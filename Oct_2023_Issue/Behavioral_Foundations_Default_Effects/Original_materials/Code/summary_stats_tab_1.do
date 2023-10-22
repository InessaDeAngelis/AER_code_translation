*This do file tabulates summary statistics of demographics and prescription drug utilization for different samples.
*This file produces Table 1
*Final products:
*summ_stat_nytx_mcd_mcr_samp_dem.csv;
*summ_stat_nytx_mcd_mcr_samp_20_pct_util_elix_chronicspend.csv;
*summ_stat_national_mcr_ent_samp_dem.csv;
*summ_stat_national_mcr_ent_samp_20_pct_util_elix_chronicspend.csv;
*summ_stat_LIS_summ_stats_samp_simp_20pct_util_elix_chronicspend.csv;
*summ_stat_rd_samp_20pct_util_elix_chronicspend.csv

*for testing code interactively
cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/submission/code/"

clear all
set more off
set maxvar 20000

adopath + ../../../../lib/ado/

global bsfab "../../../../raw/medicare_part_ab_bsf/data"
global bsfab_20pct "../../../../raw/medicare_part_ab_bsf_20pct/data"

global sample "../"
global elix_sample "../output"

global car "../../../../raw/medicare_part_ab_car/data"
global med "../../../../raw/medicare_part_ab_med/data"
global op "../../../../raw/medicare_part_ab_op/data"

global util_med "../../../../derived/utilization_med/output"
global util_op "../../../../derived/utilization_op/output"
global util_car "../../../../derived/utilization_car/output"
global util_pde "../../../../derived/utilization_pde/output"

global util_med_monthly "../../../../derived/utilization_med_monthly/output"
global util_op_monthly "../../../../derived/utilization_op_monthly/output"
global util_car_monthly "../../../../derived/utilization_car_monthly/output"
global util_pde_monthly "../../../../derived/utilization_pde_monthly/output"

cap log close
log using ../output/summary_stats_tab_1.log, replace text

******
*Elixhauser index calculation based on claims data
cap program drop elix_calc

program define elix_calc

	args input_data_file output_data_name first_yr last_yr
	
	forvalues year = `first_yr'/2009 {

		use `input_data_file', clear
		keep if year == `year'
		keep bene_id
		save ../temp/bene_id_`output_data_name'_`year'.dta, replace
	
		*Compile all claims files
		use ${med}/dgnscd`year', clear
		merge m:1 bene_id using ../temp/bene_id_`output_data_name'_`year', keep(3) nogen
		reshape wide dgnscd, i(bene_id medparid) j(dgnscdseq)
		keep bene_id dgnscd1-dgnscd9
		save ../temp/med_`output_data_name'_`year', replace
		
		use bene_id dgns_cd1-dgns_cd8 using ${car}/carc`year', clear
		merge m:1 bene_id using ../temp/bene_id_`output_data_name'_`year', keep(3) nogen
		rename dgns_cd* dgnscd*
		save ../temp/car_`output_data_name'_`year', replace

		use bene_id dgnscd1-dgnscd10 using ${op}/opc`year', clear
		merge m:1 bene_id using ../temp/bene_id_`output_data_name'_`year', keep(3) nogen
		save ../temp/op_`output_data_name'_`year', replace

		clear all
		foreach file in med car op {
			append using ../temp/`file'_`output_data_name'_`year'
		}
		save ../temp/appended_diagnosis_file_`output_data_name'_`year', replace
		
		*Generate Elixhauser score
		elixhauser dgnscd*, index(e) idvar(bene_id)
		unique bene_id
		gen year = `year'
		
		save ../temp/elixhauser_`output_data_name'_`year'_det, replace		
		
		keep bene_id year elixsum
		
		save ../temp/elixhauser_`output_data_name'_`year', replace
	}

	forvalues year = 2010/`last_yr' {

		use `input_data_file', clear
		keep if year == `year'
		keep bene_id
		save ../temp/bene_id_`output_data_name'_`year'.dta, replace

		*Compile all claims files	
		use ${med}/dgnscd`year', clear
		merge m:1 bene_id using ../temp/bene_id_`output_data_name'_`year', keep(3) nogen
		reshape wide dgnscd, i(bene_id medparid) j(dgnscdseq)
		keep bene_id dgnscd1-dgnscd9
		save ../temp/med_`output_data_name'_`year', replace
		
		use bene_id icd_dgns_cd1-icd_dgns_cd12 using ${car}/carc`year', clear
		merge m:1 bene_id using ../temp/bene_id_`output_data_name'_`year', keep(3) nogen
		rename icd_dgns_cd* dgnscd*
		save ../temp/car_`output_data_name'_`year', replace

		use bene_id icd_dgns_cd1-icd_dgns_cd25 using ${op}/opc`year', clear
		merge m:1 bene_id using ../temp/bene_id_`output_data_name'_`year', keep(3) nogen
		rename icd_dgns_cd* dgnscd*	
		save ../temp/op_`output_data_name'_`year', replace

		clear all
		foreach file in med car op {
			append using ../temp/`file'_`output_data_name'_`year'
		}
		save ../temp/appended_diagnosis_file_`output_data_name'_`year', replace

		*Generate Elixhauser score		 
		elixhauser dgnscd*, index(e) idvar(bene_id)
		unique bene_id
		gen year = `year'
		
		save ../temp/elixhauser_`output_data_name'_`year'_det, replace
		
		keep bene_id year elixsum
		
		save ../temp/elixhauser_`output_data_name'_`year', replace

	}

	*Append all years together
	clear
	forvalues year = `first_yr'/`last_yr' {
		append using ../temp/elixhauser_`output_data_name'_`year'
	}
	save ../output/elixhauser_`output_data_name', replace

	use `input_data_file', clear
	cap drop _merge
	merge 1:1 bene_id year using ../output/elixhauser_`output_data_name', assert(1 3) keep(1 3)
	tab year _merge

	replace elixsum = 0 if _merge == 1

	tab elixsum
	drop _merge

	save ../output/elix_`output_data_name', replace

end

******
*Construct complementary datasets
forvalues year = 2007/2015 {
        append using ${sample}/temp/sample_list_20pct_`year'
	duplicates drop
}
save ${sample}/temp/sample_list_20pct_2007_15.dta, replace

use "${sample}/output/opt1pde_spending_by_chronic.dta", clear
gen year = yofd(dofq(srvc_qtr))
collapse (sum) nonchronicspend chronicspend, by(bene_id year)
save "${sample}/output/opt1pde_spending_by_chronic_by_year.dta", replace
	
******
*NY-TX MCD-MCR sample
use ${elix_sample}/primary_elc_elixhauser_5yr.dta, clear
unique bene_id

gen enrl_yr_qual = yofd(dofm(enrl_mo_yr_qual))
cap drop year
gen year = enrl_yr_qual + 1 //first calendar year after initial enrollment 

gen yr_of_birth = yofd(el_dob)
gen age = year - yr_of_birth
tab age

gen female = (el_sex_cd == "F")

estpost tabstat age female, stat(mean)
esttab using ../output/tables/summ_stat_nytx_mcd_mcr_samp_dem.csv, cells("age female") replace

*Elixhauser and Spending
cap drop _merge
merge m:1 bene_id using ${sample}/temp/sample_list_20pct_2007_15.dta, assert (1 2 3) keep(1 3) keepusing(*) gen(in_20pct_sample)
recode in_20pct_sample 1=0 3=1
label define in_20pct_sample 0 "0" 1 "1"
label values in_20pct_sample in_20pct_sample		

keep if in_20pct_sample == 1

keep bene_id enrl_mo_yr_qual year age female elixsum
rename elixsum elixsum_mcd

save ../temp/nytx_mcd_mcr_samp_20_pct.dta, replace

*Spending
foreach x in med op car pde {
	merge 1:1 bene_id year using "${util_`x'}/utilization.dta", keep(1 3) gen(`x'_merge)
	tab year `x'_merge
	sum `x'_spend, det
	replace `x'_spend = 0 if `x'_spend == .
}

gen non_pde_spend = med_spend + op_spend + car_spend

cap drop _merge
merge 1:1 bene_id year using "${sample}/output/opt1pde_spending_by_chronic_by_year.dta", keep(1 3) gen(chronic_merge)
mvencode nonchronicspend chronicspend, mv(0) override

save ../temp/nytx_mcd_mcr_samp_20_pct_util.dta, replace

*Elixhauser
elix_calc "../temp/nytx_mcd_mcr_samp_20_pct_util.dta" nytx_mcd_mcr_samp_20_pct_util 2008 2011

use ../output/elix_nytx_mcd_mcr_samp_20_pct_util, clear

estpost tabstat age female elixsum pde_spend chronicspend non_pde_spend, stat(count mean p25 p50 p75)
esttab using ../output/tables/summ_stat_nytx_mcd_mcr_samp_20_pct_util_elix_chronicspend.csv, cells("age female elixsum pde_spend chronicspend non_pde_spend") replace


******
*National MCR entrance sample

use ${sample}/output/actv_secondary_samp_5yr.dta, clear
unique bene_id

gen enrl_yr_qual = yofd(dofm(enrl_mo_yr_qual))
count if enrl_yr_qual != year
drop year
gen year = enrl_yr_qual + 1 //first calendar year after initial enrollment 

gen yr_of_birth = yofd(bene_dob)
gen age = year - yr_of_birth
tab age

gen female = (sex == 2)

estpost tabstat age female, stat(mean)
esttab using ../output/tables/summ_stat_national_mcr_ent_samp_dem.csv, cells("age female") replace

*Elixhauser and Spending
cap drop _merge
merge m:1 bene_id using ${sample}/temp/sample_list_20pct_2007_15.dta, assert (1 2 3) keep(1 3) keepusing(*) gen(in_20pct_sample)
recode in_20pct_sample 1=0 3=1
label define in_20pct_sample 0 "0" 1 "1"
label values in_20pct_sample in_20pct_sample		

keep if in_20pct_sample == 1

keep bene_id enrl_mo_yr_qual year age female 

save ../temp/national_mcr_ent_samp_20_pct.dta, replace

*Spending
foreach x in med op car pde {
	merge 1:1 bene_id year using "${util_`x'}/utilization.dta", keep(1 3) gen(`x'_merge)
	tab year `x'_merge
	sum `x'_spend, det
	replace `x'_spend = 0 if `x'_spend == .
}

gen non_pde_spend = med_spend + op_spend + car_spend

cap drop _merge
merge 1:1 bene_id year using "${sample}/output/opt1pde_spending_by_chronic_by_year.dta", keep(1 3) gen(chronic_merge)
mvencode nonchronicspend chronicspend, mv(0) override

save ../temp/national_mcr_ent_samp_20_pct_util.dta, replace

*Elixhauser
elix_calc "../temp/national_mcr_ent_samp_20_pct_util.dta" national_mcr_ent_samp_20_pct_util 2007 2012

use ../output/elix_national_mcr_ent_samp_20_pct_util, clear

estpost tabstat age female elixsum pde_spend chronicspend non_pde_spend, stat(count mean p25 p50 p75)
esttab using ../output/tables/summ_stat_national_mcr_ent_samp_20_pct_util_elix_chronicspend.csv, cells("age female elixsum pde_spend chronicspend non_pde_spend") replace


******
*Full LIS Sample (20%)

use ${sample}/output/LIS_summ_stats_samp_simp, clear

keep if in_20pct_sample == 1

*Spending
foreach x in med op car pde {
	merge 1:1 bene_id year using "${util_`x'}/utilization.dta", keep(1 3) gen(`x'_merge)
	tab year `x'_merge
	sum `x'_spend, det
	replace `x'_spend = 0 if `x'_spend == .
}

gen non_pde_spend = med_spend + op_spend + car_spend

keep if year >= 2007 & year <= 2014

cap drop _merge
merge 1:1 bene_id year using "${sample}/output/opt1pde_spending_by_chronic_by_year.dta", keep(1 3)
tab year _merge	
mvencode nonchronicspend chronicspend, mv(0) override
	
save ${sample}/output/LIS_summ_stats_samp_simp_20pct_util, replace

*Elixhauser
elix_calc ${sample}/output/LIS_summ_stats_samp_simp_20pct_util LIS_summ_stats_samp_simp_20pct_util 2007 2014

use ../output/elix_LIS_summ_stats_samp_simp_20pct_util, clear

estpost tabstat age female elixsum pde_spend chronicspend non_pde_spend, stat(count mean p25 p50 p75)
esttab using ../output/tables/summ_stat_LIS_summ_stats_samp_simp_20pct_util_elix_chronicspend.csv, cells("age female elixsum pde_spend chronicspend non_pde_spend") replace


******
*RD sample (20%)
use ${sample}/output/ptd_LIS65_20pct_samp.dta, clear
rename ref_year year
gen female = (sex == 2)

*Spending
foreach x in med op car pde {
	merge 1:1 bene_id year using "${util_`x'}/utilization.dta", keep(1 3) gen(`x'_merge)
	tab year `x'_merge
	sum `x'_spend, det
	replace `x'_spend = 0 if `x'_spend == .
}

gen non_pde_spend = med_spend + op_spend + car_spend

cap drop _merge
merge 1:1 bene_id year using "${sample}/output/opt1pde_spending_by_chronic_by_year.dta", keep(1 3)
tab year _merge	
mvencode nonchronicspend chronicspend, mv(0) override

save ${sample}/output/ptd_LIS65_20pct_samp_util, replace

*Elixhauser
elix_calc ${sample}/output/ptd_LIS65_20pct_samp_util rd_samp_20pct_util 2007 2014

use ../output/elix_rd_samp_20pct_util, clear

estpost tabstat age female elixsum pde_spend chronicspend non_pde_spend, stat(count mean p25 p50 p75)
esttab using ../output/tables/summ_stat_rd_samp_20pct_util_elix_chronicspend.csv, cells("age female elixsum pde_spend chronicspend non_pde_spend") replace


log close
