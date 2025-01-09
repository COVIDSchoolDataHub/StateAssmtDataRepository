clear
set more off

global raw "/Users/miramehta/Documents/Virginia/Original Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global output "/Users/miramehta/Documents/Virginia/Output"

cd "/Users/miramehta/Documents"

////	Import original data - unhide on first run
/*
local levels "State District School"
foreach lev of local levels {
	import excel "$raw/2024/VA_OriginalData_2024_`lev'_Part1_New", firstrow clear
	save "$output/VA_OriginalData_2024_`lev'.dta", replace
	import excel "$raw/2024/VA_OriginalData_2024_`lev'_Part2_New", firstrow clear
	append using "$output/VA_OriginalData_2024_`lev'.dta"
	gen DataLevel = "`lev'"
	save "$output/VA_OriginalData_2024_`lev'.dta", replace
}

forvalues n = 3/8{
	import delimited "$raw/2024/VA_OriginalData_2024_District_AllStudents_Gr`n'_downloaded", case(preserve) stringcols (_all) clear
	gen DataLevel = "District"
	append using "$output/VA_OriginalData_2024_District.dta"
	save "$output/VA_OriginalData_2024_District.dta", replace
}
*/

use "$output/VA_OriginalData_2024_State.dta", clear
append using "$output/VA_OriginalData_2024_District.dta" "$output/VA_OriginalData_2024_School.dta"
duplicates drop

gen StudentSubGroup = "All Students"
replace StudentSubGroup = Race if !inlist(Race, "All Races", "")
replace StudentSubGroup = "Female" if Gender == "F"
replace StudentSubGroup = "Male" if Gender == "M"
replace StudentSubGroup = "Economically Disadvantaged" if Disadvantaged == "Y"
replace StudentSubGroup = "Not Economically Disadvantaged" if Disadvantaged == "N"
replace StudentSubGroup = "English Learner" if EnglishLearners == "Y"
replace StudentSubGroup = "EL and Monit or Recently Ex" if EnglishLearnersincludeFormer == "Y"
replace StudentSubGroup = "English Proficient" if EnglishLearners == "N"
replace StudentSubGroup = "Migrant" if Migrant == "Y"
replace StudentSubGroup = "Non-Migrant" if Migrant == "N"
replace StudentSubGroup = "Homeless" if Homeless == "Y"
replace StudentSubGroup = "Non-Homeless" if Homeless == "N"
replace StudentSubGroup = "Military" if Military == "Y"
replace StudentSubGroup = "Non-Military" if Military == "N"
replace StudentSubGroup = "Foster Care" if FosterCare == "Y"
replace StudentSubGroup = "Non-Foster Care" if FosterCare == "N"
replace StudentSubGroup = "SWD" if Disabled == "Y"
replace StudentSubGroup = "Non-SWD" if Disabled == "N"

replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black, not of Hispanic origin"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Non-Hispanic, two or more races"
replace StudentSubGroup = "White" if StudentSubGroup == "White, not of Hispanic origin"

gen StudentGroup = "All Students"
replace StudentGroup = "RaceEth" if !inlist(Race, "All Races", "")
replace StudentGroup = "Gender" if Gender != ""
replace StudentGroup = "Economic Status" if Disadvantaged != ""
replace StudentGroup = "EL Status" if EnglishLearners != ""
replace StudentGroup = "EL Status" if EnglishLearnersincludeFormer != ""
replace StudentGroup = "Migrant Status" if Migrant != ""
replace StudentGroup = "Homeless Enrolled Status" if Homeless != ""
replace StudentGroup = "Military Connected Status" if Military != ""
replace StudentGroup = "Foster Care Status" if FosterCare != ""
replace StudentGroup = "Disability Status" if Disabled != ""

drop Disadvantaged Race Gender EnglishLearners EnglishLearnersincludeFormer Migrant Homeless Military FosterCare Disabled

////	Prepare for NCES merge

destring DivisionNumber, gen(StateAssignedDistID)
replace DivisionNumber = "00" + DivisionNumber if StateAssignedDistID < 10
replace DivisionNumber = "0" + DivisionNumber if StateAssignedDistID >= 10 & StateAssignedDistID < 100
replace DivisionNumber = "VA-" + DivisionNumber
tostring StateAssignedDistID, replace
rename DivisionNumber State_leaid

replace StateAssignedDistID = "" if DataLevel == "State"
replace State_leaid = "" if DataLevel == "State"

destring SchoolNumber, gen(StateAssignedSchID)
replace SchoolNumber = State_leaid + "-" + State_leaid + "00" + SchoolNumber if StateAssignedSchID >= 10 & StateAssignedSchID < 100
replace SchoolNumber = State_leaid + "-" + State_leaid + "0" + SchoolNumber if StateAssignedSchID >= 100 & StateAssignedSchID < 1000
replace SchoolNumber = State_leaid + "-" + State_leaid + SchoolNumber if StateAssignedSchID >= 1000
replace SchoolNumber = subinstr(SchoolNumber, "VA-", "", .)
tostring StateAssignedSchID, replace
rename SchoolNumber seasch

replace StateAssignedSchID = "" if DataLevel != "School"
replace seasch = "" if DataLevel != "School"

merge m:1 State_leaid using "${NCES}/NCES_2022_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2022_School.dta"
drop if _merge == 2
drop _merge

////  Add Information for 2024 New Schools
replace SchVirtual = 0 if NCESSchoolID == "510114003102"
replace SchLevel = 4 if NCESSchoolID == "510159003123"
replace SchVirtual = 1 if NCESSchoolID == "510159003123"
replace SchLevel = 7 if NCESSchoolID == "510189003124"
replace SchVirtual = 0 if NCESSchoolID == "510189003124"
replace SchLevel = 1 if NCESSchoolID == "510313003125"
replace SchVirtual = 0 if NCESSchoolID == "510313003125"
replace SchLevel = 4 if NCESSchoolID == "510315003126"
replace SchVirtual = 1 if NCESSchoolID == "510315003126"
replace SchVirtual = 1 if NCESSchoolID == "510324003101"
replace SchLevel = 4 if NCESSchoolID == "510346003134"
replace SchVirtual = 1 if NCESSchoolID == "510346003134"

////  Rename, reorganize, standardize data
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

drop DivisionName SchName 
rename SchoolName SchName

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

rename SchoolYear SchYear
replace SchYear = "2023-24"

rename TestSource AssmtName
replace AssmtName = "Standards of Learning"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen AssmtType = "Regular"

replace Subject = "ela" if Subject == "English:Reading"
replace Subject = "wri" if Subject == "English:Writing"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

rename Grade GradeLevel
replace GradeLevel = "G0" + GradeLevel

replace TestLevel = subinstr(TestLevel, "Grade ", "G0", 1)
drop if GradeLevel != TestLevel & TestLevel != ""
drop TestLevel

rename TotalCount StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "<"
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, ",", "", .)
replace StudentSubGroup_TotalTested = strtrim(StudentSubGroup_TotalTested)

sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"

gen StudentSubGroup_TotalTested2 = StudentSubGroup_TotalTested
destring StudentSubGroup_TotalTested2, replace force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort State_leaid seasch StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
gen max = real(StudentGroup_TotalTested)
replace max = 0 if max == .

bysort State_leaid seasch GradeLevel Subject: egen RaceEth = total(StudentSubGroup_TotalTested2) if StudentGroup == "RaceEth"
bysort State_leaid seasch GradeLevel Subject: egen Econ = total(StudentSubGroup_TotalTested2) if StudentGroup == "Economic Status"
bysort State_leaid seasch GradeLevel Subject: egen Gender = total(StudentSubGroup_TotalTested2) if StudentGroup == "Gender"
bysort State_leaid seasch GradeLevel Subject: egen Migrant = total(StudentSubGroup_TotalTested2) if StudentGroup == "Migrant Status"
bysort State_leaid seasch GradeLevel Subject: egen Homeless = total(StudentSubGroup_TotalTested2) if StudentGroup == "Homeless Enrolled Status"
bysort State_leaid seasch GradeLevel Subject: egen Military = total(StudentSubGroup_TotalTested2) if StudentGroup == "Military Connected Status"
bysort State_leaid seasch GradeLevel Subject: egen Foster = total(StudentSubGroup_TotalTested2) if StudentGroup == "Foster Care Status"
bysort State_leaid seasch GradeLevel Subject: egen Disability = total(StudentSubGroup_TotalTested2) if StudentGroup == "Disability Status"

replace StudentSubGroup_TotalTested2 = max - RaceEth if StudentGroup == "RaceEth" & max != 0 & StudentSubGroup_TotalTested == "*" & RaceEth != 0
replace StudentSubGroup_TotalTested2 = max - Econ if StudentGroup == "Economic Status" & max != 0 & StudentSubGroup_TotalTested == "*" & Econ != 0
replace StudentSubGroup_TotalTested2 = max - Gender if StudentGroup == "Gender" & max != 0 & StudentSubGroup_TotalTested == "*" & Gender != 0
replace StudentSubGroup_TotalTested2 = max - Migrant if StudentGroup == "Migrant Status" & max != 0 & StudentSubGroup_TotalTested == "*" & Migrant != 0
replace StudentSubGroup_TotalTested2 = max - Homeless if StudentGroup == "Homeless Enrolled Status" & max != 0 & StudentSubGroup_TotalTested == "*" & Homeless != 0
replace StudentSubGroup_TotalTested2 = max - Military if StudentGroup == "Military Connected Status" & max != 0 & StudentSubGroup_TotalTested == "*" & Military != 0
replace StudentSubGroup_TotalTested2 = max - Foster if StudentGroup == "Foster Care Status" & max != 0 & StudentSubGroup_TotalTested == "*" & Foster != 0
replace StudentSubGroup_TotalTested2 = max - Disability if StudentGroup == "Disability Status" & max != 0 & StudentSubGroup_TotalTested == "*" & Disability != 0
replace StudentSubGroup_TotalTested = string(StudentSubGroup_TotalTested2) if StudentSubGroup_TotalTested2 != 0 & StudentSubGroup_TotalTested == "*"
drop RaceEth Econ Gender Migrant Homeless Military Foster Disability
drop if inlist(StudentSubGroup_TotalTested, "*", "0", "--") & StudentSubGroup != "All Students"

rename FailCount Lev1_count
rename FailRate Lev1_percent
rename PassProficientCount Lev2_count
rename PassProficientRate Lev2_percent
rename PassAdvancedCount Lev3_count
rename PassAdvancedRate Lev3_percent
gen Lev4_count = ""
gen Lev4_percent = ""
gen Lev5_count = ""
gen Lev5_percent = ""

replace Lev1_percent = "9999" if Lev1_percent == ">50"
replace Lev1_percent = "1111" if Lev1_percent == "<50"

local level 1 2 3

foreach a of local level{
	replace Lev`a'_count = strtrim(Lev`a'_count)
	replace Lev`a'_count = "*" if Lev`a'_count == "<"
	replace Lev`a'_count = subinstr(Lev`a'_count, ",", "", .)
	replace Lev`a'_percent = "." if Lev`a'_percent == "<"
	destring Lev`a'_percent, replace
	replace Lev`a'_percent = Lev`a'_percent/100
	tostring Lev`a'_percent, replace force
	replace Lev`a'_percent = "*" if Lev`a'_percent == "."
}

replace Lev1_percent = "0.5-1" if Lev1_percent == "99.99"
replace Lev1_percent = "0-0.5" if Lev1_percent == "11.11"
replace Lev1_count = "0-" + string(round(0.5 * real(StudentSubGroup_TotalTested))) if Lev1_percent == "0-0.5" & real(StudentSubGroup_TotalTested) != . & inlist(Lev1_count, "*", "--")
replace Lev1_count = string(round(0.5 * real(StudentSubGroup_TotalTested))) + "-" + StudentSubGroup_TotalTested if Lev1_percent == "0.5-1" & real(StudentSubGroup_TotalTested) != . & inlist(Lev1_count, "*", "--")

gen AvgScaleScore = "--"
gen ParticipationRate = "--"
gen ProficiencyCriteria = "Levels 2-3"

rename PassCount ProficientOrAbove_count
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "<"
replace ProficientOrAbove_count = subinstr(ProficientOrAbove_count, ",", "", .)

rename PassRate ProficientOrAbove_percent
replace ProficientOrAbove_percent = "9999" if ProficientOrAbove_percent == ">50"
replace ProficientOrAbove_percent = "1111" if ProficientOrAbove_percent == "<50"
destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace format("%9.2f") force
replace ProficientOrAbove_percent = "0.5-1" if ProficientOrAbove_percent == "99.99"
replace ProficientOrAbove_percent = "0-0.5" if ProficientOrAbove_percent == "11.11"
replace ProficientOrAbove_count = "0-" + string(round(0.5 * real(StudentSubGroup_TotalTested))) if ProficientOrAbove_percent == "0-0.5" & real(StudentSubGroup_TotalTested) != . & inlist(ProficientOrAbove_count, "*", "--")
replace ProficientOrAbove_count = string(round(0.5 * real(StudentSubGroup_TotalTested))) + "-" + StudentSubGroup_TotalTested if ProficientOrAbove_percent == "0.5-1" & real(StudentSubGroup_TotalTested) != . & inlist(ProficientOrAbove_count, "*", "--")

forvalues n = 1/3{
	replace Lev`n'_count = "1" if Lev`n'_count == "1-1"
}

replace ProficientOrAbove_count = "1" if ProficientOrAbove_count == "1-1"

replace ProficientOrAbove_count = strtrim(ProficientOrAbove_count)

replace State = "Virginia" if DataLevel == 1
replace StateAbbrev = "VA" if DataLevel == 1
replace StateFips = 51 if DataLevel == 1

replace SchName = strproper(SchName)
replace CountyName = strproper(CountyName)
replace CountyName = subinstr(CountyName, " Of ", " of ", 1)
replace CountyName = subinstr(CountyName, " And ", " and ", 1)

duplicates drop

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/VA_AssmtData_2024.dta", replace

export delimited using "${output}/csv/VA_AssmtData_2024.csv", replace
