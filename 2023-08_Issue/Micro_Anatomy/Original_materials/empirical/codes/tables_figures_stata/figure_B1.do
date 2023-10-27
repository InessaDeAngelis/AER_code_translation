**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code replicates Figure B.1
* IRF estimates using Cerra and Saxena (2008, AER) approach
* data from Cerra and Saxena (2008, AER) and WDI-World Bank
**********************************************************************

cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global output   = "$user/output"
global input    = "$user/input"

grstyle clear

 ************************************************* 
 *********** Figure B.1 - Crisis IRFs ************
 *************************************************

*crisis episodes for ITA, SPA, MEX, PER
 

import excel "$input/aggregate/Cerra_Saxena_2008AER_data.xls", sheet("bankcrisis") firstrow clear

reshape long @_BANKCRISIS_CAPSYST, i(obs) j(country) string

rename _BANKCRISIS_CAPSYST bankcrisis

rename obs year

tempfile bankcrisis
save `bankcrisis' , replace

import excel "$input/aggregate/Cerra_Saxena_2008AER_data.xls", sheet("currcrisis") firstrow clear

reshape long @_CRISIS, i(obs) j(country) string

rename _CRISIS currcrisis

rename obs year

tempfile currcrisis
save `currcrisis' , replace

import excel "$input/aggregate/WB_GDP_growth.xls", sheet("Data") firstrow clear

reshape long grrt_ , i(year) j(country) string

rename grrt_ grrt

destring year, replace

merge 1:1 year country using `bankcrisis'

drop _merge

merge 1:1 year country using `currcrisis'

drop _merge

keep if country == "MEX" | country == "PER" | country == "ESP" | country == "ITA"

*exclude covid crisis
drop if year == 2020

egen country_grp = group(country)

gen country_id = country_grp

xtset country_grp year

generate bankcstart = 1 if bankcrisis == 1 & L1.bankcrisis!=1

replace bankcstart = 0 if bankcstart ==. & bankcrisis!=.


*** Cerra-Saxena crisis data only go to 2001 adding 2002 onwards crisis episodes 

replace bankcstart = 0 if year > 2001

replace bankcstart = 1 if country == "ITA" & year == 2008

replace bankcstart = 1 if country == "ESP" & year == 2008

*Mexico already has the Tequila crisis of 1994
replace bankcstart = 1 if country == "MEX" & year == 2008

replace bankcstart = 1 if country == "PER" & year == 2009


*start 1988 to only include the five crisis episodes

drop if year < 1988


local out "$tables/aggregates"

xtreg grrt L1.grrt L2.grrt L3.grrt L4.grrt bankcstart L1.bankcstart L2.bankcstart L3.bankcstart L4.bankcstart, fe 

mat coeff=e(b)
matrix coeffs=coeff[1,1..9]
mat V = e(V)
mat varmatrix = V[1..9, 1..9]

*using code from Mueller AER 2008
*draw 1000 coefficients from the same distribution
clear
set matsize 2000
set obs 1000
drawnorm d1 d2 d3 d4 b0 b1 b2 b3 b4, means(coeffs) cov(varmatrix)
mkmat  d1 d2 d3 d4 b0 b1 b2 b3 b4, matrix(betas)

*simulate the impulse response for each of the draws
*to initiate the process we first do one iteration - this is repeated 999 times below
forvalues i=1/1 {

	*the growthvector will record the reaction of growth to the impulse given by the impulsevector
	*impulse in position 6 (makes it easier to calculate the impulse response function iteratively)
	matrix growthvector = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	matrix impulsevector = (0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

	local a = 0
	*calculate impulse response iteratively, i.e. first the first year after the crisis, then the second etc.
	*this following formula calculates the response not only to the original impulse but also the impact from lagged growth
	forvalues a = 6/22 {
		matrix growthvector[1,`a'] = betas[`i',1]*growthvector[1,`a'-1]+betas[`i',2]*growthvector[1,`a'-2]+betas[`i',3]*growthvector[1,`a'-3]+betas[`i',4]*growthvector[1,`a'-4]+betas[`i',5]*impulsevector[1,`a']+betas[`i',6]*impulsevector[1,`a'-1]+betas[`i',7]*impulsevector[1,`a'-2]+betas[`i',8]*impulsevector[1,`a'-3]+betas[`i',9]*impulsevector[1,`a'-4]
		}

	*take the first 10 years after the impulse and record it under the vector growthnumbers
	matrix growthnumbers = growthvector[1,6..17]
	*outputvector records the response in relative to a benchmark of 100 in period 1
	matrix outputvector = (0,0,0,0,0,0,0,0,0,0,0)
	*irf records the response in levels in percent
	matrix irf = (0,0,0,0,0,0,0,0,0,0,0)
	local t=1
	matrix outputvector[1,`t'] = 100*(1+growthnumbers[1,`t']/100)
     	matrix irf[1,`t'] = outputvector[1,`t']-100
	forvalues t=2/11 {
		matrix outputvector[1,`t'] = outputvector[1,`t'-1]*(1+growthnumbers[1,`t']/100)
	     	matrix irf[1,`t'] = outputvector[1,`t']-100
		}

	*initiate the irf matrix which will record all outputvectors
	matrix irf = (0),irf
	matrix irfs = irf
	}

*repeat this process 999 times
forvalues i=2/1000 {

	matrix growthvector = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	matrix impulsevector = (0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

	local a = 0
	forvalues a = 6/22 {
		matrix growthvector[1,`a'] = betas[`i',1]*growthvector[1,`a'-1]+betas[`i',2]*growthvector[1,`a'-2]+betas[`i',3]*growthvector[1,`a'-3]+betas[`i',4]*growthvector[1,`a'-4]+betas[`i',5]*impulsevector[1,`a']+betas[`i',6]*impulsevector[1,`a'-1]+betas[`i',7]*impulsevector[1,`a'-2]+betas[`i',8]*impulsevector[1,`a'-3]+betas[`i',9]*impulsevector[1,`a'-4]
		}
	matrix growthnumbers = growthvector[1,6..17]
	matrix outputvector = (0,0,0,0,0,0,0,0,0,0,0)
	matrix irf = (0,0,0,0,0,0,0,0,0,0,0)
	local t=1
	matrix outputvector[1,`t'] = 100*(1+growthnumbers[1,`t']/100)
     	matrix irf[1,`t'] = outputvector[1,`t']-100
	forvalues t=2/11 {
		matrix outputvector[1,`t'] = outputvector[1,`t'-1]*(1+growthnumbers[1,`t']/100)
	     	matrix irf[1,`t'] = outputvector[1,`t']-100
		}
	matrix irf = (0),irf
	matrix irfs = irfs\irf
	}

clear 
svmat irfs
*the dataset is now all the estimated irfs - these will only be used for the error bands

summarize irfs1- irfs12

collapse (sd) irfs*

gen se_irfs_y_0 = irfs1
gen se_irfs_y_1 = irfs2
gen se_irfs_y_2 = irfs3
gen se_irfs_y_3 = irfs4
gen se_irfs_y_4 = irfs5
gen se_irfs_y_5 = irfs6
gen se_irfs_y_6 = irfs7
gen se_irfs_y_7 = irfs8
gen se_irfs_y_8 = irfs9
gen se_irfs_y_9 = irfs10
gen se_irfs_y_10 = irfs11
gen se_irfs_y_11 = irfs12


gen beta_1=el(coeff,1,1)
gen beta_2=el(coeff,1,2)
gen beta_3=el(coeff,1,3)
gen beta_4=el(coeff,1,4)

gen delta_0=el(coeff,1,5)
gen delta_1=el(coeff,1,6)
gen delta_2=el(coeff,1,7)
gen delta_3=el(coeff,1,8)
gen delta_4=el(coeff,1,9)


gen g_0 = delta_0

gen g_1 = beta_1*g_0 + delta_1

gen g_2 = beta_1*g_1 + beta_2*g_0 + delta_2

gen g_3 = beta_1*g_2 + beta_2*g_1 + beta_3*g_0 + delta_3

gen g_4 = beta_1*g_3 + beta_2*g_2 + beta_3*g_1 + beta_4*g_0 + delta_4

gen g_5 = beta_1*g_4 + beta_2*g_3 + beta_3*g_2 + beta_4*g_1

gen g_6 = beta_1*g_5 + beta_2*g_4 + beta_3*g_3 + beta_4*g_2

gen g_7 = beta_1*g_6 + beta_2*g_5 + beta_3*g_4 + beta_4*g_3

gen g_8 = beta_1*g_7 + beta_2*g_6 + beta_3*g_5 + beta_4*g_4

gen g_9 = beta_1*g_8 + beta_2*g_7 + beta_3*g_6 + beta_4*g_5

gen g_10 = beta_1*g_9 + beta_2*g_8 + beta_3*g_7 + beta_4*g_6

gen y_0 = 1
gen y_1 = 1*(1+g_0/100)
gen y_2 = y_1*(1+g_1/100)
gen y_3 = y_2*(1+g_2/100)
gen y_4 = y_3*(1+g_3/100)
gen y_5 = y_4*(1+g_4/100)
gen y_6 = y_5*(1+g_5/100)
gen y_7 = y_6*(1+g_6/100)
gen y_8 = y_7*(1+g_7/100)
gen y_9 = y_8*(1+g_8/100)
gen y_10 = y_9*(1+g_9/100)
gen y_11 = y_10*(1+g_10/100)

forvalues i = 0/11 {
replace y_`i' = (y_`i' - 1)*100
}

gen irf = 1

keep y_* se_irfs* irf

collapse y_* se_irfs* irf

reshape long y_ se_irfs_y_ , i(irf) j(year)

rename y_ output
rename se_irfs_y_ se_output

gen output_plus1se = output + se_output
gen output_less1se = output - se_output

** Figure B.1 - panel a

local color_1 = "0 76 153"
local color_2 = "0 0 0"

local width_ = "2.6"
local height_ = "1.8"

twoway ///
line output year, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5) ///
|| line output_plus1se year, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5) lp("_##") ///
|| line output_less1se year, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5) lp("_##") ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(-10(2)0, labsize(large)) xsize(`width_') ysize(`height_') yscale(titlegap(*+7)) xlabel(0(1)10, labsize(large)) ///
legend(off) 
graph export "$output/figureB1_a.pdf", replace

*EM Sudden Stops from Calvo, Izquierdo and Talvi (2006)

*import sheet 1 of 2
import excel "$input/aggregate/WB_GDP_growth.xls", sheet("Data_all1") firstrow clear

foreach x of varlist _all {
	rename `x' grrt_`x'
} 

rename grrt_year year

reshape long grrt_ , i(year) j(country) string

rename grrt_ grrt

destring year, replace

tempfile gdp_growth1
save `gdp_growth1' , replace

*import sheet 2 of 2
import excel "$input/aggregate/WB_GDP_growth.xls", sheet("Data_all2") firstrow clear

foreach x of varlist _all {
	rename `x' grrt_`x'
} 

rename grrt_year year

reshape long grrt_ , i(year) j(country) string

rename grrt_ grrt

destring year, replace

*append sheet 1
append using `gdp_growth1'

sort country year

order year country


keep if country == "DZA" | country == "ARG" | country == "BRA" | country == "BGR" | country == "CIV" | country == "CHL" | country == "COL" | country == "HRV" | country == "CZE" | country == "DOM" | country == "ECU" | country == "HUN" | country == "IDN" | country == "SLV" | country == "LBN" | country == "MYS" | country == "MEX" | country == "MAR" | country == "NGA" | country == "PAN" | country == "PER" | country == "PHL" | country == "POL" | country == "RUS" | country == "ZAF" | country == "KOR" | country == "THA" | country == "TUN" | country == "TUR" | country == "UKR" | country == "URY" | country == "VEN"


gen crisis = 0
gen crisis_3S = 0

*Non-Systemic Episodes

replace crisis = 1 if country=="DZA" & year == 1987
replace crisis = 1 if country=="DZA" & year == 1991
replace crisis = 1 if country=="DZA" & year == 1993

replace crisis = 1 if country=="ARG" & year == 1985
replace crisis = 1 if country=="ARG" & year == 1988

replace crisis = 1 if country=="BRA" & year == 1988
replace crisis = 1 if country=="BRA" & year == 1990
replace crisis = 1 if country=="BRA" & year == 1992
replace crisis = 1 if country=="BRA" & year == 2003

replace crisis = 1 if country=="BGR" & year == 1989
replace crisis = 1 if country=="BGR" & year == 1996

replace crisis = 1 if country=="CIV" & year == 2002
replace crisis = 1 if country=="CIV" & year == 1987
replace crisis = 1 if country=="CIV" & year == 1990
replace crisis = 1 if country=="CIV" & year == 1992
replace crisis = 1 if country=="CIV" & year == 2000

replace crisis = 1 if country=="HRV" & year == 1991

replace crisis = 1 if country=="CZE" & year == 1991

replace crisis = 1 if country=="DOM" & year == 1990
replace crisis = 1 if country=="DOM" & year == 2003

replace crisis = 1 if country=="ECU" & year == 1987

replace crisis = 1 if country=="HUN" & year == 1990
replace crisis = 1 if country=="HUN" & year == 1985
replace crisis = 1 if country=="HUN" & year == 1988

replace crisis = 1 if country=="LBN" & year == 1989

replace crisis = 1 if country=="MYS" & year == 1985

replace crisis = 1 if country=="MEX" & year == 1986
replace crisis = 1 if country=="MEX" & year == 2001

replace crisis = 1 if country=="MAR" & year == 1992
replace crisis = 1 if country=="MAR" & year == 1987
replace crisis = 1 if country=="MAR" & year == 1999

replace crisis = 1 if country=="PAN" & year == 1983
replace crisis = 1 if country=="PAN" & year == 1987

replace crisis = 1 if country=="PER" & year == 1988

replace crisis = 1 if country=="PHL" & year == 1984
replace crisis = 1 if country=="PHL" & year == 1991

replace crisis = 1 if country=="POL" & year == 1991

replace crisis = 1 if country=="RUS" & year == 1990

replace crisis = 1 if country=="ZAF" & year == 1985
replace crisis = 1 if country=="ZAF" & year == 1990

replace crisis = 1 if country=="TUN" & year == 1986

replace crisis = 1 if country=="TUR" & year == 2001

replace crisis = 1 if country=="UKR" & year == 1990

replace crisis = 1 if country=="URY" & year == 1999
replace crisis = 1 if country=="URY" & year == 1995

replace crisis = 1 if country=="VEN" & year == 1989
replace crisis = 1 if country=="VEN" & year == 1999
replace crisis = 1 if country=="VEN" & year == 2002
replace crisis = 1 if country=="VEN" & year == 1994
replace crisis = 1 if country=="VEN" & year == 1996

*3S Episodes

replace crisis_3S = 1 if country=="ARG" & year == 1981
replace crisis_3S = 1 if country=="ARG" & year == 1999
replace crisis_3S = 1 if country=="ARG" & year == 1995

replace crisis_3S = 1 if country=="BRA" & year == 1981

replace crisis_3S = 1 if country=="CHL" & year == 1982
replace crisis_3S = 1 if country=="CHL" & year == 1999

replace crisis_3S = 1 if country=="COL" & year == 1999

replace crisis_3S = 1 if country=="CIV" & year == 1983

replace crisis_3S = 1 if country=="ECU" & year == 1999
replace crisis_3S = 1 if country=="ECU" & year == 1982

replace crisis_3S = 1 if country=="SLV" & year == 1981

replace crisis_3S = 1 if country=="IDN" & year == 1998

replace crisis_3S = 1 if country=="LBN" & year == 2000

replace crisis_3S = 1 if country=="MYS" & year == 1998

replace crisis_3S = 1 if country=="MEX" & year == 1982
replace crisis_3S = 1 if country=="MEX" & year == 1995

replace crisis_3S = 1 if country=="MAR" & year == 1995
replace crisis_3S = 1 if country=="MAR" & year == 1981
replace crisis_3S = 1 if country=="MAR" & year == 1983
replace crisis_3S = 1 if country=="MAR" & year == 1997

replace crisis_3S = 1 if country=="NGA" & year == 1981

replace crisis_3S = 1 if country=="PER" & year == 1982
replace crisis_3S = 1 if country=="PER" & year == 1998

replace crisis_3S = 1 if country=="PHL" & year == 1998

replace crisis_3S = 1 if country=="RUS" & year == 1998

replace crisis_3S = 1 if country=="ZAF" & year == 1982

replace crisis_3S = 1 if country=="KOR" & year == 1998

replace crisis_3S = 1 if country=="THA" & year == 1997

replace crisis_3S = 1 if country=="TUN" & year == 1982

replace crisis_3S = 1 if country=="TUR" & year == 1994
replace crisis_3S = 1 if country=="TUR" & year == 1999

replace crisis_3S = 1 if country=="URY" & year == 1982

replace crisis_3S = 1 if country=="VEN" & year == 1981


replace crisis = 1 if crisis_3S == 1


*keep Calvo paper sample years
drop if year < 1980
drop if year > 2004


egen country_grp = group(country)

sum country_grp

gen country_id = country_grp

xtset country_grp year

tempfile calvo_data
save `calvo_data' , replace

local out "$tables/aggregates"

xtreg grrt L1.grrt L2.grrt L3.grrt L4.grrt crisis L1.crisis L2.crisis L3.crisis L4.crisis, fe 

mat coeff=e(b)
matrix coeffs=coeff[1,1..9]
mat V = e(V)
mat varmatrix = V[1..9, 1..9]


*based on replication code from Mueller AER 2008
*draw 1000 coefficients from the same distribution
clear
set matsize 2000
set obs 1000
drawnorm d1 d2 d3 d4 b0 b1 b2 b3 b4, means(coeffs) cov(varmatrix)
mkmat  d1 d2 d3 d4 b0 b1 b2 b3 b4, matrix(betas)

*simulate the impulse response for each of the draws
*to initiate the process we first do one iteration - this is repeated 999 times below
forvalues i=1/1 {

	*the growthvector will record the reaction of growth to the impulse given by the impulsevector
	*impulse in position 6 (makes it easier to calculate the impulse response function iteratively)
	matrix growthvector = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	matrix impulsevector = (0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

	local a = 0
	*calculate impulse response iteratively, i.e. first the first year after the crisis, then the second etc.
	*this following formula calculates the response not only to the original impulse but also the impact from lagged growth
	forvalues a = 6/22 {
		matrix growthvector[1,`a'] = betas[`i',1]*growthvector[1,`a'-1]+betas[`i',2]*growthvector[1,`a'-2]+betas[`i',3]*growthvector[1,`a'-3]+betas[`i',4]*growthvector[1,`a'-4]+betas[`i',5]*impulsevector[1,`a']+betas[`i',6]*impulsevector[1,`a'-1]+betas[`i',7]*impulsevector[1,`a'-2]+betas[`i',8]*impulsevector[1,`a'-3]+betas[`i',9]*impulsevector[1,`a'-4]
		}

	*take the first 10 years after the impulse and record it under the vector growthnumbers
	matrix growthnumbers = growthvector[1,6..17]
	*outputvector records the response in relative to a benchmark of 100 in period 1
	matrix outputvector = (0,0,0,0,0,0,0,0,0,0,0)
	*irf records the response in levels in percent
	matrix irf = (0,0,0,0,0,0,0,0,0,0,0)
	local t=1
	matrix outputvector[1,`t'] = 100*(1+growthnumbers[1,`t']/100)
     	matrix irf[1,`t'] = outputvector[1,`t']-100
	forvalues t=2/11 {
		matrix outputvector[1,`t'] = outputvector[1,`t'-1]*(1+growthnumbers[1,`t']/100)
	     	matrix irf[1,`t'] = outputvector[1,`t']-100
		}

	*initiate the irf matrix which will record all outputvectors
	matrix irf = (0),irf
	matrix irfs = irf
	}

*repeat this process 999 times
forvalues i=2/1000 {

	matrix growthvector = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	matrix impulsevector = (0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

	local a = 0
	forvalues a = 6/22 {
		matrix growthvector[1,`a'] = betas[`i',1]*growthvector[1,`a'-1]+betas[`i',2]*growthvector[1,`a'-2]+betas[`i',3]*growthvector[1,`a'-3]+betas[`i',4]*growthvector[1,`a'-4]+betas[`i',5]*impulsevector[1,`a']+betas[`i',6]*impulsevector[1,`a'-1]+betas[`i',7]*impulsevector[1,`a'-2]+betas[`i',8]*impulsevector[1,`a'-3]+betas[`i',9]*impulsevector[1,`a'-4]
		}
	matrix growthnumbers = growthvector[1,6..17]
	matrix outputvector = (0,0,0,0,0,0,0,0,0,0,0)
	matrix irf = (0,0,0,0,0,0,0,0,0,0,0)
	local t=1
	matrix outputvector[1,`t'] = 100*(1+growthnumbers[1,`t']/100)
     	matrix irf[1,`t'] = outputvector[1,`t']-100
	forvalues t=2/11 {
		matrix outputvector[1,`t'] = outputvector[1,`t'-1]*(1+growthnumbers[1,`t']/100)
	     	matrix irf[1,`t'] = outputvector[1,`t']-100
		}
	matrix irf = (0),irf
	matrix irfs = irfs\irf
	}

clear 
svmat irfs
*the dataset is now all the estimated irfs - these will only be used for the error bands

summarize irfs1- irfs12

collapse (sd) irfs*

gen se_irfs_y_0 = irfs1
gen se_irfs_y_1 = irfs2
gen se_irfs_y_2 = irfs3
gen se_irfs_y_3 = irfs4
gen se_irfs_y_4 = irfs5
gen se_irfs_y_5 = irfs6
gen se_irfs_y_6 = irfs7
gen se_irfs_y_7 = irfs8
gen se_irfs_y_8 = irfs9
gen se_irfs_y_9 = irfs10
gen se_irfs_y_10 = irfs11
gen se_irfs_y_11 = irfs12


gen beta_1=el(coeff,1,1)
gen beta_2=el(coeff,1,2)
gen beta_3=el(coeff,1,3)
gen beta_4=el(coeff,1,4)

gen delta_0=el(coeff,1,5)
gen delta_1=el(coeff,1,6)
gen delta_2=el(coeff,1,7)
gen delta_3=el(coeff,1,8)
gen delta_4=el(coeff,1,9)


gen g_0 = delta_0

gen g_1 = beta_1*g_0 + delta_1

gen g_2 = beta_1*g_1 + beta_2*g_0 + delta_2

gen g_3 = beta_1*g_2 + beta_2*g_1 + beta_3*g_0 + delta_3

gen g_4 = beta_1*g_3 + beta_2*g_2 + beta_3*g_1 + beta_4*g_0 + delta_4

gen g_5 = beta_1*g_4 + beta_2*g_3 + beta_3*g_2 + beta_4*g_1

gen g_6 = beta_1*g_5 + beta_2*g_4 + beta_3*g_3 + beta_4*g_2

gen g_7 = beta_1*g_6 + beta_2*g_5 + beta_3*g_4 + beta_4*g_3

gen g_8 = beta_1*g_7 + beta_2*g_6 + beta_3*g_5 + beta_4*g_4

gen g_9 = beta_1*g_8 + beta_2*g_7 + beta_3*g_6 + beta_4*g_5

gen g_10 = beta_1*g_9 + beta_2*g_8 + beta_3*g_7 + beta_4*g_6

gen y_0 = 1
gen y_1 = 1*(1+g_0/100)
gen y_2 = y_1*(1+g_1/100)
gen y_3 = y_2*(1+g_2/100)
gen y_4 = y_3*(1+g_3/100)
gen y_5 = y_4*(1+g_4/100)
gen y_6 = y_5*(1+g_5/100)
gen y_7 = y_6*(1+g_6/100)
gen y_8 = y_7*(1+g_7/100)
gen y_9 = y_8*(1+g_8/100)
gen y_10 = y_9*(1+g_9/100)
gen y_11 = y_10*(1+g_10/100)

forvalues i = 0/11 {
replace y_`i' = (y_`i' - 1)*100
}

gen irf = 1

keep y_* se_irfs* irf

collapse y_* se_irfs* irf

reshape long y_ se_irfs_y_ , i(irf) j(year)

rename y_ output
rename se_irfs_y_ se_output

gen output_plus1se = output + se_output
gen output_less1se = output - se_output

** Figure B.1 - panel b

local color_1 = "0 76 153"
local color_2 = "0 0 0"

local width_ = "2.6"
local height_ = "1.8"

twoway ///
line output year, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5) ///
|| line output_plus1se year, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5) lp("_##") ///
|| line output_less1se year, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5) lp("_##") ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(-16(4)0, labsize(large)) xsize(`width_') ysize(`height_') yscale(titlegap(*+7)) xlabel(0(1)10, labsize(large)) ///
legend(off) 
graph export "$output/figureB1_b.pdf", replace


*Cerra & Saxena Figure 4 replication

import excel "$input/aggregate/Cerra_Saxena_2008AER_data.xls", sheet("bankcrisis") firstrow clear

reshape long @_BANKCRISIS_CAPSYST, i(obs) j(country) string

rename _BANKCRISIS_CAPSYST bankcrisis

tempfile bankcrisis
save `bankcrisis' , replace

import excel "$input/aggregate/Cerra_Saxena_2008AER_data.xls", sheet("currcrisis") firstrow clear

reshape long @_CRISIS, i(obs) j(country) string

rename _CRISIS currcrisis

tempfile currcrisis
save `currcrisis' , replace

import excel "$input/aggregate/Cerra_Saxena_2008AER_data.xls", sheet("grrt") firstrow clear

reshape long @_GRRT_WB, i(obs) j(country) string

rename _GRRT_WB grrt

merge 1:1 obs country using `bankcrisis'

drop _merge

merge 1:1 obs country using `currcrisis'

drop _merge

rename obs year

egen country_grp = group(country)

gen country_id = country_grp

xtset country_grp year


generate bankcstart = 1 if bankcrisis == 1 & L1.bankcrisis!=1

replace bankcstart = 0 if bankcstart ==. & bankcrisis!=.

*to calculate number of countries with episode
*keep if bankcstart = 1
*egen country_grp_crisis = group(country)


xtreg grrt L1.grrt L2.grrt L3.grrt L4.grrt bankcstart L1.bankcstart L2.bankcstart L3.bankcstart L4.bankcstart, fe 

mat coeff=e(b)
matrix coeffs=coeff[1,1..9]
mat V = e(V)
mat varmatrix = V[1..9, 1..9]


*based on replication code from Mueller AER 2008
*draw 1000 coefficients from the same distribution
clear
set matsize 2000
set obs 1000
drawnorm d1 d2 d3 d4 b0 b1 b2 b3 b4, means(coeffs) cov(varmatrix)
mkmat  d1 d2 d3 d4 b0 b1 b2 b3 b4, matrix(betas)

*simulate the impulse response for each of the draws
*to initiate the process we first do one iteration - this is repeated 999 times below
forvalues i=1/1 {

	*the growthvector will record the reaction of growth to the impulse given by the impulsevector
	*impulse in position 6 (makes it easier to calculate the impulse response function iteratively)
	matrix growthvector = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	matrix impulsevector = (0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

	local a = 0
	*calculate impulse response iteratively, i.e. first the first year after the crisis, then the second etc.
	*this following formula calculates the response not only to the original impulse but also the impact from lagged growth
	forvalues a = 6/22 {
		matrix growthvector[1,`a'] = betas[`i',1]*growthvector[1,`a'-1]+betas[`i',2]*growthvector[1,`a'-2]+betas[`i',3]*growthvector[1,`a'-3]+betas[`i',4]*growthvector[1,`a'-4]+betas[`i',5]*impulsevector[1,`a']+betas[`i',6]*impulsevector[1,`a'-1]+betas[`i',7]*impulsevector[1,`a'-2]+betas[`i',8]*impulsevector[1,`a'-3]+betas[`i',9]*impulsevector[1,`a'-4]
		}

	*take the first 10 years after the impulse and record it under the vector growthnumbers
	matrix growthnumbers = growthvector[1,6..17]
	*outputvector records the response in relative to a benchmark of 100 in period 1
	matrix outputvector = (0,0,0,0,0,0,0,0,0,0,0)
	*irf records the response in levels in percent
	matrix irf = (0,0,0,0,0,0,0,0,0,0,0)
	local t=1
	matrix outputvector[1,`t'] = 100*(1+growthnumbers[1,`t']/100)
     	matrix irf[1,`t'] = outputvector[1,`t']-100
	forvalues t=2/11 {
		matrix outputvector[1,`t'] = outputvector[1,`t'-1]*(1+growthnumbers[1,`t']/100)
	     	matrix irf[1,`t'] = outputvector[1,`t']-100
		}

	*initiate the irf matrix which will record all outputvectors
	matrix irf = (0),irf
	matrix irfs = irf
	}

*repeat this process 999 times
forvalues i=2/1000 {

	matrix growthvector = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	matrix impulsevector = (0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

	local a = 0
	forvalues a = 6/22 {
		matrix growthvector[1,`a'] = betas[`i',1]*growthvector[1,`a'-1]+betas[`i',2]*growthvector[1,`a'-2]+betas[`i',3]*growthvector[1,`a'-3]+betas[`i',4]*growthvector[1,`a'-4]+betas[`i',5]*impulsevector[1,`a']+betas[`i',6]*impulsevector[1,`a'-1]+betas[`i',7]*impulsevector[1,`a'-2]+betas[`i',8]*impulsevector[1,`a'-3]+betas[`i',9]*impulsevector[1,`a'-4]
		}
	matrix growthnumbers = growthvector[1,6..17]
	matrix outputvector = (0,0,0,0,0,0,0,0,0,0,0)
	matrix irf = (0,0,0,0,0,0,0,0,0,0,0)
	local t=1
	matrix outputvector[1,`t'] = 100*(1+growthnumbers[1,`t']/100)
     	matrix irf[1,`t'] = outputvector[1,`t']-100
	forvalues t=2/11 {
		matrix outputvector[1,`t'] = outputvector[1,`t'-1]*(1+growthnumbers[1,`t']/100)
	     	matrix irf[1,`t'] = outputvector[1,`t']-100
		}
	matrix irf = (0),irf
	matrix irfs = irfs\irf
	}

clear 
svmat irfs
*the dataset is now all the estimated irfs - these will only be used for the error bands

summarize irfs1- irfs12

collapse (sd) irfs*

gen se_irfs_y_0 = irfs1
gen se_irfs_y_1 = irfs2
gen se_irfs_y_2 = irfs3
gen se_irfs_y_3 = irfs4
gen se_irfs_y_4 = irfs5
gen se_irfs_y_5 = irfs6
gen se_irfs_y_6 = irfs7
gen se_irfs_y_7 = irfs8
gen se_irfs_y_8 = irfs9
gen se_irfs_y_9 = irfs10
gen se_irfs_y_10 = irfs11
gen se_irfs_y_11 = irfs12



gen beta_1=el(coeff,1,1)
gen beta_2=el(coeff,1,2)
gen beta_3=el(coeff,1,3)
gen beta_4=el(coeff,1,4)

gen delta_0=el(coeff,1,5)
gen delta_1=el(coeff,1,6)
gen delta_2=el(coeff,1,7)
gen delta_3=el(coeff,1,8)
gen delta_4=el(coeff,1,9)


gen g_0 = delta_0

gen g_1 = beta_1*g_0 + delta_1

gen g_2 = beta_1*g_1 + beta_2*g_0 + delta_2

gen g_3 = beta_1*g_2 + beta_2*g_1 + beta_3*g_0 + delta_3

gen g_4 = beta_1*g_3 + beta_2*g_2 + beta_3*g_1 + beta_4*g_0 + delta_4

gen g_5 = beta_1*g_4 + beta_2*g_3 + beta_3*g_2 + beta_4*g_1

gen g_6 = beta_1*g_5 + beta_2*g_4 + beta_3*g_3 + beta_4*g_2

gen g_7 = beta_1*g_6 + beta_2*g_5 + beta_3*g_4 + beta_4*g_3

gen g_8 = beta_1*g_7 + beta_2*g_6 + beta_3*g_5 + beta_4*g_4

gen g_9 = beta_1*g_8 + beta_2*g_7 + beta_3*g_6 + beta_4*g_5

gen g_10 = beta_1*g_9 + beta_2*g_8 + beta_3*g_7 + beta_4*g_6

gen y_0 = 1
gen y_1 = 1*(1+g_0/100)
gen y_2 = y_1*(1+g_1/100)
gen y_3 = y_2*(1+g_2/100)
gen y_4 = y_3*(1+g_3/100)
gen y_5 = y_4*(1+g_4/100)
gen y_6 = y_5*(1+g_5/100)
gen y_7 = y_6*(1+g_6/100)
gen y_8 = y_7*(1+g_7/100)
gen y_9 = y_8*(1+g_8/100)
gen y_10 = y_9*(1+g_9/100)
gen y_11 = y_10*(1+g_10/100)

forvalues i = 0/11 {
replace y_`i' = (y_`i' - 1)*100
}

gen irf = 1

keep y_* se_irfs* irf

collapse y_* se_irfs* irf

reshape long y_ se_irfs_y_ , i(irf) j(year)

rename y_ output
rename se_irfs_y_ se_output

gen output_plus1se = output + se_output
gen output_less1se = output - se_output

** Figure B.1 - panel c

local color_1 = "0 76 153"
local color_2 = "0 0 0"

local width_ = "2.6"
local height_ = "1.8"

twoway ///
line output year, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5) ///
|| line output_plus1se year, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5) lp("_##") ///
|| line output_less1se year, lw(1) lc("`color_1'") mc("`color_1'") msize(2.5) lp("_##") ///
, name(a,replace) xtitle("") ytitle("") ///
graphregion(color(white)) ylabel(-10(2)0, labsize(large)) xsize(`width_') ysize(`height_') yscale(titlegap(*+7)) xlabel(0(1)10, labsize(large)) ///
legend(off) 
graph export "$output/figureB1_c.pdf", replace




