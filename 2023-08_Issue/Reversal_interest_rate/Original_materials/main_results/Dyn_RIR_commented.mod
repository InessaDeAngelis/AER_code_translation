// DYNARE FILE FOR BENCHMARK MODEL

var llambda R dRL rk_nbd rk_bd w EA_k L L_nbd L_bd K_nbd K_bd Y Y_bd Y_nbd C Invest Invest_nbdx Invest_bdx  Invest_nbd Invest_bd Q_nbd Q_bd nu_A nu_mp nu_fg Rn Pi P_I D RDn RLn Pi_D Pi_L LevCost Lo Eq_B CG S Q_S RS NII_B RL Divs ROE_annual bbeta_endog nu_bbeta LR_rate Rn_target Trule;
varexo eps_A eps_mp eps_fg eps_bbeta eps_target eps_Trule;

parameters bbeta h Norm   nnu aalpha alpha_l alpha_k ddelta A_nbd ggamma elast_invest kappa_I_nbd rho_A cchi psi_L rho_Rn phi_pi phi_y rho_mp rho_fg eps_PC theta_PC Pi_SS L_to_S Eq_to_L ben_D D_bar cchi_D D_max DGDP_ratio kappa_L eps_L eps_D delta_E tau_S rho_SS lvg_elasticity xxi A_bd kappa_I_bd Y_bd_sh Invest_bdx_SS Invest_nbdx_SS Invest_SS rho_bbeta rho_eq LvgRatio Iss_to_A;

// STANDARD NK
// Preferemces
ggamma = 1.0;    // risk aversion coefficient       
h = 0.62;        // habit parameter h       
psi_L = 2;       // inverse Frisch elasticity (called phi in the paper)       
bbeta = (1-0.02)^(1/4);       // subjective discount factor


// Technology
Norm = 1.0;             // Equivalent to normalizing time worked in steady state
nnu = 0.85;             // decreasing returns to scale parameter
aalpha = 0.36;          // capital share
alpha_k = nnu * aalpha; 
alpha_l = nnu * (1-aalpha);
ddelta = 0.025;         // depreciation
xxi = 0.998;            // fraction of bank-dependent firms
Y_bd_sh = 0.558;        // output share of bank-dependent firms  
A_nbd = 1.0;            // non-bank-dependent firm produc
elast_invest = 0.2;     // elasticity of investment to Q
kappa_I_nbd = 1/elast_invest;         // investment adjustment cost
kappa_I_bd = 1/elast_invest;     


// Price stickiness and monetary policy
eps_PC = 1.35/(1.35-1); // markup parameter
theta_calvo = 0.82;     // equivalent Calvo stickiness
Pi_SS = 1.00;        // steady-state inflation
                           
rho_Rn = 0.93;          // Taylor rule persistence
phi_pi = 2.74;          // coefficient on inflation
phi_y = 0.0;            // coefficient on output
theta_PC = theta_calvo*(eps_PC-1)/((1-theta_calvo)*(1-bbeta*theta_calvo)); // derive Rotemberg parameter from Calvo, https://cadmus.eui.eu/bitstream/handle/1814/63144/ECO_OH_2019_01.pdf?sequence=1&isAllowed=y

// BANK PARAMETERS
L_to_S = 0.65/0.18;    // loan-to-bond ratio       
Iss_to_A = 0.01/4;    // equity issuance-to-asset ratio

Eq_to_L = 0.155; // capitalization ratio
LvgRatio = Eq_to_L * L_to_S/(1+L_to_S);  // leverage ratio

DGDP_ratio = 2.45/1.93; // deposits/GDP in 2014 vs 2000

ben_D = 0.005/4;  // non-pecuniary benefit of deposit issuance
eps_L = 200.0;  // loan demand elasticity
eps_D = -275.0; // deposit demand elasticity
tau_S = 3.4 * 4;   // bond maturity
rho_SS = Eq_to_L; // capitalization ratio target
lvg_elasticity = 0.0007; // change in annual loan rate for a 25bp increase in target capitalization ratio

kappa_L = lvg_elasticity/4 * 1 / (1/rho_SS - 1/(rho_SS+0.0025))^2; // leverage cost parameter
rho_eq = 1-Iss_to_A / LvgRatio; // persistence of bank net worth


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
bbeta_endog = bbeta * exp(nu_bbeta);     // Discount factor shocks
llambda = (C-h*C(-1))^(-ggamma) - bbeta_endog*h*(C(+1)-h*C)^(-ggamma);  // Marginal utility of consumption (A.4)
llambda/steady_state(llambda) = (R/steady_state(R)*exp(eps_bbeta)) * (llambda(+1)/steady_state(llambda)); // Euler equation (A.28)
R = Rn/Pi(+1);  // Fisher equation (A.17)
EA_k = (1-alpha_l)*(P_I(+1)*exp(nu_A(+1)))^(1/(1-alpha_l)) * (alpha_l/w(+1))^(alpha_l/(1-alpha_l)); // Defined in (A.10)

// NKPC AND TAYLOR RULE
log(Pi/steady_state(Pi)) = (eps_PC-1)/theta_PC * log(P_I/steady_state(P_I))+ bbeta_endog*log(Pi(+1)/steady_state(Pi)); // NKPC (A.44)
Rn/steady_state(Rn) = Trule*Rn_target/steady_state(Rn) + (1-Trule)*(Rn(-1)/steady_state(Rn))^rho_Rn * ( (Pi/Pi_SS)^phi_pi * (Y/steady_state(Y))^phi_y )^(1-rho_mp) * exp(-nu_mp) * exp(nu_fg(-4)); // Taylor rule (19) + indicator for forward guidance

//NON-BANK-DEPENDENT FIRMS
Q_nbd = ((llambda-bbeta_endog*llambda(+1)*Q_nbd(+1)*kappa_I_nbd*(Invest_nbdx(+1)/Invest_nbdx-1)*(Invest_nbdx(+1)/Invest_nbdx)^2)/(llambda*(1-kappa_I_nbd/2*(Invest_nbdx/Invest_nbdx(-1)-1)^2-kappa_I_nbd*(Invest_nbdx/Invest_nbdx(-1)-1)*(Invest_nbdx/Invest_nbdx(-1))))); // Capital pricing equation (A.42)
rk_nbd = Q_nbd*R - Q_nbd(+1)*(1-ddelta); // User cost of capital (A.8)

K_nbd = (alpha_k/(1-alpha_l)*A_nbd^(1/(1-alpha_l))*EA_k/(rk_nbd))^((1-alpha_l)/(1-alpha_l-alpha_k)); // Capital demand (A.9)
L_nbd = ( alpha_l * P_I*A_nbd*exp(nu_A)*K_nbd(-1)^alpha_k/w)^(1/(1-alpha_l)); // Labor demand (A.11)
Y_nbd = A_nbd*exp(nu_A)*K_nbd(-1)^(alpha_k)*L_nbd^(alpha_l); // Production function 
Invest_nbd*(1-kappa_I_nbd/2*(Invest_nbd/Invest_nbd(-1)-1)^2) = K_nbd - (1-ddelta)*K_nbd(-1) ; // Capital accumulation (A.41)

//BANK-DEPENDENT FIRMS
Q_bd = ((llambda-bbeta_endog*llambda(+1)*Q_bd(+1)*kappa_I_bd*(Invest_bdx(+1)/Invest_bdx-1)*(Invest_bdx(+1)/Invest_bdx)^2)/(llambda*(1-kappa_I_bd/2*(Invest_bdx/Invest_bdx(-1)-1)^2-kappa_I_bd*(Invest_bdx/Invest_bdx(-1)-1)*(Invest_bdx/Invest_bdx(-1))))); // Capital pricing equation (A.42)
rk_bd = Q_bd*RLn/Pi(+1) - Q_bd(+1)*(1-ddelta); // User cost of capital (A.8)

K_bd = (alpha_k/(1-alpha_l)*A_bd^(1/(1-alpha_l))*EA_k/(rk_bd))^((1-alpha_l)/(1-alpha_l-alpha_k)); // Capital demand (A.9)
L_bd = ( alpha_l * P_I*A_bd*exp(nu_A)*K_bd(-1)^alpha_k/w)^(1/(1-alpha_l)); // Labor demand (A.11)
Y_bd = A_bd*exp(nu_A)*K_bd(-1)^(alpha_k)*L_bd^(alpha_l); // Production function
Invest_bd*(1-kappa_I_bd/2*(Invest_bd/Invest_bd(-1)-1)^2) = K_bd - (1-ddelta)*K_bd(-1) ; // Capital accumulation (A.41)

// AGGREGATION
L = (1-xxi)*L_nbd+xxi*L_bd; // Labor market clearing (A.22)
Y = (1-xxi)*Y_nbd+xxi*Y_bd; // Aggregate production function (A.31) 
Invest_nbdx = (1-xxi)*Invest_nbd; // Definition of per-firm investment 
Invest_bdx = xxi*Invest_bd;
Invest = (1-xxi)*Invest_nbd+xxi*Invest_bd; // Investment goods market clearing (A.43)
w = L^psi_L * cchi / llambda; // Labor-leisure optimization (A.5)
C = Y-Invest; // Resource constraint (A.20)

// BANK EQUATIONS
// Deposits
RDn = max(1, eps_D/(eps_D-1) * (Rn + ben_D)); // Deposit rate under monopolistic competition + ZLB
D = min(D_max - (1-RDn/Rn)/cchi_D * llambda, D_max); // Household liquidity demand (A.29)
Pi_D = (Rn+ben_D-RDn)*D/Pi(+1); // Profits from deposit-taking (A.36)

// Loans
Lo = Q_bd*K_bd; // Loan market clearing (A.26)
RLn = eps_L/(eps_L-1)*(Rn + dRL); // Loan rate under monopolistic competition + leverage costs

Pi_L = (RLn-Rn)*Lo/Pi(+1); // Profits from lending (A.35)
RL = RLn/Pi(+1); // Real loan rate

dRL = kappa_L * max(0, Lo/Eq_B - 1/rho_SS)^2; // Marginal leverage cost of loans (A.37)
LevCost = dRL * Lo/Pi(+1); // Total leverage costs

// Balance sheet and NW accumulation
S = Eq_B + D - Lo; // Balance sheet identity (4)
NII_B = Pi_L + Pi_D + (Rn/Pi(+1)-1)*Eq_B - LevCost; // Net interest income (A.34)

CG = (RS - R(-1))*S(-1); // Capital gains on bonds (A.33)
Eq_B = rho_eq * (1-delta_E) * (CG + NII_B(-1) + Eq_B(-1)) + (1-rho_eq) * steady_state(Eq_B); // Net worth accumulation (A.32)

Divs = CG + NII_B(-1) + Eq_B(-1) - Eq_B; // Bank dividends (A.38)
ROE_annual = (Divs + Divs(+1) + Divs(+2) + Divs(+3) + Eq_B(+3))/Eq_B(-1); // One-year accounting ROE (extrapolate A.39)

// Bond pricing
Q_S = (1/tau_S*1/Pi(+1) + (1-1/tau_S)*Q_S(+1))/(Rn/Pi(+1)); // No-arbitrage bond pricing (A.18)
RS = (1/tau_S*1/Pi + (1-1/tau_S)*Q_S)/Q_S(-1); // Definition of bond returns

// EXOGENOUS PROCESSES
nu_A = nu_A(-1)*rho_A + eps_A; // Productivity shocks
nu_mp = nu_mp(-1)*rho_mp + eps_mp; // Taylor rule shocks
nu_fg = nu_fg(-1)*rho_fg + eps_fg; // Alternative forward guidance shocks to Taylor rule
nu_bbeta = nu_bbeta(-1)*rho_bbeta + eps_bbeta; // Discount factor shocks

// LONG-RUN LOAN RATE
LR_rate = log(RL) + log(RL(+1)) + log(RL(+2)) + log(RL(+3)); // One-year loan rate

// TARGET RATE 
Rn_target = steady_state(Rn) * exp(eps_target); // Promised forward guidance rate
Trule = eps_Trule; // Forward guidance indicator

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


// TAYLOR RULE INNOVATIONS: PERFECT FORESIGHT
shocks;
var eps_mp;
periods 1;
values 0.00;
end;

perfect_foresight_setup(periods=200);
perfect_foresight_solver;

// Record IRFs for variables of interest
Y_000 = Y; 
Invest_000 = Invest;
Rn_000 = Rn;
Lo_000 = Lo;
dRL_000 = dRL;
RL_000 = LR_rate;
Invest_bd_000 = Invest_bd;
Invest_nbd_000 = Invest_nbd;



shocks;
var eps_mp;
periods 1;
values 0.001;
end;

perfect_foresight_setup(periods=200);
perfect_foresight_solver(solve_algo=9);

Y_001 = Y;
Invest_001 = Invest;
Rn_001 = Rn;
Lo_001 = Lo;
dRL_001 = dRL;
RL_001 = LR_rate;
Invest_bd_001 = Invest_bd;
Invest_nbd_001 = Invest_nbd;

shocks;
var eps_mp;
periods 1;
values 0.005;
end;

perfect_foresight_setup(periods=200);
perfect_foresight_solver(solve_algo=9);

Y_005 = Y;
Invest_005 = Invest;
Rn_005 = Rn;
Lo_005 = Lo;
dRL_005 = dRL;
RL_005 = LR_rate;
Invest_bd_005 = Invest_bd;
Invest_nbd_005 = Invest_nbd;

shocks;
var eps_mp;
periods 1;
values 0.006;
end;

perfect_foresight_setup(periods=200);
perfect_foresight_solver(solve_algo=9);

Y_006 = Y;
Invest_006 = Invest;
Rn_006 = Rn;
Lo_006 = Lo;
dRL_006 = dRL;
RL_006 = LR_rate;
Invest_bd_006 = Invest_bd;
Invest_nbd_006 = Invest_nbd;


shocks;
var eps_mp;
periods 1;
values 0.01;
end;

perfect_foresight_setup(periods=200);
perfect_foresight_solver(solve_algo=9);

Y_010 = Y;
Invest_010 = Invest;
Rn_010 = Rn;
Lo_010 = Lo;
dRL_010 = dRL;
RL_010 = LR_rate;
Invest_bd_010 = Invest_bd;
Invest_nbd_010 = Invest_nbd;

shocks;
var eps_mp;
periods 1;
values 0.011;
end;


perfect_foresight_setup(periods=200);
perfect_foresight_solver(solve_algo=9);

Y_011 = Y;
Invest_011 = Invest;
Rn_011 = Rn;
Lo_011 = Lo;
dRL_011 = dRL;
RL_011 = LR_rate;
Invest_bd_011 = Invest_bd;
Invest_nbd_011 = Invest_nbd;


shocks;
var eps_mp;
periods 1;
values 0.015;
end;

perfect_foresight_setup(periods=200);
perfect_foresight_solver(solve_algo=9);

Y_015 = Y;
Invest_015 = Invest;
Rn_015 = Rn;
Lo_015 = Lo;
dRL_015 = dRL;
RL_015 = LR_rate;
Invest_bd_015 = Invest_bd;
Invest_nbd_015 = Invest_nbd;


shocks;
var eps_mp;
periods 1;
values 0.016;
end;

perfect_foresight_setup(periods=200);
perfect_foresight_solver(solve_algo=9);

Y_016 = Y;
Invest_016 = Invest;
Rn_016 = Rn;
Lo_016 = Lo;
dRL_016 = dRL;
RL_016 = LR_rate;
Invest_bd_016 = Invest_bd;
Invest_nbd_016 = Invest_nbd;

shocks;
var eps_mp;
periods 1;
values 0.017;
end;

perfect_foresight_setup(periods=200);
perfect_foresight_solver(solve_algo=9);

Y_020 = Y;
Invest_020 = Invest;
Rn_020 = Rn;
Lo_020 = Lo;
dRL_020 = dRL;
RL_020 = LR_rate;
Invest_bd_020 = Invest_bd;
Invest_nbd_020 = Invest_nbd;

shocks;
var eps_mp;
periods 1;
values 0.018;
end;

perfect_foresight_setup(periods=200);
perfect_foresight_solver(solve_algo=9);

Y_021 = Y;
Invest_021 = Invest;
Rn_021 = Rn;
Lo_021 = Lo;
dRL_021 = dRL;
RL_021 = LR_rate;
Invest_bd_021 = Invest_bd;
Invest_nbd_021 = Invest_nbd;


// MAIN RESULTS: BANK LENDING AND AGG. INVESTMENT

// Formatting and colors
lw = 1.5;
set(0,'defaultLineLineWidth',lw);
set(groot, 'defaultTextInterpreter', 'Latex')

co = [ 0 .45 .74;
    0.12 0.51 0.60;
    0.23 0.56 0.46;
    0.35 0.61 0.32;
    0.47 0.67 0.19];
set(groot,'defaultAxesColorOrder',co)

// Bank lending IRF
figure(1)
plot(0:20, 100*(log(Lo_001(2:22))-log(Lo_000(2:22))))
hold on
plot(0:20, 100*(log(Lo_006(2:22))-log(Lo_005(2:22))), '--')
plot(0:20, 100*(log(Lo_011(2:22))-log(Lo_010(2:22))), ':')
plot(0:20, 100*(log(Lo_016(2:22))-log(Lo_015(2:22))), '-.')
plot(0:20, 100*(log(Lo_021(2:22))-log(Lo_020(2:22))))
title('Bank lending IRF')
xlabel('Time')
ylabel('%')
legend('i=2%', 'i=1%', 'i=0%', 'i=-1%', 'i=-1.5%')
saveas(gcf, 'loan_irf.png', 'png')
saveas(gcf, 'loan_irf', 'epsc')

// Investment IRF
figure(2)
plot(0:20, 100*(log(Invest_001(2:22))-log(Invest_000(2:22))))
hold on
plot(0:20, 100*(log(Invest_006(2:22))-log(Invest_005(2:22))), '--')
plot(0:20, 100*(log(Invest_011(2:22))-log(Invest_010(2:22))), ':')
plot(0:20, 100*(log(Invest_016(2:22))-log(Invest_015(2:22))), '-.')
plot(0:20, 100*(log(Invest_021(2:22))-log(Invest_020(2:22))))
title('Investment IRF')
xlabel('Time')
ylabel('%')
legend('i=2%', 'i=1%', 'i=0%', 'i=-1%', 'i=-1.5%')
saveas(gcf, 'invest_irf.png', 'png')
saveas(gcf, 'invest_irf', 'epsc')

// Secondary results: IRFs of output and consumption
co = [       ...
    0    0.4470    0.7410 ;
    0.4660    0.6740    0.1880 ;
    0.8500    0.3250    0.0980 ;
    0.4940    0.1840    0.5560 ;
    0.9290    0.6940    0.1250 ;
    0.3010    0.7450    0.9330 ;
    0.6350    0.0780    0.1840] ; 

set(groot,'defaultAxesColorOrder',co)

// Output IRF
figure(3)
plot(0:20, 100*(log(Y_001(2:22))-log(Y_000(2:22))), '--')
hold on
plot(0:20, 100*(log(Y_016(2:22))-log(Y_015(2:22))))
title('Output IRF')
xlabel('Time')
ylabel('%')
legend('Steady state', 'Reversal rate')
saveas(gcf, 'y_irf.png', 'png')
saveas(gcf, 'y_irf', 'epsc')

// THE MAIN MECHANISM

// Bank-dependent investment IRF
figure(4)
plot(0:20, 100*(log(Invest_bd_001(2:22))-log(Invest_bd_000(2:22))), '--')
hold on
plot(0:20, 100*(log(Invest_bd_016(2:22))-log(Invest_bd_015(2:22))))
title('Bank-dependent investment IRF')
xlabel('Time')
ylabel('%')
legend('Steady state', 'Reversal rate')
saveas(gcf, 'invest_bd_irf.png', 'png')
saveas(gcf, 'invest_bd_irf', 'epsc')

// Non-bank-dependent investment IRF
figure(5)
plot(0:20, 100*(log(Invest_nbd_001(2:22))-log(Invest_nbd_000(2:22))), '--')
hold on
plot(0:20, 100*(log(Invest_nbd_016(2:22))-log(Invest_nbd_015(2:22))))
title('Non-bank-dependent investment IRF')
xlabel('Time')
ylabel('%')
legend('Steady state', 'Reversal rate')
saveas(gcf, 'invest_nbd_irf.png', 'png')
saveas(gcf, 'invest_nbd_irf', 'epsc')

// Marginal leverage cost IRF
figure(6)
plot(0:20, 40000*(dRL_001(2:22) - dRL_000(2:22)), '--')
hold on
plot(0:20, 40000*(dRL_016(2:22) - dRL_015(2:22)))
ylim([-10 10])
title('Leverage cost IRF')
xlabel('Periods')
ylabel('Basis points')
legend('Steady state', 'Reversal rate')
saveas(gcf, 'dRL_irf.png', 'png')
saveas(gcf, 'dRL_irf', 'epsc')


// One-year loan rate IRF
figure(7)
plot(0:20, 40000*(RL_001(2:22) - RL_000(2:22)), '--')
hold on
plot(0:20, 40000*(RL_016(2:22) - RL_015(2:22)))
title('Loan rate IRF')
xlabel('Periods')
ylabel('Basis points')
legend('Steady state', 'Reversal rate')
saveas(gcf, 'loanrate_irf.png', 'png')
saveas(gcf, 'loanrate_irf', 'epsc')

// IRF OF POLICY RATE (NOT IN PAPER)
figure(8)
plot(0:20, 100*(Rn_000(2:22).^4-1))
hold on
plot(0:20, 100*(Rn_005(2:22).^4-1))
plot(0:20, 100*(Rn_010(2:22).^4-1))
plot(0:20, 100*(Rn_015(2:22).^4-1))
plot(0:20, 100*(Rn_020(2:22).^4-1))
xlabel('Periods')
ylabel('Percentage points')
legend('Steady state', '1%', '0%', '-1%', '-1.5%')



