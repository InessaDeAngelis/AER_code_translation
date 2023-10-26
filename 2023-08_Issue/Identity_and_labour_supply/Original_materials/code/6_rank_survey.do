* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* PROJECT:			Does identity affect labor supply?
* RESEARCHER:		Suanna Oh
* TASK:				Analyze rank survey data
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*					<< Sections >>
* 
*		1.  Reshaping data
*		2.  Table 1: Caste ranking
*		3.  Table A1: Consistency of caste rank scores
*		4.  Figure A2 Panel A: Ranks assigned to castes
*		5.  Figure A2 Panel B: Ranks assigned to castes
* 		
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *




* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Reshaping data
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

use "$path/data/rank_survey.dta", clear


* rename variables to use numbers instead of strings

rename c1_kaibarta caste_ranking_1
rename c1_sundhi caste_ranking_2
rename c1_dhoba caste_ranking_3
rename c1_kela caste_ranking_4
rename c1_mochi caste_ranking_5
rename c1_pana caste_ranking_6
rename c1_hadi caste_ranking_7
rename c2_mali caste_ranking_8
rename c2_brahman caste_ranking_9
rename c2_gokha caste_ranking_10
rename c2_kandara caste_ranking_11
rename c2_tanla caste_ranking_12
rename c2_bhoi caste_ranking_13
rename c2_bauri caste_ranking_14
rename c2_ghusuria caste_ranking_15
rename c2_chamar caste_ranking_16

reshape long caste_ranking_ , i(pid) j(caste)

	* labelling values in variable 'caste'
	label define caste_name 1 Kaibarta 2 Sundhi 3 Dhoba 4 Kela 5 Mochi 6 Pana 7 Hadi 8 Mali 9 Brahman 10 Gokha ///
			11 Kandara 12 Tanla 13 Bhoi 14 Bauri 15 Ghusuria 16 Chamar 
	label values caste caste_name 

rename caste_ranking_ caste_ranking 
label var caste_ranking "Rank score"

* ordering variables for ease of analysis 
order pid caste caste_ranking, first

gen p_kaibarta = caste == 1
gen p_sundhi = caste == 2
gen p_dhoba = caste == 3
gen p_kela = caste == 4
gen p_mochi = caste == 5
gen p_pana = caste == 6
gen p_hadi = caste == 7

label var p_sundhi "Sundhi"
label var p_dhoba "Dhoba"
label var p_kela "Kela"
label var p_mochi "Mochi"
label var p_pana "Pana"
label var p_hadi "Hadi"


* experimental castes
gen maincastes = inrange(caste,1,7)
gen scopingcastes = inlist(caste,9,10,11,12,13,14)



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table 1: Caste ranking
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

table caste if inrange(caste,1,7), c(mean caste_ranking)
// Enter into Table 1: tab_ranking



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Table A1: Consistency of caste rank scores
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

// regressing the rank controlling for an indicator for whether person’s caste = caste in question
gen own_caste = 0
replace own_caste = 1 if caste_code == 42 & p_kaibarta==1
replace own_caste = 1 if caste_code == 71 & p_sundhi==1
replace own_caste = 1 if caste_code == 28 & p_dhoba==1
replace own_caste = 1 if caste_code == 48 & p_kela==1
replace own_caste = 1 if caste_code == 62 & p_mochi==1
replace own_caste = 1 if caste_code == 67 & p_pana==1
replace own_caste = 1 if caste_code == 38 & p_hadi==1
label var own_caste "Own caste"



// regressing the rank given on the indicator for each caste, omitting kaibarta
reg caste_ranking p_sundhi p_dhoba p_kela p_mochi p_pana p_hadi if caste <=7 , cl(pid)
	estadd local note1 "All"
test p_sundhi == p_dhoba
test p_dhoba == p_kela
test p_kela == p_mochi
test p_mochi == p_pana
test p_pana == p_hadi


eststo clear
eststo: reg caste_ranking p_sundhi p_dhoba p_kela p_mochi p_pana p_hadi own_caste if caste <=7, cl(pid)
	estadd local note1 "All types"
	qui summarize caste_ranking if p_kaibarta==1 
	qui estadd scalar cont = r(mean)
	test p_sundhi == p_dhoba
	qui estadd scalar pval1 = r(p)
	test p_dhoba == p_kela
	qui estadd scalar pval2 = r(p)	
	test p_kela == p_mochi
	qui estadd scalar pval3 = r(p)		
	test p_mochi == p_pana
	qui estadd scalar pval4 = r(p)		
	test p_pana == p_hadi
	qui estadd scalar pval5 = r(p)		

//regressing caste indicators conditional on survey type
eststo: reg caste_ranking p_sundhi p_dhoba p_kela p_mochi p_pana p_hadi own_caste if caste <=7 & survey_type == "general", cl(pid)
	estadd local note1 "General"
	qui summarize caste_ranking if p_kaibarta==1 & survey_type == "general"
	qui estadd scalar cont = r(mean)
	test p_sundhi == p_dhoba
	qui estadd scalar pval1 = r(p)
	test p_dhoba == p_kela
	qui estadd scalar pval2 = r(p)	
	test p_kela == p_mochi
	qui estadd scalar pval3 = r(p)		
	test p_mochi == p_pana
	qui estadd scalar pval4 = r(p)		
	test p_pana == p_hadi
	qui estadd scalar pval5 = r(p)	
	
eststo: reg caste_ranking p_sundhi p_dhoba p_kela p_mochi p_pana p_hadi own_caste if caste <=7 & survey_type == "food", cl(pid)
	estadd local note1 "Food-related"
	qui summarize caste_ranking if p_kaibarta==1 & survey_type == "food"
	qui estadd scalar cont = r(mean)
	test p_sundhi == p_dhoba
	qui estadd scalar pval1 = r(p)
	test p_dhoba == p_kela
	qui estadd scalar pval2 = r(p)	
	test p_kela == p_mochi
	qui estadd scalar pval3 = r(p)		
	test p_mochi == p_pana
	qui estadd scalar pval4 = r(p)		
	test p_pana == p_hadi
	qui estadd scalar pval5 = r(p)	
	
eststo: reg caste_ranking p_sundhi p_dhoba p_kela p_mochi p_pana p_hadi own_caste if caste <=7 & survey_type == "water", cl(pid)
	estadd local note1 "Water-related"
	qui summarize caste_ranking if p_kaibarta==1 & survey_type == "water"
	qui estadd scalar cont = r(mean)
	test p_sundhi == p_dhoba
	qui estadd scalar pval1 = r(p)
	test p_dhoba == p_kela
	qui estadd scalar pval2 = r(p)	
	test p_kela == p_mochi
	qui estadd scalar pval3 = r(p)		
	test p_mochi == p_pana
	qui estadd scalar pval4 = r(p)		
	test p_pana == p_hadi
	qui estadd scalar pval5 = r(p)	


#delimit ;
local tablerow p_sundhi p_dhoba p_kela p_mochi p_pana p_hadi own_caste;

esttab using "$path/output/tab_ranking_reg.tex", replace 
	b(3) se booktabs nostar nonotes nomtitles
	label style(tex) gaps keep(`tablerow') order(`tablerow') 
	stats(note1 cont none pval1 pval2 pval3 pval4 pval5 N, labels("Instruction type" "Mean rank for Kaibarta" "P-val: equality of ranks" "\hspace{1em} Sundhi = Dhoba" "\hspace{1em} Dhoba = Kela" "\hspace{1em} Kela = Mochi" "\hspace{1em} Mochi = Pana" "\hspace{1em} Pana = Hadi" "Observations") fmt(%50s %9.2fc %9.2fc %9.2fc %9.2fc %9.2fc %9.2fc %9.2fc %9.0fc)) 
	prehead("\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} 
	\begin{tabular}     
	{@{\extracolsep{4pt}}p{4.5cm}*{7}{>{\centering\arraybackslash}m{2.5cm}}@{}} 			        
	\toprule
	& \multicolumn{4}{c}{\textbf{Rank assigned to caste}} \bigstrut \\ 
	\cline{2-5} \addlinespace");
#delimit cr		




* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Figure A2 Panel A: Ranks assigned to castes
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


***** Bar graph of ranks assigned

gen plotval=1/209

#delimit ;
graph bar (sum) plotval if maincastes==1, over(caste_ranking) over(caste, label) asyvars stack ytitle("Shares of respondents assigning rank") 
	graphregion(color(white)) bar(1, color("245 171 41")) bar(2, color("219 153 37")) bar(3, color("181 110 81")) bar(4, color("158 81 92")) 
	bar(5, color("138 47 99")) bar(6, color("120 33 82")) bar(7, color("82 32 61")) intensity(*1.2) ylabel(,nogrid) 
	legend(order(1 "Rank 1" 7 "Rank 7") position(6) col(2)) ;
#delimit cr

graph export "$path/output/fig_ranking_spread.pdf", replace





* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*		Figure A2 Panel B: Ranks assigned to castes
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

** Use wide data

use "$path/data/rank_survey.dta", clear


foreach x of varlist c1_kaibarta c1_sundhi c1_kela c1_pana c2_brahman c2_gokha c2_kandara c2_tanla c2_bhoi c2_bauri {
	if "`x'"=="c1_kaibarta" local own_code=42
	else if "`x'"=="c1_pana" local own_code=67
	else if "`x'"=="c1_sundhi" local own_code=71
	else if "`x'"=="c1_kela" local own_code=48
	else if "`x'"=="c2_brahman" local own_code=24
	else if "`x'"=="c2_gokha" local own_code=35
	else if "`x'"=="c2_kandara" local own_code=45
	else if "`x'"=="c2_tanla" local own_code=76
	else if "`x'"=="c2_bhoi" local own_code=21
	else if "`x'"=="c2_bauri" local own_code=17
	else local own_code=0
	
	gen `x'_dlose=`x'>c1_dhoba if !mi(`x') & caste_code!=`own_code' & caste_code!=28
	gen `x'_mlose=`x'>c1_mochi if !mi(`x') & caste_code!=`own_code' & caste_code!=62
	gen `x'_hlose=`x'>c1_hadi if !mi(`x') & caste_code!=`own_code' & caste_code!=38
}

summ c2_brahman_dlose c2_brahman_mlose c2_brahman_hlose c1_kaibarta_dlose c1_kaibarta_mlose c1_kaibarta_hlose c1_sundhi_dlose c1_sundhi_mlose c1_sundhi_hlose c2_tanla_dlose c2_tanla_mlose c2_tanla_hlose c2_bhoi_dlose c2_bhoi_mlose c2_bhoi_hlose
summ c1_kela_dlose c1_kela_mlose c1_kela_hlose c2_gokha_dlose c2_gokha_mlose c2_gokha_hlose  
summ c2_bauri_dlose c2_bauri_mlose c2_bauri_hlose c2_kandara_dlose c2_kandara_mlose c2_kandara_hlose c1_pana_dlose c1_pana_mlose c1_pana_hlose   

rename c1_* c2_*

gen cord = _n if _n<=10
lab define cord 1 "Brahman" 2 "Kaibarta" 3 "Sundhi" 4 "Bhoi" 5 "Tanla" ///
	6 "Kela" 7 "Gokha" 8 "Bauri" 9 "Kandara" 10 "Pana" , replace
label values cord cord

gen dlose=.
gen mlose=.
gen hlose=.

local i=1
foreach x in brahman kaibarta sundhi bhoi tanla kela gokha bauri kandara pana{
	foreach y in dlose mlose hlose{
		qui summ c2_`x'_`y'
		replace `y' = r(mean) if _n==`i' 
	}	
	local `i++'
}	

graph bar dlose mlose hlose, over(cord, label) graphregion(color(white)) ylabel(0 0.25 0.5 0.75 1, glstyle(dot)) yline(0.5, lstyle(solid) lcolor(gs11)) ///
	bar(1, color("245 171 41")) bar(2, color("158 81 92")) bar(3, color("120 33 82")) intensity(*1.2)  ///
	ytitle("Shares of respondents assigning rank") legend(order(1 "Lower than Dhoba" 2 "Lower than Mochi" 3 "Lower than Hadi") position(6) col(3)) 
	
graph export "$path/output/fig_ranking_match.pdf", replace

 

	
