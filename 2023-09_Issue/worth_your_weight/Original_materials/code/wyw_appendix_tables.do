********************************************************************************	
	
	
	* Produces appendix tables for "Worth Your Weight" (Macchi)
	* Last updated: March 25 2023 
	* EM

********************************************************************************

	
	

	
	
	
*** MAIN APPENDIX TABLES *******************************************************

	

**# Table A1 - 
** Warning: Long running time! (Randomization Inference P-Values with reps 1000)  
	
	use "$path/input/wyw_credit.dta", clear 

	global APPCHR app_bm_value app_age app_male app_c1 app_c2 app_c3 ///
 				  app_o1 app_o2 app_o3 app_o4 app_o5 app_o6 app_o7 app_o8 ///
 				  app_revenues app_profits app_n app_r1 app_r2 app_r3 app_r4 ///
 				  app_r5 app_p1 app_p2 app_p3 
	 
	keep $APPCHR  app_high_bm  loanofficer_id
	order $APPCHR
	cap drop TREAT
	g TREAT = app_high_bm
	
	* Describe Variables

	des $APPCHR	
	
	* Balance Covariate Table  

		* First test of differences 

	mata: mata clear

	local i = 1

	foreach var in $APPCHR {
		qui reghdfe `var' TREAT, a(loanofficer_id) vce(cluster loanofficer_id) 
		gen s_`var'=e(sample)
		outreg, keep(TREAT)  rtitle("`: var label `var''") stats(b) ///
			noautosumm store(row`i')  nostar
		outreg, replay(diff) append(row`i') ctitles("", Difference ) ///
			store(diff) note("") nostar
		local ++i
	}

	outreg, replay(diff) nostar

		*** clustered p-value
	foreach var in $APPCHR {
		reghdfe `var' TREAT, vce(cluster loanofficer_id) a(loanofficer_id)
		outreg, keep(TREAT) rtitle("`: var label `var''") stats(p) ///
			noautosumm store(row`i') nostar starloc(1) 
		outreg, replay(clusterp) append(row`i') ctitles("",P-value ) ///
			store(clusterp) note("") nostar
		local ++i
	}
	outreg, replay(clusterp) nostar
	outreg, replay(diff) merge(clusterp) store(totdiff) nostar

	*** RI p-value
	local count: word count $APPCHR
	mat rip = J(`count',1,.)

	local i = 1
	foreach var in $APPCHR {
		ritest TREAT _b[TREAT], reps(5000) seed(546): qui reghdfe `var' TREAT, vce(cluster loanofficer_id) a(loanofficer_id)
		matrix ri = r(p)
		local Pri = ri[1,1]
		mat rip[`i',1] = `Pri'
		local i = `i' + 1
	}
	
	frmttable, statmat(rip) store(rip) sfmt(f)
	outreg, replay(totdiff) merge(rip) store(totdiff2) nostar

	* summary stats
	local count: word count $APPCHR
	mat sumstat = J(`count'+1 ,4,.)

	local i = 1
	foreach var in $APPCHR {
		quietly: summarize `var' if TREAT==0 & s_`var' == 1
		mat sumstat[`i',1] = r(mean)
		mat sumstat[`i',2] = r(sd)
		quietly: summarize `var' if TREAT==1 & s_`var' == 1
		mat sumstat[`i',3] = r(mean)
		mat sumstat[`i',4] = r(sd)
		local i = `i' + 1
		
	}
	
	* include # obs as a row
	count 
	local num: dis %15.0fc `r(N)'
	frmttable, statmat(sumstat) store(sumstat) sfmt(f,f,f,f)  varlabels

	outreg using "$path/output/tables/_tableA1_balance_appchr.tex", ///
		replay(sumstat) merge(totdiff2) tex nocenter note("") nostar fragment plain replace ///
		ctitles("", Non-obese, "", Obese, "",  P-value of difference \ "", Mean, SD, Mean, SD, Diff, Standard, RI) ///
		multicol(1,2,2;1,4,2;1,6,3) addrows("\textit{Observations}", "`num'")  bdec(2 2 2 2) 

		
**# Table A2------------------------------------------------------------------


	use $path/input/wyw_credit.dta, replace 
	
	label def financial_info2 0  "No information" 1 "Financial information"
	label val financial_info financial_info

	eststo REG_BM:     reghdfe z_qualify i.app_high_bm##i.financial_info, absorb(loanofficer_id app_id) vce(cluster loanofficer_id)
	eststo REG_AGE:    reghdfe z_qualify c.app_age##i.financial_info, absorb(loanofficer_id app_id) vce(cluster loanofficer_id)
	eststo REG_LOAN:   reghdfe z_qualify i.app_profile_num##i.financial_info, absorb(loanofficer_id app_id) vce(cluster loanofficer_id)
	eststo REG_REASON: reghdfe z_qualify i.app_reason_num##i.financial_info, absorb(loanofficer_id app_id) vce(cluster loanofficer_id)
	
	
	esttab  REG_BM REG_AGE REG_LOAN REG_REASON using $path/output/tables/tabA2_robustnessattention.tex, ///
		nostar drop(_cons 0.app_high_bm 1.app_high_bm 0.financial_info 1.financial_info ///
		0.financial_info#c.app_age app_age ///
		1.app_profile_num 2.app_profile_num 3.app_profile_num ///
		1.app_profile_num#0.financial_info 0.app_high_bm#0.financial_info ///
		0.app_high_bm#1.financial_info 1.app_high_bm#0.financial_info ///
		2.app_profile_num#0.financial_info 3.app_profile_num#0.financial_info ///
		1.app_reason_num 2.app_reason_num 3.app_reason_num 4.app_reason_num 5.app_reason_num ///
		2.app_reason_num#0.financial_info 3.app_reason_num#0.financial_info ///
		4.app_reason_num#0.financial_info 5.app_reason_num#0.financial_info ///
		1.app_reason_num#0.financial_info  1.app_reason_num#1.financial_info ///
		1.app_profile_num 1.app_profile_num#1.financial_info) replace label ///
		s(N, fmt(%15.0fc) label("Observations"))  noobs  nonotes nomti nonum ///
		f sfmt(%9.0fc %4.3f) b(%5.3f) se(%5.3f) booktabs nolines


**# Table A3 ----------------------------------------------------------------

	use $path/input/wyw_unps_credit_bmi.dta, clear
	
    eststo all: reghdfe borrowed normal_weight over obese  h2q3##c.age , a(district hhid)
	eststo byprofit: reghdfe borrowed c.bmi##non_profit h2q3##c.age, a(district hhid)
	test c.bmi + c.bmi#1.non_profit =0
	estadd scalar p_sum = r(p)/2
	eststo repay: reghdfe repayed_lastyear normal_weight over obese h2q3##c.age if borrowed==1, a(district hhid)

	
	esttab all byprofit repay using $path/output/tables/tabA3_unpscorrelation.tex, ///
		width(\hsize) nostar drop(age 0.non_profit 0.non_profit#c.bmi 1.h2q3 2.h2q3 ///
		1.h2q3#c.age 2.h2q3#c.age _cons) replace label nonotes ///
		stat(N p_sum, fmt(%15.0fc 3) label("Observations" "\makecell{\textit{p}-value: BMI + \\ Non-profit institution x BMI = 0}")) ///
		nonotes nomti nonum noobs f sfmt(%9.0fc %4.3f) b(%5.3f) se(%5.3f) booktabs nolines
	

		
**** ONLINE APPENDIX TABLES ****************************************************

**# Table G2 -------------------------------------------------------------------
	
	use $path/input/wyw_beliefs_main.dta, clear 
	
	label var pic_age  "Age"
	local OUTCOME_VARS model1 model2 model3	
	eststo model1: reghdfe  z_wealth_1b i.pic_high_bm##i.pic_male     if pic_n!=., absorb(respondent_id) vce(cluster respondent_id)
	eststo model2: reghdfe  z_wealth_1b i.pic_high_bm##c.pic_age      if pic_n!=., absorb(respondent_id) vce(cluster respondent_id)
	eststo model3: reghdfe  z_wealth_1b i.pic_high_bm##i.other_signal if pic_n!=.,  absorb(respondent_id) vce(cluster respondent_id)

	esttab  `OUTCOME_VARS' using "$path/output/tables/tabG2_heterogeneitywealthsignal.tex", ///
		 nostar keep(1.pic_high_bm 1.pic_male pic_age 1.pic_high_bm#1.pic_male ///
		 1.pic_high_bm#c.pic_age  1.other_signal 1.pic_high_bm#1.other_signal) replace label nonotes ///
		 s(N, label("Observations") fmt(%15.0fc)) ///
	     nomti nonum f  sfmt(%9.0fc %4.3f) b(%5.3f) se(%5.3f) nolines booktabs
	eststo clear
	

**# Table G4 -------------------------------------------------------------------

   	use $path/input/wyw_credit.dta, replace 

 	local OUTCOME_VARS qualify credit prod meet
	foreach var of local OUTCOME_VARS {
		
		eststo `var': reghdfe `var' i.app_high_bm##app_order_above i.app_arm, a(loanofficer_id) vce(cluster loanofficer_id)
		sca est_`var' = _b[1.app_high_bm]
	
	}
		
	esttab `OUTCOME_VARS' using $path/output/tables/tabG4_robustnessorder.tex, ///
		nostar keep(1.app_high_bm 1.app_order_above 1.app_high_bm#1.app_order_above) replace label ///
		s(N, fmt(%15.0fc)  label("Observations" ))    ///
	    nonotes nomti nonum f sfmt(%9.0fc %4.3f) b(%5.3f) se(%5.3f) booktabs nolines
	
	
**# Table G5 -------------------------------------------------------------------
	use $path/input/wyw_credit.dta, replace 
  
    label var app_profits_ml "Profits Ush mil(.)"
 
	local OUTCOME_VARS qualify credit prod meet
	foreach var of local OUTCOME_VARS {
		qui reghdfe z_`var' app_profits_ml if app_arm>1, absorb(loanofficer_id)
		eststo `var'

	}
		
	esttab `OUTCOME_VARS' using $path/output/tables/tabG5_earningspremium.tex, ///
		width(\hsize) nostar keep(app_profits_ml) ///
		replace label nonotes ///
		stat(N , fmt(%15.0fc )  ///
		label("Observations" )) ///  
		nonotes nomti nonum noobs f sfmt(%9.0fc %4.3f) b(%5.3f) se(%5.3f) booktabs nolines
	
	

	
**# Table G6  -----------------------------------------------------------------

	
	use $path/input/wyw_credit.dta, replace 

	local OUTCOME_VARS qualify credit prod meet
	foreach var of local OUTCOME_VARS {
		qui eststo `var': areg `var' i.app_high_bm##i.app_arm i.app_id, absorb( loanofficer_id) vce(cluster loanofficer_id)
			test  1.app_high_bm#2.app_arm = 1.app_high_bm#3.app_arm 
			estadd scalar p_diff = r(p)
	}
			
	esttab  `OUTCOME_VARS' using $path/output/tables/tabG6_robustnessarm.tex, ///
		width(\hsize) nostar keep(1.app_high_bm 2.app_arm 3.app_arm ///
		1.app_high_bm#2.app_arm 1.app_high_bm#3.app_arm) ///
		replace label nonotes s(N p_diff, fmt(%15.0fc 3) ///
		label("Observations" "\makecell{\textit{p}-value: Obese x Sequential information \\ = Obese x All information at once}"))   ///
		nonotes nomti nonum f sfmt(%9.0fc %4.3f) b(%5.3f) se(%5.3f)   booktabs nolines
		
		

**# Table G7 -------------------------------------------------------------------

	use $path/input/wyw_credit.dta, replace 

	local OUTCOME_VARS qualify credit prod meet
	
	foreach var of local OUTCOME_VARS {

		eststo `var': reghdfe l_`var' app_high_bm if app_arm==1, absorb(app_id loanofficer_id)  vce(cluster loanofficer_id)
		local lr_fat_`var' = round((_b[_cons] + _b[app_high_bm])*100, 0.01)
		local lr_thin_`var' = round((_b[_cons])*100, 0.01)

		test app_high_bm  =0
		local p_sum_`var' = round(r(p), 0.001)
		local ratio_`var' = round(`lr_fat_`var''/ `lr_thin_`var'', 0.01)
		
		eststo `var': reghdfe l_`var' app_high_bm if app_arm>1, absorb(app_id loanofficer_id)  vce(cluster loanofficer_id)
		local lr_fat2_`var' = round((_b[_cons] + _b[app_high_bm])*100, 0.01)
		local lr_thin2_`var' = round((_b[_cons])*100, 0.01)
		local ratio2_`var' = round(`lr_fat2_`var''/ `lr_thin2_`var'', 0.01)

	}	
	
	cap file close summary
	file open summary using  "$path/output/tables/_tableG7_likelihoodratio.tex", write replace	
	file write summary  "\begin{tabular}{lccc}"  _n
	file write summary  "\hline\hline"  _n
	file write summary  " Outcome &  Rate obese  & Rate non-obese & Ratio \\"  _n
	file write summary  "\hline "  _n
	file write summary  "  & & & \\" _n
	file write summary  " \emph{No financial information} [2,079]& & &    \\ "  _n
	file write summary  " Approval likelihood $\geq 4$ & `lr_fat_qualify' \% & `lr_thin_qualify' \% & `ratio_qualify' \\ "  _n
	file write summary  " Creditworthiness $\geq 4$ & `lr_fat_credit' \%  & `lr_thin_credit' \% & `ratio_credit' \\"  _n
	file write summary  " Financial ability $\geq 4$ & `lr_fat_prod' \% & `lr_thin_prod' \%  & `ratio_prod'  \\ "  _n
	file write summary  " Referral request $= 1$ & `lr_fat_meet' \% & `lr_thin_meet' \%  & `ratio_meet' \\ "  _n
	file write summary  "  & & &  \\" _n
	file write summary  "  & & &  \\" _n
	file write summary  " \emph{Financial information} [4,566] & & &  \\ "  _n
	file write summary  " Approval likelihood  $\geq 4$ & `lr_fat2_qualify' \% & `lr_thin2_qualify' \% & `ratio2_qualify'  \\ "  _n
	file write summary  " Creditworthiness $\geq 4$ & `lr_fat2_credit' \%  & `lr_thin2_credit' \% & `ratio2_credit'  \\"  _n
	file write summary  " Financial ability $\geq 4$ & `lr_fat2_prod' \% & `lr_thin2_prod' \%  & `ratio2_prod' \\ "  _n
	file write summary  " Referral request $= 1$ & `lr_fat2_meet' \% & `lr_thin2_meet' \%  & `ratio2_meet' \\ "  _n
	file write summary  "\hline\hline"  _n
	file write summary  " \\" _n
	file write summary  "\end{tabular}"  _n
	file close summary	

**# Table G8  ------------------------------------------------------------------


	use $path/input/wyw_credit.dta, clear 
	
	local OUTCOME_VARS z_qualify z_credit z_prod z_meet
	
	foreach var of local OUTCOME_VARS {
		
		eststo `var': reghdfe `var' app_high_bm if app_male==1 & gender==1, ///
		absorb(app_id loanofficer_id) vce(cluster loanofficer_id)

	}

	esttab  `OUTCOME_VARS' using $path/output/tables/tabG8_robustnessmenvsmen.tex, ///
		width(\hsize) nostar keep(app_high_bm) replace label nonotes ///
		s(N, fmt(%15.0fc)  label("Observations" ))   ///
	    nonotes nomti nonum f sfmt(%9.0fc %4.3f) b(%5.3f) se(%5.3f)  booktabs nolines


	

**# Table G9 ----------------------------------------------------------------
	
	use $path/input/wyw_credit.dta, clear 

	local CONT_VARS age bmi_value educ_years experience_years days_verify  

	foreach var of local CONT_VARS {
		eststo `var': areg z_qualify app_high_bm##c.`var' i.app_arm, ///
			absorb(app_id) vce(cluster loanofficer_id)
	

	}
			
	local DISCR_VARS gender role_loan_owner perf_pay sal_comp_1

	foreach var of local DISCR_VARS {
		eststo `var': areg z_qualify app_high_bm##i.`var' i.app_arm, ///
			absorb(app_id) vce(cluster loanofficer_id)
		testparm i.app_high_bm#i.`var'  
		estadd scalar ftest =r(p) 

	}

	esttab `CONT_VARS' `DISCR_VARS' using $path/output/tables/tabG9_heteroloanoffchrs.tex, ///
		nostar replace label   stat(N, fmt(%15.0fc) label("Observations") ) ///
		keep(1.app_high_bm 1.app_high_bm#c.age  ///
			 1.app_high_bm#c.bmi_value ///
			 1.app_high_bm#c.educ_years ///
		     1.app_high_bm#c.experience_years ///
			 1.app_high_bm#c.days_verify  ///
			 1.app_high_bm#1.gender       ///
			 1.app_high_bm#1.role_loan_owner ///
			 1.app_high_bm#1.perf_pay 1.app_high_bm#1.sal_comp_1 ) ///
	    nonotes nomti nonum f sfmt(%9.0fc %4.3f) b(%5.3f) se(%5.3f)  booktabs nolines

		


	 
**# Table G10 ------------------------------------------------------------------
	
	use $path/input/wyw_credit.dta, clear
	clear mata

	cap drop newid
	egen newid = group(loanofficer_id) 
		
	* define matrix input
	sum newid
	global tot  `r(max)'
	local max_plus_one `r(max)' + 1	
	
	local OUTCOME_VARS qualify credit prod meet 
	foreach var of local OUTCOME_VARS {
		
		* define matrix
		matrix U`var' = J( `max_plus_one', 6, .)
		mat colnames U`var' =  "id" "beta" "income" "car" "land" "bmi"

		* fill matrix U	

		forvalues j = 1(1)$tot{
				
					capture {
					reg z_`var' app_high_bm##financial_info app_age app_male app_type_n if newid==`j'
					
					mat U`var'[`j',1] = `j'
					mat U`var'[`j',2] =  _b[1.app_high_bm]
					
					}
					
					capture {
					reg z_`var' app_high_bm app_profits_ml app_c1 app_c2 app_age app_male app_type_n if newid==`j' & financial_info >0 

					mat U`var'[`j',3] = _b[app_profits_ml]
					mat U`var'[`j',4] = _b[app_c1]
					mat U`var'[`j',5] = _b[app_c2]

					
					}
					
					capture {
					reg z_`var' app_high_bm##financial_info app_profits_ml app_age app_male app_type_n if newid==`j'
					
					mat U`var'[`j',6] = _b[1.app_high_bm] + _b[1.financial_info#1.app_high_bm] 					
					}
					}

		mat U`var'[`max_plus_one',1] = `max_plus_one'
	
	
	}
	
	mat list Uqualify Ucredit Uprod Umeet 
	svmat double Ucredit, names(matcol)
	svmat double Uqualify, names(matcol)
	svmat double Uprod, names(matcol)
	svmat double Umeet, names(matcol)
	
	keep U* 
	drop if Ucreditid ==.
	
	g Ubeta1 = Uqualifybeta
	g Ubeta2 = Ucreditbeta 
	g Ubeta3 = Uprodbeta   
	g Ubeta4 = Umeetbeta  

	g Ubmi1 = Uqualifybmi
	g Ubmi2 = Ucreditbmi 
	g Ubmi3 = Uprodbmi   
	g Ubmi4 = Umeetbmi   

	g Uincome1 = Uqualifyincome
	g Uincome2 = Ucreditincome
	g Uincome3 = Uprodincome   
	g Uincome4 = Umeetincome 
	
	g Ucar1 = Uqualifycar
	g Ucar2 = Ucreditcar
	g Ucar3 = Uprodcar
	g Ucar4 = Umeetcar
	
	g Uland1 = Uqualifyland
	g Uland2 = Ucreditland
	g Uland3 = Uprodland 
	g Uland4 = Umeetland
	
	reshape long Uincome Ubmi Ubeta Uland Ucar, i(Ucreditid) j(outvarnum)
	
	label var Uland   "Land collateral (E)"
	label var Ucar    "Car collateral (E)"
	label var Uincome "Earnings, self-reported (E)"
	label var Ubmi    "Residual premium (T)"
	label var Ubeta   "Obesity premium (P)"
	
	g outvar = "qualify"      if outvarnum ==1
	replace outvar = "credit" if outvarnum ==2
	replace outvar = "prod"   if outvarnum ==3
	replace outvar = "meet"   if outvarnum ==4
	
	local OUTCOME_VARS qualify credit prod meet 
	foreach var of local OUTCOME_VARS {
		eststo `var': reg Ubeta Ubmi Uincome Ucar Uland if outvar =="`var'"  

	}
	
	esttab `OUTCOME_VARS' using $path/output/tables/_tableG10_loanoffbeliefs_r2analysis.tex, ///
		width(\hsize) nostar replace label nonotes ///
		stat(N r2, fmt(%15.0fc 3 3 3 3)  ///
		label("Observations" "R2")) ///  
	    nonotes nomti nonum noobs f sfmt(%9.0fc %4.3f) b(%5.3f) se(%5.3f) booktabs nolines

		
**# Table G11 ------------------------------------------------------------------
	
	use $path/input/wyw_laypeople_sample2.dta, clear
	set emptycells drop
	set matsize 11000
	
	keep responseid personal_income_mln bmi_value gender a* i* e*
	duplicates drop responseid, force
	

	global SMPCHR  gender a1 a2 a3 a4 e2 e3 e4 e5 e1 i1 i2 i3 i4 i5 i6 i7 personal_income_mln bmi_value
	
	order gender a1 a2 a3 a4 e2 e4 e3 e5 e1 i3 i5 i7 i1 i6 i4 i2  personal_income_mln bmi_value
	 
	outreg2 using $path/output/tables/_tableG11_sumstatlaypeoplesample2.tex, tex(fragment) ///
	 replace sum(detail) eqkeep(mean sd p50) keep($SMPCHR) label dec(2) 


**# Table G12----------------------------------------------------------------

	use $path/input/wyw_laypeople_sample2.dta, clear
	keep want_gain want_lose
	duplicates drop
	
	g respondent_n = _n
	label var respondent_n "Respondent number"
	label var want_gain  "Most common reason to gain"
	label var want_lose "Most common reason to lose"
	
	drop respondent_n
	
	cd $path/output/tables

	order  want_gain want_lose want_lose
	dataout, save(_tableG12_dataout_gain_lose) replace tex 
	

	
**# Format Tables ------------------------------------------------------------
	cd $path
	do $path/code/latex_scheletons_appendix.do
