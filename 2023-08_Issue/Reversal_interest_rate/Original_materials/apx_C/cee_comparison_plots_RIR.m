% Figures comparing benchmark model IRFs to CEE IRFs (in Appendix C).
% Similar to nk_comparison_plots_RIR.m.

clear

dynare Dyn_RIR_NK

clear

dynare Dyn_RIR_CEE

clear

load('irfs_NK.mat')
load('irfs_CEE.mat')

figure(1)
subplot(2,3,1)
plot(0:20, 100*(Rn_NK(1:21).^4-Rn_NK(1).^4))
hold on
plot(0:20, 100*(Rn_CEE(1:21).^4-Rn_CEE(1).^4), '--')
xlabel('$i$', 'interpreter', 'Latex')
legend('Benchmark','CEE')

subplot(2,3,2)
plot(0:20, 100*(Pi_NK(1:21).^4-Pi_NK(1).^4))
hold on
plot(0:20, 100*(Pi_CEE(1:21).^4-Pi_CEE(1).^4), '--')
xlabel('$\pi$', 'interpreter', 'Latex')
legend('Benchmark', 'CEE')

subplot(2,3,3)
plot(0:20, 100*(log(Y_NK(1:21))-log(Y_NK(1))))
hold on
plot(0:20, 100*(log(Y_CEE(1:21))-log(Y_CEE(1))), '--')
xlabel('$Y$', 'interpreter', 'Latex')
legend('Benchmark', 'CEE')

subplot(2,3,4)
plot(0:20, 100*(log(C_NK(1:21))-log(C_NK(1))))
hold on
plot(0:20, 100*(log(C_CEE(1:21))-log(C_CEE(1))), '--')
xlabel('$C$', 'interpreter', 'Latex')
legend('Benchmark', 'CEE')

subplot(2,3,5)
plot(0:20, 100*(log(Invest_NK(1:21))-log(Invest_NK(1))))
hold on
plot(0:20, 100*(log(Invest_CEE(1:21))-log(Invest_CEE(1))), '--')
xlabel('$I$', 'interpreter', 'Latex')
legend('Benchmark', 'CEE')

subplot(2,3,6)
plot(0:20, 100*(log(L_NK(1:21))-log(L_NK(1))))
hold on
plot(0:20, 100*(log(L_CEE(1:21))-log(L_CEE(1))), '--')
xlabel('$H$', 'interpreter', 'Latex')
legend('Benchmark', 'CEE')

saveas(gcf, 'cee_comparison.png', 'png')
saveas(gcf, 'cee_comparison', 'epsc')
