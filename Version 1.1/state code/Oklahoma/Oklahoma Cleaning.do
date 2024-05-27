clear
set more off

global raw "/Users/maggie/Desktop/Oklahoma/Original Data Files"
global output "/Users/maggie/Desktop/Oklahoma/Output"
global NCES "/Users/maggie/Desktop/Oklahoma/NCES/Cleaned"

cd "/Users/maggie/Desktop/Oklahoma"

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


foreach a of varlist Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count StudentSubGroup_TotalTested {
	replace `a' = "*" if `a' == "***"
	replace `a' = "0-" + subinstr(`a', "< ", "", .) if strpos(`a', "<") > 0
}

gen AssmtName = "OSTP"
gen AssmtType = "Regular"

gen Lev5_count = ""
gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"

foreach a of varlist Lev1_count Lev2_count Lev3_count Lev4_count StudentSubGroup_TotalTested {
	destring `a', gen(`a'2) force
}

foreach a of numlist 1/4 {
	replace Lev`a'_count2 = 3 if Lev`a'_count == "0-3"
	gen Lev`a'_percent = round(Lev`a'_count2 / StudentSubGroup_TotalTested2, 0.01)
	tostring Lev`a'_percent, replace format("%9.2g") force
	replace Lev`a'_percent = "*" if Lev`a'_percent == "."
	replace Lev`a'_percent = "0-" + Lev`a'_percent if Lev`a'_percent != "*" & Lev`a'_count == "0-3"
}

foreach a of varlist ProficientOrAbove_percent ParticipationRate {
	destring `a', gen(`a'2) force
	replace `a'2 = `a'2/100
	tostring `a'2, replace format("%9.2g") force
	replace `a'2 = "0-.05" if `a' == "< 5"
	replace `a'2 = ".95-1" if `a' == "> 95"
	replace `a'2 = "--" if `a' == ""
	drop `a'
	rename `a'2 `a'
}

replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort countycode StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen test = max(StudentSubGroup_TotalTested2)
bysort countycode StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen StudentGroup_TotalTested = max(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

drop *2

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
	
	merge m:1 State_leaid using "${NCES}/NCES_`prevyear'_District.dta"

	drop if _merge == 2
	drop _merge
	
	merge m:1 seasch using "${NCES}/NCES_`prevyear'_School.dta"

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

	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
	save "${output}/OK_AssmtData_`year'.dta", replace

	export delimited using "${output}/csv/OK_AssmtData_`year'.csv", replace
	
	restore
	
}
