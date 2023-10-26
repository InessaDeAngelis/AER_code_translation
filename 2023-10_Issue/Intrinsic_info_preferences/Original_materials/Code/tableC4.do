use "$root/Data/Output/Exp3.dta", clear


local preferences "(1,1)>(0.5,0.5) (0.5,0.69)>(0.84,0.35) (0.34,0.82)>(0.94,0.21)"

putexcel set tableC4, replace


// Headers

	matrix input column_head = (0,1,2,3,4,5,6,7,8,9,10)
	putexcel A1:B3=("") C1:N1=("Preference Strength")  O1:O3=("Difference p-value") N2:N3=("Avg") C2:M2=("Distribution"), merge  hcenter vcenter
	putexcel A4:O4=("Prior 10%") A11:O11=("Prior 90%"), merge
	putexcel  C3=matrix(column_head), hcenter


local row_iterator = 0
foreach cc in 1 2 3   {
	
	// Get preference labels from preferences for prior 10 and prior 90 
			local pref1: word `cc' of `preferences'
			local pos = strpos("`pref1'", ">")
			local pref_1 = substr("`pref1'", 1, `pos'-1)
			local pref_2 = substr("`pref1'", `pos'+1,.)
			
			local pref_1_pos = strpos("`pref_1'", ",")
			local pref_1_1 = substr("`pref_1'", 2, `pref_1_pos'-2)
			local pref_1_2_pos = strpos("`pref_1'", ")") 
			local pref_1_2 = substr("`pref_1'", `pref_1_pos'+1, `pref_1_2_pos'-`pref_1_pos'-1)
			local pref_1_inv = "(`pref_1_2', `pref_1_1')"
			
			local pref_2_pos = strpos("`pref_2'", ",")
			local pref_2_1 = substr("`pref_2'", 2, `pref_2_pos'-2)
			local pref_2_2_pos = strpos("`pref_2'", ")") 
			local pref_2_2 = substr("`pref_2'", `pref_2_pos'+1,`pref_2_2_pos'-`pref_2_pos'-1)
			local pref_2_inv = "(`pref_2_2', `pref_2_1')"
			
			if `cc' == 1 {
				local pref9 = "`pref_1_inv'>`pref_2_inv'"
			}
			if `cc' != 1 {
				local pref9 = "`pref_2_inv'>`pref_1_inv'"
			}
		
	// Prior 10
		local row = 5 + `row_iterator'
		// Displayed Preferences
			local pref = "`pref1'"
			local pos = strpos("`pref'", ">")
			local pref_1 = substr("`pref'", 1, `pos'-1)
			local pref_2 = substr("`pref'", `pos'+1,.)
			local inv_pref = "`pref_2'>`pref_1'"
			
		// Tabulated values
			matrix define values1 = (.,.,.,.,.,.,.,.,.,.,.)
			matrix define values0 = (.,.,.,.,.,.,.,.,.,.,.)
			forvalues i = 0/10 {
				count if infostrength == `i' & condition == `cc' & prior == 10 & choicemajor == 1
				matrix values1[1, `i'+1] = r(N)
				
				count if infostrength == `i' & condition == `cc' & prior == 10 & choicemajor == 0
				matrix values0[1, `i'+1] = r(N)
			}
			
		
		// Mean and p-value of differences
			ttest infostrength if condition == `cc' & prior == 10 , by(choicemajor)
			local mean1 = round(r(mu_2), 0.01)
			local mean0 = round(r(mu_1), 0.01)
			local p = round(r(p), 0.001)
			
		local row_plus1 = `row' + 1
		putexcel A`row':A`row_plus1'=("C`cc'") O`row':O`row_plus1'=(`p'), merge hcenter vcenter
		putexcel B`row'=("`pref'") B`row_plus1'=("`inv_pref'") C`row'=matrix(values1) C`row_plus1'=matrix(values0) N`row'=(`mean1') N`row_plus1'=(`mean0'), hcenter 	
		
		
		
	// Prior 90
		local row = 12 + `row_iterator'
		// Displayed Preferences
		
		
			local pref = "`pref9'"
			local pos = strpos("`pref'", ">")
			local pref_1 = substr("`pref'", 1, `pos'-1)
			local pref_2 = substr("`pref'", `pos'+1,.)
			local inv_pref = "`pref_2'>`pref_1'" 
			
			
		// Tabulated values
			matrix define values1 = (.,.,.,.,.,.,.,.,.,.,.)
			matrix define values0 = (.,.,.,.,.,.,.,.,.,.,.)
			forvalues i = 0/10 {
				count if infostrength == `i' & condition == `cc' & prior == 90 & choicemajor == 1
				matrix values1[1, `i'+1] = r(N)
				
				count if infostrength == `i' & condition == `cc' & prior == 90 & choicemajor == 0
				matrix values0[1, `i'+1] = r(N)
			}
		
		// Mean and p-value of differences
			ttest infostrength if condition == `cc' & prior == 90 , by(choicemajor)
			local mean1 = round(r(mu_2), 0.01)
			local mean0 = round(r(mu_1), 0.01)
			local p = round(r(p), 0.001)
			
		local row_plus1 = `row' + 1
		putexcel A`row':A`row_plus1'=("C`cc'") O`row':O`row_plus1'=(`p'), merge hcenter vcenter
		putexcel B`row'=("`pref'") B`row_plus1'=("`inv_pref'") C`row'=matrix(values1) C`row_plus1'=matrix(values0) N`row'=(`mean1') N`row_plus1'=(`mean0'), hcenter 	
		
	local row_iterator = `row_iterator'+2
	
		
		
	
		
	} 
	
	


putexcel save