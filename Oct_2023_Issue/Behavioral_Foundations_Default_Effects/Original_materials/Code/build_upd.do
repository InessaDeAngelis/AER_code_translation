*Purpose: Generate analytic file with linked Medicaid-Medicare, around active choice of those aging into Medicare at 65 from Medicaid, and factors influencing that active choice propensity (including based on HCC's pre-medicare-in Medicaid-and overlap between Medicaid drugs and post-65 Medicare formularies)

cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/utilization_fit/code/"
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


cap program drop util_file_prep
program util_file_prep

forvalues year = 2004/2010 {
	disp "`year' NY"
	use ${rx}/ny/maxdata_ny_rx_`year'.dta, clear
	rename *, lower
	describe ndc
	
	disp "`year' TX"
	use ${rx}/tx/maxdata_tx_rx_`year'.dta, clear
	rename *, lower
	describe ndc
		
}	
	
forvalues year = 2004/2010 {
	use ${rx}/ny/maxdata_ny_rx_`year'.dta, clear
	rename *, lower
	merge m:1 bene_id using ${sample}/output/primary_bene_id.dta, keep(3) nogen
	unique bene_id
	gen year = `year'
	if `year' == 2008 {
		format ndc %11.0f
		tostring(ndc), gen(ndc_str) format(%011.0f)
		rename ndc ndc_backup
		rename ndc_str ndc
	}	
	describe ndc
	replace ndc = substr(ndc,1,9)
	recast str9 ndc
	format ndc %9s
	describe ndc

	save ../temp/maxdata_ny_rx_prim_samp_`year'.dta, replace
	
	use ${rx}/tx/maxdata_tx_rx_`year'.dta, clear
	rename *, lower	
	merge m:1 bene_id using ${sample}/output/primary_bene_id.dta, keep(3) nogen
	unique bene_id
	gen year = `year'
	
	if `year' >= 2004 & `year' <= 2008 {
		count if strlen(ndc) == 12
		count if strlen(ndc) == 11
		tab ndc if strlen(ndc) == 12
		
		replace ndc = substr(ndc,2,.) if substr(ndc,1,1) == "0" & strlen(ndc) == 12
		replace ndc = substr(ndc,1,11) if substr(ndc,1,1) != "0" & strlen(ndc) == 12
		count if strlen(ndc) == 12
		count if strlen(ndc) == 11
		tab ndc if strlen(ndc) == 12
		
		recast str11 ndc
		format ndc %11s
		describe ndc
	}	
	
	replace ndc = substr(ndc,1,9)
	recast str9 ndc
	format ndc %9s
	describe ndc

	save ../temp/maxdata_tx_rx_prim_samp_`year'.dta, replace

}

clear
forvalues year = 2004/2010 {
	append using ../temp/maxdata_ny_rx_prim_samp_`year'.dta, force
	append using ../temp/maxdata_tx_rx_prim_samp_`year'.dta, force
}
save ../temp/rx_prim_samp.dta, replace
unique bene_id

gen elig_mo_yr_dif = el_elig_mo_yr - mofd(prscrptn_fill_dt)
tab elig_mo_yr_dif
keep if (elig_mo_yr_dif >= 1 & elig_mo_yr_dif <= 12)
unique bene_id

sort bene_id prscrptn_fill_dt

tab year 
tab year if ndc == ""

gen ndc_trim = strtrim(ndc)
rename ndc backup_ndc
rename ndc_trim ndc
bysort bene_id ndc: gen ndc_cnt = (_n == 1)

save ../output/rx_util.dta, replace

preserve
keep ndc
rename ndc ndc_base
bysort ndc_base: gen ndc_1st = (_n ==1)
keep if ndc_1st == 1
keep ndc_base
save ../temp/ndc_base_unique.dta, replace
restore

keep bene_id
bysort bene_id: gen first = (_n == 1)
keep if first == 1
drop first
unique bene_id

merge 1:1 bene_id using ${sample}/output/primary_bene_id.dta
rename bene_id bene_id_mcd
rename bene_id_mcr bene_id
drop _merge
save ../output/primary_bene_id_rx_util.dta, replace

end

******
cap program drop plan_fit
program plan_fit

use ${rx}/CombinedFormAll.dta, clear
gen state_cd = ""
replace state_cd = "NY" if state  == "New York"
replace state_cd = "TX" if state == "Texas"
tab state_cd
egen plan_cd = group(contract_id plan_id segment_id)
sort yr state_cd
gen ndc_trim = strtrim(ndc)
rename ndc backup_ndc
rename ndc_trim ndc
drop backup_ndc
replace ndc = substr(ndc,1,9)
recast str9 ndc
format ndc %9s
describe ndc

bysort plan_cd state_cd yr ndc: gen ndc_1st = (_n ==1)
keep if ndc_1st == 1
drop ndc_1st
 
save ../temp/CombinedFormAll.dta, replace

*Get Medicaid NCD that never appears in any Medicare formulary
preserve
keep ndc
rename ndc ndc_form_mcr
bysort ndc_form_mcr: gen ndc_1st = (_n ==1)
keep if ndc_1st == 1
keep ndc_form_mcr
save ../temp/ndc_form_mcr_unique.dta, replace

use ../temp/ndc_base_unique.dta, clear
cross using ../temp/ndc_form_mcr_unique.dta
save ../temp/ndc_base_form_cross.dta, replace
gen form_match_any = ndc_base == ndc_form_mcr
collapse (sum) form_match_any, by(ndc_base)
save ../output/ndc_base_form_match_any.dta, replace

use ../output/ndc_base_form_match_any.dta, clear
merge 1:1 ndc_base using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/partdpriceall_firsthalf.dta", keep(1 3) nogen
replace totalcst = 0 if totalcst == .
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/utilization_fit/output/ndc_base_form_match_any_wprice.dta", replace

restore

*Reshape formulary long to wide
use ../temp/CombinedFormAll.dta, clear
bysort yr plan_cd: gen ndc_cnt = _n
drop priorauth_or_step contract_id plan_id segment_id state 
reshape wide ndc, i(yr state_cd plan_cd) j(ndc_cnt)
sort yr state_cd
save ../temp/CombinedFormAll_ndc_wide.dta, replace

forvalues t = 2007/2010 {
	foreach x in NY TX {
		use ../temp/CombinedFormAll_ndc_wide.dta, clear
		keep if yr == `t' & state_cd == "`x'"
		drop yr state_cd
		save ../temp/CombinedFormAll_ndc_wide_`x'_`t'.dta, replace
}
}

use ../output/rx_util.dta, clear
unique bene_id if enrl_mo_yr_d != el_elig_mo_yr
gen enrl_yr_d = yofd(dofm(enrl_mo_yr_d))
keep if enrl_yr_d >= 2007 & enrl_yr_d <= 2010
keep if ndc_cnt == 1
unique bene_id
keep bene_id bene_id_mcr state_cd enrl_yr_d ndc
rename ndc ndc_base
rename enrl_yr_d yr
sort yr state_cd
save ../output/rx_util_ndc.dta, replace

forvalues t = 2007/2010 {
	foreach x in NY TX {
		use ../output/rx_util_ndc.dta, clear
		keep if yr == `t' & state_cd == "`x'"
		drop yr state_cd
		save ../temp/rx_util_ndc_`x'_`t'.dta, replace
}
}

forvalues t = 2007/2010 {
	foreach x in NY TX {
		use ../temp/rx_util_ndc_`x'_`t'.dta, clear
		merge m:1 ndc_base using ../output/ndc_base_form_match_any_wprice.dta
		drop if _merge == 2
		drop _merge
		tab form_match_any
		drop if form_match_any == 0
		bysort bene_id: egen ndc_sum = total(form_match_any)
		bysort bene_id: egen ndc_spendsum = total(totalcst)
		drop form_match_any
		save ../temp/rx_util_ndc_`x'_`t'_norm.dta, replace
		
		cross using ../temp/CombinedFormAll_ndc_wide_`x'_`t'.dta
		save ../temp/rx_util_ndc_fit_`x'_`t'.dta, replace
		
		gen ndc_match = 0
		forvalues i = 1/7243 {
			replace ndc_match = ndc_match + 1 if ndc_base == ndc`i'
		}
		gen ndc_match_pri = 0
		replace ndc_match_pri = totalcst if ndc_match == 1
		save ../temp/rx_util_ndc_fit_`x'_`t'.dta, replace

		keep bene_id bene_id_mcr plan_cd ndc_sum ndc_spendsum ndc_match ndc_match_pri
		bysort bene_id plan_cd: egen ndc_match_tot = total(ndc_match)
		bysort bene_id plan_cd: egen ndc_matchspend_tot = total(ndc_match_pri)
		gen ndc_nomatch = 1-ndc_match
		bysort bene_id plan_cd: egen ndc_nomatch_test = total(ndc_nomatch)
		gen ndc_nomatch_tot = ndc_sum - ndc_match_tot
		assert ndc_nomatch_test == ndc_nomatch_tot
		drop ndc_nomatch ndc_nomatch_test
		save ../temp/rx_util_ndc_fit_`x'_`t'_annot.dta, replace

		bysort bene_id plan_cd: gen plan_cnt = _n == 1
		keep if plan_cnt == 1
		
		gen ndc_match_sh = ndc_match_tot/ndc_sum
		gen ndc_matchspend_sh = ndc_matchspend_tot/ndc_spendsum
		bysort bene_id: egen avg_nomatch = mean(ndc_nomatch_tot)
		bysort bene_id: egen min_nomatch = min(ndc_nomatch_tot)
		bysort bene_id: egen avg_match_sh = mean(ndc_match_sh)
		bysort bene_id: egen max_match_sh = max(ndc_match_sh)
		
		bysort bene_id: egen avg_matchspend_sh = mean(ndc_matchspend_sh)
		bysort bene_id: egen max_matchspend_sh = max(ndc_matchspend_sh)
		
		drop plan_cnt
		
		generate u1 = runiform()
		sort bene_id ndc_matchspend_sh u1
		qby bene_id: gen spendobs = _N
		qby bene_id: gen spendperc = _n/_N

		sort bene_id ndc_match_sh u1
		qby bene_id: gen prescobs = _N
		qby bene_id: gen prescperc = _n/_N

		save ../temp/rx_util_ndc_fit_`x'_`t'_plan.dta, replace
		
		bysort bene_id: gen keep = _n == 1
		keep if keep == 1
		drop plan_cd ndc_match ndc_match_pri ndc_matchspend_tot prescobs prescperc spendobs spendperc ndc_match_tot ndc_nomatch_tot ndc_match_sh ndc_matchspend_sh keep
		rename bene_id bene_id_mcd
		rename bene_id_mcr bene_id
		save ../temp/rx_util_ndc_fit_`x'_`t'_bene.dta, replace	
		
}
}

clear
forvalues t = 2007/2010 {
	foreach x in NY TX {
	append using ../temp/rx_util_ndc_fit_`x'_`t'_bene.dta, force
}
}
unique bene_id
save ../output/rx_util_fit_bene.dta, replace

use ../output/rx_util_fit_bene.dta, clear
merge 1:1 bene_id using ../output/primary_bene_id_rx_util.dta
keep if _merge == 3
drop _merge

label variable ndc_sum "Baseline number of drugs"
label variable avg_nomatch "Avg(baseline drug with no match)"
label variable min_nomatch "Min(baseline drug with no match)"
label variable avg_match_sh "Avg(share of baseline drug with match)"
label variable max_match_sh "Max(share of baseline drug with match)"
label variable avg_matchspend_sh "Avg(share of baseline drug with match: by spending)"
label variable max_matchspend_sh "Max(share of baseline drug with match: by spending)"

unique bene_id
save ../output/rx_util_fit_bene.dta, replace


end

******
cap program drop elc_actv_match
program elc_actv_match

use ../output/rx_util_fit_bene.dta, clear
merge 1:1 bene_id using ${sample}/output/elc_actv_init, keep(3)
save ../output/rx_util_fit_elc_init.dta, replace


use ../output/rx_util_fit_bene.dta, clear
merge 1:1 bene_id using ${sample}/output/elc_actv_5yr, keep(3)
save ../output/rx_util_fit_elc_5yr.dta, replace


end

*******
*Execute

util_file_prep
elc_actv_match
log close
