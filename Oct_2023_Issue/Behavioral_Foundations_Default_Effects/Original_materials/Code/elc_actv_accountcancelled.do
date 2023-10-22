cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/code/"
*for testing code interactively

*Purpose: Construct dataset tracking randomized plan assignments, for instances where people opted out of the assignments pre-start of enrollment spell (but post receiving assignment)
*This can help us construct a plan assignment measure that is fully complete, and that reflects the original set of assignments, and that is not tainted by opt-out of the assignment pre-actual enrollment spell

*adopath + ../../../../lib/ado/
*preliminaries, globals(../../../../lib/globals)

global bsfab "../../../../raw/medicare_part_ab_bsf/data"
global bsfab_20pct "../../../../raw/medicare_part_ab_bsf_20pct/data"
global bsfd "../../../../raw/medicare_part_d_bsf/data"
global elc "../../../../raw/medicare_part_d_elc/data"
global states "../../../../raw/geo_data/data/states"
global mcdps "../../../../raw/medicaid_ps/data"
global mcr_mcd_xwk "../../../../raw/medicare_medicaid_crosswalk/data"

use ../temp/elc, clear
tab ref_year
*unique bene_id

gen enrlmt_efctv_month = month(enrlmt_efctv_dt)
*format enrlmt_efctv_month %tm
gen enrlmt_efctv_yr = yofd(enrlmt_efctv_dt)
format enrlmt_efctv_yr %ty

**Keep only enrollment records relevant to begin of year enrollments/assignments
keep if enrlmt_efctv_month == 1

gen nonactive_ind = (enrlmt_type_cd ~= "B")
gen audt_sqnc_nonzero = (audt_sqnc_num ~= 0)

keep if audt_sqnc_nonzero == 1
keep if nonactive_ind == 1

gsort bene_id ref_year enrlmt_efctv_dt 
qby bene_id ref_year: gen elc_1st_ind = (_n == 1)

*Keep only first record
*Further, restrict only to potentially cancelled/reversed records
keep if elc_1st_ind == 1

rename enrlmt_type_cd enrlmt_type_cancld_code
rename contract_id cancl_contract_id
rename plan_id cancl_plan_id

keep cancl_* enrlmt_type_cancld_code bene_id ref_year
rename ref_year year
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/sample/output/elc_actv_cancelled.dta", replace
