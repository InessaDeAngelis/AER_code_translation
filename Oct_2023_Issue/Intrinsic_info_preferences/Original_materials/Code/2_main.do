
** MAIN TEXT RESULTS

** To run this file, please make sure to run 0_setup.do and 1_data_setup.do first.
 
/*
The following do files generate the Figures and Tables in the main text.
The do file names correspond to the Figure/Table number.
*/
 
cd "$root/Results"

**Experiment 1 Results 
do "$root/Code/table1.do"
do "$root/Code/Figure3.do"

*Experiment 2 Results
do "$root/Code/table2.do" 
do "$root/Code/table3.do" 
 
*AD results
do "$root/Code/Figure4.do"

** IQ test results 
do "$root/Code/table4.do" 

 
/*
The following do files generate the statistics mentioned in the main text.
The filenames correspond to the studies.
*/ 

do "$root/Code/Exp1_text.do"
do "$root/Code/Exp2_text.do"
do "$root/Code/AD_text.do"
do "$root/Code/IQ_text.do"
