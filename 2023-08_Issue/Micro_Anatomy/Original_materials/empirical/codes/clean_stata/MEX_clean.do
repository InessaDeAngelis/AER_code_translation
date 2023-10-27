**********************************************************************
* Guntin, Ottonello and Perez (2022)
* Code cleans ENIGH Mexico raw data
**********************************************************************

cls
clear all
capture clear matrix
set mem 200m
set more off

global database   = "$user/working_data"
global input      = "$user/input"
global output     = "$user/output"

************************************************************************************************************************

** 1992 **

* concen

import excel "$input/MEX/concen_92.xls", sheet("Sheet1") clear firstrow

rename INGMONN112 INGMON
rename GASMONN112 GASMON
rename FOLIOC11 FOLIO
rename INGCORN112 INGCOR
rename TAM_HOGN20 TAM_HOG
rename HOGN102 HOG
rename GASCORN112 GASCOR
rename UBICA_GEOC5 UBICA_GEO
rename MENORESN20 KIDS

rename NEGOCION102 NEGOCIO
rename RENTASN102 RENTA

rename ESTRATOC1 ESTRATO

keep HOG TAM_HOG INGCOR GASCOR NEGOCIO RENTA FOLIO UBICA_GEO INGMON GASMON ESTRATO KIDS

gen ENT = substr(UBICA_GEO, 1,2)
destring ENT, replace
gen year = 1992

tempfile concen_1992
save `concen_1992', replace

* poblacion

import excel "$input/MEX/POBLA92.xls", sheet("Sheet1") clear firstrow

rename SEXOC1 SEX

rename FOLIOC11 FOLIO
rename PARENC1 PAREN

rename EDADN20 EDAD

rename ED_FORMALC1 ED_FORMAL
rename ED_TECNICAC1 ED_TECNICA
rename LEE_ESCC1 LEE_ESC

rename TRAB_SE_PC1 TRABAJO
rename RAMAC4 RAMA

gen SEC = substr(RAMA, 1,1)

keep FOLIO PAREN EDAD ED_FORMAL ED_TECNICA LEE_ESC TRABAJO SEC RAMA SEX
destring PAREN ED_FORMAL ED_TECNICA LEE_ESC TRABAJO SEC RAMA SEX, replace

egen EDADa=mean(EDAD), by(FOLIO)
keep if PAREN==1 
gen year = 1992

* age
* EDAD<=25  = 1
* EDAD>25 & EDAD<=35 = 2
* EDAD>35 & EDAD<=45 = 3
* EDAD>45 & EDAD<=55 = 4
* EDAD>55 & EDAD<=65 = 5
* EDAD>65 = 6
gen age =. 
replace age =1 if EDAD<=25 
replace age =2 if EDAD>25 & EDAD<=35
replace age =3 if EDAD>35 & EDAD<=45
replace age =4 if EDAD>45 & EDAD<=55
replace age =5 if EDAD>55 & EDAD<=65
replace age =6 if EDAD>65

gen age2 =. 
replace age2 =1 if EDAD<=35 
replace age2 =2 if EDAD>35 & EDAD<=55
replace age2 =3 if EDAD>55

* education
* no educacion tecnica ni formal o no sabe leer ni escribir = 1
* no termino primaria ni basico de tecnica pero sabe leer y escribir =2
* termino primaria, termino carrera tecnica sin requisito, secundaria incompleta y tecnico con primaria incompleta = 3 
* no termino bachillerato o menos, pero al menos secundaria completa = 4
* termino bachillerato y no finalizo terciario = 5
* termino terciario o mas = 6
replace ED_TECNICA = ED_TECNICA + 1
replace ED_FORMAL = ED_FORMAL + 1

gen educ=.
replace educ=1 if ((ED_TECNICA==1 & ED_FORMAL==1) | LEE_ESC==2)
replace educ=2 if ((ED_TECNICA==2 | ED_FORMAL==2) & LEE_ESC==1) 
replace educ=3 if (ED_FORMAL==3 | ED_TECNICA==3 | ED_TECNICA==4 | ED_FORMAL==4)
replace educ=4 if (ED_FORMAL==5  | ED_FORMAL==6 | ED_TECNICA==5 | ED_TECNICA==6)
replace educ=5 if (ED_FORMAL==7  | ED_FORMAL==8 | ED_TECNICA==7 | ED_TECNICA==8)
replace educ=6 if (ED_FORMAL==10 | ED_FORMAL==9 | ED_TECNICA==9)

gen educ2 = .
replace educ2 = 1 if educ<=2 & educ!=.
replace educ2 = 2 if educ> 2 & educ<=4 & educ!=.
replace educ2 = 3 if educ> 4 & educ!=.

* sectors 
* Tradable == 1 and Non Tradable == 2
gen sector = .
replace sector = 1 if (SEC == 1 | SEC ==2 | SEC ==3)
replace sector = 2 if sector!=1 & SEC!=.

tempfile pob_1992
save `pob_1992', replace


************************************************************************************************************************

** 1994 **

* concen

import excel "$input/MEX/concen_94.xls", sheet("Sheet1") clear firstrow

rename INGMONN112 INGMON
rename GASMONN112 GASMON
rename FOLIOC11 FOLIO
rename INGCORN112 INGCOR
rename TAM_HOGN20 TAM_HOG
rename HOGN112 HOG
rename GASCORN112 GASCOR
rename UBICA_GEOC5 UBICA_GEO

rename NEGOCION102 NEGOCIO
rename RENTASN102 RENTA

rename ESTRATOC1 ESTRATO

rename MENORESN20 KIDS

keep HOG TAM_HOG INGCOR GASCOR NEGOCIO RENTA FOLIO UBICA_GEO INGMON GASMON ESTRATO KIDS

gen ENT = substr(UBICA_GEO, 1,2)
destring ENT, replace
gen year = 1994

tempfile concen_1994
save `concen_1994', replace

* poblacion

import excel "$input/MEX/POBLA94.xls", sheet("Sheet1") clear firstrow

rename SEXOC1 SEX
rename FOLIOC11 FOLIO
rename PARENTESCOC1 PAREN

rename EDADN20 EDAD

rename ED_FORMALC1 ED_FORMAL
rename ED_TECNICAC1 ED_TECNICA
rename LEER_ESCC1 LEE_ESC

rename TRABAJOC3 TRABAJO
rename RAMAC4 RAMA

gen SEC = substr(RAMA, 1,1)

keep FOLIO PAREN EDAD ED_FORMAL ED_TECNICA LEE_ESC TRABAJO SEC RAMA SEX
destring PAREN ED_FORMAL ED_TECNICA LEE_ESC TRABAJO SEC RAMA SEX, replace

egen EDADa=mean(EDAD), by(FOLIO)
keep if PAREN==1 
gen year = 1994

* age
* EDAD<=25  = 1
* EDAD>25 & EDAD<=35 = 2
* EDAD>35 & EDAD<=45 = 3
* EDAD>45 & EDAD<=55 = 4
* EDAD>55 & EDAD<=65 = 5
* EDAD>65 = 6
gen age =. 
replace age =1 if EDAD<=25 
replace age =2 if EDAD>25 & EDAD<=35
replace age =3 if EDAD>35 & EDAD<=45
replace age =4 if EDAD>45 & EDAD<=55
replace age =5 if EDAD>55 & EDAD<=65
replace age =6 if EDAD>65

gen age2 =. 
replace age2 =1 if EDAD<=35 
replace age2 =2 if EDAD>35 & EDAD<=55
replace age2 =3 if EDAD>55

* education
* no educacion tecnica ni formal o no sabe leer ni escribir = 1
* no termino primaria ni basico de tecnica pero sabe leer y escribir =2
* termino primaria, termino carrera tecnica sin requisito, secundaria incompleta y tecnico con primaria incompleta = 3 
* no termino bachillerato o menos, pero al menos secundaria completa = 4
* termino bachillerato y no finalizo terciario = 5
* termino terciario o mas = 6
replace ED_TECNICA = ED_TECNICA + 1
replace ED_FORMAL = ED_FORMAL + 1

gen educ=.
replace educ=1 if ((ED_TECNICA==1 & ED_FORMAL==1) | LEE_ESC==2)
replace educ=2 if ((ED_TECNICA==2 | ED_FORMAL==2) & LEE_ESC==1) 
replace educ=3 if (ED_FORMAL==3 | ED_TECNICA==3 | ED_TECNICA==4 | ED_FORMAL==4)
replace educ=4 if (ED_FORMAL==5  | ED_FORMAL==6 | ED_TECNICA==5 | ED_TECNICA==6)
replace educ=5 if (ED_FORMAL==7  | ED_FORMAL==8 | ED_TECNICA==7 | ED_TECNICA==8)
replace educ=6 if (ED_FORMAL==10 | ED_FORMAL==9 | ED_TECNICA==9)

gen educ2 = .
replace educ2 = 1 if educ<=2 & educ!=.
replace educ2 = 2 if educ> 2 & educ<=4 & educ!=.
replace educ2 = 3 if educ> 4 & educ!=.

* sectors 
* Tradable == 1 and Non Tradable == 2
gen sector = .
replace sector = 1 if (SEC == 1 | SEC ==2 | SEC ==3)
replace sector = 2 if sector!=1 & SEC!=.

tempfile pob_1994
save `pob_1994', replace

************************************************************************************************************************

** 1996 **

* concen

import excel "$input/MEX/concen_96.xls", sheet("Sheet1") clear firstrow

rename INGMONN112 INGMON
rename GASMONN112 GASMON
rename FOLIOC11 FOLIO
rename INGCORN112 INGCOR
rename TAM_HOGN20 TAM_HOG
rename HOGN82 HOG
rename GASCORN112 GASCOR
rename UBICA_GEOC5 UBICA_GEO

rename NEGOCION102 NEGOCIO
rename RENTASN102 RENTA
rename ESTRATOC1 ESTRATO

rename MENORESN20 KIDS

keep HOG TAM_HOG INGCOR GASCOR NEGOCIO RENTA FOLIO UBICA_GEO GASMON INGMON ESTRATO KIDS

gen ENT = substr(UBICA_GEO, 1,2)
destring ENT, replace
gen year = 1996

tempfile concen_1996
save `concen_1996', replace

* poblacion

import excel "$input/MEX/POBLA96.xls", sheet("Sheet1") clear firstrow

rename SEXOC1 SEX
rename FOLIOC11 FOLIO
rename PARENTESCOC2 PAREN

rename EDADN20 EDAD

rename ED_FORMALC2 ED_FORMAL
rename ED_TECNICAC1 ED_TECNICA
rename LEER_ESCC1 LEE_ESC

rename TRABAJOC3 TRABAJO
rename RAMAC4 RAMA

gen SEC = substr(RAMA, 1,1)

keep FOLIO PAREN EDAD ED_FORMAL ED_TECNICA LEE_ESC TRABAJO SEC RAMA SEX
destring PAREN ED_FORMAL ED_TECNICA LEE_ESC TRABAJO SEC RAMA SEX, replace

egen EDADa=mean(EDAD), by(FOLIO)
keep if PAREN==1 
gen year = 1996

* age
* EDAD<=25  = 1
* EDAD>25 & EDAD<=35 = 2
* EDAD>35 & EDAD<=45 = 3
* EDAD>45 & EDAD<=55 = 4
* EDAD>55 & EDAD<=65 = 5
* EDAD>65 = 6
gen age =. 
replace age =1 if EDAD<=25 
replace age =2 if EDAD>25 & EDAD<=35
replace age =3 if EDAD>35 & EDAD<=45
replace age =4 if EDAD>45 & EDAD<=55
replace age =5 if EDAD>55 & EDAD<=65
replace age =6 if EDAD>65

gen age2 =. 
replace age2 =1 if EDAD<=35 
replace age2 =2 if EDAD>35 & EDAD<=55
replace age2 =3 if EDAD>55

* education
* no educacion tecnica ni formal o no sabe leer ni escribir = 1
* no termino primaria ni basico de tecnica pero sabe leer y escribir =2
* termino primaria, termino carrera tecnica sin requisito, secundaria incompleta y tecnico con primaria incompleta = 3 
* no termino bachillerato o menos, pero al menos secundaria completa = 4
* termino bachillerato y no finalizo terciario = 5
* termino terciario o mas = 6

gen educ=.
replace educ=1 if ((ED_TECNICA==0 & ED_FORMAL==0) | LEE_ESC==2)
replace educ=2 if ((ED_TECNICA==1 | ED_FORMAL==2 | ED_FORMAL==3 | ED_FORMAL==4 | ED_FORMAL==5 | ED_FORMAL==6) & LEE_ESC==1)
replace educ=3 if (ED_FORMAL==7 | ED_TECNICA==2 | ED_TECNICA==3 | ED_FORMAL==8 | ED_FORMAL==9)
replace educ=4 if (ED_FORMAL==10  | ED_FORMAL==11 | ED_TECNICA==4 | ED_TECNICA==5)
replace educ=5 if (ED_FORMAL==12  | ED_FORMAL==13 | ED_TECNICA==6 | ED_TECNICA==7)
replace educ=6 if (ED_FORMAL==14 | ED_FORMAL==15 | ED_TECNICA==8)

gen educ2 = .
replace educ2 = 1 if educ<=2 & educ!=.
replace educ2 = 2 if educ> 2 & educ<=4 & educ!=.
replace educ2 = 3 if educ> 4 & educ!=.

* sectors 
* Tradable == 1 and Non Tradable == 2
gen sector = .
replace sector = 1 if (SEC == 1 | SEC ==2 | SEC ==3)
replace sector = 2 if sector!=1 & SEC!=.

tempfile pob_1996
save `pob_1996', replace

************************************************************************************************************************

** 1998 **

* concen

import excel "$input/MEX/concen_98.xls", sheet("Sheet1") clear firstrow

rename INGMONN112 INGMON
rename GASMONN112 GASMON
rename FOLIOC11 FOLIO
rename INGCORN112 INGCOR
rename TAM_HOGN20 TAM_HOG
rename HOGN80 HOG
rename GASCORN112 GASCOR
rename UBICA_GEOC5 UBICA_GEO

rename NEGOCION102 NEGOCIO
rename RENTASN102 RENTA

rename ESTRATOC1 ESTRATO

rename MENORESN20 KIDS

keep HOG TAM_HOG INGCOR GASCOR NEGOCIO RENTA FOLIO UBICA_GEO GASMON INGMON ESTRATO KIDS

gen ENT = substr(UBICA_GEO, 1,2)
destring ENT, replace
gen year = 1998

tempfile concen_1998
save `concen_1998', replace

* poblacion

import excel "$input/MEX/POBLA98.xls", sheet("Sheet1") clear firstrow

rename sexoC1 SEX
rename folioC11 FOLIO
rename parentescoC2 PAREN

rename edadN20 EDAD

rename ed_formalC2 ED_FORMAL
rename ed_tecnicaC1 ED_TECNICA
rename leer_escC1 LEE_ESC

rename trabajoC3 TRABAJO
rename ramaC4 RAMA

gen SEC = substr(RAMA, 1,1)

keep FOLIO PAREN EDAD ED_FORMAL ED_TECNICA LEE_ESC TRABAJO SEC RAMA SEX
destring PAREN ED_FORMAL ED_TECNICA LEE_ESC TRABAJO SEC RAMA SEX, replace

egen EDADa=mean(EDAD), by(FOLIO)
keep if PAREN==1 
gen year = 1998

* age
* EDAD<=25  = 1
* EDAD>25 & EDAD<=35 = 2
* EDAD>35 & EDAD<=45 = 3
* EDAD>45 & EDAD<=55 = 4
* EDAD>55 & EDAD<=65 = 5
* EDAD>65 = 6
gen age =. 
replace age =1 if EDAD<=25 
replace age =2 if EDAD>25 & EDAD<=35
replace age =3 if EDAD>35 & EDAD<=45
replace age =4 if EDAD>45 & EDAD<=55
replace age =5 if EDAD>55 & EDAD<=65
replace age =6 if EDAD>65

gen age2 =. 
replace age2 =1 if EDAD<=35 
replace age2 =2 if EDAD>35 & EDAD<=55
replace age2 =3 if EDAD>55

* education
* no educacion tecnica ni formal o no sabe leer ni escribir = 1
* no termino primaria ni basico de tecnica pero sabe leer y escribir =2
* termino primaria, termino carrera tecnica sin requisito, secundaria incompleta y tecnico con primaria incompleta = 3 
* no termino bachillerato o menos, pero al menos secundaria completa = 4
* termino bachillerato y no finalizo terciario = 5
* termino terciario o mas = 6

gen educ=.
replace educ=1 if ((ED_TECNICA==1 & ED_FORMAL==1) | LEE_ESC==2)
replace educ=2 if ((ED_TECNICA==2 | ED_FORMAL==3 | ED_FORMAL==4 | ED_FORMAL==5 | ED_FORMAL==6 | ED_FORMAL==7) & LEE_ESC==1)
replace educ=3 if (ED_FORMAL==8 | ED_TECNICA==3 | ED_TECNICA==4 | ED_FORMAL==9 | ED_FORMAL==10)
replace educ=4 if (ED_FORMAL==11  | ED_FORMAL==12 | ED_TECNICA==5 | ED_TECNICA==6)
replace educ=5 if (ED_FORMAL==13  | ED_FORMAL==14 | ED_TECNICA==7 | ED_TECNICA==8)
replace educ=6 if (ED_FORMAL==15 | ED_FORMAL==16 | ED_TECNICA==9)

gen educ2 = .
replace educ2 = 1 if educ<=2 & educ!=.
replace educ2 = 2 if educ> 2 & educ<=4 & educ!=.
replace educ2 = 3 if educ> 4 & educ!=.

* sectors 
* Tradable == 1 and Non Tradable == 2
gen sector = .
replace sector = 1 if (SEC == 1 | SEC ==2 | SEC ==3)
replace sector = 2 if sector!=1 & SEC!=.

tempfile pob_1998
save `pob_1998', replace

************************************************************************************************************************

** 2000 **

* concen

import excel "$input/MEX/concen_00.xls", sheet("Sheet1") clear firstrow

rename INGMONN132 INGMON
rename GASMONN132 GASMON
rename FOLIOC12 FOLIO
rename INGCORN132 INGCOR
rename TAM_HOGN20 TAM_HOG
rename HOGN100 HOG
rename GASCORN132 GASCOR
rename UBICA_GEOC5 UBICA_GEO

rename NEGOCION132 NEGOCIO
rename RENTASN132 RENTA

rename MENORESN20 KIDS

rename ESTRATOC1 ESTRATO

keep HOG TAM_HOG INGCOR GASCOR NEGOCIO RENTA FOLIO UBICA_GEO INGMON GASMON ESTRATO KIDS

gen ENT = substr(UBICA_GEO, 1,2)
destring ENT, replace
gen year = 2000

tempfile concen_2000
save `concen_2000', replace

* poblacion

import excel "$input/MEX/POBLA00.xls", sheet("Sheet1") clear firstrow

rename SEXOC1 SEX
rename FOLIOC12 FOLIO
rename PARENTESCOC2 PAREN

rename EDADN20 EDAD

rename ED_FORMALC2 ED_FORMAL
rename ED_TECNICAC1 ED_TECNICA
rename LEER_ESCC1 LEE_ESC

rename TRABAJOC3 TRABAJO
rename RAMAC3 RAMA

gen SEC = substr(RAMA, 1,1)

keep FOLIO PAREN EDAD ED_FORMAL ED_TECNICA LEE_ESC TRABAJO SEC RAMA SEX
destring PAREN ED_FORMAL ED_TECNICA LEE_ESC TRABAJO SEC RAMA SEX, replace

egen EDADa=mean(EDAD), by(FOLIO)
keep if PAREN==1 
gen year = 2000

* age
* EDAD<=25  = 1
* EDAD>25 & EDAD<=35 = 2
* EDAD>35 & EDAD<=45 = 3
* EDAD>45 & EDAD<=55 = 4
* EDAD>55 & EDAD<=65 = 5
* EDAD>65 = 6
gen age =. 
replace age =1 if EDAD<=25 
replace age =2 if EDAD>25 & EDAD<=35
replace age =3 if EDAD>35 & EDAD<=45
replace age =4 if EDAD>45 & EDAD<=55
replace age =5 if EDAD>55 & EDAD<=65
replace age =6 if EDAD>65

gen age2 =. 
replace age2 =1 if EDAD<=35 
replace age2 =2 if EDAD>35 & EDAD<=55
replace age2 =3 if EDAD>55

* education
* no educacion tecnica ni formal o no sabe leer ni escribir = 1
* no termino primaria ni basico de tecnica pero sabe leer y escribir =2
* termino primaria, termino carrera tecnica sin requisito, secundaria incompleta y tecnico con primaria incompleta = 3 
* no termino bachillerato o menos, pero al menos secundaria completa = 4
* termino bachillerato y no finalizo terciario = 5
* termino terciario o mas = 6

gen educ=.
replace educ=1 if ((ED_TECNICA==1 & ED_FORMAL==1) | LEE_ESC==2)
replace educ=2 if ((ED_TECNICA==2 | ED_FORMAL==3 | ED_FORMAL==4 | ED_FORMAL==5 | ED_FORMAL==6 | ED_FORMAL==7) & LEE_ESC==1)
replace educ=3 if (ED_FORMAL==8 | ED_TECNICA==3 | ED_TECNICA==4 | ED_FORMAL==9 | ED_FORMAL==10)
replace educ=4 if (ED_FORMAL==11  | ED_FORMAL==12 | ED_TECNICA==5 | ED_TECNICA==6)
replace educ=5 if (ED_FORMAL==13  | ED_FORMAL==14 | ED_TECNICA==7 | ED_TECNICA==8)
replace educ=6 if (ED_FORMAL==15 | ED_FORMAL==16 | ED_TECNICA==9)

gen educ2 = .
replace educ2 = 1 if educ<=2 & educ!=.
replace educ2 = 2 if educ> 2 & educ<=4 & educ!=.
replace educ2 = 3 if educ> 4 & educ!=.

* sectors 
* Tradable == 1 and Non Tradable == 2
gen sector = .
replace sector = 1 if (SEC == 1 | SEC ==2 | SEC ==3)
replace sector = 2 if sector!=1 & SEC!=.

tempfile pob_2000
save `pob_2000', replace

************************************************************************************************************************

** 2002 **

* concen

import excel "$input/MEX/concen_02.xls", sheet("Sheet1") clear firstrow

rename INGMONN132 INGMON
rename GASMONN132 GASMON
rename FOLIOC11 FOLIO
rename INGCORN132 INGCOR
rename TAM_HOGN20 TAM_HOG
rename HOGN100 HOG
rename GASCORN132 GASCOR
rename UBICA_GEOC20 UBICA_GEO

rename NEGOCION132 NEGOCIO
rename RENTASN132 RENTA

rename ESTRATOC1 ESTRATO

rename MENORESN20 KIDS

keep HOG TAM_HOG INGCOR GASCOR NEGOCIO RENTA FOLIO UBICA_GEO INGMON GASMON ESTRATO KIDS

gen ENT = substr(UBICA_GEO, 1,2)
destring ENT, replace
gen year = 2002

tempfile concen_2002
save `concen_2002', replace

*poblacion

import excel "$input/MEX/POBLA02.xls", sheet("Sheet1") clear firstrow

rename SEXOC1 SEX
rename FOLIOC11 FOLIO
rename PARENTESCOC2 PAREN

rename EDADN20 EDAD

rename ED_FORMALC2 ED_FORMAL
rename ED_TECNICAC1 ED_TECNICA
rename ESPANOLC1 LEE_ESC

rename TRABAJOC5 TRABAJO
rename RAMAC3 RAMA

gen SEC = substr(RAMA, 1,1)
 
keep FOLIO PAREN EDAD ED_FORMAL ED_TECNICA LEE_ESC TRABAJO SEC RAMA SEX
destring PAREN ED_FORMAL ED_TECNICA LEE_ESC TRABAJO SEC RAMA SEX, replace

egen EDADa=mean(EDAD), by(FOLIO)
keep if PAREN==10
gen year = 2002

* age
* EDAD<=25  = 1
* EDAD>25 & EDAD<=35 = 2
* EDAD>35 & EDAD<=45 = 3
* EDAD>45 & EDAD<=55 = 4
* EDAD>55 & EDAD<=65 = 5
* EDAD>65 = 6
gen age =. 
replace age =1 if EDAD<=25 
replace age =2 if EDAD>25 & EDAD<=35
replace age =3 if EDAD>35 & EDAD<=45
replace age =4 if EDAD>45 & EDAD<=55
replace age =5 if EDAD>55 & EDAD<=65
replace age =6 if EDAD>65

gen age2 =. 
replace age2 =1 if EDAD<=35 
replace age2 =2 if EDAD>35 & EDAD<=55
replace age2 =3 if EDAD>55

* education
* no educacion tecnica ni formal o no sabe leer ni escribir = 1
* no termino primaria ni basico de tecnica pero sabe leer y escribir =2
* termino primaria, termino carrera tecnica sin requisito, secundaria incompleta y tecnico con primaria incompleta = 3 
* no termino bachillerato o menos, pero al menos secundaria completa = 4
* termino bachillerato y no finalizo terciario = 5
* termino terciario o mas = 6

*gen educ=.
*replace educ=1 if ((ED_TECNICA==1 & ED_FORMAL==1) | LEE_ESC==2)
*replace educ=2 if ((ED_TECNICA==2 | ED_FORMAL==3 | ED_FORMAL==4 | ED_FORMAL==5 | ED_FORMAL==6 | ED_FORMAL==7) & LEE_ESC==1)
*replace educ=3 if (ED_FORMAL==8 | ED_TECNICA==3 | ED_TECNICA==4 | ED_FORMAL==9 | ED_FORMAL==10)
*replace educ=4 if (ED_FORMAL==11  | ED_FORMAL==12 | ED_TECNICA==5 | ED_TECNICA==6)
*replace educ=5 if (ED_FORMAL==13  | ED_FORMAL==14 | ED_TECNICA==7 | ED_TECNICA==8)
*replace educ=6 if (ED_FORMAL==15 | ED_FORMAL==16 | ED_TECNICA==9)

gen educ2 = .
replace educ2 = 1 if (ED_FORMAL<=7 & ED_FORMAL!=.) | (ED_TECNICA<=2 & ED_TECNICA!=.)
replace educ2 = 2 if (ED_FORMAL>7 & ED_FORMAL<=19 & ED_FORMAL!=.) | (ED_TECNICA>2 & ED_TECNICA<7 & ED_TECNICA!=.)
replace educ2 = 3 if (ED_FORMAL>19 & ED_FORMAL!=.) | (ED_TECNICA>=7 & ED_TECNICA!=.)

* sectors 
* Tradable == 1 and Non Tradable == 2
gen sector = .
replace sector = 1 if (SEC == 1 | SEC ==2 | SEC ==3)
replace sector = 2 if sector!=1 & SEC!=.

tempfile pob_2002
save `pob_2002', replace

************************************************************************************************************************

** 2004 **

* concen

import excel "$input/MEX/concen_04.xls", sheet("Sheet1") clear firstrow

rename INGMONN132 INGMON
rename GASMONN132 GASMON
rename FOLIOC11 FOLIO
rename INGCORN132 INGCOR
rename TAM_HOGN20 TAM_HOG
rename HOGN100 HOG
rename GASCORN132 GASCOR
rename UBICA_GEOC5 UBICA_GEO
rename ED_FORMALC2 ED_FORMAL
rename EDADN20 EDAD

rename ESTRATOC1 ESTRATO

destring ED_FORMAL, replace

rename NEGOCION132 NEGOCIO
rename RENTASN132 RENTA

rename MENORESN20 KIDS


keep HOG TAM_HOG INGCOR GASCOR FOLIO NEGOCIO RENTA UBICA_GEO ED_FORMAL EDAD INGMON GASMON ESTRATO KIDS

* age
* EDAD<=25  = 1
* EDAD>25 & EDAD<=35 = 2
* EDAD>35 & EDAD<=45 = 3
* EDAD>45 & EDAD<=55 = 4
* EDAD>55 & EDAD<=65 = 5
* EDAD>65 = 6
gen age =. 
replace age =1 if EDAD<=25 
replace age =2 if EDAD>25 & EDAD<=35
replace age =3 if EDAD>35 & EDAD<=45
replace age =4 if EDAD>45 & EDAD<=55
replace age =5 if EDAD>55 & EDAD<=65
replace age =6 if EDAD>65

gen age2 =. 
replace age2 =1 if EDAD<=35 
replace age2 =2 if EDAD>35 & EDAD<=55
replace age2 =3 if EDAD>55

gen educ2 = .
replace educ2 = 1 if (ED_FORMAL<=2 | ED_FORMAL==4) &  ED_FORMAL!=.
replace educ2 = 2 if ED_FORMAL==3 | ED_FORMAL==5 | ED_FORMAL==6 | ED_FORMAL==8
replace educ2 = 3 if ED_FORMAL==7 | ED_FORMAL==9 | ED_FORMAL==10 | ED_FORMAL==11

tempfile concen_2004
save `concen_2004', replace

*poblacion

import delimited "$input/MEX/POBLA04.csv", clear 

tostring folio , replace format("%12.0f")

rename folio FOLIO
rename parentesco PAREN

rename sexo SEX

rename edad EDAD

rename trabajo TRABAJO
rename scian151 RAMA

replace RAMA = "." if RAMA == "NA"
replace TRABAJO = "." if TRABAJO == "NA"

gen SEC = substr(RAMA, 1,1)

keep FOLIO PAREN EDAD TRABAJO SEC RAMA SEX
destring PAREN EDAD TRABAJO SEC RAMA, replace

egen EDADa=mean(EDAD), by(FOLIO)
drop EDAD
keep if PAREN==100
gen year = 2004

tempfile pob_2004
save `pob_2004', replace

************************************************************************************************************************

** 2005 **

* concen

import excel "$input/MEX/concen_05.xls", sheet("Sheet1") clear firstrow

rename INGMONN132 INGMON
rename GASMONN132 GASMON
rename FOLIOC11 FOLIO
rename INGCORN132 INGCOR
rename TAM_HOGN20 TAM_HOG
rename HOGN100 HOG
rename GASCORN132 GASCOR
rename UBICA_GEOC5 UBICA_GEO
renam ED_FORMALC2 ED_FORMAL
rename EDADN20 EDAD

rename ESTRATOC1 ESTRATO

destring ED_FORMAL, replace

rename NEGOCION132 NEGOCIO
rename RENTASN132 RENTA

rename MENORESN20 KIDS

keep HOG TAM_HOG INGCOR GASCOR FOLIO NEGOCIO RENTA UBICA_GEO ED_FORMAL EDAD INGMON GASMON ESTRATO KIDS

* age
* EDAD<=25  = 1
* EDAD>25 & EDAD<=35 = 2
* EDAD>35 & EDAD<=45 = 3
* EDAD>45 & EDAD<=55 = 4
* EDAD>55 & EDAD<=65 = 5
* EDAD>65 = 6
gen age =. 
replace age =1 if EDAD<=25 
replace age =2 if EDAD>25 & EDAD<=35
replace age =3 if EDAD>35 & EDAD<=45
replace age =4 if EDAD>45 & EDAD<=55
replace age =5 if EDAD>55 & EDAD<=65
replace age =6 if EDAD>65

gen age2 =. 
replace age2 =1 if EDAD<=35 
replace age2 =2 if EDAD>35 & EDAD<=55
replace age2 =3 if EDAD>55

gen educ2 = .
replace educ2 = 1 if (ED_FORMAL<=2 | ED_FORMAL==4) &  ED_FORMAL!=.
replace educ2 = 2 if ED_FORMAL==3 | ED_FORMAL==5 | ED_FORMAL==6 | ED_FORMAL==8
replace educ2 = 3 if ED_FORMAL==7 | ED_FORMAL==9 | ED_FORMAL==10 | ED_FORMAL==11

tempfile concen_2005
save `concen_2005', replace

*poblacion

import delimited "$input/MEX/POBLA05.csv", clear 

tostring folio , replace format("%12.0f")

rename folio FOLIO
rename parentesco PAREN

rename edad EDAD

rename trabajo TRABAJO
rename scian151 RAMA

rename sexo SEX

replace RAMA = "." if RAMA == "NA"
replace TRABAJO = "." if TRABAJO == "NA"

gen SEC = substr(RAMA, 1,1)

keep FOLIO PAREN EDAD TRABAJO SEC RAMA SEX
destring PAREN EDAD TRABAJO SEC RAMA, replace

egen EDADa=mean(EDAD), by(FOLIO)
drop EDAD
keep if PAREN==100
gen year = 2005

tempfile pob_2005
save `pob_2005', replace

************************************************************************************************************************

** 2006 **

use "$input/MEX/concen_06.dta", clear

gen year = 2006

rename folio FOLIO
rename ubica_geo UBICA_GEO

rename edad EDAD
rename ed_formal ED_FORMAL

destring ED_FORMAL,replace

rename RENTAS RENTA
rename estrato ESTRATO

rename menores KIDS

keep HOG TAM_HOG INGCOR GASCOR NEGOCIO RENTA FOLIO UBICA_GEO ED_FORMAL EDAD INGMON GASMON ESTRATO KIDS

* age
* EDAD<=25  = 1
* EDAD>25 & EDAD<=35 = 2
* EDAD>35 & EDAD<=45 = 3
* EDAD>45 & EDAD<=55 = 4
* EDAD>55 & EDAD<=65 = 5
* EDAD>65 = 6
gen age =. 
replace age =1 if EDAD<=25 
replace age =2 if EDAD>25 & EDAD<=35
replace age =3 if EDAD>35 & EDAD<=45
replace age =4 if EDAD>45 & EDAD<=55
replace age =5 if EDAD>55 & EDAD<=65
replace age =6 if EDAD>65

gen age2 =. 
replace age2 =1 if EDAD<=35 
replace age2 =2 if EDAD>35 & EDAD<=55
replace age2 =3 if EDAD>55

gen educ2 = .
replace educ2 = 1 if (ED_FORMAL<=2 | ED_FORMAL==4) &  ED_FORMAL!=.
replace educ2 = 2 if ED_FORMAL==3 | ED_FORMAL==5 | ED_FORMAL==6 | ED_FORMAL==8
replace educ2 = 3 if ED_FORMAL==7 | ED_FORMAL==9 | ED_FORMAL==10 | ED_FORMAL==11

tempfile concen_2006
save `concen_2006', replace

*poblacion

use "$input/MEX/poblacion_06.dta", clear

rename folio FOLIO
rename parentesco PAREN
rename edad EDAD

rename sexo SEX

rename trabajo TRABAJO
rename scian101 RAMA

gen SEC = substr(RAMA, 1,1)

keep FOLIO PAREN EDAD TRABAJO SEC RAMA SEX
destring PAREN EDAD TRABAJO SEC RAMA, replace

egen EDADa=mean(EDAD), by(FOLIO)
drop EDAD
keep if PAREN==100
gen year = 2006

tempfile pob_2006
save `pob_2006', replace

************************************************************************************************************************

** 2008 **

use "$input/MEX/concen_08.dta", clear

gen year = 2008

gen  FOLIO = folioviv + foliohog
rename ubica_geo UBICA_GEO
rename sexo SEX

rename edad EDAD
rename ed_formal ED_FORMAL

destring ED_FORMAL,replace

rename estrato ESTRATO

rename RENTAS RENTA
rename menores KIDS

keep HOG TAM_HOG INGCOR GASCOR NEGOCIO RENTA FOLIO UBICA_GEO ED_FORMAL EDAD INGMON GASMON SEX ESTRATO KIDS

* age
* EDAD<=25  = 1
* EDAD>25 & EDAD<=35 = 2
* EDAD>35 & EDAD<=45 = 3
* EDAD>45 & EDAD<=55 = 4
* EDAD>55 & EDAD<=65 = 5
* EDAD>65 = 6
gen age =. 
replace age =1 if EDAD<=25 
replace age =2 if EDAD>25 & EDAD<=35
replace age =3 if EDAD>35 & EDAD<=45
replace age =4 if EDAD>45 & EDAD<=55
replace age =5 if EDAD>55 & EDAD<=65
replace age =6 if EDAD>65

gen age2 =. 
replace age2 =1 if EDAD<=35 
replace age2 =2 if EDAD>35 & EDAD<=55
replace age2 =3 if EDAD>55

gen educ2 = .
replace educ2 = 1 if (ED_FORMAL<=3) &  ED_FORMAL!=.
replace educ2 = 2 if ED_FORMAL==4 | ED_FORMAL==5 | ED_FORMAL==6 | ED_FORMAL==7
replace educ2 = 3 if ED_FORMAL==8 | ED_FORMAL==9 | ED_FORMAL==10 | ED_FORMAL==11

tempfile concen_2008
save `concen_2008', replace

*poblacion

use "$input/MEX/poblacion_08.dta", clear

gen  FOLIO = folioviv + foliohog
gen  FOLIO2 = folioviv + foliohog + numren

rename parentesco PAREN
rename edad EDAD
rename trabajo TRABAJO

keep FOLIO FOLIO2 PAREN EDAD TRABAJO
destring PAREN EDAD TRABAJO, replace

egen EDADa=mean(EDAD), by(FOLIO)
drop EDAD
gen year = 2008

tempfile temp1
save `temp1', replace

use "$input/MEX/trabajos_08.dta", clear

gen  FOLIO = folioviv + foliohog
gen  FOLIO2 = folioviv + foliohog + numren

rename scian RAMA

keep if numtrab == 1
keep RAMA FOLIO FOLIO2

gen SEC = substr(RAMA, 1,1)
destring SEC RAMA, replace

merge 1:1 FOLIO2 using `temp1', nogenerate

keep if PAREN==101

replace year = 2008

tempfile pob_2008
save `pob_2008', replace

************************************************************************************************************************

** 2010 **

use "$input/MEX/concen_10.dta", clear

gen year = 2010

gen  FOLIO = folioviv + foliohog
rename ubica_geo UBICA_GEO

rename edad EDAD
rename ed_formal ED_FORMAL
rename sexo SEX

rename tam_loc ESTRATO 

destring ED_FORMAL,replace

rename RENTAS RENTA
rename menores KIDS
rename alquiler ALQUILER

keep HOG TAM_HOG INGCOR GASCOR NEGOCIO RENTA FOLIO UBICA_GEO ED_FORMAL EDAD INGMON GASMON SEX ESTRATO KIDS ALQUILER

* age
* EDAD<=25  = 1
* EDAD>25 & EDAD<=35 = 2
* EDAD>35 & EDAD<=45 = 3
* EDAD>45 & EDAD<=55 = 4
* EDAD>55 & EDAD<=65 = 5
* EDAD>65 = 6
gen age =. 
replace age =1 if EDAD<=25 
replace age =2 if EDAD>25 & EDAD<=35
replace age =3 if EDAD>35 & EDAD<=45
replace age =4 if EDAD>45 & EDAD<=55
replace age =5 if EDAD>55 & EDAD<=65
replace age =6 if EDAD>65

gen age2 =. 
replace age2 =1 if EDAD<=35 
replace age2 =2 if EDAD>35 & EDAD<=55
replace age2 =3 if EDAD>55

gen educ2 = .
replace educ2 = 1 if (ED_FORMAL<=3) &  ED_FORMAL!=.
replace educ2 = 2 if ED_FORMAL==4 | ED_FORMAL==5 | ED_FORMAL==6 | ED_FORMAL==7
replace educ2 = 3 if ED_FORMAL==8 | ED_FORMAL==9 | ED_FORMAL==10 | ED_FORMAL==11

tempfile concen_2010
save `concen_2010', replace

*poblacion

use "$input/MEX/poblacion_10.dta", clear

gen  FOLIO = folioviv + foliohog
gen  FOLIO2 = folioviv + foliohog + numren

rename parentesco PAREN
rename edad EDAD
rename trabajo TRABAJO

keep FOLIO FOLIO2 PAREN EDAD TRABAJO
destring PAREN EDAD TRABAJO, replace

egen EDADa=mean(EDAD), by(FOLIO)
drop EDAD
gen year = 2010

tempfile temp1
save `temp1', replace

use "$input/MEX/trabajos_10.dta", clear

gen  FOLIO = folioviv + foliohog
gen  FOLIO2 = folioviv + foliohog + numren

rename scian RAMA

destring numtrab, replace
keep if numtrab == 1
keep RAMA FOLIO FOLIO2

gen SEC = substr(RAMA, 1,1)
destring SEC RAMA, replace

merge 1:1 FOLIO2 using `temp1', nogenerate

keep if PAREN==101

replace year = 2010

tempfile pob_2010
save `pob_2010', replace

************************************************************************************************************************

** 2012 **

use "$input/MEX/concen_12.dta", clear

gen year = 2012

gen  FOLIO = folioviv + foliohog
rename ubica_geo UBICA_GEO
rename sexo_jefe SEX

rename edad EDAD
rename educa_jefe ED_FORMAL

destring ED_FORMAL,replace

rename RENTAS RENTA

rename tam_loc ESTRATO
rename menores KIDS

keep HOG TAM_HOG INGCOR GASCOR NEGOCIO RENTA FOLIO UBICA_GEO ED_FORMAL EDAD INGMON GASMON SEX ESTRATO KIDS

* age
* EDAD<=25  = 1
* EDAD>25 & EDAD<=35 = 2
* EDAD>35 & EDAD<=45 = 3
* EDAD>45 & EDAD<=55 = 4
* EDAD>55 & EDAD<=65 = 5
* EDAD>65 = 6
gen age =. 
replace age =1 if EDAD<=25 
replace age =2 if EDAD>25 & EDAD<=35
replace age =3 if EDAD>35 & EDAD<=45
replace age =4 if EDAD>45 & EDAD<=55
replace age =5 if EDAD>55 & EDAD<=65
replace age =6 if EDAD>65

gen age2 =. 
replace age2 =1 if EDAD<=35 
replace age2 =2 if EDAD>35 & EDAD<=55
replace age2 =3 if EDAD>55

gen educ2 = .
replace educ2 = 1 if (ED_FORMAL<=3) &  ED_FORMAL!=.
replace educ2 = 2 if ED_FORMAL==4 | ED_FORMAL==5 | ED_FORMAL==6 | ED_FORMAL==7
replace educ2 = 3 if ED_FORMAL==8 | ED_FORMAL==9 | ED_FORMAL==10 | ED_FORMAL==11

tempfile concen_2012
save `concen_2012', replace

*poblacion

use "$input/MEX/poblacion_12.dta", clear

gen  FOLIO = folioviv + foliohog
gen  FOLIO2 = folioviv + foliohog + numren

rename parentesco PAREN
rename edad EDAD
rename trabajo TRABAJO

keep FOLIO FOLIO2 PAREN EDAD TRABAJO
destring PAREN EDAD TRABAJO, replace

egen EDADa=mean(EDAD), by(FOLIO)
drop EDAD
gen year = 2012

tempfile temp1
save `temp1', replace

use "$input/MEX/trabajos_12.dta", clear

gen  FOLIO = folioviv + foliohog
gen  FOLIO2 = folioviv + foliohog + numren

rename scian RAMA

destring id_trabajo, replace
keep if id_trabajo == 1
keep RAMA FOLIO FOLIO2

gen SEC = substr(RAMA, 1,1)
destring SEC RAMA, replace

merge 1:1 FOLIO2 using `temp1', nogenerate

keep if PAREN==101

replace year = 2012

tempfile pob_2012
save `pob_2012', replace

************************************************************************************************************************

** 2014 **

use "$input/MEX/concen_14.dta", clear

gen year = 2014

gen  FOLIO = folioviv + foliohog
rename ubica_geo UBICA_GEO

rename edad EDAD
rename educa_jefe ED_FORMAL
rename sexo_jefe SEX

destring ED_FORMAL SEX,replace

rename RENTAS RENTA

rename tam_loc ESTRATO
rename menores KIDS

keep HOG TAM_HOG INGCOR GASCOR NEGOCIO RENTA FOLIO UBICA_GEO ED_FORMAL EDAD INGMON GASMON SEX ESTRATO KIDS

* age
* EDAD<=25  = 1
* EDAD>25 & EDAD<=35 = 2
* EDAD>35 & EDAD<=45 = 3
* EDAD>45 & EDAD<=55 = 4
* EDAD>55 & EDAD<=65 = 5
* EDAD>65 = 6
gen age =. 
replace age =1 if EDAD<=25 
replace age =2 if EDAD>25 & EDAD<=35
replace age =3 if EDAD>35 & EDAD<=45
replace age =4 if EDAD>45 & EDAD<=55
replace age =5 if EDAD>55 & EDAD<=65
replace age =6 if EDAD>65

gen age2 =. 
replace age2 =1 if EDAD<=35 
replace age2 =2 if EDAD>35 & EDAD<=55
replace age2 =3 if EDAD>55

gen educ2 = .
replace educ2 = 1 if (ED_FORMAL<=3) &  ED_FORMAL!=.
replace educ2 = 2 if ED_FORMAL==4 | ED_FORMAL==5 | ED_FORMAL==6 | ED_FORMAL==7
replace educ2 = 3 if ED_FORMAL==8 | ED_FORMAL==9 | ED_FORMAL==10 | ED_FORMAL==11

tempfile concen_2014
save `concen_2014', replace

*poblacion

use "$input/MEX/trabajos_14.dta", clear

gen  FOLIO = folioviv + foliohog
gen  FOLIO2 = folioviv + foliohog + numren

rename scian RAMA

destring id_trabajo, replace
keep if id_trabajo == 1
keep RAMA FOLIO FOLIO2

gen SEC = substr(RAMA, 1,1)
destring SEC RAMA, replace

tempfile temp1
save `temp1', replace


use "$input/MEX/poblacion_14.dta", clear

gen  FOLIO = folioviv + foliohog
gen  FOLIO2 = folioviv + foliohog + numren

rename parentesco PAREN
rename edad EDAD
rename trabajo TRABAJO

keep FOLIO FOLIO2 PAREN EDAD TRABAJO
destring PAREN EDAD TRABAJO, replace

egen EDADa=mean(EDAD), by(FOLIO)
drop EDAD

merge 1:1 FOLIO2 using `temp1', nogenerate

gen year = 2014

keep if PAREN==101

tempfile pob_2014
save `pob_2014', replace

************************************************************************************************************************

** Mergring


local year = "1992 1994 1996 1998 2000 2002 2004 2005 2006 2008 2010 2012 2014"

foreach x of local year {

use `concen_`x'' , clear

merge 1:1 FOLIO using `pob_`x'' , nogenerate

replace year = `x'

destring SEX ESTRATO , replace

foreach y of varlist GASCOR INGCOR GASMON RENTA INGMON {
replace `y'=`y'/(1000) if `x'==1992
}

gen state_code = substr(UBICA_GEO,1,2)
destring state_code, replace

save "$database/MEX/merge_`x'.dta" , replace

}

