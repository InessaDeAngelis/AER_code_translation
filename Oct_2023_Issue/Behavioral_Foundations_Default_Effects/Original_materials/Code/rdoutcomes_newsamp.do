cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/code/"

*Purpose: Fixes definition of active choice to take into account so-called roll-over statuses 'D'. When this status is 'D', need to do look-back further in time to get at what actual active choice status is. 

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

bysort bene_id (enrlmt_efctv_dt): gen enrlmt_type_cd_1 = enrlmt_type_cd[_n -1]
bysort bene_id (enrlmt_efctv_dt): gen enrlmt_type_cd_2 = enrlmt_type_cd[_n -2]
bysort bene_id (enrlmt_efctv_dt): gen enrlmt_type_cd_3 = enrlmt_type_cd[_n -3]
bysort bene_id (enrlmt_efctv_dt): gen enrlmt_type_cd_4 = enrlmt_type_cd[_n -4]


gen type_actv_ind_pre = (enrlmt_type_cd == "B" | (enrlmt_type_cd == "D" & enrlmt_type_cd_1 == "B"))
gen type_actv_ind = (enrlmt_type_cd == "B" | (enrlmt_type_cd == "D" & enrlmt_type_cd_1 == "B") | (enrlmt_type_cd == "D" & enrlmt_type_cd_1 == "D" & enrlmt_type_cd_2 == "B") |  (enrlmt_type_cd == "D" & enrlmt_type_cd_1 == "D" & enrlmt_type_cd_2 == "D" & enrlmt_type_cd_3 == "B") | (enrlmt_type_cd == "D" & enrlmt_type_cd_1 == "D" & enrlmt_type_cd_2 == "D" & enrlmt_type_cd_3 == "D" & enrlmt_type_cd_4 == "B"))

bysort bene_id ref_year (enrlmt_efctv_dt): gen last = (_n == _N)
keep if last == 1

keep bene_id ref_year testpre type_actv_ind_new	

rename type_actv_ind_pre testpre
rename type_actv_ind type_actv_ind_new
rename ref_year year
replace year = year+1
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/newactvind.dta", replace
