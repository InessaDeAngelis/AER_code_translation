**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code makes CPI aggregate and by category to level-1 for Mexico
**********************************************************************

cls
clear all
capture clear matrix
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

** CPI by category

import excel "$input/MEX/CPI_MEX.xls", sheet("level1") firstrow clear

rename Indicenacionaldepreciosalco CPI_0_0
rename C CPI_1_1
rename D CPI_1_2
rename E CPI_1_3
rename F CPI_1_4
rename G CPI_1_5
rename H CPI_1_6
rename I CPI_1_7
rename J CPI_1_8


gen year = substr(Date, strpos(Date, " ") + 1, .)
destring year, replace
gen month_ = substr(Date,1 , strpos(Date, " ")-1)
gen month=.
replace month=1 if month_=="Ene"
replace month=2 if month_=="Feb"
replace month=3 if month_=="Mar"
replace month=4 if month_=="Abr"
replace month=5 if month_=="May"
replace month=6 if month_=="Jun"
replace month=7 if month_=="Jul"
replace month=8 if month_=="Ago"
replace month=9 if month_=="Sep"
replace month=10 if month_=="Oct"
replace month=11 if month_=="Nov"
replace month=12 if month_=="Dic"

gen yearmonth = ym(year,month)
reshape long CPI_, i(yearmonth) j(id, string)
format yearmonth %tm
drop Date month_ month year
gen code = substr(id, strpos(id, "_") + 1, .) 
gen level = substr(id, 1,  strpos(id, "_") - 1) 
destring code level, replace
rename CPI_ index

egen id_n=group(id)
xtset id_n yearmonth

gen mInf=log(index)-log(L1.index)


label define code 0 "CPI general" 1 "Alimentos y bebidas" 2 "Vestimenta y Calzado" 3 "Vivienda" 4 "Muebles y artÌculos para la vivienda" 5 "Salud" 6 "Transporte" 7 "Entretenimiento, cultura y educacion" 8 "Bienes y servicios diversos"
label values code code

gen month = month(dofm(yearmonth))
gen year = yofd(dofm(yearmonth))

save "$database/MEX/CPI_cat_monthly.dta", replace

* use the ENIGH period
gen ENIGH=.
replace ENIGH=1 if month>=8 & month<=11
drop if ENIGH==.
collapse(mean) index, by( code ENIGH year )
drop ENIGH


egen code_n = group(code)
replace code_n = code_n - 1
drop code

reshape wide index, i(year) j(code_n)

save "$database/MEX/CPI_cat.dta", replace

** General CPI

import excel "$input/MEX/CPI_MEX.xls", sheet("general") firstrow clear

keep if month == 9 | month == 8 /* use two-previous months to survey */
collapse(sum) CPI, by(year)

rename CPI index

save "$database/MEX/CPI.dta", replace
save "$input/MEX/CPI.dta", replace
