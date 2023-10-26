********************************************************************************
* Title:   Master do
* Descrip: installs porgrams and runs other dofiles in correct sequence
********************************************************************************
clear all
set more off

use ../Data/Processed_Data/analyticaldata.dta, clear 

********************************************************************************
**#1. INSTALLING PROGRAMS FOR DATA ANALYSIS 
********************************************************************************
ssc install estout, replace 
ssc install coefplot, replace 
net install grc1leg2.pkg, replace from (http://digital.cgdev.org/doc/stata/MO/Misc/)
ssc install rwolf2, replace 
ssc install wyoung, replace 

********************************************************************************
**#2. RUNNING ALL DOFILES IN THE CORRECT ORDER
********************************************************************************
set seed 28383
do ../Code/cleaning_type1type2.do
do ../Code/tables_type1type2.do
do ../Code/figures_type1type2.do
do ../Code/mht_type1type2.do
do ../Code/AppendixBcleaning2_type1type2.do
do ../Code/AppendixBanalysis_type1type2.do