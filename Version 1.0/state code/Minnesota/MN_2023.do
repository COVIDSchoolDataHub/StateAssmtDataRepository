clear

// Define file paths

global original_files "/Users/meghancornacchia/Desktop/DataRepository/Minnesota/Original_Data_Files"
global NCES_files "/Users/meghancornacchia/Desktop/DataRepository/NCES_Data_Files"
global output_files "/Users/meghancornacchia/Desktop/DataRepository/Minnesota/Output_Data_Files"
global temp_files "/Users/meghancornacchia/Desktop/DataRepository/Minnesota/Temporary_Data_Files"

// 2022-23
/*
// Separating large subject files by datalevel sheets and combining
// Math

import excel "$original_files/MN_OriginalData_2023_mat.xlsx", sheet("State") firstrow cellrange(A1:AF201) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolNumber, replace
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
gen DataLevel = "State"
save "${temp_files}/MN_AssmtData_2023_mat_state.dta", replace

import excel "$original_files/MN_OriginalData_2023_mat.xlsx", sheet("District") firstrow cellrange(A1:AF66849) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolNumber, replace
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	replace `var' = "" if `var' == "no data"
	destring `var', replace
}
gen DataLevel = "District"
save "${temp_files}/MN_AssmtData_2023_mat_district.dta", replace

import excel "$original_files/MN_OriginalData_2023_mat.xlsx", sheet("School") firstrow cellrange(A1:AF136741) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolNumber, replace
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	replace `var' = "" if `var' == "no data"
	destring `var', replace
}
gen DataLevel = "School"
save "${temp_files}/MN_AssmtData_2023_mat_school.dta", replace

clear


append using "${temp_files}/MN_AssmtData_2023_mat_state.dta" "${temp_files}/MN_AssmtData_2023_mat_district.dta" "${temp_files}/MN_AssmtData_2023_mat_school.dta"
tostring Grade, replace
replace MCAAverageScore = "" if MCAAverageScore == "no data"
destring MCAAverageScore, replace
save "${temp_files}/MN_AssmtData_2023_mat_all.dta", replace

// Reading

import excel "$original_files/MN_OriginalData_2023_rea.xlsx", sheet("State") firstrow cellrange(A1:AF201) clear
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
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
replace MCAAverageScore = "" if MCAAverageScore == "no data"
destring MCAAverageScore, replace
gen DataLevel = "State"
save "${temp_files}/MN_AssmtData_2023_rea_state.dta", replace

import excel "$original_files/MN_OriginalData_2023_rea.xlsx", sheet("District") firstrow cellrange(A1:AF66907) clear
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
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
replace MCAAverageScore = "" if MCAAverageScore == "no data"
destring MCAAverageScore, replace
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	replace `var' = "" if `var' == "no data"
	destring `var', replace
}
gen DataLevel = "District"
save "${temp_files}/MN_AssmtData_2023_rea_district.dta", replace

import excel "$original_files/MN_OriginalData_2023_rea.xlsx", sheet("School") firstrow cellrange(A1:AF135887) clear
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
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
replace MCAAverageScore = "" if MCAAverageScore == "no data"
destring MCAAverageScore, replace
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	replace `var' = "" if `var' == "no data"
	destring `var', replace
}
gen DataLevel = "School"
save "${temp_files}/MN_AssmtData_2023_rea_school.dta", replace

clear

append using "${temp_files}/MN_AssmtData_2023_rea_state.dta" "${temp_files}/MN_AssmtData_2023_rea_district.dta" "${temp_files}/MN_AssmtData_2023_rea_school.dta"
save "${temp_files}/MN_AssmtData_2023_rea_all.dta", replace

// Science

import excel "$original_files/MN_OriginalData_2023_sci.xlsx", sheet("State") firstrow cellrange(A1:AF101) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
replace MCAAverageScore = "" if MCAAverageScore == "no data"
destring MCAAverageScore, replace
gen DataLevel = "State"
save "${temp_files}/MN_AssmtData_2023_sci_state.dta", replace

import excel "$original_files/MN_OriginalData_2023_sci.xlsx", sheet("District") firstrow cellrange(A1:AF33013) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS 
foreach var of varlist SchoolNumber SchoolName MCAAverageScore {
	replace `var' = "" if `var' == "no data"
}
destring MCAAverageScore, replace
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	replace `var' = "" if `var' == "no data"
	destring `var', replace
}
gen DataLevel = "District"
save "${temp_files}/MN_AssmtData_2023_sci_district.dta", replace

import excel "$original_files/MN_OriginalData_2023_sci.xlsx", sheet("School") firstrow cellrange(A1:AF71634) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolNumber, replace
replace MCAAverageScore = "" if MCAAverageScore == "no data"
destring MCAAverageScore, replace
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	replace `var' = "" if `var' == "no data"
	destring `var', replace
}
gen DataLevel = "School"
save "${temp_files}/MN_AssmtData_2023_sci_school.dta", replace

clear

append using "${temp_files}/MN_AssmtData_2023_sci_state.dta" "${temp_files}/MN_AssmtData_2023_sci_district.dta" "${temp_files}/MN_AssmtData_2023_sci_school.dta"
save "${temp_files}/MN_AssmtData_2023_sci_all.dta", replace

clear

// Combining all subjects

append using "${temp_files}/MN_AssmtData_2023_mat_all.dta" "${temp_files}/MN_AssmtData_2023_rea_all.dta" "${temp_files}/MN_AssmtData_2023_sci_all.dta"
save "${temp_files}/MN_AssmtData_2023_all_imported.dta", replace
*/

use "${temp_files}/MN_AssmtData_2023_all_imported.dta", clear

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

// Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

// Dropping extra categories of analysis

drop if StudentGroup == "Homeless Status"
drop if StudentGroup == "Migrant Status"
drop if StudentGroup == "Military Family Status"
drop if StudentGroup == "SLIFE Status"
drop if StudentGroup == "Special Education"

// Transforming Variable Values

replace SchYear = "2022-23" if SchYear == "22-23"
replace Subject = "math" if Subject == "MATH"
replace Subject = "ela" if Subject == "Reading"
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
replace StudentGroup = "All Students" if StudentGroup == "All Categories"
replace StudentGroup = "RaceEth" if StudentGroup == "State Race/Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English Proficiency"
replace StudentSubGroup = "All Students" if StudentSubGroup == "All students"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian Students"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian students"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American students"
replace StudentSubGroup = "White" if StudentSubGroup == "White students"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino students"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander students"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Students with two or more races"
drop if StudentSubGroup == "Other Indigenous Peoples Students"
replace StudentSubGroup = "Male" if StudentSubGroup == "Male students"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female students"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English learners"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not English learners"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Students eligible for free/reduced-price meals"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Students not eligible for free/reduced-price meals"

gen ProficientOrAbove_count = Lev3_count+Lev4_count

foreach var of varlist Lev1_count Lev2_count Lev3_count Lev4_count Lev1_percent Lev2_percent Lev3_percent Lev4_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent {
	tostring `var', replace force
	replace `var' = "*" if Filtered == "Y"
}

drop Filtered

// Generating missing variables
gen Lev5_count = ""
gen Lev5_percent = ""
replace AssmtName = "Minnesota Comprehensive Assessment III & Minnesota Test of Academic Skills"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular and Alt"
gen ProficiencyCriteria = "Levels 3 and 4"
gen ParticipationRate = ""

// Combined State School IDs
// (School ID in format to match with NCES is combination of different IDs)
gen seasch = DistrictTypeCode + StateAssignedDistID + "-" + DistrictTypeCode + StateAssignedDistID + StateAssignedSchID
gen state_leaid = "MN-" + DistrictTypeCode + StateAssignedDistID 

// Generating Student Group Counts
bysort seasch StudentGroup Grade Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

// Fixing Unmerged Schools
drop if SchName == "New Century School Secondary Program"
drop if SchName == "NLA-Carlton"
drop if SchName == "Laker Online"
drop if SchName == "Aspen House Education Program"
drop if SchName == "Wheaton Area Schools ESY"
drop if seasch == "010621-010621047"

// Saving transformed data
save "${output_files}/MN_AssmtData_2023.dta", replace

// Merging with NCES School Data

use "$NCES_files/NCES_2021_School.dta", clear

keep state_location state_fips district_agency_type school_type ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code

keep if substr(ncesschoolid, 1, 2) == "27"

merge 1:m seasch using "${output_files}/MN_AssmtData_2023.dta", keep(match using)

replace ncesschoolid = "Missing" if _merge == 2 & DataLevel == 3
drop _merge

save "${output_files}/MN_AssmtData_2023.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES_2021_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code

keep if substr(ncesdistrictid, 1, 2) == "27"

merge 1:m state_leaid using "${output_files}/MN_AssmtData_2023.dta", keep(match using) nogenerate

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
rename school_type SchType
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

// Fixing more unmerged schools
replace NCESSchoolID = "Missing/not reported" if SchName == "STEP Academy Kg-5th - Burnsville" | SchName == "Futures Sun" | SchName == "Universal Academy Middle/High"

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/MN_AssmtData_2023.dta", replace
export delimited using "$output_files/MN_AssmtData_2023.csv", replace

