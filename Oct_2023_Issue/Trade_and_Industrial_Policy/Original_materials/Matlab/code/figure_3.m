clear;
clc

%------------------------------------------------------------
%                 Description of Variables
% -----------------------------------------------------------
%   N: number of countries;  S: umber of industries 
%   Yi3D: national expenditure ~ national income
%   Ri3D: national wage revneues ~ sales net of tariffs and profits 
%   e_ik3D: industry-level expenditure share (C-D weight)
%   lambda_jik: within-industry expenditure share
%   mu: industry-level scale elasticity
%   sigma: industry-level CES parameter (sigma-1 ~ trade elasticity)
%   tjik_3D_app: applied tariff
% ------------------------------------------------------------

%-------------------------------------------------------------------------
%-------------------------  FREE ENTRY CASE ----------------------------
%-------------------------------------------------------------------------
     N_total = 44; AggC = eye(N_total);

     f_Read_Raw_Data_T4
     f_Balance_Data_FE
       
    lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
    Ri3D=repmat(sum(sum(Xjik_3D./(1+tjik_3D),2),3), [ 1 N S]) ;
    rik3D = repmat(sum(Xjik_3D./(1+tjik_3D),2), [1 N 1])./Ri3D;
    Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
    e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
    Gains_deep_agreement = zeros(43,2);
    
options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',1000,...
            'TolFun',1e-12,'TolX',1e-16, 'algorithm','levenberg-marquardt');
target = @(X) Cooperative_FE(X, N ,S, ....
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D);
T0=[1.1*ones(N,1);  0.9*ones(N,1); 1.25*ones(N*S,1)]; 
X_sol=fsolve(target,T0, options);

Gains_deep_agreement(:,2) = Welfare_Gains_FE(X_sol, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D); 

%-------------------------------------------------------------------------
%----------------------  RESTRICTED ENTRY CASE --------------------------
%-------------------------------------------------------------------------
     clearvars -except Gains_deep_agreement
     N_total = 44; AggC = eye(N_total);
        
     f_Read_Raw_Data_T4
     f_Balance_Data_RE
        
        lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
        Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
        Ri3D=repmat(sum(sum(Xjik_3D./((1+mu_k3D).*(1+tjik_3D)),2),3), [ 1 N S]) ;
        e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
    
options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',1000,...
                'TolFun', 1e-12,'TolX',1e-16, 'algorithm','levenberg-marquardt'); 
target = @(X) Cooperative_RE(X, N ,S, ...
                    Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D);
T0=[1.1*ones(N,1);0.9*ones(N,1)]; 
X_sol=fsolve(target,T0, options);

Gains_deep_agreement(:,1) = Welfare_Gains_RE(X_sol, N , S, ...
                                e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D);

load output/temp/Gains_from_policy_t4
[num, text, raw] = xlsread('Country_List.xlsx');
countries = text(1:end-1, 1);

T=table(countries, Gains_from_policy(1:43,1), Gains_deep_agreement(:,1), ...
                    Gains_from_policy(1:43,4), Gains_deep_agreement(:,2), ...
  'VariableNames', {'iso', 'first_best_RE', 'cooperative_RE', 'first_best_FE', 'cooperative_FE'});
  writetable(T,'output/temp/output_for_stata_fig3.csv', 'Delimiter',',')  

%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~           AUXILIARY FUNCTION           ~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [ceq] = Cooperative_FE(X, N ,S, ...
                 Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D_app)

wi_h=abs(X(1:N));    % abs(.) is used avoid complex numbers...
Yi_h=abs(X(N+1:N+N));
rik_h = abs(X(2*N+1:2*N+N*S));

% construct 3D cubes from 1D vectors
wi_h3D=repmat(wi_h,[1 N S]);
Yi_h3D=repmat(Yi_h,[1 N S]);
Yj_h3D=permute(Yi_h3D,[2 1 3]);
Yj3D=permute(Yi3D,[2 1 3]);
rik_h3D = repmat(reshape(rik_h,N,1,S), [1 N 1]);

% ------------------------------------------------------------------
%        construct 3D cubes for change in taxes
% ------------------------------------------------------------------
 
 tjik_3D = tjik_3D_app; 
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);

 xjik_3D=ones(N,N,S); 
 xjik_h3D = xjik_3D; xjik_3D=xjik_3D-1 ;
 
sik_3D=(1./(1+mu_k3D)) - 1;
 sik_h3D= 1 + sik_3D; 

% ------------------------------------------------------------------
%        Wage Income = Total Sales net of Taxes and Profits
% ------------------------------------------------------------------
taujik_h3D = tjik_h3D.*xjik_h3D.*sik_h3D;
pjik_h3D = wi_h3D.*taujik_h3D.*(rik_h3D.^ (-mu_k3D));
AUX0 = lambda_jik3D.*(pjik_h3D.^(1-sigma_k3D));
AUX1 = repmat(sum(AUX0,1),[N 1 1]);
AUX2 = AUX0./AUX1;
AUX3 = AUX2.*e_ik3D.*(Yj_h3D.*Yj3D)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D));

AUX4 = rik_h3D.*rik3D.*wi_h.*Ri3D;
ERR1_3D = sum(AUX3,2)-AUX4(:,1,:);
ERR1 = reshape(ERR1_3D,N*S,1);

% replace one excess equation with normalization,w^=w'/w=1, where w=sum_i(wi'*Li)/sum(wi*Li)
ERR1(N*S,1) = sum(Ri3D(:,1,1).*(wi_h-1));  
% ------------------------------------------------------------------
%                    Total Income = Total Sales 
% -------------------------------------------------------------------
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./...
                ((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = sum(sum(R_M,3),1)' + sum(sum(R_X,3),2)+ ...
                        (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);

% ------------------------------------------------------------------
%                   Sum of Revenue Shares = 1
% ------------------------------------------------------------------
ERR5_3D=sum(rik_h3D.*rik3D,3);
ERR5=100*(ERR5_3D(:,1)-1);
% ------------------------------------------------------------------

ceq= [ERR1' ERR2' ERR5'];

end


function [Gains]=Welfare_Gains_FE(X, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D)

wi_h=abs(X(1:N));% Nx1, mod to avoid complex numbers...
wi_h3D=repmat(wi_h,[1 N S]); % construct 3D cubes from 1D vectors
Ei_h=abs(X(N+1:N+N));
rik_h = abs(X(2*N+1:2*N+N*S));
rik_h3D = repmat(reshape(rik_h,N,1,S), [1 N 1]);

% ------------------------------------------------------------------
%        construct 3D cubes for change in taxes
% ------------------------------------------------------------------   
 tjik_h3D = ones(N,N,S);
 xjik_h3D = ones(N,N,S); 

 sik_3D=(1./(1+mu_k3D)) - 1;
 sik_h3D= 1 + sik_3D;

% Calculate the change in price indexes
taujik_h3D = tjik_h3D.*xjik_h3D.*sik_h3D;
pjik_h3D = wi_h3D.*taujik_h3D.*(rik_h3D.^(- mu_k3D));
AUX1 = lambda_jik3D.*(pjik_h3D.^(1-sigma_k3D));
Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX1,1)),3))';

% Calculate the change in welfare
Wi_h = Ei_h./Pi_h;
Gains = 100*(Wi_h(1:N-1)-1);
end


function [ceq] = Cooperative_RE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D_app)

wi_h=abs(X(1:N));    % abs(.) is used avoid complex numbers...
Yi_h=abs(X(N+1:N+N));

% construct 3D cubes from 1D vectors
wi_h3D=repmat(wi_h,[1 N S]);
Yi_h3D=repmat(Yi_h,[1 N S]);
Yj_h3D=permute(Yi_h3D,[2 1 3]);
Yj3D=permute(Yi3D,[2 1 3]);

% ------------------------------------------------------------------
%            construct 3D cubes for change in taxes
% ------------------------------------------------------------------
 tjik_3D = tjik_3D_app; 
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);

 xjik_3D=ones(N,N,S); 
 xjik_h3D = xjik_3D; xjik_3D=xjik_3D-1 ;
 
sik_3D=(1./(1+mu_k3D)) - 1;
 sik_h3D= 1 + sik_3D; 
% ------------------------------------------------------------------
%        Wage Income = Total Sales net of Taxes and Profits
% ------------------------------------------------------------------
tau_h = tjik_h3D.*xjik_h3D.*sik_h3D;
AUX0 = lambda_jik3D.*((tau_h.*wi_h3D).^(1-sigma_k3D));
AUX1 = repmat(sum(AUX0,1),[N 1 1]);
AUX2 = AUX0./AUX1;
AUX3 = AUX2.*e_ik3D.*(Yj_h3D.*Yj3D)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D).*(1+mu_k3D));

ERR1 = sum(sum(AUX3,3),2) - wi_h.*Ri3D(:,1,1);

% replace one excess equation with normalization,w^=w'/w=1, where w=sum_i(wi'*Li)/sum(wi*Li)
ERR1(N,1) = sum(Ri3D(:,1,1).*(wi_h-1));  
% ------------------------------------------------------------------
%                   Total Income = Total Sales
% ------------------------------------------------------------------
Profit =  sum(sum(mu_k3D.* AUX3,3),2);
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./ ...
        ((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = Profit + sum(sum(R_M,3),1)' + sum(sum(R_X,3),2)+ ...
                    (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);
% ------------------------------------------------------------------

ceq= [ERR1' ERR2'];

end



function [Gains]= Welfare_Gains_RE(X, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D)

wi_h=abs(X(1:N));% Nx1, mod to avoid complex numbers...
wi_h3D=repmat(wi_h,[1 N S]); % construct 3D cubes from 1D vectors
Ei_h=abs(X(N+1:N+N));

% ------------------------------------------------------------------
%            construct 3D cubes for change in taxes
% ------------------------------------------------------------------
 tjik_h3D = ones(N,N,S);
 xjik_h3D = ones(N,N,S); 
 
sik_3D=(1./(1+mu_k3D)) - 1;
 sik_h3D= 1 + sik_3D; 

% Calculate the change in price indexes
tau_h = tjik_h3D.*xjik_h3D.*sik_h3D;
AUX0=((tau_h.*wi_h3D).^(1-sigma_k3D));
AUX1=lambda_jik3D.*AUX0;
Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX1,1)),3))';

% Calculate the change in welfare
Wi_h = Ei_h./Pi_h;
Gains = 100*(Wi_h(1:N-1)-1);
end
