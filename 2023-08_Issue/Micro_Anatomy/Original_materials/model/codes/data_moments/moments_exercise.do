**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates moments used for model exercises
**********************************************************************

***********************************************
* Codes compute the empirical moments used as 
* input for the model exercises
*********************************************** 

cls
clear all
set mem 200m
set more off

global database = "$user/empirical/working_data"
global input    = "$user/empirical/input"
global output   = "$user/model/input"

*** ITA - deciles *** 

** Elasticities, mpc, dY across income distribution for Italy

u "$database/resid_ITA.dta", clear

keep year uy uc ly lc freqwt probwt

local year = "2006 2014" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(mean) uc uy  [fw=freqwt], by(year decile)

gen y = uy
gen c = uc

replace uy = ln(uy)
replace uc = ln(uc)

xtset decile year

gen g_uy = uy - L8.uy
gen g_uc = uc - L8.uc

gen d_uy = y - L8.y
gen d_uc = c - L8.c

gen elast = g_uc/g_uy
gen MPC   = d_uc/d_uy

keep if year == 2014

rename g_uy dy 

keep decile elast MPC dy

tempfile data_deciles_1_ITA
save `data_deciles_1_ITA', replace

** Income dispersion across the income distribution

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

tempfile resid
save `resid', replace

* aggregate

u `resid', clear

collapse(sd) uy_agg = uy [fw=pesopop_r], by(year)

tempfile agg
save `agg', replace

* deciles

u `resid', clear

gen decile = .
local year = "1998 2000 2002 2004 2006 2008 2010 2012 2014 2016" 
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=pesopop_r] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}
drop if decile == .

collapse(sd) uy [fw=pesopop_r], by(year decile)


merge m:1 year using `agg', nogenerate

drop if year == 1995

xtset decile year

gen luy = ln(uy)
gen luy_agg = ln(uy_agg)

gen beta = .
gen beta_ub = .
gen beta_lb = .
gen decc = .

forval i =1/10{
reg luy luy_agg if decile == `i'
replace beta = _b[luy_agg] in `i'
replace beta_ub = _b[luy_agg] + 2*_se[luy_agg] in `i'
replace beta_lb = _b[luy_agg] - 2*_se[luy_agg] in `i'

replace decc = `i' in `i'
}

gen inc_sig = .

forval i = 1/10{

qui sum uy if year >=2004 & year<=2008  & decile == `i'

replace inc_sig =  uy/r(mean) if decile == `i'

}

keep if year >=2012 & year<=2016

collapse(mean)  inc_sig, by(decile)

lowess inc_sig decile, generate(inc_sig_i)  /* change in dispersion during the crisis across the income distribution */

tempfile data_deciles_2_ITA
save `data_deciles_2_ITA', replace

** Wealth shares across income distribution

u "$input/ITA/q08c1.dta", clear

gen cdebt = cartdeb
replace cdebt = 0 if cdebt == .

gen anno = 2008

keep anno cdebt nquest

tempfile ccdebt_08
save `ccdebt_08', replace

u "$input/ITA/ricfam10.dta", clear

gen cdebt = pfcarte

gen anno = 2010

keep anno cdebt nquest

tempfile ccdebt_10
save `ccdebt_10', replace

u "$input/ITA/ricfam12.dta", clear

gen cdebt = pfcarte

gen anno = 2012

keep anno cdebt nquest

tempfile ccdebt_12
save `ccdebt_12', replace

u "$input/ITA/ricfam14.dta", clear

gen cdebt = pfcarte

gen anno = 2014

keep anno cdebt nquest

tempfile ccdebt_14
save `ccdebt_14', replace

u "$input/ITA/debiti16.dta", clear

gen cdebt = pfcarte

gen anno = 2016

keep anno cdebt nquest

append using `ccdebt_08'
append using `ccdebt_10'
append using `ccdebt_12'
append using `ccdebt_14'

tempfile ccdebt
save `ccdebt', replace

u "$input/ITA/storico_stata/ricf.dta", clear

keep if anno>=2008

merge 1:1 anno nquest using `ccdebt'
drop _merge

gen liq_wealth = af - cdebt

keep anno nquest liq_wealth

tempfile wealth
save `wealth', replace

u "$database/baseline_ITA.dta", clear

merge m:1 anno using "$input/ITA/storico_stata/defl.dta"
keep if _merge == 3
drop _merge

merge m:1 anno nquest using `wealth'
keep if _merge == 3
drop _merge

gen liq_y = liq_wealth/(income/12)
drop if liq_y == .

gen pesopop_r = round(pesopop)

replace liq_wealth = liq_wealth*rival
replace income = income*rival
gen liq_wealth_p = liq_wealth/hhsize

rename anno year

gen decile = .
local year = "2008 2010 2012 2014 2016" 
foreach x of local year {
xtile decile_`x' = liq_wealth_p if year == `x' [fw=pesopop_r] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(sum) liq_wealth_p [fw=pesopop_r], by(decile)

egen w_total = sum(liq_wealth_p)
gen s_w = liq_wealth_p/w_total

keep s_w decile /* wealth share by decile */

tempfile data_deciles_3_ITA
save `data_deciles_3_ITA', replace

** Wealth revaluations across the income distribution

u "$input/ITA/storico_stata/ricf.dta", clear

gen liq_wealth = af
gen dep = af1
gen bonds = af2
gen o_sec = af3
gen lend = af4
drop if liq_wealth == .
 
keep nquest anno liq_wealth dep bond o_sec lend
rename anno year

tempfile wealth_data
save `wealth_data', replace

u "$database/resid_ITA.dta", clear

merge m:1 nquest year using `wealth_data'
keep if _merge == 3
drop _merge

replace liq_wealth = liq_wealth*rival
replace dep = dep*rival
replace bonds = bonds*rival
replace o_sec = o_sec*rival
replace lend = lend*rival

local year = "1995 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016"
gen decile = .
foreach x of local year {
xtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

collapse(sum) liq_wealth o_sec lend bonds dep income [fw=freqwt], by(year decile)

gen wy = liq_wealth/income
gen dy = dep/income
gen boy = bonds/income
gen ly = lend/income
gen sy = o_sec/income

collapse(mean) wy dy boy ly sy, by(decile)

gen d1 = ly + dy
gen d2 = sy + boy

gen ch = - sy*.44/wy - boy*.11/wy /* simulate observed drop of 44% in stock market index and drop of 11% in sovereign bonds value */
gen ch_y = ch*wy                  /* losses in terms of income, used for revaluation exercises in the model */

keep ch_y decile

tempfile data_deciles_4_ITA
save `data_deciles_4_ITA', replace

u `data_deciles_1_ITA', clear
merge 1:1 decile using `data_deciles_2_ITA', nogenerate
merge 1:1 decile using `data_deciles_3_ITA', nogenerate
merge 1:1 decile using `data_deciles_4_ITA', nogenerate

/* create Excel file for deciles moments */
export excel decile elast MPC dy ch_y s_w inc_sig inc_sig_i using "$output/data_ITA.xls", firstrow(variables) replace

*** ITA - liquid wealth moments *** 

u "$database/resid_ITA.dta", clear

gen anno = year

merge m:1 anno nquest using `wealth'
keep if _merge == 3
drop _merge

replace uy = ly

gen position = .
local year = "2008" 
foreach x of local year {

_pctile uy if year == `x', percentiles(1 2 5 11 19 30 43 57 70 81 89 95 98 99) /* percentiles corresponds to points in the grid of the model */

gen categ = .
replace categ = 1 if uy <= `r(r1)' & year == `x'
replace categ = 2 if uy <= `r(r2)' & uy > `r(r1)' & year == `x'
replace categ = 3 if uy <= `r(r3)' & uy > `r(r2)' & year == `x'
replace categ = 4 if uy <= `r(r4)' & uy > `r(r3)' & year == `x'
replace categ = 5 if uy <= `r(r5)' & uy > `r(r4)' & year == `x'
replace categ = 6 if uy <= `r(r6)' & uy > `r(r5)' & year == `x'
replace categ = 7 if uy <= `r(r7)' & uy > `r(r6)' & year == `x'
replace categ = 8 if uy <= `r(r8)' & uy > `r(r7)' & year == `x'
replace categ = 9 if uy <= `r(r9)' & uy > `r(r8)' & year == `x'
replace categ = 10 if uy <= `r(r10)' & uy > `r(r9)' & year == `x'
replace categ = 11 if uy <= `r(r11)' & uy > `r(r10)' & year == `x'
replace categ = 12 if uy <= `r(r12)' & uy > `r(r11)' & year == `x'
replace categ = 13 if uy <= `r(r13)' & uy > `r(r12)' & year == `x'
replace categ = 14 if uy <= `r(r14)' & uy > `r(r13)' & year == `x'
replace categ = 15 if uy  > `r(r14)' & year == `x'

replace position = categ if year == `x' 
drop categ
}

gen ingreso = exp(ly)
keep if year == 2008

collapse(median) ingreso liq_wealth [fw=pesopop_r], by(position)

gen ratio_liq = liq_wealth/ingreso

keep position ratio_liq

/* create Excel file for wealth moments */
export excel position ratio_liq using "$output/liqwealth_ITA.xls", firstrow(variables) replace

*** ITA - Y Path ***

u "$database/resid_ITA.dta", clear

collapse(mean) uy [fw=pesopop_r], by(year)

qui sum uy if year == 2006
replace uy = uy/r(mean)

tsset year
tsfill, full

ipolate uy year, gen(iuy) 
rename iuy y
keep year y

/* create Excel file for aggregate Y */
export excel year y using "$output/dataY_ITA.xls", firstrow(variables) replace

*** MEX deciles *** 

u "$database/resid_MEX.dta", clear

keep year uy uc ly lc freqwt probwt
 
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

keep decile elast 

/* create Excel file for aggregate Y */
export excel decile elast using "$output/data_MEX.xls", firstrow(variables) replace
