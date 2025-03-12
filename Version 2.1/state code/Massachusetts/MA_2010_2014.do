*******************************************************
* MASSACHUSETTS

* File name: MA_2010_2014
* Last update: 2/27/2025

*******************************************************
* Notes

	* This do file first cleans MA's 2010-2014 data.
	* Then this file merges with NCES data for the previous year.
	* Only the usual (temp) output for 2010-2014 is created.
*******************************************************
///////////////////////////////
// Setup
///////////////////////////////
clear

//Combining Data
use "$Original_DTA/MA_OriginalData_Dist_all_2010_2014_Legacy_MCAS", clear
rename A DataLevel	
rename B SchYear 	
rename C GradeLevel
rename D StudentSubGroup	
rename E DistName
rename F StateAssignedDistID
rename G Subject	
rename H ProficientOrAbove_count
rename I ProficientOrAbove_percent	
rename J Lev4_count	
rename K Lev4_percent	
rename L Lev3_count	
rename M Lev3_percent	
rename N Lev2_count
rename O Lev2_percent	
rename P Lev1_count		
rename Q Lev1_percent				
rename R StudentSubGroup_TotalTested	
drop S T U	
replace DataLevel = "District"
replace DataLevel = "State" if DistName == "State Total" | StateAssignedDistID == "00000000"
replace DistName = "All Districts" if DistName == "State Total" | StateAssignedDistID == "00000000"
save "$Temp/MA_Dist_2010_2014", replace
clear

tempfile temp1
save "`temp1'", empty
local schdata "MA_OriginalData_Sch_all_2010_2011_Legacy_MCAS MA_OriginalData_Sch_all_2010_Legacy_MCAS MA_OriginalData_Sch_all_2012_2014_Legacy_MCAS"
foreach dataset of local schdata {
use "`temp1'", clear
append using "$Original_DTA/`dataset'"
save "`temp1'", replace
}

use "`temp1'", clear
rename A DataLevel
rename B SchYear 	
rename C GradeLevel
rename D StudentSubGroup	
drop E
rename F SchName
rename G StateAssignedSchID
rename H Subject	
rename I ProficientOrAbove_count
rename J ProficientOrAbove_percent	
rename K Lev4_count	
rename L Lev4_percent	
rename M Lev3_count	
rename N Lev3_percent	
rename O Lev2_count
rename P Lev2_percent	
rename Q Lev1_count		
rename R Lev1_percent				
rename S StudentSubGroup_TotalTested	
drop T U V
save "$Temp/MA_Sch_2010_2014", replace

use "$Temp/MA_Dist_2010_2014", clear
append using "$Temp/MA_Sch_2010_2014"
replace DataLevel = "State" if DistName == "State Total" | StateAssignedDistID == "00000000" | StateAssignedSchID == "00000000"
replace DistName = "All Districts" if DistName == "State Total" | StateAssignedDistID == "00000000" | StateAssignedSchID == "00000000"
duplicates drop

//Fixing District info at Sch Level
replace StateAssignedDistID = substr(StateAssignedSchID, 1,4) + "0000" if DataLevel == "School"
replace DistName = substr(SchName, 1, strpos(SchName," - ")-1) if DataLevel == "School"
replace SchName = substr(SchName,strpos(SchName," -")+3,.) if DataLevel == "School"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
drop DataLevel
rename DataLevel_n DataLevel
sort DataLevel
order DataLevel
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel !=3

//SchYear
replace SchYear = string(real(SchYear)-1) + "-" + substr(SchYear,-2,2)

//GradeLevel
drop if missing(real(GradeLevel)) | real(GradeLevel) > 8
replace GradeLevel = "G" + GradeLevel

//StudentSubGroup
*All Students
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Afr. Amer./Black"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Amer. Ind. or Alaska Nat."
*Asian
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL"
replace StudentSubGroup = "EL and Moniot or Recently Ex" if StudentSubGroup == "EL and Former EL"
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "Former EL"
*Ever EL
*Female
drop if StudentSubGroup == "High needs"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Low income"
*Male
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-race, Non-Hisp./Lat."
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Nat. Haw. or Pacif. Isl."
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Non-Disabled"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Low Income"
drop if strpos(StudentSubGroup, "Title1")
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students w/disabilities"
*White

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex" | StudentSubGroup == "EL Exited" | StudentSubGroup == "EL and Monit or Recently Ex" | StudentSubGroup == "Ever EL"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//Subject
replace Subject = lower(Subject)
replace Subject = "math" if Subject == "mth"

//Percents
foreach percent of varlist *_percent {
	replace `percent' = string(real(`percent')/100, "%9.3g") if !missing(real(`percent'))
}

//NCES Merging
gen FILE = substr(SchYear, 1,2) + substr(SchYear,-2,2)
tempfile temp3
save "`temp3'", replace
forvalues year = 2010/2014 {
	use "`temp3'", clear
	keep if FILE == "`year'"
	drop FILE
	save "$Temp/MA_AssmtData_`year'", replace
}
forvalues year = 2010/2014 {
local prevyear = `year'-1	
use "$Temp/MA_AssmtData_`year'", clear
gen State_leaid = subinstr(StateAssignedDistID, "0000","",.)
gen seasch = StateAssignedSchID

merge m:1 State_leaid using "$NCES_MA/NCES_`prevyear'_District", gen(DistMerge) keep(match master)
duplicates drop
merge m:1 seasch using "$NCES_MA/NCES_`prevyear'_School", gen(SchMerge) keep(match master)
duplicates drop
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

replace State = "Massachusetts"
replace StateAbbrev = "MA"
replace StateFips = 25

//StudentGroup_TotalTested
cap drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Indicator and Missing Variables
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N" 
gen Flag_CutScoreChange_soc = "Not applicable"

gen AssmtName = "Legacy MCAS"
gen AssmtType = "Regular"

gen ProficiencyCriteria = "Levels 3-4"

gen AvgScaleScore = "--"
gen ParticipationRate = "--"

gen Lev5_count = ""
gen Lev5_percent = ""

//Missing Data on Resiliency Middle School
replace NCESSchoolID = "250483002838" if SchName == "Resiliency Middle School" 
replace SchVirtual = -1 if SchName == "Resiliency Middle School"  
replace SchLevel = 2 if SchName == "Resiliency Middle School" 
replace SchType = 1 if SchName == "Resiliency Middle School" // NCESDistrictID = "2504830" 

//Incorporating Stable Dist/SchNames
merge m:1 SchYear NCESDistrictID NCESSchoolID using "$Original_DTA/MA_StableNames", keep(match master) nogen
replace DistName = newdistname if !missing(newdistname)
replace SchName = newschname if !missing(newschname)

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
replace CountyName = proper(CountyName)

// Reordering variables and sorting data
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

*Exporting Temp Output*
save "$Temp/MA_AssmtData_`year'", replace
}
* END of MA_2010_2014.do
****************************************************
