********************************************************************************
* Title:   Tables in Second-best Fairness paper
* Descrip: Contains Regression tables in main text and appendix
*          Table 2 - Descriptove statistics
*          Table 3 - Treat. effects Compensation-experiment
*          Table 4 - Estimated shares Compensation and Earnings-expeirments
*          Table 5 - Additional treatments
*          Table 6 - Politial and Country Differences
*          Table 7 - Policy attitudes
*          Table A2 - Country Differences
*          Table A3 - Additional treatments + controls
*          Table A5 - Treat. effects Earnings-experiment
*          Table A7 - Compensation-experiment vs Earnings-experiment
*          Table A9 - Treat. effects Unemployment-experiment
*          Table A11 - Estimated shares Unemployment-experiment
*          Table A12 - Compensation-experiment vs Unemployment-experiment
*          Table A13 - Political differences
*          Table A14 - Estimated shares political and country differences
*          Table A15 - Policy attitudes associations with controls
*          Table A16 - Policy attitudes prob50
*          Table A17 - Policy attitudes US
*          Table A18 - Policy attitudes Norway
*          Table A19 - Policy attitudes Compensation-experiment
*          Table A20 - Policy attitudes Earnings-experiment
*          Table A21 - Policy attitudes Unemployment-experiment 
*          Table A22 - Policy attitude Disability-treatment
*          Table A22 - Policy attitude Unemployment vs Disability
*          All numbers mentioned in the text that are not regression coefficients
*          are calculated at the end of the dofile
********************************************************************************

clear all
set more off
cap log close
log using ../Code/Type1Type2_2022.log, text replace

use ../Data/Processed_Data/analyticaldata.dta, clear 


*to distinguish different samples 
gen comp_exp=.
replace comp_exp=1 if h_treatment<6
gen earn_exp=.
replace earn_exp=1 if h_treatment>15 & h_treatment<21
gen unemp_exp=.
replace unemp_exp=1 if h_treatment>10 & h_treatment<16
gen all_treat=1
gen nor=.
replace nor=1 if Norway==1
gen us=.
replace us=1 if Norway==0 

********************************************************************************
**#2. DES. STATS.
********************************************************************************
*MEDIAN INCOME

*The median values of the varuiable Houselhold income are reported in categories:
*norway 0-100.000 NOK - category 1
*       100.001-200.000 NOK - category 2
*       200.001-300.000 NOK - category 3
*       300.001-400.000 NOK - category 4
*       400.001-500.000 NOK - category 5
*       500.001-600.000 NOK - category 6
*       600.001-700.000 NOK - category 7
*       700.001-800.000 NOK - category 8
*       800.001-900.000 NOK - category 9
*       900.001-1.000.000 NOK - category 10
*       1.000.001-1.100.000 NOK - category 11
*       1.100.001-1.200.000 NOK - category 12
*       1.200.001-1.300.000 NOK - category 13
*       1.300.001-1.400.000 NOK - category 14
*       1.400.001-1.500.000 NOK - category 15
*       1.500.001 NOK eller mer - category 16
*       Vil ikke svare - category 17
*       Vet ikke - category 18

*usa:
*       Under $20,000 - category 1
*       $20,000 to $29,999 - category 2
*       $30,000 to $39,999 - category 3
*       $40,000 to $49,999 - category 4
*       $50,000 to $59,999 - category 5
*       $60,000 to $69,999 - category 6
*       $70,000 to $79,999 - category 7
*       $80,000 to $89,999 - category 8
*       $90,000 to $99,999 - category 9
*       $100,000 to $119,999 - category 10
*       $120,000 to $149,999 - category 11
*       $150,000 to $199,999 - category 12
*       Over $200,000 - category 13
*       Would rather not say - category 14

preserve
matrix des1=J(1, 2, .)
local i=0
drop if incomenorway==17
drop if incomenorway==18
local i=0
foreach v in incomeusa incomenorway {
	sum `v', detail
	return list
	scalar `v'_50 =  r(p50)
	
	local i = `i'+1
	matrix des1[1, `i'] = `v'_50
}

matrix rownames des1 = "Household income (median)"
matrix colnames des1 = "US" "Norway"
matrix list des1 

*the table reports the category corresponding to the median household income for the two countries.
*the categories are listed above, in the README file and in the survey instructions
*the table in the manuscript reports the rounded mean value for each category. For instance, median household income for the US is equal to category 5, which is $50,000 to $59,999, and the manuscritp reports that the median household income is $55,000

esttab matrix(des1, fmt(2)) using ../Tables/Table2a.tex, replace ///
title(Descriptive Statistics) ///
addnotes("The median values of the varuiable Houselhold income are reported in categories")

restore

*SHARE EDUCATION AGE GENDER POLITICAL IDEOLOGY
matrix des=J(4, 2, .)
local i=0
foreach v in loweducation age male rightwing{
	sum `v' if Norway==0
	return list
	local `v'_mean_us = r(mean)
	
	sum `v' if Norway==1
	return list
	local `v'_mean_nor = r(mean)

    local i= `i'+1 
	matrix des[`i', 1]= ``v'_mean_us'
	matrix des[`i', 2]= ``v'_mean_nor'
	
}

matrix rownames des = "Low education" "Age" "Male" "Right-wing"
matrix colnames des = "US" "Norway"
matrix list des 

esttab matrix(des, fmt(2)) using ../Tables/Table2b.tex, replace ///
title(Descriptive Statistics)

*N OF OBSERVATIONS 
sum Norway if Norway==0
return list
mat us = r(N)

sum Norway if Norway==1
return list
mat nor = r(N)

mat obs = us, nor
matrix rownames obs = "observations"
matrix colnames obs = "US" "Norway" 
mat list obs

esttab matrix(obs, fmt(2)) using ../Tables/Table2c.tex, replace ///
title(Descriptive Statistics)

********************************************************************************
**#3. TREAT. EFFECTS COMP. EXP.
********************************************************************************
local controls male lowage lowincome loweducation rightwing
eststo clear 
*ALL
eststo: quietly reg pay prob25 prob50 prob75 prob100 if h_treatment<6 [pweight=sca_weight], r
eststo: quietly reg pay prob25 prob50 prob75 prob100 `controls' if h_treatment<6 [pweight=sca_weight], r

*US
eststo: quietly reg pay prob25 prob50 prob75 prob100 if h_treatment<6 & Norway==0 [pweight=sca_weight], r
eststo: quietly reg pay prob25 prob50 prob75 prob100 `controls' if h_treatment<6 & Norway==0 [pweight=sca_weight], r

*NORWAY 
eststo: quietly reg pay prob25 prob50 prob75 prob100 if h_treatment<6 & Norway==1 [pweight=sca_weight], r
eststo: quietly reg pay prob25 prob50 prob75 prob100 `controls' if h_treatment<6 & Norway==1 [pweight=sca_weight], r

esttab using ../Tables/Table3.tex, replace ///
gaps b(3) se(3) booktabs nomtitle nostar ///
title (Regression Analysis of Treatment Effects - Compensation-experiment) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
mgroups(All US Norway, pattern(1 0 1 0 1 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span}))  

********************************************************************************
**#4. ESTIMATED SHARES COMP. & EARN. EXPS.
********************************************************************************
foreach var in all_treat us nor{
 foreach v in comp_exp earn_exp {
	reg pay prob25 prob50 prob75 prob100 if `v'==1 & `var'==1 [pweight=sca_weight], r
 
     ereturn list
	 mat `var'_obs_`v'= e(N)
	 
     *FPL
     lincom 1-(_cons+prob50)-(prob25-prob50)
	 return list
	 mat `var'_fpl_`v'= r(estimate)
	 mat `var'_fplse_`v' = r(se)
     *FPU
     lincom 1-(_cons+prob50)
	 return list
	 mat `var'_fpu_`v'= r(estimate)
	 mat `var'_fpuse_`v' = r(se)
	 *SL
	 lincom 0
	 return list
	 mat `var'_sl_`v'= r(estimate)
	 mat `var'_slse_`v' = r(se)
     *SU
     lincom 2*(prob25-prob50)
	 return list
	 mat `var'_su_`v'= max(r(estimate), 0)
	 mat `var'_suse_`v' = r(se) 
	 *FNL
     lincom _cons+prob50-(prob25-prob50)
	 return list
	 mat `var'_fnl_`v'= r(estimate)
	 mat `var'_fnlse_`v' = r(se)
     *FNU
     lincom _cons+prob50
	 return list
	 mat `var'_fnu_`v'= r(estimate)
	 mat `var'_fnuse_`v' = r(se)
}
}

*allobs= observations for US and Norway pooled
*usobs = observations for US
*norobs = oservations for Norway
*fpl=lower bound of share of false positive averse spectators 
*fpu=upper bound of the share of false positive averse spectators 
*sl=lower bound of the share of symmetric spectators 
*su=lower bound of the share of symmetric spectators 
*fnl=lower bound of the share of false negative averse spectators 
*fnu=upper bound of the share of false negative averse spectators

mat allobs = all_treat_obs_comp_exp, all_treat_obs_comp_exp, all_treat_obs_earn_exp, all_treat_obs_earn_exp
mat usobs = us_obs_comp_exp, us_obs_comp_exp, us_obs_earn_exp, us_obs_earn_exp
mat norobs = nor_obs_comp_exp, nor_obs_comp_exp, nor_obs_earn_exp, nor_obs_earn_exp

mat allfp = all_treat_fpl_comp_exp, all_treat_fpu_comp_exp, all_treat_fpl_earn_exp, all_treat_fpu_earn_exp 
mat allfpse = all_treat_fplse_comp_exp, all_treat_fpuse_comp_exp, all_treat_fplse_earn_exp, all_treat_fpuse_earn_exp 

mat usfp = us_fpl_comp_exp, us_fpu_comp_exp, us_fpl_earn_exp, us_fpu_earn_exp 
mat usfpse = us_fplse_comp_exp, us_fpuse_comp_exp, us_fplse_earn_exp, us_fpuse_earn_exp 

mat norfp = nor_fpl_comp_exp, nor_fpu_comp_exp, nor_fpl_earn_exp, nor_fpu_earn_exp 
mat norfpse = nor_fplse_comp_exp, nor_fpuse_comp_exp, nor_fpuse_earn_exp, nor_fpuse_earn_exp 

mat alls = all_treat_sl_comp_exp, all_treat_su_comp_exp, all_treat_sl_earn_exp, all_treat_su_earn_exp
mat allsse = all_treat_slse_comp_exp, all_treat_suse_comp_exp, all_treat_slse_earn_exp, all_treat_suse_earn_exp

mat uss = us_sl_comp_exp, us_su_comp_exp, us_sl_earn_exp, us_su_earn_exp
mat ussse = us_slse_comp_exp, us_suse_comp_exp, us_slse_earn_exp, us_suse_earn_exp

mat nors = nor_sl_comp_exp, nor_su_comp_exp, nor_sl_earn_exp, nor_su_earn_exp
mat norsse = nor_slse_comp_exp, nor_suse_comp_exp, nor_slse_earn_exp, nor_suse_earn_exp

mat allfn = all_treat_fnl_comp_exp, all_treat_fnu_comp_exp, all_treat_fnl_earn_exp, all_treat_fnu_earn_exp 
mat allfnse = all_treat_fnlse_comp_exp, all_treat_fnuse_comp_exp, all_treat_fnlse_earn_exp, all_treat_fnuse_earn_exp 

mat usfn = us_fnl_comp_exp, us_fnu_comp_exp, us_fnl_earn_exp, us_fnu_earn_exp 
mat usfnse = us_fnlse_comp_exp, us_fnuse_comp_exp, us_fnlse_earn_exp, us_fnuse_earn_exp

mat norfn = nor_fnl_comp_exp, nor_fnu_comp_exp, nor_fnl_earn_exp, nor_fnu_earn_exp 
mat norfnse = nor_fnlse_comp_exp, nor_fnuse_comp_exp, nor_fnlse_earn_exp, nor_fnuse_earn_exp

mat Table4 = allfp \ allfpse \ alls \ allsse \ allfn \ allfnse \ allobs \ usfp \ usfpse \ uss \ ussse \ usfn \ usfnse \ usobs \ norfp \ norfpse \ nors \ norsse \ norfn \ norfnse \ norobs
matrix rownames Table4 = "False positive averse" "se" "Symmetric" "se" "False negative averse" "se" "Observations" "False positive averse" "se" "Symmetric" "se" "False negative averse" "se" "Observations" "False positive averse" "se" "Symmetric" "se" "False negative averse" "se" "Observations"
matrix colnames Table4 = "Lower bound" "Upper bound" "Lower bound" "Upper bound" 

*symmetric lower bounds are zero (check in main text why) and negative shares are also turned into zeros
foreach row in 3 6 9 {
    foreach col in 1 2 3 4 {
	    if Table4[`row', `col']<=0 {
		mat Table4[`row', `col']=0 
		mat Table4[`row' + 1, `col']=0
}
}
}
esttab matrix(Table4, fmt(3)) using ../Tables/Table4.tex, replace ///
title(Estimated shares - Compensation-experiment and Earnings-experiment)

********************************************************************************
**#5. ADDITIONAL TREAT. COMP. EXP. (HIGH/NATIONAL/ENDOW./COST)
********************************************************************************
eststo clear 
*HIGH STAKES 
eststo: quietly reg pay high if h_treatment==3 | h_treatment==7 [pweight=sca_weight], robust
eststo: quietly reg pay high if Norway==0 & h_treatment==3 | Norway==0 & h_treatment==7 [pweight=sca_weight], r
eststo: quietly reg pay high if Norway==1 & h_treatment==3 | Norway==1 & h_treatment==7 [pweight=sca_weight], r

*NATIONALITY  
eststo: quietly reg pay national if h_treatment==3 | h_treatment==6 [pweight=sca_weight], robust
eststo: quietly reg pay national if Norway==0 & h_treatment==3 | Norway==0 & h_treatment==6 [pweight=sca_weight], r
eststo: quietly reg pay national if Norway==1 & h_treatment==3 | Norway==1 & h_treatment==6 [pweight=sca_weight], r

esttab using ../Tables/Table5a.tex, replace ///
gaps b(3) se(3) nomtitle nostar ///
nonumber booktabs ///
mlabels (All US Norway All US Norway) ///
stats(N r2, fmt(%7.0fc %6.3f)) label ///
mgroups(Stakes National, pattern(1 0 0 1 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(})   ///
span erepeat(\cmidrule(lr){@span}))

eststo clear
*ENDOWMENT  
eststo: quietly reg pay comp if h_treatment==3 | h_treatment==8 [pweight=sca_weight], robust 
eststo: quietly reg pay comp if Norway==0 & h_treatment==3 | Norway==0 & h_treatment==8 [pweight=sca_weight], r
eststo: quietly reg pay comp if Norway==1 & h_treatment==3 | Norway==1 & h_treatment==8 [pweight=sca_weight], r

*COST
eststo: quietly reg pay lowcost highcost if h_treatment>7 & h_treatment<11 [pweight=sca_weight], robust
eststo: quietly reg pay lowcost highcost if h_treatment>7 & h_treatment<11 & Norway==0 [pweight=sca_weight], r
eststo: quietly reg pay lowcost highcost if h_treatment>7 & h_treatment<11 & Norway==1 [pweight=sca_weight], r

esttab using ../Tables/Table5b.tex, replace ///
gaps b(3) se(3) nomtitle nostar ///
nonumber booktabs ///
mlabels (All US Norway All US Norway) ///
stats(N r2, fmt(%7.0fc %6.3f)) label ///
mgroups(Endowment Cost, pattern(1 0 0 1 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(})   ///
span erepeat(\cmidrule(lr){@span}))

********************************************************************************
**#6. ESTIMATED SHARES POLITICAL & COUNTRY DIFF.
********************************************************************************
foreach v in all_treat us nor{
	reg pay rightwing prob25 prob50 prob75 prob100 rightwing_prob25 rightwing_prob50 rightwing_prob75 rightwing_prob100 if `v'==1 [pweight=sca_weight],r 
     ereturn list 
	 mat `v'_obs6 = e(N)
     *FNA
     lincom (rightwing + rightwing_prob50)
	 return list
	 mat fna_`v'= r(estimate)
	 mat fnase_`v' = r(se)
     *SFP
     lincom -(rightwing + rightwing_prob25)
	 return list
	 mat sfp_`v'= r(estimate)
  	 mat sfpse_`v' = r(se)
     *SFN
     lincom rightwing + rightwing_prob75
	 return list
	 mat sfn_`v'= r(estimate)
	 mat sfnse_`v' = r(se)
}
*obs6 = number of observations
*fna=share of false negative averse spectators (upper bound) 
*sfp=share of strongly false positive averse spectators 
*sfn=share of strongly false negative averse spectators 

mat obs6 = all_treat_obs6, us_obs6, nor_obs6

mat fna6 = fna_all_treat, fna_us, fna_nor
mat fnase6 = fnase_all_treat, fnase_us,fnase_nor

mat sfp6 = sfp_all_treat, sfp_us, sfp_nor
mat sfpse6 = sfpse_all_treat, sfpse_us, sfpse_nor

mat sfn6 = sfn_all_treat, sfn_us, sfn_nor
mat sfnse6 = sfnse_all_treat, sfnse_us, sfnse_nor

mat Table6a = fna6 \ fnase6 \ sfp6 \ sfpse6 \ sfn6 \ sfnse6 \ obs6
matrix rownames Table6a = "False Negative" "se" "Strongly False Positive" "se" "Strongly False Negative" "se" "Observations"
matrix colnames Table6a = "All" "US" "Norway"

esttab matrix(Table6a, fmt(3)) using ../Tables/Table6a.tex, replace ///
title(Political and Country Differences)


reg pay Norway prob25 prob50 prob75 prob100 Norway_prob25 Norway_prob50 Norway_prob75 Norway_prob100 [pweight=sca_weight], robust
ereturn list
mat obs_cntr = e(N)
*FNA
lincom (_cons + prob50) - (_cons + prob50 + Norway_prob50 + Norway)
mat fna = r(estimate)
mat fnase = r(se)
*SFP
lincom (1-(_cons + prob25)) - (1-(_cons + prob25 + Norway_prob25 + Norway))
mat sfp = r(estimate)
mat sfpse = r(se)
*SFN
lincom (_cons + prob75) - (_cons + prob75 + Norway_prob75 + Norway)
mat sfn = r(estimate)
mat sfnse = r(se)
 

mat Table6b = fna \ fnase \ sfp \ sfpse \ sfn\ sfnse \ obs_cntr

matrix rownames Table6b = "False Negative" "se" "Strongly False Positive" "se" "Strongly False Negative" "se" "Observations"
matrix colnames Table6b = "Difference"

esttab matrix(Table6b, fmt(3)) using ../Tables/Table6b.tex, replace 

********************************************************************************
**#7. POLICY ATTITUDES
********************************************************************************
local controls male lowage lowincome loweducation rightwing
eststo clear 
eststo: quietly reg Rmoregenerous pay [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' Rgive Rreligion [pweight=sca_weight], r

eststo: quietly reg Rreduceinequality pay [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' Rgive Rreligion [pweight=sca_weight], r

esttab using ../Tables/Table7.tex, replace ///
gaps b(3) se(3) nomtitle nostar ///
title (Policy Attitudes) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
indicate("Controls= male* lowincome* lowage* loweducation* rightwing*" "Additional controls= Rgive* Rreligion*") ///
mgroups("Unemployment benefits" "Income inequality", pattern(1 0 0 0 1 0 0 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span})) 

********************************************************************************
**#A2. COUNTRY DIFF. 
********************************************************************************
foreach v in comp_exp earn_exp unemp_exp all_treat {
	local controls male lowage lowincome loweducation rightwing
	reg pay Norway prob25 prob50 prob75 prob100 Norway_prob25 Norway_prob50 Norway_prob75 Norway_prob100 if `v'==1 [pweight=sca_weight], r
	est store est_`v'
    local estimates1 `estimates1' est_`v'
	test Norway_prob25 Norway_prob50 Norway_prob75 Norway_prob100
	return list
    mat test1_`v'= r(p)
	reg pay Norway prob25 prob50 prob75 prob100 Norway_prob25 Norway_prob50 Norway_prob75 Norway_prob100 `controls' if `v'==1 [pweight=sca_weight], r
	est store est_2_`v'
	local estimates1 `estimates2' est_2_`v'
	test Norway_prob25 Norway_prob50 Norway_prob75 Norway_prob100
	return list
    mat test2_`v'= r(p)
}
	
esttab est_comp_exp est_2_comp_exp est_earn_exp est_2_earn_exp est_unemp_exp est_2_unemp_exp est_all_treat est_2_all_treat using ../Tables/Tablea2a.tex, replace ///
gaps b(3) se(3) nomtitle nostar ///
title (Country Differences) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
indicate(Controls= male* lowincome* lowage* loweducation* rightwing*) ///
mgroups(Compensation Earnings Benefits, pattern(1 0 1 0 1 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span}))

mat ftest = test1_comp_exp, test2_comp_exp, test1_earn_exp, test2_earn_exp, test1_unemp_exp, test2_unemp_exp, test1_all_treat, test2_all_treat
matrix rownames ftest = "F-Test(interactions)"
esttab matrix(ftest, fmt(4)) using ../Tables/Tablea2b.tex, replace 

********************************************************************************
**#A3. ADDITIONAL TREAT. COMP. EXP. (HIGH/NATIONAL/ENDOW./COST) - CONTROLS 
********************************************************************************
local controls male lowage lowincome loweducation rightwing
eststo clear 
*HIGH STAKES 
eststo: quietly reg pay high `controls' if h_treatment==3 | h_treatment==7 [pweight=sca_weight], robust
eststo: quietly reg pay high `controls' if Norway==0 & h_treatment==3 | Norway==0 & h_treatment==7 [pweight=sca_weight], r
eststo: quietly reg pay high `controls' if Norway==1 & h_treatment==3 | Norway==1 & h_treatment==7 [pweight=sca_weight], r

*NATIONALITY  
eststo: quietly reg pay national `controls' if h_treatment==3 | h_treatment==6 [pweight=sca_weight], robust
eststo: quietly reg pay national `controls' if Norway==0 & h_treatment==3 | Norway==0 & h_treatment==6 [pweight=sca_weight], r
eststo: quietly reg pay national `controls' if Norway==1 & h_treatment==3 | Norway==1 & h_treatment==6 [pweight=sca_weight], r

esttab using ../Tables/Tablea3a.tex, replace ///
gaps b(3) se(3) nomtitle nostar ///
nonumber booktabs ///
mlabels (All US Norway All US Norway) ///
stats(N r2, fmt(%7.0fc %6.3f)) label ///
mgroups(Stakes National, pattern(1 0 0 1 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(})   ///
span erepeat(\cmidrule(lr){@span}))

local controls male lowage lowincome loweducation rightwing
eststo clear
*ENDOWMENT  
eststo: quietly reg pay comp `controls' if h_treatment==3 | h_treatment==8 [pweight=sca_weight], robust 
eststo: quietly reg pay comp `controls' if Norway==0 & h_treatment==3 | Norway==0 & h_treatment==8 [pweight=sca_weight], r
eststo: quietly reg pay comp `controls' if Norway==1 & h_treatment==3 | Norway==1 & h_treatment==8 [pweight=sca_weight], r

*COST
eststo: quietly reg pay lowcost highcost `controls' if h_treatment>7 & h_treatment<11 [pweight=sca_weight], robust
eststo: quietly reg pay lowcost highcost `controls' if h_treatment>7 & h_treatment<11 & Norway==0 [pweight=sca_weight], r
eststo: quietly reg pay lowcost highcost `controls' if h_treatment>7 & h_treatment<11 & Norway==1 [pweight=sca_weight], r

esttab using ../Tables/Tablea3b.tex, replace ///
gaps b(3) se(3) nomtitle nostar ///
nonumber booktabs ///
mlabels (All US Norway All US Norway) ///
stats(N r2, fmt(%7.0fc %6.3f)) label ///
mgroups(Endowment Cost, pattern(1 0 0 1 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(})   ///
span erepeat(\cmidrule(lr){@span}))

********************************************************************************
**#A5. TREAT. EFFECTS EARN. EXP.
********************************************************************************
local controls male lowage lowincome loweducation rightwing
eststo clear 
*ALL
eststo: quietly reg pay prob25 prob50 prob75 prob100 if h_treatment>15 & h_treatment<21 [pweight=sca_weight], r
eststo: quietly reg pay prob25 prob50 prob75 prob100 `controls' if h_treatment>15 & h_treatment<21 [pweight=sca_weight], r

*US
eststo: quietly reg pay prob25 prob50 prob75 prob100 if h_treatment>15 & h_treatment<21 & Norway==0 [pweight=sca_weight], r
eststo: quietly reg pay prob25 prob50 prob75 prob100 `controls' if h_treatment>15 & h_treatment<21 & Norway==0 [pweight=sca_weight], r

*NORWAY 
eststo: quietly reg pay prob25 prob50 prob75 prob100 if h_treatment>15 & h_treatment<21 & Norway==1 [pweight=sca_weight], r
eststo: quietly reg pay prob25 prob50 prob75 prob100 `controls' if h_treatment>15 & h_treatment<21 & Norway==1 [pweight=sca_weight], r

esttab using ../Tables/Tablea5.tex, replace ///
gaps b(3) se(3) booktabs nomtitle nostar ///
title (Regression Analysis of Treatment Effects - Earnings-experiment) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
mgroups(All US Norway, pattern(1 0 1 0 1 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span}))  

********************************************************************************
**#Table A7 - TREAT. COMPARISON COMP. VS EARN. 
********************************************************************************
foreach v in all_treat us nor {
	local controls male lowage lowincome loweducation rightwing
	reg pay prob25 prob50 prob75 prob100 replication replication_prob25 replication_prob50 replication_prob75 replication_prob100 if (h_treatment<6 | h_treatment>15 & h_treatment<21) & `v'==1 [pweight=sca_weight], r
		est store est_3_`v'
    local estimates3 `estimates3' est_3_`v'
		reg pay prob25 prob50 prob75 prob100 replication replication_prob25 replication_prob50 replication_prob75 replication_prob100 `controls' if (h_treatment<6 | h_treatment>15 & h_treatment<21) & `v'==1 [pweight=sca_weight], r
	est store est_4_`v'
	local estimates4 `estimates4' est_4_`v'
}

esttab est_3_all_treat est_4_all_treat est_3_us est_4_us est_3_nor est_4_nor using ../Tables/Tablea7.tex, replace ///
gaps b(3) se(3) booktabs nomtitle nostar ///
indicate (Controls=male* lowincome* loweducation* lowage* rightwing*) ///
stats(N r2, fmt(%7.0fc %6.3f)) label ///
mgroups(All US Norway, pattern(1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(})   ///
span erepeat(\cmidrule(lr){@span}))

********************************************************************************
**#A9. TREAT. EFFECTS UNEMP. EXP.
********************************************************************************
local controls male lowage lowincome loweducation rightwing
eststo clear 
*All 
eststo: quietly reg pay prob25 prob50 prob75 prob100 if h_treatment>10 & h_treatment<16 [pweight=sca_weight], robust
eststo: quietly reg pay prob25 prob50 prob75 prob100 `controls' if h_treatment>10 & h_treatment<16 [pweight=sca_weight], robust

*USA 
eststo: quietly reg pay prob25 prob50 prob75 prob100 if h_treatment>10 & h_treatment<16 & Norway==0 [pweight=sca_weight], robust
est store mainunUSA1
eststo: quietly reg pay prob25 prob50 prob75 prob100 `controls' if h_treatment>10 & h_treatment<16 & Norway==0 [pweight=sca_weight], robust

*Norway 
eststo: quietly reg pay prob25 prob50 prob75 prob100 if h_treatment>10 & h_treatment<16 & Norway==1 [pweight=sca_weight], robust
eststo: quietly reg pay prob25 prob50 prob75 prob100 `controls' if h_treatment>10 & h_treatment<16 & Norway==1 [pweight=sca_weight], robust


esttab using ../Tables/Tablea9.tex, replace ///
gaps b(3) se(3) nomtitle nostar ///
title (Regression analysis of Treatment Effects - Unemployment Benefits) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
mgroups(All US Norway, pattern(1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(})   ///
span erepeat(\cmidrule(lr){@span}))

********************************************************************************
**#A11. TREAT. EFFECTS UNEMP. EXP.
********************************************************************************
foreach v in all_treat us nor {
	reg pay prob25 prob50 prob75 prob100 if h_treatment>10 & h_treatment<16 & `v'==1 [pweight=sca_weight], r
	
	 ereturn list
	 mat `v'_obs11 = e(N)
     *FPL
     lincom 1-(_cons+prob50)-(prob25-prob50)
	 return list
	 mat fpl_`v'= r(estimate)
	 mat fplse_`v' = r(se)
     *FPU
     lincom 1-(_cons+prob50)
	 return list
	 mat fpu_`v'= r(estimate)
	 mat fpuse_`v' = r(se)
	 *SL
	 lincom 0
	 return list
	 mat sl_`v'= r(estimate)
	 mat slse_`v' = r(se)
     *SU
     lincom 2*(prob25-prob50)
	 return list
	 mat su_`v'= r(estimate)
	 mat suse_`v' = r(se)
     *FNL
     lincom _cons+prob50-(prob25-prob50)
	 return list
	 mat fnl_`v'= r(estimate)
	 mat fnlse_`v' = r(se)
     *FNU
     lincom _cons+prob50
	 return list
	 mat fnu_`v'= r(estimate)
	 mat fnuse_`v' = r(se)
}

*fpl=lower bound of share of false positive averse spectators 
*fpu=upper bound of the share of false positive averse spectators 
*sl=lower bound of the share of symmetric spectators 
*su=lower bound of the share of symmetric spectators 
*fnl=lower bound of the share of false negative averse spectators 
*fnu=upper bound of the share of false negative averse spectators

mat obs11 = all_treat_obs11, all_treat_obs11, us_obs11, us_obs11, nor_obs11, nor_obs11
mat fp = fpl_all_treat, fpu_all_treat, fpl_us, fpu_us, fpl_nor, fpu_nor 
mat fpse = fplse_all_treat, fpuse_all_treat, fplse_us, fpuse_us, fplse_nor, fpuse_nor 

mat s = sl_all_treat, su_all_treat, sl_us, su_us, sl_nor, su_nor
mat sse = slse_all_treat, suse_all_treat, slse_us, suse_us, slse_nor, suse_nor

mat fn = fnl_all_treat, fnu_all_treat, fnl_us, fnu_us, fnl_nor, fnu_nor
mat fnse = fnlse_all_treat, fnuse_all_treat, fnlse_us, fnuse_us, fnlse_nor, fnuse_nor

mat Tablea11 = fp \ fpse \ s \ sse \ fn \ fnse \ obs11
matrix rownames Tablea11 = "False positive averse" "se" "Symmetric" "se" "False negative averse" "se" "Observations"
matrix colnames Tablea11 = "Lower bound" "Upper bound" "Lower bound" "Upper bound" "Lower bound" "Upper bound"
mat list Tablea11

esttab matrix(Tablea11, fmt(3)) using ../Tables/Tablea11.tex, replace ///
title (Estimated Shares - Unemployment-experiment) 

********************************************************************************
**#A12 - TREAT. COMPARISON COMP. VS UNEMP. 
********************************************************************************
foreach v in all_treat us nor {
	local controls male lowage lowincome loweducation rightwing
	reg pay prob25 prob50 prob75 prob100 unemployment unemployment_prob25 unemployment_prob50 unemployment_prob75 unemployment_prob100 if (h_treatment<6 | h_treatment>10 & h_treatment<16) & `v'==1 [pweight=sca_weight], r
		est store est_5_`v'
    local estimates5 `estimates5' est_5_`v'
		reg pay prob25 prob50 prob75 prob100 unemployment unemployment_prob25 unemployment_prob50 unemployment_prob75 unemployment_prob100 `controls' if (h_treatment<6 | h_treatment>10 & h_treatment<16) & `v'==1 [pweight=sca_weight], r
	est store est_6_`v'
	local estimates6 `estimates6' est_6_`v'
}

esttab est_5_all_treat est_6_all_treat est_5_us est_6_us est_5_nor est_6_nor using ../Tables/Tablea12.tex, replace ///
gaps b(3) se(3) nomtitle booktabs nostar ///
indicate (Controls=male* lowincome* loweducation* lowage* rightwing*) ///
stats(N r2, fmt(%7.0fc %6.3f)) label ///
mgroups(All US Norway, pattern(1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(})   ///
span erepeat(\cmidrule(lr){@span}))

********************************************************************************
**#A13. POLITICAL DIFFERENCES
********************************************************************************
foreach var in all_treat us nor{
foreach v in all_treat comp_exp earn_exp unemp_exp{
	reg pay rightwing prob25 prob50 prob75 prob100 rightwing_prob25 rightwing_prob50 rightwing_prob75 rightwing_prob100 if `v'==1 & `var'==1 [pweight=sca_weight], r
	est store `var'_est_7_`v'
	local estimates7 `estimates7' `var'_est_7_`v'
}
}

esttab `estimates7' using ../Tables/Tablea13.tex, replace ///
gaps b(3) se(3) nomtitle nostar ///
title (Political Differences) ///
mlabels (Pooled Comp Earn Benefits Pooled Comp Earn Benefits Pooled Comp Earn Benefits) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
mgroups(All US Norway, pattern(1 0 0 0 1 0 0 0 1 0 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(})   ///
span erepeat(\cmidrule(lr){@span}))

********************************************************************************
**#A14. ESTIMATED SHARES - POLITICAL AND COUNTRY DIFFERENCES
********************************************************************************
foreach var in all_treat us nor{
 foreach v in all_treat comp_exp earn_exp unemp_exp {
	reg pay rightwing prob25 prob50 prob75 prob100 rightwing_prob25 rightwing_prob50 rightwing_prob75 rightwing_prob100 if `v'==1 & `var'==1 [pweight=sca_weight],r 
	
	 ereturn list
	 mat `var'_obs_`v' = e(N)

     *FNA
     lincom (rightwing + rightwing_prob50)
	 return list
	 mat `var'_fna_`v'= r(estimate)
	 mat `var'_fnase_`v' = r(se)
     *SFP
     lincom -(rightwing + rightwing_prob25)
	 return list
	 mat `var'_sfp_`v'= r(estimate)
  	 mat `var'_sfpse_`v' = r(se)
     *SFN
     lincom rightwing + rightwing_prob75
	 return list
	 mat `var'_sfn_`v'= r(estimate)
	 mat `var'_sfnse_`v' = r(se)
}
}
*obs = number of observations 
*fna=share of false negative averse spectators (upper bound) 
*sfp=share of strongly false positive averse spectators 
*sfn=share of strongly false negative averse spectators 

mat obs = all_treat_obs_all_treat, all_treat_obs_comp_exp, all_treat_obs_earn_exp, all_treat_obs_unemp_exp, us_obs_all_treat, us_obs_comp_exp, us_obs_earn_exp, us_obs_unemp_exp, nor_obs_all_treat, nor_obs_comp_exp, nor_obs_earn_exp, nor_obs_unemp_exp

mat fna = all_treat_fna_all_treat, all_treat_fna_comp_exp, all_treat_fna_earn_exp, all_treat_fna_unemp_exp, us_fna_all_treat, us_fna_comp_exp, us_fna_earn_exp, us_fna_unemp_exp, nor_fna_all_treat, nor_fna_comp_exp, nor_fna_earn_exp, nor_fna_unemp_exp
mat fnase = all_treat_fnase_all_treat, all_treat_fnase_comp_exp, all_treat_fnase_earn_exp, all_treat_fnase_unemp_exp, us_fnase_all_treat, us_fnase_comp_exp, us_fnase_earn_exp, us_fnase_unemp_exp, nor_fnase_all_treat, nor_fnase_comp_exp, nor_fnase_earn_exp, nor_fnase_unemp_exp

mat list fna
mat list fnase

mat sfp = all_treat_sfp_all_treat, all_treat_sfp_comp_exp, all_treat_sfp_earn_exp, all_treat_sfp_unemp_exp, us_sfp_all_treat, us_sfp_comp_exp, us_sfp_earn_exp, us_sfp_unemp_exp, nor_sfp_all_treat, nor_sfp_comp_exp, nor_sfp_earn_exp, nor_sfp_unemp_exp
mat sfpse = all_treat_sfpse_all_treat, all_treat_sfpse_comp_exp, all_treat_sfpse_earn_exp, all_treat_sfpse_unemp_exp, us_sfpse_all_treat, us_sfpse_comp_exp, us_sfpse_earn_exp, us_sfpse_unemp_exp, nor_sfpse_all_treat, nor_sfpse_comp_exp, nor_sfpse_earn_exp, nor_sfpse_unemp_exp

mat list fna
mat list fnase

mat sfn = all_treat_sfn_all_treat, all_treat_sfn_comp_exp, all_treat_sfn_earn_exp, all_treat_sfn_unemp_exp, us_sfn_all_treat, us_sfn_comp_exp, us_sfn_earn_exp, us_sfn_unemp_exp, nor_sfn_all_treat, nor_sfn_comp_exp, nor_sfn_earn_exp, nor_sfn_unemp_exp
mat sfnse = all_treat_sfnse_all_treat, all_treat_sfnse_comp_exp, all_treat_sfnse_earn_exp, all_treat_sfnse_unemp_exp, us_sfnse_all_treat, us_sfnse_comp_exp, us_sfnse_earn_exp, us_sfnse_unemp_exp, nor_sfnse_all_treat, nor_sfnse_comp_exp, nor_sfnse_earn_exp, nor_sfnse_unemp_exp

mat Tablea14a = fna \ fnase \ sfp \ sfpse \ sfn \ sfnse \ obs 
matrix rownames Tablea14a = "False Negative" "se" "Strongly False Positive" "se" "Strongly False Negative" "se" "Observations"
matrix colnames Tablea14a = "Pooled" "Comp" "Earn" "Unemp" "Pooled" "Comp" "Earn" "Unemp" "Pooled" "Comp" "Earn" "Unemp"

esttab matrix(Tablea14a, fmt(3)) using ../Tables/Tablea14a.tex, replace ///
title(Estimated shares - Political and Country Differences)

foreach v in all_treat comp_exp earn_exp unemp_exp {
	reg pay Norway prob25 prob50 prob75 prob100 Norway_prob25 Norway_prob50 Norway_prob75 Norway_prob100 if `v'==1 [pweight=sca_weight], robust
	 ereturn list
	 mat `v'_obs14 = e(N)
    *FNA
    lincom (_cons + prob50) - (_cons + prob50 + Norway_prob50 + Norway)
	mat fna_`v'= r(estimate)
	mat fnase_`v' = r(se)
    *SFP
    lincom (1-(_cons + prob25)) - (1-(_cons + prob25 + Norway_prob25 + Norway))
	mat sfp_`v'= r(estimate)
  	mat sfpse_`v' = r(se)
    *SFN
    lincom (_cons + prob75) - (_cons + prob75 + Norway_prob75 + Norway)
	mat sfn_`v'= r(estimate)
	mat sfnse_`v' = r(se)
}

mat obs14 = all_treat_obs14, comp_exp_obs14, earn_exp_obs14, unemp_exp_obs14
mat fnac = fna_all_treat, fna_comp_exp, fna_earn_exp, fna_unemp_exp
mat fnasec = fnase_all_treat, fnase_comp_exp, fnase_earn_exp, fnase_unemp_exp

mat sfpc = sfp_all_treat, sfp_comp_exp, sfp_earn_exp, sfp_unemp_exp
mat sfpsec = sfpse_all_treat, sfpse_comp_exp, sfpse_earn_exp, sfpse_unemp_exp

mat sfnc = sfn_all_treat, sfn_comp_exp, sfn_earn_exp, sfn_unemp_exp
mat sfnsec = sfnse_all_treat, sfnse_comp_exp, sfnse_earn_exp, sfnse_unemp_exp

mat Tablea14b = fnac \ fnasec \ sfpc \ sfpsec \ sfnc \ sfnsec \ obs14

matrix rownames Tablea14b = "False Negative" "se" "Strongly False Positive" "se" "Strongly False Negative" "se" "Observations"
matrix colnames Tablea14b = "Pooled" "Compensation" "Earnings" "Unemployment"

esttab matrix(Tablea14b, fmt(3)) using ../Tables/Tablea14b.tex, replace 

********************************************************************************
**#A15. POLICY ATTITUDES ASSOCIATIONS
********************************************************************************
foreach v in male loweducation lowincome lowage rightwing Rgive Rreligion{
	reg Rmoregenerous `v' [pweight=sca_weight], r
	est store est_8_`v'
	local estimates8 `estimates8' est_8_`v'
	
	reg Rreduceinequality `v' [pweight=sca_weight], r
	est store est_9_`v'
	local estimates9 `estimates9' est_9_`v'
}

esttab `estimates8' using ../Tables/Tablea15a.tex, replace ///
gaps b(3) se(3) nomtitle nostar ///
title (Panel A: Unemployment) ///
stats (N r2, fmt(%7.0fc %6.3f)) label 

esttab `estimates9' using ../Tables/Tablea15b.tex, replace ///
gaps b(3) se(3) nomtitle nostar ///
title (Panel B: Income Inequality) ///
stats (N r2, fmt(%7.0fc %6.3f)) label 

********************************************************************************
**#A16. POLICY ATTITUDES PROB =.5
********************************************************************************
eststo clear 
local controls male lowage lowincome loweducation rightwing
eststo: quietly reg Rmoregenerous pay if pooled50==1 [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt if pooled50==1 [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' if pooled50==1 [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' Rgive Rreligion if pooled50==1 [pweight=sca_weight], r

eststo: quietly reg Rreduceinequality pay [pweight=sca_weight] if pooled50==1, r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt if pooled50==1 [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' if pooled50==1 [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' Rgive Rreligion if pooled50==1 [pweight=sca_weight], r

esttab using ../Tables/Tablea16.tex, replace ///
gaps b(3) se(3) nomtitle booktabs nostar  ///
title (Policy Attitudes for Treatments with 50% Probability of a False Claim) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
indicate("Controls= male* lowincome* lowage* loweducation* rightwing*" "Additional controls= Rgive* Rreligion*") ///
mgroups("Unemployment benefits" "Income inequality", pattern(1 0 0 0 1 0 0 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span})) 
	
********************************************************************************
**#A17. POLICY ATTITUDES US
********************************************************************************
eststo clear 
local controls male lowage lowincome loweducation rightwing
eststo: quietly reg Rmoregenerous pay if Norway==0  [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt if Norway==0  [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' if Norway==0  [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' Rgive Rreligion if Norway==0  [pweight=sca_weight], r

eststo: quietly reg Rreduceinequality pay [pweight=sca_weight] if Norway==0 , r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt if Norway==0  [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' if Norway==0  [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' Rgive Rreligion if Norway==0  [pweight=sca_weight], r

esttab using ../Tables/Tablea17.tex, replace ///
gaps b(3) se(3) nomtitle booktabs nostar ///
title (Policy Attitudes - US) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
indicate("Controls= male* lowincome* lowage* loweducation* rightwing*" "Additional controls= Rgive* Rreligion*") ///
mgroups("Unemployment benefits" "Income inequality", pattern(1 0 0 0 1 0 0 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span})) 
	
********************************************************************************
**#A18. POLICY ATTITUDES NORWAY
********************************************************************************	
eststo clear 
local controls male lowage lowincome loweducation rightwing
eststo: quietly reg Rmoregenerous pay if Norway==1  [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt if Norway==1  [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' if Norway==1  [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' Rgive Rreligion if Norway==1  [pweight=sca_weight], r

eststo: quietly reg Rreduceinequality pay [pweight=sca_weight] if Norway==1 , r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt if Norway==1  [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' if Norway==1  [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' Rgive Rreligion if Norway==1  [pweight=sca_weight], r

esttab using ../Tables/Tablea18.tex, replace ///
gaps b(3) se(3) nomtitle booktabs nostar ///
title (Policy Attitudes - Norway) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
indicate("Controls= male* lowincome* lowage* loweducation* rightwing*" "Additional controls= Rgive* Rreligion*") ///
mgroups("Unemployment benefits" "Income inequality", pattern(1 0 0 0 1 0 0 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span})) 
	
********************************************************************************
**#A19. POLICY ATTITUDES COMP.EXP.
********************************************************************************	
eststo clear 
local controls male lowage lowincome loweducation rightwing
eststo: quietly reg Rmoregenerous pay if h_treatment<6  [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt if h_treatment<6  [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' if h_treatment<6  [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' Rgive Rreligion if h_treatment<6  [pweight=sca_weight], r

eststo: quietly reg Rreduceinequality pay [pweight=sca_weight] if h_treatment<6 , r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt if h_treatment<6  [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' if h_treatment<6  [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' Rgive Rreligion if h_treatment<6  [pweight=sca_weight], r

esttab using ../Tables/Tablea19.tex, replace ///
gaps b(3) se(3) nomtitle booktabs nostar ///
title (Policy Attitudes - Compensation-experiment) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
indicate("Controls= male* lowincome* lowage* loweducation* rightwing*" "Additional controls= Rgive* Rreligion*") ///
mgroups("Unemployment benefits" "Income inequality", pattern(1 0 0 0 1 0 0 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span})) 
	
********************************************************************************
**#A20. POLICY ATTITUDES EARN.EXP.
********************************************************************************
eststo clear 
local controls male lowage lowincome loweducation rightwing
eststo: quietly reg Rmoregenerous pay if h_treatment>15 & h_treatment<21  [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt if h_treatment>15 & h_treatment<21  [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' if h_treatment>15 & h_treatment<21  [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' Rgive Rreligion if h_treatment>15 & h_treatment<21  [pweight=sca_weight], r

eststo: quietly reg Rreduceinequality pay [pweight=sca_weight] if h_treatment>15 & h_treatment<21 , r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt if h_treatment>15 & h_treatment<21  [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' if h_treatment>15 & h_treatment<21  [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' Rgive Rreligion if h_treatment>15 & h_treatment<21  [pweight=sca_weight], r

esttab using ../Tables/Tablea20.tex, replace ///
gaps b(3) se(3) nomtitle booktabs nostar ///
title (Policy Attitudes - Earnings-experiment) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
indicate("Controls= male* lowincome* lowage* loweducation* rightwing*" "Additional controls= Rgive* Rreligion*") ///
mgroups("Unemployment benefits" "Income inequality", pattern(1 0 0 0 1 0 0 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span})) 
	
********************************************************************************
**#A21. POLICY ATTITUDES UNEMP.EXP.
********************************************************************************
eststo clear 
local controls male lowage lowincome loweducation rightwing
eststo: quietly reg Rmoregenerous pay if h_treatment>10 & h_treatment<16 [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt if h_treatment>10 & h_treatment<16  [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' if h_treatment>10 & h_treatment<16 [pweight=sca_weight], r
eststo: quietly reg Rmoregenerous pay Rfullycompensated Runemploymentbenefitshurt `controls' Rgive Rreligion if h_treatment>10 & h_treatment<16 [pweight=sca_weight], r

eststo: quietly reg Rreduceinequality pay [pweight=sca_weight] if h_treatment>10 & h_treatment<16, r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt if h_treatment>10 & h_treatment<16 [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' if h_treatment>10 & h_treatment<16 [pweight=sca_weight], r
eststo: quietly reg Rreduceinequality pay Rinequalityunfair Rinequalityhurt `controls' Rgive Rreligion if  h_treatment>10 & h_treatment<16 [pweight=sca_weight], r

esttab using ../Tables/Tablea21.tex, replace ///
gaps b(3) se(3) nomtitle booktabs nostar ///
title (Policy Attitudes - Earnings-experiment) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
indicate("Controls= male* lowincome* lowage* loweducation* rightwing*" "Additional controls= Rgive* Rreligion*") ///
mgroups("Unemployment benefits" "Income inequality", pattern(1 0 0 0 1 0 0 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span})) 
	
********************************************************************************
**#A22. POLICY ATTITUDES DISABILITY
********************************************************************************
eststo clear 
local controls male lowage lowincome loweducation rightwing
*ALL
eststo: quietly reg Rdisbenefitsmoregenerous pay [pweight=sca_weight], r
eststo: quietly reg Rdisbenefitsmoregenerous pay Rdisbenefitsfullycompensated Rdisbenefitshurt [pweight=sca_weight], r
eststo: quietly reg Rdisbenefitsmoregenerous pay Rdisbenefitsfullycompensated Rdisbenefitshurt `controls' [pweight=sca_weight], r
eststo: quietly reg Rdisbenefitsmoregenerous pay Rdisbenefitsfullycompensated Rdisbenefitshurt `controls' Rgive Rreligion [pweight=sca_weight], r

*USA
eststo: quietly reg Rdisbenefitsmoregenerous pay if Norway==0 [pweight=sca_weight], r
eststo: quietly reg Rdisbenefitsmoregenerous pay Rdisbenefitsfullycompensated Rdisbenefitshurt if Norway==0 [pweight=sca_weight], r
eststo: quietly reg Rdisbenefitsmoregenerous pay Rdisbenefitsfullycompensated Rdisbenefitshurt `controls' if Norway==0 [pweight=sca_weight], r
eststo: quietly reg Rdisbenefitsmoregenerous pay Rdisbenefitsfullycompensated Rdisbenefitshurt `controls' Rgive Rreligion if Norway==0 [pweight=sca_weight], r

*NORWAY
eststo: quietly reg Rdisbenefitsmoregenerous pay if Norway==1 [pweight=sca_weight], r
eststo: quietly reg Rdisbenefitsmoregenerous pay Rdisbenefitsfullycompensated Rdisbenefitshurt if Norway==1 [pweight=sca_weight], r
eststo: quietly reg Rdisbenefitsmoregenerous pay Rdisbenefitsfullycompensated Rdisbenefitshurt `controls' if Norway==1 [pweight=sca_weight], r
eststo: quietly reg Rdisbenefitsmoregenerous pay Rdisbenefitsfullycompensated Rdisbenefitshurt `controls' Rgive Rreligion if Norway==1 [pweight=sca_weight], r

esttab using ../Tables/Tablea22.tex, replace ///
gaps b(3) se(3) nomtitle booktabs nostar ///
title (Policy Attitudes - Disability Experiment) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
indicate("Controls= male* lowincome* lowage* loweducation* rightwing*" "Additional controls= Rgive* Rreligion*") ///
mgroups(All US Norway, pattern(1 0 0 0 1 0 0 0 1 0 0 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span})) 
	
********************************************************************************
**#A23. UNEMP VS. DISABILITY
********************************************************************************
foreach v in all_treat us nor{
    local controls male lowage lowincome loweducation rightwing
    reg pay dis_unemp if `v'==1 [pweight=sca_weight], r
	est store est_10_`v'
	local estimates10 `estimates10' est_10_`v'
	
	reg pay dis_unemp `controls' if `v'==1 [pweight=sca_weight], r
	est store est_11_`v'
	local estimates11 `estimates8' est_11_`v'
}

esttab est_10_all_treat est_11_all_treat est_10_us est_11_us est_10_nor est_11_nor using ../Tables/Tablea23.tex, replace ///
gaps b(3) se(3) nomtitle fragment booktabs nostar ///
title (Regression Analysis of Treatment Effects - Unemployment Benefits Vs. Disability Benefits) ///
stats (N r2, fmt(%7.0fc %6.3f)) label ///
mgroups(All US Norway, pattern(1 0 1 0 1 0) ///
      prefix(\multicolumn{@span}{c}{) suffix(})   ///
    span erepeat(\cmidrule(lr){@span}))



cap log close

********************************************************************************
**#IN-TEXT NUMBERS
********************************************************************************
**Results Compensation-experiment
*Figure1
reg pay prob25 prob50 prob75 prob100 if h_treatment<6, r
*pay when certain correct claim
lincom _cons
*do not pay when certaion false claim
lincom 1 - (_cons + prob100)

*Table 3 col 1
*share paying the compensation when the probability of a false claim is 0.5
reg pay prob25 prob50 prob75 prob100 if h_treatment<6 [pweight=sca_weight], r
lincom _cons + prob50

reg pay prob25 prob50 prob75 prob100 if h_treatment<6 [pweight=sca_weight], r
*difference false negative averse and false positive averse pooled
lincom _cons + prob50 - (1-(_cons + prob50))

*Table 3 col 3-6
reg pay prob25 prob50 prob75 prob100 if h_treatment<6 & Norway==0 [pweight=sca_weight], r
*difference false negative averse and false positive averse us
lincom _cons + prob50 - (1-(_cons + prob50))

reg pay prob25 prob50 prob75 prob100 if h_treatment<6 & Norway==1 [pweight=sca_weight], r
*difference false negative averse and false positive averse nor
lincom _cons + prob50 - (1-(_cons + prob50))

*Figure 2 
reg pay prob25 prob50 prob75 prob100 if h_treatment<6 [pweight=sca_weight], robust
*strongly false positive pooled
lincom 1-(_cons + prob25)
*strongly false negative pooled
lincom _cons + prob75

reg pay prob25 prob50 prob75 prob100 if h_treatment<6 & Norway==0 [pweight=sca_weight], robust
*strongly false positive us
lincom 1-(_cons + prob25)
*strongly false negative us
lincom _cons + prob75

reg pay prob25 prob50 prob75 prob100 if h_treatment<6 & Norway==1 [pweight=sca_weight], robust
*strongly false positive nor
lincom 1-(_cons + prob25)
*strongly false negative nor
lincom _cons + prob75

**Results additional treatments
*Table 5
*pay when high stakes us
reg pay high if Norway==0 & h_treatment==3 | Norway==0 & h_treatment==7 [pweight=sca_weight], r
lincom _cons + high 
*pay when high stakes nor
reg pay high if Norway==1 & h_treatment==3 | Norway==1 & h_treatment==7 [pweight=sca_weight], r
lincom _cons + high 

**Results Earnings-experiment
*Figure1
reg pay prob25 prob50 prob75 prob100 if h_treatment>15 & h_treatment<21, r
*pay when certain correct claim
lincom _cons
*do not pay when certaion false claim
lincom 1 - (_cons + prob100)

**Results Unemployment-experiment
reg pay prob25 prob50 prob75 prob100 if h_treatment>10 & h_treatment<16, r
*Figure 4
*pay when certain correct claim
lincom _cons
*do not pay when certaion false claim
lincom 1 - (_cons + prob100)

