** Creating summary statitics dataset
	
	// import clean laypeople data
	
	use $path/rawdata/wyw_beliefs_demographics_clean.dta, clear
	
	g educ_years = 6 if educ_level==1
	replace educ_years = 11 if educ_level==2
	replace educ_years = 14 if educ_level==3
	replace educ_years = 13 if educ_level==4
	replace educ_years = 16 if educ_level==5
	replace educ_years = 18 if educ_level==6
	replace educ_years = 20 if educ_level==7

	g s1 = personal_income <= 500000
	g s2 = personal_income > 500000 & personal_income<= 1000000
	g s3 = personal_income > 1000000 & personal_income<= 1500000
	g s4 = personal_income > 1500000 & personal_income<= 2000000
	g s5 = personal_income > 2000000 
	
	g n_family_mbrs = n_children
	replace n_family_mbrs = n_family_mbrs + 1  if marital_status == 2 | marital_status==3
	
	tab district, g(dis)
	
	keep dis1 dis2 dis3 age gender bmi educ_years n_family_mbrs s1 s2 s3 s4 s5 respondent_id personal_income household_income
	
	duplicates drop respondent_id, force
	g id_role = "General Population"
	

	// import clean loan officers data
	preserve
	use $path/input/wyw_credit.dta, replace
	
	rename (distr1 distr2 distr3) (dis1 dis2 dis3)

	rename  bmi_value bmi	  
	keep loanofficer_id dis1 dis2 dis3 age gender bmi educ_years n_family_mbrs s1 s2 s3 s4 s5  ///
			   role_loan_off role_loan_owner role_loan_manager  perf_pay experience_years ///
			   int_rate_discretion fin_know_self action_1-action_8 action_9 ///
			   days_verify matters_* n_meet n_qualify tier1 tier3 tier2 tier4 ///
			   instit_branches instit_size inst_personalloan inst_businessloan ///
			   int_rate1m int_rate5m int_rate7m 
			   
	duplicates drop loanofficer_id, force
	
	g id_role = "Loan Officers"
	
	label var bmi "BMI"
	label var s1 "Personal Income: Under UGX 500k"
	label var s2 "\hphantom{Personal Income:} UGX 500k to 1 mln"
	label var s3 "\hphantom{Personal Income:} UGX 1 to 1.5 mln"
	label var s4 "\hphantom{Personal Income:} UGX 1.5 to 2 mln"
	label var s5 "\hphantom{Personal Income:} Over UGX 2 mln"
	label var action_2  "\hphantom{Task:} provide product information"
	label var action_3  "\hphantom{Task:} review personal information"
	label var action_4  "\hphantom{Task:} review financial information"
	label var action_5  "\hphantom{Task:} refer borrowers to next step"
	label var action_6  "\hphantom{Task:} recruit new borrowers"
	label var action_7  "\hphantom{Task:} approve borrowers"
	label var action_8  "\hphantom{Task:} collect credit"
	label var action_9  "\hphantom{Task:} verify financial information"
	label var matters_age  		  "Matters for Loan: Age"
	label var matters_income 	  "\hphantom{Matters for Loan:} Income"
	label var matters_gend 		  "\hphantom{Matters for Loan:} Gender"
	label var matters_collateral  "\hphantom{Matters for Loan:} Collateral"
	label var matters_guarantor   "\hphantom{Matters for Loan:} Guarantor"
	label var matters_education   "\hphantom{Matters for Loan:} Education"
	label var matters_nationality "\hphantom{Matters for Loan:} Nationality"
	label var matters_appearance  "\hphantom{Matters for Loan:} Appearance"
	label var matters_occupation  "\hphantom{Matters for Loan:} Occupation"
	label var role_loan_off      "Role: Loan officer"
	label var role_loan_owner   "\hphantom{Role:} Owner"
	label var role_loan_manager "\hphantom{Role:} Manager"
	label var educ_years         "Education (Years)"

	label var n_meet "Borrowers met daily"
	label var n_qualify "Borrowers approved daily"
	
	save $path/temp/loanoff.dta, replace

	restore 
	
	// import clean institutions data

	preserve 
	
	use $path/input/wyw_credit.dta, replace

	rename (distr1 distr2 distr3) (dis1 dis2 dis3)

	keep instit_id dis1 dis2 dis3 tier1 tier3 tier2 tier4 ///
					instit_branches instit_size inst_personalloan inst_businessloan ///
					int_rate1m int_rate5m int_rate7m 
	duplicates drop instit_id, force
	
	cap drop both_loans
	g both_loans = inst_personalloan ==1 &  inst_businessloan==1
	label var both_loans "Offer personal and business loans"
	
	drop inst_personalloan inst_businessloan
	
	g id_role = "Financial Institutions"
	
	save $path/temp/instit.dta, replace
	
	restore
	
	// put data together and

	append using $path/temp/instit.dta
	append using $path/temp/loanoff.dta

	g idrole =1 if id_role=="General Population"
	replace idrole =2 if id_role=="Loan Officers"
	replace idrole =3 if id_role=="Financial Institutions"
	label var idrole "Sample identifier"
	drop id_role

	// labels

	label var s1 "Personal income: Under Ush 500k"
	label var s2 "\hphantom{Personal income:} Ush 500k to 1 mil"
	label var s3 "\hphantom{Personal income:} Ush 1 to 1.5 mil"
	label var s4 "\hphantom{Personal income:} Ush 1.5 to 2 mil"
	label var s5 "\hphantom{Personal income:} Over Ush 2 mil"
	
	label var gender "Gender: Male"

	label var dis1 "District: Kampala"
	label var dis2 "\hphantom{District:} Wakiso"
	label var dis3 "\hphantom{District:} Mukono"

	destring bmi, replace
	replace bmi=. if bmi>100
	label var bmi "Body mass index (kg/m2)"	
	
	label var s1 "Personal income: Under Ush 500k"
	label var s2 "\hphantom{Personal income:} Ush 500k to 1 mil"
	label var s3 "\hphantom{Personal income:} Ush 1 to 1.5 mil"
	label var s4 "\hphantom{Personal income:} Ush 1.5 to 2 mil"
	label var s5 "\hphantom{Personal income:} over Ush 2 mil"
	
	label var action_2  "\hphantom{Task:} Provide product information"
	label var action_3  "\hphantom{Task:} Review personal information"
	label var action_4  "\hphantom{Task:} Review financial information"
	label var action_5  "\hphantom{Task:} Refer borrowers to next step"
	label var action_6  "\hphantom{Task:} Recruit new borrowers"
	label var action_7  "\hphantom{Task:} Approve borrowers"
	label var action_8  "\hphantom{Task:} Collect credit"
	label var action_9  "\hphantom{Task:} Verify financial information"
	
	label var matters_age  		  "Matters for loan: Age"
	label var matters_income 	  "\hphantom{Matters for loan:} Income"
	label var matters_gend 		  "\hphantom{Matters for loan:} Gender"
	label var matters_collateral  "\hphantom{Matters for loan:} Collateral"
	label var matters_guarantor   "\hphantom{Matters for loan:} Guarantor"
	label var matters_education   "\hphantom{Matters for loan:} Education"
	label var matters_nationality "\hphantom{Matters for loan:} Nationality"
	label var matters_appearance  "\hphantom{Matters for loan:} Appearance"
	label var matters_occupation  "\hphantom{Matters for loan:} Occupation"
	
	label var experience_years "Years at institution"
	
	label var role_loan_owner   "Role: Loan officer"
	label var role_loan_owner   "\hphantom{Role:} Owner"
	label var role_loan_manager "\hphantom{Role:} Manager"
	
	label var tier1 "Type: Credit institutions"
	label var tier3 "\hphantom{Type:} Microfinance institutions"
	label var tier2 "\hphantom{Type:} Non-deposit-taking MFIs"
	label var tier4 "\hphantom{Type:} Licensed moneylenders"
	
	label var n_family_mbrs    "Family members"
	
	label var int_rate1m   "Interest rate Ush 1 mil"
	label var int_rate5m   "\hphantom{Interest rate} Ush 5 mil"
	label var int_rate7m   "\hphantom{Interest rate} Ush 7 mil"
	
	label var educ_years         "Education (Years)"

	

	// save
	save $path/input/wyw_summarystats.dta, replace
	

	