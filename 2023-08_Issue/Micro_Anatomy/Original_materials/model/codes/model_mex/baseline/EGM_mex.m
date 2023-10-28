% Guntin, Ottonello and Perez (2022) 
% Code solves the model for calibration, and computes baseline
% PI-view elasticities

% output: 
% Table D.3;
% Table D.4;

clear all
close all
clc

%% directories

dir_fig = '../../../output';
dir_tab = '../../../output';

%% parameters

% -> common parameters

% preferences and interest rate
par.beta = .91; % .95
par.sigma = 2; % CRRA
par.r_star = 0.02; % interest rate

% aggregate income and constraint
par.Y = 1;
par.kappa = 0.18; % .0048

% idio income
par.rho_mu = .9695;
par.sig_mu = 0.1833;

% subsistence level of consumption
inc_mean = -(1/2.*par.sig_mu.^2)./(1-par.rho_mu.^2);
inc_sd = sqrt((par.sig_mu.^2)./(1-par.rho_mu.^2));

c_level_mex = norminv(0.1572666667,inc_mean(1),inc_sd(1)); % poverty WB 5.5USD/day PPP 2011 (1992-2018)
c_level_mex = exp(c_level_mex);

par.cbar = c_level_mex;

parmex = par;
save('../../../input/parameters_mex','par')

%% calibration for Mexico with non-H

import = fullfile('../../../input/', 'parameters.mat');
load(import);

calib = fopen(fullfile(dir_tab,'tableD3.tex'), 'w');
fprintf(calib, '\\begin{tabular}{lccc} \n');
fprintf(calib, '\\hline \n');
fprintf(calib, 'Parameter & & Italy & Mexico  \\\\ \n');
fprintf(calib, '\\hline \n');
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, '\\textit{Country-Specific}  \\\\ \n');
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, 'Discount factor & $\\beta$ & %8.2f & %8.2f \\\\ \n',par.beta,parmex.beta);
fprintf(calib, 'Persistence of idiosyncratic process &$\\rho_\\mu$ & %8.2f & %8.2f \\\\ \n',par.rho_mu,parmex.rho_mu);
fprintf(calib, 'Volatility of idiosyncratic process &$\\sigma_\\mu$ & %8.2f & %8.2f \\\\ \n',par.sig_mu,parmex.sig_mu);
fprintf(calib, 'Financial constraints & $\\kappa$ & %8.2f & %8.2f \\\\ \n',par.kappa,parmex.kappa);
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, '\\textit{Assigned Parameters}  \\\\ \n');
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, 'Risk-aversion coefficient & $\\gamma$ & %8.2f & %8.2f \\\\ \n',par.sigma,parmex.sigma);
fprintf(calib, 'Risk-free interest rate & $r*$ & %8.2f & %8.2f \\\\ \n',par.r_star,parmex.r_star);
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, '\\textit{Nonhomothetic}  \\\\ \n');
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, 'Consumption subsistence level & $\\underbar{c}$ & %8.2f & %8.2f \\\\ \n',0.04,parmex.cbar);
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, '\\hline \n');
fprintf(calib, '\\end{tabular} \n');
fclose(calib);

par = parmex;

%% grid

Grid.na         = 500;       % number of points for assets a grid construction
Grid.nmu         = 31;       % number of points for mu grid

mu_scale   = sqrt(Grid.nmu-1);
[mugrid, Grid.Pmu]  = tauchen(-1/2*(par.sig_mu.^2)/(1-par.rho_mu.^2), par.rho_mu, par.sig_mu, Grid.nmu, mu_scale);
Grid.mumin = min(mugrid);
Grid.mumax = max(mugrid);

Grid.amin      = - par.kappa; 
Grid.amax =  100;
agrid = Grid.amin + (Grid.amax - Grid.amin)*linspace(0, 1, round(Grid.na)).^2';

Grid.na = length(agrid);


Grid.fspacelin     = fundef({'spli', agrid,  0, 1}, ...
                         {'spli', mugrid,  0, 1});
                     
Grid.s      = gridmake(funnode(Grid.fspacelin)); % state na*nz*nmu rows and 3 columns for each variable

Grid.n      = size(Grid.s, 1);  
                     
%% EGM solution

% rename variables
s = Grid.s;
s_a = agrid;
s_mu = mugrid;
n_a = Grid.na;
n_mu = Grid.nmu;
N   = Grid.n;

maxiter = 1000;
tol=1e-10;

[c,y,ap,bind_mat] = solutionEGM(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol);

%% ergodic distribution

Grid.nalin        = Grid.na;
Grid.nmulin        = Grid.nmu;

agridlin       = Grid.amin + (Grid.amax - Grid.amin)*linspace(0, 1, Grid.nalin)'.^2; 
mugridlin       =  linspace(Grid.mumin, Grid.mumax, Grid.nmulin)';  

mugridlin = round(mugridlin*10^5)/10^5;

Grid.fspacelin     = fundef({'spli', agridlin,  0, 1}, ...
                         {'spli', mugridlin,  0, 1});

Grid.slin      = gridmake(funnode(Grid.fspacelin));

Grid.Nlin      = size(Grid.slin, 1); 

aprime  = max(min(ap, Grid.amax), Grid.amin);
sav    = aprime - Grid.slin(:,1);
c = exp( Grid.slin(:,2) ) + (1+par.r_star)*Grid.slin(:,1) - aprime; 

[I,Locmu] = ismember( round(Grid.slin(:,2)*10^2)/10^2 ,  round(mugridlin*10^2)/10^2 );
Pmu_s = Grid.Pmu(Locmu,:);

P      = sparse(Grid.Nlin, Grid.Nlin);

for i  = 1 : Grid.nmulin 

muprime       = ones(Grid.Nlin,1)*mugridlin(i);              

    P     = P + Pmu_s(:,i).*funbas( Grid.fspacelin, [aprime, muprime] );

end

% Ergodic distribution
[n, ~]     = eigs(P',1);
n          = n/sum(n); 
n          = max(n, 0); 

dist = reshape(n,[Grid.nalin Grid.nmulin]);
na = sum(dist,2); 
nmu = sum(dist,1)';

%% wealth and income distribution moments

%Compute CDF on assets/income

Gassets = zeros(Grid.nalin,1);
Gy = zeros(Grid.nmulin,1);
index_a = zeros(100,1);
index_y = zeros(100,1);
perc = linspace(1,100,100)';

for i=1:Grid.nalin
    Gassets(i)  = sum(na(1:i));
end

for i=1:Grid.nmulin
    Gy(i)  = sum(nmu(1:i));
end

for i=1:100
    [~, index_a(i)]   = min( abs( 100*Gassets   - perc(i) ) );
    [~, index_y(i)]   = min( abs( 100*Gy  - perc(i) ) );
end

% income shares
y_integ = exp(mugridlin).*nmu; % income
ytotal = sum(y_integ);
m.y_share_bot75 = sum(y_integ(1:index_y(75)))/ytotal;
m.y_share_top10 = 1-sum(y_integ(1:index_y(90)))/ytotal;
m.y_share_top5  = 1-sum(y_integ(1:index_y(95)))/ytotal;

% Gini index income

id_gini = (exp(mugridlin)>10^(-16));
income = exp(mugridlin);
nincome = nmu( id_gini )/sum( nmu( id_gini ));

mean_income      = nincome'*income;
data             = [nincome, income];
cumF             = cumsum(data(:,1)); 
m.income_gini    = 1 - sum( data(:,1).*data(:,2)/mean_income.*(data(:,1) + 2*(1 - cumF)) );

% constraints

agridlin_htm = repmat(agridlin,[1 Grid.nmulin]);
mugridlin_htm = repmat(mugridlin',[Grid.nalin 1]);
mugridlin_htm = par.Y.*exp(mugridlin_htm);
htm = (agridlin_htm <= 0 );
htm = htm.*dist;
m.htm = sum(sum(htm));

%% moments model and data

% data 
opts = spreadsheetImportOptions("NumVariables", 1);
opts.Sheet = "Sheet1";
opts.DataRange = "B2:B7";
opts.VariableNames = "moments_mex";
opts.VariableTypes = "double";
tbl = readtable("../../../input/moments_MEX.xls", opts, "UseExcel", false);
moments_mex_data = tbl.moments_mex;
clear opts tbl

% Table D.4 
calib = fopen(fullfile(dir_tab,'tableD4.tex'), 'w');
fprintf(calib, '\\begin{tabular}{lcc} \n');
fprintf(calib, '\\hline \n');
fprintf(calib, 'Variable & Model & Data \\\\ \n');
fprintf(calib, '\\hline \n');
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, '\\textit{Targeted} \\\\ \n');
fprintf(calib, '\\noalign{\\vskip 0.25em} \n');
fprintf(calib, 'Gini index income & %8.2f & %8.2f \\\\ \n',m.income_gini,moments_mex_data(1));
fprintf(calib, 'No liquid assets & %8.2f & %8.2f \\\\ \n',m.htm,moments_mex_data(2));
fprintf(calib, 'Share below subsistence & %8.2f & %8.2f \\\\ \n',0.1572666667,moments_mex_data(3)/100); % matched using c_bar (see plot in EGM_mex_nonh.m)
fprintf(calib, '\\noalign{\\vskip 0.25em} \n');
fprintf(calib, '\\textit{Non-Targeted} \\\\ \n');
fprintf(calib, '\\noalign{\\vskip 0.25em} \n');
fprintf(calib, 'Income share bottom 75 & %8.2f & %8.2f \\\\ \n',m.y_share_bot75,moments_mex_data(4));
fprintf(calib, 'Income share top 10 & %8.2f & %8.2f \\\\ \n',m.y_share_top10,moments_mex_data(5));
fprintf(calib, 'Income share top 5 & %8.2f & %8.2f \\\\ \n',m.y_share_top5,moments_mex_data(6));
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, '\\hline \n');
fprintf(calib, '\\end{tabular} \n');
fclose(calib);

%% Crisis MIT shock 

drop = 0.19;            % 19% drop
pers_perm = 1-0.982;    % persistence g shock (note: lower than 0 so we match lower than 1 elasticities in Mexico)

run mit_shocks.m

elast_PI_mex = elast_PI;

save('../../../input/baseline_results_MEX','elast_PI_mex');