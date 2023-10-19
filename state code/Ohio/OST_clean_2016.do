clear all
set more off

cd "/Users/miramehta/Documents"

global raw "/Users/miramehta/Documents/OH State Testing Data"
global output "/Users/miramehta/Documents/OH State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"
global NCES_clean "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global dta "/Users/miramehta/Documents/OH State Testing Data/dta"
global csv "/Users/miramehta/Documents/OH State Testing Data/CSV"

import excel "${raw}/OH_OriginalData_District_2016.xls", sheet("Performance_Indicators") firstrow clear

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
replace Subject="ela" if Subject=="Reading"
replace Subject="soc" if Subject=="SocialStudies"
replace Subject="sci" if Subject=="Science"

rename Proficient ProficientOrAbove_percent

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

save "$dta/OH_AssmtData_2016", replace

* Gender Files
import excel "${raw}/OH_OriginalData_Gender_District_2016.xls", sheet("District_Gender") clear
drop C D J P V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP

rename A StateAssignedDistID
rename B DistName
rename E StudentSubGroup
rename F ProficientOrAbove_pct_G03_ela
rename G ProficientOrAbove_pct_G03_math
rename H ProficientOrAbove_pct_G04_ela
rename I ProficientOrAbove_pct_G04_math
rename K ProficientOrAbove_pct_G05_ela
rename L ProficientOrAbove_pct_G05_math
rename M ProficientOrAbove_pct_G05_sci
rename N ProficientOrAbove_pct_G06_ela
rename O ProficientOrAbove_pct_G06_math
rename Q ProficientOrAbove_pct_G07_ela
rename R ProficientOrAbove_pct_G07_math
rename S ProficientOrAbove_pct_G08_ela
rename T ProficientOrAbove_pct_G08_math
rename U ProficientOrAbove_pct_G08_sci

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

save "${dta}/OH_DistData_Gender_2016.dta", replace

* EL Status Files
import excel "${raw}/OH_OriginalData_EL Status_District_2016.xls", sheet("District_LEP") clear
drop C D J P V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP

rename A StateAssignedDistID
rename B DistName
rename E StudentSubGroup
rename F ProficientOrAbove_pct_G03_ela
rename G ProficientOrAbove_pct_G03_math
rename H ProficientOrAbove_pct_G04_ela
rename I ProficientOrAbove_pct_G04_math
rename K ProficientOrAbove_pct_G05_ela
rename L ProficientOrAbove_pct_G05_math
rename M ProficientOrAbove_pct_G05_sci
rename N ProficientOrAbove_pct_G06_ela
rename O ProficientOrAbove_pct_G06_math
rename Q ProficientOrAbove_pct_G07_ela
rename R ProficientOrAbove_pct_G07_math
rename S ProficientOrAbove_pct_G08_ela
rename T ProficientOrAbove_pct_G08_math
rename U ProficientOrAbove_pct_G08_sci

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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
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

save "${dta}/OH_DistData_EL Status_2016.dta", replace

* Economic Status Files
import excel "${raw}/OH_OriginalData_Econ_District_2016.xls", sheet("District_Econ_Disadvantage") clear
drop C D J P V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP

rename A StateAssignedDistID
rename B DistName
rename E StudentSubGroup
rename F ProficientOrAbove_pct_G03_ela
rename G ProficientOrAbove_pct_G03_math
rename H ProficientOrAbove_pct_G04_ela
rename I ProficientOrAbove_pct_G04_math
rename K ProficientOrAbove_pct_G05_ela
rename L ProficientOrAbove_pct_G05_math
rename M ProficientOrAbove_pct_G05_sci
rename N ProficientOrAbove_pct_G06_ela
rename O ProficientOrAbove_pct_G06_math
rename Q ProficientOrAbove_pct_G07_ela
rename R ProficientOrAbove_pct_G07_math
rename S ProficientOrAbove_pct_G08_ela
rename T ProficientOrAbove_pct_G08_math
rename U ProficientOrAbove_pct_G08_sci

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
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NonDisadvantaged"
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

save "${dta}/OH_DistData_Econ Status_2016.dta", replace

* RaceEth Files
import excel "${raw}/OH_OriginalData_RaceEth_District_2016.xls", sheet("District_Ethnicity") clear
drop C D J P V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP

rename A StateAssignedDistID
rename B DistName
rename E StudentSubGroup
rename F ProficientOrAbove_pct_G03_ela
rename G ProficientOrAbove_pct_G03_math
rename H ProficientOrAbove_pct_G04_ela
rename I ProficientOrAbove_pct_G04_math
rename K ProficientOrAbove_pct_G05_ela
rename L ProficientOrAbove_pct_G05_math
rename M ProficientOrAbove_pct_G05_sci
rename N ProficientOrAbove_pct_G06_ela
rename O ProficientOrAbove_pct_G06_math
rename Q ProficientOrAbove_pct_G07_ela
rename R ProficientOrAbove_pct_G07_math
rename S ProficientOrAbove_pct_G08_ela
rename T ProficientOrAbove_pct_G08_math
rename U ProficientOrAbove_pct_G08_sci

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
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian or Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiracial"
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

save "${dta}/OH_DistData_RaceEth_2016.dta", replace

//School Data - All Students
import excel "${raw}/OH_OriginalData_School_2016.xls", sheet("Performance Indicators") clear

drop E F G H I J K L M N O Q S U W X Y AA AC AE AG AI AJ AK AM AO AQ AS AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ CA CB CC CD CE CF CG CH CI CJ CK CL CM CN CO CP CQ CR CS CT CU CV CW CX CY CZ DA DB DC DD DE DF DG DH DI DJ DK DL DM DN DO DP DQ DR DS DT DU DV DW DX DY DZ EA EB EC ED EE EF EG

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename P ProficientOrAbove_pct_G03_ela
rename R ProficientOrAbove_pct_G03_math
rename T ProficientOrAbove_pct_G04_ela
rename V ProficientOrAbove_pct_G04_math
rename Z ProficientOrAbove_pct_G05_ela
rename AB ProficientOrAbove_pct_G05_math
rename AD ProficientOrAbove_pct_G05_sci
rename AF ProficientOrAbove_pct_G06_ela
rename AH ProficientOrAbove_pct_G06_math
rename AL ProficientOrAbove_pct_G07_ela
rename AN ProficientOrAbove_pct_G07_math
rename AP ProficientOrAbove_pct_G08_ela
rename AR ProficientOrAbove_pct_G08_math
rename AT ProficientOrAbove_pct_G08_sci

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

save "${dta}/OH_SchoolData_2016.dta", replace

* Gender Files
import excel "${raw}/OH_OriginalData_Gender_School_2016.xls", sheet("Building_Gender") clear
drop E F G H N T Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename I StudentSubGroup
rename J ProficientOrAbove_pct_G03_ela
rename K ProficientOrAbove_pct_G03_math
rename L ProficientOrAbove_pct_G04_ela
rename M ProficientOrAbove_pct_G04_math
rename O ProficientOrAbove_pct_G05_ela
rename P ProficientOrAbove_pct_G05_math
rename Q ProficientOrAbove_pct_G05_sci
rename R ProficientOrAbove_pct_G06_ela
rename S ProficientOrAbove_pct_G06_math
rename U ProficientOrAbove_pct_G07_ela
rename V ProficientOrAbove_pct_G07_math
rename W ProficientOrAbove_pct_G08_ela
rename X ProficientOrAbove_pct_G08_math
rename Y ProficientOrAbove_pct_G08_sci

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

save "${dta}/OH_SchoolData_Gender_2016.dta", replace

* EL Status Files
import excel "${raw}/OH_OriginalData_EL Status_School_2016.xls", sheet("Building_LEP") clear
drop E F G H N T Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename I StudentSubGroup
rename J ProficientOrAbove_pct_G03_ela
rename K ProficientOrAbove_pct_G03_math
rename L ProficientOrAbove_pct_G04_ela
rename M ProficientOrAbove_pct_G04_math
rename O ProficientOrAbove_pct_G05_ela
rename P ProficientOrAbove_pct_G05_math
rename Q ProficientOrAbove_pct_G05_sci
rename R ProficientOrAbove_pct_G06_ela
rename S ProficientOrAbove_pct_G06_math
rename U ProficientOrAbove_pct_G07_ela
rename V ProficientOrAbove_pct_G07_math
rename W ProficientOrAbove_pct_G08_ela
rename X ProficientOrAbove_pct_G08_math
rename Y ProficientOrAbove_pct_G08_sci

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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
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

save "${dta}/OH_SchoolData_EL Status_2016.dta", replace

* Economic Status Files
import excel "${raw}/OH_OriginalData_Econ_School_2016.xls", sheet("Building_Econ_Disadvantage") clear
drop E F G H N T Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename I StudentSubGroup
rename J ProficientOrAbove_pct_G03_ela
rename K ProficientOrAbove_pct_G03_math
rename L ProficientOrAbove_pct_G04_ela
rename M ProficientOrAbove_pct_G04_math
rename O ProficientOrAbove_pct_G05_ela
rename P ProficientOrAbove_pct_G05_math
rename Q ProficientOrAbove_pct_G05_sci
rename R ProficientOrAbove_pct_G06_ela
rename S ProficientOrAbove_pct_G06_math
rename U ProficientOrAbove_pct_G07_ela
rename V ProficientOrAbove_pct_G07_math
rename W ProficientOrAbove_pct_G08_ela
rename X ProficientOrAbove_pct_G08_math
rename Y ProficientOrAbove_pct_G08_sci

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
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NonDisadvantaged"
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

save "${dta}/OH_SchoolData_Econ Status_2016.dta", replace

* RaceEth Files
import excel "${raw}/OH_OriginalData_RaceEth_School_2016.xls", sheet("Building_Ethnicity") clear
drop E F G H N T Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName
rename I StudentSubGroup
rename J ProficientOrAbove_pct_G03_ela
rename K ProficientOrAbove_pct_G03_math
rename L ProficientOrAbove_pct_G04_ela
rename M ProficientOrAbove_pct_G04_math
rename O ProficientOrAbove_pct_G05_ela
rename P ProficientOrAbove_pct_G05_math
rename Q ProficientOrAbove_pct_G05_sci
rename R ProficientOrAbove_pct_G06_ela
rename S ProficientOrAbove_pct_G06_math
rename U ProficientOrAbove_pct_G07_ela
rename V ProficientOrAbove_pct_G07_math
rename W ProficientOrAbove_pct_G08_ela
rename X ProficientOrAbove_pct_G08_math
rename Y ProficientOrAbove_pct_G08_sci

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
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian or Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiracial"
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

save "${dta}/OH_SchoolData_RaceEth_2016.dta", replace

* Cleaning NCES Data
use "${NCES}/NCES District Files, Fall 1997-Fall 2021/NCES_2015_District.dta", clear
drop if state_location != "OH"
rename lea_name DistName
gen str StateAssignedDistID = state_leaid
save "$NCES_clean/NCES_2016_District_OH.dta", replace

use "${NCES}/NCES School Files, Fall 1997-Fall 2021/NCES_2015_School.dta", clear
drop if state_location != "OH"
gen str StateAssignedDistID = state_leaid
gen str StateAssignedSchID = seasch
save "$NCES_clean/NCES_2016_School_OH.dta", replace

* Merge Data
use "$dta/OH_AssmtData_2016.dta", clear
append using "${dta}/OH_DistData_Gender_2016.dta" "${dta}/OH_DistData_EL Status_2016.dta" "${dta}/OH_DistData_Econ Status_2016.dta" "${dta}/OH_DistData_RaceEth_2016.dta" "${dta}/OH_SchoolData_2016.dta" "${dta}/OH_SchoolData_Gender_2016.dta" "${dta}/OH_SchoolData_EL Status_2016.dta" "${dta}/OH_SchoolData_Econ Status_2016.dta" "${dta}/OH_SchoolData_RaceEth_2016.dta"

merge m:1 StateAssignedDistID using "$NCES_clean/NCES_2016_District_OH.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES_clean/NCES_2016_School_OH.dta", gen (merge2)
drop if merge2 == 2

save "$output/OH_AssmtData_2016.dta", replace

* Extracting and cleaning 2016 State Data

import excel "${raw}/OH_OriginalData_District_2016.xls", sheet("Performance_Indicators") firstrow clear

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

keep if _n==2
gen DataLevel="State" 

reshape long G3Proficient G4Proficient G5Proficient G6Proficient G7Proficient G8Proficient, i(DataLevel) j(Subject) string 

rename *Proficient Proficient*

reshape long Proficient, i(Subject) j(GradeLevel) string 

rename Proficient ProficientOrAbove_percent

replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force

save "${dta}/OH_AssmtData_state_2016.dta", replace

*Append and clean 

use "${output}/OH_AssmtData_2016.dta", clear

append using "${dta}/OH_AssmtData_state_2016.dta"

gen SchYear="2015-16"
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
replace DistName = "Academy of Educational Excellence" if SchName == "Academy of Educational Excellence"
replace NCESDistrictID = "3901502" if SchName == "Academy of Educational Excellence"
replace State_leaid = "013195" if SchName == "Academy of Educational Excellence"
replace DistCharter = "Yes" if SchName == "Academy of Educational Excellence"
replace DistType = "Charter agency" if SchName == "Academy of Educational Excellence"
replace NCESSchoolID = "390150205733" if SchName == "Academy of Educational Excellence"
replace SchType = "Regular school" if SchName == "Academy of Educational Excellence"
replace seasch = "013195" if SchName == "Academy of Educational Excellence"
replace SchLevel = "Primary" if SchName == "Academy of Educational Excellence"
replace SchVirtual = "No" if SchName == "Academy of Educational Excellence"
replace CountyName = "Lucas County" if SchName == "Academy of Educational Excellence"
replace CountyCode = 39095 if SchName == "Academy of Educational Excellence"

replace DistName = "Albert Einstein Academy For Letters Arts And Sciences-ohio" if SchName == "Albert Einstein Academy for Letters, Arts and Sciences-Ohio"
replace NCESDistrictID = "3901539" if SchName == "Albert Einstein Academy for Letters, Arts and Sciences-Ohio"
replace State_leaid = "013994" if SchName == "Albert Einstein Academy for Letters, Arts and Sciences-Ohio"
replace DistCharter = "Yes" if SchName == "Albert Einstein Academy for Letters, Arts and Sciences-Ohio"
replace DistType = "Charter agency" if SchName == "Albert Einstein Academy for Letters, Arts and Sciences-Ohio"
replace NCESSchoolID = "390153905804" if SchName == "Albert Einstein Academy for Letters, Arts and Sciences-Ohio"
replace SchType = "Regular school" if SchName == "Albert Einstein Academy for Letters, Arts and Sciences-Ohio"
replace seasch = "013994" if SchName == "Albert Einstein Academy for Letters, Arts and Sciences-Ohio"
replace SchLevel = "Other" if SchName == "Albert Einstein Academy for Letters, Arts and Sciences-Ohio"
replace SchVirtual = "No" if SchName == "Albert Einstein Academy for Letters, Arts and Sciences-Ohio"
replace CountyName = "Cuyahoga County" if SchName == "Albert Einstein Academy for Letters, Arts and Sciences-Ohio"
replace CountyCode = 39035 if SchName == "Albert Einstein Academy for Letters, Arts and Sciences-Ohio"

replace DistName = "Beacon Hill Academy" if SchName == "Beacon Hill Academy"
replace NCESDistrictID = "3901463" if SchName == "Beacon Hill Academy"
replace State_leaid = "012501" if SchName == "Beacon Hill Academy"
replace DistCharter = "Yes" if SchName == "Beacon Hill Academy"
replace DistType = "Charter agency" if SchName == "Beacon Hill Academy"
replace NCESSchoolID = "390146305666" if SchName == "Beacon Hill Academy"
replace SchType = "Regular school" if SchName == "Beacon Hill Academy"
replace seasch = "012501" if SchName == "Beacon Hill Academy"
replace SchLevel = "High" if SchName == "Beacon Hill Academy"
replace SchVirtual = "No" if SchName == "Beacon Hill Academy"
replace CountyName = "Wayne County" if SchName == "Beacon Hill Academy"
replace CountyCode = 39169 if SchName == "Beacon Hill Academy"

replace DistName = "Berwyn East Academy" if SchName == "Berwyn East Academy"
replace NCESDistrictID = "3901550" if SchName == "Berwyn East Academy"
replace State_leaid = "014090" if SchName == "Berwyn East Academy"
replace DistCharter = "Yes" if SchName == "Berwyn East Academy"
replace DistType = "Charter agency" if SchName == "Berwyn East Academy"
replace NCESSchoolID = "390155005772" if SchName == "Berwyn East Academy"
replace SchType = "Regular school" if SchName == "Berwyn East Academy"
replace seasch = "014090" if SchName == "Berwyn East Academy"
replace SchLevel = "Primary" if SchName == "Berwyn East Academy"
replace SchVirtual = "No" if SchName == "Berwyn East Academy"
replace CountyName = "Franklin County" if SchName == "Berwyn East Academy"
replace CountyCode = 39049 if SchName == "Berwyn East Academy"

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

replace DistName = "Citizens Academy East" if SchName == "Citizens Academy East"
replace NCESDistrictID = "3901486" if SchName == "Citizens Academy East"
replace State_leaid = "012852" if SchName == "Citizens Academy East"
replace DistCharter = "Yes" if SchName == "Citizens Academy East"
replace DistType = "Charter agency" if SchName == "Citizens Academy East"
replace NCESSchoolID = "390148605709" if SchName == "Citizens Academy East"
replace SchType = "Regular school" if SchName == "Citizens Academy East"
replace seasch = "012852" if SchName == "Citizens Academy East"
replace SchLevel = "Primary" if SchName == "Citizens Academy East"
replace SchVirtual = "No" if SchName == "Citizens Academy East"
replace CountyName = "Cuyahoga County" if SchName == "Citizens Academy East"
replace CountyCode = 39035 if SchName == "Citizens Academy East"

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

replace DistName = "Cleveland Entrepreneurship Preparatory School" if SchName == "Cleveland Entrepreneurship Preparatory School"
replace NCESDistrictID = "3900557" if SchName == "Cleveland Entrepreneurship Preparatory School"
replace State_leaid = "000930" if SchName == "Cleveland Entrepreneurship Preparatory School"
replace DistCharter = "Yes" if SchName == "Cleveland Entrepreneurship Preparatory School"
replace DistType = "Charter agency" if SchName == "Cleveland Entrepreneurship Preparatory School"
replace NCESSchoolID = "390055705049" if SchName == "Cleveland Entrepreneurship Preparatory School"
replace SchType = "Regular school" if SchName == "Cleveland Entrepreneurship Preparatory School"
replace seasch = "000930" if SchName == "Cleveland Entrepreneurship Preparatory School"
replace SchLevel = "Middle" if SchName == "Cleveland Entrepreneurship Preparatory School"
replace SchVirtual = "No" if SchName == "Cleveland Entrepreneurship Preparatory School"
replace CountyName = "Cuyahoga County" if SchName == "Cleveland Entrepreneurship Preparatory School"
replace CountyCode = 39035 if SchName == "Cleveland Entrepreneurship Preparatory School"

replace DistName = "Dayton Early College Academy, Inc" if SchName == "Dayton Early College Academy, Inc"
replace NCESDistrictID = "3901302" if SchName == "Dayton Early College Academy, Inc"
replace State_leaid = "009283" if SchName == "Dayton Early College Academy, Inc"
replace DistCharter = "Yes" if SchName == "Dayton Early College Academy, Inc"
replace DistType = "Charter agency" if SchName == "Dayton Early College Academy, Inc"
replace NCESSchoolID = "390130205399" if SchName == "Dayton Early College Academy, Inc"
replace SchType = "Regular school" if SchName == "Dayton Early College Academy, Inc"
replace seasch = "009283" if SchName == "Dayton Early College Academy, Inc"
replace SchLevel = "High" if SchName == "Dayton Early College Academy, Inc"
replace SchVirtual = "No" if SchName == "Dayton Early College Academy, Inc"
replace CountyName = "Montgomery County" if SchName == "Dayton Early College Academy, Inc"
replace CountyCode = 39113 if SchName == "Dayton Early College Academy, Inc"

replace DistName = "Deca Prep" if SchName == "DECA PREP"
replace NCESDistrictID = "3901508" if SchName == "DECA PREP"
replace State_leaid = "012924" if SchName == "DECA PREP"
replace DistCharter = "Yes" if SchName == "DECA PREP"
replace DistType = "Charter agency" if SchName == "DECA PREP"
replace NCESSchoolID = "390150805714" if SchName == "DECA PREP"
replace SchType = "Regular school" if SchName == "DECA PREP"
replace seasch = "012924" if SchName == "DECA PREP"
replace SchLevel = "Primary" if SchName == "DECA PREP"
replace SchVirtual = "No" if SchName == "DECA PREP"
replace CountyName = "Montgomery County" if SchName == "DECA PREP"
replace CountyCode = 39113 if SchName == "DECA PREP"

replace DistName = "Educational Academy for Boys & Girls" if SchName == "Educational Academy for Boys & Girls"
replace NCESDistrictID = "3900434" if SchName == "Educational Academy for Boys & Girls"
replace State_leaid = "000779" if SchName == "Educational Academy for Boys & Girls"
replace DistCharter = "Yes" if SchName == "Educational Academy for Boys & Girls"
replace DistType = "Charter agency" if SchName == "Educational Academy for Boys & Girls"
replace NCESSchoolID = "390043404993" if SchName == "Educational Academy for Boys & Girls"
replace SchType = "Regular school" if SchName == "Educational Academy for Boys & Girls"
replace seasch = "000779" if SchName == "Educational Academy for Boys & Girls"
replace SchLevel = "Primary" if SchName == "Educational Academy for Boys & Girls"
replace SchVirtual = "No" if SchName == "Educational Academy for Boys & Girls"
replace CountyName = "Franklin County" if SchName == "Educational Academy for Boys & Girls"
replace CountyCode = 39049 if SchName == "Educational Academy for Boys & Girls"

replace DistName = "Entrepreneurship Preparatory School - Woodland Hills Campus" if SchName == "Entrepreneurship Preparatory School - Woodland Hills Campus"
replace NCESDistrictID = "3901406" if SchName == "Entrepreneurship Preparatory School - Woodland Hills Campus"
replace State_leaid = "012031" if SchName == "Entrepreneurship Preparatory School - Woodland Hills Campus"
replace DistCharter = "Yes" if SchName == "Entrepreneurship Preparatory School - Woodland Hills Campus"
replace DistType = "Charter agency" if SchName == "Entrepreneurship Preparatory School - Woodland Hills Campus"
replace NCESSchoolID = "390140605613" if SchName == "Entrepreneurship Preparatory School - Woodland Hills Campus"
replace SchType = "Regular school" if SchName == "Entrepreneurship Preparatory School - Woodland Hills Campus"
replace seasch = "012031" if SchName == "Entrepreneurship Preparatory School - Woodland Hills Campus"
replace SchLevel = "Middle" if SchName == "Entrepreneurship Preparatory School - Woodland Hills Campus"
replace SchVirtual = "No" if SchName == "Entrepreneurship Preparatory School - Woodland Hills Campus"
replace CountyName = "Cuyahoga County" if SchName == "Entrepreneurship Preparatory School - Woodland Hills Campus"
replace CountyCode = 39035 if SchName == "Entrepreneurship Preparatory School - Woodland Hills Campus"

replace DistName = "Focus Learning Academy of Northern Columbus" if SchName == "Focus Learning Academy of Northern Columbus"
replace NCESDistrictID = "3900179" if SchName == "Focus Learning Academy of Northern Columbus"
replace State_leaid = "142943" if SchName == "Focus Learning Academy of Northern Columbus"
replace DistCharter = "Yes" if SchName == "Focus Learning Academy of Northern Columbus"
replace DistType = "Charter agency" if SchName == "Focus Learning Academy of Northern Columbus"
replace NCESSchoolID = "390017904703" if SchName == "Focus Learning Academy of Northern Columbus"
replace SchType = "Regular school" if SchName == "Focus Learning Academy of Northern Columbus"
replace seasch = "142943" if SchName == "Focus Learning Academy of Northern Columbus"
replace SchLevel = "Primary" if SchName == "Focus Learning Academy of Northern Columbus"
replace SchVirtual = "No" if SchName == "Focus Learning Academy of Northern Columbus"
replace CountyName = "Franklin County" if SchName == "Focus Learning Academy of Northern Columbus"
replace CountyCode = 39049 if SchName == "Focus Learning Academy of Northern Columbus"

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

replace DistName = "Greater Summit County Early Learning Center" if SchName == "Greater Summit County Early Learning Center"
replace NCESDistrictID = "3901369" if SchName == "Greater Summit County Early Learning Center"
replace State_leaid = "011381" if SchName == "Greater Summit County Early Learning Center"
replace DistCharter = "Yes" if SchName == "Greater Summit County Early Learning Center"
replace DistType = "Charter agency" if SchName == "Greater Summit County Early Learning Center"
replace NCESSchoolID = "390136905522" if SchName == "Greater Summit County Early Learning Center"
replace SchType = "Regular school" if SchName == "Greater Summit County Early Learning Center"
replace seasch = "011381" if SchName == "Greater Summit County Early Learning Center"
replace SchLevel = "Primary" if SchName == "Greater Summit County Early Learning Center"
replace SchVirtual = "No" if SchName == "Greater Summit County Early Learning Center"
replace CountyName = "Summit County" if SchName == "Greater Summit County Early Learning Center"
replace CountyCode = 39153 if SchName == "Greater Summit County Early Learning Center"

replace DistName = "Hope Learning Academy of Toledo" if SchName == "Hope Learning Academy of Toledo"
replace NCESDistrictID = "3901520" if SchName == "Hope Learning Academy of Toledo"
replace State_leaid = "014091" if SchName == "Hope Learning Academy of Toledo"
replace DistCharter = "Yes" if SchName == "Hope Learning Academy of Toledo"
replace DistType = "Charter agency" if SchName == "Hope Learning Academy of Toledo"
replace NCESSchoolID = "390152005819" if SchName == "Hope Learning Academy of Toledo"
replace SchType = "Regular school" if SchName == "Hope Learning Academy of Toledo"
replace seasch = "014091" if SchName == "Hope Learning Academy of Toledo"
replace SchLevel = "Primary" if SchName == "Hope Learning Academy of Toledo"
replace SchVirtual = "No" if SchName == "Hope Learning Academy of Toledo"
replace CountyName = "Lucas County" if SchName == "Hope Learning Academy of Toledo"
replace CountyCode = 39095 if SchName == "Hope Learning Academy of Toledo"

replace DistName = "Imagine Columbus Primary School" if SchName == "Imagine Columbus Primary School"
replace NCESDistrictID = "3901521" if SchName == "Imagine Columbus Primary School"
replace State_leaid = "014139" if SchName == "Imagine Columbus Primary School"
replace DistCharter = "Yes" if SchName == "Imagine Columbus Primary School"
replace DistType = "Charter agency" if SchName == "Imagine Columbus Primary School"
replace NCESSchoolID = "390152105801" if SchName == "Imagine Columbus Primary School"
replace SchType = "Regular school" if SchName == "Imagine Columbus Primary School"
replace seasch = "014139" if SchName == "Imagine Columbus Primary School"
replace SchLevel = "Primary" if SchName == "Imagine Columbus Primary School"
replace SchVirtual = "No" if SchName == "Imagine Columbus Primary School"
replace CountyName = "Franklin County" if SchName == "Imagine Columbus Primary School"
replace CountyCode = 39049 if SchName == "Imagine Columbus Primary School"

replace DistName = "Imagine Leadership Academy" if SchName == "Imagine Leadership Academy"
replace NCESDistrictID = "3901549" if SchName == "Imagine Leadership Academy"
replace State_leaid = "014121" if SchName == "Imagine Leadership Academy"
replace DistCharter = "Yes" if SchName == "Imagine Leadership Academy"
replace DistType = "Charter agency" if SchName == "Imagine Leadership Academy"
replace NCESSchoolID = "390154905797" if SchName == "Imagine Leadership Academy"
replace SchType = "Regular school" if SchName == "Imagine Leadership Academy"
replace seasch = "014121" if SchName == "Imagine Leadership Academy"
replace SchLevel = "Primary" if SchName == "Imagine Leadership Academy"
replace SchVirtual = "No" if SchName == "Imagine Leadership Academy"
replace CountyName = "Summit County" if SchName == "Imagine Leadership Academy"
replace CountyCode = 39153 if SchName == "Imagine Leadership Academy"

replace DistName = "Imagine Woodbury Academy" if SchName == "Imagine Woodbury Academy"
replace NCESDistrictID = "3901466" if SchName == "Imagine Woodbury Academy"
replace State_leaid = "012545" if SchName == "Imagine Woodbury Academy"
replace DistCharter = "Yes" if SchName == "Imagine Woodbury Academy"
replace DistType = "Charter agency" if SchName == "Imagine Woodbury Academy"
replace NCESSchoolID = "390146605660" if SchName == "Imagine Woodbury Academy"
replace SchType = "Regular school" if SchName == "Imagine Woodbury Academy"
replace seasch = "012545" if SchName == "Imagine Woodbury Academy"
replace SchLevel = "Primary" if SchName == "Imagine Woodbury Academy"
replace SchVirtual = "No" if SchName == "Imagine Woodbury Academy"
replace CountyName = "Montgomery County" if SchName == "Imagine Woodbury Academy"
replace CountyCode = 39113 if SchName == "Imagine Woodbury Academy"

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

replace DistName = "Lakeland Academy Community School" if SchName == "Lakeland Academy Community School"
replace NCESDistrictID = "3901363" if SchName == "Lakeland Academy Community School"
replace State_leaid = "011511" if SchName == "Lakeland Academy Community School"
replace DistCharter = "Yes" if SchName == "Lakeland Academy Community School"
replace DistType = "Charter agency" if SchName == "Lakeland Academy Community School"
replace NCESSchoolID = "390136305525" if SchName == "Lakeland Academy Community School"
replace SchType = "Regular school" if SchName == "Lakeland Academy Community School"
replace seasch = "011511" if SchName == "Lakeland Academy Community School"
replace SchLevel = "Other" if SchName == "Lakeland Academy Community School"
replace SchVirtual = "No" if SchName == "Lakeland Academy Community School"
replace CountyName = "Harrison County" if SchName == "Lakeland Academy Community School"
replace CountyCode = 39067 if SchName == "Lakeland Academy Community School"

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

replace NCESSchoolID = "Missing/not reported" if SchName == "Lakewood Digital Academy"
replace SchType = "Missing/not reported" if SchName == "Lakewood Digital Academy"
replace seasch = "Missing/not reported" if SchName == "Lakewood Digital Academy"
replace SchLevel = "Missing/not reported" if SchName == "Lakewood Digital Academy"
replace SchVirtual = "Missing/not reported" if SchName == "Lakewood Digital Academy"

replace DistName = "Lawrence County Academy" if SchName == "Lawrence County Academy"
replace NCESDistrictID = "3901564" if SchName == "Lawrence County Academy"
replace State_leaid = "014094" if SchName == "Lawrence County Academy"
replace DistCharter = "Yes" if SchName == "Lawrence County Academy"
replace DistType = "Charter agency" if SchName == "Lawrence County Academy"
replace NCESSchoolID = "390153105777" if SchName == "Lawrence County Academy"
replace SchType = "Regular school" if SchName == "Lawrence County Academy"
replace seasch = "014094" if SchName == "Lawrence County Academy"
replace SchLevel = "High" if SchName == "Lawrence County Academy"
replace SchVirtual = "No" if SchName == "Lawrence County Academy"
replace CountyName = "Lawrence County" if SchName == "Lawrence County Academy"
replace CountyCode = 39087 if SchName == "Lawrence County Academy"

replace NCESSchoolID = "Missing/not reported" if SchName == "Lorain K-12 Digital Academy"
replace SchType = "Missing/not reported" if SchName == "Lorain K-12 Digital Academy"
replace seasch = "Missing/not reported" if SchName == "Lorain K-12 Digital Academy"
replace SchLevel = "Missing/not reported" if SchName == "Lorain K-12 Digital Academy"
replace SchVirtual = "Missing/not reported" if SchName == "Lorain K-12 Digital Academy"

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

replace DistName = "Midnimo Cross Cultural Community School" if SchName == "Midnimo Cross Cultural Community School"
replace NCESDistrictID = "3900435" if SchName == "Midnimo Cross Cultural Community School"
replace State_leaid = "000780" if SchName == "Midnimo Cross Cultural Community School"
replace DistCharter = "Yes" if SchName == "Midnimo Cross Cultural Community School"
replace DistType = "Charter agency" if SchName == "Midnimo Cross Cultural Community School"
replace NCESSchoolID = "390043504994" if SchName == "Midnimo Cross Cultural Community School"
replace SchType = "Regular school" if SchName == "Midnimo Cross Cultural Community School"
replace seasch = "000780" if SchName == "Midnimo Cross Cultural Community School"
replace SchLevel = "Middle" if SchName == "Midnimo Cross Cultural Community School"
replace SchVirtual = "No" if SchName == "Midnimo Cross Cultural Community School"
replace CountyName = "Franklin County" if SchName == "Midnimo Cross Cultural Community School"
replace CountyCode = 39049 if SchName == "Midnimo Cross Cultural Community School"

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

replace DistName = "North Central Academy" if SchName == "North Central Academy"
replace NCESDistrictID = "3901420" if SchName == "North Central Academy"
replace State_leaid = "012054" if SchName == "North Central Academy"
replace DistCharter = "Yes" if SchName == "North Central Academy"
replace DistType = "Charter agency" if SchName == "North Central Academy"
replace NCESSchoolID = "390142005577" if SchName == "North Central Academy"
replace SchType = "Regular school" if SchName == "North Central Academy"
replace seasch = "012054" if SchName == "North Central Academy"
replace SchLevel = "High" if SchName == "North Central Academy"
replace SchVirtual = "No" if SchName == "North Central Academy"
replace CountyName = "Seneca County" if SchName == "North Central Academy"
replace CountyCode = 39147 if SchName == "North Central Academy"

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

replace NCESSchoolID = "Missing/not reported" if SchName == "Norwood Conversion Community School"
replace SchType = "Missing/not reported" if SchName == "Norwood Conversion Community School"
replace seasch = "Missing/not reported" if SchName == "Norwood Conversion Community School"
replace SchLevel = "Missing/not reported" if SchName == "Norwood Conversion Community School"
replace SchVirtual = "Missing/not reported" if SchName == "Norwood Conversion Community School"

replace NCESSchoolID = "Missing/not reported" if SchName == "Ohio Valley Energy Technology Academy"
replace SchType = "Missing/not reported" if SchName == "Ohio Valley Energy Technology Academy"
replace seasch = "Missing/not reported" if SchName == "Ohio Valley Energy Technology Academy"
replace SchLevel = "Missing/not reported" if SchName == "Ohio Valley Energy Technology Academy"
replace SchVirtual = "Missing/not reported" if SchName == "Ohio Valley Energy Technology Academy"

replace DistName = "Par Excellence Academy" if SchName == "Par Excellence Academy"
replace NCESDistrictID = "3900567" if SchName == "Par Excellence Academy"
replace State_leaid = "000941" if SchName == "Par Excellence Academy"
replace DistCharter = "Yes" if SchName == "Par Excellence Academy"
replace DistType = "Charter agency" if SchName == "Par Excellence Academy"
replace NCESSchoolID = "390056705059" if SchName == "Par Excellence Academy"
replace SchType = "Regular school" if SchName == "Par Excellence Academy"
replace seasch = "000941" if SchName == "Par Excellence Academy"
replace SchLevel = "Primary" if SchName == "Par Excellence Academy"
replace SchVirtual = "No" if SchName == "Par Excellence Academy"
replace CountyName = "Licking County" if SchName == "Par Excellence Academy"
replace CountyCode = 39089 if SchName == "Par Excellence Academy"

replace NCESSchoolID = "Missing/not reported" if SchName == "Pleasant Community Digital"
replace SchType = "Missing/not reported" if SchName == "Pleasant Community Digital"
replace seasch = "Missing/not reported" if SchName == "Pleasant Community Digital"
replace SchLevel = "Missing/not reported" if SchName == "Pleasant Community Digital"
replace SchVirtual = "Missing/not reported" if SchName == "Pleasant Community Digital"

replace DistName = "Richland Academy School of Excellence" if SchName == "Richland Academy School of Excellence"
replace NCESDistrictID = "3901381" if SchName == "Richland Academy School of Excellence"
replace State_leaid = "011967" if SchName == "Richland Academy School of Excellence"
replace DistCharter = "Yes" if SchName == "Richland Academy School of Excellence"
replace DistType = "Charter agency" if SchName == "Richland Academy School of Excellence"
replace NCESSchoolID = "390138105634" if SchName == "Richland Academy School of Excellence"
replace SchType = "Regular school" if SchName == "Richland Academy School of Excellence"
replace seasch = "011967" if SchName == "Richland Academy School of Excellence"
replace SchLevel = "Primary" if SchName == "Richland Academy School of Excellence"
replace SchVirtual = "No" if SchName == "Richland Academy School of Excellence"
replace CountyName = "Richland County" if SchName == "Richland Academy School of Excellence"
replace CountyCode = 39139 if SchName == "Richland Academy School of Excellence"

replace NCESSchoolID = "Missing/not reported" if SchName == "Ridgedale Community School"
replace SchType = "Missing/not reported" if SchName == "Ridgedale Community School"
replace seasch = "Missing/not reported" if SchName == "Ridgedale Community School"
replace SchLevel = "Missing/not reported" if SchName == "Ridgedale Community School"
replace SchVirtual = "Missing/not reported" if SchName == "Ridgedale Community School"

replace DistName = "Rise & Shine Academy" if SchName == "Rise & Shine Academy"
replace NCESDistrictID = "3901555" if SchName == "Rise & Shine Academy"
replace State_leaid = "013999" if SchName == "Rise & Shine Academy"
replace DistCharter = "Yes" if SchName == "Rise & Shine Academy"
replace DistType = "Charter agency" if SchName == "Rise & Shine Academy"
replace NCESSchoolID = "390155505806" if SchName == "Rise & Shine Academy"
replace SchType = "Regular school" if SchName == "Rise & Shine Academy"
replace seasch = "013999" if SchName == "Rise & Shine Academy"
replace SchLevel = "Primary" if SchName == "Rise & Shine Academy"
replace SchVirtual = "No" if SchName == "Rise & Shine Academy"
replace CountyName = "Lucas County" if SchName == "Rise & Shine Academy"
replace CountyCode = 39095 if SchName == "Rise & Shine Academy"

replace NCESSchoolID = "390480410823" if SchName == "Southwest Licking Digital Acad"
replace SchType = "Regular school" if SchName == "Southwest Licking Digital Acad"
replace seasch = "020112" if SchName == "Southwest Licking Digital Acad"
replace SchLevel = "Other" if SchName == "Southwest Licking Digital Acad"
replace SchVirtual = "Missing/not reported" if SchName == "Southwest Licking Digital Acad"

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

replace DistName = "Stonebrook Montessori" if SchName == "Stonebrook Montessori"
replace NCESDistrictID = "3901571" if SchName == "Stonebrook Montessori"
replace State_leaid = "015239" if SchName == "Stonebrook Montessori"
replace DistCharter = "Yes" if SchName == "Stonebrook Montessori"
replace DistType = "Charter agency" if SchName == "Stonebrook Montessori"
replace NCESSchoolID = "390157105849" if SchName == "Stonebrook Montessori"
replace SchType = "Regular school" if SchName == "Stonebrook Montessori"
replace seasch = "015239" if SchName == "Stonebrook Montessori"
replace SchLevel = "Primary" if SchName == "Stonebrook Montessori"
replace SchVirtual = "No" if SchName == "Stonebrook Montessori"
replace CountyName = "Cuyahoga County" if SchName == "Stonebrook Montessori"
replace CountyCode = 39035 if SchName == "Stonebrook Montessori"

replace DistName = "Utica Shale Academy of Ohio" if SchName == "Utica Shale Academy of Ohio"
replace NCESDistrictID = "3901566" if SchName == "Utica Shale Academy of Ohio"
replace State_leaid = "014830" if SchName == "Utica Shale Academy of Ohio"
replace DistCharter = "Yes" if SchName == "Utica Shale Academy of Ohio"
replace DistType = "Charter agency" if SchName == "Utica Shale Academy of Ohio"
replace NCESSchoolID = "390156605837" if SchName == "Utica Shale Academy of Ohio"
replace SchType = "Regular school" if SchName == "Utica Shale Academy of Ohio"
replace seasch = "014830" if SchName == "Utica Shale Academy of Ohio"
replace SchLevel = "High" if SchName == "Utica Shale Academy of Ohio"
replace SchVirtual = "No" if SchName == "Utica Shale Academy of Ohio"
replace CountyName = "Columbiana County" if SchName == "Utica Shale Academy of Ohio"
replace CountyCode = 39029 if SchName == "Utica Shale Academy of Ohio"

replace NCESSchoolID = "Missing/not reported" if SchName == "Utica Shale Academy-Belmont"
replace SchType = "Missing/not reported" if SchName == "Utica Shale Academy-Belmont"
replace seasch = "Missing/not reported" if SchName == "Utica Shale Academy-Belmont"
replace SchLevel = "Missing/not reported" if SchName == "Utica Shale Academy-Belmont"
replace SchVirtual = "Missing/not reported" if SchName == "Utica Shale Academy-Belmont"

replace DistName = "Village Preparatory School" if SchName == "Village Preparatory School"
replace NCESDistrictID = "3901368" if SchName == "Village Preparatory School"
replace State_leaid = "011291" if SchName == "Village Preparatory School"
replace DistCharter = "Yes" if SchName == "Village Preparatory School"
replace DistType = "Charter agency" if SchName == "Village Preparatory School"
replace NCESSchoolID = "390136805528" if SchName == "Village Preparatory School"
replace SchType = "Regular school" if SchName == "Village Preparatory School"
replace seasch = "011291" if SchName == "Village Preparatory School"
replace SchLevel = "Primary" if SchName == "Village Preparatory School"
replace SchVirtual = "No" if SchName == "Village Preparatory School"
replace CountyName = "Cuyahoga County" if SchName == "Village Preparatory School"
replace CountyCode = 39035 if SchName == "Village Preparatory School"

replace DistName = "Village Preparatory School:: Woodland Hills Campus" if SchName == "Village Preparatory School:: Woodland Hills Campus"
replace NCESDistrictID = "3901505" if SchName == "Village Preparatory School:: Woodland Hills Campus"
replace State_leaid = "013034" if SchName == "Village Preparatory School:: Woodland Hills Campus"
replace DistCharter = "Yes" if SchName == "Village Preparatory School:: Woodland Hills Campus"
replace DistType = "Charter agency" if SchName == "Village Preparatory School:: Woodland Hills Campus"
replace NCESSchoolID = "390150505720" if SchName == "Village Preparatory School:: Woodland Hills Campus"
replace SchType = "Regular school" if SchName == "Village Preparatory School:: Woodland Hills Campus"
replace seasch = "013034" if SchName == "Village Preparatory School:: Woodland Hills Campus"
replace SchLevel = "Primary" if SchName == "Village Preparatory School:: Woodland Hills Campus"
replace SchVirtual = "No" if SchName == "Village Preparatory School:: Woodland Hills Campus"
replace CountyName = "Cuyahoga County" if SchName == "Village Preparatory School:: Woodland Hills Campus"
replace CountyCode = 39035 if SchName == "Village Preparatory School:: Woodland Hills Campus"

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

drop state_name _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch lea_name agency_charter_indicator dist_agency_charter_indicator

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType  Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/OH_AssmtData_2016.dta", replace

export delimited "${output}/OH_AssmtData_2016.csv", replace
