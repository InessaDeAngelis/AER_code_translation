
use "Data/Input/Exp1_input.dta", clear
destring info*, force replace

 
gen choicemajor=0
replace choicemajor=1 if infochoice == 1 & treatment==1  
replace choicemajor=1 if infochoice == 2 & treatment==2  
replace choicemajor=1 if infochoice == 1 & treatment==3  
replace choicemajor=1 if infochoice == 2 & treatment==4  
replace choicemajor=1 if infochoice == 2 & treatment==5  
replace choicemajor=1 if treatment==6 & infochoice==1 & wave==2
replace choicemajor=1 if treatment==7 & infochoice==2 & wave==2
replace choicemajor=1 if treatment==8 & infochoice==1 & wave==2
replace choicemajor=1 if treatment==9 & infochoice==2 & wave==2
replace choicemajor=1 if treatment==10 & infochoice==1 & wave==2
 
 
label variable choicemajor "Choice Corresponds to the Option Preferred by Majority"
label define mc_ 0 "No" 1 "Yes" 
label values choicemajor mc_

foreach x in 1 5 10 15 20 25 30 35 40 50{
replace info`x' = info`x' - 1	
label var info`x' "Would switch choice for `x' cents"
label define info`x'_ 0 "No" 1 "Yes" 
label values info`x' info`x'_
}
 

*adjust scale to reflect 0 -- 10
replace infostrength=infostrength-1

label variable infostrength "Preference Strength for Chosen over Unchosen Option"


**define minimum compensation required to switch from chosen option to rejected option
gen wta_min=0.1 
foreach x in 1 5 10 15 20 25 30 35 40 50{
replace wta_min=`x'.1 if info`x'==0
}
 
label var wta_min "MCTS (min compensation to switch) from chosen option to rejected option"
 
**define information premia for the majority chosen option
**if the majority's favorite is rejected by the individual, the information premia is negative 
gen infoprem = 	wta_min if 	choicemajor==1
replace infoprem = - wta_min if 	choicemajor==0
label var infoprem "Information Premia (re choicemajor)"


label var treatment "Treatment"
label define tr_ 1 "T1" 2 "T2" 3 "T3" 4 "T4" 5 "T5" 6 "T6" 7 "T7" 8 "T8" 9 "T9" 10 "T10"
label values treatment tr_

label var wave "Experimental Wave"
label define w_ 1 "Summer 2015" 2 "Winter/Spring 2017" 
label values wave w_

label data "This file contains Experiment 1 Results for Replication" 

save "Data/Output/Exp1.dta", replace
 

  
