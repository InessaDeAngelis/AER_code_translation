**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code cleans ENIGH Mexico raw data and creates consumption baskets
**********************************************************************

cls
clear all
capture clear matrix
set mem 200m
set more off

global database   = "$user/working_data"
global input      = "$user/input"
global output     = "$user/output"

*** Make non-durable ***

** 1992

u "$input/MEX/gastos1992.dta", replace

decode FOLIO, gen(FOLIO2)
decode CLAVE, gen(CLAVE2)

drop FOLIO CLAVE

rename FOLIO2 FOLIO
rename CLAVE2 CLAVE

gen year = 1992

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
destring numb, replace

* food
gen food_home_nd = (categ == "A" &  numb <=198 & numb!=.)
gen food_outhome_serv = (categ == "A" &  numb >=199 & numb <= 202)
gen tobacco_nd =  (categ == "A" &  numb >=203 & numb <= 205)

* public transport
gen transport_pub_serv =  (categ == "B" &  numb >=1 & numb <= 7)

*house mantainance goods (durab are e.g. detergent): nd:nondurable; d = durable
gen house_maintgoods_nd =  (categ == "C" &  numb >=1 & numb <= 6)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb >=14 & numb <= 16)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb == 19)

gen house_maintgoods_sd =  (categ == "C" &  numb >=7 & numb <= 13)
replace house_maintgoods_sd = 1 if (categ == "C" &  numb >=17 & numb <= 18)

gen house_serv =  (categ == "C" &  numb >=20 & numb <= 24)

* personal care goods (durab are e.g. hairdryer goods)
gen pcare_nd =  (categ == "D" &  numb >=1 & numb <= 6)
replace pcare_nd = 1 if (categ == "D" &  numb >=8 & numb <= 13)
replace pcare_nd = 1 if (categ == "D" &  numb == 17)

gen pcare_d =  (categ == "D" &  numb >=7 & numb <= 7)
replace pcare_d = 1 if (categ == "D" &  numb >=14 & numb <= 16)

gen pcare_serv = (categ == "D" &  numb >=18 & numb <= 22)

* educational
gen educ_serv = (categ == "E" &  numb >=1 & numb <= 9)
gen educ_d = (categ == "E" &  numb >=10 & numb <= 13)

* entretainment
gen ent_d = (categ == "E" &  numb >=14 & numb <= 17)
gen ent_serv = (categ == "E" &  numb >=18 & numb <= 25)

* communication
gen comm_d = (categ == "F" &  numb >=1 & numb <= 5)

* vehicles
gen fuel_nd = (categ == "F" &  numb >=6 & numb <= 7)
gen vehicles_serv = (categ == "F" &  numb >=8 & numb <= 10)

* housing
gen water_serv = (categ == "G" &  (numb == 3 | numb == 6 | numb ==8 | numb == 11 | numb == 14 | numb == 16))
gen tax_rent_house = (categ == "G" &  numb >=1 & numb <=17 & water_serv == 0)
gen serv_house = (categ == "G" &  numb >=18 & numb <=29)

* clothing
gen clothes_serv = (categ == "H" &  (numb ==30 | numb==43 | numb == 54 | numb ==64) )
gen clothes_sd = (categ == "H" &  numb >=1 & numb <=64 & clothes_serv == 0)

* decoration
gen decor_sd = (categ == "I" &  numb >=1 & numb <=23)
gen decor_serv = (categ == "I" &  numb ==24)

* medical
gen medical_serv = (categ == "J" & numb >=1 & numb <=28)
replace medical_serv = 1 if (categ == "J" & numb >=42 & numb <=43)
gen medication_nd = (categ == "J" & numb >=29 & numb <=36)
gen medical_d = (categ == "J" & numb >=37 & numb <=41)

* house equipment
gen heq_d = (categ == "K" & numb >=1 & numb <=18)
replace heq_d = 1 if (categ == "K" & numb >=20 & numb <=28)
replace heq_d = 1 if (categ == "K" & numb ==30)
gen heq_serv = (categ == "K" & (numb == 19 | numb == 29))
replace heq_serv = 1 if (categ == "K" & numb ==31)

* entretainment
replace ent_d = 1 if (categ == "L" &  numb >=1 & numb <= 11)
replace ent_d = 1 if (categ == "L" &  numb >=13 & numb <= 16)
replace ent_d = 1 if (categ == "L" &  numb >=18 & numb <= 22)
replace ent_d = 1 if (categ == "L" &  numb == 24)

replace ent_ser = 1 if (categ == "L" &  numb == 12)
replace ent_ser = 1 if (categ == "L" &  numb == 17)
replace ent_ser = 1 if (categ == "L" &  numb == 23)

* transport services
gen transp_serv = (categ == "M" &  numb >= 1 & numb<=6)
gen vehicles_d = (categ == "M" &  numb >= 7 & numb<=13)
replace vehicles_serv = 1 if (categ == "M" &  numb >= 14 & numb<=16)

* other expenditures
gen other_serv = (categ == "N" &  numb >= 1 & numb<=10)

* transfers 
gen transfers_all = (categ == "N" &  numb >= 11 & numb<=15)

*** drop erogaciones

drop if categ == "K" & (numb>=30 & numb<=31)
drop if categ == "G" & (numb==2)

*** tradable and non-tradable; services, transfers, durable and non-durable

gen serv = food_outhome_serv + transport_pub_serv + house_serv + pcare_serv + educ_serv + ent_serv + vehicles_serv ///
 + water_serv + serv_house + clothes_serv + decor_serv + medical_serv + heq_serv + ent_ser + transp_serv ///
 + other_serv
 replace serv = 1 if serv>0 & serv!=.
 
gen transfers = transfers_all
replace transfers = 1 if transfers>0 & transfers!=.

gen durable = vehicles_d + ent_d + heq_d + medical_d + tax_rent_house + comm_d + ent_d + educ_d + pcare_d 
replace durable = 1 if durable>0 & durable!=.
 
gen ndurab = medication_nd + decor_sd + fuel_nd + pcare_nd + house_maintgoods_sd + house_maintgoods_nd + tobacco_nd + food_home_nd + clothes_sd
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen NT = serv
gen T = durable + ndurab
replace T = 1 if T>0 & T!=.

save "$database/MEX/basket1992.dta", replace

******************************************************************************************

** 1994

u "$input/MEX/gastos1994.dta", replace

decode FOLIO, gen(FOLIO2)
decode CLAVE, gen(CLAVE2)

drop FOLIO CLAVE

rename FOLIO2 FOLIO
rename CLAVE2 CLAVE

gen year = 1994

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
destring numb, replace

* food
gen food_home_nd = (categ == "A" &  numb <=203 & numb!=.)
gen food_outhome_serv = (categ == "A" &  numb >=204 & numb <= 207)
gen tobacco_nd =  (categ == "A" &  numb >=208 & numb <= 210)

* public transport
gen transport_pub_serv =  (categ == "B" &  numb >=1 & numb <= 7)

*house mantainance goods (durab are e.g. detergent): nd:nondurable; d = durable
gen house_maintgoods_nd =  (categ == "C" &  numb >=1 & numb <= 6)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb >=14 & numb <= 16)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb == 19)

gen house_maintgoods_sd =  (categ == "C" &  numb >=7 & numb <= 13)
replace house_maintgoods_sd = 1 if (categ == "C" &  numb >=17 & numb <= 18)

gen house_serv =  (categ == "C" &  numb >=20 & numb <= 24)

* personal care goods (durab are e.g. hairdryer goods)
gen pcare_nd =  (categ == "D" &  numb >=1 & numb <= 6)
replace pcare_nd = 1 if (categ == "D" &  numb >=8 & numb <= 13)
replace pcare_nd = 1 if (categ == "D" &  numb == 17)

gen pcare_d =  (categ == "D" &  numb >=7 & numb <= 7)
replace pcare_d = 1 if (categ == "D" &  numb >=14 & numb <= 16)

gen pcare_serv = (categ == "D" &  numb >=18 & numb <= 22)

* educational
gen educ_serv = (categ == "E" &  numb >=1 & numb <= 12)
gen educ_d = (categ == "E" &  numb >=13 & numb <= 17)

* entretainment
gen ent_d = (categ == "E" &  numb >=18 & numb <= 22)
gen ent_serv = (categ == "E" &  numb >=23 & numb <= 31)

* communication
gen comm_d = (categ == "F" &  numb >=1 & numb <= 5)

* vehicles
gen fuel_nd = (categ == "F" &  numb >=6 & numb <= 7)
gen vehicles_serv = (categ == "F" &  numb >=8 & numb <= 10)

* housing
gen water_serv = (categ == "G" &  (numb == 3 | numb == 6 | numb ==8 | numb == 11 | numb == 14 | numb == 17 | numb == 20))
gen tax_rent_house = (categ == "G" &  numb >=1 & numb <=21 & water_serv == 0)
gen serv_house = (categ == "G" &  numb >=22 & numb <=33)

* clothing
gen clothes_serv = (categ == "H" &  (numb ==31 | numb==44 | numb == 54 | numb ==65) )
gen clothes_sd = (categ == "H" &  numb >=1 & numb <=65 & clothes_serv == 0)

* decoration
gen decor_sd = (categ == "I" &  numb >=1 & numb <=12)
replace decor_sd = 1 if (categ == "I" &  numb >=14 & numb <=22)
replace decor_sd = 1 if (categ == "I" &  numb >=24 & numb <=26)
gen decor_serv = (categ == "I" &  numb ==13)
replace decor_serv = 1 if (categ == "I" &  numb ==23)

* medical
gen medical_serv = (categ == "J" & numb >=1 & numb <=28)
replace medical_serv = 1 if (categ == "J" & numb >=42 & numb <=43)
gen medication_nd = (categ == "J" & numb >=29 & numb <=36)
gen medical_d = (categ == "J" & numb >=37 & numb <=41)

* house equipment
gen heq_d = (categ == "K" & numb >=1 & numb <=18)
replace heq_d = 1 if (categ == "K" & numb >=20 & numb <=28)
replace heq_d = 1 if (categ == "K" & numb ==30)
replace heq_d = 1 if (categ == "K" & numb ==32)
gen heq_serv = (categ == "K" & (numb == 19 | numb == 29))
replace heq_serv = 1 if (categ == "K" & numb ==31)
replace heq_serv = 1 if (categ == "K" & numb ==33)

* entretainment
replace ent_d = 1 if (categ == "L" &  numb >=1 & numb <= 14)
replace ent_d = 1 if (categ == "L" &  numb >=16 & numb <= 19)
replace ent_d = 1 if (categ == "L" &  numb >=21 & numb <= 25)
replace ent_d = 1 if (categ == "L" &  numb == 27)

replace ent_ser = 1 if (categ == "L" &  numb == 15)
replace ent_ser = 1 if (categ == "L" &  numb == 20)
replace ent_ser = 1 if (categ == "L" &  numb == 26)

* transport services
gen transp_serv = (categ == "M" &  numb >= 1 & numb<=6)
gen vehicles_d = (categ == "M" &  numb >= 7 & numb<=13)
replace vehicles_d = 1 if (categ == "M" &  numb >= 15 & numb<=16)
replace vehicles_serv = 1 if (categ == "M" &  numb == 14)
replace vehicles_serv = 1 if (categ == "M" &  numb == 17)
replace vehicles_serv = 1 if (categ == "M" &  numb == 18)

* other expenditures
gen other_serv = (categ == "N" &  numb >= 1 & numb<=10)

* transfers 
gen transfers_all = (categ == "N" &  numb >= 11 & numb<=16)

*** drop erogaciones

drop if categ == "K" & (numb>=30 & numb<=33)
drop if categ == "G" & (numb==2)

*** tradable and non-tradable; services, transfers, durable and non-durable

gen serv = food_outhome_serv + transport_pub_serv + house_serv + pcare_serv + educ_serv + ent_serv + vehicles_serv ///
 + water_serv + serv_house + clothes_serv + decor_serv + medical_serv + heq_serv + ent_ser + transp_serv ///
 + other_serv
 replace serv = 1 if serv>0 & serv!=.
 
gen transfers = transfers_all
replace transfers = 1 if transfers>0 & transfers!=.

gen durable = vehicles_d + ent_d + heq_d + medical_d + tax_rent_house + comm_d + ent_d + educ_d + pcare_d 
replace durable = 1 if durable>0 & durable!=.
 
gen ndurab = medication_nd + decor_sd + fuel_nd + pcare_nd + house_maintgoods_sd + house_maintgoods_nd + tobacco_nd + food_home_nd + clothes_sd
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen NT = serv
gen T = durable + ndurab
replace T = 1 if T>0 & T!=.

save "$database/MEX/basket1994.dta", replace

******************************************************************************************

** 1996

u "$input/MEX/gastos1996.dta", replace

decode FOLIO, gen(FOLIO2)
decode CLAVE, gen(CLAVE2)

drop FOLIO CLAVE

rename FOLIO2 FOLIO
rename CLAVE2 CLAVE

gen year = 1996

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
destring numb, replace

* food
gen food_home_nd = (categ == "A" &  numb <=204 & numb!=.)
gen food_outhome_serv = (categ == "A" &  numb >=205 & numb <= 208)
gen tobacco_nd =  (categ == "A" &  numb >=209 & numb <= 211)

* public transport
gen transport_pub_serv =  (categ == "B" &  numb >=1 & numb <= 7)

*house mantainance goods (durab are e.g. detergent): nd:nondurable; d = durable
gen house_maintgoods_nd =  (categ == "C" &  numb >=1 & numb <= 6)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb >=14 & numb <= 16)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb == 19)

gen house_maintgoods_sd =  (categ == "C" &  numb >=7 & numb <= 13)
replace house_maintgoods_sd = 1 if (categ == "C" &  numb >=17 & numb <= 18)

gen house_serv =  (categ == "C" &  numb >=20 & numb <= 24)

* personal care goods (durab are e.g. hairdryer goods)
gen pcare_nd =  (categ == "D" &  numb >=1 & numb <= 6)
replace pcare_nd = 1 if (categ == "D" &  numb >=8 & numb <= 13)
replace pcare_nd = 1 if (categ == "D" &  numb == 17)

gen pcare_d =  (categ == "D" &  numb >=7 & numb <= 7)
replace pcare_d = 1 if (categ == "D" &  numb >=14 & numb <= 16)

gen pcare_serv = (categ == "D" &  numb >=18 & numb <= 22)

* educational
gen educ_serv = (categ == "E" &  numb >=1 & numb <= 13)
replace educ_serv = 1 if (categ == "E" &  numb ==20)
gen educ_d = (categ == "E" &  numb >=14 & numb <= 19)

* entretainment
gen ent_d = (categ == "E" &  numb >=21 & numb <= 25)
gen ent_serv = (categ == "E" &  numb >=26 & numb <= 34)

* communication
gen comm_d = (categ == "F" &  numb >=1 & numb <= 5)

* vehicles
gen fuel_nd = (categ == "F" &  numb >=6 & numb <= 7)
gen vehicles_serv = (categ == "F" &  numb >=8 & numb <= 10)

* housing
gen water_serv = (categ == "G" &  (numb == 3 | numb == 6 | numb ==8 | numb == 11 | numb == 14 | numb == 17 | numb == 20))
gen tax_rent_house = (categ == "G" &  numb >=1 & numb <=21 & water_serv == 0)
gen serv_house = (categ == "G" &  numb >=22 & numb <=33)

* clothing
gen clothes_serv = (categ == "H" &  (numb ==31 | numb==44 | numb == 54 | numb ==65) )
gen clothes_sd = (categ == "H" &  numb >=1 & numb <=65 & clothes_serv == 0)

* decoration
gen decor_sd = (categ == "I" &  numb >=1 & numb <=12)
replace decor_sd = 1 if (categ == "I" &  numb >=14 & numb <=22)
replace decor_sd = 1 if (categ == "I" &  numb >=24 & numb <=26)
gen decor_serv = (categ == "I" &  numb ==13)
replace decor_serv = 1 if (categ == "I" &  numb ==23)

* medical
gen medical_serv = (categ == "J" & numb >=1 & numb <=32)
replace medical_serv = 1 if (categ == "J" & numb >=44 & numb <=45)
gen medication_nd = (categ == "J" & numb >=33 & numb <=38)
gen medical_d = (categ == "J" & numb >=39 & numb <=43)

* house equipment
gen heq_serv = (categ == "K" & (numb == 20 | numb == 30))
replace heq_serv = 1 if (categ == "K" & numb ==32)
replace heq_serv = 1 if (categ == "K" & numb ==34)

gen heq_d = (categ == "K" & numb >=1 & numb <=34 & heq_serv == 0)

* entretainment
replace ent_d = 1 if (categ == "L" &  numb >=1 & numb <= 14)
replace ent_d = 1 if (categ == "L" &  numb >=16 & numb <= 19)
replace ent_d = 1 if (categ == "L" &  numb >=21 & numb <= 25)
replace ent_d = 1 if (categ == "L" &  numb == 27)

replace ent_ser = 1 if (categ == "L" &  numb == 15)
replace ent_ser = 1 if (categ == "L" &  numb == 20)
replace ent_ser = 1 if (categ == "L" &  numb == 26)

* transport services
gen transp_serv = (categ == "M" &  numb >= 1 & numb<=6)
gen vehicles_d = (categ == "M" &  numb >= 7 & numb<=13)
replace vehicles_d = 1 if (categ == "M" &  numb >= 15 & numb<=16)
replace vehicles_serv = 1 if (categ == "M" &  numb == 14)
replace vehicles_serv = 1 if (categ == "M" &  numb == 17)
replace vehicles_serv = 1 if (categ == "M" &  numb == 18)

* other expenditures
gen other_serv = (categ == "N" &  numb >= 1 & numb<=10)

* transfers 
gen transfers_all = (categ == "N" &  numb >= 11 & numb<=16)

*** drop erogaciones

drop if categ == "K" & (numb>=30 & numb<=34)
drop if categ == "G" & (numb==2)

*** tradable and non-tradable; services, transfers, durable and non-durable

gen serv = food_outhome_serv + transport_pub_serv + house_serv + pcare_serv + educ_serv + ent_serv + vehicles_serv ///
 + water_serv + serv_house + clothes_serv + decor_serv + medical_serv + heq_serv + ent_ser + transp_serv ///
 + other_serv
 replace serv = 1 if serv>0 & serv!=.
 
gen transfers = transfers_all
replace transfers = 1 if transfers>0 & transfers!=.

gen durable = vehicles_d + ent_d + heq_d + medical_d + tax_rent_house + comm_d + ent_d + educ_d + pcare_d 
replace durable = 1 if durable>0 & durable!=.
 
gen ndurab = medication_nd + decor_sd + fuel_nd + pcare_nd + house_maintgoods_sd + house_maintgoods_nd + tobacco_nd + food_home_nd + clothes_sd
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen NT = serv
gen T = durable + ndurab
replace T = 1 if T>0 & T!=.

save "$database/MEX/basket1996.dta", replace


******************************************************************************************

** 1998

u "$input/MEX/gastos1998.dta", replace

decode FOLIO, gen(FOLIO2)
decode CLAVE, gen(CLAVE2)

drop FOLIO CLAVE

rename FOLIO2 FOLIO
rename CLAVE2 CLAVE

gen year = 1998

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
destring numb, replace

* food
gen food_home_nd = (categ == "A" &  numb <=204 & numb!=.)
gen food_outhome_serv = (categ == "A" &  numb >=205 & numb <= 208)
gen tobacco_nd =  (categ == "A" &  numb >=209 & numb <= 212)

* public transport
gen transport_pub_serv =  (categ == "B" &  numb >=1 & numb <= 7)

*house mantainance goods (durab are e.g. detergent): nd:nondurable; d = durable
gen house_maintgoods_nd =  (categ == "C" &  numb >=1 & numb <= 6)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb >=14 & numb <= 16)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb == 19)

gen house_maintgoods_sd =  (categ == "C" &  numb >=7 & numb <= 13)
replace house_maintgoods_sd = 1 if (categ == "C" &  numb >=17 & numb <= 18)

gen house_serv =  (categ == "C" &  numb >=20 & numb <= 24)

* personal care goods (durab are e.g. hairdryer goods)
gen pcare_nd =  (categ == "D" &  numb >=1 & numb <= 6)
replace pcare_nd = 1 if (categ == "D" &  numb >=8 & numb <= 13)
replace pcare_nd = 1 if (categ == "D" &  numb == 17)

gen pcare_d =  (categ == "D" &  numb >=7 & numb <= 7)
replace pcare_d = 1 if (categ == "D" &  numb >=14 & numb <= 16)

gen pcare_serv = (categ == "D" &  numb >=20 & numb <= 24)

* educational
gen educ_serv = (categ == "E" &  numb >=1 & numb <= 13)
replace educ_serv = 1 if (categ == "E" &  numb ==20)
gen educ_d = (categ == "E" &  numb >=14 & numb <= 19)

* entretainment
gen ent_d = (categ == "E" &  numb >=21 & numb <= 25)
gen ent_serv = (categ == "E" &  numb >=26 & numb <= 34)

* communication
gen comm_d = (categ == "F" &  numb >=1 & numb <= 6)

* vehicles
gen fuel_nd = (categ == "F" &  numb >=7 & numb <= 8)
gen vehicles_serv = (categ == "F" &  numb >=9 & numb <= 11)

* housing
gen water_serv = (categ == "G" &  (numb == 3 | numb == 6 | numb ==8 | numb == 11 | numb == 14 | numb == 17 | numb == 20))
gen tax_rent_house = (categ == "G" &  numb >=1 & numb <=21 & water_serv == 0)
gen serv_house = (categ == "G" &  numb >=22 & numb <=33)

* clothing
gen clothes_serv = (categ == "H" &  (numb ==31 | numb==44 | numb == 54 | numb ==65) )
gen clothes_sd = (categ == "H" &  numb >=1 & numb <=65 & clothes_serv == 0)

* decoration
gen decor_sd = (categ == "I" &  numb >=1 & numb <=12)
replace decor_sd = 1 if (categ == "I" &  numb >=14 & numb <=22)
replace decor_sd = 1 if (categ == "I" &  numb >=24 & numb <=26)
gen decor_serv = (categ == "I" &  numb ==13)
replace decor_serv = 1 if (categ == "I" &  numb ==23)

* medical
gen medical_serv = (categ == "J" & numb >=1 & numb <=32)
replace medical_serv = 1 if (categ == "J" & numb >=44 & numb <=45)
gen medication_nd = (categ == "J" & numb >=33 & numb <=38)
gen medical_d = (categ == "J" & numb >=39 & numb <=43)

* house equipment
gen heq_serv = (categ == "K" & (numb == 22 | numb == 33))
replace heq_serv = 1 if (categ == "K" & numb ==35)
replace heq_serv = 1 if (categ == "K" & numb ==37)

gen heq_d = (categ == "K" & numb >=1 & numb <=37 & heq_serv == 0)

* entretainment
replace ent_d = 1 if (categ == "L" &  numb >=1 & numb <= 14)
replace ent_d = 1 if (categ == "L" &  numb >=16 & numb <= 19)
replace ent_d = 1 if (categ == "L" &  numb >=21 & numb <= 25)
replace ent_d = 1 if (categ == "L" &  numb == 27)

replace ent_ser = 1 if (categ == "L" &  numb == 15)
replace ent_ser = 1 if (categ == "L" &  numb == 20)
replace ent_ser = 1 if (categ == "L" &  numb == 26)

* transport services
gen transp_serv = (categ == "M" &  numb >= 1 & numb<=6)
gen vehicles_d = (categ == "M" &  numb >= 7 & numb<=13)
replace vehicles_d = 1 if (categ == "M" &  numb >= 15 & numb<=16)
replace vehicles_serv = 1 if (categ == "M" &  numb == 14)
replace vehicles_serv = 1 if (categ == "M" &  numb == 17)
replace vehicles_serv = 1 if (categ == "M" &  numb == 18)

* other expenditures
gen other_serv = (categ == "N" &  numb >= 1 & numb<=10)

* transfers 
gen transfers_all = (categ == "N" &  numb >= 11 & numb<=16)

*** drop erogaciones

drop if categ == "K" & (numb>=34 & numb<=37)
drop if categ == "G" & (numb==2)

*** tradable and non-tradable; services, transfers, durable and non-durable

gen serv = food_outhome_serv + transport_pub_serv + house_serv + pcare_serv + educ_serv + ent_serv + vehicles_serv ///
 + water_serv + serv_house + clothes_serv + decor_serv + medical_serv + heq_serv + ent_ser + transp_serv ///
 + other_serv
 replace serv = 1 if serv>0 & serv!=.
 
gen transfers = transfers_all
replace transfers = 1 if transfers>0 & transfers!=.

gen durable = vehicles_d + ent_d + heq_d + medical_d + tax_rent_house + comm_d + ent_d + educ_d + pcare_d 
replace durable = 1 if durable>0 & durable!=.
 
gen ndurab = medication_nd + decor_sd + fuel_nd + pcare_nd + house_maintgoods_sd + house_maintgoods_nd + tobacco_nd + food_home_nd + clothes_sd
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen NT = serv
gen T = durable + ndurab
replace T = 1 if T>0 & T!=.

save "$database/MEX/basket1998.dta", replace

******************************************************************************************

** 2000

u "$input/MEX/gastos2000.dta", replace

decode FOLIO, gen(FOLIO2)
decode CLAVE, gen(CLAVE2)

drop FOLIO CLAVE

rename FOLIO2 FOLIO
rename CLAVE2 CLAVE

gen year = 2000

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
destring numb, replace

* food
gen food_home_nd = (categ == "A" &  numb <=205 & numb!=.)
gen food_outhome_serv = (categ == "A" &  numb >=206 & numb <= 209)
gen tobacco_nd =  (categ == "A" &  numb >=211 & numb <= 213)

* public transport
gen transport_pub_serv =  (categ == "B" &  numb >=1 & numb <= 7)

*house mantainance goods (durab are e.g. detergent): nd:nondurable; d = durable
gen house_maintgoods_nd =  (categ == "C" &  numb >=1 & numb <= 6)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb >=14 & numb <= 16)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb == 19)

gen house_maintgoods_sd =  (categ == "C" &  numb >=7 & numb <= 13)
replace house_maintgoods_sd = 1 if (categ == "C" &  numb >=17 & numb <= 18)

gen house_serv =  (categ == "C" &  numb >=20 & numb <= 24)

* personal care goods (durab are e.g. hairdryer goods)
gen pcare_nd =  (categ == "D" &  numb >=1 & numb <= 6)
replace pcare_nd = 1 if (categ == "D" &  numb >=8 & numb <= 13)
replace pcare_nd = 1 if (categ == "D" &  numb == 17)

gen pcare_d =  (categ == "D" &  numb >=7 & numb <= 7)
replace pcare_d = 1 if (categ == "D" &  numb >=14 & numb <= 16)

gen pcare_serv = (categ == "D" &  numb >=18 & numb <= 22)

* educational
gen educ_serv = (categ == "E" &  numb >=1 & numb <= 13)
replace educ_serv = 1 if (categ == "E" &  numb ==20)
gen educ_d = (categ == "E" &  numb >=14 & numb <= 19)

* entretainment
gen ent_d = (categ == "E" &  numb >=21 & numb <= 25)
gen ent_serv = (categ == "E" &  numb >=26 & numb <= 34)

* communication
gen comm_d = (categ == "F" &  numb >=1 & numb <= 6)

* vehicles
gen fuel_nd = (categ == "F" &  numb >=7 & numb <= 8)
gen vehicles_serv = (categ == "F" &  numb >=9 & numb <= 11)

* housing
gen water_serv = (categ == "G" &  (numb == 3 | numb == 6 | numb ==8 | numb == 11 | numb == 14 | numb == 17 | numb == 20))
gen tax_rent_house = (categ == "G" &  numb >=1 & numb <=21 & water_serv == 0)
gen serv_house = (categ == "G" &  numb >=22 & numb <=33)

* clothing
gen clothes_serv = (categ == "H" &  (numb ==31 | numb==44 | numb == 54 | numb ==65) )
gen clothes_sd = (categ == "H" &  numb >=1 & numb <=65 & clothes_serv == 0)

* decoration
gen decor_sd = (categ == "I" &  numb >=1 & numb <=12)
replace decor_sd = 1 if (categ == "I" &  numb >=14 & numb <=22)
replace decor_sd = 1 if (categ == "I" &  numb >=24 & numb <=26)
gen decor_serv = (categ == "I" &  numb ==13)
replace decor_serv = 1 if (categ == "I" &  numb ==23)

* medical
gen medical_serv = (categ == "J" & numb >=1 & numb <=32)
replace medical_serv = 1 if (categ == "J" & numb >=44 & numb <=45)
gen medication_nd = (categ == "J" & numb >=33 & numb <=38)
gen medical_d = (categ == "J" & numb >=39 & numb <=43)

* house equipment
gen heq_serv = (categ == "K" & (numb == 22 | numb == 33))
replace heq_serv = 1 if (categ == "K" & numb ==35)
replace heq_serv = 1 if (categ == "K" & numb ==37)

gen heq_d = (categ == "K" & numb >=1 & numb <=37 & heq_serv == 0)

* entretainment
replace ent_d = 1 if (categ == "L" &  numb >=1 & numb <= 14)
replace ent_d = 1 if (categ == "L" &  numb >=16 & numb <= 19)
replace ent_d = 1 if (categ == "L" &  numb >=21 & numb <= 25)
replace ent_d = 1 if (categ == "L" &  numb == 27)

replace ent_ser = 1 if (categ == "L" &  numb == 15)
replace ent_ser = 1 if (categ == "L" &  numb == 20)
replace ent_ser = 1 if (categ == "L" &  numb == 26)

* transport services
gen transp_serv = (categ == "M" &  numb >= 1 & numb<=6)
gen vehicles_d = (categ == "M" &  numb >= 7 & numb<=13)
replace vehicles_d = 1 if (categ == "M" &  numb >= 15 & numb<=16)
replace vehicles_serv = 1 if (categ == "M" &  numb == 14)
replace vehicles_serv = 1 if (categ == "M" &  numb == 17)
replace vehicles_serv = 1 if (categ == "M" &  numb == 18)

* other expenditures
gen other_serv = (categ == "N" &  numb >= 1 & numb<=10)

* transfers 
gen transfers_all = (categ == "N" &  numb >= 11 & numb<=16)

*** drop erogaciones

drop if categ == "K" & (numb>=34 & numb<=37)
drop if categ == "G" & (numb==2)

*** tradable and non-tradable; services, transfers, durable and non-durable

gen serv = food_outhome_serv + transport_pub_serv + house_serv + pcare_serv + educ_serv + ent_serv + vehicles_serv ///
 + water_serv + serv_house + clothes_serv + decor_serv + medical_serv + heq_serv + ent_ser + transp_serv ///
 + other_serv
 replace serv = 1 if serv>0 & serv!=.
 
gen transfers = transfers_all
replace transfers = 1 if transfers>0 & transfers!=.

gen durable = vehicles_d + ent_d + heq_d + medical_d + tax_rent_house + comm_d + ent_d + educ_d + pcare_d 
replace durable = 1 if durable>0 & durable!=.
 
gen ndurab = medication_nd + decor_sd + fuel_nd + pcare_nd + house_maintgoods_sd + house_maintgoods_nd + tobacco_nd + food_home_nd + clothes_sd
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen NT = serv
gen T = durable + ndurab
replace T = 1 if T>0 & T!=.

save "$database/MEX/basket2000.dta", replace

******************************************************************************************

** 2002

u "$input/MEX/gastos2002.dta", replace

decode FOLIO, gen(FOLIO2)
decode CLAVE, gen(CLAVE2)

drop FOLIO CLAVE

rename FOLIO2 FOLIO
rename CLAVE2 CLAVE

gen year = 2002

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
destring numb, replace

* food
gen food_home_nd = (categ == "A" &  numb <=234 & numb!=.)
gen food_outhome_serv = (categ == "A" &  numb >=235 & numb <= 239)
gen tobacco_nd =  (categ == "A" &  numb >=240 & numb <= 243)

* public transport
gen transport_pub_serv =  (categ == "B" &  numb >=1 & numb <= 7)

*house mantainance goods (durab are e.g. detergent): nd:nondurable; d = durable
gen house_maintgoods_nd =  (categ == "C" &  numb >=1 & numb <= 6)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb >=14 & numb <= 16)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb == 19)

gen house_maintgoods_sd =  (categ == "C" &  numb >=7 & numb <= 13)
replace house_maintgoods_sd = 1 if (categ == "C" &  numb >=17 & numb <= 18)

gen house_serv =  (categ == "C" &  numb >=20 & numb <= 24)

* personal care goods (durab are e.g. hairdryer goods)
gen pcare_nd =  (categ == "D" &  numb >=1 & numb <= 16)
replace pcare_nd = 1 if (categ == "D" &  numb ==19)

gen pcare_d =  (categ == "D" &  numb == 17)

gen pcare_serv = (categ == "D" &  numb ==18)
replace pcare_serv = 1 if (categ == "D" &  numb >=20 &  numb <=24)

* educational
gen educ_serv = (categ == "E" &  numb >=1 & numb <= 13)
replace educ_serv = 1 if (categ == "E" &  numb ==20)
gen educ_d = (categ == "E" &  numb >=14 & numb <= 19)

* entretainment
gen ent_d = (categ == "E" &  numb >=21 & numb <= 25)
gen ent_serv = (categ == "E" &  numb >=26 & numb <= 34)

* communication
gen comm_serv = (categ == "F" &  numb >=1 & numb <= 9)

* vehicles
gen fuel_nd = (categ == "F" &  numb >=10 & numb <= 11)
gen vehicles_serv = (categ == "F" &  numb >=12 & numb <= 15)

* housing
gen tax_rent_house = (categ == "G" &  numb ==1)
replace tax_rent_house = 1 if (categ == "G" &  numb ==5)
replace tax_rent_house = 1 if (categ == "G" &  numb ==8)
replace tax_rent_house = 1 if (categ == "G" &  numb ==12)
replace tax_rent_house = 1 if (categ == "G" &  numb ==23)
replace tax_rent_house = 1 if (categ == "G" &  numb ==27)
replace tax_rent_house = 1 if (categ == "G" &  numb ==33)

gen serv_house = (categ == "G" &  numb >=1 & numb <=40 & tax_rent_house==0)
gen combus_nd =  (categ == "G" &  numb >=41 & numb <=47)

* clothing
gen clothes_serv = (categ == "H" &  (numb ==25 | numb==93 | numb == 130 | numb ==143) )
gen clothes_sd = (categ == "H" &  numb >=1 & numb <=143 & clothes_serv == 0)

* decoration
gen decor_sd = (categ == "I" &  numb >=1 & numb <=12)
replace decor_sd = 1 if (categ == "I" &  numb >=14 & numb <=22)
replace decor_sd = 1 if (categ == "I" &  numb >=24 & numb <=26)
gen decor_serv = (categ == "I" &  numb ==13)
replace decor_serv = 1 if (categ == "I" &  numb ==23)

* medical
gen medical_serv = (categ == "J" & numb >=1 & numb <=47)
replace medical_serv = 1 if (categ == "J" & numb >= 74 & numb <= 77)
gen medication_nd = (categ == "J" & numb >=48 & numb <=69)
gen medical_d = (categ == "J" & numb >=70 & numb <=73)

* house equipment
gen heq_serv = (categ == "K" & (numb == 24 | numb == 36))
replace heq_serv = 1 if (categ == "K" & numb ==38)
replace heq_serv = 1 if (categ == "K" & numb ==40)
replace heq_serv = 1 if (categ == "K" & numb ==42)
replace heq_serv = 1 if (categ == "K" & numb ==44)

gen heq_d = (categ == "K" & numb >=1 & numb <=44 & heq_serv == 0)

* entretainment
replace ent_d = 1 if (categ == "L" &  numb >=1 & numb <= 15)
replace ent_d = 1 if (categ == "L" &  numb >=17 & numb <= 21)
replace ent_d = 1 if (categ == "L" &  numb >=23 & numb <= 28)
replace ent_d = 1 if (categ == "L" &  numb == 30)

replace ent_ser = 1 if (categ == "L" &  numb == 16)
replace ent_ser = 1 if (categ == "L" &  numb == 22)
replace ent_ser = 1 if (categ == "L" &  numb == 29)

* transport services
gen transp_serv = (categ == "M" &  numb >= 1 & numb<=6)
gen vehicles_d = (categ == "M" &  numb >= 7 & numb<=13)
replace vehicles_d = 1 if (categ == "M" &  numb >= 15 & numb<=16)
replace vehicles_serv = 1 if (categ == "M" &  numb == 14)
replace vehicles_serv = 1 if (categ == "M" &  numb == 17)
replace vehicles_serv = 1 if (categ == "M" &  numb == 18)

* other expenditures
gen other_serv = (categ == "N" &  numb >= 1 & numb<=10)

* transfers 
gen transfers_all = (categ == "N" &  numb >= 11 & numb<=16)

*** drop erogaciones

drop if categ == "K" & (numb>=37 & numb<=44)
drop if categ == "G" & (numb==1)

*** tradable and non-tradable; services, transfers, durable and non-durable

gen serv = food_outhome_serv + transport_pub_serv + house_serv + pcare_serv + educ_serv + ent_serv + vehicles_serv ///
  + serv_house + clothes_serv + decor_serv + medical_serv + heq_serv + ent_ser + transp_serv ///
 + other_serv + comm_serv
 replace serv = 1 if serv>0 & serv!=.
 
gen transfers = transfers_all
replace transfers = 1 if transfers>0 & transfers!=.

gen durable = vehicles_d + ent_d + heq_d + medical_d + tax_rent_house  + ent_d + educ_d + pcare_d 
replace durable = 1 if durable>0 & durable!=.
 
gen ndurab = medication_nd + decor_sd + fuel_nd + pcare_nd + house_maintgoods_sd + house_maintgoods_nd + tobacco_nd + food_home_nd + clothes_sd + combus_nd
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen NT = serv
gen T = durable + ndurab
replace T = 1 if T>0 & T!=.

save "$database/MEX/basket2002.dta", replace

******************************************************************************************

** 2004

u "$input/MEX/gastos2004.dta", replace

decode FOLIO, gen(FOLIO2)
decode CLAVE, gen(CLAVE2)

drop FOLIO CLAVE

rename FOLIO2 FOLIO
rename CLAVE2 CLAVE

gen year = 2004

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
drop if categ == "T"
destring numb, replace

* food
gen food_home_nd = (categ == "A" &  numb <=234 & numb!=.)
gen food_outhome_serv = (categ == "A" &  numb >=235 & numb <= 239)
gen tobacco_nd =  (categ == "A" &  numb >=240 & numb <= 243)

* public transport
gen transport_pub_serv =  (categ == "B" &  numb >=1 & numb <= 7)

*house mantainance goods (durab are e.g. detergent): nd:nondurable; d = durable
gen house_maintgoods_nd =  (categ == "C" &  numb >=1 & numb <= 6)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb >=14 & numb <= 16)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb == 19)

gen house_maintgoods_sd =  (categ == "C" &  numb >=7 & numb <= 13)
replace house_maintgoods_sd = 1 if (categ == "C" &  numb >=17 & numb <= 18)

gen house_serv =  (categ == "C" &  numb >=20 & numb <= 24)

* personal care goods (durab are e.g. hairdryer goods)
gen pcare_nd =  (categ == "D" &  numb >=1 & numb <= 16)
replace pcare_nd = 1 if (categ == "D" &  numb ==19)

gen pcare_d =  (categ == "D" &  numb == 17)

gen pcare_serv = (categ == "D" &  numb ==18)
replace pcare_serv = 1 if (categ == "D" &  numb >=20 &  numb <=24)

* educational
gen educ_serv = (categ == "E" &  numb >=1 & numb <= 13)
replace educ_serv = 1 if (categ == "E" &  numb ==20)
gen educ_d = (categ == "E" &  numb >=14 & numb <= 19)

* entretainment
gen ent_d = (categ == "E" &  numb >=21 & numb <= 24)
gen ent_serv = (categ == "E" &  numb >=25 & numb <= 33)

* communication
gen comm_serv = (categ == "F" &  numb >=1 & numb <= 9)

* vehicles
gen fuel_nd = (categ == "F" &  numb >=10 & numb <= 11)
gen vehicles_serv = (categ == "F" &  numb >=12 & numb <= 15)

* housing

gen serv_house = (categ == "G" &  numb >=7 & numb <=9)
replace serv_house = 1 if (categ == "G" &  numb >=19 & numb <=22)

gen tax_rent_house = (categ == "G" &  numb >=1 & numb <=18 & serv_house==0)

gen combus_nd =  (categ == "G" &  numb >=23 & numb <=29)

* clothing
gen clothes_serv = (categ == "H" &  (numb ==15 | numb==27 | numb == 43 | numb ==55 | numb ==71 | numb ==75 | numb ==106 | numb ==119) )
gen clothes_sd = (categ == "H" &  numb >=1 & numb <=119 & clothes_serv == 0)

* decoration
gen decor_sd = (categ == "I" &  numb >=1 & numb <=12)
replace decor_sd = 1 if (categ == "I" &  numb >=14 & numb <=22)
replace decor_sd = 1 if (categ == "I" &  numb >=24 & numb <=26)
gen decor_serv = (categ == "I" &  numb ==13)
replace decor_serv = 1 if (categ == "I" &  numb ==23)

* medical
gen medical_serv = (categ == "J" & numb >=1 & numb <=19)
replace medical_serv = 1 if (categ == "J" & numb >= 36 & numb <= 43)
replace medical_serv = 1 if (categ == "J" & numb >= 62 & numb <= 64)
replace medical_serv = 1 if (categ == "J" & numb >= 70 & numb <= 72)

gen medication_nd = (categ == "J" & numb >=20 & numb <=35)
replace medication_nd = 1 if (categ == "J" & numb >=44 & numb <=61)

gen medical_d = (categ == "J" & numb >=65 & numb <=69)

* house equipment
gen heq_serv = (categ == "K" & (numb == 24 | numb == 36))
replace heq_serv = 1 if (categ == "K" & numb ==38)
replace heq_serv = 1 if (categ == "K" & numb ==40)
replace heq_serv = 1 if (categ == "K" & numb ==42)
replace heq_serv = 1 if (categ == "K" & numb ==44)

gen heq_d = (categ == "K" & numb >=1 & numb <=44 & heq_serv == 0)

* entretainment
replace ent_d = 1 if (categ == "L" &  numb >=1 & numb <= 15)
replace ent_d = 1 if (categ == "L" &  numb >=17 & numb <= 21)
replace ent_d = 1 if (categ == "L" &  numb >=23 & numb <= 27)
replace ent_d = 1 if (categ == "L" &  numb == 29)

replace ent_ser = 1 if (categ == "L" &  numb == 16)
replace ent_ser = 1 if (categ == "L" &  numb == 22)
replace ent_ser = 1 if (categ == "L" &  numb == 28)

* transport services
gen transp_serv = (categ == "M" &  numb >= 1 & numb<=6)
gen vehicles_d = (categ == "M" &  numb >= 7 & numb<=13)
replace vehicles_d = 1 if (categ == "M" &  numb >= 15 & numb<=16)
replace vehicles_serv = 1 if (categ == "M" &  numb == 14)
replace vehicles_serv = 1 if (categ == "M" &  numb == 17)
replace vehicles_serv = 1 if (categ == "M" &  numb == 18)

* other expenditures
gen other_serv = (categ == "N" &  numb >= 1 & numb<=10)

* transfers 
gen transfers_all = (categ == "N" &  numb >= 11 & numb<=16)

*** drop erogaciones

drop if categ == "K" & (numb>=37 & numb<=44)
drop if categ == "G" & (numb==1)

*** tradable and non-tradable; services, transfers, durable and non-durable

gen serv = food_outhome_serv + transport_pub_serv + house_serv + pcare_serv + educ_serv + ent_serv + vehicles_serv ///
  + serv_house + clothes_serv + decor_serv + medical_serv + heq_serv + ent_ser + transp_serv ///
 + other_serv + comm_serv
 replace serv = 1 if serv>0 & serv!=.
 
gen transfers = transfers_all
replace transfers = 1 if transfers>0 & transfers!=.

gen durable = vehicles_d + ent_d + heq_d + medical_d + tax_rent_house  + ent_d + educ_d + pcare_d 
replace durable = 1 if durable>0 & durable!=.
 
gen ndurab = medication_nd + decor_sd + fuel_nd + pcare_nd + house_maintgoods_sd + house_maintgoods_nd + tobacco_nd + food_home_nd + clothes_sd + combus_nd
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen NT = serv
gen T = durable + ndurab
replace T = 1 if T>0 & T!=.

drop if numb == 901

save "$database/MEX/basket2004.dta", replace

******************************************************************************************

** 2006

u "$input/MEX/gastos2006.dta", replace

rename folio FOLIO
rename gas_tri GAS_TRI
rename clave CLAVE

gen year = 2006

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
drop if categ == "T"
destring numb, replace

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
drop if categ == "T"
destring numb, replace

* food
gen food_home_nd = (categ == "A" &  numb <=238 & numb!=.)
gen food_outhome_serv = (categ == "A" &  numb >=243 & numb <= 247)
gen tobacco_nd =  (categ == "A" &  numb >=239 & numb <= 242)

* public transport
gen transport_pub_serv =  (categ == "B" &  numb >=1 & numb <= 7)

*house mantainance goods (durab are e.g. detergent): nd:nondurable; d = durable
gen house_maintgoods_nd =  (categ == "C" &  numb >=1 & numb <= 6)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb >=14 & numb <= 16)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb == 19)

gen house_maintgoods_sd =  (categ == "C" &  numb >=7 & numb <= 13)
replace house_maintgoods_sd = 1 if (categ == "C" &  numb >=17 & numb <= 18)

gen house_serv =  (categ == "C" &  numb >=20 & numb <= 24)

* personal care goods (durab are e.g. hairdryer goods)
gen pcare_nd =  (categ == "D" &  numb >=1 & numb <= 18)
replace pcare_nd = 1 if (categ == "D" &  numb ==21)

gen pcare_d =  (categ == "D" &  numb == 19)

gen pcare_serv = (categ == "D" &  numb ==20)
replace pcare_serv = 1 if (categ == "D" &  numb >=22 & numb <=26 )

* educational
gen educ_serv = (categ == "E" &  numb >=1 & numb <= 13)
replace educ_serv = 1 if (categ == "E" &  numb ==19)
gen educ_d = (categ == "E" &  numb >=14 & numb <= 18)

* entretainment
gen ent_d = (categ == "E" &  numb >=20 & numb <= 24)
gen ent_serv = (categ == "E" &  numb >=25 & numb <= 33)

* communication
gen comm_serv = (categ == "F" &  numb >=1 & numb <= 9)

* vehicles
gen fuel_nd = (categ == "F" &  numb >=10 & numb <= 13)
gen vehicles_serv = (categ == "F" &  numb >=14 & numb <= 17)

* housing

gen serv_house = (categ == "G" &  numb >=7 & numb <=10)
replace serv_house = 1 if (categ == "G" &  numb >=20 & numb <=23)

gen tax_rent_house = (categ == "G" &  numb >=1 & numb <=19 & serv_house==0)

gen combus_nd =  (categ == "G" &  numb >=24 & numb <=30)

* clothing
gen clothes_serv = (categ == "H" &  (numb ==15 | numb==27 | numb == 43 | numb ==55 | numb ==71 | numb ==75 | numb ==106 | numb ==119) )
gen clothes_sd = (categ == "H" &  numb >=1 & numb <=119 & clothes_serv == 0)

* decoration
gen decor_sd = (categ == "I" &  numb >=1 & numb <=12)
replace decor_sd = 1 if (categ == "I" &  numb >=14 & numb <=22)
replace decor_sd = 1 if (categ == "I" &  numb >=24 & numb <=26)
gen decor_serv = (categ == "I" &  numb ==13)
replace decor_serv = 1 if (categ == "I" &  numb ==23)

* medical
gen medical_serv = (categ == "J" & numb >=1 & numb <=19)
replace medical_serv = 1 if (categ == "J" & numb >= 36 & numb <= 43)
replace medical_serv = 1 if (categ == "J" & numb >= 62 & numb <= 64)
replace medical_serv = 1 if (categ == "J" & numb >= 70 & numb <= 72)

gen medication_nd = (categ == "J" & numb >=20 & numb <=35)
replace medication_nd = 1 if (categ == "J" & numb >=44 & numb <=61)

gen medical_d = (categ == "J" & numb >=65 & numb <=69)

* house equipment
gen heq_serv = (categ == "K" & (numb == 24 | numb == 36))
replace heq_serv = 1 if (categ == "K" & numb ==38)
replace heq_serv = 1 if (categ == "K" & numb ==40)
replace heq_serv = 1 if (categ == "K" & numb ==42)
replace heq_serv = 1 if (categ == "K" & numb ==44)

gen heq_d = (categ == "K" & numb >=1 & numb <=44 & heq_serv == 0)

* entretainment
replace ent_d = 1 if (categ == "L" &  numb >=1 & numb <= 15)
replace ent_d = 1 if (categ == "L" &  numb >=17 & numb <= 21)
replace ent_d = 1 if (categ == "L" &  numb >=23 & numb <= 27)
replace ent_d = 1 if (categ == "L" &  numb == 29)

replace ent_ser = 1 if (categ == "L" &  numb == 16)
replace ent_ser = 1 if (categ == "L" &  numb == 22)
replace ent_ser = 1 if (categ == "L" &  numb == 28)

* transport services
gen transp_serv = (categ == "M" &  numb >= 1 & numb<=6)
gen vehicles_d = (categ == "M" &  numb >= 7 & numb<=13)
replace vehicles_d = 1 if (categ == "M" &  numb >= 15 & numb<=16)
replace vehicles_serv = 1 if (categ == "M" &  numb == 14)
replace vehicles_serv = 1 if (categ == "M" &  numb == 17)
replace vehicles_serv = 1 if (categ == "M" &  numb == 18)

* other expenditures
gen other_serv = (categ == "N" &  numb >= 1 & numb<=10)

* transfers 
gen transfers_all = (categ == "N" &  numb >= 11 & numb<=16)

*** drop erogaciones

drop if categ == "K" & (numb>=37 & numb<=44)
drop if categ == "G" & (numb==1)

*** tradable and non-tradable; services, transfers, durable and non-durable

gen serv = food_outhome_serv + transport_pub_serv + house_serv + pcare_serv + educ_serv + ent_serv + vehicles_serv ///
  + serv_house + clothes_serv + decor_serv + medical_serv + heq_serv + ent_ser + transp_serv ///
 + other_serv + comm_serv
 replace serv = 1 if serv>0 & serv!=.
 
gen transfers = transfers_all
replace transfers = 1 if transfers>0 & transfers!=.

gen durable = vehicles_d + ent_d + heq_d + medical_d + tax_rent_house  + ent_d + educ_d + pcare_d 
replace durable = 1 if durable>0 & durable!=.
 
gen ndurab = medication_nd + decor_sd + fuel_nd + pcare_nd + house_maintgoods_sd + house_maintgoods_nd + tobacco_nd + food_home_nd + clothes_sd + combus_nd
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen NT = serv
gen T = durable + ndurab
replace T = 1 if T>0 & T!=.

save "$database/MEX/basket2006.dta", replace

******************************************************************************************

** 2008

use "$input/MEX/gastos2008_1.dta", clear
append using "$input/MEX/gastos2008_2.dta"
append using "$input/MEX/gastos2008_3.dta"
append using "$input/MEX/gastos2008_4.dta"

gen FOLIO = folioviv + foliohog
rename clave CLAVE
rename gas_tri GAS_TRI

gen year = 2008

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
drop if categ == "T"
destring numb, replace

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
drop if categ == "T"
destring numb, replace

* food
gen food_home_nd = (categ == "A" &  numb <=238 & numb!=.)
gen tobacco_nd =  (categ == "A" &  numb >=239 & numb <= 242)
gen food_outhome_serv = (categ == "A" &  numb >=243 & numb <= 247)

* public transport
gen transport_pub_serv =  (categ == "B" &  numb >=1 & numb <= 7)

*house mantainance goods (durab are e.g. detergent): nd:nondurable; d = durable
gen house_maintgoods_nd =  (categ == "C" &  numb >=1 & numb <= 6)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb >=14 & numb <= 16)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb == 19)

gen house_maintgoods_sd =  (categ == "C" &  numb >=7 & numb <= 13)
replace house_maintgoods_sd = 1 if (categ == "C" &  numb >=17 & numb <= 18)

gen house_serv =  (categ == "C" &  numb >=20 & numb <= 24)

* personal care goods (durab are e.g. hairdryer goods)
gen pcare_nd =  (categ == "D" &  numb >=1 & numb <= 18)
replace pcare_nd = 1 if (categ == "D" &  numb ==21)

gen pcare_d =  (categ == "D" &  numb == 19)

gen pcare_serv = (categ == "D" &  numb ==20)
replace pcare_serv = 1 if (categ == "D" &  numb >=22 & numb <=26 )

* educational
gen educ_serv = (categ == "E" &  numb >=1 & numb <= 13)
replace educ_serv = 1 if (categ == "E" &  numb ==19)
gen educ_d = (categ == "E" &  numb >=14 & numb <= 18)

* entretainment
gen ent_d = (categ == "E" &  numb >=20 & numb <= 24)
gen ent_serv = (categ == "E" &  numb >=25 & numb <= 33)

* communication
gen comm_serv = (categ == "F" &  numb >=1 & numb <= 9)

* vehicles
gen fuel_nd = (categ == "F" &  numb >=10 & numb <= 13)
gen vehicles_serv = (categ == "F" &  numb >=14 & numb <= 17)

* housing

gen serv_house = (categ == "G" &  numb >=7 & numb <=10)
replace serv_house = 1 if (categ == "G" &  numb >=12 & numb <=15)

gen tax_rent_house = (categ == "G" &  numb >=1 & numb <=11 & serv_house==0)

gen combus_nd =  (categ == "G" &  numb >=16 & numb <=22)

* clothing
gen clothes_serv = (categ == "H" &  (numb ==12 | numb==26 | numb == 38 | numb ==54 | numb ==66 | numb ==82 | numb ==120 | numb ==133 | numb ==136) )
gen clothes_sd = (categ == "H" &  numb >=1 & numb <=136 & clothes_serv == 0)

* decoration
gen decor_sd = (categ == "I" &  numb >=1 & numb <=12)
replace decor_sd = 1 if (categ == "I" &  numb >=14 & numb <=22)
replace decor_sd = 1 if (categ == "I" &  numb >=24 & numb <=26)
gen decor_serv = (categ == "I" &  numb ==13)
replace decor_serv = 1 if (categ == "I" &  numb ==23)

* medical
gen medical_serv = (categ == "J" & numb >=1 & numb <=19)
replace medical_serv = 1 if (categ == "J" & numb >= 36 & numb <= 43)
replace medical_serv = 1 if (categ == "J" & numb >= 62 & numb <= 64)
replace medical_serv = 1 if (categ == "J" & numb >= 70 & numb <= 72)

gen medication_nd = (categ == "J" & numb >=20 & numb <=35)
replace medication_nd = 1 if (categ == "J" & numb >=44 & numb <=61)

gen medical_d = (categ == "J" & numb >=65 & numb <=69)

* house equipment
gen heq_serv = (categ == "K" & (numb == 24 | numb == 36))
replace heq_serv = 1 if (categ == "K" & numb ==38)
replace heq_serv = 1 if (categ == "K" & numb ==40)
replace heq_serv = 1 if (categ == "K" & numb ==42)
replace heq_serv = 1 if (categ == "K" & numb ==44)

gen heq_d = (categ == "K" & numb >=1 & numb <=44 & heq_serv == 0)

* entretainment
replace ent_d = 1 if (categ == "L" &  numb >=1 & numb <= 15)
replace ent_d = 1 if (categ == "L" &  numb >=17 & numb <= 21)
replace ent_d = 1 if (categ == "L" &  numb >=23 & numb <= 27)
replace ent_d = 1 if (categ == "L" &  numb == 29)

replace ent_ser = 1 if (categ == "L" &  numb == 16)
replace ent_ser = 1 if (categ == "L" &  numb == 22)
replace ent_ser = 1 if (categ == "L" &  numb == 28)

* transport services
gen transp_serv = (categ == "M" &  numb >= 1 & numb<=6)
gen vehicles_d = (categ == "M" &  numb >= 7 & numb<=13)
replace vehicles_d = 1 if (categ == "M" &  numb >= 15 & numb<=16)
replace vehicles_serv = 1 if (categ == "M" &  numb == 14)
replace vehicles_serv = 1 if (categ == "M" &  numb == 17)
replace vehicles_serv = 1 if (categ == "M" &  numb == 18)

* other expenditures
gen other_serv = (categ == "N" &  numb >= 1 & numb<=10)

* transfers 
gen transfers_all = (categ == "N" &  numb >= 11 & numb<=16)

*** drop erogaciones

drop if categ == "K" & (numb>=37 & numb<=44)
drop if categ == "G" & (numb==1)

*** tradable and non-tradable; services, transfers, durable and non-durable

gen serv = food_outhome_serv + transport_pub_serv + house_serv + pcare_serv + educ_serv + ent_serv + vehicles_serv ///
  + serv_house + clothes_serv + decor_serv + medical_serv + heq_serv + ent_ser + transp_serv ///
 + other_serv + comm_serv
 replace serv = 1 if serv>0 & serv!=.
 
gen transfers = transfers_all
replace transfers = 1 if transfers>0 & transfers!=.

gen durable = vehicles_d + ent_d + heq_d + medical_d + tax_rent_house  + ent_d + educ_d + pcare_d 
replace durable = 1 if durable>0 & durable!=.
 
gen ndurab = medication_nd + decor_sd + fuel_nd + pcare_nd + house_maintgoods_sd + house_maintgoods_nd + tobacco_nd + food_home_nd + clothes_sd + combus_nd
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen NT = serv
gen T = durable + ndurab
replace T = 1 if T>0 & T!=.

save "$database/MEX/basket2008.dta", replace

******************************************************************************************

** 2010

use "$input/MEX/gastos2010_1.dta", clear
append using "$input/MEX/gastos2010_2.dta"
append using "$input/MEX/gastos2010_3.dta"
append using "$input/MEX/gastos2010_4.dta"
append using "$input/MEX/gastos2010_5.dta"
append using "$input/MEX/gastos2010_6.dta"

gen FOLIO = folioviv + foliohog
rename clave CLAVE
rename gas_tri GAS_TRI

replace GAS_TRI = 0 if GAS_TRI == .
replace costo_tri = 0 if costo_tri == .
replace recibo_tri = 0 if recibo_tri == .

replace GAS_TRI = GAS_TRI + costo_tri + recibo_tri

drop if GAS_TRI == .

gen year = 2010

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
drop if categ == "T"
destring numb, replace

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
drop if categ == "T"
destring numb, replace

* food
gen food_home_nd = (categ == "A" &  numb <=238 & numb!=.)
gen tobacco_nd =  (categ == "A" &  numb >=239 & numb <= 242)
gen food_outhome_serv = (categ == "A" &  numb >=243 & numb <= 247)

* public transport
gen transport_pub_serv =  (categ == "B" &  numb >=1 & numb <= 7)

*house mantainance goods (durab are e.g. detergent): nd:nondurable; d = durable
gen house_maintgoods_nd =  (categ == "C" &  numb >=1 & numb <= 6)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb >=14 & numb <= 16)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb == 19)

gen house_maintgoods_sd =  (categ == "C" &  numb >=7 & numb <= 13)
replace house_maintgoods_sd = 1 if (categ == "C" &  numb >=17 & numb <= 18)

gen house_serv =  (categ == "C" &  numb >=20 & numb <= 24)

* personal care goods (durab are e.g. hairdryer goods)
gen pcare_nd =  (categ == "D" &  numb >=1 & numb <= 18)
replace pcare_nd = 1 if (categ == "D" &  numb ==21)

gen pcare_d =  (categ == "D" &  numb == 19)

gen pcare_serv = (categ == "D" &  numb ==20)
replace pcare_serv = 1 if (categ == "D" &  numb >=22 & numb <=26 )

* educational
gen educ_serv = (categ == "E" &  numb >=1 & numb <= 13)
replace educ_serv = 1 if (categ == "E" &  numb >=18 & numb <= 19)
replace educ_serv = 1 if (categ == "E" &  numb ==21)
gen educ_d = (categ == "E" &  numb >=14 & numb <= 17)
replace educ_d = 1 if (categ == "E" &  numb ==20)

* entretainment
gen ent_d = (categ == "E" &  numb >=22 & numb <= 26)
gen ent_serv = (categ == "E" &  numb >=27 & numb <= 34)

* communication
gen comm_serv = (categ == "F" &  numb >=1 & numb <= 6)

* vehicles
gen fuel_nd = (categ == "F" &  numb >=7 & numb <= 10)
gen vehicles_serv = (categ == "F" &  numb >=11 & numb <= 14)

* housing

gen serv_house = (categ == "G" &  numb >=5 & numb <=8)
replace serv_house = 1 if (categ == "R" &  numb >=1 & numb <=13)

gen tax_rent_house = (categ == "G" &  numb >=1 & numb <=4)

gen combus_nd =  (categ == "G" &  numb >=9 & numb <=16)

* clothing
gen clothes_serv = (categ == "H" &  (numb ==12 | numb==26 | numb == 38 | numb ==54 | numb ==66 | numb ==82 | numb ==120 | numb ==133 | numb ==136) )
gen clothes_sd = (categ == "H" &  numb >=1 & numb <=136 & clothes_serv == 0)

* decoration
gen decor_sd = (categ == "I" &  numb >=1 & numb <=12)
replace decor_sd = 1 if (categ == "I" &  numb >=14 & numb <=22)
replace decor_sd = 1 if (categ == "I" &  numb >=24 & numb <=26)
gen decor_serv = (categ == "I" &  numb ==13)
replace decor_serv = 1 if (categ == "I" &  numb ==23)

* medical
gen medical_serv = (categ == "J" & numb >=1 & numb <=19)
replace medical_serv = 1 if (categ == "J" & numb >= 36 & numb <= 43)
replace medical_serv = 1 if (categ == "J" & numb >= 62 & numb <= 64)
replace medical_serv = 1 if (categ == "J" & numb >= 70 & numb <= 72)

gen medication_nd = (categ == "J" & numb >=20 & numb <=35)
replace medication_nd = 1 if (categ == "J" & numb >=44 & numb <=61)

gen medical_d = (categ == "J" & numb >=65 & numb <=69)

* house equipment
gen heq_serv = (categ == "K" & (numb == 25 | numb == 37))
replace heq_serv = 1 if (categ == "K" & numb ==39)
replace heq_serv = 1 if (categ == "K" & numb ==41)
replace heq_serv = 1 if (categ == "K" & numb ==43)
replace heq_serv = 1 if (categ == "K" & numb ==45)

gen heq_d = (categ == "K" & numb >=1 & numb <=45 & heq_serv == 0)

* entretainment
replace ent_d = 1 if (categ == "L" &  numb >=1 & numb <= 15)
replace ent_d = 1 if (categ == "L" &  numb >=17 & numb <= 21)
replace ent_d = 1 if (categ == "L" &  numb >=23 & numb <= 27)
replace ent_d = 1 if (categ == "L" &  numb == 29)

replace ent_ser = 1 if (categ == "L" &  numb == 16)
replace ent_ser = 1 if (categ == "L" &  numb == 22)
replace ent_ser = 1 if (categ == "L" &  numb == 28)

* transport services
gen transp_serv = (categ == "M" &  numb >= 1 & numb<=6)
gen vehicles_d = (categ == "M" &  numb >= 7 & numb<=13)
replace vehicles_d = 1 if (categ == "M" &  numb >= 15 & numb<=16)
replace vehicles_serv = 1 if (categ == "M" &  numb == 14)
replace vehicles_serv = 1 if (categ == "M" &  numb == 17)
replace vehicles_serv = 1 if (categ == "M" &  numb == 18)

* other expenditures
gen other_serv = (categ == "N" &  numb >= 1 & numb<=10)

* transfers 
gen transfers_all = (categ == "N" &  numb >= 11 & numb<=16)

*** drop erogaciones

drop if categ == "K" & (numb>=38 & numb<=45)

*** tradable and non-tradable; services, transfers, durable and non-durable

gen serv = food_outhome_serv + transport_pub_serv + house_serv + pcare_serv + educ_serv + ent_serv + vehicles_serv ///
  + serv_house + clothes_serv + decor_serv + medical_serv + heq_serv + ent_ser + transp_serv ///
 + other_serv + comm_serv
 replace serv = 1 if serv>0 & serv!=.
 
gen transfers = transfers_all
replace transfers = 1 if transfers>0 & transfers!=.

gen durable = vehicles_d + ent_d + heq_d + medical_d + tax_rent_house  + ent_d + educ_d + pcare_d 
replace durable = 1 if durable>0 & durable!=.
 
gen ndurab = medication_nd + decor_sd + fuel_nd + pcare_nd + house_maintgoods_sd + house_maintgoods_nd + tobacco_nd + food_home_nd + clothes_sd + combus_nd 
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen NT = serv
gen T = durable + ndurab
replace T = 1 if T>0 & T!=.

save "$database/MEX/basket2010.dta", replace

******************************************************************************************

** 2012

u "$input/MEX/gastos2012_1.dta", replace
append using "$input/MEX/gastos2012_2.dta"

gen FOLIO = folioviv + foliohog
rename clave CLAVE
rename gasto_tri GAS_TRI

gen year = 2012

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
drop if categ == "T"
destring numb, replace

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
drop if categ == "T"
destring numb, replace

* food
gen food_home_nd = (categ == "A" &  numb <=238 & numb!=.)
gen tobacco_nd =  (categ == "A" &  numb >=239 & numb <= 242)
gen food_outhome_serv = (categ == "A" &  numb >=243 & numb <= 247)

* public transport
gen transport_pub_serv =  (categ == "B" &  numb >=1 & numb <= 7)

*house mantainance goods (durab are e.g. detergent): nd:nondurable; d = durable
gen house_maintgoods_nd =  (categ == "C" &  numb >=1 & numb <= 6)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb >=14 & numb <= 16)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb == 19)

gen house_maintgoods_sd =  (categ == "C" &  numb >=7 & numb <= 13)
replace house_maintgoods_sd = 1 if (categ == "C" &  numb >=17 & numb <= 18)

gen house_serv =  (categ == "C" &  numb >=20 & numb <= 24)

* personal care goods (durab are e.g. hairdryer goods)
gen pcare_nd =  (categ == "D" &  numb >=1 & numb <= 18)
replace pcare_nd = 1 if (categ == "D" &  numb ==21)

gen pcare_d =  (categ == "D" &  numb == 19)

gen pcare_serv = (categ == "D" &  numb ==20)
replace pcare_serv = 1 if (categ == "D" &  numb >=22 & numb <=26 )

* educational
gen educ_serv = (categ == "E" &  numb >=1 & numb <= 13)
replace educ_serv = 1 if (categ == "E" &  numb >=18 & numb <= 19)
replace educ_serv = 1 if (categ == "E" &  numb ==21)
gen educ_d = (categ == "E" &  numb >=14 & numb <= 17)
replace educ_d = 1 if (categ == "E" &  numb ==20)

* entretainment
gen ent_d = (categ == "E" &  numb >=22 & numb <= 26)
gen ent_serv = (categ == "E" &  numb >=27 & numb <= 34)

* communication
gen comm_serv = (categ == "F" &  numb >=1 & numb <= 6)

* vehicles
gen fuel_nd = (categ == "F" &  numb >=7 & numb <= 10)
gen vehicles_serv = (categ == "F" &  numb >=11 & numb <= 14)

* housing

gen serv_house = (categ == "G" &  numb >=5 & numb <=8)
replace serv_house = 1 if (categ == "R" &  numb >=1 & numb <=13)

gen tax_rent_house = (categ == "G" &  numb >=1 & numb <=4)
replace tax_rent_house = 1 if (categ == "G" &  numb ==101)

gen combus_nd =  (categ == "G" &  numb >=9 & numb <=16)

* clothing
gen clothes_serv = (categ == "H" &  (numb ==12 | numb==26 | numb == 38 | numb ==54 | numb ==66 | numb ==82 | numb ==120 | numb ==133 | numb ==136) )
gen clothes_sd = (categ == "H" &  numb >=1 & numb <=136 & clothes_serv == 0)

* decoration
gen decor_sd = (categ == "I" &  numb >=1 & numb <=12)
replace decor_sd = 1 if (categ == "I" &  numb >=14 & numb <=22)
replace decor_sd = 1 if (categ == "I" &  numb >=24 & numb <=26)
gen decor_serv = (categ == "I" &  numb ==13)
replace decor_serv = 1 if (categ == "I" &  numb ==23)

* medical
gen medical_serv = (categ == "J" & numb >=1 & numb <=19)
replace medical_serv = 1 if (categ == "J" & numb >= 36 & numb <= 43)
replace medical_serv = 1 if (categ == "J" & numb >= 62 & numb <= 64)
replace medical_serv = 1 if (categ == "J" & numb >= 69 & numb <= 72)

gen medication_nd = (categ == "J" & numb >=20 & numb <=35)
replace medication_nd = 1 if (categ == "J" & numb >=44 & numb <=61)

gen medical_d = (categ == "J" & numb >=65 & numb <=68)

* house equipment
gen heq_serv = (categ == "K" & (numb == 25 | numb == 37))
replace heq_serv = 1 if (categ == "K" & numb ==39)
replace heq_serv = 1 if (categ == "K" & numb ==41)
replace heq_serv = 1 if (categ == "K" & numb ==43)
replace heq_serv = 1 if (categ == "K" & numb ==45)

gen heq_d = (categ == "K" & numb >=1 & numb <=45 & heq_serv == 0)

* entretainment
replace ent_d = 1 if (categ == "L" &  numb >=1 & numb <= 15)
replace ent_d = 1 if (categ == "L" &  numb >=17 & numb <= 21)
replace ent_d = 1 if (categ == "L" &  numb >=23 & numb <= 27)
replace ent_d = 1 if (categ == "L" &  numb == 29)

replace ent_ser = 1 if (categ == "L" &  numb == 16)
replace ent_ser = 1 if (categ == "L" &  numb == 22)
replace ent_ser = 1 if (categ == "L" &  numb == 28)

* transport services
gen transp_serv = (categ == "M" &  numb >= 1 & numb<=6)
gen vehicles_d = (categ == "M" &  numb >= 7 & numb<=13)
replace vehicles_d = 1 if (categ == "M" &  numb >= 15 & numb<=16)
replace vehicles_serv = 1 if (categ == "M" &  numb == 14)
replace vehicles_serv = 1 if (categ == "M" &  numb == 17)
replace vehicles_serv = 1 if (categ == "M" &  numb == 18)

* other expenditures
gen other_serv = (categ == "N" &  numb >= 1 & numb<=10)

* transfers 
gen transfers_all = (categ == "N" &  numb >= 11 & numb<=16)

*** drop erogaciones

drop if categ == "K" & (numb>=38 & numb<=45)

*** tradable and non-tradable; services, transfers, durable and non-durable

gen serv = food_outhome_serv + transport_pub_serv + house_serv + pcare_serv + educ_serv + ent_serv + vehicles_serv ///
  + serv_house + clothes_serv + decor_serv + medical_serv + heq_serv + ent_ser + transp_serv ///
 + other_serv + comm_serv
 replace serv = 1 if serv>0 & serv!=.
 
gen transfers = transfers_all
replace transfers = 1 if transfers>0 & transfers!=.

gen durable = vehicles_d + ent_d + heq_d + medical_d + tax_rent_house  + ent_d + educ_d + pcare_d 
replace durable = 1 if durable>0 & durable!=.
 
gen ndurab = medication_nd + decor_sd + fuel_nd + pcare_nd + house_maintgoods_sd + house_maintgoods_nd + tobacco_nd + food_home_nd + clothes_sd + combus_nd 
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen NT = serv
gen T = durable + ndurab
replace T = 1 if T>0 & T!=.

save "$database/MEX/basket2012.dta", replace

******************************************************************************************

** 2014

u "$input/MEX/gastos2014_1.dta", replace
append using "$input/MEX/gastos2014_2.dta"


gen FOLIO = folioviv + foliohog
rename clave CLAVE
rename gasto_tri GAS_TRI

gen year = 2014

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
drop if categ == "T"
destring numb, replace

keep CLAVE FOLIO GAS_TRI

gen categ = substr(CLAVE,1,1) 
gen numb = substr(CLAVE,2,.) 
drop if categ == "T"
destring numb, replace

* food
gen food_home_nd = (categ == "A" &  numb <=238 & numb!=.)
gen tobacco_nd =  (categ == "A" &  numb >=239 & numb <= 242)
gen food_outhome_serv = (categ == "A" &  numb >=243 & numb <= 247)

* public transport
gen transport_pub_serv =  (categ == "B" &  numb >=1 & numb <= 7)

*house mantainance goods (durab are e.g. detergent): nd:nondurable; d = durable
gen house_maintgoods_nd =  (categ == "C" &  numb >=1 & numb <= 6)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb >=14 & numb <= 16)
replace house_maintgoods_nd = 1 if (categ == "C" &  numb == 19)

gen house_maintgoods_sd =  (categ == "C" &  numb >=7 & numb <= 13)
replace house_maintgoods_sd = 1 if (categ == "C" &  numb >=17 & numb <= 18)

gen house_serv =  (categ == "C" &  numb >=20 & numb <= 24)

* personal care goods (durab are e.g. hairdryer goods)
gen pcare_nd =  (categ == "D" &  numb >=1 & numb <= 18)
replace pcare_nd = 1 if (categ == "D" &  numb ==21)

gen pcare_d =  (categ == "D" &  numb == 19)

gen pcare_serv = (categ == "D" &  numb ==20)
replace pcare_serv = 1 if (categ == "D" &  numb >=22 & numb <=26 )

* educational
gen educ_serv = (categ == "E" &  numb >=1 & numb <= 13)
replace educ_serv = 1 if (categ == "E" &  numb >=18 & numb <= 19)
replace educ_serv = 1 if (categ == "E" &  numb ==21)
gen educ_d = (categ == "E" &  numb >=14 & numb <= 17)
replace educ_d = 1 if (categ == "E" &  numb ==20)

* entretainment
gen ent_d = (categ == "E" &  numb >=22 & numb <= 26)
gen ent_serv = (categ == "E" &  numb >=27 & numb <= 34)

* communication
gen comm_serv = (categ == "F" &  numb >=1 & numb <= 6)

* vehicles
gen fuel_nd = (categ == "F" &  numb >=7 & numb <= 10)
gen vehicles_serv = (categ == "F" &  numb >=11 & numb <= 14)

* housing

gen serv_house = (categ == "G" &  numb >=5 & numb <=8)
replace serv_house = 1 if (categ == "R" &  numb >=1 & numb <=13)

gen tax_rent_house = (categ == "G" &  numb >=1 & numb <=4)
replace tax_rent_house = 1 if (categ == "G" &  numb ==101)

gen combus_nd =  (categ == "G" &  numb >=9 & numb <=16)

* clothing
gen clothes_serv = (categ == "H" &  (numb ==12 | numb==26 | numb == 38 | numb ==54 | numb ==66 | numb ==82 | numb ==120 | numb ==133 | numb ==136) )
gen clothes_sd = (categ == "H" &  numb >=1 & numb <=136 & clothes_serv == 0)

* decoration
gen decor_sd = (categ == "I" &  numb >=1 & numb <=12)
replace decor_sd = 1 if (categ == "I" &  numb >=14 & numb <=22)
replace decor_sd = 1 if (categ == "I" &  numb >=24 & numb <=26)
gen decor_serv = (categ == "I" &  numb ==13)
replace decor_serv = 1 if (categ == "I" &  numb ==23)

* medical
gen medical_serv = (categ == "J" & numb >=1 & numb <=19)
replace medical_serv = 1 if (categ == "J" & numb >= 36 & numb <= 43)
replace medical_serv = 1 if (categ == "J" & numb >= 62 & numb <= 64)
replace medical_serv = 1 if (categ == "J" & numb >= 69 & numb <= 72)

gen medication_nd = (categ == "J" & numb >=20 & numb <=35)
replace medication_nd = 1 if (categ == "J" & numb >=44 & numb <=61)

gen medical_d = (categ == "J" & numb >=65 & numb <=68)

* house equipment
gen heq_serv = (categ == "K" & (numb == 25 | numb == 37))
replace heq_serv = 1 if (categ == "K" & numb ==39)
replace heq_serv = 1 if (categ == "K" & numb ==41)
replace heq_serv = 1 if (categ == "K" & numb ==43)
replace heq_serv = 1 if (categ == "K" & numb ==45)

gen heq_d = (categ == "K" & numb >=1 & numb <=45 & heq_serv == 0)

* entretainment
replace ent_d = 1 if (categ == "L" &  numb >=1 & numb <= 15)
replace ent_d = 1 if (categ == "L" &  numb >=17 & numb <= 21)
replace ent_d = 1 if (categ == "L" &  numb >=23 & numb <= 27)
replace ent_d = 1 if (categ == "L" &  numb == 29)

replace ent_ser = 1 if (categ == "L" &  numb == 16)
replace ent_ser = 1 if (categ == "L" &  numb == 22)
replace ent_ser = 1 if (categ == "L" &  numb == 28)

* transport services
gen transp_serv = (categ == "M" &  numb >= 1 & numb<=6)
gen vehicles_d = (categ == "M" &  numb >= 7 & numb<=13)
replace vehicles_d = 1 if (categ == "M" &  numb >= 15 & numb<=16)
replace vehicles_serv = 1 if (categ == "M" &  numb == 14)
replace vehicles_serv = 1 if (categ == "M" &  numb == 17)
replace vehicles_serv = 1 if (categ == "M" &  numb == 18)

* other expenditures
gen other_serv = (categ == "N" &  numb >= 1 & numb<=10)

* transfers 
gen transfers_all = (categ == "N" &  numb >= 11 & numb<=16)

*** drop erogaciones

drop if categ == "K" & (numb>=38 & numb<=45)

*** tradable and non-tradable; services, transfers, durable and non-durable

gen serv = food_outhome_serv + transport_pub_serv + house_serv + pcare_serv + educ_serv + ent_serv + vehicles_serv ///
  + serv_house + clothes_serv + decor_serv + medical_serv + heq_serv + ent_ser + transp_serv ///
 + other_serv + comm_serv
 replace serv = 1 if serv>0 & serv!=.
 
gen transfers = transfers_all
replace transfers = 1 if transfers>0 & transfers!=.

gen durable = vehicles_d + ent_d + heq_d + medical_d + tax_rent_house  + ent_d + educ_d + pcare_d 
replace durable = 1 if durable>0 & durable!=.
 
gen ndurab = medication_nd + decor_sd + fuel_nd + pcare_nd + house_maintgoods_sd + house_maintgoods_nd + tobacco_nd + food_home_nd + clothes_sd + combus_nd 
replace ndurab = 1 if ndurab>0 & ndurab!=.

gen NT = serv
gen T = durable + ndurab
replace T = 1 if T>0 & T!=.

save "$database/MEX/basket2014.dta", replace
