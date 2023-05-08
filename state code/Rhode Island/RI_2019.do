clear
global path "/Users/willtolmie/Documents/State Repository Research/Rhode Island"

** 2018-19 NCES School Data

use "${path}/NCES/School/NCES_2018_School.dta"

** Rename Variables

rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename charter Charter
rename ncesschoolid NCESSchoolID
rename virtual Virtual 
rename school_level SchoolLevel
rename lea_name DistName
rename school_type SchoolType

** Drop Excess Variables

drop year urban_centric_locale bureau_indian_education lunch_program free_lunch reduced_price_lunch free_or_reduced_price_lunch enrollment school_status county_name county_code school_name school_id

** Label Variables

label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var Charter "Charter indicator"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"

** Isolate Rhode Island Data

drop if StateFips != 44
save "${path}/Semi-Processed Data Files/2018_19_NCES_Cleaned_School.dta", replace

** 2017-18 NCES District Data

use "${path}/NCES/District/NCES_2018_District.dta"

** Rename Variables

rename ncesdistrictid NCESDistrictID
rename state_name State
rename state_leaid State_leaid
rename state_location StateAbbrev
rename county_code CountyCode
rename county_name CountyName
rename district_agency_type DistrictType
rename state_fips StateFips

** Drop Excess Variables

drop year lea_name

** Label Variables

label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var CountyName "County in which the district or school is located."
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var DistrictType "District type as defined by NCES"

* Isolate Rhode Island Data

drop if StateFips != 44
save "${path}/Semi-Processed Data Files/2018_19_NCES_Cleaned_District.dta", replace

** 2018-19 ELA Data

import excel "${path}/Original Data Files/RI_OriginalData_2019_ela_state.xlsx", sheet("By_State_AndGrade") firstrow clear
gen DataLevel = "State"
save "${path}/Semi-Processed Data Files/2019_ela_state.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2019_ela_state.xlsx", sheet("By_State_Subgroups") firstrow clear
gen DataLevel = "State"
gen StudentGroup_TotalTested = "63155"
save "${path}/Semi-Processed Data Files/2019_ela_state_subgroups.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2019_ela_district.xlsx", sheet("By_District_AndGrade") firstrow clear
gen DataLevel = "District"
save "${path}/Semi-Processed Data Files/2019_ela_district.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2019_ela.xlsx", sheet("By_School_AndGrade") firstrow clear
gen DataLevel = "School"
append using "${path}/Semi-Processed Data Files/2019_ela_district.dta" "${path}/Semi-Processed Data Files/2019_ela_state.dta" "${path}/Semi-Processed Data Files/2019_ela_state_subgroups.dta"
rename PercentNotMeetingExpectations Lev1_percent
rename PercentPartiallyMeetingExpect Lev2_percent
rename PercentMeetingExpectations Lev3_percent
rename PercentExceedingExpectations Lev4_percent
rename PercentMeetingOrExceedingExp ProficientOrAbove_percent
save "${path}/Semi-Processed Data Files/2019_ela_unmerged.dta", replace

** 2018-19 Math Data

import excel "${path}/Original Data Files/RI_OriginalData_2019_mat_state.xlsx", sheet("By_State_AndGrade") firstrow clear
gen DataLevel = "State"
save "${path}/Semi-Processed Data Files/2019_math_state.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2019_mat_state.xlsx", sheet("By_State_Subgroups") firstrow clear
gen DataLevel = "State"
gen StudentGroup_TotalTested = "63856"
save "${path}/Semi-Processed Data Files/2019_math_state_subgroups.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2019_mat_district.xlsx", sheet("By_District_AndGrade") firstrow clear
gen DataLevel = "District"
save "${path}/Semi-Processed Data Files/2019_math_district.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2019_mat.xlsx", sheet("By_School_AndGrade") firstrow clear
gen DataLevel = "School"
append using "${path}/Semi-Processed Data Files/2019_math_district.dta" "${path}/Semi-Processed Data Files/2019_math_state.dta" "${path}/Semi-Processed Data Files/2019_math_state_subgroups.dta"
rename PercentNotMeetingExpectations Lev1_percent
rename PercentPartiallyMeetingExpect Lev2_percent
rename PercentMeetingExpectations Lev3_percent
rename PercentExceedingExpectations Lev4_percent
rename PercentMeetingOrExceedingExp ProficientOrAbove_percent
save "${path}/Semi-Processed Data Files/2019_math_unmerged.dta", replace

** 2018-19 Science Data

import excel "${path}/Original Data Files/RI_OriginalData_2019_sci_state.xlsx", sheet("By_State_AndGrade") firstrow clear
gen DataLevel = "State"
save "${path}/Semi-Processed Data Files/2019_sci_state.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2019_sci_state.xlsx", sheet("By_State_Subgroups") firstrow clear
gen DataLevel = "State"
gen StudentGroup_TotalTested = "31072"
save "${path}/Semi-Processed Data Files/2019_sci_state_subgroups.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2019_sci_district.xlsx", sheet("By_District_AndGrade") firstrow clear
gen DataLevel = "District"
save "${path}/Semi-Processed Data Files/2019_sci_district.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2019_sci.xlsx", sheet("By_School") firstrow clear
gen DataLevel = "School"
append using "${path}/Semi-Processed Data Files/2019_sci_district.dta" "${path}/Semi-Processed Data Files/2019_sci_state.dta" "${path}/Semi-Processed Data Files/2019_sci_state_subgroups.dta"
rename PercentBeginningToMeetExpect Lev1_percent
rename PercentApproachingExpectations Lev2_percent
rename PercentMeetingExpectations Lev3_percent
rename PercentExceedsExpectations Lev4_percent
rename PercentMeetingOrExceedingExp ProficientOrAbove_percent
save "${path}/Semi-Processed Data Files/2019_sci_unmerged.dta", replace

** Merge 2018-19 Assessments

append using "${path}/Semi-Processed Data Files/2019_ela_unmerged.dta" "${path}/Semi-Processed Data Files/2019_math_unmerged.dta"

** Rename Variables

rename AssessmentName AssmtName
rename DistrictCode StateAssignedDistID
rename DistrictName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName
rename Grade GradeLevel
rename PercentTested ParticipationRate
rename AverageScaleScore AvgScaleScore
rename Group StudentGroup
rename GroupName StudentSubGroup

** Generate Flags

gen Flag_AssmtNameChange = "N"
replace Flag_AssmtNameChange = "Y" if AssmtName == "NGSA - Science"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "Y"

** Label Flags

label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only."
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."
label var Flag_CutScoreChange_oth "Flag denoting a change in scoring determinations in subjects other than ELA, math, or reading from the prior year only (e.g., writing, STEM)."

** Generate Other Variables

gen Subject = "ela"
replace Subject = "math" if AssmtName == "RICAS - Mathematics"
replace Subject = "sci" if AssmtName == "NGSA - Science"
replace AssmtName = "RICAS" if Subject != "sci"
replace AssmtName = "NGSA" if Subject == "sci"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3 and 4"

** Standardize Subgroup Data

replace StudentGroup = "All students" if StudentGroup == ""
replace StudentSubGroup = "All students" if StudentSubGroup == ""
gen StudentSubGroup_TotalTested = NumberTested
replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All students"
replace StudentGroup="Race" if StudentGroup=="Race/Ethnicity"
replace StudentGroup="EL status" if StudentGroup=="English Learner"
replace StudentGroup="Economic status" if StudentGroup=="Economically Disadvantaged"
drop if StudentGroup=="Homeless"
drop if StudentGroup=="Special Education"
drop if StudentGroup=="Accommodations"
drop if StudentGroup=="Migrant"
drop if StudentGroup=="Active Military Parent"
drop if StudentGroup=="Foster Care"
replace StudentGroup="All students" if StudentGroup==""
replace StudentSubGroup="All students" if StudentGroup=="All students"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Other"
replace StudentSubGroup="English learner" if StudentSubGroup=="Current English Learners"
replace StudentSubGroup="English proficient" if StudentSubGroup=="Not English Learners"
replace StudentSubGroup="Other" if StudentSubGroup=="Recently (3 yrs) Exited English Learners"

** Generate Empty Variables

gen ProficientOrAbove_count = "*"
gen Lev1_count = "*"
gen Lev2_count = "*"
gen Lev3_count = "*"
gen Lev4_count = "*"
gen Lev5_percent = "*"
gen Lev5_count = "*"

** Label Variables

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

** Drop Excess Variables

drop NumberTested PercentHighGrowth AverageStudentGrowthPercentil PercentLowGrowth PercentTypicalGrowth L M N O P Q R S T U V W X Y Z

** Merging NCES Variables

gen state_leaidnumber =.
gen State_leaid = string(state_leaidnumber)
replace State_leaid = "RI-" + StateAssignedDistID if DataLevel != "State"
label var State_leaid "State LEA ID"
gen seaschnumber=.
gen seasch = string(seaschnumber)
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == "School"
merge m:1 State_leaid using "${path}/Semi-Processed Data Files/2018_19_NCES_Cleaned_District.dta"
rename _merge district_merge
merge m:1 seasch StateFips using "${path}/Semi-Processed Data Files/2018_19_NCES_Cleaned_School.dta"

** Drop Unmerged NCES Observations

drop if district_merge != 3 & _merge !=3 & DataLevel != "State"
keep if SchYear == "2018-19"

** Fix Variable Types

destring StudentGroup_TotalTested, replace
destring StudentSubGroup_TotalTested, replace
destring NCESDistrictID, replace
destring NCESSchoolID, replace
destring CountyCode, replace
decode State, gen(State2)
decode DistrictType, gen(DistrictType2)
decode Charter, gen(Charter2)
decode SchoolLevel, gen(SchoolLevel2)
decode SchoolType, gen(SchoolType2)
decode Virtual, gen(Virtual2)
drop state_leaidnumber seaschnumber _merge district_merge State DistrictType Charter SchoolLevel SchoolType Virtual
rename State2 State
rename DistrictType2 DistrictType
rename Charter2 Charter
rename SchoolLevel2 SchoolLevel 
rename SchoolType2 SchoolType 
rename Virtual2 Virtual

** Relabel GradeLevel Values

replace GradeLevel="G03" if GradeLevel=="03"
replace GradeLevel="G04" if GradeLevel=="04"
replace GradeLevel="G05" if GradeLevel=="05"
replace GradeLevel="G06" if GradeLevel=="06"
replace GradeLevel="G07" if GradeLevel=="07"
replace GradeLevel="G08" if GradeLevel=="08"
replace GradeLevel="G11" if GradeLevel=="11"
replace GradeLevel="G08" if SchoolLevel=="Middle" & Subject=="sci"
replace GradeLevel="G05" if SchoolLevel=="Primary" & Subject=="sci"
replace GradeLevel="G38" if DataLevel=="State" & GradeLevel==""
replace GradeLevel="G38" if GradeLevel=="STATE"

** Relabel GradeLevel Values for Science Assessment Data

gen lowgrade = string(lowest_grade_offered)
gen highgrade = string(highest_grade_offered)
replace lowgrade="3" if lowgrade=="-1" | lowgrade=="0" | lowgrade=="2"
replace GradeLevel="G05, G08, G11" if lowgrade=="3" & GradeLevel=="" | GradeLevel=="G38" & Subject=="sci"
replace GradeLevel="G08, G11" if lowgrade=="7" & GradeLevel==""
replace GradeLevel="G11" if lowgrade=="9" & GradeLevel==""
drop lowest_grade_offered lowgrade highest_grade_offered highgrade

** Standardize Suppressed Proficiency Data

replace Lev1_percent="*" if Lev1_percent=="**" | Lev1_percent=="***"
replace Lev2_percent="*" if Lev2_percent=="**" | Lev2_percent=="***"
replace Lev3_percent="*" if Lev3_percent=="**" | Lev3_percent=="***"
replace Lev4_percent="*" if Lev4_percent=="**" | Lev4_percent=="***"

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

** Standardize Non-School Level Data

replace SchName = "Statewide" if DataLevel == "State"
replace SchName = "Districtwide" if DataLevel == "District"
replace DistName = "Statewide" if DataLevel == "State"

** Fix Variable Order 

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

** Drop 11th Grade Science Assessment Data

drop if GradeLevel == "G11"

** Export 2018-19 Assessment Data

save "${path}/Semi-Processed Data Files/RI_AssmtData_2019.dta", replace
export delimited using "${path}/Output/RI_AssmtData_2019.csv", replace
