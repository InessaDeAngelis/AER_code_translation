cd "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/"

*Purpose: This file identifies the universe of individuals whose active choice status was potentially tained in the data, due to data error that CMS made in 2007 for certain individuals that propagated in future years.

**This list is used in separate files as a sample exclusion criteria.

use "/disk/agedisk3/medicare.work/duggan-DUA51935/extracts/elc/2007/lis2007.dta", clear
**keep if lis_months == 12
keep bene_id reassign_jan chooser
sort bene_id
save LIS_Pop, replace
keep if reassign_jan == "Y"
duplicates drop bene_id, force
keep bene_id 
save ListtoDropMay2019, replace
**
