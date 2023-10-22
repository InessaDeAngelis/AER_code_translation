clear all

* load data
use "RA23/dataset.dta"

*** set globals

* treatment
global add_treatment  "period_lag_4_tr period_lag_3_tr period_lag_2_tr period_tr_tr"

* fixed effects
global baseline_FE "grid_cell_no period period#i.dataset_int period#c.average_temperature period#c.average_rainfall period#exp_period_fixed_city_cell"

* clusters
global cluster_level_double "grid_cell_no i.period#i.nearest_city_ID"

*********** replicate regression and generate standard errors ******************


eststo clear

*full specification

space_reg Y X cutoff7 cutoff8 is_under_city_state_map_tot $add_treatment  , xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

space_reg Y X cutoff5 cutoff6 is_under_city_state_map_tot $add_treatment  , xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c1_se = se[4, 1]

space_reg Y X cutoff3 cutoff4 is_under_city_state_map_tot $add_treatment  , xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c2_se = se[4, 1]

reghdfe is_under_city_state_map_tot $add_treatment  , cluster(grid_cell_no i.period#i.nearest_city_ID) absorb($baseline_FE)
$add_y
$add_p_value 
eststo, addscalars(c_se c_se c1_se c1_se c2_se c2_se)

*alternative outcome
space_reg Y X cutoff7 cutoff8 building $add_treatment  , xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

space_reg Y X cutoff5 cutoff6 building $add_treatment  , xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c1_se = se[4, 1]

space_reg Y X cutoff3 cutoff4 building $add_treatment  , xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c2_se = se[4, 1]

reghdfe building $add_treatment  , cluster(grid_cell_no i.period#i.nearest_city_ID) absorb($baseline_FE)
$add_y
$add_p_value 
eststo, addscalars(c_se c_se c1_se c1_se c2_se c2_se)

*New states
space_reg Y X cutoff7 cutoff8 is_under_city_state_map_tot_new $add_treatment  , xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

space_reg Y X cutoff5 cutoff6 is_under_city_state_map_tot_new $add_treatment  , xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c1_se = se[4, 1]

space_reg Y X cutoff3 cutoff4 is_under_city_state_map_tot_new $add_treatment  , xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c2_se = se[4, 1]

reghdfe is_under_city_state_map_tot_new $add_treatment  , cluster(grid_cell_no i.period#i.nearest_city_ID) absorb($baseline_FE)
$add_y
$add_p_value 
eststo, addscalars(c_se c_se c1_se c1_se c2_se c2_se)

*Expanding states
space_reg Y X cutoff5 cutoff6 is_under_city_state_map_tot_cont $add_treatment  , xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

space_reg Y X cutoff5 cutoff6 is_under_city_state_map_tot_cont $add_treatment  , xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c1_se = se[4, 1]

space_reg Y X cutoff3 cutoff4 is_under_city_state_map_tot_cont $add_treatment  , xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c2_se = se[4, 1]

reghdfe is_under_city_state_map_tot_cont $add_treatment  , cluster(grid_cell_no i.period#i.nearest_city_ID) absorb($baseline_FE)
$add_y
$add_p_value 
eststo, addscalars(c_se c_se c1_se c1_se c2_se c2_se)

esttab  using "$project_output_path\RA23.tex", ///
b(2) se(2) se ///
keep(period_tr_tr) nonumber label ///
stats(p_pl ymean N N_clust1 N_clust2 c_se c1_se c2_se, fmt(2 2 0 0 0 2 2 2)labels("P-value pre-trend" "Mean dep. var." "Observations" "Clusters 1 - Grid cells" "Clusters 2 - City x period" "Conley SE 66 km" "Conley SE 121 km" "Conley SE 242 km")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace
