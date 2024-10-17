clear
set more off
cd "/Volumes/T7/State Test Project/Massachusetts"
global Original "/Volumes/T7/State Test Project/Massachusetts/Original"
global Output "/Volumes/T7/State Test Project/Massachusetts/Output"
global NCES "/Volumes/T7/State Test Project/Massachusetts/NCES"
global Temp "/Volumes/T7/State Test Project/Massachusetts/Temp"

//Combining Data
use "$Original/MA_OriginalData_Dist_all_2015_2018_Legacy_MCAS", clear
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

gen AssmtName = "Legacy MCAS"
save "$Temp/MA_Dist_2015_2016_MCAS", replace

use "$Original/MA_OriginalData_Sch_all_2015_2018_Legacy_MCAS", clear
rename A DataLevel
rename B SchYear 	
rename C GradeLevel
rename D StudentSubGroup	
rename E SchName
rename F StateAssignedSchID
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

gen AssmtName = "Legacy MCAS"
save "$Temp/MA_Sch_2015_2016_MCAS", replace 

use "$Original/MA_OriginalData_Dist_ela_math_2015_2016_PARCC", clear
rename A DataLevel	
rename B SchYear
rename C GradeLevel_Subject	
rename D StudentSubGroup	
rename E DistName
rename F StateAssignedDistID
drop G 	
rename H ProficientOrAbove_count
rename I ProficientOrAbove_percent	
rename J Lev5_count	
rename K Lev5_percent	
rename L Lev4_count	
rename M Lev4_percent	
rename N Lev3_count
rename O Lev3_percent	
rename P Lev2_count		
rename Q Lev2_percent
rename R Lev1_count		
rename S Lev1_percent								
rename T AvgScaleScore
rename U StudentSubGroup_TotalTested
drop V-Y

gen AssmtName = "PARCC"
save "$Temp/MA_Dist_2015_2016_PARCC", replace

use "$Original/MA_OriginalData_Sch_ela_math_2015_2016_PARCC", clear
rename A DataLevel	
rename B SchYear
rename C GradeLevel_Subject	
rename D StudentSubGroup	
drop E 
rename F SchName
rename G StateAssignedSchID
drop H	
rename I ProficientOrAbove_count
rename J ProficientOrAbove_percent	
rename K Lev5_count	
rename L Lev5_percent	
rename M Lev4_count	
rename N Lev4_percent	
rename O Lev3_count
rename P Lev3_percent	
rename Q Lev2_count		
rename R Lev2_percent
rename S Lev1_count		
rename T Lev1_percent								
rename U AvgScaleScore
rename V StudentSubGroup_TotalTested	
drop W-Z
	

gen AssmtName = "PARCC"
save "$Temp/MA_Sch_2015_2016_PARCC", replace
clear

local files "MA_Dist_2015_2016_MCAS MA_Sch_2015_2016_MCAS MA_Dist_2015_2016_PARCC MA_Sch_2015_2016_PARCC"
tempfile temp1
save "`temp1'", empty
foreach file of local files {
	use "`temp1'"
	append using "$Temp/`file'"
	save "`temp1'", replace
}
use "`temp1'"
keep if real(SchYear) < 2017
duplicates drop
save "$Temp/MA_OriginalData_2015_2016", replace

//GradeLevel_Subject
replace GradeLevel = "0" + substr(GradeLevel_Subject,7,1) if !missing(GradeLevel_Subject)
drop if GradeLevel == "01"
replace Subject = substr(GradeLevel_Subject, -4,4) if !missing(GradeLevel_Subject)
drop if Subject == "G. I"
drop GradeLevel_Subject

//Fixing District info at Sch Level
replace StateAssignedDistID = substr(StateAssignedSchID, 1,4) + "0000" if DataLevel == "School"
replace DistName = substr(SchName, 1, strpos(SchName," - ")-1) if DataLevel == "School"
replace SchName = substr(SchName,strpos(SchName," -")+3,.) if DataLevel == "School"

//DataLevel
replace DataLevel = "State" if StateAssignedDistID == "00000000"
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
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "EL and Former EL"
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "Former EL"
*Ever EL
*Female
drop if StudentSubGroup == "High needs"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Econ. Disadvantaged"
*Male
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-race, Non-Hisp./Lat."
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Nat. Haw. or Pacif. Isl."
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Non-Disabled"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Econ. Disadvantaged"
drop if strpos(StudentSubGroup, "Title1")
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students w/ disabilities"
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
replace Subject = "ela" if Subject == "la/l"

//Percents
foreach percent of varlist *_percent {
	replace `percent' = string(real(`percent')/100, "%9.3g") if !missing(real(`percent'))
}

//NCES Merging
gen FILE = substr(SchYear, 1,2) + substr(SchYear,-2,2)
tempfile temp3
save "`temp3'", replace
forvalues year = 2015/2016 {
	use "`temp3'", clear
	keep if FILE == "`year'"
	drop FILE
	save "$Temp/MA_AssmtData_`year'", replace
}
forvalues year = 2015/2016 {
local prevyear = `year'-1	
use "$Temp/MA_AssmtData_`year'", clear
gen State_leaid = subinstr(StateAssignedDistID, "0000","",.)
gen seasch = StateAssignedSchID

merge m:1 State_leaid using "$NCES/NCES_`prevyear'_District", gen(DistMerge) keep(match master)
merge m:1 seasch using "$NCES/NCES_`prevyear'_School", gen(SchMerge) keep(match master)
duplicates drop
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

replace State = "Massachusetts"
replace StateAbbrev = "MA"
replace StateFips = 25

//Aggregating District Data to State Level
if `year' == 2016 {
tempfile temp5
save "`temp5'", replace
foreach var of varlist StudentSubGroup_TotalTested *count {
	destring `var', replace
}
collapse (sum) StudentSubGroup_TotalTested Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count ProficientOrAbove_count, by(GradeLevel StudentSubGroup Subject State StateAbbrev StateFips AssmtName Subject StudentGroup)
drop if Subject == "sci"
gen DataLevel = 1

foreach count of varlist *count {
	local percent = subinstr("`count'", "count", "percent",.)
	gen `percent' = string(`count'/StudentSubGroup_TotalTested, "%9.3g")
}

foreach var of varlist StudentSubGroup_TotalTested *count {
	tostring `var', replace usedisplayformat
}
gen DistName = "All Districts"
gen SchName = "All Schools"
gen SchYear = "2015-16"

foreach var of varlist Lev5* {
	replace `var' = "" if AssmtName != "PARCC"
}

tempfile tempstate
save "`tempstate'", replace
use "`temp5'"
append using "`tempstate'"
	
}

//StudentGroup_TotalTested
cap drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel AssmtName)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Indicator and Missing Variables
gen Flag_AssmtNameChange = "N"
replace Flag_AssmtNameChange = "Y" if (Subject == "ela" | Subject == "math") & `year' == 2015
gen Flag_CutScoreChange_ELA = "N"
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2015
gen Flag_CutScoreChange_math = "N"
replace Flag_CutScoreChange_math = "Y" if `year' == 2015
gen Flag_CutScoreChange_sci = "N" 
gen Flag_CutScoreChange_soc = "Not applicable"

gen AssmtType = "Regular"

gen ProficiencyCriteria = "Levels 3-4"
replace ProficiencyCriteria = "Levels 4-5" if AssmtName == "PARCC"

gen ParticipationRate = "--"
replace AvgScaleScore = "--" if missing(real(AvgScaleScore))

//Incorporating Stable Dist/SchNames
merge m:1 SchYear NCESDistrictID NCESSchoolID using "MA_StableNames", keep(match master) nogen
replace DistName = newdistname if !missing(newdistname)
replace SchName = newschname if !missing(newschname)


//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
if `year' == 2015 replace CountyName = proper(CountyName)

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName AssmtName Subject GradeLevel StudentGroup StudentSubGroup

save "$Output/MA_AssmtData_`year'", replace	
}


