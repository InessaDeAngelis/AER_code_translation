% Create figure showing response of NII to interest rate cuts (left panel
% of Figure 7)

clear

% Set vector of shocks
Nshocks = 15;
cut_min = 0.0;
cut_max = 0.015;
mp_cuts = linspace(cut_min, cut_max, Nshocks);

% IRF horizon
horizon = 4;


r_vec = zeros(1, Nshocks);
nii_vec = zeros(1, Nshocks);
% eq_b_vec = zeros(1, Nshocks);
% eq_b_impact = zeros(1, Nshocks);
roe_vec = zeros(1, Nshocks);

% nii_irf_deposits = zeros(1, Nshocks);

T = 20;
% eq_b_irf = zeros(Nshocks, 1+T);

for n=1:Nshocks
    
    var_epsV = mp_cuts(n);
    
    save('shocks_RIR_nii.mat', 'var_epsV')
    
    save('shock_value_deposits.mat', 'var_epsV')
    

    % Calculate and save impulse responses of NII, net worth Eq_B, and
    % dividends Divs
    dynare Dyn_RIR_nii
    
    % Marginal impulse response vectors

    % Nominal rate
    r_vec(n) = Rn_0(2)^4 - 1;

    % NII/Steady state assets
    nii_vec(n) = (NII_B_1(2)/A_B_1(1) - NII_B_0(2)/A_B_0(1));

    % ROE over one year
    roe_vec(n) = log((sum(Divs_1(2:5)) + Eq_B_1(5))/Eq_B_1(1)) - log((sum(Divs_0(2:5)) + Eq_B_0(5))/Eq_B_0(1));
    
end

save('nii_results.mat', 'r_vec', 'nii_vec')

% Borio et al. estimate of dNII/di as a function of i
borio_et_al = -0.1*(0.5327 - 0.054*100*r_vec);

% Impulse response of NII in the model vs. Borio et al.
figure(1)
plot(100*r_vec, borio_et_al, 'k--')
hold on
plot(100*r_vec, 100*nii_vec, 'r')
xlabel('Policy rate (pts)')
ylabel('Change in NII/Assets at impact (%)')
title('Response of NII to 10bp cut')
legend('Borio et al.', 'Model', 'Location', 'northwest')
saveas(gcf, 'nii_response.png', 'png')
saveas(gcf, 'nii_response', 'epsc')

% Marginal response of ROE to interest rate cuts in the model
figure(2)
scatter(100*r_vec, 100*roe_vec, 100, '.')
xlabel('Policy rate (pts)')
ylabel('Change in 1-year ROE at impact (%)')
title('Response of ROE to 10bp cut')
saveas(gcf, 'roe_irf.png', 'png')
saveas(gcf, 'roe_irf', 'epsc')


