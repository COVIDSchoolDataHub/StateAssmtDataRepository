****************************************************************
** Yearly cleaning, 2015+
****************************************************************
clear
set more off

global raw "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\Raw"
global temp "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\temp"
global NCESDistrict "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\NCES District Files, Fall 1997-Fall 2022"
global NCESSchool "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\NCES School Files, Fall 1997-Fall 2022"
global EDFacts "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\EdFacts"
global output "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\Output"

****************************************************************
** 2015 
****************************************************************

import excel "${raw}/KS_OriginalData_2015_all.xlsx", sheet("2015") firstrow clear

** Renaming variables

rename OrganizationLevel SchName
rename PctLevelOne Lev1_percent
rename PctLevelTwo Lev2_percent
rename PctLevelThree Lev3_percent
rename PctLevelFour Lev4_percent
rename GroupName StudentSubGroup
rename Grade GradeLevel
rename BldgNo StateAssignedSchID
rename OrgNo StateAssignedDistID
rename SchoolYear SchYear

** Dropping entries

drop if inlist(GradeLevel, 10, 13)
drop if inlist(StudentSubGroup, "Free Lunch only", "Reduced Lunch only")

** Replacing/generating variables

tostring SchYear, replace
replace SchYear = "2014-15"

replace Subject = strlower(Subject)

tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

replace StateAssignedDistID = strtrim(StateAssignedDistID)
replace StateAssignedSchID = strtrim(StateAssignedSchID)
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "0"
replace DataLevel = "State" if StateAssignedDistID == "0"

replace SchName = stritrim(SchName)
split SchName, parse ("-")
replace SchName = subinstr(SchName, SchName1, "", 1) if DataLevel == "School"
replace SchName = subinstr(SchName, "- ", "", 1) if DataLevel == "School"
drop SchName1 SchName2 SchName3 SchName4

gen DistName = SchName
sort StateAssignedDistID StateAssignedSchID
replace DistName = DistName[_n-1] if DataLevel == "School"
split DistName, parse ("-")
replace DistName = subinstr(DistName, DistName1, "", 1) if DataLevel != "State"
replace DistName = subinstr(DistName, "- ", "", 1) if DataLevel != "State"
drop DistName1 DistName2 DistName3 DistName4

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

	// Cleaning up DistNames & SchNames
	replace DistName =strtrim(DistName) 
	replace DistName =stritrim(DistName) 
	replace SchName =strtrim(SchName) 
	replace SchName =stritrim(SchName) 

replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

replace StudentSubGroup = strtrim(StudentSubGroup)
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African-American Students"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learner Students"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free and Reduced Lunch"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-Racial"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Self-Paid Lunch only"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with  Disabilities"
gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"

gen StudentSubGroup_TotalTested = "--"

replace PctNotValid = PctNotValid/100


//Kansas includes the pctnotvalid percent as one of the "levels". We want to remove this and re-scale the level percents so that they only include the valid tests. The website indicates that "PctNotValid" is the % not tested (https://ksreportcard.ksde.org/assessment_results.aspx?org_no=State&rptType=3)

local level 1 2 3 4
foreach a of local level {
	replace Lev`a'_percent = Lev`a'_percent/100
	replace Lev`a'_percent = Lev`a'_percent/(1-PctNotValid)
	gen Lev`a'_count = "--"
}


gen Lev5_count = ""
gen Lev5_percent = ""

gen AssmtName = "KAP"
gen AssmtType = "Regular"

gen AvgScaleScore = "--"

gen ParticipationRate = 1 - PctNotValid

tostring ParticipationRate, replace format("%9.4g") force
replace ParticipationRate = "--" if inlist(ParticipationRate, "", ".")
drop PctNotValid

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--"
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent

tostring ProficientOrAbove_percent, replace format("%9.4f") force // new
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""


** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order SchYear DataLevel DistName SchName StateAssignedDistID StateAssignedSchID AssmtName AssmtType Subject GradeLevel Lev1_count Lev2_count Lev1_percent Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent StudentGroup StudentSubGroup StudentSubGroup_TotalTested  ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent  AvgScaleScore ParticipationRate 

// save to temp
save "${temp}/kansas_2015_temp1.dta", replace


*********************************************
** Merging with NCES

use "${temp}/kansas_2015_temp1.dta"
gen State_leaid = StateAssignedDistID

merge m:1 State_leaid using "${NCESDistrict}/NCES_2014_District_KS.dta"

drop if _merge == 1 & DataLevel != 1
drop if _merge == 2
drop _merge

gen seasch = StateAssignedSchID
merge m:1 seasch using "${NCESSchool}/NCES_2014_School_KS.dta"

drop if _merge == 2
drop _merge

replace StateAbbrev = "KS" if DataLevel == 1
replace State = "Kansas" if DataLevel == 1
replace StateFips = 20 if DataLevel == 1
replace CountyName = strproper(CountyName)
replace CountyName = "McPherson County" if CountyName == "Mcpherson County"

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup  StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode


// save to temp
save "${temp}/kansas_2015_temp2.dta", replace
export delimited "${temp}/kansas_2015_temp2.csv", replace


****************************************************************
** 2016
****************************************************************

import excel "${raw}/KS_OriginalData_2016_all.xlsx", sheet("AssessmentResults") firstrow clear

** Renaming variables

rename Organization SchName
rename PCLevel_One Lev1_percent
rename PCLevel_Two Lev2_percent
rename PCLevel_Three Lev3_percent
rename PCLevel_Four Lev4_percent
rename GroupName StudentSubGroup
rename GradeName GradeLevel
rename Building_Number StateAssignedSchID
rename Org_No StateAssignedDistID
rename program_year SchYear

** Dropping entries

// Entries with a Population value of Report Card were retained bc later years (e.g. 2018) report the Report Card level percents.
drop if Population == "Accountability"
drop Population

drop if inlist(GradeLevel, "10", "ALL")

drop if SchYear == "2015"

drop if StateAssignedSchID == "District Aggregate" & SchName == "State of Kansas"

drop if StudentSubGroup == "ELL with Disabilities"
drop if StudentSubGroup == "Free Lunch only"
drop if StudentSubGroup == "Reduced Lunch only"
drop if StudentSubGroup == "With Disability"

** Replacing/generating variables

replace SchYear = "2015-16"

replace Subject = strlower(Subject)

replace GradeLevel = "G0" + GradeLevel

gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "District Aggregate"
replace DataLevel = "State" if StateAssignedSchID == "State Aggregate"

replace SchName = stritrim(SchName)
split SchName, parse ("-")
replace SchName = subinstr(SchName, SchName1, "", 1) if DataLevel == "School"
replace SchName = subinstr(SchName, "- ", "", 1) if DataLevel == "School"
drop SchName1 SchName2 SchName3 SchName4

gen DistName = SchName
sort StateAssignedDistID DataLevel
replace DistName = DistName[_n-1] if DataLevel == "School"
split DistName, parse ("-")
replace DistName = subinstr(DistName, DistName1, "", 1) if DataLevel != "State"
replace DistName = subinstr(DistName, "- ", "", 1) if DataLevel != "State"
drop DistName1 DistName2 DistName3 DistName4

	// Cleaning up DistNames & SchNames
	replace DistName =strtrim(DistName) 
	replace DistName =stritrim(DistName) 
	replace SchName =strtrim(SchName) 
	replace SchName =stritrim(SchName) 
	
replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

replace StudentSubGroup = strtrim(StudentSubGroup)
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African-American Students"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ELL Students"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free and Reduced Lunch"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-Racial"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-ELL Students"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Self-Paid Lunch only"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with  Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not Disabled"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"

gen StudentSubGroup_TotalTested = "--"

destring PCNotValid, replace
replace PCNotValid = PCNotValid/100

local level 1 2 3 4
foreach a of local level {
	destring Lev`a'_percent, replace
	replace Lev`a'_percent = Lev`a'_percent/100
	replace Lev`a'_percent = Lev`a'_percent/(1 - PCNotValid)
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen AssmtName = "KAP"
gen AssmtType = "Regular"

gen AvgScaleScore = "--"

gen ParticipationRate = 1 - PCNotValid

tostring ParticipationRate, replace format("%9.4g") force
replace ParticipationRate = "--" if inlist(ParticipationRate, "", ".")
drop PCNotValid

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--"
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
tostring ProficientOrAbove_percent, replace format("%9.4f") force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order SchYear DataLevel DistName SchName StateAssignedDistID StateAssignedSchID AssmtName AssmtType Subject GradeLevel Lev1_count Lev2_count Lev1_percent Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent StudentGroup StudentSubGroup StudentSubGroup_TotalTested  ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent  AvgScaleScore ParticipationRate 

// save to temp
save "${temp}/kansas_2016_temp1.dta", replace


*********************************************
** Merging with NCES
use "${temp}/kansas_2016_temp1.dta"
gen State_leaid = StateAssignedDistID

merge m:1 State_leaid using "${NCESDistrict}/NCES_2015_District_KS.dta"

drop if _merge == 1 & DataLevel != 1
drop if _merge == 2
drop _merge

gen seasch = StateAssignedSchID

merge m:1 seasch using "${NCESSchool}/NCES_2015_School_KS.dta"

drop if _merge == 2
drop _merge

replace StateAbbrev = "KS" if DataLevel == 1
replace State = "Kansas" if DataLevel == 1
replace StateFips = 20 if DataLevel == 1


order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup  StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate  DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode


// save to temp
save "${temp}/kansas_2016_temp2.dta", replace
export delimited "${temp}/kansas_2016_temp2.csv", replace


****************************************************************
** 2017
****************************************************************

import excel "${raw}/KS_OriginalData_2017_all.xlsx", sheet("2017") firstrow clear

** Renaming variables

rename orglevel SchName
rename PCLevel_One Lev1_percent
rename PCLevel_Two Lev2_percent
rename PCLevel_Three Lev3_percent
rename PCLevel_Four Lev4_percent
rename GroupName StudentSubGroup
rename Grade GradeLevel
rename bldgno StateAssignedSchID
rename orgno StateAssignedDistID
rename program_year SchYear

** Dropping entries

// Entries with a Population value of Report Card were retained bc later years (e.g. 2018) report the Report Card level percents.
drop if Population == "Accountability"
drop Population

drop if inlist(GradeLevel, 10, 13)

sort StateAssignedDistID StateAssignedSchID

drop if inlist(StudentSubGroup, "ELL with Disabilities", "Free Lunch only", "Reduced Lunch only", "With Disability")

** Replacing/generating variables

tostring SchYear, replace
replace SchYear = "2016-17"

replace Subject = strlower(Subject)

tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == 0
replace DataLevel = "State" if StateAssignedDistID == "0"

replace SchName = stritrim(SchName)

gen DistName = SchName
sort StateAssignedDistID DataLevel
replace DistName = DistName[_n-1] if DataLevel == "School"
split DistName, parse ("-")
replace DistName = subinstr(DistName, DistName1, "", 1) if DataLevel != "State"
replace DistName = subinstr(DistName, "- ", "", 1) if DataLevel != "State"
drop DistName1 DistName2 DistName3 DistName4

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

	// Cleaning up DistNames & SchNames
	replace DistName =strtrim(DistName) 
	replace DistName =stritrim(DistName) 
	replace SchName =strtrim(SchName) 
	replace SchName =stritrim(SchName) 
	
tostring StateAssignedSchID, replace
replace StateAssignedSchID = substr(SchName, 1, 4)
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

split SchName, parse ("-")
replace SchName = subinstr(SchName, SchName1, "", 1) if DataLevel == "School"
replace SchName = subinstr(SchName, "- ", "", 1) if DataLevel == "School"
drop SchName1 SchName2 SchName3 SchName4

replace StudentSubGroup = strtrim(StudentSubGroup)
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African-American Students"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ELL Students"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free and Reduced Lunch"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-Racial"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-ELL Students"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Self-Paid Lunch only"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with  Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not Disabled"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"

gen StudentSubGroup_TotalTested = "--"

destring PCNotValid, replace
replace PCNotValid = PCNotValid/100

local level 1 2 3 4
foreach a of local level {
	destring Lev`a'_percent, replace
	replace Lev`a'_percent = Lev`a'_percent/100
	replace Lev`a'_percent = Lev`a'_percent/(1-PCNotValid)
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen AssmtName = "KAP"
gen AssmtType = "Regular"

gen AvgScaleScore = "--"

gen ParticipationRate = 1 - PCNotValid
tostring ParticipationRate, replace format("%9.4g") force
replace ParticipationRate = "--" if inlist(ParticipationRate, "", ".")
drop PCNotValid

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--"
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
tostring ProficientOrAbove_percent, replace format("%9.4f") force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order SchYear DataLevel DistName SchName StateAssignedDistID StateAssignedSchID AssmtName AssmtType Subject GradeLevel Lev1_count Lev2_count Lev1_percent Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent StudentGroup StudentSubGroup StudentSubGroup_TotalTested  ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent  AvgScaleScore ParticipationRate 

// save to temp
save "${temp}/kansas_2017_temp1.dta", replace


*********************************************
** Merging with NCES
use "${temp}/kansas_2017_temp1.dta"

gen State_leaid = "KS-" + StateAssignedDistID
replace State_leaid = "" if DataLevel == 1

merge m:1 State_leaid using "${NCESDistrict}/NCES_2016_District_KS.dta"

drop if _merge == 1 & DataLevel != 1
drop if _merge == 2
drop _merge

gen seasch = StateAssignedDistID + "-" + StateAssignedSchID
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCESSchool}/NCES_2016_School_KS.dta"

drop if _merge == 2
drop _merge

replace StateAbbrev = "KS" if DataLevel == 1
replace State = "Kansas" if DataLevel == 1
replace StateFips = 20 if DataLevel == 1



order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup  StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate  DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode


// save to temp
save "${temp}/kansas_2017_temp2.dta", replace
export delimited "${temp}/kansas_2017_temp2.csv", replace


****************************************************************
** 2018
****************************************************************

import excel "${raw}/KS_OriginalData_2018_all.xlsx", sheet("2018") firstrow clear

** Renaming variables
rename orglevel SchName
rename PCLevel_One Lev1_percent
rename PCLevel_Two Lev2_percent
rename PCLevel_Three Lev3_percent
rename PCLevel_Four Lev4_percent
rename GroupName StudentSubGroup
rename Grade GradeLevel
rename bldgno StateAssignedSchID
rename orgno StateAssignedDistID
rename program_year SchYear

** Dropping entries

drop PCNotValid // these all have a value of 0 

drop if inlist(GradeLevel, 10, 13)

drop if inlist(StudentSubGroup, "Building Mobile students", "District Mobile Student", "Free Lunch only", "Gifted only", "Reduced Lunch only", "Regular Ed. only", "ELL with Disabilities", "With Disability")

** Replacing/generating variables

tostring SchYear, replace
replace SchYear = "2017-18"

replace Subject = strlower(Subject)

tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

gen DataLevel = "School"
replace StateAssignedDistID = strtrim(StateAssignedDistID)
replace StateAssignedSchID = strtrim(StateAssignedSchID)
replace DataLevel = "District" if StateAssignedSchID == "0"
replace DataLevel = "State" if StateAssignedDistID == "0"

replace SchName = stritrim(SchName)
split SchName, parse ("-")
replace SchName = subinstr(SchName, SchName1, "", 1) if DataLevel == "School"
replace SchName = subinstr(SchName, "- ", "", 1) if DataLevel == "School"
drop SchName1 SchName2 SchName3 SchName4

gen DistName = SchName
sort StateAssignedDistID DataLevel
replace DistName = DistName[_n-1] if DataLevel == "School"
split DistName, parse ("-")
replace DistName = subinstr(DistName, DistName1, "", 1) if DataLevel != "State"
replace DistName = subinstr(DistName, "- ", "", 1) if DataLevel != "State"
drop DistName1 DistName2 DistName3 DistName4

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

	// Cleaning up DistNames & SchNames
	replace DistName =strtrim(DistName) 
	replace DistName =stritrim(DistName) 
	replace SchName =strtrim(SchName) 
	replace SchName =stritrim(SchName) 
	
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

replace StudentSubGroup = strtrim(StudentSubGroup)
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African-American Students"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ELL Students"
replace StudentSubGroup = "Female" if StudentSubGroup == "Females"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free and Reduced Lunch"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Male" if StudentSubGroup == "Males"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-Racial"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-ELL Students"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Self-Paid Lunch only"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with  Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not Disabled"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"

gen StudentSubGroup_TotalTested = "--"

local level 1 2 3 4
foreach a of local level {
	replace Lev`a'_percent = Lev`a'_percent/100
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen AssmtName = "KAP"
gen AssmtType = "Regular"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--"
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
tostring ProficientOrAbove_percent, replace format("%9.4g") force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order SchYear DataLevel DistName SchName StateAssignedDistID StateAssignedSchID AssmtName AssmtType Subject GradeLevel Lev1_count Lev2_count Lev1_percent Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent StudentGroup StudentSubGroup StudentSubGroup_TotalTested  ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent  AvgScaleScore ParticipationRate 

// save to temp
save "${temp}/kansas_2018_temp1.dta", replace


*********************************************
** Merging with NCES
use "${temp}/kansas_2018_temp1.dta"

gen State_leaid = "KS-" + StateAssignedDistID
replace State_leaid = "" if DataLevel == 1

merge m:1 State_leaid using "${NCESDistrict}/NCES_2018_District_KS.dta"

drop if _merge == 1 & DataLevel != 1
drop if _merge == 2
drop _merge

gen seasch = StateAssignedDistID + "-" + StateAssignedSchID
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCESSchool}/NCES_2018_School_KS.dta"

drop if _merge == 2
drop _merge

replace StateAbbrev = "KS" if DataLevel == 1
replace State = "Kansas" if DataLevel == 1
replace StateFips = 20 if DataLevel == 1


order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup  StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate  DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode


// save to temp
save "${temp}/kansas_2018_temp2.dta", replace
export delimited "${temp}/kansas_2018_temp2.csv", replace


****************************************************************
** 2019
****************************************************************

import excel "${raw}/KS_OriginalData_2019_all.xlsx", sheet("2019") firstrow clear

** Renaming variables

rename OrganizationBuildingStateName SchName
rename PctLevel1 Lev1_percent
rename PctLevel2 Lev2_percent
rename PctLevel3 Lev3_percent
rename PctLevel4 Lev4_percent
rename Group StudentSubGroup
rename Grade GradeLevel
rename BldgNo StateAssignedSchID
rename OrgNo StateAssignedDistID
rename SchoolYear SchYear

** Dropping entries

drop PctNotValid // all values are 0

drop if inlist(GradeLevel, 10, 11, 13)

drop if inlist(StudentSubGroup, "Building Mobile students", "District Mobile Student", "Free Lunch only", "Gifted only", "Reduced Lunch only", "Regular Ed. only", "English Learner with Disabilities", "With Disability")

drop if SchName == "State of Kansas" // these are duplicate obs

** Replacing/generating variables

tostring SchYear, replace
replace SchYear = "2018-19"

replace Subject = strlower(Subject)
replace Subject = "sci" if Subject == "science" // first year with science data

tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == 0
replace DataLevel = "State" if StateAssignedDistID == "0"

tostring StateAssignedSchID, replace
replace StateAssignedSchID = substr(SchName, 1, 4)
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

replace SchName = stritrim(SchName)
split SchName, parse ("-")
replace SchName = subinstr(SchName, SchName1, "", 1) if DataLevel == "School"
replace SchName = subinstr(SchName, "- ", "", 1) if DataLevel == "School"
drop SchName1 SchName2 SchName3 SchName4

gen DistName = SchName
sort StateAssignedDistID DataLevel
replace DistName = DistName[_n-1] if DataLevel == "School"
split DistName, parse ("-")
replace DistName = subinstr(DistName, DistName1, "", 1) if DataLevel != "State"
replace DistName = subinstr(DistName, "- ", "", 1) if DataLevel != "State"
drop DistName1 DistName2 DistName3 DistName4

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

	// Cleaning up DistNames & SchNames
	replace DistName =strtrim(DistName) 
	replace DistName =stritrim(DistName) 
	replace SchName =strtrim(SchName) 
	replace SchName =stritrim(SchName) 
	
replace StudentSubGroup = strtrim(StudentSubGroup)
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African-American Students"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learner Students"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free and Reduced Lunch"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-Racial"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Learner Students"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Self-Paid Lunch only"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with  Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not Disabled"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected Students"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"

gen StudentSubGroup_TotalTested = "--"

local level 1 2 3 4
foreach a of local level {
	replace Lev`a'_percent = Lev`a'_percent/100
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen AssmtName = "KAP"
gen AssmtType = "Regular"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--"
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
tostring ProficientOrAbove_percent, replace format("%9.4g") force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order SchYear DataLevel DistName SchName StateAssignedDistID StateAssignedSchID AssmtName AssmtType Subject GradeLevel Lev1_count Lev2_count Lev1_percent Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent StudentGroup StudentSubGroup StudentSubGroup_TotalTested  ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent  AvgScaleScore ParticipationRate 

// save to temp
save "${temp}/kansas_2019_temp1.dta", replace

*********************************************
** Merging with NCES
use "${temp}/kansas_2019_temp1.dta"

gen State_leaid = "KS-" + StateAssignedDistID
replace State_leaid = "" if DataLevel == 1

merge m:1 State_leaid using "${NCESDistrict}/NCES_2018_District_KS.dta"

drop if _merge == 1 & DataLevel != 1
drop if _merge == 2
drop _merge

gen seasch = StateAssignedDistID + "-" + StateAssignedSchID
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCESSchool}/NCES_2018_School_KS.dta"

drop if _merge == 2
drop _merge

replace StateAbbrev = "KS" if DataLevel == 1
replace State = "Kansas" if DataLevel == 1
replace StateFips = 20 if DataLevel == 1



order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup  StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode


// save to temp
save "${temp}/kansas_2019_temp2.dta", replace
export delimited "${temp}/kansas_2019_temp2.csv", replace


****************************************************************
** 2021
****************************************************************

import excel "${raw}/KS_OriginalData_2021_all.xlsx", sheet("2021") firstrow clear

** Renaming variables

rename OrganizationLevel SchName
rename PctLevelOne Lev1_percent
rename PctLevelTwo Lev2_percent
rename PctLevelThree Lev3_percent
rename PctLevelFour Lev4_percent
rename GroupName StudentSubGroup
rename Grade GradeLevel
rename BldgNo StateAssignedSchID
rename OrgNo StateAssignedDistID
rename SchoolYear SchYear

** Dropping entries

drop PctNotValid // these are all 0 

drop if inlist(GradeLevel, 10, 11, 13)

drop if inlist(StudentSubGroup, "Building Mobile students", "District Mobile Student", "Free Lunch only", "Gifted only", "Reduced Lunch only", "Regular Ed. only", "English Learner with Disabilities", "With Disability")

drop if SchName == "State of Kansas" // these are duplicate obs

** Replacing/generating variables

tostring SchYear, replace
replace SchYear = "2020-21"

replace Subject = strlower(Subject)
replace Subject = "sci" if Subject == "science"

tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

gen DataLevel = "School"
replace StateAssignedSchID = strtrim(StateAssignedSchID)
replace DataLevel = "District" if StateAssignedSchID == "0"
replace DataLevel = "State" if StateAssignedDistID == "0"

replace SchName = stritrim(SchName)
split SchName, parse ("-")
replace SchName = subinstr(SchName, SchName1, "", 1) if DataLevel == "School"
replace SchName = subinstr(SchName, "- ", "", 1) if DataLevel == "School"
drop SchName1 SchName2 SchName3 SchName4

gen DistName = SchName
sort StateAssignedDistID DataLevel
replace DistName = DistName[_n-1] if DataLevel == "School"
split DistName, parse ("-")
replace DistName = subinstr(DistName, DistName1, "", 1) if DataLevel != "State"
replace DistName = subinstr(DistName, "- ", "", 1) if DataLevel != "State"
drop DistName1 DistName2 DistName3 DistName4

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

	// Cleaning up DistNames & SchNames
	replace DistName =strtrim(DistName) 
	replace DistName =stritrim(DistName) 
	replace SchName =strtrim(SchName) 
	replace SchName =stritrim(SchName) 
	
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

replace StudentSubGroup = strtrim(StudentSubGroup)
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African-American Students"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learner Students"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free and Reduced Lunch"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-Racial"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Learner Students"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Self-Paid Lunch only"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with  Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not Disabled"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected Students"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"

gen StudentSubGroup_TotalTested = "--"

local level 1 2 3 4
foreach a of local level {
	replace Lev`a'_percent = Lev`a'_percent/100
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen AssmtName = "KAP"
gen AssmtType = "Regular"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--"
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
tostring ProficientOrAbove_percent, replace format("%9.4g") force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel


order SchYear DataLevel DistName SchName StateAssignedDistID StateAssignedSchID AssmtName AssmtType Subject GradeLevel Lev1_count Lev2_count Lev1_percent Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent StudentGroup StudentSubGroup StudentSubGroup_TotalTested  ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent  AvgScaleScore ParticipationRate 

// save to temp
save "${temp}/kansas_2021_temp1.dta", replace


*********************************************
** Merging with NCES
use "${temp}/kansas_2021_temp1.dta"

gen State_leaid = "KS-" + StateAssignedDistID
replace State_leaid = "" if DataLevel == 1

merge m:1 State_leaid using "${NCESDistrict}/NCES_2020_District_KS.dta"

drop if _merge == 1 & DataLevel != 1
drop if _merge == 2
drop _merge

gen seasch = StateAssignedDistID + "-" + StateAssignedSchID
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCESSchool}/NCES_2020_School_KS.dta"

drop if _merge == 2
drop _merge

replace StateAbbrev = "KS" if DataLevel == 1
replace State = "Kansas" if DataLevel == 1
replace StateFips = 20 if DataLevel == 1



order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup  StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate  DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode


// save to temp
save "${temp}/kansas_2021_temp2.dta", replace
export delimited "${temp}/kansas_2021_temp2.csv", replace


****************************************************************
** 2022
****************************************************************

import excel "${raw}/KS_OriginalData_2022_all.xlsx", sheet("2022") firstrow clear

** Renaming variables

rename OrganizationBuildingStateName SchName
rename PctLevel1 Lev1_percent
rename PctLevel2 Lev2_percent
rename PctLevel3 Lev3_percent
rename PctLevel4 Lev4_percent
rename Group StudentSubGroup
rename Grade GradeLevel
rename BldgNo StateAssignedSchID
rename OrgNo StateAssignedDistID
rename SchoolYear SchYear

** Dropping entries

drop if inlist(GradeLevel, "10th Grade", "11th Grade", "All Grades")

drop if inlist(StudentSubGroup, "Building Mobile students", "District Mobile Student", "Free Lunch only", "Gifted only", "Reduced Lunch only", "Regular Ed. only", "English Learner with Disabilities", "With Disability") // changed to English Learning with Disabilities for 2019+


** Replacing/generating variables

tostring SchYear, replace
replace SchYear = "2021-22"

replace Subject = strlower(Subject)
replace Subject = "sci" if Subject == "science"

replace GradeLevel = "G0" + substr(GradeLevel, 1, 1)

gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == 0
replace DataLevel = "State" if StateAssignedDistID == "0"

tostring StateAssignedSchID, replace
replace StateAssignedSchID = substr(SchName, 1, 4)
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

replace SchName = stritrim(SchName)
split SchName, parse ("-")
replace SchName = subinstr(SchName, SchName1, "", 1) if DataLevel == "School"
replace SchName = subinstr(SchName, "- ", "", 1) if DataLevel == "School"
drop SchName1 SchName2 SchName3 SchName4

gen DistName = SchName
sort StateAssignedDistID DataLevel
replace DistName = DistName[_n-1] if DataLevel == "School"
split DistName, parse ("-")
replace DistName = subinstr(DistName, DistName1, "", 1) if DataLevel != "State"
replace DistName = subinstr(DistName, "- ", "", 1) if DataLevel != "State"
drop DistName1 DistName2 DistName3 DistName4

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

	// Cleaning up DistNames & SchNames
	replace DistName =strtrim(DistName) 
	replace DistName =stritrim(DistName) 
	replace SchName =strtrim(SchName) 
	replace SchName =stritrim(SchName) 
	
replace StudentSubGroup = strtrim(StudentSubGroup)
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African-American Students"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learner Students"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free and Reduced Lunch"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-Racial"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Learner Students"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Self-Paid Lunch only"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with  Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not Disabled"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected Students"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"

gen StudentSubGroup_TotalTested = "--"

local level 1 2 3 4
foreach a of local level {
	replace Lev`a'_percent = Lev`a'_percent/100
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen AssmtName = "KAP"
gen AssmtType = "Regular"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--"
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
tostring ProficientOrAbove_percent, replace format("%9.4g") force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order SchYear DataLevel DistName SchName StateAssignedDistID StateAssignedSchID AssmtName AssmtType Subject GradeLevel Lev1_count Lev2_count Lev1_percent Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent StudentGroup StudentSubGroup StudentSubGroup_TotalTested  ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent  AvgScaleScore ParticipationRate 
drop SchName5

// save to temp
save "${temp}/kansas_2022_temp1.dta", replace


*********************************************
** Merging with NCES
use  "${temp}/kansas_2022_temp1.dta"

gen State_leaid = "KS-" + StateAssignedDistID
replace State_leaid = "" if DataLevel == 1

merge m:1 State_leaid using "${NCESDistrict}/NCES_2021_District_KS.dta"

drop if _merge == 1 & DataLevel != 1
drop if _merge == 2
drop _merge

gen seasch = StateAssignedDistID + "-" + StateAssignedSchID
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCESSchool}/NCES_2021_School_KS.dta"

drop if _merge == 2
drop _merge

replace StateAbbrev = "KS" if DataLevel == 1
replace State = "Kansas" if DataLevel == 1
replace StateFips = 20 if DataLevel == 1


order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup  StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate  DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode


// save to temp
save "${temp}/kansas_2022_temp2.dta", replace
export delimited "${temp}/kansas_2022_temp2.csv", replace


****************************************************************
** 2023
****************************************************************

import excel "${raw}/KS_OriginalData_2023_all.xlsx", sheet("2023") firstrow clear

** Renaming variables

rename Organization DistName
rename Building SchName
rename PctLevel1 Lev1_percent
rename PctLevel2 Lev2_percent
rename PctLevel3 Lev3_percent
rename PctLevel4 Lev4_percent
rename StudentSubgroup StudentSubGroup
rename Grade GradeLevel
rename BldgNo StateAssignedSchID
rename OrgNo StateAssignedDistID
rename SchoolYear SchYear

** Dropping entries

drop PctNotTested // all are 0 
drop if inlist(GradeLevel, "10th Grade", "11th Grade", "All Grades")

drop if inlist(StudentSubGroup, "Building Mobile students", "District Mobile Student", "Free Lunch only", "Gifted only", "Reduced Lunch only", "Regular Ed. only", "English Learner with Disabilities", "With Disability") 

** Replacing/generating variables

tostring SchYear, replace
replace SchYear = "2022-23"

replace Subject = strlower(Subject)
replace Subject = "sci" if Subject == "science"

replace GradeLevel = "G0" + substr(GradeLevel, 1, 1)

gen DataLevel = "School"
replace StateAssignedDistID = strtrim(StateAssignedDistID)
replace StateAssignedSchID = strtrim(StateAssignedSchID)
replace DataLevel = "District" if StateAssignedSchID == "0"
replace DataLevel = "State" if StateAssignedDistID == "0"

replace SchName = stritrim(SchName)

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

	// Cleaning up DistNames & SchNames
	replace DistName =strtrim(DistName) 
	replace DistName =stritrim(DistName) 
	replace SchName =strtrim(SchName) 
	replace SchName =stritrim(SchName) 
	
tostring StateAssignedSchID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

replace StudentSubGroup = strtrim(StudentSubGroup)
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African-American Students"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learner Students"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free and Reduced Lunch"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-Racial"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Learner Students"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Self-Paid Lunch only"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with  Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not Disabled"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected Students"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"

gen StudentSubGroup_TotalTested = "--"

local level 1 2 3 4
foreach a of local level {
	replace Lev`a'_percent = Lev`a'_percent/100
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen AssmtName = "KAP"
gen AssmtType = "Regular"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--"
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
tostring ProficientOrAbove_percent, replace format("%9.4g") force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order SchYear DataLevel DistName SchName StateAssignedDistID StateAssignedSchID AssmtName AssmtType Subject GradeLevel Lev1_count Lev2_count Lev1_percent Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent StudentGroup StudentSubGroup StudentSubGroup_TotalTested  ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent  AvgScaleScore ParticipationRate 


// save to temp
save "${temp}/kansas_2023_temp1.dta", replace


*********************************************
** Merging with NCES
use  "${temp}/kansas_2023_temp1.dta"

gen State_leaid = "KS-" + StateAssignedDistID
replace State_leaid = "" if DataLevel == 1

merge m:1 State_leaid using "${NCESDistrict}/NCES_2022_District_KS.dta"

drop if _merge == 1 & DataLevel != 1
drop if _merge == 2
drop _merge

gen seasch = StateAssignedDistID + "-" + StateAssignedSchID

merge m:1 seasch using "${NCESSchool}/NCES_2022_School_KS.dta"

drop if _merge == 2
drop _merge

replace StateAbbrev = "KS"
replace State = "Kansas"
replace StateFips = 20



order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup  StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate  DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode


// save to temp
save "${temp}/kansas_2023_temp2.dta", replace
export delimited "${temp}/kansas_2023_temp2.csv", replace


****************************************************************
** 2024
****************************************************************











