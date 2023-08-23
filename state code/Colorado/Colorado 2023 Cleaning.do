clear
set more off

global output "/Users/maggie/Desktop/Colorado/Output"
global NCES "/Users/maggie/Desktop/Colorado/NCES/Cleaned"

cd "/Users/maggie/Desktop/Colorado"

** Appending ela & math

use "${output}/CO_AssmtData_2023_ela_mat_allstudents.dta", clear
drop NumberofTotalRecords NumberofNoScores ParticipationRate2022 ParticipationRate2019 StandardDeviation AB AC Change20232022 AE
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
rename Content Subject
rename AA PercentMetorExceededExpectat
rename ParticipationRate2023 ParticipationRate

append using "${output}/CO_AssmtData_2023_ELA_Gender.dta"
append using "${output}/CO_AssmtData_2023_Math_Gender.dta"
replace StudentSubGroup = Gender if StudentGroup == "Gender"
drop Gender

append using "${output}/CO_AssmtData_2023_ELA_Race Ethnicity.dta"
append using "${output}/CO_AssmtData_2023_Math_Race Ethnicity.dta"
replace StudentGroup = "RaceEth" if StudentGroup == "Race Ethnicity"
replace StudentSubGroup = RaceEthnicity if StudentGroup == "RaceEth"
drop RaceEthnicity

append using "${output}/CO_AssmtData_2023_ELA_Free Reduced Lunch.dta"
append using "${output}/CO_AssmtData_2023_Math_Free Reduced Lunch.dta"
replace StudentSubGroup = FreeReducedLunchStatus if StudentGroup == "Economic Status"
drop FreeReducedLunchStatus

append using "${output}/CO_AssmtData_2023_ELA_Language Proficiency.dta"
append using "${output}/CO_AssmtData_2023_Math_Language Proficiency.dta"
replace StudentGroup = "EL Status" if StudentGroup == "Language Proficiency"
replace StudentSubGroup = LanguageProficiency if StudentGroup == "EL Status"
drop LanguageProficiency

replace Subject = "ela" if Subject == "English Language Arts" | Subject == "ELA"
replace Subject = "math" if Subject == "Mathematics" | Subject == "Math"
drop if Subject == "Spanish Language Arts"

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

save "${output}/CO_AssmtData_2023_ela_math.dta", replace

** Appending science

use "${output}/CO_AssmtData_2023_sci_allstudents.dta", replace
drop NumberofTotalRecords NumberofNoScores StandardDeviation W
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen Subject = "sci"
rename ParticpationRate ParticipationRate

append using "${output}/CO_AssmtData_2023_Science_Gender.dta"
replace StudentSubGroup = Gender if StudentGroup == "Gender"
drop Gender

append using "${output}/CO_AssmtData_2023_Science_Race Ethnicity.dta"
replace StudentGroup = "RaceEth" if StudentGroup == "Race Ethnicity"
replace StudentSubGroup = RaceEthnicity if StudentGroup == "RaceEth"
drop RaceEthnicity

append using "${output}/CO_AssmtData_2023_Science_Free Reduced Lunch.dta"
replace StudentSubGroup = FreeReducedLunchStatus if StudentGroup == "Economic Status"
drop FreeReducedLunchStatus

append using "${output}/CO_AssmtData_2023_Science_Language Proficiency.dta"
replace StudentGroup = "EL Status" if StudentGroup == "Language Proficiency"
replace StudentSubGroup = LanguageProficiency if StudentGroup == "EL Status"
drop LanguageProficiency

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

save "${output}/CO_AssmtData_2023_sci.dta", replace

** Appending all subjects

append using "${output}/CO_AssmtData_2023_ela_math.dta"

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
drop if GradeLevel == "All Grades" | GradeLevel == "11"
drop if StudentSubGroup == "NEP (Not English Proficient)" | StudentSubGroup == "LEP (Limited English Proficient)" | StudentSubGroup == "FEP (Fluent English Proficient), FELL (Former English Language Learner)" | StudentSubGroup == "PHLOTE, NA, Not Reported"

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

replace GradeLevel = "G" + GradeLevel

replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Proficiency: (NEP/LEP)"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "English Language Proficiency: (Not NEP/LEP)"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free/Reduced Lunch Eligible"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Free/Reduced Lunch Eligible"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaiian/Pacific Islander"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Not Reported"

replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "- -"
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested,",","",.)

local level 1 2 3 4 5

foreach a of local level {
	replace Lev`a'_count = "*" if Lev`a'_count == "- -"
	replace Lev`a'_count = subinstr(Lev`a'_count,",","",.)
	}
	
replace ProficientOrAbove_count = subinstr(ProficientOrAbove_count,",","",.)

replace AvgScaleScore = "*" if AvgScaleScore == "- -"

** Generating new variables

gen SchYear = "2022-23"

gen State_leaid = StateAssignedDistID
replace State_leaid = "CO-" + State_leaid if DataLevel != 1

gen seasch = StateAssignedSchID
replace seasch = StateAssignedDistID + "-" + seasch if DataLevel == 3

gen AssmtName = "CMAS"
gen AssmtType = "Regular"

gen StudentSubGroup_TotalTested2 = StudentSubGroup_TotalTested
destring StudentSubGroup_TotalTested2, replace force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort DistName SchName StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

** Converting Data to String

foreach a of local level {
	replace Lev`a'_percent = "-100" if Lev`a'_percent == "- -"
	destring Lev`a'_percent, replace force
	replace Lev`a'_percent = Lev`a'_percent/100
	tostring Lev`a'_percent, replace force
	replace Lev`a'_percent = "*" if Lev`a'_percent == "-1"
	replace Lev`a'_percent = "" if Lev`a'_percent == "."
	}
	
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "- -"

destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

destring ParticipationRate, replace force
replace ParticipationRate = ParticipationRate/100
tostring ParticipationRate, replace force
replace ParticipationRate = "*" if ParticipationRate == "."

** Merging with NCES

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta"

drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2021_School.dta"

drop if _merge == 2
drop _merge

replace StateAbbrev = "CO" if DataLevel == 1
replace State = 8 if DataLevel == 1
replace StateFips = 8 if DataLevel == 1

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/CO_AssmtData_2023.dta", replace

export delimited using "${output}/csv/CO_AssmtData_2023.csv", replace
