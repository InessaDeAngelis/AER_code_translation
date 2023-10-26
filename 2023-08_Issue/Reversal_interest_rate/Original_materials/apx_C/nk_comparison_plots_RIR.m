% Figures comparing benchmark model IRFs to modified "frictionless" model
% IRFs (no bank frictions) in Appendix C

% Run benchmark and frictionless model to generate IRFs
clear

dynare Dyn_RIR_benchmark

clear

dynare Dyn_RIR_NK


clear

% Load IRFs
load('irfs_RIR.mat')
load('irfs_NK.mat')

% Formatting
co = [       ...
    0    0.4470    0.7410 ;
    0.8500    0.3250    0.0980 ;
    0.4660    0.6740    0.1880 ;
    0.4940    0.1840    0.5560 ;
    0.9290    0.6940    0.1250 ;
    0.3010    0.7450    0.9330 ;
    0.6350    0.0780    0.1840] ; 
set(groot,'defaultAxesColorOrder',co)

% Figures
figure(1)
subplot(2,3,1)
plot(0:20, 100*(Rn_bench(1:21).^4-Rn_bench(1).^4))
hold on
plot(0:20, 100*(Rn_NK(1:21).^4-Rn_NK(1).^4), '--')
xlabel('$i$', 'interpreter', 'Latex')
legend('Benchmark','Frictionless')

subplot(2,3,2)
plot(0:20, 100*(Pi_bench(1:21).^4-Pi_bench(1).^4))
hold on
plot(0:20, 100*(Pi_NK(1:21).^4-Pi_NK(1).^4), '--')
xlabel('$\pi$', 'interpreter', 'Latex')
legend('Benchmark', 'Frictionless')

subplot(2,3,3)
plot(0:20, 100*(log(Y_bench(1:21))-log(Y_bench(1))))
hold on
plot(0:20, 100*(log(Y_NK(1:21))-log(Y_NK(1))), '--')
xlabel('$Y$', 'interpreter', 'Latex')
legend('Benchmark', 'Frictionless')

subplot(2,3,4)
plot(0:20, 100*(log(C_bench(1:21))-log(C_bench(1))))
hold on
plot(0:20, 100*(log(C_NK(1:21))-log(C_NK(1))), '--')
xlabel('$C$', 'interpreter', 'Latex')
legend('Benchmark', 'Frictionless')

subplot(2,3,5)
plot(0:20, 100*(log(Invest_bench(1:21))-log(Invest_bench(1))))
hold on
plot(0:20, 100*(log(Invest_NK(1:21))-log(Invest_NK(1))), '--')
xlabel('$I$', 'interpreter', 'Latex')
legend('Benchmark', 'Frictionless')

subplot(2,3,6)
plot(0:20, 100*(log(L_bench(1:21))-log(L_bench(1))))
hold on
plot(0:20, 100*(log(L_NK(1:21))-log(L_NK(1))), '--')
xlabel('$H$', 'interpreter', 'Latex')
legend('Benchmark', 'Frictionless')

saveas(gcf, 'nk_comparison.png', 'png')
saveas(gcf, 'nk_comparison', 'epsc')


