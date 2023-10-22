clear all

* load data
use "RA2/dataset.dta"

*** set globals

* treatment 
global shift_treatment  "tr_all_move_5000"

*********** replicate regression and generate standard errors ******************

eststo clear

*average_rainfall
eststo: reg average_rainfall $shift_treatment, robust
$add_y

*average_temperature
eststo: reg average_temperature $shift_treatment, robust
$add_y

*barley_suitability_irrigated
eststo: reg suitability_diff $shift_treatment, robust
$add_y

esttab  using "$project_output_path\RA2.tex", ///
b(2) se(2) se ///
keep(tr_all_move_5000) nonumber label ///
stats(ymean N, fmt(2 0)labels("Mean dep. var." "Observations")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace
