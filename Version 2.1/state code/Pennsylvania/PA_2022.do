clear all 
set more off

global Abbrev "PA"
global Original "/Users/name/Desktop/Pennsylvania/Original"
global NCES "/Users/name/Desktop/Pennsylvania/NCES"
global Output "/Users/name/Desktop/Pennsylvania/Output"
global Temp "/Users/name/Desktop/Pennsylvania/Temp"

capture log close
log using 2022_PA, replace

// Import Original Data Files
/*

// All years from data request

//School import

import excel "$Original/2015-2022 PSSA Schools.xlsx", sheet("Sheet1") firstrow clear
drop if Year != 2022
gen DataLevel = "School"

save "$Temp/PA_DataRequest_School_Part1.dta", replace

clear
import excel "$Original/2015-2022 PSSA Schools.xlsx", sheet("Sheet2") firstrow clear

drop if AUN == .
drop if Year != 2022
gen DataLevel = "School"

save "$Temp/PA_DataRequest_School_Part2.dta", replace

import excel "$Original/PA_2022_OriginalData_School.xlsx", cellrange(A5) firstrow clear
//The original data request did not contain certain Student Subgroup information that the public data did, so we merged it in with PA_2022_OriginalData_School
drop if AUN == .

gen DataLevel = "School"

replace Grade = "38" if Grade == "School Total"
destring Grade, replace 
destring Year, replace
save "$Temp/PA_DataRequest_School_Part3.dta", replace

// School append

clear
append using "$Temp/PA_DataRequest_School_Part1.dta" "$Temp/PA_DataRequest_School_Part2.dta" "$Temp/PA_DataRequest_School_Part3.dta"

save "$Temp/PA_DataRequest_School_All.dta", replace

// District import

import excel "$Original/2015-2022 PSSA District.xlsx", firstrow clear
drop if Year != 2022

gen SchoolName = "All Schools"
gen SchoolNumber = ""
gen DataLevel = "District"

save "$Temp/PA_DataRequest_District.dta", replace

// State import
import excel "$Original/2015-2022 PSSA State.xlsx", firstrow clear
drop if Year != 2022

gen AUN = .
gen DistrictName = "All Districts"
gen SchoolName = "All Schools"
gen SchoolNumber = ""
drop N
rename Subgroup Group
gen DataLevel = "State"

save "$Temp/PA_DataRequest_State.dta", replace


// Appending All DataLevels
clear
append using "$Temp/PA_DataRequest_School_All.dta" "$Temp/PA_DataRequest_District.dta" "$Temp/PA_DataRequest_State.dta"

duplicates drop
save "$Temp/PA_DataRequest_2022.dta", replace
*/

use "$Temp/PA_DataRequest_2022.dta", clear

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
rename NumberBelowBasic Lev1_count 
rename NumberBasic Lev2_count 
rename NumberProficient Lev3_count
rename NumberAdvanced Lev4_count 
drop County 

// Transforming variables
gen SchYear = "2021-22" 
drop Year
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"
tostring GradeLevel, replace
replace GradeLevel = "G0"+GradeLevel
replace GradeLevel = "G38" if GradeLevel == "G038"
gen StudentGroup = ""
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-ethnic"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or other Pacific Islander"
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ELL"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-ELL" | StudentSubGroup == "Not-ELL"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not-Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"

// Relabelling Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

forvalues n = 1/4{
	replace Lev`n'_percent = Lev`n'_percent/100
}

gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent 
gen ProficientOrAbove_count = Lev3_count + Lev4_count if Lev3_percent != . & Lev4_percent != . & StudentSubGroup_TotalTested != .

foreach var of varlist Lev1_percent Lev1_count Lev2_percent Lev2_count Lev3_percent Lev3_count Lev4_percent Lev4_count ProficientOrAbove_percent ProficientOrAbove_count {
	gen s`var' = string(`var',"%9.3g")
	replace s`var' = "*" if s`var' == "." & StudentSubGroup_TotalTested < 11
	drop `var'
	rename s`var' `var'
}

//Removing extra spaces
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var') // collapses all consecutive, internal blanks to one blank.
	replace `var' = strtrim(`var') // removes leading and trailing blanks
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

// Generate ID to match NCES
tostring StateAssignedDistID, gen(state_leaid)
gen seasch = state_leaid+"-"+substr(StateAssignedSchID,-4,4)
replace state_leaid = "PA-"+state_leaid

save "$Output/PA_AssmtData_2022.dta", replace

// Merging with NCES School Data

use "$NCES/NCES School Files, Fall 1997-Fall 2022/NCES_2021_School.dta", clear 

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if state_location == "PA"

merge 1:m state_leaid seasch using "$Output/PA_AssmtData_2022.dta", keep(match using) nogenerate

save "$Output/PA_AssmtData_2022.dta", replace

// Merging with NCES District Data

use "$NCES/NCES District Files, Fall 1997-Fall 2022/NCES_2021_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if state_location == "PA"

merge 1:m state_leaid using "$Output/PA_AssmtData_2022.dta", keep(match using) nogenerate

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

gen Prof = ProficientOrAbove_percent
destring Prof, replace force
gen Profcount = (StudentSubGroup_TotalTested) * Prof if Lev3_count == "." & Lev4_count == "."
replace Profcount = round(Profcount)
tostring Profcount, replace
replace ProficientOrAbove_count = Profcount if Lev3_count == "." & Lev4_count == "."

// Renaming NCES variables
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename state_location StateAbbrev
generate State = "Pennsylvania"
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

duplicates tag, gen (dup)
duplicates drop 
drop dup
duplicates tag DataLevel AssmtName AssmtType NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup StudentSubGroup, gen(dup2)
drop if dup2 > 0 & Lev1_count == "." & Lev2_count == "." & Lev3_count == "." & Lev4_count == "."

replace Lev1_count = "--" if Lev1_count == "." 
replace Lev2_count = "--" if Lev2_count == "."
replace Lev3_count = "--" if Lev3_count == "."
replace Lev4_count = "--" if Lev4_count == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ParticipationRate = "" if ParticipationRate == "."

destring StateAssignedSchID, replace
gen StateAssignedSchID1 = substr(string(StateAssignedSchID, "%20.0f"), -4, 4)
replace StateAssignedSchID1 = substr(string(StateAssignedSchID, "%20.0f"), -3, 4) if StateAssignedSchID1 == "" & DataLevel == 3
replace StateAssignedSchID1 = substr(string(StateAssignedSchID, "%20.0f"), -2, 4) if StateAssignedSchID1 == "" & DataLevel == 3
drop StateAssignedSchID
rename StateAssignedSchID1 StateAssignedSchID

	//Removing extra spaces
	foreach var of varlist DistName SchName {
		replace `var' = stritrim(`var') // collapses all consecutive, internal blanks to one blank.
		replace `var' = strtrim(`var') // removes leading and trailing blanks
	}
	
	
	foreach var of varlist StateAssignedDistID {
		replace `var'  = . if  `var' == 1
		replace `var'  = . if  `var' == 1
		replace `var'  = . if  `var' == 0
	}
	
				foreach var of varlist StateAssignedSchID {
    replace `var' = "" if `var' == "1"
    replace `var' = "" if `var' == "0"
    replace `var' = "" if `var' == "."
}	

// Reordering variables and sorting data
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "$Output/PA_AssmtData_2022.dta", replace
export delimited using "$Output/PA_AssmtData_2022.csv", replace
