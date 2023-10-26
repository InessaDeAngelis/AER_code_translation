* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* PROJECT:			Does Identity Affect Labor Supply?
* RESEARCHER:		Suanna Oh
* TASK:				Clean the bonus experiment data
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

use "$path/data/choice_bonuswage.dta", clear

gen survey_completed = pid!=179


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


	// Get PCA loadings from main data for merging

	preserve
	use "$path/data/choice_jobtakeup_analysis.dta", clear
	keep if tag_pid==1
		
	pca workshare kutcha_house semipucca_house own_land landsize log_income paid_days sew_mach_own bicycle_own motorbike_own fridge_own radio_own tv_own mobile_own land_phone_own stove_own watches_own
		mat W = e(L)

	local i=1
	foreach x of varlist workshare kutcha_house semipucca_house own_land landsize log_income paid_days sew_mach_own bicycle_own motorbike_own fridge_own radio_own tv_own mobile_own land_phone_own stove_own watches_own{
		local w`i' = W[`i',1]
		qui summ `x'
		local m`i' = r(mean)
		local sd`i' = r(sd)
		local `i++'
	}
		
	sum wealth_pca, det
	local pca_median = r(p50)		// use same cutoff for price data
	restore

local i=1
foreach x of varlist workshare kutcha_house semipucca_house own_land landsize log_income paid_days sew_mach_own bicycle_own motorbike_own fridge_own radio_own tv_own mobile_own land_phone_own stove_own watches_own{
	di "`m`i'' `sd`i'' `w`i''"
	gen temp_`x' = ((`x'-`m`i'')/`sd`i'')* `w`i''
	local `i++'
}

egen wealth_pca = rowtotal(temp_*) if survey_completed == 1
drop temp_*
gen hiwealth=wealth_pca>`pca_median' if !mi(wealth_pca)

sum year_edu, det
gen hiedu=year_edu>r(p50) if !mi(year_edu)

sum age, det
gen old=age>r(p50) if !mi(age)

sum paid_days, det
gen hijobs=paid_days>r(p50) if !mi(paid_days)




** Vignettes

// lower means conservative: d1_karthik_tuna d2_bindusagar_rabi d3_gagan_find_work
// higher means conservative: d4_santhilatha_college d5_nehru_finish_ssc d6_sameer_jena d7_tukuna_naika

foreach x of varlist d1_karthik_tuna d2_bindusagar_rabi d3_gagan_find_work{
	gen `x'_cons=inlist(`x',1,2) if !mi(`x')
}

foreach x of varlist d4_santhilatha_college d5_nehru_finish_ssc d6_sameer_jena d7_tukuna_naika{
	gen `x'_cons=inlist(`x',4,5) if !mi(`x')
}

sum d1_karthik_tuna_cons d2_bindusagar_rabi_cons d3_gagan_find_work_cons d4_santhilatha_college_cons d5_nehru_finish_ssc_cons d6_sameer_jena_cons d7_tukuna_naika_cons
egen conserv_index=rowtotal(d1_karthik_tuna_cons d2_bindusagar_rabi_cons d3_gagan_find_work_cons d4_santhilatha_college_cons d5_nehru_finish_ssc_cons d6_sameer_jena_cons d7_tukuna_naika_cons), m
gen conserv5up=conserv_index>=5 if !mi(conserv_index)

label var survey_completed "Completed survey"
label var age "Age"
label var married "Married"
label var famsize "Family size"
label var workshare "Share of working members"
label var workmember "Number of working members"
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
label var hiwealth "High wealth"
label var hiedu "High education"
label var hijobs "High number of days with jobs"
label var old "Older"
label var conserv5up "Caste-sensitive (5+)"



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Reshape data
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


** worker X price level data

reshape long i_a_sweep_latrine i_b_sweep_latrine i_c_sweep_latrine ii_a_wash_agtool ii_b_wash_agtool ii_c_wash_agtool iii_a_repair_grassmat iii_b_repair_grassmat iii_c_repair_grassmat iv_a_construction iv_b_construction iv_c_construction v_a_wash_cloth v_b_wash_cloth v_c_wash_cloth vi_a_repair_shoes vi_b_repair_shoes vi_c_repair_shoes vii_a_shed_sweep vii_b_shed_sweep vii_c_shed_sweep, i(pid) j(pay)

rename i_a_sweep_latrine task6_1
rename i_b_sweep_latrine task6_2
rename i_c_sweep_latrine task6_3
rename ii_a_wash_agtool task3_1
rename ii_b_wash_agtool task3_2
rename ii_c_wash_agtool task3_3
rename iii_a_repair_grassmat task5_1
rename iii_b_repair_grassmat task5_2
rename iii_c_repair_grassmat task5_3
rename iv_a_construction task1_1
rename iv_b_construction task1_2
rename iv_c_construction task1_3
rename v_a_wash_cloth task2_1
rename v_b_wash_cloth task2_2
rename v_c_wash_cloth task2_3
rename vi_a_repair_shoes task4_1
rename vi_b_repair_shoes task4_2
rename vi_c_repair_shoes task4_3
rename vii_a_shed_sweep task7_1
rename vii_b_shed_sweep task7_2
rename vii_c_shed_sweep task7_3


** worker X price X time level data

gen id_pay=_n
reshape long task1_ task2_ task3_ task4_ task5_ task6_ task7_ , i(id_pay) j(timecat)
rename task*_ task*

gen timemin = 10 if timecat==1
replace timemin = 30 if timecat==2
replace timemin = 60 if timecat==3
label var timemin "Minutes on the task"
order timemin, after(task7)

foreach x of varlist task1 task2 task3 task4 task5 task6 task7 {
	replace `x'=. if `x'<0
}

label var task1 "Moving bricks"
label var task2 "Washing clothes"
label var task3 "Washing farming tools"
label var task4 "Mending leather shoes"
label var task5 "Mending grass mats"
label var task6 "Sweeping latrines"
label var task7 "Sweeping animal sheds"


** worker X price X time X task level data

rename c1_make_paper_bag extent1_8
rename c1_make_paper_bag_oth extent_oth8
rename c3_wash_cloths1 extent1_2
rename c3_wash_cloths2 extent2_2
rename c3_wash_cloths_oth extent_oth2 
rename c4_repair_old_lthr_shoes extent1_4
rename c4_repair_old_lthr_shoes_oth extent_oth4
rename c5_sweep_latrine1 extent1_6
rename c5_sweep_latrine2 extent2_6
rename c5_sweep_latrine_oth extent_oth6
rename c6_hvy_lift_construction1 extent1_1
rename c6_hvy_lift_construction2 extent2_1
rename c6_hvy_lift_construction3 extent3_1
rename c6_hvy_lift_construction4 extent4_1
rename c6_hvy_lift_construction5 extent5_1
rename c6_hvy_lift_construction_oth extent_oth1
rename c7_wash_agri_tools1 extent1_3
rename c7_wash_agri_tools2 extent2_3
rename c7_wash_agri_tools3 extent3_3
rename c7_wash_agri_tools_oth extent_oth3
rename c8_repair_grassmat1 extent1_5
rename c8_repair_grassmat2 extent2_5
rename c8_repair_grassmat_oth extent_oth5
rename c9_sweep_animal_shed1 extent1_7
rename c9_sweep_animal_shed2 extent2_7
rename c9_sweep_animal_shed3 extent3_7
rename c9_sweep_animal_shed_oth extent_oth7

rename c10_wash_cloths refuse_all2
rename c10a_all_wage_wash_cloth reason_main2
rename c10a_all_wage_wash_cloth_oth reason_main_oth2
rename c10b_all_wage_oth_wash_cloth1 reason1_2
rename c10b_all_wage_oth_wash_cloth2 reason2_2
rename c10b_all_wage_oth_wash_cloth3 reason3_2
rename c10b_all_wage_oth_wash_cloth_o reason_oth2
rename c10c_extra_wage_wash_cloth extrawage2
rename c10c_extra_wage_wash_cloth_rs extrawage_rs2
rename c10d_some_wage_wash_cloth secretagree2
rename c10d_some_wage_wash_cloth_no secret_nowhy2
rename c10d_some_wage_wash_cloth_yes secret_yeswhy2
rename c10e_fin_soc_wash_cloth1 social1_2
rename c10e_fin_soc_wash_cloth2 social2_2
rename c10e_fin_soc_wash_cloth3 social3_2
rename c10e_fin_soc_wash_cloth_oth social_oth2

rename c11_repair_shoes  refuse_all4
rename c11a_all_wage_repr_shoes reason_main4
rename c11a_all_wage_repr_shoes_oth reason_main_oth4
rename c11b_all_wage_oth_repr_shoes1 reason1_4
rename c11b_all_wage_oth_repr_shoes2 reason2_4
rename c11b_all_wage_oth_repr_shoes3 reason3_4
rename c11b_all_wage_oth_repr_shoes_o reason_oth4
rename c11c_extra_wage_repr_shoes extrawage4
rename c11c_extra_wage_repr_shoes_rs extrawage_rs4
rename c11d_some_wage_repr_shoes secretagree4
rename c11d_some_wage_repr_shoes_no secret_nowhy4
rename c11d_some_wage_repr_shoes_yes secret_yeswhy4
rename c11e_fin_soc_repr_shoes1 social1_4
rename c11e_fin_soc_repr_shoes2 social2_4
rename c11e_fin_soc_repr_shoes3 social3_4
rename c11e_fin_soc_repr_shoes_oth social_oth4

rename c12_sweep_latrine  refuse_all6
rename c12a_all_wage_sweep_latr reason_main6
rename c12a_all_wage_sweep_latr_oth reason_main_oth6
rename c12b_all_wage_oth_sweep_latr1 reason1_6
rename c12b_all_wage_oth_sweep_latr2 reason2_6
rename c12b_all_wage_oth_sweep_latr3 reason3_6
rename c12b_all_wage_oth_sweep_latr4 reason4_6
rename c12b_all_wage_oth_sweep_latr_o reason_oth6
rename c12c_extra_wage_sweep_latr extrawage6
rename c12c_extra_wage_sweep_latr_rs extrawage_rs6
rename c12d_some_wage_sweep_latr secretagree6
rename c12d_some_wage_sweep_latr_no secret_nowhy6
rename c12d_some_wage_sweep_latr_yes secret_yeswhy6
rename c12e_fin_soc_sweep_latr1 social1_6
rename c12e_fin_soc_sweep_latr2 social2_6
rename c12e_fin_soc_sweep_latr3 social3_6
rename c12e_fin_soc_sweep_latr_oth social_oth6

rename c13_hvy_lift_constru  refuse_all1
rename c13a_all_wage_hvy_lift reason_main1
rename c13a_all_wage_hvy_lift_oth reason_main_oth1
rename c13b_all_wage_oth_hvy_lift reason1_1
rename c13b_all_wage_oth_hvy_lift_o reason_oth1
rename c13c_extra_wage_hvy_lift extrawage1
rename c13c_extra_wage_hvy_lift_rs extrawage_rs1

rename c14_wash_agri_tools  refuse_all3
rename c14a_all_wage_wash_agrtool reason_main3
rename c14a_all_wage_wash_agrtool_oth reason_main_oth3
rename c14b_all_wage_oth_wash_agrtool reason1_3
rename c14b_all_wage_oth_wash_agrtool_o reason_oth3
rename c14c_extra_wage_wash_agrtool extrawage3
rename c14c_extra_wage_wash_agrtool_rs extrawage_rs3

rename c15_repair_grassmat  refuse_all5
rename c15a_all_wage_rpr_grsmat reason_main5
rename c15a_all_wage_rpr_grsmat_oth reason_main_oth5
rename c15b_all_wage_oth_rpr_grsmat1 reason1_5
rename c15b_all_wage_oth_rpr_grsmat2 reason2_5
rename c15b_all_wage_oth_rpr_grsmat_o reason_oth5
rename c15c_extra_wage_rpr_grsmat extrawage5
rename c15c_extra_wage_rpr_grsmat_rs extrawage_rs5

rename c16_sweep_animal_shed  refuse_all7
rename c16a_all_wage_shed_swep reason_main7
rename c16a_all_wage_shed_swep_oth reason_main_oth7
rename c16b_all_wage_oth_shed_swep1 reason1_7
rename c16b_all_wage_oth_shed_swep2 reason2_7
rename c16b_all_wage_oth_shed_swep_o reason_oth7
rename c16c_extra_wage_shed_swep extrawage7
rename c16c_extra_wage_shed_swep_rs extrawage_rs7


rename c17_wash_cloths demandhigh2
rename c17a_hgh_wage_wash_cloth dhreason_main2
rename c17a_hgh_wage_wash_cloth_oth dhreason_main_oth2
rename c17b_hgh_wage_oth_wash_cloth1 dhreason1_2
rename c17b_hgh_wage_oth_wash_cloth2 dhreason2_2
rename c17b_hgh_wage_oth_wash_cloth_o dhreason_oth2
rename c17c_extra_wage_wash_cloth dhextrawage2
rename c17c_extra_wage_wash_cloth_rs dhextrawage_rs2
rename c17d_low_wage_wash_cloth dhsecretagree2
rename c17d_low_wage_wash_cloth_no dhsecret_nowhy2
rename c17d_low_wage_wash_cloth_yes dhsecret_yeswhy2

rename c18_repair_shoes demandhigh4
rename c18a_hgh_wage_rpr_shoe dhreason_main4
rename c18a_hgh_wage_rpr_shoe_oth dhreason_main_oth4
rename c18b_hgh_wage_oth_rpr_shoe1 dhreason1_4
rename c18b_hgh_wage_oth_rpr_shoe2 dhreason2_4
rename c18b_hgh_wage_oth_rpr_shoe_o dhreason_oth4
rename c18c_extra_wage_rpr_shoe dhextrawage4
rename c18c_extra_wage_rpr_shoe_rs dhextrawage_rs4
rename c18d_low_wage_rpr_shoe dhsecretagree4
rename c18d_low_wage_rpr_shoe_no dhsecret_nowhy4
rename c18d_low_wage_rpr_shoe_yes dhsecret_yeswhy4

rename c19_sweep_latrine demandhigh6
rename c19a_hgh_wage_sweep_latr dhreason_main6
rename c19a_hgh_wage_sweep_latr_oth dhreason_main_oth6
rename c19b_hgh_wage_oth_sweep_latr1 dhreason1_6
rename c19b_hgh_wage_oth_sweep_latr2 dhreason2_6
rename c19b_hgh_wage_oth_sweep_latr_o dhreason_oth6
rename c19c_extra_wage_sweep_latr dhextrawage6
rename c19c_extra_wage_sweep_latr_rs dhextrawage_rs6
rename c19d_low_wage_sweep_latr dhsecretagree6
rename c19d_low_wage_sweep_latr_no dhsecret_nowhy6
rename c19d_low_wage_sweep_latr_yes dhsecret_yeswhy6

rename c20_hvy_lift demandhigh1
rename c20a_hgh_wage_hvy_lift dhreason_main1
rename c20a_hgh_wage_hvy_lift_oth dhreason_main_oth1
rename c20b_hgh_wage_oth_hvy_lift dhreason1_1
rename c20b_hgh_wage_oth_hvy_lift_o dhreason_oth1
rename c20c_extra_wage_hvy_lift dhextrawage1
rename c20c_extra_wage_hvy_lift_rs dhextrawage_rs1

rename c21_wash_agri_tool demandhigh3
rename c21a_hgh_wage_wash_agrtool dhreason_main3
rename c21a_hgh_wage_wash_agrtool_oth dhreason_main_oth3
rename c21b_hgh_wage_oth_wash_agrtool dhreason1_3
rename c21b_hgh_wage_oth_wash_agrtool_o dhreason_oth3
rename c21c_extra_wage_wash_agrtool dhextrawage3
rename c21c_extra_wage_wash_agrtool_rs dhextrawage_rs3

rename c22_repair_grassmat demandhigh5
rename c22a_hgh_wage_rpr_grsmat dhreason_main5
rename c22a_hgh_wage_rpr_grsmat_oth dhreason_main_oth5
rename c22b_hgh_wage_oth_rpr_grsmat1 dhreason1_5
rename c22b_hgh_wage_oth_rpr_grsmat2 dhreason2_5
rename c22b_hgh_wage_oth_rpr_grsmat_o dhreason_oth5
rename c22c_extra_wage_rpr_grsmat dhextrawage5
rename c22c_extra_wage_rpr_grsmat_rs dhextrawage_rs5

rename c23_sweep_animal_shed demandhigh7
rename c23a_hgh_wage_shed_swep dhreason_main7
rename c23a_hgh_wage_shed_swep_oth dhreason_main_oth7
rename c23b_hgh_wage_oth_shed_swep1 dhreason1_7
rename c23b_hgh_wage_oth_shed_swep2 dhreason2_7
rename c23b_hgh_wage_oth_shed_swep_o dhreason_oth7
rename c23c_extra_wage_shed_swep dhextrawage7
rename c23c_extra_wage_shed_swep_rs dhextrawage_rs7


gen id_pay_time=_n
label values dhreason_oth7 reason

foreach x of varlist extent_oth* dhreason_oth* dhreason_main_oth6{
	cap confirm string variable `x'
	if _rc {
		decode `x', gen(temp)
		drop `x'
		rename temp `x'
	}
}

foreach x of varlist reason_oth* {
	cap confirm string variable `x'
	if _rc {
		tostring `x', replace
	}
}

reshape long task extent1_ extent2_ extent3_ extent4_ extent5_ extent_oth ///
	refuse_all reason_main reason_main_oth reason1_ reason2_ reason3_ reason4_ reason_oth extrawage extrawage_rs secretagree secret_nowhy secret_yeswhy social1_ social2_ social3_ social_oth ///
	demandhigh dhreason_main dhreason_main_oth dhreason1_ dhreason2_ dhreason_oth dhextrawage dhextrawage_rs dhsecretagree dhsecret_nowhy dhsecret_yeswhy /// 
	, i(id_pay_time) j(cat)
	
rename task agree
rename cat task
rename extent*_ extent*
rename *reason*_ *reason*
rename social*_ social*

label define task 1 "Moving bricks" 2 "Washing clothes" 3 "Washing farming tools" 4 "Mending leather shoes" 5 "Mending grass mats" 6 "Sweeping latrines" 7 "Sweeping animal sheds" 8 "Making paper bags" 
label values task task
order extent1 extent2 extent3 extent4 extent5 extent_oth, after(agree)



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Generate variables for analysis
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


// minimum price demanded 
// defined at pid X task X time level

sort pid task timecat pay
egen tag_pidtasktime=tag(pid task timecat) 
egen pidtask = group(pid task) 
egen tag_pidtask = tag(pid task) if tag_pidtasktime==1
egen tag_pid = tag(pid) if tag_pidtask

bys pid task timecat: egen temp1 = max(agree)
gen nevertake_tasktime = temp1==0 if task!=8		// never take up task for this time
bys pid task: egen temp2 = max(agree)
gen nevertake_task = temp2==0 if task!=8			// never take up task 
drop temp1 temp2

gen temp1 = pay if agree==1 						
bys pid task timecat: egen minwage_tasktime = min(temp1) 		// minimum amount demanded per task X time (missing if nevertake)
bys pid task: egen minwage_task = min(temp1) 					// minimum amount demanded per task (missing if nevertake)
drop temp1

gen minwage_tasktime_imp = minwage_tasktime
replace minwage_tasktime_imp = 5000 if mi(minwage_tasktime) & task!=8		// minimum amount demanded per task X time imputed
gen minwage_task_imp = minwage_task
replace minwage_task_imp = 5000 if mi(minwage_task) & task!=8		// minimum amount demanded per task imputed


gen take30_tasktime = minwage_tasktime_imp <= 30 if !mi(minwage_tasktime_imp)
gen take3000_tasktime = minwage_tasktime_imp <= 3000 if !mi(minwage_tasktime_imp)

table task if timecat==1, c(mean nevertake_tasktime mean take30_tasktime mean take3000_tasktime)


// extent of choice reversals (bonus)

gen temp2 = minwage_tasktime_imp if timecat==1
gen temp3 = minwage_tasktime_imp if timecat!=1
bys pid task: egen temp4=min(temp2)
bys pid task: egen temp5=min(temp3)
sort pid task timecat pay
list pid task timecat pay agree minwage_tasktime_imp if temp4>temp5			// 3 instances (out of 742 pid-tasks) where people demand higher wage for shorter time
gen incons_time = temp4>temp5 if !mi(minwage_tasktime_imp)


gen temp6 = pay if agree==1
gen temp7 = pay if agree==0
by pid task timecat: egen temp8=min(temp6)
by pid task timecat: egen temp9=max(temp7)

count if temp8<temp9 & task!=8 & !mi(temp9)
gen incons_amt = temp8<temp9 & !mi(temp9) if !mi(minwage_tasktime_imp)		// 14 instances (out of 2226 pid-task-time) where people accept and then refuse a higher amount

gen temp10 = incons_time + incons_amt
by pid: egen reversal_pid=max(temp10)	
tab reversal_pid if tag_pid													// 12% has at least one choice reversal;
drop temp*


// extent of choice reversals (practice)

preserve
keep if tag_pid==1
keep pid b7_tea_rs1 b7_mustard_seed_rs1 b8_tea_rs2 b8_mustard_seed_rs2 b9_tea_rs3 b9_mustard_seed_rs3 b10_tea_rs4 b10_mustard_seed_rs4 b11_tea_rs5 b11_mustard_seed_rs5 b12_tea_rs6 b12_mustard_seed_rs6 b13_tea_rs7 b13_mustard_seed_rs7 b14_tea_rs8 b14_mustard_seed_rs8 b15_tea_rs9 b15_mustard_seed_rs9 b16_tea_rs10 b16_mustard_seed_rs10


local k=1
foreach x of varlist b7_tea_rs1 b8_tea_rs2 b9_tea_rs3 b10_tea_rs4 b11_tea_rs5 b12_tea_rs6 b13_tea_rs7 b14_tea_rs8 b15_tea_rs9 b16_tea_rs10{
	rename `x' tea`k'
	local `k++'
}


local k=1
foreach x of varlist b7_mustard_seed_rs1 b8_mustard_seed_rs2 b9_mustard_seed_rs3 b10_mustard_seed_rs4 b11_mustard_seed_rs5 b12_mustard_seed_rs6 b13_mustard_seed_rs7 b14_mustard_seed_rs8 b15_mustard_seed_rs9 b16_mustard_seed_rs10{
	rename `x' mustard`k'
	local `k++'
}

reshape long tea mustard, i(pid) 
rename _j price

gen temp1 = price if tea==1
egen temp2 = max(temp1), by(pid)		// max willing to pay
gen temp3 = price if tea==0
egen temp4 = min(temp3), by(pid)		// min rejected price

*br if temp2>temp4 & !mi(temp2)
gen incons_tea = temp2>temp4 

gen temp5 = price if mustard==1
egen temp6 = max(temp5), by(pid)		// max willing to pay
gen temp7 = price if mustard==0
egen temp8 = min(temp7), by(pid)		// min rejected price

*br if temp6>temp8 & !mi(temp6)
gen incons_mustard = temp6>temp8 & !mi(temp6)

tab pid if incons_tea==1
tab pid if incons_mustard==1			// only 2 people are confused

egen tag_pid = tag(pid)
keep if tag_pid==1
keep pid incons_tea incons_mustard
tempfile practice
save `practice'

restore
merge m:1 pid using `practice', nogen


// categorizing tasks

gen kaibarta = caste == 1
gen pana = caste==6
gen identity = task==2 | task==4 | task==6
gen pairedcont = task==3 | task==5 | task==7 
gen purecont = task==1 | task==8
gen exptask = identity==1 | pairedcont==1

gen lowertask = 0
replace lowertask = 1 if (caste==1) & inlist(task,2,3,4,5,6,7)
replace lowertask = 1 if (caste==6) & inlist(task,6,7)

gen iden_lowertask = lowertask*identity

foreach y of numlist 1 6{
	gen caste`y'=caste==`y'
}

foreach x of numlist 1/7{ 
	gen task`x'=task==`x'
	gen time_task`x'=timemin*task`x'
}



gen public = random_private_public==0 
foreach x of varlist identity lowertask iden_lowertask pairedcont purecont exptask{
	gen pub_`x'=public*`x'
}


label var public "Public" 
label var identity "Identity task"
label var lowertask "Lower task"
label var iden_lowertask "Lower $\times$ Identity"
label var pub_lowertask "Public $\times$ Lower"
label var pub_iden_lowertask "Public $\times$ Lower $\times$ Identity"
label var kaibarta "Kaibarta"
label var pana "Pana"



// number of refusals at the task level
gen refuse=nevertake_task
tab nevertake_task refuse_all if tag_pidtask    				// refuse_all is filled in by surveyor: consistent

gen int temp1 = refuse if pairedcont==1 & tag_pidtask==1
gen int temp2 = refuse if identity==1 & tag_pidtask==1
gen int temp3 = refuse if tag_pidtask==1

sort pid
by pid: egen int numrefuse_cont = total(temp1)
by pid: egen int numrefuse_iden = total(temp2)
by pid: egen int numrefuse = total(temp3)
drop temp1 temp2 temp3


// whether refused a particular task
foreach x of numlist 1/7{
	gen temp`x' = refuse==1 & task==`x'
	by pid: egen refuse_task`x'=max(temp`x')
}	
drop temp*



// hasconcern: refuse any or all identity tasks
gen hasconcern = numrefuse_iden > 0 					// refused any identity task 
gen hasconcern_v2 = numrefuse_iden > 0 if numrefuse<6	// 	if numrefuse<6 (exclude 7 who refuse almost all)

gen refuseall = numrefuse>=6 

gen hasconcernstr = numrefuse_iden == 3
gen hasconcernstr_v2 = numrefuse_iden == 3  if numrefuse<6




// experience
egen neverperf = anymatch(extent1 extent2 extent3 extent4 extent5), values(1) 
egen ownhhperf = anymatch(extent1 extent2 extent3 extent4 extent5), values(2)
egen outhhperf = anymatch(extent1 extent2 extent3 extent4 extent5), values(3 4)
egen wageperf = anymatch(extent1 extent2 extent3 extent4 extent5), values(5 6)

foreach x of varlist neverperf ownhhperf outhhperf wageperf {
	replace `x'=. if mi(extent1) | extent1<0
}

foreach x of numlist 2 4 6{
	gen temp1=ownhhperf if task==`x' & tag_pidtask==1
	egen ownhhperf`x' = max(temp1), by(pid)
	gen temp2=outhhperf if task==`x' & tag_pidtask==1
	egen outhhperf`x' = max(temp2), by(pid)	
	gen temp3=wageperf if task==`x' & tag_pidtask==1
	egen wageperf`x' = max(temp3), by(pid)		
	gen temp4=neverperf if task==`x' & tag_pidtask==1
	egen neverperf`x' = max(temp4), by(pid)		
	drop temp*
}

	

// reason turned down
replace reason_main = 6 if regexm(reason_main_oth,"HARD WORK")
replace reason_main = 12 if regexm(reason_main_oth,"HEALTH")  
replace reason_main = 5 if regexm(reason_main_oth,"MY VILLAGE PEOPLE")
replace reason_main_oth = "-555" if reason_main!=-97 & !mi(reason_main)
label define reason 9 "Troublesome to switch to another task" 10 "Want to stay inside the work site" 11 "Already earning enough wages for today" 12 "Health problems", add
label values reason_main reason

tab reason_main if nevertake_task==0, m		// skip pattern is consistent
tab reason_main if nevertake_task==1, m


foreach x of varlist reason1 reason2 reason3 reason4{
	replace `x' = `x'*(-1) if `x'>20
}


foreach i of numlist 1/8 10 12{
	egen temp`i'=anymatch(reason_main reason1 reason2 reason3 reason4), values(`i')
	gen refuse_reason`i'=temp`i'==1 if nevertake_task==1
	drop temp`i'
}


gen refuse_iden = 0 if identity==1 & nevertake_task==1
replace refuse_iden = 1 if refuse_iden==0 & (refuse_reason1==1 | refuse_reason2==1 | refuse_reason3==1)
gen refuse_social = 0 if identity==1 & nevertake_task==1
replace refuse_social = 1 if refuse_social==0 & (refuse_reason4==1 | refuse_reason5==1)
gen refuse_skill = 0 if identity==1 & nevertake_task==1
replace refuse_skill = 1 if refuse_skill==0 & (refuse_reason6==1 | refuse_reason7==1 | refuse_reason8==1)


gen refuse_iden_cont = 0 if pairedcont==1 & nevertake_task==1
replace refuse_iden_cont = 1 if refuse_iden_cont==0 & (refuse_reason1==1 | refuse_reason2==1 | refuse_reason3==1)
gen refuse_social_cont = 0 if pairedcont==1 & nevertake_task==1
replace refuse_social_cont = 1 if refuse_social_cont==0 & (refuse_reason4==1 | refuse_reason5==1)
gen refuse_skill_cont = 0 if pairedcont==1 & nevertake_task==1
replace refuse_skill_cont = 1 if refuse_skill_cont==0 & (refuse_reason6==1 | refuse_reason7==1 | refuse_reason8==1)

                                          
gen reason_both = refuse_iden==1 & refuse_social==1 if identity==1 & nevertake_task==1
gen reason_onlyiden = refuse_iden==1 & refuse_social==0 if identity==1 & nevertake_task==1
gen reason_onlysocial = refuse_iden==0 & refuse_social==1 if identity==1 & nevertake_task==1
gen reason_neither = refuse_iden==0 & refuse_social==0 if identity==1 & nevertake_task==1

gen reason_both_cont = refuse_iden_cont==1 & refuse_social_cont==1 if pairedcont==1 & nevertake_task==1
gen reason_onlyiden_cont = refuse_iden_cont==1 & refuse_social_cont==0 if pairedcont==1 & nevertake_task==1
gen reason_onlysocial_cont = refuse_iden_cont==0 & refuse_social_cont==1 if pairedcont==1 & nevertake_task==1
gen reason_neither_cont = refuse_iden_cont==0 & refuse_social_cont==0 if pairedcont==1 & nevertake_task==1



// verifying BDM decisions
tab task extrawage if nevertake_task==1 & tag_pidtask==1, row m  
	// 98.4% say that they would refuse at any amounts of money
	//  2 out of 3 people state small amounts of money 

tab secretagree if nevertake_task==1 & tag_pidtask==1 & public==1 & secretagree>=0
	// 95% say they would not do the task even if the information was completely private
	// br secret_nowhy secretagree if nevertake_task==1 & tag_pidtask==1 & public==1 & secretagree==0
	
// what would happen if people found out
tab social2 social1 if nevertake_task==1 & tag_pidtask==1 & task==2
tab social2 social1 if nevertake_task==1 & tag_pidtask==1 & task==4
tab social2 social1 if nevertake_task==1 & tag_pidtask==1 & task==6



// comprehension
replace b6a_paying_packet=1 if b6a_paying_packet==-222
egen compscore = rowtotal(b1a_determine_tea b2a_roll_die b3a_deter_price b4a_cards_price b5a_get_offer b6a_paying_packet c1a_wrk_paperbag c2a_add_task c3a_extra_wage c4a_switch_add_task c5a_add_wage)
sum compscore if tag_pid, det
gen hicomp=compscore>=r(p50) if !mi(compscore)
label var compscore "Comprehension score"


// save task X time X price level data
save "$path/data/choice_bonuswage_analysis.dta", replace


