clear;
clc
  
%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%%
%                         FIGURE W.1
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %%
close all
N_cases = 3;
Gains_from_policy = zeros(43,3,N_cases);
CORR = zeros(1,N_cases); COV = zeros(1,N_cases);
N_total = 44; home_id = 2;
rho_vector = {-0.05 0.075 1};

for k=1:N_cases
for country_id=1:N_total-1
    
%-----------------------------------  Read Data  ------------------------------------
        clearvars -except country_id Gains_from_policy N_total home_id rho_vector k CORR COV
        AggC = [ones(1,N_total); zeros(1,N_total)];
        AggC(2,country_id)=1; AggC(1,country_id)=0;
        rho = rho_vector{k}; % rho ~ corr(sigma,gamma)
        
        f_Read_Raw_Data_AV

        lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
        Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
        Ri3D=repmat(sum(sum(Xjik_3D./((1+mu_k3D).*(1+tjik_3D)),2),3), [ 1 N S]) ;
        e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
 
%-----------------------------------  Compute Gains from Policy  ------------------------------------        
T0=[1*ones(N,1); 1*ones(N,1); 1.25*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
target = @(X) f_First_Best_RE(X, N ,S, ...
                Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id, 1);
options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',inf,'TolFun',1e-12,'TolX',1e-16);
X_sol=fsolve(target,T0, options);

Gains_from_policy(country_id,1,k) = f_Welfare_Gains_RE(X_sol, N , S, ...
                e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id, 1); 
               
LB=[0.5*ones(N,1); 0.5*ones(N,1); 0.75*ones((N-1)*S,1); 0.75*ones((N-1)*S,1)];
UB=[2*ones(N,1); 2*ones(N,1);  2*ones((N-1)*S,1);4*ones((N-1)*S,1)];

if ismember(country_id, [9 10 11 14 21 25 27 29 40])
T0=[0.9*ones(N,1); 1.1*ones(N,1); 1.1*ones((N-1)*S,1); 1.5*ones((N-1)*S,1)];
else
T0=[ones(N,1); ones(N,1); 1.25*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
end

target = @(X) f_Obj_MPEC_RE(X, N , S, ...
                        e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id);
constraint = @(X) f_Const_MPEC_RE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id);

options = optimoptions(@fmincon,'Display','off','MaxFunEvals',inf,'MaxIter',5000,...
                        'TolFun',1e-8,'TolX',1e-8, 'TolCon', 1e-8, 'algorithm','sqp');
[X_MPEC_A, ~]=fmincon(target,T0,[],[],[],[],LB,UB,constraint,options);

Gains_from_policy(country_id,2,k) = f_Welfare_Gains_RE(X_MPEC_A, N , S, ...
                    e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id, 0);

LB=[0.5*ones(N,1); 0.5*ones(N,1); 0.75*ones((N-1)*S,1); ones((N-1)*S,1)];
UB=[2*ones(N,1); 2*ones(N,1);  2*ones((N-1)*S,1); ones((N-1)*S,1)];

T0=[ones(N,1); ones(N,1); 1.25*ones((N-1)*S,1); ones((N-1)*S,1)];
target = @(X) f_Obj_MPEC_RE(X, N , S, ...
                e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id);
constraint = @(X) f_Const_MPEC_RE(X, N ,S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id);

options = optimoptions(@fmincon,'Display','off','MaxFunEvals',inf,...
        'MaxIter',5000,'TolFun',1e-8,'TolX',1e-8, 'TolCon', 1e-8, 'algorithm','sqp' );
[X_MPEC_B, ~]=fmincon(target,T0,[],[],[],[],LB,UB,constraint,options);

Gains_from_policy(country_id,3,k) = f_Welfare_Gains_RE(X_MPEC_B, N , S, ...
                        e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id, 0);

CORR(k) = corr(permute(mu_k3D(1,1,:),[3 2 1]), permute(1./(sigma_k3D(1,1,:)-1),[3 2 1]));
AUX = cov(permute((mu_k3D(1,1,1:16)),[3 2 1]), permute((sigma_k3D(1,1,1:16)-1),[3 2 1]));
COV(k) = AUX(2,1);

end
end

Case = {'Artificial 2', 'Artificial 1' , 'Estimated'};

TEMP = median(Gains_from_policy./repmat(Gains_from_policy(:,1,:), [1 3 1]),1); TEMP(:,:,2)= TEMP(:,:,2)-1e-1;
output = [COV(1) TEMP(:,:,1); COV(2) TEMP(:,:,2); COV(3) TEMP(:,:,3)];

T=table(output(:,1), output(:,2), output(:,3), output(:,4),  ...
        'RowNames', Case, 'VariableNames', {'rho', 'first_best','second_best', 'third_best'});


writetable(T ,'output/temp/output_for_stata_figW1.csv', 'Delimiter',',', 'WriteRowNames',true)


%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%%
%               FIGURE W.2: Immiserizing Growth
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %%
clearvars
N_cases = 3;
immiserizing_growth = zeros(44,N_cases);
CORR = zeros(1,N_cases); COV = zeros(1,N_cases);
N_total = 44; rho_vector = {-0.05 0.075 1};

for k=1:N_cases
for country_id=1:N_total
    
%-----------------------------------   Read Data    -------------------------------------
        clearvars -except country_id Gains_from_policy N_total home_id rho_vector k CORR COV
        AggC = eye(N_total);
        rho = rho_vector{k}; % rho ~ corr(sigma,gamma)

        f_Read_Raw_Data_AV

        lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
        Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]);
        Ri3D=repmat(sum(sum(Xjik_3D./((1+mu_k3D).*(1+tjik_3D)),2),3), [ 1 N S]) ;
        e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
        
%-----------------------------------  Compute Gains from Policy  ------------------------------------  
T0=[1.1*ones(N,1); 0.9*ones(N,1)];
target = @(X) f_Growth_RE(X, N ,S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, country_id);
options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',inf,'TolFun',1e-12,'TolX',1e-16);
X_sol=fsolve(target,T0, options);

[~, Gains_from_policy(country_id,k)] = f_Growth_RE(X_sol, N ,S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, country_id); 

CORR(k) = corr(permute(mu_k3D(1,1,:),[3 2 1]), permute(1./(sigma_k3D(1,1,:)-1),[3 2 1]));
AUX = cov(permute(mu_k3D(1,1,1:16),[3 2 1]), permute(sigma_k3D(1,1,1:16)-1,[3 2 1]));
COV(k) = AUX(2,1);

end
end


Case = {'Artificial 2', 'Artificial 1' , 'Estimated'};

TEMP = mean(Gains_from_policy,1);
TEMP(1) = sum(Gains_from_policy(:,1).*(Yi3D(:,1,1)))./sum((Yi3D(:,1,1)));
output = [COV(1) TEMP(1); COV(2) TEMP(2); COV(3) TEMP(3)];

T=table(output(:,1), output(:,2),  ...
        'RowNames', Case, 'VariableNames', {'rho', 'dW'});


writetable(T ,'output/temp/output_for_stata_figW2.csv', 'Delimiter',',', 'WriteRowNames',true)
       