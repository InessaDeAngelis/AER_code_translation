**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code makes series of CPI for Peru
**********************************************************************


cls
clear all
capture clear matrix
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

** aggregate

import excel "$input/PER/CPI_PER.xlsx", sheet("data") cellrange(A4:F304) clear firstrow
rename Ano year
replace year=year[_n-1] if year==.

rename Mes month_
gen month="."
replace month="01" if month_=="Enero"
replace month="02" if month_=="Febrero"
replace month="03" if month_=="Marzo"
replace month="04" if month_=="Abril"
replace month="05" if month_=="Mayo"
replace month="06" if month_=="Junio"
replace month="07" if month_=="Julio"
replace month="08" if month_=="Agosto"
replace month="09" if month_=="Setiembre"
replace month="10" if month_=="Octubre"
replace month="11" if month_=="Noviembre"
replace month="12" if month_=="Diciembre"
rename Indice CPI_index

tostring month year, replace
gen year_month = year + "_" + month
keep year month CPI_index year_month

save "$database/PER/CPI.dta", replace
save "$input/PER/CPI.dta", replace
