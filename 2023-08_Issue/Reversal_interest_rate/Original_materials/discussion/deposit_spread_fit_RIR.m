% Code to produce deposit spread figure in Appendix

clear

data = readtable('overnight_deposits_master.csv');

dates = data.date;
actual_deposit = data.EuroArea; % Euro area average deposit rate
actual_rate = data.EONIA; % EONIA rate
actual_spread = actual_rate - actual_deposit; % Spread in data

model_spread = data.ModelSpread; % Model-predicted spread based on EONIA rate
model_rate = data.ModelRate; % Model-predicted rate

ben_D = 0.005; % Non-pecuniary benefit of issuing deposits in model (annualized)

% Function to compute distance between modified model-predicted deposit rate and actual deposit rate
distfun = @(sp_D) sum((max(sp_D*(actual_rate + ben_D), 0) - actual_deposit).^2, 'omitnan');

% Find best-fit pass-through parameter sp_D
sp_D = fmincon(distfun, 0.5, [], [], [], [], 0, 1);

% Modified model-predicted rate and spread
modified_rate = max(sp_D*(actual_rate + ben_D), 0);
modified_spread = actual_rate - modified_rate;

figure(1)
plot(datetime(dates), actual_spread, 'k--')
hold on
plot(datetime(dates), model_spread)
plot(datetime(dates), modified_spread)
legend('Data', 'Model', 'Modified model')
title('Deposit spreads: Model and data (time series)')
xlabel('Year')
ylabel('Avg deposit spread: Euro area (pts)')
saveas(gcf, 'deposit_spread_ts.png', 'png')
saveas(gcf, 'deposit_spread_ts', 'epsc')
