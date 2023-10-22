*This file takes the NY-TX MCD-MCR linked sample, constructs Elixhauser scores based on the Medicaid record prior to Medicare enrollment, 
*and plots the active choice status of Medicare Part D plans by groups of Elixhauser scores.

*Final Products: 
*primary_bene_id.dta;
*primary_elc_elixhauser_5yr.dta;
*actv_elixhauser_5yr_connected.eps;
*actv_nytx_mcr_samp_5yr_connected

*for testing code interactively
cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/submission/code/"

clear all
set more off

adopath + ../../../../lib/ado/

global ip "../../../../raw/medicaid_ip/data"
global ot "../../../../raw/medicaid_ot/data"
global sample "../"

cap log close
log using ../output/nytx_elixhauser_fig_a1_a2.log, replace text

*Take NY-TX MCD-MCR matched data and create file of beneficiary IDs
cap program drop prim_samp_bene_id
program prim_samp_bene_id

use ${sample}/temp/prelim_merge_sample_mcd_dblt_noMCR_mcr_match_slct.dta, clear
gsort bene_id -_merge
by bene_id: carryforward bene_id_mcd el_dob el_elig_mo_yr el_sex_cd, replace
count if bene_id_mcd == ""

keep bene_id bene_id_mcd el_dob el_elig_mo_yr enrl_mo_yr_gen enrl_mo_yr_d enrl_mo_yr_nonhmo enrl_mo_yr_qual el_sex_cd

by bene_id: gen seq = _n
keep if seq == 1
drop seq

duplicates drop 
rename bene_id bene_id_mcr
rename bene_id_mcd bene_id
unique bene_id 

save ${sample}/output/primary_bene_id.dta, replace

end

*Get Medicaid claims record for beneficiaries in the sample, to be used for Elixhauser score calculation later
cap program drop diag_file_prep
program diag_file_prep

forvalues year = 2004/2010 {
	use ${ip}/ny/maxdata_ny_ip_`year'.dta, clear
	rename *, lower
	merge m:1 bene_id using ${sample}/output/primary_bene_id.dta, keep(3) nogen
	unique bene_id
	gen year = `year'
	gen pattype = 1
	save ../temp/maxdata_ny_ip_prim_samp_`year'.dta, replace
	
	use ${ip}/tx/maxdata_tx_ip_`year'.dta, clear
	rename *, lower	
	merge m:1 bene_id using ${sample}/output/primary_bene_id.dta, keep(3) nogen
	unique bene_id
	gen year = `year'
	gen pattype = 1	
	save ../temp/maxdata_tx_ip_prim_samp_`year'.dta, replace

	use ${ot}/ny/maxdata_ny_ot_`year'.dta, clear
	rename *, lower	
	merge m:1 bene_id using ${sample}/output/primary_bene_id.dta, keep(3) nogen
	tostring srvc_bgn_dt, gen(srvc_bgn_dt_str)
	rename srvc_bgn_dt srvc_bgn_dt_bckup
	gen srvc_bgn_dt = date(srvc_bgn_dt_str, "YMD")
	format srvc_bgn_dt %td
	unique bene_id
	gen year = `year'
	gen pattype = 2	
	save ../temp/maxdata_ny_ot_prim_samp_`year'.dta, replace

	use ${ot}/tx/maxdata_tx_ot_`year'.dta, clear
	rename *, lower	
	merge m:1 bene_id using ${sample}/output/primary_bene_id.dta, keep(3) nogen
	unique bene_id
	gen year = `year'
	gen pattype = 2	
	save ../temp/maxdata_tx_ot_prim_samp_`year'.dta, replace
}

clear
forvalues year = 2004/2010 {
	append using ../temp/maxdata_ny_ip_prim_samp_`year'.dta, force
	append using ../temp/maxdata_tx_ip_prim_samp_`year'.dta, force
	append using ../temp/maxdata_ny_ot_prim_samp_`year'.dta, force
	append using ../temp/maxdata_tx_ot_prim_samp_`year'.dta, force
}
save ../temp/maxdata_prim_samp.dta, replace
unique bene_id

gen elig_mo_yr_dif = el_elig_mo_yr - mofd(srvc_bgn_dt)
tab elig_mo_yr_dif
keep if (elig_mo_yr_dif >= 1 & elig_mo_yr_dif <= 12)
unique bene_id

sort bene_id srvc_bgn_dt

count if diag_cd_1 == ""
tab year if diag_cd_1 == ""
tab pattype if diag_cd_1 == ""
tab max_tos if diag_cd_1 == ""

forvalues i = 1/9 {
	gen diag_cd_`i'_trim = strtrim(diag_cd_`i')
	rename diag_cd_`i' backup_diag_cd_`i'
	rename diag_cd_`i'_trim diag_cd_`i'
}

keep bene_id diag_cd*

save ../output/max_diag.dta, replace

end

*Construct Elixhauser scores
program main

elixhauser diag_cd*, index(e) idvar(bene_id)
unique bene_id
save ../output/max_elixhauser.dta, replace

merge 1:1 bene_id using ${sample}/output/primary_bene_id.dta
replace elixsum = 0 if _merge == 2
rename bene_id bene_id_mcd
rename bene_id_mcr bene_id
drop _merge
save ../output/primary_bene_id_elixhauser.dta, replace

*Merge with active choice status
use ../output/primary_bene_id_elixhauser.dta, clear
merge 1:1 bene_id using ${sample}/output/elc_actv_5yr_upd.dta, keep(3)
save ../output/primary_elc_elixhauser_5yr.dta, replace

*Plot active choice propensity
cap rename chooser_init actv_0_0mth

gen elixgrp = elixsum
replace elixgrp = 4 if elixsum > 4 & elixsum != .
label define elixgrp_lab 0 "0" 1 "1" 2 "2" 3 "3" 4 "4+", replace
label values elixgrp elixgrp_lab
label variable elixgrp "Pre-65 Elixhauser Score"

keep bene_id elixgrp actv_0*

forvalues t = 0(12)60 {
	rename actv_0_`t'mth actv`t'
}
reshape long actv, i(bene_id) j(mth)

*Figure Appendix A2
*Plot active choice propensity for NY-TX MCD-MCR sample by group of Elixhauser score
preserve
collapse (mean) actv, by(elixgrp mth)

export delimited using ../output/tables/actv_elixhauser_5yr.csv, replace

twoway (connected actv mth if elixgrp == 0) (connected actv mth if elixgrp == 1) (connected actv mth if elixgrp == 2) (connected actv mth if elixgrp == 3) (connected actv mth if elixgrp == 4), graphregion(color(white)) legend (order(1 "0" 2 "1" 3 "2" 4 "3" 5 "4+") col(5)) title("Active Choice Propensity by Pre-65 Elixhauser Score") xla(0(12)60) xtitle("Months after Initial Enrollment") ytitle("Active Choice")
graph export ../output/graphs/actv_elixhauser_5yr_connected.eps, replace
restore 

*Figure Appendix A1
*Plot active choice propensity for full NY-TX MCD-MCR sample
preserve
collapse (mean) actv, by(mth)

export delimited using ../output/tables/actv_nytx_mcr_samp_5yr.csv, replace

twoway (connected actv mth), graphregion(color(white)) title("Active Choice Propensity") xla(0(12)60) xtitle("Months after Initial Enrollment") ytitle("Active Choice")
graph export ../output/graphs/actv_nytx_mcr_samp_5yr_connected.eps, replace
restore 

end

*****************
*Execute
prim_samp_bene_id
diag_file_prep
main        

log close
