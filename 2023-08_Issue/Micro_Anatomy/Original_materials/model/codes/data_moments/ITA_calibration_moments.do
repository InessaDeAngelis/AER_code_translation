**********************************************************************
* Guntin, Ottonello and Perez (2022)

* Calculates moments for table 4
**********************************************************************

cls
clear all
set mem 200m
set more off

global database = "$user/empirical/working_data" 
global input = "$user/empirical/input" 
global output   = "$user/model/input"

*** income moments ***

** Gini index income

u "$database/resid_ITA.dta", clear

*ginidesc uy [fw=pesopop_r] /* Gini index of residualized income, ginidesc function may not work */

gen variable = "Gini index income" in 1
gen value = 0.316  in 1
drop if value == .
keep variable value

tempfile income_gini
save `income_gini', replace

** Income shares

u "$database/resid_ITA.dta", clear

local year = "1995 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016" 
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=pesopop_r] , nq(20)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(sum) uy [fw=pesopop_r], by(decile)

egen uy_total = sum(uy)
gen s_income = uy/uy_total
keep s_income decile /* Income shares */

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

*** wealth moments ***

u "$input/ITA/q08c1.dta", clear

gen cdebt = cartdeb
replace cdebt = 0 if cdebt == .

gen anno = 2008

keep anno cdebt nquest

tempfile ccdebt_08
save `ccdebt_08', replace

u "$input/ITA/ricfam10.dta", clear

gen cdebt = pfcarte

gen anno = 2010

keep anno cdebt nquest

tempfile ccdebt_10
save `ccdebt_10', replace

u "$input/ITA/ricfam12.dta", clear

gen cdebt = pfcarte

gen anno = 2012

keep anno cdebt nquest

tempfile ccdebt_12
save `ccdebt_12', replace

u "$input/ITA/ricfam14.dta", clear

gen cdebt = pfcarte

gen anno = 2014

keep anno cdebt nquest

tempfile ccdebt_14
save `ccdebt_14', replace

u "$input/ITA/debiti16.dta", clear

gen cdebt = pfcarte

gen anno = 2016

keep anno cdebt nquest

append using `ccdebt_08'
append using `ccdebt_10'
append using `ccdebt_12'
append using `ccdebt_14'

tempfile ccdebt
save `ccdebt', replace

u "$input/ITA/storico_stata/ricf.dta", clear

keep if anno>=2008

merge 1:1 anno nquest using `ccdebt'
drop _merge

gen liq_wealth = af - cdebt

keep anno nquest liq_wealth

tempfile wealth
save `wealth', replace

u "$database/baseline_ITA.dta", clear

merge m:1 anno using "$input/ITA/storico_stata/defl.dta"
keep if _merge == 3
drop _merge

merge m:1 anno nquest using `wealth'
keep if _merge == 3
drop _merge

gen liq_y = liq_wealth/(income/12)
drop if liq_y == .

gen htm = (liq_y<.5)

gen pesopop_r = round(pesopop)

replace liq_wealth = liq_wealth*rival
replace income = income*rival
gen liq_wealth_p = liq_wealth/hhsize

tempfile data
save `data', replace

** Gini index liquid wealth

gen  liq_wealth_p_aux = liq_wealth_p
replace liq_wealth_p_aux = 0.0000000001 if liq_wealth_p<=0 & liq_wealth_p!=. /* include negative values as almost 0 holdings */
*ginidesc liq_wealth_p_aux [fw=pesopop_r]  /* Gini index of net liquid wealth, ginidesc may no work */
local gini_wealth = 0.783

rename anno year

gen decile = .
local year = "2008 2010 2012 2014 2016" 
foreach x of local year {
xtile decile_`x' = liq_wealth_p if year == `x' [fw=pesopop_r] , nq(20)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(sum) liq_wealth_p [fw=pesopop_r], by(decile)

egen w_total = sum(liq_wealth_p)
gen s_w = liq_wealth_p/w_total
keep s_w decile

gen categ = 0
replace categ = 1 if decile == 20 /* top 5 */
replace categ = 2 if decile == 19 /* top 10 to 5 */
replace categ = 3 if decile <= 15 /* bottom 75 */

collapse(sum) s_w, by(categ)

gen variable = "Gini index wealth" in 1
replace variable = "Wealth share bottom 75" in 2
replace variable = "Wealth share top 10" in 3
replace variable = "Wealth share top 5" in 4

gen value = `gini_wealth' in 1
replace value = s_w[4] in 2
replace value = s_w[3] + s_w[2] in 3
replace value = s_w[2] in 4

keep variable value

tempfile wealth_shares_gini
save `wealth_shares_gini', replace

** Hand-to-mouth

u `data', clear

collapse(mean) htm [fw=pesopop_r], by(anno)
collapse(mean) htm                         /* Hand-to-mouth hh share */

gen variable = "Hand-to-mouth share" in 1
gen value = htm 

keep variable value

tempfile HtM_share
save `HtM_share', replace

** Wealth-over-income ratio

u `data', clear

replace liq_wealth = liq_wealth*rival
replace income = income*rival

collapse(sum) income liq_wealth [fw=pesopop_r], by(anno)

gen w_y = liq_wealth/income 

collapse(mean) w_y  /* W-to-Y ratio */

gen variable = "Wealth-to-income ratio" in 1
gen value = w_y 

keep variable value

*** calibration moments for Excel file ***

append using `HtM_share'
append using `income_gini'
append using `income_shares'
append using `wealth_shares_gini'

rename value moments_baseline

export excel variable moments_baseline using "$output/moments_ITA.xls", firstrow(variables) replace

