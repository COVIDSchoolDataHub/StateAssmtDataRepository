clear
set more off
local ID_Cleaning "/Volumes/T7/State Test Project/Idaho/ID_Cleaning.do"
local Original "/Volumes/T7/State Test Project/Idaho/Original Data"
local Output "/Volumes/T7/State Test Project/Idaho/Output"
local NCES_District "/Volumes/T7/State Test Project/NCES/District"
local years 2017 2018 2019 2021 2022
set trace off

//Extra Cleaning and Adding aggregate (G38) data for 2017, 2018, 2019, 2021, and 2022

do "`ID_Cleaning'"

foreach year of local years {
local prevyear =`=`year'-1'
if `year' == 2017 | `year' == 2018 {
import excel "`Original'/ID_OriginalDataG38ela_`year'", firstrow
gen Subject = "ela"
tempfile tempela_`year'
save "`tempela_`year''", replace
clear
import excel "`Original'/ID_OriginalDataG38math_`year'", firstrow
gen Subject = "math"
append using "`tempela_`year''"
rename LeaNumber StateAssignedDistID
}

else {
import excel "`Original'/ID_OriginalDataG38_`year'", firstrow
rename DistrictId StateAssignedDistID
}
replace StateAssignedDistID = "ID-" + StateAssignedDistID
tempfile temp1
save "`temp1'", replace
clear
use "`Output'/ID_AssmtData_`year'"
duplicates drop StateAssignedDistID, force
keep if DataLevel ==2
keep StateAssignedDistID NCESDistrictID State_leaid CountyName CountyCode DistType DistCharter State StateAbbrev StateFips SchYear DataLevel
merge 1:m StateAssignedDistID using "`temp1'"
drop if _merge ==1
if `year' == 2019 | `year' == 2021 | `year' == 2022 {
drop if missing(DistrictName)
rename DistrictName DistName
rename ELA_Advanced Lev4_percentela
rename ELA_Proficient Lev3_percentela
rename ELA_Basic Lev2_percentela
rename ELA_BelowBasic Lev1_percentela
rename Math_Advanced Lev4_percentmath
rename Math_Proficient Lev3_percentmath
rename Math_Basic Lev2_percentmath
rename Math_BelowBasic Lev1_percentmath
reshape long Lev4_percent Lev3_percent Lev2_percent Lev1_percent, i(StateAssignedDistID) j(Subject, string)
gen SUP = ""
foreach var of varlist _all {
cap replace `var' = "*" if `var' == "NSIZE"
cap replace SUP = "*" if `var' == "*"
}
foreach n in 1 2 3 4 {
gen Lev`n'_count = "--"
destring Lev`n'_percent, replace i(*)
}
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
gen perc_string = string(ProficientOrAbove_percent, "%9.4f")
drop ProficientOrAbove_percent
rename perc_string ProficientOrAbove_percent
replace ProficientOrAbove_percent = SUP if !missing(SUP)
foreach n in 1 2 3 4 {
gen string`n' = string(Lev`n'_percent, "%9.4f")
drop Lev`n'_percent
rename string`n' Lev`n'_percent
replace Lev`n'_percent = SUP if !missing(SUP)
}
}

else {
drop if missing(LeaName)
rename LeaName DistName
foreach n in 1 2 3 4 {
rename Level`n' Lev`n'_count
}
rename BelowBasic Lev1_percent
rename Basic Lev2_percent
rename Proficient Lev3_percent
rename Advanced Lev4_percent
gen SUP = "" 
foreach var of varlist _all {
cap replace `var' = "*" if `var' == "NSIZE"
cap replace SUP = "*" if `var' == "*"
}

foreach n in 1 2 3 4 {
destring Lev`n'_percent, replace i(*)
destring Lev`n'_count, replace i(*)
}
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
gen ProficientOrAbove_count = Lev3_count + Lev4_count
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = SUP if !missing(SUP)
gen perc_string = string(ProficientOrAbove_percent, "%9.4f")
drop ProficientOrAbove_percent
rename perc_string ProficientOrAbove_percent
replace ProficientOrAbove_percent = SUP if !missing(SUP)

foreach n in 1 2 3 4 {
gen stringperc`n' = string(Lev`n'_percent, "%9.4f")
drop Lev`n'_percent
rename stringperc`n' Lev`n'_percent
tostring Lev`n'_count, replace
replace Lev`n'_count = SUP if !missing(SUP)
replace Lev`n'_percent = SUP if !missing(SUP)
}

}


//Fixing Variables
gen GradeLevel = "G38"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested= "--"
gen StudentSubGroup_TotalTested = "--"
gen AvgScaleScore = "--"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA= "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_oth = "N"
gen SchName = "All Schools"
gen AssmtName = "ISAT"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3 and 4"
gen ParticipationRate = "--"
//Adding to other data
append using "`Output'/ID_AssmtData_`year'"
replace State = "Idaho"
replace StateAbbrev = "ID"
replace SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)
replace StateFips = 16


//Charter schools listed in G38 data are unmerged. G38 data has them as Districts, whereas other original data and NCES has them as Schools. There is no comparable district nces data, so leaving as "Missing/not reported" for now. Not a problem for 2021 and 2022.
replace DistType = 7 if missing(DataLevel) & GradeLevel == "G38"
replace DistCharter = "Yes" if missing(DataLevel) & GradeLevel == "G38"
replace State_leaid = "Missing/not reported" if missing(DataLevel) & GradeLevel == "G38"
replace CountyName = "Missing/not reported" if missing(DataLevel) & GradeLevel == "G38"
replace CountyCode = 0 if missing(DataLevel) & GradeLevel == "G38"
replace DataLevel = 2 if missing(DataLevel) & GradeLevel == "G38"



//Final cleaning and dropping extra variables
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/ID_AssmtData_`year'", replace
export delimited using "`Output'/ID_AssmtData_`year'", replace
clear

}
