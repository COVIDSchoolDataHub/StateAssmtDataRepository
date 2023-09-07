clear
set more off
cd "/Volumes/T7/State Test Project/Alabama/Output"
local NCES "/Volumes/T7/State Test Project/NCES/School"

use "`NCES'/NCES_2014_School"
keep if state_fips==1
keep if strpos(school_name, "Eichold") !=0
gen StateAssignedSchID = "049-0506"
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
merge 1:m StateAssignedSchID using AL_AssmtData_2016, nogen
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
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

//NCESSchoolID for unmerged 2023
replace NCESSchoolID = "10039002553" if StateAssignedSchID == "114-0025"
replace NCESSchoolID = "10081002545" if StateAssignedSchID == "016-0045"
replace NCESSchoolID = "10358202558" if StateAssignedSchID == "811-0010"
replace NCESSchoolID = "10358102554" if StateAssignedSchID == "174-0010"
replace NCESSchoolID = "10358102555" if StateAssignedSchID == "174-0020"

//DistType (all unmerged are regular)
replace DistType = 1 if missing(DistType) & DataLevel !=1

//SchType (all unmerged are regular)
replace SchType = 1 if missing(SchType) & DataLevel ==3

//State_leaid
replace State_leaid = "AL-" + StateAssignedDistID if missing(State_leaid) & DataLevel !=1

//CountyName
replace CountyName = "Missing/not reported" if missing(CountyName) & DataLevel !=1
replace CountyName = "Coffee County" if StateAssignedSchID == "016-0045"

//CountyCode
replace CountyCode = 0 if missing(CountyCode) & DataLevel !=1

//DistCharter
replace DistCharter = "Yes" if StateAssignedDistID == "811"
replace DistCharter = "No" if StateAssignedDistID == "174"
replace DistCharter = "No" if StateAssignedSchID == "114-0025"
replace DistCharter = "No" if StateAssignedSchID == "016-0045"
replace DistCharter = "Yes" if StateAssignedSchID == "811-0010"
replace DistCharter = "No" if StateAssignedSchID == "174-0010"
replace DistCharter = "No" if StateAssignedSchID == "174-0020"

//SchLevel
replace SchLevel = 4 if StateAssignedSchID == "114-0025"
replace SchLevel = 2 if StateAssignedSchID == "016-0045"
replace SchLevel = 1 if StateAssignedSchID == "811-0010"
replace SchLevel = 1 if StateAssignedSchID == "174-0010"
replace SchLevel = 2 if StateAssignedSchID == "174-0020"

//SchVirtual
replace SchVirtual = 1 if StateAssignedSchID == "114-0025"
replace SchVirtual = 0 if StateAssignedSchID == "016-0045"
replace SchVirtual = 0 if StateAssignedSchID == "811-0010"
replace SchVirtual = 0 if StateAssignedSchID == "174-0010"
replace SchVirtual = 0 if StateAssignedSchID == "174-0020"

//Exporting
save "AL_AssmtData_2023", replace
export delimited "AL_AssmtData_2023", replace
clear




