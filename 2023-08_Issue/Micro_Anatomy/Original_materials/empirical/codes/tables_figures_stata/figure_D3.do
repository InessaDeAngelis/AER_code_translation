**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figure D.3
* Wealth revaluation and holdings across income distribution
********************************************************************** 

cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

grstyle clear
set scheme s2color
graph set window fontface default

*** Liquid wealth by risk and wealth revaluation in Italy ***

u "$input/ITA/storico_stata/ricf.dta", clear

gen liq_wealth = af
gen dep = af1
gen bonds = af2
gen o_sec = af3
gen lend = af4
drop if liq_wealth == .
 
keep nquest anno liq_wealth dep bond o_sec lend
rename anno year

tempfile wealth_data
save `wealth_data', replace

* baseline sample and residualization
u "$database/resid_ITA.dta", clear

* merge wealth data
merge m:1 nquest year using `wealth_data'
keep if _merge == 3
drop _merge

replace liq_wealth = liq_wealth*rival
replace dep = dep*rival
replace bonds = bonds*rival
replace o_sec = o_sec*rival
replace lend = lend*rival

* deciles of residualized income

local year = "1995 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016"
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(sum) liq_wealth o_sec lend bonds dep income [fw=freqwt], by(year decile)

gen wy = liq_wealth/income
gen dy = dep/income
gen boy = bonds/income
gen ly = lend/income
gen sy = o_sec/income

collapse(mean) wy dy boy ly sy, by(decile)

gen d1 = ly + dy
gen d2 = sy + boy

gen ch = - sy*.44/wy - boy*.11/wy /* observed drop of 44% in stock market index and drop of 11% in sovereign bond value */
gen ch_y = ch*wy                  /* losses in terms of income, used for revaluation exercises in the model */

* Figure D.3 - panel (a) and (b)

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(connected d1 d2 decile, lc(orange emerald) mc(orange*.7 emerald*.7) msize(2.5 2.5) lw(1 1)) ///
, xtitle("deciles of income")  ytitle("liquid wealth/income") ///
graphregion(color(white)) ylabel(0(.25)1,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(, grid labsize(large)) ///
legend(order(1 "low-risk" 2 "high-risk") ring(0) position(8) region(color(white)))
graph export "$output/figureD3_a.pdf", replace

twoway ///
(connected ch decile, lc(maroon emerald) mc(maroon*.7 emerald*.7) msize(2.5 2.5) lw(1 1)) ///
, xtitle("") ytitle("") xtitle("deciles of income") ytitle("drop asset value") ///
graphregion(color(white)) ylabel(-.3(.1)0,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(, grid labsize(large)) ///
yline(0, lc(gray*.8) lw(.6) lp(dash))
graph export "$output/figureD3_b.pdf", replace


