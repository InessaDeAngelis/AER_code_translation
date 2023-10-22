*This do file builds the  20% LIS sample for dual-eligible beneficiaries aged 65+ (to create column 1 of Table 1 summary stats); not limited just to random assignees or those in benchmark plans
*Final product: LIS_summ_stats_samp_simp.dta

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
log using ../ouput/build_summary_stats_sample.log, replace

*Select the broad LIS sample

    forv year = 2007/2015 {
	disp "`year'"

	*Get 20% sample indicator
        use bene_id using ${bsfab_20pct}/bsfab`year', clear
        duplicates drop
        save ../temp/sample_list_20pct_`year', replace	
	
	if `year' < 2015 {
	
		use bene_id rfrnc_yr sex race age bene_dob death_dt buyin* hmo* using ${bsfab}/bsfab`year', clear
	
		*Keep those aged 65+
		keep if rfrnc_yr - yofd(bene_dob) >= 65 

		*A small number of duplicated observations in bsfab, keeping all of them for now
		bysort bene_id: egen dupcnt = count(rfrnc_yr)
		tab dupcnt

		merge m:1 bene_id using ${bsfd}/bsfd`year', assert(2 3) keep(3) keepusing(dual* cntrct* cstshr*) nogen		
		
	*Generate indicator for non-MA enrollment in Part A, B & D AND dual-eligible AND LIS beneficiary
	foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {	
		gen enrl_nonhmo_`t' = ((buyin`t' == "3" | buyin`t' == "C") & ///
			(cntrct`t' != "" & cntrct`t' != "N" & cntrct`t' != "0" & cntrct`t' != "*" & cntrct`t' != "X") & ///
			(hmoind`t' == "0"))
		gen enrl_qual_`t' = (enrl_nonhmo_`t' == 1 & ///
			(dual_`t' != "" & dual_`t' != "**" & dual_`t' != "00" & dual_`t' != "09" & dual_`t' != "99" & dual_`t' != "NA" & dual_`t' != "XX") & ///
			(cstshr`t' == "01" | cstshr`t' == "02" | cstshr`t' == "03"))
	}
	
	*Keep if all enrollment requirements are satisfied for all 12 months of the year
	foreach x in nonhmo qual {
		gen enrl_`x'_mo = 0
		foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {
			replace enrl_`x'_mo = enrl_`x'_mo + enrl_`x'_`t'
		}
		tab enrl_`x'_mo
	}	
	
	keep if enrl_qual_mo == 12
			
	}
	
	if `year' == 2015 {
		use bene_id rfrnc_yr sex race age bene_dob death_dt buyin* hmo* using ${bsfab}/bsfab`year', clear

		*A small number of duplicated observations in bsfab, keeping all of them for now
		
		bysort bene_id: egen dupcnt = count(rfrnc_yr)
		tab dupcnt

		merge m:1 bene_id using ${bsfd}/bsfd`year', assert(2 3) keep(3) keepusing(dual* ptdcntrct* cstshr*) nogen		
		
		foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {
			rename ptdcntrct`t' cntrct`t'
		}
		
		*Keep those aged 65+
		keep if rfrnc_yr - yofd(bene_dob) >= 65 

	*Generate indicator for non-MA enrollment in Part A, B & D AND dual-eligible AND LIS beneficiary
	foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {	
		gen enrl_nonhmo_`t' = ((buyin`t' == "3" | buyin`t' == "C") & ///
			(cntrct`t' != "" & cntrct`t' != "N" & cntrct`t' != "0" & cntrct`t' != "*" & cntrct`t' != "X") & ///
			(hmoind`t' == "0"))
		gen enrl_qual_`t' = (enrl_nonhmo_`t' == 1 & ///
			(dual_`t' != "" & dual_`t' != "**" & dual_`t' != "00" & dual_`t' != "09" & dual_`t' != "99" & dual_`t' != "NA" & dual_`t' != "XX") & ///
			(cstshr`t' == "01" | cstshr`t' == "02" | cstshr`t' == "03"))
	}
	
	*Keep if all enrollment requirements are satisfied for all 12 months of the year	
	foreach x in nonhmo qual {
		gen enrl_`x'_mo = 0
		foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {
			replace enrl_`x'_mo = enrl_`x'_mo + enrl_`x'_`t'
		}
		tab enrl_`x'_mo
	}	
	
	keep if enrl_qual_mo == 12
		
	}

	*Merge in the 20% indicator
        merge m:1 bene_id using ../temp/sample_list_20pct_`year', assert (1 2 3) keep(1 3) keepusing(*) gen(in_20pct_sample)
        recode in_20pct_sample 1=0 3=1
        label define in_20pct_sample 0 "0" 1 "1"
        label values in_20pct_sample in_20pct_sample	
	
	rename rfrnc_yr year
			
	foreach var in sex race age {
		cap destring `var', replace force
	}	
	
        save ../temp/LIS_summ_stats_samp`year', replace		
	}
	
   *Append all years together	
   clear
   forv year = 2007/2015 {
        append using ../temp/LIS_summ_stats_samp`year', force
    }
       
   save ../output/LIS_summ_stats_samp, replace
   
   keep bene_id year age bene_dob death_dt sex race dupcnt in_20pct_sample
   tab dupcnt
   keep if dupcnt == 1
   unique bene_id year
   
   tab in_20pct_sample
   
   gen female = (sex == 2)
   tab female
   
   gen obs = 1

   save ../output/LIS_summ_stats_samp_simp, replace
  
log close
