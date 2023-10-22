*This file constructs graphs of plan fit for the Medicaid-linked sample
*Final products: 

*avg_match_sh.eps;
*max_avg_sh_dif.eps;
*actv_ndcsum_5yr_connect.eps;
*actv_max_avg_match_dif_5yr_connect.eps

*Corresponds to figures a3, a19, a20, a21 in the appendix

*for testing code interactively
cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/submission/code/"

clear all
set more off
set maxvar 20000

adopath + ../../../../lib/ado/

global rx "../../../../raw/medicaid_rx/data"
global sample "../"

cap log close
log using ../output/utilization_fit_fig_a3_a17_a18_a19.log, replace text

*Get baseline prescription drug utilization from Medicaid claims
cap program drop util_file_prep

******
*Plot histograms of fit measures and active choice status by baseline drug utilization and plan fit

cap program drop elc_actv_match_simp

program elc_actv_match_simp

*Merge with active choice status

use ../output/rx_util_fit_bene.dta, clear
merge 1:1 bene_id using ${sample}/output/elc_actv_init, keep(3)
cap drop _merge

merge 1:1 bene_id using ${sample}/output/elc_actv_5yr_upd, keep(3)
save ../output/rx_util_fit_elc_5yr.dta, replace

use ../output/rx_util_fit_elc_5yr.dta, clear

gen max_avg_sh_dif = max_match_sh - avg_match_sh
label variable max_avg_sh_dif "Max - Avg Match Rate"

*Plot histogram of fit measures
*Figure A19, A20
foreach x in avg_match_sh max_avg_sh_dif {
	sum `x', det
	hist `x', fraction graphregion(color(white))
	graph export "../output/graphs/`x'.eps", replace
}

*Plot active choice status by baseline drug utilization and fit of Medicare Part D plans

cap rename chooser_init actv_0_0mth

sum ndc_sum, det
gen ndc_sum_grp = (ndc_sum >= 1 & ndc_sum <= 4)
replace ndc_sum_grp = 2 if (ndc_sum >= 5 & ndc_sum <= 8)
replace ndc_sum_grp = 3 if (ndc_sum >= 9 & ndc_sum <= 12)
replace ndc_sum_grp = 4 if (ndc_sum >= 13 & ndc_sum != .)
tab ndc_sum_grp
label define ndc_sum_lab 1 "1-4" 2 "5-8" 3 "9-12" 4 "13+", replace
label values ndc_sum_grp ndc_sum_lab
tab ndc_sum_grp

sum max_avg_sh_dif, det
gen max_avg_sh_dif_grp = (max_avg_sh_dif >= 0 & max_avg_sh_dif < 0.1)
replace max_avg_sh_dif_grp = 2 if (max_avg_sh_dif >= 0.1 & max_avg_sh_dif < 0.2)
replace max_avg_sh_dif_grp = 3 if (max_avg_sh_dif >= 0.2 & max_avg_sh_dif < 0.3)
replace max_avg_sh_dif_grp = 4 if (max_avg_sh_dif >= 0.3 & max_avg_sh_dif != .)
label define max_avg_sh_dif_lab 1 "0-0.1" 2 "0.1-0.2" 3 "0.2-0.3" 4 "0.3+", replace
label values max_avg_sh_dif_grp max_avg_sh_dif_lab
tab max_avg_sh_dif_grp

keep bene_id ndc_sum_grp max_avg_sh_dif_grp actv_0*

forvalues t = 0(12)60 {
	rename actv_0_`t'mth actv`t'
}

reshape long actv, i(bene_id) j(mth)

*Figure A3
preserve
collapse (mean) actv, by(ndc_sum_grp mth)
twoway (connected actv mth if ndc_sum_grp == 1) (connected actv mth if ndc_sum_grp == 2) (connected actv mth if ndc_sum_grp == 3) (connected actv mth if ndc_sum_grp == 4), graphregion(color(white)) ///
	legend(order (1 "1-4" 2 "5-8" 3 "9-12" 4 "13+") col(4)) xtitle("Months after Initial Enrollment") ytitle("Active Choice") title("Active Choice Propensity by Baseline # of Drugs") 
graph export ../output/graphs/actv_ndcsum_5yr_connect.eps, replace
restore

*Figure A21
preserve
collapse (mean) actv, by(max_avg_sh_dif_grp mth)
twoway (connected actv mth if max_avg_sh_dif_grp == 1) (connected actv mth if max_avg_sh_dif_grp == 2) (connected actv mth if max_avg_sh_dif_grp == 3) (connected actv mth if max_avg_sh_dif_grp == 4), graphregion(color(white)) ///
	legend(order (1 "0-0.1" 2 "0.1-0.2" 3 "0.2-0.3" 4 "0.3+") col(4)) xtitle("Months after Initial Enrollment") ytitle("Active Choice") title("Active Choice Propensity by Max - Avg Match Rate") 
graph export ../output/graphs/actv_max_avg_match_dif_5yr_connect.eps, replace
restore

end


******
*Execute

elc_actv_match_simp

log close
