*Description: Data construction for RD outcomes analysis
*1. Take data set constructed previously, for outcomes around RD (pre and post year)
*Note: Observation-level at person-enrollment spell/transition level 

*2. Add additional fields on inpatient and ER visit count
*3. Add pre-2 year, post 2 year for ALL outcome variables
*4. Merge in additional person-level characteristics that were externally generated:
*a. Assigned plan ID's for those who opted out of randomized assignment, pre-start of enrollment spell
*b. Pre-year elixhauser scores
*c. Active choice status over post-period (post1/2/3 year) 
*d. Within-person plan-fit quality measures
*5. Merge in additional person-quarter level outcome variable for pre and post year (inpatient spend/visits by category)

cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/rd_outcomes/code/"
*for testing code interactively

global bsfab "../../../../raw/medicare_part_ab_bsf/data"
global bsfab_20pct "../../../../raw/medicare_part_ab_bsf_20pct/data"
global bsfd "../../../../raw/medicare_part_d_bsf/data"
global elc "../../../../raw/medicare_part_d_elc/data"
global states "../../../../raw/geo_data/data/states"
global mcdps "../../../../raw/medicaid_ps/data"
global mcr_mcd_xwk "../../../../raw/medicare_medicaid_crosswalk/data"
global ptd_bnch "../../../../raw/medicare_part_d_benchmark/data"
global samp "../../sample/output"
global car "../../../../raw/medicare_part_ab_car/data"
global med "../../../../raw/medicare_part_ab_med/data"
global op "../../../../raw/medicare_part_ab_op/data"

global util_med "../../../../derived/utilization_med/output"
global util_op "../../../../derived/utilization_op/output"
global util_car "../../../../derived/utilization_car/output"
global util_pde "../../../../derived/utilization_pde/output"


use "/disk/agedisk3/medicare.work/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/output/ptd_LIS65_20pct_samp_outcome_util.dta", clear

gen binary = running > 0

**Add new outcome variables for post -year: ER & inpatient utilization visit count

merge 1:1 bene_id year using "$samp/ptdsamp_ER_util.dta", keep(1 3) gen(ER_merge)
tab year ER_merge
replace ER = 0 if ER == .

merge 1:1 bene_id year using "$samp/ptdsamp_numinp_util.dta", keep(1 3) gen(numinp_merge)
tab year numinp_merge
replace inp = 0 if inp == .

foreach v of varlist med_spend-numinp_merge {
rename `v' fut_`v'
}

replace year = year-1

**Add pre year utilization: ER & inpatient visit count
**Medical spend, drug spend, drug utilization measures

merge 1:1 bene_id year using "$samp/ptdsamp_ER_util.dta", keep(1 3) nogen
*tab year ER_merge
replace ER = 0 if ER == .

merge 1:1 bene_id year using "$samp/ptdsamp_numinp_util.dta", keep(1 3) nogen
*tab year numinp_merge
replace inp = 0 if inp == .

foreach x in med op car pde {
	merge 1:1 bene_id year using "${util_`x'}/utilization.dta", keep(1 3) nogen
*	tab year `x'_merge
	sum `x'_spend, det
	replace `x'_spend = 0 if `x'_spend == .
}

replace year = year+1

foreach x in number_of_prescriptions days_supply {
	sum `x', det
	replace `x' = 0 if `x' == .

}

foreach v of varlist ER-days_supply {
rename `v' cur_`v'
}


**Add pre-2 year utilization: ER & inpatient visit count
**Medical spend, drug spend, drug utilization measures

replace year = year-2

merge 1:1 bene_id year using "$samp/ptdsamp_ER_util.dta", keep(1 3) nogen
*tab year ER_merge
replace ER = 0 if ER == .

merge 1:1 bene_id year using "$samp/ptdsamp_numinp_util.dta", keep(1 3) nogen
*tab year numinp_merge
replace inp = 0 if inp == .

foreach x in med op car pde {
	merge 1:1 bene_id year using "${util_`x'}/utilization.dta", keep(1 3) nogen
*	tab year `x'_merge
	sum `x'_spend, det
	replace `x'_spend = 0 if `x'_spend == .
}

replace year = year+2

foreach x in number_of_prescriptions days_supply {
	sum `x', det
	replace `x' = 0 if `x' == .

}

foreach v of varlist ER-days_supply {
rename `v' pre_`v'
}

**Add post-2 year utilization: ER & inpatient visit count
**Medical spend, drug spend, drug utilization measures

replace year = year+1

merge 1:1 bene_id year using "$samp/ptdsamp_ER_util.dta", keep(1 3) nogen
*tab year ER_merge
replace ER = 0 if ER == .

merge 1:1 bene_id year using "$samp/ptdsamp_numinp_util.dta", keep(1 3) nogen
*tab year numinp_merge
replace inp = 0 if inp == .

foreach x in med op car pde {
	merge 1:1 bene_id year using "${util_`x'}/utilization.dta", keep(1 3) nogen
*	tab year `x'_merge
	sum `x'_spend, det
	replace `x'_spend = 0 if `x'_spend == .
}

replace year = year-2

foreach x in number_of_prescriptions days_supply {
	sum `x', det
	replace `x' = 0 if `x' == .

}



foreach v of varlist ER-days_supply {
rename `v' post_`v'
}

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/temp/rd-outcomes.dta", replace

*********************
**Prepare person-year level elixhauser score file, to then merge in later 

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/elixhauser/output/elixhauserlis_all.dta", clear
keep bene_id year elixsum
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/localelix.dta", replace

*********************

*Standardize field names, drop extraneous fields
use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/temp/rd-outcomes.dta", clear

*Drop extraneous variables
drop fut_log* fut_ER_merge fut_numinp_merge fut_op_merge fut_car_merge fut_pde_merge
drop fut_tot_ip_spend fut_tot_op_spend fut_tot_ip_op_spend fut_any_tot_ip_spend fut_any_tot_op_spend fut_any_tot_ip_op_spend fut_any_pde_spend fut_binary
drop fut_med_merge
gen binary = running > 0

foreach x in cur fut pre post {
gen `x'_tot_spend = `x'_med_spend+`x'_op_spend+`x'_car_spend

}

foreach x in cur fut pre post {
rename `x'_med_spend `x'_ip_spend
}

foreach x in cur fut pre post {
rename `x'_tot_spend `x'_nondrug_spend
}

foreach x in cur fut pre post {

gen `x'_all_spend=`x'_nondrug_spend+`x'_pde_spend
}

foreach x in cur fut pre post {
drop `x'_car_spend `x'_op_spend
}

*Merge in file tracking difference between premium and benchmark, as of pre-year
merge m:1 contract_id_Dec plan_id_Dec region_code year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/PreRunningFile.dta", keep(1 3) nogen

rename year yr
*Merge in file on number of drugs people are taking, also as of pre-year
merge 1:1 bene_id yr using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/nun_ndc/output/drugcount_all.dta", keep(1 3)
rename yr year
replace ndc_count = 0 if ndc_count == .

*Merge in file on elixhauser score for people, also as of pre-year
merge 1:1 bene_id year using  "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/localelix.dta", keep(1 3) nogen


rename year yr

replace yr = yr+1
merge 1:1 bene_id yr using  "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/inp//output/inp_by_cat.dta", keep(1 3) nogen
replace yr = yr-1

**Additional outcome variable:
**Pull in information at level of inpatient category type
**Both by visit count as well as spend

foreach x of varlist inp_cat_visit* inp_cat_spend* {
rename `x' fut_`x'
}

merge 1:1 bene_id yr using  "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/inp//output/inp_by_cat.dta", keep(1 3) nogen

rename yr year


foreach x of varlist inp_cat_visit* inp_cat_spend* {
rename `x' cur_`x'

}

foreach x of varlist cur_inp_cat_visit* cur_inp_cat_spend* fut_inp_cat_visit* fut_inp_cat_spend* {
replace `x' = 0 if `x' == .
}

foreach x of varlist cur_inp_cat_spend* fut_inp_cat_spend* {
gen `x'log = log(`x'+1)
}

foreach y in cur fut pre post {
foreach x in nondrug_spend ip_spend pde_spend all_spend number_of_prescriptions days_supply {
gen `y'_`x'log = log(`y'_`x'+1)
} 
}


**Integrate in reversed plan assignments (to which people assigned, but disenrolled from prior to start of enrollment spell)
*For subsequent use in assigning plan fit measure!

egen region_code_year = group(region_code year)
replace year = year +1

gen contract_id = contract_id_Jan 
gen plan_id = plan_id_Jan 

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/InterimDataSet.dta", replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/InterimDataSet.dta", clear

cap drop _merge 

**Merge in plan assignment for folks who opted out of assignment pre actual start of enrollment (pre jan)

merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/sample/output/elc_actv_cancelled.dta", keep(1 3)

gen test = (cancl_contract_id == contract_id) & (cancl_plan_id == plan_id)

replace contract_id = cancl_contract_id if _merge == 3
replace plan_id = cancl_plan_id if _merge == 3

**Merge in fit measures for those who get reassigned
**Including for those opting out of reassigned plan ust before start of enrollment 

drop _merge
merge 1:1 bene_id year contract_id plan_id using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planunivlvlfit_all_wq.dta", keep(1 3)

eststo clear

gen presc_lowerquintile = prescperc < .2
gen spend_lowerquintile = perc < .2

replace elixsum = 0 if elixsum == .


*sort bene_id year contract_id plan_id 
*Generate some variables to test how random 'random' assignment is
*Note: Not currently using these variables very aggressively
sort region_code year contract_id_Dec plan_id_Dec
qby region_code year contract_id_Dec plan_id_Dec: egen denom = sum(switch_reas)
sort region_code year contract_id_Dec plan_id_Dec contract_id plan_id
qby region_code year contract_id_Dec plan_id_Dec contract_id plan_id: egen numer = sum(switch_reas)
gen fract = numer/denom
gsort region_code year contract_id_Dec plan_id_Dec -fract
qby region_code year contract_id_Dec plan_id_Dec: gen planfract = fract[1]

drop _merge
rename year yr

**Merge in additional enrollment info 
merge 1:1 bene_id yr using"/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/enrollment_data/output/lis_enroll_data", keep(1 3)
rename yr year

gen sameplanoveryear = (contract_id == contract_id12) & (plan_id == plan_id12) & (segment_next == segment_id12)
gen sametest = (contract_id == contract_id01) & (plan_id == plan_id01) & (segment_next == segment_id01)

gen switch_reasgn_stay = switch_reasgn == 1 & sameplanoveryear == 1

gen actv_return = (contract_id_Dec == contract_id12) & (plan_id_Dec == plan_id12) & (switch_reasgn == 1)
compress
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileOct2019.dta", replace

**********************
use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileOct2019.dta", clear

**Merge in inp, ER

drop cur_* fut_* pre_* post_*
merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/ED/output/ptdsamp_ER_util_qtr_pan.dta", keep(1 3) nogen
*tab year ER_merge
foreach x of varlist ER* {
replace `x' = 0 if `x' == .
}

merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/inp/output/inp_qtr_pan.dta", keep(1 3) nogen
*tab year numinp_merge
foreach x of varlist inp* {
replace `x' = 0 if `x' == .
}

foreach x in medpar car rx {
	merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_`x'_rdsamp/output/util_qtr_pan.dta", keep(1 3) nogen

}

merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_op_rd_samp/output/util_qtr_pan.dta", keep(1 3) nogen


foreach x of varlist car_spend* days_supply* med_spend* op_spend* pde_spend* number_of_prescriptions* num_pres* standardized* standardclass* chronic* nonchronic* {
replace `x' = 0 if `x' == .
}

forval x=1/16 {
gen nondrug_spend`x' = med_spend`x'+op_spend`x'+car_spend`x'

}

forval x=1/16 {
gen all_spend`x'=nondrug_spend`x'+pde_spend`x'
}

forval x=1/16 {
rename med_spend`x' ip_spend`x'
}


forval y=1/16 {
foreach x in nondrug_spend ip_spend pde_spend all_spend number_of_prescriptions days_supply standardizedclassspend standardizedplanspend standardclassgenspend chronicspend nonchronicspend {
gen `x'log`y' = log(`x'`y'+1)
} 
}

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_event.dta",replace

*Reshape: Construct dataset where observation level is at person-quarter rather than person-year

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_event.dta", clear

drop num_pres_hibene* num_pres_lowbene* days_supply_hibene* days_supply_lowbene* 

reshape long pde_spend pde_spendlog number_of_prescriptions number_of_prescriptionslog days_supply days_supplylog ER ip_spend inp_count ip_spendlog nondrug_spend nondrug_spendlog all_spend all_spendlog standardizedplanspend standardizedplanspendlog standardizedclassspend standardizedclassspendlog standardclassgenspend standardclassgenspendlog pde_spend_hibene pde_spend_lowbene chronicspend chronicspendlog nonchronicspend nonchronicspendlog, i(bene_id year) j(new) 

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_eventreshaped.dta", replace

*********************
*Build file tracking first ever year of enrollment in Part D
use "/disk/agedisk3/medicare.work/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/output/elc_actv_init.dta"

keep bene_id enrlmt_yr_1st

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/year_one_partd.dta", replace
