cap log close
log using alaska_cleaning.log, replace

cd "/Users/benjaminm/Documents/State_Repository_Research/Alaska"


// 2016-17
import excel "Alaska_test_scores_2017_original.xlsx", clear

// Rename Variables
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


// Label Variables
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

// Generate Flags
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

// Generate other variables
gen DataLevel = "District"
gen AssmtType = "Regular"


// Generate Empty Variables

gen Lev1_count = . 
gen Lev1_percent = .
gen Lev2_count = .
gen Lev2_percent = .
gen Lev3_count = .
gen Lev3_percent = .
gen Lev4_count = .
gen Lev4_percent = .
gen Lev5_count = .
gen Lev5_percent = .
gen AvgScaleScore = .
gen ProficiencyCriteria = ""


label var DataLevel "Level at which the data are reported"

drop if SchYear == "School_Year"

merge m:1 DistName using NCES_2016_District_Data_Cleaned

// Formatting for School Year
replace SchYear = "2016-17"

// Making the Subjects Lowercase
gen Subject2 = lower(Subject)
drop Subject 
rename Subject2 Subject

// Recode DistrictType to String and Generate Charter Variable
decode DistrictType, gen(DistrictType2)
drop DistrictType
rename DistrictType2 DistrictType
 
gen Charter = "No" 
replace Charter = "Yes" if DistrictType == "Charter agency"

drop _merge

// Deletes unmerged districts
keep if AssmtName == "PEAKS"

gen NCESSchoolID =.
gen SchoolType  =.
gen Virtual  =.
gen seasch  =.
gen SchoolLevel  =.
gen SchName  =.
gen StateAssignedSchID  =.


gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == "3"
replace GradeLevel2 = "G04" if GradeLevel == "4"
replace GradeLevel2 = "G05" if GradeLevel == "5"
replace GradeLevel2 = "G06" if GradeLevel == "6"
replace GradeLevel2 = "G07" if GradeLevel == "7"
replace GradeLevel2 = "G08" if GradeLevel == "8"

drop GradeLevel
rename GradeLevel2 GradeLevel

drop NotProficient_count NotProficient_percent

replace ProficiencyCriteria = "Levels 3 and 4"

order State StateAbbrev StateFips NCESDistrictID State_leaid  DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual  seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA	Flag_CutScoreChange_math Flag_CutScoreChange_read	Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName Subject StateAssignedSchID GradeLevel StudentGroup  StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 



save AK_AssmtData_2017_Stata, replace
export delimited AK_AssmtData_2017.csv, replace

// 2017-18
import excel "Alaska_test_scores_2018_original.xlsx", clear

// Rename Variables
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


// Label Variables
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

// Generate Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""

label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only. "
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."
label var Flag_CutScoreChange_oth "Flag denoting a change in scoring determinations in subjects other than ELA, math, or reading from the prior year only (e.g., writing, STEM)."

// Generate other variables
gen DataLevel = "District"
gen AssmtType = "Regular"


// Generate Empty Variables

gen Lev1_count = . 
gen Lev1_percent = .
gen Lev2_count = .
gen Lev2_percent = .
gen Lev3_count = .
gen Lev3_percent = .
gen Lev4_count = .
gen Lev4_percent = .
gen Lev5_count = .
gen Lev5_percent = .
gen AvgScaleScore = .
gen ProficiencyCriteria = ""


label var DataLevel "Level at which the data are reported"

drop if SchYear == "School_Year"

merge m:1 DistName using NCES_2017_District_Data_Cleaned

// Formatting for School Year
replace SchYear = "2017-18"

// Making the Subjects Lowercase
gen Subject2 = lower(Subject)
drop Subject 
rename Subject2 Subject

// Recode DistrictType to String and Generate Charter Variable
decode DistrictType, gen(DistrictType2)
drop DistrictType
rename DistrictType2 DistrictType
 
gen Charter = "No" 
replace Charter = "Yes" if DistrictType == "Charter agency"

gen NCESSchoolID =.
gen SchoolType  =.
gen Virtual  =.
gen seasch  =.
gen SchoolLevel  =.
gen SchName  =.
gen StateAssignedSchID  =.


gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == "3"
replace GradeLevel2 = "G04" if GradeLevel == "4"
replace GradeLevel2 = "G05" if GradeLevel == "5"
replace GradeLevel2 = "G06" if GradeLevel == "6"
replace GradeLevel2 = "G07" if GradeLevel == "7"
replace GradeLevel2 = "G08" if GradeLevel == "8"

drop GradeLevel
rename GradeLevel2 GradeLevel

drop NotProficient_count NotProficient_percent

replace ProficiencyCriteria = "Levels 3 and 4"


// Correct Order for Variables
order State StateAbbrev StateFips NCESDistrictID State_leaid  DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual  seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA	Flag_CutScoreChange_math Flag_CutScoreChange_read	Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName Subject StateAssignedSchID GradeLevel StudentGroup  StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 

drop _merge

// Deletes unmerged districts
keep if AssmtName == "PEAKS"


save AK_AssmtData_2018_Stata, replace
export delimited AK_AssmtData_2018.csv, replace

// 2018-19
import excel "Alaska_test_scores_2019_original.xlsx", clear

// Rename Variables
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


// Label Variables
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

// Generate Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""

label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only. "
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."
label var Flag_CutScoreChange_oth "Flag denoting a change in scoring determinations in subjects other than ELA, math, or reading from the prior year only (e.g., writing, STEM)."

// Generate other variables
gen DataLevel = "District"
gen AssmtType = "Regular"


// Generate Empty Variables

gen Lev1_count = . 
gen Lev1_percent = .
gen Lev2_count = .
gen Lev2_percent = .
gen Lev3_count = .
gen Lev3_percent = .
gen Lev4_count = .
gen Lev4_percent = .
gen Lev5_count = .
gen Lev5_percent = .
gen AvgScaleScore = .
gen ProficiencyCriteria = ""


label var DataLevel "Level at which the data are reported"

drop if SchYear == "School_Year"

merge m:1 DistName using NCES_2018_District_Data_Cleaned

// Formatting for School Year
replace SchYear = "2018-19"

// Making the Subjects Lowercase
gen Subject2 = lower(Subject)
drop Subject 
rename Subject2 Subject

// Recode DistrictType to String and Generate Charter Variable
decode DistrictType, gen(DistrictType2)
drop DistrictType
rename DistrictType2 DistrictType
 
gen Charter = "No" 
replace Charter = "Yes" if DistrictType == "Charter agency"


gen NCESSchoolID =.
gen SchoolType  =.
gen Virtual  =.
gen seasch  =.
gen SchoolLevel  =.
gen SchName  =.
gen StateAssignedSchID  =.


gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == "3"
replace GradeLevel2 = "G04" if GradeLevel == "4"
replace GradeLevel2 = "G05" if GradeLevel == "5"
replace GradeLevel2 = "G06" if GradeLevel == "6"
replace GradeLevel2 = "G07" if GradeLevel == "7"
replace GradeLevel2 = "G08" if GradeLevel == "8"

drop GradeLevel
rename GradeLevel2 GradeLevel

drop NotProficient_count NotProficient_percent

replace ProficiencyCriteria = "Levels 3 and 4"


// Correct Order for Variables
order State StateAbbrev StateFips NCESDistrictID State_leaid  DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual  seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA	Flag_CutScoreChange_math Flag_CutScoreChange_read	Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName Subject StateAssignedSchID GradeLevel StudentGroup  StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 

drop _merge

// Deletes unmerged districts
keep if AssmtName == "PEAKS"


save AK_AssmtData_2019_Stata, replace
export delimited AK_AssmtData_2019.csv, replace

// 2020-21
import excel "Alaska_test_scores_2021_original.xlsx", clear

// Rename Variables
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


// Label Variables
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

// Generate Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""

label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only. "
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."
label var Flag_CutScoreChange_oth "Flag denoting a change in scoring determinations in subjects other than ELA, math, or reading from the prior year only (e.g., writing, STEM)."

// Generate other variables
gen DataLevel = "District"
gen AssmtType = "Regular"


// Generate Empty Variables

gen Lev1_count = . 
gen Lev1_percent = .
gen Lev2_count = .
gen Lev2_percent = .
gen Lev3_count = .
gen Lev3_percent = .
gen Lev4_count = .
gen Lev4_percent = .
gen Lev5_count = .
gen Lev5_percent = .
gen AvgScaleScore = .
gen ProficiencyCriteria = ""


label var DataLevel "Level at which the data are reported"

drop if SchYear == "School_Year"

merge m:1 DistName using NCES_2020_District_Data_Cleaned

// Formatting for School Year
replace SchYear = "2020-21"

// Making the Subjects Lowercase
gen Subject2 = lower(Subject)
drop Subject 
rename Subject2 Subject

// Recode DistrictType to String and Generate Charter Variable
decode DistrictType, gen(DistrictType2)
drop DistrictType
rename DistrictType2 DistrictType
 
gen Charter = "No" 
replace Charter = "Yes" if DistrictType == "Charter agency"

gen NCESSchoolID =.
gen SchoolType  =.
gen Virtual  =.
gen seasch  =.
gen SchoolLevel  =.
gen SchName  =.
gen StateAssignedSchID  =.


gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == "3"
replace GradeLevel2 = "G04" if GradeLevel == "4"
replace GradeLevel2 = "G05" if GradeLevel == "5"
replace GradeLevel2 = "G06" if GradeLevel == "6"
replace GradeLevel2 = "G07" if GradeLevel == "7"
replace GradeLevel2 = "G08" if GradeLevel == "8"

drop GradeLevel
rename GradeLevel2 GradeLevel

drop NotProficient_count NotProficient_percent

replace ProficiencyCriteria = "Levels 3 and 4"

// Correct Order for Variables
order State StateAbbrev StateFips NCESDistrictID State_leaid  DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual  seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA	Flag_CutScoreChange_math Flag_CutScoreChange_read	Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName Subject StateAssignedSchID GradeLevel StudentGroup  StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 

drop _merge

// Deletes unmerged districts
keep if AssmtName == "PEAKS"


save AK_AssmtData_2021_Stata, replace
export delimited AK_AssmtData_2021.csv

