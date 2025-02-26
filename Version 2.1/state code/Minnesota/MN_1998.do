*******************************************************
* MINNESOTA

* File name: MN_1998
* Last update: 2/21/2025

*******************************************************
* Notes

	* This do file cleans MN's 1998 data and merges with NCES 1997. 
	* Only one temp output created.
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear

************************************************************************************
* Importing data and renaming variables
************************************************************************************
// 1997-1998
import excel "$Original/MN_OriginalData_1998_all.xlsx", cellrange(A6:X6235) clear

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

replace SchYear = "1997-98" if SchYear == "97-98"
replace Subject = "math" if Subject == "M"
replace Subject = "ela" if Subject == "R"
replace Subject = "wri" if Subject == "W"
replace GradeLevel = "G03" if GradeLevel == "03"
replace GradeLevel = "G05" if GradeLevel == "05"


foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev3_count Lev4_percent Lev4_count Lev5_percent Lev5_count {
	destring `var', generate(num`var') force
}

foreach var of varlist numLev1_percent numLev2_percent numLev3_percent numLev4_percent numLev5_percent {
	replace `var' = `var'/100
}

gen ProficientOrAbove_count = numLev3_count + numLev4_count + numLev5_count
gen ProficientOrAbove_percent = numLev3_percent + numLev4_percent + numLev5_percent

drop numLev3_count
drop numLev4_count
drop numLev5_count

foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent {
	tostring num`var', replace force format("%9.3g")
	replace `var' = num`var' if `var' != "--"
	drop num`var'
}

foreach var of varlist ProficientOrAbove_count ProficientOrAbove_percent {
	tostring `var', replace force
	replace `var' = "--" if `var' == "."
}

replace AvgScaleScore = "--" if Subject == "wri"

// Generating missing variables
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen AssmtName = "Minnesota Comprehensive Assessment"
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
*gen Flag_CutScoreChange_read = ""
*gen Flag_CutScoreChange_oth = "Y"
gen Flag_CutScoreChange_sci = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"
replace Flag_CutScoreChange_sci = "Not applicable"
gen AssmtType = "Regular"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen ProficiencyCriteria = "Levels 3-5"
gen ParticipationRate = "--"

// Data Levels
gen DataLevel = "School"
replace DataLevel = "District" if SchName == "All Schools"
replace DataLevel = "State" if DistName == "Statewide Totals"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

// Combined State School and District IDs
// (School ID in format to match with NCES is combination of different IDs)
gen seasch = DistrictTypeCode + StateAssignedDistID + StateAssignedSchID
gen state_leaid = DistrictTypeCode + StateAssignedDistID 

// Drop Unnamed School
drop if DistName == "DULUTH" & SchName == ""

// Saving transformed data
save "${Original_Cleaned}/MN_AssmtData_1998.dta", replace

************************************************************************************
*Merging with NCES data
************************************************************************************
// Merging with NCES School Data
use "$NCES_School/NCES_1997_School.dta", clear 

keep state_location state_name state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale
keep if state_name == "Minnesota"
drop if seasch == "701000010"

merge 1:m seasch using "${Original_Cleaned}/MN_AssmtData_1998.dta", keep(match using) nogenerate

save "${Temp}/MN_AssmtData_1998.dta", replace

// Merging with NCES District Data
use "$NCES_District/NCES_1997_District.dta", clear 

keep state_location state_name state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale
keep if state_name == "Minnesota"
drop if state_leaid == "701000"

merge 1:m state_leaid using "${Temp}/MN_AssmtData_1998.dta", keep(match using) nogenerate

// Reformatting IDs
replace StateAssignedDistID = StateAssignedDistID+"-"+DistrictTypeCode
replace StateAssignedSchID = StateAssignedDistID+"-"+StateAssignedSchID

// Renaming NCES variables
drop DistrictTypeCode

rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename state_location StateAbbrev
generate State = "Minnesota"
rename county_code CountyCode
*rename school_type SchType
rename state_fips StateFips
rename county_name CountyName

// Dropping cross-border district
drop if StateAbbrev == "IA"

// Fixing State Level Missing DataLevel
replace StateAbbrev = "MN"
replace StateFips = 27 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
replace seasch = "" if DataLevel != 3
replace State_leaid = "" if DataLevel == 1

replace DistName = strproper(DistName)

// Generating Student Group Counts - ADDED 10/3/24
{
replace StateAssignedDistID = "000000" if DataLevel== 1 // State
replace StateAssignedSchID = "000000" if DataLevel== 1 // State
replace StateAssignedSchID = "000000" if DataLevel== 2 // District
egen uniquegrp = group(SchYear DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup 
by uniquegrp: gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by uniquegrp: replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
drop StudentGroup_TotalTested
rename AllStudents StudentGroup_TotalTested
}

replace StateFips = 27 if StateFips ==. 

// Reordering variables and sorting data
local vars State StateAbbrev StateFips SchYear DataLevel DistName DistType 	///
    SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID 		///
    StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual 			///
    CountyName CountyCode AssmtName AssmtType Subject GradeLevel 			///
    StudentGroup StudentGroup_TotalTested StudentSubGroup 					///
    StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count 			///
    Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent 			///
    Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria 				///
    ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 	///
    Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math 	///
    Flag_CutScoreChange_sci Flag_CutScoreChange_soc
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Temp Output*
save "${Temp}/MN_AssmtData_1998.dta", replace
* END of MN_1998.do
****************************************************

