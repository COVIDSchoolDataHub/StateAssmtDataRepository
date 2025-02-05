clear all
set maxvar 10000

// Define file paths
global original_files "/Users/miramehta/Documents/TX State Testing Data/Original"
global original_full "$original_files/2012 to 2021, non-scraped, full files"
global original_reduced "$original_files/2012 to 2021, non-scraped, REDUCED files"
global NCES_files "/Users/miramehta/Documents/NCES District and School Demographics"
global output_files "/Users/miramehta/Documents/TX State Testing Data/Output"
global temp_files "/Users/miramehta/Documents/TX State Testing Data/Temp"

///2011-12

** State Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2012_G0`i'_State", clear
	cap rename grade GRADE
	drop *cat*
	drop *ti1*
	drop *migv*
	drop *bil*
	drop *spev*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *ph2*
	drop *satis_rec*
	drop *unsat_rec*
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_ph1_nm *_satis_ph1_nm *_adv_rec_nm *_unsat_ph1_rm *_satis_ph1_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_ph1_nm_* satis_ph1_nm_* adv_rec_nm_* unsat_ph1_rm_* satis_ph1_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_ph1_nm_ satis_ph1_nm_ adv_rec_nm_ unsat_ph1_rm_ satis_ph1_rm_ adv_rec_rm_ rs_, i(GRADE) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2012_G0`i'_State.dta", replace
}

clear
append using "$temp_files/TX_Temp_2012_G03_State.dta" "$temp_files/TX_Temp_2012_G04_State.dta" "$temp_files/TX_Temp_2012_G05_State.dta" "$temp_files/TX_Temp_2012_G06_State.dta" "$temp_files/TX_Temp_2012_G07_State.dta" "$temp_files/TX_Temp_2012_G08_State.dta"

generate CAMPUS = ""
generate DISTRICT = ""
generate DNAME = "All Districts"
generate CNAME = "All Schools"
generate DataLevel = "State"

save "$temp_files/TX_Temp_2012_All_State.dta", replace

** District Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2012_G0`i'_District", clear
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti1*
	drop *migv*
	drop *bil*
	drop *spev*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *ph2*
	drop *satis_rec*
	drop *unsat_rec*
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_ph1_nm *_satis_ph1_nm *_adv_rec_nm *_unsat_ph1_rm *_satis_ph1_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_ph1_nm_* satis_ph1_nm_* adv_rec_nm_* unsat_ph1_rm_* satis_ph1_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_ph1_nm_ satis_ph1_nm_ adv_rec_nm_ unsat_ph1_rm_ satis_ph1_rm_ adv_rec_rm_ rs_, i(DISTRICT) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2012_G0`i'_District.dta", replace
}

clear
append using "$temp_files/TX_Temp_2012_G03_District.dta" "$temp_files/TX_Temp_2012_G04_District.dta" "$temp_files/TX_Temp_2012_G05_District.dta" "$temp_files/TX_Temp_2012_G06_District.dta" "$temp_files/TX_Temp_2012_G07_District.dta" "$temp_files/TX_Temp_2012_G08_District.dta"

generate CAMPUS = ""
generate CNAME = "All Schools"
generate DataLevel = "District"

save "$temp_files/TX_Temp_2012_All_District.dta", replace

** School Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2012_G0`i'_School", clear
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename cname CNAME
	cap rename campus CAMPUS
	tostring CAMPUS, replace
	replace CAMPUS = "0" + CAMPUS if strlen(CAMPUS) == 8
	replace CAMPUS = "00" + CAMPUS if strlen(CAMPUS) == 7
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti1*
	drop *migv*
	drop *bil*
	drop *spev*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *ph2*
	drop *satis_rec*
	drop *unsat_rec*
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_ph1_nm *_satis_ph1_nm *_adv_rec_nm *_unsat_ph1_rm *_satis_ph1_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_ph1_nm_* satis_ph1_nm_* adv_rec_nm_* unsat_ph1_rm_* satis_ph1_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_ph1_nm_ satis_ph1_nm_ adv_rec_nm_ unsat_ph1_rm_ satis_ph1_rm_ adv_rec_rm_ rs_, i(CAMPUS) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2012_G0`i'_School.dta", replace
}

clear
append using "$temp_files/TX_Temp_2012_G03_School.dta" "$temp_files/TX_Temp_2012_G04_School.dta" "$temp_files/TX_Temp_2012_G05_School.dta" "$temp_files/TX_Temp_2012_G06_School.dta" "$temp_files/TX_Temp_2012_G07_School.dta" "$temp_files/TX_Temp_2012_G08_School.dta"

generate DataLevel = "School"

save "$temp_files/TX_Temp_2012_All_School.dta", replace

** Combine Data Levels
clear 
append using "$temp_files/TX_Temp_2012_All_State.dta" "$temp_files/TX_Temp_2012_All_District.dta" "$temp_files/TX_Temp_2012_All_School.dta"

save "$original_reduced/TX_Temp_2012_All_All.dta", replace

///2012-13

** State Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2013_G0`i'_State", clear
	export delimited using "$original_full/TX_OriginalData_2013_G0`i'_State.csv", replace
	cap rename grade GRADE
	drop *cat*
	drop *ti1*
	drop *migv*
	drop *bil*
	drop *spev*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *ph2*
	drop *satis_rec*
	drop *unsat_rec*
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_ph1_nm *_satis_ph1_nm *_adv_rec_nm *_unsat_ph1_rm *_satis_ph1_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_ph1_nm_* satis_ph1_nm_* adv_rec_nm_* unsat_ph1_rm_* satis_ph1_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_ph1_nm_ satis_ph1_nm_ adv_rec_nm_ unsat_ph1_rm_ satis_ph1_rm_ adv_rec_rm_ rs_, i(GRADE) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2013_G0`i'_State.dta", replace
}

clear
append using "$temp_files/TX_Temp_2013_G03_State.dta" "$temp_files/TX_Temp_2013_G04_State.dta" "$temp_files/TX_Temp_2013_G05_State.dta" "$temp_files/TX_Temp_2013_G06_State.dta" "$temp_files/TX_Temp_2013_G07_State.dta" "$temp_files/TX_Temp_2013_G08_State.dta"

generate CAMPUS = ""
generate DISTRICT = ""
generate DNAME = "All Districts"
generate CNAME = "All Schools"
generate DataLevel = "State"

save "$temp_files/TX_Temp_2013_All_State.dta", replace

** District Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2013_G0`i'_District", clear
	export delimited using "$original_full/TX_OriginalData_2013_G0`i'_District.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti1*
	drop *migv*
	drop *bil*
	drop *spev*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *ph2*
	drop *satis_rec*
	drop *unsat_rec*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_ph1_nm *_satis_ph1_nm *_adv_rec_nm *_unsat_ph1_rm *_satis_ph1_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_ph1_nm_* satis_ph1_nm_* adv_rec_nm_* unsat_ph1_rm_* satis_ph1_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_ph1_nm_ satis_ph1_nm_ adv_rec_nm_ unsat_ph1_rm_ satis_ph1_rm_ adv_rec_rm_ rs_, i(DISTRICT) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2013_G0`i'_District.dta", replace
}

clear
append using "$temp_files/TX_Temp_2013_G03_District.dta" "$temp_files/TX_Temp_2013_G04_District.dta" "$temp_files/TX_Temp_2013_G05_District.dta" "$temp_files/TX_Temp_2013_G06_District.dta" "$temp_files/TX_Temp_2013_G07_District.dta" "$temp_files/TX_Temp_2013_G08_District.dta"

generate CAMPUS = ""
generate CNAME = "All Schools"
generate DataLevel = "District"

save "$temp_files/TX_Temp_2013_All_District.dta", replace

** School Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2013_G0`i'_School", clear
	export delimited using "$original_full/TX_OriginalData_2013_G0`i'_School.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename cname CNAME
	cap rename campus CAMPUS
	tostring CAMPUS, replace
	replace CAMPUS = "0" + CAMPUS if strlen(CAMPUS) == 8
	replace CAMPUS = "00" + CAMPUS if strlen(CAMPUS) == 7
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti1*
	drop *migv*
	drop *bil*
	drop *spev*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *ph2*
	drop *satis_rec*
	drop *unsat_rec*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_ph1_nm *_satis_ph1_nm *_adv_rec_nm *_unsat_ph1_rm *_satis_ph1_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_ph1_nm_* satis_ph1_nm_* adv_rec_nm_* unsat_ph1_rm_* satis_ph1_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_ph1_nm_ satis_ph1_nm_ adv_rec_nm_ unsat_ph1_rm_ satis_ph1_rm_ adv_rec_rm_ rs_, i(CAMPUS) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2013_G0`i'_School.dta", replace
}

clear
append using "$temp_files/TX_Temp_2013_G03_School.dta" "$temp_files/TX_Temp_2013_G04_School.dta" "$temp_files/TX_Temp_2013_G05_School.dta" "$temp_files/TX_Temp_2013_G06_School.dta" "$temp_files/TX_Temp_2013_G07_School.dta" "$temp_files/TX_Temp_2013_G08_School.dta"

generate DataLevel = "School"

save "$temp_files/TX_Temp_2013_All_School.dta", replace

** Combine Data Levels
clear 
append using "$temp_files/TX_Temp_2013_All_State.dta" "$temp_files/TX_Temp_2013_All_District.dta" "$temp_files/TX_Temp_2013_All_School.dta"

save "$original_reduced/TX_Temp_2013_All_All.dta", replace

///2013-14

** State Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2014_G0`i'_State", clear
	export delimited using "$original_full/TX_OriginalData_2014_G0`i'_State.csv", replace
	cap rename grade GRADE
	drop *cat*
	drop *ti1*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *ph2*
	drop *satis_rec*
	drop *unsat_rec*
	drop *migv*
	drop *spev*
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_ph1_nm *_satis_ph1_nm *_adv_rec_nm *_unsat_ph1_rm *_satis_ph1_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_ph1_nm_* satis_ph1_nm_* adv_rec_nm_* unsat_ph1_rm_* satis_ph1_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_ph1_nm_ satis_ph1_nm_ adv_rec_nm_ unsat_ph1_rm_ satis_ph1_rm_ adv_rec_rm_ rs_, i(GRADE) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2014_G0`i'_State.dta", replace
}

clear
append using "$temp_files/TX_Temp_2014_G03_State.dta" "$temp_files/TX_Temp_2014_G04_State.dta" "$temp_files/TX_Temp_2014_G05_State.dta" "$temp_files/TX_Temp_2014_G06_State.dta" "$temp_files/TX_Temp_2014_G07_State.dta" "$temp_files/TX_Temp_2014_G08_State.dta"

generate CAMPUS = ""
generate DISTRICT = ""
generate DNAME = "All Districts"
generate CNAME = "All Schools"
generate DataLevel = "State"

save "$temp_files/TX_Temp_2014_All_State.dta", replace

** District Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2014_G0`i'_District", clear
	export delimited using "$original_full/TX_OriginalData_2014_G0`i'_District.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti1*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *ph2*
	drop *satis_rec*
	drop *unsat_rec*
	drop *migv*
	drop *spev*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_ph1_nm *_satis_ph1_nm *_adv_rec_nm *_unsat_ph1_rm *_satis_ph1_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_ph1_nm_* satis_ph1_nm_* adv_rec_nm_* unsat_ph1_rm_* satis_ph1_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_ph1_nm_ satis_ph1_nm_ adv_rec_nm_ unsat_ph1_rm_ satis_ph1_rm_ adv_rec_rm_ rs_, i(DISTRICT) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2014_G0`i'_District.dta", replace
}

clear
append using "$temp_files/TX_Temp_2014_G03_District.dta" "$temp_files/TX_Temp_2014_G04_District.dta" "$temp_files/TX_Temp_2014_G05_District.dta" "$temp_files/TX_Temp_2014_G06_District.dta" "$temp_files/TX_Temp_2014_G07_District.dta" "$temp_files/TX_Temp_2014_G08_District.dta"

generate CAMPUS = ""
generate CNAME = "All Schools"
generate DataLevel = "District"

save "$temp_files/TX_Temp_2014_All_District.dta", replace

** School Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2014_G0`i'_School", clear
	export delimited using "$original_full/TX_OriginalData_2014_G0`i'_School.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename cname CNAME
	cap rename campus CAMPUS
	tostring CAMPUS, replace
	replace CAMPUS = "0" + CAMPUS if strlen(CAMPUS) == 8
	replace CAMPUS = "00" + CAMPUS if strlen(CAMPUS) == 7
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti1*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *ph2*
	drop *satis_rec*
	drop *unsat_rec*
	drop *migv*
	drop *spev*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_ph1_nm *_satis_ph1_nm *_adv_rec_nm *_unsat_ph1_rm *_satis_ph1_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_ph1_nm_* satis_ph1_nm_* adv_rec_nm_* unsat_ph1_rm_* satis_ph1_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_ph1_nm_ satis_ph1_nm_ adv_rec_nm_ unsat_ph1_rm_ satis_ph1_rm_ adv_rec_rm_ rs_, i(CAMPUS) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2014_G0`i'_School.dta", replace
}

clear
append using "$temp_files/TX_Temp_2014_G03_School.dta" "$temp_files/TX_Temp_2014_G04_School.dta" "$temp_files/TX_Temp_2014_G05_School.dta" "$temp_files/TX_Temp_2014_G06_School.dta" "$temp_files/TX_Temp_2014_G07_School.dta" "$temp_files/TX_Temp_2014_G08_School.dta"

generate DataLevel = "School"

save "$temp_files/TX_Temp_2014_All_School.dta", replace

** Combine Data Levels
clear 
append using "$temp_files/TX_Temp_2014_All_State.dta" "$temp_files/TX_Temp_2014_All_District.dta" "$temp_files/TX_Temp_2014_All_School.dta"

save "$original_reduced/TX_Temp_2014_All_All.dta", replace

///2014-15

** State Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2015_G0`i'_State", clear
	export delimited using "$original_full/TX_OriginalData_2015_G0`i'_State.csv", replace
	cap rename grade GRADE
	drop *cat*
	drop *ti1*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *ph2*
	drop *ph3*
	drop *satis_rec*
	drop *unsat_rec*
	drop *migv*
	drop *spev*
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_ph1_nm *_satis_ph1_nm *_adv_rec_nm *_unsat_ph1_rm *_satis_ph1_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_ph1_nm_* satis_ph1_nm_* adv_rec_nm_* unsat_ph1_rm_* satis_ph1_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_ph1_nm_ satis_ph1_nm_ adv_rec_nm_ unsat_ph1_rm_ satis_ph1_rm_ adv_rec_rm_ rs_, i(GRADE) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2015_G0`i'_State.dta", replace
}

clear
append using "$temp_files/TX_Temp_2015_G03_State.dta" "$temp_files/TX_Temp_2015_G04_State.dta" "$temp_files/TX_Temp_2015_G05_State.dta" "$temp_files/TX_Temp_2015_G06_State.dta" "$temp_files/TX_Temp_2015_G07_State.dta" "$temp_files/TX_Temp_2015_G08_State.dta"

generate CAMPUS = ""
generate DISTRICT = ""
generate DNAME = "All Districts"
generate CNAME = "All Schools"
generate DataLevel = "State"

save "$temp_files/TX_Temp_2015_All_State.dta", replace

** District Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2015_G0`i'_District", clear
	export delimited using "$original_full/TX_OriginalData_2015_G0`i'_District.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti1*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *ph2*
	drop *ph3*
	drop *satis_rec*
	drop *unsat_rec*
	drop *migv*
	drop *spev*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_ph1_nm *_satis_ph1_nm *_adv_rec_nm *_unsat_ph1_rm *_satis_ph1_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_ph1_nm_* satis_ph1_nm_* adv_rec_nm_* unsat_ph1_rm_* satis_ph1_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_ph1_nm_ satis_ph1_nm_ adv_rec_nm_ unsat_ph1_rm_ satis_ph1_rm_ adv_rec_rm_ rs_, i(DISTRICT) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2015_G0`i'_District.dta", replace
}

clear
append using "$temp_files/TX_Temp_2015_G03_District.dta" "$temp_files/TX_Temp_2015_G04_District.dta" "$temp_files/TX_Temp_2015_G05_District.dta" "$temp_files/TX_Temp_2015_G06_District.dta" "$temp_files/TX_Temp_2015_G07_District.dta" "$temp_files/TX_Temp_2015_G08_District.dta"

generate CAMPUS = ""
generate CNAME = "All Schools"
generate DataLevel = "District"

save "$temp_files/TX_Temp_2015_All_District.dta", replace

** School Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2015_G0`i'_School", clear
	export delimited using "$original_full/TX_OriginalData_2015_G0`i'_School.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename cname CNAME
	cap rename campus CAMPUS
	tostring CAMPUS, replace
	replace CAMPUS = "0" + CAMPUS if strlen(CAMPUS) == 8
	replace CAMPUS = "00" + CAMPUS if strlen(CAMPUS) == 7
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti1*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *ph2*
	drop *ph3*
	drop *satis_rec*
	drop *unsat_rec*
	drop *migv*
	drop *spev*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_ph1_nm *_satis_ph1_nm *_adv_rec_nm *_unsat_ph1_rm *_satis_ph1_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_ph1_nm_* satis_ph1_nm_* adv_rec_nm_* unsat_ph1_rm_* satis_ph1_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_ph1_nm_ satis_ph1_nm_ adv_rec_nm_ unsat_ph1_rm_ satis_ph1_rm_ adv_rec_rm_ rs_, i(CAMPUS) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2015_G0`i'_School.dta", replace
}

clear
append using "$temp_files/TX_Temp_2015_G03_School.dta" "$temp_files/TX_Temp_2015_G04_School.dta" "$temp_files/TX_Temp_2015_G05_School.dta" "$temp_files/TX_Temp_2015_G06_School.dta" "$temp_files/TX_Temp_2015_G07_School.dta" "$temp_files/TX_Temp_2015_G08_School.dta"

generate DataLevel = "School"

save "$temp_files/TX_Temp_2015_All_School.dta", replace

** Combine Data Levels
clear 
append using "$temp_files/TX_Temp_2015_All_State.dta" "$temp_files/TX_Temp_2015_All_District.dta" "$temp_files/TX_Temp_2015_All_School.dta"

save "$original_reduced/TX_Temp_2015_All_All.dta", replace

///2015-16

** State Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2016_G0`i'_State", clear
	export delimited using "$original_full/TX_OriginalData_2016_G0`i'_State.csv", replace
	cap rename grade GRADE
	drop *cat*
	drop *ti1*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *satis_rec*
	drop *unsat_rec*
	drop *migv*
	drop *spev*
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_lvl2_nm *_satis_lvl2_nm *_adv_rec_nm *_unsat_lvl2_rm *_satis_lvl2_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_lvl2_nm_* satis_lvl2_nm_* adv_rec_nm_* unsat_lvl2_rm_* satis_lvl2_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_lvl2_nm_ satis_lvl2_nm_ adv_rec_nm_ unsat_lvl2_rm_ satis_lvl2_rm_ adv_rec_rm_ rs_, i(GRADE) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2016_G0`i'_State.dta", replace
}

clear
append using "$temp_files/TX_Temp_2016_G03_State.dta" "$temp_files/TX_Temp_2016_G04_State.dta" "$temp_files/TX_Temp_2016_G05_State.dta" "$temp_files/TX_Temp_2016_G06_State.dta" "$temp_files/TX_Temp_2016_G07_State.dta" "$temp_files/TX_Temp_2016_G08_State.dta"

generate CAMPUS = ""
generate DISTRICT = ""
generate DNAME = "All Districts"
generate CNAME = "All Schools"
generate DataLevel = "State"

save "$temp_files/TX_Temp_2016_All_State.dta", replace

** District Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2016_G0`i'_District", clear
	export delimited using "$original_full/TX_OriginalData_2016_G0`i'_District.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti1*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *satis_rec*
	drop *unsat_rec*
	drop *migv*
	drop *spev*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_lvl2_nm *_satis_lvl2_nm *_adv_rec_nm *_unsat_lvl2_rm *_satis_lvl2_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_lvl2_nm_* satis_lvl2_nm_* adv_rec_nm_* unsat_lvl2_rm_* satis_lvl2_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_lvl2_nm_ satis_lvl2_nm_ adv_rec_nm_ unsat_lvl2_rm_ satis_lvl2_rm_ adv_rec_rm_ rs_, i(DISTRICT) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2016_G0`i'_District.dta", replace
}

clear
append using "$temp_files/TX_Temp_2016_G03_District.dta" "$temp_files/TX_Temp_2016_G04_District.dta" "$temp_files/TX_Temp_2016_G05_District.dta" "$temp_files/TX_Temp_2016_G06_District.dta" "$temp_files/TX_Temp_2016_G07_District.dta" "$temp_files/TX_Temp_2016_G08_District.dta"

generate CAMPUS = ""
generate CNAME = "All Schools"
generate DataLevel = "District"

save "$temp_files/TX_Temp_2016_All_District.dta", replace

** School Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2016_G0`i'_School", clear
	export delimited using "$original_full/TX_OriginalData_2016_G0`i'_School.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename cname CNAME
	cap rename campus CAMPUS
	tostring CAMPUS, replace
	replace CAMPUS = "0" + CAMPUS if strlen(CAMPUS) == 8
	replace CAMPUS = "00" + CAMPUS if strlen(CAMPUS) == 7
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti1*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *satis_rec*
	drop *unsat_rec*
	drop *migv*
	drop *spev*
	drop region
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsat_lvl2_nm *_satis_lvl2_nm *_adv_rec_nm *_unsat_lvl2_rm *_satis_lvl2_rm *_adv_rec_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsat_lvl2_nm_* satis_lvl2_nm_* adv_rec_nm_* unsat_lvl2_rm_* satis_lvl2_rm_* adv_rec_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsat_lvl2_nm_ satis_lvl2_nm_ adv_rec_nm_ unsat_lvl2_rm_ satis_lvl2_rm_ adv_rec_rm_ rs_, i(CAMPUS) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2016_G0`i'_School.dta", replace
}

clear
append using "$temp_files/TX_Temp_2016_G03_School.dta" "$temp_files/TX_Temp_2016_G04_School.dta" "$temp_files/TX_Temp_2016_G05_School.dta" "$temp_files/TX_Temp_2016_G06_School.dta" "$temp_files/TX_Temp_2016_G07_School.dta" "$temp_files/TX_Temp_2016_G08_School.dta"

generate DataLevel = "School"

save "$temp_files/TX_Temp_2016_All_School.dta", replace

** Combine Data Levels
clear 
append using "$temp_files/TX_Temp_2016_All_State.dta" "$temp_files/TX_Temp_2016_All_District.dta" "$temp_files/TX_Temp_2016_All_School.dta"

save "$original_reduced/TX_Temp_2016_All_All.dta", replace

///2016-17

** State Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2017_G0`i'_State", clear
	export delimited using "$original_full/TX_OriginalData_2017_G0`i'_State.csv", replace
	cap rename grade GRADE
	drop *cat*
	drop *ti*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *migv*
	drop *spev*
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsatgl_nm *_approgl_nm *_meetsgl_nm *_mastrgl_nm *_unsatgl_rm *_approgl_rm *_meetsgl_rm *_mastrgl_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsatgl_nm_* approgl_nm_* meetsgl_nm_* mastrgl_nm_* unsatgl_rm_* approgl_rm_* meetsgl_rm_* mastrgl_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsatgl_nm_ approgl_nm_ meetsgl_nm_ mastrgl_nm_ unsatgl_rm_ approgl_rm_ meetsgl_rm_ mastrgl_rm_ rs_, i(GRADE) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2017_G0`i'_State.dta", replace
}

clear
append using "$temp_files/TX_Temp_2017_G03_State.dta" "$temp_files/TX_Temp_2017_G04_State.dta" "$temp_files/TX_Temp_2017_G05_State.dta" "$temp_files/TX_Temp_2017_G06_State.dta" "$temp_files/TX_Temp_2017_G07_State.dta" "$temp_files/TX_Temp_2017_G08_State.dta"

generate CAMPUS = ""
generate DISTRICT = ""
generate DNAME = "All Districts"
generate CNAME = "All Schools"
generate DataLevel = "State"

save "$temp_files/TX_Temp_2017_All_State.dta", replace

** District Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2017_G0`i'_District", clear
	export delimited using "$original_full/TX_OriginalData_2017_G0`i'_District.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *migv*
	drop *spev*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsatgl_nm *_approgl_nm *_meetsgl_nm *_mastrgl_nm *_unsatgl_rm *_approgl_rm *_meetsgl_rm *_mastrgl_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsatgl_nm_* approgl_nm_* meetsgl_nm_* mastrgl_nm_* unsatgl_rm_* approgl_rm_* meetsgl_rm_* mastrgl_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsatgl_nm_ approgl_nm_ meetsgl_nm_ mastrgl_nm_ unsatgl_rm_ approgl_rm_ meetsgl_rm_ mastrgl_rm_ rs_, i(DISTRICT) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2017_G0`i'_District.dta", replace
}

clear
append using "$temp_files/TX_Temp_2017_G03_District.dta" "$temp_files/TX_Temp_2017_G04_District.dta" "$temp_files/TX_Temp_2017_G05_District.dta" "$temp_files/TX_Temp_2017_G06_District.dta" "$temp_files/TX_Temp_2017_G07_District.dta" "$temp_files/TX_Temp_2017_G08_District.dta"

generate CAMPUS = ""
generate CNAME = "All Schools"
generate DataLevel = "District"

save "$temp_files/TX_Temp_2017_All_District.dta", replace

** School Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2017_G0`i'_School", clear
	export delimited using "$original_full/TX_OriginalData_2017_G0`i'_School.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename cname CNAME
	cap rename campus CAMPUS
	tostring CAMPUS, replace
	replace CAMPUS = "0" + CAMPUS if strlen(CAMPUS) == 8
	replace CAMPUS = "00" + CAMPUS if strlen(CAMPUS) == 7
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *migv*
	drop *spev*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsatgl_nm *_approgl_nm *_meetsgl_nm *_mastrgl_nm *_unsatgl_rm *_approgl_rm *_meetsgl_rm *_mastrgl_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsatgl_nm_* approgl_nm_* meetsgl_nm_* mastrgl_nm_* unsatgl_rm_* approgl_rm_* meetsgl_rm_* mastrgl_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsatgl_nm_ approgl_nm_ meetsgl_nm_ mastrgl_nm_ unsatgl_rm_ approgl_rm_ meetsgl_rm_ mastrgl_rm_ rs_, i(CAMPUS) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2017_G0`i'_School.dta", replace
}

clear
append using "$temp_files/TX_Temp_2017_G03_School.dta" "$temp_files/TX_Temp_2017_G04_School.dta" "$temp_files/TX_Temp_2017_G05_School.dta" "$temp_files/TX_Temp_2017_G06_School.dta" "$temp_files/TX_Temp_2017_G07_School.dta" "$temp_files/TX_Temp_2017_G08_School.dta"

generate DataLevel = "School"

save "$temp_files/TX_Temp_2017_All_School.dta", replace

** Combine Data Levels

clear 
append using "$temp_files/TX_Temp_2017_All_State.dta" "$temp_files/TX_Temp_2017_All_District.dta" "$temp_files/TX_Temp_2017_All_School.dta"

save "$original_reduced/TX_Temp_2017_All_All.dta", replace

///2017-18

** State Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2018_G0`i'_State", clear
	export delimited using "$original_full/TX_OriginalData_2018_G0`i'_State.csv", replace
	cap rename grade GRADE
	drop *cat*
	drop *ti*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *migv*
	drop *spev*
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsatgl_nm *_approgl_nm *_meetsgl_nm *_mastrgl_nm *_unsatgl_rm *_approgl_rm *_meetsgl_rm *_mastrgl_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsatgl_nm_* approgl_nm_* meetsgl_nm_* mastrgl_nm_* unsatgl_rm_* approgl_rm_* meetsgl_rm_* mastrgl_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsatgl_nm_ approgl_nm_ meetsgl_nm_ mastrgl_nm_ unsatgl_rm_ approgl_rm_ meetsgl_rm_ mastrgl_rm_ rs_, i(GRADE) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2018_G0`i'_State.dta", replace
}

clear
append using "$temp_files/TX_Temp_2018_G03_State.dta" "$temp_files/TX_Temp_2018_G04_State.dta" "$temp_files/TX_Temp_2018_G05_State.dta" "$temp_files/TX_Temp_2018_G06_State.dta" "$temp_files/TX_Temp_2018_G07_State.dta" "$temp_files/TX_Temp_2018_G08_State.dta"

generate CAMPUS = ""
generate DISTRICT = ""
generate DNAME = "All Districts"
generate CNAME = "All Schools"
generate DataLevel = "State"

save "$temp_files/TX_Temp_2018_All_State.dta", replace

** District Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2018_G0`i'_District", clear
	export delimited using "$original_full/TX_OriginalData_2018_G0`i'_District.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *migv*
	drop *spev*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsatgl_nm *_approgl_nm *_meetsgl_nm *_mastrgl_nm *_unsatgl_rm *_approgl_rm *_meetsgl_rm *_mastrgl_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsatgl_nm_* approgl_nm_* meetsgl_nm_* mastrgl_nm_* unsatgl_rm_* approgl_rm_* meetsgl_rm_* mastrgl_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsatgl_nm_ approgl_nm_ meetsgl_nm_ mastrgl_nm_ unsatgl_rm_ approgl_rm_ meetsgl_rm_ mastrgl_rm_ rs_, i(DISTRICT) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2018_G0`i'_District.dta", replace
}

clear
append using "$temp_files/TX_Temp_2018_G03_District.dta" "$temp_files/TX_Temp_2018_G04_District.dta" "$temp_files/TX_Temp_2018_G05_District.dta" "$temp_files/TX_Temp_2018_G06_District.dta" "$temp_files/TX_Temp_2018_G07_District.dta" "$temp_files/TX_Temp_2018_G08_District.dta"

generate CAMPUS = ""
generate CNAME = "All Schools"
generate DataLevel = "District"

save "$temp_files/TX_Temp_2018_All_District.dta", replace

** School Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2018_G0`i'_School", clear
	export delimited using "$original_full/TX_OriginalData_2018_G0`i'_School.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename cname CNAME
	cap rename campus CAMPUS
	tostring CAMPUS, replace
	replace CAMPUS = "0" + CAMPUS if strlen(CAMPUS) == 8
	replace CAMPUS = "00" + CAMPUS if strlen(CAMPUS) == 7
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lepv*
	drop *migv*
	drop *spev*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsatgl_nm *_approgl_nm *_meetsgl_nm *_mastrgl_nm *_unsatgl_rm *_approgl_rm *_meetsgl_rm *_mastrgl_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsatgl_nm_* approgl_nm_* meetsgl_nm_* mastrgl_nm_* unsatgl_rm_* approgl_rm_* meetsgl_rm_* mastrgl_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsatgl_nm_ approgl_nm_ meetsgl_nm_ mastrgl_nm_ unsatgl_rm_ approgl_rm_ meetsgl_rm_ mastrgl_rm_ rs_, i(CAMPUS) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2018_G0`i'_School.dta", replace
}

clear
append using "$temp_files/TX_Temp_2018_G03_School.dta" "$temp_files/TX_Temp_2018_G04_School.dta" "$temp_files/TX_Temp_2018_G05_School.dta" "$temp_files/TX_Temp_2018_G06_School.dta" "$temp_files/TX_Temp_2018_G07_School.dta" "$temp_files/TX_Temp_2018_G08_School.dta"

generate DataLevel = "School"

save "$temp_files/TX_Temp_2018_All_School.dta", replace

** Combine Data Levels
clear 
append using "$temp_files/TX_Temp_2018_All_State.dta" "$temp_files/TX_Temp_2018_All_District.dta" "$temp_files/TX_Temp_2018_All_School.dta"

save "$original_reduced/TX_Temp_2018_All_All.dta", replace

///2018-19

** State Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2019_G0`i'_State", clear
	export delimited using "$original_full/TX_OriginalData_2019_G0`i'_State.csv", replace
	cap rename grade GRADE
	drop *cat*
	drop *ti*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lept*
	drop *lepr*
	drop *lepv*
	drop *migv*
	drop *spev*
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsatgl_nm *_approgl_nm *_meetsgl_nm *_mastrgl_nm *_unsatgl_rm *_approgl_rm *_meetsgl_rm *_mastrgl_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsatgl_nm_* approgl_nm_* meetsgl_nm_* mastrgl_nm_* unsatgl_rm_* approgl_rm_* meetsgl_rm_* mastrgl_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsatgl_nm_ approgl_nm_ meetsgl_nm_ mastrgl_nm_ unsatgl_rm_ approgl_rm_ meetsgl_rm_ mastrgl_rm_ rs_, i(GRADE) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2019_G0`i'_State.dta", replace
}

clear
append using "$temp_files/TX_Temp_2019_G03_State.dta" "$temp_files/TX_Temp_2019_G04_State.dta" "$temp_files/TX_Temp_2019_G05_State.dta" "$temp_files/TX_Temp_2019_G06_State.dta" "$temp_files/TX_Temp_2019_G07_State.dta" "$temp_files/TX_Temp_2019_G08_State.dta"

generate CAMPUS = ""
generate DISTRICT = ""
generate DNAME = "All Districts"
generate CNAME = "All Schools"
generate DataLevel = "State"

save "$temp_files/TX_Temp_2019_All_State.dta", replace

** District Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2019_G0`i'_District", clear
	export delimited using "$original_full/TX_OriginalData_2019_G0`i'_District.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	
	drop *cat*
	drop *ti*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lept*
	drop *lepr*
	drop *lepv*
	drop *migv*
	drop *spev*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsatgl_nm *_approgl_nm *_meetsgl_nm *_mastrgl_nm *_unsatgl_rm *_approgl_rm *_meetsgl_rm *_mastrgl_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsatgl_nm_* approgl_nm_* meetsgl_nm_* mastrgl_nm_* unsatgl_rm_* approgl_rm_* meetsgl_rm_* mastrgl_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsatgl_nm_ approgl_nm_ meetsgl_nm_ mastrgl_nm_ unsatgl_rm_ approgl_rm_ meetsgl_rm_ mastrgl_rm_ rs_, i(DISTRICT) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2019_G0`i'_District.dta", replace
}

clear
append using "$temp_files/TX_Temp_2019_G03_District.dta" "$temp_files/TX_Temp_2019_G04_District.dta" "$temp_files/TX_Temp_2019_G05_District.dta" "$temp_files/TX_Temp_2019_G06_District.dta" "$temp_files/TX_Temp_2019_G07_District.dta" "$temp_files/TX_Temp_2019_G08_District.dta"

generate CAMPUS = ""
generate CNAME = "All Schools"
generate DataLevel = "District"

save "$temp_files/TX_Temp_2019_All_District.dta", replace

** School Level
forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2019_G0`i'_School", clear
	export delimited using "$original_full/TX_OriginalData_2019_G0`i'_School.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename cname CNAME
	cap rename campus CAMPUS
	tostring CAMPUS, replace
	replace CAMPUS = "0" + CAMPUS if strlen(CAMPUS) == 8
	replace CAMPUS = "00" + CAMPUS if strlen(CAMPUS) == 7
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lept*
	drop *lepr*
	drop *lepv*
	drop *migv*
	drop *spev*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsatgl_nm *_approgl_nm *_meetsgl_nm *_mastrgl_nm *_unsatgl_rm *_approgl_rm *_meetsgl_rm *_mastrgl_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsatgl_nm_* approgl_nm_* meetsgl_nm_* mastrgl_nm_* unsatgl_rm_* approgl_rm_* meetsgl_rm_* mastrgl_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsatgl_nm_ approgl_nm_ meetsgl_nm_ mastrgl_nm_ unsatgl_rm_ approgl_rm_ meetsgl_rm_ mastrgl_rm_ rs_, i(CAMPUS) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2019_G0`i'_School.dta", replace
}

clear
append using "$temp_files/TX_Temp_2019_G03_School.dta" "$temp_files/TX_Temp_2019_G04_School.dta" "$temp_files/TX_Temp_2019_G05_School.dta" "$temp_files/TX_Temp_2019_G06_School.dta" "$temp_files/TX_Temp_2019_G07_School.dta" "$temp_files/TX_Temp_2019_G08_School.dta"

generate DataLevel = "School"

save "$temp_files/TX_Temp_2019_All_School.dta", replace

** Combine Data Levels
clear 
append using "$temp_files/TX_Temp_2019_All_State.dta" "$temp_files/TX_Temp_2019_All_District.dta" "$temp_files/TX_Temp_2019_All_School.dta"

save "$original_reduced/TX_Temp_2019_All_All.dta", replace

/// 2020-2021

** State Level

forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2021_G0`i'_State", clear
	export delimited using "$original_full/TX_OriginalData_2021_G0`i'_State.csv", replace
	cap rename grade GRADE
	drop *cat*
	drop *ti*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lept*
	drop *lepr*
	drop *lepe*
	drop *lepv*
	drop *migv*
	drop *spev*
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsatgl_nm *_approgl_nm *_meetsgl_nm *_mastrgl_nm *_unsatgl_rm *_approgl_rm *_meetsgl_rm *_mastrgl_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsatgl_nm_* approgl_nm_* meetsgl_nm_* mastrgl_nm_* unsatgl_rm_* approgl_rm_* meetsgl_rm_* mastrgl_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsatgl_nm_ approgl_nm_ meetsgl_nm_ mastrgl_nm_ unsatgl_rm_ approgl_rm_ meetsgl_rm_ mastrgl_rm_ rs_, i(GRADE) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2021_G0`i'_State.dta", replace
}

clear
append using "$temp_files/TX_Temp_2021_G03_State.dta" "$temp_files/TX_Temp_2021_G04_State.dta" "$temp_files/TX_Temp_2021_G05_State.dta" "$temp_files/TX_Temp_2021_G06_State.dta" "$temp_files/TX_Temp_2021_G07_State.dta" "$temp_files/TX_Temp_2021_G08_State.dta"

generate CAMPUS = ""
generate DISTRICT = ""
generate DNAME = "All Districts"
generate CNAME = "All Schools"
generate DataLevel = "State"

save "$temp_files/TX_Temp_2021_All_State.dta", replace

** District Level

forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2021_G0`i'_District", clear
	export delimited using "$original_full/TX_OriginalData_2021_G0`i'_District.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	
	drop *cat*
	drop *ti*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lept*
	drop *lepr*
	drop *lepe*
	drop *lepv*
	drop *migv*
	drop *spev*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsatgl_nm *_approgl_nm *_meetsgl_nm *_mastrgl_nm *_unsatgl_rm *_approgl_rm *_meetsgl_rm *_mastrgl_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsatgl_nm_* approgl_nm_* meetsgl_nm_* mastrgl_nm_* unsatgl_rm_* approgl_rm_* meetsgl_rm_* mastrgl_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsatgl_nm_ approgl_nm_ meetsgl_nm_ mastrgl_nm_ unsatgl_rm_ approgl_rm_ meetsgl_rm_ mastrgl_rm_ rs_, i(DISTRICT) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2021_G0`i'_District.dta", replace
}

clear
append using "$temp_files/TX_Temp_2021_G03_District.dta" "$temp_files/TX_Temp_2021_G04_District.dta" "$temp_files/TX_Temp_2021_G05_District.dta" "$temp_files/TX_Temp_2021_G06_District.dta" "$temp_files/TX_Temp_2021_G07_District.dta" "$temp_files/TX_Temp_2021_G08_District.dta"

generate CAMPUS = ""
generate CNAME = "All Schools"
generate DataLevel = "District"

save "$temp_files/TX_Temp_2021_All_District.dta", replace

** School Level

forvalues i = 3/8 {
	import delimited using "$original_full/TX_OriginalData_2021_G0`i'_School", clear
	export delimited using "$original_full/TX_OriginalData_2021_G0`i'_School.csv", replace
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename cname CNAME
	cap rename campus CAMPUS
	tostring CAMPUS, replace
	replace CAMPUS = "0" + CAMPUS if strlen(CAMPUS) == 8
	replace CAMPUS = "00" + CAMPUS if strlen(CAMPUS) == 7
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti*
	drop *bil*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	drop *leps*
	drop *lept*
	drop *lepr*
	drop *lepe*
	drop *lepv*
	drop *migv*
	drop *spev*
	drop region
	
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsatgl_nm *_approgl_nm *_meetsgl_nm *_mastrgl_nm *_unsatgl_rm *_approgl_rm *_meetsgl_rm *_mastrgl_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsatgl_nm_* approgl_nm_* meetsgl_nm_* mastrgl_nm_* unsatgl_rm_* approgl_rm_* meetsgl_rm_* mastrgl_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsatgl_nm_ approgl_nm_ meetsgl_nm_ mastrgl_nm_ unsatgl_rm_ approgl_rm_ meetsgl_rm_ mastrgl_rm_ rs_, i(CAMPUS) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2021_G0`i'_School.dta", replace
}

clear
append using "$temp_files/TX_Temp_2021_G03_School.dta" "$temp_files/TX_Temp_2021_G04_School.dta" "$temp_files/TX_Temp_2021_G05_School.dta" "$temp_files/TX_Temp_2021_G06_School.dta" "$temp_files/TX_Temp_2021_G07_School.dta" "$temp_files/TX_Temp_2021_G08_School.dta"

generate DataLevel = "School"

save "$temp_files/TX_Temp_2021_All_School.dta", replace

** Combine Data Levels

clear 
append using "$temp_files/TX_Temp_2021_All_State.dta" "$temp_files/TX_Temp_2021_All_District.dta" "$temp_files/TX_Temp_2021_All_School.dta"

save "$original_reduced/TX_Temp_2021_All_All.dta", replace
