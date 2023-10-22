clear all

* load data
use "RA27/dataset.dta"

*** set globals

* treatment
global add_treatment  "period_lag_4_tr period_lag_3_tr period_lag_2_tr period_tr_tr"

* fixed effects
global baseline_FE "grid_cell_no period period#i.dataset_int period#c.average_temperature period#c.average_rainfall period#exp_period_fixed_city_cell"

* clusters
global cluster_level "grid_cell_no"

*********** replicate regression and generate standard errors ******************

eststo clear

eststo: reghdfe on_canal_5000 $add_treatment, /// 
 cluster($cluster_level) absorb($baseline_FE)
$add_y

eststo: reghdfe defensive_wall $add_treatment, /// 
 cluster($cluster_level) absorb($baseline_FE)
$add_y

eststo: reghdfe tablet $add_treatment, /// 
 cluster($cluster_level) absorb($baseline_FE)
$add_y

eststo: reghdfe tot_buildings $add_treatment, /// 
 cluster($cluster_level) absorb($baseline_FE)
$add_y

esttab  using "$project_output_path\RA27.tex", ///
b(2) se(2) se ///
nonumber label ///
stats(ymean N N_clust, fmt(2 0 0)labels("Mean dep. var." "Observations" "Clusters")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace

