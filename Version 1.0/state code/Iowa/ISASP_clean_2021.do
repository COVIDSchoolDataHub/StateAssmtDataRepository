clear
set more off

global raw "/Users/minnamgung/Desktop/SADR/Iowa/Input"
global output "/Users/minnamgung/Desktop/SADR/Iowa/Output"
global int "/Users/minnamgung/Desktop/SADR/Iowa/Intermediate"

global nces "/Users/minnamgung/Desktop/SADR/NCES"
global iowa "/Users/minnamgung/Desktop/SADR/Iowa/NCES"

/////////////////////////////////////////
*** NCES Cleaning for IA ***
/////////////////////////////////////////


/////////////////////////////////////////
*** Iowa District Cleaning ***
/////////////////////////////////////////

* ELA and Math
import excel "${raw}/Iowa - District/IA_OriginalData_2021_all.xlsx", sheet("ELA") cellrange(A7:BE338) firstrow clear

gen Subject="ela"
drop AX AY AZ BA BB BC BD BE

save "${int}/IA_AssmtData_district_ela_2021.dta", replace

import excel "${raw}/Iowa - District/IA_OriginalData_2021_all.xlsx", sheet("Math") cellrange(A7:AW338) firstrow clear

gen Subject="math"

save "${int}/IA_AssmtData_district_math_2021.dta", replace

append using "${int}/IA_AssmtData_district_ela_2021.dta"

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

save "${int}/IA_AssmtData_district_2021.dta", replace

* Science
import excel "${raw}/Iowa - District/IA_OriginalData_2021_all.xlsx", sheet("Science") cellrange(A7:S337) firstrow clear

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

save "${int}/IA_AssmtData_district_sci_2021.dta", replace

* Entire dataset cleaning 
use "${int}/IA_AssmtData_district_2021.dta", clear

append using "${int}/IA_AssmtData_district_sci_2021.dta"

rename DistrictName DistName
rename District StateAssignedDistID

rename *NotProficient NotProficient*
rename *PercentProficient PercentProficient*
rename *Proficient Proficient*
rename *TotalTested TotalTested*

rename *Grade* **

drop if DistName==""
drop County CountyName

reshape long NotProficient Proficient TotalTested PercentProficient, i(StateAssignedDistID DistName Subject) j(Grade)

gen State_leaid=StateAssignedDistID
merge m:1 State_leaid using "${iowa}/NCES_2020_district.dta"

drop if _merge==2

gen DataLevel="District"
replace DataLevel="State" if DistName=="State"
replace DistName="All Districts" if DataLevel=="State"

save "${int}/IA_AssmtData_district_2021.dta", replace


/////////////////////////////////////////
*** Iowa School Cleaning ***
/////////////////////////////////////////



* ELA and Math
import excel "${raw}/Iowa - School/IA_OriginalData_2021_all.xls", sheet("ELA") cellrange(A7:BG1230) firstrow clear

gen Subject="ela"
drop AZ BA BB BC BD BE BF BG

save "${int}/IA_AssmtData_school_ela_2021.dta", replace

import excel "${raw}/Iowa - School/IA_OriginalData_2021_all.xls", sheet("Math") cellrange(A7:AY1229) firstrow clear

gen Subject="math"

save "${int}/IA_AssmtData_school_math_2021.dta", replace

append using "${int}/IA_AssmtData_school_ela_2021.dta"

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

save "${int}/IA_AssmtData_school_2021.dta", replace

* Entire dataset cleaning 
use "${int}/IA_AssmtData_school_2021.dta", clear


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

drop if DistName=="" & SchName==""

reshape long NotProficient Proficient TotalTested PercentProficient, i(StateAssignedSchID DistName SchName Subject) j(Grade)

gen school_name=SchName
replace school_name="Odebolt Arthur Battle Creek Ida Grove Elementary-Ida Grove" if SchName=="Odebolt Arthur Battle Creek Ida Grove Elementary School - Ida Grove"
replace school_name="Odebolt Arthur Battle Creek Ida Grove Elementary-Odebolt" if SchName=="Odebolt Arthur Battle Creek Ida Grove Elementary School - Odebolt"
replace school_name="Van Buren County Community School District Douds Center" if SchName=="Van Buren County Community School District Middle & High School"


gen seasch=StateAssignedDistID
merge m:1 school_name seasch using "${iowa}/NCES_2020_school.dta"

drop if DistName=="State" | SchName=="State"
gen DataLevel="School"

drop if _merge==2

save "${int}/IA_AssmtData_school_2021.dta", replace


/////////////////////////////////////////
*** Appending ALL data for IOWA ***
/////////////////////////////////////////

append using "${int}/IA_AssmtData_district_2021.dta"

drop if Grade>8
rename Grade GradeLevel
tostring GradeLevel, replace
replace GradeLevel="G0"+GradeLevel

drop State
gen State="Iowa"
replace StateAbbrev="IA"
replace StateFips=19
gen SchYear="2020-21"

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

drop if DistName=="Rolled up to state"

foreach i of varlist NCESDistrictID State_leaid NCESSchoolID seasch CountyName DistCharter {
	tostring `i', replace 
	replace `i'="Missing/not reported" if _merge==1 & DataLevel!=1
}

foreach i of varlist DistType SchType SchLevel SchVirtual CountyCode {
	replace `i'=-1 if _merge==1 & DataLevel!=1 
	label def `i' -1 "Missing/not reported"
}

foreach v of varlist StudentGroup_TotalTested StudentSubGroup_TotalTested ProficientOrAbove_count ProficientOrAbove_percent {
	replace `v'="*" if `v'=="small N"
}

foreach v of varlist StudentSubGroup_TotalTested AvgScaleScore Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ParticipationRate Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	tostring `v', replace
	replace `v' = "--" if `v' == "" | `v' == "."
}

drop if _merge==1 & strpos(SchName, "Online")>0

save "${int}/IA_AssmtData_school_2021.dta", replace

keep if _merge==1 & DataLevel!=1

export delimited using "${output}/Unmerged/IA_unmerged_2021.csv", replace

use "${int}/IA_AssmtData_school_2021.dta", clear

////////////////////////////////////
*** Review 2 Edits ***
////////////////////////////////////

destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent=ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent="--" if ProficientOrAbove_percent=="."

label define agency_typedf -1 "Missing/not reported", add
label values DistType agency_typedf

replace Lev4_count=""
replace Lev4_percent=""

replace CountyCode=. if CountyCode==-1

////////////////////////////////////
*** Review 3 Edits ***
////////////////////////////////////

tostring StateAssignedDistID, replace
tostring State_leaid, replace

decode DataLevel, gen(DataLevel1)
drop DataLevel
rename DataLevel1 DataLevel

////////////////////////////////////
*** Sorting ***
////////////////////////////////////

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

//sort
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
* replace SchVirtual = "Missing/not reported" if SchVirtual == "" & DataLevel == 3
* replace SchLevel = "Missing/not reported" if SchLevel == "" & DataLevel == 3

save "${output}/IA_AssmtData_all_2021.dta", replace

export delimited using "${output}/IA_AssmtData_2021.csv", replace
