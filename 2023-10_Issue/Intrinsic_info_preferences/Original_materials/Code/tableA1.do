 use "$root/Data/Output/Exp1.dta", clear

 
 /*
This do file generates TABLE 5. For a more user-friendly code that displays the same information as the STATA output, please see below.

foreach x in 1 2 3 4 5 {
preserve 
keep if treatment==`x'
tabstat choice, by(wave)
tabulate wave choice, chi2
restore
}
*/

local preferences "(1,1)>(0.5,0.5) (0.5,1)>(1,0.5) (0.3,0.9)>(0.9,0.3) (0.6,0.9)>(0.9,0.6) (0.5,1)>(0.5,0.5)"

putexcel set tableA1, replace
// headings
	putexcel A1:B1=("") C1:D1=("1st Wave") E1=("Takers") F1:G1=("2nd Wave")
	putexcel A2:B2=("") C2=("N") D2=("Percentage") E2=("p-value") F2=("Percentage") G2=("N")

foreach x in 1 2 3 4 5 {
	preserve 
	keep if treatment==`x'
	local pref: word `x' of `preferences'
	
	tabstat choice, by(wave) stat(N, mean) save 

	local N_1 = r(Stat1)[1,1]
	local mean_1 = round(r(Stat1)[2,1] * 100, 1)
	
	local N_2 = r(Stat2)[1,1]
	local mean_2 = round(r(Stat2)[2,1]*100, 1)
	
	tabulate wave choice, chi2 matcell(x)
	local p = round(r(p), 0.001)
	restore
	
	local row = `x' + 2
	putexcel A`row'=("T`x'") B`row'=("`pref'") C`row'=(`N_1') D`row'=("`mean_1'%") E`row'=(`p') F`row'=("`mean_2'%") G`row'=(`N_2')
}
putexcel save
