*******************************************************
* MASSACHUSETTS

* File name: MA ParticipationRate
* Last update: 2/27/2025

*******************************************************
* Notes

	* This do file first cleans Participation Rates for 2010-2022.
	* This file is merged with the temp output created in
	* a) MA_2010_2014.do
	* b) MA_2015_2016.do
	* c) MA_2017_2024.do
	* The usual output for 2010 to 2022 is created.
	* This file will need to be updated when newer participation rates are available.
	
*******************************************************
///////////////////////////////
// Setup
///////////////////////////////
clear

*****************************
// ** ParticipationRate ** //
*****************************
use "$Original_DTA/MA_ParticipationRate_Dist", clear
rename A DataLevel
rename B SchYear
rename C GradeLevel
rename D StudentSubGroup
rename E Subject
rename F DistName
rename G StateAssignedDistID
replace I = H if real(SchYear) < 2017
drop H
rename I ParticipationRate

tempfile dist_part
save "`dist_part'", replace

use "$Original_DTA/MA_ParticipationRate_Sch", clear
rename A DataLevel
rename B SchYear
rename C GradeLevel
rename D StudentSubGroup
rename E Subject
rename F SchName
rename G StateAssignedSchID
replace I = H if real(SchYear) < 2017
drop H
rename I ParticipationRate

append using "`dist_part'"

//DataLevel
replace DataLevel = "State" if strpos(DistName, "State Total") !=0
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3
replace StateAssignedDistID = "" if DataLevel == 1

//SchYear
replace SchYear = string(real(SchYear)-1) + "-" + substr(SchYear,-2,2)

//GradeLevel
replace GradeLevel = "G" + GradeLevel

//StudentSubGroup
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Afr. Amer./Black"
* All Students
* Asian
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL"
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "EL and Former EL"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Econ. Disadvantaged"
* Ever EL
* Female
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "Former EL"
drop if StudentSubGroup == "High needs"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
* Male
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-race, Non-Hisp."
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students w/ disabilities"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Amer. Ind. or Alaska Nat."
drop if StudentSubGroup == "XXXXXXXX"

//Subject
replace Subject = "ela" if Subject == "English"
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "sci" if strpos(Subject, "Sci") !=0

//StateAssignedDistID & StateAssignedSchID
replace StateAssignedDistID = substr(StateAssignedSchID,1,4) + "0000" if DataLevel == 3

//ParticipationRate
replace ParticipationRate = string(real(ParticipationRate)/100, "%9.3g")
rename ParticipationRate ParticipationRate_1

//Final Cleaning
rename *Name *Name_1
order SchYear DataLevel StateAssignedDistID StateAssignedSchID StudentSubGroup GradeLevel Subject ParticipationRate SchName_1 DistName_1
sort SchYear DataLevel

save "$Temp/MA_Participation", replace

forvalues year = 2010/2022 {
if `year' == 2020 continue
use "$Temp/MA_AssmtData_`year'", clear
merge m:1 SchYear StateAssignedDistID StateAssignedSchID StudentSubGroup GradeLevel Subject using "$Temp/MA_Participation", gen(Merge)
drop if Merge == 2

replace ParticipationRate = ParticipationRate_1 if missing(real(ParticipationRate)) & !missing(real(ParticipationRate_1))
drop *_1

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

*Exporting Output*
save "$Output/MA_AssmtData_`year'", replace
export delimited "$Output/MA_AssmtData_`year'", replace
}
* END of MA ParticipationRate.do
****************************************************
