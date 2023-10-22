*Construct absolute (raw) fit for an individual's incumbent plan
*Purpose: To respond to a specific referee comment

**Specify beneficiary sample for which fit measure will actually get generated
use "/disk/agedisk3/medicare.work/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/output/ptd_LIS65_samp.dta", clear
keep if in_20pct == 1
duplicates drop bene_id, force
keep bene_id
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneid_list.dta", replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/output/ptd_LIS65_samp.dta", clear
keep ref_year contract_id_Dec plan_id_Dec bene_id in_20pct
rename ref_year yr
keep if in_20pct == 1
duplicates drop bene_id yr, force
drop in_20pct
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneidyr_list.dta", replace

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

/*
*Generate list of benchmark plans, which we will later limit these analyses to
*Revision: Do this just for the incumbent plan
use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/CombinedFormAll_Sept2019.dta", clear
duplicates drop contract_id plan_id region_code yr, force
keep contract_id plan_id region_code yr
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/uniqplnlst.dta", replace
*/

*Generate unique set of NDC 9's covered in each plan formulary
*Pull in formulary data with NON-benchmark plans
use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/LPV_CombinedFormAll_Feb2020.dta", clear
keep yr contract_id plan_id ndc 
gen ndc9 = substr(ndc, 1, 9)
*duplicates drop yr contract_id plan_id segment_id region_code ndc9, force
duplicates drop yr contract_id plan_id ndc9, force
*drop segment_id
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/formularyforuse_vx.dta", replace 
*Generate unique set of NDC9's covered by ANY plan formulary over our sample period
duplicates drop ndc9, force
keep ndc9
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/formularyforusetest2_vx.dta", replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/formularyforuse_vx.dta", clear
duplicates drop yr contract_id plan_id, force
keep yr contract_id plan_id
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planlistformulary.dta", replace

 

*Take unique set of NDC9's taken by each bene per year
*Pull in each patient's region code of residence
*Pull in each person's plan of enrollment
*Increment to reflect year t+1

forval yr = 2007/2014 {
use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/uniqdrugs`yr'.dta", clear
gen yr = `yr'
merge m:1 bene_id yr using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/regioncodes.dta", keep (3) nogen

merge m:1 bene_id yr using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/beneidyr_list.dta", keep (3) nogen
rename contract_id_Dec contract_id 
rename plan_id_Dec plan_id
*Increment to reflect t+1
replace yr = yr+1

save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/uniqdrugsplanuniv`yr'_vx.dta", replace
}

forval yr = 2007/2014 {
use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/uniqdrugsplanuniv`yr'_vx.dta", clear
*Restrict just to Medicare-covered drugs (covered by at least one formulary across all years in samp period)
merge m:1 ndc9 using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/formularyforusetest2_vx.dta", keep(3) nogen

*Merge each possible person-drug-year combo (set of ex-ante drugs person was taking), with the drug formulary status in their incumbent plan in year t+1 
merge m:1 yr contract_id plan_id ndc9 using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/formularyforuse_vx.dta", keep(1 3)
gen on_formulary = _merge == 3
drop ndc _merge

*Only keep if incument plan shows up in formulary in post year to begin with
merge m:1 yr contract_id plan_id using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planlistformulary.dta", keep(3)

*Merge in drug-year level average drug price information
replace yr = yr-1
drop _merge
merge m:1 yr ndc9 using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/pardpriceallyrs.dta", keep(3)

gen t = 1
**Generate total cost of each beneficiary's ex-ante basket of drugs, for each year
*Also calculate number of drugs in each ex-ante basket
sort bene_id contract_id plan_id yr
qby bene_id contract_id plan_id  yr: egen totalbenecost = sum(totalcst)
qby bene_id contract_id plan_id yr: egen totalpresc = sum(t)

gen newprice = totalcst
replace newprice = 0 if on_formulary == 0 

*Generate drugs actually covered by formulary, as share both of count and of spending
sort bene_id contract_id plan_id yr
qby bene_id contract_id plan_id yr: egen totalcostcovered = sum(newprice)
qby bene_id contract_id plan_id yr: egen totalpresccovered = sum(on_formulary)


gen costfit = totalcostcovered/totalbenecost
gen prescfit = totalpresccovered/totalpresc

duplicates drop bene_id yr, force
keep costfit prescfit bene_id yr
rename costfit costfit_inc
rename prescfit prescfit_inc
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planunivlvlfit`yr'_vx.dta", replace
}

*Stack the years together
clear
forval yr=2007/2014 {
append using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planunivlvlfit`yr'_vx.dta"
} 
replace yr = yr+1
rename yr year
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/rdfit/temp/planunivlvlfit_all_vx.dta", replace
