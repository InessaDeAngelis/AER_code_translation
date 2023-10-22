
/*
Each do file below defines variables, labels them and prepares the data for analysis. The filename corresponds to the studies in the paper: Experiment 1, Experiment 2, Alzheimer's Disease, IQ test and Experiment 3 (presented only in the appendix).

These files can be run independentently. Their sequence does not matter.
*/

cd "$root"

do "$root/Code/Exp1_dataprep.do"
do "$root/Code/Exp2_dataprep.do"
do "$root/Code/AD_dataprep.do"
do "$root/Code/IQ_dataprep.do"
do "$root/Code/Exp3_dataprep.do"





