%%% Code: run_all_files.m
%%% Description: main script for "PROFITS, SCALE ECONOMIES, & THE GAINS FROM TRADE & INDUSTRIAL POLICY"
%%% Last update: August 9, 2023

clc
clear all
close all

% save path to main file here
cd '~/Dropbox/LL2020/Replication_Aug_2023/Matlab'


%  create folders to save output if needed
if ~exist('./output', 'dir')
    mkdir('./output')
end
if ~exist('./output/temp', 'dir')
    mkdir('./output/temp')
end
if ~exist('./input/temp', 'dir')
    mkdir('./input/temp')
end

% add sub-folders to search path
addpath('./code')
addpath('./code/auxiliary') % path to auxiliary files and functions
addpath('./input') % path to aggregate matrixes
addpath('./input/temp') % path to temp ouput from earlier scripts
addpath('./input/WIOD') % path to WIOD data

tic
%% ~~~~~~~~~~~~~~~~~~~~~~~~~
%         Main Text
%%~~~~~~~~~~~~~~~~~~~~~~~~~~

% ------- Section 4 ---------
% runtime: ~ 1 minute
figure_1; % creates Figure 1
table_2; % creates Table 2


% ------- Section 7 ----------
% runtime: ~ 3 hours and 30 minutes
table_4; % creates Table 4
table_5; % creates Table 5
figure_2; % creates the data points for Figure 2 (produced later in stata)
figure_3; % creates the data points for Figure 3 (produced later in stata)


%% ~~~~~~~~~~~~~~~~~~~~~~~~~
%      Online Appendix
%%~~~~~~~~~~~~~~~~~~~~~~~~~~

% ------- Appendix E ---------
% runtime: ~1 minute
figure_E1; % creates Figure E.1

% ------- Appendix H ---------
% runtime: ~3 hours and 15 minutes
appendix_H; % simulate data for Figures H1-H3 (to be generated in Stata)

% ------- Appendix V ---------
% runtime ~ 15 minutes
table_V1; % creates Table V.1

% ------- Appendix W ---------
% runtime ~ 25 minutes
appendix_W; % creates data poinst for Figures W1-W2 (to be generated in Stata)

% ------- Appendix X ---------
% runtime ~ 1 minute
figure_X1; % creates Figure X.1

% ------- Appendix Y ---------
% runtime ~ 10 minutes
appendix_Y; % creates data poinst for Figures Y1-Y3 (to be generated in Stata)

% ------- Appendix Z ---------
% runtime ~ 1 minute
figure_Z1; % creates Figure Z.1

%---- delete temp files ------
if exist('input/temp/Step_1.mat', 'file')
    delete('input/temp/Step_1.mat')
end

toc