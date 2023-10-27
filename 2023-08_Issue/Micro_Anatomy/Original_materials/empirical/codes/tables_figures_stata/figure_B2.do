**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figure B2
* compute transition proba matrix of income for panel sample
* for Italy and Peru
**********************************************************************


cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

grstyle init
grstyle set plain, horizontal grid  


ssc install xttrans2 
ssc install outtable
ssc install heatplot
ssc install palettes

 *************************************************
 **** Transition Probability Matrix and Plot *****
 *************************************************

** ITALY

* Panel -- Annual
* Deciles

* Panel

u "$database/resid_ITA.dta", clear

* panel sample selection
keep if year>= 2006 & year<=2014
xtset nquest year
egen count_f = sum(count), by(nquest)
keep if count_f == 5

egen n = group(nquest)
sum n

tempfile sample_data
save `sample_data', replace

xtset nquest year

*income
local year = "2006 2008 2010 2012 2014" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}
rename decile y_decile

*consumption
local year = "2006 2008 2010 2012 2014" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uc if year == `x' [fw=freqwt] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}

rename decile c_decile

xttrans2 y_decile, prob matcell(Y)

* Figure B.2 panel a

heatplot Y, keylabels(,format(%4.2f)  range(0))
graph export "$output/figureB2_a.pdf", replace

*** PERU

* Panel
* Annual

* Deciles data

u "$database/resid_PER.dta", clear

* panel sample selection during crisis
gen id_HH = conglome_ + vivienda_ + hogar
egen id_HH_n = group(id_HH)
xtset id_HH_n year
drop if year < 2007
drop if year > 2010
egen count_f = sum(count), by(id_HH_n)
keep if count_f == 4
drop count_f

tempfile sample_data
save `sample_data', replace

egen n = group(id_HH_n)
sum n

xtset id_HH_n year

*income
local year = "2007 2008 2009 2010" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uy if year == `x' [fw=freqwt] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}
rename decile y_decile

*consumption
local year = "2007 2008 2009 2010" 
gen decile = .
foreach x of local year {
fastxtile decile_`x' = uc if year == `x' [fw=freqwt] , nq(10)
replace decile = decile_`x' if year == `x'
drop decile_`x'
}
rename decile c_decile

xttrans2 y_decile, prob matcell(Y)

* Figure B.2 panel b

heatplot Y, keylabels(,format(%4.2f)  range(0))
graph export "$output/figureB2_b.pdf", replace
