% Guntin, Ottonello and Perez (2022) 
% Code computes response of household's consumption to different transfer policy interventions

% output: 
% Figure 8; 
% Table D.2;
% Figure D.18 panel (a) and (b);

clear all
close all
clc

%% directories

dir_fig = '../../output';
dir_tab = '../../output';


%% parameters

import = fullfile('../../input/', 'parameters.mat');
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

par.transf = zeros(1,n_mu);

[c,y,ap,bind_mat] = solutionEGM(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol);

%% ergodic initial distribution

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

P      = sparse(Grid.Nlin, Grid.Nlin); %TPM

for i  = 1 : Grid.nmulin 

muprime       = ones(Grid.Nlin,1)*mugridlin(i);              

    P     = P + Pmu_s(:,i).*funbas( Grid.fspacelin, [aprime, muprime] );

end

% Ergodic distribution
[n, ~]     = eigs(P',1);
n          = n/sum(n); 
n          = max(n, 0); 

% wealth and income distribution in st-st

dist = reshape(n,[Grid.nalin Grid.nmulin]);
na = sum(dist,2); 
nmu = sum(dist,1)';

%% Transfers

% 1: tau indicates progressivity of transfer scheme. If tau = 0 then lump-sum
% 2: transfer is made unexpectedly at period t = 1 (crisis period)
% 3: payments of the transfer are done from t>1 onwards

tau = -1:.1:1;
tau = tau';

par.eta = .1;
transf = par.eta.*par.Y;                 % tax payments
par.transfers_pay = par.r_star.*transf; % tax payments

e_tau = zeros(length(tau),1);
for i = 1:length(tau)
e_tau(i) = sum(exp(-tau(i)*s_mu).*nmu);      %integral across mu for a given tau
end
X = transf./e_tau;

par.transfers = zeros(n_mu,length(tau));

for i = 1:length(tau)
par.transfers(:,i) = X(i).*exp(-tau(i)*s_mu); % transfer for each income level (rows) and each tax scheme (columns)
end

% transfers matrix across time and agents

par.transf_mat = zeros(40,n_mu);            % shock length x income distribution
par.transf_mat(2,:) = par.transfers(:,11)'; % lump-sum
par.transf_mat(3:end,:) = - par.transfers_pay.*ones(38,n_mu);

%% MIT shock 

import = fullfile('../../input/', 'shock.mat');
load(import);

run mit_shocks_policy.m

%% Plot for flat policy exercise

ftsize = 13;
set(groot, 'DefaultAxesTickLabelInterpreter','latex'); 
set(groot, 'DefaultLegendInterpreter','latex');
set(groot, 'DefaultAxesFontSize',ftsize);

jj = 1;

figure(jj)
plot(1:10,mpc_t_T_plot,'--','LineWidth',5,'Color',[0/256,69/256,255/256]) 
hold on;
plot(1:10,mpc_t_TEMP_plot,'D','LineWidth',5,'MarkerSize',8,'Color',[100/256,0/256,0/256]) 
hold on;
plot(1:10,mpc_t_PI_plot,'k-','LineWidth',5,'Color',[255/256,69/256,0/256]) 
hold on;
plot(1:10,mpc_t_FF_plot,'-o','LineWidth',5,'MarkerSize',8,'Color',[128/256,128/256,128/256]) 
hold off;
grid on;
ylabel('MPC to transfer policy','FontSize',ftsize,'interpreter','latex')
xlabel('income deciles','FontSize',ftsize,'interpreter','latex')
legend('steady state','transitory income shock','PI crisis','CT crisis','Location','Northeast' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 1]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figure8');
movefile('figure8.pdf',dir_fig);

% hand-to-mouth

calib = fopen(fullfile(dir_tab,'tableD2.tex'), 'w');
fprintf(calib, '\\begin{tabular}{lccc} \n');
fprintf(calib, '\\hline \n');
fprintf(calib, ' & HtM & Non-HtM & Average \\\\ \n');
fprintf(calib, '\\hline \n');
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, '\\textit{Scenarios} \\\\  \n');
fprintf(calib, 'Steady state & %8.2f & %8.2f & %8.2f \\\\ \n',mpc_T_htm,mpc_T_nhtm,mpc_ag_T);
fprintf(calib, 'Transitory income shock & %8.2f & %8.2f & %8.2f \\\\ \n',mpc_TEMP_htm,mpc_TEMP_nhtm,mpc_ag_TEMP);
fprintf(calib, 'PI crisis & %8.2f & %8.2f & %8.2f \\\\ \n',mpc_PI_htm,mpc_PI_nhtm,mpc_ag_PI);
fprintf(calib, 'CT crisis & %8.2f & %8.2f & %8.2f \\\\ \n',mpc_FF_htm,mpc_FF_nhtm,mpc_ag_FF);
fprintf(calib, '\\noalign{\\vskip 0.5em} \n');
fprintf(calib, '\\hline \n');
fprintf(calib, '\\end{tabular} \n');
fclose(calib);

%% Results for different levels of progressivity

%%% Transfers

% 1: tau indicates progressivity of transfer scheme. If tau = 0 then lump-sum
% 2: transfer is made unexpectedly at period t = 1 (crisis period)
% 3: payments of the transfer are done from t>1 onwards

tau =-1:.1:1;
tau = tau';

par.eta = .1;
transf = par.eta.*par.Y;
par.transfers_pay = par.r_star.*transf;

e_tau = zeros(length(tau),1);
for i = 1:length(tau)
e_tau(i) = sum(exp(-tau(i)*s_mu).*nmu); %integral across mu for a given tau
end
X = transf./e_tau;

par.transfers = zeros(n_mu,length(tau));

for i = 1:length(tau)
par.transfers(:,i) = X(i).*exp(-tau(i)*s_mu); % transfer for each income level (rows) and each tax scheme (columns)
end

% transfers matrix across time and agents

par.transf_mat = zeros(40,n_mu);            % shock length x income distribution
par.transf_mat(2,:) = par.transfers(:,11)'; % lump-sum
par.transf_mat(3:end,:) = - par.transfers_pay.*ones(38,n_mu);

%%% Results for different levels of progressivity

mpc_T_tau  = zeros(length(tau),1);
mpc_PI_tau = zeros(length(tau),1);
mpc_FF_tau = zeros(length(tau),1);

for hhh = 1:length(tau)
    
par.transf_mat = zeros(40,n_mu);            % shock length x income distribution
par.transf_mat(2,:) = par.transfers(:,hhh)'; % lump-sum
par.transf_mat(3:end,:) = - par.transfers_pay.*ones(38,n_mu);
        
import = fullfile('../../input/', 'shock.mat');
load(import);

run mit_shocks_policy.m    
    
% MPC for different aggregate shocks
mpc_T_tau(hhh,1)  =  mpc_ag_T;
mpc_PI_tau(hhh,1) =  mpc_ag_PI;
mpc_FF_tau(hhh,1) =  mpc_ag_FF;
    
end

%%% Figures

jj = jj+1;

figure(jj)
plot(tau,mpc_T_tau,'--','LineWidth',5,'Color',[0/256,69/256,255/256]) 
hold on;
plot(tau,mpc_PI_tau,'k-','LineWidth',5,'Color',[255/256,69/256,0/256]) 
hold on;
plot(tau,mpc_FF_tau,'-o','LineWidth',5,'MarkerSize',8,'Color',[128/256,128/256,128/256]) 
hold off;
grid on;
ylabel('MPC to transfer policy','FontSize',ftsize,'interpreter','latex')
xlabel('tax progressivity ($\tau$)','FontSize',ftsize,'interpreter','latex')
legend('policy in steady state','policy in PI crisis','policy in CT crisis','Location','Northeast' );
xlim([-1 1]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 .8]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD18_b');
movefile('figureD18_b.pdf',dir_fig);

jj = jj + 1;

% deciles
nmu_cum = cumsum(nmu);
transfer_1_plot    = interp1(nmu_cum(8:23),par.transfers(8:23,11),0.05:.1:.95,'linear','extrap');
transfer_2_plot    = interp1(nmu_cum(8:23),par.transfers(8:23,6),0.05:.1:.95,'linear','extrap');
transfer_3_plot    = interp1(nmu_cum(8:23),par.transfers(8:23,16),0.05:.1:.95,'linear','extrap');

figure(jj)
plot(1:10,transfer_1_plot,'k-','LineWidth',5,'Color',[0/256,0/256,0/256]) 
hold on;
plot(1:10,transfer_2_plot,'--','LineWidth',5,'Color',[0/256,0/256,0/256])
hold on;
plot(1:10,transfer_3_plot,'*','LineWidth',5,'Color',[0/256, 0/256,0/256])
hold off;
grid on;
legend('lump sum','$\tau < 0$','$\tau > 0$','FontSize',ftsize,'Location','North');
ylabel('transfer','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
xlim([1 10]);
ylim([.03 .17]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD18_a');
movefile('figureD18_a.pdf',dir_fig);
