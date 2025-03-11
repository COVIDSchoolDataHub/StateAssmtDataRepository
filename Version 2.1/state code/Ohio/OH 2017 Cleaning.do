* OHIO

* File name: OH 2017 Cleaning
* Last update: 03/10/2025

*******************************************************
* Notes

	* This do file uses 2017 OH data. 
	* Variables are renamed and the file is cleaned.
	* A breakpoint is created before any derivations and NCES Merging. 
	* NCES 2016 is used. 
	* The usual and non-derivation output are created. 

*******************************************************
clear

use "$Original_DTA/OH_OriginalData_2017.dta", clear

rename school_year SchYear
tostring SchYear, replace
replace SchYear = "2016-17" if SchYear == "2017"

rename group StudentGroup
replace StudentGroup = "All Students" if StudentGroup == "1-ALL"
replace StudentGroup = "RaceEth" if StudentGroup == "2-RAC"
replace StudentGroup = "EL Status" if StudentGroup == "3-EL"
replace StudentGroup = "Economic Status" if StudentGroup == "4-ED"
replace StudentGroup = "Gender" if StudentGroup == "5-SEX"
replace StudentGroup = "Disability Status" if StudentGroup == "6-DIS"

rename subgrp StudentSubGroup
replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL"
replace StudentSubGroup = "Asian" if StudentSubGroup == "ASN"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "BLK"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "HSP"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "MLT"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "NAT"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "PAC"
replace StudentSubGroup = "White" if StudentSubGroup == "WHT"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "NEL"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ED"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NED"
replace StudentSubGroup = "Female" if StudentSubGroup == "FEM"
replace StudentSubGroup = "Male" if StudentSubGroup == "MAL"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "N"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Y"

rename subjct Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "M"
replace Subject = "sci" if Subject == "S"
replace Subject = "soc" if Subject == "C"

rename grdlev GradeLevel
drop if GradeLevel == "HS"
replace GradeLevel = "G" + GradeLevel

rename lea_irn StateAssignedDistID
rename lea_name DistName
rename org_irn StateAssignedSchID
rename org_name SchName

replace DistName = "All Districts" if DataLevel == "State"
replace SchName = "All Schools" if DataLevel != "School"

//Formatting & Deriving Proficiency Information
rename tested StudentSubGroup_TotalTested
rename prfrate ProficientOrAbove_percent
rename limtd_ct Lev1_count
rename basic_ct Lev2_count
rename prfcnt_ct Lev3_count
rename accomp_ct Lev4_count
rename advncd_ct Lev5_count

forvalues n = 1/5{
	replace Lev`n'_count = "*" if Lev`n'_count == "Z"
	destring Lev`n'_count, gen(Lev`n') force
	gen Lev`n'_percent = Lev`n'/StudentSubGroup_TotalTested
}

replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen ProficientOrAbove_count = Lev3 + Lev4 + Lev5

*******************************************************
// Creating a Breakpoint - to restore for non-derivation data processing
*******************************************************
save "$Temp/OH_2017_Breakpoint",replace

//Derivations [328,953 changes!]
replace ProficientOrAbove_count = round(ProficientOrAbove_percent * StudentSubGroup_TotalTested) if ProficientOrAbove_count == . & ProficientOrAbove_percent != . & StudentSubGroup_TotalTested != .

replace Lev1 = StudentSubGroup_TotalTested - ProficientOrAbove_count - Lev2 if Lev1 == . & ProficientOrAbove_count != . & Lev2 != . & StudentSubGroup_TotalTested != .
replace Lev2 = StudentSubGroup_TotalTested - ProficientOrAbove_count - Lev1 if Lev2 == . & ProficientOrAbove_count != . & Lev1 != . & StudentSubGroup_TotalTested != .
replace Lev3 = ProficientOrAbove_count - Lev4 - Lev5 if Lev3 == . & ProficientOrAbove_count != . & Lev4 != . & Lev5 != .
replace Lev4 = ProficientOrAbove_count - Lev3 - Lev5 if Lev4 == . & ProficientOrAbove_count != . & Lev3 != . & Lev5 != .
replace Lev5 = ProficientOrAbove_count - Lev3 - Lev4 if Lev5 == . & ProficientOrAbove_count != . & Lev3 != . & Lev4 != .

forvalues n = 1/5{
	replace Lev`n'_count = string(Lev`n') if Lev`n'_count == "*" & Lev`n' != .
	replace Lev`n'_percent = Lev`n'/StudentSubGroup_TotalTested if Lev`n'_percent == . & Lev`n' != . & StudentSubGroup_TotalTested != .
	tostring Lev`n'_percent, replace format("%9.4f") force
	replace Lev`n'_percent = "*" if Lev`n'_count == "*"
}

tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
replace ProficientOrAbove_count = string(StudentSubGroup_TotalTested - Lev1 - Lev2) if ProficientOrAbove_count == "*" & Lev1_count != "*" & Lev2_count != "*"
tostring ProficientOrAbove_percent, replace format("%9.4f") force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

replace ProficientOrAbove_count = "." if Lev3_count == "*"
replace ProficientOrAbove_count = "." if Lev4_count == "*"
replace ProficientOrAbove_count = "." if Lev5_count == "*"

gen ParticipationRate = StudentSubGroup_TotalTested/req_testers
tostring ParticipationRate, replace format("%9.4f") force
replace ParticipationRate = "*" if ParticipationRate == "."
replace ParticipationRate = "0" if StudentSubGroup_TotalTested == 0 & req_testers == 0
drop if StudentSubGroup_TotalTested == 0 & StudentSubGroup != "All Students"

//Other Variables
gen AssmtName = "Ohio's State Tests (OST)"
gen AssmtType = "Regular"
gen ProficiencyCriteria= "Levels 3-5"
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "N"  
gen Flag_CutScoreChange_math = "N"  
gen Flag_CutScoreChange_sci = "N"  
gen Flag_CutScoreChange_soc = "N"  
gen AvgScaleScore = "--"  

save "$Temp/OH_AssmtData_2017.dta", replace

* Cleaning NCES Data
use "${NCES_District}/NCES_2016_District.dta", clear
drop if state_location != "OH"
gen str StateAssignedDistID = substr(state_leaid, 4, 9)
destring StateAssignedDistID, replace
save "$NCES_OH/NCES_2016_District_OH.dta", replace

use "${NCES_School}/NCES_2016_School.dta", clear
drop if state_location != "OH"
gen str leaid = substr(state_leaid, 4, 9)
destring leaid, replace
gen str StateAssignedSchID = substr(seasch, 8, 13)
destring StateAssignedSchID, replace
rename district_agency_type DistType2
rename lea_name DistName2
rename ncesdistrictid ncesdistrictid2
rename county_code county_code2
rename county_name county_name2
rename DistCharter DistCharter2
rename DistLocale DistLocale2
keep leaid StateAssignedSchID DistName2 ncesdistrictid2 ncesschoolid DistType2 DistCharter2 DistLocale2 county_code2 county_name2 SchType SchLevel SchVirtual
save "$NCES_OH/NCES_2016_School_OH.dta", replace

* Merge Data
use "$Temp/OH_AssmtData_2017.dta", clear

merge m:1 StateAssignedDistID using "$NCES_OH/NCES_2016_District_OH.dta"
drop if _merge == 2
drop _merge

merge m:1 StateAssignedSchID using "$NCES_OH/NCES_2016_School_OH.dta"
gen flag = 1 if StateAssignedDistID != leaid & _merge == 3
drop if _merge == 2
drop _merge

replace DistName = DistName2 if flag == 1
replace ncesdistrictid = ncesdistrictid2 if flag == 1
replace county_code = county_code2 if flag == 1
replace county_name = county_name2 if flag == 1
replace DistType = DistType2 if flag == 1
replace DistLocale = DistLocale2 if flag == 1
replace DistCharter = DistCharter2 if flag == 1
replace StateAssignedDistID = leaid if flag == 1
drop leaid ncesdistrictid2 DistName2 county_code2 county_name2 DistType2 DistCharter2 DistLocale2

//Cleaning up from NCES
gen State="Ohio"
rename state_location StateAbbrev
rename state_fips StateFips
rename county_name CountyName
rename county_code CountyCode
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID

replace StateAbbrev = "OH"
replace StateFips = 39

//StateAssigned ID Formatting
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace
forvalues n = 2/5{
	replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == `n'
	replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == `n'
}
replace StateAssignedDistID = "" if DataLevel == "State"
replace StateAssignedSchID = "" if DataLevel != "School"

//Aggregating Values for Schools Listed in Multiple Districts
egen uniquegrp = group(DataLevel StateAssignedDistID StateAssignedSchID AssmtName Subject GradeLevel StudentSubGroup)
gen x = 1
bysort uniquegrp: egen num = total(x)
drop flag

destring ProficientOrAbove_count, gen(Prof) force

foreach var of varlist Prof StudentSubGroup_TotalTested {
	gen flag = 1 if `var' == .
	replace flag = 0 if flag == .
	bysort uniquegrp: egen flag2 = max(flag)
	bysort uniquegrp: egen `var'agg = total(`var')
	replace `var'agg = . if flag2 > 0
	drop flag flag2
}

gen weight = StudentSubGroup_TotalTested/StudentSubGroup_TotalTestedagg
destring ParticipationRate, gen(Part) force
gen Part_weighted = Part * weight
gen flag = 1 if Part_weighted == .
replace flag = 0 if flag == .
bysort uniquegrp: egen flag2 = max(flag)
bysort uniquegrp: egen Partagg = total(Part_weighted)
replace Partagg = . if flag2 > 0
drop flag flag2

replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTestedagg if StudentSubGroup_TotalTestedagg != . & num > 1 & uniquegrp != .
replace ProficientOrAbove_count = string(Profagg) if Profagg != . & num > 1 & uniquegrp != .
replace ProficientOrAbove_count = "*" if Profagg == . & num > 1 & uniquegrp != .
gen Prof_pctagg = Profagg/StudentSubGroup_TotalTestedagg if Profagg != . & StudentSubGroup_TotalTestedagg != . & num > 1 & uniquegrp != .
replace ProficientOrAbove_percent = string(Prof_pctagg, "%9.4f") if Prof_pctagg != . & num > 1 & uniquegrp != .
replace ProficientOrAbove_percent = "*" if Prof_pctagg == . & num > 1 & uniquegrp != .
replace ParticipationRate = string(Partagg, "%9.4f") if Partagg != . & num > 1 & uniquegrp != .
replace ParticipationRate = "*" if Partagg == . & num > 1 & uniquegrp != .

foreach var of varlist Lev*_count Lev*_percent{
	replace `var' = "*" if num > 1 & uniquegrp != .
}

sort uniquegrp
drop if uniquegrp == uniquegrp[_n-1] & num > 1 & uniquegrp != .
drop num uniquegrp

//StudentGroup_TotalTested
replace DistName = stritrim(DistName)
replace DistName = strtrim(DistName)
replace SchName = stritrim(SchName)
replace SchName = strtrim(SchName)
sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
gen StudentGroup_TotalTested = AllStudents_Tested
drop AllStudents_Tested

//Label & Organize Variables
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Cleaning and dropping extra variables
local vars State StateAbbrev StateFips SchYear DataLevel DistName DistType 	///
    SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID 		///
    StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual 			///
    CountyName CountyCode AssmtName AssmtType Subject GradeLevel 			///
    StudentGroup StudentGroup_TotalTested StudentSubGroup 					///
    StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count 			///
    Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent 			///
    Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria 				///
    ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 	///
    Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math 	///
    Flag_CutScoreChange_sci Flag_CutScoreChange_soc
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output for 2017
save "${Output}/OH_AssmtData_2017.dta", replace
export delimited "${Output}/OH_AssmtData_2017.csv", replace

******************************
// Creating the non-derivation output
******************************
*Restoring the breakpoint
use "$Temp/OH_2017_Breakpoint", clear

replace Lev1 = StudentSubGroup_TotalTested - ProficientOrAbove_count - Lev2 if Lev1 == . & ProficientOrAbove_count != . & Lev2 != . & StudentSubGroup_TotalTested != .
replace Lev2 = StudentSubGroup_TotalTested - ProficientOrAbove_count - Lev1 if Lev2 == . & ProficientOrAbove_count != . & Lev1 != . & StudentSubGroup_TotalTested != .
replace Lev3 = ProficientOrAbove_count - Lev4 - Lev5 if Lev3 == . & ProficientOrAbove_count != . & Lev4 != . & Lev5 != .
replace Lev4 = ProficientOrAbove_count - Lev3 - Lev5 if Lev4 == . & ProficientOrAbove_count != . & Lev3 != . & Lev5 != .
replace Lev5 = ProficientOrAbove_count - Lev3 - Lev4 if Lev5 == . & ProficientOrAbove_count != . & Lev3 != . & Lev4 != .

forvalues n = 1/5{
	replace Lev`n'_count = string(Lev`n') if Lev`n'_count == "*" & Lev`n' != .
	replace Lev`n'_percent = Lev`n'/StudentSubGroup_TotalTested if Lev`n'_percent == . & Lev`n' != . & StudentSubGroup_TotalTested != .
	tostring Lev`n'_percent, replace format("%9.4f") force
	replace Lev`n'_percent = "*" if Lev`n'_count == "*"
}

tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
replace ProficientOrAbove_count = string(StudentSubGroup_TotalTested - Lev1 - Lev2) if ProficientOrAbove_count == "*" & Lev1_count != "*" & Lev2_count != "*"
tostring ProficientOrAbove_percent, replace format("%9.4f") force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

replace ProficientOrAbove_count = "." if Lev3_count == "*"
replace ProficientOrAbove_count = "." if Lev4_count == "*"
replace ProficientOrAbove_count = "." if Lev5_count == "*"

gen ParticipationRate = StudentSubGroup_TotalTested/req_testers
tostring ParticipationRate, replace format("%9.4f") force
replace ParticipationRate = "*" if ParticipationRate == "."
replace ParticipationRate = "0" if StudentSubGroup_TotalTested == 0 & req_testers == 0
drop if StudentSubGroup_TotalTested == 0 & StudentSubGroup != "All Students"

//Other Variables
gen AssmtName = "Ohio's State Tests (OST)"
gen AssmtType = "Regular"
gen ProficiencyCriteria= "Levels 3-5"
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "N"  
gen Flag_CutScoreChange_math = "N"  
gen Flag_CutScoreChange_sci = "N"  
gen Flag_CutScoreChange_soc = "N"  
gen AvgScaleScore = "--"  

merge m:1 StateAssignedDistID using "$NCES_OH/NCES_2016_District_OH.dta"
drop if _merge == 2
drop _merge

merge m:1 StateAssignedSchID using "$NCES_OH/NCES_2016_School_OH.dta"
gen flag = 1 if StateAssignedDistID != leaid & _merge == 3
drop if _merge == 2
drop _merge

replace DistName = DistName2 if flag == 1
replace ncesdistrictid = ncesdistrictid2 if flag == 1
replace county_code = county_code2 if flag == 1
replace county_name = county_name2 if flag == 1
replace DistType = DistType2 if flag == 1
replace DistLocale = DistLocale2 if flag == 1
replace DistCharter = DistCharter2 if flag == 1
replace StateAssignedDistID = leaid if flag == 1
drop leaid ncesdistrictid2 DistName2 county_code2 county_name2 DistType2 DistCharter2 DistLocale2

//Cleaning up from NCES
gen State="Ohio"
rename state_location StateAbbrev
rename state_fips StateFips
rename county_name CountyName
rename county_code CountyCode
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID

replace StateAbbrev = "OH"
replace StateFips = 39

//StateAssigned ID Formatting
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace
forvalues n = 2/5{
	replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == `n'
	replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == `n'
}
replace StateAssignedDistID = "" if DataLevel == "State"
replace StateAssignedSchID = "" if DataLevel != "School"

//Aggregating Values for Schools Listed in Multiple Districts
egen uniquegrp = group(DataLevel StateAssignedDistID StateAssignedSchID AssmtName Subject GradeLevel StudentSubGroup)
gen x = 1
bysort uniquegrp: egen num = total(x)
drop flag

destring ProficientOrAbove_count, gen(Prof) force

foreach var of varlist Prof StudentSubGroup_TotalTested {
	gen flag = 1 if `var' == .
	replace flag = 0 if flag == .
	bysort uniquegrp: egen flag2 = max(flag)
	bysort uniquegrp: egen `var'agg = total(`var')
	replace `var'agg = . if flag2 > 0
	drop flag flag2
}

gen weight = StudentSubGroup_TotalTested/StudentSubGroup_TotalTestedagg
destring ParticipationRate, gen(Part) force
gen Part_weighted = Part * weight
gen flag = 1 if Part_weighted == .
replace flag = 0 if flag == .
bysort uniquegrp: egen flag2 = max(flag)
bysort uniquegrp: egen Partagg = total(Part_weighted)
replace Partagg = . if flag2 > 0
drop flag flag2

replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTestedagg if StudentSubGroup_TotalTestedagg != . & num > 1 & uniquegrp != .
replace ProficientOrAbove_count = string(Profagg) if Profagg != . & num > 1 & uniquegrp != .
replace ProficientOrAbove_count = "*" if Profagg == . & num > 1 & uniquegrp != .
gen Prof_pctagg = Profagg/StudentSubGroup_TotalTestedagg if Profagg != . & StudentSubGroup_TotalTestedagg != . & num > 1 & uniquegrp != .
replace ProficientOrAbove_percent = string(Prof_pctagg, "%9.4f") if Prof_pctagg != . & num > 1 & uniquegrp != .
replace ProficientOrAbove_percent = "*" if Prof_pctagg == . & num > 1 & uniquegrp != .
replace ParticipationRate = string(Partagg, "%9.4f") if Partagg != . & num > 1 & uniquegrp != .
replace ParticipationRate = "*" if Partagg == . & num > 1 & uniquegrp != .

foreach var of varlist Lev*_count Lev*_percent{
	replace `var' = "*" if num > 1 & uniquegrp != .
}

sort uniquegrp
drop if uniquegrp == uniquegrp[_n-1] & num > 1 & uniquegrp != .
drop num uniquegrp

//StudentGroup_TotalTested
replace DistName = stritrim(DistName)
replace DistName = strtrim(DistName)
replace SchName = stritrim(SchName)
replace SchName = strtrim(SchName)
sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
gen StudentGroup_TotalTested = AllStudents_Tested
drop AllStudents_Tested

//Label & Organize Variables
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Non-Derivation Output.
save "${Output_ND}/OH_AssmtData_2017_ND", replace
export delimited "${Output_ND}/OH_AssmtData_2017_ND", replace
*End of OH 2017 Cleaning.do
****************************************************
