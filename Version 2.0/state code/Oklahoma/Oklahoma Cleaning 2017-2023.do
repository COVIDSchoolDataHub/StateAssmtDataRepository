clear
set more off

global raw "/Users/miramehta/Documents/Oklahoma/Original Data Files"
global output "/Users/miramehta/Documents/Oklahoma/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

foreach sub in Math Reading Science {
	use "${raw}/`sub' Performance.dta", clear
	merge 1:1 ReportYear EducationAgencyType countycode DistrictCode sitecode GradeLevel reportcategory using "${raw}/`sub' Participation.dta"
	drop if _merge == 2
	drop _merge
	if "`sub'" == "Math" {
		gen Subject = "math"
	}
	if "`sub'" == "Reading" {
		gen Subject = "ela"
	}
	if "`sub'" == "Science" {
		gen Subject = "sci"
	}
	save "${raw}/`sub'.dta", replace
}

use "${raw}/Math.dta"
append using "${raw}/Reading.dta"
append using "${raw}/Science.dta"

** Renaming variables

rename ReportYear SchYear
rename EducationAgencyType DataLevel
rename DistrictCode StateAssignedDistID
rename sitecode StateAssignedSchID
rename reportcategory StudentSubGroup
rename BelowBasic Lev1_count
rename Basic Lev2_count
rename Proficient Lev3_count
rename Advanced Lev4_count
rename ProficientorAbove ProficientOrAbove_count
rename Total StudentSubGroup_TotalTested
rename N ProficientOrAbove_percent

** Replacing variables

tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

gen prevyear = SchYear - 1
tostring SchYear, replace
tostring prevyear, replace
replace SchYear = prevyear + "-" + substr(SchYear, 3, 2)
drop prevyear

tostring countycode, replace
replace countycode = "0" + countycode if strlen(countycode) == 1
tostring StateAssignedSchID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECODIS"
replace StudentSubGroup = "Female" if StudentSubGroup == "F"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "FCS"
replace StudentSubGroup = "Homeless" if StudentSubGroup == "HOMELSENRL"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "Male" if StudentSubGroup == "M"
replace StudentSubGroup = "Asian" if StudentSubGroup == "MA"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "MAN"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "MB"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "MHL"
replace StudentSubGroup = "Military" if StudentSubGroup == "MILCNCTD"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "MM"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "MNP"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "MS"
replace StudentSubGroup = "White" if StudentSubGroup == "MW"
replace StudentSubGroup = "SWD" if StudentSubGroup == "WDIS"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"

gen AssmtName = "OSTP"
gen AssmtType = "Regular"

// Performance Information
gen Lev5_count = ""
gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"

foreach a of varlist Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count StudentSubGroup_TotalTested {
	replace `a' = "*" if `a' == "***"
	replace `a' = "0-" + subinstr(`a', "< ", "", .) if strpos(`a', "<") > 0
	destring `a', gen(`a'2) force
}

foreach a of varlist ProficientOrAbove_percent ParticipationRate {
	destring `a', gen(`a'2) force
	replace `a'2 = `a'2/100
}

replace ProficientOrAbove_percent2 = round(ProficientOrAbove_count2/StudentSubGroup_TotalTested2, 0.0001) if ProficientOrAbove_count2 != . & StudentSubGroup_TotalTested2 != .
replace ProficientOrAbove_count2 = round(ProficientOrAbove_percent2 * StudentSubGroup_TotalTested2) if ProficientOrAbove_percent2 != . & StudentSubGroup_TotalTested2 != .
tostring ProficientOrAbove_count2, replace force
replace ProficientOrAbove_count2 = ProficientOrAbove_count if ProficientOrAbove_count2 == "."
drop ProficientOrAbove_count
rename ProficientOrAbove_count2 ProficientOrAbove_count

** Deriving Additional Counts
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & Lev3_count != "*" & Lev4_count != "*"
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev1_count != "*" & Lev2_count != "*"

replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count)) if (strpos(Lev4_count, "-") > 0 | Lev4_count == "*") & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) >= 0
replace Lev4_count = "0" if (strpos(Lev4_count, "-") > 0 | Lev4_count == "*") & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) < 0
replace Lev4_count = "0" if Lev4_count == "--" & ProficientOrAbove_count == "0"

replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count)) if (strpos(Lev3_count, "-") > 0 | Lev3_count == "*") & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) >= 0
replace Lev3_count = "0" if (strpos(Lev3_count, "-") > 0 | Lev3_count == "*") & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) < 0
replace Lev3_count = string(real(ProficientOrAbove_count) - 3) + "-" + ProficientOrAbove_count if real(ProficientOrAbove_count) != . & Lev3_count == "*" & Lev4_count == "0-3"
replace Lev3_count = "0" if Lev3_count == "--" & ProficientOrAbove_percent == "0"

replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count)) if (strpos(Lev2_count, "-") > 0 | Lev2_count == "*") & strpos(Lev1_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev1_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count) >= 0
replace Lev2_count = "0" if (strpos(Lev2_count, "-") > 0 | Lev2_count == "*") & strpos(Lev1_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev1_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count) < 0

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count)) if (strpos(Lev1_count, "-") > 0 | Lev1_count == "*") & strpos(Lev2_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) >= 0
replace Lev1_count = "0" if (strpos(Lev1_count, "-") > 0 | Lev1_count == "*") & strpos(Lev2_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) < 0

** Level Percents
foreach a of numlist 1/4 {
	replace Lev`a'_count2 = 3 if Lev`a'_count == "0-3"
	replace Lev`a'_count2 = real(Lev`a'_count) if !missing(real(Lev`a'_count))
	gen Lev`a'_percent = round(Lev`a'_count2 / StudentSubGroup_TotalTested2, 0.0001)
	tostring Lev`a'_percent, replace format("%9.4g") force
	replace Lev`a'_percent = "*" if Lev`a'_percent == "."
	replace Lev`a'_percent = "0-" + Lev`a'_percent if Lev`a'_percent != "*" & Lev`a'_count == "0-3"
}
	
foreach a of varlist ProficientOrAbove_percent ParticipationRate {
	tostring `a'2, replace format("%9.4g") force
	replace `a'2 = "0-.05" if `a' == "< 5" & `a'2 == "."
	replace `a'2 = ".95-1" if `a' == "> 95" & `a'2 == "."
	replace `a'2 = "--" if `a' == ""
	drop `a'
	rename `a'2 `a'
}

forvalues n = 1/4 {
	replace Lev`n'_percent = "1" if Lev`n'_percent == "1.00e+00"
	replace Lev`n'_percent = "0" if strpos(Lev`n'_percent, "e") > 0
	replace Lev`n'_count = "0" if Lev`n'_percent == "0"
	replace Lev`n'_percent = "0" if Lev`n'_count == "0"
}

replace ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & Lev3_percent != "*" & Lev4_percent != "*"
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev1_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & Lev1_percent != "*" & Lev2_percent != "*"
replace ProficientOrAbove_percent = "1" if ProficientOrAbove_percent == "1.00e+00"
replace ProficientOrAbove_percent = "0" if strpos(ProficientOrAbove_percent, "e") > 0
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_count == "0"
replace ProficientOrAbove_count = "0" if ProficientOrAbove_percent == "0"

/*
replace Lev3_count = string(real(ProficientOrAbove_count) - 3) + "-" + ProficientOrAbove_count if real(ProficientOrAbove_count) != . & Lev3_count == "*" & Lev4_count == "0-3"
split Lev4_percent, parse("-")
replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent2)) + "-" + ProficientOrAbove_percent if real(ProficientOrAbove_percent) != . & Lev3_percent == "*" & Lev4_percent2 != ""
drop Lev4_percent1 Lev4_percent2
*/
** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

gen State_leaid = "OK-" + countycode + "-" + StateAssignedDistID
replace State_leaid = "" if DataLevel == 1

gen seasch = countycode + "-" + StateAssignedDistID + "-" + StateAssignedSchID
replace seasch = "" if DataLevel != 3

replace StateAssignedDistID = countycode + "-" + StateAssignedDistID
replace StateAssignedDistID = "" if DataLevel == 1

replace StateAssignedSchID = seasch
replace StateAssignedSchID = "" if DataLevel != 3

forvalues year = 2017/2023 {
	
	if `year' == 2020 {
		continue
	}
	
	local prevyear = `year' - 1
	
	preserve
	
	keep if strpos(SchYear, "`prevyear'") > 0
	
	merge m:1 State_leaid using "${NCES}/NCES_`prevyear'_District_OK.dta"

	drop if _merge == 2
	drop _merge
	
	merge m:1 seasch using "${NCES}/NCES_`prevyear'_School_OK.dta"

	drop if _merge == 2
	drop _merge
	
	if `year' != 2021 {
		merge 1:1 State_leaid seasch Subject GradeLevel StudentSubGroup using "${raw}/OK_AssmtData_`year'.dta"

		replace AvgScaleScore = "--" if _merge == 1

		drop if _merge == 2
		drop _merge
	}
	
	if `year' == 2021 {
		gen AvgScaleScore = "--"
	}
	
	replace StateAbbrev = "OK" if DataLevel == 1
	replace State = "Oklahoma" if DataLevel == 1
	replace StateFips = 40 if DataLevel == 1
	replace CountyName = proper(CountyName)
	replace CountyName = "McClain County" if CountyName == "Mcclain County"
	replace CountyName = "McCurtain County" if CountyName == "Mccurtain County"
	replace CountyName = "McIntosh County" if CountyName == "Mcintosh County"
	replace DistName = proper(DistName)
	replace DistName = "All Districts" if DataLevel == 1
	replace SchName = "All Schools" if DataLevel != 3
	
	gen Flag_AssmtNameChange = "N"
	gen Flag_CutScoreChange_ELA = "N"
	gen Flag_CutScoreChange_math = "N"
	gen Flag_CutScoreChange_sci = "N"
	gen Flag_CutScoreChange_soc = "Not applicable"
	
	if `year' == 2017 {
		replace Flag_AssmtNameChange = "Y"
		replace Flag_CutScoreChange_ELA = "Y"
		replace Flag_CutScoreChange_math = "Y"
	}
	
	if `year' == 2017 | `year' == 2023 {
		replace Flag_CutScoreChange_sci = "Y"
	}
	
	//StudentGroup_TotalTested & StudentSubGroup_TotalTested
	sort SchYear DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
	gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
	order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
	replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"
	
	replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == . | StudentGroup != "All Students"
	drop *2

	//Final Cleaning
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
	save "${output}/OK_AssmtData_`year'.dta", replace

	export delimited using "${output}/csv/OK_AssmtData_`year'.csv", replace
	
	restore
	
}
