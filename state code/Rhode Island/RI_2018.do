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
rename charter Charter
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename virtual Virtual 
rename school_level SchoolLevel
rename lea_name DistName
rename school_type SchoolType
rename county_name CountyName

** Drop Excess Variables

drop year

** Label Variables

label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var Charter "Charter indicator"
label var CountyName "County in which the district or school is located."
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"

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
save "${path}/Semi-Processed Data Files/2017_18_NCES_Cleaned_District.dta", replace

** 2017-18 ELA Data

import excel "${path}/Original Data Files/RI_OriginalData_2018_ela.xlsx", sheet("By_School_AndGrade") firstrow clear
save "${path}/Semi-Processed Data Files/2018_ela_unmerged.dta", replace

** 2017-18 Math Data

import excel "${path}/Original Data Files/RI_OriginalData_2018_mat.xlsx", sheet("By_School_AndGrade") firstrow clear
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
rename NumberTested StudentGroup_TotalTested
rename PercentTested ParticipationRate
rename PercentNotMeetingExpectations Lev1_percent
rename PercentPartiallyMeetingExpect Lev2_percent
rename PercentMeetingExpectations Lev3_percent
rename PercentExceedingExpectations Lev4_percent
rename PercentMeetingOrExceedingExp ProficientOrAbove_percent
rename AverageScaleScore AvgScaleScore

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
label var Flag_CutScoreChange_oth "Flag denoting a change in scoring determinations in subjects other than ELA, math, or reading from the prior year only (e.g., writing, STEM)."

** Generate Other Variables

gen Subject = "ela"
replace Subject = "math" if AssmtName == "RICAS - Mathematics"
gen AssmtType = "Regular"
gen DataLevel = "School"
gen StudentGroup = "All students"
gen StudentSubGroup = "All students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen ProficiencyCriteria = "Levels 3 and 4"

** Generate Empty Variables

gen ProficientOrAbove_count = .
gen Lev1_count = .
gen Lev2_count = .
gen Lev3_count = .
gen Lev4_count = .
gen Lev5_percent = .
gen Lev5_count = .

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

drop AverageStudentGrowthPercentil PercentLowGrowth PercentTypicalGrowth PercentHighGrowth T U V W X Y Z

** Merging NCES Variables

gen state_leaidnumber =.
gen State_leaid = string(state_leaidnumber)
replace State_leaid = "RI-" + StateAssignedDistID 
label var State_leaid "State LEA ID"
gen seaschnumber=.
gen seasch = string(seaschnumber)
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID
merge m:1 State_leaid using "${path}/Semi-Processed Data Files/2017_18_NCES_Cleaned_District.dta"
rename _merge district_merge
merge m:1 seasch StateFips using "${path}/Semi-Processed Data Files/2017_18_NCES_Cleaned_School.dta"

** Drop Unmerged NCES Observations

. drop if district_merge != 3

* Fix Variable Types

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

* Fix Variable Order 

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

* Export 2017-18 Assessment Data

save "${path}/Semi-Processed Data Files/RI_AssmtData_2018.dta", replace
export delimited using "${path}/Output/RI_AssmtData_2018.csv", replace
