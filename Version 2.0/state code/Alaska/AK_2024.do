cd "/Users/name/Desktop/Alaska"
cap log close
log using alaska_cleaning2024.log, replace

/*
//New Importing Code
import excel AK_OriginalData_2024.xlsx, clear 
save "$Original/AK_OriginalData_2024", replace
export delimited AK_OriginalData_2024.csv, replace 
clear all
*/

import delimited AK_OriginalData_2024.csv, case(preserve) stringcols(_all) varnames(2) rowrange(3:)
// rename vars
rename datalevel DataLevel
rename District_Name  DistName
rename School_Name SchName
rename Test AssmtName
rename Grade GradeLevel
rename Group StudentGroup
rename SubGroup StudentSubGroup
rename AdvancedCount Lev4_count
rename Advanced Lev4_percent
rename ProficientCount Lev3_count
rename Proficient Lev3_percent
rename ApproachingCount Lev2_count
rename Approaching Lev2_percent
rename SupportCount Lev1_count
rename Support Lev1_percent
rename Tested ParticipationRate

//Indicator Variables
gen State = "Alaska"
gen StateAbbrev = "AK"
gen StateFips = 2
gen SchYear = "2023-24"
gen AssmtType = "Regular"
gen Lev5_count = ""
gen Lev5_percent = ""
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3-4"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

//Subject
replace Subject = "sci" if Subject == "Science"
replace Subject = lower(Subject)
replace GradeLevel = "G38" if strpos(GradeLevel, "Combined") !=0
replace GradeLevel = "G0" + GradeLevel if GradeLevel != "G38"

//StudentGroup
replace StudentGroup = "RaceEth" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English Proficiency"

//StudentSubGroup
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Alaska Native/American Indian"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "White" if StudentSubGroup == "Caucasian"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not English Learners"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students With Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students Without Disabilities"

//Cleaning Percents
foreach var of varlist Lev*_percent {
	replace `var' = "0-" + string(real(substr(`var',1,2))/100, "%9.4g") if strpos(`var', "% or fewer") !=0
	replace `var' = subinstr(`var', "% or fewer","",.)
	replace `var' = string(real(substr(`var',1,2))/100, "%9.4g") + "-1" if strpos(`var', "% or more") !=0
	replace `var' = subinstr(`var', "% or more","",.)
	replace `var' = string(real(`var')/100, "%9.4g") if regexm(`var', "[*-]") == 0
	replace `var' = "0-.05" if `var' == "0-."
}

//ParticipationRate
replace ParticipationRate = string(real(ParticipationRate)/100)

//ProficientOrAbove Count and Percent

**Ranges
foreach var of varlist Lev*_percent {
	gen low`var' = substr(`var', 1, strpos(`var', "-")-1)
	gen high`var' = substr(`var', strpos(`var', "-") +1, 5)
}
gen lowProficientOrAbove_percent = real(lowLev3_percent) + real(lowLev4_percent) 
gen highProficientOrAbove_percent = real(highLev3_percent) + real(highLev4_percent)
replace highProficientOrAbove_percent = 1 if highProficientOrAbove_percent > 1
tostring highProficientOrAbove_percent lowProficientOrAbove_percent, replace force format("%9.4g")
replace highProficientOrAbove_percent = "*" if Lev3_percent == "*" | Lev4_percent == "*"
gen ProficientOrAbove_percent = highProficientOrAbove_percent if lowProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = lowProficientOrAbove_percent + "-" + highProficientOrAbove_percent if lowProficientOrAbove_percent != "."
foreach var of varlist high* low* {
	drop `var'
}
gen ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if Lev3_count != "*" & Lev4_count != "*"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == ""

//StudentSubGroup_TotalTested
gen StudentSubGroup_TotalTested = (real(Enrollment) * real(ParticipationRate))
replace StudentSubGroup_TotalTested = round(StudentSubGroup_TotalTested)

//NCES Merging
tempfile temp1
save "`temp1'", replace

//District Level
keep if DataLevel == 2
gen state_leaid = "0" + id if strlen(id) <2
replace state_leaid = id if strlen(id) >=2
gen StateAssignedDistID = state_leaid
replace state_leaid = "AK-" + state_leaid
tempfile tempdist
save "`tempdist'", replace
clear
use "NCES_2022_District"
keep if state_fips == 2
keep ncesdistrictid state_leaid district_agency_type DistCharter DistLocale county_code county_name
merge 1:m state_leaid using "`tempdist'", keep(match using) 
save "`tempdist'", replace
clear

//School Level
use "`temp1'"
keep if DataLevel == 3
gen seasch = id
replace seasch = "0" + seasch if strlen(seasch) == 5
gen StateAssignedSchID = seasch
tempfile tempsch
save "`tempsch'", replace
clear
use "NCES_2022_School"
keep if state_fips == 2
keep ncesdistrictid state_leaid district_agency_type DistCharter DistLocale county_code county_name ncesschoolid seasch SchVirtual SchLevel school_type
foreach var of varlist SchVirtual district_agency_type SchLevel school_type {
	decode `var', gen(temp)
	drop `var'
	rename temp `var'
}
replace seasch = substr(seasch,4,6)
merge 1:m seasch using "`tempsch'", keep(match using) nogen
save "`tempsch'", replace
clear

//Combining
use "`temp1'"
keep if DataLevel == 1
append using "`tempdist'" "`tempsch'"
replace StateAssignedDistID = subinstr(state_leaid, "AK-", "",.) if DataLevel == 3

//Fixing NCES Variables
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename county_code CountyCode
rename school_type SchType
rename county_name CountyName

gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

foreach percent of varlist *_percent {
local count = subinstr("`percent'", "percent", "count",.)
replace `count' = string(round(StudentSubGroup_TotalTested * real(substr(`percent',1,strpos(`percent',"-")-1)))) + "-" + string(round(StudentSubGroup_TotalTested * real(substr(`percent',strpos(`percent',"-")+1,3)))) if regexm(`percent', "[0-9]") !=0 & `count' == "*"
}

replace ParticipationRate = "--" if strpos(ParticipationRate, "-") !=0 | ParticipationRate == "." | StudentSubGroup_TotalTested == 0 

tostring StudentGroup_TotalTested StudentSubGroup_TotalTested, replace 

drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"
replace StudentGroup_TotalTested = "0" if StudentGroup_TotalTested == "."
replace StudentSubGroup_TotalTested = "0" if StudentSubGroup_TotalTested == "."
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "N/A"
replace Lev5_count = "" if Lev5_count != "" 
replace Lev5_percent = "" if Lev5_percent != "" 

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject Grade StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup 

save "$Output/AK_AssmtData_2024", replace
export delimited "$Output/AK_AssmtData_2024.csv", replace

