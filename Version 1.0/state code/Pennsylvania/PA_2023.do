clear all

// Define file paths
global original_files "/Users/meghancornacchia/Desktop/DataRepository/Pennsylvania/Original_Data_Files"
global NCES_files "/Users/meghancornacchia/Desktop/DataRepository/NCES_Data_Files"
global output_files "/Users/meghancornacchia/Desktop/DataRepository/Pennsylvania/Output_Data_Files"
global temp_files "/Users/meghancornacchia/Desktop/DataRepository/Pennsylvania/Temporary_Data_Files"

// All years from data request

//School import

import excel "$original_files/PA_OriginalData_2023_Subgroups_School.xlsx", cellrange(A5) firstrow clear

gen DataLevel = "School"
drop County

save "$temp_files/PA_2023_School.dta", replace


// District import

import excel "$original_files/PA_OriginalData_2023_Subgroups_District.xlsx", cellrange(A5) firstrow clear

gen SchoolName = "All Schools"
gen SchoolNumber = ""
gen DataLevel = "District"
drop County
drop N

save "$temp_files/PA_2023_District.dta", replace

// State import
import excel "$original_files/PA_OriginalData_2023_Subgroups_State.xlsx", cellrange(A4) firstrow clear

gen AUN = .
gen DistrictName = "All Districts"
gen SchoolName = "All Schools"
gen SchoolNumber = ""
gen DataLevel = "State"
rename PercentProficientandAbove PercentProficientandabove
drop K L
drop if Subject == ""

save "$temp_files/PA_2023_State.dta", replace


// Appending All DataLevels
clear
append using "$temp_files/PA_2023_School.dta" "$temp_files/PA_2023_District.dta" "$temp_files/PA_2023_State.dta"
save "$temp_files/PA_2023_All.dta", replace
*/

use "$temp_files/PA_2023_All.dta", clear

// Relabelling variables
rename AUN StateAssignedDistID
rename Group StudentSubGroup
rename Grade GradeLevel
rename NumberScored StudentSubGroup_TotalTested
rename PercentAdvanced Lev4_percent
rename PercentProficient Lev3_percent
rename PercentBasic Lev2_percent
rename PercentBelowBasic Lev1_percent
rename SchoolNumber StateAssignedSchID
rename DistrictName DistName
rename SchoolName SchName
rename PercentProficientandabove ProficientOrAbove_percent

// Transforming variables
gen SchYear = "2022-23" if Year == 2023
drop Year
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"
replace GradeLevel = "G0"+GradeLevel
replace GradeLevel = "G38" if GradeLevel == "G0Total"
gen StudentGroup = "Replace"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American (not Hispanic)"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic (any race)"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-ethnic (not Hispanic)"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian / Alaskan Native (not Hispanic)"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or other Pacific Islander (not Hispanic)"
replace StudentSubGroup = "White" if StudentSubGroup == "White (not Hispanic)"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian (not Hispanic)"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ELL"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
drop if StudentSubGroup == "IEP"

foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	replace `var' = `var'/100
}

foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	gen s`var' = string(`var',"%9.3g")
	replace s`var' = "*" if s`var' == "." & StudentSubGroup_TotalTested < 11
	drop `var'
	rename s`var' `var'
}

// Generating missing variables
gen AssmtName = "Pennsylvania System of School Assessment"
gen AssmtType = "Regular"
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3 and 4"
gen ParticipationRate = "--"
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen ProficientOrAbove_count = "--"
gen Lev5_count = ""
gen Lev5_percent = ""
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"


// Generating StudentGroup count
//replace StateAssignedDistID = "StateLevel" if StateAssignedSchID == ""
bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject SchYear: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

// Relabelling Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


// NCES merging

// Generate ID to match NCES
tostring StateAssignedDistID, gen(state_leaid)
gen seasch = state_leaid+"-"+substr(StateAssignedSchID,-4,4)
replace state_leaid = "PA-"+state_leaid

save "${output_files}/PA_AssmtData_2023.dta", replace

// Merging with NCES School Data

import delimited "$original_files/PA_Unmerged2023.csv", clear stringcols(1 5) case(preserve)
append using "$NCES_files/NCES_2021_School.dta"

label values school_type school_typedf
label values SchLevel school_leveldf
label values SchVirtual virtualdf

keep state_location state_fips district_agency_type school_type ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code

keep if state_location == "PA"
drop if seasch == ""

merge 1:m seasch using "${output_files}/PA_AssmtData_2023.dta", keep(match using)
replace ncesschoolid = "Missing/not reported" if _merge == 2 & DataLevel == 3
drop _merge

save "${output_files}/PA_AssmtData_2023.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES_2021_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code

keep if state_location == "PA"

merge 1:m state_leaid using "${output_files}/PA_AssmtData_2023.dta", keep(match using) nogenerate

replace ncesdistrictid = "4289394" if SchName == "CALIFORNIA ACADEMY OF LEARNING CS"
replace district_agency_type = 7 if SchName == "CALIFORNIA ACADEMY OF LEARNING CS"
replace DistCharter = "Yes" if SchName == "CALIFORNIA ACADEMY OF LEARNING CS"
replace county_code = -1 if SchName == "CALIFORNIA ACADEMY OF LEARNING CS"
replace county_name = "Missing/not reported" if SchName == "CALIFORNIA ACADEMY OF LEARNING CS"
label def agency_typedf 7 "Charter agency", modify
label values district_agency_type agency_typedf
label def county_code -1 "Missing/not reported"


// Renaming NCES variables
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename state_location StateAbbrev
generate State = "Pennsylvania"
rename county_code CountyCode
rename school_type SchType
rename state_fips StateFips
rename county_name CountyName

// Fixing State Level Data
replace StateAbbrev = "PA" if DataLevel == 1
replace StateFips = 42 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2
replace seasch = "" if DataLevel != 3
replace State_leaid = "" if DataLevel != 3

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/PA_AssmtData_2023.dta", replace
export delimited using "$output_files/PA_AssmtData_2023.csv", replace
