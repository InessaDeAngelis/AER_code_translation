**********************************************************************
* Guntin, Ottonello and Perez (2022)

* Calculates moments for table D.4
**********************************************************************

cls
clear all
set mem 200m
set more off

global database = "$user/empirical/working_data" 
global input    = "$user/empirical/input" 
global output   = "$user/model/input"

*** income distribution moments ***

u "$database/resid_MEX.dta", clear

*replace uy = ln(uy)
*ginidesc uy [fw=HOG_r]  /* Gini index income, ginidesc may not work */

gen variable = "Gini index income" in 1
gen value =  0.428   in 1
drop if value == .
keep variable value

tempfile income_gini
save `income_gini', replace

** income shares **

u "$database/resid_MEX.dta", clear

local year = "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014" 
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=HOG_r] , nq(20)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uy [fw=HOG_r], by(decile)

qui sum uy
replace uy = uy/r(sum)

rename uy s_income

gen categ = 0
replace categ = 1 if decile == 20 /* top 5 */
replace categ = 2 if decile == 19 /* top 10 to 5 */
replace categ = 3 if decile <= 15 /* bottom 75 */
drop if categ == 0

collapse(sum) s_income, by(categ)

gen variable = "Income share bottom 75" in 1
replace variable = "Income share top 10" in 2
replace variable = "Income share top 5" in 3

gen value = s_income[3] in 1
replace value = s_income[2] + s_income[1] in 2
replace value = s_income[1] in 3

keep variable value

tempfile income_shares
save `income_shares', replace

*** poverty moments ***

import excel "$input/aggregate/WB_poverty_middle.xls", sheet("Data") cellrange(A4:BN270) firstrow clear

keep if CountryCode == "MEX" | CountryCode == "ITA" 

keep CountryCode year*
reshape long year, i(CountryCode) j(date)
reshape wide year, i(date) j(CountryCode, string)

ipolate yearITA date, gen(ITA_pov_rate)
ipolate yearMEX date, gen(MEX_pov_rate)

keep if date>=1998 & date<=2016
collapse(mean) MEX_pov_rate ITA_pov_rate /* HH share below subsistence level - values may change if file updated */

keep MEX_pov_rate

gen variable = "Share below subsistence" in 1
gen value = MEX_pov_rate 

keep variable value

tempfile subsistence
save `subsistence', replace

*** wealth moments ***

u "$database/resid_MEX.dta", clear

merge 1:1 year FOLIO using  "$database/MEX/MEX_wealth.dta"  /* HH with liquid asset holding id using financial income data */
drop if _merge == 2
drop _merge

collapse(mean) fina /* HH share with assets */

gen variable = "No liquid assets" in 1

gen value = 1 - fina

keep variable value

tempfile nassets
save `nassets', replace

*** data for Excel files ***

u `income_gini', clear
append using `nassets'
append using `subsistence'
append using `income_shares'

rename value moments_mex

export excel variable moments_mex using "$output/moments_MEX.xls", firstrow(variables) replace


