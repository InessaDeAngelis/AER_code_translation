**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table 1 panel b
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
 ******* Table 1 panel - All Households *******
 **********************************************
 
** ITALY

global input_data_ITA  = "$input/ITA/storico_stata"

* wealth data

u "$input_data_ITA/ricf.dta", clear

gen liq_wealth = af - pf
drop if liq_wealth == .

keep nquest anno liq_wealth

tempfile wealth_data
save `wealth_data', replace

* merge income and consumption with wealth data

u "$database/resid_ITA.dta", clear

rename year anno
merge m:1 nquest anno using `wealth_data'
keep if _merge == 3
drop _merge
rename anno year 

gen liq_y = liq_wealth/(income/12)
drop if liq_y == .
gen liq_y_aux = liq_y
replace liq_y_aux = -10 if liq_y<-10 & liq_y!=.
replace liq_y_aux = 10 if  liq_y>10 & liq_y!=.
gen htm = (liq_y<.5)                                /* identify HtM households */

keep year uy uc ly lc freqwt probwt htm
keep if htm == 0
 
tempfile sample_data
save `sample_data', replace

* elasticities by decile

u `sample_data', clear

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

tempfile ITA
save `ITA', replace

** SPAIN

u "$database/resid_SPA.dta", clear

* liquid assets holdings

merge 1:1 year numero using "$database/SPA/SPA_wealth.dta", keepusing(liq_hold nhtm wealth)  /* HtM households in Spanish using data from EFF */
drop if _merge == 2

gen fina = (nhtm>=.5 & nhtm!=.)
drop if nhtm == .

keep year uy uc ly lc freqwt probwt fina

keep if fina == 1
 
tempfile sample_data
save `sample_data', replace

* Deciles data

local year = "2008 2013" 
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

gen g_uy = uy - L5.uy
gen g_uc = uc - L5.uc

gen elast = g_uc/g_uy

keep if year == 2013

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

gen g_uy = uy - L5.uy
gen g_uc = uc - L5.uc

gen elast = g_uc/g_uy

keep if year == 2013

keep elast g_uy g_uc year

gen categ = "all"

append using `top'

drop year
gen episode = "Spain"

tempfile SPA
save `SPA', replace

** MEX

u "$database/resid_MEX.dta", clear

* liquid assets

merge 1:1 year FOLIO using  "$database/MEX/MEX_wealth.dta"  /* HH with liquid asset holding id using financial income data */
drop if _merge == 2
drop _merge

keep if fina == 1

* key variables

keep year uy uc ly lc freqwt probwt
 
tempfile sample_data
save `sample_data', replace

* Deciles data

local year = "1994 1996 2006 2010" 
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

gen g_uy = uy - L2.uy
gen g_uc = uc - L2.uc

gen elast = g_uc/g_uy

gen g_uy2 = uy - L4.uy
gen g_uc2 = uc - L4.uc

gen elast2 = g_uc2/g_uy2

keep if year == 1996 | year == 2010

replace elast = elast2 if year == 2010
replace g_uc = g_uc2 if year == 2010
replace g_uy = g_uy2 if year == 2010
keep elast g_uc g_uy decile year

keep if decile == 10
gen episode = "Mexico - Tequila" if year == 1996
replace episode = "Mexico - GFC" if year == 2010
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

gen g_uy = uy - L2.uy
gen g_uc = uc - L2.uc

gen elast = g_uc/g_uy

gen g_uy2 = uy - L4.uy
gen g_uc2 = uc - L4.uc

gen elast2 = g_uc2/g_uy2

keep if year == 1996 | year == 2010

replace elast = elast2 if year == 2010
replace g_uc = g_uc2 if year == 2010
replace g_uy = g_uy2 if year == 2010
keep elast g_uc g_uy year

gen episode = "Mexico - Tequila" if year == 1996
replace episode = "Mexico - GFC" if year == 2010
drop year

gen categ = "all"

append using `top'

tempfile MEX
save `MEX', replace

*** PER 

u "$database/resid_PER.dta", clear

* liquid assets
gen year_n = year
tostring year_n, replace
gen id_HH = year_n + conglome_ + vivienda_ + hogar

merge 1:1 year_n id_HH using "$database/PER/PER_wealth.dta"

destring year_n, gen(year_naux)
drop year_n

* liquid assets

drop if _merge == 2
drop _merge

gen fina = 0
replace fina = 1 if finb == 1
replace fina = 1 if stocksb == 1
replace fina = 1 if depb == 1

keep if fina == 1

* key variables

keep year uy uc ly lc freqwt probwt
 
tempfile sample_data
save `sample_data', replace

* Deciles data

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

tempfile PER
save `PER', replace

*** Table 1 - b

append using `MEX'
append using `SPA'
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
replace tc3 = " & " + string(g_uy[9],"%9.2f") in `row'
replace tc4 = " & " + string(g_uy[7],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(g_uy[3],"%9.2f") in `row'
replace tc7 = " & " + string(g_uy[4],"%9.2f") in `row'
replace tc8 = " & " + string(g_uy[1],"%9.2f") in `row'
replace tc9 = " & " in `row'
replace tc10 = " & " + string(`g_uy_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(g_uy[10],"%9.2f") in `row'
replace tc4 = " & " + string(g_uy[8],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(g_uy[5],"%9.2f") in `row'
replace tc7 = " & " + string(g_uy[6],"%9.2f") in `row'
replace tc8 = " & " + string(g_uy[2],"%9.2f") in `row'
replace tc9 = " & " in `row'
replace tc10 = " & " + string(`g_uy_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{$\Delta \log C$}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(g_uc[9],"%9.2f") in `row'
replace tc4 = " & " + string(g_uc[7],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(g_uc[3],"%9.2f") in `row'
replace tc7 = " & " + string(g_uc[4],"%9.2f") in `row'
replace tc8 = " & " + string(g_uc[1],"%9.2f") in `row'
replace tc9 = " & " in `row'
replace tc10 = " & " + string(`g_uc_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(g_uc[10],"%9.2f") in `row'
replace tc4 = " & " + string(g_uc[8],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(g_uc[5],"%9.2f") in `row'
replace tc7 = " & " + string(g_uc[6],"%9.2f") in `row'
replace tc8 = " & " + string(g_uc[2],"%9.2f") in `row'
replace tc9 = " & " in `row'
replace tc10 = " & " + string(`g_uc_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{Elasticity}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(elast[9],"%9.2f") in `row'
replace tc4 = " & " + string(elast[7],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(elast[3],"%9.2f") in `row'
replace tc7 = " & " + string(elast[4],"%9.2f") in `row'
replace tc8 = " & " + string(elast[1],"%9.2f") in `row'
replace tc9 = " & " in `row'
replace tc10 = " & " + string(`elast_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(elast[10],"%9.2f") in `row'
replace tc4 = " & " + string(elast[8],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(elast[5],"%9.2f") in `row'
replace tc7 = " & " + string(elast[6],"%9.2f") in `row'
replace tc8 = " & " + string(elast[2],"%9.2f") in `row'
replace tc9 = " & " in `row'
replace tc10 = " & " + string(`elast_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

outsheet tc* in 1/`row' using "$output/table1_b.tex", noquote nonames delimit(" ") replace

