%% MIT shocks

%%% MIT shocks with transfers

% recover policy functions for t = 0,...,T
% dimensions of each matrix are (a x mu) rows x T+1 columns

% -> transfers with no crisis shock

par.Y_mat = par.Y.*ones(40,1);
par.kappa_mat = par.kappa.*ones(40,1);

[c_T,ap_T,y_T,a_T] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_T = par.Y_mat;

% -> permanent one time shock = kappa constant + one time shock of income (PI-view)
 
par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)
       par.Y_mat(hh) = par.Y_mat(hh-1).*exp(-drop*pers_perm^(hh-2));
end
par.kappa_mat = par.kappa.*ones(40,1); % remains unchanged

[c_PI,ap_PI,y_PI,a_PI] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_PI = par.Y_mat;

% -> temporary income shock without credit tightening

drop = drop/pers_temp;

par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)-1
       par.Y_mat(hh) = par.Y.*exp(-drop*pers_temp^(hh-1));
end
par.Y_mat(end) = par.Y;
par.kappa_mat = par.kappa.*ones(40,1); % remains unchanged

[c_TEMP,ap_TEMP,y_TEMP,a_TEMP] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_TEMP = par.Y_mat;

% -> temporary income shock with credit tightening (CT-view)

par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)-1
       par.Y_mat(hh) = par.Y.*exp(-drop*pers_temp^(hh-1));
end
par.Y_mat(end) = par.Y;
par.kappa_mat = par.kappa.*par.Y_mat.^nu; % kappa drops and recovers

[c_FF,ap_FF,y_FF,a_FF] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_FF = par.Y_mat;

% transfer matrix

par.transf_matrix = par.transf_mat;

%%% MIT shocks without transfers

par.transf_mat = zeros(40,n_mu); % matrix 0 transfers

par.Y_mat = par.Y.*ones(40,1);
par.kappa_mat = par.kappa.*ones(40,1);

[c_Tn,ap_Tn,y_Tn,a_Tn] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_Tn = par.Y_mat;

% -> permanent one time shock = kappa constant + one time shock of income (PI-view)
 
drop = drop*pers_temp;

par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)
       par.Y_mat(hh) = par.Y_mat(hh-1).*exp(-drop*pers_perm^(hh-2));
end
par.kappa_mat = par.kappa.*ones(40,1); % remains unchanged

[c_PIn,ap_PIn,y_PIn,a_PIn] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_PIn = par.Y_mat;

% -> temporary income shock without credit tightening

drop = drop/pers_temp;

par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)-1
       par.Y_mat(hh) = par.Y.*exp(-drop*pers_temp^(hh-1));
end
par.Y_mat(end) = par.Y;
par.kappa_mat = par.kappa.*ones(40,1); % remains unchanged

[c_TEMPn,ap_TEMPn,y_TEMPn,a_TEMPn] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_TEMPn = par.Y_mat;

% -> temporary income shock with credit tightening (CT-view)

%drop = drop/pers_temp;

par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)-1
       par.Y_mat(hh) = par.Y.*exp(-drop*pers_temp^(hh-1));
end
par.Y_mat(end) = par.Y;
par.kappa_mat = par.kappa.*par.Y_mat.^nu; % kappa drops and recovers

[c_FFn,ap_FFn,y_FFn,a_FFn] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_FFn = par.Y_mat;

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

%% transfer shock in steady state

y_i_T = zeros(T,N);
c_i_T = zeros(T,N);
a_i_T = zeros(T+1,N);
y_i_Tn = zeros(T,N);
c_i_Tn = zeros(T,N);
a_i_Tn = zeros(T+1,N);

% initial asset distribution

A=length(na);
    
    a_i_T(1,:)  = a_initial(101,:);
    a_i_Tn(1,:) = a_initial(101,:);    

% initial period

for i = 1:N
    
    [~,a_p] = min(abs(a_i_T(1,i)*ones(A,1)-s_a));
    [~,a_pn] = min(abs(a_i_Tn(1,i)*ones(A,1)-s_a));
    
    id_p = A*(mpath(1+100,i)-1) + a_p;
    id_pn = A*(mpath(1+100,i)-1) + a_pn;
    
        c_i_T(1,i) = c_T(id_p,1);
        a_i_T(2,i) = ap_T(id_p,1);
        y_i_T(1,i) = Y_mat_T(1).*exp(s_mu(mpath(1+100,i)));
        
        c_i_Tn(1,i) = c_Tn(id_pn,1);
        a_i_Tn(2,i) = ap_Tn(id_pn,1);
        y_i_Tn(1,i) = Y_mat_Tn(1).*exp(s_mu(mpath(1+100,i)));
        
end

% after shock

for t = 2:length(Y_mat_T)
for i = 1:N
    
    [~,a_p] = min(abs(a_i_T(t,i)*ones(A,1)-s_a));
    [~,a_pn] = min(abs(a_i_Tn(t,i)*ones(A,1)-s_a));
    
    id_p = A*(mpath(t+100,i)-1) + a_p;
    id_pn = A*(mpath(t+100,i)-1) + a_pn;
    
        c_i_T(t,i) = c_T(id_p,t);
        a_i_T(t+1,i) = ap_T(id_p,t);
        y_i_T(t,i) = Y_mat_T(t).*exp(s_mu(mpath(t+100,i)));
        
        c_i_Tn(t,i) = c_Tn(id_pn,t);
        a_i_Tn(t+1,i) = ap_Tn(id_pn,t);
        y_i_Tn(t,i) = Y_mat_Tn(t).*exp(s_mu(mpath(t+100,i)));        
        
end
end

for t = length(Y_mat_T):T
for i = 1:N
    
    [~,a_p] = min(abs(a_i_T(t,i)*ones(A,1)-s_a));
    [~,a_pn] = min(abs(a_i_Tn(t,i)*ones(A,1)-s_a));
    
    id_p = A*(mpath(t+100,i)-1) + a_p;
    id_pn = A*(mpath(t+100,i)-1) + a_pn;
    
        c_i_T(t,i) = c_T(id_p,length(Y_mat_T));
        a_i_T(t+1,i) = ap_T(id_p,length(Y_mat_T));
        y_i_T(t,i) = Y_mat_T(length(Y_mat_T)).*exp(s_mu(mpath(t+100,i)));

        c_i_Tn(t,i) = c_Tn(id_pn,length(Y_mat_Tn));
        a_i_Tn(t+1,i) = ap_Tn(id_pn,length(Y_mat_Tn));
        y_i_Tn(t,i) = Y_mat_Tn(length(Y_mat_Tn)).*exp(s_mu(mpath(t+100,i)));        
end
end

C_T_ag = sum(c_i_T')/N;
Y_T_ag = sum(y_i_T')/N;

C_Tn_ag = sum(c_i_Tn')/N;
Y_Tn_ag = sum(y_i_Tn')/N;

C_dist_T = zeros(T,length(s_mu));
Y_dist_T = zeros(T,length(s_mu));
a_dist_T = zeros(T,length(s_mu));

C_dist_Tn = zeros(T,length(s_mu));
Y_dist_Tn = zeros(T,length(s_mu));
a_dist_Tn = zeros(T,length(s_mu));

for i = 1:length(s_mu)
    
    er = s_mu(i) - s_mu(mpath(101:end,:));
    id = (er==0);
    cons = id.*c_i_T;
    inc = id.*y_i_T;
    asse = id.*a_i_T(2:end,:);
    
    consn = id.*c_i_Tn;
    incn = id.*y_i_Tn;  
    assen = id.*a_i_Tn(2:end,:);
    
    ni = sum(id')';
    C_dist_T(:,i) = sum(cons')'./ni;   
    Y_dist_T(:,i) = sum(inc')'./ni;
    a_dist_T(:,i) = sum(asse')'./ni;
    
    C_dist_Tn(:,i) = sum(consn')'./ni;   
    Y_dist_Tn(:,i) = sum(incn')'./ni;
    a_dist_Tn(:,i) = sum(assen')'./ni;
    
end

mpc_t_T = (C_dist_T(2,:) - C_dist_Tn(2,:))./par.transf_matrix(2,:);
mpc_ag_T = (C_T_ag(2) - C_Tn_ag(2))./par.eta;

% hand-to-mouth agents

htm_T  = (a_i_T(1:end-1,:) <= min(agridlin) +y_i_T./24);
htm_Tn = (a_i_Tn(1:end-1,:) <= min(agridlin) +y_i_Tn./24);

mpc_T_htm = ((sum(htm_Tn(2,:).*c_i_T(2,:))- sum(htm_Tn(2,:).*c_i_Tn(2,:)))/sum(htm_Tn(2,:)))./mean(par.transf_matrix(2,:));
mpc_T_nhtm = ((sum((1-htm_Tn(2,:)).*c_i_T(2,:))- sum((1-htm_Tn(2,:)).*c_i_Tn(2,:)))/sum((1-htm_Tn(2,:))))./mean(par.transf_matrix(2,:));


%% PI shock

y_i_PI = zeros(T,N);
c_i_PI = zeros(T,N);
a_i_PI = zeros(T+1,N);

y_i_PIn = zeros(T,N);
c_i_PIn = zeros(T,N);
a_i_PIn = zeros(T+1,N);

% initial asset distribution

A=length(na);

    a_i_PI(1,:)  = a_initial(101,:);
    a_i_PIn(1,:) = a_initial(101,:);
    

% initial period

for i = 1:N
    
    [~,a_p] = min(abs(a_i_PI(1,i)*ones(A,1)-s_a)); % position in m of b(t) 
    [~,a_pn] = min(abs(a_i_PIn(1,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(1+100,i)-1) + a_p;
    id_pn = A*(mpath(1+100,i)-1) + a_pn;
    
        c_i_PI(1,i) = c_PI(id_p,1);
        a_i_PI(2,i) = ap_PI(id_p,1);
        y_i_PI(1,i) = Y_mat_PI(1).*exp(s_mu(mpath(1+100,i)));
        c_i_PIn(1,i) = c_PIn(id_pn,1);
        a_i_PIn(2,i) = ap_PIn(id_pn,1);
        y_i_PIn(1,i) = Y_mat_PIn(1).*exp(s_mu(mpath(1+100,i)));
        
end

% after shock

for t = 2:length(Y_mat_PI)
for i = 1:N
    
    [~,a_p] = min(abs(a_i_PI(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    [~,a_pn] = min(abs(a_i_PIn(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(t+100,i)-1) + a_p;
    id_pn = A*(mpath(t+100,i)-1) + a_pn;
    
        c_i_PI(t,i) = c_PI(id_p,t);
        a_i_PI(t+1,i) = ap_PI(id_p,t);
        y_i_PI(t,i) = Y_mat_PI(t).*exp(s_mu(mpath(t+100,i)));
        c_i_PIn(t,i) = c_PIn(id_pn,t);
        a_i_PIn(t+1,i) = ap_PIn(id_pn,t);
        y_i_PIn(t,i) = Y_mat_PIn(t).*exp(s_mu(mpath(t+100,i)));        
end
end

for t = length(Y_mat_PI):T
for i = 1:N
    
    [~,a_p] = min(abs(a_i_PI(t,i)*ones(A,1)-s_a));
    [~,a_pn] = min(abs(a_i_PIn(t,i)*ones(A,1)-s_a));
    
    id_p = A*(mpath(t+100,i)-1) + a_p;
    id_pn = A*(mpath(t+100,i)-1) + a_pn;
    
        c_i_PI(t,i) = c_PI(id_p,length(Y_mat_PI));
        a_i_PI(t+1,i) = ap_PI(id_p,length(Y_mat_PI));
        y_i_PI(t,i) = Y_mat_PI(length(Y_mat_PI)).*exp(s_mu(mpath(t+100,i)));
        c_i_PIn(t,i) = c_PIn(id_pn,length(Y_mat_PIn));
        a_i_PIn(t+1,i) = ap_PIn(id_pn,length(Y_mat_PIn));
        y_i_PIn(t,i) = Y_mat_PIn(length(Y_mat_PIn)).*exp(s_mu(mpath(t+100,i)));        
        
end
end

C_PI_ag = sum(c_i_PI')/N;
Y_PI_ag = sum(y_i_PI')/N;
C_PIn_ag = sum(c_i_PIn')/N;
Y_PIn_ag = sum(y_i_PIn')/N;

C_dist_PI = zeros(T,length(s_mu));
Y_dist_PI = zeros(T,length(s_mu));
a_dist_PI = zeros(T,length(s_mu));
C_dist_PIn = zeros(T,length(s_mu));
Y_dist_PIn = zeros(T,length(s_mu));
a_dist_PIn = zeros(T,length(s_mu));

for i = 1:length(s_mu)
    
    er = s_mu(i) - s_mu(mpath(101:end,:));
    id = (er==0);
    cons = id.*c_i_PI;
    inc = id.*y_i_PI;
    asse = id.*a_i_PI(2:end,:);
    
    consn = id.*c_i_PIn;
    incn = id.*y_i_PIn;
    assen = id.*a_i_PIn(2:end,:);
    
    ni = sum(id')';
    C_dist_PI(:,i) = sum(cons')'./ni;   
    Y_dist_PI(:,i) = sum(inc')'./ni;
    a_dist_PI(:,i) = sum(asse')'./ni;
    
    C_dist_PIn(:,i) = sum(consn')'./ni;   
    Y_dist_PIn(:,i) = sum(incn')'./ni;
    a_dist_PIn(:,i) = sum(assen')'./ni;
    
end

mpc_t_PI = (C_dist_PI(2,:) - C_dist_PIn(2,:))./par.transf_matrix(2,:);
mpc_ag_PI = (C_PI_ag(2) - C_PIn_ag(2))./par.eta;

% hand-to-mouth agents

htm_PI  = (a_i_PI(1:end-1,:) <= min(agridlin) +y_i_PI./24);
htm_PIn = (a_i_PIn(1:end-1,:) <= min(agridlin) +y_i_PIn./24);

mpc_PI_htm = ((sum(htm_PIn(2,:).*c_i_PI(2,:))- sum(htm_PIn(2,:).*c_i_PIn(2,:)))/sum(htm_PIn(2,:)))./mean(par.transf_matrix(2,:));
mpc_PI_nhtm = ((sum((1-htm_PIn(2,:)).*c_i_PI(2,:))- sum((1-htm_PIn(2,:)).*c_i_PIn(2,:)))/sum((1-htm_PIn(2,:))))./mean(par.transf_matrix(2,:));

%% FF shock

y_i_FF = zeros(T,N);
c_i_FF = zeros(T,N);
a_i_FF = zeros(T+1,N);
y_i_FFn = zeros(T,N);
c_i_FFn = zeros(T,N);
a_i_FFn = zeros(T+1,N);

% initial asset distribution

A=length(na);
    
    a_i_FF(1,:)  = a_initial(101,:);
    a_i_FFn(1,:) = a_initial(101,:);
    
% initial period

for i = 1:N
    
    [~,a_p] = min(abs(a_i_FF(1,i)*ones(A,1)-s_a)); % position in m of b(t)
    [~,a_pn] = min(abs(a_i_FFn(1,i)*ones(A,1)-s_a)); % position in m of b(t)
    
    id_p = A*(mpath(1+100,i)-1) + a_p;
    id_pn = A*(mpath(1+100,i)-1) + a_pn;
    
        c_i_FF(1,i) = c_FF(id_p,1);
        a_i_FF(2,i) = ap_FF(id_p,1);
        y_i_FF(1,i) = Y_mat_FF(1).*exp(s_mu(mpath(1+100,i)));
        
        c_i_FFn(1,i) = c_FFn(id_pn,1);
        a_i_FFn(2,i) = ap_FFn(id_pn,1);
        y_i_FFn(1,i) = Y_mat_FFn(1).*exp(s_mu(mpath(1+100,i)));
        
end

% path shock

for t = 2:length(Y_mat_FF)-1
for i = 1:N
    
    [~,a_p] = min(abs(a_i_FF(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    [~,a_pn] = min(abs(a_i_FFn(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(t+100,i)-1) + a_p;
    id_pn = A*(mpath(t+100,i)-1) + a_pn;
    
        c_i_FF(t,i) = c_FF(id_p,t);
        a_i_FF(t+1,i) = ap_FF(id_p,t);
        y_i_FF(t,i) = Y_mat_FF(t).*exp(s_mu(mpath(t+100,i)));
        
        c_i_FFn(t,i) = c_FFn(id_pn,t);
        a_i_FFn(t+1,i) = ap_FFn(id_pn,t);
        y_i_FFn(t,i) = Y_mat_FFn(t).*exp(s_mu(mpath(t+100,i)));
        
end
end

% after shock

for t = length(Y_mat_FF):T
for i = 1:N
    
    [~,a_p] = min(abs(a_i_FF(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    [~,a_pn] = min(abs(a_i_FFn(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(t+100,i)-1) + a_p;
    id_pn = A*(mpath(t+100,i)-1) + a_pn;
    
        c_i_FF(t,i) = c_FF(id_p,length(Y_mat_FF));
        a_i_FF(t+1,i) = ap_FF(id_p,length(Y_mat_FF));
        y_i_FF(t,i) = Y_mat_FF(length(Y_mat_FF)).*exp(s_mu(mpath(t+100,i)));

        c_i_FFn(t,i) = c_FFn(id_pn,length(Y_mat_FFn));
        a_i_FFn(t+1,i) = ap_FFn(id_pn,length(Y_mat_FFn));
        y_i_FFn(t,i) = Y_mat_FFn(length(Y_mat_FFn)).*exp(s_mu(mpath(t+100,i)));        
end
end

C_FF_ag = sum(c_i_FF')/N;
Y_FF_ag = sum(y_i_FF')/N;

C_FFn_ag = sum(c_i_FFn')/N;
Y_FFn_ag = sum(y_i_FFn')/N;

C_dist_FF = zeros(T,length(s_mu));
Y_dist_FF = zeros(T,length(s_mu));
a_dist_FF = zeros(T,length(s_mu));

C_dist_FFn = zeros(T,length(s_mu));
Y_dist_FFn = zeros(T,length(s_mu));
a_dist_FFn = zeros(T,length(s_mu));

for i = 1:length(s_mu)
    
    er = s_mu(i) - s_mu(mpath(101:end,:));
    id = (er==0);
    cons = id.*c_i_FF;
    inc = id.*y_i_FF;
    asse = id.*a_i_FF(2:end,:);
    
    consn = id.*c_i_FFn;
    incn = id.*y_i_FFn;
    asse = id.*a_i_FFn(2:end,:);
    
    ni = sum(id')';
    C_dist_FF(:,i) = sum(cons')'./ni;   
    Y_dist_FF(:,i) = sum(inc')'./ni;
    a_dist_FF(:,i) = sum(asse')'./ni;
    
    C_dist_FFn(:,i) = sum(consn')'./ni;   
    Y_dist_FFn(:,i) = sum(incn')'./ni; 
    a_dist_FFn(:,i) = sum(assen')'./ni;
end

mpc_t_FF = (C_dist_FF(2,:) - C_dist_FFn(2,:))./par.transf_matrix(2,:);
mpc_ag_FF = (C_FF_ag(2) - C_FFn_ag(2))./par.eta;

% hand-to-mouth agents

htm_FF  = (a_i_FF(1:end-1,:) <= min(agridlin) +y_i_FF./24);
htm_FFn = (a_i_FFn(1:end-1,:) <= min(agridlin) +y_i_FFn./24);

mpc_FF_htm = ((sum(htm_FFn(2,:).*c_i_FF(2,:))- sum(htm_FFn(2,:).*c_i_FFn(2,:)))/sum(htm_FFn(2,:)))./mean(par.transf_matrix(2,:));
mpc_FF_nhtm = ((sum((1-htm_FFn(2,:)).*c_i_FF(2,:))- sum((1-htm_FFn(2,:)).*c_i_FFn(2,:)))/sum((1-htm_FFn(2,:))))./mean(par.transf_matrix(2,:));


%% TEMP shock

y_i_TEMP = zeros(T,N);
c_i_TEMP = zeros(T,N);
a_i_TEMP = zeros(T+1,N);
y_i_TEMPn = zeros(T,N);
c_i_TEMPn = zeros(T,N);
a_i_TEMPn = zeros(T+1,N);

% initial asset distribution

A=length(na);
    
    a_i_TEMP(1,:)  = a_initial(101,:);
    a_i_TEMPn(1,:) = a_initial(101,:);
    
% initial period

for i = 1:N
    
    [~,a_p] = min(abs(a_i_TEMP(1,i)*ones(A,1)-s_a)); % position in m of b(t)
    [~,a_pn] = min(abs(a_i_TEMPn(1,i)*ones(A,1)-s_a)); % position in m of b(t)
    
    id_p = A*(mpath(1+100,i)-1) + a_p;
    id_pn = A*(mpath(1+100,i)-1) + a_pn;
    
        c_i_TEMP(1,i) = c_TEMP(id_p,1);
        a_i_TEMP(2,i) = ap_TEMP(id_p,1);
        y_i_TEMP(1,i) = Y_mat_TEMP(1).*exp(s_mu(mpath(1+100,i)));
        
        c_i_TEMPn(1,i) = c_TEMPn(id_pn,1);
        a_i_TEMPn(2,i) = ap_TEMPn(id_pn,1);
        y_i_TEMPn(1,i) = Y_mat_TEMPn(1).*exp(s_mu(mpath(1+100,i)));
        
end

% path shock

for t = 2:length(Y_mat_TEMP)-1
for i = 1:N
    
    [~,a_p] = min(abs(a_i_TEMP(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    [~,a_pn] = min(abs(a_i_TEMPn(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(t+100,i)-1) + a_p;
    id_pn = A*(mpath(t+100,i)-1) + a_pn;
    
        c_i_TEMP(t,i) = c_TEMP(id_p,t);
        a_i_TEMP(t+1,i) = ap_TEMP(id_p,t);
        y_i_TEMP(t,i) = Y_mat_TEMP(t).*exp(s_mu(mpath(t+100,i)));
        
        c_i_TEMPn(t,i)   = c_TEMPn(id_pn,t);
        a_i_TEMPn(t+1,i) = ap_TEMPn(id_pn,t);
        y_i_TEMPn(t,i)   = Y_mat_TEMPn(t).*exp(s_mu(mpath(t+100,i)));
        
end
end

% after shock

for t = length(Y_mat_TEMP):T
for i = 1:N
    
    [~,a_p] = min(abs(a_i_TEMP(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    [~,a_pn] = min(abs(a_i_TEMPn(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(t+100,i)-1) + a_p;
    id_pn = A*(mpath(t+100,i)-1) + a_pn;
    
        c_i_TEMP(t,i)   = c_TEMP(id_p,length(Y_mat_TEMP));
        a_i_TEMP(t+1,i) = ap_TEMP(id_p,length(Y_mat_TEMP));
        y_i_TEMP(t,i)   = Y_mat_TEMP(length(Y_mat_TEMP)).*exp(s_mu(mpath(t+100,i)));

        c_i_TEMPn(t,i)   = c_TEMPn(id_pn,length(Y_mat_TEMPn));
        a_i_TEMPn(t+1,i) = ap_TEMPn(id_pn,length(Y_mat_TEMPn));
        y_i_TEMPn(t,i)   = Y_mat_TEMPn(length(Y_mat_TEMPn)).*exp(s_mu(mpath(t+100,i)));        
end
end

C_TEMP_ag = sum(c_i_TEMP')/N;
Y_TEMP_ag = sum(y_i_TEMP')/N;

C_TEMPn_ag = sum(c_i_TEMPn')/N;
Y_TEMPn_ag = sum(y_i_TEMPn')/N;

C_dist_TEMP = zeros(T,length(s_mu));
Y_dist_TEMP = zeros(T,length(s_mu));
a_dist_TEMP = zeros(T,length(s_mu));

C_dist_TEMPn = zeros(T,length(s_mu));
Y_dist_TEMPn = zeros(T,length(s_mu));
a_dist_TEMPn = zeros(T,length(s_mu));

for i = 1:length(s_mu)
    
    er = s_mu(i) - s_mu(mpath(101:end,:));
    id = (er==0);
    cons = id.*c_i_TEMP;
    inc = id.*y_i_TEMP;
    asse = id.*a_i_TEMP(2:end,:);
    
    consn = id.*c_i_TEMPn;
    incn = id.*y_i_TEMPn;
    asse = id.*a_i_TEMPn(2:end,:);
    
    ni = sum(id')';
    C_dist_TEMP(:,i) = sum(cons')'./ni;   
    Y_dist_TEMP(:,i) = sum(inc')'./ni;
    a_dist_TEMP(:,i) = sum(asse')'./ni;
    
    C_dist_TEMPn(:,i) = sum(consn')'./ni;   
    Y_dist_TEMPn(:,i) = sum(incn')'./ni; 
    a_dist_TEMPn(:,i) = sum(assen')'./ni;
end

mpc_t_TEMP = (C_dist_TEMP(2,:) - C_dist_TEMPn(2,:))./par.transf_matrix(2,:);
mpc_ag_TEMP = (C_TEMP_ag(2) - C_TEMPn_ag(2))./par.eta;

% hand-to-mouth agents

htm_TEMP  = (a_i_TEMP(1:end-1,:) <= min(agridlin) +y_i_TEMP./24);
htm_TEMPn = (a_i_TEMPn(1:end-1,:) <= min(agridlin) +y_i_TEMPn./24);

mpc_TEMP_htm = ((sum(htm_TEMPn(2,:).*c_i_TEMP(2,:))- sum(htm_TEMPn(2,:).*c_i_TEMPn(2,:)))/sum(htm_TEMPn(2,:)))./mean(par.transf_matrix(2,:));
mpc_TEMP_nhtm = ((sum((1-htm_TEMPn(2,:)).*c_i_TEMP(2,:))- sum((1-htm_TEMPn(2,:)).*c_i_TEMPn(2,:)))/sum((1-htm_TEMPn(2,:))))./mean(par.transf_matrix(2,:));

%% deciles for plots

nmu_cum = cumsum(nmu);
mpc_t_T_plot    = interp1(nmu_cum(8:23),mpc_t_T(8:23),0.05:.1:.95,'linear','extrap');
mpc_t_TEMP_plot = interp1(nmu_cum(8:23),mpc_t_TEMP(8:23),0.05:.1:.95,'linear','extrap');
mpc_t_PI_plot   = interp1(nmu_cum(8:23),mpc_t_PI(8:23),0.05:.1:.95,'linear','extrap');
mpc_t_FF_plot   = interp1(nmu_cum(8:23),mpc_t_FF(8:23),0.05:.1:.95,'linear','extrap');








