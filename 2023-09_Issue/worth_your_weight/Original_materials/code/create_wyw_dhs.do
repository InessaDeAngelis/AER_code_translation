**# Create DHS data for analysis in Macchi (2021)

**# Input aggregate wealth quintiles data from DHS (includes also data from CDC )

	use $path/rawdata-dhs/IPUMS_DHS_IR_aggregate_2017.dta, clear  // Note for replicator: UPDATE WITH YOUR FILENAME & PATH
	
	
	**# PREP DHS DATA:        
	
	/* Note to replicator: the part of the code that is commented out cleans the DHS IR country file to select the relevant variables. 
	I recomment running this code iteratively by country before appending the data.
	
	
	// Keep selected variables: country code, year of 
	// interview, age, wealth index, currently pregnant

	keep v000 v007 v012 v190 v213 v445

	// Keep adults only
	drop if v012 < 18 

	// Drop pregnant women
	drop if v213 == 1 

	// Generate obesity variable
	gen BMI30 = v445 >= 30 & !missing(v445)

	// Extract first two digits from v000 as country code
	gen str2 countrycode2 = substr(v000, 1, 2)
	
	*/
		
	* only if wealth quintile data available
	keep if WealthQuint!=.  

	* waves after 2010
	bys CountryName: egen maxYear= max(Year)
	keep if Year == maxYear // last available year only
	drop if maxYear<2010 
	drop maxYear

	
**# convert WB GDP data to dta

	preserve
	import excel $path/rawdata/GdpPcPPP.xlsx, firstrow clear 
    save $path/temp/GdpPcPPP.dta, replace
	restore

	
**# Append Eurostat

	preserve
	import excel $path/rawdata/eu_obesity_13.xlsx, firstrow clear 
	
	* rename as in DHS
	rename (GEOBMI Quintile) (CountryName WealthQuint)
	
	* average across sex and year
	bys CountryName WealthQuint: egen BMI30 = mean(Obese)
	
	* merge with gdp pc data worldbank
		 
	
	merge m:1 CountryName using  $path/temp/GdpPcPPP.dta
	drop if _m!=3
	

	keep Year WealthQuint BMI30 CountryCode CountryName GdpPcPPP 
	
	g EU =1
	label var EU EU

    save $path/temp/Eurostat_byIncome_2013.dta, replace
	
	restore
	
**# Append Eurostat

    append using $path/temp/Eurostat_byIncome_2013.dta

	
**# Append CDC (US level data)
	 
	preserve
	import excel $path/rawdata/usa_obesity_13.xlsx, firstrow clear 
    save $path/temp/CDC_byIncome_2013.dta, replace
	restore
	
    append using $path/temp/CDC_byIncome_2013.dta

	label var Year Year
	label var WealthQuint WealthQuint
	label var BMI30 BMI30
	label var CountryCode CountryCode
	label var CountryName CountryName
	label var GdpPcPPP GdpPcPPP
	
**# income group variable (world bank thresholds)
	cap drop IG
	g IG=.
	replace IG=1 if GdpPcPPP<=3895
	replace IG=2 if GdpPcPPP>=3896 & GdpPcPPP<=12055
	replace IG=3 if GdpPcPPP>=12056 & GdpPcPPP!=.
	
	replace IG=3 if CountryCode =="USA"

	replace IG =1 if CountryName=="India" // data missing
	replace IG =1 if CountryName=="Ghana" // data missing

		
	label define IG   1 "Low and lower middle income" ///
					2 "Middle income" 3 "High income"
					
	label val IG IG
	label var IG IG
	
	
**# Save
	save $path/input/wyw_dhs_wealthquint.dta, replace
	
	
