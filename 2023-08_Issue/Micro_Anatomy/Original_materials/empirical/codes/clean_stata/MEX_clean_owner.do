**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code creates database which identifies HH by firm and home
* ownership for waves 1994, 1996, 2006, and 2010
**********************************************************************


cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"


*** 1994 and 1996

local year = "94 96"

foreach y of local year {

use "$input/MEX/poblacion_`y'.dta", clear

gen owner= 0
replace owner = 1 if POSICION==4 | POSICION==5 | POSICI_SEC==4 | POSICI_SEC==5

decode FOLIO, gen(FOLIO_)
drop FOLIO
rename FOLIO_ FOLIO

collapse (mean) owner, by(FOLIO)
replace owner = 1 if owner>0 & owner!=.

tempfile ownership
save `ownership' , replace

use "$input/MEX/hogares_`y'.dta", clear

gen tenencia = 1
replace tenencia = 0 if TENENCIA == 9 | TENENCIA == 8 | TENENCIA ==  7 | TENENCIA == 6 | TENENCIA == 1
keep FOLIO tenencia

decode FOLIO, gen(FOLIO_)
drop FOLIO
rename FOLIO_ FOLIO

merge 1:1 FOLIO using `ownership'
drop _merge

gen year = 1900 + `y'

tempfile own_`y'
save `own_`y'' , replace
}

*** 2006


use "$input/MEX/poblacion_06.dta", clear

gen owner= 0
replace owner = 1 if posicion07 == "6" | posicion18 == "6"
rename folio FOLIO

collapse (mean) owner, by(FOLIO)
replace owner = 1 if owner>0 & owner!=.

tempfile ownership
save `ownership' , replace

use "$input/MEX/concen_06.dta", clear

rename folio FOLIO

merge 1:1 FOLIO using `ownership', nogenerate

tempfile data
save `data' , replace

use "$input/MEX/hogares_06.dta", clear

destring tenencia12, replace
gen tenencia = 0
replace tenencia = 1  if tenencia12==5 | tenencia12==4
rename tenencia12 tenen
keep folio tenencia tenen
rename folio FOLIO

tempfile house
save `house' , replace

use `data' , clear
drop tenencia
merge 1:1 FOLIO using `house', nogenerate

gen owner2 = 0
replace owner2 = 1 if NEGOCIO/INGCOR>0.5 & NEGOCIO!=.

gen year = 2006
keep owner tenencia FOLIO year

tempfile own_06
save `own_06' , replace


*** 2010

use "$input/MEX/hogares_10.dta", clear

gen owner= 0
replace owner = 1 if negcua=="1"
gen FOLIO = folioviv + foliohog

collapse (mean) owner, by(FOLIO)
replace owner = 1 if owner>0 & owner!=.

tempfile ownership
save `ownership' , replace

use "$input/MEX/concen_10.dta", clear

gen FOLIO = folioviv + foliohog

merge 1:1 FOLIO using `ownership', nogenerate

tempfile data
save `data' , replace

use "$input/MEX/hogares_10.dta", clear

destring tenen, replace
gen tenencia = 0
replace tenencia = 1  if tenen==3 | tenen==4
gen folio=folioviv + foliohog
keep folio tenencia tenen
rename folio FOLIO

tempfile house
save `house' , replace

use `data' , clear
drop tenencia
merge 1:1 FOLIO using `house', nogenerate

gen owner2 = 0
replace owner2 = 1 if NEGOCIO/INGCOR>0.5 & NEGOCIO!=.

gen year = 2010
keep owner tenencia FOLIO year


append using `own_94'
append using `own_96'
append using `own_06'

rename owner firm_owner

save "$database/MEX/MEX_owner.dta", replace
