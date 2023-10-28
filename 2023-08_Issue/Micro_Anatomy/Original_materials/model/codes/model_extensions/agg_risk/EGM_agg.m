% Guntin, Ottonello and Perez (2022) 
% Code solves the model with aggregate risk and computes elasticities during crisis episode for PI-view

% output: 
% Figure D.10;

clear all
close all
clc

%% directories

dir_fig = '../../../output';

%% parameters

% -> common parameters

% preferences and interest rate
par.alpha_g = .007;
par.beta = .953;
par.sigma = 2;      % CRRA
par.r_star = 0.007;

% -> PI model - parameters

% aggregate shocks
par.rho_z = .95;
par.sig_z = .0031;
par.rho_g = .08;
par.sig_g = .0161;

% distribution of PI
par.rho_mu = 0.88;
par.sig_mu = 0.258;

save('../../../input/parameters_agg','par')

%% solve PI model and plot C elasticities

run PI_solve.m

elast_PIH_agg = elast_PI_st;


%% plots

ftsize = 13;
set(groot, 'DefaultAxesTickLabelInterpreter','latex'); 
set(groot, 'DefaultLegendInterpreter','latex');
set(groot, 'DefaultAxesFontSize',ftsize);

run plots_agg.m
