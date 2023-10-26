%% HOW TO USE THIS FILE
% There are three blocks of parameters (household preferences, technology/New
% Keynesian, and bank parameters). Uncomment one block and run the file to
% generate the sensitivity analysis figures for the corresponding
% parameters. Then repeat for the other blocks of parameters.

%% DEFINE PARAMETER GRIDS
clear

Np = 5;

% Household preference parameters
% names = ["ggammaV", "ggammaV", "hV", "hV", "psi_LV", "psi_LV", "bbetaV", "bbetaV"]; 
% mins = [1.0, 1.0, 0.62, 0.62, 2.0, 2.0, 0.98^(1/4), 0.98^(1/4)];
% maxs = [1.5, 0.5, 0.8, 0.44, 3.0, 1.0, 0.99^(1/4), 0.97^(1/4)];

% Technology and New Keynesian parameters
% names = ["nnuV", "nnuV", "aalphaV", "aalphaV", "ddeltaV", "ddeltaV", "eps_PCV", "eps_PCV", "rho_RnV", "rho_RnV", "phi_piV", "phi_piV", "theta_PCV", "theta_PCV", "phi_yV", "phi_yV"];
% mins = [0.85, 0.85, 0.36, 0.36, 0.025, 0.025, 3.85, 3.85, 0.93, 0.93, 2.74, 2.74, 70.68, 70.68, 0.0, 0.0];
% maxs = [0.95, 0.75, 0.42, 0.30, 0.03, 0.02, 6.0, 2.0, 0.95, 0.6, 3.9, 1.5, 80.0, 60.0, 0.5, 0.5];

% Bank parameters
names = ["eps_DV", "eps_DV", "ben_DV", "ben_DV", "DGDP_ratioV", "DGDP_ratioV", "elast_investV", "elast_investV", "eps_LV", "eps_LV", "lvg_elasticityV", "lvg_elasticityV", "xxiV", "xxiV", "tau_SV", "tau_SV", "Y_bd_shV", "Y_bd_shV", "Iss_to_AV", "Iss_to_AV"];
mins = [-275, -275, 0.005/4, 0.005/4, 2.47/1.93, 2.47/1.93, 0.2, 0.2, 200, 200, 0.0007, 0.0007, 0.9, 0.9, 3.4*4, 3.4*4, 0.558, 0.558, 0.0025, 0.0025];
maxs = [-325, -225, 0.0075/4, 0.0025/4, 1.0, 1.5, 0.3, 0.1, 300, 100, 0.00105, 0.00035, 0.8, 0.998, 24.0, 3.0, 0.65, 0.45, 0.000, 0.005];


K = length(names);
horizon = 10;

%% LOOP OVER PARAMETERS

% Set vector of monetary shocks
Nshocks = 100;
cut_min = 0.00;
cut_max = 0.02;
mp_cuts = linspace(cut_min, cut_max, Nshocks);

initial_rate_vec = zeros(1, Nshocks);

% Find initial interest rate (in benchmark parametrization) for each
% monetary shock
parametrization;
for n=1:Nshocks
    
    var_epsV = mp_cuts(n);
    
    save('shock_value_mp.mat', 'var_epsV')
    

    count_runs = 0;
    count_errs = 0;
    while count_runs == count_errs
        try
            dynare Dyn_RIR_a_search;  
            initial_rate_vec(n) = Rn_0(2)^4-1;
        catch
            count_errs = count_errs + 1;
        end
        count_runs = count_runs + 1;
    end           
    
end

% Loop over parameters
for k=1:K
    pMin = mins(k);
    pMax = maxs(k);
    pName = names(k);
    
    p_vec = linspace(pMin, pMax, Np);
    rr_vec = -1 * ones(Np,horizon);
    
    % Loop over possible values of specific parameter
    for i=1:Np
        parametrization; % Initialize benchmark parametrization
        
        % Assign new value to parameter
        p = p_vec(i);
        assignin('base', pName, p);
        save('params_dynare.mat', pName);
        
        % Loop over monetary shocks
        for n=1:Nshocks
            var_epsV = mp_cuts(n);

            save('shock_value_mp.mat', 'var_epsV')
            

            % Block that computes reversal rate given value of parameter
            % try

            count_runs = 0;
            count_errs = 0;
            while count_runs == count_errs
                try
                    dynare Dyn_RIR_a_search;  
                    
                    if i==1
                        initial_rate_vec(n) = Rn_0(2)^4-1;
                    end
                    
                    for t=1:horizon
                          if Invest_1(t) < Invest_0(t)
                              rr_vec(i,t) = max(Rn_0(2)^4-1, rr_vec(i,t));
                          end
                    end
                catch
                    count_errs = count_errs + 1;
                end
                count_runs = count_runs + 1;
            end
                
            % catch
            %     for t=1:horizon
            %         rr_vec(i,t) = NaN;
            %     end
            % end
         end


    end
    
    % Save values of reversal rate for current parameter
    save(strcat(pName, num2str(mod(k+1,2)), '_rr_mpshock.mat'), 'p_vec', 'rr_vec')
end