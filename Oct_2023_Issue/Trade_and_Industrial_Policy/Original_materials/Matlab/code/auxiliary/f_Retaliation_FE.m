function [ceq, Gains] = Retaliation_FE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D_app, id, case_id)

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

%---- construct 3D cubes for change in tariffs ---------------
 tjik_3D=0;
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);
 
 
 xjik_3D= sigma_k3D./(sigma_k3D-1) - 1;
 xjik_3D(repmat(eye(N)==1, [1 1 S]))=0;
 xjik_h3D= 1 + xjik_3D ;
 
 sik_3D = zeros(N,N,S);  sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
 sik_h3D= 1 + sik_3D; 

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
%TEMP = abs(rik_h3D);
ERR1 = reshape(ERR1_3D,N*S,1); %/min(TEMP(:)); 
ERR1(N*S,1) = sum(Ri3D(:,1,1).*(wi_h-1));  % replace one excess equation with normalization,w^=w'/w=1, where w=sum_i(wi'*Li)/sum(wi*Li)
%ERR1(N*S,1) = wi_h(N) - 1;
% ------------------------------------------------------------------
%        Total Income = Total Sales (Equation 15)
% --------------------------a----------------------------------------
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = sum(sum(R_M,3),1)' + sum(sum(R_X,3),2)+ (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);
% ------------------------------------------------------------------
ERR5_3D=sum(rik_h3D.*rik3D,3);
ERR5=100*(ERR5_3D(:,1)-1); % Eq.31.b in Section 5

ceq= [ERR1' ERR2' ERR5'];

Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX0,1)),3))';
Wi_h = Yi_h./Pi_h;
Gains = 100*(Wi_h(id)-1);

end
