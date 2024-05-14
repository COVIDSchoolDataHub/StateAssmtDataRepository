clear all
set maxvar 10000
// Define file paths

global original_files "/Volumes/T7/State Test Project/Texas/Original"
global NCES_files "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global output_files "/Volumes/T7/State Test Project/Texas/Output"
global temp_files "/Volumes/T7/State Test Project/Texas/Temp"

// 2020-2021

/*
// State Level

forvalues i = 3/8 {
	import sas using "$original_files/TX_OriginalData_2021_G0`i'_State.sas7bdat", clear
	export delimited using "$original_files/TX_OriginalData_2021_G0`i'_State.csv", replace
	drop *cat*
	drop *ti*
	*drop *mig*
	drop *bil*
	*drop *spe*
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
generate REGION = ""
generate DISTRICT = ""
generate DNAME = "All Districts"
generate CNAME = "All Schools"
generate DataLevel = "State"

save "$temp_files/TX_Temp_2021_All_State.dta", replace

// District Level

forvalues i = 3/8 {
	import sas using "$original_files/TX_OriginalData_2021_G0`i'_District.sas7bdat", clear
	export delimited using "$original_files/TX_OriginalData_2021_G0`i'_District.csv", replace
	drop *cat*
	drop *ti*
	*drop *mig*
	drop *bil*
	*drop *spe*
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
	drop *lept*
	drop *lepr*
	drop *lepe*
	drop *lepv*
	drop *migv*
	drop *spev*
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

// School Level

forvalues i = 3/8 {
	import sas using "$original_files/TX_OriginalData_2021_G0`i'_School.sas7bdat", clear
	export delimited using "$original_files/TX_OriginalData_2021_G0`i'_School.csv", replace
	drop *cat*
	drop *ti*
	*drop *mig*
	drop *bil*
	*drop *spe*
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
	drop *lept*
	drop *lepr*
	drop *lepe*
	drop *lepv*
	drop *migv*
	drop *spev*
	rename (*_docs_n *_abs_n *_oth_n *_d *_docs_r *_abs_r *_oth_r *_unsatgl_nm *_approgl_nm *_meetsgl_nm *_mastrgl_nm *_unsatgl_rm *_approgl_rm *_meetsgl_rm *_mastrgl_rm *_rs) (docs_n_* abs_n_* oth_n_* d_* docs_r_* abs_r_* oth_r_* unsatgl_nm_* approgl_nm_* meetsgl_nm_* mastrgl_nm_* unsatgl_rm_* approgl_rm_* meetsgl_rm_* mastrgl_rm_* rs_*)
	
	reshape long docs_n_ abs_n_ oth_n_ d_ docs_r_ abs_r_ oth_r_ unsatgl_nm_ approgl_nm_ meetsgl_nm_ mastrgl_nm_ unsatgl_rm_ approgl_rm_ meetsgl_rm_ mastrgl_rm_ rs_, i(CAMPUS) j(subject_group, string)
	
	save "$temp_files/TX_Temp_2021_G0`i'_School.dta", replace
}

clear
append using "$temp_files/TX_Temp_2021_G03_School.dta" "$temp_files/TX_Temp_2021_G04_School.dta" "$temp_files/TX_Temp_2021_G05_School.dta" "$temp_files/TX_Temp_2021_G06_School.dta" "$temp_files/TX_Temp_2021_G07_School.dta" "$temp_files/TX_Temp_2021_G08_School.dta"

generate DataLevel = "School"

save "$temp_files/TX_Temp_2021_All_School.dta", replace

// Combine Data Levels

clear 
append using "$temp_files/TX_Temp_2021_All_State.dta" "$temp_files/TX_Temp_2021_All_District.dta" "$temp_files/TX_Temp_2021_All_School.dta"

save "$temp_files/TX_Temp_2021_All_All.dta", replace

*/

// Splitting Subject and Subgroups

use "$temp_files/TX_Temp_2021_All_All.dta", clear

generate Subject = substr(subject_group, 1, 1)
generate StudentGroup = substr(subject_group, 3, 3)
generate StudentSubGroup = substr(subject_group, 3, .)
drop subject_group

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
replace GradeLevel = "G"+GradeLevel

rename YEAR SchYear
replace SchYear = "2020-21" if SchYear == "21"

rename d_ StudentSubGroup_TotalTested
rename unsatgl_nm_ Lev1_count
rename approgl_nm_ Lev2plus_count
rename meetsgl_nm_ Lev3plus_count
rename mastrgl_nm_ Lev4_count
rename unsatgl_rm_ Lev1_percent
rename approgl_rm_ Lev2plus_percent
rename meetsgl_rm_ Lev3plus_percent
rename mastrgl_rm_ Lev4_percent

generate Lev2_count = Lev2plus_count - Lev3plus_count
generate Lev3_count = Lev3plus_count - Lev4_count
generate Lev2_percent = Lev2plus_percent - Lev3plus_percent
generate Lev3_percent = Lev3plus_percent - Lev4_percent
generate ProficientOrAbove_count = Lev2plus_count
generate ProficientOrAbove_percent = Lev2plus_percent
drop Lev2plus_count
drop Lev2plus_percent
drop Lev3plus_count
drop Lev3plus_percent

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
drop REGION

// Relabeling Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

// Fixing Percents
foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent ParticipationRate {
	replace `var' = `var'/100
}

// Dealing with Suppressed/Missing
foreach var of varlist Lev1_count Lev2_count Lev3_count Lev4_count Lev1_percent Lev2_percent Lev3_percent Lev4_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent {
	tostring `var', replace force format ("%9.3g")
	replace `var' = "--" if StudentSubGroup_TotalTested == 0
	replace `var' = "*" if `var' == "."
}

tostring ParticipationRate, replace force
replace ParticipationRate = "--" if ParticipationRate == "."

// Generating missing variables
gen Lev5_count = ""
gen Lev5_percent = ""
gen AssmtName = "STAAR"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "N"
gen Flag_CutScoreChange_sci = "N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 2-4"
gen state_leaid = "TX-"+StateAssignedDistID
replace state_leaid = "" if DataLevel == 1
gen seasch = StateAssignedDistID+"-"+StateAssignedSchID
replace seasch = "" if DataLevel != 3

// Generating Student Group Counts
bysort StateAssignedDistID StateAssignedSchID StudentGroup Grade Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

// Saving transformed data
save "$output_files/TX_AssmtData_2021.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES_2020_District.dta", clear

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if state_location == "TX"

merge 1:m state_leaid using "${output_files}/TX_AssmtData_2021.dta", keep(match using) nogenerate

save "$output_files/TX_AssmtData_2021.dta", replace

// Merging with NCES School Data

use "$NCES_files/NCES_2020_School.dta", clear

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if state_location == "TX"

merge 1:m seasch using "${output_files}/TX_AssmtData_2021.dta", keep(match using) nogenerate

save "$output_files/TX_AssmtData_2021.dta", replace

// Renaming NCES Variables
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

// Relabelling missing SchVirtual
replace SchVirtual = -1 if SchVirtual == . & DataLevel == 3 & NCESSchoolID != "Missing"

//Other Post Launch
drop seasch State_leaid

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/TX_AssmtData_2021.dta", replace
export delimited using "$output_files/TX_AssmtData_2021.csv", replace

