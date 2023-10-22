** Creating WYW credit data
	
	// import raw data
	use $path/rawdata/wyw_loanofficers_clean.dta, clear 

	// generate variables 
	
	* outcomes
	cap drop z_*
	egen z_meet    = std(meet)
	egen z_qualify = std(qualify)
	egen z_credit  = std(credit)
	egen z_prod    = std(prod)
	egen z_trust    = std(trust)
	
	* for likelihood ratios
	cap drop l_*
	gen l_qualify = qualify>=4 & qualify!=.
	gen l_credit  = credit>=4 & credit!=.
	gen l_prod    = prod>=4   & prod!=.
	gen l_trust   = trust>=4 & trust!=.
	gen l_meet    = meet

	* explanatory vars
	cap drop financial_info
	g financial_info = app_arm>1 & app_arm!=.
	
	cap drop app_info_wealth
	g app_info_wealth = 0 if app_arm==1
	replace app_info_wealth = 1 if app_rich==0 & (app_arm>1 & app_arm!=.)
	replace app_info_wealth = 2 if app_rich==1 & (app_arm>1 & app_arm!=.)
	
	* other vars

	encode app_profile, g(app_profile_num)
	label var app_profile_num "Loan profile"
	
	encode app_reason, g(app_reason_num) 
	label var app_reason_num "Reason for loan"


	cap drop app_order_above
    g app_order_above = app_n>5 & app_n !=.
	
	encode app_type, g(app_type_n)
	drop app_type

	
	// labels


	label def obese 0 "Non-obese" 1 "Obese"
	label val app_high_bm obese
	label var app_high_bm "Profile BMI (Obese)"
	
	
	label var meet   "Referral request (yes/no)"
	label var qualify "Approval likelihood (1-5)"
	label var credit "Creditworthiness (1-5)"
	label var prod "Financial ability (1-5)"
	label var trust "Information reliability (1-5)"
	
	label var l_meet   "Referral request (yes/no)"
	label var l_qualify "Approval likelihood >4"
	label var l_credit "Creditworthiness >4"
	label var l_prod "Financial ability >4"
	label var l_trust "Information reliability >4"
	
	label var z_meet   "Referral request (Std)"
	label var z_qualify "Approval likelihood (Std)"
	label var z_credit "Creditworthiness (Std)"
	label var z_prod "Financial ability (Std)"
	label var z_trust "Information reliability (Std)"

	label var financial_info "Financial information"
	label def financial_info 0 "No information" 1 "Self-reported"
	label val financial_info financial_info
	
	label def  lab_app_info_wealth 0 "No financial information"  1 "High DTI ratio"  2 "Low DTI ratio"
	label val app_info_wealth lab_app_info_wealth	
	
	label var app_type_n "Profile set evaluated (A or B)"

	label var app_p1 "Loan amount: UGX 1 mil" 
	label var app_p2 "\hphantom{Loan Amount} Ush 5 mil" 
	label var app_p3 "\hphantom{Loan Amount} Ush 7 mil" 
	
	label var app_c2 "\hphantom{Collateral:} Land title"	
	label var app_c3 "\hphantom{Collateral:} Motorcycle"
	
	label var app_o1 "Occupation: Agri Shop"
	label var app_o2 "\hphantom{Occupation:} Sells clothes"
	label var app_o3 "\hphantom{Occupation:} Diary project"
	label var app_o4 "\hphantom{Occupation:} Hardware store"
	label var app_o5 "\hphantom{Occupation:} Jewelry  shop"
	label var app_o6 "\hphantom{Occupation:} Retail and mobile money"
	label var app_o7 "\hphantom{Occupation:} Phone and movies shop"
	label var app_o8 "\hphantom{Occupation:} Poultry and eggs"
	
	label var app_r2 "\hphantom{Reason:} Home improvement"
	label var app_r3 "\hphantom{Reason:} Purchase animal"
	label var app_r4 "\hphantom{Reason:} Purchase asset"
	label var app_r5 "\hphantom{Reason:} Purchase land"
	
	label def app_order_above 0 "First half"  1 "Second half"  
	label val app_order_above app_order_above
	
	label var app_order_above "Profile in second half of rating order"
	
	label def app_arm  1 "No information" 2 "Sequential information" 3 "All information at once"
	label val app_arm app_arm
		
	label def role_loan_owner 0 "Non-owner" 1 "Owner"
	label val role_loan_owner role_loan_owner
	
	label def perf_pay 0 "No performance pay" 1 "Performance pay"
	label val perf_pay perf_pay
	label var experience_years "Experience (years)"
	label var educ_years "Education (years)"
	label var bmi_value "BMI (loan officer)"
	
	label def sal_comp_1 0 "Any performance pay" 1 "Performance pay: Sales volume"
	
	label var instit_branches  "Branches"	
	label var instit_size      "Employees per branch"
	
	label var n_meet    "Borrowers met daily"
	label var n_qualify "Borrowers approved daily"

	// save
	save $path/input/wyw_credit.dta, replace
