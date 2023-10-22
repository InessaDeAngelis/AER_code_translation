clear
capture log close
capture graph close
log using logs/9-figure_P1.log, replace

if "$access_to_datamyne" == "yes" {
*************** Perform Robustness Checks *********************
do code/data_prep/4-robustness_check_1 // build IV using initial shares
do code/data_prep/5-robustness_check_2 // exclude excessively large firms
do code/data_prep/6-robustness_check_3 // control for exchange rate

*************** Figure 9: Top Pannel *********************
}



use data/internally_generated/figP1_initial_share_iv
merge 1:1 id using data/temp/baseline_estimates

scatter theta theta_base, msymbol(O) mcolor(k) || function y=x, range(0 8) xsize(5) ysize(5) ///
ytitle(Alternative Estimation, size(med)) xtitle(Baseline Estimation , size(med)) legend(off) ///
lwidth(medthin) lcolor(red) lpattern(dash) title({&sigma}{subscript:k}-1, size(huge)  position(12)) saving(output/temp/figP1_A, replace)
*graph export output/temp/figP1_11.png, replace

scatter psi psi_base, msymbol(O) mcolor(k) xscale(log) yscale(log) || function y=x,  range(0.1 2) xsize(5) ysize(5) xscale(log) yscale(log) ///
ytitle(Alternative Estimation, size(med)) xtitle(Baseline Estimation , size(med)) legend(off) ///
lwidth(medthin) lcolor(red) lpattern(dash) title({&mu}{subscript:k}, size(huge)  position(12)) saving(output/temp/figP1_B, replace)
*graph export output/temp/figP1_12.png, replace

graph combine output/temp/figP1_A.gph output/temp/figP1_B.gph, r(1) c(2) title("Constructing IV using 4th Lags ", size(large) position(12)) xsize(8) ysize(4)
graph export "output/Figure_P1_A.pdf", replace

*************** Figure 9: Middle Pannel *********************
 use data/internally_generated/figP1_large_firms, clear
merge 1:1 id using data/temp/baseline_estimates

scatter theta theta_base, msymbol(O) mcolor(k) || function y=x, range(0 8) xsize(5) ysize(5) ///
ytitle(Alternative Estimation, size(med)) xtitle(Baseline Estimation , size(med)) legend(off) ///
lwidth(medthin) lcolor(red) lpattern(dash) title({&sigma}{subscript:k}-1, size(huge)  position(12)) saving(output/temp/figP1_A, replace)
*graph export output/temp/figP1_21.png, replace


scatter psi psi_base, msymbol(O) mcolor(k) xscale(log) yscale(log) || function y=x,  range(0.1 2) xsize(5) ysize(5) xscale(log) yscale(log) ///
ytitle(Alternative Estimation, size(med)) xtitle(Baseline Estimation , size(med)) legend(off) ///
lwidth(medthin) lcolor(red) lpattern(dash) title({&mu}{subscript:k}, size(huge)  position(12)) saving(output/temp/figP1_B, replace)
*graph export output/temp/figP1_22.png, replace

graph combine output/temp/figP1_A.gph output/temp/figP1_B.gph, r(1) c(2) title("Controlling for Changes in Annual Exchange Rate", size(large) position(12)) xsize(8) ysize(4)
graph export "output/Figure_P1_B.pdf", replace

*************** Figure 9: Bottom Pannel *********************
use data/internally_generated/figP1_exc_rate_control, clear
merge 1:1 id using data/temp/baseline_estimates

scatter theta theta_base, msymbol(O) mcolor(k) || function y=x, range(0 8) xsize(5) ysize(5) ///
ytitle(Alternative Estimation, size(med)) xtitle(Baseline Estimation , size(med)) legend(off) ///
lwidth(medthin) lcolor(red) lpattern(dash) title({&sigma}{subscript:k}-1, size(huge)  position(12)) saving(output/temp/figP1_A, replace)
*graph export output/temp/figP1_31.png, replace


scatter psi psi_base, msymbol(O) mcolor(k) xscale(log) yscale(log) || function y=x,  range(0.1 2) xsize(5) ysize(5) xscale(log) yscale(log) ///
ytitle(Alternative Estimation, size(med)) xtitle(Baseline Estimation , size(med))  legend(off) ///
lwidth(medthin) lcolor(red) lpattern(dash) title({&mu}{subscript:k}, size(huge)  position(12)) saving(output/temp/figP1_B, replace)
*graph export output/temp/figP1_32.png, replace

graph combine output/temp/figP1_A.gph output/temp/figP1_B.gph, r(1) c(2) title("Dropping Large Mullti-Product Firms", size(large) position(12)) xsize(8) ysize(4)
graph export "output/Figure_P1_C.pdf", replace


erase output/temp/figP1_A.gph
erase output/temp/figP1_B.gph
erase data/temp/baseline_estimates.dta
*erase data/internally_generated/figP1_initial_share_iv
*erase data/internally_generated/fig9_exc_rate_control
*erase data/internally_generated/fig9_large_firms

graph close
log close



 
