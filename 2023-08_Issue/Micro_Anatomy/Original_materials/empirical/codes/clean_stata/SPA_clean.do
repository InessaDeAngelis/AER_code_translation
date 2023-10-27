**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Cleans raw data from Spain EPF
**********************************************************************

cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"


local year = "06 07 08 09 10 11 12 13 14 15 16 17 18"

foreach y of local year {

use "$input/SPA/hog_`y'", clear

if `y' >= 15 {
rename estudredsp estudred_sp
rename estudiossp estudios_sp
}

keep numero impexac gastot gastmon factor estudred_sp edadsp nmiemb ccaa sexosp tamamu numero

gen year = 2000 + `y'

tempfile dat_`y'
save `dat_`y'', replace

}

local year = "06 07 08 09 10 11 12 13 14 15 16 17"

foreach y of local year {

append using `dat_`y''

}

replace gastot=gastot/(factor*12)
replace gastmon=gastmon/(factor*12)
gen ingtot = impexac + (gastot-gastmon)

destring sexosp ccaa estudred_sp tamamu, replace

save "$database/SPA/SPA_Cdata.dta" , replace
