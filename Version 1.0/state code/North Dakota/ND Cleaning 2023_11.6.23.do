clear all
set more off

cd "/Users/miramehta/Documents/"
global data "/Users/miramehta/Documents/ND State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

//Import Data & Merge in Participation Data
import excel "$data/ND_ParticipationData_2023.xlsx", clear firstrow
duplicates drop
save "$data/ND_ParticipationData_2023.dta", replace

import excel "$data/ND_OriginalData_2023_all.xlsx", clear firstrow
duplicates drop
merge 1:1 InstitutionName InstitutionID Grade Subject AssessmentType Accomodations Subgroup using "$data/ND_ParticipationData_2023.dta", gen (mergep)
drop if mergep == 2

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
drop if GradeLevel == "10" | GradeLevel == "11" | GradeLevel == "All Grades"
replace GradeLevel = "G0" + GradeLevel

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
drop if StudentSubGroup == "Mobile Student " | StudentSubGroup == "Non-Mobile Student"
drop if StudentSubGroup == "Former English Learner" | StudentSubGroup == "Non-Former English Learner"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Gender" if StudentSubGroup == "Female" | StudentSubGroup == "Male"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"

//Fix Formatting & Generate Additional Variables
replace SchYear = "2022-23"
gen AssmtName = "North Dakota State Assessment (NDSA)"
gen Lev5_count = ""
gen Lev5_percent = ""
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3-4"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

save "$data/ND_AssmtData_2023.dta", replace

//Merge Data
use "$data/ND_AssmtData_2023.dta", clear
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2022_District_ND.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2022_School_ND.dta", gen (merge2)
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
replace DistName = proper(DistName) if DataLevel == "School"

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch lea_name

//Merged Schools with Missing Information
replace SchVirtual = -1 if SchName == "Elk Ridge Elementary School"
replace SchVirtual = -1 if SchName == "Silver Ranch Elementary School"

//Merge Student Counts
merge m:1 SchYear StateAssignedDistID StateAssignedSchID SchName StudentSubGroup GradeLevel using "$data/ND_EnrollmentData_2223.dta"
drop if _merge == 2

destring Enrolled, replace
gen StudentSubGroup_TotalTested = PercentTestedRangeLow * Enrolled
replace StudentSubGroup_TotalTested = round(StudentSubGroup_TotalTested)
gen StudentSubGroup_TotalTestedH = PercentTestedRangeHigh * Enrolled
replace StudentSubGroup_TotalTestedH = round(StudentSubGroup_TotalTestedH)
replace StudentSubGroup_TotalTested = . if _merge == 1 | Enrolled == . | mergep == 1

//Proficiency Levels, Participation Rates, and Cleaning Student Counts
gen ProfLow = ProficientRangeLow + AdvancedRangeLow
gen ProfHigh = ProficientRangeHigh + AdvancedRangeHigh
replace ProfHigh = 1 if ProfHigh > 1

rename NoviceRangeLow Lev1_pctLow
rename NoviceRangeHigh Lev1_pctHigh
rename PartiallyRangeLow Lev2_pctLow
rename PartiallyRangeHigh Lev2_pctHigh
rename ProficientRangeLow Lev3_pctLow
rename ProficientRangeHigh Lev3_pctHigh
rename AdvancedRangeLow Lev4_pctLow
rename AdvancedRangeHigh Lev4_pctHigh

forvalues n = 1/4 {
	gen Lev`n'_countLow = StudentSubGroup_TotalTested * Lev`n'_pctLow
	replace Lev`n'_countLow = round(Lev`n'_countLow)
	gen Lev`n'_countHigh = StudentSubGroup_TotalTestedH * Lev`n'_pctHigh
	replace Lev`n'_countHigh = round(Lev`n'_countHigh)
	replace Lev`n'_countLow = . if StudentSubGroup_TotalTested == .
	replace Lev`n'_countHigh = . if StudentSubGroup_TotalTested == .
}

tostring StudentSubGroup_TotalTested, replace
tostring StudentSubGroup_TotalTestedH, replace
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTested + "-" + StudentSubGroup_TotalTestedH if StudentSubGroup_TotalTested != StudentSubGroup_TotalTestedH
replace StudentSubGroup_TotalTested = "--" if mergep == 1 | _merge == 1 | StudentSubGroup_TotalTested == "."
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

tostring PercentTestedRangeLow, replace force
tostring PercentTestedRangeHigh, replace force

gen ParticipationRate = PercentTestedRangeLow + "-" + PercentTestedRangeHigh
replace ParticipationRate = PercentTestedRangeLow if PercentTestedRangeLow == PercentTestedRangeHigh
replace ParticipationRate = "--" if mergep == 1

drop Enrolled StudentSubGroup_TotalTestedH PercentTestedRangeLow PercentTestedRangeHigh mergep _merge

gen Prof_countLow = Lev3_countLow + Lev4_countLow
gen Prof_countHigh = Lev3_countHigh + Lev4_countHigh

forvalues n = 1/4 {
	tostring Lev`n'_countLow, replace
	tostring Lev`n'_countHigh, replace
	tostring Lev`n'_pctLow, replace
	tostring Lev`n'_pctHigh, replace
	gen Lev`n'_count = Lev`n'_countLow + "-" + Lev`n'_countHigh
	replace Lev`n'_count = Lev`n'_countLow if Lev`n'_countLow == Lev`n'_countHigh
	replace Lev`n'_count = "--" if Lev`n'_countLow == "." | Lev`n'_countHigh == "."
	gen Lev`n'_percent = Lev`n'_pctLow + "-" + Lev`n'_pctHigh
	replace Lev`n'_percent = Lev`n'_pctLow if Lev`n'_pctLow == Lev`n'_pctHigh
	drop Lev`n'_countLow Lev`n'_countHigh Lev`n'_pctLow Lev`n'_pctHigh
}

tostring ProfLow, replace format("%6.0g") force
tostring ProfHigh, replace format("%6.0g") force
gen ProficientOrAbove_percent = ProfLow + "-" + ProfHigh
replace ProficientOrAbove_percent = ProfLow if ProfLow == ProfHigh
tostring Prof_countLow, replace
tostring Prof_countHigh, replace
gen ProficientOrAbove_count = Prof_countLow + "-" + Prof_countHigh
replace ProficientOrAbove_count = Prof_countLow if Prof_countLow == Prof_countHigh
replace ProficientOrAbove_count = "--" if StudentSubGroup_TotalTested == "--"

drop ProfLow ProfHigh Prof_countLow Prof_countHigh

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

save "$data/ND_AssmtData_2023.dta", replace
export delimited "$data/ND_AssmtData_2023.csv", replace
clear
