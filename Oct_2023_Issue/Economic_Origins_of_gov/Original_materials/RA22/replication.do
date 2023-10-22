clear all

* load data
use "RA22/dataset.dta"

*** set globals

* treatment
global add_treatment  "period_lag_4_tr period_lag_3_tr period_lag_2_tr period_tr_tr"

* fixed effects
global baseline_FE "grid_cell_no period period#i.dataset_int period#c.average_temperature period#c.average_rainfall period#exp_period_fixed_city_cell"

* clusters
global cluster_level_double_10km "grid_cell_no FID_10km"

*********** replicate regression and generate standard errors ******************

eststo clear

*full specification
eststo: reghdfe is_under_city_state_map_tot $add_treatment, ///
 cluster($cluster_level_double_10km) absorb($baseline_FE)
$add_y

*alternative outcome
eststo: reghdfe building $add_treatment, ///
 cluster($cluster_level_double_10km) absorb($baseline_FE)
$add_y

*New states
eststo: reghdfe is_under_city_state_map_tot_new $add_treatment, ///
 cluster($cluster_level_double_10km) absorb($baseline_FE)
$add_y

*Expanding states
eststo: reghdfe is_under_city_state_map_tot_cont $add_treatment, ///
 cluster($cluster_level_double_10km) absorb($baseline_FE)
$add_y

esttab  using "$project_output_path\RA22.tex", ///
b(2) se(2) se ///
nonumber label ///
stats(ymean N N_clust1 N_clust2, fmt(2 0 0 0)labels("Mean dep. var." "Observations" "Clusters 1" "Clusters 2")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace
