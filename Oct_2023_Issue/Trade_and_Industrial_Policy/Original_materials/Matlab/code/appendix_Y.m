clear;
clc

%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ~~~~~~~~~~     MELITZ-PARETO MODEL (FIGURE Y1)    ~~~~~~~~~~~
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Gains_from_policy = zeros(43,3);
N_total = 44; home_id = 2;

for country_id=1:N_total-1
    
%------------------------------------------------------------        
%--------         Read and Prepare Data       -------------
%------------------------------------------------------------
    clearvars -except country_id Gains_from_policy N_total home_id
    AggC = [ones(1,N_total); zeros(1,N_total)];
    AggC(2,country_id)=1; AggC(1,country_id)=0;

    f_Read_Raw_Data_Melitz
    f_Balance_Data_RE

    lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
    Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
    Ri3D=repmat(sum(sum(Xjik_3D./((1+mu_k3D).*(1+tjik_3D)),2),3), [ 1 N S]) ;
    e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);

%---------------------------------------------------------        
%--------   Compute Gains from Policy    -------------
%---------------------------------------------------------

%-----------------   First-Best Policy  -----------------%
T0=[1*ones(N,1); 1*ones(N,1); 1.1*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
target = @(X) f_First_Best_RE(X, N ,S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id, 1);
options = optimset('Display','iter','MaxFunEvals',inf,...
        'MaxIter',inf,'TolFun',1e-12,'TolX',1e-16, 'algorithm','levenberg-marquardt');
X_sol=fsolve(target,T0, options);

Gains_from_policy(country_id,1) = f_Welfare_Gains_RE(X_sol, N , S, ...
                    e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id, 1); 

%-----------------   Second-Best Policy  -----------------%               
LB=[0.5*ones(N,1); 0.5*ones(N,1); 0.75*ones((N-1)*S,1); 0.75*ones((N-1)*S,1)];
UB=[2*ones(N,1); 2*ones(N,1);  2*ones((N-1)*S,1);4*ones((N-1)*S,1)];

    if ismember(country_id, [12 20 21 23 28])
        T0=[ones(N,1); ones(N,1); 1.1*ones((N-1)*S,1); 1.5*ones((N-1)*S,1)];
    else
        T0=[ones(N,1); ones(N,1); 1.25*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
    end
    
target = @(X) f_Obj_MPEC_RE(X, N , S, ...
                        e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id);
constraint = @(X) f_Const_MPEC_RE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id);

options = optimoptions(@fmincon,'Display','off','MaxFunEvals',inf,...
           'MaxIter',5000,'TolFun',1e-8,'TolX',1e-8, 'TolCon', 1e-8, 'algorithm','sqp');
[X_MPEC_A, ~]=fmincon(target,T0,[],[],[],[],LB,UB,constraint,options);

Gains_from_policy(country_id,2) = f_Welfare_Gains_RE(X_MPEC_A, N , S, ...
                    e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id, 0);

%-----------------   Third-Best Policy  -----------------%  
LB=[0.5*ones(N,1); 0.5*ones(N,1); 0.75*ones((N-1)*S,1); ones((N-1)*S,1)];
UB=[2*ones(N,1); 2*ones(N,1);  2*ones((N-1)*S,1); ones((N-1)*S,1)];

T0=[ones(N,1); ones(N,1); 1.25*ones((N-1)*S,1); ones((N-1)*S,1)];
target = @(X) f_Obj_MPEC_RE(X, N , S, ...
                        e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id);
constraint = @(X) f_Const_MPEC_RE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id);

options = optimoptions(@fmincon,'Display','off','MaxFunEvals',inf, ...
      'MaxIter',5000,'TolFun',1e-8,'TolX',1e-8, 'TolCon', 1e-8, 'algorithm','sqp' );
[X_MPEC_B, ~]=fmincon(target,T0,[],[],[],[],LB,UB,constraint,options);

Gains_from_policy(country_id,3) = f_Welfare_Gains_RE(X_MPEC_B, N , S, ...
                      e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id, 0);

end

[~, text, ~] = xlsread('Country_List.xlsx');
countries = text(1:end-1, 1);

Gains_from_policy_Meltiz = Gains_from_policy;
clear Gains_from_policy
load output/temp/Gains_from_policy_t4
T=table(countries, Gains_from_policy(1:43,1), Gains_from_policy_Meltiz(:,1), Gains_from_policy(1:43,2), ...
        Gains_from_policy_Meltiz(:,2), Gains_from_policy(1:43,3), Gains_from_policy_Meltiz(:,3), ...
         'VariableNames', {'iso', 'first_best', 'first_best_Melitz', ...
         'second_best', 'second_best_Melitz', 'third_best', 'third_best_Melitz'});
 writetable(T,'output/temp/output_for_stata_figY1.csv', 'Delimiter',',')  
  

%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ~~~~~~~~~~   FIXED EFFECT ESTIMATION (FIGURE Y2)  ~~~~~~~~~~~
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
clear;
clc

Gains_from_policy = zeros(43,3);
N_total = 44; home_id = 2;

 for country_id=1:N_total-1
    
%------------------------------------------------------------        
%--------         Read and Prepare Data       -------------
%------------------------------------------------------------
    clearvars -except country_id Gains_from_policy N_total home_id
    AggC = [ones(1,N_total); zeros(1,N_total)];
    AggC(2,country_id)=1; AggC(1,country_id)=0;

    f_Read_Raw_Data_FixedEffects
    f_Balance_Data_RE

    lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
    Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
    Ri3D=repmat(sum(sum(Xjik_3D./((1+mu_k3D).*(1+tjik_3D)),2),3), [ 1 N S]) ;
    e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);

%---------------------------------------------------------        
%--------   Compute Gains from Policy    -------------
%---------------------------------------------------------

%-----------------   First-Best Policy  -----------------%        
T0=[1*ones(N,1); 1*ones(N,1); 1.1*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
target = @(X) f_First_Best_RE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id, 1);
options = optimset('Display','iter','MaxFunEvals',inf, ...
        'MaxIter',inf,'TolFun',1e-12,'TolX',1e-16, 'algorithm','levenberg-marquardt');
X_sol=fsolve(target,T0, options);

Gains_from_policy(country_id,1) = f_Welfare_Gains_RE(X_sol, N , S, ...
                        e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id, 1); 

%-----------------   Second-Best Policy  -----------------%                 
LB=[0.5*ones(N,1); 0.5*ones(N,1); 0.75*ones((N-1)*S,1); 0.75*ones((N-1)*S,1)];
UB=[2*ones(N,1); 2*ones(N,1);  2*ones((N-1)*S,1);4*ones((N-1)*S,1)];

    if ismember(country_id, [10 16 18 27])
        T0=[0.85*ones(N,1); 1.15*ones(N,1); 1.2*ones((N-1)*S,1); 1.5*ones((N-1)*S,1)];
    else
        T0=[ones(N,1); ones(N,1); 1.25*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
    end
    
target = @(X) f_Obj_MPEC_RE(X, N , S, ...
            e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id);
constraint = @(X) f_Const_MPEC_RE(X, N ,S, ...
    Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id);

options = optimoptions(@fmincon,'Display','off','MaxFunEvals',inf,'MaxIter',5000,'TolFun',1e-8,'TolX',1e-8, 'TolCon', 1e-8, 'algorithm','sqp');
[X_MPEC_A, ~]=fmincon(target,T0,[],[],[],[],LB,UB,constraint,options);

Gains_from_policy(country_id,2) = f_Welfare_Gains_RE(X_MPEC_A, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id, 0);

%-----------------   Third-Best Policy  -----------------%  
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

Gains_from_policy(country_id,3) = f_Welfare_Gains_RE(X_MPEC_B, N , S, ...
                        e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id, 0);


end

[~, text, ~] = xlsread('Country_List.xlsx');
countries = text(1:end-1, 1);

Gains_from_policy_Fixed_Effects = Gains_from_policy;
clear Gains_from_policy
load output/temp/Gains_from_policy_t4
T=table(countries, Gains_from_policy(1:43,1), Gains_from_policy_Fixed_Effects(:,1), Gains_from_policy(1:43,2), ...
        Gains_from_policy_Fixed_Effects(:,2), Gains_from_policy(1:43,3), Gains_from_policy_Fixed_Effects(:,3), ...
        'VariableNames', {'iso', 'first_best', 'first_best_Fixed_Effects', 'second_best', ...
                                'second_best_Fixed_Effects', 'third_best', 'third_best_Fixed_Effects'});
  writetable(T,'output/temp/output_for_stata_figY2.csv', 'Delimiter',',')
   
%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ~~~~~~~~~~    Alternative Service Sector Scale Elasticity (Y3) ~~~~~~~~~~~
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
clear;
clc

Gains_from_policy = zeros(43,3);
N_total = 44; home_id = 2;

for country_id=1:N_total-1
    
%------------------------------------------------------------        
%--------         Read and Prepare Data       -------------
%------------------------------------------------------------
    clearvars -except country_id Gains_from_policy N_total home_id
    AggC = [ones(1,N_total); zeros(1,N_total)];
    AggC(2,country_id)=1; AggC(1,country_id)=0;

    f_Read_Raw_Data_AltSrv
    f_Balance_Data_RE

    lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
    Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
    Ri3D=repmat(sum(sum(Xjik_3D./((1+mu_k3D).*(1+tjik_3D)),2),3), [ 1 N S]) ;
    e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);

%---------------------------------------------------------        
%--------   Compute Gains from Policy    -------------
%---------------------------------------------------------

%-----------------   First-Best Policy  -----------------%         
T0=[1*ones(N,1); 1*ones(N,1); 1.1*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
target = @(X) f_First_Best_RE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id, 1);
options = optimset('Display','iter','MaxFunEvals',inf,...
        'MaxIter',inf,'TolFun',1e-12,'TolX',1e-16, 'algorithm','levenberg-marquardt');
X_sol=fsolve(target,T0, options);

Gains_from_policy(country_id,1) = f_Welfare_Gains_RE(X_sol, N , S, ...
                        e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id, 1); 

%-----------------   Second-Best Policy  -----------------% 
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

options = optimoptions(@fmincon,'Display','off','MaxFunEvals',inf, ...
        'MaxIter',5000,'TolFun',1e-8,'TolX',1e-8, 'TolCon', 1e-8, 'algorithm','sqp');
[X_MPEC_A, ~]=fmincon(target,T0,[],[],[],[],LB,UB,constraint,options);

Gains_from_policy(country_id,2) = f_Welfare_Gains_RE(X_MPEC_A, N , S, ...
                        e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id, 0);

%-----------------   Third-Best Policy  -----------------%  
LB=[0.5*ones(N,1); 0.5*ones(N,1); 0.75*ones((N-1)*S,1); ones((N-1)*S,1)];
UB=[2*ones(N,1); 2*ones(N,1);  2*ones((N-1)*S,1); ones((N-1)*S,1)];

T0=[ones(N,1); ones(N,1); 1.25*ones((N-1)*S,1); ones((N-1)*S,1)];
target = @(X) f_Obj_MPEC_RE(X, N , S, ...
            e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id);
constraint = @(X) f_Const_MPEC_RE(X, N ,S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id);

options = optimoptions(@fmincon,'Display','off','MaxFunEvals',inf, ...
        'MaxIter',5000,'TolFun',1e-8,'TolX',1e-8, 'TolCon', 1e-8, 'algorithm','sqp' );
[X_MPEC_B, ~]=fmincon(target,T0,[],[],[],[],LB,UB,constraint,options);

Gains_from_policy(country_id,3) = f_Welfare_Gains_RE(X_MPEC_B, N , S, ...
                        e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id, 0);

end

[~, text, ~] = xlsread('Country_List.xlsx');
countries = text(1:end-1, 1);

Gains_from_policy_Alt = Gains_from_policy;
clear Gains_from_policy
load output/temp/Gains_from_policy_t4
T=table(countries, Gains_from_policy(1:43,1), Gains_from_policy_Alt(:,1), Gains_from_policy(1:43,2), ...
        Gains_from_policy_Alt(:,2), Gains_from_policy(1:43,3), Gains_from_policy_Alt(:,3), ...
        'VariableNames', {'iso', 'first_best', 'first_best_Alt', 'second_best', ...
                                            'second_best_Alt', 'third_best', 'third_best_Alt'});
  writetable(T,'output/temp/output_for_stata_figY3.csv', 'Delimiter',',') 
  
  
 delete output/temp/Gains_from_policy_t4 
            