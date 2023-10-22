*Generate person-year level dataset, which tracks RX outcomes as a year-quarter level panel, relative to the person-year listed (in terms of quarters pre and quarters post, as in event study design)

*Source data: Cms Medicare Part D Event file (see more info here: https://resdac.org/cms-data/files/pde)

*RX outcomes tracked include utilization, spend-broken down by nonstandardized/standardized, chronic/nonchornic, and high value/low value

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/utilization_pde_monthly/output/utilization.dta", clear
keep year
duplicates drop year, force
gen t = 1
save"/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/temp/yr_list.dta", replace

*Create panel across years of sample period, for every single person in our main sample

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneid_list.dta", clear
gen t= 1
joinby t using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/temp/yr_list.dta"
drop t
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/temp/beneidyr_list.dta", replace


*Open RX utilizaiton file, and restrict just to individuals in our sample.
*Generate panel tracking RX utilization and general spend

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/utilization_pde_monthly/output/utilization.dta", clear

merge m:1 bene_id using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneid_list.dta", keep(3) nogen

gen qtr = .
replace qtr = 9 if month <= 3
replace qtr = 10 if month > 3 & month <= 6
replace qtr = 11 if month > 6 & month <= 9
replace qtr = 12 if month > 9

*Roll upon main RX utilization outcomes to person-year-quarter level

collapse (sum) pde_spend number_of_prescriptions days_supply, by(bene_id qtr year)

*Reshape dataset to person-year level, with outcomes for individual quarters tracked as separate columns

reshape wide pde_spend number_of_prescriptions days_supply, i(bene_id year) j(qtr)

merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/temp/beneidyr_list.dta", keep(2 3)

foreach x of varlist pde_spend* number_of_prescriptions* days_supply* {
replace `x' = 0 if `x' == .
}

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/output/util_qtr.dta", replace


*Create panel of RX outcomes dealing with high vs low value
use "/disk/agedisk3/medicare.work/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/output/ptd_LIS65_20pct_samp_pde_qtr.dta", clear

merge m:1 bene_id using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneid_list.dta", keep(3) nogen

gen dq = dofq(srvc_qtr)
gen year = year(dq)
gen qtr = quarter(dq)

replace qtr = 9 if qtr == 1
replace qtr = 10 if qtr == 2
replace qtr = 11 if qtr == 3
replace qtr = 12 if qtr == 4
drop srvc_qtr dq ref_year
reshape wide pde_spend_lowbene num_pres_lowbene days_supply_lowbene pde_spend_hibene num_pres_hibene days_supply_hibene, i(bene_id year) j(qtr)

merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/temp/beneidyr_list.dta", keep(2 3)

foreach x of varlist pde_spend_lowbene* num_pres_lowbene* days_supply_lowbene* pde_spend_hibene* num_pres_hibene* days_supply_hibene* {
replace `x' = 0 if `x' == .
}

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/output/util_qtr_high.dta", replace

*Generate panel tracking RX spend that is price standardized at various levels (class level, plan level, class-generic level)

use "/disk/agedisk3/medicare.work/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/output/opt1pde_2007_2015_standard_spend_gen_by_year.dta", clear

merge m:1 bene_id using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneid_list.dta", keep(3) nogen

gen dq = dofq(srvc_qtr)
gen year = year(dq)
gen qtr = quarter(dq)

replace qtr = 9 if qtr == 1
replace qtr = 10 if qtr == 2
replace qtr = 11 if qtr == 3
replace qtr = 12 if qtr == 4
drop srvc_qtr dq
reshape wide standardizedplanspend standardizedclassspend standardclassgenspend, i(bene_id year) j(qtr)

merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/temp/beneidyr_list.dta", keep(2 3)

foreach x of varlist standardized* standardclass* {
replace `x' = 0 if `x' == .
}
drop _merge 
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/output/util_qtr_stand.dta", replace


use "/disk/agedisk3/medicare.work/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/output/opt1pde_spending_by_chronic.dta", clear

merge m:1 bene_id using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneid_list.dta", keep(3) nogen

gen dq = dofq(srvc_qtr)
gen year = year(dq)
gen qtr = quarter(dq)

replace qtr = 9 if qtr == 1
replace qtr = 10 if qtr == 2
replace qtr = 11 if qtr == 3
replace qtr = 12 if qtr == 4
drop srvc_qtr dq

reshape wide chronicspend nonchronicspend, i(bene_id year) j(qtr)

merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/temp/beneidyr_list.dta", keep(2 3)

foreach x of varlist chronicspend* nonchronicspend* {
replace `x' = 0 if `x' == .
}
drop _merge
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/output/util_qtr_chron.dta", replace
***

*Merge all the different RX outcome panels together into a single file trackng all the different outcomes-by quarter across columns-where each row is at a bene-year level
use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/output/util_qtr.dta", clear

drop _merge
merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/output/util_qtr_high.dta"

drop _merge 
merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/output/util_qtr_stand.dta"

drop _merge

merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/output/util_qtr_chron.dta"

drop _merge

foreach x of varlist pde_spend* number_of_prescriptions* days_supply* standardized* pde_spend_lowbene* num_pres_lowbene* days_supply_lowbene* pde_spend_hibene* num_pres_hibene* days_supply_hibene* standardclass* chronicspend* nonchronicspend* {
replace `x' = 0 if `x' == .
}

sort bene_id year
foreach x in pde_spend number_of_prescriptions days_supply standardizedplanspend standardizedclassspend pde_spend_lowbene num_pres_lowbene days_supply_lowbene pde_spend_hibene num_pres_hibene days_supply_hibene chronicspend nonchronicspend standardclassgenspend {
qby bene_id: gen `x'13 = `x'9[_n+1] if year[_n+1] == year+1
qby bene_id: gen `x'14 = `x'10[_n+1] if year[_n+1] == year+1
qby bene_id: gen `x'15 = `x'11[_n+1] if year[_n+1] == year+1
qby bene_id: gen `x'16 = `x'12[_n+1] if year[_n+1] == year+1

qby bene_id: gen `x'5 = `x'9[_n-1] if year[_n-1] == year-1
qby bene_id: gen `x'6 = `x'10[_n-1] if year[_n-1] == year-1
qby bene_id: gen `x'7 = `x'11[_n-1] if year[_n-1] == year-1
qby bene_id: gen `x'8 = `x'12[_n-1] if year[_n-1] == year-1

qby bene_id: gen `x'1 = `x'9[_n-2] if year[_n-2] == year-2
qby bene_id: gen `x'2 = `x'10[_n-2] if year[_n-2] == year-2
qby bene_id: gen `x'3 = `x'11[_n-2] if year[_n-2] == year-2
qby bene_id: gen `x'4 = `x'12[_n-2] if year[_n-2] == year-2
}

foreach x of varlist pde_spend* number_of_prescriptions* days_supply* standardized* pde_spend_lowbene* num_pres_lowbene* days_supply_lowbene* pde_spend_hibene* num_pres_hibene* days_supply_hibene* chronicspend* nonchronicspend* standard* {
qui replace `x' = 0 if `x' == .
}

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/output/util_qtr_pan.dta", replace
