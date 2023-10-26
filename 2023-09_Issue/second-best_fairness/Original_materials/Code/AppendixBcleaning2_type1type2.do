********************************************************************************
* Title:   Cleaning and defining variables for analysis in Appendix B
* Descrip: The code imports, cleans, defines variable for subsequent analysis,   
*          and appends four datasets: usa2019raw, norway2019raw, usa2015raw, and 
*          norway2015raw. The 2019 datasets correspond to Study 1 and the 2015 
*          datasets correspond to Study 2 in Appendix B.
********************************************************************************
clear all 
set more off


********************************************************************************
**#1. CLEANING USA 2019
********************************************************************************
use ../Data/Raw_Data/usa2019_raw.dta, clear

*BACKGROUND VAR
rename Q1 male
recode male (2=0)
label define gender 1 "Male" 0 "Female"
label values male gender 

rename Q2 age
rename Q4 incomeusa1
rename Q5 educationusa1
rename Q6 politicalusa1
rename Q2_2 inequalityusa1

*INDEPENDENT VAR
rename Quota treatment 
gen treat1=0
replace treat1=1 if treatment==5
gen treat2=0
replace treat2=1 if treatment==4
gen treat3=0
replace treat3=1 if treatment==3
gen treat4=0
replace treat4=1 if treatment==2
gen treat5=0
replace treat5=1 if treatment==1

*DEPENDENT VAR
gen pay=0
replace pay=1 if Q1a==2
replace pay=1 if Q1b==2
replace pay=1 if Q1c==2
replace pay=1 if Q1d==2
replace pay=1 if Q1e==2

*BACKGROUND DUMMIES
* low income = below $60,000
gen incomelow=0
replace incomelow=1 if incomeusa1<6

* low education = those who do not have a college degree (below Associates' degree in the case of US)
gen educationlow=0
replace educationlow=1 if educationusa1<4

* rightwing = voting for the republican party 
gen rightwing=0
replace rightwing=1 if politicalusa1==1

* low age = below median age 
preserve 
replace age=. if age>100
sum age, detail 
restore

gen agelow=0
replace agelow=1 if age<40

* gen var to identify US
gen US=1

drop age_group Q3 Q1a Q1b Q1c Q1d Q1e 

save ../Data/Processed_Data/usa2019.dta, replace 

********************************************************************************
**#.2 CLEANING NORWAY 2019
********************************************************************************
clear all
use ../Data/Raw_Data/norway2019_raw.dta, clear 

*BACKGROUND VAR
rename gender male
recode male (2=0)
label define gender1 1 "Male" 0 "Female"
label values male gender1

rename Q2 inequalitynor1
label define ineqnor 1 "Svært enig" 2 "Enig" 3 "Noe enig" 4 "Hverken enig eller uenig" 5 "Noe uenig" 6 "Uenig" 7 "Svært uenig"
label values inequalitynor1 ineqnor  

rename Q3 incomenor1

rename Q4 educationnor1
label define education 1 "Deler av videreg�ende skole" 2 "Videregående" 3 "Et eller to �r p� fagskole, h�yskole el" 4 "Tre �rig h�yskole- eller universitetsgr" 5 "Fire�rig h�yskole- eller universitetsgr" 6 "5 eller 6-�rig profesjonsstudium" 7 "Mastergrad / Hovedfag" 8 "Doktorgrad" 9 "Ingen av alternativene over"
label values educationnor1 education

rename Q5 politicalnor1
label define polnor 1 "R�dt" 2 "Mdg" 3 "SV" 4 "Ap" 5 "Venstre" 6 "Sp" 7 "KrF" 8 "H�yre" 9 "Frp" 10 "Kystpartiet" 11 "Andre:" 12 "Ville ikke stemme" 13 "Vil ikke si" 14 "Ikke sikker" 15 "Har ikke stemmerett"
label values politicalnor1 polnor 


*INDEPENDENT VAR
rename Quota treatment 
gen treat1=0
replace treat1=1 if treatment==5
gen treat2=0
replace treat2=1 if treatment==4
gen treat3=0
replace treat3=1 if treatment==3
gen treat4=0
replace treat4=1 if treatment==2
gen treat5=0
replace treat5=1 if treatment==1

*DEPENDENT VAR
gen pay=0
replace pay=1 if Q1a==2
replace pay=1 if Q1b==2
replace pay=1 if Q1c==2
replace pay=1 if Q1d==2
replace pay=1 if Q1e==2

*BACKGROUND DUMMIES
* low income = below NOK600,000
gen incomelow=0
replace incomelow=1 if incomenor1<7

* low education = those who do not have a college degree (below three-year of tertiary education in the case of Norway)
gen educationlow=0
replace educationlow=1 if educationnor1<4

* rightwing = voting for hooyre or frp
gen rightwing=0
replace rightwing=1 if politicalnor1==9
replace rightwing=1 if politicalnor1==8

* low age = below median age 
preserve 
drop if age>100
sum age, detail 
restore

gen agelow=0
replace agelow=1 if age<46


drop age_group AVQ Q1a Q1b Q1c Q1d Q1e

save ../Data/Processed_Data/norway2019.dta, replace 

********************************************************************************
**#3. APPENDING USA AND NORWAY 2019
********************************************************************************
clear all
use ../Data/Processed_Data/usa2019.dta, clear 
append using ../Data/Processed_Data/norway2019.dta

replace US=0 if US==.
gen study1=1

save ../Data/Processed_Data/data2019.dta, replace 

********************************************************************************
**#4. CLEANING USA 2015
********************************************************************************
clear all 
use ../Data/Raw_Data/usa2015_raw.dta, clear

*BACKGROUND VAR 
destring qAgenderPleaseindicateyo, gen(male)
recode male (2=0)
label define gender 1 "Male" 0 "Female"
label values male gender 

rename qBagePleaseindicateyour age

destring qDqDPleasestateyourannu, gen(incomeusa2)
recode incomeusa2 (99=14)
label define income1 1 "Under $20,000" 2 " $20,000 to $29,999" 3 "$30,000 to $39,999" 4 "$40,000 to $49,999" 5 "$50,000 to $59,999" 6 "$60,000 to $69,999" 7 "$70,000 to $79,999" 8 " $80,000 to $89,999" 9 "$90,000 to $99,999" 10 "$100,000 to $119,999" 11 "$120,000 to $149,999" 12 "$150,000 to $199,999" 13 "Over $200,000" 14 "Would rather not say"
label values incomeusa2 income1 

destring qEqEIftherewasapreside, gen(politicalusa2)
label define political1 1 "The Republican Party" 2 "The Democratic Party" 3 "A third party" 4 "Do not want to answer" 5 "Do not know" 6 "Not eligible to vote"
label values politicalusa2 political1 

destring qFqFWhatisyourhighestc, gen(educationusa2)
recode educationusa2 (99=9)
label define educ1 1 "Completed some high school" 2 "High school graduate or GED equivalent" 3 "Completed some college" 4 "Associates degree" 5 "College degree" 6 "Completed some postgraduate" 7 "Master's degree" 8 "Doctorate degree" 9 "None of the above"
label values educationusa2 educ1

destring q2q2Towhatextentdoyou, gen(inequalityusa2)
label define ineq1 1 "Strongly Agree" 2 "Agree" 3 "Mildly Agree" 4 "Neither Agree nor Disagree" 5 "Mildly Disagree" 6 "Disagree" 7 "Strongly Disagree"
label values inequalityusa2 ineq1 

*INDEPENDENT VAR
destring h_groupHIDDENGroup, gen(treatment)

label define treat 1 "1a Treatment" 2 "1b Treatment" 3 "1c Treatment" 4 "1d Treatment" 5 "1e Treatment"
label values treatment treat1

gen treat1=0
replace treat1=1 if treatment==1
gen treat2=0
replace treat2=1 if treatment==2
gen treat3=0
replace treat3=1 if treatment==3
gen treat4=0
replace treat4=1 if treatment==4
gen treat5=0
replace treat5=1 if treatment==5

foreach var in g1g1Incontrasttotraditi g2g2Incontrasttotraditi g3g3Incontrasttotraditi g4g4Incontrasttotraditi g5g5Incontrasttotraditi {
    destring `var', gen(`var'_)
}

*DEPENDENT VAR
gen pay=0
replace pay=1 if g1g1Incontrasttotraditi_==2
replace pay=1 if g2g2Incontrasttotraditi_==2
replace pay=1 if g3g3Incontrasttotraditi_==2
replace pay=1 if  g4g4Incontrasttotraditi_==2
replace pay=1 if g5g5Incontrasttotraditi_==2

*BACKGROUND DUMMIES
* low income = below $60,000
gen incomelow=0
replace incomelow=1 if incomeusa2<6

* low education = those who do not have a college degree (below Associates' degree in the case of US)
gen educationlow=0
replace educationlow=1 if educationusa2<4

* rightwing = voting for the republican party 
gen rightwing=0
replace rightwing=1 if politicalusa2==1

* low age = below median age 
preserve 
replace age=. if age>100
sum age, detail 
restore

gen agelow=0
replace agelow=1 if age<45

*US
gen US=1

drop qAgenderPleaseindicateyo qCstateWheredoyoulive ABBRHIDDENWheredoyouliv h_ageHIDDENPleaseindicate regionHIDDENWheredoyoul qDqDPleasestateyourannu qEqEIftherewasapreside h_groupHIDDENGroup g1g1Incontrasttotraditi g2g2Incontrasttotraditi g3g3Incontrasttotraditi g4g4Incontrasttotraditi g5g5Incontrasttotraditi q2q2Towhatextentdoyou g1g1Incontrasttotraditi_ g2g2Incontrasttotraditi_ g3g3Incontrasttotraditi_ g4g4Incontrasttotraditi_ g5g5Incontrasttotraditi_ qFqFWhatisyourhighestc

save ../Data/Processed_Data/usa2015.dta, replace 

********************************************************************************
**#5. CLEANING NORWAY 2015
********************************************************************************
clear all 

use ../Data/Raw_Data/norway2015_raw.dta, clear

rename Alder age

*BACKGROUND VAR 
gen male=0
replace male=1 if q215== "Mann"

label define gender1 1 "Male" 0 "Female"
label values male gender1

gen incomenor2=.
replace incomenor2= 1 if NO_household_income=="0-100.000 NOK" 
replace incomenor2= 11 if NO_household_income=="1.000.001-1.100.000 NOK" 
replace incomenor2= 12 if NO_household_income=="1.100.001-1.200.000 NOK"
replace incomenor2= 13 if NO_household_income=="1.200.001-1.300.000 NOK"
replace incomenor2= 14 if NO_household_income=="1.300.001-1.400.000 NOK"
replace incomenor2= 15 if NO_household_income=="1.400.001-1.500.000 NOK"
replace incomenor2= 16 if NO_household_income=="1.500.001 NOK eller mer" 
replace incomenor2= 2 if NO_household_income=="100.001-200.000 NOK" 
replace incomenor2= 3 if NO_household_income=="200.001-300.000 NOK" 
replace incomenor2= 4 if NO_household_income=="300.001-400.000 NOK" 
replace incomenor2= 5 if NO_household_income=="400.001-500.000 NOK" 
replace incomenor2= 6 if NO_household_income=="500.001-600.000 NOK" 
replace incomenor2= 7 if NO_household_income=="600.001-700.000 NOK" 
replace incomenor2= 8 if NO_household_income=="700.001-800.000 NOK" 
replace incomenor2= 9 if NO_household_income=="800.001-900.000 NOK" 
replace incomenor2= 10 if NO_household_income=="900.001-1.000.000 NOK" 
replace incomenor2= 17 if NO_household_income== "Vet ikke"
replace incomenor2= 18 if NO_household_income== "Vil ikke svare"
label define income 1 "0-100.000 NOK" 2 "100.001-200.000 NOK" 3 "200.001-300.000 NOK" 4 "300.001-400.000 NOK"  5 "400.001-500.000 NOK" 6 "500.001-600.000 NOK" 7 "600.001-700.000 NOK" 8 "700.001-800.000 NOK" 9 "800.001-900.000 NOK" 10 "900.001-1.000.000 NOK" 11 "1.000.001-1.100.000 NOK" 12 "1.100.001-1.200.000 NOK"13 "1.200.001-1.300.000 NOK"14 "1.300.001-1.400.000 NOK"15 "1.400.001-1.500.000 NOK"16 "1.500.001 NOK eller mer" 17  "Vet ikke"18  "Vil ikke svare"
label values incomenor2 income 

gen politicalnor2=0
replace politicalnor2=1 if p1== "Rødt"
replace politicalnor2=2 if p1== "Mdg"
replace politicalnor2=3 if p1== "SV"
replace politicalnor2=4 if p1== "Ap"
replace politicalnor2=5 if p1== "Venstre"
replace politicalnor2=6 if p1== "Sp"
replace politicalnor2=7 if p1== "KrF"
replace politicalnor2=8 if p1== "Høyre"
replace politicalnor2=9 if p1== "Frp"
replace politicalnor2=10 if p1== "Kystpartiet"
replace politicalnor2=11 if p1== "Andre:"
replace politicalnor2=12 if p1== "Ville ikke stemme"
replace politicalnor2=13 if p1== "Vil ikke si"
replace politicalnor2=14 if p1== "Ikke sikker"
replace politicalnor2=15 if p1== "Har ikke stemmerett"
label define polnor 1 "R�dt" 2 "Mdg" 3 "SV" 4 "Ap" 5 "Venstre" 6 "Sp" 7 "KrF" 8 "H�yre" 9 "Frp" 10 "Kystpartiet" 11 "Andre:" 12 "Ville ikke stemme" 13 "Vil ikke si" 14 "Ikke sikker" 15 "Har ikke stemmerett"
label values politicalnor2 polnor 

gen inequalitynor2=0
replace inequalitynor2=3 if NOHNO38236_2== "Noe enig"
replace inequalitynor2=4 if NOHNO38236_2== "Hverken enig eller uenig"
replace inequalitynor2=2 if NOHNO38236_2== "Enig"
replace inequalitynor2=1 if NOHNO38236_2== "Svært enig"
replace inequalitynor2=5 if NOHNO38236_2== "Noe uenig"
replace inequalitynor2=6 if NOHNO38236_2== "Uenig"
replace inequalitynor2=7 if NOHNO38236_2== "Svært uenig"
label define ineqnor 1 "Svært enig" 2 "Enig" 3 "Noe enig" 4 "Hverken enig eller uenig" 5 "Noe uenig" 6 "Uenig" 7 "Svært uenig"
label values inequalitynor2 ineqnor

gen educationnor2=0
replace educationnor2=1 if NO_educationLevel== "Grunnskole"
replace educationnor2=2 if NO_educationLevel== "Videregående"
replace educationnor2=3 if NO_educationLevel== "Universitet-/høyskole 1-3 år (Bachelor eller tilsvarende)"
replace educationnor2=4 if NO_educationLevel== "Universitet-/høyskole 4 år + (Master eller tilsvarende)"
replace educationnor2=5 if NO_educationLevel== "Universitet-/høyskole 5 år + (Doktorgrad eller tilsvarende)"
replace educationnor2=6 if NO_educationLevel== "Annet"
label define education2 1 "Grunnskole" 2 "Videregående" 3 "Universitet-/høyskole 1-3 år (Bachelor eller tilsvarende)" 4 "Universitet-/høyskole 4 år + (Master eller tilsvarende)" 5 "Universitet-/høyskole 5 år + (Doktorgrad eller tilsvarende)" 6 "Annet"
label values educationnor2 education2

*INDEPENDENT VAR
gen treatment=0
replace treatment=1 if rotatenohno== "Gruppe 1"
replace treatment=2 if rotatenohno== "Gruppe 2"
replace treatment=3 if rotatenohno== "Gruppe 3"
replace treatment=4 if rotatenohno== "Gruppe 4"
replace treatment=5 if rotatenohno== "Gruppe 5"
label define treatt 1 "1a Treatment" 2 "1b Treatment" 3 "1c Treatment" 4 "1d Treatment" 5 "1e Treatment"
label values treatment treatt

gen treat1=0
replace treat1=1 if treatment==1
gen treat2=0
replace treat2=1 if treatment==2
gen treat3=0
replace treat3=1 if treatment==3
gen treat4=0
replace treat4=1 if treatment==4
gen treat5=0
replace treat5=1 if treatment==5

gen t1=substr(NOHNO38236_1a,1,12)
gen t2=substr(NOHNO38236_1b,1,12)
gen t3=substr(NOHNO38236_1c,1,12)
gen t4=substr(NOHNO38236_1d,1,12)
gen t5=substr(NOHNO38236_1e,1,12)

*DEPENDENT VAR
gen pay=0
replace pay=1 if t1== "Alternativ B"
replace pay=1 if t2== "Alternativ B"
replace pay=1 if t3== "Alternativ B"
replace pay=1 if t4== "Alternativ B"
replace pay=1 if t5== "Alternativ B"

*BACKGROUND DUMMIES
* income low = below 700,000
gen incomelow=0
replace incomelow=1 if incomenor2<7

* low education = those who do not have a college degree (below three-year of tertiary education in the case of Norway)
gen educationlow=0
replace educationlow=1 if educationnor2<3

* rightwing = voting for hoyre or frp
gen rightwing=0
replace rightwing=1 if politicalnor2== 8
replace rightwing=1 if politicalnor2== 9

* age low = below median age 
sum age, detail 

gen agelow=0
replace agelow=1 if age<49.5

drop Alder_koder q215 NO_city_size household_size childage_1 childage_2 childage_3 childage_4 childage_5 no_occupation no_profession work_sector rotatenohno civil_status NOHNO38236_1a NOHNO38236_1b NOHNO38236_1c NOHNO38236_1d NOHNO38236_1e NO_educationLevel NO_household_income household_children_u18 p1_12_other NOHNO38236_2 p1
drop t1 t2 t3 t4 t5 

save ../Data/Processed_Data/norway2015.dta, replace

********************************************************************************
**#6. APPENDING USA AND NORWAY 2015
********************************************************************************
clear all
append using ../Data/Processed_Data/usa2015.dta ../Data/Processed_Data/norway2015.dta

replace US=0 if US==.

save ../Data/Processed_Data/data2015.dta, replace 

********************************************************************************
**#7. APPENDING 2015 AND 2019 AND CREATING\LABELLING ANALYSIS-RELEVANT VARIABLES 
********************************************************************************
clear all 
append using ../Data/Processed_Data/data2015.dta ../Data/Processed_Data/data2019.dta

replace study1=0 if study1==.

label var treat1 "0 percent"
label var treat2 "25 percent"
label var treat3 "50 percent"
label var treat4 "75 percent"
label var treat5 "100 percent"
label var male "Male"
label var incomelow "low income"
label var educationlow "Low education"
label var agelow "Low age"
label var rightwing "Right-wing"

drop weight 

save ../Data/Processed_Data/study20152019.dta, replace 


*interaction rightwing and treatments
gen rightwing_treat2 = rightwing*treat2
gen rightwing_treat3 = rightwing*treat3 
gen rightwing_treat4 = rightwing*treat4 
gen rightwing_treat5 = rightwing*treat5

*standardized equalize: answer to the statement "The state should help reduce income inequalities in society"
gen shouldequalize=inequalityusa1
replace shouldequalize=inequalityusa2 if shouldequalize==. 
replace shouldequalize=inequalitynor1 if shouldequalize==. 
replace shouldequalize=inequalitynor2 if shouldequalize==. 
recode shouldequalize (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1)

gen zshould=(shouldequalize-4.978755)/1.789078

*paying where prob of false claim/share filing a false claim is 50 percent 
gen falsenegative = pay if treat3==1
label var falsenegative "False negative averse"

save ../Data/Processed_Data/analysis_20152019.dta, replace 



