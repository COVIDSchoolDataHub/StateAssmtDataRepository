clear all
set more off

cd "/Users/miramehta/Documents"
global data "/Users/miramehta/Documents/ND State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"
global NCES_clean "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global counts "/Users/miramehta/Documents/EdFacts Data"

//Import & Rename Variables
import excel "$data/ND_EnrollmentData_1421.xlsx", clear
rename A SchName
rename B DataLevel
rename C StateAssignedSchID
rename D DistName
rename E GradeLevel
rename N Enrolled22
rename O Enrolled23

drop if SchName == "Institution"
drop F G H I J K L M

//Data Levels
replace SchName = "All Schools" if DataLevel != "School"
gen StateAssignedDistID = ""
replace StateAssignedDistID = StateAssignedSchID if DataLevel == "District"
replace StateAssignedDistID = substr(StateAssignedSchID, 1, 5) if DataLevel == "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

//Reshape Data
reshape long Enrolled, i(StateAssignedDistID DistName StateAssignedSchID SchName GradeLevel) j(SchYear) string
replace SchYear = "2021-22" if SchYear == "22"
replace SchYear = "2022-23" if SchYear == "23"

//Grade Levels
drop if GradeLevel == "PK" | GradeLevel == "K"
destring GradeLevel, replace
drop if GradeLevel < 3
drop if GradeLevel > 8
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

gen StudentSubGroup = "All Students"
save "$data/ND_EnrollmentData_2223.dta", replace
