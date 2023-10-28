%% Figures of shock with heterogeneity of aggregate income loadings

% interpolate deciles on grid

nmu_cum = cumsum(nmu);
elast_PI_plot = interp1(nmu_cum(8:23),elast_PI(2,8:23),0.05:.1:.95,'linear','extrap');
elast_FF_plot = interp1(nmu_cum(8:23),elast_FF(2,8:23),0.05:.1:.95,'linear','extrap');
elast_PI_Yhet_plot   = interp1(nmu_cum(8:23),elast_PI_Yhet(2,8:23),0.05:.1:.95,'linear','extrap');
elast_FF_Yhet_plot   = interp1(nmu_cum(8:23),elast_FF_Yhet(2,8:23),0.05:.1:.95,'linear','extrap');
dY_PI_het_plot       = interp1(nmu_cum(8:23),dY_PI_het(2,8:23),0.05:.1:.95,'linear','extrap');


jj = 0;

% data and model simulation

jj = jj + 1;

figure(jj)
plot(1:10,dY_PI_het_plot,'-mo','LineWidth',5,'Color',[128/256,20/256,0/256]) 
hold on;
plot(1:10,data_ITA.dy(1:10),'o','LineWidth',3,'Color',[0/256,0/256,0/256]) 
hold on;
plot(1:10,dy_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,0/256,0/256]) 
hold on;
plot(1:10,zeros(10,1),'--','LineWidth',2,'Color',[0/256,0/256,0/256])
hold off;
grid on;
xlabel('income deciles','FontSize',ftsize,'interpreter','latex')
legend('model','data','Location','Southwest' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([-.4 .1]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD12_b');
movefile('figureD12_b.pdf',dir_fig);

% PI-view

jj = jj + 1;

figure(jj)
plot(1:10,elast_PI_plot,'-mo','LineWidth',5,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,elast_PI_Yhet_plot,'kD','LineWidth',3,'MarkerSize',12,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,data_ITA.elast,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,elast_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('C-Y Elasticity','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('baseline model','model w. het. loadings','data','Location','Southwest' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figure5_b');
movefile('figure5_b.pdf',dir_fig);

% CT-view

jj = jj + 1;

figure(jj)
plot(1:10,elast_FF_plot,'-mo','LineWidth',5,'Color',[128/256,128/256,128/256])
hold on;
plot(1:10,elast_FF_Yhet_plot,'kD','LineWidth',3,'MarkerSize',12,'Color',[128/256,128/256,128/256])
hold on;
plot(1:10,data_ITA.elast,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,elast_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('C-Y Elasticity','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('baseline model','model w. het. loadings','data','Location','Southwest' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD15_b');
movefile('figureD15_b.pdf',dir_fig);