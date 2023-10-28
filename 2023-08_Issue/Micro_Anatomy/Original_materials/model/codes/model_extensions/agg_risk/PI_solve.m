%% PI model solution

% use endogenous grid method and compute elasticties using policy function

%% bounds and nodes in state-space

Grid.na         = 300;       % number of points for assets a grid construction
Grid.nz         = 7;        % number of points for z grid
Grid.ng         = 7;        % number of points for g grid
Grid.nmu         = 31;       % number of points for mu grid

mu_scale   = sqrt(Grid.nmu-1);
[mugrid, Grid.Pmu]  = tauchen(-1/2*(par.sig_mu.^2)/(1-par.rho_mu.^2), par.rho_mu, par.sig_mu, Grid.nmu, mu_scale);
Grid.mumin = min(mugrid);
Grid.mumax = max(mugrid);

z_scale   = sqrt(Grid.nz-1);                             
[zgrid, Grid.Pz]  = tauchen(- 1/2*(par.sig_z.^2)/(1-par.rho_z.^2), par.rho_z, par.sig_z,Grid.nz, z_scale);
Grid.zmin = min(zgrid);
Grid.zmax = max(zgrid);

g_scale   = sqrt(Grid.ng-1);
[ggrid, Grid.Pg]  = tauchen(par.alpha_g - 1/2*(par.sig_g.^2)/(1-par.rho_g.^2), par.rho_g, par.sig_g, Grid.ng, g_scale);
Grid.gmin = min(ggrid);
Grid.gmax = max(ggrid);

% assets

Grid.amin = -1.5; % natural debt limit: exp(Grid.gmin + Grid.zmin + Grid.mumin)./(1+par.r_star-exp(Grid.zmin))
Grid.amax =  130; % 30
% agrid = Grid.amin + (Grid.amax - Grid.amin)*linspace(0, 1, round(Grid.na*3))'.^3;
a1 = Grid.amin + (.99999 - Grid.amin)*linspace(0, 1, round(2*Grid.na))'.^1.5;
a2 = 1 + (Grid.amax - 1)*linspace(0, 1, round(Grid.na*3))'.^1.5;
agrid = [a1;a2];

Grid.na = length(agrid);
    
%% grid

Grid.fspacelin     = fundef({'spli', agrid,  0, 1}, ...
                         {'spli', zgrid,  0, 1}, ...
                         {'spli', ggrid,  0, 1}, ...
                         {'spli', mugrid,  0, 1});

Grid.s      = gridmake(funnode(Grid.fspacelin)); % state na*nz*ng*nmu rows and 4 columns for each variable

Grid.n      = size(Grid.s, 1);

%% initial guess

% rename variables to simplify notation
s_a = agrid;
s_z = zgrid;
s_g = ggrid;
s_mu = mugrid;
n_a = Grid.na;
n_z = Grid.nz;
n_g = Grid.ng;
n_mu = Grid.nmu;
N   = Grid.n;
s     = Grid.s;

% locates first value of the grid of assets in the state-space 
atilde0_id = [1; zeros(n_a-1,1)];
atilde0_id = logical(repmat(atilde0_id,[n_z*n_g*n_mu, 1]));

% guess for consumption (5% of "binding" consumption)
ctilde_bind = exp( s(:,2) +  s(:,3) + s(:,4) ) + (1+par.r_star).*s(:,1) - exp(s(:,3)).*s(1,1) + 0.0000000001;
for i =1:N 
   if ctilde_bind(i)<=0 
       ctilde_bind(i) =1e-12; % return;
   else
       ctilde_bind(i)=ctilde_bind(i);
   end
       
end
c0 = ctilde_bind*.05;

%% EGM iteration

maxiter = 200;
tol=1e-9;

for iter=1:maxiter

% using guess of c' compute EE equation to invert
uc = c0.^(-par.sigma); 
uc = reshape( uc,[n_a n_z n_g n_mu] );

B = permute(uc, [1 3 4 2]);
B = reshape(B, [n_a*n_g*n_mu n_z]);
B = Grid.Pz*B';

B = reshape(B', [n_a n_g n_mu n_z]);
B = permute(B, [1 3 4 2]);
B = reshape(B, [n_a*n_z*n_mu n_g]);
B = Grid.Pg*B';

B = reshape(B', [n_a n_mu n_z n_g]);
B = permute(B, [1 3 4 2]);
B = reshape(B, [n_a*n_z*n_g n_mu]);
B = Grid.Pmu*B';

B = reshape(B', [N 1]);
B = par.beta*(1+par.r_star)*exp(-par.sigma*s(:,3)).*B;

% consumption and assets as if collateral constraint not binding
ctilde = B.^(-1/par.sigma);
atilde = (1/(1+par.r_star)).*( ctilde + exp(s(:,3)).*s(:,1) - exp( s(:,2) + s(:,3) + s(:,4) ) );

% assets next period that induce binding constraint today
atilde0 = atilde(atilde0_id);
atilde0 = reshape(atilde0, [n_z n_g n_mu]);

atilde      = reshape(atilde,[n_a n_z n_g n_mu]);
ctilde      = reshape(ctilde,[n_a n_z n_g n_mu]);
ctilde_bind = reshape(ctilde_bind,[n_a n_z n_g n_mu]);

c1=zeros(n_a, n_z, n_g,n_mu);
bind_mat = zeros(n_a,n_z, n_g,n_mu);

% solution
for i=1:n_z
    for k=1:n_g
        for h=1:n_mu
    bind = ( s_a <= atilde0(i,k,h) );
    bind_mat(:,i,k,h) = bind;
    % bind = 0; % no binding
    c1(:,i,k,h)   = (1-bind).*interp1( atilde(:,i,k,h), ctilde(:,i,k,h), s_a, 'linear', 'extrap' ) + bind.*ctilde_bind(:,i,k,h);      
        end
    end
end

bind_mat = bind_mat(:);
c1 = reshape(c1,[N 1]);

if norm( c1-c0 )/norm(c0) < tol , break, end

c0=c1;


end

%% elasticities 

c = c1;
y =  exp(s(:,2) + s(:,3) + s(:,4));
ap =  (y + (1+par.r_star).*s(:,1) - c)./exp(s(:,3));

c = reshape(c,[n_a n_z n_g n_mu]);
ap = reshape(ap,[n_a n_z n_g n_mu]);
y = reshape(y,[n_a n_z n_g n_mu]);

zmed = round(n_z/2);
gmed = round(n_g/2);
mumed = round(n_mu/2);


%% distribution of assets

T = 100000;

% z path

muz = - 1/2*(par.sig_z.^2)/(1-par.rho_z.^2);
z = s_z;
Z = n_z;

shockz=rand(T,1); %shockz is uniform between 0 and 1
zpath=zeros(T,1);
zpath(1,1)=find(z==max(z(find(abs(muz-z)==min(abs(muz-z)))))); %start zpath at z closest to steady state

for t=2:T
    temp=cumsum(Grid.Pz(zpath(t-1),:));
    if shockz(t)<temp(1)
        zpath(t,1)=1;
    elseif shockz(t)>temp(Z)
        zpath(t,1)=Z;
    else
        zpath(t,1)=find(shockz(t)<=temp(2:Z) & shockz(t)>temp(1:Z-1))+1 ;
    end
end

% g path

mug = par.alpha_g - 1/2*(par.sig_g.^2)/(1-par.rho_g.^2);
g = s_g;
G = n_g;

shockg=rand(T,1); %shockz is uniform between 0 and 1
gpath=zeros(T,1);
gpath(1,1)=find(g==max(g(find(abs(mug-g)==min(abs(mug-g)))))); %start zpath at g closest to steady state

for t=2:T
    temp=cumsum(Grid.Pg(gpath(t-1),:));
    if shockg(t)<temp(1)
        gpath(t,1)=1;
    elseif shockz(t)>temp(G)
        gpath(t,1)=G;
    else
        gpath(t,1)=find(shockg(t)<=temp(2:Z) & shockg(t)>temp(1:Z-1))+1 ;
    end
end

% mu path

mum = - 1/2*(par.sig_mu.^2)/(1-par.rho_mu.^2);
mu = s_mu;
M = n_mu;

shockm=rand(T,1); %shockz is uniform between 0 and 1
mpath=zeros(T,1);
mpath(1,1)=find(mu==max(mu(find(abs(mum-mu)==min(abs(mum-mu)))))); %start zpath at g closest to steady state

for t=2:T
    temp=cumsum(Grid.Pmu(mpath(t-1,1),:));
    if shockm(t-1,1)<temp(1)
        mpath(t,1)=1;
    elseif shockm(t-1,1)>temp(M)
        mpath(t,1)=M;
    else
        mpath(t,1)=find(shockm(t-1,1)<=temp(2:M) & shockm(t-1,1)>temp(1:M-1))+1 ;
    end
end

% assets in steady-state

assets_dist = zeros(T+1,1);
B = n_a;

for t=1:T
    
    [~,b_p] = min(abs(assets_dist(t,1)*ones(B,1)-s_a(:,1)));
    
    id_p = (Z*B*G)*(mpath(t,1)-1) + (Z*B)*(gpath(t)-1) + B*(zpath(t)-1) + b_p;
    
        assets_dist(t+1,1) = ap(id_p);
        
end

assets_dist = assets_dist(100:end-1,1);
mpath = mpath(100:end,1);

assets_st_PI = zeros(31,1);

for i=1:31
assets_st_PI(i,1) = mean(assets_dist(mpath==i));
end

% elasticity using policy functions

elast_PI_st = zeros(23-8+1,1);

for i = 8:23
[~,ida] = min(abs(agrid-assets_st_PI(i,1)));

dC = log(c(ida,zmed,1,i)) - log(c(ida,zmed,gmed,i));
dY = log(y(ida,zmed,1,i)) - log(y(ida,zmed,gmed,i));

elast_PI_st(i-7,1)=dC./dY;

end


