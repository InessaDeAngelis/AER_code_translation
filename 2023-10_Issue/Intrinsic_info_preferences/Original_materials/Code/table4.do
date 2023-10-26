use "$root/Data/Output/IQdata.dta", clear

gen top_most = certain_info==1
gen top_pos = pos_skew==1
gen top_neg = neg_skew==1
gen top_noinfo =  no_info==1


********************************************************************************
* Table 4*
* Avoiders and Non-avoiders
********************************************************************************
** pos skew > neg. skew (preference, which is the inverse of rank)
gen pos_neg = 0
replace pos_neg = 1 if pos_skew < neg_skew

** pos skew > most skew (preference, which is the inverse of rank)
gen pos_full = 0
replace pos_full = 1 if pos_skew < certain_info

** neg skew > most skew (preference, which is the inverse of rank)
gen neg_full = 0
replace neg_full = 1 if neg_skew < certain_info

*------------------------------------------------------------------------------*
// Label variables (to be used in excel replication)
label var top_most "Most Info. Ranked Best"
label var top_pos "Pos. Skew Ranked Best"
label var top_neg "Neg. Skew Ranked Best"
label var top_noinfo "No Info. Ranked Best"

label var pos_neg "Pos. Skew > Neg. Skew"
label var pos_full "Pos. Skew > Most Info"
label var neg_full "Neg. Skew > Most Info"

 

putexcel set table4, replace
// headings
	putexcel A1=("") B1=("Avoiders") C1=("Takers")
	putexcel A2=("") B2=("(No Info. > Most Info.)") C2=("(Most Info. > No Info.)")
	

local row = 3
foreach var of varlist top_most top_pos top_neg top_noinfo pos_neg pos_full neg_full {
	tabstat `var' , by(avoid) stat(mean) save
	local avoid = round(r(Stat2)[1,1]*100, 0.1)
	local taker = round(r(Stat1)[1,1]*100, 0.1)
	local lab: variable label `var'
	putexcel A`row' =("`lab'") B`row'=("`avoid'%") C`row'=("`taker'%") 
	local row = `row' + 1 
	if "`var'" == "top_noinfo" local row = `row' + 1
	
}

putexcel save


