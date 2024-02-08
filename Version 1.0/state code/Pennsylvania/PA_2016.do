clear all

// Define file paths
global original_files "/Users/meghancornacchia/Desktop/DataRepository/Pennsylvania/Original_Data_Files"
global NCES_files "/Users/meghancornacchia/Desktop/DataRepository/NCES_Data_Files"
global output_files "/Users/meghancornacchia/Desktop/DataRepository/Pennsylvania/Output_Data_Files"
global temp_files "/Users/meghancornacchia/Desktop/DataRepository/Pennsylvania/Temporary_Data_Files"

// 2015-2016

// State Level
import excel "$original_files/PA_OriginalData_2016_all_State.xlsx", sheet("website") cellrange(A5:J35) firstrow clear

rename Percent* *
rename Numberscored NumberScored
gen AUN = .
gen SchoolNumber = ""
gen District = ""
gen School = ""
gen DataLevel = "State"

save "$temp_files/PA_2016_State.dta", replace

// School Level
import excel "$original_files/PA_OriginalData_2016_all_School.xlsx", sheet("website") cellrange(A5:N49529) firstrow clear

drop County
gen Proficientandabove = .
gen DataLevel = "School"

save "$temp_files/PA_2016_School.dta", replace

// Merging
clear
append using "$temp_files/PA_2016_State.dta" "$temp_files/PA_2016_School.dta"

// Relabelling variables
rename Year SchYear
rename AUN StateAssignedDistID
rename Group StudentSubGroup
rename Grade GradeLevel
rename NumberScored StudentSubGroup_TotalTested
rename Advanced Lev4_percent
rename Proficient Lev3_percent
rename Basic Lev2_percent
rename BelowBasic Lev1_percent
rename SchoolNumber StateAssignedSchID
rename District DistName
rename School SchName
rename Proficientandabove ProficientOrAbove_percent

// Dropping extra subgroups
drop if StudentSubGroup == "Historically Underperforming"

// Transforming Variable Values
replace SchYear = "2015-16" if SchYear == "2016"
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"
replace GradeLevel = "G0" + GradeLevel
replace GradeLevel = "G38" if GradeLevel == "G0Total"
replace GradeLevel = "G38" if GradeLevel == "G0School Total"

foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	replace `var' = `var'/100
}

replace ProficientOrAbove_percent = Lev3_percent + Lev4_percent if DataLevel == "School"

foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	tostring `var', replace force
	replace `var' = "*" if `var' == "."
}

// Generating missing variables
gen AssmtName = "Pennsylvania System of School Assessment"
gen AssmtType = "Regular"
gen StudentGroup = "All Students" if StudentSubGroup == "All Students"
gen Lev1_count = ""
gen Lev2_count = ""
gen Lev3_count = ""
gen Lev4_count = ""
gen Lev5_count = ""
gen Lev5_percent = ""
gen AvgScaleScore = ""
gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count = ""
gen ParticipationRate = .
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

// Generating StudentGroup count
replace StateAssignedSchID = "StateLevel" if StateAssignedSchID == ""
bysort StateAssignedSchID StudentGroup Grade Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

// Relabelling Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

// Generate ID to match NCES
gen seasch = substr(StateAssignedSchID,-4,4)

// Saving Transformed Data
save "$output_files/PA_AssmtData_2016.dta", replace

// Merging with NCES School Data

use "$NCES_files/NCES_2015_School.dta", clear 

keep state_location state_fips district_agency_type school_type ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code

keep if state_location == "PA"

merge 1:m seasch using "${output_files}/PA_AssmtData_2016.dta", keep(match using) nogenerate

save "${output_files}/PA_AssmtData_2016.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES_2015_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code

keep if state_location == "PA"

merge 1:m ncesdistrictid using "${output_files}/PA_AssmtData_2016.dta", keep(match using) nogenerate

// Renaming NCES variables
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename state_location StateAbbrev
generate State = "Pennsylvania"
rename county_code CountyCode
rename school_type SchType
rename state_fips StateFips
rename county_name CountyName

// Fixing State Level Data
replace StateAbbrev = "PA" if DataLevel == 1
replace StateFips = 42 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2
replace StateAssignedSchID = "" if StateAssignedSchID == "StateLevel"
replace seasch = "" if seasch == "evel"

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/PA_AssmtData_2016.dta", replace
export delimited using "$output_files/PA_AssmtData_2016.csv", replace
