clear

// Define file paths

/*
global original_files "/Volumes/T7/State Test Project/Minnesota post launch/Original Data"
global NCES_files "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global output_files "/Volumes/T7/State Test Project/Minnesota post launch/Output"
global temp_files "/Volumes/T7/State Test Project/Minnesota post launch/Temp"
*/

// 2007-2008

// Converting subject tab files to dta, removing extra variables, and appending

import delimited "$original_files/MN_OriginalData_2008_mat_rea.tab", clear

recast int grade
tostring grade, replace
replace grade = "0" + grade
drop testdate
drop districtcountynumber
drop districtcountyname
drop ecsunumber
drop ecodevrgn
drop testname
drop reportorder
drop nssaveragescore
drop pfasaveragescore
drop dspsaveragescore
drop sgmsaveragescore
drop vessaveragescore
drop cpssaveragescore
drop lssaveragescore
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
drop schoolcountynumber

save "${temp_files}/MN_AssmtData_2008_mat_rea.dta", replace



import delimited "$original_files/MN_OriginalData_2008_sci.tab", clear

rename v1 datayear
drop v2
drop v3
rename v4 districtnumber
rename v5 districttype
rename v6 districtname
rename v7 schoolnumber
rename v8 schoolname
drop v9
drop v10
drop v11
drop v12
rename v13 grade
rename v14 subject
drop v15
rename v16 reportcategory
rename v17 reportdescription
rename v18 filtered
rename v19 counttested
rename v20 countlevel1
rename v21 countlevel2
rename v22 countlevel3
rename v23 countlevel4
rename v24 percentlevel1
rename v25 percentlevel2
rename v26 percentlevel3
rename v27 percentlevel4
rename v28 averagescore
foreach x of numlist 29/49 {
	drop v`x'
}

save "${temp_files}/MN_AssmtData_2008_sci.dta", replace

clear all

append using "${temp_files}/MN_AssmtData_2008_sci.dta" "${temp_files}/MN_AssmtData_2008_mat_rea.dta"


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
drop if StateAssignedDistID == "7777"
drop if StateAssignedDistID == "8888"

// Transforming Variable Values

replace SchYear = "2007-08" if SchYear == "07-08"
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
replace StudentGroup = "Migrant Status" if StudentGroup == "MigrantStatus"
replace StudentGroup = "Disability Status" if StudentGroup == "Special Education"
replace StudentGroup = "All Students" if StudentGroup == "All Categories"
replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English Proficiency"
replace StudentGroup = "Economic Status" if StudentGroup == "EconomicStatus"
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "1-American Indian"
replace StudentSubGroup = "Asian" if StudentSubGroup == "2-Asian / Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "4-Black"
replace StudentSubGroup = "White" if StudentSubGroup == "5-White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "3-Hispanic"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Eligible for LEP Services"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not eligible for LEP Services"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Eligible for Free/Reduced Priced Meals"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not eligible for Free/Reduced Priced Meals"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Receiving Special Education Services"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not receiving Special Education Services"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Eligible for Migrant Services"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not eligible for Migrant Services"

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
gen AssmtName = "Minnesota Comprehensive Assessment II"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = ""
gen Flag_CutScoreChange_sci = "N"
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
gen seasch = DistrictTypeCode + StateAssignedDistID + StateAssignedSchID
gen state_leaid = DistrictTypeCode + StateAssignedDistID 

// Generating Student Group Counts
bysort seasch StudentGroup Grade Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

// Saving transformed data
save "${output_files}/MN_AssmtData_2008.dta", replace

// Merging with NCES School Data

use "$NCES_files/NCES_2007_School.dta", clear 

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if substr(ncesschoolid, 1, 2) == "27"

merge 1:m seasch using "${output_files}/MN_AssmtData_2008.dta", keep(match using) nogenerate

save "${output_files}/MN_AssmtData_2008.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES_2007_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if substr(ncesdistrictid, 1, 2) == "27"

merge 1:m state_leaid using "${output_files}/MN_AssmtData_2008.dta", keep(match using) nogenerate

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

save "${output_files}/MN_AssmtData_2008.dta", replace
export delimited using "$output_files/MN_AssmtData_2008.csv", replace
