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
%   mu: industry-level markup
%   sigma: industry-level CES parameter (sigma-1 ~ trade elasticity)
%   tjik_3D_app: applied tariff
% ------------------------------------------------------------------

N=2; % number of countries
S=2; % number of industries

% pre-define ouput matrix
Output=zeros(3,10);

for i=1:19
rho = 1 + (i-1)*0.5 ; %relative country size
delta = 1; % relative scetor size
lambda_jik = [ 0.6  0.25/rho ; ...
               0.4  1-0.25/rho]; 

   
lambda_jik3D = repmat(lambda_jik, [1 1 S]);

lambda_jik3D(:,:,2) = [ 0.75  0.4/rho ; ...
                        0.25  1-0.4/rho];  
                                    
mu = 0.25*[1:S]/S; mu_k3D = repmat(reshape(mu,1,1,S), [N N 1]); %sector 2 is high markup
%sigma_k3D = 2*ones(N,N,S);  e_ik3D = (1/S)*ones(N,N,S);
sigma_k3D = 1 + 1./mu_k3D;  e_ik3D = (1/S)*ones(N,N,S);

Yi3D = repmat([100; rho*100], [1 N S]);   tjik_3D = zeros(N,N,S);
Ri3D=repmat(sum(sum(lambda_jik3D.*e_ik3D.*permute(Yi3D,[2 1 3])./(1+tjik_3D),2),3), [1 N S]) ;
X = lambda_jik3D .* e_ik3D .* permute(Yi3D,  [2 1 3]);
rik3D = repmat(sum(X,2), [1 N 1])./repmat(sum(sum(X,2),3), [1 N S]);
        
country_id = 1;

T0=[ones(N,1); ones(N,1); ones(N*S,1); 1*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
options = optimset('Display','off','MaxFunEvals',inf,'MaxIter',inf,'TolFun',1e-12,'TolX',1e-14);

target = @(X) First_Best_FE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, country_id, 1);
X_sol=fsolve(target,T0, options);
Gains_theory = Welfare_Gains_FE(X_sol, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, country_id);

target = @(X) First_Best_FE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, country_id, 2);
X_sol=fsolve(target,T0, options);
Gains_small_open_economy = Welfare_Gains_FE(X_sol, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, country_id);

%-----------------------------------------------------------------%
%            Obtain Exact Optimal Policy using MPEC
%-----------------------------------------------------------------%
LB=[0.25*ones(N,1); 0.25*ones(N,1); 0.25*ones(N*S,1); 0.1*ones((N-1)*S,1); 0.1*ones((N-1)*S,1)];
UB=[4*ones(N,1); 4*ones(N,1); 4*ones(N*S,1);  10*ones((N-1)*S,1); 10*ones((N-1)*S,1)];

T0=[ones(N,1); ones(N,1); ones(N*S,1); 1*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
target = @(X) Obj_MPEC_FE(X, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, country_id);
constraint = @(X) Const_MPEC_FE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, country_id);

options = optimoptions(@fmincon,'Display','iter','MaxFunEvals',inf,'MaxIter',5000,'TolFun',1e-8,'TolX',1e-8, 'TolCon', 1e-8);
[X_MPEC, W_MPEC]=fmincon(target,T0,[],[],[],[],LB,UB,constraint,options);
Gains_fmincon = Welfare_Gains_FE(X_MPEC, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, country_id);

Output(:,i) = [Gains_fmincon; Gains_theory; Gains_small_open_economy]./Gains_fmincon;

end

line([1:0.5:10]', Output(1,:),'Color','[0.5 0.5 0.5]','LineWidth',4, 'linestyle',':')
    line([1:0.5:10]', Output(2,:),'Color','[0.1 0.5 1]','LineWidth',6', 'linestyle','--')
    line([1:0.5:10]', Output(3,:),'Color','[1 0.8 0]','LineWidth',6)
    
    xlabel('\textbf{relative size of country $i$ to the RoW}','interpreter','latex','FontSize',16);
    ylabel( '\textbf{Gains from optimal policy}','interpreter','latex','FontSize',16);
    ylim([0.8 1.01]); yticks([0.9 0.95 1]);
    legend({'Actual gains (normalized to 1)', ...
            'Gains implied by approximated $\omega_{ji,k}$', ...
            'Small open economy assumption ($\omega_{ji,k}=0$)'}, 'FontSize',18, 'interpreter','latex', 'Location','southeast'); 
    legend boxoff 
    %print -dpng output/Figure_E1.png
    print -depsc2 output/Figure_E1.eps

    
%% --------------------------------------------------------------------------------%    
%                                    FUNCTIONS
%--------------------------------------------------------------------------------%   
    
function [c, ceq] = Const_MPEC_FE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D_app, id)

% ------------------------------------------------------------------
%        Description of Inputs
% ------------------------------------------------------------------
%   N: number of countries;  S: umber of industries 
%   Yi3D: national expenditure ~ national income
%   Ri3D: national wage revneues ~ sales net of tariffs  
%   e_ik3D: industry-level expenditure share (C-D weight)
%   lambda_jik: within-industry expenditure share
%   mu: industry-level markup
%   sigma: industry-level CES parameter (sigma-1 ~ trade elasticity)
%   tjik_3D_app: applied tariff
% ------------------------------------------------------------------

wi_h=abs(X(1:N));    % abs(.) is used avoid complex numbers...
Yi_h=abs(X(N+1:N+N));
rik_h = abs(X(2*N+1:2*N+N*S));
rik_h3D = repmat(reshape(rik_h,N,1,S), [1 N 1]);

% construct 3D cubes from 1D vectors
wi_h3D=repmat(wi_h,[1 N S]);
Yi_h3D=repmat(Yi_h,[1 N S]);
Yj_h3D=permute(Yi_h3D,[2 1 3]);
Yj3D=permute(Yi3D,[2 1 3]);

%---- construct 3D cubes for change in tariffs ---------------
 tjik = abs(X(2*N+N*S+1:2*N+N*S+(N-1)*S));
 tjik_temp = 1 + tjik_3D_app; tjik_temp([1:id-1 id+1:N],id,:)=reshape(tjik,N-1,1,S);
 tjik_3D = repmat(eye(N), [1 1 S]) + tjik_temp.*repmat(1-eye(N), [1 1 S]) - 1 ;
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);
 

 xjik=abs(X(2*N+N*S+(N-1)*S+1:end));
 xjik_3D=ones(N,N,S); 
 xjik_3D(id,[1:id-1 id+1:N],:)=reshape(xjik,1,N-1,S);
 xjik_h3D = xjik_3D; xjik_3D=xjik_3D-1 ;
 

%  sik_3D = zeros(N,N,S); sik_h3D= 1 + sik_3D ; 
 sik_3D = zeros(N,N,S);  sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
 sik_h3D= 1 + sik_3D ; 

% ------------------------------------------------------------------
%        Wage Income = Total Sales net of Taxes (Equation 6)
% ------------------------------------------------------------------
taujik_h3D = tjik_h3D.*xjik_h3D.*sik_h3D;
pjik_h3D = wi_h3D.*taujik_h3D.*(rik_h3D.^ (-mu_k3D));
AUX0 = lambda_jik3D.*(pjik_h3D.^(1-sigma_k3D));
AUX1 = repmat(sum(AUX0,1),[N 1 1]);
AUX2 = AUX0./AUX1;
AUX3 = AUX2.*e_ik3D.*(Yj_h3D.*Yj3D)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D));

AUX4 = rik_h3D.*rik3D.*wi_h.*Ri3D;
ERR1_3D = sum(AUX3,2)-AUX4(:,1,:); % Eq.31.a in Section 5
ERR1 = reshape(ERR1_3D,N*S,1); 
ERR1(N*S,1) = sum(Ri3D(:,1,1).*(wi_h-1));  % replace one excess equation with normalization,w^=w'/w=1, where w=sum_i(wi'*Li)/sum(wi*Li)
% ------------------------------------------------------------------
%        Total Income = Total Sales (Equation 15)
% ------------------------------------------------------------------
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = sum(sum(R_M,3),1)' + sum(sum(R_X,3),2)+ (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);
% ------------------------------------------------------------------
ERR3_3D=sum(rik_h3D.*rik3D,3);
ERR3=100*(ERR3_3D(:,1)-1); % Eq.31.b in Section 5

c=[];
ceq= [ERR1' ERR2' ERR3'];

end

function [Gains]=Obj_MPEC_FE(X, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D_app, id)

wi_h=abs(X(1:N));% Nx1, mod to avoid complex numbers...
wi_h3D=repmat(wi_h,[1 N S]); % construct 3D cubes from 1D vectors
Ei_h=abs(X(N+1:N+N));
rik_h = abs(X(2*N+1:2*N+N*S));
rik_h3D = repmat(reshape(rik_h,N,1,S), [1 N 1]);

% Construct 3D cube of Nash tariffs
 tjik = abs(X(2*N+N*S+1:2*N+N*S+(N-1)*S));
 tjik_temp = 1 + tjik_3D_app; tjik_temp([1:id-1 id+1:N],id,:)=reshape(tjik,N-1,1,S);
 tjik_3D = repmat(eye(N), [1 1 S]) + tjik_temp.*repmat(1-eye(N), [1 1 S]) - 1;
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);
 

 xjik=abs(X(2*N+N*S+(N-1)*S+1:end));
 xjik_3D=ones(N,N,S); 
 xjik_3D(id,[1:id-1 id+1:N],:)=reshape(xjik,1,N-1,S);
 xjik_h3D = xjik_3D;

%  t_bar = ones(N,N,S); t_bar(2,1,:) = tjik_h3D(2,1,2);
%  tjik_h3D./t_bar
%  xjik_h3D.*permute(t_bar, [2 1 3])
 
  sik_3D = zeros(N,N,S);  sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
  sik_h3D= 1 + sik_3D;

% Calculate the change in price indexes
taujik_h3D = tjik_h3D.*xjik_h3D.*sik_h3D;
pjik_h3D = wi_h3D.*taujik_h3D.*(rik_h3D.^(- mu_k3D));
AUX1 = lambda_jik3D.*(pjik_h3D.^(1-sigma_k3D));
Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX1,1)),3))';

% Calculate the change in welfare
Wi_h = Ei_h./Pi_h;
Gains = -100*(Wi_h(id)-1);
end

function [Gains]=Welfare_Gains_FE(X, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D_app, id)

wi_h=abs(X(1:N));% Nx1, mod to avoid complex numbers...
wi_h3D=repmat(wi_h,[1 N S]); % construct 3D cubes from 1D vectors
Ei_h=abs(X(N+1:N+N));
rik_h = abs(X(2*N+1:2*N+N*S));
rik_h3D = repmat(reshape(rik_h,N,1,S), [1 N 1]);

% Construct 3D cube of Nash tariffs
 tjik = abs(X(2*N+N*S+1:2*N+N*S+(N-1)*S));
 tjik_temp = 1 + tjik_3D_app; tjik_temp([1:id-1 id+1:N],id,:)=reshape(tjik,N-1,1,S);
 tjik_3D = repmat(eye(N), [1 1 S]) + tjik_temp.*repmat(1-eye(N), [1 1 S]) - 1;
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);
 
 xjik=abs(X(2*N+N*S+(N-1)*S+1:end));
 xjik_3D=ones(N,N,S); 
 xjik_3D(id,[1:id-1 id+1:N],:)=reshape(xjik,1,N-1,S);
 xjik_h3D = xjik_3D; 

 
 t_bar = ones(N,N,S); t_bar(2,1,:) = tjik_h3D(2,1,1);
 tjik_h3D./t_bar;
 xjik_h3D.*permute(t_bar, [2 1 3]);
 

sik_3D = zeros(N,N,S);  sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
sik_h3D= 1 + sik_3D;

     
% Calculate the change in price indexes
taujik_h3D = tjik_h3D.*xjik_h3D.*sik_h3D;
pjik_h3D = wi_h3D.*taujik_h3D.*(rik_h3D.^(- mu_k3D));
AUX1 = lambda_jik3D.*(pjik_h3D.^(1-sigma_k3D));
Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX1,1)),3))';

% Calculate the change in welfare
Wi_h = Ei_h./Pi_h;
Gains = 100*(Wi_h(id)-1);
end

function [ceq] = First_Best_FE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D_app, id, case_id)

% ------------------------------------------------------------------
%        Description of Inputs
% ------------------------------------------------------------------
%   N: number of countries;  S: umber of industries 
%   Yi3D: national expenditure ~ national income
%   Ri3D: national wage revneues ~ sales net of tariffs  
%   e_ik3D: industry-level expenditure share (C-D weight)
%   lambda_jik: within-industry expenditure share
%   mu: industry-level markup
%   sigma: industry-level CES parameter (sigma-1 ~ trade elasticity)
%   tjik_3D_app: applied tariff
% ------------------------------------------------------------------

wi_h=abs(X(1:N));    % abs(.) is used avoid complex numbers...
Yi_h=abs(X(N+1:N+N));
rik_h = abs(X(2*N+1:2*N+N*S));

% construct 3D cubes from 1D vectors
wi_h3D=repmat(wi_h,[1 N S]);
Yi_h3D=repmat(Yi_h,[1 N S]);
Yj_h3D=permute(Yi_h3D,[2 1 3]);
Yj3D=permute(Yi3D,[2 1 3]);
rik_h3D = repmat(reshape(rik_h,N,1,S), [1 N 1]);

%---- construct 3D cubes for change in taxes ---------------
 tjik = abs(X(2*N+N*S+1:2*N+N*S+(N-1)*S));
 tjik_temp = 1 + tjik_3D_app; tjik_temp([1:id-1 id+1:N],id,:)=reshape(tjik,N-1,1,S);
 tjik_3D = repmat(eye(N), [1 1 S]) + tjik_temp.*repmat(1-eye(N), [1 1 S]) - 1 ;
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);
 

 xjik=abs(X(2*N+N*S+(N-1)*S+1:end));
 xjik_3D=ones(N,N,S); 
 xjik_3D(id,[1:id-1 id+1:N],:)=reshape(xjik,1,N-1,S);
 xjik_h3D = xjik_3D; xjik_3D=xjik_3D-1 ;
 
 sik_3D = zeros(N,N,S);  sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
 sik_h3D= 1 + sik_3D; 

% ------------------------------------------------------------------
%      Wage Income = Total Sales net of Taxes and Profits
% ------------------------------------------------------------------
taujik_h3D = tjik_h3D.*xjik_h3D.*sik_h3D;
pjik_h3D = wi_h3D.*taujik_h3D.*(rik_h3D.^ (-mu_k3D));
AUX0 = lambda_jik3D.*(pjik_h3D.^(1-sigma_k3D));
AUX1 = repmat(sum(AUX0,1),[N 1 1]);
AUX2 = AUX0./AUX1;
AUX3 = AUX2.*e_ik3D.*(Yj_h3D.*Yj3D)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D));

AUX4 = rik_h3D.*rik3D.*wi_h.*Ri3D;
ERR1_3D = sum(AUX3,2)-AUX4(:,1,:); % Eq.31.a in Section 5
%TEMP = abs(rik_h3D);
ERR1 = reshape(ERR1_3D,N*S,1); %/min(TEMP(:)); 
ERR1(N*S,1) = sum(Ri3D(:,1,1).*(wi_h-1));  % replace one excess equation with normalization,w^=w'/w=1, where w=sum_i(wi'*Li)/sum(wi*Li)
%ERR1(N*S,1) = wi_h(N) - 1;
% ------------------------------------------------------------------
%        Total Income = Total Sales 
% --------------------------a----------------------------------------
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = sum(sum(R_M,3),1)' + sum(sum(R_X,3),2)+ (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);
% ------------------------------------------------------------------
%        Optimal Import Tax Formula: Theorem 1
% ------------------------------------------------------------------
    if case_id == 1
        rjik_3D = AUX3./repmat(sum(AUX3,2), [1 N 1]); 
        AUX5 = mu_k3D ./(1 + mu_k3D);
        AUX6 = repmat(sum(  - AUX5.*rjik_3D.*(1 + (sigma_k3D-1).*(1-AUX2)),2),[1 N 1]) ...
                - ( - AUX5.* rjik_3D.*(1 + (sigma_k3D-1).*(1-AUX2)));
        delta = permute(rik_h3D.*rik3D.*wi_h.*Ri3D, [2 1 3]) ./(rik_h3D.*rik3D.*wi_h.*Ri3D)  ;
        Adjust = permute(AUX5.*rjik_3D.*(sigma_k3D-1).*(1-AUX2), [2 1 3]); 
        omega = -AUX5.*(rjik_3D - delta.*Adjust)./(1 + AUX6);
 % ------------------------------------------------------------------
    else

        omega = zeros(N,N,S);

    end
    
t_pred = omega; 
ERR3 = reshape(tjik_3D([1:id-1 id+1:N],id,:) - t_pred([1:id-1 id+1:N],id,:), (N-1)*S,1) ;

% ------------------------------------------------------------------
%               Optimal Export Tax Formula: Theorem 1
% ------------------------------------------------------------------
AUX7=zeros(N,N,S);
omega_prime = permute(omega,[2 1 3]).*repmat(eye(N)==0,[1 1 S]);

for s=1:S
    AUX7(:,:,s)= omega_prime(:,:,s)* AUX2(:,:,s);
end
subsidy = AUX7./(1-AUX2);
x_pred  = (1 + 1./((sigma_k3D-1).*(1-AUX2)))./(1+subsidy); 
ERR4 = reshape(xjik_3D(id,[1:id-1 id+1:N],:) - (x_pred(id,[1:id-1 id+1:N],:) - 1), (N-1)*S,1);

% ------------------------------------------------------------------
ERR5_3D=sum(rik_h3D.*rik3D,3);
ERR5=100*(ERR5_3D(:,1)-1); % Eq.31.b in Section 5

ceq= [ERR1' ERR2' ERR3' ERR4' ERR5'];

end
