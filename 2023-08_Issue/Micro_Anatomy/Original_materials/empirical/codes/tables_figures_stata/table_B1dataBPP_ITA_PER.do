**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code creates data for Table B.1 BPP estimates for Italy and Peru
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

*** ITALY ***

u "$database/baseline_ITA.dta", clear

merge m:1 anno using "$input/ITA/storico_stata/defl.dta"
keep if _merge == 3
drop _merge

replace income = income*rival
replace consum = consum*rival

gen ly = ln(income) - ln(hhsize)
gen lc = ln(consum) - ln(hhsize)

* residualization for BPP estimates (use year FE)

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
qui tab year, gen(yearb)

gen yeducb1 = educb1*year
gen yeducb2 = educb2*year
gen yeducb3 = educb3*year
gen yeducb4 = educb4*year

gen ysexb1 = sessob1*year
gen ysexb2 = sessob2*year

reg ly sessob* age age2 educb* ysexb* estratob* yeducb*  yearb* [aw=pesopop]
predict uy if e(sample),res

reg lc  sessob* age age2 educb* ysexb* estratob* yeducb* yearb* [aw=pesopop]
predict uc if e(sample),res 

replace uy = exp(uy)
replace uc = exp(uc)

* panel moments

replace uy = ln(uy)
replace uc = ln(uc)

rename nquest id_HH

* Panel sample selection criteria

drop if year == 1995

sort id_HH year
qby id_HH: gen dyear=year-year[_n-1]
egen todrop=sum(dyear>2 & dyear!=.),by(id_HH)		/*Drop those with intermittent "headship" */
egen n=sum(id_HH!=.),by(id_HH)				/*Drop those appearing only once		*/
replace todrop=1 if n==1
drop if todrop>0
drop todrop dyear n

egen miny=min(year),by(id_HH)
qby id_HH: gen dhhsize=abs(hhsize-hhsize[_n-1])
gen todrop1=(dhhsize>0)
replace todrop1=0 if year==miny & todrop1==1	/*starting household structure is when they first appear in sample*/
egen todrop2=sum(todrop1),by(id_HH)
drop if todrop2!=0
drop todrop* miny dhhsize

xtset id_HH year
gen g_Y = income/L2.income - 1
gen m=g_Y>5 & g_Y!=.|g_Y<-0.8 & g_Y!=.
egen mm=sum(m),by(id_HH)
drop if mm>0
drop g_Y mm m

* panel income and consumption change

xtset id_HH year

local rho = 1 /* as in BPP we assume persistent component is a random walk */

gen duc = uc - L2.uc
gen duy = uy - `rho'*L2.uy

* data for minimum distance estimation

keep year id_HH duc duy
xtset id_HH year
fillin id_HH year 

gen yduy=duy!=.
replace  duy=0 if duy==.

gen yduc=duc!=.        
replace  duc=0 if duc==.

egen nobsdif=sum(yduy),by(year)	
drop if nobsdif<50
drop nobsdif

sort id_HH year
keep  id_HH year duy yduy duc yduc
order id_HH year duy yduy duc yduc

export delimited using "$database/ITA/ITA_mom_BPP.csv", replace

*** PERU ***

use "$database/baseline_PER.dta", clear

destring year_n, replace
gen id_HH = conglome_ + vivienda_ + hogar

replace id_HH = substr(id_HH,3,.) if year_n>=2011
egen id = group(id_HH)

drop if year_n < 2007 /* Use short panel sample for consistency */
drop if year_n > 2011

gen tax = inghog2d_/inghog1d_
gen inc = inghog2d_ - rents_income*tax
gen consu = gashog1d_ - (hhcred_expend + rent_expend + hhexpan_expend) - hhequip_expend
replace inc = inc/CPI_index
replace consu = consu/CPI_index

* residualization for BPP estimates (use year FE)

qui tab(educ), gen(educb)
qui tab(year_n), gen(yearb)
qui tab(sex), gen(sexb)
qui tab(mstatus), gen(mstatusb)
qui tab(mieperho_), gen(mieperhob)
qui tab(dominio_), gen(dominiob) 
gen size_large = (estrato<=2)
gen age2 = age^2

gen linc = ln(inc)
gen lconsu = ln(consu)

reg linc sexb* mstatusb* mieperhob* dominiob* size_large age age2 yearb* educb*
predict uy if e(sample),res

reg lconsu sexb* mstatusb* mieperhob* dominiob* size_large age age2 yearb* educb*
predict uc if e(sample),res

* Panel sample extra sample filters

drop year
rename year_n year

gen hhsize = mieperho_

sort id year
qby id: gen dyear=year-year[_n-1]
egen todrop=sum(dyear>2 & dyear!=.),by(id)		/*Drop those with intermittent "headship" */
egen n=sum(id!=.),by(id)				        /*Drop those appearing only once		*/
replace todrop=1 if n==1
drop if todrop>0
drop todrop dyear n

egen miny=min(year),by(id)
qby id: gen dhhsize=abs(hhsize-hhsize[_n-1])
gen todrop1=(dhhsize>0)
replace todrop1=0 if year==miny & todrop1==1	/*starting household structure is when they first appear in sample*/
egen todrop2=sum(todrop1),by(id)
drop if todrop2!=0
drop todrop* miny dhhsize

xtset id year
gen g_Y = inc/L1.inc - 1
gen m=g_Y>5 & g_Y!=.|g_Y<-0.8 & g_Y!=. 	/* income outliers */
egen mm=sum(m),by(id)
drop if mm>0
drop g_Y mm m

* BPP moments

xtset id year

local rho = 1 /* as in BPP we assume persistent component is a random walk */

gen duc = uc - L1.uc
gen duy = uy - `rho'*L1.uy

keep year id duc duy
xtset id year
fillin id year 

gen yduy=duy!=.
replace  duy=0 if duy==.

gen yduc=duc!=.        
replace  duc=0 if duc==.
gen coh=0

egen nobsdif=sum(yduy),by(year)	
drop if nobsdif<50
drop nobsdif

egen miny=min(year)
egen maxy=max(year)
egen temp1=sum(yduc),by(id)
egen nmissd=max(temp1)
replace nmissd=(maxy-miny+1)-nmissd
gen ndrod=year==1987|year==1988|year==1989
drop maxy miny temp1

sort id year
keep  id year coh ndrod duy yduy duc yduc nmissd
order id year coh ndrod duy yduy duc yduc nmissd

export delimited using "$database/PER/PER_mom_BPP.csv", replace
