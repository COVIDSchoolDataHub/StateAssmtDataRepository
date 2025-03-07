* MICHIGAN

* File name: MI_EDFactsParticipation_2022
* Last update: 03/07/2025

*******************************************************
* Notes
	
	* The do file imports *.csv ED Data Express data for 2022.
	* It cleans, renames variables and saves it as *.dta.
	* The MI specific EDFacts participation rate files are merged with the
	* Temp output with derivations created in Michigan 2022 Cleaning.do
	
*******************************************************
clear

foreach s in ela math sci {
	import delimited "${ED_Express}/MI_EFParticipation_2022_`s'.csv", case(preserve) clear
	save "${ED_Express}/MI_EFParticipation_2022_`s'.dta", replace
}

use "${ED_Express}/MI_EFParticipation_2022_ela.dta"
append using "${ED_Express}/MI_EFParticipation_2022_math.dta" "${ED_Express}/MI_EFParticipation_2022_sci.dta"


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
replace Participation = string(real(Participation)/100, "%9.3g") if real(Participation) > 1.01 & !missing(real(Participation))

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

//Subject
replace Subject = "ela" if Subject == "Reading/Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"


//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.)

//Saving EDFacts Output
save "${ED_Express}/MI_EFParticipation_2022", replace

//Merging with 2022
use "${Temp}/MI_AssmtData_2022", clear

destring NCESDistrictID NCESSchoolID, replace

//Merging
merge 1:1 NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup using "${ED_Express}/MI_EFParticipation_2022"
drop if _merge ==2
replace ParticipationRate = Participation
replace ParticipationRate = "--" if missing(ParticipationRate) | ParticipationRate == "."
drop _merge Participation

tostring NCESDistrictID, replace
tostring NCESSchoolID, replace

//Cleaning and dropping extra variables
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

******************************
*Exporting Output
******************************
save "${Output}/MI_AssmtData_2022", replace
export delimited "${Output}/MI_AssmtData_2022", replace
* END of MI_EDFactsParticipation_2022.do
****************************************************
