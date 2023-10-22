function [Gains]=f_Obj_MPEC_RE(X, N , S, e_ik3D, sigma_k3D, mu_k3D, lambda_jik3D, tjik_3D_app, id)

wi_h=abs(X(1:N));% Nx1, mod to avoid complex numbers...
wi_h3D=repmat(wi_h,[1 N S]); % construct 3D cubes from 1D vectors
Ei_h=abs(X(N+1:N+N));

% Construct 3D cube of Nash tariffs
 tjik = abs(X(2*N+1:2*N+(N-1)*S));
 tjik_temp = 1 + tjik_3D_app; tjik_temp([1:id-1 id+1:N],id,:)=reshape(tjik,N-1,1,S);
 tjik_3D = repmat(eye(N), [1 1 S]) + tjik_temp.*repmat(1-eye(N), [1 1 S]) - 1 ;
 tjik_h3D = (1+tjik_3D)./(1+tjik_3D_app);
 

 xjik=abs(X(2*N+(N-1)*S+1:end));
 xjik_3D=ones(N,N,S); 
 xjik_3D(id,[1:id-1 id+1:N],:)=reshape(xjik,1,N-1,S);
 xjik_h3D = xjik_3D;

 sik_3D = zeros(N,N,S);  sik_h3D= 1 + sik_3D;
%  sik_3D = zeros(N,N,S);  sik_3D(id,:,:)=(1./(1+mu_k3D(id,:,:))) - 1;
%  sik_h3D= 1 + sik_3D;

% Calculate the change in price indexes
tau_h = tjik_h3D.*xjik_h3D.*sik_h3D;
AUX0=((tau_h.*wi_h3D).^(1-sigma_k3D));
AUX1=lambda_jik3D.*AUX0;
Pi_h = exp(sum((e_ik3D(1,:,:)./(1-sigma_k3D(1,:,:))).*log(sum(AUX1,1)),3))';

% Calculate the change in welfare
Wi_h = Ei_h./Pi_h;
Gains = -100*(Wi_h(id)-1);
end