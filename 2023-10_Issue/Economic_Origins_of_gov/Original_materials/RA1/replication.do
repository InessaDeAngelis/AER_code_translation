clear all

* load data
use "RA1/dataset.dta"

*** set globals

* treatment 
global shift_treatment  "tr_all_move_5000"

*********** replicate regression and generate standard errors ******************

eststo clear

*canals 1952
eststo: reg on_canal_1952 $shift_treatment, robust
$add_y

*cultivation 2010
eststo: reg d_bare_area $shift_treatment, robust
$add_y

*excavated nearest city
eststo: reg not_excavated_indicator $shift_treatment, robust
$add_y

esttab  using "$project_output_path\RA1.tex", ///
b(2) se(2) se ///
keep(tr_all_move_5000) nonumber label ///
stats(ymean N, fmt(2 0)labels("Mean dep. var." "Observations")) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) nolines nomtitles nonumbers fragment  replace
