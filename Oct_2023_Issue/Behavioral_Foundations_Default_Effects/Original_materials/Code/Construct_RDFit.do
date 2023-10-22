
*Purpose: Generate within-person fit measures (price and non-price weighted)
*Across universe of benchmark plans person could be re-assigned to
*For a given bene-yr combo

*Additionally, construct variables on raw (absolute) spread between best and worst fitting plans
*for a given person-year combo

**Specify beneficiary sample for which fit measure will actually get generated
use "/disk/agedisk3/medicare.work/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/output/ptd_LIS65_samp.dta", clear
keep if in_20pct == 1
duplicates drop bene_id, force
keep bene_id
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneid_list.dta", replace

*Pull region codes by person year, to later merge into data
use "/disk/agedisk3/medicare.work/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/output/ptd_LIS65_samp.dta", clear
keep if in_20pct == 1
keep bene_id ref_year region_code
rename ref_year yr
duplicates drop bene_id yr, force
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/regioncodes.dta", replace

**Generate unique set of NDC 9's taken by each person in the selected subsample, for each year
forval yr = 2007/2014 {
use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pde/opt1pde`yr'.dta"

merge m:1 bene_id using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneid_list.dta", keep(3) nogen
gen ndc9 = substr(prdsrvid, 1, 9)
keep bene_id ndc9
duplicates drop bene_id ndc9, force

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/uniqdrugs`yr'.dta", replace

}

*Generate list of benchmark plans, which we will later limit these analyses to
*Revision: Do this just for the incumbent plan
use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/CombinedFormAll_Sept2019.dta", clear
duplicates drop contract_id plan_id region_code yr, force
keep contract_id plan_id region_code yr
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/uniqplnlst.dta", replace

*Generate unique set of NDC 9's covered in each plan formulary
*Pull in formulary data with NON-benchmark plans
use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/CombinedFormAll_Sept2019.dta", clear
keep yr contract_id plan_id segment_id ndc region_code
gen ndc9 = substr(ndc, 1, 9)
duplicates drop yr contract_id plan_id segment_id region_code ndc9, force
duplicates drop yr contract_id plan_id region_code ndc9, force
drop segment_id
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/formularyforuse.dta", replace 
*Generate unique set of NDC9's covered by ANY plan formulary over our sample period
duplicates drop ndc9, force
keep ndc9
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/formularyforusetest2.dta", replace

*Take unique set of NDC9's taken by each bene per year
*Pull in each patient's region code of residence
*Then, make separate copy of every person-drug-year record, for EVERY benchmark plan
*Appearing in their region for that year
forval yr = 2007/2014 {
use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/uniqdrugs`yr'.dta", clear
gen yr = `yr'
merge m:1 bene_id yr using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/regioncodes.dta", keep (3) nogen

replace yr = yr+1
joinby region_code yr using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/uniqplnlst.dta"

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/uniqdrugsplanuniv`yr'.dta", replace
}

forval yr = 2007/2014 {
use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/uniqdrugsplanuniv`yr'.dta", clear
*Restrict just to Medicare-covered drugs (covered by at least one formulary across all years in samp period)
merge m:1 ndc9 using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/formularyforusetest2.dta", keep(3) nogen
*Merge each possible person-drug-plan-year combo (set of ex-ante drugs person was taking, crossed with the set of benchmark plans in their region in year t+1), with the drug formulary status in 
*that corresponding plan
merge m:1 yr contract_id plan_id region_code ndc9 using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/formularyforuse.dta", keep(1 3)
gen on_formulary = _merge == 3
drop ndc

*Merge in drug-year level average drug price information
replace yr = yr-1
drop _merge
merge m:1 yr ndc9 using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/pardpriceallyrs.dta", keep(3)

gen t = 1
**Generate total cost of each beneficiary's ex-ante basket of drugs, for each year
*Also calculate number of drugs in each ex-ante basket
sort bene_id contract_id plan_id region_code yr
qby bene_id contract_id plan_id region_code yr: egen totalbenecost = sum(totalcst)
qby bene_id contract_id plan_id region_code yr: egen totalpresc = sum(t)

gen newprice = totalcst
replace newprice = 0 if on_formulary == 0 

*Generate drugs actually covered by formulary, as share both of count and of spending
sort bene_id contract_id plan_id region_code yr
qby bene_id contract_id plan_id region_code yr: egen totalcostcovered = sum(newprice)
qby bene_id contract_id plan_id region_code yr: egen totalpresccovered = sum(on_formulary)


gen costfit = totalcostcovered/totalbenecost
gen prescfit = totalpresccovered/totalpresc

duplicates drop bene_id contract_id plan_id region_code yr, force
keep costfit prescfit bene_id contract_id plan_id region_code yr
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planunivlvlfit`yr'.dta", replace
}

*Stack the years together
clear
forval yr=2007/2014 {
append using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planunivlvlfit`yr'.dta"
} 
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planunivlvlfit_all.dta" 

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planunivlvlfit_all.dta", clear

*Generate randomized variable as random tiebreaker in case two plans have the same fit
generate u1 = runiform()
*Sort plans within person-year, by cost fit (by plan's spending-weighted share of drugs covered)
sort bene_id yr costfit u1
qby bene_id yr: gen obs = _N
*Generate plan's within person-year percentile, by cost fit
qby bene_id yr: gen perc = _n/_N

gen cost_lowerquart = perc <= .25
gen cost_upperquart = perc > .75

*Sort plans iwthin person-year, by non spending-weighted share of drugs covered
sort bene_id yr prescfit u1
qby bene_id yr: gen prescobs = _N
qby bene_id yr: gen prescperc = _n/_N

gen presc_lowerquart = prescperc <= .25
gen presc_upperquart = prescperc > .75

*Increment year to reflect year of reassignment, not year t-1 off which
*Ex-ante basket of drugs is calculated
replace yr = yr+1
rename yr year

*Calculate difference between median and worst plan in choice set
*For the spending and non-spending weighted measures of fit
sort bene_id year
qby bene_id year: egen costfit_median = median(costfit)
qby bene_id year: egen costfit_min = min(costfit)
gen costfit_median_min = costfit_median-costfit_min

qby bene_id year: egen prescfit_median = median(prescfit)
qby bene_id year: egen prescfit_min = min(prescfit)
gen prescfit_median_min = prescfit_median-prescfit_min

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planunivlvlfit_all_wq.dta", replace

**
*Construct person-year level absolute spread between best and worst fitting plans
*File which will be merged into main data set later
use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planunivlvlfit_all_wq.dta", clear
keep bene_id year prescfit_median_min costfit_median_min
rename prescfit_median_min prescfit_median_min_fa
rename costfit_median_min costfit_median_min_fa
duplicates drop bene_id year, force
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneyrlvl_spread.dta"

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planunivlvlfit_all_wq.dta", clear
duplicates drop region_code year, force
keep region_code year obs
rename obs obs_fin
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/obscount.dta", replace

