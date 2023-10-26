use "$root/Data/Output/Exp1.dta", clear

/*
This do file generates TABLE 6. For a more user-friendly code that displays the same information as the STATA output, please see below.

foreach cc in 1 2 3 4 5 6 7 8 9 10 {
preserve
keep if treatment==`cc'
tab infostrength choice
tabstat infostrength, by(choice)
ttest infostrength , by(choice)
restore
}
*/

local preferences "(1,1)>(0.5,0.5) (0.5,1)>(1,0.5) (0.3,0.9)>(0.9,0.3) (0.6,0.9)>(0.9,0.6) (0.5,1)>(0.5,0.5) (0.3,0.9)>(0.5,0.5) (1,0.5)>(0.5,0.5) (0.9,0.3)>(0.5,0.5) (0.79,0.79)>(0.5,0.5) (0.63,0.63)>(0.5,0.5)"

putexcel set tableA2, replace

// headings
	matrix input column_head = (0,1,2,3,4,5,6,7,8,9,10)
	putexcel A1:B3=("") C1:N1=("Preference Strength")  C2:M2=("") O1:O3=("Difference p-value") N2:N3=("Avg"), merge  hcenter vcenter
	putexcel  C3=matrix(column_head), hcenter
	
// get tabulation output
	tab infostrength treatment if choice == 1, matcell(choice1)
	tab infostrength treatment if choice == 0, matcell(choice0)
	
// T1
	putexcel A4:O4=("Early vs. Late"), merge
	local row = 5
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
		ttest infostrength if treatment == `cc' , by(choice)
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel A`row':A`row_plus1'=("T`cc'") O`row':O`row_plus1'=(`p'), merge hcenter vcenter
		putexcel B`row'=("`pref1'") B`row_plus1'=("`pref0'") C`row'=matrix(values1) C`row_plus1'=matrix(values0) N`row'=(`mean1') N`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
	

	
// T2, T3, T4
	putexcel A7:O7=("Positively Skewed vs. Negatively Skewed"), merge
	local row = 8
	foreach cc in 2 3 4 { 
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
		ttest infostrength if treatment == `cc' , by(choice)
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel A`row':A`row_plus1'=("T`cc'") O`row':O`row_plus1'=(`p'), merge hcenter vcenter
		putexcel B`row'=("`pref1'") B`row_plus1'=("`pref0'") C`row'=matrix(values1) C`row_plus1'=matrix(values0) N`row'=(`mean1') N`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
		

// T5, T6
	putexcel A14:O14=("Positively Skewed vs. Late"), merge
	local row = 15
	foreach cc in 5 6 { 
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
		ttest infostrength if treatment == `cc' , by(choice)
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel A`row':A`row_plus1'=("T`cc'") O`row':O`row_plus1'=(`p'), merge hcenter vcenter
		putexcel B`row'=("`pref1'") B`row_plus1'=("`pref0'") C`row'=matrix(values1) C`row_plus1'=matrix(values0) N`row'=(`mean1') N`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
	
	

// T7, T8
	putexcel A19:O19=("Negatively Skewed vs. Late"), merge
	local row = 20
	foreach cc in 7 8 { 
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
		ttest infostrength if treatment == `cc' , by(choice)
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel A`row':A`row_plus1'=("T`cc'") O`row':O`row_plus1'=(`p'), merge hcenter vcenter
		putexcel B`row'=("`pref1'") B`row_plus1'=("`pref0'") C`row'=matrix(values1) C`row_plus1'=matrix(values0) N`row'=(`mean1') N`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
				
				
				
// T9, T10
	putexcel A24:O24=("Gradual vs. Late"), merge
	local row = 25
	foreach cc in 9 10 { 
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
		ttest infostrength if treatment == `cc' , by(choice)
		local mean1 = round(r(mu_2), 0.01)
		local mean0 = round(r(mu_1), 0.01)
		local p = round(r(p), 0.001)
		
		local row_plus1 = `row' + 1
		putexcel A`row':A`row_plus1'=("T`cc'") O`row':O`row_plus1'=(`p'), merge hcenter vcenter
		putexcel B`row'=("`pref1'") B`row_plus1'=("`pref0'") C`row'=matrix(values1) C`row_plus1'=matrix(values0) N`row'=(`mean1') N`row_plus1'=(`mean0'), hcenter 	
		
		local row = `row'+2
	}
		

putexcel save
