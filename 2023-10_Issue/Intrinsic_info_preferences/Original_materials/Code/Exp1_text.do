use "$root/Data/Output/Exp1.dta", clear

 
**footnote 10
corr wta_min infostrength  

 
/*
p.12 of WP: average premia for the positively skewed structures over negatively skewed ones are large, and at least as large as the premium for full early resolution over full late resolution (two-sample Wilcoxon rank-sum tests for T1 vs. T2: p = 0.013; T1 vs. T3: p = 0.951; T1 vs. T4: p = 0.37). 
*/
 
foreach zz in 2 3 4{
preserve
keep if  treatment==1 | treatment==`zz' 
ranksum infoprem, by(treatment)
restore
}
 
 
/*
p. 12 of WP: 87% of individuals demand (positively skewed) information in T5 whereas only 72% of individuals demand (negatively skewed) information in T7 (two-sided χ2 test, p = .035). 
*/

preserve
keep if  treatment==7 | treatment==5 
tabulate treatment choice, chi2
restore

/*footnote 12: The proportion in T9 falls in the middle (T9 vs. T5: p = 0.361; T9 vs. T7: p = 0.243). Proportions of information takers in T6–T10–T8 are ordered in the same way but are not statistically different.
*/

 preserve
keep if  treatment==9 | treatment==5 
tabulate treatment choice, chi2
restore


preserve
keep if  treatment==7 | treatment==9 
tabulate treatment choice, chi2
restore

preserve
keep if  treatment==8 | treatment==6 
tabulate treatment choice, chi2
restore
preserve
keep if  treatment==8 | treatment==10
tabulate treatment choice, chi2
restore
preserve
keep if  treatment==10| treatment==6
tabulate treatment choice, chi2
restore
  
  
/*
p.12 of WP: Also, the information premia for the positively skewed structures are the highest,
while the premia for the negatively skewed signals are the lowest (two-sample Wilcoxon rank-
sum tests, T5 vs. T7: p = 0.007, T6 vs. T8: p = .067). 
*/  

preserve
keep if  treatment==5 | treatment==7
ranksum infoprem, by(treatment)
restore

preserve
keep if  treatment==6 | treatment==8
ranksum infoprem, by(treatment)
restore

/*
p.13 of WP: information avoidance falls from 30% in T1 to 13% in T5 (two-sided χ2 test, p = 0.011) and to 18% in T6 (p = 0.073). In contrast, comparing T1 to T7 and T8 shows that information avoidance is not lower with the negatively skewed signals (two-sided χ2 tests, T1 vs. T7: p = 0.771; T1 vs. T8, p = 0.356),
*/


foreach zz in 5 6 7 8{ 
preserve
keep if  treatment==1 | treatment==`zz' 
tabulate treatment choice, chi2
restore
}
 


/*
p.14 of WP:  demand for information is higher for the positively skewed signals than for the fully informative signal at almost every point in the demand curve (two-sample Wilcoxon rank-sum tests, T1 vs. T5: p < .001; T1 vs. T6: p = 0.158). in contrast, comparing T1 to T7 and T8 ...  information pre-mia are also indistinguishable (two-sample Wilcoxon rank-sum tests, T1 vs. T7: p = 0.506; T1 vs. T8, p = 0.864)
*/

foreach zz in 5 6 7 8{
preserve
keep if  treatment==1 | treatment==`zz'
ranksum infoprem, by(treatment)
restore
}
 
   
