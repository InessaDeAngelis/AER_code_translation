% Find reversal rate in extended model with modified deposit spread in
% Appendix. Similar code to main reversal_rate_finder_RIR.m.

clear

Nshocks = 100;
cut_min = 0.00;
cut_max = 0.015;
mp_cuts = linspace(cut_min, cut_max, Nshocks);

horizon = 13;

r_vec = zeros(1, Nshocks);
irf_vec = zeros(Nshocks, horizon);
rr_vec = -ones(1,horizon);

irf_vec_L = zeros(Nshocks, horizon);
rr_vec_L = -ones(1, horizon);

nii_vec = zeros(1, Nshocks);

for n=1:Nshocks
    var_epsV = mp_cuts(n);
    
    
    save('shock_value_deposits.mat', 'var_epsV')
    
    try
        dynare Dyn_RIR_deposits;
        
        r_vec(n) = Rn_0(2)^4 - 1;
        
        for t=1:horizon
            irf_vec(n,t) = log(Invest_1(t+1)) - log(Invest_0(t+1));
            irf_vec_L(n,t) = log(Lo_1(t+1)) - log(Lo_0(t+1));
            
            if Invest_1(t+1)<Invest_0(t+1)
                rr_vec(t) = max(r_vec(n), rr_vec(t));
            end
            
            if Lo_1(t+1)<Lo_0(t+1)
                rr_vec_L(t) = max(r_vec(n), rr_vec_L(t));
            end
        end
        
    catch
        irf_vec(n) = NaN;
    end

end

save('deposit_results.mat', 'r_vec', 'irf_vec', 'rr_vec')


figure(1)
scatter(100*r_vec, 100*irf_vec(:,1), '.')
xlabel('Policy rate (pts)')
ylabel('Response of investment to 10bp monetary shock (%)')
saveas(gcf, 'reversal_rate_deposits.png', 'png')


figure(2)
scatter(100*r_vec, 100*irf_vec_L(:,1), '.')
xlabel('Policy rate (pts)')
ylabel('Response of bank lending to 10bp monetary shock (%)')
saveas(gcf, 'reversal_rate_L_deposits.png', 'png')


