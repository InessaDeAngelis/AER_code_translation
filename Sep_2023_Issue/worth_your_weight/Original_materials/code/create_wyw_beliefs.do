** Creating WYW beliefs data
	
	clear all
	// import raw data
	use $path/rawdata/wyw_beliefs_clean.dta, clear


	// Standardize first order beliefs
	egen z_attr_1b        = std(attr_1b)
	egen z_wealth_1b      = std(wealth_1b)
	egen z_health_1b      = std(health_1b)
	egen z_selfcontrol_1b = std(selfcontrol_1b)
	egen z_lifeexp_1b     = std(lifeexp_1b)
	egen z_ability_1b     = std(ability_1b)
	egen z_trust_1b       = std(trust_1b)

	// Standardize second order beliefs
	
	egen z_attr_2b   		= std(attr_2b)
	egen z_wealth_2b        = std(wealth_2b)
	egen z_health_2b        = std(health_2b)
	egen z_selfcontrol_2b   = std(selfcontrol_2b)
	egen z_lifeexp_2b       = std(lifeexp_2b)
	egen z_ability_2b       = std(ability_2b)
	egen z_trust_2b         = std(trust_2b)
	
	// Information Treatment 
	
	cap drop other_signal
	g other_signal = info_treat>0 & info_treat!=.
	

	// keep variables relevant for analysis
	keep respondent_id pic_* order  info_treat other_signal ///
		 wealth_1b attr_1b health_1b lifeexp_1b selfcontrol_1b ability_1b trust_1b ///
		 wealth_2b attr_2b health_2b lifeexp_2b selfcontrol_2b ability_2b trust_2b ///
		  z_*   
		 
	order respondent_id pic_* order info_treat other_signal ///
		 wealth_1b attr_1b health_1b lifeexp_1b selfcontrol_1b ability_1b trust_1b ///
		 wealth_2b attr_2b health_2b lifeexp_2b selfcontrol_2b ability_2b trust_2b ///
		  z_*   

		 
    // labels 

	label var z_wealth_1b "Wealth (std)"
	label var z_attr_1b "Beauty (std)"
	label var z_health_1b "Health (std)"
	label var z_lifeexp_1b "Life expectancy  (std)"
	label var z_selfcontrol_1b "Self-control (std)"
	label var z_ability_1b "Ability (std)"
	label var z_trust_1b "Trustworthiness (std)" 
	
	label var z_wealth_2b "Wealth (beliefs about others beliefs, std)"
	label var z_attr_2b "Beauty (beliefs about others beliefs, std)"
	label var z_health_2b "Health (beliefs about others beliefs, std)"
	label var z_lifeexp_2b "Life expectancy  (beliefs about others beliefs, std)"
	label var z_selfcontrol_2b "Self-control  (beliefs about others beliefs, std)"
	label var z_ability_2b "Ability  (beliefs about others beliefs, std)"
	label var z_trust_2b "Trustworthiness (beliefs about others beliefs, std)"
	
	
	label def other_signal 0 "No information" 1 "Additional wealth signal"
	label val other_signal other_signal
	label var other_signal "Information treatment (binary)"
	
	label def info_treat_lab  0 "No information" 1 "Lives in slum" 2 "Owns car or land title"
	label val info_treat info_treat_lab
	label var info_treat "Information treatment (type)"


	label def idinst 1 "Financial institutions"
	
	
	label def idrole5 1 "General population" ///
					  2 "Loan officers"  ///
					  3 "Financial institutions" 
	

	label def pic_male  0 "Female" 1 "Male"
	label val pic_male pic_male
	label var pic_male "Portrait Sex"
	
	label var pic_age  "Portrait Age"
	label var pic_high_bm  "Portrait Obesity Status"

	
	label def obese           0 "Not Obese" 1 "Obese"
	label val pic_high_bm obese
	// save
	save $path/input/wyw_beliefs_main.dta, replace 

