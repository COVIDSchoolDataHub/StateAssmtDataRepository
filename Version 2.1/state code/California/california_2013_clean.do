*******************************************************
* CALIFORNIA

* File name: california_2013_clean
* Last update: 2/18/2025

*******************************************************
* Notes

	* This do file cleans CA's 2013 data and merges with NCES 2009, 2010 and 2022. 
	* As of 2/18/25, the most recent NCES file available is NCES_2022. 
	* This file will need to be updated when NCES_2023 becomes available

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear
set more off

cap log close

// 2012-13 School Year 

use "$Original_Cleaned/California_Original_2013", clear

keep if TestType =="C"
keep if Grade == 3 |  Grade == 4 |  Grade == 5 |  Grade == 6 |  Grade == 7 |  Grade == 8 
drop if StudentsTested == 0

merge m:1 CountyCode DistrictCode SchoolCode TestYear using "$Original_Cleaned/CA_DistSchInfo_2010_2024"
drop if _merge == 2
drop _merge

replace DataLevel = "State" if CountyCode == 0 & DistrictCode == 0 & SchoolCode == 0

replace Drop = "DROP" if DistrictName == "California Education Authority"
drop if Drop == "DROP"
drop Drop CountyCode
rename SubgroupID StudentGroupID

merge m:1 StudentGroupID using "$Original_Cleaned/California_Student_Group_Names"
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

//Rename vars
rename DistrictName DistName 
rename TestId Subject 
rename Grade GradeLevel
rename DemographicName StudentSubGroup
rename StudentsTested StudentSubGroup_TotalTested
rename SchoolName SchName
rename PercentageAdvanced Lev5_percent
rename PercentageProficient Lev4_percent
rename PercentageBasic Lev3_percent
rename PercentageBelowBasic Lev2_percent 
rename PercentageFarBelowBasic Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageAtOrAboveProficient ProficientOrAbove_percent


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
merge m:1 NCESDistrictID using "$NCES_CA/NCES_2011_District_CA.dta", gen(DistMerge1)
merge m:1 NCESDistrictID using "$NCES_CA/NCES_2012_District_CA.dta", update gen(DistMerge2)
merge m:1 NCESDistrictID using "$NCES_CA/NCES_2022_District_CA.dta", update gen(DistMerge3)

merge m:1 NCESSchoolID using "${NCES_CA}/NCES_2011_School_CA.dta", gen(SchMerge1)
merge m:1 NCESSchoolID using "${NCES_CA}/NCES_2012_School_CA.dta", update gen(SchMerge2)
merge m:1 NCESSchoolID using "${NCES_CA}/NCES_2022_School_CA.dta", update gen(SchMerge3)

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

//Indicator Vars
replace State = "California"
replace StateAbbrev = "CA"
replace StateFips = 6

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"

gen SchYear = "2012-13"

gen AssmtName = "STAR - California Standards Tests (CSTs)" 
gen AssmtType = "Regular"

// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 8 // CHANGED
replace Subject2 = "ela" if Subject == 7 // CHANGED
replace Subject2 = "soc" if Subject == 29 // CHANGED
replace Subject2 = "sci" if Subject == 32 // CHANGED
replace Subject2 = "math" if Subject == 9 & GradeLevel == 8

drop Subject
rename Subject2 Subject

drop if Subject == ""

// Changing GradeLevel to correct format
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

// New Demographic/StudentGroup LABEL criteria (2024 update)
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
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

drop if missing(StudentSubGroup)

// Generate Missing Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
gen ProficiencyCriteria = "Levels 4-5"
gen ProficientOrAbove_count = "--" 

//ParticipationRate
gen ParticipationRate = string(StudentSubGroup_TotalTested/STARReportedEnrollmentCAPAEligib, "%9.4g")
replace ParticipationRate = "--" if ParticipationRate == "." | missing(ParticipationRate)
drop STARReportedEnrollmentCAPAEligib

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
drop if StudentSubGroup=="Never EL"

replace SchVirtual = "Missing/not reported" if missing(SchVirtual) & DataLevel == 3

replace NCESDistrictID="" if DataLevel==1
replace NCESDistrictID="Missing/not reported" if DataLevel!=1 & NCESDistrictID=="00"


local nomissing Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent ProficientOrAbove_percent

foreach var of local nomissing {
	replace `var'="*" if `var'=="."
}

//Converting to string and replacing if missing
tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)

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

//Misc Fixes
drop if strpos(SchName, "District Level Program")

replace AvgScaleScore="*" if AvgScaleScore==""

replace ParticipationRate = "1" if !missing(real(ParticipationRate)) & real(ParticipationRate) > 1


foreach v of varlist DistType DistLocale CountyName DistCharter {
	
	replace `v'="Missing/not reported" if DataLevel==2 & missing(`v')
	
}

foreach v of varlist SchType SchLevel SchVirtual DistType DistLocale CountyName DistCharter {
	
	replace `v'="Missing/not reported" if DataLevel==3 & missing(`v')
	
}

tostring StudentSubGroup_TotalTested, replace
drop if StudentGroup_TotalTested=="0"
drop if DataLevel==.
drop if StudentSubGroup=="Never EL"

replace NCESDistrictID="" if DataLevel==1


local nomissing Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent ProficientOrAbove_percent

foreach var of local nomissing {
	replace `var'="*" if `var'=="."
}

foreach var of varlist Lev*_percent {
	replace `var' = "--" if missing(`var')
}

//Other Updates
replace CountyName = proper(CountyName) if CountyName != "Missing/not reported"

//DistName Cleaning
replace DistName =stritrim(DistName) 

//SchName Cleaning
replace SchName = strtrim(SchName)
replace SchName = stritrim(SchName)

//Level Count Updates
foreach var of varlist Lev*_count {
	replace `var' = "--" if real(`var') < 0 & !missing(real(`var'))
}

//ProficientOrAbove_count updates based on V2.0 R1 (Universal code if we have two levels proficient)
local lowproflev = substr(ProficiencyCriteria, strpos(ProficiencyCriteria, "-")-1,1)
local highproflev = substr(ProficiencyCriteria, strpos(ProficiencyCriteria, "-")+1,1)
di `highproflev' - `lowproflev'
replace ProficientOrAbove_count = string(real(Lev`lowproflev'_count) + real(Lev`highproflev'_count)) if !missing(real(Lev`lowproflev'_count)) & !missing(real(Lev`highproflev'_count))
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested)) if real(ProficientOrAbove_count) > real(StudentSubGroup_TotalTested) & !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_count))

//Order, keep, sort
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName AssmtType Subject GradeLevel StudentGroup StudentSubGroup

*Exporting into a separate folder Output for Stanford - without derivations*
save "${Output_ND}/CA_AssmtData2013_NoDev", replace //If .dta format needed.
export delimited "${Output_ND}/CA_AssmtData2013_NoDev", replace 

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

*Exporting Output with derivations*
save "${Output}/CA_AssmtData_2013", replace
export delimited "${Output}/CA_AssmtData_2013", replace

* END of california_2013_clean.do
****************************************************
