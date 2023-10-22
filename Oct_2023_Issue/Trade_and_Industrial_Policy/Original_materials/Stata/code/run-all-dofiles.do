clear
clear matrix
clear mata
set maxvar 25000
set matsize 11000
set more off
capture log close

******************************************
* CHANGE PATH BASED ON THE COMPUTER NAME *
******************************************
cd "~/Dropbox/LL2020/Replication_Aug_2023/Stata"

** create temporary directories if needed
local dir "data/temp"
capture noisily!mkdir -p "`dir'"
local dir "output/temp"
capture noisily !mkdir -p "`dir'"

*****************************************
* SPECIFY ACCESS TO CONFIDENTIAL DATA *
*****************************************
* set value to 'yes' if you have access to transaction-level Colombian import data from www.Datamyne.com 
* as in dataset 'data/confidential/datamyne/ColombiaImports2008.dta' (not provided in this archive)
global access_to_datamyne no
* set value to 'yes' if you have access to the World Bank's Exporter Dynamics Database
* the datset must be saved as 'data/confidential/edd_worldbank/CYH6_manuf.dta'(not provided in this archive)
global access_to_edd no 

* set value to 'yes' if you wish to delete the intermediate output produced in
* MATLAB after generating the final exhibit (Figures 2, 3, W1-W2, and Y1-Y3)
global delete_matlab_output no

**********************
* INSTALL PACKAGES *
**********************

capture ssc install colrspace, replace
capture ssc install cleanplots, replace
capture ssc install palettes, replace
capture ssc install estout, replace
capture ssc install outreg, replace
capture ssc install ivreg2, replace
capture ssc install gtools, replace
capture ssc install hdfe, replace
capture ssc install reghdfe, replace
capture ssc install ivreghdfe, replace
capture ssc install ftools, replace 
capture ssc install ranktest, replace 
capture ssc install winsor2, replace 
capture ssc install strdist, replace
capture ssc install labutil, replace 
capture ssc install scheme-burd, replace

******************************************************
 *** 	PRDOUCE TABLES & FIGURE in MAIN TEXT 	***
******************************************************/
set scheme cleanplots, perm
colorpalette lin fruits, global
*graph set window fontface "Merriweather"
graph set window fontface "Times New Roman"

*~~~~~~~~~~~~  SECTION 6  ~~~~~~~~~~~~~
* Table 3: firm-level demand estimation 
* To run all portions of this file, you need access to transaction-level trade data from www.Datamyne.com  
* as in the dataset 'data/confidential/datamyne/ColombiaImports2008.dta' (data not provided)
* runtime:  ~35 minutes
di "$S_DATE $S_TIME"
do "code/analysis/1-table_3.do"

if "$access_to_datamyne" == "yes" {
* save codebook for confidential data from www.Datamyne.com
* runtime:  ~5 minutes
use data/temp/colombia_imports, clear
log using "data/confidential_data/datamyne/list_of_variables.log", replace
codebook, compact
log close
}
*~~~~~~~~~~~~  SECTION 7  ~~~~~~~~~~~~~
* Figure 2: gains from deep vs. shallow cooperation
* runtime: ~1 second
di "$S_DATE $S_TIME"
do "code/analysis/2-figure_2.do"

* Figure 3: gains from cooperative vs. non-ccoperative policies
* runtime: ~1 second
di "$S_DATE $S_TIME"
do "code/analysis/3-figure_3.do"

**********************************************************
 *** 	PRDOUCE TABLES & FIGURE in ONLINE APPENDIX 	  ***
**********************************************************

* Appendix H – test theoritical formulas
* runtime: ~3 seconds
di "$S_DATE $S_TIME"
do "code/analysis/4-figure_H1.do"
do "code/analysis/5-figure_H2.do"
do "code/analysis/6-figure_H3.do"

* Appendix N – summary statistics: Colombia imports
* runtime: ~1 minute
di "$S_DATE $S_TIME"
do "code/analysis/7-table_N1.do"

* Appendix O – Illustrative IV examle
* runtime: ~6 seconds
di "$S_DATE $S_TIME"
do "code/analysis/8-figure_O1.do"

* Appendix P – robsutness checks:demand estimation
* runtime: ~20 minutes
di "$S_DATE $S_TIME"
do "code/analysis/9-figure_P1.do"

* Apeendix Q – fixed effects demand estimation
* runtime: ~ 15 minutes
di "$S_DATE $S_TIME"
do "code/analysis/10-table_Q1.do"


* Apeendix R – markups under alternative market conduct
* runtime: ~7 seconds
di "$S_DATE $S_TIME"
do "code/analysis/11-table_R1.do"
*/

* Apeendix S – plausibility of estimates 
* runtime: ~1 minute
di "$S_DATE $S_TIME"
do "code/analysis/12-table_S1.do"
do "code/analysis/13-figure_S1.do"

* Apeendix W – tension between ToT & misallocation
* runtime: ~3 seconds
di "$S_DATE $S_TIME"
do "code/analysis/14-figure_W1.do"
do "code/analysis/15-figure_W2.do"

* Apeendix Y –  policy gains in alternative settings
* runtime: ~10 seconds
di "$S_DATE $S_TIME"
do "code/analysis/16-figure_Y1.do"
do "code/analysis/17-figure_Y2.do"
do "code/analysis/18-figure_Y3.do"
