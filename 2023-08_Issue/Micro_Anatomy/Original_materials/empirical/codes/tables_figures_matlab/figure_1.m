%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Guntin, Ottonello and Perez (2022)
% Code replicates Figure 1
% data source: WDI World Bank and Barro and Ursua  (2008)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

start_wdi   = 1960;
end_wdi     = 2018;
dates_wdi   = (start_wdi:1:end_wdi);

bblue     = [0/255,76/255,153/255];

%% Euro

% Dates
t_crisis_start_euro = 2008;
t_crisis_end_euro   = 2015;
dates_crisis_euro   = (t_crisis_start_euro:1:t_crisis_end_euro);
t_crisis_euro       = size(dates_crisis_euro,2);

i_crisis_start_euro = find(dates_wdi ==t_crisis_start_euro,1,'first');
i_crisis_end_euro   = find(dates_wdi ==t_crisis_end_euro,1,'first');

dates_euro          = dates_wdi(i_crisis_start_euro:i_crisis_end_euro);

% Data 
data_greece         = xlsread('../../input/aggregate/WB_GDP_C.xls','wdi_greece');
data_euro_greece    = data_greece(2:end,i_crisis_start_euro:i_crisis_end_euro)./repmat(data_greece(2:end,i_crisis_start_euro),1,t_crisis_euro)*100;

data_ireland        = xlsread('../../input/aggregate/WB_GDP_C.xls','wdi_ireland');
data_euro_ireland   = data_ireland(2:end,i_crisis_start_euro:i_crisis_end_euro)./repmat(data_ireland(2:end,i_crisis_start_euro),1,t_crisis_euro)*100;

data_portugal       = xlsread('../../input/aggregate/WB_GDP_C.xls','wdi_portugal');
data_euro_portugal  = data_portugal(2:end,i_crisis_start_euro:i_crisis_end_euro)./repmat(data_portugal(2:end,i_crisis_start_euro),1,t_crisis_euro)*100;

data_spain          = xlsread('../../input/aggregate/WB_GDP_C.xls','wdi_spain');
data_euro_spain     = data_spain(2:end,i_crisis_start_euro:i_crisis_end_euro)./repmat(data_spain(2:end,i_crisis_start_euro),1,t_crisis_euro)*100;

data_italy          = xlsread('../../input/aggregate/WB_GDP_C.xls','wdi_italy');
data_euro_italy     = data_italy(2:end,i_crisis_start_euro:i_crisis_end_euro)./repmat(data_italy(2:end,i_crisis_start_euro),1,t_crisis_euro)*100;

data_euro           = (data_euro_greece...
                        +data_euro_ireland...
                        +data_euro_portugal...
                        +data_euro_spain...
                        +data_euro_italy...
                        )/5;

% Plot

f1=figure;
dates = dates_euro;
data1 = data_euro(2,:);
data2 = data_euro(1,:);
mind1  = min(data1)-0.2*(max(data1)-min(data1));
maxd1  = max(data1)+0.2*(max(data1)-min(data1));
mind2  = min(data2)-0.2*(max(data2)-min(data2));
maxd2  = max(data2)+0.2*(max(data2)-min(data2));
axis([dates(1), dates(end), min([mind1,mind2]), max([maxd1,maxd2])])
xticks(dates(1):2:dates(end));
hold on 
plot (dates,data1,'color',bblue,'linewidth', 6)
plot (dates,data2,'linestyle','--','color','k','linewidth', 6)
box on
set(gca,'fontsize',24)
hold off
box on
grid on
hold off

set(gcf,'color','w')
set(gcf,'PaperPositionMode', 'auto','Position',[0, 0, 650, 450])
fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3)  fig_pos(4)];
print( gcf, '-dpdf', '-r300', '../../output/figure1_a');
exportgraphics(gcf,'../../output/figure1_a.pdf','Resolution',300)


%% EMs

data_EM = xlsread('../../input/aggregate/WB_GDP_C.xls','average_EMs');

t_crisis_start_EM = 0;
t_crisis_end_EM   = 2;

dates_crisis_EM   = (t_crisis_start_EM:1:t_crisis_end_EM);
t_crisis_EM       = size(dates_crisis_EM,2);

f1=figure;
dates = dates_crisis_EM;
data1 = data_EM(1:size(dates,2),3);
data2 = data_EM(1:size(dates,2),2);
mind1  = min(data1)-0.2*(max(data1)-min(data1));
maxd1  = max(data1)+0.2*(max(data1)-min(data1));
mind2  = min(data2)-0.2*(max(data2)-min(data2));
maxd2  = max(data2)+0.2*(max(data2)-min(data2));
axis([dates(1), dates(end), min([mind1,mind2]), max([maxd1,maxd2])])
xticks(dates(1):1:dates(end));
hold on 
plot (dates,data1,'color',bblue,'linewidth', 6)
plot (dates,data2,'linestyle','--','color','k','linewidth', 6)
set(gca,'fontsize', 24,'XTickLabel',{'t=0 (Peak)','t=1','t=2'})
box on
hold off
box on
grid on
hold off

l=legend('Consumption','GDP');
set(l, 'Location', 'North','FontSize',30)
set(l,'Box','off')
set([l], ...
    'Interpreter','latex');

set(gcf,'color','w')
set(gcf,'PaperPositionMode', 'auto','Position',[0, 0, 650, 450])
fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3)  fig_pos(4)];
print( gcf, '-dpdf', '-r300', '../../output/figure1_b');
exportgraphics(gcf,'../../output/figure1_b.pdf','Resolution',300)

%% Great Depression

data_GD = xlsread('../../input/aggregate/Barro_Ursua_2012ARE_data.xlsx','average_GD');

t_crisis_start_GD = 1929;
t_crisis_end_GD   = 1934;

dates_crisis_GD   = (t_crisis_start_GD:1:t_crisis_end_GD);
t_crisis_GD       = size(dates_crisis_GD,2);


f1=figure;
dates = dates_crisis_GD;
data1 = data_GD(1:size(dates,2),3);
data2 = data_GD(1:size(dates,2),2);
mind1  = min(data1)-0.2*(max(data1)-min(data1));
maxd1  = max(data1)+0.2*(max(data1)-min(data1));
mind2  = min(data2)-0.2*(max(data2)-min(data2));
maxd2  = max(data2)+0.2*(max(data2)-min(data2));
axis([dates(1), dates(end), min([mind1,mind2]), max([maxd1,maxd2])])
xticks(dates(1):2:dates(end));
hold on 
plot (dates,data1,'color',bblue,'linewidth', 6)
plot (dates,data2,'linestyle','--','color','k','linewidth', 6)
box on
set(gca,'fontsize',24)
hold off
box on
grid on
hold off

set(gcf,'color','w')
set(gcf,'PaperPositionMode', 'auto','Position',[0, 0, 650, 450])
fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) - 1.102  fig_pos(4)];
print( gcf, '-dpdf', '-r300', '../../output/figure1_c');
exportgraphics(gcf,'../../output/figure1_c.pdf','Resolution',300)
