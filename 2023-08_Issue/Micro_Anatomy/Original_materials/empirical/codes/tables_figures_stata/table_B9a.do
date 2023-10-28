**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table B9 income change, observations and
* elasticities of tradable goods consumption
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


 *************************************
 ******* Table B9 - Tradable  ********
 *************************************

** SPAIN

global input_data_SPA = "$input/SPA"

* compute tradable basket

local year = "2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018"
foreach y of local year {

use "$database/SPA/gastos`y'", clear

keep if trade == 1 | non_trade == 1

collapse(sum) gastmon, by(numero trade)

reshape wide gastmon, i(numero) j(trade)

replace gastmon1 = 0 if gastmon1==.
replace gastmon0 = 0 if gastmon0==.

rename gastmon1 trade
rename gastmon0 ntrade

gen year = `y'

tempfile data_`y'
save `data_`y'', replace

}

local year = "2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"

foreach y of local year {
append using `data_`y''
}

merge 1:1 year numero using "$database/baseline_SPA.dta"
drop if _merge == 1
drop _merge

merge m:1 year using "$input_data_SPA/CPI.dta"
drop if _merge==2
drop _merge

replace ntrade=ntrade/(factor*12)
replace trade=trade/(factor*12)

gen inc = impexac
gen cons = trade

replace inc=inc/CPI
replace cons = cons/CPI

gen ly=ln(inc)
gen lc=ln(cons)

** regression for residual income and consumption

gen edadsp2 = edadsp^2
qui tab estudred_sp , gen(estudb)
qui tab sexosp , gen(sexob)
qui tab nmiemb , gen(nmiembb)
qui tab ccaa , gen(ccaab)

gen yeducb1 = estudb1*year
gen yeducb2 = estudb2*year
gen yeducb3 = estudb3*year
gen yeducb4 = estudb4*year

gen ysexob1 = sexob1*year
gen ysexob2 = sexob2*year

qui tab tamamu , gen(tamamub)

reg ly edadsp2 edadsp estudb* sexob* nmiembb* yeducb* ysexob* tamamub* year [aw=factor]
predict uy if e(sample),res
*ccaab*

reg lc edadsp2 edadsp estudb* sexob* nmiembb* yeducb* ysexob* tamamub* year [aw=factor]
predict uc if e(sample),res
*ccaab* 

replace uy = exp(uy)
replace uc = exp(uc)

gen freqwt = factor_r 
egen sum_freqwt = total(freqwt), by(year)
gen probwt = freqwt/sum_freqwt

keep year uy uc freqwt probwt
 
tempfile sample_data
save `sample_data', replace

* Data by decile

u `sample_data', clear

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

* compute tradable expenditure

local yearl = "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014"

foreach x of local yearl {

use "$database/MEX/basket`x'.dta", replace

keep if serv == 1

gen year = `x'

collapse(sum) GAS_TRI, by(FOLIO year)

tempfile data_`x'
save `data_`x'', replace

}

local yearl = "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012"

foreach x of local yearl {

append using `data_`x''

}

merge 1:1 year FOLIO using "$database/baseline_MEX.dta" 
drop if year == 2005
drop if _merge == 2
drop if _merge == 1
drop _merge

replace GAS_TRI = GAS_TRI/1000 if year ==1992

merge m:1 year using "$input/MEX/CPI.dta", nogenerate
drop if GASCOR==.

foreach x of varlist GASCOR INGCOR GASMON RENTA INGMON GAS_TRI {
replace `x'=`x'/index
}

gen income = INGMON - RENTA
gen consum = GASMON - GAS_TRI
replace consum = round(consum) if consum<0 & consum!=.

gen ly = ln(income)
gen lc = ln(consum)

* residualize income and consumption

gen EDAD2 = EDAD^2
qui tab EDUC , gen(EDUCb)
qui tab SEX , gen(SEXb)
qui tab TAM_HOG , gen(TAM_HOGb)
qui tab ESTRATO , gen(ESTRATOb)

gen YEDUCb1 = EDUCb1*year
gen YEDUCb2 = EDUCb2*year
gen YEDUCb3 = EDUCb3*year

gen YSEXb1 = SEXb1*year
gen YSEXb2 = SEXb2*year

reg ly EDAD EDAD2 SEXb* EDUCb* ESTRATOb* YEDUCb* TAM_HOGb* YSEXb*  year [aw=HOG]
predict uy if e(sample),res

reg lc EDAD EDAD2 SEXb* EDUCb* ESTRATOb* YEDUCb* TAM_HOGb* YSEXb*  year [aw=HOG]
predict uc if e(sample),res

replace ly = ln(income) - ln(TAM_HOG)
replace lc = ln(consum) - ln(TAM_HOG)

replace uy = exp(uy)
replace uc = exp(uc)

gen HOG_r  = round(HOG)
gen freqwt = HOG_r 
egen sum_freqwt = total(freqwt), by(year)
gen probwt = freqwt/sum_freqwt

keep year uy uc freqwt probwt
 
tempfile sample_data
save `sample_data', replace

* Data by decile

u `sample_data', clear

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

append using `SPA'

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


*** TABLE B9 - Income

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
replace tc3 = " & " + string(g_uy[5],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(g_uy[1],"%9.2f") in `row'
replace tc6 = " & " + string(g_uy[2],"%9.2f") in `row'
replace tc7 = " & " in `row'
replace tc8 = " & " + string(`g_uy_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(g_uy[6],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(g_uy[3],"%9.2f") in `row'
replace tc6 = " & " + string(g_uy[4],"%9.2f") in `row'
replace tc7 = " & " in `row'
replace tc8 = " & " + string(`g_uy_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

outsheet tc* in 1/`row' using "$output/tableB9_a.tex", noquote nonames delimit(" ") replace


*** TABLE B9 - Tradable Consumption

u `MEX', clear
append using `SPA'

** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0


local ++row
replace tc1 = "& \multirow{2}{*}{$\Delta \log C$}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(g_uc[5],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(g_uc[1],"%9.2f") in `row'
replace tc6 = " & " + string(g_uc[2],"%9.2f") in `row'
replace tc7 = " & " in `row'
replace tc8 = " & " + string(`g_uc_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(g_uc[6],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(g_uc[3],"%9.2f") in `row'
replace tc6 = " & " + string(g_uc[4],"%9.2f") in `row'
replace tc7 = " & " in `row'
replace tc8 = " & " + string(`g_uc_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{Elasticity}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(elast[5],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[1],"%9.2f") in `row'
replace tc6 = " & " + string(elast[2],"%9.2f") in `row'
replace tc7 = " & " in `row'
replace tc8 = " & " + string(`elast_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(elast[6],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[3],"%9.2f") in `row'
replace tc6 = " & " + string(elast[4],"%9.2f") in `row'
replace tc7 = " & " in `row'
replace tc8 = " & " + string(`elast_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

outsheet tc* in 1/`row' using "$output/tableB9_b.tex", noquote nonames delimit(" ") replace


*** TABLE B9 - OBSERVATIONS

u "$database/baseline_SPA.dta", clear

sum year if year == 2013 | year == 2008
local obs_SPA = r(N)

u "$database/baseline_MEX.dta", clear

sum year if year == 1996 | year == 1994
local obs_MEX_T = r(N)

sum year if year == 2010 | year == 2006
local obs_MEX_L = r(N)

** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local obs_TOT = `obs_SPA' + `obs_MEX_T' + `obs_MEX_L'

local ++row
replace tc1 = "& \multicolumn{2}{l}{N Observations} \vspace{.2em}" in `row'
replace tc2 = " & " + string(`obs_SPA',"%9.0fc") in `row'
replace tc3 = "& \hspace{.5em}"  in `row'
replace tc4 = " & " + string(`obs_MEX_T',"%9.0fc") in `row'
replace tc5 = " & " + string(`obs_MEX_L',"%9.0fc") in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`obs_TOT',"%9.0fc") in `row'

outsheet tc* in 1/`row' using "$output/tableB9_f.tex", noquote nonames delimit(" ") replace
