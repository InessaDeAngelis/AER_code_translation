% Guntin, Ottonello and Perez (2022) 
% Code solves the model for baseline calibration, and computes baseline PI-view and CT-view experiments

% 1 step - record parameters
% 2 step - compute steady-state moments
% 3 step - plot elasticities for permanent and transitory for PI-view and CT-view

% output: 
% Table 3; 
% Table 4; 
% Figure 5 and Figure 7 panel (a); 
% Figure 7 panel (b) and Figure D.15 panel (a);
% Figure D.2 panel (a) and (b);
% Figure D.8 panel (a) and (b);

clear all
close all
clc

%% parameters

% -> common parameters

% preferences and interest rate
par.beta = .9; % 
par.sigma = 2; % CRRA
par.r_star = 0.02; % interest rate

% aggregate income and constraint
par.Y = 1;
par.kappa = 0.225;

% idio income
par.rho_mu = 0.88;
par.sig_mu = 0.258;

save('../../../input/parameters','par') % save for input other exercises

%% parameters

% Table 3

calib = fopen(fullfile('../../../output/table3.tex'), 'w');
fprintf(calib, '\\begin{tabular}{lcc} \n');
fprintf(calib, '\\hline \n');
fprintf(calib, 'Parameter & & Value \\\\ \n');
fprintf(calib, '\\hline \n');
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, 'Discount factor & $\\beta$ & %8.2f \\\\ \n',par.beta);
fprintf(calib, 'Risk-aversion coefficient & $\\gamma$ & %8.2f \\\\ \n',par.sigma);
fprintf(calib, 'Risk-free interest rate & $r*$ & %8.2f  \\\\ \n',par.r_star); % quarterly
fprintf(calib, 'Persistence of idiosyncratic process &$\\rho_\\mu$ & %8.2f  \\\\ \n',par.rho_mu);
fprintf(calib, 'Volatility of idiosyncratic process &$\\sigma_\\mu$ & %8.2f \\\\ \n',par.sig_mu);
fprintf(calib, 'Financial constraints & $\\kappa$ & %8.2f \\\\ \n',par.kappa);
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, '\\hline \n');
fprintf(calib, '\\end{tabular} \n');
fclose(calib);

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

save('../../../input/grid','Grid') % save for input other exercises
                     
%% EGM solution

% rename variables
s    = Grid.s;
s_a  = agrid;
s_mu = mugrid;
n_a  = Grid.na;
n_mu = Grid.nmu;
N    = Grid.n;

maxiter = 1000;
tol=1e-10;

[c,y,ap,bind_mat] = solutionEGM(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol);

%% ergodic distribution

% Define linear function space for transition matrix and ergodic distribution

Grid.nalin        = Grid.na;           % number of points for assets a
Grid.nmulin       = Grid.nmu;          % number of points for mu

agridlin  = Grid.amin + (Grid.amax - Grid.amin)*linspace(0, 1, Grid.nalin)'.^2; 
mugridlin = linspace(Grid.mumin, Grid.mumax, Grid.nmulin)';  
mugridlin = round(mugridlin*10^5)/10^5; % round to 3 decimals 

Grid.fspacelin = fundef({'spli', agridlin,  0, 1}, ...
                         {'spli', mugridlin,  0, 1});

Grid.slin      = gridmake(funnode(Grid.fspacelin));

Grid.Nlin      = size(Grid.slin, 1); 

% Construct transition matrix

aprime  = max(min(ap, Grid.amax), Grid.amin);  % impose a bound so dont extrapolate
sav    = aprime - Grid.slin(:,1);              % (a' - a)
c = exp( Grid.slin(:,2) ) + (1+par.r_star)*Grid.slin(:,1) - aprime; 

[I,Locmu] = ismember( round(Grid.slin(:,2)*10^2)/10^2 ,  round(mugridlin*10^2)/10^2 );
Pmu_s = Grid.Pmu(Locmu,:);

P      = sparse(Grid.Nlin, Grid.Nlin); % transition matrix

for i  = 1 : Grid.nmulin 

    muprime = ones(Grid.Nlin,1)*mugridlin(i);              

    P       = P + Pmu_s(:,i).*funbas( Grid.fspacelin, [aprime, muprime] );

end

% Ergodic distribution
[n, ~]     = eigs(P',1,'lm');
n          = n/sum(n);  
n          = max(n, 0);

%% wealth and income distribution moments

dist = reshape(n,[Grid.nalin Grid.nmulin]);
na = sum(dist,2); 
nmu = sum(dist,1)';

% Compute CDF on assets/income

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

% Wealth and income shares

a_integ = agridlin.*na; % wealth
atotal = sum(a_integ);
m.w_share_bot75 = sum(a_integ(1:index_a(75)))/atotal;
m.w_share_top10 = 1-sum(a_integ(1:index_a(90)))/atotal;
m.w_share_top5  = 1-sum(a_integ(1:index_a(95)))/atotal;

y_integ = exp(mugridlin).*nmu; % income
ytotal = sum(y_integ);
m.y_share_bot75 = sum(y_integ(1:index_y(75)))/ytotal;
m.y_share_top10 = 1-sum(y_integ(1:index_y(90)))/ytotal;
m.y_share_top5  = 1-sum(y_integ(1:index_y(95)))/ytotal;

% Gini index wealth/income

id_gini = (exp(mugridlin)>10^(-16));
income = exp(mugridlin);
nincome = nmu( id_gini )/sum( nmu( id_gini ));

mean_wealth      = na'*agridlin;
mean_income      = nincome'*income;
data             = [nincome, income];
cumF             = cumsum(data(:,1)); 
m.income_gini    = 1 - sum( data(:,1).*data(:,2)/mean_income.*(data(:,1) + 2*(1 - cumF)) ); % income gini

m.wealth_income = mean_wealth/mean_income; % wealth to income

gwealth = max(10^(-16),agridlin);
mean_gwealth      = na'*gwealth;
data             = [na, gwealth];
cumF             = cumsum(data(:,1)); 
m.gwealth_gini    = 1 - sum( data(:,1).*data(:,2)/mean_gwealth.*(data(:,1) + 2*(1 - cumF)) ); % wealth gini with negative values
 
% Hand-to-mouth

agridlin_htm = repmat(agridlin,[1 Grid.nmulin]);
mugridlin_htm = repmat(mugridlin',[Grid.nalin 1]);
mugridlin_htm = par.Y.*exp(mugridlin_htm);
htm = (agridlin_htm <= min(agridlin) + mugridlin_htm/24); % mugridlin_htm/24
htm = htm.*dist;
m.htm = sum(sum(htm));


%% moments in the model and data

% import data moments

opts = spreadsheetImportOptions("NumVariables", 1);
opts.Sheet = "Sheet1";
opts.DataRange = "B2:B11";
opts.VariableNames = "moments_baseline";
opts.VariableTypes = "double";
tbl = readtable("../../../input/moments_ITA.xls", opts, "UseExcel", false);
moments_baseline_data = tbl.moments_baseline;
clear opts tbl

% Table 4

calib = fopen(fullfile('../../../output/table4.tex'), 'w');
fprintf(calib, '\\begin{tabular}{lcc} \n');
fprintf(calib, '\\hline \n');
fprintf(calib, 'Variable & Model & Data \\\\ \n');
fprintf(calib, '\\hline \n');
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, '\\textit{Targeted} \\\\ \n');
fprintf(calib, '\\noalign{\\vskip 0.25em} \n');
fprintf(calib, 'Wealth-to-income ratio & %8.2f & %8.2f \\\\ \n',m.wealth_income,moments_baseline_data(1));
fprintf(calib, 'Hand-to-mouth share & %8.2f & %8.2f \\\\ \n',m.htm,moments_baseline_data(2));
fprintf(calib, '\\noalign{\\vskip 0.25em} \n');
fprintf(calib, '\\textit{Non-Targeted} \\\\ \n');
fprintf(calib, '\\noalign{\\vskip 0.25em} \n');
fprintf(calib, 'Gini index income & %8.2f & %8.2f \\\\ \n',m.income_gini,moments_baseline_data(3));
fprintf(calib, 'Income share bottom 75 & %8.2f & %8.2f \\\\ \n',m.y_share_bot75,moments_baseline_data(4));
fprintf(calib, 'Income share top 10 & %8.2f & %8.2f \\\\ \n',m.y_share_top10,moments_baseline_data(5));
fprintf(calib, 'Income share top 5 & %8.2f & %8.2f \\\\ \n',m.y_share_top5,moments_baseline_data(6));
fprintf(calib, '\\noalign{\\vskip 0.25em} \n');
fprintf(calib, 'Gini index wealth & %8.2f & %8.2f \\\\ \n',m.gwealth_gini,moments_baseline_data(7));
fprintf(calib, 'Wealth share bottom 75 & %8.2f & %8.2f \\\\ \n',m.w_share_bot75,moments_baseline_data(8));
fprintf(calib, 'Wealth share top 10 & %8.2f & %8.2f \\\\ \n',m.w_share_top10,moments_baseline_data(9));
fprintf(calib, 'Wealth share top 5 & %8.2f & %8.2f \\\\ \n',m.w_share_top5,moments_baseline_data(10));
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, '\\hline \n');
fprintf(calib, '\\end{tabular} \n');
fclose(calib);

%% Crisis MIT shock 

drop = 0.15;          % size income shock 

pers_perm = 0.243;    % persistence g shock
pers_temp = 0.9;      % persistence z shock
nu = 2.68;            % elasticity of Y in financial constraint

save('../../../input/shock','drop','pers_perm','pers_temp','nu')

run mit_shocks.m

save('../../../input/baseline_results','elast_PI','elast_FF'); % save baseline elasticities
save('../../../input/distmu','nmu');                           % pdf of mu

%% plots

% load data from Italy

data_ITA = readtable('../../../input/data_ITA.xls');
deccc    = 1:10;
data_smooth      = [deccc',data_ITA.elast];
elast_data_ita_s = lowess(data_smooth,1);
data_smooth      = [deccc',data_ITA.MPC];
mpc_data_ita_s   = lowess(data_smooth,1);

% create figures

dir_fig = '../../../output';

ftsize = 13;
set(groot, 'DefaultAxesTickLabelInterpreter','latex'); 
set(groot, 'DefaultLegendInterpreter','latex');
set(groot, 'DefaultAxesFontSize',ftsize);

run plots.m

