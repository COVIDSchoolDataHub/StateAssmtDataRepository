* NEW JERSEY

* File name: NJ_EDFactsParticipation_2022
* Last update: 03/10/2025

*******************************************************
* Notes

	* This do file imports 2022 *.xlsx NJ EDFacts Participation Data. 
	* It loops through the temp 2022 output file and merges EDFacts participation rates. 
	* The resulting output is saved in the usual output folder.
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear

foreach s in ela math sci {
	import excel "${ED_Express}/NJ_EFParticipation_2022_`s'.xlsx", case(preserve) clear
	save "${Original_DTA}/NJ_EFParticipation_2022_`s'.dta", replace
}

use "${Original_DTA}/NJ_EFParticipation_2022_ela.dta"
append using "${Original_DTA}/NJ_EFParticipation_2022_math.dta" "${Original_DTA}/NJ_EFParticipation_2022_sci.dta"

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
save "${Original_DTA}/NJ_EFParticipation_2022", replace

//Merging with 2022
use "${Temp}/NJ_AssmtData_2022", clear

destring NCESDistrictID NCESSchoolID, replace

duplicates drop NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup, force

//Merging
merge 1:1 NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup using "${Original_DTA}/NJ_EFParticipation_2022"
drop if _merge ==2
replace ParticipationRate = Participation
replace ParticipationRate = "--" if missing(ParticipationRate)
replace StudentSubGroup_TotalTested = "*" if missing(StudentSubGroup_TotalTested)
drop _merge Participation

	foreach var of varlist DistName SchName {
	replace `var' = lower(`var')
	replace `var' = proper(`var')
	replace `var' = stritrim(`var') // collapses all consecutive, internal blanks to one blank.
	replace `var' = strtrim(`var') // removes leading and trailing blanks
	replace `var' = lower(`var')
	replace `var' = proper(`var')
	}

//Final Cleaning
local vars State StateAbbrev StateFips SchYear DataLevel DistName SchName 	///
    NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID		///
    AssmtName AssmtType Subject GradeLevel	StudentGroup 					///
    StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested    ///
    Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent	///
    Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore			///
    ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent	///
    ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA 			///
    Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc ///
    DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	keep `vars' State_leaid
	order `vars' State_leaid
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output for 2022
replace State_leaid = "" if DataLevel == 1
save "${Output_HMH}/NJ_AssmtData_2022_HMH", replace
export delimited "${Output_HMH}/NJ_AssmtData_2022_HMH", replace
forvalues n = 1/3 {
		preserve
		keep if DataLevel == `n'
		if `n' == 1{
			export excel "${Output_HMH}/NJ_AssmtData_2022_HMH.xlsx", sheet("State") sheetreplace firstrow(variables)
		}
		if `n' == 2{
			export excel "${Output_HMH}/NJ_AssmtData_2022_HMH.xlsx", sheet("District") sheetreplace firstrow(variables)
		}
		if `n' == 3{
			export excel "${Output_HMH}/NJ_AssmtData_2022_HMH.xlsx", sheet("School") sheetreplace firstrow(variables)
		}
		restore
	}
drop State_leaid //remove alternate ID for non-HMH output
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "${Output}/NJ_AssmtData_2022", replace
export delimited "${Output}/NJ_AssmtData_2022", replace
*End of NJ_EDFactsParticipation_2022.do
****************************************************
