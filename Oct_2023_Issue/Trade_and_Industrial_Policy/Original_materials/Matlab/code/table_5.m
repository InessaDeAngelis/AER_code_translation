clear;
clc

% ------------------------------------------------------------------
%        Description of Variables
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
Gains_deep_agreement = zeros(44,2); 
Gains_unilateral = zeros(44,2); 
N_total = 44; AggC = eye(N_total);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       FREE ENTRY CASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
%------------------------- Prepare Data ----------------------------         
        f_Read_Raw_Data_T5
        f_Balance_Data_FE
        
    lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
    Ri3D=repmat(sum(sum(Xjik_3D./(1+tjik_3D),2),3), [ 1 N S]) ;
    rik3D = repmat(sum(Xjik_3D./(1+tjik_3D),2), [1 N 1])./Ri3D;
    Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
    e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
           
%------------------------- Deep Agreement ----------------------------    
options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',50,...
            'TolFun',1e-12,'TolX',1e-16, 'algorithm','levenberg-marquardt'); % 
target = @(X) Cooperative_FE(X, N ,S, ...
                        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D);
T0=[1.75*ones(N,1);  0.75*ones(N,1); 1*ones(N*S,1)]; 
 X_sol=fsolve(target,T0, options);

[~, Gains_deep_agreement(:,2)] = Cooperative_FE(X_sol, N ,S, ...
                        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D);

%%--------------- Unilateral Scale Correction ------------------------- 
for country_id = 1:44
 
        options = optimset('Display','iter','MaxFunEvals',inf,...
        'MaxIter',100, 'TolFun',1e-12,'TolX',1e-16);
        T0=[1.2*ones(N,1);  0.85*ones(N,1); 1*ones(N*S,1)]; 
        
    target = @(X) Unilateral_FE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, country_id); 
    X_sol=fsolve(target,T0, options);

    [~, Gains_unilateral(country_id,2)] = Unilateral_FE(X_sol, N ,S, ... 
             Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, country_id);
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       RESTRICTED ENTRY CASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------- Prepare Data ---------------------------- 
        clearvars -except Gains_deep_agreement Gains_unilateral
        N_total = 44; AggC = eye(N_total);
        
        f_Read_Raw_Data_T4
        f_Balance_Data_RE
        
        lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
        Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
        Ri3D=repmat(sum(sum(Xjik_3D./((1+mu_k3D).*(1+tjik_3D)),2),3), [ 1 N S]) ;
        e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
        
%------------------------- Deep Agreement ----------------------------     
options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',1000,...
                'TolFun', 1e-12,'TolX',1e-16, 'algorithm','levenberg-marquardt'); 
target = @(X) Cooperative_RE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D);
T0=[1.2*ones(N,1);0.85*ones(N,1)]; 
X_sol=fsolve(target,T0, options);

[~ , Gains_deep_agreement(:,1)] = Cooperative_RE(X_sol, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D);


%%--------------- Unilateral Markup Correction -------------------------
for country_id=1:43

options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',1000,...
            'TolFun',1e-12,'TolX',1e-16);
target = @(X) Unilateral_RE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, country_id);
T0=[1.2*ones(N,1);  0.85*ones(N,1)]; 
X_sol=fsolve(target,T0, options);

[~ , Gains_unilateral(country_id,1)] = Unilateral_RE(X_sol, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, country_id);

end 

save('output/temp/gains_from_policy_t5.mat','Gains_unilateral', 'Gains_deep_agreement');
% uncomment the following line to export output results in CSV format
% writematrix([Gains_unilateral Gains_deep_agreement],'output/temp/gains_from_policy_t5.csv') 

Table = [mean(Gains_unilateral(1:43,1)) mean(Gains_deep_agreement(1:43,1)) ...
            mean(Gains_unilateral(1:43,2)) mean(Gains_deep_agreement(1:43,2))];
tablePreamble = {...
        '\begin{tabular}{lccccccc}';
        ' \toprule';
        '&&    \multicolumn{2}{c}{Restricted Entry}   & \phantom{abc} &   \multicolumn{2}{c}{Free Entry}  \\';
        '﻿\cmidrule{3-4}    \cmidrule{6-7}';
        '&&          \specialcell{Unilateral} &  \specialcell{Multilateral}  && \specialcell{Unilateral} &  \specialcell{Multilateral}  \\ ';
        '\midrule'
        };

        tableClosing = {...
        ' \bottomrule';
        '\end{tabular}'
        };

        fileID = fopen('output/Table_5.tex', 'w');
        
        for i = 1:size(tablePreamble)
         fprintf(fileID, '%s\n', char(tablePreamble(i)));
        end
        
        fprintf(fileID, '\\%% %s && ', '$\Delta W_{avg}$');
        fprintf(fileID, '%1.2f\\%% & ', Table(1,1));
        fprintf(fileID, '%1.2f\\%% && ', Table(1,2));
        fprintf(fileID, '%1.2f\\%% & ', Table(1,3));
        fprintf(fileID, '%1.2f\\%% \\\\ ', Table(1,4));
        
        for i = 1:size(tableClosing)
         fprintf(fileID, '%s\n', char(tableClosing(i)));
        end
        
        fclose(fileID);
              
               
    tex_filename = 'output/Table_5.tex';
    fid = fopen(tex_filename, 'r');
    latexTable = fread(fid, '*char')';
    fclose(fid);

    % Create the LaTeX document
    document_lines = {
        '\documentclass{article}',
        '\usepackage{booktabs}',
        '\newcommand{\specialcell}[2][c]{%',
        '\begin{tabular}[#1]{@{}c@{}}#2\end{tabular}}',
        '\usepackage{multirow}',
        '\usepackage[utf8]{inputenc}',
        '\usepackage{geometry}',
        '\geometry{a4paper, left=20mm, right=20mm, top=25mm, bottom=25mm}',
        '\begin{document}',
        '\begin{table}',
        '\centering',
        latexTable,
        '\end{table}',
        '\end{document}'
    };


    % Join the documents ----> Convert the string array to a character array
    document = join(document_lines, newline);
    document = char(document);

    % Save the LaTeX document (containig results) to a file
    document_filename = 'Output/Table_5_standalone.tex';
    fid = fopen(document_filename, 'w');
    fprintf(fid, '%s', document);
    fclose(fid);
        
%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~           AUXILIARY FUNCTION           ~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [ceq, gains] = Cooperative_FE(X, N ,S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D_app)

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
%           construct 3D cubes for change in taxes
% ------------------------------------------------------------------
 
 tjik_3D = tjik_3D_app; 
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);

 xjik_3D=ones(N,N,S); 
 xjik_h3D = xjik_3D; xjik_3D=xjik_3D-1 ;
 
sik_3D=(1./(1+mu_k3D)) - 1;
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
%                  Total Income = Total Sales
% ------------------------------------------------------------------
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./...
            ((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = sum(sum(R_M,3),1)' + sum(sum(R_X,3),2) + ...
                    (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);
                
% ------------------------------------------------------------------
%                   Sum of Revenue Shares = 1
% ------------------------------------------------------------------
ERR5_3D=sum(rik_h3D.*rik3D,3);
ERR5=100*(ERR5_3D(:,1)-1); 
% ------------------------------------------------------------------

ceq= [ERR1' ERR2' ERR5'];

Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX0,1)),3))';
% Calculate the change in welfare
Wi_h = Yi_h./Pi_h;
gains = 100*(Wi_h(1:N)-1);

end

function [ceq, gains] = Unilateral_FE(X, N ,S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D_app, id)

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
%           construct 3D cubes for change in taxes
% ------------------------------------------------------------------
 
 tjik_3D = tjik_3D_app; 
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);

 xjik_3D=ones(N,N,S); 
 xjik_h3D = xjik_3D; xjik_3D=xjik_3D-1 ;
 
sik_3D=zeros(N,N,S); sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
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
%                   Total Income = Total Sales
% ------------------------------------------------------------------
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = sum(sum(R_M,3),1)' + sum(sum(R_X,3),2)+ (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);

% ------------------------------------------------------------------
%                   Sum of Revenue Shares = 1
% ------------------------------------------------------------------
ERR5_3D=sum(rik_h3D.*rik3D,3);
ERR5=100*(ERR5_3D(:,1)-1); 
% ------------------------------------------------------------------

ceq= [ERR1' ERR2' ERR5'];

Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX0,1)),3))';
% Calculate the change in welfare
Wi_h = Yi_h(id)./Pi_h(id);
gains = 100*(Wi_h-1);

end

function [ceq, gains] = Cooperative_RE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D_app)

wi_h=abs(X(1:N));    % abs(.) is used avoid complex numbers...
Yi_h=abs(X(N+1:N+N));

% construct 3D cubes from 1D vectors
wi_h3D=repmat(wi_h,[1 N S]);
Yi_h3D=repmat(Yi_h,[1 N S]);
Yj_h3D=permute(Yi_h3D,[2 1 3]);
Yj3D=permute(Yi3D,[2 1 3]);

% ------------------------------------------------------------------
%           construct 3D cubes for change in taxes
% ------------------------------------------------------------------
 tjik_3D = tjik_3D_app; 
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);

 xjik_3D=ones(N,N,S); 
 xjik_h3D = xjik_3D; xjik_3D=xjik_3D-1 ;
 
sik_3D=(1./(1+mu_k3D)) - 1;
 sik_h3D= 1 + sik_3D; 
% ------------------------------------------------------------------
%        Wage Income = Total Sales net of Taxes and Profits
% ------------------------------------------------------------------
tau_h = tjik_h3D.*xjik_h3D.*sik_h3D;
AUX0 = lambda_jik3D.*((tau_h.*wi_h3D).^(1-sigma_k3D));
AUX1 = repmat(sum(AUX0,1),[N 1 1]);
AUX2 = AUX0./AUX1;
AUX3 = AUX2.*e_ik3D.*(Yj_h3D.*Yj3D)./...
            ((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D).*(1+mu_k3D));

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

ERR2 = Profit + sum(sum(R_M,3),1)' + ...
            sum(sum(R_X,3),2)+ (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);
% ------------------------------------------------------------------

ceq= [ERR1' ERR2'];


Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX0,1)),3))';
% Calculate the change in welfare
Wi_h = Yi_h./Pi_h;
gains = 100*(Wi_h(1:N)-1);

end

function [ceq, gains] = Unilateral_RE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D_app, id)

wi_h=abs(X(1:N));    % abs(.) is used avoid complex numbers...
Yi_h=abs(X(N+1:N+N));

% construct 3D cubes from 1D vectors
wi_h3D=repmat(wi_h,[1 N S]);
Yi_h3D=repmat(Yi_h,[1 N S]);
Yj_h3D=permute(Yi_h3D,[2 1 3]);
Yj3D=permute(Yi3D,[2 1 3]);

% ------------------------------------------------------------------
%           construct 3D cubes for change in taxes
% ------------------------------------------------------------------
 tjik_3D = tjik_3D_app; 
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);

 xjik_h3D = ones(N,N,S); xjik_3D=xjik_h3D-1 ;
 
sik_3D=zeros(N,N,S); sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
 sik_h3D= 1 + sik_3D; 
% ------------------------------------------------------------------
%        Wage Income = Total Sales net of Taxes and Profits
% ------------------------------------------------------------------
tau_h = tjik_h3D.*xjik_h3D.*sik_h3D;
AUX0 = lambda_jik3D.*((tau_h.*wi_h3D).^(1-sigma_k3D));
AUX1 = repmat(sum(AUX0,1),[N 1 1]);
AUX2 = AUX0./AUX1;
AUX3 = AUX2.*e_ik3D.*(Yj_h3D.*Yj3D)./...
            ((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D).*(1+mu_k3D));

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
% ------------------------------------------------------------------

ceq= [ERR1' ERR2'];

Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX0,1)),3))';
% Calculate the change in welfare
Wi_h = Yi_h(id)./Pi_h(id);
gains = 100*(Wi_h-1);

end
