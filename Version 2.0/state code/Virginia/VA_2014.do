clear
set more off

global raw "/Users/maggie/Desktop/Virginia/Original Data"
global NCES "/Users/maggie/Desktop/Virginia/NCES/Cleaned"
global output "/Users/maggie/Desktop/Virginia/Output"

cd "/Users/maggie/Desktop/Virginia"


////	Import aggregate data from 2006-2022

import delimited "/${raw}/VA_OriginalData_2006-2022_all.csv", varnames(1) clear 

drop if schoolyear != "2013-2014"

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

save "${output}/VA_2014_base.dta", replace


////	Import disaggregate gender data

import delimited "/${raw}/Disaggregate/VA_OriginalData_2014_all_gender.csv", varnames(1) clear 

rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${output}/VA_2014_gender.dta", replace


////	Import disaggregate language proficiency data

import delimited "/${raw}/Disaggregate/VA_OriginalData_2014_all_language.csv", varnames(1) clear 

rename englishlearners StudentSubGroup
gen StudentGroup = "EL Status"

save "${output}/VA_2014_language.dta", replace


////	Import disaggregate race data

import delimited "/${raw}/Disaggregate/VA_OriginalData_2014_all_race.csv", varnames(1) clear 

rename race StudentSubGroup
gen StudentGroup = "RaceEth"

save "${output}/VA_2014_race.dta", replace


//// Import disaggregate economic status data

import delimited "/${raw}/Disaggregate/VA_OriginalData_2014_all_econ.csv", varnames(1) clear

rename disadvantaged StudentSubGroup
gen StudentGroup = "Economic Status"

tostring divisionnumber, replace
replace divisionnumber = "" if divisionnumber == "."
tostring schoolnumber, replace
replace schoolnumber = "" if schoolnumber == "."
tostring averagesolscaledscore, replace
replace averagesolscaledscore = "" if averagesolscaledscore == "."

save "${output}/VA_2014_econ.dta", replace


//// Import disaggregate migrant status data

import delimited "/${raw}/Disaggregate/VA_OriginalData_2014_all_migrant.csv", varnames(1) clear

rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"

tostring divisionnumber, replace
replace divisionnumber = "" if divisionnumber == "."
tostring schoolnumber, replace
replace schoolnumber = "" if schoolnumber == "."
tostring averagesolscaledscore, replace
replace averagesolscaledscore = "" if averagesolscaledscore == "."

save "${output}/VA_2014_migrant.dta", replace


////	Append aggregate and disaggregate 

use "${output}/VA_2014_base.dta", clear

append using "${output}/VA_2014_gender.dta"
append using "${output}/VA_2014_language.dta"
append using "${output}/VA_2014_race.dta"
append using "${output}/VA_2014_econ.dta"
append using "${output}/VA_2014_migrant.dta"


////	Prepare for NCES merge

destring divisionnumber, gen(StateAssignedDistID)
replace divisionnumber = "00" + divisionnumber if StateAssignedDistID < 10
replace divisionnumber = "0" + divisionnumber if StateAssignedDistID >= 10 & StateAssignedDistID < 100
tostring StateAssignedDistID, replace
rename divisionnumber State_leaid

replace StateAssignedDistID = "" if level == "State"
replace State_leaid = "" if level == "State"

tostring schoolnumber, replace
destring schoolnumber, gen(StateAssignedSchID)
replace schoolnumber = State_leaid + "000" + schoolnumber if StateAssignedSchID < 10
replace schoolnumber = State_leaid + "00" + schoolnumber if StateAssignedSchID >= 10 & StateAssignedSchID < 100
replace schoolnumber = State_leaid + "0" + schoolnumber if StateAssignedSchID >= 100 & StateAssignedSchID < 1000
replace schoolnumber = State_leaid + schoolnumber if StateAssignedSchID >= 1000
tostring StateAssignedSchID, replace
rename schoolnumber seasch

replace StateAssignedSchID = "" if level != "School"
replace seasch = "" if level != "School"

merge m:1 State_leaid using "/${NCES}/NCES_2013_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "/${NCES}/NCES_2013_School.dta"
drop if _merge == 2
drop _merge


////  Rename, reorganize, standardize data

rename level DataLevel
replace DataLevel = "District" if DataLevel == "Division"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

drop divisionname schoolname

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

rename schoolyear SchYear
replace SchYear = "2013-14"

rename testsource AssmtName
replace AssmtName = "Standards of Learning"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"
gen AssmtType = "Regular"

rename subject Subject
replace Subject = "ela" if Subject == "English:Reading"
replace Subject = "wri" if Subject == "English:Writing"
replace Subject = "soc" if Subject == "History and Social Science"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

rename testlevel GradeLevel
replace GradeLevel = subinstr(GradeLevel,"Grade ","",.)
replace GradeLevel = "G0" + GradeLevel

replace StudentSubGroup = "Male" if StudentSubGroup == "M"
replace StudentSubGroup = "Female" if StudentSubGroup == "F"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Y" & StudentGroup == "EL Status"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "N" & StudentGroup == "EL Status"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black, not of Hispanic origin"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian  or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White, not of Hispanic origin"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Unknown - Race/Ethnicity not provided"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Non-Hispanic, two or more races"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Y" & StudentGroup == "Economic Status"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "N" & StudentGroup == "Economic Status"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Y" & StudentGroup == "Migrant Status"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "N" & StudentGroup == "Migrant Status"

rename totalcount StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = strtrim(StudentSubGroup_TotalTested)
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "<"
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, ",", "", .)

gen StudentSubGroup_TotalTested2 = StudentSubGroup_TotalTested
destring StudentSubGroup_TotalTested2, replace force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort State_leaid seasch StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort State_leaid seasch GradeLevel Subject: egen max = max(StudentSubGroup_TotalTested2)
bysort State_leaid seasch StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
replace StudentGroup_TotalTested = max if !inlist(max, ., 0) & StudentGroup_TotalTested == .
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

bysort State_leaid seasch GradeLevel Subject: egen Econ = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Economic Status"
bysort State_leaid seasch GradeLevel Subject: egen EL = sum(StudentSubGroup_TotalTested2) if StudentGroup == "EL Status"
bysort State_leaid seasch GradeLevel Subject: egen Gender = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Gender"
bysort State_leaid seasch GradeLevel Subject: egen Migrant = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Migrant Status"
replace StudentSubGroup_TotalTested2 = max - Econ if StudentSubGroup == "Not Economically Disadvantaged" & max != 0 & StudentSubGroup_TotalTested == "*" & Econ != 0
replace StudentSubGroup_TotalTested2 = max - Econ if StudentSubGroup == "Economically Disadvantaged" & max != 0 & StudentSubGroup_TotalTested == "*" & Econ != 0
replace StudentSubGroup_TotalTested2 = max - EL if StudentSubGroup == "English Proficient" & max != 0 & StudentSubGroup_TotalTested == "*" & EL != 0
replace StudentSubGroup_TotalTested2 = max - EL if StudentSubGroup == "English Learner" & max != 0 & StudentSubGroup_TotalTested == "*" & EL != 0
replace StudentSubGroup_TotalTested2 = max - Gender if StudentSubGroup == "Male" & max != 0 & StudentSubGroup_TotalTested == "*" & Gender != 0
replace StudentSubGroup_TotalTested2 = max - Gender if StudentSubGroup == "Female" & max != 0 & StudentSubGroup_TotalTested == "*" & Gender != 0
replace StudentSubGroup_TotalTested2 = max - Migrant if StudentSubGroup == "Non-Migrant" & max != 0 & StudentSubGroup_TotalTested == "*" & Migrant != 0
replace StudentSubGroup_TotalTested2 = max - Migrant if StudentSubGroup == "Migrant" & max != 0 & StudentSubGroup_TotalTested == "*" & Migrant != 0
replace StudentSubGroup_TotalTested = string(StudentSubGroup_TotalTested2) if StudentSubGroup_TotalTested2 != 0

rename failcount Lev1_count
rename failrate Lev1_percent
rename passproficientcount Lev2_count
rename passproficientrate Lev2_percent
rename passadvancedcount Lev3_count
rename passadvancedrate Lev3_percent
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

rename averagesolscaledscore AvgScaleScore
replace AvgScaleScore = "*" if AvgScaleScore == " " | AvgScaleScore == ""

gen ProficiencyCriteria = "Levels 2-3"

rename passcount ProficientOrAbove_count
replace ProficientOrAbove_count = strtrim(ProficientOrAbove_count)
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "<"
replace ProficientOrAbove_count = subinstr(ProficientOrAbove_count, ",", "", .)

rename passrate ProficientOrAbove_percent
replace ProficientOrAbove_percent = "9999" if ProficientOrAbove_percent == ">50"
replace ProficientOrAbove_percent = "1111" if ProficientOrAbove_percent == "<50"
destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "0.5-1" if ProficientOrAbove_percent == "99.99"
replace ProficientOrAbove_percent = "0-0.5" if ProficientOrAbove_percent == "11.11"

gen ParticipationRate = "--"

replace State = "Virginia" if DataLevel == 1
replace StateAbbrev = "VA" if DataLevel == 1
replace StateFips = 51 if DataLevel == 1
replace CountyName = proper(CountyName)
replace DistName = proper(DistName)

merge m:1 SchYear CountyCode using "/${raw}/va_county-list_through2023.dta"
replace CountyName = newcountyname
drop if _merge == 2
drop _merge

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/VA_AssmtData_2014.dta", replace

export delimited using "${output}/csv/VA_AssmtData_2014.csv", replace