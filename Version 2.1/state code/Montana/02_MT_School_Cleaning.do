*******************************************************
* MONTANA

* File name: 02_MT_School_Cleaning
* Last update: 03/06/2025

*******************************************************
* Notes

	* This do file cleans MT school level data and appends it to the state level data.
	* You must have the filelist package installed for this file to run properly.
	
*******************************************************

// IMPORT & APPEND DATA -- CAN HIDE AFTER FIRST RUN

import excel "${Original}/Montana Data Received From Data Request - 1-6-24/Halloran_Proficiency_v2_01-06-2024_Final.xlsx", clear sheet("Eligible 2016") firstrow case(preserve)
drop if FiscalYear == .
drop EligibleStudentsSci //all values are null
tostring EligibleStudentsMath, replace
save "${Original}/MT_SSGTT.dta", replace

import excel "${Original}/Montana Data Received From Data Request - 1-6-24/Halloran_Proficiency_v2_01-06-2024_Final.xlsx", clear sheet("Eligible 2017-2019") firstrow case(preserve)
append using "${Original}/MT_SSGTT.dta"
save "${Original}/MT_SSGTT.dta", replace

import excel "${Original}/Montana Data Received From Data Request - 1-6-24/Halloran_Proficiency_v2_01-06-2024_Final.xlsx", clear sheet("Eligible 2022-2023") firstrow case(preserve)
tostring EligibleStudentsELA, replace
append using "${Original}/MT_SSGTT.dta"
save "${Original}/MT_School_SSGTT.dta", replace

import excel "${Original}/Montana Data Received From Data Request - 1-6-24/Halloran_Proficiency_v2_01-06-2024_Final.xlsx", clear sheet("School Science 2016") firstrow case(preserve)
rename LegalEntity DistrictNumber
drop if FiscalYear == .
foreach var of varlist *Science {
	tostring `var', replace
}
save "${Original}/MT_School.dta", replace

import excel "${Original}/Montana Data Received From Data Request - 1-6-24/Halloran_Proficiency_v2_01-06-2024_Final.xlsx", clear sheet("School 2016 -2019") firstrow case(preserve)
rename Le DistrictNumber
rename SC SchoolNumber
rename LeName DistrictName
rename StateFy FiscalYear
foreach var of varlist *ELA *Math {
	tostring `var', replace
}
merge 1:1 FiscalYear DistrictNumber SchoolNumber using "${Original}/MT_School.dta", update replace //replaces NULL 2016 science data in this sheet with non-null 2016 sci data from "School Science 2016"
drop if _merge == 2
drop _merge
rename *SBACELA *ELA
rename *SBACMath *Math
*rename *CRTScience *Sci //unhide to incorporate sci data pre-2022
save "${Original}/MT_School.dta", replace

import excel "${Original}/Montana Data Received From Data Request - 1-6-24/Halloran_Proficiency_v2_01-06-2024_Final.xlsx", clear sheet("School 2022 -2023") firstrow case(preserve)
rename StateFy FiscalYear
rename Le DistrictNumber
rename SC SchoolNumber
rename LeName DistrictName
foreach var of varlist *ELA {
	tostring `var', replace
}
rename *SBACELA *ELA
rename *SBACMath *Math
rename *MSAScience *Sci
append using "${Original}/MT_School.dta"
save "${Original}/MT_School.dta", replace

// CLEANING FILE -- DO NOT HIDE
use "${Original}/MT_School.dta", clear
merge 1:1 FiscalYear DistrictNumber SchoolNumber using "${Original}/MT_School_SSGTT.dta"
drop if _merge == 2
drop _merge

//Reshaping
drop *CRTScience
reshape long EligibleStudents Novice NearingProficient Proficient Advanced, i(FiscalYear DistrictNumber SchoolNumber) j(Subject) string

replace Subject = strlower(Subject)
drop if Subject == "sci" & FiscalYear < 2022 //all missing; haven't pulled in this info (older assessment) yet

//Renaming Variables
rename DistrictName DistName
rename SchoolName SchName
rename DistrictNumber StateAssignedDistID
rename SchoolNumber StateAssignedSchID
rename FiscalYear SchYear
rename Advanced Lev4_count
rename Proficient Lev3_count
rename NearingProficient Lev2_count
rename Novice Lev1_count

drop co countyname

//SchYear
tostring SchYear, replace
replace SchYear = string(real(SchYear)-1) + "-" + substr(SchYear, 3, 2)

//GradeLevel
gen GradeLevel = "G38"

//StudentSubGroup_TotalTested & StudentGroup_TotalTested
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

gen StudentSubGroup_TotalTested = string(real(Lev1_count) + real(Lev2_count) + real(Lev3_count) + real(Lev4_count)) if Lev1_count != "NULL" & Lev2_count != "NULL" & Lev3_count != "NULL" & Lev4_count != "NULL"

replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

//Cleaning Percents & Counts
foreach var of varlist Lev* {
	replace `var' = "--" if `var' == "NULL"
}

gen ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if Lev3_count != "--" & Lev4_count != "--"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == ""

local levels Lev1 Lev2 Lev3 Lev4 ProficientOrAbove
foreach lev of local levels {
	gen `lev'_percent = string(real(`lev'_count)/real(StudentSubGroup_TotalTested), "%9.4g")
	replace `lev'_percent = "0" if `lev'_percent == "0.0000"
	replace `lev'_percent = "1" if `lev'_percent == "1.0000"
	replace `lev'_percent = "--" if `lev'_percent == "."
	replace `lev'_percent = "0" if `lev'_count == "0"
}

//ParticipationRate
gen ParticipationRate = string(real(StudentSubGroup_TotalTested)/real(EligibleStudents), "%9.4g")
replace ParticipationRate = "--" if ParticipationRate == "."
replace ParticipationRate = "1" if ParticipationRate == "1.0000"
replace ParticipationRate = "1" if real(ParticipationRate) > 1 & real(ParticipationRate) != . //normalizing for obs. where sum of level counts > reported number of eligible students
replace ParticipationRate = "--" if StudentSubGroup_TotalTested == "0"

//Prepare for NCES Merging
tostring StateAssignedDistID StateAssignedSchID, replace
foreach var of varlist StateAssignedDistID StateAssignedSchID {
	replace `var' = "000" + `var' if strlen(`var') == 1
	replace `var' = "00" +`var' if strlen(`var') == 2
	replace `var' = "0" + `var' if strlen(`var') == 3	
}

drop if StateAssignedDistID == "9751" & StateAssignedSchID == "9977" //2 obs. for a school in 2017 that does not have NCES information & has only 1 student tested

gen seasch = StateAssignedSchID if SchYear == "2015-16"
gen State_leaid = StateAssignedDistID if SchYear == "2015-16"
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if SchYear != "2015-16"
replace State_leaid = "MT-" + StateAssignedDistID if SchYear != "2015-16"

//Separating by year
forvalues year = 2016/2023{
if `year' == 2020 continue
preserve
local prevyear = `year' - 1
keep if SchYear == "`prevyear'-" + substr("`year'", -2,2)
save "${Original}/MT_School_`year'", replace
restore	
}

forvalues year = 2016/2023 {
	if inlist(`year', 2020, 2021) continue
	local prevyear = `year' - 1
	use "${Original}/MT_School_`year'", clear
	merge m:1 State_leaid seasch using "${NCES_MT}/NCES_`prevyear'_School"
	drop if _merge == 2
	drop _merge
	save "${Original}/MT_School_`year'", replace
	
//Indicator Variables
gen AssmtName = "Smarter Balanced Assessment"
replace AssmtName = "Montana Science Assessment" if Subject == "sci"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"

drop State_leaid seasch

//DataLevel
gen DataLevel = "School"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel

** Flags
gen Flag_AssmtNameChange = "N"
replace Flag_AssmtNameChange = "Y" if Subject == "sci" & SchYear == "2021-22"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Not applicable"
replace Flag_CutScoreChange_sci = "Y" if SchYear == "2021-22"
replace Flag_CutScoreChange_sci = "N" if inlist(SchYear, "2022-23", "2023-24")
gen Flag_CutScoreChange_soc = "Not applicable"

//Missing Variables
gen AvgScaleScore = "--"
gen Lev5_count = ""
gen Lev5_percent = ""

//Names
replace SchName = strtrim(SchName)
replace SchName = stritrim(SchName)

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/MT_AssmtData_`year'_School", replace
clear	
}



