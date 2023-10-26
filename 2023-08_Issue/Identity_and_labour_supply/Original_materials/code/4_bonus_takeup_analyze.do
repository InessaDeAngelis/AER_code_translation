* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* PROJECT:			Does Identity Affect Labor Supply?
* RESEARCHER:		Suanna Oh
* TASK:				Analyze the bonus experiment data
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*					<< Sections >>
* 
*		1.  Figure 4: Willingness to switch to working on extra tasks - Panel A
*		2.  Figure 4: Willingness to switch to working on extra tasks - Panel B
*		3.  Table 4: Caste inconsistency and refusal of all offers involving a task
*		4.  Table A8: Balance of worker characteristics
*		5.  Table A10: Role of experience and comprehension
*		6.  Table A11: Number of refusals for each task within worker-subgroups
*		7.  Table A12: Predicting which workers have identity concerns
*		8.	Choice inconsistency
* 		
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Figure 4: Willingness to switch to working on extra tasks - Panel A
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


use "$path/data/choice_bonuswage_analysis.dta", clear

egen tag_time = tag(timecat)

gen take30 = minwage_tasktime_imp<=30 if !mi(minwage_tasktime_imp)
gen take3000 = minwage_tasktime_imp<=3000 if !mi(minwage_tasktime_imp)


gen take30_id = take30 if identity==1
gen take30_pc = take30 if pairedcont==1
gen take3000_id = take3000 if identity==1
gen take3000_pc = take3000 if pairedcont==1


foreach x of varlist take30_id take30_pc take3000_id take3000_pc {
	bys timecat: egen `x'_l = mean(`x')
}


#delimit ;

twoway (connected take30_id_l timemin if tag_time==1, color(green*0.75) lpattern(dash) lwidth(medthick) msymbol(O) msize(medlarge)), 
		xscale(range(5 65)) yscale(range(0 1)) ylabel(#6, labsize(medlarge)) xlabel(,nogrid labsize(medlarge)) graphregion(color(white)) title("Identity tasks", size(huge))
		ytitle("Take-up rate", size(vlarge)) xtitle("Time in minutes", size(vlarge)) ;
graph display, xsize(5.1);
graph export "$path/output/fig_pricelin_iden_v1.pdf", replace;

twoway (connected take30_id_l timemin if tag_time==1, color(green*0.75) lpattern(dash) lwidth(medthick) msymbol(O) msize(medlarge))
		(connected take3000_id_l timemin if tag_time==1, color(green*0.75) lwidth(medthick) msymbol(T) msize(medlarge)), 
		legend(off) xscale(range(5 65)) yscale(range(0 1)) ylabel(#6, labsize(medlarge)) xlabel(,nogrid labsize(medlarge)) graphregion(color(white)) title("Identity tasks", size(huge)) 
		ytitle("Take-up rate", size(vlarge)) xtitle("Time in minutes", size(vlarge)) ;
graph display, xsize(5.1);
graph export "$path/output/fig_pricelin_iden_v2.pdf", replace;

twoway (connected take30_pc_l timemin if tag_time==1, color(blue*0.75) lpattern(dash) lwidth(medthick) msymbol(O) msize(medlarge)), 
		xscale(range(5 65)) yscale(range(0 1)) ylabel(#6, labsize(medlarge)) xlabel(,nogrid labsize(medlarge)) graphregion(color(white)) title("Paired control tasks", size(huge))
		ytitle("Take-up rate", size(vlarge)) xtitle("Time in minutes", size(vlarge)) ;
graph display, xsize(5.1);
graph export "$path/output/fig_pricelin_cont_v1.pdf", replace;

twoway (connected take30_pc_l timemin if tag_time==1, color(blue*0.75) lpattern(dash) lwidth(medthick) msymbol(O) msize(medlarge))
		(connected take3000_pc_l timemin if tag_time==1, color(blue*0.75) lwidth(medthick) msymbol(T) msize(medlarge)), 
		legend(off) xscale(range(5 65)) yscale(range(0 1)) ylabel(#6, labsize(medlarge)) xlabel(,nogrid labsize(medlarge)) graphregion(color(white)) title("Paired control tasks", size(huge)) 
		ytitle("Take-up rate", size(vlarge)) xtitle("Time in minutes", size(vlarge)) ;
graph display, xsize(5.1);
graph export "$path/output/fig_pricelin_cont_v2.pdf", replace;

#delimit cr





* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Figure 4: Willingness to switch to working on extra tasks - Panel B
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 



use "$path/data/choice_bonuswage_analysis.dta", clear

gen minwage_imp_v2=minwage_task_imp/30
replace minwage_imp_v2=13 if minwage_imp_v2==30
replace minwage_imp_v2=16 if minwage_imp_v2==50
replace minwage_imp_v2=22 if minwage_imp_v2==100
replace minwage_imp_v2=24 if minwage_imp_v2>100 & minwage_imp_v2<200

label define minwage_imp_v2 0 "0" 1 "30" 2 "60" 3 "90" 4 "120" 6 "180" 8 "240" 10 "300" 13 "900" 16 "1500" 22 "3K" 24 ">3K", replace
label values minwage_imp_v2 minwage_imp_v2

twoway histogram minwage_imp_v2 if tag_pidtask & timecat==1 & pairedcont==1, ///
	discrete frac xlabel(0 2 4 6 8 10 13 16 22 24, valuelabel labsize(medlarge) nogrid) xscale(titlegap(1)) ylabel(,labsize(medlarge)) xtitle("Minimum additional wage", size(vlarge)) ytitle("Share of workers", size(vlarge)) ///
	title("Paired control tasks", size(huge)) fcolor(blue*0.75) lcolor(blue*0.5) graphregion(color(white)) yscale(range(0.45))
graph display, xsize(5.1)
graph export "$path/output/fig_price_histogram_cont.pdf", replace


twoway histogram minwage_imp_v2 if tag_pidtasktime & timecat==1 & identity==1, ///
	discrete frac xlabel(0 2 4 6 8 10 13 16 22 24, valuelabel labsize(medlarge) nogrid) xscale(titlegap(1)) ylabel(,labsize(medlarge)) xtitle("Minimum additional wage", size(vlarge)) ytitle("Share of workers", size(vlarge)) ///
	title("Identity tasks", size(huge)) fcolor(green*0.75) lcolor(green*0.5) graphregion(color(white)) yscale(range(0.45))
graph display, xsize(5.1)
graph export "$path/output/fig_price_histogram_iden.pdf", replace


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table 4: Caste inconsistency and refusal of all offers involving a task
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 



use "$path/data/choice_bonuswage_analysis.dta", clear
drop if purecont==1

** task level
foreach var of varlist old age hiedu year_edu own_index compscore hicomp hiwealth wealth_pca{
	foreach x of numlist 1/7{ 
		gen `var'`x'=`var'*task`x'
	}
}

// combined;
eststo clear
eststo: areg nevertake_task identity if tag_pidtask==1, absorb(caste) cluster(pid)
	estadd local fe "Caste"
	estadd local dem ""
	estadd local surv ""
eststo: areg nevertake_task identity if tag_pidtask==1, absorb(pid) cluster(pid)
	estadd local fe "Worker"
	estadd local surv ""
	estadd local dem ""
eststo: areg nevertake_task identity old2-old7 hiedu2-hiedu7 hiwealth2-hiwealth7 if tag_pidtask==1, absorb(pid) cluster(pid)
	estadd local fe "Worker"
	estadd local surv "Yes"
	estadd local dem "Binary"
eststo: areg nevertake_task identity pub_identity if tag_pidtask==1, absorb(pid) cluster(pid)
	estadd local fe "Worker"
	estadd local surv ""
	estadd local dem ""
eststo: areg nevertake_task identity pub_identity old2-old7 hiedu2-hiedu7 hiwealth2-hiwealth7 if tag_pidtask==1, absorb(pid) cluster(pid)
	estadd local fe "Worker"
	estadd local surv "Yes"
	estadd local dem "Binary"


label var identity "Identity tasks"
label var exptask "Paired tasks"
label var pub_identity "Public $\times$ Identity"
label var pub_exptask "Public $\times$ Paired"

#delimit ;
esttab using "$path/output/tab_price.tex", replace 
	b(3) se booktabs nostar label gaps nonotes nomtitles 
	keep(identity pub_identity )
	order(identity pub_identity )
	stats(fe surv dem N, labels("Fixed effects included" "Answered follow-up survey" "Demographic controls" "Observations") 
	fmt(%20s %20s %9.0fc))
	prehead( "
	\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	\begin{tabular}{@{\extracolsep{1pt}}p{5cm}*{10}{>{\centering\arraybackslash}m{2cm}}@{}}
	\toprule 
	& \multicolumn{5}{c}{\textbf{Refuse all offers regardless of bonus}} \bigstrut \\
	\cline{2-6} \addlinespace");
#delimit cr




* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table A8: Balance of worker characteristics
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ;

use "$path/data/choice_jobtakeup_analysis.dta", clear


foreach var in age year_edu read_odiya famsize workshare kutcha_house semipucca_house own_land landsize income paid_days own_index wealth_pca conserv_index  { 

	summ `var' if tag_pid==1 & public==0
		local `var'_coef1: di %7.3f r(mean)
		local `var'_sd1=trim(string(r(sd), "%7.3f"))
	
	reg `var' public if tag_pid, cl(pid)
		local `var'_coef2: di %7.3f _b[public]
		local `var'_se2=trim(string(_se[public], "%7.3f"))
		
	* stars
		local `var'_t2 = (_b[public])/(_se[public])
		local `var'_p2 = 2*ttail(e(df_r), abs(``var'_t2'))
			local `var'_stars2 ""
			if ``var'_p2'<.1 local `var'_stars2 "*"
			if ``var'_p2'<.05 local `var'_stars2 "**"
			if ``var'_p2'<.01 local `var'_stars2 "***"		
				
	if "`var'"=="income" {
		local `var'_coef1=trim(string(``var'_coef1', "%7.0gc"))
		local `var'_sd1=trim(string(``var'_sd1', "%7.0gc"))
		local `var'_coef2=trim(string(``var'_coef2', "%7.0gc")) 
		local `var'_se2=trim(string(``var'_se2', "%7.0gc"))
	}
	
}

use "$path/data/choice_bonuswage_analysis.dta", clear

foreach var in age year_edu read_odiya famsize workshare kutcha_house semipucca_house own_land landsize income paid_days own_index wealth_pca conserv_index  { 

	summ `var' if tag_pid==1 & public==0
		local `var'_coef3: di %7.3f r(mean)
		local `var'_sd3=trim(string(r(sd), "%7.3f"))
	
	reg `var' public if tag_pid, cl(pid)
		local `var'_coef4: di %7.3f _b[public]
		local `var'_se4=trim(string(_se[public], "%7.3f"))
		
	* stars
		local `var'_t4 = (_b[public])/(_se[public])
		local `var'_p4 = 2*ttail(e(df_r), abs(``var'_t4'))
			local `var'_stars2 ""
			if ``var'_p4'<.1 local `var'_stars4 "*"
			if ``var'_p4'<.05 local `var'_stars4 "**"
			if ``var'_p4'<.01 local `var'_stars4 "***"		
				
	if "`var'"=="income" {
		local `var'_coef3=trim(string(``var'_coef3', "%7.0gc"))
		local `var'_sd3=trim(string(``var'_sd3', "%7.0gc"))
		local `var'_coef4=trim(string(``var'_coef4', "%7.0gc")) 
		local `var'_se4=trim(string(``var'_se4', "%7.0gc"))
	}
	
}



cap file close sumstat
file open sumstat using "$path/output/tab_balance.tex", write replace

file write sumstat "{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}  \begin{tabular}{@{\extracolsep{2pt}}p{6cm}*{5}{>{\centering\arraybackslash}m{2cm}}@{}}   \toprule" _n      // table header
file write sumstat "& \multicolumn{2}{c}{\textbf{Main experiment data}} & \multicolumn{2}{c}{\textbf{Supplementary data}} \bigstrut \\ 	\cline{2-3} \cline{4-5} \addlinespace " _n        
file write sumstat "&Mean for Private & Diff. for Public &Mean for Private & Diff. for Public \\     " _n        
file write sumstat "\midrule" _n 	

foreach var in age year_edu read_odiya famsize workshare kutcha_house semipucca_house own_land landsize income paid_days own_index wealth_pca conserv_index  { 

	local varlab: variable label `var'	

	file write sumstat "`varlab' & ``var'_coef1' & ``var'_coef2'``var'_stars2' & ``var'_coef3' & ``var'_coef4'``var'_stars4'   \\  " _n  
	file write sumstat "		 & [``var'_sd1'] & (``var'_se2')  & [``var'_sd3'] & (``var'_se4')  \\     \addlinespace[5pt]   " _n  


}

file write sumstat "\bottomrule" _n           // table footer
file write sumstat "\end{tabular}" _n 
file write sumstat "}" _n 
file close sumstat		


		
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table A10: Role of experience and comprehension
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


use "$path/data/choice_bonuswage_analysis.dta", clear
drop if purecont==1

		
foreach var of varlist old age hiedu year_edu own_index compscore hicomp hiwealth wealth_pca{
	foreach x of numlist 1/7{ 
		gen `var'`x'=`var'*task`x'
	}
}

eststo clear
eststo: areg nevertake_task identity exptask ownhhperf outhhperf wageperf if tag_pidtask==1, absorb(caste) cluster(pid)
	estadd local fe "Caste"
	estadd local surv "Yes"
	estadd local dem ""
	estadd local rest ""	
eststo: areg nevertake_task identity exptask ownhhperf outhhperf wageperf if tag_pidtask==1, absorb(pid) cluster(pid)
	estadd local fe "Worker"
	estadd local surv "Yes"
	estadd local dem ""
	estadd local rest ""		
eststo: areg nevertake_task identity exptask ownhhperf outhhperf wageperf old2-old7 hiedu2-hiedu7 hiwealth2-hiwealth7 if tag_pidtask==1, absorb(pid) cluster(pid)
	estadd local fe "Worker"
	estadd local surv "Yes"
	estadd local dem "Binary"
	estadd local rest ""		
eststo: areg nevertake_task identity exptask ownhhperf outhhperf wageperf old2-old7 hiedu2-hiedu7 hiwealth2-hiwealth7 if tag_pidtask==1 & compscore>8, absorb(pid) cluster(pid) // exclude 30%
	estadd local fe "Worker"
	estadd local surv "Yes"
	estadd local dem "Binary"
	estadd local rest "Low comprehension"	
eststo: areg nevertake_task identity exptask ownhhperf outhhperf wageperf old2-old7 hiedu2-hiedu7 hiwealth2-hiwealth7 if tag_pidtask==1 & reversal_pid==0, absorb(pid) cluster(pid) // exclude 12%
	estadd local fe "Worker"
	estadd local surv "Yes"
	estadd local dem "Binary"
	estadd local rest "Choice inconsistency"	

label var identity "Identity tasks"
label var exptask "Paired tasks"
label var ownhhperf "Performed in own HH"
label var outhhperf "Performed outside HH"
label var wageperf "Performed for wage"

#delimit ;
esttab using "$path/output/tab_price_experience.tex", replace 
	b(3) se booktabs nostar label gaps nonotes nomtitles 
	keep(identity ownhhperf outhhperf wageperf)
	order(identity ownhhperf outhhperf wageperf)
	stats(fe surv dem rest N, labels("Fixed effects included" "Answered follow-up survey" "Demographic controls" "Excluded from sample" "Observations") 
	fmt(%20s %20s %20s %9.0fc))
	prehead( "
	\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	\begin{tabular}{@{\extracolsep{1pt}}p{5cm}*{10}{>{\centering\arraybackslash}m{2.5cm}}@{}}
	\toprule 
	& \multicolumn{5}{c}{\textbf{Refuse all offers regardless of bonus}} \bigstrut \\
	\cline{2-6} \addlinespace");
#delimit cr
	



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table A11: Number of refusals for each task within worker-subgroups
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 



use "$path/data/choice_bonuswage_analysis.dta", clear


table caste if tag_pid==1, c(mean numrefuse_cont mean numrefuse_iden N numrefuse_iden)
table task if tag_pidtask==1, c(mean refuse)


tab numrefuse if tag_pid==1								// 44 accept all, 7 refuse almost all
tab numrefuse_cont numrefuse_iden if tag_pid==1			// refuse more identity tasks	

gen count_never = 1 if nevertake_task == 1					// for counting number of obs
	replace count_never=1 if task==8	

	

table task hasconcern_v2 if tag_pidtask==1, c(count count_never)
table task hasconcern_v2 if tag_pidtask==1, c(mean nevertake_task mean minwage_task) 		
	//  when 0, most people do all tasks
	//  when 1, refusal rate high for identity tasks and sweeping animal sheds

table task hasconcernstr_v2 if tag_pidtask==1, c(count count_never)
table task hasconcernstr_v2 if tag_pidtask==1, c(mean nevertake_task mean minwage_task) 



table task numrefuse_iden if tag_pidtask==1, c(count count_never)
table task numrefuse_iden if tag_pidtask==1, c(count nevertake_task mean minwage_task)
	//  among those who refuse 1 iden task, 15/19 refuse to sweep latrines
	//  6 people refuse 2 iden tasks
	//  35 people refuse all 3 iden tasks and some more -> categorize as strongly concerned

	
cap file close sumstat
file open sumstat using "$path/output/tab_joint_count.tex", write replace

file write sumstat "{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}  \begin{tabular}{@{\extracolsep{5pt}}p{4.3cm}*{5}{>{\centering\arraybackslash}m{2.2cm}}@{}}   \toprule" _n      // table header
file write sumstat "& \multicolumn{2}{c}{\textbf{Refuse any identity task}} & \multicolumn{2}{c}{\textbf{Refuse all identity tasks}} \bigstrut \\ 	\cline{2-3} \cline{4-5} \addlinespace " _n        
file write sumstat "&Refuse 0 & Refuse 1+ &Refuse 2-  & Refuse 3 \\     " _n     
file write sumstat "&(1) &(2) &(3) &(4) \\     " _n     
file write sumstat "\midrule  \addlinespace[5pt] " _n 	
file write sumstat "\addlinespace[2pt] " _n  
file write sumstat "\textbf{A. Control tasks} \\ \addlinespace[2pt]  " _n  

foreach n of numlist 1 3 5 7 {

	local varlab: label task `n'

	count if tag_pidtask==1 & hasconcern_v2==0 & nevertake_task == 1 & task==`n' 
	local count1: di %7.0f r(N)
	count if tag_pidtask==1 & hasconcern_v2==1 & nevertake_task == 1 & task==`n'
	local count2: di %7.0f r(N)
	count if tag_pidtask==1 & hasconcernstr_v2==0 & nevertake_task == 1 & task==`n'
	local count3: di %7.0f r(N)
	count if tag_pidtask==1 & hasconcernstr_v2==1 & nevertake_task == 1 & task==`n'
	local count4: di %7.0f r(N)
	file write sumstat "\addlinespace[2pt] " _n  
	file write sumstat "`varlab' & `count1' & `count2' & `count3' & `count4'   \\ \addlinespace[2pt] " _n  

}


file write sumstat "\addlinespace[5pt] " _n  
file write sumstat "\textbf{B. Identity tasks} \\ \addlinespace[2pt] " _n 

foreach n of numlist 2 4 6{

	local varlab: label task `n'

	count if tag_pidtask==1 & hasconcern_v2==0 & nevertake_task == 1 & task==`n' 
	local count1: di %7.0f r(N)
	count if tag_pidtask==1 & hasconcern_v2==1 & nevertake_task == 1 & task==`n'
	local count2: di %7.0f r(N)
	count if tag_pidtask==1 & hasconcernstr_v2==0 & nevertake_task == 1 & task==`n'
	local count3: di %7.0f r(N)
	count if tag_pidtask==1 & hasconcernstr_v2==1 & nevertake_task == 1 & task==`n'
	local count4: di %7.0f r(N)
	file write sumstat "\addlinespace[2pt] " _n  
	file write sumstat "`varlab' & `count1' & `count2' & `count3' & `count4'   \\ \addlinespace[2pt] " _n  

}


	count if tag_pidtask==1 & hasconcern_v2==0 & task==1
	local count1: di %7.0f r(N)
	count if tag_pidtask==1 & hasconcern_v2==1 & task==1
	local count2: di %7.0f r(N)
	count if tag_pidtask==1 & hasconcernstr_v2==0 & task==1
	local count3: di %7.0f r(N)
	count if tag_pidtask==1 & hasconcernstr_v2==1 & task==1
	local count4: di %7.0f r(N)
	file write sumstat "\midrule \addlinespace[5pt] " _n  
	file write sumstat "Total & `count1' & `count2' & `count3' & `count4'   \\ \addlinespace[2pt] " _n  
	
file write sumstat "\bottomrule" _n           // table footer
file write sumstat "\end{tabular}" _n 
file write sumstat "}" _n 
file close sumstat		



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table A12: Predicting which workers have identity concerns
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 



drop if survey_completed==0

gen temp = neverperf if tag_pidtask==1 & exptask==1
egen neverperfnum = total(temp), by(pid)
drop temp
label var neverperfnum "Number of tasks never performed before"
label var hasconcern "Refuse any identity tasks"
label var hasconcernstr "Refuse all identity tasks"
label var kaibarta "Kaibarta caste"
label var log_income "Last month income"

eststo clear
eststo: reg hasconcern age year_edu workshare kutcha_house semipucca_house own_land landsize log_income paid_days own_index kaibarta if tag_pid, cluster(pid)
eststo: reg hasconcern age year_edu workshare kutcha_house semipucca_house own_land landsize log_income paid_days own_index kaibarta compscore if tag_pid, cluster(pid) 
eststo: reg hasconcern age year_edu workshare kutcha_house semipucca_house own_land landsize log_income paid_days own_index kaibarta compscore conserv_index if tag_pid, cluster(pid)

eststo: reg hasconcernstr age year_edu workshare kutcha_house semipucca_house own_land landsize log_income paid_days own_index kaibarta if tag_pid, cluster(pid)
eststo: reg hasconcernstr age year_edu workshare kutcha_house semipucca_house own_land landsize log_income paid_days own_index kaibarta compscore if tag_pid, cluster(pid) 
eststo: reg hasconcernstr age year_edu workshare kutcha_house semipucca_house own_land landsize log_income paid_days own_index kaibarta compscore conserv_index if tag_pid, cluster(pid)


#delimit ;
esttab using "$path/output/tab_price_prediction.tex", replace 
	b(3) se booktabs nostar label gaps nonotes nomtitles 
	keep(age year_edu workshare kutcha_house semipucca_house own_land landsize log_income paid_days own_index kaibarta compscore conserv_index)
	order(age year_edu workshare kutcha_house semipucca_house own_land landsize log_income paid_days own_index kaibarta compscore conserv_index)
	stats(r2 N, labels("R-squared" "Observations") 
	fmt(%9.3fc %9.0fc))
	prehead( "
	\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	\begin{tabular}{@{\extracolsep{4pt}}p{6cm}*{10}{>{\centering\arraybackslash}m{1.8cm}}@{}}
	\toprule 
	& \multicolumn{3}{c}{\textbf{Refuse any identity task}} & \multicolumn{3}{c}{\textbf{Refuse all identity tasks}} \bigstrut \\
	\cline{2-4} \cline{5-7} \addlinespace");
#delimit cr




* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Choice inconsistency
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

use "$path/data/choice_bonuswage_analysis.dta", clear


tab incons_tea if tag_pid==1
tab incons_mustard if tag_pid==1

tab incons_time if tag_pidtask
tab incons_amt if tag_pidtasktime
tab reversal_pid if tag_pid
