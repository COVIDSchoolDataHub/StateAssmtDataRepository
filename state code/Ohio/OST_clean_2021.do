clear
set more off

cd "/Users/miramehta/Documents"

global raw "/Users/miramehta/Documents/OH State Testing Data"
global output "/Users/miramehta/Documents/OH State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2021"
global NCES_clean "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global dta "/Users/miramehta/Documents/OH State Testing Data/dta"
global csv "/Users/miramehta/Documents/OH State Testing Data/CSV"

import excel "${raw}/OH_OriginalData_2021_all.xlsx", sheet("Performance_Indicators") firstrow

keep AA AB AC AD AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB DistrictIRN DistrictName N O Q R T U W rdGradeEnglishLanguageArts X Y Z rdGradeMath20202021Percent thGradeEnglishLanguageArts thGradeMath20202021Percent thGradeScience20202021Perc

foreach var of varlist AA AB AC AD AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB DistrictIRN DistrictName N O Q R T U W rdGradeEnglishLanguageArts X Y Z rdGradeMath20202021Percent thGradeEnglishLanguageArts thGradeMath20202021Percent thGradeScience20202021Perc {

  local varlabel : var label `var'
  local newname = subinstr("`varlabel'"," 2020-2021 Percent at or above Proficient - ", "", .)
  label variable `var' "`newname'"
  
}

foreach var of varlist AA AB AC AD AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB DistrictIRN DistrictName N O Q R T U W rdGradeEnglishLanguageArts X Y Z rdGradeMath20202021Percent thGradeEnglishLanguageArts thGradeMath20202021Percent thGradeScience20202021Perc {

  local varlabel : var label `var'
  local newname = subinstr("`varlabel'"," ", "", .)
  label variable `var' "`newname'"
  
}

foreach var of varlist AA AB AC AD AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB DistrictIRN DistrictName N O Q R T U W rdGradeEnglishLanguageArts X Y Z rdGradeMath20202021Percent thGradeEnglishLanguageArts thGradeMath20202021Percent thGradeScience20202021Perc {

  local varlabel : var label `var'
  local newname = substr("`varlabel'",4,.)+substr("`varlabel'",1,3)
  label variable `var' "`newname'"
  
}

foreach var of varlist AA AB AC AD AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB DistrictIRN DistrictName N O Q R T U W rdGradeEnglishLanguageArts X Y Z rdGradeMath20202021Percent thGradeEnglishLanguageArts thGradeMath20202021Percent thGradeScience20202021Perc {
   local x : var label `var'
   rename `var' `x'
}

drop *Simil*
rename *rd* *th*

rename *EnglishLanguageArts* *ELA*

foreach i of numlist 3/8 {
	foreach v of varlist GradeELADistr`i'th {
		local new = substr("`v'", 1, 13)+"ict`i'th"
		rename `v' `new'
	}
}

save "${dta}/OH_AssmtData_2021.dta", replace

drop *State*

rename trictIRNDis StateAssignedDistID
rename trictNameDis DistName

foreach i of numlist 3/8 {
	rename *`i'th* *G`i'*
}

rename *Grade* **

foreach i of numlist 3/8 {
	foreach v of varlist ELADistrictG`i' {
		local new = substr("`v'", 4, .)+"ELA"
		rename `v' `new'
	}
}

foreach i of numlist 3/8 {
	foreach v of varlist MathDistrictG`i' {
		local new = substr("`v'", 5, .)+"Math"
		rename `v' `new'
	}
}

rename ScienceDistrictG5 DistrictG5Science
rename ScienceDistrictG8 DistrictG8Science

reshape long DistrictG3 DistrictG4 DistrictG5 DistrictG6 DistrictG7 DistrictG8, i(StateAssignedDistID) j(Subject) string 

reshape long District, i(StateAssignedDistID Subject) j(GradeLevel) string 

replace Subject="math" if Subject=="Math"
replace Subject="ela" if Subject=="ELA"
replace Subject="soc" if Subject=="SocialStudies"
replace Subject="sci" if Subject=="Science"

rename District ProficientOrAbove_percent

replace ProficientOrAbove_percent="-" if ProficientOrAbove_percent==""
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="NC"
	
gen ProficiencyCriteria="Level 3/4/5"
gen DataLevel="District" 

save "${output}/OH_AssmtData_2021.dta", replace

* Cleaning NCES Data
use "${NCES}/NCES_2020_District.dta", clear
drop if state_location != "OH"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 9)
save "$NCES_clean/NCES_2021_District_OH.dta", replace

* Merge Data
use "$output/OH_AssmtData_2021.dta", clear
merge m:1 StateAssignedDistID using "$NCES_clean/NCES_2021_District_OH.dta"
drop if _merge == 2

save "$output/OH_AssmtData_2021.dta", replace

* Extracting and cleaning 2021 State Data

use "${dta}/OH_AssmtData_2021.dta", replace

drop *District*

rename trictIRNDis StateAssignedDistID
rename trictNameDis DistName

drop StateAssignedDistID DistName


foreach i of numlist 3/8 {
	rename *`i'th* *G`i'*
}

rename *Grade* **

foreach i of numlist 3/8 {
	foreach v of varlist ELAStateG`i' {
		local new = substr("`v'", 4, .)+"ELA"
		rename `v' `new'
	}
}

foreach i of numlist 3/8 {
	foreach v of varlist MathStateG`i' {
		local new = substr("`v'", 5, .)+"Math"
		rename `v' `new'
	}
}

rename ScienceStateG5 StateG5Science
rename ScienceStateG8 StateG8Science

keep if _n==1
gen DataLevel="State" 

tostring *State*, replace

reshape long StateG3 StateG4 StateG5 StateG6 StateG7 StateG8, i(DataLevel) j(Subject) string 

reshape long State, i(Subject) j(GradeLevel) string 

rename State ProficientOrAbove_percent
replace ProficientOrAbove_percent="--" if ProficientOrAbove_percent==""
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="NC"

save "${dta}/OH_AssmtData_state_2021.dta", replace

* Append and clean 

use "${output}/OH_AssmtData_2021.dta", clear

append using "${dta}/OH_AssmtData_state_2021.dta"

gen SchYear="2020-21"
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

gen Prof_percent = ProficientOrAbove_percent
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "*" if Prof_percent == "*"
replace ProficientOrAbove_percent = "--" if Prof_percent == "-"
replace ProficientOrAbove_percent = "--" if Prof_percent == "--"
drop Prof_percent

replace DistName = "All Districts" if DataLevel == "State"
replace SchName = "All Schools"

decode DistType, gen(DistType_s)
drop DistType
rename DistType_s DistType

replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

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

save "${output}/OH_AssmtData_2021.dta", replace

export delimited "${output}/OH_AssmtData_2021.csv", replace
