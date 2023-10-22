clear
capture log close
capture graph close
log using logs/5-figure_H2.log, replace

use dW_MPEC dW_Theory case using data/internally_generated/appendixH_simulation_all, clear

gen id = 1
replace id =  2 if dW_Theory > 1.0025*dW_MPEC
replace id =  3 if dW_MPEC > 1.0025*dW_Theory
gen frequency = 1 

collapse (sum) frequency, by(id case)
bysort case: egen total_freq = total(frequency)
replace frequency = frequency/total_freq
drop total_freq

reshape wide frequency, i(case) j(id)
forvalues i=1/3 {
replace frequency`i' = 0 if missing(frequency`i')
replace frequency`i' = 100*frequency`i'
}

gen     case_desc = "2 countries"   			if case==1
replace case_desc = "5 countries"      			if case==2
replace case_desc = "20 countries"     			if case==3

label variable frequency1   "Theorem 1 and MPEC have comparable accuracy"
label variable frequency2   "Theorem 1 is more accurate by at least 0.25%"
label variable frequency3   "MPEC is more accurate by at least 0.25%"

*graph set window fontface "Merriweather"
ds frequency*
local items : word count `r(varlist)'
display `item'
local colors = `items' + 1
colorpalette9    ///
 "250 150   0"  ///
 "  0  100  175"  ///
  , n(`colors') nograph
foreach x of numlist 1/`items' {
 

*** here the code for bar colors
 local barcolor `barcolor' bar(`x', fcolor("`r(p`x')'") ///
 lcolor(black) lwidth(*2)) `///' 
 
 
*** here the code for legend
 local mylab : var lab frequency`x'
 local legend `legend' lab(`x' "`mylab'") 
}

*** the final graph we want:
graph bar (mean) frequency*, ///
 over(case_desc, gap(*1.5) label(labsize(4)) axis(lcolor(none)) sort(case)) bargap(-15)  ///
  `barcolor' ///
  ytitle(% frequency, size(medlarge)) ///
  legend(`legend' col(1) size(medlarge) pos(6) ring(1) region(fcolor(none)) ) ///
  title("") xsize(2) ysize(1) //note("{fontface typewriter:Source: WBES}", size(3)) 
  
graph export "output/Figure_H2.pdf", replace

graph close
log close   
   