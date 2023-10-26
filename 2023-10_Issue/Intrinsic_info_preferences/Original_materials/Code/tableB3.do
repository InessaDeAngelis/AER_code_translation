 use "$root/Data/Output/Exp2.dta", clear
  
// Create variables that reverse the order in Q4 variables
// 1 if 0, 0 if 1
// This is because in the raw data, 

foreach var of varlist Q4A_C1 Q4A_C2 Q4B_C1 Q4B_C2 {
	gen `var'_R = !`var'
	gen `var'_R_pref = `var'_pref
}



label var early "(1,1)>(0.5,0.5)"
label var pos_extreme "(0.5,1)>(1,0.5)"
label var pos_slight "(0.3,0.9)>(0.9,0.3)"
label var pos_inter "(0.6,0.9)>(0.9,0.6)"
label var Q4A_C1_R "(0.76,0.76)>(0.3,0.9)"
label var Q4A_C2_R "(0.67,0.67)>(0.1,0.95)"
label var Q4B_C1_R "(0.55,0.55)>(0.3,0.9)"
label var Q4B_C2_R "(0.66,0.66)>(0.5,1)"
label var abit_early "(0.55,0.55)>(0.5,0.5)"


putexcel set tableB3, replace

// headings
	matrix input column_head = (0,1,2,3,4,5,6,7,8,9,10)
	putexcel A1:A3=("") B1:M1=("Preference Strength")  B2:L2=("Distribution") N1:N3=("Difference p-value") M2:M3=("Avg"), merge  hcenter vcenter
	putexcel  B3=matrix(column_head), hcenter
	
	

local variablelist early  pos_extreme pos_slight pos_inter  Q4A_C1_R Q4A_C2_R Q4B_C1_R Q4B_C2_R abit_early
 	
 
 
// Early vs Late
	putexcel A4:N4=("Early vs. Late"), merge
	local row = 5
	foreach cc in 1 {
		local var: word `cc' of `variablelist'
		// Displayed Preferences
		local pref1: variable label `var'
		local pos = strpos("`pref1'", ">")
		local pref_1 = substr("`pref1'", 1, `pos'-1)
		local pref_2 = substr("`pref1'", `pos'+1,.)
		local pref0 = "`pref_2'>`pref_1'"

		// Tabulated values
		matrix define values1 = (.,.,.,.,.,.,.,.,.,.,.)
		matrix define values0 = (.,.,.,.,.,.,.,.,.,.,.)
		forvalues i = 0/10 {
			count if `var'_pref == `i' & `var' == 1
			matrix values1[1, `i'+1] = r(N)
			
			count if `var'_pref == `i' & `var' == 0
			matrix values0[1, `i'+1] = r(N)
		}
	
		// Mean and p-value of differences
		ttest `var'_pref, by(`var') 
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel N`row':N`row_plus1'=(`p'), merge hcenter vcenter
		putexcel A`row'=("`pref1'") A`row_plus1'=("`pref0'") B`row'=matrix(values1) B`row_plus1'=matrix(values0) M`row'=(`mean1') M`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
	
	
// Pos Skewed vs Negatively skewed
	putexcel A7:N7=("Positively Skewed vs. Negatively Skewed"), merge
	local row = 8
	foreach cc in 2 3 4 {
		local var: word `cc' of `variablelist'
		// Displayed Preferences
		local pref1: variable label `var'
		local pos = strpos("`pref1'", ">")
		local pref_1 = substr("`pref1'", 1, `pos'-1)
		local pref_2 = substr("`pref1'", `pos'+1,.)
		local pref0 = "`pref_2'>`pref_1'"

		// Tabulated values
		matrix define values1 = (.,.,.,.,.,.,.,.,.,.,.)
		matrix define values0 = (.,.,.,.,.,.,.,.,.,.,.)
		forvalues i = 0/10 {
			count if `var'_pref == `i' & `var' == 1
			matrix values1[1, `i'+1] = r(N)
			
			count if `var'_pref == `i' & `var' == 0
			matrix values0[1, `i'+1] = r(N)
		}
	
		// Mean and p-value of differences
		ttest `var'_pref, by(`var') 
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel N`row':N`row_plus1'=(`p'), merge hcenter vcenter
		putexcel A`row'=("`pref1'") A`row_plus1'=("`pref0'") B`row'=matrix(values1) B`row_plus1'=matrix(values0) M`row'=(`mean1') M`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
	
	
// Pos Skewed vs Symmetric
	putexcel A14:N14=("Positively Skewed vs. Symmetric"), merge
	local row = 15
	foreach cc in 5 6 7 8 {
		local var: word `cc' of `variablelist'
		// Displayed Preferences
		local pref1: variable label `var'
		local pos = strpos("`pref1'", ">")
		local pref_1 = substr("`pref1'", 1, `pos'-1)
		local pref_2 = substr("`pref1'", `pos'+1,.)
		local pref0 = "`pref_2'>`pref_1'"

		// Tabulated values
		matrix define values1 = (.,.,.,.,.,.,.,.,.,.,.)
		matrix define values0 = (.,.,.,.,.,.,.,.,.,.,.)
		forvalues i = 0/10 {
			count if `var'_pref == `i' & `var' == 1
			matrix values1[1, `i'+1] = r(N)
			
			count if `var'_pref == `i' & `var' == 0
			matrix values0[1, `i'+1] = r(N)
		}
	
		// Mean and p-value of differences
		ttest `var'_pref, by(`var') 
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel N`row':N`row_plus1'=(`p'), merge hcenter vcenter
		putexcel A`row'=("`pref1'") A`row_plus1'=("`pref0'") B`row'=matrix(values1) B`row_plus1'=matrix(values0) M`row'=(`mean1') M`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
	
	
// Gradual vs Late
	putexcel A23:N23=("Gradual vs. Late"), merge
	local row = 24
	foreach cc in 9 {
		local var: word `cc' of `variablelist'
		// Displayed Preferences
		local pref1: variable label `var'
		local pos = strpos("`pref1'", ">")
		local pref_1 = substr("`pref1'", 1, `pos'-1)
		local pref_2 = substr("`pref1'", `pos'+1,.)
		local pref0 = "`pref_2'>`pref_1'"

		// Tabulated values
		matrix define values1 = (.,.,.,.,.,.,.,.,.,.,.)
		matrix define values0 = (.,.,.,.,.,.,.,.,.,.,.)
		forvalues i = 0/10 {
			count if `var'_pref == `i' & `var' == 1
			matrix values1[1, `i'+1] = r(N)
			
			count if `var'_pref == `i' & `var' == 0
			matrix values0[1, `i'+1] = r(N)
		}
	
		// Mean and p-value of differences
		ttest `var'_pref, by(`var') 
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel N`row':N`row_plus1'=(`p'), merge hcenter vcenter
		putexcel A`row'=("`pref1'") A`row_plus1'=("`pref0'") B`row'=matrix(values1) B`row_plus1'=matrix(values0) M`row'=(`mean1') M`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
	
	
putexcel save
