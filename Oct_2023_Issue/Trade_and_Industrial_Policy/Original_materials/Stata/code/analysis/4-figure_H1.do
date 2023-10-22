clear
capture log close
capture graph close
log using logs/4-figure_H1.log, replace

import delimited using data/internally_generated/appendixH_simulation_2x10.csv, case(preserve) clear
gen case = 1
tempfile Output_2x10
save `Output_2x10'

import delimited using data/internally_generated/appendixH_simulation_5x10.csv, case(preserve) clear
gen case = 2
tempfile Output_5x10
save `Output_5x10'

import delimited using data/internally_generated/appendixH_simulation_20x10.csv, case(preserve) clear
gen case = 3
tempfile Output_20x10
save `Output_20x10'

use `Output_2x10', clear
append using `Output_5x10'
append using `Output_20x10'

keep if dW_Theory>1 & dW_MPEC>1
save data/internally_generated/appendixH_simulation_all, replace

*graph set window fontface "Merriweather Bold"
graph twoway ///
 (scatter dW_Theory dW_MPEC if case==1, msize(medlarge))  (scatter dW_Theory dW_MPEC if case==2, msize(medlarge)) ///
 (scatter dW_Theory dW_MPEC if case==3, msize(medlarge))   (function y=x, range(5 15) lpattern(dash)) , ///
 ytitle(Theorem 1 ( %{&Delta}W{subscript:i} )) xtitle(Numerical Optimization ( %{&Delta}W{subscript:i} ) ) ///
 ylabel(5(2)15) yscale(log) xsize(5) ysize(5) ///
 xlabel(5(2)15) xscale(log) ///
 legend(pos(10) col(1) size(medium) ring(0) lab(1 "2 Countries") lab(2 "5 countries") lab(3 "20 countries") lab(4 "45-degree line") )
 
*note({fontface Arial Narrow: Abel used as the default font for the graphs. Arial Narrow used for notes.}, span size(*0.65)) xsize(5) ysize(5) ///

 graph export "output/Figure_H1.pdf", replace
 graph close
 log close
