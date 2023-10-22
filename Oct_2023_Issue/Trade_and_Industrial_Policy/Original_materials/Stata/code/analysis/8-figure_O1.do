clear
capture log close
capture graph close
log using logs/8-figure_O1.log, replace

******************************************

if "$access_to_datamyne" == "yes" {
use "./data/temp/colombia_imports_updated_hs.dta", clear
keep if CountryofOrigin=="ESTADOS UNIDOS" & ProductHS=="8431490000"


destring ExchangeRate TariffPercent VATPercent, replace
collapse (mean) VATPercent TariffPercent ExchangeRate  [aweight = FOBValueUS], by(month year)

save data/internally_generated/figure_O1_a.dta, replace
}

use data/internally_generated/figure_O1_a.dta, clear
gen date=ym(year, month)
tsset date
gen Dexc = 100*(log(F12.ExchangeRate) - log(ExchangeRate))


generate str3 month_name = cond(month==1 , "JAN", ///
                    cond(month==2 ,  "FEB", ///
			        cond(month==3 ,  "MAR", ///
				    cond(month==4 ,  "APR", ///
				    cond(month==5 ,  "MAY", ///
					cond(month==6 ,  "JUN", ///
				    cond(month==7 ,  "JUL", ///
					cond(month==8 ,  "AUG", ///
					cond(month==9 ,  "SEP", ///
					cond(month==10 , "NOV", ///
					cond(month==11 , "OCT", ///
					cond(month==12 , "DEC", ///
										"." ))))))))))))
gen zero = 0
labmask month, values(month_name) 
twoway (line Dexc month if year==2008, xla(1/12, valuelabel ang(v) noticks) xtitle("") lcolor("193 5 52") lwidth(vthick) ) ///
       (line zero month if year==2008, xla(1/12, valuelabel ang(v) noticks) xtitle("") lcolor("251 162 127") lwidth(medium) lpattern(dash)), ///
	   ytitle("% {&Delta} Exchange Rate", size(large)) legend(off)
	   
graph export output/Figure_O1_a.pdf, replace

********************************************
if "$access_to_datamyne" == "yes" {
use "./data/temp/colombia_imports_updated_hs.dta", clear
keep if CountryofOrigin=="ESTADOS UNIDOS" & ProductHS=="8431490000"


destring ExchangeRate TariffPercent VATPercent, replace
collapse (sum) FOBValueUS (mean) VATPercent TariffPercent ExchangeRate, by(Provider month year)
gen date=ym(year,month)

sort year Provider date 
by year Provider: egen FOBValueUS_total = total(FOBValueUS)
replace FOBValueUS=FOBValueUS/FOBValueUS_total

keep if Provider=="CATERPILLARA"  | Provider=="MACHINERYCOR"

keep Provider month date FOBValueUS year
reshape wide FOBValueUS, j(Provider) i(date) string
save data/internally_generated/figure_O1_b.dta, replace
}

use data/internally_generated/figure_O1_b.dta, clear
generate str3 month_name = cond(month==1 , "JAN", ///
                    cond(month==2 ,  "FEB", ///
			        cond(month==3 ,  "MAR", ///
				    cond(month==4 ,  "APR", ///
				    cond(month==5 ,  "MAY", ///
					cond(month==6 ,  "JUN", ///
				    cond(month==7 ,  "JUL", ///
					cond(month==8 ,  "AUG", ///
					cond(month==9 ,  "SEP", ///
					cond(month==10 , "NOV", ///
					cond(month==11 , "OCT", ///
					cond(month==12 , "DEC", ///
										"." ))))))))))))

labmask month, values(month_name) 
twoway (lowess FOBValueUSCATERPILLARA month if year==2008, xla(1/12, valuelabel ang(v) noticks) xtitle("") lcolor("251 222 6") lwidth(vthick) bwidth(.4)) ///
       (lowess FOBValueUSMACHINERYCOR month if year==2008, xla(1/12, valuelabel ang(v) noticks) xtitle("") lcolor(midblue) lwidth(vthick)  bwidth(.4)), ///
	   legend(ring(1) pos(12) row(1) order(1 "CATERPILLAR" 2 "MACHINERY CORP AMERICA" )) ytitle("Export Share",  size(large))

graph export output/Figure_O1_b.pdf, replace	
*****************************************

*erase "./data/temp/colombia_imports_updated_hs.dta"
graph close
log close   





