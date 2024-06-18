clear
set more off

global Original "/Volumes/T7/State Test Project/Arizona/Original Data"
global Output "/Volumes/T7/State Test Project/Arizona/Output"

//Loop Example
forvalues year = 2017/2017 {  //List beginning and end years here in the loop

** Unhide Code on First Run
/*
	import delimited "${Original}/AZ_AssmtData_`year'.csv", case(preserve) clear
	save "${Original}/AZ_Assmt_`year'.dta", replace
	clear
	import delimited "${Original}/AZ_ParticipationRate_`year'", case(preserve) clear
	save "${Original}/AZ_ParticipationRate_`year'", replace
	clear
*/

use "${Original}/AZ_ParticipationRate_`year'", clear

//Rename & drop Variables
rename SchoolYear SchYear
rename NCESLEAID NCESDistrictID
rename LEA DistName
rename School SchName
rename NCESSCHID NCESSchoolID
drop DataGroup
keep if DataDescription == "Students Participating by Program Type"
drop DataDescription
rename Value ParticipationRate_1
drop Denominator Numerator
rename Population StudentSubGroup
rename AgeGrade GradeLevel

//Some Basic Cleaning Commands

//Subinstr

replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.) //Converts Grade Level values from something like "Grade 8" to "G08"

//Replace with a condition example
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migratory Students"
//should be done for all subgroups. in the edfacts file to match with the existing values in StudentSubGroup. The values are linked in the Participation Rate spreadsheet under the "File Format" tab.

//Numeric to String Conversion Examples (variable formats in both files must match)
tostring NCESDistrictID, replace

//"NCESSchoolID cannot be converted reversibily..."
format NCESSchoolID %18.3g
tostring NCESSchoolID, replace usedisplayformat

//String to Numeric Conversion
destring NCESDistrictID, replace //options: force, ignore(),

//A Basic Loop. This one replaces NCESDistrictID & NCESSchoolID with nothing if it equals ".". You could also use NCES* rather than writing out NCESDistrictID NCESSchoolID (with the "*" as a wildcard for both NCESDistrictID & NCESSchoolID)
foreach var of varlist NCESDistrictID NCESSchoolID {
	replace `var' = "" if `var' == "."
}

//Merge Example

merge 1:1 SchYear NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel using "${Original}/AZ_AssmtData_`year'"
drop if _merge == 1 //Drops extra edfacts data that wasn't merged with the original data

//Replace old ParticipationRate data with new
replace ParticipationRate = ParticipationRate_1 if !missing(ParticipationRate_1)
drop ParticipationRate_1

//Final Cleaning Code (should run at the end of every do-file)
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/AZ_AssmtData_2017", replace
export delimited "${Output}/AZ_AssmtData_2017.csv", replace








}
