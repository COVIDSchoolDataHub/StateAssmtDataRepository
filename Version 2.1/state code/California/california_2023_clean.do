clear
set more off

// IMPORTANT NOTE!
// before running the code, make sure a copy of 
// "California_Student_Group_Names.dta" exists in the Cleaned DTA folder

global data "/Volumes/T7/State Test Project/California/Cleaned DTA"
global nces "/Volumes/T7/State Test Project/California/NCES"
global output "/Volumes/T7/State Test Project/California/Output"


// 2022-23 School Year 
use "$data/California_Original_2023", clear

//Drop if StudentSubGroup_TotalTested == 0
drop if StudentsTested == "0"

//Get School Names & NCES Info
merge m:1 CountyCode DistrictCode SchoolCode TestYear using "$data/CA_DistSchInfo_2010_2024"
drop if _merge == 2
drop _merge

drop if Drop == "DROP"
drop Drop CountyCode

* drop if StudentGroupID == 250
drop if StudentGroupID == 251
drop if StudentGroupID == 252

//Get StudentSubGroup info
merge m:1 StudentGroupID using "$data/California_Student_Group_Names"
drop if _merge ==2
drop _merge


// New Demographic/StudentGroup DROP criteria (2024 update)
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if DemographicName == "ADEL (Adult English learner)"  
drop if DemographicName == "College graduate"
drop if DemographicName == "Declined to state"
drop if DemographicName == "ELs enrolled 12 months or more"
drop if DemographicName == "ELs enrolled less than 12 months"

drop if DemographicName == "Graduate school/Post graduate"
drop if DemographicName == "High school graduate"
drop if DemographicName == "Not a high school graduate"
drop if DemographicName == "Some college (includes AA degree)"
drop if DemographicName == "IFEP (Initial fluent English proficient)"
drop if DemographicName == "TBD (To be determined)"
drop if DemographicName == "AR–LTEL (At-Risk of becoming LTEL)"


//Rename Variables
rename DistrictName DistName 
rename TestID Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
rename StudentsTested StudentSubGroup_TotalTested // r3 changed 2021 + 2022
rename SchoolName SchName
rename PercentageStandardExceeded Lev4_percent
rename PercentageStandardMet Lev3_percent
rename PercentageStandardNearlyMet Lev2_percent
rename PercentageStandardNotMet Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageStandardMetandAbove ProficientOrAbove_percent

drop StudentGroupID
drop if missing(StudentSubGroup)

//DistName Updates
replace DistName = "Para Los Ninos Charter" if DistName == "Para Los Niños Charter"
replace DistName = "Para Los Ninos Middle" if DistName == "Para Los Niños Middle"
replace DistName = "Shanel Valley Academy" if DistName == "Shanél Valley Academy" 

//NCES Merging
replace NCESDistrictID = string(real(NCESDistrictID), "%07.0f")
replace NCESDistrictID = "" if DataLevel == "State"
replace NCESSchoolID = string(real(NCESSchoolID), "%012.0f")
replace NCESSchoolID = "" if DataLevel != "School"
merge m:1 NCESDistrictID using "$nces/NCES_2022_District.dta", gen(DistMerge1)
merge m:1 NCESDistrictID using "$nces/NCES_2021_District.dta", update gen(DistMerge2)
merge m:1 NCESDistrictID using "$nces/NCES_2020_District.dta", update gen(DistMerge3)

merge m:1 NCESSchoolID using "${nces}/NCES_2022_School.dta", gen(SchMerge1)
merge m:1 NCESSchoolID using "${nces}/NCES_2021_School.dta", update gen(SchMerge2)
merge m:1 NCESSchoolID using "${nces}/NCES_2020_School.dta", update gen(SchMerge3)

foreach var of varlist *Merge* {
	drop if `var' == 2
}
drop *Merge*

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

//Indicator Variables
replace State = "California"
replace StateAbbrev = "CA"
replace StateFips = 6

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

gen SchYear = "2022-23"

gen AssmtName = "Smarter Balanced"
gen AssmtType = "Regular"

//Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 2 
replace Subject2 = "ela" if Subject == 1
drop Subject
rename Subject2 Subject

//Changing GradeLevel to correct format
drop if GradeLevel > 8
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel


//New Demographic/StudentGroup LABEL criteria (2024 update)

replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

// StudentSubGroup Correct Labels 

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


// Generate Missing Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count= ""
gen Lev5_percent= ""

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--" 

//ParticipationRate
gen ParticipationRate = string(real(StudentSubGroup_TotalTested)/real(StudentsEnrolled), "%9.4g")
replace ParticipationRate = "--" if ParticipationRate == "." | missing(ParticipationRate)
drop StudentsEnrolled


//Converting Percents to Decimal
foreach var of varlist *_percent {
	replace `var' = string(real(`var')/100, "%9.4g") if !missing(real(`var'))
}


//StateAssignedDistID and StateAssignedSchID
gen StateAssignedDistID = subinstr(State_leaid, "CA-","",.)
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-") +1,.)

replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode = ""  if DataLevel == 1

//Misc Fixes

replace AvgScaleScore="*" if AvgScaleScore==""

foreach v of varlist DistType DistLocale CountyName DistCharter {
	
	replace `v'="Missing/not reported" if DataLevel==2 & missing(`v')
	
}

foreach v of varlist SchType SchLevel SchVirtual DistType DistLocale CountyName DistCharter {
	
	replace `v'="Missing/not reported" if DataLevel==3 & missing(`v')
	
}

drop if DataLevel==.
drop if StudentSubGroup == "Never–EL" | StudentSubGroup == "Never EL"

replace SchVirtual = "Missing/not reported" if missing(SchVirtual) & DataLevel == 3

replace NCESDistrictID="" if DataLevel==1
replace NCESDistrictID="Missing/not reported" if DataLevel!=1 & NCESDistrictID=="00"


local nomissing Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent ProficientOrAbove_percent

foreach var of local nomissing {
	replace `var'="*" if `var'=="."
}

//Deriving Counts where possible
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)
foreach count of varlist *_count {
local percent = subinstr("`count'","count", "percent",.)
replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}




//StudentGroup_TotalTested
cap drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Level Count Updates
foreach var of varlist Lev*_count {
	replace `var' = "--" if real(`var') < 0 & !missing(real(`var'))
}

//Cleaning in response to self review
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
replace DistName = strtrim(DistName)
replace DistName =stritrim(DistName)
replace SchName = strtrim(SchName)
replace SchName = stritrim(SchName)
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


save "${output}/CA_AssmtData_2023_ela_math", replace