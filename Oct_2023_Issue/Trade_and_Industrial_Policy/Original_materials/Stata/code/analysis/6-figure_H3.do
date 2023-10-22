clear
capture log close
capture graph close
log using logs/6-figure_H3.log, replace

use RunTime_MPEC RunTime_Theory case using data/internally_generated/appendixH_simulation_all, clear

collapse (mean) RunTime*, by(case)

gen     case_desc = "2 countries"   			if case==1
replace case_desc = "5 countries"      			if case==2
replace case_desc = "20 countries"     			if case==3

rename RunTime_Theory RunTime1
rename RunTime_MPEC RunTime2

label variable RunTime1 "Theorem 1"
label variable RunTime2   "Numerical Optimization (FMINCON)"

*graph set window fontface "Merriweather"
ds RunTime*
local items : word count `r(varlist)'
display `item'
local colors = `items' + 1
colorpalette9    ///
 "130  192  233"  ///
 "  0  100  175"  ///
  , n(`colors') nograph
foreach x of numlist 1/`items' {
 

*** here the code for bar colors
 local barcolor `barcolor' bar(`x', fcolor("`r(p`x')'") ///
 lcolor(black) lwidth(*1)) `///' 
 
 
*** here the code for legend
 local mylab : var lab RunTime`x'
 local legend `legend' lab(`x' "`mylab'")
}

gen RunTime = 100*(RunTime2/RunTime1)
*** the final graph we want:
graph bar (mean) RunTime, ///
 over(case_desc, gap(*1.5) label(labsize(4)) axis(lcolor(none)) sort(case)) bargap(-15)  ///
  `barcolor' ///
  ytitle(% gains in computation speed, size(medlarge)) ///
  legend(`legend' col(1) size(medium) pos(12) ring(1) region(fcolor(none)) ) ///
  title("") xsize(2) ysize(1) //note("{fontface typewriter:Source: WBES}", size(3)) 
  
graph export "output/Figure_H3.pdf", replace   


graph close
erase data/internally_generated/appendixH_simulation_all.dta
capture erase data/internally_generated/appendixH_simulation_2x10_s.csv
capture erase data/internally_generated/appendixH_simulation_5x10_s.csv
capture erase data/internally_generated/appendixH_simulation_20x10_s.csv
log close   
