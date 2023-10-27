**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code makes series of CPI for Spain
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

import excel "$input/SPA/CPI_SPA.xls", sheet("proc") firstrow clear
rename Indicegeneral CPI
rename anio year

collapse (mean) CPI, by(year)

save "$database/SPA/CPI.dta", replace
save "$input/SPA/CPI.dta", replace
