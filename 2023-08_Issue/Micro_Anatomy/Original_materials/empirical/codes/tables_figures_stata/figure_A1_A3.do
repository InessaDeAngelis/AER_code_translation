***********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figures A.1 and A.3
* Compares national accounts data with comparable micro data aggregates
***********************************************************************

***********************************************
* Micro vs Macro data
*********************************************** 

cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

*** National Accounts and Aggregate Microdata

***** ITA

** microdata

u "$input/ITA/storico_stata/comp.dta", clear

keep nquest anno ncomp 

collapse(mean) ncomp, by(nquest anno)

tempfile ncompd
save `ncompd', replace

* weights

u "$input/ITA/storico_stata/peso.dta", clear

keep nquest anno pesopop 

tempfile weights
save `weights', replace

* income

u "$input/ITA/storico_stata/rfam.dta", clear

gen income = yl + yt + ym + yc

drop if income == .

keep nquest anno income 

tempfile ydata
save `ydata', replace

* consumption

u "$input/ITA/storico_stata/cons.dta", clear

merge 1:1 nquest anno using `ydata'
keep if _merge == 3
drop _merge

merge 1:1 nquest anno using `ncompd'
keep if _merge == 3
drop _merge

merge 1:1 nquest anno using `weights'
keep if _merge == 3
drop _merge

gen pop = pesopop*ncomp

replace y = y*pop
replace c = c*pop
replace cn = cn*pop

collapse(sum) c cn y pop, by(anno)

replace y = y/pop
replace c = c/pop
replace cn = cn/pop

merge 1:1 anno using "$input/ITA/storico_stata/defl.dta"
keep if _merge == 3
drop _merge

replace y = y*rival
replace c = c*rival
replace cn = cn*rival

gen quarter = 4

replace y = ln(y)
replace c = ln(c)
replace cn = ln(cn)

rename anno year

local vars = "y c cn" 
foreach x of local vars {
qui sum `x' if year == 2006
replace `x' = `x' - r(mean)
}

tempfile microdata
save `microdata', replace

** aggregate

import excel "$input/aggregate/national_accounts_data.xls", sheet("ITA") firstrow clear

drop if year == .
drop date

* per capita
local vars = "gdp pce"
foreach x of local vars {
replace `x' = `x'/pop
}

collapse(mean) gdp pce, by(year)

* logs
local vars = "gdp pce"
foreach x of local vars {
replace `x' = ln(`x')
qui sum `x' if year == 2006
replace `x' = `x' - r(mean)
}

merge 1:1 year using `microdata'

** Figure A.1 - Panel a

sort year

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(line gdp year if year>=1995 & year<=2016 , lw(1) lc(dknavy)) ///
(line y year if year>=1995 & year<=2016 , lw(1) lc(maroon))  ///
, xtitle("date") ytitle("log-base = 0 in 2006") graphregion(color(white)) ///
legend(order (1 "National accounts" 2 "HH survey") row(2) size(small) region(lcolor(white)) ring(0) position(6)) ///
xlabel(,grid format(%1.0f))  xsize(`width_') ysize(`height_') ylabel(-.2(.1)0, grid)
graph export "$output/figureA1_a_i.pdf", replace

twoway ///
(line pce year if year>=1995 & year<=2016 , lw(1) lc(dknavy)) ///
(line c year if year>=1995 & year<=2016 , lw(1) lc(maroon))  ///
, xtitle("date") ytitle("log-base = 0 in 2006") graphregion(color(white)) ///
legend(off) ///
xlabel(,grid format(%1.0f))  xsize(`width_') ysize(`height_') ylabel(-.2(.1)0, grid)
graph export "$output/figureA1_a_ii.pdf", replace

***** SPA

import excel "$input/aggregate/national_accounts_data.xls", sheet("SPA") firstrow clear

drop if year == .
drop date

* per capita
local vars = "gdp pce"
foreach x of local vars {
replace `x' = `x'/pop
}

collapse(mean) gdp pce, by(year)

* logs
local vars = "gdp pce"
foreach x of local vars {
replace `x' = ln(`x')
qui sum `x' if year == 2006
replace `x' = `x' - r(mean)
}

tempfile agg_SPA
save `agg_SPA', replace

** microdata

u "$database/SPA/SPA_Cdata.dta", clear

gen pop_m = factor*nmiemb
replace gastmon= gastot*factor
replace impexac= impexac*factor

collapse (sum)  gastmon impexac pop_m, by(year)

replace gastmon = gastmon/pop_m
replace impexac = impexac/pop_m

merge m:1 year using "$input/SPA/CPI.dta"
drop if _merge==2
drop _merge

replace gastmon=gastmon/CPI
replace impexac=impexac/CPI

replace gastmon=ln(gastmon)
replace impexac=ln(impexac)

rename gastmon C_micro
rename impexac Y_micro

merge 1:1 year using `agg_SPA' 

rename gdp Y_macro
rename pce C_macro

local vara = "Y_macro Y_micro C_macro C_micro"
foreach x of local vara {
qui sum `x' if year == 2008, detail	
replace `x' = `x' - r(mean)
}

** Figure A.1 - Panel b

sort year

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(line Y_macro year if year>=2006 & year<=2018 , lw(1) lc(dknavy)) ///
(line Y_micro year if year>=2006 & year<=2018 , lw(1) lc(maroon))  ///
, xtitle("date") ytitle("log-base = 0 in 2008") graphregion(color(white)) ///
legend(order (1 "National accounts" 2 "HH survey") row(2) size(small) region(lcolor(white)) ring(0) position(4)) ///
xlabel(,grid format(%1.0f)) xsize(`width_') ysize(`height_') ylabel(-.2(0.1)0, grid)
graph export "$output/figureA1_b_i.pdf", replace

twoway ///
(line C_macro year if year>=2006 & year<=2018 , lw(1) lc(dknavy)) ///
(line C_micro year if year>=2006 & year<=2018 , lw(1) lc(maroon))  ///
, xtitle("date") ytitle("log-base = 0 in 2008") graphregion(color(white)) ///
legend(off) ///
ylabel(-.2(0.1)0,grid) xlabel(,grid format(%1.0f))  xsize(`width_') ysize(`height_')
graph export "$output/figureA1_b_ii.pdf", replace

***** MEX

** aggregate

import excel "$input/aggregate/national_accounts_data.xls", sheet("MEX_long") firstrow clear

drop if year == .
drop date

* per capita
local vars = "gdp pce"
foreach x of local vars {
replace `x' = `x'/pop
}

* logs
local vars = "gdp pce"
foreach x of local vars {
replace `x' = ln(`x')
qui sum `x' if year == 2008 & quarter == 3
replace `x' = `x' - r(mean)
}

gen year_var = year + quarter/4

tempfile agg_MEX
save `agg_MEX', replace

** microdata

global input_data_MEX = "$database/MEX"

local year = "1992 1994 1996 1998 2000 2002 2004 2005 2006 2008 2010 2012 2014"

foreach y of local year {
use "$input_data_MEX/merge_`y'.dta" , clear

collapse (sum) INGCOR GASCOR INGMON GASMON TAM_HOG [fweight=HOG]

gen year=`y'

tempfile sum_`y'
save `sum_`y'', replace
}

local year = "1992 1994 1996 1998 2000 2002 2004 2005 2006 2008 2010 2012"
foreach y of local year {
append using `sum_`y''
}

*replace INGCOR = INGMON
*replace GASCOR = GASMON
*replace INGCOR=INGCOR/1000 if year==1992
*replace GASCOR=GASCOR/1000 if year==1992

gen GDP_micro = INGMON/TAM_HOG
gen C_micro = GASMON/TAM_HOG
keep year GDP_micro C_micro


merge m:1 year using "$input/MEX/CPI.dta"
drop if _merge!=3
drop _merge

tsset year

foreach x of varlist GDP_micro C_micro {
replace `x'=`x'/index
replace `x'=ln(`x')
}

gen quarter = 3

merge 1:1 quarter year using `agg_MEX' 
sort year_var
keep pce gdp GDP_micro C_micro year year_var quarter
rename pce C_macro
rename gdp Y_macro
rename GDP_micro Y_micro

local vara = "Y_macro Y_micro C_macro C_micro"
foreach x of local vara {
qui sum `x' if year == 2000 & quarter == 3, detail
replace `x' = `x' - r(mean)
}

** Figure A.3 - Panel a

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(line Y_macro year_var if year>=1992 & year<=2016 , lw(1) lc(dknavy)) ///
(line Y_micro year_var if year>=1992 & year<=2016 , lw(1) lc(maroon))  ///
, xtitle("date") ytitle("log-base = 0 in 2000") graphregion(color(white)) ///
legend(order (1 "National accounts" 2 "HH survey") row(2) size(small) region(lcolor(white)) ring(0) position(4)) ///
ylabel(,grid) xlabel(,grid format(%1.0f))  xsize(`width_') ysize(`height_') ylabel(, grid)
graph export "$output/figureA3_a_i.pdf", replace

twoway ///
(line C_macro year_var if year>=1992 & year<=2016 , lw(1) lc(dknavy)) ///
(line C_micro year_var if year>=1992 & year<=2016 , lw(1) lc(maroon))  ///
, xtitle("date") ytitle("log-base = 0 in 2000") graphregion(color(white)) ///
legend(off) ///
ylabel(,grid format(%8.1g)) xlabel(,grid format(%1.0f))   xsize(`width_') ysize(`height_') ylabel(, grid)
graph export "$output/figureA3_a_ii.pdf", replace

***** PER

** aggregate

import excel "$input/aggregate/national_accounts_data.xls", sheet("PER") firstrow clear

keep pce gdp pop year
drop if pop == .
destring year, replace

* per capita
local vars = "gdp pce"
foreach x of local vars {
replace `x' = `x'/pop
}

* logs
local vars = "gdp pce"
foreach x of local vars {
replace `x' = ln(`x')
qui sum `x' if year == 2013
replace `x' = `x' - r(mean)
}

tempfile agg_data
save `agg_data', replace

** microdata

use "$database/PER/PER_Cdata.dta", clear

rename mes_ month
gen year_month = year_n + "_" + month

merge m:1 year_month using "$input/PER/CPI.dta"
drop if _merge==2
drop _merge

destring year_n, replace

* income and consumption definition

gen tax = ingmo2hd_/ingmo1hd_
gen inc = (ingmo2hd_- rents_income*tax)/CPI_index
gen consu = gashog1d_/CPI_index

gen pop = factor07_*mieperho_
replace inc = inc*factor07_
replace consu = consu*factor07_

collapse(sum) inc consu pop, by(year_n)

tsset year_n

local vars = "inc consu" 
foreach x of local vars {

replace `x' = `x'/pop
replace `x' = ln(`x')
qui sum `x' if year_n == 2013
replace `x' = `x' - r(mean)

}

rename year_n year

merge 1:1 year using `agg_data'

tsset year

** Figure A.3 - Panel b

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(line gdp year if year>=2005 & year<=2018 , lw(1) lc(dknavy)) ///
(line inc year if year>=2005 & year<=2018 , lw(1) lc(maroon))  ///
, xtitle("date") ytitle("log-base = 0 in 2013") graphregion(color(white)) ///
legend(order (1 "National accounts" 2 "HH survey") row(2) size(small) region(lcolor(white)) ring(0) position(4)) ///
xlabel(,grid format(%1.0f)) name(g, replace)  xsize(`width_') ysize(`height_') ylabel(, grid)
graph export "$output/figureA3_b_i.pdf", replace

twoway ///
(line pce year if year>=2005 & year<=2018 , lw(1) lc(dknavy)) ///
(line cons year if year>=2005 & year<=2018 , lw(1) lc(maroon))  ///
, xtitle("date") ytitle("log-base = 0 in 2013") graphregion(color(white)) ///
legend(off) ///
ylabel(,grid) xlabel(,grid format(%1.0f)) name(h, replace)  xsize(`width_') ysize(`height_')
graph export "$output/figureA3_b_ii.pdf", replace
