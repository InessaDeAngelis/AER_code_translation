*This do file takes national Medicare initial enrollment sample and NY&TX Medicaid sample to create a merged sample of beneficiaries in NY & TX who were in Medicaid due to disability and then aged into Medicare at 65.
*Final product: prelim_merge_sample_mcd_dblt_noMCR_mcr_match_slct.dta

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

cap log close
log using ../output/build_mcr_mcd_nytx_merge.log, replace


*Program selecting individuals who satisfies requirement for 12 months after month-year
program select_12mth_after
   args var month year idname yearname
   
   gen `var'_stct = (`month' == 12 & `yearname' == `year' + 1 & `var'_1 == 1 & `var'_2 == 1 & `var'_3 == 1 & `var'_4 == 1 & `var'_5 == 1 & `var'_6 == 1 & `var'_7 == 1 & `var'_8 == 1 & `var'_9 == 1 & `var'_10 == 1 & `var'_11 == 1 & `var'_12 == 1)
   
   forvalues t = 1/11 {
	disp "month = `t'"
	local start = `t' + 1
	gen count = 0
	forvalues i = `start'/12 {
		disp "m`i' same year"
		replace count = count + `var'_`i' if `month' == `t' & `yearname' == `year'
	}
	replace `var'_stct = 1 if (count == 12 - `start' + 1) & `month' == `t' & `yearname' == `year'

	forvalues i = 1/`t' {
		disp "m`i' next year"
		replace count = count + `var'_`i' if `month' == `t' & `yearname' == `year' + 1	
	}
	replace `var'_stct = 1 if (count == `t') & `month' == `t' & `yearname' == `year' + 1
	
	drop count 
	
}	
	
bysort `idname': egen `var'_stct_sum = total(`var'_stct)
tab `var'_stct_sum
tab `var'_stct_sum if `month' == 12
tab `var'_stct_sum if `month' < 12 & `month' != .

drop if (`var'_stct_sum < 1 & `month' == 12) | (`var'_stct_sum < 2 & `month' < 12)

unique `idname'

end

******
*Merge MCD NY&TX disabled noMCR sample with MCR
use ../temp/prelim_sample_mcd_dblt_noMCR, clear

rename bene_id_mcr bene_id
rename ref_year year
merge 1:m bene_id year using ../temp/prelim_sample_mcr_raw_06_12
save ../temp/prelim_merge_sample_mcd_dblt_noMCR_mcr, replace

tab year if _merge == 1
tab el_mdcr_ben_mo_cnt if _merge == 1

keep if _merge == 3
tab orec if _merge == 3
unique bene_id if _merge == 3

*Merge MCD NY&TX disabled noMCR sample with MCR annotated with enrollment details
use ../temp/prelim_sample_mcd_dblt_noMCR, clear

rename bene_id_mcr bene_id
rename ref_year year
merge 1:m bene_id year using ../temp/prelim_sample_mcr_annotate_06_12
tab orec if _merge == 3

save ../temp/prelim_merge_sample_mcd_dblt_noMCR_mcr_annotate, replace

tab year if _merge == 1
tab el_mdcr_ben_mo_cnt if _merge == 1

gen match_ind = (_merge == 3)
bysort bene_id: egen match_sum = total(match_ind)
tab match_sum
drop if match_sum == 0
unique bene_id
sort bene_id year

save ../temp/prelim_merge_sample_mcd_dblt_noMCR_mcr_match, replace

*Keep individuals with 12 months of Medicaid enrollment and 12 months of Medicare enrollment that satisfied the sample selection criteria
gen match_yr = year if match_ind == 1
bysort bene_id (year): egen match_yr_1st = min(match_yr)
tab match_yr_1st
drop match_yr match_ind

tab orec if match_yr_1st < el_elig_yr
tab orec if match_yr_1st == el_elig_yr
tab orec if match_yr_1st > el_elig_yr

unique bene_id if match_yr_1st >= el_elig_yr

gsort bene_id -_merge 
by bene_id: carryforward enrl_mo_yr_gen enrl_mo_yr_d enrl_mo_yr_nonhmo enrl_mo_yr_qual elig_mo_yr, replace

keep if (enrl_mo_yr_qual - elig_mo_yr <= 3 & enrl_mo_yr_qual - elig_mo_yr >= -3)
keep if (enrl_mo_yr_gen - elig_mo_yr <= 3 & enrl_mo_yr_gen - elig_mo_yr >= -3)

forvalues t = 1/9 {
	rename enrl_qual_0`t' enrl_qual_`t'
	rename enrl_nonhmo_0`t' enrl_nonhmo_`t'
	rename enrl_d_0`t' enrl_d_`t'
	rename enrl_gen_0`t' enrl_gen_`t'
}	

gen enrl_qual_yr_init = yofd(dofm(enrl_mo_yr_qual))	
gen enrl_qual_mo_init = month(dofm(enrl_mo_yr_qual))

select_12mth_after enrl_qual enrl_qual_mo_init enrl_qual_yr_init bene_id year

sort bene_id year
save ../temp/prelim_merge_sample_mcd_dblt_noMCR_mcr_match_slct, replace


log close


