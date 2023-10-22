*Program takes sample of initial Medicare enrollees, then plots the trend of cumulative active choice status up to five years after initial enrollment.

*Final products: 
*actv_national_mcr_samp_5yr_connected.eps;
*actv_national_mcr_samp_5yr_connected_ME_NH.eps

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
log using ../output/fig_1.log, replace

program mcr_samp_actv
	*Take sample of initial Medicare enrollees that was generated previously
	*Merge in active choice status for the first five years of enrollment
	use ../temp/prelim_sample_mcr_slct_06_12, clear
	keep if yr_seq == 1
	merge 1:1 bene_id using ../output/elc_actv_5yr_upd, keep(1 3)
	tab year _merge
	keep if _merge == 3
	
	rename chooser_init actv_0_0mth
	
	keep bene_id state_name sex bene_dob elig_mo_yr enrl_mo_yr_gen enrl_mo_yr_d enrl_mo_yr_nonhmo enrl_mo_yr_qual year actv_0* actv_0_60mth_sum actv_ind_tot_cnt 

	*Active choice distribution
	unique bene_id
	
	tab actv_ind_tot_cnt
	unique bene_id if actv_ind_tot_cnt > 0
	egen actv_ind_tot_cnt_sum = total(actv_ind_tot_cnt)
	tab actv_ind_tot_cnt_sum
	
	preserve
	gen actv_ind_tot_cnt_grp = actv_ind_tot_cnt
	replace actv_ind_tot_cnt_grp = 5 if actv_ind_tot_cnt > 5
	tab actv_ind_tot_cnt_grp
	gen bene_cnt = 1
	collapse (sum) bene_cnt actv_ind_tot_cnt, by(actv_ind_tot_cnt_grp)
	export delimited ../output/tables/actv_ind_tot_cnt.csv, replace
	restore
	
	save ../output/actv_secondary_samp_5yr.dta, replace
		
	*Cumulative active choice over time
	keep bene_id state_name sex actv_0*
	forvalues t = 0(12)60 {
		rename actv_0_`t'mth actv`t'
	}
	reshape long actv, i(bene_id state_name) j(mth)
	
	*Figure 1A
	*For national sample
	preserve
	collapse (mean) actv, by(mth)

	export delimited ../output/tables/actv_national_mcr_samp_5yr.csv, replace
	
	twoway (connected actv mth), graphregion(color(white)) title("Active Choice Propensity") xla(0(12)60) xtitle("Months after Initial Enrollment") ytitle("Active Choice") yla(0(0.2)0.8)
	graph export ../output/graphs/actv_national_mcr_samp_5yr_connected.eps, replace
	restore

	
end

*Execute

mcr_samp_actv

log close
