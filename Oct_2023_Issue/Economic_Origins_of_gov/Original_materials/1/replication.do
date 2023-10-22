*Table 1

* group 1: main study period
use "1\dataset_A.dta", clear

eststo clear
eststo: estpost summ ///
treated_away ///
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

esttab using "$project_output_path\1a.tex", nonumber label cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") replace


* group 2: extended study period
use "1\dataset_B.dta", clear

eststo clear
eststo: estpost summ ///
tr_all_move_5000 ///
on_canal_5000

esttab using "$project_output_path\1b.tex", nonumber label cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") replace


* group 3: cross-sectional data
use "1\dataset_C.dta", clear

eststo clear
eststo: estpost summ ///
average_rainfall ///
average_temperature ///
period7_fixed_city_cell ///
high_returns_diff ///
low_water_flow ///
high_density_count ///
aligned_wrong ///
surveyed

esttab using "$project_output_path\1c.tex", nonumber label cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") replace
