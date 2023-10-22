% Code plots investment and dividends relative to first-best, both PE and GE 
%(Figures 3 and 5 of the paper). 

clear
clc
close all
%common parameters

b      = 1.0; %baseline: 1
lambda = 1;  %baseline: 1

ubar  = 0.0; %baseline: 0
a_up  = 0.7; %baseline: 0
b_up  = 0.5; %baseline: 0.7
a_dn  = 2.5; %baseline: 3.5
b_dn  = 0.5; %baseline: 0.7


Chi = [0.05 0.15];
n_chi = size(Chi,2);
n_alpha = 31;
Alpha = linspace(0,1,n_alpha);
n_u = 41;
sig_u = linspace(0.5,2,n_u);

Nt_grid  = 500;
Nz_grid  = 500;
theta = linspace(-4*lambda^(-0.5),4*lambda^(-0.5),Nt_grid);

%Matrices for investment, delta and losses, PE
LossRatio_up_vec = zeros(n_chi,n_u,n_alpha);
LossRatio_dn_vec = zeros(n_chi,n_u,n_alpha);
LossRatio_up_vec_cf = zeros(n_chi,n_u,n_alpha); %cf: closed-form solution
LossRatio_dn_vec_cf = zeros(n_chi,n_u,n_alpha); 
Delta_up_vec = zeros(1,n_u);
Delta_dn_vec = zeros(1,n_u);
K_up_vec = zeros(n_chi,n_u,n_alpha);
K_star_up_vec = zeros(n_chi,n_u,n_alpha); %K_star should only depend on chi; since frictions don´t affect it. However, rounding error in computation of V (for different info frictions) give small changes in V for different values of sig_u/Delta
K_dn_vec = zeros(n_chi,n_u,n_alpha);
K_star_dn_vec = zeros(2,n_u);
KRatio_up_vec = zeros(n_chi,n_u,n_alpha);
KRatio_dn_vec = zeros(n_chi,n_u,n_alpha);
KRatio_up_vec_cf = zeros(n_chi,n_u,n_alpha);
KRatio_dn_vec_cf = zeros(n_chi,n_u,n_alpha);

%Matrices for investment, delta and losses, GE
LossRatio_up_vec_GE = zeros(n_chi,n_u,n_alpha);
LossRatio_dn_vec_GE = zeros(n_chi,n_u,n_alpha);
LossRatio_up_vec_GE_cf = zeros(n_chi,n_u,n_alpha);
LossRatio_dn_vec_GE_cf = zeros(n_chi,n_u,n_alpha);
K_up_vec_GE = zeros(n_chi,n_u,n_alpha);
K_dn_vec_GE = zeros(n_chi,n_u,n_alpha);
KRatio_up_vec_GE = zeros(n_chi,n_u,n_alpha);
KRatio_dn_vec_GE = zeros(n_chi,n_u,n_alpha);
KRatio_up_vec_GE_cf = zeros(n_chi,n_u,n_alpha);
KRatio_dn_vec_GE_cf = zeros(n_chi,n_u,n_alpha);
QRatio_up_GE = zeros(n_chi,n_u,n_alpha); %Corresponds to Q/Qhat
QRatio_dn_GE = zeros(n_chi,n_u,n_alpha);

%Note: no K* or Delta for GE, as they are the same as in PE

for a=1:n_alpha
alpha = Alpha(a);
for x=1:n_chi
    chi = Chi(x);

for u=1:n_u
    U = sig_u(u);
    tau    = b/U^2;
    
gp     =(b+tau)/(lambda+b+tau);
gv     =tau/(lambda+tau);
sigz   =lambda^(-0.5)*gv^(-0.5); %same as simply (lambda^-1+tau^-1)^0.5
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

%%%Dividend function
R_theta_up = a_up+exp(b_up*theta);
R_theta_dn = a_dn -exp(-b_dn*theta);

%Expected and market-implied R(theta)
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

P_z_dn = R_theta_dn*transpose(Pr_theta_z_z);
V_z_dn = R_theta_dn*transpose(Pr_theta_z);
E_P_dn = P_z_dn*transpose(Pr_z);
E_V_dn = V_z_dn*transpose(Pr_z);

%Partial equilibrium investment and losses
%upside
I_star_up = (E_V_up)^(1/chi);
I_hat_up = (E_V_up + alpha*(E_P_up-E_V_up))^(1/chi);
Delta_up = E_P_up/E_V_up - 1;
K_up_vec(x,u,a) = I_hat_up;
K_star_up_vec(x,u,a) = I_star_up;
Delta_up_vec(u) = Delta_up;
KRatio_up_vec(x,u,a) = I_hat_up/I_star_up;
KRatio_up_vec_cf(x,u,a) = (1+alpha*Delta_up)^(1/chi);

Pi_z_z_hat_up  = P_z_up*I_hat_up - I_hat_up^(1+chi)/(1+chi);
Pi_z_hat_up    = V_z_up*I_hat_up - I_hat_up^(1+chi)/(1+chi);
Pi_z_z_star_up = P_z_up*I_star_up - I_star_up^(1+chi)/(1+chi);
Pi_z_star_up   = V_z_up*I_star_up - I_star_up^(1+chi)/(1+chi);

E_Pi_z_z_hat_up  = Pi_z_z_hat_up*transpose(Pr_z);
E_Pi_z_hat_up    = Pi_z_hat_up*transpose(Pr_z);
E_Pi_z_z_star_up = Pi_z_z_star_up*transpose(Pr_z);
E_Pi_z_star_up   = Pi_z_star_up*transpose(Pr_z);

LossRatio_up_vec(x,u,a) = E_Pi_z_hat_up/E_Pi_z_star_up;
LossRatio_up_vec_cf(x,u,a) = (1+alpha*Delta_up)^(1/chi)*(1-alpha*Delta_up*chi^(-1));

%Downside
I_star_dn = (E_V_dn)^(1/chi);
I_hat_dn = (E_V_dn + alpha*(E_P_dn-E_V_dn))^(1/chi);
Delta_dn = E_P_dn/E_V_dn - 1;
K_dn_vec(x,u,a) = I_hat_dn;
K_star_dn_vec(x,u,a) = I_star_dn;
Delta_dn_vec(u) = Delta_dn;
KRatio_dn_vec(x,u,a) = I_hat_dn/I_star_dn;
KRatio_dn_vec_cf(x,u,a) = (1+alpha*Delta_dn)^(1/chi);

Pi_z_z_hat_dn  = P_z_dn*I_hat_dn - I_hat_dn^(1+chi)/(1+chi);
Pi_z_hat_dn    = V_z_dn*I_hat_dn - I_hat_dn^(1+chi)/(1+chi);
Pi_z_z_star_dn = P_z_dn*I_star_dn - I_star_dn^(1+chi)/(1+chi);
Pi_z_star_dn   = V_z_dn*I_star_dn - I_star_dn^(1+chi)/(1+chi);

E_Pi_z_z_hat_dn  = Pi_z_z_hat_dn*transpose(Pr_z);
E_Pi_z_hat_dn    = Pi_z_hat_dn*transpose(Pr_z);
E_Pi_z_z_star_dn = Pi_z_z_star_dn*transpose(Pr_z);
E_Pi_z_star_dn   = Pi_z_star_dn*transpose(Pr_z);

LossRatio_dn_vec(x,u,a) = E_Pi_z_hat_dn/E_Pi_z_star_dn;
LossRatio_dn_vec_cf(x,u,a) = (1+alpha*Delta_dn)^(1/chi)*(1-alpha*Delta_dn*chi^(-1));

%General equilibrium
%Upside
Root_1_up = ((E_P_up*(1+(1-alpha)*chi) + E_V_up*(1+alpha*chi) -((E_P_up*(1+(1-alpha)*chi)+E_V_up*(1+alpha*chi))^2-4*(1+chi)*E_P_up*E_V_up )^(0.5))/2)^(1/chi);
Root_2_up = ((E_P_up*(1+(1-alpha)*chi) + E_V_up*(1+alpha*chi) +(  (E_P_up*(1+(1-alpha)*chi)+E_V_up*(1+alpha*chi))^2  -  4*(1+chi)*E_P_up*E_V_up )^(0.5))/2)^(1/chi);
if 0<alpha && alpha<1
    I_hat_up_GE = min(Root_1_up,Root_2_up);
elseif alpha==1
    I_hat_up_GE = E_P_up^(1/chi);
else
    I_hat_up_GE = E_V_up^(1/chi);
end

K_up_vec_GE(x,u,a) = I_hat_up_GE;
KRatio_up_vec_GE(x,u,a) = I_hat_up_GE/I_star_up;

Pi_z_z_hat_up_GE  = P_z_up*I_hat_up_GE - I_hat_up_GE^(1+chi)/(1+chi);
Pi_z_hat_up_GE    = V_z_up*I_hat_up_GE - I_hat_up_GE^(1+chi)/(1+chi);
E_Pi_z_z_hat_up_GE  = Pi_z_z_hat_up_GE*transpose(Pr_z);
E_Pi_z_hat_up_GE    = Pi_z_hat_up_GE*transpose(Pr_z);

QRatio_up_GE(x,u,a) = E_Pi_z_hat_up_GE/E_Pi_z_z_hat_up_GE;
KRatio_up_vec_GE_cf(x,u,a) = (1+alpha*Delta_up*(QRatio_up_GE(x,u,a)/(1-alpha+alpha*QRatio_up_GE(x,u,a))))^(1/chi);
LossRatio_up_vec_GE(x,u,a) = E_Pi_z_hat_up_GE/E_Pi_z_star_up;

%Downside

Root_1_dn = ((E_P_dn*(1+(1-alpha)*chi) + E_V_dn*(1+alpha*chi) -((E_P_dn*(1+(1-alpha)*chi)+E_V_dn*(1+alpha*chi))^2-4*(1+chi)*E_P_dn*E_V_dn )^(0.5))/2)^(1/chi);
Root_2_dn = ((E_P_dn*(1+(1-alpha)*chi) + E_V_dn*(1+alpha*chi) +((E_P_dn*(1+(1-alpha)*chi)+E_V_dn*(1+alpha*chi))^2-4*(1+chi)*E_P_dn*E_V_dn )^(0.5))/2)^(1/chi);

if 1>alpha&&alpha>0
    I_hat_dn_GE = min(Root_1_dn,Root_2_dn);
elseif alpha==1
    I_hat_dn_GE = E_P_dn^(1/chi);
    else
I_hat_dn_GE = E_V_dn^(1/chi);
end

K_dn_vec_GE(x,u,a) = I_hat_dn_GE;
KRatio_dn_vec_GE(x,u,a) = I_hat_dn_GE/I_star_dn;

Pi_z_z_hat_dn_GE  = P_z_dn*I_hat_dn_GE - I_hat_dn_GE^(1+chi)/(1+chi);
Pi_z_hat_dn_GE    = V_z_dn*I_hat_dn_GE - I_hat_dn_GE^(1+chi)/(1+chi);
E_Pi_z_z_hat_dn_GE  = Pi_z_z_hat_dn_GE*transpose(Pr_z);
E_Pi_z_hat_dn_GE    = Pi_z_hat_dn_GE*transpose(Pr_z);

QRatio_dn_GE(x,u,a) = E_Pi_z_hat_dn_GE/E_Pi_z_z_hat_dn_GE;
KRatio_dn_vec_GE_cf(x,u,a) = (1+alpha*Delta_dn*(QRatio_dn_GE(x,u,a)/(1-alpha+alpha*QRatio_dn_GE(x,u,a))))^(1/chi);
LossRatio_dn_vec_GE(x,u,a) = E_Pi_z_hat_dn_GE/E_Pi_z_star_dn;

Iteration = [x u a]

end
end
end

D_up = min(find(Delta_up_vec>0.05));
D_dn = min(find(Delta_dn_vec<-0.05));
A_base = min(find(Alpha>0.499));



save incentives

%Figure 3 of the paper:
%______________________________________________________________________________
%The figure uses alpha=1, since its all scalable by Delta*alpha, and
%Delta starts at 0
figure(3)
subplot(2,2,1)
plot(Delta_up_vec,KRatio_up_vec_cf(1,:,n_alpha),'k -','LineWidth',2)
hold all
plot(Delta_up_vec,KRatio_up_vec_cf(2,:,n_alpha),'k -','LineWidth',1)
hold off
xlabel('---> \alpha\Delta')
xlim([Delta_up_vec(1,1) 0.08])
ylabel('Investment distortion')
h=legend('$$\hat{K}/K^{*} (\chi=0.05)$$','$$\hat{K}/K^{*} (\chi=0.15)$$', 'Fontsize',10,'EdgeColor','none');
set(h,'Interpreter','latex')
title('a) Upside Risks','Fontsize',16)

subplot(2,2,2)
plot(-Delta_dn_vec,KRatio_dn_vec_cf(1,:,n_alpha),'k -','LineWidth',2)
hold all
plot(-Delta_dn_vec,KRatio_dn_vec_cf(2,:,n_alpha),'k -','LineWidth',1)
hold off
xlabel('---> -\alpha\Delta')
ylabel('Investment distortion')
xlim([-Delta_dn_vec(1) 0.08])
h=legend('$$\hat{K}/K^{*} (\chi=0.05)$$','$$\hat{K}/K^{*} (\chi=0.15)$$','Fontsize',10,'EdgeColor','none');
set(h,'Interpreter','latex')
title('b) Downside Risks','Fontsize',16)

subplot(2,2,3)
plot(Delta_up_vec,LossRatio_up_vec(1,:,n_alpha),'k -','LineWidth',2)
hold all
plot(Delta_up_vec,LossRatio_up_vec(2,:,n_alpha),'k -','LineWidth',1)
plot(Delta_up_vec,zeros(1,n_u),'k -','LineWidth',0.5)
hold off
xlabel('---> \alpha\Delta')
ylabel('Expected dividend losses')
h=legend('$$V(\hat{K})/V(K^{*}) (\chi = 0.05)$$', '$$V(\hat{K})/V(K^{*}) (\chi = 0.15)$$','Fontsize',10,'EdgeColor','none');
set(h,'Interpreter','latex')
xlim([Delta_up_vec(1) 0.08])

subplot(2,2,4)
plot(-Delta_dn_vec,LossRatio_dn_vec(1,:,n_alpha),'k -','LineWidth',2)
hold all
plot(-Delta_dn_vec,LossRatio_dn_vec(2,:,n_alpha),'k -','LineWidth',1)
plot(-Delta_up_vec,zeros(1,n_u),'k -','LineWidth',0.5)
hold off
xlabel('---> -\alpha\Delta')
ylabel('Expected dividend losses')
h=legend('$$V(\hat{K})/V(K^{*}) (\chi = 0.05)$$','$$V(\hat{K})/V(K^{*}) (\chi = 0.15)$$','Fontsize',10,'EdgeColor','none');
set(h,'Interpreter','latex')
xlim([-Delta_dn_vec(1) 0.08])
%______________________________________________________________________________





%Figure 5 of the paper: 
%______________________________________________________________________________
%First panel varies Delta, so alpha is fixed at 0.7. 
figure(5)
subplot(2,2,1)
plot(Delta_up_vec,KRatio_up_vec_GE_cf(1,:,A_base),'k --','LineWidth',2)
hold all
plot(Delta_up_vec,KRatio_up_vec_cf(1,:,A_base),'k -','LineWidth',2)
plot(Delta_up_vec,KRatio_up_vec_GE_cf(2,:,A_base),'k --','LineWidth',1)
plot(Delta_up_vec,KRatio_up_vec_cf(2,:,A_base),'k -','LineWidth',1)
hold off
xlabel('---> \Delta')
xlim([Delta_up_vec(1,1) 0.08])
ylabel('Investment distortion')
h=legend('$$\hat{K_{GE}}/K^{*} (\chi=0.05)$$','$$\hat{K}/K^{*} (\chi=0.05)$$','$$\hat{K_{GE}}/K^{*} (\chi=0.15)$$','$$\hat{K}/K^{*} (\chi=0.15)$$','Fontsize',10,'EdgeColor','none');
set(h,'Interpreter','latex')
title('a) Upside Risks','Fontsize',16)

subplot(2,2,2)
plot(-Delta_dn_vec,KRatio_dn_vec_GE_cf(1,:,A_base),'k --','LineWidth',2)
hold all
plot(-Delta_dn_vec,KRatio_dn_vec_cf(1,:,A_base),'k -','LineWidth',2)
plot(-Delta_dn_vec,KRatio_dn_vec_GE_cf(2,:,A_base),'k --','LineWidth',1)
plot(-Delta_dn_vec,KRatio_dn_vec_cf(2,:,A_base),'k -','LineWidth',1)
hold off
xlabel('---> -\Delta')
xlim([-Delta_dn_vec(1,1) 0.08])
ylabel('Investment distortion')
h=legend('$$\hat{K_{GE}}/K^{*} (\chi=0.05)$$','$$\hat{K}/K^{*} (\chi=0.05)$$','$$\hat{K_{GE}}/K^{*} (\chi=0.15)$$','$$\hat{K}/K^{*} (\chi=0.15)$$','Fontsize',10,'EdgeColor','none');
set(h,'Interpreter','latex')
title('b) Downside Risks','Fontsize',16)


subplot(2,2,3)
plot(Delta_up_vec,LossRatio_up_vec_GE(1,:,A_base),'k --','LineWidth',2)
hold all
plot(Delta_up_vec,LossRatio_up_vec_cf(1,:,A_base),'k -','LineWidth',2)
plot(Delta_up_vec,LossRatio_up_vec_GE(2,:,A_base),'k --','LineWidth',1)
plot(Delta_up_vec,LossRatio_up_vec_cf(2,:,A_base),'k -','LineWidth',1)
plot(Delta_up_vec,zeros(1,n_u),'k -','LineWidth',0.5)
hold off
xlabel('---> \Delta')
xlim([Delta_up_vec(1,1) 0.08])
ylim([0.5 1])
ylabel('Expected dividend losses')
h=legend('$$V(\hat{K_{GE}})/V(K^{*}) (\chi=0.05)$$','$$V(\hat{K})/V(K^{*}) (\chi=0.05)$$','$$V(\hat{K_{GE}})/V(K^{*}) (\chi=0.15)$$','$$V(\hat{K})/V(K^{*}) (\chi=0.15)$$','Fontsize',10,'EdgeColor','none');
set(h,'Interpreter','latex')

subplot(2,2,4)
plot(-Delta_dn_vec,LossRatio_dn_vec_GE(1,:,A_base),'k --','LineWidth',2)
hold all
plot(-Delta_dn_vec,LossRatio_dn_vec_cf(1,:,A_base),'k -','LineWidth',2)
plot(-Delta_dn_vec,LossRatio_dn_vec_GE(2,:,A_base),'k --','LineWidth',1)
plot(-Delta_dn_vec,LossRatio_dn_vec_cf(2,:,A_base),'k -','LineWidth',1)
plot(-Delta_up_vec,zeros(1,n_u),'k -','LineWidth',0.5)
hold off
xlabel('---> -\Delta')
xlim([-Delta_dn_vec(1,1) 0.08])
ylim([0.5 1])
ylabel('Expected dividend losses')
h=legend('$$V(\hat{K_{GE}})/V(K^{*}) (\chi=0.05)$$','$$V(\hat{K})/V(K^{*}) (\chi=0.05)$$','$$V(\hat{K_{GE}})/V(K^{*}) (\chi=0.15)$$','$$V(\hat{K})/V(K^{*}) (\chi=0.15)$$', 'Fontsize',10,'EdgeColor','none');
set(h,'Interpreter','latex')

%Second panel varies alpha, so delta is fixed at roughly 0.5 (that´s what
%D_up; D_dn stand for...)
KRatio_up_vec_GE_cf_plot = zeros(n_chi,n_alpha);
KRatio_up_vec_cf_plot = zeros(n_chi,n_alpha);
KRatio_dn_vec_GE_cf_plot = zeros(n_chi,n_alpha);
KRatio_dn_vec_cf_plot = zeros(n_chi,n_alpha);
LossRatio_up_vec_GE_plot = zeros(n_chi,n_alpha);
LossRatio_up_vec_cf_plot = zeros(n_chi,n_alpha);
LossRatio_dn_vec_GE_plot = zeros(n_chi,n_alpha);
LossRatio_dn_vec_cf_plot = zeros(n_chi,n_alpha);

for a=1:n_alpha
    for x=1:n_chi
    KRatio_up_vec_GE_cf_plot(x,a) = KRatio_up_vec_GE_cf(x,D_up,a);
    KRatio_up_vec_cf_plot(x,a)    = KRatio_up_vec_cf(x,D_up,a);
    KRatio_dn_vec_GE_cf_plot(x,a) = KRatio_dn_vec_GE_cf(x,D_dn,a);
    KRatio_dn_vec_cf_plot(x,a)    = KRatio_dn_vec_cf(x,D_dn,a);
    LossRatio_up_vec_GE_plot(x,a) = LossRatio_up_vec_GE(x,D_up,a);
    LossRatio_up_vec_cf_plot(x,a) = LossRatio_up_vec_cf(x,D_up,a);
    LossRatio_dn_vec_GE_plot(x,a) = LossRatio_dn_vec_GE(x,D_dn,a);
    LossRatio_dn_vec_cf_plot(x,a) = LossRatio_dn_vec_cf(x,D_dn,a);
    end
end
    
figure(6)
subplot(2,2,1)
plot(Alpha,KRatio_up_vec_GE_cf_plot(1,:),'k --','LineWidth',2)
hold all
plot(Alpha,KRatio_up_vec_cf_plot(1,:),'k -','LineWidth',2)
plot(Alpha,KRatio_up_vec_GE_cf_plot(2,:),'k --','LineWidth',1)
plot(Alpha,KRatio_up_vec_cf_plot(2,:),'k -','LineWidth',1)
hold off
xlabel('---> \alpha')
xlim([0 1])
ylabel('Investment distortion')
h=legend('$$\hat{K_{GE}}/K^{*} (\chi=0.05)$$','$$\hat{K}/K^{*} (\chi=0.05)$$','$$\hat{K_{GE}}/K^{*} (\chi=0.15)$$','$$\hat{K}/K^{*} (\chi=0.15)$$','Fontsize',10,'EdgeColor','none');
set(h,'Interpreter','latex')
title('a) Upside Risks','Fontsize',16)

subplot(2,2,2)
plot(Alpha,KRatio_dn_vec_GE_cf_plot(1,:),'k --','LineWidth',2)
hold all
plot(Alpha,KRatio_dn_vec_cf_plot(1,:),'k -','LineWidth',2)
plot(Alpha,KRatio_dn_vec_GE_cf_plot(2,:),'k --','LineWidth',1)
plot(Alpha,KRatio_dn_vec_cf_plot(2,:),'k -','LineWidth',1)
hold off
xlabel('---> \alpha')
xlim([0 1])
ylabel('Investment distortion')
h=legend('$$\hat{K_{GE}}/K^{*} (\chi=0.05)$$','$$\hat{K}/K^{*} (\chi=0.05)$$','$$\hat{K_{GE}}/K^{*} (\chi=0.15)$$','$$\hat{K}/K^{*} (\chi=0.15)$$','Fontsize',10,'EdgeColor','none');
set(h,'Interpreter','latex')
title('b) Downside Risks','Fontsize',16)


subplot(2,2,3)
plot(Alpha,LossRatio_up_vec_GE_plot(1,:),'k --','LineWidth',2)
hold all
plot(Alpha,LossRatio_up_vec_cf_plot(1,:),'k -','LineWidth',2)
plot(Alpha,LossRatio_up_vec_GE_plot(2,:),'k --','LineWidth',1)
plot(Alpha,LossRatio_up_vec_cf_plot(2,:),'k -','LineWidth',1)
plot(Alpha,zeros(1,n_alpha),'k -','LineWidth',1)
hold off
xlabel('---> \alpha')
xlim([0 1])
ylabel('Expected divididend losses')
h=legend('$$V(\hat{K_{GE}})/V(K^{*}) (\chi=0.05)$$','$$V(\hat{K})/V(K^{*}) (\chi=0.05)$$','$$V(\hat{K_{GE}})/V(K^{*}) (\chi=0.15)$$','$$V(\hat{K})/V(K^{*}) (\chi=0.15)$$','Fontsize',10,'EdgeColor','none');
set(h,'Interpreter','latex')

subplot(2,2,4)
plot(Alpha,LossRatio_dn_vec_GE_plot(1,:),'k --','LineWidth',2)
hold all
plot(Alpha,LossRatio_dn_vec_cf_plot(1,:),'k -','LineWidth',2)
plot(Alpha,LossRatio_dn_vec_GE_plot(2,:),'k --','LineWidth',1)
plot(Alpha,LossRatio_dn_vec_cf_plot(2,:),'k -','LineWidth',1)
plot(Alpha,zeros(1,n_alpha),'k -','LineWidth',1)
hold off
xlabel('---> \alpha')
xlim([0 1])
ylim([0.6 1])
ylabel('Expected dividend losses')
h=legend('$$V(\hat{K_{GE}})/V(K^{*}) (\chi=0.05)$$','$$V(\hat{K})/V(K^{*}) (\chi=0.05)$$','$$V(\hat{K_{GE}})/V(K^{*}) (\chi=0.15)$$','$$V(\hat{K})/V(K^{*}) (\chi=0.15)$$', 'Fontsize',10,'EdgeColor','none');
set(h,'Interpreter','latex')
%______________________________________________________________________________
