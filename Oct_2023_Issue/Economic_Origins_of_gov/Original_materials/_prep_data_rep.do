* import GIS generated dataset 
use panel_dataset_raw_replication.dta, clear
 
* set panel
xtset grid_cell_no period

                             ******************************* DATA CLEANING AND VARIABLES DEFINITION ****************************



*recode distance in meters
replace dist_to_city=dist_to_city/1000


*set to missing period for canals and settlement data that are missing in the sources: see table DA4 in the data appendix

*canals
replace dist_nearest_canal = . if period==7 & dataset=="lbb"
replace dist_nearest_canal = . if period==18 & dataset=="lbb"
replace dist_nearest_canal = . if period==30 & dataset=="lbb"
replace dist_nearest_canal = . if period==31 & dataset=="lbb"

replace dist_nearest_canal = . if period==18 & dataset=="lok"
replace dist_nearest_canal = . if period==27 & dataset=="lok"
replace dist_nearest_canal = . if period==29 & dataset=="lok"
replace dist_nearest_canal = . if period==30 & dataset=="lok"
replace dist_nearest_canal = . if period==31 & dataset=="lok"

replace dist_nearest_canal = . if period==29 & dataset=="hoc"
replace dist_nearest_canal = . if period==30 & dataset=="hoc"
replace dist_nearest_canal = . if period==31 & dataset=="hoc"

*settlement
foreach settl in settlement_count settlement_area {
	
	replace `settl' = . if period==7 & dataset=="lbb"
	replace `settl' = . if period==18 & dataset=="lbb"
	replace `settl' = . if period==26 & dataset=="lbb"
	replace `settl' = . if period==28 & dataset=="lbb"
	replace `settl' = . if period==31 & dataset=="lbb"

	replace `settl' = . if period==18 & dataset=="lok"
	replace `settl' = . if period==27 & dataset=="lok"
	replace `settl' = . if period==29 & dataset=="lok"
	replace `settl' = . if period==30 & dataset=="lok"
	replace `settl' = . if period==31 & dataset=="lok"
	

}

*generate sample main study period
gen main_study_period = (period > 3 & period < 9)

*Generate sample of study period cities that are located but not excavated
gen missing_city_sample = (nearest_city_name=="Akshak" | nearest_city_name=="Bad Tibira" | nearest_city_name=="Kesh" | nearest_city_name=="Larak")

*tablets

* recode zeroes to missing for non excavated cities based on buildings in nearest city
foreach var in n_tablets n_admin_tablets tablet admin_tablet {
    
	replace `var'=. if number_of_palaces==. & number_of_temples==. & number_of_ziggurats==.
}

*set non-excavated to missing for main study period
foreach y in n_tablets n_admin_tablets tablet admin_tablet number_of_palaces number_of_temples number_of_ziggurats defensive_wall {
    
	replace `y' = . if main_study_period==1 & missing_city_sample==1
}

*set words indicators from text analysis on tablets to missing
foreach y in tax_indicator tax_food_indicator seal_indicator lugal_indicator_ratio gal_indicator_ratio canal_indicator_ratio tax_indicator_ratio {	
     
	*not excavated
	replace `y' = . if main_study_period==1 & missing_city_sample==1

	*tablets exist but none is transliterated for a given period
	replace `y' = . if period==7 & nearest_city_name=="Ur"
    replace `y' = . if period==8 & nearest_city_name=="Khafagi"
}


                                          ************************* GENERATE WATER VARIABLES  ***********************

* gen treatment with different cut-offs: On river in t-1, no longer in t
gen tr_all_move_2000=(l1.distance_to_river_all <2000 & distance_to_river_all>2000)
gen tr_all_move_3500=(l1.distance_to_river_all <3500 & distance_to_river_all>3500)
gen tr_all_move_5000=(l1.distance_to_river_all <5000 & distance_to_river_all>5000)
gen tr_all_move_7500=(l1.distance_to_river_all <7500 & distance_to_river_all>7500)
gen tr_all_move_10000=(l1.distance_to_river_all <10000 & distance_to_river_all>10000)

*set treated to zero for undated period 31 shift
foreach x in tr_all_move_2000 tr_all_move_3500 tr_all_move_5000 tr_all_move_7500 tr_all_move_10000 {
    
	replace `x' = 0 if period==31
}

* remove one treated grid in period 4 due to spatial error
foreach x in tr_all_move_2000 tr_all_move_3500 tr_all_move_5000 tr_all_move_7500 tr_all_move_10000 {
    
	replace `x' = 0 if period==4
}

* gen dummy for being on a canal
gen on_canal_5000 = (dist_nearest_canal < 5000 & dist_nearest_canal!=.)
replace on_canal_5000 = . if dist_nearest_canal==.
replace on_canal_5000=0 if period<4 & on_canal_5000==.



                                            ********************* FIXED EFFECTS AND SAMPLE RESTRICTIONS ********************

* gen dataset fixed effects
encode dataset, gen(dataset_int)

* gen nearest city numeric identifier
encode nearest_city_name, gen(nearest_city_ID)

* gen moving closer indicator
gen tr_all_move_close_5000=(l1.distance_to_river_all>5000 & distance_to_river_all<5000)

* set to zero for periods 4 and 31
replace tr_all_move_close_5000 = 0 if period==4 | period==31

* gen treated within the previous 4 periods indicator
gen treated_2_1 = (l2.distance_to_river_all<5000 & l1.distance_to_river_all>5000)
gen treated_3_2 = (l3.distance_to_river_all<5000 & l2.distance_to_river_all>5000)
gen treated_4_3 = (l4.distance_to_river_all<5000 & l3.distance_to_river_all>5000)
gen treated_5_4 = (l5.distance_to_river_all<5000 & l4.distance_to_river_all>5000)

gen not_treated_before= (treated_2_1==0 & treated_3_2==0)
gen sample_remove_pr_tr = (tr_all_move_5000==1 | not_treated_before==1)

* gen next to river before the shift indicator
gen next_to_river_1_0 = (l1.distance_to_river_all<10000)
gen sample_next_to_river = (next_to_river_1_0==1)

* gen indicator for surveyed parts of the sample area
gen surveyed = 0
replace surveyed = 1 if dataset=="lok" | dataset=="lbb"
replace surveyed = 1 if dataset=="hoc" & survey_quality_category=="Surveyed"
replace surveyed = 1 if dataset=="hoc" & survey_quality_category=="Limited Survey"

* gen alternative indicator for surveyed parts of the sample area
gen high_survey_quality = 0
replace high_survey_quality = 1 if dataset=="lbb"
replace high_survey_quality = 1 if dataset=="lok"
replace high_survey_quality = 1 if dataset=="hoc" & survey_quality_category=="Surveyed"


                                         ********************************* SETTLEMENT ***********************************
 
* gen city indicator
bysort period nearest_city_name: egen min_dist=min(dist_to_city)
gen city_cell = (dist_to_city == min_dist & dist_to_city<3.5355)

* gen settlement_density
gen area_settlement = settlement_area*settlement_count


                                     ********************************* STATE FORMATION OUTCOMES ******************************

* set ziggurats to missing based on temples
replace number_of_ziggurats=. if number_of_ziggurats==0 & number_of_temples==. 

* gen variables for number of buildings in nearest city - palaces and ziggurats
gen nr_of_admin_build = ///
cond(missing(number_of_palaces), 0, number_of_palaces) + ///
cond(missing(number_of_ziggurats), 0, number_of_ziggurats)
replace nr_of_admin_build= . if number_of_palaces==. & number_of_ziggurats==.
replace nr_of_admin_build= . if main_study_period==1 & missing_city_sample==1

* gen variables for number of buildings in nearest city - all admin buildings
gen tot_buildings = ///
cond(missing(nr_of_admin_build), 0, nr_of_admin_build) + ///
cond(missing(number_of_temples), 0, number_of_temples)
replace tot_buildings= . if number_of_palaces==. & number_of_ziggurats==. & number_of_temples==.
replace tot_buildings= . if main_study_period==1 & missing_city_sample==1

* set state indicators to zero for pre-period 8 - state indicators 

*6km 

*all states
gen is_under_city_state_map_tot = is_under_city_state_map_totO
replace is_under_city_state_map_tot = 0 if dist_to_city > 6 & period < 8

*new states
gen is_under_city_state_map_tot_new = is_under_city_state_map_tot_newO
replace is_under_city_state_map_tot_new = 0 if dist_to_city > 6 & period < 8

*expanding states
gen is_under_city_state_map_tot_cont = is_under_city_state_map_tot_conO
replace is_under_city_state_map_tot_cont = 0 if dist_to_city > 6 & period < 8

*all states
gen is_under_city_state_map = is_under_city_state_mapO
replace is_under_city_state_map = 0 if dist_to_city > 6 & period < 8

*new states 
gen is_under_city_state_map_new = is_under_city_state_map_newO
replace is_under_city_state_map_new = 0 if dist_to_city > 6 & period < 8

*expanding states
gen is_under_city_state_map_cont = is_under_city_state_map_conO
replace is_under_city_state_map_cont = 0 if dist_to_city > 6 & period < 8
 
*8km

*all states
gen is_under_city_state_map_tot_8km = is_under_city_state_map_totO
replace is_under_city_state_map_tot_8km = 0 if dist_to_city > 8 & period < 8

*new states
gen is_under_city_state_map_totN8km = is_under_city_state_map_tot_newO
replace is_under_city_state_map_totN8km = 0 if dist_to_city > 8 & period < 8

*expanding states
gen is_under_city_state_map_totC8km = is_under_city_state_map_tot_conO
replace is_under_city_state_map_totC8km = 0 if dist_to_city > 8 & period < 8

*12km

*all states
gen is_under_city_state_map_tot_12km = is_under_city_state_map_totO
replace is_under_city_state_map_tot_12km = 0 if dist_to_city > 12 & period < 8

*new states
gen is_under_city_state_map_totN12km = is_under_city_state_map_tot_newO
replace is_under_city_state_map_totN12km = 0 if dist_to_city > 12 & period < 8

*expanding states
gen is_under_city_state_map_totC12km = is_under_city_state_map_tot_conO
replace is_under_city_state_map_totC12km = 0 if dist_to_city > 12 & period < 8

*15km

*all states
gen is_under_city_state_map_tot_15km = is_under_city_state_map_totO
replace is_under_city_state_map_tot_15km = 0 if dist_to_city > 15 & period < 8

*new states
gen is_under_city_state_map_totN15km = is_under_city_state_map_tot_newO
replace is_under_city_state_map_totN15km = 0 if dist_to_city > 15 & period < 8

*expanding states
gen is_under_city_state_map_totC15km = is_under_city_state_map_tot_conO
replace is_under_city_state_map_totC15km = 0 if dist_to_city > 15 & period < 8 


* gen alternative state indicators

gen building = (tot_buildings>0 & tot_buildings!=.)
replace building = 0 if dist_to_city > 6 & period < 8
replace building = . if tot_buildings==.

gen building_admin_only = building
replace building_admin_only = 0 if nr_of_admin_build==0 & building!=.
replace building_admin_only = . if building==.

gen building_8km = (tot_buildings>0 & tot_buildings!=.)
replace building_8km = 0 if dist_to_city > 8 & period < 8
replace building_8km = . if tot_buildings==.

gen building_12km = (tot_buildings>0 & tot_buildings!=.)
replace building_12km = 0 if dist_to_city > 12 & period < 8
replace building_12km = . if tot_buildings==.

gen building_15km = (tot_buildings>0 & tot_buildings!=.)
replace building_15km = 0 if dist_to_city > 15 & period < 8
replace building_15km = . if tot_buildings==.

*gen alternative state indicators without missing observations

gen is_under_city_state_map_tot_alt = is_under_city_state_map_tot
replace is_under_city_state_map_tot_alt = 0 if city_state_name_centroid=="Akshak" 

gen city_state_map_tot_cont_alt = is_under_city_state_map_tot_cont
replace city_state_map_tot_cont_alt = 0 if city_state_name_centroid=="Akshak" 

gen city_state_map_tot_new_alt = is_under_city_state_map_tot_new
replace city_state_map_tot_new_alt = 0 if city_state_name_centroid=="Akshak" 

gen building_alt = building
replace building_alt = 0 if main_study_period==1 & missing_city_sample==1

                                        *************************** BALANCE TEST OUTCOMES ******************************

xtset grid_cell_no period 

*gen panel variables

gen l_settl = l.settlement_count
gen l2_settl = l2.settlement_count

gen l_canal = l.on_canal_5000
gen l2_canal = l2.on_canal_5000

gen l_city_cell = l.city_cell
gen l2_city_cell = l2.city_cell

*gen cross-section variables

*contemporary land cover - bare areas
gen d_bare_area = (cov_code==19)

*1952 canals
gen on_canal_1952 = (D_can_1952 < 5)

                                           ************************* HETEROGENEOUS EFFECTS ********************************

* gen temporary main study period identifier
gen temporary_identifier = (period==4 | period==5 | period==6 | period==7 | period==8)

* compute settlement density, market potential and spatial lags

save intermediate_dataset.dta, replace

forvalues i=1(1)31{
preserve

keep if period==`i'
keep grid_cell_no Y X settlement_count settlement_area period tr_all_move_5000 city_cell is_under_city_state_map_tot building is_under_city_state_map_tot_new is_under_city_state_map_tot_cont

*set missing to 0 for spatial matrix computation
replace is_under_city_state_map_tot = 0 if is_under_city_state_map_tot==.
replace is_under_city_state_map_tot_new = 0 if is_under_city_state_map_tot_new==.
replace is_under_city_state_map_tot_cont = 0 if is_under_city_state_map_tot_cont==.
replace building = 0 if building==.

*gen total settled area 
gen area_settlement = settlement_area*settlement_count
replace area_settlement = 0 if area_settlement==.

* gen weighting unbounded matrix 
spmat idistance MP_weights_mat X Y, id(grid_cell_no) replace 

*create weighted treatment for autoregressive model
spmat lag treatment_SPLAG MP_weights_mat tr_all_move_5000

*create weighted states outcomes for autoregressive model
spmat lag state_tot_SPLAG MP_weights_mat is_under_city_state_map_tot
spmat lag building_SPLAG MP_weights_mat building
spmat lag state_tot_new_SPLAG MP_weights_mat is_under_city_state_map_tot_new
spmat lag state_tot_cont_SPLAG MP_weights_mat is_under_city_state_map_tot_cont

*create weighted density area
spmat lag settl_density_ha MP_weights_mat area_settlement

*keep  relevant variables
keep period grid_cell_no settl_density_ha state_tot_SPLAG building_SPLAG state_tot_new_SPLAG state_tot_cont_SPLAG treatment_SPLAG

*restore dataset and merge back
save spmat_`i'.dta, replace
restore
}

*append, save, merge back

use spmat_1.dta, clear
forvalues i=2(1)31{
append using spmat_`i'.dta
}

save spmat.dta, replace

use intermediate_dataset.dta, clear

merge 1:1 period grid_cell_no using spmat.dta
drop _merge

* gen densely settled area indicator
egen median_splag=median(settl_density_ha) if period==7 & surveyed==1
gen high_density_count_7 = (settl_density_ha>median_splag) if period==7 
bysort grid_cell_no: egen high_density_count=max(high_density_count_7) if temporary_identifier==1

*gen market potential measure
gen MP_settl_density_ha = (2*area_settlement) + settl_density_ha

* reset xtset
xtset grid_cell_no period

*compute settlement alignement

* gen X bins
xtile X_bins = X, nq(18)

* count settlements per bin for period 7
bysort X_bins: egen X_bins_count_7=total(settlement_count) if period==7

* assign to other periods
bysort grid_cell_no: egen settlement_count_ver = max(X_bins_count_7) if temporary_identifier == 1

* gen measure of mis-aligment
qui summ settlement_count_ver if period==7 & surveyed==1, detail
gen aligned_wrong = (settlement_count_ver <= `r(p50)') 

*compute productivity differences
gen suitability_diff = barley_suitability_irrigated - barley_suitability_rainfed

*median of the restricted sample for period 7
qui summ suitability_diff if period==7 & surveyed==1, detail
gen high_returns_diff = (suitability_diff > `r(p50)') 

*define primary and secondary branches
gen primary_branch_all_1=.
replace primary_branch_all_1 = 1 if ///
closest_river_all == "Euph_main" & period==8 | ///
closest_river_all == "Euph_sec" & period==8 | ///
closest_river_all == "Diyala" & period==8

replace primary_branch_all_1 = 0 if ///
closest_river_all == "Tigr_main" & period==8 | ///
closest_river_all == "Tigr_sec" & period==8

*gen water flow indicator
bysort grid_cell_no: egen high_water_flow_all = max(primary_branch_all_1) if temporary_identifier==1
gen low_water_flow = 1-high_water_flow_all

* drop temporary identifier
drop temporary_identifier

                                          ****************************RURAL-URBAN TRENDS**********************

gen city_period7 = city_cell if period==7
bysort grid_cell_no: egen period7_fixed_city_cell = max(city_period7)


                                          ****************************** CONLEY SE ****************************************


* generate Conley cut-offs

gen cutoff1 = 4.4
gen cutoff2 = 4.4

gen cutoff3 = 2.2
gen cutoff4 = 2.2

gen cutoff5 = 1.1
gen cutoff6 = 1.1

gen cutoff7 = 0.6
gen cutoff8 = 0.6

*xtset and save final panel

xtset grid_cell_no period

save panel_dataset_replication.dta, replace


                                            *************************Generate stacked panel ****************************

* we start stacking at period 5, so that 1 to 4 are pre periods

forvalues i=5(1)31{
di "Running for period `i'"

* load regular panel
use panel_dataset_replication, clear

* generate period for diff in diff centered on period `i'

gen period_orig = period

keep if period==`i'-4 | period==`i'-3 | period==`i'-2 | period==`i'-1 | period == `i'

replace period = -4 if period == `i'-4
replace period = -3 if period == `i'-3
replace period = -2 if period == `i'-2
replace period = -1 if period == `i'-1
replace period = 0 if period == `i'

gen experiment_period = `i'

gen period_lag_4 = (period==-4) 
gen period_lag_3 = (period==-3) 
gen period_lag_2 = (period==-2) 
gen period_lag_1 = (period==-1)
gen period_tr = (period==0)

*capture time invariant variables within shift episode

gen treated_one_period 			= (tr_all_move_5000>0 & period_tr == 1)
gen treated_one_period_10km     = (tr_all_move_10000>0 & period_tr == 1)
gen treated_one_period_2km     = (tr_all_move_2000>0 & period_tr == 1)
gen treated_one_period_35km     = (tr_all_move_3500>0 & period_tr == 1)
gen treated_one_period_75km     = (tr_all_move_7500>0 & period_tr == 1)

gen next_to_river_one_period 	= (sample_next_to_river>0 & period_tr == 1)
gen untreated_before_one_period	= (sample_remove_pr_tr>0 & period_tr == 1)
gen treated_closer_one_period	= (tr_all_move_close_5000>0 & period_tr == 1)

gen treatment_SPLAG_one_period = treatment_SPLAG
replace treatment_SPLAG_one_period = 0 if period_tr != 1

bysort grid_cell_no: egen treated_away=max(treated_one_period)
bysort grid_cell_no: egen treated_closer=max(treated_closer_one_period)
bysort grid_cell_no: egen treated_away_10km=max(treated_one_period_10km)
bysort grid_cell_no: egen treated_away_2km=max(treated_one_period_2km)
bysort grid_cell_no: egen treated_away_35km=max(treated_one_period_35km)
bysort grid_cell_no: egen treated_away_75km=max(treated_one_period_75km)

bysort grid_cell_no: egen treated_SPLAG=max(treatment_SPLAG_one_period)
bysort grid_cell_no: egen sample_river=max(next_to_river_one_period)
bysort grid_cell_no: egen sample_untreated_before=max(untreated_before_one_period)

*create city-status indicator for last pre-treatment period
bysort grid_cell_no: gen fixed_city_cell = city_cell if period==-1
bysort grid_cell_no: egen exp_period_fixed_city_cell = max(fixed_city_cell)

* gen time varying treatment by interacting time invariant indicator with dummies
gen period_lag_4_tr = period_lag_4 * treated_away
gen period_lag_3_tr = period_lag_3 * treated_away
gen period_lag_2_tr = period_lag_2 * treated_away
gen period_lag_1_tr = period_lag_1 * treated_away
gen period_tr_tr = period_tr * treated_away

gen period_lag_4_tr_2km = period_lag_4 * treated_away_2km
gen period_lag_3_tr_2km = period_lag_3 * treated_away_2km
gen period_lag_2_tr_2km = period_lag_2 * treated_away_2km
gen period_lag_1_tr_2km = period_lag_1 * treated_away_2km
gen period_tr_tr_2km = period_tr * treated_away_2km

gen period_lag_4_tr_35km = period_lag_4 * treated_away_35km
gen period_lag_3_tr_35km = period_lag_3 * treated_away_35km
gen period_lag_2_tr_35km = period_lag_2 * treated_away_35km
gen period_lag_1_tr_35km = period_lag_1 * treated_away_35km
gen period_tr_tr_35km = period_tr * treated_away_35km

gen period_lag_4_tr_75km = period_lag_4 * treated_away_75km
gen period_lag_3_tr_75km = period_lag_3 * treated_away_75km
gen period_lag_2_tr_75km = period_lag_2 * treated_away_75km
gen period_lag_1_tr_75km = period_lag_1 * treated_away_75km
gen period_tr_tr_75km = period_tr * treated_away_75km

gen period_lag_4_tr_10km = period_lag_4 * treated_away_10km
gen period_lag_3_tr_10km = period_lag_3 * treated_away_10km
gen period_lag_2_tr_10km = period_lag_2 * treated_away_10km
gen period_lag_1_tr_10km = period_lag_1 * treated_away_10km
gen period_tr_tr_10km = period_tr * treated_away_10km

gen period_lag_4_tr_cl = period_lag_4 * treated_closer
gen period_lag_3_tr_cl = period_lag_3 * treated_closer
gen period_lag_2_tr_cl = period_lag_2 * treated_closer
gen period_lag_1_tr_cl = period_lag_1 * treated_closer
gen period_tr_tr_cl = period_tr * treated_closer

gen period_lag_4_tr_splag = period_lag_4 * treated_SPLAG
gen period_lag_3_tr_splag = period_lag_3 * treated_SPLAG
gen period_lag_2_tr_splag = period_lag_2 * treated_SPLAG
gen period_lag_1_tr_splag = period_lag_1 * treated_SPLAG
gen period_tr_tr_splag = period_tr * treated_SPLAG

save experiment`i'.dta, replace
}


* stack individual experiments together
use experiment5.dta, clear
forvalues i=6(1)31{
append using experiment`i'.dta
}

* label treatment-period interactions
label variable period_lag_4_tr "river shift (yes/no) t-4"
label variable period_lag_3_tr "river shift (yes/no) t-3"
label variable period_lag_2_tr "river shift (yes/no) t-2"
label variable period_lag_1_tr "river shift (yes/no) t-1"

label variable period_tr_tr "river shift (yes/no)"

label variable period_lag_4_tr_cl "river shift closer (yes/no) t-4"
label variable period_lag_3_tr_cl "river shift closer (yes/no) t-3"
label variable period_lag_2_tr_cl "river shift closer (yes/no) t-2"
label variable period_lag_1_tr_cl "river shift closer (yes/no) t-1"
label variable period_tr_tr_cl "river shift closer (yes/no)"

* keep relevant variables, order and sort
keep X Y ///
grid_cell_no experiment period ///
average_rainfall ///
average_temperature ///
barley_suitability_rainfed ///
barley_suitability_irrigated ///
exp_period_fixed_city_cell ///
tr_all_move_5000 ///
treated_away ///
treated_closer ///
period_lag_4_tr ///
period_lag_3_tr ///
period_lag_2_tr ///
period_lag_1_tr ///
period_tr_tr  ///
period_lag_4_tr_2km ///
period_lag_3_tr_2km ///
period_lag_2_tr_2km ///
period_lag_1_tr_2km ///
period_tr_tr_2km  ///
period_lag_4_tr_35km ///
period_lag_3_tr_35km ///
period_lag_2_tr_35km ///
period_lag_1_tr_35km ///
period_tr_tr_35km  ///
period_lag_4_tr_75km ///
period_lag_3_tr_75km ///
period_lag_2_tr_75km ///
period_lag_1_tr_75km ///
period_tr_tr_75km  ///
period_lag_4_tr_10km ///
period_lag_3_tr_10km ///
period_lag_2_tr_10km ///
period_lag_1_tr_10km ///
period_tr_tr_10km  ///
period_lag_4_tr_cl ///
period_lag_3_tr_cl ///
period_lag_2_tr_cl ///
period_lag_1_tr_cl ///
period_tr_tr_cl  ///
MP_settl_density_ha ///
is_under_city_state_map ///
is_under_city_state_map_new ///
is_under_city_state_map_cont ///
is_under_city_state_map_tot ///
is_under_city_state_map_tot_new ///
is_under_city_state_map_tot_cont ///
is_under_city_state_map_tot_alt ///
city_state_map_tot_cont_alt ///
city_state_map_tot_new_alt ///
is_under_city_state_map_tot_8km ///
is_under_city_state_map_totN8km ///
is_under_city_state_map_totC8km ///
is_under_city_state_map_tot_12km ///
is_under_city_state_map_totN12km ///
is_under_city_state_map_totC12km ///
is_under_city_state_map_tot_15km ///
is_under_city_state_map_totN15km ///
is_under_city_state_map_totC15km ///
building ///
building_alt ///
building_admin_only ///
building_8km ///
building_12km ///
building_15km ///
tablet ///
admin_tablet ///
tax_indicator ///
tax_food_indicator ///
tax_indicator_ratio ///
canal_indicator_ratio ///
seal_indicator ///
lugal_indicator_ratio ///
gal_indicator_ratio ///
defensive_wall ///
tot_buildings ///
on_canal_5000 ///
high_returns_diff ///
low_water_flow ///
high_density_count ///
aligned_wrong ///
settlement_count ///
city_cell ///
l_settl ///
l2_settl ///
l_canal ///
l2_canal ///
l_city_cell ///
l2_city_cell ///
sample_untreated_before ///
surveyed ///
dataset_int ///
sample_river ///
cutoff1 ///
cutoff2 ///
cutoff3 ///
cutoff4 ///
cutoff5 ///
cutoff6 ///
cutoff7 ///
cutoff8 ///
period7_fixed_city_cell ///
exp_period_fixed_city_cell ///
FID_10km ///
high_survey_quality ///
state_tot_SPLAG ///
building_SPLAG ///
state_tot_new_SPLAG ///
state_tot_cont_SPLAG ///
treated_SPLAG ///
period_lag_4_tr_splag ///
period_lag_3_tr_splag ///
period_lag_2_tr_splag ///
period_lag_1_tr_splag ///
period_tr_tr_splag ///
nearest_city_ID ///
distance_to_river_all ///
not_excavated_indicator



order X Y ///
grid_cell_no experiment period ///
period_lag_4_tr ///
period_lag_3_tr ///
period_lag_2_tr ///
period_lag_1_tr ///
period_tr_tr  ///
period_lag_4_tr_2km ///
period_lag_3_tr_2km ///
period_lag_2_tr_2km ///
period_lag_1_tr_2km ///
period_tr_tr_2km  ///
period_lag_4_tr_35km ///
period_lag_3_tr_35km ///
period_lag_2_tr_35km ///
period_lag_1_tr_35km ///
period_tr_tr_35km  ///
period_lag_4_tr_75km ///
period_lag_3_tr_75km ///
period_lag_2_tr_75km ///
period_lag_1_tr_75km ///
period_tr_tr_75km  ///
period_lag_4_tr_10km ///
period_lag_3_tr_10km ///
period_lag_2_tr_10km ///
period_lag_1_tr_10km ///
period_tr_tr_10km  ///
period_lag_4_tr_cl ///
period_lag_3_tr_cl ///
period_lag_2_tr_cl ///
period_lag_1_tr_cl ///
period_tr_tr_cl  ///
sample_untreated_before ///
surveyed ///
dataset_int ///
sample_river ///
cutoff1 ///
cutoff2 ///
cutoff3 ///
cutoff4 ///
cutoff5 ///
cutoff6 ///
cutoff7 ///
cutoff8 ///
period7_fixed_city_cell ///
average_rainfall ///
average_temperature ///
barley_suitability_rainfed ///
barley_suitability_irrigated ///
exp_period_fixed_city_cell ///
city_cell ///
l_settl ///
l2_settl ///
l_city_cell ///
l2_city_cell ///
l_canal ///
l2_canal ///
is_under_city_state_map ///
is_under_city_state_map_new ///
is_under_city_state_map_cont ///
is_under_city_state_map_tot ///
is_under_city_state_map_tot_new ///
is_under_city_state_map_tot_cont ///
is_under_city_state_map_tot_12km ///
is_under_city_state_map_totN12km ///
is_under_city_state_map_totC12km ///
building ///
building_8km ///
building_12km ///
building_15km ///
on_canal_5000 ///
defensive_wall ///
tablet ///
tot_buildings ///
high_returns_diff ///
low_water_flow ///
high_density_count ///
aligned_wrong ///
admin_tablet ///
tax_indicator ///
tax_indicator_ratio ///
canal_indicator_ratio ///
FID_10km ///
nearest_city_ID ///
tr_all_move_5000 ///
treated_away ///
treated_closer ///
distance_to_river_all ///
not_excavated_indicator ///
state_tot_SPLAG ///
building_SPLAG ///
state_tot_new_SPLAG ///
state_tot_cont_SPLAG ///
treated_SPLAG ///
period_lag_4_tr_splag ///
period_lag_3_tr_splag ///
period_lag_2_tr_splag ///
period_lag_1_tr_splag ///
period_tr_tr_splag

sort experiment_period period grid_cell_no

************************************ SAVE ****************************
save panel_dataset_stacked_replication.dta, replace

