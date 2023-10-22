clear all

* load data
use "RA24/dataset.dta"

*** set globals

* treatment
global add_treatment  "period_lag_4_tr period_lag_3_tr period_lag_2_tr period_tr_tr"
global spatial_lag_treat "period_lag_4_tr_splag period_lag_3_tr_splag period_lag_2_tr_splag period_tr_tr_splag"

* fixed effects
global baseline_FE "grid_cell_no period period#i.dataset_int period#c.average_temperature period#c.average_rainfall period#exp_period_fixed_city_cell"

* clusters
global cluster_level "grid_cell_no"

*********** replicate regression and generate standard errors ******************

eststo clear

*full specification
eststo: reghdfe is_under_city_state_map_tot $add_treatment $spatial_lag_treat state_tot_SPLAG, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 

*alternative outcome
eststo: reghdfe building $add_treatment $spatial_lag_treat building_SPLAG, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 

*New states
eststo: reghdfe is_under_city_state_map_tot_new $add_treatment $spatial_lag_treat state_tot_new_SPLAG, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 

*Expanding states
eststo: reghdfe is_under_city_state_map_tot_cont $add_treatment $spatial_lag_treat state_tot_cont_SPLAG, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 

esttab  using "$project_output_path\RA24.tex", ///
b(2) se(2) se ///
keep(period_tr_tr) nonumber label ///
stats(p_pl ymean N N_clust, fmt(2 2 0 0)labels("P-value pre-trend" "Mean dep. var." "Observations" "Clusters")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace
