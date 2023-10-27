**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figure B.5
* Half-life of Income dynamics by quintile of income
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


 *****************************
 ******* Half-life ***********
 *****************************


*** ITA *** 

u "$database/resid_ITA.dta", clear

keep year uy uc ly lc freqwt probwt

* quintiles of income 

local year = "1995 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016" 
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(5)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy  [fw=freqwt], by(year decile)

xtset decile year

replace uy = ln(uy)
replace uc = ln(uc)

forval i = 1/5 {
qui sum uy if decile == `i' & year == 2006, detail
local uym = r(mean)
replace uy = uy - `uym' if decile == `i'

qui sum uc if decile == `i' & year == 2006, detail
local ucm = r(mean)
replace uc = uc - `ucm' if decile == `i'
}

* Figure B.5 - a

local width_ = "2.6"
local height_ = "1.8"

gen half_life = .
gen recov = .
gen trough = .
forval i = 1/5 {
qui sum uy if decile == `i' , detail
local uymin = r(min)
replace recov = 2*uy - `uymin'  if decile == `i' & year > 2010
replace trough = 1 if uy == `uymin'
replace half_life = 1 if recov > 0 & recov != . & decile == `i'
}

replace half_life = half_life*(year - 2012) if year > 2010
forval i = 1/5 {
qui sum half_life if decile == `i', detail
local half_life_yrs_min = r(min)
replace half_life = `half_life_yrs_min' if decile == `i' & `half_life_yrs_min' > 0
}

egen half_life_0 = mean(half_life), by(decile) 
replace half_life = half_life_0
drop half_life_0

replace half_life = 6 if half_life == .

twoway ///
(bar half_life decile, lc(dknavy) barw(.6)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(0(2)10,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(, labsize(large)) ///
legend(order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5") region(color(white)) ring(0) position(12))
graph export "$output/figureB5_a.pdf", replace


*** SPA *** 

u "$database/resid_SPA.dta", clear

keep year uy uc ly lc freqwt probwt
 
* quintiles of income

local year = "2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018" 
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(5)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy  [fw=freqwt], by(year decile)

xtset decile year

replace uy = ln(uy)
replace uc = ln(uc)


forval i = 1/5 {
qui sum uy if decile == `i' & year == 2007, detail
local uym = r(mean)
replace uy = uy - `uym' if decile == `i'

qui sum uc if decile == `i' & year == 2007, detail
local ucm = r(mean)
replace uc = uc - `ucm' if decile == `i'
}


* Figure B.5 - b

local width_ = "2.6"
local height_ = "1.8"

gen half_life = .
gen recov = .
gen trough = .
forval i = 1/5 {
qui sum uy if decile == `i' , detail
local uymin = r(min)
replace recov = 2*uy - `uymin'  if decile == `i' & year > 2013
replace trough = 1 if uy == `uymin'
replace half_life = 1 if recov > 0 & recov != . & decile == `i'
}

replace half_life = half_life*(year - 2013) if year > 2013
forval i = 1/5 {
qui sum half_life if decile == `i', detail
local half_life_yrs_min = r(min)
replace half_life = `half_life_yrs_min' if decile == `i' & `half_life_yrs_min' > 0
}

egen half_life_0 = mean(half_life), by(decile) 
replace half_life = half_life_0
drop half_life_0


twoway ///
(bar half_life decile, lc(dknavy) barw(.6)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(0(2)10,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(, labsize(large)) ///
legend(order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5") region(color(white)) ring(0) position(12))
graph export "$output/figureB5_b.pdf", replace


*** MEX *** 


use "$database/resid_MEX.dta", clear

keep year uy uc ly lc freqwt probwt
 
* quintiles of income 

local year = "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014" 
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(5)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

drop if decile == .

collapse(mean) uc uy  [fw=freqwt], by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

forval i = 1/5 {
qui sum uy if decile == `i' & year == 2006, detail
local uym = r(mean)
replace uy = uy - `uym' if decile == `i'

qui sum uc if decile == `i' & year == 2006, detail
local ucm = r(mean)
replace uc = uc - `ucm' if decile == `i'
}


forval i = 1/5 {
qui sum uy if decile == `i' & year == 1994, detail
local uym = r(mean)
replace uy = uy - `uym' if decile == `i'

qui sum uc if decile == `i' & year == 1994, detail
local ucm = r(mean)
replace uc = uc - `ucm' if decile == `i'
}

* average episode

gen period = .

replace period = 0 if year == 2006
replace period = 1 if year == 2008
replace period = 2 if year == 2010
replace period = 3 if year == 2012
replace period = 4 if year == 2014

replace period = 0 if year == 1994
replace period = 1 if year == 1996
replace period = 2 if year == 1998
replace period = 3 if year == 2000
replace period = 4 if year == 2002
replace period = 5 if year == 2004

gen crisis = .
replace crisis = 1 if year>=1994 & year<=2004
replace crisis = 2 if year>=2006 & year<=2014

drop if crisis == .
keep crisis period uy uc year decile
egen period_decile = group(period decile)

reshape wide uy uc  period decile year , i(period_decile) j(crisis)

forval i = 1/5 {
qui sum uy2 if decile2 == `i' & period2 == 0, detail
local uym = r(mean)
replace uy2 = uy2 - `uym' if decile2 == `i'

qui sum uc2 if decile2 == `i' & period2 == 0, detail
local ucm = r(mean)
replace uc2 = uc2 - `ucm' if decile2 == `i'
}

gen uy = (uy1 + uy2)/2 
gen uc = (uc1 + uc2)/2 

* Figure B.5 - c

local width_ = "2.6"
local height_ = "1.8"

gen half_life = .
gen recov = .
gen trough = .
forval i = 1/5 {
qui sum uy if decile2 == `i', detail
local uymin = r(min)
replace recov = 2*uy - `uymin'  if decile2 == `i' & period2 > 0
replace trough = 1 if uy == `uymin'
replace half_life = 1 if recov > 0 & recov != . & decile2 == `i'
}

replace half_life = half_life*(period2-1)*2 if period2 > 0
forval i = 1/5 {
qui sum half_life if decile2 == `i', detail
local half_life_yrs_min = r(min)
}

egen half_life_0 = mean(half_life), by(decile2) 
replace half_life = half_life_0
drop half_life_0

replace half_life = 8 if decile1 > 1

twoway ///
(bar half_life decile1, lc(dknavy) barw(.6)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(0(2)10,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(, labsize(large)) ///
legend(order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5") region(color(white)) ring(0) position(12))
graph export "$output/figureB5_c.pdf", replace



*** PER *** 

u "$database/resid_PER.dta", clear

keep year uy uc ly lc freqwt probwt

* quintiles of income 

gen decile = .
levelsof year, local(yearl)
foreach x of local yearl {
xtile decile_`x' = uy if year == `x' [fw=freqwt], nq(5)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy [fw=freqwt], by(year decile)

xtset decile year

replace uy = ln(uy)
replace uc = ln(uc)

forval i = 1/5 {
qui sum uy if decile == `i' & year == 2007, detail
local uym = r(mean)
replace uy = uy - `uym' if decile == `i'

qui sum uc if decile == `i' & year == 2007, detail
local ucm = r(mean)
replace uc = uc - `ucm' if decile == `i'
}

* Figure B.5 - d

local width_ = "2.6"
local height_ = "1.8"

gen half_life = .
gen recov = .
gen trough = .
forval i = 1/5 {
qui sum uy if decile == `i' & year >= 2007 & year <= 2010, detail
local uymin = r(min)
replace recov = 2*uy - `uymin'  if decile == `i' & year > 2007
replace trough = 1 if uy == `uymin'
replace half_life = 1 if recov > 0 & recov != . & decile == `i'
}

replace half_life = half_life*(year - 2008) if year > 2007
forval i = 1/5 {
qui sum half_life if decile == `i', detail
local half_life_yrs_min = r(min)
replace half_life = `half_life_yrs_min' if decile == `i' & `half_life_yrs_min' > 0
}

egen half_life_0 = mean(half_life), by(decile) 
replace half_life = half_life_0
drop half_life_0

replace half_life = 10 if decile == 4
replace half_life = 10 if decile == 5

twoway ///
(bar half_life decile, lc(dknavy) barw(.6)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(0(2)10,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(, labsize(large)) ///
legend(order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5") region(color(white)) ring(0) position(12))
graph export "$output/figureB5_d.pdf", replace

