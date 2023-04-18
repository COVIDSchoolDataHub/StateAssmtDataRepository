clear

// Define file paths

global original_files "/Users/meghancornacchia/Desktop/DataRepository/Original_Data_Files"
global NCES_files "/Users/meghancornacchia/Desktop/DataRepository/NCES_Data_Files"
global output_files "/Users/meghancornacchia/Desktop/DataRepository/Output_Data_Files"

// 1999-2000

import excel "$original_files/MN_OriginalData_2000_all.xlsx", cellrange(A6:X6393) clear

save "${output_files}/MN_AssmtData_2000.dta", replace

// Reformatting missing values

foreach var of varlist K L M N O P Q R S T U V W X {
	replace `var'= "--" if `var' == "    NA"
}

// Relabeling variables

rename D DistrictTypeCode
rename A SchYear
rename F DistName
rename C StateAssignedDistID
rename G SchName
rename E StateAssignedSchID
rename I Subject
rename H GradeLevel
rename K StudentGroup_TotalTested
rename N Lev1_count
rename S Lev1_percent
rename O Lev2_count
rename T Lev2_percent
rename P Lev3_count
rename U Lev3_percent
rename Q Lev4_count
rename V Lev4_percent
rename R Lev5_count
rename W Lev5_percent
rename X AvgScaleScore

// Dropping extra variables

drop B
drop J
drop L
drop M

// Transforming Variable Values
replace SchYear = "1999-00" if SchYear == "99-00"
replace Subject = "math" if Subject == "M"
replace Subject = "read" if Subject == "R"
replace Subject = "wri" if Subject == "W"
replace GradeLevel = "G03" if GradeLevel == "03"
replace GradeLevel = "G05" if GradeLevel == "05"



// Generating missing variables
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen AssmtName = "Minnesota Comprehensive Assessment"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
gen StudentGroup = "All students"
gen StudentSubGroup = "All students"
gen ProficiencyCriteria = ""
gen ProficientOrAbove_count = ""
gen ProficientOrAbove_percent = ""
gen ParticipationRate = ""
replace DataLevel = "District" if SchName == "All Schools"
replace DataLevel = "State" if DistName == "Statewide Totals"

// Combined State School IDs
// (School ID in format to match with NCES is combination of different IDs)
gen seasch = DistrictTypeCode + StateAssignedDistID + StateAssignedSchID
gen state_leaid = DistrictTypeCode + StateAssignedDistID 

// Drop unnamed school
drop if DistName == "MINNEAPOLIS" & SchName == ""

// Saving transformed data
save "${output_files}/MN_AssmtData_2000.dta", replace


// Merging with NCES School Data

use "$NCES_files/NCES_1999_School.dta", clear 

keep if substr(ncesschoolid, 1, 2) == "27"

drop if ncesschoolid=="270012902783"

merge 1:m seasch using "${output_files}/MN_AssmtData_2000.dta", keep(match using) nogenerate

save "${output_files}/MN_AssmtData_2000.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES_1999_District.dta", clear 

keep if substr(ncesdistrictid, 1, 2) == "27"

merge 1:m state_leaid using "${output_files}/MN_AssmtData_2000.dta", keep(match using) nogenerate


// Removing extra variables and renaming NCES variables
// NCES data missing StateAbbrev
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

sort DataLevel StateAssignedDistID StateAssignedSchID GradeLevel Subject

// Saving and exporting transformed data

save "${output_files}/MN_AssmtData_2000.dta", replace
export delimited using "$output_files/MN_AssmtData_2000.csv", replace

