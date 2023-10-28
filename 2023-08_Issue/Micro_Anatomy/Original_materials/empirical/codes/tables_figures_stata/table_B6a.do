**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table B6 panel a
* elasticities across wealth levels for all households
**********************************************************************

cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

grstyle clear

 ************************************ 
 ********* sample selection *********
 ************************************

*** baseline sample ITA *** 

global input_data_ITA  = "$input/ITA"
 
*** ITA wealth data *** 

u "$input_data_ITA/storico_stata/ricf.dta", clear

*same defn as former 4a.ITA_asset_categ
gen liq_wealth = af
drop if liq_wealth == .
rename anno year

*liquid risky wealth
gen risk_wealth = af2 + af3

gen firm_owner = 0
replace firm_owner = 1 if ar2!=0 & ar2!=.

keep nquest year liq_wealth w risk_wealth pf firm_owner

tempfile wealth_data
save `wealth_data', replace


u "$input_data_ITA/storico_stata/fami.dta", clear

gen home_owner = (godab == 1)

rename anno year

keep year nquest home_owner

tempfile hown
save `hown' , replace

*cross section

u "$database/resid_ITA.dta", clear

* home owner
merge m:1 year nquest using `hown'
drop if _merge == 2
drop _merge 
replace home_owner = 0 if home_owner == .

merge m:1 nquest year using `wealth_data'
keep if _merge == 3
drop _merge

gen nom_income = income/rival

gen lw_y = liq_wealth/nom_income
gen w_y = w/nom_income
gen rw_y = risk_wealth/nom_income
gen pf_y = pf/nom_income

keep year uy uc ly lc freqwt probwt lw_y w_y rw_y pf_y firm_owner home_owner

tempfile sample_data
save `sample_data', replace


*total net wealth to income
u `sample_data', clear

drop if w_y == .
drop if w_y <= 0

local year = "2006 2014"
gen decile = .
foreach x of local year {
fastxtile decile_`x' = w_y if year == `x' [fw=freqwt] , nq(2)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse (mean) uc uy w_y [fw=freqwt], by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014
keep elast w_y decile

rename w_y value

gen ty = "total net wealth to income"
gen episode = "cross-section"

tempfile cs_w_y
save `cs_w_y' , replace


*liquid wealth to income
u `sample_data', clear

drop if lw_y == .
drop if lw_y <= 0

local year = "2006 2014"
gen decile = .
foreach x of local year {
fastxtile decile_`x' = lw_y if year == `x' [fw=freqwt] , nq(2)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

keep if year == 2006 | year == 2014

collapse (mean) uc uy lw_y [fw=freqwt], by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014
keep elast lw_y decile

rename lw_y value

gen ty = "liquid wealth to income"
gen episode = "cross-section"

tempfile cs_lw_y
save `cs_lw_y' , replace


*risky wealth to income
u `sample_data', clear

drop if rw_y == .
drop if rw_y <= 0

local year = "2006 2014"
gen decile = .
foreach x of local year {
fastxtile decile_`x' = rw_y if year == `x' [fw=freqwt] , nq(2)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse (mean) uc uy rw_y [fw=freqwt], by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014
keep elast rw_y decile

rename rw_y value

gen ty = "risky liquid wealth to income"
gen episode = "cross-section"

tempfile cs_rw_y
save `cs_rw_y' , replace


*debt to income
u `sample_data', clear

drop if pf_y == .
drop if pf_y<=0

local year = "2006 2014"
gen decile = .
foreach x of local year {
fastxtile decile_`x' = pf_y if year == `x' [fw=freqwt] , nq(2)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

keep if year == 2006 | year == 2014

collapse (mean) uc uy pf_y [fw=freqwt], by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014
keep elast pf_y decile

rename pf_y value

gen ty = "debt to income"
gen episode = "cross-section"

tempfile cs_d_y
save `cs_d_y' , replace


*home owner
u `sample_data', clear

* elasticities

collapse (mean) uc uy [fw=freqwt], by(year home_owner)

replace uy = ln(uy)
replace uc = ln(uc)

xtset home_owner year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014

keep home_owner elast

gen ty = "home owner"
gen episode = "cross-section"

tempfile cs_ho
save `cs_ho' , replace


*firm owner
u `sample_data', clear

* elasticities

collapse(mean) uc uy  [fw=freqwt], by(year firm_owner)

replace uy = ln(uy)
replace uc = ln(uc)

xtset firm_owner year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014

keep firm_owner elast

gen ty = "firm owner"
gen episode = "cross-section"

tempfile cs_fo
save `cs_fo' , replace

append using `cs_ho'
append using `cs_d_y'
append using `cs_rw_y'
append using `cs_lw_y'
append using `cs_w_y'

tempfile cross_section
save `cross_section' , replace

tempfile data_table
save `data_table', replace


** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "& \multirow{2}{*}{Total Net Wealth-to-Income}\hspace*{.5em}" in `row'
replace tc2 = "& Low" in `row'
replace tc6 = " & " + string(value[11],"%9.2f") in `row'
replace tc7 = " & " + string(elast[11],"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& High" in `row'
replace tc6 = " & " + string(value[12],"%9.2f") in `row'
replace tc7 = " & " + string(elast[12],"%9.2f") + "\vspace{.3em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{Liquid Wealth-to-Income}\hspace*{.8em}" in `row'
replace tc2 = "& Low" in `row'
replace tc6 = " & " + string(value[9],"%9.2f") in `row'
replace tc7 = " & " + string(elast[9],"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& High" in `row'
replace tc6 = " & " + string(value[10],"%9.2f") in `row'
replace tc7 = " & " + string(elast[10],"%9.2f") + "\vspace{.3em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{Risky Liquid Wealth-to-Income}\hspace*{.5em}" in `row'
replace tc2 = "& Low\hspace*{.5em}" in `row'
replace tc6 = " & " + string(value[7],"%9.2f") in `row'
replace tc7 = " & " + string(elast[7],"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& High" in `row'
replace tc6 = " & " + string(value[8],"%9.2f") in `row'
replace tc7 = " & " + string(elast[8],"%9.2f") + "\vspace{.3em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{Debt-to-Income}\hspace*{.5em}" in `row'
replace tc2 = "& Low" in `row'
replace tc6 = " & " + string(value[5],"%9.2f") in `row'
replace tc7 = " & " + string(elast[5],"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& High" in `row'
replace tc6 = " & " + string(value[6],"%9.2f") in `row'
replace tc7 = " & " + string(elast[6],"%9.2f") + "\vspace{.3em}" in `row'

outsheet tc* in 1/`row' using "$output/tableB6_a.tex", noquote nonames delimit(" ") replace


*** TABLE D3 - B - OBSERVATIONS

u "$database/resid_ITA.dta", clear

sum year if year == 2014 | year == 2006
local obs_cs = r(N)


** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "& \multicolumn{2}{l}{N Observations} \vspace{.2em}" in `row'
replace tc2 = " " in `row'
replace tc6 = " & " + string(`obs_cs',"%9.0fc") in `row'
replace tc7 = " & " + string(`obs_cs',"%9.0fc") in `row'

outsheet tc* in 1/`row' using "$output/tableB6_b.tex", noquote nonames delimit(" ") replace


