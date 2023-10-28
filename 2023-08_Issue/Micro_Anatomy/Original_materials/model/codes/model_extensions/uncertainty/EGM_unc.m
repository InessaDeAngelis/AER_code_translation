% Guntin, Ottonello and Perez (2022) 
% Code solves the model and computes elasticities across income
% distribution for exercise with an homogeneous increase in uncertainty

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

% Define Linear Function Space for TPM and Ergodic distribution

Grid.nalin        = Grid.na;       % number of points for assets a
Grid.nmulin        = Grid.nmu;         % number of points for mu

agridlin       = Grid.amin + (Grid.amax - Grid.amin)*linspace(0, 1, Grid.nalin)'.^2; 
mugridlin       =  linspace(Grid.mumin, Grid.mumax, Grid.nmulin)';  

% Round to 3 decimals 

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
    
% recalibration
volshock     = .41;   % increment in the idiosyncratic shocks volatility calibrated to fit cross-sectional income dispersion increment in the data
volshockpers = 1/3;
pers_perm    = 0.1;
nu           = 2.55; 

run mit_shocks_unc.m

save('../../../input/unc_results','elast_FF_unc','elast_PI_unc');




