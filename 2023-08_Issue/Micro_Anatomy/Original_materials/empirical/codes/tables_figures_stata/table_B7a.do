**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table 1 panel a and Table B7 panel a
* Elasticities by firm ownership top income households
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

 **********************************************
 ******* Table 2 panel - Firm owner *******
 **********************************************
 
** ITALY

* data of firm ownership

global input_data_ITA  = "$input/ITA/storico_stata"

u "$input_data_ITA/ricf.dta", clear

gen firm_owner = 0
replace firm_owner = 1 if ar2!=0 & ar2!=.

rename anno year
keep year nquest firm_owner

tempfile fown
save `fown' , replace

u "$database/resid_ITA.dta", clear

* key variables

keep year uy uc ly lc studio freqwt probwt nquest

* firm owner
 
merge m:1 year nquest using `fown'
drop if _merge == 2
drop _merge nquest
replace firm_owner = 0 if firm_owner == .

local year = "2006 2014" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(5)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

keep if decile == 5

tempfile italy_obs
save `italy_obs' , replace

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year firm_owner)

replace uy = ln(uy)
replace uc = ln(uc)

xtset firm_owner year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014

keep firm_owner  g_uc g_uy elast

gen ty = "firm owner"
gen episode = "Italy"

tempfile italy
save `italy' , replace

** SPAIN

global input_data_SPA = "$input/SPA"

* data of firm ownership

local year = "08 13"

foreach y of local year {

use "$input_data_SPA/hog_`y'", clear

destring sitprof regten nuts1, replace

gen year = 2000 + `y'

gen business = .
replace business = 1 if sitprof == 3
replace business = 0 if sitprof == 1 | sitprof == 2 | sitprof == 4

keep numero year business

tempfile dat_`y'
save `dat_`y'',replace

}

append using `dat_08'

tempfile f_own
save `f_own', replace

u "$database/resid_SPA.dta", clear

keep year uy uc ly lc freqwt estudred_sp probwt numero
 
* firm owner

merge 1:1 year numero using `f_own'
keep if _merge == 3
drop _merge numero

rename business firm_owner

keep if year == 2008 | year == 2013

drop if firm_owner == .

local year = "2008 2013" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(5)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

keep if decile == 5

tabulate firm_owner year

tempfile spain_obs
save `spain_obs' , replace

* elasticities

collapse(mean) uc uy [w=freqwt], by(year firm_owner)

replace uy = ln(uy)
replace uc = ln(uc)

xtset firm_owner year

gen g_uy = uy - L5.uy
gen g_uc = uc - L5.uc

gen elast = g_uc/g_uy
keep if year == 2013

keep firm_owner g_uc g_uy elast

gen ty = "firm owner"
gen episode = "Spain"

tempfile spain
save `spain' , replace

** MEXICO

u "$database/resid_MEX.dta", clear

rename EDAD age

keep FOLIO year uy uc ly lc age freqwt probwt

* firm owner

merge 1:1 year FOLIO using "$database/MEX/MEX_owner.dta" /* merge with ownership dataset for Mexico-ENIGH */
keep if _merge == 3
drop _merge FOLIO

drop if firm_owner == .

local year = "1994 1996 2006 2010" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(5)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

keep if decile == 5

tabulate firm_owner year

tempfile mex_obs
save `mex_obs' , replace

* elasticities

collapse(mean) uc uy [w=freqwt], by(year firm_owner)

replace uy = ln(uy)
replace uc = ln(uc)

xtset firm_owner year

gen g_uy = uy - L2.uy
gen g_uc = uc - L2.uc

gen g_uy2 = uy - L4.uy
gen g_uc2 = uc - L4.uc

gen elast = g_uc/g_uy
gen elast2 = g_uc2/g_uy2

keep if year == 2010 | year == 1996

replace g_uy = g_uy2 if year == 2010
replace g_uc = g_uc2 if year == 2010 
replace elast = elast2 if year == 2010

keep firm_owner g_uc g_uy elast year

gen ty = "firm owner"
gen episode = "Mexico - Tequila"
replace episode = "Mexico - GFC" if year == 2010 
drop year

tempfile mexico
save `mexico' , replace

** PERU

global input_PER = "$input/PER"

u "$database/PER/PER_Cdata_charact.dta", clear /* load dataset with more characteristics (e.g., ownership) for Peru */

* variable

keep year uy uc ly lc job freqwt probwt

* ownership

drop if job == .
gen firm_owner = 0
replace firm_owner = 1 if job == 1

* top income

local year = "2007 2010" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(5)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

keep if decile == 5

tabulate firm_owner year

tempfile peru_obs
save `peru_obs' , replace


* elasticities

collapse(mean) uc uy [w=freqwt], by(year firm_owner)

replace uy = ln(uy)
replace uc = ln(uc)

xtset firm_owner year

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy
keep if year == 2010

keep firm_owner g_uc g_uy elast

gen ty = "firm owner"
gen episode = "Peru"

*** TABLE WITH RESULTS ***

append using `mexico'
append using `spain'
append using `italy'

sum elast if firm_owner == 0
local elast_1 = r(mean)

sum elast if firm_owner == 1
local elast_2 = r(mean)


** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "& Yes &" in `row'
replace tc2 = " & " + string(elast[10],"%9.2f") in `row'
replace tc3 = " & " + string(elast[8],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[5],"%9.2f") in `row'
replace tc6 = " & " + string(elast[6],"%9.2f") in `row'
replace tc7 = " & " + string(elast[2],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_2',"%9.2f") in `row'

local ++row
replace tc1 = "& No &" in `row'
replace tc2 = " & " + string(elast[9],"%9.2f") in `row'
replace tc3 = " & " + string(elast[7],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[3],"%9.2f") in `row'
replace tc6 = " & " + string(elast[4],"%9.2f") in `row'
replace tc7 = " & " + string(elast[1],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_1',"%9.2f") in `row'
replace tc10 = "& \hspace{-1em} \vspace{.5em}" in `row'


outsheet tc* in 1/`row' using "$output/tableB7_c.tex", noquote nonames delimit(" ") replace


