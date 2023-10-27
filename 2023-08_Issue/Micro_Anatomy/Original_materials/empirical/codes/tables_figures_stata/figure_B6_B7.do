**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figure B.6 and B.7
* cross-sectional variance and 90/10 income ratio dynamics
********************************************************************** 

cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

grstyle clear
set scheme s2color
graph set window fontface default

 ****************************************************
 ******* * cross-sectional variance and 90/10 *******
 ****************************************************

*** ITA *** 

u "$database/resid_ITA.dta", clear

replace uy = ln(uy)
replace uc = ln(uc)

tempfile data_main
save `data_main' , replace

collapse (sd) uc uy lc ly [fw=pesopop_r], by(year)

replace uc = uc^2
replace uy = uy^2
replace lc = lc^2
replace ly = ly^2

* Figure B.6 - panel a

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(scatteri .2 2007  .2 2015, bcolor(gs14) recast(area) plotr(m(zero))) ///
(scatteri .5 2007  .5 2015, bcolor(gs14) recast(area) plotr(m(zero))) ///
(connected uy year if year<=2014, lc(dknavy) mc(dknavy) msize(2.3) lw(1)) /// */ exclude 2016 observation */
(connected uc year if year<=2014, lc(maroon) mc(maroon) msize(2.3) lw(1)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(.2(.1).5,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(1995(5)2016, labsize(large)) ///
legend(order (4 "C" 3 "Y" ) row(3) size(large) ring(0) position(4) region(lwidth(none)))
graph export "$output/figureB6_a.pdf", replace

u `data_main', clear

replace uc = exp(uc)
replace uy = exp(uy)
replace lc = exp(lc)
replace ly = exp(ly)

collapse (p90) uc_p90=uc uy_p90=uy lc_p90=lc ly_p90=ly (p10) uc_p10=uc uy_p10=uy lc_p10=lc ly_p10=ly (p50) uc_p50=uc uy_p50=uy lc_p50=lc ly_p50=ly [fw=pesopop_r], by(year)

gen uc_9010 = uc_p90/uc_p10
gen uy_9010 = uy_p90/uy_p10
gen lc_9010 = lc_p90/lc_p10
gen ly_9010 = ly_p90/ly_p10

gen uc_5010 = uc_p50/uc_p10
gen uy_5010 = uy_p50/uy_p10
gen lc_5010 = lc_p50/lc_p10
gen ly_5010 = ly_p50/ly_p10

* Figure B.7 - panel a

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(scatteri 3 2007  3 2015, bcolor(gs14) recast(area) plotr(m(zero))) ///
(scatteri 6 2007  6 2015, bcolor(gs14) recast(area) plotr(m(zero))) ///
(connected uy_9010 year if year<=2014, lc(dknavy) mc(dknavy) msize(2.3) lw(1)) ///
(connected uc_9010 year if year<=2014, lc(maroon) mc(maroon) msize(2.3) lw(1)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(3(1)6,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(1995(5)2016, labsize(large)) ///
legend(order (4 "C" 3 "Y" ) row(3) size(large) ring(0) position(4) region(lcolor(white)))
graph export "$output/figureB7_a.pdf", replace

*** SPA *** 

u "$database/resid_SPA.dta", clear

replace uy = ln(uy)
replace uc = ln(uc)

tempfile data_main
save `data_main' , replace

collapse (sd) uc uy lc ly [fw=factor_r], by(year)

replace uc = uc^2
replace uy = uy^2
replace lc = lc^2
replace ly = ly^2

* Figure B.6 - panel b

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(scatteri 0.2 2008  0.2 2013.25, bcolor(gs14) recast(area) plotr(m(zero))) ///
(scatteri 0.5 2008  0.5 2013.25, bcolor(gs14) recast(area) plotr(m(zero))) ///
(connected uy year, lc(dknavy) mc(dknavy) msize(2.3) lw(1)) ///
(connected uc year, lc(maroon) mc(maroon) msize(2.3) lw(1)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(.2(.1).5,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(2006(2)2016, labsize(large)) ///
legend(off)
graph export "$output/figureB6_b.pdf", replace

u `data_main', clear

replace uc = exp(uc)
replace uy = exp(uy)
replace lc = exp(lc)
replace ly = exp(ly)

collapse (p90) uc_p90=uc uy_p90=uy lc_p90=lc ly_p90=ly (p10) uc_p10=uc uy_p10=uy lc_p10=lc ly_p10=ly (p50) uc_p50=uc uy_p50=uy lc_p50=lc ly_p50=ly [fw=factor_r], by(year)

gen uc_9010 = uc_p90/uc_p10
gen uy_9010 = uy_p90/uy_p10
gen lc_9010 = lc_p90/lc_p10
gen ly_9010 = ly_p90/ly_p10

gen uc_5010 = uc_p50/uc_p10
gen uy_5010 = uy_p50/uy_p10
gen lc_5010 = lc_p50/lc_p10
gen ly_5010 = ly_p50/ly_p10

* Figure B.7 - panel b

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(scatteri 3 2008  3 2013.25, bcolor(gs14) recast(area) plotr(m(zero))) ///
(scatteri 6 2008  6 2013.25, bcolor(gs14) recast(area) plotr(m(zero))) ///
(connected uy_9010 year, lc(dknavy) mc(dknavy) msize(2.3) lw(1)) ///
(connected uc_9010 year, lc(maroon) mc(maroon) msize(2.3) lw(1)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(3(1)6,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(2006(2)2016, labsize(large)) ///
legend(off)
graph export "$output/figureB7_b.pdf", replace

*** MEX *** 

u "$database/resid_MEX.dta", clear

replace uy = ln(uy)
replace uc = ln(uc)

tempfile data_main
save `data_main' , replace


collapse (sd) uc uy lc ly [fw=HOG_r], by(year)

replace uc = uc^2
replace uy = uy^2
replace lc = lc^2
replace ly = ly^2

* Figure B.6 - panel c

local width_ = "2.6"
local height_ = "1.8"

gen shade = .6

twoway ///
(scatteri .2 1995  .2 1995.5, bcolor(gs14) recast(area) plotr(m(zero))) ///
(scatteri .8 1995  .8 1995.5, bcolor(gs14) recast(area) plotr(m(zero))) ///
(scatteri .2 2006.5  .2 2009.5, bcolor(gs14) recast(area) plotr(m(zero))) ///
(scatteri .8 2006.5  .8 2009.5, bcolor(gs14) recast(area) plotr(m(zero))) ///
(connected uy year, lc(dknavy) mc(dknavy) msize(2.3) lw(1)) ///
(connected uc year, lc(maroon) mc(maroon) msize(2.3) lw(1)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(.2(.2).8,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(1992(4)2014, labsize(large)) ///
legend(off)
graph export "$output/figureB6_c.pdf", replace

u `data_main' , clear

replace uc = exp(uc)
replace uy = exp(uy)
replace lc = exp(lc)
replace ly = exp(ly)


collapse (p90) uc_p90=uc uy_p90=uy lc_p90=lc ly_p90=ly (p10) uc_p10=uc uy_p10=uy lc_p10=lc ly_p10=ly (p50) uc_p50=uc uy_p50=uy lc_p50=lc ly_p50=ly [fw=HOG_r], by(year)

gen uc_9010 = uc_p90/uc_p10
gen uy_9010 = uy_p90/uy_p10
gen lc_9010 = lc_p90/lc_p10
gen ly_9010 = ly_p90/ly_p10

gen uc_5010 = uc_p50/uc_p10
gen uy_5010 = uy_p50/uy_p10
gen lc_5010 = lc_p50/lc_p10
gen ly_5010 = ly_p50/ly_p10

* Figure B.7 - panel c

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(scatteri 3 1995  3 1995.5, bcolor(gs14) recast(area) plotr(m(zero))) ///
(scatteri 7 1995  7 1995.5, bcolor(gs14) recast(area) plotr(m(zero))) ///
(scatteri 3 2006.5  3 2009.5, bcolor(gs14) recast(area) plotr(m(zero))) ///
(scatteri 7 2006.5  7 2009.5, bcolor(gs14) recast(area) plotr(m(zero))) ///
(connected uy_9010 year, lc(dknavy) mc(dknavy) msize(2.3) lw(1)) ///
(connected uc_9010 year, lc(maroon) mc(maroon) msize(2.3) lw(1)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(3(1)7,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(1992(4)2014, labsize(large)) ///
legend(off)
graph export "$output/figureB7_c.pdf", replace


*** PER *** 

u "$database/resid_PER.dta", clear

replace uy = ln(uy)
replace uc = ln(uc)

*dropping outliers
drop if ly <= -10 & year == 2005

tempfile data_main
save `data_main', replace

u `data_main', clear

collapse (sd) uc uy lc ly [fw=factor07_r], by(year)

replace uc = uc^2
replace uy = uy^2
replace lc = lc^2
replace ly = ly^2

* Figure B.6 - panel d

local width_ = "2.6"
local height_ = "1.8"


twoway ///
(scatteri .2 2008.5  .2 2009.5, bcolor(gs14) recast(area) plotr(m(zero))) ///
(scatteri .8 2008.5  .8 2009.5, bcolor(gs14) recast(area) plotr(m(zero))) ///
(connected uy year, lc(dknavy) mc(dknavy) msize(2.3) lw(1)) ///
(connected uc year, lc(maroon) mc(maroon) msize(2.3) lw(1)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(.2(.2).8,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(2004(4)2018, labsize(large)) ///
legend(off)
graph export "$output/figureB6_d.pdf", replace

u `data_main', clear

replace uc = exp(uc)
replace uy = exp(uy)
replace lc = exp(lc)
replace ly = exp(ly)


collapse (p90) uc_p90=uc uy_p90=uy lc_p90=lc ly_p90=ly (p10) uc_p10=uc uy_p10=uy lc_p10=lc ly_p10=ly (p50) uc_p50=uc uy_p50=uy lc_p50=lc ly_p50=ly [fw=factor07_r], by(year)

gen uc_9010 = uc_p90/uc_p10
gen uy_9010 = uy_p90/uy_p10
gen lc_9010 = lc_p90/lc_p10
gen ly_9010 = ly_p90/ly_p10

gen uc_5010 = uc_p50/uc_p10
gen uy_5010 = uy_p50/uy_p10
gen lc_5010 = lc_p50/lc_p10
gen ly_5010 = ly_p50/ly_p10

* Figure B.7 - panel d

local width_ = "2.6"
local height_ = "1.8"

twoway ///
(scatteri 3 2008.5  3 2009.5, bcolor(gs14) recast(area) plotr(m(zero))) ///
(scatteri 7 2008.5  7 2009.5, bcolor(gs14) recast(area) plotr(m(zero))) ///
(connected uy_9010 year, lc(dknavy) mc(dknavy) msize(2.3) lw(1)) ///
(connected uc_9010 year, lc(maroon) mc(maroon) msize(2.3) lw(1)) ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(3(1)7,grid labsize(large)) xsize(`width_') ysize(`height_') xlabel(2004(4)2018, labsize(large)) ///
legend(off)
graph export "$output/figureB7_d.pdf", replace

