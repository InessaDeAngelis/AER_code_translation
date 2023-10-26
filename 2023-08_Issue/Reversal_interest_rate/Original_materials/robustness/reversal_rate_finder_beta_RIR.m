% Compute investment reversal rate when shocks are to household discount factor 
% (discussed in Appendix). Code is similar to reversal_rate_finder_RIR.m

clear

Nshocks = 100;

bbeta_shock_min = 0.00;
bbeta_shock_max = 0.08;
bbeta_shocks = linspace(bbeta_shock_min, bbeta_shock_max, Nshocks);

horizon = 13;

r_vec = zeros(1, Nshocks);
irf_vec = zeros(Nshocks, horizon);
rr_vec = -ones(1,horizon);


for n=1:Nshocks
    
    var_betaV = bbeta_shocks(n);

    save('shock_value_mp.mat', 'var_betaV')
    
    try
        dynare Dyn_RIR_finder_beta;
        
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


save('beta_results.mat', 'r_vec', 'irf_vec', 'rr_vec')

set(groot, 'defaultTextInterpreter', 'Latex')

figure(1)
scatter(100*r_vec, 100*irf_vec(:,1), '.')
xlabel('Policy rate (pts)')
ylabel('Investment response to 10bp monetary shock (\%)', 'Interpreter', 'Latex')
title('Discount factor shocks')
saveas(gcf, 'reversal_irf_beta.png', 'png')
saveas(gcf, 'reversal_irf_beta', 'epsc')
