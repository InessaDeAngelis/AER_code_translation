	use $path/rawdata/wyw_malawi_clean.dta, clear 

	cap drop outcome_*

	egen outcome_1 = std(food_4)
	egen outcome_2 = std(food_1)
	egen outcome_3 = std(food_2)
	egen outcome_4 = std(food_3)
	egen outcome_5 = std(food_5)
	
	label var outcome_1 Creditworthiness
	label var outcome_2 Wealth
	label var outcome_3 Authority
	label var outcome_4 Dating
	label var outcome_5 Beauty

	

	save $path/input/wyw_malawi.dta, replace
