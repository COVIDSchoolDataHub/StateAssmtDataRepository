clear
set more off
cd "/Volumes/T7/State Test Project/MD R3 Response/Output"

forvalues year = 2015/2018 {
use MD_AssmtData_`year'	

di "~~~~~~~~"
di "`year'"
di "~~~~~~~~"

	
//General Cleaning (NEW FORMATTING)

if `year' ==2021 {
tostring Lev4_count, replace
replace Lev4_count = "--"
tostring Lev4_percent, replace
replace Lev4_percent = "--"
}

//GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08", "G38")

//NCES
cap noisily replace NCESSchoolID = "Missing/not reported" if !regexm(NCESSchoolID, "[0-9]") & DataLevel == "School"

//ParticipationRate
replace ParticipationRate = "--" //Keeping ParticipationRate at "--" for now


//Data not dropped correctly
drop if SchName == "School Name"

//2016 Missing NCES
if `year' == 2016 drop if NCESSchoolID == "Missing/not reported"

//2021 StudentSubGroup / StudentGroup
replace StudentGroup = "RaceEth" if StudentGroup == "Two or more"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more"

//Flags
replace Flag_AssmtNameChange = "Y" if `year' == 2015
replace Flag_AssmtNameChange = "N" if AssmtName == "PARCC" & `year' == 2018
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2015
replace Flag_CutScoreChange_math = "Y" if `year' == 2015
replace Flag_CutScoreChange_oth = "" if `year' == 2017
replace Flag_CutScoreChange_oth = "Y" if `year' == 2015 | `year' == 2018

//Supression and Missing
foreach var of varlist Lev* ProficientOrAbove_percent {
	replace `var' = "*" if `var' == "."
}

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save MD_AssmtData_`year', replace
export delimited MD_AssmtData_`year', replace
clear
}
