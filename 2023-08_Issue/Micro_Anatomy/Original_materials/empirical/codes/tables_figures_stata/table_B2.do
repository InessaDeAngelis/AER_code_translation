**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table B2 - all panels
**********************************************************************


cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

grstyle clear

 
*** ITA  *** 

u "$database/baseline_ITA.dta", clear

* merging CPI
merge m:1 anno using "$input/ITA/storico_stata/defl.dta"
keep if _merge == 3
drop _merge

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
*predict uy if e(sample),res
*regionb*

reg lc  sessob* age age2 educb* ysexb* estratob* yeducb* year [aw=pesopop]
*predict uc if e(sample),res 
*regionb*


local mcode 0
local var y c
foreach m of local var {

reg l`m' age age2 [aw=pesopop]
predict u`m'1 if e(sample),res

reg l`m' age age2 sessob* [aw=pesopop]
predict u`m'2 if e(sample),res

reg l`m' age age2 sessob* educb* [aw=pesopop]
predict u`m'3 if e(sample),res

reg l`m' age age2 sessob* educb* [aw=pesopop]
predict u`m'4 if e(sample),res

reg l`m' age age2 sessob* educb* estratob* [aw=pesopop]
predict u`m'5 if e(sample),res

reg l`m' age age2 sessob* educb* estratob* ysexb* [aw=pesopop]
predict u`m'6 if e(sample),res

reg l`m' age age2 sessob* educb* estratob* ysexb* yeducb* [aw=pesopop]
predict u`m'7 if e(sample),res

reg l`m' age age2 sessob* educb* estratob* ysexb* yeducb* year [aw=pesopop]
predict u`m' if e(sample),res
gen r2`m' = e(r2)
}

collapse (mean) r2y r2c (sd) ly lc uy* uc* [aw=pesopop]

*No regression including HH size
replace uy4 = .
replace uc4 = .

gen country = "ITA"

tempfile ITA
save `ITA', replace

**

*** SPA *** 

u "$database/baseline_SPA.dta", clear

merge m:1 year using "$input/SPA/CPI.dta"
drop if _merge==2
drop _merge

gen inc = impexac
gen cons = nondurab

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
*predict uy if e(sample),res
*ccaab*

reg lc edadsp2 edadsp estudb* sexob* nmiembb* yeducb* ysexob* tamamub* year [aw=factor]
*predict uc if e(sample),res
*ccaab* 


local mcode 0
local var y c
foreach m of local var {

reg l`m' edadsp edadsp2 [aw=factor]
predict u`m'1 if e(sample),res

reg l`m' edadsp edadsp2 sexob* [aw=factor]
predict u`m'2 if e(sample),res

reg l`m' edadsp edadsp2 sexob* estudb* [aw=factor]
predict u`m'3 if e(sample),res

reg l`m' edadsp edadsp2 sexob* estudb* nmiembb* [aw=factor]
predict u`m'4 if e(sample),res

reg l`m' edadsp edadsp2 sexob* estudb* nmiembb* tamamub* [aw=factor]
predict u`m'5 if e(sample),res

reg l`m' edadsp edadsp2 sexob* estudb* nmiembb* tamamub* ysexob* [aw=factor]
predict u`m'6 if e(sample),res

reg l`m' edadsp edadsp2 sexob* estudb* nmiembb* tamamub* ysexob* yeducb* [aw=factor]
predict u`m'7 if e(sample),res

reg l`m' edadsp edadsp2 sexob* estudb* nmiembb* tamamub* ysexob* yeducb* year [aw=factor]
predict u`m' if e(sample),res
gen r2`m' = e(r2)
}

collapse (mean) r2y r2c (sd) ly lc uy* uc* [aw=factor]

gen country = "SPA"

tempfile SPA
save `SPA', replace

*** MEX *** 

u "$database/baseline_MEX.dta", clear

merge m:1 year using "$input/MEX/CPI.dta", nogenerate
drop if GASCOR==.

foreach x of varlist GASCOR INGCOR GASMON RENTA INGMON GAS_TRI {
replace `x'=`x'/index
}

gen income = INGMON - RENTA
gen consum = GAS_TRI

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
*predict uy if e(sample),res

reg lc EDAD EDAD2 SEXb* EDUCb* ESTRATOb* YEDUCb* TAM_HOGb* YSEXb*  year [aw=HOG]
*predict uc if e(sample),res


local mcode 0
local var y c
foreach m of local var {

reg l`m' EDAD EDAD2 [aw=HOG]
predict u`m'1 if e(sample),res

reg l`m' EDAD EDAD2 SEXb* [aw=HOG]
predict u`m'2 if e(sample),res

reg l`m' EDAD EDAD2 SEXb* EDUCb* [aw=HOG]
predict u`m'3 if e(sample),res

reg l`m' EDAD EDAD2 SEXb* EDUCb* TAM_HOGb* [aw=HOG]
predict u`m'4 if e(sample),res

reg l`m' EDAD EDAD2 SEXb* EDUCb* TAM_HOGb* ESTRATOb* [aw=HOG]
predict u`m'5 if e(sample),res

reg l`m' EDAD EDAD2 SEXb* EDUCb* TAM_HOGb* ESTRATOb* YSEXb* [aw=HOG]
predict u`m'6 if e(sample),res

reg l`m' EDAD EDAD2 SEXb* EDUCb* TAM_HOGb* ESTRATOb* YSEXb* YEDUCb* [aw=HOG]
predict u`m'7 if e(sample),res

reg l`m' EDAD EDAD2 SEXb* EDUCb* TAM_HOGb* ESTRATOb* YSEXb* YEDUCb* year [aw=HOG]
predict u`m' if e(sample),res
gen r2`m' = e(r2)
}


collapse (mean) r2y r2c (sd) ly lc uy* uc* [aw=HOG]

gen country = "MEX"

tempfile MEX
save `MEX', replace

*** PER *** 

u "$database/baseline_PER.dta", clear

destring year_n, replace

* income and consumption definition

gen tax = ingmo2hd_/ingmo1hd_
gen inc = (ingmo2hd_- rents_income*tax)/CPI_index
gen consu = (gashog1d_ - rent_expend - hhequip_expend)/CPI_index

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
*predict uy if e(sample),res
*estratob*
*dominiob*

reg lc age age2 sexb* educ2b* mieperhob* size_large ysexb* yeducb* year_t year_n [aw=factor07_]
*predict uc if e(sample),res
*estratob*
*dominiob*


local mcode 0
local var y c
foreach m of local var {

reg l`m' age age2 [aw=factor07_]
predict u`m'1 if e(sample),res

reg l`m' age age2 sexb* [aw=factor07_]
predict u`m'2 if e(sample),res

reg l`m' age age2 sexb* educ2b* [aw=factor07_]
predict u`m'3 if e(sample),res

reg l`m' age age2 sexb* educ2b* mieperhob* [aw=factor07_]
predict u`m'4 if e(sample),res

reg l`m' age age2 sexb* educ2b* mieperhob* size_large [aw=factor07_]
predict u`m'5 if e(sample),res

reg l`m' age age2 sexb* educ2b* mieperhob* size_large ysexb* [aw=factor07_]
predict u`m'6 if e(sample),res

reg l`m' age age2 sexb* educ2b* mieperhob* size_large ysexb* yeducb* [aw=factor07_]
predict u`m'7 if e(sample),res

reg l`m' age age2 sexb* educ2b* mieperhob* size_large ysexb* yeducb* year_t year_n [aw=factor07_]
predict u`m' if e(sample),res
gen r2`m' = e(r2)
}

collapse (mean) r2y r2c (sd) ly lc uy* uc*

gen country = "PER"

tempfile PER
save `PER', replace


*** TABLE D1 - RESIDUALIZATION

append using `MEX'
append using `SPA'
append using `ITA'

** latex preamble

if _N<500 set obs 500

forval i = 0/12 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "Non-residualized" in `row'
replace tc2 = " & " in `row'
replace tc3 = " & " + string(ly[4],"%9.2f") in `row'
replace tc4 = " & " + string(lc[4],"%9.2f") in `row'
replace tc5 = " & " + string(ly[3],"%9.2f") in `row'
replace tc6 = " & " + string(lc[3],"%9.2f") in `row'
replace tc7 = "& \hspace{.3em}"  in `row'
replace tc8 = " & " + string(ly[2],"%9.2f") in `row'
replace tc9 = " & " + string(lc[2],"%9.2f") in `row'
replace tc10 = " & " + string(ly[1],"%9.2f") in `row'
replace tc11 = " & " + string(lc[1],"%9.2f") + "\vspace{.3em}" in `row'

outsheet tc* in 1/`row' using "$output/tableB2_a.tex", noquote nonames delimit(" ") replace

use `PER', clear
append using `MEX'
append using `SPA'
append using `ITA'

if _N<500 set obs 500

forval i = 0/20 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = " " in `row'
replace tc2 = "\hspace{.5em} Age (quadratic) &" in `row'
replace tc3 = " & " + string(uy1[4],"%9.2f") in `row'
replace tc4 = " & " + string(uc1[4],"%9.2f") in `row'
replace tc5 = " & " + string(uy1[3],"%9.2f") in `row'
replace tc6 = " & " + string(uc1[3],"%9.2f") in `row'
replace tc7 = "& \hspace{.3em}"  in `row'
replace tc8 = " & " + string(uy1[2],"%9.2f") in `row'
replace tc9 = " & " + string(uc1[2],"%9.2f") in `row'
replace tc10 = " & " + string(uy1[1],"%9.2f") in `row'
replace tc11 = " & " + string(uc1[1],"%9.2f") + "\vspace{.3em}" in `row'

local ++row
replace tc1 = " " in `row'
replace tc2 = "\hspace{.5em} + Sex & " in `row'
replace tc3 = " & " + string(uy2[4],"%9.2f") in `row'
replace tc4 = " & " + string(uc2[4],"%9.2f") in `row'
replace tc5 = " & " + string(uy2[3],"%9.2f") in `row'
replace tc6 = " & " + string(uc2[3],"%9.2f") in `row'
replace tc7 = "& \hspace{.3em}"  in `row'
replace tc8 = " & " + string(uy2[2],"%9.2f") in `row'
replace tc9 = " & " + string(uc2[2],"%9.2f") in `row'
replace tc10 = " & " + string(uy2[1],"%9.2f") in `row'
replace tc11 = " & " + string(uc2[1],"%9.2f") + "\vspace{.3em}" in `row'

local ++row
replace tc1 = " " in `row'
replace tc2 = "\hspace{.5em} + Education & " in `row'
replace tc3 = " & " + string(uy3[4],"%9.2f") in `row'
replace tc4 = " & " + string(uc3[4],"%9.2f") in `row'
replace tc5 = " & " + string(uy3[3],"%9.2f") in `row'
replace tc6 = " & " + string(uc3[3],"%9.2f") in `row'
replace tc7 = "& \hspace{.3em}"  in `row'
replace tc8 = " & " + string(uy3[2],"%9.2f") in `row'
replace tc9 = " & " + string(uc3[2],"%9.2f") in `row'
replace tc10 = " & " + string(uy3[1],"%9.2f") in `row'
replace tc11 = " & " + string(uc3[1],"%9.2f") + "\vspace{.3em}" in `row'

local ++row
replace tc1 = " " in `row'
replace tc2 = "\hspace{.5em} + Household size & " in `row'
replace tc3 = " & " + string(uy4[4],"%9.2f") in `row'
replace tc4 = " & " + string(uc4[4],"%9.2f") in `row'
replace tc5 = " & " + string(uy4[3],"%9.2f") in `row'
replace tc6 = " & " + string(uc4[3],"%9.2f") in `row'
replace tc7 = "& \hspace{.3em}"  in `row'
replace tc8 = " & " + string(uy4[2],"%9.2f") in `row'
replace tc9 = " & " + string(uc4[2],"%9.2f") in `row'
replace tc10 = " & " + string(uy4[1],"%9.2f") in `row'
replace tc11 = " & " + string(uc4[1],"%9.2f") + "\vspace{.3em}" in `row'

local ++row
replace tc1 = " " in `row'
replace tc2 = "\hspace{.5em} + Region & " in `row'
replace tc3 = " & " + string(uy5[4],"%9.2f") in `row'
replace tc4 = " & " + string(uc5[4],"%9.2f") in `row'
replace tc5 = " & " + string(uy5[3],"%9.2f") in `row'
replace tc6 = " & " + string(uc5[3],"%9.2f") in `row'
replace tc7 = "& \hspace{.3em}"  in `row'
replace tc8 = " & " + string(uy5[2],"%9.2f") in `row'
replace tc9 = " & " + string(uc5[2],"%9.2f") in `row'
replace tc10 = " & " + string(uy5[1],"%9.2f") in `row'
replace tc11 = " & " + string(uc5[1],"%9.2f") + "\vspace{.3em}" in `row'

local ++row
replace tc1 = " " in `row'
replace tc2 = "\hspace{.5em} + Sex $\times$ year & " in `row'
replace tc3 = " & " + string(uy6[4],"%9.2f") in `row'
replace tc4 = " & " + string(uc6[4],"%9.2f") in `row'
replace tc5 = " & " + string(uy6[3],"%9.2f") in `row'
replace tc6 = " & " + string(uc6[3],"%9.2f") in `row'
replace tc7 = "& \hspace{.3em}"  in `row'
replace tc8 = " & " + string(uy6[2],"%9.2f") in `row'
replace tc9 = " & " + string(uc6[2],"%9.2f") in `row'
replace tc10 = " & " + string(uy6[1],"%9.2f") in `row'
replace tc11 = " & " + string(uc6[1],"%9.2f") + "\vspace{.3em}" in `row'


local ++row
replace tc1 = " " in `row'
replace tc2 = "\hspace{.5em} + Education $\times$ year & " in `row'
replace tc3 = " & " + string(uy7[4],"%9.2f") in `row'
replace tc4 = " & " + string(uc7[4],"%9.2f") in `row'
replace tc5 = " & " + string(uy7[3],"%9.2f") in `row'
replace tc6 = " & " + string(uc7[3],"%9.2f") in `row'
replace tc7 = "& \hspace{.3em}"  in `row'
replace tc8 = " & " + string(uy7[2],"%9.2f") in `row'
replace tc9 = " & " + string(uc7[2],"%9.2f") in `row'
replace tc10 = " & " + string(uy7[1],"%9.2f") in `row'
replace tc11 = " & " + string(uc7[1],"%9.2f") + "\vspace{.3em}" in `row'

local ++row
replace tc1 = "Residualized (Baseline model)" in `row'
replace tc2 = " & " in `row'
replace tc3 = " & " + string(uy[4],"%9.2f") in `row'
replace tc4 = " & " + string(uc[4],"%9.2f") in `row'
replace tc5 = " & " + string(uy[3],"%9.2f") in `row'
replace tc6 = " & " + string(uc[3],"%9.2f") in `row'
replace tc7 = "& \hspace{.3em}"  in `row'
replace tc8 = " & " + string(uy[2],"%9.2f") in `row'
replace tc9 = " & " + string(uc[2],"%9.2f") in `row'
replace tc10 = " & " + string(uy[1],"%9.2f") in `row'
replace tc11 = " & " + string(uc[1],"%9.2f") + "\vspace{.3em}" in `row'


outsheet tc* in 1/`row' using "$output/tableB2_b.tex", noquote nonames delimit(" ") replace

use `PER', clear
append using `MEX'
append using `SPA'
append using `ITA'

if _N<500 set obs 500

forval i = 0/12 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "R$^2$ (Baseline model)" in `row'
replace tc2 = "& " in `row'
replace tc3 = " & " + string(r2y[4],"%9.2f") in `row'
replace tc4 = " & " + string(r2c[4],"%9.2f") in `row'
replace tc5 = " & " + string(r2y[3],"%9.2f") in `row'
replace tc6 = " & " + string(r2c[3],"%9.2f") in `row'
replace tc7 = "& \hspace{.3em}"  in `row'
replace tc8 = " & " + string(r2y[2],"%9.2f") in `row'
replace tc9 = " & " + string(r2c[2],"%9.2f") in `row'
replace tc10 = " & " + string(r2y[1],"%9.2f") in `row'
replace tc11 = " & " + string(r2c[1],"%9.2f") + "\vspace{.3em}" in `row'

outsheet tc* in 1/`row' using "$output/tableB2_c.tex", noquote nonames delimit(" ") replace
