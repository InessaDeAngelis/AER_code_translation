
use "$root/Data/Output/Exp2.dta", clear
  
/*
p.16 of WP: Congruently, an individual’s choice in any [sic:of the Q2, Q3, Q5a]  question significantly predicts their choice in another (p’s < .016 across logistic regressions).
*/  

* Consistency: positive skew across Q2, Q3 and Q5a 
  
logit pos_extreme pos_slight 
logit pos_inter  pos_extreme
logit pos_inter pos_slight 
 

  
/*
footnote 16 of WP: We can conduct a similar exercise for preferences for earlier resolution: 75% of those who saw Q1 and
Q5b made consistent choices (p < .001) and the choice in Q1 was predictive of the choice in Q5b (logistic
regression β = 1.57, p = .001).
*/  
tab early abit_early
logit  abit_early  early


/*
p.16-17 of WP: We can also ask whether the fraction of individuals who prefer positive to negative skew differs between avoiders and takers. For two out of the three comparisons, we do not find significant differences between the fraction of individuals preferring positive over negative skew when comparing takers to avoiders. However, avoiders are more likely than takers to prefer the positively skewed information structure that resolves all uncertainty regarding the good outcome, (0.5, 1), to a negatively skewed information structure that resolves all uncertainty regarding the bad outcome, (1, 0.5) (81% vs. 63%, McNemar test,
p−value= 0.009). 
*/


**testing if information avoiders vs takers are different in skew prefs.
**no effect 
 tab pos_slight early 
 mcci 6 28 32 117
**no effect 
 tab pos_inter early 
 mcci 11 41 31 113
**Exact McNemar significance probability = 0.009
 tab pos_extreme early 
 mcci 10 73 44 123

 
/*
p.17 of WP: We find that 67% of the information takers (Q4a collapsed across questions) made choices consistent with their informational preferences as elicited by Q1, preferring the more informative signal over the positively skewed alternative (one-sided binomial test, p < .001). However, less than half (44%) of the information avoiders (Q4b collapsed across questions) chose the less informative signal. 
*/
sum monot_taker monot_avoid
bitest monot_taker==.5


/*p.17 of WP: We fail to reject the null hypothesis that consistency in terms of preferences for informativeness among avoiders is not greater than what we could obtain by chance (one-sided binomial test, p = .83). 
*/

bitest monot_avoid==.5

/*Contrasting the results in Q4a and Q4b, we show that avoiders are significantly less likely to adhere to the ordering induced by Blackwell dominance when evaluating a positively skewed structure than takers (two-sided chi-square test, χ2(1) = 9.47, p = 0.002).
*/
 
tab monot early, chi2


  
