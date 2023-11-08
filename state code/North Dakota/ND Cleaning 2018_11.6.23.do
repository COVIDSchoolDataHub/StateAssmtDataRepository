clear all
set more off

cd "/Users/miramehta/Documents/"
global data "/Users/miramehta/Documents/ND State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

//Import Data & Merge in Participation Data
import excel "$data/ND_ParticipationData_2018.xlsx", clear firstrow
duplicates drop
save "$data/ND_ParticipationData_2018.dta", replace

import excel "$data/ND_OriginalData_2018_all.xlsx", clear firstrow
duplicates drop
merge 1:1 InstitutionName InstitutionID Grade Subject AssessmentType Accomodations Subgroup using "$data/ND_ParticipationData_2018.dta"
drop if _merge == 2

tostring PercentTestedRangeLow, replace force
tostring PercentTestedRangeHigh, replace force

gen ParticipationRate = PercentTestedRangeLow + "-" + PercentTestedRangeHigh
replace ParticipationRate = PercentTestedRangeLow if PercentTestedRangeLow == PercentTestedRangeHigh
replace ParticipationRate = "--" if _merge == 1

drop _merge PercentTestedRangeLow PercentTestedRangeHigh

//Rename Variables
rename AcademicYear SchYear
rename InstitutionName SchName
rename InstitutionID StateAssignedSchID
rename Grade GradeLevel
rename AssessmentType AssmtType
rename Subgroup StudentSubGroup

//Filter for Only Desired Data
drop if AssmtType != "Reg"
replace AssmtType = "Regular"
drop Accomodations
drop if GradeLevel == "10" | GradeLevel == "11" | GradeLevel == "High School" | GradeLevel == "All Grades"
replace GradeLevel = "G0" + GradeLevel
replace GradeLevel = "G38" if GradeLevel == "G0Elementary/Middle School"

//Data Levels
gen DataLevel = "School"
replace DataLevel = "District" if strlen(StateAssignedSchID) == 5
gen DistName = ""
replace DistName = SchName if DataLevel == "District"
replace SchName = "All Schools" if DataLevel == "District"
gen StateAssignedDistID = ""
replace StateAssignedDistID = StateAssignedSchID if DataLevel == "District"
replace StateAssignedDistID = substr(StateAssignedSchID, 1, 5) if DataLevel == "School"
replace StateAssignedSchID = "" if DataLevel == "District"
replace DataLevel = "State" if DistName == "State of North Dakota"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

//Subject
replace Subject = "ela" if Subject == "Reading"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

//Student Groups & SubGroups
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian American"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Learner"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Low Income"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Low Income"
drop if StudentSubGroup == "All Others"
drop if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
drop if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
drop if StudentSubGroup == "IEP (student with disabilities)" | StudentSubGroup == "Non-IEP"
drop if StudentSubGroup == "IEP - Emotional Disturbance" | StudentSubGroup == "Non-IEP - Emotional Disturbance"
drop if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
drop if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"
drop if StudentSubGroup == "Mobile Student" | StudentSubGroup == "Non-Mobile Student"
drop if StudentSubGroup == "Non-Former English Learner"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Gender" if StudentSubGroup == "Female" | StudentSubGroup == "Male"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"

//Proficiency Percents
gen ProfLow = ProficientRangeLow + AdvancedRangeLow
gen ProfHigh = ProficientRangeHigh + AdvancedRangeHigh
replace ProfHigh = 1 if ProfHigh > 1

tostring NoviceRangeLow, replace
tostring NoviceRangeHigh, replace
tostring PartiallyRangeLow, replace
tostring PartiallyRangeHigh, replace
tostring ProficientRangeLow, replace
tostring ProficientRangeHigh, replace
tostring AdvancedRangeLow, replace
tostring AdvancedRangeHigh, replace
tostring ProfLow, replace format("%6.0g") force
tostring ProfHigh, replace format("%6.0g") force

gen Lev1_percent = NoviceRangeLow + "-" + NoviceRangeHigh
replace Lev1_percent = NoviceRangeLow if NoviceRangeLow == NoviceRangeHigh
gen Lev2_percent = PartiallyRangeLow + "-" + PartiallyRangeHigh
replace Lev2_percent = PartiallyRangeLow if PartiallyRangeLow == PartiallyRangeHigh
gen Lev3_percent = ProficientRangeLow + "-" + ProficientRangeHigh
replace Lev3_percent = ProficientRangeLow if ProficientRangeLow == ProficientRangeHigh
gen Lev4_percent = AdvancedRangeLow + "-" + AdvancedRangeHigh
replace Lev4_percent = AdvancedRangeLow if AdvancedRangeLow == AdvancedRangeHigh
gen ProficientOrAbove_percent = ProfLow + "-" + ProfHigh
replace ProficientOrAbove_percent = ProfLow if ProfLow == ProfHigh

drop NoviceRangeLow NoviceRangeHigh PartiallyRangeLow PartiallyRangeHigh ProficientRangeLow ProficientRangeHigh AdvancedRangeLow AdvancedRangeHigh ProfLow ProfHigh

//Fix Formatting & Generate Additional Variables
replace SchYear = "2017-18"
gen AssmtName = "North Dakota State Assessment (NDSA)"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficientOrAbove_count = "--"
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3-4"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

save "$data/ND_AssmtData_2018.dta", replace

//Clean NCES Data
use "$NCES/NCES School Files, Fall 1997-Fall 2021/NCES_2017_School.dta", clear
drop if state_location != "ND"
gen StateAssignedDistID = substr(state_leaid, 4, 8)
gen StateAssignedSchID = substr(seasch, 1, 5) + substr(seasch, 7, 11)
save "$NCES/Cleaned NCES Data/NCES_2018_School_ND.dta", replace

use "$NCES/NCES District Files, Fall 1997-Fall 2021/NCES_2017_District.dta", clear
drop if state_location!= "ND"
gen StateAssignedDistID = substr(state_leaid, 4, 8)
save "$NCES/Cleaned NCES Data/NCES_2018_District_ND.dta", replace

//Merge Data
use "$data/ND_AssmtData_2018.dta", clear
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2018_District_ND.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2018_School_ND.dta", gen (merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchType
rename state_leaid State_leaid

gen State = "North Dakota"
replace StateAbbrev = "ND"
replace StateFips = 38
replace DistName = lea_name if DataLevel == "School"

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch lea_name agency_charter_indicator dist_agency_charter_indicator

//Unmerged Schools
replace NCESDistrictID = "3820340" if StateAssignedDistID == "27014"
replace State_leaid = "NE-27014" if StateAssignedDistID == "27014"
replace DistType = 1 if StateAssignedDistID == "27014"
replace DistCharter = "No" if StateAssignedDistID == "27014"
replace CountyName = "MCKENZIE COUNTY" if StateAssignedDistID == "27014"
replace CountyCode = 38053 if StateAssignedDistID == "27014"
replace NCESSchoolID = "382034000714" if SchName == "East Fairview Elementary School"
replace seasch = "27014-27411" if SchName == "East Fairview Elementary School"
replace SchType = 1 if SchName == "East Fairview Elementary School"
replace SchLevel = 1 if SchName == "East Fairview Elementary School"
replace SchVirtual = 0 if SchName == "East Fairview Elementary School"
replace DistName = "Yellowstone 14" if SchName == "East Fairview Elementary School"

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistType "District type as defined by NCES"
label var DistCharter "Charter indicator"
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
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only"
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

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType  Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$data/ND_AssmtData_2018.dta", replace
export delimited "$data/ND_AssmtData_2018.csv", replace
clear
