clear
set more off
set trace off
cd "/Users/miramehta/Documents/AL State Testing Data/Output"
local NCES "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"


use "`NCES'/NCES_2014_School"
keep if state_fips==1
keep if strpos(school_name, "Eichold") !=0
gen StateAssignedSchID = "049-0506"
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
drop SchType
rename SchType_str SchType
drop SchLevel
rename SchLevel_str SchLevel
drop SchVirtual
rename SchVirtual_str SchVirtual
merge 1:m StateAssignedSchID using AL_AssmtData_2016, nogen
save "AL_AssmtData_2016", replace
clear

use AL_AssmtData_2016

foreach var of varlist NCESSchoolID NCESDistrictID DistType DistCharter SchType SchVirtual SchLevel CountyName State_leaid seasch {
 replace `var' = "Missing/not reported" if StateAssignedSchID == "049-0266"
}
replace CountyCode = "0" if StateAssignedSchID == "049-0266"


order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "AL_AssmtData_2016", replace
export delimited "AL_AssmtData_2016", replace
clear

use AL_AssmtData_2023

//NCESDistrictID for unmerged 2023
replace NCESDistrictID = "103582" if StateAssignedDistID == "811"
replace NCESDistrictID = "103581" if StateAssignedDistID == "174"
replace NCESDistrictID = "100390" if StateAssignedSchID == "114-0025"
replace NCESDistrictID = "100810" if StateAssignedSchID == "016-0045"
replace NCESDistrictID = "103582" if StateAssignedSchID == "811-0010"
replace NCESDistrictID = "103581" if StateAssignedSchID == "174-0010"
replace NCESDistrictID = "103581" if StateAssignedSchID == "174-0020"
replace NCESDistrictID = "100270" if StateAssignedSchID == "002-0141"
replace NCESDistrictID = "102010" if StateAssignedSchID == "039-0035"
replace NCESDistrictID = "102010" if StateAssignedSchID == "039-0075"
replace NCESDistrictID = "102010" if StateAssignedSchID == "039-0085"
replace NCESDistrictID = "102010" if StateAssignedSchID == "039-0115"
replace NCESDistrictID = "102010" if StateAssignedSchID == "039-0145"
replace NCESDistrictID = "100199" if StateAssignedSchID == "801-0020"

//NCESSchoolID for unmerged 2023
replace NCESSchoolID = "10039002553" if StateAssignedSchID == "114-0025"
replace NCESSchoolID = "10081002545" if StateAssignedSchID == "016-0045"
replace NCESSchoolID = "10358202558" if StateAssignedSchID == "811-0010"
replace NCESSchoolID = "10358102554" if StateAssignedSchID == "174-0010"
replace NCESSchoolID = "10358102555" if StateAssignedSchID == "174-0020"
replace NCESSchoolID = "10027002544" if StateAssignedSchID == "002-0141"
replace NCESSchoolID = "10201002547" if StateAssignedSchID == "039-0035"
replace NCESSchoolID = "10201002548" if StateAssignedSchID == "039-0075"
replace NCESSchoolID = "10201002549" if StateAssignedSchID == "039-0085"
replace NCESSchoolID = "10201002550" if StateAssignedSchID == "039-0115"
replace NCESSchoolID = "10201002551" if StateAssignedSchID == "039-0145"
replace NCESSchoolID = "10019902557" if StateAssignedSchID == "801-0020"

//DistType
replace DistType = "Regular local school district" if missing(DistType) & DataLevel !=1
replace DistType = "Charter agency" if StateAssignedSchID == "801-0020"

//SchType (all unmerged are regular)
replace SchType = 1 if missing(SchType) & DataLevel ==3

//CountyName
replace CountyName = "Missing/not reported" if missing(CountyName) & DataLevel !=1
replace CountyName = "Coffee County" if StateAssignedSchID == "016-0045"
replace CountyName = "Baldwin County" if StateAssignedSchID == "002-0141"
replace CountyName = "Lauderdale County" if StateAssignedDistID == "039"


//CountyCode
replace CountyCode = "0" if missing(CountyCode) & DataLevel !=1
replace CountyCode = "1003" if StateAssignedSchID == "002-0141"
replace CountyCode = "1077" if StateAssignedDistID == "039"

//DistCharter
replace DistCharter = "Yes" if StateAssignedDistID == "811"
replace DistCharter = "No" if StateAssignedDistID == "174"
replace DistCharter = "No" if StateAssignedSchID == "114-0025"
replace DistCharter = "No" if StateAssignedSchID == "016-0045"
replace DistCharter = "Yes" if StateAssignedSchID == "811-0010"
replace DistCharter = "No" if StateAssignedSchID == "174-0010"
replace DistCharter = "No" if StateAssignedSchID == "174-0020"
replace DistCharter = "No" if StateAssignedSchID == "002-0141"
replace DistCharter = "No" if StateAssignedDistID == "039"
replace DistCharter = "Yes" if StateAssignedSchID == "801-0020"

//SchLevel
replace SchLevel = 4 if StateAssignedSchID == "114-0025"
replace SchLevel = 2 if StateAssignedSchID == "016-0045"
replace SchLevel = 1 if StateAssignedSchID == "811-0010"
replace SchLevel = 1 if StateAssignedSchID == "174-0010"
replace SchLevel = 2 if StateAssignedSchID == "174-0020"
replace SchLevel = 1 if StateAssignedSchID == "002-0141"
replace SchLevel = 1 if StateAssignedDistID == "039"
replace SchLevel = 2 if StateAssignedSchID == "801-0020"

//SchVirtual
replace SchVirtual = 1 if StateAssignedSchID == "114-0025"
replace SchVirtual = 0 if StateAssignedSchID == "016-0045"
replace SchVirtual = 0 if StateAssignedSchID == "811-0010"
replace SchVirtual = 0 if StateAssignedSchID == "174-0010"
replace SchVirtual = 0 if StateAssignedSchID == "174-0020"
replace SchVirtual = 0 if StateAssignedSchID == "002-0141"
replace SchVirtual = 0 if StateAssignedDistID == "039"
replace SchVirtual = 0 if StateAssignedSchID == "801-0020"

//District Level Data
replace SchVirtual = . if DataLevel == 2
replace SchLevel = . if DataLevel == 2

//Exporting
save "AL_AssmtData_2023", replace
export delimited "AL_AssmtData_2023", replace
clear




