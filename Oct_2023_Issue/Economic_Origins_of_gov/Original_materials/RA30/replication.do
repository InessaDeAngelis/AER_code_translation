clear all

* load data
use "RA30/dataset.dta"

*** set globals

* treatment
global add_treatment  "period_lag_4_tr period_lag_3_tr period_lag_2_tr period_tr_tr"

* fixed effects
global baseline_FE "grid_cell_no period period#i.dataset_int period#c.average_temperature period#c.average_rainfall period#exp_period_fixed_city_cell"

* clusters
global cluster_level "grid_cell_no"

*********** replicate regression and generate standard errors ******************


*panel 1

eststo clear

eststo: reghdfe is_under_city_state_map_tot $add_treatment, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

eststo: reghdfe is_under_city_state_map_tot $add_treatment if high_density_count==1, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

eststo: reghdfe is_under_city_state_map_tot $add_treatment if high_density_count==0, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

eststo: reghdfe is_under_city_state_map_tot $add_treatment if aligned_wrong==0, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

eststo: reghdfe is_under_city_state_map_tot $add_treatment if aligned_wrong==1, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

esttab  using "$project_output_path\RA30_1.tex", ///
b(2) se(2) se ///
nonumber label ///
stats(ymean N N_clust, fmt(2 0 0)labels("Mean dep. var." "Observations" "Clusters")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace


*panel 2

eststo clear

eststo: reghdfe is_under_city_state_map_tot $add_treatment, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

eststo: reghdfe is_under_city_state_map_tot $add_treatment if high_returns_diff==1, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

eststo: reghdfe is_under_city_state_map_tot $add_treatment if high_returns_diff==0, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

eststo: reghdfe is_under_city_state_map_tot $add_treatment if low_water_flow==0, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

eststo: reghdfe is_under_city_state_map_tot $add_treatment if low_water_flow==1, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y

esttab  using "$project_output_path\RA30_2.tex", ///
b(2) se(2) se ///
nonumber label ///
stats(ymean N N_clust, fmt(2 0 0)labels("Mean dep. var." "Observations" "Clusters")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace

