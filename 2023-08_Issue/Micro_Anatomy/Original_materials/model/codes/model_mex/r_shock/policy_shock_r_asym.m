function [c_policy, a_policy,y_grid,a_grid] = policy_shock_r_asym(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol)

% length of shock
T = length(par.Y_mat) - 1;
    
    c_policy = zeros(N,T+1);
    a_policy = zeros(N,T+1);
    y_grid = zeros(N,T+1);
    a_grid = s_a;
               
       % initial and final policies
       par.Y = par.Y_mat(1);
       par.kappa = par.kappa_mat(1);
       par.r_star_l = par.lr_mat(1);        
       [c_policy(:,1),y_grid(:,1),a_policy(:,1),~] = solutionEGM_asym(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol);
       
       par.Y = par.Y_mat(T+1);
       par.kappa = par.kappa_mat(T+1);
       par.r_star_l = par.lr_mat(T+1);
       [c_policy(:,T+1),y_grid(:,T+1),a_policy(:,T+1),~] = solutionEGM_asym(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol);
       
       % 0 < t < T - iterate EE backwards
       
       for i = T:-1:2
       
       y_grid(:,i) = par.Y_mat(i).*exp(s(:,2));
       par.r_star_l = par.lr_mat(i);
       
       rmat = (s(:,1)<0).*par.r_star_l + (1-(s(:,1)<0)).*par.r_star_b; % rate depends on asset level
       
       atilde0_id=zeros(N,1);

     for j=1:n_mu
    [~,aa] = min( abs( s_a - (-par.kappa_mat(i)) ) );
    atilde0_id(aa+(j-1)*n_a) = 1;
     end

     atilde0_id = logical(atilde0_id);
     ctilde_bind = (1+rmat).*s(:,1) + y_grid(:,i) + par.kappa_mat(i);

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
       B = par.beta.*(1+rmat).*B;
              
       ctilde = B.^(-1/par.sigma);
       auxx = (ctilde + s(:,1) - par.Y.*exp( s(:,2) ));
       rmat_auxx = (auxx<0).*par.r_star_l + (1-(auxx<0)).*par.r_star_b; % rate depends on asset level
       atilde = (1./(1+rmat_auxx)).*( ctilde + s(:,1) - y_grid(:,i));
       
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
a_policy(:,i) =  y_grid(:,i) + (1+rmat).*s(:,1) - c_policy(:,i);
      
       
       end
     

end