clear all

* load data
use "RA28/dataset.dta"

*** set globals

* treatment
global add_treatment  "period_lag_4_tr period_lag_3_tr period_lag_2_tr period_tr_tr"

* fixed effects
global baseline_FE "grid_cell_no period period#i.dataset_int period#c.average_temperature period#c.average_rainfall period#exp_period_fixed_city_cell"

* clusters
global cluster_level_double "grid_cell_no i.period#i.nearest_city_ID"

*********** replicate regression and generate standard errors ******************

eststo clear

eststo: reghdfe on_canal_5000 $add_treatment, /// 
 cluster($cluster_level_double) absorb($baseline_FE)
$add_y
$add_p_value 

eststo: reghdfe defensive_wall $add_treatment, /// 
 cluster($cluster_level_double) absorb($baseline_FE)
$add_y
$add_p_value 

eststo: reghdfe tablet $add_treatment, /// 
 cluster($cluster_level_double) absorb($baseline_FE)
$add_y
$add_p_value 

eststo: reghdfe tot_buildings $add_treatment, /// 
 cluster($cluster_level_double) absorb($baseline_FE)
$add_y
$add_p_value 

esttab  using "$project_output_path\RA28.tex", ///
b(2) se(2) se ///
keep(period_tr_tr)  nonumber label ///
stats(p_pl ymean N N_clust1 N_clust2 , fmt(2 2 0 0 0)labels("P-value pre-trend" "Mean dep. var." "Observations" "Clusters 1 - Grid cells" "Clusters 2 - City x period")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace