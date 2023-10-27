**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code cleans dataset and identifies households that hold liquid 
* assets through income and financial net income data in Mexico
**********************************************************************


cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

** 2007 interest on liquid assets **

use "$input/PER/enaho01a-2007-500.dta", clear

rename a—o year_n

gen depb = (p5572a == 1)
rename p5572b depf
rename p5572c depm

gen stocksb = (p5574a == 1)
rename p5574b stocksf
rename p5574c stocksm

gen id_HH = year_n + conglome + vivienda + hogar
keep depb depf depm stocks* id_HH year_n

collapse(sum) stocksm depm (mean) stocksb depb (max) stocksf depf, by(id_HH year_n)

replace stocksb = 1 if stocksb > 0 & stocksb!=.
replace depb = 1 if depb > 0 & depb!=.

tempfile ingreso07
save `ingreso07', replace

use "$input/PER/enaho01-2007-611.dta", clear

rename a—o year_n

keep if p611n == 3

gen finb = (p611 == 1)

rename p611b finm
replace finm = 0 if finm == .
replace finm = . if finm == 999999.9

gen id_HH = year_n + conglome + vivienda + hogar
keep finb finm id_HH year_n

merge 1:1 id_HH using `ingreso07', nogenerate

tempfile dat07
save `dat07', replace

use "$input/PER/enaho01a-2010-500.dta", clear

rename a—o year_n

gen depb = (p5572a == 1)
rename p5572b depf
rename p5572c depm

gen stocksb = (p5574a == 1)
rename p5574b stocksf
rename p5574c stocksm

gen id_HH = year + conglome + vivienda + hogar
keep depb depf depm stocks* id_HH year_n

collapse(sum) stocksm depm (mean) stocksb depb (max) stocksf depf, by(id_HH year_n)

replace stocksb = 1 if stocksb > 0 & stocksb!=.
replace depb = 1 if depb > 0 & depb!=.

tempfile ingreso10
save `ingreso10', replace

use "$input/PER/enaho01-2010-611.dta", clear

rename a—o year_n

keep if p611n == 3

gen finb = (p611 == 1)

rename p611b finm
replace finm = 0 if finm == .
replace finm = . if finm == 999999.9

gen id_HH = year + conglome + vivienda + hogar
keep finb finm id_HH year_n

merge 1:1 id_HH using `ingreso10', nogenerate
append using `dat07'

save "$database/PER/PER_wealth.dta", replace


