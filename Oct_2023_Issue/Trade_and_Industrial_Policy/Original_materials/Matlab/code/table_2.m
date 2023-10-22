clear;
clc

% ------------------------------------------------------------------
%          Description of Variables
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

sigma = [1.5  3]; sigma_k3D = repmat(reshape(sigma,1,1,S), [N N 1]); %sector 2 is high markup
gamma = [3  6]; mu_k3D = repmat(reshape(1./(gamma-1),1,1,S), [N N 1]); %sector 2 is high markup 
e_ik3D = (1/S)*ones(N,N,S);
country_id = 1;

lambda_jik = [ 0.6  0.4 ; ...
               0.4  0.6]; 
lambda_jik3D = repmat(lambda_jik, [1 1 S]);
Yi3D = repmat([100; 100], [1 N S]);   tjik_3D = zeros(N,N,S);
Ri3D=repmat(sum(sum(lambda_jik3D.*e_ik3D.*permute(Yi3D,[2 1 3])./(1+tjik_3D),2),3), [1 N S]) ;
X = lambda_jik3D .* e_ik3D .* permute(Yi3D,  [2 1 3]);
rik3D = repmat(sum(X,2), [1 N 1])./repmat(sum(sum(X,2),3), [1 N S]);

T0=[ones(N,1); ones(N,1); ones(N*S,1)];
options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',inf,'TolFun',1e-12,'TolX',1e-14); 
target = @(X) Unilateral_Industrial_Policy_FE(X, N ,S, ...
    Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, country_id);
X_sol=fsolve(target,T0, options);
[~, unilateral] = Unilateral_Industrial_Policy_FE(X_sol, N , S, ...
    Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, country_id);

options = optimset('Display','iter','MaxFunEvals',inf,'MaxIter',inf,'TolFun',1e-12,'TolX',1e-14);
target = @(X) Multilateral_Industrial_Policy_FE(X, N ,S, ...
    Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, country_id);
X_sol=fsolve(target,T0, options);
[~, multilateral] = Multilateral_Industrial_Policy_FE(X_sol, N , S,...
    Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, rik3D, mu_k3D, country_id);
      

 table_A = {...
        '\vspace{-0.2in}';
        '\begin{center}';
        '\setlength{\extrarowheight}{4pt}';
        '\begin{adjustbox}{width=0.8\textwidth}';
        '\begin{tabular}{*{4}{c|}}'  ;    
        '\multicolumn{2}{c}{} & \multicolumn{2}{c}{Country $j$ (\%$\Delta W_j$)} \\';
        '\cline{3-4}' ;
        '\multicolumn{1}{c}{} &  & $\textbf{s}_j=\textbf{0}$ & $\textbf{s}_j=\boldsymbol{\mu}$ \\';
        '\cline{2-4}       \multirow{2}*{Country $i$ (\%$\Delta W_i)$}  &';
        '$\textbf{s}_i=\textbf{0}$ & $(\; 0\% \; , \; 0\% \;) $ & $(\;';
        };
    
table_B = {...
        '\cline{2-4}'     
        '& $\textbf{s}_i=\boldsymbol{\mu}$ & $(\;'
        };
    
table_C = {...
        '\cline{2-4}'     
        '\end{tabular}'
        '\end{adjustbox}'
        '\end{center}'
        };
    
    fileID = fopen('Output/Table_2.tex', 'w');
      for i = 1:size(table_A)
            fprintf(fileID, '%s\n', char(table_A(i)));
      end
        
      fprintf(fileID, '%1.1f\\%% \\; , \\;', unilateral(2));
      fprintf(fileID, '%1.1f\\%% \\;)$ \\\\ ', unilateral(1));
      
    for i = 1:size(table_B)
            fprintf(fileID, '%s\n', char(table_B(i)));
    end
      
            
      fprintf(fileID, '%1.1f\\%% \\; , \\;', unilateral(1));
      fprintf(fileID, '%1.1f\\%% \\;)$ &  $(\\;', unilateral(2));
            fprintf(fileID, '%1.1f\\%% \\; , \\;', multilateral(1));
      fprintf(fileID, '%1.1f\\%% \\;)$ \\\\ ', multilateral(2));
      
   for i = 1:size(table_C)
            fprintf(fileID, '%s\n', char(table_C(i)));
   end
    
fclose(fileID);  


tex_filename = 'output/Table_2.tex';
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
    '\usepackage{array}',
    '\usepackage{adjustbox}',
    '\usepackage{amsmath, bm}',
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
document_filename = 'output/Table_2_standalone.tex';
fid = fopen(document_filename, 'w');
fprintf(fid, '%s', document);
fclose(fid);

%--------------------------------------------------------------------------------%    
    %%                       FUNCTIONS
%--------------------------------------------------------------------------------%   
    

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

AUX00 = e_ik3D.*repmat(sum(AUX0).^(1.15./(1-sigma_k3D(1,:,:))), [N 1 1]);
e_ik3D = AUX00./repmat(sum(AUX00,3),[ 1 1 S]);

AUX3 = AUX2.*e_ik3D.*(Yj_h3D.*Yj3D)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D));

AUX4 = rik_h3D.*rik3D.*wi_h.*Ri3D;
ERR1_3D = sum(AUX3,2)-AUX4(:,1,:);
ERR1 = reshape(ERR1_3D,N*S,1);
% replace one excess equation with normalization,w^=w'/w=1, where w=sum_i(wi'*Li)/sum(wi*Li)
ERR1(N*S,1) = sum(Ri3D(:,1,1).*(wi_h-1));  

% ------------------------------------------------------------------
%                    Total Income = Total Sales
% -------------------------------------------------------------------
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./...
                ((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = sum(sum(R_M,3),1)' + sum(sum(R_X,3),2)+ ...
                        (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);

% ------------------------------------------------------------------
%                   Sum of Revenue Shares = 1
% ------------------------------------------------------------------
ERR3_3D=sum(rik_h3D.*rik3D,3);
ERR3=100*(ERR3_3D(:,1)-1);
% ------------------------------------------------------------------


ceq= [ERR1' ERR2' ERR3'];

Pi_h = sum(e_ik3D(1,:,:).*(sum(AUX0,1).^(1.15./(1-sigma_k3D(1,:,:)))),3)';
gains = 100*(Yi_h./Pi_h-1)';

end

function [ceq, gains] = Multilateral_Industrial_Policy_FE(X, N ,S, ...
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
 
 sik_3D=(1./(1+mu_k3D)) - 1; sik_h3D= 1 + sik_3D; 


% ------------------------------------------------------------------
%        Wage Income = Total Sales net of Taxes and Profits
% ------------------------------------------------------------------
taujik_h3D = tjik_h3D.*xjik_h3D.*sik_h3D;
pjik_h3D = wi_h3D.*taujik_h3D.*(rik_h3D.^ (-mu_k3D));
AUX0 = lambda_jik3D.*(pjik_h3D.^(1-sigma_k3D));
AUX1 = repmat(sum(AUX0,1),[N 1 1]);
AUX2 = AUX0./AUX1;

AUX00 = e_ik3D.*repmat(sum(AUX0).^(1.15./(1-sigma_k3D(1,:,:))), [N 1 1]);
e_ik3D = AUX00./repmat(sum(AUX00,3),[ 1 1 S]);
AUX3 = AUX2.*e_ik3D.*(Yj_h3D.*Yj3D)./((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D));

AUX4 = rik_h3D.*rik3D.*wi_h.*Ri3D;
ERR1_3D = sum(AUX3,2)-AUX4(:,1,:);
ERR1 = reshape(ERR1_3D,N*S,1); 
% replace one excess equation with normalization,w^=w'/w=1, where w=sum_i(wi'*Li)/sum(wi*Li)
ERR1(N*S,1) = sum(Ri3D(:,1,1).*(wi_h-1));  

% ------------------------------------------------------------------
%                  Total Income = Total Sales
% -------------------------------------------------------------------
R_M = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
R_X = AUX2.*e_ik3D.*(((1+xjik_3D).*(1+sik_3D)-1)./...
             ((1+tjik_3D).*(1+xjik_3D).*(1+sik_3D))).*Yj_h3D.*Yj3D;

ERR2 = sum(sum(R_M,3),1)' + sum(sum(R_X,3),2)+ ...
                     (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);

% ------------------------------------------------------------------
%                   Sum of Revenue Shares = 1
% ------------------------------------------------------------------
ERR3_3D=sum(rik_h3D.*rik3D,3);
ERR3=100*(ERR3_3D(:,1)-1); 
% ------------------------------------------------------------------

ceq= [ERR1' ERR2' ERR3'];

Pi_h = sum(e_ik3D(1,:,:).*(sum(AUX0,1).^(1.15./(1-sigma_k3D(1,:,:)))),3)';
gains = 100*(Yi_h./Pi_h-1)';

end