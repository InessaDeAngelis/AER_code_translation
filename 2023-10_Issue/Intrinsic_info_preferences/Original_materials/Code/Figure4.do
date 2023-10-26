use  "$root/Data/Output/alzheimer.dta", clear
 
 
gen avoid = (exact_learn == 0)
gen navoid = (exact_learn == 1)

tab no_switching
** Figure 4 footnote: in depicting these inverse demand curves, we exclude 9% of the sample who had more than a single crossing in the price list used to elicit willingness to pay
keep if no_switching == 1 

preserve
keep if avoid == 1

keep *paid* *pay*  

foreach yy in risk safe exact{
rename `yy'_paid* `yy'1*
rename `yy'_pay* `yy'9*
}


collapse risk*  safe* exact* 
gen wtp=999
reshape long risk safe exact , i(wtp)  j(cond)

* Graph Demand Curves for WTP

replace wtp = -50 if cond==150
replace wtp = -25 if cond==125
replace wtp = -15 if cond==115
replace wtp = -10 if cond==110
replace wtp = -5 if cond==15
replace wtp = 0 if cond==90
replace wtp = 5 if cond==95
replace wtp = 10 if cond==910
replace wtp = 15 if cond==915
replace wtp = 25 if cond==925
replace wtp = 50 if cond==950

sort wtp

label var exact "Most Informative"
label var risk "Negatively Skewed"
label var safe "Positively Skewed"


twoway 	(line exact wtp, connect(stairstep) lcolor(gs0) lpattern(dash) lwidth(medthick))    (line risk wtp, connect(stairstep) lcolor(orange) lpattern(longdash dot) lwidth(medthick)) (line safe wtp, connect(stairstep) lcolor(midblue) lwidth(medthick)),  ytitle("") ytitle(, size(medsmall) margin(medsmall)) ylabel(, labsize(small))  xtitle(Amount ($)) xtitle(, size(medsmall) margin(medsmall)) xlabel(#11, labsize(small)) graphregion(color(white)) title("(B) Avoiders", size(medsmall)) legend(size(small) rows(1) order(1 "Most Informative" 2 "Negatively Skewed" 3 "Positively Skewed"))   saving("avoid.gph", replace)

*legend(region(lcolor(none) )   ring(0) position(2) bmargin(tiny) col(1) subtitle("  ") ) 
 
restore



preserve
keep if navoid == 1
keep if no_switching == 1

keep *paid* *pay*  

foreach yy in risk safe exact{
rename `yy'_paid* `yy'1*
rename `yy'_pay* `yy'9*
}


collapse risk*  safe* exact* 
gen wtp=999
reshape long risk safe exact , i(wtp)  j(cond)

* Graph Demand Curves for WTP

replace wtp = -50 if cond==150
replace wtp = -25 if cond==125
replace wtp = -15 if cond==115
replace wtp = -10 if cond==110
replace wtp = -5 if cond==15
replace wtp = 0 if cond==90
replace wtp = 5 if cond==95
replace wtp = 10 if cond==910
replace wtp = 15 if cond==915
replace wtp = 25 if cond==925
replace wtp = 50 if cond==950

sort wtp


twoway 	(line exact wtp, connect(stairstep) lcolor(gs0) lpattern(dash) lwidth(medthick))    (line risk wtp, connect(stairstep) lcolor(orange) lpattern(longdash dot) lwidth(medthick)) (line safe wtp, connect(stairstep) lcolor(midblue) lwidth(medthick)),  ytitle("") ytitle(, size(medsmall) margin(medsmall)) ylabel(, labsize(small))  xtitle(Amount ($)) xtitle(, size(medsmall) margin(medsmall)) xlabel(#11, labsize(small)) graphregion(color(white)) title("(A) Takers", size(medsmall)) legend(size(small) rows(1) order(1 "Most Informative" 2 "Negatively Skewed" 3 "Positively Skewed"))   saving("navoid.gph", replace)


restore

grc1leg  "navoid" "avoid" , imargin(.4) graphregion(color(white)) col(2) 
  
*graph combine  "navoid" "avoid" , imargin(0 2 0 0) graphregion(color(white)) 
graph export "Fig4.pdf", replace
 rm "navoid.gph"
 rm"avoid.gph"
  
 
