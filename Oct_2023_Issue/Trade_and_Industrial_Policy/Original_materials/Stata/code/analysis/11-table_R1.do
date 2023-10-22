clear
capture log close
capture graph close
log using logs/11-figure_R1.log, replace

if "$access_to_edd" == "yes" {
use id psi using data/internally_generated/table3_estimates
rename psi mu
drop if missing(id)
tempfile markup
save `markup'

use id theta using data/internally_generated/table3_estimates
rename theta sigma
drop if missing(id)
merge 1:1 id using `markup'
drop _m
tempfile estimation_results
save `estimation_results'

use "data/confidential_data/edd_worldbank/CYH6_manuf.dta", clear

keep A1 A6i y h6 c
gen Ni = A1
gen Xi = A1*A6i
drop A1
rename c country
rename y year
rename h6 hs6
destring hs6, force replace

merge m:1 hs6 using data/concordance/isic_hs6
drop if _m == 2

gen id = 0
replace id=1 if isic>=100 & isic<1500
replace id=2 if isic>=1500 & isic<1700
replace id=3 if isic>=1700 & isic<2000
replace id=4 if isic>=2000 & isic<2100
replace id=5 if isic>=2100 & isic<2300
replace id=7 if isic>=2400 & isic<2500
replace id=9 if isic>=2600 & isic<2700
replace id=10 if isic>=2700 & isic<2900
replace id=11 if isic>=2900 & isic<3100
replace id=12 if isic>=3100 & isic<3400
replace id=13 if isic>=3400 & isic<3600
replace id=14 if isic>=3600 & isic<3800
replace id=14 if id==0

collapse (mean) Ni [w=Xi], by(country year id)

winsor2 Ni , by(id year) trim cuts(5 95) replace

merge m:1 id using `estimation_results'
keep if _m==3

gen ln_sigma = log(sigma-1)
gen ln_mu = log((1/Ni)*(1+mu))
gen ln_mu_baseline = log((1+mu))

keep if year>=2007 & year<=2013

reg ln_sigma ln_mu
gen b1 = _b[ln_mu]
gen b1_se = _se[ln_mu]
gen obsv_1 = e(N) 

reghdfe ln_sigma ln_mu, a(year) 
gen b2 = _b[ln_mu]
gen b2_se = _se[ln_mu]
gen obsv_2 = e(N) 

reghdfe ln_sigma ln_mu, a(year country)
gen b3 = _b[ln_mu]
gen b3_se = _se[ln_mu]
gen obsv_3 = e(N) 

collapse b1 b1_se obsv_1 b2 b2_se obsv_2 b3 b3_se obsv_3
save data/internally_generated/tableR1_estimates, replace 
}

use data/internally_generated/tableR1_estimates, clear

capture file close OuputTable
	file open  OuputTable using "output/Table_R1.tex", write replace
	file write 	OuputTable /// 
    "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n ///
    "\begin{adjustbox}{width=0.7\textwidth}" _n ///
    "\begin{tabular}{lcccccc}" _n ///
		 "\midrule" _n /// 									               
    "& \multicolumn{5}{c}{dependent: trade elasticity ($ \sigma_{k} - 1 $)} \\ "   _n ///                
         "\toprule" _n ///
   "$\mu_{i,k}=\frac{1}{N_{i,k}}\times\frac{\gamma_{k}}{\gamma_{k}-1}$ &" %6.3f (b1) "\sym{***} &&" %6.3f (b2) "\sym{***} &&" %6.3f (b3) "\sym{***} \\" _n ///                  
	"&"   %8.4f (b1_se)  "&&"    %8.4f (b2_se)    "&&"    %8.4f (b3_se)    "\\  \\"   _n ///   
    "\addlinespace"    _n ///   
    "Year fixed effects    &   No   &&    Yes    &&   Yes  \\"    _n ///   
    "Origin fixed effects  &   No   &&    No     &&  Yes   \\"    _n ///   
    "Observations        &"        %9.0fc (obsv_1)      "&&"     %9.0fc (obsv_2)   "&&"   %9.0fc (obsv_1)   " \\ "  _n /// 
					"\bottomrule"  _n /// 
    "\end{tabular}"   _n ///
	"\end{adjustbox}" 

file close OuputTable
*erase data/internally_generated/table3_estimates
log close
