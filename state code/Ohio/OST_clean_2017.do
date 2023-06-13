clear
set more off

cd "/Users/minnamgung/Desktop/Ohio"

global raw "/Users/minnamgung/Desktop/Ohio/Original Data Files"
global output "/Users/minnamgung/Desktop/Ohio/Output"
global NCES "/Users/minnamgung/Desktop/Ohio/NCES"
global dta "/Users/minnamgung/Desktop/Ohio/dta"
global csv "/Users/minnamgung/Desktop/Ohio/Output/CSV"

import excel "${raw}/OH_OriginalData_2017_all.xls", sheet("Performance_Indicators") firstrow

drop Reading3rdGrade201516ato Math3rdGrade201516atora Reading4thGrade201516ato Math4thGrade201516atora SocialStudies4thGrade201516 Reading5thGrade201516ato Math5thGrade201516atora Science5thGrade201516ato Reading6thGrade201516ato Math6thGrade201516atora SocialStudies6thGrade201516 Reading7thGrade201516ato Math7thGrade201516atora Reading8thGrade201516ato Math8thGrade201516atora Science8thGrade201516ato HSEnglishI201516atorabo HSEnglishII201516atorab HSMathI201516atorabove HSMathII201516atorabove HSAlgebraI201516atorabo HSGeometry201516atorabov HSPhysicalScience201516at HSGovernment201516atorab HSHistory201516atorabove Reading3rdGrade201415ato Math3rdGrade201415atora Reading4thGrade201415ato Math4thGrade201415atora Reading5thGrade201415ato Math5thGrade201415atora Science5thGrade201415ato Reading6thGrade201415ato Math6thGrade201415atora Reading7thGrade201415ato Math7thGrade201415atora Reading8thGrade201415ato Math8thGrade201415atora Science8thGrade201415ato Watermark Region Address CityandZipCode Phone Superintendent NumberofStandardsMet NumberofStandardsPossible PercentofStandardsMet LetterGradeofStandardsMet GiftedIndicator

drop HSEnglishI201617atorabo BK BL HSEnglishII201617atorab BN BO HSMathI201617atorabove BQ BR HSMathII201617atorabove BT BU HSAlgebraI201617atorabo BW BX HSGeometry201617atorabov BZ CA HSBiology201617atorabove CC CD HSPhysicalScience201617at CF CG HSGovernment201617atorab CI CJ HSHistory201617atorabove CL CM

drop O R U X AA AD AG AJ AM AP AS AV AY BB BE BH

rename DistrictIRN StateAssignedDistID
rename DistrictName DistName

rename *201617ato *
rename *201617atora *
rename *201617 *

drop P S V Y AB AE AH AK AN AQ AT AW AZ BC BF BI

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

drop if StateAssignedDistID==""

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

merge m:1 StateAssignedDistID using "${NCES}/NCES_2017_District.dta"

save "${dta}/OH_AssmtData_2017.dta", replace

* Extracting and cleaning 2017 State Data

import excel "${raw}/OH_OriginalData_2017_all.xls", sheet("Performance_Indicators") firstrow clear

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

foreach v of varlist G3Proficientreading G3Proficientmath G4Proficientreading G4Proficientmath G4Proficientsoc G5Proficientreading G5Proficientmath G5Proficientsci G6Proficientreading G6Proficientmath G6Proficientsoc G7Proficientreading G7Proficientmath G8Proficientreading G8Proficientmath G8Proficientsci {
   tostring `v', replace
}


reshape long G3Proficient G4Proficient G5Proficient G6Proficient G7Proficient G8Proficient, i(DataLevel) j(Subject) string 

rename *Proficient Proficient*


reshape long Proficient, i(Subject) j(GradeLevel) string 

rename Proficient ProficientOrAbove_percent

tostring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent="-" if ProficientOrAbove_percent==""
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="NC"

save "${dta}/OH_AssmtData_state_2017.dta", replace

* Append and clean 

use "${dta}/OH_AssmtData_2017.dta", clear

append using "${dta}/OH_AssmtData_state_2017.dta"

gen SchYear="2016-17"
drop year

drop if _merge==2

gen State="Ohio"
gen Charter="" 
rename county_name CountyName  
gen NCESSchoolID="" 
gen SchoolType=""
gen Virtual="" 
gen seasch="" 
gen SchoolLevel="" 
gen AssmtName="Ohio's State Tests (OST)" 
gen Flag_AssmtNameChange="N" 
gen Flag_CutScoreChange_ELA="N"  
gen Flag_CutScoreChange_math="N"  
gen Flag_CutScoreChange_read="N"  
gen Flag_CutScoreChange_oth="N"  
gen AssmtType="Regular"  
gen SchName="" 
gen StateAssignedSchID="" 
gen StudentGroup="" 
gen StudentGroup_TotalTested="" 
gen StudentSubGroup="" 
gen Lev1_count="-" 
gen Lev1_percent="-" 
gen Lev2_count="-" 
gen Lev2_percent="-" 
gen Lev3_count="-" 
gen Lev3_percent="-" 
gen Lev4_count="-" 
gen Lev4_percent="-"  
gen Lev5_count="-"  
gen Lev5_percent="-" 
gen AvgScaleScore="-"  
gen ProficientOrAbove_count="-" 
gen ParticipationRate="-"

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

replace ProficiencyCriteria="Levels 3/4/5"

replace State="ohio"
replace StateAbbrev="OH"
replace StateFips=39

drop _merge lea_name

save "${output}/OH_AssmtData_2017.dta", replace

export delimited using "${csv}/OH_AssmtData_2017.csv", replace
