**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Use baseline sample and residualizes income and consumption using
* HHs observable characteristics
**********************************************************************

cls
clear all
set mem 200m
set more off

global database   = "$user/working_data"
global input      = "$user/input"
global output     = "$user/output"

***********************************
********* residualization *********
***********************************

*** ITA *** 

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
predict uy if e(sample),res

reg lc  sessob* age age2 educb* ysexb* estratob* yeducb* year [aw=pesopop]
predict uc if e(sample),res 

replace uy = exp(uy)
replace uc = exp(uc)

gen pesopop_r = round(pesopop)
gen freqwt = pesopop_r 
egen sum_freqwt = total(freqwt), by(year)
gen probwt = freqwt/sum_freqwt

save "$database/resid_ITA.dta", replace

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
predict uy if e(sample),res

reg lc edadsp2 edadsp estudb* sexob* nmiembb* yeducb* ysexob* tamamub* year [aw=factor]
predict uc if e(sample),res

replace ly = ln(inc) - ln(nmiemb)
replace lc = ln(cons) - ln(nmiemb)

replace uy = exp(uy)
replace uc = exp(uc)

gen freqwt = factor_r 
egen sum_freqwt = total(freqwt), by(year)
gen probwt = freqwt/sum_freqwt

save "$database/resid_SPA.dta", replace

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

save "$database/resid_MEX.dta", replace

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
predict uy if e(sample),res

reg lc age age2 sexb* educ2b* mieperhob* size_large ysexb* yeducb* year_t year_n [aw=factor07_]
predict uc if e(sample),res

* non-residualized 

replace ly = ln(inc) - ln(mieperho_)
replace lc = ln(consu) - ln(mieperho_)

replace uy = exp(uy)
replace uc = exp(uc)

gen freqwt = factor07_r 
egen sum_freqwt = total(freqwt), by(year)
gen probwt = freqwt/sum_freqwt

drop year 
rename year_n year

save "$database/resid_PER.dta", replace

