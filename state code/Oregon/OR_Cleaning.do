clear
set more off
set trace off
cd "/Volumes/T7/State Test Project/Oregon"
local Original "/Volumes/T7/State Test Project/Oregon/Original Data"
local Output "/Volumes/T7/State Test Project/Oregon/Output"
local NCES "/Volumes/T7/State Test Project/NCES"

//Unhide Below Importing Code on First Run

/*

forvalues year = 2015/2023 {
	if `year' == 2020 | `year' == 2021 continue
	tempfile temp1
	save "`temp1'", emptyok
	clear
	foreach dl in State District School {
		foreach Subject in ela mat sci {
		local prior_2019_sg "RE ES_EL_Gen"
		local post_2019_sg "RE ES EL Gen"
				if "`dl'" != "School" {
					import excel "`Original'/OR_OriginalData_`year'_`Subject'_`dl'", firstrow case(preserve) allstring
					gen DataLevel = "`dl'"
					append using "`temp1'"
					save "`temp1'", replace
					clear
				}
				if "`dl'" == "School" & (`year' < 2019 | "`Subject'" == "sci") {
					foreach sg of local prior_2019_sg {
					import excel "`Original'/OR_OriginalData_`year'_`Subject'_`dl'_`sg'", firstrow case(preserve) allstring
					gen DataLevel = "`dl'"
					append using "`temp1'"
					save "`temp1'", replace
					clear
				}
			}
				if "`dl'" == "School" & `year' >= 2019 & "`Subject'" != "sci"  {
					foreach sg of local post_2019_sg {
					import excel "`Original'/OR_OriginalData_`year'_`Subject'_`dl'_`sg'", firstrow case(preserve) allstring
					gen DataLevel = "`dl'"
					append using "`temp1'"
					save "`temp1'", replace
					clear
					}
				}
			
		}
	}
	use "`temp1'"
	save "`Original'/`year'", replace
	clear
}

clear
tempfile temp1
save "`temp1'", emptyok
foreach dl in State District School {
	foreach sg in EL ES Gen RE {
		if "`dl'" != "School" {
			import excel "`Original'/OR_OriginalData_2021_`dl'", firstrow case(preserve) allstring
			gen DataLevel = "`dl'"
					append using "`temp1'"
					save "`temp1'", replace
					clear
		}
		if "`dl'" == "School" {
			import excel "`Original'/OR_OriginalData_2021_`dl'_`sg'", firstrow case(preserve) allstring
			gen DataLevel = "`dl'"
					append using "`temp1'"
					save "`temp1'", replace
					clear
		}
	}
}
use "`temp1'"
save "`Original'/2021", replace
clear

*/

//Unhide Above importing code on first run

forvalues year == 2015/2023 {
if `year' == 2020 | `year' == 2021 continue

use "`Original'/`year'"
local prevyear =`=`year'-1'

//Renaming and Dropping
drop AcademicYear
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)
rename DistrictID StateAssignedDistID
rename District DistName
rename SchoolID StateAssignedSchID
rename School SchName
rename StudentGroup StudentSubGroup
foreach n in 1 2 3 4 5 {
	cap rename NumberLevel`n' Lev`n'_count
	cap rename PercentLevel`n' Lev`n'_percent
}
rename NumberofParticipants StudentSubGroup_TotalTested
gen ProficientOrAbove_percent = ""
gen ProficientOrAbove_count = ""
if `year' <= 2017 {
replace ProficientOrAbove_count = NumberProficientLevel3or4 if !missing(NumberProficientLevel3or4)
replace ProficientOrAbove_count = NumberProficientLevel4or5 if !missing(NumberProficientLevel4or5)
replace ProficientOrAbove_percent = PercentProficientLevel4or5 if !missing(PercentProficientLevel4or5)
replace ProficientOrAbove_percent = PercentProficientLevel3or4 if !missing(PercentProficientLevel3or4)
}
if `year' ==2018 {
	replace ProficientOrAbove_count = NumberProficient
	replace ProficientOrAbove_percent = PercentProficientLevel4or5 if !missing(PercentProficientLevel4or5)
	replace ProficientOrAbove_percent = PercentProficientLevel3or4 if !missing(PercentProficientLevel3or4)
}
if `year' ==2019 {
replace ProficientOrAbove_count = NumberProficient if !missing(NumberProficient)
replace ProficientOrAbove_percent = PercentProficientLevel3or4 if !missing(PercentProficientLevel3or4)
}
if `year' == 2022 {
replace ProficientOrAbove_count = NumberProficient if !missing(NumberProficient)
replace ProficientOrAbove_percent = PercentProficientLevel3or4 if !missing(PercentProficientLevel3or4)
replace ProficientOrAbove_percent = PercentProficient if !missing(PercentProficient)

}
if `year' == 2023 {
	replace ProficientOrAbove_count = NumberProficient
	replace ProficientOrAbove_percent = PercentProficient
}
cap gen Lev5_count = ""
cap gen Lev5_percent = ""
keep StateAssignedDistID DistName StateAssignedSchID SchName Subject StudentSubGroup GradeLevel Lev5_count Lev5_percent Lev4_count Lev4_percent Lev3_count Lev3_percent Lev2_count Lev2_percent Lev1_count Lev1_percent StudentSubGroup_TotalTested ParticipationRate DataLevel SchYear ProficientOrAbove_count ProficientOrAbove_percent

//Subject 
replace Subject = "sci" if Subject == "Science"
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "ela" if strpos(Subject, "English") !=0

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.)
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = subinstr(StudentSubGroup, "Alaskan", "Alaska", .)
replace StudentSubGroup = "Economically Disadvantaged" if strpos(StudentSubGroup, "Disadvantaged") !=0
replace StudentSubGroup = subinstr(StudentSubGroup, "Learners", "Learner",.)
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Multi") !=0
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All Students") !=0
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All students") !=0
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "Unknown"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Unknown"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino"


*save "/Volumes/T7/State Test Project/Oregon/Testing/`year'", replace

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel != 3

//ProficientOrAbove_count
replace ProficientOrAbove_count = "*" if regexm(ProficientOrAbove_count, "[<>]") !=0

//Dealing with ProficientOrAbove_percent ranges
replace ProficientOrAbove_percent = "0-0.05" if strpos(ProficientOrAbove_percent, "<") !=0
replace ProficientOrAbove_percent = "0.95-1" if strpos(ProficientOrAbove_percent, ">") !=0

//Proficiency Levels
foreach n in 1 2 3 4 5 {
destring Lev`n'_percent, gen(nLev`n'_percent) i(*-%)
replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.3g") if regexm(Lev`n'_percent, "[*-]") ==0
}
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*-)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100,"%9.3g") if regexm(ProficientOrAbove_percent, "[*-]") == 0

//ParticipationRate
destring ParticipationRate, gen(nParticipationRate) i(*-)
replace ParticipationRate = string(nParticipationRate/100, "%9.3g") if regexm(ParticipationRate, "[*-]") ==0

//Missing Data
foreach var of varlist Lev* ParticipationRate ProficientOrAbove_percent StudentSubGroup_TotalTested ProficientOrAbove_count {
	replace `var' = "--" if `var' == "-"
	replace `var' = "--" if `var' == "."
}

**Merging with NCES Data**
tempfile temp1
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) ==3
replace StateAssignedSchID = "00" + StateAssignedSchID if strlen(StateAssignedSchID) ==2
replace StateAssignedSchID = "000" + StateAssignedSchID if strlen(StateAssignedSchID) ==1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'", replace
clear
if `year' < 2023 {
use "`NCES'/NCES_`prevyear'_District"
}
else if `year'==2023{
use "`NCES'/NCES_2021_District"
}
keep if state_name == 41 | state_location == "OR"
gen StateAssignedDistID = substr(state_leaid,-4,4)
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge ==1
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel ==3
tempfile tempsch
save "`tempsch'", replace
clear
if `year' < 2023 {
use "`NCES'/NCES_`prevyear'_School"
}
else if `year'==2023{
use "`NCES'/NCES_2021_School"
}
keep if state_name == 41 | state_location == "OR"
gen StateAssignedSchID = substr(seasch, -4,4)
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge ==1
save "`tempsch'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 41
replace StateAbbrev = "OR"

//Generating additional variables
gen State = "Oregon"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
gen Flag_CutScoreChange_read = ""
gen ProficiencyCriteria = "Levels 3 and 4"
gen AssmtType = "Regular"
gen AssmtName = "Smarter Balanced Assessment"
replace AssmtName = "OSAS" if Subject == "sci"
replace ProficiencyCriteria = "Levels 4 and 5" if Subject == "sci" & `year' <2019

//Flags
foreach var of varlist Flag* {
	replace `var' = "Y" if ("`var'" == "Flag_AssmtNameChange" | "`var'" == "Flag_CutScoreChange_ELA" | "`var'" == "Flag_CutScoreChange_math" | "`var'" == "Flag_CutScoreChange_oth") & `year' == 2015
	replace `var' = "Y" if "`var'" == "Flag_CutScoreChange_oth" & `year' == 2019
}

//Empty Variables
gen AvgScaleScore = "--"

//Fixing Lev5_count and Lev5_percent
replace Lev5_count = "" if Subject != "sci"
replace Lev5_percent = "" if Subject != "sci"
replace Lev5_count = "" if Subject == "sci" & `year' > 2018
replace Lev5_percent = "" if Subject == "sci" & `year' > 2018

//StudentGroup_TotalTested
duplicates drop
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
sort StudentGroup
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"

//Supression
foreach var of varlist StudentSubGroup_TotalTested Lev* ParticipationRate {
	replace `var' = "*" if `var' == "--" & ProficientOrAbove_percent != "--"
}

//Dropping Empty Obs
drop if ProficientOrAbove_percent == "--"

**Unmerged 2023**
label def SchLevel -1 "Missing/not reported"
if `year' == 2023 {
//Colton Virtual Academy:
replace NCESSchoolID = "410327011349" if StateAssignedSchID == "5720"
replace NCESDistrictID = "4103270" if StateAssignedSchID == "5720"
replace DistType = 1 if StateAssignedSchID == "5720"
replace State_leaid = "OR-00000000001927" if StateAssignedSchID == "5720"
replace seasch = "00000000001927-00000000000000005720" if StateAssignedSchID == "5720"
replace DistCharter = "No" if StateAssignedSchID == "5720"
replace SchType = 1 if StateAssignedSchID == "5720"
replace SchLevel = 4 if StateAssignedSchID == "5720"
replace CountyName = "Clackamas County" if StateAssignedSchID == "5720"
replace CountyCode = 41005 if StateAssignedSchID == "5720"
replace SchVirtual = 0 if StateAssignedSchID == "5720"

//Loma Vista Elementary
replace NCESSchoolID = "410630011358" if StateAssignedSchID == "5717"
replace NCESDistrictID = "4106300" if StateAssignedSchID == "5717"
replace DistType = 1 if StateAssignedSchID == "5717"
replace State_leaid = "OR-00000000002206" if StateAssignedSchID == "5717"
replace seasch = "00000000002206-00000000000000005717" if StateAssignedSchID == "5717"
replace DistCharter = "No" if StateAssignedSchID == "5717"
replace SchType = 1 if StateAssignedSchID == "5717"
replace SchLevel = 1 if StateAssignedSchID == "5717"
replace CountyName = "Umatilla County" if StateAssignedSchID == "5717"
replace CountyCode = 41059 if StateAssignedSchID == "5717"
replace SchVirtual = 0 if StateAssignedSchID == "5717"

//Nyssa Virtual School
replace NCESSchoolID = "410900011355" if StateAssignedSchID == "5723"
replace NCESDistrictID = "4109000" if StateAssignedSchID == "5723"
replace DistType = 1 if StateAssignedSchID == "5723"
replace State_leaid = "OR-00000000002110" if StateAssignedSchID == "5723"
replace seasch = "00000000002110-00000000000000005723" if StateAssignedSchID == "5723"
replace DistCharter = "No" if StateAssignedSchID == "5723"
replace SchType = 1 if StateAssignedSchID == "5723"
replace SchLevel = -1 if StateAssignedSchID == "5723"
replace CountyName = "Malheur County" if StateAssignedSchID == "5723"
replace CountyCode = 41045 if StateAssignedSchID == "5723"
replace SchVirtual = 1 if StateAssignedSchID == "5723"

//Oliver Middle
replace NCESSchoolID = "410280011357" if StateAssignedSchID == "5721"
replace NCESDistrictID = "4102800" if StateAssignedSchID == "5721"
replace DistType = 1 if StateAssignedSchID == "5721"
replace State_leaid = "OR-00000000002185" if StateAssignedSchID == "5721"
replace seasch = "00000000002185-00000000000000005721" if StateAssignedSchID == "5721"
replace DistCharter = "No" if StateAssignedSchID == "5721"
replace SchType = 1 if StateAssignedSchID == "5721"
replace SchLevel = 2 if StateAssignedSchID == "5721"
replace CountyName = "Multnomah County" if StateAssignedSchID == "5721"
replace CountyCode = 41051 if StateAssignedSchID == "5721"
replace SchVirtual = 0 if StateAssignedSchID == "5721"

//Wallowa Middle School
replace NCESSchoolID = "411299011359" if StateAssignedSchID == "5728"
replace NCESDistrictID = "4112990" if StateAssignedSchID == "5728"
replace DistType = 1 if StateAssignedSchID == "5728"
replace State_leaid = "OR-00000000002220" if StateAssignedSchID == "5728"
replace seasch = "00000000002220-00000000000000005728" if StateAssignedSchID == "5728"
replace DistCharter = "No" if StateAssignedSchID == "5728"
replace SchType = 1 if StateAssignedSchID == "5728"
replace SchLevel = 2 if StateAssignedSchID == "5728"
replace CountyName = "Wallowa County" if StateAssignedSchID == "5728"
replace CountyCode = 41063 if StateAssignedSchID == "5728"
replace SchVirtual = 0 if StateAssignedSchID == "5728"
}


//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/OR_AssmtData_`year'", replace
export delimited "`Output'/OR_AssmtData_`year'", replace
clear


do OR_Cleaning_2021



clear
}
