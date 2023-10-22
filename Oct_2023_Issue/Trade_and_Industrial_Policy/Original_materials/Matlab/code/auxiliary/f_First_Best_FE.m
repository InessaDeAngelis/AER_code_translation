function [ceq, Gains] = First_Best_FE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D_app, id, case_id)

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
%               Optimal Import Tax Formula: Theorem 1
% ------------------------------------------------------------------

% -------------- other specifications --------------
%{
%----------------- Original Specification --------------------
% rjik_3D = AUX3./repmat(sum(AUX3,2), [1 N 1]); 
% AUX5 = mu_k3D ./(1 + mu_k3D);
% AUX6 = repmat(sum(  - AUX5.*rjik_3D.*(1 + (sigma_k3D-1).*(1-AUX2)),2),[1 N 1]) ...
%         - (  - AUX5.* rjik_3D.*(1 + (sigma_k3D-1).*(1-AUX2)));
%  
% omega = - AUX5.*rjik_3D./(1 + AUX6);
%
%------- Specification based on Adding Up Constraint----------
% rjik_3D = AUX3./repmat(sum(AUX3,2), [1 N 1]); 
% AUX5 = mu_k3D ./(1 + mu_k3D);
% AUX6 = repmat(sum( - AUX5.*rjik_3D.*(1 + (sigma_k3D-1).*(1-AUX2)),2),[1 N 1]) ...
%         - ( - AUX5.* rjik_3D.*(1 + (sigma_k3D-1).*(1-AUX2)));
% AUX5A = (repmat(sum(rjik_3D.*rik_h3D.*rik3D./(1 + AUX6),3),[1 1 S]) - rjik_3D.*rik_h3D.*rik3D./(1 + AUX6))./(1 + mu_k3D);   
% omega = - AUX5.*rjik_3D./(1 + AUX6) - (1./(1 - rik_h3D.*rik3D)).*AUX5A;

%--------- Specification based on rho ----------------
% rjik_3D = AUX3./repmat(sum(AUX3,2), [1 N 1]); 
% epsilon = -( 1 + (sigma_k3D-1).*(1-AUX2) );
% AUX6A =  mu_k3D .*(1 + repmat(sum(rjik_3D.*epsilon,2), [1 N 1]) - rjik_3D.*epsilon);
% AUX6B = (repmat(sum( rik_h3D.*rik3D.*AUX6A,3), [1 1 S]) -  rik_h3D.*rik3D.*AUX6A) ./ (1-rik_h3D.*rik3D);
% 
% B = 1./(1-rik_h3D.*rik3D) + AUX6A - (rik_h3D.*rik3D./(1-rik_h3D.*rik3D)).*AUX6B;
% A = - (mu_k3D.*rjik_3D - (repmat(sum(mu_k3D.*rik_h3D.*rik3D.*rjik_3D,3),[1 1 S]) - mu_k3D.*rik_h3D.*rik3D.*rjik_3D)./(1-rik_h3D.*rik3D));
%            
% omega =  A./B ;
%}
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
ERR5=100*(ERR5_3D(:,1)-1); % Eq.31.b in Section 5

ceq= [ERR1' ERR2' ERR3' ERR4' ERR5'];

Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX0,1)),3))';
Wi_h = Yi_h./Pi_h;
Gains = 100*(Wi_h(id)-1);

end
