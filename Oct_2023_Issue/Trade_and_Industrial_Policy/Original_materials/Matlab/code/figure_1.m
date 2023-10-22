clear;
clc
% ------------------------------------------------------------------
%           Description of Variables
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

% pre-define matrixes to save output
gains = zeros(11,3); Covariance = zeros(1,11);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% compute policy outcomes for i= 1,..,11 different parameter values
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for i=1:11
    
%-----------------------------------------------------------------%
%      (Fig 1.B) Consequences of Unilateral Scale Correction
%-----------------------------------------------------------------%

sigma = [1.5+(i-1)*0.15  3-(i-1)*0.15]; sigma_k3D = repmat(reshape(sigma,1,1,S), [N N 1]); %sector 2 is high markup
gamma = [3  6]; mu_k3D = repmat(reshape(1./(gamma-1),1,1,S), [N N 1]); %sector 2 is high markup 
e_ik3D = (1/S)*ones(N,N,S);
home_country_id = 1;

lambda_jik = [ 0.5  0.5 ; ...
               0.5  0.5]; 
lambda_jik3D = repmat(lambda_jik, [1 1 S]);

Yi3D = repmat([100; 100], [1 N S]);   tjik_3D = zeros(N,N,S);
Ri3D=repmat(sum(sum(lambda_jik3D.*e_ik3D.*permute(Yi3D,[2 1 3])./(1+tjik_3D),2),3), [1 N S]) ;
X = lambda_jik3D .* e_ik3D .* permute(Yi3D,  [2 1 3]);
rik3D = repmat(sum(X,2), [1 N 1])./repmat(sum(sum(X,2),3), [1 N S]);

T0=[ones(N,1); ones(N,1); ones(N*S,1)];
options = optimset('Display','off','MaxFunEvals',inf,'MaxIter',inf,'TolFun',1e-12,'TolX',1e-14);
target = @(X) Unilateral_Industrial_Policy_FE(X, N ,S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, home_country_id);
X_sol=fsolve(target,T0, options);
[~, gains(i,1)] = Unilateral_Industrial_Policy_FE(X_sol, N , S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, home_country_id);


Yi3D = repmat([100; 100], [1 N S]);   tjik_3D = zeros(N,N,S);
Ri3D=repmat(sum(sum(lambda_jik3D.*e_ik3D.*permute(Yi3D,[2 1 3])./((1+tjik_3D).*(1+mu_k3D)),2),3), [1 N S]) ;
%X = lambda_jik3D .* e_ik3D .* permute(Yi3D,  [2 1 3]);

T0=[1.1*ones(N,1); 0.9*ones(N,1)];
options = optimset('Display','off','MaxFunEvals',inf,'MaxIter',inf,'TolFun',1e-12,'TolX',1e-14);
target = @(X) Unilateral_Industrial_Policy_RE(X, N ,S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, home_country_id);
X_sol=fsolve(target,T0, options);
[~, gains(i,2)] = Unilateral_Industrial_Policy_RE(X_sol, N , S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, home_country_id);

AUX = cov(log(sigma-1), log(1./(gamma-1)));
Covariance(i,1) = AUX(1,2);


%-----------------------------------------------------------------%
%             (Fig 1.A) Efficiacy of 2nd-Best Trade Taxes
%-----------------------------------------------------------------%
gamma = [3+(i-1)*0.3  6-(i-1)*0.3]; 
mu_k3D = repmat(reshape(1./(gamma-1),1,1,S), [N N 1]); %sector 2 is high markup
sigma = [3  1.5]; sigma_k3D = repmat(reshape(sigma,1,1,S), [N N 1]); %sector 2 is high markup
lambda_jik = [ 0.9  0.1 ; ...
               0.1  0.9];
lambda_jik3D = repmat(lambda_jik, [1 1 S]);

Yi3D = repmat([100; 100], [1 N S]);   tjik_3D = zeros(N,N,S);
Ri3D=repmat(sum(sum(lambda_jik3D.*e_ik3D.*permute(Yi3D,[2 1 3])./(1+tjik_3D),2),3), [1 N S]) ;
X = lambda_jik3D .* e_ik3D .* permute(Yi3D,  [2 1 3]);
rik3D = repmat(sum(X,2), [1 N 1])./repmat(sum(sum(X,2),3), [1 N S]);

LB=[0.5*ones(N,1); 0.5*ones(N,1); 0.5*ones(N*S,1); 0.75*ones((N-1)*S,1); ones((N-1)*S,1)];
UB=[2*ones(N,1); 2*ones(N,1); 2*ones(N*S,1);  1.5*ones((N-1)*S,1); 5*ones((N-1)*S,1)];
T0=[1*ones(N,1); 1*ones(N,1); 1*ones(N*S,1); 1*ones((N-1)*S,1); sigma'./(sigma'-1)];
options = optimoptions(@fmincon,'Display','off','MaxFunEvals',inf,...
                'MaxIter',5000,'TolFun',1e-12,'TolX',1e-14, 'TolCon', 1e-10);

target = @(X) Obj_MPEC_FE(X, N , S, ...
                    e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_country_id, 0);
constraint = @(X) Const_MPEC_FE(X, N ,S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, home_country_id, 0);
[~, gains(i,3)]=fmincon(target,T0,[],[],[],[],LB,UB,constraint,options);

Yi3D = repmat([100; 100], [1 N S]);   tjik_3D = zeros(N,N,S);
Ri3D=repmat(sum(sum(lambda_jik3D.*e_ik3D.*permute(Yi3D,[2 1 3])...
                        ./((1+tjik_3D).*(1+mu_k3D)),2),3), [1 N S]) ;
X = lambda_jik3D .* e_ik3D .* permute(Yi3D,  [2 1 3]);

LB=[0.5*ones(N,1); 0.5*ones(N,1); 0.75*ones((N-1)*S,1); ones((N-1)*S,1)];
UB=[2*ones(N,1); 2*ones(N,1); 1.5*ones((N-1)*S,1); 5*ones((N-1)*S,1)];
T0=[1*ones(N,1); 1*ones(N,1); 1*ones((N-1)*S,1); sigma'./(sigma'-1)];
options = optimoptions(@fmincon,'Display','off','MaxFunEvals',inf,...
                'MaxIter',5000,'TolFun',1e-12,'TolX',1e-14, 'TolCon', 1e-10);

target = @(X) Obj_MPEC_RE(X, N , S, ...
        e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_country_id, 0);
constraint = @(X) Const_MPEC_RE(X, N ,S, ...
    Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_country_id, 0);
[~, gains(i,4)]=fmincon(target,T0,[],[],[],[],LB,UB,constraint,options);

AUX = cov(log(sigma-1), log(1./(gamma-1)));
Covariance(i,2) = AUX(1,2);

end


line(Covariance(:,2), -gains(:,3)','Color','[1 0.8 0]','LineWidth',5, 'linestyle','-')
line(Covariance(:,2), -gains(:,4)','Color','[0.1 0.5 1]','LineWidth',5, 'linestyle','-.')

title( '\textbf{Gains from 2nd-Best Trade Policies}','interpreter','latex','FontSize',20);
yticks([2 2.4 2.8]);
xlim([-0.65 0.65]); 
xticks([-0.6 -0.3 0 0.3 0.6]);
ax = gca; ax.YAxis.FontSize = 16; ax.XAxis.FontSize = 16;
xlabel( '$Cov(\sigma_{k},\mu_{k})$','interpreter','latex','FontSize',24);
ylabel( '\textbf{\% $\Delta\,$Welfare}','interpreter','latex','FontSize',18);

    legend({'Free Entry','Restricted Entry' }, ...
             'FontSize',18, 'interpreter','latex', 'Location','northwest'); 
    legend boxoff 
    %print('Output/Figure_1A.png', '-dpng', '-r500')   % Resolution = 500 DPI
    print('Output/Figure_1A.eps', '-depsc2')
    
close all

line(Covariance(:,1), gains(:,1)','Color','[1 0.8 0]','LineWidth',5, 'linestyle','-')
line(Covariance(:,1), gains(:,2)','Color','[0.1 0.5 1]','LineWidth',5, 'linestyle','-.')
line(Covariance(:,1), zeros(1,11),'Color','r','LineWidth',1.5, 'linestyle','--')

title( '\textbf{Consequences of Unilateral Scale/Markup Correction}','interpreter','latex','FontSize',20);
yticks([-4 -2 0 2 4]);
xlim([-0.65 0.65]); 
xticks([-0.6 -0.3 0 0.3 0.6]);
ax = gca; ax.YAxis.FontSize = 16; ax.XAxis.FontSize = 16;
xlabel( '$Cov(\sigma_{k},\mu_{k})$','interpreter','latex','FontSize',24);
   legend off
   %print('Output/Figure_1B.png', '-dpng', '-r500')   % Resolution = 500 DPI
   print('Output/Figure_1B.eps', '-depsc2')
    
    
close all    

%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~           AUXILIARY FUNCTION           ~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
    

function [ceq, gains] = Unilateral_Industrial_Policy_FE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, id)

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

% ------------------------------------------------------------------
%        construct 3D cubes for change in taxes
% ------------------------------------------------------------------
 tjik_h3D =ones(N,N,S); tjik_3D=tjik_h3D-1 ;
 xjik_h3D =ones(N,N,S); xjik_3D=xjik_h3D-1 ;
 
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
%                    Total Income = Total Sales
% ------------------------------------------------------------------
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./...
        ((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = sum(sum(R_M,3),1)' + sum(sum(R_X,3),2) + ...
                    (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);

% ------------------------------------------------------------------
%                   Sum of Revenue Shares = 1
% ------------------------------------------------------------------
ERR3_3D=sum(rik_h3D.*rik3D,3);
ERR3=100*(ERR3_3D(:,1)-1);

% ------------------------------------------------------------------
ceq= [ERR1' ERR2' ERR3'];

Pi_h = prod(sum(AUX0,1).^(e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))),3)';
gains = 100*(Yi_h(id)/Pi_h(id)-1);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ceq, gains] = Unilateral_Industrial_Policy_RE(X, N ,S, ...
                    Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, id)

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

% construct 3D cubes from 1D vectors
wi_h3D=repmat(wi_h,[1 N S]);
Yi_h3D=repmat(Yi_h,[1 N S]);
Yj_h3D=permute(Yi_h3D,[2 1 3]);
Yj3D=permute(Yi3D,[2 1 3]);

% ------------------------------------------------------------------
%        construct 3D cubes for change in taxes
% ------------------------------------------------------------------
 tjik_h3D = ones(N,N,S); tjik_3D=tjik_h3D-1 ;
 xjik_h3D = ones(N,N,S); xjik_3D=xjik_h3D-1 ;
 
 sik_3D = zeros(N,N,S);  sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
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
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./...
            ((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = Profit + sum(sum(R_M,3),1)' + sum(sum(R_X,3),2) + ...
                           (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);

ceq= [ERR1' ERR2'];

Pi_h = prod(sum(AUX0,1).^(e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))),3)';
gains = 100*(Yi_h(id)/Pi_h(id) - 1);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [c, ceq] = Const_MPEC_FE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D_app, id, first_best)

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

% ------------------------------------------------------------------
%        construct 3D cubes for change in taxes
% ------------------------------------------------------------------
 tjik = abs(X(2*N+N*S+1:2*N+N*S+(N-1)*S));
 tjik_temp = 1 + tjik_3D_app;
 tjik_temp([1:id-1 id+1:N],id,:)=reshape(tjik,N-1,1,S);
 tjik_3D = repmat(eye(N), [1 1 S]) + tjik_temp.*repmat(1-eye(N), [1 1 S]) - 1 ;
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);
 

 xjik=abs(X(2*N+N*S+(N-1)*S+1:end));
 xjik_3D=ones(N,N,S); 
 xjik_3D(id,[1:id-1 id+1:N],:)=reshape(xjik,1,N-1,S);
 xjik_h3D = xjik_3D; xjik_3D=xjik_3D-1 ;
 
 if first_best~=1
    sik_3D = zeros(N,N,S); sik_h3D= 1 + sik_3D ; 
 else
    sik_3D = zeros(N,N,S);  sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
    sik_h3D= 1 + sik_3D ;
 end


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
% ------------------------------------------------------------------
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./...
            ((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = sum(sum(R_M,3),1)' + sum(sum(R_X,3),2) + ...
                        (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);
% ------------------------------------------------------------------
ERR3_3D=sum(rik_h3D.*rik3D,3);
ERR3=100*(ERR3_3D(:,1)-1); 

c=[];
ceq= [ERR1' ERR2' ERR3'];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Gains]=Obj_MPEC_FE(X, N , S, ...
        e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D_app, id, first_best)

wi_h=abs(X(1:N));% abs(.) is used avoid complex numbers...
wi_h3D=repmat(wi_h,[1 N S]); % construct 3D cubes from 1D vectors
Ei_h=abs(X(N+1:N+N));
rik_h = abs(X(2*N+1:2*N+N*S));
rik_h3D = repmat(reshape(rik_h,N,1,S), [1 N 1]);

% ------------------------------------------------------------------
%        construct 3D cubes for change in taxes
% ------------------------------------------------------------------
 tjik = abs(X(2*N+N*S+1:2*N+N*S+(N-1)*S));
 tjik_temp = 1 + tjik_3D_app; 
 tjik_temp([1:id-1 id+1:N],id,:)=reshape(tjik,N-1,1,S);
 tjik_3D = repmat(eye(N), [1 1 S]) + tjik_temp.*repmat(1-eye(N), [1 1 S]) - 1;
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);

 xjik=abs(X(2*N+N*S+(N-1)*S+1:end));
 xjik_3D=ones(N,N,S); 
 xjik_3D(id,[1:id-1 id+1:N],:)= reshape(xjik,1,N-1,S);
 xjik_h3D = xjik_3D;

if first_best~=1
    sik_3D = zeros(N,N,S); sik_h3D= 1 + sik_3D ; 
else
    sik_3D = zeros(N,N,S);  sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
    sik_h3D= 1 + sik_3D ;
 end 

% Calculate the change in price indexes
taujik_h3D = tjik_h3D.*xjik_h3D.*sik_h3D;
pjik_h3D = wi_h3D.*taujik_h3D.*(rik_h3D.^(- mu_k3D));
AUX1 = lambda_jik3D.*(pjik_h3D.^(1-sigma_k3D));
Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX1,1)),3))';

% Calculate the change in welfare
Wi_h = Ei_h./Pi_h;
Gains = -100*(Wi_h(id)-1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [c, ceq] = Const_MPEC_RE(X, N ,S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D_app, id, first_best)

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

% construct 3D cubes from 1D vectors
wi_h3D=repmat(wi_h,[1 N S]);
Yi_h3D=repmat(Yi_h,[1 N S]);
Yj_h3D=permute(Yi_h3D,[2 1 3]);
Yj3D=permute(Yi3D,[2 1 3]);

% ------------------------------------------------------------------
%        construct 3D cubes for change in taxes
% ------------------------------------------------------------------
 tjik = abs(X(2*N+1:2*N+(N-1)*S));
 tjik_temp = 1 + tjik_3D_app; 
 tjik_temp([1:id-1 id+1:N],id,:)=reshape(tjik,N-1,1,S);
 tjik_3D = repmat(eye(N), [1 1 S]) + tjik_temp.*repmat(1-eye(N), [1 1 S]) - 1 ;
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);
 

 xjik=abs(X(2*N+(N-1)*S+1:end));
 xjik_3D=ones(N,N,S); 
 xjik_3D(id,[1:id-1 id+1:N],:)=reshape(xjik,1,N-1,S);
 xjik_h3D = xjik_3D; xjik_3D=xjik_3D-1 ;
 
 if first_best~=1
    sik_3D = zeros(N,N,S); sik_h3D= 1 + sik_3D ; 
 else
    sik_3D = zeros(N,N,S);  sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
    sik_h3D= 1 + sik_3D ;
 end

% ------------------------------------------------------------------
%        Wage Income = Total Sales net of Taxes (Equation 6)
% ------------------------------------------------------------------
tau_h = tjik_h3D.*xjik_h3D.*sik_h3D;
AUX0 = lambda_jik3D.*((tau_h.*wi_h3D).^(1-sigma_k3D));
AUX1 = repmat(sum(AUX0,1),[N 1 1]);
AUX2 = AUX0./AUX1;
AUX3 = AUX2.*e_ik3D.*(Yj_h3D.*Yj3D)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D).*(1+mu_k3D));

ERR1 = sum(sum(AUX3,3),2) - wi_h.*Ri3D(:,1,1);
ERR1(N,1) = sum(Ri3D(:,1,1).*(wi_h-1));  % replace one excess equation with normalization,w^=w'/w=1, where w=sum_i(wi'*Li)/sum(wi*Li)
% ------------------------------------------------------------------
%        Total Income = Total Sales (Equation 15)
% ------------------------------------------------------------------
Profit =  sum(sum(mu_k3D.* AUX3,3),2);
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = Profit + sum(sum(R_M,3),1)' + sum(sum(R_X,3),2)+ (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);
% ------------------------------------------------------------------
c=[];
ceq= [ERR1' ERR2'];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Gains]=Obj_MPEC_RE(X, N , S, ...
            e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D_app, id, first_best)

wi_h=abs(X(1:N));% Nx1, apply abs to avoid complex numbers...
wi_h3D=repmat(wi_h,[1 N S]); % construct 3D cubes from 1D vectors
Ei_h=abs(X(N+1:N+N));

% ------------------------------------------------------------------
%        construct 3D cubes for change in taxes
% ------------------------------------------------------------------
 tjik = abs(X(2*N+1:2*N+(N-1)*S));
 tjik_temp = 1 + tjik_3D_app; tjik_temp([1:id-1 id+1:N],id,:)=reshape(tjik,N-1,1,S);
 tjik_3D = repmat(eye(N), [1 1 S]) + tjik_temp.*repmat(1-eye(N), [1 1 S]) - 1 ;
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);
 

 xjik=abs(X(2*N+(N-1)*S+1:end));
 xjik_3D=ones(N,N,S); 
 xjik_3D(id,[1:id-1 id+1:N],:)=reshape(xjik,1,N-1,S);
 xjik_h3D = xjik_3D;

 if first_best~=1
    sik_3D = zeros(N,N,S); sik_h3D= 1 + sik_3D ; 
 else
    sik_3D = zeros(N,N,S);  sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
    sik_h3D= 1 + sik_3D ;
 end

% Calculate the change in price indexes
tau_h = tjik_h3D.*xjik_h3D.*sik_h3D;
AUX0=((tau_h.*wi_h3D).^(1-sigma_k3D));
AUX1=lambda_jik3D.*AUX0;
Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX1,1)),3))';

% Calculate the change in welfare
Wi_h = Ei_h./Pi_h;
Gains = -100*(Wi_h(id)-1);
end

