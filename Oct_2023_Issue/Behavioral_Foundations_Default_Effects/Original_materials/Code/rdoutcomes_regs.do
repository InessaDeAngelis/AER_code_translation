
*Prep for event study regressions: construct different variables needed for event study regressions

************************************************************


use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_eventreshaped.dta", clear

forval n=1/16 {
gen indicator`n' = new == `n'
}

forval n=1/16 {
gen ybinary`n' =binary*indicator`n'
}

*Adjust prescperc/perc masures down appropriately, to have minimum at 'zero'
replace prescperc = prescperc-(1/obs)
replace perc = perc-(1/obs)
drop presc_lowerquintile
gen presc_lowerquintile = prescperc<= .2
drop spend_lowerquintile
gen spend_lowerquintile = perc <= .2

forval n=1/16 {
gen assign`n' = presc_lowerquintile*indicator`n'
}


set seed 1
gen ui1 = runiform()
gen fake_fit = ui1 < .2
gen newfit_unif = presc_lowerquintile
replace newfit_unif = fake_fit if prescperc == .

gen spendnewfit_unif = spend_lowerquintile
replace spendnewfit_unif = fake_fit if perc == .

*Merge in newfit_unif

forval n=1/16 {
gen xbinaryfit`n' = binary*newfit_unif*indicator`n'
}

forval n=1/16 {
gen spendxbinaryfit`n' = binary*spendnewfit_unif*indicator`n'
}

forval n=1/16 {
gen zfit`n' = newfit_unif*indicator`n'
}

drop ybinary8 xbinaryfit8 spendxbinaryfit8
drop ref_year
rename year ref_year 
cap drop _merge

*Merge in additional enrollment panel variables (to track at quarterly level), post event
merge 1:1 ref_year bene_id new using "/disk/agedisk3/medicare.work/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/temp/enroll_panel_final.dta", keep(1 3)
rename ref_year year
replace switch_from_Dec = 0 if new == 8
replace type_actv_ind = type_actv_ind_Dec if new == 8
replace switch_from_Jan = 0 if new == 8
*compress

gen elix_bin = elixsum >= 6
gen presc_bin = prescfit_median_m >= .2
gen presc_bin_v2 = costfit_median_m >= .2

forval n=1/16 {
gen elix_time`n' = elix_bin*indicator`n'
}


forval n=1/16 {
gen ebinaryfit`n' = binary*elix_bin*indicator`n'
}

forval n=1/16 {
gen pbinaryfit`n' = binary*presc_bin*indicator`n'
}

forval n=1/16 {
gen p2binaryfit`n' = binary*presc_bin_v2*indicator`n'
}

drop ebinaryfit8 pbinaryfit8 p2binaryfit8
drop elix_time8
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_eventreshaped_ref.dta", replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_eventreshaped_ref.dta", clear
keep bene_id year prescfit
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/presc_fit_file.dta", replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_eventreshaped_ref.dta", clear

gen qtr = .
replace qtr = 1 if new == 1 | new == 5 | new == 9 | new == 13
replace qtr = 2 if new == 2 | new == 6 | new == 10 | new == 14
replace qtr = 3 if new == 3 | new == 7 | new == 11 | new == 15
replace qtr = 4 if new == 4 | new == 8 | new == 12 | new == 16

gen yrnew = year 
replace yrnew = year+1 if new >= 13
replace yrnew = year-1 if new < 9 & new >= 5
replace yrnew = year-2 if new < 5 & new >= 1

drop if year == 2015

drop region_code_year 

*Experiment level
egen region_code_year = group(region_code year)
egen bene_id_ex = group(bene_id region_code_year)

*Regular quarter year
egen qtr_yr = group(yrnew qtr)

*Within experiment indicator
egen event_time = group(region_code_year new)
sort contract_id plan_id

cap drop _merge
merge m:1 contract_id plan_id region_code year using"/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/PlansRunningPrem_yr_assigned.dta", keep(1 3)

cap drop _merge
merge m:1 contract_id_Dec plan_id_Dec region_code year using"/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/PlansRunningPrem_2year.dta", keep(1 3)

*contract_id_Dec plan_id_Dec
gen keepforlongterm = (binary == 1 & lose_benchmarkassigned == 0) | (binary == 0 & not_losebenchmark2 == 1)

*replace type_actv_ind = 1 if new > 8 & switch == 0 & binary == 1 & type_actv_ind_Dec == 0 & type_actv_ind ~= .
**Exclude people with miscoded active choice status
drop if ListtoDrop == 3

*Merge in 
cap drop _merge
merge m:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/newactvind.dta", keep (1 3)

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_eventreshaped_ref_v2.dta", replace
