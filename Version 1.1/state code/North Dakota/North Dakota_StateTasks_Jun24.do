clear
set more off

cd "/Volumes/T7/State Test Project/North Dakota/Output"

//Importing and Saving

/*
forvalues year = 2015/2023 {
	if `year' == 2020 continue
	import delimited "ND_AssmtData_`year'", case(preserve) stringcols(_all) clear
	save "ND_AssmtData_`year'", replace

}
*/

foreach year in 2015 2022 2023 {
	if `year' == 2020 continue
use "ND_AssmtData_`year'", clear
	
//Adding Flags for 2015
if `year' == 2015 replace Flag_AssmtNameChange = "Y" if Subject == "ela" | Subject == "math"

//Applying new StudentGroup_TotalTested Convention and Deriving Counts for 2022 & 2023

if `year' >= 2022 {
drop StudentGroup_TotalTested

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

destring StudentSubGroup_TotalTested, gen(UnsuppressedSSG) force
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup GradeLevel Subject DistName SchName)
order Subject GradeLevel StudentGroup_TotalTested UnsuppressedSG StudentGroup StudentSubGroup UnsuppressedSSG StudentSubGroup

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested) - UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & !missing(real(StudentGroup_TotalTested)) & UnsuppressedSG !=0 & (real(StudentGroup_TotalTested) - UnsuppressedSG) > 0 & StudentSubGroup == "English Proficient"

foreach count of varlist *_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(`percent')) & missing(real(`count'))
}
}


	
//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
	
	
	
save "ND_AssmtData_`year'", replace
export delimited "ND_AssmtData_`year'", replace	
}	

