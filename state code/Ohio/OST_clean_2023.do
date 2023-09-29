clear
set more off

cd "/Users/miramehta/Documents"

global raw "/Users/miramehta/Documents/OH State Testing Data"
global output "/Users/miramehta/Documents/OH State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/"
global NCES_clean "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global dta "/Users/miramehta/Documents/OH State Testing Data/dta"
global csv "/Users/miramehta/Documents/OH State Testing Data/CSV"

import excel "${raw}/OH_OriginalData_District_2023.xlsx", sheet("Report_Only_Indicators") firstrow

keep AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT DistrictIRN DistrictName F G I J L M O P Q R S T U V rdGradeEnglishLanguageArts X Y Z rdGradeMath20222023Percent thGradeEnglishLanguageArts thGradeMath20222023Percent thGradeScience20222023Perc

foreach var of varlist AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT DistrictIRN DistrictName F G I J L M O P Q R S T U V rdGradeEnglishLanguageArts X Y Z rdGradeMath20222023Percent thGradeEnglishLanguageArts thGradeMath20222023Percent thGradeScience20222023Perc {

  local varlabel : var label `var'
  local newname = subinstr("`varlabel'"," 2022-2023 Percent Proficient or above - ", "", .)
  label variable `var' "`newname'"
  
}

foreach var of varlist AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT DistrictIRN DistrictName F G I J L M O P Q R S T U V rdGradeEnglishLanguageArts X Y Z rdGradeMath20222023Percent thGradeEnglishLanguageArts thGradeMath20222023Percent thGradeScience20222023Perc {

  local varlabel : var label `var'
  local newname = subinstr("`varlabel'"," ", "", .)
  label variable `var' "`newname'"
  
}

foreach var of varlist AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT DistrictIRN DistrictName F G I J L M O P Q R S T U V rdGradeEnglishLanguageArts X Y Z rdGradeMath20222023Percent thGradeEnglishLanguageArts thGradeMath20222023Percent thGradeScience20222023Perc {

  local varlabel : var label `var'
  local newname = substr("`varlabel'",4,.)+substr("`varlabel'",1,3)
  label variable `var' "`newname'"
  
}

foreach var of varlist AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT DistrictIRN DistrictName F G I J L M O P Q R S T U V rdGradeEnglishLanguageArts X Y Z rdGradeMath20222023Percent thGradeEnglishLanguageArts thGradeMath20222023Percent thGradeScience20222023Perc {

  local varlabel : var label `var'
  local newname = subinstr("`varlabel'","EnglishLanguageArts","ELA",.)
  label variable `var' "`newname'"
  
}

foreach var of varlist AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT DistrictIRN DistrictName F G I J L M O P Q R S T U V rdGradeEnglishLanguageArts X Y Z rdGradeMath20222023Percent thGradeEnglishLanguageArts thGradeMath20222023Percent thGradeScience20222023Perc {
   local x : var label `var'
   rename `var' `x'
}

drop *Simil*
rename *rd* *th*

save "${dta}/OH_AssmtData_2023.dta", replace

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

save "${output}/OH_AssmtData_2023.dta", replace

* Gender Files
import excel "${raw}/OH_OriginalData_Gender_District_2023.xlsx", sheet("GENDER") clear
drop C D F G H W X Y Z AA AB AC AD AE AF AG

rename A StateAssignedDistID
rename B DistName
rename E StudentSubGroup
rename I ProficientOrAbove_pct_G03_ela
rename J ProficientOrAbove_pct_G03_math
rename K ProficientOrAbove_pct_G04_ela
rename L ProficientOrAbove_pct_G04_math
rename M ProficientOrAbove_pct_G05_ela
rename N ProficientOrAbove_pct_G05_math
rename O ProficientOrAbove_pct_G05_sci
rename P ProficientOrAbove_pct_G06_ela
rename Q ProficientOrAbove_pct_G06_math
rename R ProficientOrAbove_pct_G07_ela
rename S ProficientOrAbove_pct_G07_math
rename T ProficientOrAbove_pct_G08_ela
rename U ProficientOrAbove_pct_G08_math
rename V ProficientOrAbove_pct_G08_sci

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

save "${dta}/OH_DistData_Gender_2023.dta", replace

* EL Status Files
import excel "${raw}/OH_OriginalData_EL Status_District_2023.xlsx", sheet("ENGLEARN") clear
drop C D F G H W X Y Z AA AB AC AD AE AF AG

rename A StateAssignedDistID
rename B DistName
rename E StudentSubGroup
rename I ProficientOrAbove_pct_G03_ela
rename J ProficientOrAbove_pct_G03_math
rename K ProficientOrAbove_pct_G04_ela
rename L ProficientOrAbove_pct_G04_math
rename M ProficientOrAbove_pct_G05_ela
rename N ProficientOrAbove_pct_G05_math
rename O ProficientOrAbove_pct_G05_sci
rename P ProficientOrAbove_pct_G06_ela
rename Q ProficientOrAbove_pct_G06_math
rename R ProficientOrAbove_pct_G07_ela
rename S ProficientOrAbove_pct_G07_math
rename T ProficientOrAbove_pct_G08_ela
rename U ProficientOrAbove_pct_G08_math
rename V ProficientOrAbove_pct_G08_sci

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

save "${dta}/OH_DistData_EL Status_2023.dta", replace

* Economic Status Files
import excel "${raw}/OH_OriginalData_Econ_District_2023.xlsx", sheet("ECON_DISADV") clear
drop C D F G H W X Y Z AA AB AC AD AE AF AG

rename A StateAssignedDistID
rename B DistName
rename E StudentSubGroup
rename I ProficientOrAbove_pct_G03_ela
rename J ProficientOrAbove_pct_G03_math
rename K ProficientOrAbove_pct_G04_ela
rename L ProficientOrAbove_pct_G04_math
rename M ProficientOrAbove_pct_G05_ela
rename N ProficientOrAbove_pct_G05_math
rename O ProficientOrAbove_pct_G05_sci
rename P ProficientOrAbove_pct_G06_ela
rename Q ProficientOrAbove_pct_G06_math
rename R ProficientOrAbove_pct_G07_ela
rename S ProficientOrAbove_pct_G07_math
rename T ProficientOrAbove_pct_G08_ela
rename U ProficientOrAbove_pct_G08_math
rename V ProficientOrAbove_pct_G08_sci

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

save "${dta}/OH_DistData_Econ Status_2023.dta", replace

* RaceEth Files
import excel "${raw}/OH_OriginalData_RaceEth_District_2023.xlsx", sheet("RACE") clear
drop C D F G H W X Y Z AA AB AC AD AE AF AG

rename A StateAssignedDistID
rename B DistName
rename E StudentSubGroup
rename I ProficientOrAbove_pct_G03_ela
rename J ProficientOrAbove_pct_G03_math
rename K ProficientOrAbove_pct_G04_ela
rename L ProficientOrAbove_pct_G04_math
rename M ProficientOrAbove_pct_G05_ela
rename N ProficientOrAbove_pct_G05_math
rename O ProficientOrAbove_pct_G05_sci
rename P ProficientOrAbove_pct_G06_ela
rename Q ProficientOrAbove_pct_G06_math
rename R ProficientOrAbove_pct_G07_ela
rename S ProficientOrAbove_pct_G07_math
rename T ProficientOrAbove_pct_G08_ela
rename U ProficientOrAbove_pct_G08_math
rename V ProficientOrAbove_pct_G08_sci

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

save "${dta}/OH_DistData_RaceEth_2023.dta", replace

//School Data - All Students
import excel "${raw}/OH_OriginalData_School_2023.xlsx", sheet("Report_Only_Indicators") clear

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

save "${dta}/OH_SchoolData_2023.dta", replace

* Gender Files
import excel "${raw}/OH_OriginalData_Gender_School_2023.xlsx", sheet("GENDER") clear
drop E F H I J Y Z AA AB AC AD AE AF AG AH AI

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename G StudentSubGroup
rename K ProficientOrAbove_pct_G03_ela
rename L ProficientOrAbove_pct_G03_math
rename M ProficientOrAbove_pct_G04_ela
rename N ProficientOrAbove_pct_G04_math
rename O ProficientOrAbove_pct_G05_ela
rename P ProficientOrAbove_pct_G05_math
rename Q ProficientOrAbove_pct_G05_sci
rename R ProficientOrAbove_pct_G06_ela
rename S ProficientOrAbove_pct_G06_math
rename T ProficientOrAbove_pct_G07_ela
rename U ProficientOrAbove_pct_G07_math
rename V ProficientOrAbove_pct_G08_ela
rename W ProficientOrAbove_pct_G08_math
rename X ProficientOrAbove_pct_G08_sci

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

save "${dta}/OH_SchoolData_Gender_2023.dta", replace

* EL Status Files
import excel "${raw}/OH_OriginalData_EL Status_School_2023.xlsx", sheet("ENGLEARN") clear
drop E F H I J Y Z AA AB AC AD AE AF AG AH AI

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename G StudentSubGroup
rename K ProficientOrAbove_pct_G03_ela
rename L ProficientOrAbove_pct_G03_math
rename M ProficientOrAbove_pct_G04_ela
rename N ProficientOrAbove_pct_G04_math
rename O ProficientOrAbove_pct_G05_ela
rename P ProficientOrAbove_pct_G05_math
rename Q ProficientOrAbove_pct_G05_sci
rename R ProficientOrAbove_pct_G06_ela
rename S ProficientOrAbove_pct_G06_math
rename T ProficientOrAbove_pct_G07_ela
rename U ProficientOrAbove_pct_G07_math
rename V ProficientOrAbove_pct_G08_ela
rename W ProficientOrAbove_pct_G08_math
rename X ProficientOrAbove_pct_G08_sci

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

save "${dta}/OH_SchoolData_EL Status_2023.dta", replace

* Economic Status Files
import excel "${raw}/OH_OriginalData_Econ_School_2023.xlsx", sheet("ECON_DISADV") clear
drop E F H I J Y Z AA AB AC AD AE AF AG AH AI

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename G StudentSubGroup
rename K ProficientOrAbove_pct_G03_ela
rename L ProficientOrAbove_pct_G03_math
rename M ProficientOrAbove_pct_G04_ela
rename N ProficientOrAbove_pct_G04_math
rename O ProficientOrAbove_pct_G05_ela
rename P ProficientOrAbove_pct_G05_math
rename Q ProficientOrAbove_pct_G05_sci
rename R ProficientOrAbove_pct_G06_ela
rename S ProficientOrAbove_pct_G06_math
rename T ProficientOrAbove_pct_G07_ela
rename U ProficientOrAbove_pct_G07_math
rename V ProficientOrAbove_pct_G08_ela
rename W ProficientOrAbove_pct_G08_math
rename X ProficientOrAbove_pct_G08_sci

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

save "${dta}/OH_SchoolData_Econ Status_2023.dta", replace

* RaceEth Files
import excel "${raw}/OH_OriginalData_RaceEth_School_2023.xlsx", sheet("RACE") clear
drop E F H I J Y Z AA AB AC AD AE AF AG AH AI

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename G StudentSubGroup
rename K ProficientOrAbove_pct_G03_ela
rename L ProficientOrAbove_pct_G03_math
rename M ProficientOrAbove_pct_G04_ela
rename N ProficientOrAbove_pct_G04_math
rename O ProficientOrAbove_pct_G05_ela
rename P ProficientOrAbove_pct_G05_math
rename Q ProficientOrAbove_pct_G05_sci
rename R ProficientOrAbove_pct_G06_ela
rename S ProficientOrAbove_pct_G06_math
rename T ProficientOrAbove_pct_G07_ela
rename U ProficientOrAbove_pct_G07_math
rename V ProficientOrAbove_pct_G08_ela
rename W ProficientOrAbove_pct_G08_math
rename X ProficientOrAbove_pct_G08_sci

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

save "${dta}/OH_SchoolData_RaceEth_2023.dta", replace

* Cleaning NCES Data
use "${NCES}/NCES District Files, Fall 1997-Fall 2021/NCES_2021_District.dta", clear
drop if state_location != "OH"
rename lea_name DistName
gen str StateAssignedDistID = substr(state_leaid, 4, 9)
replace state_leaid = StateAssignedDistID
save "$NCES_clean/NCES_2022_District_OH.dta", replace

use "${NCES}/NCES School Files, Fall 1997-Fall 2021/NCES_2021_School.dta", clear
drop if state_location != "OH"
gen str StateAssignedDistID = substr(state_leaid, 4, 9)
gen str StateAssignedSchID = substr(seasch, 8, 13)
replace state_leaid = StateAssignedDistID
replace seasch = StateAssignedSchID
save "$NCES_clean/NCES_2022_School_OH.dta", replace

* Merge Data
use "$output/OH_AssmtData_2023.dta", clear
append using "${dta}/OH_DistData_Gender_2023.dta" "${dta}/OH_DistData_EL Status_2023.dta" "${dta}/OH_DistData_Econ Status_2023.dta" "${dta}/OH_DistData_RaceEth_2023.dta" "${dta}/OH_SchoolData_2023.dta" "${dta}/OH_SchoolData_Gender_2023.dta" "${dta}/OH_SchoolData_EL Status_2023.dta" "${dta}/OH_SchoolData_Econ Status_2023.dta" "${dta}/OH_SchoolData_RaceEth_2023.dta"

merge m:1 StateAssignedDistID using "$NCES_clean/NCES_2022_District_OH.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES_clean/NCES_2022_School_OH.dta", gen (merge2)
drop if merge2 == 2

save "$output/OH_AssmtData_2023.dta", replace

* Extracting and cleaning 2023 State Data

use "${dta}/OH_AssmtData_2023.dta", replace

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

save "${dta}/OH_AssmtData_state_2023.dta", replace

*Append and clean 

use "${output}/OH_AssmtData_2023.dta", clear

append using "${dta}/OH_AssmtData_state_2023.dta"

gen SchYear="2022-23"
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
replace NCESSchoolID = "390436410842" if SchName == "Brecksville-Broadview Heights Elementary School"
replace SchType = "Regular school" if SchName == "Brecksville-Broadview Heights Elementary School"
replace seasch = "019910" if SchName == "Brecksville-Broadview Heights Elementary School"
replace SchLevel = "Primary" if SchName == "Brecksville-Broadview Heights Elementary School"
replace SchVirtual = "Missing/not reported" if SchName == "Brecksville-Broadview Heights Elementary School"

replace NCESSchoolID = "390454910835" if SchName == "Cardinal Autism Resource and Education School (CARES)"
replace SchType = "Regular school" if SchName == "Cardinal Autism Resource and Education School (CARES)"
replace seasch = "020375" if SchName == "Cardinal Autism Resource and Education School (CARES)"
replace SchLevel = "Other" if SchName == "Cardinal Autism Resource and Education School (CARES)"
replace SchVirtual = "Missing/not reported" if SchName == "Cardinal Autism Resource and Education School (CARES)"

replace NCESDistrictID = "3910034" if SchName == "Cincinnati Classical Academy"
replace State_leaid = "019530" if SchName == "Cincinnati Classical Academy"
replace DistCharter = "Yes" if SchName == "Cincinnati Classical Academy"
replace DistType = "Charter agency" if SchName == "Cincinnati Classical Academy"
replace NCESSchoolID = "391003410838" if SchName == "Cincinnati Classical Academy"
replace SchType = "Regular school" if SchName == "Cincinnati Classical Academy"
replace seasch = "019530" if SchName == "Cincinnati Classical Academy"
replace SchLevel = "Primary" if SchName == "Cincinnati Classical Academy"
replace SchVirtual = "Missing/not reported" if SchName == "Cincinnati Classical Academy"
replace CountyName = "Missing/not reported" if SchName == "Cincinnati Classical Academy"

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

replace NCESSchoolID = "390438010826" if SchName == "Columbus Online Academy"
replace SchType = "Regular school" if SchName == "Columbus Online Academy"
replace seasch = "020245" if SchName == "Columbus Online Academy"
replace SchLevel = "Other" if SchName == "Columbus Online Academy"
replace SchVirtual = "Yes" if SchName == "Columbus Online Academy"

replace NCESSchoolID = "390470210855" if SchName == "DCS Virtual"
replace SchType = "Regular school" if SchName == "DCS Virtual"
replace seasch = "020079" if SchName == "DCS Virtual"
replace SchLevel = "Other" if SchName == "DCS Virtual"
replace SchVirtual = "Yes" if SchName == "DCS Virtual"

replace NCESSchoolID = "390473310843" if SchName == "Finneytown Elementary"
replace SchType = "Regular school" if SchName == "Finneytown Elementary"
replace seasch = "019940" if SchName == "Finneytown Elementary"
replace SchLevel = "Primary" if SchName == "Finneytown Elementary"
replace SchVirtual = "Missing/not reported" if SchName == "Finneytown Elementary"

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

replace NCESDistrictID = "3910039" if SchName == "Gateway Online Academy of Ohio"
replace State_leaid = "020078" if SchName == "Gateway Online Academy of Ohio"
replace DistCharter = "Yes" if SchName == "Gateway Online Academy of Ohio"
replace DistType = "Charter agency" if SchName == "Gateway Online Academy of Ohio"
replace NCESSchoolID = "391003910854" if SchName == "Gateway Online Academy of Ohio"
replace SchType = "Regular school" if SchName == "Gateway Online Academy of Ohio"
replace seasch = "020078" if SchName == "Gateway Online Academy of Ohio"
replace SchLevel = "High" if SchName == "Gateway Online Academy of Ohio"
replace SchVirtual = "Yes" if SchName == "Gateway Online Academy of Ohio"
replace CountyName = "Missing/not reported" if SchName == "Gateway Online Academy of Ohio"

replace DistName = "Horizon Science Academy-cleveland Middle School" if SchName == "Horizon Science Acad Cleveland"
replace NCESDistrictID = "3900470" if SchName == "Horizon Science Acad Cleveland"
replace State_leaid = "000858" if SchName == "Horizon Science Acad Cleveland"
replace DistCharter = "Yes" if SchName == "Horizon Science Acad Cleveland"
replace DistType = "Charter agency" if SchName == "Horizon Science Acad Cleveland"
replace NCESSchoolID = "390047005029" if SchName == "Horizon Science Acad Cleveland"
replace SchType = "Regular school" if SchName == "Horizon Science Acad Cleveland"
replace seasch = "000858" if SchName == "Horizon Science Acad Cleveland"
replace SchLevel = "Missing/not reported" if SchName == "Horizon Science Acad Cleveland"
replace SchVirtual = "Missing/not reported" if SchName == "Horizon Science Acad Cleveland"
replace CountyName = "Cuyahoga County" if SchName == "Horizon Science Acad Cleveland"
replace CountyCode = 39035 if SchName == "Horizon Science Acad Cleveland"

replace NCESDistrictID = "3910035" if SchName == "IDEA Greater Cincinnati, Inc"
replace State_leaid = "020007" if SchName == "IDEA Greater Cincinnati, Inc"
replace DistCharter = "Yes" if SchName == "IDEA Greater Cincinnati, Inc"
replace DistType = "Charter agency" if SchName == "IDEA Greater Cincinnati, Inc"
replace NCESSchoolID = "391003510847" if SchName == "IDEA Greater Cincinnati, Inc"
replace SchType = "Regular school" if SchName == "IDEA Greater Cincinnati, Inc"
replace seasch = "020007" if SchName == "IDEA Greater Cincinnati, Inc"
replace SchLevel = "Missing/not reported" if SchName == "IDEA Greater Cincinnati, Inc"
replace SchVirtual = "Missing/not reported" if SchName == "IDEA Greater Cincinnati, Inc"
replace CountyName = "Missing/not reported" if SchName == "IDEA Greater Cincinnati, Inc"

replace DistName = "Intergenerational School, The" if SchName == "Intergenerational School, The"
replace NCESDistrictID = "3900065" if SchName == "Intergenerational School, The"
replace State_leaid = "133215" if SchName == "Intergenerational School, The"
replace DistCharter = "Yes" if SchName == "Intergenerational School, The"
replace DistType = "Charter agency" if SchName == "Intergenerational School, The"
replace NCESSchoolID = "390006503248" if SchName == "Intergenerational School, The"
replace SchType = "Regular school" if SchName == "Intergenerational School, The"
replace seasch = "133215" if SchName == "Intergenerational School, The"
replace SchLevel = "Primary" if SchName == "Intergenerational School, The"
replace SchVirtual = "No" if SchName == "Intergenerational School, The"
replace CountyName = "Cuyahoga County" if SchName == "Intergenerational School, The"
replace CountyCode = 39035 if SchName == "Intergenerational School, The"

replace NCESSchoolID = "390479810845" if SchName == "JOHNSTOWN INTERMEDIATE SCHOOL"
replace SchType = "Regular school" if SchName == "JOHNSTOWN INTERMEDIATE SCHOOL"
replace seasch = "019946" if SchName == "JOHNSTOWN INTERMEDIATE SCHOOL"
replace SchLevel = "Missing/not reported" if SchName == "JOHNSTOWN INTERMEDIATE SCHOOL"
replace SchVirtual = "Missing/not reported" if SchName == "JOHNSTOWN INTERMEDIATE SCHOOL"

replace DistName = "Lakeshore Intergenerational School" if SchName == "Lakeshore Intergenerational School"
replace NCESDistrictID = "3901564" if SchName == "Lakeshore Intergenerational School"
replace State_leaid = "014913" if SchName == "Lakeshore Intergenerational School"
replace DistCharter = "Yes" if SchName == "Lakeshore Intergenerational School"
replace DistType = "Charter agency" if SchName == "Lakeshore Intergenerational School"
replace NCESSchoolID = "390156405843" if SchName == "Lakeshore Intergenerational School"
replace SchType = "Regular school" if SchName == "Lakeshore Intergenerational School"
replace seasch = "014913" if SchName == "Lakeshore Intergenerational School"
replace SchLevel = "Primary" if SchName == "Lakeshore Intergenerational School"
replace SchVirtual = "No" if SchName == "Lakeshore Intergenerational School"
replace CountyName = "Cuyahoga County" if SchName == "Lakeshore Intergenerational School"
replace CountyCode = 39035 if SchName == "Lakeshore Intergenerational School"

replace NCESSchoolID = "390461110849" if SchName == "Lakota Central"
replace SchType = "Regular school" if SchName == "Lakota Central"
replace seasch = "020059" if SchName == "Lakota Central"
replace SchLevel = "High" if SchName == "Lakota Central"
replace SchVirtual = "Missing/not reported" if SchName == "Lakota Central"

replace NCESDistrictID = "3910040" if SchName == "Legacy Academy of Excellence"
replace State_leaid = "020091" if SchName == "Legacy Academy of Excellence"
replace DistCharter = "Yes" if SchName == "Legacy Academy of Excellence"
replace DistType = "Charter agency" if SchName == "Legacy Academy of Excellence"
replace NCESSchoolID = "391004010856" if SchName == "Legacy Academy of Excellence"
replace SchType = "Regular school" if SchName == "Legacy Academy of Excellence"
replace seasch = "020091" if SchName == "Legacy Academy of Excellence"
replace SchLevel = "Missing/not reported" if SchName == "Legacy Academy of Excellence"
replace SchVirtual = "Missing/not reported" if SchName == "Legacy Academy of Excellence"
replace CountyName = "Missing/not reported" if SchName == "ILegacy Academy of Excellence"

replace NCESDistrictID = "3910042" if SchName == "Lorain Preparatory High School"
replace State_leaid = "020186" if SchName == "Lorain Preparatory High School"
replace DistCharter = "Yes" if SchName == "Lorain Preparatory High School"
replace DistType = "Charter agency" if SchName == "Lorain Preparatory High School"
replace NCESSchoolID = "391004210824" if SchName == "Lorain Preparatory High School"
replace SchType = "Regular school" if SchName == "Lorain Preparatory High School"
replace seasch = "020186" if SchName == "Lorain Preparatory High School"
replace SchLevel = "High" if SchName == "Lorain Preparatory High School"
replace SchVirtual = "Missing/not reported" if SchName == "Lorain Preparatory High School"
replace CountyName = "Missing/not reported" if SchName == "Lorain Preparatory High School"

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

replace NCESSchoolID = "390450410841" if SchName == "Minerva France Elementary School"
replace SchType = "Regular school" if SchName == "Minerva France Elementary School"
replace seasch = "019875" if SchName == "Minerva France Elementary School"
replace SchLevel = "Primary" if SchName == "Minerva France Elementary School"
replace SchVirtual = "Missing/not reported" if SchName == "Minerva France Elementary School"

replace NCESSchoolID = "390444110844" if SchName == "MT. HEALTHY VIRTUAL ACADEMY"
replace SchType = "Regular school" if SchName == "MT. HEALTHY VIRTUAL ACADEMY"
replace seasch = "019945" if SchName == "MT. HEALTHY VIRTUAL ACADEMY"
replace SchLevel = "Other" if SchName == "MT. HEALTHY VIRTUAL ACADEMY"
replace SchVirtual = "Yes" if SchName == "MT. HEALTHY VIRTUAL ACADEMY"

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

replace DistName = "Northwest School of the Arts" if SchName == "Northwest School of the Arts"
replace NCESDistrictID = "3900313" if SchName == "Northwest School of the Arts"
replace State_leaid = "000575" if SchName == "Northwest School of the Arts"
replace DistCharter = "Yes" if SchName == "Northwest School of the Arts"
replace DistType = "Charter agency" if SchName == "Northwest School of the Arts"
replace NCESSchoolID = "390031304850" if SchName == "Northwest School of the Arts"
replace SchType = "Regular school" if SchName == "Northwest School of the Arts"
replace seasch = "000575" if SchName == "Northwest School of the Arts"
replace SchLevel = "Missing/not reported" if SchName == "Northwest School of the Arts"
replace SchVirtual = "Missing/not reported" if SchName == "Northwest School of the Arts"
replace CountyName = "Cuyahoga County" if SchName == "Northwest School of the Arts"
replace CountyCode = 39035 if SchName == "Northwest School of the Arts"

replace NCESSchoolID = "390446310832" if SchName == "Parma Virtual Learning Academy"
replace SchType = "Regular school" if SchName == "Parma Virtual Learning Academy"
replace seasch = "020317" if SchName == "Parma Virtual Learning Academy"
replace SchLevel = "Other" if SchName == "Parma Virtual Learning Academy"
replace SchVirtual = "Yes" if SchName == "Parma Virtual Learning Academy"

replace DistName = "Wings Academy 1" if SchName == "Phoenix Village Academy Primary 2 dba Wings Academy 1"
replace NCESDistrictID = "3900399" if SchName == "Phoenix Village Academy Primary 2 dba Wings Academy 1"
replace State_leaid = "000736" if SchName == "Phoenix Village Academy Primary 2 dba Wings Academy 1"
replace DistCharter = "Yes" if SchName == "Phoenix Village Academy Primary 2 dba Wings Academy 1"
replace DistType = "Charter agency" if SchName == "Phoenix Village Academy Primary 2 dba Wings Academy 1"
replace NCESSchoolID = "390039904959" if SchName == "Phoenix Village Academy Primary 2 dba Wings Academy 1"
replace SchType = "Regular school" if SchName == "Phoenix Village Academy Primary 2 dba Wings Academy 1"
replace seasch = "000736" if SchName == "Phoenix Village Academy Primary 2 dba Wings Academy 1"
replace SchLevel = "Primary" if SchName == "Phoenix Village Academy Primary 2 dba Wings Academy 1"
replace SchVirtual = "No" if SchName == "Phoenix Village Academy Primary 2 dba Wings Academy 1"
replace CountyName = "Cuyahoga County" if SchName == "Phoenix Village Academy Primary 2 dba Wings Academy 1"
replace CountyCode = 39035 if SchName == "Phoenix Village Academy Primary 2 dba Wings Academy 1"

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

replace NCESSchoolID = "390470005566" if SchName == "Reynoldsburg High School"
replace SchType = "Regular school" if SchName == "Reynoldsburg High School"
replace seasch = "012094" if SchName == "Reynoldsburg High School"
replace SchLevel = "High" if SchName == "Reynoldsburg High School"
replace SchVirtual = "Missing/not reported" if SchName == "Reynoldsburg High School"

replace NCESDistrictID = "3910041" if SchName == "Sheffield Academy"
replace State_leaid = "020092" if SchName == "Sheffield Academy"
replace DistCharter = "Yes" if SchName == "Sheffield Academy"
replace DistType = "Charter agency" if SchName == "Sheffield Academy"
replace NCESSchoolID = "391004110857" if SchName == "Sheffield Academy"
replace SchType = "Regular school" if SchName == "Sheffield Academy"
replace seasch = "020092" if SchName == "Sheffield Academy"
replace SchLevel = "Primary" if SchName == "Sheffield Academy"
replace SchVirtual = "Missing/not reported" if SchName == "Sheffield Academy"
replace CountyName = "Missing/not reported" if SchName == "Sheffield Academy"

replace NCESDistrictID = "3910037" if SchName == "Solon Academy"
replace State_leaid = "020076" if SchName == "Solon Academy"
replace DistCharter = "Yes" if SchName == "Solon Academy"
replace DistType = "Charter agency" if SchName == "Solon Academy"
replace NCESSchoolID = "391003710852" if SchName == "Solon Academy"
replace SchType = "Regular school" if SchName == "Solon Academy"
replace seasch = "020076" if SchName == "Solon Academy"
replace SchLevel = "Primary" if SchName == "Solon Academy"
replace SchVirtual = "Missing/not reported" if SchName == "Solon Academy"
replace CountyName = "Missing/not reported" if SchName == "Solon Academy"

replace NCESSchoolID = "390482210850" if SchName == "Springfield Digital Academy (SDA)"
replace SchType = "Regular school" if SchName == "Springfield Digital Academy (SDA)"
replace seasch = "020063" if SchName == "Springfield Digital Academy (SDA)"
replace SchLevel = "Other" if SchName == "Springfield Digital Academy (SDA)"
replace SchVirtual = "Yes" if SchName == "Springfield Digital Academy (SDA)"

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

replace NCESDistrictID = "3910043" if SchName == "Strongsville Academy"
replace State_leaid = "020189" if SchName == "Strongsville Academy"
replace DistCharter = "Yes" if SchName == "Strongsville Academy"
replace DistType = "Charter agency" if SchName == "Strongsville Academy"
replace NCESSchoolID = "391004310825" if SchName == "Strongsville Academy"
replace SchType = "Regular school" if SchName == "Strongsville Academy"
replace seasch = "020189" if SchName == "Strongsville Academy"
replace SchLevel = "Primary" if SchName == "Strongsville Academy"
replace SchVirtual = "Missing/not reported" if SchName == "Strongsville Academy"
replace SchVirtual = "Missing/not reported" if SchName == "Strongsville Academy"
replace CountyName = "Missing/not reported" if SchName == "Strongsville Academy"

replace NCESSchoolID = "390439010858" if SchName == "Superior School for the Performing Arts"
replace SchType = "Regular school" if SchName == "Superior School for the Performing Arts"
replace seasch = "020109" if SchName == "Superior School for the Performing Arts"
replace SchLevel = "Primary" if SchName == "Superior School for the Performing Arts"
replace SchVirtual = "Missing/not reported" if SchName == "Superior School for the Performing Arts"

replace NCESSchoolID = "390480410823" if SchName == "SWL Digital Academy"
replace SchType = "Regular school" if SchName == "SWL Digital Academy"
replace seasch = "020112" if SchName == "SWL Digital Academy"
replace SchLevel = "Other" if SchName == "SWL Digital Academy"
replace SchVirtual = "Missing/not reported" if SchName == "SWL Digital Academy"

replace NCESSchoolID = "390490910839" if SchName == "Teays Valley Digital Academy"
replace SchType = "Regular school" if SchName == "Teays Valley Digital Academy"
replace seasch = "019829" if SchName == "Teays Valley Digital Academy"
replace SchLevel = "Other" if SchName == "Teays Valley Digital Academy"
replace SchVirtual = "Missing/not reported" if SchName == "Teays Valley Digital Academy"

replace NCESDistrictID = "3910045" if SchName == "The Dayton School"
replace State_leaid = "020293" if SchName == "The Dayton School"
replace DistCharter = "Yes" if SchName == "The Dayton School"
replace DistType = "Charter agency" if SchName == "The Dayton School"
replace NCESSchoolID = "391004510831" if SchName == "The Dayton School"
replace SchType = "Regular school" if SchName == "The Dayton School"
replace seasch = "020293" if SchName == "The Dayton School"
replace SchLevel = "High" if SchName == "The Dayton School"
replace SchVirtual = "Missing/not reported" if SchName == "The Dayton School"
replace CountyName = "Missing/not reported" if SchName == "The Dayton School"

replace NCESSchoolID = "Missing/not reported" if SchName == "The International School"
replace SchType = "Missing/not reported" if SchName == "The International School"
replace seasch = "Missing/not reported" if SchName == "The International School"
replace SchLevel = "Missing/not reported" if SchName == "The International School"
replace SchVirtual = "Missing/not reported" if SchName == "The International School"

replace NCESSchoolID = "390445710846" if SchName == "The Norwood Montessori School"
replace SchType = "Regular school" if SchName == "The Norwood Montessori School"
replace seasch = "019994" if SchName == "The Norwood Montessori School"
replace SchLevel = "Primary" if SchName == "The Norwood Montessori School"
replace SchVirtual = "Missing/not reported" if SchName == "The Norwood Montessori School"

replace NCESDistrictID = "3910036" if SchName == "Unity Academy"
replace State_leaid = "020046" if SchName == "Unity Academy"
replace DistCharter = "Yes" if SchName == "Unity Academy"
replace DistType = "Charter agency" if SchName == "Unity Academy"
replace NCESSchoolID = "391003610848" if SchName == "Unity Academy"
replace SchType = "Regular school" if SchName == "Unity Academy"
replace seasch = "020046" if SchName == "Unity Academy"
replace SchLevel = "High" if SchName == "Unity Academy"
replace SchVirtual = "Missing/not reported" if SchName == "Unity Academy"
replace CountyName = "Missing/not reported" if SchName == "Unity Academy"

replace NCESDistrictID = "3910044" if SchName == "Victory Academy of Toledo"
replace State_leaid = "020265" if SchName == "Victory Academy of Toledo"
replace DistCharter = "Yes" if SchName == "Victory Academy of Toledo"
replace DistType = "Charter agency" if SchName == "Victory Academy of Toledo"
replace NCESSchoolID = "391004410829" if SchName == "Victory Academy of Toledo"
replace SchType = "Regular school" if SchName == "Victory Academy of Toledo"
replace seasch = "020265" if SchName == "Victory Academy of Toledo"
replace SchLevel = "Other" if SchName == "Victory Academy of Toledo"
replace SchVirtual = "Missing/not reported" if SchName == "Victory Academy of Toledo"
replace CountyName = "Missing/not reported" if SchName == "Victory Academy of Toledo"

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

replace NCESDistrictID = "3910038" if SchName == "Westlake Academy"
replace State_leaid = "020077" if SchName == "Westlake Academy"
replace DistCharter = "Yes" if SchName == "Westlake Academy"
replace DistType = "Charter agency" if SchName == "Westlake Academy"
replace NCESSchoolID = "391003810853" if SchName == "Westlake Academy"
replace SchType = "Regular school" if SchName == "Westlake Academy"
replace seasch = "020077" if SchName == "Westlake Academy"
replace SchLevel = "Primary" if SchName == "Westlake Academy"
replace SchVirtual = "Missing/not reported" if SchName == "Westlake Academy"
replace CountyName = "Missing/not reported" if SchName == "Westlake Academy"

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

drop state_name _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch lea_name

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType  Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/OH_AssmtData_2023.dta", replace

export delimited "${output}/OH_AssmtData_2023.csv", replace
