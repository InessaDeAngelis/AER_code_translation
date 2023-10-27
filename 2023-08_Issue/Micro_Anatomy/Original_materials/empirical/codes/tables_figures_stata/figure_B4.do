**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figure B.4
* Income dynamics by quintile of income
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

 ******************************
 ******* Y Dynamics ***********
 ******************************
 
*** ITA *** 

u "$database/resid_ITA.dta", clear

keep year uy uc ly lc freqwt probwt

* quntiles of residualized income (by year)

local year = "1995 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016" 
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(5)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uy  [fw=freqwt], by(year decile)

replace uy = ln(uy)

xtset decile year

forval i = 1/5 {
qui sum uy if decile == `i' & year == 2006, detail
local uym = r(mean)
replace uy = uy - `uym' if decile == `i'
}

** Figure B.4 - panel a

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(connected uy year if decile == 1 & year>=2005, lc(orange) mc(orange) msize(2.3) lw(1)) ///
(connected uy year if decile == 2 & year>=2005, lc(dknavy) mc(dknavy) msize(2.3) lw(1)) ///
(connected uy year if decile == 3 & year>=2005, lc(gray) mc(gray) msize(2.3) lw(1)) ///
(connected uy year if decile == 4 & year>=2005, lc(maroon) mc(maroon) msize(2.3) lw(1)) ///
(connected uy year if decile == 5 & year>=2005, lc(emerald) mc(emerald) msize(2.3) lw(1)) ///
, xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(-.3(.1).12,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(, labsize(large)) ///
legend(order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5") region(color(white)) ring(0) position(8))
graph export "$output/figureB4_a.pdf", replace

*** SPA *** 

u "$database/resid_SPA.dta", clear

keep year uy uc ly lc freqwt probwt
 
* quntiles of residualized income (by year)

local year = "2006 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018" 
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(5)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uy  [fw=freqwt], by(year decile)

replace uy = ln(uy)

xtset decile year

forval i = 1/5 {
qui sum uy if decile == `i' & year == 2007, detail
local uym = r(mean)
replace uy = uy - `uym' if decile == `i'
}

** Figure B.4 - panel b

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(connected uy year if decile == 1 & year>=2007, lc(orange) mc(orange) msize(2.3) lw(1)) ///
(connected uy year if decile == 2 & year>=2007, lc(dknavy) mc(dknavy) msize(2.3) lw(1)) ///
(connected uy year if decile == 3 & year>=2007, lc(gray) mc(gray) msize(2.3) lw(1)) ///
(connected uy year if decile == 4 & year>=2007, lc(maroon) mc(maroon) msize(2.3) lw(1)) ///
(connected uy year if decile == 5 & year>=2007, lc(emerald) mc(emerald) msize(2.3) lw(1)) ///
, xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(-.3(.1).12,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(, labsize(large)) ///
legend(order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5") region(color(white)) ring(0) position(8)) 
graph export "$output/figureB4_b.pdf", replace

*** MEX ***  

u "$database/resid_MEX.dta", clear

keep year uy uc ly lc freqwt probwt

* quintiles of residualized income (by year)

local year = "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014" 
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(5)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}
drop if decile == .

collapse(mean) uy  [fw=freqwt], by(year decile)

replace uy = ln(uy)

* average episode

gen period = .

replace period = 0 if year == 2006
replace period = 1 if year == 2008
replace period = 2 if year == 2010
replace period = 3 if year == 2012

replace period = 0 if year == 1994
replace period = 1 if year == 1996
replace period = 2 if year == 1998
replace period = 3 if year == 2000

gen crisis = .
replace crisis = 1 if year>=1994 & year<=2000
replace crisis = 2 if year>=2006 & year<=2012

drop if crisis == .
keep crisis period uy year decile
egen period_decile = group(period decile)

reshape wide uy  period decile year , i(period_decile) j(crisis)

forval i = 1/5 {
qui sum uy1 if decile2 == `i' & period1 == 0, detail
local uym1 = r(mean)
replace uy1 = uy1 - `uym1' if decile1 == `i'

qui sum uy2 if decile2 == `i' & period2 == 0, detail
local uym2 = r(mean)
replace uy2 = uy2 - `uym2' if decile2 == `i'
}

gen uy = (uy1 + uy2)/2 

** Figure B.4 - panel c

local width_ = "2.6"
local height_ = "1.8"


twoway ///
(connected uy period1 if decile1 == 1 , lc(orange) mc(orange) msize(2.3) lw(1)) ///
(connected uy period1 if decile1 == 2 , lc(dknavy) mc(dknavy) msize(2.3) lw(1)) ///
(connected uy period1 if decile1 == 3 , lc(gray) mc(gray) msize(2.3) lw(1)) ///
(connected uy period1 if decile1 == 4 , lc(maroon) mc(maroon) msize(2.3) lw(1)) ///
(connected uy period1 if decile1 == 5 , lc(emerald) mc(emerald) msize(2.3) lw(1)) ///
,  xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(, labsize(large)) ///
legend(order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5") region(color(white)) ring(0) position(12))
graph export "$output/figureB4_c.pdf", replace 
 
*** PER ***   

u "$database/resid_PER.dta", clear

keep year uy uc ly lc freqwt probwt

* quntiles of residualized income (by year)

local year = "2004 2005 2006 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018" 
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(5)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uy  [fw=freqwt], by(year decile)

replace uy = ln(uy)

xtset decile year

forval i = 1/5 {
qui sum uy if decile == `i' & year == 2007, detail
local uym = r(mean)
replace uy = uy - `uym' if decile == `i'
}

** Figure B.4 - panel d

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(connected uy year if decile == 1 & year>=2007 & year<=2012, lc(orange) mc(orange) msize(2.3) lw(1)) ///
(connected uy year if decile == 2 & year>=2007 & year<=2012, lc(dknavy) mc(dknavy) msize(2.3) lw(1)) ///
(connected uy year if decile == 3 & year>=2007 & year<=2012, lc(gray) mc(gray) msize(2.3) lw(1)) ///
(connected uy year if decile == 4 & year>=2007 & year<=2012, lc(maroon) mc(maroon) msize(2.3) lw(1)) ///
(connected uy year if decile == 5 & year>=2007 & year<=2012, lc(emerald) mc(emerald) msize(2.3) lw(1)) ///
, xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(2007(1)2012, labsize(large)) ///
legend(order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5") region(color(white)) ring(0) position(12)) 
graph export "$output/figureB4_d.pdf", replace
 
