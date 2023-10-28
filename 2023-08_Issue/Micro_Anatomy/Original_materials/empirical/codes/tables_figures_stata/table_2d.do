**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table 1 panel d: Elasticities by education level
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

 **********************************************
 ******* Table 2 panel - Eduaction *******
 **********************************************
 
** ITALY

u "$database/resid_ITA.dta", clear

* key variables

keep year uy uc ly lc studio freqwt probwt

* educ groups
 
gen educ_lev = .
replace educ_lev = 1 if studio == 1 | studio == 2 | studio == 3 
replace educ_lev = 2 if studio == 4 | studio == 5 | studio == 6

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year educ_lev)

replace uy = ln(uy)
replace uc = ln(uc)

xtset educ_lev year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014

keep educ_lev g_uc g_uy elast

gen ty = "educ"
gen episode = "Italy"

tempfile italy
save `italy' , replace

** SPAIN

u "$database/resid_SPA.dta", clear

keep year uy uc ly lc freqwt estudred_sp probwt
 
* educ groups
 
gen educ_lev = .
replace educ_lev = 1 if estudred_sp == 2 | estudred_sp == 1
replace educ_lev = 2 if estudred_sp == 4 | estudred_sp == 3
drop if educ_lev == .

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year educ_lev)

replace uy = ln(uy)
replace uc = ln(uc)

xtset educ_lev year

gen g_uy = uy - L5.uy
gen g_uc = uc - L5.uc

gen elast = g_uc/g_uy
keep if year == 2013

keep educ_lev g_uc g_uy elast

gen ty = "educ"
gen episode = "Spain"

tempfile spain
save `spain' , replace

** MEXICO

global input_mex = "$input/MEX"

* redefine educational groups to be consistent with other countries

import excel "$input_mex/POBLA94.xls", sheet("Sheet1") clear firstrow

rename FOLIOC11 FOLIO
rename PARENTESCOC1 PAREN

rename EDADN20 EDAD

rename ED_FORMALC1 ED_FORMAL
rename ED_TECNICAC1 ED_TECNICA
rename LEER_ESCC1 LEE_ESC

keep FOLIO PAREN EDAD ED_FORMAL ED_TECNICA LEE_ESC
destring PAREN ED_FORMAL ED_TECNICA LEE_ESC, replace

egen EDADa=mean(EDAD), by(FOLIO)
keep if PAREN==1 
gen year = 1994

* education
* no educacion tecnica ni formal o no sabe leer ni escribir = 1
* no termino primaria ni basico de tecnica pero sabe leer y escribir =2
* termino primaria, termino carrera tecnica sin requisito, secundaria incompleta y tecnico con primaria incompleta = 3 
* no termino bachillerato o menos, pero al menos secundaria completa = 4
* termino bachillerato y no finalizo terciario = 5
* termino terciario o mas = 6
replace ED_TECNICA = ED_TECNICA + 1
replace ED_FORMAL = ED_FORMAL + 1

gen educ=.
replace educ=1 if ((ED_TECNICA==1 & ED_FORMAL==1) | LEE_ESC==2)
replace educ=2 if ((ED_TECNICA==2 | ED_FORMAL==2) & LEE_ESC==1) 
replace educ=3 if (ED_FORMAL==3 | ED_TECNICA==3 | ED_TECNICA==4 | ED_FORMAL==4)
replace educ=4 if (ED_FORMAL==5  | ED_FORMAL==6 | ED_TECNICA==5 | ED_TECNICA==6)
replace educ=5 if (ED_FORMAL==7  | ED_FORMAL==8 | ED_TECNICA==7 | ED_TECNICA==8)
replace educ=6 if (ED_FORMAL==10 | ED_FORMAL==9 | ED_TECNICA==9)

rename educ educ_aux

gen educ = .
replace educ = 1 if educ_aux==1 |  educ_aux==2
replace educ = 2 if educ_aux>2 & educ_aux!=.

keep FOLIO ED_FORMAL educ

gen year = 1994

tempfile educ_1994
save `educ_1994', replace

import excel "$input_mex/POBLA96.xls", sheet("Sheet1") clear firstrow

rename FOLIOC11 FOLIO
rename PARENTESCOC2 PAREN

rename ED_FORMALC2 ED_FORMAL
rename ED_TECNICAC1 ED_TECNICA
rename LEER_ESCC1 LEE_ESC

keep FOLIO PAREN EDAD ED_FORMAL ED_TECNICA LEE_ESC
destring PAREN ED_FORMAL ED_TECNICA LEE_ESC, replace

egen EDADa=mean(EDAD), by(FOLIO)
keep if PAREN==1 
gen year = 1996

* education
* no educacion tecnica ni formal o no sabe leer ni escribir = 1
* no termino primaria ni basico de tecnica pero sabe leer y escribir =2
* termino primaria, termino carrera tecnica sin requisito, secundaria incompleta y tecnico con primaria incompleta = 3 
* no termino bachillerato o menos, pero al menos secundaria completa = 4
* termino bachillerato y no finalizo terciario = 5
* termino terciario o mas = 6

gen educ=.
replace educ=1 if ((ED_TECNICA==0 & ED_FORMAL==0) | LEE_ESC==2)
replace educ=2 if ((ED_TECNICA==1 | ED_FORMAL==2 | ED_FORMAL==3 | ED_FORMAL==4 | ED_FORMAL==5 | ED_FORMAL==6) & LEE_ESC==1)
replace educ=3 if (ED_FORMAL==7 | ED_TECNICA==2 | ED_TECNICA==3 | ED_FORMAL==8 | ED_FORMAL==9)
replace educ=4 if (ED_FORMAL==10  | ED_FORMAL==11 | ED_TECNICA==4 | ED_TECNICA==5)
replace educ=5 if (ED_FORMAL==12  | ED_FORMAL==13 | ED_TECNICA==6 | ED_TECNICA==7)
replace educ=6 if (ED_FORMAL==14 | ED_FORMAL==15 | ED_TECNICA==8)

rename educ educ_aux

gen educ = .
replace educ = 1 if educ_aux==1 |  educ_aux==2
replace educ = 2 if educ_aux>2 & educ_aux!=.

keep FOLIO ED_FORMAL educ year

tempfile educ_1996
save `educ_1996', replace

u "$input_mex/concen_06.dta", replace

gen year = 2006

rename folio FOLIO
rename ed_formal ED_FORMAL

destring ED_FORMAL,replace

keep FOLIO ED_FORMAL

gen educ = .
replace educ = 1 if ED_FORMAL<=4 &  ED_FORMAL!=.
replace educ = 2 if ED_FORMAL>=5  &  ED_FORMAL!=.

gen year = 2006

tempfile educ_2006
save `educ_2006', replace

u "$input_mex/concen_10.dta", replace

gen year = 2010

gen  FOLIO = folioviv + foliohog
rename ed_formal ED_FORMAL
destring ED_FORMAL, replace

keep FOLIO ED_FORMAL

gen educ = .
replace educ = 1 if ED_FORMAL<=4 &  ED_FORMAL!=.
replace educ = 2 if ED_FORMAL>=5  &  ED_FORMAL!=.

gen year = 2010

tempfile educ_2010
save `educ_2010', replace

append using `educ_1994'
append using `educ_1996'
append using `educ_2006'

tempfile educa
save `educa', replace

* merge with baseline sample data

u "$database/resid_MEX.dta", clear

rename EDAD age

keep FOLIO year uy uc ly lc age freqwt probwt

* educ groups

keep if year == 1994 | year == 1996 | year == 2006 | year == 2010

merge 1:1 FOLIO using `educa'
keep if _merge == 3
drop _merge ED_FORMAL
drop if educ == .
drop FOLIO

rename educ educ_lev

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year educ_lev)

replace uy = ln(uy)
replace uc = ln(uc)

xtset educ_lev year

gen g_uy = uy - L2.uy
gen g_uc = uc - L2.uc

gen g_uy2 = uy - L4.uy
gen g_uc2 = uc - L4.uc

gen elast = g_uc/g_uy
gen elast2 = g_uc2/g_uy2

keep if year == 2010 | year == 1996

replace g_uy = g_uy2 if year == 2010
replace g_uc = g_uc2 if year == 2010 
replace elast = elast2 if year == 2010 

keep educ_lev g_uc g_uy elast year

gen ty = "educ"
gen episode = "Mexico - Tequila"
replace episode = "Mexico - GFC" if year == 2010 
drop year

tempfile mexico
save `mexico' , replace

** PERU

u "$database/resid_PER.dta", clear

keep year educ uy uc ly lc age freqwt probwt

* educ groups

drop if educ == .
gen educ_lev = .
replace educ_lev = 1 if educ<=6 & educ!=.
replace educ_lev = 2 if educ>6 & educ!=.

* elasticities

collapse(mean) uc uy  [w=freqwt], by(year educ_lev)

replace uy = ln(uy)
replace uc = ln(uc)

xtset educ_lev year

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy
keep if year == 2010

keep educ_lev g_uc g_uy elast

gen ty = "educ"
gen episode = "Peru"

*** TABLE WITH RESULTS ***

append using `mexico'
append using `spain'
append using `italy'

sum elast if educ_lev == 1
local elast_1 = r(mean)

sum elast if educ_lev == 2
local elast_2 = r(mean)

** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "& Low &" in `row'
replace tc2 = " & " + string(elast[9],"%9.2f") in `row'
replace tc3 = " & " + string(elast[7],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[3],"%9.2f") in `row'
replace tc6 = " & " + string(elast[4],"%9.2f") in `row'
replace tc7 = " & " + string(elast[1],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_1',"%9.2f") in `row'

local ++row
replace tc1 = "& High &" in `row'
replace tc2 = " & " + string(elast[10],"%9.2f") in `row'
replace tc3 = " & " + string(elast[8],"%9.2f") in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[5],"%9.2f") in `row'
replace tc6 = " & " + string(elast[6],"%9.2f") in `row'
replace tc7 = " & " + string(elast[2],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_2',"%9.2f") in `row'
replace tc10 = "& \hspace{-1em} \vspace{.5em}" in `row'

outsheet tc* in 1/`row' using "$output/table2_d.tex", noquote nonames delimit(" ") replace

