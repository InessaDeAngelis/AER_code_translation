**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code merges data from EFF-Spain and EPF-Spain
* estimates LPM regression with HH observables in EFF and then merges
* with EPF consumption and income data
**********************************************************************

cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

****** estimates regression coefficients to merge with EPF ******

global input_EFF = "$input/SPA/EFF"

local year = "2008 2011 2014"

foreach x of local year {
forval i = 1/5 {

use "$input_EFF/other_sections_`x'_imp`i'.dta", clear

* variables needed for merging 
gen q_house = 0
replace q_house = 1 if p2_1b == 1
replace q_house = p2_1c/100 if p2_1b == 2
replace q_house = q_house + p2_37_1/100 if (p2_33>=1 & p2_33!=. & p2_39_1>=0 & p2_39_1!=. & p2_37_1>0 & p2_37_1!=.)
replace q_house = q_house + p2_37_2/100 if (p2_33>=2 & p2_33!=. & p2_39_2>=0 & p2_39_2!=. & p2_37_2>0 & p2_37_2!=.)
replace q_house = q_house + p2_37_3/100 if (p2_33>=3 & p2_33!=. & p2_39_3>=0 & p2_39_3!=. & p2_37_3>0 & p2_37_3!=.)
replace q_house = q_house + p2_33 - 3 if (p2_33>3 & p2_33!=. & p2_39_4>=0 & p2_39_4!=.)
 
gen q_business = 0
replace q_business = 1 if p4_101==1 & p4_111_1>0 & p4_111_1!=.
replace q_business = q_business + 1 if p4_101==1 & p4_111_2>0 & p4_111_2!=.
replace q_business = q_business + 1 if p4_101==1 & p4_111_3>0 & p4_111_3!=.
replace q_business = q_business + 1 if p4_101==1 & p4_111_4>0 & p4_111_4!=.
replace q_business = q_business + 1 if p4_101==1 & p4_111_5>0 & p4_111_5!=.
replace q_business = q_business + 1 if p4_101==1 & p4_111_6>0 & p4_111_6!=.

rename renthog income_1
rename mrenthog income_2
rename facine3 factor5

keep factor5 p1 p1_1_1 p1_2d_1 p1_5_1 p1_4_1 p2_1 p2_33 p4_101 p9_2 h_`x' income_1 income_2 q_house q_business

tempfile data_indiv
save `data_indiv', replace

use "$input_EFF/databol`i'_`x'.dta", clear

merge 1:1 h_`x' using `data_indiv' , nogenerate

gen factor = facine3/5

tempfile imp_`i'
save `imp_`i'', replace

}

append using `imp_1'
append using `imp_2'
append using `imp_3'
append using `imp_4'

gen year = `x'

tempfile data_`x'_merge_C
save `data_`x'_merge_C', replace

}

append using `data_2008_merge_C'
append using `data_2011_merge_C'

* consumption

gen consumption = 0 
replace consumption = alim + nodur + gimpvehic
replace consumption = consumption + p2_70 if (p2_70>0 & p2_70!=.)

gen consumption_nond = alim + nodur

** assets
* real assets (gross)

gen business = 0
replace business = business + valhog if (valhog>0 & valhog!=.)

gen house_main = 0
replace house_main = house_main + np2_5 if (np2_5>0 & np2_5!=.)

gen house_other = 0
replace house_other = otraspr if (otraspr>0 & otraspr!=.)

gen assets_house = 0
replace assets_house = house_other + house_main

gen other_real = 0
replace other_real = p2_84 if (p2_84>0 & p2_84!=.)

* financial assets
gen financial_gross = 0
replace financial_gross = financial_gross + actfinanc if (actfinanc>0 & actfinanc!=.)

* total gross 

gen assets_total = financial_gross + business + house_main + house_other + other_real

* liquid (depositos + acciones bolsa + bonos (renta fija) + fondos de inversion + cartera de gestion)
gen liq = 0
replace liq = liq + p4_7_3 if (p4_7_3>0 & p4_7_3!=.)
replace liq = liq + p4_15 if (p4_15>0 & p4_15!=.)
replace liq = liq + p4_35 if (p4_35>0 & p4_35!=.)
replace liq = liq + allf  if (allf >0 & allf!=.)
replace liq = liq + p4_43 if (p4_43 >0 & p4_43!=.)

* non liquid ( reales + acciones no en bolsa + cuentas no utilizable para pagos + pension funds + insurance + otras deudas de 3ros)
gen nliq = 0
replace nliq = nliq + house_main + house_other + other_real + business
replace nliq = nliq + p4_24      if (p4_24 >0 & p4_24!=.)
replace nliq = nliq + salcuentas if (salcuentas >0 & salcuentas!=.)
replace nliq = nliq + valor if (valor >0 & valor!=.)
replace nliq = nliq + valseg if (valseg >0 & valseg!=.)
replace nliq = nliq + odeuhog if (odeuhog >0 & odeuhog!=.)

* business with financial assets 

gen business_fin = 0
replace business_fin = business_fin + business if (business>0 & business!=.)
replace business_fin = business_fin + p4_15 if (p4_15>0 & p4_15!=.)
replace business_fin = business_fin + p4_24 if (p4_24>0 & p4_24!=.)

gen financial_gross_bus = 0
replace financial_gross_bus = financial_gross_bus + financial_gross if (financial_gross>0 & financial_gross!=.)
replace financial_gross_bus = financial_gross_bus - p4_15 if (p4_15>0 & p4_15!=.)
replace financial_gross_bus = financial_gross_bus - p4_24 if (p4_24>0 & p4_24!=.)

gen stocks = 0
replace stocks = stocks + p4_15 if (p4_15>0 & p4_15!=.)

gen priv_stocks = 0
replace priv_stocks = priv_stocks + p4_24 if (p4_24>0 & p4_24!=.)

** liabilities

* house
gen house_main_debt = 0
replace house_main_debt =  house_main_debt +  dvivpral if (dvivpral >0 & dvivpral!=.)

gen house_other_debt = 0
replace house_other_debt =  house_other_debt +  deuoprop if (deuoprop >0 & deuoprop!=.)

gen debt_house = house_main_debt + house_other_debt

* other
gen other_debt = 0
replace other_debt = other_debt + phipo if (phipo >0 & phipo!=.)
replace other_debt = other_debt + pperso if (pperso >0 & pperso!=.)
replace other_debt = other_debt + potrasd if (potrasd >0 & potrasd!=.)

* financial = liquid = credit card debt
gen ccdebt = 0
replace ccdebt = ccdebt + ptmos_tarj if (ptmos_tarj >0 & ptmos_tarj!=.)

* total
gen debt_total = 0
replace debt_total =  debt_total + debt_house + other_debt + ccdebt

** net assets

gen wealth = assets_total - debt_total

gen house_net = assets_house - debt_house

gen liq_net = liq - ccdebt

gen financial_net = financial_gross - ccdebt

gen financial_bus_net = financial_gross_bus - ccdebt

gen business_net = business

gen other_net = other_real - other_debt

** LPM model estimation

gen factor_r = round(factor)

*business owner
gen bus = 0 
replace bus = 1 if q_business>0 & q_business!=.
*house owner
gen house = 0 
replace house = 1 if q_house>0 & q_house!=.
*members HH
gen members = p1
replace members = 9 if p1>=9 & p1!=.
*age head HH
rename p1_2d_1 age
replace age = 22 if age<=22 & age!=.
replace age = 80 if age>=80 & age!=.
*income HH per capita
rename income_1 income
gen income_pc = income/p1
xtile perc_income_2008 = income_pc [fw=factor_r] if year == 2008, nq(100)
xtile perc_income_2011 = income_pc [fw=factor_r] if year == 2011, nq(100)
xtile perc_income_2014 = income_pc [fw=factor_r] if year == 2014, nq(100)
gen perc_income = .
replace perc_income = perc_income_2014 if year ==2014
replace perc_income = perc_income_2008 if year ==2008
replace perc_income = perc_income_2011 if year ==2011
*maritial status head of HH
gen mar_status = 1 if p1_4_1 == 1
replace mar_status = 2 if p1_4_1 == 2
replace mar_status = 3 if p1_4_1 == 6
replace mar_status = 4 if p1_4_1 == 4
replace mar_status = 5 if p1_4_1 == 5
replace mar_status = 2 if p1_4_1 == 3
*sex head of HH
gen male = (p1_1_1 == 1 & p1_1_1!=.)
*education 
gen educ = 1 if p1_5_1 == 1
replace educ = 2 if p1_5_1 == 2
replace educ = 3 if p1_5_1 == 3 | p1_5_1==4 | p1_5_1==5 | p1_5_1==6
replace educ = 4 if p1_5_1 == 7 | p1_5_1==8 | p1_5_1==9 
replace educ = 5 if p1_5_1 == 10 | p1_5_1==11
replace educ = 6 if p1_5_1==12

*HtM and liquid holdings
gen liq_income = liq/income_2 
gen htm = 0
replace htm = 1 if liq/income_2>1 & liq/income_2!=.
gen liq_hold = (liq>0 & liq!=.)

save "$database/SPA/SPA_wealth_EFF.dta", replace /* save to compute distribution in EFF-Spain dataset */

*wealth at 2014 prices

merge m:1 year using "$input/SPA/CPI.dta"
drop if _merge==2
drop _merge

qui sum CPI if year == 2014
local CPI14 = r(mean)
gen liq_14 = (liq/CPI)*`CPI14'
gen wealth_14 = (wealth/CPI)*`CPI14'

*** wealth coefficients for merging ***
gen beta_liq = .
gen beta_hold = .
gen beta_htm = .
gen beta_wealth = .

reg liq_14 i.year i.age male i.educ i.members i.perc_income i.mar_status house business [pw = factor]

mat beta =e(b)
forval i =1/200 {
replace beta_liq = beta[1,`i'] in `i'
}

reg liq_hold i.year i.age male i.educ i.members i.perc_income i.mar_status house business [pw = factor]

mat beta =e(b)
forval i =1/200 {
replace beta_hold = beta[1,`i'] in `i'
}


reg htm i.year i.age male i.educ i.members i.perc_income i.mar_status house business [pw = factor]

mat beta =e(b)
forval i =1/200 {
replace beta_htm = beta[1,`i'] in `i'
}


reg wealth_14 i.year i.age male i.educ i.members i.perc_income i.mar_status house business [pw = factor]

mat beta =e(b)
forval i =1/200 {
replace beta_wealth = beta[1,`i'] in `i'
}

keep beta_*
drop if beta_htm == .

tempfile coefficients_merging
save `coefficients_merging', replace


****** merge with EPF ******

global income  = "impexac"
global gastot  = "gastot"
global gasmon = "gastmon"
global factor = "factor"

local year = "08 11 13 14"

foreach y of local year {

use "$input/SPA/hog_`y'", clear

replace $gastot=$gastot/($factor*12*nmiemb)
replace $gasmon=$gasmon/($factor*12*nmiemb)
replace $income=$income/nmiemb

replace $income=$income + ( $gastot - $gasmon )
drop if $income==.

drop if $gastot<0
drop if $income<0

gen ratio=$gastot/$income
drop if ratio==.
replace $factor = round($factor)

gen u_ratio=.
_pctile ratio [fw=$factor], p(99.5)
replace u_ratio=r(r1)

gen d_ratio=.
_pctile ratio [fw=$factor], p(0.05)
replace d_ratio=r(r1)

drop if ratio==.
keep if ratio>=d_ratio & ratio<=u_ratio

gen year=2000+`y'

tempfile data_`y'
save `data_`y'', replace

}

append using `data_08'
append using `data_11'
append using `data_13'

* variables for the merging with wealth data

*house owner
destring regten, replace
gen house = 0 
replace house = 1 if regten==1 | regten==2
*business owner
destring sitprof, replace
gen bus = 0 
replace bus = 1 if sitprof==2 | sitprof==3
*members HH
gen members = nmiemb
replace members = 9 if nmiemb>=9 & nmiemb!=.
*age head HH
rename edadsp age
replace age = 22 if age<=22 & age!=.
replace age = 80 if age>=80 & age!=.
*income HH per capita
gen income = impexac
gen income_pc = income/nmiemb
xtile perc_income_2008 = income_pc [fw=factor] if year == 2008, nq(100)
xtile perc_income_2011 = income_pc [fw=factor] if year == 2011, nq(100)
xtile perc_income_2013 = income_pc [fw=factor] if year == 2013, nq(100)
xtile perc_income_2014 = income_pc [fw=factor] if year == 2014, nq(100)
gen perc_income = .
replace perc_income = perc_income_2014 if year ==2014
replace perc_income = perc_income_2008 if year ==2008
replace perc_income = perc_income_2011 if year ==2011
replace perc_income = perc_income_2013 if year ==2013
*maritial status head of HH
destring ecivillegalsp, replace
destring ecivilsp, replace
gen mar_status = ecivillegalsp
replace mar_status = ecivilsp if year == 2008
*sex head of HH
destring sexosp, replace
gen male = (sexosp == 1 & sexosp!=.)
*education 
destring  estudios_sp, replace
gen educ = 1 if  estudios_sp == 1
replace educ = 2 if  estudios_sp == 2
replace educ = 3 if  estudios_sp == 3
replace educ = 4 if  estudios_sp == 4 |  estudios_sp==5
replace educ = 5 if  estudios_sp == 6 |  estudios_sp==7
replace educ = 6 if  estudios_sp == 8

tempfile data_consum
save `data_consum', replace

use `coefficients_merging', clear

mkmat beta_*

use `data_consum', clear

gen year_2008 = (year == 2008)
gen year_2011 = (year == 2011)
gen year_2013 = (year == 2013)
gen year_2014 = (year == 2014)

*** impute variables using coefficients

* Liquid assets value

gen liq = beta_liq[186,1]

replace liq = liq + beta_liq[1,1]*year_2008 + beta_liq[2,1]*year_2011 + beta_liq[3,1]*year_2013 + beta_liq[3,1]*year_2014 

levelsof age, local(levels)
foreach x of local levels {
gen age_`x' = (age == `x')
}

forval i=1/59 {
local y = `i' + 3
local yy = `i' + 21

replace liq = liq + beta_liq[`y',1]*age_`yy'

}

replace liq = liq + beta_liq[63,1]*male

forval i=1/6 {
gen educ_`i' = (educ == `i')
local y = `i' + 63

replace liq = liq + beta_liq[`y',1]*educ_`i'

}

forval i=1/9 {
gen members_`i' = (members == `i')
local y = `i' + 69

replace liq = liq + beta_liq[`y',1]*members_`i'

}

forval i=1/100 {
gen perc_income_`i' = (perc_income == `i')
local y = `i' + 78

replace liq = liq + beta_liq[`y',1]*perc_income_`i'

}

forval i=1/5 {
gen mar_status_`i' = (mar_status == `i')
local y = `i' + 178

replace liq = liq + beta_liq[`y',1]*mar_status_`i'

}

replace liq = liq + beta_liq[184,1]*house
replace liq = liq + beta_liq[185,1]*bus

* Liquid assets holding likelihood

gen liq_hold = beta_hold[186,1]

replace liq_hold = liq_hold + beta_hold[1,1]*year_2008 + beta_hold[2,1]*year_2011 + beta_hold[3,1]*year_2013 + beta_hold[3,1]*year_2014 

forval i=1/59 {
local y = `i' + 3
local yy = `i' + 21

replace liq_hold = liq_hold + beta_hold[`y',1]*age_`yy'

}

replace liq_hold = liq_hold + beta_hold[63,1]*male

forval i=1/6 {
local y = `i' + 63

replace liq_hold = liq_hold + beta_hold[`y',1]*educ_`i'

}

forval i=1/9 {
local y = `i' + 69

replace liq_hold = liq_hold + beta_hold[`y',1]*members_`i'

}

forval i=1/100 {
local y = `i' + 78

replace liq_hold = liq_hold + beta_hold[`y',1]*perc_income_`i'

}

forval i=1/5 {
local y = `i' + 178

replace liq_hold = liq_hold + beta_hold[`y',1]*mar_status_`i'

}

replace liq_hold = liq_hold + beta_hold[184,1]*house
replace liq_hold = liq_hold + beta_hold[185,1]*bus

* HtM likelihood

gen htm = beta_htm[186,1]

replace htm = htm + beta_htm[1,1]*year_2008 + beta_htm[2,1]*year_2011 + beta_htm[3,1]*year_2013 + beta_htm[3,1]*year_2014 

forval i=1/59 {
local y = `i' + 3
local yy = `i' + 21

replace htm = htm + beta_htm[`y',1]*age_`yy'

}

replace htm = htm + beta_htm[63,1]*male

forval i=1/6 {
local y = `i' + 63

replace htm = htm + beta_htm[`y',1]*educ_`i'

}

forval i=1/9 {
local y = `i' + 69

replace htm = htm + beta_htm[`y',1]*members_`i'

}

forval i=1/100 {
local y = `i' + 78

replace htm = htm + beta_htm[`y',1]*perc_income_`i'

}

forval i=1/5 {
local y = `i' + 178

replace htm = htm + beta_htm[`y',1]*mar_status_`i'

}

replace htm = htm + beta_htm[184,1]*house
replace htm = htm + beta_htm[185,1]*bus

rename htm nhtm /* htm = 1 liquid assets originally (typo) */

* wealth

gen wealth = beta_wealth[186,1]

replace wealth = wealth + beta_wealth[1,1]*year_2008 + beta_wealth[2,1]*year_2011 + beta_wealth[3,1]*year_2013 + beta_wealth[3,1]*year_2014 

forval i=1/59 {
local y = `i' + 3
local yy = `i' + 21

replace wealth = wealth + beta_wealth[`y',1]*age_`yy'

}

replace wealth = wealth + beta_wealth[63,1]*male

forval i=1/6 {
local y = `i' + 63

replace wealth = wealth + beta_wealth[`y',1]*educ_`i'

}

forval i=1/9 {
local y = `i' + 69

replace wealth = wealth + beta_wealth[`y',1]*members_`i'

}

forval i=1/100 {
local y = `i' + 78

replace wealth = wealth + beta_wealth[`y',1]*perc_income_`i'

}

forval i=1/5 {
local y = `i' + 178

replace wealth = wealth + beta_wealth[`y',1]*mar_status_`i'

}

replace wealth = wealth + beta_wealth[184,1]*house
replace wealth = wealth + beta_wealth[185,1]*bus

save "$database/SPA/SPA_wealth.dta", replace

