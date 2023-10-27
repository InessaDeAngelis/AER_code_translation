**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figure 2
**********************************************************************

cls
clear all
set mem 200m
set more off

global data_input = "$user/input/aggregate"
global output     = "$user/output"

****************************************************************************************
*\ figures format *\

local color_1 = "0 76 153"
local color_2 = "0 0 0"

local width_ = "2.6"
local height_ = "1.8"

****************************************************************************************
** Mexico **
*\ micro data sample 1992 - 2014 *\

import excel "$data_input/national_accounts_data.xls", sheet("MEX") firstrow clear

* per capita and logs
local vars = "gdp pce no_durable"
foreach x of local vars {
replace `x' = `x'/pop
replace `x' = ln(`x')
}

gen year_quarter = yq(year,quarter)
format year_quarter %tq

* de-trend

gen t = _n

local vars = "gdp pce no_durable"
foreach x of local vars {

reg `x' t if year<=2014 & year>=1992
gen `x'_trend_T = _b[_cons] + _b[t]*t
gen gap_`x'_T = `x'-`x'_trend_T

reg `x' t if year<=2014 & year>=1992
gen `x'_trend_L = _b[_cons] + _b[t]*t
gen gap_`x'_L = `x'-`x'_trend_L

}

* plots separate episodes

replace year = year + quarter/4

twoway ///
(connected gap_gdp_T year_quarter if year>=1994.49 & year<=1996, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5)) ///
(line gap_pce_T year_quarter if year>=1994.49 & year<=1996, lw(1) lc("`color_2'")) ///
(line gap_no_durable_T year_quarter if year>=1994.49 & year<=1996, lw(1) lc("`color_2'") lp(dash)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(-.10(.05)0.02,grid labsize(large)) xsize(`width_') ysize(`height_') yscale(titlegap(*+7)) xlabel(137(2)143,grid labsize(large)) ///
legend(off) xscale(range(143.12))
graph export "$output/figure2_c.pdf", replace

twoway ///
(connected gap_gdp_L year_quarter if year>=2008 & year<=2010, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5)) ///
(line gap_pce_L year_quarter if year>=2008 & year<=2010, lw(1) lc("`color_2'")) ///
(line gap_no_durable_L year_quarter if year>=2008 & year<=2010, lw(1) lc("`color_2'") lp(dash)) ///
, name(b,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(-.05(.05)0.05,grid labsize(large)) xsize(`width_') ysize(`height_') yscale(titlegap(*+7)) xlabel(,grid labsize(large)) ///
legend(off)  xscale(range(199.15))
graph export "$output/figure2_d.pdf", replace

****************************************************************************************
** Peru **
*\ annual and quarterly data *\

import excel "$data_input/national_accounts_data.xls", sheet("PER") firstrow clear
keep year gdp pce pop
drop if pce == .

local vars = "gdp pce"
foreach x of local vars {
replace `x' = `x'/pop
replace `x' = ln(`x')
}

destring year, replace
drop if gdp == .
drop pop

* de-trend 

gen t = _n

local vars = "gdp pce"
foreach x of local vars {
reg `x' t if year<=2018 & year>=2004
gen `x'_trend = _b[_cons] + _b[t]*t
gen gap_`x' = `x'-`x'_trend

}

* quarterly data

keep year gdp_trend pce_trend
gen quarter = 4
tempfile annual
save `annual', replace

import excel "$data_input/national_accounts_data.xls", sheet("PER") firstrow clear
keep date gdp_sa pce_sa I
rename I pop
drop if gdp_sa == .

gen year = year(date)
gen quarter = quarter(date)

merge 1:1 year quarter using `annual'

gen year_quarter = yq(year,quarter)
format year_quarter %tq

local vars = "gdp_sa pce_sa"
foreach x of local vars {
replace `x' = `x'/pop
replace `x' = ln(`x')
}

tsset year_quarter
ipolate gdp_trend year_quarter, gen(t_gdp)
ipolate pce_trend year_quarter, gen(t_pce)

gen dif_gdp = t_gdp - L1.t_gdp
gen dif_pce = t_pce - L1.t_pce

/* adjust trend level to fit missing quarterly data before 2007 using annual data */
local vars = "gdp pce"
foreach x of local vars {
gen `x'_trend_sa = .

if "`x'" == "gdp" {
replace `x'_trend_sa = `x'_sa - .035 if year_quarter==tq(2008q2)
}

if "`x'" == "pce" {
replace `x'_trend_sa = `x'_sa - .015 if year_quarter==tq(2008q2)
}

replace `x'_trend_sa = dif_`x' + L1.`x'_trend_sa if year_quarter>tq(2008q2)
replace `x'_trend_sa = F1.`x'_trend_sa - dif_`x' if year_quarter<tq(2008q2)
replace `x'_trend_sa = F1.`x'_trend_sa - dif_`x' if year_quarter<tq(2008q2)
replace `x'_trend_sa = F1.`x'_trend_sa - dif_`x' if year_quarter<tq(2008q2)
replace `x'_trend_sa = F1.`x'_trend_sa - dif_`x' if year_quarter<tq(2008q2)
replace `x'_trend_sa = F1.`x'_trend_sa - dif_`x' if year_quarter<tq(2008q2)
replace `x'_trend_sa = F1.`x'_trend_sa - dif_`x' if year_quarter<tq(2008q2)
gen gap_`x' = `x'_sa - `x'_trend_sa
}

* plots
replace year = year + quarter/4

twoway ///
(connected gap_gdp year_quarter if year>=2008 & year<=2010, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5)) ///
(line gap_pce year_quarter if year>=2008 & year<=2010, lw(1) lc("`color_2'")) ///
, name(c,replace) xtitle("") ytitle("") ///
legend(order (1 "GDP" 2 "PCE") row(1) size(small) region(lcolor(white))) ///
graphregion(color(white)) ylabel(,grid labsize(large)) xsize(`width_') ysize(`height_') yscale(titlegap(*+7),) xlabel(,grid labsize(large)) legend(off) ///
xscale(range(199.17))
graph export "$output/figure2_e.pdf", replace

****************************************************************************************
** Spain **

import excel "$data_input/national_accounts_data.xls", sheet("SPA") firstrow clear

drop if year == .
drop date

* per capita and logs
local vars = "gdp pce durable non_durable_all"
foreach x of local vars {
replace `x' = `x'/pop
replace `x' = ln(`x')
}

gen year_quarter = yq(year,quarter)
format year_quarter %tq
tsset year_quarter

* de-trend

gen t = _n

local vars = "gdp pce durable non_durable_all"
foreach x of local vars {

reg `x' t if year<=2018 & year>=2006
gen `x'_trend = _b[_cons] + _b[t]*t
gen gap_`x' = `x'-`x'_trend
}

replace year = year + quarter/4

gen gap_gdp_aux = gap_gdp
replace gap_gdp_aux = . if quarter!=4


twoway ///
(scatter gap_gdp_aux year_quarter if year>=2006 & year<=2014, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5)) ///
(line gap_gdp year_quarter if year>=2006 & year<=2014, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5)) ///
(line gap_pce year_quarter if year>=2006 & year<=2014, lw(1) lc("`color_2'")) ///
(line gap_non_durable_all year_quarter if year>=2006 & year<=2014, lw(.8) lc("`color_2'") lp(dash)) ///
, name(d,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(,grid labsize(large)) legend(off)
graph export "$output/figure2_b.pdf", replace

****************************************************************************************
** Italy **

import excel "$data_input/national_accounts_data.xls", sheet("ITA") firstrow clear

drop if year == .
drop date

* per capita and logs
local vars = "gdp pce durable non_durable_all"
foreach x of local vars {
replace `x' = `x'/pop
replace `x' = ln(`x')
}

gen year_quarter = yq(year,quarter)
format year_quarter %tq
tsset year_quarter

* de-trend

gen t = _n

local vars = "gdp pce durable non_durable_all"
foreach x of local vars {

reg `x' t if year<=2016 & year>=1994
gen `x'_trend = _b[_cons] + _b[t]*t
gen gap_`x' = `x'-`x'_trend
}

replace year = year + quarter/4

gen gap_gdp_aux = gap_gdp
replace gap_gdp_aux = . if quarter!=4


twoway ///
(scatter gap_gdp_aux year_quarter if year>=2006 & year<=2014, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5)) ///
(line gap_gdp year_quarter if year>=2006 & year<=2014, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5)) ///
(line gap_pce year_quarter if year>=2006 & year<=2014, lw(1) lc("`color_2'")) ///
(line gap_non_durable_all year_quarter if year>=2006 & year<=2014, lw(.8) lc("`color_2'") lp(dash)) ///
, name(dd,replace) xtitle("") ytitle("") ///
legend(order (2 "output" 3 "consumption" 4 "nondurable consumption") row(3) size(large) ring(0) position(8) region(lcolor(white))) ///
graphregion(color(white)) ylabel(,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(,grid labsize(large))
graph export "$output/figure2_a.pdf", replace
