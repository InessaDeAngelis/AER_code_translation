*This do file plots rational inattention graphs: Figures a14, a15, a16

*Final products:
*rational_inattention_ActiveChoiceResponse_scaled_All.eps;
*rational_inattention_SwitchDecDec_All.eps;
*rational_inattention_ActiveChoiceResponse_scaled_Top50Spread.eps;
*rational_inattention_SwitchDecDec_Top50Spread.eps;
*rational_inattention_ActiveChoiceResponse_scaled_Top25Spread.eps;
*rational_inattention_SwitchDecDec_Top25Spread.eps

cd "/Users/AdelinaWang/Dropbox/Part D Behavioral/Rational Inattention Code"


foreach x in All {
		
	import excel "CoeffstoGraph_`x'.xlsx", sheet("Sheet1") firstrow clear
	
	gen DrugResponse_neg = - DrugResponse
	
	sort DrugResponse_neg


	twoway connected ActiveChoiceResponse DrugResponse_neg, graphregion(color(white)) xtitle("Change in Consumption (Drug Spending) in %") ytitle("Active Choice Reponse") ylabel(0(0.2)1) xlabel(-15(5)0)
	graph export "rational_inattention_ActiveChoiceResponse_scaled_`x'.eps", replace
	graph export "rational_inattention_ActiveChoiceResponse_scaled_`x'.png", replace

		*Figure A14
	twoway connected SwitchDecDec DrugResponse_neg, graphregion(color(white)) xtitle("Change in Consumption (Drug Spending) in %") ytitle("Switch by Dec") ylabel(0(0.2)1) xlabel(-15(5)0)
	graph export "rational_inattention_SwitchDecDec_`x'.eps", replace
	graph export "rational_inattention_SwitchDecDec_`x'.png", replace
	

}


*Figure A15, A16
foreach x in Top50Spread Top25Spread {
		
	import excel "CoeffstoGraph_`x'.xlsx", sheet("Sheet1") firstrow clear

	gen DrugResponse_neg = - DrugResponse
	
	sort DrugResponse_neg

	twoway connected ActiveChoiceResponse DrugResponse_neg, graphregion(color(white)) xtitle("Change in Consumption (Drug Spending) in %") ytitle("Active Choice Reponse") ylabel(0(0.2)1) xlabel(-30(10)0)
	graph export "rational_inattention_ActiveChoiceResponse_scaled_`x'.eps", replace
	graph export "rational_inattention_ActiveChoiceResponse_scaled_`x'.png", replace

	twoway connected SwitchDecDec DrugResponse_neg, graphregion(color(white)) xtitle("Change in Consumption (Drug Spending) in %") ytitle("Switch by Dec") ylabel(0(0.2)1) xlabel(-30(10)0)
	graph export "rational_inattention_SwitchDecDec_`x'.eps", replace
	graph export "rational_inattention_SwitchDecDec_`x'.png", replace
	

}

