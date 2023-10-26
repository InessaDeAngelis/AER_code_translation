use "$root/Data/Output/Exp1.dta", clear
 
/*
This do file generates TABLE 7. For a more user-friendly code that displays the same information as the STATA output, please see below.

foreach cc in 1 2 3 4 5 6 7 8 9 10 {
preserve
keep if treatment==`cc'
tab wta_min choice
tabstat wta_min, by(choice)
ttest wta_min , by(choice)
restore
}
*/


local preferences "(1,1)>(0.5,0.5) (0.5,1)>(1,0.5) (0.3,0.9)>(0.9,0.3) (0.6,0.9)>(0.9,0.6) (0.5,1)>(0.5,0.5) (0.3,0.9)>(0.5,0.5) (1,0.5)>(0.5,0.5) (0.9,0.3)>(0.5,0.5) (0.79,0.79)>(0.5,0.5) (0.63,0.63)>(0.5,0.5)"

putexcel set tableA3, replace

// headings
	matrix input column_head = (0.1,1.1,5.1,10.1,15.1,20.1,25.1,30.1,35.1,40.1,50.1)
	putexcel A1:B2=("") C1:M1=("Minimum Compensation Required to Switch (cents)")  O1:O2=("Difference p-value") N1:N2=("Avg. Cond'l Premia"), merge  hcenter vcenter
	putexcel  C2=matrix(column_head), hcenter
	
// get tabulation output
	tab wta_min treatment if choice == 1, matcell(choice1)
	tab wta_min treatment if choice == 0, matcell(choice0)
	
	
// T1
	putexcel A3:O3=("Early vs. Late"), merge
	local row = 4
	foreach cc in 1 {
		// Displayed Preferences
		local pref1: word `cc' of `preferences'
		local pos = strpos("`pref1'", ">")
		local pref_1 = substr("`pref1'", 1, `pos'-1)
		local pref_2 = substr("`pref1'", `pos'+1,.)
		local pref0 = "`pref_2'>`pref_1'"

		// Tabulated values
		matrix define values1 = choice1[1..11, `cc']'
		matrix define values0 = choice0[1..11, `cc']'
	
		// Mean and p-value of differences
		ttest wta_min  if treatment == `cc' , by(choice)
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel A`row':A`row_plus1'=("T`cc'") O`row':O`row_plus1'=(`p'), merge hcenter vcenter
		putexcel B`row'=("`pref1'") B`row_plus1'=("`pref0'") C`row'=matrix(values1) C`row_plus1'=matrix(values0) N`row'=(`mean1') N`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
	

	
// T2, T3, T4
	putexcel A6:O6=("Positively Skewed vs. Negatively Skewed"), merge
	local row = 7
	foreach cc in 2 3 4 { // 2 3 4 5 6 7 8 9 10 {
		// Displayed Preferences
		local pref1: word `cc' of `preferences'
		local pos = strpos("`pref1'", ">")
		local pref_1 = substr("`pref1'", 1, `pos'-1)
		local pref_2 = substr("`pref1'", `pos'+1,.)
		local pref0 = "`pref_2'>`pref_1'"

		// Tabulated values
		matrix define values1 = choice1[1..11, `cc']'
		matrix define values0 = choice0[1..11, `cc']'
	
		// Mean and p-value of differences
		ttest wta_min  if treatment == `cc' , by(choice)
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel A`row':A`row_plus1'=("T`cc'") O`row':O`row_plus1'=(`p'), merge hcenter vcenter
		putexcel B`row'=("`pref1'") B`row_plus1'=("`pref0'") C`row'=matrix(values1) C`row_plus1'=matrix(values0) N`row'=(`mean1') N`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
		

// T5, T6
	putexcel A13:O13=("Positively Skewed vs. Late"), merge
	local row = 14
	foreach cc in 5 6 { // 2 3 4 5 6 7 8 9 10 {
		// Displayed Preferences
		local pref1: word `cc' of `preferences'
		local pos = strpos("`pref1'", ">")
		local pref_1 = substr("`pref1'", 1, `pos'-1)
		local pref_2 = substr("`pref1'", `pos'+1,.)
		local pref0 = "`pref_2'>`pref_1'"

		// Tabulated values
		matrix define values1 = choice1[1..11, `cc']'
		matrix define values0 = choice0[1..11, `cc']'
	
		// Mean and p-value of differences
		ttest wta_min  if treatment == `cc' , by(choice)
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel A`row':A`row_plus1'=("T`cc'") O`row':O`row_plus1'=(`p'), merge hcenter vcenter
		putexcel B`row'=("`pref1'") B`row_plus1'=("`pref0'") C`row'=matrix(values1) C`row_plus1'=matrix(values0) N`row'=(`mean1') N`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
	
	

// T7, T8
	putexcel A18:O18=("Negatively Skewed vs. Late"), merge
	local row = 19
	foreach cc in 7 8 { // 2 3 4 5 6 7 8 9 10 {
		// Displayed Preferences
		local pref1: word `cc' of `preferences'
		local pos = strpos("`pref1'", ">")
		local pref_1 = substr("`pref1'", 1, `pos'-1)
		local pref_2 = substr("`pref1'", `pos'+1,.)
		local pref0 = "`pref_2'>`pref_1'"

		// Tabulated values
		matrix define values1 = choice1[1..11, `cc']'
		matrix define values0 = choice0[1..11, `cc']'
	
		// Mean and p-value of differences
		ttest wta_min  if treatment == `cc' , by(choice)
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel A`row':A`row_plus1'=("T`cc'") O`row':O`row_plus1'=(`p'), merge hcenter vcenter
		putexcel B`row'=("`pref1'") B`row_plus1'=("`pref0'") C`row'=matrix(values1) C`row_plus1'=matrix(values0) N`row'=(`mean1') N`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
				
				
				
// T9, T10
	putexcel A23:O23=("Gradual vs. Late"), merge
	local row = 24
	foreach cc in 9 10 { // 2 3 4 5 6 7 8 9 10 {
		// Displayed Preferences
		local pref1: word `cc' of `preferences'
		local pos = strpos("`pref1'", ">")
		local pref_1 = substr("`pref1'", 1, `pos'-1)
		local pref_2 = substr("`pref1'", `pos'+1,.)
		local pref0 = "`pref_2'>`pref_1'"

		// Tabulated values
		matrix define values1 = choice1[1..11, `cc']'
		matrix define values0 = choice0[1..11, `cc']'
	
		// Mean and p-value of differences
		ttest wta_min  if treatment == `cc' , by(choice)
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel A`row':A`row_plus1'=("T`cc'") O`row':O`row_plus1'=(`p'), merge hcenter vcenter
		putexcel B`row'=("`pref1'") B`row_plus1'=("`pref0'") C`row'=matrix(values1) C`row_plus1'=matrix(values0) N`row'=(`mean1') N`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
		

putexcel save
