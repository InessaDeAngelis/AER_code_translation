*This do file plots premiums in year t-1 against premiums in year t for all plans in our data that existed in consecutive year pairs.
*Final product: premium_binscatter.eps


**Appendix figure A4

*for testing code interactively
cd "/disk/homedirs/adywang-dua51935/duggan-DUA51935/adywang-dua51935/svn/trunk/derived/part_d_behavioral_all/submission/code/"

clear all
set more off
set maxvar 20000

cap log close
log using ../output/premium_transit_fig_a2.log, replace text

adopath + ../../../../lib/ado/

use "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/PlansRunningPrem_FullUniv_Aug2020.dta", clear

count if missing(running) == 1
count if missing(pre_running) == 1

drop if missing(running) == 1

binscatter running pre_running, graphregion(color(white)) xtitle("Premium - Benchmark in t-1") ytitle("Premium - Benchmark in t")
graph export "../output/graphs/premium_binscatter.eps", replace

log close
