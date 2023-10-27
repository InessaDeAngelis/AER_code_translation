**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Longer sample for Italy to calculate business cycle elasticities
* Baseline sample criteria for 1980 onwards sample
**********************************************************************

cls
clear all
set mem 200m
set more off

global database   = "$user/working_data"
global input      = "$user/input"
global output     = "$user/output"

*** ITA *** 

global input_data_ITA  = "$user/input/ITA"

u "$input_data_ITA/storico_stata/comp.dta", clear

{
* hh size = ncomp
rename ncomp hhsize 
* region = 
rename  area3 region
* area = acom4c (by size)
rename  acom4c estrato
* hh head 
keep if cfred == 1

gen count = 1
qui sum count
display r(sum)

* sample years
keep if anno>=1980
qui sum count
display r(sum)

* remove small location
drop if acom5 == 1
qui sum count
display r(sum)

* age 
rename eta age
keep if age<=60 & age>=25
qui sum count
display r(sum)

tempfile sample1
save `sample1', replace

*** hh income and consumption ***

* income

u "$input_data_ITA/storico_stata/rfam.dta", clear

merge 1:1 nquest anno using `sample1'
keep if _merge == 3
drop _merge

gen income = yl - yl2 + yt + ym + yca1 /* excludes financial income, in kind payments and imputed rents */

tempfile ydata
save `ydata', replace

* consumption

u "$input_data_ITA/storico_stata/cons.dta", clear

merge 1:1 nquest anno using `ydata'
keep if _merge == 3
drop _merge

merge 1:1 nquest anno using "$input_data_ITA/storico_stata/peso.dta"
keep if _merge == 3
drop _merge

gen consum = cn - yca2  - yl2 /* non-durable and monetary */

gen C_Y = consum/income

* remove outliers 

drop if consum <=0 | consum == .
drop if income <=0 | income == .

drop if C_Y == .

_pctile C_Y [aweight=peso], p(.5 99.5)
local C_Y_l=r(r1)
local C_Y_u=r(r2)

drop if C_Y<`C_Y_l'
drop if C_Y>`C_Y_u'

qui sum count
display r(sum)

}

save "$database/baseline_ITA_long.dta", replace
