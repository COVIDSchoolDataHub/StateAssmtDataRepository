clear
set more off

global EDFacts "/Users/mikaeloberlin/Desktop/New Jersey/EDFacts"
global NCES "/Users/mikaeloberlin/Desktop/New Jersey/NCES"
global Output "/Users/mikaeloberlin/Desktop/New Jersey/Output"
global Original "/Users/mikaeloberlin/Desktop/New Jersey/Original"


foreach s in ela math sci {
	import excel "${Original}/NJ_EFParticipation_2022_`s'.xlsx", case(preserve) clear
	save "${Original}/NJ_EFParticipation_2022_`s'.dta", replace
}



use "${Original}/NJ_EFParticipation_2022_ela.dta"
append using "${Original}/NJ_EFParticipation_2022_math.dta" "${Original}/NJ_EFParticipation_2022_sci.dta"

rename A SchYear
rename B State
rename C NCESDistrictID
rename D DistName
rename E SchName
rename F NCESSchoolID
rename I Participation
rename K StudentSubGroup_TotalTested
rename L StudentGroup
rename M StudentSubGroup
rename N Characteristics
replace StudentSubGroup = Characteristics if missing(StudentSubGroup) & !missing(Characteristics)
rename O GradeLevel
rename P Subject

tostring StudentSubGroup_TotalTested, replace

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
save "${Original}/NJ_EFParticipation_2022", replace

//Merging with 2022
import delimited "${Output}/NJ_AssmtData_2022", case(preserve) clear
save "${Output}/NJ_AssmtData_2022", replace

use "${Output}/NJ_AssmtData_2022", clear

//Convert to numeric if necessary
destring NCESDistrictID NCESSchoolID, replace


duplicates drop NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup, force

//Merging
merge 1:1 NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup using "${Original}/NJ_EFParticipation_2022"
drop if _merge ==2
replace ParticipationRate = Participation
replace ParticipationRate = "--" if missing(ParticipationRate)
replace StudentSubGroup_TotalTested = "*" if missing(StudentSubGroup_TotalTested)
drop _merge Participation

gen is_whole = mod(real(ParticipationRate), 1) == 0 if !missing(real(ParticipationRate))  // Check if ParticipationRate is a whole number
replace ParticipationRate = string(real(ParticipationRate) / 100) if is_whole == 0

	foreach var of varlist DistName SchName {
	replace `var' = lower(`var')
	replace `var' = proper(`var')
	replace `var' = stritrim(`var') // collapses all consecutive, internal blanks to one blank.
	replace `var' = strtrim(`var') // removes leading and trailing blanks
	replace `var' = lower(`var')
	replace `var' = proper(`var')
	}


	// Relabelling Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 
	
	
//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/NJ_AssmtData_2022", replace
export delimited "${Output}/NJ_AssmtData_2022", replace


