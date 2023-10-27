**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Cleans raw data from Spain EPF and creates consumption baskets
**********************************************************************

cls
clear all
set mem 200m
set more off

global database = "$user/working_data"
global input = "$user/input"


local year = "2006 2007 2008 2009 2010 2011 2012 2013 2014 2015"

foreach y of local year {

use "$input/SPA/gastos`y'", clear

gen categ1 = substr(codigo,1,2)
gen categ2 = substr(codigo,3,1)
gen categ3 = substr(codigo,4,1)
gen categ4 = substr(codigo,5,1)

destring categ2, replace
destring categ3, replace
destring categ4, replace

* Food
gen food_nd = (categ1 == "01")

* Drinks, Tabacco and Drugs
gen dtd_nd = (categ1 == "02")

* Clothes
gen clothes_sd = (categ1 == "03" & categ2 == 1 & categ3 >= 1 & categ3 <= 3)
replace clothes_sd = 1 if (categ1 == "03" & categ2 == 2 & categ3 == 1)

gen clothes_nc = (categ1 == "03" & categ2 == 3)

gen clothes_serv = (categ1 == "03" & categ2 == 1 & categ3 == 4)
replace clothes_serv = 1 if (categ1 == "03" & categ2 == 2 & categ3 == 2)

* Housing
gen rent_d = (categ1 == "04" & categ2 == 1)
replace rent_d = 1 if (categ1 == "04" & categ2 == 2)

gen house_mant_d = (categ1 == "04" & categ2 == 3 & categ3 == 1)
replace house_mant_d = 1 if (categ1 == "04" & categ2 == 3 & categ3 == 3)

gen house_mant_serv = (categ1 == "04" & categ2 == 3 & categ3 == 2)
replace house_mant_serv = 1 if (categ1 == "04" & categ2 == 3 & categ3 == 4)

gen housing_serv = (categ1 == "04" & categ2 == 4)

gen housepw_serv = (categ1 == "04" & categ2 == 5)

gen house_other = (categ1 == "04" & categ2 == 6)

* Muebles
gen muebles_d = (categ1 == "05" & categ2 == 1 & categ3 == 1)
replace muebles_d = 1 if (categ1 == "05" & categ2 == 1 & categ3 == 2)
replace muebles_d = 1 if (categ1 == "05" & categ2 == 2)
replace muebles_d = 1 if (categ1 == "05" & categ2 == 3 & categ3 == 1)
replace muebles_d = 1 if (categ1 == "05" & categ2 == 3 & categ3 == 2)
replace muebles_d = 1 if (categ1 == "05" & categ2 == 4 & categ3 == 1 & categ4 >= 1 & categ4 <= 3)
replace muebles_d = 1 if (categ1 == "05" & categ2 == 5)

gen muebles_serv = (categ1 == "05" & categ2 == 1 & categ3 == 3)
replace muebles_serv = 1 if (categ1 == "05" & categ2 == 3 & categ3 == 3)
replace muebles_serv = 1 if (categ1 == "05" & categ2 == 4 & categ3 == 1 & categ4 == 4)
replace muebles_serv = 1 if (categ1 == "05" & categ2 == 6 & categ3 == 2)

gen limpieza_nd = (categ1 == "05" & categ2 == 6 & categ3 == 1)

gen muebles_other = (categ1 == "05" & categ2 == 7)

* Salud
gen med_nd = (categ1 == "06" & categ2 == 1 & categ3 == 1 & categ4 == 1)
replace med_nd = 1 if (categ1 == "06" & categ2 == 1 & categ3 == 1 & categ4 == 2)

gen med_d = (categ1 == "06" & categ2 == 1 & categ3 == 1 & categ4 == 3)

gen med_serv = (categ1 == "06" & categ2 == 2)
replace med_serv = 1 if (categ1 == "06" & categ2 == 3)

gen med_other = (categ1 == "06" & categ2 == 4)

* Transport
gen vehicle_d = (categ1 == "07" & categ2 == 1)
replace vehicle_d = 1 if (categ1 == "07" & categ2 == 2 & categ3 == 1)

gen fuel_nd = (categ1 == "07" & categ2 == 2 & categ3 == 2)

gen vehicle_serv = (categ1 == "07" & categ2 == 2 & categ3 >=3 & categ3<=4)

gen transp_serv = (categ1 == "07" & categ2 == 3)

gen transp_other = (categ1 == "07" & categ2 == 4)

* Communication
gen com_serv = (categ1 == "08" & categ2 == 1)
replace com_serv = 1 if (categ1 == "08" & categ2 == 3)

gen com_d = (categ1 == "08" & categ2 == 2)

gen com_other = (categ1 == "08" & categ2 == 4)

* Ocio and other
gen equip_d = (categ1 == "09" & categ2 == 1 & categ3>=1 & categ3 <= 4)
replace equip_d = 1 if (categ1 == "09" & categ2 == 2 & categ3>=1 & categ3 <= 2)
replace equip_d = 1 if (categ1 == "09" & categ2 == 3)

gen equip_serv = (categ1 == "09" & categ2 == 1 & categ3 == 5)
replace equip_serv = 1 if (categ1 == "09" & categ2 == 2 & categ3==3)

gen cult_serv =  (categ1 == "09" & categ2 == 4)

gen cult_d =  (categ1 == "09" & categ2 == 5)

gen vacations_serv =  (categ1 == "09" & categ2 == 6)

gen cult_other =  (categ1 == "09" & categ2 == 7)

* Educational services
gen educa_serv = (categ1 == "10")

* Hotel restaurants and other
gen foodout_serv = (categ1 == "11" & categ2==1)

gen hotel_serv = (categ1 == "11" & categ2>=2 & categ2<=3)

* other

gen personal_serv = (categ1 == "12" & categ2==1 & categ3==1)
replace personal_serv = 1 if (categ1 == "12" & categ2==1 & categ3==3)

gen personal_d = (categ1 == "12" & categ2==1 & categ3==2)

gen notdec_d =  (categ1 == "12" & categ2==2)

gen fin_serv =  (categ1 == "12" & categ2>=3 & categ2<=6)

gen transfer =  (categ1 == "12" & categ2>=7 & categ2<=8)

gen other_other = (categ1 == "12" & (categ2 == 0 | categ2 == 9))


*************************************************

gen serv = fin_serv + personal_serv + hotel_serv + foodout_serv + vacations_serv + cult_serv + equip_serv + com_serv + transp_serv + vehicle_serv ///
           + med_serv + muebles_serv + housing_serv + housepw_serv + clothes_serv + house_mant_serv + educa_serv
replace serv = 1 if serv>0 & serv!=.

gen durab = notdec_d + personal_d + cult_d + equip_d + com_d + vehicle_d + med_d + muebles_d + house_mant_d + rent_d 
replace durab = 1 if durab>0 & durab!=.

gen ndurab = food_nd + fuel_nd + med_nd + limpieza_nd + clothes_sd + dtd_nd
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen transfer_others = transfer + other_other + cult_other + com_other + transp_other + med_other + muebles_other + house_other
replace transfer_others = 1 if transfer_others>0 & transfer_others!=.

gen non_trade = rent_d + serv

gen trade = durab + ndurab - rent_d

gen all = serv + durab + ndurab + transfer_others
tab all

*tempfile gast_`y'
*save `gast_`y'', replace

save "$database/SPA/gastos`y'", replace

}


local year = "2016 2017 2018"

foreach y of local year {

use "$input/SPA/gastos`y'", clear

gen categ1 = substr(codigo,1,2)
gen categ2 = substr(codigo,3,1)
gen categ3 = substr(codigo,4,1)
gen categ4 = substr(codigo,5,1)

replace categ4 = "9" if categ4 == "A" | categ4 == "B" | categ4 == "C"

destring categ2, replace
destring categ3, replace
destring categ4, replace

* Food
gen food_nd = (categ1 == "01")

* Drinks, Tabacco and Drugs
gen dtd_nd = (categ1 == "02")

* Clothes
gen clothes_sd = (categ1 == "03" & categ2 == 1 & categ3 >= 1 & categ3 <= 3)
replace clothes_sd = 1 if (categ1 == "03" & categ2 == 2 & categ3 == 1)

gen clothes_serv = (categ1 == "03" & categ2 == 1 & categ3 == 4)
replace clothes_serv = 1 if (categ1 == "03" & categ2 == 2 & categ3 == 2)

* Housing
gen rent_d = (categ1 == "04" & categ2 == 1)
replace rent_d = 1 if (categ1 == "04" & categ2 == 2)

gen house_mant_d = (categ1 == "04" & categ2 == 3 & categ3 == 1)
*replace house_mant_d = 1 if (categ1 == "04" & categ2 == 3 & categ3 == 3)

gen house_mant_serv = (categ1 == "04" & categ2 == 3 & categ3 == 2)
*replace house_mant_serv = 1 if (categ1 == "04" & categ2 == 3 & categ3 == 4)

gen housing_serv = (categ1 == "04" & categ2 == 4)

gen housepw_serv = (categ1 == "04" & categ2 == 5)

*gen house_other = (categ1 == "04" & categ2 == 6)

* Muebles
gen muebles_d = (categ1 == "05" & categ2 == 1 & categ3 == 1)
replace muebles_d = 1 if (categ1 == "05" & categ2 == 1 & categ3 == 2)
replace muebles_d = 1 if (categ1 == "05" & categ2 == 2)
replace muebles_d = 1 if (categ1 == "05" & categ2 == 3 & categ3 == 1)
replace muebles_d = 1 if (categ1 == "05" & categ2 == 3 & categ3 == 2)
replace muebles_d = 1 if (categ1 == "05" & categ2 == 4 & categ3 == 0 & categ4 >= 1 & categ4 <= 3)
replace muebles_d = 1 if (categ1 == "05" & categ2 == 5)

gen muebles_serv = (categ1 == "05" & categ2 == 1 & categ3 == 3)
replace muebles_serv = 1 if (categ1 == "05" & categ2 == 3 & categ3 == 3)
replace muebles_serv = 1 if (categ1 == "05" & categ2 == 4 & categ3 == 0 & categ4 == 4)
replace muebles_serv = 1 if (categ1 == "05" & categ2 == 6 & categ3 == 2)

gen limpieza_nd = (categ1 == "05" & categ2 == 6 & categ3 == 1)

gen muebles_other = (categ1 == "05" & categ2 == 7)

* Salud
gen med_nd = (categ1 == "06" & categ2 == 1 & categ3 == 1)
replace med_nd = 1 if (categ1 == "06" & categ2 == 1 & categ3 == 2)

gen med_d = (categ1 == "06" & categ2 == 1 & categ3 == 3)

gen med_serv = (categ1 == "06" & categ2 == 2)
replace med_serv = 1 if (categ1 == "06" & categ2 == 3)

*gen med_other = (categ1 == "06" & categ2 == 4)

* Transport
gen vehicle_d = (categ1 == "07" & categ2 == 1)
replace vehicle_d = 1 if (categ1 == "07" & categ2 == 2 & categ3 == 1)

gen fuel_nd = (categ1 == "07" & categ2 == 2 & categ3 == 2)

gen vehicle_serv = (categ1 == "07" & categ2 == 2 & categ3 >=3 & categ3<=4)

gen transp_serv = (categ1 == "07" & categ2 == 3)

*gen transp_other = (categ1 == "07" & categ2 == 4)

* Communication
gen com_serv = (categ1 == "08" & categ2 == 1)
replace com_serv = 1 if (categ1 == "08" & categ2 == 3)

gen com_d = (categ1 == "08" & categ2 == 2)

*gen com_other = (categ1 == "08" & categ2 == 4)

* Ocio and other
gen equip_d = (categ1 == "09" & categ2 == 1 & categ3>=1 & categ3 <= 4)
replace equip_d = 1 if (categ1 == "09" & categ2 == 2 & categ3>=1 & categ3 <= 2)
replace equip_d = 1 if (categ1 == "09" & categ2 == 3)

gen equip_serv = (categ1 == "09" & categ2 == 1 & categ3 == 5)
replace equip_serv = 1 if (categ1 == "09" & categ2 == 2 & categ3==3)

gen cult_serv =  (categ1 == "09" & categ2 == 4)

gen cult_d =  (categ1 == "09" & categ2 == 5)

gen vacations_serv =  (categ1 == "09" & categ2 == 6)

*gen cult_other =  (categ1 == "09" & categ2 == 7)

* Educational services
gen educa_serv = (categ1 == "10")

* Hotel restaurants and other
gen foodout_serv = (categ1 == "11" & categ2==1)

gen hotel_serv = (categ1 == "11" & categ2==2)

* other

gen personal_serv = (categ1 == "12" & categ2==1 & categ3==1)
replace personal_serv = 1 if (categ1 == "12" & categ2==1 & categ3==3)

gen personal_d = (categ1 == "12" & categ2==1 & categ3==2)

gen notdec_d =  (categ1 == "12" & categ2==3)

gen fin_serv =  (categ1 == "12" & categ2>=4 & categ2<=7)

gen transfer =  (categ1 == "12" & categ2==8)

*gen other_other = (categ1 == "12" & (categ2 == 0 | categ2 == 9))


*************************************************

gen serv = fin_serv + personal_serv + hotel_serv + foodout_serv + vacations_serv + cult_serv + equip_serv + com_serv + transp_serv + vehicle_serv ///
           + med_serv + muebles_serv + housing_serv + housepw_serv + clothes_serv + house_mant_serv + educa_serv
replace serv = 1 if serv>0 & serv!=.

gen durab = notdec_d + personal_d + cult_d + equip_d + com_d + vehicle_d + med_d + muebles_d + house_mant_d + rent_d 
replace durab = 1 if durab>0 & durab!=.

gen ndurab = food_nd + fuel_nd + med_nd + limpieza_nd + clothes_sd + dtd_nd
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen transfer_others = transfer 
* + other_other + cult_other + com_other + transp_other + med_other + muebles_other + house_other
replace transfer_others = 1 if transfer_others>0 & transfer_others!=.

gen non_trade = rent_d + serv

gen trade = durab + ndurab - rent_d

gen all = serv + durab + ndurab + transfer_others
tab all

*tempfile gast_`y'
*save `gast_`y'', replace

save "$database/SPA/gastos`y'", replace

}


