clear
set more off

cd "/Users/miramehta/Documents"

global raw "/Users/miramehta/Documents/OH State Testing Data/Original Data"
global output "/Users/miramehta/Documents/OH State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/"
global NCES_clean "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

use "$raw/OH_OriginalData_2016.dta", clear

rename school_year SchYear
tostring SchYear, replace
replace SchYear = "2015-16" if SchYear == "2016"

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
	tostring Lev`n'_percent, replace format("%9.4f") force
	replace Lev`n'_percent = "*" if Lev`n'_count == "*"
}

gen ProficientOrAbove_count = Lev3 + Lev4 + Lev5
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "*" if Lev3_count == "*"
replace ProficientOrAbove_count = "*" if Lev4_count == "*"
replace ProficientOrAbove_count = "*" if Lev5_count == "*"
replace ProficientOrAbove_count = string(StudentSubGroup_TotalTested - Lev1 - Lev2) if ProficientOrAbove_count == "*" & Lev1_count != "*" & Lev2_count != "*"
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace format("%9.4f") force

gen ParticipationRate = StudentSubGroup_TotalTested/req_testers
tostring ParticipationRate, replace format("%9.4f") force
replace ParticipationRate = "*" if ParticipationRate == "."
drop if StudentSubGroup_TotalTested == 0 & StudentSubGroup != "All Students"

//StudentGroup_TotalTested
replace DistName = stritrim(DistName)
replace DistName = strtrim(DistName)
replace SchName = stritrim(SchName)
replace SchName = strtrim(SchName)
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
gen StudentGroup_TotalTested = AllStudents_Tested
drop AllStudents_Tested
	
//Other Variables
gen AssmtName = "Ohio's State Tests (OST)"
gen AssmtType = "Regular"
gen ProficiencyCriteria= "Levels 3-5"
gen Flag_AssmtNameChange = "N" 
gen Flag_CutScoreChange_ELA = "Y"  
gen Flag_CutScoreChange_math = "Y"  
gen Flag_CutScoreChange_sci = "N"  
gen Flag_CutScoreChange_soc = "N"
gen AvgScaleScore = "--"

save "$output/OH_AssmtData_2016.dta", replace

* Cleaning NCES Data
use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_2015_District.dta", clear
drop if state_location != "OH"
gen str StateAssignedDistID = state_leaid
destring StateAssignedDistID, replace
save "$NCES_clean/NCES_2015_District_OH.dta", replace

use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_2015_School.dta", clear
drop if state_location != "OH"
gen str leaid = state_leaid
destring leaid, replace
gen str StateAssignedSchID = seasch
destring StateAssignedSchID, replace
rename district_agency_type DistType2
rename lea_name DistName2
rename ncesdistrictid ncesdistrictid2
rename county_code county_code2
rename county_name county_name2
rename DistCharter DistCharter2
rename DistLocale DistLocale2
keep leaid StateAssignedSchID DistName2 ncesdistrictid2 ncesschoolid DistType2 DistCharter2 DistLocale2 county_code2 county_name2 SchType SchLevel SchVirtual
save "$NCES_clean/NCES_2015_School_OH.dta", replace

* Merge Data
use "$output/OH_AssmtData_2016.dta", clear

merge m:1 StateAssignedDistID using "$NCES_clean/NCES_2015_District_OH.dta"
drop if _merge == 2
drop _merge

merge m:1 StateAssignedSchID using "$NCES_clean/NCES_2016_School_OH.dta"
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

tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace
replace StateAssignedDistID = "" if DataLevel == "State"
replace StateAssignedSchID = "" if DataLevel != "School"

//Label & Organize Variables
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/OH_AssmtData_2016.dta", replace

export delimited "${output}/OH_AssmtData_2016.csv", replace
