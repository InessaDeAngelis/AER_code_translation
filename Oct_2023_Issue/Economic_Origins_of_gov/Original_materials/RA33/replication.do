clear all

* load data
use "RA33/dataset.dta"

*** set globals

* treatment
global add_treatment  "period_lag_4_tr period_lag_3_tr period_lag_2_tr period_tr_tr"

* fixed effects
global baseline_FE_full "grid_cell_no period experiment_period experiment_period#period#i.dataset_int experiment_period#period#c.average_temperature experiment_period#period#c.average_rainfall experiment_period#period#exp_period_fixed_city_cell experiment_period#grid_cell_no experiment_period#period"

* clusters
global cluster_level "grid_cell_no"

*********** replicate regression and generate standard errors ******************


eststo clear

eststo: reghdfe on_canal_5000 $add_treatment if experiment_period <= 31, ///
 cluster($cluster_level) absorb($baseline_FE_full)
$add_y
$add_p_value 

eststo: reghdfe on_canal_5000 $add_treatment if experiment_period <= 10, /// 
 cluster($cluster_level) absorb($baseline_FE_full)
$add_y
$add_p_value 

eststo: reghdfe on_canal_5000 $add_treatment if experiment_period > 10 & experiment_period <= 31, ///
 cluster($cluster_level) absorb($baseline_FE_full)
$add_y
$add_p_value 

esttab  using "$project_output_path\RA33.tex", ///
b(2) se(2) se ///
keep(period_tr_tr) nonumber label ///
stats(p_pl ymean N N_clust, fmt(2 2 0 0)labels("P-value pre-trend" "Mean dep. var." "Observations" "Clusters")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace