clear
global path "/Users/willtolmie/Documents/State Repository Research/Rhode Island"

** 2017-18 NCES School Data

use "${path}/NCES/School/NCES_2017_School.dta"

** Rename Variables

rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename lea_name DistName
rename school_type SchType

** Drop Excess Variables

drop year district_agency_type district_agency_type_num county_code county_name school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch dist_lowest_grade_offered dist_highest_grade_offered dist_agency_charter_indicator

** Label Variables

label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistCharter "Charter indicator"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"

** Isolate Rhode Island Data

drop if StateFips != 44
save "${path}/Semi-Processed Data Files/2017_18_NCES_Cleaned_School.dta", replace

** 2017-18 NCES District Data

use "${path}/NCES/District/NCES_2017_District.dta"

** Rename Variables

rename ncesdistrictid NCESDistrictID
rename state_name State
rename state_leaid State_leaid
rename state_location StateAbbrev
rename county_code CountyCode
rename county_name CountyName
rename district_agency_type DistType
rename state_fips StateFips

** Drop Excess Variables

drop year lea_name urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type_num agency_charter_indicator lowest_grade_offered highest_grade_offered

** Label Variables

label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var CountyName "County in which the district or school is located."
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var DistCharter "Charter indicator"
label var DistType "District type as defined by NCES"

** Isolate Rhode Island Data

drop if StateFips != 44
save "${path}/Semi-Processed Data Files/2017_18_NCES_Cleaned_District.dta", replace

** 2017-18 ELA Data

import excel "${path}/Original Data Files/RI_OriginalData_2018_ela_state.xlsx", sheet("By_State_AndGrade") firstrow clear
gen DataLevel = "State"
save "${path}/Semi-Processed Data Files/2018_ela_state.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2018_ela_state.xlsx", sheet("By_State_Subgroups") firstrow clear
gen DataLevel = "State"
gen StudentGroup_TotalTested = "63663"
save "${path}/Semi-Processed Data Files/2018_ela_state_subgroups.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2018_ela_district.xlsx", sheet("By_District_AndGrade") firstrow clear
gen DataLevel = "District"
save "${path}/Semi-Processed Data Files/2018_ela_district.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2018_ela.xlsx", sheet("By_School_AndGrade") firstrow clear
gen DataLevel = "School"
append using "${path}/Semi-Processed Data Files/2018_ela_district.dta" "${path}/Semi-Processed Data Files/2018_ela_state.dta" "${path}/Semi-Processed Data Files/2018_ela_state_subgroups.dta"
save "${path}/Semi-Processed Data Files/2018_ela_unmerged.dta", replace

** 2017-18 Math Data

import excel "${path}/Original Data Files/RI_OriginalData_2018_mat_state.xlsx", sheet("By_State_AndGrade") firstrow clear
gen DataLevel = "State"
save "${path}/Semi-Processed Data Files/2018_math_state_unmerged.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2018_mat_state.xlsx", sheet("By_State_Subgroups") firstrow clear
gen DataLevel = "State"
gen StudentGroup_TotalTested = "64468"
save "${path}/Semi-Processed Data Files/2018_math_state_subgroups_unmerged.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2018_mat_district.xlsx", sheet("By_District_AndGrade") firstrow clear
gen DataLevel = "District"
save "${path}/Semi-Processed Data Files/2018_math_district_unmerged.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2018_mat.xlsx", sheet("By_School_AndGrade") firstrow clear
gen DataLevel = "School"
append using "${path}/Semi-Processed Data Files/2018_math_district_unmerged.dta" "${path}/Semi-Processed Data Files/2018_math_state_unmerged.dta" "${path}/Semi-Processed Data Files/2018_math_state_subgroups_unmerged.dta"
save "${path}/Semi-Processed Data Files/2018_math_unmerged.dta", replace

** Merge 2017-18 Assessments

append using "${path}/Semi-Processed Data Files/2018_ela_unmerged.dta"

** Rename Variables

rename AssessmentName AssmtName
rename DistrictCode StateAssignedDistID
rename DistrictName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName
rename Grade GradeLevel
rename PercentTested ParticipationRate
rename PercentNotMeetingExpectations Lev1_percent
rename PercentPartiallyMeetingExpect Lev2_percent
rename PercentMeetingExpectations Lev3_percent
rename PercentExceedingExpectations Lev4_percent
rename PercentMeetingOrExceedingExp ProficientOrAbove_percent
rename AverageScaleScore AvgScaleScore
rename Group StudentGroup
rename GroupName StudentSubGroup

** Generate Flags

gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""

** Label Flags

label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only."
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."

** Generate Other Variables

gen Subject = "ela"
replace Subject = "math" if AssmtName == "RICAS - Mathematics"
replace AssmtName = "RICAS"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3 and 4"

** Standardize Subgroup Data

replace StudentGroup = "All Students" if StudentGroup == ""
replace StudentSubGroup = "All Students" if StudentSubGroup == ""
gen StudentSubGroup_TotalTested = NumberTested
replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup="RaceEth" if StudentGroup=="Race/Ethnicity"
replace StudentGroup="EL Status" if StudentGroup=="English Learner"
replace StudentGroup="Economic Status" if StudentGroup=="Economically Disadvantaged"
drop if StudentGroup=="Homeless"
drop if StudentGroup=="Special Education"
drop if StudentGroup=="Accommodations"
drop if StudentGroup=="Migrant"
drop if StudentGroup=="Active Military Parent"
drop if StudentGroup=="Foster Care"
replace StudentGroup="All Students" if StudentGroup==""
replace StudentSubGroup="All Students" if StudentGroup=="All Students"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Other"
replace StudentSubGroup="English Learner" if StudentSubGroup=="Current English Learners"
replace StudentSubGroup="English Proficient" if StudentSubGroup=="Not English Learners"
replace StudentSubGroup="Other" if StudentSubGroup=="Recently (3 yrs) Exited English Learners"

** Generate Empty Variables

gen ProficientOrAbove_count = "--"
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"

** Drop Excess Variables

drop NumberTested AverageStudentGrowthPercentil PercentLowGrowth PercentTypicalGrowth PercentHighGrowth P Q R S T U V W X Y Z

** Merging NCES Variables

gen state_leaidnumber =.
gen State_leaid = string(state_leaidnumber)
replace State_leaid = "RI-" + StateAssignedDistID if DataLevel != "State"
label var State_leaid "State LEA ID"
gen seaschnumber=.
gen seasch = string(seaschnumber)
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == "School"
merge m:1 State_leaid using "${path}/Semi-Processed Data Files/2017_18_NCES_Cleaned_District.dta"
rename _merge district_merge
merge m:1 seasch StateFips using "${path}/Semi-Processed Data Files/2017_18_NCES_Cleaned_School.dta"

** Drop Unmerged NCES Observations

drop if district_merge != 3 & _merge !=3 & DataLevel != "State"
keep if SchYear == "2017-18"

** Standardize Non-School Level Data

replace SchName = "All Schools" if DataLevel == "State"
replace SchName = "All Schools" if DataLevel == "District"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace State_leaid = "" if DataLevel == "State"
replace seasch = "" if DataLevel == "State"

** Fix Variable Types

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 
recast int CountyCode
drop State StateAbbrev StateFips
gen State = "Rhode Island"
gen StateAbbrev = "RI"
gen StateFips = 44
recast int StateFips
decode DistType, gen(DistType2)
drop state_leaidnumber seaschnumber _merge district_merge DistType
rename DistType2 DistType
generate SchType2 = strofreal(SchType)
drop SchType
rename SchType2 SchType
generate SchLevel2 = strofreal(SchLevel)
drop SchLevel
rename SchLevel2 SchLevel
generate SchVirtual2 = strofreal(SchVirtual)
drop SchVirtual
rename SchVirtual2 SchVirtual

** Relabel GradeLevel Values

replace GradeLevel="G03" if GradeLevel=="03"
replace GradeLevel="G04" if GradeLevel=="04"
replace GradeLevel="G05" if GradeLevel=="05"
replace GradeLevel="G06" if GradeLevel=="06"
replace GradeLevel="G07" if GradeLevel=="07"
replace GradeLevel="G08" if GradeLevel=="08"
replace GradeLevel="G38" if DistName=="All Districts" & GradeLevel==""
replace GradeLevel="G38" if GradeLevel=="STATE"

** Standardize Suppressed Proficiency Data

replace Lev1_percent="*" if Lev1_percent=="**" | Lev1_percent=="***"
replace Lev2_percent="*" if Lev2_percent=="**" | Lev2_percent=="***"
replace Lev3_percent="*" if Lev3_percent=="**" | Lev3_percent=="***"
replace Lev4_percent="*" if Lev4_percent=="**" | Lev4_percent=="***"
replace Lev4_percent="*" if Lev4_percent=="**" | Lev4_percent=="***"
replace ParticipationRate="*" if ParticipationRate=="**" | ParticipationRate=="***"
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="**" | ProficientOrAbove_percent=="***"

** Convert Proficiency Data into Percentages

foreach v of varlist Lev* {
	destring `v', g(n`v') i(* -)
	replace n`v' = n`v' / 100 if n`v' != .
	tostring n`v', replace force
	replace `v' = n`v' if `v' != "*"
	drop n`v'
}

destring ProficientOrAbove_percent, generate(nProficientOrAbove_percent) force
replace nProficientOrAbove_percent = nProficientOrAbove_percent / 100 if nProficientOrAbove_percent != .
tostring nProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = nProficientOrAbove_percent if ProficientOrAbove_percent != "*"
drop nProficientOrAbove_percent

destring ParticipationRate, generate(nParticipationRate) force
replace nParticipationRate = nParticipationRate / 100 if nParticipationRate != .
tostring nParticipationRate, replace force
replace ParticipationRate = nParticipationRate if ParticipationRate != "*"
drop nParticipationRate

** Label Variables

rename State StateName
label var StateName "State name"
rename StateName State
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var SchYear "School year in which the data were reported. (e.g., 2021-22)"
label var AssmtName "Name of state assessment"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested (Individual grade levels, Gr3-8, all grades)"
label var StudentGroup "Student demographic group"
label var StudentSubGroup "Student demographic subgroup"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested."
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested."
label var Lev1_count "Count of students within subgroup performing at Level 1."
label var Lev1_percent "Percent of students within subgroup performing at Level 1."
label var Lev2_count "Count of students within subgroup performing at Level 2."
label var Lev2_percent "Percent of students within subgroup performing at Level 2."
label var Lev3_count "Count of students within subgroup performing at Level 3."
label var Lev3_percent "Percent of students within subgroup performing at Level 3 ."
label var Lev4_count "Count of students within subgroup performing at Level 4."
label var Lev4_percent "Percent of students within subgroup performing at Level 4."
label var Lev5_count "Count of students within subgroup performing at Level 5."
label var Lev5_percent "Percent of students within subgroup performing at Level 5."
label var AvgScaleScore "Avg scale score within subgroup."
label var ProficiencyCriteria "Levels included in determining proficiency status."
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment."
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment."
label var ParticipationRate "Participation rate."

** Fix Variable Order 

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

** Export 2017-18 Assessment Data

save "${path}/Semi-Processed Data Files/RI_AssmtData_2018.dta", replace
export delimited using "${path}/Output/RI_AssmtData_2018.csv", replace
