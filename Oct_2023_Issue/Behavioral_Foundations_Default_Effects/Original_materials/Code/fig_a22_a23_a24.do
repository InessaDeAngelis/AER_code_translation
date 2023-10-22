
*Code for appendix Figures A22-A24:

cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/submission/code/"


use ../output/rx_util_fit_elc_5yr.dta, clear

gen max_avg_sh_dif = max_match_sh - avg_match_sh
label variable max_avg_sh_dif "Max - Avg Match Rate"

gen max_avg_shspend_dif = max_matchspend_sh - avg_matchspend_sh
label variable max_avg_shspend_dif "Max - Avg Match Rate: Spend Based"

*Appendix A22, A23 
foreach x in  avg_matchspend_sh max_avg_shspend_dif {
	sum `x', det
	hist `x', fraction graphregion(color(white))
	graph export "../output/graphs/`x'.eps", replace
}



cap rename chooser_init actv_0_0mth

sum max_avg_shspend_dif, det
gen max_avg_shspend_dif_grp = (max_avg_shspend_dif >= 0 & max_avg_shspend_dif < 0.1)
replace max_avg_shspend_dif_grp = 2 if (max_avg_shspend_dif >= 0.1 & max_avg_shspend_dif < 0.2)
replace max_avg_shspend_dif_grp = 3 if (max_avg_shspend_dif >= 0.2 & max_avg_shspend_dif < 0.3)
replace max_avg_shspend_dif_grp = 4 if (max_avg_shspend_dif >= 0.3 & max_avg_shspend_dif != .)
label define max_avg_shspend_dif_lab 1 "0-0.1" 2 "0.1-0.2" 3 "0.2-0.3" 4 "0.3+", replace
label values max_avg_shspend_dif_grp max_avg_shspend_dif_lab
tab max_avg_shspend_dif_grp

keep bene_id ndc_sum_grp max_match_sh_grp avg_match_sh_grp max_avg_sh_dif_grp actv_0* max_matchspend_sh_grp avg_matchspend_sh_grp  max_avg_shspend_dif_grp

forvalues t = 0(12)60 {
	rename actv_0_`t'mth actv`t'
}

reshape long actv, i(bene_id) j(mth)


preserve
*Appendix Figure A24
collapse (mean) actv, by(max_avg_shspend_dif_grp mth)
twoway (connected actv mth if max_avg_shspend_dif_grp == 1) (connected actv mth if max_avg_shspend_dif_grp == 2) (connected actv mth if max_avg_shspend_dif_grp == 3) (connected actv mth if max_avg_shspend_dif_grp == 4), graphregion(color(white)) ///
	legend(order (1 "0-0.1" 2 "0.1-0.2" 3 "0.2-0.3" 4 "0.3+") col(4)) xtitle("Months after Initial Enrollment") ytitle("Active Choice") title("Active Choice Prop. by Max - Avg Match Rate by Spend") 
graph export ../output/graphs/actv_max_avg_matchspend_dif_5yr_connect.eps, replace


