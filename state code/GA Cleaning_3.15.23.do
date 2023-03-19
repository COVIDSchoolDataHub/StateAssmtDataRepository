clear all
log using georgia_cleaning.log, replace text

//2010-2011
import delimited "/Users/miramehta/Documents/GA State Testing Data/GA_OriginalData_2011_all.csv"

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
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
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = ""
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "School" if StateAssignedSchID != "ALL"
gen AvgScaleScore =.
gen StudentGroup = ""
gen StudentGroup_TotalTested =.

//Passing Rates
gen ProficiencyCriteria = "Students in Levels 2 and 3 are considered proficient."
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev2_count + Lev3_count
gen ProficientOrAbove_percent = Lev2_percent + Lev3_percent
gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
replace Lev1_count = "--" if Lev1_count == ""
replace Lev2_count = "--" if Lev2_count == ""
replace Lev3_count = "--" if Lev3_count == ""

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
drop if Subject == "Social Studies"

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2011.dta"

//Clean NCES Data
use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2011_School.dta"
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2011_School_GA.dta"

use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2011_District.dta"
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2011_District_GA"

//Merge Data
use "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2011.dta"
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedSchID StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2011_School_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2011_District_GA.dta", gen(merge2)
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

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

order State StateAbbrev StateFips NCESDistrictID DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2011", replace
export delimited "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2011"
clear

//2011-2012
import delimited "/Users/miramehta/Documents/GA State Testing Data/GA_OriginalData_2012_all.csv"

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
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
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = ""
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "School" if StateAssignedSchID != "ALL"
gen AvgScaleScore =.
gen StudentGroup = ""
gen StudentGroup_TotalTested =.

//Passing Rates
gen ProficiencyCriteria = "Students in Levels 2 and 3 are considered proficient."
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev2_count + Lev3_count
gen ProficientOrAbove_percent = Lev2_percent + Lev3_percent
gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
replace Lev1_count = "--" if Lev1_count == ""
replace Lev2_count = "--" if Lev2_count == ""
replace Lev3_count = "--" if Lev3_count == ""

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
drop if Subject == "Social Studies"

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2012.dta"

//Clean NCES Data
use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2012_School.dta"
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2012_School_GA.dta"

use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2012_District.dta"
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2012_District_GA"

//Merge Data
use "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2012.dta"
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedSchID StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2012_School_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2012_District_GA.dta", gen(merge2)
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

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

order State StateAbbrev StateFips NCESDistrictID DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2012", replace
export delimited "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2012"
clear

//2012-2013
import delimited "/Users/miramehta/Documents/GA State Testing Data/GA_OriginalData_2013_all.csv"

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
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
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = ""
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "School" if StateAssignedSchID != "ALL"
gen AvgScaleScore =.
gen StudentGroup = ""
gen StudentGroup_TotalTested =.

//Passing Rates
gen ProficiencyCriteria = "Students in Levels 2 and 3 are considered proficient."
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev2_count + Lev3_count
gen ProficientOrAbove_percent = Lev2_percent + Lev3_percent
gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
replace Lev1_count = "--" if Lev1_count == ""
replace Lev2_count = "--" if Lev2_count == ""
replace Lev3_count = "--" if Lev3_count == ""

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
drop if Subject == "Social Studies"

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2013.dta"

//Clean NCES Data
use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2013_School.dta"
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2013_School_GA.dta"

use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2013_District.dta"
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2013_District_GA"

//Merge Data
use "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2013.dta"
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedSchID StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2013_School_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2013_District_GA.dta", gen(merge2)
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

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

order State StateAbbrev StateFips NCESDistrictID DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2013", replace
export delimited "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2013"
clear

//2013-2014
import delimited "/Users/miramehta/Documents/GA State Testing Data/GA_OriginalData_2014_all.csv"

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
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
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = ""
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "School" if StateAssignedSchID != "ALL"
gen AvgScaleScore =.
gen StudentGroup = ""
gen StudentGroup_TotalTested =.

//Passing Rates
gen ProficiencyCriteria = "Students in Levels 2 and 3 are considered proficient."
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev2_count + Lev3_count
gen ProficientOrAbove_percent = Lev2_percent + Lev3_percent
gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
replace Lev1_count = "--" if Lev1_count == ""
replace Lev2_count = "--" if Lev2_count == ""
replace Lev3_count = "--" if Lev3_count == ""

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
drop if Subject == "Social Studies"

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2014.dta"

//Clean NCES Data
use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2014_School.dta"
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2014_School_GA.dta"

use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2014_District.dta"
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2014_District_GA"

//Merge Data
use "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2014.dta"
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedSchID StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2014_School_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2014_District_GA.dta", gen(merge2)
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

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

order State StateAbbrev StateFips NCESDistrictID DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2014", replace
export delimited "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2014"
clear

//2014-2015
import delimited "/Users/miramehta/Documents/GA State Testing Data/GA_OriginalData_2015_all.csv"

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
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_oth = "Y"
gen AssmtType = "Regular"
gen DataLevel = ""
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "School" if StateAssignedSchID != "ALL"
gen AvgScaleScore =.
gen StudentGroup = ""
gen StudentGroup_TotalTested =.

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
replace Proficient_Count = "" if Lev3_count == "*"
replace Proficient_Count = "" if Lev3_count == "--"
replace Distinguished_Count = "" if Lev4_count == "*"
replace Distinguished_Count = "" if Lev4_count == "--"
destring Proficient_Count, replace
destring Distinguished_Count, replace

gen ProficiencyCriteria = "Students in Levels 3 and 4 are considered proficient."
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Proficient_Count + Distinguished_Count if Proficient_Count !=. & Distinguished_Count !=.
drop Proficient_Count Distinguished_Count
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
gen ParticipationRate =.

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
drop if Subject == "Social Studies"

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2015.dta"

//Clean NCES Data
use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2015_School.dta"
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename seasch StateAssignedSchID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2015_School_GA.dta"

use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2015_District.dta"
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid StateAssignedDistID
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2015_District_GA"

//Merge Data
use "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2015.dta"
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedSchID StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2015_School_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2015_District_GA.dta", gen(merge2)
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

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

order State StateAbbrev StateFips NCESDistrictID DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2015", replace
export delimited "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2015"
clear

//2015-2016
import delimited "/Users/miramehta/Documents/GA State Testing Data/GA_OriginalData_2016_all.csv"

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
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = ""
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "School" if StateAssignedSchID != "ALL"
gen AvgScaleScore =.
gen StudentGroup = ""
gen StudentGroup_TotalTested =.

//Passing Rates
gen ProficiencyCriteria = "Students in Levels 3 and 4 are considered proficient."
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev3_count + Lev4_count
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
tostring Lev4_count, replace
replace Lev1_count = "--" if Lev1_count == ""
replace Lev2_count = "--" if Lev2_count == ""
replace Lev3_count = "--" if Lev3_count == ""
replace Lev4_count = "--" if Lev4_count == ""

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
drop if Subject == "Social Studies"

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2016.dta"

//Clean NCES Data
use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2016_School.dta"
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
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2016_School_GA.dta"

use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2016_District.dta"
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2016_District_GA"

//Merge Data
use "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2016.dta"
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedSchID StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2016_School_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2016_District_GA.dta", gen(merge2)
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

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

order State StateAbbrev StateFips NCESDistrictID DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2016", replace
export delimited "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2016"
clear

//2016-2017
import delimited "/Users/miramehta/Documents/GA State Testing Data/GA_OriginalData_2017_all.csv"

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
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = ""
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "School" if StateAssignedSchID != "ALL"
gen AvgScaleScore =.
gen StudentGroup = ""
gen StudentGroup_TotalTested =.

//Passing Rates
gen ProficiencyCriteria = "Students in Levels 3 and 4 are considered proficient."
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev3_count + Lev4_count
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
tostring Lev4_count, replace
replace Lev1_count = "--" if Lev1_count == ""
replace Lev2_count = "--" if Lev2_count == ""
replace Lev3_count = "--" if Lev3_count == ""
replace Lev4_count = "--" if Lev4_count == ""

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
drop if Subject == "Social Studies"

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2017.dta"

//Clean NCES Data
use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2017_School.dta"
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
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2017_School_GA.dta"

use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2017_District.dta"
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2017_District_GA"

//Merge Data
use "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2017.dta"
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedSchID StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2017_School_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2017_District_GA.dta", gen(merge2)
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

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

order State StateAbbrev StateFips NCESDistrictID DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2017", replace
export delimited "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2017"
clear

//2017-2018
import delimited "/Users/miramehta/Documents/GA State Testing Data/GA_OriginalData_2018_all.csv"

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
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = ""
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "School" if StateAssignedSchID != "ALL"
gen AvgScaleScore =.
gen StudentGroup = ""
gen StudentGroup_TotalTested =.

//Passing Rates
gen ProficiencyCriteria = "Students in Levels 3 and 4 are considered proficient."
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Lev3_count + Lev4_count
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
gen ParticipationRate =.

//Missing Data
tostring Lev1_count, replace
tostring Lev2_count, replace
tostring Lev3_count, replace
tostring Lev4_count, replace
replace Lev1_count = "--" if Lev1_count == ""
replace Lev2_count = "--" if Lev2_count == ""
replace Lev3_count = "--" if Lev3_count == ""
replace Lev4_count = "--" if Lev4_count == ""

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
drop if Subject == "Social Studies"

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2018.dta"

//Clean NCES Data
use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2018_School.dta"
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
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2018_School_GA.dta"

use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2018_District.dta"
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2018_District_GA"

//Merge Data
use "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2018.dta"
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedSchID StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2018_School_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2018_District_GA.dta", gen(merge2)
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

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

order State StateAbbrev StateFips NCESDistrictID DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2018", replace
export delimited "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2018"
clear

//2018-2019
import delimited "/Users/miramehta/Documents/GA State Testing Data/GA_OriginalData_2019_all.csv"

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
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = ""
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "School" if StateAssignedSchID != "ALL"
gen AvgScaleScore =.
gen StudentGroup = ""
gen StudentGroup_TotalTested =.

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
replace Proficient_Count = "" if Lev3_count == "*"
replace Proficient_Count = "" if Lev3_count == "--"
replace Distinguished_Count = "" if Lev4_count == "*"
replace Distinguished_Count = "" if Lev4_count == "--"
destring Proficient_Count, replace
destring Distinguished_Count, replace

gen ProficiencyCriteria = "Students in Levels 3 and 4 are considered proficient."
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Proficient_Count + Distinguished_Count if Proficient_Count !=. & Distinguished_Count !=.
drop Proficient_Count Distinguished_Count
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
gen ParticipationRate =.

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
drop if Subject == "Social Studies"

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2019.dta"

//Clean NCES Data
use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2018_School.dta"
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
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2019_School_GA.dta"

use "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2019_District.dta"
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2019_District_GA"

//Merge Data
use "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2019.dta"
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedSchID StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2019_School_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES Data Prior to 2020-21/NCES_2019_District_GA.dta", gen(merge2)
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

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

order State StateAbbrev StateFips NCESDistrictID DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2019", replace
export delimited "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2019"
clear

//2020-2021
import delimited "/Users/miramehta/Documents/GA State Testing Data/GA_OriginalData_2021_all.csv"

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
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = ""
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "School" if StateAssignedSchID != "ALL"
gen AvgScaleScore =.
gen StudentGroup = ""
gen StudentGroup_TotalTested =.

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
replace Proficient_Count = "" if Lev3_count == "*"
replace Proficient_Count = "" if Lev3_count == "--"
replace Distinguished_Count = "" if Lev4_count == "*"
replace Distinguished_Count = "" if Lev4_count == "--"
destring Proficient_Count, replace
destring Distinguished_Count, replace

gen ProficiencyCriteria = "Students in Levels 3 and 4 are considered proficient."
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Proficient_Count + Distinguished_Count if Proficient_Count !=. & Distinguished_Count !=.
drop Proficient_Count Distinguished_Count
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
gen ParticipationRate =.

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
drop if Subject == "Social Studies"

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2021.dta"
clear

//Clean NCES Data
import delimited "/Users/miramehta/Documents/NCES District and School Demographics/NCES_2020-2021_School_Demographics_opt.csv"
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
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES_2021_School_GA.dta"
clear

import delimited "/Users/miramehta/Documents/NCES District and School Demographics/NCES_2020-2021_District_Demographics_opt.csv"
drop if state_location != "GA"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 7)
drop state_leaid
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
save "/Users/miramehta/Documents/NCES District and School Demographics/NCES_2021_District_GA"
clear

//Merge Data
use "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2021.dta"
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedSchID StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES_2021_School_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedDistID using "/Users/miramehta/Documents/NCES District and School Demographics/NCES_2021_District_GA.dta", gen(merge2)
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

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "ALL" if StateAssignedSchID == "."
replace StateAssignedDistID = "ALL" if StateAssignedDistID == "."

order State StateAbbrev StateFips NCESDistrictID DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2021", replace
export delimited "/Users/miramehta/Documents/GA State Testing Data/GA_AssmtData_2021"
clear

log close
