% Guntin, Ottonello and Perez (2022) 
% This runs all the Matlab codes for the model exercises in the paper

clear all
close all
clc

cd /Users/rafaelguntin/Dropbox/papers/GuOP_consumption/replication_files_revision % change this line to run the code

addpath(genpath('model/input/Compecon_64')) % adds path for Compecon
cd model/codes/                             % redirect to codes for codes in model

tic

%% baseline ITA

% 1 - baseline exercise

run model_baseline/baseline/EGM_baseline.m 
% output: 
% Table 3; 
% Table 4; 
% Figure 5 and Figure 7 panel (a); 
% Figure 7 panel (b) and Figure D.15 panel (a);
% Figure D.2 panel (a) and (b);
% Figure D.8 panel (a) and (b);


% 2 - identification rhog and nu

run model_baseline/identification/EGM_id.m 
% output/
% Figure D1 panel (a) and (b); 

run model_baseline/identification/EGM_mixed.m 
% output/
% Figure D16; 


%% extensions ITA

% 3 - alternative exercises PI-view and CT-view

% income heterogeneity
run model_extensions/het_Y/EGM_Yhet.m           
% output/
% Figure 5 panel (b); 
% Figure D12 panel (b);
% Figure D15 panel (b);

% wealth revaluation
run model_extensions/rev_W/EGM_rev.m
% output/
% Figure 5 panel (c);

run model_extensions/rev_W/EGM_wdist.m
% output/
% Figure D.4 panel (a) and (b);
% Figure D.15 panel (c);

% uncertainty shock
run model_extensions/uncertainty/EGM_unc.m   % homogeneous shock
run model_extensions/uncertainty/EGM_hun.m   % heterogeneous
% output:
% Figure 5 (d);
% Figure D.13 (b);
% Figure D.15 (d);

% income collateral constraint
run model_extensions/y_collateral/EGM_yc.m  
% output/
% Figure D17 panel (a) and (b);

% 5 - other extensions PI-view

% non-homotheticities
run model_extensions/non_h/EGM_nonh.m 
% output/
% Figure 6 panel (a); 
% Figure D14 panel (a);

% protracted crisis
run model_extensions/simulated/EGM_simul.m 
% output/
% Figure D.9;

% aggregate risk model
run model_extensions/agg_risk/EGM_agg.m
% output/
% Figure D.10;

run model_extensions/closed/EGM_closed.m
% output/
% Figure D.11 panel (a) and (b);

%% transfer policy

% 6 - transfer policy with different progressivity for ITA calibration

run policy/EGM_policy.m 
% output/
% Figure 8; 
% Table D.2;
% Figure D.18 panel (a) and (b);

%% MEX

% 7 - Mexico: calibration and exercises

run model_mex/baseline/EGM_mex.m        
% output/
% Table D.3;
% Table D.4;
 
run model_mex/nonh/EGM_mex_nonh.m
% output/
% Figure D14 panel (b);
% Figure 6 panel (b);

run model_mex/r_shock/EGM_mex_rshock.m
% output/
% Figure D.7 panel (a);

run model_mex/r_shock_nonh/EGM_mex_rshock_nonh.m  % non-h + r shock
% output/
% Figure D.7 panel (b);

toc
