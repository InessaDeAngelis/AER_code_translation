clear

	 *** ten codes changing twice old/new
	if 0{
	303290000*
	303890000*
	304890000*
	308290000*
	2931909700*
	3824909900*
	3824909930*
	8703900030*
	8711900020*
	9405102000*
	}

	use "data/concordance/hs_code_change.dta", clear
	keep codeold codenew year
	duplicates drop
	destring year, replace
	keep if year>=2007 & year<=2013
	bysort codeold year: gen nold=_N
	bysort codenew year: gen nnew=_N
	drop if codenew==codeold & nold==1 & nnew==1
	save data/temp/tempMain, replace


 use data/temp/colombia_imports, clear
	*2931909700
	*codeold	codenew	year	nold	nnew
	*2931909700	2931399600	2011	1	1
	*2931009800	2931909700	2008	1	1
	* 2931399600 is only once, 2931009800 only once
	***2931909700 first change in 2008
	replace ProductHS="2931399600" if ProductHS=="2931909700" | ProductHS=="2931009800"

	*303290000
	***first change codenew== 303290000 codeold=303790090 change in 2008
	***second change codeold== 303290000 codenew=303190000 change in 2011 
	 * 303290000 303190000 only once
	replace ProductHS="303790090" if ProductHS=="303290000" | ProductHS=="303190000"


	*303890000
	if 0{
	***first change codenew== 303890000 codeold=303790090 change in 2008
	***second change codeold== 303890000 codenew=303590000 change in 2011 
	 * 303790090 303590000 only once
	 }
	replace ProductHS="303790090" if ProductHS=="303890000" | ProductHS=="303590000"

	*304890000
	if 0{
	***first change codenew== 304890000 codeold=304299090 15:1 change in 2008
	***second change codeold== 304890000 codenew=304880000 change in 2011 
	 * 304299090 304880000 only once
	 }
	replace ProductHS="304299090" if ProductHS=="304890000" | ProductHS=="304880000"

	*308290000
	if 0{
	***first change codenew== 308290000 codeold=307999000 7:1 change in 2011
	***second change codeold== 308290000 codenew=308220000 change in 2011 
	 * 308220000 307999000 only once
	 }
	replace ProductHS="307999000" if ProductHS=="308290000" | ProductHS=="308220000"
	
	**3824909900
	if 0{
		codeold	codenew	year	nold	nnew
		3824909990	2852901000	2007	5	1
		3824909990	2852909000	2007	5	1
		3824909900	3824840000	2011	6	1
		3824909900	3824850000	2011	6	1
		3824909900	3824860000	2011	6	1
		3824909900	3824870000	2011	6	1
		3824909900	3824880000	2011	6	1
		3824909990	3824909900	2007	5	1
		3824909990	3824909930	2007	5	1
		3824909990	3824909990	2007	5	1
		3824909900	3824999900	2011	6	1
		}
		#delimit ;
	replace ProductHS="3824909990" if ProductHS=="3824909900" 
	| ProductHS=="3824840000" | ProductHS=="3824850000"
	| ProductHS=="3824860000" | ProductHS=="3824870000" | ProductHS=="3824880000"
	;	
	#delimit cr

	
	**3824909930
	if 0{
		codeold	codenew	year	nold	nnew
		3824909990	2852901000	2007	5	1
		3824909990	2852909000	2007	5	1
		3824909990	3824909900	2007	5	1
		3824909990	3824909930	2007	5	1
		3824909990	3824909990	2007	5	1
		3824909930	3826000000	2007	1	1
	}
	replace ProductHS="3824909990" if ProductHS=="3824909930" | ProductHS=="3826000000"

	*8703900030
		if 0{
	codeold	codenew	year	nold	nnew
	8703900030	8703401000	2010	8	1
	8703900030	8703409000	2010	8	1
	8703900030	8703501000	2010	8	1
	8703900030	8703509000	2010	8	1
	8703900030	8703601000	2010	8	1
	8703900030	8703609000	2010	8	1
	8703900030	8703701000	2010	8	1
	8703900030	8703709000	2010	8	1
	8703900090	8703900030	2009	3	1
	}
	#delimit ;
	replace ProductHS="8703900090" if ProductHS=="8703900030" | ProductHS=="8703401000" 
	|ProductHS=="8703409000" | ProductHS=="8703501000"
	| ProductHS=="8703509000" | ProductHS=="8703601000" |ProductHS=="8703609000" 
	| ProductHS=="8703701000" | ProductHS=="8703709000";
	#delimit cr

	*8711900020
	if 0{
	codeold	codenew	year	nold	nnew
	8711900020	8711600010	2011	1	1
	8711900010	8711900020	2009	1	1
	}
	replace ProductHS="8711900020" if ProductHS=="8711900010" | ProductHS=="8711600010" 

	*9405102000
	if 0{
	codeold	codenew	year	nold	nnew
	9405109000	9405102000	2011	3	1
	9405102000	9405102010	2011	2	1
	9405102000	9405102090	2011	2	1
	}

	replace ProductHS="9405109000" if ProductHS=="9405102000" | ProductHS=="9405102010"  | ProductHS=="9405102090"

	save data/temp/colombia_imports_updated_hs, replace

**rearranging the concordance file
use data/temp/tempMain, replace
#delimit ;
drop if codeold==303290000 | codeold==303890000 |codeold==304890000 |codeold==308290000 
|codeold==3824909930 |codeold==3824909900 |codeold==2931909700 | codeold==8703900030 
|codeold==8711900020 |codeold==9405102000
;
drop if codenew==303290000 | codenew==303890000 |codenew==304890000 |codenew==308290000
|codenew==3824909930 |codenew==3824909900 |codenew==2931909700 | codenew==8703900030 
|codenew==8711900020 |codenew==9405102000
;
#delimit cr
save data/temp/tempMain2nd, replace

if 0{
	drop if codeold==codenew
	sort year codeold codenew
	** difficult cases: many to many
	drop nold nnew
	bysort codeold year: gen nold=_N
	bysort codenew year: gen nnew=_N
	*keep if nold>1 & nnew>1
	*bro
	sort codeold codenew


	bro if codeold==305490000 | codeold==305410000 |codeold==305690000 |codenew==305720000
	codeold	codenew	year	nold	nnew
	305410000	305720000	2011	2	3
	305410000	305799000	2011	2	3
	305490000	305430000	2011	4	1
	305490000	305440000	2011	4	1
	305490000	305720000	2011	4	3
	305490000	305799000	2011	4	3
	305690000	305640000	2011	3	1
	305690000	305720000	2011	3	3
	305690000	305799000	2011	3	3
}
use data/temp/tempMain2nd, clear
	keep if codeold==305490000 | codeold==305410000 |codeold==305690000 |codenew==305720000
	rename codeold ProductHS
	tostring ProductHS, replace
	keep ProductHS
	save data/temp/temp1, replace
	use data/temp/tempMain2nd, clear
	keep if codeold==305490000 | codeold==305410000 |codeold==305690000 |codenew==305720000
	rename codenew ProductHS
	tostring ProductHS, replace
	keep ProductHS
	append using data/temp/temp1
	duplicates drop
	gen str10 codenew="305.2011.1"
	save data/temp/Main_1, replace

use data/temp/tempMain2nd, clear
	drop if codeold==305490000 | codeold==305410000 |codeold==305690000 |codenew==305720000
	drop if codeold==codenew
sort year codeold codenew
drop nold nnew
	bysort codeold year: gen nold=_N
	bysort codenew year: gen nnew=_N
	sort codeold codenew
	bro if nold>1 & nnew>1

	keep if nnew==1
	tostring codenew, replace
	rename codenew ProductHS
	tostring codeold, replace
	rename codeold codenew
	keep ProductHS codenew
	save data/temp/Main_2, replace
	
use data/temp/tempMain2nd, clear
	drop if codeold==305490000 | codeold==305410000 |codeold==305690000 |codenew==305720000
	drop if codeold==codenew
sort year codeold codenew
drop nold nnew
	bysort codeold year: gen nold=_N
	bysort codenew year: gen nnew=_N
	sort codeold codenew
	bro if nold>1 & nnew>1

	keep if nold==1
	tostring codenew, replace
	tostring codeold, replace
	rename codeold ProductHS
	keep ProductHS codenew
	save data/temp/Main_3, replace
	append using data/temp/Main_2
	append using data/temp/Main_1
	duplicates drop
	save data/temp/Main_all, replace
		if 0{
		*check that there are no duplicates
		bysort ProductHS: gen k=_N
		}
merge 1:m ProductHS using data/temp/colombia_imports_updated_hs
replace ProductHS=codenew if _m==3
drop if _m==1
drop codenew _m CIFValueUS
save data/temp/colombia_imports_updated_hs, replace

erase "data/temp/tempMain2nd.dta"
erase "data/temp/tempMain.dta"
erase "data/temp/temp1.dta"
erase "data/temp/Main_all.dta"
erase "data/temp/Main_3.dta"
erase "data/temp/Main_2.dta"
erase "data/temp/Main_1.dta"
