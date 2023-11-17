clear all
set more off

cd "/Users/miramehta/Documents"
global data "/Users/miramehta/Documents/NE State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

//Import and Append Subject Files
import delimited "$data/NE_OriginalData_2019_ela.csv", clear
save "$data/NE_AssmtData_2019.dta", replace

import delimited "$data/NE_OriginalData_2019_mat.csv", clear
save "$data/NE_AssmtData_2019_math.dta", replace

import delimited "$data/NE_OriginalData_2019_sci.csv", clear
save "$data/NE_AssmtData_2019_sci.dta", replace

use "$data/NE_AssmtData_2019.dta", clear
append using "$data/NE_AssmtData_2019_math.dta" "$data/NE_AssmtData_2019_sci.dta"

//Rename & Generate Variables
rename schoolyear SchYear
rename type DataLevel
rename district StateAssignedDistID
rename school StateAssignedSchID
rename agencyname SchName
rename subject Subject
rename grade GradeLevel
rename category StudentGroup
rename studentsubgroup StudentSubGroup
rename averagescalescore AvgScaleScore
rename basicpct Lev1_percent
rename proficientpct Lev2_percent
rename advancedpct Lev3_percent
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = ""
gen Lev4_percent = ""
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficientOrAbove_count = "--"
gen StudentSubGroup_TotalTested = "--"
gen StudentGroup_TotalTested = "--"
gen DistName = ""
gen AssmtName = "Nebraska Student-Centered Assessment System (NSCAS)"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"
gen ProficiencyCriteria = "Levels 2-3"
gen ParticipationRate = 1 - nottestedpct
drop dataasof nottested nottestedpct

//School Year
drop if SchYear != "2018-2019"
replace SchYear = "2018-19"

//Data Levels
drop if DataLevel == "LC"
replace DataLevel = "State" if DataLevel == "ST"
replace DataLevel = "District" if StateAssignedSchID == 0 & DataLevel != "State"
replace DataLevel = "School" if DataLevel == "SC" & StateAssignedSchID != 0
replace DistName = SchName if DataLevel == "District"
replace DistName = "All Districts" if DataLevel == "State"
replace SchName = "All Schools" if DataLevel != "School"

local id "county StateAssignedDistID StateAssignedSchID"
foreach var of local id{
	tostring `var', replace
	gen `var'l = strlen(`var')
}

gen seasch = ""
replace seasch = "0" + county + "000" + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 1 & StateAssignedSchIDl == 1
replace seasch = county + "000" + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 1 & StateAssignedSchIDl == 1
replace seasch = "0" + county + "00" + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 2 & StateAssignedSchIDl == 1
replace seasch = county + "00" + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 2 & StateAssignedSchIDl == 1
replace seasch = "0" + county + "0" + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 3 & StateAssignedSchIDl == 1
replace seasch = county + "0" + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 3 & StateAssignedSchIDl == 1
replace seasch = "0" + county + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 4 & StateAssignedSchIDl == 1
replace seasch = county + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 4 & StateAssignedSchIDl == 1
replace seasch = "0" + county + "000" + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 1 & StateAssignedSchIDl == 2
replace seasch = county + "000" + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 1 & StateAssignedSchIDl == 2
replace seasch = "0" + county + "00" + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 2 & StateAssignedSchIDl == 2
replace seasch = county + "00" + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 2 & StateAssignedSchIDl == 2
replace seasch = "0" + county + "0" + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 3 & StateAssignedSchIDl == 2
replace seasch = county + "0" + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 3 & StateAssignedSchIDl == 2
replace seasch = "0" + county + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 4 & StateAssignedSchIDl == 2
replace seasch = county + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 4 & StateAssignedSchIDl == 2
replace seasch = "0" + county + "000" + StateAssignedDistID + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 1 & StateAssignedSchIDl == 3
replace seasch = county + "000" + StateAssignedDistID + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 1 & StateAssignedSchIDl == 3
replace seasch = "0" + county + "00" + StateAssignedDistID + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 2 & StateAssignedSchIDl == 3
replace seasch = county + "00" + StateAssignedDistID + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 2 & StateAssignedSchIDl == 3
replace seasch = "0" + county + "0" + StateAssignedDistID + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 3 & StateAssignedSchIDl == 3
replace seasch = county + "0" + StateAssignedDistID + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 3 & StateAssignedSchIDl == 3
replace seasch = "0" + county + StateAssignedDistID + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 4 & StateAssignedSchIDl == 3
replace seasch = county + StateAssignedDistID + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 4 & StateAssignedSchIDl == 3
replace seasch = "" if DataLevel != "School"

gen state_leaid = ""
replace state_leaid = "0" + county + "000" + StateAssignedDistID + "000" if countyl == 1 & StateAssignedDistIDl == 1
replace state_leaid = county + "000" + StateAssignedDistID + "000" if countyl == 2 & StateAssignedDistIDl == 1
replace state_leaid = "0" + county + "00" + StateAssignedDistID + "000" if countyl == 1 & StateAssignedDistIDl == 2
replace state_leaid = county + "00" + StateAssignedDistID + "000" if countyl == 2 & StateAssignedDistIDl == 2
replace state_leaid = "0" + county + "0" + StateAssignedDistID + "000" if countyl == 1 & StateAssignedDistIDl == 3
replace state_leaid = county + "0" + StateAssignedDistID + "000" if countyl == 2 & StateAssignedDistIDl == 3
replace state_leaid = "0" + county + StateAssignedDistID + "000" if countyl == 1 & StateAssignedDistIDl == 4
replace state_leaid = county + StateAssignedDistID + "000" if countyl == 2 & StateAssignedDistIDl == 4
replace state_leaid = "" if DataLevel == "State"

replace seasch = state_leaid + "-" + seasch if DataLevel == "School"
replace state_leaid = "NE-" + state_leaid if DataLevel != "State"

drop county countyl StateAssignedDistIDl StateAssignedSchIDl

replace StateAssignedDistID = "" if DataLevel == "State"
replace StateAssignedSchID = "" if DataLevel != "School"

//Grade Levels
drop if GradeLevel == 11
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

//Proficiency Percents
replace Lev1_percent = 1 - (Lev2_percent + Lev3_percent) if Lev1_percent == -1 & Lev2_percent != -1 & Lev3_percent != -1
replace Lev2_percent = 1 - (Lev1_percent + Lev3_percent) if Lev2_percent == -1 & Lev1_percent != -1 & Lev3_percent != -1
replace Lev3_percent = 1 - (Lev1_percent + Lev2_percent) if Lev3_percent == -1 & Lev1_percent != -1 & Lev2_percent != -1

gen ProficientOrAbove_percent = -1
replace ProficientOrAbove_percent = Lev2_percent + Lev3_percent if Lev2_percent != -1 | Lev3_percent != -1
replace ProficientOrAbove_percent = . if ProficientOrAbove_percent < 0
tostring ProficientOrAbove_percent, replace format("%6.0g") force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

local prof_vars "Lev1_percent Lev2_percent Lev3_percent AvgScaleScore"
foreach var of local prof_vars {
	tostring `var', replace format("%6.0g") force
	replace `var' = "*" if `var' == "-1"
	replace `var' = "--" if `var' == ""
}

//Student Groups & SubGroups
drop if StudentGroup == "Mobile"
replace StudentSubGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Students eligible for free and reduced lunch"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Receiving Free or Reduced Lunch"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
drop if StudentGroup == "Misc / Other"

//Subjects
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

save "$data/NE_AssmtData_2019.dta", replace

//Merge NCES Data
merge m:1 state_leaid using "$NCES/NCES District Files, Fall 1997-Fall 2021/NCES_2018_District.dta"
drop if _merge == 2

merge m:1 seasch state_leaid using "$NCES/NCES School Files, Fall 1997-Fall 2021/NCES_2018_School.dta", gen (merge2)
drop if merge2 == 2
save "$data/NE_AssmtData_2019.dta", replace

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

gen State = "Nebraska"
replace StateAbbrev = "NE"
replace StateFips = 31
replace DistName = lea_name if DataLevel == "School"

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch lea_name agency_charter_indicator dist_agency_charter_indicator

//Variable Types
decode SchVirtual, gen(SchVirtual_s)
drop SchVirtual
rename SchVirtual_s SchVirtual

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen (SchType_s)
drop SchType
rename SchType_s SchType

decode DistType, gen (DistType_s)
drop DistType
rename DistType_s DistType

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

save "$data/NE_AssmtData_2019.dta", replace
export delimited "$data/NE_AssmtData_2019", replace
clear


