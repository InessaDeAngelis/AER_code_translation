
*Purpose: Generate person-quarter-year level dataset, tracking active choice status
*plan of enrollment, and switching status from reassignment

*Track status as of latest point in the quarter, for an 8 quarter period
*following event, for each person

*Input into event study analytic data construction 

cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/code/"

*Restrict plan enrollment/election file to our main sample

use ../temp/prelim_sample_mcr_20pct_raw_LIS65_07_15, clear
duplicates drop bene_id, force
keep bene_id
save ../temp/person_list.dta, replace

use ../temp/elc_actv_ind, clear
merge m:1 bene_id using ../temp/person_list.dta, keep(3)
save ../temp/elc_actv_ind_lim, replace

*Start by generating plan enrollment/active choice type as of beginning and end of year
*for each person

use ../temp/elc_actv_ind_lim, clear
bysort bene_id ref_year (enrlmt_efctv_dt): gen last = (_n == _N)
	tab last
	keep if last == 1
	keep bene_id ref_year contract_id plan_id
	rename contract_id contract_id8
	rename plan_id plan_id8
	replace ref_year = ref_year+1
save ../temp/yr_end, replace

use ../temp/elc_actv_ind_lim, clear
gen mon_date = month(enrlmt_efctv_dt)
gen yr_date = year(enrlmt_efctv_dt)
gen dis_mon = month(disenrlmt_dt)
gen dis_yr = year(disenrlmt_dt)
keep if (mon_date <= 1 & yr_date == ref_year) | (yr_date < ref_year)
bysort bene_id ref_year (enrlmt_efctv_dt): gen last = (_n == _N)
	tab last
	keep if last == 1
	drop if (dis_mon < 3 & dis_yr <= ref_year & dis_yr ~= .)
	keep bene_id ref_year contract_id plan_id 
	rename contract_id contract_idxb 
	rename plan_id plan_idxb
*	rename type_actv_ind type_actv_ind_9
	
save ../temp/yr_begin, replace

*Generate plan enrollment and active choice status by quarter, for 8 quarters following each
*point in time. This is as of the end of each quarter

use ../temp/elc_actv_ind_lim, clear
gen mon_date = month(enrlmt_efctv_dt)
gen yr_date = year(enrlmt_efctv_dt)
gen dis_mon = month(disenrlmt_dt)
gen dis_yr = year(disenrlmt_dt)
keep if (mon_date <= 3 & yr_date == ref_year) | (yr_date < ref_year)
bysort bene_id ref_year (enrlmt_efctv_dt): gen last = (_n == _N)
	tab last
	keep if last == 1
	drop if (dis_mon < 3 & dis_yr <= ref_year & dis_yr ~= .)
	keep bene_id ref_year contract_id plan_id type_actv_ind

	gen q = 9
save ../temp/stats9, replace

use ../temp/elc_actv_ind_lim, clear
gen mon_date = month(enrlmt_efctv_dt)
gen yr_date = year(enrlmt_efctv_dt)
gen dis_mon = month(disenrlmt_dt)
gen dis_yr = year(disenrlmt_dt)
keep if (mon_date <= 6 & yr_date == ref_year) | (yr_date < ref_year)
bysort bene_id ref_year (enrlmt_efctv_dt): gen last = (_n == _N)
	tab last
	keep if last == 1
	drop if (dis_mon < 6 & dis_yr <= ref_year & dis_yr ~= .)
	keep bene_id ref_year contract_id plan_id type_actv_ind

	gen q = 10
save ../temp/stats10, replace

use ../temp/elc_actv_ind_lim, clear
gen mon_date = month(enrlmt_efctv_dt)
gen yr_date = year(enrlmt_efctv_dt)
gen dis_mon = month(disenrlmt_dt)
gen dis_yr = year(disenrlmt_dt)
keep if (mon_date <= 9 & yr_date == ref_year) | (yr_date < ref_year)
bysort bene_id ref_year (enrlmt_efctv_dt): gen last = (_n == _N)
	tab last
	keep if last == 1
	drop if (dis_mon < 9 & dis_yr <= ref_year & dis_yr ~= .)
	keep bene_id ref_year contract_id plan_id type_actv_ind

	gen q = 11
save ../temp/stats11, replace

use ../temp/elc_actv_ind_lim, clear
gen mon_date = month(enrlmt_efctv_dt)
gen yr_date = year(enrlmt_efctv_dt)
gen dis_mon = month(disenrlmt_dt)
gen dis_yr = year(disenrlmt_dt)
keep if (mon_date <= 12 & yr_date == ref_year) | (yr_date < ref_year)
bysort bene_id ref_year (enrlmt_efctv_dt): gen last = (_n == _N)
	tab last
	keep if last == 1
	drop if (dis_mon < 12 & dis_yr <= ref_year & dis_yr ~= .)
	keep bene_id ref_year contract_id plan_id type_actv_ind

	gen q = 12
save ../temp/stats12, replace

use ../temp/stats9, clear
replace ref_year = ref_year - 1
*rename contract_id_9 contract_id_13
*	rename plan_id_9 plan_id_13
*	rename type_actv_ind_9 type_actv_ind_13
drop q
gen q = 13
	save ../temp/stats13, replace
	
	use ../temp/stats10, clear
replace ref_year = ref_year - 1
*rename contract_id_10 contract_id_14
*	rename plan_id_10 plan_id_14
*	rename type_actv_ind_10 type_actv_ind_14
drop q
gen q = 14
	save ../temp/stats14, replace
	
		use ../temp/stats11, clear
replace ref_year = ref_year - 1

drop q
gen q = 15
	save ../temp/stats15, replace
	
		use ../temp/stats12, clear
replace ref_year = ref_year - 1

drop q
gen q = 16
	save ../temp/stats16, replace

*Stack all the quarter level observations together
	clear
	forval t=9/16 {
		append using ../temp/stats`t'
	}
	reshape wide contract_id plan_id type_actv_ind, i(bene_id ref_year) j(q)
	save ../temp/stats_all, replace
	
	use ../temp/stats_all, clear
	merge 1:1 bene_id ref_year using ../temp/yr_end, keep(3)
	cap drop _merge
	merge 1:1 bene_id ref_year using ../temp/yr_begin, keep(3)
	
	forval t = 9/16 {
	gen switch_from_Janx`t' = ((plan_idxb == plan_id`t') & (contract_idxb == contract_id`t'))
	gen switch_from_Jan`t' = switch_from_Janx`t' == 0
	
	drop switch_from_Janx`t' 
	}
	
		forval t = 9/16 {

	gen switch_from_Decx`t' = ((plan_id8 == plan_id`t') & (contract_id8 == contract_id`t'))
	gen switch_from_Dec`t' = switch_from_Decx`t' == 0
	drop switch_from_Decx`t'
	}
	
	drop contract* plan* _merge
	reshape long switch_from_Jan type_actv_ind switch_from_Dec, i(bene_id ref_year) j(new)
	save ../temp/enroll_panel_final, replace
