*******************************************************
* ARIZONA

* File name: 18_AZ_EDFactsParticipation_2022
* Last update: 2/20/2025

*******************************************************
* Notes

	* This do file merges AZ EDFacts data for 2022 with the derived output for the same year. 
	
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear

** Preparing EDFacts files

foreach s in ela math sci {
	import delimited "${Original}/AZ_EFParticipation_2022_`s'.csv", case(preserve) clear
	save "${Original}/AZ_EFParticipation_2022_`s'.dta", replace
}

use "${Original}/AZ_EFParticipation_2022_ela.dta"
append using "${Original}/AZ_EFParticipation_2022_math.dta" "${Original}/AZ_EFParticipation_2022_sci.dta"

//Rename and Drop Vars
drop SchoolYear State
rename NCESLEAID NCESDistrictID
drop LEA School
rename NCESSCHID NCESSchoolID
rename Value Participation
drop DataGroup DataDescription Denominator Numerator Population
rename Subgroup StudentSubGroup
replace StudentSubGroup = Characteristics if missing(StudentSubGroup) & !missing(Characteristics)
rename AgeGrade GradeLevel
rename AcademicSubject Subject
drop ProgramType Outcome Characteristics

//Clean ParticipationRate
replace Participation = "*" if Participation == "S"	
gen rangeParticipation = substr(Participation,1,1) if regexm(Participation,"[<>]") !=0
replace Participation = subinstr(Participation, "=","",.)
split Participation, parse("-")
destring Participation1, replace i(*%<>-)
destring Participation2, replace i(*%<>-)
replace Participation = rangeParticipation + string(Participation1/100, "%9.3g") if !inlist(Participation, "*",  "--") & Participation2 == .
replace Participation = string(Participation1/100, "%9.3g") + "-" + string(Participation2/100, "%9.3g") if !inlist(Participation, "*",  "--") & Participation2 != .
replace Participation = subinstr(Participation,">","",.) + "-1" if strpos(Participation, ">") !=0
replace Participation = subinstr(Participation, "<","0-",.) if strpos(Participation, "<") !=0
drop rangeParticipation Participation1 Participation2

//StudentSubGroup
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All Students") !=0
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/Alaska Native/Native American"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black (not Hispanic) African American"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multicultural/Multiethnic/Multiracial/other"
replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian (not Hispanic)"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Children with disabilities"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migratory students"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military connected"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster care students"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"

//Subject
replace Subject = "ela" if Subject == "Reading/Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.)

duplicates drop NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup, force

//Saving EDFacts Output
save "${Original}/AZ_EFParticipation_2022", replace

//Merging with 2022
use "${Output}/AZ_AssmtData_2022.dta", clear

destring NCESDistrictID NCESSchoolID, replace

//Merging
merge 1:1 NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup using "${Original}/AZ_EFParticipation_2022"
drop if _merge ==2
replace ParticipationRate = Participation
replace ParticipationRate = "--" if missing(ParticipationRate)
drop _merge Participation

// Reordering variables and sorting data
local vars State StateAbbrev StateFips SchYear DataLevel DistName DistType 	///
    SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID 		///
    StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual 			///
    CountyName CountyCode AssmtName AssmtType Subject GradeLevel 			///
    StudentGroup StudentGroup_TotalTested StudentSubGroup 					///
    StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count 			///
    Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent 			///
    Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria 				///
    ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 	///
    Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math 	///
    Flag_CutScoreChange_sci Flag_CutScoreChange_soc
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/AZ_AssmtData_2022.dta", replace
export delimited "${Output}/AZ_AssmtData_2022.csv", replace
* END of 18_AZ_EDFactsParticipation_2022.do
****************************************************
