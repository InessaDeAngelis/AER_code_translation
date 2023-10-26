use "$root/Data/Output/Exp2.dta", clear


**TABLE 9 Choice frequencies by sequence of evaluation


/*
This do file generates TABLE 9. For a more user-friendly code that displays the same information as the STATA output, please see below.
  
tabstat  pos_slight pos_inter abit_early, by(condition) 
tab pos_slight condition, chi2
tab pos_inter condition, chi2
tab abit_early condition, chi2
*/

label var pos_slight "(0.3,0.9)>(0.9,0.3)"
label var pos_inter "(0.6,0.9)>(0.9,0.6)"
label var abit_early "(0.55,0.55)>(0.5,0.5)"

putexcel set tableB2, replace
// headings
	putexcel A1:A2=("") B1:C1=("Condition 1") E1:F1=("Condition 2"), merge hcenter
	putexcel D1=("Difference") B2=("N") C2=("Percentage") D2=("p-value") E2=("Percentage") F2=("N"), hcenter

	
// table values
	local row = 3
	foreach var of varlist pos_slight pos_inter abit_early  {

		local pref: variable label `var'
		
		tabstat `var', by(condition) stat(N, mean) save 
	
		local N_1 = r(Stat1)[1,1]
		local mean_1 = round(r(Stat1)[2,1] * 100, 1)
		
		local N_2 = r(Stat2)[1,1]
		local mean_2 = round(r(Stat2)[2,1]*100, 1)
		
		tabulate `var' condition, chi2 matcell(x)
		local p = round(r(p), 0.001)
		

		putexcel A`row'=("`pref'") B`row'=(`N_1') C`row'=("`mean_1'%") D`row'=(`p') E`row'=("`mean_2'%") F`row'=(`N_2')
		local row = `row' + 1
	
	}
	
	
putexcel save
	
