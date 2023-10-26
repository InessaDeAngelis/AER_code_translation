
** APPENDIX (ADDITIONAL RESULTS)

** To run this file, please make sure to run 0_setup.do and 1_data_setup.do first.
 
/*
The following do files generate the Figures and Tables in the appendix.
The do file names correspond to the Figure/Table number.
*/
 
cd "$root/Results"

**Experiment 1 appendix 
do "$root/Code/tableA1.do"
do "$root/Code/tableA2.do"
do "$root/Code/tableA3.do"

 
*Experiment 2 appendix
do "$root/Code/tableB2.do"
do "$root/Code/tableB3.do"
do "$root/Code/tableB4.do"
 
  
*Experiment 3 appendix
do "$root/Code/tableC2.do"
do "$root/Code/tableC3.do"
do "$root/Code/tableC4.do"
do "$root/Code/tableC5.do"
  

*IQ appendix
do "$root/Code/FigureE1.do"


 
