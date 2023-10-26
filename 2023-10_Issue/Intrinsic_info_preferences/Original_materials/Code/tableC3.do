use "$root/Data/Output/Exp3.dta", clear

local preferences "(1,1)>(0.5,0.5) (0.5,0.69)>(0.84,0.35) (0.34,0.82)>(0.94,0.21)"

putexcel set tableC3, replace


// Headers
putexcel A1:B2=("") C1:D1=("U of M") F1:G1=("U Mass"), merge hcenter
putexcel C2=("N") D2=("Percentage") E2=("p-value") E1=("Difference") G2=("N") F2=("Percentage") 

putexcel A3:G3=("Prior 10%") A7:G7=("Prior 90%"), merge

forvalues cc = 1/3 {
		// Displayed Preferences
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
			
		
		// N and % (10)
			tabstat choicemajor if prior == 10 & condition == `cc' , by(school) stat(N mean) save
			local N_10_um = r(Stat2)[1,1]
			local pct_10_um = round(r(Stat2)[2,1]*100, 1)
			local N_10_am = r(Stat1)[1,1]
			local pct_10_am = round(r(Stat1)[2,1]*100, 1)
		
		// N and % (90)
			tabstat choicemajor if prior == 90 & condition == `cc' , by(school) stat(N mean) save
			local N_90_um = r(Stat2)[1,1]
			local pct_90_um = round(r(Stat2)[2,1]*100, 1)
			local N_90_am = r(Stat1)[1,1]
			local pct_90_am = round(r(Stat1)[2,1]*100, 1)
		
		// Chi2 (10)
			tabulate choicemajor school if prior == 10 & condition == `cc', chi2
			local p10 = round(r(p), 0.001)
		
		// Chi2 (90)
			tabulate choicemajor school if prior == 90 & condition == `cc', chi2
			local p90 = round(r(p), 0.001)
		
		local row10 = `cc' + 3
		local row90 = `cc' + 7
		
		putexcel A`row10'=("C`cc'") B`row10'=("`pref1'") C`row10'=(`N_10_um') D`row10'=("`pct_10_um'%") E`row10'=(`p10') F`row10'=("`pct_10_am'%") G`row10'=(`N_10_am') A`row90'=("C`cc'") B`row90'=("`pref9'") C`row90'=(`N_90_um') D`row90'=("`pct_90_um'%") E`row90'=(`p90') F`row90'=("`pct_90_am'%") G`row90'=(`N_90_am')

		
		
	
}

putexcel save
