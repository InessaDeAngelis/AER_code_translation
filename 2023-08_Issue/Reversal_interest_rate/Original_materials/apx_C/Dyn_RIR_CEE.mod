// Modified CEE model without capital utilization or wage stickiness (used
// as a point of comparison for the benchmark model in Appendix C). As in
// CEE, there are no bank frictions.

var llambda R w EA_k L Y C Invest Rn Pi P_I Y_bd K_bd L_bd Invest_bd Invest_bdx rk_bd Q_bd Y_nbd K_nbd L_nbd Invest_nbd Invest_nbdx rk_nbd Q_nbd nu_A nu_mp ;
varexo eps_A eps_mp;

parameters Norm bbeta h ggamma cchi psi_L nnu aalpha alpha_l alpha_k ddelta rho_Rn phi_pi phi_y eps_PC theta_PC kappa_I rho_A rho_mp xxi A_nbd A_bd;

// CALIBRATION

// Normalization
Norm = 1.0;

// Preferences
bbeta = 1.03^(-1/4);
ggamma = 1.0;
psi_L = 1.0;
h = 0.62;

// Technology
aalpha = 0.36;
ddelta = 0.025;
nnu = 0.99;
alpha_l = (1-aalpha)*nnu;
alpha_k = aalpha*nnu;
xxi = 0.998;              
Y_bd_sh = 0.998;          
A_nbd = 1.0;            
kappa_I = 2.48;

// Taylor rule
rho_Rn = 0.8;
phi_pi = 1.5;
phi_y = 0.5;

// Price stickiness and markups
eps_PC = 6.0;
theta_calvo = 0.6;
theta_PC = theta_calvo*(eps_PC-1)/((1-theta_calvo)*(1-bbeta*theta_calvo));

// Persistence of shocks
rho_A = 0.9;
rho_mp = 0;

// STEADY STATE CALIBRATION
// Normalization
Y_SS = Norm;

// Calibrating interest rate and Fisher equation
R_SS = 1/bbeta;
Rn_SS = R_SS;

// Calibrating non-bank-dependent firms
rk_nbd_SS = 1/bbeta -1 + ddelta;
Y_nbd_SS = (1-Y_bd_sh)/(1-xxi) * Y_SS;
K_nbd_SS = alpha_k*Y_nbd_SS/rk_nbd_SS;
L_nbd_SS = (Y_nbd_SS/A_nbd/K_nbd_SS^alpha_k)^(1/(alpha_l));
Invest_nbdx_SS = (1-xxi)*ddelta*K_nbd_SS;
w_SS = alpha_l * A_nbd * K_nbd_SS^alpha_k * L_nbd_SS^(alpha_l-1);

// Calibrating bank-dependent firms
rk_bd_SS  = 1/bbeta - 1 + ddelta;
Y_bd_SS  = Y_bd_sh/xxi * Y_SS;
K_bd_SS  = alpha_k*Y_bd_SS/rk_bd_SS;
L_bd_SS = alpha_l*Y_bd_SS/w_SS;
Invest_bdx_SS = xxi*ddelta*K_bd_SS;
A_bd = Y_bd_SS/(K_bd_SS^alpha_k * L_bd_SS^alpha_l);

// Aggregates
Invest_SS = Invest_nbdx_SS+Invest_bdx_SS;
C_SS = Y_SS - Invest_SS;
llambda_SS = (C_SS-h*C_SS)^(-ggamma) - bbeta*h*(C_SS-h*C_SS)^(-ggamma);
L_SS = (1-xxi)*L_nbd_SS + xxi*L_bd_SS;
cchi = llambda_SS*w_SS / (L_SS^psi_L);

model;

// STANDARD EQUATIONS
llambda = (C-h*C(-1))^(-ggamma) - bbeta*h*(C(+1)-h*C)^(-ggamma);
llambda/steady_state(llambda) = R/steady_state(R)* llambda(+1)/steady_state(llambda);
R = Rn/Pi(+1);
EA_k = (1-alpha_l)*(P_I(+1)*exp(nu_A(+1)))^(1/(1-alpha_l)) * (alpha_l/w(+1))^(alpha_l/(1-alpha_l));

// NKPC AND TAYLOR RULE
log(Pi/steady_state(Pi)) = (eps_PC-1)/theta_PC * log(P_I/steady_state(P_I))+ bbeta*log(Pi(+1)/steady_state(Pi)); //Note: log linear version
Rn/steady_state(Rn) = (Rn(-1)/steady_state(Rn))^rho_Rn * ( Pi/steady_state(Pi)^phi_pi * (Y/steady_state(Y))^phi_y )^(1-rho_mp) * exp(-nu_mp);

//NON-BANK-DEPENDENT FIRMS
Q_nbd = ((llambda-bbeta*llambda(+1)*Q_nbd(+1)*kappa_I*(Invest_nbdx(+1)/Invest_nbdx-1)*(Invest_nbdx(+1)/Invest_nbdx)^2)/(llambda*(1-kappa_I/2*(Invest_nbdx/Invest_nbdx(-1)-1)^2-kappa_I*(Invest_nbdx/Invest_nbdx(-1)-1)*(Invest_nbdx/Invest_nbdx(-1)))));
rk_nbd = Q_nbd*R - Q_nbd(+1)*(1-ddelta);

K_nbd = (alpha_k/(1-alpha_l)*A_nbd^(1/(1-alpha_l))*EA_k/(rk_nbd))^((1-alpha_l)/(1-alpha_l-alpha_k));
L_nbd = ( alpha_l * P_I*A_nbd*exp(nu_A)*K_nbd(-1)^alpha_k/w)^(1/(1-alpha_l));
Y_nbd = A_nbd*exp(nu_A)*K_nbd(-1)^(alpha_k)*L_nbd^(alpha_l);
Invest_nbd*(1-kappa_I/2*(Invest_nbd/Invest_nbd(-1)-1)^2) = K_nbd - (1-ddelta)*K_nbd(-1) ;
Invest_nbdx = (1-xxi) * Invest_nbd;

//BANK-DEPENDENT FIRMS
Q_bd = ((llambda-bbeta*llambda(+1)*Q_bd(+1)*kappa_I*(Invest_bdx(+1)/Invest_bdx-1)*(Invest_bdx(+1)/Invest_bdx)^2)/(llambda*(1-kappa_I/2*(Invest_bdx/Invest_bdx(-1)-1)^2-kappa_I*(Invest_bdx/Invest_bdx(-1)-1)*(Invest_bdx/Invest_bdx(-1)))));
rk_bd = Q_bd*R - Q_bd(+1)*(1-ddelta);

K_bd = (alpha_k/(1-alpha_l)*A_bd^(1/(1-alpha_l))*EA_k/(rk_bd))^((1-alpha_l)/(1-alpha_l-alpha_k));
L_bd = ( alpha_l * P_I*A_bd*exp(nu_A)*K_bd(-1)^alpha_k/w)^(1/(1-alpha_l));
Y_bd = A_bd*exp(nu_A)*K_bd(-1)^(alpha_k)*L_bd^(alpha_l);
Invest_bd*(1-kappa_I/2*(Invest_bd/Invest_bd(-1)-1)^2) = K_bd - (1-ddelta)*K_bd(-1) ;
Invest_bdx = xxi * Invest_bd;

// AGGREGATION
L = (1-xxi)*L_nbd+xxi*L_bd;
Y = (1-xxi)*Y_nbd+xxi*Y_bd;
Invest = (1-xxi)*Invest_nbd+xxi*Invest_bd;
w = L^psi_L * cchi / llambda;
C = Y-Invest;

// EXOGENOUS PROCESSES
nu_A = nu_A(-1)*rho_A + eps_A;
nu_mp = nu_mp(-1)*rho_mp + eps_mp;

end;


initval;
// Normalization
Y = Norm;

// Interest rates and inflation
Pi = 1;
R = 1/bbeta;
Rn = R;

// Non-bank-dependent
rk_nbd = 1/bbeta -1 + ddelta;
Q_nbd  = 1;

Y_nbd = (1-Y_bd_sh)/(1-xxi) * Y;
K_nbd = alpha_k*Y_nbd/rk_nbd;
L_nbd = (Y_nbd/A_nbd/K_nbd^alpha_k)^(1/(alpha_l));
Invest_nbd = ddelta*K_nbd;
Invest_nbdx = (1-xxi) * Invest_nbd;

// Bank-dependent
rk_bd  = 1/bbeta - 1 + ddelta;
Q_bd   = 1;

Y_bd  = Y_bd_sh/xxi * Y;
K_bd  = alpha_k*Y_bd/rk_bd;
L_bd = (Y_bd/A_bd/K_bd^alpha_k)^(1/alpha_l);
Invest_bd  = ddelta*K_bd;
Invest_bdx = xxi * Invest_bd;

// Aggregates
Invest = (1-xxi)*Invest_nbd+xxi*Invest_bd;
C = Y - Invest;
w = alpha_l * A_nbd * K_nbd^alpha_k * L_nbd^(alpha_l-1);
L = xxi*L_bd + (1-xxi)*L_nbd;

// Other standard stuff
P_I = 1;
EA_k = (1-alpha_l)* P_I^(1/(1-alpha_l)) * (alpha_l/w)^(alpha_l/(1-alpha_l));
llambda = (C-h*C)^(-ggamma) - bbeta*h*(C-h*C)^(-ggamma);

// Exogenous processes
nu_A = 0;
nu_mp = 0;

end;

resid;

steady;


// SHOCKS: IRF Comparison
shocks;
var eps_mp;
periods 1;
values 0.001;
end;

perfect_foresight_setup(periods=200);
perfect_foresight_solver;


Rn_CEE = Rn;
Pi_CEE = Pi;
Y_CEE = Y;
C_CEE = C;
Invest_CEE = Invest;
L_CEE = L;

save('irfs_CEE.mat', 'Rn_CEE', 'Pi_CEE', 'Y_CEE', 'C_CEE', 'Invest_CEE', 'L_CEE')

