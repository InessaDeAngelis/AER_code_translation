/************************************
Project:    A Signal to End Child Marriage: Theory and Experimental Evidence from Bangladesh
File Name:  6_model_assumptions.do
Purpose: 	Checking Model Assumptions
************************************/


/* Notes:
	
	Check Model Assumptions 
	
*/

clear
set more off
set seed 		2023
set sortseed 	2023

cap log close
log using "$logs\6_model_assumptions_$date_string", replace

********************************************************************************
* Observability of Social Conservatism
********************************************************************************

* Import data
u "$data\waveIII_young_women_sample", clear

foreach var in bl_educ_goal_comfort bl_puberty_comfort bl_marriage_time_comfort bl_marriage_choice_comfort bl_marriage_dowry_comfort bl_harrassment_comfort bl_harrassment_discuss would_tell{
	cap g `var'=-i_`var'
}

* Adjust the names
** Girls
foreach var of varlist bl_latest_marry bl_highest_education bl_desired_marriage_age{
    cap replace `var'=. if `var'_miss==1
	}	
ren bl_husband_level g_wives_less_educated
ren bl_allow_study g_girls_study_far 
ren bl_highest_education g_education_desired
ren bl_latest_marry g_max_marriage_age
ren bl_desired_marriage_age g_age_married_desired
replace g_max_marriage_age=. if g_max_marriage_age>40
replace g_education_desired=. if g_education_desired>18
replace g_age_married_desired=. if g_age_married_desired>40
ren bl_allow_makeup g_makeup
ren bl_allow_dress g_dress
ren bl_educ_goal_comfort g_edu_comfort
ren bl_puberty_comfort g_pub_comfort
ren bl_marriage_time_comfort g_mar_time_comfort
ren bl_marriage_choice_comfort g_mar_choice_comfort
ren bl_marriage_dowry_comfort g_dowry_comfort
ren bl_harrassment_comfort g_harass_comfort
ren bl_harrassment_discuss g_harass_discuss
ren bl_reason_occupation_none g_no_occu 
ren bl_reason_occupation_emerg g_emerg_occu 
ren no_menstru g_no_menstru 
ren would_tell g_would_tell

** Parents
ren wives_less_educated p_wives_less_educated
ren girls_study_far p_girls_study_far 
ren education_desired p_education_desired
ren max_marriage_age p_max_marriage_age
ren age_married_desired p_age_married_desired

* Girls' and Parents' conservatism
local subs "g p"
foreach sub in `subs'{
	g `sub'_secondary_complete_d=`sub'_education_desired>=10
	replace `sub'_secondary_complete_d=. if `sub'_education_desired==.
	g `sub'_max_age_20=`sub'_max_marriage_age>20
	replace `sub'_max_age_20=. if `sub'_max_marriage_age==.
	g `sub'_age_married_desired_20=`sub'_age_married_desired>20
	replace `sub'_age_married_desired_20=. if `sub'_age_married_desired==. 
	}
keep ss_girlID HHID g_* p_* bl_age_reported

preserve

* Siblings' conservatism
ren g_* *
keep ss_girlID HHID bl_age_reported wives_less_educated girls_study_far secondary_complete_d max_age_20 age_married_desired_20 makeup dress edu_comfort pub_comfort mar_time_comfort mar_choice_comfort dowry_comfort harass_comfort harass_discuss no_occu emerg_occu no_menstru would_tell 
bys HHID: g n=_n
reshape wide ss_girlID bl_age_reported wives_less_educated girls_study_far secondary_complete_d max_age_20 age_married_desired_20 makeup dress edu_comfort pub_comfort mar_time_comfort mar_choice_comfort dowry_comfort harass_comfort harass_discuss no_occu emerg_occu no_menstru would_tell, i(HHID) j(n)
keep if bl_age_reported2!=.
local conservative "wives_less_educated girls_study_far secondary_complete_d max_age_20 age_married_desired_20 makeup dress edu_comfort pub_comfort mar_time_comfort mar_choice_comfort dowry_comfort harass_comfort harass_discuss no_occu emerg_occu no_menstru would_tell"

forval i=1/3{
    forval j=1/3{
	    if `i'!=`j'{
			g age_diff`i'`j'=abs(bl_age_reported`i'-bl_age_reported`j')
			}
		}
	egen min_diff`i'=rowmin(age_diff`i'*)	 
	foreach var in `conservative'{
		g s_`var'`i'=.
		}
    forval j=1/3{
	    if `i'!=`j'{
		    foreach var in `conservative'{
				replace s_`var'`i'=`var'`j' if age_diff`i'`j'==min_diff`i' & min_diff`i'!=.
				}
			}
		}
	}
foreach var in `conservative'{
	local vars `vars' "s_`var'"
}	
keep HHID ss_girlID* s_*
reshape long ss_girlID `vars', i(HHID) j(n)
drop n HHID
drop if ss_girlID==""
tempfile siblings
save `siblings', replace

restore
merge 1:1 ss_girlID using `siblings'
drop _merge

local subs "s p"
foreach var in `conservative'{
	foreach sub in `subs'{
		cap g `var'_`sub'_diff=100*(g_`var'!=`sub'_`var')
		cap replace `var'_`sub'_diff=. if g_`var'==. | `sub'_`var'==.
		}
	cap noisily: tab g_`var'
	cap noisily tab p_`var'
	cap noisily tab s_`var'
}

foreach sub in `subs'{
	estpost sum wives_less_educated_`sub'_diff
	est store diff_`sub'
	sum wives_less_educated_`sub'_diff
	scalar wives_less_educated_`sub'_mean=r(mean)
	est restore diff_`sub'
	estadd scalar wives_less_educated_`sub'_mean
	estout diff_`sub' ///
		using "$tables\Summary\Observability_SC\diff_`sub'.tex", replace style(tex)  ///
		label cells(none) ///
		mlabels(, none) collabels(, none) eqlabels(, none) ///
		stats(wives_less_educated_`sub'_mean,labels(, none) fmt(2))
	local cons "girls_study_far secondary_complete_d max_age_20 age_married_desired_20 makeup dress edu_comfort pub_comfort mar_time_comfort mar_choice_comfort dowry_comfort harass_comfort harass_discuss no_occu emerg_occu no_menstru would_tell"
	foreach var in `cons'{
		cap sum `var'_`sub'_diff
		cap scalar `var'_`sub'_mean=r(mean)
		cap est restore diff_`sub'
		cap estadd scalar `var'_`sub'_mean
		cap estout diff_`sub' ///
			using "$tables\Summary\Observability_SC\diff_`sub'.tex", append style(tex)  ///
			label cells(none) ///
			mlabels(, none) collabels(, none) eqlabels(, none) ///
			stats(`var'_`sub'_mean,labels(, none) fmt(2))
			}			
		}

********************************************************************************
* Correlation between SC and marriage and education outcomes
********************************************************************************

* Define outcomes	
local outcomes "ever_married under_18 still_in_school education iga_current econ_dec_index "
local econ_dec_k "majorpurchase_dec bed_dec bedsheet_dec utensils_dec phone_recharge_dec cosmetics_dec accessories_dec loan_dec ornament_dec access_cash budget_dec"

* Import data
u "$data\waveIII_young_women_sample", clear

replace iga_current=0 if ever_worked==0
la var high_p_cons "High Parents' Social Conservatism"

* Keep only analysis data
keep if treatment_type==4 & endline==1 & girls_washedout==0 & before_miss==0

local controls "older_sister bl_still_in_school bl_education_mother bl_HHsize bl_public_transit bl_age6 bl_age7 bl_age8 bl_age9 bl_age10 bl_age11 bl_age12 bl_age13 bl_age14 bl_age15 bl_age16 bl_age17 bl_stunted bl_bmi bl_income"
local miss "older_sister_miss bl_still_in_school_miss bl_education_mother_miss bl_HHsize_miss bl_public_transit_miss bl_stunted_miss bl_bmi_miss bl_income_miss"

foreach control in `controls'{
	cap g `control'_miss=`control'==. 
	cap replace `control'=0 if `control'==.
}

* Loop through outcomes
foreach outcome in `outcomes'{
	preserve
					
	if "`outcome'"=="econ_dec_index"{
		keep if ever_married==1
		egen observations=rownonmiss(`econ_dec_k')
		foreach component in `econ_dec_k'{
			bys high_g_cons high_p_cons: egen `component'_med=mean(`component')
			g `component'_k=`component'
			sum `component' if high_g_cons==0 & high_p_cons==0
			g `component'_mean=r(mean)
			g `component'_sd=r(sd)
			g `component'_std=(`component'_k-`component'_mean)/`component'_sd
			}
		egen econ_dec_index=rowmean(*_std)
	}

	* Run regression
	eststo reg_`outcome': reg `outcome' high_g_cons high_p_cons i.third i.unionID `controls' `miss' , cluster(CLUSTER)
	sum `outcome' if high_g_cons==0
	estadd scalar control_mean=r(mean)
	estadd local fe_var "Union"
	
	restore
}

* Output the data

estout reg_* ///
using "$tables\Reg_ITT\Social_Conservatism.tex", label replace cells(b( fmt(3)) se(par fmt(3))) style(tex) ///
mlabels(, none) collabels(, none) varlabels(N Observations) ///
eqlabels(, none) ///
stats(control_mean N fe_var, fmt(3 %12.0gc) ///
labels("\hline Outcome Mean" "Observations" "FE")) /// 
noomitted keep(high_g_cons high_p_cons) order(high_g_cons high_p_cons)      
eststo clear
	
********************************************************************************
* Share of girls who heard about the incentive
********************************************************************************

* Import data
u "$data\waveIII_young_women_sample", clear 

* keep sample
keep if endline==1 & girls_washedout==0 & before_miss==0

* Convert in percent for the table
replace oil_heard=oil_heard*100
sum oil_heard if anyoil==0	

* Create treatment groups
g group=. 
replace group=1 if anylist==1
replace group=2 if anylist==0 & anyoil==1
replace group=3 if vill_radius_500_oil==1 & anyoil==0
replace group=4 if vill_radius_500_oil==0 & anyoil==0

forval i=1/4{
	estpost sum oil_heard if group==`i'
	est store group`i'
	sum oil_heard if group==`i'
	scalar group`i'_mean=r(mean)
	scalar group`i'_sd=r(sd)
	scalar group`i'_N=r(N)
	est restore group`i'
	estadd scalar group`i'_mean
	estout group`i' ///
		using "$tables\Summary\Exposure\group`i'.tex", replace style(tex)  ///
		label cells(none) ///
		mlabels(, none) collabels(, none) eqlabels(, none) ///
		stats(group`i'_mean,labels(, none) fmt(2))
	est restore group`i'
	estadd scalar group`i'_sd
	estout group`i' ///
		using "$tables\Summary\Exposure\group`i'.tex", append style(tex)  ///
		label cells(none) ///
		mlabels(, none) collabels(, none) eqlabels(, none) ///
		stats(group`i'_sd,labels(, none) fmt(2))
	est restore group`i'
	estadd scalar group`i'_N
	estout group`i' ///
		using "$tables\Summary\Exposure\group`i'.tex", append style(tex)  ///
		label cells(none) ///
		mlabels(, none) collabels(, none) eqlabels(, none) ///
		stats(group`i'_N,labels(, none) fmt(0))
		}

********************************************************************************
* Share of in-laws who heard about the incentive
********************************************************************************

* Import data
u "$data\waveIII_young_women_sample", clear 

* keep sample
keep if endline==1 & girls_washedout==0 & before_miss==0
sum received_oil_il if oil==0

cd "$dof"
