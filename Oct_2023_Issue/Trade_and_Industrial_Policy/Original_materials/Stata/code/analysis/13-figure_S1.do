clear
capture log close
capture graph close
log using logs/13-figure_S1.log, replace

* load Penn World Table (year 2011)
use data/penn_world_tables/pwt90
keep if year==2011

gen ly= log(rgdpo/emp)
local US = ly[173]
replace ly = ly - `US'
lab var ly "Real GDP/pc relative to US (log)"

gen trade =0.5*( csh_x-  csh_m)
gen lambda_ii= 1 - trade
lab var lambda_ii "domestic expinditure share"

**** Preidcted Y/L: Krugman (1980) **************
gen ly_K= 0.36*log(emp) - 0.36*(lambda_ii) + log(ctfp)

local US = ly_K[173]
replace ly_K = ly_K - `US'
lab var ly_K "Real GDP/pc predicted by Krugman (log)"

****** Preidcted Y/L: Krugman (1980) + Domestic trade frictions *********

gen ly_DTF= 0.19*log(emp) - 0.36*(lambda_ii) + log(ctfp)

local US = ly_DTF[173]
replace ly_DTF = ly_DTF - `US'
lab var ly_DTF "Real GDP/pc predicted by Krugman + domestic trade frictions (log)"

**** ****** Preidcted Y/L: Krugman (1980) + Domestic trade frictions + estimated scale elasticity *********
gen ly_LL= 0.04*log(emp) - 0.36*(lambda_ii) + log(ctfp)

local US = ly_LL[173]
replace ly_LL = ly_LL - `US'
lab var ly_LL "Real GDP/pc predicted by Krugman + domestic trade frictions + estimated scale elasticity (log)"


gen lemp=log(emp)


graph twoway ///
(scatter ly_K lemp, mcolor($Cherry) msymbol(O)) (lfit ly_K lemp, lwidth(medthick) lpattern(dash) lcolor($Cherry ) ) ///
(scatter ly lemp if !missing(ly_K), mcolor($Blueberry ) msymbol(Sh)) (lfit ly lemp if !missing(ly_K), lwidth(medthick) lpattern(dash) lcolor($Blueberry )), ///
 xlabel(-2(2)6) xtitle("Population (log)") title(Standard Krugman Model) ///
legend(pos(4) col(1) size(medium) ring(0) order(1 "model prediction" 3 "data") ) 
graph export "output/Figure_S1_A.pdf", replace


graph twoway ///
(scatter ly_LL lemp, mcolor($TomaCherryto ) msymbol(O)) (lfit ly_LL lemp, lwidth(medthick) lpattern(dash)  lcolor($Cherry )) ///
(scatter ly lemp if !missing(ly_LL), mcolor($Blueberry ) msymbol(Sh)) (lfit ly lemp if !missing(ly_LL), lwidth(medthick) lpattern(dash) lcolor($Blueberry )), ///
xlabel(-2(2)6) xtitle("Population (log)")  title(Krugman Model + domestic trade frictions)  ///
legend(pos(4) col(1) size(medium) ring(0) order(1 "model prediction" 3 "data") ) 
graph export "output/Figure_S1_B.pdf", replace


graph twoway ///
(scatter ly_DTF lemp, mcolor($Cherry ) msymbol(O)) (lfit ly_DTF lemp, lwidth(medthick) lpattern(dash)  lcolor($Cherry )) ///
(scatter ly lemp if !missing(ly_DTF), mcolor($Blueberry ) msymbol(Sh)) (lfit ly lemp if !missing(ly_DTF), lwidth(medthick) lpattern(dash) lcolor($Blueberry )), ///
xlabel(-2(2)6) xtitle("Population (log)") title(Krugman Model + domestic trade frictions + estimated scale elasticity) ///
legend(pos(4) col(1) size(medium) ring(0) order(1 "model prediction" 3 "data") ) 
graph export "output/Figure_S1_C.pdf", replace

graph close
log close   
