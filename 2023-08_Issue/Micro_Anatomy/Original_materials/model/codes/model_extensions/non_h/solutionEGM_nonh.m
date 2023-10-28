function [c,y,ap,bind_mat] = solutionEGM_nonh(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol)

% locates first value of the grid of assets in the state-space 
atilde0_id = [1; zeros(n_a-1,1)];
atilde0_id = logical(repmat(atilde0_id,[n_mu, 1]));

% initial guess
y = par.Y.*exp( s(:,2) );
ctilde_bind = (1+par.r_star)*s(:,1) + y - s(1,1);
for i =1:N 
   if ctilde_bind(i)<=1e-6
       ctilde_bind(i) = 1e-6; % return;
   else
       ctilde_bind(i)=ctilde_bind(i);
   end       
end

c0 = ctilde_bind*.08;

for iter=1:maxiter
    
c0s = c0 - par.cbar;   

for i =1:N 
   if c0s(i)<=1e-6
       c0s(i) = 1e-6; % return;
   else
       c0s(i)=c0s(i);
   end       
end

% using guess of c' compute RHS of EE equation    
uc = c0s.^(-par.sigma); 
uc = reshape( uc,[n_a n_mu] );

B = permute(uc, [1 2]);
B = Grid.Pmu*B';
B = reshape(B', [N 1]);
B = par.beta*(1+par.r_star).*B;

% consumption and assets as if collateral constraint not binding
ctilde = B.^(-1/par.sigma) + par.cbar;
atilde = (1/(1+par.r_star))*( ctilde + s(:,1) - par.Y.*exp( s(:,2) ) );

% assets next period that induce binding constraint today
atilde0 = atilde(atilde0_id);

atilde      = reshape(atilde,[n_a n_mu]);
ctilde      = reshape(ctilde,[n_a n_mu]);
ctilde_bind = reshape(ctilde_bind,[n_a n_mu]);

c1=zeros(n_a, n_mu);
bind_mat = zeros(n_a,n_mu);

% solution

for h=1:n_mu
    bind = ( s_a <= atilde0(h) );
    bind_mat(:,h) = bind;  
    c1(:,h)   = (1-bind).*interp1( atilde(:,h), ctilde(:,h), s_a, 'linear', 'extrap' ) + bind.*ctilde_bind(:,h);      
end

bind_mat = bind_mat(:);
c1 = reshape(c1,[N 1]);

if norm( c1-c0 )/norm(c0) < tol , break, end

norm( c1-c0 )/norm(c0)

c0=c1;

end

c = c1;
y =  par.Y.*exp(s(:,2));
ap =  y + (1+par.r_star).*s(:,1) - c;

end