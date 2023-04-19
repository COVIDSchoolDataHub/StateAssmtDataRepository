clear

// Define file paths

global original_files "/Users/meghancornacchia/Desktop/DataRepository/Original_Data_Files"
global NCES_files "/Users/meghancornacchia/Desktop/DataRepository/NCES_Data_Files"
global output_files "/Users/meghancornacchia/Desktop/DataRepository/Output_Data_Files"
global temp_files "/Users/meghancornacchia/Desktop/DataRepository/Temporary_Data_Files"

// 2020-2021

// Separating large subject files by datalevel sheets and combining
// Math

import excel "$original_files/MN_OriginalData_2021_mat.xlsx", sheet("State") firstrow cellrange(A2:AF194) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolNumber, replace
replace SchoolNumber = "" if SchoolNumber == "N/A"
replace SchoolName = "" if SchoolName == "N/A"
gen DataLevel = "State"
save "${temp_files}/MN_AssmtData_2021_mat_state.dta", replace

import excel "$original_files/MN_OriginalData_2021_mat.xlsx", sheet("District") firstrow cellrange(A2:AF64971) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolNumber, replace
replace SchoolNumber = "" if SchoolNumber == "N/A"
replace SchoolName = "" if SchoolName == "N/A"
gen DataLevel = "District"
save "${temp_files}/MN_AssmtData_2021_mat_district.dta", replace

import excel "$original_files/MN_OriginalData_2021_mat.xlsx", sheet("School") firstrow cellrange(A2:AF134023) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolNumber, replace
replace SchoolNumber = "" if SchoolNumber == "N/A"
replace SchoolName = "" if SchoolName == "N/A"
gen DataLevel = "School"
save "${temp_files}/MN_AssmtData_2021_mat_school.dta", replace


append using "${temp_files}/MN_AssmtData_2021_mat_state.dta" "${temp_files}/MN_AssmtData_2021_mat_district.dta" "${temp_files}/MN_AssmtData_2021_mat_school.dta"
tostring Grade, replace
replace MCAAverageScore = "" if MCAAverageScore == "N/A"
destring MCAAverageScore, replace
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	replace `var' = "" if `var' == "N/A"
	destring `var', replace
}
save "${temp_files}/MN_AssmtData_2021_mat_all.dta", replace

// Reading

import excel "$original_files/MN_OriginalData_2021_rea.xlsx", sheet("State") firstrow cellrange(A2:AF194) clear
tostring Grade, replace
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolName, replace
tostring SchoolNumber, replace
replace SchoolNumber = "" if SchoolNumber == "N/A"
replace SchoolName = "" if SchoolName == "N/A"
replace MCAAverageScore = "" if MCAAverageScore == "N/A"
destring MCAAverageScore, replace
gen DataLevel = "State"
save "${temp_files}/MN_AssmtData_2021_rea_state.dta", replace

import excel "$original_files/MN_OriginalData_2021_rea.xlsx", sheet("District") firstrow cellrange(A2:AF64951) clear
tostring Grade, replace
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolName, replace
tostring SchoolNumber, replace
replace SchoolNumber = "" if SchoolNumber == "N/A"
replace SchoolName = "" if SchoolName == "N/A"
gen DataLevel = "District"
save "${temp_files}/MN_AssmtData_2021_rea_district.dta", replace

import excel "$original_files/MN_OriginalData_2021_rea.xlsx", sheet("School") firstrow cellrange(A2:AF132883) clear
tostring Grade, replace
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolName, replace
tostring SchoolNumber, replace
replace SchoolNumber = "" if SchoolNumber == "N/A"
replace SchoolName = "" if SchoolName == "N/A"
gen DataLevel = "School"
save "${temp_files}/MN_AssmtData_2021_rea_school.dta", replace

append using "${temp_files}/MN_AssmtData_2021_rea_state.dta" "${temp_files}/MN_AssmtData_2021_rea_district.dta" "${temp_files}/MN_AssmtData_2021_rea_school.dta"
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	destring `var', replace
}
save "${temp_files}/MN_AssmtData_2021_rea_all.dta", replace

// Science

import excel "$original_files/MN_OriginalData_2021_sci.xlsx", sheet("State") firstrow cellrange(A2:AF98) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
replace SchoolNumber = "" if SchoolNumber == "N/A"
replace SchoolName = "" if SchoolName == "N/A"
replace MCAAverageScore = "" if MCAAverageScore == "N/A"
destring MCAAverageScore, replace
gen DataLevel = "State"
save "${temp_files}/MN_AssmtData_2021_sci_state.dta", replace

import excel "$original_files/MN_OriginalData_2021_sci.xlsx", sheet("District") firstrow cellrange(A2:AF32061) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS 
foreach var of varlist SchoolNumber SchoolName MCAAverageScore {
	replace `var' = "" if `var' == "N/A"
}
destring MCAAverageScore, replace
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	replace `var' = "" if `var' == "N/A"
	destring `var', replace
}
gen DataLevel = "District"
save "${temp_files}/MN_AssmtData_2021_sci_district.dta", replace

import excel "$original_files/MN_OriginalData_2021_sci.xlsx", sheet("School") firstrow cellrange(A2:AF70230) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolNumber, replace
replace MCAAverageScore = "" if MCAAverageScore == "N/A"
destring MCAAverageScore, replace
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	replace `var' = "" if `var' == "N/A"
	destring `var', replace
}
gen DataLevel = "School"
save "${temp_files}/MN_AssmtData_2021_sci_school.dta", replace

append using "${temp_files}/MN_AssmtData_2021_sci_state.dta" "${temp_files}/MN_AssmtData_2021_sci_district.dta" "${temp_files}/MN_AssmtData_2021_sci_school.dta"
save "${temp_files}/MN_AssmtData_2021_sci_all.dta", replace


// Combining all subjects

append using "${temp_files}/MN_AssmtData_2021_mat_all.dta" "${temp_files}/MN_AssmtData_2021_rea_all.dta" "${temp_files}/MN_AssmtData_2021_sci_all.dta"
save "${output_files}/MN_AssmtData_2021.dta", replace


use "${output_files}/MN_AssmtData_2021.dta"

// Reformatting IDs to standard length strings

// District Code

gen districtcodebig = .
replace districtcodebig=0 if DistrictNumber<10
replace districtcodebig=1 if DistrictNumber>=10
replace districtcodebig=2 if DistrictNumber>=100
replace districtcodebig=3 if DistrictNumber>=1000

gen StateAssignedDistID = string(DistrictNumber)

replace StateAssignedDistID = "000" + StateAssignedDistID if districtcodebig==0
replace StateAssignedDistID = "00" + StateAssignedDistID if districtcodebig==1
replace StateAssignedDistID = "0" + StateAssignedDistID if districtcodebig==2
replace StateAssignedDistID = StateAssignedDistID if districtcodebig==3

drop districtcodebig
drop DistrictNumber

// District Type

recast int DistrictType
gen districttypebig = .
replace districttypebig=0 if DistrictType<10
replace districttypebig=1 if DistrictType>=10


tostring DistrictType, replace

replace DistrictType = "0" + DistrictType if districttypebig==0
replace DistrictType = DistrictType if districttypebig==1

drop districttypebig
rename DistrictType DistrictTypeCode

// School ID

gen schoolcodebig = .
destring SchoolNumber, replace 
replace schoolcodebig=0 if SchoolNumber<10
replace schoolcodebig=1 if SchoolNumber>=10
replace schoolcodebig=2 if SchoolNumber>=100

tostring SchoolNumber, replace

replace SchoolNumber = "00" + SchoolNumber if schoolcodebig==0
replace SchoolNumber = "0" + SchoolNumber if schoolcodebig==1
replace SchoolNumber = SchoolNumber if schoolcodebig==2

drop schoolcodebig


// Renaming variables and removing labels

rename DataYear SchYear
rename DistrictName DistName
rename SchoolNumber StateAssignedSchID
rename SchoolName SchName
rename TestName AssmtName
rename Grade GradeLevel
rename StudentGroup StudentSubGroup
rename GroupCategory StudentGroup
drop TotalTested
rename CountValidScoresMCA StudentSubGroup_TotalTested
rename FilterMCA Filtered
rename CountLevelD Lev1_count
rename CountLevelP Lev2_count
rename CountLevelM Lev3_count
rename CountLevelE Lev4_count
rename PercentProficient ProficientOrAbove_percent
rename PercentLevelD Lev1_percent
rename PercentLevelP Lev2_percent
rename PercentLevelM Lev3_percent
rename PercentLevelE Lev4_percent
rename MCAAverageScore AvgScaleScore
foreach var of varlist _all {
	label var `var' ""
}

// Dropping extra categories of analysis

drop if StudentGroup == "Homeless Status"
drop if StudentGroup == "Migrant Status"
drop if StudentGroup == "Military Family Status"
drop if StudentGroup == "SLIFE Status"
drop if StudentGroup == "Special Education"

// Transforming Variable Values

replace SchYear = "2020-21" if SchYear == "20-21"
replace Subject = "math" if Subject == "MATH"
replace Subject = "read" if Subject == "Reading"
replace Subject = "sci" if Subject == "Science"
tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"
drop if GradeLevel == "10"
drop if GradeLevel == "11"
drop if GradeLevel == "HS"
drop if GradeLevel == "0"
replace StudentGroup = "All students" if StudentGroup == "All Categories"
replace StudentGroup = "Race" if StudentGroup == "Race/Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English Proficiency"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native students"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian students"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American students"
replace StudentSubGroup = "White" if StudentSubGroup == "White students"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino students"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander students"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Students with two or more races"
replace StudentSubGroup = "Male" if StudentSubGroup == "Male students"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female students"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English learners"
replace StudentSubGroup = "English proficient" if StudentSubGroup == "Not English learners"

// Generating missing variables
gen Lev5_count = ""
gen Lev5_percent = ""
replace AssmtName = "Minnesota Comprehensive Assessment III"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = ""
gen ProficientOrAbove_count = ""
gen ParticipationRate = ""

// Combined State School IDs
// (School ID in format to match with NCES is combination of different IDs)
gen seasch = DistrictTypeCode + StateAssignedDistID + "-" + DistrictTypeCode + StateAssignedDistID + StateAssignedSchID
gen state_leaid = "MN-" + DistrictTypeCode + StateAssignedDistID 

// Generating Student Group Counts
bysort seasch StudentGroup Grade Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

// Drop Extended School Year Observations
drop if seasch == "012753-012753025"

// Saving transformed data
save "${output_files}/MN_AssmtData_2021.dta", replace

// Merging with NCES School Data

use "$NCES_files/NCES_2020_School.dta", clear 

keep if substr(ncesschoolid, 1, 2) == "27"

merge 1:m seasch using "${output_files}/MN_AssmtData_2021.dta", keep(match using) nogenerate

save "${output_files}/MN_AssmtData_2021.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES_2020_District.dta", clear 

keep if substr(ncesdistrictid, 1, 2) == "27"

merge 1:m state_leaid using "${output_files}/MN_AssmtData_2021.dta", keep(match using) nogenerate

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

save "${output_files}/MN_AssmtData_2021.dta", replace
export delimited using "$output_files/MN_AssmtData_2021.csv", replace

