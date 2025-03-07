*******************************************************
* MONTANA

* File name: 04_MT_State_Cleaning
* Last update: 03/06/2025

*******************************************************
* Notes

	* This do file cleans MT state level data (for all subgroups).
	
*******************************************************

clear all
set more off
set trace off

//Importing and Combining
tempfile temp1
save "`temp1'", replace emptyok
foreach Subject in "ELA" "Math" "Sci" {
	foreach Grade in "3" "4" "5" "6" "7" "8" "38" {
		if "`Subject'" == "Sci" & !inlist("`Grade'", "5", "8", "38") continue
		foreach sg in All_Students American_Indian_Or_Alaskan_Native Asian Black_or_African_American Economically_Disadvantaged EL EL_Monit_or_Recently_Ex Female Hispanic Homeless Male Migrant Multi-Racial Native_Hawaiian_or_Other_Pacific_Islander Non-Homeless Non-Migrant Non-SWD NonEL Not_Economically_Disadvantaged SWD White {
		import excel "${Original}/State-level downloads/MT_State_`Subject'_G`Grade'_`sg'.xlsx", firstrow cellrange(A3) case(preserve) clear
		cap rename NearingProficiencyStudents NearingProficientStudents
		drop if SchoolYear == "2019-2020"
		foreach var of varlist *Percent *Students {
			destring `var', replace i(*)
		}

	gen Subject = strlower("`Subject'")
	gen GradeLevel = "G0`Grade'"
	replace GradeLevel = "G38" if "`Grade'" == "38"
	gen StudentSubGroup = "`sg'"
	append using "`temp1'"
	save "`temp1'", replace
	clear
		}
	}
}
use "`temp1'"
save "${Original}/Combined", replace

clear all
tempfile temp2
save "`temp2'", replace emptyok
foreach Subject in "ELA" "Math" "Sci" {
	foreach Grade in "3" "4" "5" "6" "7" "8" "38" {
		if "`Subject'" == "Sci" & !inlist("`Grade'", "5", "8", "38") continue
		foreach sg in All_Students American_Indian_Or_Alaskan_Native Asian Black_or_African_American Economically_Disadvantaged EL EL_Monit_or_Recently_Ex Female Hispanic Homeless Male Migrant Multi-Racial Native_Hawaiian_or_Other_Pacific_Islander Non-Homeless Non-Migrant Non-SWD NonEL Not_Economically_Disadvantaged SWD White {
		import excel "${Original}/State-level downloads/MT_State_`Subject'_G`Grade'_`sg'_Participation.xlsx", firstrow cellrange(A3) case(preserve) clear
		drop if SchoolYear == "2019-2020"
		if "`Subject'" != "Sci" tostring StudentsNotTested, replace
		cap rename NumberAssessed StudentsTested
		cap drop TotalCount
		cap destring StudentsTested, replace i(*)
		
	gen Subject = strlower("`Subject'")
	gen GradeLevel = "G0`Grade'"
	replace GradeLevel = "G38" if "`Grade'" == "38"
	gen StudentSubGroup = "`sg'"
	append using "`temp2'"
	save "`temp2'", replace
	clear
		}
	}
}
use "`temp2'"
save "${Original}/Combined_Participation", replace

use "${Original}/Combined", clear
merge 1:1 SchoolYear Subject GradeLevel StudentSubGroup using "${Original}/Combined_Participation"
drop if _merge == 2
drop _merge

//Renaming
rename SchoolYear SchYear
rename AdvancedStudents Lev4_count
rename AdvancedPercent Lev4_percent
rename ProficientStudents Lev3_count
rename ProficientPercent Lev3_percent
rename NearingProficientStudents Lev2_count
rename NearingProficientPercent Lev2_percent
rename NovicePercent Lev1_percent
rename NoviceStudents Lev1_count
rename PercentAssessed ParticipationRate
rename StudentsTested StudentSubGroup_TotalTested

//StudentSubGroup & StudentGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "_", " ",.)
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "Indian") !=0
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Racial") !=0
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "NonEL"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Male", "Female")
replace StudentGroup = "Disability Status" if strpos(StudentSubGroup, "SWD") != 0
replace StudentGroup = "Economic Status" if strpos(StudentSubGroup, "Economically") != 0
replace StudentGroup = "EL Status" if strpos(StudentSubGroup, "English") != 0 | strpos(StudentSubGroup, "EL") != 0
replace StudentGroup = "Homeless Enrolled Status" if strpos(StudentSubGroup, "Homeless") != 0
replace StudentGroup = "Migrant Status" if strpos(StudentSubGroup, "Migrant") != 0

//Correcting Importing Error
foreach var of varlist Lev*_count Lev*_percent StudentSubGroup_TotalTested ParticipationRate {
	replace `var' = . if `var' == 0
}

//Deriving Additional Information
replace Lev4_percent = 1 - Lev1_percent - Lev2_percent - Lev3_percent if Lev4_percent == . & Lev1_percent != . & Lev2_percent != . & Lev3_percent != .
replace Lev4_count = StudentSubGroup_TotalTested - Lev1_count - Lev2_count - Lev3_count if Lev4_count == . & Lev1_count != . & Lev2_count != . & Lev3_count != . & StudentSubGroup_TotalTested != .
replace Lev4_percent = 0 if Lev4_count == 0

replace Lev3_percent = 1 - Lev1_percent - Lev2_percent - Lev4_percent if Lev3_percent == . & Lev1_percent != . & Lev2_percent != . & Lev4_percent != .
replace Lev3_count = StudentSubGroup_TotalTested - Lev1_count - Lev2_count - Lev4_count if Lev3_count == . & Lev1_count != . & Lev2_count != . & Lev4_count != . & StudentSubGroup_TotalTested != .
replace Lev3_percent = 0 if Lev3_count == 0

replace Lev2_percent = 1 - Lev1_percent - Lev3_percent - Lev4_percent if Lev2_percent == . & Lev1_percent != . & Lev3_percent != . & Lev4_percent != .
replace Lev2_count = StudentSubGroup_TotalTested - Lev1_count - Lev3_count - Lev4_count if Lev2_count == . & Lev1_count != . & Lev3_count != . & Lev4_count != . & StudentSubGroup_TotalTested != .
replace Lev2_percent = 0 if Lev2_count == 0

replace Lev1_percent = 1 - Lev2_percent - Lev3_percent - Lev4_percent if Lev1_percent == . & Lev2_percent != . & Lev3_percent != . & Lev4_percent != .
replace Lev1_count = StudentSubGroup_TotalTested - Lev2_count - Lev3_count - Lev4_count if Lev1_count == . & Lev2_count != . & Lev3_count != . & Lev4_count != . & StudentSubGroup_TotalTested != .
replace Lev1_percent = 0 if Lev1_count == 0

forvalues n = 1/4{
	replace Lev`n'_percent = 0 if Lev`n'_percent < 0 //confirmed that these are all very very small decimals
}

gen ProficientOrAbove_count = Lev3_count + Lev4_count
replace ProficientOrAbove_count = StudentSubGroup_TotalTested - Lev1_count - Lev2_count if ProficientOrAbove_count == .
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
replace ProficientOrAbove_percent = 1 - Lev1_percent - Lev2_percent if ProficientOrAbove_percent == .

foreach lev in Lev1 Lev2 Lev3 Lev4 ProficientOrAbove {
	tostring `lev'_count, replace
	tostring `lev'_percent, replace format("%9.4g") force
	replace `lev'_count = "*" if `lev'_count == "."
	replace `lev'_percent = "*" if `lev'_percent == "."
	replace `lev'_percent = "0" if `lev'_percent == "0.0000"
}

gen Lev5_percent = ""
gen Lev5_count = ""
gen AvgScaleScore = "--"

//ParticipationRate
tostring ParticipationRate, replace format("%9.4g") force
replace ParticipationRate = "1" if ParticipationRate == "1.0000"

//SchYear
replace SchYear = substr(SchYear, 1, 5) + substr(SchYear, 8, 2)

//Indicator Variables
gen DataLevel = "State"
gen DistName = "All Districts"
gen SchName = "All Schools"
gen AssmtName = "Smarter Balanced Assessment"
replace AssmtName = "Montana Science Assessment" if Subject == "sci"
gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "N"
replace Flag_AssmtNameChange = "Y" if Subject == "sci" & SchYear == "2021-22"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "Not applicable"
replace Flag_CutScoreChange_sci = "Y" if SchYear == "2021-22"
replace Flag_CutScoreChange_sci = "N" if inlist(SchYear, "2022-23", "2023-24")
gen State = "Montana"
gen StateFips = 30
gen StateAbbrev = "MT"

//Empty Variables
gen DistType = ""
gen SchType = ""
gen NCESDistrictID = ""
gen StateAssignedDistID = ""
gen NCESSchoolID = ""
gen StateAssignedSchID = ""
gen DistCharter = ""
gen SchLevel = ""
gen SchVirtual = ""
gen CountyName = ""
gen CountyCode =""
gen DistLocale = ""

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//StudentSubGroup_TotalTested & StudentGroup_TotalTested
tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."
drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"

sort SchYear DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"

//Separating by Year & Saving
forvalues year = 2016/2024 {
	if `year' == 2020 continue
	preserve
	keep if "`year'" == substr(SchYear,1,2) + substr(SchYear, -2,2)
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	append using "${Output}/MT_AssmtData_`year'_District"
	if !inlist(`year', 2021, 2024) append using "${Output}/MT_AssmtData_`year'_School"
	
	//Variable Clean-up
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	save "${Output}/MT_AssmtData_`year'.dta", replace
	export delimited "${Output}/MT_AssmtData_`year'.csv", replace
	restore
}






