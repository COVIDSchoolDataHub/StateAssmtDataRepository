cap log close
log using alaska_cleaning.log, replace

cd "/Users/benjaminm/Documents/State_Repository_Research/Alaska"


//import delimited AK_AssmtData_2017.csv, clear stringcols(10)
// NEW ADDED: new changes 5/26





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

//NEW ADDED

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 
//NEW ADDED

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
 
gen DistCharter = "No"  
replace DistCharter = "Yes" if DistrictType == "Charter agency" 
//NEW ADDED

rename DistrictType DistType 
//NEW ADDED


// NEW ADDED
gen NCESSchoolID = ""

gen SchType  = ""

gen SchVirtual  = ""

gen seasch  = ""
gen SchLevel  = ""

gen SchName = "All Schools"

gen StateAssignedSchID = ""


// Student Group Correct Labels 
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English Proficiency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"

keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Alaska Native/American Indian"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
// replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == ""
replace StudentSubGroup = "White" if StudentSubGroup == "Caucasian"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"


// Ethnicity Group 
//replace StudentSubGroup = "" if StudentSubGroup == ""
// replace StudentSubGroup = "" if StudentSubGroup == ""

// El Status Group 

replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Economically Disadvantaged"


// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"
//NEW ADDED


// GradeLevel Changes
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


// NEW ADDED
destring StudentGroup_TotalTested, replace force
destring ParticipationRate, replace force


// Accurate StudentGroup_Total_Tested using Part Rate and Enrollment
gen double StudentGroup_TotalTested_New = . 
replace StudentGroup_TotalTested_New = StudentGroup_TotalTested * ParticipationRate
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested_New StudentGroup_TotalTested

// Creating StudentSubGroup_TotalTested 
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
// destring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == .
bys StudentGroup Subject GradeLevel DistName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
//replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
// tostring StudentGroup_TotalTested1, replace
//replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested


// Changing ParticipationRate to Percent 
destring ProficientOrAbove_percent, generate (ProficientOrAbove_percent1) force percent

tostring ProficientOrAbove_percent1, replace force

replace ProficientOrAbove_percent = ProficientOrAbove_percent1 if ProficientOrAbove_percent1 != "."



order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth 

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth 


// Deletes unmerged districts
keep if AssmtName == "PEAKS"

sort DataLevel DistName Subject GradeLevel StudentGroup StudentSubGroup 
//NEW ADDED


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

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

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
 
gen DistCharter = "No"  
replace DistCharter = "Yes" if DistrictType == "Charter agency" 

rename DistrictType DistType 

gen NCESSchoolID = ""

gen SchType  = ""

gen SchVirtual  = ""

gen seasch  = ""
gen SchLevel  = ""

gen SchName = "All Schools"

gen StateAssignedSchID = ""


// Student Group Correct Labels 
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English Proficiency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"

keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Alaska Native/American Indian"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
// replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == ""
replace StudentSubGroup = "White" if StudentSubGroup == "Caucasian"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"


// Ethnicity Group 
//replace StudentSubGroup = "" if StudentSubGroup == ""
// replace StudentSubGroup = "" if StudentSubGroup == ""

// El Status Group 

replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Economically Disadvantaged"


// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

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


destring StudentGroup_TotalTested, replace force
destring ParticipationRate, replace force


// Accurate StudentGroup_Total_Tested using Part Rate and Enrollment
gen double StudentGroup_TotalTested_New = . 
replace StudentGroup_TotalTested_New = StudentGroup_TotalTested * ParticipationRate
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested_New StudentGroup_TotalTested

// Creating StudentSubGroup_TotalTested 
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
// destring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == .
bys StudentGroup Subject GradeLevel DistName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
//replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
// tostring StudentGroup_TotalTested1, replace
//replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested


// Changing ParticipationRate to Percent 
destring ProficientOrAbove_percent, generate (ProficientOrAbove_percent1) force percent

tostring ProficientOrAbove_percent1, replace force

replace ProficientOrAbove_percent = ProficientOrAbove_percent1 if ProficientOrAbove_percent1 != "."



order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth 

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth 


// Deletes unmerged districts
keep if AssmtName == "PEAKS"


sort DataLevel DistName Subject GradeLevel StudentGroup StudentSubGroup 


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

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

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
 
gen DistCharter = "No"  
replace DistCharter = "Yes" if DistrictType == "Charter agency" 
rename DistrictType DistType 

gen NCESSchoolID = ""

gen SchType  = ""

gen SchVirtual  = ""

gen seasch  = ""
gen SchLevel  = ""

gen SchName = "All Schools"

gen StateAssignedSchID = ""


// Student Group Correct Labels NEW
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English Proficiency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"

keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Alaska Native/American Indian"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
// replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == ""
replace StudentSubGroup = "White" if StudentSubGroup == "Caucasian"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"


// Ethnicity Group 
//replace StudentSubGroup = "" if StudentSubGroup == ""
// replace StudentSubGroup = "" if StudentSubGroup == ""

// El Status Group 

replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Economically Disadvantaged"


// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"


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


destring StudentGroup_TotalTested, replace force
destring ParticipationRate, replace force


// Accurate StudentGroup_Total_Tested using Part Rate and Enrollment
gen double StudentGroup_TotalTested_New = . 
replace StudentGroup_TotalTested_New = StudentGroup_TotalTested * ParticipationRate
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested_New StudentGroup_TotalTested

// Creating StudentSubGroup_TotalTested 
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
// destring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == .
bys StudentGroup Subject GradeLevel DistName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
//replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
// tostring StudentGroup_TotalTested1, replace
//replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested


// Changing ParticipationRate to Percent 
destring ProficientOrAbove_percent, generate (ProficientOrAbove_percent1) force percent

tostring ProficientOrAbove_percent1, replace force

replace ProficientOrAbove_percent = ProficientOrAbove_percent1 if ProficientOrAbove_percent1 != "."



order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth 

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth 


// Deletes unmerged districts
keep if AssmtName == "PEAKS"

sort DataLevel DistName Subject GradeLevel StudentGroup StudentSubGroup 


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

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

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
 
gen DistCharter = "No"  
replace DistCharter = "Yes" if DistrictType == "Charter agency" 

rename DistrictType DistType 

gen NCESSchoolID = ""

gen SchType  = ""

gen SchVirtual  = ""

gen seasch  = ""
gen SchLevel  = ""

gen SchName = "All Schools"

gen StateAssignedSchID = ""


// Student Group Correct Labels NEW
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English Proficiency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"

keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Alaska Native/American Indian"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
// replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == ""
replace StudentSubGroup = "White" if StudentSubGroup == "Caucasian"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"

// Ethnicity Group 
//replace StudentSubGroup = "" if StudentSubGroup == ""
// replace StudentSubGroup = "" if StudentSubGroup == ""

// El Status Group 

replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Economically Disadvantaged"


// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

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

destring StudentGroup_TotalTested, replace force
destring ParticipationRate, replace force


// Accurate StudentGroup_Total_Tested using Part Rate and Enrollment
gen double StudentGroup_TotalTested_New = . 
replace StudentGroup_TotalTested_New = StudentGroup_TotalTested * ParticipationRate
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested_New StudentGroup_TotalTested

// Creating StudentSubGroup_TotalTested 
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
// destring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == .
bys StudentGroup Subject GradeLevel DistName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
//replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
// tostring StudentGroup_TotalTested1, replace
//replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested


// Changing ParticipationRate to Percent 
destring ProficientOrAbove_percent, generate (ProficientOrAbove_percent1) force percent

tostring ProficientOrAbove_percent1, replace force

replace ProficientOrAbove_percent = ProficientOrAbove_percent1 if ProficientOrAbove_percent1 != "."



order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth 

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth 


// Deletes unmerged districts
keep if AssmtName == "PEAKS"

sort DataLevel DistName Subject GradeLevel StudentGroup StudentSubGroup 


save AK_AssmtData_2021_Stata, replace
export delimited AK_AssmtData_2021.csv, replace

