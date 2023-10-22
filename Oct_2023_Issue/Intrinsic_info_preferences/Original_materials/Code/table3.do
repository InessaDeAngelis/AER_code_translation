use "$root/Data/Output/Exp2.dta", clear

 /*
This do file generates TABLE 3. For a more user-friendly code that displays the same information as the STATA output, please see below.
  
**top 2 rows
tabstat monot_taker , by(condition)
bitest monot_taker ==.5 if condition==1
bitest monot_taker ==.5 if condition==2

**bottom 2 rows
tabstat monot_avoid , by(condition)
bitest monot_avoid ==.5 if condition==1
bitest monot_avoid ==.5 if condition==2

*/

******** TABLE 3 *********
putexcel set table3, replace
// headings
	putexcel A1=("Question") B1=("N") C1=("Preferences") D1=("Percentage") E1=("p-value")
	
// Q4a
	putexcel A2 = ("Asked to those who chose (1,1)>(.5,.5)")
	putexcel A3 = ("Information vs. Positive Skewness")
	bitest monot_taker ==.5 if condition==1
	local N = r(N)
	local pref = "(0.76,0.76)>(0.3,0.9)"
	local percent = round(r(k)/r(N)*100)
	local p = round(r(p_u),0.001)	
	putexcel A4 =("Q4a") B4=(`N') C4=("`pref'") D4=("`percent'%") E4=(`p') 
	
	bitest monot_taker ==.5 if condition==2
	local N = r(N)
	local pref = "(0.67,0.67)>(0.1,0.95)"
	local percent = round(r(k)/r(N)*100)
	local p = round(r(p_u),0.001)	
	putexcel A5 =("Q4a") B5=(`N') C5=("`pref'") D5=("`percent'%") E5=(`p') 


// Q4b
	putexcel A6 = ("Asked to those who chose (.5,.5)>(1,1)")
	bitest monot_avoid ==.5 if condition==1
	local N = r(N)
	local pref = "(0.55,0.55)>(0.3,0.9)"
	local percent = round(r(k)/r(N)*100)
	local p = round(r(p_u),0.001)	
	putexcel A7 =("Q4b") B7=(`N') C7=("`pref'") D7=("`percent'%") E7=(`p') 
	
	bitest monot_avoid ==.5 if condition==2
	local N = r(N)
	local pref = "(0.66,0.66)>(0.5,0.1)"
	local percent = round(r(k)/r(N)*100)
	local p = round(r(p_u),0.001)	
	putexcel A8 =("Q4b") B8=(`N') C8=("`pref'") D8=("`percent'%") E8=(`p') 
	
putexcel save
