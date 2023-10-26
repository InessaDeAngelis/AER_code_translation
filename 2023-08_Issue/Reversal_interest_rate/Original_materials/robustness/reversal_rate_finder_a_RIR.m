% Compute investment reversal rate when shocks are to productivity (discussed in
% Appendix). Code is similar to reversal_rate_finder_RIR.m

clear

% Set vector of productivity shocks
Nshocks = 100;

a_shock_min = 0.00;
a_shock_max = 0.035;
a_shocks = linspace(a_shock_min, a_shock_max, Nshocks);

% IRF horizon
horizon = 13;

% Arrays to store interest rates and IRFs
r_vec = zeros(1, Nshocks);
irf_vec = zeros(Nshocks, horizon);
rr_vec = -ones(1,horizon);

for n=1:Nshocks
    
    var_aV = a_shocks(n);

    save('shock_value_mp.mat', 'var_aV')
    
    try
        dynare Dyn_RIR_finder_a;
        
        r_vec(n) = Rn(2)^4 - 1;
        
        for t=1:horizon
            irf_vec(n,t) = log(Invest_1(t+1)) - log(Invest_0(t+1));
            
            if Invest_1(t+1)<Invest_0(t+1)
                rr_vec(t) = max(r_vec(n), rr_vec(t));
            end
            
        end
        
    catch
        r_vec(n) = NaN;
        irf_vec(n) = NaN;
    end

end


save('a_results.mat', 'r_vec', 'irf_vec', 'rr_vec')
set(groot, 'defaultTextInterpreter', 'Latex')

figure(1)
scatter(100*r_vec, 100*irf_vec(:,1), '.')
xlabel('Policy rate (pts)')
ylabel('Investment response to 10bp monetary shock (\%)')
title('Productivity shocks')
saveas(gcf, 'reversal_irf_a.png', 'png')
saveas(gcf, 'reversal_irf_a', 'epsc')
