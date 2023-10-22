*Purpose: Analytic data construction for 'plan exit' analyses

*for testing code interactively
cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/submission/code/"

adopath + ../../../../lib/ado/

global bsfab "../../../../raw/medicare_part_ab_bsf/data"
global bsfab_20pct "../../../../raw/medicare_part_ab_bsf_20pct/data"
global bsfd "../../../../raw/medicare_part_d_bsf/data"
global elc "../../../../raw/medicare_part_d_elc/data"
global states "../../../../raw/geo_data/data/states"
global mcdps "../../../../raw/medicaid_ps/data"
global mcr_mcd_xwk "../../../../raw/medicare_medicaid_crosswalk/data"
global ptd_bnch "../../../../raw/medicare_part_d_benchmark/data"
global samp "../output"
global car "../../../../raw/medicare_part_ab_car/data"
global med "../../../../raw/medicare_part_ab_med/data"
global op "../../../../raw/medicare_part_ab_op/data"

global util_med "../../../../derived/utilization_med/output"
global util_op "../../../../derived/utilization_op/output"
global util_car "../../../../derived/utilization_car/output"
global util_pde "../../../../derived/utilization_pde/output"


cap ssc install distinct

******
*Prepare data for regression analysis

use "$samp/ptd_LIS65_samp_exit.dta", clear
tab in_20pct_sample
keep bene_id  ref_year
save "$samp/ptd_LIS65_samp_exit_20pct.dta", replace 
keep bene_id
duplicates drop
save ../temp/ptd_LTS65_exit_20pct_bene_id.dta, replace

*Construct baseline elixhauser score based on inpatient hospitalizations (for which we have full rather than 20% sample)

forvalues year = 2007/2014 {
	use "$samp/ptd_LIS65_samp_exit.dta", clear
	keep if ref_year == `year'
	keep bene_id in_20pct_sample
	save ../temp/ptd_LTS65_exit_bene_id_`year'.dta, replace
	
	use ${med}/dgnscd`year', clear
	merge m:1 bene_id using ../temp/ptd_LTS65_exit_bene_id_`year'.dta
	tab _merge in_20pct_sample 
	tab in_20pct_sample if _merge == 2
	tab in_20pct_sample if _merge == 3
	keep if _merge == 3
	drop _merge
	reshape wide dgnscd, i(bene_id medparid) j(dgnscdseq)
	keep bene_id dgnscd1-dgnscd9
	save ../temp/med_`year', replace
	
	elixhauser dgnscd*, index(e) idvar(bene_id)
	unique bene_id
	gen ref_year = `year'
	
	save ../temp/elixhauser_med_`year', replace
}

clear all
forvalues year = 2007/2014 {
	append using ../temp/elixhauser_med_`year'
}
save ../temp/elixhauser_med, replace

use "$samp/ptd_LIS65_samp_exit.dta", clear
merge 1:1 bene_id ref_year using ../temp/elixhauser_med
drop if _merge == 2

replace elixsum = 0 if _merge == 1
tab elixsum
mvencode ynel*, mv(0) override
drop _merge
save "$samp/ptd_LIS65_samp_exit_elix_med.dta", replace

*Generate gender indicator and age groups
gen female = sex == 2
replace female = . if sex == 0

xtile age_grp = age, nq(5)

*Generate variable for years enrolled in incumbent plan
gen dec_31_yr = mdy(12,31,ref_year)
format dec_31_yr %td
tab dec_31_yr

gen enrl_days = dec_31_yr - enrlmt_efctv_dt_Dec
gen enrl_yrs_norm = enrl_days/365
label variable enrl_yrs_norm "Years Enrolled in Exiting Plan"

gen enrl_efctv_yr = yofd(enrlmt_efctv_dt_Dec)
tab enrl_efctv_yr

egen plan_grp_Dec = group(contract_id_Dec plan_id_Dec segment_id)

save "$samp/ptd_LIS65_samp_exit_elix_med.dta", replace
