**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figure B.8
* elasticites across wealth levels
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

 *********************************************************
 ******** elasticities across wealth distribution ********
 *********************************************************

*** wealth data *** 

u "$input/ITA/storico_stata/ricf.dta", clear

gen liq_wealth = af
drop if liq_wealth == .
rename anno year

keep nquest year liq_wealth pf

tempfile wealth_data
save `wealth_data', replace

u "$database/resid_ITA.dta", clear

merge m:1 nquest year using `wealth_data'
keep if _merge == 3
drop _merge

gen nom_income = income/rival

gen lw_y = liq_wealth/nom_income
gen pf_y = pf/nom_income

replace liq_wealth = liq_wealth/hhsize
replace pf = pf/hhsize

keep year uy uc ly lc freqwt probwt lw_y liq_wealth pf_y pf

tempfile sample_data
save `sample_data', replace

*** liquid wealth to income

u `sample_data', clear

local year = "2006 2014" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = lw_y if year == `x' [fw=freqwt] , nq(4)
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

* Figure B.8 - b

local color_1 = "70 70 70"
local color_2 = "0 0 0"

local width_ = "2.6"
local height_ = "1.8"

twoway ///
scatter elast decile, mc("`color_1'") msize(3) ///
|| lowess elast decile, noweight bwidth(.99) lc("`color_2'") lp(solid) lw(1) ///
, name(ITA_`xx',replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(0(.5)2.2,grid labsize(large) glcolor(gray*.3)) xsize(`width_') ysize(`height_') xlabel(1(1)4, labsize(large) glcolor(gray*.3)) ///
legend(off) 
graph export "$output/figureB8_b.pdf", replace

*** liquid wealth

u `sample_data', clear

local year = "2006 2014" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = liq_wealth if year == `x' [fw=freqwt] , nq(4)
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

* Figure B.8 - a

local color_1 = "70 70 70"
local color_2 = "0 0 0"

local width_ = "2.6"
local height_ = "1.8"

twoway ///
scatter elast decile, mc("`color_1'") msize(3) ///
|| lowess elast decile, noweight bwidth(.99)  lc("`color_2'") lp(solid) lw(1) ///
, name(ITA_`xx',replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(0(.5)2.2,grid labsize(large) glcolor(gray*.3)) xsize(`width_') ysize(`height_') xlabel(1(1)4, labsize(large) glcolor(gray*.3)) ///
legend(off) 
graph export "$output/figureB8_a.pdf", replace


*** debt/income

* Data by decile

u `sample_data', clear

drop if pf_y == .
drop if pf_y<=0

local year = "2006 2014" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = pf_y if year == `x' [fw=freqwt] , nq(4)
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

local color_1 = "70 70 70"
local color_2 = "0 0 0"

local width_ = "2.6"
local height_ = "1.8"

twoway ///
scatter elast decile, mc("`color_1'") msize(3) ///
|| lowess elast decile, noweight bwidth(.99) lc("`color_2'") lp(solid) lw(1) ///
, name(ITA_`xx',replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(0(.5)2.2,grid labsize(large) glcolor(gray*.3)) xsize(`width_') ysize(`height_') xlabel(1(1)4, labsize(large) glcolor(gray*.3)) ///
legend(off) 
graph export "$output/figureB8_d.pdf", replace


*** debt

* Data by decile

u `sample_data', clear

drop if pf_y == .
drop if pf_y<=0

local year = "2006 2014" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = pf if year == `x' [fw=freqwt] , nq(4)
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

* Plots - deciles

local color_1 = "70 70 70"
local color_2 = "0 0 0"

local width_ = "2.6"
local height_ = "1.8"

twoway ///
scatter elast decile, mc("`color_1'") msize(3) ///
|| lowess elast decile, noweight bwidth(.99)  lc("`color_2'") lp(solid) lw(1) ///
, name(ITA_`xx',replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(0(.5)2.2,grid labsize(large) glcolor(gray*.3)) xsize(`width_') ysize(`height_') xlabel(1(1)4, labsize(large) glcolor(gray*.3)) ///
legend(off) 
graph export "$output/figureB8_c.pdf", replace

