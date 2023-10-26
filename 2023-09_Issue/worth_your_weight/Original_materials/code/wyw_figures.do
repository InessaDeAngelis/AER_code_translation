	***************************************************************************	
	* Produces main figures for "Worth Your Weight" (Macchi)
	* Last updated: March 25 2023 
	* EM
	


	
	** NOTE: Figure 1 is based on non publicly available DHS data, to reproduce 
	** first, download DHS data following instructions on README
	
	*******************************************************+********************

	/** Fig 1 *******************************************************************
	
	use $path/input/wyw_dhs_wealthquint.dta, clear
	
	// Figure 1 : Panel A
	preserve
	
	* low and lower-middle income countries
	keep if IG ==1 | CountryName=="India" | CountryName=="Ghana"  // Low income and lower middle income
	
	bys  CountryName WealthQuint: egen BMI30_mean_c = mean(BMI30)  
	bys  WealthQuint: egen average_quint = mean(BMI30)  
	
	
	twoway  line BMI30_mean_c WealthQuint if CountryName=="Bangladesh", lcolor(gs14) lstyle(solid)  || ///
            line BMI30_mean_c WealthQuint if CountryName=="Benin", lcolor(gs14) lstyle(solid)       || ///
			line BMI30_mean_c WealthQuint if CountryName=="Burkina Faso", lcolor(gs14) lstyle(solid)|| ///
			line BMI30_mean_c WealthQuint if CountryName=="Burundi", lcolor(gs14) lstyle(solid)     || ///
			line BMI30_mean_c WealthQuint if CountryName=="Cambodia", lcolor(gs14) lstyle(solid)    || ///
			line BMI30_mean_c WealthQuint if CountryName=="Cameroon", lcolor(gs14) lstyle(solid)    || ///
			line BMI30_mean_c WealthQuint if CountryName=="Comoros", lcolor(gs14) lstyle(solid)     || ///
			line BMI30_mean_c WealthQuint if CountryName=="Congo", lcolor(gs14) lstyle(solid)       || ///
			line BMI30_mean_c WealthQuint if CountryName=="Ethiopia", lcolor(gs14) lstyle(solid)    || ///
			line BMI30_mean_c WealthQuint if CountryName=="Gambia", lcolor(gs14) lstyle(solid)      || ///
			line BMI30_mean_c WealthQuint if CountryName=="Ghana", lcolor(gs14) lstyle(solid)       || ///
			line BMI30_mean_c WealthQuint if CountryName=="Guinea", lcolor(gs14) lstyle(solid)      || ///
			line BMI30_mean_c WealthQuint if CountryName=="Haiti", lcolor(gs14) lstyle(solid)       || ///
			line BMI30_mean_c WealthQuint if CountryName=="India", lcolor(gs14) lstyle(solid)       || ///
			line BMI30_mean_c WealthQuint if CountryName=="Ivory Coast", lcolor(gs14) lstyle(solid) || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Kenya", lcolor(gs14) lstyle(solid)       || ///
			line BMI30_mean_c WealthQuint if CountryName=="Liberia", lcolor(gs14) lstyle(solid)     || ///
			line BMI30_mean_c WealthQuint if CountryName=="Madagascar", lcolor(gs14) lstyle(solid)  || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Malawi", lcolor(gs14) lstyle(solid)      || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Mali", lcolor(gs14) lstyle(solid)        || ///
			line BMI30_mean_c WealthQuint if CountryName=="Mozambique", lcolor(gs14) lstyle(solid)  || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Nepal", lcolor(gs14) lstyle(solid)       || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Niger", lcolor(gs14) lstyle(solid)       || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Nigeria", lcolor(gs14) lstyle(solid)     || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Rwanda", lcolor(gs14) lstyle(solid)      || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Sierra Leone", lcolor(gs14) lstyle(solid) || ///
			line BMI30_mean_c WealthQuint if CountryName=="Tajikistan", lcolor(gs14) lstyle(solid)  || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Tanzania", lcolor(gs14) lstyle(solid)    || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Timor-Leste", lcolor(gs14) lstyle(solid) || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Togo", lcolor(gs14) lstyle(solid)        || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Uzbekistan", lcolor(gs14) lstyle(solid)  || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Zambia", lcolor(gs14) lstyle(solid)      || ///
		    line BMI30_mean_c WealthQuint if CountryName=="Zimbabwe",   lcolor(gs14) lstyle(solid)  || ///
			line average_quint WealthQuint, lcolor(red) lstyle(solid)  ||  ///
			line BMI30_mean_c WealthQuint if CountryName=="Uganda", lwidth(thick) lcolor(gs6) lstyle(solid)   ///
		   subtitle(, justification(center)) xlabel(1 "1st" 2 " " 3 " " 4 " " 5 "5th") ylabel(0(5)31) ///
		   xtitle(Wealth quintile)  ylabel(0(5)31) xsize(6) ///
		   graphregion(margin(2 10 2 2)) plotregion(margin(2 13 0 0)) ///
		   text(17 5.35   "Uganda", size(small)) ///
		   text(30.4 5.3  "Ghana", color(gs12) size(small))  ///
		   text(11 5.25   "India", color(gs12) size(small))  ///
		   text(18.5 5.35 "Nigeria", color(gs12) size(small))  ///
		   text(8 5.3     "Nepal", color(gs12) size(small))  ///
		   text(24 5.25 "Haiti", color(gs12) size(small))  legend(off) ytitle(Percent obese) 
		   
	graph export $path/output/figures/fig1A_gr_conn_obesitybyincome_lowincome.pdf, replace
	restore
    

	
	// Panel B
	
	bys IG WealthQuint: egen BMI30_mean = mean(BMI30)	
	
	twoway connected BMI30_mean WealthQuint if IG==1, lwidth(thick) msymbol(O) mcolor(gs6) lcolor(gs6) mcolor(gs6) lstyle(solid)   || ///
		   connected BMI30_mean WealthQuint if IG==2, lwidth(thick) msymbol(O) mcolor(gs6) lcolor(gs6) mcolor(gs6) lstyle(solid)   || ///
		   connected BMI30_mean WealthQuint if IG==3, lwidth(thick) msymbol(O) mcolor(gs6) lcolor(gs6) lwidth(thick) lstyle(solid)  ///
		   by(IG, col(15) note("") legend(off)) ytitle(Percent obese) ///
		   subtitle(, justification(center)) xtitle(Wealth quintile) ///
		   xlabel(1 "1st" 2 " " 3 " " 4 " " 5 "5th") ylabel(0(5)31)  ///
		   graphregion(margin(2 2 2 2)) plotregion(margin(2 10 0 0)) 
		   
		   
	graph export $path/output/figures/fig1B_gr_conn_obesitybyincome_aggregate.pdf, replace
	
*/

	** Fig 2 *******************************************************************
	
	use $path/input/wyw_beliefs_main.dta, clear 
	
	* panel A
	cibar wealth_1b if order<=3, over1(pic_high_bm) over2(info_treat) ///
	graphopts(ytitle("Wealth rating (1-4)") yscale(range(1(0.5)4 )) ylabel(1(0.5)4) ///
	legend(order(1 "Non-obese portraits" 2 "Obese portraits") size(medium) pos(12) row(1) ring(0)) ///
	xtitle("Additional information provided")) ///
	barcolor(gs13 black) bargap(10) baropts(fintensity(60)) 
	
	graph export $path/output/figures/fig2A_bar_bm_info_wealth.pdf, replace

	* panel B
	
    local outcomes z_wealth_1b z_attr_1b z_health_1b z_lifeexp_1b z_selfcontrol_1b z_ability_1b z_trust_1b // rename outcomes for matrix
	cap drop outcome_*
	forval j = 1/7{ 
		local outcome : word `j'  of  `outcomes'
		rename `outcome' outcome_`j' 
	}

	est clear
	matrix U = J(7, 3, .)
	mat colnames U =  "section" "beta" "se" 

	forvalues j = 1(1)7{
			qui reg outcome_`j' pic_high_bm i.pic_n i.respondent_id i.order ///
				i.other_signal, vce(cluster respondent_id)   		
			mat U[`j',1] = `j'
			mat U[`j',2] = round(_b[pic_high_bm], .001)
			mat U[`j',3] = _se[pic_high_bm]
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
			rcap upperci lowerci number if number==1, vertical lstyle(ci) lcolor(orange) ///
				mlab(Usection) mlabgap(18) mlabsize(tiny) pstyle(p7) || ///
	scatter Ubeta number,  mlabel(Ubeta) mlabposition(1)  m(i) mlabsize(small) mlabformat(%03.2f)  ///
				mlabcolor(gs1) mcolor(gs8)  msymbol(o)  msize(medlarge)  || ///
	scatter Ubeta number if number==1, pstyle(p7)  m(i) mlabsize(small) mlabformat(%03.2f) ///
				mlabcolor(orange)  msymbol(d) msize(medlarge)  lstyle(ci) lcolor(pink) mcolor(orange)  ///
				yline(0, lpattern(solid) lcolor(red))  legend(off) mlabposition(1) ylabel(-.2 (.2) 0.8, format(%03.1f))  ///
				ytitle("Obesity coefficient (SD)") xlabel( 0 " " 1 "Wealth" ///
				2 "Beauty" 3 "Health" 4 "Life expectancy" 5 "Self-control"  ///
				6 "Ability" 7 "Trustworthiness" 8 " ", labsize(small) angle(90) )

	graph export $path/output/figures/fig2B_belief1_all.pdf, replace
	
	
**# Fig 3 **********************************************************************

	use $path/input/wyw_credit.dta, clear 
	
	local outcomes qualify prod credit 
	foreach var of local outcomes{ 
		
			cibar `var', over(app_high_bm financial_info) ///
				graphopts( ytitle( , size(medlarge))  ytitle(`: variable label `var'') xtitle("Financial information") ///  
				legend(order(1 "Non-obese borrowers" 2 "Obese borrowers") size(medium)  cols(2) pos(12) ring(0) ) ///
				yscale(range(2.2(0.2)3)) ylabel(2.2(0.2)3, format(%03.1f)) name(g_left_`var', replace)) ///
				bargap(10)  level(95) barcolor(gs13 black) baropts(fintensity(70)) 
				
			binscatter `var' app_bm_value, nquantiles(10) controls(loanofficer_id app_id) 	///
				xline(25, lcolor(cranberry)) xline(30, lcolor(cranberry)) xline(35, lcolor(cranberry)) xline(40, lcolor(cranberry)) ///
				text(2.9 21 "Normal" "weight", place(n) size(medsmall) color(cranberry)) ///
				text(2.9 27.5 "Over-" "weight", place(n) size(medsmall) color(cranberry)) ///
				text(2.9 32.5 "Obesity" "class I" , place(n) size(medsmall) color(cranberry)) ///
				text(2.9 37.5 "Obesity" "class II", place(n) size(medsmall) color(cranberry))  ///
				text(2.9 42 "Obesity" "class III", place(n) size(medsmall) color(cranberry))  ///
				legend(off) title(" ")   xtitle("BMI", size(medlarge)) ///
				yscale(range(2.2(0.2)3)) ylabel(2.2(0.2)3, format(%03.1f)) ytitle(" ") ///
				graphregion(margin(0 3 1 0)) xscale(range(18.5(2)44)) xlabel(18(2)44, labsize(medsmall)) ///
				name(g_right_`var', replace) 
	
	}
	
	cibar meet, over(app_high_bm financial_info) ///
		graphopts(  ytitle(, size(medlarge))       ytitle(`: variable label meet')  xtitle("Financial information")  ///
		legend( order(1 "Non-obese borrowers" 2 "Obese borrowers" ) size(medium) cols(2) pos(12) ring(0) ) ///
		yscale(range(0.70(0.02)0.8)) ylabel(0.60(0.04)0.8, format(%03.2f)) name(g_left_meet, replace)) ///
		bargap(10)  level(95) barcolor(gs13 black gs13 black) baropts(fintensity(70)) 

	binscatter meet app_bm_value, nquantiles(10) controls(loanofficer_id app_id) 	///
		xline(25, lcolor(cranberry)) xline(30, lcolor(cranberry)) ///
		xline(35, lcolor(cranberry)) xline(40, lcolor(cranberry)) ///
		text(0.78 21.5 "Normal" "weight", place(n) size(medsmall) color(cranberry)) ///
		text(0.78 27.5 "Over-" "weight", place(n) size(medsmall) color(cranberry)) ///
		text(0.78 32.5 "Obesity" "class I" , place(n) size(medsmall) color(cranberry)) ///
		text(0.78 37  "Obesity" "class II", place(n) size(medsmall) color(cranberry))  ///
		text(0.78 42  "Obesity" "class III", place(n) size(medsmall) color(cranberry))  ///
		legend(off) title(" ")   xtitle("BMI", size(medlarge)) ///
		yscale(range(0.70(0.02)0.8)) ylabel(0.60(0.04)0.8, format(%03.2f)) ytitle(" ") ///
		graphregion(margin(0 3 1 0)) xscale(range(18.5(2)44)) xlabel(18(2)44, labsize(medsmall)) ///
		name(g_right_meet, replace) 
	

	* combine and export 
	
	local outcomes meet qualify prod credit 
	foreach var of local outcomes{ 
		graph combine g_left_`var' g_right_`var',   ycommon name(g_`var', replace) ///
		b1title("Borrower BMI")  xsize(7)
		
		graph export "$path/output/figures/fig3_gr_barmargins_`var'.pdf", replace

	}
	
**# Fig 4 **********************************************************************

	use $path/input/wyw_credit.dta, clear 

	* drop loan officers duplicates (each loan officers rates 30 profiles)
	drop if app_id >1 & app_id!=.
	
	* create cumulative beliefs
	egen explicit_33 = rowtotal(explicit_25 explicit_57)   // normalweight to BMI=33
	egen explicit_49 = rowtotal(explicit_25 explicit_57 explicit_79) // normalweight to BMI=49
	drop explicit_57 explicit_79

	* reshape
	reshape long explicit_, i(loanofficer_id) j(change)
	
	cibar explicit_, over1(change) barcolor(gs14 gs9 gs3) bargap(10) ///
		graphopts( ytitle("Share loan officers") ///
		yscale(range(0(0.2)1 )) ylabel(0(0.2)1, format(%03.1f)) legend(off)   ///
		subtitle("Access to credit improves if BMI increases from normal weight (BMI>18.5) to..") ///
		xlabel( 1.1 "Overweight (BMI > 25)"        ///
		        2.2 "Obese class I (BMI > 30)"    ///
				3.3 "Obese class III (BMI > 40)"))
	
	graph export $path/output/figures/fig4_gr_bar_loanofficersexplicit.pdf, replace

	
**# Fig 5 **********************************************************************

	use $path/input/wyw_beliefs_guessappratings.dta, clear

	// 1) store ACTUAL OBESITY PREMIUM
	
	preserve
	
	use $path/input/wyw_credit.dta, replace
	
	*Referral Request (average meeting request)
	sum meet if app_arm==1 
	sca meet_mean = `r(mean)'
	sca meet_sd = `r(sd)'
	
	global meet_mean meet_mean
	global meet_sd meet_sd
	
	sum qualify if app_arm==1
	sca qualify_mean = `r(mean)'   //save to standardized lay people's answers
	sca qualify_sd = `r(sd)'
	
	global qualify_mean qualify_mean
	global qualify_sd qualify_sd
	
	*Approval likelihood (Most Frequent)
	g count_r1 = (qualify ==1 & app_arm==1) 
	g count_r2 = (qualify ==2 & app_arm==1) 
	g count_r3 = (qualify ==3 & app_arm==1) 
	g count_r4 = (qualify ==4 & app_arm==1) 
	g count_r5 = (qualify ==5 & app_arm==1) 
	
	bys app_high_bm app_id: egen sum_r1 = mean(count_r1)
	bys app_high_bm app_id: egen sum_r2 = mean(count_r2)
	bys app_high_bm app_id: egen sum_r3 = mean(count_r3)
	bys app_high_bm app_id: egen sum_r4 = mean(count_r4)
	bys app_high_bm app_id: egen sum_r5 = mean(count_r5)

	local vars sum_r1 sum_r2 sum_r3 sum_r4 sum_r5
	cap drop m2
	egen double m2= rowmax( sum_r1 sum_r2 sum_r3 sum_r4 sum_r5)

	cap drop wanted
	gen wanted="" 
	foreach var of local vars {
	replace wanted = "`var'" if m2==`var'
	}
	
	drop m2

	cap drop most_frequent_approval_lkh 
	g most_frequent_approval_lkh =.
	replace most_frequent_approval_lkh = 1 if wanted=="sum_r1" 
	replace most_frequent_approval_lkh = 2 if wanted=="sum_r2" 
	replace most_frequent_approval_lkh = 3 if wanted=="sum_r3" 
	replace most_frequent_approval_lkh = 4 if wanted=="sum_r4" 
	replace most_frequent_approval_lkh = 5 if wanted=="sum_r5" 
	
	*Save obesity premium estimates

	reghdfe most_frequent_approval_lkh app_high_bm i.app_id if app_arm==1, absorb(loanofficer_id) vce(cluster loanofficer_id)  
	sca est_qual = round(_b[app_high_bm], .001)
	sca sd_qual = _se[app_high_bm]
	
	reghdfe meet app_high_bm i.app_id if app_arm==1, absorb(loanofficer_id) vce(cluster loanofficer_id)   		
	sca est_meet = round(_b[app_high_bm], .001)
	sca sd_meet = _se[app_high_bm]
		
	global est_qual est_qual
	global sd_qual sd_qual

	global est_meet est_meet
	global sd_meet sd_meet
	
	
	reghdfe most_frequent_approval_lkh app_male if app_arm==1, absorb(loanofficer_id) vce(cluster loanofficer_id)  
	reghdfe meet app_male if app_arm==1, absorb(loanofficer_id) vce(cluster loanofficer_id)   		

	
	restore
	
	* Store Loan Officers' Results into Matrix
	est clear
	matrix U = J(6, 3, .)
	mat colnames U =  "section" "beta" "se"
	
	mat U[1,1] = 1
	mat U[1,2] = $est_qual
	mat U[1,3] = $sd_qual

	mat U[2,1] = 2
	mat U[2,2] = $est_meet
	mat U[2,3] = $sd_meet

	mat list U
	svmat double U, names(matcol)

	cap drop upperci
	cap drop lowerci
	gen upperci = Ubeta + ( 1.96*Use)
	gen lowerci = Ubeta - ( 1.96*Use)
	
	cap drop number
	gen number = Usection

	label var number " "
	
	// Store LAYPEOPLE PREDICTED PREMIUM
	
	g outcome_1 = most_frequent_approval_lkh_lay
	g outcome_2 = referral_lkh
	g outcome_3 = loan_worth_apply
	
	est clear
	matrix V = J(6, 3, .)
	mat colnames V =  "section" "beta" "se"

	forvalues j = 1(1)3{
		
			qui reghdfe outcome_`j' app_high_bm, absorb(app_id respondent_id) vce(cluster respondent_id)		
			mat V[`j',1] = `j'
			mat V[`j',2] = round(_b[app_high_bm], .001)
			mat V[`j',3] = _se[app_high_bm]
		
			}


	mat list V
	svmat double V, names(matcol)
	cap drop Vupperci
	cap drop Vlowerci
	gen Vupperci = Vbeta + ( 1.96*Vse)
	gen Vlowerci = Vbeta - ( 1.96*Vse)
	cap drop numberV
	gen numberV = Vsection
	label var numberV " "

	* Panel A: approval likelihood
	replace  number = number +1.5
	twoway	scatter Vbeta numberV if numberV ==1, mlabel(Vbeta) mlabposition(1)  m(i) mlabsize(small) ///
				   msymbol(o) msize(large) mlabcolor(gs1) color(navy) mlabformat(%03.2f)  || ///
			scatter Ubeta number if number ==2.5, mlabel(Ubeta) mlabposition(1)  m(i) mlabsize(small) ///
				   msymbol(s)  msize(large) mlabcolor(gs1) color(orange) mlabformat(%03.2f) || ///
			rcap Vupperci Vlowerci numberV if numberV ==1, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
				mlab(Vsection) mlabgap(18) mlabsize(tiny) || ///
			rcap upperci lowerci number if number ==2.5, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
				mlab(Vsection) mlabgap(18) mlabsize(tiny) ///
				legend(off) ylabel(0 (.2) 1, format(%03.2f)) ///
				xlabel( 0 " " 1  "Predictions (Laypeople)" 2.5 "Actual (Loan officers)"  3.5 " ")  ///
				ytitle("Obesity coefficient (SD)") ///
				name(approval, replace) title("Approval likelihood")  

	
	* Panel B: referral request
	twoway scatter Vbeta numberV if numberV ==2, mlabel(Vbeta) mlabposition(1) m(i) mlabsize(small) ///
				   msymbol(o)  msize(large) mlabcolor(gs1) color(navy) mlabformat(%03.2f)   || ///
			scatter Ubeta number if number ==3.5, mlabel(Ubeta) mlabposition(1)  m(i) mlabsize(small) ///
				   msymbol(s)  msize(large) mlabcolor(gs1) color(orange) mlabformat(%03.2f) || ///
			rcap Vupperci Vlowerci numberV if numberV ==2, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
				mlab(Vsection) mlabgap(18) mlabsize(tiny) || ///
			rcap upperci lowerci number if number ==3.5, vertical lp(shortdash) lstyle(ci) lcolor(gs2)  ///
				mlab(Vsection) mlabgap(18) mlabsize(tiny) ///
			   legend(order( "95% confidence interval") position(12) cols(2)) ///
				ylabel(0 (.05) 0.25, format(%03.2f)) legend(off) ///
				xlabel( 1 " " 2 "Predictions (Laypeople)" 3.5 "Actual (Loan officers)"  4.5 " ")  ytitle(" ") ///
				name(referral, replace) title("Referral request")
	

	graph combine approval referral, name(laypredictions, replace) 
	graph export $path/output/figures/fig5_gr_coefplot_laypredictions_main.pdf, replace


**# Fig 6 **********************************************************************

	use "$path/input/wyw_laypeople_sample2.dta", clear
		
	cap drop avg_income_diff_w
	g avg_income_diff_w = avg_income_diff_usd

	* winsorize
	sum avg_income_diff_w, detail
	replace avg_income_diff_w = `r(p99)' if avg_income_diff_w > `r(p99)' & avg_income_diff_w!=.
	replace avg_income_diff_w = `r(p1)'  if avg_income_diff_w < `r(p1)'
	

	* graph

	graph twoway (hist avg_income_diff_w, ///
					 percent fcolor(gs12) ///
					 width(50)  lcolor(gs12) color(gs12) ///
					 xtitle("Income difference (USD, month): Obese vs normal weight") ///
					 ytitle("Percent laypeople")   xscale(range(-1000 2000)))
					 

	graph export $path/output/figures/fig6_gr_hist_genpopbeliefsdistribution.pdf, replace
