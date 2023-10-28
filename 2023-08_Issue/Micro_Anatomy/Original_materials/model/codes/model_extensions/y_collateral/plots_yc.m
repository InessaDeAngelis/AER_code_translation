%% plots with income-based credit constraints

% elasticity baseline

data_ITA = readtable('../../../input/data_ITA.xls');
deccc = 1:10;
data_smooth= [deccc',data_ITA.elast];
elast_data_ita_s=lowess(data_smooth,1);

% interpolate deciles

nmu_cum = cumsum(nmu);
elast_PI_plot = interp1(nmu_cum(8:23),elast_PI(2,8:23),0.05:.1:.95,'linear','extrap');
elast_FF_plot = interp1(nmu_cum(8:23),elast_FF(2,8:23),0.05:.1:.95,'linear','extrap');
elast_PI_yc_plot = interp1(nmu_cum(8:23),elast_PI_yc(2,8:23),0.05:.1:.95,'linear','extrap');
elast_FF_yc_plot = interp1(nmu_cum(8:23),elast_FF_yc(2,8:23),0.05:.1:.95,'linear','extrap');


% plot

jj = 1;

figure(jj)
plot(1:10,elast_PI_plot,'-mo','LineWidth',5,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,elast_PI_yc_plot,'kD','LineWidth',3,'MarkerSize',12,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,data_ITA.elast,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,elast_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('C-Y Elasticity','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('baseline model','model w. income collateral','data','Location','Southwest' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD17_a');
movefile('figureD17_a.pdf',dir_fig);

jj = jj + 1;

figure(jj)
plot(1:10,elast_FF_plot,'-mo','LineWidth',5,'Color',[128/256,128/256,128/256])
hold on;
plot(1:10,elast_FF_yc_plot,'kD','LineWidth',3,'MarkerSize',12,'Color',[128/256,128/256,128/256])
hold on;
plot(1:10,data_ITA.elast,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,elast_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('C-Y Elasticity','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('baseline model','model w. income collateral','data','Location','Southwest' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD17_b');
movefile('figureD17_b.pdf',dir_fig);

