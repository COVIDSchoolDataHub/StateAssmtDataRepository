cap log close
set trace on

cd "/Users/name/Desktop/Alaska"
log using alaska_cleaning.log, replace

global Original "/Volumes/T7/State Test Project/Alaska/Original"
global Output "/Volumes/T7/State Test Project/Alaska/Output"
global Temp "/Volumes/T7/State Test Project/Alaska/Temp"
global NCES "/Volumes/T7/State Test Project/Alaska/NCES"

/*
//New Importing Code
import delimited "$Original/AK_OriginalData_2015_2022", varnames(nonames) clear 
save "$Original/alaska_updated_original", replace
clear
*/


use "$Original/alaska_updated_original", clear


// rename vars
rename v1 DataLevel
rename v2 SchYear
rename v3 AssmtName
rename v4 StateAssignedDistID
rename v5 DistName
rename v6 SchName
rename v7 Subject
rename v8 GradeLevel
rename v9 StudentGroup
rename v10 StudentSubGroup
rename v11 ProficientOrAbove_count
rename v12 ProficientOrAbove_percent
drop v13 
drop v14 
rename v15 Enrollment // originally enrollment
rename v16 ParticipationRate

// drops first line
drop if DataLevel == "datalevel"

// encodes datalevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


gen AssmtType = "Regular"

gen Subject2 = lower(Subject)
drop Subject 
rename Subject2 Subject

replace Subject = "sci" if Subject == "science"

// Generate Empty Variables

/*
gen Lev1_count = . 
gen Lev1_percent = .
gen Lev2_count = .
gen Lev2_percent = .
gen Lev3_count = .
gen Lev3_percent = .
gen Lev4_count = .
gen Lev4_percent = .
gen Lev5_count = .
gen Lev5_percent = .
*/

forvalues n = 1/4 {
	gen Lev`n'_count = "--"
	gen Lev`n'_percent = "--"
}
gen Lev5_count = ""
gen Lev5_percent = ""
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3-4"

tab StudentSubGroup

// Student Group Correct Labels // AD
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English Leaner Status"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"


// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Alaska Native/American Indian"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
// replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == ""
replace StudentSubGroup = "White" if StudentSubGroup == "Caucasian"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"



// Ethnicity Group 
//replace StudentSubGroup = "" if StudentSubGroup == ""
// replace StudentSubGroup = "" if StudentSubGroup == ""

// El Status Group 

replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non English Learners"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Economically Disadvantaged"


// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// Disability Group
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students With Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students Without Disabilities"

//NEW ADDED


tab GradeLevel
// GradeLevel Changes
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == "3"
replace GradeLevel2 = "G04" if GradeLevel == "4"
replace GradeLevel2 = "G05" if GradeLevel == "5"
replace GradeLevel2 = "G06" if GradeLevel == "6"
replace GradeLevel2 = "G07" if GradeLevel == "7"
replace GradeLevel2 = "G08" if GradeLevel == "8"
replace GradeLevel2 = "G38" if GradeLevel == "All Grades"

drop GradeLevel
rename GradeLevel2 GradeLevel


destring Enrollment, replace 
destring ParticipationRate, replace percent

gen double ParticipationRate1 = ParticipationRate/100
drop ParticipationRate

// Accurate StudentGroup_Total_Tested using Part Rate and Enrollment
gen double StudentGroup_TotalTested_New = . 
replace StudentGroup_TotalTested_New = Enrollment * ParticipationRate1
drop Enrollment
rename StudentGroup_TotalTested_New StudentGroup_TotalTested

// rounds student group number to nearest whole number of students
replace StudentGroup_TotalTested = round(StudentGroup_TotalTested,1)

replace SchYear = "2017" if SchYear == "2016-2017"
replace SchYear = "2018" if SchYear == "2017-2018"
replace SchYear = "2019" if SchYear == "2018-2019"
replace SchYear = "2021" if SchYear == "2020-2021"
replace SchYear = "2022" if SchYear == "2021-2022"

// create StateAssignedSchID

gen districtID = substr(StateAssignedDistID, 1, length(StateAssignedDistID) - 4)
gen schoolID = StateAssignedDistID if DataLevel == 3

replace districtID = StateAssignedDistID if DataLevel == 2

replace districtID = "0" + districtID if length(districtID) == 1 
replace schoolID = "0" + schoolID if length(schoolID) == 5

drop StateAssignedDistID
rename districtID StateAssignedDistID
rename schoolID StateAssignedSchID

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// bring part rate back to string
tostring ParticipationRate1, replace force
rename ParticipationRate1 ParticipationRate
replace ParticipationRate = "-" if ParticipationRate == "."


// the following creates ranges for supressed values of ProficientOrAbove_percent such as 40% or fewer in 0-0.4. 
gen or_lower = ""
replace or_lower = ProficientOrAbove_percent if strpos(ProficientOrAbove_percent, "% or fewer") > 0
replace or_lower = subinstr(or_lower, "% or fewer", "", .)
recast str2 or_lower
destring or_lower, replace 
gen double or_lower2 = or_lower/100 
drop or_lower
rename or_lower2 or_lower

tostring or_lower, replace force 
replace or_lower = "0 - " + or_lower
replace or_lower = "" if or_lower == "0 - ."

//drop or_higher
gen or_higher = ""
replace or_higher = ProficientOrAbove_percent if strpos(ProficientOrAbove_percent, "% or more") > 0
replace or_higher = subinstr(or_higher, "% or more", "", .)
destring or_higher, replace 

gen double or_higher2 = or_higher/100 
drop or_higher
rename or_higher2 or_higher


tostring or_higher, replace force 
replace or_higher = or_higher + " - 1"
replace or_higher = "" if or_higher == ". - 1"


destring ProficientOrAbove_percent, force replace
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, force replace
replace ProficientOrAbove_percent = or_lower if or_lower != ""
replace ProficientOrAbove_percent = or_higher if or_higher != ""
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

save "$Temp/alaska_cleaned_updated", replace


global years1 2017 2018 2019 2021 2022

foreach a in $years1 {

local prevyear = `a' - 1
	
use "$Temp/alaska_cleaned_updated", clear

keep if SchYear == "`a'"


rename StateAssignedDistID State_leaid

// District NCES Merge
merge m:1 State_leaid using "$NCES/NCES_`prevyear'_District_Alaska" // 
rename _merge DistMerge
drop if DistMerge == 2

rename State_leaid StateAssignedDistID
drop DistMerge
rename State_leaid_og State_leaid

// School NCES merge	
rename StateAssignedSchID seasch
merge m:1 seasch using "$NCES/NCES_`prevyear'_School_Alaska" //  
rename _merge SchoolMerge
drop if SchoolMerge == 2

rename seasch StateAssignedSchID
rename seasch_og seasch

drop SchoolMerge

drop State
drop StateAbbrev
drop StateFips
gen State = "Alaska"
gen StateAbbrev = "AK"
gen StateFips = 2 // CHANGED


if `a' == 2017 {
// year specific 2017 
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "Y"

}

if `a' == 2018 {
// year specific 2018
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"
}

if `a' == 2019 {
// year specific 2019
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"
}

if `a' == 2021 {
// year specific 2021
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "Not applicable"
}

if `a' == 2022 {
// year specific 2022 
gen Flag_AssmtNameChange = "Y" 
replace Flag_AssmtNameChange = "N" if Subject == "sci"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "Y"

}
//SchYear Correct Format
replace SchYear = "`prevyear'-" + substr("`a'",-2,2)

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
drop StudentGroup_TotalTested
///Gen StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested_New = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested_New = StudentGroup_TotalTested_New[_n-1] if missing(StudentGroup_TotalTested_New)
drop group_id StateAssignedDistID1 StateAssignedSchID1
rename StudentGroup_TotalTested_New StudentGroup_TotalTested

// rounds student group number to nearest whole number of students
replace StudentGroup_TotalTested = round(StudentGroup_TotalTested,1)

tostring StudentGroup_TotalTested StudentSubGroup_TotalTested, replace 

//Post Launch Updates 4/27/24
replace StudentGroup_TotalTested = "0" if StudentGroup_TotalTested == "."
replace StudentGroup_TotalTested = "0" if StudentGroup_TotalTested == "."
replace StudentSubGroup_TotalTested = "0" if StudentSubGroup_TotalTested == "."
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "N/A"
foreach var of varlist *_percent {
	replace `var' = subinstr(`var', " ", "",.)
}

//Post Launch Response to Review
if `a' == 2019 replace SchVirtual = 0 if NCESSchoolID == "020051000450"
replace ProficientOrAbove_count = string(round(real(StudentSubGroup_TotalTested) * real(substr(ProficientOrAbove_percent,1,strpos(ProficientOrAbove_percent,"-")-1)))) + "-" + string(round(real(StudentSubGroup_TotalTested) * real(substr(ProficientOrAbove_percent,strpos(ProficientOrAbove_percent,"-")+1,3)))) if regexm(ProficientOrAbove_percent, "[0-9]") !=0 & ProficientOrAbove_count == "*"
replace ParticipationRate = "--" if strpos(ParticipationRate, "-") !=0

foreach var of varlist *_percent *_count {
replace `var' = "0" if `var' == "0-0"
}

drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"


order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Output/AK_AssmtData_`a'_Stata", replace
export delimited "$Output/AK_AssmtData_`a'.csv", replace

