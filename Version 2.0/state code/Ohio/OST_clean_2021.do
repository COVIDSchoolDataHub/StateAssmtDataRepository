clear
set more off

cd "/Users/miramehta/Documents"

global raw "/Users/miramehta/Documents/OH State Testing Data"
global output "/Users/miramehta/Documents/OH State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"
global NCES_clean "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global dta "/Users/miramehta/Documents/OH State Testing Data/dta"
global csv "/Users/miramehta/Documents/OH State Testing Data/CSV"

import excel "${raw}/OH_OriginalData_District_2021.xlsx", sheet("Performance_Indicators") firstrow

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

//Percentages
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
	
//Other Variables
gen DataLevel = "District"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested =.
gen StudentSubGroup_TotalTested =.

gen AssmtName = "Ohio's State Tests (OST)"
gen SchName = "All Schools"
gen StateAssignedSchID = ""
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "N"  
gen Flag_CutScoreChange_math = "N"  
gen Flag_CutScoreChange_read = ""  
gen Flag_CutScoreChange_oth = "N"  
gen AssmtType = "Regular"
gen Lev1_count = "--"
gen Lev1_percent = "--" 
gen Lev2_count = "--" 
gen Lev2_percent = "--" 
gen Lev3_count = "--" 
gen Lev3_percent = "--" 
gen Lev4_count = "--" 
gen Lev4_percent = "--"  
gen Lev5_count = "--"  
gen Lev5_percent = "--" 
gen AvgScaleScore = "--"  
gen ProficientOrAbove_count = "--" 
gen ParticipationRate = "--"

save "${output}/OH_AssmtData_2021.dta", replace

* Gender Files
import excel "${raw}/OH_OriginalData_Gender_District_2021.xlsx", sheet("GENDER") clear
drop C D T U V W X Y Z AA AB AC AD AE AF AG AH AI

rename A StateAssignedDistID
rename B DistName
rename E StudentSubGroup
rename F ProficientOrAbove_pct_G03_ela
rename G ProficientOrAbove_pct_G03_math
rename H ProficientOrAbove_pct_G04_ela
rename I ProficientOrAbove_pct_G04_math
rename J ProficientOrAbove_pct_G05_ela
rename K ProficientOrAbove_pct_G05_math
rename L ProficientOrAbove_pct_G05_sci
rename M ProficientOrAbove_pct_G06_ela
rename N ProficientOrAbove_pct_G06_math
rename O ProficientOrAbove_pct_G07_ela
rename P ProficientOrAbove_pct_G07_math
rename Q ProficientOrAbove_pct_G08_ela
rename R ProficientOrAbove_pct_G08_math
rename S ProficientOrAbove_pct_G08_sci

drop if StateAssignedDistID == "District IRN"

//Reshape Data
reshape long ProficientOrAbove_pct, i(StateAssignedDistID StudentSubGroup) j(GradeLevel) string

gen Subject = "math"
replace Subject = "ela" if GradeLevel == "_G03_ela"
replace Subject = "ela" if GradeLevel == "_G04_ela"
replace Subject = "ela" if GradeLevel == "_G05_ela"
replace Subject = "ela" if GradeLevel == "_G06_ela"
replace Subject = "ela" if GradeLevel == "_G07_ela"
replace Subject = "ela" if GradeLevel == "_G08_ela"
replace Subject = "sci" if GradeLevel == "_G05_sci"
replace Subject = "sci" if GradeLevel == "_G08_sci"

replace GradeLevel = "G03" if GradeLevel == "_G03_math"
replace GradeLevel = "G03" if GradeLevel == "_G03_ela"
replace GradeLevel = "G04" if GradeLevel == "_G04_math"
replace GradeLevel = "G04" if GradeLevel == "_G04_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_math"
replace GradeLevel = "G05" if GradeLevel == "_G05_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_sci"
replace GradeLevel = "G06" if GradeLevel == "_G06_math"
replace GradeLevel = "G06" if GradeLevel == "_G06_ela"
replace GradeLevel = "G07" if GradeLevel == "_G07_math"
replace GradeLevel = "G07" if GradeLevel == "_G07_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_math"
replace GradeLevel = "G08" if GradeLevel == "_G08_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_sci"

rename ProficientOrAbove_pct ProficientOrAbove_percent

//Percentages
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Other Variables
gen DataLevel = "District"
gen StudentGroup = "Gender"
replace StudentSubGroup = "Female" if StudentSubGroup == "FEMALE"
replace StudentSubGroup = "Male" if StudentSubGroup == "MALE"
gen StudentGroup_TotalTested =.
gen StudentSubGroup_TotalTested =.

gen AssmtName = "Ohio's State Tests (OST)"
gen SchName = "All Schools"
gen StateAssignedSchID = ""
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "N"  
gen Flag_CutScoreChange_math = "N"  
gen Flag_CutScoreChange_read = ""  
gen Flag_CutScoreChange_oth = "N"  
gen AssmtType = "Regular"
gen Lev1_count = "--" 
gen Lev1_percent = "--" 
gen Lev2_count = "--" 
gen Lev2_percent = "--" 
gen Lev3_count = "--" 
gen Lev3_percent = "--" 
gen Lev4_count = "--" 
gen Lev4_percent = "--"  
gen Lev5_count = "--"  
gen Lev5_percent = "--" 
gen AvgScaleScore = "--"  
gen ProficientOrAbove_count = "--" 
gen ParticipationRate = "--"

save "${dta}/OH_DistData_Gender_2021.dta", replace

* EL Status Files
import excel "${raw}/OH_OriginalData_EL Status_District_2021.xlsx", sheet("ENGLEARN") clear
drop C D T U V W X Y Z AA AB AC AD AE AF AG AH AI

rename A StateAssignedDistID
rename B DistName
rename E StudentSubGroup
rename F ProficientOrAbove_pct_G03_ela
rename G ProficientOrAbove_pct_G03_math
rename H ProficientOrAbove_pct_G04_ela
rename I ProficientOrAbove_pct_G04_math
rename J ProficientOrAbove_pct_G05_ela
rename K ProficientOrAbove_pct_G05_math
rename L ProficientOrAbove_pct_G05_sci
rename M ProficientOrAbove_pct_G06_ela
rename N ProficientOrAbove_pct_G06_math
rename O ProficientOrAbove_pct_G07_ela
rename P ProficientOrAbove_pct_G07_math
rename Q ProficientOrAbove_pct_G08_ela
rename R ProficientOrAbove_pct_G08_math
rename S ProficientOrAbove_pct_G08_sci

drop if StateAssignedDistID == "District IRN"

//Reshape Data
reshape long ProficientOrAbove_pct, i(StateAssignedDistID StudentSubGroup) j(GradeLevel) string

gen Subject = "math"
replace Subject = "ela" if GradeLevel == "_G03_ela"
replace Subject = "ela" if GradeLevel == "_G04_ela"
replace Subject = "ela" if GradeLevel == "_G05_ela"
replace Subject = "ela" if GradeLevel == "_G06_ela"
replace Subject = "ela" if GradeLevel == "_G07_ela"
replace Subject = "ela" if GradeLevel == "_G08_ela"
replace Subject = "sci" if GradeLevel == "_G05_sci"
replace Subject = "sci" if GradeLevel == "_G08_sci"

replace GradeLevel = "G03" if GradeLevel == "_G03_math"
replace GradeLevel = "G03" if GradeLevel == "_G03_ela"
replace GradeLevel = "G04" if GradeLevel == "_G04_math"
replace GradeLevel = "G04" if GradeLevel == "_G04_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_math"
replace GradeLevel = "G05" if GradeLevel == "_G05_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_sci"
replace GradeLevel = "G06" if GradeLevel == "_G06_math"
replace GradeLevel = "G06" if GradeLevel == "_G06_ela"
replace GradeLevel = "G07" if GradeLevel == "_G07_math"
replace GradeLevel = "G07" if GradeLevel == "_G07_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_math"
replace GradeLevel = "G08" if GradeLevel == "_G08_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_sci"

rename ProficientOrAbove_pct ProficientOrAbove_percent

//Percentages
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Other Variables
gen DataLevel = "District"
gen StudentGroup = "EL Status"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ENGLEARN"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "NOTENGLEARN"
gen StudentGroup_TotalTested =.
gen StudentSubGroup_TotalTested =.

gen AssmtName = "Ohio's State Tests (OST)"
gen SchName = "All Schools"
gen StateAssignedSchID = ""
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "N"  
gen Flag_CutScoreChange_math = "N"  
gen Flag_CutScoreChange_read = ""  
gen Flag_CutScoreChange_oth = "N"  
gen AssmtType = "Regular"
gen Lev1_count = "--" 
gen Lev1_percent = "--" 
gen Lev2_count = "--" 
gen Lev2_percent = "--" 
gen Lev3_count = "--" 
gen Lev3_percent = "--" 
gen Lev4_count = "--" 
gen Lev4_percent = "--"  
gen Lev5_count = "--"  
gen Lev5_percent = "--" 
gen AvgScaleScore = "--"  
gen ProficientOrAbove_count = "--" 
gen ParticipationRate = "--"

save "${dta}/OH_DistData_EL Status_2021.dta", replace

* Economic Status Files
import excel "${raw}/OH_OriginalData_Econ_District_2021.xlsx", sheet("ECON_DISADV") clear
drop C D T U V W X Y Z AA AB AC AD AE AF AG AH AI

rename A StateAssignedDistID
rename B DistName
rename E StudentSubGroup
rename F ProficientOrAbove_pct_G03_ela
rename G ProficientOrAbove_pct_G03_math
rename H ProficientOrAbove_pct_G04_ela
rename I ProficientOrAbove_pct_G04_math
rename J ProficientOrAbove_pct_G05_ela
rename K ProficientOrAbove_pct_G05_math
rename L ProficientOrAbove_pct_G05_sci
rename M ProficientOrAbove_pct_G06_ela
rename N ProficientOrAbove_pct_G06_math
rename O ProficientOrAbove_pct_G07_ela
rename P ProficientOrAbove_pct_G07_math
rename Q ProficientOrAbove_pct_G08_ela
rename R ProficientOrAbove_pct_G08_math
rename S ProficientOrAbove_pct_G08_sci

drop if StateAssignedDistID == "District IRN"

//Reshape Data
reshape long ProficientOrAbove_pct, i(StateAssignedDistID StudentSubGroup) j(GradeLevel) string

gen Subject = "math"
replace Subject = "ela" if GradeLevel == "_G03_ela"
replace Subject = "ela" if GradeLevel == "_G04_ela"
replace Subject = "ela" if GradeLevel == "_G05_ela"
replace Subject = "ela" if GradeLevel == "_G06_ela"
replace Subject = "ela" if GradeLevel == "_G07_ela"
replace Subject = "ela" if GradeLevel == "_G08_ela"
replace Subject = "sci" if GradeLevel == "_G05_sci"
replace Subject = "sci" if GradeLevel == "_G08_sci"

replace GradeLevel = "G03" if GradeLevel == "_G03_math"
replace GradeLevel = "G03" if GradeLevel == "_G03_ela"
replace GradeLevel = "G04" if GradeLevel == "_G04_math"
replace GradeLevel = "G04" if GradeLevel == "_G04_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_math"
replace GradeLevel = "G05" if GradeLevel == "_G05_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_sci"
replace GradeLevel = "G06" if GradeLevel == "_G06_math"
replace GradeLevel = "G06" if GradeLevel == "_G06_ela"
replace GradeLevel = "G07" if GradeLevel == "_G07_math"
replace GradeLevel = "G07" if GradeLevel == "_G07_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_math"
replace GradeLevel = "G08" if GradeLevel == "_G08_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_sci"

rename ProficientOrAbove_pct ProficientOrAbove_percent

//Percentages
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Other Variables
gen DataLevel = "District"
gen StudentGroup = "Economic Status"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECONDISADV"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NOTECONDISADV"
gen StudentGroup_TotalTested =.
gen StudentSubGroup_TotalTested =.

gen AssmtName = "Ohio's State Tests (OST)"
gen SchName = "All Schools"
gen StateAssignedSchID = "" 
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "N"  
gen Flag_CutScoreChange_math = "N"  
gen Flag_CutScoreChange_read = ""  
gen Flag_CutScoreChange_oth = "N"  
gen AssmtType = "Regular"
gen Lev1_count = "--" 
gen Lev1_percent = "--" 
gen Lev2_count = "--" 
gen Lev2_percent = "--" 
gen Lev3_count = "--" 
gen Lev3_percent = "--" 
gen Lev4_count = "--" 
gen Lev4_percent = "--"  
gen Lev5_count = "--"  
gen Lev5_percent = "--" 
gen AvgScaleScore = "--"  
gen ProficientOrAbove_count = "--" 
gen ParticipationRate = "--"

save "${dta}/OH_DistData_Econ Status_2021.dta", replace

* RaceEth Files
import excel "${raw}/OH_OriginalData_RaceEth_District_2021.xlsx", sheet("RACE") clear
drop C D T U V W X Y Z AA AB AC AD AE AF AG AH AI

rename A StateAssignedDistID
rename B DistName
rename E StudentSubGroup
rename F ProficientOrAbove_pct_G03_ela
rename G ProficientOrAbove_pct_G03_math
rename H ProficientOrAbove_pct_G04_ela
rename I ProficientOrAbove_pct_G04_math
rename J ProficientOrAbove_pct_G05_ela
rename K ProficientOrAbove_pct_G05_math
rename L ProficientOrAbove_pct_G05_sci
rename M ProficientOrAbove_pct_G06_ela
rename N ProficientOrAbove_pct_G06_math
rename O ProficientOrAbove_pct_G07_ela
rename P ProficientOrAbove_pct_G07_math
rename Q ProficientOrAbove_pct_G08_ela
rename R ProficientOrAbove_pct_G08_math
rename S ProficientOrAbove_pct_G08_sci

drop if StateAssignedDistID == "District IRN"

//Reshape Data
reshape long ProficientOrAbove_pct, i(StateAssignedDistID StudentSubGroup) j(GradeLevel) string

gen Subject = "math"
replace Subject = "ela" if GradeLevel == "_G03_ela"
replace Subject = "ela" if GradeLevel == "_G04_ela"
replace Subject = "ela" if GradeLevel == "_G05_ela"
replace Subject = "ela" if GradeLevel == "_G06_ela"
replace Subject = "ela" if GradeLevel == "_G07_ela"
replace Subject = "ela" if GradeLevel == "_G08_ela"
replace Subject = "sci" if GradeLevel == "_G05_sci"
replace Subject = "sci" if GradeLevel == "_G08_sci"

replace GradeLevel = "G03" if GradeLevel == "_G03_math"
replace GradeLevel = "G03" if GradeLevel == "_G03_ela"
replace GradeLevel = "G04" if GradeLevel == "_G04_math"
replace GradeLevel = "G04" if GradeLevel == "_G04_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_math"
replace GradeLevel = "G05" if GradeLevel == "_G05_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_sci"
replace GradeLevel = "G06" if GradeLevel == "_G06_math"
replace GradeLevel = "G06" if GradeLevel == "_G06_ela"
replace GradeLevel = "G07" if GradeLevel == "_G07_math"
replace GradeLevel = "G07" if GradeLevel == "_G07_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_math"
replace GradeLevel = "G08" if GradeLevel == "_G08_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_sci"

rename ProficientOrAbove_pct ProficientOrAbove_percent

//Percentages
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Other Variables
gen DataLevel = "District"
gen StudentGroup = "RaceEth"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "AMERICAN INDIAN OR ALASKAN NATIVE"
replace StudentSubGroup = "Asian" if StudentSubGroup == "ASIAN"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "BLACK, NON-HISPANIC"
replace StudentSubGroup = "White" if StudentSubGroup == "WHITE, NON-HISPANIC"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "HISPANIC"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "MULTIRACIAL"
gen StudentGroup_TotalTested =.
gen StudentSubGroup_TotalTested =.

gen AssmtName = "Ohio's State Tests (OST)" 
gen SchName = "All Schools"
gen StateAssignedSchID = ""
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "N"  
gen Flag_CutScoreChange_math = "N"  
gen Flag_CutScoreChange_read = ""  
gen Flag_CutScoreChange_oth = "N"  
gen AssmtType = "Regular"
gen Lev1_count = "--" 
gen Lev1_percent = "--" 
gen Lev2_count = "--" 
gen Lev2_percent = "--" 
gen Lev3_count = "--" 
gen Lev3_percent = "--" 
gen Lev4_count = "--" 
gen Lev4_percent = "--"  
gen Lev5_count = "--"  
gen Lev5_percent = "--" 
gen AvgScaleScore = "--"  
gen ProficientOrAbove_count = "--" 
gen ParticipationRate = "--"

save "${dta}/OH_DistData_RaceEth_2021.dta", replace

//School Data - All Students
import excel "${raw}/OH_OriginalData_School_2021.xlsx", sheet("Performance_Indicators") clear

drop E F H J L N P R T V X Z AB AD AF AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename G ProficientOrAbove_pct_G03_ela
rename I ProficientOrAbove_pct_G03_math
rename K ProficientOrAbove_pct_G04_ela
rename M ProficientOrAbove_pct_G04_math
rename O ProficientOrAbove_pct_G05_ela
rename Q ProficientOrAbove_pct_G05_math
rename S ProficientOrAbove_pct_G05_sci
rename U ProficientOrAbove_pct_G06_ela
rename W ProficientOrAbove_pct_G06_math
rename Y ProficientOrAbove_pct_G07_ela
rename AA ProficientOrAbove_pct_G07_math
rename AC ProficientOrAbove_pct_G08_ela
rename AE ProficientOrAbove_pct_G08_math
rename AG ProficientOrAbove_pct_G08_sci

drop if StateAssignedSchID == "Building IRN"

//Reshape Data
reshape long ProficientOrAbove_pct, i(StateAssignedDistID StateAssignedSchID) j(GradeLevel) string

gen Subject = "math"
replace Subject = "ela" if GradeLevel == "_G03_ela"
replace Subject = "ela" if GradeLevel == "_G04_ela"
replace Subject = "ela" if GradeLevel == "_G05_ela"
replace Subject = "ela" if GradeLevel == "_G06_ela"
replace Subject = "ela" if GradeLevel == "_G07_ela"
replace Subject = "ela" if GradeLevel == "_G08_ela"
replace Subject = "sci" if GradeLevel == "_G05_sci"
replace Subject = "sci" if GradeLevel == "_G08_sci"

replace GradeLevel = "G03" if GradeLevel == "_G03_math"
replace GradeLevel = "G03" if GradeLevel == "_G03_ela"
replace GradeLevel = "G04" if GradeLevel == "_G04_math"
replace GradeLevel = "G04" if GradeLevel == "_G04_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_math"
replace GradeLevel = "G05" if GradeLevel == "_G05_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_sci"
replace GradeLevel = "G06" if GradeLevel == "_G06_math"
replace GradeLevel = "G06" if GradeLevel == "_G06_ela"
replace GradeLevel = "G07" if GradeLevel == "_G07_math"
replace GradeLevel = "G07" if GradeLevel == "_G07_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_math"
replace GradeLevel = "G08" if GradeLevel == "_G08_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_sci"

rename ProficientOrAbove_pct ProficientOrAbove_percent

//Percentages
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Other Variables
gen DataLevel = "School"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested =.
gen StudentSubGroup_TotalTested =.

gen AssmtName = "Ohio's State Tests (OST)" 
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "N"  
gen Flag_CutScoreChange_math = "N"  
gen Flag_CutScoreChange_read = ""  
gen Flag_CutScoreChange_oth = "N"  
gen AssmtType = "Regular"
gen Lev1_count = "--" 
gen Lev1_percent = "--" 
gen Lev2_count = "--" 
gen Lev2_percent = "--" 
gen Lev3_count = "--" 
gen Lev3_percent = "--" 
gen Lev4_count = "--" 
gen Lev4_percent = "--"  
gen Lev5_count = "--"  
gen Lev5_percent = "--" 
gen AvgScaleScore = "--"  
gen ProficientOrAbove_count = "--" 
gen ParticipationRate = "--"

save "${dta}/OH_SchoolData_2021.dta", replace

* Gender Files
import excel "${raw}/OH_OriginalData_Gender_School_2021.xlsx", sheet("GENDER") clear
drop E F V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename G StudentSubGroup
rename H ProficientOrAbove_pct_G03_ela
rename I ProficientOrAbove_pct_G03_math
rename J ProficientOrAbove_pct_G04_ela
rename K ProficientOrAbove_pct_G04_math
rename L ProficientOrAbove_pct_G05_ela
rename M ProficientOrAbove_pct_G05_math
rename N ProficientOrAbove_pct_G05_sci
rename O ProficientOrAbove_pct_G06_ela
rename P ProficientOrAbove_pct_G06_math
rename Q ProficientOrAbove_pct_G07_ela
rename R ProficientOrAbove_pct_G07_math
rename S ProficientOrAbove_pct_G08_ela
rename T ProficientOrAbove_pct_G08_math
rename U ProficientOrAbove_pct_G08_sci

drop if StateAssignedSchID == "Building IRN"

//Reshape Data
reshape long ProficientOrAbove_pct, i(StateAssignedDistID StateAssignedSchID StudentSubGroup) j(GradeLevel) string

gen Subject = "math"
replace Subject = "ela" if GradeLevel == "_G03_ela"
replace Subject = "ela" if GradeLevel == "_G04_ela"
replace Subject = "ela" if GradeLevel == "_G05_ela"
replace Subject = "ela" if GradeLevel == "_G06_ela"
replace Subject = "ela" if GradeLevel == "_G07_ela"
replace Subject = "ela" if GradeLevel == "_G08_ela"
replace Subject = "sci" if GradeLevel == "_G05_sci"
replace Subject = "sci" if GradeLevel == "_G08_sci"

replace GradeLevel = "G03" if GradeLevel == "_G03_math"
replace GradeLevel = "G03" if GradeLevel == "_G03_ela"
replace GradeLevel = "G04" if GradeLevel == "_G04_math"
replace GradeLevel = "G04" if GradeLevel == "_G04_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_math"
replace GradeLevel = "G05" if GradeLevel == "_G05_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_sci"
replace GradeLevel = "G06" if GradeLevel == "_G06_math"
replace GradeLevel = "G06" if GradeLevel == "_G06_ela"
replace GradeLevel = "G07" if GradeLevel == "_G07_math"
replace GradeLevel = "G07" if GradeLevel == "_G07_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_math"
replace GradeLevel = "G08" if GradeLevel == "_G08_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_sci"

rename ProficientOrAbove_pct ProficientOrAbove_percent

//Percentages
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Other Variables
gen DataLevel = "School"
gen StudentGroup = "Gender"
replace StudentSubGroup = "Female" if StudentSubGroup == "FEMALE"
replace StudentSubGroup = "Male" if StudentSubGroup == "MALE"
gen StudentGroup_TotalTested =.
gen StudentSubGroup_TotalTested =.

gen AssmtName = "Ohio's State Tests (OST)" 
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "N"  
gen Flag_CutScoreChange_math = "N"  
gen Flag_CutScoreChange_read = ""  
gen Flag_CutScoreChange_oth = "N"  
gen AssmtType = "Regular"
gen Lev1_count = "--" 
gen Lev1_percent = "--" 
gen Lev2_count = "--" 
gen Lev2_percent = "--" 
gen Lev3_count = "--" 
gen Lev3_percent = "--" 
gen Lev4_count = "--" 
gen Lev4_percent = "--"  
gen Lev5_count = "--"  
gen Lev5_percent = "--" 
gen AvgScaleScore = "--"  
gen ProficientOrAbove_count = "--" 
gen ParticipationRate = "--"

save "${dta}/OH_SchoolData_Gender_2021.dta", replace

* EL Status Files
import excel "${raw}/OH_OriginalData_EL Status_School_2021.xlsx", sheet("ENGLEARN") clear
drop E F V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename G StudentSubGroup
rename H ProficientOrAbove_pct_G03_ela
rename I ProficientOrAbove_pct_G03_math
rename J ProficientOrAbove_pct_G04_ela
rename K ProficientOrAbove_pct_G04_math
rename L ProficientOrAbove_pct_G05_ela
rename M ProficientOrAbove_pct_G05_math
rename N ProficientOrAbove_pct_G05_sci
rename O ProficientOrAbove_pct_G06_ela
rename P ProficientOrAbove_pct_G06_math
rename Q ProficientOrAbove_pct_G07_ela
rename R ProficientOrAbove_pct_G07_math
rename S ProficientOrAbove_pct_G08_ela
rename T ProficientOrAbove_pct_G08_math
rename U ProficientOrAbove_pct_G08_sci

drop if StateAssignedSchID == "Building IRN"

//Reshape Data
reshape long ProficientOrAbove_pct, i(StateAssignedDistID StateAssignedSchID StudentSubGroup) j(GradeLevel) string

gen Subject = "math"
replace Subject = "ela" if GradeLevel == "_G03_ela"
replace Subject = "ela" if GradeLevel == "_G04_ela"
replace Subject = "ela" if GradeLevel == "_G05_ela"
replace Subject = "ela" if GradeLevel == "_G06_ela"
replace Subject = "ela" if GradeLevel == "_G07_ela"
replace Subject = "ela" if GradeLevel == "_G08_ela"
replace Subject = "sci" if GradeLevel == "_G05_sci"
replace Subject = "sci" if GradeLevel == "_G08_sci"

replace GradeLevel = "G03" if GradeLevel == "_G03_math"
replace GradeLevel = "G03" if GradeLevel == "_G03_ela"
replace GradeLevel = "G04" if GradeLevel == "_G04_math"
replace GradeLevel = "G04" if GradeLevel == "_G04_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_math"
replace GradeLevel = "G05" if GradeLevel == "_G05_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_sci"
replace GradeLevel = "G06" if GradeLevel == "_G06_math"
replace GradeLevel = "G06" if GradeLevel == "_G06_ela"
replace GradeLevel = "G07" if GradeLevel == "_G07_math"
replace GradeLevel = "G07" if GradeLevel == "_G07_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_math"
replace GradeLevel = "G08" if GradeLevel == "_G08_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_sci"

rename ProficientOrAbove_pct ProficientOrAbove_percent

//Percentages
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Other Variables
gen DataLevel = "School"
gen StudentGroup = "EL Status"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ENGLEARN"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "NOTENGLEARN"
gen StudentGroup_TotalTested =.
gen StudentSubGroup_TotalTested =.

gen AssmtName = "Ohio's State Tests (OST)" 
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "N"  
gen Flag_CutScoreChange_math = "N"  
gen Flag_CutScoreChange_read = ""  
gen Flag_CutScoreChange_oth = "N"  
gen AssmtType = "Regular"
gen Lev1_count = "--" 
gen Lev1_percent = "--" 
gen Lev2_count = "--" 
gen Lev2_percent = "--" 
gen Lev3_count = "--" 
gen Lev3_percent = "--" 
gen Lev4_count = "--" 
gen Lev4_percent = "--"  
gen Lev5_count = "--"  
gen Lev5_percent = "--" 
gen AvgScaleScore = "--"  
gen ProficientOrAbove_count = "--" 
gen ParticipationRate = "--"

save "${dta}/OH_SchoolData_EL Status_2021.dta", replace

* Economic Status Files
import excel "${raw}/OH_OriginalData_Econ_School_2021.xlsx", sheet("ECON_DISADV") clear
drop E F V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename G StudentSubGroup
rename H ProficientOrAbove_pct_G03_ela
rename I ProficientOrAbove_pct_G03_math
rename J ProficientOrAbove_pct_G04_ela
rename K ProficientOrAbove_pct_G04_math
rename L ProficientOrAbove_pct_G05_ela
rename M ProficientOrAbove_pct_G05_math
rename N ProficientOrAbove_pct_G05_sci
rename O ProficientOrAbove_pct_G06_ela
rename P ProficientOrAbove_pct_G06_math
rename Q ProficientOrAbove_pct_G07_ela
rename R ProficientOrAbove_pct_G07_math
rename S ProficientOrAbove_pct_G08_ela
rename T ProficientOrAbove_pct_G08_math
rename U ProficientOrAbove_pct_G08_sci

drop if StateAssignedSchID == "Building IRN"

//Reshape Data
reshape long ProficientOrAbove_pct, i(StateAssignedDistID StateAssignedSchID StudentSubGroup) j(GradeLevel) string

gen Subject = "math"
replace Subject = "ela" if GradeLevel == "_G03_ela"
replace Subject = "ela" if GradeLevel == "_G04_ela"
replace Subject = "ela" if GradeLevel == "_G05_ela"
replace Subject = "ela" if GradeLevel == "_G06_ela"
replace Subject = "ela" if GradeLevel == "_G07_ela"
replace Subject = "ela" if GradeLevel == "_G08_ela"
replace Subject = "sci" if GradeLevel == "_G05_sci"
replace Subject = "sci" if GradeLevel == "_G08_sci"

replace GradeLevel = "G03" if GradeLevel == "_G03_math"
replace GradeLevel = "G03" if GradeLevel == "_G03_ela"
replace GradeLevel = "G04" if GradeLevel == "_G04_math"
replace GradeLevel = "G04" if GradeLevel == "_G04_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_math"
replace GradeLevel = "G05" if GradeLevel == "_G05_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_sci"
replace GradeLevel = "G06" if GradeLevel == "_G06_math"
replace GradeLevel = "G06" if GradeLevel == "_G06_ela"
replace GradeLevel = "G07" if GradeLevel == "_G07_math"
replace GradeLevel = "G07" if GradeLevel == "_G07_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_math"
replace GradeLevel = "G08" if GradeLevel == "_G08_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_sci"

rename ProficientOrAbove_pct ProficientOrAbove_percent

//Percentages
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Other Variables
gen DataLevel = "School"
gen StudentGroup = "Economic Status"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECONDISADV"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NOTECONDISADV"
gen StudentGroup_TotalTested =.
gen StudentSubGroup_TotalTested =.

gen AssmtName = "Ohio's State Tests (OST)" 
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "N"  
gen Flag_CutScoreChange_math = "N"  
gen Flag_CutScoreChange_read = ""  
gen Flag_CutScoreChange_oth = "N"  
gen AssmtType = "Regular"
gen Lev1_count = "--" 
gen Lev1_percent = "--" 
gen Lev2_count = "--" 
gen Lev2_percent = "--" 
gen Lev3_count = "--" 
gen Lev3_percent = "--" 
gen Lev4_count = "--" 
gen Lev4_percent = "--"  
gen Lev5_count = "--"  
gen Lev5_percent = "--" 
gen AvgScaleScore = "--"  
gen ProficientOrAbove_count = "--" 
gen ParticipationRate = "--"

save "${dta}/OH_SchoolData_Econ Status_2021.dta", replace

* RaceEth Files
import excel "${raw}/OH_OriginalData_RaceEth_School_2021.xlsx", sheet("RACE") clear
drop E F V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename G StudentSubGroup
rename H ProficientOrAbove_pct_G03_ela
rename I ProficientOrAbove_pct_G03_math
rename J ProficientOrAbove_pct_G04_ela
rename K ProficientOrAbove_pct_G04_math
rename L ProficientOrAbove_pct_G05_ela
rename M ProficientOrAbove_pct_G05_math
rename N ProficientOrAbove_pct_G05_sci
rename O ProficientOrAbove_pct_G06_ela
rename P ProficientOrAbove_pct_G06_math
rename Q ProficientOrAbove_pct_G07_ela
rename R ProficientOrAbove_pct_G07_math
rename S ProficientOrAbove_pct_G08_ela
rename T ProficientOrAbove_pct_G08_math
rename U ProficientOrAbove_pct_G08_sci

drop if StateAssignedSchID == "Building IRN"

//Reshape Data
reshape long ProficientOrAbove_pct, i(StateAssignedDistID StateAssignedSchID StudentSubGroup) j(GradeLevel) string

gen Subject = "math"
replace Subject = "ela" if GradeLevel == "_G03_ela"
replace Subject = "ela" if GradeLevel == "_G04_ela"
replace Subject = "ela" if GradeLevel == "_G05_ela"
replace Subject = "ela" if GradeLevel == "_G06_ela"
replace Subject = "ela" if GradeLevel == "_G07_ela"
replace Subject = "ela" if GradeLevel == "_G08_ela"
replace Subject = "sci" if GradeLevel == "_G05_sci"
replace Subject = "sci" if GradeLevel == "_G08_sci"

replace GradeLevel = "G03" if GradeLevel == "_G03_math"
replace GradeLevel = "G03" if GradeLevel == "_G03_ela"
replace GradeLevel = "G04" if GradeLevel == "_G04_math"
replace GradeLevel = "G04" if GradeLevel == "_G04_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_math"
replace GradeLevel = "G05" if GradeLevel == "_G05_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_sci"
replace GradeLevel = "G06" if GradeLevel == "_G06_math"
replace GradeLevel = "G06" if GradeLevel == "_G06_ela"
replace GradeLevel = "G07" if GradeLevel == "_G07_math"
replace GradeLevel = "G07" if GradeLevel == "_G07_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_math"
replace GradeLevel = "G08" if GradeLevel == "_G08_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_sci"

rename ProficientOrAbove_pct ProficientOrAbove_percent

//Percentages
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

//Other Variables
gen DataLevel = "School"
gen StudentGroup = "RaceEth"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "AMERICAN INDIAN OR ALASKAN NATIVE"
replace StudentSubGroup = "Asian" if StudentSubGroup == "ASIAN"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "BLACK, NON-HISPANIC"
replace StudentSubGroup = "White" if StudentSubGroup == "WHITE, NON-HISPANIC"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "HISPANIC"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "MULTIRACIAL"
gen StudentGroup_TotalTested =.
gen StudentSubGroup_TotalTested =.

gen AssmtName = "Ohio's State Tests (OST)" 
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "N"  
gen Flag_CutScoreChange_math = "N"  
gen Flag_CutScoreChange_read = ""  
gen Flag_CutScoreChange_oth = "N"  
gen AssmtType = "Regular"
gen Lev1_count = "--" 
gen Lev1_percent = "--" 
gen Lev2_count = "--" 
gen Lev2_percent = "--" 
gen Lev3_count = "--" 
gen Lev3_percent = "--" 
gen Lev4_count = "--" 
gen Lev4_percent = "--"  
gen Lev5_count = "--"  
gen Lev5_percent = "--" 
gen AvgScaleScore = "--"  
gen ProficientOrAbove_count = "--" 
gen ParticipationRate = "--"

save "${dta}/OH_SchoolData_RaceEth_2021.dta", replace

* Cleaning NCES Data
use "${NCES}/NCES District Files, Fall 1997-Fall 2021/NCES_2020_District.dta", clear
drop if state_location != "OH"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 9)
replace state_leaid = StateAssignedDistID
save "$NCES_clean/NCES_2021_District_OH.dta", replace

use "${NCES}/NCES School Files, Fall 1997-Fall 2021/NCES_2020_School.dta", clear
drop if state_location != "OH"
gen str StateAssignedDistID = substr(state_leaid, 4, 9)
gen str StateAssignedSchID = substr(seasch, 8, 13)
replace state_leaid = StateAssignedDistID
replace seasch = StateAssignedSchID
save "$NCES_clean/NCES_2021_School_OH.dta", replace

* Merge Data
use "$output/OH_AssmtData_2021.dta", clear
append using "${dta}/OH_DistData_Gender_2021.dta" "${dta}/OH_DistData_EL Status_2021.dta" "${dta}/OH_DistData_Econ Status_2021.dta" "${dta}/OH_DistData_RaceEth_2021.dta" "${dta}/OH_SchoolData_2021.dta" "${dta}/OH_SchoolData_Gender_2021.dta" "${dta}/OH_SchoolData_EL Status_2021.dta" "${dta}/OH_SchoolData_Econ Status_2021.dta" "${dta}/OH_SchoolData_RaceEth_2021.dta"

merge m:1 StateAssignedDistID using "$NCES_clean/NCES_2021_District_OH.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES_clean/NCES_2021_School_OH.dta", gen (merge2)
drop if merge2 == 2

save "$output/OH_AssmtData_2021.dta", replace

* Extracting and cleaning 2021 State Data

use "${dta}/OH_AssmtData_2021.dta", clear

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
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

tostring *State*, replace

reshape long StateG3 StateG4 StateG5 StateG6 StateG7 StateG8, i(DataLevel) j(Subject) string 

reshape long State, i(Subject) j(GradeLevel) string 

rename State ProficientOrAbove_percent
replace ProficientOrAbove_percent="-" if ProficientOrAbove_percent==""
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="NC"

gen AssmtName = "Ohio's State Tests (OST)" 
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "N"  
gen Flag_CutScoreChange_math = "N"  
gen Flag_CutScoreChange_read = ""  
gen Flag_CutScoreChange_oth = "N"  
gen AssmtType = "Regular"
gen Lev1_count = "--" 
gen Lev1_percent = "--" 
gen Lev2_count = "--" 
gen Lev2_percent = "--" 
gen Lev3_count = "--" 
gen Lev3_percent = "--" 
gen Lev4_count = "--" 
gen Lev4_percent = "--"  
gen Lev5_count = "--"  
gen Lev5_percent = "--" 
gen AvgScaleScore = "--"  
gen ProficientOrAbove_count = "--" 
gen ParticipationRate = "--"
gen SchName = "All Schools"
gen DistName = "All Districts"

//Percentages
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

save "${dta}/OH_AssmtData_state_2021.dta", replace

*Append and clean 

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
rename district_agency_type DistType
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename school_type SchType
gen ProficiencyCriteria= "Levels 3, 4, 5"

replace StateAbbrev="OH"
replace StateFips=39

replace GradeLevel = "G03" if GradeLevel == "G3"
replace GradeLevel = "G04" if GradeLevel == "G4"
replace GradeLevel = "G05" if GradeLevel == "G5"
replace GradeLevel = "G06" if GradeLevel == "G6"
replace GradeLevel = "G07" if GradeLevel == "G7"
replace GradeLevel = "G08" if GradeLevel == "G8"

replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

//Variable Types
decode DistType, gen(DistType_s)
drop DistType
rename DistType_s DistType

decode SchType, gen(SchType_s)
drop SchType
rename SchType_s SchType

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchVirtual, gen(SchVirtual_s)
drop SchVirtual
rename SchVirtual_s SchVirtual

//Unmerged Schools
replace DistName = "Citizens Academy" if SchName == "Citizens Academy"
replace NCESDistrictID = "3900032" if SchName == "Citizens Academy"
replace State_leaid = "133520" if SchName == "Citizens Academy"
replace DistCharter = "Yes" if SchName == "Citizens Academy"
replace DistType = "Charter agency" if SchName == "Citizens Academy"
replace NCESSchoolID = "390003202833" if SchName == "Citizens Academy"
replace SchType = "Regular school" if SchName == "Citizens Academy"
replace seasch = "133520" if SchName == "Citizens Academy"
replace SchLevel = "Primary" if SchName == "Citizens Academy"
replace SchVirtual = "No" if SchName == "Citizens Academy"
replace CountyName = "Cuyahoga County" if SchName == "Citizens Academy"
replace CountyCode = 39035 if SchName == "Citizens Academy"

replace DistName = "Citizens Academy Southeast" if SchName == "Citizens Academy Southeast"
replace NCESDistrictID = "3901570" if SchName == "Citizens Academy Southeast"
replace State_leaid = "015261" if SchName == "Citizens Academy Southeast"
replace DistCharter = "Yes" if SchName == "Citizens Academy Southeast"
replace DistType = "Charter agency" if SchName == "Citizens Academy Southeast"
replace NCESSchoolID = "390157005844" if SchName == "Citizens Academy Southeast"
replace SchType = "Regular school" if SchName == "Citizens Academy Southeast"
replace seasch = "015261" if SchName == "Citizens Academy Southeast"
replace SchLevel = "Primary" if SchName == "Citizens Academy Southeast"
replace SchVirtual = "No" if SchName == "Citizens Academy Southeast"
replace CountyName = "Cuyahoga County" if SchName == "Citizens Academy Southeast"
replace CountyCode = 39035 if SchName == "Citizens Academy Southeast"

replace DistName = "Citizens Leadership Academy" if SchName == "Citizens Leadership Academy"
replace NCESDistrictID = "3901444" if SchName == "Citizens Leadership Academy"
replace State_leaid = "012029" if SchName == "Citizens Leadership Academy"
replace DistCharter = "Yes" if SchName == "Citizens Leadership Academy"
replace DistType = "Charter agency" if SchName == "Citizens Leadership Academy"
replace NCESSchoolID = "390144405673" if SchName == "Citizens Leadership Academy"
replace SchType = "Regular school" if SchName == "Citizens Leadership Academy"
replace seasch = "012029" if SchName == "Citizens Leadership Academy"
replace SchLevel = "Middle" if SchName == "Citizens Leadership Academy"
replace SchVirtual = "No" if SchName == "Citizens Leadership Academy"
replace CountyName = "Cuyahoga County" if SchName == "Citizens Leadership Academy"
replace CountyCode = 39035 if SchName == "Citizens Leadership Academy"

replace DistName = "Citizens Leadership Academy East" if SchName == "Citizens Leadership Academy East"
replace NCESDistrictID = "3901594" if SchName == "Citizens Leadership Academy East"
replace State_leaid = "016843" if SchName == "Citizens Leadership Academy East"
replace DistCharter = "Yes" if SchName == "Citizens Leadership Academy East"
replace DistType = "Charter agency" if SchName == "Citizens Leadership Academy East"
replace NCESSchoolID = "390159405904" if SchName == "Citizens Leadership Academy East"
replace SchType = "Regular school" if SchName == "Citizens Leadership Academy East"
replace seasch = "016843" if SchName == "Citizens Leadership Academy East"
replace SchLevel = "Primary" if SchName == "Citizens Leadership Academy East"
replace SchVirtual = "No" if SchName == "Citizens Leadership Academy East"
replace CountyName = "Cuyahoga County" if SchName == "Citizens Leadership Academy East"
replace CountyCode = 39035 if SchName == "Citizens Leadership Academy East"

replace DistName = "Cleveland College Preparatory School" if SchName == "Cleveland College Preparatory School"
replace NCESDistrictID = "3901397" if SchName == "Cleveland College Preparatory School"
replace State_leaid = "012010" if SchName == "Cleveland College Preparatory School"
replace DistCharter = "Yes" if SchName == "Cleveland College Preparatory School"
replace DistType = "Charter agency" if SchName == "Cleveland College Preparatory School"
replace NCESSchoolID = "390139705615" if SchName == "Cleveland College Preparatory School"
replace SchType = "Regular school" if SchName == "Cleveland College Preparatory School"
replace seasch = "012010" if SchName == "Cleveland College Preparatory School"
replace SchLevel = "Primary" if SchName == "Cleveland College Preparatory School"
replace SchVirtual = "No" if SchName == "Cleveland College Preparatory School"
replace CountyName = "Cuyahoga County" if SchName == "Cleveland College Preparatory School"
replace CountyCode = 39035 if SchName == "Cleveland College Preparatory School"

replace DistName = "Foxfire Intermediate School" if SchName == "Foxfire Intermediate School"
replace NCESDistrictID = "3901407" if SchName == "Foxfire Intermediate School"
replace State_leaid = "012033" if SchName == "Foxfire Intermediate School"
replace DistCharter = "Yes" if SchName == "Foxfire Intermediate School"
replace DistType = "Charter agency" if SchName == "Foxfire Intermediate School"
replace NCESSchoolID = "390140705576" if SchName == "Foxfire Intermediate School"
replace SchType = "Regular school" if SchName == "Foxfire Intermediate School"
replace seasch = "012033" if SchName == "Foxfire Intermediate School"
replace SchLevel = "Missing/not reported" if SchName == "Foxfire Intermediate School"
replace SchVirtual = "Missing/not reported" if SchName == "Foxfire Intermediate School"
replace CountyName = "Muskingum County" if SchName == "Foxfire Intermediate School"
replace CountyCode = 39119 if SchName == "Foxfire Intermediate School"

replace DistName = "Hope Academy Northwest Campus" if SchName == "Hope Academy Northwest Campus"
replace NCESDistrictID = "3900313" if SchName == "Hope Academy Northwest Campus"
replace State_leaid = "000575" if SchName == "Hope Academy Northwest Campus"
replace DistCharter = "Yes" if SchName == "Hope Academy Northwest Campus"
replace DistType = "Charter agency" if SchName == "Hope Academy Northwest Campus"
replace NCESSchoolID = "390031304850" if SchName == "Hope Academy Northwest Campus"
replace SchType = "Regular school" if SchName == "Hope Academy Northwest Campus"
replace seasch = "000575" if SchName == "Hope Academy Northwest Campus"
replace SchLevel = "Primary" if SchName == "Hope Academy Northwest Campus"
replace SchVirtual = "No" if SchName == "Hope Academy Northwest Campus"
replace CountyName = "Cuyahoga County" if SchName == "Hope Academy Northwest Campus"
replace CountyCode = 39035 if SchName == "Hope Academy Northwest Campus"

replace DistName = "Horizon Science Academy-cleveland Middle School" if SchName == "Horizon Science Acad Cleveland"
replace NCESDistrictID = "3900470" if SchName == "Horizon Science Acad Cleveland"
replace State_leaid = "000858" if SchName == "Horizon Science Acad Cleveland"
replace DistCharter = "Yes" if SchName == "Horizon Science Acad Cleveland"
replace DistType = "Charter agency" if SchName == "Horizon Science Acad Cleveland"
replace NCESSchoolID = "390047005029" if SchName == "Horizon Science Acad Cleveland"
replace SchType = "Regular school" if SchName == "Horizon Science Acad Cleveland"
replace seasch = "000858" if SchName == "Horizon Science Acad Cleveland"
replace SchLevel = "High" if SchName == "Horizon Science Acad Cleveland"
replace SchVirtual = "No" if SchName == "Horizon Science Acad Cleveland"
replace CountyName = "Cuyahoga County" if SchName == "Horizon Science Acad Cleveland"
replace CountyCode = 39035 if SchName == "Horizon Science Acad Cleveland"

replace DistName = "Menlo Park Academy" if SchName == "Menlo Park Academy"
replace NCESDistrictID = "3900505" if SchName == "Menlo Park Academy"
replace State_leaid = "000318" if SchName == "Menlo Park Academy"
replace DistCharter = "Yes" if SchName == "Menlo Park Academy"
replace DistType = "Charter agency" if SchName == "Menlo Park Academy"
replace NCESSchoolID = "390050505215" if SchName == "Menlo Park Academy"
replace SchType = "Regular school" if SchName == "Menlo Park Academy"
replace seasch = "000318" if SchName == "Menlo Park Academy"
replace SchLevel = "Primary" if SchName == "Menlo Park Academy"
replace SchVirtual = "No" if SchName == "Menlo Park Academy"
replace CountyName = "Cuyahoga County" if SchName == "Menlo Park Academy"
replace CountyCode = 39035 if SchName == "Menlo Park Academy"

replace DistName = "Near West Intergenerational School" if SchName == "Near West Intergenerational School"
replace NCESDistrictID = "3901405" if SchName == "Near West Intergenerational School"
replace State_leaid = "012030" if SchName == "Near West Intergenerational School"
replace DistCharter = "Yes" if SchName == "Near West Intergenerational School"
replace DistType = "Charter agency" if SchName == "Near West Intergenerational School"
replace NCESSchoolID = "390140505596" if SchName == "Near West Intergenerational School"
replace SchType = "Regular school" if SchName == "Near West Intergenerational School"
replace seasch = "012030" if SchName == "Near West Intergenerational School"
replace SchLevel = "Primary" if SchName == "Near West Intergenerational School"
replace SchVirtual = "No" if SchName == "Near West Intergenerational School"
replace CountyName = "Cuyahoga County" if SchName == "Near West Intergenerational School"
replace CountyCode = 39035 if SchName == "Near West Intergenerational School"

replace DistName = "Northeast Ohio College Preparatory School" if SchName == "Northeast Ohio College Preparatory School"
replace NCESDistrictID = "3901376" if SchName == "Northeast Ohio College Preparatory School"
replace State_leaid = "011923" if SchName == "Northeast Ohio College Preparatory School"
replace DistCharter = "Yes" if SchName == "Northeast Ohio College Preparatory School"
replace DistType = "Charter agency" if SchName == "Northeast Ohio College Preparatory School"
replace NCESSchoolID = "390142005577" if SchName == "Northeast Ohio College Preparatory School"
replace SchType = "Regular school" if SchName == "Northeast Ohio College Preparatory School"
replace seasch = "011923" if SchName == "Northeast Ohio College Preparatory School"
replace SchLevel = "Other" if SchName == "Northeast Ohio College Preparatory School"
replace SchVirtual = "No" if SchName == "Northeast Ohio College Preparatory School"
replace CountyName = "Cuyahoga County" if SchName == "Northeast Ohio College Preparatory School"
replace CountyCode = 39035 if SchName == "Northeast Ohio College Preparatory School"

replace DistName = "Quaker Preparatory Academy" if SchName == "Quaker Preparatory Academy"
replace NCESDistrictID = "3901619" if SchName == "Quaker Preparatory Academy"
replace State_leaid = "019156" if SchName == "Quaker Preparatory Academy"
replace DistCharter = "Yes" if SchName == "Quaker Preparatory Academy"
replace DistType = "Charter agency" if SchName == "Quaker Preparatory Academy"
replace NCESSchoolID = "390161906019" if SchName == "Quaker Preparatory Academy"
replace SchType = "Regular school" if SchName == "Quaker Preparatory Academy"
replace seasch = "019156" if SchName == "Quaker Preparatory Academy"
replace SchLevel = "Primary" if SchName == "Quaker Preparatory Academy"
replace SchVirtual = "Yes" if SchName == "Quaker Preparatory Academy"
replace CountyName = "Tuscarawas County" if SchName == "Quaker Preparatory Academy"
replace CountyCode = 39157 if SchName == "Quaker Preparatory Academy"

replace DistName = "Stepstone Academy" if SchName == "Stepstone Academy"
replace NCESDistrictID = "3901498" if SchName == "Stepstone Academy"
replace State_leaid = "013148" if SchName == "Stepstone Academy"
replace DistCharter = "Yes" if SchName == "Stepstone Academy"
replace DistType = "Charter agency" if SchName == "Stepstone Academy"
replace NCESSchoolID = "390149805759" if SchName == "Stepstone Academy"
replace SchType = "Regular school" if SchName == "Stepstone Academy"
replace seasch = "013148" if SchName == "Stepstone Academy"
replace SchLevel = "Primary" if SchName == "Stepstone Academy"
replace SchVirtual = "No" if SchName == "Stepstone Academy"
replace CountyName = "Cuyahoga County" if SchName == "Stepstone Academy"
replace CountyCode = 39035 if SchName == "Stepstone Academy"

replace DistName = "Village Preparatory School Cliffs" if SchName == "Village Preparatory School Cliffs"
replace NCESDistrictID = "3901368" if SchName == "Village Preparatory School Cliffs"
replace State_leaid = "011291" if SchName == "Village Preparatory School Cliffs"
replace DistCharter = "Yes" if SchName == "Village Preparatory School Cliffs"
replace DistType = "Charter agency" if SchName == "Village Preparatory School Cliffs"
replace NCESSchoolID = "390136805528" if SchName == "Village Preparatory School Cliffs"
replace SchType = "Regular school" if SchName == "Village Preparatory School Cliffs"
replace seasch = "011291" if SchName == "Village Preparatory School Cliffs"
replace SchLevel = "Primary" if SchName == "Village Preparatory School Cliffs"
replace SchVirtual = "No" if SchName == "Village Preparatory School Cliffs"
replace CountyName = "Cuyahoga County" if SchName == "Village Preparatory School Cliffs"
replace CountyCode = 39035 if SchName == "Village Preparatory School Cliffs"

replace DistName = "Village Preparatory School Willard" if SchName == "Village Preparatory School Willard"
replace NCESDistrictID = "3901581" if SchName == "Village Preparatory School Willard"
replace State_leaid = "015722" if SchName == "Village Preparatory School Willard"
replace DistCharter = "Yes" if SchName == "Village Preparatory School Willard"
replace DistType = "Charter agency" if SchName == "Village Preparatory School Willard"
replace NCESSchoolID = "390158105885" if SchName == "Village Preparatory School Willard"
replace SchType = "Regular school" if SchName == "Village Preparatory School Willard"
replace seasch = "015722" if SchName == "Village Preparatory School Willard"
replace SchLevel = "Other" if SchName == "Village Preparatory School Willard"
replace SchVirtual = "Missing/not reported" if SchName == "Village Preparatory School Willard"
replace CountyName = "Cuyahoga County" if SchName == "Village Preparatory School Willard"
replace CountyCode = 39035 if SchName == "Village Preparatory School Willard"

replace DistName = "Village Preparatory School Woodland Hills" if SchName == "Village Preparatory School Woodland Hills"
replace NCESDistrictID = "3901505" if SchName == "Village Preparatory School Woodland Hills"
replace State_leaid = "013034" if SchName == "Village Preparatory School Woodland Hills"
replace DistCharter = "Yes" if SchName == "Village Preparatory School Woodland Hills"
replace DistType = "Charter agency" if SchName == "Village Preparatory School Woodland Hills"
replace NCESSchoolID = "390150505720" if SchName == "Village Preparatory School Woodland Hills"
replace SchType = "Regular school" if SchName == "Village Preparatory School Woodland Hills"
replace seasch = "013034" if SchName == "Village Preparatory School Woodland Hills"
replace SchLevel = "Primary" if SchName == "Village Preparatory School Woodland Hills"
replace SchVirtual = "No" if SchName == "Village Preparatory School Woodland Hills"
replace CountyName = "Cuyahoga County" if SchName == "Village Preparatory School Woodland Hills"
replace CountyCode = 39035 if SchName == "Village Preparatory School Woodland Hills"

replace DistName = "Wings Academy 1" if SchName == "Wings Academy 1"
replace NCESDistrictID = "3900399" if SchName == "Wings Academy 1"
replace State_leaid = "000736" if SchName == "Wings Academy 1"
replace DistCharter = "Yes" if SchName == "Wings Academy 1"
replace DistType = "Charter agency" if SchName == "Wings Academy 1"
replace NCESSchoolID = "390039904959" if SchName == "Wings Academy 1"
replace SchType = "Regular school" if SchName == "Wings Academy 1"
replace seasch = "000736" if SchName == "Wings Academy 1"
replace SchLevel = "Primary" if SchName == "Wings Academy 1"
replace SchVirtual = "No" if SchName == "Wings Academy 1"
replace CountyName = "Cuyahoga County" if SchName == "Wings Academy 1"
replace CountyCode = 39035 if SchName == "Wings Academy 1"

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

drop state_name _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch lea_name agency_charter_indicator dist_agency_charter_indicator BV BW BX BY BZ CA CB CC CD CE CF CG CH CI

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType  Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/OH_AssmtData_2021.dta", replace

export delimited "${output}/OH_AssmtData_2021.csv", replace
