clear
set more off

global output "/Users/maggie/Desktop/Washington/Output"
global NCES "/Users/maggie/Desktop/Washington/NCES/Cleaned"

cd "/Users/maggie/Desktop/Washington"

use "${output}/WA_AssmtData_2023_all.dta", clear

** Dropping extra variables

drop ESDName ESDOrganizationId CurrentSchoolType PercentMetTestedOnly PercentNoScore DataAsOf

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
rename CountofStudentsExpectedtoTestinc StudentSubGroup_TotalTested
rename CountMetStandard ProficientOrAbove_count
rename PercentMetStandard ProficientOrAbove_percent
rename PercentLevel1 Lev1_percent
rename PercentLevel2 Lev2_percent
rename PercentLevel3 Lev3_percent
rename PercentLevel4 Lev4_percent
rename PercentParticipation ParticipationRate
rename CountofStudentsExpectedtoTest testreplacement

** Dropping entries

keep if AssmtName == "SBAC" | AssmtName == "WCAS"
drop if DataLevel == "ESD"
drop if (strpos(GradeLevel, "All") | strpos(GradeLevel, "11") | strpos(GradeLevel, "10")) > 0
drop if StudentGroup == "Foster" | StudentGroup == "homeless" | StudentGroup == "Migrant" | StudentGroup == "Military" | StudentGroup == "SWD" | StudentGroup == "s504"
drop if SchName == "Chief Leschi Schools" | SchName == "Paschal Sherman(Closed)" | SchName == "Wa He Lut Indian School" | SchName == "Lummi Nation School" | SchName == "Quileute Tribal School" | SchName == "Muckleshoot Tribal School"

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

local level 1 2 3 4

foreach a of local level {
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen AvgScaleScore = "--"

gen ProficiencyCriteria = "Levels 3-4"

replace ParticipationRate = "*" if DAT != "None" & ParticipationRate == "NULL"

** Converting Data to String

foreach a of local level {
	replace Lev`a'_percent = "*" if DAT != "None" & Lev`a'_percent == "NULL"
}

replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent,"%","",.)
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "*" if DAT != "None" & ProficientOrAbove_percent == "."

replace ProficientOrAbove_count = "*" if DAT != "None"

tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested = "*" if DAT != "None"

drop DAT

** Review 2 Update

destring Lev3_percent, gen(Lev3_percent2) force
destring Lev4_percent, gen(Lev4_percent2) force
destring ProficientOrAbove_percent, gen(ProficientOrAbove_percent2) force
destring testreplacement, replace force

gen sum = Lev3_percent2 + Lev4_percent2
gen diff = sum - ProficientOrAbove_percent2

replace ProficientOrAbove_percent2 = Lev3_percent2 + Lev4_percent2
gen ProficientOrAbove_count2 = round(testreplacement * ProficientOrAbove_percent2)

tostring ProficientOrAbove_count2, replace force
replace ProficientOrAbove_count = ProficientOrAbove_count2 if (diff > 0.01 | diff < -0.01) & diff != . & ProficientOrAbove_count2 != "."

tostring ProficientOrAbove_percent2, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent2 if (diff > 0.01 | diff < -0.01) & diff != . & ProficientOrAbove_percent2 != "."

tostring testreplacement, replace force
replace StudentSubGroup_TotalTested = testreplacement if (diff > 0.01 | diff < -0.01) & diff != . & testreplacement != "."

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = -100000 if StudentSubGroup_TotalTested2 == .
bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2)
replace StudentGroup_TotalTested = . if StudentGroup_TotalTested < 0

tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

drop *percent2 testreplacement ProficientOrAbove_count2 sum diff StudentSubGroup_TotalTested2

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

**** Update 2023 schools

replace SchType = 1 if SchName == "Bellevue Digital Discovery"
replace NCESSchoolID = "530039003883" if SchName == "Bellevue Digital Discovery"

replace SchType = 1 if SchName == "Desert Sky Elementary"
replace NCESSchoolID = "530732003901" if SchName == "Desert Sky Elementary"

replace SchType = 1 if SchName == "Eagle Virtual Sky Academy"
replace NCESSchoolID = "530249003884" if SchName == "Eagle Virtual Sky Academy"

replace SchType = 1 if SchName == "Ida Nason Aronica Elementary"
replace NCESSchoolID = "530246003887" if SchName == "Ida Nason Aronica Elementary"

replace SchType = 4 if SchName == "Kent Virtual Academy"
replace NCESSchoolID = "530396003898" if SchName == "Kent Virtual Academy"

replace SchType = 1 if SchName == "Kiona-Benton City Elementary"
replace NCESSchoolID = "530402003888" if SchName == "Kiona-Benton City Elementary"

replace SchType = 1 if SchName == "Tacoma Online Elementary School"
replace NCESSchoolID = "530870003889" if SchName == "Tacoma Online Elementary School"

replace SchType = 1 if SchName == "Tacoma Online Middle School"
replace NCESSchoolID = "530870003890" if SchName == "Tacoma Online Middle School"

replace SchType = 2 if SchName == "Vancouver Intensive Communications Center"
replace NCESSchoolID = "530927003885" if SchName == "Vancouver Intensive Communications Center"

replace SchType = 4 if SchName == "Vancouver Success Academy"
replace NCESSchoolID = "530927003882" if SchName == "Vancouver Success Academy"

replace SchType = 1 if SchName == "Wapato Online Academy 6-8"
replace NCESSchoolID = "530948003893" if SchName == "Wapato Online Academy 6-8"

replace SchType = 1 if SchName == "Willow Crest Elementary"
replace NCESSchoolID = "530030003886" if SchName == "Willow Crest Elementary"

replace SchLevel = -1 if SchName == "Bellevue Digital Discovery" | SchName == "Desert Sky Elementary" | SchName == "Eagle Virtual Sky Academy" | SchName == "Ida Nason Aronica Elementary" | SchName == "Kent Virtual Academy" | SchName == "Kiona-Benton City Elementary" | SchName == "Tacoma Online Elementary School" | SchName == "Tacoma Online Middle School" | SchName == "Vancouver Intensive Communications Center" | SchName == "Vancouver Success Academy" | SchName == "Wapato Online Academy 6-8" | SchName == "Willow Crest Elementary"
replace SchVirtual = -1 if SchName == "Bellevue Digital Discovery" | SchName == "Desert Sky Elementary" | SchName == "Eagle Virtual Sky Academy" | SchName == "Ida Nason Aronica Elementary" | SchName == "Kent Virtual Academy" | SchName == "Kiona-Benton City Elementary" | SchName == "Tacoma Online Elementary School" | SchName == "Tacoma Online Middle School" | SchName == "Vancouver Intensive Communications Center" | SchName == "Vancouver Success Academy" | SchName == "Wapato Online Academy 6-8" | SchName == "Willow Crest Elementary"
label def SchLevel -1 "Missing/not reported"
label def SchVirtual -1 "Missing/not reported"

**

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

save "${output}/WA_AssmtData_2023.dta", replace

export delimited using "${output}/csv/WA_AssmtData_2023.csv", replace
