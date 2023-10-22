/************************************
Project:    A Signal to End Child Marriage: Theory and Experimental Evidence from Bangladesh
File Name:  4_summ_tables.do
Purpose: 	Create summary table
************************************/

/* Notes:
	
	Prepare wave III summary table
	
*/

clear
set more off
estimates clear

set scheme s2color, permanently
set pformat %5.4f, permanently

cap log close
log using "$logs\4_summ_stats_$date_string", replace

* SUMMARY STATS TABLE 
********************************************************************************

* Import data
u "$data\waveIII", clear

* Keep only analysis data
keep if endline==1 & washedout==0 & bl_age_reported<=16 & bl_age_reported>=14 & before_miss==0 & bl_ever_married==0

* Share of dowry
g has_dowry=dowry>0 if dowry!=.
sum has_dowry
replace dowry=. if dowry==0

* Convert in percent for the table
foreach var of varlist bl_rural has_primary has_secondary matchmaker matchmaker_3 ever_married under_18 under_16 ever_birth ever_birth_20 arranged_marriage outside_village still_in_school iga_yesno{
    replace `var'=`var'*100
	}

* Husband age variation
sum husband_age_reported	
	
* Community and individual characteristics	
forval i=0/2{

	preserve
	
	if `i'==0{
		local keep "hh_village bl_rural has_primary has_secondary matchmaker matchmaker_3"
		local level "vill"
	}
	if `i'==1 | `i'==2{
		local keep "el_age_predicted ever_married under_18 under_16 ever_birth ever_birth_20 dowry arranged_marriage age_gap outside_village still_in_school education iga_yesno"
		local level "individual"
	}
	if `i'==2{
		local level "individual15"
		keep if bl_age_reported==14
	}
	keep CLUSTER `keep'
	duplicates drop 

	local loop=0
	foreach var in `keep'{
		cap replace `var'=. if `var'_miss==1
		local loop=`loop'+1
		if `loop'==1{
			local action "replace"
		}
		if `loop'!=1{
			local action "append"
		}
		
		estpost sum `var'
		est store `var'
		
		foreach stat in mean sd{
			sum `var'
			scalar `var'_`stat'=r(`stat')
			est restore `var'
			estadd scalar `var'_`stat'
			estout `var' ///
				using "$tables\Summary\s`level'_`stat'.tex", `action' style(tex)  ///
				label cells(none) ///
				mlabels(, none) collabels(, none) eqlabels(, none) ///
				stats(`var'_`stat',labels(, none) fmt(1))
		}
	}
	restore
}


* TAKE-UP 
********************************************************************************
	
* All girls and unmarried girls only
u "$data\waveIII", clear

* Number of girls who received the oil
count if oil==1

* Keep the age range
qui: keep if bl_age_reported>=14 & bl_age_reported<=16 & bl_ever_married==0 & anylist==1

* Convert in percent for the table
foreach var of varlist bl_still_in_school older_sister bl_public_transit{
	qui: replace `var'=`var'*100
}
	
foreach var in distance_hh_vc distance_hh_ss bl_bmi bl_stunted bl_income{
	cap g `var'=.
	replace `var'=.
}	

* Statistics to be exported: Number of observations, mean (sd), beta (p-value)
forval s=1/3{
	// s=1: sample size
	// s=2: within-group mean and SD
	// s=3: beta and p-value from regression of var on treatment dummy
	estimates clear

	* Store the statistics for Control and Treatment
	forval level=0/1{
		estimates clear

		* Determine the statistics to be outputted
		if `s'==1{
			local stat "stats(bl_age_reported_Nat`level', labels(, none) fmt(%9.0fc)) cells(none)"
			local keepvar ""
		}
		if `s'==2{
			local stat "cells(mean(fmt(1)) sd(par fmt(1)))"
			local keepvar ""
		}
		if `s'==3{
			local stat "cells(b(fmt(1)) p(par fmt(2)))"
			local keepvar "drop(oil _cons)"
		}

		preserve
		
		* Keep treatment subsample (unless we are interested in the regression coefficients)
		if `s'<3{
			cap keep if oil==`level'
		}

		if `s'==1{
			cap replace bl_age_reported=. if bl_age_reported_miss==1
			
			estpost sum bl_age_reported
			est store bl_age_reported_e

			count
			scalar bl_age_reported_Nat`level'=r(N)
			est store bl_age_reported_e
			estadd scalar bl_age_reported_Nat`level'

			estout bl_age_reported_e ///
				using "$tables\Takeup\Takeup`s'_oil`level'.tex", replace style(tex)  ///
				`stat' `keepvar' ///
				mlabels(, none) collabels(, none) eqlabels(, none) varlabels(none)
				eststo clear
		}

		if `s'==2 {
			* storing estimate for first variable
			cap replace bl_age_reported=. if bl_age_reported_miss==1
	
			estpost sum bl_age_reported
			est store Takeup`s'_`level'
			sum bl_age_reported
			scalar bl_age_reported_`s'`level'_mean	=r(mean)
			scalar bl_age_reported_`s'`level'_sd	=r(sd)
			est restore Takeup`s'_`level'
			estadd scalar bl_age_reported_`s'`level'_mean
			estadd scalar bl_age_reported_`s'`level'_sd

			estout Takeup`s'_`level' ///
				using "$tables\Takeup\Takeup`s'_oil`level'.tex", replace style(tex)  ///
				`keepvar'	///
				mlabels(, none) collabels(, none) eqlabels(, none) varlabels(none)	///
				stats(bl_age_reported_`s'`level'_mean bl_age_reported_`s'`level'_sd, layout("@" "(@)") labels(, none) fmt(1))
		}

		if `s'==3 & `level'!=0{
			* storing estimate for first variable
			cap replace bl_age_reported=. if bl_age_reported_miss==1

			reg bl_age_reported oil, cluster(CLUSTER)
			est store n`s'_`level'
			reg bl_age_reported oil, cluster(CLUSTER)
			scalar bl_age_reported_`s'`level'_beta	=_b[oil]
			scalar bl_age_reported_`s'`level'_p	=r(table)[4,1]
			est restore n`s'_`level'
			estadd scalar bl_age_reported_`s'`level'_beta
			estadd scalar bl_age_reported_`s'`level'_p

			estout n`s'_`level' ///
				using "$tables\Takeup\Takeup`s'_oil`level'.tex", replace style(tex)  ///
				`keepvar'	///
				mlabels(, none) collabels(, none) eqlabels(, none) varlabels(none)	///
				stats(bl_age_reported_`s'`level'_beta bl_age_reported_`s'`level'_p, layout("@" "(@)") labels(, none) fmt(1 2))
		}

		* List the variables to be included for all girls and unmarried girls only
		local vars_to_loop "bl_still_in_school older_sister bl_education_mother bl_HHsize bl_public_transit village_distance distance_hh_vc distance_hh_ss bl_bmi bl_stunted bl_income"
		foreach var in `vars_to_loop' {
			if `s'==2 {
				cap replace `var'=. if `var'_miss==1

				if !("`var'"=="distance_hh_vc" | "`var'"=="distance_hh_ss" | "`var'"=="bl_bmi" | "`var'"=="bl_stunted" | "`var'"=="bl_income")   {
					cap sum `var'
					cap scalar `var'_`s'`level'_mean	=r(mean)
					cap scalar `var'_`s'`level'_sd		=r(sd)
					cap est restore Takeup`s'_`level'
					cap estadd scalar `var'_`s'`level'_mean
					cap estadd scalar `var'_`s'`level'_sd
				}
				if ("`var'"=="distance_hh_vc" | "`var'"=="distance_hh_ss" | "`var'"=="bl_bmi" | "`var'"=="bl_stunted" | "`var'"=="bl_income")   {
					cap sum `var'
					cap scalar `var'_`s'`level'_mean	=r(mean)
					cap est restore Takeup`s'_`level'
					cap estadd scalar `var'_`s'`level'_mean
				}

				cap estout Takeup`s'_`level' 	///
					using "$tables\Takeup\Takeup`s'_oil`level'.tex", append style(tex)  ///
					`keepvar'					///
					mlabels(, none) collabels(, none) eqlabels(, none) varlabels(none)	///
					stats(`var'_`s'`level'_mean `var'_`s'`level'_sd, layout("@" "(@)") labels(, none) fmt(1))
			}

			if `s'==3 {
				cap replace `var'=. if `var'_miss==1

				if !("`var'"=="distance_hh_vc" | "`var'"=="distance_hh_ss" | "`var'"=="bl_bmi" | "`var'"=="bl_stunted" | "`var'"=="bl_income")   {
					cap reg `var' oil, cluster(CLUSTER)
					cap scalar `var'_`s'`level'_beta	=_b[oil]
					cap scalar `var'_`s'`level'_p		=r(table)[4,1]
					cap est restore n`s'_`level'
					cap estadd scalar `var'_`s'`level'_beta
					cap estadd scalar `var'_`s'`level'_p
				}

				if ("`var'"=="distance_hh_vc" | "`var'"=="distance_hh_ss" | "`var'"=="bl_bmi" | "`var'"=="bl_stunted" | "`var'"=="bl_income")   {
					cap sum `var'
					cap scalar `var'_`s'`level'_beta	=r(mean)
					cap est restore Takeup`s'_`level'
					cap estadd scalar `var'_`s'`level'_beta
				}
				
				cap estout n`s'_`level' 	///
					using "$tables\Takeup\Takeup`s'_oil`level'.tex", append style(tex)  ///
					`keepvar'				///
					mlabels(, none) collabels(, none) eqlabels(, none) varlabels(none)	///
					stats(`var'_`s'`level'_beta `var'_`s'`level'_p, layout("@" "(@)") labels(, none) fmt(1 2))
			}
		}
		restore
	}
}

* TAKE-UP -- SUBSAMPLE
********************************************************************************
	
* All girls and unmarried girls only
u "$data\waveIII_young_women_sample", clear

* Keep the age range
qui: keep if bl_age_reported>=14 & bl_age_reported<=16 & bl_ever_married==0 

* Convert in percent for the table
foreach var of varlist bl_still_in_school older_sister bl_public_transit bl_stunted{
	qui: replace `var'=`var'*100
}
	
* List the variables to be included for all girls and unmarried girls only
local keep "bl_age_reported bl_still_in_school older_sister bl_education_mother bl_HHsize bl_public_transit village_distance distance_hh_vc distance_hh_ss bl_bmi bl_stunted bl_income"


* Foreach comparison
foreach comp in kk_member{
	
	local loop=0
	
	* Foreach variable
	foreach var in `keep'{
		
		* Replace with missing if it's a control variable
		cap replace `var'=. if `var'_miss==1
		local loop=`loop'+1
		
		* Create a new tex file in the first iteration and append for all later iterations
		if `loop'==1{
			local action "replace"
		}
		if `loop'!=1{
			local action "append"
		}
						
		* Statistics to be exported: Number of observations, mean (sd), beta (p-value)
		forval s=1/3{
							
			* Store the statistics for Control and Treatment
			forval level=0/1{
				
				preserve
				
				* Keep sample
				if "`comp'"=="oil"{
					cap: keep if anylist==1
				}
				if "`comp'"=="kk_attend"{
					cap: keep if anyemp==1
				}
				
				* Keep treatment subsample (unless we are interested in the regression coefficients)
				if `s'<3{
					cap keep if `comp'==`level'
				}
				
				* Determine the statistics to be outputted
				if `s'==1{
					local stat "stats(`var'_Nat`level', labels(, none) fmt(%9.0fc)) cells(none)"
					local keepvar ""
				}
				if `s'==2{
					local stat "cells(mean(fmt(1)) sd(par fmt(1)))"
					local keepvar ""
				}
				if `s'==3{
					local stat "cells(b(fmt(1)) p(par fmt(2)))"
				}	

				* Start storing values
				cap estpost sum `var'
				cap est store `var'

				* Store the number of observations
				if `s'==1{
					cap count
					cap scalar `var'_Nat`level'=r(N)
					cap est store `var'
					cap estadd scalar `var'_Nat`level'
				}
				
				* Run the regression for beta (p-value)
				if `s'==3 & `level'!=0{
					eststo `var': cap reg `var' `comp', cluster(CLUSTER)
					local keepvar "keep(`comp')"
				}
				
				* Export the statistics -- do this only once for the sample size and joint hypothesis
				if (`s'!=1) | `loop'==1{
					cap: estout `var' ///
						using "$tables\Takeup\Takeup`s'_`comp'`level'_ss.tex", `action' style(tex)  ///
						`stat' `keepvar' ///
						mlabels(, none) collabels(, none) eqlabels(, none) varlabels(none)
						eststo clear
				}
				
				restore
			}
		}

	}   
}


* OTHER SUMMARY STATS ACROSS THE PAPER
********************************************************************************

* Attitudes about Early Marriage
u "$data\waveIII_young_women_sample", clear 
cap replace bl_earliest_marry=. if bl_earliest_marry_miss==1
replace bl_earliest_marry=. if bl_earliest_marry>95
g bl_earliest_18=bl_earliest_marry<18 | bl_earliest_marry==95
replace bl_earliest_18=. if bl_earliest_marry==. 
sum bl_earliest_18 if bl_age_reported<=16 & bl_age_reported>=14
sum bl_earliest_marry_why_phys if bl_age_reported<=16 & bl_age_reported>=14

* Mentioned in Introduction
* Share of households that choose underage marriage not for all their daughters
u "$data\waveIII", clear
keep if endline==1 & washedout==0 & before_miss==0 & bl_ever_married==0
drop if under_18==. 
bys HHID: g girls=_N
preserve
keep if treatment_type==4 & girls>1 
bys HHID: egen mean_marriage=mean(under_18)
keep HHID mean_marriage 
duplicates drop
g fraction_18=mean_marriage!=0 & mean_marriage!=1
sum fraction_18
restore

* Mentioned in Introduction, Section I, Section IV and Section V
* Girls marry outside village and sub-district
keep if bl_age_reported>=14 & bl_age_reported<=16
sum outside_village outside_union

* Mentioned in Section I
* Ability to discuss marriage with parents
u "$data\waveI_young_women_sample", clear
keep if bl_age_reported<=16 & bl_age_reported>=14 & bl_ever_married==0
replace bl_marriage_time_who=0 if bl_marriage_time_comfort==0 
tab bl_marriage_time_who if bl_treatment_type==4

* Marriage has dowry
u "$data\waveIII", clear
keep if endline==1 & washedout==0 & before_miss==0 & bl_ever_married==0 & bl_age_reported<=16 & bl_age_reported>=14
g has_dowry=dowry>0 if dowry!=.
sum has_dowry

* Mentioned in Section I
* Marriage has  denmeher and Mean denmeher
u "$data\waveIII_young_women_sample", clear 
keep if bl_age_reported<=16 & bl_age_reported>=14 & endline==1 & girls_washedout==0 & before_miss==0
g has_denmeher=denmeher>0 if denmeher!=.
sum has_denmeher denmeher

* Mentioned in Section I and II.E
* Girls marry outside sub-district
u "$data\waveIII", clear
keep if endline==1 & washedout==0 & before_miss==0 & bl_ever_married==0 & bl_age_reported>=14 & bl_age_reported<=16
sum outside_union

* Mentioned in Section I
* Desired marriage age of parents
u "$data\waveI_households", clear
keep if child==1

keep if age_reported<=16 & age_reported>=14 & ever_married==0
la var age_married_desired "Desired marriage age for daughter"
foreach var of varlist age_married_desired{
    sum `var'
}

* Mentioned in Section I
* Desired marriage age, earliest marriage age, reason is not physicially ready
u "$data\waveI_young_women_sample", clear
keep if bl_age_reported<=16 & bl_age_reported>=14 & bl_ever_married==0

foreach var of varlist bl_earlypreg bl_risks_earlypreg_* bl_latest_marry_why_*{
	replace `var'=`var'*100
	}
	
replace bl_desired_marriage_age=. if bl_desired_marriage_age>90
sum bl_desired_marriage_age
tab bl_earliest_marry
sum bl_earliest_marry_why_phys

* Mentioned in Section I
* Number of pregnancy risks identified
u "$data\waveIII_young_women_sample", clear 
replace pregnancy_risks=0 if pregnancy_risks==.
tab pregnancy_risks if treatment_type==4 & endline==1 & washedout==0 & before_miss==0 & bl_age_reported>=14

* Mentioned in Section I
* What determines timing of marriage
u "$data\waveI_households", clear
keep if child==1

keep if age_reported<=16 & age_reported>=14 & ever_married==0

foreach var of varlist economic_status adolescence_period sisters brothers school_skill right_spouse society_pressure reputation matchmaker{
	replace `var'=. if `var'==3
	replace `var'=`var'*100
}

graph hbar economic_status adolescence_period right_spouse sisters brothers school_skill matchmaker reputation society_pressure, ///
title("What influences your daughter's marriage timing?") ///
blabel(bar, format(%4.1f)) graphregion(color(white)) ///
legend(label(1 "Economic status") label(2 "Adoloscence age") label(3 "Sisters' marriage") label(4 "Finding right spouse") label(5 "Brothers' marriage") label(6 "Ability in school") label(7 "Matchmaker's suggestion") label(8 "Risk of bad name") label(9 "Pressure from society"))  ///
ylabel(0(20)100)

* Mentioned in Section I
* Reasons a girl should not marry late
u "$data\waveI_young_women_sample", clear
keep if bl_age_reported<=16 & bl_age_reported>=14 & bl_ever_married==0
foreach var of varlist bl_latest_marry_why*{
	di "`var'"
	sum `var'
}

* Share of women reporting meeting her husband before marriage
u "$data\waveIII_young_women_sample", clear
keep if endline==1 & washedout==0 & before_miss==0 & bl_age_reported>=14 & bl_age_reported<=16
sum met_hus_pre_mar

* desired characteristics by women in a husband
u "$data\waveIII_young_women_sample", clear
keep if endline==1 & washedout==0 & before_miss==0

ds char_marriage*
local i=0
foreach var in `r(varlist)'{
	local i=`i'+1
	ren `var' character`i'
	replace character`i'=character`i'*100
} 
replace character6=100 if character2==100
drop character7 character2

keep character*

foreach num of numlist 1 3 5 8 13{
	ren character`num' SC`num'
}

g n=_n
reshape long character SC, i(n) j(category)
la def character 1 "Age" 3 "Education" 4 "Good Family" 5 "Looks" 6 "Nature/Character" 8 "Income" 9 "Religion and Tradition" 10 "Reputation" 11 "Responsibility" 12 "Romantic Compatibility" 13 "Wealth", replace
la val category SC character
g order=. 
local order=0
foreach num of numlist 8 6 3 11 5 12 13 9 4 1 10 {
	local order=`order'+1
	replace order=`order' if category==`num'
}

rename SC reported_dummy
sum reported_dummy if category==8


* Mentioned in Section II.D
* Observations from Muladi subdistrict dropped because of rumors
u "$data\waveI_young_women_sample", clear
count if upcode==69				// number of girls
unique CLUSTER if upcode==69	// number of villages

* Mentioned in Section II.E
* Average income, married and in school
u "$data\waveIII", clear
keep if endline==1 & washedout==0 & before_miss==0 & bl_ever_married==0 & bl_age_reported>=14 & bl_age_reported<=16
sum income_lastmonth if iga_yesno==1
sum ever_married if still_in_school==1

* Mentioned in Section II.E
* Married girls in secondary school at midline
u "$data\waveII", clear
keep if midline==1 & washedout==0 & before_miss==0 & bl_age_reported>=14
sum ml_still_in_school if ml_ever_married==1

* Mentioned in Section IV
* Standard deviation in husband's age
u "$data\waveIII", clear
keep if endline==1 & washedout==0 & before_miss==0 & bl_ever_married==0 & bl_age_reported>=14 & bl_age_reported<=16
sum husband_age_reported

* Mentioned in Section IV.A
* Man to woman ratio
u "$data\waveIII", clear
keep if bl_ever_married==0
preserve
keep CLUSTER bl_girl_boy_ratio
duplicates drop
g bl_boy_girl_ratio=1/bl_girl_boy_ratio
sum bl_girl_boy_ratio
restore

* Mentioned in Section IV.B 
* Difference in income by SC
u "$data\waveIII_young_women_sample", clear 
keep if bl_age_reported<=16 & bl_age_reported>=14 & endline==1 & girls_washedout==0 & before_miss==0
forval i=0/1{
	sum bl_income if high_g_cons==`i'
	local cons`i'=`r(mean)'
}
local diff=`cons0'-`cons1'

* Mentioned in Section IV.B 
* Expected dowry at baseline
replace bl_dowry_amnt=bl_dowry_amnt/41.794
sum bl_dowry_amnt
local dowry=`r(mean)'
sum bl_income
local income=12*`r(mean)'
local perc=`diff'/`dowry'
di `perc'

* Mentioned in Section IV.C
* Value of transfer as percentage of expected dowry and income
local dowry_perc=16/`dowry'
local income_perc=16/`income'
di "dowry: `dowry_perc', income: `income_perc'"


* Mentioned in Section V
* Share of in-laws in non-incentive community who reported woman to have received the incentive
u "$data\waveIII_young_women_sample", clear 
keep if endline==1 & girls_washedout==0 & before_miss==0
sum received_oil_il if oil==0


* number of non-incentive communities within 500 meters of incentive communities
u "$data\waveIII", clear
unique CLUSTER if vill_radius_500_oil==1 & anyoil==0


* CHECK MARRIAGE AGE REPORTING
********************************************************************************

u "$data\waveIII_young_women_sample", clear

keep if endline==1 & bl_age_reported>=14 & bl_age_reported<=16 & washedout==0 & before_miss==0

g has_certificate=marriage_age3!=. 
preserve
keep if ever_married==1
reg has_certificate anyemp anyoil oil_kk i.unionID i.third, cluster(CLUSTER)
restore

forval c=1/3{
	
	preserve
	
	* Create the comparison groups (the marriage ages to be compared)
	local var1: word `c' of c_marriage_age c_marriage_age marriage_age1
	local var2: word `c' of marriage_age1 marriage_age3 marriage_age3
	
	* Create differences
	g diff_month=12*(`var1'-`var2')
	replace diff_month=. if `var1'==. | `var2'==.
	count if diff_month!=.
		
	forval i=0/4{
		if `i'==0{
			local keep "if treatment_type!=."
		}
		if `i'!=0{
			local keep "if treatment_type==`i'"
		}

		foreach stat in mean sd{	
			estpost summ diff_month `keep'
			est store diff_month_`i'
			estout diff_month_`i' ///
				using "$tables\Summary\Marriage_age\age`c'_`stat'_`i'.tex", replace style(tex)  ///
				label cells(`stat'(fmt(%9.1fc)))  ///
				mlabels(, none) collabels(, none) eqlabels(, none) varlab(,none) 
		}
	}
				
	reg diff_month at1 at2 at3, cluster(CLUSTER)
	est store diff_month

	forval i=1/3{
		est restore diff_month
		estout diff_month ///
			using "$tables\Summary\Marriage_age\age`c'_diff_`i'.tex", replace style(tex)  ///
			label cells(b(star fmt(%9.1fc)))  ///
			keep(at`i') ///
			mlabels(, none) collabels(, none) eqlabels(, none) varlab(,none) 
	}

restore

}


* TAKE-UP - Self-Reported (l: 1-3), 
* 			Incentive from Monitoring Data (l: 4-5), 
* 			Empowerment from Monitoring Data (l: 6)
********************************************************************************

forval l=1/6{
	
	preserve
		
	if `l'<=3{
		u "$data\waveIII_young_women_sample", clear
		keep if bl_age_reported>=10
		if `l'==1{
			local v "kk_attend"
		}
		if `l'==2 | `l'==3{
			local v "oil_received"
			keep if bl_age_reported>=14 & bl_age_reported<=16
			if `l'==3{
				keep if oil_sheet==1
			}
		}
	}
	if `l'==4 | `l'==5{
		u "$data\waveIII", clear
		keep if bl_age_reported<=16 & bl_age_reported>=14 & bl_ever_married==0
		local v "oil"
		replace oil=. if treatment_type==1 | treatment_type==4
		if `l'==5{
			keep if anylist==1
		}
	}
	if `l'==6 {
		u "$data\kk", clear	

		merge m:1 villagecode using "$data\village_treat"
		drop if _merge==2
		drop _merge
		g anyemp=treatment_type==1 | treatment_type==3
		g anyoil=treatment_type==2 | treatment_type==3

		collapse (max) enroll (mean) total_girls treatment_type anyemp anyoil, by(CLUSTER cycle)
		collapse (sum) enroll (mean) total_girls treatment_type anyemp anyoil, by(CLUSTER)
		collapse (sum) enroll total_girls, by(treatment_type anyemp anyoil)
		g enroll_rate=enroll/total_girls
		
		local v "enroll_rate"
		replace enroll_rate=. if treatment_type==2 | treatment_type==4

	}
	
	tempfile data
	save `data', replace

    estpost summ `v'
    est store `v'

	forval i=1/6{
		
		u `data', clear
		
		if `i'==1 | `i'==5{
			local action "replace"
		}
		if `i'!=1 & `i'!=5{
			local action "append"
		}
		
		if `i'==5{
			local treatment "anyemp"
		}
		if `i'==6{
			local treatment "anyoil"
		}

		if `l'==6 & `i'>=5{
			collapse (sum) enroll total_girls, by(`treatment')
			g enroll_rate=enroll/total_girls
		}
		tempfile new_data
		save `new_data', replace

		if `i'<=4{
			summ `v' if treatment_type==`i'
			local save "ind"
		}
		if `i'>=5{
			if (`l'==4 | `l'==5) & `i'==5{
				u `new_data', clear
				replace `v'=. if anyemp==1
			}
			if `l'==6 & `i'==6{
				u `new_data', clear
				replace `v'=. if anyoil==1
			}
			summ `v' if `treatment'==1
			local save "any"
		}

		scalar m_`v'_`i'=r(mean)*100
		est restore `v'
		estadd scalar m_`v'_`i'
		estout `v' using "$tables\Summary\Monitoring\m_`l'_`save'.tex", `action' style(tex) ///
			label cells(none) ///
			mlabels(, none) collabels(, none) eqlabels(, none) ///
			stats(m_`v'_`i',labels(, none) fmt(%9.1fc))	
	}
	restore
}
