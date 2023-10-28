%% MIT shocks
 
par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)
       par.Y_mat(hh) = par.Y_mat(hh-1).*exp(-drop*pers_perm^(hh-2));
end
par.kappa_mat = par.kappa.*ones(40,1); % remains unchanged

[c_PI,ap_PI,y_PI,a_PI] = policy_shock_hun(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_PI = par.Y_mat;

drop = drop/pers_temp;

par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)-1
       par.Y_mat(hh) = par.Y.*exp(-drop*pers_temp^(hh-1));
end
par.Y_mat(end) = par.Y;
par.kappa_mat = par.kappa.*par.Y_mat.^nu; % kappa drops and recovers

[c_FF,ap_FF,y_FF,a_FF] = policy_shock_hun(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_FF = par.Y_mat;

%% simulate - start from initial st-st and use policy functions with shocks

Pmu = Grid.Pmu_mat;

T = 100;
N = 100000;
first = 100;

% idio income

mpath=zeros(T+first,N);
M = Grid.nmulin;

ishock_m =rand(N,1);
shockm =rand(T+first-1,N);

temp = cumsum(nmu);

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
for t=2:first+1
    
    temp=cumsum(Pmu(mpath(t-1,i),:,1));
    
    if shockm(t-1,i)<temp(1)
        mpath(t,i)=1;
    elseif shockm(t-1,i)>temp(M)
        mpath(t,i)=M;
    else
        mpath(t,i)=find(shockm(t-1,i)<=temp(2:M) & shockm(t-1,i)>temp(1:M-1))+1 ;
    end
    
end
end

for i = 1:N
for t=first+2:first+39
    
    temp=cumsum(Pmu(mpath(t-1,i),:,t-first));
    
    if shockm(t-1,i)<temp(1)
        mpath(t,i)=1;
    elseif shockm(t-1,i)>temp(M)
        mpath(t,i)=M;
    else
        mpath(t,i)=find(shockm(t-1,i)<=temp(2:M) & shockm(t-1,i)>temp(1:M-1))+1 ;
    end
    
end
end

for i = 1:N
for t=first+40:T+first
    
    temp=cumsum(Pmu(mpath(t-1,i),:,40));
    
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
    
        c_initial(t,i) = c_FF(id_p,1);
        a_initial(t+1,i) = ap_FF(id_p,1);
        y_initial(t,i) = Y_mat_FF(1).*exp(s_mu(mpath(t,i)));
        
end
end

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
    
    id_p = A*(mpath(1+first,i)-1) + a_p;
    
        c_i_FF(1,i) = c_FF(id_p,1);
        a_i_FF(2,i) = ap_FF(id_p,1);
        y_i_FF(1,i) = Y_mat_FF(1).*exp(s_mu(mpath(1+first,i)));
        
end

% path shock

for t = 2:length(Y_mat_FF)-1
for i = 1:N
    
    [~,a_p] = min(abs(a_i_FF(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(t+first,i)-1) + a_p;
    
        c_i_FF(t,i) = c_FF(id_p,t);
        a_i_FF(t+1,i) = ap_FF(id_p,t);
        y_i_FF(t,i) = Y_mat_FF(t).*exp(s_mu(mpath(t+first,i)));
        
end
end

% after shock

for t = length(Y_mat_FF):T
for i = 1:N
    
    [~,a_p] = min(abs(a_i_FF(t,i)*ones(A,1)-s_a)); % position in m of b(t) 
    
    id_p = A*(mpath(t+first,i)-1) + a_p;
    
        c_i_FF(t,i) = c_FF(id_p,length(Y_mat_FF));
        a_i_FF(t+1,i) = ap_FF(id_p,length(Y_mat_FF));
        y_i_FF(t,i) = Y_mat_FF(length(Y_mat_FF)).*exp(s_mu(mpath(t+first,i)));
        
end
end

C_FF_ag = sum(c_i_FF')/N;
Y_FF_ag = sum(y_i_FF')/N;

C_dist_FF = zeros(T,length(s_mu));
Y_dist_FF = zeros(T,length(s_mu));

for i = 1:length(s_mu)
    
    er = s_mu(i) - s_mu(mpath(first+1:end,:));
    id = (er==0);
    cons = id.*c_i_FF;
    inc = id.*y_i_FF;
    ni = sum(id')';
    C_dist_FF(:,i) = sum(cons')'./ni;   
    Y_dist_FF(:,i) = sum(inc')'./ni;
    
end

elast_FF_hun = (log(C_dist_FF(:,:)) - log(C_dist_FF(1,:)))./(log(Y_dist_FF(:,:)) - log(Y_dist_FF(1,:)));
mpc_FF_hun = ((C_dist_FF(:,:)) - (C_dist_FF(1,:)))./((Y_dist_FF(:,:)) - (Y_dist_FF(1,:)));
id_Cadjust = (c_i_FF == 10e-07);

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

C_PI_ag = sum(c_i_PI')/N;
Y_PI_ag = sum(y_i_PI')/N;

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

elast_PI_hun = (log(C_dist_PI(:,:)) - log(C_dist_PI(1,:)))./(log(Y_dist_PI(:,:)) - log(Y_dist_PI(1,:)));
mpc_PI_hun = ((C_dist_PI(:,:)) - (C_dist_PI(1,:)))./((Y_dist_PI(:,:)) - (Y_dist_PI(1,:)));

%% simulation for large panel of income using heterogeneous process for uncertainty

par.sig_mu_mat_10 = par.sig_mu_mat(1:40,12:21); % in each decile

% initial period
N = 100000;

inshockm = normrnd(-1/2*(par.sig_mu.^2)/(1+par.rho_mu),par.sig_mu,101,N);
y_in = zeros(101,N);
y_in(1,:) = inshockm(1,:);
for t = 2:101
   y_in(t,:) = par.rho_mu.*y_in(t-1,:) + inshockm(t,:);    
end

y_in = y_in(101,:); % initial distribution

% loop for income process

y_sim = zeros(40,N);
y_sim(1,:) = y_in;
shockm = zeros(10,N);

for t = 2:40
    for i = 1:10
   shockm(i,:) = normrnd(-1/2*(par.sig_mu.^2)/(1+par.rho_mu),par.sig_mu_mat_10(t,i),1,N); 
    end
    
    col = sort(exp(y_sim(t-1,:)),2, 'ascend')';
    cdf = cumsum(ones(length(y_sim(t-1,:)),1)); % Compute cdf
    cdf = cdf/cdf(end); % Normalize
    % Find index of top 20 %
    index = find(cdf >= 0.9,1,'first');
    p90 = col(index);        
    index = find(cdf >= 0.8,1,'first');
    p80 = col(index);
    index = find(cdf >= 0.7,1,'first');
    p70 = col(index);    
    index = find(cdf >= 0.6,1,'first');
    p60 = col(index);        
    index = find(cdf >= 0.5,1,'first');
    p50 = col(index);
    index = find(cdf >= 0.4,1,'first');
    p40 = col(index);
    index = find(cdf >= 0.3,1,'first');
    p30 = col(index);        
    index = find(cdf >= 0.2,1,'first');
    p20 = col(index);
    index = find(cdf >= 0.1,1,'first');
    p10 = col(index);
    
    y_sim(t,:) = par.rho_mu.*y_sim(t-1,:) + ...
        (exp(y_sim(t-1,:))>=p90).*shockm(10,:) + ...
        (exp(y_sim(t-1,:))>=p80 & exp(y_sim(t-1,:))<p90).*shockm(9,:) + ...
        (exp(y_sim(t-1,:))>=p70 & exp(y_sim(t-1,:))<p80).*shockm(8,:) + ...
        (exp(y_sim(t-1,:))>=p60 & exp(y_sim(t-1,:))<p70).*shockm(7,:) + ...
        (exp(y_sim(t-1,:))>=p50 & exp(y_sim(t-1,:))<p60).*shockm(6,:) + ...
        (exp(y_sim(t-1,:))>=p40 & exp(y_sim(t-1,:))<p50).*shockm(5,:) + ...
        (exp(y_sim(t-1,:))>=p30 & exp(y_sim(t-1,:))<p40).*shockm(4,:) + ...
        (exp(y_sim(t-1,:))>=p20 & exp(y_sim(t-1,:))<p30).*shockm(3,:) + ...
        (exp(y_sim(t-1,:))>=p10 & exp(y_sim(t-1,:))<p20).*shockm(2,:) + ...
        (exp(y_sim(t-1,:))<p10).*shockm(1,:) ;
                    
    
end

sig_dist_large = zeros(40,10);
y_dist_large = zeros(40,10);

for t = 1:40

    col = sort(exp(y_sim(t,:)),2, 'ascend')';
    cdf = cumsum(ones(length(y_sim(t,:)),1)); % Compute cdf
    cdf = cdf/cdf(end); % Normalize
    % Find index of top 20 %
    index = find(cdf >= 0.9,1,'first');
    p90 = col(index);        
    index = find(cdf >= 0.8,1,'first');
    p80 = col(index);
    index = find(cdf >= 0.7,1,'first');
    p70 = col(index);    
    index = find(cdf >= 0.6,1,'first');
    p60 = col(index);        
    index = find(cdf >= 0.5,1,'first');
    p50 = col(index);
    index = find(cdf >= 0.4,1,'first');
    p40 = col(index);
    index = find(cdf >= 0.3,1,'first');
    p30 = col(index);        
    index = find(cdf >= 0.2,1,'first');
    p20 = col(index);
    index = find(cdf >= 0.1,1,'first');
    p10 = col(index);
    
    y_sim_t = y_sim(t,:);
    y_dist_large(t,10) = mean(exp(y_sim_t(exp(y_sim_t)>=p90)),2);
    y_dist_large(t,9) = mean(exp(y_sim_t(exp(y_sim_t)>=p80 & exp(y_sim_t)<p90)),2);
    y_dist_large(t,8) = mean(exp(y_sim_t(exp(y_sim_t)>=p70 & exp(y_sim_t)<p80)),2);
    y_dist_large(t,7) = mean(exp(y_sim_t(exp(y_sim_t)>=p60 & exp(y_sim_t)<p70)),2);
    y_dist_large(t,6) = mean(exp(y_sim_t(exp(y_sim_t)>=p50 & exp(y_sim_t)<p60)),2);
    y_dist_large(t,5) = mean(exp(y_sim_t(exp(y_sim_t)>=p40 & exp(y_sim_t)<p50)),2);
    y_dist_large(t,4) = mean(exp(y_sim_t(exp(y_sim_t)>=p30 & exp(y_sim_t)<p40)),2);
    y_dist_large(t,3) = mean(exp(y_sim_t(exp(y_sim_t)>=p20 & exp(y_sim_t)<p30)),2);
    y_dist_large(t,2) = mean(exp(y_sim_t(exp(y_sim_t)>=p10 & exp(y_sim_t)<p20)),2);
    y_dist_large(t,1) = mean(exp(y_sim_t(exp(y_sim_t)<p10)),2);
    
    sig_dist_large(t,10) = std(y_sim_t(exp(y_sim_t)>=p90));
    sig_dist_large(t,9) = std(y_sim_t(exp(y_sim_t)>=p80 & exp(y_sim_t)<p90));
    sig_dist_large(t,8) = std(y_sim_t(exp(y_sim_t)>=p70 & exp(y_sim_t)<p80));
    sig_dist_large(t,7) = std(y_sim_t(exp(y_sim_t)>=p60 & exp(y_sim_t)<p70));
    sig_dist_large(t,6) = std(y_sim_t(exp(y_sim_t)>=p50 & exp(y_sim_t)<p60));
    sig_dist_large(t,5) = std(y_sim_t(exp(y_sim_t)>=p40 & exp(y_sim_t)<p50));
    sig_dist_large(t,4) = std(y_sim_t(exp(y_sim_t)>=p30 & exp(y_sim_t)<p40));
    sig_dist_large(t,3) = std(y_sim_t(exp(y_sim_t)>=p20 & exp(y_sim_t)<p30));
    sig_dist_large(t,2) = std(y_sim_t(exp(y_sim_t)>=p10 & exp(y_sim_t)<p20));
    sig_dist_large(t,1) = std(y_sim_t(exp(y_sim_t)<p10));

end

change_vol_dist = sig_dist_large(3,:)./sig_dist_large(1,:); % change in volatility to fit the data


