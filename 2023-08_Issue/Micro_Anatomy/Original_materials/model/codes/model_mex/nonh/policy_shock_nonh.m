function [c_policy, a_policy,y_grid,a_grid] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol)

% length of shock
T = length(par.Y_mat) - 1;

% one time shock
if T == 1 
    
    c_policy = zeros(N,2);
    a_policy = zeros(N,2);
    y_grid = zeros(N,2);
    a_grid = s_a;
    
       % initial
       par.Y = par.Y_mat(1);
       par.kappa = par.kappa(1);
       [c_policy(:,1),y_grid(:,1),a_policy(:,1),~] = solutionEGM_nonh(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol);
       
       % final
       par.Y = par.Y_mat(2);
       par.kappa = par.kappa_mat(2);
       mu_scale   = sqrt(Grid.nmu-1);
              
       [mugrid, Grid.Pmu]  = tauchen(-1/2*(par.sig_mu.^2)/(1-par.rho_mu.^2), par.rho_mu, par.sig_mu, Grid.nmu, mu_scale);
       Grid.mumin = min(mugrid);
       Grid.mumax = max(mugrid);
       Grid.amin      = - par.kappa; 
       Grid.amax =  100;
       agrid = Grid.amin + (Grid.amax - Grid.amin)*linspace(0, 1, round(Grid.na)).^2';
       Grid.na = length(agrid);
       Grid.fspacelin     = fundef({'spli', agrid,  0, 1}, ...
                         {'spli', mugrid,  0, 1});
       Grid.s      = gridmake(funnode(Grid.fspacelin));
       Grid.n      = size(Grid.s, 1);
       
       [c_policy_aux,~,~,~] = solutionEGM_nonh(par,Grid,Grid.s,agrid,mugrid,length(agrid),length(mugrid),length(Grid.s),maxiter,tol);
       
       c_policy_aux = reshape(c_policy_aux,[length(agrid) n_mu]);
       c_policy_aux_2 = zeros(length(agrid),n_mu);
       
       for j=1:n_mu
       c_policy_aux_2(:,j) = interp1( agrid, c_policy_aux(:,j), s_a, 'linear', 'extrap' );
       end
       c_policy(:,2) = c_policy_aux_2(:);
       
       idB = (c_policy(:,2)<=1e-6);
       c_policy(idB,2) = 1e-6; % minimum consumption
       y_grid(:,2) =  par.Y.*exp(s(:,2));
       a_policy(:,2) = y_grid(:,2) + (1+par.r_star).*s(:,1) - c_policy(:,2);
          
end
    

% sequence of shocks

if T > 1  
    
    c_policy = zeros(N,T+1);
    a_policy = zeros(N,T+1);
    y_grid = zeros(N,T+1);
    a_grid = s_a;
               
       % initial and final policies
       par.Y = par.Y_mat(1);
       par.kappa = par.kappa_mat(1);
       [c_policy(:,1),y_grid(:,1),a_policy(:,1),~] = solutionEGM_nonh(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol);
       
       par.Y = par.Y_mat(T+1);
       par.kappa = par.kappa_mat(T+1);
       [c_policy(:,T+1),y_grid(:,T+1),a_policy(:,T+1),~] = solutionEGM_nonh(par,Grid,s,s_a,s_mu,n_a,n_mu,N,maxiter,tol);
       
       % 0 < t < T - iterate EE backwards
       
       for i = T:-1:2
       
       y_grid(:,i) = par.Y_mat(i).*exp(s(:,2));
       
       atilde0_id=zeros(N,1);

     for j=1:n_mu
    [~,aa] = min( abs( s_a - (-par.kappa_mat(i)) ) );
    atilde0_id(aa+(j-1)*n_a) = 1;
     end

     atilde0_id = logical(atilde0_id);
     ctilde_bind = (1+par.r_star)*s(:,1) + y_grid(:,i) + par.kappa_mat(i);

   for j =1:N
    if ctilde_bind(j)<=1e-6
       ctilde_bind(j)=1e-6; % min val
    else
       ctilde_bind(j)=ctilde_bind(j);
    end
       
   end
           
       c1 = c_policy(:,i+1)-par.cbar;    
              
for ii =1:N 
   if c1(ii)<=1e-6
       c1(ii) = 1e-6; % return;
   else
       c1(ii)=c1(ii);
   end       
end

       uc = c1.^(-par.sigma); 
       uc = reshape( uc,[n_a n_mu] );

       B = permute(uc, [1 2]);
       B = Grid.Pmu*B';
       B = reshape(B', [N 1]);
       B = par.beta*(1+par.r_star).*B;
              
       ctilde = B.^(-1/par.sigma)+par.cbar;
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



end