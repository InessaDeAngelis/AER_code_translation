/******************************************************************************
Project:    A Signal to End Child Marriage: Theory and Experimental Evidence from Bangladesh
File Name:  0_a_Main.do
Purpose:    Master File

Do File Structure:
- Numbers show the absolute order of do-files and do-files are order-specific. 
- Previous do-files have to be run first.

******************************************************************************/
* Opening commands
clear all
clear matrix
set more off
version 17.0
cap log close _all
cap estimates drop _all
cap eststo drop _all
set maxvar 32000
set mem 1g
set scheme s2color, permanently

** install user-written commands
local commands xsvmat estout suregr unique
foreach c of local commands {
	qui capture which `c'
	qui if _rc == 111 {
		dis "Installing `c' to label data..."
		cap noi ssc install `c', replace
	}
}

********************************************************************************
** change the path in "user" global to the main folder
gl user     "C:\Users\ncbuc\Duke Development Lab Dropbox\Nina Buchmann\KK\Papers\Signaling\AER Submission\Prepping for final submission\Data and code\replication_folder_to_share"

** defining Global file paths
gl dof 		"$user\Dofiles"
gl data     "$user\Data"
gl logs 	"$dof\Logs"
gl output   "$user"
gl tables 	"$output\Tables"
gl graphs 	"$output\Graphs"

* DHS individual recode
gl dhsir2004 "$data\DHS_raw_data\individual_recode\BDIR4JFL_2004"
gl dhsir2007 "$data\DHS_raw_data\individual_recode\BDIR51FL_2007"
gl dhsir2011 "$data\DHS_raw_data\individual_recode\BDIR61FL_2011"
gl dhsir2014 "$data\DHS_raw_data\individual_recode\BDIR70FL_2014"
gl dhsir2017 "$data\DHS_raw_data\individual_recode\BDIR7RFL_2017"

* DHS birth recode
gl dhsbr2004 "$data\DHS_raw_data\births_recode\BDBR4JFL_2004"
gl dhsbr2007 "$data\DHS_raw_data\births_recode\BDBR51FL_2007"
gl dhsbr2011 "$data\DHS_raw_data\births_recode\BDBR61FL_2011"
gl dhsbr2014 "$data\DHS_raw_data\births_recode\BDBR70FL_2014"
gl dhsbr2017 "$data\DHS_raw_data\births_recode\BDBR7RFL_2017"


** defining control variables
gl controls "older_sister bl_still_in_school bl_education_mother bl_HHsize bl_public_transit bl_age6 bl_age7 bl_age8 bl_age9 bl_age10 bl_age11 bl_age12 bl_age13 bl_age14 bl_age15 bl_age16 bl_age17"
gl miss 	"older_sister_miss bl_still_in_school_miss bl_education_mother_miss bl_HHsize_miss bl_public_transit_miss"

local date: dis %td_NN_DD_CCYY date(c(current_date), "DMY")
gl date_string = subinstr(trim("`date'"), " " , "_", .)


** Run analysis do files
*(Please run all do files from this file only)
cd "$dof"

do 1_clean_DHS          // Clean DHS data

do 2_balance            // Balance 

do 3_attrition          // Attrition

do 4_summ_stats			// Summary Statistics

do 5_graphs             // Graphs

do 6_model_assumptions  // Model assumptions

do 7_regression_tables  // Regressions
