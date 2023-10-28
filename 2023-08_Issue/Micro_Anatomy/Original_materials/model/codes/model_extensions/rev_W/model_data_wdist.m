%% Wealth model and data

% import data

data_ITA = readtable('../../../input/data_ITA.xls');
deccc = 1:10;
s_w_data= data_ITA.s_w;

%% Compute wealth shares using ergodic distribution

% Ergodic distribution
[n, ~]     = eigs(P',1,'lm');
n          = n/sum(n);  
n          = max(n, 0);

dist = reshape(n,[Grid.nalin Grid.nmulin]);
na = sum(dist,2); 
nmu = sum(dist,1)';

%Compute CDF on assets/income

Gassets = zeros(Grid.nalin,1);
Gy = zeros(Grid.nmulin,1);
index_a = zeros(100,1);
index_y = zeros(100,1);
perc = linspace(1,100,100)';

for i=1:Grid.nalin
    Gassets(i)  = sum(na(1:i));
end

for i=1:Grid.nmulin
    Gy(i)  = sum(nmu(1:i));
end

for i=1:100
    [~, index_a(i)]   = min( abs( 100*Gassets   - perc(i) ) );
    [~, index_y(i)]   = min( abs( 100*Gy  - perc(i) ) );
end

% wealth shares

s_w      = zeros(10,1);

a_integ = agridlin.*na; % wealth
atotal = sum(a_integ);

for hh = 1:length(s_w)
s_w(hh,1)      = sum(a_integ(1:index_a(hh*10)))/atotal;
end

s_w(2:end) = s_w(2:end) - s_w(1:end-1);

%% plots

jj = jj + 1;

figure(jj)
plot(1:10,s_w,'k-','LineWidth',5,'Color',[0/256,51/256,102/256]) 
hold on;
plot(1:10,s_w_data,'o','LineWidth',2,'MarkerSize',12,'Color',[0/256,51/256,102/256]) 
grid on;
ylabel('wealth share','FontSize',ftsize,'interpreter','latex')
xlabel('wealth decile','FontSize',ftsize,'interpreter','latex')
legend('model','data','Location','Northwest' );
xlim([1 10]);
set(findall(gcf,'-property','FontSize'),'FontSize',18);
ylim([-0.1 .7]);

fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)]; 
print( gcf, '-dpdf', '-r300', 'figureD4_a');
movefile('figureD4_a.pdf',dir_fig);

