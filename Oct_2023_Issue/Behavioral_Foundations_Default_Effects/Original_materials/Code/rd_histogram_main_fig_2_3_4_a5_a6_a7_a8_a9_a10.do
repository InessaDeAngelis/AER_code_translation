*This do file takes the RD sample and 20% RD sample to plot RD balances and effects.
*Figures: 2, 3, 4, A5, A6, A7, A8, A9, A10, Table A1

*Final products: 
*ptd_LIS65_samp_elix_baseutil_Excldemin_rd_prep_new_samp.dta
*rd_hist_running_non_actv_in_Dec_allyrs_ExclDemin.eps;
*rd_hist_running_non_actv_in_Dec_pre2010_ExclDemin.eps;
*rd_hist_running_non_actv_in_Dec_post2011_ExclDemin.eps;
*rd_age_non_actv_Dec_all_years.eps;
*rd_female_non_actv_Dec_all_years.eps;
*rd_elixsum_non_actv_Dec_all_years.eps;
*rd_pde_spend_non_actv_Dec_all_years.eps;
*rd_npde_spend_non_actv_Dec_all_years.eps;
*rd_prescfit_inc_non_actv_Dec_all_years.eps;
*rd_prescfit_non_actv_Dec_all_years.eps;
*rd_prescfit_inc_prescfit_non_actv_Dec_all_years.eps;
*rd_switch_Jan_non_actv_Dec_all_years.eps;
*rd_switch_Jan_by_actv_Dec_all_years;
*rd_switch_Jan_by_type_non_actv_Dec_all_years;

*for testing code interactively
cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/submission/code/"

adopath + ../../../../lib/ado/

global bsfab "../../../../raw/medicare_part_ab_bsf/data"
global bsfab_20pct "../../../../raw/medicare_part_ab_bsf_20pct/data"
global bsfd "../../../../raw/medicare_part_d_bsf/data"
global elc "../../../../raw/medicare_part_d_elc/data"
global states "../../../../raw/geo_data/data/states"
global mcdps "../../../../raw/medicaid_ps/data"
global mcr_mcd_xwk "../../../../raw/medicare_medicaid_crosswalk/data"
global ptd_bnch "../../../../raw/medicare_part_d_benchmark/data"
global samp "../output"
global car "../../../../raw/medicare_part_ab_car/data"
global med "../../../../raw/medicare_part_ab_med/data"
global op "../../../../raw/medicare_part_ab_op/data"

global util_med "../../../../derived/utilization_med/output"
global util_op "../../../../derived/utilization_op/output"
global util_car "../../../../derived/utilization_car/output"
global util_pde "../../../../derived/utilization_pde/output"

cap log close
log using "../output/rd_histogram_main_fig_3_4_5_a6_a7_a8_a9_a10.log", replace


******
*Supplement RD sample with baseline Elixhauser score and utilization 

	*Make sure to drop problematic cases 
	use "$samp/ptd_LIS65_samp.dta", clear
	cap drop if ListtoDrop == 3
	save "$samp/ptd_LIS65_samp.dta", replace

	*Generate baseline elixhauser score based on claims records
	forvalues year = 2007/2009 {
		use "$samp/ptd_LIS65_samp.dta", clear
		keep if ref_year == `year'
		keep bene_id
		save ../temp/ptd_LTS65_bene_id_`year'.dta, replace
		
		use ${med}/dgnscd`year', clear
		merge m:1 bene_id using ../temp/ptd_LTS65_bene_id_`year'.dta, keep(3) nogen
		reshape wide dgnscd, i(bene_id medparid) j(dgnscdseq)
		keep bene_id dgnscd1-dgnscd9
		save ../temp/med_`year', replace
		
		use bene_id dgns_cd1-dgns_cd8 using ${car}/carc`year', clear
		merge m:1 bene_id using ../temp/ptd_LTS65_bene_id_`year'.dta, keep(3) nogen	
		rename dgns_cd* dgnscd*
		save ../temp/car_`year', replace

		use bene_id dgnscd1-dgnscd10 using ${op}/opc`year', clear
		merge m:1 bene_id using ../temp/ptd_LTS65_bene_id_`year'.dta, keep(3) nogen		
		save ../temp/op_`year', replace

		clear
		foreach file in med car op {
			append using ../temp/`file'_`year'
		}
		save ../temp/appended_diagnosis_file_`year', replace
		 
		elixhauser dgnscd*, index(e) idvar(bene_id)
		unique bene_id
		gen ref_year = `year'
		keep bene_id ref_year elixsum
		
		save ../temp/elixhauser_`year', replace
	}

	forvalues year = 2010/2014 {
		use "$samp/ptd_LIS65_samp.dta", clear
		keep if ref_year == `year'
		keep bene_id
		save ../temp/ptd_LTS65_bene_id_`year'.dta, replace
		
		use ${med}/dgnscd`year', clear
		merge m:1 bene_id using ../temp/ptd_LTS65_bene_id_`year'.dta, keep(3) nogen
		reshape wide dgnscd, i(bene_id medparid) j(dgnscdseq)
		keep bene_id dgnscd1-dgnscd9
		save ../temp/med_`year', replace
		
		use bene_id icd_dgns_cd1-icd_dgns_cd12 using ${car}/carc`year', clear
		merge m:1 bene_id using ../temp/ptd_LTS65_bene_id_`year'.dta, keep(3) nogen	
		rename icd_dgns_cd* dgnscd*
		save ../temp/car_`year', replace

		use bene_id icd_dgns_cd1-icd_dgns_cd25 using ${op}/opc`year', clear
		merge m:1 bene_id using ../temp/ptd_LTS65_bene_id_`year'.dta, keep(3) nogen
		rename icd_dgns_cd* dgnscd*	
		save ../temp/op_`year', replace

		clear
		foreach file in med car op {
			append using ../temp/`file'_`year'
		}
		save ../temp/appended_diagnosis_file_`year', replace
		 
		elixhauser dgnscd*, index(e) idvar(bene_id)
		unique bene_id
		gen ref_year = `year'
		keep bene_id ref_year elixsum
		
		save ../temp/elixhauser_`year', replace
		
	}

	clear
	forvalues year = 2007/2014 {
		append using ../temp/elixhauser_`year'
	}
	save ../output/elixhauser, replace

	******
	*Merge baseline Elixhauser score and baseline utilization with the 20% RD sample

	use "$samp/ptd_LIS65_20pct_samp.dta", clear

	cap drop if ListtoDrop == 3
	
	*Merge in Elixhauser score
	merge 1:1 bene_id ref_year using ../output/elixhauser, keep(1 3)
	tab ref_year _merge
	replace elixsum = 0 if _merge == 1
	tab elixsum
	drop _merge

	*Merge in baseline utilization
	rename ref_year year

	foreach x in med op car pde {
		merge 1:1 bene_id year using "${util_`x'}/utilization.dta", keep(1 3) gen(`x'_merge)
		tab year `x'_merge
		sum `x'_spend, det
		replace `x'_spend = 0 if `x'_spend == .
	}

	foreach x in number_of_prescriptions days_supply {
		sum `x', det
		replace `x' = 0 if `x' == .
	}

	gen tot_ip_spend = med_spend
	gen tot_op_spend = op_spend + car_spend
	gen tot_ip_op_spend = tot_ip_spend + tot_op_spend

	rename year ref_year
	cap drop _merge
	
	save "$samp/ptd_LIS65_20pct_samp_elix_baseutil.dta", replace

	*Merge the full RD sample with the 20% sample (thus accounting for the fact that baseline utilization is only available for the 20% sample)
	use "$samp/ptd_LIS65_samp.dta", clear
	cap drop _merge
	cap drop if ListtoDrop == 3
	merge 1:1 bene_id ref_year using "$samp/ptd_LIS65_20pct_samp_elix_baseutil.dta"
	drop if _merge == 2
	save "$samp/ptd_LIS65_samp_elix_baseuitl.dta", replace
		
	******
	*Drop all plans in the de minimus price region after 2011
	drop if (running < 2.05 & running > 0) & ref_year >= 2010
	save "$samp/ptd_LIS65_samp_elix_baseuitl_Excldemin.dta", replace



******
*Further prepare the sample for plotting and analysis

	use "$samp/ptd_LIS65_samp_elix_baseuitl_Excldemin.dta", clear

	******
	gen female = sex == 2
	replace female = . if sex == 0

	gen obs = 1
	gen with_util_info = _merge == 3
	tab with_util_info

	preserve
	collapse (sum) obs with_util_info (mean) age female elixsum tot_ip_op_spend pde_spend, by(lose_benchmark)
	export delimited ../output/tables/rd_balance_tabulation.csv, replace
	restore

	******
	*Create relative time indicators for plotting RD balance and effects
	sum running, det
	count if missing(running) == 1

	forvalues m = 0/13 {
		local m_1 = `m' + 1
		gen running`m_1' = (running > `m') & (running <= `m_1')
	}
	gen running15m = running > 14

	forvalues m = 0/13 {
		local m_1 = `m' + 1
		gen running_`m_1' = (running > -`m_1') & (running <= -`m')
	}
	gen running_15m = running <= -14

	label variable running_15m "-15"
	label variable running_14 " "
	label variable running_13 "-13"
	label variable running_12 " "
	label variable running_11 "-11"
	label variable running_10 " "
	label variable running_9 "-9"
	label variable running_8 " "
	label variable running_7 "-7"
	label variable running_6 " "
	label variable running_5 "-5"
	label variable running_4 " "
	label variable running_3 "-3"
	label variable running_2 " "
	label variable running_1 "-1"
	label variable running1 "1"
	label variable running2 " "
	label variable running3 "3"
	label variable running4 " "
	label variable running5 "5"
	label variable running6 " "
	label variable running7 "7"
	label variable running8 " "
	label variable running9 "9"
	label variable running10 " "
	label variable running11 "11"
	label variable running12 " "
	label variable running13 "13"
	label variable running14 " "
	label variable running15m "15"

	gen placeholder = 0
	label variable placeholder " "

	gen test = running_15m + running_14 + running_13 + running_12 + running_11 + running_10 + running_9 + running_8 + running_7 + running_6 + running_5 + running_4 + running_3 + running_2 + running_1 + placeholder + running1 + running2 + running3 + running4 + running5 + running6 + running7 + running8 + running9 + running10 + running11 + running12 + running13 + running14 + running15m
	tab test
	drop test

	gen running_grp = .
	
	replace running_grp = 1 if running_15m == 1
	
	forvalues i = 1/14 {
		local index = 16 - `i'
		replace running_grp = `index' if running_`i' == 1
		
	}

	forvalues i = 1/14 {
		local index = 16 + `i'
		replace running_grp = `index' if running`i' == 1		
	}
	
	replace running_grp = 31 if running15m == 1
	
	gen one = 1
	
	replace running_grp = running_grp - 16
	replace running_grp = running_grp + 0.5 if running_grp < 0
	replace running_grp = running_grp - 0.5 if running_grp > 0		
		
	******
	*Clean and label demographic and health vars 
	cap rename tot_ip_op_spend npde_spend

	label variable age "Age"
	label variable female "Female"
	label variable elixsum "Elixhauser Score"
	label variable pde_spend "Drug Spending"
	label variable npde_spend "Non-Drug Spending"

	save "$samp/ptd_LIS65_samp_elix_baseutil_Excldemin_rd_prep.dta", replace

	*Update_sample with new active indicator information
	use "$samp/ptd_LIS65_samp_elix_baseutil_Excldemin_rd_prep.dta", clear
	
	cap drop _merge
	
	cap drop year
	gen year = ref_year + 1
	merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/newactvind.dta"	
	keep if _merge == 3
	drop _merge
	
	tab type_actv_ind_new type_actv_ind_Dec
	replace type_actv_ind_Dec = type_actv_ind_new
	tab type_actv_ind_new type_actv_ind_Dec
	
	cap drop if ListtoDrop == 3
	
	*Merge in fit of incumbent plan
	merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planunivlvlfit_all_vx.dta"
	
	drop _merge

	*Merge in fit of assigned plan
	merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/presc_fit_file.dta"
	
	drop _merge

	save "$samp/ptd_LIS65_samp_elix_baseutil_Excldemin_rd_prep_new_samp.dta", replace	
	

******
*Plot Histograms of running variable
	use  "/disk/agedisk3/medicare.work/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/output/ptd_LIS65_samp_InclDemin_running_grp_new_samp.dta", clear
	keep if type_actv_ind_Dec == 0
	
	*Figure 2

	collapse (sum) one, by(running_grp demin_flag)
	reshape wide one, i(running_grp) j(demin_flag)
	rename one0 non_demin_cnt
	rename one1 demin_cnt
	replace demin_cnt = 0 if demin_cnt == . 	
	gen total_cnt = non_demin_cnt + demin_cnt
			
	twoway bar non_demin_cnt running_grp || rbar non_demin_cnt total_cnt running_grp, xlabel(-15(2)15) graphregion(color(white)) ylabel(none) legend(order(1 "Non De Minimis" 2 "De Minimis")) title("Prior Non-Choosers, 2008-15") xtitle(""Monthly Premium - Subsidy"")
	
	graph export ../output/graphs_InclDemin/rd_hist_running_non_actv_in_Dec_allyrs.eps, replace
	
	*Figure A5
	preserve
	keep if ref_year <= 2009	
	keep if type_actv_ind_Dec == 0
	
	collapse (sum) one, by(running_grp demin_flag)
	reshape wide one, i(running_grp) j(demin_flag)
	rename one0 non_demin_cnt
	rename one1 demin_cnt
	replace demin_cnt = 0 if demin_cnt == . 	
	gen total_cnt = non_demin_cnt + demin_cnt
			
	twoway bar non_demin_cnt running_grp || rbar non_demin_cnt total_cnt running_grp, xlabel(-15(2)15) graphregion(color(white)) ylabel(none) legend(order(1 "Non De Minimis" 2 "De Minimis")) title("Prior Non-Choosers, 2008-10") xtitle(""Monthly Premium - Subsidy"")
	
	graph export ../output/graphs/rd_hist_running_non_actv_in_Dec_pre2010_InclDemin.eps, replace
	restore
	
	*Figure A6
	preserve
	keep if ref_year >= 2010	
	keep if type_actv_ind_Dec == 0
	
	collapse (sum) one, by(running_grp demin_flag)
	reshape wide one, i(running_grp) j(demin_flag)
	rename one0 non_demin_cnt
	rename one1 demin_cnt
	replace demin_cnt = 0 if demin_cnt == . 	
	gen total_cnt = non_demin_cnt + demin_cnt
			
	twoway bar non_demin_cnt running_grp || rbar non_demin_cnt total_cnt running_grp, xlabel(-15(2)15) graphregion(color(white)) ylabel(none) legend(order(1 "Non De Minimis" 2 "De Minimis")) title("Prior Non-Choosers, 2011-15") xtitle(""Monthly Premium - Subsidy"")
	
	
	graph export ../output/graphs/rd_hist_running_non_actv_in_Dec_post2011_InclDemin.eps, replace
	restore


******
*Plot Main RD Graphs
program rd_graphs

use "$samp/ptd_LIS65_samp_elix_baseutil_Excldemin_rd_prep_new_samp.dta", clear	
	args sample
	
	local run_vars_all "running_15m running_14 running_13 running_12 running_11 running_10 running_9 running_8 running_7 running_6 running_5 running_4 running_3 running_2 running_1 placeholder running1 running2 running3 running4 running5 running6 running7 running8 running9 running10 running11 running12 running13 running14 running15m"

	local run_vars_left "running_15m running_14 running_13 running_12 running_11 running_10 running_9 running_8 running_7 running_6 running_5 running_4 running_3 running_2 running_1"
	
	local run_vars_right "running1 running2 running3 running4 running5 running6 running7 running8 running9 running10 running11 running12 running13 running14 running15m"	
	
	******
	*Balance tests
	
	label variable prescfit_inc "Fit of Incumbent Plan"
	label variable prescfit "Fit of Assigned Plan"
	
	*Figures 3, A7 (RD balance for prior drug spending, demographic variables and baseline utilization)
	foreach x in age female elixsum pde_spend npde_spend prescfit_inc prescfit {
		reg `x' `run_vars_all' if type_actv_ind_Dec == 0, robust nocons
		est sto non_actv_Dec_`x'
		estadd ysumm

	coefplot (non_actv_Dec_`x', omitted msymbol(none) noci offset(0)) ///
		(non_actv_Dec_`x', keep(`run_vars_left') mcolor(navy) ciopts(color(navy)) offset(0.5)) ///
		(non_actv_Dec_`x', keep(`run_vars_right') mcolor(navy) ciopts(color(navy)) offset(-0.5)), vertical ytitle("`: variable label `x''") xtitle("Monthly Premium - Subsidy") graphregion(color(white)) xline(16, lpattern(dash)) title("`: variable label `x''") legend(off) 

	graph export ../output/graphs/rd_`x'_non_actv_Dec_`sample'.eps, replace	
	
	}	
	
	*Plot RD balance for plan fit measures (overlaying incumbent and assigned plans)
	coefplot (non_actv_Dec_prescfit_inc, omitted msymbol(none) noci offset(0)) ///
		(non_actv_Dec_prescfit_inc, keep(`run_vars_left') mcolor(navy) ciopts(color(navy)) offset(0.5)) ///
		(non_actv_Dec_prescfit_inc, keep(`run_vars_right') mcolor(navy) ciopts(color(navy)) offset(-0.5)) ///
		(non_actv_Dec_prescfit, keep(`run_vars_right') mcolor(maroon) msymbol(D) ciopts(color(navy)) offset(-0.5)), ///
		vertical ytitle("Fit of Plans") xtitle("Monthly Premium - Subsidy") graphregion(color(white)) xline(16, lpattern(dash)) title("Fit of Plans") legend(off) text(0.7 20 "Incumbent Plans", place(e)) text(0.55 22 "Assigned Plans", place(e))

	graph export ../output/graphs/rd_prescfit_inc_prescfit_non_actv_Dec_`sample'.eps, replace	

*Table A1
	esttab non_actv_Dec* using "../output/tables/rd_non_actv_Dec_balance.txt", b(%12.3fc) se(%12.3fc) parentheses replace title("RD Balance") ///
		keep(`run_vars_all') stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%12.3fc %12.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes

	esttab non_actv_Dec* using "../output/tables/rd_non_actv_Dec_balance.csv", b(%12.3fc) se(%12.3fc) parentheses replace title("RD Balance") ///
		keep(`run_vars_all') stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%12.3fc %12.3fc 0)) nolabel nogaps tab compress se  nostar nonotes
	
	
	*******
	*Switch rate in Jan by Active choice status

	reg switch `run_vars_all' if type_actv_ind_Dec == 0, robust nocons
	est sto rd_switch_Jan_non_actv_Dec
	estadd ysumm

	reg switch `run_vars_all' if type_actv_ind_Dec == 1, robust nocons
	est sto rd_switch_Jan_actv_Dec
	estadd ysumm

	*Figure 4
	coefplot (rd_switch_Jan_non_actv_Dec, omitted msymbol(none) noci offset(0)) ///
		(rd_switch_Jan_non_actv_Dec, keep(`run_vars_left') mcolor(navy) ciopts(color(navy)) offset(0.5)) ///
		(rd_switch_Jan_non_actv_Dec, keep(`run_vars_right') mcolor(navy) ciopts(color(navy)) offset(-0.5)), vertical ytitle("Dec-Jan Switch Rate") xtitle("Monthly Premium - Subsidy") graphregion(color(white)) xline(16, lpattern(dash)) title("Switch Rate in Jan for Non-Choosers in Dec") legend(off)
		
	graph export ../output/graphs/rd_switch_Jan_non_actv_Dec_`sample'.eps, replace
	
		*Figure A10
	coefplot (rd_switch_Dec_non_actv_Dec, omitted msymbol(none) noci offset(0)) ///
		(rd_switch_Dec_non_actv_Dec, keep(`run_vars_left') mcolor(navy) ciopts(color(navy)) offset(0.5)) ///
		(rd_switch_Dec_non_actv_Dec, keep(`run_vars_right') mcolor(navy) ciopts(color(navy)) offset(-0.5)), vertical ytitle("Dec-Dec Switch Rate") xtitle("Monthly Premium - Subsidy") graphregion(color(white)) xline(16, lpattern(dash)) title("Switch Rate in Dec for Non-Choosers in Dec") legend(off)
		
	graph export ../output/graphs/rd_switch_Dec_non_actv_Dec_`sample'.eps, replace


	*Figure A9
	coefplot (rd_switch_Jan_non_actv_Dec, omitted msymbol(none) noci offset(0)) ///
		(rd_switch_Jan_non_actv_Dec, keep(`run_vars_left') mcolor(navy) ciopts(color(navy)) offset(0.5)) ///
		(rd_switch_Jan_non_actv_Dec, keep(`run_vars_right') mcolor(navy) ciopts(color(navy)) offset(-0.5)) ///
		(rd_switch_Jan_actv_Dec, keep(`run_vars_left') mcolor(maroon) ciopts(color(maroon)) offset(0.5)) ///
		(rd_switch_Jan_actv_Dec, keep(`run_vars_right') mcolor(maroon) ciopts(color(maroon)) offset(-0.5)), vertical ytitle("Dec-Jan Switch Rate") xtitle("Monthly Premium - Subsidy") graphregion(color(white)) xline(16, lpattern(dash)) title("Switch Rate in Jan") legend(off) text(0.85 20 "Prior Non-Choosers", place(e)) text(0.25 22 "Prior Choosers", place(e))

	graph export ../output/graphs/rd_switch_Jan_by_actv_Dec_`sample'.eps, replace

	esttab rd_switch_Jan_non_actv_Dec using "../output/tables/rd_switch_Jan_non_actv_Dec.txt", b(%12.3fc) se(%12.3fc) parentheses replace title("RD Switch") ///
		keep(`run_vars_all') stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%12.3fc %12.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes

	esttab rd_switch_Jan_non_actv_Dec using "../output/tables/rd_switch_Jan_non_actv_Dec.csv", b(%12.3fc) se(%12.3fc) parentheses replace title("RD Switch") ///
		keep(`run_vars_all') stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%12.3fc %12.3fc 0)) nolabel nogaps tab compress se  nostar nonotes

	esttab rd_switch_Jan_actv_Dec using "../output/tables/rd_switch_Jan_actv_Dec.txt", b(%12.3fc) se(%12.3fc) parentheses replace title("RD Switch") ///
		keep(`run_vars_all') stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%12.3fc %12.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes

	esttab rd_switch_Jan_actv_Dec using "../output/tables/rd_switch_Jan_actv_Dec.csv", b(%12.3fc) se(%12.3fc) parentheses replace title("RD Switch") ///
		keep(`run_vars_all') stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%12.3fc %12.3fc 0)) nolabel nogaps tab compress se  nostar nonotes
		
	******
	*Switch Rate in Jan by Type of Switch
	keep if type_actv_ind_Dec == 0

	rename segment_id segment_id_Dec
	rename contract_id_Jan contract_id
	rename plan_id_Jan plan_id
	rename segment_next segment_id
	gen yr = ref_year + 1

	cap drop _merge
	merge m:1 contract_id plan_id segment_id region_code yr using ${ptd_bnch}/PlansRunningPrem.dta	
	gen non_benchmark_Jan = (_merge == 1)
	cap replace non_benchmark_Jan = . if ref_year == 2014
	drop if _merge == 2
	drop _merge
	gen switch_actv_nb = (switch_actv == 1 & non_benchmark_Jan == 1)
	cap replace switch_actv_nb = . if ref_year == 2014

	foreach x in switch_reasgn switch_actv switch_actv_nb {
		reg `x' `run_vars_all' if type_actv_ind_Dec == 0, robust nocons
		est sto rd_`x'_Jan
		estadd ysumm
	
	}

	*Figure A8
	coefplot (rd_switch_reasgn_Jan, omitted msymbol(none) noci offset(0)) ///
		(rd_switch_actv_Jan, keep(`run_vars_left') mcolor(navy) ciopts(color(navy)) offset(0.5)) ///
		(rd_switch_actv_Jan, keep(`run_vars_right') mcolor(navy) ciopts(color(navy)) offset(-0.5)) ///
		(rd_switch_actv_nb_Jan, keep(`run_vars_left') mcolor(maroon) ciopts(color(maroon)) offset(0.5)) ///
		(rd_switch_actv_nb_Jan, keep(`run_vars_right') mcolor(maroon) ciopts(color(maroon)) offset(-0.5)) ///
		(rd_switch_reasgn_Jan, keep(`run_vars_left') mcolor(gs6) ciopts(color(gs6)) offset(0.5)) ///
		(rd_switch_reasgn_Jan, keep(`run_vars_right') mcolor(gs6) ciopts(color(gs6)) offset(-0.5)) ///	
		, vertical ytitle("Dec-Jan Switch Rate") xtitle("Monthly Premium - Subsidy") graphregion(color(white)) xline(16, lpattern(dash)) title("Switch Rate in Jan") legend(order(3 "by Active Choice" 7 "by Active Choice to Non-Benchmark Plan")) text(0.75 20 "by Default Reassignment", place(e))

	graph export ../output/graphs/rd_switch_Jan_by_type_non_actv_Dec_`sample'.eps, replace

	esttab rd_switch_reasgn_Jan rd_switch_actv_Jan rd_switch_actv_nb_Jan using "../output/tables/rd_switch_Jan_by_type_non_actv_Dec.txt", b(%12.3fc) se(%12.3fc) parentheses replace title("RD Switch") ///
		keep(`run_vars_all') stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%12.3fc %12.3fc 0)) nolabel nogaps tab compress se  star(* 0.10 ** 0.05 *** 0.01) nonotes

	esttab rd_switch_reasgn_Jan rd_switch_actv_Jan rd_switch_actv_nb_Jan using "../output/tables/rd_switch_Jan_by_type_non_actv_Dec.csv", b(%12.3fc) se(%12.3fc) parentheses replace title("RD Switch") ///
		keep(`run_vars_all') stats(ymean N, label("Mean of Dep Var" "Observations") fmt(%12.3fc %12.3fc 0)) nolabel nogaps tab compress se  nostar nonotes
	
end


******
*Execute
rd_graphs all_years



log close


