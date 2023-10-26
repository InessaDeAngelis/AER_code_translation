* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* PROJECT:			Does Identity Affect Labor Supply?
* RESEARCHER:		Suanna Oh (PSE)
* TASK:				Clean the main experiment data
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*					<< Sections >>
* 
*		1.  Generate survey variables
*		2.  Reshape data
*		3.  Generate variables for analysis
* 		
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Generate survey variables
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

use "$path/data/choice_jobtakeup.dta", clear


** Section B : Demographics

gen age=b1_age if !mi(b1_age)

gen married=b2_marital_status==1 if !mi(b2_marital_status)

gen famsize= b3_hh_adults + b3_hh_all_children if b3_hh_all_children>=0 & b3_hh_adults>=0 & !mi(b3_hh_all_children,b3_hh_adults)

gen workmember=b4_act_engage_paid_work if b4_act_engage_paid_work<=famsize & b4_act_engage_paid_work>=0

gen workshare=workmember/famsize

gen year_edu=b5_high_level_edu_class if inrange(b5_high_level_edu_class,0,12)		// top coded at 12
replace year_edu=0 if b5_high_level_edu==0
replace year_edu=0 if b5_high_level_edu==1 & b5_high_level_edu_class<0
replace year_edu=12 if inlist(b5_high_level_edu,2,3,4)

gen read_odiya=b6_read_odiya_paper if inlist(b6_read_odiya_paper,0,1)

gen pucca_house=b7_dwell_type==1 if !mi(b7_dwell_type)
gen semipucca_house=b7_dwell_type==2 if !mi(b7_dwell_type)
gen kutcha_house=b7_dwell_type==3 if !mi(b7_dwell_type)

gen gunta = 0
replace gunta = b8_own_land_gunta if b8_own_land_gunta>=0 

gen acre = 0
replace acre = b8_own_land_acre if b8_own_land_acre>=0 

gen landsize=gunta/40 + acre if !mi(b8_own_land)

gen own_land = b8_own_land==1 | b8_own_land==2 if !mi(b8_own_land)
replace own_land=0 if landsize==0

gen income=b9_hh_tot_income_last_mm if b9_hh_tot_income_last_mm>=0
gen log_income = log(income+(income^2+1)^.5) if !mi(income) // inverse hyperbolic sine

gen paid_days=b12_get_paid_7days

foreach x of varlist b13a_sew_mach_own b13b_bicycle_own b13c_motorbike_own b13d_fridge_own b13e_radio_own b13f_tv_own b13g_mobile_own b13h_land_phone_own b13i_stove_own b13j_watches_own {
	local varname=substr("`x'",strpos("`x'","_")+1,.)
	gen `varname'=`x'>0 if !mi(`x')
}

egen own_index=rowtotal(sew_mach_own bicycle_own motorbike_own fridge_own radio_own tv_own mobile_own land_phone_own stove_own watches_own), missing

	//	Wealth PCA
sum age year_edu read_odiya married famsize workmember workshare kutcha_house semipucca_house pucca_house own_land landsize income log_income paid_days sew_mach_own bicycle_own motorbike_own fridge_own radio_own tv_own mobile_own land_phone_own stove_own watches_own
pca workshare kutcha_house semipucca_house own_land landsize log_income paid_days sew_mach_own bicycle_own motorbike_own fridge_own radio_own tv_own mobile_own land_phone_own stove_own watches_own

	// temporarily fill mean values for 5 observations with missing values for PCA scores
foreach x of varlist workshare log_income { 	// FIX
	gen `x'_miss = `x'
	order `x'_miss , after(`x')
	qui sum `x', det
	replace `x'=r(p50) if mi(`x')
}

predict wealth_pca, score  
drop workshare log_income
rename *_miss *

sum wealth_pca, det
gen hiwealth=wealth_pca>r(p50) if !mi(wealth_pca)

sum year_edu, det
gen hiedu=year_edu>r(p50) if !mi(year_edu)

sum age, det
gen old=age>r(p50) if !mi(age)

sum paid_days, det
gen hijobs=paid_days>r(p50) if !mi(paid_days)



** Section C : refusal reasons 


rename	c1a_agree_make_rope	agree10
rename	c1b_reason_not_make_rope1	reason1_not10
rename  c1b_reason_not_make_rope2   reason2_not10
rename  c1b_reason_not_make_rope3   reason3_not10
rename	c1b_reason_not_make_rope_oth	reason_not_sfy10
rename	c1c_migrate_make_rope	migrate10
rename	c1c_migrate_make_rope_oth	migrate_oth10
rename	c1d_extent_make_rope	extent1_10
rename	c1d_extent_make_rope_oth	extent_oth10
rename	c1e_perform_make_rope	perform10
rename	c1e_perform_make_rope_oth	perform_oth10
rename	c2a_agree_pnut_dshel	agree9
rename	c2b_reason_not_pnut_dshel	reason1_not9
rename	c2b_reason_not_pnut_dshel_oth	reason_not_sfy9
rename	c2c_migrate_pnut_dshel	migrate9
rename	c2c_migrate_pnut_dshel_oth	migrate_oth9
rename	c2d_extent_pnut_dshel1	extent1_9
rename	c2d_extent_pnut_dshel2	extent2_9
rename	c2d_extent_pnut_dshel_oth	extent_oth9
rename	c2e_perform_pnut_dshel	perform9
rename	c2e_perform_pnut_dshel_oth	perform_oth9
rename	c3a_agree_sweep_shed	agree7
rename	c3b_reason_not_sweep_shed1	reason1_not7
rename	c3b_reason_not_sweep_shed2	reason2_not7
rename	c3b_reason_not_sweep_shed3	reason3_not7
rename	c3b_reason_not_sweep_shed_oth	reason_not_sfy7
rename	c3c_migrate_sweep_shed	migrate7
rename	c3c_migrate_sweep_shed_oth	migrate_oth7
rename	c3d_extent_sweep_shed	extent1_7
rename	c3d_extent_sweep_shed_oth	extent_oth7
rename	c3e_perform_sweep_shed	perform7
rename	c3e_perform_sweep_shed_oth	perform_oth7
rename	c4a_agree_wash	agree3
rename	c4b_reason_not_wash1	reason1_not3
rename	c4b_reason_not_wash2	reason2_not3
rename	c4b_reason_not_wash3	reason3_not3
rename	c4b_reason_not_wash_oth	reason_not_sfy3
rename	c4c_migrate_wash	migrate3
rename	c4c_migrate_wash_oth	migrate_oth3
rename	c4d_extent_wash1	extent1_3
rename	c4d_extent_wash_oth	extent_oth3
rename	c4e_perform_wash	perform3
rename	c4e_perform_wash_oth	perform_oth3
rename	c5a_agree_repair_grassmat	agree5
rename	c5b_reason_not_repair_grassmat1	reason1_not5
rename	c5b_reason_not_repair_grassmat2	reason2_not5
rename	c5b_reason_not_repair_grassmat3	reason3_not5
rename	c5b_reason_not_repair_oth	reason_not_sfy5
rename	c5c_migrate_repair_grassmat	migrate5
rename	c5c_migrate_repair_grassmat_oth	migrate_oth5
rename	c5d_extent_repair_grassmat	extent1_5
rename	c5d_extent_repair_grassmat_oth	extent_oth5
rename	c5e_perform_repair_grassmat	perform5
rename	c5e_perform_repair_grassmat_oth	perform_oth5
rename	c6a_agree_stitching	agree11
rename	c6b_reason_not_stitching1	reason1_not11
rename	c6b_reason_not_stitching2	reason2_not11
rename	c6b_reason_not_stitching3	reason3_not11
rename	c6b_reason_not_stitching_oth	reason_not_sfy11
rename	c6c_migrate_stitching	migrate11
rename	c6c_migrate_stitching_oth	migrate_oth11
rename	c6d_extent_stitching	extent1_11
rename	c6d_extent_stitching_oth	extent_oth11
rename	c6e_perform_stitching	perform11
rename	c6e_perform_stitching_oth	perform_oth11
rename	c7a_agree_wash_cloth	agree2
rename	c7b_reason_not_wash_cloth1	reason1_not2
rename	c7b_reason_not_wash_cloth2	reason2_not2
rename	c7b_reason_not_wash_cloth3	reason3_not2
rename	c7b_reason_not_wash_cloth4	reason4_not2
rename	c7b_reason_not_wash_cloth5	reason5_not2
rename	c7b_reason_not_wash_cloth_oth	reason_not_sfy2
rename	c7c_migrate_wash_cloth	migrate2
rename	c7c_migrate_wash_cloth_oth	migrate_oth2
rename	c7d_extent_wash_cloth	extent1_2
rename	c7d_extent_wash_cloth_oth	extent_oth2
rename	c7e_perform_wash_cloth	perform2
rename	c7e_perform_wash_cloth_oth	perform_oth2
rename	c8a_agree_polish_shoe	agree4
rename	c8b_reason_not_polish_shoe1	reason1_not4
rename	c8b_reason_not_polish_shoe2	reason2_not4
rename	c8b_reason_not_polish_shoe3	reason3_not4
rename	c8b_reason_not_polish_shoe4	reason4_not4
rename	c8b_reason_not_polish_shoe5	reason5_not4
rename	c8b_reason_not_polish_shoe6	reason6_not4
rename	c8b_reason_not_polish_shoe_oth	reason_not_sfy4
rename	c8c_migrate_polish_shoe	migrate4
rename	c8c_migrate_polish_shoe_oth	migrate_oth4
rename	c8d_extent_polish_shoe1	extent1_4
rename	c8d_extent_polish_shoe2	extent2_4
rename	c8d_extent_polish_shoe3	extent3_4
rename	c8d_extent_polish_shoe4	extent4_4
rename	c8d_extent_polish_shoe_oth	extent_oth4
rename	c8e_perform_polish_shoe	perform4
rename	c8e_perform_polish_shoe_oth	perform_oth4
rename	c9a_agree_sweep_latr	agree6
rename	c9b_reason_not_sweep_latr1	reason1_not6
rename	c9b_reason_not_sweep_latr2	reason2_not6
rename	c9b_reason_not_sweep_latr3	reason3_not6
rename	c9b_reason_not_sweep_latr4	reason4_not6
rename	c9b_reason_not_sweep_latr5	reason5_not6
rename	c9b_reason_not_sweep_latr6	reason6_not6
rename	c9b_reason_not_sweep_latr_oth	reason_not_sfy6
rename	c9c_migrate_sweep_latr	migrate6
rename	c9c_migrate_sweep_latr_oth	migrate_oth6
rename	c9d_extent_sweep_latr1	extent1_6
rename	c9d_extent_sweep_latr_oth	extent_oth6
rename	c9e_perform_sweep_latr	perform6
rename	c9e_perform_sweep_latr_oth	perform_oth6
rename  c10d_extent_paper_bag1 	extent1_8
rename  c10d_extent_paper_bag2  extent2_8
rename  c10d_extent_paper_bag3  extent3_8
rename  c10d_extent_paper_bag_oth  extent_oth8


 
** Section D: stories

	// lower value means more conservative: d1_karthik_tuna d2_bindusagar_rabi d3_gagan_find_work
	// higher value means more conservative: d4_santhilatha_college d5_nehru_finish_ssc d6_sameer_jena d7_tukuna_naika

foreach x of varlist d1_karthik_tuna d2_bindusagar_rabi d3_gagan_find_work{
	gen `x'_cons=inlist(`x',1,2) if !mi(`x')
}

foreach x of varlist d4_santhilatha_college d5_nehru_finish_ssc d6_sameer_jena d7_tukuna_naika{
	gen `x'_cons=inlist(`x',4,5) if !mi(`x')
}

sum d1_karthik_tuna_cons d2_bindusagar_rabi_cons d3_gagan_find_work_cons d4_santhilatha_college_cons d5_nehru_finish_ssc_cons d6_sameer_jena_cons d7_tukuna_naika_cons
egen conserv_index=rowtotal(d1_karthik_tuna_cons d2_bindusagar_rabi_cons d3_gagan_find_work_cons d4_santhilatha_college_cons d5_nehru_finish_ssc_cons d6_sameer_jena_cons d7_tukuna_naika_cons), m
summ conserv_index, det
gen conserv5up=conserv_index>=5 if !mi(conserv_index)

pca d1_karthik_tuna_cons d2_bindusagar_rabi_cons d3_gagan_find_work_cons d4_santhilatha_college_cons d5_nehru_finish_ssc_cons d6_sameer_jena_cons d7_tukuna_naika_cons
predict conserv_pca
sum conserv_pca, det
gen hiconserv=conserv_pca>r(p50) if !mi(conserv_pca)


label var age "Age"
label var married "Married"
label var famsize "Family size"
label var workshare "Share of working members"
label var year_edu "Years of education"
label var read_odiya "Able to read"
label var pucca_house "Non-mud house"
label var semipucca_house "Semi-mud house"
label var kutcha_house "Mud house"
label var own_land "Owns land"
label var landsize "Land size in acres"
label var income "Last month income in Rs."
label var log_income "Log of last month income"
label var paid_days "Paid work days last week"
label var own_index "Number of assets owned"
label var wealth_pca "Wealth PCA score"
label var conserv_index "Number of caste-sensitive views"
label var conserv_pca "Caste sensitivity PCA score"
label var hiwealth "High wealth"
label var hiedu "High education"
label var old "Older"
label var conserv5up "Caste-sensitive (5+)"
label var hiconserv "Caste-sensitive (above median score)"



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Reshape data
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


// make long data with time variations

local num=5
foreach x in wash_clothes animal_shed shoe_repair wash_agri deshell grass_mat stitching latrine rope {
	rename c`num'_`x'_10min `x'1
	rename c`num'_`x'_30min `x'2
	rename c`num'_`x'_1hr `x'3
	rename c`num'_`x'_1_30hr `x'4
	local `num++'
}


reshape long wash_clothes animal_shed shoe_repair wash_agri deshell grass_mat stitching latrine rope, i(pid) j(timecat)

gen timemin = 10 if timecat==1
replace timemin = 30 if timecat==2
replace timemin = 60 if timecat==3
replace timemin = 90 if timecat==4
label var timemin "Minutes on extra tasks"

gen timehr = timemin/60
label var timehr "Hours on extra tasks"

foreach x of varlist wash_clothes animal_shed shoe_repair wash_agri deshell grass_mat stitching latrine rope {
	replace `x'=. if `x' == -222
}

gen had_rope=!mi(rope)

label var wash_clothes "Washing clothes"
label var animal_shed "Sweeping animal sheds"
label var shoe_repair "Mending leather shoes"
label var wash_agri "Washing farming tools"
label var deshell "Deshelling peanuts"
label var grass_mat "Mending grass mats"
label var stitching "Stitching"
label var latrine "Sweeping latrines"
label var rope "Making ropes"
label var had_rope "Random choice set variation with rope"


save "$path/data/choice_jobtakeup_wide.dta", replace



// make long data with task variations


egen id_time=group(pid timecat)

rename wash_clothes takeup2
rename wash_agri takeup3
rename shoe_repair takeup4
rename grass_mat takeup5
rename latrine takeup6
rename animal_shed takeup7
rename deshell takeup9
rename rope takeup10
rename stitching takeup11

rename wash_cloths_sno taskorder2
rename wash_agri_tool_sno taskorder3
rename shoe_repair_sno taskorder4
rename make_grass_mat_sno taskorder5
rename latrine_sweep_sno taskorder6
rename animal_shed_sweep_sno taskorder7 
rename deshell_peanut_sno taskorder9
rename make_rope_sno taskorder10
rename stitching_sno taskorder11


reshape long takeup taskorder agree reason1_not reason2_not reason3_not reason4_not reason5_not reason6_not reason_not_sfy migrate migrate_oth extent1_ extent2_ extent3_ extent4_ extent_oth perform perform_oth, i(id_time) j(task)
order reason4_not reason5_not reason6_not, after(reason3_not)
order extent2_ extent3_ extent4_, after(extent1_)
rename *_ *

label define task 2 "Washing clothes" 3 "Washing farming tools" 4 "Mending leather shoes" 5 "Mending grass mats" 6 "Sweeping latrines" 7 "Sweeping animal sheds" 8 "Making paper bags" 9 "Deshelling peanuts" 10 "Making ropes" 11 "Stitching"
label values task task


// tags
egen pidtask=group(pid task)
egen tag_pidtask=tag(pid task) 
egen tag_pid=tag(pid) if task==2



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Generate variables for analysis
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

gen private=random_private_public==1
gen public=random_private_public==2

gen castelev = 4 if caste==7					 	// based on ranking survey
replace castelev=3 if caste==5 | caste==6
replace castelev=2 if caste==3 | caste==4
replace castelev=1 if caste==2 | caste==1


gen castelev_old = 4 if caste==7 | caste==4			 // pre-registred version
replace castelev_old=3 if caste==5 | caste==6
replace castelev_old=2 if caste==1 | caste==3
replace castelev_old=1 if caste==2 

forval i=1/4{
	foreach x in castelev castelev_old{
		gen `x'`i'=`x'==`i'
	}
}


gen tasklev = 1 if task == 8 | task==9 | task==10 | task==11
replace tasklev = 2 if task==2 | task==3
replace tasklev = 3 if task==4 | task==5
replace tasklev = 4 if task==6 | task==7

gen tasklev1 = tasklev == 1
gen tasklev2 = tasklev == 2 
gen tasklev3 = tasklev == 3
gen tasklev4 = tasklev == 4

gen taskpair=tasklev
replace taskpair=task if tasklev==1
egen pidtaskpair=group(pid taskpair)


gen identity = task==2 | task==4 | task==6
gen pairedcont = task==3 | task==5 | task==7 
gen purecont = task==8 | task==9 | task==10 | task==11

gen lowertask = castelev<tasklev if !mi(tasklev) & !mi(castelev)  		// task is lower than the caste
gen lowertask_old = castelev_old<tasklev if !mi(tasklev) & !mi(castelev_old)		// pre-registered version (wrong)
gen lowertask_old2 = lowertask_old				// making partial correction to ranking
replace lowertask_old2 = 1 if caste==1 & inlist(task,2,3)
replace lowertask_old2 = 1 if caste==4 & inlist(task,6,7)


gen sametask = 0  if !mi(tasklev) & !mi(castelev)
replace sametask = 1 if caste==3 & tasklev == 2  // dhoba for washing
replace sametask = 1 if caste==5 & tasklev == 3  // mochi for mending
replace sametask = 1 if caste==7 & tasklev == 4  // hadi for sweeping

gen diftask = sametask!=1 & purecont==0 if !mi(sametask) 
gen highertask = lowertask==0 & sametask==0 & purecont==0 if !mi(tasklev) & !mi(castelev) & purecont==0


// implementation vars

gen int offer_type=0
replace offer_type=2 if job_offer_task==1
replace offer_type=3 if job_offer_task==4
replace offer_type=4 if job_offer_task==3
replace offer_type=5 if job_offer_task==6
replace offer_type=6 if job_offer_task==8
replace offer_type=7 if job_offer_task==2
replace offer_type=9 if job_offer_task==5
replace offer_type=10 if job_offer_task==9
replace offer_type=11 if job_offer_task==7
replace offer_type=. if offer_type==0

gen int offer_tasklev = .
replace offer_tasklev = 1 if offer_type==9 | offer_type==10 | offer_type==11
replace offer_tasklev = 2 if offer_type==2 | offer_type==3
replace offer_tasklev = 3 if offer_type==4 | offer_type==5
replace offer_tasklev = 4 if offer_type==6 | offer_type==7

gen int lowertask_offer = castelev<offer_tasklev if !mi(offer_tasklev) & !mi(castelev)  // offered task is lower than the caste

gen int sametask_offer = 0  if !mi(offer_tasklev) & !mi(castelev)
replace sametask_offer = 1 if caste==3 & offer_tasklev == 2  // dhoba for washing
replace sametask_offer = 1 if caste==5 & offer_tasklev == 3  // mochi for mending
replace sametask_offer = 1 if caste==7 & offer_tasklev == 4  // hadi for sweeping

gen int diftask_offer = sametask_offer!=1 & offer_tasklev!=1 if !mi(sametask_offer)

gen int iden_offer = inlist(offer_type,2,4,6) if !mi(offer_type)
gen int iden_lowertask_offer = lowertask_offer*iden_offer
gen int iden_sametask_offer = sametask_offer*iden_offer
gen int iden_diftask_offer = diftask_offer*iden_offer

gen int offer_accept = job_accepted==1 
gen int offer_completed = job_completed==1 
gen int survey_completed = _merge_survey==3


foreach x of varlist lowertask lowertask_old lowertask_old2 sametask diftask {
	gen iden_`x'=identity*`x'
}

foreach y of numlist 1/7{
	gen caste`y'=caste==`y'
}

gen timeminq = timemin^2

foreach x of numlist 2/7 9/11{ 
	gen task`x'=task==`x'
	gen time_task`x'=timemin*task`x'
	gen time_taskq`x'=timeminq*task`x'
}


foreach var of varlist old age hiedu year_edu hiwealth wealth_pca paid_days hijobs{
	foreach x of numlist 2/7 9/11{ 
		gen `var'`x'=`var'*task`x'
	}
}


// comprehension
egen compscore = rowtotal(b6_choice_t1 b7_offer_t1 b8_offchoice_t1 c1_dice_t1 c2_card_t1 c3_choiceyes_t1 c4_choiceno_t1)
sum compscore if tag_pid, det
gen hicomp=compscore>=r(p50) if !mi(compscore)
label var compscore "Comprehension score"



// extent of choice reversal 
sort pid task timecat
gen temp1=timecat if takeup==1
gen temp2=timecat if takeup==0
by pid task: egen temp1b=max(temp1)
by pid task: egen temp2b=min(temp2)
egen temp5=tag(pid task)
count if !mi(temp1b) & !mi(temp2b) & temp5==1 
count if !mi(temp1b) & !mi(temp2b) & temp5==1 & temp1b>temp2b
gen reversal_task=!mi(temp1b) & !mi(temp2b) & temp1b>temp2b
by pid: egen reversal_pid=max(reversal_task)
tab reversal_task if tag_pidtask		// shows 3% choice reversal
tab reversal_pid if tag_pid				// 17% has at least one choice reversal
drop temp*




foreach x of varlist identity pairedcont purecont lowertask sametask iden_lowertask iden_sametask diftask iden_diftask {
	gen pub_`x'=public*`x'
}

order pid task timecat timemin timehr private public id_time pidtask tag_pidtask tag_pid, first
label var task "Task"
label var timecat "Time requirement"
label var takeup "Take-up"
label var identity "Identity"
label var lowertask "Lower tasks"
label var iden_lowertask "Identity $\times$ Lower"
label var sametask "Same-ranked"
label var iden_sametask "Identity $\times$ Same-ranked"
label var diftask "Different tasks"
label var iden_diftask "Identity $\times$ Different"
label var pairedcont "Paired control"
label var purecont "Pure control"

label var lowertask_old "Lower"
label var iden_lowertask_old "Identity $\times$ Lower"
label var lowertask_old2 "Lower"
label var iden_lowertask_old2 "Identity $\times$ Lower"
label var lowertask_offer "Lower"
label var iden_lowertask_offer "Identity $\times$ Lower"
label var diftask_offer "Different"
label var iden_diftask_offer "Identity $\times$ Different"

label var pub_lowertask "Public $\times$ Lower"
label var pub_iden_lowertask "Public $\times$ Identity $\times$ Lower"
label var pub_sametask "Public $\times$ Same-ranked" 
label var pub_iden_sametask "Public $\times$ Identity $\times$ Same-ranked"
label var pub_diftask "Public $\times$ Different" 
label var pub_iden_diftask "Public $\times$ Identity $\times$ Different"
label var pub_identity "Public $\times$ Identity"
label var pub_pairedcont "Public $\times$ Paired control"
label var pub_purecont "Public $\times$ Pure control"
label var public "Public"
label var private "Private"


save "$path/data/choice_jobtakeup_analysis.dta", replace
