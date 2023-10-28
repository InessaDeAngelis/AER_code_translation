%% MIT shocks

% recover policy functions for t = 0,...,T
% dimensions of each matrix are (a x mu) rows x T+1 columns

% -> permanent one time shock = kappa constant + one time shock of income
 
par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)
       par.Y_mat(hh) = par.Y_mat(hh-1).*exp(-drop*pers_perm^(hh-2));
end
par.kappa_mat = par.kappa.*ones(40,1); % remains unchanged

[c_PI,ap_PI,y_PI,a_PI] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_PI = par.Y_mat;

% -> temporary double shock = kappa drop and increase + path of income down
% and recover

drop = drop/pers_temp;

par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)-1
       par.Y_mat(hh) = par.Y.*exp(-drop*pers_temp^(hh-1));
end
par.Y_mat(end) = par.Y;
par.kappa_mat = par.kappa.*par.Y_mat.^nu; % kappa drops and recovers

[c_FF,ap_FF,y_FF,a_FF] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_FF = par.Y_mat;

%% simulate panel - start from initial st-st and use policy functions with shocks

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
    
        c_initial(t,i) = c_PI(id_p,1);
        a_initial(t+1,i) = ap_PI(id_p,1);
        y_initial(t,i) = Y_mat_PI(1).*exp(s_mu(mpath(t,i)));
        
end
end

%% PI shock

y_i_PI = zeros(T,N);
c_i_PI = zeros(T,N);
a_i_PI = zeros(T+1,N);

% initial asset distribution

A=length(na);
    
    a_i_PI(1,:) = a_initial(first+1,:);   

% initial period

for i = 1:N
    
    [~,a_p] = min(abs(a_i_PI(1,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(first+1,i)-1) + a_p;
    
        c_i_PI(1,i) = c_PI(id_p,1);
        a_i_PI(2,i) = ap_PI(id_p,1);
        y_i_PI(1,i) = Y_mat_PI(1).*exp(s_mu(mpath(first+1,i)));
        
end

% after shock

for t = 2:length(Y_mat_PI)
for i = 1:N
    
    [~,a_p] = min(abs(a_i_PI(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(first+t,i)-1) + a_p;
    
        c_i_PI(t,i) = c_PI(id_p,t);
        a_i_PI(t+1,i) = ap_PI(id_p,t);
        y_i_PI(t,i) = Y_mat_PI(t).*exp(s_mu(mpath(first+t,i)));
        
end
end

for t = length(Y_mat_PI):T
for i = 1:N
    
    [~,a_p] = min(abs(a_i_PI(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(first+t,i)-1) + a_p;

        c_i_PI(t,i) = c_PI(id_p,length(Y_mat_PI));
        a_i_PI(t+1,i) = ap_PI(id_p,length(Y_mat_PI));
        y_i_PI(t,i) = Y_mat_PI(length(Y_mat_PI)).*exp(s_mu(mpath(first+t,i)));
        
end
end

C_dist_PI = zeros(T,length(s_mu));
Y_dist_PI = zeros(T,length(s_mu));
a_dist_PI = zeros(T,length(s_mu));

for i = 1:length(s_mu)
    
    er = s_mu(i) - s_mu(mpath((first+1):end,:));
    id = (er==0);
    cons = id.*c_i_PI;
    inc = id.*y_i_PI;
    assets = id.*a_i_PI(1:end-1,:);
    ni = sum(id')';
    C_dist_PI(:,i) = sum(cons')'./ni;   
    Y_dist_PI(:,i) = sum(inc')'./ni;
    a_dist_PI(:,i) = sum(assets')'./ni;
    
end

Y_PI_ag  = sum(y_i_PI')/N;
elast_PI = (log(C_dist_PI(:,:)) - log(C_dist_PI(1,:)))./(log(Y_dist_PI(:,:)) - log(Y_dist_PI(1,:)));
mpc_PI   = ((C_dist_PI(:,:)) - (C_dist_PI(1,:)))./((Y_dist_PI(:,:)) - (Y_dist_PI(1,:)));

%% FF shock

y_i_FF = zeros(T,N);
c_i_FF = zeros(T,N);
a_i_FF = zeros(T+1,N);

% initial asset distribution

A=length(na);

    a_i_FF(1,:) = a_initial(first+1,:);

% initial period

for i = 1:N
    
    [~,a_p] = min(abs(a_i_FF(1,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(first+1,i)-1) + a_p;
    
        c_i_FF(1,i) = c_FF(id_p,1);
        a_i_FF(2,i) = ap_FF(id_p,1);
        y_i_FF(1,i) = Y_mat_FF(1).*exp(s_mu(mpath(first+1,i)));
        
end

% path shock

for t = 2:length(Y_mat_FF)-1
for i = 1:N
    
    [~,a_p] = min(abs(a_i_FF(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(first+t,i)-1) + a_p;
    
        c_i_FF(t,i) = c_FF(id_p,t);
        a_i_FF(t+1,i) = ap_FF(id_p,t);
        y_i_FF(t,i) = Y_mat_FF(t).*exp(s_mu(mpath(first+t,i)));
        
end
end

% after shock

for t = length(Y_mat_FF):T
for i = 1:N
    
    [~,a_p] = min(abs(a_i_FF(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(first+t,i)-1) + a_p;
    
        c_i_FF(t,i) = c_FF(id_p,length(Y_mat_FF));
        a_i_FF(t+1,i) = ap_FF(id_p,length(Y_mat_FF));
        y_i_FF(t,i) = Y_mat_FF(length(Y_mat_FF)).*exp(s_mu(mpath(first+t,i)));
        
end
end

C_dist_FF = zeros(T,length(s_mu));
Y_dist_FF = zeros(T,length(s_mu));
a_dist_FF = zeros(T,length(s_mu));

for i = 1:length(s_mu)
    
    er = s_mu(i) - s_mu(mpath((first+1):end,:));
    id = (er==0);
    cons = id.*c_i_FF;
    inc = id.*y_i_FF;
    assets = id.*a_i_FF(1:end-1,:);
    ni = sum(id')';
    C_dist_FF(:,i) = sum(cons')'./ni;   
    Y_dist_FF(:,i) = sum(inc')'./ni;
    a_dist_FF(:,i) = sum(assets')'./ni;
    
end

Y_FF_ag  = sum(y_i_FF')/N;
elast_FF = (log(C_dist_FF(:,:)) - log(C_dist_FF(1,:)))./(log(Y_dist_FF(:,:)) - log(Y_dist_FF(1,:)));
mpc_FF   = ((C_dist_FF(:,:)) - (C_dist_FF(1,:)))./((Y_dist_FF(:,:)) - (Y_dist_FF(1,:)));

%% theoretical

c_PI_1 = reshape(c_PI(:,1),[n_a n_mu]); % before shock
c_PI_2 = reshape(c_PI(:,2),[n_a n_mu]); % after shock

% evaluate at steady-state asset distribution

a_i_0 = a_i_PI(1,:);
mean_d = zeros(length(8:23),1);

for hh = 8:23
er = s_mu(hh) - s_mu(mpath((first+1),:));
id = (er==0);
aa = a_i_0(id==1)';

d_ = zeros(length(aa),1);

for i = 1:length(aa)
    [~,a_val] = min(abs(aa(i,1)*ones(A,1)-s_a));        
    d_(i,1) = (log(c_PI_2(a_val,hh))-log(c_PI_1(a_val,hh)))./(log(Y_PI_ag(2))-log(Y_PI_ag(1)));    
end

mean_d(hh-7,:) = mean(d_);

end

%% deciles

% interpolate on grid to approx values in decile
nmu_cum = cumsum(nmu);
elast_PI_plot = interp1(nmu_cum(8:23),elast_PI(2,8:23),0.05:.1:.95,'linear','extrap');
elast_FF_plot = interp1(nmu_cum(8:23),elast_FF(2,8:23),0.05:.1:.95,'linear','extrap');
mpc_PI_plot   = interp1(nmu_cum(8:23),mpc_PI(2,8:23),0.05:.1:.95,'linear','extrap');
mean_d_plot   = interp1(nmu_cum(8:23),mean_d,0.05:.1:.95,'linear','extrap');


