clear all

* load data
use "RA25/dataset.dta"

*** set globals

* treatment
global add_treatment_closer  "period_lag_4_tr_cl  period_lag_3_tr_cl period_lag_2_tr_cl period_tr_tr_cl"

* fixed effects
global baseline_FE "grid_cell_no period period#i.dataset_int period#c.average_temperature period#c.average_rainfall period#exp_period_fixed_city_cell"

* clusters
global cluster_level "grid_cell_no"

*********** replicate regression and generate standard errors ******************

eststo clear

*full specification
eststo: reghdfe is_under_city_state_map_tot $add_treatment_closer, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

*alternative outcome
eststo: reghdfe building $add_treatment_closer, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

*New states
eststo: reghdfe is_under_city_state_map_tot_new $add_treatment_closer, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

*Expanding states
eststo: reghdfe is_under_city_state_map_tot_cont $add_treatment_closer, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

esttab  using "$project_output_path\RA25.tex", ///
b(2) se(2) se ///
nonumber label ///
stats(ymean N N_clust, fmt(2 0 0)labels("Mean dep. var." "Observations" "Clusters")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace
