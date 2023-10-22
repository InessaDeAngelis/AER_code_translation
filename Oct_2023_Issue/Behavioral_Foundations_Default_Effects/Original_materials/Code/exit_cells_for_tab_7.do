*This do file takes the exit sample and tabulates cells for structural modeling
*Final product:
*exit_cells_benchmark.csv;
*exit_cells_benchmark_broad.csv

*for testing code interactively
cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/submission/code/"

adopath + ../../../../lib/ado/
preliminaries, globals(../../../../lib/globals)

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
log using "../output/exit_cells.log", replace

******
*Aggregate cells of different characteristics for structural modeling

use "$samp/ptd_LIS65_samp_exit_elix_med.dta", clear

gen cnt = 1

gen age_75plus = (age >= 75)

tab race
gen race_white = (race == 1)

sum elixsum, det
egen elix_median = median(elixsum)
gen elix_above_med = (elixsum > elix_median)
tab elix_above_med

preserve
keep if benchmark == 1
collapse (sum) cnt (mean) switch_actv, by(type_actv_ind_Dec age_75plus race_white female elix_above_med)
export delimited "../output/tables/exit_cells_benchmark.csv", replace
restore

preserve
keep if (benchmark == 1 | deminimus == 1)
collapse (sum) cnt (mean) switch_actv, by(type_actv_ind_Dec age_75plus race_white female elix_above_med)
export delimited "../output/tables/exit_cells_benchmark_broad.csv", replace
restore

******
*Compute descriptive statistics for years enrolled in exiting plans
estpost tabstat enrl_yrs_norm, by(type_actv_ind_Dec) stat(mean count) columns(statistics) listwise
eststo mean_enrl_yrs_norm
esttab mean_enrl_yrs_norm using "../output/tables/mean_enrl_yrs_norm_by_actv.csv", cells("mean count") noobs nonumber replace

estpost tabstat enrl_yrs_norm if benchmark == 1, by(type_actv_ind_Dec) stat(mean count) columns(statistics) listwise
eststo mean_enrl_yrs_norm_bench
esttab mean_enrl_yrs_norm_bench using "../output/tables/mean_enrl_yrs_norm_by_actv_benchmark.csv", cells("mean count") noobs nonumber replace

estpost tabstat enrl_yrs_norm if (benchmark == 1 | deminimus == 1), by(type_actv_ind_Dec) stat(mean count) columns(statistics) listwise
eststo mean_enrl_yrs_norm_bnchbrd
esttab mean_enrl_yrs_norm_bnchbrd using "../output/tables/mean_enrl_yrs_norm_by_actv_benchmark_broad.csv", cells("mean count") noobs nonumber replace


log close


