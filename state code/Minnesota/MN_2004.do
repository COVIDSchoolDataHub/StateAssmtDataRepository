clear

// Define file paths

global original_files "/Users/meghancornacchia/Desktop/DataRepository/Original_Data_Files"
global NCES_files "/Users/meghancornacchia/Desktop/DataRepository/NCES_Data_Files"
global output_files "/Users/meghancornacchia/Desktop/DataRepository/Output_Data_Files"

// 2003-2004

import delimited "$original_files/MN_OriginalData_2004_all.TAB"

save "${output_files}/MN_AssmtData_2004.dta", replace

// Reformatting IDs to standard length strings

// District Code
gen districtcodebig = .
replace districtcodebig=0 if districtnumber<10
replace districtcodebig=1 if districtnumber>=10
replace districtcodebig=2 if districtnumber>=100
replace districtcodebig=3 if districtnumber>=1000

gen newdistrictnumber = string(districtnumber)

replace newdistrictnumber = "000" + newdistrictnumber if districtcodebig==0
replace newdistrictnumber = "00" + newdistrictnumber if districtcodebig==1
replace newdistrictnumber = "0" + newdistrictnumber if districtcodebig==2
replace newdistrictnumber = newdistrictnumber if districtcodebig==3

drop districtcodebig
drop districtnumber

// District Type
gen districttypebig = .
replace districttypebig=0 if districttype<10
replace districttypebig=1 if districttype>=10


gen newdistricttype = string(districttype)

replace newdistricttype = "0" + newdistricttype if districttypebig==0
replace newdistricttype = newdistricttype if districttypebig==1

drop districttypebig
drop districttype

// School ID
gen schoolcodebig = .
replace schoolcodebig=0 if schoolnumber<10
replace schoolcodebig=1 if schoolnumber>=10
replace schoolcodebig=2 if schoolnumber>=100

gen newschoolnumber = string(schoolnumber)

replace newschoolnumber = "00" + newschoolnumber if schoolcodebig==0
replace newschoolnumber = "0" + newschoolnumber if schoolcodebig==1
replace newschoolnumber = newschoolnumber if schoolcodebig==2

drop schoolcodebig
drop schoolnumber


// Relabeling variables

rename newdistricttype DistrictTypeCode
rename datayear SchYear
rename districtname DistName
rename newdistrictnumber StateAssignedDistID
rename schoolname SchName
rename newschoolnumber StateAssignedSchID
rename subject Subject
rename grade GradeLevel
rename counttested StudentSubGroup_TotalTested
rename countlevel1 Lev1_count
rename percentlevel1 Lev1_percent
rename countlevel2 Lev2_count
rename percentlevel2 Lev2_percent
rename countlevel3 Lev3_count
rename percentlevel3 Lev3_percent
rename countlevel4 Lev4_count
rename percentlevel4 Lev4_percent
rename countlevel5 Lev5_count
rename percentlevel5 Lev5_percent
rename averagescore AvgScaleScore
rename reportcategory StudentGroup
rename reportdescription StudentSubGroup

// Dropping extra variables

drop testname
drop testdate
drop reportorder
drop averagescoreprompt1
drop averagescoreprompt2
drop averagescoreprompt3
drop averagescoreprompt4
drop schoolclassification
drop gradeenrollment
drop k12enrollment
drop filterthreshold
drop publicschool
drop if StudentGroup == "Student Stability"
drop if StudentGroup == "Special Education" 
drop if StudentGroup == "MigrantStatus"

// Transforming Variable Values

replace SchYear = "2003-04" if SchYear == "03-04"
replace Subject = "math" if Subject == "M"
replace Subject = "read" if Subject == "R"
replace Subject = "wri" if Subject == "W"
recast int GradeLevel
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G07" if GradeLevel == "7"
drop if GradeLevel == "10"
drop if GradeLevel == "11"
replace StudentGroup = "All students" if StudentGroup == "All Categories"
replace StudentGroup = "Race" if StudentGroup == "Race/Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "Limited English Proficient"
replace StudentGroup = "Economic Status" if StudentGroup == "EconomicStatus"
replace StudentSubGroup = "All students" if StudentSubGroup == "All Students"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "1-American Indian"
replace StudentSubGroup = "Asian" if StudentSubGroup == "2-Asian / Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "4-Black"
replace StudentSubGroup = "White" if StudentSubGroup == "5-White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "3-Hispanic"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Eligible for LEP Services"


// Generating missing variables
gen AssmtName = "Minnesota Comprehensive Assessment"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "000"
replace DataLevel = "State" if StateAssignedDistID == "9999"
gen ProficiencyCriteria = ""
gen ProficientOrAbove_count = ""
gen ProficientOrAbove_percent = ""
gen ParticipationRate = ""

// Combined State School IDs
// (School ID in format to match with NCES is combination of different IDs)
gen seasch = DistrictTypeCode + StateAssignedDistID + StateAssignedSchID
gen state_leaid = DistrictTypeCode + StateAssignedDistID 

// Generating Student Group Counts
bysort seasch StudentGroup Grade Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

// Saving transformed data
save "${output_files}/MN_AssmtData_2004.dta", replace

// Merging with NCES School Data

use "$NCES_files/NCES_2004_School.dta", clear 

keep if ncesschoolid == "270444003269"

append using "$NCES_files/NCES_2003_School.dta"

keep if substr(ncesschoolid, 1, 2) == "27"

merge 1:m seasch using "${output_files}/MN_AssmtData_2004.dta", keep(match using) nogenerate

save "${output_files}/MN_AssmtData_2004.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES_2003_District.dta", clear 

keep if substr(ncesdistrictid, 1, 2) == "27"

merge 1:m state_leaid using "${output_files}/MN_AssmtData_2004.dta", keep(match using) nogenerate

// Removing extra variables and renaming NCES variables
drop DistrictTypeCode
rename district_agency_type DistrictType
drop year
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
drop lea_name
rename state_leaid State_leaid
rename state_location StateAbbrev
generate State = "Minnesota"
drop state_name
rename county_code CountyCode
rename school_level SchoolLevel
rename school_type SchoolType
rename charter Charter
rename virtual Virtual
rename state_fips StateFips
rename county_name CountyName

// Reordering variables and sorting data
order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

sort DataLevel StateAssignedDistID StateAssignedSchID GradeLevel Subject StudentGroup

// Saving and exporting transformed data

save "${output_files}/MN_AssmtData_2004.dta", replace
export delimited using "$output_files/MN_AssmtData_2004.csv", replace
