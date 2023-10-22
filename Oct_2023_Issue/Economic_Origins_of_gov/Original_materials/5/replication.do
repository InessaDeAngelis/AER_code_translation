clear all

* load data
use "5/dataset.dta"

*** set globals

* treatment 
global add_treatment  "period_lag_4_tr period_lag_3_tr period_lag_2_tr period_tr_tr"

* fixed effects
global baseline_FE "grid_cell_no period period#i.dataset_int period#c.average_temperature period#c.average_rainfall period#period7_fixed_city_cell"

* clusters
global cluster_level "grid_cell_no"

*********** replicate regression and generate standard errors ******************

eststo clear

* panel 1
space_reg Y X cutoff1 cutoff2 is_under_city_state_map_tot $add_treatment, xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

reghdfe is_under_city_state_map_tot $add_treatment, cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 
$rec_est

space_reg Y X cutoff1 cutoff2 is_under_city_state_map_tot $add_treatment if high_density_count==1, xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

reghdfe is_under_city_state_map_tot $add_treatment if high_density_count==1, cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 
$rec_est

space_reg Y X cutoff1 cutoff2 is_under_city_state_map_tot $add_treatment if high_density_count==0, xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

reghdfe is_under_city_state_map_tot $add_treatment if high_density_count==0, cluster($cluster_level) absorb($baseline_FE) 
$add_y
$add_p_value 
$rec_est

space_reg Y X cutoff1 cutoff2 is_under_city_state_map_tot $add_treatment if aligned_wrong==0, xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

reghdfe is_under_city_state_map_tot $add_treatment if aligned_wrong==0, cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 
$rec_est

space_reg Y X cutoff1 cutoff2 is_under_city_state_map_tot $add_treatment if aligned_wrong==1, xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

reghdfe is_under_city_state_map_tot $add_treatment if aligned_wrong==1, cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 
$rec_est

esttab  using "$project_output_path\5_1.tex", ///
b(2) se(2) se ///
keep(period_tr_tr) nonumber label ///
stats(p_pl ymean N N_clust c_se, fmt(2 2 0 0 2)labels("P-value pre-trend" "Mean dep. var." "Observations" "Clusters" "Conley SE")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace



*test equality of coefficients columns 2 and 3
gen period_lag_4_tr_HD = period_lag_4_tr * high_density_count
gen period_lag_3_tr_HD = period_lag_3_tr * high_density_count
gen period_lag_2_tr_HD = period_lag_2_tr * high_density_count
gen period_tr_tr_HD = period_tr_tr * high_density_count

global treat_HD "period_lag_4_tr_HD period_lag_3_tr_HD period_lag_2_tr_HD period_tr_tr_HD"

global FE_het_HD "grid_cell_no#high_density_count period#high_density_count period#i.dataset_int#high_density_count period#c.average_temperature#high_density_count period#c.average_rainfall#high_density_count period#period7_fixed_city_cell#high_density_count"


reghdfe is_under_city_state_map_tot $add_treatment $treat_HD, ///
 cluster($cluster_level) absorb($FE_het_HD) constant

test period_tr_tr=period_tr_tr_HD

* test equality of coefficients columns 4 and 5
gen period_lag_4_tr_AW = period_lag_4_tr * aligned_wrong
gen period_lag_3_tr_AW = period_lag_3_tr * aligned_wrong
gen period_lag_2_tr_AW = period_lag_2_tr * aligned_wrong
gen period_tr_tr_AW = period_tr_tr * aligned_wrong

global treat_AW "period_lag_4_tr_AW period_lag_3_tr_AW period_lag_2_tr_AW period_tr_tr_AW"

global FE_het_AW "grid_cell_no#aligned_wrong period#aligned_wrong period#i.dataset_int#aligned_wrong period#c.average_temperature#aligned_wrong period#c.average_rainfall#aligned_wrong period#period7_fixed_city_cell#aligned_wrong"


reghdfe is_under_city_state_map_tot $add_treatment $treat_AW, ///
 cluster($cluster_level) absorb($FE_het_AW)

test period_tr_tr=period_tr_tr_AW


**********************************

* panel 2

eststo clear

space_reg Y X cutoff1 cutoff2 is_under_city_state_map_tot $add_treatment, xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

reghdfe is_under_city_state_map_tot $add_treatment, cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 
$rec_est

space_reg Y X cutoff1 cutoff2 is_under_city_state_map_tot $add_treatment if high_returns_diff==1, xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

reghdfe is_under_city_state_map_tot $add_treatment if high_returns_diff==1, cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 
$rec_est

space_reg Y X cutoff1 cutoff2 is_under_city_state_map_tot $add_treatment if high_returns_diff==0, xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

reghdfe is_under_city_state_map_tot $add_treatment if high_returns_diff==0, cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 
$rec_est

space_reg Y X cutoff1 cutoff2 is_under_city_state_map_tot $add_treatment if low_water_flow==0, xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

reghdfe is_under_city_state_map_tot $add_treatment if low_water_flow==0, cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 
$rec_est

space_reg Y X cutoff1 cutoff2 is_under_city_state_map_tot $add_treatment if low_water_flow==1, xreg(4) coord(2) model(reghdfe, $baseline_FE) 
mat se = e(se)
scalar c_se = se[4, 1]

reghdfe is_under_city_state_map_tot $add_treatment if low_water_flow==1, cluster($cluster_level) absorb($baseline_FE)
$add_y
$add_p_value 
$rec_est

esttab  using "$project_output_path\5_2.tex", ///
b(2) se(2) se ///
keep(period_tr_tr) nonumber label ///
stats(p_pl ymean N N_clust c_se, fmt(2 2 0 0 2)labels("P-value pre-trend" "Mean dep. var." "Observations" "Clusters" "Conley SE")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace

*test equality of coefficients columns 2 and 3
gen period_lag_4_tr_HP = period_lag_4_tr * high_returns_diff
gen period_lag_3_tr_HP = period_lag_3_tr * high_returns_diff
gen period_lag_2_tr_HP = period_lag_2_tr * high_returns_diff
gen period_tr_tr_HP = period_tr_tr * high_returns_diff

global treat_HP "period_lag_4_tr_HP period_lag_3_tr_HP period_lag_2_tr_HP period_tr_tr_HP"

global FE_het_HP "grid_cell_no#high_returns_diff period#high_returns_diff period#i.dataset_int#high_returns_diff period#c.average_temperature#high_returns_diff period#c.average_rainfall#high_returns_diff period#period7_fixed_city_cell#high_returns_diff"


reghdfe is_under_city_state_map_tot $add_treatment $treat_HP, ///
 cluster($cluster_level) absorb($FE_het_HP)

test period_tr_tr=period_tr_tr_HP

*test equality of coefficients columns 4 and 5
gen period_lag_4_tr_WF = period_lag_4_tr * low_water_flow
gen period_lag_3_tr_WF = period_lag_3_tr * low_water_flow
gen period_lag_2_tr_WF = period_lag_2_tr * low_water_flow
gen period_tr_tr_WF = period_tr_tr * low_water_flow

global treat_WF "period_lag_4_tr_WF period_lag_3_tr_WF period_lag_2_tr_WF period_tr_tr_WF"

global FE_het_WF "grid_cell_no#low_water_flow period#low_water_flow period#i.dataset_int#low_water_flow period#c.average_temperature#low_water_flow period#c.average_rainfall#low_water_flow period#period7_fixed_city_cell#low_water_flow"


reghdfe is_under_city_state_map_tot $add_treatment $treat_WF, ///
 cluster($cluster_level) absorb($FE_het_WF)

test period_tr_tr=period_tr_tr_WF

