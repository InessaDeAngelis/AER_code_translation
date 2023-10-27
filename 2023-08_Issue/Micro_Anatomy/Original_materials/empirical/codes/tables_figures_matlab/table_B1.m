%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Guntin, Ottonello and Perez (2022)
% Code replicates Table B.1 BPP estimates for Italy and Peru
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

addpath('BPP/')

%% Italy

data = readtable('../../working_data/ITA/ITA_mom_BPP.csv');

% empirical moments

T = (max(data.year) - min(data.year) + 2)./2; % time lenght
N = length(data.id_HH)/T; % number of households
T1 = 2*T; % T1 lenght of matrix of income and consumption

x = zeros(T*N*2,4);

for i = 1:N  % order data
     x (2*T*(i-1)+1:2*T*i,:)        ...
     =  [[data.duc(T*(i-1)+1:T*i);data.duy(T*(i-1)+1:T*i)], [data.yduc(T*(i-1)+1:T*i);data.yduy(T*(i-1)+1:T*i)], ...
        [data.id_HH(T*(i-1)+1:T*i);data.id_HH(T*(i-1)+1:T*i)], [data.year(T*(i-1)+1:T*i);data.year(T*(i-1)+1:T*i)] ];
end

xx = zeros(T1,T1);
dd = zeros(T1,T1);

% moments

for i = 1:N  % compute xx'
    xx = xx + x(1+T1*(i-1):T1*i,1)*x(1+T1*(i-1):T1*i,1)';
    dd = dd + x(1+T1*(i-1):T1*i,2)*x(1+T1*(i-1):T1*i,2)';
end

cc = xx./dd;
vec_cc = vech(cc);

% variance and convariance matrix

vec_dd = vech(dd);

dim    =(T1*(T1+1))/2;
omega = zeros(dim,dim);

for i = 1:N  % compute xx'
    x_aux = x(1+T1*(i-1):T1*i,1)*x(1+T1*(i-1):T1*i,1)';
    d_aux = x(1+T1*(i-1):T1*i,2)*x(1+T1*(i-1):T1*i,2)';
    vec_x_i = vech(x_aux);
    vec_d_i = vech(d_aux);
    omega = omega + ((vec_x_i - vec_cc)*(vec_x_i - vec_cc)').*(vec_d_i*vec_d_i');
end

omega=omega./(vec_dd*vec_dd');

clearvars -except cc vec_cc omega T

%%% BPP minimum distance estimation - constant

rho = 1; % BPP random walk = 1

% BPP initial guess estimate

param0 = zeros(2+T-4+T-2+1+1+8,1);
param0(1) = 0.11;
param0(2) = 0.0105;
param0(2+1:2+T-4) = 0.9;
param0(2+T-4+1:2+T-4+T-2) = 0.03;
param0(2+T-4+T-2+1) = .99;
param0(2+T-4+T-2+2) = 0;
param0(2+T-4+T-2+2+1:2+T-4+T-2+2+8) = 0.6;

f = @(param) min_dist_ITA(param,vec_cc,omega,T,rho);
param_BPP = fminsearch(f,param0);

for i =1:10
f = @(param) min_dist_ITA(param,vec_cc,omega,T,rho);
param_BPP = fminsearch(f,param_BPP);
end

% results 
phit_ITA = param_BPP(2+T-4+T-2+1); % permanent elasticity coefficient
psit_ITA = param_BPP(2+T-4+T-2+2); % temporary elasticity coefficient

clearvars -except phit_ITA psit_ITA

%% Peru

% load data
data = readtable('../../working_data/PER/PER_mom_BPP.csv');

% empirical moments

T = max(data.year) - min(data.year) + 1; % time lenght
N = length(data.id)/T; % number of households
T1 = 2*T; % T1 lenght of matrix of income and consumption excluding consumption no observation years

x = zeros(T*N*2,5);

for i = 1:N  % order data
     x (2*T*(i-1)+1:2*T*i,:)        ...
     =  [[data.duc(T*(i-1)+1:T*i);data.duy(T*(i-1)+1:T*i)], [data.yduc(T*(i-1)+1:T*i);data.yduy(T*(i-1)+1:T*i)], ...
        [data.id(T*(i-1)+1:T*i);data.id(T*(i-1)+1:T*i)], [data.year(T*(i-1)+1:T*i);data.year(T*(i-1)+1:T*i)] ...
        [data.ndrod(T*(i-1)+1:T*i);zeros(T,1)]];
end

x(x(:, 5)== 1, :)= []; % remove no observation years of consumption moments

xx = zeros(T1,T1);
dd = zeros(T1,T1);

% moments

for i = 1:N  % compute xx'
    xx = xx + x(1+T1*(i-1):T1*i,1)*x(1+T1*(i-1):T1*i,1)';
    dd = dd + x(1+T1*(i-1):T1*i,2)*x(1+T1*(i-1):T1*i,2)';
end

cc = xx./dd;
vec_cc = vech(cc);

% variance and convariance matrix

vec_dd = vech(dd);

dim    =(T1*(T1+1))/2;
omega = zeros(dim,dim);

for i = 1:N  % compute xx'
    x_aux = x(1+T1*(i-1):T1*i,1)*x(1+T1*(i-1):T1*i,1)';
    d_aux = x(1+T1*(i-1):T1*i,2)*x(1+T1*(i-1):T1*i,2)';
    vec_x_i = vech(x_aux);
    vec_d_i = vech(d_aux);
    omega = omega + ((vec_x_i - vec_cc)*(vec_x_i - vec_cc)').*(vec_d_i*vec_d_i');
end

omega=omega./(vec_dd*vec_dd');

clearvars -except cc vec_cc omega T phit_ITA psit_ITA

%%% BPP minimum distance estimation - constant

rho = 1; % BPP random walk = 1

% BPP initial guess estimate

param0 = zeros(2+T-4+T-2+2+1+3,1);
param0(1) = 0.1132;
param0(2) = 0.0105;
param0(2+1:2+T-4) = 0.03;
param0(2+T-4+1:2+T-4+T-2) = 0.03;
param0(2+T-4+T-2+1) = .6;
param0(2+T-4+T-2+2) = 0;
param0(2+T-4+T-2+2+1:2+T-4+T-2+2+1+2) = 0.6;

f = @(param) min_dist_PER(param,vec_cc,omega,T,rho);
param_BPP = fminsearch(f,param0);

for i =1:10
f = @(param) min_dist_PER(param,vec_cc,omega,T,rho);
param_BPP = fminsearch(f,param_BPP);
end

% results time-varying

phit_PER = param_BPP(5); % permanent elasticity coefficient
psit_PER = param_BPP(6); % temporary elasticity coeffici

clearvars -except phit_PER psit_PER phit_ITA psit_ITA

%% Table B.1 - BPP coefficients

tab = fopen(fullfile('../../output/tableB1_b.tex'), 'w');
fprintf(tab, '﻿ & Persistent shocks & $\\phi$ & %8.2f  & %8.2f & %8.2f  \\\\ \n',0.642, phit_ITA, phit_PER);
fprintf(tab, '﻿ & Transitory shocks & $\\varphi$ & %8.2f  & %8.2f & %8.2f \\\\ \n',0.053, psit_ITA, psit_PER);
fclose(tab);

