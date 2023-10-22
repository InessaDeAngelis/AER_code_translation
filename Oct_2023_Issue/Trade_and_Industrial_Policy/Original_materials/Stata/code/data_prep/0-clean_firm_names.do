clear

**you need to have or install strdist package:
*ssc install strdist

local table Weightallyears


if 1{
	
if 1{
	
	foreach year in 2007 2009 2010 2011 2012 2013 {
		#delimit ;

		use FOBValueUS CIFValueUS DeclarationDate  
			ProviderEmail
			ProductHS Provider ProviderCountry using data/confidential_data/datamyne/ColombiaImports`year'_1, clear;
		save data/temp/temp1, replace;

		use FOBValueUS CIFValueUS Product  DeclarationDate 
			ProviderEmail
			ProductHS Provider ProviderCountry using data/confidential_data/datamyne/ColombiaImports`year'_2, clear;
		append using data/temp/temp1;
		drop if FOBValueUS==0 | CIFValueUS==0 |Provider=="";
		#delimit cr
		**year;
		gen year=year( DeclarationDate)
		keep if year==`year'
		
		** fixing country names
		gen str3 prov=ProviderCountry
		replace ProviderCountry="ESPANIA" if prov=="ESP"
		drop prov
		
		** fixing firm name
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
		drop if Provider2=="DEPARTAMENTO"
		drop Provider1 Provider
		rename Provider2 Provider
		
		** fixing email
		gen ProviderEmail1=upper(ProviderEmail)
		replace ProviderEmail1 = subinstr(ProviderEmail1,".","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1," ","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,",","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"/","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"-","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,";","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"&","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,char(34),"",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"(","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,")","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"@","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"FAX","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,":","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"#","",.)
		drop if ProviderEmail1=="NOTIENE"
		drop if ProviderEmail1=="NOREPORTA"
		drop if ProviderEmail1=="NOREGISTRA"
		drop if ProviderEmail1=="NOAPLICA"
		drop if ProviderEmail1=="SINNUMERO"
		drop if ProviderEmail1=="NOREPORTAHOTMAILCOM"
		drop if ProviderEmail1=="NO"
		drop if ProviderEmail1=="NOPRESENTA"
		drop if ProviderEmail1=="3055935515"
		drop if ProviderEmail1=="NOAMERITA"
		drop if ProviderEmail1=="3058712865"
		drop if ProviderEmail1=="44443866"
		drop if ProviderEmail1=="SN"
		drop if ProviderEmail1=="NOEMAIL"
		drop if ProviderEmail1=="6676266"
		drop if ProviderEmail1=="3218151297"
		drop if ProviderEmail1=="3218151311"
		drop if ProviderEmail1==""
		drop if ProviderEmail1=="ND"
		drop if ProviderEmail1=="NOMANIFIESTA"
		drop if ProviderEmail1=="1"
		drop if ProviderEmail1=="0000000000"
		drop if ProviderEmail1=="0"
		drop if ProviderEmail1=="1234567890"
		drop if ProviderEmail1=="N"
		gen str12 ProviderEmail2=ProviderEmail1
		drop ProviderEmail ProviderEmail1
		rename ProviderEmail2 ProviderEmail
		
		** gen Ntrans, Ncountries, NFirms, Nproducts by firm year
		bysort ProviderCountry Provider year: gen NtransFirm=_N
		egen Valuefob=sum(FOBValueUS), by(ProviderCountry Provider year)
		egen Valuecif=sum(CIFValueUS), by(ProviderCountry Provider year)

	
		collapse (mean) Ntrans Valuefob Valuecif, by(ProductHS Provider ProviderCountry ProviderEmail year)
		
	if 1{		
		gen Nvarieties=_N
		egen k=group(ProductHS)
		egen NproductsHS=max(k)
		drop k
		egen k=group(ProviderCountry)
		egen Ncountries=max(k)
		
		collapse (mean) NtransFirm Valuefob Valuecif Nvarieties Ncountries Nproducts, by(year Provider ProviderCountry ProviderEmail)
}
		if `year'==2007{
			save data/temp/tableSummary1, replace
			}
		if `year'!=2007{
			append using data/temp/tableSummary1
			save data/temp/tableSummary1, replace
			}
		
	}
	#delimit ;
	use FOBValueUS CIFValueUS DeclarationDate  
		ProviderEmail
		ProductHS Provider ProviderCountry using data/confidential_data/datamyne/ColombiaImports2008, clear;
		drop if FOBValueUS==0 | CIFValueUS==0 |Provider=="";
		#delimit cr
		**year;
		gen year=year( DeclarationDate)
		keep if year==2008
		
				** fixing country names
		gen str3 prov=ProviderCountry
		replace ProviderCountry="ESPANIA" if prov=="ESP"
		drop prov
		
		** fixing firm name
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
		drop if Provider2=="DEPARTAMENTO"
		drop Provider1 Provider
		rename Provider2 Provider
		
		** fixing email
		gen ProviderEmail1=upper(ProviderEmail)
		replace ProviderEmail1 = subinstr(ProviderEmail1,".","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1," ","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,",","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"/","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"-","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,";","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"&","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,char(34),"",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"(","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,")","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"@","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"FAX","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,":","",.)
		replace ProviderEmail1 = subinstr(ProviderEmail1,"#","",.)
		drop if ProviderEmail1=="NOTIENE"
		drop if ProviderEmail1=="NOREPORTA"
		drop if ProviderEmail1=="NOREGISTRA"
		drop if ProviderEmail1=="NOAPLICA"
		drop if ProviderEmail1=="SINNUMERO"
		drop if ProviderEmail1=="NOREPORTAHOTMAILCOM"
		drop if ProviderEmail1=="NO"
		drop if ProviderEmail1=="NOPRESENTA"
		drop if ProviderEmail1=="3055935515"
		drop if ProviderEmail1=="NOAMERITA"
		drop if ProviderEmail1=="3058712865"
		drop if ProviderEmail1=="44443866"
		drop if ProviderEmail1=="SN"
		drop if ProviderEmail1=="NOEMAIL"
		drop if ProviderEmail1=="6676266"
		drop if ProviderEmail1=="3218151297"
		drop if ProviderEmail1=="3218151311"
		drop if ProviderEmail1==""
		drop if ProviderEmail1=="ND"
		drop if ProviderEmail1=="NOMANIFIESTA"
		drop if ProviderEmail1=="1"
		drop if ProviderEmail1=="0000000000"
		drop if ProviderEmail1=="0"
		drop if ProviderEmail1=="1234567890"
		drop if ProviderEmail1=="N"
		gen str12 ProviderEmail2=ProviderEmail1
		drop ProviderEmail ProviderEmail1
		rename ProviderEmail2 ProviderEmail
		
		** gen Ntrans, Ncountries, NFirms, Nproducts by firm year
		bysort ProviderCountry Provider year: gen NtransFirm=_N
		egen Valuefob=sum(FOBValueUS), by(ProviderCountry Provider year)
		egen Valuecif=sum(CIFValueUS), by(ProviderCountry Provider year)
		
		collapse (mean) Ntrans Valuefob Valuecif, by(ProductHS Provider ProviderCountry ProviderEmail year)
	if 1{
		gen Nvarieties=_N
		egen k=group(ProductHS)
		egen NproductsHS=max(k)
		drop k
		egen k=group(ProviderCountry)
		egen Ncountries=max(k)
		
		collapse (mean) Ntrans Valuefob Valuecif Nvarieties Ncountries Nproducts, by(year Provider ProviderEmail ProviderCountry)
	}	
		append using data/temp/tableSummary1
		collapse (mean) Ntrans Valuefob Valuecif, by(Provider ProviderCountry ProviderEmail year)

		save data/temp/tableSummary1, replace
}



use data/temp/tableSummary1	

sort ProviderCountry Provider
egen TNtransactionsFirm=sum(Ntr), by(ProviderCountry Provider) 
duplicates drop 

sort ProviderEmail Provider ProviderCountry year
egen group_cey=group(ProviderEmail ProviderCountry year)


bysort group_cey: gen Nrepeats=_N

sort group_cey TNtransactionsFirm Provider 

by group_cey : gen identifier=_n
save data/temp/temp1, replace
}






if 1{
	** for 2 duplicates
	use data/temp/temp1, clear
	
	


	keep if Nrepeats==2
	** reshaping
	reshape wide Provider year NtransFirm Valuefob Valuecif TNtransactionsFirm, i(group) j(identifier)
	strdist Provider1 Provider2, gen(strdist)
	keep if strdist<=4
	keep Provider1 Provider2 ProviderCountry 
	rename Provider1 Provider
	duplicates drop
	gen ind=2
	drop if Provider=="TYROBES" |Provider=="ALLAFRANCESA" |Provider=="TECNOBLUCLAB"  |Provider=="NYLACASTENGI"
	save data/temp/Nrepeats2, replace

}



if 1{
	** for 3 duplicates New
	use data/temp/temp1, clear

	keep if Nr==3

	** reshaping
	reshape wide Provider year NtransFirm Valuefob Valuecif TNtransactionsFirm, i(group) j(identifier)
	strdist Provider1 Provider2, gen(strdist)
	keep if strdist<=4
	keep Provider1 Provider2 ProviderCountry 
	rename Provider1 Provider


	keep if (Provider=="AIRCOL13" |Provider=="ALVARADO" |Provider=="AROHMAR4SINT" |Provider=="AVSALEASING2" |Provider=="BAKEPARTNER"  |Provider=="BBBLACBOARDI" |Provider=="CHANGXINGHEW" |Provider2=="CHILESINSAEQ"  |Provider=="CREATIVEBALL" |Provider=="GUANGSHOUXIN" |Provider=="HONSONGROUPC" |Provider2=="JODUPREBVBAY" |Provider=="JPNHARMAPVTL" |Provider=="MRSZIGETI" |Provider2=="MOOGFERNAULI" |Provider=="MOGGFERNAULT" |Provider=="JDTSSVCINC" |Provider2=="NORTHBAYINT" |Provider2=="PANAZURZONAL" |Provider=="PERUVIANWILB" |Provider=="PRECISIONBRU" | Provider2=="SZIGETI" ||Provider2=="SICTIASASCAP" |Provider=="FISHERPANDAG" |Provider2=="WOLVERINETUB" |Provider=="XPSTREMEPERF" | Provider=="YAKANASHIHIT")
	duplicates drop
	gen ind=312
	save data/temp/Nrepeats3_12, replace

}


	
if 1{
	** for 3 duplicates
	use data/temp/temp1, clear
	keep if Nr==3

	** reshaping
	reshape wide Provider year NtransFirm Valuefob Valuecif TNtransactionsFirm, i(group) j(identifier)
	strdist Provider1 Provider3, gen(strdist)
	keep if strdist<=4
	keep Provider1 Provider3 ProviderCountry 
	rename Provider3 Provider2
	rename Provider1 Provider
	duplicates drop
	drop if Provider=="CHEFANGDA" |Provider=="CREATIVEBALL"  |Provider=="FISHERPANDAG" |Provider=="INDEXNINDUSA" |Provider=="MANZONAHONEY" |Provider=="PRECISIONBRU" |Provider=="XPSTREMEPERF" |Provider=="TECNOBLUCLAB" |Provider=="UNIPACKSACOC"
	gen ind=31

	save data/temp/Nrepeats3_1, replace
}

if 1{
	** for 3 duplicates
	use data/temp/temp1, clear
	keep if Nr==3

	** reshaping
	reshape wide Provider year NtransFirm Valuefob Valuecif TNtransactionsFirm, i(group) j(identifier)
	strdist Provider2 Provider3, gen(strdist)
	keep if strdist<=4
	keep Provider2 Provider3 ProviderCountry 
	rename Provider2 Provider
	rename Provider3 Provider2
	duplicates drop
	drop if Provider=="AIRCOL14" |Provider=="AVSALEASING3" |Provider=="MOOGFERNAULI" |Provider=="UNIPACKSACOC" |Provider=="YAMANASHIHIT"
		gen ind=32

	save data/temp/Nrepeats3_2, replace
	


}



append using data/temp/Nrepeats3_12
append using data/temp/Nrepeats3_1
append using data/temp/Nrepeats2
duplicates drop



*Making sure that providers with different variants are converging to one variant
drop if (Provider=="BBBLACBOARDI" |Provider=="CHANGXINGHEW"   |Provider=="JDTSSVCINC"   ) & ind!=312


expand 2 if Provider=="MSSHKELKARCO" |Provider=="ALPHARMAANIM" |Provider=="MIDORIIIINC" |Provider=="SLANTFINCORP"

bysort Provider Provider2 ProviderCountry : gen N1=_n
foreach x in "AROHMARSINTE" "ARTICTTCS" "ALPHARMAANIM" "AXOMATICGROU" "MIDORIIIINC" "JPNPHARMAPVT" "MSSHKELKARCO"	"SLANTFINCORP" "TECNOBLUINDC"{ 
	gen holder=Provider if Provider=="`x'" & N1==2
	replace Provider=Provider2 if Provider=="`x'" &  N1==2
	replace Provider2=holder if holder=="`x'" &  N1==2
	drop holder
}



		
drop N1
bysort Provider Provider2 ProviderCountry : gen N1=_n
drop if N1>1



bysort Provider ProviderCountry: gen N=_N
drop if N>1 & Provider!="AIRCOL13" & Provider2!="AROHMARSINTE" &Provider!="AVSALEASING2" &Provider!="CHRISTIEHOUS" &Provider!="CHILESINSAEQ" &Provider!="CREATIVEBALL" & Provider!="FISHERPANDAG"  & Provider!="NORTHBAYINT" &Provider!="MRSZIGETI" & Provider!="MOOGFERNAULI" & Provider!="MOGGFERNAULT"  & Provider!="MESOESTETIC" & Provider!="MESOESTETIC" & Provider!="ARTICTTCS" & Provider!="NORTHBAYINT"  & Provider!="PANAZURZONAL" &Provider!="PRECISIONBRU" &Provider!="XPSTREMEPERF"
drop N N1
duplicates drop







*Switchign names for Provider and the other variant of porvider to reflect a more used name ot be Provider

local firms2 "ABBNVPOWERQU AIRCOL13	ARMATEKS	ARTHURSKOCIN	AVSALEASING2	BRYAIR ALMACENELPIM	AROHMAR4SINT	ARTHURSKOCIN	AXESSTELINC	BELMARBISTIC	BRAISOGONA	BRAUNSHARING	BRYAIR	CAAYMANCHEMI	CAMFILFARRAI	CANUSAPAPERA	CAVALEROPLAS	CERAMICANOVA	CHELUMBEINTE	CHILDRENSPLU	CHRISTIESHOU	CLIMASTAREFF	CONSORCIOGMC	CREATIVEBALL	CREATIVEDIST	DAMBYPRODUCT	DANIELSDIECU	DELTABOX	DILFIELDSERV	DUALTIMEINTE	EARLLEVALLOI	EASOLUTIONSS	ECOPACK	EDILTECOSRI	EEUROSICSL	ELIZABETHPLE	EMMEGEMSAS	ENEREGETICTE	ETSAMYOT	GARLANDSALEI	GATEWAYSYSTE	GEMSUMFRESHL	GHUANGZHOUHU	GLADEKSA	GOBBETTOSRL	GONZAGARREDI	HENNESSYGRAD	HERSON�SHOND	HIELSCHERUNT	HKSHUNCENGTR	HUANGSHIHOND	HUNANXINHAII	HWASEUGNETWO	IDARELECTRON	IDEXPORT	IDMCIMPRESUB	IFEELEVATORC	IIRSACERO	IKNINC	IMPESAESPORT	INTENSUSEGIN	IOLMOPTHETOT	ISIDROTORIBI	JAFFSONENTER	JCIMPORTACIO	JERRY4SFORDS	JOHNMILLSINT	JOSEMMEDINAC	KELLYCOLORDS	KMPLANTHIRES	KUMHOTIRESUS	LIAONINGYING	LIFESUCCESPR	LOILAINC	MACCHINAMACI	MACQUAIREBAN	MAGICKINDOMI	MARKETLOGICT	MCDOWELLBORT	MEIJEILABELP	METALISESTUN	MICROMED		MIMET	MONTRESMICHE	MSLEDATORSCH	MTVNETWORKAV	N*TECCONSTRU	NAYAX	NBITEENISEDO	NEUMANMACHIN	NILKANTHORGA	NINGBONATIVE	NITROBICFORD	O4DRLLMCMINC	OFFICEOFOVER	OFFICINEELEC	ONGGRONGSUND	OSCARSAUTOSA	PAISTEGMBHCO		PARAGONTECHN	PDMEXPORTTRA	PROMOCOMPO	QINGDAOPARTN	RCIMPORT%EXP	REDCOM	SANIFRUTTASO	SERVERWOLDS	SEVENWELLSIN	SHANGAIHUIXU	SHANGAILOHUI	SHANGHAICOMP	SHANGHAIRYUA		SNCOTINGSTAR	SOCEIDADINTD	SOCIEDADDEIW	SOLITAIREFAS	SOTRTHEASTPR	SPKPROCESSAQ	TACTICS2000S	TEXASOILFIEL	THEKEMWALLEN	TODOPAKSDERL	TOEIREEFERLI	TOPEYACCESOR	TRAFIFURAAGB	UNIPACKSACOC	VERISIGN	VICKOSAERODI	XLEQUIPMENTI		XPXTREMEPERF	YAKANASHIHIT		ZHEGIANGHORD	ACCESORIESGE	ACCOIN	ADVANCEDMARK AIMSPOWERCOR  ACTARISLTDA AFFORDABLETO AIRSTARSA AISISCORPORA ALADNANFOREX ALCEREXPORTC ALLERGAN APPLIANCESEN AQUATROLINC ARESLINESPA AREVATYDHIGH ARVITECHILER ARYZTA ASIATECHGBSG ASSDJOSEJATE ATACPLASTIKM AUTOLABOR AVIANCATACA AXXONFASESUZ BBBLACKBOARD BESTCHOISEMO BIGPRINT BIOFUELTECHN BOCSAVSASDIB BOREALISAG BOSHEDITOR BPSERVICEREP BRODWAYBELTS BWIERRUMGRAV BYDEEOLOSANG CANEXCOLEXPO CARLOSBORJAE CARLTSOESAFE CASDITSRL CASTNYLONSLI CATERCHEMGBM CAVEDERIBEAU CEINTERNATIO CENTRONESNC CHANGXINGHAO CHANGZHOUASC CHATEAUDAXSP CHENTRONICSC CIXIYOUNGYEF CMCMAGNETICS CODIANINC COGNISIMPECO COMPUTACERTE COTECPACKAMG CTPRODUCTSLI DACBOMACHINA	DAQUINTERRAC	DEMBURINC	DESINGHOUSES	DINLARENTRAD	DISTEXSA	DNBHUMIDIFIE	DOMINIOSIMAG	DRDRUGRESEAR	DUALLIFTGMBH	DUCHEMWORLD	DYNAMICMACHI	EDMEDISYSEXP	EDOMYHEALTCA	EHKTECHNOLOG	EMBRACONORTA	EQUIMENTTRUC	ERLENBACHGMB	EUROTEST	EXPOELECPOTE	EXTERRAN	FACTRIONICOR	FAGIAXACESSO	FAPLISAFABRI	FERRETERIASE FISCHERPANDA	FINDTAPECOM	FLORIDATRAID	FORALCONCEPT	FRIEMSDA	FROTEKUKLTD	FRUITDORINC	FUELBELTUSA	FUHRMEISTE	GANESHAEXPO	GEIGRUPOESSE	GENERANTCOMP	GINGOADAIZHI	GLGDIMURAIRL	GORBREXMACHI	GOSAGSAUNIPE	GREENTEXCORP	GRUPONOVEMSI	GUANGZHOUDOH	GUANGZHOUSPI	GVISAMSUNGEL	HACIENDASMAR	HANNOVERMEXI	HARRYSEIDNER	HBFULLERIASR	HELINTERNATI	HOHNER	HOLLOWELPROD	HSHOOGERHUIL IBEXPARTS	ICCOACCESORI	IMDCHINACOLT	INFOTECHNYIN	INNOVATIONBE	INTERPACKITA	INTERPORTINT	INVESTORTRUS	JACKSONMSC	JARLWAYXINXI	JAVIERMERINO	JDTSVCINC	JIAXINGJUNYE	JNEQUIPAMENT	JOALCATRADIN	JODUPREBVBAY	KEESAMGCORPO	KIMALMACKING	KRONOPLY	LANCOHARRIEC	LEADLIGHTING	LGCWIRELESAN	LOGICAIRGROU	LPGTECHLTD	LPRINOSFOODS	LUCKYGEMSJAW	LUZDELARIVAB	MAMUNDOVARIE	MERCEDESAMPA	MERCHANTEXPO	MERCONCOFFEC		MICROENVASE	MICROINC	MIINTERNATIO MOGGFERNAULT	MQUINARIAYTR	 MRSZIGETI	MSCFAREASTIN	MSMARKANSASP	NANMATTECHON	NANYIINTLLIG	NETWORLDIT	NGRPROCESSSO	NIGOCERAMICL	NINGBOHENGEL	NOBLEHARVESC	NORMABARRECA	NUCLETRONOPE	OILFIELDEQUI	ONLINESALE	P3INTERNACIO PANAZURZONAL	PATMSAPPAREL	PAVIOERICCHR	PEACECORPSHE	PEDROLLOOFFL	PEINEMANNEQU	PENGOCOKATE	PHELPSDODGEC	PHILXN	PICCHIGROUPS	PJBAKERY3021	POWEREX	POWERSTREMTE	PRENSOLAND	PROTECHNO	PUREH2OTECHN	QINGDAOEMPCO	QUANTUMDESIN	QUESTINT4LAD	RAJRAYONLTD	REYNALDOARIE	RIOTINTO	ROCELSHKING	ROWDENYSONS	RTDHALLSTARI	RUGUISLU	RUIANYUZHOUA	RUKSHMANISYB	SAFARIMIAMIL	SAMARTHOMEPR	SAMPEXINDCOM	SANIGNACIOKI	SCHIRTSCOLLE	SCHUSTERAUTO	SCHWIHAGAG	SEEBECKINSTR	SERVICIOSPAC	SHANGAIOMNIL	SHANGHAIRAQI	SHANTOULIANT	SHAOXINGBAOF	SHENYANGFUSH	SHENZENARTLO	SHOLLELTDA	SICTIASASCAP	SIMANSTONES	SJAFILMTECHN	SKINNTECHNOL	SKYSTREANNET	SOCINCER21SA	SODEMDIFUSSI	SONACVUREN	SPORTLINEIND	SPORTSPARNER	SPREAFICOFRA	SRKCONSULTIN	SS8NETWORKS	STEELCANADAL	SYNCHRATECH	TECHNICALAND	TECHNICOLORD	TECNOPOWERSY	THBALTESGMBH	THESERVICECE	THEUNDERSECR	TITANWHEELIN	TRACFONE	TREVIICOS	TROOSTWIJKAG	TTWORLDWIDEC	TYGCORPORATI	UNILEVELINTL	USANETWORKBN	USIMECAUSINA	VALTERDOMINA	VENCOREXCHEM	VERTISOL	VIBRODYNAMIC	VIBROMAQBIGG	VICTORYINTLS	VILLAD4AGRIS	VIVOTECH	VOLCUERSRL	WATANABEINDE	WESTICATVSUP	WESTLEYPLAST	WHIRLPOOLPER	WILLIANBRUDO	WILLMORSA	WINNERVALVES	WORLWIDE	WYNNSTARR	YIWUSHUNXIN	ZHEJIANTAIJI	ZHONGSHANOFF "

foreach x of local firms2 {
	gen holder=Provider if Provider=="`x'"
	replace Provider=Provider2 if Provider=="`x'"
	replace Provider2=holder if holder=="`x'"
	drop holder
}



local firms2 "AROHMAR4SINT CHILESINLTDA CHRISTIESHOU MESOESTETICU NORTHBAYINTL	PRECISIONPLA SOCIETATESSI "

foreach x of local firms2 {
	gen holder=Provider2 if Provider2=="`x'" & Provider!="CHISTIESHOUS"
	replace Provider2=Provider if Provider2=="`x'" & Provider!="CHISTIESHOUS"
	replace Provider=holder if holder=="`x'" & Provider!="CHISTIESHOUS"
	drop holder
}

*Rearranging Providers with unclear symbols "?"
		
gen str4 ProviderStr4=Provider
gen str6 ProviderStr6= Provider
local firms4 "TITO"
foreach x of local firms4 {
	gen holder=Provider if ProviderStr4=="`x'"
	replace Provider=Provider2 if ProviderStr4=="`x'"
	replace Provider2=holder if ProviderStr4=="`x'"
	drop holder
}


local firms6 "GRADDY "
foreach x of local firms6 {
	gen holder=Provider if ProviderStr6=="`x'"
	replace Provider=Provider2 if ProviderStr6=="`x'"
	replace Provider2=holder if ProviderStr6=="`x'"
	drop holder
}



*Dealing with Providers with similar names but in different countries

gen holder=Provider if Provider=="D2MASQ" & ProviderCountry=="ITALIA"
	replace Provider=Provider2 if Provider=="D2MASQ" & ProviderCountry=="ITALIA"
	replace Provider2=holder if holder=="D2MASQ" & ProviderCountry=="ITALIA"
	drop holder

	gen holder=Provider if Provider=="SPEDITIONHOO" & ProviderCountry=="ALBANIA"
	replace Provider=Provider2 if Provider=="SPEDITIONHOO" & ProviderCountry=="ALBANIA"
	replace Provider2=holder if holder=="SPEDITIONHOO" & ProviderCountry=="ALBANIA"
	drop holder
	
	gen holder=Provider if Provider=="PANASONICAVC" & ProviderCountry=="MALAYSIA"
	replace Provider=Provider2 if Provider=="PANASONICAVC" & ProviderCountry=="MALAYSIA"
	replace Provider2=holder if holder=="PANASONICAVC" & ProviderCountry=="MALAYSIA"
	drop holder
	
		gen holder=Provider if Provider=="TROYINTERNAC" & ProviderCountry=="TAILANDIA"
	replace Provider=Provider2 if Provider=="TROYINTERNAC" & ProviderCountry=="TAILANDIA"
	replace Provider2=holder if holder=="TROYINTERNAC" & ProviderCountry=="TAILANDIA"
	drop holder


sort Provider Provider2 ProviderCountry
drop ProviderStr*

save data/temp/firms_clean, replace

erase data/temp/tableSummary1.dta
erase data/temp/temp1.dta
erase data/temp/Nrepeats3_12.dta
erase data/temp/Nrepeats3_1.dta
erase data/temp/Nrepeats3_2.dta
erase data/temp/Nrepeats2.dta





