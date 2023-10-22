	
use "Data/Input/AD_input.dta", clear

destring *, replace

rename q2 gender
replace gender = 0 if gender == 1
replace gender = 1 if gender == 2
label define gg 0 "male" 1 "female"
label values gender gg
label var gender "gender"

rename q3 age
label var age "age"

rename q49 age_death
label var age_death "expected age at death"


rename q47 risk_learn
replace risk_learn = 1 if risk_learn == 23
replace risk_learn = 0 if risk_learn == 24
label define risk_learn_ 0 "no" 1 "yes"
label values risk_learn risk_learn_
label var risk_learn "learn if at least one risky allele"

rename q46 safe_learn
replace safe_learn = 1 if safe_learn == 23
replace safe_learn = 0 if safe_learn == 24
label define safe_learn_ 0 "no" 1 "yes"
label values safe_learn safe_learn_
label var safe_learn "learn if at least one protective allele"

rename q48 exact_learn
replace exact_learn = 1 if exact_learn == 23
replace exact_learn = 0 if exact_learn == 24
label define exact_learn_ 0 "Avoiders" 1 "Takers"
label values exact_learn exact_learn_
label var exact_learn "learn exact apoE allele combination"

rename q55_1 risk_chance
label var risk_chance "chance at least one risky allele"

rename q56_1 safe_chance
label var safe_chance "chance at least one protective allele"

rename q22 family_hx
replace family_hx = 1 if family_hx == 5
replace family_hx = 0 if family_hx == 6
label define family_hx_ 0 "no" 1 "yes"
label values family_hx family_hx_
label var family_hx "first-degree relatives dx w/ AD"

rename q23 risk_other
label define risk_other_ 1 "Yes, I have been diagnosed with it" 2 "I suspect I am at a very high risk of developing the disease" 3 "No particular reason to think I have a heightened risk, but I still worry" 4 "No, I have no reason to think I am at a higher risk than the average person" 
label values risk_other risk_other_
label var risk_other "other reasons for risk of AD"


** variables re: willingness to take test
*recode 1 2 into 1 0 to so 0 reflects rejection
forval i = 1/11 {
	foreach v in q511_`i' q521_`i' q531_`i' {
		replace `v' = 0 if `v' == 2
	}
}

label define test_ 1 "yes" 0 "no"	

rename q511_1 risk_paid50
label values risk_paid50 test_
label var risk_paid50 "Test for risky gene if paid $50"

rename q511_2 risk_paid25
label values risk_paid25 test_
label var risk_paid25 "Test for risky gene if paid $25"

rename q511_3 risk_paid15
label values risk_paid15 test_
label var risk_paid15 "Test for risky gene if paid $15"	

rename q511_4 risk_paid10
label values risk_paid10 test_
label var risk_paid10 "Test for risky gene if paid $10"

rename q511_5 risk_paid5
label values risk_paid5 test_
label var risk_paid5 "Test for risky gene if paid $5"

rename q511_6 risk_pay0
label values risk_pay0 test_
label var risk_pay0 "Test for risky gene if free"

rename q511_7 risk_pay5
label values risk_pay5 test_
label var risk_pay5 "Test for risky gene if pay $5"

rename q511_8 risk_pay10
label values risk_pay10 test_
label var risk_pay10 "Test for risky gene if pay $10"

rename q511_9 risk_pay15
label values risk_pay15 test_
label var risk_pay15 "Test for risky gene if pay $15"

rename q511_10 risk_pay25
label values risk_pay25 test_
label var risk_pay25 "Test for risky gene if pay $25"

rename q511_11 risk_pay50
label values risk_pay50 test_
label var risk_pay50 "Test for risky gene if pay $50"

gen risk_wtp = .
replace risk_wtp = -50 if risk_paid50 == 0
replace risk_wtp = (-25-50)/2 if risk_paid50 == 1
replace risk_wtp = (-15-25)/2 if risk_paid25 == 1
replace risk_wtp = (-10-15)/2 if risk_paid15 == 1
replace risk_wtp = (-5-10)/2 if risk_paid10 == 1
replace risk_wtp = (0-5)/2 if risk_paid5 == 1
replace risk_wtp = (5+0)/2 if risk_pay0 == 1
replace risk_wtp = (10+5)/2 if risk_pay5 == 1
replace risk_wtp = (15+10)/2 if risk_pay10 == 1
replace risk_wtp = (15+25)/2 if risk_pay15 == 1
replace risk_wtp = (25+50)/2 if risk_pay25 == 1
replace risk_wtp = 50 if risk_pay50 == 1
label var risk_wtp "WTP for Negative Skew"



rename q521_1 safe_paid50
label values safe_paid50 test_
label var safe_paid50 "Test for protective gene if paid $50"

rename q521_2 safe_paid25
label values safe_paid25 test_
label var safe_paid25 "Test for protective gene if paid $25"

rename q521_3 safe_paid15
label values safe_paid15 test_
label var safe_paid15 "Test for protective gene if paid $15"	

rename q521_4 safe_paid10
label values safe_paid10 test_
label var safe_paid10 "Test for protective gene if paid $10"

rename q521_5 safe_paid5
label values safe_paid5 test_
label var safe_paid5 "Test for protective gene if paid $5"

rename q521_6 safe_pay0
label values safe_pay0 test_
label var safe_pay0 "Test for protective gene if free"

rename q521_7 safe_pay5
label values safe_pay5 test_
label var safe_pay5 "Test for protective gene if pay $5"

rename q521_8 safe_pay10
label values safe_pay10 test_
label var safe_pay10 "Test for protective gene if pay $10"

rename q521_9 safe_pay15
label values safe_pay15 test_
label var safe_pay15 "Test for protective gene if pay $15"

rename q521_10 safe_pay25
label values safe_pay25 test_
label var safe_pay25 "Test for protective gene if pay $25"

rename q521_11 safe_pay50
label values safe_pay50 test_
label var safe_pay50 "Test for protective gene if pay $50"

gen safe_wtp = .
replace safe_wtp = -50 if safe_paid50 == 0
replace safe_wtp = (-25-50)/2 if safe_paid50 == 1
replace safe_wtp = (-15-25)/2 if safe_paid25 == 1
replace safe_wtp = (-10-15)/2 if safe_paid15 == 1
replace safe_wtp = (-5-10)/2 if safe_paid10 == 1
replace safe_wtp = (0-5)/2 if safe_paid5 == 1
replace safe_wtp = (5+0)/2 if safe_pay0 == 1
replace safe_wtp = (10+5)/2 if safe_pay5 == 1
replace safe_wtp = (15+10)/2 if safe_pay10 == 1
replace safe_wtp = (15+25)/2 if safe_pay15 == 1
replace safe_wtp = (25+50)/2 if safe_pay25 == 1
replace safe_wtp = 50 if safe_pay50 == 1
label var safe_wtp "WTP for Positive Skew"



rename q531_1 exact_paid50
label values exact_paid50 test_
label var exact_paid50 "Test for exact gene if paid $50"

rename q531_2 exact_paid25
label values exact_paid25 test_
label var exact_paid25 "Test for exact gene if paid $25"

rename q531_3 exact_paid15
label values exact_paid15 test_
label var exact_paid15 "Test for exact gene if paid $15"	

rename q531_4 exact_paid10
label values exact_paid10 test_
label var exact_paid10 "Test for exact gene if paid $10"

rename q531_5 exact_paid5
label values exact_paid5 test_
label var exact_paid5 "Test for exact gene if paid $5"

rename q531_6 exact_pay0
label values exact_pay0 test_
label var exact_pay0 "Test for exact gene if free"

rename q531_7 exact_pay5
label values exact_pay5 test_
label var exact_pay5 "Test for exact gene if pay $5"

rename q531_8 exact_pay10
label values exact_pay10 test_
label var exact_pay10 "Test for exact gene if pay $10"

rename q531_9 exact_pay15
label values exact_pay15 test_
label var exact_pay15 "Test for exact gene if pay $15"

rename q531_10 exact_pay25
label values exact_pay25 test_
label var exact_pay25 "Test for exact gene if pay $25"

rename q531_11 exact_pay50
label values exact_pay50 test_
label var exact_pay50 "Test for exact gene if pay $50"

gen exact_wtp = .
replace exact_wtp = -50 if exact_paid50 == 0
replace exact_wtp = (-25-50)/2 if exact_paid50 == 1
replace exact_wtp = (-15-25)/2 if exact_paid25 == 1
replace exact_wtp = (-10-15)/2 if exact_paid15 == 1
replace exact_wtp = (-5-10)/2 if exact_paid10 == 1
replace exact_wtp = (0-5)/2 if exact_paid5 == 1
replace exact_wtp = (5+0)/2 if exact_pay0 == 1
replace exact_wtp = (10+5)/2 if exact_pay5 == 1
replace exact_wtp = (15+10)/2 if exact_pay10 == 1
replace exact_wtp = (15+25)/2 if exact_pay15 == 1
replace exact_wtp = (25+50)/2 if exact_pay25 == 1
replace exact_wtp = 50 if exact_pay50 == 1
label var exact_wtp "WTP for Full Info"

* determine single-point switches only
foreach x in "risk" "safe" "exact" {
	gen `x'_consistency = 1

	replace `x'_consistency = 0 if `x'_paid50 == 0 & (`x'_paid25 == 1 | `x'_paid15 == 1 | `x'_paid10 == 1 | `x'_paid5 == 1 | ///
	`x'	_pay0 == 1 | `x'_pay5 == 1 | `x'_pay10 == 1 | `x'_pay15 == 1 | `x'_pay25 == 1 | `x'_pay50 == 1)
	
	replace `x'_consistency = 0 if `x'_paid25 == 0 & (`x'_paid15 == 1 | `x'_paid10 == 1 | `x'_paid5 == 1 | ///
	`x'	_pay0 == 1 | `x'_pay5 == 1 | `x'_pay10 == 1 | `x'_pay15 == 1 | `x'_pay25 == 1 | `x'_pay50 == 1)
	
	replace `x'_consistency = 0 if `x'_paid15 == 0 & (`x'_paid10 == 1 | `x'_paid5 == 1 | ///
	`x'	_pay0 == 1 | `x'_pay5 == 1 | `x'_pay10 == 1 | `x'_pay15 == 1 | `x'_pay25 == 1 | `x'_pay50 == 1)
	
	replace `x'_consistency = 0 if `x'_paid10 == 0 & (`x'_paid5 == 1 | ///
	`x'	_pay0 == 1 | `x'_pay5 == 1 | `x'_pay10 == 1 | `x'_pay15 == 1 | `x'_pay25 == 1 | `x'_pay50 == 1)
	
	replace `x'_consistency = 0 if `x'_paid5 == 0 & (`x'	_pay0 == 1 | `x'_pay5 == 1 | `x'_pay10 == 1 | ///
	`x'_pay15 == 1 | `x'_pay25 == 1 | `x'_pay50 == 1)
	
	replace `x'_consistency = 0 if `x'_pay0 == 0 & (`x'_pay5 == 1 | `x'_pay10 == 1 | ///
	`x'_pay15 == 1 | `x'_pay25 == 1 | `x'_pay50 == 1)
	
	replace `x'_consistency = 0 if `x'_pay5 == 0 & (`x'_pay10 == 1 | ///
	`x'_pay15 == 1 | `x'_pay25 == 1 | `x'_pay50 == 1)
	
	replace `x'_consistency = 0 if `x'_pay10 == 0 & (`x'_pay15 == 1 | `x'_pay25 == 1 | `x'_pay50 == 1)
	
	replace `x'_consistency = 0 if `x'_pay15 == 0 & (`x'_pay25 == 1 | `x'_pay50 == 1)
	
	replace `x'_consistency = 0 if `x'_pay25 == 0 & (`x'_pay50 == 1)
}

egen no_switching = rowmin(risk_consistency safe_consistency exact_consistency)
label var no_switching "Single point switchers only"
* 56 switchers 

keep exact_learn risk_learn  safe_learn *_wtp   no_switching  safe_p* risk_p* exact_p* age age_death gender
 
 label data "This file contains Alzheimer's Disease Study Results for Replication"
 
save "Data/Output/alzheimer.dta", replace
