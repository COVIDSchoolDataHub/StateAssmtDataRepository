* NORTH CAROLINA

* File name: NC_EDFactsParticipation_2022
* Last update: 03/04/2025

*******************************************************
* Notes

	* This do file imports 2022 *.xlsx NC EDFacts Participation Data. 
	* It loops through the temp 2022 output file and merges EDFacts participation rates. 
	* The resulting output is saved in the usual output folder.
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear

foreach s in ela math sci {
	import excel "$Original/NC_EFParticipation_2022_`s'.xlsx", case(preserve) clear
	rename C NCESDistrictID
	rename F NCESSchoolID
	rename I Participation
	rename M StudentSubGroup
	rename N Characteristics
	rename O GradeLevel
	rename P Subject
	keep NCESDistrictID NCESSchoolID Participation StudentSubGroup Characteristics GradeLevel Subject
	save "$Original_DTA/NC_EFParticipation_2022_`s'.dta", replace
}


use "$Original_DTA/NC_EFParticipation_2022_ela.dta"
append using "$Original_DTA/NC_EFParticipation_2022_math.dta" "$Original_DTA/NC_EFParticipation_2022_sci.dta"


//StudentSubGroup
replace StudentSubGroup = Characteristics if missing(StudentSubGroup) & !missing(Characteristics)
drop Characteristics

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
save "$Original_DTA/NC_EFParticipation_2022", replace

//Merging with 2022
use "$Temp/NC_AssmtData_2022", clear

//Convert to numeric if necessary
destring NCESDistrictID NCESSchoolID, replace
duplicates drop NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup, force

//Merging
merge 1:1 NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup using "$Original_DTA/NC_EFParticipation_2022"
drop if _merge ==2
replace ParticipationRate = Participation
replace ParticipationRate = "--" if missing(ParticipationRate)
drop _merge Participation

tostring NCESDistrictID, replace
tostring NCESSchoolID, replace format("%18.0f")
replace NCESDistrictID = "" if NCESDistrictID == "."
replace NCESSchoolID = "" if NCESSchoolID == "."

//Final Cleaning

local vars State StateAbbrev StateFips SchYear DataLevel DistName SchName ///
	NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID ///
	AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested ///
	StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent ///
	Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent ///
	Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ///
	ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA ///
	Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType ///
	DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Final Output for 2022. 
save "$Output/NC_AssmtData_2022", replace
export delimited "$Output/NC_AssmtData_2022", replace
*End of NC_EDFactsParticipation_2022.do
****************************************************
