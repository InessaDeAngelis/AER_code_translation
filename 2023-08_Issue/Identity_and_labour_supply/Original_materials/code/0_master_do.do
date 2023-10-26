* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* PROJECT:			Does Identity Affect Labor Supply?
* RESEARCHER:		Suanna Oh (PSE)
* TASK:				Run all the replication codes
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

clear all
timer on 1
set more off

version 14

// SSC install estout if not installed already
* quietly ssc install estout


// Set filepath to IdentityReplicationAER folder here
global path 			"C:/Users/s.oh/Dropbox/Occupation and Identity/Replication" 


// Run the codes

run "$path/code/1_job_takeup_clean.do"			// clean the main experiment data and save: choice_jobtakeup_wide.dta and choice_jobtakeup_analysis.dta
run "$path/code/2_job_takeup_analyze.do"		// make tables/figures using cleaned data from the main experiment
run "$path/code/3_bonus_takeup_clean.do"		// clean the supplementary experiment data and save: choice_bonuswage_analysis.dta
run "$path/code/4_bonus_takeup_analyze.do"		// make tables/figures using cleaned data from the supplementary experiment 
run "$path/code/5_task_survey.do"				// clean and analyze task survey data
run "$path/code/6_rank_survey.do"				// clean and analyze rank survey data


timer off 1
timer list 1

