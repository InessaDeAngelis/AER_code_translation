clear
capture log close
capture graph close
log using logs/17-figure_Y2.log, replace

import delimited using ../Matlab/output/temp/output_for_stata_figY2.csv, case(preserve) delim(",") varnames(1) clear

scatter first_best_Fixed_Effects first_best, msymbol(O) || function y=x, range(0.5 2.5) xsize(5) ysize(5) ///
ytitle(Fixed Effects Estimates for {&mu}{subscript:k} and {&sigma}{subscript:k}, size(med)) xtitle(Baseline  Estimates for {&mu}{subscript:k} and {&sigma}{subscript:k}, size(med)) legend(off) ///
lwidth(medthin) lpattern(dash) title(%{&Delta}W{subscript:1st best}, size(large)  position(12))

graph export "output/Figure_Y2_a.pdf", replace
 
 
 replace second_best_Fixed_Effects=second_best_Fixed_Effects/first_best_Fixed_Effects
 replace second_best=second_best/first_best
 
 replace third_best_Fixed_Effects=third_best_Fixed_Effects/first_best_Fixed_Effects
 replace third_best=third_best/first_best
 
scatter second_best_Fixed_Effects second_best, msymbol(Oh) || scatter third_best_Fixed_Effects third_best, msymbol(O) || function y=x, range(0 1) xsize(5) ysize(5) ///
ytitle(Fixed Effects Estimates for {&mu}{subscript:k} and {&sigma}{subscript:k}, size(med)) ///
xtitle(Baseline  Estimates for {&mu}{subscript:k} and {&sigma}{subscript:k} , size(med)) ///
lwidth(medthin) lpattern(dash) title({&Delta}W{subscript:2nd best} {&frasl} {&Delta}W{subscript:1st best}, size(large)  position(12)) ///
legend(pos(10) size(medium) ring(0) order(1 "All Trade Taxes" 2 "Only Import Taxes"))

graph export "output/Figure_Y2_b.pdf", replace

if "$delete_matlab_output" == "yes" {
 erase ../Matlab/output/temp/output_for_stata_figY2.csv
}
 graph close
 log close
 
 