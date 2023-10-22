*Purpose: Generate active choice rate by quintile of within-person fit measure (Figure 1b, Appendix Figure 25)
*Specifically for sample that is aging in to Medicare at 65.

cd "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/utilization_fit/code/"
*for testing code interactively

clear all
set more off
set maxvar 20000

cap log close
log using ../output/log, replace text
cap mkdir ../temp

adopath + ../../../../lib/ado/
preliminaries, globals(../../../../lib/globals)

global rx "../../../../raw/medicaid_rx/data"
global sample "/disk/agedisk3/medicare.work/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample"

global util_med "../../../../derived/utilization_med/output"
global util_op "../../../../derived/utilization_op/output"
global util_car "../../../../derived/utilization_car/output"
global util_pde "../../../../derived/utilization_pde/output"


*Open plan election file
*Identify active choice status for first plan bene ends up in (as well as the associated plan ID)
*After aging into Medicare
use $sample/temp/elc_actv_ind, clear
	bysort bene_id ref_year (enrlmt_efctv_dt): egen yr_dup = count(ref_year)
	tab yr_dup
	bysort bene_id ref_year (enrlmt_efctv_dt): gen first = (_n == 1)
	tab first
	tab enrl_mo if first == 1
	keep if first == 1
	drop first yr_dup
	rename bene_id bene_id_mcr

save $sample/temp/elc_actv_ind_yr_1st, replace

*Get cross walk of plan_cd and actual plan information
use ../temp/CombinedFormAll.dta, clear
bysort plan_cd state_cd yr: gen obs_1st = _n == 1
keep if obs_1st == 1
keep yr contract_id plan_id segment_id state_cd plan_cd
save ../temp/CombinedFormAll_plan_cd_plan_id.dta, replace

*Stack together universe of all benchmark plans in individuals' choice sets, and their respective fits for individual

forvalues t = 2007/2010 {
	foreach x in NY TX {
		use ../temp/rx_util_ndc_fit_`x'_`t'.dta, clear
		gen state_cd = "`x'"
		gen yr = `t'
		merge m:1 yr state_cd plan_cd using ../temp/CombinedFormAll_plan_cd_plan_id.dta, keep(3) nogen
		save ../temp/rx_util_ndc_fit_`x'_`t'_plan_id.dta, replace
	}	
}

forvalues t = 2007/2010 {
	foreach x in NY TX {
		use ../temp/rx_util_ndc_fit_`x'_`t'_plan.dta, clear
		gen state_cd = "`x'"
		gen yr = `t'
		merge m:1 yr state_cd plan_cd using ../temp/CombinedFormAll_plan_cd_plan_id.dta, keep(3) nogen
		save ../temp/rx_util_ndc_fit_`x'_`t'_plan_id_info.dta, replace
	}	
}

clear all
forvalues t = 2007/2010 {
	foreach x in NY TX {
		append using ../temp/rx_util_ndc_fit_`x'_`t'_plan_id_info.dta
}
}
save ../output/rx_util_ndc_fit_plan_id_info.dta, replace

*Merge in actual plan bene initially ends up in, as well as active choice status for that plan
use ../output/rx_util_ndc_fit_plan_id_info.dta, clear
rename contract_id contract_id_info 
rename plan_id plan_id_info
rename yr ref_year
merge m:1 bene_id_mcr ref_year using $sample/temp/elc_actv_ind_yr_1st, keep(1 3)
save ../output/rx_util_ndc_fit_plan_id_info_elc.dta, replace

**Keep fit only of actual plan in which person ends up enrolled in
use ../output/rx_util_ndc_fit_plan_id_info_elc.dta, clear
gen actual_enroll = (contract_id == contract_id_info) & (plan_id == plan_id_info)
tab actual_enroll _merge
keep if actual_enroll == 1
save ../output/rx_util_ndc_fit_actual_enroll.dta, replace
use ../output/rx_util_ndc_fit_actual_enroll.dta, clear


rename bene_id bene_id_mcd
rename bene_id_mcr bene_id
rename ref_year year
save ../output/rx_util_ndc_fit_actual_enroll.dta, replace

*****
*Subset within-person fit measures

use ../output/rx_util_ndc_fit_actual_enroll.dta, clear
keep bene_id prescperc spendperc
save ../temp/FitMeasures.dta, replace

*Merge in 5 years of post-enrollment active choice history
*To dataset tracking fit of original plan
*Then, graph 5-year active choice propensity for all different quintiles 
*of initial fit assignment 
use ../output/rx_util_ndc_fit_actual_enroll.dta, clear
cap drop _merge
merge 1:1 bene_id using ${sample}/output/elc_actv_5yr, keep(3)
drop _merge
merge 1:1 bene_id using ../temp/FitMeasures.dta, keep(3)

rename chooser_init actv_0_0mth

forvalues t = 0(12)60 {
	rename actv_0_`t'mth actv`t'
}

reshape long actv, i(bene_id) j(mth)

save ../temp/PreQuintileGraph.dta, replace
