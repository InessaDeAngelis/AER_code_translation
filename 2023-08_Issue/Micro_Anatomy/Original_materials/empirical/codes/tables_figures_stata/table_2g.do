**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table 1 panel g: Elasticities by employment level
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
 ******* Table 2 panel - Employment *******
 **********************************************
 
** ITALY

*** full-time employees ***

global input_data_ITA  = "$input/ITA/storico_stata"

u "$input_data_ITA/ldip.dta", clear

gen ft_employee = 1 if oretot >=35 & attivp == 1 & partean == 0 & partime == 0 & mesilav == 12
*oretot = hours worked including overtime, taking full-time as 35 or more
*attivp = 1 if main activity
*partean = 0 if duration of activity was all year
*partime = 0 if not part-time activity
*mesilav = 12 if individual worked 12 months in the year
*documentation: https://www.bancaditalia.it/statistiche/tematiche/indagini-famiglie-imprese/bilanci-famiglie/documentazione/Shiw-Historical-Database.pdf?language_id=1

collapse(mean) ft_employee, by(anno nquest)

rename anno year

tempfile fte
save `fte' , replace

u "$database/resid_ITA.dta", clear

* key variables

keep year uy uc ly lc studio freqwt probwt nquest

merge 1:1 year nquest using `fte'
drop if _merge == 2
drop _merge

collapse(mean) uc uy [fw=freqwt], by(year ft_employee)

replace uy = ln(uy)
replace uc = ln(uc)

xtset ft_employee year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy
keep if year == 2014
keep ft_employee g_uc g_uy elast
gen ty = "ft_employee"
gen episode = "Italy"

tempfile italy
save `italy' , replace


** MEXICO

global input_mex = "$input/MEX"

local year = "94 96"

foreach y of local year {

use "$input_mex/poblacion_`y'.dta", clear

decode FOLIO, gen(FOLIO_)
drop FOLIO
rename FOLIO_ FOLIO

decode TOT_HRS, gen(TOT_HRS_)

gen ft_employee = 1 if TOT_HRS >=35 & POSICION == 1
replace ft_employee = 1 if TOT_HRS >=35 & POSICION == 2

collapse (mean) ft_employee, by(FOLIO)

gen year = 1900 + `y'

tempfile emp_`y'
save `emp_`y'' , replace
}

*2006 employment data
use "$input_mex/poblacion_06.dta", clear

rename folio FOLIO

gen ft_employee = 1 if horas_trab >=35 & posicion07 == "1"
replace ft_employee = 1 if horas_trab >=35 & posicion07 == "2"
*analogous definitions to 1994 and 1996 above

collapse (mean) ft_employee, by(FOLIO)

gen year = 2006

tempfile emp_06
save `emp_06', replace

*2010 employment data
use "$input_mex/trabajos_10.dta", clear

gen ft_employee = 1 if htrab >=35 & subor == "1" & pago == "1"
*htrab = “Horas trabajadas” = “Hours worked”
*subor = “Fue subordinado” = “Was subordinate” 1 Sí
*pago = “Como le pagaron” = “How did you get paid” 1 Recibe un pago 1 Receive a payment 

egen FOLIO = concat(folioviv foliohog)

collapse (mean) ft_employee, by(FOLIO)

gen year = 2010

tempfile emp_2010
save `emp_2010', replace


append using `emp_94'
append using `emp_96'
append using `emp_06'


tempfile fte
save `fte' , replace

u "$database/resid_MEX.dta", clear

keep FOLIO year uy uc ly lc freqwt probwt

merge 1:1 year FOLIO  using `fte'
drop if _merge == 2
drop _merge

collapse(mean) uc uy  [fw=freqwt], by(year ft_employee)

replace uy = ln(uy)
replace uc = ln(uc)

xtset ft_employee year

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

keep ft_employee g_uc g_uy elast year

gen ty = "ft_employee"

gen episode = "Mexico - Tequila"
replace episode = "Mexico - GFC" if year == 2010 
drop year

tempfile mexico
save `mexico' , replace


** PERU

global input_PER = "$input/PER"

** merge household head charceristics to sumaria data

local year = "2007 2010"
foreach y of local year {

use "$input_PER/enaho01a-`y'-500.dta", clear

rename a* year

rename p507 emp
rename p513t hours_total
rename p520 hours_normal

gen id_HH = year + conglome + vivienda + hogar

tempfile dat_`y'
save `dat_`y'', replace
}

local year = "2007"
foreach y of local year {

append using `dat_`y'', force
}

keep year id_HH emp hours*

gen ft_employee = 1 if hours_total >=35 & emp == 3
replace ft_employee = 1 if hours_total >=35 & emp == 4
*taking full-time as 35 or more hours per week
*p513t = Total de horas trabajadas = “Total hours worked” [many more data, fewer missing]
*p520 = Normalmente, Cuantas horas trabaja en la semana? = “Normally, how many hours do you work in the week?” [more missing values]
*p507 = 3 En su centro de trabajo Ud. era: Empleado? = "In your workplace you were: Employee?"
*p507 = 4 En su centro de trabajo Ud. era: Obrero? = "In your workplace you were: Worker?"
*From DiccionarioDatos.pdf file

collapse(mean) ft_employee, by(year id_HH)

destring year, replace

tempfile fte
save `fte' , replace

u "$database/PER/PER_Cdata_charact.dta", clear /* load dataset with more characteristics (e.g., ownership) for Peru */

* variable

tostring year, gen(yearS)

gen id_HH = yearS + conglome + vivienda + hogar
keep year uy uc ly lc freqwt probwt id_HH

destring year, replace

* key variables

merge 1:1 year id_HH using `fte'
drop if _merge == 2
drop _merge

collapse(mean) uc uy [fw=freqwt], by(year ft_employee)

replace uy = ln(uy)
replace uc = ln(uc)

xtset ft_employee year

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy
keep if year == 2010

keep ft_employee g_uc g_uy elast

gen ty = "ft_employee"
gen episode = "Peru"

*** TABLE WITH RESULTS ***

append using `mexico'
append using `italy'

sum elast if ft_employee == 1
local elast_1 = r(mean)

sum elast if ft_employee == .
local elast_2 = r(mean)

** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "& Yes &" in `row'
replace tc2 = " & " + string(elast[7],"%9.2f") in `row'
replace tc3 = " & N/A" in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[3],"%9.2f") in `row'
replace tc6 = " & " + string(elast[4],"%9.2f") in `row'
replace tc7 = " & " + string(elast[1],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_1',"%9.2f") in `row'

local ++row
replace tc1 = "& No &" in `row'
replace tc2 = " & " + string(elast[8],"%9.2f") in `row'
replace tc3 = " & N/A" in `row'
replace tc4 = "& \hspace{.5em}"  in `row'
replace tc5 = " & " + string(elast[5],"%9.2f") in `row'
replace tc6 = " & " + string(elast[6],"%9.2f") in `row'
replace tc7 = " & " + string(elast[2],"%9.2f") in `row'
replace tc8 = " & " in `row'
replace tc9 = " & " + string(`elast_2',"%9.2f") in `row'
replace tc10 = "& \hspace{-1em} \vspace{.5em}" in `row'

outsheet tc* in 1/`row' using "$output/table2_g.tex", noquote nonames delimit(" ") replace

