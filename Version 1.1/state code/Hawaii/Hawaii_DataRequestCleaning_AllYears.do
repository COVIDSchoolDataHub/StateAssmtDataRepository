clear
set more off
set trace off
global Original "/Volumes/T7/State Test Project/Hawaii/Original Data"
global Output "/Volumes/T7/State Test Project/Hawaii/Output"
global NCES "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"

//Importing (Unhide on First Run)
/*
import excel "$Original/HI_OriginalData_DataRequest_All", firstrow sheet("SBAData")
save "$Original/HI_OriginalData_DataRequest_All", replace


//Separating by Year
forvalues year = 2015/2023 {
	if `year' == 2020 continue
	use "$Original/HI_OriginalData_DataRequest_All", clear
	keep if Column4 == `year'
	save "$Original/HI_OriginalData_DataRequest_`year'", replace
}
clear
*/


forvalues year = 2015/2023 {
if `year' == 2020 continue
use "$Original/HI_OriginalData_DataRequest_`year'", clear
local prevyear = `year' - 1

	
//Renaming
rename Column1 AssmtName
rename Column2 StateAssignedSchID
rename Column3 SchName
rename Column4 SchYear
drop Column5
rename Column6 StudentSubGroup
rename Column7 GradeLevel
rename Column8 Subject
rename Column9 StudentSubGroup_TotalTested
rename Column10 ParticipationRate
rename Column11 Lev1_count
rename Column12 Lev1_percent
rename Column13 Lev2_count
rename Column14 Lev2_percent
rename Column15 Lev3_count
rename Column16 Lev3_percent
rename Column17 Lev4_count
rename Column18 Lev4_percent
rename Column19 ProficientOrAbove_count
rename Column20 ProficientOrAbove_percent

//StudentSubGroup
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Disadvantaged"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learner (EL)"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiple"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non Disadvantaged (Non Disadvantaged)"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non English Learner (Non EL)"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander"
replace StudentSubGroup = subinstr(StudentSubGroup, "Non ", "Non-",.)
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Non-Foster"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Special Education (SPED)"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Non-Special Education (Non-SPED)"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//GradeLevel
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

//Subject
replace Subject = "math" if Subject == "M"
replace Subject = "sci" if Subject == "S"
replace Subject = "ela" if Subject == "R"

//Cleaning Counts/Percents
foreach var of varlist StudentSubGroup_TotalTested-ProficientOrAbove_percent {
replace `var' = "--" if `var' == "n/a"
}


foreach percent of varlist *_percent {
	replace `percent' = string(real(`percent')/100, "%9.3g") if regexm(`percent', "[0-9]") !=0
	local count = subinstr("`percent'", "percent", "count",.)
	replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if regexm(`count', "[0-9]") == 0 & regexm(`percent', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0
}

replace ParticipationRate = string(real(ParticipationRate)/100, "%9.3g") if regexm(ParticipationRate, "[0-9]") !=0

//SchYear
tostring SchYear, replace
replace SchYear = string(real(SchYear)-1) + "-" + substr(SchYear, 3, 2)

//DataLevel
gen DataLevel = ""
replace DataLevel = "School" if StateAssignedSchID < 777
replace DataLevel = "State" if StateAssignedSchID == 999
drop if StateAssignedSchID >= 777 & StateAssignedSchID != 999 //Dropping Data with ID 777 ("State of Hawaii - Charter") and 900 ("State of Hawaii - DOE School")
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel

**Creating District Level Observations as Duplicates of State Level Observations
expand 2 if DataLevel == 1, gen(Dist)
replace DataLevel = 2 if Dist == 1
gen state_leaid = "HI-001" if DataLevel !=1
replace SchName = "All Schools" if DataLevel !=3
replace StateAssignedSchID = . if DataLevel !=3
sort DataLevel
drop Dist

//Merging with NCES
tempfile temp1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
clear
use "$NCES/NCES_`prevyear'_District"
keep if state_name == "Hawaii"
replace state_leaid = "HI-001"
keep ncesdistrictid state_leaid lea_name district_agency_type DistCharter DistLocale county_code county_name
merge 1:m state_leaid using "`tempdist'", keep(match using) nogen
save "`tempdist'", replace
clear

//Schools
use "`temp1'"
keep if DataLevel == 3
gen seasch = string(StateAssignedSchID)
tempfile tempsch
save "`tempsch'", replace
use "$NCES/NCES_`prevyear'_School"
keep if state_name == "Hawaii"
replace state_leaid = "HI-001"
if `year' != 2023 keep ncesdistrictid state_leaid lea_name district_agency_type DistCharter DistLocale county_code county_name ncesschoolid SchLevel SchVirtual SchType seasch
if `year' == 2023 {
keep ncesdistrictid state_leaid lea_name district_agency_type DistCharter DistLocale county_code county_name ncesschoolid SchLevel SchVirtual school_type seasch 
rename school_type SchType
foreach var of varlist district_agency_type SchType SchVirtual SchLevel {
	decode `var', gen(temp)
	drop `var'
	rename temp `var'
}
}
replace seasch = substr(seasch,3,4)
merge 1:m seasch using "`tempsch'", keep(match using) nogen
save "`tempsch'", replace
clear

use "`temp1'"
keep if DataLevel == 1
append using "`tempdist'" "`tempsch'"


//Fixing NCES Vars
rename state_leaid StateAssignedDistID
rename ncesdistrictid NCESDistrictID
rename lea_name DistName
replace DistName = "All Districts" if DataLevel == 1
rename district_agency_type DistType
rename county_code CountyCode
rename county_name CountyName
rename ncesschoolid NCESSchoolID

//StudentGroup_TotalTested (with new convention)
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

**Deriving StudentSubGroup_TotalTested if possible (Doesn't look like any derivations are possible)
destring StudentSubGroup_TotalTested, gen(UnsuppressedSSG) force
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName Subject GradeLevel)
gen ind = 1 if UnsuppressedSG !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") == 0 & regexm(StudentGroup_TotalTested, "[0-9]") !=0 & StudentGroup != "RaceEth"
replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested) - UnsuppressedSG) if UnsuppressedSG !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") == 0 & regexm(StudentGroup_TotalTested, "[0-9]") !=0 & StudentGroup != "RaceEth"
drop ind UnsuppressedSG UnsuppressedSSG

//Indicator Variables
gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular"
gen State = "Hawaii"
gen StateAbbrev = "HI"
gen StateFips = 15

**Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

if `year' == 2015 {
	replace Flag_AssmtNameChange = "Y"
	replace Flag_CutScoreChange_ELA = "Y"
	replace Flag_CutScoreChange_math = "Y"
	replace Flag_CutScoreChange_sci = "Y"
	
}

if `year' == 2021 {
	replace Flag_AssmtNameChange = "Y" if Subject == "sci"
	replace Flag_CutScoreChange_sci = "Y"
}



//Empty Variables
gen AvgScaleScore = "--"
gen Lev5_count = ""
gen Lev5_percent = ""

//CountyName
if `year' == 2015 replace CountyName = proper(CountyName)

//AssmtName
replace AssmtName = "Smarter Balanced Assessment" if Subject != "sci"
if `year' <2021 replace AssmtName = "Hawaii Science Assessment - HCPS III" if Subject == "sci"
if `year' >=2021 replace AssmtName = "Hawaii Science Assessment - NGSS" if Subject == "sci"

//Deriving ProficientOrAbove_count and ProficientOrAbove_percent if we have Levels 1 & 2
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count)) if regexm(StudentSubGroup_TotalTested, "[0-9]") !=0 & regexm(Lev1_count, "[0-9]") !=0 & regexm(Lev2_count, "[0-9]") !=0 & regexm(ProficientOrAbove_count, "[0-9]") == 0 
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent), "%9.3g") if regexm(Lev1_percent, "[0-9]") !=0 & regexm(Lev2_percent, "[0-9]") !=0 & regexm(ProficientOrAbove_percent, "[0-9]") == 0 
replace ProficientOrAbove_percent = "0" if strpos(ProficientOrAbove_percent, "e") !=0 | ProficientOrAbove_count == "0" | (real(ProficientOrAbove_percent)< 0.009 & regexm(ProficientOrAbove_percent, "[0-9]") !=0)
replace ProficientOrAbove_count = "0" if real(ProficientOrAbove_count)< 0 & regexm(ProficientOrAbove_count, "[0-9]") !=0

//Deriving Lev Counts/Percents if we have all others
replace Lev1_percent = string(1-real(Lev2_percent)-real(Lev3_percent)-real(Lev4_percent), "%9.3g") if regexm(Lev1_percent, "[0-9]") == 0 & regexm(Lev2_percent, "[0-9]") !=0 & regexm(Lev3_percent, "[0-9]") !=0 & regexm(Lev4_percent, "[0-9]") !=0
replace Lev2_percent = string(1-real(Lev1_percent)-real(Lev3_percent)-real(Lev4_percent), "%9.3g") if regexm(Lev2_percent, "[0-9]") == 0 & regexm(Lev1_percent, "[0-9]") !=0 & regexm(Lev3_percent, "[0-9]") !=0 & regexm(Lev4_percent, "[0-9]") !=0
replace Lev3_percent = string(1-real(Lev2_percent)-real(Lev1_percent)-real(Lev4_percent), "%9.3g") if regexm(Lev3_percent, "[0-9]") == 0 & regexm(Lev1_percent, "[0-9]") !=0 & regexm(Lev2_percent, "[0-9]") !=0 & regexm(Lev4_percent, "[0-9]") !=0
replace Lev4_percent = string(1-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if regexm(Lev4_percent, "[0-9]") == 0 & regexm(Lev1_percent, "[0-9]") !=0 & regexm(Lev3_percent, "[0-9]") !=0 & regexm(Lev2_percent, "[0-9]") !=0
foreach var of varlist Lev*_percent {
	replace `var' = "0" if strpos(`var', "e") !=0
}
replace Lev1_count = string(1-real(Lev2_count)-real(Lev3_count)-real(Lev4_count), "%9.3g") if regexm(Lev1_count, "[0-9]") == 0 & regexm(Lev2_count, "[0-9]") !=0 & regexm(Lev3_count, "[0-9]") !=0 & regexm(Lev4_count, "[0-9]") !=0
replace Lev2_count = string(1-real(Lev1_count)-real(Lev3_count)-real(Lev4_count), "%9.3g") if regexm(Lev2_count, "[0-9]") == 0 & regexm(Lev1_count, "[0-9]") !=0 & regexm(Lev3_count, "[0-9]") !=0 & regexm(Lev4_count, "[0-9]") !=0
replace Lev3_count = string(1-real(Lev2_count)-real(Lev1_count)-real(Lev4_count), "%9.3g") if regexm(Lev3_count, "[0-9]") == 0 & regexm(Lev1_count, "[0-9]") !=0 & regexm(Lev2_count, "[0-9]") !=0 & regexm(Lev4_count, "[0-9]") !=0
replace Lev4_count = string(1-real(Lev1_count)-real(Lev3_count)-real(Lev2_count), "%9.3g") if regexm(Lev4_count, "[0-9]") == 0 & regexm(Lev1_count, "[0-9]") !=0 & regexm(Lev3_count, "[0-9]") !=0 & regexm(Lev2_count, "[0-9]") !=0
foreach var of varlist Lev*_count {
	replace `var' = "0" if strpos(`var', "e") !=0
}



//Final Cleaning and Exporting
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/HI_AssmtData_`year'", replace
export delimited "${Output}/HI_AssmtData_`year'", replace
clear
}


