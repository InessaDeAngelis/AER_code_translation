PROFITS, SCALE ECONOMIES, & THE GAINS FROM TRADE & INDUSTRIAL POLICY (2023)
Authors: Lashkaripour, A. and V. Lugovskyy

----------------
Folder structure
----------------

Use 'run_all_files' to execute all the functions in the 'Matlab' project. 

For things to work as designed, one must preserve the following folder structure:

- auxiliary 		(folder containing auxiliary files/functions)
- ../input   		(folder to stores output)
- ../output 		(folder to read data inputs)
- run_all_files.m 	(Matlab Code)

---------------
Basic operation
---------------
The script 'run_all_files' runs all the programs and generates all the outputs in the 'Matlab' project. Running this script also generates the necessary output for the 'Stata' project.

--------------------
Description of files
--------------------
%-- level 1 -%

run_all_files	- Main MATLAB file——generates all figures/tables derived from the Matlab project
figure_1      	- Generates figures associated with Figure 1 in the draft.
table_2     	- Generates a Tex file that produces Table 2 in the draft.
table_4     	- Generates a Tex file that produces Table 4 in the draft.
table_5     	- Generates a Tex file that produces Table 5 in the draft. 
figure_2     	- Generates the data (for STATA) to create Figure 2 in the draft. 
figure_3     	- Generates the data (for STATA) to create Figure 3 in the draft.
figure_E1     	- Generates Figure E.1 in the online appendix.
appendix_H       - Simulates data (for STATA) to produce Figures H1-H3 in the online appendix.
table_V1      	- Generates a Tex file that produces Table V1. in the online appendix.
appendix_W       - Generates the data (for STATA) to create Figures W1-W2 in the online appendix.
figure_X1       	- Generates figure X.1 the online appendix.
appendix_Y      	- Generates the data (for STATA) to create Figures Y1-Y3 in the online appendix.
figure_Z1     	- Generates figure Z.1 the online appendix.


%-- auxiliary folder --%

f_Read_Raw_Data_T4      		- Reads the raw data files (Table 4).
f_Read_Raw_Data_T5      		- Reads the raw data files (Table 5).
f_Read_Raw_Data_Melitz  		- Reads the raw data files (Figure Y1).
f_Read_Raw_Data_FixedEffects  	- Reads the raw data files (Figure Y2).
f_Read_Raw_Data_AltSrv            - Reads the raw data files (Figure Y3).
f_Read_Raw_Data_AV                - Reads the raw data files (Table V1)
f_Balance_Data_RE                 - Purges data from trade imbalances (restricted entry)
f_Balance_Data_FE		- Purges data from trade imbalances (free entry)
f_First_Best_RE	                 - Computes the gains from 1st-best policies based on Theorem 1 (restricted entry)
f_Second_Best_RE                  - Computes the gains from 2nd-best policies based on Theorem 2 (restricted entry)
f_Third_Best_RE			- Computes the gains from 3rd-best policies based on Theorem 3 (restricted entry)
f_First_Best_FE	                 - Computes the gains from 1st-best policies based on Theorem 1 (free entry)
f_Second_Best_FE                  - Computes the gains from 2nd-best policies based on Theorem 2 (free entry) 
f_Third_Best_FE			- Computes the gains from 3rd-best policies based on Theorem 3 (free entry) 
f_Obj_MPEC_RE	                 - Computes the policy objective for the MPEC approach (restricted entry)
f_Const_MPEC_RE                 	- Specifies the equilibrium constraints for the MPEC approach (restricted entry)
f_Obj_MPEC_FE			- Computes the policy objective for the MPEC approach (free entry)
f_Const_MPEC_FE  	        	- Specifies the equilibrium constraints for the MPEC approach (free entry)
f_Welfare_Gains_RE                - Computes the welfare gains given tax choice (restricted entry) 
f_Welfare_Gains_FE		- Computes the welfare gains given tax choice (free entry)
f_Retaliation_RE  	        	- Computes the welfare loss from retaliation (restricted entry, Table 4)
f_Retaliation_FE                 	- Computes the welfare loss from retaliation (free entry, Table 4) 
f_Growth_RE			- Computes the gains from unilateral markup correction  

