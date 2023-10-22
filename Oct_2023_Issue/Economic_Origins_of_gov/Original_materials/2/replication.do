clear all

* load data
use "2/dataset.dta"

*** set globals

* fixed effects
global baseline_FE "grid_cell_no period period#i.dataset_int period#c.average_temperature period#c.average_rainfall period#period7_fixed_city_cell"

* clusters
global cluster_level "grid_cell_no"

*********** replicate regression and generate standard errors ******************


use $stacked_panel , clear

eststo clear

							**** lag settlement ****

space_reg Y X cutoff1 cutoff2 l_settl tr_all_move_5000 if experiment_period==8 ///
$sample_restr , xreg(1) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[1, 1]
 
reghdfe l_settl tr_all_move_5000 if experiment_period==8 ///
$sample_restr , cluster($cluster_level) absorb($baseline_FE)
$add_y
$rec_est

space_reg Y X cutoff1 cutoff2 l2_settl tr_all_move_5000 if experiment_period==8 ///
$sample_restr , xreg(1) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[1, 1]
 
reghdfe l2_settl tr_all_move_5000 if experiment_period==8 ///
$sample_restr , cluster($cluster_level) absorb($baseline_FE)
$add_y
$rec_est

							**** lag city indicator ****
							
space_reg Y X cutoff1 cutoff2 l_city_cell tr_all_move_5000 if experiment_period==8 ///
$sample_restr , xreg(1) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[1, 1]
 
reghdfe l_city_cell tr_all_move_5000 if experiment_period==8 ///
$sample_restr , cluster($cluster_level) absorb($baseline_FE)
$add_y
$rec_est 

space_reg Y X cutoff1 cutoff2 l2_city_cell tr_all_move_5000 if experiment_period==8 ///
$sample_restr , xreg(1) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[1, 1]
 
reghdfe l2_city_cell tr_all_move_5000 if experiment_period==8 ///
$sample_restr , cluster($cluster_level) absorb($baseline_FE)
$add_y
$rec_est

							**** lag canal indicator ****
							
space_reg Y X cutoff1 cutoff2 l_canal tr_all_move_5000 if experiment_period==8 ///
$sample_restr , xreg(1) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[1, 1]
 
reghdfe l_canal tr_all_move_5000 if experiment_period==8 ///
$sample_restr , cluster($cluster_level) absorb($baseline_FE)
$add_y
$rec_est 

space_reg Y X cutoff1 cutoff2 l2_canal tr_all_move_5000 if experiment_period==8 ///
$sample_restr , xreg(1) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[1, 1]
 
reghdfe l2_canal tr_all_move_5000 if experiment_period==8 ///
$sample_restr , cluster($cluster_level) absorb($baseline_FE)
$add_y
$rec_est

esttab  using "$project_output_path\2.tex", ///
b(2) se(2) se ///
keep(tr_all_move_5000) nonumber label ///
stats(ymean N N_clust c_se, fmt(2 0 0 2)labels("Mean dep. var." "Observations" "Clusters" "Conley SE" )) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace

