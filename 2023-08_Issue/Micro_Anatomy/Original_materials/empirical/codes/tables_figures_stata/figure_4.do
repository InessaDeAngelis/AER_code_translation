**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figure 4
* Estimates elasticities for Italy and US across business cycle
* US data from from Dauchy, Navarro-Sanchez and Seegert (RED, 2020)
* Italian data baseline sample extended
**********************************************************************


cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

grstyle clear

 **********************************************
 ******* Figure D3 - All Households *******
 **********************************************

cls
clear all
set mem 200m
set more off

********* US *********

** load CEX data from Dauchy, Navarro-Sanchez and Seegert (RED, 2020)

use "$input/US/DNS_cex_new.dta", clear
 
rename l1  nondurable1 

gen lc = nondurable1 - lp - ln(ncomp)
gen ly = ln(income_net) - lp - ln(ncomp)
drop if year<1980

* de-trending data 

reg lc year
predict uc, residual
reg ly year
predict uy, residual

replace uy = exp(uy)
replace uc = exp(uc)

* regression by quintile

gen decile = .
levelsof year, local(yearl)
foreach x of local yearl {
xtile decile_`x' = uy if year == `x', nq(5) 
replace decile = decile_`x' if year == `x',
drop decile_`x'
}
drop if decile == .

tempfile data_cex
save `data_cex', replace

collapse(mean) uc uy, by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_y = uy - L1.uy
gen g_c = uc - L1.uc

gen decc = .
gen beta = .
gen beta_ub = .
gen beta_lb = .

forval i = 1/5 {
replace decc = `i' in `i'
reg g_c g_y if decile == `i', robust
replace beta = _b[g_y] in `i'
replace beta_ub = _b[g_y] + 1.645*_se[g_y] in `i'
replace beta_lb = _b[g_y] - 1.645*_se[g_y] in `i'
}

keep decc beta beta_ub beta_lb
gen country = "US"
drop if decc == .

tempfile data_US
save `data_US', replace

********* ITA *********

u "$database/baseline_ITA_long.dta", clear


merge m:1 anno using "$input/ITA/storico_stata/defl.dta"
keep if _merge == 3
drop _merge

drop if anno<1980

* residual income and consumption

replace income = income*rival
replace consum = consum*rival

* non-residualized

gen ly = ln(income) - ln(hhsize)
gen lc = ln(consum) - ln(hhsize)

* resid
rename anno year
gen age2 = age^2
tab sesso, gen(sessob)

gen educ = .
replace educ = 1 if studio == 1 | studio == 2
replace educ = 2 if studio == 3
replace educ = 3 if studio == 4
replace educ = 4 if studio == 5 | studio == 6
tab educ, gen(educb)

qui tab hhsize, gen(hhsizeb)
gen lhsize = ln(hhsize)

qui tab region, gen(regionb)
qui tab estrato, gen(estratob)

gen yeducb1 = educb1*year
gen yeducb2 = educb2*year
gen yeducb3 = educb3*year
gen yeducb4 = educb4*year

gen ysexb1 = sessob1*year
gen ysexb2 = sessob2*year

reg ly sessob* age age2 educb* ysexb* estratob* yeducb*  year [aw=pesopop]
predict uy if e(sample),res
*regionb*

reg lc  sessob* age age2 educb* ysexb* estratob* yeducb* year [aw=pesopop]
predict uc if e(sample),res 
*regionb*

replace uy = exp(uy)
replace uc = exp(uc)

gen pesopop_r = round(pesopop)

*estrato variable only available from 1987 onwards
drop if year < 1987

gen decile = .
local year = "1987 1989 1991 1993 1995 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016" 
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=pesopop_r] , nq(5)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}
drop if decile == .

tempfile data_main
save `data_main' , replace

collapse(mean) uy uc [fw=pesopop_r], by(year decile)

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = .
replace g_uy = uy - L2.uy if year==1982
replace g_uy = uy - L1.uy if year>1982 & year<=1984
replace g_uy = uy - L3.uy if year==1987
replace g_uy = uy - L2.uy if year>1987 & year<=1995
replace g_uy = uy - L3.uy if year==1998
replace g_uy = uy - L2.uy if year>1998 & year<=2006
replace g_uy = uy - L8.uy if year==2014
replace g_uy = uy - L2.uy if year>2014 & year<=2016

gen g_uc = .
replace g_uc = uc - L2.uc if year==1982
replace g_uc = uc - L1.uc if year>1982 & year<=1984
replace g_uc = uc - L3.uc if year==1987
replace g_uc = uc - L2.uc if year>1987 & year<=1995
replace g_uc = uc - L3.uc if year==1998
replace g_uc = uc - L2.uc if year>1998 & year<=2006
replace g_uc = uc - L8.uc if year==2014
replace g_uc = uc - L2.uc if year>2014 & year<=2016

gen decc = .
gen beta = .
gen beta_ub = .
gen beta_lb = .

gen beta_rec = .
gen beta_rec_ub = .
gen beta_rec_lb = .
gen beta_nrec = .
gen beta_nrec_ub = .
gen beta_nrec_lb = .

gen rec = 0
replace rec = 1 if year == 2014 
replace rec = 1 if year == 1982 
replace rec = 1 if year == 1993

gen g_uy_rec = g_uy*rec
gen g_uy_nrec = g_uy*(1-rec)

* regression by quintile

forval i = 1/5 {

replace decc = `i' in `i'

reg g_uc g_uy if decile == `i', robust
replace beta = _b[g_uy] in `i'
replace beta_ub = _b[g_uy] + 1.645*_se[g_uy] in `i'
replace beta_lb = _b[g_uy] - 1.645*_se[g_uy] in `i'

reg g_uc g_uy_rec g_uy_nrec if decile == `i', robust

replace beta_rec = _b[g_uy_rec] in `i'
replace beta_rec_ub = _b[g_uy_rec] + 1.645*_se[g_uy_rec] in `i'
replace beta_rec_lb = _b[g_uy_rec] - 1.645*_se[g_uy_rec] in `i'

replace beta_nrec = _b[g_uy_nrec] in `i'
replace beta_nrec_ub = _b[g_uy_nrec] + 1.645*_se[g_uy_nrec] in `i'
replace beta_nrec_lb = _b[g_uy_nrec] - 1.645*_se[g_uy_nrec] in `i'

}

keep decc beta beta_ub beta_lb
gen country = "ITA"
drop if decc == .

tempfile data_ITA
save `data_ITA' , replace

********* plot *********

u `data_ITA', clear

append using `data_US'

local width_ = "2.6"
local height_ = "2"

twoway ///
(connected beta decc if country == "ITA", lc(blue) mc(blue) msize(2) lw(.8)) ///
(rcap beta_ub beta_lb decc if country == "ITA", lc(blue) lw(.5)) ///\
(connected beta decc if country == "US", lc(maroon) mc(maroon) msize(2) lw(.8)) ///
(rcap beta_ub beta_lb decc if country == "US", lc(maroon) lw(.5)) ///\
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(-.5(.5)2, labsize(large)) xsize(`width_') ysize(`height_') xlabel(1(1)5, labsize(large)) ///
yline(1.1 , lw(.8) lc(blue*.6) lp(dash)) yline(0.52 , lw(.8) lc(maroon*.6) lp(dash)) ///
legend(order(1 "ITA" 3 "US")  region(color(white))) 
graph export "$output/figure4.pdf", replace
