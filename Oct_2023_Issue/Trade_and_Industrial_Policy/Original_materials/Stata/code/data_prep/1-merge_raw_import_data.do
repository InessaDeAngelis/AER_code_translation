clear

foreach x in 2007 2009 2010 2011 2012 2013 {
	
use "data/confidential_data/datamyne/ColombiaImports`x'_1.dta"
append using "data/confidential_data/datamyne/ColombiaImports`x'_2.dta", force
keep VATPercent TariffPercent ExchangeRate CustomsValueTariffBase CIFValueUS FOBValueUS Valuetobepay Quantity GrossWeight NetWeight ProductHS CountryofOrigin ProviderCountry Provider DeclarationDate 

			** fixing country names
			gen str3 prov=ProviderCountry
			replace ProviderCountry="ESPANIA" if prov=="ESP"
			drop prov
			
			drop if Provider=="" |ProviderCountry=="" 
			gen Provider1=upper(Provider)
			replace Provider1 = subinstr(Provider1,".","",.)
			replace Provider1 = subinstr(Provider1," ","",.)
			replace Provider1 = subinstr(Provider1,",","",.)
			replace Provider1 = subinstr(Provider1,"/","",.)
			replace Provider1 = subinstr(Provider1,"-","",.)
			replace Provider1 = subinstr(Provider1,";","",.)
			replace Provider1 = subinstr(Provider1,"&","",.)
			replace Provider1 = subinstr(Provider1,char(34),"",.)
			replace Provider1 = subinstr(Provider1,"(","",.)
			replace Provider1 = subinstr(Provider1,")","",.)
			replace Provider1 = subinstr(Provider1,"@","",.)
			replace Provider1 = subinstr(Provider1,"LLC","",.)
			replace Provider1 = subinstr(Provider1,"?","",.)
			replace Provider1 = subinstr(Provider1,"`","",.)
			replace Provider1 = subinstr(Provider1,"}","",.)
			gen str12 Provider2=Provider1
			drop Provider1 Provider
			rename Provider2 Provider
			
			sort Provider ProviderCountry
			merge m:1 Provider ProviderCountry using data/temp/firms_clean
			replace Provider=Provider2 if _m==3
			drop if _m==2
			drop _m Provider2
			compress
			
keep VATPercent TariffPercent ExchangeRate CustomsValueTariffBase CIFValueUS FOBValueUS Valuetobepay Quantity GrossWeight NetWeight ProductHS CountryofOrigin Provider DeclarationDate 
gen year=year(DeclarationDate)
gen month=month(DeclarationDate)
drop DeclarationDate
					
save data/temp/colombiaimports`x', replace
}

use "data/confidential_data/datamyne/ColombiaImports2008.dta"
keep VATPercent TariffPercent ExchangeRate CustomsValueTariffBase CIFValueUS FOBValueUS Valuetobepay Quantity GrossWeight NetWeight ProductHS CountryofOrigin ProviderCountry Provider DeclarationDate 
			** fixing country names
			gen str3 prov=ProviderCountry
			replace ProviderCountry="ESPANIA" if prov=="ESP"
			drop prov

			drop if Provider=="" |ProviderCountry=="" 
			gen Provider1=upper(Provider)
			replace Provider1 = subinstr(Provider1,".","",.)
			replace Provider1 = subinstr(Provider1," ","",.)
			replace Provider1 = subinstr(Provider1,",","",.)
			replace Provider1 = subinstr(Provider1,"/","",.)
			replace Provider1 = subinstr(Provider1,"-","",.)
			replace Provider1 = subinstr(Provider1,";","",.)
			replace Provider1 = subinstr(Provider1,"&","",.)
			replace Provider1 = subinstr(Provider1,char(34),"",.)
			replace Provider1 = subinstr(Provider1,"(","",.)
			replace Provider1 = subinstr(Provider1,")","",.)
			replace Provider1 = subinstr(Provider1,"@","",.)
			replace Provider1 = subinstr(Provider1,"LLC","",.)
			replace Provider1 = subinstr(Provider1,"?","",.)
			replace Provider1 = subinstr(Provider1,"`","",.)
			replace Provider1 = subinstr(Provider1,"}","",.)
			gen str12 Provider2=Provider1
			drop Provider1 Provider
			rename Provider2 Provider
			
			sort Provider ProviderCountry
			merge m:1 Provider ProviderCountry using data/temp/firms_clean
			replace Provider=Provider2 if _m==3
			drop if _m==2
			drop _m Provider2
			compress

keep VATPercent TariffPercent ExchangeRate CustomsValueTariffBase CIFValueUS FOBValueUS Valuetobepay Quantity GrossWeight NetWeight ProductHS CountryofOrigin Provider DeclarationDate  

gen year=year(DeclarationDate)
gen month=month(DeclarationDate)
drop DeclarationDate

save data/temp/colombiaimports2008, replace
*********************************************************************
**       combine data files from years 2007 to 2013          **
*********************************************************************

use data/temp/colombiaimports2007, replace
forvalues y=2008/2013 {
append using data/temp/colombiaimports`y', force
}

replace CountryofOrigin ="ESPANA" if substr(CountryofOrigin,1,4)=="ESPA"


*********************************************************************
**      create lables for variables and save raw data         **
*********************************************************************

label variable ProductHS "Colombian 8-digit Harmonized System Code"
label variable CountryofOrigin "Country of Origin Of the Imported Good"
label variable Quantity "Quantity: Unit Types are the same within an HS8 Product"
label variable CIFValueUS "CIF (Cost, Insurance, and Freight) Value of Imports in Current US Dollars"
label variable FOBValueUS "FOB (Free On Board) Value of Imports, expressed in Current US Dollars"
label variable NetWeight "Net Weight in Kilograms"
label variable GrossWeight "Gross Weight in Kilograms"
label variable ExchangeRate "Exchange Rate expressed in Colombian Pesos per 1 US Dollar"
  
label variable CustomsValueTariffBase "Customs Value Tariff Base Expressed in Colombian Pesos"
label variable TariffPercent "Import Tariff Rate Expressed in Ad-valorem Percentage Terms"
label variable VATPercent "Value Added Tax Rate Expressed in Ad-valorem Percentage Terms"
label variable Valuetobepay "Total Value of Taxes and Tariffs (including VAT) in Colombian Pesos"
label variable Provider "Name of the Exporting (to Colombia) Firm"
 
save data/temp/colombia_imports, replace

erase "data/temp/colombiaimports2007.dta"
erase "data/temp/colombiaimports2008.dta"
erase "data/temp/colombiaimports2009.dta"
erase "data/temp/colombiaimports2010.dta"
erase "data/temp/colombiaimports2011.dta"
erase "data/temp/colombiaimports2012.dta"
erase "data/temp/colombiaimports2013.dta"
erase "data/temp/firms_clean.dta"
