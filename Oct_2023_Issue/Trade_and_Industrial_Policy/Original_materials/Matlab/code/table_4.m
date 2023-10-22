clear;
clc

%% -------- Calculate the Gains from Unilateral Policy ------------%%

%------------------------------------------------------------        
%    ~~~~~~~~     Read and Prepare Data     ~~~~~~~~
%------------------------------------------------------------
%                 Description of Variables
% -----------------------------------------------------------
%   N: number of countries;  S: umber of industries 
%   Yi3D: national expenditure ~ national income
%   Ri3D: national wage revneues ~ sales net of tariffs and profits 
%   e_ik3D: industry-level expenditure share (C-D weight)
%   lambda_jik: within-industry expenditure share
%   mu: industry-level scale elasticity
%   sigma: industry-level CES parameter (sigma-1 ~ trade elasticity)
%   tjik_3D_app: applied tariff
% ------------------------------------------------------------
     N_total = 44; AggC = eye(N_total); % N_total ~ total number of countries including RoW

     f_Read_Raw_Data_T4
     f_Balance_Data_RE
     
    lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
    Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
    Ri3D=repmat(sum(sum(Xjik_3D./((1+mu_k3D).*(1+tjik_3D)),2),3), [ 1 N S]) ;
    e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
    save input/temp/tab4_data_RE.mat
    
    clearvars
    N_total = 44; AggC = eye(N_total); % N_total ~ total number of countries including RoW
    
    f_Read_Raw_Data_T4
    f_Balance_Data_FE
    
    lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
    Ri3D=repmat(sum(sum(Xjik_3D./(1+tjik_3D),2),3), [ 1 N S]) ;
    rik3D = repmat(sum(Xjik_3D./(1+tjik_3D),2), [1 N 1])./Ri3D;
    Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
    e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
    save input/temp/tab4_data_FE.mat
    
Gains_from_policy = zeros(43,6);

for country_id= 1:43
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
%~~~~~~~~~~~~~~~~~~     GAINS FROM POLICY: RESTRICTED ENTRY     ~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
load input/temp/tab4_data_RE   
home_id = country_id;    
                
T0=[ones(N,1); ones(N,1); 1*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
target = @(X) f_First_Best_RE(X, N ,S, ...
          Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id, 1);
options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',inf, ...
                    'TolFun',1e-12,'TolX',1e-16, 'algorithm','levenberg-marquardt');
X_sol_1st = fsolve(target,T0, options);
[ ~, Gains_from_policy(country_id,1)] = f_First_Best_RE(X_sol_1st, N ,S, ...
       Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id, 1); 
               
target = @(X) f_Second_Best_RE(X, N ,S, ...
       Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id, 1);
X_sol_2nd=fsolve(target,T0, options);
[~, Gains_from_policy(country_id,2)] = f_Second_Best_RE(X_sol_2nd, N ,S, ...
       Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id, 1);


T0=[ones(N,1); ones(N,1); 1.5*ones((N-1)*S,1)];
target = @(X) f_Third_Best_RE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id, 0);
X_sol_3rd=fsolve(target,T0, options);
[~, Gains_from_policy(country_id,3)] = f_Third_Best_RE(X_sol_3rd, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id, 0);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
%~~~~~~~~~~~~~~~~~~        GAINS FROM POLICY: FREE ENTRY        ~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    clearvars -except country_id Gains_from_policy N_total home_id X_sol_1st X_sol_2nd X_sol_3rd
        
     if ismember(country_id, [9 39])
         AggC = [ones(1,N_total); zeros(1,N_total)];
         AggC(2,country_id)=1; AggC(1,country_id)=0;
         home_id = 2;
         
         f_Read_Raw_Data_T4
         f_Balance_Data_FE
         
         lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
         Ri3D=repmat(sum(sum(Xjik_3D./(1+tjik_3D),2),3), [ 1 N S]) ;
         rik3D = repmat(sum(Xjik_3D./(1+tjik_3D),2), [1 N 1])./Ri3D;
         Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
         e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
         
     else
       load input/temp/tab4_data_FE 
     end  
    
T0=[X_sol_1st(1:2*N); 1.1*ones(N*S,1); X_sol_1st(2*N+1:end)];
target = @(X) f_First_Best_FE_Fast(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, home_id);
options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',50,'TolFun',1e-8,'TolX',1e-8);
X_sol=fsolve(target,T0, options);
[ ~, Gains_from_policy(country_id,4)] = f_First_Best_FE_Fast(X_sol, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, home_id); 

    clearvars -except country_id Gains_from_policy N_total home_id X_sol_1st X_sol_2nd X_sol_3rd
    AggC = [ones(1,N_total); zeros(1,N_total)];
    AggC(2,country_id)=1; AggC(1,country_id)=0;
    
    f_Read_Raw_Data_T4
    f_Balance_Data_FE
       
    lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
    Ri3D=repmat(sum(sum(Xjik_3D./(1+tjik_3D),2),3), [ 1 N S]) ;
    rik3D = repmat(sum(Xjik_3D./(1+tjik_3D),2), [1 N 1])./Ri3D;
    Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); home_id = 2;
    e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
    

LB=[0.75*ones(N,1); 0.75*ones(N,1); 0.25*ones(N*S,1); 0.75*ones((N-1)*S,1); 0.75*ones((N-1)*S,1)];
UB=[1.5*ones(N,1); 1.5*ones(N,1); 4*ones(N*S,1);  2*ones((N-1)*S,1);4*ones((N-1)*S,1)];
    if ismember(country_id, 39)
        T0=[ones(N,1); ones(N,1); 1*ones(N*S,1); 1*ones((N-1)*S,1); 1.5*ones((N-1)*S,1)];
    else
        T0=[ones(N,1); ones(N,1); 1*ones(N*S,1); 1.25*ones((N-1)*S,1); 1.25*ones((N-1)*S,1)];
    end
target = @(X) f_Obj_MPEC_FE(X, N , S, ...
            e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id);
constraint = @(X) f_Const_MPEC_FE(X, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, home_id);
options = optimoptions(@fmincon,'Display','off','MaxFunEvals',inf,'MaxIter',5000,...
                        'TolFun',1e-8,'TolX',1e-8, 'TolCon', 1e-8, 'algorithm','sqp');
[~, temp]=fmincon(target,T0,[],[],[],[],LB,UB,constraint,options);
Gains_from_policy(country_id,5) = - temp;


LB=[0.75*ones(N,1); 0.75*ones(N,1); 0.25*ones(N*S,1); 0.75*ones((N-1)*S,1); ones((N-1)*S,1)];
UB=[1.5*ones(N,1); 1.5*ones(N,1); 4*ones(N*S,1); 2*ones((N-1)*S,1); ones((N-1)*S,1)];
T0=[ones(N,1); ones(N,1); 1*ones(N*S,1); 1.25*ones((N-1)*S,1); ones((N-1)*S,1)];
target = @(X) f_Obj_MPEC_FE(X, N , S, ...
                e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D, home_id);
constraint = @(X) f_Const_MPEC_FE(X, N ,S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, home_id);
options = optimoptions(@fmincon,'Display','off','MaxFunEvals',inf,...
        'MaxIter',5000,'TolFun',1e-8,'TolX',1e-8, 'TolCon', 1e-8, 'algorithm','sqp' );
[~, temp]=fmincon(target,T0,[],[],[],[],LB,UB,constraint,options);
Gains_from_policy(country_id,6) = - temp;
        
end
 
save('output/temp/gains_from_policy_t4.mat','Gains_from_policy')
% uncomment the following line to export output results in CSV format
%writematrix(Gains_from_policy, 'output/temp/gains_from_policy_t4.csv')

%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ~~~~~~~~~     Calculate the Cost of Retaliation      ~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
clear;
clc
Gains_from_policy = zeros(43,2);

for country_id=1:43
%---------------------------------------------------------------     
%                       RESTRICTED ENTRY 
%--------------------------------------------------------------- 

    clearvars -except country_id Gains_from_policy N_total home_id
    N_total = 44; AggC = eye(N_total); % N_total ~ total number of countries including RoW
    
    f_Read_Raw_Data_T4
    f_Balance_Data_RE
    
    home_id = country_id;
    lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
    Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
    Ri3D=repmat(sum(sum(Xjik_3D./((1+mu_k3D).*(1+tjik_3D)),2),3), [ 1 N S]) ;
    e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
                
T0=[ones(N,1); ones(N,1)];
target = @(X) f_Retaliation_RE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id);
options = optimset('Display','iter','MaxFunEvals',inf,...
        'MaxIter',inf,'TolFun',1e-12,'TolX',1e-16, 'algorithm','levenberg-marquardt'); 
X_sol_1st = fsolve(target,T0, options);
[ ~, Gains_from_policy(country_id,1)] = f_Retaliation_RE(X_sol_1st, N ,S, ...
            Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D, home_id);
        
%---------------------------------------------------------------     
%                            FREE ENTRY 
%--------------------------------------------------------------- 
clearvars -except country_id Gains_from_policy N_total home_id X_sol_1st X_sol_2nd X_sol_3rd
    AggC = [ones(1,N_total); zeros(1,N_total)];
    AggC(2,country_id)=1; AggC(1,country_id)=0;

    f_Read_Raw_Data_T4
    f_Balance_Data_FE
    
    home_id = 2 - (country_id==1);
    lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
    Ri3D=repmat(sum(sum(Xjik_3D./(1+tjik_3D),2),3), [ 1 N S]) ;
    rik3D = repmat(sum(Xjik_3D./(1+tjik_3D),2), [1 N 1])./Ri3D;
    Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); 
    e_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
                
T0=[ones(N,1); ones(N,1); ones(N*S,1)];
target = @(X) f_Retaliation_FE(X, N ,S, ...
        Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, home_id);
options = optimset('Display','iter','MaxFunEvals',inf,...
                    'MaxIter',inf,'TolFun',1e-12,'TolX',1e-16); 
X_sol=fsolve(target,T0, options);
[ ~, Gains_from_policy(country_id,2)] = f_Retaliation_FE(X_sol, N ,S, ...
          Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D, home_id); 


end

Cost_of_retaliation = Gains_from_policy;
clearvars -except Cost_of_retaliation
load output/temp/Gains_from_policy_t4

%% ---------------------------------------------------------------------------------
%
%                   Print Output and save as 'Table_4.tex'
%
%-----------------------------------------------------------------------------------

        N=44;
        [num, text, raw] = xlsread('Country_List.xlsx');
        countries = text(1:end-1, 1);
       %Fix the last name, which is an aggregation of several countries
       % countries(end) = cellstr('RoW');

        Table = [Gains_from_policy(1:43,1:3) Cost_of_retaliation(:,1)  ...
                    Gains_from_policy(1:43,4:6) Cost_of_retaliation(:,2)];

        tablePreamble = {...
        '\begin{tabular}{lccccccccc}';
        ' \toprule';
        '& \multicolumn{4}{c}{Restricted Entry} & & \multicolumn{4}{c}{Free Entry} \\';
        '\addlinespace[3pt]';
        '﻿\cline{2-5} \cline{7-10}';
        '\addlinespace[3pt]';
        'Country &';
        '\specialcell{1st-Best} &';
        '\specialcell{2nd best \\ trade tax} &';
        '\specialcell{3rd best \\ import tax} &';
        '\specialcell{post \\ retaliation} & &';
        '\specialcell{1st-Best} &';
        '\specialcell{2nd best \\ trade tax} &';
        '\specialcell{3rd best \\ import tax} &';
        '\specialcell{post \\ retaliation} \\';

        '\midrule'
        };

        tableClosing = {...
        ' \bottomrule';
        '\end{tabular}'
        };

        fileID = fopen('output/Table_4.tex', 'w');

        %% TABLE PREAMBLE   %%%
        for i = 1:size(tablePreamble)
            fprintf(fileID, '%s\n', char(tablePreamble(i)));
        end

         %%  COLUMNS WITH RESULTS %%%
        for i = 1:N-1
            fprintf(fileID, '%s & ', char(countries(i)));
            fprintf(fileID, '%1.2f\\%% & ', Table(i, 1));
            fprintf(fileID, '%1.2f\\%% & ', Table(i, 2));
            fprintf(fileID, '%1.2f\\%% &', Table(i, 3));
            fprintf(fileID, '%1.2f\\%% &&', Table(i, 4));
             fprintf(fileID, '%1.2f\\%% & ', Table(i, 5));
            fprintf(fileID, '%1.2f\\%% & ', Table(i, 6));
            fprintf(fileID, '%1.2f\\%% & ', Table(i, 7));
            fprintf(fileID, '%1.2f\\%% \\\\', Table(i, 8));
        end

        %%  WRITE AVERAGES %%%
        fprintf(fileID, ' \\addlinespace[3pt]\n');
        avg = mean(Table);
        fprintf(fileID, '\\textbf{Average} & ');
        fprintf(fileID, '%1.2f\\%% & ', avg(1));
        fprintf(fileID, '%1.2f\\%% & ', avg(2));
        fprintf(fileID, '%1.2f\\%% & ', avg(3));
        fprintf(fileID, '%1.2f\\%% && ', avg(4));
        fprintf(fileID, '%1.2f\\%% & ', avg(5));
        fprintf(fileID, '%1.2f\\%% & ', avg(6));
        fprintf(fileID, '%1.2f\\%% & ', avg(7));
        fprintf(fileID, '%1.2f\\%% \\\\', avg(8));
            
        %% TABLE CLOSING  %%%
        for i = 1:size(tableClosing)
            fprintf(fileID, '%s\n', char(tableClosing(i)));
        end

        fclose(fileID);     
        
tex_filename = 'output/Table_4.tex';
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
document_filename = 'Output/Table_4_standalone.tex';
fid = fopen(document_filename, 'w');
fprintf(fid, '%s', document);
fclose(fid);

        
%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~           AUXILIARY FUNCTION           ~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [ceq, Gains] = f_First_Best_FE_Fast(X, N ,S, Yi3D, Ri3D, e_ik3D, ...
                        sigma_k3D, lambda_jik3D, rik3D, mu_k3D, tjik_3D_app, id)

% ------------------------------------------------------------------
%        Description of Inputs
% ------------------------------------------------------------------
%   N: number of countries;  S: umber of industries 
%   Yi3D: national expenditure ~ national income
%   Ri3D: national wage revneues ~ sales net of tariffs and profits 
%   e_ik3D: industry-level expenditure share (C-D weight)
%   lambda_jik: within-industry expenditure share
%   mu: industry-level scale elasticity
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
 tjik_3D = 0 ;
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);
 
 xjik_3D = ones(N,N,S);
 xjik_3D(id,[1:id-1 id+1:end],:) = sigma_k3D(id,[1:id-1 id+1:end],:)...
                                    ./(sigma_k3D(id,[1:id-1 id+1:end],:)-1);
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
ERR1_3D = sum(AUX3,2)-AUX4(:,1,:); % Eq.31.a in Section 5
ERR1 = reshape(ERR1_3D,N*S,1); %/min(TEMP(:)); 
ERR1(N*S,1) = sum(Ri3D(:,1,1).*(wi_h-1));  % replace one excess equation with normalization,w^=w'/w=1, where w=sum_i(wi'*Li)/sum(wi*Li)
% ------------------------------------------------------------------
%                   Total Income = Total Sales
% ------------------------------------------------------------------
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = sum(sum(R_M,3),1)' + sum(sum(R_X,3),2)+ (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);

% ------------------------------------------------------------------
%                   Sum of Revenue Shares = 1
% ------------------------------------------------------------------
ERR3_3D=sum(rik_h3D.*rik3D,3);
ERR3=100*(ERR3_3D(:,1)-1);
% ------------------------------------------------------------------

ceq= [ERR1' ERR2' ERR3'];

Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX0,1)),3))';
Wi_h = Yi_h./Pi_h;
Gains = 100*(Wi_h(id)-1);

end
