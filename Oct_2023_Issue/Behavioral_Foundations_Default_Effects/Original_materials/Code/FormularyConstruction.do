cd "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/"

*Purpose: Create Part D plan formulary file, which is then input to measuring plan 'fit'

**Stack together formulary files different plans, at plan-drug-year level

*Sample limitations:
***For 2007-2015
***Limiting to benchmark plans only

*Source data: CMS Medicare formulary files (more info here: https://www.cms.gov/Research-Statistics-Data-and-Systems/Files-for-Order/NonIdentifiableDataFiles/PrescriptionDrugPlanFormularyPharmacyNetworkandPricingInformationFiles)

use "/homes/data/cms/formulary/2007/1/basic-drugs/basicdrugs20071.dta", clear
gen yr = 2007
keep yr formulary_id ndc prior_auth step_therapy_y
duplicates drop formulary_id ndc, force
save Form2007, replace

use "/homes/data/cms/formulary/2007/10/basic-drugs/basicdrugs200710.dta"
gen yr = 2008
keep yr formulary_id ndc prior_auth step_therapy_y
duplicates drop formulary_id ndc, force
save Form2008, replace

use "/homes/data/cms/formulary/2009/1/basic-drugs/basicdrugs20091.dta", clear
gen yr = 2009
keep yr formulary_id ndc prior_auth step_therapy_y
duplicates drop formulary_id ndc, force
save Form2009, replace

use "/homes/data/cms/formulary/2009/10/basic-drugs/basicdrugs200910.dta", clear
gen yr = 2010
keep yr formulary_id ndc prior_auth step_therapy_y
duplicates drop formulary_id ndc, force
save Form2010, replace

use "/homes/data/cms/formulary/2010/10/basic-drugs/basicdrugs201010.dta", clear
gen yr = 2011
keep yr formulary_id ndc prior_auth step_therapy_y
duplicates drop formulary_id ndc, force
save Form2011, replace

use "/homes/data/cms/formulary/2011/10/basic-drugs/basicdrugs201110.dta", clear
gen yr = 2012
keep yr formulary_id ndc prior_auth step_therapy_y
duplicates drop formulary_id ndc, force
save Form2012, replace

use "/homes/data/cms/formulary/2012/10/basic-drugs/basicdrugs201210.dta", clear
gen yr = 2013
keep yr formulary_id ndc prior_auth step_therapy_y
duplicates drop formulary_id ndc, force
save Form2013, replace

use "/homes/data/cms/formulary/2013/10/basic-drugs/basicdrugs201310.dta", clear
gen yr = 2014
keep yr formulary_id ndc prior_auth step_therapy_y
duplicates drop formulary_id ndc, force
save Form2014, replace

use "/homes/data/cms/formulary/2014/10/basic-drugs/basicdrugs201410.dta", clear
gen yr = 2015
keep yr formulary_id ndc prior_auth step_therapy_y
duplicates drop formulary_id ndc, force
save Form2015, replace


**Stack base formulary files together
clear 
forval yr = 2007/2015 {
append using Form`yr'
}
save FormAllYrs, replace

***
*Pull in crosswalk mapping encrypted plan ID's to actual plan ID's, given that some datasets have encrypted, some have actual. Jsut to standardize everything
forval yr = 2007/2012 {
use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/`yr'/plnb`yr'.dta", clear
sort contract_id_encrypted plan_id_encrypted segment_id_encrypted
keep contract_id* plan_id* segment_id* formulary_id
destring formulary_id, replace
save XWalkenc`yr', replace

***
*Load in unique service regions in which different plans operate
use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/`yr'/srv`yr'.dta", clear
duplicates drop contract_id plan_id segment_id region_code, force
keep contract_id plan_id segment_id region_code region_name
save srvB`yr',replace
***

*Pull in plans benchmark statuses-limit just to benchmark plans
*Expand contract-plan-year dataset to be contract-plan-service-year level instead
*
use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/`yr'/prm`yr'.dta", clear

keep if below_benchmark == "B"
joinby contract_id plan_id segment_id using srvB`yr'

rename contract_id contract_id_encrypted
rename plan_id plan_id_encrypted
rename segment_id segment_id_encrypted

*Map encrypted plan ID's to actual
sort contract_id_encrypted plan_id_encrypted segment_id_encrypted
merge contract_id_encrypted plan_id_encrypted segment_id_encrypted using XWalkenc`yr'
keep if _merge == 3
keep contract_id plan_id segment_id below_benchmark formulary_id region_code region_name

sort contract_id plan_id segment_id
save prmB_`yr', replace
tab region_name
save prmBT_`yr', replace
***
*Map contract-plan-service-year data to its corresponding formulary, and expand out data
*to contract-plan-service-year-NDC level accordingly
use Form`yr', clear
joinby formulary_id using prmBT_`yr'
drop below_benchmark
order yr contract_id plan_id segment_id region_code region_name
save Combined`yr', replace
}


*Do the same exercise as above, except for 2013-2015, rather than just 2007-2012
forval yr = 2013/2015 {

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/`yr'/pln`yr'.dta", clear
duplicates drop contract_id plan_id, force
destring formulary_id, replace
keep contract_id plan_id formulary_id
sort contract_id plan_id
save plnX`yr', replace 

***
use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/`yr'/srv`yr'.dta", clear
duplicates drop contract_id plan_id segment_id region_code, force
keep contract_id plan_id segment_id region_code region_name
save srvB`yr',replace
***

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/`yr'/prm`yr'.dta", clear

keep if below_benchmark == "B" | below_benchmark == "X"
sort contract_id plan_id
merge contract_id plan_id using plnX`yr'

joinby contract_id plan_id segment_id using srvB`yr'

keep contract_id plan_id segment_id below_benchmark formulary_id region_code region_name

sort contract_id plan_id segment_id
save prmB_`yr', replace
tab region_name
save prmBT_`yr', replace
***

use Form`yr', clear
joinby formulary_id using prmBT_`yr'
drop below_benchmark
order yr contract_id plan_id segment_id region_code region_name
save Combined`yr', replace
}


*Stack yearly files together
*Merge in plan premium, relative to benchmark
*Throw out benchmark plans whose premiums above benchmark
clear
forval yr = 2007/2015 {
append using Combined`yr', force
}
replace region_name = trim(region_name)

gen priorauth_or_step = prior_authorization_yn == "Y" | step_therapy_yn == "Y"

destring region_code, replace
sort contract_id plan_id region_code yr
merge contract_id plan_id region_code yr using PlanRunning
keep if _merge == 3
drop _merge
*Throw out plans specified benchmark, but whose premium was 'above benchmark' in the index year
drop if (pre_running > 0)

save CombinedFormAll_Sept2019, replace
