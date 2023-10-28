% Guntin, Ottonello and Perez (2022) 
% Code solves the model and computes elasticities across income
% distribution for exercise with heterogeneous changes in uncertainty

clear all
close all
clc

% output:
% Figure 5 (d);
% Figure D.13 (b);
% Figure D.15 (d);

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

% Define Linear Function Space for TPM and Ergodic distribution

Grid.nalin        = Grid.na;       % number of points for assets a
Grid.nmulin        = Grid.nmu;         % number of points for mu

agridlin       = Grid.amin + (Grid.amax - Grid.amin)*linspace(0, 1, Grid.nalin)'.^2; 
mugridlin       =  linspace(Grid.mumin, Grid.mumax, Grid.nmulin)'; 

mugridlin = round(mugridlin*10^5)/10^5;

Grid.fspacelin     = fundef({'spli', agridlin,  0, 1}, ...
                         {'spli', mugridlin,  0, 1});

Grid.slin      = gridmake(funnode(Grid.fspacelin));

Grid.Nlin      = size(Grid.slin, 1); 

% Construct TPM

aprime  = max(min(ap, Grid.amax), Grid.amin);  % impose a bound so dont extrapolate
sav    = aprime - Grid.slin(:,1); % (a' - a)
c = exp( Grid.slin(:,2) ) + (1+par.r_star)*Grid.slin(:,1) - aprime; 

[I,Locmu] = ismember( round(Grid.slin(:,2)*10^2)/10^2 ,  round(mugridlin*10^2)/10^2 );
Pmu_s = Grid.Pmu(Locmu,:);

P      = sparse(Grid.Nlin, Grid.Nlin); %TPM

for i  = 1 : Grid.nmulin 

muprime       = ones(Grid.Nlin,1)*mugridlin(i);              

    P     = P + Pmu_s(:,i).*funbas( Grid.fspacelin, [aprime, muprime] ); %Opertion not available in Matlab 2014 

end

% Ergodic distribution
[n, ~]     = eigs(P',1,'lm');
n          = n/sum(n);  
n          = max(n, 0);


dist = reshape(n,[Grid.nalin Grid.nmulin]);
na = sum(dist,2); 
nmu = sum(dist,1)';

%% Crisis MIT shock 

import = fullfile('../../../input/', 'shock.mat');
load(import);

% recalibrate to mean elasticity
pers_perm    = 0.15; 
nu           = 2.8;

% loadings calibrated to dispersion increments in the crisis
volshock = zeros(1,length(nmu));
volshock(1,1:12)   =  .58*ones(1,12);     % assume tails flat
volshock(1,13)     =  .50*ones(1,1);
volshock(1,14)     =  .32*ones(1,1);
volshock(1,15)     =  .27*ones(1,1);
volshock(1,16)     =  .24*ones(1,1);
volshock(1,17)     =  .21*ones(1,1);
volshock(1,18)     =  .14*ones(1,1);
volshock(1,19)     = -.02*ones(1,1);
volshock(1,20)     = -.04*ones(1,1);
volshock(1,21:end) = -.15*ones(1,31-21+1); % assume tails flat

volshockpers = 1/3; % short-lived shock

% probability transition matrix across time

par.sig_mu_mat = zeros(40,length(nmu));
par.sig_mu_mat(1,:) = par.sig_mu*ones(1,length(nmu));
for hhh = 1:length(nmu)
for hh = 2:39
       par.sig_mu_mat(hh,hhh) = par.sig_mu + volshockpers^(hh-2)*volshock(1,hhh)*par.sig_mu;
end
end
par.sig_mu_mat(end,:) = par.sig_mu*ones(1,length(nmu));

run mprob_hun.m
Grid.Pmu_mat = Pmu;

% solution shocks and relevant moments
run mit_shocks_hun.m

%% plot

import = fullfile('../../../input/', 'baseline_results.mat');
load(import);

ftsize = 13;
set(groot, 'DefaultAxesTickLabelInterpreter','latex'); 
set(groot, 'DefaultLegendInterpreter','latex');
set(groot, 'DefaultAxesFontSize',ftsize);

run plots_uncertainty.m
