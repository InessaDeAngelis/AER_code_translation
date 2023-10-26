use "$root/Data/Output/Exp1.dta", clear

/*
This do file generates TABLE 1. For a more user-friendly code that displays the same information as the STATA output, please see below.
**TABLE 1 (N, Percentage, p-value)

bitest choicemajor==.5 if treatment==1
bitest choicemajor==.5 if treatment==2
bitest choicemajor==.5 if treatment==3
bitest choicemajor==.5 if treatment==4
bitest choicemajor==.5 if treatment==5
bitest choicemajor==.5 if treatment==6
bitest choicemajor==.5 if treatment==7
bitest choicemajor==.5 if treatment==8
bitest choicemajor==.5 if treatment==9
bitest choicemajor==.5 if treatment==10
 
** TABLE 1 (Information Premia)
tabstat infoprem, by(treatment) stat(mean)
*/
 
recast double infoprem, force
local preferences "(1,1)>(0.5,0.5) (0.5,1)>(1,0.5) (0.3,0.9)>(0.9,0.3) (0.6,0.9)>(0.9,0.6) (0.5,1)>(0.5,0.5) (0.3,0.9)>(0.5,0.5) (1,0.5)>(0.5,0.5) (0.9,0.3)>(0.5,0.5) (0.79,0.79)>(0.5,0.5) (0.63,0.63)>(0.5,0.5)"

putexcel set table1, replace
// headings
	putexcel A1=("Treatment") B1=("N") C1=("Preferences") D1=("Percentage") E1=("p-value") F1=("Info. Premia") 


// t1
	putexcel A2 = "Early vs Late" 
	summarize infoprem if treatment == 1
	local info_prem = round(r(mean), 0.1)

	bitest choicemajor==.5 if treatment==1
	local N = r(N)
	local pref: word 1 of `preferences'
	local percent = round(r(k)/r(N)*100)
	local p = round(r(p),0.001)

	putexcel A3 =("T1") B3=(`N') C3=("`pref'") D3=("`percent'%") E3=(`p') F3=("`info_prem'c")

// t2, t3, t4 
	putexcel A4 = "Positively Skewed vs. Negatively Skewed"
	forvalues i = 2/4 {
		summarize infoprem if treatment == `i'
		local info_prem = round(r(mean), 0.1)
		
		bitest choicemajor==.5 if treatment == `i'
		local N = r(N)
		local pref: word `i' of `preferences'
		local percent = round(r(k)/r(N)*100)
		local p = round(r(p),0.001)
		
		local row = 3 +`i'
		putexcel A`row'=("T`i'") B`row'=(`N') C`row'=("`pref'") D`row'=("`percent'%") E`row'=(`p') F`row'=("`info_prem'c")
	}
	
	
// t5, t6
	putexcel A8 = "Positively Skewed vs. Late"
	forvalues i = 5/6 {
		summarize infoprem if treatment == `i'
		local info_prem = round(r(mean), 0.1)
		
		bitest choicemajor==.5 if treatment == `i'
		local N = r(N)
		local pref: word `i' of `preferences'
		local percent = round(r(k)/r(N)*100)
		local p = round(r(p),0.001)
		
		local row = 4 +`i'
		putexcel A`row'=("T`i'") B`row'=(`N') C`row'=("`pref'") D`row'=("`percent'%") E`row'=(`p') F`row'=("`info_prem'c")
	}
	
// t7, t8
	putexcel A11 = "Negatively Skewed vs. Late"
	forvalues i = 7/8 {
		summarize infoprem if treatment == `i'
		local info_prem = round(r(mean), 0.1)
		
		bitest choicemajor==.5 if treatment == `i'
		local N = r(N)
		local pref: word `i' of `preferences'
		local percent = round(r(k)/r(N)*100)
		local p = round(r(p),0.001)
		
		local row = 5 +`i'
		putexcel A`row'=("T`i'") B`row'=(`N') C`row'=("`pref'") D`row'=("`percent'%") E`row'=(`p') F`row'=("`info_prem'c")
	}

// t9,10
	putexcel A14 = "Gradual vs. Late"
	forvalues i = 9/10 {
		summarize infoprem if treatment == `i'
		local info_prem = round(r(mean), 0.1)
		
		bitest choicemajor==.5 if treatment == `i'
		local N = r(N)
		local pref: word `i' of `preferences'
		local percent = round(r(k)/r(N)*100)
		local p = round(r(p),0.001)
		
		local row = 6 +`i'
		putexcel A`row'=("T`i'") B`row'=(`N') C`row'=("`pref'") D`row'=("`percent'%") E`row'=(`p') F`row'=("`info_prem'c")
	}

	

putexcel save  
