clear
set more off
set trace off
local Original "/Volumes/T7/State Test Project/Arkansas/Original Data"
local Output "/Volumes/T7/State Test Project/Arkansas/Output"
local NCES "/Volumes/T7/State Test Project/NCES"

//Importing

forvalues year = 2016/2022 {
local prevyear =`=`year'-1'
if `year' == 2020 continue
tempfile temp1
save "`temp1'", replace emptyok 
clear

import excel "`Original'/AR_OriginalData_`year'", sheet(Schools) firstrow allstring
append using "`temp1'"
save "`temp1'", replace
clear
import excel "`Original'/AR_OriginalData_`year'", sheet(Districts) firstrow allstring
append using "`temp1'"
save "`temp1'", replace
clear
import excel "`Original'/AR_OriginalData_`year'", sheet(State) firstrow allstring
append using "`temp1'"
save "`Original'/`year'", replace


//Renaming in prep for reshape
rename EnglishN StudentSubGroup_TotalTestedeng
rename EnglishInNeedofSupport Lev1_percenteng
rename EnglishClose Lev2_percenteng
rename EnglishReady Lev3_percenteng
rename EnglishExceeding Lev4_percenteng
rename EnglishMetReadinessBenchmar ProficientOrAbove_percenteng
rename MathN StudentSubGroup_TotalTestedmath
rename MathInNeedofSupport Lev1_percentmath
rename MathClose Lev2_percentmath
rename MathReady Lev3_percentmath
rename MathExceeding Lev4_percentmath
rename MathMetReadinessBenchmark ProficientOrAbove_percentmath
rename ScienceN StudentSubGroup_TotalTestedsci
rename ScienceInNeedofSupport Lev1_percentsci
rename ScienceClose Lev2_percentsci
rename ScienceReady Lev3_percentsci
rename ScienceExceeding Lev4_percentsci
rename ScienceMetReadinessBenchmar ProficientOrAbove_percentsci
rename ReadingN StudentSubGroup_TotalTestedread
rename ReadingInNeedofSupport Lev1_percentread
rename ReadingClose Lev2_percentread
rename ReadingReady Lev3_percentread
rename ReadingExceeding Lev4_percentread
rename ReadingMetReadinessBenchmar ProficientOrAbove_percentread
if `year' < 2018 {
rename WritingN StudentSubGroup_TotalTestedwrit
rename WritingInNeedofSupport Lev1_percentwrit
rename WritingClose Lev2_percentwrit
rename WritingReady Lev3_percentwrit
rename WritingExceeding Lev4_percentwrit
rename WritingMetReadinessBenchmar ProficientOrAbove_percentwrit
}
rename ELAN StudentSubGroup_TotalTestedela
rename ELAInNeedofSupport Lev1_percentela
rename ELAClose Lev2_percentela
rename ELAReady Lev3_percentela
rename ELAExceeding Lev4_percentela
rename ELAMetReadinessBenchmark ProficientOrAbove_percentela
rename STEMN StudentSubGroup_TotalTestedstem
rename STEMMetReadinessBenchmark ProficientOrAbove_percentstem
if `year' < 2021 rename Grade GradeLevel
if `year' == 2016 rename DISTRICTLEA DistrictLEA
rename DistrictLEA StateAssignedDistID
rename SchoolLEA StateAssignedSchID
rename DISTRICTNAME DistName
rename SCHOOLNAME SchName 
if `year' == 2022 replace StateAssignedDistID = DISTRICTLEA if missing(StateAssignedDistID)
if `year' == 2022 drop DISTRICTLEA
//Reshaping from wide to long
reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent StudentSubGroup_TotalTested ProficientOrAbove_percent, i(GradeLevel StateAssignedSchID StateAssignedDistID) j(Subject, string)
*save "/Volumes/T7/State Test Project/Arkansas/Testing/`year'", replace


//GradeLevel
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//StudentSubGroup and StudentGroup
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

//Supression / missing
foreach var of varlist Lev* ProficientOrAbove_percent StudentSubGroup_TotalTested StudentGroup_TotalTested {
	replace `var' = lower(`var')
	replace `var' = "*" if `var' == "n<10"
	replace `var' = "*" if `year' == 2019 & Subject == "ela" & `var' == "."
	replace `var' = "--" if missing(`var')
	replace `var' = "--" if `var' == "na"
	replace `var' = "--" if `var' == "."
}

//Proficiency Levels
foreach n in 1 2 3 4 {
	drop if Lev`n'_percent == "rv"
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*-%)
	replace Lev`n'_percent = string(nLev`n'_percent/100) if Lev`n'_percent != "*" & Lev`n'_percent != "--"
	
}

destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*-%)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100) if ProficientOrAbove_percent != "*" & ProficientOrAbove_percent != "--"

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if missing(StateAssignedDistID) & missing(StateAssignedSchID)
replace DataLevel = "District" if !missing(StateAssignedDistID) & missing(StateAssignedSchID)
replace DataLevel = "School" if !missing(StateAssignedDistID) & !missing(StateAssignedSchID)
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1
*save "/Volumes/T7/State Test Project/Arkansas/Testing/`year'", replace

**Merging**
gen StateAssignedSchID1 = ""
if `year' == 2016 replace StateAssignedSchID1 = StateAssignedSchID
if `year' > 2016 replace StateAssignedSchID1 = StateAssignedDistID + "-" + StateAssignedSchID
tempfile temp1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
clear
use "`NCES'/NCES_`prevyear'_District"
keep if state_name == 5 | state_location == "AR"
gen StateAssignedDistID = subinstr(state_leaid, "AR-","",.)
duplicates drop StateAssignedDistID, force
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge ==1
save "`tempdist'", replace
clear

//School 
use "`temp1'"
keep if DataLevel ==3
tempfile tempsch
save "`tempsch'", replace
clear
use "`NCES'/NCES_`prevyear'_School"
keep if state_name == 5 | state_location == "AR"
gen StateAssignedSchID1 = seasch
 if `year' ==2019 replace StateAssignedSchID1 = "6061700-6061702" if ncesschoolid == "050042301657"
duplicates drop StateAssignedSchID, force
merge 1:m StateAssignedSchID1 using "`tempsch'"
drop if _merge ==1
save "`tempsch'", replace

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 5
replace StateAbbrev = "AR"

//Generating additional variables
gen State = "Arkansas"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
gen Flag_CutScoreChange_read = "N"
gen ProficiencyCriteria = "Levels 3 and 4"
gen AssmtType = "Regular"
gen AssmtName = "ACT Aspire"
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2018
replace Flag_CutScoreChange_oth = "Y" if `year' == 2018

foreach var of varlist Flag* {
	replace `var' = "Y" if `year' == 2016
}

//Missing Variables

foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
}
gen ProficientOrAbove_count = "--"
gen Lev5_percent = ""
gen Lev5_count = ""
gen AvgScaleScore = "--"
gen ParticipationRate = "--"

//Dropping if StudentSubGroup_TotalTested == 0
drop if StudentSubGroup_TotalTested == "0"

//Missing DistName for some obs (??)
replace DistName = "ARKANSAS CONNECTIONS ACADEMY" if NCESDistrictID == "0500417"
replace DistName = "JACKSONVILLE NORTH PULASKI SCHOOL DISTRICT" if NCESDistrictID == "0500419"

drop if missing(DistName) & missing(NCESDistrictID) & DataLevel ==2
replace DistName = lea_name if missing(DistName) & DataLevel ==2

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/AR_AssmtData_`year'", replace
export delimited "`Output'/AR_AssmtData_`year'", replace
clear

clear
}
