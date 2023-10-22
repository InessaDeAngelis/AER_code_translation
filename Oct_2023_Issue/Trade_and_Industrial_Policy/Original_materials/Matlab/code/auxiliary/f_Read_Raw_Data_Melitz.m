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
%AggC=dlmread('AGG_C.csv');  N=size(AggC,1);
AggS=dlmread('AGG_S.csv');  S=size(AggS,1);  N=size(AggC,1);
CC=kron(AggC,AggS); % matrix for aggregating matrix of intermediate goods flows Z
FF=kron(AggC,eye(5));  % matrix for aggregating matrix of final demand F (Note: 5 catgeories of final demand)
Z=(CC) * (Z) * (CC');   % aggregated Z matrix
F=(CC) * (F) * (FF');   % aggregated F matrix
X=[Z,F];  R=sum(X,2);
%======================= Compute the required data ========================
ls=ones(S,1);	ln=ones(N,1);	l5=ones(5,1);   % summer vectors
AUX1=kron(eye(N),ls);	% aux matrix for summation over "k": ijsk -> ijs
AUX2=kron(eye(N),l5);
AUX=[AUX1;AUX2];
Xijs3D=permute(reshape(X*AUX,S,N,N),[2 3 1]); % Xijs -- flow of good "s" from "i" to "j"

PARAM=dlmread('AGG_P.csv');

epsilon_s=PARAM(:,2); epsilon_s([S+1:length(PARAM)])=[];    % drop elasticities for aggregated sectors: for initial sectors 5 and 4 elasticities are the same, while initial sectors 17:35 are non-tradable (also have the same elasticity)
epsilon_s(end,1)=10;   % set trade elasticities for non-tradables to 100
sigma_s3D= 1+ reshape(kron(epsilon_s',ones(N)),N,N,S);

mu_s=PARAM(:,3); mu_s([S+1:length(PARAM)])=[];    % drop elasticities for aggregated sectors: for initial sectors 5 and 4 elasticities are the same, while initial sectors 17:35 are non-tradable (also have the same elasticity)
mu_s3D=reshape(kron((mu_s)',ones(N)),N,N,S);

epsilon_s=PARAM(:,4); epsilon_s([S+1:length(PARAM)])=[];    % drop elasticities for aggregated sectors: for initial sectors 5 and 4 elasticities are the same, while initial sectors 17:35 are non-tradable (also have the same elasticity)
epsilon_s(end,1)=10;   % set trade elasticities for non-tradables to 100
epsilon_s3D=reshape(kron(epsilon_s',ones(N)),N,N,S);

TEMP1 = epsilon_s3D(:,:,1:2).*Xijs3D(:,:,1:2); TEMP2 = Xijs3D(:,:,1:2);
epsilon_s3D(:,:,1:2)=sum(TEMP1(:))/sum(TEMP2(:))*ones(N,N,2);
epsilon_s3D(:,:,3) = 1 + epsilon_s3D(:,:,3);
epsilon_s3D(:,:,7) = sigma_s3D(:,:,7) - 1;

mu_s3D = 1./(epsilon_s3D./(1 - ( (1./(sigma_s3D-1)) - mu_s3D).*epsilon_s3D));

epsilon_s3D(:,:,7) = 14.94;
sigma_s3D = 1 + epsilon_s3D;

mu_s3D = mu_s3D.*(mu_s3D.*(sigma_s3D-1)<1) +  (1./(sigma_s3D-1)).*(mu_s3D.*(sigma_s3D-1)>1);

save Input/TEMP/Step_1.mat N S Xijs3D mu_s3D sigma_s3D AggC;
