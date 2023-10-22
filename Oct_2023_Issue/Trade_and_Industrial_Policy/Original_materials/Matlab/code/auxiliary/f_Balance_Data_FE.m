%==========================================================================
% Step 03: this file solves the DEK exercise for the zero trade deficit
%============================ READ THE DATA ===============================
% Load data from Step_01_... All variables in the loaded data are supposed to be "cubes" NxNxS: (i,j,s);
clearvars -except country_id Gains_from_policy N_total home_id Gains_deep_agreement Gains_unilateral X_sol_1st X_sol_2nd X_sol_3rd
load Input/TEMP/Step_1.mat;
%load Input/tariff_2014_TRAINS.mat

T = dlmread('AGG_T.csv', ',');
t_3D = reshape(T(:,4), S,N_total,N_total)/100;
tjik_3D = permute(t_3D,[3 2 1]);

for s=1:S        
           AUX1 = AggC*tjik_3D(:,:,s)*AggC';
           AUX2 = AggC*ones(N_total,N_total)*AggC';
           t_new(:,:,s) = AUX1./AUX2;
end
t_new(repmat(eye(N)==1, [1 1 S])) = 0; tjik_3D = t_new;

%============================== SET SHOCKS ================================
        %Xjik_3D = Xijs3D; Xjik_3D = Xjik_3D + 10*(Xjik_3D<10);
        Xjik_3D = 1 + Xijs3D;
        lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
        Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); Ri3D=repmat(sum(sum(Xjik_3D./(1+tjik_3D),2),3), [ 1 N S]) ;
        beta_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
        sigma_k3D=sigma_s3D; mu_k3D=mu_s3D; 

%============================= SOLVE THE MODEL ============================
X0=[ ones(N,1); ones(N,1)];
syst=@(X) BT_FE(X, N ,S, Yi3D, Ri3D, beta_ik3D, sigma_k3D, lambda_jik3D, tjik_3D);
options = optimset('Display','iter','MaxFunEvals',50000000,'MaxIter',100000,'TolFun',1e-16,'TolX',1e-16); %'Algorithm','trust-region-dogleg',
[x_fsolve,fval_fsolve]=fsolve(syst, X0, options);
max(abs(fval_fsolve))

wi_h=abs(x_fsolve(1:N));    % abs(.) is used avoid complex numbers...
Yi_h=abs(x_fsolve(N+1:N+N));

% construct 3D cubes from 1D vectors
wi_h3D=repmat(wi_h,[1 N S]);
Yi_h3D=repmat(Yi_h,[1 N S]);
Yj_h3D=permute(Yi_h3D,[2 1 3]);
Yj3D=permute(Yi3D,[2 1 3]);

% ------------------------------------------------------------------
%        Wage Income = Total Sales net of Taxes
% ------------------------------------------------------------------
AUX0 = lambda_jik3D.*( wi_h3D.^(1-sigma_k3D));
AUX1 = repmat(sum(AUX0,1),[N 1 1]);
AUX2 = AUX0./AUX1;
Xjik_3D = AUX2.*beta_ik3D.*(Yj_h3D.*Yj3D);
   
clearvars -except Xjik_3D sigma_k3D mu_k3D tjik_3D N S country_id Gains_from_policy N_total home_id Gains_deep_agreement Gains_unilateral X_sol_1st X_sol_2nd X_sol_3rd

%% ----------------------     FUNCTIONS   --------------------------%%
function [ceq] = BT_FE(X, N ,S, Yi3D, Ri3D, beta_ik3D, sigma_k3D, lambda_jik3D, tjik_3D_app)

% ------------------------------------------------------------------
%        Description of Variables
% ------------------------------------------------------------------
%   N: number of countries;  S: umber of industries  
%   Yi: factual income (GDP) in country i    
%   beta_ik: industry-level expenditure share (C-D weight)
%   lambda_jik: within-industry expenditure share
%   sigma: industry-level CES parameter (sigma-1 ~ trade elasticity)
%   country_id: index of the Home country
% ------------------------------------------------------------------

wi_h=abs(X(1:N));    % abs(.) is used avoid complex numbers...
Yi_h=abs(X(N+1:N+N));
tjik_3D = tjik_3D_app;


% construct 3D cubes from 1D vectors
wi_h3D=repmat(wi_h,[1 N S]);
Yi_h3D=repmat(Yi_h,[1 N S]);
Yj_h3D=permute(Yi_h3D,[2 1 3]);
Yj3D=permute(Yi3D,[2 1 3]);

% ------------------------------------------------------------------
%        Wage Income = Total Sales net of Taxes
% ------------------------------------------------------------------
AUX0 = lambda_jik3D.*( wi_h3D.^(1-sigma_k3D));
AUX1 = repmat(sum(AUX0,1),[N 1 1]);
AUX2 = AUX0./AUX1;
AUX3 = AUX2.*beta_ik3D.*(Yj_h3D.*Yj3D)./((1+tjik_3D));
ERR1 = sum(sum(AUX3,3),2) - wi_h.*Ri3D(:,1,1);
ERR1(N,1) = sum(Ri3D(:,1,1).*(wi_h-1));  % replace one excess equation with normalization,w^=w'/w=1, where w=sum_i(wi'*Li)/sum(wi*Li)

% ------------------------------------------------------------------
%        Total Income = Total Sales 
% ------------------------------------------------------------------
AUX5 = AUX2.*beta_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
ERR2 = sum(sum(AUX5,3),1)' + (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);

% ------------------------------------------------------------------

ceq= [ERR1' ERR2'];

end
