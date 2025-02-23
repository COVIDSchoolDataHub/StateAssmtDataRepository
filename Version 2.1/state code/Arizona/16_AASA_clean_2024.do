*******************************************************
* ARIZONA

* File name: 16_AASA_clean_2024
* Last update: 2/20/2025

*******************************************************
* Notes

	* This do file cleans AZ's 2024 data and merges with NCES 2022.
	* Both the non-derivation and derivation outputs are created.  
	* As of 2/20/2025, NCES 2022 is the latest release. 
	* This file will need to be updated as NCES 2023 is available. 
	
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear

************************************************************************************
* Importing data and renaming variables
************************************************************************************
** 2024 ELA and Math

//SCHOOLS
import excel "${AASA}/AZ_OriginalData_2024_ela_mat.xlsx", sheet("School") firstrow clear
** Rename existing variables
rename DistrictName DistName
rename DistrictEntityID StateAssignedDistID
rename SchoolEntityID StateAssignedSchID
rename SchoolName SchName
rename Subgroup StudentSubGroup
rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

drop Charter Alternative DistrictCTDS SchoolCTDS

** Generate grade observations from TestLevel variable
drop if strpos(GradeLevel, "Alt") > 0
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

tostring StateAssignedSchID, generate(seasch)
tostring StateAssignedSchID, replace

save "${AASA}/AZ_AssmtData_school_2024.dta", replace

************************************************************************************
//DISTRICTS
import excel "${AASA}/AZ_OriginalData_2024_ela_mat.xlsx", sheet("District") firstrow clear   

** Rename existing variables
rename DistrictName DistName
rename DistrictEntityID StateAssignedDistID

rename Subgroup StudentSubGroup
rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

drop DistrictCTDS

** Generate grade observations from TestLevel variable
drop if strpos(GradeLevel, "Alt") > 0
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

save "${AASA}/AZ_AssmtData_district_2024.dta", replace

************************************************************************************
//STATE
import excel "${AASA}/AZ_OriginalData_2024_ela_mat.xlsx", sheet("State") firstrow clear

rename Subgroup StudentSubGroup
rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

** Generate grade observations from TestLevel variable
drop if strpos(GradeLevel, "Alt") > 0
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

save "${AASA}/AZ_AssmtData_state_2024.dta", replace

************************************************************************************
** 2024 Science
//SCHOOLS

import excel "${AzSci}/AZ_OriginalData_2024_sci.xlsx", sheet("School") firstrow clear

** Rename existing variables
rename DistrictName DistName
rename DistrictEntityID StateAssignedDistID
rename SchoolEntityID StateAssignedSchID
rename SchoolName SchName
rename Subgroup StudentSubGroup

rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

replace Subject="sci"

drop Charter DistrictCTDS SchoolCTDS

** Generate grade observations from TestLevel variable
drop if strpos(GradeLevel, "Alt") > 0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

keep if FAYStatus == "All"

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedSchID, generate(seasch)
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace

save "${AzSci}/AZ_AssmtData_2024_school_sci.dta", replace

************************************************************************************
//DISTRICTS

import excel "${AzSci}/AZ_OriginalData_2024_sci.xlsx", sheet("District") firstrow clear

rename DistrictName DistName
rename DistrictEntityID StateAssignedDistID
rename Subgroup StudentSubGroup

rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

drop DistrictCTDS

replace Subject="sci"

** Generate grade observations from TestLevel variable
drop if strpos(GradeLevel, "Alt") > 0

replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

keep if FAYStatus == "All"

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

save "${AzSci}/AZ_AssmtData_2024_district_sci.dta", replace

************************************************************************************
//STATE

import excel "${AzSci}/AZ_OriginalData_2024_sci.xlsx", sheet("State") firstrow clear

rename TestLevel GradeLevel
rename Subgroup StudentSubGroup

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

replace Subject="sci"

** Generate grade observations from TestLevel variable
drop if strpos(GradeLevel, "Alt") > 0

tostring GradeLevel, replace
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")
keep if FAYStatus == "All"

tostring Lev1_percent, replace force
tostring Lev2_percent, replace force
tostring Lev3_percent, replace force
tostring Lev4_percent, replace force

tostring ProficientOrAbove_percent, replace force

save "${AzSci}/AZ_AssmtData_2024_state_sci.dta", replace

************************************************************************************
*Appending and merging with NCES data
************************************************************************************
//SCHOOLS - ELA and Math, Sci
use "${AASA}/AZ_AssmtData_school_2024.dta", clear
append using "${AzSci}/AZ_AssmtData_2024_school_sci.dta"

merge m:1 State_leaid using "${NCES_AZ}/NCES_2022_District_AZ.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch NCESDistrictID using "${NCES_AZ}/NCES_2022_School_AZ.dta"
drop if _merge == 2
drop _merge

sort NCESSchoolID GradeLevel Subject
gen DataLevel = "School"

save "${Temp}/AZ_AssmtData_school_2024.dta", replace

//DISTRICTS - ELA and Math, Sci
use "${AASA}/AZ_AssmtData_district_2024.dta", clear

append using "${AzSci}/AZ_AssmtData_2024_district_sci.dta"

merge m:1 State_leaid using "${NCES_AZ}/NCES_2022_District_AZ.dta"
drop if _merge == 2
drop _merge

sort NCESDistrictID GradeLevel Subject
gen DataLevel = "District"

//Unmerged
replace NCESDistrictID = "0409745" if StateAssignedDistID == "1002079"
replace DistType = 7 if NCESDistrictID == "0409745"
replace DistCharter = "Yes" if NCESDistrictID == "0409745"
replace DistLocale = "City, large" if NCESDistrictID == "0409745"
replace CountyName = "Maricopa County" if NCESDistrictID == "0409745"
replace CountyCode = "4013" if NCESDistrictID == "0409745"

replace NCESDistrictID = "0409746" if StateAssignedDistID == "1002080"
replace DistType = 7 if NCESDistrictID == "0409746"
replace DistCharter = "Yes" if NCESDistrictID == "0409746"
replace DistLocale = "City, large" if NCESDistrictID == "0409746"
replace CountyName = "Maricopa County" if NCESDistrictID == "0409746"
replace CountyCode = "4013" if NCESDistrictID == "0409746"

replace NCESDistrictID = "0409747" if StateAssignedDistID == "1002101"
replace DistType = 7 if NCESDistrictID == "0409747"
replace DistCharter = "Yes" if NCESDistrictID == "0409747"
replace DistLocale = "City, large" if NCESDistrictID == "0409747"
replace CountyName = "Maricopa County" if NCESDistrictID == "0409747"
replace CountyCode = "4013" if NCESDistrictID == "0409747"

replace NCESDistrictID = "0409744" if StateAssignedDistID == "1002029"
replace DistType = 7 if NCESDistrictID == "0409744"
replace DistCharter = "Yes" if NCESDistrictID == "0409744"
replace DistLocale = "Suburb, large" if NCESDistrictID == "0409744"
replace CountyName = "Maricopa County" if NCESDistrictID == "0409744"
replace CountyCode = "4013" if NCESDistrictID == "0409744"

//Duplicates
duplicates tag NCESDistrictID Subject GradeLevel StudentSubGroup, gen(tag)
sort tag NCESDistrictID Subject GradeLevel StudentSubGroup
drop if tag > 0 & strpos(CountyName, County) == 0
drop tag

save "${Temp}/AZ_AssmtData_district_2024.dta", replace


//STATE - ELA and Math, Sci - Appending only. 
use "${AASA}/AZ_AssmtData_state_2024.dta", clear

append using "${AzSci}/AZ_AssmtData_2024_state_sci.dta"

keep if SchoolType == "All"
drop SchoolType
sort GradeLevel Subject

gen DataLevel = "State"

tostring StudentSubGroup_TotalTested, replace force

save "${Temp}/AZ_AssmtData_state_2024.dta", replace

** Append all files 
append using "${Temp}/AZ_AssmtData_school_2024.dta" "${Temp}/AZ_AssmtData_district_2024.dta"

gen SchYear = "2023-24"

gen StudentGroup = ""
drop State
gen State = "Arizona"
drop StateAbbrev
gen StateAbbrev = "AZ"
drop StateFips
gen StateFips = 4

save "${Temp}/AZ_AssmtData_2024.dta", replace

** Generating missing variables

keep if FAYStatus == "All"

gen AssmtName="AASA"
replace AssmtName="AzSci" if Subject == "sci"
gen AssmtType = "Regular"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"

gen AvgScaleScore = "--"

gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"
gen ParticipationRate = "--"

//District wide
replace SchName = "All Schools" if DataLevel == "District" | DataLevel == "State"
replace DistName = "All Districts" if DataLevel == "State"
replace SchName = strtrim(SchName)
replace SchName = stritrim(SchName)
replace DistName = strtrim(DistName)
replace DistName = stritrim(DistName)

//Fixing types
tostring StateAssignedSchID, replace
replace StateAssignedSchID = "" if StateAssignedSchID == "."
decode SchLevel, generate(new)
drop SchLevel
rename new SchLevel
decode SchType, generate(new)
drop SchType
rename new SchType
decode SchVirtual, generate(new)
drop SchVirtual
rename new SchVirtual

** Replace missing values
	
foreach u of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	destring `u', generate(`u'2) force
	replace `u'2 = `u'2 / 100
	tostring `u'2, replace format("%9.2g") force
	replace `u' = `u'2 if `u'2 != "."
	replace `u' = "0-0.02" if `u' == "<2"
	replace `u' = "0.98-1" if `u' == ">98"
	drop `u'2
}

replace CountyName = strproper(CountyName)

replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if inlist(StudentSubGroup, "American Indian or Alaska Native", "Asian", "Black or African American", "Hispanic or Latino", "Native Hawaiian or Pacific Islander", "Two or more Races", "White")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Income Eligibility 1 and 2")
replace StudentGroup = "EL Status" if StudentSubGroup == "Limited English Proficient"
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Male", "Female")
replace StudentGroup="Disability Status" if StudentSubGroup == "Students with Disabilities"
replace StudentGroup="Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup="Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup="Military Connected Status" if StudentSubGroup == "Military"
replace StudentGroup="Foster Care Status" if StudentSubGroup == "Foster Care"
drop if StudentGroup == "" & StudentSubGroup != ""

replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more Races"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Income Eligibility 1 and 2"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"

sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
egen uniquegrp = group(DataLevel StateAssignedDistID StateAssignedSchID AssmtName Subject GradeLevel)
gen flag = 1 if StudentSubGroup_TotalTested == "*" & ProficientOrAbove_percent == "*" & StudentSubGroup_TotalTested[_n-1] != "*" & StudentSubGroup == StudentSubGroup[_n-1] & uniquegrp == uniquegrp[_n-1]
replace flag = 1 if StudentSubGroup_TotalTested == "*" & ProficientOrAbove_percent == "*" & StudentSubGroup_TotalTested[_n+1] != "*" & StudentSubGroup == StudentSubGroup[_n+1] & uniquegrp == uniquegrp[_n+1]
drop if flag == 1
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"
drop uniquegrp flag

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) i(*-)
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen RaceEth = sum(StudentSubGroup_TotalTested2) if StudentGroup == "RaceEth"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Gender = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Gender"

gen max = real(StudentGroup_TotalTested)
replace max = 0 if max == .

gen x = 1 if missing(real(StudentSubGroup_TotalTested))
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject StudentGroup: egen flag = sum(x)

replace StudentSubGroup_TotalTested2 = max - RaceEth if StudentGroup == "RaceEth" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag <= 1
replace StudentSubGroup_TotalTested2 = max - Gender if StudentGroup == "Gender" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag <= 1

replace StudentSubGroup_TotalTested = string(StudentSubGroup_TotalTested2) if missing(real(StudentSubGroup_TotalTested)) & StudentSubGroup_TotalTested2 != . & inlist(StudentGroup, "RaceEth", "Gender")
drop if inlist(StudentSubGroup_TotalTested, "", "0") & StudentSubGroup != "All Students"
drop StudentSubGroup_TotalTested2

replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Mathematics"

//sort
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
drop DataLevel 
rename DataLevel_n DataLevel

**

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
destring Lev1_percent, gen(Lev1_percent2) force
destring Lev2_percent, gen(Lev2_percent2) force

foreach v of varlist Lev3_percent Lev4_percent ProficientOrAbove_percent {
	split `v', parse("-")
	destring `v'1, replace force
	destring `v'2, replace force
	replace `v'2 = `v'1 if `v'2 == . & `v'1 != .
	replace `v'1 = . if `v'1 == `v'2
}

replace ProficientOrAbove_percent2 = Lev3_percent2 + Lev4_percent2 if ProficientOrAbove_percent2 == . & Lev3_percent2 != . & Lev4_percent2 != .

save "${Temp}/AZ_AssmtData_2024.dta", replace //This file is used for derived output. 

************************************************************************************
*Calculations*
************************************************************************************
tostring ProficientOrAbove_percent2, format("%9.2g") replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent2 if ProficientOrAbove_percent2 != "."

replace Lev1_percent2 = 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) if missing(real(Lev1_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev2_percent))
replace Lev1_percent = string(1 - real(Lev2_percent) - 0.02) + "-" + string(1 - real(Lev2_percent)) if missing(real(Lev1_percent)) & ProficientOrAbove_percent == "0-0.02" & !missing(real(Lev2_percent))
replace Lev2_percent2 = 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) if missing(real(Lev2_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev1_percent))
replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - 0.02) + "-" + string(1 - real(ProficientOrAbove_percent)) if missing(real(Lev2_percent)) & Lev1_percent == "0-0.02" & !missing(real(ProficientOrAbove_percent))
replace Lev2_percent = string(1 - real(Lev1_percent) - 0.02) + "-" + string(1 - real(Lev1_percent)) if missing(real(Lev2_percent)) & ProficientOrAbove_percent == "0-0.02" & !missing(real(Lev1_percent))
replace Lev3_percent2 = real(ProficientOrAbove_percent) - real(Lev4_percent) if missing(real(Lev3_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev4_percent))
replace Lev3_percent = string(real(ProficientOrAbove_percent) - 0.02) + "-" + ProficientOrAbove_percent if missing(real(Lev3_percent)) & Lev4_percent == "0-0.02" & !missing(real(ProficientOrAbove_percent))
replace Lev3_percent = "0-0.02" if Lev3_percent == "0-.02"
replace Lev4_percent2 = real(ProficientOrAbove_percent) - real(Lev3_percent) if missing(real(Lev4_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev3_percent))
replace Lev4_percent = string(real(ProficientOrAbove_percent) - 0.02) + "-" + ProficientOrAbove_percent if missing(real(Lev4_percent)) & Lev3_percent == "0-0.02" & !missing(real(ProficientOrAbove_percent))
replace Lev4_percent = "0-0.02" if Lev4_percent == "0-.02"

foreach x of numlist 1/4 {
	replace Lev`x'_percent2 = 0 if Lev`x'_percent2 < 0 & Lev`x'_percent2 != .
	replace Lev`x'_percent = string(Lev`x'_percent2, "%9.2g") if Lev`x'_percent == "*" & Lev`x'_percent2 != .
	replace Lev`x'_percent = "0" if strpos(Lev`x'_percent, "e") > 0 & strpos(Lev`x'_percent, "-0.02") == 0
	replace Lev`x'_percent = "0-0.02" if strpos(Lev`x'_percent, "e") > 0 & strpos(Lev`x'_percent, "-0.02") > 0
	cap drop Lev`x'_percent1
	drop Lev`x'_percent2
}

************************************************************************************
*Creating variables for non-derivation output*
************************************************************************************
gen Lev5_count = ""
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen  ProficientOrAbove_count = "--"

//New Districts and Schools
replace NCESDistrictID = "0409745" if StateAssignedDistID == "1002079"
replace DistType = 7 if NCESDistrictID == "0409745"
replace DistCharter = "Yes" if NCESDistrictID == "0409745"
replace DistLocale = "City, large" if NCESDistrictID == "0409745"
replace CountyName = "Maricopa County" if NCESDistrictID == "0409745"
replace CountyCode = "4013" if NCESDistrictID == "0409745"

replace NCESDistrictID = "0409746" if StateAssignedDistID == "1002080"
replace DistType = 7 if NCESDistrictID == "0409746"
replace DistCharter = "Yes" if NCESDistrictID == "0409746"
replace DistLocale = "City, large" if NCESDistrictID == "0409746"
replace CountyName = "Maricopa County" if NCESDistrictID == "0409746"
replace CountyCode = "4013" if NCESDistrictID == "0409746"

replace NCESDistrictID = "0409747" if StateAssignedDistID == "1002101"
replace DistType = 7 if NCESDistrictID == "0409747"
replace DistCharter = "Yes" if NCESDistrictID == "0409747"
replace DistLocale = "City, large" if NCESDistrictID == "0409747"
replace CountyName = "Maricopa County" if NCESDistrictID == "0409747"
replace CountyCode = "4013" if NCESDistrictID == "0409747"

replace NCESDistrictID = "0409744" if StateAssignedDistID == "1002029"
replace DistType = 7 if NCESDistrictID == "0409744"
replace DistCharter = "Yes" if NCESDistrictID == "0409744"
replace DistLocale = "Suburb, large" if NCESDistrictID == "0409744"
replace CountyName = "Maricopa County" if NCESDistrictID == "0409744"
replace CountyCode = "4013" if NCESDistrictID == "0409744"

replace NCESSchoolID = "040974503850" if StateAssignedSchID == "1002100"
replace SchType = "Regular school" if NCESSchoolID == "040974503850"
replace SchLevel = "Primary" if NCESSchoolID == "040974503850"
replace SchVirtual = "Yes" if NCESSchoolID == "040974503850"

replace NCESSchoolID = "040974603602" if StateAssignedSchID == "1000169"
replace SchType = "Regular school" if NCESSchoolID == "040974603602"
replace SchLevel = "Other" if NCESSchoolID == "040974603602"
replace SchVirtual = "No" if NCESSchoolID == "040974603602"

replace NCESSchoolID = "040974703852" if StateAssignedSchID == "1002105"
replace SchType = "Regular school" if NCESSchoolID == "040974703852"
replace SchLevel = "High" if NCESSchoolID == "040974703852"
replace SchVirtual = "No" if NCESSchoolID == "040974703852"

replace NCESSchoolID = "040974403844" if StateAssignedSchID == "1002031"
replace SchType = "Regular school" if NCESSchoolID == "040974403844"
replace SchLevel = "High" if NCESSchoolID == "040974403844"
replace SchVirtual = "Yes" if NCESSchoolID == "040974403844"

replace NCESSchoolID = "040091303846" if StateAssignedSchID == "1002081"
replace SchType = "Special education school" if NCESSchoolID == "040091303846"
replace SchLevel = "Other" if NCESSchoolID == "040091303846"
replace SchVirtual = "No" if NCESSchoolID == "040091303846"

replace NCESSchoolID = "040005303851" if StateAssignedSchID == "1002102"
replace SchType = "Regular school" if NCESSchoolID == "040005303851"
replace SchLevel = "Primary" if NCESSchoolID == "040005303851"
replace SchVirtual = "No" if NCESSchoolID == "040005303851"

replace NCESSchoolID = "040444003843" if StateAssignedSchID == "1002030"
replace SchType = "Regular school" if NCESSchoolID == "040444003843"
replace SchLevel = "Primary" if NCESSchoolID == "040444003843"
replace SchVirtual = "No" if NCESSchoolID == "040444003843"

replace SchLevel = "Other" if NCESSchoolID == "040974103839"
replace SchVirtual = "No" if NCESSchoolID == "040974103839"

//Formatting NCES IDs
replace NCESSchoolID = subinstr(NCESSchoolID, "0", "", 1) if DataLevel == 3
replace NCESDistrictID = subinstr(NCESDistrictID, "0", "", 1) if DataLevel != 1
duplicates drop

foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

// Reordering variables and sorting data
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

// *Exporting into a separate folder Output for Stanford - without derivations*
save "${Output_ND}/AZ_AssmtData2024_NoDev", replace //If .dta format needed.
export delimited "${Output_ND}/AZ_AssmtData2024_NoDev", replace 

***********************************************
*File splits here for derivations
***********************************************
use "${Temp}/AZ_AssmtData_2024.dta", clear

gen ProficientOrAbove_count = round(ProficientOrAbove_percent2 * StudentSubGroup_TotalTested2)
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."

tostring ProficientOrAbove_percent2, format("%9.2g") replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent2 if ProficientOrAbove_percent2 != "."

replace Lev1_percent2 = 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) if missing(real(Lev1_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev2_percent))
replace Lev1_percent = string(1 - real(Lev2_percent) - 0.02) + "-" + string(1 - real(Lev2_percent)) if missing(real(Lev1_percent)) & ProficientOrAbove_percent == "0-0.02" & !missing(real(Lev2_percent))
replace Lev2_percent2 = 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) if missing(real(Lev2_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev1_percent))
replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - 0.02) + "-" + string(1 - real(ProficientOrAbove_percent)) if missing(real(Lev2_percent)) & Lev1_percent == "0-0.02" & !missing(real(ProficientOrAbove_percent))
replace Lev2_percent = string(1 - real(Lev1_percent) - 0.02) + "-" + string(1 - real(Lev1_percent)) if missing(real(Lev2_percent)) & ProficientOrAbove_percent == "0-0.02" & !missing(real(Lev1_percent))
replace Lev3_percent2 = real(ProficientOrAbove_percent) - real(Lev4_percent) if missing(real(Lev3_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev4_percent))
replace Lev3_percent = string(real(ProficientOrAbove_percent) - 0.02) + "-" + ProficientOrAbove_percent if missing(real(Lev3_percent)) & Lev4_percent == "0-0.02" & !missing(real(ProficientOrAbove_percent))
replace Lev3_percent = "0-0.02" if Lev3_percent == "0-.02"
replace Lev4_percent2 = real(ProficientOrAbove_percent) - real(Lev3_percent) if missing(real(Lev4_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev3_percent))
replace Lev4_percent = string(real(ProficientOrAbove_percent) - 0.02) + "-" + ProficientOrAbove_percent if missing(real(Lev4_percent)) & Lev3_percent == "0-0.02" & !missing(real(ProficientOrAbove_percent))
replace Lev4_percent = "0-0.02" if Lev4_percent == "0-.02"

foreach x of numlist 1/4 {
	replace Lev`x'_percent2 = 0 if Lev`x'_percent2 < 0 & Lev`x'_percent2 != .
	replace Lev`x'_percent = string(Lev`x'_percent2, "%9.2g") if Lev`x'_percent == "*" & Lev`x'_percent2 != .
	replace Lev`x'_percent = "0" if strpos(Lev`x'_percent, "e") > 0 & strpos(Lev`x'_percent, "-0.02") == 0
	replace Lev`x'_percent = "0-0.02" if strpos(Lev`x'_percent, "e") > 0 & strpos(Lev`x'_percent, "-0.02") > 0
	cap drop Lev`x'_percent1
	drop Lev`x'_percent2
}

foreach x of numlist 1/4 {
	split Lev`x'_percent, parse("-")
	destring Lev`x'_percent1, replace force
	cap destring Lev`x'_percent2, replace force
	if `x' <=2{
		gen Lev`x'_count = round(Lev`x'_percent1 * StudentSubGroup_TotalTested2)
		tostring Lev`x'_count, replace
	}
	if `x' > 2{
		gen Lev`x'_count = round(Lev`x'_percent1 * StudentSubGroup_TotalTested2) if Lev`x'_percent2 == .
		tostring Lev`x'_count, replace
		replace Lev`x'_count = string(round(Lev`x'_percent1 * StudentSubGroup_TotalTested2)) + "-" + string(round(Lev`x'_percent2 * StudentSubGroup_TotalTested2)) if round(Lev`x'_percent1 * StudentSubGroup_TotalTested2) != round(Lev`x'_percent2 * StudentSubGroup_TotalTested2) & Lev`x'_percent2 != .
	}
	replace Lev`x'_count = "*" if Lev`x'_count == "."
}

gen Lev5_count = ""

//New Districts and Schools
replace NCESDistrictID = "0409745" if StateAssignedDistID == "1002079"
replace DistType = 7 if NCESDistrictID == "0409745"
replace DistCharter = "Yes" if NCESDistrictID == "0409745"
replace DistLocale = "City, large" if NCESDistrictID == "0409745"
replace CountyName = "Maricopa County" if NCESDistrictID == "0409745"
replace CountyCode = "4013" if NCESDistrictID == "0409745"

replace NCESDistrictID = "0409746" if StateAssignedDistID == "1002080"
replace DistType = 7 if NCESDistrictID == "0409746"
replace DistCharter = "Yes" if NCESDistrictID == "0409746"
replace DistLocale = "City, large" if NCESDistrictID == "0409746"
replace CountyName = "Maricopa County" if NCESDistrictID == "0409746"
replace CountyCode = "4013" if NCESDistrictID == "0409746"

replace NCESDistrictID = "0409747" if StateAssignedDistID == "1002101"
replace DistType = 7 if NCESDistrictID == "0409747"
replace DistCharter = "Yes" if NCESDistrictID == "0409747"
replace DistLocale = "City, large" if NCESDistrictID == "0409747"
replace CountyName = "Maricopa County" if NCESDistrictID == "0409747"
replace CountyCode = "4013" if NCESDistrictID == "0409747"

replace NCESDistrictID = "0409744" if StateAssignedDistID == "1002029"
replace DistType = 7 if NCESDistrictID == "0409744"
replace DistCharter = "Yes" if NCESDistrictID == "0409744"
replace DistLocale = "Suburb, large" if NCESDistrictID == "0409744"
replace CountyName = "Maricopa County" if NCESDistrictID == "0409744"
replace CountyCode = "4013" if NCESDistrictID == "0409744"

replace NCESSchoolID = "040974503850" if StateAssignedSchID == "1002100"
replace SchType = "Regular school" if NCESSchoolID == "040974503850"
replace SchLevel = "Primary" if NCESSchoolID == "040974503850"
replace SchVirtual = "Yes" if NCESSchoolID == "040974503850"

replace NCESSchoolID = "040974603602" if StateAssignedSchID == "1000169"
replace SchType = "Regular school" if NCESSchoolID == "040974603602"
replace SchLevel = "Other" if NCESSchoolID == "040974603602"
replace SchVirtual = "No" if NCESSchoolID == "040974603602"

replace NCESSchoolID = "040974703852" if StateAssignedSchID == "1002105"
replace SchType = "Regular school" if NCESSchoolID == "040974703852"
replace SchLevel = "High" if NCESSchoolID == "040974703852"
replace SchVirtual = "No" if NCESSchoolID == "040974703852"

replace NCESSchoolID = "040974403844" if StateAssignedSchID == "1002031"
replace SchType = "Regular school" if NCESSchoolID == "040974403844"
replace SchLevel = "High" if NCESSchoolID == "040974403844"
replace SchVirtual = "Yes" if NCESSchoolID == "040974403844"

replace NCESSchoolID = "040091303846" if StateAssignedSchID == "1002081"
replace SchType = "Special education school" if NCESSchoolID == "040091303846"
replace SchLevel = "Other" if NCESSchoolID == "040091303846"
replace SchVirtual = "No" if NCESSchoolID == "040091303846"

replace NCESSchoolID = "040005303851" if StateAssignedSchID == "1002102"
replace SchType = "Regular school" if NCESSchoolID == "040005303851"
replace SchLevel = "Primary" if NCESSchoolID == "040005303851"
replace SchVirtual = "No" if NCESSchoolID == "040005303851"

replace NCESSchoolID = "040444003843" if StateAssignedSchID == "1002030"
replace SchType = "Regular school" if NCESSchoolID == "040444003843"
replace SchLevel = "Primary" if NCESSchoolID == "040444003843"
replace SchVirtual = "No" if NCESSchoolID == "040444003843"

replace SchLevel = "Other" if NCESSchoolID == "040974103839"
replace SchVirtual = "No" if NCESSchoolID == "040974103839"

//Formatting NCES IDs
replace NCESSchoolID = subinstr(NCESSchoolID, "0", "", 1) if DataLevel == 3
replace NCESDistrictID = subinstr(NCESDistrictID, "0", "", 1) if DataLevel != 1

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

duplicates drop

//Keeping, ordering and sorting variables
keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output with derivations*
save "${Output}/AZ_AssmtData_2024.dta", replace
export delimited using "${Output}/AZ_AssmtData_2024.csv", replace
* END of 16_AASA_clean_2024.do
****************************************************
