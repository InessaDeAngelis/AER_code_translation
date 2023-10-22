
use "$root/Data/Output/Exp2.dta", clear

/*This do file generates TABLE 2. For a more user-friendly code that displays the same information as the STATA output, please see below.
  
sum early abit_early pos_extreme pos_slight pos_inter  
foreach q in early abit_early pos_extreme pos_slight pos_inter { 
	bitest `q'==.5
}
*/

******** TABLE 2 *********
local preferences "(1,1)>(0.5,0.5) (0.55,0.55)>(0.5,0.5) (0.5,1)>(1,0.5) (0.3,0.9)>(0.9,0.3) (0.6,0.9)>(0.9,0.6)"


putexcel set table2, replace
// headings
	putexcel A1=("Question") B1=("N") C1=("Preferences") D1=("Percentage") E1=("p-value")  

// Q1, Q5b
	putexcel A2 = "Early vs Late" 

	bitest early == 0.5
	local N = r(N)
	local pref = "(1,1)>(0.5,0.5)"
	local percent = round(r(k)/r(N)*100)
	local p = round(r(p),0.001)	
	putexcel A3 =("Q1") B3=(`N') C3=("`pref'") D3=("`percent'%") E3=(`p') 
	
	bitest abit_early == 0.5
	local N = r(N)
	local pref = "(1,1)>(0.5,0.5)"
	local percent = round(r(k)/r(N)*100)
	local p = round(r(p),0.001)	
	putexcel A4 =("Q5b") B4=(`N') C4=("(0.55,0.55)>(0.5,0.5)") D4=("`percent'%") E4=(`p') 
	
	

// Q2, Q3, Q5a	
	putexcel A5 = "Positively Skewed vs. Negatively Skewed" 

	bitest pos_extreme == 0.5
	local N = r(N)
	local pref = "(0.5,1)>(1,0.5)"
	local percent = round(r(k)/r(N)*100)
	local p = round(r(p),0.001)	
	putexcel A6 =("Q2") B6=(`N') C6=("`pref'") D6=("`percent'%") E6=(`p') 
	
	bitest pos_slight == 0.5
	local N = r(N)
	local pref = "(0.3,0.9)>(0.9,0.3)"
	local percent = round(r(k)/r(N)*100)
	local p = round(r(p),0.001)	
	putexcel A7 =("Q3") B7=(`N') C7=("`pref'") D7=("`percent'%") E7=(`p') 
	
	bitest pos_inter == 0.5
	local N = r(N)
	local pref = "(0.6,0.9)>(0.9,0.6)"
	local percent = round(r(k)/r(N)*100)
	local p = round(r(p),0.001)	
	putexcel A8 =("Q5b") B8=(`N') C8=("`pref'") D8=("`percent'%") E8=(`p') 
	
	
putexcel save
