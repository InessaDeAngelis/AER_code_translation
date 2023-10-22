# -*- coding: utf-8 -*-
"""
Created on Sat Aug  1 15:21:31 2020

@author: Zarek Brot-Goldberg
"""

#import packages
import pandas as pd
import numpy as np
from scipy.special import roots_hermite as hg
from scipy.special import eval_hermite as hermite
from scipy.stats import norm
from scipy.optimize import minimize
from numpy import dot,sqrt,pi,log,sum,mean,exp,var
import matplotlib as plt
import random

#di = 'C:\\Users\\Zarek\\Dropbox\\Projects\\Part D Behavioral\\Final_Results\\Exit\\'

#Read in data. Each row is a cell. The first five columns are binary switches for the demographic represented by the cell:
#-Prior active vs. non-active chooser (`type_actv')
#-Female vs. male (`female')
#-Age >=75 vs. age < 75 (`age_75plus')
#-White vs. non-white (`race_white')
#-Above- vs. below-median Elixhauser comorbidity index (`elix_above_med')
#The sixth column is a variable called `cnt' which gives the number of beneficiaries in that cell
#The final column is a variable called `switch_actv' which says what share of those beneficiaries made an active choice after their plan exited
raw_data = pd.read_csv(di + 'exit_cells_benchmark_broad.csv')

#Define groups as tuples of the demographics
raw_data['group'] = raw_data.age_75plus.astype(str) + raw_data.race_white.astype(str) + raw_data.female.astype(str) + raw_data.elix_above_med.astype(str)

#Define within-demographic cell means of choice sequences (active vs. passive in initial choice, active vs. passive in post-exit choice)
new_data = pd.DataFrame(data = raw_data[0:16]['group'])
new_data['cnt_nonchoosers'] = raw_data[0:16]['cnt']
new_data['choice_nonchoosers'] = raw_data[0:16]['switch_actv']
new_data['cnt_choosers'] = (raw_data[16:32]['cnt'].reset_index())['cnt']
new_data['choice_choosers'] = (raw_data[16:32]['switch_actv'].reset_index())['switch_actv']
new_data['00'] = new_data['cnt_nonchoosers'] * (1 - new_data['choice_nonchoosers'])
new_data['01'] = new_data['cnt_nonchoosers'] * new_data['choice_nonchoosers']
new_data['10'] = new_data['cnt_choosers'] * (1 - new_data['choice_choosers'])
new_data['11'] = new_data['cnt_choosers'] * new_data['choice_choosers']

#Define log-likelihood function.
def likelihood(params,data,hg_nodes,hg_weights):
    cell_means = params[0:len(params)-1]
    sigma = exp(params[len(params)-1])
    
    likelihood_vals = np.zeros_like(data)
    
    for i in range(len(params)-1):
        use_cell_mean = cell_means[i]
        #For each demographic cell, compute probability of each choice sequence
        #Since this involves integrating over the normal CDF, we approximate using Gauss-Hermite quadrature.
        
        #For each node (i.e., a simulated draw of c, the beneficiary-specific decision cost), we compute the probability of each choice sequence
        pc_at_nodes = 1 - norm.cdf(-use_cell_mean - (sqrt(2) * sigma * hg_nodes))
        
        #We then take the weighted average of choice sequence probabilities across simulated draws, weighted with the Gauss-Hermite weights (see Appendix E)
        likelihood_vals[i,0] = sum((1-pc_at_nodes)* (1-pc_at_nodes) * hg_weights) / sqrt(pi)
        likelihood_vals[i,1] = sum((1-pc_at_nodes) * pc_at_nodes * hg_weights) / sqrt(pi)
        likelihood_vals[i,2] = likelihood_vals[i,1]
        likelihood_vals[i,3] = sum(pc_at_nodes * pc_at_nodes * hg_weights) / sqrt(pi)
        
    #Python optimizers are minimizers, so return the negative log-likelihood
    negloglik = sum(data * -log(likelihood_vals))
    
    #Catch just in case the likelihood produces garbage--tells the optimizer it's hit a really bad point.
    if np.isnan(negloglik) or np.isinf(negloglik):
        return 1e20
    else:
        return negloglik

data = np.array(new_data[['00','01','10','11']])
hg_nodes,hg_weights = hg(100)

numgroups = len(data)

x0 = np.zeros((numgroups+1,1))
#x0[0:len(data_norm)] = 1

estimates = minimize(likelihood,x0,args=(data,hg_nodes,hg_weights), method="BFGS",options={'disp':True,'maxiter':10**10})

e_mu = np.average(estimates.x[0:numgroups],weights=(data.sum(axis=1)/data.sum()))
var_mu = float(np.cov(estimates.x[0:16],aweights=(data.sum(axis=1)/data.sum())))
sigma_2 = exp(estimates.x[numgroups])**2
print('Disaggregate Estimates of E[mu], Var(mu) and Sigma^2:')
est_params = (e_mu,var_mu,sigma_2)
print(est_params)
print('Variance Decomposition:')
var_decomp = (100 * var_mu/(1+var_mu+sigma_2),100 * sigma_2/(1+var_mu+sigma_2),100/(1+var_mu+sigma_2))
print(var_decomp)


#Estimate version with no heterogeneity
data_agg = sum(data,axis=0).reshape((1,4))
x0_agg = [-2,0]
estimates = minimize(likelihood,x0_agg,args=(data_agg,hg_nodes,hg_weights), method="BFGS",options={'disp':True,'maxiter':10**10})

e_mu = estimates.x[0]
sigma_2 = exp(estimates.x[1])**2
print('Aggregate Estimates of mu and Sigma^2:')
est_params_agg = (e_mu,sigma_2)
print(est_params_agg)
print('Variance Decomposition:')
var_decomp_agg = (100*sigma_2/(1+sigma_2),100/(1+sigma_2))
print(var_decomp_agg)


######

#Bootstrap time

raw_data['share'] = raw_data.cnt / raw_data.cnt.sum()
sample_n = raw_data.cnt.sum()

num_bootstrap_runs = 1000

estimates_bs = np.zeros((num_bootstrap_runs,numgroups+1))
estimates_agg_bs = np.zeros((num_bootstrap_runs,2))
weights = np.zeros((num_bootstrap_runs,numgroups))

for run in range(num_bootstrap_runs):
    print(run)
    random.seed(run)
    boot_sample = raw_data.sample(n=sample_n,replace=True,weights='share')
    boot_sample['active_choice'] = (np.random.uniform(size=(boot_sample.switch_actv.shape)) <= boot_sample.switch_actv).astype(int)
    boot_gby_count = boot_sample.groupby(by=['type_actv_ind_Dec','active_choice','group']).count()['female']
    
    boot_data = pd.merge(boot_gby_count.loc[0,0].to_frame(),boot_gby_count.loc[0,1].to_frame(),on='group',how='outer')
    boot_data = pd.merge(boot_data,boot_gby_count.loc[1,0].to_frame(),on='group',how='outer')
    boot_data = pd.merge(boot_data,boot_gby_count.loc[1,1].to_frame(),on='group',how='outer')
    boot_data = np.array(boot_data.fillna(0)).astype(float)

    estimates = minimize(likelihood,x0,args=(boot_data,hg_nodes,hg_weights), method="BFGS",options={'maxiter':10**10})
    estimates_bs[run,:] = estimates.x
    
    boot_data_agg = sum(boot_data,axis=0).reshape((1,4))
    estimates_agg = minimize(likelihood,x0_agg,args=(boot_data_agg,hg_nodes,hg_weights), method="BFGS",options={'maxiter':10**10})
    estimates_agg_bs[run,:] = estimates_agg.x
    
    weights[run,:] = boot_data.sum(axis=1) / boot_data.sum()


variances_bs = np.zeros((num_bootstrap_runs,1))
for i in range(num_bootstrap_runs):
    variances_bs[i] = float(np.cov(estimates_bs[i,0:numgroups],aweights=weights[i]))

est_params_bs = np.c_[np.average(estimates_bs[:,0:numgroups], weights=weights,axis=1),variances_bs,exp(estimates_bs[:,numgroups])**2]
est_params_bs_se = np.c_[est_params_bs.var(axis=0).reshape((3,1)),np.percentile(est_params_bs,2.5,axis=0).reshape((3,1)),np.percentile(est_params_bs,97.5,axis=0).reshape((3,1))]

var_decomp_bs = np.c_[100 * est_params_bs[:,1] / (1 + est_params_bs[:,1] + est_params_bs[:,2]),100 * est_params_bs[:,2] / (1 + est_params_bs[:,1] + est_params_bs[:,2]),100 / (1 + est_params_bs[:,1] + est_params_bs[:,2])]
var_decomp_bs_se = np.c_[var_decomp_bs.var(axis=0).reshape((3,1)),np.percentile(var_decomp_bs,2.5,axis=0).reshape((3,1)),np.percentile(var_decomp_bs,97.5,axis=0).reshape((3,1))]

est_params_bs_agg = np.c_[estimates_agg_bs[:,0],exp(estimates_agg_bs[:,1])**2]
est_params_bs_agg_se = np.c_[est_params_bs_agg.var(axis=0).reshape((2,1)),np.percentile(est_params_bs_agg,2.5,axis=0).reshape((2,1)),np.percentile(est_params_bs_agg,97.5,axis=0).reshape((2,1))]

var_decomp_bs_agg = np.c_[100 * exp(estimates_agg_bs[:,1])**2 / (1 + exp(estimates_agg_bs[:,1])**2),100 / (1 + exp(estimates_agg_bs[:,1])**2)]
var_decomp_bs_agg_se = np.c_[var_decomp_bs_agg.var(axis=0).reshape((2,1)),np.percentile(var_decomp_bs_agg,2.5,axis=0).reshape((2,1)),np.percentile(var_decomp_bs_agg,97.5,axis=0).reshape((2,1))]

print(est_params_bs_se)
print(var_decomp_bs_se)
print(est_params_bs_agg_se)
print(var_decomp_bs_agg_se)



