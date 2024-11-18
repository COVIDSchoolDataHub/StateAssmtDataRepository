clear
set more off

global original "/Volumes/T7/State Test Project/California/Original Data Files"
global data "/Volumes/T7/State Test Project/California/Cleaned DTA"
global nces "/Volumes/T7/State Test Project/California/NCES"
global output "/Volumes/T7/State Test Project/California/Output"
global unmerged "/Volumes/T7/State Test Project/California/Unmerged Districts With NCES"

//years 2019 2021 2022 2023 2024
foreach year in 2019 2021 2022 2023 2024 {
	local prevyear = `year' - 1
	use "${original}/CA_OriginalData_`year'_sci", clear
	
//Drop if StudentSubGroup_TotalTested == "0"
if `year' == 2019 rename TotalNumberofStudentsTested StudentSubGroup_TotalTested
if `year' > 2019 & `year' < 2024 rename StudentsTested StudentSubGroup_TotalTested
if `year' == 2024 rename TotalStudentsTested StudentSubGroup_TotalTested
	
drop if StudentSubGroup_TotalTested == "0"

//Get School Names & NCES Info
merge m:1 CountyCode DistrictCode SchoolCode TestYear using "$data/CA_DistSchInfo_2010_2024"
drop if _merge == 2
drop _merge

replace DataLevel = "State" if CountyCode == 0 & DistrictCode == 0 & SchoolCode == 0

//Get StudentSubGroup info
cap rename DemographicID StudentGroupID
merge m:1 StudentGroupID using "$data/California_Student_Group_Names"
drop if _merge ==2
drop _merge

replace Drop = "DROP" if DistrictName == "California Education Authority"
drop if Drop == "DROP"
drop Drop CountyCode

//Rename and Drop Variables
if `year' == 2019 drop Filler TestYear DemographicIDNum TestType TotalNumberTestedatEntityLevelan TotalNumberTestedatthisDemograph TestID TotalNumberofStudentswithValidSc-v29 StudentGroupID
if `year' > 2019 & `year' < 2024 drop Filler TestYear DemographicIDNum TestType TotalTestedatReportingLevel TotalTestedwithScoresatReporting TestID StudentswithScores-TypeID StudentGroupID
rename Grade GradeLevel
if `year' == 2019 rename CASTReportedEnrollment Enrollment
if `year' > 2019 & `year' < 2024 rename StudentsEnrolled Enrollment
rename MeanScaleScore AvgScaleScore
rename PercentageStandardExceeded Lev4_percent
rename PercentageStandardMet Lev3_percent
rename PercentageStandardNearlyMet Lev2_percent
rename PercentageStandardNotMet Lev1_percent
rename PercentageStandardMetandAbove ProficientOrAbove_percent
rename DemographicName StudentSubGroup
rename DistrictName DistName
rename SchoolName SchName
if `year' == 2024 {
rename CountStandardExceeded Lev4_count
rename CountStandardMet Lev3_count
rename CountStandardNearlyMet Lev2_count
rename CountStandardNotMet Lev1_count
rename CountStandardMetandAbove ProficientOrAbove_count
rename TotalStudentsEnrolled Enrollment
}
drop if missing(StudentSubGroup)

//GradeLevel
drop if GradeLevel > 8 | GradeLevel < 3
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

//ParticipationRate
gen ParticipationRate = string(real(StudentSubGroup_TotalTested)/real(Enrollment), "%9.4g") if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Enrollment))
replace ParticipationRate = "--" if missing(ParticipationRate)
drop Enrollment

//Proficiency Level Conversions
foreach var of varlist Lev*_percent ProficientOrAbove_percent {
	replace `var' = string(real(`var')/100, "%9.4g") if strpos(`var', "*") == 0
	replace `var' = "--" if missing(`var')
}


//Level Counts for 2019-2023
if `year' != 2024 {
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	gen `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested))
	replace `count' = "--" if missing(`count')
}
}

//StudentGroup & StudentSubGroup 
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if StudentSubGroup == "ADEL (Adult English learner)"  
drop if StudentSubGroup == "College graduate"
drop if StudentSubGroup == "Declined to state"
drop if StudentSubGroup == "ELs enrolled 12 months or more"
drop if StudentSubGroup == "ELs enrolled less than 12 months"

drop if StudentSubGroup == "Graduate school/Post graduate"
drop if StudentSubGroup == "High school graduate"
drop if StudentSubGroup == "Not a high school graduate"
drop if StudentSubGroup == "Some college (includes AA degree)"
drop if StudentSubGroup == "IFEP (Initial fluent English proficient)"
drop if StudentSubGroup == "TBD (To be determined)"

replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"
*drop if StudentSubGroup == "Filipino" //Not dropping as of 10/15/24

replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"

drop if StudentSubGroup == "Never EL"

//NCES Merging
replace NCESDistrictID = string(real(NCESDistrictID), "%07.0f")
replace NCESDistrictID = "" if DataLevel == "State"
replace NCESSchoolID = string(real(NCESSchoolID), "%012.0f")
replace NCESSchoolID = "" if DataLevel != "School"
if `year' != 2024 merge m:1 NCESDistrictID using "$nces/NCES_`prevyear'_District.dta", gen(DistMerge1)
merge m:1 NCESDistrictID using "$nces/NCES_2022_District.dta", update gen(DistMerge2)

if `year' != 2024 merge m:1 NCESSchoolID using "${nces}/NCES_`prevyear'_School.dta", gen(SchMerge1)
merge m:1 NCESSchoolID using "${nces}/NCES_2022_School.dta", update gen(SchMerge2)

//StateAssignedDistID and StateAssignedSchID
gen StateAssignedDistID = subinstr(State_leaid, "CA-","",.)
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-") +1,.)

//Unmerged Schools
if `year' == 2024 { 
merge m:1 DistName SchName using "$data/CA_Unmerged_2024", update gen(Unmerged_1)
drop if Unmerged_1 == 2
drop Unmerged_1

merge m:1 DistName SchName using "$data/CA_2024_Updates", gen(Updates)
drop if Updates == 2
drop Updates
replace SchVirtual = SchVirtualNEW if !missing(SchVirtualNEW)
replace SchLevel = SchLevelNEW if !missing(SchLevelNEW)
drop *NEW SchYear
}


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

//Indicator and Missing Variables
replace State = "California"
replace StateAbbrev = "CA"
replace StateFips = 6
gen SchYear = "`prevyear'-" + substr("`year'",-2,2)

gen AssmtName = "CAST"
gen AssmtType = "Regular"

gen Subject = "sci"

gen Flag_AssmtNameChange = "N"
replace Flag_AssmtNameChange = "Y" if `year' == 2019
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
replace Flag_CutScoreChange_sci = "Y" if `year' == 2019
gen Flag_CutScoreChange_soc = "Not applicable"

gen ProficiencyCriteria = "Levels 3-4"

gen Lev5_count = ""
gen Lev5_percent = ""

//Fixing Missing Values for SSG_TT
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested) | StudentSubGroup_TotalTested == "."

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

//Deriving StudentSubGroup_TotalTested where possible
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName GradeLevel Subject)
gen missing_SSG = 1 if missing(real(StudentSubGroup_TotalTested))
egen missing_multiple = total(missing_SSG), by(StudentGroup DistName SchName GradeLevel Subject)

order StudentGroup_TotalTested UnsuppressedSG StudentSubGroup_TotalTested UnsuppressedSSG missing_multiple

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0 & !missing(real(StudentGroup_TotalTested)-UnsuppressedSG) & StudentSubGroup != "All Students"

drop Unsuppressed* missing_*

order DataLevel

//Misc Changes to DistName for Consistency
replace DistName = "Para Los Ninos Charter" if DistName == "Para Los Niños Charter"
replace DistName = "Para Los Ninos Middle" if DistName == "Para Los Niños Middle"
replace DistName = "Shanel Valley Academy" if DistName == "Shanél Valley Academy"
replace DistName = "Voices College-Bound Language Academy At" if DistName == "Voices College Bound Language Academy At" 


//Misc Changes in response to self review
forvalues n = 1/4 {
	replace Lev`n'_percent = "--" if Lev`n'_percent == "." | missing(Lev`n'_percent)
	replace Lev`n'_count = "--" if Lev`n'_count == "." | missing(Lev`n'_count)
}
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." | missing(ProficientOrAbove_count)
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "." | missing(ProficientOrAbove_percent)

replace AvgScaleScore = "--" if missing(AvgScaleScore)

drop if missing(DataLevel)


//ProficientOrAbove_count updates based on V2.0 R1 (Universal code if we have two levels proficient)
local lowproflev = substr(ProficiencyCriteria, strpos(ProficiencyCriteria, "-")-1,1)
local highproflev = substr(ProficiencyCriteria, strpos(ProficiencyCriteria, "-")+1,1)
di `highproflev' - `lowproflev'
replace ProficientOrAbove_count = string(real(Lev`lowproflev'_count) + real(Lev`highproflev'_count)) if !missing(real(Lev`lowproflev'_count)) & !missing(real(Lev`highproflev'_count))

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//Saving and appending
save "${output}/CA_AssmtData_`year'_sci", replace
append using "${output}/CA_AssmtData_`year'_ela_math"
drop if missing(StateAbbrev)
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "${output}/CA_AssmtData_`year'_Stata", replace
export delimited "$output/CA_AssmtData_`year'", replace
}
