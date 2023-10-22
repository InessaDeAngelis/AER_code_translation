clear
capture log close
capture graph close
log using logs/7-table_N1.log, replace

if "$access_to_datamyne" == "yes" {
use data/temp/colombia_imports, clear
drop if missing(CountryofOrigin) | missing(ProductHS) | missing(Provider)

bysort year CountryofOrigin: gen country_tag = _n == 1
bysort year CountryofOrigin Provider ProductHS: gen variety_tag = _n == 1

destring ExchangeRate, replace force
gen Tax_Payment = Valuetobepay/ExchangeRate

collapse (sum) country_tag variety_tag CIFValueUS FOBValueUS Tax_Payment, by(year)

save data/internally_generated/table_N1_estimates.dta, replace

erase data/temp/colombia_imports.dta
}

use data/internally_generated/table_N1_estimates.dta, clear

local i = 1
forval year = 2007/2013 {
scalar FOB_`year'= FOBValueUS[`i']/10e8
scalar CIFtoFOB_`year'= CIFValueUS[`i']/FOBValueUS[`i']
scalar COSTtoFOB_`year'= (CIFValueUS[`i']+Tax_Payment[`i'])/FOBValueUS[`i']
scalar N_Countries_`year' =  country_tag[`i']
scalar N_Varieties_`year' =  variety_tag[`i']
local i = `i' + 1
}

capture file close OuputTable
	file open  OuputTable using "output/Table_N1.tex", write replace
	file write 	OuputTable /// 
	    "\begin{adjustwidth}{0in}{0in}" _n ///																					 
		"\begin{tabular}{lcccccccc}" _n ///
		"\toprule" _n ///
		" &                 \multicolumn{7}{c}{Year}  \\"	_n ///
		"Statistic    & 2007  &    2008   & 2009    &   2010     &  2011 &     2012   &    2013  \\ " _n ///
		"\midrule" _n ///
        "\footnotesize{F.O.B. value} \scriptsize{(billion dollars)} &" %3.2f (FOB_2007) "&" %3.2f (FOB_2008) "&" %3.2f (FOB_2009) "&" %3.2f (FOB_2010) "&" %3.2f (FOB_2011) "&"          %3.2f (FOB_2012) "&" %3.2f (FOB_2013) "\\" _n ///
		"\addlinespace" _n ///
		"$\frac{\text{C.I.F. value}}{\text{F.O.B. value}}$  &" %3.2f (CIFtoFOB_2007) "&" %3.2f (CIFtoFOB_2008) "&" %3.2f (CIFtoFOB_2009) "&" %3.2f (CIFtoFOB_2010) "&"             %3.2f (CIFtoFOB_2011) "&" %3.2f (CIFtoFOB_2012) "&" %3.2f (CIFtoFOB_2013) "\\" _n ///
		"\addlinespace" _n ///
	    "$\frac{\text{C.I.F. + tax value}}{\text{F.O.B. value}}$   &" %3.2f (COSTtoFOB_2007) "&" %3.2f (COSTtoFOB_2008) "&" %3.2f (COSTtoFOB_2009) "&" %3.2f (COSTtoFOB_2010) "&"          %3.2f (COSTtoFOB_2011) "&"  %3.2f (COSTtoFOB_2012) "&" %3.2f (COSTtoFOB_2013) "\\" _n ///
		"\addlinespace" _n ///
		"\footnotesize{No. of exporting countries}  &" %9.0fc (N_Countries_2007) "&" %9.0fc (N_Countries_2008) "&" %9.0fc (N_Countries_2009) "&" %9.0fc (N_Countries_2010) "&"         %9.0fc (N_Countries_2011) "&"   %9.0fc (N_Countries_2012) "&" %9.0fc (N_Countries_2013) "\\" _n ///
		"\addlinespace" _n ///
		"\footnotesize{No. of imported varieties}    &" %9.0fc (N_Varieties_2007) "&" %9.0fc (N_Varieties_2008) "&" %9.0fc (N_Varieties_2009) "&" %9.0fc (N_Varieties_2010) "&"         %9.0fc (N_Varieties_2011) "&"   %9.0fc (N_Varieties_2012) "&" %9.0fc (N_Varieties_2013) "\\" _n ///
		"\bottomrule \end{tabular}" _n ///
        "\end{adjustwidth}"
		
file close OuputTable
log close
