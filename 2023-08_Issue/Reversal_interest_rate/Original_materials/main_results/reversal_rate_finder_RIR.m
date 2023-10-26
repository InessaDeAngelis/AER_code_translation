clear

% Set vector of Taylor rule innovations
Nshocks = 100; 
cut_min = 0.00; 
cut_max = 0.02;
mp_cuts = linspace(cut_min, cut_max, Nshocks); 

horizon = 13; % Horizon of IRF

% Arrays to store interest rate + IRFs
r_vec = zeros(1, Nshocks);
irf_vec = zeros(Nshocks, horizon);
rr_vec = -ones(1,horizon);

irf_vec_L = zeros(Nshocks, horizon);
rr_vec_L = -ones(1, horizon);

for n=1:Nshocks
    
    % Set current shock
    var_epsV = mp_cuts(n);
    var_betaV = 0.00;
    
    % Save for use in Dynare file on next run
    save('shock_value_mp.mat', 'var_epsV')
    
    try
        dynare Dyn_RIR_finder
        
        % Initial interest rate
        r_vec(n) = Rn_0(2)^4 - 1;
        
        for t=1:horizon
            % Marginal responses to interest rate cut
            irf_vec(n,t) = log(Invest_1(t+1)) - log(Invest_0(t+1));
            irf_vec_L(n,t) = log(Lo_1(t+1)) - log(Lo_0(t+1));
            
            % Set r = investment reversal rate if (1) marginal response to
            % cuts is negative, (2) r < previous reversal rate
            if Invest_1(t+1)<Invest_0(t+1)
                rr_vec(t) = max(r_vec(n), rr_vec(t));
            end
            
            % Same for bank lending reversal rate
            if Lo_1(t+1)<Lo_0(t+1)
                rr_vec_L(t) = max(r_vec(n), rr_vec_L(t));
            end
        end
        
    catch
        irf_vec(n) = NaN;
    end

end

save('reversal_rate.mat', 'r_vec', 'irf_vec', 'rr_vec')

figure(1)
scatter(100*r_vec, 100*irf_vec(:,1), '.')
xlabel('Policy rate (pts)')
ylabel('Response of investment to 10bp monetary shock (%)')
saveas(gcf, 'rr_investment.png', 'png')
saveas(gcf, 'rr_investment', 'epsc')

figure(2)
scatter(100*r_vec, 100*irf_vec_L(:,1), '.')
xlabel('Policy rate (pts)')
ylabel('Response of bank lending to 10bp monetary shock (%)')
saveas(gcf, 'rr_lending.png', 'png')
saveas(gcf, 'rr_lending', 'epsc')

