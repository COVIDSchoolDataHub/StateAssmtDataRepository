clear all
log using georgia_cleaning.log, replace text

cd "/Users/miramehta/Documents/"
global GAdata "/Users/miramehta/Documents/GA State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

//2010-2011
import delimited "$GAdata/GA_OriginalData_2011_all.csv", clear

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
rename num_tested_cnt StudentSubGroup_TotalTested
rename does_not_meet_cnt Lev1_count
rename does_not_meet_percent Lev1_percent
rename meets_cnt Lev2_count
rename meets_percent Lev2_percent
rename exceeds_cnt Lev3_count
rename exceeds_percent Lev3_percent

//Generate Other Variables
gen AssmtName = "Criterion-Referenced Competency Tests"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "State" if StateAssignedDistID == "ALL"
gen AvgScaleScore =.
gen Lev4_count = "--"
gen Lev4_percent = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"

//Groups & SubGroups
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Asian"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Black or African American"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "White"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

replace SchName = DistName + " District Total" if DataLevel == "District"

bys SchName Subject GradeLevel StudentGroup: egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested)

//Passing Rates & Percentages
gen ProficiencyCriteria = "Levels 2 and 3"
gen ProficientOrAbove_count = Lev2_count + Lev3_count
gen ProficientOrAbove_percent = Lev2_percent + Lev3_percent

replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
tostring ProficientOrAbove_count, replace
replace Lev1_count = "--" if Lev1_count == "."
replace Lev2_count = "--" if Lev2_count == "."
replace Lev3_count = "--" if Lev3_count == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Grade Levels
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

//Subject Areas
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "read" if Subject == "Reading"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

//State and District Data
replace SchName = "Statewide" if DataLevel == "State"
replace DistName = "Statewide" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace SchName = "Districtwide" if DataLevel == "District"
replace StateAssignedSchID = "" if DataLevel != "School"

save "$GAdata/GA_AssmtData_2011.dta", replace

//Clean NCES Data
use "$NCES/NCES Data Prior to 2020-21/NCES_2010_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2011_School_GA.dta", replace

use "$NCES/NCES Data Prior to 2020-21/NCES_2010_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2011_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2011.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2011_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2011_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistrictType
rename charter Charter
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel

drop state_name year _merge merge2

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

//Unmerged Schools
replace NCESSchoolID = "130022503061" if SchName == "Atlanta Area School for the Deaf"
replace NCESDistrictID = "1300225" if DistName == "State Schools- Atlanta Area School for the Deaf"
replace SchoolLevel = 4 if SchName == "Atlanta Area School for the Deaf"
replace SchoolType = 2 if SchName == "Atlanta Area School for the Deaf"
replace Charter = 0 if SchName == "Atlanta Area School for the Deaf"
replace CountyCode = 13089 if DistName == "State Schools- Atlanta Area School for the Deaf"
replace CountyName = "DeKalb County" if DistName == "State Schools- Atlanta Area School for the Deaf"
replace NCESSchoolID = "130022403062" if SchName == "Georgia Academy for the Blind"
replace NCESDistrictID = "1300224" if DistName == "State Schools- Georgia Academy for the Blind"
replace SchoolLevel = 4 if SchName == "Georgia Academy for the Blind"
replace SchoolType = 2 if SchName == "Georgia Academy for the Blind"
replace Charter = 0 if SchName == "Georgia Academy for the Blind"
replace CountyCode = 13021 if DistName == "State Schools- Georgia Academy for the Blind"
replace CountyName = "Bibb County" if DistName == "State Schools- Georgia Academy for the Blind"
replace NCESSchoolID = "130022303063" if SchName == "Georgia School for the Deaf"
replace NCESDistrictID = "1300223" if DistName == "State Schools- Georgia School for the Deaf"
replace Charter = 0 if SchName == "Georgia School for the Deaf"
replace CountyCode = 13115 if DistName == "State Schools- Georgia School for the Deaf"
replace CountyName = "Floyd County" if DistName == "State Schools- Georgia School for the Deaf"

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistrictType "District type as defined by NCES"
label var Charter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"
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

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2011", replace
export delimited "$GAdata/GA_AssmtData_2011", replace
clear

//2011-2012
import delimited "$GAdata/GA_OriginalData_2012_all.csv", clear

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
rename num_tested_cnt StudentSubGroup_TotalTested
rename does_not_meet_cnt Lev1_count
rename does_not_meet_percent Lev1_percent
rename meets_cnt Lev2_count
rename meets_percent Lev2_percent
rename exceeds_cnt Lev3_count
rename exceeds_percent Lev3_percent

//Label Variables
label var SchYear "School year in which the data were reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested"
label var StudentSubGroup "Student demographic subgroup"
label var Lev1_count "Count of students within subgroup performing at Level 1"
label var Lev1_percent "Percent of students within subgroup performing at Level 1"
label var Lev2_count "Count of students within subgroup performing at Level 2"
label var Lev2_percent "Percent of students within subgroup performing at Level 2"
label var Lev3_count "Count of students within subgroup performing at Level 3"
label var Lev3_percent "Percent of students within subgroup performing at Level 3"

//Generate Other Variables
gen AssmtName = "Criterion-Referenced Competency Tests"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "State" if StateAssignedDistID == "ALL"
gen AvgScaleScore =.
gen Lev4_count = "--"
gen Lev4_percent = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"

//Groups & SubGroups
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Asian"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Black or African American"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "White"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

replace SchName = DistName + " District Total" if DataLevel == "District"

bys SchName Subject GradeLevel StudentGroup: egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested)

//Passing Rates & Percentages
gen ProficiencyCriteria = "Levels 2 and 3"
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev2_count + Lev3_count
gen ProficientOrAbove_percent = Lev2_percent + Lev3_percent

replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
tostring ProficientOrAbove_count, replace
replace Lev1_count = "--" if Lev1_count == "."
replace Lev2_count = "--" if Lev2_count == "."
replace Lev3_count = "--" if Lev3_count == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Grade Levels
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

//Subject Areas
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "read" if Subject == "Reading"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

//Statewide Data
replace SchName = "Statewide" if DataLevel == "State"
replace DistName = "Statewide" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace SchName = "Districtwide" if DataLevel == "District"
replace StateAssignedSchID = "" if DataLevel != "School"

save "$GAdata/GA_AssmtData_2012.dta", replace

//Clean NCES Data
use "$NCES/NCES Data Prior to 2020-21/NCES_2011_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2012_School_GA.dta", replace

use "$NCES/NCES Data Prior to 2020-21/NCES_2011_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2012_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2012.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2012_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2012_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistrictType
rename charter Charter
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel

drop state_name year _merge merge2

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistrictType "District type as defined by NCES"
label var Charter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"
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

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "$GAdata/GA_AssmtData_2012", replace
export delimited "$GAdata/GA_AssmtData_2012", replace
clear

//2012-2013
import delimited "$GAdata/GA_OriginalData_2013_all.csv", clear

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
rename num_tested_cnt StudentSubGroup_TotalTested
rename does_not_meet_cnt Lev1_count
rename does_not_meet_percent Lev1_percent
rename meets_cnt Lev2_count
rename meets_percent Lev2_percent
rename exceeds_cnt Lev3_count
rename exceeds_percent Lev3_percent

//Generate Other Variables
gen AssmtName = "Criterion-Referenced Competency Tests"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "State" if StateAssignedDistID == "ALL"
gen AvgScaleScore =.
gen Lev4_count = "--"
gen Lev4_percent = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"

//Groups & SubGroups
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Asian"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Black or African American"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "White"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

replace SchName = DistName + " District Total" if DataLevel == "District"

bys SchName Subject GradeLevel StudentGroup: egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested)

//Passing Rates & Percentages
gen ProficiencyCriteria = "Levels 2 and 3"
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev2_count + Lev3_count
gen ProficientOrAbove_percent = Lev2_percent + Lev3_percent

replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
tostring ProficientOrAbove_count, replace
replace Lev1_count = "--" if Lev1_count == "."
replace Lev2_count = "--" if Lev2_count == "."
replace Lev3_count = "--" if Lev3_count == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Grade Levels
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

//Subject Areas
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "read" if Subject == "Reading"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

//Statewide Data
replace SchName = "Statewide" if DataLevel == "State"
replace DistName = "Statewide" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace SchName = "Districtwide" if DataLevel == "District"
replace StateAssignedSchID = "" if DataLevel != "School"

save "$GAdata/GA_AssmtData_2013.dta", replace

//Clean NCES Data
use "/$NCES/NCES Data Prior to 2020-21/NCES_2012_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2013_School_GA.dta", replace

use "$NCES/NCES Data Prior to 2020-21/NCES_2012_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2013_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2013.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2013_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2013_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistrictType
rename charter Charter
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel

drop state_name year _merge merge2

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistrictType "District type as defined by NCES"
label var Charter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"
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

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "$GAdata/GA_AssmtData_2013", replace
export delimited "$GAdata/GA_AssmtData_2013", replace
clear

//2013-2014
import delimited "$GAdata/GA_OriginalData_2014_all.csv", clear

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
rename num_tested_cnt StudentSubGroup_TotalTested
rename does_not_meet_cnt Lev1_count
rename does_not_meet_percent Lev1_percent
rename meets_cnt Lev2_count
rename meets_percent Lev2_percent
rename exceeds_cnt Lev3_count
rename exceeds_percent Lev3_percent

//Generate Other Variables
gen AssmtName = "Criterion-Referenced Competency Tests"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "State" if StateAssignedDistID == "ALL"
gen AvgScaleScore =.
gen Lev4_count = "--"
gen Lev4_percent = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"

//Groups & SubGroups
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Asian"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Black or African American"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "White"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

replace SchName = DistName + " District Total" if DataLevel == "District"

bys SchName Subject GradeLevel StudentGroup: egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested)

//Passing Rates & Percentages
gen ProficiencyCriteria = "Levels 2 and 3"
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev2_count + Lev3_count
gen ProficientOrAbove_percent = Lev2_percent + Lev3_percent

replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
tostring ProficientOrAbove_count, replace
replace Lev1_count = "--" if Lev1_count == "."
replace Lev2_count = "--" if Lev2_count == "."
replace Lev3_count = "--" if Lev3_count == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Grade Levels
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

//Subject Areas
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "read" if Subject == "Reading"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

//Statewide Data
replace SchName = "Statewide" if DataLevel == "State"
replace DistName = "Statewide" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace SchName = "Districtwide" if DataLevel == "District"
replace StateAssignedSchID = "" if DataLevel != "School"

save "$GAdata/GA_AssmtData_2014.dta", replace

//Clean NCES Data
use "$NCES/NCES Data Prior to 2020-21/NCES_2013_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2014_School_GA.dta", replace

use "$NCES/NCES Data Prior to 2020-21/NCES_2013_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2014_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2014.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2014_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2014_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistrictType
rename charter Charter
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel

drop state_name year _merge merge2

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistrictType "District type as defined by NCES"
label var Charter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"
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

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "$GAdata/GA_AssmtData_2014", replace
export delimited "$GAdata/GA_AssmtData_2014", replace
clear

//2014-2015
import delimited "$GAdata/GA_OriginalData_2015_all.csv", clear

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
rename begin_cnt Lev1_count
rename begin_pct Lev1_percent
rename developing_cnt Lev2_count
rename developing_pct Lev2_percent
rename proficient_cnt Lev3_count
rename proficient_pct Lev3_percent
rename distinguished_cnt Lev4_count
rename distinguished_pct Lev4_percent

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "Y"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "State" if StateAssignedDistID == "ALL"
gen AvgScaleScore =.
gen Lev5_count = "--"
gen Lev5_percent = "--"

//Groups & SubGroups
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Asian"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Black or African American"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "White"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

replace SchName = DistName + " District Total" if DataLevel == "District"

gen StudentSubGroup_TotalTested = num_tested_cnt
destring num_tested_cnt, replace force
replace num_tested_cnt = -1000000 if num_tested_cnt == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(num_tested_cnt)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop num_tested_cnt

//Missing & Suppressed Data
replace Lev1_count = "--" if Lev1_count == ""
replace Lev1_count = "*" if Lev1_count == "TFS"
replace Lev2_count = "--" if Lev2_count == ""
replace Lev2_count = "*" if Lev2_count == "TFS"
replace Lev3_count = "--" if Lev3_count == ""
replace Lev3_count = "*" if Lev3_count == "TFS"
replace Lev4_count = "--" if Lev4_count == ""
replace Lev4_count = "*" if Lev4_count == "TFS"

//Passing Rates
gen Proficient_Count = Lev3_count
gen Distinguished_Count = Lev4_count
destring Proficient_Count, replace force
destring Distinguished_Count, replace force

gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Proficient_Count + Distinguished_Count if Proficient_Count !=. & Distinguished_Count !=.
drop Proficient_Count Distinguished_Count
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent

replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen ParticipationRate =.

//Missing Data (Part II)
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev3_count == "--"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev4_count == "--"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev3_count == "*"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev4_count == "*"
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace Lev4_percent = "--" if Lev4_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Grade Levels
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

//Subject Areas
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

//Statewide Data
replace SchName = "Statewide" if DataLevel == "State"
replace DistName = "Statewide" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace SchName = "Districtwide" if DataLevel == "District"
replace StateAssignedSchID = "" if DataLevel != "School"

save "$GAdata/GA_AssmtData_2015.dta", replace

//Clean NCES Data
use "$NCES/NCES Data Prior to 2020-21/NCES_2014_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2015_School_GA.dta", replace

use "$NCES/NCES Data Prior to 2020-21/NCES_2014_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2015_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2015.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2015_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2015_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistrictType
rename charter Charter
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel

drop state_name year _merge merge2

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistrictType "District type as defined by NCES"
label var Charter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"
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

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "$GAdata/GA_AssmtData_2015", replace
export delimited "$GAdata/GA_AssmtData_2015", replace
clear

//2015-2016
import delimited "$GAdata/GA_OriginalData_2016_all.csv", clear

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
rename num_tested_cnt StudentSubGroup_TotalTested
rename begin_cnt Lev1_count
rename begin_pct Lev1_percent
rename developing_cnt Lev2_count
rename developing_pct Lev2_percent
rename proficient_cnt Lev3_count
rename proficient_pct Lev3_percent
rename distinguished_cnt Lev4_count
rename distinguished_pct Lev4_percent

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "State" if StateAssignedDistID == "ALL"
gen AvgScaleScore =.
gen Lev5_count = "--"
gen Lev5_percent = "--"

//Groups & SubGroups
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Asian"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Black or African American"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "White"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

replace SchName = DistName + " District Total" if DataLevel == "District"

bys SchName Subject GradeLevel StudentGroup: egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested)

//Passing Rates & Percentages
gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev3_count + Lev4_count
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent

replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
tostring Lev4_count, replace
tostring ProficientOrAbove_count, replace
replace Lev1_count = "--" if Lev1_count == "."
replace Lev2_count = "--" if Lev2_count == "."
replace Lev3_count = "--" if Lev3_count == "."
replace Lev4_count = "--" if Lev4_count == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace Lev4_percent = "--" if Lev4_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Grade Levels
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

//Subject Areas
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

//Statewide Data
replace SchName = "Statewide" if DataLevel == "State"
replace DistName = "Statewide" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace SchName = "Districtwide" if DataLevel == "District"
replace StateAssignedSchID = "" if DataLevel != "School"

save "$GAdata/GA_AssmtData_2016.dta", replace

//Clean NCES Data
use "$NCES/NCES Data Prior to 2020-21/NCES_2015_School.dta", replace
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2016_School_GA.dta", replace

use "$NCES/NCES Data Prior to 2020-21/NCES_2015_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2016_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2016.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2016_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2016_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistrictType
rename charter Charter
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel

drop state_name year _merge merge2

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistrictType "District type as defined by NCES"
label var Charter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"
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

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "$GAdata/GA_AssmtData_2016", replace
export delimited "$GAdata/GA_AssmtData_2016", replace
clear

//2016-2017
import delimited "$GAdata/GA_OriginalData_2017_all.csv", clear

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
rename num_tested_cnt StudentSubGroup_TotalTested
rename begin_cnt Lev1_count
rename begin_pct Lev1_percent
rename developing_cnt Lev2_count
rename developing_pct Lev2_percent
rename proficient_cnt Lev3_count
rename proficient_pct Lev3_percent
rename distinguished_cnt Lev4_count
rename distinguished_pct Lev4_percent

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "State" if StateAssignedDistID == "ALL"
gen AvgScaleScore =.
gen Lev5_count = "--"
gen Lev5_percent = "--"

//Groups & SubGroups
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Asian"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Black or African American"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "White"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

replace SchName = DistName + " District Total" if DataLevel == "District"

bys SchName Subject GradeLevel StudentGroup: egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested)

//Passing Rates & Percentages
gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev3_count + Lev4_count
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent

replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
tostring Lev4_count, replace
tostring ProficientOrAbove_count, replace
replace Lev1_count = "--" if Lev1_count == "."
replace Lev2_count = "--" if Lev2_count == "."
replace Lev3_count = "--" if Lev3_count == "."
replace Lev4_count = "--" if Lev4_count == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace Lev4_percent = "--" if Lev4_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Grade Levels
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

//Subject Areas
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

//Statewide Data
replace SchName = "Statewide" if DataLevel == "State"
replace DistName = "Statewide" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace SchName = "Districtwide" if DataLevel == "District"
replace StateAssignedSchID = "" if DataLevel != "School"

save "$GAdata/GA_AssmtData_2017.dta", replace

//Clean NCES Data
use "$NCES/NCES Data Prior to 2020-21/NCES_2016_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
gen str StateAssignedSchID = substr(seasch, 5, 8)
drop seasch
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2017_School_GA.dta", replace

use "$NCES/NCES Data Prior to 2020-21/NCES_2016_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2017_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2017.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2017_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2017_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistrictType
rename charter Charter
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel

drop state_name year _merge merge2

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

//Unmerged Schools
replace NCESSchoolID = "130002303482" if SchName == "Odyssey School"
replace SchoolLevel = 1 if SchName == "Odyssey School"
replace SchoolType = 1 if SchName == "Odyssey School"
replace Charter = 1 if SchName == "Odyssey School"
replace Virtual = 0 if SchName == "Odyssey School"
replace NCESSchoolID = "130023204148" if SchName == "Georgia Cyber Academy"
replace SchoolLevel = 4 if SchName == "Georgia Cyber Academy"
replace SchoolType = 1 if SchName == "Georgia Cyber Academy"
replace Charter = 1 if SchName == "Georgia Cyber Academy"
replace Virtual = 1 if SchName == "Georgia Cyber Academy"
replace NCESSchoolID = "130023304164" if SchName == "Utopian Academy for the Arts Charter School"
replace SchoolLevel = 2 if SchName == "Utopian Academy for the Arts Charter School"
replace SchoolType = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace Charter = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace Virtual = 0 if SchName == "Utopian Academy for the Arts Charter School"
replace NCESSchoolID = "130021803964" if SchName == "Pataula Charter Academy"
replace SchoolLevel = 4 if SchName == "Pataula Charter Academy"
replace SchoolType = 1 if SchName == "Pataula Charter Academy"
replace Charter = 1 if SchName == "Pataula Charter Academy"
replace Virtual = 0 if SchName == "Pataula Charter Academy"
replace NCESSchoolID = "130023004051" if SchName == "Cherokee Charter Academy"
replace SchoolLevel = 1 if SchName == "Cherokee Charter Academy"
replace SchoolType = 1 if SchName == "Cherokee Charter Academy"
replace Charter = 1 if SchName == "Cherokee Charter Academy"
replace Virtual = 0 if SchName == "Cherokee Charter Academy"
replace NCESSchoolID = "130021703961" if SchName == "Fulton Leadership Academy"
replace SchoolLevel = 4 if SchName == "Fulton Leadership Academy"
replace SchoolType = 1 if SchName == "Fulton Leadership Academy"
replace Charter = 1 if SchName == "Fulton Leadership Academy"
replace Virtual = 0 if SchName == "Fulton Leadership Academy"
replace NCESSchoolID = "130022104021" if SchName == "Atlanta Heights Charter School"
replace SchoolLevel = 1 if SchName == "Atlanta Heights Charter School"
replace SchoolType = 1 if SchName == "Atlanta Heights Charter School"
replace Charter = 1 if SchName == "Atlanta Heights Charter School"
replace Virtual = 0 if SchName == "Atlanta Heights Charter School"
replace NCESSchoolID = "130022704031" if SchName == "Georgia Connections Academy"
replace SchoolLevel = 4 if SchName == "Georgia Connections Academy"
replace SchoolType = 1 if SchName == "Georgia Connections Academy"
replace Charter = 1 if SchName == "Georgia Connections Academy"
replace SchoolType = 1 if SchName == "Georgia Connections Academy"
replace Virtual = 1 if SchName == "Georgia Connections Academy"
replace NCESSchoolID = "130022204007" if SchName == "Coweta Charter Academy"
replace SchoolLevel = 1 if SchName == "Coweta Charter Academy"
replace SchoolType = 1 if SchName == "Coweta Charter Academy"
replace Charter = 1 if SchName == "Coweta Charter Academy"
replace Virtual = 0 if SchName == "Coweta Charter Academy"
replace NCESSchoolID = "130023904226" if SchName == "Cirrus Charter Academy"
replace SchoolLevel = 1 if SchName == "Cirrus Charter Academy"
replace SchoolType = 1 if SchName == "Cirrus Charter Academy"
replace Charter = 1 if SchName == "Cirrus Charter Academy"
replace Virtual = 0 if SchName == "Cirrus Charter Academy"
replace NCESSchoolID = "130022604023" if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchoolLevel = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchoolType = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace Charter = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace Virtual = 0 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace NCESSchoolID = "130024304253" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchoolLevel = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchoolType = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace Charter = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace Virtual = 0 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace NCESSchoolID = "130024204249" if SchName == "Brookhaven Innovation Academy"
replace SchoolLevel = 1 if SchName == "Brookhaven Innovation Academy"
replace SchoolType = 1 if SchName == "Brookhaven Innovation Academy"
replace Charter = 1 if SchName == "Brookhaven Innovation Academy"
replace Virtual = 0 if SchName == "Brookhaven Innovation Academy"
replace NCESSchoolID = "130023404179" if SchName == "International Charter School of Atlanta"
replace SchoolLevel = 1 if SchName == "International Charter School of Atlanta"
replace SchoolType = 1 if SchName == "International Charter School of Atlanta"
replace Charter = 1 if SchName == "International Charter School of Atlanta"
replace Virtual = 0 if SchName == "International Charter School of Atlanta"
replace NCESSchoolID = "130024104229" if SchName == "Liberty Tech Charter Academy"
replace SchoolLevel = 1 if SchName == "Liberty Tech Charter Academy"
replace SchoolType = 1 if SchName == "Liberty Tech Charter Academy"
replace Charter = 1 if SchName == "Liberty Tech Charter Academy"
replace Virtual = 0 if SchName == "Liberty Tech Charter Academy"
replace NCESSchoolID = "130023604192" if SchName == "Scintilla Charter Academy"
replace SchoolLevel = 1 if SchName == "Scintilla Charter Academy"
replace SchoolType = 1 if SchName == "Scintilla Charter Academy"
replace Charter = 1 if SchName == "Scintilla Charter Academy"
replace Virtual = 0 if SchName == "Scintilla Charter Academy"
replace NCESSchoolID = "130023804205" if SchName == "Georgia School for Innovation and the Classics"
replace SchoolLevel = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchoolType = 1 if SchName == "Georgia School for Innovation and the Classics"
replace Charter = 1 if SchName == "Georgia School for Innovation and the Classics"
replace Virtual = 0 if SchName == "Georgia School for Innovation and the Classics"
replace NCESSchoolID = "130023704193" if SchName == "Dubois Integrity Academy I"
replace SchoolLevel = 1 if SchName == "Dubois Integrity Academy I"
replace SchoolType = 1 if SchName == "Dubois Integrity Academy I"
replace Charter = 1 if SchName == "Dubois Integrity Academy I"
replace Virtual = 0 if SchName == "Dubois Integrity Academy I"
replace NCESSchoolID = "130022503061" if SchName == "Atlanta Area School for the Deaf"
replace NCESDistrictID = "1300225" if DistName == "State Schools- Atlanta Area School for the Deaf"
replace SchoolLevel = 4 if SchName == "Atlanta Area School for the Deaf"
replace SchoolType = 2 if SchName == "Atlanta Area School for the Deaf"
replace Charter = 0 if SchName == "Atlanta Area School for the Deaf"
replace Virtual = 0 if SchName == "Atlanta Area School for the Deaf"
replace CountyCode = 13089 if DistName == "State Schools- Atlanta Area School for the Deaf"
replace CountyName = "DeKalb County" if DistName == "State Schools- Atlanta Area School for the Deaf"
replace NCESSchoolID = "130022403062" if SchName == "Georgia Academy for the Blind"
replace NCESDistrictID = "1300224" if DistName == "State Schools- Georgia Academy for the Blind"
replace SchoolLevel = 4 if SchName == "Georgia Academy for the Blind"
replace SchoolType = 2 if SchName == "Georgia Academy for the Blind"
replace Charter = 0 if SchName == "Georgia Academy for the Blind"
replace Virtual = 0 if SchName == "Georgia Academy for the Blind"
replace CountyCode = 13021 if DistName == "State Schools- Georgia Academy for the Blind"
replace CountyName = "Bibb County" if DistName == "State Schools- Georgia Academy for the Blind"
replace NCESSchoolID = "130022303063" if SchName == "Georgia School for the Deaf"
replace NCESDistrictID = "1300223" if DistName == "State Schools- Georgia School for the Deaf"
replace Charter = 0 if SchName == "Georgia School for the Deaf"
replace Virtual = 0 if SchName == "Georgia School for the Deaf"
replace CountyCode = 13115 if DistName == "State Schools- Georgia School for the Deaf"
replace CountyName = "Floyd County" if DistName == "State Schools- Georgia School for the Deaf"

replace NCESSchoolID = "Missing" if SchName == "CCAT School"
replace NCESSchoolID = "Missing" if SchName == "Ivy Preparatory Academy School"

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistrictType "District type as defined by NCES"
label var Charter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"
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

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "$GAdata/GA_AssmtData_2017", replace
export delimited "$GAdata/GA_AssmtData_2017", replace
clear

//2017-2018
import delimited "$GAdata/GA_OriginalData_2018_all.csv", clear

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
rename num_tested_cnt StudentSubGroup_TotalTested
rename begin_cnt Lev1_count
rename begin_pct Lev1_percent
rename developing_cnt Lev2_count
rename developing_pct Lev2_percent
rename proficient_cnt Lev3_count
rename proficient_pct Lev3_percent
rename distinguished_cnt Lev4_count
rename distinguished_pct Lev4_percent

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "State" if StateAssignedDistID == "ALL"
gen AvgScaleScore =.
gen Lev5_count = "--"
gen Lev5_percent = "--"

//Groups & SubGroups
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Asian"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Black or African American"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "White"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

replace SchName = DistName + " District Total" if DataLevel == "District"

bys SchName Subject GradeLevel StudentGroup: egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested)

//Passing Rates & Percentages
gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev3_count + Lev4_count
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent

replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
tostring Lev4_count, replace
tostring ProficientOrAbove_count, replace
replace Lev1_count = "--" if Lev1_count == "."
replace Lev2_count = "--" if Lev2_count == "."
replace Lev3_count = "--" if Lev3_count == "."
replace Lev4_count = "--" if Lev4_count == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace Lev4_percent = "--" if Lev4_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Grade Levels
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

//Subject Areas
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

//Statewide Data
replace SchName = "Statewide" if DataLevel == "State"
replace DistName = "Statewide" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace SchName = "Districtwide" if DataLevel == "District"
replace StateAssignedSchID = "" if DataLevel != "School"

save "$GAdata/GA_AssmtData_2018.dta", replace

//Clean NCES Data
use "$NCES/NCES Data Prior to 2020-21/NCES_2017_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
gen str StateAssignedSchID = substr(seasch, 5, 8)
drop seasch
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2018_School_GA.dta", replace

use "$NCES/NCES Data Prior to 2020-21/NCES_2017_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2018_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2018.dta", replace
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2018_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2018_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistrictType
rename charter Charter
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel

drop state_name year _merge merge2

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

//Unmerged Schools
replace NCESSchoolID = "130002303482" if SchName == "Odyssey School"
replace SchoolLevel = 1 if SchName == "Odyssey School"
replace SchoolType = 1 if SchName == "Odyssey School"
replace Charter = 1 if SchName == "Odyssey School"
replace Virtual = 0 if SchName == "Odyssey School"
replace NCESSchoolID = "130023204148" if SchName == "Georgia Cyber Academy"
replace SchoolLevel = 4 if SchName == "Georgia Cyber Academy"
replace SchoolType = 1 if SchName == "Georgia Cyber Academy"
replace Charter = 1 if SchName == "Georgia Cyber Academy"
replace Virtual = 1 if SchName == "Georgia Cyber Academy"
replace NCESSchoolID = "130023304164" if SchName == "Utopian Academy for the Arts Charter School"
replace SchoolLevel = 2 if SchName == "Utopian Academy for the Arts Charter School"
replace SchoolType = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace Charter = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace Virtual = 0 if SchName == "Utopian Academy for the Arts Charter School"
replace NCESSchoolID = "130021803964" if SchName == "Pataula Charter Academy"
replace SchoolLevel = 4 if SchName == "Pataula Charter Academy"
replace SchoolType = 1 if SchName == "Pataula Charter Academy"
replace Charter = 1 if SchName == "Pataula Charter Academy"
replace Virtual = 0 if SchName == "Pataula Charter Academy"
replace NCESSchoolID = "130023004051" if SchName == "Cherokee Charter Academy"
replace SchoolLevel = 1 if SchName == "Cherokee Charter Academy"
replace SchoolType = 1 if SchName == "Cherokee Charter Academy"
replace Charter = 1 if SchName == "Cherokee Charter Academy"
replace Virtual = 0 if SchName == "Cherokee Charter Academy"
replace NCESSchoolID = "130021703961" if SchName == "Fulton Leadership Academy"
replace SchoolLevel = 4 if SchName == "Fulton Leadership Academy"
replace SchoolType = 1 if SchName == "Fulton Leadership Academy"
replace Charter = 1 if SchName == "Fulton Leadership Academy"
replace Virtual = 0 if SchName == "Fulton Leadership Academy"
replace NCESSchoolID = "130022104021" if SchName == "Atlanta Heights Charter School"
replace SchoolLevel = 1 if SchName == "Atlanta Heights Charter School"
replace SchoolType = 1 if SchName == "Atlanta Heights Charter School"
replace Charter = 1 if SchName == "Atlanta Heights Charter School"
replace Virtual = 0 if SchName == "Atlanta Heights Charter School"
replace NCESSchoolID = "130022704031" if SchName == "Georgia Connections Academy"
replace SchoolLevel = 4 if SchName == "Georgia Connections Academy"
replace SchoolType = 1 if SchName == "Georgia Connections Academy"
replace Charter = 1 if SchName == "Georgia Connections Academy"
replace SchoolType = 1 if SchName == "Georgia Connections Academy"
replace Virtual = 1 if SchName == "Georgia Connections Academy"
replace NCESSchoolID = "130022204007" if SchName == "Coweta Charter Academy"
replace SchoolLevel = 1 if SchName == "Coweta Charter Academy"
replace SchoolType = 1 if SchName == "Coweta Charter Academy"
replace Charter = 1 if SchName == "Coweta Charter Academy"
replace Virtual = 0 if SchName == "Coweta Charter Academy"
replace NCESSchoolID = "130023904226" if SchName == "Cirrus Charter Academy"
replace SchoolLevel = 1 if SchName == "Cirrus Charter Academy"
replace SchoolType = 1 if SchName == "Cirrus Charter Academy"
replace Charter = 1 if SchName == "Cirrus Charter Academy"
replace Virtual = 0 if SchName == "Cirrus Charter Academy"
replace NCESSchoolID = "130022604023" if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchoolLevel = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchoolType = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace Charter = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace Virtual = 0 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace NCESSchoolID = "130024304253" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchoolLevel = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchoolType = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace Charter = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace Virtual = 0 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace NCESSchoolID = "130024204249" if SchName == "Brookhaven Innovation Academy"
replace SchoolLevel = 1 if SchName == "Brookhaven Innovation Academy"
replace SchoolType = 1 if SchName == "Brookhaven Innovation Academy"
replace Charter = 1 if SchName == "Brookhaven Innovation Academy"
replace Virtual = 0 if SchName == "Brookhaven Innovation Academy"
replace NCESSchoolID = "130023404179" if SchName == "International Charter School of Atlanta"
replace SchoolLevel = 1 if SchName == "International Charter School of Atlanta"
replace SchoolType = 1 if SchName == "International Charter School of Atlanta"
replace Charter = 1 if SchName == "International Charter School of Atlanta"
replace Virtual = 0 if SchName == "International Charter School of Atlanta"
replace NCESSchoolID = "130024104229" if SchName == "Liberty Tech Charter Academy"
replace SchoolLevel = 1 if SchName == "Liberty Tech Charter Academy"
replace SchoolType = 1 if SchName == "Liberty Tech Charter Academy"
replace Charter = 1 if SchName == "Liberty Tech Charter Academy"
replace Virtual = 0 if SchName == "Liberty Tech Charter Academy"
replace NCESSchoolID = "130023604192" if SchName == "Scintilla Charter Academy"
replace SchoolLevel = 1 if SchName == "Scintilla Charter Academy"
replace SchoolType = 1 if SchName == "Scintilla Charter Academy"
replace Charter = 1 if SchName == "Scintilla Charter Academy"
replace Virtual = 0 if SchName == "Scintilla Charter Academy"
replace NCESSchoolID = "130023804205" if SchName == "Georgia School for Innovation and the Classics"
replace SchoolLevel = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchoolType = 1 if SchName == "Georgia School for Innovation and the Classics"
replace Charter = 1 if SchName == "Georgia School for Innovation and the Classics"
replace Virtual = 0 if SchName == "Georgia School for Innovation and the Classics"
replace NCESSchoolID = "130023704193" if SchName == "Dubois Integrity Academy I"
replace SchoolLevel = 1 if SchName == "Dubois Integrity Academy I"
replace SchoolType = 1 if SchName == "Dubois Integrity Academy I"
replace Charter = 1 if SchName == "Dubois Integrity Academy I"
replace Virtual = 0 if SchName == "Dubois Integrity Academy I"
replace NCESSchoolID = "130024804288" if SchName == "Genesis Innovation Academy for Boys"
replace SchoolLevel = 1 if SchName == "Genesis Innovation Academy for Boys"
replace SchoolType = 1 if SchName == "Genesis Innovation Academy for Boys"
replace Charter = 1 if SchName == "Genesis Innovation Academy for Boys"
replace Virtual = 0 if SchName == "Genesis Innovation Academy for Boys"
replace NCESSchoolID = "130024404272" if SchName == "Genesis Innovation Academy for Girls"
replace SchoolLevel = 1 if SchName == "Genesis Innovation Academy for Girls"
replace SchoolType = 1 if SchName == "Genesis Innovation Academy for Girls"
replace Charter = 1 if SchName == "Genesis Innovation Academy for Girls"
replace Virtual = 0 if SchName == "Genesis Innovation Academy for Girls"
replace NCESSchoolID = "130024704283" if SchName == "Resurgence Hall Charter School"
replace SchoolLevel = 1 if SchName == "Resurgence Hall Charter School"
replace SchoolType = 1 if SchName == "Resurgence Hall Charter School"
replace Charter = 1 if SchName == "Resurgence Hall Charter School"
replace Virtual = 0 if SchName == "Resurgence Hall Charter School"
replace NCESSchoolID = "130024504293" if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchoolLevel = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchoolType = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace Charter = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace Virtual = 0 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace NCESSchoolID = "130024904273" if SchName == "International Academy of Smyrna"
replace SchoolLevel = 1 if SchName == "International Academy of Smyrna"
replace SchoolType = 1 if SchName == "International Academy of Smyrna"
replace Charter = 1 if SchName == "International Academy of Smyrna"
replace Virtual = 0 if SchName == "International Academy of Smyrna"
replace NCESSchoolID = "130022503061" if SchName == "Atlanta Area School for the Deaf"
replace NCESDistrictID = "1300225" if DistName == "State Schools- Atlanta Area School for the Deaf"
replace SchoolLevel = 4 if SchName == "Atlanta Area School for the Deaf"
replace SchoolType = 2 if SchName == "Atlanta Area School for the Deaf"
replace Charter = 0 if SchName == "Atlanta Area School for the Deaf"
replace Virtual = 0 if SchName == "Atlanta Area School for the Deaf"
replace CountyCode = 13089 if DistName == "State Schools- Atlanta Area School for the Deaf"
replace CountyName = "DeKalb County" if DistName == "State Schools- Atlanta Area School for the Deaf"
replace NCESSchoolID = "130022403062" if SchName == "Georgia Academy for the Blind"
replace NCESDistrictID = "1300224" if DistName == "State Schools- Georgia Academy for the Blind"
replace SchoolLevel = 4 if SchName == "Georgia Academy for the Blind"
replace SchoolType = 2 if SchName == "Georgia Academy for the Blind"
replace Charter = 0 if SchName == "Georgia Academy for the Blind"
replace Virtual = 0 if SchName == "Georgia Academy for the Blind"
replace CountyCode = 13021 if DistName == "State Schools- Georgia Academy for the Blind"
replace CountyName = "Bibb County" if DistName == "State Schools- Georgia Academy for the Blind"
replace NCESSchoolID = "130022303063" if SchName == "Georgia School for the Deaf"
replace NCESDistrictID = "1300223" if DistName == "State Schools- Georgia School for the Deaf"
replace Charter = 0 if SchName == "Georgia School for the Deaf"
replace Virtual = 0 if SchName == "Georgia School for the Deaf"
replace CountyCode = 13115 if DistName == "State Schools- Georgia School for the Deaf"
replace CountyName = "Floyd County" if DistName == "State Schools- Georgia School for the Deaf"

replace NCESSchoolID = "Missing" if SchName == "CCAT School"
replace NCESSchoolID = "Missing" if SchName == "Ivy Preparatory Academy School"


//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistrictType "District type as defined by NCES"
label var Charter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"
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

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "$GAdata/GA_AssmtData_2018", replace
export delimited "$GAdata/GA_AssmtData_2018", replace
clear

//2018-2019
import delimited "$GAdata/GA_OriginalData_2019_all.csv", clear

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
rename begin_cnt Lev1_count
rename begin_pct Lev1_percent
rename developing_cnt Lev2_count
rename developing_pct Lev2_percent
rename proficient_cnt Lev3_count
rename proficient_pct Lev3_percent
rename distinguished_cnt Lev4_count
rename distinguished_pct Lev4_percent

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "State" if StateAssignedDistID == "ALL"
gen AvgScaleScore =.
gen Lev5_count = "--"
gen Lev5_percent = "--"

//Groups & SubGroups
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Asian"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Black or African American"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "White"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

gen StudentSubGroup_TotalTested = num_tested_cnt
destring num_tested_cnt, replace force
replace num_tested_cnt = -1000000 if num_tested_cnt == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(num_tested_cnt)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop num_tested_cnt

//Missing & Suppressed Data
replace Lev1_count = "--" if Lev1_count == ""
replace Lev1_count = "*" if Lev1_count == "TFS"
replace Lev2_count = "--" if Lev2_count == ""
replace Lev2_count = "*" if Lev2_count == "TFS"
replace Lev3_count = "--" if Lev3_count == ""
replace Lev3_count = "*" if Lev3_count == "TFS"
replace Lev4_count = "--" if Lev4_count == ""
replace Lev4_count = "*" if Lev4_count == "TFS"

//Passing Rates
gen Proficient_Count = Lev3_count
gen Distinguished_Count = Lev4_count
destring Proficient_Count, replace force
destring Distinguished_Count, replace force

gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Proficient_Count + Distinguished_Count if Proficient_Count !=. & Distinguished_Count !=.
drop Proficient_Count Distinguished_Count
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent

replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen ParticipationRate =.

//Missing Data (Part II)
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev3_count == "--"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev4_count == "--"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev3_count == "*"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev4_count == "*"
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace Lev4_percent = "--" if Lev4_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Grade Levels
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

//Subject Areas
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

//Statewide Data
replace SchName = "Statewide" if DataLevel == "State"
replace DistName = "Statewide" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace SchName = "Districtwide" if DataLevel == "District"
replace StateAssignedSchID = "" if DataLevel != "School"

save "$GAdata/GA_AssmtData_2019.dta", replace

//Clean NCES Data
use "$NCES/NCES Data Prior to 2020-21/NCES_2018_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
gen str StateAssignedSchID = substr(seasch, 5, 8)
drop seasch
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2019_School_GA.dta", replace

use "$NCES/NCES Data Prior to 2020-21/NCES_2018_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/NCES Data Prior to 2020-21/NCES_2019_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2019.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2019_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/NCES Data Prior to 2020-21/NCES_2019_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistrictType
rename charter Charter
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel

drop state_name year _merge merge2

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

//Unmerged Schools
replace NCESSchoolID = "130002303482" if SchName == "Odyssey School"
replace SchoolLevel = 1 if SchName == "Odyssey School"
replace SchoolType = 1 if SchName == "Odyssey School"
replace Charter = 1 if SchName == "Odyssey School"
replace Virtual = 0 if SchName == "Odyssey School"
replace NCESSchoolID = "130023204148" if SchName == "Georgia Cyber Academy"
replace SchoolLevel = 4 if SchName == "Georgia Cyber Academy"
replace SchoolType = 1 if SchName == "Georgia Cyber Academy"
replace Charter = 1 if SchName == "Georgia Cyber Academy"
replace Virtual = 1 if SchName == "Georgia Cyber Academy"
replace NCESSchoolID = "130023304164" if SchName == "Utopian Academy for the Arts Charter School"
replace SchoolLevel = 2 if SchName == "Utopian Academy for the Arts Charter School"
replace SchoolType = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace Charter = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace Virtual = 0 if SchName == "Utopian Academy for the Arts Charter School"
replace NCESSchoolID = "130021803964" if SchName == "Pataula Charter Academy"
replace SchoolLevel = 4 if SchName == "Pataula Charter Academy"
replace SchoolType = 1 if SchName == "Pataula Charter Academy"
replace Charter = 1 if SchName == "Pataula Charter Academy"
replace Virtual = 0 if SchName == "Pataula Charter Academy"
replace NCESSchoolID = "130023004051" if SchName == "Cherokee Charter Academy"
replace SchoolLevel = 1 if SchName == "Cherokee Charter Academy"
replace SchoolType = 1 if SchName == "Cherokee Charter Academy"
replace Charter = 1 if SchName == "Cherokee Charter Academy"
replace Virtual = 0 if SchName == "Cherokee Charter Academy"
replace NCESSchoolID = "130021703961" if SchName == "Fulton Leadership Academy"
replace SchoolLevel = 4 if SchName == "Fulton Leadership Academy"
replace SchoolType = 1 if SchName == "Fulton Leadership Academy"
replace Charter = 1 if SchName == "Fulton Leadership Academy"
replace Virtual = 0 if SchName == "Fulton Leadership Academy"
replace NCESSchoolID = "130022104021" if SchName == "Atlanta Heights Charter School"
replace SchoolLevel = 1 if SchName == "Atlanta Heights Charter School"
replace SchoolType = 1 if SchName == "Atlanta Heights Charter School"
replace Charter = 1 if SchName == "Atlanta Heights Charter School"
replace Virtual = 0 if SchName == "Atlanta Heights Charter School"
replace NCESSchoolID = "130022704031" if SchName == "Georgia Connections Academy"
replace SchoolLevel = 4 if SchName == "Georgia Connections Academy"
replace SchoolType = 1 if SchName == "Georgia Connections Academy"
replace Charter = 1 if SchName == "Georgia Connections Academy"
replace SchoolType = 1 if SchName == "Georgia Connections Academy"
replace Virtual = 1 if SchName == "Georgia Connections Academy"
replace NCESSchoolID = "130022204007" if SchName == "Coweta Charter Academy"
replace SchoolLevel = 1 if SchName == "Coweta Charter Academy"
replace SchoolType = 1 if SchName == "Coweta Charter Academy"
replace Charter = 1 if SchName == "Coweta Charter Academy"
replace Virtual = 0 if SchName == "Coweta Charter Academy"
replace NCESSchoolID = "130023904226" if SchName == "Cirrus Charter Academy"
replace SchoolLevel = 1 if SchName == "Cirrus Charter Academy"
replace SchoolType = 1 if SchName == "Cirrus Charter Academy"
replace Charter = 1 if SchName == "Cirrus Charter Academy"
replace Virtual = 0 if SchName == "Cirrus Charter Academy"
replace NCESSchoolID = "130022604023" if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchoolLevel = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchoolType = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace Charter = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace Virtual = 0 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace NCESSchoolID = "130024304253" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchoolLevel = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchoolType = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace Charter = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace Virtual = 0 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace NCESSchoolID = "130024204249" if SchName == "Brookhaven Innovation Academy"
replace SchoolLevel = 1 if SchName == "Brookhaven Innovation Academy"
replace SchoolType = 1 if SchName == "Brookhaven Innovation Academy"
replace Charter = 1 if SchName == "Brookhaven Innovation Academy"
replace Virtual = 0 if SchName == "Brookhaven Innovation Academy"
replace NCESSchoolID = "130023404179" if SchName == "International Charter School of Atlanta"
replace SchoolLevel = 1 if SchName == "International Charter School of Atlanta"
replace SchoolType = 1 if SchName == "International Charter School of Atlanta"
replace Charter = 1 if SchName == "International Charter School of Atlanta"
replace Virtual = 0 if SchName == "International Charter School of Atlanta"
replace NCESSchoolID = "130024104229" if SchName == "Liberty Tech Charter Academy"
replace SchoolLevel = 1 if SchName == "Liberty Tech Charter Academy"
replace SchoolType = 1 if SchName == "Liberty Tech Charter Academy"
replace Charter = 1 if SchName == "Liberty Tech Charter Academy"
replace Virtual = 0 if SchName == "Liberty Tech Charter Academy"
replace NCESSchoolID = "130023604192" if SchName == "Scintilla Charter Academy"
replace SchoolLevel = 1 if SchName == "Scintilla Charter Academy"
replace SchoolType = 1 if SchName == "Scintilla Charter Academy"
replace Charter = 1 if SchName == "Scintilla Charter Academy"
replace Virtual = 0 if SchName == "Scintilla Charter Academy"
replace NCESSchoolID = "130023804205" if SchName == "Georgia School for Innovation and the Classics"
replace SchoolLevel = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchoolType = 1 if SchName == "Georgia School for Innovation and the Classics"
replace Charter = 1 if SchName == "Georgia School for Innovation and the Classics"
replace Virtual = 0 if SchName == "Georgia School for Innovation and the Classics"
replace NCESSchoolID = "130023704193" if SchName == "Dubois Integrity Academy I"
replace SchoolLevel = 1 if SchName == "Dubois Integrity Academy I"
replace SchoolType = 1 if SchName == "Dubois Integrity Academy I"
replace Charter = 1 if SchName == "Dubois Integrity Academy I"
replace Virtual = 0 if SchName == "Dubois Integrity Academy I"
replace NCESSchoolID = "130024804288" if SchName == "Genesis Innovation Academy for Boys"
replace SchoolLevel = 1 if SchName == "Genesis Innovation Academy for Boys"
replace SchoolType = 1 if SchName == "Genesis Innovation Academy for Boys"
replace Charter = 1 if SchName == "Genesis Innovation Academy for Boys"
replace Virtual = 0 if SchName == "Genesis Innovation Academy for Boys"
replace NCESSchoolID = "130024404272" if SchName == "Genesis Innovation Academy for Girls"
replace SchoolLevel = 1 if SchName == "Genesis Innovation Academy for Girls"
replace SchoolType = 1 if SchName == "Genesis Innovation Academy for Girls"
replace Charter = 1 if SchName == "Genesis Innovation Academy for Girls"
replace Virtual = 0 if SchName == "Genesis Innovation Academy for Girls"
replace NCESSchoolID = "130024704283" if SchName == "Resurgence Hall Charter School"
replace SchoolLevel = 1 if SchName == "Resurgence Hall Charter School"
replace SchoolType = 1 if SchName == "Resurgence Hall Charter School"
replace Charter = 1 if SchName == "Resurgence Hall Charter School"
replace Virtual = 0 if SchName == "Resurgence Hall Charter School"
replace NCESSchoolID = "130024504293" if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchoolLevel = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchoolType = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace Charter = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace Virtual = 0 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace NCESSchoolID = "130024904273" if SchName == "International Academy of Smyrna"
replace SchoolLevel = 1 if SchName == "International Academy of Smyrna"
replace SchoolType = 1 if SchName == "International Academy of Smyrna"
replace Charter = 1 if SchName == "International Academy of Smyrna"
replace Virtual = 0 if SchName == "International Academy of Smyrna"
replace NCESSchoolID = "130025004325" if SchName == "International Charter Academy of Georgia"
replace SchoolLevel = 1 if SchName == "International Charter Academy of Georgia"
replace SchoolType = 1 if SchName == "International Charter Academy of Georgia"
replace Charter = 1 if SchName == "International Charter Academy of Georgia"
replace Virtual = 0 if SchName == "International Charter Academy of Georgia"
replace NCESSchoolID = "130025104306" if SchName == "SLAM Academy of Atlanta"
replace SchoolLevel = 1 if SchName == "SLAM Academy of Atlanta"
replace SchoolType = 1 if SchName == "SLAM Academy of Atlanta"
replace Charter = 1 if SchName == "SLAM Academy of Atlanta"
replace Virtual = 0 if SchName == "SLAM Academy of Atlanta"
replace NCESSchoolID = "130022503061" if SchName == "Atlanta Area School for the Deaf"
replace NCESDistrictID = "1300225" if DistName == "State Schools- Atlanta Area School for the Deaf"
replace SchoolLevel = 4 if SchName == "Atlanta Area School for the Deaf"
replace SchoolType = 2 if SchName == "Atlanta Area School for the Deaf"
replace Charter = 0 if SchName == "Atlanta Area School for the Deaf"
replace Virtual = 0 if SchName == "Atlanta Area School for the Deaf"
replace CountyCode = 13089 if DistName == "State Schools- Atlanta Area School for the Deaf"
replace CountyName = "DeKalb County" if DistName == "State Schools- Atlanta Area School for the Deaf"
replace NCESSchoolID = "130022403062" if SchName == "Georgia Academy for the Blind"
replace NCESDistrictID = "1300224" if DistName == "State Schools- Georgia Academy for the Blind"
replace SchoolLevel = 4 if SchName == "Georgia Academy for the Blind"
replace SchoolType = 2 if SchName == "Georgia Academy for the Blind"
replace Charter = 0 if SchName == "Georgia Academy for the Blind"
replace Virtual = 0 if SchName == "Georgia Academy for the Blind"
replace CountyCode = 13021 if DistName == "State Schools- Georgia Academy for the Blind"
replace CountyName = "Bibb County" if DistName == "State Schools- Georgia Academy for the Blind"
replace NCESSchoolID = "130022303063" if SchName == "Georgia School for the Deaf"
replace NCESDistrictID = "1300223" if DistName == "State Schools- Georgia School for the Deaf"
replace Charter = 0 if SchName == "Georgia School for the Deaf"
replace Virtual = 0 if SchName == "Georgia School for the Deaf"
replace CountyCode = 13115 if DistName == "State Schools- Georgia School for the Deaf"
replace CountyName = "Floyd County" if DistName == "State Schools- Georgia School for the Deaf"

replace NCESSchoolID = "Missing" if SchName == "CCAT School"

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistrictType "District type as defined by NCES"
label var Charter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"
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

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "$GAdata/GA_AssmtData_2019", replace
export delimited "$GAdata/GA_AssmtData_2019", replace
clear

//2020-2021
import delimited "$GAdata/GA_OriginalData_2021_all.csv", clear

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
rename begin_cnt Lev1_count
rename begin_pct Lev1_percent
rename developing_cnt Lev2_count
rename developing_pct Lev2_percent
rename proficient_cnt Lev3_count
rename proficient_pct Lev3_percent
rename distinguished_cnt Lev4_count
rename distinguished_pct Lev4_percent

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "State" if StateAssignedDistID == "ALL"
gen AvgScaleScore =.
gen Lev5_count = "--"
gen Lev5_percent = "--"

//Groups & SubGroups
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Asian"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Black or African American"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "White"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

replace SchName = DistName + " District Total" if DataLevel == "District"

gen StudentSubGroup_TotalTested = num_tested_cnt
destring num_tested_cnt, replace force
replace num_tested_cnt = -1000000 if num_tested_cnt == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(num_tested_cnt)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop num_tested_cnt

//Missing & Suppressed Data
replace Lev1_count = "--" if Lev1_count == ""
replace Lev1_count = "*" if Lev1_count == "TFS"
replace Lev2_count = "--" if Lev2_count == ""
replace Lev2_count = "*" if Lev2_count == "TFS"
replace Lev3_count = "--" if Lev3_count == ""
replace Lev3_count = "*" if Lev3_count == "TFS"
replace Lev4_count = "--" if Lev4_count == ""
replace Lev4_count = "*" if Lev4_count == "TFS"

//Passing Rates
gen Proficient_Count = Lev3_count
gen Distinguished_Count = Lev4_count
destring Proficient_Count, replace force
destring Distinguished_Count, replace force

gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Proficient_Count + Distinguished_Count if Proficient_Count !=. & Distinguished_Count !=.
drop Proficient_Count Distinguished_Count

destring Lev1_percent, replace force
destring Lev2_percent, replace force
destring Lev3_percent, replace force
destring Lev4_percent, replace force

gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent

replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen ParticipationRate =.

//Missing Data (Part II)
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev3_count == "--"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev4_count == "--"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev3_count == "*"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev4_count == "*"
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace Lev4_percent = "--" if Lev4_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Grade Levels
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

//Subject Areas
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

//Statewide Data
replace SchName = "Statewide" if DataLevel == "State"
replace DistName = "Statewide" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace SchName = "Districtwide" if DataLevel == "District"
replace StateAssignedSchID = "" if DataLevel != "School"

save "$GAdata/GA_AssmtData_2021.dta", replace

//Clean NCES Data
use "$NCES/NCES Data Prior to 2020-21/NCES_2020_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
gen str StateAssignedSchID = substr(seasch, 5, 8)
drop seasch
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/NCES_2021_School_GA.dta", replace

use "$NCES/NCES Data Prior to 2020-21/NCES_2020_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/NCES_2021_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2021.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/NCES_2021_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/NCES_2021_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistrictType
rename charter Charter
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel

drop state_name year _merge merge2

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

//Unmerged Schools
replace NCESSchoolID = "130002303482" if SchName == "Odyssey School"
replace SchoolLevel = 1 if SchName == "Odyssey School"
replace SchoolType = 1 if SchName == "Odyssey School"
replace Charter = 1 if SchName == "Odyssey School"
replace Virtual = 0 if SchName == "Odyssey School"
replace NCESSchoolID = "130023204148" if SchName == "Georgia Cyber Academy"
replace SchoolLevel = 4 if SchName == "Georgia Cyber Academy"
replace SchoolType = 1 if SchName == "Georgia Cyber Academy"
replace Charter = 1 if SchName == "Georgia Cyber Academy"
replace Virtual = 1 if SchName == "Georgia Cyber Academy"
replace NCESSchoolID = "130023304164" if SchName == "Utopian Academy for the Arts Charter School"
replace SchoolLevel = 2 if SchName == "Utopian Academy for the Arts Charter School"
replace SchoolType = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace Charter = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace Virtual = 0 if SchName == "Utopian Academy for the Arts Charter School"
replace NCESSchoolID = "130021803964" if SchName == "Pataula Charter Academy"
replace SchoolLevel = 4 if SchName == "Pataula Charter Academy"
replace SchoolType = 1 if SchName == "Pataula Charter Academy"
replace Charter = 1 if SchName == "Pataula Charter Academy"
replace Virtual = 0 if SchName == "Pataula Charter Academy"
replace NCESSchoolID = "130023004051" if SchName == "Cherokee Charter Academy"
replace SchoolLevel = 1 if SchName == "Cherokee Charter Academy"
replace SchoolType = 1 if SchName == "Cherokee Charter Academy"
replace Charter = 1 if SchName == "Cherokee Charter Academy"
replace Virtual = 0 if SchName == "Cherokee Charter Academy"
replace NCESSchoolID = "130021703961" if SchName == "Fulton Leadership Academy"
replace SchoolLevel = 4 if SchName == "Fulton Leadership Academy"
replace SchoolType = 1 if SchName == "Fulton Leadership Academy"
replace Charter = 1 if SchName == "Fulton Leadership Academy"
replace Virtual = 0 if SchName == "Fulton Leadership Academy"
replace NCESSchoolID = "130022104021" if SchName == "Atlanta Heights Charter School"
replace SchoolLevel = 1 if SchName == "Atlanta Heights Charter School"
replace SchoolType = 1 if SchName == "Atlanta Heights Charter School"
replace Charter = 1 if SchName == "Atlanta Heights Charter School"
replace Virtual = 0 if SchName == "Atlanta Heights Charter School"
replace NCESSchoolID = "130022704031" if SchName == "Georgia Connections Academy"
replace SchoolLevel = 4 if SchName == "Georgia Connections Academy"
replace SchoolType = 1 if SchName == "Georgia Connections Academy"
replace Charter = 1 if SchName == "Georgia Connections Academy"
replace SchoolType = 1 if SchName == "Georgia Connections Academy"
replace Virtual = 1 if SchName == "Georgia Connections Academy"
replace NCESSchoolID = "130022204007" if SchName == "Coweta Charter Academy"
replace SchoolLevel = 1 if SchName == "Coweta Charter Academy"
replace SchoolType = 1 if SchName == "Coweta Charter Academy"
replace Charter = 1 if SchName == "Coweta Charter Academy"
replace Virtual = 0 if SchName == "Coweta Charter Academy"
replace NCESSchoolID = "130023904226" if SchName == "Cirrus Charter Academy"
replace SchoolLevel = 1 if SchName == "Cirrus Charter Academy"
replace SchoolType = 1 if SchName == "Cirrus Charter Academy"
replace Charter = 1 if SchName == "Cirrus Charter Academy"
replace Virtual = 0 if SchName == "Cirrus Charter Academy"
replace NCESSchoolID = "130022604023" if SchName == "Ivy Preparatory Academy, Inc"
replace SchoolLevel = 1 if SchName == "Ivy Preparatory Academy, Inc"
replace SchoolType = 1 if SchName == "Ivy Preparatory Academy, Inc"
replace Charter = 1 if SchName == "Ivy Preparatory Academy, Inc"
replace Virtual = 0 if SchName == "Ivy Preparatory Academy, Inc"
replace NCESSchoolID = "130024304253" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchoolLevel = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchoolType = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace Charter = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace Virtual = 0 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace NCESSchoolID = "130024204249" if SchName == "Brookhaven Innovation Academy"
replace SchoolLevel = 1 if SchName == "Brookhaven Innovation Academy"
replace SchoolType = 1 if SchName == "Brookhaven Innovation Academy"
replace Charter = 1 if SchName == "Brookhaven Innovation Academy"
replace Virtual = 0 if SchName == "Brookhaven Innovation Academy"
replace NCESSchoolID = "130023404179" if SchName == "International Charter School of Atlanta"
replace SchoolLevel = 1 if SchName == "International Charter School of Atlanta"
replace SchoolType = 1 if SchName == "International Charter School of Atlanta"
replace Charter = 1 if SchName == "International Charter School of Atlanta"
replace Virtual = 0 if SchName == "International Charter School of Atlanta"
replace NCESSchoolID = "130024104229" if SchName == "Liberty Tech Charter Academy"
replace SchoolLevel = 1 if SchName == "Liberty Tech Charter Academy"
replace SchoolType = 1 if SchName == "Liberty Tech Charter Academy"
replace Charter = 1 if SchName == "Liberty Tech Charter Academy"
replace Virtual = 0 if SchName == "Liberty Tech Charter Academy"
replace NCESSchoolID = "130023604192" if SchName == "Scintilla Charter Academy"
replace SchoolLevel = 1 if SchName == "Scintilla Charter Academy"
replace SchoolType = 1 if SchName == "Scintilla Charter Academy"
replace Charter = 1 if SchName == "Scintilla Charter Academy"
replace Virtual = 0 if SchName == "Scintilla Charter Academy"
replace NCESSchoolID = "130023804205" if SchName == "Georgia School for Innovation and the Classics"
replace SchoolLevel = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchoolType = 1 if SchName == "Georgia School for Innovation and the Classics"
replace Charter = 1 if SchName == "Georgia School for Innovation and the Classics"
replace Virtual = 0 if SchName == "Georgia School for Innovation and the Classics"
replace NCESSchoolID = "130023704193" if SchName == "Dubois Integrity Academy I"
replace SchoolLevel = 1 if SchName == "Dubois Integrity Academy I"
replace SchoolType = 1 if SchName == "Dubois Integrity Academy I"
replace Charter = 1 if SchName == "Dubois Integrity Academy I"
replace Virtual = 0 if SchName == "Dubois Integrity Academy I"
replace NCESSchoolID = "130024804288" if SchName == "Genesis Innovation Academy for Boys"
replace SchoolLevel = 1 if SchName == "Genesis Innovation Academy for Boys"
replace SchoolType = 1 if SchName == "Genesis Innovation Academy for Boys"
replace Charter = 1 if SchName == "Genesis Innovation Academy for Boys"
replace Virtual = 0 if SchName == "Genesis Innovation Academy for Boys"
replace NCESSchoolID = "130024404272" if SchName == "Genesis Innovation Academy for Girls"
replace SchoolLevel = 1 if SchName == "Genesis Innovation Academy for Girls"
replace SchoolType = 1 if SchName == "Genesis Innovation Academy for Girls"
replace Charter = 1 if SchName == "Genesis Innovation Academy for Girls"
replace Virtual = 0 if SchName == "Genesis Innovation Academy for Girls"
replace NCESSchoolID = "130024704283" if SchName == "Resurgence Hall Charter School"
replace SchoolLevel = 1 if SchName == "Resurgence Hall Charter School"
replace SchoolType = 1 if SchName == "Resurgence Hall Charter School"
replace Charter = 1 if SchName == "Resurgence Hall Charter School"
replace Virtual = 0 if SchName == "Resurgence Hall Charter School"
replace NCESSchoolID = "130024504293" if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchoolLevel = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchoolType = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace Charter = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace Virtual = 0 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace NCESSchoolID = "130024904273" if SchName == "International Academy of Smyrna"
replace SchoolLevel = 1 if SchName == "International Academy of Smyrna"
replace SchoolType = 1 if SchName == "International Academy of Smyrna"
replace Charter = 1 if SchName == "International Academy of Smyrna"
replace Virtual = 0 if SchName == "International Academy of Smyrna"
replace NCESSchoolID = "130025004325" if SchName == "International Charter Academy of Georgia"
replace SchoolLevel = 1 if SchName == "International Charter Academy of Georgia"
replace SchoolType = 1 if SchName == "International Charter Academy of Georgia"
replace Charter = 1 if SchName == "International Charter Academy of Georgia"
replace Virtual = 0 if SchName == "International Charter Academy of Georgia"
replace NCESSchoolID = "130025104306" if SchName == "SLAM Academy of Atlanta"
replace SchoolLevel = 1 if SchName == "SLAM Academy of Atlanta"
replace SchoolType = 1 if SchName == "SLAM Academy of Atlanta"
replace Charter = 1 if SchName == "SLAM Academy of Atlanta"
replace Virtual = 0 if SchName == "SLAM Academy of Atlanta"
replace NCESSchoolID = "130000502626" if SchName == "Statesboro STEAM Academy"
replace SchoolLevel = 3 if SchName == "Statesboro STEAM Academy"
replace SchoolType = 1 if SchName == "Statesboro STEAM Academy"
replace Charter = 1 if SchName == "Statesboro STEAM Academy"
replace Virtual = 0 if SchName == "Statesboro STEAM Academy"
replace NCESSchoolID = "130025204345" if SchName == "Academy For Classical Education"
replace SchoolLevel = 4 if SchName == "Academy For Classical Education"
replace SchoolType = 1 if SchName == "Academy For Classical Education"
replace Charter = 1 if SchName == "Academy For Classical Education"
replace Virtual = 0 if SchName == "Academy For Classical Education"
replace NCESSchoolID = "130025304349" if SchName == "Spring Creek Charter Academy"
replace SchoolLevel = 1 if SchName == "Spring Creek Charter Academy"
replace SchoolType = 1 if SchName == "Spring Creek Charter Academy"
replace Charter = 1 if SchName == "Spring Creek Charter Academy"
replace Virtual = 0 if SchName == "Spring Creek Charter Academy"
replace NCESSchoolID = "130025704372" if SchName == "Yi Hwang Academy of Language Excellence"
replace SchoolLevel = 1 if SchName == "Yi Hwang Academy of Language Excellence"
replace SchoolType = 1 if SchName == "Yi Hwang Academy of Language Excellence"
replace Charter = 1 if SchName == "Yi Hwang Academy of Language Excellence"
replace Virtual = 0 if SchName == "Yi Hwang Academy of Language Excellence"
replace NCESSchoolID = "130025804373" if SchName == "Furlow Charter School"
replace SchoolLevel = 4 if SchName == "Furlow Charter School"
replace SchoolType = 1 if SchName == "Furlow Charter School"
replace Charter = 1 if SchName == "Furlow Charter School"
replace Virtual = 0 if SchName == "Furlow Charter School"
replace NCESSchoolID = "130025504332" if SchName == "Ethos Classical Charter School"
replace SchoolLevel = 1 if SchName == "Ethos Classical Charter School"
replace SchoolType = 1 if SchName == "Ethos Classical Charter School"
replace Charter = 1 if SchName == "Ethos Classical Charter School"
replace Virtual = 0 if SchName == "Ethos Classical Charter School"
replace NCESSchoolID = "130025604363" if SchName == "Baconton Community Charter School"
replace SchoolLevel = 4 if SchName == "Baconton Community Charter School"
replace SchoolType = 1 if SchName == "Baconton Community Charter School"
replace Charter = 1 if SchName == "Baconton Community Charter School"
replace Virtual = 0 if SchName == "Baconton Community Charter School"
replace NCESSchoolID = "130026104376" if SchName == "Atlanta Unbound Academy"
replace SchoolLevel = 1 if SchName == "Atlanta Unbound Academy"
replace SchoolType = 1 if SchName == "Atlanta Unbound Academy"
replace Charter = 1 if SchName == "Atlanta Unbound Academy"
replace Virtual = 0 if SchName == "Atlanta Unbound Academy"
replace NCESSchoolID = "130026204377" if SchName == "D.E.L.T.A. STEAM Academy"
replace SchoolLevel = 1 if SchName == "D.E.L.T.A. STEAM Academy"
replace SchoolType = 1 if SchName == "D.E.L.T.A. STEAM Academy"
replace Charter = 1 if SchName == "D.E.L.T.A. STEAM Academy"
replace Virtual = 0 if SchName == "D.E.L.T.A. STEAM Academy"
replace NCESSchoolID = "130026304378" if SchName == "Georgia Fugees Academy Charter School"
replace SchoolLevel = 3 if SchName == "Georgia Fugees Academy Charter School"
replace SchoolType = 1 if SchName == "Georgia Fugees Academy Charter School"
replace Charter = 1 if SchName == "Georgia Fugees Academy Charter School"
replace Virtual = 0 if SchName == "Georgia Fugees Academy Charter School"

replace NCESSchoolID = "Missing" if SchName == "Harriet Tubman School of Science & Technology"

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistrictType "District type as defined by NCES"
label var Charter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"
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

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "$GAdata/GA_AssmtData_2021", replace
export delimited "$GAdata/GA_AssmtData_2021", replace
clear

//2021-2022
import delimited "$GAdata/GA_OriginalData_2022_all.csv", clear

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
rename begin_cnt Lev1_count
rename begin_pct Lev1_percent
rename developing_cnt Lev2_count
rename developing_pct Lev2_percent
rename proficient_cnt Lev3_count
rename proficient_pct Lev3_percent
rename distinguished_cnt Lev4_count
rename distinguished_pct Lev4_percent

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "State" if StateAssignedDistID == "ALL"
gen AvgScaleScore =.
gen Lev5_count = "--"
gen Lev5_percent = "--"

//Groups & SubGroups
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Asian"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Black or African American"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "White"
replace StudentGroup = "Race/Ethnicity" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

replace SchName = DistName + " District Total" if DataLevel == "District"

gen StudentSubGroup_TotalTested = num_tested_cnt
destring num_tested_cnt, replace force
replace num_tested_cnt = -1000000 if num_tested_cnt == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(num_tested_cnt)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop num_tested_cnt

//Missing & Suppressed Data
replace Lev1_count = "--" if Lev1_count == ""
replace Lev1_count = "*" if Lev1_count == "TFS"
replace Lev2_count = "--" if Lev2_count == ""
replace Lev2_count = "*" if Lev2_count == "TFS"
replace Lev3_count = "--" if Lev3_count == ""
replace Lev3_count = "*" if Lev3_count == "TFS"
replace Lev4_count = "--" if Lev4_count == ""
replace Lev4_count = "*" if Lev4_count == "TFS"

//Passing Rates
gen Proficient_Count = Lev3_count
gen Distinguished_Count = Lev4_count
destring Proficient_Count, replace force
destring Distinguished_Count, replace force

gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Proficient_Count + Distinguished_Count if Proficient_Count !=. & Distinguished_Count !=.
drop Proficient_Count Distinguished_Count

destring Lev1_percent, replace force
destring Lev2_percent, replace force
destring Lev3_percent, replace force
destring Lev4_percent, replace force

gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent

replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen ParticipationRate =.

//Missing Data (Part II)
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev3_count == "--"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev4_count == "--"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev3_count == "*"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev4_count == "*"
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace Lev4_percent = "--" if Lev4_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Grade Levels
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

//Subject Areas
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

//Statewide Data
replace SchName = "Statewide" if DataLevel == "State"
replace DistName = "Statewide" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace SchName = "Districtwide" if DataLevel == "District"
replace StateAssignedSchID = "" if DataLevel != "School"

save "$GAdata/GA_AssmtData_2022.dta", replace

//Clean NCES Data
use "${NCES}/NCES_2021_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
gen str StateAssignedSchID = substr(st_schid, 8, 12)
drop st_schid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/NCES_2022_School_GA.dta", replace

import delimited "${NCES}/NCES_2021_District.csv", clear
drop if stateabbrev != "GA"
rename distname DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/NCES_2022_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2022.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/NCES_2022_District_GA.dta"
drop if _merge == 2
drop charter

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/NCES_2022_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename districttype DistrictType
rename charter Charter
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel

gen State = "Georgia"
gen StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

drop state_location state_name year school_name urban_centric_locale school_status lowest_grade_offered highest_grade_offered bureau_indian_education lunch_program free_lunch reduced_price_lunch free_or_reduced_price_lunch enrollment schid state stateabbrev statefips countyname countycode schyear updated_status_text effective_date _merge merge2

//Unmerged Schools
replace NCESSchoolID = "130026404424" if SchName == "Northwest Classical Academy"
replace SchoolLevel = "Elementary" if SchName == "Northwest Classical Academy"
replace SchoolType = "Regular School" if SchName == "Northwest Classical Academy"
replace Charter = "Yes" if SchName == "Northwest Classical Academy"
replace NCESSchoolID = "130025904374" if SchName == "Atlanta SMART Academy"
replace SchoolLevel = "Middle" if SchName == "Atlanta SMART Academy"
replace SchoolType = "Regular School" if SchName == "Atlanta SMART Academy"
replace Charter = "Yes" if SchName == "Atlanta SMART Academy"
replace NCESSchoolID = "130002303482" if SchName == "Odyssey School"
replace SchoolLevel = "Elementary" if SchName == "Odyssey School"
replace SchoolType = "Regular School" if SchName == "Odyssey School"
replace Charter = "Yes" if SchName == "Odyssey School"
replace NCESSchoolID = "130023204148" if SchName == "Georgia Cyber Academy"
replace SchoolLevel = "Other" if SchName == "Georgia Cyber Academy"
replace SchoolType = "Regular School" if SchName == "Georgia Cyber Academy"
replace Charter = "Yes" if SchName == "Georgia Cyber Academy"
replace NCESSchoolID = "130023304164" if SchName == "Utopian Academy for the Arts Charter School"
replace SchoolLevel = "Middle" if SchName == "Utopian Academy for the Arts Charter School"
replace SchoolType = "Regular School" if SchName == "Utopian Academy for the Arts Charter School"
replace Charter = "Yes" if SchName == "Utopian Academy for the Arts Charter School"
replace NCESSchoolID = "130021803964" if SchName == "Pataula Charter Academy"
replace SchoolLevel = "Other" if SchName == "Pataula Charter Academy"
replace SchoolType = "Regular School" if SchName == "Pataula Charter Academy"
replace Charter = "Yes" if SchName == "Pataula Charter Academy"
replace NCESSchoolID = "130023004051" if SchName == "Cherokee Charter Academy"
replace SchoolLevel = "Elementary" if SchName == "Cherokee Charter Academy"
replace SchoolType = "Regular School" if SchName == "Cherokee Charter Academy"
replace Charter = "Yes" if SchName == "Cherokee Charter Academy"
replace NCESSchoolID = "130021703961" if SchName == "Fulton Leadership Academy"
replace SchoolLevel = "Other" if SchName == "Fulton Leadership Academy"
replace SchoolType = "Regular School" if SchName == "Fulton Leadership Academy"
replace Charter = "Yes" if SchName == "Fulton Leadership Academy"
replace NCESSchoolID = "130022104021" if SchName == "Atlanta Heights Charter School"
replace SchoolLevel = "Elementary" if SchName == "Atlanta Heights Charter School"
replace SchoolType = "Regular School" if SchName == "Atlanta Heights Charter School"
replace Charter = "Yes" if SchName == "Atlanta Heights Charter School"
replace NCESSchoolID = "130022704031" if SchName == "Georgia Connections Academy"
replace SchoolLevel = "Other" if SchName == "Georgia Connections Academy"
replace SchoolType = "Regular School" if SchName == "Georgia Connections Academy"
replace Charter = "Yes" if SchName == "Georgia Connections Academy"
replace SchoolType = "Elementary" if SchName == "Georgia Connections Academy"
replace NCESSchoolID = "130022204007" if SchName == "Coweta Charter Academy"
replace SchoolLevel = "Elementary" if SchName == "Coweta Charter Academy"
replace SchoolType = "Regular School" if SchName == "Coweta Charter Academy"
replace Charter = "Yes" if SchName == "Coweta Charter Academy"
replace NCESSchoolID = "130023904226" if SchName == "Cirrus Charter Academy"
replace SchoolLevel = "Elementary" if SchName == "Cirrus Charter Academy"
replace SchoolType = "Regular School" if SchName == "Cirrus Charter Academy"
replace Charter = "Yes" if SchName == "Cirrus Charter Academy"
replace NCESSchoolID = "130022604023" if SchName == "Ivy Preparatory Academy, Inc"
replace SchoolLevel = "Elementary" if SchName == "Ivy Preparatory Academy, Inc"
replace SchoolType = "Regular School" if SchName == "Ivy Preparatory Academy, Inc"
replace Charter = "Yes" if SchName == "Ivy Preparatory Academy, Inc"
replace NCESSchoolID = "130024304253" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchoolLevel = "Elementary" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchoolType = "Regular School" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace Charter = "Yes" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace NCESSchoolID = "130024204249" if SchName == "Brookhaven Innovation Academy"
replace SchoolLevel = "Elementary" if SchName == "Brookhaven Innovation Academy"
replace SchoolType = "Regular School" if SchName == "Brookhaven Innovation Academy"
replace Charter = "Yes" if SchName == "Brookhaven Innovation Academy"
replace NCESSchoolID = "130023404179" if SchName == "International Charter School of Atlanta"
replace SchoolLevel = "Elementary" if SchName == "International Charter School of Atlanta"
replace SchoolType = "Regular School" if SchName == "International Charter School of Atlanta"
replace Charter = "Yes" if SchName == "International Charter School of Atlanta"
replace NCESSchoolID = "130024104229" if SchName == "Liberty Tech Charter Academy"
replace SchoolLevel = "Elementary" if SchName == "Liberty Tech Charter Academy"
replace SchoolType = "Regular School" if SchName == "Liberty Tech Charter Academy"
replace Charter = "Yes" if SchName == "Liberty Tech Charter Academy"
replace NCESSchoolID = "130023604192" if SchName == "Scintilla Charter Academy"
replace SchoolLevel = "Elementary" if SchName == "Scintilla Charter Academy"
replace SchoolType = "Regular School" if SchName == "Scintilla Charter Academy"
replace Charter = "Yes" if SchName == "Scintilla Charter Academy"
replace NCESSchoolID = "130023804205" if SchName == "Georgia School for Innovation and the Classics"
replace SchoolLevel = "Elementary" if SchName == "Georgia School for Innovation and the Classics"
replace SchoolType = "Regular School" if SchName == "Georgia School for Innovation and the Classics"
replace Charter = "Yes" if SchName == "Georgia School for Innovation and the Classics"
replace NCESSchoolID = "130023704193" if SchName == "Dubois Integrity Academy I"
replace SchoolLevel = "Elementary" if SchName == "Dubois Integrity Academy I"
replace SchoolType = "Regular School" if SchName == "Dubois Integrity Academy I"
replace Charter = "Yes" if SchName == "Dubois Integrity Academy I"
replace NCESSchoolID = "130024804288" if SchName == "Genesis Innovation Academy for Boys"
replace SchoolLevel = "Elementary" if SchName == "Genesis Innovation Academy for Boys"
replace SchoolType = "Regular School" if SchName == "Genesis Innovation Academy for Boys"
replace Charter = "Yes" if SchName == "Genesis Innovation Academy for Boys"
replace NCESSchoolID = "130024404272" if SchName == "Genesis Innovation Academy for Girls"
replace SchoolLevel = "Elementary" if SchName == "Genesis Innovation Academy for Girls"
replace SchoolType = "Regular School" if SchName == "Genesis Innovation Academy for Girls"
replace Charter = "Yes" if SchName == "Genesis Innovation Academy for Girls"
replace NCESSchoolID = "130024704283" if SchName == "Resurgence Hall Charter School"
replace SchoolLevel = "Elementary" if SchName == "Resurgence Hall Charter School"
replace SchoolType = "Regular School" if SchName == "Resurgence Hall Charter School"
replace Charter = "Yes" if SchName == "Resurgence Hall Charter School"
replace NCESSchoolID = "130024504293" if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchoolLevel = "Elementary" if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchoolType = "Regular School" if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace Charter = "Yes" if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace NCESSchoolID = "130024904273" if SchName == "International Academy of Smyrna"
replace SchoolLevel = "Elementary" if SchName == "International Academy of Smyrna"
replace SchoolType = "Regular School" if SchName == "International Academy of Smyrna"
replace Charter = "Yes" if SchName == "International Academy of Smyrna"
replace NCESSchoolID = "130025004325" if SchName == "International Charter Academy of Georgia"
replace SchoolLevel = "Elementary" if SchName == "International Charter Academy of Georgia"
replace SchoolType = "Regular School" if SchName == "International Charter Academy of Georgia"
replace Charter = "Yes" if SchName == "International Charter Academy of Georgia"
replace NCESSchoolID = "130025104306" if SchName == "SLAM Academy of Atlanta"
replace SchoolLevel = "Elementary" if SchName == "SLAM Academy of Atlanta"
replace SchoolType = "Regular School" if SchName == "SLAM Academy of Atlanta"
replace Charter = "Yes" if SchName == "SLAM Academy of Atlanta"
replace NCESSchoolID = "130000502626" if SchName == "Statesboro STEAM Academy"
replace SchoolLevel = "High" if SchName == "Statesboro STEAM Academy"
replace SchoolType = "Regular School" if SchName == "Statesboro STEAM Academy"
replace Charter = "Yes" if SchName == "Statesboro STEAM Academy"
replace NCESSchoolID = "130025204345" if SchName == "Academy For Classical Education"
replace SchoolLevel = "Other" if SchName == "Academy For Classical Education"
replace SchoolType = "Regular School" if SchName == "Academy For Classical Education"
replace Charter = "Yes" if SchName == "Academy For Classical Education"
replace NCESSchoolID = "130025304349" if SchName == "Spring Creek Charter Academy"
replace SchoolLevel = "Elementary" if SchName == "Spring Creek Charter Academy"
replace SchoolType = "Regular School" if SchName == "Spring Creek Charter Academy"
replace Charter = "Yes" if SchName == "Spring Creek Charter Academy"
replace NCESSchoolID = "130025704372" if SchName == "Yi Hwang Academy of Language Excellence"
replace SchoolLevel = "Elementary" if SchName == "Yi Hwang Academy of Language Excellence"
replace SchoolType = "Regular School" if SchName == "Yi Hwang Academy of Language Excellence"
replace Charter = "Yes" if SchName == "Yi Hwang Academy of Language Excellence"
replace NCESSchoolID = "130025804373" if SchName == "Furlow Charter School"
replace SchoolLevel = "Other" if SchName == "Furlow Charter School"
replace SchoolType = "Regular School" if SchName == "Furlow Charter School"
replace Charter = "Yes" if SchName == "Furlow Charter School"
replace NCESSchoolID = "130025504332" if SchName == "Ethos Classical Charter School"
replace SchoolLevel = "Elementary" if SchName == "Ethos Classical Charter School"
replace SchoolType = "Regular School" if SchName == "Ethos Classical Charter School"
replace Charter = "Yes" if SchName == "Ethos Classical Charter School"
replace NCESSchoolID = "130025604363" if SchName == "Baconton Community Charter School"
replace SchoolLevel = "Other" if SchName == "Baconton Community Charter School"
replace SchoolType = "Regular School" if SchName == "Baconton Community Charter School"
replace Charter = "Yes" if SchName == "Baconton Community Charter School"
replace NCESSchoolID = "130026104376" if SchName == "Atlanta Unbound Academy"
replace SchoolLevel = "Elementary" if SchName == "Atlanta Unbound Academy"
replace SchoolType = "Regular School" if SchName == "Atlanta Unbound Academy"
replace Charter = "Yes" if SchName == "Atlanta Unbound Academy"
replace NCESSchoolID = "130026204377" if SchName == "D.E.L.T.A. STEAM Academy"
replace SchoolLevel = "Elementary" if SchName == "D.E.L.T.A. STEAM Academy"
replace SchoolType = "Regular School" if SchName == "D.E.L.T.A. STEAM Academy"
replace Charter = "Yes" if SchName == "D.E.L.T.A. STEAM Academy"
replace NCESSchoolID = "130026304378" if SchName == "Georgia Fugees Academy Charter School"
replace SchoolLevel = "High" if SchName == "Georgia Fugees Academy Charter School"
replace SchoolType = "Regular School" if SchName == "Georgia Fugees Academy Charter School"
replace Charter = "Yes" if SchName == "Georgia Fugees Academy Charter School"

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistrictType "District type as defined by NCES"
label var Charter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"
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

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "$GAdata/GA_AssmtData_2022", replace
export delimited "$GAdata/GA_AssmtData_2022", replace
clear

log close
