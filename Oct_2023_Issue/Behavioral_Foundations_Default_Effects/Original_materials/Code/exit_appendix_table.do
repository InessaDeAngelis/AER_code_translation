*Regression code for appendix table 7: exit regressions

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
log using "../output/exit_main.log", replace

cap ssc install distinct


*******
*Regressions

use "$samp/ptd_LIS65_samp_exit_elix_med.dta", replace

*Generate indicator for broad definition of benchmark
gen benchmark_broad = (benchmark == 1 | deminimus == 1)
tab benchmark_broad

*No control vars
reg switch_actv type_actv_ind_Dec if benchmark_broad == 1, robust
eststo reg_exit_bnch
estadd local dem_ctrl " "
estadd local hth_ctrl " "
estadd local time_fe " "
estadd local plan_fe " "
estadd local sample "Benchmark"
*estadd ysumm, mean
summarize switch_actv if (e(sample) & type_actv_ind_Dec == 0)
estadd scalar y_non_actv_Dec = r(mean)
summarize switch_actv if (e(sample) & type_actv_ind_Dec == 1)
estadd scalar y_actv_Dec = r(mean)
distinct plan_grp_Dec if e(sample)
estadd scalar unique_plan = r(ndistinct)

*Controlling for demographic variables, health status (chronic health conditions from Elixhauser), and year FEs
reg switch_actv type_actv_ind_Dec i.age_grp female i.race i.ref_year ynel* if benchmark_broad == 1, robust
eststo reg_exit_bnch_dem
estadd local dem_ctrl "Y"
estadd local hth_ctrl "Y"
estadd local time_fe "Y"
estadd local plan_fe " "
estadd local sample "Benchmark"
summarize switch_actv if (e(sample) & type_actv_ind_Dec == 0)
estadd scalar y_non_actv_Dec = r(mean)
summarize switch_actv if (e(sample) & type_actv_ind_Dec == 1)
estadd scalar y_actv_Dec = r(mean)
distinct plan_grp_Dec if e(sample)
estadd scalar unique_plan = r(ndistinct)

*Controlling for demographic variables, health status (chronic health conditions from Elixhauser), year FEs, and exiting plan FEs 
reg switch_actv type_actv_ind_Dec i.age_grp female i.race i.ref_year ynel* i.plan_grp_Dec if benchmark_broad == 1, robust
eststo reg_exit_bnch_planfe
estadd local dem_ctrl "Y"
estadd local hth_ctrl "Y"
estadd local time_fe "Y"
estadd local plan_fe "Y"
estadd local sample "Benchmark"
summarize switch_actv if (e(sample) & type_actv_ind_Dec == 0)
estadd scalar y_non_actv_Dec = r(mean)
summarize switch_actv if (e(sample) & type_actv_ind_Dec == 1)
estadd scalar y_actv_Dec = r(mean)
distinct plan_grp_Dec if e(sample)
estadd scalar unique_plan = r(ndistinct)

*Interacting prior active choice status with years enrolled in plan, 
*controlling for demographic variables, health status (chronic health conditions from Elixhauser), year FEs, and exiting plan FEs 
reg switch_actv type_actv_ind_Dec##c.enrl_yrs_norm i.age_grp female i.race i.ref_year ynel* i.plan_grp_Dec if benchmark_broad == 1, robust
eststo reg_exit_bnch_days
estadd local dem_ctrl "Y"
estadd local hth_ctrl "Y"
estadd local time_fe "Y"
estadd local plan_fe "Y"
estadd local sample "Benchmark"
summarize switch_actv if (e(sample) & type_actv_ind_Dec == 0)
estadd scalar y_non_actv_Dec = r(mean)
summarize switch_actv if (e(sample) & type_actv_ind_Dec == 1)
estadd scalar y_actv_Dec = r(mean)
distinct plan_grp_Dec if e(sample)
estadd scalar unique_plan = r(ndistinct)

label variable switch_actv "Active Choice"
label variable type_actv_ind_Dec "Prior Active Choice"
	
esttab reg_exit* using "../output/tables/reg_exit_broad_det.csv", replace label title("Switch by Active Choice after Plan Exit") b(a3) se(a3) stats(dem_ctrl hth_ctrl time_fe plan_fe sample y_non_actv_Dec y_actv_Dec unique_plan r2 N, label("Demographic Controls" "Health Controls" "Time FE" "Plan FE" "Sample" "Mean(y) Prior Non-Choosers" "Mean(y) Prior Choosers" "Number of Exiting Plans" "R2" "Observations") fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f 0 %9.3f 0)) star(* 0.10 ** 0.05 *** 0.01) nonotes

esttab reg_exit* using "../output/tables/reg_exit_broad_simp.csv", replace label title("Switch by Active Choice after Plan Exit") keep(*type_actv_ind_Dec enrl_yrs_norm *.type_actv_ind_Dec#c.enrl_yrs_norm) b(a3) se(a3) stats(dem_ctrl hth_ctrl time_fe plan_fe sample y_non_actv_Dec y_actv_Dec unique_plan r2 N, label("Demographic Controls" "Health Controls" "Time FE" "Plan FE" "Sample" "Mean(y) Prior Non-Choosers" "Mean(y) Prior Choosers" "Number of Exiting Plans" "R2" "Observations") fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f 0 %9.3f 0)) star(* 0.10 ** 0.05 *** 0.01) nonotes
	
	
log close


