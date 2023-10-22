*Code for figures 1b, appendix figure 25, on active choice as function of formulary fit-based on within person, relative fit. 

cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/submission/code/"


use ../temp/PreQuintileGraph.dta, clear
keep if prescperc ~= .
gen prescperccat = .
replace prescperccat = 5 if prescperc < .2
replace prescperccat = 4 if prescperc > .2 & prescperc < .4
replace prescperccat = 3 if prescperc > .4 & prescperc < .6
replace prescperccat = 2 if prescperc > .6 & prescperc < .8
replace prescperccat = 1 if prescperc > .8

*Non-spend weighted (Figure 1b)
collapse (mean) actv, by(prescperccat mth)
twoway (connected actv mth if prescperccat == 1) (connected actv mth if prescperccat == 2) (connected actv mth if prescperccat == 3) (connected actv mth if prescperccat == 4) (connected actv mth if prescperccat == 5), graphregion(color(white)) ///
	legend(order (1 "1st" 2 "2nd" 3 "3rd" 4 "4th" 5 "5th") col(4)) xtitle("Months after Initial Enrollment") ytitle("Active Choice") title("Active Choice Propensity by Quintile of Fit") 
graph export ../output/graphs/actv_default_withinfit_5yr_connect.eps, replace

use ../temp/PreQuintileGraph.dta, clear

keep if spendperc ~= .
gen spendperccat = .
replace spendperccat = 5 if spendperc < .2
replace spendperccat = 4 if spendperc > .2 & spendperc < .4
replace spendperccat = 3 if spendperc > .4 & spendperc < .6
replace spendperccat = 2 if spendperc > .6 & spendperc < .8
replace spendperccat = 1 if spendperc > .8

*Spend weighted (Appendix Figure 25)
collapse (mean) actv, by(spendperccat mth)
twoway (connected actv mth if spendperccat == 1) (connected actv mth if spendperccat == 2) (connected actv mth if spendperccat == 3) (connected actv mth if spendperccat == 4) (connected actv mth if spendperccat == 5), graphregion(color(white)) ///
	legend(order (1 "1st" 2 "2nd" 3 "3rd" 4 "4th" 5 "5th") col(4)) xtitle("Months after Initial Enrollment") ytitle("Active Choice") title("Active Choice Propensity by Quintile of Fit: Spend-Based") 
graph export ../output/graphs/actv_default_withinfit_5yr_connect_spendbased.eps, replace


