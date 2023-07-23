clear all
set more off

cd "/Users/miramehta/Documents"

global raw "/Users/miramehta/Documents/OH State Testing Data"
global output "/Users/miramehta/Documents/OH State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2021"
global NCES_clean "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global dta "/Users/miramehta/Documents/OH State Testing Data/dta"
global csv "/Users/miramehta/Documents/OH State Testing Data/CSV"

import excel "${raw}/OH_OriginalData_2016_all.xls", sheet("Performance_Indicators") firstrow clear

* Renaming variables

rename DistrictIRN StateAssignedDistID
rename DistrictName DistName

* Extracting and cleaning 2016 District Data

keep StateAssignedDistID DistName Reading3rdGrade201516ato Math3rdGrade201516atora Reading4thGrade201516ato Math4thGrade201516atora SocialStudies4thGrade201516 Reading5thGrade201516ato Math5thGrade201516atora Science5thGrade201516ato Reading6thGrade201516ato Math6thGrade201516atora SocialStudies6thGrade201516 Reading7thGrade201516ato Math7thGrade201516atora Reading8thGrade201516ato Math8thGrade201516atora Science8thGrade201516ato

rename *201516ato *
rename *201516atora *
rename *201516 *

rename *Grade *Proficient

rename *rd* *th*

foreach i of numlist 3/8 {
	rename *`i'th* *G`i'*
}

foreach i of numlist 3/8 {
	foreach v of varlist ReadingG`i'Proficient {
		local new = substr("`v'", 8, .)+"Reading"
		rename `v' `new'
	}
}

foreach i of numlist 3/8 {
	foreach v of varlist MathG`i'Proficient {
		local new = substr("`v'", 5, .)+"Math"
		rename `v' `new'
	}
}

rename ScienceG5Proficient G5ProficientScience
rename ScienceG8Proficient G8ProficientScience
rename SocialStudiesG4Proficient G4ProficientSocialStudies
rename SocialStudiesG6Proficient G6ProficientSocialStudies

reshape long G3Proficient G4Proficient G5Proficient G6Proficient G7Proficient G8Proficient, i(StateAssignedDistID) j(Subject) string 

rename *Proficient Proficient*

reshape long Proficient, i(StateAssignedDistID Subject) j(GradeLevel) string 

replace Subject="math" if Subject=="Math"
replace Subject="read" if Subject=="Reading"
replace Subject="soc" if Subject=="SocialStudies"
replace Subject="sci" if Subject=="Science"

rename Proficient ProficientOrAbove_percent

replace ProficientOrAbove_percent="-" if ProficientOrAbove_percent==""
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="NC"
	
gen ProficiencyCriteria="Level 3,4,5"
gen DataLevel="District"

save "$dta/OH_AssmtData_2016", replace

* Cleaning NCES Data
use "${NCES}/NCES_2015_District.dta", clear
drop if state_location != "OH"
rename lea_name DistName
gen StateAssignedDistID = state_leaid
save "$NCES_clean/NCES_2016_District_OH.dta", replace

* Merging Data
use "$dta/OH_AssmtData_2016", clear
merge m:1 StateAssignedDistID using "$NCES_clean/NCES_2016_District_OH.dta"

drop if _merge == 2

save "${dta}/OH_AssmtData_2016.dta", replace

* Extracting and cleaning 2016 State Data

import excel "${raw}/OH_OriginalData_2016_all.xls", sheet("Performance_Indicators") firstrow clear

keep P S V Y AB AE AH AK AN AQ AT AW AZ BC BF BI

rename P G3Proficientreading
rename S G3Proficientmath
rename V G4Proficientreading
rename Y G4Proficientmath
rename AB G4Proficientsoc
rename AE G5Proficientreading
rename AH G5Proficientmath
rename AK G5Proficientsci
rename AN G6Proficientreading
rename AQ G6Proficientmath
rename AT G6Proficientsoc
rename AW G7Proficientreading
rename AZ G7Proficientmath
rename BC G8Proficientreading
rename BF G8Proficientmath
rename BI G8Proficientsci

keep if _n==1
gen DataLevel="State" 

reshape long G3Proficient G4Proficient G5Proficient G6Proficient G7Proficient G8Proficient, i(DataLevel) j(Subject) string 

rename *Proficient Proficient*

reshape long Proficient, i(Subject) j(GradeLevel) string 

rename Proficient ProficientOrAbove_percent

tostring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent="-" if ProficientOrAbove_percent==""
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="NC"

save "${dta}/OH_AssmtData_state_2016.dta", replace

* Append and clean 

use "${dta}/OH_AssmtData_2016.dta", clear

append using "${dta}/OH_AssmtData_state_2016.dta"

gen SchYear="2015-16"
drop year

gen State="Ohio"
rename state_location StateAbbrev
rename state_fips StateFips
rename county_name CountyName
rename county_code CountyCode
rename ncesdistrictid NCESDistrictID
gen NCESSchoolID=""
rename district_agency_type DistType
gen SchType=""
gen SchVirtual="" 
gen seasch=""
rename state_leaid State_leaid
gen SchLevel="" 
gen AssmtName="Ohio's State Tests (OST)" 
gen Flag_AssmtNameChange="N" 
gen Flag_CutScoreChange_ELA="N"  
gen Flag_CutScoreChange_math="N"  
gen Flag_CutScoreChange_read="N"  
gen Flag_CutScoreChange_oth="N"  
gen AssmtType="Regular"  
gen SchName="" 
gen StateAssignedSchID="" 
gen StudentGroup="All Students" 
gen StudentGroup_TotalTested="--" 
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested="--" 
gen Lev1_count="--" 
gen Lev1_percent="--" 
gen Lev2_count="--" 
gen Lev2_percent="--" 
gen Lev3_count="--" 
gen Lev3_percent="--" 
gen Lev4_count="--" 
gen Lev4_percent="--"  
gen Lev5_count="--"  
gen Lev5_percent="--" 
gen AvgScaleScore="--"  
gen ProficientOrAbove_count="--" 
gen ParticipationRate="--"

//Final Clean-Up
replace ProficiencyCriteria= "Levels 3, 4, 5"

replace State = "Ohio"
replace StateAbbrev="OH"
replace StateFips=39

replace GradeLevel = "G03" if GradeLevel == "G3"
replace GradeLevel = "G04" if GradeLevel == "G4"
replace GradeLevel = "G05" if GradeLevel == "G5"
replace GradeLevel = "G06" if GradeLevel == "G6"
replace GradeLevel = "G07" if GradeLevel == "G7"
replace GradeLevel = "G08" if GradeLevel == "G8"

replace Subject = "read" if Subject == "reading"

gen Prof_percent = ProficientOrAbove_percent
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "*" if Prof_percent == "*"
replace ProficientOrAbove_percent = "--" if Prof_percent == "-"
replace ProficientOrAbove_percent = "--" if Prof_percent == "."
drop Prof_percent

replace DistName = "All Districts" if DataLevel == "State"
replace SchName = "All Schools"

decode DistType, gen(DistType_s)
drop DistType
rename DistType_s DistType

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistType "District type as defined by NCES"
label var DistCharter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var SchYear "School year in which the data were reported"
label var AssmtName "Name of state assessment"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only"
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only"
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only"
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested"
label var StudentGroup "Student demographic group"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested"
label var StudentSubGroup "Student demographic subgroup"
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested"
label var Lev1_count "Count of students within subgroup performing at Level 1"
label var Lev1_percent "Percent of students within subgroup performing at Level 1"
label var Lev2_count "Count of students within subgroup performing at Level 2"
label var Lev2_percent "Percent of students within subgroup performing at Level 2"
label var Lev3_count "Count of students within subgroup performing at Level 3"
label var Lev3_percent "Percent of students within subgroup performing at Level 3"
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"
label var Lev5_count "Count of students within subgroup performing at Level 5"
label var Lev5_percent "Percent of students within subgroup performing at Level 5"
label var AvgScaleScore "Avg scale score within subgroup"
label var ProficiencyCriteria "Levels included in determining proficiency status"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment"
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment"
label var ParticipationRate "Participation rate"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

drop state_name district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte agency_charter_indicator _merge

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType  Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/OH_AssmtData_2016.dta", replace

export delimited "${output}/OH_AssmtData_2016.csv", replace
