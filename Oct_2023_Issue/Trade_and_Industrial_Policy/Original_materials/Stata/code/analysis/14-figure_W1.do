clear
capture log close
capture graph close
log using logs/14-figure_W1.log, replace

import delimited using ../Matlab/output/temp/output_for_stata_figW1.csv, case(preserve) delim(",") varnames(1) clear

label var second_best "gains from 2nd-best policies relative to the 1st best"

replace Row ="Artificial parameters" if Row=="Artificial 1" | Row=="Artificial 2"
replace Row ="Estimated parameters" if Row=="Estimated"


*graph set window fontface "Merriweather Light"

graph bar second_best,  scheme(burd9) xsize(4) ysize(4)  over(Row) ///
over(rho, sort(second_best) gap(*1) relabel(1 "-0.65"  2 "-0.35" 3 "0.20") label(labsize(medium)))  ///
asyvars b1title("{it:Cov} ( {&mu}{sub:k} , {&sigma}{sub:k} )", size(medlarge)) ///
ytitle("Efficacy of 2nd-Best Trade Taxes", size(medlarge)) ///  ytitle("{&Delta}W{sup:2nd-best} {&frasl} {&Delta}W{sup:1st-best}", size(medlarge)) 
bar(2, color("250 150 125")) nofill legend(order(2 1)) legend(size(*0.9))

graph export output/Figure_W1.pdf, replace

if "$delete_matlab_output" == "yes" {
 erase ../Matlab/output/temp/output_for_stata_figW1.csv
}

graph close
log close
