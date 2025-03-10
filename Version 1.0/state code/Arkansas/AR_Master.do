clear
set more off
cd "/Volumes/T7/State Test Project/Arkansas"
local dofiles AR_Cleaning_2009_2014 AR_Cleaning_2015 AR_Cleaning_2016_2022
local Original "/Volumes/T7/State Test Project/Arkansas/Original Data"
local Output "/Volumes/T7/State Test Project/Arkansas/Output"

foreach file of local dofiles {
	do `file'
}

clear
//Adding State SG Data for 2019-2022
foreach year in 2019 2021 2022 {
local prevyear =`=`year'-1'
import excel "`Original'/AR_OriginalData_`year'_State_sg", firstrow allstring sheet(Demographics)

	
//Reshaping from wide to long for StudentSubGroup 
rename Female StudentSubGroupF
rename Male StudentSubGroupM
rename AmericanIndianAlaskaNative StudentSubGroupAIAN
rename Asian StudentSubGroupAs
rename BlackAfricanAmerican StudentSubGroupBAA
rename HispanicorLatino StudentSubGroupHL
rename NativeHawaiianOtherPacificI StudentSubGroupNHPI
rename White StudentSubGroupW
rename EconomicallyDisadvantaged StudentSubGroupED
rename ELL StudentSubGroupELL
drop NotCategorized Gifted IEP Migrant Section504 OtherAccomsPlan Homeless ParentinMilitary InFosterCare
reshape long StudentSubGroup, i(GradeLevel SubjectArea ReadinessLevel) j(StudentSubGroup1, string)
cap drop X
//reshaping from long to wide for Performance Level
reshape wide StudentSubGroup, i(StudentSubGroup1 SubjectArea GradeLevel) j(ReadinessLevel, string)

//Renaming
rename StudentSubGroupE Lev4_percent
rename StudentSubGroupR Lev3_percent
rename StudentSubGroupC Lev2_percent
rename StudentSubGroupN Lev1_percent
rename SubjectArea Subject
rename StudentSubGroup1 StudentSubGroup


gen DataLevel = "State"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel

//StudentSubGroup
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "AIAN"
replace StudentSubGroup = "Asian" if StudentSubGroup == "As"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "BAA"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ED"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ELL"
replace StudentSubGroup = "Female" if StudentSubGroup == "F"
replace StudentSubGroup = "Male" if StudentSubGroup == "M"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "HL"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "NHPI"
replace StudentSubGroup = "White" if StudentSubGroup == "W"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Unknown"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino"

//Subject
replace Subject = "math" if substr(Subject, 1,1) == "m"
replace Subject = "eng" if substr(Subject,1,1) == "e"
replace Subject = "read" if substr(Subject,1,1) == "r"
replace Subject = "sci" if substr(Subject,1,1) == "s"

//GradeLevel
replace GradeLevel = "G0" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//Proficiency Levels and ProficientOrAbove_percent
foreach n in 1 2 3 4 {
	destring Lev`n'_percent, gen(nLev`n'_percent)
	replace Lev`n'_percent = string(nLev`n'_percent, "%9.3g")
}
gen ProficientOrAbove_percent = string(nLev3_percent + nLev4_percent, "%9.3g")


//Generating additional variables
gen State = "Arkansas"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
gen Flag_CutScoreChange_read = "N"
gen ProficiencyCriteria = "Levels 3 and 4"
gen AssmtType = "Regular"
gen AssmtName = "ACT Aspire"
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)
gen StateFips = 5
gen StateAbbrev = "AR"
gen DistName = "All Districts"
gen SchName = "All Schools"

//Missing Variables
foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
}
gen ProficientOrAbove_count = "--"
gen ParticipationRate = "--"
gen AvgScaleScore = "--"
gen StudentSubGroup_TotalTested = "--"
gen StudentGroup_TotalTested = "--"


//Appending and Final Cleaning
append using "`Output'/AR_AssmtData_`year'"
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/AR_AssmtData_`year'", replace
export delimited "`Output'/AR_AssmtData_`year'", replace
clear

}

