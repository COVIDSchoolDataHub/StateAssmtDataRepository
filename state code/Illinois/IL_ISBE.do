clear
set more off

global path "/Users/willtolmie/Documents/State Repository Research/Illinois"

** 2022 Data

import excel "${path}/ISBE/FY2022-Fall-Enroll-Report.xlsx", sheet("Home District Summary") firstrow clear
gen DataLevel = "District"
save tmp.dta, replace
import excel "${path}/ISBE/FY2022-Fall-Enroll-Report.xlsx", sheet("Serving District Summary") firstrow clear
gen DataLevel = "District"
append using tmp.dta
save tmp.dta, replace
import excel "${path}/ISBE/FY2022-Fall-Enroll-Report.xlsx", sheet("Serving District Public") firstrow clear
gen DataLevel = "District"
append using tmp.dta
save tmp.dta, replace
import excel "${path}/ISBE/FY2022-Fall-Enroll-Report.xlsx", sheet("Serving District Other") firstrow clear
gen DataLevel = "District"
append using tmp.dta
save tmp.dta, replace
import excel "${path}/ISBE/FY2022-Fall-Enroll-Report.xlsx", sheet("Serving School Summary ") firstrow clear
gen DataLevel = "School"
append using tmp.dta
save tmp.dta, replace
import excel "${path}/ISBE/FY2022-Fall-Enroll-Report.xlsx", sheet("Serving School Public") firstrow clear
gen DataLevel = "School"
append using tmp.dta
save tmp.dta, replace
import excel "${path}/ISBE/FY2022-Fall-Enroll-Report.xlsx", sheet("Serving School Other") firstrow clear
gen DataLevel = "School"
append using tmp.dta
save tmp.dta, replace
keep RCDTS SchoolName DistrictName Grade3 Grade4 Grade5 Grade6 Grade7 Grade8 DataLevel
gen StateAssignedSchID = RCDTS
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 14
generate str StateAssignedDistID = substr(StateAssignedSchID, 1, strlen(StateAssignedSchID) - 4)
generate id = _n
reshape long Grade, i(id) j(g, string)
rename Grade Enrollment
rename g GradeLevel
drop id
replace GradeLevel = "G0" + GradeLevel
replace StateAssignedSchID = "" if DataLevel == "District"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
duplicates drop
bysort DataLevel StateAssignedDistID StateAssignedSchID GradeLevel : gen tag = _n == 1
drop if tag != 1
drop tag
save tmp.dta, replace

import delimited "/Users/willtolmie/Documents/State Repository Research/Illinois/Output/IL_AssmtData_2022.csv", case(preserve) clear 
merge m:1 DataLevel StateAssignedDistID StateAssignedSchID GradeLevel StudentGroup StudentSubGroup using tmp.dta
drop if _merge == 2
drop _merge
replace StudentGroup_TotalTested = Enrollment if Enrollment != ""
replace StudentSubGroup_TotalTested = Enrollment if Enrollment != ""

save tmp.dta, replace
keep if Data == "District"
keep if StudentGroup == "All Students"
replace StudentGroup_TotalTested = "5" if StudentGroup_TotalTested == "<10"
destring StudentGroup_TotalTested, replace force
collapse (sum) StudentGroup_TotalTested, by(GradeLevel)
replace StudentGroup_TotalTested = round(StudentGroup_TotalTested)
rename StudentGroup_TotalTested StudentGroup_TotalTestedState
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen DataLevel = "State"
save tmp2.dta, replace
use tmp.dta
merge m:1 DataLevel GradeLevel StudentGroup StudentSubGroup using tmp2.dta
tostring StudentGroup_TotalTestedState, replace force
replace StudentGroup_TotalTested = StudentGroup_TotalTestedState if StudentGroup_TotalTestedState != "."
replace StudentSubGroup_TotalTested = StudentGroup_TotalTestedState if StudentGroup_TotalTestedState != "."

** Label Variables

label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var SchYear "School year in which the data were reported. (e.g., 2021-22)"
label var AssmtName "Name of state assessment"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var DistCharter "Charter indicator - district"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested (Individual grade levels, Gr3-8, all grades)"
label var StudentGroup "Student demographic group"
label var StudentSubGroup "Student demographic subgroup"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested."
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested."
label var Lev1_count "Count of students within subgroup performing at Level 1."
label var Lev1_percent "Percent of students within subgroup performing at Level 1."
label var Lev2_count "Count of students within subgroup performing at Level 2."
label var Lev2_percent "Percent of students within subgroup performing at Level 2."
label var Lev3_count "Count of students within subgroup performing at Level 3."
label var Lev3_percent "Percent of students within subgroup performing at Level 3 ."
label var Lev4_count "Count of students within subgroup performing at Level 4."
label var Lev4_percent "Percent of students within subgroup performing at Level 4."
label var Lev5_count "Count of students within subgroup performing at Level 5."
label var Lev5_percent "Percent of students within subgroup performing at Level 5."
label var AvgScaleScore "Avg scale score within subgroup."
label var ProficiencyCriteria "Levels included in determining proficiency status."
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment."
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment."
label var ParticipationRate "Participation rate."
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var CountyName "County in which the district or school is located."
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var DistType "District type as defined by NCES"
label var NCESDistrictID "NCES district ID"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only."
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."

** Fix Variable Order 
	
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

** Export Assessment Data

save "${path}/EDFacts Output/IL_AssmtData_2022.dta", replace
export delimited using "${path}/EDFacts Output/IL_AssmtData_2022.csv", replace
	
clear

** 2023 Data

import excel "${path}/ISBE/FY2023-Fall-Enroll-Report.xlsx", sheet("Home District") firstrow allstring clear
gen DataLevel = "District"
save tmp.dta, replace
import excel "${path}/ISBE/FY2023-Fall-Enroll-Report.xlsx", sheet("Serving District Summary") firstrow allstring clear
gen DataLevel = "District"
append using tmp.dta
save tmp.dta, replace
import excel "${path}/ISBE/FY2023-Fall-Enroll-Report.xlsx", sheet("Serving District Public") firstrow allstring clear
gen DataLevel = "District"
append using tmp.dta
save tmp.dta, replace
import excel "${path}/ISBE/FY2023-Fall-Enroll-Report.xlsx", sheet("Serving District Other") firstrow allstring clear
gen DataLevel = "District"
append using tmp.dta
save tmp.dta, replace
import excel "${path}/ISBE/FY2023-Fall-Enroll-Report.xlsx", sheet("Home School") firstrow allstring clear
gen DataLevel = "School"
append using tmp.dta
save tmp.dta, replace
import excel "${path}/ISBE/FY2023-Fall-Enroll-Report.xlsx", sheet("Serving School Summary") firstrow allstring clear
gen DataLevel = "School"
append using tmp.dta
save tmp.dta, replace
import excel "${path}/ISBE/FY2023-Fall-Enroll-Report.xlsx", sheet("Serving School Public") firstrow allstring clear
gen DataLevel = "School"
append using tmp.dta
save tmp.dta, replace
import excel "${path}/ISBE/FY2023-Fall-Enroll-Report.xlsx", sheet("Serving School Other") firstrow allstring clear
gen DataLevel = "School"
append using tmp.dta
save tmp.dta, replace
keep RCDTS SchoolName DistrictName Grade3 Grade4 Grade5 Grade6 Grade7 Grade8 DataLevel
gen StateAssignedSchID = RCDTS
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 14
generate str StateAssignedDistID = substr(StateAssignedSchID, 1, strlen(StateAssignedSchID) - 4)
generate id = _n
reshape long Grade, i(id) j(g, string)
rename Grade Enrollment
rename g GradeLevel
drop id
replace GradeLevel = "G0" + GradeLevel
replace StateAssignedSchID = "" if DataLevel == "District"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
duplicates drop
bysort DataLevel StateAssignedDistID StateAssignedSchID GradeLevel : gen tag = _n == 1
drop if tag != 1
drop tag
save tmp.dta, replace

import delimited "/Users/willtolmie/Documents/State Repository Research/Illinois/Output/IL_AssmtData_2023.csv", case(preserve) clear 
merge m:1 DataLevel StateAssignedDistID StateAssignedSchID GradeLevel StudentGroup StudentSubGroup using tmp.dta
drop if _merge == 2
drop _merge
replace StudentGroup_TotalTested = Enrollment if Enrollment != ""
replace StudentSubGroup_TotalTested = Enrollment if Enrollment != ""

save tmp.dta, replace
keep if Data == "District"
keep if StudentGroup == "All Students"
replace StudentGroup_TotalTested = "5" if StudentGroup_TotalTested == "<10"
destring StudentGroup_TotalTested, replace force
collapse (sum) StudentGroup_TotalTested, by(GradeLevel)
replace StudentGroup_TotalTested = round(StudentGroup_TotalTested)
rename StudentGroup_TotalTested StudentGroup_TotalTestedState
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen DataLevel = "State"
save tmp2.dta, replace
use tmp.dta
merge m:1 DataLevel GradeLevel StudentGroup StudentSubGroup using tmp2.dta
tostring StudentGroup_TotalTestedState, replace force
replace StudentGroup_TotalTested = StudentGroup_TotalTestedState if StudentGroup_TotalTestedState != "."
replace StudentSubGroup_TotalTested = StudentGroup_TotalTestedState if StudentGroup_TotalTestedState != "."

** Label Variables

label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var SchYear "School year in which the data were reported. (e.g., 2021-22)"
label var AssmtName "Name of state assessment"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var DistCharter "Charter indicator - district"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested (Individual grade levels, Gr3-8, all grades)"
label var StudentGroup "Student demographic group"
label var StudentSubGroup "Student demographic subgroup"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested."
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested."
label var Lev1_count "Count of students within subgroup performing at Level 1."
label var Lev1_percent "Percent of students within subgroup performing at Level 1."
label var Lev2_count "Count of students within subgroup performing at Level 2."
label var Lev2_percent "Percent of students within subgroup performing at Level 2."
label var Lev3_count "Count of students within subgroup performing at Level 3."
label var Lev3_percent "Percent of students within subgroup performing at Level 3 ."
label var Lev4_count "Count of students within subgroup performing at Level 4."
label var Lev4_percent "Percent of students within subgroup performing at Level 4."
label var Lev5_count "Count of students within subgroup performing at Level 5."
label var Lev5_percent "Percent of students within subgroup performing at Level 5."
label var AvgScaleScore "Avg scale score within subgroup."
label var ProficiencyCriteria "Levels included in determining proficiency status."
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment."
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment."
label var ParticipationRate "Participation rate."
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var CountyName "County in which the district or school is located."
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var DistType "District type as defined by NCES"
label var NCESDistrictID "NCES district ID"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only."
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."

** Fix Variable Order 
	
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

** Export Assessment Data

save "${path}/EDFacts Output/IL_AssmtData_2023.dta", replace
export delimited using "${path}/EDFacts Output/IL_AssmtData_2023.csv", replace
