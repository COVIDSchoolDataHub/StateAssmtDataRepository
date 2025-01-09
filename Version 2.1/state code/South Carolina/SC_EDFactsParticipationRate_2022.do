clear
set more off

global EDFacts "/Users/benjaminm/Documents/State_Repository_Research/EdFacts" //Folder with downloaded state-specific 2022 participation data from EDFacts
global State_Output "/Users/benjaminm/Documents/State_Repository_Research/South_Carolina/State_Output" // Folder with state-specific data
global New_Output "/Users/benjaminm/Documents/State_Repository_Research/South_Carolina/New_Output"

foreach s in ela math sci {
	import delimited "${EDFacts}/SC_EFParticipation_2022_`s'.csv", case(preserve) clear
	save "${EDFacts}/SC_EFParticipation_2022_`s'.dta", replace
}

use "${EDFacts}/SC_EFParticipation_2022_ela.dta"
append using "${EDFacts}/SC_EFParticipation_2022_math.dta" "${EDFacts}/SC_EFParticipation_2022_sci.dta"


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

replace Participation = "0.808" if Participation == "80.8" 
replace Participation = "0.909" if Participation == "90.9" 
replace Participation = "0.859" if Participation == "85.9" 
replace Participation = "0.809" if Participation == "80.9" 
replace Participation = "0.758" if Participation == "75.8" 
replace Participation = "0.708" if Participation == "70.8" 
replace Participation = "0.608" if Participation == "60.8" 
replace Participation = "0.607" if Participation == "60.7" 
replace Participation = "0.406" if Participation == "40.6" 


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
save "${EDFacts}/SC_EFParticipation_2022", replace

//Merging with 2022
use "${State_Output}/SC_AssmtData_2022", clear

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Merging
merge 1:1 NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup using "${EDFacts}/SC_EFParticipation_2022"
drop if _merge ==2
replace ParticipationRate = Participation
replace ParticipationRate = "--" if missing(ParticipationRate)
drop _merge Participation

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${New_Output}/SC_AssmtData_2022", replace
export delimited "${New_Output}/SC_AssmtData_2022", replace




