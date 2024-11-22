clear all

global Original "/Users/miramehta/Documents/DE State Testing Data/Original Data Files"
global Output "/Users/miramehta/Documents/DE State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

//Import Relevant Data - Unhide on first run
/*
import excel "$Original/DE_OriginalData_ela_mat_2015-2018.xlsx", firstrow case(preserve) clear

keep if SchoolYear == 2016
drop SchoolYear

save "$Original/DE_OriginalData_ela_mat_2016.dta", replace
*/
use "$Original/DE_OriginalData_ela_mat_2016.dta", clear

//Rename Variables
rename DistrictCode StateAssignedDistID
rename District DistName
rename SchoolCode StateAssignedSchID
rename Organization SchName
rename AssessmentName AssmtName
rename ContentArea Subject
rename Grade GradeLevel
rename Tested StudentSubGroup_TotalTested
rename Proficient ProficientOrAbove_count
rename PctProficient ProficientOrAbove_percent
rename PctParticipation ParticipationRate
rename ScaleScoreAvg AvgScaleScore
rename PL* Lev*_count
rename PctPL* Lev*_percent

//Data Levels
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == 0
replace DataLevel = "State" if StateAssignedDistID == 0

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1

//Subject & GradeLevel
replace Subject = strlower(Subject)
replace GradeLevel = substr(GradeLevel, 1, 1)
replace GradeLevel = "G0" + GradeLevel

//StudentSubGroup & StudentGroup
gen StudentSubGroup = Race if Gender == "All Students" & SpecialDemo == "All Students"
replace StudentSubGroup = Gender if Race == "All Students" & SpecialDemo == "All Students"
replace StudentSubGroup = SpecialDemo if Race == "All Students" & Gender == "All Students"

gen StudentGroup = "RaceEth" if StudentSubGroup == Race
replace StudentGroup = "Gender" if StudentSubGroup == Gender
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
drop Race Gender SpecialDemo

replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ", 1)
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian American"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-Racial"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Low-Income"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non Low-Income"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Active EL Students"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-EL Students"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"

replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "EL Status"  if inlist(StudentSubGroup, "English Learner", "English Proficient")
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"

sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"

gen flag = 1 if StudentSubGroup_TotalTested == .
bysort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup: egen group_missing = total(flag)
bysort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel: egen RaceEth = total(StudentSubGroup_TotalTested) if StudentGroup == "RaceEth"
bysort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel: egen Gender = total(StudentSubGroup_TotalTested) if StudentGroup == "Gender"
bysort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel: egen Disability = total(StudentSubGroup_TotalTested) if StudentGroup == "Disability Status"
bysort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel: egen Econ = total(StudentSubGroup_TotalTested) if StudentGroup == "Economic Status"
bysort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel: egen ELStatus = total(StudentSubGroup_TotalTested) if StudentGroup == "EL Status"

replace StudentSubGroup_TotalTested = StudentGroup_TotalTested - RaceEth if StudentSubGroup_TotalTested == . & group_missing == 1 & StudentGroup == "RaceEth"
replace StudentSubGroup_TotalTested = StudentGroup_TotalTested - Gender if StudentSubGroup_TotalTested == . & group_missing == 1 & StudentGroup == "Gender"
replace StudentSubGroup_TotalTested = StudentGroup_TotalTested - Disability if StudentSubGroup_TotalTested == . & group_missing == 1 & StudentGroup == "Disability Status"
replace StudentSubGroup_TotalTested = StudentGroup_TotalTested - Econ if StudentSubGroup_TotalTested == . & group_missing == 1 & StudentGroup == "Economic Status"
replace StudentSubGroup_TotalTested = StudentGroup_TotalTested - ELStatus if StudentSubGroup_TotalTested == . & group_missing == 1 & StudentGroup == "EL Status"
drop flag group_missing RaceEth Gender Disability Econ ELStatus

//Performance Information
foreach var of varlist *_percent ParticipationRate{
	replace `var' = `var'/100
}

replace Lev3_percent = ProficientOrAbove_percent - Lev4_percent if Lev3_percent == . & ProficientOrAbove_percent != . & Lev4_percent != .
replace Lev3_count = ProficientOrAbove_count - Lev4_count if Lev3_count == . & ProficientOrAbove_count != . & Lev4_count != .
replace Lev4_percent = ProficientOrAbove_percent - Lev3_percent if Lev4_percent == . & ProficientOrAbove_percent != . & Lev3_percent != .
replace Lev4_count = ProficientOrAbove_count - Lev3_count if Lev4_count == . & ProficientOrAbove_count != . & Lev3_count != .

replace Lev1_percent = 1 - ProficientOrAbove_percent - Lev2_percent if Lev1_percent == . & ProficientOrAbove_percent != . & Lev2_percent != .
replace Lev1_count = StudentSubGroup_TotalTested - ProficientOrAbove_percent - Lev2_count if Lev1_count == . & ProficientOrAbove_count != . & Lev2_count != . & StudentSubGroup_TotalTested != .
replace Lev2_percent = 1 - ProficientOrAbove_percent - Lev1_percent if Lev2_percent == . & ProficientOrAbove_percent != . & Lev1_percent != .
replace Lev2_count = StudentSubGroup_TotalTested - ProficientOrAbove_percent - Lev1_count if Lev2_count == . & ProficientOrAbove_count != . & Lev1_count != . & StudentSubGroup_TotalTested != .

foreach var of varlist *_count *_percent ParticipationRate AvgScaleScore {
	if strpos("`var'", "count") > 0 tostring `var', replace format("%9.0f") force
	if strpos("`var'", "count") == 0 tostring `var', replace format("%9.4f") force
	replace `var' = "*" if `var' == "."
}

drop RowStatus

tostring StudentGroup_TotalTested, replace
tostring StudentSubGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."

replace AvgScaleScore = substr(AvgScaleScore, 1, 7) if !inlist(AvgScaleScore, "*", "--")

gen Lev5_count = ""
gen Lev5_percent = ""

//Additional Variables
gen SchYear = "2015-16"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"

//Merge with NCES
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3

replace StateAssignedDistID = "" if SchName == "Delaware College Preparatory Academy" //pulling in NCES assigned State ID, which is not the same as the value in the raw data
replace DistName = "" if SchName == "Delaware College Preparatory Academy" //pulling in NCES assigned district, which is not the same as the value in the raw data

merge m:1 StateAssignedSchID using "$NCES/NCES_2015_School_DE", update
drop if _merge == 2
drop if _merge == 1 & DataLevel == 3 //all data for these schools are suppressed
drop _merge

merge m:1 StateAssignedDistID using "$NCES/NCES_2015_District_DE", update
drop if _merge == 2
drop _merge

//Cleaning up from NCES
replace State = "Delaware"
replace StateAbbrev = "DE"
replace StateFips = 10

//Standardizing DistName & SchName
replace DistName = strtrim(DistName)
replace DistName = stritrim(DistName)
replace SchName = strtrim(SchName)
replace SchName = stritrim(SchName)
replace DistName = "Campus Community School" if NCESDistrictID == "1000007"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Output/DE_AssmtData_2016.dta", replace
export delimited "$Output/DE_AssmtData_2016.csv", replace
