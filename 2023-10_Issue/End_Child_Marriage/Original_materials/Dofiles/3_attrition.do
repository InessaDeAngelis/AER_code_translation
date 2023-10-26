/************************************
Project:    A Signal to End Child Marriage: Theory and Experimental Evidence from Bangladesh
File Name:  3_attrition.do
Purpose:    Calculate Attrition
************************************/

/* Notes:
	
	Calculate Attrition.
	
	
*/

clear
set more off

cap log close
log using "$logs\3_attrition_$date_string", replace

********************************************************************************
* ABSOLUTE NUMBERS FOR TRIAL PROFILE - CENSUS
*******************************************************************************

* Calculate and export absolute attrition numbers
u "$data\waveIII", clear

keep if bl_age_reported>=14 & bl_age_reported<=16 & bl_ever_married==0

g attrition=endline==0
local controls "bl_age_reported bl_still_in_school older_sister bl_education_mother bl_HHsize bl_public_transit"
local controlsm "bl_still_in_school_miss older_sister_miss bl_education_mother_miss bl_HHsize_miss bl_public_transit_miss"

la var bl_age_reported "Age"
la var bl_still_in_school "Still in-school"
la var older_sister "Unmarried older sister in HH"
la var bl_education_mother "Mother education"
la var bl_HHsize "HH size (members)"
la var bl_public_transit "Community connected to public transport"

foreach var in `controls'{
	cap g `var'_miss=`var'==. 
	replace `var'=0 if `var'==. 
}
local control1 ""
local control2 "`controls' `controlsm'"

forval i=1/2{
	eststo atbroad`i': reg attrition at1 at2 at3 `control`i'', cluster(CLUSTER) 
	sum attrition if treatment_type==4
	estadd scalar control_mean=r(mean)
}
drop attrition

codebook CLUSTER
codebook HHID
codebook girlID

* Noprefill
bys HHID: egen min_noprefill=min(noprefill)
g all_noprefill=min_noprefill==1
codebook HHID if all_noprefill==1 & missing_village==1
codebook girlID if noprefill==1 & missing_village==1
codebook HHID if all_noprefill==1 & missing_village==0
codebook girlID if noprefill==1 & missing_village==0
drop if noprefill==1
drop min_noprefill all_noprefill

* Washedout
codebook CLUSTER if washedout==1 
codebook HHID if washedout==1 
codebook girlID if washedout==1 
drop if washedout==1

* Followed-up
forvalues i=1/4{
	di `i'
	codebook CLUSTER if treatment_type==`i'
	codebook HHID if treatment_type==`i'
	codebook girlID if treatment_type==`i'
}	

* Attritted
g attrition=endline==0
codebook girlID if attrition==1
sum attrition
bys HHID: egen min_attritted=min(attrition)
g all_attritted=min_attritted==1
forvalues i=1/4{
	di `i'
	codebook HHID if endline==0 & all_attritted==1 & treatment_type==`i'
	codebook girlID if endline==0 & treatment_type==`i'
	sum attrition if treatment_type==`i'
}	
drop min_attritted all_attritted

* Married before oil program or missing baseline info
preserve
keep if endline==1
bys HHID: egen min_miss=min(before_miss)
g all_miss=min_miss==1
forvalues i=1/4{
	di `i'
	codebook HHID if all_miss==1 & treatment_type==`i'
	codebook girlID if before_miss==1 & treatment_type==`i'
}	
reg before_miss at1 at2 at3, cluster(CLUSTER)
drop if before_miss==1
forvalues i=1/4{
	di `i'
	codebook HHID if treatment_type==`i'
	codebook girlID if treatment_type==`i'
}
restore

********************************************************************************
* ATTRITION REGRESSION - CENSUS
*******************************************************************************
local controls "bl_age_reported bl_still_in_school older_sister bl_education_mother bl_HHsize bl_public_transit"
local controlsm "bl_still_in_school_miss older_sister_miss bl_education_mother_miss bl_HHsize_miss bl_public_transit_miss"

la var bl_age_reported "Age"
la var bl_still_in_school "Still in-school"
la var older_sister "Unmarried older sister in HH"
la var bl_education_mother "Mother education"
la var bl_HHsize "HH size (members)"
la var bl_public_transit "Community connected to public transport"

foreach var in `controls'{
	cap g `var'_miss=`var'==. 
	replace `var'=0 if `var'==. 
}
local control1 ""
local control2 "`controls' `controlsm'"

forval i=1/2{
	eststo atnormal`i': reg attrition at1 at2 at3 `control`i'', cluster(CLUSTER) 
	sum attrition if treatment_type==4
	estadd scalar control_mean=r(mean)
}


********************************************************************************
* ABSOLUTE NUMBERS FOR TRIAL PROFILE - SUBSAMPLE
*******************************************************************************

* Calculate and export absolute attrition numbers
u "$data\waveIII_young_women_sample", clear
keep if bl_age_reported>=14 & bl_age_reported<=16 & bl_ever_married==0
count

g attrition=endline==0
local controls "bl_age_reported bl_still_in_school older_sister bl_education_mother bl_HHsize bl_public_transit bl_bmi bl_stunted bl_income"
local controlsm "bl_still_in_school_miss older_sister_miss bl_education_mother_miss bl_HHsize_miss bl_public_transit_miss bl_bmi_miss bl_stunted_miss bl_income_miss"

replace bl_income=bl_income/100

la var bl_age_reported "Age"
la var bl_still_in_school "Still in-school"
la var older_sister "Unmarried older sister in HH"
la var bl_education_mother "Mother education"
la var bl_HHsize "HH size (members)"
la var bl_public_transit "Community connected to public transport"
la var bl_bmi "BMI"
la var bl_stunted "Stunted"
la var bl_income "HH income (100 USD)"

foreach var in `controls'{
	cap g `var'_miss=`var'==. 
	replace `var'=0 if `var'==. 
}
local control1 ""
local control2 "`controls' `controlsm'"

forval i=1/2{
	eststo atbroad`i'_ss: reg attrition at1 at2 at3 `control`i'', cluster(CLUSTER) 
	sum attrition if treatment_type==4
	estadd scalar control_mean=r(mean)
}

estout atbroad* ///
using "$output\Tables\Reg_Attrition\attrition_broad.tex", label replace cells(b(fmt(3)) se(par fmt(3))) style(tex) ///
mlabels(, none) collabels(, none) varlabels(N Observations) ///
eqlabels(, none)  ///
stats(control_mean N, fmt(3 %12.0gc) ///
labels("\hline Control Mean" "Observations")) /// 
noomitted keep(at1 at2 at3 `controls') order(at1 at2 at3 `controls')    

drop attrition
codebook CLUSTER
codebook HHID
codebook girlID

* Washedout
codebook CLUSTER if girls_washedout==1 
codebook HHID if girls_washedout==1 
codebook girlID if girls_washedout==1 
drop if girls_washedout==1

* Attritted
g attrition=endline==0
codebook girlID if attrition==1
tab attrition
sum attrition
bys HHID: egen min_attritted=min(attrition)
g all_attritted=min_attritted==1
forvalues i=1/4{
	di `i'
	codebook HHID if endline==0 & all_attritted==1 & treatment_type==`i'
	codebook girlID if endline==0 & treatment_type==`i'
	sum attrition if treatment_type==`i'
}	
drop min_attritted all_attritted

* Married before oil program or missing baseline info
preserve
keep if endline==1
bys HHID: egen min_miss=min(before_miss)
g all_miss=min_miss==1
forvalues i=1/4{
	di `i'
	codebook HHID if all_miss==1 & treatment_type==`i'
	codebook girlID if before_miss==1 & treatment_type==`i'
}	
reg before_miss at1 at2 at3, cluster(CLUSTER)
drop if before_miss==1
forvalues i=1/4{
	di `i'
	codebook HHID if treatment_type==`i'
	codebook girlID if treatment_type==`i'
}
count
restore

********************************************************************************
* ATTRITION REGRESSION
*******************************************************************************
local controls "bl_age_reported bl_still_in_school older_sister bl_education_mother bl_HHsize bl_public_transit bl_bmi bl_stunted bl_income"
local controlsm "bl_still_in_school_miss older_sister_miss bl_education_mother_miss bl_HHsize_miss bl_public_transit_miss bl_bmi_miss bl_stunted_miss bl_income_miss"

replace bl_income=bl_income/100

la var bl_age_reported "Age"
la var bl_still_in_school "Still in-school"
la var older_sister "Unmarried older sister in HH"
la var bl_education_mother "Mother education"
la var bl_HHsize "HH size (members)"
la var bl_public_transit "Community connected to public transport"
la var bl_bmi "BMI"
la var bl_stunted "Stunted"
la var bl_income "HH income (100 USD)"

foreach var in `controls'{
	cap g `var'_miss=`var'==. 
	replace `var'=0 if `var'==. 
}
local control1 ""
local control2 "`controls' `controlsm'"

forval i=1/2{
	eststo atnormal`i'_ss: reg attrition at1 at2 at3 `control`i'', cluster(CLUSTER) 
	sum attrition if treatment_type==4
	estadd scalar control_mean=r(mean)
}


estout atnormal* ///
using "$output\Tables\Reg_Attrition\attrition.tex", label replace cells(b(fmt(3)) se(par fmt(3))) style(tex) ///
mlabels(, none) collabels(, none) varlabels(N Observations) ///
eqlabels(, none)  ///
stats(control_mean N, fmt(3 %12.0gc) ///
labels("\hline Control Mean" "Observations")) /// 
noomitted keep(at1 at2 at3 `controls') order(at1 at2 at3 `controls')    
eststo clear	
