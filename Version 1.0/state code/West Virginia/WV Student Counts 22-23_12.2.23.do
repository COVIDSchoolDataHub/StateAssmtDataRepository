clear all
set more off

cd "/Users/miramehta/Documents/"
global data "/Users/miramehta/Documents/WV State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"
global NCES_clean "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global counts "/Users/miramehta/Documents/EdFacts Data"

//2022//
import excel "$data/WV_EnrollmentData_2022.xlsx", sheet("SY21-22 School Composition") clear

//Rename Variables
rename A StateAssignedDistID
rename B StateAssignedSchID
rename D DistName
rename E SchName

//Data Levels
replace SchName = F if F == "All Schools"
replace StateAssignedSchID = "" if SchName == "All Schools"
replace DistName = "All Districts" if DistName == "State"

//Remove Unncessary Information
drop if StateAssignedDistID == "*Note: State totals do not include students enrolled in West Virginia Schools of Diversion and Transition or the West Virginia Schools for the Deaf and Blind. Columns may not sum to the state total due to suppression of data for schools which had total enrollments less than 10 students."
drop if StateAssignedDistID == ""
drop if StateAssignedDistID == "District Code"
replace StateAssignedDistID = "" if DistName == "All Districts"
drop C F G H I J Q R S T U V W X Y Z AA AB AC AD AE AF AG

//Reshape Data
rename K StudentSubGroup_TotalTestedG03
rename L StudentSubGroup_TotalTestedG04
rename M StudentSubGroup_TotalTestedG05
rename N StudentSubGroup_TotalTestedG06
rename O StudentSubGroup_TotalTestedG07
rename P StudentSubGroup_TotalTestedG08

reshape long StudentSubGroup_TotalTested, i(StateAssignedDistID StateAssignedSchID) j(GradeLevel) string

gen StudentSubGroup = "All Students"

save "$data/WV_EnrollmentData_2022.dta", replace

//2023//
import excel "$data/WV_EnrollmentData_2023.xlsx", sheet("SY22-23 School Composition") clear

//Rename Variables
rename B StateAssignedDistID
rename C DistName
rename D StateAssignedSchID
rename E SchName

//Data Levels
replace StateAssignedSchID = "" if SchName == "All Schools"
replace DistName = "All Districts" if DistName == "Statewide"

//Remove Unncessary Information
drop if StateAssignedDistID == ""
drop if A == "Year"
replace StateAssignedDistID = "" if DistName == "All Districts"
drop A F G H I J Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV

//Reshape Data
rename K StudentSubGroup_TotalTestedG03
rename L StudentSubGroup_TotalTestedG04
rename M StudentSubGroup_TotalTestedG05
rename N StudentSubGroup_TotalTestedG06
rename O StudentSubGroup_TotalTestedG07
rename P StudentSubGroup_TotalTestedG08

reshape long StudentSubGroup_TotalTested, i(StateAssignedDistID StateAssignedSchID) j(GradeLevel) string

gen StudentSubGroup = "All Students"

//Modify IDs
split StateAssignedSchID, p(" ")
replace StateAssignedSchID = StateAssignedSchID1
split StateAssignedDistID, p(" ")
replace StateAssignedDistID = StateAssignedDistID1
drop StateAssignedSchID1 StateAssignedDistID1

save "$data/WV_EnrollmentData_2023.dta", replace

