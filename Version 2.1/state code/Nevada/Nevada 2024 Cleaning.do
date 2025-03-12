*******************************************************
* NEVADA

* File name: Nevada 2024 Cleaning
* Last update: 2/28/2025

*******************************************************
* Notes

	* This do file first appends multiple NV 2024 dta files.
	* The combined files are then cleaned and merged with NCES 2022.
	* As of 2/28/25, the latest NCES data is 2022.
	* This file will need to be updated when NCES 2023 is available.
	* The non-derivation and usual output are created. 
*******************************************************
///////////////////////////////
// Setup
///////////////////////////////
clear
set more off

local levels "state districts schools"
foreach lev of local levels{
	use "${Original}/ELA & Math/2024/`lev'/NV_OriginalData_2024_ela_math_G38.dta", clear
	append using "${Original}/Sci/2024/`lev'/NV_OriginalData_2024_sci_G38.dta"
	gen GradeLevel = "G38"
	forvalues n = 3/8{
		append using "${Original}/ELA & Math/2024/`lev'/NV_OriginalData_2024_ela_math_G0`n'.dta"
		if `n' == 5 | `n' == 8{
			append using "${Original}/Sci/2024/`lev'/NV_OriginalData_2024_sci_G0`n'.dta"
		}
		replace GradeLevel = "G0`n'" if GradeLevel == ""
	}
	gen DataLevel = "`lev'"
	save "${Original}/NV_OriginalData_2024_`lev'", replace
}

use "${Original}/NV_OriginalData_2024_state", clear
append using "${Original}/NV_OriginalData_2024_districts" "${Original}/NV_OriginalData_2024_schools"

drop *NotTested

rename ELA* *ela
rename Mathematics* *math
rename Science* *sci

drop if Group == "Unknown"

duplicates drop

reshape long NumberTested Tested Proficient EmergentDeveloping ApproachesStandard MeetsStandard ExceedsStandard, i(Group OrganizationCode GradeLevel Sub1) j(Subject) string
drop if Subject == "sci" & !inlist(GradeLevel, "G05", "G08", "G38")

drop if Sub1 == "elamat" & Subject == "sci"
drop if Sub1 == "sci" & Subject != "sci"

rename Year SchYear
rename NumberTested StudentSubGroup_TotalTested
rename Tested ParticipationRate
rename Proficient ProficientOrAbove_percent
rename EmergentDeveloping Lev1_percent
rename ApproachesStandard Lev2_percent
rename MeetsStandard Lev3_percent
rename ExceedsStandard Lev4_percent

** Replacing variables
replace SchYear = "2023-24"

** Generating new variables
gen StateAssignedSchID = OrganizationCode
sort StateAssignedSchID
gen StateAssignedDistID = StateAssignedSchID
replace StateAssignedDistID = substr(StateAssignedSchID, 1, 2)

replace DataLevel = "School" if DataLevel == "schools"
replace DataLevel = "District" if DataLevel == "districts"
replace DataLevel = "State" if DataLevel == "state"

replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
drop OrganizationCode

drop if inlist(Group, "Grade 3", "Grade 4", "Grade 5", "Grade 6", "Grade 7", "Grade 8")
drop if inlist(Group, "NewcomerEL", "Not NewcomerEL", "ShortTermEL", "Not ShortTermEL", "Not LongTermEL", "IEP w/ Acc", "IEP w/o Acc")
gen StudentSubGroup = "All Students"
replace StudentSubGroup = "Female" if Group == "Female"
replace StudentSubGroup = "Male" if Group == "Male"
replace StudentSubGroup = "American Indian or Alaska Native" if Group == "Am In/AK Native"
replace StudentSubGroup = "Black or African American" if Group == "Black"
replace StudentSubGroup = "Hispanic or Latino" if Group == "Hispanic"
replace StudentSubGroup = "White" if Group == "White"
replace StudentSubGroup = "Two or More" if Group == "Two or More Races"
replace StudentSubGroup = "Asian" if Group == "Asian"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if Group == "Pacific Islander"
replace StudentSubGroup = "SWD" if Group == "IEP"
replace StudentSubGroup = "Non-SWD" if Group == "Not IEP"
replace StudentSubGroup = "English Learner" if Group == "EL"
replace StudentSubGroup = "English Proficient" if Group == "Not EL" 
replace StudentSubGroup = "Economically Disadvantaged" if Group == "FRL"
replace StudentSubGroup = "Not Economically Disadvantaged" if Group == "Not FRL"
replace StudentSubGroup = "Migrant" if Group == "Migrant"
replace StudentSubGroup = "Non-Migrant" if Group == "Not Migrant"
replace StudentSubGroup = "Homeless" if Group == "Homeless"
replace StudentSubGroup = "Non-Homeless" if Group == "Not Homeless"
replace StudentSubGroup = "Foster Care" if Group == "Foster"
replace StudentSubGroup = "Non-Foster Care" if Group == "Not Foster"
replace StudentSubGroup = "Military" if Group == "Military Connected"
replace StudentSubGroup = "Non-Military" if Group == "Not Military Connected"
replace StudentSubGroup = "LTEL" if Group == "LongTermEL"

gen StudentGroup = "All Students"
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
replace StudentGroup = "RaceEth" if inlist(StudentSubGroup, "American Indian or Alaska Native", "Black or African American", "Hispanic or Latino", "White", "Two or More", "Asian", "Native Hawaiian or Pacific Islander")
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "Migrant Status" if inlist(StudentSubGroup, "Migrant", "Non-Migrant")
replace StudentGroup = "Homeless Enrolled Status" if inlist(StudentSubGroup, "Homeless", "Non-Homeless")
replace StudentGroup = "Foster Care Status" if inlist(StudentSubGroup, "Foster Care", "Non-Foster Care")
replace StudentGroup = "Military Connected Status" if inlist(StudentSubGroup, "Military", "Non-Military")

drop Group

gen AssmtName = "SBAC"
replace AssmtName = "Science" if Subject == "sci"
gen AssmtType = "Regular"

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "-"

sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"

bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen RaceEth = sum(StudentSubGroup_TotalTested2) if StudentGroup == "RaceEth"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Econ = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Economic Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen EL = sum(StudentSubGroup_TotalTested2) if StudentGroup == "EL Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Gender = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Gender"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Migrant = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Migrant Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Homeless = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Homeless Enrolled Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Military = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Military Connected Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Foster = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Foster Care Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Disability = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Disability Status"

gen max = real(StudentGroup_TotalTested)
replace max = 0 if max == .

gen x = 1 if missing(real(StudentSubGroup_TotalTested))
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject StudentGroup: egen flag = sum(x)

replace StudentSubGroup_TotalTested2 = max - RaceEth if StudentGroup == "RaceEth" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag <= 1
replace StudentSubGroup_TotalTested2 = real(StudentGroup_TotalTested) - Econ if StudentGroup == "Economic Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & Econ != 0 & flag <= 1
replace StudentSubGroup_TotalTested2 = max - EL if StudentSubGroup == "English Proficient" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & EL != 0
replace StudentSubGroup_TotalTested2 = max - EL if StudentSubGroup == "English Learner" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & EL != 0
replace StudentSubGroup_TotalTested2 = max - Gender if StudentGroup == "Gender" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & Gender != 0 & flag <= 1
replace StudentSubGroup_TotalTested2 = max - Migrant if StudentGroup == "Migrant Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & Migrant != 0 & flag <= 1
replace StudentSubGroup_TotalTested2 = max - Homeless if StudentGroup == "Homeless Enrolled Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & Homeless != 0 & flag <= 1
replace StudentSubGroup_TotalTested2 = max - Military if StudentGroup == "Military Connected Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & Military != 0 & flag <= 1
replace StudentSubGroup_TotalTested2 = max - Foster if StudentGroup == "Foster Care Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & Foster != 0 & flag <= 1
replace StudentSubGroup_TotalTested2 = max - Disability if StudentGroup == "Disability Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & Disability != 0 & flag <= 1

replace StudentSubGroup_TotalTested = string(StudentSubGroup_TotalTested2) if missing(real(StudentSubGroup_TotalTested)) & StudentSubGroup_TotalTested2 != . & StudentSubGroup != "All Students"
drop if inlist(StudentSubGroup_TotalTested, "", "0") & StudentSubGroup != "All Students"

replace StudentGroup = "EL Status" if StudentSubGroup == "LTEL"

// Saving transformed data, will restore this file for non-derivation output. 
save "${Temp}/NV_AssmtData_2024_Breakpoint.dta", replace
*******************************************************
**Derivations***
*******************************************************
local level Lev1 Lev2 Lev3 Lev4 ProficientOrAbove 
foreach a of local level {
	gen `a'_percent2 = subinstr(`a'_percent, "<", "", .)
	replace `a'_percent2 = subinstr(`a'_percent2, ">", "", .)
	destring `a'_percent2, replace force
	replace `a'_percent2 = `a'_percent2/100
	gen `a'_count = round(StudentSubGroup_TotalTested2 * `a'_percent2)
	tostring `a'_percent2, replace format("%9.3f") force
	replace `a'_percent2 = "0-" + `a'_percent2 if strpos(`a'_percent, "<") > 0
	replace `a'_percent2 = `a'_percent2 + "-1" if strpos(`a'_percent, ">") > 0
	replace `a'_percent2 = "*" if `a'_percent2 == "."
	tostring `a'_count, replace force
	replace `a'_count = "0-" + `a'_count if strpos(`a'_percent, "<") > 0
	replace `a'_count = `a'_count + "-" + StudentSubGroup_TotalTested if strpos(`a'_percent, ">") > 0 & StudentGroup_TotalTested != "*" & `a'_count != StudentSubGroup_TotalTested
	replace `a'_count = "*" if `a'_count == "."
	drop `a'_percent
	rename `a'_percent2 `a'_percent
	split `a'_percent, parse("-")
	destring `a'_percent1, replace force
	destring `a'_percent2, replace force
}

replace ProficientOrAbove_percent1 = 1 - Lev1_percent1 - Lev2_percent1 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent1 != . & Lev2_percent1 != . & Lev1_percent2 == . & Lev2_percent2 == .
replace ProficientOrAbove_percent1 = 1 - Lev1_percent2 - Lev2_percent1 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent2 != . & Lev2_percent1 != . & Lev2_percent2 == .
replace ProficientOrAbove_percent1 = 1 - Lev1_percent1 - Lev2_percent2 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent1 != . & Lev2_percent2 != . & Lev1_percent2 == .
replace ProficientOrAbove_percent1 = 1 - Lev1_percent2 - Lev2_percent2 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent2 != . & Lev2_percent2 != .
replace ProficientOrAbove_percent1 = 0 if ProficientOrAbove_percent1 < 0

replace ProficientOrAbove_percent2 = 1 - Lev1_percent1 - Lev2_percent1 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent1 != . & Lev2_percent1 != . & Lev1_percent2 != . & Lev2_percent2 != .
replace ProficientOrAbove_percent2 = 1 - Lev1_percent1 - Lev2_percent1 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent1 != . & Lev2_percent1 != . & Lev1_percent2 != . & Lev2_percent2 == .
replace ProficientOrAbove_percent2 = 1 - Lev1_percent1 - Lev2_percent1 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent1 != . & Lev2_percent1 != . & Lev1_percent2 == . & Lev2_percent2 != .
replace ProficientOrAbove_percent2 = 0 if ProficientOrAbove_percent2 < 0

replace ProficientOrAbove_percent = string(ProficientOrAbove_percent1, "%9.3f") if inlist(ProficientOrAbove_percent, "*", "--") & ProficientOrAbove_percent1 != . & ProficientOrAbove_percent2 == .
replace ProficientOrAbove_percent = string(ProficientOrAbove_percent1, "%9.3f") if inlist(ProficientOrAbove_percent, "*", "--") & ProficientOrAbove_percent1 != . & ProficientOrAbove_percent1 == ProficientOrAbove_percent2
replace ProficientOrAbove_percent = string(ProficientOrAbove_percent1, "%9.3f") + "-" + string(ProficientOrAbove_percent2, "%9.3f") if inlist(ProficientOrAbove_percent, "*", "--") & ProficientOrAbove_percent1 != . & ProficientOrAbove_percent2 != . & ProficientOrAbove_percent1 != ProficientOrAbove_percent2

replace ProficientOrAbove_count = string(round(StudentSubGroup_TotalTested2 * ProficientOrAbove_percent1)) if inlist(ProficientOrAbove_count, "*", "--") & StudentSubGroup_TotalTested2 != . & ProficientOrAbove_percent1 != . & ProficientOrAbove_percent2 == .
replace ProficientOrAbove_count = string(round(StudentSubGroup_TotalTested2 * ProficientOrAbove_percent1)) if inlist(ProficientOrAbove_count, "*", "--") & StudentSubGroup_TotalTested2 != . & ProficientOrAbove_percent1 != . & ProficientOrAbove_percent2 != . & round(StudentSubGroup_TotalTested2 * ProficientOrAbove_percent1) == round(StudentSubGroup_TotalTested2 * ProficientOrAbove_percent2)
replace ProficientOrAbove_count = string(round(StudentSubGroup_TotalTested2 * ProficientOrAbove_percent1)) + "-" + string(round(StudentSubGroup_TotalTested2 * ProficientOrAbove_percent2)) if inlist(ProficientOrAbove_count, "*", "--") & StudentSubGroup_TotalTested2 != . & ProficientOrAbove_percent1 != . & ProficientOrAbove_percent2 != . & round(StudentSubGroup_TotalTested2 * ProficientOrAbove_percent1) != round(StudentSubGroup_TotalTested2 * ProficientOrAbove_percent2)

replace Lev3_percent1 = ProficientOrAbove_percent1 - Lev4_percent1 if Lev3_percent1 == . & ProficientOrAbove_percent1 != . & Lev4_percent1 != . & Lev4_percent2 == .
replace Lev3_percent1 = ProficientOrAbove_percent1 - Lev4_percent2 if Lev3_percent1 == . & ProficientOrAbove_percent1 != . & Lev4_percent2 != . & ProficientOrAbove_percent2 == .
replace Lev3_percent1 = ProficientOrAbove_percent2 - Lev4_percent2 if Lev3_percent1 == . & ProficientOrAbove_percent2 != . & Lev4_percent2 != .
replace Lev3_percent1 = 0 if Lev3_percent1 < 0 & Lev3_percent1 != .

replace Lev3_percent2 = ProficientOrAbove_percent2 - Lev4_percent1 if Lev3_percent2 == . & ProficientOrAbove_percent2 != . & Lev4_percent1 != .
replace Lev3_percent2 = ProficientOrAbove_percent1 - Lev4_percent1 if Lev3_percent2 == . & ProficientOrAbove_percent1 != . & Lev4_percent1 != . & ProficientOrAbove_percent2 == . & Lev4_percent2 != .
replace Lev3_percent2 = 0 if Lev3_percent2 < 0 & Lev3_percent2 != .

replace Lev3_percent = string(Lev3_percent1, "%9.3f") if inlist(Lev3_percent, "*", "--") & Lev3_percent1 != . & Lev3_percent2 == .
replace Lev3_percent = string(Lev3_percent1, "%9.3f") if inlist(Lev3_percent, "*", "--") & Lev3_percent1 != . & Lev3_percent1 == Lev3_percent2
replace Lev3_percent = string(Lev3_percent1, "%9.3f") + "-" + string(Lev3_percent2, "%9.3f") if inlist(Lev3_percent, "*", "--") & Lev3_percent1 != . & Lev3_percent2 != . & Lev3_percent1 != Lev3_percent2

replace Lev3_count = string(round(StudentSubGroup_TotalTested2 * Lev3_percent1)) if inlist(Lev3_count, "*", "--") & StudentSubGroup_TotalTested2 != . & Lev3_percent1 != . & Lev3_percent2 == .
replace Lev3_count = string(round(StudentSubGroup_TotalTested2 * Lev3_percent1)) if inlist(Lev3_count, "*", "--") & StudentSubGroup_TotalTested2 != . & Lev3_percent1 != . & Lev3_percent2 != . & round(StudentSubGroup_TotalTested2 * Lev3_percent1) == round(StudentSubGroup_TotalTested2 * Lev3_percent2)
replace Lev3_count = string(round(StudentSubGroup_TotalTested2 * Lev3_percent1)) + "-" + string(round(StudentSubGroup_TotalTested2 * Lev3_percent2)) if inlist(Lev3_count, "*", "--") & StudentSubGroup_TotalTested2 != . & Lev3_percent1 != . & Lev3_percent2 != . & round(StudentSubGroup_TotalTested2 * Lev3_percent1) != round(StudentSubGroup_TotalTested2 * Lev3_percent2)

replace Lev4_percent1 = ProficientOrAbove_percent1 - Lev3_percent1 if Lev4_percent1 == . & ProficientOrAbove_percent1 != . & Lev3_percent1 != . & Lev3_percent2 == .
replace Lev4_percent1 = ProficientOrAbove_percent1 - Lev3_percent2 if Lev4_percent1 == . & ProficientOrAbove_percent1 != . & Lev3_percent2 != .
replace Lev4_percent1 = ProficientOrAbove_percent2 - Lev3_percent2 if Lev4_percent1 == . & ProficientOrAbove_percent2 != . & Lev3_percent2 != .
replace Lev4_percent1 = 0 if Lev4_percent1 < 0 & Lev4_percent1 != .

replace Lev4_percent2 = ProficientOrAbove_percent2 - Lev3_percent1 if Lev4_percent2 == . & ProficientOrAbove_percent2 != . & Lev3_percent1 != .
replace Lev4_percent2 = ProficientOrAbove_percent1 - Lev3_percent1 if Lev4_percent2 == . & ProficientOrAbove_percent1 != . & Lev3_percent1 != . & ProficientOrAbove_percent2 == . & Lev3_percent2 != .
replace Lev4_percent2 = 0 if Lev4_percent2 < 0 & Lev4_percent2 != .

replace Lev4_percent = string(Lev4_percent1, "%9.3f") if inlist(Lev4_percent, "*", "--") & Lev4_percent1 != . & Lev4_percent2 == .
replace Lev4_percent = string(Lev4_percent1, "%9.3f") if inlist(Lev4_percent, "*", "--") & Lev4_percent1 != . & Lev4_percent1 == Lev4_percent2
replace Lev4_percent = string(Lev4_percent1, "%9.3f") + "-" + string(Lev4_percent2, "%9.3f") if inlist(Lev4_percent, "*", "--") & Lev4_percent1 != . & Lev4_percent2 != . & Lev4_percent1 != Lev4_percent2

replace Lev4_count = string(round(StudentSubGroup_TotalTested2 * Lev4_percent1)) if inlist(Lev4_count, "*", "--") & StudentSubGroup_TotalTested2 != . & Lev4_percent1 != . & Lev4_percent2 == .
replace Lev4_count = string(round(StudentSubGroup_TotalTested2 * Lev4_percent1)) if inlist(Lev4_count, "*", "--") & StudentSubGroup_TotalTested2 != . & Lev4_percent1 != . & Lev4_percent2 != . & round(StudentSubGroup_TotalTested2 * Lev4_percent1) == round(StudentSubGroup_TotalTested2 * Lev4_percent2)
replace Lev4_count = string(round(StudentSubGroup_TotalTested2 * Lev4_percent1)) + "-" + string(round(StudentSubGroup_TotalTested2 * Lev4_percent2)) if inlist(Lev4_count, "*", "--") & StudentSubGroup_TotalTested2 != . & Lev4_percent1 != . & Lev4_percent2 != . & round(StudentSubGroup_TotalTested2 * Lev4_percent1) != round(StudentSubGroup_TotalTested2 * Lev4_percent2)

replace Lev1_percent1 = 1 - ProficientOrAbove_percent1 - Lev2_percent1 if Lev1_percent1 == . & ProficientOrAbove_percent1 != . & Lev2_percent1 != . & Lev2_percent2 == .
replace Lev1_percent1 = 1 - ProficientOrAbove_percent1 - Lev2_percent2 if Lev1_percent1 == . & ProficientOrAbove_percent1 != . & Lev2_percent2 != . & ProficientOrAbove_percent2 == .
replace Lev1_percent1 = 1 - ProficientOrAbove_percent2 - Lev2_percent2 if Lev1_percent1 == . & ProficientOrAbove_percent2 != . & Lev2_percent2 != .
replace Lev1_percent1 = 0 if Lev1_percent1 < 0 & Lev1_percent1 != .

replace Lev1_percent2 = 1 - ProficientOrAbove_percent2 - Lev2_percent1 if Lev1_percent2 == . & ProficientOrAbove_percent2 != . & Lev2_percent1 != .
replace Lev1_percent2 = 1 - ProficientOrAbove_percent1 - Lev2_percent1 if Lev1_percent2 == . & ProficientOrAbove_percent1 != . & Lev2_percent1 != . & ProficientOrAbove_percent2 == . & Lev2_percent2 != .
replace Lev1_percent2 = 0 if Lev1_percent2 < 0 & Lev1_percent2 != .

replace Lev1_percent = string(Lev1_percent1, "%9.3f") if inlist(Lev1_percent, "*", "--") & Lev1_percent1 != . & Lev1_percent2 == .
replace Lev1_percent = string(Lev1_percent1, "%9.3f") if inlist(Lev1_percent, "*", "--") & Lev1_percent1 != . & Lev1_percent1 == Lev1_percent2
replace Lev1_percent = string(Lev1_percent1, "%9.3f") + "-" + string(Lev1_percent2, "%9.3f") if inlist(Lev1_percent, "*", "--") & Lev1_percent1 != . & Lev1_percent2 != . & Lev1_percent1 != Lev1_percent2

replace Lev1_count = string(round(StudentSubGroup_TotalTested2 * Lev1_percent1)) if inlist(Lev1_count, "*", "--") & StudentSubGroup_TotalTested2 != . & Lev1_percent1 != . & Lev1_percent2 == .
replace Lev1_count = string(round(StudentSubGroup_TotalTested2 * Lev1_percent1)) if inlist(Lev1_count, "*", "--") & StudentSubGroup_TotalTested2 != . & Lev1_percent1 != . & Lev1_percent2 != . & round(StudentSubGroup_TotalTested2 * Lev1_percent1) == round(StudentSubGroup_TotalTested2 * Lev1_percent2)
replace Lev1_count = string(round(StudentSubGroup_TotalTested2 * Lev1_percent1)) + "-" + string(round(StudentSubGroup_TotalTested2 * Lev1_percent2)) if inlist(Lev1_count, "*", "--") & StudentSubGroup_TotalTested2 != . & Lev1_percent1 != . & Lev1_percent2 != . & round(StudentSubGroup_TotalTested2 * Lev1_percent1) != round(StudentSubGroup_TotalTested2 * Lev1_percent2)

replace Lev2_percent1 = 1 - ProficientOrAbove_percent1 - Lev1_percent1 if Lev2_percent1 == . & ProficientOrAbove_percent1 != . & Lev1_percent1 != . & Lev1_percent2 == .
replace Lev2_percent1 = 1 - ProficientOrAbove_percent1 - Lev1_percent2 if Lev2_percent1 == . & ProficientOrAbove_percent1 != . & Lev1_percent2 != . & ProficientOrAbove_percent1 == .
replace Lev2_percent1 = 1 - ProficientOrAbove_percent2 - Lev1_percent2 if Lev2_percent1 == . & ProficientOrAbove_percent2 != . & Lev1_percent2 != .
replace Lev2_percent1 = 0 if Lev2_percent1 < 0 & Lev2_percent1 != .

replace Lev2_percent2 = 1 - ProficientOrAbove_percent2 - Lev1_percent1 if Lev2_percent2 == . & ProficientOrAbove_percent2 != . & Lev1_percent1 != .
replace Lev2_percent2 = 1 - ProficientOrAbove_percent1 - Lev1_percent1 if Lev2_percent2 == . & ProficientOrAbove_percent1 != . & Lev1_percent1 != . & ProficientOrAbove_percent2 == . & Lev1_percent2 != .
replace Lev2_percent2 = 0 if Lev2_percent2 < 0 & Lev2_percent2 != .

replace Lev2_percent = string(Lev2_percent1, "%9.3f") if inlist(Lev2_percent, "*", "--") & Lev2_percent1 != . & Lev2_percent2 == .
replace Lev2_percent = string(Lev2_percent1, "%9.3f") if inlist(Lev2_percent, "*", "--") & Lev2_percent1 != . & Lev2_percent1 == Lev2_percent2
replace Lev2_percent = string(Lev2_percent1, "%9.3f") + "-" + string(Lev2_percent2, "%9.3f") if inlist(Lev2_percent, "*", "--") & Lev2_percent1 != . & Lev2_percent2 != . & Lev2_percent1 != Lev2_percent2

replace Lev2_count = string(round(StudentSubGroup_TotalTested2 * Lev2_percent1)) if inlist(Lev2_count, "*", "--") & StudentSubGroup_TotalTested2 != . & Lev2_percent1 != . & Lev2_percent2 == .
replace Lev2_count = string(round(StudentSubGroup_TotalTested2 * Lev2_percent1)) if inlist(Lev2_count, "*", "--") & StudentSubGroup_TotalTested2 != . & Lev2_percent1 != . & Lev2_percent2 != . & round(StudentSubGroup_TotalTested2 * Lev2_percent1) == round(StudentSubGroup_TotalTested2 * Lev2_percent2)
replace Lev2_count = string(round(StudentSubGroup_TotalTested2 * Lev2_percent1)) + "-" + string(round(StudentSubGroup_TotalTested2 * Lev2_percent2)) if inlist(Lev2_count, "*", "--") & StudentSubGroup_TotalTested2 != . & Lev1_percent2 != . & Lev2_percent2 != . & round(StudentSubGroup_TotalTested2 * Lev2_percent1) != round(StudentSubGroup_TotalTested2 * Lev2_percent2)

local level Lev1 Lev2 Lev3 Lev4 ProficientOrAbove 
foreach a of local level {
	replace `a'_percent = "0-0.05" if inlist(`a'_percent, "0.000-0.050", "0.0000-0.05000", "0-0.050", "0-0.0500")
	replace `a'_percent = "0.95-1" if inlist(`a'_percent, "0.950-1", "0.9500-1")
}

gen flag2 = 1 if Lev4_percent == "0-0.05" & strpos(ProficientOrAbove_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0
replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent), "%9.3f") if flag2 == 1 & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev3_percent))
replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count)) if flag2 == 1 & !missing(real(ProficientOrAbove_count)) & !missing(real(Lev3_count))

gen Lev5_count = ""
gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"

gen ParticipationRate2 = subinstr(ParticipationRate, "<", "", .)
replace ParticipationRate2 = subinstr(ParticipationRate2, ">", "", .)
destring ParticipationRate2, replace force
replace ParticipationRate2 = ParticipationRate2/100
tostring ParticipationRate2, replace force
replace ParticipationRate2 = "0-" + ParticipationRate2 if strpos(ParticipationRate, "<") > 0
replace ParticipationRate2 = ParticipationRate2 + "-1" if strpos(ParticipationRate, ">") > 0
replace ParticipationRate2 = "*" if ParticipationRate2 == "."
drop ParticipationRate max StudentSubGroup_TotalTested2
rename ParticipationRate2 ParticipationRate

gen AvgScaleScore = "--"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

gen State_leaid = "NV-" + StateAssignedDistID
replace State_leaid = "" if DataLevel == 1

replace State_leaid = "NV-18" if inlist(StateAssignedSchID, "101101", "102100", "105101", "106101", "107101", "108101") | inlist(StateAssignedSchID, "110100", "112100", "111100", "113100", "114100", "116100")
replace StateAssignedDistID = "18" if inlist(StateAssignedSchID, "101101", "102100", "105101", "106101", "107101", "108101") | inlist(StateAssignedSchID, "110100", "112100", "111100", "113100", "114100", "116100")

replace State_leaid = "NV-19" if StateAssignedSchID == "84406"
replace StateAssignedDistID = "19" if StateAssignedSchID == "84406"
replace State_leaid = "NV-18" if StateAssignedSchID == "115100"
replace StateAssignedDistID = "18" if StateAssignedSchID == "115100"

merge m:1 State_leaid using "${NCES_NV}/NCES_2022_District_NV.dta"

replace State_leaid = "NV-18" if _merge == 1 & DataLevel != 1
replace StateAssignedDistID = "18" if _merge == 1 & DataLevel != 1

drop if _merge == 2
drop _merge

merge m:1 State_leaid using "${NCES_NV}/NCES_2022_District_NV.dta", update

drop if _merge == 2
drop _merge

gen seasch = StateAssignedDistID + "-" + StateAssignedSchID
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCES_NV}/NCES_2022_School_NV.dta"
drop if _merge == 2
drop _merge

** New Schools 2024
replace NCESSchoolID = "320000100990" if StateAssignedSchID == "58430"
replace SchName = "Pinecrest Academy of Nevada Springs" if NCESSchoolID == "320000100990"
replace SchType = 1 if NCESSchoolID == "320000100990"
replace SchLevel = 1 if NCESSchoolID == "320000100990"
replace SchVirtual = 0 if NCESSchoolID == "320000100990"
replace NCESSchoolID = "320000100991" if StateAssignedSchID == "88101"
replace SchName = "Eagle Charter Schools of Nevada" if NCESSchoolID == "320000100991"
replace SchType = 1 if NCESSchoolID == "320000100991"
replace SchLevel = 1 if NCESSchoolID == "320000100991"
replace SchVirtual = 0 if NCESSchoolID == "320000100991"

replace SchLevel = 1 if NCESSchoolID == "320006000572"
replace SchVirtual = 0 if NCESSchoolID == "320006000572"
replace SchLevel = 4 if NCESSchoolID == "320006000923"
replace SchVirtual = 0 if NCESSchoolID == "320006000923"
replace SchLevel = 1 if NCESSchoolID == "320048000978"
replace SchVirtual = 0 if NCESSchoolID == "320048000978"
replace SchLevel = 1 if NCESSchoolID == "320048000979"
replace SchVirtual = 0 if NCESSchoolID == "320048000979"

** Cleaning up from NCES
replace StateAbbrev = "NV" if DataLevel == 1
replace State = "Nevada" if DataLevel == 1
replace StateFips = 32 if DataLevel == 1
replace CountyName = proper(CountyName)
replace DistName = proper(DistName)
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3
replace DistName = stritrim(DistName)
replace SchName = stritrim(SchName)

replace StateAssignedSchID = subinstr(StateAssignedSchID, "0", "", 1) if strpos(StateAssignedSchID, "0") == 1

** Generating new variables
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

// Reordering variables and sorting data
local vars State StateAbbrev StateFips SchYear DataLevel DistName SchName ///
	NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID ///
	AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested ///
	StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent ///
	Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent ///
	Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ///
	ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA ///
	Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType ///
	DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output*
save "${Output}/NV_AssmtData_2024.dta", replace
export delimited using "${Output}/NV_AssmtData_2024.csv", replace

///////////////////////////////////////////////////////
*******************************************************
** Creating the non-derivation file
*******************************************************
///////////////////////////////////////////////////////
// Restoring the break-point 
use "${Temp}/NV_AssmtData_2024_Breakpoint.dta", clear

*******************************************************
*No counts are generated since they're calculated as percentage * SSGT
*******************************************************
local level Lev1 Lev2 Lev3 Lev4 ProficientOrAbove 
foreach a of local level {
	gen `a'_percent2 = subinstr(`a'_percent, "<", "", .)
	replace `a'_percent2 = subinstr(`a'_percent2, ">", "", .)
	destring `a'_percent2, replace force
	replace `a'_percent2 = `a'_percent2/100
	tostring `a'_percent2, replace format("%9.3f") force
	replace `a'_percent2 = "0-" + `a'_percent2 if strpos(`a'_percent, "<") > 0
	replace `a'_percent2 = `a'_percent2 + "-1" if strpos(`a'_percent, ">") > 0
	replace `a'_percent2 = "*" if `a'_percent2 == "."
	drop `a'_percent
	rename `a'_percent2 `a'_percent
	split `a'_percent, parse("-")
	destring `a'_percent1, replace force
	destring `a'_percent2, replace force
}

replace ProficientOrAbove_percent1 = 1 - Lev1_percent1 - Lev2_percent1 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent1 != . & Lev2_percent1 != . & Lev1_percent2 == . & Lev2_percent2 == .
replace ProficientOrAbove_percent1 = 1 - Lev1_percent2 - Lev2_percent1 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent2 != . & Lev2_percent1 != . & Lev2_percent2 == .
replace ProficientOrAbove_percent1 = 1 - Lev1_percent1 - Lev2_percent2 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent1 != . & Lev2_percent2 != . & Lev1_percent2 == .
replace ProficientOrAbove_percent1 = 1 - Lev1_percent2 - Lev2_percent2 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent2 != . & Lev2_percent2 != .
replace ProficientOrAbove_percent1 = 0 if ProficientOrAbove_percent1 < 0

replace ProficientOrAbove_percent2 = 1 - Lev1_percent1 - Lev2_percent1 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent1 != . & Lev2_percent1 != . & Lev1_percent2 != . & Lev2_percent2 != .
replace ProficientOrAbove_percent2 = 1 - Lev1_percent1 - Lev2_percent1 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent1 != . & Lev2_percent1 != . & Lev1_percent2 != . & Lev2_percent2 == .
replace ProficientOrAbove_percent2 = 1 - Lev1_percent1 - Lev2_percent1 if inlist(ProficientOrAbove_percent, "*", "--") & Lev1_percent1 != . & Lev2_percent1 != . & Lev1_percent2 == . & Lev2_percent2 != .
replace ProficientOrAbove_percent2 = 0 if ProficientOrAbove_percent2 < 0

replace ProficientOrAbove_percent = string(ProficientOrAbove_percent1, "%9.3f") if inlist(ProficientOrAbove_percent, "*", "--") & ProficientOrAbove_percent1 != . & ProficientOrAbove_percent2 == .
replace ProficientOrAbove_percent = string(ProficientOrAbove_percent1, "%9.3f") if inlist(ProficientOrAbove_percent, "*", "--") & ProficientOrAbove_percent1 != . & ProficientOrAbove_percent1 == ProficientOrAbove_percent2
replace ProficientOrAbove_percent = string(ProficientOrAbove_percent1, "%9.3f") + "-" + string(ProficientOrAbove_percent2, "%9.3f") if inlist(ProficientOrAbove_percent, "*", "--") & ProficientOrAbove_percent1 != . & ProficientOrAbove_percent2 != . & ProficientOrAbove_percent1 != ProficientOrAbove_percent2

replace Lev3_percent1 = ProficientOrAbove_percent1 - Lev4_percent1 if Lev3_percent1 == . & ProficientOrAbove_percent1 != . & Lev4_percent1 != . & Lev4_percent2 == .
replace Lev3_percent1 = ProficientOrAbove_percent1 - Lev4_percent2 if Lev3_percent1 == . & ProficientOrAbove_percent1 != . & Lev4_percent2 != . & ProficientOrAbove_percent2 == .
replace Lev3_percent1 = ProficientOrAbove_percent2 - Lev4_percent2 if Lev3_percent1 == . & ProficientOrAbove_percent2 != . & Lev4_percent2 != .
replace Lev3_percent1 = 0 if Lev3_percent1 < 0 & Lev3_percent1 != .

replace Lev3_percent2 = ProficientOrAbove_percent2 - Lev4_percent1 if Lev3_percent2 == . & ProficientOrAbove_percent2 != . & Lev4_percent1 != .
replace Lev3_percent2 = ProficientOrAbove_percent1 - Lev4_percent1 if Lev3_percent2 == . & ProficientOrAbove_percent1 != . & Lev4_percent1 != . & ProficientOrAbove_percent2 == . & Lev4_percent2 != .
replace Lev3_percent2 = 0 if Lev3_percent2 < 0 & Lev3_percent2 != .

replace Lev3_percent = string(Lev3_percent1, "%9.3f") if inlist(Lev3_percent, "*", "--") & Lev3_percent1 != . & Lev3_percent2 == .
replace Lev3_percent = string(Lev3_percent1, "%9.3f") if inlist(Lev3_percent, "*", "--") & Lev3_percent1 != . & Lev3_percent1 == Lev3_percent2
replace Lev3_percent = string(Lev3_percent1, "%9.3f") + "-" + string(Lev3_percent2, "%9.3f") if inlist(Lev3_percent, "*", "--") & Lev3_percent1 != . & Lev3_percent2 != . & Lev3_percent1 != Lev3_percent2

replace Lev4_percent1 = ProficientOrAbove_percent1 - Lev3_percent1 if Lev4_percent1 == . & ProficientOrAbove_percent1 != . & Lev3_percent1 != . & Lev3_percent2 == .
replace Lev4_percent1 = ProficientOrAbove_percent1 - Lev3_percent2 if Lev4_percent1 == . & ProficientOrAbove_percent1 != . & Lev3_percent2 != .
replace Lev4_percent1 = ProficientOrAbove_percent2 - Lev3_percent2 if Lev4_percent1 == . & ProficientOrAbove_percent2 != . & Lev3_percent2 != .
replace Lev4_percent1 = 0 if Lev4_percent1 < 0 & Lev4_percent1 != .

replace Lev4_percent2 = ProficientOrAbove_percent2 - Lev3_percent1 if Lev4_percent2 == . & ProficientOrAbove_percent2 != . & Lev3_percent1 != .
replace Lev4_percent2 = ProficientOrAbove_percent1 - Lev3_percent1 if Lev4_percent2 == . & ProficientOrAbove_percent1 != . & Lev3_percent1 != . & ProficientOrAbove_percent2 == . & Lev3_percent2 != .
replace Lev4_percent2 = 0 if Lev4_percent2 < 0 & Lev4_percent2 != .

replace Lev4_percent = string(Lev4_percent1, "%9.3f") if inlist(Lev4_percent, "*", "--") & Lev4_percent1 != . & Lev4_percent2 == .
replace Lev4_percent = string(Lev4_percent1, "%9.3f") if inlist(Lev4_percent, "*", "--") & Lev4_percent1 != . & Lev4_percent1 == Lev4_percent2
replace Lev4_percent = string(Lev4_percent1, "%9.3f") + "-" + string(Lev4_percent2, "%9.3f") if inlist(Lev4_percent, "*", "--") & Lev4_percent1 != . & Lev4_percent2 != . & Lev4_percent1 != Lev4_percent2

replace Lev1_percent1 = 1 - ProficientOrAbove_percent1 - Lev2_percent1 if Lev1_percent1 == . & ProficientOrAbove_percent1 != . & Lev2_percent1 != . & Lev2_percent2 == .
replace Lev1_percent1 = 1 - ProficientOrAbove_percent1 - Lev2_percent2 if Lev1_percent1 == . & ProficientOrAbove_percent1 != . & Lev2_percent2 != . & ProficientOrAbove_percent2 == .
replace Lev1_percent1 = 1 - ProficientOrAbove_percent2 - Lev2_percent2 if Lev1_percent1 == . & ProficientOrAbove_percent2 != . & Lev2_percent2 != .
replace Lev1_percent1 = 0 if Lev1_percent1 < 0 & Lev1_percent1 != .

replace Lev1_percent2 = 1 - ProficientOrAbove_percent2 - Lev2_percent1 if Lev1_percent2 == . & ProficientOrAbove_percent2 != . & Lev2_percent1 != .
replace Lev1_percent2 = 1 - ProficientOrAbove_percent1 - Lev2_percent1 if Lev1_percent2 == . & ProficientOrAbove_percent1 != . & Lev2_percent1 != . & ProficientOrAbove_percent2 == . & Lev2_percent2 != .
replace Lev1_percent2 = 0 if Lev1_percent2 < 0 & Lev1_percent2 != .

replace Lev1_percent = string(Lev1_percent1, "%9.3f") if inlist(Lev1_percent, "*", "--") & Lev1_percent1 != . & Lev1_percent2 == .
replace Lev1_percent = string(Lev1_percent1, "%9.3f") if inlist(Lev1_percent, "*", "--") & Lev1_percent1 != . & Lev1_percent1 == Lev1_percent2
replace Lev1_percent = string(Lev1_percent1, "%9.3f") + "-" + string(Lev1_percent2, "%9.3f") if inlist(Lev1_percent, "*", "--") & Lev1_percent1 != . & Lev1_percent2 != . & Lev1_percent1 != Lev1_percent2

replace Lev2_percent1 = 1 - ProficientOrAbove_percent1 - Lev1_percent1 if Lev2_percent1 == . & ProficientOrAbove_percent1 != . & Lev1_percent1 != . & Lev1_percent2 == .
replace Lev2_percent1 = 1 - ProficientOrAbove_percent1 - Lev1_percent2 if Lev2_percent1 == . & ProficientOrAbove_percent1 != . & Lev1_percent2 != . & ProficientOrAbove_percent1 == .
replace Lev2_percent1 = 1 - ProficientOrAbove_percent2 - Lev1_percent2 if Lev2_percent1 == . & ProficientOrAbove_percent2 != . & Lev1_percent2 != .
replace Lev2_percent1 = 0 if Lev2_percent1 < 0 & Lev2_percent1 != .

replace Lev2_percent2 = 1 - ProficientOrAbove_percent2 - Lev1_percent1 if Lev2_percent2 == . & ProficientOrAbove_percent2 != . & Lev1_percent1 != .
replace Lev2_percent2 = 1 - ProficientOrAbove_percent1 - Lev1_percent1 if Lev2_percent2 == . & ProficientOrAbove_percent1 != . & Lev1_percent1 != . & ProficientOrAbove_percent2 == . & Lev1_percent2 != .
replace Lev2_percent2 = 0 if Lev2_percent2 < 0 & Lev2_percent2 != .

replace Lev2_percent = string(Lev2_percent1, "%9.3f") if inlist(Lev2_percent, "*", "--") & Lev2_percent1 != . & Lev2_percent2 == .
replace Lev2_percent = string(Lev2_percent1, "%9.3f") if inlist(Lev2_percent, "*", "--") & Lev2_percent1 != . & Lev2_percent1 == Lev2_percent2
replace Lev2_percent = string(Lev2_percent1, "%9.3f") + "-" + string(Lev2_percent2, "%9.3f") if inlist(Lev2_percent, "*", "--") & Lev2_percent1 != . & Lev2_percent2 != . & Lev2_percent1 != Lev2_percent2

local level Lev1 Lev2 Lev3 Lev4 ProficientOrAbove 
foreach a of local level {
	replace `a'_percent = "0-0.05" if inlist(`a'_percent, "0.000-0.050", "0.0000-0.05000", "0-0.050", "0-0.0500")
	replace `a'_percent = "0.95-1" if inlist(`a'_percent, "0.950-1", "0.9500-1")
}

gen flag2 = 1 if Lev4_percent == "0-0.05" & strpos(ProficientOrAbove_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0
replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent), "%9.3f") if flag2 == 1 & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev3_percent))

gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen ProficientOrAbove_count = "--"
gen Lev5_count = ""
gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"

gen ParticipationRate2 = subinstr(ParticipationRate, "<", "", .)
replace ParticipationRate2 = subinstr(ParticipationRate2, ">", "", .)
destring ParticipationRate2, replace force
replace ParticipationRate2 = ParticipationRate2/100
tostring ParticipationRate2, replace force
replace ParticipationRate2 = "0-" + ParticipationRate2 if strpos(ParticipationRate, "<") > 0
replace ParticipationRate2 = ParticipationRate2 + "-1" if strpos(ParticipationRate, ">") > 0
replace ParticipationRate2 = "*" if ParticipationRate2 == "."
drop ParticipationRate max StudentSubGroup_TotalTested2
rename ParticipationRate2 ParticipationRate

gen AvgScaleScore = "--"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

gen State_leaid = "NV-" + StateAssignedDistID
replace State_leaid = "" if DataLevel == 1

replace State_leaid = "NV-18" if inlist(StateAssignedSchID, "101101", "102100", "105101", "106101", "107101", "108101") | inlist(StateAssignedSchID, "110100", "112100", "111100", "113100", "114100", "116100")
replace StateAssignedDistID = "18" if inlist(StateAssignedSchID, "101101", "102100", "105101", "106101", "107101", "108101") | inlist(StateAssignedSchID, "110100", "112100", "111100", "113100", "114100", "116100")

replace State_leaid = "NV-19" if StateAssignedSchID == "84406"
replace StateAssignedDistID = "19" if StateAssignedSchID == "84406"
replace State_leaid = "NV-18" if StateAssignedSchID == "115100"
replace StateAssignedDistID = "18" if StateAssignedSchID == "115100"

merge m:1 State_leaid using "${NCES_NV}/NCES_2022_District_NV.dta"

replace State_leaid = "NV-18" if _merge == 1 & DataLevel != 1
replace StateAssignedDistID = "18" if _merge == 1 & DataLevel != 1

drop if _merge == 2
drop _merge

merge m:1 State_leaid using "${NCES_NV}/NCES_2022_District_NV.dta", update

drop if _merge == 2
drop _merge

gen seasch = StateAssignedDistID + "-" + StateAssignedSchID
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCES_NV}/NCES_2022_School_NV.dta"
drop if _merge == 2
drop _merge

** New Schools 2024
replace NCESSchoolID = "320000100990" if StateAssignedSchID == "58430"
replace SchName = "Pinecrest Academy of Nevada Springs" if NCESSchoolID == "320000100990"
replace SchType = 1 if NCESSchoolID == "320000100990"
replace SchLevel = 1 if NCESSchoolID == "320000100990"
replace SchVirtual = 0 if NCESSchoolID == "320000100990"
replace NCESSchoolID = "320000100991" if StateAssignedSchID == "88101"
replace SchName = "Eagle Charter Schools of Nevada" if NCESSchoolID == "320000100991"
replace SchType = 1 if NCESSchoolID == "320000100991"
replace SchLevel = 1 if NCESSchoolID == "320000100991"
replace SchVirtual = 0 if NCESSchoolID == "320000100991"

replace SchLevel = 1 if NCESSchoolID == "320006000572"
replace SchVirtual = 0 if NCESSchoolID == "320006000572"
replace SchLevel = 4 if NCESSchoolID == "320006000923"
replace SchVirtual = 0 if NCESSchoolID == "320006000923"
replace SchLevel = 1 if NCESSchoolID == "320048000978"
replace SchVirtual = 0 if NCESSchoolID == "320048000978"
replace SchLevel = 1 if NCESSchoolID == "320048000979"
replace SchVirtual = 0 if NCESSchoolID == "320048000979"

** Cleaning up from NCES
replace StateAbbrev = "NV" if DataLevel == 1
replace State = "Nevada" if DataLevel == 1
replace StateFips = 32 if DataLevel == 1
replace CountyName = proper(CountyName)
replace DistName = proper(DistName)
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3
replace DistName = stritrim(DistName)
replace SchName = stritrim(SchName)

replace StateAssignedSchID = subinstr(StateAssignedSchID, "0", "", 1) if strpos(StateAssignedSchID, "0") == 1

** Generating new variables
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

// Reordering variables and sorting data
keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Non-Derivation Output*
save "${Output_ND}/NV_AssmtData_2024_ND", replace
export delimited "${Output_ND}/NV_AssmtData_2024_ND", replace
* END of Nevada 2024 Cleaning.do
****************************************************
