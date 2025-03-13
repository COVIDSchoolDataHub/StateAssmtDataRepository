*******************************************************
* COLORADO

* File name: CO_2023
* Last update: 2/25/2025

*******************************************************
* Notes

	* This do file imports *.dta CO 2023 files created in Colorado DTA Conversion.do
	* It appends, renames, cleans it and merges with NCES 2022 data. 
	* The usual output is created.
*******************************************************
/////////////////////////////////////////
*** Setup ***

clear
*******************************************************
** Appending ela & math
*******************************************************

use "${Temp}/CO_AssmtData_2023_ela_mat_allstudents.dta", clear
drop NumberofTotalRecords NumberofNoScores ParticipationRate2022 ParticipationRate2019 StandardDeviation AB AC Change20232022 AE
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
rename Content Subject
rename AA PercentMetorExceededExpectat
rename ParticipationRate2023 ParticipationRate

append using "${Temp}/CO_AssmtData_2023_ELA_Gender.dta"
append using "${Temp}/CO_AssmtData_2023_Math_Gender.dta"
replace StudentSubGroup = Gender if StudentGroup == "Gender"
drop Gender

append using "${Temp}/CO_AssmtData_2023_ELA_Race Ethnicity.dta"
append using "${Temp}/CO_AssmtData_2023_Math_Race Ethnicity.dta"
replace StudentGroup = "RaceEth" if StudentGroup == "Race Ethnicity"
replace StudentSubGroup = RaceEthnicity if StudentGroup == "RaceEth"
drop RaceEthnicity

append using "${Temp}/CO_AssmtData_2023_ELA_Free Reduced Lunch.dta"
append using "${Temp}/CO_AssmtData_2023_Math_Free Reduced Lunch.dta"
replace StudentSubGroup = FreeReducedLunchStatus if StudentGroup == "Economic Status"
drop FreeReducedLunchStatus

append using "${Temp}/CO_AssmtData_2023_ELA_Language Proficiency.dta"
append using "${Temp}/CO_AssmtData_2023_Math_Language Proficiency.dta"
replace StudentGroup = "EL Status" if StudentGroup == "Language Proficiency"
replace StudentSubGroup = LanguageProficiency if StudentGroup == "EL Status"
drop LanguageProficiency

append using "${Temp}/CO_AssmtData_2023_ELA_Migrant.dta"
append using "${Temp}/CO_AssmtData_2023_Math_Migrant.dta"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentSubGroup = Migrant if StudentGroup == "Migrant Status"
drop Migrant

append using "${Temp}/CO_AssmtData_2023_ELA_IEP.dta"
append using "${Temp}/CO_AssmtData_2023_Math_IEP.dta"
replace StudentGroup = "Disability Status" if StudentGroup == "IEP"
replace StudentSubGroup = IEPStatus if StudentGroup == "Disability Status"
drop IEPStatus

replace Subject = "ela" if Subject == "English Language Arts" | Subject == "ELA"
replace Subject = "math" if Subject == "Mathematics" | Subject == "Math"
replace Subject = "esp" if Subject == "Spanish Language Arts"

rename NumberDidNotYetMeetExpectat Lev1_count
rename PercentDidNotYetMeetExpecta Lev1_percent
rename NumberPartiallyMetExpectation Lev2_count
rename PercentPartiallyMetExpectatio Lev2_percent
rename NumberApproachedExpectations Lev3_count
rename PercentApproachedExpectations Lev3_percent
rename NumberMetExpectations Lev4_count
rename PercentMetExpectations Lev4_percent
rename NumberExceededExpectations Lev5_count
rename PercentExceededExpectations Lev5_percent

gen ProficiencyCriteria = "Levels 4-5"

save "${Temp}/CO_AssmtData_2023_ela_math.dta", replace

*******************************************************
** Appending science
*******************************************************

use "${Temp}/CO_AssmtData_2023_sci_allstudents.dta", replace
drop NumberofTotalRecords NumberofNoScores StandardDeviation W
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen Subject = "sci"
rename ParticpationRate ParticipationRate

append using "${Temp}/CO_AssmtData_2023_Science_Gender.dta"
replace StudentSubGroup = Gender if StudentGroup == "Gender"
drop Gender

append using "${Temp}/CO_AssmtData_2023_Science_Race Ethnicity.dta"
replace StudentGroup = "RaceEth" if StudentGroup == "Race Ethnicity"
replace StudentSubGroup = RaceEthnicity if StudentGroup == "RaceEth"
drop RaceEthnicity

append using "${Temp}/CO_AssmtData_2023_Science_Free Reduced Lunch.dta"
replace StudentSubGroup = FreeReducedLunchStatus if StudentGroup == "Economic Status"
drop FreeReducedLunchStatus

append using "${Temp}/CO_AssmtData_2023_Science_Language Proficiency.dta"
replace StudentGroup = "EL Status" if StudentGroup == "Language Proficiency"
replace StudentSubGroup = LanguageProficiency if StudentGroup == "EL Status"
drop LanguageProficiency

append using "${Temp}/CO_AssmtData_2023_Science_Migrant.dta"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentSubGroup = Migrant if StudentGroup == "Migrant Status"
drop Migrant

append using "${Temp}/CO_AssmtData_2023_Science_IEP.dta"
replace StudentGroup = "Disability Status" if StudentGroup == "IEP"
replace StudentSubGroup = IEPStatus if StudentGroup == "Disability Status"
drop IEPStatus

replace Subject = "sci"

rename NumberPartiallyMetExpectation Lev1_count
rename PercentPartiallyMetExpectatio Lev1_percent
rename NumberApproachedExpectations Lev2_count
rename PercentApproachedExpectations Lev2_percent
rename NumberMetExpectations Lev3_count
rename PercentMetExpectations Lev3_percent
rename NumberExceededExpectations Lev4_count
rename PercentExceededExpectations Lev4_percent

gen ProficiencyCriteria = "Levels 3-4"

save "${Temp}/CO_AssmtData_2023_sci.dta", replace

*******************************************************
** Appending all subjects
*******************************************************
append using "${Temp}/CO_AssmtData_2023_ela_math.dta"

** Rename existing variables
rename Level DataLevel
rename DistrictCode StateAssignedDistID
rename DistrictName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName
rename Grade GradeLevel
rename NumberofValidScores StudentSubGroup_TotalTested
rename MeanScaleScore AvgScaleScore
rename NumberMetorExceededExpectati ProficientOrAbove_count
rename PercentMetorExceededExpectat ProficientOrAbove_percent

** Dropping entries
drop if DataLevel == ""
drop if GradeLevel == "11"
drop if StudentSubGroup == "NEP (Not English Proficient)" | StudentSubGroup == "LEP (Limited English Proficient)" | StudentSubGroup == "PHLOTE, NA, Not Reported"

** Changing DataLevel
replace DataLevel = proper(DataLevel)

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Replacing variables
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
replace SchName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

replace DistName = strtrim(DistName)
replace SchName = strtrim(SchName)

replace GradeLevel = "G38" if GradeLevel == "All Grades"
replace GradeLevel = "G" + GradeLevel if GradeLevel != "G38"

replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Proficiency: (NEP/LEP)"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "English Language Proficiency: (Not NEP/LEP)"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "FEP (Fluent English Proficient), FELL (Former English Language Learner)"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free/Reduced Lunch Eligible"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Free/Reduced Lunch Eligible"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaiian/Pacific Islander"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Not Reported"
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No IEP"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"

//StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = "0-15" if strpos(StudentSubGroup_TotalTested, "<16") !=0 | strpos(StudentSubGroup_TotalTested, "< 16") !=0
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)

** Student and Performance Counts & Percents
replace StudentSubGroup_TotalTested = "0-15" if StudentSubGroup_TotalTested == "- -"
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, ",", "", 1)

forvalues n = 1/5{
	replace Lev`n'_count = subinstr(Lev`n'_count, ",", "", 1)
	replace Lev`n'_count = strtrim(Lev`n'_count)
	destring Lev`n'_percent, replace force
	replace Lev`n'_percent = Lev`n'_percent/100
	tostring Lev`n'_percent, replace format("%9.3g") force
	replace Lev`n'_percent = "*" if Lev`n'_percent == "."
	replace Lev`n'_count = "*" if Lev`n'_count == "- -"
}

replace ProficientOrAbove_count = subinstr(ProficientOrAbove_count, ",", "", 1)
replace ProficientOrAbove_count = strtrim(ProficientOrAbove_count)
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace format("%9.3g") force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_count="*" if ProficientOrAbove_count=="- -"

//StudentGroup_TotalTested
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

//Deriving StudentSubGroup_TotalTested where suppressed
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup GradeLevel Subject DistName SchName)
replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & !missing(real(StudentGroup_TotalTested)) & real(StudentGroup_TotalTested) - UnsuppressedSG >=0 & UnsuppressedSG > 0 & StudentGroup != "RaceEth" & StudentSubGroup != "EL Exited"
drop Unsuppressed*

//Other Cleaning
replace Lev5_percent = "" if Subject == "sci"
replace Lev5_count = "" if Subject == "sci"
replace AvgScaleScore="*" if AvgScaleScore=="- -"
replace ParticipationRate="*" if ParticipationRate=="- -"
destring ParticipationRate, gen(part) force
replace part = part/100
tostring part, replace format (%9.3g) force
replace ParticipationRate = part if ParticipationRate != "*"

//Removing "Empty" Observations for Subgroups
drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"
gen AllPart = ParticipationRate if StudentSubGroup == "All Students"
replace AllPart = AllPart[_n-1] if missing(AllPart) & StudentSubGroup != "All Students"
gen flag = 1 if AllPart == "0" & StudentSubGroup != "All Students" & inlist(ProficientOrAbove_percent, "*", "--")
drop if flag == 1
drop AllPart flag

** Generating new variables
gen SchYear = "2022-23"

gen State_leaid = StateAssignedDistID
replace State_leaid = "CO-" + State_leaid if DataLevel != 1

gen seasch = StateAssignedSchID
replace seasch = StateAssignedDistID + "-" + seasch if DataLevel == 3

gen AssmtName = "Colorado Measures of Academic Success"
gen AssmtType = "Regular"

save "${Original_Cleaned}/CO_OriginalData_2023.dta", replace

*******************************************************
**Merging NCES Variables
*******************************************************
merge m:1 State_leaid using "${NCES_CO}/NCES_2022_District_CO.dta"

drop if _merge == 2
drop _merge 
drop supervisory_union_number boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment teachers_total_fte staff_total_fte FLAG state_mailing urban_centric_locale

merge m:1 State_leaid seasch using "${NCES_CO}/NCES_2022_School_CO"

drop if _merge == 2
drop _merge

**
replace StateAbbrev = "CO"
replace State = "Colorado"
replace StateFips = 8

** Generating new variables
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "Y"

*******************************************************
*Derivations [0 real changes made]
*******************************************************
replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent)* real(StudentSubGroup_TotalTested))) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_percent)) & missing(real(ProficientOrAbove_count))

** Standardize Names
replace DistName = strproper(DistName)
replace DistName = "McClave Re-2" if NCESDistrictID == "0805580"
replace DistName = "Weld Re-4" if NCESDistrictID == "0807350"
replace DistName = "Elizabeth School District" if NCESDistrictID == "0803720"

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

foreach var of varlist StudentGroup_TotalTested StudentSubGroup_TotalTested *_count *_percent {
	replace `var' = subinstr(`var', ",","",.)
	replace `var' = subinstr(`var', " ", "",.)
}

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
save "${Output}/CO_AssmtData_2023", replace
export delimited "${Output}/CO_AssmtData_2023", replace
* END of CO_2023.do
****************************************************
