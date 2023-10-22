clear
capture log close
capture graph close
log using logs/1-table_3.log, replace

if "$access_to_datamyne" == "yes" {
************************************************
   *********     CLEAN DATA     ***********
************************************************	
do code/data_prep/0-clean_firm_names // clean and synchronize firm names
do code/data_prep/1-merge_raw_import_data // merge raw data for years 2007-2013
do code/data_prep/2-revise_hs_codes // update HS10 codes for longitudinal consistency
do code/data_prep/3-construct_variables // construct variables for demand estimation
************************************************

use "./data/temp/colombia_imports_cleaned", clear

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

*----- match HS product codes with ISIC industry codes -----
gen hs6=substr(ProductHS,1,6)
destring hs6, replace
merge m:1 hs6 using "./data/concordance/isic_hs6.dta"
replace isic=3600 if _merge == 1
drop _merge

*----- trim data -------
winsor2 Dlprice Dln_x_wih, replace cuts(1 99) by(fe1) trim

rename Dexc_usd Z1
rename Dexc_col Z2

lab var Z1 "Shift-share IV based on exchange rate with US dollar"
lab var Z2 "Shift-share IV based on exchange rate with Peso"
generate Z = cond(!missing(Z1) & Z1!=0, Z1, Z2, .)

**********************************************************
*****     PERFORM INDUSTRY-LEVEL ESTIMATION      ******
**********************************************************

set more off
	#delimit;	
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda = Z1 Dln_nfirms Dln_nproducts Dltax) 
	if isic>=100 & isic<1500, a(fe1) cluster(fe2 fe1);
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment replace  
	ctitle("" "A&M") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g );
	replace theta = -_b[Dlprice]  if isic>=100 & isic<1500;
	replace theta_se = _se[Dlprice]  if isic>=100 & isic<1500;
	replace a = (1 - _b[Dln_cond_lambda])  if isic>=100 & isic<1500;
	replace a_se = _se[Dln_cond_lambda]  if isic>=100 & isic<1500;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=100 & isic<1500;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2 
	+ (_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=100 & isic<1500;
	replace fstat = e(widstat) if isic>=100 & isic<1500;
	replace obsv =  e(N) if isic>=100 & isic<1500;
	replace id=1 if isic>=100 & isic<1500;

ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda = Z Dln_nfirms Dln_nproducts Dltax) 
	if isic>=1500 & isic<1700, a(fe1) cluster(fe2 fe1) ;  
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment merge  
	ctitle( "" "Food") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g );
	replace theta = -_b[Dlprice]  if isic>=1500 & isic<1700;
	replace theta_se = _se[Dlprice]  if isic>=1500 & isic<1700;
	replace a = (1 - _b[Dln_cond_lambda])  if isic>=1500 & isic<1700;
	replace a_se = _se[Dln_cond_lambda] if isic>=1500 & isic<1700;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=1500 & isic<1700;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2 
		+ (_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=1500 & isic<1700;
	replace fstat = e(widstat) if  isic>=1500 & isic<1700;
	replace obsv =  e(N) if  isic>=1500 & isic<1700;
	replace id=2 if isic>=1500 & isic<1700;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda = Z Dln_nfirms Dln_nproducts Dltax) 
	if isic>=1700 & isic<2000, a(fe1)  cluster(fe2 fe1);
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment merge  
	ctitle( "" "Text&L&F") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g );
	replace theta = -_b[Dlprice]  if isic>=1700 & isic<2000;
	replace theta_se = _se[Dlprice]  if isic>=1700 & isic<2000;
	replace a = (1 - _b[Dln_cond_lambda])  if isic>=1700 & isic<2000;
	replace a_se = _se[Dln_cond_lambda] if isic>=1700 & isic<2000;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=1700 & isic<2000;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2 
		+ (_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=1700 & isic<2000;
	replace fstat = e(widstat) if  isic>=1700 & isic<2000;
	replace obsv =  e(N) if  isic>=1700 & isic<2000;
	replace id=3 if isic>=1700 & isic<2000;

ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda = Z Dln_nfirms Dln_nproducts Dltax) 
	if isic>=2000 & isic<2100, a(fe1) cluster(fe2 fe1);
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment merge  
	ctitle("" "Wood") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[Dlprice]  if isic>=2000 & isic<2100;
	replace theta_se = _se[Dlprice]  if isic>=2000 & isic<2100;
	replace a = (1 - _b[Dln_cond_lambda])  if isic>=2000 & isic<2100;
	replace a_se = _se[Dln_cond_lambda] if isic>=2000 & isic<2100;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=2000 & isic<2100;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2 
		+ (_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=2000 & isic<2100;
	replace fstat = e(widstat) if  isic>=2000 & isic<2100;
	replace obsv =  e(N) if  isic>=2000 & isic<2100;
	replace id=4 if isic>=2000 & isic<2100;

ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =  Z1 Dln_nfirms Dln_nproducts Dltax)
	if isic>=2100 & isic<2300, a(fe1) cluster(fe2 fe1);  
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment merge  
	ctitle("" "Paper") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[Dlprice]  if isic>=2100 & isic<2300;
	replace theta_se = _se[Dlprice]  if isic>=2100 & isic<2300;
	replace a = (1 - _b[Dln_cond_lambda])  if isic>=2100 & isic<2300;
	replace a_se = _se[Dln_cond_lambda] if isic>=2100 & isic<2300;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=2100 & isic<2300;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2 
		+ (_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=2100 & isic<2300;
	replace fstat = e(widstat) if  isic>=2100 & isic<2300;
	replace obsv =  e(N) if  isic>=2100 & isic<2300;
	replace id=5 if isic>=2100 & isic<2300;

ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =  Z Dln_nfirms Dln_nproducts Dltariff) 
 if isic>=2300 & isic<2400, a(fe1) 	cluster(fe2 fe1);  
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment merge  
	ctitle("" "Petr") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[Dlprice]   if isic>=2300 & isic<2400;
	replace theta_se = _se[Dlprice]  if isic>=2300 & isic<2400;
	replace a = (1 - _b[Dln_cond_lambda])  if isic>=2300 & isic<2400;
	replace a_se = _se[Dln_cond_lambda] if isic>=2300 & isic<2400;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=2300 & isic<2400;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2
		+ (_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=2300 & isic<2400;
	replace fstat = e(widstat) if  isic>=2300 & isic<2400;
	replace obsv =  e(N) if  isic>=2300 & isic<2400;	
	replace id=6 if isic>=2300 & isic<2400;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =  Z Dln_nfirms Dln_nproducts Dlvat) 
	if isic>=2400 & isic<2500, a(fe1) 	cluster(fe2 fe1);
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment merge  
	ctitle("" "Chem") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[Dlprice]  if isic>=2400 & isic<2500;
	replace theta_se = _se[Dlprice]  if isic>=2400 & isic<2500;
	replace a = (1 - _b[Dln_cond_lambda])  if isic>=2400 & isic<2500;
	replace a_se = _se[Dln_cond_lambda] if isic>=2400 & isic<2500;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=2400 & isic<2500;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2 
		+ (_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=2400 & isic<2500;
	replace fstat = e(widstat) if  isic>=2400 & isic<2500;
	replace obsv =  e(N) if  isic>=2400 & isic<2500;
	replace id=7 if isic>=2400 & isic<2500;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =  Z Dln_nfirms Dln_nproducts Dlvat) 
	if isic>=2500 & isic<2600, a(fe1)	cluster(fe2 fe1); 
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment merge  
	ctitle("" "Rub&Plas") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[Dlprice]  if isic>=2500 & isic<2600;
	replace theta_se = _se[Dlprice]  if isic>=2500 & isic<2600;
	replace a = (1 - _b[Dln_cond_lambda])  if isic>=2500 & isic<2600;
	replace a_se = _se[Dln_cond_lambda] if isic>=2500 & isic<2600;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=2500 & isic<2600;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2 
		+ (_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=2500 & isic<2600;
	replace fstat = e(widstat) if  isic>=2500 & isic<2600;
	replace obsv =  e(N) if  isic>=2500 & isic<2600;
	replace id=8 if isic>=2500 & isic<2600;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =  Z Dln_nfirms Dln_nproducts Dlvat) 
	if isic>=2600 & isic<2700, a(fe1)	cluster(fe2 fe1); 
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment merge  
	ctitle("" "Miner") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[Dlprice]  if isic>=2600 & isic<2700;
	replace theta_se = _se[Dlprice]  if isic>=2600 & isic<2700;
	replace a = (1 - _b[Dln_cond_lambda])  if isic>=2600 & isic<2700;
	replace a_se = _se[Dln_cond_lambda]  if isic>=2600 & isic<2700;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=2600 & isic<2700;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2 
	+ (_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=2600 & isic<2700;
	replace fstat = e(widstat) if  isic>=2600 & isic<2700;
	replace obsv =  e(N) if  isic>=2600 & isic<2700;
	replace id=9 if isic>=2600 & isic<2700;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =  Z Dln_nfirms Dln_nproducts Dlvat) 
	if isic>=2700 & isic<2900, a(fe1)	cluster(fe2 fe1);  
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment merge  
	ctitle("" "BasFaM") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[Dlprice]  if isic>=2700 & isic<2900;
	replace theta_se = _se[Dlprice]  if isic>=2700 & isic<2900;
	replace a = (1 - _b[Dln_cond_lambda])  if isic>=2700 & isic<2900;
	replace a_se = _se[Dln_cond_lambda] if isic>=2700 & isic<2900;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=2700 & isic<2900;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2 
	+ (_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=2700 & isic<2900;
	replace fstat = e(widstat) if  isic>=2700 & isic<2900;
	replace obsv =  e(N) if isic>=2700 & isic<2900;
	replace id=10 if isic>=2700 & isic<2900;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =   Z Dln_nfirms Dln_nproducts Dltax) 
	if isic>=2900 & isic<3100, a(fe1)	cluster(fe2 fe1); 
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment merge  
	ctitle("" "Mach") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[Dlprice]  if isic>=2900 & isic<3100;
	replace theta_se = _se[Dlprice]  if isic>=2900 & isic<3100;
	replace a = (1 - _b[Dln_cond_lambda])  if isic>=2900 & isic<3100;
	replace a_se = _se[Dln_cond_lambda] if isic>=2900 & isic<3100;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=2900 & isic<3100;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2 
	+ (_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=2900 & isic<3100;
	replace fstat = e(widstat) if  isic>=2900 & isic<3100;
	replace obsv =  e(N) if  isic>=2900 & isic<3100;
	replace id=11 if isic>=2900 & isic<3100;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =   Z Dln_nfirms Dln_nproducts Dltax) 
	if isic>=3100 & isic<3400, a(fe1)	cluster(fe2 fe1);
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment merge  
	ctitle("" "Elec") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[Dlprice]  if isic>=3100 & isic<3400;
	replace theta_se = _se[Dlprice]  if isic>=3100 & isic<3400;
	replace a = (1 - _b[Dln_cond_lambda])  if isic>=3100 & isic<3400;
	replace a_se = _se[Dln_cond_lambda]  if isic>=3100 & isic<3400;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=3100 & isic<3400;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2 
	+ (_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=3100 & isic<3400;
	replace fstat = e(widstat) if  isic>=3100 & isic<3400;
	replace obsv =  e(N) if  isic>=3100 & isic<3400;
	replace id=12 if isic>=3100 & isic<3400;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =   Z Dln_nfirms Dln_nproducts Dltariff) 
	if isic>=3400 & isic<3600, a(fe1)	cluster(fe2 fe1);
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment merge  
	ctitle("" "Trnsp") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[Dlprice]  if isic>=3400 & isic<3600;
	replace theta_se = _se[Dlprice]  if isic>=3400 & isic<3600;
	replace a = (1 - _b[Dln_cond_lambda])  if isic>=3400 & isic<3600;
	replace a_se = _se[Dln_cond_lambda]  if isic>=3400 & isic<3600;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=3400 & isic<3600;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2 + 
	(_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=3400 & isic<3600;
	replace fstat = e(widstat) if  isic>=3400 & isic<3600;
	replace obsv =  e(N) if  isic>=3400 & isic<3600;
	replace id=13  if isic>=3400 & isic<3600;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =   Z Dln_nfirms Dln_nproducts Dltax) 
	if isic>=3600 & isic<3800, a(fe1)	cluster(fe2 fe1);
outreg using output/temp/Table3_outreg.tex, varlabels tex fragment merge  
	ctitle("" "MnfR") nocons se bdec(3) statfont(normalsize)
	sigsymbols(*,**,***) starlevels(10 5 1) hlines(101{0}1010010001)  
	summtitle( N Obs.\Weak Ident Test \UnderIdent P-val\ N Prod-Year grs.)
	summstat(N\widstat \idp\ N_g ) ;
	replace theta = -_b[Dlprice]  if isic>=3600 & isic<3800;
	replace theta_se = _se[Dlprice]  if isic>=3600 & isic<3800;
	replace a = (1 - _b[Dln_cond_lambda]) if isic>=3600 & isic<3800;
	replace a_se = _se[Dln_cond_lambda] if isic>=3600 & isic<3800;
	replace psi = -(1 - _b[Dln_cond_lambda])/_b[Dlprice]  if isic>=3600 & isic<3800;
	replace psi_se = psi * ( (_se[Dlprice]/_b[Dlprice])^2 
	+ (_se[Dln_cond_lambda]/(1-_b[Dln_cond_lambda]))^2 )^0.5 if isic>=3600 & isic<3800;
	replace fstat = e(widstat) if  isic>=3600 & isic<3800;
	replace obsv =  e(N) if  isic>=3600 & isic<3800;
	replace id=14 if isic>=3600 & isic<3800;
	
collapse  theta theta_se psi psi_se a a_se fstat obsv, by(id);
save data/internally_generated/table3_estimates.dta, replace;

#delimit cr

}
*******************************************************
  *******   CREATE TABLE 3 in TEX FROMAT   ********
*******************************************************
use data/internally_generated/table3_estimates.dta, clear
capture file close OuputTable
	file open  OuputTable using "output/Table_3.tex", write replace
	file write 	OuputTable /// 
	    "\begin{adjustwidth}{-0.25in}{-0.0in}" _n ///																					 
		"\small" _n ///
		"\begin{tabular}{lccccccccccc}" _n ///
		"\toprule" _n ///
		"& & & \multicolumn{5}{c}{Estimated Parameter} && \phantom{abc} & \phantom{abc} & \\"	_n ///
		"\cmidrule{4-8}"_n ///
		"Sector & ISIC4 codes && $\sigma_{k}-1$ && $\frac{\sigma_{k}-1}{\gamma_{k}-1}$ && $\mu_{k}$ && Obs. & \specialcell{\footnotesize Weak \\ Ident. Test} \\" _n ///
		"\midrule"
		
		local sectors  `" "Agriculture \& Mining" "Food" "Textiles, Leather \& Footwear" "Wood" "Paper" "Petroleum"  "Chemicals" "Rubber \& Plastic"  "Minerals" "Basic \& Fabricated Metals" "Machinery" 	 "Electrical \& Optical Equipment"  "Transport Equipment" "N.E.C. \& Recycling"  "'
		
				local isic  `" "100-1499" "1500-1699" "1700-1999" "2000-2099" "2100-2299" "2300-2399" "2400-2499" "2500-2599"  "2600-2699" "2700-2899" "2900-3099" "3100-3399" "3400-3599" "3600-3800"  "'
		
		forval i = 1/14 {
        
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
		"& && \footnotesize(" %6.3f (D) ") && \footnotesize(" %6.3f (E) ") && \footnotesize(" %6.3f (F) ") &&     &    \\ \addlinespace														"
		
		}
		
	file write OuputTable ///	
	"\bottomrule \\ \end{tabular} \vspace{-0.2in} \\"	_n ///
    "\footnotesize {\it Notes}. Estimation results of Equation \eqref{eq:Main}. Standard errors in parentheses. The estimation is conducted with HS10 product-year fixed effects." _n ///
	"All standard errors are simultaneously clustered by product-year and by origin-product, which is akin to the correction proposed by \citet{adao2019shift}." _n ///      
	"The weak identification test statistics is the F statistics from the Kleibergen-Paap Wald test for weak identification of all instrumented variables." _n ///
	"The test for over-identification is not reported due to the pitfalls of the standard over-identification Sargan-Hansen J test in the multi-dimensional large datasets pointed by \cite{AngrsitEtAl96}." _n ///
    "\end{adjustwidth}"
																						 
file close OuputTable

rename theta theta_baseline
rename psi psi_baseline
keep theta_baseline psi_baseline id
save data/temp/baseline_estimates.dta, replace

*erase "./data/temp/colombia_imports_cleaned.dta"
log close
