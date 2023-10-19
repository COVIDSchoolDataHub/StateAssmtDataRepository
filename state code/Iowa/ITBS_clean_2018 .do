clear
set more off

global raw "/Users/minnamgung/Desktop/Iowa/Input"
global output "/Users/minnamgung/Desktop/Iowa/Output"
global int "/Users/minnamgung/Desktop/Iowa/Intermediate"

global nces "/Users/minnamgung/Desktop/NCES"
global iowa "/Users/minnamgung/Desktop/Iowa/NCES"

/////////////////////////////////////////
*** NCES Cleaning for IA ***
/////////////////////////////////////////


/////////////////////////////////////////
*** Iowa District Cleaning ***
/////////////////////////////////////////

* ELA
import excel "${raw}/Iowa - District/IA_OriginalData_2018_all.xls", sheet("Reading") cellrange(A6:AW341) firstrow clear

gen Subject="read"

drop AS AT AU AV AW

save "${int}/IA_AssmtData_district_ela_2018.dta", replace

* Math 

import excel "${raw}/Iowa - District/IA_OriginalData_2018_all.xls", sheet("Math") cellrange(A6:AU338) firstrow clear

gen Subject="math"

save "${int}/IA_AssmtData_district_math_2018.dta", replace

append using "${int}/IA_AssmtData_district_ela_2018.dta"

drop J O T Y AD AI AN AS AT AU AJ AK AL AM AO AP AQ AR

foreach i of varlist NotProficient Proficient TotalTested I {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "3"
	label var `i' "`a'"
}

foreach i of varlist K L M N {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "4"
	label var `i' "`a'"
}

foreach i of varlist P Q R S {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "5"
	label var `i' "`a'"
}

foreach i of varlist U V W X {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "6"
	label var `i' "`a'"
}

foreach i of varlist Z AA AB AC {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "7"
	label var `i' "`a'"
}

foreach i of varlist AE AF AG AH {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "8"
	label var `i' "`a'"
}


foreach i of varlist NotProficient Proficient TotalTested I K L M N P Q R S U V W X Z AA AB AC AE AF AG AH {
	local x : variable label `i'
	rename `i' `x'
}

save "${int}/IA_AssmtData_district_2018.dta", replace

rename DistrictName DistName
rename District StateAssignedDistID

rename *NotProficient NotProficient*
rename *PercentProficient PercentProficient*
rename *Proficient Proficient*
rename *TotalTested TotalTested*

drop if DistName==""
drop County CountyName

reshape long NotProficient Proficient TotalTested PercentProficient, i(StateAssignedDistID DistName Subject) j(Grade)

gen State_leaid=StateAssignedDistID
merge m:1 State_leaid using "${iowa}/NCES_2017_district.dta"


foreach i of varlist NCESDistrictID State_leaid DistType CountyName CountyCode {
	tostring `i', replace force
	replace `i'="Missing/not reported" if _merge==1 & DistName!="State" & DistName!="Accountable to State"
}

drop if _merge==2
drop _merge AEA

gen DataLevel="District"
replace DataLevel="State" if DistName=="State"
replace DistName="All Districts" if DataLevel=="State"

save "${int}/IA_AssmtData_district_2018.dta", replace


/////////////////////////////////////////
*** General cleaning for IOWA ***
/////////////////////////////////////////

drop if Grade>8
rename Grade GradeLevel
tostring GradeLevel, replace
replace GradeLevel="G0"+GradeLevel

drop State
gen State="IOWA"
replace StateAbbrev="IA"
replace StateFips=19
gen SchYear="2017-18"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLeve

gen SchName=""

replace DistName="All Districts" if DataLevel==1
replace SchName="All Districts" if DataLevel==1

gen AssmtName="ITBS"
gen AssmtType="Regular and alt"
gen StudentGroup="All Students"

rename TotalTested StudentGroup_TotalTested 
rename PercentProficient ProficientOrAbove_percent
rename Proficient ProficientOrAbove_count

replace StudentGroup_TotalTested="0" if StudentGroup_TotalTested==""

gen ProficiencyCriteria="Levels 2 and 3"
gen AvgScaleScore=""
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested 
gen ParticipationRate=""

foreach x of numlist 1/5 {
    generate Lev`x'_count = ""
	generate Lev`x'_percent = ""
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

** Replace missing values
foreach v of varlist StudentSubGroup_TotalTested AvgScaleScore Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ParticipationRate {
	tostring `v', replace
	replace `v' = "-" if `v' == "" | `v' == "."
}
	
foreach u of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	destring `u', replace force
	replace `u' = `u' / 100
	tostring `u', replace force
	replace `u' = "*" if `u' == "."
}

gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA=""
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth=""

gen SchType=""
gen NCESSchoolID=""
gen StateAssignedSchID=""
gen seasch="" 
gen SchLevel="" 
gen SchVirtual=""
gen DistCharter=""

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

//sort
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
replace SchVirtual = "Missing/not reported" if SchVirtual == "" & DataLevel == 3
replace SchLevel = "Missing/not reported" if SchLevel == "" & DataLevel == 3

save "${output}/IA_AssmtData_all_2018.dta"
