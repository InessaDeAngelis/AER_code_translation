% Figures for sensitivity analysis in Appendix C

clear

names_std_1 = ["aalphaV", "ddeltaV", "ggammaV", "hV", "psi_LV", "eps_PCV", "theta_PCV"];
xlabs_std_1 = ["$\alpha$", "$\delta$", "$\sigma$", "$h$", "$\psi_L$", "$\varepsilon$", "$\theta$"];

figure(1)

for n=1:length(names_std_1)
    load(names_std_1(n) + "0_rr_mpshock.mat")
    p_vec0 = p_vec;
    rr_vec0 = rr_vec;
    
    load(names_std_1(n) + "1_rr_mpshock.mat")
    p_vec1 = p_vec;
    rr_vec1 = rr_vec;
    
    p_vec = [p_vec0 p_vec1];
    rr_vec = [rr_vec0(:,2); rr_vec1(:,2)];
    
    k = n + 1*(n==length(names_std_1));
    subplot(3,3,k)
    scatter(p_vec, 100*rr_vec, 'k', 'filled')
    xlabel(xlabs_std_1(n), 'Interpreter', 'Latex');
    ylabel('%');
    ylim([-2.0 0.0])
end
sgtitle('Sensitivity to standard parameters')
saveas(gcf, 'sensitivity_standard1_apx.png', 'png')
saveas(gcf, 'sensitivity_standard1_apx', 'epsc')


names_std_2 = ["rho_RnV", "phi_piV", "phi_yV"];
xlabs_std_2 = ["$\rho^{mp}$", "$\phi^\pi$", "$\phi^y$"];
figure(2)
for n=1:length(names_std_2)
    load(names_std_2(n) + "0_rr_mpshock.mat")
    p_vec0 = p_vec;
    rr_vec0 = rr_vec;
    
    load(names_std_2(n) + "1_rr_mpshock.mat")
    p_vec1 = p_vec;
    rr_vec1 = rr_vec;
    
    p_vec = [p_vec0 p_vec1];
    rr_vec = [rr_vec0(:,2); rr_vec1(:,2)];
    
    subplot(3, 1, n)
    scatter(p_vec, 100*rr_vec, 'k', 'filled')
    xlabel(xlabs_std_2(n), 'Interpreter', 'Latex');
    ylabel('%');
    ylim([-2.0 0.0])
end
sgtitle('Sensitivity to monetary policy parameters')
saveas(gcf, 'sensitivity_standard2_apx.png', 'png')
saveas(gcf, 'sensitivity_standard2_apx', 'epsc')

names_calib = ["bbetaV", "nnuV", "xxiV", "ben_DV", "DGDP_ratioV", "Iss_to_AV"];
xlabs_calib = ["$\beta$", "$\nu$", "$\xi$", "$\mu^D$", "2014 Deposit/GDP ratio", "Issuance/Asset ratio"];

figure(3)
for n=1:length(names_calib)
    load(names_calib(n) + "0_rr_mpshock.mat")
    p_vec0 = p_vec;
    rr_vec0 = rr_vec;
    
    load(names_calib(n) + "1_rr_mpshock.mat")
    p_vec1 = p_vec;
    rr_vec1 = rr_vec;
    
    p_vec = [p_vec0 p_vec1];
    rr_vec = [rr_vec0(:,2); rr_vec1(:,2)];
    
    subplot(2, 3, n)
    scatter(p_vec, 100*rr_vec, 'k', 'filled')
    xlabel(xlabs_calib(n), 'Interpreter', 'Latex');
    ylabel('%');
    ylim([-2.0 0.0])
end
sgtitle('Sensitivity to calibrated parameters')
saveas(gcf, 'sensitivity_calib_apx.png', 'png')
saveas(gcf, 'sensitivity_calib_apx', 'epsc')
