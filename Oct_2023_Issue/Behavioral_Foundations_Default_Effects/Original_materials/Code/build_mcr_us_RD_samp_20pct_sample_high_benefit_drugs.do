*This do file takes the 20% RD sample and merges it with the high benefit drugs indicators to create spending variables for high benefit drugs.
*Final product: ptd_LIS65_20pct_samp_pde_qtr.dta

*for testing code interactively
cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/submission/code/"

adopath + ../../../../lib/ado/

global bsfab "../../../../raw/medicare_part_ab_bsf/data"
global bsfab_20pct "../../../../raw/medicare_part_ab_bsf_20pct/data"
global bsfd "../../../../raw/medicare_part_d_bsf/data"
global elc "../../../../raw/medicare_part_d_elc/data"
global states "../../../../raw/geo_data/data/states"
global mcdps "../../../../raw/medicaid_ps/data"
global mcr_mcd_xwk "../../../../raw/medicare_medicaid_crosswalk/data"
global ptd_bnch "../../../../raw/medicare_part_d_benchmark/data"

global redbook "../../../../raw/redbook/data"
global ptd_event "../../../../raw/medicare_part_d_pde/data"

cap log close
log using ../output/build_mcr_us_RD_samp_20pct_sample_high_benefit_drugs.log, replace

*Get mental drug and high benefit drug indicators
use "$redbook/redbook.dta", clear
gen ndcnum_9 = substr(ndcnum,1,9)

tab thrclds
gen mental_drug = (thrclds == "Psychother,Tranq/Antipsychotic" | thrclds == "Antimanic Agents, NEC")
tab mental_drug

tab thercls
gen high_bene_drug = (thercls == 173 | thercls == 172 | thercls == 174 | thercls == 53 | thercls == 69 | thercls == 70 | thercls == 74 | thercls == 64 | thercls == 47 | thercls == 50 | thercls == 51 | thercls == 39 | thercls == 166 | thercls == 78 | thercls == 168)
tab high_bene_drug

keep ndcnum_9 mental_drug high_bene_drug thercls

*Keep unique 9-digit NDC for mental and high benefit drugs
duplicates drop 
unique ndcnum_9

gsort ndcnum_9 -high_bene_drug -mental_drug

bysort ndcnum_9: gen drug_seq = _n
tab drug_seq

keep if drug_seq == 1
keep ndcnum_9 thercls mental_drug high_bene_drug
unique ndcnum_9
tab mental_drug
tab high_bene_drug

save "$redbook/redbook_high_bene_mental_ind.dta", replace

*Merge high benefit drug indicator with drug claims for beneficiaries in the RD 20% sample
use ../output/ptd_LIS65_20pct_samp_bene_id.dta, clear
keep bene_id
duplicates drop
save ../output/ptd_LIS65_20pct_samp_bene_id_only.dta, replace

forvalues t = 2007/2015 {

	use "$ptd_event/opt1pde`t'.dta", clear
	keep bene_id prdsrvid srvc_dt totalcst dayssply
	gen ref_year = `t'
	merge m:1 bene_id using ../output/ptd_LIS65_20pct_samp_bene_id_only.dta, keep(3) nogen
	
	gen ndcnum_9 = substr(prdsrvid,1,9)
	merge m:1 ndcnum_9 using "$redbook/redbook_high_bene_mental_ind.dta", keep(3) nogen
	save "../temp/ptd_LIS65_20pct_samp_pde_`t'.dta", replace
	
}

clear all
forvalues t = 2007/2015 {
	append using ../temp/ptd_LIS65_20pct_samp_pde_`t'.dta
}
save ../output/ptd_LIS65_20pct_samp_pde.dta, replace

*Aggregate to person-quarter level drug usage by high vs. low benefit drugs
gen srvc_qtr = qofd(srvc_dt)
format srvc_qtr %tq
collapse (sum) pde_spend=totalcst (count) num_pres=totalcst (sum) days_supply=dayssply (mean) ref_year, by(bene_id srvc_qtr high_bene_drug)
reshape wide pde_spend num_pres days_supply, i(bene_id srvc_qtr) j(high_bene_drug)
foreach x in pde_spend num_pres days_supply {
	rename `x'0 `x'_lowbene
	rename `x'1 `x'_hibene
}
save ../output/ptd_LIS65_20pct_samp_pde_qtr.dta, replace

log close

