
use  "$root/Data/Output/alzheimer.dta", clear


ereturn clear
/*
p.20 of WP: 28% of individuals avoid learning about the exact combination of APOE alleles.
However, information avoidance decreases to 24% for the positively skewed test. In contrast,
avoidance of the negatively skewed test is about the same as the avoidance of learning
about both alleles, at 29%.
*/
gen avoid_exact=1-exact_learn
gen avoid_safe =1-safe_learn
gen avoid_risky = 1- risk_learn
summarize   avoid_exact   avoid_safe avoid_risky

 /*
p.20 of WP: In summary, the results show that people are more likely to take up information that is positively skewed compared with (i) information that is strictly more informative but relatively more negatively skewed (McNemar χ2 = 16.1, p < 0.001) and (ii) information that is negatively skewed (McNemar χ2 = 23.17, p < 0.001). We find no difference between the demand for negatively skewed and more informative information structures (McNemar χ2 = 2.33, p = 0.13).
 */

tab exact_learn  safe_learn
mcci 141 34 8 443

tab risk_learn  safe_learn
mcci 142 40 7 437

tab exact_learn  risk_learn
mcci 168 7 14 437



  /*
p.20  of WP: takers generally want information: 98% of them also take
the positively skewed test and 97% also take the negatively skewed test. Figure 4 shows the inverse demand curves. Among takers (Panel (A)), the willingness to pay for information (relative to no information) is generally positive. Moreover, the average willingness to pay for the most informative test ($26.3) is larger than that for negative skew ($22.3), which is in turn higher than for positive skew ($20.4) (paired t-tests, p < 0.001).
*/

sum risk_learn  safe_learn if exact_learn ==1

ttest risk_wtp == exact_wtp if exact_learn == 1   
ttest risk_wtp == safe_wtp if exact_learn == 1   


/*
p.20  of WP: Although all of them reject the most informative structure and only 4% would take the
negatively skewed test, 19% were willing to take the positively skewed test (negative vs.
positive, McNemar χ2 = 23.52, p < 0.001).
*/

sum risk_learn  safe_learn if exact_learn ==0

tab risk_learn  safe_learn if exact_learn ==0
mcci 139 29 2 5


/*
p.20/21 of WP: Avoiders’ willingness to pay also reflects this ranking: the average subsidy they required for the positively skewed test is $29.4, which is significantly lower than the average subsidy required to learn about the risky allele ($37.1, paired t-test p = 0.001) or both alleles ($40.2, paired t-test p < 0.001).
*/
ttest risk_wtp == exact_wtp if exact_learn == 0   
ttest risk_wtp == safe_wtp if exact_learn == 0 
  
/*

p.21 As apparent from Panel (B) in Figure 4, the inverse demand curves reveal an even stronger result: the demand for positively skewed tests dominates the demand for other tests at each price point (Wilcoxon matched-pairs signed-rank tests, both $p<0.001$). The results indicate that providing positively skewed information may indeed reduce information avoidance: 23.4\% of   those who avoid  the most informative test, and even when paid \$5 to do so, would demand to take the positively skewed test if it were free. A total of 9.25\% of them would pay a positive amount to take it.
*/  
  
 signrank exact_wtp = safe_wtp if exact_learn == 0  
 signrank risk_wtp = safe_wtp if exact_learn == 0  
  
  
/*Appendix: Among the 626 respondents, 55\% of them are female. The average  age is 53 and the average expected age of death is 82*/
sum age age_death gender

 
 
