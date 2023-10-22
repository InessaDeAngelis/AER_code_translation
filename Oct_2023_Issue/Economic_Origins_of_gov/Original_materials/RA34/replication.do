clear all

* load data
use "RA34/dataset.dta"

*** set globals 

* clusters
global cluster_level "grid_cell_no"

*set seed
set seed 200
*********** replicate regression and generate standard errors ******************


*
did_multiplegt on_canal_5000 grid_cell_no period tr_all_move_5000 if period <=31, placebo(4) trends_nonparam(dataset_int) trends_lin(average_temperature average_rainfall period7_fixed_city_cell) cluster($cluster_level) breps(100)
ereturn list
scalar t_stat_0 = e(effect_0)/e(se_effect_0)
scalar p_val_0 = 2*normal(-abs(t_stat_0))
di p_val_0
scalar t_stat_1 = e(placebo_1)/e(se_placebo_1)
scalar p_val_1 = 2*normal(-abs(t_stat_1))
di p_val_1
scalar t_stat_2 = e(placebo_2)/e(se_placebo_2)
scalar p_val_2 = 2*normal(-abs(t_stat_2))
di p_val_2
scalar t_stat_3 = e(placebo_3)/e(se_placebo_3)
scalar p_val_3 = 2*normal(-abs(t_stat_3))
di p_val_3
scalar t_stat_4 = e(placebo_4)/e(se_placebo_4)
scalar p_val_4 = 2*normal(-abs(t_stat_4))
di p_val_4

*
did_multiplegt on_canal_5000 grid_cell_no period tr_all_move_5000 if period <= 10, placebo(4) trends_nonparam(dataset_int) trends_lin(average_temperature average_rainfall period7_fixed_city_cell) cluster($cluster_level) breps(100)
ereturn list
scalar t_stat_0 = e(effect_0)/e(se_effect_0)
scalar p_val_0 = 2*normal(-abs(t_stat_0))
di p_val_0
scalar t_stat_1 = e(placebo_1)/e(se_placebo_1)
scalar p_val_1 = 2*normal(-abs(t_stat_1))
di p_val_1
scalar t_stat_2 = e(placebo_2)/e(se_placebo_2)
scalar p_val_2 = 2*normal(-abs(t_stat_2))
di p_val_2
scalar t_stat_3 = e(placebo_3)/e(se_placebo_3)
scalar p_val_3 = 2*normal(-abs(t_stat_3))
di p_val_3
scalar t_stat_4 = e(placebo_4)/e(se_placebo_4)
scalar p_val_4 = 2*normal(-abs(t_stat_4))
di p_val_4

*
did_multiplegt on_canal_5000 grid_cell_no period tr_all_move_5000 if period > 10 & period <=31, placebo(4) trends_nonparam(dataset_int) trends_lin(average_temperature average_rainfall period7_fixed_city_cell) cluster($cluster_level) breps(100) 
ereturn list
scalar t_stat_0 = e(effect_0)/e(se_effect_0)
scalar p_val_0 = 2*normal(-abs(t_stat_0))
di p_val_0
scalar t_stat_1 = e(placebo_1)/e(se_placebo_1)
scalar p_val_1 = 2*normal(-abs(t_stat_1))
di p_val_1
scalar t_stat_2 = e(placebo_2)/e(se_placebo_2)
scalar p_val_2 = 2*normal(-abs(t_stat_2))
di p_val_2
scalar t_stat_3 = e(placebo_3)/e(se_placebo_3)
scalar p_val_3 = 2*normal(-abs(t_stat_3))
di p_val_3
scalar t_stat_4 = e(placebo_4)/e(se_placebo_4)
scalar p_val_4 = 2*normal(-abs(t_stat_4))
di p_val_4
