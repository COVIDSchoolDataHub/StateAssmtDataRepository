
//Name: Pennsylvania 2024 State Assessment
//purpose: Cleaning PA State Assessment Data
//author: Mikael Oberlin
//date created: 11/13/24

clear all 
set more off

global Abbrev "PA"
global years 2015 2016 2017 2018 2019 2021 2022 2023 2024
global Original "/Users/mikaeloberlin/Desktop/Pennsylvania/Original"
global NCES "/Users/mikaeloberlin/Desktop/Pennsylvania/NCES"
global Output "/Users/mikaeloberlin/Desktop/Pennsylvania/Output"
global Temp "/Users/mikaeloberlin/Desktop/Pennsylvania/Temp"

cd "/Users/mikaeloberlin/Desktop/Pennsylvania/"
capture log close
log using 2024_PA, replace

//2023-2024
// Import Original Data Files
//School import
import excel "$Original/PA_OriginalData_2024_School.xlsx", cellrange(A5) firstrow clear

gen DataLevel = "School"
drop County

save "$Temp/PA_2024_School.dta", replace


// District import

import excel "$Original/PA_OriginalData_2024_District.xlsx", cellrange(A5) firstrow clear

gen SchoolName = "All Schools"
gen SchoolNumber = ""
gen DataLevel = "District"
drop County
drop N

save "$Temp/PA_2024_District.dta", replace

// State import
import excel "$Original/PA_OriginalData_2024_State.xlsx", cellrange(A4) firstrow clear

gen AUN = .
gen DistrictName = "All Districts"
gen SchoolName = "All Schools"
gen SchoolNumber = ""
gen DataLevel = "State"
rename PercentProficientandabove PercentProficientandabove
drop if Subject == ""

save "$Temp/PA_2024_State.dta", replace


// Appending All DataLevels
clear
append using "$Temp/PA_2024_School.dta" "$Temp/PA_2024_District.dta" "$Temp/PA_2024_State.dta"
save "$Temp/PA_2024_All.dta", replace
*/

use "$Temp/PA_2024_All.dta", clear

// Relabelling variables
rename AUN StateAssignedDistID
rename Group StudentSubGroup
rename Grade GradeLevel
rename NumberScored StudentSubGroup_TotalTested
rename PercentAdvanced Lev4_percent
rename PercentProficient Lev3_percent
rename PercentBasic Lev2_percent
rename PercentBelowBasic Lev1_percent
rename SchoolNumber StateAssignedSchID
rename DistrictName DistName
rename SchoolName SchName
rename PercentProficientandabove ProficientOrAbove_percent

// Transforming variables
gen SchYear = "2023-24" 
drop Year
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"
replace GradeLevel = "G0" + GradeLevel
replace GradeLevel = "G38" if GradeLevel == "G0Total"
gen StudentGroup = "Gender"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American (not Hispanic)"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic (any race)"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-ethnic (not Hispanic)"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian / Alaskan Native (not Hispanic)"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or other Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White (not Hispanic)"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian (not Hispanic)"
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Gender" if inlist(StudentSubGroup, "Male", "Female")
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ELL"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"

forvalues n = 1/4{
	replace Lev`n'_percent = Lev`n'_percent/100
	gen Lev`n'_count = round(Lev`n'_percent * StudentSubGroup_TotalTested)
}

replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
gen ProficientOrAbove_count = round(ProficientOrAbove_percent * StudentSubGroup_TotalTested)

foreach var of varlist Lev1_percent Lev1_count Lev2_percent Lev2_count Lev3_percent Lev3_count Lev4_percent Lev4_count ProficientOrAbove_percent ProficientOrAbove_count {
	gen s`var' = string(`var',"%9.3g")
	replace s`var' = "*" if s`var' == "." & StudentSubGroup_TotalTested < 11
	drop `var'
	rename s`var' `var'
}

// Generating missing variables
gen AssmtName = "Pennsylvania System of School Assessment"
gen AssmtType = "Regular"
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3-4"
gen ParticipationRate = "--"
gen Lev5_count = ""
gen Lev5_percent = ""
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"

// Relabelling Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

// Generating StudentGroup count
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = 000000 if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
drop AllStudents_Tested

// NCES merging

// Generate ID to match NCES
tostring StateAssignedDistID, gen(state_leaid)
gen seasch = state_leaid+"-"+substr(StateAssignedSchID,-4,4)
replace state_leaid = "PA-"+state_leaid

save "$Output/PA_AssmtData_2024.dta", replace

// Merging with NCES School Data
use "$NCES/NCES_2022_School.dta", clear
rename SchVirtual SchVirtual_n
decode district_agency_type, gen (DistType)
drop district_agency_type
rename DistType district_agency_type
merge 1:1 ncesdistrictid ncesschoolid using "$NCES/NCES_2021_School.dta", keepusing (county_code county_name district_agency_type SchVirtual)
drop if state_location != "PA"
replace SchVirtual_n = SchVirtual if inlist(SchVirtual_n, -1, .)
drop SchVirtual
rename SchVirtual_n SchVirtual
rename school_type SchType
keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

merge 1:m seasch using "$Output/PA_AssmtData_2024.dta", keep(match using)
drop _merge

save "$Output/PA_AssmtData_2024.dta", replace

// Merging with NCES District Data

use "$NCES/NCES_2022_District.dta", clear
merge 1:1 ncesdistrictid using "$NCES/NCES_2021_District.dta", keepusing (county_code county_name DistCharter)
drop if state_location != "PA"

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter DistLocale county_name county_code

merge 1:m state_leaid using "$Output/PA_AssmtData_2024.dta", keep(match using) nogenerate

// Renaming NCES variables
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename state_location StateAbbrev
gen State = "Pennsylvania"
rename county_code CountyCode
rename state_fips StateFips
rename county_name CountyName

// Final Cleaning
replace StateAbbrev = "PA" if missing(StateAbbrev)
replace StateFips = 42 if missing(StateFips)
replace SchName = lower(SchName)
replace SchName = proper(SchName)
replace DistName = lower(DistName)
replace DistName = proper(DistName)
drop seasch State_leaid

//New Schools
replace NCESSchoolID = "421053010035" if SchName == "Galeton Area Sch"
replace SchType = 1 if SchName == "Galeton Area Sch"
replace SchLevel = 1 if SchName == "Galeton Area Sch"
replace SchVirtual = 0 if SchName == "Galeton Area Sch"

replace NCESSchoolID = "421053010036" if SchName == "Galeton Jshs"
replace SchType = 1 if SchName == "Galeton Jshs"
replace SchLevel = 3 if SchName == "Galeton Jshs"
replace SchVirtual = 0 if SchName == "Galeton Jshs"

replace NCESSchoolID = "428939810041" if SchName == "Northeast Secure Treatment Unit"
replace SchType = 2 if SchName == "Northeast Secure Treatment Unit" 
replace SchLevel = 3 if SchName == "Northeast Secure Treatment Unit" 
replace SchVirtual = 0 if SchName == "Northeast Secure Treatment Unit" 

replace NCESSchoolID = "421764010038" if SchName == "Northern Lebanon El Sch"
replace SchType = 1 if SchName == "Northern Lebanon El Sch"
replace SchLevel = 1 if SchName == "Northern Lebanon El Sch"
replace SchVirtual = 0 if SchName == "Northern Lebanon El Sch"

replace NCESSchoolID = "421821010037" if SchName == "Oswayo Valley Jshs"
replace SchType = 1 if SchName == "Oswayo Valley Jshs"
replace SchLevel = 0 if SchName == "Oswayo Valley Jshs"
replace SchVirtual = 0 if SchName == "Oswayo Valley Jshs"

replace NCESSchoolID = "421899010043" if SchName == "Guidon S Bluford El Sch"
replace SchType = 1 if SchName == "Guidon S Bluford El Sch"
replace SchLevel = 1 if SchName == "Guidon S Bluford El Sch"
replace SchVirtual = 0 if SchName == "Guidon S Bluford El Sch"

replace NCESSchoolID = "428939910044" if SchName == "Provident Cs - West"
replace SchType = 1 if SchName == "Provident Cs - West"
replace SchLevel = 1 if SchName == "Provident Cs - West"
replace SchVirtual = 0 if SchName == "Provident Cs - West"


replace NCESSchoolID = "422382010039" if SchName == "Tulpehocken Area Ms"
replace SchType = 1 if SchName == "Tulpehocken Area Ms"
replace SchLevel = 2 if SchName == "Aronimink El Sch"
replace SchVirtual = 0 if SchName == "Aronimink El Sch"

replace NCESSchoolID = "422432010042" if SchName == "Aronimink El Sch"
replace SchType = 1 if SchName == "Aronimink El Sch"
replace SchLevel = 1 if SchName == "Aronimink El Sch" 
replace SchVirtual = 0 if SchName == "Aronimink El Sch" 

replace NCESSchoolID = "422487010040" if SchName == "Warrior Run El Sch"
replace SchType = 1 if SchName == "Warrior Run El Sch"
replace SchLevel = 1 if SchName == "Warrior Run El Sch"
replace SchVirtual = 0 if SchName == "Warrior Run El Sch"

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data
save "$Output/PA_AssmtData_2024.dta", replace
export delimited using "$Output/PA_AssmtData_2024.csv", replace
