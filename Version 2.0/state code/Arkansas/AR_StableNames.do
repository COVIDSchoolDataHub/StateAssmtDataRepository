clear
set more off

//Importing

import excel "ar_full-dist-sch-stable-list_through2023.xlsx", firstrow case(preserve) allstring

//Fixing DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

save "${Temp}/AR_StableNames_Sch", replace
duplicates drop NCESDistrictID SchYear, force
drop NCESSchoolID newschname olddistname oldschname
gen SchName = "All Schools"
replace DataLevel = 2

append using "${Temp}/AR_StableNames_Sch"
sort DataLevel
duplicates drop SchYear DataLevel NCESDistrictID NCESSchoolID, force
replace NCESDistrictID = "0" + NCESDistrictID
replace NCESSchoolID = "0" + NCESSchoolID if DataLevel == 3

save "${Temp}/AR_StableNames", replace
clear


//Looping Through Years
forvalues year = 2009/2023 {
	if `year' == 2020 continue
use "${Temp}/AR_StableNames"
local prevyear = `=`year'-1'
keep if SchYear == "`prevyear'-" + substr("`year'",-2,2)
merge 1:m DataLevel NCESDistrictID NCESSchoolID using "${Output}/AR_AssmtData_`year'", update
drop if _merge == 1
replace DistName = newdistname if DataLevel !=1 & !missing(newdistname)
replace SchName = newschname if DataLevel == 3 & !missing(newschname)
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel ==1



//Final Cleaning and Saving
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup	
save "${Output}/AR_AssmtData_`year'", replace
export delimited "${Output}/AR_AssmtData_`year'", replace
clear
}
