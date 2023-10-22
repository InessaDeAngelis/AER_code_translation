 
use "$root/Data/Output/Exp1.dta", clear

**FIGURE 3  


gen infot50 = infoprem >50
gen infot40 = infoprem >40
gen infot35 = infoprem >35
gen infot30 = infoprem >30
gen infot25 = infoprem >25
gen infot20 = infoprem >20
gen infot15 = infoprem >15
gen infot10 = infoprem >10
gen infot5 = infoprem >5
gen infot1 = infoprem >1
gen infot0 = infoprem >0
gen infot90 = infoprem > -1
gen infot91 = infoprem > -1.2
gen infot95 = infoprem > -5.2
gen infot910 = infoprem >-10.2
gen infot915 = infoprem >-15.2
gen infot920 = infoprem >-20.2
gen infot925 = infoprem >-25.2
gen infot930 = infoprem >-30.2
gen infot935 = infoprem >-35.2
gen infot940 = infoprem >-40.2
gen infot950 = infoprem > -50.2

collapse infot*  , by(treatment)

reshape long infot, i(treatment)  j(wtp) 

foreach x in 0 1 5 10 15 20 25 30 35 40 50{
	replace wtp = `x'.1 if wtp==`x'
	replace wtp = -`x'.1 if wtp==9`x'
}

reshape wide  infot , i(wtp) j(treatment)
  
label var infot1  "Full"
label var infot9  "Symmetric Partial"
label var infot7  "Negatively Skewed"
label var infot5  "Positively Skewed"
label var infot10  "Symmetric Partial"
label var infot8  "Positively Skewed"
label var infot6  "Negatively Skewed"

twoway 	(line infot1 wtp, connect(stairstep) lcolor(gs0) lpattern(dash) lwidth(medthick)) (line infot9 wtp, connect(stairstep) lcolor(gray) lpattern(dash_dot) lwidth(medthick))  (line infot7 wtp, connect(stairstep) lcolor(orange) lpattern(longdash dot) lwidth(medthick)) (line infot5 wtp, connect(stairstep) lcolor(midblue) lpattern(solid) lwidth(medthick)) , ytitle("") ytitle(, size(medsmall) margin(medsmall)) ylabel(, labsize(small))  xtitle(Amount ($)) yscale(r(0 1)) xtitle(, size(medsmall) margin(medsmall)) xlabel(#11, labsize(small)) graphregion(color(white))    title("(A) T1, T5, T7, T9", size(medsmall))    saving("1A.gph", replace)

twoway 	(line infot1 wtp, connect(stairstep) lcolor(gs0) lpattern(dash) lwidth(medthick)) (line infot10 wtp, connect(stairstep) lcolor(gray) lpattern(dash_dot) lwidth(medthick))  (line infot8 wtp, connect(stairstep) lcolor(orange) lpattern(longdash dot) lwidth(medthick))  (line infot6 wtp, connect(stairstep) lcolor(midblue) lpattern(solid) lwidth(medthick)) , ytitle("") ytitle(, size(medsmall) margin(medsmall)) ylabel(, labsize(small))  yscale(r(0 1)) xtitle(Amount ($)) xtitle(, size(medsmall) margin(medsmall)) xlabel(#11, labsize(small)) graphregion(color(white))  title("(A) T1, T6, T8, T10", size(medsmall))     saving("1B.gph", replace)
*legend(region(lstyle(none)))
*graph combine "1A" "1B" , imargin(0 2 0 0) graphregion(color(white)) 
grc1leg  "1A" "1B" , imargin(.4)  graphregion(color(white)) col(2)  
graph export "Fig3.pdf", replace
 
  
rm  "1A.gph" 
rm "1B.gph"
