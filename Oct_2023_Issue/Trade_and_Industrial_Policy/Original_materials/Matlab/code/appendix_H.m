clear;
clc

% NS ~ [N,S], where 
% N is the number of countries 
% S is the number of industries
NS = {[2,10]; [5,10]; [20,10]};
Case_ID = {'2x10'; '5x10'; '20x10'};

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

for c = 1:3
    
Output = zeros(2,50);
RunTime = zeros(2,50);
iter = 1;

while iter <= 50

display(iter)
NS_temp = NS{c};
N=NS_temp(1); S=NS_temp(2);

ii = repmat(eye(N,N),[1 1 S]);
lambda_jik3D = zeros(N,N,S);
lambda_jik3D(ii==1) = 0.75;
lambda_jik3D(ii==0) = 0.25/(N-1);

rng(150+iter)
mu = rand(1,1,S); mu_k3D = repmat(mu, [N N 1]); 
alpha = rand(1,1,S); alpha_k3D = repmat(alpha, [N N 1]); 
sigma_k3D = 1 + alpha_k3D./mu_k3D; 
e_ik3D = (1/S)*ones(N,N,S);
Yi3D = 100*ones(N,N,S);   tjik_3D = zeros(N,N,S);
Ri3D=repmat(sum(sum(lambda_jik3D.*e_ik3D.*permute(Yi3D,[2 1 3])./(1+tjik_3D),2),3), [1 N S]) ;
X = lambda_jik3D .* e_ik3D .* permute(Yi3D,  [2 1 3]);
rik3D = repmat(sum(X,2), [1 N 1])./repmat(sum(sum(X,2),3), [1 N S]);
        
country_id = 1;

T0=[ones(N,1); ones(N,1); ones(N*S,1); 1*ones((N-1)*S,1); 1.5*ones((N-1)*S,1)];
options = optimset('Display','off','MaxFunEvals',inf,'MaxIter',1000,'TolFun',1e-10,'TolX',1e-10);


target = @(X) First_Best_FE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, country_id, 1);

tic
X_sol=fsolve(target,T0, options);
RunTime(2,iter) = toc;

Gains_theory = Welfare_Gains_FE(X_sol, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, country_id);

%-----------------------------------------------------------------%
%                        MPEC
%-----------------------------------------------------------------%
LB=[0.25*ones(N,1); 0.25*ones(N,1); 0.25*ones(N*S,1); 0.1*ones((N-1)*S,1); 0.1*ones((N-1)*S,1)];
UB=[4*ones(N,1); 4*ones(N,1); 4*ones(N*S,1);  10*ones((N-1)*S,1); 10*ones((N-1)*S,1)];

T0=[ones(N,1); ones(N,1); ones(N*S,1); 1*ones((N-1)*S,1); 1.5*ones((N-1)*S,1)];
target = @(X) Obj_MPEC_FE(X, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, country_id);
constraint = @(X) Const_MPEC_FE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, country_id);

options = optimoptions(@fmincon,'Display','off','MaxFunEvals',inf,'MaxIter',1000,'TolFun',1e-8,'TolX',1e-8, 'TolCon', 1e-8);
tic
[X_MPEC, W_MPEC]=fmincon(target,T0,[],[],[],[],LB,UB,constraint,options);
RunTime(1,iter) = toc;

Gains_fmincon = Welfare_Gains_FE(X_MPEC, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, country_id);
Output(:,iter) = [Gains_fmincon; Gains_theory];

iter = iter + 1;

end

T=table(Output(1,:)', Output(2,:)', RunTime(1,:)' , RunTime(2,:)', ...
    'VariableNames', {'dW_MPEC', 'dW_Theory', 'RunTime_MPEC', 'RunTime_Theory'});
  writetable(T,['../Stata/data/internally_generated/appendixH_simulation_',Case_ID{c},'_s.csv'], 'Delimiter',',')  
  
end

 
          
%--------------------------------------------------------------------------------%    
    %%                       FUNCTIONS
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

%---- construct 3D cubes for change in taxes ---------------
 tjik = abs(X(2*N+N*S+1:2*N+N*S+(N-1)*S));
 tjik_temp = 1 + tjik_3D_app; tjik_temp([1:id-1 id+1:N],id,:)=reshape(tjik,N-1,1,S);
 tjik_3D = repmat(eye(N), [1 1 S]) + tjik_temp.*repmat(1-eye(N), [1 1 S]) - 1 ;
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);
 

 xjik=abs(X(2*N+N*S+(N-1)*S+1:end));
 xjik_3D=ones(N,N,S); 
 xjik_3D(id,[1:id-1 id+1:N],:)=reshape(xjik,1,N-1,S);
 xjik_h3D = xjik_3D; xjik_3D=xjik_3D-1 ;
 

%sik_3D = zeros(N,N,S); sik_h3D= 1 + sik_3D ; 
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
ERR1_3D = sum(AUX3,2)-AUX4(:,1,:);
ERR1 = reshape(ERR1_3D,N*S,1); 

% replace one excess equation with normalization,w^=w'/w=1, where w=sum_i(wi'*Li)/sum(wi*Li)
ERR1(N*S,1) = sum(Ri3D(:,1,1).*(wi_h-1));  
% ------------------------------------------------------------------
%        Total Income = Total Sales 
% ------------------------------------------------------------------
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = sum(sum(R_M,3),1)' + sum(sum(R_X,3),2)+ (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);
% ------------------------------------------------------------------
ERR3_3D=sum(rik_h3D.*rik3D,3);
ERR3=100*(ERR3_3D(:,1)-1); 

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
 
%  t_bar = ones(N,N,S); t_bar(2,1,:) = tjik_h3D(2,1,1);
%  tjik_h3D./t_bar;
%  xjik_h3D.*permute(t_bar, [2 1 3]);
 
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
%           Total Income = Total Sales
% --------------------------a----------------------------------------
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = sum(sum(R_M,3),1)' + sum(sum(R_X,3),2)+ (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);
% ------------------------------------------------------------------
%               Optimal Import Tax Formula: Theorem 1
% ------------------------------------------------------------------

%----------------- Main Specification + account for cross-effects --------------------
    if case_id == 1
    rjik_3D = AUX3./repmat(sum(AUX3,2), [1 N 1]); 
    AUX5 = mu_k3D ./(1 + mu_k3D);
    AUX6 = repmat(sum(  - AUX5.*rjik_3D.*(1 + (sigma_k3D-1).*(1-AUX2)),2),[1 N 1]) ...
            - ( - AUX5.* rjik_3D.*(1 + (sigma_k3D-1).*(1-AUX2)));
    delta = permute(rik_h3D.*rik3D.*wi_h.*Ri3D, [2 1 3]) ./(rik_h3D.*rik3D.*wi_h.*Ri3D)  ;
    Adjust = permute(AUX5.*rjik_3D.*(sigma_k3D-1).*(1-AUX2), [2 1 3]); 
    omega = -AUX5.*(rjik_3D - delta.*Adjust)./(1 + AUX6);
    % --------------------------------------------------
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
ERR5=100*(ERR5_3D(:,1)-1); 

ceq= [ERR1' ERR2' ERR3' ERR4' ERR5'];

end
