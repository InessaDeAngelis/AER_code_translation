clear 
capture log close
capture graph close

log using logs/2-figure_2.log, replace

import delimited using "../Matlab/output/temp/output_for_stata_fig2.csv", case(preserve) clear

rename Row iso

lab var iso "country code"
lab var dW_Cooperation "realized gains from shallow cooperation"
lab var dW_Coordination "prospective gains from deep cooperation"

drop if dW_Coordination<0
*-----------------------------  Plot Figure 1  ---------------------------------
graph hbar (asis)  dW_Cooperation dW_Coordination , ///
	over(iso, label(labsize(vsmall))) stack scheme(burd4) xsize(8) ysize(10) ///
	legend(rows(2) pos(6) bmargin(0) size(small) ///
	order(1 "% Gains from Shallow Cooperation ({it:realized})" ///
          2 "% Gains from Deep Cooperation ({it:unrealized})")) ///
	bar(2, color("250 150 125")) ylab(0(4)12) 

graph export output/Figure_2.pdf, replace

if "$delete_matlab_output" == "yes" {
 erase "../Matlab/output/temp/output_for_stata_fig2.csv"
}

graph close
log close
