clear

// Define file paths

global original_files "/Users/kaitlynlucas/Desktop/Minnesota State Task"
global NCES_files "/Users/kaitlynlucas/Desktop/Minnesota State Task/NCES_MN"
global output_files "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN Output"
global temp_files "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN_Temp"

/*
// 2023-24

// Separating large subject files by datalevel sheets and combining
// Math

import excel "$original_files/MN_OriginalData_2024_mat.xlsx", sheet("State") firstrow cellrange(A1:AF201) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolNumber, replace
tostring SchoolName, replace
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
gen DataLevel = "State"
save "${temp_files}/MN_AssmtData_2024_mat_state.dta", replace

import excel "$original_files/MN_OriginalData_2024_mat.xlsx", sheet("District") firstrow cellrange(A1:AF66849) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolNumber, replace
tostring SchoolName, replace
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	destring `var', replace
}
gen DataLevel = "District"
save "${temp_files}/MN_AssmtData_2024_mat_district.dta", replace

import excel "$original_files/MN_OriginalData_2024_mat.xlsx", sheet("School") firstrow cellrange(A1:AF136741) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolNumber, replace
tostring SchoolName, replace
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	destring `var', replace
}
gen DataLevel = "School"
save "${temp_files}/MN_AssmtData_2024_mat_school.dta", replace

clear


append using "${temp_files}/MN_AssmtData_2024_mat_state.dta" "${temp_files}/MN_AssmtData_2024_mat_district.dta" "${temp_files}/MN_AssmtData_2024_mat_school.dta"
tostring Grade, replace
destring MCAAverageScore, replace
save "${temp_files}/MN_AssmtData_2024_mat_all.dta", replace

// Reading

import excel "$original_files/MN_OriginalData_2024_rea.xlsx", sheet("State") firstrow cellrange(A1:AF201) clear
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
/*
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
replace MCAAverageScore = "" if MCAAverageScore == "no data"
*/
destring MCAAverageScore, replace
gen DataLevel = "State"
save "${temp_files}/MN_AssmtData_2024_rea_state.dta", replace

import excel "$original_files/MN_OriginalData_2024_rea.xlsx", sheet("District") firstrow cellrange(A1:AF66907) clear
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
/*
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
replace MCAAverageScore = "" if MCAAverageScore == "no data"
*/
destring MCAAverageScore, replace
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	/*replace `var' = "" if `var' == "no data"*/
	destring `var', replace
}
gen DataLevel = "District"
save "${temp_files}/MN_AssmtData_2024_rea_district.dta", replace

import excel "$original_files/MN_OriginalData_2024_rea.xlsx", sheet("School") firstrow cellrange(A1:AF135887) clear
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
/*
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
replace MCAAverageScore = "" if MCAAverageScore == "no data"
*/
destring MCAAverageScore, replace
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	/*replace `var' = "" if `var' == "no data"*/
	destring `var', replace
}
gen DataLevel = "School"
save "${temp_files}/MN_AssmtData_2024_rea_school.dta", replace

clear

append using "${temp_files}/MN_AssmtData_2024_rea_state.dta" "${temp_files}/MN_AssmtData_2024_rea_district.dta" "${temp_files}/MN_AssmtData_2024_rea_school.dta"
save "${temp_files}/MN_AssmtData_2024_rea_all.dta", replace

// Science

import excel "$original_files/MN_OriginalData_2024_sci.xlsx", sheet("State") firstrow cellrange(A1:AF101) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
/*
replace SchoolNumber = "" if SchoolNumber == "no data"
replace SchoolName = "" if SchoolName == "no data"
replace MCAAverageScore = "" if MCAAverageScore == "no data"
*/
destring MCAAverageScore, replace
tostring SchoolNumber, replace
tostring SchoolName, replace
gen DataLevel = "State"
save "${temp_files}/MN_AssmtData_2024_sci_state.dta", replace

import excel "$original_files/MN_OriginalData_2024_sci.xlsx", sheet("District") firstrow cellrange(A1:AF33013) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS 
/*foreach var of varlist SchoolNumber SchoolName MCAAverageScore {
	replace `var' = "" if `var' == "no data"
}*/
destring MCAAverageScore, replace
tostring SchoolNumber, replace
tostring SchoolName, replace
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	/*replace `var' = "" if `var' == "no data"*/
	destring `var', replace
}
gen DataLevel = "District"
save "${temp_files}/MN_AssmtData_2024_sci_district.dta", replace

import excel "$original_files/MN_OriginalData_2024_sci.xlsx", sheet("School") firstrow cellrange(A1:AF71634) clear
drop CountyNumber
drop CountyName
drop ECSUNumber
drop EconomicDevelopmentRegion
drop SchoolClassification
drop FilterAll
drop CountValidScoresMTAS
drop FilterMTAS
tostring SchoolNumber, replace
tostring SchoolName, replace
/*replace MCAAverageScore = "" if MCAAverageScore == "no data"*/
destring MCAAverageScore, replace
foreach var of varlist CountLevelD CountLevelE CountLevelM CountLevelP PercentLevelD PercentLevelE PercentLevelM PercentLevelP PercentProficient {
	/*replace `var' = "" if `var' == "no data"*/
	destring `var', replace
}
gen DataLevel = "School"
save "${temp_files}/MN_AssmtData_2024_sci_school.dta", replace

clear

append using "${temp_files}/MN_AssmtData_2024_sci_state.dta" "${temp_files}/MN_AssmtData_2024_sci_district.dta" "${temp_files}/MN_AssmtData_2024_sci_school.dta"
save "${temp_files}/MN_AssmtData_2024_sci_all.dta", replace

clear

// Combining all subjects

append using "${temp_files}/MN_AssmtData_2024_mat_all.dta" "${temp_files}/MN_AssmtData_2024_rea_all.dta" "${temp_files}/MN_AssmtData_2024_sci_all.dta"
save "${temp_files}/MN_AssmtData_2024_all_imported.dta", replace
*/

use "${temp_files}/MN_AssmtData_2024_all_imported.dta", clear

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

*drop if StudentGroup == "Homeless Status"
*drop if StudentGroup == "Migrant Status"
*drop if StudentGroup == "Military Family Status"
drop if StudentGroup == "SLIFE Status"
*drop if StudentGroup == "Special Education"

// Transforming Variable Values

replace SchYear = "2023-24" if SchYear == "23-24"
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
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Family Status"
replace StudentGroup = "Disability Status" if StudentGroup == "Special Education"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
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
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students receiving special education services"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students not receiving special education services"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant students"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Students who are not migrant"
replace StudentSubGroup = "Homeless" if StudentSubGroup == "Students experiencing homelessness"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Students not experiencing homelessness"
replace StudentSubGroup = "Military" if StudentSubGroup == "Students with an active duty parent"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Students with no active duty parent"

gen ProficientOrAbove_count = Lev3_count+Lev4_count

foreach var of varlist Lev1_count Lev2_count Lev3_count Lev4_count Lev1_percent Lev2_percent Lev3_percent Lev4_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent {
	tostring `var', replace force format("%9.3g")
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
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not Applicable"
gen AssmtType = "Regular and Alt"
gen ProficiencyCriteria = "Levels 3-4"
gen ParticipationRate = "--"

// Combined State School IDs
// (School ID in format to match with NCES is combination of different IDs)
gen seasch = DistrictTypeCode + StateAssignedDistID + "-" + DistrictTypeCode + StateAssignedDistID + StateAssignedSchID
gen state_leaid = "MN-" + DistrictTypeCode + StateAssignedDistID 

// Generating Student Group Counts
bysort seasch StudentGroup Grade Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

/*
// Fixing Unmerged Schools


keep if inlist(SchName, "New Century School Secondary Program", "NLA-Carlton", "Laker Online", "Aspen House Education Program","Wheaton Area Schools ESY" ) | seasch == "010621-010621047" | SchName == "STEP Academy Kg-5th - Burnsville" | SchName == "Futures Sun" | SchName == "Universal Academy Middle/High"
save "${temp_files}/MN_AssmtData_2023_unmerged", replace
clear
use "$NCES_files/NCES_2022_School.dta"
keep if StateAbbrev == "MN"
rename st_schid seasch
replace seasch = subinstr(seasch, "MN-","",.)
merge 1:m seasch using "${temp_files}/MN_AssmtData_2023_unmerged", replace update
drop if _merge <=3

//Fixing NCES 2023 Variables

rename StateName State
rename SchoolType SchType
gen DistType = "Missing/not reported"
gen DistLocale = "Missing/not reported"
gen CountyName = "Missing/not reported"
gen CountyCode = "Missing/not reported"
label def SchVirtual -1 "Missing/not reported"
encode SchVirtual, gen(nSchVirtual)
replace nSchVirtual = -1
drop SchVirtual
rename nSchVirtual SchVirtual
destring StateFips, replace
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
save "${temp_files}/MN_AssmtData_2023_unmerged", replace
clear


//Preparing for Merge
use "${temp_files}/MN_AssmtData_2023"

drop if SchName == "New Century School Secondary Program"
drop if SchName == "NLA-Carlton"
drop if SchName == "Laker Online"
drop if SchName == "Aspen House Education Program"
drop if SchName == "Wheaton Area Schools ESY"
drop if seasch == "010621-010621047"
drop if SchName == "STEP Academy Kg-5th - Burnsville" | SchName == "Futures Sun" | SchName == "Universal Academy Middle/High"

// Saving transformed data
save "${output_files}/MN_AssmtData_2023.dta", replace
*/

// Merging with NCES School Data
save "${temp_files}/MN_AssmtData_2024", replace
clear
use "${NCES_files}/NCES_2022_School.dta", clear

keep state_location state_fips district_agency_type school_type ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if substr(ncesschoolid, 1, 2) == "27"
foreach var of varlist district_agency_type SchLevel SchVirtual school_type {
	decode `var', gen(`var'_x)
	drop `var'
	rename `var'_x `var'
}
merge 1:m seasch using "${temp_files}/MN_AssmtData_2024.dta", keep(match using)

replace ncesschoolid = "Missing" if _merge == 2 & DataLevel == 3
drop _merge


save "${temp_files}/MN_AssmtData_2024.dta", replace

// Merging with NCES District Data

use "${NCES_files}/NCES_2022_District.dta", clear 
tostring _all, replace force
destring state_fips, replace
keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if substr(ncesdistrictid, 1, 2) == "27"

merge 1:m state_leaid using "${temp_files}/MN_AssmtData_2024.dta", keep(match using) nogenerate

// Reformatting IDs
replace StateAssignedDistID = StateAssignedDistID+"-"+DistrictTypeCode
replace StateAssignedSchID = StateAssignedDistID+"-"+StateAssignedSchID

// Removing extra variables and renaming NCES variables
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

gen dname_spaces1 = DistName 
replace dname_spaces1 =strtrim(dname_spaces1) // returns var with leading and trailing blanks removed.
replace DistName = "Skyline Math and Science Academy" if DistName != dname_spaces1

/*
// Fixing more unmerged schools
*replace NCESSchoolID = "Missing/not reported" if SchName == "STEP Academy Kg-5th - Burnsville" | SchName == "Futures Sun" | SchName == "Universal Academy Middle/High"
decode SchType, gen(sSchType)
drop SchType
rename sSchType SchType
decode SchLevel, gen(sSchLevel)
drop SchLevel
rename sSchLevel SchLevel
append using "${temp_files}/MN_AssmtData_2023_unmerged"
*/

//fixing unmerged schools
replace NCESSchoolID = "270046512838" if SchName == "Aspire Academy Middle School"
replace SchType = "Regular school" if SchName == "Aspire Academy Middle School"
replace SchLevel = "Middle" if SchName == "Aspire Academy Middle School"
replace SchVirtual = "No" if SchName == "Aspire Academy Middle School"

replace NCESSchoolID = "270030912832" if SchName == "Wakanda Virtual Academy"
replace SchType = "Regular school" if SchName == "Wakanda Virtual Academy"
replace SchLevel = "Primary" if SchName == "Wakanda Virtual Academy"
replace SchVirtual = "Yes" if SchName == "Wakanda Virtual Academy"

replace NCESSchoolID = "270045412837" if SchName == "GOA School of Logic"
replace SchType = "Regular school" if SchName == "GOA School of Logic"
replace SchLevel = "Middle" if SchName == "GOA School of Logic"
replace SchVirtual = "No" if SchName == "GOA School of Logic"

replace NCESSchoolID = "270014012829" if SchName == "HGA Junior High"
replace SchType = "Regular school" if SchName == "HGA Junior High"
replace SchLevel = "Middle" if SchName == "HGA Junior High"
replace SchVirtual = "No" if SchName == "HGA Junior High"

replace NCESSchoolID = "270046405322" if SchName == "Innovation Science and Technology Academy Middle School"
replace SchType = "Regular school" if SchName == "Innovation Science and Technology Academy Middle School"
replace SchLevel = "Middle" if SchName == "Innovation Science and Technology Academy Middle School"
replace SchVirtual = "No" if SchName == "Innovation Science and Technology Academy Middle School"

replace NCESSchoolID = "270041012835" if SchName == "Compass Academy"
replace SchType = "Regular school" if SchName == "Compass Academy"
replace SchLevel = "Primary" if SchName == "Compass Academy"
replace SchVirtual = "No" if SchName == "Compass Academy"

replace NCESSchoolID = "272505012795" if SchName == "SUCCESS"
replace SchType = "Other/alternative school" if SchName == "SUCCESS"
replace SchLevel = "Middle" if SchName == "SUCCESS"
replace SchVirtual = "No" if SchName == "SUCCESS"

replace NCESSchoolID = "270036712833" if SchName == "STEP Academy 6-12 - Burnsville"
replace SchType = "Regular school" if SchName == "STEP Academy 6-12 - Burnsville"
replace SchLevel = "Middle" if SchName == "STEP Academy 6-12 - Burnsville"
replace SchVirtual = "No" if SchName == "STEP Academy 6-12 - Burnsville"

replace NCESSchoolID = "273384012803" if SchName == "East African Magnet School"
replace SchType = "Regular school" if SchName == "East African Magnet School"
replace SchLevel = "Primary" if SchName == "East African Magnet School"
replace SchVirtual = "No" if SchName == "East African Magnet School"

replace NCESSchoolID = "270042012826" if SchName == "SWMetro Level 3"
replace SchType = "Special education school" if SchName == "SWMetro Level 3"
replace SchLevel = "Primary" if SchName == "SWMetro Level 3"
replace SchVirtual = "No" if SchName == "SWMetro Level 3"

drop if SchName == "180 Degrees / Youth Shelter"

replace NCESSchoolID = "273354012789" if SchName == "Crossroads East"
replace SchType = "Other/alternative school" if SchName == "Crossroads East"
replace SchLevel = "High" if SchName == "Crossroads East"
replace SchVirtual = "No" if SchName == "Crossroads East"

replace NCESSchoolID = "274416012796" if SchName == "Virtual Instruction by Excellence Elementary"
replace SchType = "Regular school" if SchName == "Virtual Instruction by Excellence Elementary"
replace SchLevel = "Primary" if SchName == "Virtual Instruction by Excellence Elementary"
replace SchVirtual = "Yes" if SchName == "Virtual Instruction by Excellence Elementary"

replace NCESSchoolID = "274416012797" if SchName == "Virtual Instruction by Excellence Secondary"
replace SchType = "Regular school" if SchName == "Virtual Instruction by Excellence Secondary"
replace SchLevel = "High" if SchName == "Virtual Instruction by Excellence Secondary"
replace SchVirtual = "Yes" if SchName == "Virtual Instruction by Excellence Secondary"

//missing sch levels
replace SchLevel = "Middle" if SchName == "Blooming Prairie Intermediate School"
replace SchVirtual = "No" if SchName == "Blooming Prairie Intermediate School"
replace SchLevel = "Middle" if SchName == "Community School of Excellence - MS"
replace SchVirtual = "No" if SchName == "Community School of Excellence - MS"
replace SchLevel = "Primary" if SchName == "New Heights Elementary School"
replace SchVirtual = "No" if SchName == "New Heights Elementary School"
replace SchLevel = "Middle" if SchName == "Washington Technology Middle School"
replace SchVirtual = "No" if SchName == "Washington Technology Middle School"
replace SchLevel = "Primary" if SchName == "Surad Academy"
replace SchVirtual = "No" if SchName == "Surad Academy"

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
drop State_leaid seasch DistrictTypeCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/MN_AssmtData_2024.dta", replace
export delimited using "${output_files}/MN_AssmtData_2024.csv", replace
