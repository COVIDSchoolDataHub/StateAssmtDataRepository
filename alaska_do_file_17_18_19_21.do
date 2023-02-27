cap log close
log using alaska_cleaning.log, replace

cd "/Users/benjaminm/Documents/State_Repository_Research/Alaska/Output"

// 2016-17
import excel "Alaska_test_scores_2017_original.xlsx", clear


rename A SchYear
rename B AssmtName
rename C StateAssignedDistID
rename D DistName
rename E Subject
rename F GradeLevel
rename G StudentGroup
rename H StudentSubGroup
rename I ProficientOrAbove_count
rename J ProficientOrAbove_percent
rename K NotProficient_count
rename L NotProficient_percent
rename M StudentGroup_TotalTested
rename N ParticipationRate


label var SchYear "School year in which the data were reported. (e.g., 2021-22)"

label var AssmtName "Name of state assessment"
label var StateAssignedDistID "State-assigned district ID"
label var DistName "District name"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested (Individual grade levels, Gr3-8, all grades)"
label var StudentGroup "Student demographic group"
label var StudentSubGroup "Student demographic subgroup"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment."
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment."
label var NotProficient_count "Count of students achieving below proficiency on the state assessment."
label var NotProficient_percent "Percent of students achieving below proficiency on the state assessment."
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested."
label var ParticipationRate "Participation rate."

gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""

label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only. "
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."
label var Flag_CutScoreChange_oth "Flag denoting a change in scoring determinations in subjects other than ELA, math, or reading from the prior year only (e.g., writing, STEM)."


gen DataLevel = "District"
gen AssmtType = "Regular"

label var DataLevel "Level at which the data are reported"

drop if SchYear == "School_Year"

merge m:1 DistName using NCES_2017_District_Data_Cleaned

replace SchYear = "2016-17"
gen Subject2 = lower(Subject)
drop Subject 
rename Subject2 Subject

order State StateAbbrev StateFips NCESDistrictID State_leaid  DistrictType CountyName CountyCode SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA	Flag_CutScoreChange_math Flag_CutScoreChange_read	Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID Subject GradeLevel StudentGroup  StudentGroup_TotalTested StudentSubGroup ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 

drop _merge

save AK_AssmtData_2017_Stata, replace
export delimited AK_AssmtData_2017_Stata_v2.csv

// 2017-18
import excel "Alaska_test_scores_2018_original.xlsx", clear


rename A SchYear
rename B AssmtName
rename C StateAssignedDistID
rename D DistName
rename E Subject
rename F GradeLevel
rename G StudentGroup
rename H StudentSubGroup
rename I ProficientOrAbove_count
rename J ProficientOrAbove_percent
rename K NotProficient_count
rename L NotProficient_percent
rename M StudentGroup_TotalTested
rename N ParticipationRate


label var SchYear "School year in which the data were reported. (e.g., 2021-22)"

label var AssmtName "Name of state assessment"
label var StateAssignedDistID "State-assigned district ID"
label var DistName "District name"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested (Individual grade levels, Gr3-8, all grades)"
label var StudentGroup "Student demographic group"
label var StudentSubGroup "Student demographic subgroup"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment."
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment."
label var NotProficient_count "Count of students achieving below proficiency on the state assessment."
label var NotProficient_percent "Percent of students achieving below proficiency on the state assessment."
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested."
label var ParticipationRate "Participation rate."

gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""

label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only. "
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."
label var Flag_CutScoreChange_oth "Flag denoting a change in scoring determinations in subjects other than ELA, math, or reading from the prior year only (e.g., writing, STEM)."


gen DataLevel = "District"
gen AssmtType = "Regular"

label var DataLevel "Level at which the data are reported"

drop if SchYear == "School_Year"

merge m:1 DistName using NCES_2018_District_Data_Cleaned

replace SchYear = "2017-18"
gen Subject2 = lower(Subject)
drop Subject 
rename Subject2 Subject

order State StateAbbrev StateFips NCESDistrictID State_leaid  DistrictType CountyName CountyCode SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA	Flag_CutScoreChange_math Flag_CutScoreChange_read	Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID Subject GradeLevel StudentGroup  StudentGroup_TotalTested StudentSubGroup ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 

drop _merge

save AK_AssmtData_2018_Stata, replace
export delimited AK_AssmtData_2018_Stata_v2.csv

// 2018-19
import excel "Alaska_test_scores_2019_original.xlsx", clear


rename A SchYear
rename B AssmtName
rename C StateAssignedDistID
rename D DistName
rename E Subject
rename F GradeLevel
rename G StudentGroup
rename H StudentSubGroup
rename I ProficientOrAbove_count
rename J ProficientOrAbove_percent
rename K NotProficient_count
rename L NotProficient_percent
rename M StudentGroup_TotalTested
rename N ParticipationRate


label var SchYear "School year in which the data were reported. (e.g., 2021-22)"

label var AssmtName "Name of state assessment"
label var StateAssignedDistID "State-assigned district ID"
label var DistName "District name"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested (Individual grade levels, Gr3-8, all grades)"
label var StudentGroup "Student demographic group"
label var StudentSubGroup "Student demographic subgroup"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment."
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment."
label var NotProficient_count "Count of students achieving below proficiency on the state assessment."
label var NotProficient_percent "Percent of students achieving below proficiency on the state assessment."
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested."
label var ParticipationRate "Participation rate."

gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""

label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only. "
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."
label var Flag_CutScoreChange_oth "Flag denoting a change in scoring determinations in subjects other than ELA, math, or reading from the prior year only (e.g., writing, STEM)."


gen DataLevel = "District"
gen AssmtType = "Regular"

label var DataLevel "Level at which the data are reported"

drop if SchYear == "School_Year"

merge m:1 DistName using NCES_2019_District_Data_Cleaned

replace SchYear = "2018-19"
gen Subject2 = lower(Subject)
drop Subject 
rename Subject2 Subject

order State StateAbbrev StateFips NCESDistrictID State_leaid  DistrictType CountyName CountyCode SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA	Flag_CutScoreChange_math Flag_CutScoreChange_read	Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID Subject GradeLevel StudentGroup  StudentGroup_TotalTested StudentSubGroup ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 

drop _merge

save AK_AssmtData_2019_Stata, replace
export delimited AK_AssmtData_2019_Stata_v2.csv

// 2020-21
import excel "Alaska_test_scores_2021_original.xlsx", clear


rename A SchYear
rename B AssmtName
rename C StateAssignedDistID
rename D DistName
rename E Subject
rename F GradeLevel
rename G StudentGroup
rename H StudentSubGroup
rename I ProficientOrAbove_count
rename J ProficientOrAbove_percent
rename K NotProficient_count
rename L NotProficient_percent
rename M StudentGroup_TotalTested
rename N ParticipationRate


label var SchYear "School year in which the data were reported. (e.g., 2021-22)"

label var AssmtName "Name of state assessment"
label var StateAssignedDistID "State-assigned district ID"
label var DistName "District name"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested (Individual grade levels, Gr3-8, all grades)"
label var StudentGroup "Student demographic group"
label var StudentSubGroup "Student demographic subgroup"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment."
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment."
label var NotProficient_count "Count of students achieving below proficiency on the state assessment."
label var NotProficient_percent "Percent of students achieving below proficiency on the state assessment."
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested."
label var ParticipationRate "Participation rate."

gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""

label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only. "
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."
label var Flag_CutScoreChange_oth "Flag denoting a change in scoring determinations in subjects other than ELA, math, or reading from the prior year only (e.g., writing, STEM)."


gen DataLevel = "District"
gen AssmtType = "Regular"

label var DataLevel "Level at which the data are reported"

drop if SchYear == "School_Year"

merge m:1 DistName using NCES_2021_District_Data_Cleaned

replace SchYear = "2020-21"
gen Subject2 = lower(Subject)
drop Subject 
rename Subject2 Subject

order State StateAbbrev StateFips NCESDistrictID State_leaid  DistrictType CountyName CountyCode SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA	Flag_CutScoreChange_math Flag_CutScoreChange_read	Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID Subject GradeLevel StudentGroup  StudentGroup_TotalTested StudentSubGroup ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 

drop _merge

save AK_AssmtData_2019_Stata, replace
export delimited AK_AssmtData_2021_Stata_v2.csv

