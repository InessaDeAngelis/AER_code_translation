function [c,y,ap,bind_mat] = solutionEGM(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol)

y_mu = exp( s(:,2) );
atilde0_id=zeros(n_a*n_mu,1);

for i=1:n_mu
    [~,aa] = min( abs( s_a - (-par.kappa*(y_mu(((i-1)*n_a+1):((i-1)*n_a+n_a)).^par.nu_mu).*(par.Y)) ) );
    atilde0_id(aa+(i-1)*n_a) = 1;
end

y = par.Y.*exp( s(:,2) );

atilde0_id = logical(atilde0_id);
ctilde_bind = (1+par.r_star)*s(:,1) + y + par.kappa.*(exp( s(:,2) ).^par.nu_mu).*(par.Y);

for i =1:N
   if ctilde_bind(i)<=0 
       ctilde_bind(i)=1e-7; % min val
   else
       ctilde_bind(i)=ctilde_bind(i);
   end
       
end

c0 = ctilde_bind*.05;


for iter=1:maxiter

% using guess of c' compute RHS of EE equation    
uc = c0.^(-par.sigma); 
uc = reshape( uc,[n_a n_mu] );

B = permute(uc, [1 2]);
B = Grid.Pmu*B';
B = reshape(B', [N 1]);
B = par.beta*(1+par.r_star).*B;

% consumption and assets as if collateral constraint not binding
ctilde = B.^(-1/par.sigma);
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