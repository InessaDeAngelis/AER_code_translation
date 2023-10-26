*********************************************************************
*
* REPLICATION FILES README
* "THE ECONOMIC ORIGINS OF GOVERNMENT"
* Allen, Bertazzini, Heldring - 2023
*
*********************************************************************

* Please read the following

** STEP 1: SET THE APPROPRIATE DIRECTORY WHERE YOU SAVED THE REPLICATION FILES **

global project_path ""

* set folder where you would like to save output.
global project_output_path ""

cd "$project_path"

** STEP 2: INSTALL SPACE-REG AND OTHER PACKAGES**

* In this folder there is a .ado file, space_reg.ado. Copy this file into your
* ado folder. It enables quick computation of Conley standard errors. For
* more on space_reg, see www.leanderheldring.com and the paper "Spatial standard
* errors for several common M-estimators" with Luis Calderon.

*ssc install estout
*ssc install reghdfe
*ssc install ftools

*this part of code sets the globals

* datasets
global panel "panel_dataset_replication.dta"
global stacked_panel "panel_dataset_stacked_replication.dta"

* fixed effects
global baseline_FE "grid_cell_no period period#i.dataset_int period#c.average_temperature period#c.average_rainfall period#exp_period_fixed_city_cell"
global baseline_FE_full "grid_cell_no period experiment_period experiment_period#period#i.dataset_int experiment_period#period#c.average_temperature experiment_period#period#c.average_rainfall experiment_period#period#exp_period_fixed_city_cell experiment_period#grid_cell_no experiment_period#period"

* clusters
global cluster_level "grid_cell_no"

* treatment 
global add_treatment  "period_lag_4_tr period_lag_3_tr period_lag_2_tr period_tr_tr"
global add_treatment_closer  "period_lag_4_tr_cl  period_lag_3_tr_cl period_lag_2_tr_cl period_tr_tr_cl"
global shift_treatment  "tr_all_move_5000"
global add_treatment_2km  "period_lag_4_tr_2km period_lag_3_tr_2km period_lag_2_tr_2km period_tr_tr_2km"
global add_treatment_35km  "period_lag_4_tr_35km period_lag_3_tr_35km period_lag_2_tr_35km period_tr_tr_35km"
global add_treatment_75km  "period_lag_4_tr_75km period_lag_3_tr_75km period_lag_2_tr_75km period_tr_tr_75km"
global add_treatment_10km  "period_lag_4_tr_10km period_lag_3_tr_10km period_lag_2_tr_10km period_tr_tr_10km"
global spatial_lag_treat "period_lag_4_tr_splag period_lag_3_tr_splag period_lag_2_tr_splag period_tr_tr_splag"

* sample restrictions
global sample_restr "& treated_closer!=1 & surveyed==1"
global sample_restr_closer "& treated_away!=1 & surveyed==1"

global sample_restr_balance "& surveyed==1"
global sample_restr_eventdd "& tr_all_move_close_5000!=1 & not_treated_before==1 & surveyed==1"

* regression options
global spatial_options "timevar(period) panelvar(grid_cell_no) lat(Y) lon(X) distcutoff(100)"

* adding constants for table notes
global add_y "estadd ysumm"
global add_p_value "estadd scalar p_pl = 2*(ttail(e(df_r), abs(_b[period_lag_2_tr]/_se[period_lag_2_tr])))"

* record estimates including conley
global rec_est "eststo, addscalars(c_se c_se)"

*This do file imports the GIS output, cleans the data, generates all variables and outputs the dataset(s) for the analysis
do "$project_path\_prep_data_rep.do"

*This do file creates individual datasets for replication of tables and figures
do "$project_path\_generate_replication_materials.do"

*This do file generates tables and figures and outputs them in one folder
do "$project_path\_replication_main.do"