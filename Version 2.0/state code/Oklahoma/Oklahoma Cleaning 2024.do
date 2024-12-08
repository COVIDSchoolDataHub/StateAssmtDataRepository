clear
set more off

global raw "/Users/miramehta/Documents/Oklahoma/Original Data Files"
global output "/Users/miramehta/Documents/Oklahoma/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

//Import Data - Unhide on First Run
/*
import excel "${raw}/OK ELA, Math, Sci Assmt Data (2024) Received via Data Request - 11-10-24/OK_OriginalData_2024.xlsx", sheet("Oklahoma_Halloran") firstrow case(preserve) clear
save "${raw}/OK_OriginalData_2024.dta", replace
*/

use "${raw}/OK_OriginalData_2024.dta", clear

//Rename Variables
rename EducationAgencyType DataLevel
rename NumberofStudentsTested StudentSubGroup_TotalTested
rename NumberofProficientorAboveSt ProficientOrAbove_count
rename PercentProficientorAbove ProficientOrAbove_percent
rename NumberofBelowBasicStudents Lev1_count
rename PercentBelowBasic Lev1_percent
rename NumberofBasicStudents Lev2_count
rename PercentBasic Lev2_percent
rename NumberofProficientStudents Lev3_count
rename PercentProficient Lev3_percent
rename NumberofAdvancedStudents Lev4_count
rename PercentAdvanced Lev4_percent
rename Fullcode StateAssignedDistID
rename ReportSubgroup StudentSubGroup
drop SchoolYear NumberofStudents

//DataLevel & StateAssigned IDs
replace DataLevel = "State" if DataLevel == "All"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedDistID = "55E003" if StateAssignedDistID == "55000"
replace StateAssignedDistID = "55E012" if StateAssignedDistID == "55000000000000"
replace StateAssignedDistID = "72E004" if StateAssignedDistID == "720000"
replace StateAssignedDistID = "72E005" if StateAssignedDistID == "7200000"
replace StateAssignedDistID = "72E006" if StateAssignedDistID == "72000000"
replace StateAssignedDistID = "61E020" if StateAssignedDistID == "6.10000000000e+21"
replace StateAssignedDistID = "55E026" if StateAssignedDistID == "5.50000000000e+27"
replace StateAssignedDistID = "55E028" if StateAssignedDistID == "5.50000000000e+29"
replace StateAssignedDistID = "55E030" if StateAssignedDistID == "5.50000000000e+31"
replace StateAssignedDistID = "72E017" if StateAssignedDistID == "7.20000000000e+18"
replace StateAssignedDistID = "72E018" if StateAssignedDistID == "7.20000000000e+19"
replace StateAssignedDistID = substr(StateAssignedDistID, 1, 2) + "-" + substr(StateAssignedDistID, 3, strlen(StateAssignedDistID)) if DataLevel != 1
gen StateAssignedSchID = StateAssignedDistID if DataLevel == 3
replace StateAssignedDistID = substr(StateAssignedDistID, 1, 7) if DataLevel == 3
replace StateAssignedSchID = subinstr(StateAssignedSchID, StateAssignedDistID, StateAssignedDistID + "-", 1)

//GradeLevel & Subject
drop if inlist(GradeLevel, "9", "All")
replace GradeLevel = "G0" + GradeLevel

replace Subject = strlower(Subject)
replace Subject = "sci" if Subject == "scie"

//StudentSubGroup & StudentGroup
gen x = strpos(StudentSubGroup, "_")
gen StudentGroup = substr(StudentSubGroup, 1, x-1)
replace StudentSubGroup = subinstr(StudentSubGroup, StudentGroup, "", 1)
replace StudentSubGroup = subinstr(StudentSubGroup, "_", "", 1)
drop x

replace StudentGroup = "All Students" if StudentSubGroup == "All"
replace StudentGroup = "Disability Status" if StudentGroup == "IEP"
replace StudentGroup = "Economic Status" if StudentGroup == "EconomicDisadvantage"
replace StudentGroup = "EL Status" if StudentGroup == "ELL"
replace StudentGroup = "Foster Care Status" if StudentGroup == "FosterCare"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military"
replace StudentGroup = "RaceEth" if StudentGroup == "Race"
replace StudentGroup = "RaceEth" if StudentSubGroup == "More than One Race"
drop if StudentGroup == "RegularEducation"

replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Yes" & StudentGroup == "Disability Status"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No" & StudentGroup == "Disability Status"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Yes" & StudentGroup == "Economic Status"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "No" & StudentGroup == "Economic Status"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Yes" & StudentGroup == "EL Status"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "No" & StudentGroup == "EL Status"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Yes" & StudentGroup == "Foster Care Status"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "No" & StudentGroup == "Foster Care Status"
replace StudentSubGroup = "Homeless" if StudentSubGroup == "Yes" & StudentGroup == "Homeless Enrolled Status"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "No" & StudentGroup == "Homeless Enrolled Status"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Yes" & StudentGroup == "Migrant Status"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "No" & StudentGroup == "Migrant Status"
replace StudentSubGroup = "Military" if StudentSubGroup == "Yes" & StudentGroup == "Military Connected Status"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "No" & StudentGroup == "Military Connected Status"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "AmericanIndian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "More than One Race"
drop if StudentSubGroup == "FreeReducedLunch"

replace StudentSubGroup_TotalTested = "0-3" if StudentSubGroup_TotalTested == "≤3"
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "***"
sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
gen max = real(StudentGroup_TotalTested)
replace max = 0 if max == .

bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen RaceEth = total(StudentSubGroup_TotalTested2) if StudentGroup == "RaceEth"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Econ = total(StudentSubGroup_TotalTested2) if StudentGroup == "Economic Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen EL = total(StudentSubGroup_TotalTested2) if StudentGroup == "EL Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Gender = total(StudentSubGroup_TotalTested2) if StudentGroup == "Gender"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Migrant = total(StudentSubGroup_TotalTested2) if StudentGroup == "Migrant Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Homeless = total(StudentSubGroup_TotalTested2) if StudentGroup == "Homeless Enrolled Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Military = total(StudentSubGroup_TotalTested2) if StudentGroup == "Military Connected Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Foster = total(StudentSubGroup_TotalTested2) if StudentGroup == "Foster Care Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Disability = total(StudentSubGroup_TotalTested2) if StudentGroup == "Disability Status"

replace StudentSubGroup_TotalTested = string(max - RaceEth) if StudentGroup == "RaceEth" & max != 0 & StudentSubGroup_TotalTested2 == . & RaceEth != 0
replace StudentSubGroup_TotalTested = string(max - Econ) if StudentGroup == "Economic Status" & max != 0 & StudentSubGroup_TotalTested2 == . & Econ != 0
replace StudentSubGroup_TotalTested = string(max - EL) if StudentGroup == "EL Status" & max != 0 & StudentSubGroup_TotalTested2 == . & EL != 0
replace StudentSubGroup_TotalTested = string(max - Gender) if StudentGroup == "Gender" & max != 0 & StudentSubGroup_TotalTested2 == . & Gender != 0
replace StudentSubGroup_TotalTested = string(max - Migrant) if StudentGroup == "Migrant Status" & max != 0 & StudentSubGroup_TotalTested2 == . & Migrant != 0
replace StudentSubGroup_TotalTested = string(max - Homeless) if StudentGroup == "Homeless Enrolled Status" & max != 0 & StudentSubGroup_TotalTested2 == . & Homeless != 0
replace StudentSubGroup_TotalTested = string(max - Military) if StudentGroup == "Military Connected Status" & max != 0 & StudentSubGroup_TotalTested2 == . & Military != 0
replace StudentSubGroup_TotalTested = string(max - Foster) if StudentGroup == "Foster Care Status" & max != 0 & StudentSubGroup_TotalTested2 == . & Foster != 0
replace StudentSubGroup_TotalTested = string(max - Disability) if StudentGroup == "Disability Status" & max != 0 & StudentSubGroup_TotalTested2 == . & Disability != 0
drop RaceEth Econ EL Gender Migrant Homeless Military Foster Disability StudentSubGroup_TotalTested2

//Performance Information
foreach var of varlist *_percent ParticipationRate {
	destring `var', gen(`var'2) force
	replace `var' = string(`var'2, "%9.8f") if `var'2 != .
	replace `var' = "*" if `var' == "***"
	drop `var'2
}

replace ParticipationRate = "1" if ParticipationRate == "1.00e+00"

foreach var of varlist *_count {
	replace `var' = "*" if `var' == "***"
	replace `var' = "0-3" if `var' == "≤3"
}

gen Lev5_count = ""
gen Lev5_percent = ""

//Derive additional information
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent), "%9.8f") if ProficientOrAbove_percent == "*" & Lev1_percent != "*" & Lev2_percent != "*"
replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent), "%9.8f") if Lev3_percent == "*" & ProficientOrAbove_percent != "*" & Lev4_percent != "*"
replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent), "%9.8f") if Lev4_percent == "*" & ProficientOrAbove_percent != "*" & Lev3_percent != "*"
replace Lev1_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev2_percent), "%9.8f") if Lev1_percent == "*" & ProficientOrAbove_percent != "*" & Lev2_percent != "*"
replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent), "%9.8f") if Lev2_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*"

forvalues n = 1/4{
	replace Lev`n'_percent = "0" if Lev`n'_percent == "-0.00000000"
	replace Lev`n'_percent = "0" if Lev`n'_percent == "0.00e+00"
	replace Lev`n'_count = "0" if Lev`n'_percent == "0" & Lev`n'_count == "0-3"
}

replace ProficientOrAbove_percent = "0" if ProficientOrAbove_percent == "-0.00000000"
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_percent == "0.00e+00"
replace ProficientOrAbove_count = "0" if ProficientOrAbove_percent == "0" & ProficientOrAbove_count == "0-3"

replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count)) if inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(StudentSubGroup_TotalTested, "*", "0-3") & !inlist(Lev1_count, "*", "0-3") & !inlist(Lev2_count, "*", "0-3")
replace ProficientOrAbove_percent = "1" if ProficientOrAbove_percent == "1.00e+00"
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_count == "0"
replace ProficientOrAbove_count = "0" if ProficientOrAbove_percent == "0"

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count)) if inlist(Lev1_count, "*", "0-3") & !inlist(StudentSubGroup_TotalTested, "*", "0-3") & !inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(Lev2_count, "*", "0-3") & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) >= 0
replace Lev1_count = "0" if inlist(Lev1_count, "*", "0-3") & !inlist(StudentSubGroup_TotalTested, "*", "0-3") & !inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(Lev2_count, "*", "0-3") & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) < 0
replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count)) if inlist(Lev2_count, "*", "0-3") & !inlist(StudentSubGroup_TotalTested, "*", "0-3") & !inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(Lev1_count, "*", "0-3") & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count) >= 0
replace Lev2_count = "0" if inlist(Lev2_count, "*", "0-3") & !inlist(StudentSubGroup_TotalTested, "*", "0-3") & !inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(Lev1_count, "*", "0-3") & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count) < 0
replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count)) if inlist(Lev3_count, "*", "0-3") & !inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(Lev4_count, "*", "0-3") & real(ProficientOrAbove_count) - real(Lev4_count) >= 0
replace Lev3_count = "0" if inlist(Lev3_count, "*", "0-3") & !inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(Lev4_count, "*", "0-3") & real(ProficientOrAbove_count) - real(Lev4_count) < 0
replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count)) if inlist(Lev4_count, "*", "0-3") & !inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(Lev3_count, "*", "0-3") & real(ProficientOrAbove_count) - real(Lev3_count) >= 0
replace Lev4_count = "0" if inlist(Lev4_count, "*", "0-3") & !inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(Lev3_count, "*", "0-3") & real(ProficientOrAbove_count) - real(Lev3_count) < 0

forvalues n = 1/4{
	replace Lev`n'_percent = "1" if Lev`n'_percent == "1.00e+00"
	replace Lev`n'_percent = "0" if strpos(Lev`n'_percent, "e") > 0
	replace Lev`n'_count = "0" if Lev`n'_percent == "0"
	replace Lev`n'_percent = "0" if Lev`n'_count == "0"
}

//Assessment Information
gen SchYear = "2023-24"
gen AssmtName = "OSTP"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

//Merge with NCES
gen State_leaid = "OK-" + StateAssignedDistID if DataLevel != 1
gen seasch = StateAssignedSchID

merge m:1 State_leaid using "${NCES}/NCES_2022_District_OK.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2022_School_OK.dta"
drop if _merge == 2
drop _merge

//Cleaning up from NCES
replace State = "Oklahoma"
replace StateAbbrev = "OK"
replace StateFips = 40
replace DistName = strproper(DistName)
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

//2024 New Districts & Schools
replace NCESDistrictID = "4033606" if StateAssignedDistID == "72-G006"
replace DistName = "Tulsa Classical Academy" if NCESDistrictID == "4033606"
replace DistType = 7 if NCESDistrictID == "4033606"
replace DistCharter = "Yes" if NCESDistrictID == "4033606"
replace DistLocale = "City, large" if NCESDistrictID == "4033606"
replace CountyName = "Tulsa County" if NCESDistrictID == "4033606"
replace CountyCode = "40143" if NCESDistrictID == "4033606"
replace NCESSchoolID = "403360629879" if StateAssignedSchID == "72-G006-930"
replace SchName = "TULSA CLASSICAL ACADEMY" if NCESSchoolID == "403360629879"
replace SchType = 1 if NCESSchoolID == "403360629879"
replace SchLevel = 1 if NCESSchoolID == "403360629879"
replace SchVirtual = 0 if NCESSchoolID == "403360629879"

replace NCESDistrictID = "4033605" if StateAssignedDistID == "55-Z016"
replace DistName = "Virtual Preparatory Academy (Charter)" if NCESDistrictID == "4033605"
replace DistType = 7 if NCESDistrictID == "4033605"
replace DistCharter = "Yes" if NCESDistrictID == "4033605"
replace DistLocale = "City, large" if NCESDistrictID == "4033605"
replace CountyName = "Oklahoma County" if NCESDistrictID == "4033605"
replace CountyCode = "40109" if NCESDistrictID == "4033605"
replace NCESSchoolID = "403360529873" if StateAssignedSchID == "55-Z016-930"
replace SchName = "VIRTUAL PREPARATORY ACADEMY (CHARTER)" if NCESSchoolID == "403360529873"
replace SchType = 1 if NCESSchoolID == "403360529873"
replace SchLevel = 1 if NCESSchoolID == "403360529873"
replace SchVirtual = 1 if NCESSchoolID == "403360529873"

replace NCESSchoolID = "400079629870" if StateAssignedSchID == "55-G021-938"
replace SchName = "SANTA FE SOUTH SHIDLER ELEMENTARY" if NCESSchoolID == "400079629870"
replace SchType = 1 if NCESSchoolID == "400079629870"
replace SchLevel = 1 if NCESSchoolID == "400079629870"
replace SchVirtual = 0 if NCESSchoolID == "400079629870"

replace NCESSchoolID = "400079629871" if StateAssignedSchID == "55-G021-984"
replace SchName = "SANTA FE SOUTH WEST MIDDLE SCHOOL" if NCESSchoolID == "400079629871"
replace SchType = 1 if NCESSchoolID == "400079629871"
replace SchLevel = 2 if NCESSchoolID == "400079629871"
replace SchVirtual = 0 if NCESSchoolID == "400079629871"

replace NCESSchoolID = "400762029872" if StateAssignedSchID == "55-I004-130"
replace SchName = "GRIFFITH MERIDIAN ELEMENTARY" if NCESSchoolID == "400762029872"
replace SchType = 1 if NCESSchoolID == "400762029872"
replace SchLevel = 1 if NCESSchoolID == "400762029872"
replace SchVirtual = 0 if NCESSchoolID == "400762029872"

replace NCESSchoolID = "401944029875" if StateAssignedSchID == "61-I080-160"
replace SchName = "PUTERBAUGH UPPER ELEMENTARY" if NCESSchoolID == "401944029875"
replace SchType = 1 if NCESSchoolID == "401944029875"
replace SchLevel = 1 if NCESSchoolID == "401944029875"
replace SchVirtual = 0 if NCESSchoolID == "401944029875"

replace NCESSchoolID = "401944029876" if StateAssignedSchID == "61-I080-515"
replace SchName = "RANDY HUGHES MIDDLE SCHOOL" if NCESSchoolID == "401944029876"
replace SchType = 1 if NCESSchoolID == "401944029876"
replace SchLevel = 2 if NCESSchoolID == "401944029876"
replace SchVirtual = 0 if NCESSchoolID == "401944029876"

replace NCESSchoolID = "400079129878" if StateAssignedSchID == "72-E017-979"
replace SchName = "COLLEGE BOUND ACADEMY-BROOKSIDE CAMPUS" if NCESSchoolID == "400079129878"
replace SchType = 1 if NCESSchoolID == "400079129878"
replace SchLevel = 1 if NCESSchoolID == "400079129878"
replace SchVirtual = 0 if NCESSchoolID == "400079129878"

//AvgScaleScore
merge 1:1 State_leaid seasch Subject GradeLevel StudentSubGroup using "${raw}/OK_AssmtData_2024.dta"
drop if _merge == 2
drop _merge
replace AvgScaleScore = "--" if AvgScaleScore == ""

//Final Cleaning
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
save "${output}/OK_AssmtData_2024.dta", replace

export delimited using "${output}/csv/OK_AssmtData_2024.csv", replace
