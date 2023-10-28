**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code creates dataset for BPP estimates
* Code replicates Table B1 - individual elasticities
* individual elasticities for U.S., Italy and Peru
**********************************************************************

cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

grstyle init
grstyle set plain, horizontal grid  

 *****************************************
 ******* Table B.1 - BPP datasets ********
 *****************************************
 
 do $tables_figures/table_B1dataBPP_US.do
 do $tables_figures/table_B1dataBPP_ITA_PER.do

 ****************************************************
 ******* Table B.1 - Individual Elasticities ********
 ****************************************************
 
** US

u "$database/US/cohA_GuOP.dta", clear

xtset person year

gen g_uy = uy - L1.uy
gen g_uc = uc - L1.uc

reg g_uc g_uy, robust
local ielast_US = _b[g_uy]


** ITALY

* elasticities using panel data (same households across deciles)

u "$database/resid_ITA.dta", clear

replace uy = ln(uy)
replace uc = ln(uc)

xtset nquest year

gen g_uy = uy - L2.uy
gen g_uc = uc - L2.uc
gen elast = g_uc/g_uy

keep if g_uy!=.
keep if g_uc!=.

reg g_uc g_uy, robust

local ielast_ITA = _b[g_uy]

** PER

u "$database/resid_PER.dta", clear

replace uy = ln(uy)
replace uc = ln(uc)

gen id_HH = conglome_ + vivienda_ + hogar

egen id_HH_n = group(id_HH)

xtset id_HH_n year

gen g_uy = uy - L2.uy /* use 2 year difference for consistence with ITA data */
gen g_uc = uc - L2.uc /* use 2 year difference for consistence with ITA data */

drop if g_uy == .
drop if g_uc == .

reg g_uc g_uy, robust
local ielast_PER = _b[g_uy]

** Table B.1 - individual elasticity

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "& Individual Elasticity &   \hspace*{.5em}" in `row'
replace tc2 = " & " + string(`ielast_US',"%9.2fc") in `row'
replace tc3 = " & " + string(`ielast_ITA',"%9.2fc") in `row'
replace tc4 = " & " + string(`ielast_PER',"%9.2fc") in `row'

outsheet tc* in 1/`row' using "$output/tableB1_a.tex", noquote nonames delimit(" ") replace


