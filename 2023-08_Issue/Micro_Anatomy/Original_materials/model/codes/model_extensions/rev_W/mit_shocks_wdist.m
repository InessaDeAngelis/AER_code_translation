%% MIT shocks

% recover policy functions for t = 0,...,T
% dimensions of each matrix are (a x mu) rows x T+1 columns

% -> permanent one time shock = kappa constant + one time shock of income
 
par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)
       par.Y_mat(hh) = par.Y_mat(hh-1).*exp(-drop*pers_perm^(hh-2));
end
par.kappa_mat = par.kappa.*ones(40,1); % remains unchanged

[c_PI,ap_PI,y_PI,a_PI] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_PI = par.Y_mat;

% -> temporary double shock = kappa drop and increase + path of income down
% and recover

nu = 11; % adjusted to match average elasticity in new exercise
drop = drop/pers_temp;

par.Y_mat = zeros(40,1);
par.Y_mat(1) = par.Y;
for hh = 2:length(par.Y_mat)-1
       par.Y_mat(hh) = par.Y.*exp(-drop*pers_temp^(hh-1));
end
par.Y_mat(end) = par.Y;
par.kappa_mat = par.kappa.*par.Y_mat.^nu; % kappa drops and recovers

[c_FF,ap_FF,y_FF,a_FF] = policy_shock(par,Grid,s,s_a,s_mu,n_a,n_mu,length(s),maxiter,tol);
Y_mat_FF = par.Y_mat;


%% using policy functions

% policy functions
c_PI_1 = reshape(c_PI(:,1),[n_a n_mu]);
c_PI_2 = reshape(c_PI(:,2),[n_a n_mu]);

c_FF_1 = reshape(c_FF(:,1),[n_a n_mu]);
c_FF_2 = reshape(c_FF(:,2),[n_a n_mu]);

% initial asset positions using observed wealth distribution

assets_income = (s_a'*dist)'./nmu; % steady state assets
assets_relative = assets_income./sum(assets_income.*nmu);
income_dist_position = cumsum(nmu);
income_dist_position(9:9+13);       % used percentiles for data

data_liqW_ITA = readtable('../../../input/liqwealth_ITA.xls');
ratio_liq = data_liqW_ITA.ratio_liq;

liqassets_income_observed            = assets_income;
liqassets_income_observed(8:8+14)    = exp(s_mu(8:8+14)).*ratio_liq;                  % observed liq asset distribution across income
liqassets_income_observed(1:7)       = liqassets_income_observed(8).*ones(7,1);
liqassets_income_observed(23:end)    = liqassets_income_observed(22).*ones(n_mu-22,1);

% wealth revaluation using observed drop in asset prices and wealth holdingx

data_ITA = readtable('../../../input/data_ITA.xls');
reval_wealth = - data_ITA.ch_y;

nmu_cum = cumsum(nmu);
reval_wealth_i = interp1(0.05:.1:.95,reval_wealth,nmu_cum,'linear','extrap'); % interpolate on the grid
reval_wealth_i(1:7)       = reval_wealth_i(8).*ones(7,1);
reval_wealth_i(23:end)    = reval_wealth_i(22).*ones(n_mu-22,1);

drop_asset = zeros(length(s_mu),1); % measured relative to their income

for i=1:length(s_mu)
drop_asset(i,1)  = Y_mat_PI(1).*exp(s_mu(i)).*reval_wealth_i(i);
end

assets_income_observed_crisis = liqassets_income_observed - drop_asset;  % change of asset value in terms of income

% compute elasticities using observed initial asset position and drop of asset value

A=length(na);
elast_PI_distliq_reval = zeros(10,1);
elast_FF_distliq_reval = zeros(10,1);

for i = 1:length(liqassets_income_observed)
    
[~,a_p1] = min(abs(liqassets_income_observed(i)*ones(A,1)-s_a));
[~,a_p2] = min(abs(assets_income_observed_crisis(i)*ones(A,1)-s_a));

elast_PI_distliq_reval(i,1) = (log(c_PI_2(a_p2,i)) - log(c_PI_1(a_p1,i)))./(log(Y_mat_PI(2))-log(Y_mat_PI(1)));
elast_FF_distliq_reval(i,1) = (log(c_FF_2(a_p2,i)) - log(c_FF_1(a_p1,i)))./(log(Y_mat_FF(2))-log(Y_mat_FF(1)));

end


