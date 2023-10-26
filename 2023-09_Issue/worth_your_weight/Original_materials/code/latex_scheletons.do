	***************************************************************************	
	* Compiles latex scheletons for main tables for "Worth Your Weight" (Macchi)
	
	***************************************************************************	

	
	global table2 _table2_mainbeliefs
	global tab2a  tab2a_firstorderbeliefs
	global tab2b  tab2b_firstorderbeliefs
	
	global table3 _table3_obesitypremium
	global tab3   tab3_obesitypremium

	global table4 _table4_obesitypremiumbytype
	global tab4   tab4_obesitypremiumbytype
	
	
	
	* Table 2 ---
	
	cap file close summary
	file open summary using  "$path/output/tables/${table2}.tex", write replace
	file write summary  "\begin{tabular}{l*{7}{c}}"  _n
	file write summary  "\hline\hline"  _n
	file write summary  "&\multicolumn{1}{c}{(1)}   &\multicolumn{1}{c}{(2)}         &\multicolumn{1}{c}{(3)}         &\multicolumn{1}{c}{(4)}         &\multicolumn{1}{c}{(5)}  &\multicolumn{1}{c}{(6)}   &\multicolumn{1}{c}{(7)}         \\"  _n
	file write summary  "  &\multicolumn{1}{c}{Wealth}  &\multicolumn{1}{c}{Beauty}         &\multicolumn{1}{c}{Health}         &\multicolumn{1}{c}{\shortstack{Life\\ expectancy}}         &\multicolumn{1}{c}{\shortstack{Self\\-control}}  &\multicolumn{1}{c}{Ability}   &\multicolumn{1}{c}{\shortstack{Trust-\\worthiness}  }       \\"  _n
	file write summary  "\hline "  _n
	********* PANEL A
	file write summary  ""  _n
	file write summary  "\\" _n
	file write summary  "\multicolumn{2}{c}{\textbf{First-order beliefs}}	&	&	&	&  & \\"  _n
	file write summary  " \\" _n
	file write summary  "\input{tables/${tab2a}.tex}"  _n
	file write summary  "   \\"  _n
	********* PANEL A
	file write summary  "  \\" _n
	file write summary  "\multicolumn{2}{c}{\textbf{Beliefs about others' beliefs}} &	&	&	&  & \\"  _n
	file write summary  " \\" _n
	file write summary  "\input{tables/${tab2b}.tex}"  _n
	file write summary  " "  _n
	file write summary  "   \\"  _n
	******* END
	file write summary  "\hline\hline"  _n
	file write summary  "\end{tabular}"  _n
	file close summary		
	
	
	
	* Table 3 ---
	
	cap file close summary
	file open summary using  "$path/output/tables/${table3}.tex", write replace
	file write summary  "\begin{tabular}{l*{5}{c}}"  _n
	file write summary  "\hline\hline"  _n
	file write summary  "  &\multicolumn{1}{c}{(1)}   &\multicolumn{1}{c}{(2)}         &\multicolumn{1}{c}{(3)}         &\multicolumn{1}{c}{(4)}       &\multicolumn{1}{c}{(5)}           \\"  _n
	file write summary  "  &\multicolumn{1}{c}{\shortstack{Approval \\ likelihood}}     &\multicolumn{1}{c}{\shortstack{Financial\\ ability}}   &\multicolumn{1}{c}{\shortstack{Credit- \\ worthiness}} &\multicolumn{1}{c}{\shortstack{Referral \\ request}}  &\multicolumn{1}{c}{\shortstack{Information \\ reliability}} \\"  _n
	file write summary  "\hline "  _n
	file write summary  "   \\"  _n
	file write summary  "\input{tables/${tab3}.tex}"  _n
	file write summary  " "  _n
	file write summary  "   \\"  _n
// 	******* END
	file write summary  "\hline\hline"  _n
	file write summary  "\end{tabular}"  _n	

	file close summary		

	
	
	* Table 4 ---
	
	cap file close summary
	file open summary using  "$path/output/tables/${table4}.tex", write replace
	file write summary  "\begin{tabular}{l*{4}{c}}"  _n
	file write summary  "\hline\hline"  _n
	file write summary  "  &\multicolumn{1}{c}{(1)}   &\multicolumn{1}{c}{(2)}  &\multicolumn{1}{c}{(3)}  &\multicolumn{1}{c}{(4)}    \\"  _n
	file write summary  "  &\multicolumn{1}{c}{\shortstack{Approval \\ likelihood}}     &\multicolumn{1}{c}{\shortstack{Financial\\ ability}}   &\multicolumn{1}{c}{\shortstack{Credit- \\ worthiness}} &\multicolumn{1}{c}{\shortstack{Referral \\ request}} \\"  _n
	file write summary  "\hline "  _n
	file write summary  "   \\"  _n
	file write summary  "\input{tables/${tab4}.tex}"  _n
	file write summary  " "  _n
	file write summary  "   \\"  _n
// 	******* END
	file write summary  "\hline\hline"  _n
	file write summary  "\end{tabular}"  _n	

	file close summary		

	
	
	