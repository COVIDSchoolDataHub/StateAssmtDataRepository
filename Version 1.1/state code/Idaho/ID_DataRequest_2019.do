clear all
set more off

cd "/Users/miramehta/Documents"

// Define file paths

global original_files "/Users/miramehta/Documents/ID State Testing Data/Idaho data received from data request 11-27-23"
global NCES_files "/Users/miramehta/Documents/NCES District and School Demographics"
global output_files "/Users/miramehta/Documents/ID State Testing Data/Output"
global temp_files "/Users/miramehta/Documents/ID State Testing Data/Temporary Files"

// 2018-2019
/*
import excel "$original_files/2018-2019 Assessment Aggregates (Redacted).xlsx", sheet("State Of Idaho") firstrow clear
gen DataLevel = "State"
save "${temp_files}/ID_AssmtData_2019_state.dta", replace

import excel "$original_files/2018-2019 Assessment Aggregates (Redacted).xlsx", sheet("Districts") firstrow clear
gen DataLevel = "District"
save "${temp_files}/ID_AssmtData_2019_district.dta", replace

import excel "$original_files/2018-2019 Assessment Aggregates (Redacted).xlsx", sheet("Schools") firstrow clear
gen DataLevel = "School"
save "${temp_files}/ID_AssmtData_2019_school.dta", replace

clear

append using "${temp_files}/ID_AssmtData_2019_state.dta" "${temp_files}/ID_AssmtData_2019_district.dta" "${temp_files}/ID_AssmtData_2019_school.dta"

save "${temp_files}/ID_AssmtData_2019_all.dta", replace
*/
// Renaming Variables

use "${temp_files}/ID_AssmtData_2019_all.dta", clear

rename SubjectName Subject
rename Grade GradeLevel
rename Population StudentSubGroup
rename Advanced Lev4_count
rename AdvancedRate	Lev4_percent
rename Proficient Lev3_count
rename ProficientRate Lev3_percent
rename Basic Lev2_count
rename BasicRate Lev2_percent
rename BelowBasic Lev1_count
rename BelowBasicRate Lev1_percent
rename Tested StudentSubGroup_TotalTested
rename TestedRate ParticipationRate
rename DistrictId StateAssignedDistID
rename DistrictName DistName
rename SchoolId StateAssignedSchID
rename SchoolName SchName
drop ParticipationDenominator
drop ProficiencyDenominator

// Dropping irrelevant Observations
drop if Lev1_percent == "N/A"
drop if GradeLevel == "High School"
drop if GradeLevel == "All Grades"

// StudentSubGroup
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup,"Asian") !=0
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup,"Black") !=0
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Economically Disadvantaged "
replace StudentSubGroup = "Not Economically Disadvantaged" if strpos(StudentSubGroup, "Not Economically Disadvantaged") !=0
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "American Indian or Alaskan Native") !=0
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not LEP"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two Or More") !=0
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without Disabilities"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected"

// StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"

// GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ","",.)
keep if GradeLevel == "3" | GradeLevel == "4" | GradeLevel == "5" | GradeLevel == "6" | GradeLevel == "7" | GradeLevel == "8"
replace GradeLevel = "G0" + GradeLevel

// DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3

//Derive Missing Student Counts
replace StudentSubGroup_TotalTested = Lev1_count + Lev2_count + Lev3_count + Lev4_count if StudentSubGroup_TotalTested == .

//Proficient or above percent and Dealing with ranges
gen missing = ""
foreach n in 1 2 3 4 {
	gen Range`n' = ""
}
foreach n in 1 2 3 4 {
	gen Suppressed`n' = "*" if strpos(Lev`n'_percent,"*") !=0 | strpos(Lev`n'_percent, "NSIZE") !=0
	replace Range`n' = "-1" if strpos(Lev`n'_percent, ">") !=0
	replace Range`n' = "0-" if strpos(Lev`n'_percent, "<") !=0
	replace missing = "Y" if Lev`n'_percent == "N/A"
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*NSIZE/A<>)
	replace nLev`n'_percent = nLev`n'_percent/100
	replace Lev`n'_percent = Range`n' + string(nLev`n'_percent, "%9.4f")
	replace Lev`n'_percent = substr(Lev`n'_percent, 3, 8) + Range`n' if Range`n' == "-1"
	replace Lev`n'_percent = "*" if Suppressed`n' == "*"
	replace Lev`n'_percent = "--" if missing == "Y"

}
gen ProficientOrAbove_percent = string(nLev3_percent + nLev4_percent, "%9.4f")
replace ProficientOrAbove_percent = "*" if Suppressed3 == "*" | Suppressed4 == "*"
replace ProficientOrAbove_percent = "*" if Range3 != Range4 & !missing(Range3) & !missing(Range4)
replace ProficientOrAbove_percent = Lev3_percent + "-" + ProficientOrAbove_percent if Range4 == "0-" & missing(Range3)
replace ProficientOrAbove_percent = Lev4_percent + "-" + ProficientOrAbove_percent if Range3 == "0-" & missing(Range4)
replace ProficientOrAbove_percent = "0-" + ProficientOrAbove_percent if Range3 == "0-" & Range4 == "0-"
replace ProficientOrAbove_percent = ProficientOrAbove_percent + "-1" if Range3 == "-1" & ProficientOrAbove_percent != "*"
replace ProficientOrAbove_percent = ProficientOrAbove_percent + "-1" if Range4 == "-1" & ProficientOrAbove_percent != "*"

destring ProficientOrAbove_percent, gen(ind) i(*-) force
replace ind = 1 if ind > 1 & !missing(ind)
replace ProficientOrAbove_percent = "*" if ind == 1 & !missing(Range3) & !missing(Range4)
drop ind
replace ProficientOrAbove_percent = "--" if missing== "Y"

replace ParticipationRate = "--" if ParticipationRate == "N/A"
replace ParticipationRate = "*" if ParticipationRate == "NSIZE" | strpos(ParticipationRate, "*") !=0
gen PartRange = "Y" if strpos(ParticipationRate,">") !=0
destring ParticipationRate, gen(Part) i(*->)
replace Part = Part/100
replace ParticipationRate = string(Part, "%9.4f") if !missing(Part)
replace ParticipationRate = ParticipationRate + "-1" if PartRange == "Y"
drop PartRange

generate ProficientOrAbove_count = Lev3_count + Lev4_count
replace ProficientOrAbove_count = StudentSubGroup_TotalTested - (Lev1_count + Lev2_count) if ProficientOrAbove_count == .

foreach n in 1 2 3 4 {
replace Lev`n'_percent = "--" if Lev`n'_percent == "*" & (Suppressed1 != Suppressed2 | Suppressed3 != Suppressed4 | Suppressed2 != Suppressed3)
tostring Lev`n'_count, replace force
replace Lev`n'_count = "*" if Lev`n'_count == "."
replace Lev`n'_count = "--" if Lev`n'_percent == "--"
}
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev3_count == "*"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev4_count == "*"
replace ParticipationRate = "--" if Lev1_percent == "--" & Lev2_percent == "--" & Lev3_percent == "--" & Lev4_percent == "--"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev3_percent == "--"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev4_percent == "--"
drop Part

// Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

// Missing Variables
gen State = "Idaho"
gen SchYear = "2018-19"
gen Lev5_percent = ""
gen Lev5_count = ""
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3-4"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = ""
gen Flag_CutScoreChange_sci = "N"
gen AssmtName = "ISAT"
gen AssmtType = "Regular"
gen state_leaid = "ID-"+StateAssignedDistID
gen seasch = StateAssignedDistID+"-"+StateAssignedSchID

// Generating + Formatting Student Group Counts
bysort state_leaid seasch StudentGroup Grade Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)
tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

// Saving transformed data
save "${output_files}/ID_AssmtData_2019.dta", replace

// Merging with NCES School Data

use "$NCES_files/NCES School Files, Fall 1997-Fall 2022/NCES_2018_School.dta", clear 

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code

drop if seasch == ""

keep if substr(ncesschoolid, 1, 2) == "16"

merge 1:m seasch using "${output_files}/ID_AssmtData_2019.dta", keep(match using) nogenerate

save "${output_files}/ID_AssmtData_2019.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES District Files, Fall 1997-Fall 2022/NCES_2018_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter DistLocale county_name county_code

keep if substr(ncesdistrictid, 1, 2) == "16"

merge 1:m state_leaid using "${output_files}/ID_AssmtData_2019.dta", keep(match using) nogenerate

// Removing extra variables and renaming NCES variables
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_location StateAbbrev
rename county_code CountyCode
rename state_fips StateFips
rename county_name CountyName
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc

// Fixing missing state data
replace StateAbbrev = "ID" if DataLevel == 1
replace StateFips = 16 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3

// Dropping not ID data
drop if StateAbbrev != "ID"

//Variable Types
decode SchVirtual, gen(SchVirtual_s)
drop SchVirtual
rename SchVirtual_s SchVirtual

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen (SchType_s)
drop SchType
rename SchType_s SchType

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/ID_AssmtData_2019.dta", replace
export delimited using "$output_files/ID_AssmtData_2019.csv", replace

