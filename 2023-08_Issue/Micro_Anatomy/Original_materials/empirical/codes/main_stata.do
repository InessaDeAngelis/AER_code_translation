**********************************************************************
* Guntin, Ottonello and Perez (2022)
* This codes runs all the .do files of the paper that replicate the
* empirical tables and figures created using STATA

* Cleans the raw data
* Reproduces all the empirical figures and tables using Stata

* note: numbering of the names of the files different from the table/
* figures number in the paper for Appendix A and B. 
* Check Readme for correspondance.

**********************************************************************

timer on 1

cls
clear all
set mem 200m
set more off

global user = "/Users/rafaelguntin/Dropbox/papers/GuOP_consumption/replication_files_revision/empirical" /* change this to run all the code */

******** install packages ********

ssc install grstyle, replace
net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
ssc install fastxtile, replace
ssc install gsample, replace
ssc install moremata, replace
ssc install colrspace, replace

******** CLEAN RAW DATA ********

global clean = "$user/codes/clean_stata"

** BY COUNTRY

* Italy
do $clean/ITA_clean_long.do

* Spain
do $clean/SPA_clean_CPI.do
do $clean/SPA_clean.do
do $clean/SPA_clean_Cbaskets.do
do $clean/SPA_clean_wealth.do

* Mexico
do $clean/MEX_clean_CPI.do
do $clean/MEX_clean.do
do $clean/MEX_clean_Cbaskets.do
do $clean/MEX_clean_liquid.do
do $clean/MEX_clean_owner.do

* Peru
do $clean/PER_clean_CPI.do
do $clean/PER_clean.do
do $clean/PER_clean_liquid.do
do $clean/PER_clean_charact.do


** SAMPLE SELECTION

do $clean/baseline_sample.do
do $clean/residual.do

******** FIGURES AND TABLES ********

global tables_figures = "$user/codes/tables_figures_stata"

** TABLES

* table 1 and A.8 panels (a) and (b)
do $tables_figures/table_1a_B8ab.do
do $tables_figures/table_1b.do

* table 2
do $tables_figures/table_2a.do
do $tables_figures/table_2b.do
do $tables_figures/table_2c.do
do $tables_figures/table_2d.do
do $tables_figures/table_2e.do
do $tables_figures/table_2f.do
do $tables_figures/table_2g.do

* tables B.1-B.4
do $tables_figures/table_A1_to_A4.do

* table A.1 
do $tables_figures/table_B1.do

* table A.2
do $tables_figures/table_B2.do

* table A.3
do $tables_figures/table_B3a.do
do $tables_figures/table_B3b.do
do $tables_figures/table_B3c.do

* table A.4
do $tables_figures/table_B4a.do
do $tables_figures/table_B4b.do
do $tables_figures/table_B4c.do
do $tables_figures/table_B4d.do

* table A.5
do $tables_figures/table_B5.do

* table A.6
do $tables_figures/table_B6a.do
do $tables_figures/table_B6b.do

* table A.7
do $tables_figures/table_B7a.do
do $tables_figures/table_B7b.do

* table A.8
do $tables_figures/table_B8.do

* table A.9
do $tables_figures/table_B9a.do
do $tables_figures/table_B9b.do
do $tables_figures/table_B9c.do
do $tables_figures/table_B9d.do

* table A.10
do $tables_figures/table_B10.do

* table A.11
do $tables_figures/table_B11a.do
do $tables_figures/table_B11b.do

* table D.1
do $tables_figures/table_D1.do

** FIGURES

* figure 2
do $tables_figures/figure_2.do

* figure 3 and figure B.3
do $tables_figures/figure_3_B3.do

* figure 4
do $tables_figures/figure_4.do

* figure B.1 and B.3
do $tables_figures/figure_A1_A3.do

* figure B.2
do $tables_figures/figure_A2.do

* figure A.1
do $tables_figures/figure_B1.do

* figure A.2
do $tables_figures/figure_B2.do

* figure A.4
do $tables_figures/figure_B4.do

* figure A.5
do $tables_figures/figure_B5.do

* figure A.6 and A.7
do $tables_figures/figure_B6_B7.do

* figure A.8
do $tables_figures/figure_B8.do

* figure D.3
do $tables_figures/figure_D3.do

* figure D.5 and D.6
do $tables_figures/figure_D5_D6.do

* figure D.12 panel (a)
do $tables_figures/figure_D12a.do

* figure D.13 panel (a)
do $tables_figures/figure_D13a.do


timer off 1
timer list
