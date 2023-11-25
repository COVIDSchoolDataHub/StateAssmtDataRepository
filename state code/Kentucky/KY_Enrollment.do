clear

// Define file paths

global original_files "/Users/meghancornacchia/Desktop/DataRepository/Kentucky/Original_Data_Files"
global output_files "/Users/meghancornacchia/Desktop/DataRepository/Kentucky/Output_Data_Files"
global temp_files "/Users/meghancornacchia/Desktop/DataRepository/Kentucky/Temporary_Data_Files"



// 2022

// Trying to add enrollment data
import delimited "$original_files/KY_OriginalData_Enrollment_2022.csv", case(preserve) stringcols(10) clear 

// Dropping irrelevant grades/categories
drop PRESCHOOL*
drop KINDER*
drop TOTAL*
drop GRADE1*
drop GRADE2*
drop GRADE9*
drop *MALE*

// Reshaping
rename *COUNT Count*
reshape long Count, i(SCHOOLNAME DISTRICTNAME NCESID Demographic) j(GradeLevel, string)

// Dropping irrelevant variables
keep SCHOOLNAME DISTRICTNAME NCESID Demographic GradeLevel Count

// Transform Values
replace GradeLevel = "G0"+substr(GradeLevel, 6, 1)
replace Demographic = "Black or African American" if Demographic == "African American"
replace	Demographic = "Two or More" if Demographic == "Two or More Races"
replace Demographic = "White" if Demographic == "White (Non Hispanic)"
replace SCHOOLNAME = "All Schools" if SCHOOLNAME == "---District Total---"
replace SCHOOLNAME = "All Schools" if SCHOOLNAME == "---State Total---"
replace DISTRICTNAME = "All Districts" if DISTRICTNAME == "State"

// Renaming variables
rename SCHOOLNAME SchName
rename DISTRICTNAME DistName
rename Demographic StudentSubGroup
rename Count StudentSubGroup_TotalEnrolled

// Handling NCES IDs
rename NCESID NCESSchoolID
replace NCESSchoolID = "Missing" if NCESSchoolID == ""

// Fixing missing ids
replace NCESSchoolID = "210007002535" if SchName == "Patriot Academy"
replace NCESSchoolID = "210024002542" if SchName == "Barbourville Learning Center"
replace NCESSchoolID = "210147002538" if SchName == "Virtual Academy"
replace NCESSchoolID = "210246002540" if SchName == "Hancock County Alternative Program"
replace NCESSchoolID = "210315002543" if SchName == "Lynn Camp Elementary School"
replace NCESSchoolID = "210315002544" if SchName == "Lynn Camp Middle High School"
replace NCESSchoolID = "210354002529" if SchName == "Cougar Virtual Academy"
replace NCESSchoolID = "210051002522" if SchName == "Steeplechase Elementary School"
replace NCESSchoolID = "210051002523" if SchName == "ACCEL Academy"
replace NCESSchoolID = "210115002524" if SchName == "Christian County Public Schools VLA"
replace NCESSchoolID = "210336002528" if SchName == "Letcher Elementary & Middle School"
replace NCESSchoolID = "210372002530" if SchName == "Madison County Virtual Academy"
replace NCESSchoolID = "210408002531" if SchName == "Menifee Central School"
replace NCESSchoolID = "210417002521" if SchName == "Middlesboro Group Home School"
replace NCESSchoolID = "210558002534" if SchName == "Harbor Academy and Virtual School"


replace NCESSchoolID = "" if NCESSchoolID == "Missing" & SchName == "All Schools"
gen NCESDistrictID = substr(NCESSchoolID, 1, 7)

// Fixing Schools for Blind and Deaf
replace DistName = "Kentucky School for the Blind District" if DistName == "Kentucky School for the Blind"
replace DistName = "Kentucky School for the Deaf District" if DistName == "Kentucky School for the Deaf"

preserve
keep DistName NCESDistrictID
duplicates drop
drop if NCESDistrictID == "" | NCESDistrictID == "Missing"
rename NCESDistrictID NCESDistrictIDNEW
save "$temp_files/NCESDistIDs_2022.dta", replace
restore

merge m:1 DistName using "$temp_files/NCESDistIDs_2022.dta", nogenerate
replace NCESDistrictID = NCESDistrictIDNEW if NCESDistrictID == ""
drop NCESDistrictIDNEW

// Sorting
sort DistName SchName StudentSubGroup

// Dropping missing counts
drop if StudentSubGroup_TotalEnrolled == .
drop if NCESSchoolID == "Missing"

// Saving
save "$output_files/KY_Enrollment_2022.dta", replace
*/

// 2023

// Trying to add enrollment data
import delimited "$original_files/KY_OriginalData_Enrollment_2023.csv", case(preserve) stringcols(10) clear 

// Dropping irrelevant grades/categories
drop PRESCHOOL*
drop KINDER*
drop TOTAL*
drop GRADE1*
drop GRADE2*
drop GRADE9*
drop *MALE*

// Reshaping
rename *COUNT Count*
reshape long Count, i(SCHOOLNAME DISTRICTNAME NCESID Demographic) j(GradeLevel, string)

// Dropping irrelevant variables
keep SCHOOLNAME DISTRICTNAME NCESID Demographic GradeLevel Count

// Transform Values
replace GradeLevel = "G0"+substr(GradeLevel, 6, 1)
replace Demographic = "Black or African American" if Demographic == "African American"
replace	Demographic = "Two or More" if Demographic == "Two or More Races"
replace Demographic = "White" if Demographic == "White (Non Hispanic)"
replace SCHOOLNAME = "All Schools" if SCHOOLNAME == "---District Total---"
replace SCHOOLNAME = "All Schools" if SCHOOLNAME == "---State Total---"
replace DISTRICTNAME = "All Districts" if DISTRICTNAME == "State"

// Renaming variables
rename SCHOOLNAME SchName
rename DISTRICTNAME DistName
rename Demographic StudentSubGroup
rename Count StudentSubGroup_TotalEnrolled

// Handling NCES IDs
rename NCESID NCESSchoolID
replace NCESSchoolID = "Missing" if NCESSchoolID == ""

// Fixing missing ids
replace NCESSchoolID = "210007002535" if SchName == "Patriot Academy"
replace NCESSchoolID = "210024002542" if SchName == "Barbourville Learning Center"
replace NCESSchoolID = "210147002538" if SchName == "Virtual Academy"
replace NCESSchoolID = "210246002540" if SchName == "Hancock County Alternative Program"
replace NCESSchoolID = "210315002543" if SchName == "Lynn Camp Elementary School"
replace NCESSchoolID = "210315002544" if SchName == "Lynn Camp Middle High School"
replace NCESSchoolID = "210354002529" if SchName == "Cougar Virtual Academy"

replace NCESSchoolID = "" if NCESSchoolID == "Missing" & SchName == "All Schools"
gen NCESDistrictID = substr(NCESSchoolID, 1, 7)

// Fixing Schools for Blind and Deaf
replace DistName = "Kentucky School for the Blind District" if DistName == "Kentucky School for the Blind"
replace DistName = "Kentucky School for the Deaf District" if DistName == "Kentucky School for the Deaf"

preserve
keep DistName NCESDistrictID
duplicates drop
drop if NCESDistrictID == "" | NCESDistrictID == "Missing"
rename NCESDistrictID NCESDistrictIDNEW
save "$temp_files/NCESDistIDs_2023.dta", replace
restore

merge m:1 DistName using "$temp_files/NCESDistIDs_2023.dta", nogenerate
replace NCESDistrictID = NCESDistrictIDNEW if NCESDistrictID == ""
drop NCESDistrictIDNEW


// Sorting
sort DistName SchName StudentSubGroup

// Dropping missing counts
drop if StudentSubGroup_TotalEnrolled == .
drop if NCESSchoolID == "Missing"

// Saving
save "$output_files/KY_Enrollment_2023.dta", replace


*/

// Now merging with 2022 assessment data

import delimited using "$original_files/KY_AssmtData_2022.csv", case(preserve) stringcols(10 13) clear

merge m:1 NCESDistrictID NCESSchoolID GradeLevel StudentSubGroup using "$output_files/KY_Enrollment_2022.dta"
drop if _merge == 2
drop _merge
bysort NCESDistrictID NCESSchoolID StudentGroup Grade Subject: egen StudentGroup_TotalEnrolled = sum(StudentSubGroup_TotalEnrolled)
tostring StudentSubGroup_TotalEnrolled, replace force
tostring StudentGroup_TotalEnrolled, replace force
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalEnrolled if StudentSubGroup_TotalEnrolled != "."
drop StudentSubGroup_TotalEnrolled
replace StudentGroup_TotalTested = StudentGroup_TotalEnrolled if StudentGroup_TotalEnrolled != "."
drop StudentGroup_TotalEnrolled
replace StudentGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "--"

// Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output_files}/KY_AssmtData_2022_enrollment.dta", replace
export delimited using "$output_files/KY_AssmtData_2022_enrollment.csv", replace

// Now merging with 2023 assessment data

import delimited using "$original_files/KY_AssmtData_2023.csv", case(preserve) stringcols(10 13) clear

merge m:1 NCESDistrictID NCESSchoolID GradeLevel StudentSubGroup using "$output_files/KY_Enrollment_2023.dta"
drop if _merge == 2
drop _merge
bysort NCESDistrictID NCESSchoolID StudentGroup Grade Subject: egen StudentGroup_TotalEnrolled = sum(StudentSubGroup_TotalEnrolled)
tostring StudentSubGroup_TotalEnrolled, replace force
tostring StudentGroup_TotalEnrolled, replace force
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalEnrolled if StudentSubGroup_TotalEnrolled != "."
drop StudentSubGroup_TotalEnrolled
replace StudentGroup_TotalTested = StudentGroup_TotalEnrolled if StudentGroup_TotalEnrolled != "."
drop StudentGroup_TotalEnrolled
replace StudentGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "--"

// Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output_files}/KY_AssmtData_2023_enrollment.dta", replace
export delimited using "$output_files/KY_AssmtData_2023_enrollment.csv", replace
