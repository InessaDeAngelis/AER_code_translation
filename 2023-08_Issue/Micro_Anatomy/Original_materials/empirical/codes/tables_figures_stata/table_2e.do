**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table 1 panel e: Elasticities by geographical area
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
 ******* Table 2 panel - Geo *******
 **********************************************
 
** ITALY

global input_data_ITA  = "$input/ITA/storico_stata"

* region

u "$input_data_ITA/comp.dta", clear

gen large = .
replace large = 0 if acom5 == 1 | acom5 == 2 | acom5 == 3
replace large = 1 if acom5 == 4 | acom5 == 5

keep if cfred == 1

keep anno nquest large

rename anno year

tempfile largee
save `largee' , replace

u "$database/resid_ITA.dta", clear

* variables

keep year uy uc ly lc studio freqwt probwt nquest

* region
 
merge m:1 year nquest using `largee'
drop if _merge == 2
drop _merge nquest
drop if large == .

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year large)

replace uy = ln(uy)
replace uc = ln(uc)

xtset large year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014

keep large g_uc g_uy elast

gen ty = "large region"
gen episode = "Italy"

tempfile italy
save `italy' , replace

** SPAIN

u "$database/resid_SPA.dta", clear

keep year uy uc ly lc freqwt estudred_sp probwt tamamu
 
* region

gen large = (tamamu == 1)

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year large)

replace uy = ln(uy)
replace uc = ln(uc)

xtset large year

gen g_uy = uy - L5.uy
gen g_uc = uc - L5.uc

gen elast = g_uc/g_uy
keep if year == 2013

keep large g_uc g_uy elast

gen ty = "large region"
gen episode = "Spain"

tempfile spain
save `spain' , replace

** MEXICO

u "$database/resid_MEX.dta", clear

rename EDAD age

keep ESTRATO year uy uc ly lc age freqwt probwt

* region

gen large = .
replace large = 1 if ESTRATO == 1
replace large = 0 if ESTRATO == 2 | ESTRATO == 3

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year large)

replace uy = ln(uy)
replace uc = ln(uc)

xtset large year

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

keep large g_uc g_uy elast year

gen ty = "large region"
gen episode = "Mexico - Tequila"
replace episode = "Mexico - GFC" if year == 2010 
drop year

tempfile mexico
save `mexico' , replace

** PERU

u "$database/resid_PER.dta", clear

keep year uy uc ly lc estrato_ freqwt probwt

* region

drop if estrato_ == .

gen large = .
replace large = 1 if estrato_ == 1 | estrato_ == 2
replace large = 0 if estrato_ == 3 | estrato_ == 4 | estrato_ == 5 | estrato_ == 6
drop if large == .

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year large)

replace uy = ln(uy)
replace uc = ln(uc)

xtset large year

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy
keep if year == 2010

keep large g_uc g_uy elast

gen ty = "large region"
gen episode = "Peru"

*** TABLE WITH RESULTS ***

append using `mexico'
append using `spain'
append using `italy'

sum elast if large == 0
local elast_1 = r(mean)

sum elast if large == 1
local elast_2 = r(mean)

** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "& Large Population &" in `row'
replace tc2 = " & " + string(elast[10],"%9.2f") in `row'
replace tc3 = " & " + string(elast[8],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[5],"%9.2f") in `row'
replace tc6 = " & " + string(elast[6],"%9.2f") in `row'
replace tc7 = " & " + string(elast[2],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_2',"%9.2f") in `row'

local ++row
replace tc1 = "& Low Population &" in `row'
replace tc2 = " & " + string(elast[9],"%9.2f") in `row'
replace tc3 = " & " + string(elast[7],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[3],"%9.2f") in `row'
replace tc6 = " & " + string(elast[4],"%9.2f") in `row'
replace tc7 = " & " + string(elast[1],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_1',"%9.2f") in `row'
replace tc10 = "& \hspace{-1em} \vspace{.5em}" in `row'

outsheet tc* in 1/`row' using "$output/table2_e.tex", noquote nonames delimit(" ") replace

