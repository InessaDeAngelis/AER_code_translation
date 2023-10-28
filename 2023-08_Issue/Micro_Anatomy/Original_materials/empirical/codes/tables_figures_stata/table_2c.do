**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table 1 panel c: Elasticities by age group
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
 ******* Table 2 panel - Age *******
 **********************************************
 
** ITALY

u "$database/resid_ITA.dta", clear

* key variables

keep year uy uc ly lc age freqwt probwt

* age groups
 
drop if age == .

gen age_g = 1
replace age_g = 2 if age>35
replace age_g = 3 if age>50

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year age_g)

replace uy = ln(uy)
replace uc = ln(uc)

xtset age_g year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014

keep age_g g_uc g_uy elast

gen ty = "age"
gen episode = "Italy"

tempfile italy
save `italy' , replace

** SPAIN

u "$database/resid_SPA.dta", clear

rename edadsp age

keep year uy uc ly lc freqwt age probwt
 
* age groups
 
drop if age == .

gen age_g = 1
replace age_g = 2 if age>35
replace age_g = 3 if age>50

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year age_g)

replace uy = ln(uy)
replace uc = ln(uc)

xtset age_g year

gen g_uy = uy - L5.uy
gen g_uc = uc - L5.uc

gen elast = g_uc/g_uy
keep if year == 2013

keep age_g g_uc g_uy elast

gen ty = "age"
gen episode = "Spain"

tempfile spain
save `spain' , replace

** MEXICO

u "$database/resid_MEX.dta", clear

rename EDAD age

keep year uy uc ly lc age freqwt probwt

* age groups
 
drop if age == .

gen age_g = 1
replace age_g = 2 if age>35
replace age_g = 3 if age>50

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year age_g)

replace uy = ln(uy)
replace uc = ln(uc)

xtset age_g year

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

keep age_g g_uc g_uy elast year

gen ty = "age"
gen episode = "Mexico - Tequila"
replace episode = "Mexico - GFC" if year == 2010 
drop year

tempfile mexico
save `mexico' , replace

** PERU

u "$database/resid_PER.dta", clear

keep year uy uc ly lc age freqwt probwt

* age groups
 
drop if age == .

gen age_g = 1
replace age_g = 2 if age>35
replace age_g = 3 if age>50

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year age_g)

replace uy = ln(uy)
replace uc = ln(uc)

xtset age_g year

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy
keep if year == 2010

keep age_g g_uc g_uy elast

gen ty = "age"
gen episode = "Peru"

*** TABLE WITH RESULTS ***

append using `mexico'
append using `spain'
append using `italy'

sum elast if age_g == 1
local elast_1 = r(mean)

sum elast if age_g == 2
local elast_2 = r(mean)

sum elast if age_g == 3
local elast_3 = r(mean)

** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "& $\leq$ 35 &" in `row'
replace tc2 = " & " + string(elast[13],"%9.2f") in `row'
replace tc3 = " & " + string(elast[10],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[4],"%9.2f") in `row'
replace tc6 = " & " + string(elast[5],"%9.2f") in `row'
replace tc7 = " & " + string(elast[1],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_1',"%9.2f") in `row'

local ++row
replace tc1 = "& 35 $>$ and $\leq$ 50 &" in `row'
replace tc2 = " & " + string(elast[14],"%9.2f") in `row'
replace tc3 = " & " + string(elast[11],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[6],"%9.2f") in `row'
replace tc6 = " & " + string(elast[7],"%9.2f") in `row'
replace tc7 = " & " + string(elast[2],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_2',"%9.2f") in `row'

local ++row
replace tc1 = "& $>$ 50 &" in `row'
replace tc2 = " & " + string(elast[15],"%9.2f") in `row'
replace tc3 = " & " + string(elast[12],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[8],"%9.2f") in `row'
replace tc6 = " & " + string(elast[9],"%9.2f") in `row'
replace tc7 = " & " + string(elast[3],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_3',"%9.2f") in `row'
replace tc10 = "& \hspace{-1em} \vspace{.5em}" in `row'

outsheet tc* in 1/`row' using "$output/table2_c.tex", noquote nonames delimit(" ") replace

