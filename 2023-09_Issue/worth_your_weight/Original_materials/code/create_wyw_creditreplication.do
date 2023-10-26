**# Credit experiment replication with laypeople
	
	use $path/rawdata/wyw_beliefs_guessappratings_clean.dta, clear
	
	destring respondent_id, replace 
	
//	label var app_n         "Profile order in arm"
	label var app_id        "Profile ID"
	label var app_reason    "Profile reason for loan"
	label var app_male      "Profile sex (male)"
	label var app_high_bm   "Profile bmi (obese)"
	label var app_pic_filename   "Profile portrait filename"
	label var app_age 		"Profile age"
	label var app_profile   "Profile loan amount"
	
	
	// create laypeople guesses variables
	
	* Approval Likelihood
	
	cap drop count_r*
	g count_r1 = (loan_lkh_score ==1)
	g count_r2 = (loan_lkh_score ==2)
	g count_r3 = (loan_lkh_score ==3)
	g count_r4 = (loan_lkh_score ==4)
	g count_r5 = (loan_lkh_score ==5)
	
	bys app_high_bm app_id: egen sum_r1 = mean(count_r1)
	bys app_high_bm app_id: egen sum_r2 = mean(count_r2)
	bys app_high_bm app_id: egen sum_r3 = mean(count_r3)
	bys app_high_bm app_id: egen sum_r4 = mean(count_r4)
	bys app_high_bm app_id: egen sum_r5 = mean(count_r5)

	local vars sum_r1 sum_r2 sum_r3 sum_r4 sum_r5
	
	cap drop m2
	egen double m2= rowmax(sum_r1 sum_r2 sum_r3 sum_r4 sum_r5)
	

	cap drop wanted
	gen wanted="" 
	foreach var of local vars {
	replace wanted = "`var'" if m2==`var'
	}
	drop m2
	
	cap drop most_frequent_approval_lkh_lay 
	g most_frequent_approval_lkh_lay =.
	replace most_frequent_approval_lkh_lay = 1 if wanted=="sum_r1" 
	replace most_frequent_approval_lkh_lay = 2 if wanted=="sum_r2" 
	replace most_frequent_approval_lkh_lay = 3 if wanted=="sum_r3" 
	replace most_frequent_approval_lkh_lay = 4 if wanted=="sum_r4" 
	replace most_frequent_approval_lkh_lay = 5 if wanted=="sum_r5" 
		
	* Referral Request
	g referral_lkh = share_referrals/10
	
	// labels
	label var referral_lkh "Referral request"
	label var most_frequent_approval_lkh_lay "Approval likelihood"
	label var loan_worth_apply  "Worth applying"
	label var app_high_bm "Obese"

	save $path/input/wyw_beliefs_guessappratings.dta, replace
