/************************************
Project:    A Signal to End Child Marriage: Theory and Experimental Evidence from Bangladesh
File Name:  2_balance.do
Purpose:    Create balance table
************************************/

/* Notes:
	
	Prepare wave I balance tables
	
*/

clear
set more off

set scheme s2color, permanently
set pformat %5.4f, permanently

cap log close
log using "$logs\2_balance_$date_string", replace

* BASELINE BALANCE -- CENSUS
********************************************************************************
	
* All girls and unmarried girls only
forval i=0/1{

	u "$data\waveIII", clear

	* Keep the age range
	qui: keep if bl_age_reported>=14 & bl_age_reported<=16

	* Convert in percent for the table
	foreach var of varlist bl_ever_married bl_still_in_school older_sister bl_public_transit{
		qui: replace `var'=`var'*100
	}
	
	* List the variables to be included for all girls and unmarried girls only
	if `i'==0{
		local keep "bl_ever_married bl_age_reported bl_still_in_school"
		local level "all"
	}
	if `i'==1 {
		local keep "bl_age_reported bl_still_in_school older_sister bl_education_mother bl_HHsize bl_public_transit"
		local level "unmarried"
		* Keep only unmarried girls
		qui: keep if bl_ever_married==0
	}
	
	* Specify the variables for the joint hypotheses test
	local joint ""
	foreach var in `keep'{
		local joint `joint' "(`var' at1 at2 at3)"
	} 
	forval at=1/4{
		local test`at' ""
		foreach var in `keep'{
			local test`at' `test`at'' "[`var']at`at'"
		}
	}
	
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
						
		* Statistics to be exported: Number of observations, mean (sd), beta (p-value), p-value from joint significance test, pairwise significance
		forval s=1/5{
							
			* Store the statistics for the entire sample and each treatment arm, at1: Empowerment, at2: Incentive, at3: Empowerment+Incentive, at4: Control
			forval at=0/4{
				
				preserve
				
				* For each statistic, specify how to format the export
				
				* Keep treatment subsample (unless we are interested in the regression coefficients)
				if `s'<3{
					if `at'!=0{
						qui keep if at`at'==1
					}
				}
				
				* Determine the statistics to be outputted
				if `s'==1{
					local stat "stats(`var'_Nat`at', labels(, none) fmt(%9.0fc)) cells(none)"
					local keepvar ""
				}
				if `s'==2{
					local stat "cells(mean(fmt(2)) sd(par fmt(2)))"
					local keepvar ""
				}
				if `s'==3{
					local stat "cells(b(fmt(2)) p(par fmt(2)))"
				}	
				if `s'==4{
					local stat "stats(`var'_pvalat`at', labels(, none) fmt(2)) cells(none)"
					local keepvar ""
				}

				* Start storing values
				qui estpost sum `var'
				qui est store `var'

				* Store the number of observations
				if `s'==1{
					qui count
					qui scalar `var'_Nat`at'=r(N)
					qui est store `var'
					qui estadd scalar `var'_Nat`at'
				}
				
				* Run the regression for beta (p-value)
				if `s'==3 & `at'!=0 & `at'!=4{
					eststo `var': qui reg `var' at1 at2 at3, cluster(CLUSTER)
					local keepvar "keep(at`at')"
				}
				
				* Test for joint significance
				if `s'==4 & `at'!=0 & `at'!=4 & `loop'==1{

					qui sureg `joint'
					qui suregr, cluster(CLUSTER) minus(1)
					qui test `test`at''
					qui scalar `var'_pvalat`at'=`r(p)'
					qui est store `var'
					qui estadd scalar `var'_pvalat`at'
				}

				* Export the statistics -- do this only once for the sample size and joint hypothesis
				if (`s'!=1 & `s'!=4) | `loop'==1{
					cap estout `var' ///
						using "$tables\Balance\balance`s'_at`at'_`level'.tex", `action' style(tex)  ///
						`stat' `keepvar' ///
						mlabels(, none) collabels(, none) eqlabels(, none) varlabels(none)
						eststo clear
				}
				
				if `s'==5{
					local reg1 "at2 at3" 
					local reg2 "at1 at3"
					local reg3 "at1 at2"
					forval r=1/3{
						qui: reg `var' `reg`r'' if at4==0, cluster(CLUSTER)
						matrix values=r(table)
						forval j=1/2{
							local p`j'=values[4,`j']
							if `p`j''<0.1{
								display "sig (`p`j'') in `var': `j' in `reg`r''"
							}
						}
					}
				}
				
				restore
			}
		}

	}    
				
}


* BASELINE BALANCE -- SUBSAMPLE
********************************************************************************
	
* All girls and unmarried girls only
u "$data\waveIII_young_women_sample", clear

* Keep the age range
qui: keep if bl_age_reported>=14 & bl_age_reported<=16

* Convert in percent for the table
foreach var of varlist bl_ever_married bl_still_in_school older_sister bl_public_transit bl_stunted{
	qui: replace `var'=`var'*100
}

* List the variables to be included
local keep "bl_age_reported bl_still_in_school older_sister bl_education_mother bl_HHsize bl_public_transit bl_bmi bl_stunted bl_income"

* Specify the variables for the joint hypotheses test
local joint ""
foreach var in `keep'{
	local joint `joint' "(`var' at1 at2 at3)"
} 
forval at=1/4{
	local test`at' ""
	foreach var in `keep'{
		local test`at' `test`at'' "[`var']at`at'"
	}
}

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
					
	* Statistics to be exported: Number of observations, mean (sd), beta (p-value), p-value from joint significance test, pairwise significance
	forval s=1/5{
						
		* Store the statistics for the entire sample and each treatment arm, at1: Empowerment, at2: Incentive, at3: Empowerment+Incentive, at4: Control
		forval at=0/4{
			
			preserve
			
			* For each statistic, specify how to format the export
			
			* Keep treatment subsample (unless we are interested in the regression coefficients)
			if `s'<3{
				if `at'!=0{
					qui keep if at`at'==1
				}
			}
			
			* Determine the statistics to be outputted
			if `s'==1{
				local stat "stats(`var'_Nat`at', labels(, none) fmt(%9.0fc)) cells(none)"
				local keepvar ""
			}
			if `s'==2{
				local stat "cells(mean(fmt(2)) sd(par fmt(2)))"
				local keepvar ""
			}
			if `s'==3{
				local stat "cells(b(fmt(2)) p(par fmt(2)))"
			}	
			if `s'==4{
				local stat "stats(`var'_pvalat`at', labels(, none) fmt(2)) cells(none)"
				local keepvar ""
			}

			* Start storing values
			qui estpost sum `var'
			qui est store `var'

			* Store the number of observations
			if `s'==1{
				qui count
				qui scalar `var'_Nat`at'=r(N)
				qui est store `var'
				qui estadd scalar `var'_Nat`at'
			}
			
			* Run the regression for beta (p-value)
			if `s'==3 & `at'!=0 & `at'!=4{
				eststo `var': qui reg `var' at1 at2 at3, cluster(CLUSTER)
				local keepvar "keep(at`at')"
			}
			
			* Test for joint significance
			if `s'==4 & `at'!=0 & `at'!=4 & `loop'==1{

				qui sureg `joint'
				qui suregr, cluster(CLUSTER) minus(1)
				qui test `test`at''
				qui scalar `var'_pvalat`at'=`r(p)'
				qui est store `var'
				qui estadd scalar `var'_pvalat`at'
			}

			* Export the statistics -- do this only once for the sample size and joint hypothesis
			if (`s'!=1 & `s'!=4) | `loop'==1{
				cap estout `var' ///
					using "$tables\Balance\balance`s'_at`at'_ss.tex", `action' style(tex)  ///
					`stat' `keepvar' ///
					mlabels(, none) collabels(, none) eqlabels(, none) varlabels(none)
					eststo clear
			}
			
			if `s'==5{
				local reg1 "at2 at3" 
				local reg2 "at1 at3"
				local reg3 "at1 at2"
				forval r=1/3{
					qui: reg `var' `reg`r'' if at4==0, cluster(CLUSTER)
					matrix values=r(table)
					forval j=1/2{
						local p`j'=values[4,`j']
						if `p`j''<0.1{
							display "sig (`p`j'') in `var': `j' in `reg`r''"
						}
					}
				}
			}
			
			restore
		}
	}

}    
