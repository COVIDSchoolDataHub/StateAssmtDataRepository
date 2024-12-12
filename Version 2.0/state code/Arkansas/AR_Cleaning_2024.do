clear
set more off
set trace off

global Original "/Users/miramehta/Documents/AR State Testing Data/Original Data"
global Output "/Users/miramehta/Documents/AR State Testing Data/Output"
global NCES "//Users/miramehta/Documents/NCES District and School Demographics"
global Temp "/Users/miramehta/Documents/AR State Testing Data/Temp"
global EDFacts "/Users/miramehta/Documents/AR State Testing Data/EDFacts"

//Importing = Unhide on First Run
/*
** All Students Data
tempfile temp1
save "`temp1'", replace emptyok 
clear

import excel "${Original}/AR_OriginalData_2024", sheet(Schools) firstrow allstring
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/AR_OriginalData_2024", sheet(Districts) firstrow allstring
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/AR_OriginalData_2024", sheet(State) firstrow allstring
append using "`temp1'"
save "${Original}/2024", replace

import excel "${Original}/AR_School_Subgroups_2024_no counts.xlsx", clear cellrange(A2)

foreach v of varlist _all {
replace `v' = subinstr(`v',"ATLAS - All Grades","DROP",.)
replace `v' = subinstr(`v',"ATLAS - Grade ","",.)
replace `v' = subinstr(`v',": At or Above Grade Level Mastery - ","",.)
local vars = `v'[2] + `v'[1]
replace `v' = "`vars'" in 1
replace `v' = subinstr(`v', " ", "",50) in 1
replace `v' = subinstr(`v', "EconomicallyDisadvantaged", "_ECD_",.) in 1
replace `v' = subinstr(`v', "StudentswithDisabilities", "_SWD_",.) in 1
replace `v' = subinstr(`v', "African-American", "_BLK_",.) in 1
replace `v' = subinstr(`v', "Caucasian", "_WHT_",.) in 1
replace `v' = subinstr(`v', "Hispanic", "_HIS_",.) in 1
replace `v' = subinstr(`v', "LEP", "_LEP_",.) in 1
replace `v' = subinstr(`v', "NotEnglishLearner", "_EngProf_",.) in 1
replace `v' = subinstr(`v', "FormerEnglishLearner", "_ELEx_",.) in 1
replace `v' = subinstr(`v', "Migrant", "_MIG_",.) in 1
replace `v' = subinstr(`v', "MilitaryDependent", "_MIL_",.) in 1
replace `v' = subinstr(`v', "FosterCare", "_FOS_",.) in 1
replace `v' = subinstr(`v', "Homeless", "_HOM_",.) in 1
replace `v' = subinstr(`v', "Female", "_FML_",.) in 1
replace `v' = subinstr(`v', "Male", "_MAL_",.) in 1
replace `v' = subinstr(`v', "GiftedandTalented", "_GTDROP_",.) in 1
replace `v' = subinstr(`v', "All Students", "_ALL_",.) in 1
forvalues n = 3/8 {
	replace `v' = subinstr(`v',"`n'","`n'",.) in 1
}
replace `v' = subinstr(`v', "Science", "_sci",.) in 1
replace `v' = subinstr(`v', "Reading", "_read",.) in 1
replace `v' = subinstr(`v', "ELA", "_ela",.) in 1
replace `v' = subinstr(`v', "Mathematics", "_math",.) in 1
}
drop in 2 // Second part of varnames included in new variables, dropping

foreach v of varlist _all { //renaming vars to first row
local var = `v'[1]
rename `v' Prof`var'
}
drop in 1 //Renamed v

rename ProfLEA StateAssignedSchID
rename ProfSchoolName SchName
rename ProfDistrictLEAInformation DistName 

gen DataLevel = "School"

save "${Temp}/AR_OriginalData_2024_School.dta", replace

** SubGroup Data
import excel "${Original}/AR_District_Subgroups_2024_no counts.xlsx", clear cellrange(A2)

foreach v of varlist _all {
replace `v' = subinstr(`v',"ATLAS - All Grades","DROP",.)
replace `v' = subinstr(`v',"ATLAS - Grade ","",.)
replace `v' = subinstr(`v',": At or Above Grade Level Mastery - ","",.)
local vars = `v'[2] + `v'[1]
replace `v' = "`vars'" in 1
replace `v' = subinstr(`v', " ", "",50) in 1
replace `v' = subinstr(`v', "EconomicallyDisadvantaged", "_ECD_",.) in 1
replace `v' = subinstr(`v', "StudentswithDisabilities", "_SWD_",.) in 1
replace `v' = subinstr(`v', "African-American", "_BLK_",.) in 1
replace `v' = subinstr(`v', "Caucasian", "_WHT_",.) in 1
replace `v' = subinstr(`v', "Hispanic", "_HIS_",.) in 1
replace `v' = subinstr(`v', "LEP", "_LEP_",.) in 1
replace `v' = subinstr(`v', "NotEnglishLearner", "_EngProf_",.) in 1
replace `v' = subinstr(`v', "FormerEnglishLearner", "_ELEx_",.) in 1
replace `v' = subinstr(`v', "Migrant", "_MIG_",.) in 1
replace `v' = subinstr(`v', "MilitaryDependent", "_MIL_",.) in 1
replace `v' = subinstr(`v', "FosterCare", "_FOS_",.) in 1
replace `v' = subinstr(`v', "Homeless", "_HOM_",.) in 1
replace `v' = subinstr(`v', "Female", "_FML_",.) in 1
replace `v' = subinstr(`v', "Male", "_MAL_",.) in 1
replace `v' = subinstr(`v', "GiftedandTalented", "_GTDROP_",.) in 1
replace `v' = subinstr(`v', "All Students", "_ALL_",.) in 1
forvalues n = 3/8 {
	replace `v' = subinstr(`v',"`n'","`n'",.) in 1
}
replace `v' = subinstr(`v', "Science", "_sci",.) in 1
replace `v' = subinstr(`v', "Reading", "_read",.) in 1
replace `v' = subinstr(`v', "ELA", "_ela",.) in 1
replace `v' = subinstr(`v', "Mathematics", "_math",.) in 1
}
drop in 2 // Second part of varnames included in new variables, dropping

foreach v of varlist _all { //renaming vars to first row
local var = `v'[1]
rename `v' Prof`var'
}
drop in 1 //Renamed v

rename ProfLEA StateAssignedDistID
rename ProfDistrictName DistName

gen DataLevel = "District"

append using "${Temp}/AR_OriginalData_2024_School.dta"

save "${Temp}/AR_OriginalData_2024_Dist_School.dta", replace
*/
use "${Temp}/AR_OriginalData_2024_Dist_School.dta", clear

//Reshape Data
reshape long Prof, i(DataLevel DistName SchName StateAssignedSchID) j(StudentSubGroup) str

drop if strpos(StudentSubGroup, "DROP") > 0
drop if strpos(StudentSubGroup, "AllStudents") > 0
drop if strpos(StudentSubGroup, "TAGG") > 0

gen Subject = ""
replace Subject = "ela" if strpos(StudentSubGroup, "ela") != 0
replace Subject = "math" if strpos(StudentSubGroup, "math") != 0
replace Subject = "sci" if strpos(StudentSubGroup, "sci") != 0
replace Subject = "read" if strpos(StudentSubGroup, "read") != 0
replace StudentSubGroup = subinstr(StudentSubGroup, Subject, "", 1)
drop if strpos(StudentSubGroup, "Combined") > 0

gen GradeLevel = substr(StudentSubGroup, strlen(StudentSubGroup) - 1, 2)
replace StudentSubGroup = subinstr(StudentSubGroup, GradeLevel, "", 1)
replace GradeLevel = "G0" + GradeLevel
replace GradeLevel = subinstr(GradeLevel, "_", "", 1)
rename Prof ProficientOrAbove_percent

//StudentGroup & StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "_", "", .)

gen StudentGroup = "All Students" if StudentSubGroup == "All"
replace StudentGroup = "Disability Status" if strpos(StudentSubGroup, "SWD") > 0
replace StudentGroup = "Economic Status" if strpos(StudentSubGroup, "ECD") > 0
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "LEP", "EngProf", "ELEx")
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "FOS"
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "FML", "MAL")
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "HOM"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "MIG"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "MIL"
replace StudentGroup = "RaceEth" if inlist(StudentSubGroup, "BLK", "HIS", "WHT")

replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "BLK"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "HIS"
replace StudentSubGroup = "White" if StudentSubGroup == "WHT"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NotECD"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "ELEx"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "EngProf"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "NotSWD"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "FOS"
replace StudentSubGroup = "Homeless" if StudentSubGroup == "HOM"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "MIG"
replace StudentSubGroup = "Military" if StudentSubGroup == "MIL"
replace StudentSubGroup = "Female" if StudentSubGroup == "FML"
replace StudentSubGroup = "Male" if StudentSubGroup == "MAL"

//Assessment & Performance Information
gen SchYear = "2023-24"
gen AssmtName = "ATLAS"
gen AssmtType = "Regular and alt"
gen ProficiencyCriteria = "Levels 3-4"
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_sci = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"

forvalues n = 1/4{
	gen Lev`n'_count = "--"
	gen Lev`n'_percent = "--"
}
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficientOrAbove_count = "--"
gen StudentSubGroup_TotalTested = "--"
gen AvgScaleScore = "--"
gen ParticipationRate = "--"

replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "N/A"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "RV"
destring ProficientOrAbove_percent, gen(Prof) i(*-)
replace ProficientOrAbove_percent = string(Prof, "%9.4f") if Prof != .

//Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1

save "${Temp}/AR_AssmtData_2024_nocountsSG.dta", replace

use "${Original}/2024", clear

//Renaming Variables
rename Grade GradeLevel
replace GradeLevel = grade if GradeLevel == "" & grade != ""
drop grade

rename DISTRICTNAME DistName 
rename SCHOOLNAME SchName
rename DistrictLEA StateAssignedDistID
rename SchoolLEA StateAssignedSchID
replace StateAssignedDistID = DISTRICTLEA if StateAssignedDistID == "" & DISTRICTLEA != ""
drop DISTRICTLEA

drop Algebra* Biology* Geometry*
rename ELA* ela*
rename Math* math*
rename Reading* read*
rename Science* sci*
rename *N StudentSubGroup_TotalTested*
forvalues n = 1/4{
	rename *Level`n' Lev`n'_percent*
}

//Reshaping from wide to long
reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent StudentSubGroup_TotalTested, i(GradeLevel StateAssignedSchID StateAssignedDistID StateAssignedSchID) j(Subject, string)

//GradeLevel
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//StudentSubGroup and StudentGroup
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

//Supression / missing
foreach var of varlist Lev* StudentSubGroup_TotalTested StudentGroup_TotalTested {
	replace `var' = lower(`var')
	replace `var' = "*" if `var' == "n<10"
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

gen nProficientOrAbove_percent = nLev3_percent + nLev4_percent if nLev3_percent != . & nLev4_percent != .
gen ProficientOrAbove_percent = string(nProficientOrAbove_percent/100)
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "." & (Lev3_percent == "*" | Lev4_percent == "*")
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

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

//Generating additional variables
gen State = "Arkansas"
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_sci = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"
gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular"
gen AssmtName = "ATLAS"
gen SchYear = "2023-24"

//Missing Variables

foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
}
gen ProficientOrAbove_count = "--"
gen Lev5_percent = "--"
gen Lev5_count = "--"
gen AvgScaleScore = "--"
gen ParticipationRate = "--"

save "${Temp}/AR_AssmtData_2024_AllStudents", replace

append using "${Temp}/AR_AssmtData_2024_nocountsSG.dta"
drop if DistName == "N/A" //these are obs for pre-school/pre-K with no actual data
drop if inlist(StateAssignedSchID, "1603011", "1611051", "6058706") //additional obs for pre-school/adult education without real data

**Merging**
tempfile temp1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
clear
use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District"
keep if state_name == "Arkansas" | state_location == "AR"
gen StateAssignedDistID = subinstr(state_leaid, "AR-","",.)
duplicates drop StateAssignedDistID, force
tostring _all, replace force
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge ==1
save "`tempdist'", replace
clear

//School 
use "`temp1'"
keep if DataLevel ==3
tempfile tempsch
save "`tempsch'", replace

use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_2022_School", clear
keep if state_name == "Arkansas" | state_location == "AR"
gen StateAssignedSchID1 = seasch 	
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1, 10)
replace StateAssignedSchID1 = "3201702" if ncesschoolid == "050001900042"
replace StateAssignedSchID1 = "0442703" if ncesschoolid == "050040901606"

foreach var of varlist year district_agency_type SchLevel SchVirtual school_type {
	decode `var', gen(`var'_x)
	drop `var'
	rename `var'_x `var'
}
tostring _all, replace force

duplicates drop StateAssignedSchID, force
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge ==1

save "`tempsch'", replace

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"

replace StateAssignedDistID = state_leaid if StateAssignedDistID == ""
replace StateAssignedDistID = subinstr(StateAssignedDistID, "AR-", "", 1)

//2024 District Information (New Schools)
drop if inlist(SchLevel, "Prekindergarten", "Adult Education")

replace StateAssignedDistID = "1804000" if StateAssignedSchID == "1804026"
replace StateAssignedDistID = "3505000" if StateAssignedSchID == "3505052"
replace StateAssignedDistID = "4702000" if StateAssignedSchID == "4702015"
replace StateAssignedDistID = "4706000" if StateAssignedSchID == "4706702"
replace StateAssignedDistID = "4901000" if StateAssignedSchID == "4901703"
replace StateAssignedDistID = "6041700" if StateAssignedSchID == "6041713"
replace StateAssignedDistID = "6060700" if StateAssignedSchID == "6060705"
replace StateAssignedDistID = "6064700" if StateAssignedSchID == "6064703"
replace StateAssignedDistID = "6302000" if StateAssignedSchID == "6302013"
replace StateAssignedDistID = "6601000" if StateAssignedSchID == "6601703"
replace StateAssignedDistID = "7203000" if StateAssignedSchID == "7203030"
replace StateAssignedDistID = "7240700" if StateAssignedSchID == "7240715"
replace StateAssignedDistID = "7503000" if StateAssignedSchID == "7503008"
replace StateAssignedDistID = "3544700" if inlist(StateAssignedSchID, "3544705", "3544710")
replace StateAssignedDistID = "6505000" if inlist(StateAssignedSchID, "6505018", "6505019", "6505020", "6505021")

tempfile temp2
save "`temp2'", replace

use "`temp2'", clear
keep if ncesdistrictid != ""
tempfile merged
save "`merged'", replace

use "`temp2'", clear
keep if ncesdistrictid == ""
tempfile unmerged
save "`unmerged'", replace

use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District"
keep if state_name == "Arkansas" | state_location == "AR"
gen StateAssignedDistID = subinstr(state_leaid, "AR-","",.)
duplicates drop StateAssignedDistID, force
tostring _all, replace force
merge 1:m StateAssignedDistID using "`unmerged'", gen(merge2)
drop if merge2 ==1
append using "`merged'"

//Fixing NCES Variables
rename state_location StateAbbrev
drop state_fips
rename district_agency_type DistType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
gen StateFips = 5
replace State = "Arkansas"
replace StateAbbrev = "AR"
rename school_type SchType

//2024 New Schools
replace NCESDistrictID = "514491" if StateAssignedDistID == "6064700"
replace DistType = "Charter agency" if NCESDistrictID == "514491"
replace DistCharter = "Yes" if NCESDistrictID == "514491"
replace DistLocale = "City, midsize" if NCESDistrictID == "514491"
replace CountyName = "Pulaski County" if NCESDistrictID == "514491"
replace CountyCode = "5119" if NCESDistrictID == "514491"
replace NCESSchoolID = "51449105158" if StateAssignedSchID == "6064703"
replace SchType = "Regular school" if NCESSchoolID == "51449105158"
replace SchLevel = "Secondary" if NCESSchoolID == "51449105158"
replace SchVirtual = "No" if NCESSchoolID == "51449105158"

replace NCESSchoolID = "50939005150" if StateAssignedSchID == "1804026"
replace SchType = "Regular school" if NCESSchoolID == "50939005150"
replace SchLevel = "Middle" if NCESSchoolID == "50939005150"
replace SchVirtual = "No" if NCESSchoolID == "50939005150"

replace NCESSchoolID = "50002605151" if StateAssignedSchID == "3505052"
replace SchType = "Regular school" if NCESSchoolID == "50002605151"
replace SchLevel = "Middle" if NCESSchoolID == "50002605151"
replace SchVirtual = "No" if NCESSchoolID == "50002605151"

replace NCESSchoolID = "50042305152" if StateAssignedSchID == "3544705"
replace SchType = "Regular school" if NCESSchoolID == "50042305152"
replace SchLevel = "Middle" if NCESSchoolID == "50042305152"
replace SchVirtual = "No" if NCESSchoolID == "50042305152"

replace NCESSchoolID = "50042305153" if StateAssignedSchID == "3544710"
replace SchType = "Regular school" if NCESSchoolID == "50042305153"
replace SchLevel = "Primary" if NCESSchoolID == "50042305153"
replace SchVirtual = "No" if NCESSchoolID == "50042305153"

replace NCESSchoolID = "50332005155" if StateAssignedSchID == "4702015"
replace SchType = "Regular school" if NCESSchoolID == "50332005155"
replace SchLevel = "Middle" if NCESSchoolID == "50332005155"
replace SchVirtual = "No" if NCESSchoolID == "50332005155"

replace NCESSchoolID = "50004501735" if StateAssignedSchID == "4706702"
replace SchType = "Regular school" if NCESSchoolID == "50004501735"
replace SchLevel = "Middle" if NCESSchoolID == "50004501735"
replace SchVirtual = "No" if NCESSchoolID == "50004501735"

replace NCESSchoolID = "50377000127" if StateAssignedSchID == "4901703"
replace SchType = "Regular school" if NCESSchoolID == "50377000127"
replace SchLevel = "High" if NCESSchoolID == "50377000127"
replace SchVirtual = "No" if NCESSchoolID == "50377000127"

replace NCESSchoolID = "50007405156" if StateAssignedSchID == "6041713"
replace SchType = "Regular school" if NCESSchoolID == "50007405156"
replace SchLevel = "Primary" if NCESSchoolID == "50007405156"
replace SchVirtual = "No" if NCESSchoolID == "50007405156"

replace NCESSchoolID = "50042101656" if StateAssignedSchID == "6060705"
replace SchType = "Regular school" if NCESSchoolID == "50042101656"
replace SchLevel = "Primary" if NCESSchoolID == "50042101656"
replace SchVirtual = "No" if NCESSchoolID == "50042101656"

replace NCESSchoolID = "50296005159" if StateAssignedSchID == "6302013"
replace SchType = "Regular school" if NCESSchoolID == "50296005159"
replace SchLevel = "Primary" if NCESSchoolID == "50296005159"
replace SchVirtual = "No" if NCESSchoolID == "50296005159"

replace NCESSchoolID = "50007605160" if StateAssignedSchID == "6505018"
replace SchType = "Regular school" if NCESSchoolID == "50007605160"
replace SchLevel = "Primary" if NCESSchoolID == "50007605160"
replace SchVirtual = "No" if NCESSchoolID == "50007605160"

replace NCESSchoolID = "50007605161" if StateAssignedSchID == "6505019"
replace SchType = "Regular school" if NCESSchoolID == "50007605161"
replace SchLevel = "Primary" if NCESSchoolID == "50007605161"
replace SchVirtual = "No" if NCESSchoolID == "50007605161"

replace NCESSchoolID = "50007605162" if StateAssignedSchID == "6505020"
replace SchType = "Regular school" if NCESSchoolID == "50007605162"
replace SchLevel = "Primary" if NCESSchoolID == "50007605162"
replace SchVirtual = "No" if NCESSchoolID == "50007605162"

replace NCESSchoolID = "50007605163" if StateAssignedSchID == "6505021"
replace SchType = "Regular school" if NCESSchoolID == "50007605163"
replace SchLevel = "High" if NCESSchoolID == "50007605163"
replace SchVirtual = "No" if NCESSchoolID == "50007605163"

replace NCESSchoolID = "50633005147" if StateAssignedSchID == "6601703"
replace SchType = "Regular school" if NCESSchoolID == "50633005147"
replace SchLevel = "Other" if NCESSchoolID == "50633005147"
replace SchVirtual = "No" if NCESSchoolID == "50633005147"

replace NCESSchoolID = "50612005165" if StateAssignedSchID == "7203030"
replace SchType = "Regular school" if NCESSchoolID == "50612005165"
replace SchLevel = "Middle" if NCESSchoolID == "50612005165"
replace SchVirtual = "No" if NCESSchoolID == "50612005165"

replace NCESSchoolID = "50007805166" if StateAssignedSchID == "7240715"
replace SchType = "Regular school" if NCESSchoolID == "50007805166"
replace SchLevel = "High" if NCESSchoolID == "50007805166"
replace SchVirtual = "No" if NCESSchoolID == "50007805166"

replace NCESSchoolID = "50489005167" if StateAssignedSchID == "7503008"
replace SchType = "Regular school" if NCESSchoolID == "50489005167"
replace SchLevel = "Middle" if NCESSchoolID == "50489005167"
replace SchVirtual = "No" if NCESSchoolID == "50489005167"

//Missing DistName for some obs (??)
replace DistName = "ARKANSAS CONNECTIONS ACADEMY" if NCESDistrictID == "0500417"
replace DistName = "JACKSONVILLE NORTH PULASKI SCHOOL DISTRICT" if NCESDistrictID == "0500419"

replace DistName = strproper(DistName)

//StudentGroup_TotalTested
replace StateAssignedDistID = "00000" if DataLevel == 1
replace StateAssignedSchID = "00000" if DataLevel != 3
egen uniquegrp = group(DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup
by uniquegrp: replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
by uniquegrp: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
replace StudentGroup_TotalTested = "--" if missing(StudentGroup_TotalTested)
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/AR_AssmtData_2024", replace
