*This do file takes raw Medicaid data and identifies beneficiaries in NY&TX who were enrolled in Medicaid due to disability (and not in Medicare) before turning 65.
*Final product: prelim_sample_mcd_dblt_noMCR.dta

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

cap log close
log using ../output/build_mcd.log, replace

*Program selecting individuals who satisfies requirement for 12 months prior to month-year
program select_12mth_before
   args var month year
   
   gen `var'_stct = (`month' == 1 & ref_year == `year' - 1 & `var'_1 == 1 & `var'_2 == 1 & `var'_3 == 1 & `var'_4 == 1 & `var'_5 == 1 & `var'_6 == 1 & `var'_7 == 1 & `var'_8 == 1 & `var'_9 == 1 & `var'_10 == 1 & `var'_11 == 1 & `var'_12 == 1)
   
   forvalues t = 2/12 {
	disp "month = `t'"
	local cutoff = `t' - 1
	gen count = 0
	forvalues i = 1/`cutoff' {
		disp "m`i' same year"
		replace count = count + `var'_`i' if `month' == `t' & ref_year == `year'
	}
	replace `var'_stct = 1 if (count == `cutoff') & `month' == `t' & ref_year == `year'

	forvalues i = `t'/12 {
		disp "m`i' last year"
		replace count = count + `var'_`i' if `month' == `t' & ref_year == `year' - 1	
	}
	replace `var'_stct = 1 if (count == 12 - `t' + 1) & `month' == `t' & ref_year == `year' - 1
	
	drop count 
	
}	
	
bysort bene_id_mcd: egen `var'_stct_sum = total(`var'_stct)
tab `var'_stct_sum
tab `var'_stct_sum if `month' == 1
tab `var'_stct_sum if `month' > 1 & `month' != .

drop if (`var'_stct_sum < 1 & `month' == 1) | (`var'_stct_sum < 2 & `month' > 1)

unique bene_id_mcd

end


*Program selecting preliminary Medicaid sample
program prelim_medicaid
    forv year = 2006/2010 {
	disp "`year'"

	*New York
	use ${mcdps}/ny/NY_PS_`year'_new.dta, clear
	rename *, lower
	tab max_yr_dt
	
	*Select individuals who turned 65 in our Medicare sample period (thus were aged 64 in the Medicaid sample period, before aging into Medicare)
	if `year' == 2010 {
		gen el_dob_num = date(el_dob,"DMY")
		drop el_dob
		rename el_dob_num el_dob
	}	
	
	gen el_yob = yofd(el_dob)
	count if (el_yob >= 1942 & el_yob <= 1945)
	tab el_yob
	
	count if bene_id == ""
	tab el_age_grp_cd if bene_id == ""	
	tab el_age_grp_cd	
		
	keep if ((el_yob >= 1942 & el_yob <= 1945) | el_yob == .)
	
	keep bene_id state_cd max_yr_dt el_dob el_age_grp_cd el_sex_cd el_race_ethncy_cd el_dod mdcr_dod ///
		el_rsdnc_cnty_cd_ltst el_rsdnc_zip_cd_ltst el_max_elgblty_cd_ltst el_elgblty_mo_cnt ///
		el_mdcr_ben_mo_cnt mdcr_orig_reas_cd el_mdcr_dual_mo_* max_elg_cd_mo_* el_mdcr_ben_mo_* el_days_el_cnt_*
	
	save ../temp/`year'_NY_mcd, replace
	
	*Texas
	use ${mcdps}/tx/maxdata_tx_ps_`year'.dta, clear
	rename *, lower
	tab max_yr_dt

	*Select individuals who turned 65 in our Medicare sample period (thus were aged 64 in the Medicaid sample period, before aging into Medicare)	
	gen el_yob = yofd(el_dob)
	count if (el_yob >= 1942 & el_yob <= 1945)
	tab el_yob
	
	count if bene_id == ""
	tab el_age_grp_cd if bene_id == ""
	tab el_age_grp_cd	
		
	keep if ((el_yob >= 1942 & el_yob <= 1945) | el_yob == .)

	keep bene_id state_cd max_yr_dt el_dob el_yob el_age_grp_cd el_sex_cd el_race_ethncy_cd el_dod mdcr_dod ///
		el_rsdnc_cnty_cd_ltst el_rsdnc_zip_cd_ltst el_max_elgblty_cd_ltst el_elgblty_mo_cnt ///
		el_mdcr_ben_mo_cnt mdcr_orig_reas_cd el_mdcr_dual_mo_* max_elg_cd_mo_* el_mdcr_ben_mo_* el_days_el_cnt_*
	
	save ../temp/`year'_TX_mcd, replace
	}
	   
    clear
	
    forv year = 2006/2010 {
        append using ../temp/`year'_NY_mcd, force
        append using ../temp/`year'_TX_mcd, force	
    }
       
   save ../temp/prelim_sample_mcd, replace
   
   *Get Medicare and Medicaid beneficiary ID crosswalk
   rename bene_id bene_id_25543
   merge m:1 bene_id_25543 using ${mcr_mcd_xwk}/bene_bene_xwalk, keep(1 3)
   rename bene_id_25543 bene_id_mcd
   rename bene_id_16702 bene_id_mcr
   tab max_yr_dt if _merge == 1
   tab max_yr_dt if _merge == 1 & bene_id_mcd != ""
   drop if bene_id_mcd == ""
   drop _merge
   rename max_yr_dt ref_year
   format ref_year %ty

   *Get month when beneficiary became eligible for Medicare
   gen el_elig_mo = month(el_dob)
   gen el_elig_yr = yofd(el_dob) + 65
   gen el_elig_mo_yr = ym(el_elig_yr, el_elig_mo)
   format el_elig_mo_yr %tm
   tab el_elig_mo_yr
   
   *Get indicators for whether beneficiary was in Medicaid due to disability
   forvalues t = 1/12 {
	gen dblt_`t' = (max_elg_cd_mo_`t' == "12" | max_elg_cd_mo_`t' == "22" | max_elg_cd_mo_`t' == "32" | max_elg_cd_mo_`t' == "42" | max_elg_cd_mo_`t' == "52")
   }	
    
   save ../temp/prelim_sample_mcd, replace

end

*Program selecting NY&TX disabled sample
program select_disability

   use ../temp/prelim_sample_mcd, clear
   
   *Keep those who became eligible for Medicare during sample period
   tab ref_year
   tab el_elig_mo_yr
   keep if (el_elig_mo_yr >= tm(2007m1) & el_elig_mo_yr <= tm(2010m12))
   tab el_elig_mo_yr
  
   *Drop duplicates
   bysort bene_id_mcd el_dob: gen dob_seq = (_n == 1)
   bysort bene_id_mcd: egen dob_dup = total(dob_seq)
   tab dob_dup
   drop if dob_dup != 1
   drop dob_seq dob_dup
  
   duplicates drop
   bysort bene_id_mcd ref_year: egen yr_dup = count(ref_year)
   replace yr_dup = yr_dup - 1
   bysort bene_id_mcd: egen yr_dup_tot = total(yr_dup)
   tab yr_dup_tot
   drop if yr_dup_tot != 0
   drop yr_dup yr_dup_tot
  
   *Select individuals who satisfied sample selection criteria for 12 months prior to becoming eligible for Medicare (program defined above)
   select_12mth_before dblt el_elig_mo el_elig_yr

tab el_max_elgblty_cd_ltst if ref_year >= el_elig_yr - 1
tab el_max_elgblty_cd_ltst if ref_year == el_elig_yr - 1
tab el_max_elgblty_cd_ltst if ref_year >= el_elig_yr

unique bene_id_mcd

save ../temp/prelim_sample_mcd_dblt, replace

end

	
*Program selecting NY&TX disabled sample with no MCR in the 12 months before turning 65
program select_disability_noMCR

   use ../temp/prelim_sample_mcd_dblt, clear

   forvalues t = 1/12 {
	gen el_noMCR_`t' = (el_mdcr_ben_mo_`t' == 0)
   }	

   select_12mth_before el_noMCR el_elig_mo el_elig_yr
   
   tab el_mdcr_ben_mo_cnt if ref_year >= el_elig_yr - 1
   tab el_mdcr_ben_mo_cnt if ref_year == el_elig_yr - 1
   tab el_mdcr_ben_mo_cnt if ref_year >= el_elig_yr
   unique bene_id_mcd
   
   save ../temp/prelim_sample_mcd_dblt_noMCR, replace

end


*Execute
prelim_medicaid
select_disability
select_disability_noMCR

log close

