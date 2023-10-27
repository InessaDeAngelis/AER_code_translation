**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code cleans INEI Peru raw data
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


**** 2007 - 2011 ****

u $input_PER/panel_individual_1.dta, clear 

keep p203_* p207_* p209_* p208a_* a—o_* mes_* con_* cong viv_* vivi hog_* num* fac_* fac_panel* estrato_* dominio_* p301a_*

drop num_per
*gen jefe = 0
*replace jefe = 1 if p203_07 == 1 & a—o_07 == "2007"
*replace jefe = 1 if p203_08 == 1 & a—o_08 == "2008"
*replace jefe = 1 if p203_09 == 1 & a—o_09 == "2009"
*replace jefe = 1 if p203_10 == 1 & a—o_10 == "2010"
*replace jefe = 1 if p203_11 == 1 & a—o_11 == "2011"

rename num7 num07
rename num8 num08
rename num9 num09

gen id = _n

reshape long p203_ p207_ p209_ p208a_ a—o_ mes_ con_ viv_ hog_  num fac_ fac_panel07 fac_panel08 fac_panel09 fac_panel10 estrato_ dominio_ p301a_, i(id) j(year, string)

keep if p203_ == 1

rename p208a_ age
rename p207_ sex
rename p209_ mstatus
rename p203_ poshog
rename p301a_ educ

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

keep id_HH age sex mstatus poshog year educ
drop if age == .

tempfile individual
save `individual', replace

u $input_PER/panel_sumaria_1.dta, clear

drop if inghog2d_07 == . & inghog2d_08 == . & inghog2d_09 == . & inghog2d_10 == . & inghog2d_11 == .
drop if gashog2d_07 == . & gashog2d_08 == . & gashog2d_09 == . & gashog2d_10 == . & gashog2d_11 == .

keep gashog* inghog* ingmo* mes_* con_* cong viv_* vivi hog_* num_hog num* fac_* fac_panel* estrato_* mieperho_* dominio_* sg42_* ingrenhd_* ga03hd_* g01hd_* ig04hd_*
drop num_hog
gen id = _n

rename num7 num07
rename num8 num08
rename num9 num09

reshape long gashog1d_ gashog2d_ inghog1d_ inghog2d_ ingmo1hd_ ingmo2hd_ mes_ con_ viv_ hog_ num fac_ fac_panel07 fac_panel08 fac_panel09 fac_panel10 estrato_ mieperho_ dominio_ sg42_ ingrenhd_ ga03hd_ g01hd_ ig04hd_, i(id) j(year, string)

rename ig04hd_ hhcred_expend
rename ga03hd_ rent_expend
rename g01hd_ hhexpan_expend
rename sg42_ hhequip_expend
rename ingrenhd_ rents_income

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

tempfile clean_PER_1
save `clean_PER_1', replace


**** 2011-2015 ****
 
u $input_PER/panel_individual_2.dta, clear 

rename facpob07_12 factor07_12

keep p203_* p207_* p209_* p208a_* a—o_* mes_* conglome_* conglome vivienda_* vivienda hogar_* num* factor07_* estrato_* dominio_* p301a_*

drop num

gen id = _n

reshape long p203_ p207_ p209_ p208a_ a—o_ mes_ conglome_ vivienda_ hogar_  num factor07_ estrato_ dominio_ p301a_, i(id) j(year, string)

keep if p203_ == 1

rename p208a_ age
rename p207_ sex
rename p209_ mstatus
rename p203_ poshog
rename p301a_ educ

drop a—o_
rename hogar_ hogar

gen year_n = "2011" if year == "11"
replace year_n = "2012" if year == "12"
replace year_n = "2013" if year == "13"
replace year_n = "2014" if year == "14"
replace year_n = "2015" if year == "15"

gen id_HH = year_n + conglome + vivienda + hogar

keep id_HH age sex mstatus poshog year educ
drop if age == .

gen count = 1
egen s_count= sum(count) , by(id_HH)
drop if s_count == 2
drop count s_count

tempfile individual
save `individual', replace

u $input_PER/panel_sumaria_2.dta, clear

rename factor07 factor07_15

drop if inghog2d_11 == . & inghog2d_12 == . & inghog2d_13 == . & inghog2d_14 == . & inghog2d_15 == .
drop if gashog2d_11 == . & gashog2d_12 == . & gashog2d_13 == . & gashog2d_14 == . & gashog2d_15 == .

keep gashog* inghog* ingmo* mes_* conglome_* conglome vivienda_* vivienda hogar_* num* factor07_* estrato_* mieperho_* dominio_* sg42_* ingrenhd_* ga03hd_* g01hd_* ig04hd_*
drop num_hog
gen id = _n + 86978

reshape long gashog1d_ gashog2d_ inghog1d_ inghog2d_ ingmo1hd_ ingmo2hd_ mes_ conglome_ vivienda_ hogar_ factor07_ estrato_ mieperho_ dominio_ sg42_ ingrenhd_ ga03hd_ g01hd_ ig04hd_, i(id) j(year, string)

rename ig04hd_ hhcred_expend
rename ga03hd_ rent_expend
rename g01hd_ hhexpan_expend
rename sg42_ hhequip_expend
rename ingrenhd_ rents_income

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

u $input_PER/panel_individual_3.dta, clear 

keep p203_* p207_* p209_* p208a_* a—o_* mes_* conglome_* conglome vivienda_* vivienda hogar_* numpanh* numper factor07_* estrato_* dominio_* p301a_*

drop numper

gen id = 198733 + 1 + _n 

reshape long p203_ p207_ p209_ p208a_ a—o_ mes_ conglome_ vivienda_ hogar_  numpanh factor07_ estrato_ dominio_ p301a_, i(id) j(year, string)

keep if p203_ == 1

rename p208a_ age
rename p207_ sex
rename p209_ mstatus
rename p203_ poshog
rename p301a_ educ

drop a—o_
rename hogar_ hogar

gen year_n = "2014" if year == "14"
replace year_n = "2015" if year == "15"
replace year_n = "2016" if year == "16"
replace year_n = "2017" if year == "17"
replace year_n = "2018" if year == "18"

gen id_HH = year_n + conglome + vivienda + hogar

keep id_HH age sex mstatus poshog year educ
drop if age == .

gen count = 1
egen s_count= sum(count) , by(id_HH)
drop if s_count == 2
drop count s_count

tempfile indivual
save  `indivual', replace

u $input_PER/panel_sumaria_3.dta, clear 

drop if inghog2d_14 == . & inghog2d_15 == . & inghog2d_16 == . & inghog2d_17 == . & inghog2d_18 == .
drop if gashog2d_14 == . & gashog2d_15 == . & gashog2d_16 == . & gashog2d_17 == . & gashog2d_18 == .

keep gashog* inghog* ingmo* mes_* conglome_* conglome vivienda_* vivienda hogar_* numpanh factor07_* estrato_* mieperho_* dominio_* sg42_* ingrenhd_* ga03hd_*
drop numpanh
gen id = 198733 + 1 + _n 

reshape long gashog1d_ gashog2d_ inghog1d_ inghog2d_ ingmo1hd_ ingmo2hd_ mes_ conglome_ vivienda_ hogar_ factor07_ estrato_ mieperho_ dominio_ sg42_ ingrenhd_ ga03hd_, i(id) j(year, string)

*rename ig04hd_ hhcred_expend
rename ga03hd_ rent_expend
*rename g01hd_ hhexpan_expend
rename sg42_ hhequip_expend
rename ingrenhd_ rents_income

drop if factor07_ == .
rename hogar_ hogar

gen year_n = "2014" if year == "14"
replace year_n = "2015" if year == "15"
replace year_n = "2016" if year == "16"
replace year_n = "2017" if year == "17"
replace year_n = "2018" if year == "18"

gen id_HH = year_n + conglome + vivienda + hogar

merge 1:1 id_HH using `indivual'
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

tempfile clean_PER_panel
save `clean_PER_panel', replace

**** 2004-2006 ****

local year = "2004 2005 2006"

foreach y of local year {

use "$input_PER/enaho01-`y'-200.dta", clear

rename p208a age
rename p207 sex
rename p209 mstatus
rename p203 poshog

if `y' != 2006 & `y' != 2004 {
rename a—o year 
}

if `y' == 2006 | `y' == 2004 {
rename a_o year 
rename conglome conglome_aux
rename vivienda vivienda_aux
rename codperso codperso_aux
gen conglome = subinstr(conglome_aux," ","0",3)
gen vivienda = subinstr(vivienda_aux," ","0",3)
gen codperso = subinstr(codperso_aux," ","0",3)
}

if `y' == 2005  {
rename conglome conglome_aux
rename vivienda vivienda_aux
rename codperso codperso_aux
gen conglome = subinstr(conglome_aux," ","0",3)
gen vivienda = subinstr(vivienda_aux," ","0",3)
gen codperso = subinstr(codperso_aux," ","0",3)
}


gen id_HH = year + conglome + vivienda + hogar

keep if codperso == "01"

keep id_HH age sex mstatus poshog

tempfile data1 
save `data1', replace

use "$input_PER/enaho01a-`y'-300.dta", clear

rename p301a educ

if `y' != 2006 & `y' != 2004 {
rename a—o year 
}

if `y' == 2006 | `y' == 2004 {
rename a—o year 
rename conglome conglome_aux
rename vivienda vivienda_aux
rename codperso codperso_aux
gen conglome = subinstr(conglome_aux," ","0",3)
gen vivienda = subinstr(vivienda_aux," ","0",3)
gen codperso = subinstr(codperso_aux," ","0",3)
}

if `y' == 2005  {
rename conglome conglome_aux
rename vivienda vivienda_aux
rename codperso codperso_aux
gen conglome = subinstr(conglome_aux," ","0",3)
gen vivienda = subinstr(vivienda_aux," ","0",3)
gen codperso = subinstr(codperso_aux," ","0",3)
}


gen id_HH = year + conglome + vivienda + hogar

keep if codperso == "01"

keep id_HH educ

tempfile data2 
save `data2', replace

use "$input_PER/sumaria-`y'.dta", clear

if `y'!=2013  {
rename a—o year 
}

if `y'==2013 {
rename aÒo year
}

gen id_HH = year + conglome + vivienda + hogar

merge 1:1 id_HH using `data1'
drop _merge
merge 1:1 id_HH using `data2'
drop _merge

tempfile dat_`y'
save `dat_`y'', replace

}


local year = "2004 2005"

foreach y of local year {

append using `dat_`y''

}

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

append using `clean_PER_panel'

keep age sex mstatus hhcred_expend rent_expend hhexpan_expend hhequip_expend rents_income gashog1d_ gashog2d_ inghog1d_ inghog2d_ ingmo1hd_ ingmo2hd_ mes_ conglome_ vivienda_ factor07_ estrato_ mieperho_ dominio_ hogar year_n educ fac_ con_ viv_

replace factor07_ = fac_ if factor07_ == .
replace conglome_ = con_ if conglome_ == ""
replace vivienda_ = viv_ if vivienda_ == ""

drop viv_ con_

save "$database/PER/PER_Cdata.dta", replace
