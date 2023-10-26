* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* PROJECT:			Does Identity Affect Labor Supply?
* RESEARCHER:		Suanna Oh
* DATE:				October 2022
* TASK:				Analyze the main experiment data
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*					<< Sections >>
* 
*		1.  Figure 1. Willingness to take up job offers and caste associations
*		2.  Figure 2: Willingness to take-up by task
*		3.  Figure 3: Reasons for turning down job offers
*		4.  Table 2: Identity inconsistency and job offer take-up
*		5.	Table 3: Role of social image concerns
*		6.  Table A3: Summary of worker characteristics
*		7.  Table A4: Job take-up results with alternate specifications
*		8.  Table A5: Job take-up results using alternate rankings
*		9.  Table A6: Completion rates of actually selected offers
*		10.  Table A7: Heterogeneity in job offer take-up
*		11. Permutation test
* 		
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Fig 1. Willingness to take up job offers and caste associations
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


use "$path/data/choice_jobtakeup_analysis.dta", clear 

egen tag_time = tag(timecat)

gen iden_1 = . 		// associated task
replace iden_1 = takeup if task==2 & caste==3
replace iden_1 = takeup if task==4 & caste==5
replace iden_1 = takeup if task==6 & caste==7

gen iden_2 = . 		// higher task
replace iden_2 = takeup if task==2 & caste>3
replace iden_2 = takeup if task==4 & caste>5

gen iden_3 = . 		// lower task
replace iden_3 = takeup if task==2 & caste<3
replace iden_3 = takeup if task==4 & caste<5
replace iden_3 = takeup if task==6 & caste<7

gen cont_1 = . 		// associated task
replace cont_1 = takeup if task==3 & caste==3
replace cont_1 = takeup if task==5 & caste==5
replace cont_1 = takeup if task==7 & caste==7

gen cont_2 = . 		// higher task
replace cont_2 = takeup if task==3 & caste>3
replace cont_2 = takeup if task==5 & caste>5

gen cont_3 = . 		// lower task
replace cont_3 = takeup if task==3 & caste<3
replace cont_3 = takeup if task==5 & caste<5
replace cont_3 = takeup if task==7 & caste<7


foreach x of varlist iden_1 iden_2 iden_3 cont_1 cont_2 cont_3 {
	bys timecat: egen `x'_m = mean(`x')
}

gen timecat2=timecat==2
gen timecat3=timecat==3
gen timecat4=timecat==4

gen highertask2 = highertask==1 & timecat==2
gen highertask3 = highertask==1 & timecat==3
gen highertask4 = highertask==1 & timecat==4

gen lowertask2 = lowertask==1 & timecat==2
gen lowertask3 = lowertask==1 & timecat==3
gen lowertask4 = lowertask==1 & timecat==4

xi: reg takeup timecat2 timecat3 timecat4 highertask highertask2 highertask3 highertask4 lowertask lowertask2 lowertask3 lowertask4 if identity==1, cluster(pid)

gen iden_1_se = _se[_cons] if timecat==1
replace iden_1_se = _se[timecat2] if timecat==2
replace iden_1_se = _se[timecat3] if timecat==3
replace iden_1_se = _se[timecat4] if timecat==4

gen iden_2_se = _se[highertask] if timecat==1
replace iden_2_se = _se[highertask2] if timecat==2
replace iden_2_se = _se[highertask3] if timecat==3
replace iden_2_se = _se[highertask4] if timecat==4

gen iden_3_se = _se[lowertask] if timecat==1
replace iden_3_se = _se[lowertask2] if timecat==2
replace iden_3_se = _se[lowertask3] if timecat==3
replace iden_3_se = _se[lowertask4] if timecat==4

gen iden_1_u = iden_1_m + 1.96*iden_1_se
gen iden_1_l = iden_1_m - 1.96*iden_1_se
gen iden_2_u = iden_2_m + 1.96*iden_2_se
gen iden_2_l = iden_2_m - 1.96*iden_2_se
gen iden_3_u = iden_3_m + 1.96*iden_3_se
gen iden_3_l = iden_3_m - 1.96*iden_3_se


xi: reg takeup timecat2 timecat3 timecat4 highertask highertask2 highertask3 highertask4 lowertask lowertask2 lowertask3 lowertask4 if pairedcont==1, cluster(pid)

gen cont_1_se = _se[_cons] if timecat==1
replace cont_1_se = _se[timecat2] if timecat==2
replace cont_1_se = _se[timecat3] if timecat==3
replace cont_1_se = _se[timecat4] if timecat==4

gen cont_2_se = _se[highertask] if timecat==1
replace cont_2_se = _se[highertask2] if timecat==2
replace cont_2_se = _se[highertask3] if timecat==3
replace cont_2_se = _se[highertask4] if timecat==4

gen cont_3_se = _se[lowertask] if timecat==1
replace cont_3_se = _se[lowertask2] if timecat==2
replace cont_3_se = _se[lowertask3] if timecat==3
replace cont_3_se = _se[lowertask4] if timecat==4


gen cont_1_u = cont_1_m + 1.96*cont_1_se
gen cont_1_l = cont_1_m - 1.96*cont_1_se
gen cont_2_u = cont_2_m + 1.96*cont_2_se
gen cont_2_l = cont_2_m - 1.96*cont_2_se
gen cont_3_u = cont_3_m + 1.96*cont_3_se
gen cont_3_l = cont_3_m - 1.96*cont_3_se

#delimit ;

twoway (rarea iden_1_u iden_1_l timemin if tag_time==1, color(gs14) fintensity(inten100))
	(rarea iden_2_u iden_2_l timemin if tag_time==1, color(gs14) fintensity(inten100))
	(rarea iden_3_u iden_3_l timemin if tag_time==1, color(gs14) fintensity(inten100))
		(connected iden_1_m timemin if tag_time==1, color(blue*0.75) lwidth(medthick) msymbol(O) msize(medlarge))
		(connected iden_2_m timemin if tag_time==1, color(green*0.75) lwidth(medthick) msymbol(T) msize(medlarge))
		(connected iden_3_m timemin if tag_time==1, color(red*0.75) lwidth(medthick) msymbol(S) msize(medlarge)), 
		legend(off) yscale(range(0 1)) ylabel(#6, labsize(medlarge)) xlabel(,nogrid labsize(medlarge)) graphregion(color(white)) title("Identity tasks", size(huge)) 
		ytitle("Take-up rate", size(vlarge)) xtitle("Time in minutes", size(vlarge));
graph display, xsize(5.1);
graph export "$path/output/fig_iden_ci.pdf", replace;


twoway (rarea cont_1_u cont_1_l timemin if tag_time==1, color(gs14) fintensity(inten100))
	(rarea cont_2_u cont_2_l timemin if tag_time==1, color(gs14) fintensity(inten100))
	(rarea cont_3_u cont_3_l timemin if tag_time==1, color(gs14) fintensity(inten100))
		(connected cont_1_m timemin if tag_time==1, color(blue*0.75) lwidth(medthick) msymbol(O) msize(medlarge))
		(connected cont_2_m timemin if tag_time==1, color(green*0.75) lwidth(medthick) msymbol(T) msize(medlarge))
		(connected cont_3_m timemin if tag_time==1, color(red*0.75) lwidth(medthick) msymbol(S) msize(medlarge)), 
		legend(off) yscale(range(0 1)) ylabel(#6, labsize(medlarge)) xlabel(,nogrid labsize(medlarge)) graphregion(color(white)) title("Paired control tasks", size(huge)) 
		ytitle("Take-up rate", size(vlarge)) xtitle("Time in minutes", size(vlarge)) ;
graph display, xsize(5.1);
graph export "$path/output/fig_cont_ci.pdf", replace;

#delimit cr



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Figure 2: Willingness to take-up by task
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


use "$path/data/choice_jobtakeup_wide.dta", clear 


gen castelev = 4 if caste==7					 	
replace castelev=3 if caste==5 | caste==6			
replace castelev=2 if caste==3 | caste==4
replace castelev=1 if caste==2 | caste==1


egen tag_castelev_t=tag(castelev timecat)
egen tag_time = tag(timecat)



foreach x of varlist deshell rope stitching {
	bys castelev timecat: egen `x'_level = mean(`x')
}


foreach x of varlist wash_clothes wash_agri {
	gen `x'_temp1 = `x' if caste!=3
	bys castelev timecat: egen `x'_level = mean(`x'_temp1)
	gen `x'_temp2 = `x' if caste==3
	bys timecat: egen `x'_same = mean(`x'_temp2)
	drop *temp1 *temp2
}


foreach x of varlist shoe_repair grass_mat{
	gen `x'_temp1 = `x' if caste!=5
	bys castelev timecat: egen `x'_level = mean(`x'_temp1)
	gen `x'_temp2 = `x' if caste==5
	bys timecat: egen `x'_same = mean(`x'_temp2)
	drop *temp1 *temp2
}

foreach x of varlist latrine animal_shed{
	gen `x'_temp1 = `x' if caste!=7
	bys castelev timecat: egen `x'_level = mean(`x'_temp1)
	gen `x'_temp2 = `x' if caste==7
	bys timecat: egen `x'_same = mean(`x'_temp2)
	drop *temp1 *temp2
}


#delimit ;
foreach x in wash_clothes wash_agri{ ;
	local varlab: variable label `x' ;

	twoway (connected `x'_level timemin if castelev==1 & tag_castelev_t==1, color(red) lwidth(medthick) lpattern(shortdash) msymbol(o) msize(medlarge)) 
		(connected `x'_level timemin if castelev==2 & tag_castelev_t==1, color(orange) lwidth(medthick) msymbol(t) msize(medlarge)) 
		(connected `x'_level timemin if castelev==3 & tag_castelev_t==1, color(midblue) lwidth(medthick) msymbol(s) msize(medlarge)) 
		(connected `x'_level timemin if castelev==4 & tag_castelev_t==1, color(blue) lwidth(medthick) msymbol(d) msize(medlarge))
		(connected `x'_same timemin if tag_time==1, color(green*0.75) lwidth(medthick) msymbol(Oh) msize(medlarge)), 
		legend(off)
		yscale(range(0 1)) ylabel(#4) xlabel(,nogrid) graphregion(color(white)) title("`varlab'", size(medium)) ytitle("") xtitle("") name(`x', replace) nodraw;
};


foreach x in shoe_repair grass_mat{ ;
	local varlab: variable label `x' ;

	twoway (connected `x'_level timemin if castelev==1 & tag_castelev_t==1, color(red) lwidth(medthick) lpattern(shortdash) msymbol(o) msize(medlarge)) 
		(connected `x'_level timemin if castelev==2 & tag_castelev_t==1, color(orange) lwidth(medthick) lpattern(shortdash) msymbol(t) msize(medlarge)) 
		(connected `x'_level timemin if castelev==3 & tag_castelev_t==1, color(midblue) lwidth(medthick) msymbol(s) msize(medlarge)) 
		(connected `x'_level timemin if castelev==4 & tag_castelev_t==1, color(blue) lwidth(medthick) msymbol(d) msize(medlarge))
		(connected `x'_same timemin if tag_time==1, color(green*0.75) lwidth(medthick) msymbol(Oh) msize(medlarge)), 
		legend(off)
		yscale(range(0 1)) ylabel(#4) xlabel(,nogrid) graphregion(color(white)) title("`varlab'", size(medium)) ytitle("") xtitle("") name(`x', replace) nodraw;

};


foreach x in latrine animal_shed{ ;
	local varlab: variable label `x' ;

	twoway (connected `x'_level timemin if castelev==1 & tag_castelev_t==1, color(red) lwidth(medthick) lpattern(shortdash) msymbol(o) msize(medlarge)) 
		(connected `x'_level timemin if castelev==2 & tag_castelev_t==1, color(orange) lwidth(medthick) lpattern(shortdash) msymbol(t) msize(medlarge)) 
		(connected `x'_level timemin if castelev==3 & tag_castelev_t==1, color(midblue) lwidth(medthick) lpattern(shortdash) msymbol(s) msize(medlarge)) 
		(connected `x'_same timemin if tag_time==1, color(green*0.75) lwidth(medthick) msymbol(Oh) msize(medlarge)), 
		legend(off)
		yscale(range(0 1)) ylabel(#4) xlabel(,nogrid) graphregion(color(white)) title("`varlab'", size(medium)) ytitle("") xtitle("") name(`x', replace) nodraw;

};

foreach x in deshell rope stitching{ ;
	local varlab: variable label `x' ;

	twoway (connected `x'_level timemin if castelev==1 & tag_castelev_t==1, color(red) lwidth(medthick) msymbol(o) msize(medlarge)) 
		(connected `x'_level timemin if castelev==2 & tag_castelev_t==1, color(orange) lwidth(medthick) msymbol(t) msize(medlarge)) 
		(connected `x'_level timemin if castelev==3 & tag_castelev_t==1, color(midblue) lwidth(medthick) msymbol(s) msize(medlarge)) 
		(connected `x'_level timemin if castelev==4 & tag_castelev_t==1, color(blue) lwidth(medthick) msymbol(d) msize(medlarge)), 
		legend(off)
		yscale(range(0 1)) ylabel(#4) xlabel(,nogrid) graphregion(color(white)) title("`varlab'", size(medium)) ytitle("") xtitle("") name(`x', replace) nodraw;
};

graph combine deshell wash_agri wash_clothes rope grass_mat shoe_repair stitching animal_shed latrine, 
	col(3) graphregion(color(white) margin(l=10 r=10)) title("Pure control tasks               Paired control tasks                  Identity tasks" , size(medsmall));
graph export "$path/output/fig_combined.pdf", replace;


#delimit cr


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Figure 3: Reasons for turning down job offers
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


use "$path/data/choice_jobtakeup_analysis.dta", clear 


bys pid task: egen any_no=min(takeup)
bys pid task: egen any_yes=max(takeup)
tab any_yes agree if tag_pidtask, m 		// some inconsistency

gen all_no=any_yes==0 & agree==0			// refused to do the task and answered survey

foreach i of numlist 1/8{
	egen temp`i'=anymatch(reason1_not reason2_not reason3_not reason4_not reason5_not reason6_not), values(`i')
	gen refuse_reason`i'=temp`i'==1 if all_no==1 
	drop temp`i'
}

	egen temp9=anymatch(reason1_not reason2_not reason3_not reason4_not reason5_not reason6_not), values(-97)
	gen refuse_reason9=temp9==1 if all_no==1 
	drop temp9
	

gen refuse_iden = 0 if identity==1 & all_no==1 
replace refuse_iden = 1 if refuse_iden==0 & (refuse_reason1==1 | refuse_reason2==1 | refuse_reason3==1)

gen refuse_social = 0 if identity==1 & all_no==1 
replace refuse_social = 1 if refuse_social==0 & (refuse_reason4==1 | refuse_reason5==1)

gen refuse_skill = 0 if identity==1 & all_no==1 
replace refuse_skill = 1 if refuse_skill==0 & (refuse_reason6==1 | refuse_reason7==1 | refuse_reason8==1)


gen refuse_iden_cont = 0 if pairedcont==1 & all_no==1 
replace refuse_iden_cont = 1 if refuse_iden_cont==0 & (refuse_reason1==1 | refuse_reason2==1 | refuse_reason3==1)

gen refuse_social_cont = 0 if pairedcont==1 & all_no==1
replace refuse_social_cont = 1 if refuse_social_cont==0 & (refuse_reason4==1 | refuse_reason5==1)

gen refuse_skill_cont = 0 if pairedcont==1 & all_no==1
replace refuse_skill_cont = 1 if refuse_skill_cont==0 & (refuse_reason6==1 | refuse_reason7==1 | refuse_reason8==1)

                                          
gen reason_both = refuse_iden==1 & refuse_social==1 if tag_pidtask==1 & identity==1 & all_no==1
gen reason_onlyiden = refuse_iden==1 & refuse_social==0 if tag_pidtask==1 & identity==1 & all_no==1
gen reason_onlysocial = refuse_iden==0 & refuse_social==1 if tag_pidtask==1 & identity==1 & all_no==1
gen reason_neither = refuse_iden==0 & refuse_social==0 if tag_pidtask==1 & identity==1 & all_no==1

gen reason_both_cont = refuse_iden_cont==1 & refuse_social_cont==1 if tag_pidtask==1 & pairedcont==1 & all_no==1
gen reason_onlyiden_cont = refuse_iden_cont==1 & refuse_social_cont==0 if tag_pidtask==1 & pairedcont==1 & all_no==1
gen reason_onlysocial_cont = refuse_iden_cont==0 & refuse_social_cont==1 if tag_pidtask==1 & pairedcont==1 & all_no==1
gen reason_neither_cont = refuse_iden_cont==0 & refuse_social_cont==0 if tag_pidtask==1 & pairedcont==1 & all_no==1

tab reason_not_sfy if reason_neither==1 & tag_pidtask==1
tab reason_not_sfy if reason_neither_cont==1 & tag_pidtask==1

collapse (mean) mean1=reason_both mean2=reason_onlyiden mean3=reason_onlysocial mean4=reason_neither mean5=reason_both_cont mean6=reason_onlyiden_cont mean7=reason_onlysocial_cont mean8=reason_neither_cont ///
	(sd) sd1=reason_both sd2=reason_onlyiden sd3=reason_onlysocial sd4=reason_neither sd5=reason_both_cont sd6=reason_onlyiden_cont sd7=reason_onlysocial_cont sd8=reason_neither_cont ///
	(count) n1=reason_both n2=reason_onlyiden n3=reason_onlysocial n4=reason_neither n5=reason_both_cont n6=reason_onlyiden_cont n7=reason_onlysocial_cont n8=reason_neither_cont

gen cat=_n
reshape long mean sd n, i(cat)
rename _j order

gen identity = order<=4
replace order=order-4 if identity==0

gen order2 = order + 0.08
gen mean2 = mean + 0.02

gen barlabel=mean 
format %12.2f barlabel 

generate hiz = mean + 1.96*(sd / sqrt(n))
generate loz = mean - 1.96*(sd / sqrt(n))


#delimit ;

twoway (bar mean order if identity==0 & order==1, color(blue*0.9) barwidth(.7))
		(bar mean order if identity==0 & order==2, color(green*0.9) barwidth(.7))
		(bar mean order if identity==0 & order==3, color(red*0.9) barwidth(.7)) 
		(bar mean order if identity==0 & order==4, color(gray*0.8) barwidth(.7)) 
       (rcap hiz loz order if identity==0, lwidth(medthick) lcolor(black)) 
	   (scatter mean2 order2 if identity==0, msym(none) mlab(barlabel) mlabpos(2) mlabcolor(black) mlabsize(large)), 
	   yscale(range(0 0.65)) ylabel(0(.2)0.6, labsize(medlarge)) ytitle("Share of answers" , size(large)) legend(off)
       /*xscale(range(1 3))*/ xtitle("") xlabel(1 `" "Identity &" "social image" "' 2 `" "Identity" "only" "' 3 `" "Social" "image only""' 4 "Neither", nogrid noticks labsize(vlarge) labgap(3)) 
	   graphregion(color(white)) title("Paired control tasks", size(huge));

graph display, xsize(5.1);
graph export "$path/output/fig_reason_cont.pdf", replace;


twoway (bar mean order if identity==1 & order==1, color(blue*0.9) barwidth(.7))
		(bar mean order if identity==1 & order==2, color(green*0.9) barwidth(.7))
		(bar mean order if identity==1 & order==3, color(red*0.9) barwidth(.7)) 
		(bar mean order if identity==1 & order==4, color(gray*0.8) barwidth(.7)) 
       (rcap hiz loz order if identity==1, lwidth(medthick) lcolor(black)) 
	   (scatter mean2 order2 if identity==1, msym(none) mlab(barlabel) mlabpos(2) mlabcolor(black) mlabsize(large)), 
	   yscale(range(0 0.65)) ylabel(0(.2)0.6, labsize(medlarge)) ytitle("Share of answers" , size(large)) legend(off)
       /*xscale(range(1 3))*/ xtitle("") xlabel(1 `" "Identity &" "social image" "' 2 `" "Identity" "only" "' 3 `" "Social" "image only""' 4 "Neither", nogrid noticks labsize(vlarge) labgap(3)) 
	   graphregion(color(white)) title("Identity tasks", size(huge));
	   
graph display, xsize(5.1);
graph export "$path/output/fig_reason_iden.pdf", replace;

#delimit cr



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table 2: Identity inconsistency and job offer take-up
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 



use "$path/data/choice_jobtakeup_analysis.dta", clear 
drop if purecont==1


eststo clear
eststo: areg takeup iden_diftask iden_lowertask diftask lowertask i.task timehr, absorb(caste) cluster(pid)
	estadd local fe "Task, Caste"
	estadd local dem ""
	estadd local surv ""
	estadd local hold ""
	qui sum takeup if sametask==1 & iden_sametask==0
	estadd scalar depmean1=r(mean)
	qui sum takeup if iden_sametask==1
	estadd scalar depmean2=r(mean)	
eststo: areg takeup iden_diftask iden_lowertask diftask lowertask i.task timehr, absorb(pid) cluster(pid)
	estadd local fe "Task, Worker"
	estadd local surv ""
	estadd local dem ""
	qui sum takeup if sametask==1 & iden_sametask==0
	estadd scalar depmean1=r(mean)
	qui sum takeup if iden_sametask==1
	estadd scalar depmean2=r(mean)
eststo: areg takeup iden_diftask iden_lowertask diftask lowertask i.task timehr if survey_completed==1, absorb(pid) cluster(pid)
	estadd local fe "Task, Worker"
	estadd local surv "Yes"
	estadd local dem ""
	qui sum takeup if sametask==1 & iden_sametask==0 & survey_completed==1
	estadd scalar depmean1=r(mean)
	qui sum takeup if iden_sametask==1 & survey_completed==1
	estadd scalar depmean2=r(mean)
eststo: areg takeup iden_diftask iden_lowertask diftask lowertask i.task timehr age3-age11 year_edu3-year_edu11 wealth_pca3-wealth_pca11, absorb(pid) cluster(pid)
	estadd local fe "Task, Worker"
	estadd local surv "Yes"
	estadd local dem "Linear"
	qui sum takeup if sametask==1 & iden_sametask==0 & survey_completed==1
	estadd scalar depmean1=r(mean)
	qui sum takeup if iden_sametask==1 & survey_completed==1
	estadd scalar depmean2=r(mean)
eststo: areg takeup iden_diftask iden_lowertask diftask lowertask i.task timehr old3-old11 hiedu3-hiedu11 hiwealth3-hiwealth11, absorb(pid) cluster(pid)
	estadd local fe "Task, Worker"
	estadd local surv "Yes"
	estadd local dem "Binary"
	qui sum takeup if sametask==1 & iden_sametask==0 & survey_completed==1
	estadd scalar depmean1=r(mean)
	qui sum takeup if iden_sametask==1 & survey_completed==1
	estadd scalar depmean2=r(mean)	

#delimit ;
esttab using "$path/output/tab_takeup_main.tex", replace 
	b(3) se booktabs nostar label gaps nonotes nomtitles 
	keep(iden_diftask iden_lowertask diftask lowertask timehr)
	order(iden_diftask iden_lowertask diftask lowertask timehr)	
	stats(hold depmean2 depmean1 fe surv dem N, labels("Mean: same-ranked tasks" "\hspace{0.4cm} Identity tasks" "\hspace{0.4cm} Control tasks" "Fixed effects included" "Answered follow-up survey" "Demographic controls" "Observations") 
	fmt(%20s %9.3fc %9.3fc %20s %20s %20s %9.0fc))
	prehead( "
	\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	\begin{tabular}{l*{7}{c}}
	\toprule 
	& \multicolumn{5}{c}{\textbf{Willing to take up job offer}} \bigstrut \\
	\cline{2-6} \addlinespace");
#delimit cr




* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table 3: Role of social image concerns
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 



use "$path/data/choice_jobtakeup_analysis.dta", clear 
drop if purecont==1


eststo clear
eststo: areg takeup iden_diftask iden_lowertask diftask lowertask pub_iden_diftask pub_iden_lowertask pub_diftask pub_lowertask pub_identity public timehr i.task, absorb(caste) cluster(pid)
	estadd local fe "Task, Caste"
	estadd local dem ""
	estadd local surv ""
	estadd local hold ""
eststo: areg takeup iden_diftask iden_lowertask diftask lowertask pub_iden_diftask pub_iden_lowertask pub_diftask pub_lowertask pub_identity timehr i.task, absorb(pid) cluster(pid)
	estadd local fe "Task, Worker"
	estadd local surv ""
	estadd local dem ""
eststo: areg takeup iden_diftask iden_lowertask diftask lowertask pub_iden_diftask pub_iden_lowertask pub_diftask pub_lowertask pub_identity timehr i.task if survey_completed==1, absorb(pid) cluster(pid)
	estadd local fe "Task, Worker"
	estadd local surv "Yes"
	estadd local dem ""
eststo: areg takeup iden_diftask iden_lowertask diftask lowertask pub_iden_diftask pub_iden_lowertask pub_diftask pub_lowertask pub_identity timehr i.task age3-age11 year_edu3-year_edu11 wealth_pca3-wealth_pca11, absorb(pid) cluster(pid)
	estadd local fe "Task, Worker"
	estadd local surv "Yes"
	estadd local dem "Linear"
eststo: areg takeup iden_diftask iden_lowertask diftask lowertask pub_iden_diftask pub_iden_lowertask pub_diftask pub_lowertask pub_identity timehr i.task old3-old11 hiedu3-hiedu11 hiwealth3-hiwealth11, absorb(pid) cluster(pid)
	estadd local fe "Task, Worker"
	estadd local surv "Yes"
	estadd local dem "Binary"

#delimit ;
esttab using "$path/output/tab_social_image.tex", replace 
	b(3) se booktabs nostar label gaps nonotes nomtitles 
	keep(iden_diftask iden_lowertask pub_iden_diftask pub_iden_lowertask timehr)
	order(iden_diftask iden_lowertask pub_iden_diftask pub_iden_lowertask timehr)	
	stats(fe surv dem N, labels("Fixed effects included" "Answered follow-up survey" "Demographic controls" "Observations") 
	fmt(%20s %20s %9.0fc))
	prehead( "
	\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	\begin{tabular}{l*{7}{c}}
	\toprule 
	& \multicolumn{5}{c}{\textbf{Willing to take up job offer}} \bigstrut \\
	\cline{2-6} \addlinespace");
#delimit cr





* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table A3: Summary of worker characteristics
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 



use "$path/data/choice_jobtakeup_analysis.dta", clear 


gen level4 = caste==7
gen level3 = caste==6 | caste==5 
gen level2 = caste==3 | caste==4 
gen level1 = caste==1 | caste==2 


cap file close sumstat
file open sumstat using "$path/output/tab_summary.tex", write replace

file write sumstat "{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}  \begin{tabular}{@{\extracolsep{2pt}}p{6cm}*{5}{>{\centering\arraybackslash}m{2cm}}@{}}   \toprule" _n      // table header
file write sumstat "&Mean for Level 4 &Diff. for Level 3 &Diff. for Level 2 &Diff. for Level 1 \\     " _n        
file write sumstat "\midrule" _n 	

foreach var in age year_edu read_odiya famsize workshare kutcha_house semipucca_house own_land landsize income paid_days own_index wealth_pca conserv_index { 

	local varlab: variable label `var'
	
	if "`var'"!="income" {
	summ `var' if tag_pid==1 & level4==1
		local coef1: di %7.3f r(mean)
		local sd1=trim(string(r(sd), "%7.3f"))
	
	reg `var' level3 level2 level1 if tag_pid, r
		
		local coef2: di %7.3f _b[level3]
		local coef3: di %7.3f _b[level2]
		local coef4: di %7.3f _b[level1]
		
		local se2=trim(string(_se[level3], "%7.3f"))
		local se3=trim(string(_se[level2], "%7.3f"))
		local se4=trim(string(_se[level1], "%7.3f"))
	}
	
	if "`var'"=="income" {
	summ `var' if tag_pid==1 & level4==1
		local coef1: di %7.0gc r(mean)
		local sd1=trim(string(r(sd), "%7.0gc"))
	
	reg `var' level3 level2 level1 if tag_pid, r
		
		local coef2: di %7.0gc _b[level3]
		local coef3: di %7.0gc _b[level2]
		local coef4: di %7.0gc _b[level1]
		
		local se2=trim(string(_se[level3], "%7.0gc"))
		local se3=trim(string(_se[level2], "%7.0gc"))
		local se4=trim(string(_se[level1], "%7.0gc"))
	
	}
	
		* stars
			local t2=(_b[level3])/(_se[level3])
			local p2=2*ttail(e(df_r), abs(`t2'))
				local stars2 ""
				if `p2'<.1 local stars2 "*"
				if `p2'<.05 local stars2 "**"
				if `p2'<.01 local stars2 "***"
			local t3=(_b[level2])/(_se[level2])
			local p3=2*ttail(e(df_r), abs(`t3'))	
				local stars3 ""
				if `p3'<=.1 local stars3 "*"
				if `p3'<=.05 local stars3 "**"
				if `p3'<=.01 local stars3 "***"
				if `p3'>.05 local stars3 ""
			local t4=(_b[level1])/(_se[level1])
			local p4=2*ttail(e(df_r), abs(`t4'))
				local stars4 ""
				if `p4'<=.1 local stars4 "*"
				if `p4'<=.05 local stars4 "**"
				if `p4'<=.01 local stars4 "***"				


file write sumstat "`varlab' & `coef1' & `coef2'`stars2' & `coef3'`stars3' & `coef4'`stars4'   \\  " _n  
file write sumstat "		 & [`sd1'] & (`se2') & (`se3') & (`se4')   \\     \addlinespace[5pt]   " _n  


}

file write sumstat "\bottomrule" _n           // table footer
file write sumstat "\end{tabular}" _n 
file write sumstat "}" _n 
file close sumstat		




* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table A4: Job take-up results with alternate specifications
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


use "$path/data/choice_jobtakeup_analysis.dta", clear 

replace taskorder=. if taskorder<0

eststo clear


eststo: areg takeup iden_diftask iden_lowertask diftask lowertask i.task time_task* , absorb(pid) cluster(pid)
	estadd local extra_cont "Alternate time controls"

eststo: areg takeup iden_diftask iden_lowertask diftask lowertask i.task time_task* i.interviewer_id##identity, absorb(pid) cluster(pid)
	estadd local extra_cont "Surveyor FE"

eststo: areg takeup iden_diftask iden_lowertask diftask lowertask i.task time_task* i.interviewer_id##identity i.taskorder##identity, absorb(pid) cluster(pid)
	estadd local extra_cont "Task order FE"
	
eststo: areg takeup iden_diftask iden_lowertask diftask lowertask i.task time_task* i.interviewer_id##identity i.taskorder##identity i.had_rope##identity, absorb(pid) cluster(pid)
	estadd local extra_cont "Choice set FE"

eststo: areg takeup iden_diftask iden_lowertask diftask lowertask i.task timehr if purecont==0 & task!=3 & task!=4, absorb(pid) cluster(pid)
	estadd local samp "Mending grass mats or shoes"

eststo: areg takeup iden_lowertask lowertask iden_diftask diftask i.task timehr if purecont==0 & hicomp==1, absorb(pid) cluster(pid)
	estadd local samp "Low comprehension workers"
	
eststo: areg takeup iden_lowertask lowertask iden_diftask diftask i.task timehr if purecont==0 & reversal_pid==0, absorb(pid) cluster(pid)
	estadd local samp "Choices with inconsistency"

	
#delimit ;
esttab using "$path/output/tab_robust_other.tex", replace 
	b(3) se booktabs nostar label gaps nonotes nomtitles 
	keep(iden_diftask iden_lowertask diftask lowertask)
	order(iden_diftask iden_lowertask diftask lowertask)		
	stats(extra_cont samp N, labels("Controls added" "Excluded from sample" "Observations") 
	fmt(%20s %20s %9.0fc))
	prehead( "
	\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	\begin{tabular}
	{@{\extracolsep{5pt}}{l}*{8}{>{\centering\arraybackslash}m{2.2cm}}@{}}
	\toprule  
	& \multicolumn{7}{c}{\textbf{Willing to take up job offer}}  \bigstrut \\
	\cline{2-8} \addlinespace
	& \multicolumn{4}{c}{Progressively add more controls} & \multicolumn{3}{c}{Restrict sample}  \bigstrut \\
	\cline{2-5} \cline{6-8} \addlinespace	");
#delimit cr




* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table A5: Job take-up results using alternate rankings
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


use "$path/data/choice_jobtakeup_analysis.dta", clear 
drop if purecont==1


eststo clear
eststo: areg takeup iden_diftask iden_lowertask_old diftask lowertask_old i.task timehr, absorb(caste) cluster(pid)
	estadd local fe "Task, Caste"
	estadd local dem ""
	estadd local surv ""
eststo: areg takeup iden_diftask iden_lowertask_old diftask lowertask_old i.task timehr, absorb(pid) cluster(pid)
	estadd local fe "Task, Worker"
	estadd local surv ""
	estadd local dem ""
eststo: areg takeup iden_diftask iden_lowertask_old diftask lowertask_old i.task timehr age3-age11 year_edu3-year_edu11 wealth_pca3-wealth_pca11, absorb(pid) cluster(pid)
	estadd local fe "Task, Worker"
	estadd local surv "Yes"
	estadd local dem "Linear"

drop iden_lowertask_old lowertask_old
gen iden_lowertask_old = iden_lowertask_old2
gen lowertask_old = lowertask_old2

eststo: areg takeup iden_diftask iden_lowertask_old diftask lowertask_old i.task timehr, absorb(caste) cluster(pid)
	estadd local fe "Task, Caste"
	estadd local dem ""
	estadd local surv ""
eststo: areg takeup iden_diftask iden_lowertask_old diftask lowertask_old i.task timehr, absorb(pid) cluster(pid)
	estadd local fe "Task, Worker"
	estadd local surv ""
	estadd local dem ""
eststo: areg takeup iden_diftask iden_lowertask_old diftask lowertask_old i.task timehr age3-age11 year_edu3-year_edu11 wealth_pca3-wealth_pca11, absorb(pid) cluster(pid)
	estadd local fe "Task, Worker"
	estadd local surv "Yes"
	estadd local dem "Linear"

	
label var lowertask_old "Lower"
label var iden_lowertask_old "Identity $\times$ Lower"

#delimit ;
esttab using "$path/output/tab_takeup_main_register.tex", replace 
	b(3) se booktabs nostar label gaps nonotes nomtitles 
	keep(iden_diftask iden_lowertask_old diftask lowertask_old timehr)
	order(iden_diftask iden_lowertask_old diftask lowertask_old timehr)	
	stats(fe surv dem N, labels("Fixed effects included" "Answered follow-up survey" "Demographic controls" "Observations") 
	fmt(%20s %20s %9.0fc))
	prehead( "
	\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	\begin{tabular}
	{@{\extracolsep{5pt}}{l}*{6}{>{\centering\arraybackslash}{c}}@{}}
	\toprule 
	& \multicolumn{6}{c}{\textbf{Willing to take up job offer}} \bigstrut \\
	\cline{2-7} \addlinespace
	&\multicolumn{3}{c}{Registered ranking} &  \multicolumn{3}{c}{Partially corrected ranking}  \\
	\cline{2-4} \cline{5-7} \addlinespace ");
#delimit cr



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table A6: Completion rates of actually selected offers
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


use "$path/data/choice_jobtakeup_analysis.dta", clear 
drop if purecont==1

bys pid task: egen takeup_task = max(takeup)

eststo clear
eststo a1: reg offer_accept iden_lowertask_offer lowertask_offer iden_diftask_offer diftask_offer i.offer_type i.caste if tag_pid==1, cluster(pid)
	estadd local fe "Task, Caste"	
	qui sum offer_accept if sametask_offer==1 & iden_sametask_offer==0 & tag_pid==1
	estadd scalar depmean1=r(mean)
	qui sum offer_accept if iden_sametask_offer==1 & tag_pid==1
	estadd scalar depmean2=r(mean)

eststo a2: reg offer_complete iden_lowertask_offer lowertask_offer iden_diftask_offer diftask_offer i.offer_type i.caste if tag_pid==1, cluster(pid)
	estadd local fe "Task, Caste"	
	qui sum offer_complete if sametask_offer==1 & iden_sametask_offer==0 & tag_pid==1
	estadd scalar depmean1=r(mean)
	qui sum offer_complete if iden_sametask_offer==1 & tag_pid==1
	estadd scalar depmean2=r(mean)

eststo a3: reg survey_complete iden_lowertask_offer lowertask_offer iden_diftask_offer diftask_offer i.offer_type i.caste if tag_pid==1, cluster(pid)
	estadd local fe "Task, Caste"	
	qui sum survey_complete if sametask_offer==1 & iden_sametask_offer==0 & tag_pid==1
	estadd scalar depmean1=r(mean)
	qui sum survey_complete if iden_sametask_offer==1 & tag_pid==1
	estadd scalar depmean2=r(mean)

cap drop iden_lowertask_offer lowertask_offer iden_diftask_offer diftask_offer
gen iden_diftask_offer=iden_diftask 
gen iden_lowertask_offer=iden_lowertask 
gen diftask_offer=diftask 
gen lowertask_offer=lowertask

eststo a4: areg takeup_task iden_lowertask_offer lowertask_offer iden_diftask_offer diftask_offer i.task if tag_pidtask==1, absorb(caste) cluster(pid)
	estadd local fe "Task, Caste"	
	qui sum takeup_task if sametask_offer==1 & iden_sametask_offer==0 & tag_pidtask==1
	estadd scalar depmean1=r(mean)
	qui sum takeup_task if iden_sametask_offer==1 & tag_pidtask==1
	estadd scalar depmean2=r(mean)

label var lowertask_offer "Lower"
label var iden_lowertask_offer "Identity $\times$ Lower"
label var diftask_offer "Different"
label var iden_diftask_offer "Identity $\times$ Different"


#delimit ;
esttab a4 a1 a2 a3 using "$path/output/tab_app_completion.tex", replace 
	b(3) se booktabs nostar label gaps nonotes nomtitles 
	keep(iden_diftask_offer iden_lowertask_offer diftask_offer lowertask_offer)
	order(iden_diftask_offer iden_lowertask_offer diftask_offer lowertask_offer)	
	stats(hold depmean2 depmean1 N, labels("Mean: same-ranked tasks" "\hspace{0.4cm} Identity tasks" "\hspace{0.4cm} Control tasks" "Observations") 
	fmt(%20s %9.3fc %9.3fc %9.0fc))
	prehead( "
	\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	\begin{tabular}
	{@{\extracolsep{5pt}}{l}*{8}{>{\centering\arraybackslash}m{3cm}}@{}}
	\toprule  
	& \multicolumn{2}{c}{\textbf{Willing to take up job offer}} & \multicolumn{2}{c}{\textbf{Completion}} \bigstrut \\
	\cline{2-3} \cline{4-5} \addlinespace
	& Any offer involving task & Randomly selected offer & One-day job & Follow-up survey  \\");
#delimit cr
	


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table A7: Heterogeneity in job offer take-up
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


use "$path/data/choice_jobtakeup_analysis.dta", clear 
drop if purecont==1

gen loedu = 1-hiedu if !mi(hiedu)

eststo clear

foreach y in conserv5up old loedu { 
	cap drop het het_* 
	gen het = `y'
	
	foreach x of varlist iden_diftask iden_lowertask diftask lowertask identity{ 
		gen het_`x'=`y'*`x' 
	} 

	eststo: areg takeup iden_diftask iden_lowertask diftask lowertask het het_* i.task timehr, absorb(caste) cluster(pid)
		estadd local fe "Task, Caste"
		estadd local surv "Yes"
		
	eststo: areg takeup iden_diftask iden_lowertask diftask lowertask het_* i.task timehr, absorb(pid) cluster(pid)
		estadd local fe "Task, Worker"
		estadd local surv "Yes"
}

label var het_iden_diftask "Traditional $\times$ Identity $\times$ Different "
label var het_iden_lowertask "Traditional $\times$ Identity $\times$ Lower"
label var het_diftask "Traditional $\times$ Different"
label var het_lowertask "Traditional $\times$ Lower"
label var het_identity "Traditional $\times$ Identity"
label var het "Traditional"

#delimit ;
esttab using "$path/output/tab_sensitive.tex", replace 
	b(3) se booktabs nostar label gaps nonotes nomtitles 
	keep(iden_diftask iden_lowertask het_iden_diftask het_iden_lowertask timehr)
	order(iden_diftask iden_lowertask het_iden_diftask het_iden_lowertask timehr)	
	stats(fe N, labels("Fixed effects included" "Observations") 
	fmt(%20s %9.0fc))
	prehead( "
	\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	\begin{tabular}
	{@{\extracolsep{5pt}}{l}*{6}{>{\centering\arraybackslash}{c}}@{}}
	\toprule 
	& \multicolumn{6}{c}{\textbf{Willing to take up job offer}} \bigstrut \\
	\cline{2-7} \addlinespace
	&\multicolumn{2}{c}{Caste-sensitive} &  \multicolumn{2}{c}{Older} &  \multicolumn{2}{c}{Less educated}  \\ 
	\cline{2-3} \cline{4-5} \cline{6-7} \addlinespace ");
#delimit cr




* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Permutation test
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

/* Erase this line to run the permutation test

set seed 12345

use "$path/data/choice_jobtakeup_analysis.dta", clear 
drop if purecont==1

areg takeup iden_diftask iden_lowertask diftask lowertask i.task timehr, absorb(pid) cluster(pid)
local coef1 = _b[iden_diftask]
local coef2 = _b[iden_lowertask]
local coef3 = _b[diftask]
local coef4 = _b[lowertask]

egen newid = group(pid)
keep takeup iden_diftask iden_lowertask diftask lowertask task timehr pid tag_pid newid task timecat
local j = 0
local k = 0
local l = 0
local m = 0

tempfile orig
save `orig'



forval i=1/10000{	
	use `orig', clear
	keep takeup tag_pid newid task timecat
	qui gen rand`i' = runiform() if tag_pid==1
	gsort -tag_pid rand`i'
	cap drop temp0
	qui gen temp0 = _n if tag_pid==1
	qui egen temp`i' = min(temp0), by(newid)
	drop temp0 newid tag_pid rand`i'
	rename temp`i' newid
	rename takeup takeupf
	
	qui merge 1:1 newid task timecat using `orig', nogenerate

	qui areg takeupf iden_diftask iden_lowertask diftask lowertask i.task timehr, absorb(newid) cluster(newid)
	if _b[iden_diftask]<`coef1' {
		local `j++'
	}
	if _b[iden_lowertask]<`coef2' {
		local `k++'
	}
	if _b[diftask]<`coef3' {
		local `l++'
	}
	if _b[lowertask]>`coef4' {
		local `m++'
	}	
	di "`i'"
}


di "iden_diftask pval = `j', iden_lowertask pval = `k'"
di "diftask pval = `l', lowertask pval = `m'"

/* for reporting results, divide the output by 10000:
iden_diftask pval = 0, iden_lowertask pval = 0
diftask pval = 96, lowertask pval = 0 */

