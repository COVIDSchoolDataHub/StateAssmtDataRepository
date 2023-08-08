clear all
log using georgia_cleaning.log, replace text

cd "/Users/miramehta/Documents/"
global GAdata "/Users/miramehta/Documents/GA State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

//2010-2011
import delimited "$GAdata/GA_OriginalData_2011_G38_all.csv", clear
gen acdmc_lvl = "G38"
save "$GAdata/GA_OriginalData_2011_G38_all.dta", replace

import delimited "$GAdata/GA_OriginalData_2011_all.csv", clear
tostring acdmc_lvl, replace
append using "$GAdata/GA_OriginalData_2011_G38_all.dta"

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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"
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
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "$GAdata/GA_AssmtData_2011.dta", replace

//Clean NCES Data
use "$NCES/NCES School Files, Fall 1997-Fall 2021/NCES_2010_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/Cleaned NCES Data/NCES_2011_School_GA.dta", replace

use "$NCES/NCES District Files, Fall 1997-Fall 2021/NCES_2010_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/Cleaned NCES Data/NCES_2011_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2011.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2011_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2011_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchType

tostring sch_highest_grade_offered, replace force
tostring sch_lowest_grade_offered, replace force

replace sch_lowest_grade_offered = "K" if sch_lowest_grade_offered == "0"

replace GradeLevel = "G" + sch_lowest_grade_offered + sch_highest_grade_offered if GradeLevel == "G38"

drop if GradeLevel == "G-112"
drop if GradeLevel == "G-13"
drop if GradeLevel == "G-14"
drop if GradeLevel == "G-15"
drop if GradeLevel == "G-16"
drop if GradeLevel == "G-17"
drop if GradeLevel == "G-18"
drop if GradeLevel == "G111"
drop if GradeLevel == "G112"
drop if GradeLevel == "G210"
drop if GradeLevel == "G23"
drop if GradeLevel == "G25"
drop if GradeLevel == "G311"
drop if GradeLevel == "G312"
drop if GradeLevel == "G412"
drop if GradeLevel == "G512"
drop if GradeLevel == "G55"
drop if GradeLevel == "G610"
drop if GradeLevel == "G611"
drop if GradeLevel == "G612"
drop if GradeLevel == "G66"
drop if GradeLevel == "G69"
drop if GradeLevel == "G711"
drop if GradeLevel == "G712"
drop if GradeLevel == "G810"
drop if GradeLevel == "G812"
drop if GradeLevel == "G89"
drop if GradeLevel == "GK12"
drop if GradeLevel == "GK3"
drop if GradeLevel == "GK5"
drop if GradeLevel == "GK6"
drop if GradeLevel == "GK7"
drop if GradeLevel == "GK8"
drop if GradeLevel == "GK9"
drop if GradeLevel == "G.." & SchName == "All Schools"

drop state_name year _merge merge2 agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID

//Unmerged Schools
replace NCESSchoolID = "130022503061" if SchName == "Atlanta Area School for the Deaf"
replace NCESDistrictID = "1300225" if DistName == "State Schools- Atlanta Area School for the Deaf"
replace SchLevel = 4 if SchName == "Atlanta Area School for the Deaf"
replace SchType = 2 if SchName == "Atlanta Area School for the Deaf"
replace DistCharter = "No" if DistName == "State Schools- Atlanta Area School for the Deaf"
replace CountyCode = 13089 if DistName == "State Schools- Atlanta Area School for the Deaf"
replace CountyName = "DeKalb County" if DistName == "State Schools- Atlanta Area School for the Deaf"
replace DistType = 5 if DistName == "State Schools- Atlanta Area School for the Deaf"
drop if GradeLevel == "G.." & SchName == "Atlanta Area School for the Deaf"
replace NCESSchoolID = "130022403062" if SchName == "Georgia Academy for the Blind"
replace NCESDistrictID = "1300224" if DistName == "State Schools- Georgia Academy for the Blind"
replace SchLevel = 4 if SchName == "Georgia Academy for the Blind"
replace SchType = 2 if SchName == "Georgia Academy for the Blind"
replace DistCharter = "No" if DistName == "State Schools- Georgia Academy for the Blind"
replace CountyCode = 13021 if DistName == "State Schools- Georgia Academy for the Blind"
replace CountyName = "Bibb County" if DistName == "State Schools- Georgia Academy for the Blind"
replace DistType = 5 if DistName == "State Schools- Georgia Academy for the Blind"
drop if GradeLevel == "G.." & SchName == "Georgia Academy for the Blind"
replace NCESSchoolID = "130022303063" if SchName == "Georgia School for the Deaf"
replace NCESDistrictID = "1300223" if DistName == "State Schools- Georgia School for the Deaf"
replace SchLevel = 4 if SchName == "Georgia School for the Deaf"
replace SchType = 2 if SchName == "Georgia School for the Deaf"
replace DistCharter = "No" if DistName == "State Schools- Georgia School for the Deaf"
replace CountyCode = 13115 if DistName == "State Schools- Georgia School for the Deaf"
replace CountyName = "Floyd County" if DistName == "State Schools- Georgia School for the Deaf"
replace DistType = 5 if DistName == "State Schools- Georgia School for the Deaf"
drop if GradeLevel == "G.." & SchName == "Georgia School for the Deaf"

//Variable Types
decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen(SchType_s)
drop SchType
rename SchType_s SchType

decode DistType, gen(DistType_s)
drop DistType
rename DistType_s DistType

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistType "District type as defined by NCES"
label var DistCharter "Charter indicator - district"
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

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2011", replace
export delimited "$GAdata/GA_AssmtData_2011", replace
clear

//2011-2012
import delimited "$GAdata/GA_OriginalData_2012_G38_all.csv", clear
gen acdmc_lvl = "G38"
save "$GAdata/GA_OriginalData_2012_G38_all.dta", replace

import delimited "$GAdata/GA_OriginalData_2012_all.csv", clear
tostring acdmc_lvl, replace
append using "$GAdata/GA_OriginalData_2012_G38_all.dta"

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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"
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
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "$GAdata/GA_AssmtData_2012.dta", replace

//Clean NCES Data
use "$NCES/NCES School Files, Fall 1997-Fall 2021/NCES_2011_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/Cleaned NCES Data/NCES_2012_School_GA.dta", replace

use "$NCES/NCES District Files, Fall 1997-Fall 2021/NCES_2011_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/Cleaned NCES Data/NCES_2012_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2012.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2012_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2012_School_GA.dta", gen(merge2)
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

tostring sch_highest_grade_offered, replace force
tostring sch_lowest_grade_offered, replace force

replace sch_lowest_grade_offered = "K" if sch_lowest_grade_offered == "0"

replace GradeLevel = "G" + sch_lowest_grade_offered + sch_highest_grade_offered if GradeLevel == "G38"

drop if GradeLevel == "G-112"
drop if GradeLevel == "G-13"
drop if GradeLevel == "G-14"
drop if GradeLevel == "G-15"
drop if GradeLevel == "G-16"
drop if GradeLevel == "G-17"
drop if GradeLevel == "G-18"
drop if GradeLevel == "G111"
drop if GradeLevel == "G112"
drop if GradeLevel == "G210"
drop if GradeLevel == "G211"
drop if GradeLevel == "G212"
drop if GradeLevel == "G23"
drop if GradeLevel == "G25"
drop if GradeLevel == "G311"
drop if GradeLevel == "G312"
drop if GradeLevel == "G411"
drop if GradeLevel == "G412"
drop if GradeLevel == "G512"
drop if GradeLevel == "G55"
drop if GradeLevel == "G610"
drop if GradeLevel == "G611"
drop if GradeLevel == "G612"
drop if GradeLevel == "G66"
drop if GradeLevel == "G69"
drop if GradeLevel == "G711"
drop if GradeLevel == "G712"
drop if GradeLevel == "G810"
drop if GradeLevel == "G812"
drop if GradeLevel == "G89"
drop if GradeLevel == "GK10"
drop if GradeLevel == "GK11"
drop if GradeLevel == "GK12"
drop if GradeLevel == "GK3"
drop if GradeLevel == "GK4"
drop if GradeLevel == "GK5"
drop if GradeLevel == "GK6"
drop if GradeLevel == "GK7"
drop if GradeLevel == "GK8"
drop if GradeLevel == "GK9"
drop if GradeLevel == "G.." & SchName == "All Schools"

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID

//Variable Types
decode DistType, gen(DistType_s)
drop DistType
rename DistType_s DistType

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen (SchType_s)
drop SchType
rename SchType_s SchType

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

save "$GAdata/GA_AssmtData_2012", replace
export delimited "$GAdata/GA_AssmtData_2012", replace
clear

//2012-2013
import delimited "$GAdata/GA_OriginalData_2013_G38_all.csv", clear
gen acdmc_lvl = "G38"
save "$GAdata/GA_OriginalData_2013_G38_all.dta", replace

import delimited "$GAdata/GA_OriginalData_2013_all.csv", clear
tostring acdmc_lvl, replace
append using "$GAdata/GA_OriginalData_2013_G38_all.dta"

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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"
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
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "$GAdata/GA_AssmtData_2013.dta", replace

//Clean NCES Data
use "/$NCES/NCES School Files, Fall 1997-Fall 2021/NCES_2012_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/Cleaned NCES Data/NCES_2013_School_GA.dta", replace

use "$NCES/NCES District Files, Fall 1997-Fall 2021/NCES_2012_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/Cleaned NCES Data/NCES_2013_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2013.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2013_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2013_School_GA.dta", gen(merge2)
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

tostring sch_highest_grade_offered, replace force
tostring sch_lowest_grade_offered, replace force

replace sch_lowest_grade_offered = "K" if sch_lowest_grade_offered == "0"

replace GradeLevel = "G" + sch_lowest_grade_offered + sch_highest_grade_offered if GradeLevel == "G38"

drop if GradeLevel == "G-112"
drop if GradeLevel == "G-13"
drop if GradeLevel == "G-14"
drop if GradeLevel == "G-15"
drop if GradeLevel == "G-16"
drop if GradeLevel == "G-17"
drop if GradeLevel == "G-18"
drop if GradeLevel == "G111"
drop if GradeLevel == "G112"
drop if GradeLevel == "G210"
drop if GradeLevel == "G211"
drop if GradeLevel == "G212"
drop if GradeLevel == "G23"
drop if GradeLevel == "G25"
drop if GradeLevel == "G311"
drop if GradeLevel == "G312"
drop if GradeLevel == "G410"
drop if GradeLevel == "G411"
drop if GradeLevel == "G412"
drop if GradeLevel == "G512"
drop if GradeLevel == "G55"
drop if GradeLevel == "G610"
drop if GradeLevel == "G611"
drop if GradeLevel == "G612"
drop if GradeLevel == "G66"
drop if GradeLevel == "G69"
drop if GradeLevel == "G711"
drop if GradeLevel == "G712"
drop if GradeLevel == "G810"
drop if GradeLevel == "G812"
drop if GradeLevel == "G89"
drop if GradeLevel == "GK10"
drop if GradeLevel == "GK11"
drop if GradeLevel == "GK12"
drop if GradeLevel == "GK3"
drop if GradeLevel == "GK4"
drop if GradeLevel == "GK5"
drop if GradeLevel == "GK6"
drop if GradeLevel == "GK7"
drop if GradeLevel == "GK8"
drop if GradeLevel == "GK9"
drop if GradeLevel == "G.." & SchName == "All Schools"

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch agency_charter_indicator

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID

//Variable Types
decode DistType, gen(DistType_s)
drop DistType
rename DistType_s DistType

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen (SchType_s)
drop SchType
rename SchType_s SchType

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

save "$GAdata/GA_AssmtData_2013", replace
export delimited "$GAdata/GA_AssmtData_2013", replace
clear

//2013-2014
import delimited "$GAdata/GA_OriginalData_2014_G38_all.csv", clear
gen acdmc_lvl = "G38"
save "$GAdata/GA_OriginalData_2014_G38_all.dta", replace

import delimited "$GAdata/GA_OriginalData_2014_all.csv", clear
tostring acdmc_lvl, replace
append using "$GAdata/GA_OriginalData_2014_G38_all.dta"

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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"
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
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "$GAdata/GA_AssmtData_2014.dta", replace

//Clean NCES Data
use "$NCES/NCES School Files, Fall 1997-Fall 2021/NCES_2013_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/Cleaned NCES Data/NCES_2014_School_GA.dta", replace

use "$NCES/NCES District Files, Fall 1997-Fall 2021/NCES_2013_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/Cleaned NCES Data/NCES_2014_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2014.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/CLeaned NCES Data/NCES_2014_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2014_School_GA.dta", gen(merge2)
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

tostring sch_highest_grade_offered, replace force
tostring sch_lowest_grade_offered, replace force

replace sch_lowest_grade_offered = "K" if sch_lowest_grade_offered == "0"

replace GradeLevel = "G" + sch_lowest_grade_offered + sch_highest_grade_offered if GradeLevel == "G38"

drop if GradeLevel == "G-19"
drop if GradeLevel == "G-112"
drop if GradeLevel == "G-13"
drop if GradeLevel == "G-14"
drop if GradeLevel == "G-15"
drop if GradeLevel == "G-16"
drop if GradeLevel == "G-17"
drop if GradeLevel == "G-18"
drop if GradeLevel == "G-2-2"
drop if GradeLevel == "G111"
drop if GradeLevel == "G112"
drop if GradeLevel == "G210"
drop if GradeLevel == "G211"
drop if GradeLevel == "G212"
drop if GradeLevel == "G23"
drop if GradeLevel == "G24"
drop if GradeLevel == "G25"
drop if GradeLevel == "G311"
drop if GradeLevel == "G312"
drop if GradeLevel == "G410"
drop if GradeLevel == "G411"
drop if GradeLevel == "G412"
drop if GradeLevel == "G511"
drop if GradeLevel == "G512"
drop if GradeLevel == "G55"
drop if GradeLevel == "G610"
drop if GradeLevel == "G611"
drop if GradeLevel == "G612"
drop if GradeLevel == "G66"
drop if GradeLevel == "G69"
drop if GradeLevel == "G711"
drop if GradeLevel == "G712"
drop if GradeLevel == "G88"
drop if GradeLevel == "G810"
drop if GradeLevel == "G812"
drop if GradeLevel == "G89"
drop if GradeLevel == "GK10"
drop if GradeLevel == "GK11"
drop if GradeLevel == "GK12"
drop if GradeLevel == "GK3"
drop if GradeLevel == "GK4"
drop if GradeLevel == "GK5"
drop if GradeLevel == "GK6"
drop if GradeLevel == "GK7"
drop if GradeLevel == "GK8"
drop if GradeLevel == "GK9"
drop if GradeLevel == "G.." & SchName == "All Schools"

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch agency_charter_indicator dist_agency_charter_indicator

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID

//Variable Types
decode DistType, gen(DistType_s)
drop DistType
rename DistType_s DistType

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen (SchType_s)
drop SchType
rename SchType_s SchType

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
gen Flag_CutScoreChange_read = ""
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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"
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
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "TFS"
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
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "$GAdata/GA_AssmtData_2015.dta", replace

//Clean NCES Data
use "$NCES/NCES School Files, Fall 1997-Fall 2021/NCES_2014_School.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/Cleaned NCES Data/NCES_2015_School_GA.dta", replace

use "$NCES/NCES District Files, Fall 1997-Fall 2021/NCES_2014_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/Cleaned NCES Data/NCES_2015_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2015.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2015_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2015_School_GA.dta", gen(merge2)
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

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch agency_charter_indicator dist_agency_charter_indicator

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID

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
gen Flag_CutScoreChange_read = ""
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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

replace SchName = DistName + " District Total" if DataLevel == "District"

bys SchName Subject GradeLevel StudentGroup: egen StudentGroup_TotalTested = total (StudentSubGroup_TotalTested)

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
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "$GAdata/GA_AssmtData_2016.dta", replace

//Clean NCES Data
use "$NCES/NCES School Files, Fall 1997-Fall 2021/NCES_2015_School.dta", replace
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "$NCES/Cleaned NCES Data/NCES_2016_School_GA.dta", replace

use "$NCES/NCES District Files, Fall 1997-Fall 2021/NCES_2015_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/Cleaned NCES Data/NCES_2016_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2016.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2016_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2016_School_GA.dta", gen(merge2)
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

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch agency_charter_indicator dist_agency_charter_indicator

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID

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
gen Flag_CutScoreChange_read = ""
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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"
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
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "$GAdata/GA_AssmtData_2017.dta", replace

//Clean NCES Data
use "$NCES/NCES School Files, Fall 1997-Fall 2021/NCES_2016_School.dta", clear
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
save "$NCES/Cleaned NCES Data/NCES_2017_School_GA.dta", replace

use "$NCES/NCES District Files, Fall 1997-Fall 2021/NCES_2016_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/Cleaned NCES Data/NCES_2017_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2017.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2017_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2017_School_GA.dta", gen(merge2)
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

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch agency_charter_indicator dist_agency_charter_indicator

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID

//Unmerged Schools
replace NCESSchoolID = "130002303482" if SchName == "Odyssey School"
replace SchLevel = 1 if SchName == "Odyssey School"
replace SchType = 1 if SchName == "Odyssey School"
replace SchVirtual = 0 if SchName == "Odyssey School"
replace NCESSchoolID = "130023204148" if SchName == "Georgia Cyber Academy"
replace SchLevel = 4 if SchName == "Georgia Cyber Academy"
replace SchType = 1 if SchName == "Georgia Cyber Academy"
replace SchVirtual = 1 if SchName == "Georgia Cyber Academy"
replace NCESSchoolID = "130023304164" if SchName == "Utopian Academy for the Arts Charter School"
replace SchLevel = 2 if SchName == "Utopian Academy for the Arts Charter School"
replace SchType = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace SchVirtual = 0 if SchName == "Utopian Academy for the Arts Charter School"
replace NCESSchoolID = "130021803964" if SchName == "Pataula Charter Academy"
replace SchLevel = 4 if SchName == "Pataula Charter Academy"
replace SchType = 1 if SchName == "Pataula Charter Academy"
replace SchVirtual = 0 if SchName == "Pataula Charter Academy"
replace NCESSchoolID = "130023004051" if SchName == "Cherokee Charter Academy"
replace SchLevel = 1 if SchName == "Cherokee Charter Academy"
replace SchType = 1 if SchName == "Cherokee Charter Academy"
replace SchVirtual = 0 if SchName == "Cherokee Charter Academy"
replace NCESSchoolID = "130021703961" if SchName == "Fulton Leadership Academy"
replace SchLevel = 4 if SchName == "Fulton Leadership Academy"
replace SchType = 1 if SchName == "Fulton Leadership Academy"
replace SchVirtual = 0 if SchName == "Fulton Leadership Academy"
replace NCESSchoolID = "130022104021" if SchName == "Atlanta Heights Charter School"
replace SchLevel = 1 if SchName == "Atlanta Heights Charter School"
replace SchType = 1 if SchName == "Atlanta Heights Charter School"
replace SchVirtual = 0 if SchName == "Atlanta Heights Charter School"
replace NCESSchoolID = "130022704031" if SchName == "Georgia Connections Academy"
replace SchLevel = 4 if SchName == "Georgia Connections Academy"
replace SchType = 1 if SchName == "Georgia Connections Academy"
replace SchVirtual = 1 if SchName == "Georgia Connections Academy"
replace NCESSchoolID = "130022204007" if SchName == "Coweta Charter Academy"
replace SchLevel = 1 if SchName == "Coweta Charter Academy"
replace SchType = 1 if SchName == "Coweta Charter Academy"
replace SchVirtual = 0 if SchName == "Coweta Charter Academy"
replace NCESSchoolID = "130023904226" if SchName == "Cirrus Charter Academy"
replace SchLevel = 1 if SchName == "Cirrus Charter Academy"
replace SchType = 1 if SchName == "Cirrus Charter Academy"
replace SchVirtual = 0 if SchName == "Cirrus Charter Academy"
replace NCESSchoolID = "130022604023" if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchLevel = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchType = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchVirtual = 0 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace NCESSchoolID = "130024304253" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchLevel = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchType = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchVirtual = 0 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace NCESSchoolID = "130024204249" if SchName == "Brookhaven Innovation Academy"
replace SchLevel = 1 if SchName == "Brookhaven Innovation Academy"
replace SchType = 1 if SchName == "Brookhaven Innovation Academy"
replace SchVirtual = 0 if SchName == "Brookhaven Innovation Academy"
replace NCESSchoolID = "130023404179" if SchName == "International Charter School of Atlanta"
replace SchLevel = 1 if SchName == "International Charter School of Atlanta"
replace SchType = 1 if SchName == "International Charter School of Atlanta"
replace SchVirtual = 0 if SchName == "International Charter School of Atlanta"
replace NCESSchoolID = "130024104229" if SchName == "Liberty Tech Charter Academy"
replace SchLevel = 1 if SchName == "Liberty Tech Charter Academy"
replace SchType = 1 if SchName == "Liberty Tech Charter Academy"
replace SchVirtual = 0 if SchName == "Liberty Tech Charter Academy"
replace NCESSchoolID = "130023604192" if SchName == "Scintilla Charter Academy"
replace SchLevel = 1 if SchName == "Scintilla Charter Academy"
replace SchType = 1 if SchName == "Scintilla Charter Academy"
replace SchVirtual = 0 if SchName == "Scintilla Charter Academy"
replace NCESSchoolID = "130023804205" if SchName == "Georgia School for Innovation and the Classics"
replace SchLevel = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchType = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchVirtual = 0 if SchName == "Georgia School for Innovation and the Classics"
replace NCESSchoolID = "130023704193" if SchName == "Dubois Integrity Academy I"
replace SchLevel = 1 if SchName == "Dubois Integrity Academy I"
replace SchType = 1 if SchName == "Dubois Integrity Academy I"
replace SchVirtual = 0 if SchName == "Dubois Integrity Academy I"
replace NCESSchoolID = "130022503061" if SchName == "Atlanta Area School for the Deaf"
replace SchLevel = 4 if SchName == "Atlanta Area School for the Deaf"
replace SchType = 2 if SchName == "Atlanta Area School for the Deaf"
replace NCESSchoolID = "130022403062" if SchName == "Georgia Academy for the Blind"
replace SchLevel = 4 if SchName == "Georgia Academy for the Blind"
replace SchType = 2 if SchName == "Georgia Academy for the Blind"
replace NCESSchoolID = "130022303063" if SchName == "Georgia School for the Deaf"
replace SchLevel = 4 if SchName == "Georgia School for the Deaf"
replace SchType = 2 if SchName == "Georgia School for the Deaf"
replace NCESSchoolID = "130000502626" if SchName == "CCAT School"
replace SchType = 1 if SchName == "CCAT School"
replace SchLevel = 4 if SchName == "CCAT School"
replace SchVirtual = 0 if SchName == "CCAT School"
replace NCESSchoolID = "130021503748" if SchName == "Ivy Preparatory Academy School"
replace SchType = 1 if SchName == "Ivy Preparatory Academy School"
replace SchLevel = 4 if SchName == "Ivy Preparatory Academy School"
replace SchVirtual = 0 if SchName == "Ivy Preparatory Academy School"

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
gen Flag_CutScoreChange_read = ""
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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"
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
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "$GAdata/GA_AssmtData_2018.dta", replace

//Clean NCES Data
use "$NCES/NCES School Files, Fall 1997-Fall 2021/NCES_2017_School.dta", clear
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
save "$NCES/Cleaned NCES Data/NCES_2018_School_GA.dta", replace

use "$NCES/NCES District Files, Fall 1997-Fall 2021/NCES_2017_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/Cleaned NCES Data/NCES_2018_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2018.dta", replace
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2018_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2018_School_GA.dta", gen(merge2)
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

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch agency_charter_indicator dist_agency_charter_indicator

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID

//Unmerged Schools
replace NCESSchoolID = "130002303482" if SchName == "Odyssey School"
replace SchLevel = 1 if SchName == "Odyssey School"
replace SchType = 1 if SchName == "Odyssey School"
replace SchVirtual = 0 if SchName == "Odyssey School"
replace NCESSchoolID = "130023204148" if SchName == "Georgia Cyber Academy"
replace SchLevel = 4 if SchName == "Georgia Cyber Academy"
replace SchType = 1 if SchName == "Georgia Cyber Academy"
replace SchVirtual = 1 if SchName == "Georgia Cyber Academy"
replace NCESSchoolID = "130023304164" if SchName == "Utopian Academy for the Arts Charter School"
replace SchLevel = 2 if SchName == "Utopian Academy for the Arts Charter School"
replace SchType = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace SchVirtual = 0 if SchName == "Utopian Academy for the Arts Charter School"
replace NCESSchoolID = "130021803964" if SchName == "Pataula Charter Academy"
replace SchLevel = 4 if SchName == "Pataula Charter Academy"
replace SchType = 1 if SchName == "Pataula Charter Academy"
replace SchVirtual = 0 if SchName == "Pataula Charter Academy"
replace NCESSchoolID = "130023004051" if SchName == "Cherokee Charter Academy"
replace SchLevel = 1 if SchName == "Cherokee Charter Academy"
replace SchType = 1 if SchName == "Cherokee Charter Academy"
replace SchVirtual = 0 if SchName == "Cherokee Charter Academy"
replace NCESSchoolID = "130021703961" if SchName == "Fulton Leadership Academy"
replace SchLevel = 4 if SchName == "Fulton Leadership Academy"
replace SchType = 1 if SchName == "Fulton Leadership Academy"
replace SchVirtual = 0 if SchName == "Fulton Leadership Academy"
replace NCESSchoolID = "130022104021" if SchName == "Atlanta Heights Charter School"
replace SchLevel = 1 if SchName == "Atlanta Heights Charter School"
replace SchType = 1 if SchName == "Atlanta Heights Charter School"
replace SchVirtual = 0 if SchName == "Atlanta Heights Charter School"
replace NCESSchoolID = "130022704031" if SchName == "Georgia Connections Academy"
replace SchLevel = 4 if SchName == "Georgia Connections Academy"
replace SchType = 1 if SchName == "Georgia Connections Academy"
replace SchVirtual = 1 if SchName == "Georgia Connections Academy"
replace NCESSchoolID = "130022204007" if SchName == "Coweta Charter Academy"
replace SchLevel = 1 if SchName == "Coweta Charter Academy"
replace SchType = 1 if SchName == "Coweta Charter Academy"
replace SchVirtual = 0 if SchName == "Coweta Charter Academy"
replace NCESSchoolID = "130023904226" if SchName == "Cirrus Charter Academy"
replace SchLevel = 1 if SchName == "Cirrus Charter Academy"
replace SchType = 1 if SchName == "Cirrus Charter Academy"
replace SchVirtual = 0 if SchName == "Cirrus Charter Academy"
replace NCESSchoolID = "130022604023" if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchLevel = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchType = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchVirtual = 0 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace NCESSchoolID = "130024304253" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchLevel = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchType = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchVirtual = 0 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace NCESSchoolID = "130024204249" if SchName == "Brookhaven Innovation Academy"
replace SchLevel = 1 if SchName == "Brookhaven Innovation Academy"
replace SchType = 1 if SchName == "Brookhaven Innovation Academy"
replace SchVirtual = 0 if SchName == "Brookhaven Innovation Academy"
replace NCESSchoolID = "130023404179" if SchName == "International Charter School of Atlanta"
replace SchLevel = 1 if SchName == "International Charter School of Atlanta"
replace SchType = 1 if SchName == "International Charter School of Atlanta"
replace SchVirtual = 0 if SchName == "International Charter School of Atlanta"
replace NCESSchoolID = "130024104229" if SchName == "Liberty Tech Charter Academy"
replace SchLevel = 1 if SchName == "Liberty Tech Charter Academy"
replace SchType = 1 if SchName == "Liberty Tech Charter Academy"
replace SchVirtual = 0 if SchName == "Liberty Tech Charter Academy"
replace NCESSchoolID = "130023604192" if SchName == "Scintilla Charter Academy"
replace SchLevel = 1 if SchName == "Scintilla Charter Academy"
replace SchType = 1 if SchName == "Scintilla Charter Academy"
replace SchVirtual = 0 if SchName == "Scintilla Charter Academy"
replace NCESSchoolID = "130023804205" if SchName == "Georgia School for Innovation and the Classics"
replace SchLevel = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchType = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchVirtual = 0 if SchName == "Georgia School for Innovation and the Classics"
replace NCESSchoolID = "130023704193" if SchName == "Dubois Integrity Academy I"
replace SchLevel = 1 if SchName == "Dubois Integrity Academy I"
replace SchType = 1 if SchName == "Dubois Integrity Academy I"
replace SchVirtual = 0 if SchName == "Dubois Integrity Academy I"
replace NCESSchoolID = "130024804288" if SchName == "Genesis Innovation Academy for Boys"
replace SchLevel = 1 if SchName == "Genesis Innovation Academy for Boys"
replace SchType = 1 if SchName == "Genesis Innovation Academy for Boys"
replace SchVirtual = 0 if SchName == "Genesis Innovation Academy for Boys"
replace NCESSchoolID = "130024404272" if SchName == "Genesis Innovation Academy for Girls"
replace SchLevel = 1 if SchName == "Genesis Innovation Academy for Girls"
replace SchType = 1 if SchName == "Genesis Innovation Academy for Girls"
replace SchVirtual = 0 if SchName == "Genesis Innovation Academy for Girls"
replace NCESSchoolID = "130024704283" if SchName == "Resurgence Hall Charter School"
replace SchLevel = 1 if SchName == "Resurgence Hall Charter School"
replace SchType = 1 if SchName == "Resurgence Hall Charter School"
replace SchVirtual = 0 if SchName == "Resurgence Hall Charter School"
replace NCESSchoolID = "130024504293" if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchLevel = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchType = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchVirtual = 0 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace NCESSchoolID = "130024904273" if SchName == "International Academy of Smyrna"
replace SchLevel = 1 if SchName == "International Academy of Smyrna"
replace SchType = 1 if SchName == "International Academy of Smyrna"
replace SchVirtual = 0 if SchName == "International Academy of Smyrna"
replace NCESSchoolID = "130022503061" if SchName == "Atlanta Area School for the Deaf"
replace SchLevel = 4 if SchName == "Atlanta Area School for the Deaf"
replace SchType = 2 if SchName == "Atlanta Area School for the Deaf"
replace SchVirtual = 0 if SchName == "Atlanta Area School for the Deaf"
replace NCESSchoolID = "130022403062" if SchName == "Georgia Academy for the Blind"
replace SchLevel = 4 if SchName == "Georgia Academy for the Blind"
replace SchType = 2 if SchName == "Georgia Academy for the Blind"
replace SchVirtual = 0 if SchName == "Georgia Academy for the Blind"
replace NCESSchoolID = "130022303063" if SchName == "Georgia School for the Deaf"
replace SchType = 2 if SchName == "Georgia School for the Deaf"
replace SchLevel = 4 if SchName == "Georgia School for the Deaf"
replace SchVirtual = 0 if SchName == "Georgia School for the Deaf"
replace NCESSchoolID = "130000502626" if SchName == "CCAT School"
replace SchType = 1 if SchName == "CCAT School"
replace SchLevel = 4 if SchName == "CCAT School"
replace SchVirtual = 0 if SchName == "CCAT School"
replace NCESSchoolID = "130021503748" if SchName == "Ivy Preparatory Academy School"
replace SchType = 1 if SchName == "Ivy Preparatory Academy School"
replace SchLevel = 4 if SchName == "Ivy Preparatory Academy School"
replace SchVirtual = 0 if SchName == "Ivy Preparatory Academy School"

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
gen Flag_CutScoreChange_read = ""
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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

gen StudentSubGroup_TotalTested = num_tested_cnt
destring num_tested_cnt, replace force
replace num_tested_cnt = -1000000 if num_tested_cnt == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(num_tested_cnt)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "TFS"
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
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "$GAdata/GA_AssmtData_2019.dta", replace

//Clean NCES Data
use "$NCES/NCES School Files, Fall 1997-Fall 2021/NCES_2018_School.dta", clear
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
save "$NCES/Cleaned NCES Data/NCES_2019_School_GA.dta", replace

use "$NCES/NCES District Files, Fall 1997-Fall 2021/NCES_2018_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/Cleaned NCES Data/NCES_2019_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2019.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2019_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2019_School_GA.dta", gen(merge2)
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

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch agency_charter_indicator dist_agency_charter_indicator

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID

//Unmerged Schools
replace NCESSchoolID = "130002303482" if SchName == "Odyssey School"
replace SchLevel = 1 if SchName == "Odyssey School"
replace SchType = 1 if SchName == "Odyssey School"
replace SchVirtual = 0 if SchName == "Odyssey School"
replace NCESSchoolID = "130023204148" if SchName == "Georgia Cyber Academy"
replace SchLevel = 4 if SchName == "Georgia Cyber Academy"
replace SchType = 1 if SchName == "Georgia Cyber Academy"
replace SchVirtual = 1 if SchName == "Georgia Cyber Academy"
replace NCESSchoolID = "130023304164" if SchName == "Utopian Academy for the Arts Charter School"
replace SchLevel = 2 if SchName == "Utopian Academy for the Arts Charter School"
replace SchType = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace SchVirtual = 0 if SchName == "Utopian Academy for the Arts Charter School"
replace NCESSchoolID = "130021803964" if SchName == "Pataula Charter Academy"
replace SchLevel = 4 if SchName == "Pataula Charter Academy"
replace SchType = 1 if SchName == "Pataula Charter Academy"
replace SchVirtual = 0 if SchName == "Pataula Charter Academy"
replace NCESSchoolID = "130023004051" if SchName == "Cherokee Charter Academy"
replace SchLevel = 1 if SchName == "Cherokee Charter Academy"
replace SchType = 1 if SchName == "Cherokee Charter Academy"
replace SchVirtual = 0 if SchName == "Cherokee Charter Academy"
replace NCESSchoolID = "130021703961" if SchName == "Fulton Leadership Academy"
replace SchLevel = 4 if SchName == "Fulton Leadership Academy"
replace SchType = 1 if SchName == "Fulton Leadership Academy"
replace SchVirtual = 0 if SchName == "Fulton Leadership Academy"
replace NCESSchoolID = "130022104021" if SchName == "Atlanta Heights Charter School"
replace SchLevel = 1 if SchName == "Atlanta Heights Charter School"
replace SchType = 1 if SchName == "Atlanta Heights Charter School"
replace SchVirtual = 0 if SchName == "Atlanta Heights Charter School"
replace NCESSchoolID = "130022704031" if SchName == "Georgia Connections Academy"
replace SchLevel = 4 if SchName == "Georgia Connections Academy"
replace SchType = 1 if SchName == "Georgia Connections Academy"
replace SchVirtual = 1 if SchName == "Georgia Connections Academy"
replace NCESSchoolID = "130022204007" if SchName == "Coweta Charter Academy"
replace SchLevel = 1 if SchName == "Coweta Charter Academy"
replace SchType = 1 if SchName == "Coweta Charter Academy"
replace SchVirtual = 0 if SchName == "Coweta Charter Academy"
replace NCESSchoolID = "130023904226" if SchName == "Cirrus Charter Academy"
replace SchLevel = 1 if SchName == "Cirrus Charter Academy"
replace SchType = 1 if SchName == "Cirrus Charter Academy"
replace SchVirtual = 0 if SchName == "Cirrus Charter Academy"
replace NCESSchoolID = "130022604023" if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchLevel = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchType = 1 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace SchVirtual = 0 if SchName == "Ivy Prep Academy at Kirkwood for Girls School"
replace NCESSchoolID = "130024304253" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchLevel = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchType = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchVirtual = 0 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace NCESSchoolID = "130024204249" if SchName == "Brookhaven Innovation Academy"
replace SchLevel = 1 if SchName == "Brookhaven Innovation Academy"
replace SchType = 1 if SchName == "Brookhaven Innovation Academy"
replace SchVirtual = 0 if SchName == "Brookhaven Innovation Academy"
replace NCESSchoolID = "130023404179" if SchName == "International Charter School of Atlanta"
replace SchLevel = 1 if SchName == "International Charter School of Atlanta"
replace SchType = 1 if SchName == "International Charter School of Atlanta"
replace SchVirtual = 0 if SchName == "International Charter School of Atlanta"
replace NCESSchoolID = "130024104229" if SchName == "Liberty Tech Charter Academy"
replace SchLevel = 1 if SchName == "Liberty Tech Charter Academy"
replace SchType = 1 if SchName == "Liberty Tech Charter Academy"
replace SchVirtual = 0 if SchName == "Liberty Tech Charter Academy"
replace NCESSchoolID = "130023604192" if SchName == "Scintilla Charter Academy"
replace SchLevel = 1 if SchName == "Scintilla Charter Academy"
replace SchType = 1 if SchName == "Scintilla Charter Academy"
replace SchVirtual = 0 if SchName == "Scintilla Charter Academy"
replace NCESSchoolID = "130023804205" if SchName == "Georgia School for Innovation and the Classics"
replace SchLevel = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchType = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchVirtual = 0 if SchName == "Georgia School for Innovation and the Classics"
replace NCESSchoolID = "130023704193" if SchName == "Dubois Integrity Academy I"
replace SchLevel = 1 if SchName == "Dubois Integrity Academy I"
replace SchType = 1 if SchName == "Dubois Integrity Academy I"
replace SchVirtual = 0 if SchName == "Dubois Integrity Academy I"
replace NCESSchoolID = "130024804288" if SchName == "Genesis Innovation Academy for Boys"
replace SchLevel = 1 if SchName == "Genesis Innovation Academy for Boys"
replace SchType = 1 if SchName == "Genesis Innovation Academy for Boys"
replace SchVirtual = 0 if SchName == "Genesis Innovation Academy for Boys"
replace NCESSchoolID = "130024404272" if SchName == "Genesis Innovation Academy for Girls"
replace SchLevel = 1 if SchName == "Genesis Innovation Academy for Girls"
replace SchType = 1 if SchName == "Genesis Innovation Academy for Girls"
replace SchVirtual = 0 if SchName == "Genesis Innovation Academy for Girls"
replace NCESSchoolID = "130024704283" if SchName == "Resurgence Hall Charter School"
replace SchLevel = 1 if SchName == "Resurgence Hall Charter School"
replace SchType = 1 if SchName == "Resurgence Hall Charter School"
replace SchVirtual = 0 if SchName == "Resurgence Hall Charter School"
replace NCESSchoolID = "130024504293" if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchLevel = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchType = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchVirtual = 0 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace NCESSchoolID = "130024904273" if SchName == "International Academy of Smyrna"
replace SchLevel = 1 if SchName == "International Academy of Smyrna"
replace SchType = 1 if SchName == "International Academy of Smyrna"
replace SchVirtual = 0 if SchName == "International Academy of Smyrna"
replace NCESSchoolID = "130025004325" if SchName == "International Charter Academy of Georgia"
replace SchLevel = 1 if SchName == "International Charter Academy of Georgia"
replace SchType = 1 if SchName == "International Charter Academy of Georgia"
replace SchVirtual = 0 if SchName == "International Charter Academy of Georgia"
replace NCESSchoolID = "130025104306" if SchName == "SLAM Academy of Atlanta"
replace SchLevel = 1 if SchName == "SLAM Academy of Atlanta"
replace SchType = 1 if SchName == "SLAM Academy of Atlanta"
replace SchVirtual = 0 if SchName == "SLAM Academy of Atlanta"
replace NCESSchoolID = "130022503061" if SchName == "Atlanta Area School for the Deaf"
replace SchLevel = 4 if SchName == "Atlanta Area School for the Deaf"
replace SchType = 2 if SchName == "Atlanta Area School for the Deaf"
replace SchVirtual = 0 if SchName == "Atlanta Area School for the Deaf"
replace NCESSchoolID = "130022403062" if SchName == "Georgia Academy for the Blind"
replace SchLevel = 4 if SchName == "Georgia Academy for the Blind"
replace SchType = 2 if SchName == "Georgia Academy for the Blind"
replace SchVirtual = 0 if SchName == "Georgia Academy for the Blind"
replace NCESSchoolID = "130022303063" if SchName == "Georgia School for the Deaf"
replace SchType = 2 if SchName == "Georgia School for the Deaf"
replace SchLevel = 4 if SchName == "Georgia School for the Deaf"
replace SchVirtual = 0 if SchName == "Georgia School for the Deaf"
replace NCESSchoolID = "130000502626" if SchName == "CCAT School"
replace SchType = 1 if SchName == "CCAT School"
replace SchLevel = 4 if SchName == "CCAT School"
replace SchVirtual = 0 if SchName == "CCAT School"

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
gen Flag_CutScoreChange_read = ""
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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"
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
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "TFS"
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
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "$GAdata/GA_AssmtData_2021.dta", replace

//Clean NCES Data
use "$NCES/NCES School Files, Fall 1997-Fall 2021/NCES_2020_School.dta", clear
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
save "$NCES/Cleaned NCES Data/NCES_2021_School_GA.dta", replace

use "$NCES/NCES District Files, Fall 1997-Fall 2021/NCES_2020_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/Cleaned NCES Data/NCES_2021_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2021.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2021_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2021_School_GA.dta", gen(merge2)
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

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch agency_charter_indicator dist_agency_charter_indicator

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID

//Unmerged Schools
replace NCESSchoolID = "130002303482" if SchName == "Odyssey Charter School"
replace SchLevel = 1 if SchName == "Odyssey Charter School"
replace SchType = 1 if SchName == "Odyssey Charter School"
replace SchVirtual = 0 if SchName == "Odyssey Charter School"
replace NCESSchoolID = "130023204148" if SchName == "Georgia Cyber Academy"
replace SchLevel = 4 if SchName == "Georgia Cyber Academy"
replace SchType = 1 if SchName == "Georgia Cyber Academy"
replace SchVirtual = 1 if SchName == "Georgia Cyber Academy"
replace NCESSchoolID = "130023304164" if SchName == "Utopian Academy for the Arts Charter School"
replace SchLevel = 2 if SchName == "Utopian Academy for the Arts Charter School"
replace SchType = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace SchVirtual = 0 if SchName == "Utopian Academy for the Arts Charter School"
replace NCESSchoolID = "130021803964" if SchName == "Pataula Charter Academy"
replace SchLevel = 4 if SchName == "Pataula Charter Academy"
replace SchType = 1 if SchName == "Pataula Charter Academy"
replace SchVirtual = 0 if SchName == "Pataula Charter Academy"
replace NCESSchoolID = "130023004051" if SchName == "Cherokee Charter Academy"
replace SchLevel = 1 if SchName == "Cherokee Charter Academy"
replace SchType = 1 if SchName == "Cherokee Charter Academy"
replace SchVirtual = 0 if SchName == "Cherokee Charter Academy"
replace NCESSchoolID = "130021703961" if SchName == "Fulton Leadership Academy"
replace SchLevel = 4 if SchName == "Fulton Leadership Academy"
replace SchType = 1 if SchName == "Fulton Leadership Academy"
replace SchVirtual = 0 if SchName == "Fulton Leadership Academy"
replace NCESSchoolID = "130022104021" if SchName == "Atlanta Heights Charter School"
replace SchLevel = 1 if SchName == "Atlanta Heights Charter School"
replace SchType = 1 if SchName == "Atlanta Heights Charter School"
replace SchVirtual = 0 if SchName == "Atlanta Heights Charter School"
replace NCESSchoolID = "130022704031" if SchName == "Georgia Connections Academy"
replace SchLevel = 4 if SchName == "Georgia Connections Academy"
replace SchType = 1 if SchName == "Georgia Connections Academy"
replace SchVirtual = 1 if SchName == "Georgia Connections Academy"
replace NCESSchoolID = "130022204007" if SchName == "Coweta Charter Academy"
replace SchLevel = 1 if SchName == "Coweta Charter Academy"
replace SchType = 1 if SchName == "Coweta Charter Academy"
replace SchVirtual = 0 if SchName == "Coweta Charter Academy"
replace NCESSchoolID = "130023904226" if SchName == "Cirrus Charter Academy"
replace SchLevel = 1 if SchName == "Cirrus Charter Academy"
replace SchType = 1 if SchName == "Cirrus Charter Academy"
replace SchVirtual = 0 if SchName == "Cirrus Charter Academy"
replace NCESSchoolID = "130022604023" if SchName == "Ivy Preparatory Academy, Inc"
replace SchLevel = 1 if SchName == "Ivy Preparatory Academy, Inc"
replace SchType = 1 if SchName == "Ivy Preparatory Academy, Inc"
replace SchVirtual = 0 if SchName == "Ivy Preparatory Academy, Inc"
replace NCESSchoolID = "130024304253" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchLevel = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchType = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchVirtual = 0 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace NCESSchoolID = "130024204249" if SchName == "Brookhaven Innovation Academy"
replace SchLevel = 1 if SchName == "Brookhaven Innovation Academy"
replace SchType = 1 if SchName == "Brookhaven Innovation Academy"
replace SchVirtual = 0 if SchName == "Brookhaven Innovation Academy"
replace NCESSchoolID = "130023404179" if SchName == "International Charter School of Atlanta"
replace SchLevel = 1 if SchName == "International Charter School of Atlanta"
replace SchType = 1 if SchName == "International Charter School of Atlanta"
replace SchVirtual = 0 if SchName == "International Charter School of Atlanta"
replace NCESSchoolID = "130024104229" if SchName == "Liberty Tech Charter Academy"
replace SchLevel = 1 if SchName == "Liberty Tech Charter Academy"
replace SchType = 1 if SchName == "Liberty Tech Charter Academy"
replace SchVirtual = 0 if SchName == "Liberty Tech Charter Academy"
replace NCESSchoolID = "130023604192" if SchName == "Scintilla Charter Academy"
replace SchLevel = 1 if SchName == "Scintilla Charter Academy"
replace SchType = 1 if SchName == "Scintilla Charter Academy"
replace SchVirtual = 0 if SchName == "Scintilla Charter Academy"
replace NCESSchoolID = "130023804205" if SchName == "Georgia School for Innovation and the Classics"
replace SchLevel = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchType = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchVirtual = 0 if SchName == "Georgia School for Innovation and the Classics"
replace NCESSchoolID = "130023704193" if SchName == "Dubois Integrity Academy"
replace SchLevel = 1 if SchName == "Dubois Integrity Academy"
replace SchType = 1 if SchName == "Dubois Integrity Academy"
replace SchVirtual = 0 if SchName == "Dubois Integrity Academy"
replace NCESSchoolID = "130024804288" if SchName == "Genesis Innovation Academy for Boys"
replace SchLevel = 1 if SchName == "Genesis Innovation Academy for Boys"
replace SchType = 1 if SchName == "Genesis Innovation Academy for Boys"
replace SchVirtual = 0 if SchName == "Genesis Innovation Academy for Boys"
replace NCESSchoolID = "130024404272" if SchName == "Genesis Innovation Academy for Girls"
replace SchLevel = 1 if SchName == "Genesis Innovation Academy for Girls"
replace SchType = 1 if SchName == "Genesis Innovation Academy for Girls"
replace SchVirtual = 0 if SchName == "Genesis Innovation Academy for Girls"
replace NCESSchoolID = "130024704283" if SchName == "Resurgence Hall Charter School"
replace SchLevel = 1 if SchName == "Resurgence Hall Charter School"
replace SchType = 1 if SchName == "Resurgence Hall Charter School"
replace SchVirtual = 0 if SchName == "Resurgence Hall Charter School"
replace NCESSchoolID = "130024504293" if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchLevel = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchType = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchVirtual = 0 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace NCESSchoolID = "130024904273" if SchName == "International Academy of Smyrna"
replace SchLevel = 1 if SchName == "International Academy of Smyrna"
replace SchType = 1 if SchName == "International Academy of Smyrna"
replace SchVirtual = 0 if SchName == "International Academy of Smyrna"
replace NCESSchoolID = "130025004325" if SchName == "International Charter Academy of Georgia"
replace SchLevel = 1 if SchName == "International Charter Academy of Georgia"
replace SchType = 1 if SchName == "International Charter Academy of Georgia"
replace SchVirtual = 0 if SchName == "International Charter Academy of Georgia"
replace NCESSchoolID = "130025104306" if SchName == "SLAM Academy of Atlanta"
replace SchLevel = 1 if SchName == "SLAM Academy of Atlanta"
replace SchType = 1 if SchName == "SLAM Academy of Atlanta"
replace SchVirtual = 0 if SchName == "SLAM Academy of Atlanta"
replace NCESSchoolID = "130000502626" if SchName == "Statesboro STEAM Academy"
replace SchLevel = 3 if SchName == "Statesboro STEAM Academy"
replace SchType = 1 if SchName == "Statesboro STEAM Academy"
replace SchVirtual = 0 if SchName == "Statesboro STEAM Academy"
replace NCESSchoolID = "130025204345" if SchName == "Academy For Classical Education"
replace SchLevel = 4 if SchName == "Academy For Classical Education"
replace SchType = 1 if SchName == "Academy For Classical Education"
replace SchVirtual = 0 if SchName == "Academy For Classical Education"
replace NCESSchoolID = "130025304349" if SchName == "Spring Creek Charter Academy"
replace SchLevel = 1 if SchName == "Spring Creek Charter Academy"
replace SchType = 1 if SchName == "Spring Creek Charter Academy"
replace SchVirtual = 0 if SchName == "Spring Creek Charter Academy"
replace NCESSchoolID = "130025704372" if SchName == "Yi Hwang Academy of Language Excellence"
replace SchLevel = 1 if SchName == "Yi Hwang Academy of Language Excellence"
replace SchType = 1 if SchName == "Yi Hwang Academy of Language Excellence"
replace SchVirtual = 0 if SchName == "Yi Hwang Academy of Language Excellence"
replace NCESSchoolID = "130025804373" if SchName == "Furlow Charter School"
replace SchLevel = 4 if SchName == "Furlow Charter School"
replace SchType = 1 if SchName == "Furlow Charter School"
replace SchVirtual = 0 if SchName == "Furlow Charter School"
replace NCESSchoolID = "130025504332" if SchName == "Ethos Classical Charter School"
replace SchLevel = 1 if SchName == "Ethos Classical Charter School"
replace SchType = 1 if SchName == "Ethos Classical Charter School"
replace SchVirtual = 0 if SchName == "Ethos Classical Charter School"
replace NCESSchoolID = "130025604363" if SchName == "Baconton Community Charter School"
replace SchLevel = 4 if SchName == "Baconton Community Charter School"
replace SchType = 1 if SchName == "Baconton Community Charter School"
replace SchVirtual = 0 if SchName == "Baconton Community Charter School"
replace NCESSchoolID = "130026104376" if SchName == "Atlanta Unbound Academy"
replace SchLevel = 1 if SchName == "Atlanta Unbound Academy"
replace SchType = 1 if SchName == "Atlanta Unbound Academy"
replace SchVirtual = 0 if SchName == "Atlanta Unbound Academy"
replace NCESSchoolID = "130026204377" if SchName == "D.E.L.T.A. STEAM Academy"
replace SchLevel = 1 if SchName == "D.E.L.T.A. STEAM Academy"
replace SchType = 1 if SchName == "D.E.L.T.A. STEAM Academy"
replace SchVirtual = 0 if SchName == "D.E.L.T.A. STEAM Academy"
replace NCESSchoolID = "130026304378" if SchName == "Georgia Fugees Academy Charter School"
replace SchLevel = 3 if SchName == "Georgia Fugees Academy Charter School"
replace SchType = 1 if SchName == "Georgia Fugees Academy Charter School"
replace SchVirtual = 0 if SchName == "Georgia Fugees Academy Charter School"
replace NCESSchoolID = "130026004375" if SchName == "Harriet Tubman School of Science & Technology"
replace SchLevel = 1 if SchName == "Harriet Tubman School of Science & Technology"
replace SchType = 1 if SchName == "Harriet Tubman School of Science & Technology"
replace SchVirtual = 0 if SchName == "Harriet Tubman School of Science & Technology"

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
gen Flag_CutScoreChange_read = ""
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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Non-Migrant"
drop if StudentSubGroup == "Military Connected"
drop if StudentSubGroup == "Homeless"
drop if StudentSubGroup == "Foster Care"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

replace SchName = DistName + " District Total" if DataLevel == "District"

gen StudentSubGroup_TotalTested = num_tested_cnt
destring num_tested_cnt, replace force
replace num_tested_cnt = -1000000 if num_tested_cnt == .
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(num_tested_cnt)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "TFS"
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
drop if Subject == "Physical Science"
drop if Subject == "sci" & GradeLevel == "G03"
drop if Subject == "sci" & GradeLevel == "G04"
drop if Subject == "sci" & GradeLevel == "G07"

//Statewide Data
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "$GAdata/GA_AssmtData_2022.dta", replace

//Clean NCES Data
use "$NCES/NCES School Files, Fall 1997-Fall 2021/NCES_2021_School.dta", clear
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
save "$NCES/Cleaned NCES Data/NCES_2022_School_GA.dta", replace

use "$NCES/NCES District Files, Fall 1997-Fall 2021/NCES_2021_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "$NCES/Cleaned NCES Data/NCES_2022_District_GA", replace

//Merge Data
use "$GAdata/GA_AssmtData_2022.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2022_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2022_School_GA.dta", gen(merge2)
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

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch

gen State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13 if StateFips == .
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID

//Unmerged Schools
replace NCESSchoolID = "130002303482" if SchName == "Odyssey Charter School"
replace SchLevel = 1 if SchName == "Odyssey Charter School"
replace SchType = 1 if SchName == "Odyssey Charter School"
replace SchVirtual = 0 if SchName == "Odyssey Charter School"
replace NCESSchoolID = "130023204148" if SchName == "Georgia Cyber Academy"
replace SchLevel = 4 if SchName == "Georgia Cyber Academy"
replace SchType = 1 if SchName == "Georgia Cyber Academy"
replace SchVirtual = 1 if SchName == "Georgia Cyber Academy"
replace NCESSchoolID = "130023304164" if SchName == "Utopian Academy for the Arts Charter School"
replace SchLevel = 2 if SchName == "Utopian Academy for the Arts Charter School"
replace SchType = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace SchVirtual = 0 if SchName == "Utopian Academy for the Arts Charter School"
replace NCESSchoolID = "130021803964" if SchName == "Pataula Charter Academy"
replace SchLevel = 4 if SchName == "Pataula Charter Academy"
replace SchType = 1 if SchName == "Pataula Charter Academy"
replace SchVirtual = 0 if SchName == "Pataula Charter Academy"
replace NCESSchoolID = "130023004051" if SchName == "Cherokee Charter Academy"
replace SchLevel = 1 if SchName == "Cherokee Charter Academy"
replace SchType = 1 if SchName == "Cherokee Charter Academy"
replace SchVirtual = 0 if SchName == "Cherokee Charter Academy"
replace NCESSchoolID = "130021703961" if SchName == "Fulton Leadership Academy"
replace SchLevel = 4 if SchName == "Fulton Leadership Academy"
replace SchType = 1 if SchName == "Fulton Leadership Academy"
replace SchVirtual = 0 if SchName == "Fulton Leadership Academy"
replace NCESSchoolID = "130022104021" if SchName == "Atlanta Heights Charter School"
replace SchLevel = 1 if SchName == "Atlanta Heights Charter School"
replace SchType = 1 if SchName == "Atlanta Heights Charter School"
replace SchVirtual = 0 if SchName == "Atlanta Heights Charter School"
replace NCESSchoolID = "130022704031" if SchName == "Georgia Connections Academy"
replace SchLevel = 4 if SchName == "Georgia Connections Academy"
replace SchType = 1 if SchName == "Georgia Connections Academy"
replace SchVirtual = 1 if SchName == "Georgia Connections Academy"
replace NCESSchoolID = "130022204007" if SchName == "Coweta Charter Academy"
replace SchLevel = 1 if SchName == "Coweta Charter Academy"
replace SchType = 1 if SchName == "Coweta Charter Academy"
replace SchVirtual = 0 if SchName == "Coweta Charter Academy"
replace NCESSchoolID = "130023904226" if SchName == "Cirrus Charter Academy"
replace SchLevel = 1 if SchName == "Cirrus Charter Academy"
replace SchType = 1 if SchName == "Cirrus Charter Academy"
replace SchVirtual = 0 if SchName == "Cirrus Charter Academy"
replace NCESSchoolID = "130022604023" if SchName == "Ivy Preparatory Academy, Inc"
replace SchLevel = 1 if SchName == "Ivy Preparatory Academy, Inc"
replace SchType = 1 if SchName == "Ivy Preparatory Academy, Inc"
replace SchVirtual = 0 if SchName == "Ivy Preparatory Academy, Inc"
replace NCESSchoolID = "130024304253" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchLevel = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchType = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchVirtual = 0 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace NCESSchoolID = "130024204249" if SchName == "Brookhaven Innovation Academy"
replace SchLevel = 1 if SchName == "Brookhaven Innovation Academy"
replace SchType = 1 if SchName == "Brookhaven Innovation Academy"
replace SchVirtual = 0 if SchName == "Brookhaven Innovation Academy"
replace NCESSchoolID = "130023404179" if SchName == "International Charter School of Atlanta"
replace SchLevel = 1 if SchName == "International Charter School of Atlanta"
replace SchType = 1 if SchName == "International Charter School of Atlanta"
replace SchVirtual = 0 if SchName == "International Charter School of Atlanta"
replace NCESSchoolID = "130024104229" if SchName == "Liberty Tech Charter Academy"
replace SchLevel = 1 if SchName == "Liberty Tech Charter Academy"
replace SchType = 1 if SchName == "Liberty Tech Charter Academy"
replace SchVirtual = 0 if SchName == "Liberty Tech Charter Academy"
replace NCESSchoolID = "130023604192" if SchName == "Scintilla Charter Academy"
replace SchLevel = 1 if SchName == "Scintilla Charter Academy"
replace SchType = 1 if SchName == "Scintilla Charter Academy"
replace SchVirtual = 0 if SchName == "Scintilla Charter Academy"
replace NCESSchoolID = "130023804205" if SchName == "Georgia School for Innovation and the Classics"
replace SchLevel = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchType = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchVirtual = 0 if SchName == "Georgia School for Innovation and the Classics"
replace NCESSchoolID = "130023704193" if SchName == "Dubois Integrity Academy"
replace SchLevel = 1 if SchName == "Dubois Integrity Academy"
replace SchType = 1 if SchName == "Dubois Integrity Academy"
replace SchVirtual = 0 if SchName == "Dubois Integrity Academy"
replace NCESSchoolID = "130024804288" if SchName == "Genesis Innovation Academy for Boys"
replace SchLevel = 1 if SchName == "Genesis Innovation Academy for Boys"
replace SchType = 1 if SchName == "Genesis Innovation Academy for Boys"
replace SchVirtual = 0 if SchName == "Genesis Innovation Academy for Boys"
replace NCESSchoolID = "130024404272" if SchName == "Genesis Innovation Academy for Girls"
replace SchLevel = 1 if SchName == "Genesis Innovation Academy for Girls"
replace SchType = 1 if SchName == "Genesis Innovation Academy for Girls"
replace SchVirtual = 0 if SchName == "Genesis Innovation Academy for Girls"
replace NCESSchoolID = "130024704283" if SchName == "Resurgence Hall Charter School"
replace SchLevel = 1 if SchName == "Resurgence Hall Charter School"
replace SchType = 1 if SchName == "Resurgence Hall Charter School"
replace SchVirtual = 0 if SchName == "Resurgence Hall Charter School"
replace NCESSchoolID = "130024504293" if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchLevel = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchType = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchVirtual = 0 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace NCESSchoolID = "130024904273" if SchName == "International Academy of Smyrna"
replace SchLevel = 1 if SchName == "International Academy of Smyrna"
replace SchType = 1 if SchName == "International Academy of Smyrna"
replace SchVirtual = 0 if SchName == "International Academy of Smyrna"
replace NCESSchoolID = "130025004325" if SchName == "International Charter Academy of Georgia"
replace SchLevel = 1 if SchName == "International Charter Academy of Georgia"
replace SchType = 1 if SchName == "International Charter Academy of Georgia"
replace SchVirtual = 0 if SchName == "International Charter Academy of Georgia"
replace NCESSchoolID = "130025104306" if SchName == "SLAM Academy of Atlanta"
replace SchLevel = 1 if SchName == "SLAM Academy of Atlanta"
replace SchType = 1 if SchName == "SLAM Academy of Atlanta"
replace SchVirtual = 0 if SchName == "SLAM Academy of Atlanta"
replace NCESSchoolID = "130000502626" if SchName == "Statesboro STEAM Academy"
replace SchLevel = 3 if SchName == "Statesboro STEAM Academy"
replace SchType = 1 if SchName == "Statesboro STEAM Academy"
replace SchVirtual = 0 if SchName == "Statesboro STEAM Academy"
replace NCESSchoolID = "130025204345" if SchName == "Academy For Classical Education"
replace SchLevel = 4 if SchName == "Academy For Classical Education"
replace SchType = 1 if SchName == "Academy For Classical Education"
replace SchVirtual = 0 if SchName == "Academy For Classical Education"
replace NCESSchoolID = "130025304349" if SchName == "Spring Creek Charter Academy"
replace SchLevel = 1 if SchName == "Spring Creek Charter Academy"
replace SchType = 1 if SchName == "Spring Creek Charter Academy"
replace SchVirtual = 0 if SchName == "Spring Creek Charter Academy"
replace NCESSchoolID = "130025704372" if SchName == "Yi Hwang Academy of Language Excellence"
replace SchLevel = 1 if SchName == "Yi Hwang Academy of Language Excellence"
replace SchType = 1 if SchName == "Yi Hwang Academy of Language Excellence"
replace SchVirtual = 0 if SchName == "Yi Hwang Academy of Language Excellence"
replace NCESSchoolID = "130025804373" if SchName == "Furlow Charter School"
replace SchLevel = 4 if SchName == "Furlow Charter School"
replace SchType = 1 if SchName == "Furlow Charter School"
replace SchVirtual = 0 if SchName == "Furlow Charter School"
replace NCESSchoolID = "130025504332" if SchName == "Ethos Classical Charter School"
replace SchLevel = 1 if SchName == "Ethos Classical Charter School"
replace SchType = 1 if SchName == "Ethos Classical Charter School"
replace SchVirtual = 0 if SchName == "Ethos Classical Charter School"
replace NCESSchoolID = "130025604363" if SchName == "Baconton Community Charter School"
replace SchLevel = 4 if SchName == "Baconton Community Charter School"
replace SchType = 1 if SchName == "Baconton Community Charter School"
replace SchVirtual = 0 if SchName == "Baconton Community Charter School"
replace NCESSchoolID = "130026104376" if SchName == "Atlanta Unbound Academy"
replace SchLevel = 1 if SchName == "Atlanta Unbound Academy"
replace SchType = 1 if SchName == "Atlanta Unbound Academy"
replace SchVirtual = 0 if SchName == "Atlanta Unbound Academy"
replace NCESSchoolID = "130026204377" if SchName == "D.E.L.T.A. STEAM Academy"
replace SchLevel = 1 if SchName == "D.E.L.T.A. STEAM Academy"
replace SchType = 1 if SchName == "D.E.L.T.A. STEAM Academy"
replace SchVirtual = 0 if SchName == "D.E.L.T.A. STEAM Academy"
replace NCESSchoolID = "130026304378" if SchName == "Georgia Fugees Academy Charter School"
replace SchLevel = 3 if SchName == "Georgia Fugees Academy Charter School"
replace SchType = 1 if SchName == "Georgia Fugees Academy Charter School"
replace SchVirtual = 0 if SchName == "Georgia Fugees Academy Charter School"
replace NCESSchoolID = "130025904374" if SchName == "Atlanta SMART Academy"
replace SchLevel = 2 if SchName == "Atlanta SMART Academy"
replace SchType = 1 if SchName == "Atlanta SMART Academy"
replace SchVirtual = 0 if SchName == "Atlanta SMART Academy"
replace NCESSchoolID = "130026404424" if SchName == "Northwest Classical Academy"
replace SchLevel = 1 if SchName == "Northwest Classical Academy"
replace SchType = 1 if SchName == "Northwest Classical Academy"
replace SchVirtual = 0 if SchName == "Northwest Classical Academy"

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

save "$GAdata/GA_AssmtData_2022", replace
export delimited "$GAdata/GA_AssmtData_2022", replace
clear

log close
