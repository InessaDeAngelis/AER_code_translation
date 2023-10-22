function [ceq, Gains] = First_Best_RE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D_app, id, case_id)

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

%---- construct 3D cubes for change in tariffs ---------------
 tjik = abs(X(2*N+1:2*N+(N-1)*S));
 tjik_temp = 1 + tjik_3D_app; tjik_temp([1:id-1 id+1:N],id,:)=reshape(tjik,N-1,1,S);
 tjik_3D = repmat(eye(N), [1 1 S]) + tjik_temp.*repmat(1-eye(N), [1 1 S]) - 1 ;
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);
 

 xjik=abs(X(2*N+(N-1)*S+1:end));
 xjik_3D=ones(N,N,S); 
 xjik_3D(id,[1:id-1 id+1:N],:)=reshape(xjik,1,N-1,S);
 xjik_h3D = xjik_3D; xjik_3D=xjik_3D-1 ;
 
 sik_3D = zeros(N,N,S);  sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
 sik_h3D= 1 + sik_3D; 

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
%               Optimal Import Tax Formula: Theorem 1
% ------------------------------------------------------------------

    if case_id == 1
        
    mu_avg = Profit./(wi_h.*Ri3D(:,1,1));
    mu_avg_3D =  repmat(mu_avg, [1 N S]);
    d_mu = (mu_k3D - mu_avg_3D)./(1 + mu_k3D);

    AUX4 = AUX2.*e_ik3D.*(Yj_h3D.*Yj3D)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D));
    AUX5 = AUX4./repmat(sum(sum(AUX4,2),3), [1 N S]);
    AUX6 = repmat(sum(sum(1 - d_mu.*AUX5.*(1 + (sigma_k3D-1).*(1-AUX2)),3),2),[1 N S]) ...
            - repmat(sum(1 - d_mu.*AUX5.*(1 + (sigma_k3D-1).*(1-AUX2)),3), [1 1 S]);
    omega =   -d_mu.*repmat(sum(AUX5,3), [1 1 S])./(1 + AUX6) ;

    %------ other specs -------
    %{
    %%%% Code for the two country case w/o approximation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % epsilon =  (1 + (sigma_k3D-1).*(1-AUX2))./(1 + d_mu.*AUX5.*(1 + (sigma_k3D-1).*(1-AUX2)));
    % A_11 = 0;
    % A_12 = sum(d_mu(1,2,:).*AUX5(1,2,:).*(sigma_k3D(1,2,:)-1).*AUX2(2,2,:),3);
    % A_21 = 0; %sum(d_mu_B(2,2,:).*AUX5(2,2,:).*(sigma_k3D(2,2,:)-1).*AUX2(1,2,:),3);
    % A_22 = - sum( d_mu(2,2,:).*AUX5(2,2,:).*(1 + (sigma_k3D(2,2,:)-1).*(1-AUX2(2,2,:))),3);
    % %A_22 = - sum( d_mu(2,2,:).*AUX5(2,2,:).*epsilon(2,2,:),3);
    % A = [A_11 A_12; A_21 A_22];  AUX6 = inv(eye(N) + A);
    % rho = sum(sum(AUX4(1,:,:),2),3)/sum(sum(AUX4(2,:,:),2),3);
    % omega = -d_mu.*(repmat(sum(AUX5,3), [1 1 S])* AUX6(2,2) + rho*AUX6(1,2));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % AUX4 = AUX2.*e_ik3D.*(Yj_h3D.*Yj3D)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D));
    % AUX5 = AUX4./repmat(sum(sum(AUX4,2),3), [1 N S]);
    % AUX6_A = repmat(sum(sum(  - d_mu.*AUX5.*(1 + (sigma_k3D-1).*(1-AUX2)),3),2),[1 N S]) ...
    %         - repmat(sum( - d_mu.*AUX5.*(1 + (sigma_k3D-1).*(1-AUX2)),3), [1 1 S]);
    %     
    % AUX6_B = repmat(sum(d_mu.*AUX5.*((sigma_k3D-1).*(1-AUX2)),3),[1 1 S]) ;
    % w_adj = repmat(sum(sum(AUX4,3),2),[1 N S]);    
    % adjust = permute(d_mu.*(w_adj./permute(w_adj, [2 1 3])).*AUX6_B, [2 1 3]) ;  
    %     
    % omega =   -d_mu.*(repmat(sum(AUX5,3), [1 1 S]) - adjust)./(1 + AUX6_A) ;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %}
    %--------------------------
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

ceq= [ERR1' ERR2' ERR3' ERR4'];

Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX0,1)),3))';
Wi_h = Yi_h./Pi_h;
Gains = 100*(Wi_h(id)-1);

end
