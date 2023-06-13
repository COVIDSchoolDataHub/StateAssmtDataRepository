clear
set more off

cd "/Users/minnamgung/Desktop/Ohio"

global raw "/Users/minnamgung/Desktop/Ohio/Original Data Files"
global output "/Users/minnamgung/Desktop/Ohio/Output"
global NCES "/Users/minnamgung/Desktop/Ohio/NCES"

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

merge m:1 StateAssignedDistID using "${NCES}/NCES_2021_District.dta"

save "${output}/OH_AssmtData_2021.dta", replace

* Extracting and cleaning 2019 State Data

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
replace ProficientOrAbove_percent="-" if ProficientOrAbove_percent==""
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="NC"

save "${dta}/OH_AssmtData_state_2021.dta", replace

* Append and clean 

use "${output}/OH_AssmtData_2021.dta", clear

append using "${dta}/OH_AssmtData_state_2021.dta"

gen SchYear="2020-21"
drop year

drop if _merge==2

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

drop _merge lea_name charter

replace ProficiencyCriteria="Level 3/4/5"
replace Subject="math" if Subject=="Math"
replace Subject="ela" if Subject=="ELA"
replace Subject="soc" if Subject=="SocialStudies"
replace Subject="sci" if Subject=="Science"

replace State="ohio"
replace StateAbbrev="OH"
replace StateFips=39

save "${output}/OH_AssmtData_2021.dta", replace

export delimited using "${csv}/OH_AssmtData_2021.csv", replace

