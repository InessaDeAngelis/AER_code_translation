% Figures for sensitivity analysis in Section IV as well as some figures
% that have now been relegated to Appendix C

clear

% Only "lvg_elasticityV" and "Y_bd_shV" are in the final version of the
% paper. Results for the other four parameters are reported in Online
% Appendix C.2.
names_statics = ["lvg_elasticityV", "tau_SV", "eps_LV", "eps_DV", "elast_investV", "Y_bd_shV"];
xlabs_statics = ["Response of loan rate to 25bp capitalization target increase (bp)", "Bond maturity $\tau$ (quarters)", "Loan demand elasticity $\varepsilon^L$", "Deposit demand elasticity $| \varepsilon^D |$", "Elasticity of investment to Q", "Bank-dependent share of output"];

for n=1:length(names_statics)
    
    figure(n)
    load(names_statics(n) + "0_rr_mpshock.mat")
    p_vec0 = p_vec;
    rr_vec0 = rr_vec;
    
    load(names_statics(n) + "1_rr_mpshock.mat")
    p_vec1 = p_vec;
    rr_vec1 = rr_vec;
    
    p_vec = [p_vec0 p_vec1];
    rr_vec = [rr_vec0(:,2); rr_vec1(:,2)];
    
    if names_statics(n) == "lvg_elasticityV"
       p_vec = p_vec * 10000; 
    end
    
    if names_statics(n) == "eps_DV"
        p_vec = -p_vec;
    end
    
    scatter(p_vec(rr_vec>-100), 100*rr_vec(rr_vec>-100), 'k', 'filled')
    xlabel(xlabs_statics(n), "Interpreter", "Latex");
    ylabel('Reversal rate (%)');
    ylim([-2.0 0.0])
    
    saveas(gcf, 'sensitivity_' + names_statics(n) + '.png', 'png')
    saveas(gcf, 'sensitivity_' + names_statics(n), 'epsc')
end