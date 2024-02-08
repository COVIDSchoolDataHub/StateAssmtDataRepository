clear
set more off

global raw "/Users/minnamgung/Desktop/SADR/Iowa/Input"
global output "/Users/minnamgung/Desktop/SADR/Iowa/Output"
global int "/Users/minnamgung/Desktop/SADR/Iowa/Intermediate"

global nces "/Users/minnamgung/Desktop/SADR/NCES District and School Demographics-2"
global iowa "/Users/minnamgung/Desktop/SADR/Iowa/NCES"


// 2023 Unmerged Schools
import excel "${raw}/Iowa unmerged .xlsx", sheet("Sheet1") firstrow clear

foreach i of varlist NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID {
	
	tostring `i', replace
}

format NCESSchoolID %12.0f
tostring NCESSchoolID, replace usedisplayformat

replace SchName="All Schools" if DataLevel=="District"

replace DistType="7" if DistType=="Independent charter district"
replace DistType="1" if DistType=="Regular local school district"
destring DistType, replace

replace CountyCode="." if CountyCode=="Missing/not reported"
destring CountyCode, replace

save "${raw}/IA_Unmerged.dta", replace


////////////////////////////////////////
*** NCES Cleaning for IA ***
/////////////////////////////////////////

* District 
use "${nces}/NCES District Files, Fall 1997-Fall 2021/NCES_2021_District.dta", clear 

keep state_location state_name state_fips ncesdistrictid state_leaid district_agency_type DistCharter county_name county_code lea_name 
keep if state_fips==19
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename lea_name DistName
	rename county_code CountyCode
	rename county_name CountyName
	
split State_leaid, p(" ")
drop State_leaid State_leaid2
rename State_leaid1 State_leaid
replace State_leaid=substr(State_leaid,-4,.)
	
save "${iowa}/NCES_2021_district.dta", replace

* School
use "${nces}/NCES School Files, Fall 1997-Fall 2021/NCES_2021_School.dta", clear

keep ncesschoolid school_name ncesdistrictid lea_name state_leaid state_location state_name state_fips county_name county_code school_type school_id seasch SchLevel SchVirtual district_agency_type DistCharter

keep if state_fips==19
	rename state_name State
	rename lea_name DistName
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename district_agency_type DistType
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename county_name CountyName
	rename ncesschoolid NCESSchoolID
	rename school_type SchType
	rename school_name SchName

/*
replace st_schid=substr(st_schid,-3,.)
gen StateAssignedSchID="0"+st_schid
*/

split State_leaid, p(" ")
		drop State_leaid State_leaid2
		rename State_leaid1 State_leaid
		replace State_leaid=substr(State_leaid,-4,.)
		split seasch, p(" ")
		drop seasch1
gen StateAssignedSchID="0"+seasch2

drop if SchName=="Cedar Rapids Virtual Academy" & NCESSchoolID=="190654002272"
	
save "${iowa}/NCES_2021_school.dta", replace


/////////////////////////////////////////
*** Iowa District Cleaning ***
/////////////////////////////////////////

* ELA and Math
import excel "${raw}/Iowa - District/IA_OriginalData_2023_all.xlsx", sheet("ELA") cellrange(A7:AW338) firstrow clear

gen Subject="ela"

save "${int}/IA_AssmtData_district_ela_2023.dta", replace

import excel "${raw}/Iowa - District/IA_OriginalData_2023_all.xlsx", sheet("Math") cellrange(A7:AW338) firstrow clear

gen Subject="math"

save "${int}/IA_AssmtData_district_math_2023.dta", replace

append using "${int}/IA_AssmtData_district_ela_2023.dta"

drop J O T Y AD AI AN AS

foreach i of varlist I N S X AC AH AM AR AW {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	label var `i' "`a'"
}

foreach i of varlist I N S X AC AH AM AR AW {
	local x : variable label `i'
	rename `i' `x'
}

save "${int}/IA_AssmtData_district_2023.dta", replace

* Science
import excel "${raw}/Iowa - District/IA_OriginalData_2023_all.xlsx", sheet("Science") cellrange(A7:W338) firstrow clear

gen Subject="sci"

drop J O T U V W

foreach i of varlist I N S {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	label var `i' "`a'"
}

foreach i of varlist I N S {
	local x : variable label `i'
	rename `i' `x'
}

save "${int}/IA_AssmtData_district_sci_2023.dta", replace

* Entire dataset cleaning 
use "${int}/IA_AssmtData_district_2023.dta", clear

append using "${int}/IA_AssmtData_district_sci_2023.dta"

rename DistrictName DistName
rename District StateAssignedDistID

rename *NotProficient NotProficient*
rename *PercentProficient PercentProficient*
rename *Proficient Proficient*
rename *TotalTested TotalTested*

rename *Grade* **

reshape long NotProficient Proficient TotalTested PercentProficient, i(StateAssignedDistID DistName Subject) j(Grade)

drop if DistName==""
drop County CountyName

merge m:1 DistName using "${iowa}/NCES_2021_district.dta"

drop if _merge==2

gen DataLevel="District"
replace DataLevel="State" if DistName=="State"
replace DistName="All Districts" if DataLevel=="State"

save "${int}/IA_AssmtData_district_2023.dta", replace


/////////////////////////////////////////
*** Iowa School Cleaning ***
/////////////////////////////////////////



* ELA and Math
import excel "${raw}/Iowa - School/IA_OriginalData_2023_all.xlsx", sheet("ELA") cellrange(A7:AY1244) firstrow clear

gen Subject="ela"

save "${int}/IA_AssmtData_school_ela_2023.dta", replace

import excel "${raw}/Iowa - School/IA_OriginalData_2023_all.xlsx", sheet("Math") cellrange(A7:AY1244) firstrow clear

gen Subject="math"

save "${int}/IA_AssmtData_school_math_2023.dta", replace

append using "${int}/IA_AssmtData_school_ela_2023.dta"

drop L Q V AA AF AK AP AU 

foreach i of varlist K P U Z AE AJ AO AT AY {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	label var `i' "`a'"
}

foreach i of varlist K P U Z AE AJ AO AT AY {
	local x : variable label `i'
	rename `i' `x'
}

save "${int}/IA_AssmtData_school_2023.dta", replace

* Science
import excel "${raw}/Iowa - School/IA_OriginalData_2023_all.xlsx", sheet("Science") cellrange(A7:U1100) firstrow clear

gen Subject="sci"

drop L Q

foreach i of varlist K P U {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	label var `i' "`a'"
}

foreach i of varlist K P U {
	local x : variable label `i'
	rename `i' `x'
}

save "${int}/IA_AssmtData_school_sci_2023.dta", replace

* Entire dataset cleaning 
use "${int}/IA_AssmtData_school_2023.dta", clear

append using "${int}/IA_AssmtData_school_sci_2023.dta"

rename DistrictName DistName
rename District StateAssignedDistID

drop County CountyName AEA

rename SchoolName SchName
rename School StateAssignedSchID

rename *NotProficient NotProficient*
rename *PercentProficient PercentProficient*
rename *Proficient Proficient*
rename *TotalTested TotalTested*

rename *Grade* **

reshape long NotProficient Proficient TotalTested PercentProficient, i(StateAssignedSchID DistName SchName Subject) j(Grade)

drop if DistName=="" & SchName==""
gen State_leaid=StateAssignedDistID

merge m:1 DistName StateAssignedSchID using "${iowa}/NCES_2021_school.dta"

drop if DistName=="State" | SchName=="State"
gen DataLevel="School"

drop if _merge==2

save "${int}/IA_AssmtData_school_2023.dta", replace


/////////////////////////////////////////
*** Appending ALL data for IOWA ***
/////////////////////////////////////////

append using "${int}/IA_AssmtData_district_2023.dta"

drop if Grade>8
rename Grade GradeLevel
tostring GradeLevel, replace
replace GradeLevel="G0"+GradeLevel

drop State
gen State="Iowa"
replace StateAbbrev="IA"
replace StateFips=19
gen SchYear="2022-23"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

replace DistName="All Districts" if DataLevel==1
replace SchName="All Districts" if DataLevel==1

gen AssmtName="ISASP"
gen AssmtType="Regular and alt"
gen StudentGroup="All Students"

rename TotalTested StudentGroup_TotalTested 
rename PercentProficient ProficientOrAbove_percent
rename Proficient ProficientOrAbove_count

replace StudentGroup_TotalTested="--" if StudentGroup_TotalTested==""

gen ProficiencyCriteria="Levels 2 and 3"
gen AvgScaleScore="--"
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested 
gen ParticipationRate="--"

foreach x of numlist 1/5 {
    generate Lev`x'_count = ""
	generate Lev`x'_percent = ""
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

** Replace missing values
/*
foreach v of varlist StudentSubGroup_TotalTested AvgScaleScore Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ParticipationRate Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	tostring `v', replace
	replace `v' = "--" if `v' == "" | `v' == "."
}
*/

/*
foreach u of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	destring `u', replace force
	replace `u' = `u' / 100
	tostring `u', replace force
	replace `u' = "*" if `u' == "."
}
*/

gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth="N"


////////////////////////////////////
*** Review 1 Edits ***
////////////////////////////////////

replace State="Iowa"

replace SchName="All Schools" if DataLevel==2 | DataLevel==1

drop if DistName=="Accountable to State"

foreach i of varlist NCESDistrictID State_leaid NCESSchoolID seasch DistCharter CountyName {
	tostring `i', replace 
	replace `i'="Missing/not reported" if _merge==1 & DistName!="State" & DataLevel!=1
	replace `i'="" if DataLevel!=3 & _merge==1
}

foreach i of varlist SchType SchLevel SchVirtual DistType {
	replace `i'=-1 if _merge==1 & DistName!="State" & DataLevel!=1
	label define `i' -1 "Missing/not reported"
	replace `i'=. if DataLevel!=3 & _merge==1
}

foreach v of varlist StudentGroup_TotalTested StudentSubGroup_TotalTested ProficientOrAbove_count ProficientOrAbove_percent {
	replace `v'="*" if StudentSubGroup_TotalTested=="small N"
}

foreach v of varlist StudentSubGroup_TotalTested AvgScaleScore Lev1_count Lev2_count Lev3_count ProficientOrAbove_count ParticipationRate Lev1_percent Lev2_percent Lev3_percent ProficientOrAbove_percent {
	tostring `v', replace
	replace `v' = "--" if `v' == "" | `v' == "."
}

drop if _merge==1 & strpos(SchName, "Online")>0

save "${int}/IA_AssmtData_school_2023.dta", replace

keep if _merge==1 & DataLevel!=1

export delimited using "${output}/Unmerged/IA_unmerged_2023.csv", replace

use "${int}/IA_AssmtData_school_2023.dta", clear

////////////////////////////////////
*** Review 2 Edits ***
////////////////////////////////////

destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent=ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent="--" if ProficientOrAbove_percent=="."

label define agency_typedf -1 "Missing/not reported", add
label values DistType agency_typedf

////////////////////////////////////
*** Review 3 Edits ***
////////////////////////////////////

tostring StateAssignedDistID, replace
tostring State_leaid, replace

decode DataLevel, gen(DataLevel1)
drop DataLevel
rename DataLevel1 DataLevel

drop _merge

merge m:1 SchName DistName using "${raw}/IA_Unmerged.dta", update

////////////////////////////////////
*** Sorting ***
////////////////////////////////////

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

//sort
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
* replace SchVirtual = "Missing/not reported" if SchVirtual == "" & DataLevel == 3
* replace SchLevel = "Missing/not reported" if SchLevel == "" & DataLevel == 3

save "${output}/IA_AssmtData_all_2023.dta", replace

export delimited using "${output}/IA_AssmtData_2023.csv", replace
	
