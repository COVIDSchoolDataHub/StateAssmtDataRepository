clear
set more off
set trace off

local Original "/Volumes/T7/State Test Project/Idaho/Original Data"
local Output "/Volumes/T7/State Test Project/Idaho/Output"
local nces_school "/Volumes/T7/State Test Project/NCES/School"
local nces_district "/Volumes/T7/State Test Project/NCES/District"
local years 2015 2016 2017 2018 2019 2021 2022

foreach year of local years { //Run hidden code first

local prevyear =`=`year'-1'
/*
import excel using "`Original'/ID_OriginalData_`year'.xlsx", sheet("State of Idaho") firstrow

gen DataLevel = "State"
foreach var of varlist _all {
tostring `var', replace force
} 
save "`Original'/`year'_State", replace
import excel using "`Original'/ID_OriginalData_`year'.xlsx", sheet("Districts") firstrow clear
gen DataLevel = "District"
foreach var of varlist _all {
tostring `var', replace force
} 
save "`Original'/`year'_District", replace
import excel using "`Original'/ID_OriginalData_`year'.xlsx", sheet("Schools") firstrow clear
gen DataLevel = "School"
foreach var of varlist _all {
tostring `var', replace force
} 
save "`Original'/`year'_School", replace
*/
clear
use "`Original'/`year'_State"
append using "`Original'/`year'_District"
append using "`Original'/`year'_School"
*save "/Volumes/T7/State Test Project/Idaho/Testing/`year'", replace

//Standardizing Original Variable Names
if `year' == 2015 | `year' == 2016 | `year' == 2018 {
rename Display GradeLevel
}
else if `year' != 2017 {
rename Grade GradeLevel
}
rename SubjectName SubjectName
if `year' == 2015 | `year' == 2016 | `year' == 2017 {
rename PopulationName StudentSubGroup

}
else {
rename Population StudentSubGroup
}
if `year' == 2015 | `year' == 2016 | `year' == 2017 | `year' == 2018 {
rename Advanced Lev4_percent
rename Proficient Lev3_percent
rename Basic Lev2_percent
rename BelowBasic Lev1_percent
rename Participation ParticipationRate
}
else {
rename AdvancedRate Lev4_percent
rename ProficientRate Lev3_percent
rename BasicRate Lev2_percent
rename BelowBasic Lev1_percent
rename TestedRate ParticipationRate
}
rename DistrictId StateAssignedDistID
rename DistrictName DistName
rename SchoolId StateAssignedSchID
rename SchoolName SchName
rename SubjectName Subject

////Merging NCES Data////
//Leading Zeroes
replace StateAssignedSchID = "000" + StateAssignedSchID if strlen(StateAssignedSchID)==1
replace StateAssignedSchID = "00" + StateAssignedSchID if strlen(StateAssignedSchID)==2
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID)==3
replace StateAssignedDistID = "00" + StateAssignedDistID if strlen(StateAssignedDistID)==1
replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID)==2
replace StateAssignedDistID = "ID-" + StateAssignedDistID if DataLevel != "State" & `year' !=2015 & `year' !=2016
tempfile tempall
save "`tempall'", replace
//District Data
keep if DataLevel == "District"
tempfile tempdistrict
save "`tempdistrict'", replace
clear
use "`nces_district'/NCES_`prevyear'_District.dta"
keep if state_location == "ID"
gen StateAssignedDistID = state_leaid

merge 1:m StateAssignedDistID using "`tempdistrict'"
save "`tempdistrict'", replace
clear
//School Data
use "`tempall'"
keep if DataLevel == "School"
gen NOID = subinstr(StateAssignedDistID,"ID-","",.)
replace StateAssignedSchID = NOID + "-" + StateAssignedSchID if strpos(StateAssignedSchID,"-") ==0
tempfile tempschool
save "`tempschool'", replace
clear
use "`nces_school'/NCES_`prevyear'_School.dta"
keep if state_location == "ID"
gen StateAssignedSchID = seasch
gen NOID = subinstr(state_leaid,"ID-","",.)
replace StateAssignedSchID = NOID + "-" + StateAssignedSchID if strpos(StateAssignedSchID,"-") ==0
merge 1:m StateAssignedSchID using "`tempschool'"
save "`tempschool'", replace
clear
//Combining
use "`tempall'"
keep if DataLevel == "State"
append using "`tempdistrict'" "`tempschool'"
drop if _merge ==1
*save "/Volumes/T7/State Test Project/Idaho/Testing/`year'", replace
tab DistName if _merge == 2 & DataLevel == "District"
tab SchName if _merge ==2 & DataLevel == "School"

//StudentSubGroup
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup,"Asian") !=0
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup,"Black") !=0
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Economically Disadvantaged "
replace StudentSubGroup = "Not Economically Disadvantaged" if strpos(StudentSubGroup, "Not Economically Disadvantaged") !=0
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "American Indian or Alaskan Native") !=0
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not LEP"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two Or More") !=0
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ","",.)
keep if GradeLevel == "3" | GradeLevel == "4" | GradeLevel == "5" | GradeLevel == "6" | GradeLevel == "7" | GradeLevel == "8"
replace GradeLevel = "G0" + GradeLevel

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3


//Proficient or above percent


gen Range1 = ""
gen Range2 = ""
gen missing = ""
foreach n in 1 2 3 4 {
	gen Suppressed`n' = "*" if strpos(Lev`n'_percent,"*") !=0 | strpos(Lev`n'_percent, "NSIZE") !=0
	replace Range1 = substr(Lev`n'_percent,strpos(Lev`n'_percent,"<"),1)
	replace Range2 = substr(Lev`n'_percent,strpos(Lev`n'_percent,">"),1)
	replace missing = "Y" if Lev`n'_percent == "N/A"
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*NSIZE/A<>)
	replace nLev`n'_percent = nLev`n'_percent/100 if (`year' != 2017 & `year' != 2018)
	replace Lev`n'_percent = Range1 + Range2 + string(nLev`n'_percent, "%9.3f")
	replace Lev`n'_percent = "*" if Suppressed`n' == "*"
	replace Lev`n'_percent = "--" if missing == "Y"

}
gen ProficientOrAbove_percent = string(nLev3_percent + nLev4_percent, "%9.3f")
replace ProficientOrAbove_percent = "*" if Suppressed3 == "*" | Suppressed4 == "*"
replace ProficientOrAbove_percent = "--" if missing== "Y"
replace ParticipationRate = "--" if ParticipationRate == "N/A"
replace ParticipationRate = "*" if ParticipationRate == "NSIZE" | strpos(ParticipationRate, "*") !=0
destring ParticipationRate, gen(Part) i(*-)
replace Part = Part/100 if (`year' != 2017 & `year' != 2018)
replace ParticipationRate = string(Part, "%9.3f") if !missing(Part)
foreach n in 1 2 3 4 {
replace Lev`n'_percent = "--" if Lev`n'_percent == "*" & (Suppressed1 != Suppressed2 | Suppressed3 != Suppressed4 | Suppressed2 != Suppressed3)
}
replace ParticipationRate = "--" if Lev1_percent == "--" & Lev2_percent == "--" & Lev3_percent == "--" & Lev4_percent == "--"
drop Part

//Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"


//Misc Variables

di "`year'"
gen State = "Idaho"
gen StateAbbrev = "ID"
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)
foreach n in 1 2 3 4 {
gen Lev`n'_count = "--"
}
gen Lev5_percent = ""
gen Lev5_count = ""
gen AvgScaleScore = "--"
gen ProficientOrAbove_count = ""
gen StudentSubGroup_TotalTested = "--"
gen StudentGroup_TotalTested = "--"
gen ProficiencyCriteria = "Levels 3 and 4"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"
rename state_fips StateFips
replace StateFips = 16
rename district_agency_type DistType
rename school_type SchType
rename state_leaid State_leaid
rename ncesdistrictid NCESDistrictID
rename ncesschoolid NCESSchoolID
rename county_name CountyName
replace CountyName = proper(CountyName)
rename county_code CountyCode
gen AssmtName = "ISAT"
gen AssmtType = "Regular"

//Final cleaning and dropping extra variables
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/ID_AssmtData_`year'", replace
if `year' == 2015 | `year' == 2016 {
	export delimited using "`Output'/ID_AssmtData_`year'", replace
}

clear

}


