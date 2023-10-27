% Guntin, Ottonello and Perez (2022) 
% This runs all the Matlab codes for the empirical tables and figures in the paper

clear all
close all
clc

cd /Users/rafaelguntin/Dropbox/papers/GuOP_consumption/replication_files_revision % change this line to run the code

addpath(genpath('model/input/Compecon_64')) % adds path for Compecon
cd empirical/codes/                         % redirect to codes for codes in empirical

tic

% Figure 1
run tables_figures_matlab/figure_1.m

% Table A.1 - BPP partial insurance coefficients for Italy and Peru
run tables_figures_matlab/table_B1.m

toc