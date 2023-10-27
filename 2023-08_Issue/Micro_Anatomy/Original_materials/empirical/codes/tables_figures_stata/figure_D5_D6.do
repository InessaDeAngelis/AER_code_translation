**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figure D.5 and D.6
* cross-sectional variance and 90/10 income ratio dynamics
********************************************************************** 

cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

grstyle clear
set scheme s2color
graph set window fontface default

**** Safe US and GER rates ****

import excel "$input/aggregate/interest_rates_data.xls", sheet("US_GER") cellrange(A2:G1065) firstrow clear /* US data */

gen month = month(date)
gen year_month = ym(year, month)
format year_month %tm
tsset year_month

gen inflation_core = cpi_US_core/L12.cpi_US_core - 1
gen inflation_GER = cpi_GER/L12.cpi_GER - 1

gen rc_T_Bills_10 = (1+T_Bills_10/100)/(1+F12.inflation_core/2+inflation_core/2) - 1
gen r_GER10Y = (1+GER_10Y/100)/(1+F12.inflation_GER/2+inflation_GER/2) - 1

replace T_Bills_10 = T_Bills_10/100
replace GER_10Y    = GER_10Y/100

tempfile monthly_data
save `monthly_data', replace

collapse(mean) T_Bills_10 GER_10Y rc_T_Bills_10 r_GER10Y inflation_core, by(year)  /* annual */

tempfile safe_rates
save `safe_rates', replace

**** Government Spreads ****

import excel "$input/aggregate/interest_rates_data.xls", sheet("GovBonds") cellrange(A2:G379) firstrow clear /* Gov Bond data */

gen month = month(date)
gen year_month = ym(year, month)
format year_month %tm
tsset year_month

gen s_ITA = 100*(ITA - GER)
gen s_SPA = 100*(SPA - GER)

collapse(mean) s_ITA s_SPA s_PER s_MEX, by(year)

local vars = "ITA SPA MEX PER"

foreach x of local vars {
replace s_`x' = s_`x'/10000
}

merge 1:1 year using `safe_rates', nogenerate
sort year

tempfile interest_rates
save `interest_rates', replace

****** Plot by episode-country ******

** ITA **

import excel "$input/aggregate/interest_rates_data.xls", sheet("ITA_HH") cellrange(A2:E331) firstrow clear /* Italy */

gen month = month(date)
gen year_month = ym(year, month)
format year_month %tm
tsset year_month

gen inflation = cpi/L12.cpi - 1

gen rlend_rate = (1+lend_rate/100)/(1+F12.inflation/2+inflation/2) - 1
gen rdep_rate = (1+dep_rate/100)/(1+F12.inflation/2+inflation/2) - 1

replace lend_rate = lend_rate/100
replace dep_rate = dep_rate/100

collapse(mean) lend_rate dep_rate rlend_rate rdep_rate, by(year)  /* annual */

keep year lend_rate dep_rate rlend_rate* rdep_rate*

merge 1:1 year using `interest_rates', nogenerate keepusing(GER_10Y r_GER10Y s_ITA) 
sort year

gen lend_spread = lend_rate - dep_rate
format s_ITA %8.0g

local width_ = "2.6"
local height_ = "1.8"

* Figure D.5 - panel a

twoway ///
(line rdep_rate year if year>=2006 & year<=2016 , lc(dknavy)  lp(solid)  lw(1)) ///
(line r_GER10Y year if year>=2006 & year<=2016 , lc(dknavy) lp(dash) lw(1)) ///
, xtitle("") ytitle("")  xline(2008 2013, lc(black) lp(dot) lw(.5)) ///
graphregion(color(white)) ylabel(-.02(.02)0.06,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(, grid labsize(large)) ///
legend(order(1 "deposit rate" 2 "GER 10Y") row(3) size(large) ring(0) position(1) region(color(white)))
graph export "$output/figureD5_a.pdf", replace

* Figure D.6 - panel a

twoway ///
(line lend_spread year if year>=2006 & year<=2016, lc(maroon)  lp(solid)  lw(1)) ///
(line s_ITA year if year>=2006 & year<=2016, lc(maroon) lp(dash) lw(1)) ///
, xtitle("") ytitle("")  xline(2008 2013, lc(black) lp(dot) lw(.5)) ///
graphregion(color(white))  ylabel(.0(.02).05,grid labsize(large) ) ///
xsize(`width_') ysize(`height_') xlabel(, grid labsize(large)) ///
legend(order(1 "lending spread" 2 "gov bond spreads") row(3) size(large) ring(0) position(5) region(color(white)))
graph export "$output/figureD6_a.pdf", replace

** SPA **

import excel "$input/aggregate/interest_rates_data.xls", sheet("SPA_HH") cellrange(A2:E236) firstrow clear /* Spain */

gen month = month(date)
gen year_month = ym(year, month)
format year_month %tm
tsset year_month

gen inflation = cpi/L12.cpi - 1

gen rlend_rate = (1+lend_rate/100)/(1+F12.inflation/2+inflation/2) - 1
gen rdep_rate = (1+dep_rate/100)/(1+F12.inflation/2+inflation/2) - 1

replace lend_rate = lend_rate/100
replace dep_rate = dep_rate/100

collapse(mean) lend_rate dep_rate rlend_rate rdep_rate, by(year)  /* annual */

keep year lend_rate dep_rate rlend_rate* rdep_rate*

merge 1:1 year using `interest_rates', nogenerate keepusing(GER_10Y r_GER10Y s_SPA) 
sort year

gen lend_spread = lend_rate - dep_rate
format s_SPA %8.0g

local width_ = "2.6"
local height_ = "1.8"

* Figure D.6 - panel b

twoway ///
(line rdep_rate year if year>=2006 & year<=2016 , lc(dknavy)  lp(solid)  lw(1)) ///
(line r_GER10Y year if year>=2006 & year<=2016 , lc(dknavy) lp(dash) lw(1)) ///
, xtitle("") ytitle("")  xline(2008 2013, lc(black) lp(dot) lw(.5)) ///
graphregion(color(white)) ylabel(-.02(.02)0.06,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(, grid labsize(large)) ///
legend(order(1 "deposit rate" 2 "GER 10Y") row(3) size(large) ring(0) position(1) region(color(white)))
graph export "$output/figureD5_b.pdf", replace

* Figure D.6 - panel b

twoway ///
(line lend_spread year if year>=2006 & year<=2016, lc(maroon)  lp(solid)  lw(1)) ///
(line s_SPA year if year>=2006 & year<=2016, lc(maroon) lp(dash) lw(1)) ///
, xtitle("") ytitle("")  xline(2008 2013, lc(black) lp(dot) lw(.5)) ///
graphregion(color(white))  ylabel(.0(.02).05,grid labsize(large) ) ///
xsize(`width_') ysize(`height_') xlabel(, grid labsize(large)) ///
legend(order(1 "lending spread" 2 "gov bond spreads") row(3) size(large) ring(0) position(5) region(color(white)))
graph export "$output/figureD6_b.pdf", replace


** MEX **

import excel "$input/aggregate/interest_rates_data.xls", sheet("MEX_HH") cellrange(A2:E560) firstrow clear /* Mexico */

gen month = month(date)
gen year_month = ym(year, month)
format year_month %tm
tsset year_month

gen inflation = cpi/L12.cpi - 1

gen rlend_rate = (1+lend_rate/100)/(1+F12.inflation/2 + inflation/2) - 1
gen rdep_rate = (1+dep_rate/100)/(1+F12.inflation/2 + inflation/2) - 1

replace lend_rate = lend_rate/100
replace dep_rate = dep_rate/100

collapse(mean) lend_rate dep_rate rlend_rate rdep_rate, by(year)  /* annual */

merge 1:1 year using `interest_rates', nogenerate keepusing(T_Bills_10 rc_T_Bills_10 s_MEX) 
sort year

keep year lend_rate dep_rate rlend_rate rdep_rate T_Bills_10 rc_T_Bills_10 s_MEX

gen ep = .
replace ep = 1 if year>=1993 & year<=1997
replace ep = 2 if year>=2006 & year<=2010

gen t =.
replace t = 0 if year==1993 | year==2006
replace t = 1 if year==1994 | year==2007
replace t = 2 if year==1995 | year==2008
replace t = 3 if year==1996 | year==2009
replace t = 4 if year==1997 | year==2010

keep lend_rate dep_rate rlend_rate rdep_rate T_Bills_10 rc_T_Bills_10 s_MEX t ep

drop if ep == .

reshape wide lend_rate dep_rate rlend_rate rdep_rate T_Bills_10 rc_T_Bills_10 s_MEX, i(t) j(ep)

local vars = "lend_rate dep_rate rlend_rate rdep_rate T_Bills_10 rc_T_Bills_10 s_MEX"

foreach x of local vars {

gen `x' = (`x'1 + `x'2)/2

}

keep lend_rate dep_rate rlend_rate rdep_rate T_Bills_10 rc_T_Bills_10 s_MEX t

gen lend_spread = lend_rate - dep_rate

local width_ = "2.6"
local height_ = "1.8"

* Figure D.6 - panel c

twoway ///
(line rdep_rate t, lc(dknavy)  lp(solid)  lw(1)) ///
(line rc_T_Bills_10 t , lc(dknavy) lp(dash) lw(1)) ///
, xtitle("") ytitle("")  xline(1 3, lc(black) lp(dot) lw(.5)) ///
graphregion(color(white)) ylabel(-0.05(.05).15,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(, grid labsize(large)) ///
legend(order(1 "deposit rate" 2 "US 10Y") row(3) size(large) ring(0) position(12) region(color(white)))
graph export "$output/figureD5_c.pdf", replace

* Figure D.7 - panel c

twoway ///
(line lend_spread t, lc(maroon)  lp(solid)  lw(1) yaxis(1)) ///
(line s_MEX t , lc(maroon) lp(dash) lw(1)  yaxis(2)) ///
, xtitle("") ytitle("", axis(1)) ytitle("", axis(2))  xline(1 3, lc(black) lp(dot) lw(.5)) ///
graphregion(color(white)) ylabel(0(.05).13,grid labsize(large) axis(1)) ylabel(0(.03).06, labsize(large) axis(2)) ///
xsize(`width_') ysize(`height_') xlabel(, grid labsize(large)) ///
legend(order(1 "lending spread" 2 "gov bond spreads (right axis)") row(3) size(large) ring(0) position(5) region(color(white)))
graph export "$output/figureD6_c.pdf", replace

** PER **

import excel "$input/aggregate/interest_rates_data.xls", sheet("PER_HH") cellrange(A2:G446) firstrow clear /* Peru */

gen month = month(date)
gen year_month = ym(year, month)
format year_month %tm
tsset year_month

merge 1:1 year_month using `monthly_data', keepusing(inflation_core) nogenerate
tsset year_month

gen inflation_PER = cpi/L12.cpi - 1

gen rlend_rate = (1+lend_rate/100)/(1+F12.inflation_PER/2 + inflation_PER/2) - 1
gen rdep_rate = (1+dep_rate/100)/(1+F12.inflation_PER/2 + inflation_PER/2) - 1
gen rcdep_rate_FC = (1+dep_rate_FC/100)/(1+F12.inflation_core/2 + inflation_core/2) - 1

replace lend_rate = lend_rate/100
replace dep_rate = dep_rate/100
replace dep_rate_FC = dep_rate_FC/100

collapse(mean) lend_rate dep_rate dep_rate_FC rcdep_rate_FC rlend_rate rdep_rate , by(year)  /* annual */

keep year lend_rate dep_rate dep_rate_FC rcdep_rate_FC rlend_rate rdep_rate

merge 1:1 year using `interest_rates', nogenerate keepusing(T_Bills_10 rc_T_Bills_10 s_PER) 
sort year

gen lend_spread = lend_rate - dep_rate
tsset year
format s_PER %8.0g

local width_ = "2.6"
local height_ = "1.8"

* Figure D.5 - panel d

twoway ///
(line rdep_rate year if year>=2006 & year<=2012 , lc(dknavy)  lp(solid)  lw(1)) ///
(connected rcdep_rate_FC year if year>=2006 & year<=2012 , lc(dknavy)  mc(dknavy) msize(2)  lw(1)) ///
(line rc_T_Bills_10 year if year>=2006 & year<=2012 , lc(dknavy) lp(dash) lw(1)) ///
,  xtitle("") ytitle("")  xline(2007 2010, lc(black) lp(dot) lw(.5)) ///
graphregion(color(white)) ylabel(0.0(.05).1,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(, grid labsize(large)) ///
legend(order(1 "deposit rate" 2 "FC deposit rate" 3 "US 10Y") row(3) size(large) ring(0) position(1) region(color(white)))
graph export "$output/figureD5_d.pdf", replace

* Figure D.6 - panel d

twoway ///
(line lend_spread year if year>=2006 & year<=2012, yaxis(1) lc(maroon)  lp(solid)  lw(1)) ///
(line s_PER year if year>=2006 & year<=2012, yaxis(2) lc(maroon) lp(dash) lw(1)) ///
,  xtitle("") ytitle("", axis(1)) ytitle("", axis(2))  xline(2007 2010, lc(black) lp(dot) lw(.5)) ///
graphregion(color(white))  ylabel(.01(.01).033, labsize(large) axis(2)) ylabel(.1(.05).2,grid labsize(large) axis(1) ) ///
xsize(`width_') ysize(`height_') xlabel(, grid labsize(large)) ///
legend(order(1 "lending spread" 2 "gov bond spreads (right axis)") row(3) size(large) ring(0) position(5) region(color(white)))
graph export "$output/figureD6_d.pdf", replace

