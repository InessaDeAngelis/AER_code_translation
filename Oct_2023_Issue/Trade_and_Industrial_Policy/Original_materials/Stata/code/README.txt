PROFITS, SCALE ECONOMIES, & THE GAINS FROM TRADE & INDUSTRIAL POLICY (2023).
Authors: Lashkaripour, A. and V. Lugovskyy

----------------
Folder structure
----------------

Use 'run-all-dofiles.do' to execute all the functions in the 'Stata' project. 

For things to work as designed, one must preserve the following folder structure:

- analysis 		(folder containing do-file that perform analysis)
- data_prep		(folder containing do-file that prepare data)
- ../data   		(folder to read data)
- ../output 		(folder to stores output)
– ../../Matlab		(folder containing the Matlab project)
- run-all-dofiles.do 	(STATA Code)

---------------
Basic operation
---------------
The script 'run-all-dofiles.do' runs all the programs and generates all the outputs in the 'Stata' project. If you do not have access to confidential trade data from Datamyne.com, assign the global macro 'access_to_datamyne' the value 'no' instead of 'yes'. If you do not have access to the confidential data from the Exporter Dynamics Database, assign to the global macro 'access_to_edd' the value 'no' instead of 'yes'.


--------------------
Description of files
--------------------
%-- analysis folder --%

run-all-dofiles	- Main STATA file—generates all figures/tables derived from the Stata project
1-table_3     	- Replicates Table 3 in Section VI of the paper in Tex format
2-figure_2    	- Replicates Figure 2 in Section VII of the paper
3-figure_3    	- Replicates Figure 3 in Section VII of the paper
4-figure_H1    	- Replicates Figure H1 of the Online Appendix H
5-figure_H2     	- Replicates Figure H2 of the Online Appendix H
6-figure_H3     	- Replicates Figure H3 of the Online Appendix H
7-table_N1   	- Replicates Table N1 of the Online Appendix N in Tex format
8-figure_O1      - Replicates Figure O1 of the Online Appendix O
9-figure_P1      - Replicates Figure P1 of the Online Appendix P
10-table_Q1      - Replicates Table Q1 of the Online Appendix Q in Tex format
11-table_R1      - Replicates Table R1 of the Online Appendix R in Tex format
12-table_S1      - Replicates Table S1 of the Online Appendix S in Tex format
13-figure_S1     - Replicates Figure S1 of the Online Appendix S
14-figure_W1     - Replicates Figure W1 of the Online Appendix W
15-figure_W2     - Replicates Figure W2 of the Online Appendix W
16-figure_Y1     - Replicates Figure Y1 of the Online Appendix Y
17-figure_Y2     - Replicates Figure Y2 of the Online Appendix Y
18-figure_Y3     - Replicates Figure Y3 of the Online Appendix Y


%-- data_prep folder --%

0-clean_firm_names      	  	- Cleans and synchronizes firm names in the Datamyne data
1-merge_raw_import_data    	- Merges Datamyne data files for years 2007 to 2013
2-revise_hs_codes 		- Revises HS codes to make the compatible across years
3-construct_variables  		- Constructs the variables needed to run the demand estimation
4-robustness_check_1              - Prepares data for robustness check 1 (Figure P1.A)
5-robustness_check_2              - Prepares data for robustness check 2 (Figure P2.B)
6-robustness_check_3              - Prepares data for robustness check 3 (Figure P1.C)
