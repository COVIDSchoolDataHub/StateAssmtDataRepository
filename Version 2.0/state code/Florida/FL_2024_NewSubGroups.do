clear
set more off
set trace off

global Original "/Volumes/T7/State Test Project/Florida post-launch/Original Data/FL_OriginalData_2024"
global Output "/Volumes/T7/State Test Project/Florida post-launch/Output"
global Temp "/Volumes/T7/State Test Project/Florida post-launch/Temp"
global NCES "/Volumes/T7/State Test Project/Florida post-launch/NCES"

//Run below code when first cleaning 

/*

foreach dl in State District School {
	foreach sg in AllStudents Disability Econ ELcode ELstatus Gender Homeless Migrant Military Race {
		import excel "${Original}/FL_OriginalData_2024_`dl'_Grade_`sg'.xlsx", firstrow case(preserve) allstring
		save "${Temp}/FL_OriginalData_2024_`dl'_`sg'.dta", replace
		clear
		
	} 
}





tempfile temp1
save "`temp1'", emptyok replace
clear

//Creating one big dataset for all years
foreach dl in State District School {
	foreach sg in AllStudents Disability Econ ELcode ELstatus Gender Homeless Migrant Military Race {
	use "${Temp}/FL_OriginalData_2024_`dl'_`sg'.dta"
	
	if "`dl'" == "State" {
	gen DataLevel = "State"	
	rename J Lev1_percent
	rename L Lev2_percent
	rename N Lev3_percent
	rename P Lev4_percent
	rename R Lev5_percent
	rename T ProficientOrAbove_percent
	save "${Temp}/FL_OriginalData_2024_`dl'_`sg'.dta", replace
	}
	
	if "`dl'" == "District" {
	gen DataLevel = "District"	
	rename L Lev1_percent
	rename N Lev2_percent
	rename P Lev3_percent
	rename R Lev4_percent
	rename T Lev5_percent
	rename V ProficientOrAbove_percent
	save "${Temp}/FL_OriginalData_2024_`dl'_`sg'.dta", replace
	}
	
	if "`dl'" == "School" {
	gen DataLevel = "School"	
	rename N Lev1_percent
	rename P Lev2_percent
	rename R Lev3_percent
	rename T Lev4_percent
	rename V Lev5_percent
	rename X ProficientOrAbove_percent
	save "${Temp}/FL_OriginalData_2024_`dl'_`sg'.dta", replace
	}

append using "`temp1'"
save "`temp1'", replace
clear	
		
	}
}
use "`temp1'"
drop if Indicator2 == "Not Reported" // Dropping "Not Reported" StudentSubGroup for viewing original data
rename SchoolYear SchYear
save "${Temp}/FL_OriginalData_2024", replace
clear



*/

//Run above code when first cleaning or if you need to incorporate additional data

use "${Temp}/FL_OriginalData_2024"

//Renaming and Dropping Variables
drop Index
rename DistrictName DistName
rename DistrictNumber StateAssignedDistID
rename SchoolName SchName
rename SchoolNumber StateAssignedSchID
rename SubjectArea Subject
rename Indicator1 GradeLevel
rename Indicator2 StudentSubGroup
rename ofStudents StudentSubGroup_TotalTested
forvalues n = 1/5 {
	rename ofStudentsLevel`n' Lev`n'_count
}
rename ofStudentsLevel3andAbove ProficientOrAbove_count
rename MeanScaleScore AvgScaleScore

//Subject
replace Subject = "ela" if strpos(Subject, "English Language") !=0
replace Subject = "math" if strpos(Subject, "Mathematics") !=0
replace Subject = "sci" if Subject == "Science"
drop if Subject == "Social Studies" //These are non-standardized assessments included only at the school level

//GradeLevel
replace GradeLevel = "G" + substr(GradeLevel,1,2)
drop if real(substr(GradeLevel,-2,2)) > 8

//StudentSubGroup
replace StudentSubGroup = "All Students" if missing(StudentSubGroup)
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Eco. Disadvantaged"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Current ELL"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Current ELL"
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "LF"
drop if StudentSubGroup == "LZ" //Not directly codeable, dropping
drop if StudentSubGroup == "LA" //This is a category for Students who exited the EL program 3-4 years ago after being in "LF." Dropping for now as there is no direct mapping in our categories. For more details, read the ELL Codes in the Data Documentation Folder.
drop if StudentSubGroup == "LP" //This is a category for Students who are pending proficiency designation. For more details, read the ELL Codes in the Data Documentation Folder.
drop if StudentSubGroup == "LY" | StudentSubGroup == "ZZ" //These Categories are similar to categories described in ELstatus dataset, dropped
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Family"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Non-Military Family"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Eco. Disadvantaged"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
drop if StudentSubGroup == "Not Reported"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Exited" | StudentSubGroup == "EL Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//Assessment (Dealing with duplicate values within DistName, SchName, GradeLevel, Subject, StudentSubGroup)
drop if strpos(Assessment, "EOC") !=0


//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel == 1 | DataLevel == 2

//StudentGroup_TotalTested
destring StudentSubGroup_TotalTested, replace
egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)
replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "EL Monit or Recently Ex"

/*
	//Fixing For EL Status:
	gen StudentSubGroup_TotalTested1 = StudentSubGroup_TotalTested
	replace StudentSubGroup_TotalTested1 = 0 if StudentSubGroup == "EL Monit or Recently Ex"
	egen StudentGroup_TotalTested1 = total(StudentSubGroup_TotalTested1), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)
	replace StudentGroup_TotalTested = StudentGroup_TotalTested1 if StudentGroup == "EL Status"
	drop StudentSubGroup_TotalTested1 StudentGroup_TotalTested1
	replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "EL Monit or Recently Ex"
*/

//Code above effectively substracts EL Monitored or Ex StudentGroup_TotalTested from the rest of EL Status. Decided not to do.


//StudentSubGroup_TotalTested
drop if missing(StudentSubGroup_TotalTested) | StudentSubGroup_TotalTested == 0 //I would guess these values are suppressed, but the data just has them missing. Tranforming assuming StudentSubGroup_TotalTested == 0


//Merging NCES
gen State_leaid = "FL-" + StateAssignedDistID if DataLevel != 1
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == 3

merge m:1 State_leaid using "$NCES/NCES_2022_District", gen(DistMerge)
merge m:1 seasch using "$NCES/NCES_2022_School", gen(SchMerge)

drop if DistMerge == 2
drop if SchMerge == 2

//Indicator Variables
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen AssmtName = "FAST"
replace AssmtName = "Statewide Science Assessment" if Subject == "sci"

replace Flag_AssmtNameChange = "N"
replace Flag_CutScoreChange_math = "N"
replace Flag_CutScoreChange_ELA = "N"
replace Flag_CutScoreChange_sci = "N"
replace StateAbbrev = "FL"
replace StateFips = 12
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-5"
gen ParticipationRate = "--"

//Cleaning Percents
foreach var of varlist Lev* ProficientOrAbove* {
	destring `var', replace
	format `var' %9.4g
}

//AvgScaleScore
replace AvgScaleScore = string(real(AvgScaleScore), "%9.4g")
replace AvgScaleScore = "--" if AvgScaleScore == "."

//Dropping Online Unmerged School
drop if DataLevel ==3 & missing(NCESSchoolID) & SchName == "Hendry Online Learning School-7006"

//Post Launch review response
replace DistName = subinstr(DistName, substr(DistName, 1, strpos(DistName, "-")),"",.)
replace SchName = proper(SchName)

**Updating CountyName and CountyCode of Select Districts
replace CountyName = "Duval County" if NCESSchoolID == "120008410710" | NCESSchoolID == "120008410711" 
replace CountyName = "Hillsborough County" if NCESSchoolID == "120008410712" | NCESSchoolID == "120008410714"
replace CountyCode = "12031" if NCESSchoolID == "120008410710" | NCESSchoolID == "120008410711" 
replace CountyCode = "12057" if NCESSchoolID == "120008410712" | NCESSchoolID == "120008410714"
replace CountyName = "Hidalgo County" if NCESDistrictID == "1200084" & DataLevel == 2
replace CountyCode = "48215" if NCESDistrictID == "1200084" & DataLevel == 2



//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/FL_AssmtData_2024", replace
export delimited "${Output}/FL_AssmtData_2024", replace

