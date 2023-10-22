use "$root/Data/Output/IQdata.dta", clear


gen top_most = certain_info==1
gen top_pos = pos_skew==1
gen top_neg = neg_skew==1
gen top_noinfo =  no_info==1


 
/*
p.22-23 of WP: A majority of the individuals (58.2%) ranked the most informative option as their top-ranked information structure. The positively skewed structure was ranked as the most preferred option by 21.5% of individuals, followed by the non-informative option (by 12%) and the negatively skewed option (by 8.3%). 
*/
sum top_most top_pos top_neg

/*p.22-23 of WP:  In terms of information uptake, 82.2% preferred the most informative option over no information. We refer to this group as information takers and the remaining 17.8% as information avoiders. Uptake of other information structures was 80.5% for the positively skewed option over no information, and 75.3% for the negatively skewed option over no information.  
*/

sum full avoid pos neg


/*
p.23 of WP: While similar proportions of individuals are willing to acquire positively skewed information (which is strictly less informative) and the most informative signal (McNemar χ2 = 1.39, p = 0.24), the proportion of individuals willing to take the negatively skewed option was significantly lower (McNemar χ2 = 16.32, p < 0.001).
*/


tab full pos 
mcci 76 31 41 452

tab full neg 
mcci 76 31 72 421


/*
p.23 of WP: The top panel shows that the positively skewed option is more likely to be ranked first than the negatively skewed option, both by avoiders (24.3% vs. 8.4%, p = 0.004) and by takers (20.9% vs. 8.3%, p < 0.001).
*/	
signrank  top_pos =  top_neg if avoid==1
tab  top_pos  top_neg  if avoid==1  
mcci 72 9 26 0
signrank  top_pos =  top_neg if avoid==0
tab  top_pos  top_neg  if avoid==0  
mcci 349 41 103 0
	
	
/*
p.23 and 24 of WP: among the avoiders, the difference in the propensity to rank the most informative signal below a skewed signal is statistically significant (p < 0.005, McNemar’s χ2 = 8, and suggests that offering positively skewed information not only offers a net benefit in increasing a preference for information among avoiders but is also significantly better at doing so compared to offering negatively skewed information.) Even among those who prefer the most informative option to no information (takers), a non-trivial fraction, 23.9%, ranks positively skewed information even higher, while only 12.6% of individuals do the same for the negatively skewed option (difference is significant at p < 0.001, McNemar’s χ2 = 29.04).
*/


** pos skew > neg. skew (preference, which is the inverse of rank)
gen pos_neg = 0
replace pos_neg = 1 if pos_skew < neg_skew

** pos skew > most skew (preference, which is the inverse of rank)
gen pos_full = 0
replace pos_full = 1 if pos_skew < certain_info

** neg skew > most skew (preference, which is the inverse of rank)
gen neg_full = 0
replace neg_full = 1 if neg_skew < certain_info
 

 
tab  pos_full  neg_full  if avoid==1  
mcci 23 8 24 52

tab  pos_full  neg_full  if avoid==0  
mcci 349 26 82 36
signrank pos_full = neg_full  if avoid==0  
	
/*
p. 24 of WP: As the top panel of Table 4 shows, among avoiders who do not rank the no-information option as their top choice, the vast majority of them prefer positively skewed information best versus preferring negatively skewed information best (74% vs. 26% p = 0.004). 
*/	 

preserve
drop if no_info==1
*drop top choice = no info

keep if avoid ==1   
*drop info seekers

**can use pos_neg, because the top choice is not no_info, and not full among this population.
* so when pos>neg, pos needs to be top. And when neg>pos, neg is top.

tab pos_neg  
   signrank  top_pos =  top_neg  
   tab  top_pos  top_neg   
  mcci  0 9 26 0
restore
	
/*
Appendix: The sample is well balanced across gender, age and education:  50\% are women; 9\% only have a high-school (or equivalent) education, 19\% have some college education,  56\% graduated from college, and 17\% have professional-school or graduate-school degrees. The mean age is 39.8, with a standard deviation of 12.2.  
*/
sum gender age 
tab education


 






 
