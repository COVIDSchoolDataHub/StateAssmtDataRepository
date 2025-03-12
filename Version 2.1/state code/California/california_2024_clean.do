*******************************************************
* CALIFORNIA

* File name: california_2024_clean
* Last update: 2/18/2025

*******************************************************
* Notes

	* This do file cleans CA's 2024 ELA and Math data and merges with NCES 2020, 2021 and 2022. 
	* The output *.dta files will be merged with Science Data in california_Science_2019_2024.do
	* As of 2/18/25, the most recent NCES file available is NCES_2022. 
	* This file will need to be updated when NCES_2023 becomes available

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear
set more off

// 2023-24 School Year 
use "$Original_Cleaned/California_Original_2024", clear

//Drop if StudentSubGroup_TotalTested == 0
drop if TotalStudentsTested == "0"

//Get School Names & NCES Info
merge m:1 CountyCode DistrictCode SchoolCode TestYear using "$Original_Cleaned/CA_DistSchInfo_2010_2024"
drop if _merge == 2
drop _merge

drop if Drop == "DROP"
drop Drop CountyCode

//Get StudentSubGroup info
merge m:1 StudentGroupID using "$Original_Cleaned/California_Student_Group_Names"
drop if _merge ==2
drop _merge

//Rename Vars
rename DistrictName DistName
rename SchoolName SchName
rename Grade GradeLevel
rename TotalStudentsTested StudentSubGroup_TotalTested
rename MeanScaleScore AvgScaleScore
rename PercentageStandardExceeded Lev4_percent
rename PercentageStandardMet Lev3_percent
rename PercentageStandardNearlyMet Lev2_percent
rename PercentageStandardNotMet Lev1_percent 
rename CountStandardExceeded Lev4_count
rename CountStandardMet Lev3_count
rename CountStandardNearlyMet Lev2_count
rename CountStandardNotMet Lev1_count
rename PercentageStandardMetandAbove ProficientOrAbove_percent
rename CountStandardMetandAbove ProficientOrAbove_count
rename DemographicName StudentSubGroup
rename TestID Subject
rename TotalStudentsEnrolled Enrolled

drop if missing(StudentSubGroup)

//Subject
gen Subject1 = "ela" if Subject == 1
replace Subject1 = "math" if Subject == 2
drop Subject
rename Subject1 Subject
order DataLevel Subject

//GradeLevel
drop if GradeLevel > 8
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

//Converting Percents to Decimal
foreach var of varlist *_percent {
	replace `var' = string(real(`var')/100, "%9.4g") if !missing(real(`var'))
}

//Cleaning missing counts/percents
foreach var of varlist Lev* ProficientOrAbove* AvgScaleScore {
	replace `var' = "--" if missing(`var')
}

** StudentGroup & StudentSubGroup **
drop if strpos(StudentGroup, "Ethnicity for") | StudentGroup == "Parent Education"

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"
//Filipino included

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged" | StudentSubGroup == "Socioeconomically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged" | StudentSubGroup == "Not socioeconomically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"
replace StudentSubGroup = "LTEL" if StudentSubGroup == "LTEL (Long-Term English learner)"

// Disability Status 
replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

// Migrant Status
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

// Homeless Status
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

// Foster Care 
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

// Military
replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"

//Extra Groups (dropping)
drop if StudentSubGroup == "TBD (To be determined)" | StudentSubGroup == "IFEP (Initial fluent English proficient)" | StudentSubGroup == "ELs enrolled 12 months or more" | StudentSubGroup == "ELs enrolled less than 12 months" | StudentSubGroup == "Never–EL" | StudentSubGroup == "Never EL" | StudentSubGroup == "AR–LTEL (At-Risk of becoming LTEL)"

//StudentGroup
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

//ParticipationRate
gen ParticipationRate = string(real(StudentSubGroup_TotalTested)/real(Enrolled), "%9.4g")
replace ParticipationRate = "--" if ParticipationRate == "."
drop Enrolled

//DistName Updates
replace DistName = "Para Los Ninos Charter" if DistName == "Para Los Niños Charter"
replace DistName = "Para Los Ninos Middle" if DistName == "Para Los Niños Middle"
replace DistName = "Shanel Valley Academy" if DistName == "Shanél Valley Academy" 

//NCES Merging
replace NCESDistrictID = string(real(NCESDistrictID), "%07.0f")
replace NCESDistrictID = "" if DataLevel == "State"
replace NCESSchoolID = string(real(NCESSchoolID), "%012.0f")
replace NCESSchoolID = "" if DataLevel != "School"
merge m:1 NCESDistrictID using "$NCES_CA/NCES_2022_District_CA.dta", gen(DistMerge1)
merge m:1 NCESDistrictID using "$NCES_CA/NCES_2021_District_CA.dta", update gen(DistMerge2)
merge m:1 NCESDistrictID using "$NCES_CA/NCES_2020_District_CA.dta", update gen(DistMerge3)

merge m:1 NCESSchoolID using "${NCES_CA}/NCES_2022_School_CA.dta", gen(SchMerge1)
merge m:1 NCESSchoolID using "${NCES_CA}/NCES_2021_School_CA.dta", update gen(SchMerge2)
merge m:1 NCESSchoolID using "${NCES_CA}/NCES_2020_School_CA.dta", update gen(SchMerge3)

foreach var of varlist *Merge* {
	drop if `var' == 2
}
drop *Merge*

//Indicator and Missing Variables
replace State = "California"
replace StateAbbrev = "CA"
replace StateFips = 6
gen SchYear = "2023-24"

gen AssmtName = "Smarter Balanced"
gen AssmtType = "Regular"


gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

gen ProficiencyCriteria = "Levels 3-4"

gen Lev5_count = ""
gen Lev5_percent = ""

//StateAssignedDistID and StateAssignedSchID
gen StateAssignedDistID = subinstr(State_leaid, "CA-","",.)
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-") +1,.)

//Unmerged Schools
merge m:1 DistName SchName using "$Original_Cleaned/CA_Unmerged_2024", update gen(Unmerged_1)
drop if Unmerged_1 == 2
drop Unmerged_1

//2024 Updates
merge m:1 DistName SchName using "$Original_Cleaned/CA_2024_Updates", gen(Updates)
drop if Updates == 2
drop Updates
replace SchVirtual = SchVirtualNEW if !missing(SchVirtualNEW)
replace SchLevel = SchLevelNEW if !missing(SchLevelNEW)
drop *NEW


//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3

replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode = ""  if DataLevel == 1

//StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Misc Cleaning in response to self review
drop if StudentSubGroup_TotalTested == "."
replace AvgScaleScore = "--" if missing(AvgScaleScore)
replace ProficientOrAbove_percent = string(real(ProficientOrAbove_count)/real(StudentSubGroup_TotalTested), "%9.4g") if missing(real(ProficientOrAbove_percent)) & !missing(real(ProficientOrAbove_count)) & !missing(real(StudentSubGroup_TotalTested))
foreach var of varlist *_count *_percent {
	if "`var'" == "Lev5_count" | "`var'" == "Lev5_percent" continue
	replace `var' = "--" if `var' == "." | missing(`var')
}
replace AvgScaleScore = "--" if missing(AvgScaleScore)

//ProficientOrAbove_count updates based on V2.0 R1 (Universal code if we have two levels proficient)
local lowproflev = substr(ProficiencyCriteria, strpos(ProficiencyCriteria, "-")-1,1)
local highproflev = substr(ProficiencyCriteria, strpos(ProficiencyCriteria, "-")+1,1)
di `highproflev' - `lowproflev'
replace ProficientOrAbove_count = string(real(Lev`lowproflev'_count) + real(Lev`highproflev'_count)) if !missing(real(Lev`lowproflev'_count)) & !missing(real(Lev`highproflev'_count))
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested)) if real(ProficientOrAbove_count) > real(StudentSubGroup_TotalTested) & !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_count))

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

// Order, keep, sort
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName AssmtType Subject GradeLevel StudentGroup StudentSubGroup

*No Derivations - Exporting into a seperate Temp folder till Science data can be appended
save "${Temp}/CA_AssmtData_2024_ela_math_ND", replace 

*Derivations*
//Deriving Counts where possible
foreach count of varlist *_count {
local percent = subinstr("`count'","count", "percent",.)
replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}

//Level Count Updates
foreach var of varlist Lev*_count {
	replace `var' = "--" if real(`var') < 0 & !missing(real(`var'))
}

//Replacing ProficientOrAbove_count updates based on V2.0 R1 (Universal code if we have two levels proficient)
replace ProficientOrAbove_count = string(real(Lev`lowproflev'_count) + real(Lev`highproflev'_count)) if !missing(real(Lev`lowproflev'_count)) & !missing(real(Lev`highproflev'_count))
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested)) if real(ProficientOrAbove_count) > real(StudentSubGroup_TotalTested) & !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_count))

//Keeping, ordering and sorting variables
keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting into a seperate Temp folder till Science data can be appended
save "$Temp/CA_AssmtData_2024_ela_math", replace	
* END of california_2024_clean.do
****************************************************
