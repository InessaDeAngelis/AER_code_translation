// Modified version of benchmark model without bank frictions. The only
// bank parameter remaining is elasticity of loan demand. Used as point of
// comparison for benchmark model in Appendix C.

var llambda R rk_nbd rk_bd w EA_k L L_nbd L_bd K_nbd K_bd Y Y_bd Y_nbd C Invest Invest_nbdx Invest_bdx  Invest_nbd Invest_bd Q_nbd Q_bd nu_A nu_mp nu_fg Rn Pi P_I RLn RL bbeta_endog nu_bbeta Rn_target Trule Lo;
varexo eps_A eps_mp eps_fg eps_bbeta eps_target eps_Trule;

parameters bbeta h Norm   nnu aalpha alpha_l alpha_k ddelta A_nbd ggamma kappa_I_nbd rho_A sigma_A cchi psi_L rho_Rn phi_pi phi_y rho_mp sigma_mp rho_fg sigma_fg eps_PC theta_PC Pi_SS xxi A_bd kappa_I_bd Y_bd_sh Invest_bdx_SS Invest_nbdx_SS Invest_SS rho_bbeta sigma_bbeta eps_L;

// STANDARD NK
// Preferemces
ggamma = 1.0;           
h = 0.62;               
psi_L = 2;              
bbeta = (1-0.02)^(1/4);          


// Technology
Norm = 1.0;             
nnu = 0.85;            
aalpha = 0.36;         
alpha_k = nnu * aalpha;
alpha_l = nnu * (1-aalpha);
ddelta = 0.025;         
xxi = 0.998;              
Y_bd_sh = 0.558;         
A_nbd = 1.0;            
elast_invest = 0.2;
kappa_I_nbd = 1/elast_invest;         
kappa_I_bd = 1/elast_invest;      

// Price stickiness and monetary policy
eps_PC = 1.35/(1.35-1); 
theta_calvo = 0.82;     
Pi_SS = 1.00;        
                            
rho_Rn = 0.93;          
phi_pi = 2.74;          
phi_y = 0.0;            
theta_PC = theta_calvo*(eps_PC-1)/((1-theta_calvo)*(1-bbeta*theta_calvo)); 

// Bank equations
eps_L = 200;

// SHOCKS                        
sigma_A = 0.01;
rho_A = 0.9^4;
sigma_mp = 0.0025;
rho_mp = 0.0;
sigma_fg = 0.01;
rho_fg = 0.0;
rho_bbeta = 0.5;
sigma_bbeta = 0.01;

// STEADY STATE CALIBRATION: cchi, A_bd, D_bar, D_max, kappa_L, delta_E
// Normalization
Y_SS = Norm;

// Calibrating interest rate and Fisher equation
R_SS = 1/bbeta;
Pi_SS_SS = Pi_SS;
Rn_SS = R_SS*Pi_SS_SS;

// Calibrating non-bank-dependent firms
rk_nbd_SS = 1/bbeta -1 + ddelta;
Y_nbd_SS = (1-Y_bd_sh)/(1-xxi) * Y_SS;
K_nbd_SS = alpha_k*Y_nbd_SS/rk_nbd_SS;
L_nbd_SS = (Y_nbd_SS/A_nbd/K_nbd_SS^alpha_k)^(1/(alpha_l));
Invest_nbdx_SS = (1-xxi)*ddelta*K_nbd_SS;
w_SS = alpha_l * A_nbd * K_nbd_SS^alpha_k * L_nbd_SS^(alpha_l-1);

// Calibrating bank-dependent firms
rk_bd_SS  = eps_L/(eps_L-1)*(1/bbeta -1) + 1/(eps_L-1) + ddelta;
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
bbeta_endog = bbeta * exp(nu_bbeta);
llambda = (C-h*C(-1))^(-ggamma) - bbeta_endog*h*(C(+1)-h*C)^(-ggamma);
llambda/steady_state(llambda) = (R/steady_state(R)) * (llambda(+1)/steady_state(llambda));
R = Rn/Pi(+1);
EA_k = (1-alpha_l)*(P_I(+1)*exp(nu_A(+1)))^(1/(1-alpha_l)) * (alpha_l/w(+1))^(alpha_l/(1-alpha_l));

// NKPC AND TAYLOR RULE
log(Pi/steady_state(Pi)) = (eps_PC-1)/theta_PC * log(P_I/steady_state(P_I))+ bbeta_endog*log(Pi(+1)/steady_state(Pi)); //Note: log linear version
Rn/steady_state(Rn) = Trule*Rn_target/steady_state(Rn) + (1-Trule)*(Rn(-1)/steady_state(Rn))^rho_Rn * ( (Pi/Pi_SS)^phi_pi * (Y/steady_state(Y))^phi_y )^(1-rho_mp) * exp(-nu_mp) * exp(nu_fg(-4));

//NON-BANK-DEPENDENT FIRMS
Q_nbd = ((llambda-bbeta_endog*llambda(+1)*Q_nbd(+1)*kappa_I_nbd*(Invest_nbdx(+1)/Invest_nbdx-1)*(Invest_nbdx(+1)/Invest_nbdx)^2)/(llambda*(1-kappa_I_nbd/2*(Invest_nbdx/Invest_nbdx(-1)-1)^2-kappa_I_nbd*(Invest_nbdx/Invest_nbdx(-1)-1)*(Invest_nbdx/Invest_nbdx(-1)))));
rk_nbd = Q_nbd*R - Q_nbd(+1)*(1-ddelta);

K_nbd = (alpha_k/(1-alpha_l)*A_nbd^(1/(1-alpha_l))*EA_k/(rk_nbd))^((1-alpha_l)/(1-alpha_l-alpha_k));
L_nbd = ( alpha_l * P_I*A_nbd*exp(nu_A)*K_nbd(-1)^alpha_k/w)^(1/(1-alpha_l));
Y_nbd = A_nbd*exp(nu_A)*K_nbd(-1)^(alpha_k)*L_nbd^(alpha_l);
Invest_nbd*(1-kappa_I_nbd/2*(Invest_nbd/Invest_nbd(-1)-1)^2) = K_nbd - (1-ddelta)*K_nbd(-1) ;

//BANK-DEPENDENT FIRMS
Q_bd = ((llambda-bbeta_endog*llambda(+1)*Q_bd(+1)*kappa_I_bd*(Invest_bdx(+1)/Invest_bdx-1)*(Invest_bdx(+1)/Invest_bdx)^2)/(llambda*(1-kappa_I_bd/2*(Invest_bdx/Invest_bdx(-1)-1)^2-kappa_I_bd*(Invest_bdx/Invest_bdx(-1)-1)*(Invest_bdx/Invest_bdx(-1)))));
rk_bd = Q_bd*RL - Q_bd(+1)*(1-ddelta);

K_bd = (alpha_k/(1-alpha_l)*A_bd^(1/(1-alpha_l))*EA_k/(rk_bd))^((1-alpha_l)/(1-alpha_l-alpha_k));
L_bd = ( alpha_l * P_I*A_bd*exp(nu_A)*K_bd(-1)^alpha_k/w)^(1/(1-alpha_l));
Y_bd = A_bd*exp(nu_A)*K_bd(-1)^(alpha_k)*L_bd^(alpha_l);
Invest_bd*(1-kappa_I_bd/2*(Invest_bd/Invest_bd(-1)-1)^2) = K_bd - (1-ddelta)*K_bd(-1) ;

// AGGREGATION
L = (1-xxi)*L_nbd+xxi*L_bd;
Y = (1-xxi)*Y_nbd+xxi*Y_bd;
Invest_nbdx = (1-xxi)*Invest_nbd;
Invest_bdx = xxi*Invest_bd;
Invest = (1-xxi)*Invest_nbd+xxi*Invest_bd;
w = L^psi_L * cchi / llambda;
C = Y-Invest;

// BANK EQUATIONS
RLn = eps_L/(eps_L-1)*Rn;
RL = RLn/Pi(+1);

// EXOGENOUS PROCESSES
nu_A = nu_A(-1)*rho_A + eps_A;
nu_mp = nu_mp(-1)*rho_mp + eps_mp;
nu_fg = nu_fg(-1)*rho_fg + eps_fg;
nu_bbeta = nu_bbeta(-1)*rho_bbeta + eps_bbeta;

// Interest rate target
Rn_target = steady_state(Rn) * exp(eps_target);
Trule = eps_Trule;

// Bank lending
Lo = Q_bd*K_bd;

end;

initval;
// Normalization
Y = Norm;

// Interest rates and inflation
Pi = Pi_SS;
R = 1/bbeta;
Rn = R*Pi_SS;

// Non-bank-dependent
rk_nbd = 1/bbeta -1 + ddelta;
Q_nbd  = 1;

Y_nbd = (1-Y_bd_sh)/(1-xxi) * Y;
K_nbd = alpha_k*Y_nbd/rk_nbd;
L_nbd = (Y_nbd/A_nbd/K_nbd^alpha_k)^(1/(alpha_l));
Invest_nbd = ddelta*K_nbd;
Invest_nbdx = (1-xxi)*Invest_nbd;

// Bank-dependent
rk_bd  = eps_L/(eps_L-1)*(1/bbeta -1) + 1/(eps_L-1) + ddelta;
Q_bd   = 1;

Y_bd  = Y_bd_sh/xxi * Y;
K_bd  = alpha_k*Y_bd/rk_bd;
L_bd = (Y_bd/A_bd/K_bd^alpha_k)^(1/alpha_l);
Invest_bd  = ddelta*K_bd;
Invest_bdx = xxi*Invest_bd;

// Aggregates
Invest = (1-xxi)*Invest_nbd+xxi*Invest_bd;
C = Y - Invest;
w = alpha_l * A_nbd * K_nbd^alpha_k * L_nbd^(alpha_l-1);
L = xxi*L_bd + (1-xxi)*L_nbd;

// Other standard stuff
P_I = 1;
EA_k = (1-alpha_l)* P_I^(1/(1-alpha_l)) * (alpha_l/w)^(alpha_l/(1-alpha_l));
llambda = (C-h*C)^(-ggamma) - bbeta*h*(C-h*C)^(-ggamma);

// Bank equations
RLn = eps_L/(eps_L-1) * R;
RL = RLn/Pi_SS;

// Exogenous processes
nu_A = 0;
nu_mp = 0;
nu_fg = 0;

// Patience
bbeta_endog = bbeta;

// Interest rate target
Rn_target = Rn;
Trule = 0;

// Bank lending
Lo = Q_bd*K_bd;

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


Rn_NK = Rn;
Pi_NK = Pi;
Y_NK = Y;
C_NK = C;
Invest_NK = Invest;
L_NK = L;

save('irfs_NK.mat', 'Rn_NK', 'Pi_NK', 'Y_NK', 'C_NK', 'Invest_NK', 'L_NK')


