use "$root/Data/Output/Exp2.dta", clear

** Table 11 Relationships: Skewness Preferences

*generate dummies of consistence within person
gen ok_extr_inter=(pos_extreme==pos_inter)
replace ok_extr_inter=. if pos_inter==.
gen ok_extr_slight=(pos_extreme==pos_slight)
replace ok_extr_slight=. if pos_slight==.
gen ok_slight_inter=(pos_slight==pos_inter)
replace ok_slight_inter=. if pos_slight==.
replace ok_slight_inter=. if pos_inter==.


/*
This do file generates TABLE 11. For a more user-friendly code that displays the same information as the STATA output, please see below.

**top panel

tab  pos_extreme pos_slight
tab  pos_slight pos_inter
tab  pos_extreme pos_inter	 

**Row A

sum ok_extr_slight ok_slight_inter ok_extr_inter
**rightmost
bitest ok_extr_slight==.5
**middle
bitest ok_slight_inter==.5
**lefmost
bitest ok_extr_inter==.5

***Row B

**rightmost
logit pos_slight pos_extreme
**middle
logit pos_slight pos_inter
**lefmost
logit  pos_inter pos_extreme
*/


putexcel set tableB4, replace



preserve
gen pos_slight_11 = "(0.3,0.9)" if pos_slight == 1
replace pos_slight_11 = "(0.9,0.3)" if pos_slight == 0

gen pos_extreme_11 = "(0.5,1)" if pos_extreme == 1 
replace pos_extreme_11 = "(1,0.5)" if pos_extreme == 0

gen pos_inter_11 = "(0.6,0.9)" if pos_inter == 1
replace pos_inter_11 = "(0.9,0.6)" if pos_inter == 0

// headers
putexcel C1=("Pos") H1=("Pos") M1=("Pos") A3=("Pos") D1=("Neg") I1=("Neg") N1=("Neg") A4=("Neg") A6=("a") A7=("b")



// Cross Tab (Top Panel)

	// Table 1 (left-most)
		tab pos_slight_11 pos_extreme_11,  matcell(freq1)
		matrix define rowtotal1 = freq1[1,1..2] + freq1[2, 1..2]
		matrix define coltotal1 = freq1[1..2,1] + freq1[1..2,2]
		local total1 = rowtotal1[1,1] + rowtotal1[1,2]

		putexcel B3=("(0.3,0.9)") B4=("(0.9,0.3)") C2=("(0.5,1)") D2=("(1,0.5)") C3=matrix(freq1) E3=matrix(coltotal1) C5=matrix(rowtotal1) E5=(`total1'), hcenter 
	 
	// Table 2 (middle)
		tab  pos_slight_11 pos_inter_11, matcell(freq2)
		matrix define rowtotal2 = freq2[1,1..2] + freq2[2, 1..2]
		matrix define coltotal2 = freq2[1..2,1] + freq2[1..2,2]
		local total2 = rowtotal2[1,1] + rowtotal2[1,2]

		putexcel G3=("(0.3,0.9)") G4=("(0.9,0.3)") H2=("(0.6,0.9)") I2=("(0.9,0.6)") H3=matrix(freq2) J3=matrix(coltotal2) H5=matrix(rowtotal2)  J5=(`total2'), hcenter 

	// Table 3 (right-most)
		tab  pos_extreme_11 pos_inter_11, matcell(freq3) 	
		matrix define rowtotal3 = freq3[1,1..2] + freq3[2, 1..2]
		matrix define coltotal3 = freq3[1..2,1] + freq3[1..2,2]
		local total3 = rowtotal3[1,1] + rowtotal3[1,2]

		putexcel L3=("(0.5,1)") L4=("(1,0.5)") M2=("(0.6,0.9)") N2=("(0.9,0.6)") M3=matrix(freq3) O3=matrix(coltotal3) M5=matrix(rowtotal3) O5=(`total3'), hcenter 


// binomial test (row a)
	**left-most
		bitest ok_extr_slight==.5
		local percent1 = round(r(k)/r(N)*100,1)
		local p1 = round(r(p), 0.001)
		
		putexcel C6=("`percent1'%") D6=("p=`p1'")
		
	**middle
		bitest ok_slight_inter==.5
		local percent2 = round(r(k)/r(N)*100,1)
		local p2 = round(r(p), 0.001)
		
		putexcel H6=("`percent2'%") I6=("p=`p2'")
		
	**rightmost
		bitest ok_extr_inter==.5
		local percent3 = round(r(k)/r(N)*100,1)
		local p3 = round(r(p), 0.001)
		
		putexcel M6=("`percent3'%") N6=("p=`p3'")
		

// logit (row b)
	**left-most
		logit pos_slight pos_extreme
		local b1 = round(r(table)[1,1],0.01)
		local p1 = round(r(table)[4,1],0.001)
		
		putexcel C7=("b=`b1'") D7=("p=`p1'") 
	
	**middle
		logit pos_slight pos_inter
		local b2 = round(r(table)[1,1],0.01)
		local p2 = round(r(table)[4,1],0.001)
		
		putexcel H7=("b=`b2'") I7=("p=`p2'") 
		
	**right-most
		logit  pos_inter pos_extreme
		local b3 = round(r(table)[1,1],0.01)
		local p3 = round(r(table)[4,1],0.001)
		
		putexcel M7=("b=`b3'") N7=("p=`p3'") 
		


putexcel save	 
restore
