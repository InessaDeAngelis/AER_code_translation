clear all
set more off
cap log close
log using ../output/log, replace text
cap mkdir ../temp
adopath + ../../../../trunk/lib/ado/

*Purpose: Clean up plan file-map encrypted plan ID's to actual plan ID's. Used as input in other files

cd "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/compiled_data_plan_details/code/"

global plan_details "../../plan_details/output/plan_details"
global plans "../../../../trunk/derived/plans/output/plans_regions"
global compiled_data "../../../../trunk/derived/compiled_data/output/compiled_data_full_sample_20pct"

program main
    use contract_id plan_id year contract_id_encrypted plan_id_encrypted using $plans, clear
    drop if contract_id_encrypted=="" | plan_id_encrypted==""
    duplicates drop
    save ../temp/crosswalk, replace
    use bene_id year contract_id plan_id cntrct* pbpid* using $plan_details, clear
    merge m:1 bene_id year using $compiled_data, assert(1 3) keep(3) keepusing(bene_id year) nogen
    rename contract_id contract_id_assigned
    rename plan_id plan_id_assigned
    rename cntrct0* cntrct*
    rename pbpid0* pbpid*
    reshape long cntrct pbpid, i(bene_id year contract_id_assigned plan_id_assigned) j(month)
    rename cntrct contract_id_encrypted
    rename pbpid plan_id_encrypted
    merge m:1 contract_id_encrypted plan_id_encrypted year using ../temp/crosswalk, ///
        keepusing(*) nogen
    rename contract_id contract_id_enrolled
    rename plan_id plan_id_enrolled
    replace contract_id_enrolled=contract_id_encrypted if year==2007|year>2012
    replace plan_id_enrolled=plan_id_encrypted if year==2007|year>2012
    save ../output/compiled_data_full_sample_20pct, replace
end


*Execute
main
