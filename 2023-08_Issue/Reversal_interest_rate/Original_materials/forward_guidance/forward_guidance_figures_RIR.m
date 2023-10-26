% Produce main forward guidance figures in paper and Appendix

% Formatting
clear

lw = 1.5;
set(0,'defaultLineLineWidth',lw);
set(groot, 'defaultTextInterpreter', 'Latex')

co = [       ...
    0    0.4470    0.7410 ;
    0.8500    0.3250    0.0980 ;
    0.4660    0.6740    0.1880 ;
    0.4940    0.1840    0.5560 ;
    0.9290    0.6940    0.1250 ;
    0.3010    0.7450    0.9330 ;
    0.6350    0.0780    0.1840] ; 
set(groot,'defaultAxesColorOrder',co)

% Load forward guidance IRFs from Dynare runs
% Benchmark model
dynare Dyn_RIR_fg
load('fg_RIR.mat', 'Lo_7_10g', 'Invest_7_10g', 'Y_7_10g', 'Pi_7_10g', 'C_7_10g')

% Modified model without bank frictions
dynare Dyn_RIR_fg_NK
load('fg_NK.mat', 'Lo_7_NK', 'Invest_7_NK', 'Y_7_NK', 'Pi_7_NK', 'C_7_NK')


% Main figures in paper
figure(1)
plot(0:20, log(Invest_7_10g(2:22))-log(Invest_7_10g(1)))
hold on
plot(0:20, log(Invest_7_NK(2:22))-log(Invest_7_NK(1)), '--')
title('Investment Response to Forward Guidance')
xlabel('Time')
ylabel('$\Delta \log(I_t)$')
legend('Benchmark calibration', 'No net worth frictions')
saveas(gcf, 'fg_8quarter.png', 'png')
saveas(gcf, 'fg_8quarter', 'epsc')

figure(2)
plot(0:20, log(Y_7_10g(2:22))-log(Y_7_10g(1)))
hold on
plot(0:20, log(Y_7_NK(2:22))-log(Y_7_NK(1)), '--')
title('Output Response to Forward Guidance')
xlabel('Time')
ylabel('$\Delta \log(Y_t)$')
legend('Benchmark calibration', 'No net worth frictions')
saveas(gcf, 'fg_8quarter_Y.png', 'png')
saveas(gcf, 'fg_8quarter_Y', 'epsc')

% Figures in Appendix
figure(3)
plot(0:20, log(Lo_7_10g(2:22))-log(Lo_7_10g(1)))
hold on
plot(0:20, log(Lo_7_NK(2:22))-log(Lo_7_NK(1)), '--')
title('Bank Lending Response to Forward Guidance')
xlabel('Time')
ylabel('$\Delta \log(L_t)$')
legend('Benchmark calibration', 'No net worth frictions')
saveas(gcf, 'fg_8quarter_L.png', 'png')
saveas(gcf, 'fg_8quarter_L', 'epsc')

figure(4)
plot(0:20, log(Pi_7_10g(2:22))-log(Pi_7_10g(1)))
hold on
plot(0:20, log(Pi_7_NK(2:22))-log(Pi_7_NK(1)), '--')
title('Inflation Response to Forward Guidance')
xlabel('Time')
ylabel('$\Delta \pi_t$')
legend('Benchmark calibration', 'No net worth frictions')
saveas(gcf, 'fg_8quarter_Pi.png', 'png')
saveas(gcf, 'fg_8quarter_Pi', 'epsc')

figure(5)
plot(0:20, log(C_7_10g(2:22))-log(C_7_10g(1)))
hold on
plot(0:20, log(C_7_NK(2:22))-log(C_7_NK(1)), '--')
title('Consumption Response to Forward Guidance')
xlabel('Time')
ylabel('$\Delta \log(C_t)$')
legend('Benchmark calibration', 'No net worth frictions')
saveas(gcf, 'fg_8quarter_C.png', 'png')
saveas(gcf, 'fg_8quarter_C', 'epsc')

