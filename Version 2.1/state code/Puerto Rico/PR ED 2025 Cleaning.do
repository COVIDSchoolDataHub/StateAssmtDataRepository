clear
set more off
set trace off
global Original "/Users/miramehta/Documents/Puerto Rico/Original Data"
global Output "/Users/miramehta/Documents/Puerto Rico/Output"

//Import Data - Unhide on First Run
/*
clear all
tempfile temp1
save "`temp1'", emptyok

forvalues year = 2022/2024{
	forvalues n = 3/8{
	import excel "$Original/`year'/PR_OriginalData_`year'_State_G0`n'.xlsx", clear firstrow case(preserve)
	gen GradeLevel = "G0`n'"
	append using "`temp1'"
	save "`temp1'", replace
	}
}
save "$Original/PR_Combined.dta", replace
*/

//Rename Variables & Values to Reshape
use "$Original/PR_Combined.dta", clear

replace PartitionKey = substr(PartitionKey, 2, strlen(PartitionKey)-2)
replace ProficiencyLevel = substr(ProficiencyLevel, 2, strlen(ProficiencyLevel)-2)
replace ProficiencyLevel = "PreBasic" if ProficiencyLevel == "Beginner"
replace ProficiencyLevel = "Basic" if ProficiencyLevel == "Apprentice"
replace ProficiencyLevel = "Advanced" if ProficiencyLevel == "Distinguished"

rename PartitionKey DataLevel
rename NOTEconomicallyDisadvantaged NonEconDis //for varname length issues

local varlist All Disabilities EconomicallyDisadvantaged Female FosterCare HispanicNOTPuertoRican Homeless Male Migrants MilitaryParent NOTDisabilities NonEconDis OtherOrigin PuertoRican Section504 SpanishLearners WhiteNOTHispanic
foreach var of local varlist{
	rename `var' Count`var'
}

//Reshape
reshape long Count, i(AcademicYear Subject GradeLevel ProficiencyLevel) j(StudentSubGroup) string
reshape wide Count, i(AcademicYear Subject GradeLevel StudentSubGroup) j(ProficiencyLevel) string

rename CountPreBasic Lev1_count
rename CountBasic Lev2_count
rename CountProficient Lev3_count
rename CountAdvanced Lev4_count

//Subject
replace Subject = substr(Subject, 2, strlen(Subject)-2)
replace Subject = "ela" if Subject == "INGL"
replace Subject = "math" if Subject == "MATE"
replace Subject = "sci" if Subject == "CIEN"
replace Subject = "esp" if Subject == "ESPA"

drop if Subject == "sci" & !inlist(GradeLevel, "G04", "G08") //only grades that take this exam

//StudentSubGroup
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "EconomicallyDisadvantaged"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "FosterCare"
replace StudentSubGroup = "Military" if StudentSubGroup == "MilitaryParent"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "NOTDisabilities"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NonEconDis"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Disabilities"

//StudentGroup
gen StudentGroup = "All Students"
replace StudentGroup = "Disability Status" if strpos(StudentSubGroup, "SWD") != 0
replace StudentGroup = "Economic Status" if strpos(StudentSubGroup, "Economically") != 0
replace StudentGroup = "Foster Care Status" if strpos(StudentSubGroup, "Foster Care") != 0
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
replace StudentGroup = "Homeless Enrolled Status" if strpos(StudentSubGroup, "Homeless") != 0
replace StudentGroup = "Migrant Status" if strpos(StudentSubGroup, "Migrant") != 0
replace StudentGroup = "Military Connected Status" if strpos(StudentSubGroup, "Military") != 0
*replace StudentGroup = "RaceEth" if 

//Limit to only ED relevant information
keep if StudentSubGroup == "All Students"
keep if inlist(Subject, "ela", "math")

//Performance Information
forvalues n = 1/4{
	destring Lev`n'_count, gen(Lev`n')
}

gen SSGTT = Lev1 + Lev2 + Lev3 + Lev4
tostring SSGTT, gen(StudentSubGroup_TotalTested)
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

gen ProficientOrAbove = Lev3 + Lev4
tostring ProficientOrAbove, gen(ProficientOrAbove_count)

local levels Lev1 Lev2 Lev3 Lev4 ProficientOrAbove
foreach lev of local levels{
	gen `lev'_percent = `lev'/SSGTT
	tostring `lev'_percent, replace format("%9.4f") force
}

drop Lev1 Lev2 Lev3 Lev4 ProficientOrAbove SSGTT

gen Lev5_count = ""
gen Lev5_percent = ""

gen AvgScaleScore = "--"
gen ParticipationRate = "--"

//Assessment Information
rename AcademicYear SchYear
replace SchYear = substr(SchYear, 2, strlen(SchYear)-2)

forvalues n = 21/23{
	local m = `n' + 1
	replace SchYear = "20`n'-`m'" if strpos(SchYear, "`m'") == 3
}

gen AssmtName = "META-PR"
gen AssmtType = "Regular and alt"
gen ProficiencyCriteria = "Levels 3-4"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

replace AssmtName = "CRECE" if SchYear == "2023-24"
replace Flag_AssmtNameChange = "Y" if SchYear == "2023-24"
replace Flag_CutScoreChange_ELA = "Y" if SchYear == "2023-24"
replace Flag_CutScoreChange_math = "Y" if SchYear == "2023-24"
replace Flag_CutScoreChange_sci = "Y" if SchYear == "2023-24"

//NCES Variables
gen State = "Puerto Rico"
gen StateAbbrev = "PR"
gen StateFips = 72
gen NCESDistrictID = ""
gen NCESSchoolID = ""
gen StateAssignedDistID = ""
gen StateAssignedSchID = ""
gen DistType = ""
gen DistCharter = ""
gen DistLocale = ""
gen SchType = ""
gen SchLevel = ""
gen SchVirtual = ""
gen CountyName = ""
gen CountyCode = ""

//Data Levels
gen DistName = "All Districts"
gen SchName = "All Schools"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Output/PR_ED_Data_22_24", replace
export delimited "$Output/PR_ED_Data_22_24.csv", replace
