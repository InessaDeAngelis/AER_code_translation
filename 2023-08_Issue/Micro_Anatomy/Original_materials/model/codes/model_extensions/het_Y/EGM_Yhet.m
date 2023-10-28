% Guntin, Ottonello and Perez (2022) 
% Code solves the model and computes elasticities across income
% distribution for exercise with heterogeneous loadings to income during
% the crisis

% output:
% Figure 5 panel (b); 
% Figure D12 panel (b);
% Figure D15 panel (b);

clear all
close all
clc

%% directories

dir_fig = '../../../output';

%% parameters

import = fullfile('../../../input/', 'parameters.mat');
load(import);

%% ITA data

% elasticities
data_ITA = readtable('../../../input/data_ITA.xls');
deccc = 1:10;
data_smooth      = [deccc',data_ITA.elast];
elast_data_ita_s = lowess(data_smooth,1);

% loadings function using observed income drop in crisis
par.loadings      = zeros(10,1);
par.loadings(3:8) = - data_ITA.dy(3:8)./0.15;
step              = 2.5*(data_ITA.dy(8)-data_ITA.dy(7)+data_ITA.dy(4)-data_ITA.dy(3))./2; % for tails do in steps
par.loadings(1)   = -(data_ITA.dy(3)-2*step)./0.15;
par.loadings(2)   = -(data_ITA.dy(3)-step)./0.15;
par.loadings(10)  = -(data_ITA.dy(8)+2*step)./0.15;
par.loadings(9)   = -(data_ITA.dy(8)+step)./0.15;

deccc = 1:10;
data_smooth      = [deccc',data_ITA.dy];
dy_data_ita_s = lowess(data_smooth,1);

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

[c,y,ap,bind_mat] = solutionEGM_Yhet(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol);

%% ergodic distribution

Grid.nalin        = Grid.na;           % number of points for assets a
Grid.nmulin        = Grid.nmu;         % number of points for mu

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

%% Crisis MIT shock with loadings

import = fullfile('../../../input/', 'shock.mat');
load(import);
nu = 2.9;          % recalibrate to average
pers_perm = 0.18;  % lower rho_g to compensate for extra-persistence from loadings

run mit_shocks_Yhet.m

save('../../../input/Yhet_results','elast_PI_Yhet','elast_FF_Yhet');

%% load baseline results

import = fullfile('../../../input/', 'baseline_results.mat');
load(import);

%% plot

ftsize = 13;
set(groot, 'DefaultAxesTickLabelInterpreter','latex'); 
set(groot, 'DefaultLegendInterpreter','latex');
set(groot, 'DefaultAxesFontSize',ftsize);

run plots_Yhet.m

