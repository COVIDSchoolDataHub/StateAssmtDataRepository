clear
cd "/Users/meghancornacchia/Desktop/DataRepository/Wyoming"
local Original "/Users/meghancornacchia/Desktop/DataRepository/Wyoming/Original_Data_Files"
local Output "/Users/meghancornacchia/Desktop/DataRepository/Wyoming/Output"
local NCES "/Users/meghancornacchia/Desktop/DataRepository/Wyoming/New_NCES"
local EDFacts "/Users/meghancornacchia/Desktop/DataRepository/Wyoming/EDFacts"
local Temp "/Users/meghancornacchia/Desktop/DataRepository/Wyoming/Temporary Data Files"


import delimited "`EDFacts'/EDFacts2022.csv", case(preserve) clear 

// Keep relevant observations and variables
keep if strpos(DataDescription, "Part") != 0
drop if AgeGrade == "High School" | AgeGrade == "All Grades"
replace Subgroup = Characteristics if Subgroup == ""
drop SchoolYear State DataGroup DataDescription Value Denominator Population Characteristics ProgramType Outcome LEA School

// Rename variables
rename NCESLEAID NCESDistrictID
rename NCESSCHID NCESSchoolID
rename Numerator StudentSubGroup_TotalTested
rename Subgroup StudentSubGroup
rename AgeGrade GradeLevel
rename AcademicSubject Subject

// Make Data Levels
gen DataLevel = "School"
replace DataLevel = "District" if NCESSchoolID == .
replace DataLevel = "State" if NCESDistrictID == .

// Transform values
replace Subject = "ela" if Subject == "Reading/Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
	
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All Students") != 0
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/Alaska Native/Native American"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black (not Hispanic) African American"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multicultural/Multiethnic/Multiracial/other"
replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian (not Hispanic)"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Children with disabilities"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migratory students"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military connected"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster care students"
drop if StudentSubGroup == "Asian/Pacific Islander" & DataLevel == "State"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"

replace GradeLevel = "G0"+substr(GradeLevel,-1,1)

// Make NCES ids strings
tostring NCESSchoolID, replace format(%12.0f)
tostring NCESDistrictID, replace format(%7.0f)
replace NCESSchoolID = "" if NCESSchoolID == "."
replace NCESDistrictID = "" if NCESDistrictID == "."

//Calculating StudentSubGroup_TotalTested where possible (for ECD and LEP)
destring StudentSubGroup_TotalTested, replace
tempfile temp1
save "`temp1'", replace
keep if StudentSubGroup == "All Students" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "English Learner" | StudentSubGroup == "SWD" | StudentSubGroup == "Foster Care" | StudentSubGroup == "Homeless" | StudentSubGroup == "Military" | StudentSubGroup == "Migrant"
expand 2 if StudentSubGroup != "All Students"
gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
sort NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup
replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
bysort NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup: replace StudentSubGroup_TotalTested = AllStudents - StudentSubGroup_TotalTested if _n==2
replace StudentSubGroup = "English Proficient" if StudentSubGroup[_n-1] == "English Learner"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup[_n-1] == "Economically Disadvantaged"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup[_n-1] == "SWD"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup[_n-1] == "Foster Care"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup[_n-1] == "Homeless"
replace StudentSubGroup = "Non-Military" if StudentSubGroup[_n-1] == "Military"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup[_n-1] == "Migrant"

tempfile tempcalc
save "`tempcalc'", replace
clear
use "`temp1'"
drop if StudentSubGroup == "All Students" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "English Learner" | StudentSubGroup == "SWD" | StudentSubGroup == "Foster Care" | StudentSubGroup == "Homeless" | StudentSubGroup == "Military" | StudentSubGroup == "Migrant"
append using "`tempcalc'"
sort NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup

// Renaming variables to ease merging
rename StudentSubGroup_TotalTested EDStudentSubGroup_TotalTested
drop AllStudents

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
order DataLevel

// Save
save "`Temp'/_2022_count", replace

forvalues year = 2022/2023 {

use "`Output'/WY_AssmtData_`year'", clear
merge 1:1 DataLevel NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup using "`Temp'/_2022_count"
drop if _merge == 2
drop _merge

//Cleaning StudentSubGroup_TotalTested and Generating StudentGroup_TotalTested
egen EDStudentGroup_TotalTested = total(EDStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)
tostring EDStudentGroup_TotalTested EDStudentSubGroup_TotalTested, replace

// Apply All Student tested counts if still have ranges
gen AllStudents = EDStudentGroup_TotalTested if StudentSubGroup == "All Students"
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
replace EDStudentGroup_TotalTested = AllStudents if EDStudentGroup_TotalTested == "0" & StudentGroup != "All Students"

// Generating Level counts
destring EDStudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*)
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*-)
gen nProficientOrAbove_count = nProficientOrAbove_percent * nStudentSubGroup_TotalTested
replace nProficientOrAbove_count = round(nProficientOrAbove_count,1)
replace ProficientOrAbove_count = string(nProficientOrAbove_count,"%9.0g") if nProficientOrAbove_count != .
replace ProficientOrAbove_count = "*" if (ProficientOrAbove_percent == "*" | StudentSubGroup_TotalTested == "*") & nProficientOrAbove_count == .
foreach n in 1 2 3 4 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*-)
	gen nLev`n'_count = nLev`n'_percent*nStudentSubGroup_TotalTested
	replace nLev`n'_count = round(nLev`n'_count,1)
	replace Lev`n'_count = string(nLev`n'_count, "%9.0g") if nLev`n'_count != .
	replace Lev`n'_count = "*" if Lev`n'_percent == "*" | StudentSubGroup_TotalTested == "*"
}

// Replace with EDFacts when possible
replace StudentGroup_TotalTested = EDStudentGroup_TotalTested if EDStudentSubGroup_TotalTested != "."
replace StudentSubGroup_TotalTested = EDStudentSubGroup_TotalTested if EDStudentSubGroup_TotalTested != "."

drop nLev*_percent

// Setting part rate to 0 if tested count = 0
foreach var of varlist Lev* ParticipationRate ProficientOrAbove* {
	replace `var' = "0" if StudentSubGroup_TotalTested == "0"
	replace Lev5_count = "" if StudentSubGroup_TotalTested == "0"
	replace Lev5_percent = "" if StudentSubGroup_TotalTested == "0"
}

//Final Cleaning
recast str80 SchName
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "`Output'/WY_AssmtData_`year'", replace
export delimited "`Output'/WY_AssmtData_`year'", replace


}
