%==========================================================================
% Step 01: this file reads WIOD data and computes the required
% cubes Yi3D, Yis3D, Xijs3D, Lijs3D (lambdas), Dj3d (trade deficits) and
% betas AND (!!!) aggregates sectors and countries (see lines 36-46)
%==========================================================================
N=44;   S=56;	% number of regions and sectors
%======================= Read the data from csv-file ======================
DATA=dlmread('WIOT2014.csv',','); %wiot11_row_sep12.csv  WIOT08_ROW_Apr12.csv
Zinit=DATA(1:2464,1:2464);	% extract data on intermediate input flows
X=DATA(1:2464,1:2684);	% extract data on both flows of intemediate and final goods
Rinit=sum(X,2);


%====================== Make the required corrections =====================
%... Adjustment #1: think about IO model and data as X=A*X+F+INV, where INV
% represents a vector of NEGATIVE changes in inventories (positive changes
% are a part of final demand vector, F. Now we have X=inv(I-A)*(F+INV). We
% need to convert reduction in inventories into increased output (i.e. we 
% can think about this exercise as the one that expands the time period, so 
% that now we also take the previous period production of these inventories,
% that are reduced, into account). Keeping F the same as in data, we set 
% INV=0 and recompute vector X and matrix of flows F

FIN=X(1:2464, 2465:2684);  % matrix of final demand and inventories adjustment
FINsum=sum(FIN,2);  % initial vector of final demand including negative INV
F=FIN.*(FIN>0); % positive component of final demand (becomes final demand after correcting for INV<0)
Fsum=sum(F,2); % initial final demand (remains the same)
A=Zinit/diag(Rinit+.000001.*(Rinit<=0.000001));    % matrix on direct input coefficients (small number is added to avoid NaN for zero-sectors)
R=(eye(N*S)-A)\(Fsum);  % compute a new vector of total output under zero decline in inventories
Z=A*diag(R);            % compute a new matrix of intermediate goods flows    


%====================== Aggregate sectors & countries =====================
%... For the aggregation scheme see the "AGG_MATRICES.ods" file.
% Loading matrices for aggregating sectors and countries
%AggC=dlmread('AGG_C.csv'); N=size(AggC,1);
AggS=dlmread('AGG_S.csv');  S=size(AggS,1); N=size(AggC,1);
CC=kron(AggC,AggS); % matrix for aggregating matrix of intermediate goods flows Z
FF=kron(AggC,eye(5));  % matrix for aggregating matrix of final demand F (Note: 5 catgeories of final demand)
Z=(CC) * (Z) * (CC');   % aggregated Z matrix
F=(CC) * (F) * (FF');   % aggregated F matrix
X=[Z,F];
R=sum(X,2);


%======================= Compute the required data ========================
ls=ones(S,1);	ln=ones(N,1);	l5=ones(5,1);   % summer vectors
AUX1=kron(eye(N),ls);	% aux matrix for summation over "k": ijsk -> ijs
AUX2=kron(eye(N),l5);
AUX=[AUX1;AUX2];
Xijs3D=permute(reshape(X*AUX,S,N,N),[2 3 1]); % Xijs -- flow of good "s" from "i" to "j"

PARAM=dlmread('AGG_P.csv');

epsilon_s=PARAM(:,2); epsilon_s([S+1:length(PARAM)])=[];    % drop elasticities for aggregated sectors: for initial sectors 5 and 4 elasticities are the same, while initial sectors 17:35 are non-tradable (also have the same elasticity)
epsilon_s(end,1)=10;   % set trade elasticities for non-tradables to 100
 
mu_s=PARAM(:,3); mu_s([S+1:length(PARAM)])=[];    % drop elasticities for aggregated sectors: for initial sectors 5 and 4 elasticities are the same, while initial sectors 17:35 are non-tradable (also have the same elasticity)
mu_s3D=reshape(kron((mu_s)',ones(N)),N,N,S);

if rho ~= 1
X = (mu_s - mean(mu_s))/norm(mu_s - mean(mu_s));
Y = 1./epsilon_s; Y = (Y - mean(Y))/norm(Y - mean(Y));
W = (Y'*X)*X; W_prep = Y - W; 
W = W/norm(W); W_prep = W_prep/norm(W_prep);
Y_new = rho*W + sqrt(1-rho^2)*W_prep;
epsilon_s = abs(1./Y_new).*(median(epsilon_s(1:end-1))./median(1./abs(Y_new(1:end-1))));
end

epsilon_s3D=reshape(kron(epsilon_s',ones(N)),N,N,S);
sigma_s3D = epsilon_s3D + 1;

save Input/TEMP/Step_1.mat N S Xijs3D mu_s3D sigma_s3D AggC;

clearvars -except country_id Gains_from_policy N_total home_id Gains_deep_agreement ...
            Gains_unilateral case_id X_sol_1st X_sol_2nd X_sol_3rd rho_vector k CORR COV
        
load Input/TEMP/Step_1.mat;
%load Input/tariff_2014_TRAINS.mat

T = dlmread('AGG_T.csv', ',');
t_3D = reshape(T(:,4), S, N_total, N_total)/100;
tjik_3D = permute(t_3D,[3 2 1]);

for s=1:S        
           AUX1 = AggC*tjik_3D(:,:,s)*AggC';
           AUX2 = AggC*ones(N_total,N_total)*AggC';
           t_new(:,:,s) = AUX1./AUX2;
end
t_new(repmat(eye(N)==1, [1 1 S])) = 0; tjik_3D = t_new;

%============================== SET SHOCKS ================================
        Xjik_3D = Xijs3D; Xjik_3D = Xjik_3D + 10*(Xjik_3D<10);
        lambda_jik3D=Xjik_3D./repmat(sum(Xjik_3D,1), [ N 1 1]) ; 
        sigma_k3D=sigma_s3D; mu_k3D=mu_s3D; 
        Yi3D=repmat(sum(sum(Xjik_3D,1),3)', [ 1 N S]); Ri3D=repmat(sum(sum(Xjik_3D./((1+tjik_3D).*(1+mu_k3D)),2),3), [ 1 N S]) ;
        beta_ik3D = repmat(sum(Xjik_3D,1), [ N 1 1])./ permute(Yi3D, [2 1 3]);
        

%============================= SOLVE THE MODEL ============================
X0=[ ones(N,1); ones(N,1)];
syst=@(X) BT_RE(X, N ,S, Yi3D, Ri3D, beta_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D);
options = optimset('Display','iter','MaxFunEvals',50000000,'MaxIter',100000,'TolFun',1e-10,'TolX',1e-10); %'Algorithm','trust-region-dogleg',
[x_fsolve,fval_fsolve]=fsolve(syst, X0, options);
max(abs(fval_fsolve))

wi_h=abs(x_fsolve(1:N));    % abs(.) is used avoid complex numbers...
Yi_h=abs(x_fsolve(N+1:N+N));

% construct 3D cubes from 1D vectors
wi_h3D=repmat(wi_h,[1 N S]);
Yi_h3D=repmat(Yi_h,[1 N S]);
Yj_h3D=permute(Yi_h3D,[2 1 3]);
Yj3D=permute(Yi3D,[2 1 3]);

% ------------------------------------------------------------------
%        Wage Income = Total Sales net of Taxes
% ------------------------------------------------------------------
AUX0 = lambda_jik3D.*( wi_h3D.^(1-sigma_k3D));
AUX1 = repmat(sum(AUX0,1),[N 1 1]);
AUX2 = AUX0./AUX1;
Xjik_3D = AUX2.*beta_ik3D.*(Yj_h3D.*Yj3D);
   
clearvars -except Xjik_3D sigma_k3D mu_k3D tjik_3D N S country_id Gains_from_policy N_total home_id ...
           Gains_deep_agreement Gains_unilateral case_id X_sol_1st X_sol_2nd X_sol_3rd rho_vector k CORR COV
       
       
%% ----------------------     FUNCTIONS   --------------------------%%       
       
function [ceq] = BT_RE(X, N ,S, Yi3D, Ri3D, e_ik3D, sigma_k3D, lambda_jik3D, mu_k3D, tjik_3D_app)

wi_h=abs(X(1:N));    % abs(.) is used avoid complex numbers...
Yi_h=abs(X(N+1:N+N));
tjik_3D = tjik_3D_app;

% construct 3D cubes from 1D vectors
wi_h3D=repmat(wi_h,[1 N S]);
Yi_h3D=repmat(Yi_h,[1 N S]);
Yj_h3D=permute(Yi_h3D,[2 1 3]);
Yj3D=permute(Yi3D,[2 1 3]);

% ------------------------------------------------------------------
%        Wage Income = Total Sales net of Taxes
% ------------------------------------------------------------------
AUX0 = lambda_jik3D.*(wi_h3D.^(1-sigma_k3D));
AUX1 = repmat(sum(AUX0,1),[N 1 1]);
AUX2 = AUX0./AUX1;
AUX3 = AUX2.*e_ik3D.*(Yj_h3D.*Yj3D)./((1+tjik_3D).*(1+mu_k3D));
ERR1 = sum(sum(AUX3,3),2) - wi_h.*Ri3D(:,1,1);
ERR1(N,1) = sum(Ri3D(:,1,1).*(wi_h-1));  % replace one excess equation with normalization,w^=w'/w=1, where w=sum_i(wi'*Li)/sum(wi*Li)

% ------------------------------------------------------------------
%        Total Income = Total Sales 
% ------------------------------------------------------------------
AUX4 = mu_k3D.* AUX3;
AUX5 = AUX2.*e_ik3D.*(tjik_3D./(1+tjik_3D)).*Yj_h3D.*Yj3D;
ERR2 = sum(sum(AUX4,3),2)+ sum(sum(AUX5,3),1)' + (wi_h.*Ri3D(:,1,1)) - Yi_h.*Yi3D(:,1,1);
% ------------------------------------------------------------------

ceq= [ERR1' ERR2'];

end

