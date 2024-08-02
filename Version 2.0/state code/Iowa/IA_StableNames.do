clear
set more off

cd "/Volumes/T7/State Test Project/Iowa" //make sure the file "new dist names for zelma.dta" located in the Review folder is saved here

global Output_NoStableNames "/Volumes/T7/State Test Project/Iowa/Old Output"
global Output_StableNames "/Volumes/T7/State Test Project/Iowa/Output with stable names"

//Hide below code if you already have output in .dta format

/*

forvalues year = 2004/2023 {
	if `year' == 2020 continue 
	import delimited "${Output_NoStableNames}/IA_AssmtData_`year'", case(preserve) clear
	
	
	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(nDataLevel) label(DataLevel)
	drop DataLevel
	rename nDataLevel DataLevel
	sort DataLevel
	
	format NCESSchoolID %18.0g
	tostring NCES*, replace usedisplayformat
	replace NCESSchoolID = "" if DataLevel !=3
	replace NCESDistrictID = "" if DataLevel == 1
		
	save "${Output_NoStableNames}/IA_AssmtData_`year'", replace
}

*/

//Clean new dist names a little
use "new dist names for zelma", clear

tostring NCESDistrictID, replace

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel

replace newdistname = "Prescott Comm School District" if NCESDistrictID == "1923760"

save "new dist names for zelma", replace

//Merge in new DistNames

forvalues year = 2004/2023 {
	if `year' == 2020 continue
	
use "${Output_NoStableNames}/IA_AssmtData_`year'", clear
	
merge m:1 SchYear NCESDistrictID using "new dist names for zelma", gen(NameMerge)
drop if NameMerge == 2
	
replace DistName = newdistname if DataLevel !=1 & !missing(newdistname)
	
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	

save "${Output_StableNames}/IA_AssmtData_`year'", replace
export delimited "${Output_StableNames}/IA_AssmtData_`year'", replace
}



	

