**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table B4 - panel d
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

 *************************************************************************
 **** Table B4 panel - Including All Monetary and Non-Monetary Items *****
 *************************************************************************
 
** ITALY

u "$database/baseline_ITA.dta", clear

* merging CPI
merge m:1 anno using "$input/ITA/storico_stata/defl.dta"
keep if _merge == 3
drop _merge

replace income = income + yca2 + yl2
replace consum = cn

replace income = income*rival
replace consum = consum*rival

* non-residualized

gen ly = ln(income) - ln(hhsize)
gen lc = ln(consum) - ln(hhsize)

* resid
rename anno year
gen age2 = age^2
tab sesso, gen(sessob)

gen educ = .
replace educ = 1 if studio == 1 | studio == 2
replace educ = 2 if studio == 3
replace educ = 3 if studio == 4
replace educ = 4 if studio == 5 | studio == 6
tab educ, gen(educb)

qui tab hhsize, gen(hhsizeb)
gen lhsize = ln(hhsize)

qui tab region, gen(regionb)
qui tab estrato, gen(estratob)

gen yeducb1 = educb1*year
gen yeducb2 = educb2*year
gen yeducb3 = educb3*year
gen yeducb4 = educb4*year

gen ysexb1 = sessob1*year
gen ysexb2 = sessob2*year

reg ly sessob* age age2 educb* ysexb* estratob* yeducb*  year [aw=pesopop]
predict uy if e(sample),res
*regionb*

reg lc  sessob* age age2 educb* ysexb* estratob* yeducb* year [aw=pesopop]
predict uc if e(sample),res 
*regionb*

replace uy = exp(uy)
replace uc = exp(uc)

gen pesopop_r = round(pesopop)
gen freqwt = pesopop_r 
egen sum_freqwt = total(freqwt), by(year)
gen probwt = freqwt/sum_freqwt


tempfile sample_data
save `sample_data', replace

local year = "2006 2014" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(20)
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

keep if decile == 20
drop decile

gen categ = "top5"

tempfile top5
save `top5', replace

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
append using `top5'

drop year
gen episode = "Italy"

tempfile ITA
save `ITA', replace

** SPAIN

u "$database/baseline_SPA.dta", clear

merge m:1 year using "$input/SPA/CPI.dta"
drop if _merge==2
drop _merge

gen inc = impexac + (gastot - gastmon)
gen cons = gastot

replace inc=inc/CPI
replace cons=cons/CPI

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

tempfile sample_data
save `sample_data', replace

local year = "2008 2013" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(20)
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

keep if decile == 20
drop decile

gen categ = "top5"

tempfile top5
save `top5', replace

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
append using `top5'

drop year
gen episode = "Spain"

tempfile SPA
save `SPA', replace

** MEX

u "$database/baseline_MEX.dta", clear

merge m:1 year using "$input/MEX/CPI.dta", nogenerate
drop if GASCOR==.

foreach x of varlist GASCOR INGCOR GASMON RENTA INGMON GAS_TRI {
replace `x'=`x'/index
}

gen income = INGCOR
gen consum = GASMON

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

replace uy = exp(uy)
replace uc = exp(uc)

gen HOG_r  = round(HOG)
gen freqwt = HOG_r 
egen sum_freqwt = total(freqwt), by(year)
gen probwt = freqwt/sum_freqwt

tempfile sample_data
save `sample_data', replace

local year = "1994 1996 2006 2010" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(20)
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

keep if decile == 20
gen episode = "Mexico - Tequila" if year == 1996
replace episode = "Mexico - GFC" if year == 2010
drop year

drop decile

gen categ = "top5"

tempfile top5
save `top5', replace

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
append using `top5'

tempfile MEX
save `MEX', replace

*** PER 

u "$database/baseline_PER.dta", clear

destring year_n, replace

* income and consumption definition
gen inc = inghog2d_/CPI_index
gen consu = gashog2d_/CPI_index

gen ly = ln(inc)
gen lc = ln(consu)

*residual income and consumption

gen educ2 = .
replace educ2 = 1 if educ<=4
replace educ2 = 2 if educ>4 & educ<=6
replace educ2 = 3 if educ>6

qui tab(educ2), gen(educ2b)
qui tab(sex), gen(sexb)
qui tab(mstatus), gen(mstatusb)
qui tab(mieperho_), gen(mieperhob)
qui tab(dominio), gen(dominiob)
qui tab(estrato_), gen(estratob)
gen size_large = (estrato_<=2)
gen age2 = age^2

gen yeducb1 = educ2b1*year_n
gen yeducb2 = educ2b2*year_n
gen yeducb3 = educ2b3*year_n

gen ysexb1 = sexb1*year_n
gen ysexb2 = sexb2*year_n

gen year_t = year_n
replace year_t = 0 if year_n>2007

reg ly age age2 sexb* educ2b* mieperhob* size_large ysexb* yeducb* year_t year_n [aw=factor07_]
predict uy if e(sample),res
*estratob*
*dominiob*

reg lc age age2 sexb* educ2b* mieperhob* size_large ysexb* yeducb* year_t year_n [aw=factor07_]
predict uc if e(sample),res
*estratob*
*dominiob*

replace uy = exp(uy)
replace uc = exp(uc)

gen freqwt = factor07_r 
egen sum_freqwt = total(freqwt), by(year)
gen probwt = freqwt/sum_freqwt

drop year 
rename year_n year

tempfile sample_data
save `sample_data', replace

local year = "2007 2010" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(20)
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

keep if decile == 20
gen episode = "Peru"
drop year

drop decile

gen categ = "top5"

tempfile top5
save `top5', replace

u `sample_data', clear

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
append using `top5'

tempfile PER
save `PER', replace

append using `MEX'
append using `SPA'
append using `ITA'

sum g_uy if categ == "all"
local g_uy_all_mean = r(mean)
sum g_uy if categ == "top"
local g_uy_top_mean = r(mean)
sum g_uy if categ == "top5"
local g_uy_top5_mean = r(mean)

sum g_uc if categ == "all"
local g_uc_all_mean = r(mean)
sum g_uc if categ == "top"
local g_uc_top_mean = r(mean)
sum g_uc if categ == "top5"
local g_uc_top5_mean = r(mean)

sum elast if categ == "all"
local elast_all_mean = r(mean)
sum elast if categ == "top"
local elast_top_mean = r(mean)
sum elast if categ == "top5"
local elast_top5_mean = r(mean)

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
replace tc3 = " & " + string(g_uy[13],"%9.2f") in `row'
replace tc4 = " & " + string(g_uy[10],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(g_uy[4],"%9.2f") in `row'
replace tc7 = " & " + string(g_uy[5],"%9.2f") in `row'
replace tc8 = " & " + string(g_uy[1],"%9.2f") in `row'
replace tc9 = " & " in `row'
replace tc10 = " & " + string(`g_uy_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(g_uy[14],"%9.2f") in `row'
replace tc4 = " & " + string(g_uy[11],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(g_uy[6],"%9.2f") in `row'
replace tc7 = " & " + string(g_uy[7],"%9.2f") in `row'
replace tc8 = " & " + string(g_uy[2],"%9.2f") in `row'
replace tc9 = " & " in `row'
replace tc10 = " & " + string(`g_uy_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{$\Delta \log C$}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(g_uc[13],"%9.2f") in `row'
replace tc4 = " & " + string(g_uc[10],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(g_uc[4],"%9.2f") in `row'
replace tc7 = " & " + string(g_uc[5],"%9.2f") in `row'
replace tc8 = " & " + string(g_uc[1],"%9.2f") in `row'
replace tc9 = " & " in `row'
replace tc10 = " & " + string(`g_uc_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(g_uc[14],"%9.2f") in `row'
replace tc4 = " & " + string(g_uc[11],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(g_uc[6],"%9.2f") in `row'
replace tc7 = " & " + string(g_uc[7],"%9.2f") in `row'
replace tc8 = " & " + string(g_uc[2],"%9.2f") in `row'
replace tc9 = " & " in `row'
replace tc10 = " & " + string(`g_uc_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{Elasticity}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(elast[13],"%9.2f") in `row'
replace tc4 = " & " + string(elast[10],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(elast[4],"%9.2f") in `row'
replace tc7 = " & " + string(elast[5],"%9.2f") in `row'
replace tc8 = " & " + string(elast[1],"%9.2f") in `row'
replace tc9 = " & " in `row'
replace tc10 = " & " + string(`elast_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(elast[14],"%9.2f") in `row'
replace tc4 = " & " + string(elast[11],"%9.2f") in `row'
replace tc5 = "& \hspace{.5em}"  in `row'
replace tc6 = " & " + string(elast[6],"%9.2f") in `row'
replace tc7 = " & " + string(elast[7],"%9.2f") in `row'
replace tc8 = " & " + string(elast[2],"%9.2f") in `row'
replace tc9 = " & " in `row'
replace tc10 = " & " + string(`elast_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

outsheet tc* in 1/`row' using "$output/tableB4_d.tex", noquote nonames delimit(" ") replace
