/************************************
Project:    A Signal to End Child Marriage: Theory and Experimental Evidence from Bangladesh
File Name:  1_clean_DHS.do
Purpose:    Clean DHS data for Figure 1 in the paper
************************************/

/* Notes:
	
	Cleaning DHS data for graphs
	
*/

clear
set more off
set seed 		08022023 	// date Feb 08, 2023
set sortseed 	08022023 	// date Feb 08, 2023

cap log close
log using "$logs\1_clean_DHS_$date_string", replace

* age range for literacy, completed primary, completed secondary, child marriage
local min_age=30
local max_age=35

***********************************************************
******************** Under-5 Mortality ********************
***********************************************************
* for methodology, see Ch. 8 of the Guide to DHS Statistics: https://www.dhsprogram.com/pubs/pdf/DHSG1/Guide_to_DHS_Statistics_DHS-7_v2.pdf

foreach i in 2004 2007 2011 2014 2017 {
	* Import DHS birth recode dataset
	u "${dhsbr`i'}", clear
	
	isid caseid bidx
	keep caseid bidx v001 v002 v003 v004 v005 v007 v008 v012 b*
	gen s_weight= v005/1000000
	
	* replacing year of interview with wave of interview for 2017 wave
	replace v007=2017 if v007==2018

	rename v012 mother_age

	* looping over age group parameters to calculate component death probabilities
	forvalues a1 = 0/60 {
		if !inlist(`a1', 0, 1, 3, 6, 12, 24, 36, 48)==1 {
			continue
		}
		preserve

		************ Defining Parameters: Age groups & Time period ************
		*** Time period: 5 years preceding the survey
		gen t1 = v008-60	// survey month-5 years
		gen t2 = v008		// survey month

		*** Age groups: (a1, a2] months (up to 60 months)
		/*	0 		a1 = 0 ; a2 = 1
			1-2 	a1 = 1 ; a2 = 3
			3-5 	a1 = 3 ; a2 = 6
			6-11 	a1 = 6 ; a2 = 12
			12-23 	a1 = 12; a2 = 24
			24-35 	a1 = 24; a2 = 36
			36-47 	a1 = 36; a2 = 48
			48-59 	a1 = 48; a2 = 60 	*/

		gen a1 = `a1'
		gen a2 =	cond(`a1'==  0, 1,				///
					cond(`a1'==  1, 3, 				///
					cond(`a1'==  3, 6, 				///
					cond(`a1'==  6, 12, 			///
					cond(`a1'== 12, 24, 			///
					cond(`a1'== 24, 36, 			///
					cond(`a1'== 36, 48, 60)))))))

		** Calculating numerator and denominators
		/* Numerators:
			(a1 <= b7 < a2		  & t1 - a2 <= b3 < t1 - a1), plus
			(a1 <= b7 < a2 		  & t1 - a1 <= b3 < t2 - a2), plus
			(a1 <= b7 < a2 		  & t2 - a2 <= b3 < t2 - a1)
		
		 * Denominators:
			((b5 = 1 or a1 <= b7) & t1 - a2 <= b3 < t1 - a1), plus
			((b5 = 1 or a1 <= b7) & t1 - a1 <= b3 < t2 - a2), plus
			((b5 = 1 or a1 <= b7) & t2 - a2 <= b3 < t2 - a1) 		*/

		**** Numerators ****
		* Cohort A: (a1<=b7<a2 & (t1-a2) <= b3 < (t1-a1))
		gen num_cohort_a = 1 if b7>=a1 & b7<a2		& b3>=(t1-a2) & b3<(t1-a1)
		replace num_cohort_a=0 if num_cohort_a==.

			* replacing half the cohort A numerator values
			gen share = runiform(0,1) if num_cohort_a==1
			replace num_cohort_a=0 if (share)<=0.5
			drop share

		* Cohort B: (a1<=b7<a2 & (t1-a1) <= b3 < (t2-a2))
		gen num_cohort_b = 1 if b7>=a1 & b7<a2		& b3>=(t1-a1) & b3<(t2-a2)
		replace num_cohort_b=0 if num_cohort_b==.

		* Cohort C: (a1<=b7<a2 & (t2-a2) <= b3 < (t2-a1))
		gen num_cohort_c = 1 if b7>=a1 & b7<a2		& b3>=(t2-a2) & b3<(t2-a1)
		replace num_cohort_c=0 if num_cohort_c==.

		gen numerator = num_cohort_a + num_cohort_b + num_cohort_c

		**** Denominators ****
		* Cohort A: ((b5=1 or a1<=b7) & (t1-a2) <= b3 < (t1-a1)
		gen den_cohort_a = 1 if (b5==1 | b7>=a1) 	& b3>=(t1-a2) & b3<(t1-a1)
		replace den_cohort_a=0 if den_cohort_a==.
		
		* Cohort B: ((b5=1 or a1<=b7) & (t1-a1) <= b3 < (t2-a2)
		gen den_cohort_b = 1 if (b5==1 | b7>=a1) 	& b3>=(t1-a1) & b3<(t2-a2)
		replace den_cohort_b=0 if den_cohort_b==.
		
		* Cohort C: ((b5=1 or a1<=b7) & (t2-a2) <= b3 < (t2-a1))
		gen den_cohort_c = 1 if (b5==1 | b7>=a1) 	& b3>=(t2-a2) & b3<(t2-a1)
		replace den_cohort_c=0 if den_cohort_c==.

		gen denominator = den_cohort_a + den_cohort_b + den_cohort_c

		* calculating component survival and death probabilities
		keep if denominator==1
		mean numerator [pw=s_weight]
		matrix list r(table)
		xsvmat, from(r(table)') rownames(var) names(col) norestore
		keep b
		rename b comp_death_prob
		list

		gen comp_survival_prob`i' = 1-comp_death_prob
		gen year=`i'
		gen a1=`a1'
		order year a1 comp_survival_prob`i'
		drop comp_death_prob

		* saving in tempfile to later merge
		tempfile temp`i'_`a1'
		save `temp`i'_`a1'', replace

		restore
	}	// age group loop end

	* appending in component survival probabilities for different age groups
	u `temp`i'_0', clear
	foreach j in 1 3 6 12 `24' 36 48 {
		append using `temp`i'_`j''
	}

	* reshaping so that can multiply each age group survival probability
	rename comp* comp*_
	reshape wide comp_survival_prob`i', i(year) j(a1)

	* multiplying component survival probabilities
	gen product= comp_survival_prob`i'_0 * comp_survival_prob`i'_1 * comp_survival_prob`i'_3 * comp_survival_prob`i'_6 * comp_survival_prob`i'_12 * comp_survival_prob`i'_36 * comp_survival_prob`i'_48

	* calculating under-5 mortality (= (1-product of component survival probabilities)*1000)
	gen u5_mort = (1-product)*1000
	keep year u5_mort

	* saving in tempfile to later merge
	tempfile u5_mort_new_`i'
	save `u5_mort_new_`i'', replace

}		// year loop end


* appending different years
u `u5_mort_new_2004'
foreach i in 2007 2011 2014 2017 {
	append using `u5_mort_new_`i''
}

tempfile under5_mortality
save `under5_mortality'


***********************************************************
********************** Woman Stats ************************
***********************************************************
* importing woman dataset
u "$dhsir2004", clear
keep caseid v000 v001 v002 v003 v004 v005 v007 v012 v106 v107 v133 v149 v508 v511 v218 s111 v024 

* literacy variable changing name between waves 
rename s111 v155

** append different waves 
local data "`"$dhsir2007"' `"$dhsir2011"' `"$dhsir2014"' `"$dhsir2017"'"
foreach i of local data {
	append using "`i'", keep(caseid v000 v001 v002 v003 v004 v005 v007 v012 v106 v107 v149 v508 v511  v218 v155 v024)
}

* replacing year of interview with wave of interview for 2017 wave
replace v007=2017 if v007==2018

* rename variables
rename caseid ID
rename v000 countrycode
rename v005 s_weight
rename v007 year
rename v012 age 
rename v106 edu_level
rename v107 edu_highest_year
rename v133	edu_years
rename v149 edu_attainment
rename v218 living_children
rename v508 marriage_year
rename v511 marriage_age
rename v155 literacy 
rename v024 region


***** gen vars for graph
** completed secondary schooling
gen secondary= 1 if edu_attainment>=4
replace secondary=0 if edu_attainment<4

** completed primary schooling
gen primary=1 if edu_attainment>=2
replace primary=0 if edu_attainment<2 
tab edu_attainment primary, m

** literate
gen literate=1 if literacy==1 | literacy==2
replace literate=0 if literacy==0
tab literacy literate, m

** married by age 18
gen married_18=1 if marriage_age<18 
replace married_18=0 if marriage_age>=18
tab marriage_age married_18, m

** label variables 
label var secondary 	"Has secondary education or higher"
label var primary 		"Has primary education or higher"
label var literate  	"Can read and write"
label var married_18 	"Was married before 18"
label var marriage_year "Year of marriage"

** label values 
label define secondary	0 "has no secondary education" 1 "has secondary education or higher"
label define primary 	0 "has no primary education" 1 "has primary education or higher"
label define literate  	0 "Cannot read or write" 1 "Can read and write"
label define married_18 0 "Married>=18" 1 "Married<18"

label values secondary secondary
label values primary primary
label values literate literate 
label values married_18 married_18 

** weights
replace s_weight= s_weight/1000000

** calculating means by year
foreach i in primary secondary literate married_18 {
	preserve
	** keep women in age range
	keep if age>=`min_age' & age<=`max_age'
	
	mean `i' [pw=s_weight], over(year)
	matrix list r(table)
	xsvmat, from(r(table)') rownames(year) names(col) norestore
	split year, parse("@")
	drop year year1
	replace year2 = substr(year, 1, 4)
	rename year2 year
	destring year, replace
	sort year
	keep year b
	rename b `i'

	tempfile t`i'
	save `t`i'', replace
	restore
}

** merging
u `tprimary', clear
foreach dataset in primary secondary literate married_18 {
	merge 1:1 year using `t`dataset''
	drop _merge*
	order year
}

list

***********************************************************
******************* Merging & Rescaling *******************
***********************************************************
** merging in under-5 mortality dataset
merge 1:1 year using `under5_mortality'
drop _merge

** rescale variables for graph (under-5 mortality is already scaled)
foreach var in primary secondary literate married_18 {
	replace `var'= `var'*100
}

*save cleaned dataset
save "$data/dhs_cleaned.dta", replace
