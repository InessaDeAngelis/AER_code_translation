clear;
clc

% ------------------------------------------------------------------
%   N: number of countries;  S: umber of industries 
%   Yi3D: national expenditure ~ national income
%   Ri3D: national wage revneues ~ sales net of tariffs  
%   e_ik3D: industry-level expenditure share (C-D weight)
%   lambda_jik: within-industry expenditure share
%   mu: industry-level scale elasticity
%   sigma: industry-level CES parameter (sigma-1 ~ trade elasticity)
%   tjik_3D_app: applied tariff
% ------------------------------------------------------------------

% pre-define matrixes to save output
Gains_from_policy = zeros(43,3); N_total = 44; 

for country_id= [3 11 32 33 43]
for case_id = 1:3    
%-----------------------------------   Compute Gains from Policy   -------------------------------------
        clearvars -except country_id Gains_from_policy N_total home_id case_id AggC
        AggC = eye(N_total);
                 
        f_Read_Raw_Data_T4
        f_Balance_Data_RE

        lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
        Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
        Ri3D=repmat(sum(sum(Xjik_3D./((1+mu_k3D).*(1+tjik_3D)),2),3), [ 1 N S]) ;
        e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
        
home_id =  country_id;     
T0=[ones(N,1); ones(N,1); 1*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
target = @(X) First_Best(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id, case_id);
options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',inf,'TolFun',1e-12,'TolX',1e-16, 'algorithm','levenberg-marquardt');
X_sol=fsolve(target,T0, options);
[ ~, Gains_from_policy(country_id,case_id)] = First_Best(X_sol, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id, case_id); 

end
end

save('output/temp/tab_V1.mat','Gains_from_policy')


%% --------------------------------------------------------------------------------------------------------
%            Print Output and save as 'Table_Gains_from_Trade_Policy.tex'
% --------------------------------------------------------------------------------------------------------
        load output/temp/tab_V1.mat
        [num, text, raw] = xlsread('Country_List.xlsx');
        % Names of countries start with raw 3 of column 1:
        countries = text(1:end-1, 1);
        % Fix the last name, which is an aggregation of several countries
        %countries(end) = cellstr('RoW');
        
        Error = 100*((repmat(Gains_from_policy(:,1),1,3)- Gains_from_policy)./Gains_from_policy);
        Table = [Gains_from_policy(:,1) Gains_from_policy(:,2) Error(:,2) Gains_from_policy(:,3) Error(:,3) ];
        

        tablePreamble = {...
        '\begin{tabular}{lccccccc}';
        ' \toprule';
        '& Exact Formula & & \multicolumn{2}{c}{Approximated Formula} & & \multicolumn{2}{c}{Small Open Economy Formula} \\';
        '\addlinespace[3pt]';
        '﻿\cline{4-5} \cline{7-8}';
        '\addlinespace[3pt]';
        'Country &';
        '\specialcell{$\Delta W$} &&';
        '\specialcell{$\Delta W$} &';
        '\specialcell{Error} &&';
        '\specialcell{$\Delta W$} &';
        '\specialcell{Error}  \\';

        '\midrule'
        };

        tableClosing = {...
        ' \bottomrule';
        '\end{tabular}'
        };

        fileID = fopen('output/Table_V1.tex', 'w');

        %%% TABLE PREAMBLE   %%%
        for i = 1:size(tablePreamble)
            fprintf(fileID, '%s\n', char(tablePreamble(i)));
        end

         %%%  COLUMNS WITH RESULTS %%%
        for i = [3 11 32 33 43]
            fprintf(fileID, '%s & ', char(countries(i)));
            fprintf(fileID, '%1.4f\\%% && ', Table(i, 1));
            fprintf(fileID, '%1.4f\\%% & ', Table(i, 2));
            fprintf(fileID, '%1.2f\\%% &&', Table(i, 3));
             fprintf(fileID, '%1.4f\\%% & ', Table(i, 4));
            fprintf(fileID, '%1.2f\\%% \\\\', Table(i, 5));
        end

%         %%%  WRITE AVERAGES %%%
%         fprintf(fileID, ' \\addlinespace[3pt]\n');
%         avg = mean(Table);
%         fprintf(fileID, '\\textbf{Average} & ');
%         fprintf(fileID, '%1.2f\\%% & ', avg(1));
%         fprintf(fileID, '%1.2f\\%% & ', avg(2));
%         fprintf(fileID, '%1.2f\\%% && ', avg(3));
%         fprintf(fileID, '%1.2f\\%% & ', avg(4));
%         fprintf(fileID, '%1.2f\\%% & ', avg(5));
%         fprintf(fileID, '%1.2f\\%% \\\\', avg(6));
            
        %%% TABLE CLOSING  %%%
        for i = 1:size(tableClosing)
            fprintf(fileID, '%s\n', char(tableClosing(i)));
        end

        fclose(fileID);
        
        delete output/temp/tab_V1.mat

 %% --------------  FUNCTIONS -------------------%%
 function [ceq, gains] = First_Best(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D_app, id, case_id)

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
%        Total Income = Total Sales
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
      

    elseif case_id == 2
        
    mu_avg = Profit./(wi_h.*Ri3D(:,1,1));
    mu_avg_3D =  repmat(mu_avg, [1 N S]);
    d_mu = (mu_k3D - mu_avg_3D)./(1 + mu_k3D);
    
    AUX4 = AUX2.*e_ik3D.*(Yj_h3D.*Yj3D)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D));
    AUX5 = AUX4./repmat(sum(sum(AUX4,2),3), [1 N S]);
    AUX6_A = repmat(sum(sum(  - d_mu.*AUX5.*(1 + (sigma_k3D-1).*(1-AUX2)),3),2),[1 N S]) ...
            - repmat(sum( - d_mu.*AUX5.*(1 + (sigma_k3D-1).*(1-AUX2)),3), [1 1 S]);
        
    AUX6_B = repmat(sum(d_mu.*AUX5.*((sigma_k3D-1).*(1-AUX2)),3),[1 1 S]) ;
    w_adj = repmat(sum(sum(AUX4,3),2),[1 N S]);    
    adjust = permute(d_mu.*(w_adj./permute(w_adj, [2 1 3])).*AUX6_B, [2 1 3]) ;  
        
    omega =   -d_mu.*(repmat(sum(AUX5,3), [1 1 S]) - adjust)./(1 + AUX6_A) ;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %--------------------------
    else

    omega = zeros(N,N,S);

    end

t_pred = omega; 
ERR3 = reshape(tjik_3D([1:id-1 id+1:N],id,:) - t_pred([1:id-1 id+1:N],id,:), (N-1)*S,1) ;
% ------------------------------------------------------------------
%               Optimal Export Tax Formula: Theorem 1
% ------------------------------------------------------------------

if case_id == 1 || case_id == 2
    
AUX7=zeros(N,N,S);
omega_prime = permute(omega,[2 1 3]).*repmat(eye(N)==0,[1 1 S]);

for s=1:S
    AUX7(:,:,s)= omega_prime(:,:,s)* AUX2(:,:,s);
end
subsidy = AUX7./(1-AUX2);
x_pred  = (1 + 1./((sigma_k3D-1).*(1-AUX2)))./(1+subsidy); 

else
    
x_pred  = 1 + 1./(sigma_k3D-1); 

end
    
ERR4 = reshape(xjik_3D(id,[1:id-1 id+1:N],:) - (x_pred(id,[1:id-1 id+1:N],:) - 1), (N-1)*S,1);
% ------------------------------------------------------------------

ceq= [ERR1' ERR2' ERR3' ERR4'];

Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX0,1)),3))';
Wi_h = Yi_h./Pi_h;
gains = 100*(Wi_h(id)-1);

end


