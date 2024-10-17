clear all
set maxvar 10000
// Define file paths

global original_files "/Users/miramehta/Documents/TX State Testing Data/Original"
global NCES_files "/Users/miramehta/Documents/NCES District and School Demographics"
global output_files "/Users/miramehta/Documents/TX State Testing Data/Output"
global temp_files "/Users/miramehta/Documents/TX State Testing Data/Temp"

// 2011-2012

/*
// State Level

forvalues i = 3/8 {
	import delimited using "$original_files/TX_OriginalData_2012_G0`i'_State", clear
	cap rename grade GRADE
	drop *cat*
	drop *ti1*
	*drop *mig*
	drop *migv*
	drop *bil*
	*drop *spe*
	drop *spev*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	*drop *lepf*
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

// District Level

forvalues i = 3/8 {
	import delimited using "$original_files/TX_OriginalData_2012_G0`i'_District", clear
	cap rename grade GRADE
	cap rename dname DNAME
	cap rename district DISTRICT
	tostring DISTRICT, replace
	replace DISTRICT = "0" + DISTRICT if strlen(DISTRICT) == 5
	replace DISTRICT = "00" + DISTRICT if strlen(DISTRICT) == 4
	drop *cat*
	drop *ti1*
	*drop *mig*
	drop *migv*
	drop *bil*
	*drop *spe*
	drop *spev*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	*drop *lepf*
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

// School Level

forvalues i = 3/8 {
	import delimited using "$original_files/TX_OriginalData_2012_G0`i'_School", clear
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
	*drop *mig*
	drop *migv*
	drop *bil*
	*drop *spe*
	drop *spev*
	drop *gif*
	drop *atr*
	drop *esl*
	drop *esb*
	
	drop *eco1*
	drop *eco2*
	drop *ecov*
	drop *eco9*
	*drop *lepf*
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

// Combine Data Levels

clear 
append using "$temp_files/TX_Temp_2012_All_State.dta" "$temp_files/TX_Temp_2012_All_District.dta" "$temp_files/TX_Temp_2012_All_School.dta"

save "$temp_files/TX_Temp_2012_All_All.dta", replace

*/

// Splitting Subject and Subgroups

use "$temp_files/TX_Temp_2012_All_All.dta", clear

generate Subject = substr(subject_group, 1, 1)
generate StudentGroup = substr(subject_group, 3, 3)
generate StudentSubGroup = substr(subject_group, 3, .)
drop subject_group

drop if StudentGroup == "voc"
drop *comp*

replace Subject = "math" if Subject == "m"
replace Subject = "ela" if Subject == "r"
replace Subject = "sci" if Subject == "s"
replace Subject = "soc" if Subject == "h"
replace Subject = "wri" if Subject == "w"

replace StudentGroup = "All Students" if StudentGroup == "all"
replace StudentGroup = "RaceEth" if StudentGroup == "eth"
replace StudentGroup = "EL Status" if StudentGroup == "lep"
replace StudentGroup = "Economic Status" if StudentGroup == "eco"
replace StudentGroup = "Gender" if StudentGroup == "sex"
replace StudentGroup = "Disability Status" if StudentGroup == "spe"
replace StudentGroup = "Migrant Status" if StudentGroup == "mig"

replace StudentSubGroup = "All Students" if StudentSubGroup == "all"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "ethi"
replace StudentSubGroup = "Asian" if StudentSubGroup == "etha"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "ethb"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "ethp"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "eth2"
replace StudentSubGroup = "White" if StudentSubGroup == "ethw"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "ethh"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "ethv"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "lepc"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "lep0"
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "lepf"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ecoy"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "econ"
replace StudentSubGroup = "Male" if StudentSubGroup == "sexm"
replace StudentSubGroup = "Female" if StudentSubGroup == "sexf"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "sexv"
replace StudentSubGroup = "SWD" if StudentSubGroup == "spey"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "spen"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "migy"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "mign"

// Renaming and Transforming Variables
rename GRADE GradeLevel
tostring GradeLevel, replace
replace GradeLevel = "G0"+GradeLevel

tostring year, replace
rename year SchYear
replace SchYear = "2011-12" if SchYear == "12"

rename d_ StudentSubGroup_TotalTested
rename unsat_ph1_nm_ Lev1_count
rename satis_ph1_nm_ Lev2plus_count
rename adv_rec_nm_ Lev3_count
rename unsat_ph1_rm_ Lev1_percent
rename satis_ph1_rm_ Lev2plus_percent
rename adv_rec_rm_ Lev3_percent

generate Lev2_count = Lev2plus_count - Lev3_count
generate Lev2_percent = Lev2plus_percent - Lev3_percent
generate ProficientOrAbove_count = Lev2plus_count
generate ProficientOrAbove_percent = Lev2plus_percent
drop Lev2plus_count
drop Lev2plus_percent

rename rs_ AvgScaleScore
rename docs_n_ Submitted_count
rename docs_r_ ParticipationRate
rename abs_n_ Absent_count
rename abs_r_ Absent_percent
rename oth_n_ NoTestOth_count
rename oth_r_ NoTestOth_percent
rename CAMPUS StateAssignedSchID
rename DISTRICT StateAssignedDistID
rename DNAME DistName
rename CNAME SchName

drop Submitted_count
drop Absent_count
drop Absent_percent
drop NoTestOth_count
drop NoTestOth_percent
drop region

// Relabeling Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

// Fixing Percents
foreach var of varlist Lev1_percent Lev2_percent Lev3_percent ProficientOrAbove_percent ParticipationRate {
	replace `var' = `var'/100
}

// Dealing with Suppressed/Missing
foreach var of varlist Lev1_count Lev2_count Lev3_count Lev1_percent Lev2_percent Lev3_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent {
	tostring `var', replace force format("%9.3g")
	replace `var' = "--" if StudentSubGroup_TotalTested == 0
	replace `var' = "*" if `var' == "."
}

tostring ParticipationRate, replace force
replace ParticipationRate = "--" if ParticipationRate == "."

// Generating missing variables
gen Lev4_count = ""
gen Lev4_percent = ""
gen Lev5_count = ""
gen Lev5_percent = ""
gen AssmtName = "STAAR - English"
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_soc = "Y"
gen Flag_CutScoreChange_sci = "Y"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 2-3"
gen state_leaid = StateAssignedDistID
replace state_leaid = "" if DataLevel == 1
gen seasch = StateAssignedSchID
replace seasch = "" if DataLevel != 3

// Saving transformed data
save "$output_files/TX_AssmtData_2012.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES District Files, Fall 1997-Fall 2022/NCES_2011_District.dta", clear

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter DistLocale county_name county_code

replace state_location = "TX" if state_fips == 48

keep if state_location == "TX"

merge 1:m state_leaid using "${output_files}/TX_AssmtData_2012.dta", keep(match using) nogenerate

save "$output_files/TX_AssmtData_2012.dta", replace

// Merging with NCES School Data

use "$NCES_files/NCES School Files, Fall 1997-Fall 2022/NCES_2011_School.dta", clear

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

replace state_location = "TX" if state_fips == 48

keep if state_location == "TX"
drop if seasch == ""

merge 1:m seasch using "${output_files}/TX_AssmtData_2012.dta", keep(match using) nogenerate

save "$output_files/TX_AssmtData_2012.dta", replace

// Fixing NCES Variables
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename state_location StateAbbrev
generate State = "Texas"
rename county_code CountyCode
rename state_fips StateFips
rename county_name CountyName


// Fixing missing state data
replace StateAbbrev = "TX" if DataLevel == 1
replace StateFips = 48 if DataLevel == 1



// Fixing Texas Tech Univ
foreach var of varlist SchLevel SchVirtual SchType {
	decode `var', gen(temp)
	drop `var'
	rename temp `var'
}

replace NCESDistrictID = "4801480" if DistName == "TEXAS TECH UNIV"
replace NCESSchoolID = "480148014286" if DistName == "TEXAS TECH UNIV" & DataLevel == 3
replace DistType = " Regular local school district" if DistName == "TEXAS TECH UNIV"
replace DistCharter = "No" if DistName == "TEXAS TECH UNIV"
replace DistLocale = "City, large" if DistName == "TEXAS TECH UNIV"
replace SchType = "Regular school" if DistName == "TEXAS TECH UNIV" & DataLevel == 3
replace SchLevel = "Other" if DistName == "TEXAS TECH UNIV" & DataLevel == 3
replace SchVirtual = "Missing/not reported" if DistName == "TEXAS TECH UNIV" & DataLevel == 3
replace CountyName = "Lubbock County" if DistName == "TEXAS TECH UNIV"
replace CountyCode = "48303" if DistName == "TEXAS TECH UNIV"
replace StateAbbrev = "TX" if DistName == "TEXAS TECH UNIV"
replace StateFips = 48 if DistName == "TEXAS TECH UNIV"
drop if StateAssignedSchID == "015915137" & NCESSchoolID == ""

//Other Post Launch
replace CountyName = proper(CountyName)
drop seasch
drop State_leaid
replace DistType = trim(DistType)
replace CountyName = "DeWitt County" if CountyCode== "48123"
replace CountyName = "McCulloch County" if CountyCode== "48307"
replace CountyName = "McLennan County" if CountyCode== "48309"
replace CountyName = "McMullen County" if CountyCode== "48311"
drop if SchName == "TEXAS TECH H S"
replace SchName ="TEXAS TECH UNIV" if NCESSchoolID== "480148014286"
replace StateAssignedSchID = "152504001" if NCESSchoolID == "480148014286" //Applying 2023 StateAssignedSchID to All Years

//StudentGroup_TotalTested
sort DataLevel AssmtName StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"
drop if StudentSubGroup_TotalTested == 0 & StudentSubGroup != "All Students"

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/TX_AssmtData_2012.dta", replace
export delimited using "${output_files}/TX_AssmtData_2012.csv", replace

