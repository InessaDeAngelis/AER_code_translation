function [c_policy, a_policy,y_grid,a_grid] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol)

% length of shock
T = length(par.Y_mat) - 1;

loadings_mu = zeros(n_mu,1);

loadings_mu(1:11,1) = par.loadings(1).*ones(11,1);
loadings_mu(12:21,1) = par.loadings(1:end,1);
loadings_mu(22:end,1) = par.loadings(end,1).*ones(n_mu-21,1);

loadings_mu = repmat(loadings_mu,[1 n_a]);
loadings_mu = loadings_mu';
loadings_mu = loadings_mu(:);

    c_policy = zeros(N,T+1);
    a_policy = zeros(N,T+1);
    y_grid = zeros(N,T+1);
    a_grid = s_a;
               
       % initial and final policies
       par.Y = par.Y_mat(1);
       par.kappa = par.kappa_mat(1);
       [c_policy(:,1),y_grid(:,1),a_policy(:,1),~] = solutionEGM_Yhet(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol);
       
       par.Y = par.Y_mat(T+1);
       par.kappa = par.kappa_mat(T+1);
       [c_policy(:,T+1),y_grid(:,T+1),a_policy(:,T+1),~] = solutionEGM_Yhet(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol);
       
       % 0 < t < T - iterate EE backwards
       
       for i = T:-1:2
       
       y_grid(:,i) = (par.Y_mat(i).^loadings_mu).*exp(s(:,2));
       
       atilde0_id=zeros(N,1);

     for j=1:n_mu
    [~,aa] = min( abs( s_a - (-par.kappa_mat(i)) ) );
    atilde0_id(aa+(j-1)*n_a) = 1;
     end

     atilde0_id = logical(atilde0_id);
     ctilde_bind = (1+par.r_star)*s(:,1) + y_grid(:,i) + par.kappa_mat(i);

   for j =1:N
    if ctilde_bind(j)<=10e-7 
       ctilde_bind(j)=10e-7; % min val
    else
       ctilde_bind(j)=ctilde_bind(j);
    end
       
   end
           
       c1 = c_policy(:,i+1);    
       uc = c1.^(-par.sigma); 
       uc = reshape( uc,[n_a n_mu] );

       B = permute(uc, [1 2]);
       B = Grid.Pmu*B';
       B = reshape(B', [N 1]);
       B = par.beta*(1+par.r_star).*B;
              
       ctilde = B.^(-1/par.sigma);
       atilde = (1/(1+par.r_star))*( ctilde + s(:,1) - y_grid(:,i));
       
       atilde0 = atilde(atilde0_id);

       atilde      = reshape(atilde,[n_a n_mu]);
       ctilde      = reshape(ctilde,[n_a n_mu]);
       ctilde_bind = reshape(ctilde_bind,[n_a n_mu]);

       csol=zeros(n_a, n_mu);
       bind_mat = zeros(n_a,n_mu);

% solution

for h=1:n_mu
    bind = ( s_a <= atilde0(h) );
    bind_mat(:,h) = bind;  
    csol(:,h)   = (1-bind).*interp1( atilde(:,h), ctilde(:,h), s_a, 'linear', 'extrap' ) + bind.*ctilde_bind(:,h);      
end


c_policy(:,i) = reshape(csol,[N 1]);
a_policy(:,i) =  y_grid(:,i) + (1+par.r_star).*s(:,1) - c_policy(:,i);
      
       
       end
     



end