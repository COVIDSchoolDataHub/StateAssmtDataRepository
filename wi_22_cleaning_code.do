*Cleaning WI 2022

import delimited using /*original 2022 data*/, clear

*create 'seasch' for merging NCES school variables
gen zdistrict_code = string(district_code, "%04.0f")
gen zschool_code = string(school_code, "%04.0f")
egen seasch = concat(zdistrict_code zschool_code), p("-")

*create 'state_leaid' for merging NCES district variables
gen state_abbrev = "WI"
egen state_leaid = concat(state_abbrev district_code), p("-")

*drop intermediate variables and save
drop zdistrict_code zschool_code state_abbrev
save WIToMerge, replace

*prep NCES data
import delimited using /*2021 NCES school data*/, clear
drop if state_fips != 55
save NCESWISchool, replace
import delimited using /*2021 NCES district data*/, clear
drop if state_fips != 55
save NCESWIDist, replace

*merge NCES variables
use WIToMerge, clear
merge m:m seasch using NCESWISchool
gen _mergeSchool = _merge
drop _merge
merge m:1 state_leaid using NCESWIDist
gen _mergeDist = _merge
drop _merge

*drop DLM, grade 10, and NCES observs that don't merge into state observs
drop if test_group == "DLM"
drop if grade_level == 10
drop if agency_type == "Charter Management Organization (CMO)"
drop if _mergeSchool == 2
drop if _mergeDist == 2

*rename variables and drop duplicates
rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename district_agency_type DistrictType
rename charter Charter
drop charter_ind
rename county_name CountyName
drop county
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel
rename district_name DistName
rename district_code StateAssignedDistID
rename school_name SchName
rename school_code StateAssignedSchID
rename test_subject Subject
rename grade_level GradeLevel
rename group_by StudentGroup
rename group_count StudentGroup_TotalTested
rename group_by_value StudentSubGroup
rename forward_average_scale_score AvgScaleScore

*create CSDH variables and drop duplicates
gen SchYear = school_year
drop school_year
gen AssmtName = "Forward"
drop test_group
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "level"
replace DataLevel = "State"
replace DataLevel = "District" if agency_type == "School District"
replace DataLevel = "School" if agency_type == "Public school" | agency_type == "Public Schools-Multidistrict Charters" | agency_type == "Non District Charter Schools"
gen ProficiencyCriteria = "Proficient or Advanced"

/* 

Not sure how to get v's 36-45 and 48-50; basically, each subgroup is broken up
into five observations, each of which is for a different score (i.e. 
'test_result_code'); I believe it needs to be reshaped from long to wide.

*/

*save state observs that don't merge into NCES observs
save WIPreDrop, replace
keep if _mergeSchool != 3 & DataLevel == "School"
keep agency_type SchYear DistName SchName StateAssignedDistID StateAssignedSchID DataLevel
save WIUnmergedSchools, replace

*clean final data file
use WIPreDrop, clear
replace seasch = "" if DataLevel == "District" | DataLevel == "State"

*drop extra variables and state observs that don't merge into NCEs observs
drop if _mergeSchool != 3 & DataLevel == "School"
drop agency_type
drop cesa
drop year
drop lea_name
drop _mergeSchool
drop _mergeDistrict

