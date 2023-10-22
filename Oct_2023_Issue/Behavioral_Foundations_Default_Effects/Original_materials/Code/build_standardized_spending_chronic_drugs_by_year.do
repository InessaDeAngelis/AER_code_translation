*This do file takes the raw Part D spending data and creates spending variables by drug characteristics.
*Input into analyses looking at impacts, by subtype of drug spending rather than just overall
*Final products: 
*opt1pde_2007_2015_standard_spend_gen_by_year.dta; 
*opt1pde_spending_by_chronic.dta;
*opt1pde_spending_by_chronic_by_month.dta

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
log using "../output/build_standardized_spending_chronic_drugs_by_year.log", replace

******
*Standardized spending

use "$redbook/redbook.dta", clear
rename ndcnum prdsrvid
keep prdsrvid thercls thrclds genind gnindds
destring genind, gen(gencat)
tab gencat
save "../temp/redbook_simp.dta", replace

*Generate price-normalized drug spending
forvalues t = 2007/2015 {

	use bene_id prdsrvid srvc_dt totalcst dayssply using "$ptd_event/opt1pde`t'.dta", clear
	gen dayssply_30_less = (dayssply <= 30)
	gen srvc_qtr = qofd(srvc_dt)
	format srvc_qtr %tq
	merge m:1 prdsrvid using "../temp/redbook_simp.dta", keep(1 3)
	drop _merge
	save "../temp/opt1pde`t'_simp.dta", replace

	drop if prdsrvid == ""

	*Get mean prices for drugs of different plans, classes, generic status, and days of supply
	bysort prdsrvid dayssply_30_less: egen standardizedplanspend = mean(totalcst)
	replace standardizedplanspend = totalcst if missing(standardizedplanspend) == 1

	bysort thercls dayssply_30_less: egen standardizedclassspend = mean(totalcst)
	replace standardizedclassspend = totalcst if (missing(thercls) == 1 | thercls == 999)
	
	bysort thercls gencat dayssply_30_less: egen standardclassgenspend = mean(totalcst)
	replace standardclassgenspend = standardizedclassspend if (missing(gencat) == 1 | gencat == 7)
	replace standardclassgenspend = totalcst if (missing(thercls) == 1 | thercls == 999)
	
	save "../temp/opt1pde`t'_simp_info_gen.dta", replace
	
	*Get total price-normalized drug spending for each person-quarter
	collapse (sum) standardizedplanspend standardizedclassspend standardclassgenspend, by(bene_id srvc_qtr)
	save "../output/opt1pde`t'_standard_spend_gen.dta", replace	
}

clear all
forvalues t = 2007/2015 {
	append using "../output/opt1pde`t'_standard_spend_gen.dta"
}
save "../output/opt1pde_2007_2015_standard_spend_gen_by_year.dta", replace

******
*Chronic drugs

clear all
forvalues t = 2007/2015 {
	
	*Get the total # of fills of a drug for each person-year among those with at least one annual fill	
	use "../temp/opt1pde`t'_simp.dta", clear
	drop if prdsrvid == ""
	
	gen fill = 1
	collapse (sum) fill, by(prdsrvid bene_id)
	save "../temp/opt1pde`t'_ndc_fill_per_person.dta", replace
	
	*Classify a drug as chronic drug if the median # of annual fills among all patients is greater than 2
	collapse (median) fill, by(prdsrvid)
	sum fill, det
	count if missing(fill) == 1
	
	gen chronic_drug = (fill > 2)
	tab chronic_drug
	
	gen year = `t'
	rename fill fill_median
	save "../temp/opt1pde`t'_ndc_fill_per_person_median.dta", replace
	
}

clear all
forvalues t = 2007/2015 {
	append using "../temp/opt1pde`t'_ndc_fill_per_person_median.dta"
}

save "../output/opt1pde_chronic_drugs.dta", replace

*Create spending variables by whether drug is classified as chronic drug.
forvalues t = 2007/2015 {
	use "../temp/opt1pde`t'_simp.dta", clear
	drop if prdsrvid == ""
	merge m:1 prdsrvid using "../temp/opt1pde`t'_ndc_fill_per_person_median.dta", assert (3) keep(3)
	save "../temp/opt1pde`t'_simp_chronic.dta", replace
	
	collapse (sum) totalcst, by(bene_id srvc_qtr chronic_drug)
	reshape wide totalcst, i(bene_id srvc_qtr) j(chronic_drug)
	
	rename totalcst0 nonchronicspend
	rename totalcst1 chronicspend
	mvencode nonchronicspend chronicspend, mv(0) override

	save "../temp/opt1pde`t'_simp_spending_by_chronic.dta", replace	
}

clear all
forvalues t = 2007/2015 {
	append using "../temp/opt1pde`t'_simp_spending_by_chronic.dta"
}

save "../output/opt1pde_spending_by_chronic.dta", replace

*Collapse at monthly level instead
forvalues t = 2007/2015 {
	use "../temp/opt1pde`t'_simp_chronic.dta", clear
	gen srvc_mo = mofd(srvc_dt)
	format srvc_mo %tm
	
	collapse (sum) totalcst, by(bene_id srvc_mo chronic_drug)
	reshape wide totalcst, i(bene_id srvc_mo) j(chronic_drug)

	rename totalcst0 nonchronicspend
	rename totalcst1 chronicspend
	mvencode nonchronicspend chronicspend, mv(0) override

	save "../temp/opt1pde`t'_simp_spending_by_chronic_by_month.dta", replace		
}
	
clear all
forvalues t = 2007/2015 {
	append using "../temp/opt1pde`t'_simp_spending_by_chronic_by_month.dta"
}

gen year = yofd(dofm(srvc_mo))

save "../output/opt1pde_spending_by_chronic_by_month.dta", replace
	
log close

