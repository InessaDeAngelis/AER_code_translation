* Guntin, Ottonello and Perez (2022)
* Code creates the BPP dataset

cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global BPP = "$user/input/US/BPP"

ssc install ivreg2
ssc install ranktest

** BPP replication
* to create the dataset, the replication codes were slighly modified
* replication files used (link to data and codes https://www.openicpsr.org/openicpsr/project/113270/version/V1/view):
* 1 sample selection - adjusted_AER.do; data.dta; 
* 2 CEX imputation   - impute_AER.do; finprice.dta; cexall.dta; tax9192.dta; natpr.dta
* 3 residual consumption and income   - mindist_AER.do

* Sample selection
do $BPP/adjust_AER.do

* Imputation from CEX
do $BPP/impute_AER.do

* Creates panel dataset of residual consumption and income
do $BPP/mindist_AER.do


