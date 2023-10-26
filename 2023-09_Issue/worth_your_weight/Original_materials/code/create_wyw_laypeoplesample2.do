
**# Creating second laypeople data

**# Qualtrics sample

	use $path/rawdata/wyw_laypeople_sample2_clean.dta, clear   //previously "pilot_spring_uga.dta"

	* define outcomes
	bys key: g avg_income_diff = ave_income_fig8[_n] - ave_income_fig2[_n]
	g avg_income_diff_usd =  avg_income_diff*0.00027

	// create categories and label for table
	encode sex, g(gender)
	replace gender = 0 if gender ==2
	label var gender "Gender: Female"
	drop sex
	
	
	tabulate age, generate(a)
	
	label var a1  "Age: 18 to 24"
	label var a2  "\phantom{Age:} 25 to 35"
	label var a3  "\phantom{Age:} 35 to 44"
	label var a4  "\phantom{Age:} 55 to 64"

	drop a6
	
	tabulate income, g(i)
	
	label var i1 "\phantom{Personal income:} Average"
	label var i2 "\phantom{Personal income:} Far above average"
	label var i3 "Personal income: Far below average"
	label var i4 "\phantom{Personal income:} Moderately above average"
	label var i5 "\phantom{Personal income:} Moderately below average"
	label var i6 "\phantom{Personal income:} Slightly above average"
	label var i7 "\phantom{Personal income:} Slightly below average"
	
	tabulate education, g(e)
				
	label var e1  "\phantom{Education:} Two year degree"
	label var e2  "Education: Primary school"
	label var e3  "\phantom{Education:} Professional degree"
	label var e4  "\phantom{Education:} Secondary school"
	label var e5  "\phantom{Education:} Some college"

	g personal_income_usd = personal_income*0.00027
	
	label var personal_income_usd "Personal income (month, USD)"
	
	g personal_income_mln = personal_income/1000000

	label var personal_income_mln "Personal income (month, Ush million)"
	
	label var bmi_value "BMI"
	
	
	
	save $path/input/wyw_laypeople_sample2.dta, replace
