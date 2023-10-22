clear;
clc

% ------------------------------------------------------------------
%        Description of Inputs
% ------------------------------------------------------------------
%   N: number of countries;  S: umber of industries 
%   Yi3D: national expenditure ~ national income
%   Ri3D: national wage revneues ~ sales net of tariffs  
%   e_ik3D: industry-level expenditure share (C-D weight)
%   lambda_jik: within-industry expenditure share
%   mu: industry-level scale elasticity
%   sigma: industry-level CES parameter (sigma-1 ~ trade elasticity)
%   tjik_3D_app: applied tariff
% ------------------------------------------------------------------
N_total = 44; home_id = 2;

        
 for country_id=[8 21 26 43]
        clearvars -except country_id Gains_from_policy N_total home_id
        AggC = [ones(1,N_total); zeros(1,N_total)];
        AggC(2,country_id)=1; AggC(1,country_id)=0;
        
        f_Read_Raw_Data_T4
        f_Balance_Data_RE

        [~,a]=sort(mu_k3D(1,1,:),'Ascend');
        [~,a]=sort(a);  a = repmat(a-8,N,N,1);
        j = find([8 21 26 43]==country_id);
        
    for i=1:11
        
        mu_k3D_new = max(0, mu_k3D + 0.01*(i-1)*a); 
        if j==1 
        Gains_from_policy(i,1) = var(log(1+mu_k3D_new(1,1,:)));
        end

        lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
        Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); Ri3D=repmat(sum(sum(Xjik_3D./((1+mu_k3D_new).*(1+tjik_3D)),2),3), [ 1 N S]) ;
        e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);

T0=[ones(N,1); ones(N,1); 1*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
target = @(X) f_First_Best_RE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D_new, tjik_3D, home_id, 0);
options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',inf,'TolFun',1e-12,'TolX',1e-16, 'algorithm','levenberg-marquardt');
X_sol=fsolve(target,T0, options);

Gains_from_policy(i,j+1) = f_Welfare_Gains_RE(X_sol, N , S, e_ik3D, sigma_k3D, mu_k3D_new, lambda_jik3D, tjik_3D, home_id, 1); 


       sigma_k3D_new = 1 + (1 - 0.08*(i-1))*(sigma_k3D-1); 
       Ri3D=repmat(sum(sum(Xjik_3D./((1+mu_k3D).*(1+tjik_3D)),2),3), [ 1 N S]) ;
        if j==1 
        Gains_from_policy(i,6) = mean(1./(sigma_k3D_new(:)-1));
        end
       
T0=[ones(N,1); ones(N,1); 1*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
target = @(X) f_First_Best_RE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D_new, lambda_jik3D, mu_k3D, tjik_3D, home_id, 0);
options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',inf,'TolFun',1e-12,'TolX',1e-16, 'algorithm','levenberg-marquardt');
X_sol=fsolve(target,T0, options);

Gains_from_policy(i,6+j) = f_Welfare_Gains_RE(X_sol, N , S, e_ik3D, sigma_k3D_new, mu_k3D, lambda_jik3D, tjik_3D, home_id, 1);

    end

 end

%--------------------------------------------------------------------------------------
%                               Print Output
%--------------------------------------------------------------------------------------  

COV = Gains_from_policy(:,1);
    line(COV, Gains_from_policy(:,2),'Color','[0 0.4470 0.7410]','LineWidth',4, 'linestyle','-') 
    line(COV, Gains_from_policy(:,3),'Color','[0.8500 0.3250 0.0980]','LineWidth',4, 'linestyle','--')
    line(COV, Gains_from_policy(:,4),'Color','[0.9290 0.6940 0.1250]','LineWidth',4)
    line(COV, Gains_from_policy(:,5),'Color','[0.4660 0.6740 0.1880]','LineWidth',4, 'linestyle','--')
    xl = xline(COV(1),'--','\color{black} Estimated', 'interpreter','tex', 'FontSize',12, 'LineWidth',1.5, 'Color','[0.4 0.4 0.4]');
    xl.LabelVerticalAlignment = 'middle';
    xl.LabelHorizontalAlignment = 'center';
    xlabel('$\textrm{Var} [\log \mu ] \ \sim \textrm{ Variance of Scale Elasticities}$','Interpreter','latex','FontSize',16);
    ylabel('\% Gains from 1st-best policy','Interpreter','latex','FontSize',16);
    axis fill
    legend({'China','Indonesia','Korea','United States'}, ...
            'Location','best', 'FontSize',14, 'interpreter','latex');
    legend boxoff 
    print -depsc2 'output/Figure_Z1A.eps'
    
clf
% -------------------------------------------------------------------------------------
AVG = Gains_from_policy(:,6);
    line(AVG, Gains_from_policy(:,7),'Color','[0 0.4470 0.7410]','LineWidth',4, 'linestyle','-') 
    line(AVG, Gains_from_policy(:,8),'Color','[0.8500 0.3250 0.0980]','LineWidth',4, 'linestyle','--')
    line(AVG, Gains_from_policy(:,9),'Color','[0.9290 0.6940 0.1250]','LineWidth',4)
    line(AVG, Gains_from_policy(:,10),'Color','[0.4660 0.6740 0.1880]','LineWidth',4, 'linestyle','--')
    xl = xline(AVG(1),'--', '\color{black} Estimated', 'interpreter','tex', 'FontSize',12, 'LineWidth',1.5, 'Color','[0.4 0.4 0.4]');
    xl.LabelVerticalAlignment = 'middle';
    xl.LabelHorizontalAlignment = 'center';
    xlabel('$\textrm{E} [\frac{1}{\sigma-1}] \ \sim \textrm{ Avg. of Inverse Trade Elasticity}$','Interpreter','latex','FontSize',16);
    ylabel('\% Gains from 1st-best policy','Interpreter','latex','FontSize',16);
    axis fill
    legend({'China','Indonesia','Korea','United States'}, ...
            'Location','best', 'FontSize',14, 'interpreter','latex');
    legend boxoff 
    print -depsc2 'output/Figure_Z1B.eps'
    
   close all
 %--------------------------------------------------------------------------------------


