use "$root/Data/Output/IQdata.dta", clear

********************************************************************************
* Bar Graph of Information Preferences (Appendix)*
********************************************************************************
 
graph bar, asyvars over(certain_info, gap(*.01)) ytitle(Percent) blabel(bar, position(outside )  color(black) format(%3.1f) size("small") gap(*.5))   bar(1, color(midblue) ) bar(2, color(orange)) bar(3, color(gray) ) bar(4, color(gold)) name(full, replace) title(Most Info, size("medium")) legend(rows(1) size(small)) legend(label(1 "Ranked 1st")  label(2 "Ranked 2nd")  label(3 "Ranked 3rd") label(4 "Ranked 4th")) legend(off) graphregion(color(white)) bgcolor(white)
graph save "most.gph", replace

graph bar, asyvars over(pos_skew, gap(*.01)) ytitle(Percent) blabel(bar, position(outside)  color(black) format(%3.1f) size("small") gap(*.5)) bar(1, color(midblue)) bar(2, color(orange)) bar(3, color(gray)) bar(4, color(gold)) name(pos, replace) yscale(off) title(Pos Skew, size("medium")) legend(rows(1) size(small)) legend(label(1 "Ranked 1st")  label(2 "Ranked 2nd")  label(3 "Ranked 3rd") label(4 "Ranked 4th")) legend(off) graphregion(color(white)) bgcolor(white)
graph save "pos.gph", replace

graph bar, asyvars over(neg_skew, gap(*.01)) ytitle(Percent) blabel(bar, position(outside) color(black) format(%3.1f) size("small") gap(*.5)) bar(1, color(midblue)) bar(2, color(orange)) bar(3, color(gray)) bar(4, color(gold)) name(neg, replace) yscale(off) title(Neg Skew, size("medium")) legend(rows(1) size(small)) legend(label(1 "Ranked 1st")  label(2 "Ranked 2nd")  label(3 "Ranked 3rd") label(4 "Ranked 4th")) legend(off) graphregion(color(white)) bgcolor(white)
graph save "neg.gph", replace

graph bar, asyvars over(no_info, gap(*.01)) ytitle(Percent) blabel(bar, position(outside)  color(black) format(%3.1f) size("small") gap(*.5)) bar(1, color(midblue)) bar(2, color(orange)) bar(3, color(gray)) bar(4, color(gold)) name(none, replace) yscale(off) title(No Info, size("medium")) legend(rows(1) size(small)) legend(label(1 "Ranked 1st")  label(2 "Ranked 2nd")  label(3 "Ranked 3rd") label(4 "Ranked 4th")) legend(off) graphregion(color(white)) bgcolor(white)
graph save "none.gph", replace


grc1leg "most.gph" "pos.gph" "neg.gph" "none.gph", rows(1) imargin(zero)    ycommon  graphregion(color(white))  
 
graph export "FigE1.pdf", as(pdf)  replace
  
rm "most.gph" 
rm "pos.gph" 
rm "neg.gph" 
rm "none.gph" 
