**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figure A.2
* Distribution of net liquid assets in Spain and Italy
**********************************************************************

cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

*** ITA ***

* credit card debt

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

* distribution of liquid assets

gen w_y = (liq_wealth/income)*12
drop if w_y == .
replace w_y = 10 if w_y>10
replace w_y = -10 if w_y<-10

local width_ = "2.6"
local height_ = "1.8"

hist w_y [fw=pesopop_r], fraction width(.5) graphregion(color(white)) xtitle("liquid net assets/monthly income") ///
xlabel(,grid) ylabel(0(.05).35,grid) color(black) addplot(pci 0 .5 .35 .5, lw(.8) lc(maroon) lp(dash)) legend(off) xsize(`width_') ysize(`height_') 
graph export "$output/figureA2_a.pdf", replace

*** SPA ***

use "$database/SPA/SPA_wealth_EFF.dta" , clear

replace liq = liq - ccdebt
gen htm_y = (liq/income_2)

replace htm = 0
replace htm = 1 if htm_y>.5 & htm_y!=.

drop if income_2 <=0
drop if income_2 == .

merge m:1 year using "$input/SPA/CPI.dta"
drop if _merge==2
drop _merge

qui sum CPI if year == 2014
local CPI14 = r(mean)
gen liq_14 = (liq/CPI)*`CPI14'
gen wealth_14 = (wealth/CPI)*`CPI14'

reg htm i.year i.age male i.educ i.members i.perc_income i.mar_status house business [pw = factor]
predict htm_hat if e(sample)

replace htm_y =10 if htm_y > 10 & htm_y!=.
replace htm_y =-10 if htm_y < -10 & htm_y!=.

keep if age<61
keep if age>24

local width_ = "2.6"
local height_ = "1.8"

hist htm_y [fw=factor_r], fraction width(.5) graphregion(color(white)) xtitle("liquid net assets/monthly income") ///
xlabel(,grid) ylabel(0(.05).35,grid) color(black) addplot(pci 0 .5 .35 .5, lw(.8) lc(maroon) lp(dash)) xsize(`width_') ysize(`height_') legend(off)
graph export "$output/figureA2_b.pdf", replace


