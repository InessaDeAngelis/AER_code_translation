% Code plots market equilibium as a function of z (Figure 1 of the paper).
% it has a minor iteration to search for the parameters that deliver Delta =
% 0.2 (-0.2 for downside). 

clear
clc
close all
%common parameters

b      = 1.0; %baseline: 1
lambda = 1;  %baseline: 1
sigu   = 3;  %baseline: 2
tau    = b/sigu^2;
ubar   = 0.0; %baseline: 0
alpha  = 0.5; %baseline: 0.7
chi    = 0.15; %baseline: 0.15
a_up  = 0.7; %baseline: 0.7
b_up  = 0.5; %baseline: 0.5
a_dn  = 2.5; %baseline: 2.5
b_dn  = 0.5; %baseline: 0.5

n_u = 41;
sig_u = linspace(0.5,4,n_u);
Delta_up_vec = zeros(1,n_u);
Delta_dn_vec = zeros(1,n_u);

for u=1:n_u
    U = sig_u(u);
    tau    = b/U^2;
    
gp     =(b+tau)/(lambda+b+tau);
gv     =tau/(lambda+tau);
sigz   =lambda^(-0.5)*gv^(-0.5); %same as simply (lambda^-1+tau^-1)^0.5
Nt_grid  = 1000;
Nz_grid  = 1000;
theta = linspace(-6*lambda^(-0.5),6*lambda^(-0.5),Nt_grid);
Pr_theta = normcdf(theta,0,lambda^(-0.5));
Pr_theta(1,Nt_grid)  = 1;
Pr_theta(1,2:Nt_grid) = Pr_theta(1,2:Nt_grid)-Pr_theta(1,1:Nt_grid-1);

z     = linspace(-4*sigz,4*sigz,Nz_grid);
Pr_z  = normcdf(z,-ubar/(b^0.5),sigz);
Pr_z_RN  = normcdf(z,0,sigz);
Pr_z(1,Nz_grid)  = 1;
Pr_z(1,2:Nz_grid) = Pr_z(1,2:Nz_grid)-Pr_z(1,1:Nz_grid-1);
Pr_z_RN(1,Nz_grid)  = 1;
Pr_z_RN(1,2:Nz_grid) = Pr_z_RN(1,2:Nz_grid)-Pr_z_RN(1,1:Nz_grid-1);

%%%Div function

R_theta_up = a_up+exp(b_up*theta);
R_theta_dn =  a_dn-exp(-b_dn*theta);

Pr_theta_z_z = zeros(Nz_grid,Nt_grid);
Pr_theta_z   = zeros(Nz_grid,Nt_grid);
for i=1:Nz_grid
Pr_theta_z_z(i,:)= normcdf(theta,gp*(z(i)+(tau/(b+tau))*ubar/(b^-0.5)),lambda^(-0.5)*(1-gp)^0.5);
Pr_theta_z(i,:)= normcdf(theta,gv*(z(i)+ubar/(b^-0.5)),lambda^(-0.5)*(1-gv)^0.5);
end
Pr_theta_z_z(:,Nt_grid) = 1;
Pr_theta_z_z(:,2:Nt_grid)=Pr_theta_z_z(:,2:Nt_grid)-Pr_theta_z_z(:,1:Nt_grid-1);
Pr_theta_z(:,Nt_grid) = 1;
Pr_theta_z(:,2:Nt_grid)=Pr_theta_z(:,2:Nt_grid)-Pr_theta_z(:,1:Nt_grid-1);

P_z_up = R_theta_up*transpose(Pr_theta_z_z);
V_z_up = R_theta_up*transpose(Pr_theta_z);
E_P_up = P_z_up*transpose(Pr_z);
E_V_up = V_z_up*transpose(Pr_z);

I_star_up = (E_V_up)^(1/chi);
I_hat_up = (E_V_up + alpha*(E_P_up-E_V_up))^(1/chi);
Delta_up = E_P_up/E_V_up - 1;

Delta_up_vec(1,u)=Delta_up;


P_z_dn = R_theta_dn*transpose(Pr_theta_z_z);
V_z_dn = R_theta_dn*transpose(Pr_theta_z);
E_P_dn = P_z_dn*transpose(Pr_z);
E_V_dn = V_z_dn*transpose(Pr_z);

I_star_dn = (E_V_dn)^(1/chi);
I_hat_dn = (E_V_dn + alpha*(E_P_dn-E_V_dn))^(1/chi);
Delta_dn = E_P_dn/E_V_dn - 1;
Delta_dn_vec(1,u)=Delta_dn;

Pi_z_z_hat_up  = P_z_up*I_hat_up - I_hat_up^(1+chi)/(1+chi);
Pi_z_hat_up    = V_z_up*I_hat_up - I_hat_up^(1+chi)/(1+chi);
Pi_z_z_star_up = P_z_up*I_star_up - I_star_up^(1+chi)/(1+chi);
Pi_z_star_up   = V_z_up*I_star_up - I_star_up^(1+chi)/(1+chi);

E_Pi_z_z_hat_up  = Pi_z_z_hat_up*transpose(Pr_z);
E_Pi_z_hat_up    = Pi_z_hat_up*transpose(Pr_z);
E_Pi_z_z_star_up = Pi_z_z_star_up*transpose(Pr_z);
E_Pi_z_star_up   = Pi_z_star_up*transpose(Pr_z);

Pi_z_z_hat_dn  = P_z_dn*I_hat_dn - I_hat_dn^(1+chi)/(1+chi);
Pi_z_hat_dn    = V_z_dn*I_hat_dn - I_hat_dn^(1+chi)/(1+chi);
Pi_z_z_star_dn = P_z_dn*I_star_dn - I_star_dn^(1+chi)/(1+chi);
Pi_z_star_dn   = V_z_dn*I_star_dn - I_star_dn^(1+chi)/(1+chi);

Loss_up = (1-E_Pi_z_hat_up/E_Pi_z_star_up)*100;
Ratio_up = (E_Pi_z_z_hat_up/E_Pi_z_hat_up-1)*100;

E_Pi_z_z_hat_dn  = Pi_z_z_hat_dn*transpose(Pr_z);
E_Pi_z_hat_dn    = Pi_z_hat_dn*transpose(Pr_z);
E_Pi_z_z_star_dn = Pi_z_z_star_dn*transpose(Pr_z);
E_Pi_z_star_dn   = Pi_z_star_dn*transpose(Pr_z);

Loss_dn = (1-E_Pi_z_hat_dn/E_Pi_z_star_dn)*100;
Ratio_dn = (E_Pi_z_hat_dn/E_Pi_z_z_hat_dn-1)*100;

end

D_up = min(find(Delta_up_vec>0.2));
D_dn = min(find(Delta_dn_vec<-0.2));


for u=D_up
        U = sig_u(u);
    tau    = b/U^2;
    
gp     =(b+tau)/(lambda+b+tau);
gv     =tau/(lambda+tau);
sigz   =lambda^(-0.5)*gv^(-0.5); 
Nt_grid  = 1000;
Nz_grid  = 1000;
theta = linspace(-6*lambda^(-0.5),6*lambda^(-0.5),Nt_grid);
Pr_theta = normcdf(theta,0,lambda^(-0.5));
Pr_theta(1,Nt_grid)  = 1;
Pr_theta(1,2:Nt_grid) = Pr_theta(1,2:Nt_grid)-Pr_theta(1,1:Nt_grid-1);

z     = linspace(-4*sigz,4*sigz,Nz_grid);
Pr_z  = normcdf(z,-ubar/(b^0.5),sigz);
Pr_z_RN  = normcdf(z,0,sigz);
Pr_z(1,Nz_grid)  = 1;
Pr_z(1,2:Nz_grid) = Pr_z(1,2:Nz_grid)-Pr_z(1,1:Nz_grid-1);
Pr_z_RN(1,Nz_grid)  = 1;
Pr_z_RN(1,2:Nz_grid) = Pr_z_RN(1,2:Nz_grid)-Pr_z_RN(1,1:Nz_grid-1);

Pr_theta_z_z = zeros(Nz_grid,Nt_grid);
Pr_theta_z   = zeros(Nz_grid,Nt_grid);
for i=1:Nz_grid
Pr_theta_z_z(i,:)= normcdf(theta,gp*(z(i)+(tau/(b+tau))*ubar/(b^-0.5)),lambda^(-0.5)*(1-gp)^0.5);
Pr_theta_z(i,:)= normcdf(theta,gv*(z(i)+ubar/(b^-0.5)),lambda^(-0.5)*(1-gv)^0.5);
end
Pr_theta_z_z(:,Nt_grid) = 1;
Pr_theta_z_z(:,2:Nt_grid)=Pr_theta_z_z(:,2:Nt_grid)-Pr_theta_z_z(:,1:Nt_grid-1);
Pr_theta_z(:,Nt_grid) = 1;
Pr_theta_z(:,2:Nt_grid)=Pr_theta_z(:,2:Nt_grid)-Pr_theta_z(:,1:Nt_grid-1);

P_z_up = R_theta_up*transpose(Pr_theta_z_z);
V_z_up = R_theta_up*transpose(Pr_theta_z);
E_P_up = P_z_up*transpose(Pr_z);
E_V_up = V_z_up*transpose(Pr_z);

I_star_up = (E_V_up)^(1/chi);
I_hat_up = (E_V_up + alpha*(E_P_up-E_V_up))^(1/chi);
Delta_up = E_P_up/E_V_up - 1;

Pi_z_z_hat_up  = P_z_up*I_hat_up - I_hat_up^(1+chi)/(1+chi);
Pi_z_hat_up    = V_z_up*I_hat_up - I_hat_up^(1+chi)/(1+chi);
Pi_z_z_star_up = P_z_up*I_star_up - I_star_up^(1+chi)/(1+chi);
Pi_z_star_up   = V_z_up*I_star_up - I_star_up^(1+chi)/(1+chi);

E_Pi_z_z_hat_up  = Pi_z_z_hat_up*transpose(Pr_z);
E_Pi_z_hat_up    = Pi_z_hat_up*transpose(Pr_z);
E_Pi_z_z_star_up = Pi_z_z_star_up*transpose(Pr_z);
E_Pi_z_star_up   = Pi_z_star_up*transpose(Pr_z);

end

for u=D_dn

  U = sig_u(u);
    tau    = b/U^2;
    
gp     =(b+tau)/(lambda+b+tau);
gv     =tau/(lambda+tau);
sigz   =lambda^(-0.5)*gv^(-0.5); 
Nt_grid  = 1000;
Nz_grid  = 1000;
theta = linspace(-6*lambda^(-0.5),6*lambda^(-0.5),Nt_grid);
Pr_theta = normcdf(theta,0,lambda^(-0.5));
Pr_theta(1,Nt_grid)  = 1;
Pr_theta(1,2:Nt_grid) = Pr_theta(1,2:Nt_grid)-Pr_theta(1,1:Nt_grid-1);

z     = linspace(-4*sigz,4*sigz,Nz_grid);
Pr_z  = normcdf(z,-ubar/(b^0.5),sigz);
Pr_z_RN  = normcdf(z,0,sigz);
Pr_z(1,Nz_grid)  = 1;
Pr_z(1,2:Nz_grid) = Pr_z(1,2:Nz_grid)-Pr_z(1,1:Nz_grid-1);
Pr_z_RN(1,Nz_grid)  = 1;
Pr_z_RN(1,2:Nz_grid) = Pr_z_RN(1,2:Nz_grid)-Pr_z_RN(1,1:Nz_grid-1);

Pr_theta_z_z = zeros(Nz_grid,Nt_grid);
Pr_theta_z   = zeros(Nz_grid,Nt_grid);
for i=1:Nz_grid
Pr_theta_z_z(i,:)= normcdf(theta,gp*(z(i)+(tau/(b+tau))*ubar/(b^-0.5)),lambda^(-0.5)*(1-gp)^0.5);
Pr_theta_z(i,:)= normcdf(theta,gv*(z(i)+ubar/(b^-0.5)),lambda^(-0.5)*(1-gv)^0.5);
end
Pr_theta_z_z(:,Nt_grid) = 1;
Pr_theta_z_z(:,2:Nt_grid)=Pr_theta_z_z(:,2:Nt_grid)-Pr_theta_z_z(:,1:Nt_grid-1);
Pr_theta_z(:,Nt_grid) = 1;
Pr_theta_z(:,2:Nt_grid)=Pr_theta_z(:,2:Nt_grid)-Pr_theta_z(:,1:Nt_grid-1);

P_z_dn = R_theta_dn*transpose(Pr_theta_z_z);
V_z_dn = R_theta_dn*transpose(Pr_theta_z);
E_P_dn = P_z_dn*transpose(Pr_z);
E_V_dn = V_z_dn*transpose(Pr_z);

I_star_dn = (E_V_dn)^(1/chi);
I_hat_dn = (E_V_dn + alpha*(E_P_dn-E_V_dn))^(1/chi);
Delta_dn = E_P_dn/E_V_dn - 1;

Pi_z_z_hat_dn  = P_z_dn*I_hat_dn - I_hat_dn^(1+chi)/(1+chi);
Pi_z_hat_dn    = V_z_dn*I_hat_dn - I_hat_dn^(1+chi)/(1+chi);
Pi_z_z_star_dn = P_z_dn*I_star_dn - I_star_dn^(1+chi)/(1+chi);
Pi_z_star_dn   = V_z_dn*I_star_dn - I_star_dn^(1+chi)/(1+chi);

E_Pi_z_z_hat_dn  = Pi_z_z_hat_dn*transpose(Pr_z);
E_Pi_z_hat_dn    = Pi_z_hat_dn*transpose(Pr_z);
E_Pi_z_z_star_dn = Pi_z_z_star_dn*transpose(Pr_z);
E_Pi_z_star_dn   = Pi_z_star_dn*transpose(Pr_z);

end




figure(1)
subplot(1,2,1)
plot(z,Pi_z_z_hat_up,'k -','LineWidth',1)
hold all
plot(z,Pi_z_hat_up,'k --','LineWidth',1)
plot(z,E_Pi_z_z_hat_up*ones(1,Nz_grid),'k -','LineWidth',2)
plot(z,E_Pi_z_hat_up*ones(1,Nz_grid),'k --','LineWidth',2)
plot(z,E_Pi_z_star_up*ones(1,Nz_grid),'k :','LineWidth',2)
hold off
xlabel('--->  z ')
xlim([-2 2])
ylim([-20 E_Pi_z_z_hat_up*1.4 ])
h=legend('$$P(z;\hat{K})$$','$$V(z;\hat{K})$$','$$E[P(z;\hat{K})]$$','$$E[V(z;\hat{K})]$$','$$E[V(z,K^{*})]$$','Fontsize',12,'EdgeColor','none');
set(h,'Interpreter','latex')
title('a) Upside Risks','Fontsize',16)


subplot(1,2,2)
plot(z,Pi_z_z_hat_dn,'k -','LineWidth',1)
hold all
plot(z,Pi_z_hat_dn,'k --','LineWidth',1)
plot(z,E_Pi_z_z_hat_dn*ones(1,Nz_grid),'k -','LineWidth',2)
plot(z,E_Pi_z_hat_dn*ones(1,Nz_grid),'k --','LineWidth',2)
plot(z,E_Pi_z_star_dn*ones(1,Nz_grid),'k :','LineWidth',2)
hold off
xlabel('--->  z ')
xlim([-2 2])
ylim([-1 E_Pi_z_star_dn*1.4 ])
h=legend('$$P(z;\hat{K})$$','$$V(z;\hat{K})$$','$$E[P(z;\hat{K})]$$','$$E[V(z;\hat{K})]$$','$$E[V(z,K^{*})]$$','Fontsize',12,'EdgeColor','none');
set(h,'Interpreter','latex')
title('b) Downside Risks','Fontsize',16)
