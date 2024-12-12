clear
set more off

global Original "/Users/miramehta/Documents/AR State Testing Data/Original Data"
global Output "/Users/miramehta/Documents/AR State Testing Data/Output"
global NCES "//Users/miramehta/Documents/NCES District and School Demographics"
global Temp "/Users/miramehta/Documents/AR State Testing Data/Temp"
global EDFacts "/Users/miramehta/Documents/AR State Testing Data/EDFacts"


foreach s in ela math sci {
	import delimited "${Original}/AR_EFParticipation_2022_`s'.csv", case(preserve) clear
	save "${Original}/AR_EFParticipation_2022_`s'.dta", replace
}

use "${Original}/AR_EFParticipation_2022_ela.dta"
append using "${Original}/AR_EFParticipation_2022_math.dta" "${Original}/AR_EFParticipation_2022_sci.dta"


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
save "${EDFacts}/AR_EFParticipation_2022", replace

//Merging with 2022
use "${Output}/AR_AssmtData_2022", clear

destring NCESDistrictID, replace
destring NCESSchoolID, replace

//Merging
merge 1:1 NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup using "${EDFacts}/AR_EFParticipation_2022"
drop if _merge ==2
replace ParticipationRate = Participation
replace ParticipationRate = "--" if missing(ParticipationRate)
drop _merge Participation

tostring NCESDistrictID, replace
tostring NCESSchoolID, replace format("%18.0f")
replace NCESDistrictID = "" if NCESDistrictID == "."
replace NCESSchoolID = "" if NCESSchoolID == "."

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/AR_AssmtData_2022", replace
export delimited "${Output}/AR_AssmtData_2022", replace
