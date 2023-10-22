clear

use "data/exchange_rate_report_boc/exchange_rate_report.dta", clear
collapse (mean) xrate_usd xrate_col,by( month year country )


gen CountryofOrigin=strupper(country)
sort CountryofOrigin
collapse (mean) xrate_usd xrate_col , by(month year CountryofOrigin)

egen id=group(CountryofOrigin)
gen date=ym(year, month)
tsset id date

local n_lag=7

************** Construct Shift-Share IV **************
forvalues y=1/`n_lag'  {
local x2 = 12*`y'
local x1 = 12*(`y' - 1 ) 
gen exc_col_F`y' = 100*(log(F`x2'.xrate_col) - log(F`x1'.xrate_col))
gen exc_usd_F`y' = 100*(log(F`x2'.xrate_usd) - log(F`x1'.xrate_usd))
}

drop id
merge 1:m CountryofOrigin year month using "data/temp/colombia_imports_updated_hs.dta"

destring  VATPercent TariffPercent ExchangeRate, replace
drop if CustomsValueTariffBase<0
******************************************************************************

collapse (sum) CustomsValueTariffBase Valuetobepay Quantity ///
(mean) VATPercent TariffPercent exc_col_F* exc_usd_F* [fw=CustomsValueTariffBase], ///
by(year ProductHS CountryofOrigin Provider)


egen id = group(ProductHS CountryofOrigin Provider)
drop if missing(id)
tsset id year

local spec = 1

if `spec'== 0 {
generate Dexc_col = cond(!missing(L7.exc_col_F7) , L7.exc_col_F7, ///
                    cond(!missing(L6.exc_col_F6) , L6.exc_col_F6, ///
			        cond(!missing(L5.exc_col_F5) , L5.exc_col_F5, ///
				    cond(!missing(L4.exc_col_F4) , L4.exc_col_F4, ///
				    cond(!missing(L3.exc_col_F3) , L3.exc_col_F3, ///
					cond(!missing(L2.exc_col_F2) , L2.exc_col_F2, ///
				    cond(!missing(L.exc_col_F1) , L.exc_col_F1, ///
										. )))))))
										
generate Dexc_usd = cond(!missing(L7.exc_usd_F7) , L7.exc_usd_F7, ///
                    cond(!missing(L6.exc_usd_F6) , L6.exc_usd_F6, ///
				    cond(!missing(L5.exc_usd_F5) , L5.exc_usd_F5, ///
				    cond(!missing(L4.exc_usd_F4) , L4.exc_usd_F4, ///
				    cond(!missing(L3.exc_usd_F3) , L3.exc_usd_F3, ///
					cond(!missing(L2.exc_usd_F2) , L2.exc_usd_F2, ///
					cond(!missing(L.exc_usd_F1) , L.exc_usd_F1, ///
									. )))))))
}


if `spec'== 1 {
generate Dexc_col = cond(!missing(L.exc_col_F1) , L.exc_col_F1, ///
                    cond(!missing(L2.exc_col_F2) , L2.exc_col_F2, ///
			        cond(!missing(L3.exc_col_F3) , L3.exc_col_F3, ///
				    cond(!missing(L4.exc_col_F4) , L4.exc_col_F4, ///
				    cond(!missing(L5.exc_col_F5) , L5.exc_col_F5, ///
					cond(!missing(L6.exc_col_F6) , L6.exc_col_F6, ///
				    cond(!missing(L7.exc_col_F7) , L7.exc_col_F7, ///
										. )))))))
										
generate Dexc_usd = cond(!missing(L.exc_usd_F1) , L.exc_usd_F1, ///
                    cond(!missing(L2.exc_usd_F2) , L2.exc_usd_F2, ///
				    cond(!missing(L3.exc_usd_F3) , L3.exc_usd_F3, ///
				    cond(!missing(L4.exc_usd_F4) , L4.exc_usd_F4, ///
				    cond(!missing(L5.exc_usd_F5) , L4.exc_usd_F5, ///
					cond(!missing(L6.exc_usd_F6) , L5.exc_usd_F6, ///
					cond(!missing(L7.exc_usd_F7) , L6.exc_usd_F7, ///
									. )))))))
}


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

egen panelvar = group(ProductHS CountryofOrigin Provider)
drop if missing(panelvar)

*******************************************************
** Contructing Khandelwal IVs for Within-National Share
********************************************************

* number of firms exporting from country i in product h
bysort year CountryofOrigin ProductHS: gen ln_nfirms=log(_N )

* number of products firm w exports in
bysort year CountryofOrigin Provider: gen ln_nproducts=log(_N )

tsset id year
gen ltariff_lag = L.ltariff
gen ltax_lag = L.ltax
********************************************************

xtset panelvar year
foreach var in lprice ln_x_wih ltax ltariff lvat ln_cond_lambda ln_nfirms ln_nproducts {
	gen D`var'=100*D.`var'
	}
	
	keep if Dln_x_wih!=.
	
egen fe1=group(ProductHS year)
gen fe2=panelvar


*drop if Quantity<=1
*drop if FOBValueUS<500

keep Dln_x_wih Dln_cond_lambda Dlprice Dexc_col Dexc_usd Dlvat Dltariff Dltax fe1 fe2 ProductHS Dln_nfirms Dln_nproducts ///
ln_x_wih ln_cond_lambda lprice ltariff lvat ltax ln_nfirms ln_nproducts ltariff_lag ltax_lag year

save "./data/temp/colombia_imports_cleaned", replace
