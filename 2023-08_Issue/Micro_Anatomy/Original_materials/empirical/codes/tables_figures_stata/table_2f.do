**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table 1 panel f: Elasticities by sector of employment
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
 ******* Table 2 panel - Sectors *******
 **********************************************
 
** ITALY

global input_data_ITA  = "$input/ITA/storico_stata"

* employment sector

u "$input_data_ITA/comp.dta", clear

drop if settp11 == .
drop if settp11 == 11

gen sectors = .
replace sectors = 2 if settp11 == 2
replace sectors = 2 if settp11 == 3
replace sectors = 1 if settp11 == 1
replace sectors = 3 if sectors == .

keep if cfred == 1

keep nquest anno sectors
rename anno year

tempfile sectt
save `sectt' , replace

u "$database/resid_ITA.dta", clear

* key variables

keep year uy uc ly lc studio freqwt probwt nquest

* sectors
 
merge m:1 year nquest using `sectt'
drop if _merge == 2
drop _merge nquest
drop if sectors == .

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year sectors)

replace uy = ln(uy)
replace uc = ln(uc)

xtset sectors year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014

keep sectors g_uc g_uy elast

gen ty = "sectors"
gen episode = "Italy"

tempfile italy
save `italy' , replace

** SPAIN

* employment sector

global input_data_SPA = "$input/SPA"

local year = "08 13"

foreach y of local year {

use "$input_data_SPA/hog_`y'", clear

destring sitprof regten nuts1, replace

gen year = 2000 + `y'

if `y' == 06 | `y' == 07 | `y' == 08 {
gen sector_act = .
replace sector_act = 1 if actestb == "A" | actestb == "B"
replace sector_act = 2 if actestb == "C"
replace sector_act = 3 if actestb == "D"
replace sector_act = 4 if actestb == "E"
replace sector_act = 5 if actestb == "F"
replace sector_act = 6 if actestb == "G"
replace sector_act = 7 if actestb == "I"
replace sector_act = 8 if actestb == "H"
replace sector_act = 9 if actestb == "J"
replace sector_act = 10 if actestb == "K"
replace sector_act = 11 if actestb == "L"
replace sector_act = 12 if actestb == "M"
replace sector_act = 13 if actestb == "N"
replace sector_act = 14 if actestb == "O"
replace sector_act = 15 if actestb == "P"
}

if `y' == 09 | `y' == 10 | `y' == 11 | `y' == 12 | `y' == 13 | `y' == 14 | `y' == 15 {
gen sector_act = .
replace sector_act = 1 if actestb == "A"
replace sector_act = 2 if actestb == "B"
replace sector_act = 3 if actestb == "C"
replace sector_act = 4 if actestb == "D" | actestb == "E" 
replace sector_act = 5 if actestb == "F"
replace sector_act = 6 if actestb == "G"
replace sector_act = 7 if actestb == "H" | actestb == "J" 
replace sector_act = 8 if actestb == "I"
replace sector_act = 9 if actestb == "K"
replace sector_act = 10 if actestb == "L" | actestb == "M" | actestb == "N"
replace sector_act = 11 if actestb == "O"
replace sector_act = 12 if actestb == "P"
replace sector_act = 13 if actestb == "Q"
replace sector_act = 14 if actestb == "R" | actestb == "S"
replace sector_act = 15 if actestb == "T"
}

keep numero year sector_act

tempfile dat_`y'
save `dat_`y'',replace

}

append using `dat_08'

tempfile sectt
save `sectt', replace

u "$database/resid_SPA.dta", clear

keep year uy uc ly lc freqwt estudred_sp probwt numero
 
* sectors

merge 1:1 year numero using `sectt'
keep if _merge == 3
drop _merge numero

drop if sector_act == .

* 1 "Primary" 2 "Extractive" 3 "Manufacturing" 4 "Elect, gas & water" 5 "Construction" 6 "Retail" 7 "Transp. & comm." 8 "Hotel" 9 "Finance" 10 "Prof. serv" 11 "Public serv." 12 "Education" 13 "Social serv." 14 "Other serv." 15 "Home",

gen sectors = .
replace sectors = 2 if sector_act == 3 | sector_act == 5
replace sectors = 3 if sector_act >= 6 | sector_act == 4
replace sectors = 1 if sector_act <=2 & sector_act!=.

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year sectors)

replace uy = ln(uy)
replace uc = ln(uc)

xtset sectors year

gen g_uy = uy - L5.uy
gen g_uc = uc - L5.uc

gen elast = g_uc/g_uy
keep if year == 2013

keep sectors g_uc g_uy elast

gen ty = "sectors"
gen episode = "Spain"

tempfile spain
save `spain' , replace

** MEXICO

u "$database/resid_MEX.dta", clear

rename EDAD age

keep SEC year uy uc ly lc age freqwt probwt

* sectors

drop if SEC == .

* 1 "Primary" 2 "Extractive" 3 "Manufacturing" 4 "Elect, gas & water" 5 "Construction" 6 "Retail" 7 "Transp. & comm." 8 "Priv. services" 9 "Other services"

gen sectors = 1  /*Other*/
replace sectors = 2 if SEC == 3 /*Manufacturing*/
replace sectors = 2 if SEC == 5 /*Construction*/
replace sectors = 3 if SEC >= 6 | SEC == 4 /*Services*/

drop SEC 

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year sectors)

replace uy = ln(uy)
replace uc = ln(uc)

xtset sectors year

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

keep sectors g_uc g_uy elast year

gen ty = "sectors"
gen episode = "Mexico - Tequila"
replace episode = "Mexico - GFC" if year == 2010 
drop year

tempfile mexico
save `mexico' , replace

** PERU

global input_PER = "$input/PER"

u "$database/PER/PER_Cdata_charact.dta", clear      /* load dataset with more characteristics (e.g., ownership) for Peru */

keep year uy uc ly lc sector freqwt probwt

* educ groups

drop if sector == .

gen sectors = .
replace sectors = 1 if sector<=1429                /*primary*/
replace sectors = 2 if sector>=1511 & sector<=3720 /*manufactura*/
replace sectors = 1 if sector>=4010 & sector<=4100 /*primary*/
replace sectors = 2 if sector>=4510 & sector<=4550 /*construction*/
replace sectors = 3 if sector>=5010 & sector<=9900 /*services*/

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year sectors)

replace uy = ln(uy)
replace uc = ln(uc)

xtset sectors year

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy
keep if year == 2010

keep sectors g_uc g_uy elast

gen ty = "sectors"
gen episode = "Peru"

*** TABLE WITH RESULTS ***

append using `mexico'
append using `spain'
append using `italy'

sum elast if sectors == 1
local elast_1 = r(mean)

sum elast if sectors == 2
local elast_2 = r(mean)

sum elast if sectors == 3
local elast_3 = r(mean)

** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "& Primary &" in `row'
replace tc2 = " & " + string(elast[13],"%9.2f") in `row'
replace tc3 = " & " + string(elast[10],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[4],"%9.2f") in `row'
replace tc6 = " & " + string(elast[5],"%9.2f") in `row'
replace tc7 = " & " + string(elast[1],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_1',"%9.2f") in `row'

local ++row
replace tc1 = "& Industry &" in `row'
replace tc2 = " & " + string(elast[14],"%9.2f") in `row'
replace tc3 = " & " + string(elast[11],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[6],"%9.2f") in `row'
replace tc6 = " & " + string(elast[7],"%9.2f") in `row'
replace tc7 = " & " + string(elast[2],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_2',"%9.2f") in `row'

local ++row
replace tc1 = "& Services &" in `row'
replace tc2 = " & " + string(elast[15],"%9.2f") in `row'
replace tc3 = " & " + string(elast[12],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[8],"%9.2f") in `row'
replace tc6 = " & " + string(elast[9],"%9.2f") in `row'
replace tc7 = " & " + string(elast[3],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_3',"%9.2f") in `row'
replace tc10 = "& \hspace{-1em} \vspace{.5em}" in `row'

outsheet tc* in 1/`row' using "$output/table2_f.tex", noquote nonames delimit(" ") replace

