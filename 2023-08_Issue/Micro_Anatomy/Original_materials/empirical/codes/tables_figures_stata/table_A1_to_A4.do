**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code creates tables A.1 to A.4
* Counts the number of observations
**********************************************************************

cls
clear all
set mem 200m
set more off

global database   = "$user/working_data"
global input      = "$user/input"
global output     = "$user/output"

******************************************************************* 
********* Number of observations baseline sample criteria *********
*******************************************************************

*** ITA *** 

global input_data_ITA  = "$user/input/ITA"

u "$input_data_ITA/storico_stata/comp.dta", clear

* hh size = ncomp
rename ncomp hhsize 
* region = 
rename  area3 region
* area = acom4c (by size)
rename  acom4c estrato
* hh head 
keep if cfred == 1

gen count = 1
qui sum count
display r(sum)

* sample years
keep if anno>=1995 &  anno<=2016
qui sum count
local obs_ITA_1 = r(N)

* remove small location
drop if acom5 == 1
qui sum count
local obs_ITA_2 = r(N)

* age 
rename eta age
keep if age<=60 & age>=25
qui sum count
local obs_ITA_3 = r(N)

tempfile sample1
save `sample1', replace

*** hh income and consumption ***

* income

u "$input_data_ITA/storico_stata/rfam.dta", clear

merge 1:1 nquest anno using `sample1'
keep if _merge == 3
drop _merge

gen income = yl - yl2 + yt + ym + yca1 /* excludes financial income, in kind payments and imputed rents */

tempfile ydata
save `ydata', replace

* consumption

u "$input_data_ITA/storico_stata/cons.dta", clear

merge 1:1 nquest anno using `ydata'
keep if _merge == 3
drop _merge

merge 1:1 nquest anno using "$input_data_ITA/storico_stata/peso.dta"
keep if _merge == 3
drop _merge

gen consum = cn - yca2  - yl2 /* non-durable and monetary */

gen C_Y = consum/income

* remove outliers 

drop if consum <=0 | consum == .
drop if income <=0 | income == .

drop if C_Y == .

_pctile C_Y [aweight=peso], p(.5 99.5)
local C_Y_l=r(r1)
local C_Y_u=r(r2)

drop if C_Y<`C_Y_l'
drop if C_Y>`C_Y_u'

qui sum count
local obs_ITA_4 = r(N)

* crisis sample

keep if anno==2006 | anno==2014
qui sum count
local obs_ITA_5 = r(N)

*** Table A.1

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "All units, 1995-2016" in `row'
replace tc2 = " & " in `row'
replace tc3 = " & " + string(`obs_ITA_1',"%9.0fc") in `row'

local ++row
replace tc1 = "Excluding residents in small locations \hspace*{.5em}" in `row'
replace tc2 = " & " + string(`obs_ITA_1' - `obs_ITA_2',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_ITA_2',"%9.0fc") in `row'

local ++row
replace tc1 = "Excluding age $<$ 25 or $>$ 60" in `row'
replace tc2 = " & " + string(`obs_ITA_2' - `obs_ITA_3',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_ITA_3',"%9.0fc") in `row'

local ++row
replace tc1 = "Excluding outliers" in `row'
replace tc2 = " & " + string(`obs_ITA_3' - `obs_ITA_4',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_ITA_4',"%9.0fc") in `row'

local ++row
replace tc1 = "\midrule Crisis episode (2006 and 2014)" in `row'
replace tc2 = " & " in `row'
replace tc3 = " & " + string(`obs_ITA_5',"%9.0fc") in `row'

outsheet tc* in 1/`row' using "$output/tableA1.tex", noquote nonames delimit(" ") replace

*** SPA *** 

global input_data_SPA = "$user/input/SPA"


*** Non durable ***
local year = "2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018"

foreach y of local year {

use "$database/SPA/gastos`y'", clear /* this files come from file SPA_clean_C which defines consumption baskets */

keep if serv == 1 | ndurab == 1

collapse(sum) gastmon gasto, by(numero)

rename gastmon nondurab
rename gasto nondurab_all

gen year = `y'

tempfile data_`y'
save `data_`y'', replace
}

local year = "2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"

foreach y of local year {
append using `data_`y''
}

tempfile nondurab
save `nondurab', replace

u "$database/SPA/SPA_Cdata.dta", clear

merge 1:1 year numero using `nondurab'

drop if _merge == 1
drop _merge

replace nondurab=nondurab/(factor*12)
replace nondurab_all=nondurab_all/(factor*12)

** All

gen count = 1
egen sample_1 = sum(count)
qui sum count
local obs_SPA_1 = r(N)

** Less than 10,000

drop if tamamu == 5
qui sum count
local obs_SPA_2 = r(N)

** Age

drop if edadsp<25
drop if edadsp>60
qui sum count
local obs_SPA_3 = r(N)

** Outliers

drop if impexac <= 0
drop if ingtot <= 0
drop if gastot <= 0
drop if gastmon <= 0

gen ratio = gastmon/impexac
gen factor_r = round(factor)
 
_pctile ratio [fweight=factor_r], p(.5 99.5)
local l=r(r1)
local u=r(r2)

drop if ratio<`l'
drop if ratio>`u'

drop ratio
qui sum count
local obs_SPA_4 = r(N)

** Crisis sample

qui sum count if year == 2008 | year == 2013
local obs_SPA_5 = r(N)

*** Table A.2

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "All units, 2006-2018" in `row'
replace tc2 = " & " in `row'
replace tc3 = " & " + string(`obs_SPA_1',"%9.0fc") in `row'

local ++row
replace tc1 = "Excluding residents in small locations \hspace*{.5em}" in `row'
replace tc2 = " & " + string(`obs_SPA_1' - `obs_SPA_2',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_SPA_2',"%9.0fc") in `row'

local ++row
replace tc1 = "Excluding age $<$ 25 or $>$ 60" in `row'
replace tc2 = " & " + string(`obs_SPA_2' - `obs_SPA_3',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_SPA_3',"%9.0fc") in `row'

local ++row
replace tc1 = "Excluding outliers" in `row'
replace tc2 = " & " + string(`obs_SPA_3' - `obs_SPA_4',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_SPA_4',"%9.0fc") in `row'

local ++row
replace tc1 = "\midrule Crisis episode (2008 and 2013)" in `row'
replace tc2 = " & " in `row'
replace tc3 = " & " + string(`obs_SPA_5',"%9.0fc") in `row'

outsheet tc* in 1/`row' using "$output/tableA2.tex", noquote nonames delimit(" ") replace


*** MEX *** 

global input_data_MEX = "$database/MEX"


*** Non durable ***
local yearl = "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014"

foreach x of local yearl {
use "$input_data_MEX/basket`x'.dta", replace
keep if ndurab == 1 | serv == 1
gen year = `x'
collapse(sum) GAS_TRI, by(FOLIO year)
tempfile data_`x'
save `data_`x'', replace
}

local yearl = "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012"
foreach x of local yearl {
append using `data_`x''
}

tempfile nondurab
save `nondurab', replace

local year = "1992 1994 1996 1998 2000 2002 2004 2005 2006 2008 2010 2012 2014"

foreach y of local year {
use "$input_data_MEX/merge_`y'.dta" , clear

keep FOLIO INGCOR GASCOR HOG RENTA year EDAD SEX age educ2 state_code SEC TAM_HOG INGMON GASMON ESTRATO KIDS

tempfile sum_`y'
save `sum_`y'', replace
}

local year = "1992 1994 1996 1998 2000 2002 2004 2005 2006 2008 2010 2012"
foreach y of local year {
append using `sum_`y''
}

merge 1:1 year FOLIO using `nondurab' 
drop if year == 2005
drop if _merge == 2
drop if _merge == 1
drop _merge

replace GAS_TRI = GAS_TRI/1000 if year ==1992

* All sample

gen count = 1
qui sum count
local obs_MEX_1 = r(N)

* Missing HH characteristics

rename educ2 EDUC
drop age

drop if EDAD == .
drop if EDUC == .
drop if TAM_HOG == .
drop if SEX == .
drop if state_code == .

qui sum count
local obs_MEX_2 = r(N)


* drop if area less than 2,500 residents

drop if ESTRATO == 4
qui sum count
local obs_MEX_3 = r(N)


* Age

drop if EDAD>60
drop if EDAD<25

qui sum count
local obs_MEX_4 = r(N)

* Outliers (Income<=0 and C/Y in top .5 and bottom .5)

drop if INGMON <= 0 
drop if GASMON <= 0

drop if INGCOR <= 0 
drop if GASCOR <= 0

gen ratio = GASMON/INGMON

_pctile ratio [fweight=HOG], p(.5 99.5)
local l=r(r1)
local u=r(r2)

drop if ratio<`l'
drop if ratio>`u'

drop ratio

qui sum count
local obs_MEX_5 = r(N)

* Crisis samples

qui sum count if year == 1994 | year == 1996
local obs_MEX_6 = r(N)

qui sum count if year == 2006 | year == 2010
local obs_MEX_7 = r(N)

*** Table A.3

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "All units, 2006-2018" in `row'
replace tc2 = " & " in `row'
replace tc3 = " & " + string(`obs_MEX_1',"%9.0fc") in `row'

local ++row
replace tc1 = "Excluding missing data" in `row'
replace tc2 = " & " + string(`obs_MEX_1' - `obs_MEX_2',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_MEX_2',"%9.0fc") in `row'

local ++row
replace tc1 = "Excluding residents in small locations \hspace*{.5em}" in `row'
replace tc2 = " & " + string(`obs_MEX_2' - `obs_MEX_3',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_MEX_3',"%9.0fc") in `row'

local ++row
replace tc1 = "Excluding age $<$ 25 or $>$ 60" in `row'
replace tc2 = " & " + string(`obs_MEX_3' - `obs_MEX_4',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_MEX_4',"%9.0fc") in `row'

local ++row
replace tc1 = "Excluding outliers" in `row'
replace tc2 = " & " + string(`obs_MEX_4' - `obs_MEX_5',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_MEX_5',"%9.0fc") in `row'

local ++row
replace tc1 = "\midrule Crisis episode 1 (1994 and 1996)" in `row'
replace tc2 = " & " in `row'
replace tc3 = " & " + string(`obs_MEX_6',"%9.0fc") in `row'

local ++row
replace tc1 = "Crisis episode 2 (2006 and 2010)" in `row'
replace tc2 = " & " in `row'
replace tc3 = " & " + string(`obs_MEX_7',"%9.0fc") in `row'

outsheet tc* in 1/`row' using "$output/tableA3.tex", noquote nonames delimit(" ") replace


*** PER *** 

global input_data_PER = "$database/PER"

use "$input_data_PER/PER_Cdata.dta", clear

rename mes_ month
gen year_month = year_n + "_" + month

merge m:1 year_month using "$input/PER/CPI.dta"
drop if _merge==2
drop _merge

destring year_n, replace

* All

gen count = 1

qui sum count
local obs_PER_1 = r(N)

* Urban area

drop if estrato_ == .
gen urban = (estrato_ <7)
keep if urban == 1

qui sum count
local obs_PER_2 = r(N)

* Age

gen age_sel = (25 <= age & age <= 60)
keep if age_sel == 1

qui sum count
local obs_PER_3 = r(N)

* Outliers

drop if gashog1d_<= 0 
drop if gashog2d_<= 0 
drop if ingmo2hd_<= 0 
drop if inghog2d_<= 0 

gen gas_ing_tot=gashog1d_/ingmo2hd_
gen factor07_r = round(factor07)


_pctile gas_ing_tot [fweight=factor07_r], p(.5 99.5)
local l=r(r1)
local u=r(r2)

drop if gas_ing_tot<`l'
drop if gas_ing_tot>`u'

drop gas_ing_tot

qui sum count
local obs_PER_4 = r(N)

* Crisis epsiode (2007 and 2010)

qui sum count if year_n == 2007 | year_n == 2010 
local obs_PER_5 = r(N)

*** Table A.4

if _N<500 set obs 500

forval i = 0/10 {
gen tc`i' = ""
}
gen tcEnd = "\\"
local row = 0

local ++row
replace tc1 = "All units, 2004-2018" in `row'
replace tc2 = " & " in `row'
replace tc3 = " & " + string(`obs_PER_1',"%9.0fc") in `row'

local ++row
replace tc1 = "Excluding residents in small locations \hspace*{.5em}" in `row'
replace tc2 = " & " + string(`obs_PER_1' - `obs_PER_2',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_PER_2',"%9.0fc") in `row'

local ++row
replace tc1 = "Excluding age $<$ 25 or $>$ 60" in `row'
replace tc2 = " & " + string(`obs_PER_2' - `obs_PER_3',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_PER_3',"%9.0fc") in `row'

local ++row
replace tc1 = "Excluding outliers" in `row'
replace tc2 = " & " + string(`obs_PER_3' - `obs_PER_4',"%9.0fc") in `row'
replace tc3 = " & " + string(`obs_PER_4',"%9.0fc") in `row'

local ++row
replace tc1 = "\midrule Crisis episode (2007 and 2010)" in `row'
replace tc2 = " & " in `row'
replace tc3 = " & " + string(`obs_PER_5',"%9.0fc") in `row'

outsheet tc* in 1/`row' using "$output/tableA4.tex", noquote nonames delimit(" ") replace


