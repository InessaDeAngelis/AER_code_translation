
use "Data/Input/IQ_input.dta", clear

gen no_info = .
label var no_info "No Info Rank"
replace no_info = 1 if rank1 == option1
replace no_info = 2 if rank2 == option1
replace no_info = 3 if rank3 == option1
replace no_info = 4 if rank4 == option1

gen certain_info = .
label var certain_info "Most Info Rank"
replace certain_info = 1 if rank1 == option2
replace certain_info = 2 if rank2 == option2
replace certain_info = 3 if rank3 == option2
replace certain_info = 4 if rank4 == option2

gen pos_skew = .
label var pos_skew "Pos Skew Rank"
replace pos_skew = 1 if rank1 == option3
replace pos_skew = 2 if rank2 == option3
replace pos_skew = 3 if rank3 == option3
replace pos_skew = 4 if rank4 == option3

gen neg_skew = .
label var neg_skew "Neg Skew Rank"
replace neg_skew = 1 if rank1 == option4
replace neg_skew = 2 if rank2 == option4
replace neg_skew = 3 if rank3 == option4
replace neg_skew = 4 if rank4 == option4

rename q46 correct_preferences
label define correct_preferences_ 1 "Yes, proceed with survey" 2 "No, revise answers"
label values correct_preferences correct_preferences_
  

 sum q37_6 q37_5 q37_7 q37_15
*37_6 coded the rank of option 1 (no info), 37_5 coded the rank of option 2 (full), 37_7 coded the rank of option 3 (positive), and 37_15 coded the rank of option 4 (negative)  

	
replace no_info = q37_6 if correct_preferences==2
replace certain_info = q37_5 if correct_preferences==2
replace pos_skew = q37_7 if correct_preferences==2	
replace neg_skew = q37_15 if correct_preferences==2


** descriptive stats
global info no_info certain_info pos_skew neg_skew
summarize $info, detail

gen info_preferences = .
label var info_preferences "Information Preferences"
label define info_preferences_ 	1 "no info > certain > pos skew > neg skew" ///
								2 "no info > certain > neg skew > pos skew" ///
								3 "no info > pos skew > certain > neg skew" ///
								4 "no info > neg skew > certain > pos skew" ///
								5 "no info > pos skew > neg skew > certain" ///
								6 "no info > neg skew > pos skew > certain" ///
								7 "certain > no info > pos skew > neg skew" ///
								8 "certain > no info > neg skew > pos skew" ///
								9 "pos skew > no info > certain > neg skew" ///
								10 "neg skew > no info > certain > pos skew" ///
								11 "neg skew > no info > pos skew > certain" ///
								12 "pos skew > no info > neg skew > certain" ///
								13 "certain > pos skew > no info > neg skew" ///
								14 "certain > neg skew > no info > pos skew" ///
								15 "pos skew > certain > no info > neg skew" ///
								16 "neg skew > certain > no info > pos skew" ///
								17 "neg skew > pos skew > no info > certain" ///
								18 "pos skew > neg skew > no info > certain" ///
								19 "certain > pos skew > neg skew > no info" ///
								20 "certain > neg skew > pos skew > no info" ///
								21 "pos skew > certain > neg skew > no info" ///
								22 "neg skew > certain > pos skew > no info" ///
								23 "pos skew > neg skew > certain > no info" ///
								24 "neg skew > pos skew > certain > no info", replace
label values info_preferences info_preferences_
								
replace info_preferences = 1 if no_info == 1 & certain_info == 2 & pos_skew == 3 & neg_skew == 4

replace info_preferences = 2 if no_info == 1 & certain_info == 2 & pos_skew == 4 & neg_skew == 3

replace info_preferences = 3 if no_info == 1 & certain_info == 3 & pos_skew == 2 & neg_skew == 4

replace info_preferences = 4 if no_info == 1 & certain_info == 3 & pos_skew == 4 & neg_skew == 2

replace info_preferences = 5 if no_info == 1 & certain_info == 4 & pos_skew == 2 & neg_skew == 3

replace info_preferences = 6 if no_info == 1 & certain_info == 4 & pos_skew == 3 & neg_skew == 2

replace info_preferences = 7 if no_info == 2 & certain_info == 1 & pos_skew == 3 & neg_skew == 4

replace info_preferences = 8 if no_info == 2 & certain_info == 1 & pos_skew == 4 & neg_skew == 3

replace info_preferences = 9 if no_info == 2 & certain_info == 3 & pos_skew == 1 & neg_skew == 4

replace info_preferences = 10 if no_info == 2 & certain_info == 3 & pos_skew == 4 & neg_skew == 1

replace info_preferences = 11 if no_info == 2 & certain_info == 4 & pos_skew == 3 & neg_skew == 1

replace info_preferences = 12 if no_info == 2 & certain_info == 4 & pos_skew == 1 & neg_skew == 3

replace info_preferences = 13 if no_info == 3 & certain_info == 1 & pos_skew == 2 & neg_skew == 4

replace info_preferences = 14 if no_info == 3 & certain_info == 1 & pos_skew == 4 & neg_skew == 2

replace info_preferences = 15 if no_info == 3 & certain_info == 2 & pos_skew == 1 & neg_skew == 4

replace info_preferences = 16 if no_info == 3 & certain_info == 2 & pos_skew == 4 & neg_skew == 1

replace info_preferences = 17 if no_info == 3 & certain_info == 4 & pos_skew == 2 & neg_skew == 1

replace info_preferences = 18 if no_info == 3 & certain_info == 4 & pos_skew == 1 & neg_skew == 2

replace info_preferences = 19 if no_info == 4 & certain_info == 1 & pos_skew == 2 & neg_skew == 3

replace info_preferences = 20 if no_info == 4 & certain_info == 1 & pos_skew == 3 & neg_skew == 2

replace info_preferences = 21 if no_info == 4 & certain_info == 2 & pos_skew == 1 & neg_skew == 3

replace info_preferences = 22 if no_info == 4 & certain_info == 2 & pos_skew == 3 & neg_skew == 1

replace info_preferences = 23 if no_info == 4 & certain_info == 3 & pos_skew == 1 & neg_skew == 2

replace info_preferences = 24 if no_info == 4 & certain_info == 3 & pos_skew == 2 & neg_skew == 1

tab info_preferences

** Info vs. None
gen full = 0
label var full "Prefer Most Info > No Info"
foreach i in 7 8 13 14 15 16 19 20 21 22 23 24 {
	replace full = 1 if info_preferences == `i'
}

gen pos = 0
label var pos "Prefer Pos Skew > No Info"
foreach i in 9 12 13 15 17 18 19 20 21 22 23 24 {
	replace pos = 1 if info_preferences == `i'
}

gen neg = 0
label var neg "Prefer Neg Skew > > No Info"
foreach i in 10 11 14 16 17 18 19 20 21 22 23 24 {
	replace neg = 1 if info_preferences == `i'
}

** Avoider if no information preferred to full information
gen avoid = 1
replace avoid = 0 if certain_info < no_info
label var avoid "Prefer No Info > Most Info"


keep no_info certain_info pos_skew neg_skew full pos neg avoid gender education age

label variable age "age"
label variable education "highest education"
label variable gender "gender"

label define genderl 1 "female" 2 "male" 
label define educl 1 "Less than high school" 2 "High school graduate" 3 "Some college" 4 "2 year degree" 5 "4 year degree" 6 "Professional or Master's degree" 7 "Doctorate"
label values gender genderl
label values education educl

label data "This file contains IQ Test Experiment Results for Replication" 

save "Data/Output/IQdata.dta", replace

