*******************************************************
* NEW MEXICO

* File name: 09_New Mexico 2024 Cleaning
* Last update: 2/20/2025

*******************************************************
* Description: This file cleans all New Mexico Original Data for 2024.

*******************************************************

clear
set more off

//Combine ela/math and sci
use "$raw/NM_AssmtData_2024_elamath_DataRequest", clear
append using "$raw/NM_AssmtData_2024_sci_DataRequest"

//Rename Variables
rename SchoolYear SchYear
rename Level DataLevel
rename Test AssmtName
rename DistrictID StateAssignedDistID
rename DistrictName DistName
rename SchoolID StateAssignedSchID
rename SchoolName SchName
rename Grade GradeLevel
rename Subgroup StudentSubGroup
rename Subtest Subject
rename TotalCount StudentSubGroup_TotalTested
rename ProficientCount ProficientOrAbove_count
rename ProficiencyRate ProficientOrAbove_percent

//SchYear
replace SchYear = "2023-24"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel

tostring StateAssigned*, replace
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel !=3

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3

//GradeLevel
replace GradeLevel = "38" if GradeLevel == "All Grades 3-8"
replace GradeLevel = "G" + string(real(GradeLevel), "%02.0f")

//StudentSubGroup
replace StudentSubGroup = proper(StudentSubGroup)
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "El"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Frl"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multirace"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Notel"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Notfrl"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Swd"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Notswd"
drop if StudentSubGroup == "Directcert" | StudentSubGroup == "Notdirectcert"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//Subject
replace Subject = "ela" if Subject == "LA"
replace Subject = "math" if Subject == "MATH"
replace Subject = "sci" if Subject == "SCIENCE"

//ProficientOrAbove_percent
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "0.",".",.)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "≤ ", "0-",.)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "≥ ", "",.) + "-1" if strpos(ProficientOrAbove_percent, "≥")
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "^"

//ProficientOrAbove_count
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "^"

//Converting percent range to count range
replace ProficientOrAbove_count = string(round(real(substr(ProficientOrAbove_percent,1, strpos(ProficientOrAbove_percent, "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(ProficientOrAbove_percent, strpos(ProficientOrAbove_percent, "-") +1,.))* real(StudentSubGroup_TotalTested))) if !missing(real(substr(ProficientOrAbove_percent,1, strpos(ProficientOrAbove_percent, "-")-1))) & !missing(real(substr(ProficientOrAbove_percent, strpos(ProficientOrAbove_percent, "-") +1,.))) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(ProficientOrAbove_count)) & strpos(ProficientOrAbove_percent, "-")


//NCES Merging (Using NCES 2022 for now)
replace StateAssignedDistID = string(real(StateAssignedDistID), "%03.0f") if DataLevel !=1

replace StateAssignedSchID = substr(StateAssignedSchID, -3,3)
replace StateAssignedSchID = string(real(StateAssignedSchID), "%03.0f") if DataLevel == 3

gen State_leaid = "NM-" + StateAssignedDistID if DataLevel !=1
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == 3

merge m:1 State_leaid using "$NCES/NCES_2022_District", gen(DistMerge)
drop if DistMerge == 2
merge m:1 seasch using "$NCES/NCES_2022_School", gen(SchMerge)
drop if SchMerge == 2

drop if SchName == "LAKE ARTHUR SECONDARY ONLINE ACADEMY" //All suppressed and not in NCES

** One new charter school for 2024 (one district level obs and one sch level obs)
merge m:1 DistName SchName using "$NM/NM_2024_Unmerged", update nogen

//Indicator Variables
replace State = "New Mexico"
replace StateFips = 35
replace StateAbbrev = "NM"

replace AssmtName = "NM-" + AssmtName

gen AssmtType = "Regular" //Setting as regular for now given that the file included a "Test" variable that specifies either the MSSA or ASR. Previous files did not do this.

gen ProficiencyCriteria = "Levels 3-4"

** Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

//Missing Vars
forvalues n = 1/4 {
	gen Lev`n'_percent = "--"
	gen Lev`n'_count = "--"
}
gen Lev5_percent = ""
gen Lev5_count = ""

gen ParticipationRate = "--"
gen AvgScaleScore = "--"

//StudentGroup_TotalTested
cap drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Deriving StudentSubGroup_TotalTested where possible
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName GradeLevel Subject)
gen missing_SSG = 1 if missing(real(StudentSubGroup_TotalTested))
egen missing_multiple = total(missing_SSG), by(StudentGroup DistName SchName GradeLevel Subject)

order StudentGroup_TotalTested UnsuppressedSG StudentSubGroup_TotalTested UnsuppressedSSG missing_multiple

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0 & !missing(real(StudentGroup_TotalTested)-UnsuppressedSG) & StudentSubGroup != "All Students"

drop Unsuppressed* missing_*

//Standardizing Names
replace CountyName = "Dona Ana County" if CountyCode == "35013"
replace DistName = stritrim(DistName)
replace SchName = stritrim(SchName)

//Misc Changes in reponse to self review
replace SchVirtual = "No" if NCESSchoolID == "350280330026"
replace StudentSubGroup_TotalTested = StudentGroup_TotalTested if real(StudentSubGroup_TotalTested) > real(StudentGroup_TotalTested) & !missing(real(StudentSubGroup_TotalTested)) & !missing(real(StudentGroup_TotalTested))
** For above: A couple districts/schools had Econ Disadvantaged ssg_tt as 1 higher than sg_tt. Manually changing ssg_tt to sg_tt, but retaining same ProficientOrAbove_count and percents.

** Response to R1 3.2.25
replace StateAssignedSchID = StateAssignedDistID + StateAssignedSchID if DataLevel == 3


//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/NM_AssmtData_2024", replace
export delimited "${output}/NM_AssmtData_2024", replace

*End of 09_New Mexico 2024 Cleaning




