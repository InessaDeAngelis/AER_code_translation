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

**** 1994 ****

import excel "$input/MEX/ingresos1994.xls", sheet("Sheet1") clear firstrow

drop if ING_TRIN92 == .

rename ING_TRIN92 ING_TRI
rename FOLIOC11 FOLIO
rename CLAVEC4 CLAVE

* checking and savings accounts, stocks and bonds, and long-term deposits
gen fin = 0
replace fin=1 if CLAVE == "P018"
replace fin=1 if CLAVE == "P019"
replace fin=1 if CLAVE == "P021"
* retire deposit
replace fin=1 if CLAVE == "P031"
* sell of bonds, stocks and similar
replace fin=1 if CLAVE == "P034"
replace fin=1 if CLAVE == "P035"

collapse (sum) fin, by(FOLIO)

replace fin =1 if fin>0

tempfile income
save `income', replace

import excel "$input/MEX/eroga1994.xls", sheet("Sheet1") firstrow clear

gen fine = 0
replace fine=1 if CLAVE == "Q001"
replace fine=1 if CLAVE == "Q003"
replace fine=1 if CLAVE == "Q005"
replace fine=1 if CLAVE == "Q014"

collapse (sum) fine, by(FOLIO)

replace fine =1 if fine>0

merge 1:1 FOLIO using `income', nogenerate

gen fina = 0
replace fina = 1 if fine==1 | fin==1

keep FOLIO fina
gen year = 1994

tempfile liq_1994
save `liq_1994' , replace

**** 1996 ****

import excel "$input/MEX/ingresos1996.xls", sheet("Sheet1") firstrow clear

drop if ING_TRIN202 == .

rename ING_TRIN202 ING_TRI
rename FOLIOC11 FOLIO
rename CLAVEC4 CLAVE

* checking and savings accounts, stocks and bonds, and long-term deposits
gen fin = 0
replace fin=1 if CLAVE == "P018"
replace fin=1 if CLAVE == "P019"
replace fin=1 if CLAVE == "P021"
* retire deposit
replace fin=1 if CLAVE == "P032"
* sell of bonds, stocks and similar
replace fin=1 if CLAVE == "P035"
replace fin=1 if CLAVE == "P036"

collapse (sum) fin, by(FOLIO)

replace fin =1 if fin>0

tempfile income
save `income', replace

import excel "$input/MEX/eroga1996.xls", sheet("Sheet1") firstrow clear

rename ERO_TRIN202 ING_TRI
rename FOLIOC11 FOLIO
rename CLAVEC4 CLAVE

gen fine = 0
replace fine=1 if CLAVE == "Q001"
replace fine=1 if CLAVE == "Q003"
replace fine=1 if CLAVE == "Q005"
replace fine=1 if CLAVE == "Q014"

collapse (sum) fine, by(FOLIO)

replace fine =1 if fine>0

merge 1:1 FOLIO using `income', nogenerate

gen fina = 0
replace fina = 1 if fine==1 | fin==1

keep FOLIO fina
gen year = 1996

tempfile liq_1996
save `liq_1996' , replace

**** 2006 ****

use "$input/MEX/ingresos2006.dta", clear

* checking and savings accounts, stocks and bonds, and long-term deposits
gen fin = 0
replace fin=1 if clave == "P042"
replace fin=1 if clave == "P043"
replace fin=1 if clave == "P045"
* retire deposit
replace fin=1 if clave == "P062"
* sell of bonds, stocks and similar
replace fin=1 if clave == "P065"
replace fin=1 if clave == "P066"

collapse (sum) fin, by(folio)

replace fin =1 if fin>0

tempfile income
save `income', replace

use "$input/MEX/eroga2006.dta", clear

gen fine = 0
replace fine=1 if clave == "Q001"
replace fine=1 if clave == "Q003"
replace fine=1 if clave == "Q005"
replace fine=1 if clave == "Q006"
replace fine=1 if clave == "Q015"

collapse (sum) fine, by(folio)

replace fine =1 if fine>0

merge 1:1 folio using `income', nogenerate

rename folio FOLIO
gen fina = 0
replace fina = 1 if fine==1 | fin==1

keep FOLIO fina
gen year = 2006

tempfile liq_2006
save `liq_2006' , replace

**** 2010 ****

use "$input/MEX/ingresos2010.dta", clear

gen folio = folioviv + foliohog

* checking and savings accounts, stocks and bonds, and long-term deposits
gen fin = 0
replace fin=1 if clave == "P026"
replace fin=1 if clave == "P027"
replace fin=1 if clave == "P029"
replace fin=1 if clave == "P050"
* retire deposit
replace fin=1 if clave == "P051"
* sell of bonds, stocks and similar
replace fin=1 if clave == "P054"
replace fin=1 if clave == "P055"

collapse (sum) fin, by(folio)

replace fin =1 if fin>0

tempfile income
save `income', replace

use "$input/MEX/eroga2010.dta", clear

gen folio = folioviv + foliohog

gen fine = 0
replace fine=1 if clave == "Q001"
replace fine=1 if clave == "Q003"
replace fine=1 if clave == "Q005"
replace fine=1 if clave == "Q006"
replace fine=1 if clave == "Q015"

collapse (sum) fine, by(folio)

replace fine=1 if fine>0

merge 1:1 folio using `income', nogenerate

rename folio FOLIO
gen fina = 0
replace fina = 1 if fine==1 | fin==1

keep FOLIO fina
gen year = 2010

tempfile liq_2010
save `liq_2010' , replace

append using `liq_1994'
append using `liq_1996'
append using `liq_2006'


save "$database/MEX/MEX_wealth.dta", replace


