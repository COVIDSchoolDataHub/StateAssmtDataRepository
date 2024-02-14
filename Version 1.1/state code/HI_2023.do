clear
set more off
local Original "/Volumes/T7/State Test Project/Hawaii/Original Data"
local Output "/Volumes/T7/State Test Project/Hawaii/Cleaned Data"
local NCES "/Volumes/T7/State Test Project/NCES"


tempfile temp1
save "`temp1'", emptyok

 **Importing and Renaming**
import excel "`Original'/HI_OriginalData_ela_math_2023", sheet(STATE)
rename A GradeLevel
rename B StudentSubGroup_TotalTestedela
rename C ProficientOrAbove_countela
rename D ProficientOrAbove_percentela
rename E StudentSubGroup_TotalTestedmath
rename F ProficientOrAbove_countmath
rename G ProficientOrAbove_percentmath
gen DataLevel = "State"
drop in 1/7
tempfile tempstate
save "`tempstate'", replace
clear
import excel "`Original'/HI_OriginalData_ela_math_2023", sheet(SCHOOLS)
drop A
drop B
rename C StateAssignedSchID
rename D SchName
rename E GradeLevel
rename F StudentSubGroup_TotalTestedela
rename G ProficientOrAbove_percentela
rename H StudentSubGroup_TotalTestedmath
rename I ProficientOrAbove_percentmath
gen DataLevel = "School"
drop in 1/7
tempfile tempsch
save "`tempsch'", replace
clear


//Reshaping from Wide to Long for ELA/Math
use "`temp1'"
append using "`tempstate'" "`tempsch'"
replace StateAssignedSchID = StateAssignedSchID[_n-1] if missing(StateAssignedSchID)
replace SchName = SchName[_n-1] if missing(SchName)
drop if missing(GradeLevel)
replace SchName = "" if DataLevel == "State"
reshape long ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(SchName GradeLevel) j(Subject, string)
save "`temp1'", replace
clear

//Science
import excel "`Original'/HI_OriginalData_sci_2023", sheet(STATE)
rename A GradeLevel
rename B StudentSubGroup_TotalTested
rename C ProficientOrAbove_count
rename D ProficientOrAbove_percent
drop in 1
gen DataLevel = "State"
gen Subject = "sci"
tempfile tempsci1
save "`tempsci1'", replace
clear
import excel "`Original'/HI_OriginalData_sci_2023", sheet(SCHOOLS)
drop A
drop B
rename C StateAssignedSchID
rename D SchName
rename E GradeLevel
rename F StudentSubGroup_TotalTested
rename G ProficientOrAbove_percent
gen DataLevel = "School"
gen Subject = "sci"
drop in 1
drop if missing(GradeLevel)
replace StateAssignedSchID = StateAssignedSchID[_n-1] if missing(StateAssignedSchID)
replace SchName = SchName[_n-1] if missing(SchName)
tempfile tempsci2
save "`tempsci2'"
clear

use "`temp1'"
append using "`tempsci1'" "`tempsci2'"

//Trimming Spaces
foreach var of varlist _all {
	cap replace `var' = trim(`var')
}


//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel != 3
tempfile temp2
save "`temp2'", replace
keep if DataLevel ==1
replace DataLevel = 2
gen DistName = "Hawaii Department of Education"
gen StateAssignedDistID = "HI-001"
gen NCESDistrictID = "1500030"
append using "`temp2'"
replace DistName = "All Districts" if DataLevel == 1
sort DataLevel
replace DistName = "Hawaii Department of Education" if DataLevel == 3
replace StateAssignedDistID = "HI-001" if DataLevel == 3
replace NCESDistrictID = "1500030" if DataLevel == 3

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.)
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//Merging NCES
tempfile temp1
save "`temp1'", replace
clear

//District 
use "`temp1'"
keep if DataLevel == 2
tempfile tempdistrict
save "`tempdistrict'", replace
clear
use "`NCES'/NCES_2022_District"
gen NCESDistrictID = ncesdistrictid
merge 1:m NCESDistrictID using "`tempdistrict'"
drop if _merge == 1
save "`tempdistrict'", replace
clear

//Schools
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear
use "`NCES'/NCES_2022_School"
keep if state_location == "HI" | state_name == 15
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-") +1,4)
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge ==1
save "`tempsch'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel ==1
append using "`tempdistrict'" "`tempsch'"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename school_type SchType
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 15
replace StateAbbrev = "HI"

//Information Variables
gen State = "Hawaii"
gen SchYear = "2022-23"
gen ProficiencyCriteria = "Level 3 or 4"
gen AssmtName = "Smarter Balanced Assessment" if Subject != "sci"
gen AssmtType = "Regular"
replace AssmtName = "Hawaii State Assessment - NGSS" if Subject == "sci"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

//Missing Variables
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)
foreach n in 1 2 3 4 {
	gen Lev`n'_percent = "--"
	gen Lev`n'_count = "--"
}
gen AvgScaleScore = "--"
gen Lev5_count = ""
gen Lev5_percent = ""
gen ParticipationRate = ""

//ProficientOrAbove_percent Formatting
replace ProficientOrAbove_percent = string(real(ProficientOrAbove_percent), "%9.4g") if ProficientOrAbove_percent != "*"

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
gen Flag_CutScoreChange_read = ""



//Final Cleaning for SBAC
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/HI_AssmtData_2023", replace
export delimited "`Output'/HI_AssmtData_2023", replace
clear

//Strive

//Importing and Renaming
import excel "`Original'/HI_2023_Strive.xls", firstrow case(preserve) allstring
keep MathProficiency LAProficiency ScienceProficiency SchoolID SchoolType SubgroupDescription MathParticipation LAParticipation ScienceParticipation
rename MathProficiency ProficientOrAbove_percentmath
rename LAProficiency ProficientOrAbove_percentela
rename ScienceProficiency ProficientOrAbove_percentsci 
rename SchoolID StateAssignedSchID
rename SchoolType Level
rename SubgroupDescription StudentSubGroup
rename MathParticipation ParticipationRatemath
rename LAParticipation ParticipationRateela
rename ScienceParticipation ParticipationRatesci

//Dropping High School Data and empty data
drop if missing(StateAssignedSchID)
keep if Level != "High"
tab Level, missing
drop Level

//Generating Variables
gen GradeLevel = "G38"

//StudentSubGroup
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup, "Asian") !=0
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup, "Black") !=0
replace StudentSubGroup = "Economically Disadvantaged" if strpos(StudentSubGroup, "Disadvantaged") !=0
replace StudentSubGroup = "Hispanic or Latino" if strpos(StudentSubGroup, "Hispanic") !=0
replace StudentSubGroup = "English Learner" if strpos(StudentSubGroup, "English") !=0
replace StudentSubGroup = "Native Hawaiian" if strpos(StudentSubGroup, "Hawaiian") !=0 
replace StudentSubGroup = "Pacific Islander" if strpos(StudentSubGroup, "Pacific") !=0
replace StudentSubGroup = "Filipino" if strpos(StudentSubGroup, "Filipino") !=0
replace StudentSubGroup = "SWD" if strpos(StudentSubGroup, "SPED") !=0
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian" | StudentSubGroup == "Pacific Islander" | StudentSubGroup == "Filipino"| StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD" | StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Native Hawaiian" | StudentSubGroup == "Pacific Islander" | StudentSub == "Filipino"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
//Reshaping
reshape long ParticipationRate ProficientOrAbove_percent, i(StateAssignedSchID StudentSubGroup) j(Subject, string)

//Converting to Decimal
foreach var of varlist ProficientOrAbove_percent ParticipationRate {
	destring `var', gen(n`var') i(*-)
	replace `var' = string(n`var'/100, "%9.3g") if `var' != "--" & `var' != "*" & !missing(`var')
	replace `var' = "*" if missing(`var')
}

//Missing Variables
gen ProficientOrAbove_count = "--"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

//Merging with Cleaned
tempfile temp1 
save "`temp1'", replace
clear
use "`Output'/HI_AssmtData_2023"
duplicates drop StateAssignedSchID, force
keep if DataLevel == 3
drop Subject GradeLevel StudentGroup StudentSubGroup ProficientOrAbove_percent StudentGroup_TotalTested StudentSubGroup_TotalTested ProficientOrAbove_count ParticipationRate
merge 1:m StateAssignedSchID using "`temp1'"
drop if _merge != 3
append using "`Output'/HI_AssmtData_2023"

//NEW S2024 CHANGES:
gen Flag_CutScoreChange_sci = Flag_CutScoreChange_oth
gen Flag_CutScoreChange_soc = ""
replace ProficiencyCriteria = "Levels 3-4"

* Deriving ProficientOrAbove_count where missing
destring ProficientOrAbove_percent, gen(nnProficientOrAbove_percent) i(*-)
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
replace ProficientOrAbove_count = string(round(nnProficientOrAbove_percent * nStudentSubGroup_TotalTested,1), "%9.3g") if ProficientOrAbove_count == "--" & ProficientOrAbove_percent != "*" & ProficientOrAbove_percent != "--" & StudentSubGroup_TotalTested != "*" & StudentSubGroup_TotalTested != "--"

//Final cleaning
replace ParticipationRate = "--" if missing(ParticipationRate)
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "`Output'/HI_AssmtData_2023", replace
export delimited "`Output'/HI_AssmtData_2023", replace
clear





