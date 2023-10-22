*This do file takes 20% raw Medicare data and creates the sample for RD analysis with detailed utilization information.
*Final end products: 
*ptd_LIS65_20pct_samp.dta; 
*ptd_LIS65_20pct_samp_bene_id.dta

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

cap log close
log using "../output/build_mcr_us_RD_samp_20pct_sample.log", replace

*Program selecting preliminary sample
program prelim_medicare
    forv year = 2007/2015 {
	disp "`year'"
	
	*Get 20% sample indicator
        use bene_id using ${bsfab_20pct}/bsfab`year', clear
        duplicates drop
        save ../temp/sample_list_20pct_`year', replace
	
	if `year' < 2015 {
	
		use bene_id rfrnc_yr state_cd cnty_cd bene_zip sex race age bene_dob death_dt hmo_mo a_mo_cnt b_mo_cnt using ${bsfab}/bsfab`year', clear

		*Keep only those in the 20% sample
		merge m:1 bene_id using ../temp/sample_list_20pct_`year', keep(3) keepusing(*) nogen
	
		*Keep those aged 65+
		keep if rfrnc_yr - yofd(bene_dob) >= 65 

		*Keep if in Medicare for all year
		cap destring a_mo_cnt, replace
		cap destring b_mo_cnt, replace
		keep if a_mo_cnt == 12
		keep if b_mo_cnt == 12

		drop a_mo_cnt b_mo_cnt
	
		*Keep if not in MA in any month of the year
		cap destring hmo_mo, replace
		keep if hmo_mo == 0
		
		drop hmo_mo
		
		*A small number of duplicated observations in bsfab, keeping all of them for now
		bysort bene_id: egen dupcnt = count(rfrnc_yr)
		tab dupcnt
		
		merge m:1 bene_id using ${bsfd}/bsfd`year', assert(2 3) keep(3) keepusing(dual* cstshr* cntrct* pbpid01 pbpid12 sgmtid01 sgmtid12) nogen

		*Keep if enrolled in Part D, dual-eligible and LIS in all months		
		foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {	
			gen enrl_d_`t' = (cntrct`t' != "" & cntrct`t' != "N" & cntrct`t' != "0" & cntrct`t' != "*" & cntrct`t' != "X")
			gen enrl_dual_`t' = (dual_`t' != "" & dual_`t' != "**" & dual_`t' != "00" & dual_`t' != "09" & dual_`t' != "99" & dual_`t' != "NA" & dual_`t' != "XX")
			gen enrl_cstshr_`t' = (cstshr`t' == "01" | cstshr`t' == "02" | cstshr`t' == "03")
		}
		
		keep if (enrl_d_01 == 1 & enrl_d_02 == 1 & enrl_d_03 == 1 & enrl_d_04 == 1 & enrl_d_05 == 1 & enrl_d_06 == 1 & enrl_d_07 == 1 & enrl_d_08 == 1 & enrl_d_09 == 1 & enrl_d_10 == 1 & enrl_d_11 == 1 & enrl_d_12 == 1)
		keep if (enrl_dual_01 == 1 & enrl_dual_02 == 1 & enrl_dual_03 == 1 & enrl_dual_04 == 1 & enrl_dual_05 == 1 & enrl_dual_06 == 1 & enrl_dual_07 == 1 & enrl_dual_08 == 1 & enrl_dual_09 == 1 & enrl_dual_10 == 1 & enrl_dual_11 == 1 & enrl_dual_12 == 1)
		keep if (enrl_cstshr_01 == 1 & enrl_cstshr_02 == 1 & enrl_cstshr_03 == 1 & enrl_cstshr_04 == 1 & enrl_cstshr_05 == 1 & enrl_cstshr_06 == 1 & enrl_cstshr_07 == 1 & enrl_cstshr_08 == 1 & enrl_cstshr_09 == 1 & enrl_cstshr_10 == 1 & enrl_cstshr_11 == 1 & enrl_cstshr_12 == 1)

		foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {	
			drop enrl_d_`t' enrl_dual_`t' dual_`t' enrl_cstshr_`t' cstshr`t'
		}
		
		drop dual_mo
	
	}
	
	if `year' == 2015 {
		use bene_id rfrnc_yr state_cd cnty_cd zip_cd sex race age bene_dob death_dt hmo_mo a_mo_cnt b_mo_cnt using ${bsfab}/bsfab`year', clear
		
		*Keep only those in the 20% sample		
		merge m:1 bene_id using ../temp/sample_list_20pct_`year', keep(3) keepusing(*) nogen		
		
		rename zip_cd bene_zip	
	
		*Keep those aged 65+
		keep if rfrnc_yr - yofd(bene_dob) >= 65 

		*Keep if in Medicare for all year
		cap destring a_mo_cnt, replace
		cap destring b_mo_cnt, replace
		keep if a_mo_cnt == 12
		keep if b_mo_cnt == 12

		drop a_mo_cnt b_mo_cnt
	
		*Keep if not in MA in any month of the year
		cap destring hmo_mo, replace
		keep if hmo_mo == 0
		
		drop hmo_mo

		*A small number of duplicated observations in bsfab, keeping all of them for now
		bysort bene_id: egen dupcnt = count(rfrnc_yr)
		tab dupcnt

		merge m:1 bene_id using ${bsfd}/bsfd`year', assert(2 3) keep(3) keepusing(dual* cstshr* ptdcntrct* ptdpbpid01 ptdpbpid12 sgmtid01 sgmtid12) nogen		

		foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {	
			cap rename ptdcntrct`t' cntrct`t'
			cap rename ptdpbpid`t' pbpid`t'
		}
		
		*Keep if enrolled in Part D, dual-eligible and LIS in all months		
		foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {	
			gen enrl_d_`t' = (cntrct`t' != "" & cntrct`t' != "N" & cntrct`t' != "0" & cntrct`t' != "*" & cntrct`t' != "X")
			gen enrl_dual_`t' = (dual_`t' != "" & dual_`t' != "**" & dual_`t' != "00" & dual_`t' != "09" & dual_`t' != "99" & dual_`t' != "NA" & dual_`t' != "XX")
			gen enrl_cstshr_`t' = (cstshr`t' == "01" | cstshr`t' == "02" | cstshr`t' == "03")
		}
		
		keep if (enrl_d_01 == 1 & enrl_d_02 == 1 & enrl_d_03 == 1 & enrl_d_04 == 1 & enrl_d_05 == 1 & enrl_d_06 == 1 & enrl_d_07 == 1 & enrl_d_08 == 1 & enrl_d_09 == 1 & enrl_d_10 == 1 & enrl_d_11 == 1 & enrl_d_12 == 1)
		keep if (enrl_dual_01 == 1 & enrl_dual_02 == 1 & enrl_dual_03 == 1 & enrl_dual_04 == 1 & enrl_dual_05 == 1 & enrl_dual_06 == 1 & enrl_dual_07 == 1 & enrl_dual_08 == 1 & enrl_dual_09 == 1 & enrl_dual_10 == 1 & enrl_dual_11 == 1 & enrl_dual_12 == 1)
		keep if (enrl_cstshr_01 == 1 & enrl_cstshr_02 == 1 & enrl_cstshr_03 == 1 & enrl_cstshr_04 == 1 & enrl_cstshr_05 == 1 & enrl_cstshr_06 == 1 & enrl_cstshr_07 == 1 & enrl_cstshr_08 == 1 & enrl_cstshr_09 == 1 & enrl_cstshr_10 == 1 & enrl_cstshr_11 == 1 & enrl_cstshr_12 == 1)

		foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {	
			drop enrl_d_`t' enrl_dual_`t' dual_`t' enrl_cstshr_`t' cstshr`t'
		}
		
		drop dual_mo
		
	}
	
	rename rfrnc_yr year
	rename state_cd state_code
	rename cnty_cd county_code
			
	foreach var in state_code county_code bene_zip sex race age {
		cap destring `var', replace force
	}	
	
        save ../temp/LIS_20pct_`year', replace		
	}
	
   clear
   forv year = 2007/2015 {
        append using ../temp/LIS_20pct_`year', force
    }
    
   merge m:1 state_code using ${states}, assert(1 2 3) keep(3) keepusing(*) nogen
   
	bys bene_id pdp_region: gen c=1 if _n==1
	bys bene_id: egen number_of_regions=total(c)
	gen mover=number_of_regions>1 & number_of_regions!=.
	tab mover
	drop c number_of_regions
	keep if mover == 0
   
   save ../temp/prelim_sample_mcr_20pct_raw_LIS65_07_15, replace
   
end

*Program for selecting RD sample
program select_rd_samp

	use ../temp/prelim_sample_mcr_20pct_raw_LIS65_07_15, clear
	
	tab year
	rename pdp_region region_code 
	rename year yr

	*Merge in encrypted plan information for January
	rename cntrct01 contract_id_encrypted
	rename pbpid01 plan_id_encrypted 
	rename sgmtid01 segment_id_encrypted 
	
	merge m:1 contract_id_encrypted plan_id_encrypted segment_id_encrypted yr using ${ptd_bnch}/CrossWalkEncrypted.dta
	tab yr _merge
	tab contract_id_encrypted if _merge == 1 & yr >= 2008 & yr <= 2012 //most of the nonmatch is due to contract01 = 0 or N
	drop if _merge == 2
	drop _merge
	
	rename contract_id cntrct01
	rename plan_id pbpid01
	rename segment_id sgmtid01
	replace cntrct01 = contract_id_encrypted if (yr == 2007 | yr >= 2013)
	replace pbpid01 = plan_id_encrypted if (yr == 2007 | yr >= 2013)
	replace sgmtid01 = segment_id_encrypted if (yr == 2007 | yr >= 2013)
	drop contract_id_encrypted plan_id_encrypted segment_id_encrypted
	
	*Merge in encrypted plan information for December		
	rename cntrct12 contract_id_encrypted
	rename pbpid12 plan_id_encrypted 
	rename sgmtid12 segment_id_encrypted 
	merge m:1 contract_id_encrypted plan_id_encrypted segment_id_encrypted yr using ${ptd_bnch}/CrossWalkEncrypted.dta
	tab yr _merge
	tab contract_id_encrypted if _merge == 1 & yr >= 2008 & yr <= 2012 //most of the nonmatch is due to contract12 = 0 or N
	drop if _merge == 2
	drop _merge
	replace contract_id = contract_id_encrypted if (yr == 2007 | yr >= 2013)
	replace plan_id = plan_id_encrypted if (yr == 2007 | yr >= 2013)
	replace segment_id = segment_id_encrypted if (yr == 2007 | yr >= 2013)
	drop contract_id_encrypted plan_id_encrypted segment_id_encrypted

	*Merge in running variables			
	merge m:1 contract_id plan_id segment_id region_code yr using ${ptd_bnch}/PlansRunningPrem.dta	
	save ../temp/prelim_sample_mcr_20pct_raw_LIS65_07_15_bnch, replace
	
	tab yr _merge 
	drop if _merge == 2
	gen in_bnch = (_merge == 3)
	bysort bene_id (yr): egen in_bnch_tot = total(in_bnch)
	tab in_bnch_tot
	drop if in_bnch_tot == 0
	save ../temp/prelim_sample_mcr_20pct_raw_LIS65_07_15_inbnch, replace

	*Get plan enrollment information for both years and make sure that all sample selection requirements are met for both years	
	bysort bene_id (yr): gen contract_next = cntrct01[_n+1]
	bysort bene_id (yr): gen plan_next = pbpid01[_n+1]
	bysort bene_id (yr): gen segment_next = sgmtid01[_n+1]
	bysort bene_id (yr): gen region_next = region_code[_n+1]
	bysort bene_id (yr): gen yr_next = yr[_n+1]
		
	tab yr if yr_next == .
	drop if yr_next == .
	keep if in_bnch == 1
	keep if yr_next - yr == 1
	keep if region_code == region_next
	keep if contract_id != "0" & contract_id != "N" & contract_id != "" & contract_next != "0" & contract_next != "N" & contract_next != ""
	keep if plan_id != "0" & plan_id != "N" & plan_id != "" & plan_next != "0" & plan_next != "N" & plan_next != ""
	keep if segment_id != "0" & segment_id != "N" & segment_id != "" & segment_next != "0" & segment_next != "N" & segment_next != ""

	*Create indicators for whether stay in the same plan 	
	gen same_contract = contract_id == contract_next
	tab same_contract
	gen same_plan = plan_id == plan_next
	tab same_plan
	gen same_segment = segment_id == segment_next
	tab same_segment
	gen stay = (same_contract == 1 & same_plan == 1 & same_segment == 1)
	tab stay
	
	keep bene_id yr state_code county_code bene_zip age bene_dob death_dt sex race contract_id contract_next plan_id plan_next segment_id segment_next state_name region_code lose_benchmark running same_contract same_plan same_segment stay
	rename yr ref_year
	save ../temp/ptd_LIS65_20pct_samp_prep.dta, replace
		
	use ../temp/ptd_LIS65_20pct_samp_prep.dta, clear

	*Merge in active choice indicators
	merge 1:m bene_id ref_year contract_id plan_id using ../temp/elc_actv_ind, keep(3) nogen
	
	bysort bene_id ref_year (enrlmt_efctv_dt): egen yr_dup = count(ref_year)
	tab yr_dup
	bysort bene_id ref_year (enrlmt_efctv_dt): gen last = (_n == _N)
	tab last
	keep if last == 1
	drop last yr_dup
	
	foreach x in ref_year contract_id plan_id enrlmt_efctv_dt enrlmt_type_cd type_actv_ind type_auto_ind type_reasgn_ind type_oth_ind enrl_mo {
		rename `x' `x'_Dec
	}

	gen ref_year = ref_year_Dec + 1
	rename contract_next contract_id
	rename plan_next plan_id

	*Merge in active choice indicators for next January
	merge 1:m bene_id ref_year contract_id plan_id using ../temp/elc_actv_ind, keep(3) nogen
	save ../output/ptd_LIS65_20pct_samp.dta, replace

	*Consolidate plan and choice information for year T and T+1
	bysort bene_id ref_year (enrlmt_efctv_dt): egen yr_dup = count(ref_year)
	tab yr_dup
	bysort bene_id ref_year (enrlmt_efctv_dt): gen first = (_n == 1)
	tab first
	tab enrl_mo if first == 1
	keep if first == 1
	drop first yr_dup
	
	foreach x in ref_year contract_id plan_id enrlmt_efctv_dt enrlmt_type_cd type_actv_ind type_auto_ind type_reasgn_ind type_oth_ind enrl_mo {
		rename `x' `x'_Jan
	}

	gen ref_year = ref_year_Jan - 1
	assert ref_year == ref_year_Dec
	drop ref_year_Dec ref_year_Jan
	
	save ../output/ptd_LIS65_20pct_samp.dta, replace

	*More detailed choice information	
	tab enrlmt_type_cd_Dec type_actv_ind_Dec
	tab enrlmt_type_cd_Jan type_actv_ind_Jan
	tab enrlmt_type_cd_Jan stay
	
	gen switch = 1 - stay
	tab enrlmt_type_cd_Jan switch
	
	foreach x in stay switch {
		gen `x'_actv = `x' == 1 & type_actv_ind_Jan == 1
		tab `x'_actv
		gen `x'_auto = `x' == 1 & type_auto_ind_Jan == 1
		tab `x'_auto
		gen `x'_reasgn = `x' == 1 & type_reasgn_ind_Jan == 1
		tab `x'_reasgn
		gen `x'_oth = `x' == 1 & type_oth_ind_Jan == 1
		tab `x'_oth
}	
	save ../output/ptd_LIS65_20pct_samp.dta, replace	
	
	*Drop problematic cases	
	merge m:1 bene_id using ${ptd_bnch}/ListtoDropMay2019.dta
	drop if _merge == 2
	tab ref_year _merge
	tab type_actv_ind_Jan _merge
	tab type_actv_ind_Dec _merge
	
	drop if _merge == 3
	rename _merge ListtoDrop
	save ../output/ptd_LIS65_20pct_samp.dta, replace	
		
	keep bene_id ref_year	
	gen ref_year_next = ref_year + 1
	save ../output/ptd_LIS65_20pct_samp_bene_id.dta, replace	
	

end



*Execute
prelim_medicare
select_rd_samp

log close
