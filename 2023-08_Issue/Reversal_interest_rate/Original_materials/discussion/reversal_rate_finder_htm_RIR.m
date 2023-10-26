% Calculate reversal rate for model extension in Appendix where some bonds
% are "held-to-maturity". Parameter S_H is the quantity of held-to-maturity
% bonds.

clear

% Vector of monetary shocks
Nshocks = 100;
cut_min = 0.00;
cut_max = 0.02;
mp_cuts = linspace(cut_min, cut_max, Nshocks);

% IRF horizon
horizon = 13;

S_bar = 1.34928; % Steady-state bonds on bank balance sheet

% S_H = quantity of bonds held-to-maturity (ranges from 0% to 50% of
% steady-state holdings)
S_H_min = 0.0; 
S_H_max = 0.5 * S_bar;
N_S_H = 10;
S_H_vec = linspace(S_H_min, S_H_max, N_S_H);

r_vec = zeros(1, Nshocks); 
rr_vec = -ones(N_S_H,horizon); % Reversal rate vector

rr_vec_L = -ones(N_S_H, horizon);


for m=1:N_S_H
    var_SH = S_H_vec(m); % Value of S_H to be saved in dynare file
    
    
    for n=1:Nshocks
        var_epsV = mp_cuts(n);


        save('shock_value_htm.mat', 'var_epsV', 'var_SH')

        try
            dynare Dyn_RIR_htm;

            r_vec(n) = Rn_0(2)^4 - 1;
            

            for t=1:horizon
                % Investment reversal rate
                if Invest_1(t+1)<Invest_0(t+1)
                    rr_vec(m,t) = max(r_vec(n), rr_vec(m,t));
                end
                
                % Bank lending reversal rate
                if Lo_1(t+1)<Lo_0(t+1)
                    rr_vec_L(m,t) = max(r_vec(n), rr_vec_L(m,t));
                end
            end
            
            
        catch
            
        end
    end

end

save('htm_results.mat', 'r_vec', 'rr_vec', 'rr_vec_L')

figure(1)
scatter(S_H_vec/S_bar, 100*rr_vec(:,1), 'k', 'filled')
xlabel('$\phi$', "Interpreter", "Latex");
ylabel('Investment reversal rate (%)');
ylim([-2.0 0.0])
saveas(gcf, 'rr_htm_investment.png', 'png')
saveas(gcf, 'rr_htm_investment', 'epsc')

figure(2)
scatter(S_H_vec/S_bar, 100*rr_vec_L(:,1), 'k', 'filled')
xlabel('$\phi$', "Interpreter", "Latex");
ylabel('Bank lending reversal rate (%)');
ylim([-2.0 0.0])
saveas(gcf, 'rr_htm_lending.png', 'png')
saveas(gcf, 'rr_htm_lending', 'epsc')

