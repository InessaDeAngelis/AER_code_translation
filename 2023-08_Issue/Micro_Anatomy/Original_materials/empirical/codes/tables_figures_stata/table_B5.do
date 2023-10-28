**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table B5 panels a and b
**********************************************************************


cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

grstyle clear
grstyle init
grstyle set plain, horizontal grid  

 **********************************************
 **** Table B5 Synthetic Cohort vs Panel *****
 **********************************************
 
** ITALY

* Synthetic cohort 
* Data by decile

u "$database/resid_ITA.dta", clear

tempfile sample_data
save `sample_data', replace

local year = "2006 2014" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy  [fw=freqwt], by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy

keep if year == 2014

keep elast g_uy g_uc decile year

keep if decile == 10
drop decile

gen categ = "top"

tempfile top
save `top', replace

u `sample_data', clear

collapse(mean) uc uy  [fw=freqwt], by(year)

replace uy = ln(uy)
replace uc = ln(uc)

tsset year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy

keep if year == 2014

keep elast g_uy g_uc year

gen categ = "all"

append using `top'

drop year
gen episode = "Italy"

tempfile ITA_sc
save `ITA_sc', replace

** ITALY

* Panel

u "$database/resid_ITA.dta", clear

* panel sample selection
keep if year>= 2006 & year<=2014
xtset nquest year
egen count_f = sum(count), by(nquest)
keep if count_f == 5

tempfile sample_data
save `sample_data', replace

egen uy_f = mean(uy), by(nquest)

xtile decile = uy_f , nq(10)

collapse(mean) uc uy  , by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy

keep if year == 2014

keep elast g_uy g_uc decile year

keep if decile == 10
drop decile

gen categ = "top"

tempfile top
save `top', replace

u `sample_data', clear

collapse(mean) uc uy  , by(year)

replace uy = ln(uy)
replace uc = ln(uc)

tsset year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy

keep if year == 2014

keep elast g_uy g_uc year

gen categ = "all"

append using `top'

drop year
gen episode = "Italy"

tempfile ITA_pl
save `ITA_pl', replace

*** PER 

* Synthetic cohort

* Deciles data

u "$database/resid_PER.dta", clear

tempfile sample_data
save `sample_data', replace

local year = "2007 2010" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy  [fw=freqwt], by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy

keep if year == 2010

keep elast g_uy g_uc decile year

keep if decile == 10
gen episode = "Peru"
drop year

drop decile

gen categ = "top"

tempfile top
save `top', replace

u `sample_data', clear

collapse(mean) uc uy  [fw=freqwt], by(year)

replace uy = ln(uy)
replace uc = ln(uc)

tsset year

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy

keep if year == 2010

keep elast g_uc g_uy year

gen episode = "Peru"
drop year

gen categ = "all"

append using `top'

tempfile PER_sc
save `PER_sc', replace

* Panel

u "$database/resid_PER.dta", clear

* panel sample selection during crisis
gen id_HH = conglome_ + vivienda_ + hogar
egen id_HH_n = group(id_HH)
xtset id_HH_n year
drop if year < 2007
drop if year > 2010
egen count_f = sum(count), by(id_HH_n)
keep if count_f == 4
drop count_f

tempfile sample_data
save `sample_data', replace

egen uy_f = mean(uy), by(id_HH_n)

xtile decile = uy_f , nq(10)

collapse(mean) uc uy  , by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy

keep if year == 2010

keep elast g_uy g_uc decile year

keep if decile == 10
gen episode = "Peru"
drop year

drop decile

gen categ = "top"

tempfile top
save `top', replace

u `sample_data', clear

collapse(mean) uc uy  , by(year)

replace uy = ln(uy)
replace uc = ln(uc)

tsset year

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy

keep if year == 2010

keep elast g_uc g_uy year

gen episode = "Peru"
drop year

gen categ = "all"

append using `top'

tempfile PER_pl
save `PER_pl', replace


*** TABLE 1 - A - ALL HOUSEHOLDS

append using `PER_sc'
append using `ITA_pl'
append using `ITA_sc'

sum g_uy if categ == "all"
local g_uy_all_mean = r(mean)
sum g_uy if categ == "top"
local g_uy_top_mean = r(mean)

sum g_uc if categ == "all"
local g_uc_all_mean = r(mean)
sum g_uc if categ == "top"
local g_uc_top_mean = r(mean)

sum elast if categ == "all"
local elast_all_mean = r(mean)
sum elast if categ == "top"
local elast_top_mean = r(mean)

** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "& \multirow{2}{*}{$\Delta \log Y$}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(g_uy[7],"%9.2f") in `row'
replace tc4 = " & " + string(g_uy[5],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(g_uy[3],"%9.2f") in `row'
replace tc7 = " & " + string(g_uy[1],"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(g_uy[8],"%9.2f") in `row'
replace tc4 = " & " + string(g_uy[6],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(g_uy[4],"%9.2f") in `row'
replace tc7 = " & " + string(g_uy[2],"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{$\Delta \log C$}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(g_uc[7],"%9.2f") in `row'
replace tc4 = " & " + string(g_uc[5],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(g_uc[3],"%9.2f") in `row'
replace tc7 = " & " + string(g_uc[1],"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(g_uc[8],"%9.2f") in `row'
replace tc4 = " & " + string(g_uc[6],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(g_uc[4],"%9.2f") in `row'
replace tc7 = " & " + string(g_uc[2],"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{Elasticity}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(elast[7],"%9.2f") in `row'
replace tc4 = " & " + string(elast[5],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(elast[3],"%9.2f") in `row'
replace tc7 = " & " + string(elast[1],"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(elast[8],"%9.2f") in `row'
replace tc4 = " & " + string(elast[6],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(elast[4],"%9.2f") in `row'
replace tc7 = " & " + string(elast[2],"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

outsheet tc* in 1/`row' using "$output/tableB5_a.tex", noquote nonames delimit(" ") replace


*** TABLE B5 - B - OBSERVATIONS

u "$database/baseline_ITA.dta", clear

rename anno year
sum year if year == 2014 | year == 2006
local obs_ITA_sc = r(N)

u "$database/resid_ITA.dta", clear

keep if year>= 2006 & year<=2014
xtset nquest year
egen count_f = sum(count), by(nquest)
keep if count_f == 5

sum year if year == 2014 | year == 2006
local obs_ITA_pl = r(N)

u "$database/baseline_PER.dta", clear

sum year_n if year_n == 2007 | year_n == 2010
local obs_PER_sc = r(N)

u "$database/resid_PER.dta", clear

gen id_HH = conglome_ + vivienda_ + hogar
egen id_HH_n = group(id_HH)
xtset id_HH_n year
drop if year < 2007
drop if year > 2010
egen count_f = sum(count), by(id_HH_n)
keep if count_f == 4
drop count_f

sum year if year == 2007 | year == 2010
local obs_PER_pl = r(N)

** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local obs_TOT = `obs_ITA_sc' + `obs_ITA_pl' + `obs_PER_sc' + `obs_PER_pl'

local ++row
replace tc1 = "& \multicolumn{2}{l}{N Observations} \vspace{.2em}" in `row'
replace tc2 = " & " + string(`obs_ITA_sc',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_ITA_pl',"%9.0fc") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(`obs_PER_sc',"%9.0fc") in `row'
replace tc6 = " & " + string(`obs_PER_pl',"%9.0fc") in `row'

outsheet tc* in 1/`row' using "$output/tableB5_b.tex", noquote nonames delimit(" ") replace

