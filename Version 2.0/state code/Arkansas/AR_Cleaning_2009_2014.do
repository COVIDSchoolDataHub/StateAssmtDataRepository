clear
set more off
set trace off

forvalues year = 2009/2014 {
local prevyear =`=`year'-1'
tempfile temp1
save "`temp1'", emptyok
clear
forvalues grade = 3/8 {
	import excel "${Original}/AR_OriginalData_`year'", sheet("Grade `grade'") allstring
	if `year' >= 2012 {
		drop in 1/5
	}
	gen DataLevel = ""
	replace DataLevel = "State" if C == "STATE TOTALS"
	drop if _n==1
	gen GradeLevel = "G0`grade'"
	append using "`temp1'"
	save "`temp1'", replace
	clear
	
}
use "`temp1'"
save "${Original}/`year'", replace
if `year' < 2012 {
//Varnames
drop A
if `year' != 2011 drop B 
if `year' != 2011 rename C StateAssignedDistID
if `year' != 2011 rename D StateAssignedSchID
if `year' == 2011 rename B StateAssignedDistID
if `year' == 2011 rename C StateAssignedSchID
if `year' == 2011 drop D
rename E DistName
rename F SchName
rename G StudentSubGroup_TotalTestedM
rename H AvgScaleScoreM
rename I Lev1_percentM
rename J Lev2_percentM
rename K Lev3_percentM
rename L Lev4_percentM
rename M StudentSubGroup_TotalTestedE
rename N AvgScaleScoreE
rename O Lev1_percentE
rename P Lev2_percentE
rename Q Lev3_percentE
rename R Lev4_percentE
rename S StudentSubGroup_TotalTestedS
rename T AvgScaleScoreS
rename U Lev1_percentS
rename V Lev2_percentS
rename W Lev3_percentS
rename X Lev4_percentS
}
if `year' > 2011 {
rename A StateAssignedDistID
rename B StateAssignedSchID
drop C
rename D DistName
rename E SchName
rename F StudentSubGroup_TotalTestedM
rename G AvgScaleScoreM
rename H Lev1_percentM
rename I Lev2_percentM
rename J Lev3_percentM
rename K Lev4_percentM
rename L StudentSubGroup_TotalTestedE
rename M AvgScaleScoreE
rename N Lev1_percentE
rename O Lev2_percentE
rename P Lev3_percentE
rename Q Lev4_percentE
rename R StudentSubGroup_TotalTestedS
rename S AvgScaleScoreS
rename T Lev1_percentS
rename U Lev2_percentS
rename V Lev3_percentS
rename W Lev4_percentS
}

//DataLevel
replace DataLevel = "District" if regexm(StateAssignedSchID, "[0-9]") ==0
replace DataLevel = "School" if regexm(StateAssignedSchID, "[0-9]") !=0
replace DataLevel = "State" if regexm(StateAssignedDistID, "[0-9]") ==0
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
drop if DataLevel == 1 & strpos(DistName, "REGION") !=0
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel !=3
replace SchName = "All Schools" if DataLevel !=3
replace DistName = "All Districts" if DataLevel ==1

//Reshaping from Wide -> Long
drop if DataLevel == 1 & missing(StudentSubGroup_TotalTestedE)
reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent StudentSubGroup_TotalTested AvgScaleScore, i(DataLevel StateAssignedDistID StateAssignedSchID GradeLevel) j(Subject, string)

//Dropping if empty StudentSubGroup_TotalTested
drop if StudentSubGroup_TotalTested == "0"

**Merging with NCES Data**
gen StateAssignedDistID1 = StateAssignedDistID
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedDistID1 = subinstr(StateAssignedDistID1, "-","",.)
if `year' >= 2011 replace StateAssignedSchID1 = subinstr(StateAssignedSchID1, "-","",.)
if `year' <2011 replace StateAssignedSchID1 = StateAssignedDistID1 + StateAssignedSchID1
tempfile temp1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'"
clear
use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_`prevyear'_District"
keep if state_name == "Arkansas" | state_location == "AR"
gen StateAssignedDistID1 = substr(state_leaid,1,4)
duplicates drop StateAssignedDistID, force 
merge 1:m StateAssignedDistID1 using "`tempdist'"
drop if _merge==1
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'"
clear
use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_`prevyear'_School"
keep if state_name == "Arkansas" | state_location == "AR"
gen StateAssignedSchID1 = seasch
if `year' == 2010 replace StateAssignedSchID1 = "5802005" if StateAssignedSchID1 == "5802009"
merge 1:m StateAssignedSchID1 using "`tempsch'"
drop if _merge==1
save "`tempsch'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
*rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 5
replace StateAbbrev = "AR"

//Fixing Subject
replace Subject = "math" if Subject == "M"
replace Subject = "ela" if Subject == "E"
replace Subject = "sci" if Subject == "S"

//StudentGroup and StudentSubGroup
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

//StudentGroup_TotalTested
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

//Suppression
foreach var of varlist _all {
	cap replace `var' = "*" if `var' == "xx"
}

//Proficiency Levels and ProficientOrAbove_percent
foreach n in 1 2 3 4 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*)
	replace Lev`n'_percent = string(nLev`n'_percent/100) if Lev`n'_percent != "*"
}
gen ProficientOrAbove_percent = string((nLev3_percent + nLev4_percent)/100)
replace ProficientOrAbove_percent = "*" if Lev3_percent == "*"| Lev4_percent == "*"

//Generating additional variables
gen State = "Arkansas"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not Applicable"
gen ProficiencyCriteria = "Levels 3-4"
gen Lev5_percent = "--"
gen Lev5_count = "--"
gen AssmtType = "Regular"
gen AssmtName = "Augmented Benchmark"
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)

//Generating Missing
forvalues n = 1/4 {
	gen Lev`n'_count = "--"
}
gen ParticipationRate = "--"
gen ProficientOrAbove_count = "--"

replace DistName = trim(DistName)
replace SchName = trim(SchName)

//Fixing Unmerged
if `year' == 2012 {
replace NCESSchoolID = "050900001387" if SchName == "Cloverdale Middle School"
replace NCESDistrictID = "0509000" if SchName == "Cloverdale Middle School"
replace State_leaid = "6001000" if SchName == "Cloverdale Middle School"
replace seasch = "6001077" if SchName == "Cloverdale Middle School"
replace SchType = 1 if SchName == "Cloverdale Middle School"
replace DistType = "Regular local school district" if SchName == "Cloverdale Middle School"
replace CountyName = "PULASKI COUNTY" if SchName == "Cloverdale Middle School"
replace CountyCode = "5119" if SchName == "Cloverdale Middle School"
replace DistCharter = "No" if SchName == "Cloverdale Middle School"
replace SchVirtual = -1 if SchName == "Cloverdale Middle School"
replace SchLevel = 2 if SchName == "Cloverdale Middle School"
drop if SchName == "Cloverdale Middle School"
}


//Dropping unmerged suppressed
if `year' == 2009 drop if SchName == "ALT LEARNING ENVIRON" & missing(NCESSchoolID)

//Missing NCES Data
*label def agency_typedf 16 "Missing/not reported", add
*label def school_typedf 16 "Missing/not reported", add
replace DistType = "Missing/not reported" if missing(DistType) & DataLevel !=1
label def SchType -1 "Missing/not reported", add
replace SchType = -1 if missing(SchType) & DataLevel ==3

//Replacing StateAssignedSchID with StateAssignedDistIDStateAssignedSchID in 2009 & 2010
if `year' <2011 replace StateAssignedSchID = StateAssignedDistID + StateAssignedSchID if DataLevel ==3

//Dropping Extra Sci tests in response to R1
drop if Subject == "sci" & !inlist(GradeLevel, "G05", "G07")

//Update Mar 30 2024: Changing StateAssignedDistID to State_leaid
replace StateAssignedDistID = State_leaid

//Response to Post-Launch Review: Getting rid of hyphins in StateAssignedDistID
replace StateAssignedDistID = subinstr(StateAssignedDistID, "-","",.)
replace StateAssignedSchID = subinstr(StateAssignedSchID, "-", "",.)

//Post-Launch Change: proper(CountyName)
replace CountyName = proper(CountyName)

//Deriving ProficientOrAbove_percent where possible
replace ProficientOrAbove_percent = string(1-(real(Lev1_percent) + real(Lev2_percent)), "%9.3g") if regexm(Lev1_percent, "[0-9]") !=0 & regexm(Lev2_percent, "[0-9]") !=0 & regexm(ProficientOrAbove_percent, "[0-9]") ==0

//Deriving Counts
foreach var of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`var'","percent","count",.)
replace `count' = string(round(real(`var')*real(StudentSubGroup_TotalTested))) if regexm(`var', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0	
}


//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/AR_AssmtData_`year'", replace
export delimited "${Output}/AR_AssmtData_`year'", replace
clear
}
