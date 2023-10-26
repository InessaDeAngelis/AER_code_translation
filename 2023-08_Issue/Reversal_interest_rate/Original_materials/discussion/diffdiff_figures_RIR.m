% Create figure comparing "diff-in-diff" lending response in the model vs.
% result found by Heider, Saidi, and Schepens (2018) (right panel of Figure
% 7)

clear

% Set vector of interest rate shocks
Nshocks = 20;
cut_min = 0.0;
cut_max = 0.015;

mp_cuts = linspace(cut_min, cut_max, Nshocks);

% IRF horizon
horizon = 4;

r_vec = zeros(1,Nshocks);
dd_lending_vec = zeros(1, Nshocks);


dd_lending_baseline = zeros(1, Nshocks); % IRF of lending for benchmark banks 
dd_lending_nd = zeros(1, Nshocks); % IRF for non-deposit-dependent banks

deposit_diff = 0.15; % SD of Deposits/Assets in HSS data
basis_points = 30; % Basis point cut between June 2014/December 2015

avg_maturity = 5; % Maturity in HSS data
coeff = 0.133; % Coefficient on Deposits/Assets
coeff_sd = 0.004 * 100 * deposit_diff; % Coefficient std. err.

% Save SD of Deposit/Asset ratio to file that gets loaded in Dynare
save('params_diffdiff.mat', 'deposit_diff')

for n=1:Nshocks
    
    var_epsV = mp_cuts(n);
    
    save('shocks_RIR_lending.mat', 'var_epsV')
    
    try
        dynare Dyn_RIR_lending
        
        r_vec(n) = Rn_0(2)^4 - 1;

        % Calculate IRF of lending for benchmark banks and
        % non-deposit-dependent banks
        dd_lending_baseline(n) = log(Lo_1(horizon)) - log(Lo_0(horizon));
        dd_lending_nd(n) = log(Lo_nd_1(horizon)) - log(Lo_nd_0(horizon));

        % Difference between IRFs
        dd_lending_vec(n) = (log(Lo_1(horizon)) - log(Lo_0(horizon))) - (log(Lo_nd_1(horizon)) - log(Lo_nd_0(horizon)));
    catch
        r_vec(n) = NaN;
        dd_lending_vec(n) = NaN;
    end
end

save('diffdiff_results.mat', 'r_vec', 'dd_lending_vec')

hss_estimate = -100*coeff/avg_maturity * ones(1, Nshocks); % Point estimate in HSS
hss_sd = 100*coeff_sd/avg_maturity; % Std. err. of HSS point estimate

xconf = [100*r_vec 100*r_vec(end:-1:1)]; 
yconf = [hss_estimate+hss_sd hss_estimate(end:-1:1)-hss_sd]; % HSS confidence interval

% Main figure comparing diff-in-diff result in model vs. data
figure(1)
p = fill(xconf,yconf,'red', 'HandleVisibility', 'off');
p.FaceColor = [1 0.8 0.8];      
p.EdgeColor = 'none';
hold on

plot(100*r_vec, 10*basis_points*dd_lending_vec)
plot(100*r_vec, hss_estimate, 'k--')
xlabel('Policy rate (pts)')
ylabel('Difference in total lending (%)')
title('Diff-in-diff lending response to 30bp cut')
legend('Model', 'Heider et al. estimate +/-1SD', 'location', 'northwest')
saveas(gcf, 'dd_vs_rate.png', 'png')
saveas(gcf, 'dd_vs_rate', 'epsc')


