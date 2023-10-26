clear all

* load data
use "6/dataset.dta"

*** set globals

* fixed effects
global baseline_FE "grid_cell_no period period#i.dataset_int period#c.average_temperature period#c.average_rainfall period#period7_fixed_city_cell"

* clusters
global cluster_level "grid_cell_no"

*********** replicate regression and generate standard errors ******************

eststo clear

* full panel
space_reg Y X cutoff1 cutoff2 on_canal_5000 tr_all_move_5000, xreg(1) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[1, 1]

reghdfe on_canal_5000 tr_all_move_5000, absorb($baseline_FE) cluster($cluster_level)
$add_y
$rec_est

*first states
space_reg Y X cutoff1 cutoff2 on_canal_5000 tr_all_move_5000 if period<=10, xreg(1) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[1, 1]

reghdfe on_canal_5000 tr_all_move_5000 if period<=10, absorb($baseline_FE) cluster($cluster_level)
$add_y
$rec_est

*subsequent states
space_reg Y X cutoff1 cutoff2 on_canal_5000 tr_all_move_5000 if period>10, xreg(1) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[1, 1]

reghdfe on_canal_5000 tr_all_move_5000 if period>10, absorb($baseline_FE) cluster($cluster_level)
$add_y
$rec_est

esttab  using "$project_output_path\6.tex", ///
b(2) se(2) se ///
keep(tr_all_move_5000) nonumber label ///
stats(ymean N N_clust c_se, fmt(2 0 0 2)labels("Mean dep. var." "Observations" "Clusters" "Conley SE")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace
