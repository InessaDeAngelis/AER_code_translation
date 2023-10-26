// Clean code for replication

var llambda R dRL rk_nbd rk_bd w EA_k L L_nbd L_bd K_nbd K_bd Y Y_bd Y_nbd C Invest Invest_nbdx Invest_bdx  Invest_nbd Invest_bd Q_nbd Q_bd nu_A nu_mp nu_fg Rn Pi P_I D RDn RLn Pi_D Pi_L LevCost Lo Eq_B CG S Q_S RS NII_B RL Divs ROE_annual bbeta_endog nu_bbeta LR_rate Rn_target Trule;
varexo eps_A eps_mp eps_fg eps_bbeta eps_target eps_Trule;

parameters bbeta h Norm   nnu aalpha alpha_l alpha_k ddelta A_nbd ggamma elast_invest kappa_I_nbd rho_A cchi psi_L rho_Rn phi_pi phi_y rho_mp rho_fg eps_PC theta_PC Pi_SS L_to_S Eq_to_L ben_D D_bar cchi_D D_max DGDP_ratio kappa_L eps_L eps_D delta_E tau_S rho_SS lvg_elasticity xxi A_bd kappa_I_bd Y_bd_sh Invest_bdx_SS Invest_nbdx_SS Invest_SS rho_bbeta rho_eq LvgRatio Iss_to_A;

// STANDARD NK
// Preferemces
ggamma = 1.0;           // NAWM II
h = 0.62;               // NAWM II est/mode
psi_L = 2;              // NAWM II
bbeta = (1-0.02)^(1/4);          // NAWM II (2% real rate incl of prod growth)


// Technology
Norm = 1.0;             //Normalization (Output)
nnu = 0.85;             // CtoI approx 57.5/21.0
aalpha = 0.36;          // alpha: NAWM II
alpha_k = nnu * aalpha;
alpha_l = nnu * (1-aalpha);
ddelta = 0.025;         // NAWM II
xxi = 0.998;              //0.998;            // Eurostat SME
Y_bd_sh = 0.558;          //.558;        //-> A_bd Eurostat SME
A_nbd = 1.0;            //Normalization? Can adjust aggregate labor
elast_invest = 0.2;
kappa_I_nbd = 1/elast_invest;         // NAWM I updated
kappa_I_bd = 1/elast_invest;      // Normalize to get same peak response? Or integral response? (Given bank distortions)


// Price stickiness and monetary policy
eps_PC = 1.35/(1.35-1); // NAWM II
theta_calvo = 0.82;     // NAWM II
Pi_SS = 1.00;        // NAWM II
                            //Taylor rule
rho_Rn = 0.93;          // NAWM II est/mode
phi_pi = 2.74;          // NAWM II est/mode
phi_y = 0.0;            // NAWM II est/mode = 0.02
theta_PC = theta_calvo*(eps_PC-1)/((1-theta_calvo)*(1-bbeta*theta_calvo)); // https://cadmus.eui.eu/bitstream/handle/1814/63144/ECO_OH_2019_01.pdf?sequence=1&isAllowed=y

// BANK PARAMETERS
L_to_S = 0.65/0.18;           // SS loan to S ratio
Iss_to_A = 0.01/4;

Eq_to_L = 0.155; 
LvgRatio = Eq_to_L * L_to_S/(1+L_to_S);

DGDP_ratio = 2.45/1.93;

ben_D = 0.005/4;
eps_L = 200.0;
eps_D = -275.0;
tau_S = 3.4 * 4;   
rho_SS = Eq_to_L; 
lvg_elasticity = 0.0007; 

kappa_L = lvg_elasticity/4 * 1 / (1/rho_SS - 1/(rho_SS+0.0025))^2; 
rho_eq = 1-Iss_to_A / LvgRatio;


// SHOCKS                        
rho_A = 0.0;
rho_mp = 0.0;
rho_fg = 0.0;
rho_bbeta = 0.0;


// STEADY STATE CALIBRATION: cchi, A_bd, D_bar, D_max, kappa_L, delta_E
// Normalization
Y_SS = Norm;

// Calibrating interest rate and Fisher equation
R_SS = 1/bbeta;
Pi_SS_SS = Pi_SS;
Rn_SS = R_SS*Pi_SS_SS;

// Deposit rate, loan rate, and loan spread
RDn_SS = eps_D/(eps_D - 1) * (Rn_SS + ben_D);

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

// Calibrating deposit base
Lo_SS = K_bd_SS;
D_bar = (1 + 1/L_to_S - Eq_to_L) * Lo_SS;
D_max = DGDP_ratio * D_bar;
cchi_D = (1 - RDn_SS/Rn_SS)/(D_max-D_bar) * llambda_SS;

D_SS = D_bar;
Pi_D_SS = (Rn_SS+ben_D-RDn_SS)*D_SS/Pi_SS;

RLn_SS = eps_L/(eps_L-1) * Rn_SS;
Pi_L_SS = (RLn_SS-Rn_SS)*Lo_SS/Pi_SS;

Eq_B_SS = Lo_SS * Eq_to_L;
NII_B_SS = (Rn_SS-1)/Pi_SS*Eq_B_SS + Pi_D_SS + Pi_L_SS;
delta_E = NII_B_SS/(NII_B_SS + Eq_B_SS);
Eq_B_hat = (1-rho_eq) * Eq_B_SS;

model;

// STANDARD EQUATIONS
bbeta_endog = bbeta * exp(nu_bbeta);
llambda = (C-h*C(-1))^(-ggamma) - bbeta_endog*h*(C(+1)-h*C)^(-ggamma);
llambda/steady_state(llambda) = (R/steady_state(R)*exp(eps_bbeta)) * (llambda(+1)/steady_state(llambda));
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
rk_bd = Q_bd*RLn/Pi(+1) - Q_bd(+1)*(1-ddelta);

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
// Deposits
RDn = max(1, eps_D/(eps_D-1) * (Rn + ben_D));
D = min(D_max - (1-RDn/Rn)/cchi_D * llambda, D_max);
Pi_D = (Rn+ben_D-RDn)*D/Pi(+1);

// Loans
Lo = Q_bd*K_bd;
RLn = eps_L/(eps_L-1)*(Rn + dRL);

Pi_L = (RLn-Rn)*Lo/Pi(+1);
RL = RLn/Pi(+1);

dRL = kappa_L * max(0, Lo/Eq_B - 1/rho_SS)^2;
LevCost = dRL * Lo/Pi(+1);

// Balance sheet and NW accumulation
S = Eq_B + D - Lo;
NII_B = Pi_L + Pi_D + (Rn/Pi(+1)-1)*Eq_B - LevCost;
CG = (RS - R(-1))*S(-1);
Eq_B = rho_eq * (1-delta_E) * (CG + NII_B(-1) + Eq_B(-1)) + (1-rho_eq) * steady_state(Eq_B);

Divs = CG + NII_B(-1) + Eq_B(-1) - Eq_B;
ROE_annual = (Divs + Divs(+1) + Divs(+2) + Divs(+3) + Eq_B(+3))/Eq_B(-1);

// Bond pricing
Q_S = (1/tau_S*1/Pi(+1) + (1-1/tau_S)*Q_S(+1))/(Rn/Pi(+1));
RS = (1/tau_S*1/Pi + (1-1/tau_S)*Q_S)/Q_S(-1);

// EXOGENOUS PROCESSES
nu_A = nu_A(-1)*rho_A + eps_A;
nu_mp = nu_mp(-1)*rho_mp + eps_mp;
nu_fg = nu_fg(-1)*rho_fg + eps_fg;
nu_bbeta = nu_bbeta(-1)*rho_bbeta + eps_bbeta;

// LONG-RUN LOAN RATE
LR_rate = log(RL) + log(RL(+1)) + log(RL(+2)) + log(RL(+3));

// TARGET RATE 
Rn_target = steady_state(Rn) * exp(eps_target);
Trule = eps_Trule;

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

// Bank stuff
RDn = eps_D/(eps_D-1) * (Rn + ben_D);
D = D_bar;
Pi_D = (Rn+ben_D-RDn)*D/Pi;

dRL = 0 ;
LevCost = 0;
Lo = K_bd;
RLn = eps_L/(eps_L-1) * Rn;
RL = RLn/Pi_SS;
Pi_L = (RLn - Rn)/Pi*Lo;

Q_S = 1/(Pi * (1 + tau_S*(Rn - 1)));
RS = Rn;

CG = 0;
NII_B = NII_B_SS;
Eq_B = (1-delta_E)/delta_E*NII_B_SS;
S = Eq_B + D - Lo;

Divs = NII_B;
ROE_annual = 1+4*Divs/Eq_B;

// Exogenous processes
nu_A = 0;
nu_mp = 0;
nu_fg = 0;

// Patience
bbeta_endog = bbeta;

// Long-run loan rate
LR_rate = 4 * log(RL);

// Interest rate target
Rn_target = Rn;
Trule = 0;

end;

resid;

steady;


// SHOCKS: Productivity
load('shock_value_mp.mat');

shocks;
var eps_A;
periods 1;
values (var_aV);
end;

perfect_foresight_setup(periods=200);
perfect_foresight_solver;

Rn_0 = Rn;
Invest_0 = Invest;
Lo_0 = Lo;


shocks;
var eps_A;
periods 1;
values (var_aV);
var eps_mp;
periods 1;
values 0.001;
end;

perfect_foresight_setup(periods=200);
perfect_foresight_solver;

Rn_1 = Rn;
Invest_1 = Invest;
Lo_1 = Lo;
