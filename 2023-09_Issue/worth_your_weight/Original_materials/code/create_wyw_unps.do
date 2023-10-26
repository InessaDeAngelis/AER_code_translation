
**# Create UNPS database
	global unpsdata    $path/rawdata/UGA_2019_UNPS_v03_M_STATA14

	
	**# Import identifier data and append with anthropometrics (s2) and credit (s7)
		
	local dbs gsec1 gsec2 gsec6_5 gsec7_1 gsec7_4  
	foreach d of local dbs {
		
			use $unpsdata/HH/`d'.dta, clear
			generate str hhid_string = hhid
			replace hhid = ""
			compress hhid
			replace hhid = hhid_string
			drop hhid_string
			describe hhid
			
			save $path/temp/temp_`d'.dta, replace
		}

	use $path/temp/temp_gsec1.dta, clear

	merge 1:m hhid using $path/temp/temp_gsec2.dta
	drop _m*

	merge 1:1 hhid pid using $path/temp/temp_gsec6_5.dta 					// anthropometrics
	drop _m*

	merge m:1 hhid using $path/temp/temp_gsec7_1.dta 		     			// savings + credit
	drop _m*
	
	merge m:1 hhid pid using $path/temp/temp_gsec7_4.dta						
	drop _m*


	// keep identifiers, demographics, anthropometrics and credit vars
	keep dc_2018 district hhid pid pid_unps_wave7 h2q3 h2q4 h2q8 district ///
		s6q28b s6q28b2 s6q27a CB12* CB16* CB14* CB15*
	


**# kampala area code
	g gkla = (dc_2018 ==102 | dc_2018 ==108 | dc_2018 ==113)
	
	* age
	rename h2q8 age 
	label var age "Age (years)"

	* anthropometrics
	egen temp_height = rowmean(s6q28b s6q28b2)
	gen  height_m    = temp_height/100
	label var height_m  "Height (m)"
	drop temp_height 

	rename s6q27a weight_kg  
	label var weight_kg "Weight (kg)"
	
	gen bmi = weight_kg/(height_m*height_m)
	label var bmi "BMI"
	
	cap drop obese
	g obese = bmi >=30 & bmi!=. 
	replace obese =. if bmi==.

	g over = bmi >=25 & bmi!=.
	replace over =. if bmi==.
	
	g normal_weight = bmi>=18 & bmi <25
	
	bys hhid: g obese_hh = sum(obese)
	bys hhid: g over_hh = sum(over)
	replace  over_hh = 1 if  over_hh>0 &  over_hh!=.
	replace  over_hh = 1 if  obese_hh>0 &  obese_hh!=.

	
	// credit variables

	g borrowed = CB12 ==1  
	replace borrowed=. if CB12_1>1   // missing or person not there
	
	cap drop non_profit
	g non_profit = (  CB16__2==1  | CB16__13==1 |  ///
					  CB16__4 ==1 | CB16__6 ==1 |  ///
				      CB16__9 ==1 | CB16__10 ==1)  // source of credit/savings: ROSCAs, welfare fund, NGOs, burial society, VSLAs
	
			 
	g repayed_lastyear  = CB14a ==1				// has person paid back during last year
	replace repayed_lastyear=. if CB12_1>1 & CB12_1!=.

	
	* labels 
	label var normal_weight "Normal weight"
	label var over Overweight
	label var obese Obese
	
	label var non_profit "Non-profit institution"
	label def non_profit 0 "For profit institution" 1 "Non-profit institution"
	label val non_profit non_profit
	
	label var gkla "Kampala"	
	
	label var obese_hh "Obese household members"
	label var over_hh "Overweight household members"

	label var borrowed "Borrowed last year"
	label var repayed_lastyear "Repayed last year"

**# Sample selection: adults & measure of BMI
	keep if age > 18 & age !=.  //adults
	keep if bmi!=.
	
**# winsorize bmi outliers
	sum bmi, detail
	replace  bmi = `r(p1)'  if bmi < `r(p1)' 		          // winsorize (bmi outliers)
	replace  bmi = `r(p99)' if bmi > `r(p99)'  & bmi !=.  

**# Save in input
	
	save $path/input/wyw_unps_credit_bmi.dta, replace

	
	

	