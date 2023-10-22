clear
capture log close
capture graph close
log using logs/16-figure_Y1.log, replace

import delimited using ../Matlab/output/temp/output_for_stata_figY1.csv, case(preserve) delim(",") varnames(1) clear

scatter first_best_Melitz first_best, msymbol(O) || function y=x, range(0.5 3) xsize(5) ysize(5) ///
ytitle(Melitz-Pareto Model, size(med)) xtitle(Baseline Krugman Model , size(med)) legend(off) ///
lwidth(medthin) lpattern(dash) title(%{&Delta}W{subscript:1st best}, size(large)  position(12))

graph export "output/Figure_Y1_a.pdf", replace
 
 
 replace second_best_Melitz=second_best_Melitz/first_best_Melitz
 replace second_best=second_best/first_best
 
 replace third_best_Melitz=third_best_Melitz/first_best_Melitz
 replace third_best=third_best/first_best
 
scatter second_best_Melitz second_best, msymbol(Oh) || scatter third_best_Melitz third_best, msymbol(O) || function y=x, range(0 1) xsize(5) ysize(5) ///
ytitle(Melitz-Pareto Model, size(med)) xtitle(Baseline Krugman Model , size(med)) ///
lwidth(medthin) lpattern(dash) title({&Delta}W{subscript:2nd best} {&frasl} {&Delta}W{subscript:1st best}, size(large)  position(12)) ///
legend(pos(10) size(medium) ring(0) order(1 "All Trade Taxes" 2 "Only Import Taxes"))

graph export "output/Figure_Y1_b.pdf", replace
 
if "$delete_matlab_output" == "yes" { 
 erase ../Matlab/output/temp/output_for_stata_figY1.csv
}
 
 graph close
 log close
 