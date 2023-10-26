********************************************************************************
* Title:   Tables and Figures in Appendix B of Second-best Fairness paper
* Descrip: Contains descriptive statistics, regression tables and figures in 
*          Appendix B (experiments from 2019 - study 1, and from 2015 - study 2)
*          Table B1 - Descriptive statistics
*          Table B3 - Regression analysis of treatment effects - study 1
*          Table B4 - Estimated shares 
*          Table B5 - Regression analysis of treatment effects - study 2
*          Table B6 - Politial differences: right-wing versus non-right-wing
*          Table B7 - Should equalize
*          Figure B1 - Share of spectators who pay  
*          Figure B2 - Strength of second-best fairness preferences
*          All numbers mentioned in the text that are not regression coefficients
*          are calculated at the end of the dofile
********************************************************************************
clear all
set more off
cap log close
log using ../Code/AppendixBType1Type2_2022.log, text replace


use ../Data/Processed_Data/analysis_20152019.dta, clear 

*to distinguish different samples
gen s1=.
replace s1=1 if study1==1
replace s1=0 if study1==0
gen s2=.
replace s2=1 if study1==0
replace s2=0 if study1==1
gen all_treat=1
gen nor=.
replace nor=1 if US==0
replace nor=0 if US==1
gen usa=.
replace usa=1 if US==1
replace usa=0 if US==0

********************************************************************************
**#B1. TABLE - DESCRIPTIVE STATISTICS
********************************************************************************
* income categories norway
*category 1 "0-100.000 NOK" 
*category 2 "100.001-200.000 NOK" 
*category 3 "200.001-300.000 NOK" 
*category 4 "300.001-400.000 NOK"  
*category 5 "400.001-500.000 NOK" 
*category 6 "500.001-600.000 NOK" 
*category 7 "600.001-700.000 NOK" 
*category 8 "700.001-800.000 NOK" 
*category 9 "800.001-900.000 NOK" 
*category 10 "900.001-1.000.000 NOK" 
*category 11 "1.000.001-1.100.000 NOK" 
*category 12 "1.100.001-1.200.000 NOK"
*category 13 "1.200.001-1.300.000 NOK"
*category 14 "1.300.001-1.400.000 NOK"
*category 15 "1.400.001-1.500.000 NOK"
*category 16 "1.500.001 NOK eller mer" 
*category 17  "Vet ikke"
*category 18  "Vil ikke svare"

* income categories usa
*category 1 "Under $20,000" 
*category 2 " $20,000 to $29,999" 
*category 3 "$30,000 to $39,999" 
*category 4 "$40,000 to $49,999" 
*category 5 "$50,000 to $59,999" 
*category 6 "$60,000 to $69,999" 
*category 7 "$70,000 to $79,999" 
*category 8 " $80,000 to $89,999" 
*category 9 "$90,000 to $99,999" 
*category 10 "$100,000 to $119,999" 
*category 11 "$120,000 to $149,999" 
*category 12 "$150,000 to $199,999" 
*category 13 "Over $200,000" 
*category 14 "Would rather not say"

*INCOME
preserve
matrix des1=J(1, 4, .)
local i=0
drop if incomenor1==17 
drop if incomenor1==18
drop if incomenor2==17
drop if incomenor2==18
drop if incomeusa1==14
drop if incomeusa2==14
local i=0
foreach v in incomeusa1 incomenor1 incomeusa2 incomenor2 {
	sum `v', detail
	return list
	scalar `v'_50 =  r(p50)
	
	local i = `i'+1
	matrix des1[1, `i'] = `v'_50
}

matrix rownames des1 = "Household income (median)"
matrix colnames des1 = "US" "Norway" "US" "Norway"
matrix list des1
restore

*the table reports the category corresponding to the median household income for the two countries.
*the categories are listed above
*the table in the manuscript reports the rounded mean value for each category. For instance, median household income for the US is equal to category 5 in 2019, which is $50,000 to $59,999, and the manuscritp reports that the median household income is $55,000

esttab matrix(des1, fmt(2)) using ../Tables/TableB1a.tex, replace ///
title(Descriptive Statistics)

*OTHER BACKGROUND VAR
preserve
drop if age>100
matrix des=J(4, 4, .)
local i=0
foreach v in educationlow male age rightwing{
	sum `v' if US==1 & study1==1
	return list
	local `v'_mean_us = r(mean)
	
	sum `v' if US==0 & study1==1
	return list
	local `v'_mean_nor = r(mean)
	
	sum `v' if US==1 & study1==0
	return list
	local `v'_mean_us_0 = r(mean)
	
	sum `v' if US==0 & study1==0
	return list
	local `v'_mean_nor_0 = r(mean)

    local i= `i'+1 
	matrix des[`i', 1]= ``v'_mean_us'
	matrix des[`i', 2]= ``v'_mean_nor'
	matrix des[`i', 3]= ``v'_mean_us_0'
	matrix des[`i', 4]= ``v'_mean_nor_0'
}

matrix rownames des = "Low education" "Male" "Age" "Right-wing"
matrix colnames des = "US" "Norway" "US" "Norway"
matrix list des 
restore 

esttab matrix(des, fmt(2)) using ../Tables/TableB1b.tex, replace ///
title(Descriptive Statistics)

*N OF OBSERVATIONS 
sum study1 if US==1 & study1==1
return list
mat us1 = r(N)
	
sum study1 if US==0 & study1==1
return list
mat nor1 = r(N)
	
sum study1 if US==1 & study1==0
return list
mat us2 = r(N)
	
sum study1 if US==0 & study1==0
return list
mat nor2 = r(N)

mat obs = us1, nor1, us2, nor2
matrix rownames obs = "N"
matrix colnames obs = "s1 - US" "s1 - Norway" "s2 - US" "s2 - Norway"
mat list obs
esttab matrix(obs, fmt(2)) using ../Tables/TableB1c.tex, replace ///
title(Descriptive Statistics)

********************************************************************************
**#B3. TABLE - TREAT. EFFECTS STUDY 1
********************************************************************************
local controls incomelow educationlow male agelow rightwing
eststo clear 
*ALL
eststo: quietly reg pay treat2 treat3 treat4 treat5 if study1==1, r
eststo: quietly reg pay treat2 treat3 treat4 treat5 `controls' if study1==1, r

*US
eststo: quietly reg pay treat2 treat3 treat4 treat5 if study1==1 & US==1, r
eststo: quietly reg pay treat2 treat3 treat4 treat5 `controls' if study1==1 & US==1, r

*NORWAY 
eststo: quietly reg pay treat2 treat3 treat4 treat5 if study1==1 & US==0, r
eststo: quietly reg pay treat2 treat3 treat4 treat5 `controls' if study1==1 & US==0, r

esttab using ../Tables/TableB3.tex, replace ///
gaps b(3) se(3) booktabs nostar nomtitle ///
title (Regression Analysis of Treatment Effects - Study 1) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
mgroups(All US Norway, pattern(1 0 1 0 1 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span}))  

********************************************************************************
**#B4. TABLE - ESTIMATED SHARES
********************************************************************************	  
*STUDY1
*All   
reg pay treat2 treat3 treat4 treat5 if s1==1, r 
*SU
lincom 2*(treat2-treat3)
return list
mat all_treat_su_s1= r(estimate)
mat all_treat_suse_s1 = r(se) 
*FPL
lincom 1-(_cons+treat3)- (treat2-treat3)
return list
mat all_treat_fpl_s1= r(estimate)
mat all_treat_fplse_s1 = r(se)
*FPU
lincom 1-(_cons+treat3)
return list
mat all_treat_fpu_s1= r(estimate)
mat all_treat_fpuse_s1 = r(se)
*SL
lincom 0
return list
mat all_treat_sl_s1= r(estimate)
mat all_treat_slse_s1 = r(se) 
*FNL
lincom _cons+treat3-(treat2-treat3)
return list
mat all_treat_fnl_s1= r(estimate)
mat all_treat_fnlse_s1 = r(se)
*FNU
lincom _cons+treat3
return list
mat all_treat_fnu_s1= r(estimate)
mat all_treat_fnuse_s1 = r(se)

*US
reg pay treat2 treat3 treat4 treat5 if s1==1 & usa==1, r 
*SU
lincom 2*(treat2-treat3)
return list
mat usa_su_s1= r(estimate)
mat usa_suse_s1 = r(se) 
*FPL
lincom 1-(_cons+treat3)- (treat2-treat3)
return list
mat usa_fpl_s1= r(estimate)
mat usa_fplse_s1 = r(se)
*FPU
lincom 1-(_cons+treat3)
return list
mat usa_fpu_s1= r(estimate)
mat usa_fpuse_s1 = r(se)
*SL
lincom 0
return list
mat usa_sl_s1= r(estimate)
mat usa_slse_s1 = r(se) 
*FNL
lincom _cons+treat3-(treat2-treat3)
return list
mat usa_fnl_s1= r(estimate)
mat usa_fnlse_s1 = r(se)
*FNU
lincom _cons+treat3
return list
mat usa_fnu_s1= r(estimate)
mat usa_fnuse_s1 = r(se)

*Norway
reg pay treat2 treat3 treat4 treat5 if s1==1 & usa==1, r 
*SU
lincom 2*(treat2-treat3)
return list
mat nor_su_s1= r(estimate)
mat nor_suse_s1 = r(se) 
*FPL
lincom 1-(_cons+treat3)- (treat2-treat3)
return list
mat nor_fpl_s1= r(estimate)
mat nor_fplse_s1 = r(se)
*FPU
lincom 1-(_cons+treat3)
return list
mat nor_fpu_s1= r(estimate)
mat nor_fpuse_s1 = r(se)
*SL
lincom 0
return list
mat nor_sl_s1= r(estimate)
mat nor_slse_s1 = r(se) 
*FNL
lincom _cons+treat3-(treat2-treat3)
return list
mat nor_fnl_s1= r(estimate)
mat nor_fnlse_s1 = r(se)
*FNU
lincom _cons+treat3
return list
mat nor_fnu_s1= r(estimate)
mat nor_fnuse_s1 = r(se)

*STUDY2
*All   
reg pay treat2 treat3 treat4 treat5 if s2==1, r 
*SU
lincom 2*(treat3-treat4)
return list
mat all_treat_su_s2= r(estimate)
mat all_treat_suse_s2 = r(se) 
*FPL
lincom 1-(_cons+treat3)- (treat3-treat4)
return list
mat all_treat_fpl_s2= r(estimate)
mat all_treat_fplse_s2 = r(se)
*FPU
lincom 1-(_cons+treat3)
return list
mat all_treat_fpu_s2= r(estimate)
mat all_treat_fpuse_s2 = r(se)
*SL
lincom 0
return list
mat all_treat_sl_s2= r(estimate)
mat all_treat_slse_s2 = r(se) 
*FNL
lincom _cons+treat3-(treat3-treat4)
return list
mat all_treat_fnl_s2= r(estimate)
mat all_treat_fnlse_s2 = r(se)
*FNU
lincom _cons+treat3
return list
mat all_treat_fnu_s2= r(estimate)
mat all_treat_fnuse_s2 = r(se)

*US
reg pay treat2 treat3 treat4 treat5 if s2==1 & usa==1, r 
*SU
lincom 2*(treat3-treat4)
return list
mat usa_su_s2= r(estimate)
mat usa_suse_s2 = r(se) 
*FPL
lincom 1-(_cons+treat3)- (treat3-treat4)
return list
mat usa_fpl_s2= r(estimate)
mat usa_fplse_s2 = r(se)
*FPU
lincom 1-(_cons+treat3)
return list
mat usa_fpu_s2= r(estimate)
mat usa_fpuse_s2 = r(se)
*SL
lincom 0
return list
mat usa_sl_s2= r(estimate)
mat usa_slse_s2 = r(se) 
*FNL
lincom _cons+treat3-(treat3-treat4)
return list
mat usa_fnl_s2= r(estimate)
mat usa_fnlse_s2 = r(se)
*FNU
lincom _cons+treat3
return list
mat usa_fnu_s2= r(estimate)
mat usa_fnuse_s2 = r(se)

*Norway
reg pay treat2 treat3 treat4 treat5 if s2==1 & usa==1, r 
*SU
lincom 2*(treat2-treat3)
return list
mat nor_su_s2= r(estimate)
mat nor_suse_s2 = r(se) 
*FPL
lincom 1-(_cons+treat3)- (treat2-treat3)
return list
mat nor_fpl_s2= r(estimate)
mat nor_fplse_s2 = r(se)
*FPU
lincom 1-(_cons+treat3)
return list
mat nor_fpu_s2= r(estimate)
mat nor_fpuse_s2 = r(se)
*SL
lincom 0
return list
mat nor_sl_s2= r(estimate)
mat nor_slse_s2 = r(se) 
*FNL
lincom _cons+treat3-(treat2-treat3)
return list
mat nor_fnl_s2= r(estimate)
mat nor_fnlse_s2 = r(se)
*FNU
lincom _cons+treat3
return list
mat nor_fnu_s2= r(estimate)
mat nor_fnuse_s2 = r(se)



mat allfp = all_treat_fpl_s1, all_treat_fpu_s1, all_treat_fpl_s2, all_treat_fpu_s2 
mat allfpse = all_treat_fplse_s1, all_treat_fpuse_s1, all_treat_fplse_s2, all_treat_fpuse_s2

mat usfp = usa_fpl_s1, usa_fpu_s1, usa_fpl_s2, usa_fpu_s2
mat usfpse = usa_fplse_s1, usa_fpuse_s1, usa_fplse_s2, usa_fpuse_s2

mat norfp = nor_fpl_s1, nor_fpu_s1, nor_fpl_s2, nor_fpu_s2 
mat norfpse = nor_fplse_s1, nor_fpuse_s1, nor_fpuse_s2, nor_fpuse_s2

mat alls = all_treat_sl_s1, all_treat_su_s1, all_treat_sl_s2, all_treat_su_s2
mat allsse = all_treat_slse_s1, all_treat_suse_s1, all_treat_slse_s2, all_treat_suse_s2

mat uss = usa_sl_s1, usa_su_s1, usa_sl_s2, usa_su_s2
mat ussse = usa_slse_s1, usa_suse_s1, usa_slse_s2, usa_suse_s2

mat nors = nor_sl_s1, nor_su_s1, nor_sl_s2, nor_su_s2
mat norsse = nor_slse_s1, nor_suse_s1, nor_slse_s2, nor_suse_s2

mat allfn = all_treat_fnl_s1, all_treat_fnu_s1, all_treat_fnl_s2, all_treat_fnu_s2  
mat allfnse = all_treat_fnlse_s1, all_treat_fnuse_s1, all_treat_fnlse_s2, all_treat_fnuse_s2 

mat usfn = usa_fnl_s1, usa_fnu_s1, usa_fnl_s2, usa_fnu_s2 
mat usfnse = usa_fnlse_s1, usa_fnuse_s1, usa_fnlse_s2, usa_fnuse_s2

mat norfn = nor_fnl_s1, nor_fnu_s1, nor_fnl_s2, nor_fnu_s2 
mat norfnse = nor_fnlse_s1, nor_fnuse_s1, nor_fnlse_s2, nor_fnuse_s2

mat TableB4 = allfp \ allfpse \ alls \ allsse \ allfn \ allfnse \ usfp \ usfpse \ uss \ ussse \ usfn \ usfnse \ norfp \ norfpse \ nors \ norsse \ norfn \ norfnse
matrix rownames TableB4 = "False positive averse" "se" "Symmetric" "se" "False negative averse" "se" "False positive averse" "se" "Symmetric" "se" "False negative averse" "se" "False positive averse" "se" "Symmetric" "se" "False negative averse" "se" 
matrix colnames TableB4 = "Lower bound" "Upper bound" "Lower bound" "Upper bound"

*symmetric lower bounds are zero (check in main text why) and negative shares are also turned into zeros
foreach row in 3 9 15 {
    foreach col in 1 2 3 4 {
	    if TableB4[`row', `col']<=0 {
		mat TableB4[`row', `col']=0 
		mat TableB4[`row' + 1, `col']=0
}
}
}

mat list TableB4
esttab matrix(TableB4, fmt(3)) using ../Tables/TableB4.tex, replace ///
title(Estimated shares - Study1 and study 2)
 
********************************************************************************
**#B5. TABLE - TREAT. EFFECTS STUDY 2
********************************************************************************
local controls incomelow educationlow male agelow rightwing
eststo clear 
*ALL
eststo: quietly reg pay treat2 treat3 treat4 treat5 if study1==0, r
eststo: quietly reg pay treat2 treat3 treat4 treat5 `controls' if study1==0, r

*US
eststo: quietly reg pay treat2 treat3 treat4 treat5 if study1==0 & US==1, r
eststo: quietly reg pay treat2 treat3 treat4 treat5 `controls' if study1==0 & US==1, r

*NORWAY 
eststo: quietly reg pay treat2 treat3 treat4 treat5 if study1==0 & US==0, r
eststo: quietly reg pay treat2 treat3 treat4 treat5 `controls' if study1==0 & US==0, r

esttab using ../Tables/TableB5.tex, replace ///
gaps b(3) se(3) booktabs nostar nomtitle  ///
title (Regression Analysis of Treatment Effects - Study 2) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
mgroups(All US Norway, pattern(1 0 1 0 1 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span}))  

********************************************************************************
**#B6. TABLE - ESTIMATED SHARES POLITICAL
********************************************************************************
foreach v in all_treat usa nor{
	foreach var in all_treat s1 s2{
	reg pay rightwing treat2 treat3 treat4 treat5 rightwing_treat2 rightwing_treat3 rightwing_treat4 rightwing_treat5 if `v'==1 & `var'==1 ,r 
     ereturn list 
	 mat `v'_obsb6_`var' = e(N)
	 mat `v'_r_`var' = e(r2)
     *FNA
     lincom (rightwing + rightwing_treat3)
	 return list
	 mat fna_`v'_`var'= r(estimate)
	 mat fnase_`v'_`var' = r(se)
     *SFP
     lincom -(rightwing + rightwing_treat2)
	 return list
	 mat sfp_`v'_`var'= r(estimate)
  	 mat sfpse_`v'_`var' = r(se)
     *SFN
     lincom rightwing + rightwing_treat4
	 return list
	 mat sfn_`v'_`var'= r(estimate)
	 mat sfnse_`v'_`var' = r(se)
}
}
*obsb6 = number of observations
*fna=share of false negative averse spectators (upper bound) 
*sfp=share of strongly false positive averse spectators 
*sfn=share of strongly false negative averse spectators 

mat obsb6 = all_treat_obsb6_all_treat, all_treat_obsb6_s1, all_treat_obsb6_s2, usa_obsb6_all_treat, usa_obsb6_s1, usa_obsb6_s2, nor_obsb6_all_treat, nor_obsb6_s1, nor_obsb6_s2

mat r2 = all_treat_r_all_treat, all_treat_r_s1, all_treat_r_s2, usa_r_all_treat, usa_r_s1, usa_r_s2, nor_r_all_treat, nor_r_s1, nor_r_s2

mat fnab6 = fna_all_treat_all_treat, fna_all_treat_s1, fna_all_treat_s2, fna_usa_all_treat, fna_usa_s1, fna_usa_s2, fna_nor_all_treat, fna_nor_s1, fna_nor_s2
mat fnaseb6 = fnase_all_treat_all_treat, fnase_all_treat_s1, fnase_all_treat_s2, fnase_usa_all_treat, fnase_usa_s1, fnase_usa_s2, fnase_nor_all_treat, fnase_nor_s1, fnase_nor_s2

mat sfpb6 = sfp_all_treat_all_treat, sfp_all_treat_s1, sfp_all_treat_s2, sfp_usa_all_treat, sfp_usa_s1, sfp_usa_s2, sfp_nor_all_treat, sfp_nor_s1, sfp_nor_s2
mat sfpseb6 = sfpse_all_treat_all_treat, sfpse_all_treat_s1, sfpse_all_treat_s2, sfpse_usa_all_treat, sfpse_usa_s1, sfpse_usa_s2, sfpse_nor_all_treat, sfpse_nor_s1, sfpse_nor_s2

mat sfnb6 = sfn_all_treat_all_treat, sfn_all_treat_s1, sfn_all_treat_s2, sfn_usa_all_treat, sfn_usa_s1, sfn_usa_s2, sfn_nor_all_treat, sfn_nor_s1, sfn_nor_s2
mat sfnseb6 = sfnse_all_treat_all_treat, sfnse_all_treat_s1, sfnse_all_treat_s2, sfnse_usa_all_treat, sfnse_usa_s1, sfnse_usa_s2, sfnse_nor_all_treat, sfnse_nor_s1, sfnse_nor_s2

mat Tableb6 = fnab6 \ fnaseb6 \ sfpb6 \ sfpseb6 \ sfnb6 \ sfnseb6 \ obsb6 \ r2
matrix rownames Tableb6 = "False Negative" "se" "Strongly False Positive" "se" "Strongly False Negative" "se" "N" "R2"
matrix colnames Tableb6 = "Pooled" "Study 1" "Study 2" "Pooled" "Study 1" "Study 2"
mat list Tableb6

esttab matrix(Tableb6, fmt(3)) using ../Tables/TableB6.tex, replace ///
title(Estimated shares - Political Differences: Right-wing versus non-right-wing)
********************************************************************************
**#B7. TABLE - SHOULD EQUALIZE
********************************************************************************
local controls incomelow educationlow male agelow 
eststo clear 

*ALL
eststo: quietly reg zshould pay `controls' , r
eststo: quietly reg zshould falsenegative `controls', r

*USA
eststo: quietly reg zshould pay `controls' if US==1, r
eststo: quietly reg zshould falsenegative `controls' if US==1, r

*NORWAY
eststo: quietly reg zshould pay `controls' if US==0, r
eststo: quietly reg zshould falsenegative `controls' if US==0, r

esttab using ../Tables/TableB7.tex, replace ///
gaps b(3) se(3) booktabs nostar nomtitle noconstant ///
title (Should Equalize) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
indicate("Controls = incomelow educationlow male agelow ") ///
mgroups(All US Norway, pattern(1 0 1 0 1 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span}))

********************************************************************************
**#.B1 FIGURE - SHARE OF SPECTATORS WHO PAY 
********************************************************************************
// All - Study1

preserve
recode treatment (1=5) (2=4) (3=3) (4=2) (5=1)
drop if study1==0
collapse (mean) pay (semean) se_pay = pay, by(treatment)

gen hi = pay + se_pay

gen lo = pay - se_pay

graph twoway (bar pay treat, barw(0.75))  (rcap hi lo treat, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(1 "0" 2 "0.25" 3 "0.5" 4 "0.75" 5 "1") xtitle("Probability of cheating") title("All - Study 1") ///
    legend(off) ytitle("Share paying `pm' s.e.m.") name(barmeansstudy1, replace)

graph export ../Figures/barmeansstudy1.eps, replace
! epstopdf ../Figures/barmeansstudy1.eps
rm ../Figures/barmeansstudy1.eps


restore

// US - Study1

preserve

recode treatment (1=5) (2=4) (3=3) (4=2) (5=1)
drop if US==0
drop if study1==0

collapse (mean) pay (semean) se_pay = pay, by(treatment)

gen hi = pay + se_pay

gen lo = pay - se_pay

graph twoway (bar pay treat, barw(0.75))  (rcap hi lo treat, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(1 "0" 2 "0.25" 3 "0.5" 4 "0.75" 5 "1") xtitle("Probability of cheating") title("USA - Study 1") ///
    legend(off) ytitle("Share paying`pm' s.e.m.") name(barmeansUSstudy1, replace)

graph export ../Figures/barmeansUSstudy1.eps, replace
! epstopdf ../Figures/barmeansUSstudy1.eps
rm ../Figures/barmeansUSstudy1.eps


restore

// NOR - study1

preserve

recode treatment (1=5) (2=4) (3=3) (4=2) (5=1)
drop if US==1
drop if study1==0

collapse (mean) pay (semean) se_pay = pay, by(treatment)

gen hi = pay + se_pay

gen lo = pay - se_pay

graph twoway (bar pay treat, barw(0.75))  (rcap hi lo treat, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(1 "0" 2 "0.25" 3 "0.5" 4 "0.75" 5 "1") xtitle("Probability of cheating") title("Norway - Study 1") ///
    legend(off) ytitle("Share paying `pm' s.e.m.") name(barmeansNorwaystudy1, replace)

graph export ../Figures/barmeansNorwaystudy1.eps, replace
! epstopdf ../Figures/barmeansNorwaystudy1.eps
rm ../Figures/barmeansNorwaystudy1.eps

restore

// all - study2

preserve
drop if study1==1
collapse (mean) pay (semean) se_pay = pay, by(treatment)

gen hi = pay + se_pay

gen lo = pay - se_pay

graph twoway (bar pay treat, barw(0.75))  (rcap hi lo treat, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(1 "0" 2 "0.25" 3 "0.5" 4 "0.75" 5 "1") xtitle("Share of cheaters")  title("All - Study 2") ///
    legend(off) ytitle("Share paying `pm' s.e.m.") name(barmeansstudy2, replace)

graph export ../Figures/barmeansstudy2.eps, replace
! epstopdf ../Figures/barmeansstudy2.eps
rm ../Figures/barmeansstudy2.eps


restore

// US - study2

preserve
drop if study1==1
drop if US==0

collapse (mean) pay (semean) se_pay = pay, by(treatment)

gen hi = pay + se_pay

gen lo = pay - se_pay

graph twoway (bar pay treat, barw(0.75))  (rcap hi lo treat, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(1 "0" 2 "0.25" 3 "0.5" 4 "0.75" 5 "1") xtitle("Share of cheaters") title("USA - Study 2") ///
    legend(off) ytitle("Share paying`pm' s.e.m.") name(barmeansUSstudy2, replace)

graph export ../Figures/barmeansUSstudy2.eps, replace
! epstopdf ../Figures/barmeansUSstudy2.eps
rm ../Figures/barmeansUSstudy2.eps


restore

// NOR - study2

preserve

drop if US==1
drop if study1==1

collapse (mean) pay (semean) se_pay = pay, by(treatment)

gen hi = pay + se_pay

gen lo = pay - se_pay

graph twoway (bar pay treat, barw(0.75))  (rcap hi lo treat, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(1 "0" 2 "0.25" 3 "0.5" 4 "0.75" 5 "1") xtitle("Share of cheaters") title("Norway - Study 2") ///
    legend(off) ytitle("Share paying `pm' s.e.m.") name(barmeansNorwaystudy2, replace)

graph export ../Figures/barmeansNorwaystudy2.eps, replace
! epstopdf ../Figures/barmeansNorwaystudy2.eps
rm ../Figures/barmeansNorwaystudy2.eps

restore


graph combine  barmeansstudy1 barmeansstudy2 barmeansUSstudy1 barmeansUSstudy2 barmeansNorwaystudy1 barmeansNorwaystudy2 , cols(2) name(FigureB1, replace)
graph export ../Figures/FigureB1.eps, replace
! epstopdf ../Figures/FigureB1.eps
rm ../Figures/FigureB1.eps

********************************************************************************
**#B2. FIGURE - STRENGTH OF SECOND-BEST FAIRNESS PREFERENCES
********************************************************************************
// all study1
gen notpay=(1-pay)

preserve
drop if study1==0
recode treatment (1=5) (2=4) (3=3) (4=2) (5=1)
collapse (mean) payequal_mean = pay  notpay_mean = notpay (semean) payequal_se = pay notpay_se = notpay, by(treatment)
list
reshape long payequal_@ notpay_@, i(treat) j(y) string
list
reshape long @_, i(treat y) j(var_name) string
list
reshape wide _ , i(treat var_name) j(y) string
list
gen hi = _mean + _se
gen lo = _mean - _se


gen pos = 1 if (treat==2 & var_name == "notpay")
replace pos = 2 if (treat==3 & var_name == "notpay")
replace pos = 3 if (treat==3 & var_name == "payequal")
replace pos = 4 if (treat==4 & var_name == "payequal")


gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1


graph twoway (bar  _mean newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  _mean newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).9) xlabel(1 "False positive averse"  2 "False negative averse" ) ///
	 xtitle("")    title("All - Study 1") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(classification_1, replace)

graph export ../Figures/classification_1.pdf, replace

restore 

// all - stud2
preserve
drop if study1==1
collapse (mean) payequal_mean = pay  notpay_mean = notpay (semean) payequal_se = pay notpay_se = notpay, by(treatment)
list
reshape long payequal_@ notpay_@, i(treat) j(y) string
list
reshape long @_, i(treat y) j(var_name) string
list
reshape wide _ , i(treat var_name) j(y) string
list
gen hi = _mean + _se
gen lo = _mean - _se


gen pos = 1 if (treat==2 & var_name == "notpay")
replace pos = 2 if (treat==3 & var_name == "notpay")
replace pos = 3 if (treat==3 & var_name == "payequal")
replace pos = 4 if (treat==4 & var_name == "payequal")


gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1


graph twoway (bar  _mean newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  _mean newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).9) xlabel(1 "False positive averse"  2 "False negative averse" ) ///
	     xtitle("")   title("All - Study 2") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(classification_2, replace)

graph export ../Figures/classification_2.pdf, replace

restore

// US - study1
preserve
drop if study1==0
drop if US==0
recode treatment (1=5) (2=4) (3=3) (4=2) (5=1)
collapse (mean) payequal_mean = pay  notpay_mean = notpay (semean) payequal_se = pay notpay_se = notpay, by(treatment)
list
reshape long payequal_@ notpay_@, i(treat) j(y) string
list
reshape long @_, i(treat y) j(var_name) string
list
reshape wide _ , i(treat var_name) j(y) string
list
gen hi = _mean + _se
gen lo = _mean - _se


gen pos = 1 if (treat==2 & var_name == "notpay")
replace pos = 2 if (treat==3 & var_name == "notpay")
replace pos = 3 if (treat==3 & var_name == "payequal")
replace pos = 4 if (treat==4 & var_name == "payequal")


gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1


graph twoway (bar  _mean newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  _mean newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).9) xlabel(1 "False positive averse"  2 "False negative averse" ) ///
	     xtitle("")   title("USA - Study 1") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(classification_1US, replace)

graph export ../Figures/classification_1US.pdf, replace

restore
// NOR - study1
preserve
drop if study1==0
drop if US==1
recode treatment (1=5) (2=4) (3=3) (4=2) (5=1)
collapse (mean) payequal_mean = pay  notpay_mean = notpay (semean) payequal_se = pay notpay_se = notpay, by(treatment)
list
reshape long payequal_@ notpay_@, i(treat) j(y) string
list
reshape long @_, i(treat y) j(var_name) string
list
reshape wide _ , i(treat var_name) j(y) string
list
gen hi = _mean + _se
gen lo = _mean - _se


gen pos = 1 if (treat==2 & var_name == "notpay")
replace pos = 2 if (treat==3 & var_name == "notpay")
replace pos = 3 if (treat==3 & var_name == "payequal")
replace pos = 4 if (treat==4 & var_name == "payequal")


gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1


graph twoway (bar  _mean newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  _mean newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).9) xlabel(1 "False positive averse"  2 "False negative averse" ) ///
	  xtitle("")      title("Norway - Study 1") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(classification_1N, replace)

graph export ../Figures/classification_1N.pdf, replace

restore

// US - study2
preserve
drop if study1==1
drop if US==0
collapse (mean) payequal_mean = pay  notpay_mean = notpay (semean) payequal_se = pay notpay_se = notpay, by(treatment)
list
reshape long payequal_@ notpay_@, i(treat) j(y) string
list
reshape long @_, i(treat y) j(var_name) string
list
reshape wide _ , i(treat var_name) j(y) string
list
gen hi = _mean + _se
gen lo = _mean - _se


gen pos = 1 if (treat==2 & var_name == "notpay")
replace pos = 2 if (treat==3 & var_name == "notpay")
replace pos = 3 if (treat==3 & var_name == "payequal")
replace pos = 4 if (treat==4 & var_name == "payequal")


gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1


graph twoway (bar  _mean newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  _mean newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).9) xlabel(1 "False positive averse"  2 "False negative averse" ) ///
	     xtitle("")   title("USA - Study 2") ///
                 legend(off )   ytitle("Share {&plusminus} s.e.m.") name(classification_2US, replace)

graph export ../Figures/classification_2US.pdf, replace

restore
// NOR - study2
preserve
drop if study1==1
drop if US==1
collapse (mean) payequal_mean = pay  notpay_mean = notpay (semean) payequal_se = pay notpay_se = notpay, by(treatment)
list
reshape long payequal_@ notpay_@, i(treat) j(y) string
list
reshape long @_, i(treat y) j(var_name) string
list
reshape wide _ , i(treat var_name) j(y) string
list
gen hi = _mean + _se
gen lo = _mean - _se

gen pos = 1 if (treat==2 & var_name == "notpay")
replace pos = 2 if (treat==3 & var_name == "notpay")
replace pos = 3 if (treat==3 & var_name == "payequal")
replace pos = 4 if (treat==4 & var_name == "payequal")


gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1


graph twoway (bar  _mean newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  _mean newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).9) xlabel(1 "False positive averse"  2 "False negative averse" ) ///
	    xtitle("")    title("Norway - Study 2") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(classification_2N, replace)

graph export ../Figures/classification_2N.pdf, replace

restore

graph combine classification_1 classification_2 classification_1US classification_2US classification_1N classification_2N, cols(2) name(FigureB2, replace)
graph export ../Figures/FigureB2.pdf, replace


cap log close

********************************************************************************
**#IN-TEXT NUMBERS
********************************************************************************
*Table B3
reg pay treat2 treat3 treat4 treat5 if study1==1, r
*difference false negative averse and false positive averse pooled 
lincom _cons + treat3 - (1-(_cons + treat3))

*Figure B2
reg pay treat2 treat3 treat4 treat5 if study1==1, r
*strongly false positive pooled
lincom 1-(_cons + treat2)
*strongly false negative pooled
lincom _cons + treat4

*Figure B1
reg pay treat2 treat3 treat4 treat5 if study1==0, r
*pay when certain correct claim
lincom _cons
*do not pay when certaion false claim
lincom 1 - (_cons + treat5)

*Table B5
reg pay treat2 treat3 treat4 treat5 if study1==0, r
*difference false negative averse and false positive averse pooled 
lincom (_cons + treat3) - (1-(_cons + treat3))
*everyone filing a false claim
lincom _cons + treat5

*norway difference
reg pay treat2 treat3 treat4 treat5 if study1==0 & US==0, r
*difference false negative averse and false positive averse pooled 
lincom (_cons + treat3) - (1-(_cons + treat3))

*us difference
reg pay treat2 treat3 treat4 treat5 if study1==0 & US==1, r
*difference false negative averse and false positive averse pooled 
lincom (_cons + treat3) - (1-(_cons + treat3))