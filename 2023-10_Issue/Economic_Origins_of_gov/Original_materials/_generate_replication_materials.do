* this do file generates individual replication files

*Table 1

*Panel A

use $stacked_panel, clear

keep if experiment_period==8 

keep treated_away ///
treated_closer ///
settlement_count ///
city_cell ///
on_canal_5000 ///
is_under_city_state_map_tot ///
is_under_city_state_map_tot_new ///
is_under_city_state_map_tot_cont ///
building ///
defensive_wall ///
tablet ///
tot_buildings

save "1\dataset_A.dta", replace

*Panel B

use $panel, clear

keep if period<=31

keep tr_all_move_5000 ///
on_canal_5000

save "1\dataset_B.dta", replace

*Panel C

use $stacked_panel, clear

keep if experiment_period==8 & period==0 

keep surveyed ///
average_rainfall ///
average_temperature ///
period7_fixed_city_cell ///
high_returns_diff ///
low_water_flow ///
high_density_count ///
aligned_wrong

save "1\dataset_C.dta", replace

* table 2
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep Y X cutoff1 cutoff2 ///
l_settl l2_settl l_city_cell l2_city_cell l_canal l2_canal ///
$add_treatment grid_cell_no period dataset_int average_temperature average_rainfall period7_fixed_city_cell

save "2\dataset.dta", replace

* table 3
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep Y X cutoff1 cutoff2 ///
is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont ///
$add_treatment grid_cell_no period dataset_int average_temperature average_rainfall period7_fixed_city_cell

save "3/dataset.dta", replace

* table 4
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep Y X cutoff1 cutoff2 ///
on_canal_5000 defensive_wall tablet tot_buildings ///
$add_treatment grid_cell_no period dataset_int average_temperature average_rainfall period7_fixed_city_cell

save "4/dataset.dta", replace

* table 5
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep Y X cutoff1 cutoff2 ///
is_under_city_state_map_tot high_density_count aligned_wrong high_returns_diff low_water_flow high_returns_diff low_water_flow ///
$add_treatment grid_cell_no period dataset_int average_temperature average_rainfall period7_fixed_city_cell 

save "5/dataset.dta", replace

* table 6
use $panel, clear

keep if tr_all_move_close_5000!=1 & not_treated_before==1 & surveyed==1

keep Y X cutoff1 cutoff2 period ///
on_canal_5000 tr_all_move_5000 grid_cell_no period dataset_int average_temperature average_rainfall period7_fixed_city_cell

save "6/dataset.dta", replace

* RA1
use $panel , clear

collapse (max) tr_all_move_5000 not_excavated_indicator d_bare_area on_canal_1952, by(grid_cell_no)
drop grid_cell_no
la var tr_all_move_5000 "River shift (yes/no)"

save "RA1/dataset.dta", replace

* RA2
use $panel , clear

collapse (max) tr_all_move_5000 average_rainfall average_temperature ///
suitability_diff X Y, by(grid_cell_no)
drop grid_cell_no
la var tr_all_move_5000 "River shift (yes/no)"

save "RA2/dataset.dta", replace

* RA3
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont

save "RA3/dataset.dta", replace

* RA4
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot $add_treatment $cluster_level building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont 

save "RA4/dataset.dta", replace

* RA5
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot $add_treatment $cluster_level building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont period

save "RA5/dataset.dta", replace

* RA6
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont period tr_all_move_5000 dataset_int average_temperature average_rainfall exp_period_fixed_city_cell $cluster_level 

save "RA6/dataset.dta", replace

* RA7
use $stacked_panel, clear

collapse (max) is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont dataset_int period7_fixed_city_cell surveyed cutoff1 cutoff2 (mean) average_temperature average_rainfall Y X distance_to_river_all, by(FID_10km period experiment_period)

keep if experiment_period==8
xtset FID_10km period

gen treated_5km_away = (l.distance_to_river_all<5000 & distance_to_river_all > 5000 & l.distance_to_river_all!=.)
gen treated_5km_closer = (l.distance_to_river_all>5000 & distance_to_river_all < 5000 & l.distance_to_river_all!=.)

bysort FID_10km: egen treated_away = max(treated_5km_away)
bysort FID_10km: egen treated_closer = max(treated_5km_closer)

gen period_lag_4_tr = (period==-4 & treated_away==1)
gen period_lag_3_tr = (period==-3 & treated_away==1)
gen period_lag_2_tr = (period==-2 & treated_away==1)
gen period_lag_1_tr = (period==-1 & treated_away==1)
gen period_tr_tr = (period==0 & treated_away==1)

gen period_lag_4_tr_cl = (period==-4 & treated_closer==1)
gen period_lag_3_tr_cl = (period==-3 & treated_closer==1)
gen period_lag_2_tr_cl = (period==-2 & treated_closer==1)
gen period_lag_1_tr_cl = (period==-1 & treated_closer==1)
gen period_tr_tr_cl = (period==0 & treated_closer==1)

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont FID_10km $add_treatment FID_10km period dataset_int average_temperature average_rainfall period7_fixed_city_cell

save "RA7/dataset.dta", replace


* RA8
use $stacked_panel, clear

keep if experiment_period==8

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA8/dataset.dta", replace

* RA9
use $stacked_panel, clear

keep if experiment_period==8 & treated_closer!=1

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA9/dataset.dta", replace

* RA10
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA10/dataset.dta", replace

* RA11
use $stacked_panel, clear

keep if experiment_period==8 & treated_closer!=1 & high_survey_quality==1

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA11/dataset.dta", replace

* RA12
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1  & sample_river==1

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA12/dataset.dta", replace

* RA13
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont $add_treatment_2km $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA13/dataset.dta", replace

* RA14
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont $add_treatment_35km $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA14/dataset.dta", replace

* RA15
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont $add_treatment_75km $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA15/dataset.dta", replace

* RA16
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont $add_treatment_10km $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA16/dataset.dta", replace

* RA17
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map building_admin_only is_under_city_state_map_new is_under_city_state_map_cont $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA17/dataset.dta", replace

* RA18
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot_8km building_8km is_under_city_state_map_totN8km is_under_city_state_map_totC8km $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA18/dataset.dta", replace

* RA19
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot_12km building_12km is_under_city_state_map_totN12km is_under_city_state_map_totC12km $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA19/dataset.dta", replace

* RA20
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot_15km building_15km is_under_city_state_map_totN15km is_under_city_state_map_totC15km $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA20/dataset.dta", replace

* RA21
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot_alt building_alt city_state_map_tot_new_alt city_state_map_tot_cont_alt $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA21/dataset.dta", replace

* RA22
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont $add_treatment FID_10km grid_cell_no period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA22/dataset.dta", replace

* RA23
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont $add_treatment  grid_cell_no nearest_city_ID period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell Y X cutoff7 cutoff8 cutoff5 cutoff6 cutoff3 cutoff4 

save "RA23/dataset.dta", replace

* RA24
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell $spatial_lag_treat state_tot_SPLAG building_SPLAG state_tot_new_SPLAG state_tot_cont_SPLAG

save "RA24/dataset.dta", replace

* RA25
use $stacked_panel, clear

keep if experiment_period==8 $sample_restr_closer

keep is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont $add_treatment_closer $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell $spatial_lag_treat state_tot_SPLAG building_SPLAG state_tot_new_SPLAG state_tot_cont_SPLAG

save "RA25/dataset.dta", replace

* RA26
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep MP_settl_density_ha seal_indicator $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell cutoff1 cutoff2 Y X

save "RA26/dataset.dta", replace

* RA27
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep on_canal_5000 defensive_wall tablet tot_buildings $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell

save "RA27/dataset.dta", replace

* RA28
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep on_canal_5000 defensive_wall tablet tot_buildings $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell nearest_city_ID

save "RA28/dataset.dta", replace

* RA29
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 & period > -3

keep Y X cutoff1 cutoff2 tablet admin_tablet tax_indicator tax_food_indicator period $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell  

save "RA29/dataset.dta", replace

* RA30
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 

keep is_under_city_state_map_tot high_density_count aligned_wrong high_returns_diff low_water_flow $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell  

save "RA30/dataset.dta", replace

* RA31
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 & period > -3

keep Y X cutoff1 cutoff2 lugal_indicator_ratio gal_indicator_ratio canal_indicator_ratio tax_indicator_ratio $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell  

save "RA31/dataset.dta", replace

* RA32
use $stacked_panel, clear

keep if experiment_period==8 & surveyed==1 & treated_closer!=1 & period > -3

keep Y X cutoff1 cutoff2 lugal_indicator_ratio gal_indicator_ratio canal_indicator_ratio tax_indicator_ratio tablet $add_treatment $cluster_level period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell  

save "RA32/dataset.dta", replace

* RA33
use $stacked_panel, clear

keep if sample_untreated_before==1 & surveyed==1 & treated_closer!=1

keep on_canal_5000 experiment_period $add_treatment $cluster_level period experiment_period dataset_int average_temperature average_rainfall exp_period_fixed_city_cell 
save "RA33/dataset.dta", replace

* RA34
use $panel, clear

keep if tr_all_move_close_5000!=1 & not_treated_before==1 & surveyed==1

keep on_canal_5000 tr_all_move_5000 period $cluster_level dataset_int average_temperature average_rainfall period7_fixed_city_cell  
save "RA34/dataset.dta", replace