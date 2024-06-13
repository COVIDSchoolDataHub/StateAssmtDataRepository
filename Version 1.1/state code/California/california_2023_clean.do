clear
set more off

cap log close
log using california_cleaning.log, replace

// IMPORTANT NOTE!
// before running the code, make sure a copy of 
// "California_Student_Group_Names.dta" exists in the Cleaned DTA folder


// set file directory to cleaned DTA folder
cd "/Volumes/T7/State Test Project/California/Cleaned DTA"

global nces "/Volumes/T7/State Test Project/California/NCES"
global output "/Volumes/T7/State Test Project/California/Output"
global unmerged "/Volumes/T7/State Test Project/California/Unmerged Districts With NCES"


// 2022-23 School Year 
use California_Original_2023, clear

merge m:1 CountyCode DistrictCode SchoolCode using California_School_District_Names_2023
drop _merge

* drop if StudentGroupID == 250
drop if StudentGroupID == 251
drop if StudentGroupID == 252

merge m:1 StudentGroupID using California_Student_Group_Names
drop _merge

replace DemographicName = "LTEL" if StudentGroupID == 250
replace StudentGroup = "English-Language Fluency" if DemographicName == "LTEL"


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




gen DataLevel = "School"
replace DataLevel = "District" if SchoolCode == 0
replace DataLevel = "County" if DistrictCode == 0 & SchoolCode == 0
replace DataLevel = "State" if CountyCode == 0 & DistrictCode == 0 & SchoolCode == 0
drop if DataLevel == "County"

rename TestYear SchYear
rename DistrictCode StateAssignedDistID

rename SchoolCode StateAssignedSchID
rename DistrictName DistName 
rename TestID Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
gen StudentGroup_TotalTested = StudentsTested 
rename SchoolName SchName
rename PercentageStandardExceeded Lev4_percent
rename PercentageStandardMet Lev3_percent
rename PercentageStandardNearlyMet Lev2_percent
rename PercentageStandardNotMet Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageStandardMetandAbove ProficientOrAbove_percent

drop StudentGroupID


replace DistName = "Para Los Ninos Charter" if DistName == "Para Los Niños Charter"
replace DistName = "Para Los Ninos Middle" if DistName == "Para Los Niños Middle"
replace DistName = "Shanel Valley Academy" if DistName == "Shanél Valley Academy" 


replace DistName = ustrtitle(DistName)
*replace CountyName = ustrtitle(CountyName)
drop CountyName

tostring CountyCode StateAssignedDistID, replace
replace CountyCode = "0" + CountyCode if strlen(CountyCode) == 1
gen State_leaid = CountyCode + StateAssignedDistID
drop CountyCode

replace DistName = "Voices College-Bound Language Academy At" if DistName == "Voices College Bound Language Academy At" 

merge m:m DistName using "${nces}/1_NCES_2022_District_With_Extra_Districts.dta"
rename _merge DistMerge

replace State_leaid = "Missing/Not Reported" if DistMerge == 1 & CountyCode != 0 //& StateAssignedSchID == 0
replace NCESDistrictID = "00" if DistMerge == 1 & CountyCode != 0 // & StateAssignedSchID == 0

drop if DistMerge == 2
// drop DistMerge

gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID

rename StateAssignedSchID State_School_ID

rename State_School_ID seasch2 // NEW ADDED

* drop _merge

replace DistName=DistName+" District" if strpos(DistName, "District")<1 & DataLevel != "State"

merge m:m seasch2 using "${nces}/1_NCES_2022_School.dta", force // CHANGED
rename _merge SchoolMerge

/*
merge m:m DistName using "${nces}/1_NCES_2022_School.dta", keepusing(DistType State_leaid DistCharter NCESDistrictID) update

drop _merge
*/

drop if SchoolMerge == 2
drop if SchoolMerge == 1 & SchName != ""
// drop SchoolMerge

rename seasch2 StateAssignedSchID // CHANGED


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// NEW ADDED

drop State
drop StateAbbrev
drop StateFips
gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 // CHANGED

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_sci = "Not applicable"
gen Flag_CutScoreChange_soc = "Not applicable"


gen SchYear2 = "2022-23"
drop SchYear
rename SchYear2 SchYear

gen AssmtName = "Smarter Balanced"
gen AssmtType = "Regular"

// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 2 
replace Subject2 = "ela" if Subject == 1
drop Subject
rename Subject2 Subject

// Changing GradeLevel to correct format
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == 3
replace GradeLevel2 = "G04" if GradeLevel == 4
replace GradeLevel2 = "G05" if GradeLevel == 5
replace GradeLevel2 = "G06" if GradeLevel == 6
replace GradeLevel2 = "G07" if GradeLevel == 7
replace GradeLevel2 = "G08" if GradeLevel == 8
replace GradeLevel2 = "G10" if GradeLevel == 10
replace GradeLevel2 = "G11" if GradeLevel == 11
replace GradeLevel2 = "ALL" if GradeLevel == 13
drop GradeLevel
rename GradeLevel2 GradeLevel

drop if GradeLevel == "ALL"
drop if GradeLevel == "G10"
drop if GradeLevel == "G11"



// NEW ADDED

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

// keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

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
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "Eng Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

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


//r3 changed
// Generate Extra Level Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"



gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count = "--" 
//r3 changed

// Changed 2 
destring StudentsTested, replace force 
destring StudentsEnrolled, replace force
gen ParticipationRate = StudentsTested/StudentsEnrolled
// Changed 2


// drop schyear // DELETED


// seasch = StateAssignedSchID // CHANGED 2


// ENDED HERE
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
destring StudentGroup_TotalTested, replace force ignore(",")
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == . // CHANGED 2 
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
// CHANGED

// New ADDED 2 
replace Lev1_percent = "-99999999" if Lev1_percent == "*"
replace Lev2_percent = "-99999999" if Lev2_percent == "*"
replace Lev3_percent = "-99999999" if Lev3_percent == "*"
replace Lev4_percent = "-99999999" if Lev4_percent == "*"
// replace Lev5_percent = "-99999999" if Lev5_percent == "*"
//replace ProficientOrAbove_count = "-99999999" if ProficientOrAbove_count == "*"
replace ProficientOrAbove_percent = "-99999999" if ProficientOrAbove_percent == "*"
// replace ParticipationRate = "-99999999" if ParticipationRate == "*"
// New ADDED 2 


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent ParticipationRate, replace //r3 changed


// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100 CHANGED 2 

// NEW ADDED 2
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, replace force // r3 changed

replace Lev1_percent = "*" if Lev1_percent == "-999999.99"
replace Lev2_percent = "*" if Lev2_percent == "-999999.99"
replace Lev3_percent = "*" if Lev3_percent == "-999999.99"
replace Lev4_percent = "*" if Lev4_percent == "-999999.99"
replace Lev5_percent = "*" if Lev5_percent == "-999999.99"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-999999.99"



replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode =.  if DataLevel == 1

replace NCESDistrictID = subinstr(NCESDistrictID, "6", "06", 1)
replace NCESDistrictID = subinstr(NCESDistrictID, "006", "06", 1)
// NEW ADDED 2


// r3 change unique to 2022 
replace SchVirtual = "No" if SchName == "Aspen Ridge Public"
replace SchVirtual = "No" if SchName == "Audeo Valley Charter"
replace SchVirtual = "No" if SchName == "Bostonia Global"
replace SchVirtual = "No" if SchName == "Bridges Preparatory Academy"
replace SchVirtual = "No" if SchName == "KIPP Stockton Kindergarten-12 Grade"
replace SchVirtual = "No" if SchName == "New Hope Charter"
replace SchVirtual = "No" if SchName == "Shanél Valley Academy"
// r3 change unique to 2022 

// r3 change
replace NCESDistrictID = "0691006" if NCESDistrictID == "069106"
replace NCESDistrictID = "0602006" if NCESDistrictID == "060206"
replace NCESDistrictID = "0600006" if NCESDistrictID == "060006"
replace NCESDistrictID = "0600063" if NCESDistrictID == "060063"
replace NCESDistrictID = "0600064" if NCESDistrictID == "060064"
replace NCESDistrictID = "0600065" if NCESDistrictID == "060065"
// r3 change

replace NCESSchoolID = substr(NCESDistrictID, 1, 7) + substr(NCESSchoolID, 8, .) if NCESDistrictID != "00" & DataLevel == 3 //r3 changed


//////////////////////////
*** 2024 edits 
//////////////////////////


drop State
gen State="California"
drop StateAbbrev
gen StateAbbrev="CA"
drop StateFips
gen StateFips=6

drop if strpos(SchName, "District Level Program")

replace AvgScaleScore="*" if AvgScaleScore==""

replace ProficiencyCriteria="Levels 3-4"

replace Lev5_count=""
replace Lev5_percent=""

foreach v of varlist DistType DistLocale CountyName DistCharter {
	
	replace `v'="Missing/not reported" if DataLevel==2 & missing(`v')
	
}

foreach v of varlist SchType SchLevel SchVirtual DistType DistLocale CountyName DistCharter {
	
	replace `v'="Missing/not reported" if DataLevel==3 & missing(`v')
	
}

drop if StudentSubGroup_TotalTested=="0"
drop if StudentGroup_TotalTested=="0"
drop if DataLevel==.
drop if StudentSubGroup=="Never EL"

replace NCESDistrictID="" if DataLevel==1
replace NCESDistrictID="Missing/not reported" if DataLevel!=1 & NCESDistrictID=="00"

replace StudentSubGroup="English Proficient" if StudentSubGroup=="Eng Proficient" 

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

//ParticipationRate Updates
format ParticipationRate %9.3g
tostring ParticipationRate, replace usedisplayformat force
replace ParticipationRate = "--" if ParticipationRate == "."

	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
//NEW ADDED


save "${output}/CA_AssmtData_2023_Stata", replace
export delimited "${output}/CA_AssmtData_2023.csv", replace 
