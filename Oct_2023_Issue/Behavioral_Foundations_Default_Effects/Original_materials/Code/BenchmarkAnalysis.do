cd "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/"

*Generates our key running variable: plan premium relative to benchmark. In doing so, identifies and limits just to plans that were benchmark plans ex-ante (in the pre re-assignment year)

*Addditionally, generates set of exiting plans for each year, which is leveraged as an additional
*natural experiment in the final section of our paper.

*Load crosswalks between unencrypted and encrypted plan ID's

*Source data used: CMS Medicare Plan Characteristics data (more info on this data can be found here: https://resdac.org/cms-data/files/plan-characteristics)

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/2008/plnxw2008.dta", clear
rename contract_id_07 contract_id_encrypted
rename plan_id_07 plan_id_encrypted
drop contract_id_08 plan_id_08
gen yr = 2007
save Ext2007, replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/2009/plnxw2009.dta", clear
rename contract_id_08 contract_id_encrypted
rename plan_id_08 plan_id_encrypted
drop contract_id_09 plan_id_09
gen yr = 2008
save Ext2008, replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/2010/plnxw2010.dta", clear
rename contract_id_09 contract_id_encrypted
rename plan_id_09 plan_id_encrypted
drop contract_id_10 plan_id_10
gen yr = 2009
save Ext2009, replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/2011/plnxw2011.dta", clear
rename contract_id_10 contract_id_encrypted
rename plan_id_10 plan_id_encrypted
drop contract_id_11 plan_id_11
gen yr = 2010
save Ext2010, replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/2012/plnxw2012.dta", clear
rename contract_id_11 contract_id_encrypted
rename plan_id_11 plan_id_encrypted
drop contract_id_12 plan_id_12
gen yr = 2011
save Ext2011, replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/2013/plnxw2013.dta", clear
rename contract_id_12 contract_id_encrypted
rename plan_id_12 plan_id_encrypted
drop contract_id_13 plan_id_13
gen yr = 2012
save Ext2012, replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/2014/plnxw2014.dta", clear
rename contract_id_13 contract_id_encrypted
rename plan_id_13 plan_id_encrypted
drop contract_id_14 plan_id_14
gen yr = 2013
save Ext2013, replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/2015/plnxw2015.dta", clear
rename contract_id_14 contract_id_encrypted
rename plan_id_14 plan_id_encrypted
drop contract_id_15 plan_id_15
gen yr = 2014
save Ext2014, replace


*Stack the crosswalk files
clear
forval yr = 2007/2014 {
append using Ext`yr'
}
drop if contract_id_encrypted == ""
save ExtAll, replace
use ExtAll, clear
keep if yr < 2012
duplicates drop contract_id plan_id yr, force
sort contract_id_encrypted plan_id_encrypted yr
save ExtAll_1, replace

use ExtAll, clear
keep if yr >= 2012
rename contract_id_encrypted contract_id
rename plan_id_encrypted plan_id
sort contract_id plan_id yr
save ExtAll_2, replace

*Load in plan characteristics files, plan availability by service region files

forval yr = 2007/2012 {

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/`yr'/pln`yr'.dta", clear
keep contract_id plan_id drug_benefit_type egwp_indicator
sort contract_id plan_id
save PlanFile`yr', replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/`yr'/plnb`yr'.dta", clear
sort contract_id_encrypted plan_id_encrypted segment_id_encrypted
keep contract_id* plan_id* segment_id* formulary_id
destring formulary_id, replace
save XWalkencA`yr', replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/`yr'/srv`yr'.dta", clear
duplicates drop contract_id plan_id segment_id region_code, force
keep contract_id plan_id segment_id region_code region_name
save srvC`yr',replace

*Open premium-by-plan-file
use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/`yr'/prm`yr'.dta", clear

*Expand file to premium-by plan-by service region level
joinby contract_id plan_id segment_id using srvC`yr'

*Merge in plan characteristics
sort contract_id plan_id
merge contract_id plan_id using PlanFile`yr' 
drop if _merge == 2
 drop _merge 
rename contract_id contract_id_encrypted
rename plan_id plan_id_encrypted
rename segment_id segment_id_encrypted

*Merge in crosswalks, mapping encrypted plan ID's to non-encrypted versions
sort contract_id_encrypted plan_id_encrypted segment_id_encrypted
merge contract_id_encrypted plan_id_encrypted segment_id_encrypted using XWalkencA`yr'
keep if _merge == 3
keep contract_id* plan_id* segment_id* below_benchmark formulary_id region_code region_name drug_benefit_type egwp_indicator part_d_lips_100 plan_basic_prem plan_total_prem
gen contract_idF= substr(contract_id, 1, 1)

*Keep stand-alone PDP plans only (drop MA-PD plans)
keep if contract_idF == "S"
cap rename below_benchmarkl below_benchmark
cap rename part_d_lips_100l part_d_lips_100
cap rename plan_basic_premium_net_rebatel plan_basic_premium_net_rebate
cap rename plan_total_premium_net_rebatel plan_total_premium_net_rebate
save PlanUniv`yr', replace
}

*Do this same exercise for 2013 through 2015
forval yr = 2013/2015 {

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/`yr'/pln`yr'.dta", clear
sort contract_id plan_id 
keep contract_id* plan_id* formulary_id deminimis_pd_flag drug_benefit_type egwp_indicator
destring formulary_id, replace
save XWalkencB`yr', replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/`yr'/srv`yr'.dta", clear
duplicates drop contract_id plan_id segment_id region_code, force
keep contract_id plan_id segment_id region_code region_name
save srvC`yr',replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/`yr'/prm`yr'.dta", clear

joinby contract_id plan_id segment_id using srvC`yr'

sort contract_id plan_id
merge contract_id plan_id using XWalkencB`yr'
keep if _merge == 3

keep contract_id* plan_id* segment_id* below_benchmark formulary_id region_code region_name plan_basic_premium_net_rebate plan_total_premium_net_rebate deminimis_pd_flag part_d_lips_100 drug_benefit_type egwp_indicator
gen contract_idF= substr(contract_id, 1, 1)
keep if contract_idF == "S"
save PlanUniv`yr', replace
}

*Merge in additional deniminimus flag for 2011/2012 that did not originally show
*up in files for those years
use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/2011/pln2011.dta", clear
rename contract_id contract_id_encrypted
rename plan_id plan_id_encrypted
keep contract_id_encrypted plan_id_encrypted deminimis_pd_flag
gen yr = 2011
save PlnIDB2011, replace

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/pln/2012/pln2012.dta", clear
rename contract_id contract_id_encrypted
rename plan_id plan_id_encrypted
keep contract_id_encrypted plan_id_encrypted deminimis_pd_flag
gen yr = 2012
save PlnIDB2012, replace

use PlnIDB2011, clear
append using PlnIDB2012
sort contract_id_encrypted plan_id_encrypted yr 
save PlnIDB, replace

clear 
forval yr= 2007/2012 {
append using PlanUniv`yr'
cap gen yr = .
replace yr = `yr' if yr == .
}
sort contract_id_encrypted plan_id_encrypted yr
merge contract_id_encrypted plan_id_encrypted yr using PlnIDB
drop if _merge == 2
drop _merge
save PlanUnivAllPre, replace

*Stack all different years togetehr
clear 
forval yr= 2013/2015 {
append using PlanUniv`yr'
cap gen yr = .
replace yr = `yr' if yr == .
}
append using PlanUnivAllPre
save PlanUnivAll, replace

use PlanUnivAll, clear

*Drop if employer plan
drop if egwp_indicator == "Y"

*Merge in actual benchmark premium amounts, by region-year
destring region_code, replace
sort region_code yr
merge region_code yr using BenchmarksFinal
tab _merge
drop if region_code > 34
drop _merge

*Merge in exiting data
sort contract_id plan_id segment_id region_code yr
qby contract_id plan_id segment_id region_code: gen last = _n == _N
gen exiting = (last == 1) & yr ~= 2015

sort contract_id plan_id segment_id region_code yr
qby contract_id plan_id segment_id region_code: gen bnchmkyrp1 =below_benchmark[_n+1]
qby contract_id plan_id segment_id region_code: gen deminsp1 =deminimis_pd_flag[_n+1]
qby contract_id plan_id segment_id region_code: gen futureprem_subs =part_d_lips_100[_n+1]
qby contract_id plan_id segment_id region_code: gen futureprem_tot =plan_basic_prem[_n+1]
qby contract_id plan_id segment_id region_code: gen futurebench = benchmark_level[_n+1]
qby contract_id plan_id segment_id region_code: gen futuredbt= drug_benefit_type[_n+1]

****Define plans losing benchmark to:
*Benchmark Plans Yr 1 (pre-reassignment)
*Not Benchmark Plans Yr2 (post-reassign)
*Not Deniminis Plans Yr2 (post-reasign)
*Not Exiting Plans Yr2 (post-reassign)

*Lose benchmark-in post year, not regular benchmark and not deminimus and not exiting. In pre-year, benchmark. 
gen lose_benchmark = below_benchmark == "B" & bnchmkyrp1 ~= "B" & bnchmkyrp1 ~= "D" & deminsp1 ~= "Y" & exiting == 0 & yr ~= 2015


*Merge on unencrypted ID's
sort contract_id_encrypted plan_id_encrypted yr
merge contract_id_encrypted plan_id_encrypted yr using ExtAll_1
tab _merge
drop if _merge == 2
drop _merge
*Standardize relationship (plan type) fields
rename relationship_code relationship_code1
rename relationship_des relationship_desc1
sort contract_id plan_id yr
merge contract_id plan_id yr using ExtAll_2
tab _merge
drop if _merge == 2
drop _merge
replace relationship_code = relationship_code1 if relationship_code == ""
replace relationship_desc = relationship_desc1 if relationship_desc == ""

save PlanUnivAllFinal, replace


****Further restrictions
*Restrict only to benchmark, non deminimus plans in pre-year
*Restrict to non-deminimus plans AND non-exiting plans in post year
*Restrict to plans that retain 'basic coverage type' in post year, to ensure comparability

use PlanUnivAllFinal, clear
keep if below_benchmark == "B" & deminimis_pd_flag ~= "Y" & bnchmkyrp1 ~= "D" & deminsp1 ~= "Y" & exiting == 0 & yr ~= 2015
drop if futuredbt == "4"

*Construct running variable in terms of year t+1
*Premium-benchmark
gen running = futureprem_tot-futurebench
gen pre_running = plan_basic_prem - benchmark_level
keep contract_id plan_id segment_id region_code yr lose_benchmark futureprem* futurebench running pre_running exiting

*Drop plans whose listed  year (t+1) and year t benchmark status and premium values do not appear internally consistent 
drop if (running > 0 & lose_benchmark == 0) | (running < 0 & lose_benchmark == 1)
drop if pre_running > 0
drop futureprem* futurebench

save PlansRunningPrem, replace

**************
**Identify plans that did not lose benchmark-again-between year t+1 and year t+2
**2 year 
use PlansRunningPrem, clear
sort contract_id plan_id segment_id region_code yr
qby contract_id plan_id segment_id region_code: gen lose_benchmarkp1 = lose_benchmark[_n+1] if yr+1 == yr[_n+1] 

gen not_losebenchmark2 = (lose_benchmark == 0) & (lose_benchmarkp1 == 0)
keep contract_id plan_id region_code yr not_losebenchmark2 
duplicates drop contract_id plan_id region_code yr, force
rename yr year
replace year = year+1

sort contract_id plan_id region_code year
rename contract_id contract_id_Dec 
rename plan_id plan_id_Dec
save PlansRunningPrem_2year, replace

use PlansRunningPrem, clear
sort contract_id plan_id region_code yr
keep contract_id plan_id region_code yr lose_benchmark
rename yr year
*replace year = year+1
rename lose_benchmark lose_benchmarkassigned
sort contract_id plan_id region_code year
save PlansRunningPrem_yr_assigned, replace

**
**Include de minimus plans-alternative sample

use PlanUnivAllFinal, clear
keep if below_benchmark == "B" & exiting == 0 & yr ~= 2015 & deminimis_pd_flag ~= "Y" 
drop if futuredbt == "4"

gen demin_flag =  (bnchmkyrp1 == "D") | (deminsp1 == "Y")

gen running = futureprem_tot-futurebench
gen pre_running = plan_basic_prem - benchmark_level
keep contract_id plan_id segment_id region_code yr lose_benchmark futureprem* futurebench running pre_running exiting demin_flag
*Drop plans whose listed benchmark status and premium values do not appear internally consistent 
drop if (running > 0 & lose_benchmark == 0  & demin_flag == 0) | (running < 0 & lose_benchmark == 1)
drop if pre_running > 0
drop futureprem* futurebench

save PlansRunningPrem_InclDemin, replace


*****************

*Generating set of exiting plans

*In Feb 2020 version-do not keep benchmark variable. Also explicitly name
*year variable as 'last_yr'
*Note that this is for non-LIS analysis
use PlanUnivAllFinal, clear
keep if exiting == 1 & relationship_code == "T"
gen benchmark = below_benchmark == "B"
keep contract_id plan_id segment_id region_code yr benchmark
drop benchmark
rename yr last_yr

save ExitingPlans_Feb2020, replace

*Note that this is for regular analysis
use PlanUnivAllFinal, clear
keep if exiting == 1 & relationship_code == "T"
gen benchmark = below_benchmark == "B"
keep contract_id plan_id segment_id region_code yr benchmark 

save ExitingPlans, replace

*Note that this is same as previous exit file, except includes new definition of 'benchmark'
*inclusive of de minimus
use PlanUnivAllFinal, clear
keep if exiting == 1 & relationship_code == "T"
gen benchmark = below_benchmark == "B"
keep contract_id plan_id segment_id region_code yr below_benchmark deminimis_pd_flag
gen deminimus = below_benchmark == "D" | deminimis_pd_flag == "Y" | deminimis_pd_flag == "9"
drop below_bench deminimis
save ExitingPlans_typeinfo, replace

***************************
***Crosswalk between encrypted and unencrypted plan ID's
forval yr=2007/2012 {
use XWalkencA`yr', clear
gen yr = `yr'
save XWalkencA`yr'B, replace
}

clear
forval yr=2007/2012 {
append using XWalkencA`yr'B
}
drop formulary
save CrossWalkEncrypted, replace
