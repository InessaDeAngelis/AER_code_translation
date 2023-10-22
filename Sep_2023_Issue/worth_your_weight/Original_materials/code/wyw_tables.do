	***************************************************************************	
	
	* Produces main tables for "Worth Your Weight" (Macchi)
	* Last updated: March 25 2023 
	* EM
	
	***************************************************************************
	
	// MAIN TABLES
	
	***************************************************************************
	
		
	**# Table 1
	
	use $path/input/wyw_summarystats.dta, clear	
			
	****************************************************************************
	
	global INDCHR   dis1 dis2 dis3 age gender bmi educ_years n_family_mbrs ///
					s1 s2 s3 s4 s5 role_loan_off role_loan_owner role_loan_manager ///
					perf_pay experience_years int_rate_discretion fin_know_self ///
					action_1 action_2 action_3 action_4 action_5 action_6 action_7 ///
					action_8 action_9 ///
					days_verify n_meet n_qualify tier1  tier3 tier2 tier4 ///
					instit_branches instit_size both_loans ///
				    int_rate1m int_rate5m int_rate7m 
					
	order $INDCHR
	
	****************************************************************************
	// initialize matrix
	
	set emptycells drop
	set matsize 11000
	mata: mata clear
	
	// locals to loop over group-specific variables			
	local INDCHR1  dis1 dis2 dis3 age gender bmi educ_years n_family_mbrs ///
					s1 s2 s3 s4 s5 
					
	local INDCHR2  dis1 dis2 dis3 age gender bmi educ_years n_family_mbrs ///
					s1 s2 s3 s4 s5 role_loan_off role_loan_owner role_loan_manager ///
					perf_pay experience_years int_rate_discretion ///
					action_1 action_2 action_3 action_4 action_5 action_6 action_7 ///
					action_8 action_9 days_verify n_meet 
					
	local INDCHR3  dis1 dis2 dis3 tier1  tier3 tier2 tier4 instit_branches ///
					instit_size both_loans ///
				    int_rate1m int_rate5m int_rate7m 
	
	// set number of groups	
	local tot_number_groups 3
		
	// Loop over groups to create mean and standard deviation tables
	
	forval n = 1 / `tot_number_groups' {

		// Mean of group 1
		cap drop s`n'_*
		local i = 1

		foreach var in `INDCHR`n'' {
			qui reg `var' if idrole==`n'
			gen s`n'_`var'=e(sample)
			outreg, keep(_cons) rtitle("`: var label `var''") stats(b) ///
				noautosumm store(row`i')  nostar bdec(2)
			outreg, replay(mean`n') append(row`i') ctitles("", "M `n' ") ///
				store(mean`n') note("") nostar 
			local ++i
		}
		
		outreg, replay(mean`n') nostar

		//SD for group 1
		local count: word count `INDCHR`n''
		mat sumstat`n' = J(`count'+1 ,1,.)

		local i = 1
		foreach var in `INDCHR`n'' {
			quietly: summarize `var' if idrole==`n' & s`n'_`var'==1
			mat sumstat`n'[`i',1] = r(sd)
			local i = `i' + 1
		}

		
		frmttable, statmat(sumstat`n') store(sumstat`n') sfmt(f,f,f,f)  varlabels
		
		// merge mean and sd table
		outreg, replay(mean`n') merge(sumstat`n') store(meansd`n') nostar

	}
	
	// Save # obs to include as row
	count if idrole==1
	local num1: dis %6.0fc `r(N)'
	
	count if idrole==2
	local num2: dis %6.0fc `r(N)'
	
	count if idrole==3
	local num3: dis %6.0fc `r(N)'
	
	// merge first two groups of tables 
	outreg, replay(meansd1) merge(meansd2) store(sumstat12) nostar fragment tex

	
	// merge with third table
	outreg using $path/output/tables/_table1_summary_stats.tex, ///
		replay(sumstat12) merge(meansd3) tex nocenter nostar fragment plain replace ///
		ctitles( "", Beliefs Experiment , "",  Credit Experiment \ ///
		"", "" , "",  "", "", "" \ ///
		Variables , "\textit{General population}", " ", "\textit{Loan officers}", " ", "\textit{Institutions}" \ ///
		"", Mean, SD, Mean, SD, Mean, SD) ///
		multicol(1,2,2;1,4,4;3,2,2;3,4,2;3,6,2) addrows("Observations",  "`num1'", "" , "`num2'", "" ,  "`num3'" )  bdec(2 2 2 2) 
		
	
**# Table 2  ----------------------------------------------------------------
	
	use $path/input/wyw_beliefs_main.dta, clear 
	
	local outcomes1 wealth_1b attr_1b health_1b lifeexp_1b selfcontrol_1b ability_1b trust_1b
	local outcomes2 wealth_2b attr_2b health_2b lifeexp_2b selfcontrol_2b ability_2b trust_2b
	local coefs     1.pic_high_bm 1.other_signal 1.pic_high_bm#1.other_signal
	
	* panel a - 1st order beliefs
	foreach var of local outcomes1 {
		eststo `var': reghdfe z_`var' i.pic_high_bm##i.other_signal, ///
			absorb(respondent_id pic_n order) vce (cluster respondent_id)
		sum `var' if pic_high_bm==0
		estadd scalar depvarmean = r(mean)
		sum `var', detail		
		estadd scalar depvarsd   = r(sd)

	}

	esttab  `outcomes1' using $path/output/tables/tab2a_firstorderbeliefs.tex, ///
		 nostar keep(`coefs') replace label nonotes ///
		 s(N depvarmean depvarsd, label("Observations" "Control mean: non-obese" "Standard deviation") fmt( %15.0fc 2 2)) ///
		 nomti nonum  f sfmt(%9.0fc %4.3f) b(%5.3f) se(%5.3f) nolines booktabs
	eststo clear
	
	* panel b - 2sd order beliefs
	foreach var of local outcomes2 {
		eststo `var': reghdfe z_`var' i.pic_high_bm##i.other_signal, ///
			absorb(respondent_id pic_n order) vce (cluster respondent_id)	
		sum `var' if pic_high_bm==0
		estadd scalar depvarmean = r(mean)
		sum `var', detail		
		estadd scalar depvarsd   = r(sd)
	}

	esttab  `outcomes2' using $path/output/tables/tab2b_firstorderbeliefs.tex, ///
		nostar keep(`coefs') replace label nonotes ///
		 s(N depvarmean depvarsd, label("Observations" "Control mean: non-obese" "Standard deviation") fmt(%15.0fc 2 2)) ///
	     nomti nonum f sfmt(%9.0fc %4.3f) b(%5.3f) se(%5.3f) nolines booktabs
		
	eststo clear
	
**# Table 3 -----------------------------------------------------------------

	use "$path/input/wyw_credit.dta", clear 
	
	local OUTCOME_VARS qualify credit prod meet trust

	foreach var of local OUTCOME_VARS {

		eststo `var': reghdfe z_`var' i.app_high_bm##i.financial_info, ///
			absorb(loanofficer_id app_id) vce(cluster loanofficer_id)

		sum `var' if app_high_bm==0
		estadd scalar depvarmean = r(mean)
		sum `var', detail		
		estadd scalar depvarsd   = r(sd)
		
		if "`var'" == "trust" {
			continue
		}
		else {
			test 1.app_high_bm + 1.app_high_bm#1.financial_info =0
			estadd scalar p_sum = r(p)
		}
	
	
	}
		
	esttab `OUTCOME_VARS' using $path/output/tables/tab3_obesitypremium.tex, ///
		width(\hsize) nostar keep(1.app_high_bm 1.financial_info 1.app_high_bm#1.financial_info) ///
		replace label nonotes ///
		stat(N depvarmean depvarsd p_sum, fmt(%15.0fc 3 3 3 )  ///
		label("Observations" "Control mean: not obese" ///
			  "Standard deviation" ///
			  "\makecell{\textit{p}-value: Obese + \\ Obese x Financial Information =0}" )) ///  
		nolines nonotes nomti nonum noobs f sfmt(%9.0fc %4.3f) b(%5.3f) se(%5.3f) booktabs

	
**#  Table  4 ----------------------------------------------------------------
	
	use $path/input/wyw_credit.dta, clear 

	local OUTCOME_VARS qualify credit prod meet 

	foreach var of local OUTCOME_VARS {
		eststo `var': reghdfe z_`var' i.app_high_bm##i.app_info_wealth, ///
			absorb(loanofficer_id app_id) vce(cluster loanofficer_id)
		test 1.app_high_bm + 1.app_high_bm#1.app_info_wealth =0
		estadd scalar p_sum1 = r(p)
		test 1.app_high_bm + 1.app_high_bm#2.app_info_wealth =0
		estadd scalar p_sum2 = r(p)
		
		sum `var' if app_high_bm==0
		estadd scalar depvarmean = r(mean)
		sum `var', detail		
		estadd scalar depvarsd   = r(sd)

	}
	
	esttab  `OUTCOME_VARS' using $path/output/tables/tab4_obesitypremiumbytype.tex, ///
		 keep(1.app_high_bm 1.app_info_wealth 2.app_info_wealth 1.app_high_bm#1.app_info_wealth 1.app_high_bm#2.app_info_wealth) ///
		 stats(N depvarmean depvarsd p_sum1 p_sum2, fmt(%15.0fc 3 3 3 3) ///
		 labels("Observations" "Control mean: non-obese" ///
			  "Standard deviation" ///
			  "\makecell{\textit{p}-value:  Obese + \\ Obese x High DTI = 0}" ///
			  "\makecell{\textit{p}-value: Obese + \\ Obese x Low DTI = 0}")) ///
		 replace label nostar nolines nomti nonum f b(%5.3f) se(%5.3f) booktabs
		 
	
	
**# ! Compile Latex Shells ! ****************************************************
	
	do $path/code/latex_scheletons.do
	

	