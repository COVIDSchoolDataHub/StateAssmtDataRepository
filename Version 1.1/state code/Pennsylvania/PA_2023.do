clear all

// Define file paths
global original_files "/Users/miramehta/Documents/PA State Testing Data/Original_Data_Files"
global NCES_school "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCES_district "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global output_files "/Users/miramehta/Documents/PA State Testing Data/Output_Data_Files"
global temp_files "/Users/miramehta/Documents/PA State Testing Data/Temporary_Data_Files"

// Import Original Data Files
/*
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
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
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
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"

forvalues n = 1/4{
	replace Lev`n'_percent = Lev`n'_percent/100
	gen Lev`n'_count = round(Lev`n'_percent * StudentSubGroup_TotalTested)
}

replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
gen ProficientOrAbove_count = round(ProficientOrAbove_percent * StudentSubGroup_TotalTested)

foreach var of varlist Lev1_percent Lev1_count Lev2_percent Lev2_count Lev3_percent Lev3_count Lev4_percent Lev4_count ProficientOrAbove_percent ProficientOrAbove_count {
	gen s`var' = string(`var',"%9.3g")
	replace s`var' = "*" if s`var' == "." & StudentSubGroup_TotalTested < 11
	drop `var'
	rename s`var' `var'
}

// Generating missing variables
gen AssmtName = "Pennsylvania System of School Assessment"
gen AssmtType = "Regular"
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3-4"
gen ParticipationRate = "--"
gen Lev5_count = ""
gen Lev5_percent = ""
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"


// Generating StudentGroup count
bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject SchYear: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
replace StudentGroup_TotalTested = AllStudents_Tested if inlist(StudentGroup, "Disability Status", "EL Status", "Economic Status")
drop AllStudents_Tested


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
use "$NCES_school/NCES_2022_School.dta", clear
rename SchVirtual SchVirtual_n
decode district_agency_type, gen (DistType)
drop district_agency_type
rename DistType district_agency_type
merge 1:1 ncesdistrictid ncesschoolid using "$NCES_school/NCES_2021_School.dta", keepusing (county_code county_name district_agency_type SchVirtual)
drop if state_location != "PA"
replace SchVirtual_n = SchVirtual if inlist(SchVirtual_n, -1, .)
drop SchVirtual
rename SchVirtual_n SchVirtual
rename school_type SchType
keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

merge 1:m seasch using "${output_files}/PA_AssmtData_2023.dta", keep(match using)
drop _merge

save "${output_files}/PA_AssmtData_2023.dta", replace

// Merging with NCES District Data

use "$NCES_district/NCES_2022_District.dta", clear
merge 1:1 ncesdistrictid using "$NCES_district/NCES_2021_District.dta", keepusing (county_code county_name DistCharter)
drop if state_location != "PA"

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter DistLocale county_name county_code

merge 1:m state_leaid using "${output_files}/PA_AssmtData_2023.dta", keep(match using) nogenerate

// Renaming NCES variables
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename state_location StateAbbrev
generate State = "Pennsylvania"
rename county_code CountyCode
rename state_fips StateFips
rename county_name CountyName

// Fixing State Level Data
replace StateAbbrev = "PA" if DataLevel == 1
replace StateFips = 42 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

drop seasch State_leaid

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/PA_AssmtData_2023.dta", replace
export delimited using "$output_files/PA_AssmtData_2023.csv", replace
