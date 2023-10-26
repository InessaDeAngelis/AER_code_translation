use "$root/Data/Output/Exp3.dta", clear

local preferences "(1,1)>(0.5,0.5) (0.5,0.69)>(0.84,0.35) (0.34,0.82)>(0.94,0.21)"

putexcel set tableC2, replace


// Headers
	putexcel B1:E1=("Prior 10%") F1:G1=("") H1:K1=("Prior 90%"), merge hcenter
	putexcel B2=("N") C2=("Preferences") D2=("Pct") E2=("p-value") F2=("Diff") G2=("p-value") H2=("p-value") I2=("Pct") J2=("Preferences") K2=("N") 

local row = 3
forvalues x = 1/3 {
	// Displayed Preferences
		local pref1: word `x' of `preferences'
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
		
		if `x' == 1 {
				local pref9 = "`pref_2_inv'<`pref_1_inv'"
			}
		if `x' != 1 {
				local pref9 = "`pref_1_inv'<`pref_2_inv'"
			}
	
	
	// Left panel
		bitest choicemajor==.5 if condition==`x' & prior==10
		local N1 = r(N)
		local percent1 = round(r(k)/r(N)*100, 1)
		local p1 = round(r(p),0.001) 
	
	
	
	// Right panel
		bitest choicemajor==.5 if condition==`x' & prior==90
		local N9 = r(N)
		local percent9 = round(r(k)/r(N)*100, 1)
		local p9 = round(r(p),0.001) 
	
	// Middle Panel
		ttest choice if condition == `x', by(prior)
		local diff = round((r(mu_2) - r(mu_1))*100, 1)
		tabulate choicemajor prior if condition == `x', chi2
		local chi2 = round(r(p),0.001)
	
	putexcel A`row'=("C`x'") B`row'=(`N1') C`row'=("`pref1'") D`row'=("`percent1'%") E`row'=(`p1') F`row'=("`diff'%") G`row'=(`chi2') H`row'=(`p9') I`row'=("`percent9'%") J`row'=("`pref9'") K`row'=(`N9'), hcenter
	
	local row = `row'+1
}
putexcel save

 
