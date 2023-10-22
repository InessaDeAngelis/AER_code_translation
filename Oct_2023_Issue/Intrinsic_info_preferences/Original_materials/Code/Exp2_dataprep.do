 
use  "Data/Input/Exp2_input.dta", clear


*the following code recodes qualtrics data encoding to align data across two conditions that had a different order of presenting the questions as well as a different oder of options in some questions (see below and Table 8 in Appendix of WP)
/* 
Condition 1.
Q1. Option 1: (1, 1) vs. Option 2: (.5, .5)
Q2. Option 1: (1, .5) vs. Option 2: (.5, 1)
Q3. Option 1: (.9, .3) vs. Option 2: (.3, .9)
Q5a. Option 1 (.9, .6) vs. Option 2 (.6, .9)
Q5b. Option 1: (.55, .55) vs. Option 2: (.5, .5)

Condition 2.
Q1. Option 1: (.5, .5) vs. Option 2: (1, 1)
Q2. Option 1: (.5, 1) vs. Option 2: (1, .5)
Q3. Option 1 (.9, .6) vs. Option 2 (.6, .9)
Q5a. Option 1: (.9, .3) vs. Option 2: (.3, .9)
Q5b. Option 1: (.5, .5) vs. Option 2: (.55, .55)
*/


**NOTE: preferece strength is a scale of 1-11 in the recorded data,but the rating showes 0-10 to subjects. So we subtract 1 below from *_pref variables to reflect the rating.

foreach x in Q1_pref  Q2_pref Q3_pref Q4A_pref Q4B_pref Q5A_pref Q5B_pref{
	replace `x'=`x'-1
}


**we align definition of choices and preference strength  

gen early=(Q1==1&condition==1)|(Q1==2&condition==2)
replace early=. if (Q1==.&condition==1)|(Q1==.&condition==2)

gen early_pref= Q1_pref 
replace early_pref =. if (Q1==.&condition==1)|(Q1==.&condition==2)

gen pos_extreme=(Q2==2&condition==1)|(Q2==1&condition==2)
replace pos_extreme=. if (Q2==.&condition==1)|(Q2==.&condition==2)

gen pos_extreme_pref=Q2_pref 
replace pos_extreme_pref =. if (Q2==.&condition==1)|(Q2==.&condition==2)
 
gen pos_slight=(Q3==2&condition==1)| (Q5A==2&condition==2)
replace pos_slight=. if (Q5A==. & condition==2)
replace pos_slight=. if (Q3==. & condition==1)

gen pos_slight_pref = Q3_pref  if condition==1
replace pos_slight_pref = Q5A_pref  if condition==2
replace pos_slight_pref=. if (Q5A==. & condition==2)
replace pos_slight_pref =. if (Q3==. & condition==1)
 
gen pos_inter=(Q5A==2&condition==1)| (Q3==2&condition==2)
replace pos_inter =. if (Q5A==. & condition==1)
replace pos_inter =. if (Q3==. & condition==2)

gen pos_inter_pref= Q5A_pref  if cond==1
replace pos_inter_pref= Q3_pref  if cond==2
replace pos_inter_pref =. if (Q5A==. & condition==1)
replace pos_inter_pref =. if (Q3==. & condition==2)

gen abit_early=(Q5B==1&condition==1)|(Q5B==2&condition==2)
replace abit_early=. if (Q5B==.&condition==1)|(Q5B==.&condition==2)
gen abit_early_pref= Q5B_pref 


**recode Q4A and Q4B monotonicity (define = 1 if not tradeoff information and skewness, = 0 if they do) The options that would correspond to the preffered ones under monotonicity are marked with * below
/*
Condition 1
Q4a. Option 1: (.76, .76)* vs. Option 2: (.3, .9) if (1,1)>(.5.5)
Q4b. Option 1: (.55, .55)* vs. Option 2: (.3, .9) if (1,1)<(.5.5)
Condition 2
Q4a. Option 1: (.67, .67)* vs. Option 2: (.1, .95) if (1,1)>(.5.5)
Q4b. Option 1: (.66, .66)* vs. Option 2: (.5, 1) if (1,1)<(.5.5)

*/

 
gen Q4A_C1=Q4A-1 if condition==1
gen Q4A_C1_pref=Q4A_pref if condition==1

gen Q4A_C2=Q4A-1 if condition==2
gen Q4A_C2_pref=Q4A_pref if condition==2

gen monot_taker = 1 if Q4A_C1==0|Q4A_C2==0
replace monot_taker=0 if (monot_taker==. & early==1)
sum monot_taker

gen Q4B_C1=Q4B-1 if condition==1
gen Q4B_C1_pref=Q4B_pref if condition==1

gen Q4B_C2=Q4B-1 if condition==2
gen Q4B_C2_pref=Q4B_pref if condition==2

gen monot_avoid = 1 if Q4B_C1==0|Q4B_C2==0
replace monot_avoid=0 if (monot_avoid==. & early==0)
sum monot_avoid


gen monot=monot_taker
replace monot=monot_avoid if monot==.

 
label var monot "Indicator for  preference ordering that reflects a consistent preference for informativeness across Q1 and Q4 answers"
label define m_ 0 "No" 1 "Yes"
label values monot m_

label var monot_avoid "(Among Information Avoiders) Indicator for  preference ordering that reflects a consistent preference for informativeness across Q1 and Q4 answers"
label values monot_avoid m_

label var monot_taker "(Among Information Non-Avoiders) Indicator for  preference ordering that reflects a consistent preference for informativeness across Q1 and Q4 answers"
label values monot_taker m_

label var early "Chose (1, 1) ≻ (0.5, 0.5) in Q1"
label var early_pref "Preference Strength for Chosen over Unchosen Option in Q1"

label var pos_extreme "Chose (0.5, 1) ≻ (1, 0.5) in Q2"
label var pos_extreme_pref "Preference Strength for Chosen over Unchosen Option in Q2"

label var pos_slight "Chose (0.3, 0.9) ≻ (0.9, 0.3) in Q3"
label var pos_slight_pref   "Preference Strength for Chosen over Unchosen Option in Q3"
label var pos_inter "Chose (0.6, 0.9) ≻ (0.9, 0.6) in Q5a"
label var pos_inter_pref "Preference Strength for Chosen over Unchosen Option in Q5a"
label var abit_early "Chose (.55, .55) ≻ (0.5, 0.5) in Q5b"
label var abit_early_pref "Preference Strength for Chosen over Unchosen Option in Q5b"

label var Q4A_C1 "(Among Information non-Avoiders in Condition 1) Chose (0.3, 0.9) ≻ (0.76, 0.76) in Q4a"
label var Q4A_C1_pref "Preference Strength for Chosen over Unchosen Option in Q4a (Condition 1)"

label var Q4A_C2 "(Among Information non-Avoiders in Condition 2) Chose (0.1, 0.95) ≻ (0.67, 0.67) in Q4a"
label var Q4A_C2_pref "Preference Strength for Chosen over Unchosen Option in Q4a (Condition 2)"

label var Q4B_C1 "(Among Information non-Avoiders  Condition 1) Chose (0.3, 0.9) ≻ (0.55, 0.55) in Q4b"
label var Q4B_C1_pref "Preference Strength for Chosen over Unchosen Option in Q4b (Condition 1)"

label var Q4B_C2 "(Among Information non-Avoiders in Condition 2) Chose (0.5, 1) ≻ (0.66, 0.66) in Q4b"
label var Q4B_C2_pref "Preference Strength for Chosen over Unchosen Option in Q4b (Condition 2)"


keep *_pref condition Q4A* Q4B* early pos_extreme pos_slight pos_inter  abit_early monot*  

label data "This file contains Experiment 2 Results for Replication" 



save "Data/Output/Exp2.dta", replace
