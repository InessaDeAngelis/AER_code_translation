clear
**************************************************************/

use "data/exchange_rate_report_boc/exchange_rate_report.dta", clear
collapse (mean) xrate_usd xrate_col,by( month year country )


gen CountryofOrigin=strupper(country)
sort CountryofOrigin
collapse (mean) xrate_usd xrate_col , by(month year CountryofOrigin)

egen id=group(CountryofOrigin)
gen date=ym(year, month)
tsset id date

*gen Flxrate_col = log(F12.xrate_col) - log(F11.xrate_col)
*gen Flxrate_usd = log(F12.xrate_usd) - log(F11.xrate_usd)

local n_lag=7

******************************************
forvalues y=1/`n_lag'  {
local x2 = 12*`y'
local x1 = 12*(`y' - 1 ) 
gen exc_col_F`y' = 100*(log(F`x2'.xrate_col) - log(F`x1'.xrate_col))
gen exc_usd_F`y' = 100*(log(F`x2'.xrate_usd) - log(F`x1'.xrate_usd))
}
drop id

merge 1:m CountryofOrigin year month using "data/temp/colombia_imports_updated_hs.dta"
*merge 1:m CountryofOrigin year month using Colombiaimports_HS10_collapsed

destring  VATPercent TariffPercent ExchangeRate, replace
drop if CustomsValueTariffBase<0

collapse (sum) CustomsValueTariffBase Valuetobepay Quantity (mean) VATPercent TariffPercent exc_col_F* exc_usd_F* ExchangeRate [fw=CustomsValueTariffBase], by(year ProductHS CountryofOrigin Provider)
***************************************

egen id = group(ProductHS CountryofOrigin Provider)
drop if missing(id)
tsset id year

generate Dexc_col = cond(!missing(L.exc_col_F1) ,  L.exc_col_F1, ///
                    cond(!missing(L2.exc_col_F2) , L2.exc_col_F2, ///
			        cond(!missing(L3.exc_col_F3) , L3.exc_col_F3, ///
				    cond(!missing(L4.exc_col_F4) , L4.exc_col_F4, ///
				    cond(!missing(L5.exc_col_F5) , L5.exc_col_F5, ///
					cond(!missing(L6.exc_col_F6) , L6.exc_col_F6, ///
				    cond(!missing(L7.exc_col_F7) , L7.exc_col_F7, ///
										. )))))))
										
generate Dexc_usd = cond(!missing(L.exc_usd_F1) ,  L.exc_usd_F1, ///
                    cond(!missing(L2.exc_usd_F2) , L2.exc_usd_F2, ///
				    cond(!missing(L3.exc_usd_F3) , L3.exc_usd_F3, ///
				    cond(!missing(L4.exc_usd_F4) , L4.exc_usd_F4, ///
				    cond(!missing(L5.exc_usd_F5) , L4.exc_usd_F5, ///
					cond(!missing(L6.exc_usd_F6) , L5.exc_usd_F6, ///
					cond(!missing(L7.exc_usd_F7) , L6.exc_usd_F7, ///
									. )))))))

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
*gen ltariff=log(1+TariffPercent)
*gen lvat=log(1+VATPercent)
gen ltax = lvat + ltariff
gen lexc = log(ExchangeRate)

gen ln_x_wih = log(x_whi)
gen ln_q_wih = log(Quantity)

*gen lexc_col = log(exc_col)
*gen lexc_usd = log(exc_usd)

gen hs8=substr(ProductHS,1,8)
destring hs8, replace
*gen mnf=(hs2>=30 & hs2<=38) | (hs2>=42 & hs2<=97)

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
foreach var in lprice ln_x_wih ltax ltariff lvat ln_cond_lambda ln_nfirms ln_nproducts lexc {
	gen D`var'=100*D.`var'
	}
	
	keep if Dln_x_wih!=.
	
egen fe1=group(ProductHS year)
gen fe2=panelvar


*drop if Quantity<=1
*drop if FOBValueUS<500

gen hs2=substr(ProductHS,1,2)
bysort year hs2 CountryofOrigin : egen x_i=total(x_whi)
bysort year hs2 Provider : egen x_w=total(x_whi)
drop if x_w/x_i>0.1


keep Dln_x_wih Dln_cond_lambda Dlprice Dexc_col Dexc_usd Dlvat Dltariff Dltax fe1 fe2 ProductHS Dln_nfirms Dln_nproducts ///
ln_x_wih ln_cond_lambda lprice ltariff lvat ltax ln_nfirms ln_nproducts ltariff_lag ltax_lag year Dlexc

*****************************************
gen theta=.
gen theta_se=.
gen a_se=.
gen a = .
gen psi=.
gen psi_se=.
gen id=.


gen hs2=substr(ProductHS,1,2)
destring hs2, replace
gen mnf=(hs2>=30 & hs2<=38) | (hs2>=42 & hs2<=97)
drop hs2

gen hs6=substr(ProductHS,1,6)
destring hs6, replace

merge m:1 hs6 using data/concordance/isic_hs6
replace isic=3600 if _merge == 1
drop _merge

winsor2 Dlprice Dln_x_wih, replace cuts(1 99) by(fe1) trim
rename Dexc_usd Z1
rename Dexc_col Z2

generate Z = cond(!missing(Z1) & Z1!=0, Z1, Z2, .)
************************************************
*****   INDUSTRY-LEVEL ESTIMATION    ***********
************************************************

set more off
	#delimit;
		

ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda = Z Dln_nfirms Dln_nproducts Dltax) Dlexc
	if isic>=100 & isic<1500, liml a(fe1);
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment replace  
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
	replace id=1 if isic>=100 & isic<1500;


ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda = Z Dln_nfirms Dln_nproducts Dltax) Dlexc
	if isic>=1500 & isic<1700, a(fe1)  ;  
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment merge  
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
	replace id=2 if isic>=1500 & isic<1700;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda = Z Dln_nfirms Dln_nproducts Dltax) Dlexc
	if isic>=1700 & isic<2000, a(fe1) ;
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment merge  
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
	replace id=3 if isic>=1700 & isic<2000;

ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda = Z Dln_nfirms Dln_nproducts Dltax) Dlexc
	if isic>=2000 & isic<2100, a(fe1) ;
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment merge  
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
	replace id=4 if isic>=2000 & isic<2100;

ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =  Z1 Dln_nfirms Dln_nproducts Dltax) Dlexc
	if isic>=2100 & isic<2300, a(fe1) ;  
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment merge  
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
	replace id=5 if isic>=2100 & isic<2300;

ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =  Z Dln_nfirms Dln_nproducts Dltariff) 
 if isic>=2300 & isic<2400, a(fe1) ;  
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment merge  
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
	replace id=6 if isic>=2300 & isic<2400;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =  Z Dln_nfirms Dln_nproducts Dlvat) Dlexc
	if isic>=2400 & isic<2500, a(fe1) ;
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment merge  
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
	replace id=7 if isic>=2400 & isic<2500;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =  Z Dln_nfirms Dln_nproducts Dlvat) Dlexc
	if isic>=2500 & isic<2600, a(fe1); 
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment merge  
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
	replace id=8 if isic>=2500 & isic<2600;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =  Z Dln_nfirms Dln_nproducts Dlvat) Dlexc
	if isic>=2600 & isic<2700, a(fe1); 
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment merge  
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
	replace id=9 if isic>=2600 & isic<2700;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =  Z Dln_nfirms Dln_nproducts Dlvat) Dlexc
	if isic>=2700 & isic<2900, a(fe1);  
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment merge  
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
	replace id=10 if isic>=2700 & isic<2900;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =   Z Dln_nfirms Dln_nproducts Dltax) 
	if isic>=2900 & isic<3100, a(fe1); 
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment merge  
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
	replace id=11 if isic>=2900 & isic<3100;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =   Z Dln_nfirms Dln_nproducts Dltax) Dlexc
	if isic>=3100 & isic<3400, a(fe1);
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment merge  
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
	replace id=12 if isic>=3100 & isic<3400;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =   Z Dln_nfirms Dln_nproducts Dltariff) Dlexc
	if isic>=3400 & isic<3600, a(fe1);
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment merge  
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
	replace id=13  if isic>=3400 & isic<3600;
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =   Z Dln_nfirms Dln_nproducts Dltax) Dlexc
	if isic>=3600 & isic<3800, a(fe1);
outreg using output/temp/FigP1_C_outreg.tex, varlabels tex fragment merge  
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
	replace id=14 if isic>=3600 & isic<3800;
	
collapse  theta psi, by(id);
save data/internally_generated/figP1_large_firms.dta, replace;


	
