**Event study regressions
**Purpose: Generate companion tables to event study graphs, as well as some other assorted tables
**Note: This is the main result generating file
*Observation level: Person quarter
*Regression indicators at person-year

*Additional Restrictions: Balanced panel, throw out records in de minimis zone

**Tables produced: 2-6. A2, A5, A6. Also answers various referee comments and questions

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_eventreshaped_ref_v2.dta", clear

**Restrict to balanced panel
drop _merge
merge m:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/enrollment_data/output/balanced_list", keep(1 3)

gen balanced = _merge == 3

*Throw out records in de minimis zone
drop if running > 0 & running < 2 & year >= 2011

gen yr_indicator1 = new <= 4
gen yr_indicator2 = new > 4 & new <= 8
gen yr_indicator3 = new > 8 & new <= 12
gen yr_indicator4 = new > 12 & new <= 16
gen yr_indicator_cat = .
replace yr_indicator_cat = 1 if yr_indicator1 == 1
replace yr_indicator_cat = 2 if yr_indicator2 == 1
replace yr_indicator_cat = 3 if yr_indicator3 == 1
replace yr_indicator_cat = 4 if yr_indicator4 == 1
drop event_time
*Within experiment indicator
egen event_time = group(region_code_year yr_indicator_cat)

forval n=1/4 {
gen yr_ybinary`n' =binary*yr_indicator`n'
}

forval n=1/4 {
gen yr_elix_time`n' = elix_bin*yr_indicator`n'
}


forval n=1/4 {
gen yr_xbinaryfit`n' = binary*newfit_unif*yr_indicator`n'
}

forval n=1/4 {
gen yr_ebinaryfit`n' = binary*elix_bin*yr_indicator`n'
}

forval n=1/4 {
gen yr_pbinaryfit`n' = binary*presc_bin*yr_indicator`n'
}

forval n=1/4 {
gen yr_p2binaryfit`n' = binary*presc_bin_v2*yr_indicator`n'
}
drop yr_ybinary2 yr_xbinaryfit2 yr_ebinaryfit2 yr_pbinaryfit2 yr_p2binaryfit2 yr_elix_time2

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_eventreshaped_ref_fin.dta", replace

use  "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_eventreshaped_ref_fin.dta", clear

drop contract_id plan_id
rename contract_id_Jan contract_id
rename plan_id_Jan plan_id

*Merge in year one premium levels for different plans, relative to benchmark, for ex-post plan of enrollment
*Previously, only tracked this just for ex-ante plan of enrollment
merge m:1 contract_id plan_id region_code year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/PlansRunningPrem_FullUniv.dta", keep(1 3) nogen

*Bring in person-year level spread measures (between best and worst fitting plans)
*Contrast from previous set that was commingled with plan-specific fit measures (and only available for re-assignees)
*Reference new variables w/_fa suffix
cap drop _merge
merge m:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneyrlvl_spread.dta", keep(1 3) 
cap drop _merge

*Merge in info on number of benchmark plans in each market, per year
cap drop _merge
merge m:1 region_code year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/obscount.dta", keep(1 3) 
cap drop _merge

*Remove faulty records
drop if ListtoDrop == 3

replace prescperc = ui1 if prescperc == .

gen bnch_plan = prem_above < 0
gen switch_actv_bnch = ((switch_actv == 1) & (bnch_plan == 1))

gen prescperc_cat = 0
replace prescperc_cat = 1 if prescperc < .2 & prescperc >= 0
replace prescperc_cat = 2 if prescperc > .2 & prescperc < .4
replace prescperc_cat = 3 if prescperc > .4 & prescperc < .6
replace prescperc_cat = 4 if prescperc > .6 & prescperc < .8
replace prescperc_cat = 5 if prescperc > .8 & prescperc < 1

gen prescfit_nonmiss = prescfit_median_min_fa ~= .
sort region_code_year prescfit_nonmiss prescfit_median_min_fa
qby region_code_year prescfit_nonmiss: gen perc_med = _n/_N

sort region_code_year prescfit_nonmiss ui1
qby region_code_year prescfit_nonmiss: replace perc_med = _n/_N if prescfit_nonmiss == 0

gen percmed_cat = 0
replace percmed_cat = 1 if perc_med > .75

gen percmed_catB = 0
replace percmed_catB = 1 if perc_med > .5

*Merge in first year of Part D enrollment
cap drop _merge
merge m:1 bene_id using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/year_one_partd.dta", keep(1 3)

*Generate variable tracking experience in Part D

replace enrlmt_yr_1st = 2006 if enrlmt_yr_1st < 2006
gen yrs_enrolled = year-enrlmt_yr_1st
gen yrs_enrolled_cat = 0
replace yrs_enrolled_cat = 1 if yrs_enrolled <= 2 & yrs_enrolled >= 1
replace yrs_enrolled_cat = 2 if yrs_enrolled <= 4 & yrs_enrolled >= 3
replace yrs_enrolled_cat = 3 if yrs_enrolled >= 5

gen pde_spend_hibenelog = log(pde_spend_hibene+1)
gen pde_spend_lowbenelog = log(pde_spend_lowbene)

*Merge in fit variables
cap drop _merge
merge m:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planunivlvlfit_all_vx.dta", keep(1 3)

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_eventreshaped_ref_finfin.dta", replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_eventreshaped_ref_finfin.dta", clear

replace type_actv_ind_Dec = type_actv_ind_new

************************************
*Misc: Cited in text
foreach x in pde_spendlog switch_from_Dec {

*drop yr_ybinary1
eststo: reghdfe `x' yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & (yrs_enrolled_cat == 1), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

eststo: reghdfe `x' yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12  & (yrs_enrolled_cat == 2), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

eststo: reghdfe `x' yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & (yrs_enrolled_cat == 3), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)
}
************************************

esttab using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/spend_robustness.txt", b(%9.3fc) se(%9.3fc) parentheses replace title("Effect of Forced Switching on Non-Active Choosers") ///
	keep(yr_ybinary*) stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%9.3fc %9.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes	
**********************************
***Abbreviated panel
**********************************

keep if balanced == 1

drop yr_ybinary4 yr_xbinaryfit4 yr_ebinaryfit4 yr_pbinaryfit4 yr_p2binaryfit4 yr_elix_time4

*Referee report-Incumbent plan fit in year post assignment
eststo: reg prescfit_inc yr_ybinary* i.region_code_year if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 9, vce(cluster bene_id)
estadd ysumm
sum prescfit_inc if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 9 & binary == 0

esttab using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/TablesReferee.txt", b(%9.3fc) se(%9.3fc) parentheses replace title("Effect of Forced Switching on Non-Active Choosers") ///
	keep(yr_ybinary*) stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%9.3fc %9.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes

*Table 2*
**Enrollment Regs: RD-Jan

*foreach x in switch switch_actv switch_actv_bnch switch_reasgn {
gen switch_from_Dec_actv = switch_from_Dec == 1 & type_actv_ind == 1
gen switch_from_Dec_actv_bnch = switch_from_Dec == 1 & type_actv_ind == 1 & (bnch_plan == 1)
gen switch_from_Dec_reasgn = (switch_from_Dec == 1) & (type_actv_ind == 0) 
replace switch_from_Dec_actv = . if switch_from_Dec == .
replace switch_from_Dec_actv_bnch = . if switch_from_Dec == .
replace switch_from_Dec_reasgn = . if switch_from_Dec == .
	
	eststo clear
foreach x in switch_from_Dec switch_from_Dec_actv switch_from_Dec_actv_bnch switch_from_Dec_reasgn {	
eststo: reg `x' yr_ybinary* i.region_code_year if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 9, vce(cluster bene_id)
estadd ysumm
	
}

sum  switch_from_Dec switch_from_Dec_actv switch_from_Dec_actv_bnch switch_from_Dec_reasgn  if new == 9 & binary == 0 & type_actv_ind_Dec == 0 & running < 6 & running > -6 

esttab using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/Tables2.txt", b(%9.3fc) se(%9.3fc) parentheses replace title("Effect of Forced Switching on Non-Active Choosers") ///
	keep(yr_ybinary*) stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%9.3fc %9.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes

**************************
*Tables 3 and 4*
***Spend results/standardized spend/high value/chronic
	
foreach x in pde_spendlog standardizedplanspendlog standardizedclassspendlog standardclassgenspendlog pde_spend_hibenelog pde_spend_lowbenelog chronicspendlog nonchronicspendlog {

eststo: reghdfe `x' yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12, absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

estadd ysumm

}	
	
foreach x in pde_spendlog standardizedplanspendlog standardizedclassspendlog standardclassgenspendlog pde_spend_hibenelog pde_spend_lowbenelog chronicspendlog nonchronicspendlog {

eststo: reghdfe `x' yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12, absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

estadd ysumm

}

esttab using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/Tables3to4.txt", b(%9.3fc) se(%9.3fc) parentheses replace title("Effect of Forced Switching on Non-Active Choosers") ///
	keep(yr_ybinary* yr_xbinaryfit*) stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%9.3fc %9.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes
	
	sum  pde_spend standardizedplanspend standardizedclassspend standardclassgenspend pde_spend_hibene pde_spend_lowbene chronicspend nonchronicspend if new >= 5 & new <= 8 & binary == 0 & type_actv_ind_Dec == 0 & running < 6 & running > -6 

*Table 5*
**Enrollment Regs: RD-post period ONLY, no indiv FE's, no heterogeneity. As of Dec 

foreach x in switch_from_Dec type_actv_ind {
eststo: reg `x' yr_ybinary* i.region_code_year if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 , vce(cluster bene_id)
estadd ysumm
}


**Enrollment Regs: RD-post period ONLY, no indiv FE's, heterogeneity by plan fit. As of Dec
foreach x in switch_from_Dec type_actv_ind {
eststo: reg `x' yr_ybinary* yr_xbinaryfit* i.region_code_year if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12, vce(cluster bene_id)

estadd ysumm
}

sum switch_from_Dec type_actv_ind if new == 12 & binary == 0 & type_actv_ind_Dec == 0 & running < 6 & running > -6 

esttab using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/Tables5to6.txt", b(%9.3fc) se(%9.3fc) parentheses replace title("Effect of Forced Switching on Non-Active Choosers") ///
	keep(yr_ybinary* yr_xbinaryfit*) stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%9.3fc %9.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes

*Appendix Table: A2*
*Reg outcomes: Benchmark loss regression only, no heterogeneity
eststo clear
foreach x in number_of_prescriptionslog days_supplylog nondrug_spendlog {

eststo: reghdfe `x' yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12, absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

estadd ysumm

}

*Reg outcomes: Benchmark loss regression & heterogeneity by plan fit

foreach x in number_of_prescriptionslog days_supplylog nondrug_spendlog  {

eststo: reghdfe `x' yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12, absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

estadd ysumm

}

esttab using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/Appendix1.txt", b(%9.3fc) se(%9.3fc) parentheses replace title("Effect of Forced Switching on Non-Active Choosers") ///
	keep(yr_ybinary* yr_xbinaryfit*) stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%9.3fc %9.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes
	
*sum pde_spendlog number_of_prescriptionslog days_supplylog nondrug_spendlog if new >= 5 & new <= 8 & binary == 0

sum number_of_prescriptions days_supply nondrug_spend if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new >= 5 & new <= 8 & binary == 0

*sum pde_spend pde_spendlog number_of_prescriptions number_of_prescriptionslog days_supply days_supplylog ER inp_count ip_spend ip_spendlog nondrug_spend nondrug_spendlog all_spend all_spendlog if new >= 5 & new <= 8 & binary == 0


*******************************************	
	
**Rational inattention	
**Appendix Table A5
  
*Original 
eststo clear 
forval x =1/5 { 

eststo: qui reghdfe pde_spendlog yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((prescperc_cat == `x') | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

eststo: qui areg endyr_actv_ind yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((prescperc_cat == `x') | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

eststo: qui areg switch_from_Dec yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((prescperc_cat == `x') | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

}

esttab using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/rat_inattention_resp.txt", b(%9.3fc) se(%9.3fc) parentheses replace title("Effect of Forced Switching on Non-Active Choosers") ///
	keep(yr_ybinary*) stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%9.3fc %9.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes

	eststo clear 
	
	*Top 50 % Spread
forval x =1/5 { 
*pde_spend pde_spendlog number_of_prescriptions number_of_prescriptionslog days_supply days_supplylog ER Ainp ip_spend ip_spendlog nondrug_spend nondrug_spendlog all_spend all_spendlog {
eststo: qui reghdfe pde_spendlog yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((prescperc_cat == `x') | (binary == 0)) & ((percmed_catB == 1) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

eststo: qui areg endyr_actv_ind yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((prescperc_cat == `x') | (binary == 0)) & ((percmed_catB == 1) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

eststo: qui areg switch_from_Dec yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((prescperc_cat == `x') | (binary == 0)) & ((percmed_catB == 1) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

}
	
*Top 25% Spread	
forval x =1/5 { 
*pde_spend pde_spendlog number_of_prescriptions number_of_prescriptionslog days_supply days_supplylog ER Ainp ip_spend ip_spendlog nondrug_spend nondrug_spendlog all_spend all_spendlog {
eststo: qui reghdfe pde_spendlog yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((prescperc_cat == `x') | (binary == 0)) & ((percmed_cat == 1) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

eststo: qui areg endyr_actv_ind yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((prescperc_cat == `x') | (binary == 0)) & ((percmed_cat == 1) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

eststo: qui areg switch_from_Dec yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((prescperc_cat == `x') | (binary == 0)) & ((percmed_cat == 1) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

}

*Top 10% Spread
forval x =1/5 { 
*pde_spend pde_spendlog number_of_prescriptions number_of_prescriptionslog days_supply days_supplylog ER Ainp ip_spend ip_spendlog nondrug_spend nondrug_spendlog all_spend all_spendlog {
eststo: qui reghdfe pde_spendlog yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((prescperc_cat == `x') | (binary == 0)) & ((perc_med > .9) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

eststo: qui areg endyr_actv_ind yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((prescperc_cat == `x') | (binary == 0)) & ((perc_med > .9) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

eststo: qui areg switch_from_Dec yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((prescperc_cat == `x') | (binary == 0)) & ((perc_med > .9) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

}
	esttab using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/rat_inattention_resp_variants.txt", b(%9.3fc) se(%9.3fc) parentheses replace title("Effect of Forced Switching on Non-Active Choosers") ///
	keep(yr_ybinary*) stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%9.3fc %9.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes
	
*************************************************
***Expanded table for draft: main coefficients for subsetted populations, based levels of spread between their best and worst fitting plans

*Table 6
*Appendix Table A6

eststo clear 
	
eststo: qui reghdfe pde_spendlog yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .5) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)	

eststo: qui reghdfe standardizedplanspendlog yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .5) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)	

eststo: qui reghdfe standardizedclassspendlog yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .5) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)	

eststo: qui areg endyr_actv_ind yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((perc_med > .5) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

eststo: qui areg switch_from_Dec yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((perc_med > .5) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

eststo: qui reghdfe pde_spendlog yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .75) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

eststo: qui reghdfe standardizedplanspendlog yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .75) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)	

eststo: qui reghdfe standardizedclassspendlog yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .75) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)		

eststo: qui areg endyr_actv_ind yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((perc_med > .75) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

eststo: qui areg switch_from_Dec yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((perc_med > .75) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)
	
eststo: qui reghdfe pde_spendlog yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .9) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

eststo: qui reghdfe standardizedplanspendlog yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .9) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

eststo: qui reghdfe standardizedclassspendlog yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .9) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)	

eststo: qui areg endyr_actv_ind yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((perc_med > .9) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

eststo: qui areg switch_from_Dec yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((perc_med > .9) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

eststo: qui reghdfe pde_spendlog yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .5) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)	

eststo: qui reghdfe standardizedplanspendlog yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .5) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)	

eststo: qui reghdfe standardizedclassspendlog yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .5) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)	

eststo: qui areg endyr_actv_ind yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((perc_med > .5) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

eststo: qui areg switch_from_Dec yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((perc_med > .5) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

eststo: qui reghdfe pde_spendlog yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .75) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)	

eststo: qui reghdfe standardizedplanspendlog yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .75) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)

eststo: qui reghdfe standardizedclassspendlog yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .75) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)


eststo: qui areg endyr_actv_ind yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((perc_med > .75) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

eststo: qui areg switch_from_Dec yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((perc_med > .75) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)
	
eststo: qui reghdfe pde_spendlog yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .9) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)	

eststo: qui reghdfe standardizedplanspendlog yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .9) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)	

eststo: qui reghdfe standardizedclassspendlog yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12 & ((perc_med > .9) | (binary == 0)), absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)	

eststo: qui areg endyr_actv_ind yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((perc_med > .9) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

eststo: qui areg switch_from_Dec yr_xbinaryfit* yr_ybinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new == 12 & ((perc_med > .9) | (binary == 0)), absorb(region_code_year) vce(cluster bene_id)

esttab using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/ExpandedTable.txt", b(%9.3fc) se(%9.3fc) parentheses replace title("Effect of Forced Switching on Non-Active Choosers") ///
	keep(yr_ybinary* yr_xbinaryfit*) stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%9.3fc %9.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes
*************************************************
**Referee comment: Ask about active choice as predictor of drug spending 
*Run a few different cuts of this:
**
gen type_actv_ind12 = type_actv_ind
replace type_actv_ind12 = 0 if new ~= 12
sort bene_id_ex
qby bene_id_ex: egen type_actv_person = sum(type_actv_ind12)
replace type_actv_person = type_actv_person > 0
forval n=1/4 {
gen yr_nnbinary`n' = type_actv_person*yr_indicator`n'
}

gen prescprec_cat1 = prescperc_cat == 1
gen prescprec_cat2 = prescperc_cat == 2
gen prescprec_cat3 = prescperc_cat == 3
gen prescprec_cat4 = prescperc_cat == 4
gen prescprec_cat5 = prescperc_cat == 5

gen yr_ncat1 = prescprec_cat1*yr_indicator3
gen yr_ncat2 = prescprec_cat2*yr_indicator3
gen yr_ncat3 = prescprec_cat3*yr_indicator3
gen yr_ncat4 = prescprec_cat4*yr_indicator3
gen yr_ncat5 = prescprec_cat5*yr_indicator3


drop yr_nnbinary2 yr_nnbinary4
foreach x in pde_spendlog number_of_prescriptionslog days_supplylog {

*Time-panel	
eststo: reghdfe `x' yr_nnbinary* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12, absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)
estadd ysumm
}

*Time panel with control for within-person fit quintile
foreach x in pde_spendlog number_of_prescriptionslog days_supplylog {
	
eststo: reghdfe `x' yr_nnbinary* yr_ncat* if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new <= 12, absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)
estadd ysumm
}

*Cross-sectional: Post-year
foreach x in pde_spendlog number_of_prescriptionslog days_supplylog {
	
eststo: reghdfe `x' type_actv_person if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new >= 9 & new <= 12, absorb(region_code_year) vce(cluster bene_id)
estadd ysumm
}


	esttab using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/referee_comment_predictor.txt", b(%9.3fc) se(%9.3fc) parentheses replace title("Effect of Forced Switching on Non-Active Choosers") ///
	keep(yr_nnbinary3 type_actv_person) stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%9.3fc %9.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes

*Cross-sectional: Pre-year
foreach x in pde_spendlog number_of_prescriptionslog days_supplylog {
	
eststo: reghdfe `x' type_actv_person if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new >= 5 & new <= 8, absorb(region_code_year) vce(cluster bene_id)
estadd ysumm
}

	esttab using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/referee_comment_predictor2.txt", b(%9.3fc) se(%9.3fc) parentheses replace title("Effect of Forced Switching on Non-Active Choosers") ///
	keep(type_actv_person) stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%9.3fc %9.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes	
