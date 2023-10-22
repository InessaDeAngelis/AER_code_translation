clear 
capture log close
capture graph close
log using logs/3-figure_3.log, replace

*graph set window fontface "Merriweather light"

import delimited using "../Matlab/output/temp/output_for_stata_fig3.csv", case(preserve) clear

lab var first_best_RE "gains from the unilaterally first-best policy (restricted entry)"
lab var cooperative_RE "gains from optimal cooperative policy (restricted entry)"
lab var first_best_FE "gains from the unilaterally first-best policy (free entry)"
lab var cooperative_FE "gains from optimal cooperative policy (free entry)"

*--------- trim data: drop outliers ------------
egen UB_first_best = pctile(first_best_RE), p(95)
egen LB_first_best = pctile(first_best_RE), p(5)
egen UB_coop = pctile(cooperative_RE), p(95)
egen LB_coop = pctile(cooperative_RE), p(5)
drop if cooperative_RE<LB_coop | first_best_RE<LB_first_best ///
	  | cooperative_RE>UB_coop | first_best_RE>UB_first_best 


*--------- plot figure 3 (left panel) ----------
scatter first_best_RE cooperative_RE, mlab(iso) m(O) mlabsize(*0.85) ///
		mc("135 206 235") mlc("70 130 180") mlabcolor("34 34 34")  ///
		|| function y=x, range(0 3.5) xsize(5) ysize(5) xlab(0(1)3.5) ///
		ylab(0(1)3.5) legend(off) ytitle("Maximal Gains from Unilateral Policy", size(medsmall)) ///
		xtitle("Prospective Gains from Deep Cooperation", size(medsmall)) ///
		lwidth(medthick) lcolor("255 139 142") lpattern(dash) ///
		title("Restricted Entry", size(large)  position(12)) // title("{fontface Merriweather Bold:Restricted Entry}"

graph export "output/Figure_3A.pdf", replace
graph close

*--------- plot figure 3 (right panel) ----------
import delimited using "../Matlab/output/temp/output_for_stata_fig3.csv", case(preserve) clear

egen UB_first_best = pctile(first_best_FE), p(95)
egen LB_first_best = pctile(first_best_FE), p(5)
egen UB_coop = pctile(cooperative_FE), p(95)
egen LB_coop = pctile(cooperative_FE), p(5)
drop if cooperative_FE<LB_coop | first_best_FE<LB_first_best ///
	  | cooperative_FE>UB_coop | first_best_FE>UB_first_best 

scatter first_best_FE cooperative_FE, mlab(iso) m(O) mlabsize(*0.85) ///
		mc("135 206 235") mlc("70 130 180") mlabcolor("34 34 34") ///
		|| function y=x, range(0 8) xsize(5) ysize(5) xlab(0(2)8) ///
		ylab(0(2)8) legend(off) ytitle("", size(medsmall)) ///
		xtitle("Prospective Gains from Deep Cooperation", size(medsmall)) ///
		lwidth(medthick) lcolor("255 139 142") lpattern(dash) ///
		title("Free Entry", size(large)  position(12)) // title("{fontface Merriweather Bold:Free Entry}"

graph export "output/Figure_3B.pdf", replace
graph close

if "$delete_matlab_output" == "yes" {
erase "../Matlab/output/temp/output_for_stata_fig3.csv"
}

log close
