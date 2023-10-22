clear all

* load data
use "RA32/dataset.dta"

*** set globals

* treatment
global add_treatment  "period_lag_4_tr period_lag_3_tr period_lag_2_tr period_tr_tr"

* fixed effects
global baseline_FE "grid_cell_no period period#i.dataset_int period#c.average_temperature period#c.average_rainfall period#exp_period_fixed_city_cell"

* clusters
global cluster_level "grid_cell_no"

*********** replicate regression and generate standard errors ******************


eststo clear

space_reg Y X cutoff1 cutoff2 lugal_indicator_ratio tablet period_lag_2_tr period_tr_t, ///
 xreg(3) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[2, 1]

reghdfe lugal_indicator_ratio tablet $add_treatment, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 
$rec_est

space_reg Y X cutoff1 cutoff2 gal_indicator_ratio tablet period_lag_2_tr period_tr_t, ///
 xreg(3) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[2, 1]

reghdfe gal_indicator_ratio tablet $add_treatment, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 
$rec_est

space_reg Y X cutoff1 cutoff2 canal_indicator_ratio tablet period_lag_2_tr period_tr_t, ///
 xreg(3) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[2, 1]

reghdfe canal_indicator_ratio tablet $add_treatment, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 
$rec_est

space_reg Y X cutoff1 cutoff2 tax_indicator_ratio tablet period_tr_t, ///
 xreg(2) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[2, 1]

reghdfe tax_indicator_ratio tablet $add_treatment, ///
 cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 
$rec_est

esttab using "$project_output_path\RA32.tex", ///
b(2) se(2) se ///
keep(period_tr_tr tablet) nonumber label ///
stats(p_pl ymean N N_clust c_se, fmt(2 2 0 0 2)labels("P-value pre-trend" "Mean dep. var." "Observations" "Clusters" "Conley SE")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace
