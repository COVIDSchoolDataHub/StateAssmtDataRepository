clear
set more off

global Original "/Volumes/T7/State Test Project/Indiana/Original Data Files - Version 1.1"
global temp "/Volumes/T7/State Test Project/Indiana/Original Data Files - Version 1.1/temp"
global Output "/Volumes/T7/State Test Project/Indiana/Output"
global NCES_New "/Volumes/T7/State Test Project/Indiana/NCES"

forvalues year = 2014/2023 {
if `year' == 2020 continue
use "$temp/`year'_District_School", clear
local prevyear = `year' - 1

//Reshaping
rename proficient_per* proficiency_per*
if `year' < 2019 { 
reshape long Lev1_count_ Lev2_count_ Lev3_count_ tested proficiency_per proficient, i(idoe_corporation_id idoe_school_id grade Subject) j(StudentSubGroup, string)
}
if `year' > 2018 {
reshape long Lev1_count_ Lev2_count_ Lev3_count_ Lev4_count_ tested proficiency_per proficient, i(idoe_corporation_id idoe_school_id grade Subject) j(StudentSubGroup, string)
}
rename Lev*_count_ Lev*_count

//Combining with State Data
append using "$temp/`year'_State"

//Renaming
rename idoe_corporation_id StateAssignedDistID
rename idoe_school_id StateAssignedSchID
rename grade GradeLevel
rename corporation_name DistName
rename school_name SchName
rename proficient ProficientOrAbove_count
rename tested StudentSubGroup_TotalTested
rename proficiency_per ProficientOrAbove_percent

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.)
drop if real(substr(GradeLevel, strpos(GradeLevel, "G0")+1,2)) > 8 | real(substr(GradeLevel, strpos(GradeLevel, "G0")+1,2)) < 3

//Subject
replace Subject = lower(Subject)

//StudentSubGroup
replace StudentSubGroup = "All Students" if missing(StudentSubGroup)
replace StudentSubGroup = proper(StudentSubGroup)
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Ai" | StudentSubGroup == "American Indian"
replace StudentSubGroup = "Military" if StudentSubGroup == "Active Duty Parent"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learner" | StudentSubGroup == "Ell"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Frp" | StudentSubGroup == "Free/Reduced Price Meals"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster Student"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Ge" | StudentSubGroup == "General Education"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Mr" | StudentSubGroup == "Multiracial"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Nh" | StudentSubGroup == "Native Hawaiian Or Other Pacific Islander"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "No Active Duty Parent"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Language Learner" | StudentSubGroup == "Nonell"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Non-Foster Student"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Homeless"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Paid Meals" | StudentSubGroup == "Paidmeals"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Special Education" | StudentSubGroup == "Swd"
drop if StudentSubGroup == "Unknown" //Values for Tested Count make no sense

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Unknown"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//Getting Rid of Private Schools
drop if StateAssignedDistID == "-999"

//DataLevel
replace DataLevel = "District" if DataLevel == "LEA"
replace DataLevel = "School" if DataLevel == "SCH"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3

//Cleaning Counts and Generating Percents
foreach var of varlist *_count StudentSubGroup_TotalTested ProficientOrAbove_percent {
	replace `var' = "--" if missing(`var')
	replace `var' = "*" if strpos(`var', "*") !=0
}

foreach count of varlist Lev*_count {
	local percent = subinstr("`count'", "count","percent",.)
	gen `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.3g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested))
	replace `percent' = "--" if missing(`percent')
}

replace ProficientOrAbove_percent = string(real(ProficientOrAbove_percent), "%9.3g") if !missing(real(ProficientOrAbove_percent))


//NCES Merging
gen seasch = StateAssignedSchID
gen State_leaid = StateAssignedDistID

merge m:1 State_leaid using "${NCES_New}/NCES_`prevyear'_District", gen(_merge1)
drop if _merge1 != 3 & DataLevel !=1 //These are private schools not in NCES and should be dropped for our purposes
merge m:1 seasch using "${NCES_New}/NCES_`prevyear'_School", gen(_merge2)
drop if _merge2 == 2
drop _merge*

//Fixing One Unmerged School (Sanders School)
replace NCESSchoolID = "181281002041" if SchName == "Sanders School" & missing(NCESSchoolID)
replace SchType = "Special education school" if SchName == "Sanders School" & missing(NCESSchoolID)
replace SchLevel = "Other" if SchName == "Sanders School" & missing(NCESSchoolID)
replace SchVirtual = "Missing/not reported" if SchName == "Sanders School" & missing(NCESSchoolID)

//StudentGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(UnsuppressedSSG) force
egen StudentGroup_TotalTested = total(UnsuppressedSSG), by(StateAssignedDistID StateAssignedSchID StudentGroup Subject GradeLevel)
drop UnsuppressedSSG

//Indicator & Missing Variables
replace State = "Indiana"
replace StateFips = 18
replace StateAbbrev = "IN"
gen SchYear = "`prevyear'-" + substr("`year'",-2,2)

if `year' < 2019 gen ProficiencyCriteria = "Levels 2-3"
if `year' > 2018 gen ProficiencyCriteria = "Levels 3-4"

gen AssmtType = "Regular"

gen AvgScaleScore = "--"
gen ParticipationRate = "--"

if `year' < 2019 {
gen Lev4_count = "--"
gen Lev4_percent = "--"
}
gen Lev5_count = ""
gen Lev5_percent = ""

** Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Not applicable"
gen Flag_CutScoreChange_soc = "Not applicable"

if `year' == 2015 {
replace Flag_CutScoreChange_ELA = "Y"
replace Flag_CutScoreChange_math = "Y"
} 
if `year' == 2019 {
replace Flag_AssmtNameChange = "Y"
replace Flag_CutScoreChange_ELA = "Y"
replace Flag_CutScoreChange_math = "Y"
	
}

gen AssmtName = ""
if `year' < 2019 replace AssmtName = "ISTEP"
if `year' > 2018 replace AssmtName = "ILEARN"

replace CountyName = proper(CountyName)
replace SchName = trim(SchName)
replace DistName = trim(DistName)

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/IN_AssmtData_`year'", replace
export delimited "${Output}/IN_AssmtData_`year'", replace	
}

