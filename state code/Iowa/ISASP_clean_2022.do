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

* District 
import delimited "${nces}/District/NCES_2021_District.csv", clear 

keep state stateabbrev statefips ncesdistrictid state_leaid districttype charter countyname countycode distname 
keep if statefips==19
	rename state State
	rename stateabbrev StateAbbrev
	rename statefips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename districttype DistType
	rename charter DistCharter
	rename distname DistName
	rename countycode CountyCode
	rename countyname CountyName
	
save "${iowa}/NCES_2021_district.dta", replace

* School
use "${nces}/School/NCES_2021_School.dta", clear

keep ncesschoolid school_name ncesdistrictid lea_name state_leaid state_location state_name state_fips county_name county_code school_level school_type virtual st_schid schid
keep if state_fips==19
	rename state_name State
	rename lea_name DistName
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename county_name CountyName
	rename ncesschoolid NCESSchoolID
	rename school_type SchType
	rename school_name SchName
	rename school_level SchLevel
	rename virtual SchVirtual

replace st_schid=substr(st_schid,-3,.)
gen StateAssignedSchID="0"+st_schid
	
save "${iowa}/NCES_2021_school.dta", replace


/////////////////////////////////////////
*** Iowa District Cleaning ***
/////////////////////////////////////////

* ELA and Math
import excel "${raw}/Iowa - District/IA_OriginalData_2022_all.xlsx", sheet("ELA") cellrange(A7:AW337) firstrow clear

gen Subject="ela"

save "${int}/IA_AssmtData_district_ela_2022.dta", replace

import excel "${raw}/Iowa - District/IA_OriginalData_2022_all.xlsx", sheet("Math") cellrange(A7:AW337) firstrow clear

gen Subject="math"

save "${int}/IA_AssmtData_district_math_2022.dta", replace

append using "${int}/IA_AssmtData_district_ela_2022.dta"

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

save "${int}/IA_AssmtData_district_2022.dta", replace

* Science
import excel "${raw}/Iowa - District/IA_OriginalData_2022_all.xlsx", sheet("Science") cellrange(A7:S337) firstrow clear

gen Subject="sci"

drop J O

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

save "${int}/IA_AssmtData_district_sci_2022.dta", replace

* Entire dataset cleaning 
use "${int}/IA_AssmtData_district_2022.dta", clear

append using "${int}/IA_AssmtData_district_sci_2022.dta"

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

foreach i of varlist NCESDistrictID State_leaid DistType DistCharter CountyName CountyCode {
	tostring `i', replace 
	replace `i'="Missing/not reported" if _merge==1 & DistName!="State" & DistName!="Accountable to State"
}

drop if _merge==2
drop _merge AEA

gen DataLevel="District"
replace DataLevel="State" if DistName=="State"
replace DistName="All Districts" if DataLevel=="State"

save "${int}/IA_AssmtData_district_2022.dta", replace


/////////////////////////////////////////
*** Iowa School Cleaning ***
/////////////////////////////////////////



* ELA and Math
import excel "${raw}/Iowa - School/IA_OriginalData_2022_all.xlsx", sheet("ELA") cellrange(A7:AY1244) firstrow clear

gen Subject="ela"

save "${int}/IA_AssmtData_school_ela_2022.dta", replace

import excel "${raw}/Iowa - School/IA_OriginalData_2022_all.xlsx", sheet("Math") cellrange(A7:AY1244) firstrow clear

gen Subject="math"

save "${int}/IA_AssmtData_school_math_2022.dta", replace

append using "${int}/IA_AssmtData_school_ela_2022.dta"

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

save "${int}/IA_AssmtData_school_2022.dta", replace

* Science
import excel "${raw}/Iowa - School/IA_OriginalData_2022_all.xlsx", sheet("Science") cellrange(A7:U1105) firstrow clear

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

save "${int}/IA_AssmtData_school_sci_2022.dta", replace

* Entire dataset cleaning 
use "${int}/IA_AssmtData_school_2022.dta", clear

append using "${int}/IA_AssmtData_school_sci_2022.dta"

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

merge m:1 DistName StateAssignedSchID using "${iowa}/NCES_2021_school.dta"

drop st_schid schid

foreach i of varlist NCESSchoolID NCESDistrictID State_leaid CountyName CountyCode SchLevel SchType SchVirtual {
	tostring `i', replace 
	replace `i'="Missing/not reported" if _merge==1 & DistName!="State" & DistName!="Accountable to State"
}

drop if DistName=="State" | SchName=="State"
gen DataLevel="School"

drop if _merge==2
drop _merge

save "${int}/IA_AssmtData_school_2022.dta", replace


/////////////////////////////////////////
*** Appending ALL data for IOWA ***
/////////////////////////////////////////

append using "${int}/IA_AssmtData_district_2022.dta"

drop if Grade>8
rename Grade GradeLevel
tostring GradeLevel, replace
replace GradeLevel="G0"+GradeLevel

replace State="IOWA"
replace StateAbbrev="IA"
replace StateFips=19
gen SchYear="2021-22"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

replace DistName="All Districts" if DataLevel==1
replace SchName="All Districts" if DataLevel==1

gen seasch=""
gen AssmtName="ISASP"
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
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth="N"

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

//sort
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
replace SchVirtual = "Missing/not reported" if SchVirtual == "" & DataLevel == 3
replace SchLevel = "Missing/not reported" if SchLevel == "" & DataLevel == 3

save "${output}/IA_AssmtData_all_2022.dta"
