	***************************************************************************	
	* Compiles latex scheletons for appendix tables for "Worth Your Weight" (Macchi)
	
	***************************************************************************	

	global tableA2 _tableA2_heterogeneitywealthsignal
	global tabA2  tabA2_heterogeneitywealthsignal
	
		
	global tableA5 _tableA5_robustnessorder
	global tabA5  tabA5_robustnessorder
	
	global tableA6 _tableA6_earningspremium
	global tabA6  tabA6_earningspremium
	
	global tableA7 _tableA7_robustnessattention
	global tabA7  tabA7_robustnessattention
	
	global tableA8 _tableA8_robustnessarm
	global tabA8  tabA8_robustnessarm
	
	global tableA10 _tableA10_robustnessmenvsmen
	global tabA10  tabA10_robustnessmenvsmen
	
	global tableA11 _tableA11_heteroloanoffchrs
	global tabA11  tabA11_heteroloanoffchrs

	global tableA14 _tableA14_unpscorrelation
	global tabA14  tabA14_unpscorrelation
	
	
	* Table A2
	
	cap file close summary
	file open summary using  "$path/output/tables/${tableA2}.tex", write replace
	file write summary  "\begin{tabular}{l*{3}{c}}"  _n
	file write summary  "\hline\hline"  _n
	file write summary  "  &\multicolumn{1}{c}{(1)}   &\multicolumn{1}{c}{(2)}    &\multicolumn{1}{c}{(3)}     \\"  _n
	file write summary  "  &\multicolumn{1}{c}{Wealth}  &\multicolumn{1}{c}{Wealth}   &\multicolumn{1}{c}{Wealth} \\"  _n
	file write summary  "\hline "  _n
	file write summary  ""  _n
	file write summary  "\input{tables/${tabA2}.tex}"  _n
	********* PANEL 
	file write summary  " \\" _n
	file write summary  "\hline\hline"  _n
	file write summary  "\end{tabular}"  _n
	file close summary		
	
	* Table A5
	

	
	cap file close summary
	file open summary using  "$path/output/tables/${tableA5}.tex", write replace
	file write summary  "\begin{tabular}{l*{4}{c}}"  _n
	file write summary  "\hline\hline"  _n
	file write summary  " &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)}         &\multicolumn{1}{c}{(3)}         &\multicolumn{1}{c}{(4)}               \\"  _n
	file write summary  " &\multicolumn{1}{c}{\shortstack{Approval \\ likelihood}}      &\multicolumn{1}{c}{\shortstack{Financial\\ ability}}   &\multicolumn{1}{c}{\shortstack{Credit- \\ worthiness}} &\multicolumn{1}{c}{\shortstack{Referral \\ request}}  \\"  _n
	file write summary  "\hline "  _n
	file write summary  "\input{tables/${tabA5}.tex}"  _n
	file write summary  "   \\"  _n
	file write summary  "\hline\hline"  _n
	file write summary  "\end{tabular}"  _n

	file close summary	
	
	* Table A6
	cap file close summary
	file open summary using  "$path/output/tables/${tableA6}.tex", write replace
	file write summary  "\begin{tabular}{l*{4}{c}}"  _n
	file write summary  "\hline\hline"  _n
	file write summary  " &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)}         &\multicolumn{1}{c}{(3)}         &\multicolumn{1}{c}{(4)}               \\"  _n
	file write summary  " &\multicolumn{1}{c}{\shortstack{Approval \\ likelihood}}      &\multicolumn{1}{c}{\shortstack{Financial\\ ability}}   &\multicolumn{1}{c}{\shortstack{Credit- \\ worthiness}} &\multicolumn{1}{c}{\shortstack{Referral \\ request}}  \\"  _n
	file write summary  "\hline "  _n
	file write summary  "\input{tables/${tabA6}.tex}"  _n
	file write summary  "   \\"  _n
	file write summary  "\hline\hline"  _n
	file write summary  "\end{tabular}"  _n

	file close summary	
	

	
	* Table A7
	
	cap file close summary
	file open summary using  "$path/output/tables/${tableA7}.tex", write replace
	file write summary  "\begin{tabular}{l*{4}{c}}"  _n
	file write summary  "\hline\hline"  _n
	file write summary  " &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)}         &\multicolumn{1}{c}{(3)}         &\multicolumn{1}{c}{(4)}               \\"  _n
	file write summary  " &\multicolumn{1}{c}{\shortstack{Approval \\ likelihood}}      &\multicolumn{1}{c}{\shortstack{Approval \\ likelihood}}   &\multicolumn{1}{c}{\shortstack{Approval \\ likelihood}} &\multicolumn{1}{c}{\shortstack{Approval \\ likelihood}}  \\"  _n
	file write summary  "\hline "  _n
	file write summary  "\input{tables/${tabA7}.tex}"  _n
	file write summary  "   \\"  _n
	file write summary  "\hline\hline"  _n
	file write summary  "\end{tabular}"  _n

	file close summary		

	* Table A8
	cap file close summary
	file open summary using  "$path/output/tables/${tableA8}.tex", write replace
	file write summary  "\begin{tabular}{l*{4}{c}}"  _n
	file write summary  "\hline\hline"  _n
	file write summary  " &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)}         &\multicolumn{1}{c}{(3)}         &\multicolumn{1}{c}{(4)}               \\"  _n
	file write summary  " &\multicolumn{1}{c}{\shortstack{Approval \\ likelihood}}      &\multicolumn{1}{c}{\shortstack{Financial\\ ability}}   &\multicolumn{1}{c}{\shortstack{Credit- \\ worthiness}} &\multicolumn{1}{c}{\shortstack{Referral \\ request}}  \\"  _n
	file write summary  "\hline "  _n
	file write summary  "\input{tables/${tabA8}.tex}"  _n
	file write summary  "   \\"  _n
	file write summary  "\hline\hline"  _n
	file write summary  "\end{tabular}"  _n

	file close summary	

	* Table A10	
	cap file close summary
	file open summary using  "$path/output/tables/${tableA10}.tex", write replace
	file write summary  "\begin{tabular}{l*{4}{c}}"  _n
	file write summary  "\hline\hline"  _n
	file write summary  " &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)}         &\multicolumn{1}{c}{(3)}         &\multicolumn{1}{c}{(4)}               \\"  _n
	file write summary  " &\multicolumn{1}{c}{\shortstack{Approval \\ likelihood}}      &\multicolumn{1}{c}{\shortstack{Financial\\ ability}}   &\multicolumn{1}{c}{\shortstack{Credit- \\ worthiness}} &\multicolumn{1}{c}{\shortstack{Referral \\ request}}  \\"  _n
	file write summary  "\hline "  _n
	file write summary  "\input{tables/${tabA10}.tex}"  _n
	file write summary  "   \\"  _n
	file write summary  "\hline\hline"  _n
	file write summary  "\end{tabular}"  _n
	file close summary	
	
	* Table A11
	
	cap file close summary
	file open summary using  "$path/output/tables/${tableA11}.tex", write replace
	file write summary  "\begin{tabular}{l*{9}{c}}"  _n
	file write summary  "\hline\hline"  _n
	file write summary  "\\"  _n
	file write summary  " \multicolumn{1}{c}{\shortstack{Approval likelihood}} &\multicolumn{1}{c}{(1)}   &\multicolumn{1}{c}{(2)}    &\multicolumn{1}{c}{(3)}         &\multicolumn{1}{c}{(4)}     &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)}  &\multicolumn{1}{c}{(7)}           &\multicolumn{1}{c}{(8)}  &\multicolumn{1}{c}{(9)}                                          \\"  _n
	file write summary  " &\multicolumn{1}{c}{Age}  &\multicolumn{1}{c}{BMI}  &\multicolumn{1}{c}{Education}    &\multicolumn{1}{c}{Experience}         &\multicolumn{1}{c}{Days verify}     &\multicolumn{1}{c}{Gender} &\multicolumn{1}{c}{Owner}  &\multicolumn{1}{c}{\shortstack{Performance pay: \\ Any }} &\multicolumn{1}{c}{\shortstack{Performance pay: \\ Sales volume}}                              \\"  _n
	file write summary  "\hline "  _n
	file write summary  "   \\"  _n
	file write summary  "\input{tables/${tabA11}.tex}"  _n
	file write summary  " "  _n
	file write summary  "   \\"  _n
	file write summary  "\hline\hline"  _n
	file write summary  "\end{tabular}"  _n


	file close summary		
	
	* Table A14
	cap file close summary
	file open summary using  "$path/output/tables/${tableA14}.tex", write replace
	file write summary  "\begin{tabular}{l*{3}{c}}"  _n
	file write summary  "\hline\hline"  _n
	file write summary  "\\"  _n
	file write summary  " &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)}         &\multicolumn{1}{c}{(3)}                    \\"  _n
	file write summary  " \\ &\multicolumn{1}{c}{\shortstack{Borrowed}}   &\multicolumn{1}{c}{\shortstack{Borrowed }} &\multicolumn{1}{c}{\shortstack{Repaid}}     \\"  _n
	file write summary  "   \\"  _n
	file write summary  "\input{tables/${tabA14}.tex}"  _n
	file write summary  " "  _n
	file write summary  "   \\"  _n
	file write summary  "\hline\hline"  _n
	file write summary  "\end{tabular}"  _n	
	file close summary		




			
			
			
		