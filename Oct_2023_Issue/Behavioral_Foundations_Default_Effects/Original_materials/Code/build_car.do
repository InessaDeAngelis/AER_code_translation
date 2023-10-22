*Purpose: Generate person-year level dataset, which tracks professional services spend as a year-quarter level panel, relative to the person-year listed (in terms of quarters pre and quarters post, as in event study design)

*Source data used: CMS Medicare Carrier files-https://www2.ccwdata.org/web/guest/data-dictionaries

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/utilization_car_monthly/output/utilization.dta"

merge m:1 bene_id using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneid_list.dta", keep(3) nogen

gen qtr = .
replace qtr = 9 if month <= 3
replace qtr = 10 if month > 3 & month <= 6
replace qtr = 11 if month > 6 & month <= 9
replace qtr = 12 if month > 9

collapse (sum) car_spend, by(bene_id qtr year)

reshape wide car_spend, i(bene_id year) j(qtr)

merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/temp/beneidyr_list.dta", keep(2 3)

foreach x of varlist car_spend* {
replace `x' = 0 if `x' == .
}

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_car_rdsamp/output/util_qtr.dta", replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_car_rdsamp/output/util_qtr.dta", clear
sort bene_id year
qby bene_id: gen car_spend13 = car_spend9[_n+1] if year[_n+1] == year+1
qby bene_id: gen car_spend14 = car_spend10[_n+1] if year[_n+1] == year+1
qby bene_id: gen car_spend15 = car_spend11[_n+1] if year[_n+1] == year+1
qby bene_id: gen car_spend16 = car_spend12[_n+1] if year[_n+1] == year+1

qby bene_id: gen car_spend5 = car_spend9[_n-1] if year[_n-1] == year-1
qby bene_id: gen car_spend6 = car_spend10[_n-1] if year[_n-1] == year-1
qby bene_id: gen car_spend7 = car_spend11[_n-1] if year[_n-1] == year-1
qby bene_id: gen car_spend8 = car_spend12[_n-1] if year[_n-1] == year-1

qby bene_id: gen car_spend1 = car_spend9[_n-2] if year[_n-2] == year-2
qby bene_id: gen car_spend2 = car_spend10[_n-2] if year[_n-2] == year-2
qby bene_id: gen car_spend3 = car_spend11[_n-2] if year[_n-2] == year-2
qby bene_id: gen car_spend4 = car_spend12[_n-2] if year[_n-2] == year-2

foreach x of varlist car_spend* {
replace `x' = 0 if `x' == .
}

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_car_rdsamp/output/util_qtr_pan.dta", replace


