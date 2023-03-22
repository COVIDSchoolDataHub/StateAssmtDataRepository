global path "/Users/willtolmie/Documents/State Repository Research/Rhode Island"

** 2020-21 NCES School Data

use "${path}/NCES/School/NCES_2020_School.dta"

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
save "${path}/Semi-Processed Data Files/2020_21_NCES_Cleaned_School.dta", replace

** 2020-21 NCES District Data

use "${path}/NCES/District/NCES_2020_District.dta"

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
save "${path}/Semi-Processed Data Files/2020_21_NCES_Cleaned_District.dta"

** 2021-22 ELA Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_ela.xlsx", sheet("By_School_AndGrade") firstrow

** Standardize Variable Names in Grade Data

rename H StudentGroup_TotalTested
rename I ParticipationRate
rename J Lev1_percent
rename K Lev2_percent
rename L Lev3_percent
rename M Lev4_percent
rename N ProficientOrAbove_percent
rename O AvgScaleScore
rename P AverageStudentGrowthPercentile
rename Q PercentLowGrowth
rename R PercentTypicalGrowth
rename S PercentHighGrowth
rename T StandardError

** Drop Excess Variables

drop U V W X Y Z AA AB AC AD AE AF AG
save "/Users/willtolmie/Desktop/2022_ela_grade_unmerged.dta"
import excel "${path}/Original Data Files/RI_OriginalData_2022_ela.xlsx", sheet("By_School_Subgroups") firstrow clear

** Standardize Variable Names in Subgroup Data

rename I StudentGroup_TotalTested
rename J ParticipationRate
rename K Lev1_percent
rename L Lev2_percent
rename M Lev3_percent
rename N Lev4_percent
rename O ProficientOrAbove_percent
rename P AvgScaleScore
rename Q AverageStudentGrowthPercentile
rename R PercentLowGrowth
rename S PercentTypicalGrowth
rename T PercentHighGrowth
rename U StandardError

** Drop Excess Variables

drop V W X Y Z AA AB AC AD AE AF AG AH

** Merge Grade and Subgroup Data

append using "${path}/Semi-Processed Data Files/2022_ela_grade_unmerged.dta"
save "${path}/Semi-Processed Data Files/2022_ela_unmerged.dta"

** 2021-22 Math Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_mat.xlsx", sheet("By_School_AndGrade") firstrow clear

** Standardize Variable Names in Grade Data

rename H StudentGroup_TotalTested
rename I ParticipationRate
rename J Lev1_percent
rename K Lev2_percent
rename L Lev3_percent
rename M Lev4_percent
rename N ProficientOrAbove_percent
rename O AvgScaleScore
rename P AverageStudentGrowthPercentile
rename Q PercentLowGrowth
rename R PercentTypicalGrowth
rename S PercentHighGrowth
rename T StandardError

** Drop Excess Variables

drop U V W X Y Z AA AB AC AD AE AF AG
save "${path}/Semi-Processed Data Files/2022_math_grade_unmerged.dta"
import excel "${path}/Original Data Files/RI_OriginalData_2022_mat.xlsx", sheet("By_School_Subgroups") firstrow clear

** Standardize Variable Names in Subgroup Data

rename I StudentGroup_TotalTested
rename J ParticipationRate
rename K Lev1_percent
rename L Lev2_percent
rename M Lev3_percent
rename N Lev4_percent
rename O ProficientOrAbove_percent
rename P AvgScaleScore
rename Q AverageStudentGrowthPercentile
rename R PercentLowGrowth
rename S PercentTypicalGrowth
rename T PercentHighGrowth
rename U StandardError

** Drop Excess Variables

drop V W X Y Z AA AB AC AD AE AF AG AH

** Merge Grade and Subgroup Data

append using "${path}/Semi-Processed Data Files/2022_math_grade_unmerged.dta"
save "${path}/Semi-Processed Data Files/2022_math_unmerged.dta"

** 2021-22 Science Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_sci.xlsx", sheet("By_School_Subgroups") firstrow clear

** Standardize Variable Names in Subgroup Data

rename I StudentGroup_TotalTested
rename J ParticipationRate
rename K Lev1_percent
rename L Lev2_percent
rename M Lev3_percent
rename N Lev4_percent
rename O ProficientOrAbove_percent
rename P AvgScaleScore
rename Q StandardError

** Drop Excess Variables

drop R S T U V W X Y Z
save "${path}/Semi-Processed Data Files/2022_sci_subgroup_unmerged.dta"
import excel "${path}/Original Data Files/RI_OriginalData_2022_sci.xlsx", sheet("By_School") firstrow

** Standardize Variable Names in All Students Data

rename G StudentGroup_TotalTested
rename H ParticipationRate
rename I Lev1_percent
rename J Lev2_percent
rename K Lev3_percent
rename L Lev4_percent
rename M ProficientOrAbove_percent
rename N AvgScaleScore
rename O StandardError

** Drop Excess Variables

drop P Q R S T U V W X
save "${path}/Semi-Processed Data Files/2022_sci_all_unmerged.dta"

** Merge All Students and Subgroup Data

append using "${path}/Semi-Processed Data Files/2022_sci_subgroup_unmerged.dta"

** Merge 2021-22 Assessments

append using "${path}/Semi-Processed Data Files/2022_ela_unmerged.dta" "${path}/Semi-Processed Data Files/2022_math_unmerged.dta"

** Rename Variables

rename AssessmentName AssmtName
rename DistrictCode StateAssignedDistID
rename DistrictName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName
rename Grade GradeLevel
rename Group StudentGroup
rename GroupName StudentSubGroup

** Generate Flags

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

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
gen AssmtType = "Regular"
gen DataLevel = "School"

** Generate Empty Variables

gen ProficientOrAbove_count = .
gen Lev1_count = .
gen Lev2_count = .
gen Lev3_count = .
gen Lev4_count = .
gen Lev5_percent = .
gen Lev5_count = .
gen ProficiencyCriteria = ""

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

drop StandardError PercentTestedChange ChangeinPercentMeetingOrExc StatisticallySignificant AB AC AD AE AF AG AH AI AJ AK 

** Merging NCES Variables

gen state_leaidnumber =.
gen State_leaid = string(state_leaidnumber)
replace State_leaid = "RI-" + StateAssignedDistID 
label var State_leaid "State LEA ID"
gen seaschnumber=.
gen seasch = string(seaschnumber)
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID
merge m:1 State_leaid using "${path}/Semi-Processed Data Files/2020_21_NCES_Cleaned_District.dta"
rename _merge district_merge
merge m:1 seasch StateFips using "${path}/Semi-Processed Data Files/2020_21_NCES_Cleaned_School.dta"

** Drop Unmerged NCES Observations

drop if district_merge != 3

* Fix Variable Types

decode State, gen(State2)
rename State2 State
decode DistrictType, gen(DistrictType2)
rename DistrictType2 DistrictType
decode Charter, gen(Charter2)
rename Charter2 Charter
decode SchoolLevel, gen(SchoolLevel2)
rename SchoolLevel2 SchoolLevel 
decode SchoolType, gen(SchoolType2)
rename SchoolType2 SchoolType 
decode Virtual, gen(Virtual2)
rename Virtual2 Virtual
drop state_leaidnumber seaschnumber _merge district_merge State DistrictType Charter SchoolLevel SchoolType Virtual

* Fix Variable Order 

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

** Relabel GradeLevel Values

replace GradeLevel="G03" if GradeLevel=="03"
replace GradeLevel="G04" if GradeLevel=="04"
replace GradeLevel="G05" if GradeLevel=="05"
replace GradeLevel="G06" if GradeLevel=="06"
replace GradeLevel="G07" if GradeLevel=="07"
replace GradeLevel="G08" if GradeLevel=="08"
replace GradeLevel="G08" if SchoolLevel=="Middle" & AssmtName=="NGSA - Science"
replace GradeLevel="G05" if SchoolLevel=="Primary" & AssmtName=="NGSA - Science"
drop if SchoolLevel=="High"

* Standardize Subgroup Data

replace StudentGroup="Race" if StudentGroup=="Race/Ethnicity"
replace StudentGroup="EL status" if StudentGroup=="English Learner"
drop if StudentGroup=="Homeless"
drop if StudentGroup=="Special Education"
drop if StudentGroup=="Accommodations"
drop if StudentGroup=="Migrant"
drop if StudentGroup=="Active Military Parent"
drop if StudentGroup=="Foster Care"
replace StudentGroup="All students" if StudentGroup==""
replace StudentSubGroup="All students" if StudentGroup=="All students"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Other"
replace StudentSubGroup="English learner" if StudentSubGroup=="Current English Learners"
replace StudentSubGroup="Other" if StudentSubGroup=="Recently (3 yrs) Exited English Learners"

* Export 2021-22 Assessment Data

save "${path}/Semi-Processed Data Files/RI_AssmtData_2022.dta", replace
export delimited using "${path}/Output/RI_AssmtData_2022.csv", replace
