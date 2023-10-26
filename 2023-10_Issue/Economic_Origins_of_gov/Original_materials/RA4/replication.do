clear all

* load data
use "RA4/dataset.dta"

*** set globals

* treatment
global add_treatment  "period_lag_4_tr period_lag_3_tr period_lag_2_tr period_tr_tr"

* clusters
global cluster_level "grid_cell_no"

*********** replicate regression and generate standard errors ******************

eststo clear

*full specification
eststo: reghdfe is_under_city_state_map_tot $add_treatment, ///
 cluster($cluster_level) noabsorb
$add_y

*alternative outcome
eststo: reghdfe building $add_treatment, ///
 cluster($cluster_level) noabsorb
$add_y

*New states
eststo: reghdfe is_under_city_state_map_tot_new $add_treatment, ///
 cluster($cluster_level) noabsorb
$add_y

*Expanding states
eststo: reghdfe is_under_city_state_map_tot_cont $add_treatment, ///
 cluster($cluster_level) noabsorb
$add_y

esttab  using "$project_output_path\RA4.tex", ///
b(2) se(2) se ///
nonumber label ///
stats(ymean N N_clust, fmt(2 0 0)labels("Mean dep. var." "Observations" "Clusters")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace

