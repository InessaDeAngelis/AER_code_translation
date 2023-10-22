cd "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/nun_ndc/code"

*Generate count of unique drugs each bene was taking in each calendar year

forval yr = 2008/2014 {
use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/raw/medicare_part_d_pde/data/opt1pde`yr'.dta", clear
duplicates drop bene_id prdsrvid, force
gen ndc_count = 1
collapse (sum) ndc_count, by(bene_id)
gen yr = `yr'
 save ../temp/ndccount`yr', replace
 
 }
 
 clear
 forval yr = 2007/2014 {
 append using ../temp/ndccount`yr'
 }
 tab yr
 replace yr = 2007 if yr == .
 save ../output/drugcount_all, replace
 
