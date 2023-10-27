**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figure 3 and Figure B.3
**********************************************************************

***********************************************
* Code reproduces figures with elasticity and
* consumption/income changes for each episode
* by decile of income with bootstrap SE
* using residualized income and consumption
*********************************************** 

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

local resid  = "resid"
 
*** ITA *** 
foreach xx of local resid {

u "$database/`xx'_ITA.dta", clear

keep year uy uc ly lc freqwt probwt

tempfile sample_data
save `sample_data', replace

* Data by decile

u `sample_data', clear

local year = "2006 2014" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy  [fw=freqwt], by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy

keep if year == 2014

keep elast g_uy g_uc decile year

tempfile data_deciles
save `data_deciles', replace

* Bootstrap errors - deciles

clear

gen elast = .
gen decile = .

tempfile bs_elast_deciles
save `bs_elast_deciles', replace

tempfile bootstrap_elast
save `bootstrap_elast', replace

set seed 525

forvalues b = 1(1)2000 {

	local mcode 0
	local year 2006 2014
	foreach m of local year {

	use `sample_data', clear
		
	keep if year == `m'
	
	*generate sample equal to number of observations for year
	gen N = _N
	gsample N [aw=probwt]
	
	if `m' == 2006 {
	tempfile bootstrap_data
	save `bootstrap_data', replace
	continue
	}
	
	append using `bootstrap_data'
	save `bootstrap_data', replace
	}
	
use `bootstrap_data', clear

local year = "2006 2014" 
gen decile_bs = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' , nq(10)
replace decile_bs = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy, by(year decile_bs)

replace uy = ln(uy)
replace uc = ln(uc)

tsset decile_bs year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen elast = g_uc/g_uy

keep if year == 2014
keep g_* elast* year decile_bs

append using `bs_elast_deciles'
save `bs_elast_deciles', replace

}

drop decile
rename decile_bs decile

collapse (p5) lp_elast = elast lp_g_uc = g_uc lp_g_uy = g_uy (p95) up_elast = elast up_g_uc = g_uc up_g_uy = g_uy (mean) mean_elast = elast mean_g_uc = g_uc mean_g_uy = g_uy, by(decile)

* Plots - deciles

merge 1:1 decile using `data_deciles'

local color_1 = "70 70 70"
local color_2 = "0 0 0"

local width_ = "2.6"
local height_ = "1.8"

twoway ///
rarea lp_elast up_elast decile, fc(ltblue*.5) lc(white) ///
|| scatter elast decile, mc("`color_1'") msize(3) ///
|| lowess elast decile, lc("`color_2'") lp(solid) lw(1) ///
, xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(0(.5)2,grid labsize(large) glcolor(gray*.3)) xsize(`width_') ysize(`height_') xlabel(1(1)10, labsize(large) glcolor(gray*.3)) ///
legend(off) 
graph export "$output/figure3_a.pdf", replace


twoway ///
rarea lp_g_uc up_g_uc decile, fc(maroon*.3) lc(maroon*.1) ///
|| rarea lp_g_uy up_g_uy decile, fc(dknavy*.3) lc(maroon*.1) ///
|| scatter g_uc decile, mc(maroon*.5) msize(3) ///
|| lowess g_uc decile, lc(maroon) lp(solid) lw(1) ///
|| scatter g_uy decile, mc(dknavy*.5) msize(3) ///
|| lowess g_uy decile, lc(dknavy) lp(solid) lw(1) ///
,  xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(-.4(.1)0,grid labsize(large) glcolor(gray*.3)) xsize(`width_') ysize(`height_') xlabel(1(1)10, labsize(large) glcolor(gray*.3)) ///
legend(order(4 "dlnC" 6 "dlnY") row(3) size(large) ring(0) position(4) region(lcolor(white))) ///
yline(0, lc(gray) lw(.5) lp(dash))
graph export "$output/figureB3_a.pdf", replace
}

**

*** SPA deciles *** 
foreach xx of local resid {

u "$database/`xx'_SPA.dta", clear

keep year uy uc ly lc freqwt probwt
 
tempfile sample_data
save `sample_data', replace

* Deciles data

local year = "2008 2013" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy  [fw=freqwt], by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = uy - L5.uy
gen g_uc = uc - L5.uc

gen elast = g_uc/g_uy

keep if year == 2013

keep elast g_uy g_uc decile year

tempfile data_deciles
save `data_deciles', replace

* Bootstrap errors - deciles

clear

gen elast = .
gen decile = .

tempfile bs_elast_deciles
save `bs_elast_deciles', replace

tempfile bootstrap_elast
save `bootstrap_elast', replace

set seed 1

forvalues b = 1(1)2000 {

	local mcode 0
	local year 2008 2013
	foreach m of local year {

	use `sample_data', clear
		
	keep if year == `m'
	
	*generate sample equal to number of observations for year
	gen N = _N
	gsample N [aw=probwt]
	
	if `m' == 2008 {
	tempfile bootstrap_data
	save `bootstrap_data', replace
	continue
	}
	
	append using `bootstrap_data'
	save `bootstrap_data', replace
	}
	
use `bootstrap_data', clear

local year = "2008 2013" 
gen decile_bs = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' , nq(10)
replace decile_bs = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy, by(year decile_bs)

replace uy = ln(uy)
replace uc = ln(uc)

tsset decile_bs year

gen g_uy = uy - L5.uy
gen g_uc = uc - L5.uc

gen elast = g_uc/g_uy

keep if year == 2013
keep g_* elast* year decile_bs

append using `bs_elast_deciles'
save `bs_elast_deciles', replace

}

drop decile
rename decile_bs decile

collapse (p5) lp_elast = elast lp_g_uc = g_uc lp_g_uy = g_uy (p95) up_elast = elast up_g_uc = g_uc up_g_uy = g_uy (mean) mean_elast = elast mean_g_uc = g_uc mean_g_uy = g_uy, by(decile)

* Plots - deciles

merge 1:1 decile using `data_deciles'

local color_1 = "70 70 70"
local color_2 = "0 0 0"

local width_ = "2.6"
local height_ = "1.8"

twoway ///
rarea lp_elast up_elast decile, fc(ltblue*.5) lc(white) ///
|| scatter elast decile, mc("`color_1'") msize(3) ///
|| lowess elast decile, lc("`color_2'") lp(solid) lw(1) ///
, xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(0(.5)2,grid labsize(large) glcolor(gray*.3)) xsize(`width_') ysize(`height_') xlabel(1(1)10, labsize(large) glcolor(gray*.3)) ///
legend(off) 
graph export "$output/figure3_b.pdf", replace


twoway ///
rarea lp_g_uc up_g_uc decile, fc(maroon*.3) lc(maroon*.1) ///
|| rarea lp_g_uy up_g_uy decile, fc(dknavy*.3) lc(maroon*.1) ///
|| scatter g_uc decile, mc(maroon*.5) msize(3) ///
|| lowess g_uc decile, lc(maroon) lp(solid) lw(1) ///
|| scatter g_uy decile, mc(dknavy*.5) msize(3) ///
|| lowess g_uy decile, lc(dknavy) lp(solid) lw(1) ///
, xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(-.4(.1)0,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(1(1)10, labsize(large)) ///
legend(off) yline(0, lc(gray) lw(.5) lp(dash))
graph export "$output/figureB3_b.pdf", replace
}
**

*** MEX deciles *** 
foreach xx of local resid {

u "$database/`xx'_MEX.dta", clear

keep year uy uc ly lc freqwt probwt
 
tempfile sample_data
save `sample_data', replace

* Deciles data

local year = "1994 1996 2006 2010" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy  [fw=freqwt], by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = uy - L2.uy
gen g_uc = uc - L2.uc

gen elast = g_uc/g_uy

gen g_uy2 = uy - L4.uy
gen g_uc2 = uc - L4.uc

gen elast2 = g_uc2/g_uy2

keep if year == 1996 | year == 2010

replace g_uy = g_uy2 if year == 2010
replace g_uc = g_uc2 if year == 2010
replace elast = elast2 if year == 2010
keep g_uy g_uc elast decile year

reshape wide g_uy g_uc elast, i(decile) j(year)
drop if decile == .

gen g_uy = (g_uy2010 + g_uy1996)/2
gen g_uc = (g_uc2010 + g_uc1996)/2
gen elast = (elast2010 + elast1996)/2

keep g_uy g_uc elast decile

tempfile data_deciles
save `data_deciles', replace

* Bootstrap errors - deciles

clear

gen elast = .
gen decile = .

tempfile bs_elast_deciles
save `bs_elast_deciles', replace

tempfile bootstrap_elast
save `bootstrap_elast', replace

set seed 23

forvalues b = 1(1)2000 {

	local mcode 0
	local year 1994 1996
	foreach m of local year {

	use `sample_data', clear
		
	keep if year == `m'
	
	*generate sample equal to number of observations for year
	gen N = _N
	gsample N [aw=probwt]
	
	if `m' == 1994  {
	tempfile bootstrap_data_T
	save `bootstrap_data_T', replace
	continue
	}	
		
	append using `bootstrap_data_T'
	save `bootstrap_data_T', replace
	}
	
	local mcode 0
	local year 2006 2010
	foreach m of local year {

	use `sample_data', clear
		
	keep if year == `m'
	
	*generate sample equal to number of observations for year
	gen N = _N
	gsample N [aw=probwt]
	
	if `m' == 2006  {
	tempfile bootstrap_data_L
	save `bootstrap_data_L', replace
	continue
	}	
		
	append using `bootstrap_data_L'
	save `bootstrap_data_L', replace
	}	
	
append using `bootstrap_data_T'

local year = "1994 1996 2006 2010" 
gen decile_bs = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' , nq(10)
replace decile_bs = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy, by(year decile_bs)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile_bs year

gen g_uy = uy - L2.uy
gen g_uc = uc - L2.uc

gen elast = g_uc/g_uy

gen g_uy2 = uy - L4.uy
gen g_uc2 = uc - L4.uc

gen elast2 = g_uc2/g_uy2

keep if year == 1996 | year == 2010

replace g_uy = g_uy2 if year == 2010
replace g_uc = g_uc2 if year == 2010
replace elast = elast2 if year == 2010
keep g_uy g_uc elast decile year

reshape wide g_uy g_uc elast, i(decile_bs) j(year)
drop if decile == .

gen g_uy = (g_uy2010 + g_uy1996)/2
gen g_uc = (g_uc2010 + g_uc1996)/2
gen elast = (elast2010 + elast1996)/2

keep g_uy g_uc elast decile_bs

append using `bs_elast_deciles'
save `bs_elast_deciles', replace

}

drop decile
rename decile_bs decile

collapse (p5) lp_elast = elast lp_g_uc = g_uc lp_g_uy = g_uy (p95) up_elast = elast up_g_uc = g_uc up_g_uy = g_uy (mean) mean_elast = elast mean_g_uc = g_uc mean_g_uy = g_uy, by(decile)

* Plots - deciles

merge 1:1 decile using `data_deciles'

local color_1 = "70 70 70"
local color_2 = "0 0 0"

local width_ = "2.6"
local height_ = "1.8"

twoway ///
rarea lp_elast up_elast decile, fc(ltblue*.5) lc(white) ///
|| scatter elast decile, mc("`color_1'") msize(3) ///
|| lowess elast decile, lc("`color_2'") lp(solid) lw(1) ///
,  xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(0(.5)2,grid labsize(large) glcolor(gray*.3)) xsize(`width_') ysize(`height_') xlabel(1(1)10, labsize(large) glcolor(gray*.3)) ///
legend(off) 
graph export "$output/figure3_c.pdf", replace


twoway ///
rarea lp_g_uc up_g_uc decile, fc(maroon*.3) lc(maroon*.1) ///
|| rarea lp_g_uy up_g_uy decile, fc(dknavy*.3) lc(maroon*.1) ///
|| scatter g_uc decile, mc(maroon*.5) msize(3) ///
|| lowess g_uc decile, lc(maroon) lp(solid) lw(1) ///
|| scatter g_uy decile, mc(dknavy*.5) msize(3) ///
|| lowess g_uy decile, lc(dknavy) lp(solid) lw(1) ///
,  xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(-.4(.1)0,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(1(1)10, labsize(large)) ///
legend(off) yline(0, lc(gray) lw(.5) lp(dash))
graph export "$output/figureB3_c.pdf", replace
}
**

*** PER deciles *** 
foreach xx of local resid {

u "$database/`xx'_PER.dta", clear

keep year uy uc ly lc freqwt probwt
 
tempfile sample_data
save `sample_data', replace

* Deciles data

local year = "2007 2010" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy  [fw=freqwt], by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy

keep if year == 2010

keep elast g_uy g_uc decile year

tempfile data_deciles
save `data_deciles', replace

* Bootstrap errors - deciles

clear

gen elast = .
gen decile = .

tempfile bs_elast_deciles
save `bs_elast_deciles', replace

tempfile bootstrap_elast
save `bootstrap_elast', replace

set seed 199

forvalues b = 1(1)2000 {

	local mcode 0
	local year 2007 2010
	foreach m of local year {

	use `sample_data', clear
		
	keep if year == `m'
	
	*generate sample equal to number of observations for year
	gen N = _N
	gsample N [aw=probwt]
	
	if `m' == 2007 {
	tempfile bootstrap_data
	save `bootstrap_data', replace
	continue
	}
	
	append using `bootstrap_data'
	save `bootstrap_data', replace
	}
	
use `bootstrap_data', clear

local year = "2007 2010" 
gen decile_bs = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' , nq(10)
replace decile_bs = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy, by(year decile_bs)

replace uy = ln(uy)
replace uc = ln(uc)

tsset decile_bs year

gen g_uy = uy - L3.uy
gen g_uc = uc - L3.uc

gen elast = g_uc/g_uy

keep if year == 2010
keep g_* elast* year decile_bs

append using `bs_elast_deciles'
save `bs_elast_deciles', replace

}

drop decile
rename decile_bs decile

collapse (p5) lp_elast = elast lp_g_uc = g_uc lp_g_uy = g_uy (p95) up_elast = elast up_g_uc = g_uc up_g_uy = g_uy (mean) mean_elast = elast mean_g_uc = g_uc mean_g_uy = g_uy, by(decile)

* Plots - deciles

merge 1:1 decile using `data_deciles'
drop if decile == .

local color_1 = "70 70 70"
local color_2 = "0 0 0"

local width_ = "2.6"
local height_ = "1.8"


twoway ///
rarea lp_elast up_elast decile, fc(ltblue*.5) lc(white) ///
|| scatter elast decile, mc("`color_1'") msize(3) ///
|| lowess elast decile, lc("`color_2'") lp(solid) lw(1) ///
, xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(-0.5(.5)2,grid labsize(large) glcolor(gray*.3)) xsize(`width_') ysize(`height_') xlabel(1(1)10, labsize(large) glcolor(gray*.3)) ///
legend(off) 
graph export "$output/figure3_d.pdf", replace


twoway ///
rarea lp_g_uc up_g_uc decile, fc(maroon*.3) lc(maroon*.1) ///
|| rarea lp_g_uy up_g_uy decile, fc(dknavy*.3) lc(maroon*.1) ///
|| scatter g_uc decile, mc(maroon*.5) msize(3) ///
|| lowess g_uc decile, lc(maroon) lp(solid) lw(1) ///
|| scatter g_uy decile, mc(dknavy*.5) msize(3) ///
|| lowess g_uy decile, lc(dknavy) lp(solid) lw(1) ///
, xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(-.2(.05).05,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(1(1)10, labsize(large)) ///
legend(off) yline(0, lc(gray) lw(.5) lp(dash))
graph export "$output/figureB3_d.pdf", replace
}
