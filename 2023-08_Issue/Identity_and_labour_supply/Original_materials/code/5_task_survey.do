* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* PROJECT:			Does identity affect labor supply?
* RESEARCHER:		Suanna Oh
* TASK:				Analyze task survey data
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*					<< Sections >>
* 
*		1.  Generate variables for analysis
*		2.  Table 1: Caste associations with tasks
*		2.  Table A2: Task associations and experiences
*		3.  Table A9: Experiences with tasks
*		4.  Figure A3: Caste-sensitive opinions of oneself vs. others
* 		
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Generate variables for analysis
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


use "$path/data/task_survey.dta", clear


/* NOTES: task names (numbering is different from exp vars)

f2_1_make_peanut_shelling
f2_2_make_leaf_mat 
f2_3_make_stick_broom 
f2_4_make_bamboo_mat 
f2_5_make_grass_mat 
f2_6_make_leaf_broom 
f2_7_make_wick 
f2_8_make_paper_bag 
f2_9_make_incense_stick 
f2_10_make_rope 
f2_11_make_wash_cloth 
f2_12_make_cln_latrine 
f2_13_make_rpr_leather 
f2_14_make_stich_thrd 
f2_15_make_cln_agri_tool 
f2_16_make_cln_anml_shed

Washing clothes : 2
Washing farming tools : 3
Mending leather shoes : 4
Mending grass mats : 5
Sweeping latrines : 6
Sweeping animal sheds : 7
Making paper bags : 8 
Deshelling peanuts : 9
Making ropes : 10
Stitching : 11
Making leaf mats : 12
Making leaf brooms : 13
Making bamboo mats : 14
Making stick brooms : 15
Making incense sticks : 16
Making candle wicks : 17 
*/


** task association

local k=1
foreach x in peanut_shelling leaf_mat stick_broom bamboo_mat grass_mat leaf_broom wick paper_bag incense_stick rope wash_cloth cln_latrine rpr_leather stich_thrd cln_agri_tool cln_anml_shed{
	gen f2_task`k'_men=f2_`k'_make_`x'==1  
	gen f2_task`k'_women=f2_`k'_make_`x'==2 
	gen f2_task`k'_both=f2_`k'_make_`x'==3 
	gen f2_task`k'_dk=f2_`k'_make_`x'==-98 

	gen f4_task`k'_caste=f4_`k'_caste_`x'==1 // if f4_`k'_caste_`x'>-100
	gen f4_task`k'_sc=0
	replace f4_task`k'_sc=1 if regexm(f4_`k'_caste_`x'_oth,"TANLA") | regexm(f4_`k'_caste_`x'_oth,"BHOI") | regexm(f4_`k'_caste_`x'_oth,"DUMA") | regexm(f4_`k'_caste_`x'_oth,"KAIBARTA") | regexm(f4_`k'_caste_`x'_oth,"PANA")
	replace f4_task`k'_sc=1 if regexm(f4_`k'_caste_`x'_oth,"MOCHI") | regexm(f4_`k'_caste_`x'_oth,"DHOBA") | regexm(f4_`k'_caste_`x'_oth,"DAMA") | regexm(f4_`k'_caste_`x'_oth,"HADI") | regexm(f4_`k'_caste_`x'_oth,"BAURI") | regexm(f4_`k'_caste_`x'_oth,"SAHAR")
	replace f4_task`k'_sc=1 if regexm(f4_`k'_caste_`x'_oth,"GOKHA") | regexm(f4_`k'_caste_`x'_oth,"KANDARA")
	local `k++'
}


gen f4_task5_mochi=0
replace f4_task5_mochi=1 if regexm(f4_5_caste_grass_mat_oth,"MOCHI") 
gen f4_task15_dhoba=0
gen f4_task16_hadi=0

gen f4_task11_dhoba=0
replace f4_task11_dhoba=1 if regexm(f4_11_caste_wash_cloth_oth,"DHOBA") 
gen f4_task13_mochi=0
replace f4_task13_mochi=1 if regexm(f4_13_caste_rpr_leather_oth,"MOCHI") 
gen f4_task12_hadi=0
replace f4_task12_hadi=1 if regexm(f4_12_caste_cln_latrine_oth,"HADI")

foreach x of varlist f*_*_perf*_oth{
	cap confirm numeric variable `x'
	if !_rc drop `x'
}


** experience with tasks
local var2_a "f5_11_perfm_wash_cloth1"
local var2_b "f5_11_perfm_wash_cloth2 f5_11_perfm_wash_cloth3"
local var3_a "f5_15_perfm_cln_agri_tool1"
local var3_b "f5_15_perfm_cln_agri_tool2 f5_15_perfm_cln_agri_tool3"
local var4_a "f5_13_perfm_rpr_leather"
local var4_b ""
local var5_a "f5_5_perfm_grass_mat1"
local var5_b "f5_5_perfm_grass_mat2"
local var6_a "f5_12_perfm_cln_latrine1"
local var6_b "f5_12_perfm_cln_latrine2 f5_12_perfm_cln_latrine3"
local var7_a "f5_16_perfm_cln_anml_shed1"
local var7_b "f5_16_perfm_cln_anml_shed2"
local var8_a "f5_8_perfm_paper_bag"
local var8_b ""
local var9_a "f5_1_perfm_peanut_shelling1"
local var9_b "f5_1_perfm_peanut_shelling2"
local var10_a "f5_10_perfm_rope"
local var10_b "f5_10_perfm_rope"
local var11_a "f5_14_perfm_stich_thrd1"
local var11_b "f5_14_perfm_stich_thrd2"
local var12_a "f5_2_perfm_leaf_mat"
local var12_b ""
local var13_a "f5_6_perfm_leaf_broom1"
local var13_b "f5_6_perfm_leaf_broom2"
local var14_a "f5_4_perfm_bamboo_mat1"
local var14_b "f5_4_perfm_bamboo_mat2 f5_4_perfm_bamboo_mat3"
local var15_a "f5_3_perfm_stick_broom1"
local var15_b "f5_3_perfm_stick_broom2"
local var16_a "f5_9_perfm_incense_stick1" 
local var16_b "f5_9_perfm_incense_stick2"
local var17_a "f5_7_perfm_wick1"
local var17_b "f5_7_perfm_wick2"

foreach i of numlist 2/17{
	egen neverperf`i' = anymatch(`var`i'_a' `var`i'_b'), values(1) 
	egen ownhhperf`i' = anymatch(`var`i'_a' `var`i'_b'), values(2)
	egen friendperf`i' = anymatch(`var`i'_a' `var`i'_b'), values(3)
	egen villageperf`i' = anymatch(`var`i'_a' `var`i'_b'), values(4)
	egen wageperf`i' = anymatch(`var`i'_a' `var`i'_b'), values(5)
	egen outhhperf`i' = anymatch(`var`i'_a' `var`i'_b'), values(3 4)
	egen nonwageperf`i' = anymatch(`var`i'_a' `var`i'_b'), values(2 3 4)
	
	foreach x of varlist neverperf`i' ownhhperf`i' friendperf`i' villageperf`i' wageperf`i' outhhperf`i' nonwageperf`i'{
		replace `x'=. if mi(`var`i'_a') | `var`i'_a'<0
	}
	
	gen perf`i'=1-neverperf`i' if !mi(neverperf`i')
}


** opinions on caste norms

gen story1a=inlist(g1a_sameer_jena,4,5) if g1a_sameer_jena>0
replace story1a=inlist(g1b_friend_neigh,4,5) if g1b_friend_neigh>0
gen story2a=inlist(g2a_tukuna_naika,4,5) if g2a_tukuna_naika>0
replace story2a=inlist(g2b_friend_neigh,4,5) if g2b_friend_neigh>0
gen story3a=inlist(g3a_santhi,4,5) if g3a_santhi>0
replace story3a=inlist(g3b_friend_neigh,4,5) if g3b_friend_neigh>0
gen story4a=inlist(g4a_gagan_dalai,4,5) if g4a_gagan_dalai>0
replace story4a=inlist(g4b_friend_neigh,4,5) if g4b_friend_neigh>0



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table 1: Caste associations with tasks
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


summ f4_task11_dhoba f4_task13_mochi f4_task12_hadi			// identity tasks association with dhoba, mochi, and hadi
summ f4_task15_dhoba f4_task5_mochi f4_task16_hadi 			// paired tasks assocation with dhoba, mochi, and hadi
summ f4_task15_sc f4_task5_sc f4_task16_sc					// paired tasks assocation with any SC

// Enter the results into Table 1: tab_ranking


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table A2: Task associations and experiences
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


preserve

gen for_men=.
gen for_women=.
gen both=.
gen dont_know=.
gen caste_specific=.
gen sc_specific=.
gen perf_sum=.
gen neverperf_sum=.
gen ownhhperf_sum=.
gen outhhperf_sum=.
gen wageperf_sum=.

local k=1
foreach x of numlist 11 15 13 5 12 16 8 1 10 14 2 6 4 3 9 7{
	local `k++'
	sum f2_task`x'_men 
	replace for_men=r(mean) if _n==`k'
	sum f2_task`x'_women 
	replace for_women=r(mean) if _n==`k'
	sum f2_task`x'_both 
	replace both=r(mean) if _n==`k'
	sum f2_task`x'_dk 
	replace dont_know=r(mean) if _n==`k'
	sum f4_task`x'_caste
	replace caste_specific=r(mean) if _n==`k'
	sum f4_task`x'_sc
	replace sc_specific=r(mean) if _n==`k'		
}

foreach x of numlist 2/17{
	sum ownhhperf`x'
	replace ownhhperf_sum=r(mean) if _n==`x'
	sum outhhperf`x'
	replace outhhperf_sum=r(mean) if _n==`x'
	sum wageperf`x'
	replace wageperf_sum=r(mean) if _n==`x'	
	sum perf`x'
	replace perf_sum=r(mean) if _n==`x'
}
  
drop if _n==1
keep caste_specific sc_specific for_men for_women both ownhhperf_sum outhhperf_sum wageperf_sum perf_sum
gen taskname = ""
replace taskname="Washing clothes" if _n==1
replace taskname="Washing farming tools" if _n==2
replace taskname="Mending leather shoes" if _n==3
replace taskname="Mending grass mats" if _n==4
replace taskname="Sweeping latrines" if _n==5
replace taskname="Sweeping animal sheds" if _n==6
replace taskname="Making paper bags" if _n==7
replace taskname="Deshelling peanuts" if _n==8
replace taskname="Making ropes" if _n==9
replace taskname="Stitching" if _n==10
replace taskname="Making leaf mats" if _n==11
replace taskname="Making leaf brooms" if _n==12
replace taskname="Making bamboo mats" if _n==13
replace taskname="Making stick brooms" if _n==14
replace taskname="Making incense sticks" if _n==15
replace taskname="Making candle wicks" if _n==16
order taskname caste_specific sc_specific for_men for_women both ownhhperf_sum outhhperf_sum wageperf_sum perf_sum

// Enter the data into Table A2: tab_task_info_edit
	
restore


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table A9: Experiences with tasks
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


preserve

reshape long neverperf ownhhperf friendperf villageperf wageperf outhhperf nonwageperf perf, i(pid) j(task)

egen tag_pid=tag(pid)
egen pidtask=group(pid task)

// level for the main castes 
gen int castelev=7 if c2_caste_code==38		// hadi
replace castelev=6 if c2_caste_code==67 	// pana
replace castelev=3 if c2_caste_code==28 	// dhoba
replace castelev=1 if c2_caste_code==42 	// kaibarta

gen expcaste = inlist(c2_caste_code,38,67,28,42)==1				// castes in experiment

// assigned levels based on the ranking survey
replace castelev=6 if c2_caste_code==17 | c2_caste_code==45 	// bauri and kandara
replace castelev=4 if c2_caste_code==35                     	// gokha
replace castelev=1 if inlist(c2_caste_code,24,21,76)==1     	// brahman, bhoi, and tanla
gen direct_ranked=1 if !mi(castelev)
gen caste=c2_caste_code

// level for tasks
gen int tasklev = 0
replace tasklev = 3 if task==2 | task==3
replace tasklev = 5 if task==4 | task==5
replace tasklev = 7 if task==6 | task==7

gen int identity = task==2 | task==4 | task==6
gen int pairedcont = task==3 | task==5 | task==7 
gen int purecont = task==8 | task==9 | task==10 | task==11

gen exptask= (inrange(task,2,7)) 								// tasks in experiment

gen int sametask = 0 if exptask==1
replace sametask = 1 if tasklev == castelev & !mi(tasklev) & !mi(castelev)

gen int diftask = 0 if exptask==1
replace diftask = 1 if tasklev != castelev & !mi(tasklev) & !mi(castelev) & exptask==1

gen int lowertask = 0 if exptask==1
replace lowertask =1 if diftask==1 & castelev<tasklev & !mi(tasklev) & !mi(castelev) & exptask==1 // task is lower (higher level #) than the caste


foreach x of varlist lowertask sametask diftask {
	gen iden_`x'=identity*`x'
}


label var identity "Identity tasks"
label var lowertask "Lower tasks"
label var iden_lowertask "Lower $\times$ Identity"
label var sametask "Associated task"
label var iden_sametask "Associated $\times$ Identity"
label var diftask "Different tasks"
label var iden_diftask "Different $\times$ Identity"
label var neverperf "Never performed"
label var ownhhperf "Performed for own household"
label var friendperf "Performed for friend/family"
label var villageperf "Performed in village"
label var wageperf "Performed for wage"
label var nonwageperf "Performed without wage"
label var outhhperf "Performed outside household"
label var perf "Ever performed"
label var purecont "Pure control tasks"



eststo clear

foreach x of varlist ownhhperf outhhperf wageperf perf{

eststo: reg `x' iden_lowertask lowertask iden_diftask diftask i.task i.caste if exptask==1 & direct_ranked==1, cl(pid)
	estadd local hold ""
	estadd local fe "Task, Caste"
	qui sum `x' if sametask==1 & iden_sametask==0 & exptask==1 & direct_ranked==1
	estadd scalar depmean1=r(mean)
	qui sum `x' if iden_sametask==1 & exptask==1 & direct_ranked==1
	estadd scalar depmean2=r(mean)	
eststo: areg `x' iden_lowertask lowertask iden_diftask diftask i.task if exptask==1 & direct_ranked==1, absorb(pid) cl(pid)
	estadd local hold ""
	estadd local fe "Task, Worker"
	qui sum `x' if sametask==1 & iden_sametask==0 & exptask==1 & direct_ranked==1
	estadd scalar depmean1=r(mean)
	qui sum `x' if iden_sametask==1 & exptask==1 & direct_ranked==1
	estadd scalar depmean2=r(mean)

}

#delimit ;
esttab using "$path/output/tab_experience.tex", replace
	b(3) se booktabs nostar nonotes nomtitles label style(tex) gaps 
	keep(iden_diftask iden_lowertask diftask lowertask)
	order(iden_diftask iden_lowertask diftask lowertask)
	stats(hold depmean2 depmean1 fe N, labels("Mean for same-ranked tasks" "\hspace{0.4cm} Identity tasks" "\hspace{0.4cm} Control tasks" "Fixed effects included" "Observations") 
	fmt(%20s %9.3fc %9.3fc %20s %9.0fc))
	prehead("\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} 
	\begin{tabular}     
	{@{\extracolsep{4pt}}p{5.1cm}*{8}{>{\centering\arraybackslash}m{1.7cm}}@{}} 			        
	\toprule
	&\multicolumn{2}{c}{In own household} &  \multicolumn{2}{c}{Outside household}  &  \multicolumn{2}{c}{For wage}  &\multicolumn{2}{c}{Ever performed} \\
	\cline{2-3} \cline{4-5} \cline{6-7} \cline{8-9} \addlinespace ");
#delimit cr


restore



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Figure A3: Caste-sensitive opinions of oneself vs. others
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


preserve

collapse (mean) mean1=story1a mean2=story2a mean3=story3a mean4=story4a  ///
	(sd) sd1=story1a sd2=story2a sd3=story3a sd4=story4a ///
	(count) n1=story1a n2=story2a n3=story3a n4=story4a, by(versionA)

gen cat=_n
reshape long mean sd n, i(cat)
rename _j order2

gen order=order2*3-2 if versionA==1
replace order=order2*3-1 if versionA==0

gen barlabel=mean 
format %12.2f barlabel 

generate hiz = mean + 1.96*(sd / sqrt(n))
generate loz = mean - 1.96*(sd / sqrt(n))

gen order3 = order + 0.02
gen mean3 = mean + 0.005

#delimit ;

twoway (bar mean order if versionA==1 , color("245 171 41") fintensity(inten100) barwidth(.7))
		(bar mean order if versionA==0, color("120 33 82") fintensity(inten70) barwidth(.7))
       (rcap hiz loz order, lwidth(medium) lcolor(black)) 
	   (scatter mean3 order3, msym(none) mlab(barlabel) mlabpos(2) mlabcolor(black) mlabsize(small)), 
	   ytitle("Share of respondents")
       xtitle("") xlabel(1.5 `" "Take a lower caste job" "(barber)" "' 4.5 "Serve food to higher castes" 7.5 "Marry a lower caste man" 10.5 `" "Take a lower caste job" "(sewer cleaner)" "', noticks nogrid) 
	   graphregion(color(white)) title("")
	   legend(lab(1 "Own opinion") lab(2 "Others' opinion") size(small) order(1 2) col(2) pos(6) region(lcolor(white)));
	   
graph export "$path/output/fig_opinion.pdf", replace;

restore


