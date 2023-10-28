%% MIT shocks

% recover policy functions for t = 0,...,T
% dimensions of each matrix are (a x mu) rows x T+1 columns

% -> permanent one time shock = kappa constant + one time shock of income
 
% par.Y_mat = zeros(40,1);
% par.Y_mat(1) = par.Y;
% %for hh = 2:length(par.Y_mat)
% %       par.Y_mat(hh) = par.Y_mat(hh-1).*exp(-drop*pers_perm^(hh-2));       
% %end
% for hh = 2:length(par.Y_mat)
%        par.Y_mat(hh) = par.Y_mat(1).*exp(-drop*.98^(hh-1));       
% end
% par.kappa_mat = par.kappa.*ones(40,1); % remains unchanged
% 
% [c_PI,ap_PI,y_PI,a_PI] = policy_shock_nonh(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
% Y_mat_PI = par.Y_mat;
% 
% % -> temporary double shock = kappa drop and increase + path of income down
% % and recover
% 
% drop = drop/pers_temp;
% 
% par.Y_mat = zeros(40,1);
% par.Y_mat(1) = par.Y;
% for hh = 2:length(par.Y_mat)-1
%        par.Y_mat(hh) = par.Y.*exp(-drop*pers_temp^(hh-1));
% end
% par.Y_mat(end) = par.Y;
% par.kappa_mat = par.kappa.*par.Y_mat.^nu; % kappa drops and recovers
% 
% [c_FF,ap_FF,y_FF,a_FF] = policy_shock_nonh(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
% Y_mat_FF = par.Y_mat;

%% simulate - start from initial st-st and use policy functions with shocks

T = 100;
N = 100000;

% idio income

Pmu = nmu;

mpath=zeros(T+100,N);
M = Grid.nmulin;

ishock_m =rand(N,1);
shockm =rand(T+100-1,N);

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
for t=2:T+100
    
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

y_initial = zeros(100,N);
c_initial = zeros(100,N);
a_initial = zeros(100+1,N);

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

for t = 1:100
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
    
    a_i_PI(1,:) = a_initial(101,:);    

% initial period

for i = 1:N
    
    [~,a_p] = min(abs(a_i_PI(1,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(1+100,i)-1) + a_p;
    
        c_i_PI(1,i) = c_PI(id_p,1);
        a_i_PI(2,i) = ap_PI(id_p,1);
        y_i_PI(1,i) = Y_mat_PI(1).*exp(s_mu(mpath(1+100,i)));
        
end

% after shock

for t = 2:length(Y_mat_PI)
for i = 1:N
    
    [~,a_p] = min(abs(a_i_PI(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(t+100,i)-1) + a_p;
    
        c_i_PI(t,i) = c_PI(id_p,t);
        a_i_PI(t+1,i) = ap_PI(id_p,t);
        y_i_PI(t,i) = Y_mat_PI(t).*exp(s_mu(mpath(t+100,i)));
        
end
end

for t = length(Y_mat_PI):T
for i = 1:N
    
    [~,a_p] = min(abs(a_i_PI(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(t+100,i)-1) + a_p;
    
        c_i_PI(t,i) = c_PI(id_p,length(Y_mat_PI));
        a_i_PI(t+1,i) = ap_PI(id_p,length(Y_mat_PI));
        y_i_PI(t,i) = Y_mat_PI(length(Y_mat_PI)).*exp(s_mu(mpath(t+100,i)));
        
end
end

C_PI_ag = sum(c_i_PI')/N;
Y_PI_ag = sum(y_i_PI')/N;

C_dist_PI = zeros(T,length(s_mu));
Y_dist_PI = zeros(T,length(s_mu));

for i = 1:length(s_mu)
    
    er = s_mu(i) - s_mu(mpath(101:end,:));
    id = (er==0);
    cons = id.*c_i_PI;
    inc = id.*y_i_PI;
    ni = sum(id')';
    C_dist_PI(:,i) = sum(cons')'./ni;   
    Y_dist_PI(:,i) = sum(inc')'./ni;
    
end

elast_PInh = (log(C_dist_PI(:,:)) - log(C_dist_PI(1,:)))./(log(Y_dist_PI(:,:)) - log(Y_dist_PI(1,:)));
mpc_PInh = ((C_dist_PI(:,:)) - (C_dist_PI(1,:)))./((Y_dist_PI(:,:)) - (Y_dist_PI(1,:)));

%% FF shock

y_i_FF = zeros(T,N);
c_i_FF = zeros(T,N);
a_i_FF = zeros(T+1,N);

% initial asset distribution

A=length(na);
    
    a_i_FF(1,:) = a_initial(101,:);    

% initial period

for i = 1:N
    
    [~,a_p] = min(abs(a_i_FF(1,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(1+100,i)-1) + a_p;
    
        c_i_FF(1,i) = c_FF(id_p,1);
        a_i_FF(2,i) = ap_FF(id_p,1);
        y_i_FF(1,i) = Y_mat_FF(1).*exp(s_mu(mpath(1+100,i)));
        
end

% path shock

for t = 2:length(Y_mat_FF)-1
for i = 1:N
    
    [~,a_p] = min(abs(a_i_FF(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(t+100,i)-1) + a_p;
    
        c_i_FF(t,i) = c_FF(id_p,t);
        a_i_FF(t+1,i) = ap_FF(id_p,t);
        y_i_FF(t,i) = Y_mat_FF(t).*exp(s_mu(mpath(t+100,i)));
        
end
end

% after shock

for t = length(Y_mat_FF):T
for i = 1:N
    
    [~,a_p] = min(abs(a_i_FF(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(t+100,i)-1) + a_p;
    
        c_i_FF(t,i) = c_FF(id_p,length(Y_mat_FF));
        a_i_FF(t+1,i) = ap_FF(id_p,length(Y_mat_FF));
        y_i_FF(t,i) = Y_mat_FF(length(Y_mat_FF)).*exp(s_mu(mpath(t+100,i)));
        
end
end

C_FF_ag = sum(c_i_FF')/N;
Y_FF_ag = sum(y_i_FF')/N;

C_dist_FF = zeros(T,length(s_mu));
Y_dist_FF = zeros(T,length(s_mu));

for i = 1:length(s_mu)
    
    er = s_mu(i) - s_mu(mpath(101:end,:));
    id = (er==0);
    cons = id.*c_i_FF;
    inc = id.*y_i_FF;
    ni = sum(id')';
    C_dist_FF(:,i) = sum(cons')'./ni;   
    Y_dist_FF(:,i) = sum(inc')'./ni;
    
end

elast_FFnh = (log(C_dist_FF(:,:)) - log(C_dist_FF(1,:)))./(log(Y_dist_FF(:,:)) - log(Y_dist_FF(1,:)));
mpc_FFnh = ((C_dist_FF(:,:)) - (C_dist_FF(1,:)))./((Y_dist_FF(:,:)) - (Y_dist_FF(1,:)));
id_Cadjust = (c_i_FF == 1e-6);

%% counterfactuals

c_PI_1 = reshape(c_PI(:,1),[n_a n_mu]);
c_PI_2 = reshape(c_PI(:,2),[n_a n_mu]);
elast_PI_c = (log(c_PI_2) - log(c_PI_1))./(log(Y_PI_ag(2))-log(Y_PI_ag(1)));
mpc_PI_c = (c_PI_2 - c_PI_1)./(exp(s_mu)'*(Y_PI_ag(2)-Y_PI_ag(1)));

c_FF_1 = reshape(c_FF(:,1),[n_a n_mu]);
c_FF_2 = reshape(c_FF(:,2),[n_a n_mu]);
elast_FF_c = (log(c_FF_2) - log(c_FF_1))./(log(Y_FF_ag(2))-log(Y_FF_ag(1)));
mpc_FF_c = (c_FF_2 - c_FF_1)./(exp(s_mu)'*(Y_FF_ag(2)-Y_FF_ag(1)));

% steady state assets
assets_income = (s_a'*dist)'./nmu;
elast_PInh_2 = zeros(10,2);
elast_FFnh_2 = zeros(10,2);

mpc_PInh_2 = zeros(10,2);
mpc_FFnh_2 = zeros(10,2);

for i = 1:length(assets_income)
[~,a_p1] = min(abs(assets_income(i)*ones(A,1)-s_a));
[~,a_p2] = min(abs(0.2.*exp(s_mu(i))*ones(A,1)-s_a));

elast_PInh_2(i,1) = elast_PI_c(a_p1,i);
elast_FFnh_2(i,1) = elast_FF_c(a_p1,i);
mpc_PInh_2(i,1) = mpc_PI_c(a_p1,i);
mpc_FFnh_2(i,1) = mpc_FF_c(a_p1,i);

elast_PInh_2(i,2) = elast_PI_c(a_p2,i);
elast_FFnh_2(i,2) = elast_FF_c(a_p2,i);
mpc_PInh_2(i,2) = mpc_PI_c(a_p2,i);
mpc_FFnh_2(i,2) = mpc_FF_c(a_p2,i);

end
