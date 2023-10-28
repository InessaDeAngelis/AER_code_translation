**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Table B10
* Computes decile level CPI to 1 digit and do elasticities
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

 ************************
 ******* Table B10 *******
 ************************
 
** MEX

**** CPI - income specific indexed ****

local year = "92 94 96 98 00 02 04 05 06 08 10"
foreach x of local year {

if `x' >90 {
local y = `x' + 1900
}
if `x' <90 {
local y = `x' + 2000
}

use "$input/MEX/concen_`x'.dta", clear

if `y'>=2006 rename alimentos ALIMENTOS 
if `y'>=2006 rename vestido_c VESTIDO 
if `y'>=2006 rename vivienda VIVIENDA
if `y'>=2006 rename limpieza LIMPIEZA
if `y'>=2006 rename salud SALUD
if `y'>=2006 rename transporte TRANSPORTE
if `y'>=2006 rename educacion EDUCACION
if `y'>=2006 rename personal PERSONAL

rename GASMON gasmon

if `y' < 2006 {
decode FOLIO, gen(FOLIO_)
drop FOLIO
rename FOLIO_ FOLIO
}

if `y' == 2006 rename folio FOLIO
if `y' > 2006 gen FOLIO = folioviv + foliohog

gen year = `y'

keep ALIMENTOS VESTIDO VIVIENDA LIMPIEZA SALUD TRANSPORTE EDUCACION PERSONAL FOLIO year

tempfile temp_`y'
save `temp_`y'', replace

}

local year = "1992 1994 1996 1998 2000 2002 2004 2005 2006 2008"
foreach y of local year {
append using `temp_`y''
}

merge 1:1 year FOLIO using "$database/resid_MEX.dta"
drop if _merge == 1

replace uy = ln(uy)
replace uc = ln(uc)

local year = "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014" 
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=HOG_r] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}


tempfile data_micro
save `data_micro', replace

**** CPI - construction ****

collapse(mean) ALIMENTOS VESTIDO VIVIENDA LIMPIEZA SALUD TRANSPORTE EDUCACION PERSONAL [fw=HOG_r], by(decile year)

gen TOT = ALIMENTOS + VESTIDO + VIVIENDA + LIMPIEZA + SALUD + TRANSPORTE + EDUCACION + PERSONAL

foreach x of varlist ALIMENTOS VESTIDO VIVIENDA LIMPIEZA SALUD TRANSPORTE EDUCACION PERSONAL TOT {
gen s_`x' = `x'/TOT
}

keep s_* year decile

tempfile data_share
save `data_share' , replace

merge m:1 year using "$database/MEX/CPI_cat.dta"
drop if _merge == 2
drop _merge

xtset decile year
forval i=0/8 {
gen g_CPI_`i' = index`i'/L2.index`i' - 1
}

gen g_CPI_new = g_CPI_1*L2.s_ALIMENTOS + g_CPI_2*L2.s_VESTIDO + g_CPI_3*L2.s_VIVIENDA + g_CPI_4*L2.s_LIMPIEZA + g_CPI_5*L2.s_SALUD + g_CPI_6*L2.s_TRANSPORTE +  g_CPI_7*L2.s_EDUCACION +  g_CPI_8*L2.s_PERSONAL
drop if year == 2005
drop if year == 2012
drop if year == 2014

gen CPI_new =100
forval j = 1/10 { 
forval i=1/9 {
local h = (`j'-1)*10 + 1 + `i'
replace CPI_new = (1+g_CPI_new)*L2.CPI_new in `h'
}
}

keep CPI_new decile year

tempfile CPI_deciles_resid
save `CPI_deciles_resid', replace

************************************************************************************************************
* new CPI for C

u `data_micro', clear

merge m:1 year decile using `CPI_deciles_resid', nogenerate
drop if GASCOR == .
drop if CPI_new == .

* consumption adjusted by CPI specific to income level
gen consum_new = index*consum/CPI_new
gen lc_new = ln(consum_new)

reg lc_new EDAD EDAD2 SEXb* EDUCb* ESTRATOb* YEDUCb* TAM_HOGb* YSEXb*  year [aw=HOG]
predict uc_new if e(sample),res

* elasticities

* Deciles

replace uy = exp(uy)
replace uc = exp(uc)
replace uc_new = exp(uc_new)

tempfile sample_data
save `sample_data', replace

collapse(mean) uc_new uc uy  [fw=HOG_r], by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)
replace uc_new = ln(uc_new)

xtset decile year

gen g_uy = uy - L2.uy
gen g_uc = uc - L2.uc
gen g_uc_new = uc_new - L2.uc_new

gen elast = g_uc/g_uy
gen elast_new = g_uc_new/g_uy

gen g_uy2 = uy - L4.uy
gen g_uc2 = uc - L4.uc
gen g_uc2_new = uc_new - L4.uc_new

gen elast2 = g_uc2/g_uy2
gen elast2_new = g_uc2_new/g_uy2

keep if year == 1996 | year == 2010

drop elast2 elast g_uc2 g_uc
rename elast2_new elast2
rename elast_new elast
rename g_uc2_new g_uc2
rename g_uc_new g_uc

replace elast = elast2 if year == 2010
replace g_uc = g_uc2 if year == 2010
replace g_uy = g_uy2 if year == 2010
keep elast g_uc g_uy decile year

keep if decile == 10
gen episode = "Mexico - Tequila" if year == 1996
replace episode = "Mexico - GFC" if year == 2010
drop year

drop decile

gen categ = "top"

tempfile top
save `top', replace

* Average

u `sample_data', clear

collapse(mean) uc_new uc uy  [fw=HOG_r], by(year)

replace uy = ln(uy)
replace uc = ln(uc)
replace uc_new = ln(uc_new)

tsset year

gen g_uy = uy - L2.uy
gen g_uc = uc - L2.uc
gen g_uc_new = uc_new - L2.uc_new

gen elast = g_uc/g_uy
gen elast_new = g_uc_new/g_uy

gen g_uy2 = uy - L4.uy
gen g_uc2 = uc - L4.uc
gen g_uc2_new = uc_new - L4.uc_new

gen elast2 = g_uc2/g_uy2
gen elast2_new = g_uc2_new/g_uy2

keep if year == 1996 | year == 2010

drop elast2 elast g_uc2 g_uc
rename elast2_new elast2
rename elast_new elast
rename g_uc2_new g_uc2
rename g_uc_new g_uc

replace elast = elast2 if year == 2010
replace g_uc = g_uc2 if year == 2010
replace g_uy = g_uy2 if year == 2010
keep elast g_uc g_uy year

gen episode = "Mexico - Tequila" if year == 1996
replace episode = "Mexico - GFC" if year == 2010
drop year

gen categ = "all"
tempfile all
save `all', replace

************************************************************************************************************
*** Price index evolution around crisis episodes

use "$database/MEX/CPI_cat_monthly.dta", replace
keep yearmonth month year code index 
reshape wide index, i(yearmonth) j(code) 

* quarterly

gen quarter = .
replace quarter = 1 if month<=3
replace quarter = 2 if month>=4 & month<=6
replace quarter = 3 if month>=7 & month<=9
replace quarter = 4 if month>=10 & month<=12

collapse (mean) index*, by(year quarter)

rename year year_data
gen year = year_data if quarter == 3

tempfile dec
save `dec', replace

forval i = 1/10 {
use `dec', clear

gen decile = `i'

tempfile dec_`i'
save `dec_`i'', replace
}

forval i = 1/9 {
append using `dec_`i''
}

merge m:1 year decile using `data_share'

drop if year_data<1992
drop if year_data==1992 & quarter<3
drop if year_data>2010
drop if year_data==2010 & quarter>3

sort decile year_data quarter

gen y_q = yq(year_data, quarter)
format y_q %tq

xtset decile y_q

local categ = "ALIMENTOS VESTIDO VIVIENDA LIMPIEZA SALUD TRANSPORTE EDUCACION PERSONAL"

foreach x of local categ {

gen s_`x'_int = .
forval i = 1/10 {
ipolate s_`x' y_q if decile == `i', gen(i_s_`x'_`i')
replace s_`x'_int = i_s_`x'_`i' if decile == `i'
}
drop i_*
}

forval i=1/8 {
gen m_`i' = index`i'/L1.index`i' - 1
}

gen g_CPI_new = m_1*L1.s_ALIMENTOS_int + m_2*L1.s_VESTIDO_int + m_3*L1.s_VIVIENDA_int + m_4*L1.s_LIMPIEZA_int + m_5*L1.s_SALUD_int + m_6*L1.s_TRANSPORTE_int +  m_7*L1.s_EDUCACION_int +  m_8*L1.s_PERSONAL_int

gen CPI_new = 100

replace CPI_new =100
forval j = 1/10 { 
forval i=1/72 {
local h = (`j'-1)*73 + 1 + `i'
replace CPI_new = (1+g_CPI_new)*L1.CPI_new in `h'
}
}

keep year_data quarter CPI_new y_q decile index0

* plot time series prices

gen CPI_rel = .
replace CPI_new = ln(CPI_new)
replace index0 = ln(index0)

* Tequila

forval i = 1/10 {
qui sum CPI_new if quarter == 3 & year == 1994 & decile == `i', detail
replace CPI_new = CPI_new - r(mean) if decile == `i'
}

egen CPI_mean_T = mean(CPI_new), by(y_q)

replace CPI_rel = CPI_new - CPI_mean_T

tempfile CPI_rel
save `CPI_rel', replace

*top decile
keep if decile == 10
replace CPI_rel = - CPI_rel*100
keep if year == 1996 & quarter == 4

keep CPI_rel

gen episode = "Mexico - Tequila"

gen categ = "CPI_rel"

tempfile MEX_T
save `MEX_T', replace

* Lehman

use `CPI_rel', clear

forval i = 1/10 {
qui sum CPI_new if quarter == 3 & year == 2006 & decile == `i', detail
replace CPI_new = CPI_new - r(mean) if decile == `i'
}

egen CPI_mean_L = mean(CPI_new), by(y_q)

replace CPI_rel = CPI_new - CPI_mean_L

*top decile
keep if decile == 10
replace CPI_rel = - CPI_rel*100
keep if year == 2008 & quarter == 4

keep CPI_rel

gen episode = "Mexico - GFC"

gen categ = "CPI_rel"

append using `MEX_T'

append using `all'
append using `top'

tempfile MEX
save `MEX', replace

*** PER 

use "$database/PER/PER_Cdata_charact.dta", clear

gen year_n = year

* deciles

gen decile = .
levelsof year_n, local(yearl)
foreach x of local yearl {
xtile decile_`x' = uy if year_n == `x' [fw=factor07_r], nq(10)
replace decile = decile_`x' if year_n == `x'
drop decile_`x'
}

drop if decile == .

** share by decile and year

gen foodhome = food - foodout

collapse(mean) foodhome foodout transport housing muebles health clothes entretainment other [fw=factor07_r], by(year decile)

* include entretainment in other; missing is education expenditure

replace other = other + entretainment
gen total = foodhome + foodout + clothes + housing + muebles + health + transport + other

local vars = "foodhome foodout transport housing muebles health clothes other"
foreach x of local vars {
gen s_`x' = `x'/total
}

keep year decile s_*

destring year, replace

reshape wide s_foodhome s_foodout s_transport s_housing s_muebles s_health s_clothes s_other, i(year) j(decile)

gen month = 2

tempfile shares_c
save `shares_c', replace

**** CPI by decile ****

import excel "$input/PER/CPI_cat_PER.xlsx", sheet("monthly") firstrow clear

gen year = year(date)
gen month = month(date)

merge 1:1 month year using `shares_c'

gen year_month = ym(year,month)
format %tm year_month 

tsset year_month

forval i = 1/10 {
ipolate   s_foodhome`i' year_month, gen(is_foodhome`i') e
ipolate   s_foodout`i' year_month, gen(is_foodout`i') e
ipolate   s_transport`i' year_month, gen(is_transport`i') e
ipolate   s_housing`i' year_month, gen(is_housing`i') e
ipolate   s_health`i' year_month, gen(is_health`i') e 
ipolate   s_clothes`i' year_month, gen(is_clothes`i') e 
ipolate   s_muebles`i' year_month, gen(is_muebles`i') e
ipolate   s_other`i' year_month, gen(is_other`i') e
}


forval i = 1/10 {

gen g_CPI_`i' = is_foodhome`i'*foodhome + is_foodout`i'*foodout + is_transport`i'*transport + is_housing`i'*housing + ///
 is_clothes`i'*clothes + is_health`i'*health + is_muebles`i'*muebles + is_other`i'*other

}

keep g_CPI_* year month

gen year_month = ym(year,month)
format %tm year_month 

forval i = 1/10 {
gen CPI_`i' = 100 in 144
replace CPI_`i' = CPI_`i'[_n-1]*(1+g_CPI_`i'[_n]) if year_month>tm(2004m1)
gen lCPI_`i' = ln(CPI_`i')
}

* plot prices

gen mean_CPI = (CPI_1 + CPI_2 + CPI_3 + CPI_4 + CPI_5 + CPI_6 + CPI_7 + CPI_8 + CPI_9 + CPI_10)/10
replace mean_CPI = ln(mean_CPI)

forval i = 1/10 {
replace lCPI_`i' = lCPI_`i' - mean_CPI
}

tempfile PER_data
save `PER_data', replace

*top decile
gen CPI_rel = - lCPI_10*100
keep if year == 2008 & month == 1 
keep CPI_rel 

gen episode = "Peru"

gen categ = "CPI_rel"

tempfile CPI_rel
save `CPI_rel', replace


***** adjusted to relative prices ******

use `PER_data', clear

keep CPI_* year month

rename year year_n

tempfile rel_prices
save `rel_prices', replace

use "$database/PER/PER_Cdata_charact.dta", clear

replace uy = ln(uy)
replace uc = ln(uc)

destring month, replace
gen year_n = year

merge m:1 year_n month using `rel_prices'
keep if _merge == 3
drop _merge 

*** deciles of residualized income (by year) 

gen decile = .
levelsof year_n, local(yearl)
foreach x of local yearl {
xtile decile_`x' = uy if year_n == `x' [fw=factor07_r], nq(10)
replace decile = decile_`x' if year_n == `x'
drop decile_`x'
}

drop if decile == .

* consumption adjusted by CPI specific to income level

gen consu_rel = .

forval i = 1/10 {
replace consu_rel = (gashog1d_ - rent_expend - hhequip_expend)/CPI_`i' if decile == `i'
}

gen lc_rel = ln(consu_rel)

reg lc_rel age age2 sexb* educ2b* mieperhob* size_large ysexb* yeducb* year_t year_n [aw=factor07_]
predict uc_rel if e(sample),res

* evolution residualized income and elasticities by income group

replace uy = exp(uy)
replace uc = exp(uc)
replace uc_rel = exp(uc_rel)

tempfile data_icpi
save `data_icpi', replace

u `data_icpi', clear

collapse(mean) uc_rel uc uy [fw=factor07_r], by(year_n decile)

replace uy = ln(uy)
replace uc = ln(uc)
replace uc_rel = ln(uc_rel)

xtset decile year_n

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc
gen g_uc_rel = uc_rel - L3.uc_rel

gen elast = g_uc/g_uy
gen elast_rel = g_uc_rel/g_uy

* Top 10

keep if year == 2010
keep if decile == 10

drop elast g_uc
rename elast_rel elast
rename g_uc_rel g_uc

keep elast g_uc g_uy

gen episode = "Peru"

gen categ = "top"

tempfile deciles
save `deciles', replace

* Average 

u `data_icpi', clear

collapse(mean) uc_rel uc uy [fw=factor07_r], by(year_n)

replace uy = ln(uy)
replace uc = ln(uc)
replace uc_rel = ln(uc_rel)

tsset year_n

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc
gen g_uc_rel = uc_rel - L3.uc_rel

gen elast = g_uc/g_uy
gen elast_rel = g_uc_rel/g_uy

keep if year == 2010

drop elast g_uc
rename elast_rel elast
rename g_uc_rel g_uc

keep elast g_uc g_uy

gen episode = "Peru"

gen categ = "all"

tempfile all
save `all', replace

use `CPI_rel', clear

append using `all'
append using `deciles'

tempfile PER
save `PER', replace


*** TABLE B10

append using `MEX'

sum CPI_rel if categ == "CPI_rel"
local CPI_rel_mean = r(mean)

sum g_uy if categ == "all"
local g_uy_all_mean = r(mean)
sum g_uy if categ == "top"
local g_uy_top_mean = r(mean)

sum g_uc if categ == "all"
local g_uc_all_mean = r(mean)
sum g_uc if categ == "top"
local g_uc_top_mean = r(mean)

sum elast if categ == "all"
local elast_all_mean = r(mean)
sum elast if categ == "top"
local elast_top_mean = r(mean)

** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0


local ++row
replace tc1 = "& \multicolumn{2}{l}{Average $-$ Top-income Inflation}\hspace*{.5em} \hspace{.5em}" in `row'
replace tc2 = " " in `row'
replace tc3 = " & " + string(CPI_rel[5],"%9.1f") + "\%" in `row'
replace tc4 = " & " + string(CPI_rel[4],"%9.1f") + "\%" in `row'
replace tc5 = " & " + string(CPI_rel[1],"%9.1f") + "\%" in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`CPI_rel_mean',"%9.1f") + "\%" + "& \hspace{-1em} \vspace{.5em}" in `row'


local ++row
replace tc1 = "& \multirow{2}{*}{$\Delta \log Y$}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(g_uy[6],"%9.2f") in `row'
replace tc4 = " & " + string(g_uy[7],"%9.2f") in `row'
replace tc5 = " & " + string(g_uy[2],"%9.2f") in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`g_uy_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(g_uy[8],"%9.2f") in `row'
replace tc4 = " & " + string(g_uy[9],"%9.2f") in `row'
replace tc5 = " & " + string(g_uy[3],"%9.2f") in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`g_uy_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{$\Delta \log C$}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(g_uc[6],"%9.2f") in `row'
replace tc4 = " & " + string(g_uc[7],"%9.2f") in `row'
replace tc5 = " & " + string(g_uc[2],"%9.2f") in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`g_uc_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(g_uc[8],"%9.2f") in `row'
replace tc4 = " & " + string(g_uc[9],"%9.2f") in `row'
replace tc5 = " & " + string(g_uc[3],"%9.2f") in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`g_uc_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

local ++row
replace tc1 = "& \multirow{2}{*}{Elasticity}\hspace*{.5em}" in `row'
replace tc2 = "& Average" in `row'
replace tc3 = " & " + string(elast[6],"%9.2f") in `row'
replace tc4 = " & " + string(elast[7],"%9.2f") in `row'
replace tc5 = " & " + string(elast[2],"%9.2f") in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`elast_all_mean',"%9.2f") in `row'

local ++row
replace tc1 = "& " in `row'
replace tc2 = "& Top-income" in `row'
replace tc3 = " & " + string(elast[8],"%9.2f") in `row'
replace tc4 = " & " + string(elast[9],"%9.2f") in `row'
replace tc5 = " & " + string(elast[3],"%9.2f") in `row'
replace tc6 = " & " in `row'
replace tc7 = " & " + string(`elast_top_mean',"%9.2f") + "& \hspace{-1em} \vspace{.5em}" in `row'

outsheet tc* in 1/`row' using "$output/tableB10_a.tex", noquote nonames delimit(" ") replace


*** TABLE B10 - OBSERVATIONS

u "$database/baseline_MEX.dta", clear

sum year if year == 1996 | year == 1994
local obs_MEX_T = r(N)

sum year if year == 2010 | year == 2006
local obs_MEX_L = r(N)

u "$database/baseline_PER.dta", clear

sum year_n if year_n == 2007 | year_n == 2010
local obs_PER = r(N)

** latex preamble

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local obs_TOT = `obs_MEX_T' + `obs_MEX_L' + `obs_PER'

local ++row
replace tc1 = "& \multicolumn{2}{l}{N Observations} \vspace{.2em}" in `row'
replace tc2 = " & " + string(`obs_MEX_T',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_MEX_L',"%9.0fc") in `row'
replace tc4 = " & " + string(`obs_PER',"%9.0fc") in `row'
replace tc5 = " & " in `row'
replace tc6 = " & " + string(`obs_TOT',"%9.0fc") in `row'

outsheet tc* in 1/`row' using "$output/tableB10_b.tex", noquote nonames delimit(" ") replace


