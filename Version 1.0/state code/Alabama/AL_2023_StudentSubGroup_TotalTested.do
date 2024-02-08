clear
set more off

cd "/Volumes/T7/State Test Project/Alabama/Output"

//Replacing 2023 with empty
use AL_AssmtData_2023

replace StudentSubGroup_TotalTested = ""
replace StudentGroup_TotalTested = ""
tempfile temp1
save "`temp1'", replace
clear

//Merging 2022
use AL_AssmtData_2022
keep StudentGroup_TotalTested StudentSubGroup_TotalTested DataLevel NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject
merge 1:1 DataLevel NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject using "`temp1'", update
replace StudentSubGroup_TotalTested = "*" if _merge == 2
replace StudentGroup_TotalTested = "*" if _merge == 2
drop if _merge == 1

//Saving and Exporting
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "AL_AssmtData_2023", replace
export delimited "AL_AssmtData_2023", replace


