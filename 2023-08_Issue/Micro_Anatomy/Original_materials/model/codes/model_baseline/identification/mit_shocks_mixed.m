%% MIT shocks

% recover policy functions for t = 0,...,T
% dimensions of each matrix are (a x mu) rows x T+1 columns

% -> permanent one time shock = kappa constant + one time shock of income
 
par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)
       par.Y_mat(hh) = par.Y_mat(hh-1).*exp(-drop*pers_perm^(hh-2));
end
par.kappa_mat = par.kappa.*(par.Y_mat.^nu); % kappa drops and recovers

[c,ap,y,a] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat = par.Y_mat;

%% simulate - start from initial st-st and use policy functions with shocks

T = 100;
N = 100000;
first = 100;

% idio income

Pmu = nmu;

mpath=zeros(T+first,N);
M = Grid.nmulin;

ishock_m =rand(N,1);
shockm =rand(T+first-1,N);

temp = cumsum(Pmu);

for i = 1:N

    if ishock_m(i)<temp(1)
        mpath(1,i)=1;
    elseif ishock_m(i)>temp(M)
        mpath(1,i)=M;
    else
        mpath(1,i)=find(ishock_m(i)<=temp(2:M) & ishock_m(i)>temp(1:M-1))+1 ;
    end
    
end

for i = 1:N
for t=2:T+first
    
    temp=cumsum(Grid.Pmu(mpath(t-1,i),:));
    
    if shockm(t-1,i)<temp(1)
        mpath(t,i)=1;
    elseif shockm(t-1,i)>temp(M)
        mpath(t,i)=M;
    else
        mpath(t,i)=find(shockm(t-1,i)<=temp(2:M) & shockm(t-1,i)>temp(1:M-1))+1 ;
    end
    
end
end

%% first 100 periods of income and wealth simulated

% initial asset distribution

y_initial = zeros(first,N);
c_initial = zeros(first,N);
a_initial = zeros(first+1,N);

a_path = zeros(1,N);
ishock_a =rand(N,1);
temp = cumsum(na);
A=length(na);

for i = 1:N

    if ishock_a(i)<temp(1)
        a_path(1,i)=1;
    elseif ishock_a(i)>temp(A)
        a_path(1,i)=A;
    else
        a_path(1,i)=find(ishock_a(i)<=temp(2:A) & ishock_a(i)>temp(1:A-1))+1 ;
    end
    
    a_initial(1,i) = s_a(a_path(1,i));
    
end

% initial period

for t = 1:first
for i = 1:N
    
    [~,a_p] = min(abs(a_initial(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(t,i)-1) + a_p;
    
        c_initial(t,i) = c(id_p,1);
        a_initial(t+1,i) = ap(id_p,1);
        y_initial(t,i) = Y_mat(1).*exp(s_mu(mpath(t,i)));
        
end
end

%% shock

y_i = zeros(T,N);
c_i = zeros(T,N);
a_i = zeros(T+1,N);

% initial asset distribution

A=length(na);
    
    a_i(1,:) = a_initial(first+1,:);   

% initial period

for i = 1:N
    
    [~,a_p] = min(abs(a_i(1,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(first+1,i)-1) + a_p;
    
        c_i(1,i) = c(id_p,1);
        a_i(2,i) = ap(id_p,1);
        y_i(1,i) = Y_mat(1).*exp(s_mu(mpath(first+1,i)));
        
end

% after shock

for t = 2:length(Y_mat)
for i = 1:N
    
    [~,a_p] = min(abs(a_i(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(first+t,i)-1) + a_p;
    
        c_i(t,i) = c(id_p,t);
        a_i(t+1,i) = ap(id_p,t);
        y_i(t,i) = Y_mat(t).*exp(s_mu(mpath(first+t,i)));
        
end
end

for t = length(Y_mat):T
for i = 1:N
    
    [~,a_p] = min(abs(a_i(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(first+t,i)-1) + a_p;

        c_i(t,i) = c(id_p,length(Y_mat));
        a_i(t+1,i) = ap(id_p,length(Y_mat));
        y_i(t,i) = Y_mat(length(Y_mat)).*exp(s_mu(mpath(first+t,i)));
        
end
end

C_dist = zeros(T,length(s_mu));
Y_dist = zeros(T,length(s_mu));
a_dist = zeros(T,length(s_mu));

for i = 1:length(s_mu)
    
    er = s_mu(i) - s_mu(mpath((first+1):end,:));
    id = (er==0);
    cons = id.*c_i;
    inc = id.*y_i;
    assets = id.*a_i(1:end-1,:);
    ni = sum(id')';
    C_dist(:,i) = sum(cons')'./ni;   
    Y_dist(:,i) = sum(inc')'./ni;
    a_dist(:,i) = sum(assets')'./ni;
    
end

elast = (log(C_dist(:,:)) - log(C_dist(1,:)))./(log(Y_dist(:,:)) - log(Y_dist(1,:)));
mpc   = ((C_dist(:,:)) - (C_dist(1,:)))./((Y_dist(:,:)) - (Y_dist(1,:)));

nmu_cum = cumsum(nmu);
elast   = interp1(nmu_cum(8:23),elast(2,8:23),0.05:.1:.95,'linear','extrap');


