clear
set more off

global output "/Users/miramehta/Documents/CO State Testing Data/2023"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

cd "/Users/miramehta/Documents/CO State Testing Data"

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

append using "${output}/CO_AssmtData_2023_ELA_Migrant.dta"
append using "${output}/CO_AssmtData_2023_Math_Migrant.dta"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentSubGroup = Migrant if StudentGroup == "Migrant Status"
drop Migrant

append using "${output}/CO_AssmtData_2023_ELA_IEP.dta"
append using "${output}/CO_AssmtData_2023_Math_IEP.dta"
replace StudentGroup = "Disability Status" if StudentGroup == "IEP"
replace StudentSubGroup = IEPStatus if StudentGroup == "Disability Status"
drop IEPStatus

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

append using "${output}/CO_AssmtData_2023_Science_Migrant.dta"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentSubGroup = Migrant if StudentGroup == "Migrant Status"
drop Migrant

append using "${output}/CO_AssmtData_2023_Science_IEP.dta"
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

replace GradeLevel = "G" + GradeLevel

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

**** Updating 2023 schools

replace SchType = 1 if SchName == "Colorado Connections Academy"
replace NCESSchoolID = "080258006488" if SchName == "Colorado Connections Academy"

replace SchType = 1 if SchName == "Colorado Early Colleges Online Campus"
replace NCESSchoolID = "080002006867" if SchName == "Colorado Early Colleges Online Campus"

replace SchType = 1 if SchName == "Education reEnvisioned School"
replace NCESSchoolID = "080028206848" if SchName == "Education reEnvisioned School"

replace SchType = 1 if SchName == "Five Star Online Academy"
replace NCESSchoolID = "080690006850" if SchName == "Five Star Online Academy"

replace SchType = 1 if SchName == "Gudy Gaskill Elementary"
replace NCESSchoolID = "080531006854" if SchName == "Gudy Gaskill Elementary"

replace SchType = 1 if SchName == "JeffCo Remote Learning Program"
replace NCESSchoolID = "080480006852" if SchName == "JeffCo Remote Learning Program"

replace SchType = 1 if SchName == "Leadership Academy of Colorado"
replace NCESSchoolID = "080028206846" if SchName == "Leadership Academy of Colorado"

replace SchType = 1 if SchName == "Mapleton Online"
replace NCESSchoolID = "080555006860" if SchName == "Mapleton Online"

replace SchType = 1 if SchName == "Merit Academy"
replace NCESSchoolID = "080738006844" if SchName == "Merit Academy"

replace SchType = 1 if SchName == "Montbello Middle School"
replace NCESSchoolID = "080336006849" if SchName == "Montbello Middle School"

replace SchType = 1 if SchName == "Performing Arts School on Broadway"
replace NCESSchoolID = "080555006862" if SchName == "Performing Arts School on Broadway"

replace SchType = 1 if SchName == "Prospect Academy"
replace NCESSchoolID = "080002006853" if SchName == "Prospect Academy"

replace SchType = 1 if SchName == "Pueblo Classical Academy"
replace NCESSchoolID = "080615006841" if SchName == "Pueblo Classical Academy"

replace SchType = 1 if SchName == "Southlawn Elementary School"
replace NCESSchoolID = "080258006857" if SchName == "Southlawn Elementary School"

replace SchType = 1 if SchName == "Timnath Middle-High School"
replace NCESSchoolID = "080399006866" if SchName == "Timnath Middle-High School"

replace SchType = 1 if SchName == "Tointon Academy of Pre-Engineering"
replace NCESSchoolID = "080441006859" if SchName == "Tointon Academy of Pre-Engineering"

replace SchType = 1 if SchName == "Two Rivers Community School"
replace NCESSchoolID = "080426006635" if SchName == "Two Rivers Community School"

replace SchType = 1 if SchName == "Villa Bella Expeditionary Middle School"
replace NCESSchoolID = "080615006856" if SchName == "Villa Bella Expeditionary Middle School"

replace SchType = 1 if SchName == "Vision Charter Academy K-8"
replace NCESSchoolID = "080333006847" if SchName == "Vision Charter Academy K-8"

replace SchType = 1 if SchName == "Weld Re-3J Online Innovations"
replace NCESSchoolID = "080492006863" if SchName == "Weld Re-3J Online Innovations"

replace SchType = 1 if SchName == "Woodland Elementary School"
replace NCESSchoolID = "080291006865" if SchName == "Woodland Elementary School"

replace SchType = 1 if SchName == "World Academy Elementary School"
replace NCESSchoolID = "080354006868" if SchName == "World Academy Elementary School"

replace SchType = 1 if SchName == "World Academy Middle School"
replace NCESSchoolID = "080354006869" if SchName == "World Academy Middle School"


replace SchLevel = -1 if SchName == "Colorado Connections Academy" | SchName == "Colorado Early Colleges Online Campus" | SchName == "Education reEnvisioned School" | SchName == "Five Star Online Academy" | SchName == "Gudy Gaskill Elementary" | SchName == "JeffCo Remote Learning Program" |SchName == "Leadership Academy of Colorado" | SchName == "Mapleton Online" |SchName == "Merit Academy" | SchName == "Montbello Middle School" | SchName == "Performing Arts School on Broadway" | SchName == "Prospect Academy" | SchName == "Pueblo Classical Academy" | SchName == "Southlawn Elementary School" | SchName == "Timnath Middle-High School" | SchName == "Tointon Academy of Pre-Engineering" | SchName == "Two Rivers Community School" | SchName == "Villa Bella Expeditionary Middle School" | SchName == "Vision Charter Academy K-8" | SchName == "Weld Re-3J Online Innovations" | SchName == "Woodland Elementary School" | SchName == "World Academy Elementary School" | SchName == "World Academy Middle School"
replace SchVirtual = -1 if SchName == "Colorado Connections Academy" | SchName == "Colorado Early Colleges Online Campus" | SchName == "Education reEnvisioned School" | SchName == "Five Star Online Academy" | SchName == "Gudy Gaskill Elementary" | SchName == "JeffCo Remote Learning Program" |SchName == "Leadership Academy of Colorado" | SchName == "Mapleton Online" |SchName == "Merit Academy" | SchName == "Montbello Middle School" | SchName == "Performing Arts School on Broadway" | SchName == "Prospect Academy" | SchName == "Pueblo Classical Academy" | SchName == "Southlawn Elementary School" | SchName == "Timnath Middle-High School" | SchName == "Tointon Academy of Pre-Engineering" | SchName == "Two Rivers Community School" | SchName == "Villa Bella Expeditionary Middle School" | SchName == "Vision Charter Academy K-8" | SchName == "Weld Re-3J Online Innovations" | SchName == "Woodland Elementary School" | SchName == "World Academy Elementary School" | SchName == "World Academy Middle School"
label def SchLevel -1 "Missing/not reported"
label def SchVirtual -1 "Missing/not reported"

**

replace StateAbbrev = "CO" if DataLevel == 1
replace State = 8 if DataLevel == 1
replace StateFips = 8 if DataLevel == 1

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = ""
gen Flag_CutScoreChange_sci = "Y"

drop State_leaid seasch

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/CO_AssmtData_2023.dta", replace

export delimited using "${output}/CO_AssmtData_2023.csv", replace
