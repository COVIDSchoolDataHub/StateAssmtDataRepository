clear
set more off

global output "/Users/maggie/Desktop/Washington/Output"
global NCES "/Users/maggie/Desktop/Washington/NCES/Cleaned"

cd "/Users/maggie/Desktop/Washington"

use "${output}/WA_AssmtData_2022_all.dta", clear

** Dropping extra variables

drop ESDName ESDOrganizationId CurrentSchoolType CountofStudentsExpectedtoTest PercentMetTestedOnly DataAsOf

** Rename existing variables

rename SchoolYear SchYear
rename OrganizationLevel DataLevel
rename County CountyName
rename DistrictCode State_leaid
rename DistrictName DistName
rename DistrictOrganizationId StateAssignedDistID
rename SchoolCode seasch
rename SchoolName SchName
rename SchoolOrganizationId StateAssignedSchID
rename StudentGroup StudentSubGroup
rename StudentGroupType StudentGroup
rename TestAdministration AssmtName
rename TestSubject Subject
rename Countofstudentsexpectedtotestinc StudentSubGroup_TotalTested
rename CountMetStandard ProficientOrAbove_count
rename PercentMetStandard ProficientOrAbove_percent
rename PercentLevel1 Lev1_percent
rename PercentLevel2 Lev2_percent
rename PercentLevel3 Lev3_percent
rename PercentLevel4 Lev4_percent

** Dropping entries

keep if AssmtName == "SBAC" | AssmtName == "WCAS"
drop if DataLevel == "ESD"
drop if (strpos(GradeLevel, "All") | strpos(GradeLevel, "11") | strpos(GradeLevel, "10")) > 0
drop if StudentGroup == "Foster" | StudentGroup == "homeless" | StudentGroup == "Migrant" | StudentGroup == "Military" | StudentGroup == "SWD" | StudentGroup == "s504"
drop if SchName == "Chief Leschi Schools" | SchName == "Paschal Sherman" | SchName == "Wa He Lut Indian School" | SchName == "Lummi Nation School" | SchName == "Quileute Tribal School" | SchName == "Muckleshoot Tribal School"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Replacing variables

replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3

replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1
replace CountyName = "" if DataLevel == 1

replace Subject = "ela" if Subject == "ELA" 
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

replace GradeLevel = "G" + GradeLevel

replace StudentGroup = "All Students" if StudentGroup == "All"
replace StudentGroup = "EL Status" if StudentGroup == "ELL"
replace StudentGroup = "Economic Status" if StudentGroup == "FRL"
replace StudentGroup = "RaceEth" if StudentGroup == "Race"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/ Alaskan Native"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black/ African American"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learners"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Gender X"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/ Latino of any race(s)"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Low-Income"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian/ Other Pacific Islander"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Language Learners"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Low Income"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "TwoorMoreRaces"

** Generating new variables

gen AssmtType = "Regular"

destring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested = -100000 if StudentSubGroup_TotalTested == .
bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)
replace StudentGroup_TotalTested = . if StudentGroup_TotalTested < 0

local level 1 2 3 4

foreach a of local level {
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen AvgScaleScore = "--"

gen ProficiencyCriteria = "Levels 3-4"

destring PercentNoScore, replace force
gen ParticipationRate = 1 - PercentNoScore
tostring ParticipationRate, replace force
replace ParticipationRate = "*" if Suppression != "None" & PercentNoScore == .
drop PercentNoScore

** Converting Data to String

foreach a of local level {
	replace Lev`a'_percent = "*" if Suppression != "None" & Lev`a'_percent == "NULL"
}

replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent,"%","",.)
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "*" if Suppression != "None" & ProficientOrAbove_percent == "."

replace ProficientOrAbove_count = "*" if Suppression != "None"

tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested = "*" if Suppression != "None"

drop Suppression

** Merging with NCES

gen leadingzero = 1 if State_leaid < 10000
tostring State_leaid, replace
replace State_leaid = "0" + State_leaid if leadingzero == 1
drop leadingzero
replace State_leaid = "WA-" + State_leaid if DataLevel != 1

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta"

drop if _merge == 2
drop _merge

tostring seasch, replace
replace seasch = State_leaid + "-" + seasch if DataLevel == 3
replace seasch = subinstr(seasch,"WA-","",.) if DataLevel == 3

merge m:1 seasch using "${NCES}/NCES_2021_School.dta"

drop if _merge == 2
drop _merge

replace StateAbbrev = "WA" if DataLevel == 1
replace State = 53 if DataLevel == 1
replace StateFips = 53 if DataLevel == 1
replace State_leaid = "" if DataLevel == 1
replace seasch = "" if DataLevel != 3

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/WA_AssmtData_2022.dta", replace

export delimited using "${output}/csv/WA_AssmtData_2022.csv", replace
