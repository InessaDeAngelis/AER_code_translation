**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table D1
* Moments of wealth distribution
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
 
 ************************
 ******* Table D1 *******
 ************************

global input_data_ITA  = "$input/ITA"

* credit card debt

u "$input_data_ITA/q08c1.dta", clear

gen cdebt = cartdeb
replace cdebt = 0 if cdebt == .

gen anno = 2008

keep anno cdebt nquest

tempfile ccdebt_08
save `ccdebt_08', replace

u "$input_data_ITA/ricfam10.dta", clear

gen cdebt = pfcarte

gen anno = 2010

keep anno cdebt nquest

tempfile ccdebt_10
save `ccdebt_10', replace

u "$input_data_ITA/ricfam12.dta", clear

gen cdebt = pfcarte

gen anno = 2012

keep anno cdebt nquest

tempfile ccdebt_12
save `ccdebt_12', replace

u "$input_data_ITA/ricfam14.dta", clear

gen cdebt = pfcarte

gen anno = 2014

keep anno cdebt nquest

tempfile ccdebt_14
save `ccdebt_14', replace

u "$input_data_ITA/debiti16.dta", clear

gen cdebt = pfcarte

gen anno = 2016

keep anno cdebt nquest

append using `ccdebt_08'
append using `ccdebt_10'
append using `ccdebt_12'
append using `ccdebt_14'

tempfile ccdebt
save `ccdebt', replace

* wealth data time series

u "$input_data_ITA/storico_stata/ricf.dta", clear

keep if anno>=2008

merge 1:1 anno nquest using `ccdebt'
drop _merge

*same defn as former 4a.ITA_asset_categ
gen liq_wealth = af - cdebt
drop if liq_wealth == .
rename anno year

*liquid risky wealth
gen risk_wealth = af2 + af3

gen firm_owner = 0
replace firm_owner = 1 if ar2!=0 & ar2!=.

keep nquest year liq_wealth w risk_wealth pf firm_owner

tempfile wealth_data
save `wealth_data', replace

* build data

u "$database/resid_ITA.dta", clear

merge m:1 nquest year using `wealth_data'
keep if _merge == 3
drop _merge

rename liq_wealth lw
rename risk_wealth rw

* level
replace lw         = lw*rival
replace rw         = rw*rival
replace w          = w*rival
gen     nlw        = w - lw

* level per capita
gen lw_p         = lw/hhsize
gen rw_p         = rw/hhsize
gen w_p          = w/hhsize
gen nlw_p        = w_p - lw_p

* ratio to income
gen rw_y = rw/income
gen pf_y = pf/income
gen lw_y = lw/income
gen nlw_y = nlw/income
gen w_y  = w/income

keep ///
year freqwt probwt income hhsize ///
lw w nlw ///
lw_y w_y nlw_y ///
lw_p w_p nlw_p

tempfile data_wealth
save `data_wealth', replace

*** number of observations

gen count = 1
qui sum count, detail
local observations = r(sum)

**** Gini index **** 

/* include 0 and negative values in Gini's calculation */
replace lw_p  = 0.0000000000000000001 if lw_p<=0 & lw_p!=.     
replace nlw_p = 0.0000000000000000001 if nlw_p<=0 & nlw_p!=.
replace w_p   = 0.0000000000000000001 if w_p<=0 & w_p!=.

*ginidesc lw_p  [fw=freqwt] /* Gini index of liquid wealth */
*ginidesc w_p   [fw=freqwt] /* Gini index of Non-liquid wealth */
*ginidesc nlw_p [fw=freqwt] /* Gini index of total wealth */

/* results, ginidesc may stop the code to reproduce numbers use code above */
local gini_lw  = 0.78
local gini_nlw = 0.67
local gini_w   = 0.68

**** Wealth shares **** 

local vars = "nlw_p w_p lw_p"

foreach y of local vars {

u `data_wealth', clear

gen decile = .
local year = "2008 2010 2012 2014 2016" 
foreach x of local year {
xtile decile_`x' = `y' if year == `x' [fw=freqwt] , nq(20)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(sum) `y' [fw=freqwt], by(decile)

egen total = sum(`y')
gen s_`y' = `y'/total
keep s_`y' decile

gen categ = 0
replace categ = 1 if decile == 20 /* top 5 */
replace categ = 2 if decile == 19 /* top 10 to 5 */
replace categ = 3 if decile <= 15 /* bottom 75 */
drop if categ == 0

collapse(sum) s_`y', by(categ)

tempfile share_`y'
save `share_`y'', replace

}

merge 1:1 categ using `share_nlw_p', nogenerate
merge 1:1 categ using `share_w_p', nogenerate

local share_lw_75 = s_lw_p[3]
local share_lw_10 = s_lw_p[1] + s_lw_p[2]
local share_lw_5  = s_lw_p[1]

local share_nlw_75 = s_nlw_p[3]
local share_nlw_10 = s_nlw_p[1] + s_nlw_p[2]
local share_nlw_5  = s_nlw_p[1]

local share_w_75 = s_w_p[3]
local share_w_10 = s_w_p[1] + s_w_p[2]
local share_w_5  = s_w_p[1]

**** Wealth-to-income **** 

** aggregate

u `data_wealth', clear

collapse(sum) income lw nlw w [fw=freqwt], by(year)

gen lw_y_ag = lw/income
gen nlw_y_ag = nlw/income
gen w_y_ag = w/income

collapse(mean) lw_y_ag nlw_y_ag w_y_ag  /* W-to-Y aggregate ratio */

local lw_y_ag = lw_y_ag
local nlw_y_ag = nlw_y_ag
local w_y_ag = w_y_ag

** cross-section moments

u `data_wealth', clear

collapse(mean) lw_y_av = lw_y nlw_y_av = nlw_y w_y_av = w_y (sd)  lw_y_sd = lw_y nlw_y_sd = nlw_y w_y_sd = w_y [fw=freqwt]

local lw_y_av = lw_y_av
local nlw_y_av = nlw_y_av
local w_y_av = w_y_av

local lw_y_sd = lw_y_sd
local nlw_y_sd = nlw_y_sd
local w_y_sd = w_y_sd

** latex preamble

if _N<500 set obs 500

* N observations row

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "& \multicolumn{2}{l}{N Observations} \vspace{.2em}" in `row'
replace tc2 = " " in `row'
replace tc6 = " & " + string(`observations',"%9.0fc") in `row'
replace tc7 = " & " + string(`observations',"%9.0fc") in `row'
replace tc8 = " & " + string(`observations',"%9.0fc") in `row'

outsheet tc* in 1/`row' using "$output/tableD1_b.tex", noquote nonames delimit(" ") replace

drop tc*

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "& {Wealth-to-income}\hspace*{.5em}" in `row'
replace tc2 = "& " in `row'
replace tc6 = " & " + string(`lw_y_ag',"%9.2f") in `row'
replace tc7 = " & " + string(`nlw_y_ag',"%9.2f") in `row'
replace tc8 = " & " + string(`w_y_ag',"%9.2f") in `row'

local ++row
replace tc1 = "& {Av. Wealth-to-income}\hspace*{.5em}" in `row'
replace tc2 = "& " in `row'
replace tc6 = " & " + string(`lw_y_av',"%9.2f") in `row'
replace tc7 = " & " + string(`nlw_y_av',"%9.2f") in `row'
replace tc8 = " & " + string(`w_y_av',"%9.2f") in `row'

local ++row
replace tc1 = "& {Std. Dev. Wealth-to-income}\hspace*{.5em}" in `row'
replace tc2 = "& " in `row'
replace tc6 = " & " + string(`lw_y_sd',"%9.2f") in `row'
replace tc7 = " & " + string(`nlw_y_sd',"%9.2f") in `row'
replace tc8 = " & " + string(`w_y_sd',"%9.2f") in `row'
replace tc9 = "& \hspace{-1em} \vspace{.5em}" in `row'

local ++row
replace tc1 = "& {Gini index wealth}\hspace*{.5em}" in `row'
replace tc2 = "& " in `row'
replace tc6 = " & " + string(`gini_lw',"%9.2f") in `row'
replace tc7 = " & " + string(`gini_nlw',"%9.2f") in `row'
replace tc8 = " & " + string(`gini_w',"%9.2f") in `row'

local ++row
replace tc1 = "& {Wealth share bottom 75}\hspace*{.5em}" in `row'
replace tc2 = "& " in `row'
replace tc6 = " & " + string(`share_lw_75',"%9.2f") in `row'
replace tc7 = " & " + string(`share_nlw_75',"%9.2f") in `row'
replace tc8 = " & " + string(`share_w_75',"%9.2f") in `row'

local ++row
replace tc1 = "& {Wealth share top 10}\hspace*{.5em}" in `row'
replace tc2 = "& " in `row'
replace tc6 = " & " + string(`share_lw_10',"%9.2f") in `row'
replace tc7 = " & " + string(`share_nlw_10',"%9.2f") in `row'
replace tc8 = " & " + string(`share_w_10',"%9.2f") in `row'

local ++row
replace tc1 = "& {Wealth share top 5}\hspace*{.5em}" in `row'
replace tc2 = "& " in `row'
replace tc6 = " & " + string(`share_lw_5',"%9.2f") in `row'
replace tc7 = " & " + string(`share_nlw_5',"%9.2f") in `row'
replace tc8 = " & " + string(`share_w_5',"%9.2f") in `row'

outsheet tc* in 1/`row' using "$output/tableD1_a.tex", noquote nonames delimit(" ") replace
