*Figures A27, A28, A29, A30

*This do file plots the main event study graphs of the effects of change in default on active choice status and outcome variables (with 2 year post period)
*Final products: 
*rd_event_study_plot_pde_spendlog_balance_2yr_post.eps;
*rd_event_study_plot_pde_spendlog_by_fit_balance_2yr_post.eps;
*rd_event_study_plot_switch_from_Dec_by_fit_balance_2yr_post.eps;
*rd_event_study_plot_type_actv_ind_by_fit_balance_2yr_post.eps

*for testing code interactively
cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/submission/code/"

adopath + ../../../../lib/ado/

cap log close
log using "../output/rd_event_study_2yr_post_fig_a20_a21_a22_a23.log", replace

******
*Event study graphs

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_eventreshaped_ref_v2.dta", clear
cap drop _merge

*Update active choice indicators and keep balanced panel
tab type_actv_ind_new type_actv_ind_Dec
replace type_actv_ind_Dec = type_actv_ind_new
tab type_actv_ind_new type_actv_ind_Dec

merge m:1 bene_id year using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/enrollment_data/output/balanced_list"

keep if _merge == 3

keep if keepforlongterm == 1

*Drop de minimis plans
sum running, det
tab running if (running >= -0.5 & running <= 2.5) & year >= 2011
drop if (running > 0 & running < 2.05) & year >= 2011

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/behavioral/output/RD_AnalysisFileApr2020_eventreshaped_ref_v2_balance_2yr_post.dta", replace

eststo clear

*Create relative time indicators for event study regression and plotting 

label variable indicator1 "T-8"
label variable indicator2 "T-7"
label variable indicator3 "T-6"
label variable indicator4 "T-5"
label variable indicator5 "T-4"
label variable indicator6 "T-3"
label variable indicator7 "T-2"
label variable indicator9 "T"
label variable indicator10 "T+1"
label variable indicator11 "T+2"
label variable indicator12 "T+3"
label variable indicator13 "T+4"
label variable indicator14 "T+5"
label variable indicator15 "T+6"
label variable indicator16 "T+7"

label variable ybinary1 "T-8"
label variable ybinary2 "T-7"
label variable ybinary3 "T-6"
label variable ybinary4 "T-5"
label variable ybinary5 "T-4"
label variable ybinary6 "T-3"
label variable ybinary7 "T-2"
label variable ybinary9 "T"
label variable ybinary10 "T+1"
label variable ybinary11 "T+2"
label variable ybinary12 "T+3"
label variable ybinary13 "T+4"
label variable ybinary14 "T+5"
label variable ybinary15 "T+6"
label variable ybinary16 "T+7"

label variable xbinaryfit1 "T-8"
label variable xbinaryfit2 "T-7"
label variable xbinaryfit3 "T-6"
label variable xbinaryfit4 "T-5"
label variable xbinaryfit5 "T-4"
label variable xbinaryfit6 "T-3"
label variable xbinaryfit7 "T-2"
label variable xbinaryfit9 "T"
label variable xbinaryfit10 "T+1"
label variable xbinaryfit11 "T+2"
label variable xbinaryfit12 "T+3"
label variable xbinaryfit13 "T+4"
label variable xbinaryfit14 "T+5"
label variable xbinaryfit15 "T+6"
label variable xbinaryfit16 "T+7"

gen placeholder = 0
label variable placeholder "T-1"

forval n=1/16 {
gen xbinaryhighfit`n' = binary*(1-newfit_unif)*indicator`n'
}

drop xbinaryhighfit8

label variable xbinaryhighfit1 "T-8"
label variable xbinaryhighfit2 "T-7"
label variable xbinaryhighfit3 "T-6"
label variable xbinaryhighfit4 "T-5"
label variable xbinaryhighfit5 "T-4"
label variable xbinaryhighfit6 "T-3"
label variable xbinaryhighfit7 "T-2"
label variable xbinaryhighfit9 "T"
label variable xbinaryhighfit10 "T+1"
label variable xbinaryhighfit11 "T+2"
label variable xbinaryhighfit12 "T+3"
label variable xbinaryhighfit13 "T+4"
label variable xbinaryhighfit14 "T+5"
label variable xbinaryhighfit15 "T+6"
label variable xbinaryhighfit16 "T+7"

forval n=1/16 {
gen ebinarylowfit`n' = binary*(1-elix_bin)*indicator`n'
}

drop ebinarylowfit8

label variable ebinaryfit1 "T-8"
label variable ebinaryfit2 "T-7"
label variable ebinaryfit3 "T-6"
label variable ebinaryfit4 "T-5"
label variable ebinaryfit5 "T-4"
label variable ebinaryfit6 "T-3"
label variable ebinaryfit7 "T-2"
label variable ebinaryfit9 "T"
label variable ebinaryfit10 "T+1"
label variable ebinaryfit11 "T+2"
label variable ebinaryfit12 "T+3"
label variable ebinaryfit13 "T+4"
label variable ebinaryfit14 "T+5"
label variable ebinaryfit15 "T+6"
label variable ebinaryfit16 "T+7"

label variable ebinarylowfit1 "T-8"
label variable ebinarylowfit2 "T-7"
label variable ebinarylowfit3 "T-6"
label variable ebinarylowfit4 "T-5"
label variable ebinarylowfit5 "T-4"
label variable ebinarylowfit6 "T-3"
label variable ebinarylowfit7 "T-2"
label variable ebinarylowfit9 "T"
label variable ebinarylowfit10 "T+1"
label variable ebinarylowfit11 "T+2"
label variable ebinarylowfit12 "T+3"
label variable ebinarylowfit13 "T+4"
label variable ebinarylowfit14 "T+5"
label variable ebinarylowfit15 "T+6"
label variable ebinarylowfit16 "T+7"

*Clean up and relabel variables

rename number_of_prescriptions num_pres
rename number_of_prescriptionslog num_preslog


******
*Event study overall

*Figure A27
foreach x in pde_spendlog {

	reghdfe `x' ybinary1 ybinary2 ybinary3 ybinary4 ybinary5 ybinary6 ybinary7 placeholder ybinary9 ybinary10 ybinary11 ybinary12 ybinary13 ybinary14 ybinary15 ybinary16 if type_actv_ind_Dec == 0 & running < 6 & running > -6, absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id)
	eststo rd_`x'
	coefplot rd_`x', keep(ybinary1 ybinary2 ybinary3 ybinary4 ybinary5 ybinary6 ybinary7 placeholder ybinary9 ybinary10 ybinary11 ybinary12 ybinary13 ybinary14 ybinary15 ybinary16) vertical omitted label xline(8.5, lpattern(dash)) graphregion(color(white)) title("`x'") xtitle("Quarter")
	graph export "../output/graphs/rd_event_study_plot_`x'_balance_2yr_post.eps", replace
	

}


******
*Event study by fit 

*Figure A28
foreach x in pde_spendlog {

	reghdfe `x' xbinaryfit1 xbinaryhighfit1 xbinaryfit2 xbinaryhighfit2 xbinaryfit3 xbinaryhighfit3 xbinaryfit4 xbinaryhighfit4 xbinaryfit5 xbinaryhighfit5 xbinaryfit6 xbinaryhighfit6 xbinaryfit7 xbinaryhighfit7 placeholder placeholder xbinaryfit9 xbinaryhighfit9 xbinaryfit10 xbinaryhighfit10 xbinaryfit11 xbinaryhighfit11 xbinaryfit12 xbinaryhighfit12 xbinaryfit13 xbinaryhighfit13 xbinaryfit14 xbinaryhighfit14 xbinaryfit15 xbinaryhighfit15 xbinaryfit16 xbinaryhighfit16 if type_actv_ind_Dec == 0 & running < 6 & running > -6, absorb(bene_id_ex region_code_year event_time) vce(cluster bene_id) nocons
	
	eststo fit_`x'
	
	coefplot (fit_`x', keep(xbinaryfit1 xbinaryfit2 xbinaryfit3 xbinaryfit4 xbinaryfit5 xbinaryfit6 xbinaryfit7 placeholder xbinaryfit9 xbinaryfit10 xbinaryfit11 xbinaryfit12 xbinaryfit13 xbinaryfit14 xbinaryfit15 xbinaryfit16) label(Low Fit Quintile) msymbol(O) offset(-0.05)) (fit_`x', keep(xbinaryhighfit1 xbinaryhighfit2 xbinaryhighfit3 xbinaryhighfit4 xbinaryhighfit5 xbinaryhighfit6 xbinaryhighfit7 placeholder xbinaryhighfit9 xbinaryhighfit10 xbinaryhighfit11 xbinaryhighfit12 xbinaryhighfit13 xbinaryhighfit14 xbinaryhighfit15 xbinaryhighfit16) label(High Fit Quintile) msymbol(T) offset(0.05)), rename(xbinaryhighfit1=xbinaryfit1 xbinaryhighfit2=xbinaryfit2 xbinaryhighfit3=xbinaryfit3 xbinaryhighfit4=xbinaryfit4 xbinaryhighfit5=xbinaryfit5 xbinaryhighfit6=xbinaryfit6 xbinaryhighfit7=xbinaryfit7 xbinaryhighfit9=xbinaryfit9 xbinaryhighfit10=xbinaryfit10 xbinaryhighfit11=xbinaryfit11 xbinaryhighfit12=xbinaryfit12 xbinaryhighfit13=xbinaryfit13 xbinaryhighfit14=xbinaryfit14 xbinaryhighfit15=xbinaryfit15 xbinaryhighfit16=xbinaryfit16) vertical omitted label xline(8.5, lpattern(dash)) graphregion(color(white)) title("`x'") xtitle("Quarter")
	
	graph export "../output/graphs/rd_event_study_plot_`x'_by_fit_balance_2yr_post.eps", replace

}

*Figures A29, A30
foreach x in switch_from_Dec type_actv_ind {

	reghdfe `x' placeholder placeholder xbinaryfit9 xbinaryhighfit9 xbinaryfit10 xbinaryhighfit10 xbinaryfit11 xbinaryhighfit11 xbinaryfit12 xbinaryhighfit12 xbinaryfit13 xbinaryhighfit13 xbinaryfit14 xbinaryhighfit14 xbinaryfit15 xbinaryhighfit15 xbinaryfit16 xbinaryhighfit16 i.region_code_year if type_actv_ind_Dec == 0 & running < 6 & running > -6 & new >= 8, absorb(event_time) vce(cluster bene_id) nocons

	eststo fit_`x'
	
	coefplot (fit_`x', keep(placeholder xbinaryfit9 xbinaryfit10 xbinaryfit11 xbinaryfit12 xbinaryfit13 xbinaryfit14 xbinaryfit15 xbinaryfit16) label(Low Fit Quintile) msymbol(O) offset(-0.05)) (fit_`x', keep(placeholder xbinaryhighfit9 xbinaryhighfit10 xbinaryhighfit11 xbinaryhighfit12 xbinaryhighfit13 xbinaryhighfit14 xbinaryhighfit15 xbinaryhighfit16) label(High Fit Quintile) msymbol(T) offset(0.05)), rename(xbinaryhighfit9=xbinaryfit9 xbinaryhighfit10=xbinaryfit10 xbinaryhighfit11=xbinaryfit11 xbinaryhighfit12=xbinaryfit12 xbinaryhighfit13=xbinaryfit13 xbinaryhighfit14=xbinaryfit14 xbinaryhighfit15=xbinaryfit15 xbinaryhighfit16=xbinaryfit16) vertical omitted label xline(1.5, lpattern(dash)) graphregion(color(white)) title("`x'") xtitle("Quarter") ylab(0(0.2)1)

	graph export "../output/graphs/rd_event_study_plot_`x'_by_fit_balance_2yr_post.eps", replace

}

log close
