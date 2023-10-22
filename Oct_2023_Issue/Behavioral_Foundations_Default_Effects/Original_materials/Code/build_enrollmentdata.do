cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/sample/code/"
*for testing code interactively

*Generate year-level datasets tracking active choice, plan of enrollment, and whether belongs in balanced panel
*As input to other downstream data construction


global bsfab "../../../../raw/medicare_part_ab_bsf/data"
global bsfab_20pct "../../../../raw/medicare_part_ab_bsf_20pct/data"
global bsfd "../../../../raw/medicare_part_d_bsf/data"
global elc "../../../../raw/medicare_part_d_elc/data"
global states "../../../../raw/geo_data/data/states"
global mcdps "../../../../raw/medicaid_ps/data"
global mcr_mcd_xwk "../../../../raw/medicare_medicaid_crosswalk/data"
global ptd_bnch "../../../../raw/medicare_part_d_benchmark/data"

*Generate active choice status as of end of each calendar year, as well as of beginning fo each calendar year
use ../temp/elc_actv_ind
	
	bysort bene_id ref_year (enrlmt_efctv_dt): egen yr_dup = count(ref_year)
	*tab yr_dup
	bysort bene_id ref_year (enrlmt_efctv_dt): gen last = (_n == _N)
	*tab last
	keep if last == 1
	
	keep bene_id ref_year type_actv enrlmt_type_cd
	rename type_actv_ind endyr_actv_ind
	rename enrlmt_type_cd  endyr_code_ind
	rename ref_year yr
	save ../temp/elect_endyr_status, replace
	
	use ../temp/elc_actv_ind
	
	bysort bene_id ref_year (enrlmt_efctv_dt): egen yr_dup = count(ref_year)
	tab yr_dup
	bysort bene_id ref_year (enrlmt_efctv_dt): gen begin = (_n == 1)
	tab begin
	keep if begin == 1
	
	keep bene_id ref_year type_actv enrlmt_type_cd 
	rename type_actv_ind beginyr_actv_ind
	rename enrlmt_type_cd  beginyr_code_ind
	rename ref_year yr
	save ../temp/elect_beginyr_status, replace

*Generate dataset at person-year level with Jan plan of enrollment, December plan of enrollment, and January/December active choice status
use ../temp/prelim_sample_mcr_20pct_raw_LIS65_07_15, clear
	
	tab year
	rename pdp_region region_code 
	rename year yr

	keep bene_id yr cntrct01 cntrct12 pbpid* sgmtid*
	duplicates drop bene_id yr, force
	reshape long cntrct pbpid sgmtid, i(bene_id yr) j(month) string
	*Encrypted plan information crosswalk
	rename cntrct contract_id_encrypted
	rename pbpid plan_id_encrypted 
	rename sgmtid segment_id_encrypted 
	
	merge m:1 contract_id_encrypted plan_id_encrypted segment_id_encrypted yr using ${ptd_bnch}/CrossWalkEncrypted.dta
	tab yr _merge
	tab contract_id_encrypted if _merge == 1 & yr >= 2008 & yr <= 2012 //most of the nonmatch is due to contract01 = 0 or N
	drop if _merge == 2
	drop _merge

	replace contract_id = contract_id_encrypted if (yr == 2007 | yr >= 2013)
	replace plan_id = plan_id_encrypted if (yr == 2007 | yr >= 2013)
	replace segment_id = segment_id_encrypted if (yr == 2007 | yr >= 2013)
	
	drop contract_id_encrypted plan_id_encrypted segment_id_encrypted
	reshape wide contract_id plan_id segment_id, i(bene_id yr) j(month) string
	
	replace yr = yr + 1
	merge 1:1 bene_id yr using ../temp/elect_endyr_status, keep(1 3) nogen
	merge 1:1 bene_id yr using ../temp/elect_beginyr_status, keep(1 3) nogen
	
	replace yr = yr -1
	
	rename endyr_actv_ind endyr_act_ind_2 
	rename beginyr_actv_ind beginyr_actv_ind_2
	
	rename endyr_code_ind endyr_code_ind_2 
	rename beginyr_code_ind beginyr_code_ind_2
	
	merge 1:1 bene_id yr using ../temp/elect_endyr_status, keep(3) nogen
	merge 1:1 bene_id yr using ../temp/elect_beginyr_status, keep(3) nogen
		
save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/enrollment_data/output/lis_enroll_data", replace

**Pull in active choice status as of January for each person-year
**Limit to our LIS sample	

 use "/disk/agedisk3/medicare.work/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/sample/output/sample.dta", clear
 keep bene_id year enrlmt_type_cd
 rename year yr
 merge m:1 bene_id yr using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/enrollment_data/output/lis_enroll_data", keep(3) nogen
  keep bene_id yr enrlmt_type_cd
  save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/enrollment_data/output/active_choice_data", replace
  
  
  *Generate balanced panel sample (pre-2 years and post-1 year active in sample)-so FOUR years of balance in ALL: bene id list
use ../temp/prelim_sample_mcr_20pct_raw_LIS65_07_15, clear
gen balanced = 0
sort bene_id year
qby bene_id: replace balanced = 1 if (year+1== year[_n+1]) & (year-1== year[_n-1]) & (year-2== year[_n-2])
keep if balanced == 1
keep bene_id  year
  save "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/part_d_behavioral_all/enrollment_data/output/balanced_list", replace
