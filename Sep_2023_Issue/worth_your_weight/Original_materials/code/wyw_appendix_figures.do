********************************************************************************	
	
	
	* Produces appendix figures for "Worth Your Weight" (Macchi)
	* Last updated: March 25 2023 
	* EM

********************************************************************************

	
	
	
	
	
*** MAIN APPENDIX FIGURES ******************************************************
	
	
**# Figure A1 -----------------------------------------------------------------
	
	use $path/input/wyw_credit.dta, clear 
	twoway hist app_bm_value if app_high_bm==0,     ///
		 color(gs1*0.3)  width(1)  || ///
		 hist app_bm_value if app_high_bm==1,  ///
		 width(1)  color(black*0.9) xline(30) ///
		 ytitle("Portraits' share") ///
		 legend(order(1 "Thinner version" 2 "Fatter version") pos(12) ///
		 row(1)) start(18) xlabel(18(4)46) ylabel(0(0.1)0.4, format(%03.1f)) 
		 
	graph export $path/output/figures/figA1_portraitsbmidistribution.pdf, replace	
	
	
**# Figure A2

	use $path/input/wyw_laypeople_sample2.dta, clear  
	graph hbar, allc over(reasons_want_gain) ytitle("Percentage respondents") ///
		title("First reason mentioned (open ended)") 
		
	graph export $path/output/figures/figA2_hist_whygain.pdf, replace

	
	
*** ONLINE APPENDIX FIGURES
**# Figure G5 -----------------------------------------------------------------
	
	use $path/input/wyw_credit.dta, clear 
    keep loanofficer_id financial_info want_more_info z_qualify z_credit ///
		z_prod z_trust z_meet app_arm app_high_bm app_id 

	* declare variables:

	global treat app_high_bm
	global controls  i.app_id i.app_arm
	global error absorb(loanofficer_id) vce(cluster loanofficer_id)
	
	
	* NOTE: uncomment to run randomization inference (this takes some time)
	
	local OUTCOME_VARS  z_meet z_qualify z_credit z_prod

	foreach var of local OUTCOME_VARS {

		global y `var'

		preserve
		
		// compute actual results ATE

		reghdfe $y $treat $controls, $error
		scalar ate = _b[$treat] 
		global ate ate
		
		test $treat
		scalar pvalue = r(p)
		global pvalue pvalue

		
	    // randomization inference
		
		simulate beta=r(beta), reps(10000): randomization_inference, share(0.5) alpha(0.05)  
		
		g ate = $ate
		save $path/output/ri_$y.dta, replace 
		restore
	
	}

	global z_meet "Referral request"
	global z_qualify "Approval likelihood"
	global z_credit "Creditworthiness"
	global z_prod "Financial ability"
	
	local OUTCOME_VARS z_qualify z_credit z_prod z_meet
	foreach var of local OUTCOME_VARS {

		use $path/output/ri_`var'.dta, replace
		
		cap drop greater
		g greater = beta > ate
		sum greater
		
		local ripvalue : di %6.3f `r(mean)'

		sum ate	
		hist beta, xline(`r(mean)') xtitle("") ytitle($`var') color(black*0.7) ///
			percent subtitle("{it:p} value = `ripvalue'")
		
		graph export $path/output/figures/figG5_hist_ri_`var'.pdf, replace


		}
**# Figure G6-----------------------------------------------------------------
	
	use $path/input/wyw_malawi.dta, clear 
	
	est clear
	matrix U = J(5, 3, .)
	mat colnames U =  "section" "beta" "se"

	forvalues j = 1(1)5{
		
			qui reg outcome_`j' pic
			mat U[`j',1] = `j'
			mat U[`j',2] = round(_b[pic], .001)
			mat U[`j',3] = _se[pic]
		
			}

				
	mat list U
	svmat double U, names(matcol)

	cap drop upperci
	cap drop lowerci
	gen upperci = Ubeta + (1.96*Use)
	gen lowerci = Ubeta - (1.96*Use)

	cap drop number
	gen number = Usection
	label var number " "

	twoway  rcap upperci lowerci number, vertical lstyle(ci) lcolor(gs8) ///
				mlab(Usection) mlabgap(18) mlabsize(tiny) || ///
			rcap upperci lowerci number if number==1 |  number==2 , vertical lstyle(ci) lcolor(orange) ///
				mlab(Usection) mlabgap(18) mlabsize(tiny) pstyle(p7) || ///
	scatter Ubeta number,  mlabel(Ubeta) mlabposition(1)  m(i) mlabsize(small) ///
				mlabcolor(gs1) mcolor(gs8)  msymbol(d)  msize(medlarge)  || ///
	scatter Ubeta number  if number==1 | number==2, pstyle(p7)  m(i) mlabsize(small) mlabcolor(orange)  ///
				msymbol(d) msize(medlarge)  lstyle(ci) lcolor(pink) mcolor(orange)  ///
				yline(0, lpattern(solid) lcolor(red))  legend(off) mlabposition(1) ylabel(-.2 (.2) 0.8, format(%03.1f))  ///
				ytitle("Obesity coefficient (SD)") xlabel( 0 " " 1 "Wealth" ///
				2 "Credit" 3 "Authority" 4 "Dating" 5 "Beauty" 6 " ", labsize(small) angle(90) )

	graph export $path/output/figures/figG6_beliefs_malawi.pdf, replace

	
**# Figure G7 -----------------------------------------------------------------
	use $path/rawdata/wyw_mturk_clean.dta, clear 

	est clear
	matrix U = J(9, 3, .)
	mat colnames U =  "section" "beta" "se"

	forvalues j = 1(1)9{
		
			qui reghdfe rating t_bmi_num if outcome_type ==`j', absorb(round) cluster(player_id)
			mat U[`j',1] = `j'
			mat U[`j',2] = round(_b[t_bmi_num], .001)
			mat U[`j',3] = _se[t_bmi_num]
		
			}
				
	mat list U
	svmat double U, names(matcol)

	cap drop upperci
	cap drop lowerci
	gen upperci = Ubeta + (1.96*Use)
	gen lowerci = Ubeta - (1.96*Use)


	cap drop number
	gen number = Usection
	label var number " "

	twoway  rcap upperci lowerci number if number>3 & number!=8, vertical lstyle(ci) lcolor(gs8) ///
				mlab(Usection) mlabgap(18) mlabsize(tiny) || ///
			rcap upperci lowerci number if number==1 |  number==8 , vertical lstyle(ci) lcolor(orange) ///
				mlab(Usection) mlabgap(18) mlabsize(tiny) pstyle(p7) || ///
			rcap upperci lowerci number if number==2 | number==3 , vertical lstyle(ci) lcolor(navy) ///
				mlab(Usection) mlabgap(18) mlabsize(tiny) pstyle(p7) || ///
	scatter Ubeta number if number>3 & number!=8,  mlabel(Ubeta) mlabposition(1)  m(i) mlabsize(small) ///
				mlabcolor(gs1) mcolor(gs8)  msymbol(s)  msize(medlarge)  || ///
	scatter Ubeta number if number==2 | number==3,  mlabel(Ubeta) mlabposition(1)  m(i) mlabsize(small) ///
				mlabcolor(gs1) mcolor(navy)  msymbol(o)  msize(medlarge)  || ///
	scatter Ubeta number  if number==1 | number==8, mlabel(Ubeta) pstyle(p7)  m(i) mlabsize(small) mlabcolor(gs1)  ///
				msymbol(d) msize(medlarge)  lstyle(ci) lcolor(pink) mcolor(orange)  ///
				yline(0, lpattern(solid) lcolor(red))  legend(off) mlabposition(1) ylabel(-.8 (.2) 0.4, format(%03.1f))  ///
				ytitle("Obesity coefficient (SD)") xlabel( 0 " " 1 "Wealth" 2 "Beauty" 3 "Health" 4 "Life expectancy" ///
		5 "Self-control" 6 "Ability" 7 "Trust" 8 "Credit" 9 "Lend" 10 " ", labsize(small) angle(90) )

				
	graph export $path/output/figures/figG7_belief_mturk.pdf, replace

**# Figure G8 -----------------------------------------------------------------
	
	use $path/input/wyw_beliefs_guessappratings.dta, clear
	destring respondent_id, replace 
	
	preserve
	use $path/input/wyw_credit.dta, replace
		
	*Referral Request (average meeting request)
	sum meet if app_arm==1 
	sca meet_mean = `r(mean)'
	sca meet_sd = `r(sd)'
	
	global meet_mean meet_mean
	global meet_sd meet_sd
	
	sum qualify if app_arm==1
	sca qualify_mean = `r(mean)'   
	sca qualify_sd = `r(sd)'
	
	global qualify_mean qualify_mean
	global qualify_sd qualify_sd
	
	*Approval likelihood (Most Frequent)
	foreach i of num 1/5 {
		g count_r`i' = (qualify ==`i' & app_arm==1) 
		bys app_high_bm app_id: egen sum_r`i' = mean(count_r`i')

	}
	
	local vars sum_r1 sum_r2 sum_r3 sum_r4 sum_r5
	cap drop m2
	egen double m2= rowmax(sum_r1 sum_r2 sum_r3 sum_r4 sum_r5)

	cap drop wanted
	gen wanted="" 
	foreach var of local vars {
	replace wanted = "`var'" if m2==`var'
	}
	drop m2

	cap drop most_frequent_approval_lkh 
	
	
	g most_frequent_approval_lkh =.
	foreach i of num 2/5 {
		replace most_frequent_approval_lkh = `i' if wanted=="sum_r`i'" 

	}
	
	encode app_profile, g(app_loan_amount)
	g app_smallloan = app_loan_amount ==1

	
	encode app_reason, g(app_loan_type)
	g app_businessloan = app_loan_type ==1

	
	* approval
	reghdfe most_frequent_approval_lkh app_businessloan app_smallloan app_male app_age app_high_bm if app_arm==1, absorb(loanofficer_id) vce(cluster loanofficer_id)  
	
	sca est_qual1 = round(_b[app_businessloan], .001)
	sca sd_qual1 = _se[app_businessloan]
	
	sca est_qual2 = round(_b[app_smallloan], .001)
	sca sd_qual2 = _se[app_smallloan]
	
	sca est_qual3 = round(_b[app_male], .001)
	sca sd_qual3 = _se[app_male]
	
	sca est_qual4 = round(_b[app_age], .001)
	sca sd_qual4 = _se[app_age]
	
	* referral request
	reghdfe meet app_businessloan app_businessloan app_smallloan app_male app_age app_high_bm if app_arm==1, absorb(loanofficer_id) vce(cluster loanofficer_id)   	
	
	sca est_meet1 = round(_b[app_businessloan], .001)
	sca sd_meet1 = _se[app_businessloan]
	
	sca est_meet2 = round(_b[app_smallloan], .001)
	sca sd_meet2 = _se[app_smallloan]
	
	sca est_meet3 = round(_b[app_smallloan], .001)
	sca sd_meet3 = _se[app_smallloan]	
	
	sca est_meet4 = round(_b[app_age], .001)
	sca sd_meet4 = _se[app_age]
		
	foreach i of num 1/4 {
		global est_meet`i' est_meet`i'
		global sd_meet`i' sd_meet`i'

		global est_qual`i' est_qual`i'
		global sd_qual`i' sd_qual`i'
	
	}
	
	restore
	
	est clear
	matrix U = J(2, 9, .)
	mat colnames U =  "section" "beta1" "se1" "beta2" "se2" "beta3" "se3" "beta4" "se4"
		
	mat U[1,1] = 1
	mat U[1,2] = $est_qual1
	mat U[1,3] = $sd_qual1
	mat U[1,4] = $est_qual2
	mat U[1,5] = $sd_qual2
	mat U[1,6] = $est_qual3
	mat U[1,7] = $sd_qual3
	mat U[1,8] = $est_qual4
	mat U[1,9] = $sd_qual4
	
	mat U[2,1] = 2
	mat U[2,2] = $est_meet1
	mat U[2,3] = $sd_meet1
	mat U[2,4] = $est_meet2
	mat U[2,5] = $sd_meet2	
	mat U[2,6] = $est_meet3
	mat U[2,7] = $sd_meet3	
	mat U[2,8] = $est_meet4
	mat U[2,9] = $sd_meet4

	mat list U
	svmat double U, names(matcol)

	cap drop upperci*
	cap drop lowerci*
	
	foreach i of num 1/4 { // 4 explanatory vars
		
		gen upperci`i' = Ubeta`i' + ( 1.96*Use`i')
		gen lowerci`i' = Ubeta`i' - ( 1.96*Use`i')
		
	}

	cap drop number
	gen number = Usection

	label var number " "
	
	// LAYPEOPLE Predictions  
	
	* Approval Likelihood
	cap drop count_r*
	cap drop sum_r*

	foreach i of num 1/5 {
		g count_r`i' = (loan_lkh_score ==`i')
		bys app_high_bm app_id: egen sum_r`i' = mean(count_r`i')

	}

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
		foreach i of num 2/5 {
				replace most_frequent_approval_lkh_lay = `i' if wanted=="sum_r`i'" 

	}
	
	* Referral request
	cap drop referral_lkh
	g referral_lkh = share_referrals/10
	
	
	* labels
	label var referral_lkh "Referral request"
	label var most_frequent_approval_lkh_lay "Approval likelihood"
	label var loan_worth_apply  "Worth applying"
	label var app_high_bm "Obese"
	
	// Storing Matrix Laypeople
	
	g outcome_1 = most_frequent_approval_lkh_lay
	g outcome_2 = referral_lkh
	g outcome_3 = loan_worth_apply
	
	
	encode app_profile, g(app_loan_amount)
	g app_smallloan = app_loan_amount ==1

	
	encode app_reason, g(app_loan_type)
	g app_businessloan = app_loan_type ==1

	
	est clear
	matrix V = J(2, 9, .)
	mat colnames V =  "section" "beta1" "se1" "beta2" "se2" "beta3" "se3" "beta4" "se4"


	forvalues j = 1(1)2{
		
			qui reghdfe outcome_`j' app_businessloan app_smallloan app_male app_age app_high_bm, absorb(respondent_id) vce(cluster respondent_id)		
			mat V[`j',1] = `j'
			mat V[`j',2] = round(_b[app_businessloan], .001)
			mat V[`j',3] = _se[app_businessloan]
			mat V[`j',4] = round(_b[app_smallloan], .001)
			mat V[`j',5] = _se[app_smallloan]			
			mat V[`j',6] = round(_b[app_male], .001)
			mat V[`j',7] = _se[app_male]
			mat V[`j',8] = round(_b[app_age], .001)
			mat V[`j',9] = _se[app_age]
			}

	mat list V
	svmat double V, names(matcol)
	
	
	cap drop Vupperci*
	cap drop Vlowerci*
	
	foreach i of num 1/4 {
		gen Vupperci`i' = Vbeta`i' + ( 1.96*Vse`i')
		gen Vlowerci`i' = Vbeta`i' - ( 1.96*Vse`i')
		
	}

	cap drop numberV
	gen numberV = Vsection
	label var numberV " "
	
	
	// Figure Panel A
	replace  number = number +1.5
	twoway	scatter Vbeta1 numberV if numberV ==1, mlabel(Vbeta1) mlabposition(1)  m(i) mlabsize(medsmall) ///
				   msymbol(o) msize(large) mlabcolor(gs1) color(navy)  || ///
			scatter Ubeta1 number if number ==2.5, mlabel(Ubeta1) mlabposition(1)  m(i) mlabsize(medsmall) ///
				   msymbol(s)  msize(large) mlabcolor(gs1) color(orange)  || ///
			rcap Vupperci1 Vlowerci1 numberV if numberV ==1, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
				mlab(Vsection) mlabgap(18) mlabsize(tiny) || ///
			rcap upperci1 lowerci1 number if number ==2.5, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
				mlab(Vsection) mlabgap(18) mlabsize(tiny) ///
				legend(off) ///
				xlabel( 0 " " 1  "Predicted (Laypeople)" 2.5 "Actual (Loan officers)"  3.5 " ")  ///
				ytitle("Coefficient (SD)") ///
				name(business, replace) title("Business loan")   ylabel(, format(%03.2f))
				
	twoway	scatter Vbeta2 numberV if numberV ==1, mlabel(Vbeta2) mlabposition(1)  m(i) mlabsize(medsmall) ///
			   msymbol(o) msize(large) mlabcolor(gs1) color(navy)  || ///
		scatter Ubeta2 number if number ==2.5, mlabel(Ubeta2) mlabposition(1)  m(i) mlabsize(medsmall) ///
			   msymbol(s)  msize(large) mlabcolor(gs1) color(orange)  || ///
		rcap Vupperci2 Vlowerci2 numberV if numberV ==1, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
			mlab(Vsection) mlabgap(18) mlabsize(tiny) || ///
		rcap upperci2 lowerci2 number if number ==2.5, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
			mlab(Vsection) mlabgap(18) mlabsize(tiny) ///
			legend(off) ///
			xlabel( 0 " " 1  "Predicted (Laypeople)" 2.5 "Actual (Loan officers)"  3.5 " ")  ///
			ytitle("Coefficient (SD)") ///
			name(amount, replace) title("Small loan")  ylabel(, format(%03.2f))
			
	
	twoway	scatter Vbeta3 numberV if numberV ==1, mlabel(Vbeta3) mlabposition(1)  m(i) mlabsize(medsmall) ///
		   msymbol(o) msize(large) mlabcolor(gs1) color(navy)  || ///
			scatter Ubeta3 number if number ==2.5, mlabel(Ubeta3) mlabposition(1)  m(i) mlabsize(medsmall) ///
				   msymbol(s)  msize(large) mlabcolor(gs1) color(orange)  || ///
			rcap Vupperci3 Vlowerci3 numberV if numberV ==1, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
				mlab(Vsection) mlabgap(18) mlabsize(tiny) || ///
			rcap upperci3 lowerci3 number if number ==2.5, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
				mlab(Vsection) mlabgap(18) mlabsize(tiny) ///
				legend(off) ///
				xlabel( 0 " " 1  "Predicted (Laypeople)" 2.5 "Actual (Loan officers)"  3.5 " ")  ///
				ytitle("Coefficient (SD)") ///
				name(male, replace) title("Male")  ylabel(, format(%03.2f))


	twoway	scatter Vbeta4 numberV if numberV ==1, mlabel(Vbeta4) mlabposition(1)  m(i) mlabsize(medsmall) ///
			   msymbol(o) msize(large) mlabcolor(gs1) color(navy)  || ///
	scatter Ubeta4 number if number ==2.5, mlabel(Ubeta4) mlabposition(1)  m(i) mlabsize(medsmall) ///
			   msymbol(s)  msize(large) mlabcolor(gs1) color(orange)  || ///
		rcap Vupperci4 Vlowerci4 numberV if numberV ==1, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
			mlab(Vsection) mlabgap(18) mlabsize(tiny) || ///
		rcap upperci4 lowerci4 number if number ==2.5, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
			mlab(Vsection) mlabgap(18) mlabsize(tiny) ///
			legend(off) ///
			xlabel( 0 " " 1 "Perceived (Laypeople)" 2.5 "Actual (Loan officers)"  3.5 " ")  ytitle(" ") ///
			ytitle("Coefficient (SD)") ///
			name(age, replace) title("Age")  ylabel(, format(%03.2f))
	graph combine business amount male age, name(laypredictions, replace) b1title(Approval likelihood)

	graph export $path/output/figures/figG8a_laypredictions_otherchrs_approval.pdf, replace
	
	
	// Figure Panel B
	twoway	scatter Vbeta1 numberV if numberV ==2, mlabel(Vbeta1) mlabposition(1)  m(i) mlabsize(medsmall) ///
			   msymbol(o) msize(large) mlabcolor(gs1) color(navy)  || ///
		scatter Ubeta1 number if number ==3.5, mlabel(Ubeta1) mlabposition(1)  m(i) mlabsize(medsmall) ///
			   msymbol(s)  msize(large) mlabcolor(gs1) color(orange)  || ///
		rcap Vupperci1 Vlowerci1 numberV if numberV ==2, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
			mlab(Vsection) mlabgap(18) mlabsize(tiny) || ///
		rcap upperci1 lowerci1 number if number ==3.5, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
			mlab(Vsection) mlabgap(18) mlabsize(tiny) ///
			legend(off) ///
			xlabel( 1 " " 2 "Perceived (Laypeople)" 3.5 "Actual (Loan officers)"  4.5 " ")  ytitle(" ") ///
			ytitle("Coefficient (SD)") ///
			name(business, replace) title("Business loan")  ylabel(, format(%03.2f))
			
	twoway	scatter Vbeta2 numberV if numberV ==2, mlabel(Vbeta2) mlabposition(1)  m(i) mlabsize(medsmall) ///
			   msymbol(o) msize(large) mlabcolor(gs1) color(navy)  || ///
		scatter Ubeta2 number if number ==3.5, mlabel(Ubeta2) mlabposition(1)  m(i) mlabsize(medsmall) ///
			   msymbol(s)  msize(large) mlabcolor(gs1) color(orange)  || ///
		rcap Vupperci2 Vlowerci2 numberV if numberV ==2, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
			mlab(Vsection) mlabgap(18) mlabsize(tiny) || ///
		rcap upperci2 lowerci2 number if number ==3.5, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
			mlab(Vsection) mlabgap(18) mlabsize(tiny) ///
			legend(off) ///
			xlabel( 1 " " 2 "Perceived (Laypeople)" 3.5 "Actual (Loan officers)"  4.5 " ")  ytitle(" ") ///
			ytitle("Coefficient (SD)") ///
			name(amount, replace) title("Small loan")  ylabel(, format(%03.2f))

	twoway	scatter Vbeta3 numberV if numberV ==2, mlabel(Vbeta3) mlabposition(1)  m(i) mlabsize(medsmall) ///
			   msymbol(o) msize(large) mlabcolor(gs1) color(navy)  || ///
		scatter Ubeta3 number if number ==3.5, mlabel(Ubeta3) mlabposition(1)  m(i) mlabsize(medsmall) ///
			   msymbol(s)  msize(large) mlabcolor(gs1) color(orange)  || ///
		rcap Vupperci3 Vlowerci3 numberV if numberV ==2, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
			mlab(Vsection) mlabgap(18) mlabsize(tiny) || ///
		rcap upperci3 lowerci3 number if number ==3.5, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
			mlab(Vsection) mlabgap(18) mlabsize(tiny) ///
			legend(off) ///
			xlabel( 1 " " 2 "Perceived (Laypeople)" 3.5 "Actual (Loan officers)"  4.5 " ")  ytitle(" ") ///
			ytitle("Coefficient (SD)") ///
			name(male, replace) title("Male ")  ylabel(, format(%03.2f))

	twoway	scatter Vbeta4 numberV if numberV ==2, mlabel(Vbeta4) mlabposition(1)  m(i) mlabsize(medsmall) ///
			   msymbol(o) msize(large) mlabcolor(gs1) color(navy)  || ///
	scatter Ubeta4 number if number ==3.5, mlabel(Ubeta4) mlabposition(1)  m(i) mlabsize(medsmall) ///
			   msymbol(s)  msize(large) mlabcolor(gs1) color(orange)  || ///
		rcap Vupperci4 Vlowerci4 numberV if numberV ==2, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
			mlab(Vsection) mlabgap(18) mlabsize(tiny) || ///
		rcap upperci4 lowerci4 number if number ==3.5, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
			mlab(Vsection) mlabgap(18) mlabsize(tiny) ///
			legend(off) ///
			xlabel( 1 " " 2 "Perceived (Laypeople)" 3.5 "Actual (Loan officers)"  4.5 " ")  ytitle(" ") ///
			ytitle("Coefficient (SD)") ///
			name(age, replace) title("Age") 


	graph combine business amount male age, name(laypredictions, replace) b1title(Referral request)
	graph export $path/output/figures/figG8b_laypredictions_otherchrs_referral.pdf, replace



	
	
