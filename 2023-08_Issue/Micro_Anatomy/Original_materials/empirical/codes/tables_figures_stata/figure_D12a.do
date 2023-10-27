**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figure D.12 panel a
* Loadings of aggregate income across income distribution
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

*** estimate loadings of Yi to Y ***

local base = 2006 /* base year for calculations */

* residualization

u "$database/baseline_ITA.dta", clear

merge m:1 anno using "$input/ITA/storico_stata/defl.dta"
keep if _merge == 3
drop _merge

replace income = income*rival
gen ly = ln(income) - ln(hhsize)

rename anno year
gen age2 = age^2
tab sesso, gen(sessob)

gen educ = .
replace educ = 1 if studio == 1 | studio == 2
replace educ = 2 if studio == 3
replace educ = 3 if studio == 4
replace educ = 4 if studio == 5 | studio == 6
tab educ, gen(educb)

tab hhsize, gen(hhsizeb)
gen lhsize = ln(hhsize)

tab region, gen(regionb)

gen yeducb1 = educb1*year
gen yeducb2 = educb2*year
gen yeducb3 = educb3*year
gen yeducb4 = educb4*year

gen ysexb1 = sessob1*year
gen ysexb2 = sessob2*year

reg ly age age2 sessob* educb* regionb* ysexb* yeducb* year [aw=pesopop] /* use non-baseline residualization */
predict uy if e(sample),res

gen pesopop_r = round(pesopop)

replace uy = exp(uy)

tempfile resid
save `resid', replace

* income by decile

u `resid', clear

local year = "1995 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016" 
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=pesopop_r] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

* evolution residualized income and elasticities by income group

collapse(mean) uy  [fw=pesopop_r], by(year decile)

replace uy = ln(uy)

forval i = 1/10 {
qui sum uy if year == `base' & decile == `i'
replace uy = uy - r(mean) if decile == `i'
}

xtset decile year
keep decile year uy

tempfile deciles 
save `deciles', replace

* aggregate income

u `resid', clear

collapse(mean) uy [fw=pesopop_r], by(year)

replace uy = ln(uy)

rename uy uy_agg 

keep year uy_agg*

tempfile agg 
save `agg', replace

* regressions by deciles

u `deciles', clear

merge m:1 year using `agg', nogenerate

xtset decile year

gen g_y = uy - L2.uy
gen g_y_agg = uy_agg - L2.uy_agg

gen beta = .
gen beta_ub = .
gen beta_lb = .
gen decc = .

forval i =1/10{
reg g_y g_y_agg if decile == `i', robust
replace beta = _b[g_y_agg] in `i'
replace beta_ub = _b[g_y_agg] + 2*_se[g_y_agg] in `i'
replace beta_lb = _b[g_y_agg] - 2*_se[g_y_agg] in `i'

replace decc = `i' in `i'
}

* Figure D.12 - panel a

local color_1 = "70 70 70"
local color_2 = "0 0 0"

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(line beta_ub decc, lc(navy*.4) lw(.7) lp(dash)) ///
(line beta_lb decc, lc(navy*.4) lw(.7) lp(dash)) ///
(scatter beta decc, mc(dknavy*.5) msize(3)) ///
(lowess beta decc , lc(dknavy) lp(solid) lw(1)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(0(.5)2, grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(1(1)10, labsize(large)) ///
legend(off) xlabel(,grid)
graph export "$output/figureD12_a.pdf", replace
