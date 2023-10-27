**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code cleans INEI Peru raw data and include other characteristics
**********************************************************************

cls
clear all
capture clear matrix
set mem 200m
set more off

global database   = "$user/working_data"
global input      = "$user/input"
global output     = "$user/output"

global input_PER      = "$input/PER"


************************************ PANEL *********************************************
**** 2007-2011 ****

**** 2007 - 2010 ****

* eduaction, employment and individual characteristics

u $input_PER/panel_ingreso_1.dta, clear 

keep p203_* p207_* p209_* p208a_* a—o_* mes_* con_* cong viv_* vivi hog_* num* fac_* fac_panel* estrato_* dominio_* p301a_* p507_* p506_*

drop num_per

rename num7 num07
rename num8 num08
rename num9 num09

gen id = _n

reshape long p506_ p203_ p207_ p209_ p208a_ a—o_ mes_ con_ viv_ hog_  num fac_ fac_panel07 fac_panel08 fac_panel09 fac_panel10 estrato_ dominio_ p301a_ p507_, i(id) j(year, string)

keep if p203_ == 1

rename p208a_ age
rename p207_ sex
rename p209_ mstatus
rename p203_ poshog
rename p301a_ educ
rename p507_ job
rename p506_ sector

drop a—o_
rename cong conglome
rename vivi vivienda
rename hog_ hogar

gen year_n = "2007" if year == "07"
replace year_n = "2008" if year == "08"
replace year_n = "2009" if year == "09"
replace year_n = "2010" if year == "10"
replace year_n = "2011" if year == "11"

gen id_HH = year_n + conglome + vivienda + hogar

keep id_HH age sex mstatus poshog year educ job sector
drop if age == .

tempfile individual
save `individual', replace

* hogar

u $input_PER/panel_hogar_1.dta, clear 

rename dominio_07 domionio_07

keep mes_* con_* cong viv_* vivi hog_* num_hog num* fact_* fac_panel* estrato_* domionio_* p105a_*

drop num_hog
gen id = _n

rename num7 num07
rename num8 num08
rename num9 num09

reshape long mes_ con_ viv_ hog_ num fact_ fac_panel07 fac_panel08 fac_panel09 fac_panel10 estrato_ domionio_ p105a_, i(id) j(year, string)

rename domionio_ dominio_

rename fact_ fac_

drop if fac_ == .
rename cong conglome
rename vivi vivienda
rename hog_ hogar

rename p105a_ tenencia

gen year_n = "2007" if year == "07"
replace year_n = "2008" if year == "08"
replace year_n = "2009" if year == "09"
replace year_n = "2010" if year == "10"
replace year_n = "2011" if year == "11"

gen id_HH = year_n + conglome + vivienda + hogar

keep id_HH tenencia

drop if tenencia == .

tempfile hogar
save `hogar', replace

* sumaria gastos

u $input_PER/panel_sumaria_1.dta, clear 

drop if inghog2d_07 == . & inghog2d_08 == . & inghog2d_09 == . & inghog2d_10 == . & inghog2d_11 == .
drop if gashog2d_07 == . & gashog2d_08 == . & gashog2d_09 == . & gashog2d_10 == . & gashog2d_11 == .

keep gashog* inghog* ingmo* mes_* con_* cong viv_* vivi hog_* num_hog num* fac_* fac_panel* estrato_* mieperho_* dominio_* sg42_* ingrenhd_* ga03hd_* g01hd_* ig04hd_* ///
g05hd_* gru11hd_* gru21hd_* gru31hd_* gru41hd_* gru51hd_* gru61hd_* gru71hd_* gru81hd_*

drop num_hog
gen id = _n

rename num7 num07
rename num8 num08
rename num9 num09

reshape long g05hd_ gru81hd_ gru71hd_ gru61hd_ gru51hd_ gru41hd_ gru31hd_ gru21hd_ gru11hd_ gashog1d_ gashog2d_ inghog1d_ inghog2d_ ingmo1hd_ ingmo2hd_ mes_ con_ viv_ hog_ num fac_ fac_panel07 fac_panel08 fac_panel09 fac_panel10 estrato_ mieperho_ dominio_ sg42_ ingrenhd_ ga03hd_ g01hd_ ig04hd_, i(id) j(year, string)

rename ig04hd_ hhcred_expend
rename ga03hd_ rent_expend
rename g01hd_ hhexpan_expend
rename sg42_ hhequip_expend
rename ingrenhd_ rents_income

rename g05hd_ foodout
rename gru11hd_ food
rename gru21hd_ clothes
rename gru31hd_ housing
rename gru41hd_ muebles
rename gru51hd_ health
rename gru61hd_ transport
rename gru71hd_ entretainment
rename gru81hd_ other

drop if fac_ == .
rename cong conglome
rename vivi vivienda
rename hog_ hogar

gen year_n = "2007" if year == "07"
replace year_n = "2008" if year == "08"
replace year_n = "2009" if year == "09"
replace year_n = "2010" if year == "10"
replace year_n = "2011" if year == "11"

gen id_HH = year_n + conglome + vivienda + hogar

merge 1:1 id_HH using `individual'
drop if _merge == 1
drop _merge

merge 1:1 id_HH using `hogar'
keep if _merge == 3
drop _merge

tempfile clean_PER_1
save `clean_PER_1', replace
 
**** 2011-2015 ****

u $input_PER/panel_ingreso_2.dta, clear 

rename fac500a7_11 fac500a_11

keep p506_* p203_* p207_* p209_* p208a_* a—o_* mes_* conglome_* conglome vivienda_* vivienda hogar_* num* fac500a* estrato_* dominio_* p301a_* p507_*

drop num

gen id = _n

reshape long p506_ p203_ p207_ p209_ p208a_ a—o_ mes_ conglome_ vivienda_ hogar_  num fac500a_ estrato_ dominio_ p301a_ p507_, i(id) j(year, string)

rename fac500a_ factor07_

keep if p203_ == 1

rename p208a_ age
rename p207_ sex
rename p209_ mstatus
rename p203_ poshog
rename p301a_ educ
rename p507_ job
rename p506_ sector

drop a—o_
rename hogar_ hogar

gen year_n = "2011" if year == "11"
replace year_n = "2012" if year == "12"
replace year_n = "2013" if year == "13"
replace year_n = "2014" if year == "14"
replace year_n = "2015" if year == "15"

gen id_HH = year_n + conglome + vivienda + hogar

keep id_HH age sex mstatus poshog year educ job sector
drop if age == .

gen count = 1
egen s_count= sum(count) , by(id_HH)
drop if s_count == 2
drop count s_count

tempfile individual
save `individual', replace

* hogar

u $input_PER/panel_hogar_2.dta, clear 

rename factor_15 factor07_15

keep mes_* conglome_* conglome vivienda_* vivienda hogar_* num* factor07_* estrato_* dominio_* p105a_*
drop num_hog
gen id = _n + 86978

reshape long mes_ conglome_ vivienda_ hogar_ factor07_ estrato_ dominio_ p105a_, i(id) j(year, string)

drop if vivienda_ == ""
rename hogar_ hogar

rename p105a_ tenencia

gen year_n = "2011" if year == "11"
replace year_n = "2012" if year == "12"
replace year_n = "2013" if year == "13"
replace year_n = "2014" if year == "14"
replace year_n = "2015" if year == "15"

gen id_HH = year_n + conglome + vivienda + hogar

keep id_HH tenencia

drop if tenencia == .

tempfile hogar
save `hogar', replace

* sumaria gastos

u $input_PER/panel_sumaria_2.dta, clear 

rename factor07 factor07_15

drop if inghog2d_11 == . & inghog2d_12 == . & inghog2d_13 == . & inghog2d_14 == . & inghog2d_15 == .
drop if gashog2d_11 == . & gashog2d_12 == . & gashog2d_13 == . & gashog2d_14 == . & gashog2d_15 == .

keep gashog* inghog* ingmo* mes_* conglome_* conglome vivienda_* vivienda hogar_* num* factor07_* estrato_* mieperho_* dominio_* sg42_* ingrenhd_* ga03hd_* g01hd_* ig04hd_* ///
g05hd_* gru81hd_* gru71hd_* gru61hd_* gru51hd_* gru41hd_* gru31hd_* gru21hd_* gru11hd_* 
drop num_hog
gen id = _n + 86978

reshape long g05hd_ gru81hd_ gru71hd_ gru61hd_ gru51hd_ gru41hd_ gru31hd_ gru21hd_ gru11hd_ gashog1d_ gashog2d_ inghog1d_ inghog2d_ ingmo1hd_ ingmo2hd_ mes_ conglome_ vivienda_ hogar_ factor07_ estrato_ mieperho_ dominio_ sg42_ ingrenhd_ ga03hd_ g01hd_ ig04hd_, i(id) j(year, string)

rename ig04hd_ hhcred_expend
rename ga03hd_ rent_expend
rename g01hd_ hhexpan_expend
rename sg42_ hhequip_expend
rename ingrenhd_ rents_income

rename g05hd_ foodout
rename gru11hd_ food
rename gru21hd_ clothes
rename gru31hd_ housing
rename gru41hd_ muebles
rename gru51hd_ health
rename gru61hd_ transport
rename gru71hd_ entretainment
rename gru81hd_ other

drop if factor07_ == .
rename hogar_ hogar

gen year_n = "2011" if year == "11"
replace year_n = "2012" if year == "12"
replace year_n = "2013" if year == "13"
replace year_n = "2014" if year == "14"
replace year_n = "2015" if year == "15"

gen id_HH = year_n + conglome + vivienda + hogar

merge 1:1 id_HH using `individual'
keep if _merge == 3
drop _merge

merge 1:1 id_HH using `hogar'
keep if _merge == 3
drop _merge

* merge with pre 2011 years

gen conglome_aux = substr(conglome,3, .) if year_n == "2011"
gen id_HH_aux = year_n + conglome_aux + vivienda + hogar if year_n == "2011"

rename id_HH id_HH_new
rename id_HH_aux id_HH

rename id id_new

merge m:1 id_HH using `clean_PER_1'
drop _merge

sort id year
gen idd = id
gen diff = id - id_new
replace idd = id_new if diff!=.
by id: replace idd = idd[_n+1] if idd[_n+1]!=.
replace idd = id_new if idd == .
sort idd year
rename idd id_merge

tempfile clean_PER_2
save `clean_PER_2', replace

**** 2014-2018 ****
************
* individual

u $input_PER/panel_ingreso_3.dta, clear 

keep p506_* p203_* p207_* p209_* p208a_* a—o_* mes_* conglome_* conglome vivienda_* vivienda hogar_* numpanh* numper fac500a_* estrato_* dominio_* p301a_* p507_*

drop numper

gen id = 198733 + 1 + _n 

reshape long p203_ p506_ p207_ p209_ p208a_ a—o_ mes_ conglome_ vivienda_ hogar_  numpanh fac500a_ estrato_ dominio_ p301a_ p507_, i(id) j(year, string)

rename fac500a_ factor07_

keep if p203_ == 1

rename p208a_ age
rename p207_ sex
rename p209_ mstatus
rename p203_ poshog
rename p301a_ educ
rename p507_ job
rename p506_ sector

drop a—o_
rename hogar_ hogar

gen year_n = "2014" if year == "14"
replace year_n = "2015" if year == "15"
replace year_n = "2016" if year == "16"
replace year_n = "2017" if year == "17"
replace year_n = "2018" if year == "18"

gen id_HH = year_n + conglome + vivienda + hogar

keep id_HH age sex mstatus poshog year educ job sector
drop if age == .

gen count = 1
egen s_count= sum(count) , by(id_HH)
drop if s_count == 2
drop count s_count

tempfile individual
save `individual', replace

* hogar

u $input_PER/panel_hogar_3.dta, clear 

keep mes_* conglome_* conglome vivienda_* vivienda hogar_* numpanh factor07_* estrato_* dominio_* p105a_*
drop numpanh
gen id = 198733 + 1 + _n 

reshape long mes_ conglome_ vivienda_ hogar_ factor07_ estrato_ dominio_ p105a_, i(id) j(year, string)

drop if factor07_ == .
rename hogar_ hogar

gen year_n = "2014" if year == "14"
replace year_n = "2015" if year == "15"
replace year_n = "2016" if year == "16"
replace year_n = "2017" if year == "17"
replace year_n = "2018" if year == "18"

rename p105a_ tenencia

gen id_HH = year_n + conglome + vivienda + hogar

keep id_HH tenencia

drop if tenencia == .

tempfile hogar
save `hogar', replace

* sumaria

u $input_PER/panel_sumaria_3.dta, clear 

drop if inghog2d_14 == . & inghog2d_15 == . & inghog2d_16 == . & inghog2d_17 == . & inghog2d_18 == .
drop if gashog2d_14 == . & gashog2d_15 == . & gashog2d_16 == . & gashog2d_17 == . & gashog2d_18 == .

keep gashog* inghog* ingmo* mes_* conglome_* conglome vivienda_* vivienda hogar_* numpanh factor07_* estrato_* mieperho_* dominio_* sg42_* ingrenhd_* ga03hd_*  ///
g05hd_* gru81hd_* gru71hd_* gru61hd_* gru51hd_* gru41hd_* gru31hd_* gru21hd_* gru11hd_* 
drop numpanh
gen id = 198733 + 1 + _n 

reshape long g05hd_ gru81hd_ gru71hd_ gru61hd_ gru51hd_ gru41hd_ gru31hd_ gru21hd_ gru11hd_ gashog1d_ gashog2d_ inghog1d_ inghog2d_ ingmo1hd_ ingmo2hd_ mes_ conglome_ vivienda_ hogar_ factor07_ estrato_ mieperho_ dominio_ sg42_ ingrenhd_ ga03hd_, i(id) j(year, string)

rename ga03hd_ rent_expend
rename sg42_ hhequip_expend
rename ingrenhd_ rents_income

rename g05hd_ foodout
rename gru11hd_ food
rename gru21hd_ clothes
rename gru31hd_ housing
rename gru41hd_ muebles
rename gru51hd_ health
rename gru61hd_ transport
rename gru71hd_ entretainment
rename gru81hd_ other

drop if factor07_ == .
rename hogar_ hogar

gen year_n = "2014" if year == "14"
replace year_n = "2015" if year == "15"
replace year_n = "2016" if year == "16"
replace year_n = "2017" if year == "17"
replace year_n = "2018" if year == "18"

gen id_HH = year_n + conglome + vivienda + hogar

merge 1:1 id_HH using `individual'
keep if _merge == 3
drop _merge

merge 1:1 id_HH using `hogar'
keep if _merge == 3
drop _merge

rename id id_14_18
rename id_HH id_HH_new

merge 1:m id_HH_new using `clean_PER_2'

rename id_merge idd
sort idd year
gen iddd = idd
replace diff = idd - id_14_18

replace iddd = id_14_18 if diff!=.
by idd: replace iddd = iddd[_n+1] if iddd[_n+1]!=.
replace iddd = id_14_18 if iddd == .
sort iddd year
rename iddd id_merge

drop *_18 *_17
drop fac_panel*

tempfile clean_PER_3
save `clean_PER_3', replace

************************************ 2004-2018 (CROSS + PANEL) *********************************************


***** 2004 *****


* individual

use "$input_PER/enaho01-2004-200.dta", clear

rename p208a age
rename p207 sex
rename p209 mstatus
rename p203 poshog

rename a_o year 
rename conglome conglome_aux
rename vivienda vivienda_aux
rename codperso codperso_aux
gen conglome = subinstr(conglome_aux," ","0",3)
gen vivienda = subinstr(vivienda_aux," ","0",3)
gen codperso = subinstr(codperso_aux," ","0",3)

gen id_HH = year + conglome + vivienda + hogar

keep if codperso == "01"

keep id_HH age sex mstatus poshog

tempfile data1 
save `data1', replace

* education

use "$input_PER/enaho01a-2004-300.dta", clear

rename p301a educ

rename a—o year 
rename conglome conglome_aux
rename vivienda vivienda_aux
rename codperso codperso_aux
gen conglome = subinstr(conglome_aux," ","0",3)
gen vivienda = subinstr(vivienda_aux," ","0",3)
gen codperso = subinstr(codperso_aux," ","0",3)

gen id_HH = year + conglome + vivienda + hogar

keep if codperso == "01"

keep id_HH educ 

tempfile data2 
save `data2', replace

* employment

use "$input_PER/enaho01a-2004-500.dta", clear

rename p507 job
rename p506 sector

rename a_o year 
rename conglome conglome_aux
rename vivienda vivienda_aux
rename codperso codperso_aux
gen conglome = subinstr(conglome_aux," ","0",3)
gen vivienda = subinstr(vivienda_aux," ","0",3)
gen codperso = subinstr(codperso_aux," ","0",3)

gen id_HH = year + conglome + vivienda + hogar

keep if codperso == "01"

keep id_HH job sector

tempfile data3 
save `data3', replace

* house

use "$input_PER/enaho01-2004-100.dta", clear

rename p105a tenencia

rename a—o year 

gen id_HH = year + conglome + vivienda + hogar

keep id_HH tenencia

drop if tenencia == .

tempfile data4
save `data4', replace

* sumaria gastos

use "$input_PER/sumaria-2004.dta", clear

rename a—o year 

gen id_HH = year + conglome + vivienda + hogar

merge 1:1 id_HH using `data1'
drop _merge
merge 1:1 id_HH using `data2'
drop _merge
merge 1:1 id_HH using `data3'
drop _merge
merge 1:1 id_HH using `data4'
drop _merge


tempfile data2004
save `data2004', replace


******* 2005 *******


* individual

use "$input_PER/enaho01-2005-200.dta", clear

rename p208a age
rename p207 sex
rename p209 mstatus
rename p203 poshog

rename a—o year
rename conglome conglome_aux
rename vivienda vivienda_aux
rename codperso codperso_aux
gen conglome = subinstr(conglome_aux," ","0",3)
gen vivienda = subinstr(vivienda_aux," ","0",3)
gen codperso = subinstr(codperso_aux," ","0",3)

gen id_HH = year + conglome + vivienda + hogar

keep if codperso == "01"

keep id_HH age sex mstatus poshog

tempfile data1 
save `data1', replace

* education

use "$input_PER/enaho01a-2005-300.dta", clear

rename p301a educ

rename a—o year 
rename conglome conglome_aux
rename vivienda vivienda_aux
rename codperso codperso_aux
gen conglome = subinstr(conglome_aux," ","0",3)
gen vivienda = subinstr(vivienda_aux," ","0",3)
gen codperso = subinstr(codperso_aux," ","0",3)

gen id_HH = year + conglome + vivienda + hogar

keep if codperso == "01"

keep id_HH educ

tempfile data2 
save `data2', replace

* employment

use "$input_PER/enaho01a-2005-500.dta", clear

rename p507 job
rename p506 sector

rename a—o year 
rename conglome conglome_aux
rename vivienda vivienda_aux
rename codperso codperso_aux
gen conglome = subinstr(conglome_aux," ","0",3)
gen vivienda = subinstr(vivienda_aux," ","0",3)
gen codperso = subinstr(codperso_aux," ","0",3)

gen id_HH = year + conglome + vivienda + hogar

keep if codperso == "01"

keep id_HH job sector

tempfile data3 
save `data3', replace

* employment

use "$input_PER/enaho01-2005-100.dta", clear

rename p105a tenencia

rename a—o year 

gen id_HH = year + conglome + vivienda + hogar

keep id_HH tenencia

drop if tenencia == .

tempfile data4
save `data4', replace

* sumaria gastos

use "$input_PER/sumaria-2005.dta", clear

rename a—o year 

gen id_HH = year + conglome + vivienda + hogar

merge 1:1 id_HH using `data1'
drop _merge
merge 1:1 id_HH using `data2'
drop _merge
merge 1:1 id_HH using `data3'
drop _merge
merge 1:1 id_HH using `data4'
drop _merge

tempfile data2005
save `data2005', replace


***** 2006 *****


* individual

use "$input_PER/enaho01-2006-200.dta", clear

rename p208a age
rename p207 sex
rename p209 mstatus
rename p203 poshog

rename a_o year 
rename conglome conglome_aux
rename vivienda vivienda_aux
rename codperso codperso_aux
gen conglome = subinstr(conglome_aux," ","0",3)
gen vivienda = subinstr(vivienda_aux," ","0",3)
gen codperso = subinstr(codperso_aux," ","0",3)

gen id_HH = year + conglome + vivienda + hogar

keep if codperso == "01"

keep id_HH age sex mstatus poshog

tempfile data1 
save `data1', replace

* education

use "$input_PER/enaho01a-2006-300.dta", clear

rename p301a educ

rename a—o year 
rename conglome conglome_aux
rename vivienda vivienda_aux
rename codperso codperso_aux
gen conglome = subinstr(conglome_aux," ","0",3)
gen vivienda = subinstr(vivienda_aux," ","0",3)
gen codperso = subinstr(codperso_aux," ","0",3)

gen id_HH = year + conglome + vivienda + hogar

keep if codperso == "01"

keep id_HH educ

tempfile data2 
save `data2', replace

* employment

use "$input_PER/enaho01a-2006-500.dta", clear

rename p507 job
rename p506 sector

rename a—o year 
rename conglome conglome_aux
rename vivienda vivienda_aux
rename codperso codperso_aux
gen conglome = subinstr(conglome_aux," ","0",3)
gen vivienda = subinstr(vivienda_aux," ","0",3)
gen codperso = subinstr(codperso_aux," ","0",3)

gen id_HH = year + conglome + vivienda + hogar

keep if codperso == "01"

keep id_HH job sector

tempfile data3 
save `data3', replace

* house

use "$input_PER/enaho01-2006-100.dta", clear

rename p105a tenencia

rename a—o year 

gen id_HH = year + conglome + vivienda + hogar

keep id_HH tenencia

drop if tenencia == .

tempfile data4
save `data4', replace

* sumaria gastos

use "$input_PER/sumaria-2006.dta", clear

rename a—o year 

gen id_HH = year + conglome + vivienda + hogar

merge 1:1 id_HH using `data1'
drop _merge
merge 1:1 id_HH using `data2'
drop _merge
merge 1:1 id_HH using `data3'
drop _merge
merge 1:1 id_HH using `data4'
drop _merge

append using `data2004' 
append using `data2005'

*** append with panel data

rename g05hd foodout
rename gru11hd food
rename gru21hd clothes
rename gru31hd housing
rename gru41hd muebles
rename gru51hd health
rename gru61hd transport
rename gru71hd entretainment
rename gru81hd other

rename ig04hd hhcred_expend
rename ga03hd rent_expend
rename g01hd hhexpan_expend
rename sg42 hhequip_expend
rename ingrenhd rents_income

rename gashog1d gashog1d_ 
rename gashog2d gashog2d_ 
rename inghog1d inghog1d_
rename inghog2d inghog2d_ 
rename ingmo1hd ingmo1hd_ 
rename ingmo2hd ingmo2hd_ 
rename mes mes_ 
rename conglome conglome_ 
rename vivienda vivienda_
rename factor07 factor07_
rename estrato estrato_
rename mieperho mieperho_
rename dominio dominio_

gen year_n = "2004"
replace year_n = "2005" if year == "2005"
replace year_n = "2006" if year == "2006"

append using `clean_PER_3'

keep foodout food clothes housing muebles transport health other entretainment age sex mstatus hhcred_expend rent_expend hhexpan_expend hhequip_expend rents_income gashog1d_ gashog2d_ inghog1d_ inghog2d_ ingmo1hd_ ingmo2hd_ mes_ conglome_ vivienda_ factor07_ estrato_ mieperho_ dominio_ hogar year_n educ fac_ con_ viv_ tenencia job sector

replace factor07_ = fac_ if factor07_ == .
replace conglome_ = con_ if conglome_ == ""
replace vivienda_ = viv_ if vivienda_ == ""

drop viv_ con_

****** sample filtering

rename mes_ month
gen year_month = year_n + "_" + month

merge m:1 year_month using "$input/PER/CPI.dta"
drop if _merge==2
drop _merge

destring year_n, replace

* All

gen count = 1
egen sample_1 = sum(count)

* Urban area

drop if estrato_ == .
gen urban = (estrato_ <7)
keep if urban == 1

egen sample_2 = sum(count)
gen dif_2 = sample_1 - sample_2

* Age

gen age_sel = (25 <= age & age <= 60)
keep if age_sel == 1

egen sample_3 = sum(count)
gen dif_3 = sample_2 - sample_3

* Outliers

drop if gashog1d_<= 0 
drop if gashog2d_<= 0 
drop if ingmo2hd_<= 0 
drop if inghog2d_<= 0 

gen gas_ing_tot=gashog1d_/ingmo2hd_
gen factor07_r = round(factor07)


_pctile gas_ing_tot [fweight=factor07_r], p(.5 99.5)
local l=r(r1)
local u=r(r2)

drop if gas_ing_tot<`l'
drop if gas_ing_tot>`u'

drop gas_ing_tot

egen sample_4 = sum(count)
gen dif_4 = sample_3 - sample_4

***** residualize for sample with more characteristics

destring year_n, replace

* income and consumption definition

gen tax = ingmo2hd_/ingmo1hd_
gen inc = (ingmo2hd_- rents_income*tax)/CPI_index
gen consu = (gashog1d_ - rent_expend - hhequip_expend)/CPI_index

gen ly = ln(inc)
gen lc = ln(consu)

*residual income and consumption

gen educ2 = .
replace educ2 = 1 if educ<=4
replace educ2 = 2 if educ>4 & educ<=6
replace educ2 = 3 if educ>6

qui tab(educ2), gen(educ2b)
qui tab(sex), gen(sexb)
qui tab(mstatus), gen(mstatusb)
qui tab(mieperho_), gen(mieperhob)
qui tab(dominio), gen(dominiob)
qui tab(estrato_), gen(estratob)
gen size_large = (estrato_<=2)
gen age2 = age^2

gen yeducb1 = educ2b1*year_n
gen yeducb2 = educ2b2*year_n
gen yeducb3 = educ2b3*year_n

gen ysexb1 = sexb1*year_n
gen ysexb2 = sexb2*year_n

gen year_t = year_n
replace year_t = 0 if year_n>2007

reg ly age age2 sexb* educ2b* mieperhob* size_large ysexb* yeducb* year_t year_n [aw=factor07_]
predict uy if e(sample),res

reg lc age age2 sexb* educ2b* mieperhob* size_large ysexb* yeducb* year_t year_n [aw=factor07_]
predict uc if e(sample),res

* non-residualized 

replace ly = ln(inc) - ln(mieperho_)
replace lc = ln(consu) - ln(mieperho_)

if "`xx'" == "not_resid" {

drop uy uc

reg ly year_t year_n [aw=factor07_]
predict uy if e(sample),res

reg lc year_t year_n [aw=factor07_]
predict uc if e(sample),res

}

replace uy = exp(uy)
replace uc = exp(uc)

gen freqwt = factor07_r 
egen sum_freqwt = total(freqwt), by(year)
gen probwt = freqwt/sum_freqwt

drop year 
rename year_n year

save "$database/PER/PER_Cdata_charact.dta", replace
