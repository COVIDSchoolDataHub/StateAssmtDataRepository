clear

// Define file paths

global original_files "/Users/meghancornacchia/Desktop/DataRepository/Original_Data_Files"
global NCES_files "/Users/meghancornacchia/Desktop/DataRepository/NCES_Data_Files"
global output_files "/Users/meghancornacchia/Desktop/DataRepository/Output_Data_Files"
global temp_files "/Users/meghancornacchia/Desktop/DataRepository/Temporary_Data_Files"

// 2010-2011

// Converting subject tab files to dta and appending

import delimited "$original_files/MN_OriginalData_2011_mat_rea.tab", clear

tostring grade, replace
replace grade = "0" + grade
drop schoolcountynumber
drop districtcountynumber

save "${temp_files}/MN_AssmtData_2011_mat_rea.dta", replace

import delimited "$original_files/MN_OriginalData_2011_sci.tab", clear

drop schoolcountynumber
drop districtcountynumber

save "${temp_files}/MN_AssmtData_2011_sci.dta", replace

append using "${temp_files}/MN_AssmtData_2011_sci.dta" "${temp_files}/MN_AssmtData_2011_mat_rea.dta"

// Dropping extra variables

drop testdate
drop districtcountyname
drop ecsunumber
drop ecodevrgn
drop testname
drop reportorder
drop pfasaveragescore
drop dspsaveragescore
drop sgmsaveragescore
drop vessaveragescore
drop cpssaveragescore
drop lssaveragescore
drop hnsaveragescore
drop pscsaveragescore
drop essaveragescore
drop lifsaveragescore
drop nssaverage
drop stddev
drop stderrorofmean
drop confidenceinterval
drop countabsent
drop countinvalid
drop countmedexempt
drop countnotcomplete
drop countpso
drop countrefused
drop countwronggrade
drop schoolclassification
drop gradeenrollment
drop k12enrollment
drop filterthreshold
drop publicschool
drop schoolcountyname

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
rename averagescore AvgScaleScore
rename reportcategory StudentGroup
rename reportdescription StudentSubGroup

// Dropping extra categories of analysis
drop if StudentGroup == "Mobility"
drop if StudentGroup == "Special Education" 
drop if StudentGroup == "MigrantStatus"
drop if StateAssignedDistID == "7777"
drop if StateAssignedDistID == "8888"

// Transforming Variable Values

replace SchYear = "2010-11" if SchYear == "10-11"
replace Subject = "math" if Subject == "M"
replace Subject = "read" if Subject == "R"
replace Subject = "sci" if Subject == "S"
replace GradeLevel = "G03" if GradeLevel == "03"
replace GradeLevel = "G04" if GradeLevel == "04"
replace GradeLevel = "G05" if GradeLevel == "05"
replace GradeLevel = "G06" if GradeLevel == "06"
replace GradeLevel = "G07" if GradeLevel == "07"
replace GradeLevel = "G08" if GradeLevel == "08"
drop if GradeLevel == "010"
drop if GradeLevel == "011"
drop if GradeLevel == "HS"
replace StudentGroup = "All students" if StudentGroup == "All Categories"
replace StudentGroup = "Race" if StudentGroup == "Race/Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English Proficiency"
replace StudentGroup = "Economic Status" if StudentGroup == "EconomicStatus"
replace StudentSubGroup = "All students" if StudentSubGroup == "All Students"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "1-American Indian"
replace StudentSubGroup = "Asian" if StudentSubGroup == "2-Asian / Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "4-Black"
replace StudentSubGroup = "White" if StudentSubGroup == "5-White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "3-Hispanic"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Eligible for LEP Services"
replace StudentSubGroup = "English proficient" if StudentSubGroup == "Not eligible for LEP Services"

// Generating missing variables
gen Lev5_count = ""
gen Lev5_percent = ""
gen AssmtName = "Minnesota Comprehensive Assessment II"
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
save "${output_files}/MN_AssmtData_2011.dta", replace

// Merging with NCES School Data

use "$NCES_files/NCES_2010_School.dta", clear 

keep if substr(ncesschoolid, 1, 2) == "27"

merge 1:m seasch using "${output_files}/MN_AssmtData_2011.dta", keep(match using) nogenerate

save "${output_files}/MN_AssmtData_2011.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES_2010_District.dta", clear 

keep if substr(ncesdistrictid, 1, 2) == "27"

merge 1:m state_leaid using "${output_files}/MN_AssmtData_2011.dta", keep(match using) nogenerate

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

save "${output_files}/MN_AssmtData_2011.dta", replace
export delimited using "$output_files/MN_AssmtData_2011.csv", replace