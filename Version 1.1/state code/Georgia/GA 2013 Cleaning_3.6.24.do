clear all

cd "/Users/miramehta/Documents/"
global GAdata "/Users/miramehta/Documents/GA State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

//2012-2013
import delimited "$GAdata/GA_OriginalData_2013_G38_all.csv", clear
gen acdmc_lvl = "G38"
save "$GAdata/GA_OriginalData_2013_G38_all.dta", replace

import delimited "$GAdata/GA_OriginalData_2013_all.csv", clear
tostring acdmc_lvl, replace
append using "$GAdata/GA_OriginalData_2013_G38_all.dta"

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
rename num_tested_cnt StudentSubGroup_TotalTested
rename does_not_meet_cnt Lev1_count
rename does_not_meet_percent Lev1_percent
rename meets_cnt Lev2_count
rename meets_percent Lev2_percent
rename exceeds_cnt Lev3_count
rename exceeds_percent Lev3_percent

//Generate Other Variables
gen AssmtName = "Criterion-Referenced Competency Tests"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "State" if StateAssignedDistID == "ALL"
gen AvgScaleScore =.
gen Lev4_count = ""
gen Lev4_percent = ""
gen Lev5_count = ""
gen Lev5_percent = ""

//Groups & SubGroups
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without Disabilities"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

bys SchName DistName Subject GradeLevel StudentGroup: egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested)

//Passing Rates & Percentages
gen ProficiencyCriteria = "Levels 2-3"
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev2_count + Lev3_count
gen ProficientOrAbove_percent = Lev2_percent + Lev3_percent

replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
tostring ProficientOrAbove_count, replace
replace Lev1_count = "--" if Lev1_count == "."
replace Lev2_count = "--" if Lev2_count == "."
replace Lev3_count = "--" if Lev3_count == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Grade Levels
replace GradeLevel = "G0" + GradeLevel if GradeLevel != "G38"

//Subject Areas
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "read" if Subject == "Reading"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

//Statewide Data
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

save "$GAdata/GA_AssmtData_2013.dta", replace

//Clean NCES Data
import excel "/$NCES/NCES School Files, Fall 1997-Fall 2022/NCES_2012_School.xlsx", firstrow clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/Cleaned NCES Data/NCES_2013_School_GA.dta", replace

import excel "$NCES/NCES District Files, Fall 1997-Fall 2022/NCES_2012_District.xlsx", firstrow clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/Cleaned NCES Data/NCES_2013_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2013.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2013_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2013_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var DistType "District type as defined by NCES"
label var DistCharter "Charter indicator - district"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var SchYear "School year in which the data were reported"
label var AssmtName "Name of state assessment"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only"
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only"
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested"
label var StudentGroup "Student demographic group"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested"
label var StudentSubGroup "Student demographic subgroup"
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested"
label var Lev1_count "Count of students within subgroup performing at Level 1"
label var Lev1_percent "Percent of students within subgroup performing at Level 1"
label var Lev2_count "Count of students within subgroup performing at Level 2"
label var Lev2_percent "Percent of students within subgroup performing at Level 2"
label var Lev3_count "Count of students within subgroup performing at Level 3"
label var Lev3_percent "Percent of students within subgroup performing at Level 3"
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"
label var Lev5_count "Count of students within subgroup performing at Level 5"
label var Lev5_percent "Percent of students within subgroup performing at Level 5"
label var AvgScaleScore "Avg scale score within subgroup"
label var ProficiencyCriteria "Levels included in determining proficiency status"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment"
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment"
label var ParticipationRate "Participation rate"

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$GAdata/GA_AssmtData_2013", replace
export delimited "$GAdata/GA_AssmtData_2013", replace
clear
