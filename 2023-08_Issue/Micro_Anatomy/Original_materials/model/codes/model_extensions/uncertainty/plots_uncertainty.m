%% plots for uncertainty shocks

close all;

% load data
data_ITA = readtable('../../../input/data_ITA.xls');
deccc = 1:10;
data_smooth= [deccc',data_ITA.elast];
elast_data_ita_s=lowess(data_smooth,1);

load('../../../input/unc_results');

% deciles interpolation in grid

nmu_cum = cumsum(nmu);
elast_PI_plot = interp1(nmu_cum(8:23),elast_PI(2,8:23),0.05:.1:.95,'linear','extrap');
elast_FF_plot = interp1(nmu_cum(8:23),elast_FF(2,8:23),0.05:.1:.95,'linear','extrap');
elast_PI_unc_plot = interp1(nmu_cum(8:23),elast_PI_unc(2,8:23),0.05:.1:.95,'linear','extrap');
elast_FF_unc_plot = interp1(nmu_cum(8:23),elast_FF_unc(2,8:23),0.05:.1:.95,'linear','extrap');
elast_PI_hun_plot = interp1(nmu_cum(8:23),elast_PI_hun(2,8:23),0.05:.1:.95,'linear','extrap');
elast_FF_hun_plot = interp1(nmu_cum(8:23),elast_FF_hun(2,8:23),0.05:.1:.95,'linear','extrap');

% plots
jj = 0;

% heterogeneous uncertainty shock 

jj = 1 + jj;

figure(jj)
plot(1:10,change_vol_dist,'-mo','LineWidth',5,'Color',[128/256,20/256,0/256]) 
hold on;
plot(1:10,data_ITA.inc_sig,'o','LineWidth',3,'Color',[0/256,0/256,0/256]) 
hold on;
plot(1:10,data_ITA.inc_sig_i,'--','LineWidth',5,'Color',[0/256,0/256,0/256]) 
hold off;
hold off;
grid on;
ylabel('$\sigma_{\mu_{t}}/\sigma_{\mu}$','FontSize',ftsize,'interpreter','latex')
xlabel('income deciles','FontSize',ftsize,'interpreter','latex')
legend('model','data','Location','Northeast' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([.8 1.3]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD13_b');
movefile('figureD13_b.pdf',dir_fig);

% elasticity graph with heterogeneous and homogeneous increment in uncertainty

jj = jj + 1;

figure(jj)
plot(1:10,elast_PI_plot,'-mo','LineWidth',5,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,elast_PI_unc_plot,'-.','LineWidth',5,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,elast_PI_hun_plot,'kD','LineWidth',3,'MarkerSize',12,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,data_ITA.elast,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,elast_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('C-Y Elasticity','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('baseline model','homogenous uncertainty shock','heterogeneous uncertainty shock', 'data','Location','Southwest' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figure5_d');
movefile('figure5_d.pdf',dir_fig);

jj = jj + 1;

figure(jj)
plot(1:10,elast_FF_plot,'-mo','LineWidth',5,'Color',[128/256,128/256,128/256])
hold on;
plot(1:10,elast_FF_unc_plot,'-.','LineWidth',5,'Color',[128/256,128/256,128/256])
hold on;
plot(1:10,elast_FF_hun_plot,'kD','LineWidth',3,'MarkerSize',12,'Color',[128/256,128/256,128/256])
hold on;
plot(1:10,data_ITA.elast,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,elast_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('C-Y Elasticity','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('baseline model','homogenous uncertainty shock','heterogeneous uncertainty shock', 'data','Location','Northeast' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD15_d');
movefile('figureD15_d.pdf',dir_fig);

