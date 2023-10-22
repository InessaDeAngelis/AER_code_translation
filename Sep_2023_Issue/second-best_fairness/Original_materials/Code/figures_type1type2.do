********************************************************************************
* Title:   Figures in Second-best Fairness paper
* Descrip: Contains all figures in main text and appendix
*          Figure 1 - Share of spectators who paying
*          Figure 2 - Strength of second-best preferences
*          Figure 3 - Comepnsation exp. against earnings and unemployment-experiments
*          Figure 4 - Unemployment-experiment
********************************************************************************

clear all 
set more off 

use ../Data/Processed_Data/analyticaldata.dta, clear 

********************************************************************************
**#1. SHARE OF SPECTATORS WHO PAY
********************************************************************************
*Compensation - All
preserve
drop if h_treatment>5
collapse (mean) pay (semean) se_pay = pay, by(probability)

gen hi = pay + se_pay
gen lo = pay - se_pay

graph twoway (bar pay probability, barw(0.20))  (rcap hi lo probability, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(0 "0" 0.25 "0.25" 0.5 "0.5" 0.75 "0.75" 1 "1") xtitle("Probability of false claim") title("All - Compensation") ///
    legend(off) ytitle("Share paying `pm' s.e.m.") name(figure1_a, replace)

graph export ../Figures/figure1_a.eps, replace
! epstopdf ../Figures/figure1_a.eps
rm ../Figures/figure1_a.eps
restore

*Earnings - All
preserve
drop if replication==0
collapse (mean) pay (semean) se_pay = pay, by(probability)

gen hi = pay + se_pay
gen lo = pay - se_pay

graph twoway (bar pay probability, barw(0.20))  (rcap hi lo probability, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(0 "0" 0.25 "0.25" 0.5 "0.5" 0.75 "0.75" 1 "1") xtitle("Probability of false claim") title("All - Earnings") ///
    legend(off) ytitle("Share paying `pm' s.e.m.") name(figure1_b, replace)

graph export ../Figures/figure1_b.eps, replace
! epstopdf ../Figures/figure1_b.eps
rm ../Figures/figure1_b.eps
restore

*Compensation - USA
preserve
drop if h_treatment>5
drop if Norway==1
collapse (mean) pay (semean) se_pay = pay, by(probability)

gen hi = pay + se_pay
gen lo = pay - se_pay

graph twoway (bar pay probability, barw(0.20))  (rcap hi lo probability, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(0 "0" 0.25 "0.25" 0.5 "0.5" 0.75 "0.75" 1 "1") xtitle("Probability of false claim") title("USA - Compensation") ///
    legend(off) ytitle("Share paying `pm' s.e.m.") name(figure1_c, replace)

graph export ../Figures/figure1_c.eps, replace
! epstopdf ../Figures/figure1_c.eps
rm ../Figures/figure1_c.eps
restore

*Earnings - USA 
preserve
drop if replication==0
drop if Norway==1
collapse (mean) pay (semean) se_pay = pay, by(probability)

gen hi = pay + se_pay
gen lo = pay - se_pay

graph twoway (bar pay probability, barw(0.20))  (rcap hi lo probability, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(0 "0" 0.25 "0.25" 0.5 "0.5" 0.75 "0.75" 1 "1") xtitle("Probability of false claim") title("USA - Earnings") ///
    legend(off) ytitle("Share paying `pm' s.e.m.") name(figure1_d, replace)

graph export ../Figures/figure1_d.eps, replace
! epstopdf ../Figures/figure1_d.eps
rm ../Figures/figure1_d.eps
restore

*Compensation - Norway
preserve
drop if h_treatment>5
drop if Norway==0
collapse (mean) pay (semean) se_pay = pay, by(probability)

gen hi = pay + se_pay
gen lo = pay - se_pay

graph twoway (bar pay probability, barw(0.20))  (rcap hi lo probability, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(0 "0" 0.25 "0.25" 0.5 "0.5" 0.75 "0.75" 1 "1") xtitle("Probability of false claim") title("Norway - Compensation") ///
    legend(off) ytitle("Share paying `pm' s.e.m.") name(figure1_e, replace)

graph export ../Figures/figure1_e.eps, replace
! epstopdf ../Figures/figure1_e.eps
rm ../Figures/figure1_e.eps
restore

*Earnings - Norway
preserve
drop if replication==0
drop if Norway==0
collapse (mean) pay (semean) se_pay = pay, by(probability)

gen hi = pay + se_pay
gen lo = pay - se_pay

graph twoway (bar pay probability, barw(0.20))  (rcap hi lo probability, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(0 "0" 0.25 "0.25" 0.5 "0.5" 0.75 "0.75" 1 "1") xtitle("Probability of false claim") title("Norway - Earnings") ///
    legend(off) ytitle("Share paying `pm' s.e.m.") name(figure1_f, replace)

graph export ../Figures/figure1_f.eps, replace
! epstopdf ../Figures/figure1_f.eps
rm ../Figures/figure1_f.eps
restore

********************************************************************************
*Combining graphs 
graph combine figure1_a figure1_b figure1_c figure1_d figure1_e figure1_d, cols(2) name(Figure1, replace)
graph export ../Figures/Figure1.pdf, replace

********************************************************************************
**#2. SECOND-BEST FAIRNESS PREFERENCES
********************************************************************************
**Compensation - All
preserve 
postfile allcomp Share Se using "myresultscomp.dta", replace 
reg pay prob25 prob50 prob75 prob100 if h_treatment<6 [pweight=sca_weight], robust

*strongly false positive
lincom 1-(_cons + prob25)
return list
post allcomp (`r(estimate)') (`r(se)')

*false positive 
lincom 1-( _cons + prob50)
return list
post allcomp (`r(estimate)') (`r(se)')

*false negative 
lincom _cons + prob50
return list
post allcomp (`r(estimate)') (`r(se)')

*strongly false negative
lincom _cons + prob75
return list
post allcomp (`r(estimate)') (`r(se)')

postclose allcomp

use "myresultscomp.dta", clear 
des 
list 

gen hi = Share + Se
gen lo = Share - Se

gen N=_n
gen pos=N

gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1
list

graph twoway (bar  Share newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  Share newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).8) xlabel(1 "False positive averse"  2 "False negative averse" ) yla(, nogrid) ///
	 xtitle("")    title("All - Compensation") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(figure2_a, replace)

graph export ../Figures/figure2_a.pdf, replace
restore 

**Earnings - All 
preserve 
postfile allearn Share Se using "myresultsearn.dta", replace 
reg pay prob25 prob50 prob75 prob100 if h_treatment>15 & h_treatment<21 [pweight=sca_weight], robust

*strongly false positive
lincom 1-(_cons + prob25)
return list
post allearn (`r(estimate)') (`r(se)')

*false positive 
lincom 1-( _cons + prob50)
return list
post allearn (`r(estimate)') (`r(se)')

*false negative 
lincom _cons + prob50
return list
post allearn (`r(estimate)') (`r(se)')

*strongly false negative
lincom _cons + prob75
return list
post allearn (`r(estimate)') (`r(se)')

postclose allearn

use "myresultsearn.dta", clear 
des 
list 

gen hi = Share + Se
gen lo = Share - Se

gen N=_n
gen pos=N

gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1
list

graph twoway (bar  Share newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  Share newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).8) xlabel(1 "False positive averse"  2 "False negative averse" ) yla(, nogrid) ///
	 xtitle("")    title("All - Earnings") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(figure2_b, replace)

graph export ../Figures/figure2_b.pdf, replace
restore 

**Compensation - US 
preserve 
postfile allcompus Share Se using "myresultscompus.dta", replace 
reg pay prob25 prob50 prob75 prob100 if h_treatment<6 & Norway==0 [pweight=sca_weight], robust

*strongly false positive
lincom 1-(_cons + prob25)
return list
post allcompus (`r(estimate)') (`r(se)')

*false positive 
lincom 1-( _cons + prob50)
return list
post allcompus (`r(estimate)') (`r(se)')

*false negative 
lincom _cons + prob50
return list
post allcompus (`r(estimate)') (`r(se)')

*strongly false negative
lincom _cons + prob75
return list
post allcompus (`r(estimate)') (`r(se)')

postclose allcompus

use "myresultscompus.dta", clear 
des 
list 

gen hi = Share + Se
gen lo = Share - Se

gen N=_n
gen pos=N

gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1
list

graph twoway (bar  Share newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  Share newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).8) xlabel(1 "False positive averse"  2 "False negative averse" ) yla(, nogrid) ///
	 xtitle("")    title("US - Compensation") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(figure2_c, replace)

graph export ../Figures/figure2_c.pdf, replace
restore 

**Earnings - US
preserve 
postfile allearnus Share Se using "myresultsearnus.dta", replace 
reg pay prob25 prob50 prob75 prob100 if h_treatment>15 & h_treatment<21 & Norway==0 [pweight=sca_weight], robust

*strongly false positive
lincom 1-(_cons + prob25)
return list
post allearnus (`r(estimate)') (`r(se)')

*false positive 
lincom 1-( _cons + prob50)
return list
post allearnus (`r(estimate)') (`r(se)')

*false negative 
lincom _cons + prob50
return list
post allearnus (`r(estimate)') (`r(se)')

*strongly false negative
lincom _cons + prob75
return list
post allearnus (`r(estimate)') (`r(se)')

postclose allearnus

use "myresultsearnus.dta", clear 
des 
list 

gen hi = Share + Se
gen lo = Share - Se

gen N=_n
gen pos=N

gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1
list

graph twoway (bar  Share newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  Share newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).8) xlabel(1 "False positive averse"  2 "False negative averse" ) yla(, nogrid) ///
	 xtitle("")    title("US - Earnings") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(figure2_d, replace)

graph export ../Figures/figure2_d.pdf, replace
restore 

**Compensation - Norway 
preserve 
postfile allcompnor Share Se using "myresultscompnor.dta", replace 
reg pay prob25 prob50 prob75 prob100 if h_treatment<6 & Norway==1 [pweight=sca_weight], robust

*strongly false positive
lincom 1-(_cons + prob25)
return list
post allcompnor (`r(estimate)') (`r(se)')

*false positive 
lincom 1-( _cons + prob50)
return list
post allcompnor (`r(estimate)') (`r(se)')

*false negative 
lincom _cons + prob50
return list
post allcompnor (`r(estimate)') (`r(se)')

*strongly false negative
lincom _cons + prob75
return list
post allcompnor (`r(estimate)') (`r(se)')

postclose allcompnor

use "myresultscompnor.dta", clear 
des 
list 

gen hi = Share + Se
gen lo = Share - Se

gen N=_n
gen pos=N

gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1
list

graph twoway (bar  Share newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  Share newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).8) xlabel(1 "False positive averse"  2 "False negative averse" ) yla(, nogrid) ///
	 xtitle("")    title("Norway - Compensation") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(figure2_e, replace)

graph export ../Figures/figure2_e.pdf, replace
restore 

**Earnings - Norway 
preserve 
postfile allearnnor Share Se using "myresultsearnnor.dta", replace 
reg pay prob25 prob50 prob75 prob100 if h_treatment>15 & h_treatment<21 & Norway==1 [pweight=sca_weight], robust

*strongly false positive
lincom 1-(_cons + prob25)
return list
post allearnnor (`r(estimate)') (`r(se)')

*false positive 
lincom 1-( _cons + prob50)
return list
post allearnnor (`r(estimate)') (`r(se)')

*false negative 
lincom _cons + prob50
return list
post allearnnor (`r(estimate)') (`r(se)')

*strongly false negative
lincom _cons + prob75
return list
post allearnnor (`r(estimate)') (`r(se)')

postclose allearnnor

use "myresultsearnnor.dta", clear 
des 
list 

gen hi = Share + Se
gen lo = Share - Se

gen N=_n
gen pos=N

gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1
list

graph twoway (bar  Share newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  Share newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).8) xlabel(1 "False positive averse"  2 "False negative averse" ) yla(, nogrid) ///
	 xtitle("")    title("Norway - Earnings") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(figure2_f, replace)

graph export ../Figures/figure2_f.pdf, replace
restore 

********************************************************************************
*Combining graphs 
graph combine figure2_a figure2_b figure2_c figure2_d figure2_e figure2_f, cols(2) name(Figure2, replace)
graph export ../Figures/Figure2.pdf, replace

********************************************************************************
**#3. COMP.EXP. VS. EARN.EXP. & COMP.EXP. VS. UNEMP.EXP.
********************************************************************************
graph set window fontface "Times New Roman"

*Vs earnings
*All 
reg pay prob25 prob50 prob75 prob100 replication replication_prob25 replication_prob50 replication_prob75 replication_prob100 if (h_treatment<6 | h_treatment>15 & h_treatment<21) [pweight=sca_weight], robust 
est store A

reg pay prob25 prob50 prob75 prob100 replication replication_prob25 replication_prob50 replication_prob75 replication_prob100 male lowage lowincome loweducation rightwing if (h_treatment<6 | h_treatment>15 & h_treatment<21) [pweight=sca_weight], robust
est store B

*US
reg pay prob25 prob50 prob75 prob100 replication replication_prob25 replication_prob50 replication_prob75 replication_prob100 if Norway==0 & (h_treatment<6 | h_treatment>15 & h_treatment<21) [pweight=sca_weight], robust
est sto E

reg pay prob25 prob50 prob75 prob100 replication replication_prob25 replication_prob50 replication_prob75 replication_prob100 male lowage lowincome loweducation rightwing if Norway==0 & (h_treatment<6 | h_treatment>15 & h_treatment<21) [pweight=sca_weight], robust
est sto F
 
*Norway 
reg pay prob25 prob50 prob75 prob100 replication replication_prob25 replication_prob50 replication_prob75 replication_prob100 if Norway==1 & (h_treatment<6 | h_treatment>15 & h_treatment<21) [pweight=sca_weight], robust
est sto I

reg pay prob25 prob50 prob75 prob100 replication replication_prob25 replication_prob50 replication_prob75 replication_prob100 male lowage lowincome loweducation rightwing if Norway==1 & (h_treatment<6 | h_treatment>15 & h_treatment<21) [pweight=sca_weight], robust
est sto J

coefplot (A, label(controls) mcolor(navy) ciopts(color(navy)) offset(0.05)) (B, label(no controls) mcolor(maroon) ciopts(color(maroon)) offset(-0.05)), bylabel(All) ///
       || (E) (F), bylabel(US)  ///
       ||(I) (J), bylabel(Norway) ///
       ||, drop(_cons prob25 prob50 prob75 prob100 replication unemployment male lowage lowincome loweducation rightwing) coeflabels(replication_prob25 = "{it:Earn x 25}" replication_prob50 = "{it:Earn x 50}" replication_prob75 = "{it:Earn x 75}" replication_prob100 = "{it:Earn x 100}", wrap(20) angle(vertical)) xline(0, lcolor(red)) msymbol(o) byopts(xrescale compact col(3) legend(off) title("Panel A: Earnings Experiment")) xlabel(-0.25(0.1)0.25) xscale(range(-0.5(0.1)0.5))  name(figure3_a, replace) 
	  
graph save ../Figures/figure3_a.gph, replace 
graph export ../Figures/figure3_a.pdf, replace

*Vs unemployment
*All
reg pay prob25 prob50 prob75 prob100 unemployment unemployment_prob25 unemployment_prob50 unemployment_prob75 unemployment_prob100 [pweight=sca_weight] if (h_treatment<6 | h_treatment>10 & h_treatment<16), robust
est store C

reg pay prob25 prob50 prob75 prob100 unemployment unemployment_prob25 unemployment_prob50 unemployment_prob75 unemployment_prob100 male lowage lowincome loweducation rightwing if (h_treatment<6 | h_treatment>10 & h_treatment<16) [pweight=sca_weight], robust
est store D

*USA 
reg pay prob25 prob50 prob75 prob100 unemployment unemployment_prob25 unemployment_prob50 unemployment_prob75 unemployment_prob100 if Norway==0 & (h_treatment<6 | h_treatment>10 & h_treatment<16) [pweight=sca_weight], robust
est sto G

reg pay prob25 prob50 prob75 prob100 unemployment unemployment_prob25 unemployment_prob50 unemployment_prob75 unemployment_prob100 male lowage lowincome loweducation rightwing if Norway==0 & (h_treatment<6 | h_treatment>10 & h_treatment<16) [pweight=sca_weight], robust
est sto H

*Norway 
reg pay prob25 prob50 prob75 prob100 unemployment unemployment_prob25 unemployment_prob50 unemployment_prob75 unemployment_prob100 if Norway==1 & (h_treatment<6 | h_treatment>10 & h_treatment<16) [pweight=sca_weight], robust
est sto K

reg pay prob25 prob50 prob75 prob100 unemployment unemployment_prob25 unemployment_prob50 unemployment_prob75 unemployment_prob100 male lowage lowincome loweducation rightwing if Norway==1 & (h_treatment<6 | h_treatment>10 & h_treatment<16) [pweight=sca_weight], robust
est sto L

coefplot(C, label(no controls) mcolor(navy) ciopts(color(navy)) offset(0.05)) (D, label(controls) mcolor(maroon) ciopts(color(maroon)) offset(-0.05)), bylabel(All) ///
       || (G) (H), bylabel(US)  ///
       || (K) (L), bylabel(Norway) ///
       ||, drop(_cons prob25 prob50 prob75 prob100 replication unemployment male lowage lowincome loweducation rightwing) coeflabels(unemployment_prob25 = "{it:Unemp x 25}" unemployment_prob50 = "{it:Unemp x 50}" unemployment_prob75 = "{it:Unemp x 75}" unemployment_prob100 = "{it:Unemp x 100}", wrap(20)angle(vertical)) xline(0, lcolor(red)) msymbol(o) byopts(xrescale compact col(3) title("Panel B: Unemployment Survey Experiment") legend(off)) xlabel(-0.25(0.1)0.25) xscale(range(-0.5(0.1)0.5)) yscale(range(1 4)) name(figure3_b, replace) 
	 
graph save ../Figures/figure3_b.gph, replace 
graph export ../Figures/figure3_b.pdf, replace 
********************************************************************************
*Combining graphs
grc1leg2 ../Figures/figure3_a.gph ../Figures/figure3_b.gph, cols(1) altshrink iscale(1) 
graph export ../Figures/Figure3, as(pdf) replace

********************************************************************************
**#4. UNEMP.EXP.
********************************************************************************
**Left panels: share of spectators choosing to pay unemployment benefits
*Unemployment - USA&Norway 
preserve
drop if h_treatment<11 
drop if h_treatment>15
collapse (mean) pay (semean) se_pay = pay, by(probability)

gen hi = pay + se_pay
gen lo = pay - se_pay

graph twoway (bar pay probability, barw(0.20))  (rcap hi lo probability, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(0 "0" 0.25 "0.25" 0.5 "0.5" 0.75 "0.75" 1 "1") xtitle("Probability of false claim") title("All - Unemployment benefits") yla(, nogrid)  ///
    legend(off) ytitle("Share paying `pm' s.e.m.") name(figure4_a, replace)

graph export ../Figures/figure4_a.eps, replace
! epstopdf ../Figures/figure4_a.eps
rm ../Figures/figure4_a.eps
restore

*Unemployment - USA
preserve
drop if h_treatment<11 
drop if h_treatment>15
drop if Norway==1
collapse (mean) pay (semean) se_pay = pay, by(probability)

gen hi = pay + se_pay
gen lo = pay - se_pay

graph twoway (bar pay probability, barw(0.20))  (rcap hi lo probability, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(0 "0" 0.25 "0.25" 0.5 "0.5" 0.75 "0.75" 1 "1") xtitle("Probability of false claim") title("USA - Unemployment benefits") yla(, nogrid)  ///
    legend(off) ytitle("Share paying `pm' s.e.m.") name(figure4_c, replace)

graph export ../Figures/figure4_c.eps, replace
! epstopdf ../Figures/figure4_c.eps
rm ../Figures/figure4_c.eps
restore

*Unemployment - Norway 
preserve
drop if h_treatment<11 
drop if h_treatment>15
drop if Norway==0
collapse (mean) pay (semean) se_pay = pay, by(probability)

gen hi = pay + se_pay
gen lo = pay - se_pay

graph twoway (bar pay probability, barw(0.20))  (rcap hi lo probability, lcolor(black)),  ///
    ylabel(0(0.2)1) xlabel(0 "0" 0.25 "0.25" 0.5 "0.5" 0.75 "0.75" 1 "1") xtitle("Probability of false claim") title("Norway - Unemployment benefits") yla(, nogrid)  ///
    legend(off) ytitle("Share paying `pm' s.e.m.") name(figure4_e, replace)

graph export ../Figures/figure4_e.eps, replace
! epstopdf ../Figures/figure4_e.eps
rm ../Figures/figure4_e.eps
restore

********************************************************************************
*Combining left panels
graph combine figure4_a figure4_c figure4_e, cols(1) name(figure4_a_c_e, replace)
graph export ../Figures/figure4_a_c_e.pdf, replace

**Right panels: strongly FP and FN & upper/lower bounds FP, FN
*Unemployment - All
preserve 
postfile allunemp Share Se using "myresultsunemp.dta", replace 
reg pay prob25 prob50 prob75 prob100 if h_treatment>10 & h_treatment<16 [pweight=sca_weight], robust

*strongly false positive
lincom 1-(_cons + prob25)
return list
post allunemp (`r(estimate)') (`r(se)')

*false positive 
lincom 1-( _cons + prob50)
return list
post allunemp (`r(estimate)') (`r(se)')

*false negative 
lincom _cons + prob50
return list
post allunemp (`r(estimate)') (`r(se)')

*strongly false negative
lincom _cons + prob75
return list
post allunemp (`r(estimate)') (`r(se)')

postclose allunemp

use "myresultsunemp.dta", clear 
des 
list 

gen hi = Share + Se
gen lo = Share - Se

gen N=_n
gen pos=N

gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1
list

graph twoway (bar  Share newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  Share newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).8) xlabel(1 "False positive averse"  2 "False negative averse" ) yla(, nogrid) ///
	 xtitle("")    title("All - Unemployment benefits") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(figure4_b, replace)

graph export ../Figures/figure4_b.pdf, replace
restore 

*Unemployment - USA
preserve 
postfile allunempus Share Se using "myresultsunempus.dta", replace 
reg pay prob25 prob50 prob75 prob100 if h_treatment>10 & h_treatment<16 & Norway==0 [pweight=sca_weight], robust

*strongly false positive
lincom 1-(_cons + prob25)
return list
post allunempus (`r(estimate)') (`r(se)')

*false positive 
lincom 1-( _cons + prob50)
return list
post allunempus (`r(estimate)') (`r(se)')

*false negative 
lincom _cons + prob50
return list
post allunempus (`r(estimate)') (`r(se)')

*strongly false negative
lincom _cons + prob75
return list
post allunempus (`r(estimate)') (`r(se)')

postclose allunempus

use "myresultsunempus.dta", clear 
des 
list 

gen hi = Share + Se
gen lo = Share - Se

gen N=_n
gen pos=N

gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1
list

graph twoway (bar  Share newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  Share newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).8) xlabel(1 "False positive averse"  2 "False negative averse" ) yla(, nogrid) ///
	 xtitle("")    title("US - Unemployment benefits") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(figure4_d, replace)

graph export ../Figures/figure4_d.pdf, replace
restore 

*Unemployment - Norway 
preserve 
postfile allunempnor Share Se using "myresultsunempnor.dta", replace 
reg pay prob25 prob50 prob75 prob100 if h_treatment>10 & h_treatment<16 & Norway==1 [pweight=sca_weight], robust

*strongly false positive
lincom 1-(_cons + prob25)
return list
post allunempnor (`r(estimate)') (`r(se)')

*false positive 
lincom 1-( _cons + prob50)
return list
post allunempnor (`r(estimate)') (`r(se)')

*false negative 
lincom _cons + prob50
return list
post allunempnor (`r(estimate)') (`r(se)')

*strongly false negative
lincom _cons + prob75
return list
post allunempnor (`r(estimate)') (`r(se)')

postclose allunempnor

use "myresultsunempnor.dta", clear 
des 
list 

gen hi = Share + Se
gen lo = Share - Se

gen N=_n
gen pos=N

gen strict = inlist(pos,1,4) if pos!=.
gen newpos = 1 + inlist(pos,3,4) if pos!=.

replace newpos=newpos + 0.1 if strict==1
list

graph twoway (bar  Share newpos if strict==0 , fcolor(gs4) base(0) barw(0.55)) ///
  (bar  Share newpos if strict==1, fcolor(gs8%30) base(0) barw(0.55)) ///
  (rcap hi lo newpos, lcolor(black)), ///
   ylabel(0 (0.1).8) xlabel(1 "False positive averse"  2 "False negative averse" ) yla(, nogrid) ///
	 xtitle("")    title("Norway - Unemployment benefits") ///
                 legend(off)   ytitle("Share {&plusminus} s.e.m.") name(figure4_f, replace)

graph export ../Figures/figure4_f.pdf, replace
restore 

********************************************************************************
*Combining right panels
graph combine figure4_b figure4_d figure4_f, cols(1) name(figure4_b_d_f, replace)
graph export ../Figures/figure4_b_d_f.pdf, replace

********************************************************************************
*Combining graphs 
graph combine figure4_a_c_e figure4_b_d_f, cols(2) name(allunemployment, replace)
graph export ../Figures/Figure4.pdf, replace