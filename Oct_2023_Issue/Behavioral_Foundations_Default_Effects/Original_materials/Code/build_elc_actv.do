*This do file takes the raw file with choice variable (elc) and creates files with active choice indicators, which are then merged with the main samples.
*Final end products: 
*elc_actv_init.dta; 
*elc_actv_ind.dta; 
*elc_actv_5yr_upd.dta

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
log using ../output/build_elc_actv.log, replace

******
*Read in raw elc files and create helper variables
clear
forv year = 2007/2015 {
	append using ${elc}/elc`year', force
}
save ../temp/elc, replace

use ../temp/elc, clear
tab ref_year
unique bene_id

tab audt_sqnc_num
drop if audt_sqnc_num != 0
drop audt_sqnc_num

gen enrlmt_efctv_mo = mofd(enrlmt_efctv_dt)
format enrlmt_efctv_mo %tm
gen enrlmt_efctv_yr = yofd(enrlmt_efctv_dt)
format enrlmt_efctv_yr %ty

sort bene_id ref_year enrlmt_efctv_dt

bysort bene_id (ref_year enrlmt_efctv_dt): gen enrlmt_yr_1st = enrlmt_efctv_yr[1]
bysort bene_id (ref_year enrlmt_efctv_dt): gen enrlmt_mo_yr_1st = enrlmt_efctv_mo[1]
format enrlmt_mo_yr_1st %tm

******
*Active choice status at initial enrollment
preserve
bysort bene_id (enrlmt_efctv_dt): gen elc_1st_ind = (_n == 1)

gen chooser_init = (enrlmt_type_cd == "B") if elc_1st_ind == 1
tab chooser_init 

keep if elc_1st_ind == 1
unique bene_id
save ../output/elc_actv_init.dta, replace
restore

******
*Active choice indicator for each plan
preserve

bysort bene_id (enrlmt_efctv_dt): gen enrlmt_type_cd_1 = enrlmt_type_cd[_n -1]
tab enrlmt_type_cd_1 if enrlmt_type_cd == "D"

tab enrlmt_type_cd
gen type_actv_ind = (enrlmt_type_cd == "B" | (enrlmt_type_cd == "D" & enrlmt_type_cd_1 == "B"))
tab type_actv_ind

gen type_auto_ind = (enrlmt_type_cd == "A" | (enrlmt_type_cd == "D" & enrlmt_type_cd_1 == "A") | enrlmt_type_cd == "C" | (enrlmt_type_cd == "D" & enrlmt_type_cd_1 == "C"))
tab type_auto_ind

gen type_reasgn_ind = (enrlmt_type_cd == "H" | (enrlmt_type_cd == "D" & enrlmt_type_cd_1 == "H"))
tab type_reasgn_ind

gen type_oth_ind = type_actv_ind == 0 & type_auto_ind == 0 & type_reasgn_ind == 0
tab type_oth_ind	
	
bysort bene_id ref_year: egen yr_dup = count(ref_year)
tab yr_dup
drop yr_dup

bysort bene_id ref_year contract_id plan_id: egen yr_plan_dup = count(ref_year)
tab yr_plan_dup
drop yr_plan_dup

gen enrl_mo = month(enrlmt_efctv_dt)
tab enrl_mo

keep bene_id ref_year enrlmt_efctv_dt disenrlmt_dt enrlmt_type_cd contract_id plan_id type_actv_ind type_auto_ind type_reasgn_ind type_oth_ind enrl_mo

save ../temp/elc_actv_ind.dta, replace

restore

******
*Active choice status post initial enrollment
*Keep individuals continuously observed for at least 5 years post initial enrollment
tab enrlmt_yr_1st
keep if enrlmt_yr_1st <= 2010

bysort bene_id (ref_year enrlmt_efctv_dt): gen elc_1st_ind = (_n == 1)
bysort bene_id ref_year (enrlmt_efctv_dt): gen elc_yr_cnt = (_n == 1)
bysort bene_id (ref_year enrlmt_efctv_dt): gen elc_yr_seq = sum(elc_yr_cnt)
bysort bene_id (ref_year enrlmt_efctv_dt): gen elc_yr_sum = elc_yr_seq[_N]

drop if elc_yr_sum < 5 & elc_yr_sum != .
drop if elc_yr_seq > 6 & elc_yr_seq != .

gen yr_by_seq = enrlmt_yr_1st + elc_yr_seq - 1
gen gap_ind = ref_year != yr_by_seq
bysort bene_id (ref_year enrlmt_efctv_dt): egen gap_drop = total(gap_ind)
drop if gap_drop != 0
drop gap_ind gap_drop yr_by_seq

*Keep only observations when there's a change in part D plan
drop ref_year elc_1st_ind elc_yr_cnt elc_yr_seq elc_yr_sum 
duplicates drop

***
bysort bene_id (enrlmt_efctv_dt): gen elc_1st_ind = (_n == 1)

gen mth_aft_enrlmt = enrlmt_efctv_mo - enrlmt_mo_yr_1st
tab mth_aft_enrlmt
tab mth_aft_enrlmt if elc_1st_ind == 1

tab enrlmt_type_cd
tab enrlmt_type_cd if elc_1st_ind == 1

gen chooser_init = (enrlmt_type_cd == "B") if elc_1st_ind == 1
tab chooser_init 

bysort bene_id (enrlmt_efctv_dt): gen enrlmt_type_cd_1 = enrlmt_type_cd[_n -1]
gen actv_ind = enrlmt_type_cd == "B" | (enrlmt_type_cd == "D" & enrlmt_type_cd_1 == "B")

***
*Create indicator for cumulative active choice status
foreach t in 12 24 36 48 60 {
	gen mth_aft_0_`t'_ind = (mth_aft_enrl >= 1 & mth_aft_enrl <= `t') | elc_1st_ind == 1

	gen actv_0_`t'mth_ind = actv_ind * mth_aft_0_`t'_ind
	bysort bene_id (enrlmt_efctv_dt): egen actv_0_`t'mth_sum = total(actv_0_`t'mth_ind)
	gen actv_0_`t'mth = (actv_0_`t'mth_sum > 0 & actv_0_`t'mth_sum != .)
	drop actv_0_`t'mth_ind
}	

keep if mth_aft_enrl <= 60
bysort bene_id (enrlmt_efctv_dt): egen actv_ind_tot_cnt = total(actv_ind)
	
keep if elc_1st_ind == 1
unique bene_id

save ../output/elc_actv_5yr_upd.dta, replace

log close


