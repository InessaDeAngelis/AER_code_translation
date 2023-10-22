clear;
clc

% pre-define matrixes to save output
Gains_deep_agreement = zeros(44,2); 
Gains_unilateral = zeros(44,2); 
N_total = 44; AggC=eye(N_total);

        f_Read_Raw_Data_T5
        f_Balance_Data_FE

    lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
    Ri3D=repmat(sum(sum(Xjik_3D./(1+tjik_3D),2),3), [ 1 N S]) ;
    rik3D = repmat(sum(Xjik_3D./(1+tjik_3D),2), [1 N 1])./Ri3D;
    Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
    e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
        
    load output/temp/gains_from_policy_t5;
  
    %RCA=sum((permute(e_ik3D(1,:,1:15),[2 1 3])-rik3D(:,1,1:15)).*(1./mu_k3D(:,1,1:15)),3);
    %scatter(RCA, Gains_unilateral(:,1))
    
    Trade = sum(lambda_jik3D.*e_ik3D,3); Trade= 1 - Trade(eye(N)==1);
    %scatter(Trade([1:26 28:end],:), mean(Gains_unilateral([1:26 28:end],:),2))
    
    [num, txt, raw] = xlsread('Country_List.xlsx');
    iso = txt([1:26 29:end], 1);
    
    x = Trade([1:26 29:end]);
    y = mean(Gains_unilateral([1:26 29:end],:),2);
    
    id_A = y<0; id_B = y>=0;
    
plot(x(id_A), y(id_A),'o','MarkerEdgeColor','red','MarkerFaceColor',[1 .6 .6])
text(x(id_A), y(id_A),iso(id_A),'VerticalAlignment','top','HorizontalAlignment','left')
hold on
plot(x(id_B), y(id_B),'o','MarkerEdgeColor','#3182bd','MarkerFaceColor','#9ecae1')
text(x(id_B), y(id_B),iso(id_B),'VerticalAlignment','top','HorizontalAlignment','left', 'color', '#bdbdbd')
xlabel('\textbf{Trade-to-GDP}','interpreter','latex','FontSize',16);
ylabel( '\% $\Delta W_{i}$ \textbf{unilateral scale correction}','interpreter','latex','FontSize',16);
yline(0,'--')
exportgraphics(gcf,'output/Figure_X1.eps','BackgroundColor','none','ContentType','vector')

close all
%delete filename output/temp/Gains_from_policy_t5;