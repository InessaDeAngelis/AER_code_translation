
use "Data/Input/Exp3_input.dta", clear

rename q378 infochoice
rename q107 infostrength
rename q50_1 info1
rename q50_2 info5
rename q50_3 info10
rename q50_4 info15
rename q50_5 info20
rename q50_6 info25
rename q50_7 info30
rename q50_8 info35
rename q50_9 info40
rename q50_10 info50

label var info1 "Would switch choice for 1 cent"
label var info5 "Would switch for 5 cents"
label var info10 "Would switch for 10 cents"
label var info15 "Would switch for 15 cents"
label var info20 "Would switch for 20 cents"
label var info25 "Would switch for 25 cents"
label var info30 "Would switch for 30 cents"
label var info35 "Would switch for 35 cents"
label var info40 "Would switch for 40 cents"
label var info50 "Would switch for 50 cents"


destring info*, force replace

/* infochoice (also indicated in Table 12 of Appendix)
infochoice=1 when option 1 is chosen, infochoice=2 when option 2 is chosen

prior 10
C1 option 1 (1,1) option 2 (.5,.5)
C2 option 1 (.5,.69) option 2 (.84,.35)
C3 option 1 (.94,.21) option 2 (.34,.82)

prior 90
C1 option 1 (1,1) option 2 (.5,.5)
C2 option 1 (.69,.5) option 2 (.35,.84)
C3 option 1 (.21, .94) option 2 (.82, .34)
*/


replace infostrength = infostrength-1

tab infochoice if condition==1 & prior==10
gen choicemajor=1 if infochoice==1 & condition==1 & prior==10
tab infochoice if condition==1 & prior==90
replace choicemajor=1 if infochoice==1 & condition==1 & prior==90

tab infochoice if condition==2 & prior==10
replace choicemajor=1 if infochoice==1 & condition==2 & prior==10
tab infochoice if condition==2 & prior==90
replace choicemajor=1 if infochoice==2 & condition==2 & prior==90
 
tab infochoice if condition==3 & prior==10
replace choicemajor=1 if infochoice==2 & condition==3 & prior==10
tab infochoice if condition==3 & prior==90
replace choicemajor=1 if infochoice==1 & condition==3 & prior==90
replace choicemajor=0 if choicemajor==.
drop infochoice

keep choicemajor condition prior school infostrength info* 
label variable infostrength "Preference Strength for Chosen over Unchosen Option"
label variable prior "Treatment: Prior Level"
label variable school "Experimental Location"
label variable choicemajor "Choice Corresponds to the Option Preferred by Majority"
label define mc_ 0 "No" 1 "Yes" 
label values choicemajor mc_
label variable condition "Condition"
label define cc_ 1 "C1" 2 "C2" 3 "C#" 
label values condition cc_  



foreach x in 1 5 10 15 20 25 30 35 40 50{
replace info`x' = info`x' - 1	
label var info`x' "Would switch choice for `x' cents"
label define info`x'_ 0 "No" 1 "Yes" 
label values info`x' info`x'_
}
 

**define minimum compensation required to switch from chosen option to rejected option
gen wta_min=0.1 
foreach x in 1 5 10 15 20 25 30 35 40 50{
replace wta_min=`x'.1 if info`x'==0
}
 
label var wta_min "MCTS (min compensation to switch) from chosen option to rejected option"
 


label data "This file contains Experiment 3 Results for Replication" 


save "Data/Output/Exp3.dta",replace  

