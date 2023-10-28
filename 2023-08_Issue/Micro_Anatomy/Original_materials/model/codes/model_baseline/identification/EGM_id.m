% Guntin, Ottonello and Perez (2022) 
% Code solves the model and computes elasticities across income distribution for different values of nu and rho_gamma parameters

% output:
% Figure D1 panel (a) and (b); 

clear all
close all
clc

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

dist = reshape(n,[Grid.nalin Grid.nmulin]);
na   = sum(dist,2); 
nmu  = sum(dist,1)';

%% parameter sensitivity 

pers_perm_mat = [0,.1,0.15,0.25:.1:.45,.6,.7];
pers_temp_mat = 0.9;
nu_mat = [0:.25:1,1.5:1:3.5];

elast_mat_rhog =  zeros(10,length(pers_perm_mat)); % to record elasticities computed
elast_mat_nu   =  zeros(10,length(nu_mat)); % to record elasticities computed


% iterate: rho_g
for k=1:length(pers_perm_mat)    

drop = 0.15;            

pers_perm = pers_perm_mat(k);

run mit_shocks_id_PI.m

elast_mat_rhog(:,k) = elast';
        
    
end

% iterate: nu
for k=1:length(nu_mat)

drop = 0.15;
pers_temp = pers_temp_mat(1);
nu = nu_mat(k);

run mit_shocks_id_FF.m

elast_mat_nu(:,k) = elast';

end

%% plots

close all;
dir_fig = '../../../output';

ftsize = 13;
set(groot, 'DefaultAxesTickLabelInterpreter','latex'); 
set(groot, 'DefaultLegendInterpreter','latex');
set(groot, 'DefaultAxesFontSize',ftsize);

jj = 1;

% across g shock persistence

figure(jj)
for i = 1:length(pers_perm_mat)-1
plot(1:10,elast_mat_rhog(:,i),'k-','LineWidth',2,'Color',[10/256,10/256,i/length(pers_perm_mat)*256/256]) 
hold on;
end
plot(1:10,elast_mat_rhog(:,end),'k-','LineWidth',2,'Color',[10/256,10/256,256/256]);
hold off;
grid on;
ylabel('C-to-Y elasticty','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
ylim([0 2.5]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD1_a');
movefile('figureD1_a.pdf',dir_fig);

% across nu

jj = jj + 1;

figure(jj)
for i = 1:length(nu_mat)-2
plot(1:10,elast_mat_nu(:,i),'k-','LineWidth',2,'Color',[10/256,10/256,i/(length(nu_mat)-1)*256/256]) 
hold on;
end
plot(1:10,elast_mat_nu(:,end-1),'k-','LineWidth',2,'Color',[10/256,10/256,256/256]);
hold off;
grid on;
ylabel('C-to-Y elasticty','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
ylim([0 2.5]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD1_b');
movefile('figureD1_b.pdf',dir_fig);


