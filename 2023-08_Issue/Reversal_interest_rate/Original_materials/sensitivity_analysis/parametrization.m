% Benchmark parametrization. Run this file to set all parameters at their
% benchmark values, and then replace one parameter to do sensitivity
% analysis.

% Preferences
ggammaV = 1.0;           
hV = 0.62;               
psi_LV = 2;              
bbetaV = (1-0.02)^(1/4);    

% Technology
NormV = 1.0;            
nnuV = 0.85;             
aalphaV = 0.36;          
alpha_kV = nnuV * aalphaV;
alpha_lV = nnuV * (1-aalphaV);
ddeltaV = 0.025;         
xxiV = 0.998;              
Y_bd_shV = 0.558;          
A_nbdV = 1.0;            
elast_investV = 0.2;    

% Price stickiness and monetary policy
eps_PCV = 1.35/(1.35-1); 
theta_calvoV = 0.82;     
Pi_SSV = 1.000;        
                            
rho_RnV = 0.93;          
phi_piV = 2.74;          
phi_yV = 0.00;            
theta_PCV = theta_calvoV*(eps_PCV-1)/((1-theta_calvoV)*(1-bbetaV*theta_calvoV)); 

% BANK PARAMETERS
L_to_SV = 0.65/0.18; 
Iss_to_AV = 0.01/4;

Eq_to_LV = 0.155; 
LvgRatioV = Eq_to_LV * L_to_SV/(1+L_to_SV);

DGDP_ratioV = 2.45/1.93;

ben_DV = 0.005/4;
eps_LV = 200;
eps_DV = -275;
tau_SV = 3.4 * 4;   
rho_SSV = Eq_to_LV; 
lvg_elasticityV = 0.0007;
kappa_LV = lvg_elasticityV/4 * 1 / (1/rho_SSV - 1/(rho_SSV + 0.0025))^2; 

rho_barV = Eq_to_LV;

% SHOCKS
rho_AV = 0.0;
rho_mpV = 0.0;
rho_fgV = 0.0;
rho_bbetaV = 0.0;

save('params_dynare.mat')