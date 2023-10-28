%% plots for simulated episode

% load data

data_Y_ITA       = readtable('../../../input/dataY_ITA.xls'); % GDP path
data_ITA         = readtable('../../../input/data_ITA.xls');
deccc            = 1:10;
data_smooth      = [deccc',data_ITA.elast];
elast_data_ita_s =lowess(data_smooth,1);

import = fullfile('../../../input/', 'baseline_results.mat');
load(import);

% deciles

nmu_cum = cumsum(nmu);
elast_PI_plot = interp1(nmu_cum(8:23),elast_PI(2,8:23),0.05:.1:.95,'linear','extrap');
elast_PI_si_plot = interp1(nmu_cum(8:23),elast_PI_si(6,8:23),0.05:.1:.95,'linear','extrap');

% plots

jj = 0;

jj = 1 + jj;

figure(jj)
plot(2006:2006+19,[Y_mat_PI(1:9);NaN*ones(11,1)],'-k','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold on;
plot(2006:2006+19,[data_Y_ITA.y(12:20);NaN*ones(11,1)],'*','LineWidth',3,'MarkerSize',7,'Color',[10/256,70/256,120/256]) 
hold on;
plot(2006:2006+19,[ones(9,1);NaN*ones(11,1)],'-.','LineWidth',1,'Color',[100/256,100/256,100/256])
hold off;
grid on;
ylabel('Aggregate Y','FontSize',ftsize,'interpreter','latex')
xlabel('year','FontSize',ftsize,'interpreter','latex')
legend('model','data','Location','Southwest' );
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0.75 1.05]);
grid on;

jj = jj + 1;

figure(jj)
plot(1:10,elast_PI_plot,'-mo','LineWidth',5,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,elast_PI_si_plot,'D','LineWidth',3,'MarkerSize',12,'Color',[255/256,69/256,0/256])
hold on;
plot(1:10,data_ITA.elast,'o','LineWidth',3,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,elast_data_ita_s(:,3),'--','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold off;
grid on;
ylabel('C-Y Elasticity','FontSize',ftsize,'interpreter','latex')
xlabel('deciles of income','FontSize',ftsize,'interpreter','latex')
legend('baseline','simulated', 'data','Location','Southwest' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([0 2.5]);
grid on;

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];  
print( gcf, '-dpdf', '-r300', 'figureD9');
movefile('figureD9.pdf',dir_fig);

