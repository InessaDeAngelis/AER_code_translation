*Generate person-year level dataset, which tracks inpatient & SNF combined spend as a year-quarter level panel, relative to the person-year listed (in terms of quarters pre and quarters post, as in event study design)

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/utilization_med_monthly/output/utilization.dta", clear

merge m:1 bene_id using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneid_list.dta", keep(3) nogen

gen qtr = .
replace qtr = 9 if month <= 3
replace qtr = 10 if month > 3 & month <= 6
replace qtr = 11 if month > 6 & month <= 9
replace qtr = 12 if month > 9

collapse (sum) med_spend, by(bene_id qtr year)

reshape wide med_spend, i(bene_id year) j(qtr)

merge 1:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_rx_rdsamp/temp/beneidyr_list.dta", keep(2 3)

foreach x of varlist med_spend* {
replace `x' = 0 if `x' == .
}

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_medpar_rdsamp/output/util_qtr.dta", replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_medpar_rdsamp/output/util_qtr.dta", clear
sort bene_id year
qby bene_id: gen med_spend13 = med_spend9[_n+1] if year[_n+1] == year+1
qby bene_id: gen med_spend14 = med_spend10[_n+1] if year[_n+1] == year+1
qby bene_id: gen med_spend15 = med_spend11[_n+1] if year[_n+1] == year+1
qby bene_id: gen med_spend16 = med_spend12[_n+1] if year[_n+1] == year+1

qby bene_id: gen med_spend5 = med_spend9[_n-1] if year[_n-1] == year-1
qby bene_id: gen med_spend6 = med_spend10[_n-1] if year[_n-1] == year-1
qby bene_id: gen med_spend7 = med_spend11[_n-1] if year[_n-1] == year-1
qby bene_id: gen med_spend8 = med_spend12[_n-1] if year[_n-1] == year-1

qby bene_id: gen med_spend1 = med_spend9[_n-2] if year[_n-2] == year-2
qby bene_id: gen med_spend2 = med_spend10[_n-2] if year[_n-2] == year-2
qby bene_id: gen med_spend3 = med_spend11[_n-2] if year[_n-2] == year-2
qby bene_id: gen med_spend4 = med_spend12[_n-2] if year[_n-2] == year-2

foreach x of varlist med_spend* {
replace `x' = 0 if `x' == .
}

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/util_medpar_rdsamp/output/util_qtr_pan.dta", replace
