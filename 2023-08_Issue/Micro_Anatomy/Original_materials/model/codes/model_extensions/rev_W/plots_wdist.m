%% Figures of elasticities with observed wealth distribution and revaluation

% load elasticities from other exercises

import = fullfile('../../../input/', 'baseline_results.mat');
load(import);

import = fullfile('../../../input/', 'wrev_results.mat');
load(import);

% load data ITA

data_ITA = readtable('../../../input/data_ITA.xls');
deccc = 1:10;
data_smooth= [deccc',data_ITA.elast];
elast_data_ita_s=lowess(data_smooth,1);

% interpolate to deciles

elast_PI_distliq_reval = elast_PI_distliq_reval';
elast_FF_distliq_reval = elast_FF_distliq_reval';

nmu_cum = cumsum(nmu);
elast_PI_plot = interp1(nmu_cum(8:23),elast_PI(2,8:23),0.05:.1:.95,'linear','extrap');
elast_PI_rev_plot = interp1(nmu_cum(8:23),elast_PI_rev(2,8:23),0.05:.1:.95,'linear','extrap');
elast_PI_distliq_reval_plot = interp1(nmu_cum(8:22),elast_PI_distliq_reval(1,8:22),0.05:.1:.95,'linear','extrap');

elast_FF_plot = interp1(nmu_cum(8:23),elast_FF(2,8:23),0.05:.1:.95,'linear','extrap');
elast_FF_rev_plot = interp1(nmu_cum(8:23),elast_FF_rev(2,8:23),0.05:.1:.95,'linear','extrap');
elast_FF_distliq_reval_plot = interp1(nmu_cum(8:22),elast_FF_distliq_reval(1,8:22),0.05:.1:.95,'linear','extrap');

%% plots

close all;

% elasticities with wealth revaluation with observed distribution and model distribution

jj = 1;

figure(jj)
plot(1:10,elast_PI_plot,'-mo','LineWidth',5,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,elast_PI_rev_plot,'D','LineWidth',3,'MarkerSize',12,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,elast_PI_distliq_reval_plot,'--','LineWidth',5,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,data_ITA.elast,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,elast_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('C-Y Elasticity','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('baseline','wealth reval (model asset dist)',' wealth reval (observed asset dist)', 'data','Location','Northeast' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);

grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)]; 
print( gcf, '-dpdf', '-r300', 'figureD4_b');
movefile('figureD4_b.pdf',dir_fig);

jj = jj + 1;


figure(jj)
plot(1:10,elast_FF_plot,'-mo','LineWidth',5,'Color',[128/256,128/256,128/256])
hold on;
plot(1:10,elast_FF_rev_plot,'D','LineWidth',3,'MarkerSize',12,'Color',[128/256,128/256,128/256])
hold on;
plot(1:10,elast_FF_distliq_reval_plot,'--','LineWidth',5,'Color',[128/256,128/256,128/256])
hold on;
plot(1:10,data_ITA.elast,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,elast_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('C-Y Elasticity','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('baseline','wealth reval (model asset dist)',' wealth reval (observed asset dist)', 'data','Location','Northeast' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);

grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)]; 
print( gcf, '-dpdf', '-r300', 'figureD15_c');
movefile('figureD15_c.pdf',dir_fig);

