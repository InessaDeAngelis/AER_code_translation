**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table B9 panel c
* elasticities of luxury goods consumption
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
 ******* Table B9 - Luxury ***********
 *************************************

** SPAIN

global input_data_SPA = "$input/SPA"

u "$database/baseline_SPA.dta", clear

merge m:1 year using "$input_data_SPA/CPI.dta"
drop if _merge==2
drop _merge

gen inc = impexac

replace inc=inc/CPI

gen ly=ln(inc)

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

gen freqwt = factor_r 
egen sum_freqwt = total(freqwt), by(year)
gen probwt = freqwt/sum_freqwt

* Deciles data

levelsof year , local(yearl)
gen decile = .
foreach x of local yearl {
xtile decile_`x' = uy if year == `x' [fw=factor_r] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

drop if decile == .

keep numero year decile factor_r

tempfile dec_data
save `dec_data', replace

* luxury goods

local year = "2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018"

foreach y of local year {

use "$database/SPA/gastos`y'", clear

keep if serv == 1 | ndurab == 1

drop categ1 categ2 categ3
gen categ1 = substr(codigo,1,2)
gen categ2 = substr(codigo,3,1)
gen categ3 = substr(codigo,4,1)

drop codigo
gen codigo = categ1 + categ2 + categ3

gen year = `y'

merge m:1 numero year using `dec_data'

keep if _merge == 3
drop _merge

drop if gastmon<0 & gastmon!=.
replace gastmon = 0 if gastmon == .

collapse(sum) gastmon (mean) factor_r decile, by(numero codigo year)
egen gastmon_tot = sum(gastmon), by(numero)
gen share = gastmon/gastmon_tot

gen count = 1 
egen count_cod = sum(count), by(codigo)
qui sum count_cod, detail
drop if count_cod<0.1*r(max)

gen top = (decile == 10)

collapse(mean) share [fw=factor_r], by(top codigo)

reshape wide share, i(codigo) j(top)

gen ratio = share1/share0
sort ratio

drop if ratio == 0
drop if ratio == .

* ratio
gen lux = (ratio>1.1)

keep codigo lux

tempfile id_lux
save `id_lux', replace

use "$database/SPA/gastos`y'", clear

drop categ1 categ2 categ3
gen categ1 = substr(codigo,1,2)
gen categ2 = substr(codigo,3,1)
gen categ3 = substr(codigo,4,1)

drop codigo
gen codigo = categ1 + categ2 + categ3

gen year = `y'

merge m:1 codigo using `id_lux'
keep if _merge == 3
drop _merge

collapse(sum) gastmon, by(numero lux)

reshape wide gastmon, i(numero) j(lux)

replace gastmon1 = 0 if gastmon1==.
replace gastmon0 = 0 if gastmon0==.

rename gastmon1 luxy
rename gastmon0 nluxy

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

merge m:1 year using "$input/SPA/CPI.dta"
drop if _merge==2
drop _merge

replace luxy=luxy/(factor*12)
replace nluxy=nluxy/(factor*12)

gen inc = impexac
gen cons = luxy

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

reg lc edadsp2 edadsp estudb* sexob* nmiembb* yeducb* ysexob* tamamub* year [aw=factor]
predict uc if e(sample),res

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

use "$database/baseline_MEX.dta", clear

merge m:1 year using "$input/MEX/CPI.dta", nogenerate
drop if GASCOR==.

foreach x of varlist GASCOR INGCOR GASMON RENTA INGMON {
replace `x'=`x'/index
}

gen income = INGMON - RENTA
gen ly = ln(income)

* residualize income

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

reg ly EDAD EDAD2 SEXb* EDUCb* TAM_HOGb* ESTRATOb* YEDUCb* YSEXb*  year [aw=HOG]
predict uy if e(sample),res

local year = "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014" 
gen HOG_r = round(HOG)
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=HOG_r] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}
drop if decile == .

keep decile FOLIO year HOG_r

tempfile deciles
save `deciles' , replace

* luxury and non-luxury goods

local year = "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014" 
foreach y of local year {

u `deciles' , clear

keep if year == `y'
merge 1:m FOLIO using "$database/MEX/basket`y'.dta"
keep if _merge == 3
drop _merge

collapse(sum) GAS_TRI [fw=HOG_r], by(decile CLAVE)

egen gast_dec = sum(GAS_TRI), by(decile)
gen s_gast = GAS_TRI/gast_dec
 
keep s_gast CLAVE decile

reshape wide s_gast , i(CLAVE) j(decile)

gen lux = .
replace lux = 1 if (1*s_gast5<s_gast10 & s_gast10!=. & s_gast5!=. )
replace lux = 0 if (1*s_gast5>=s_gast10 & s_gast10!=. & s_gast5!= .)

tempfile lux 
save `lux', replace

u "$database/MEX/basket`y'.dta", replace

merge m:1 CLAVE using `lux'
keep if _merge == 3
drop _merge

gen year = `y'

drop if lux == .

collapse(sum) GAS_TRI, by(FOLIO year lux)

reshape wide GAS_TRI, i(FOLIO year) j(lux)

tempfile data_`y'
save `data_`y'', replace

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

replace GAS_TRI0 = GAS_TRI0/1000 if year ==1992
replace GAS_TRI1 = GAS_TRI1/1000 if year ==1992

rename GAS_TRI0 nlux
rename GAS_TRI1 lux

merge m:1 year using "$input/MEX/CPI.dta", nogenerate
drop if GASCOR==.

foreach x of varlist GASCOR INGCOR GASMON RENTA INGMON lux nlux {
replace `x'=`x'/index
}

gen income = INGMON - RENTA
gen consum = lux

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


*** TABLE B9 - Luxury Consumption

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

outsheet tc* in 1/`row' using "$output/tableB9_d.tex", noquote nonames delimit(" ") replace

