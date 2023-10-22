clear
capture log close
capture graph close
log using logs/12-table_S1.log, replace


if "$access_to_datamyne" == "yes" {
use "./data/temp/colombia_imports_cleaned.dta", clear

gen hs2=substr(ProductHS,1,2)
destring hs2, replace
gen mnf=(hs2>=30 & hs2<=38) | (hs2>=42 & hs2<=97)
drop hs2

bysort fe1: egen ub=pctile(Dlprice), p(99)
bysort fe2: egen lb=pctile(Dlprice), p(1)
drop if Dlprice>ub | Dlprice<lb

rename Dexc_usd Z1
rename Dexc_col Z2
gen Z = cond(!missing(Z1) & Z1!=0, Z1, Z2, .)

************************************************
 *********     POOLED ESTIMATION    ***********
************************************************	

gen a_IV = .
gen a_se_IV = .
gen b_IV = .
gen b_se_IV = .
gen a_OLS = .
gen a_se_OLS = .
gen b_OLS = .
gen b_se_OLS = .
gen fstat = .
gen idp = .
gen obsv = .
gen r2 = .
gen N_fe = .



ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =  Z1 Dln_nfirms Dln_nproducts Dltax) if mnf, a(fe1) cluster(fe2) 
replace a_IV = _b[Dlprice] if mnf
replace a_se_IV = _se[Dlprice] if mnf
replace b_IV = _b[Dln_cond_lambda] if mnf
replace b_se_IV = _se[Dln_cond_lambda] if mnf
replace fstat =  e(cdf) if mnf
replace idp = e(idp) if mnf

 

reghdfe Dln_x_wih  Dlprice Dln_cond_lambda  if mnf, a(fe1) cluster(fe1 fe2)
replace a_OLS = _b[Dlprice] if mnf
replace a_se_OLS = _se[Dlprice] if mnf
replace b_OLS = _b[Dln_cond_lambda] if mnf
replace b_se_OLS = _se[Dln_cond_lambda] if mnf
replace obsv =  e(N) if mnf	
replace r2 = e(r2_within) if mnf
replace N_fe = e(N_clust) if mnf
	
	
ivreghdfe Dln_x_wih  (Dlprice Dln_cond_lambda =   Z1 Dln_nfirms Dln_nproducts Dltariff) if ~mnf, a(fe1) cluster(fe2)
replace a_IV = _b[Dlprice] if ~mnf
replace a_se_IV = _se[Dlprice] if ~mnf
replace b_IV = _b[Dln_cond_lambda] if ~mnf
replace b_se_IV = _se[Dln_cond_lambda] if ~mnf
replace fstat =  e(cdf) if ~mnf
replace idp = e(idp) if ~mnf	


reghdfe Dln_x_wih  Dlprice Dln_cond_lambda  if ~mnf, a(fe1) cluster(fe1 fe2)
replace a_OLS = _b[Dlprice] if ~mnf
replace a_se_OLS = _se[Dlprice] if ~mnf
replace b_OLS = _b[Dln_cond_lambda] if ~mnf
replace b_se_OLS = _se[Dln_cond_lambda] if ~mnf
replace obsv =  e(N) if ~mnf	
replace r2 = e(r2_within) if ~mnf
replace N_fe = e(N_clust) if ~mnf

collapse (mean) a_IV a_se_IV b_IV b_se_IV a_OLS a_se_OLS b_OLS b_se_OLS fstat idp obsv r2 N_fe, by(mnf)

save data/internally_generated/tableS1_estimates.dta, replace

erase "./data/temp/colombia_imports_cleaned.dta"
}


use data/internally_generated/tableS1_estimates.dta, clear
sort mnf

scalar A_IV_mnf = a_IV[2]
scalar A_se_IV_mnf = a_se_IV[2]
scalar B_IV_mnf = b_IV[2]
scalar B_se_IV_mnf = b_se_IV[2]
scalar fstat_mnf = fstat[2]
scalar idp_mnf = idp[2]

scalar A_OLS_mnf = a_OLS[2]
scalar A_se_OLS_mnf = a_se_OLS[2]
scalar B_OLS_mnf = b_OLS[2]
scalar B_se_OLS_mnf = b_se_OLS[2]
scalar obsv_mnf =  obsv[2]
scalar r2_mnf = r2[2]
scalar N_fe_mnf = N_fe[2]

scalar A_IV_non = a_IV[1]
scalar A_se_IV_non = a_se_IV[1]
scalar B_IV_non = b_IV[1]
scalar B_se_IV_non = b_se_IV[1]
scalar fstat_non =  fstat[1]
scalar idp_non = idp[1]

scalar A_OLS_non = a_OLS[1]
scalar A_se_OLS_non = a_se_OLS[1]
scalar B_OLS_non = b_OLS[1]
scalar B_se_OLS_non = b_se_OLS[1]
scalar obsv_non =  obsv[1]
scalar r2_non = r2[1]
scalar N_fe_non = N_fe[1]

************************************************
*****      CREATE TABLE 9 in LaTex    ********
************************************************	

capture file close OuputTable
	file open  OuputTable using "output/Table_S1.tex", write replace
	file write 	OuputTable /// 
	"\begin{adjustwidth}{0.2in}{0in}"  _n ///
	"\begin{tabular}{lccccccc}"  _n ///
	"		\toprule		"   _n ///                          
    " &  &                \multicolumn{2}{c}{Manufacturing}  & \phantom{abc} &  \multicolumn{2}{c}{Non-Manufacturing}  \\"  _n ///
    "                                         \cmidrule{3-4}  \cmidrule{6-7}                       "  _n ///
    " Variable (log)                                               &&    2SLS     &   OLS     &&                      2SLS  &     OLS  \\  "  _n ///
    "                                     \midrule                   "   _n ///
    "Price, $1-\sigma$ &&"  %6.3f (A_IV_mnf) "*** &" %6.3f (A_OLS_mnf) "&&"  %6.3f (A_IV_non) "&"  %6.3f (A_OLS_non) "\\"  _n ///
	 " 	 && ("   %6.3f (A_se_IV_mnf) ") & (" %6.3f (A_se_OLS_mnf) ") && ("  %6.3f (A_se_IV_non) ") & ("  %6.3f (A_se_OLS_non) ") \\ \addlinespace"  _n ///
	 "Within-national share, $1-\mu(\sigma-1)$ &&"  %3.2f (B_IV_mnf) "*** &" %3.2f (B_OLS_mnf) "&&"  %3.2f (B_IV_non) "&"  %3.2f (B_OLS_non) "\\"  _n ///
	 " 	 && ("   %6.3f (B_se_IV_mnf) ") & (" %6.3f (B_se_OLS_mnf) ") && ("  %6.3f (B_se_IV_non) ") & ("  %6.3f (B_se_OLS_non) ") \\ \\"  _n ///
	 "Weak Identification Test           & &"  %3.2f (fstat_mnf) "&  ... 	&&"          %3.2f (fstat_non)   "& ...   \\"  _n ///
     "Under-Identification P-value       & &"  %3.2f (idp_mnf)   "&   ...	&&"   %3.2f (idp_non)  "& ...   \\"  _n /// 
     "Within-$R^{2}$      & &  ...      &"    %3.2f (r2_mnf)      "&&             ...     &"    %3.2f (r2_non)   "\\" _n /// 
     "N of Product-Year Groups   & &  \multicolumn{2}{c}{" %9.0fc (N_fe_mnf) "}	&&            \multicolumn{2}{c}{" %9.0fc (N_fe_non) "} \\ "   _n ///  
     "Observations               & &   \multicolumn{2}{c}{" %9.0fc (obsv_mnf) "}	&&            \multicolumn{2}{c}{" %9.0fc (obsv_non) "}  \\"  _n ///
	"\bottomrule \\ \end{tabular} \vspace{0.05in} \\"	_n ///	
    "\footnotesize {\it Notes}. *** denotes significant at the 1\% level. The Estimating Equation is \eqref{eq:Main}.  Standard errors in brackets are robust to clustering within product-year. " _n ///
	"The estimation is conducted with HS10 product-year fixed effects. The reported $R^2$ in the OLS specifications correspond to within-group goodness of fit. " _n ///      
	"Weak identification test statistics is the F statistics from the Kleibergen-Paap Wald test for weak identification of all instrumented variables. " _n ///
	"The p-value of the under-identification test of instrumented variables is based on the Kleibergen-Paap LM test. " _n ///
	"The test for over-identification is not reported due to the pitfalls of the standard over-identification Sargan-Hansen J test in the multi-dimensional large datasets pointed by \cite{AngrsitEtAl96}." _n ///
    "\end{adjustwidth}"
																 
file close OuputTable

log close
