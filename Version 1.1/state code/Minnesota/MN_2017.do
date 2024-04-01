clear

// Define file paths

/*
global original_files "/Volumes/T7/State Test Project/Minnesota post launch/Original Data"
global NCES_files "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global output_files "/Volumes/T7/State Test Project/Minnesota post launch/Output"
global temp_files "/Volumes/T7/State Test Project/Minnesota post launch/Temp"
*/


// 2016-2017

// Converting subject tab files to dta, standardizing formats, and appending

import delimited "$original_files/MN_OriginalData_2017_mat.tab", clear
tostring grade, replace
replace grade = "0" + grade
drop schoolcountynumber
drop districtcountynumber
save "${temp_files}/MN_AssmtData_2017_mat.dta", replace

import delimited "$original_files/MN_OriginalData_2017_rea.tab", clear
tostring grade, replace
replace grade = "0" + grade
drop schoolcountynumber
drop districtcountynumber
save "${temp_files}/MN_AssmtData_2017_rea.dta", replace

import delimited "$original_files/MN_OriginalData_2017_sci.tab", clear
drop schoolcountynumber
drop districtcountynumber
rename countleveld countlevel1
rename countlevelp countlevel2
rename countlevelm countlevel3
rename countlevele countlevel4
rename percentleveld percentlevel1
rename percentlevelp percentlevel2
rename percentlevelm percentlevel3
rename percentlevele percentlevel4
save "${temp_files}/MN_AssmtData_2017_sci.dta", replace

clear

append using "${temp_files}/MN_AssmtData_2017_mat.dta" "${temp_files}/MN_AssmtData_2017_rea.dta" "${temp_files}/MN_AssmtData_2017_sci.dta"

// Drop charter authorizer level observations
drop if summarylevel == "charterAuthorizer"

// Dropping extra variables

drop testdate
drop districtcountyname
drop ecsunumber
drop ecodevrgn
drop reportorder
drop nseaveragescore
drop gmsaveragescore
drop vssaveragescore
drop pscsaveragescore
drop essaveragescore
drop lifsaveragescore
drop possaveragescore
drop poesaveragescore
drop intsaveragescore
drop sflsaveragescore
drop ialsaveragescore
drop eilsaveragescore
drop hilsaveragescore
drop nopsaveragescore
drop algsaveragescore
drop dapsaveragescore
drop lssaveragescore
drop stddev
drop stderrorofmean
drop confidenceinterval
drop countabsent
drop countinvalid
drop countmedexempt
drop countnotcomplete
drop countrefused
drop countwronggrade
drop schoolclassification
drop gradeenrollment
drop k12enrollment
drop filterthreshold
drop publicschool
drop schoolcountyname
drop infsaveragescore
drop testname
drop summarylevel
drop countinvalidstudentbehavior
drop countinvaliddevice
drop countinvalidother
drop countrefusedparent
drop countrefusedstudent
drop countnotattempted
drop countnotenrolled

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
*drop if StudentGroup == "Special Education" 
*drop if StudentGroup == "MigrantStatus"
*drop if StudentGroup == "Homeless"
drop if StudentGroup == "SLIFE"
drop if StateAssignedDistID == "7777"
drop if StateAssignedDistID == "8888"

// Transforming Variable Values

replace SchYear = "2016-17" if SchYear == "16-17"
replace Subject = "math" if Subject == "M"
replace Subject = "ela" if Subject == "R"
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
replace StudentGroup = "All Students" if StudentGroup == "All Categories"
replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English Proficiency"
replace StudentGroup = "Economic Status" if StudentGroup == "EconomicStatus"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless"
replace StudentGroup = "Migrant Status" if StudentGroup == "MigrantStatus"
replace StudentGroup = "Disability Status" if StudentGroup == "Special Education"
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "I-American Indian/Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "A-Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "B-Black/African American"
replace StudentSubGroup = "White" if StudentSubGroup == "W-White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "H-Hispanic/Latino"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "P-Native Hawaiian/Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "M-Two or More Races"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Eligible for EL Services"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not eligible for EL Services"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Eligible for Free/Reduced Priced Meals"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not eligible for Free/Reduced Priced Meals"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Receiving Special Education Services"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not receiving Special Education Services"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Eligible for Migrant Services"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not eligible for Migrant Services"
replace StudentSubGroup = "Homeless" if StudentSubGroup == "Identified as Homeless"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Identified as Homeless"

gen ProficientOrAbove_count = Lev3_count+Lev4_count

foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent {
	replace `var' = `var'/100
}

gen ProficientOrAbove_percent = Lev3_percent+Lev4_percent

foreach var of varlist Lev1_count Lev2_count Lev3_count Lev4_count Lev1_percent Lev2_percent Lev3_percent Lev4_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent {
	tostring `var', replace force format("%9.3g")
	replace `var' = "*" if filtered == "Y"
}

drop filtered

// Generating missing variables
gen Lev5_count = ""
gen Lev5_percent = ""
gen AssmtName = "Minnesota Comprehensive Assessment III"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = ""
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"
gen ParticipationRate = "--"

// Data Levels
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "000"
replace DataLevel = "State" if StateAssignedDistID == "9999"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

// Combined State School IDs
// (School ID in format to match with NCES is combination of different IDs)
gen seasch = DistrictTypeCode + StateAssignedDistID + "-" + DistrictTypeCode + StateAssignedDistID + StateAssignedSchID
gen state_leaid = "MN-" + DistrictTypeCode + StateAssignedDistID 

// Generating Student Group Counts
bysort seasch StudentGroup Grade Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

// Dropping extra observations
local dropping "MN-240002 MN-240008 MN-847659 MN-847661 MN-847662 MN-847663 MN-847664 MN-847665 MN-847667 MN-847668 MN-847669 MN-847670 MN-847671"

foreach obs of local dropping {
	drop if state_leaid == "`obs'"
}

// Saving transformed data
save "${output_files}/MN_AssmtData_2017.dta", replace

// Merging with NCES School Data

use "$NCES_files/NCES_2016_School.dta", clear 

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if substr(ncesschoolid, 1, 2) == "27"

merge 1:m seasch using "${output_files}/MN_AssmtData_2017.dta", keep(match using) nogenerate

save "${output_files}/MN_AssmtData_2017.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES_2016_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if substr(ncesdistrictid, 1, 2) == "27"

merge 1:m state_leaid using "${output_files}/MN_AssmtData_2017.dta", keep(match using) nogenerate

// Reformatting IDs
replace StateAssignedDistID = StateAssignedDistID+"-"+DistrictTypeCode
replace StateAssignedSchID = StateAssignedDistID+"-"+StateAssignedSchID

// Removing extra variables and renaming NCES variables
drop DistrictTypeCode
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename state_location StateAbbrev
generate State = "Minnesota"
rename county_code CountyCode
*rename school_type SchType
rename state_fips StateFips
rename county_name CountyName

// Fixing missing state data
replace StateAbbrev = "MN" if DataLevel == 1
replace StateFips = 27 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
replace seasch = "" if DataLevel != 3
replace State_leaid = "" if DataLevel == 1

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
drop State_leaid seasch
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/MN_AssmtData_2017.dta", replace
export delimited using "$output_files/MN_AssmtData_2017.csv", replace
