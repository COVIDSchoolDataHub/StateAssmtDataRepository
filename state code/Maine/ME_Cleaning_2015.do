clear
set more off
set trace off
cd "/Volumes/T7/State Test Project/Maine"
local Original "/Volumes/T7/State Test Project/Maine/Original Data Files"
local Output "/Volumes/T7/State Test Project/Maine/Output"
local NCES_District "/Volumes/T7/State Test Project/NCES/District"
local NCES_School "/Volumes/T7/State Test Project/NCES/School"
local Unmerged "/Volumes/T7/State Test Project/Maine/Unmerged"

//Combining Subjects
tempfile temp_combined
save "`temp_combined'", replace emptyok
foreach Subject in ela math sci {
	
	import excel "`Original'/Maine_OriginalData_`Subject'_2015", firstrow case(preserve)
	gen Subject = "`Subject'"
	append using "`temp_combined'"
	save "`temp_combined'", replace
	clear
}
use "`temp_combined'"

//Standardizing Variable Names
rename DISTRICT_PUBL~E DistName
rename SCHOOL_NAME SchName
gen StudentSubGroup_TotalTested = ""
replace StudentSubGroup_TotalTested = ParticipantScience if Subject == "sci"
replace StudentSubGroup_TotalTested = ParticipantMath if Subject == "math"
replace StudentSubGroup_TotalTested = ParticipantELA if Subject == "ela"
rename ProficientorP~i ProficientOrAbove_count
rename PercentagePro~i ProficientOrAbove_percent
rename DISTRICT_ID StateAssignedDistID
rename SCHOOL_ID StateAssignedSchID
replace ProficientOrAbove_count = MetStandardorMetStandardwit if missing(ProficientOrAbove_count)
replace ProficientOrAbove_percent = PercentageMetStandardorMetS if missing(ProficientOrAbove_percent)

//Dropping Extra Variables
keep DistName SchName StateAssignedDistID StateAssignedSchID ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate StudentSubGroup_TotalTested Subject

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if SchName == "State Totals" | missing(SchName) & !missing(ParticipationRate)
replace DataLevel = "School" if !missing(SchName) & DataLevel != "State"
drop if missing(DataLevel)
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
order DataLevel
replace SchName = "All Schools" if DataLevel ==1
replace DistName = "All Districts" if DataLevel ==1

//Fixing Suppressed Data
foreach var of varlist _all {
	cap replace `var' = "*" if strpos(`var',"*") !=0
}

//Merging NCES
save "`temp_combined'", replace
clear
use "`NCES_School'/NCES_2014_School"
keep if state_name == 23 | state_location == "ME"
gen StateAssignedSchID = seasch
replace StateAssignedSchID = "1822" if school_name == "Beatrice Rafferty School"
replace StateAssignedSchID = "1820" if school_name == "Indian Island School"
replace StateAssignedSchID = "1821" if school_name == "Indian Township School"
merge 1:m StateAssignedSchID using "`temp_combined'"
drop if _merge==1


//Dropping if lowest grade is 9th grade
drop if sch_lowest_grade_offered > 8 & !missing(sch_lowest_grade_offered)

//Cleaning NCES
gen StateAbbrev = "ME"
gen State = "Maine"
gen StateFips = 23
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename district_agency_type DistType
rename county_code CountyCode
rename county_name CountyName
rename ncesschoolid NCESSchoolID
gen SchYear = "2014-15"
rename school_type SchType

//StudentGroup and StudentSubGroup
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

//GradeLevel
gen GradeLevel = "G38"

//Proficiency Criteria
gen ProficiencyCriteria = "Levels 3 and 4"

//AssmtName
gen AssmtName = "Smarter Balanced Assessment"
replace AssmtName = "Maine Educational Assessment" if Subject == "sci"

//AssmtType
gen AssmtType = "Regular"

//Generating Missing Variables
foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
	gen Lev`n'_percent = "--"
}
gen Lev5_count =.
gen Lev5_percent =.
gen AvgScaleScore = "--"

//Flags
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read=.
gen Flag_CutScoreChange_oth = "Y"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/ME_AssmtData_2015", replace
clear

