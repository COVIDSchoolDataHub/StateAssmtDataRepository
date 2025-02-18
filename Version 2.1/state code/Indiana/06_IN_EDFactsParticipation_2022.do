*******************************************************
* INDIANA

* File name: 06_IN_EDFactsParticipation_2022
* Last update: 2/13/2025

*******************************************************
* Notes

	* This do file uses EDFacts participation rates for 2022. 
	* a) IN_EFParticipation_2022_math.csv
	* b) IN_EFParticipation_2022_ela.csv
	
	* These files are found in the Google Drive --> Indiana --> Original Data Files - Version 2.0 (incl v1.1 + sci and soc data) --> ELA + Math
	
	* It merges with and REPLACES the 2023 output created in:
		* a) 04_IN_Cleaning (usual output replaced, non-derived output NOT replaced)
		
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear
set more off



foreach s in ela math {
	import delimited "$Original/ELA + Math/IN_EFParticipation_2022_`s'.csv", case(preserve) clear
	save "$Temp/IN_EFParticipation_2022_`s'.dta", replace
}

import delimited "$Original/Science + Social Studies/IN_EFParticipation_2022_sci.csv", case(preserve) clear
save "$Temp/IN_EFParticipation_2022_sci.dta", replace

use "$Temp/IN_EFParticipation_2022_ela.dta", clear
append using "$Temp/IN_EFParticipation_2022_math.dta" "$Temp/IN_EFParticipation_2022_sci.dta"


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
replace `var' = subinstr(`var', "%", "", 1)
replace `var' = "*" if `var' == "S"
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
replace `var' = subinstr(`var', "=","",.)
split `var', parse("-")
replace `var' = string(real(`var'1)/100, "%9.3g") + "-" + string(real(`var'2)/100, "%9.3g") if `var'2 != "" & `var' != "--"
destring `var', gen(n`var') i(*%<>-) force
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--" & n`var' != . & `var'2 == ""
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
drop n`var' `var'1 `var'2 range`var'
}

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

//Using ELA for eng and read
tempfile temp1
save "`temp1'", replace
keep if Subject == "ela"
expand 3, gen(exp)
drop if exp == 0
gen row = _n
replace Subject = "eng" if mod(row,2) == 0
replace Subject = "read" if mod(row,2) !=0
drop exp row
append using "`temp1'"

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.)

//Saving EDFacts Output
save "$Temp/IN_EFParticipation_2022", replace

//Merging with 2022
use "$Output/IN_AssmtData_2022", clear

destring NCESDistrictID NCESSchoolID, replace

//Merging
merge 1:1 NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup using "$Temp/IN_EFParticipation_2022"
drop if _merge ==2
replace ParticipationRate = Participation
replace ParticipationRate = "--" if missing(ParticipationRate)
drop _merge Participation

tostring NCESDistrictID, replace
replace NCESDistrictID = "" if NCESDistrictID == "."
tostring NCESSchoolID, replace format("%18.0f")
replace NCESSchoolID = "" if NCESSchoolID == "."

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

save "$Output/IN_AssmtData_2022", replace
export delimited "$Output/IN_AssmtData_2022", replace

* END of 06_IN_EDFactsParticipation_2022.do
****************************************************
