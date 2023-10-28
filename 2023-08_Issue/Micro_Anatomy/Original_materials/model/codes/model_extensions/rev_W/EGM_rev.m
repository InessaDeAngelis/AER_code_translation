% Guntin, Ottonello and Perez (2022) 
% Code solves the model and computes elasticities across income
% distribution for exercise with wealth revaluations using the observed
% drop in asset prices

% output:
% Figure 5 panel (c);

clear all
close all
clc

%% directories

dir_fig = '../../../output/';

%% parameters

import = fullfile('../../../input/', 'parameters.mat');
load(import);

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

% Define linear function space for transitions and distribution

Grid.nalin        = Grid.na;
Grid.nmulin        = Grid.nmu;

agridlin       = Grid.amin + (Grid.amax - Grid.amin)*linspace(0, 1, Grid.nalin)'.^2; 
mugridlin       =  linspace(Grid.mumin, Grid.mumax, Grid.nmulin)';  

mugridlin = round(mugridlin*10^5)/10^5;

Grid.fspacelin     = fundef({'spli', agridlin,  0, 1}, ...
                         {'spli', mugridlin,  0, 1});

Grid.slin      = gridmake(funnode(Grid.fspacelin));

Grid.Nlin      = size(Grid.slin, 1); 

% Construct transition

aprime  = max(min(ap, Grid.amax), Grid.amin);  % impose a bound so dont extrapolate
sav    = aprime - Grid.slin(:,1); % (a' - a)
c = exp( Grid.slin(:,2) ) + (1+par.r_star)*Grid.slin(:,1) - aprime; 

[I,Locmu] = ismember( round(Grid.slin(:,2)*10^2)/10^2 ,  round(mugridlin*10^2)/10^2 );
Pmu_s = Grid.Pmu(Locmu,:);

P      = sparse(Grid.Nlin, Grid.Nlin); %TPM

for i  = 1 : Grid.nmulin 

muprime       = ones(Grid.Nlin,1)*mugridlin(i);              

    P     = P + Pmu_s(:,i).*funbas( Grid.fspacelin, [aprime, muprime] );

end

% Ergodic distribution
[n, ~]     = eigs(P',1,'lm');
n          = n/sum(n);  
n          = max(n, 0);

dist = reshape(n,[Grid.nalin Grid.nmulin]);
na = sum(dist,2); 
nmu = sum(dist,1)';

%% load data Italy

data_ITA = readtable('../../../input/data_ITA.xls');
deccc = 1:10;
data_smooth= [deccc',data_ITA.elast];
elast_data_ita_s=lowess(data_smooth,1);

reval_wealth = - data_ITA.ch_y;

%% Crisis MIT shock with revaluation

import = fullfile('../../../input/', 'shock.mat');
load(import);

run mit_shocks_rev.m

save('../../../input/wrev_results','elast_PI_rev','elast_FF_rev');

%% plots

import = fullfile('../../../input/', 'baseline_results.mat');
load(import);

ftsize = 13;
set(groot, 'DefaultAxesTickLabelInterpreter','latex'); 
set(groot, 'DefaultLegendInterpreter','latex');
set(groot, 'DefaultAxesFontSize',ftsize);

run plots_rev.m

