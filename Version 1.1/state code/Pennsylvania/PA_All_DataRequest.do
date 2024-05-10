clear all

// Define file paths
global original_files "/Users/miramehta/Documents/PA State Testing Data/Original_Data_Files"
global NCES_school "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCES_district "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global output_files "/Users/miramehta/Documents/PA State Testing Data/Output_Data_Files"
global temp_files "/Users/miramehta/Documents/PA State Testing Data/Temporary_Data_Files"

// All years from data request
/*
//School import

import excel "$original_files/2015-2022 PSSA Schools.xlsx", sheet("Sheet1") firstrow clear

save "$temp_files/PA_DataRequest_School_Part1.dta", replace

clear
import excel "$original_files/2015-2022 PSSA Schools.xlsx", sheet("Sheet2") firstrow clear

drop if AUN == .

save "$temp_files/PA_DataRequest_School_Part2.dta", replace



// School append

clear
append using "$temp_files/PA_DataRequest_School_Part1.dta" "$temp_files/PA_DataRequest_School_Part2.dta"

gen DataLevel = "School"

save "$temp_files/PA_DataRequest_School_All.dta", replace

// District import

import excel "$original_files/2015-2022 PSSA District.xlsx", firstrow clear

gen SchoolName = "All Schools"
gen SchoolNumber = ""
gen DataLevel = "District"

save "$temp_files/PA_DataRequest_District.dta", replace

// State import
import excel "$original_files/2015-2022 PSSA State.xlsx", firstrow clear

gen AUN = .
gen DistrictName = "All Districts"
gen SchoolName = "All Schools"
gen SchoolNumber = ""
drop N
rename Subgroup Group
gen DataLevel = "State"

save "$temp_files/PA_DataRequest_State.dta", replace


// Appending All DataLevels
clear
append using "$temp_files/PA_DataRequest_School_All.dta" "$temp_files/PA_DataRequest_District.dta" "$temp_files/PA_DataRequest_State.dta"

duplicates drop
save "$temp_files/PA_DataRequest_All.dta", replace
*/

use "$temp_files/PA_DataRequest_All.dta", clear

// Relabelling variables
rename AUN StateAssignedDistID
rename Group StudentSubGroup
rename Grade GradeLevel
rename NumberScored StudentSubGroup_TotalTested
rename PercentAdvanced Lev4_percent
rename PercentProficient Lev3_percent
rename PercentBasic Lev2_percent
rename PercentBelowBasic Lev1_percent
rename NumberAdvanced Lev4_count
rename NumberProficient Lev3_count
rename NumberBasic Lev2_count
rename NumberBelowBasic Lev1_count
rename SchoolNumber StateAssignedSchID
rename DistrictName DistName
rename SchoolName SchName

// Transforming variables
gen SchYear = string(Year-1)+"-"+string(Year-2000)
drop Year
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science" | Subject == "S"
tostring GradeLevel, replace
replace GradeLevel = "G0"+GradeLevel
gen StudentGroup = "Replace"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-ethnic"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or other Pacific Islander"
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

foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent {
	replace `var' = `var'/100
}

gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
gen ProficientOrAbove_count = Lev3_count + Lev4_count

foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_percent ProficientOrAbove_count {
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
gen Flag_CutScoreChange_soc = ""
gen Flag_CutScoreChange_sci = "N"
replace Flag_AssmtNameChange = "Y" if SchYear == "2014-15"
replace Flag_CutScoreChange_ELA = "Y" if SchYear == "2014-15"
replace Flag_CutScoreChange_math = "Y" if SchYear == "2014-15"
replace Flag_CutScoreChange_sci = "Y" if SchYear == "2014-15"


// Generating StudentGroup count
bysort StateAssignedDistID StateAssignedSchID StudentGroup Grade Subject SchYear: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

// Relabelling Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

// Now NCES merging based on year
// 2015
/*
preserve 
keep if SchYear == "2014-15"

// Generate ID to match NCES
gen seasch = substr(StateAssignedSchID,-4,4)
tostring StateAssignedDistID, gen(state_leaid)

save "${output_files}/PA_AssmtData_2015.dta", replace

// Merging with NCES School Data

use "$NCES_school/NCES_2014_School.dta", clear 

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if state_location == "PA"
drop if seasch == ""

merge 1:m state_leaid seasch using "${output_files}/PA_AssmtData_2015.dta", keep(match using)

drop if _merge == 2 & DataLevel == 3
drop _merge

save "${output_files}/PA_AssmtData_2015.dta", replace

// Merging with NCES District Data

use "$NCES_district/NCES_2014_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if state_location == "PA"

merge 1:m state_leaid using "${output_files}/PA_AssmtData_2015.dta", keep(match using) nogenerate

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

//Other Reformatting
replace CountyName = strproper(CountyName)
replace CountyName = "McKean County" if NCESDistrictID == "42083"
replace DistName = stritrim(DistName)

// Fixing State Level Data
replace StateAbbrev = "PA" if DataLevel == 1
replace StateFips = 42 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

drop seasch State_leaid

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/PA_AssmtData_2015.dta", replace
export delimited using "$output_files/PA_AssmtData_2015.csv", replace

restore
*/
// 2016
/*
preserve 
keep if SchYear == "2015-16"

// Generate ID to match NCES
gen seasch = substr(StateAssignedSchID,-4,4)
tostring StateAssignedDistID, gen(state_leaid)

save "${output_files}/PA_AssmtData_2016.dta", replace

// Merging with NCES School Data

use "$NCES_school/NCES_2015_School.dta", clear 

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if state_location == "PA"
drop if seasch == ""

merge 1:m state_leaid seasch using "${output_files}/PA_AssmtData_2016.dta", keep(match using) nogenerate

save "${output_files}/PA_AssmtData_2016.dta", replace

// Merging with NCES District Data

use "$NCES_district/NCES_2015_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if state_location == "PA"

merge 1:m state_leaid using "${output_files}/PA_AssmtData_2016.dta", keep(match using) nogenerate

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

//Other Reformatting
replace DistName = stritrim(DistName)

// Fixing State Level Data
replace StateAbbrev = "PA" if DataLevel == 1
replace StateFips = 42 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

drop seasch State_leaid

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/PA_AssmtData_2016.dta", replace
export delimited using "$output_files/PA_AssmtData_2016.csv", replace

restore
*/
// 2017
/*
preserve 
keep if SchYear == "2016-17"

// Generate ID to match NCES
tostring StateAssignedDistID, gen(state_leaid)
gen seasch = state_leaid+"-"+substr(StateAssignedSchID,-4,4)
replace state_leaid = "PA-"+state_leaid

save "${output_files}/PA_AssmtData_2017.dta", replace

// Merging with NCES School Data

use "$NCES_school/NCES_2016_School.dta", clear 

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if state_location == "PA"
drop if seasch == ""

merge 1:m state_leaid seasch using "${output_files}/PA_AssmtData_2017.dta", keep(match using) nogenerate

save "${output_files}/PA_AssmtData_2017.dta", replace

// Merging with NCES District Data

use "$NCES_district/NCES_2016_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if state_location == "PA"

merge 1:m state_leaid using "${output_files}/PA_AssmtData_2017.dta", keep(match using) nogenerate

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

//Other Reformatting
replace DistName = stritrim(DistName)

// Fixing State Level Data
replace StateAbbrev = "PA" if DataLevel == 1
replace StateFips = 42 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

drop seasch State_leaid

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/PA_AssmtData_2017.dta", replace
export delimited using "$output_files/PA_AssmtData_2017.csv", replace

restore
*/

// 2018
/*
preserve 
keep if SchYear == "2017-18"

// Generate ID to match NCES
tostring StateAssignedDistID, gen(state_leaid)
gen seasch = state_leaid+"-"+substr(StateAssignedSchID,-4,4)
replace state_leaid = "PA-"+state_leaid

save "${output_files}/PA_AssmtData_2018.dta", replace

// Merging with NCES School Data

use "$NCES_school/NCES_2017_School.dta", clear 

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if state_location == "PA"
drop if seasch == ""

merge 1:m state_leaid seasch using "${output_files}/PA_AssmtData_2018.dta", keep(match using) nogenerate

save "${output_files}/PA_AssmtData_2018.dta", replace

// Merging with NCES District Data

use "$NCES_district/NCES_2017_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if state_location == "PA"

merge 1:m state_leaid using "${output_files}/PA_AssmtData_2018.dta", keep(match using) nogenerate

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

// Fixing State Level Data
replace StateAbbrev = "PA" if DataLevel == 1
replace StateFips = 42 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

drop seasch State_leaid

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/PA_AssmtData_2018.dta", replace
export delimited using "$output_files/PA_AssmtData_2018.csv", replace

restore
*/

// 2019
/*
preserve 
keep if SchYear == "2018-19"

// Generate ID to match NCES
tostring StateAssignedDistID, gen(state_leaid)
gen seasch = state_leaid+"-"+substr(StateAssignedSchID,-4,4)
replace state_leaid = "PA-"+state_leaid

save "${output_files}/PA_AssmtData_2019.dta", replace

// Merging with NCES School Data

use "$NCES_school/NCES_2018_School.dta", clear 

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if state_location == "PA"
drop if seasch == ""

merge 1:m state_leaid seasch using "${output_files}/PA_AssmtData_2019.dta", keep(match using) nogenerate

save "${output_files}/PA_AssmtData_2019.dta", replace

// Merging with NCES District Data

use "$NCES_district/NCES_2018_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if state_location == "PA"

merge 1:m state_leaid using "${output_files}/PA_AssmtData_2019.dta", keep(match using) nogenerate

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

// Fixing State Level Data
replace StateAbbrev = "PA" if DataLevel == 1
replace StateFips = 42 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

drop seasch State_leaid

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/PA_AssmtData_2019.dta", replace
export delimited using "$output_files/PA_AssmtData_2019.csv", replace

restore
*/

// 2021
/*
preserve 
keep if SchYear == "2020-21"

// Generate ID to match NCES
tostring StateAssignedDistID, gen(state_leaid)
gen seasch = state_leaid+"-"+substr(StateAssignedSchID,-4,4)
replace state_leaid = "PA-"+state_leaid

save "${output_files}/PA_AssmtData_2021.dta", replace

// Merging with NCES School Data

use "$NCES_school/NCES_2020_School.dta", clear 

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if state_location == "PA"
drop if seasch == ""

merge 1:m state_leaid seasch using "${output_files}/PA_AssmtData_2021.dta", keep(match using) nogenerate

save "${output_files}/PA_AssmtData_2021.dta", replace

// Merging with NCES District Data

use "$NCES_district/NCES_2020_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if state_location == "PA"

merge 1:m state_leaid using "${output_files}/PA_AssmtData_2021.dta", keep(match using) nogenerate

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

// Fixing State Level Data
replace StateAbbrev = "PA" if DataLevel == 1
replace StateFips = 42 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

drop seasch State_leaid

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/PA_AssmtData_2021.dta", replace
export delimited using "$output_files/PA_AssmtData_2021.csv", replace

restore
*/

// 2022
/*
preserve 
keep if SchYear == "2021-22"

// Generate ID to match NCES
tostring StateAssignedDistID, gen(state_leaid)
gen seasch = state_leaid+"-"+substr(StateAssignedSchID,-4,4)
replace state_leaid = "PA-"+state_leaid

save "${output_files}/PA_AssmtData_2022.dta", replace

// Merging with NCES School Data

use "$NCES_school/NCES_2021_School.dta", clear 

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if state_location == "PA"
drop if seasch == ""

merge 1:m state_leaid seasch using "${output_files}/PA_AssmtData_2022.dta", keep(match using) nogenerate

save "${output_files}/PA_AssmtData_2022.dta", replace

// Merging with NCES District Data

use "$NCES_district/NCES_2021_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if state_location == "PA"

merge 1:m state_leaid using "${output_files}/PA_AssmtData_2022.dta", keep(match using) nogenerate

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

// Fixing State Level Data
replace StateAbbrev = "PA" if DataLevel == 1
replace StateFips = 42 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

drop seasch State_leaid

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/PA_AssmtData_2022.dta", replace
export delimited using "$output_files/PA_AssmtData_2022.csv", replace

restore
*/
