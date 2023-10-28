**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table B9 panel b
* elasticities of low-elasticity HHs
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


 *********************************************
 ******* Table B11 Low-Elasticity HHs ********
 *********************************************

** ITALY

* elasticities using panel data (same households across deciles)

u "$database/resid_ITA.dta", clear

replace uy = ln(uy)
replace uc = ln(uc)

xtset nquest year

gen g_uy = uy - L2.uy
gen g_uc = uc - L2.uc
gen elast = g_uc/g_uy

gen sample = 0
replace sample = 1 if elast>0 & elast!=.
replace sample = 1 if F2.elast>0 & F2.elast!=.

keep if sample == 1

xtile deci = elast if elast>0 & elast!=. [fw=pesopop_r] , nq(2)

local year = "1998 2000 2002 2004 2006 2008 2010 2012 2014 2016" 
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=pesopop_r] , nq(2)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

egen deci_f = max(deci), by(nquest)
drop deci
rename deci_f deci

replace uy = exp(uy)
replace uc = exp(uc)

*low elasticity HHs only
keep if deci == 1

tempfile main_data
save `main_data', replace

collapse(mean) uc uy (sum) count , by(year deci decile)

replace uy = ln(uy)
replace uc = ln(uc)

egen dec_dec = group(deci decile)

xtset dec_dec year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014

*top half income HHs only
keep if decile == 2

keep g_uc g_uy elast

gen episode = "Italy"

gen categ = "top"

tempfile decile_data
save `decile_data', replace

u `main_data', replace

collapse(mean) uc uy (sum) count , by(year deci)

replace uy = ln(uy)
replace uc = ln(uc)

xtset deci year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014

keep g_uc g_uy elast

gen episode = "Italy"

gen categ = "all"

append using `decile_data'

tempfile ITA
save `ITA', replace

** PER

u "$database/resid_PER.dta", clear

replace uy = ln(uy)
replace uc = ln(uc)

gen id_HH = conglome_ + vivienda_ + hogar

** keep panel sample for 2007-2011

replace id_HH = substr(id_HH,3,.) if year>=2011
egen id_HH_n = group(id_HH)

drop if year < 2007
drop if year > 2011

xtset id_HH_n year

gen g_uy = uy - L2.uy
gen g_uc = uc - L2.uc
gen elast = g_uc/g_uy

gen sample = 0
replace sample = 1 if elast>0 & elast!=.
replace sample = 1 if F2.elast>0 & F2.elast!=.

keep if sample == 1

xtile deci = elast if elast>0 & elast!=. , nq(2)

egen deci_f = max(deci), by(id_HH_n)
drop deci
rename deci_f deci

local year = "2007 2008 2009 2010 2011" 
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' , nq(2)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

replace uy = exp(uy)
replace uc = exp(uc)

*low elasticity HHs only
keep if deci == 1

tempfile main_data
save `main_data', replace

collapse(mean) uc uy (sum) count , by(year deci decile)

replace uy = ln(uy)
replace uc = ln(uc)

egen dec_dec = group(deci decile)

xtset dec_dec year

gen sample = count + L3.count

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy
keep if year == 2010

*top half income HHs only
keep if decile == 2

keep elast g_uc g_uy

gen episode = "Peru"

gen categ = "top"

tempfile decile_data
save `decile_data', replace

u `main_data', replace

collapse(mean) uc uy (sum) count , by(year deci)

replace uy = ln(uy)
replace uc = ln(uc)

xtset deci year

gen sample = count + L3.count

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy
keep if year == 2010
keep elast g_uc g_uy

gen episode = "Peru"

gen categ = "all"

append using `decile_data'

append using `ITA'

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


*** TABLE D10 A - Low-Elasticity HHs

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
replace tc3 = " & " + string(g_uy[3],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(g_uy[1],"%9.2f") in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`g_uy_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(g_uy[4],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(g_uy[2],"%9.2f") in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`g_uy_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{$\Delta \log C$}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(g_uc[3],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(g_uc[1],"%9.2f") in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`g_uc_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(g_uc[4],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(g_uc[2],"%9.2f") in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`g_uc_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{Elasticity}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(elast[3],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[1],"%9.2f") in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`elast_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(elast[4],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[2],"%9.2f") in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`elast_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

outsheet tc* in 1/`row' using "$output/tableB11_a.tex", noquote nonames delimit(" ") replace


*** TABLE D9 - OBSERVATIONS

u "$database/resid_ITA.dta", clear

keep if year>= 2006 & year<=2014
xtset nquest year
egen count_f = sum(count), by(nquest)
keep if count_f == 5

sum year if year == 2014 | year == 2006
local obs_ITA = r(N)

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
local obs_PER = r(N)

** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local obs_TOT = `obs_ITA' + `obs_PER'

local ++row
replace tc1 = "& \multicolumn{2}{l}{N Observations} \vspace{.2em}" in `row'
replace tc2 = " & " + string(`obs_ITA',"%9.0fc") in `row'
replace tc3 = "& \hspace{.5em}"  in `row'
replace tc4 = " & " + string(`obs_PER',"%9.0fc") in `row'
replace tc5 = " & " in `row'
replace tc6 = " & " + string(`obs_TOT',"%9.0fc") in `row'

outsheet tc* in 1/`row' using "$output/tableB11_c.tex", noquote nonames delimit(" ") replace


