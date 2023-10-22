clear
capture log close
capture graph close
log using logs/15-figure_W2.log, replace

import delimited using ../Matlab/output/temp/output_for_stata_figW2.csv, case(preserve) delim(",") varnames(1) clear

label var dW "gains from unilateral markup correction"

replace Row ="Artificial parameters" if Row=="Artificial 1" | Row=="Artificial 2"
replace Row ="Estimated parameters" if Row=="Estimated"


graph bar dW,  scheme(burd9) xsize(4) ysize(4)  over(Row) ///
over(rho, sort(dW) gap(*1) relabel(1 "-0.65"  2 "-0.35" 3 "0.20") label(labsize(medium)))  ///
asyvars b1title("{it:Cov} ( {&mu}{sub:k} , {&sigma}{sub:k} )", size(medlarge)) ///
ytitle("%{&Delta}W (unilateral markup correction)", size(medlarge)) ///
bar(2, color("250 150 125")) nofill legen(order(2 1)) legend(size(*0.9))

graph export output/Figure_W2.pdf, replace

if "$delete_matlab_output" == "yes" {
 erase ../Matlab/output/temp/output_for_stata_figW2.csv
}
graph close
log close
