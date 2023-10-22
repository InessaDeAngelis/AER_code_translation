*Purpose: Construct file calculating elixhauser score by beneficiary year, for LIS sample, based on Medicare claims data

cd "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/elixhauser/code"

clear all
set more off
cap log close
log using ../output/log, replace text
cap mkdir ../temp
adopath + ../../../lib/ado/

global car "../../../raw/medicare_part_ab_car/data"
global med "../../../raw/medicare_part_ab_med/data"
global op "../../../raw/medicare_part_ab_op/data"

program main
forval yr = 2007/2014 {
    use ${med}/dgnscd`yr', clear
    
    merge m:1 bene_id using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/elixhauser/temp/lisbene_id.dta", keep(3) nogen
    reshape wide dgnscd, i(bene_id medparid) j(dgnscdseq)
    keep bene_id dgnscd1-dgnscd9
    save ../temp/med`yr', replace

    use bene_id icd_dgns_cd* using ${car}/carc`yr', clear
        merge m:1 bene_id using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/elixhauser/temp/lisbene_id.dta", keep(3) nogen

   cap rename dgns_cd* dgnscd*
   cap rename icd_dgns_cd* dgnscd*
   keep bene_id dgnscd1-dgnscd10
    save ../temp/car`yr', replace

    use bene_id icd_dgns_cd* using ${op}/opc`yr', clear
        merge m:1 bene_id using "/disk/agedisk3/medicare.work/duggan-DUA51935/bvabson-dua51935/svn/svn/trunk/derived/elixhauser/temp/lisbene_id.dta", keep(3) nogen
    cap rename icd_dgns_cd* dgnscd*
    keep bene_id dgnscd1-dgnscd10
    save ../temp/op`yr', replace

    clear
    foreach file in med car op {
        append using ../temp/`file'`yr'
    }
    save ../temp/appended_diagnosis_file`yr', replace
    elixhauser dgnscd*, index(e) idvar(bene_id)
    gen year = `yr'
    order bene_id year
    save ../output/elixhauserlis_`yr', replace
}

clear
forval yr = 2007/2014 {
append using ../output/elixhauserlis_`yr'
}
save ../output/elixhauserlis_all, replace
end



*Execute
main        
