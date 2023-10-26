/************************************
Project:    A Signal to End Child Marriage: Theory and Experimental Evidence from Bangladesh
File Name:  5_graphs.do
Purpose: 	Preparing Graphs
************************************/
	
/* Notes:
	
	Preparing different graphs of outcome variables. 
	
*/

clear
graph drop _all
set more off

set scheme s2color, permanently
set pformat %5.4f, permanently

cap log close
log using "$logs\5_graphs_$date_string", replace

*DHS graph - mean by years
********************************************************************************
u "$data\dhs_cleaned", clear

preserve
twoway line literate year 	if year <= 2014, lp(dash_dot) lcolor(ltblue) yaxis(1) ylabel(20(10)90, axis(1)) ytitle("", axis(1)) lstyle(width(medium)) /// 
	|| line literate year 	if year >= 2014, lp(dash_dot) lcolor(ltblue) yaxis(1) ///
	|| line primary year 	if year <= 2014, lp(shortdash) lcolor(ebblue) yaxis(1)  ///
	|| line primary year 	if year >= 2014, lp(shortdash) lcolor(ebblue) yaxis(1)  ///
	|| line u5_mort year if year <= 2014, lp(longdash) lcolor(navy) yaxis(1)  ///
	|| line u5_mort year if year >= 2014, lp(longdash) lcolor(navy) yaxis(1) ///
	|| line married_18 year if year <= 2014, lp(solid) lcolor(red) yaxis(1) ///
	|| line married_18 year if year >= 2014, lp(solid) lcolor(red) yaxis(1) ///				
    || line secondary year 	if year <= 2014, lp(shortdash_dot) lcolor(blue) yaxis(2)  ylabel(10(5)30, axis(2)) ytitle("", axis(2))  lstyle(width(medium)) ///
	|| line secondary year 	if year >= 2014, lp(shortdash_dot) lcolor(blue) yaxis(2)  ,   ///
	|| , legend(on order(- "{it:Left Axis:}" - "{it:Right Axis:}" 1 9  3 - 5 -  7 - "" ) label(1 "Literate (%)") label(3 "Completed Primary (%)") ///
    label(5 "Mortality Under 5 (per 1000)") label(7 "Married < 18 (%)") label(9 "Completed Secondary (%)") colgap(2) symxsize(7)) ///
	graphregion(color(white) style(line)) xlabel(2004 2007 2011 2014 2017) xtitle("")
	graph export "$graphs\DHS.png", replace
	graph export "$graphs\pdf_versions\DHS.pdf", replace
restore
	
* Desired characteristics by spouses
********************************************************************************

u "$data\spouses", clear
keep if resp_status==1 & consent==1
ren girlID ss_girlID
merge 1:1 ss_girlID using "$data\waveIII_young_women_sample", nogen keep(3)
keep if endline==1 & washedout==0 & before_miss==0 & treatment_type==4
foreach var of varlist hus_secondary_complete hus_formal {
	cap replace `var'=`var'*100
	}
la var husband_age "Age"
la var husband_edu "Education"
la var hus_secondary_complete "Secondary School (\%)"
la var hus_formal "Formally employed (\%)"
la var hus_income "Income (USD)"

la def character 1 "Looks/attractiveness" 2 "Age" 3 "Education" 4 "Family/Girl's wealth" 5 "Income earning potential" 6 "Character/Values" 7 "Reputation" 8 "Obeys religious customs and traditions" 9 "Knows how to do housework" 10 "Good family" 11 "Hard-working nature" 12 "Like-mindedness/Romantic" 13 "Temperament/Nature", replace
forval i=1/13{
	g character`i'=cchar_marriage1==`i' | cchar_marriage2==`i'
	replace character`i'=. if cchar_marriage1==. & cchar_marriage2==.
	replace character`i'=character`i'*100
	tab character`i'
}
la var character1 "Looks/Attractiveness (%)" 
la var character2 "Age (%)" 
la var character3 "Education (%)" 
la var character5 "Hard-working/Income (%)"
la var character6 "Nature/Character/Reputation/Religion/Tradition (%)" 
la var character9 "Knows how to do housework (%)"
la var character10 "Good family/Wealth (%)" 
la var character12 "Like-mindedness/Romantic (%)" 

replace character6=100 if character13==100 | character7==100 | character8==100
replace character5=100 if character11==100
replace character10=100 if character4==100

* how many husbands
count

* how many husbands choose age
tab character2

keep character1 character9 character12 character3 character6 character10 character2 character5
foreach num of numlist 6 {
	ren character`num' SC`num'
}

g n=_n
reshape long character SC, i(n) j(category)
la def character 1 "Looks" 2 "Young Age" 3 "Education" 5 "Hard-working/Income" 6 "Nature/Reputation/Tradition" 9 "Housework" 10 "Good Family/Wealth" 12 "Romantic Compatibility", replace
la val category SC character
g order=. 
local order=0
foreach num of numlist 6 1 3 12 9 10 5 2{
	local order=`order'+1
	replace order=`order' if category==`num'
}
graph hbar character SC, over(category, sort(order) gap(*6)) legend(off) graphregion(color(white)) bargap(*15.1) blabel(bar, format(%4.1f)) ytitle("% of Husbands")
graph export "$graphs\characteristics.png", replace
graph export "$graphs\pdf_versions\characteristics.pdf", replace

* PDFs
*******************************************************************************
u "$data\waveIII", clear

* Keep analysis sample
keep if endline==1 & washedout==0 & bl_age_reported>=14 & bl_ever_married==0 & before_miss==0

forval a=0/0{
	/// a=0: Age 14-16, a=1: Age15
		
	foreach var of varlist marriage_age {
		
		preserve

		if `a'==1{
			keep if bl_age_reported==14
		}
		local label "Marriage Age"	
		local bw=0.8
		if "`var'"=="education"{
			keep if bl_still_in_school==1
			local label "Last Class Passed"
			local bw=1.5
			egen mode_edu=mode(bl_education)
			g bl_kk=d(1dec2007)-bl_fielddate
			replace mode_edu=mode_edu+(bl_kk/365.25) 
			sum mode_edu
			local mode `r(mean)'
		}
	
		g `var'1=`var' if at4==1
		g `var'2=`var' if at2==1
		forval i=1/2{
			kdensity `var'`i', bw(`bw') nograph gen(x`i' `var'`i'_t)
		}
		forval j=1/4{
			kdensity `var' if at`j'==1, bw(`bw') nograph gen(x2`j' `var'2`j'_t)
		}
	
		label var x1 "`label'"
		label var `var'1_t "Control"
		label var `var'2_t "Incentive Only"
		label var `var'21_t "Empowerment"
		label var `var'22_t "Incentive"
		label var `var'23_t "Incen.+Empow."
		label var `var'24_t "Control"

		if "`var'"=="marriage_age"{
			local xline ""
		}
		if "`var'"=="education"{
			local xline "xline(`mode', lcolor(black)) xlabel(0 5 15 20) xlabel(`mode' "Median (BL)", angle(45) add)"
		}		
		twoway line `var'1_t `var'2_t x1, sort lpattern(dash solid) lwidth(medthick medthick) ytitle(Density) legend(cols(1) ring(0) position(6)) graphregion(color(white)) `xline' name(`var'`a'1, replace)
		graph export "$graphs\PDF_`var'_age`a'.png", replace
		graph export "$graphs\pdf_versions\PDF_`var'_age`a'.pdf", replace

		restore
		}
	}
