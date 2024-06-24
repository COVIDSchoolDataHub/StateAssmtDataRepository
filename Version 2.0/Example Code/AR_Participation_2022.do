clear
set more off

global Output_11 "/Volumes/T7/State Test Project/Arkansas/Output"
global Output_20 "/Volumes/T7/State Test Project/Arkansas/Output 2.0"
global Original "/Volumes/T7/State Test Project/Arkansas/Original Data"

import delimited "${Original}/AR_EFParticipation_2022.csv", case(preserve) clear

//Keep ParticipationRate
keep if strpos(DataDescription, "Participation") !=0

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
foreach var of varlist Participation {
replace `var' = "*" if `var' == "S"	
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
replace `var' = subinstr(`var', "=","",.)
destring `var', gen(n`var') i(*%<>-)
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
drop n`var'
drop range`var'
}

//StudentSubGroup
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students in SEA"
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

//Subject
replace Subject = "ela" if Subject == "Reading/Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.)

//Saving EDFacts Output
save "${Original}/AR_EFParticipation_2022", replace

//Merging with 2022
use "${Output_11}/AR_AssmtData_2022", clear

//Convert to numeric if necessary
destring NCESDistrictID NCESSchoolID, replace

//Merging
merge 1:1 NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup using "${Original}/AR_EFParticipation_2022"
drop if _merge ==2
replace ParticipationRate = Participation
replace ParticipationRate = "--" if missing(ParticipationRate)
drop _merge Participation

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output_20}/AR_AssmtData_2022", replace
export delimited "${Output_20}/AR_AssmtData_2022", replace



