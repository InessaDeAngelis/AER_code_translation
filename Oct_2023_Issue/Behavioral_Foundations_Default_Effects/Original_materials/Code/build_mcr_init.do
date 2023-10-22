*This do file takes the raw Medicare data and create national sample of beneficiaries for their initial enrollment in Medicare


*Final products: 
*prelim_sample_mcr_annotate_06_12.dta;
*prelim_sample_mcr_slct_06_12.dta; 

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
log using ../output/build_mcr_fig_1.log, replace

*Program selecting preliminary sample
program prelim_medicare
    forv year = 2006/2012 {
	disp "`year'"
	
	*Get 20% sample indicator
        use bene_id using ${bsfab_20pct}/bsfab`year', clear
        duplicates drop
        save ../temp/sample_list_20pct_`year', replace
	
	if `year' < 2015 {
		use bene_id rfrnc_yr orec crec state_cd cnty_cd bene_zip sex race age bene_dob death_dt a_mo_cnt b_mo_cnt buyin* hmo* using ${bsfab}/bsfab`year', clear
	
		*Keep cohorts who turn 65 in 2007 - 2010
		keep if bene_dob >= td(01jan1942) & bene_dob < td(01jan1946)
*		keep if orec == "0"

		*A small number of duplicated observations in bsfab, keeping all of them for now
		bysort bene_id: egen dupcnt = count(rfrnc_yr)
		tab dupcnt

		merge m:1 bene_id using ${bsfd}/bsfd`year', assert(2 3) keep(3) keepusing(dual* cntrct* cstshr* plncovmo) nogen
	}
	
	if `year' == 2015 {
		use bene_id rfrnc_yr orec crec state_cd cnty_cd zip_cd sex race age bene_dob death_dt a_mo_cnt b_mo_cnt buyin* hmo* using ${bsfab}/bsfab`year', clear
		rename zip_cd bene_zip	
	
		*Keep cohorts who turn 65 in 2007 - 2010
		keep if bene_dob >= td(01jan1942) & bene_dob < td(01jan1946)
*		keep if orec == "0"

		bysort bene_id: egen dupcnt = count(rfrnc_yr)
		tab dupcnt

		merge m:1 bene_id using ${bsfd}/bsfd`year', assert(2 3) keep(3) keepusing(dual* ptdcntrct* cstshr* ptd_mo) nogen		

		foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {
			rename ptdcntrct`t' cntrct`t'
		}
		rename ptd_mo plncovmo	
	}
	
        merge m:1 bene_id using ../temp/sample_list_20pct_`year', assert (1 2 3) keep(1 3) keepusing(*) gen(in_20pct_sample)
        recode in_20pct_sample 1=0 3=1
        label define in_20pct_sample 0 "0" 1 "1"
        label values in_20pct_sample in_20pct_sample
	
	rename rfrnc_yr year
	rename state_cd state_code
	rename cnty_cd county_code
			
	foreach var in state_code county_code bene_zip sex race age a_mo_cnt b_mo_cnt buyin_mo hmo_mo plncovmo dual_mo {
		cap destring `var', replace force
	}	
	
        save ../temp/`year', replace		
	}
	
   clear
   forv year = 2006/2012 {
        append using ../temp/`year', force
    }
    
   merge m:1 state_code using ${states}, assert(1 2 3) keep(3) keepusing(*) nogen
   
   save ../temp/prelim_sample_mcr_raw_06_12, replace

end

*Program for selecting secondary sample (national Medicare initial enrollment sample)
program select_mcr_samp

	use ../temp/prelim_sample_mcr_raw_06_12, clear

	*drop obs for sure after first year of enrollment
	keep if year <= yofd(bene_dob) + 67 

	*indicator for non-MA enrollment in Part A, B & D AND dual-eligible AND LIS beneficiary
	foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {
		gen enrl_a_only_`t' = (buyin`t' == "1" | buyin`t' == "A")
		gen enrl_b_only_`t' = (buyin`t' == "2" | buyin`t' == "B")
		gen enrl_ab_`t' = (buyin`t' == "3" | buyin`t' == "C")
		gen enrl_non_`t' = buyin`t' == "0"
		gen enrl_d_`t' = (cntrct`t' != "" & cntrct`t' != "N" & cntrct`t' != "0" & cntrct`t' != "*" & cntrct`t' != "X")
		gen enrl_dual_`t' = (dual_`t' != "" & dual_`t' != "**" & dual_`t' != "00" & dual_`t' != "09" & dual_`t' != "99" & dual_`t' != "NA" & dual_`t' != "XX")
		gen enrl_cstshr_`t' = (cstshr`t' == "01" | cstshr`t' == "02" | cstshr`t' == "03")
	
		gen enrl_nonhmo_`t' = ((buyin`t' == "3" | buyin`t' == "C") & ///
			(cntrct`t' != "" & cntrct`t' != "N" & cntrct`t' != "0" & cntrct`t' != "*" & cntrct`t' != "X") & ///
			(hmoind`t' == "0"))
		gen enrl_qual_`t' = (enrl_nonhmo_`t' == 1 & ///
			(dual_`t' != "" & dual_`t' != "**" & dual_`t' != "00" & dual_`t' != "09" & dual_`t' != "99" & dual_`t' != "NA" & dual_`t' != "XX") & ///
			(cstshr`t' == "01" | cstshr`t' == "02" | cstshr`t' == "03"))
		gen enrl_gen_`t' = (buyin`t' != "0")
	}	
	
	foreach x in gen d nonhmo qual {
		gen enrl_`x'_mo = 0
		foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {
			replace enrl_`x'_mo = enrl_`x'_mo + enrl_`x'_`t'
		}
		tab enrl_`x'_mo
	}	
	
	*sanity check
	tab year if enrl_nonhmo_mo == 0 & hmo_mo == 0 & plncovmo != 0 & plncovmo != . & a_mo_cnt != 0 & b_mo_cnt != 0
	tab year if enrl_qual_mo == 0 & buyin_mo != . & buyin_mo != 0 & dual_mo != . & dual_mo != 0 & hmo_mo == 0 & plncovmo != 0 & plncovmo != . & a_mo_cnt != 0 & b_mo_cnt != 0

	tab a_mo_cnt if enrl_qual_mo == 12
	tab b_mo_cnt if enrl_qual_mo == 12
	tab plncovmo if enrl_qual_mo == 12
	tab hmo_mo if enrl_qual_mo == 12
	tab dual_mo if enrl_qual_mo == 12
	tab buyin_mo if enrl_qual_mo == 12
				
	*get month of first general and first qualified Medicare enrollment
	bysort bene_id (year): gen yr_1st_gen = year[1]	
	
	gen enrl_qual_nz = (enrl_qual_mo != 0)
	bysort bene_id: egen enrl_qual_nz_sum = total(enrl_qual_nz)
	gen enrl_qual_nz_ind = (enrl_qual_nz_sum != 0)
	tab enrl_qual_nz_ind

	drop if enrl_qual_nz_ind == 0	//drop individuals with no qualified Medicare enrollment in all time periods
	drop enrl_qual_nz_ind enrl_qual_nz_sum	

	*year of first enrollment by type
	foreach x in d nonhmo qual {
		cap gen enrl_`x'_nz = (enrl_`x'_mo != 0)
		bysort bene_id enrl_`x'_nz (year): gen yr_1st_`x'_nz = year[1]
		replace yr_1st_`x'_nz = . if enrl_`x'_nz ==  0
		bysort bene_id (year): egen yr_1st_`x' = min(yr_1st_`x'_nz)
		drop yr_1st_`x'_nz enrl_`x'_nz
	}
	
	*month of first enrollment by type
	foreach x in gen d nonhmo qual {
		gen enrl_`x'_mo_cum = 0
		gen mo_1st_01_`x' = 1 if (enrl_`x'_01 == 1)
	
		forv t = 2/9  {
			local t_1 = `t'- 1
			local 0t_1  0`t_1'
			local 0t 0`t'
			replace enrl_`x'_mo_cum = enrl_`x'_mo_cum + enrl_`x'_`0t_1'
			
			gen mo_1st_`0t'_`x' = `t' if (enrl_`x'_mo_cum == 0 & enrl_`x'_`0t' == 1)
		}	
	
		replace enrl_`x'_mo_cum = enrl_`x'_mo_cum + enrl_`x'_09
		
		gen mo_1st_10_`x' = 10 if (enrl_`x'_mo_cum == 0 & enrl_`x'_10 == 1)
	
		forv t = 11/12 {
			local t_1 = `t'- 1
			replace enrl_`x'_mo_cum = enrl_`x'_mo_cum + enrl_`x'_`t_1'
			
			gen mo_1st_`t'_`x' = `t' if (enrl_`x'_mo_cum == 0 & enrl_`x'_`t' == 1)
		}
		mvencode(mo_1st_*), mv(0)
	
		gen mo_1st_`x' = 0
		foreach t in 01 02 03 04 05 06 07 08 09 10 11 12 {
			replace mo_1st_`x' = mo_1st_`x' + mo_1st_`t'_`x'
		}
		tab mo_1st_`x' if enrl_`x'_mo != 0
	
		gen enrl_mo_yr_1st_`x' = ym(yr_1st_`x',mo_1st_`x') if year == yr_1st_`x'
		format enrl_mo_yr_1st_`x' %tm
		bysort bene_id (year): egen enrl_mo_yr_`x' = mean(enrl_mo_yr_1st_`x')
		format enrl_mo_yr_`x' %tm

		rename mo_1st_`x' `x'_mo_1st
		drop mo_1st*
		drop enrl_mo_yr_1st_`x'
	}	
	
	gen elig_mo_yr = ym(yofd(bene_dob) + 65, month(bene_dob))
	format elig_mo_yr %tm

	save ../temp/prelim_sample_mcr_annotate_06_12, replace	

	preserve 
	keep if year >= 2006 & year <= 2012
	bysort bene_id year: egen yr_dup = count(year)
	tab yr_dup
	keep if (state_code == 33 | state_code == 45)
	save ../temp/prelim_sample_mcr_annotate_nytx_06_12, replace
	restore


	*keep individuals who fulfill requirement
	
	drop if enrl_qual_mo == 0
	
	tab orec crec
	
	*Drop those who did not "age into" Medicare	
	drop if yr_1st_gen < yofd(bene_dob) + 64
	bysort bene_id (year): gen yr_2nd = year[2]

	*Keep those enrolled in Medicare within initial enrollment window around becoming eligible at age 65
	keep if (enrl_mo_yr_qual - elig_mo_yr <= 3 & enrl_mo_yr_qual - elig_mo_yr >= -3)
	keep if (enrl_mo_yr_gen - elig_mo_yr <= 3 & enrl_mo_yr_gen - elig_mo_yr >= -3)

	tab orec crec

	*Keep those with first 12 months of consecutive Medicare enrollment that meet the sample selection criteria upon initial enrollment
	bysort bene_id (year): gen yr_seq = _n
	tab yr_seq
	drop if yr_seq >= 3
	
	bysort bene_id (year): egen yr_cnt = count(year)
	tab yr_cnt
	tab year if yr_cnt == 1
	drop if yr_cnt == 1
	drop yr_cnt
	
	gen gap_ind = (yr_2nd != yr_1st_gen + 1)
	drop if gap_ind == 1
	drop gap_ind
	
	gen keep_ind_yr1 = (enrl_qual_mo == 12 - qual_mo_1st + 1) if yr_seq == 1
	tab keep_ind_yr1
	
	gen keep_ind_yr2 = enrl_qual_mo == 12 if yr_seq == 2
	tab keep_ind_yr2
	count if keep_ind_yr2 == 0 & a_mo_cnt == 12 & b_mo_cnt == 12 & hmo_mo == 0 & plncovmo == 12 & dual_mo == 12 //mostly due to dual indicator taking the value 09
	
	bysort bene_id (year): egen keep_yr1 = mean(keep_ind_yr1)
	bysort bene_id (year): egen keep_yr2 = mean(keep_ind_yr2)
	gen keep_yr1_yr2 = (keep_yr1 == 1 & keep_yr2 == 1)
	tab keep_yr1_yr2
	keep if (keep_yr1 == 1 & keep_yr2 == 1)
	drop keep_yr1_yr2 keep_yr1 keep_yr2
	
	tab orec crec

	tab dupcnt
	
	*Keep those who stayed in the same region 	
	bys bene_id pdp_region: gen c=1 if _n==1
	bys bene_id: egen number_of_regions=total(c)
	gen mover=number_of_regions>1 & number_of_regions!=.
	tab mover
	drop c number_of_regions
	keep if mover == 0

	count if enrl_mo_yr_qual != enrl_mo_yr_gen

	tab orec crec
	
	save ../temp/prelim_sample_mcr_slct_06_12, replace	

end


*Execute
prelim_medicare
select_mcr_samp

log close
