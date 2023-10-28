% Guntin, Ottonello and Perez (2022) 
% Code solves the model and computes elasticities across income
% distribution for exercise with non-homothetic preferences for Italy

% output:
% Figure 6 panel (a); 
% Figure D14 panel (a);

clear all
close all
clc

%% directories

dir_fig = '../../../output';

%% parameters

import = fullfile('../../../input/', 'parameters.mat');
load(import);

par.cbar = 0.04; % subsistence level for ITA

save('../../../input/param_nh_ITA','par');

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

[c,y,ap,bind_mat] = solutionEGM_nonh(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol);

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

%% Shocks

import = fullfile('../../../input/', 'shock.mat');
load(import);

% recover policy functions for t = 0,...,T
% dimensions of each matrix are (a x mu) rows x T+1 columns

% -> permanent one time shock = kappa constant + one time shock of income

par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)
       par.Y_mat(hh) = par.Y_mat(hh-1).*exp(-drop*pers_perm^(hh-2));
end
par.kappa_mat = par.kappa.*ones(40,1); % remains unchanged

[c_PI,ap_PI,y_PI,a_PI] = policy_shock_nonh(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_PI = par.Y_mat;

% -> temporary double shock = kappa drop and increase + path of income down
% and recover

drop = drop/pers_temp;

par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)-1
       par.Y_mat(hh) = par.Y.*exp(-drop*pers_temp^(hh-1));
end
par.Y_mat(end) = par.Y;
par.kappa_mat = par.kappa.*par.Y_mat.^nu; % kappa drops and recovers

[c_FF,ap_FF,y_FF,a_FF] = policy_shock_nonh(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_FF = par.Y_mat;

run mit_shocks_nonh.m

save('../../../input/nh_results','elast_PInh','elast_FFnh');

%% data ITA

% import data

import = fullfile('../../../input/', 'baseline_results.mat');
load(import);

data_ITA = readtable('../../../input/data_ITA.xls');
deccc = 1:10;
data_smooth= [deccc',data_ITA.elast];
elast_data_ita_s=lowess(data_smooth,1);

% deciles interpolation in grid

nmu_cum = cumsum(nmu);
elast_PI_plot = interp1(nmu_cum(8:23),elast_PI(2,8:23),0.05:.1:.95,'linear','extrap');
elast_PInh_plot = interp1(nmu_cum(8:23),elast_PInh(2,8:23),0.05:.1:.95,'linear','extrap');

%% plot paper

close all;

ftsize = 13;
set(groot, 'DefaultAxesTickLabelInterpreter','latex'); 
set(groot, 'DefaultLegendInterpreter','latex');
set(groot, 'DefaultAxesFontSize',ftsize);

jj = 1;

figure(jj)
plot(1:10,elast_PI_plot,'-mo','LineWidth',5,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,elast_PInh_plot,'kD','LineWidth',3,'MarkerSize',12,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,data_ITA.elast,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,elast_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('C-Y Elasticity','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('baseline model','model w. non-hometeticities', 'data','Location','Southwest' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figure6_a');
movefile('figure6_a.pdf',dir_fig);

% distribution of income and poverty level

inc_mean = -(1/2.*par.sig_mu.^2)./(1-par.rho_mu.^2);
inc_sd = sqrt((par.sig_mu.^2)./(1-par.rho_mu.^2));

c_level_ita = norminv(0.0143,inc_mean(1),inc_sd(1)); % poverty WB 5.5USD/day PPP 2011 (1992-2018)
c_level_ita = exp(c_level_ita);

pdfita = makedist('Normal',inc_mean(1),inc_sd(1));
x = -4:.1:3.4;
pdf_ita = pdf(pdfita,x);
x_aux = x(x<log(c_level_ita));
pdf_ita_aux = (pdf_ita(x<log(c_level_ita)));

jj = jj + 1;

figure(jj)
plot(x,pdf_ita,'k-','LineWidth',3,'Color',[20/256,20/256,128/256])
hold on;
area(x_aux,pdf_ita_aux,'FaceColor',[20/256,20/256,128/256])
hold off;
grid on;
ylabel('pdf','FontSize',ftsize,'interpreter','latex')
xlabel('log(income)','FontSize',ftsize,'interpreter','latex')
xlim([-4 3.4]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD14_a');
movefile('figureD14_a.pdf',dir_fig);

