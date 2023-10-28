% computes transition proabilities for the idiosyncratic income with heterogeneous loadings to income dispersion


   Pmu = zeros(Grid.nmu,Grid.nmu,40);
   Pmu(:,:,1) = Grid.Pmu;
   Pmu(:,:,end) = Grid.Pmu;
   
   for i = 1:length(s_mu)          
   
   for t = 2:39              
  
   nmu_aux         = 1000;       % number of points for mu grid    
   par.sig_mu = par.sig_mu_mat(t,i);
   mu_scale   = sqrt(nmu_aux-1);
   [mugrid_aux, Pmu_aux]  = tauchen(-1/2*(par.sig_mu.^2)/(1-par.rho_mu.^2), par.rho_mu, par.sig_mu, nmu_aux, mu_scale);
   Grid.mumin = min(mugrid_aux);
   Grid.mumax = max(mugrid_aux);
   id_mu_mat = zeros(length(s_mu),1);
   for pp = 1:length(s_mu)
   [~,id_mu_mat(pp)] = min(abs(mugrid_aux-s_mu(pp)*ones(length(mugrid_aux),1)));
   end
   
   Pmu_it=Pmu_aux(id_mu_mat,id_mu_mat)'./sum(Pmu_aux(id_mu_mat,id_mu_mat)');
   Pmu_it = Pmu_it';
   Pmu(i,:,t) = Pmu_it(i,:);
   
   end
   
   end