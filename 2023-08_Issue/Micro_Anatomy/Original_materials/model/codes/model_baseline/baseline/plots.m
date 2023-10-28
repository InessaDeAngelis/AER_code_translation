% Creates figures

jj = 1;

% aggregate shock

figure(jj)
plot(0:9,Y_PI_ag(1:10),'-mo','LineWidth',5,'Color',[255/256,69/256,0/256]) 
hold on;
plot(0:9,Y_FF_ag(1:10),'-mo','LineWidth',5,'Color',[128/256,128/256,128/256]) 
hold off;
grid on;
ylabel('Aggregate Y','FontSize',ftsize,'interpreter','latex')
xlabel('t','FontSize',ftsize,'interpreter','latex')
legend('PI-view crisis','CT-view crisis', 'data','Location','Northeast' );
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0.8 1.05]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print( gcf, '-dpdf', '-r300', 'figureD2_a');
movefile('figureD2_a.pdf',dir_fig);

jj = 1 + jj;

figure(jj)
plot(0:9,par.kappa*ones(10,1),'-mo','LineWidth',5,'Color',[255/256,69/256,0/256]) 
hold on;
plot(0:9,par.kappa_mat(1:10),'-mo','LineWidth',5,'Color',[128/256,128/256,128/256]) 
hold off;
grid on;
ylabel('Borrowing constraint','FontSize',ftsize,'interpreter','latex')
xlabel('t','FontSize',ftsize,'interpreter','latex')
legend('PI-view crisis','CT-view crisis', 'data','Location','Southeast' );
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0.05 0.3]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD2_b');
movefile('figureD2_b.pdf',dir_fig);

% elasticity

jj = jj + 1;

figure(jj)
plot(1:10,elast_PI_plot,'-mo','LineWidth',5,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,data_ITA.elast,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,elast_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('C-Y Elasticity','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('model', 'data','Location','Southwest' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figure5_a_figure7_a');
movefile('figure5_a_figure7_a.pdf',dir_fig);

jj = jj + 1;

figure(jj)
plot(1:10,elast_FF_plot,'-mo','LineWidth',5,'Color',[128/256,128/256,128/256])
hold on;
plot(1:10,data_ITA.elast,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,elast_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('C-Y Elasticity','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('model','data','Location','Southwest' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figure7_b_figureD15_a');
movefile('figure7_b_figureD15_a.pdf',dir_fig);

% MPC

jj = jj + 1;

figure(jj)
plot(1:10,mpc_PI_plot,'-mo','LineWidth',5,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,data_ITA.MPC,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,mpc_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('MPC','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('model','data','Location','Southwest' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD8_b');
movefile('figureD8_b.pdf',dir_fig);

% theoretical elasticities for PI-view

jj = 1 + jj;

figure(jj)
plot(1:10,elast_PI_plot,'-mo','LineWidth',5,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,mean_d_plot','D','LineWidth',3,'MarkerSize',12,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,data_ITA.elast,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,elast_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('C-Y Elasticity','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('baseline','theoretical', 'data','Location','Northwest' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);

grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD8_a');
movefile('figureD8_a.pdf',dir_fig);
