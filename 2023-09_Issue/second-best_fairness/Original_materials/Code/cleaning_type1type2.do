********************************************************************************
* Title:   Cleaning and defining variables for analysis
* Descrip: The first part of the code merges the Norwegian and the American 
*          datasets, drops non-relevant variables, and labels the rest of the
*          variables. The second part of the CODE defines the variables for 
*          the analysis, rescales the population weights and cleans the final
*          dataset. 
********************************************************************************
clear all
set more off 

********************************************************************************
**#1. APPENDING, DROPPING AND LABELLING VARS
********************************************************************************
*APPEND
append using  ../Data/Raw_Data/surveyusa.dta ../Data/Raw_Data/surveynorway.dta

*DROP
drop h_changes hprocents_1r1 hprocents_1r2 TSpentPT_1r1 TSpentPT_1r2 TSpentPT_1r3 TSpentPT_1r4 TSpentPT_1r5 TSpentPT_1r6 hprocents_2r2 hprocents_2r2 TSpentPT_2r1 TSpentPT_2r2 TSpentPT_2r3 TSpentPT_2r4 TSpentPT_2r5 TSpentPT_2r6 hprocents_3r1 hprocents_3r2 TSpentPT_3r1 TSpentPT_3r2 TSpentPT_3r3 TSpentPT_3r4 TSpentPT_3r5 TSpentPT_3r6 hprocents_4r1 hprocents_4r2 TSpentPT_4r1 TSpentPT_4r2 TSpentPT_4r3 TSpentPT_4r4 TSpentPT_4r5 TSpentPT_4r6 hprocents_5r1 hprocents_5r2 TSpentPT_5r1 TSpentPT_5r2 TSpentPT_5r3 TSpentPT_5r4 TSpentPT_5r5 TSpentPT_5r6 hprocents_6r1 hprocents_6r2 TSpentPT_6r1 TSpentPT_6r2 TSpentPT_6r3 TSpentPT_6r4 TSpentPT_6r5 TSpentPT_6r6 hprocents_7r1 hprocents_7r2 TSpentPT_7r1 TSpentPT_7r2 TSpentPT_7r3 TSpentPT_7r4 TSpentPT_7r5 TSpentPT_7r6 hprocents_8r1 hprocents_8r2 TSpentPT_8r1 TSpentPT_8r2 TSpentPT_8r3 TSpentPT_8r4 TSpentPT_8r5 TSpentPT_8r6 hprocents_9r1 hprocents_9r2 TSpentPT_9r1 TSpentPT_9r2 TSpentPT_9r3 TSpentPT_9r4 TSpentPT_9r5 TSpentPT_9r6 hprocents_10r1 hprocents_10r2 TSpentPT_10r1 TSpentPT_10r2 TSpentPT_10r3 TSpentPT_10r4 TSpentPT_10r5 TSpentPT_10r6 hprocents_11r1 hprocents_11r2 TSpentPT_11r1 TSpentPT_11r2 TSpentPT_11r3 TSpentPT_11r4 TSpentPT_11r5 TSpentPT_11r6 hprocents_12r1 hprocents_12r2 TSpentPT_12r1 TSpentPT_12r2 TSpentPT_12r3 TSpentPT_12r4 TSpentPT_12r5 TSpentPT_12r6 hprocents_13r1 hprocents_13r2 TSpentPT_13r1 TSpentPT_13r2 TSpentPT_13r3 TSpentPT_13r4 TSpentPT_13r5 TSpentPT_13r6 hprocents_14r1 hprocents_14r2 TSpentPT_14r1 TSpentPT_14r2 TSpentPT_14r3 TSpentPT_14r4 TSpentPT_14r5 TSpentPT_14r6 hprocents_15r1 hprocents_15r2 TSpentPT_15r1 TSpentPT_15r2 TSpentPT_15r3 TSpentPT_15r4 TSpentPT_15r5 TSpentPT_15r6 hprocents_16r1 hprocents_16r2 TSpentPT_16r1 TSpentPT_16r2 TSpentPT_16r3 TSpentPT_16r4 TSpentPT_16r5 TSpentPT_16r6

drop hprocents_17r1 hprocents_17r2 TSpentPT_17r1 TSpentPT_17r2 TSpentPT_17r3 TSpentPT_17r4 TSpentPT_17r5 TSpentPT_17r6 hprocents_18r1 hprocents_18r2 TSpentPT_18r1 TSpentPT_18r2 TSpentPT_18r3 TSpentPT_18r4 TSpentPT_18r5 TSpentPT_18r6 hprocents_19r1 hprocents_19r2 TSpentPT_19r1 TSpentPT_19r2 TSpentPT_19r3 TSpentPT_19r4 TSpentPT_19r5 TSpentPT_19r6 hprocents_20r1 hprocents_20r2 TSpentPT_20r1 TSpentPT_20r2 TSpentPT_20r3 TSpentPT_20r4 TSpentPT_20r5 TSpentPT_20r6 hprocents_21r1 hprocents_21r2 TSpentPT_21r1 TSpentPT_21r2 TSpentPT_21r3 TSpentPT_21r4 TSpentPT_21r5 TSpentPT_21r6 Q1Treat_20r2 Q1Treat_21r1 h_question TSpentMAINr1 TSpentMAINr2 TSpentMAINr3 TSpentMAINr4 TSpentMAINr5 TSpentMAINr6 TSpentMAINr7 TSpentMAINr8 TSpentMAINr9 TSpentMAINr10 TSpentMAINr11 TSpentMAINr12 TSpentMAINr13 base  

drop Q1Treat_1r1 Q1Treat_1r2 hprocents_2r1 Q1Treat_2r1 Q1Treat_2r2 Q1Treat_3r1 Q1Treat_3r2 Q1Treat_4r1 Q1Treat_4r2 Q1Treat_5r1 Q1Treat_5r2 Q1Treat_6r1 Q1Treat_6r2 Q1Treat_7r1 Q1Treat_7r2 Q1Treat_8r1 Q1Treat_8r2 Q1Treat_9r1 Q1Treat_9r2 Q1Treat_10r1 Q1Treat_10r2 Q1Treat_11r1 Q1Treat_11r2 Q1Treat_12r1 Q1Treat_12r2 Q1Treat_13r1 Q1Treat_13r2 Q1Treat_14r1 Q1Treat_14r2 Q1Treat_15r1 Q1Treat_15r2 Q1Treat_16r1 Q1Treat_16r2 Q1Treat_17r1 Q1Treat_17r2 Q1Treat_18r1 Q1Treat_18r2 Q1Treat_19r1 Q1Treat_19r2 Q1Treat_20r1 Q1Treat_21r2 h_Q5ab age_group age_group2 QA1

*RENAME
rename Q6 maleusa
rename Q7 ageusa
rename Q9 incomeusa
rename Q10 educusa

rename age agenorway 
rename gender malenorway 
rename Q25 incomenorway
rename Q2x2 educnorway 

*LABEL
label var Q2Treat_1 "Do not pay/pay the compensation 100% probability correct claim"
label var Q2Treat_2 "Do not pay/pay the compensation 75% probability correct claim"
label var Q2Treat_3 "Do not pay/pay the compensation 50% probability correct claim"
label var Q2Treat_4 "Do not pay/pay the compensation 25% probability correct claim"
label var Q2Treat_5 "Do not pay/pay the compensation 0% probability correct claim"
label var Q2Treat_6 "Do not pay/pay the compensation 50% probability correct claim - National labor market service"
label var Q2Treat_7 "Do not pay/pay the compensation 50% probability correct claim - High stakes"
label var Q2Treat_8 "Do not pay/pay the compensation 50% probability correct claim - spectator paid 1USD"
label var Q2Treat_9 "Do not pay/pay the compensation 50% probability correct claim - spectator paid 1USD + 10cents cost"
label var Q2Treat_10 "Do not pay/pay the compensation 50% probability correct claim - spectator paid 1USD + 30cents cost"
label var Q2Treat_11 "Do not pay/pay the unemployment benefits 100% probability correct claim"
label var Q2Treat_12 "Do not pay/pay the unemployment benefits 75% probability correct claim"
label var Q2Treat_13 "Do not pay/pay the unemployment benefits 50% probability correct claim"
label var Q2Treat_14 "Do not pay/pay the unemployment benefits 25% probability correct claim"
label var Q2Treat_15 "Do not pay/pay the unemployment benefits 0% probability correct claim"
label var Q2Treat_16 "Do not pay/pay the earnings 100% probability correct claim"
label var Q2Treat_17 "Do not pay/pay the earnings 75% probability correct claim"
label var Q2Treat_18 "Do not pay/pay the earnings 50% probability correct claim"
label var Q2Treat_19 "Do not pay/pay the earnings 25% probability correct claim"
label var Q2Treat_20 "Do not pay/pay the earnings 0% probability correct claim"
label var Q2Treat_21 "Do not pay/pay the disability benefits 50% probability correct claim"
label var Q3r1 "USA more generous unemp. benefits"
label var Q3r2 "USA unemp. not fully compensated"
label var Q3r3 "USA unemp. benefits hurt the economy"
label var Q3r4 "USA gov. helps reduce income inequality"
label var Q3r5 "USA unfair some people have higher income"
label var Q3r6 "USA income redistribution hurt economy"
label var Q3br1 "USA more generous disability benefits"
label var Q3br2 "USA disabled not fully compensated"
label var Q3br3 "USA disability benefits hurt the economy"
label var Q4 "USA willingness to give without expecting anything in return"
label var Q4b "USA rate happiness from 0 to 10"
label var Q5 "USA importance of religion"
label var Q5a "USA gov. supports females who fall behind in educ. in labor market"
label var Q5b "USA gov. supports males who fall behind in educ. in labor market"
label var incomeusa "USA annual income"
label var educusa "USA highest achieved level of education"
label var Q11 "USA political orientation"
label var Q22r1 "Norway more generous unemp. benefits"
label var Q22r2 "Norway unemp. not fully compensated"
label var Q22r3 "Norway unemp. benefits hurt the economy"
label var Q22r4 "Norway gov. helps reduce income inequality"
label var Q22r5 "Norway unfair some people have higher income"
label var Q22r6 "Norway income redistribution hurt economy"
label var Q22br1 "Norway more generous disability benefits"
label var Q22br2 "Norway disabled not fully compensated"
label var Q22br3 "Norway disability benefits hurt the economy"
label var Q23 "Norway willingness to give without expecting anything in return"
label var Q24 "Norway importance of religion"
label var Q21b "Norway rate happiness from 0 to 10"
label var incomenorway "Norway annual income"
label var educnorway  "Norway highest achieved level of education"
label var Q3x2 "Norway political orientation"
label var weight "population weights"

label define male 1 "male" 2 "female"
label values maleusa male 

label define mann 1 "male" 2 "female"
label values malenorway male 

save ../Data/Processed_Data/studydata.dta, replace 

********************************************************************************
**#2. DEFINE VARS
********************************************************************************
clear all
set more off

use ../Data/Processed_Data/studydata.dta, clear


*DEPENDENT VAR							 
gen pay=0
replace pay=1 if Q2Treat_1==2
replace pay=1 if Q2Treat_2==2
replace pay=1 if Q2Treat_3==2
replace pay=1 if Q2Treat_4==2
replace pay=1 if Q2Treat_5==2
replace pay=1 if Q2Treat_6==2
replace pay=1 if Q2Treat_7==2
replace pay=1 if Q2Treat_8==2
replace pay=1 if Q2Treat_9==2
replace pay=1 if Q2Treat_10==2
replace pay=1 if Q2Treat_11==2
replace pay=1 if Q2Treat_12==2
replace pay=1 if Q2Treat_13==2
replace pay=1 if Q2Treat_14==2
replace pay=1 if Q2Treat_15==2
replace pay=1 if Q2Treat_16==2
replace pay=1 if Q2Treat_17==2
replace pay=1 if Q2Treat_18==2
replace pay=1 if Q2Treat_19==2
replace pay=1 if Q2Treat_20==2
replace pay=1 if Q2Treat_21==2

*INDEPENDENT VARS							 
*main explanatory 
gen probability=0.5
replace probability=0 if h_treatment==1
replace probability=0 if h_treatment==11
replace probability=0 if h_treatment==16
replace probability=0.25 if h_treatment==2
replace probability=0.25 if h_treatment==12
replace probability=0.25 if h_treatment==17
replace probability=0.75 if h_treatment==4
replace probability=0.75 if h_treatment==14
replace probability=0.75 if h_treatment==19
replace probability=1 if h_treatment==5
replace probability=1 if h_treatment==15
replace probability=1 if h_treatment==20

gen prob0=0
replace prob0=1 if probability==0

gen prob25=0
replace prob25=1 if probability==0.25

gen prob50=0
replace prob50=1 if probability==0.5

gen prob75=0
replace prob75=1 if probability==0.75

gen prob100=0
replace prob100=1 if probability==1

*experiments 
gen compensation=0
replace compensation=1 if h_treatment<11

gen unemployment=0
replace unemployment=1 if h_treatment>10 & h_treatment<16

gen replication=0
replace replication=1 if h_treatment>15 & h_treatment<21

gen disability=0
replace disability=1 if h_treatment==21

*additional treatments
gen national=0
replace national=1 if h_treatment==6

gen high=0
replace high=1 if h_treatment==7

gen comp=0
replace comp=1 if h_treatment==8

gen lowcost=0
replace lowcost=1 if h_treatment==9

gen highcost=0
replace highcost=1 if h_treatment==10

gen cost=0
replace cost=1 if h_treatment==9
replace cost=1 if h_treatment==10

*Compensation, earnings and unemployment where prob=50 
gen pooled50=0
replace pooled50=1 if h_treatment==3
replace pooled50=1 if h_treatment==13
replace pooled50=1 if h_treatment==18

*disability against unemployment 
gen dis_unemp=.
replace dis_unemp=1 if disability==1
replace dis_unemp=0 if h_treatment==13

*location
gen Norway=0
replace Norway=1 if USA==.

*POLICY ATTITUDES
*Unemployment benefits should be made more generous
gen moregenerous=0
replace moregenerous=Q3r1 if Norway==0
replace moregenerous=Q22r1 if Norway==1
gen Rmoregenerous=(8-moregenerous)

*It is unfair that the involuntary unemployed are not fully compensated for their income loss
gen fullycompensated=0
replace fullycompensated=Q3r2 if Norway==0
replace fullycompensated=Q22r2 if Norway==1
gen Rfullycompensated=(8-fullycompensated)

*Generous unemployment benefits hurt the economy 
gen unemploymentbenefitshurt=0
replace unemploymentbenefitshurt=Q3r3 if Norway==0
replace unemploymentbenefitshurt=Q22r3 if Norway==1
gen Runemploymentbenefitshurt=(8-unemploymentbenefitshurt)

*The government should help reduce the income inequalities in society 
gen reduceinequality=0
replace reduceinequality=Q3r4 if Norway==0
replace reduceinequality=Q22r4 if Norway==1
gen Rreduceinequality=(8-reduceinequality)

*It is unfair that some people have higher income than others
gen inequalityunfair=0
replace inequalityunfair=Q3r5 if Norway==0
replace inequalityunfair=Q22r5 if Norway==1
gen Rinequalityunfair=(8-inequalityunfair)

*Large income redistribution hurts the economy
gen inequalityhurt=0
replace inequalityhurt=Q3r6 if Norway==0
replace inequalityhurt=Q22r6 if Norway==1
gen Rinequalityhurt=(8-inequalityhurt)

*Disability benefits should be made more generous
gen disbenefitsmoregenerous=0
replace disbenefitsmoregenerous=Q3br1 if Norway==0
replace disbenefitsmoregenerous=Q22br1 if Norway==1
gen Rdisbenefitsmoregenerous=(8-disbenefitsmoregenerous)

*Generous disability benefits hurt the economy
gen disbenefitsfullycompensated=0
replace disbenefitsfullycompensated=Q3br2 if Norway==0
replace disbenefitsfullycompensated=Q22br2 if Norway==1
gen Rdisbenefitsfullycompensated=(8-disbenefitsfullycompensated)

*It is unfair that disabled people who cannot work are not fully compensated for their income loss
gen disbenefitshurt=0
replace disbenefitshurt=Q3br3 if Norway==0
replace disbenefitshurt=Q22br3 if Norway==1
gen Rdisbenefitshurt=(8-disbenefitshurt)

*Male
gen female=0
replace female=1 if malenorway==2 
replace female=1 if maleusa==2 
gen male=0
replace male=1 if female==1

*Low education = Completed some high school & High school graduate or GED equivalent
gen loweducation=0
replace loweducation=1 if educusa==1
replace loweducation=1 if educusa==2
replace loweducation=1 if educnorway==1
replace loweducation=1 if educnorway==2

*age
replace ageusa=. if ageusa<18
replace ageusa=. if ageusa>100
gen age=agenorway 
replace age=ageusa if age==.

*Low age = below mean(age)
gen lowage=0
replace lowage=1 if ageusa<46
replace lowage=1 if agenorway<50

*Low income = below $69.999
gen lowincome=0
replace lowincome=1 if incomeusa<6
replace lowincome=1 if incomenorway<9

*Rightwing = republican party
gen rightwing=0
replace rightwing=1 if Q11==1
replace rightwing =1 if Q3x2==8
replace rightwing =1 if Q3x2==9

gen republican=0
replace republican=1 if Q11==1

gen democrat=0
replace democrat=1 if Q11==2

*How willing are you to give to good causes without expecting anything in return?
gen give=0
replace give=Q4 if Norway==0
replace give=Q23 if Norway==1
gen Rgive=(8-give)

*From steps 0 (worst life) to 10 (best life) of a ladder, where do you feel you personally stand at this time?
gen happiness=0
replace happiness=Q4b if Norway==0
replace happiness=Q21b if Norway==1

*Is religion important in your life?
gen religion=0
replace religion=Q5 if Norway==0
replace religion=Q24 if Norway==1
gen Rreligion=(8-religion)

*INTERACTIONS
gen rightwing_prob0=rightwing*prob0
gen rightwing_prob25=rightwing*prob25
gen rightwing_prob50=rightwing*prob50
gen rightwing_prob75=rightwing*prob75
gen rightwing_prob100=rightwing*prob100

gen Norway_prob0=Norway*prob0
gen Norway_prob25=Norway*prob25
gen Norway_prob50=Norway*prob50
gen Norway_prob75=Norway*prob75
gen Norway_prob100=Norway*prob100

gen replication_prob0 = prob0*replication
gen replication_prob25 = prob25*replication 
gen replication_prob50 = prob50*replication 
gen replication_prob75 = prob75*replication 
gen replication_prob100 = prob100*replication 

gen unemployment_prob0 = prob0*unemployment 
gen unemployment_prob25 = prob25*unemployment 
gen unemployment_prob50 = prob50*unemployment 
gen unemployment_prob75 = prob75*unemployment
gen unemployment_prob100 = prob100*unemployment 

********************************************************************************
**#3. RESCALE POP. WEIGHTS
********************************************************************************
bys Norway: egen den_weight = mean(weight)
gen sca_weight = weight / den_weight

********************************************************************************
**#CLEAN REST FINAL DATASET
********************************************************************************
*DROP
drop Q2Treat_1 Q2Treat_2 Q2Treat_3 Q2Treat_4 Q2Treat_5 Q2Treat_6 Q2Treat_7 Q2Treat_8 Q2Treat_9 Q2Treat_10 Q2Treat_11 Q2Treat_12 Q2Treat_13 Q2Treat_14 Q2Treat_15 Q2Treat_16 Q2Treat_17 Q2Treat_18 Q2Treat_19 Q2Treat_21 USA NOR
drop Q3r1 Q3r2 Q3r3 Q3r4 Q3r5 Q3r6 Q3br1 Q3br2 Q3br3 Q4 Q5 Q4b Q5a Q5b Q11 Q22r1 Q22r2 Q22r3 Q22r4 Q22r5 Q22r6 Q22br1 Q22br2 Q22br3 Q23 Q24 Q21b Q3x2 
drop Q2Treat_20 female 

*LABEL
label var prob0 "0 percent"
label var prob25 "25 percent"
label var prob50 "50 percent"
label var prob75 "75 percent"
label var prob100 "100 percent"
label var lowincome "Low income"
label var loweducation "Low education"
label var male "Male"
label var lowage "Low age"
label var rightwing "Right-wing"
label var lowcost "Low cost"
label var highcost "High cost"
label var Rfullycompensated "Fairness: unemployment benefits"
label var Runemploymentbenefitshurt "Cost: unemployment benefits"
label var Rinequalityunfair "Fairness: income equalization"
label var Rinequalityhurt "Cost: income equalization"
label var Norway_prob0 "Norway*0"
label var Norway_prob25 "Norway*25"
label var Norway_prob50 "Norway*50"
label var Norway_prob75 "Norway*75"
label var Norway_prob100 "Norway*100"
label var national "Nationality"
label var high "High stakes"
label var rightwing_prob0 "Right-wing*0"
label var rightwing_prob25 "Right-wing*25"
label var rightwing_prob50 "Right-wing*50"
label var rightwing_prob75 "Right-wing*75"
label var rightwing_prob100 "Right-wing*100"
label var pay "Pay"
label var Rdisbenefitsfullycompensated "Fairness: disability benefits"
label var Rdisbenefitshurt "Cost: disability benefits"
label var Rdisbenefitsmoregenerous "More generous disability benefits"
label var Rmoregenerous "More generous unemployment benefits"
label var dis_unemp "Disability vs Unemployment"
label var unemployment_prob0 "Unemployment*0"
label var unemployment_prob25 "Unemployment*25"
label var unemployment_prob50 "Unemployment*50"
label var unemployment_prob75 "Unemployment*75"
label var unemployment_prob100 "Unemployment*100"
label var replication_prob0 "Earnings*0"
label var replication_prob25 "Earnings*25"
label var replication_prob50 "Earnings*50"
label var replication_prob75 "Earnings*75"
label var replication_prob100 "Earnings*100"
label var age "Age"  
label var comp "Positive endowment"
label var pay "Pay"

save ../Data/Processed_Data/analyticaldata.dta, replace
