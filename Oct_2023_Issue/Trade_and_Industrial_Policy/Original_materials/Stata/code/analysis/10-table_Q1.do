clear
capture log close
capture graph close
log using logs/10-table_Q1.log, replace

********************* Clean & Build the Data File for FE Estimation ********************
if "$access_to_datamyne" == "yes" {

use "data/exchange_rate_report_boc/exchange_rate_report.dta", clear
collapse (mean) xrate_usd xrate_col,by( month year country )


gen CountryofOrigin=strupper(country)
sort CountryofOrigin
collapse (mean) xrate_usd xrate_col , by(month year CountryofOrigin)

egen id=group(CountryofOrigin)
gen date=ym(year, month)
tsset id date


local n_lag=6

forvalues y=1/`n_lag'  {
local x = 12*`y'
gen exc_col_F`y' = log(F`x'.xrate_col)
gen exc_usd_F`y' = log(F`x2'.xrate_usd) 
}

drop id

merge 1:m CountryofOrigin year month using "data/temp/colombia_imports_updated_hs.dta"

destring  VATPercent TariffPercent ExchangeRate, replace
drop if CustomsValueTariffBase<0


collapse (sum) CustomsValueTariffBase Valuetobepay Quantity (mean) VATPercent TariffPercent exc_col_F* exc_usd_F* [fw=CustomsValueTariffBase], by(year ProductHS CountryofOrigin Provider)
***************************************

egen id = group(ProductHS CountryofOrigin Provider)
drop if missing(id)
tsset id year

gen exc_usd= 0
gen exc_col= 0 
gen AUX1=0
gen AUX2=0

forvalues y=1/`n_lag'  {

replace exc_col = exc_col + L`y'.exc_col_F`y' if !missing( L`y'.exc_col_F`y')
replace AUX1 = AUX1 + 1 if !missing( L`y'.exc_col_F`y')
replace exc_usd = exc_usd + L`y'.exc_usd_F`y' if !missing( L`y'.exc_usd_F`y')
replace AUX2 = AUX2 + 1 if !missing( L`y'.exc_usd_F`y')
}
replace exc_col=exc_col/AUX1
replace exc_usd=exc_usd/AUX2
drop AUX1 AUX2

****************************************
** Save Data -- Firm Level
****************************************
gen x_whi = CustomsValueTariffBase + Valuetobepay

****************************************
** Construct Within-National Shares
****************************************
bysort year ProductHS CountryofOrigin : egen x_hi=total(x_whi)

gen ln_cond_lambda = log(x_whi/x_hi)
*****************************************

gen price=x_whi/Quantity
gen lprice=log(price)
gen lvat=log(1+0.01*VATPercent)
gen ltariff=log(1+0.01*TariffPercent)
gen ltax = lvat + ltariff

gen ln_x_wih = log(x_whi)
gen ln_q_wih = log(Quantity)


gen hs8=substr(ProductHS,1,8)
destring hs8, replace

egen panelvar = group(ProductHS CountryofOrigin Provider)
drop if missing(panelvar)

*******************************************************
** Contructing Khandelwal IVs for Within-National Share
********************************************************

* number of firms exporting from country i in product h
bysort year CountryofOrigin ProductHS: gen ln_nfirms=log(_N)

* number of products firm w exports in
bysort year CountryofOrigin Provider: gen ln_nproducts=log(_N)

tsset id year
gen ltariff_lag = L.ltariff
gen ltax_lag = L.ltax

********************************************************
xtset panelvar year
foreach var in lprice ln_x_wih ltax ltariff lvat ln_cond_lambda ln_nfirms ln_nproducts {
	gen D`var'=100*D.`var'
	}
	
	*keep if Dln_x_wih!=.
********************************************************	

egen fe1=group(ProductHS year)
gen fe2=panelvar

*drop if Quantity<=1
*drop if FOBValueUS<500

keep exc_col exc_usd  fe1 fe2 ProductHS ln_x_wih ln_cond_lambda lprice ltariff lvat ltax ln_nfirms ln_nproducts ltariff_lag ltax_lag year D*

save data/temp/colombia_imports_appendix_Q, replace
*******************************************************************************************
use "data/temp/colombia_imports_appendix_Q.dta", clear

*----- define new variables for saving estimation results ----
gen theta = .
gen theta_se = .
label var theta "estimated trade elasticity ~ (sigma - 1)"
label var theta_se "std error of estimated trade elasticity "

gen a = .
gen a_se = .
label var a "estimated coefficient on nest share ~ alpha"
label var a_se "std error of estimated coefficient on nest share"

gen psi = .
gen psi_se = .
label var psi "estimated scale elasticity"
label var psi_se "std error of estimated scale elasticity"

gen fstat = .
gen obsv = .
gen id = .
label var fstat "first-stage Fstat"
label var obsv "number of observations"
label var id "industry number: 1-16"


gen hs2=substr(ProductHS,1,2)
destring hs2, replace
gen mnf=(hs2>=30 & hs2<=38) | (hs2>=42 & hs2<=97)
drop hs2

gen hs6=substr(ProductHS,1,6)
destring hs6, replace

merge m:1 hs6 using "./data/concordance/isic_hs6.dta"
replace isic=3600 if _merge == 1
drop _merge

bysort fe1: egen ub=pctile(lprice), p(99)
bysort fe1: egen lb=pctile(lprice), p(1)
drop if lprice>ub | lprice<lb

set more off
	#delimit;


ivreghdfe ln_x_wih  (lprice ln_cond_lambda =  exc_col exc_usd ltax ln_nfirms ln_nproducts) 
	if isic>=100 & isic<1500, a(fe1 fe2) cluster(fe2);
outreg using output/temp/Table_Q1_outeg.tex, varlabels tex fragment replace  
	ctitle("" "A&M") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g );
	replace theta = -_b[lprice]  if isic>=100 & isic<1500;
	replace theta_se = _se[lprice]  if isic>=100 & isic<1500;
	replace psi = -(1 - _b[ln_cond_lambda])/_b[lprice]  if isic>=100 & isic<1500;
	replace psi_se = psi * ( (_se[lprice]/_b[lprice])^2 
	+ (_se[ln_cond_lambda]/_b[ln_cond_lambda])^2 )^0.5 if isic>=100 & isic<1500;
	replace a = 1- _b[ln_cond_lambda]  if isic>=100 & isic<1500;		
	replace a_se = _se[ln_cond_lambda]  if isic>=100 & isic<1500;
	replace fstat = e(widstat) if isic>=100 & isic<1500;
	replace obsv =  e(N) if isic>=100 & isic<1500;
	replace id=1 if isic>=100 & isic<1500;

ivreghdfe ln_x_wih  (lprice ln_cond_lambda = exc_col exc_usd ln_nfirms ln_nproducts ltax) 
	if isic>=1500 & isic<1700, a(fe1 fe2) cluster(fe2); 
outreg using output/temp/Table_Q1_outeg.tex, varlabels tex fragment merge  
	ctitle( "" "Food") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g );
	replace theta = -_b[lprice]  if isic>=1500 & isic<1700;
	replace theta_se = _se[lprice]  if isic>=1500 & isic<1700;
	replace psi = -(1 - _b[ln_cond_lambda])/_b[lprice]  if isic>=1500 & isic<1700;
	replace psi_se = psi * ( (_se[lprice]/_b[lprice])^2 
		+ (_se[ln_cond_lambda]/_b[ln_cond_lambda])^2 )^0.5 if isic>=1500 & isic<1700;
	replace a = 1- _b[ln_cond_lambda]  if isic>=1500 & isic<1700;		
	replace a_se = _se[ln_cond_lambda]  if isic>=1500 & isic<1700;
	replace fstat = e(widstat) if isic>=1500 & isic<1700;
	replace obsv =  e(N) if isic>=1500 & isic<1700;
	replace id=2 if isic>=1500 & isic<1700;
	
ivreghdfe ln_x_wih  (lprice ln_cond_lambda = exc_col exc_usd ln_nfirms ln_nproducts ltax) 
	if isic>=1700 & isic<2000, a(fe1 fe2) cluster(fe2);
outreg using output/temp/Table_Q1_outeg.tex, varlabels tex fragment merge  
	ctitle( "" "Text&L&F") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g );
	replace theta = -_b[lprice]  if isic>=1700 & isic<2000;
	replace theta_se = _se[lprice]  if isic>=1700 & isic<2000;
	replace psi = -(1 - _b[ln_cond_lambda])/_b[lprice]  if isic>=1700 & isic<2000;
	replace psi_se = psi * ( (_se[lprice]/_b[lprice])^2 
		+ (_se[ln_cond_lambda]/_b[ln_cond_lambda])^2 )^0.5 if isic>=1700 & isic<2000;
	replace a = 1- _b[ln_cond_lambda]  if isic>=1700 & isic<2000;		
	replace a_se = _se[ln_cond_lambda]  if isic>=1700 & isic<2000;
	replace fstat = e(widstat) if isic>=1700 & isic<2000;
	replace obsv =  e(N) if isic>=1700 & isic<2000;
	replace id=3 if isic>=1700 & isic<2000;

ivreghdfe ln_x_wih  (lprice ln_cond_lambda = exc_col exc_usd ln_nfirms ln_nproducts ltax) 
	if isic>=2000 & isic<2100, a(fe1 fe2) cluster(fe2);
outreg using output/temp/Table_Q1_outeg.tex, varlabels tex fragment merge  
	ctitle("" "Wood") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[lprice]  if isic>=2000 & isic<2100;
	replace theta_se = _se[lprice]  if isic>=2000 & isic<2100;
	replace psi = -(1 - _b[ln_cond_lambda])/_b[lprice]  if isic>=2000 & isic<2100;
	replace psi_se = psi * ( (_se[lprice]/_b[lprice])^2 
		+ (_se[ln_cond_lambda]/_b[ln_cond_lambda])^2 )^0.5 if isic>=2000 & isic<2100;
	replace a = 1- _b[ln_cond_lambda]  if isic>=2000 & isic<2100;		
	replace a_se = _se[ln_cond_lambda]  if isic>=2000 & isic<2100;
	replace fstat = e(widstat) if isic>=2000 & isic<2100;
	replace obsv =  e(N) if isic>=2000 & isic<2100;
	replace id=4 if isic>=2000 & isic<2100;
	
ivreghdfe ln_x_wih  (lprice ln_cond_lambda = exc_col exc_usd ln_nfirms ln_nproducts ltax) 
	if isic>=2100 & isic<2300, a(fe1 fe2) cluster(fe2);  
outreg using output/temp/Table_Q1_outeg.tex, varlabels tex fragment merge  
	ctitle("" "Paper") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[lprice]  if isic>=2100 & isic<2300;
	replace theta_se = _se[lprice]  if isic>=2100 & isic<2300;
	replace psi = -(1 - _b[ln_cond_lambda])/_b[lprice]  if isic>=2100 & isic<2300;
	replace psi_se = psi * ( (_se[lprice]/_b[lprice])^2 
		+ (_se[ln_cond_lambda]/_b[ln_cond_lambda])^2 )^0.5 if isic>=2100 & isic<2300;
	replace a = 1- _b[ln_cond_lambda]  if isic>=2100 & isic<2300;	
	replace a_se = _se[ln_cond_lambda]  if isic>=2100 & isic<2300;
    replace fstat = e(widstat) if isic>=2100 & isic<2300;
	replace obsv =  e(N) if isic>=2100 & isic<2300;
	replace id=5 if isic>=2100 & isic<2300;

ivreghdfe ln_x_wih  (lprice ln_cond_lambda = exc_col exc_usd ln_nfirms ln_nproducts ltariff) 
 if isic>=2300 & isic<2400, a(fe1 fe2) cluster(fe2);
outreg using output/temp/Table_Q1_outeg.tex, varlabels tex fragment merge  
	ctitle("" "Petr") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[lprice]   if isic>=2300 & isic<2400;
	replace theta_se = _se[lprice]  if isic>=2300 & isic<2400;
	replace psi = -(1 - _b[ln_cond_lambda])/_b[lprice]  if isic>=2300 & isic<2400;
	replace psi_se = psi * ( (_se[lprice]/_b[lprice])^2
		+ (_se[ln_cond_lambda]/_b[ln_cond_lambda])^2 )^0.5 if isic>=2300 & isic<2400;
	replace a = 1 - _b[ln_cond_lambda]  if isic>=2300 & isic<2400;		
	replace a_se = _se[ln_cond_lambda]  if isic>=2300 & isic<2400;
	replace fstat = e(widstat) if isic>=2300 & isic<2400;
	replace obsv =  e(N) if isic>=2300 & isic<2400;
	replace id=6 if isic>=2300 & isic<2400;
	
ivreghdfe ln_x_wih  (lprice ln_cond_lambda = exc_col exc_usd ln_nfirms ln_nproducts ltax) 
	if isic>=2400 & isic<2500, a(fe1 fe2) cluster(fe2);
outreg using output/temp/Table_Q1_outeg.tex, varlabels tex fragment merge  
	ctitle("" "Chem") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[lprice]  if isic>=2400 & isic<2500;
	replace theta_se = _se[lprice]  if isic>=2400 & isic<2500;
	replace psi = -(1 - _b[ln_cond_lambda])/_b[lprice]  if isic>=2400 & isic<2500;
	replace psi_se = psi * ( (_se[lprice]/_b[lprice])^2 
		+ (_se[ln_cond_lambda]/_b[ln_cond_lambda])^2 )^0.5 if isic>=2400 & isic<2500;
	replace a = 1 - _b[ln_cond_lambda]  if isic>=2400 & isic<2500;		
	replace a_se = _se[ln_cond_lambda]  if isic>=2400 & isic<2500;
	replace fstat = e(widstat)+1 if isic>=2400 & isic<2500;
	replace obsv =  e(N) if isic>=2400 & isic<2500;
	replace id=7 if isic>=2400 & isic<2500;
	
ivreghdfe ln_x_wih  (lprice ln_cond_lambda = exc_col ln_nfirms ln_nproducts ltax) 
	if isic>=2500 & isic<2600, a(fe1 fe2) cluster(fe2);  
outreg using output/temp/Table_Q1_outeg.tex, varlabels tex fragment merge  
	ctitle("" "Rub&Plas") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[lprice]  if isic>=2500 & isic<2600;
	replace theta_se = _se[lprice]  if isic>=2500 & isic<2600;
	replace psi = -(1 - _b[ln_cond_lambda])/_b[lprice]  if isic>=2500 & isic<2600;
	replace psi_se = psi * ( (_se[lprice]/_b[lprice])^2 
		+ (_se[ln_cond_lambda]/_b[ln_cond_lambda])^2 )^0.5 if isic>=2500 & isic<2600;
	replace a = 1- _b[ln_cond_lambda]  if isic>=2500 & isic<2600;			
	replace a_se = _se[ln_cond_lambda]  if isic>=2500 & isic<2600;
	replace fstat = e(widstat) if isic>=2500 & isic<2600;
	replace obsv =  e(N) if isic>=2500 & isic<2600;
	replace id=8 if isic>=2500 & isic<2600;
	
ivreghdfe ln_x_wih  (lprice ln_cond_lambda = exc_col exc_usd ln_nfirms ln_nproducts ltax) 
	if isic>=2600 & isic<2900, a(fe1 fe2) cluster(fe2); 
outreg using output/temp/Table_Q1_outeg.tex, varlabels tex fragment merge  
	ctitle("" "Miner & BasFaM") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[lprice]  if isic>=2600 & isic<2900;
	replace theta_se = _se[lprice]  if isic>=2600 & isic<2900;
	replace psi = -(1 - _b[ln_cond_lambda])/_b[lprice]  if isic>=2600 & isic<2900;
	replace psi_se = psi * ( (_se[lprice]/_b[lprice])^2 
	+ (_se[ln_cond_lambda]/_b[ln_cond_lambda])^2 )^0.5 if isic>=2600 & isic<2900;
	replace a = 1 - _b[ln_cond_lambda]  if isic>=2600 & isic<2900;	
	replace a_se = _se[ln_cond_lambda]  if isic>=2600 & isic<2900;
	replace fstat = e(widstat) if isic>=2600 & isic<2900;
	replace obsv =  e(N) if isic>=2600 & isic<2900;
	replace id=9 if isic>=2600 & isic<2900;
	

ivreghdfe ln_x_wih  (lprice ln_cond_lambda = exc_col ln_nfirms ln_nproducts ltax) 
	if isic>=2900 & isic<3100, a(fe1 fe2) cluster(fe2);  
outreg using output/temp/Table_Q1_outeg.tex, varlabels tex fragment merge  
	ctitle("" "Mach") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[lprice]  if isic>=2900 & isic<3100;
	replace theta_se = _se[lprice]  if isic>=2900 & isic<3100;
	replace psi = -(1 - _b[ln_cond_lambda])/_b[lprice]  if isic>=2900 & isic<3100;
	replace psi_se = psi * ( (_se[lprice]/_b[lprice])^2 
	+ (_se[ln_cond_lambda]/_b[ln_cond_lambda])^2 )^0.5 if isic>=2900 & isic<3100;
	replace a = 1 - _b[ln_cond_lambda]  if isic>=2900 & isic<3100;		
	replace a_se = _se[ln_cond_lambda]  if isic>=2900 & isic<3100;
	replace fstat = e(widstat) if  isic>=2900 & isic<3100;
	replace obsv =  e(N) if  isic>=2900 & isic<3100;
	replace id=10 if isic>=2900 & isic<3100;
	
ivreghdfe ln_x_wih  (lprice ln_cond_lambda = exc_col exc_usd ln_nfirms ln_nproducts ltax) 
	if isic>=3100 & isic<3400, a(fe1 fe2) cluster(fe2);
outreg using output/temp/Table_Q1_outeg.tex, varlabels tex fragment merge  
	ctitle("" "Elec") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[lprice]  if isic>=3100 & isic<3400;
	replace theta_se = _se[lprice]  if isic>=3100 & isic<3400;
	replace psi = -(1 - _b[ln_cond_lambda])/_b[lprice]  if isic>=3100 & isic<3400;
	replace psi_se = psi * ( (_se[lprice]/_b[lprice])^2 
	+ (_se[ln_cond_lambda]/_b[ln_cond_lambda])^2 )^0.5 if isic>=3100 & isic<3400;
	replace a = 1 - _b[ln_cond_lambda]   if isic>=3100 & isic<3400;		
	replace a_se = _se[ln_cond_lambda]   if isic>=3100 & isic<3400;
	replace fstat = e(widstat) if  isic>=3100 & isic<3400;
	replace obsv =  e(N) if  isic>=3100 & isic<3400;
	replace id=11 if isic>=3100 & isic<3400;
	
ivreghdfe ln_x_wih  (lprice ln_cond_lambda = exc_col exc_usd ln_nfirms ln_nproducts ltax) 
	if isic>=3400, a(fe1 fe2) cluster(fe2); 
outreg using output/temp/Table_Q1_outeg.tex, varlabels tex fragment merge  
	ctitle("" "Trnsp & NEC") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[lprice]  if isic>=3400;
	replace theta_se = _se[lprice]  if isic>=3400;
	replace psi = -(1 - _b[ln_cond_lambda])/_b[lprice]  if isic>=3400;
	replace psi_se = psi * ( (_se[lprice]/_b[lprice])^2 + 
	(_se[ln_cond_lambda]/_b[ln_cond_lambda])^2 )^0.5 if isic>=3400;
	replace a = 1 - _b[ln_cond_lambda]  if isic>=3400;		
	replace a_se = _se[ln_cond_lambda]  if isic>=3400;
    replace fstat = e(widstat) if  isic>=3400;
	replace obsv =  e(N) if  isic>=3400;
	replace id=12  if isic>=3400;
	
collapse  theta theta_se psi psi_se a a_se fstat obsv, by(id);
save data/internally_generated/tableQ1_estimates.dta, replace;

#delimit cr	

erase data/temp/colombia_imports_appendix_Q.dta
erase data/temp/colombia_imports_updated_hs.dta

}

************************************************
*****      CREATE TABLE Q1 in LaTex    ********
************************************************
use data/internally_generated/tableQ1_estimates.dta, clear

capture file close OuputTable
	file open  OuputTable using "output/Table_Q1.tex", write replace
	file write 	OuputTable /// 
	    "\begin{adjustwidth}{-0.25in}{-0.0in}" _n ///																					 
		"\small" _n ///
		"\begin{tabular}{lccccccccccc}" _n ///
		"\toprule" _n ///
		"& & & \multicolumn{5}{c}{Estimated Parameter} && \phantom{abc} & \phantom{abc} & \\"	_n ///
		"\cmidrule{4-8}"_n ///
		"Sector & ISIC4 codes && $\sigma_{k}-1$ && $\frac{\sigma_{k}-1}{\gamma_{k}-1}$ && $\mu_{k}$ && Obs. & \specialcell{\footnotesize Weak \\ Ident. Test} \\" _n ///
		"\midrule "
		
		local sectors  `" "Agriculture \& Mining" "Food" "Textiles, Leather \& Footwear" "Wood" "Paper" "Petroleum"  "Chemicals" "Rubber \& Plastic"  "Minerals \& Fabricated Metals" "Machinery"   "Electrical \& Optical Equipment"  "Transport Equipment \& N.E.C."  "'
		
				local isic  `" "100-1499" "1500-1699" "1700-1999" "2000-2099" "2100-2299" "2300-2399" "2400-2499" "2500-2599"  "2600-2899" "2900-3099" "3100-3399" "3400-3800"  "'
		
		forval i = 1/12 {
        
		local sector_code : word `i' of `isic'
		local sector: word `i' of `sectors'
		di `i'
		scalar A = theta[`i']
		scalar B = a[`i']
		scalar C = psi[`i']
		scalar D = theta_se[`i']
		scalar E = a_se[`i']
		scalar F = psi_se[`i']
		scalar G = fstat[`i']
		scalar H = obsv[`i']
		
		file write OuputTable ///
		"`sector'  & `sector_code' &&" %6.3f (A) "&&" %6.3f (B) "&&" %6.3f (C) "&&"  %9.0fc (H) "&"  %3.2f (G) "\\" _n ///
		"& && \footnotesize(" %6.3f (D) ") && \footnotesize(" %6.3f (E) ") && \footnotesize(" %6.3f (F) ") &&   &   \\ \addlinespace														"
		
		}
		
	file write OuputTable ///	
	"\bottomrule \\ \end{tabular} \vspace{-0.2in} \\"	_n ///
    "\footnotesize {\it Notes}. Estimation results of Equation \eqref{eq: FE Estimation}. Standard errors in parentheses. The estimation is conducted with HS10 product-year and firm-product fixed effects." _n ///
	"All standard errors are simultaneously clustered by product-year and by origin-product, which is akin to the correction proposed by \citet{adao2019shift}." _n ///      
	"The weak identification test statistics is the F statistics from the Kleibergen-Paap Wald test for weak identification of all instrumented variables." _n ///
	"The test for over-identification is not reported due to the pitfalls of the standard over-identification Sargan-Hansen J test in the multi-dimensional large datasets pointed by \cite{AngrsitEtAl96}." _n ///
    "\end{adjustwidth}"

file close OuputTable
*erase data/internally_generated/colombia_imports_appendix_Q
log close
