//2022-2023
import excel "$data/WV_OriginalData_2023_ela,math,sci.xlsx", sheet("SY23 Schl & Dist Comp. Results") clear

//Variable Names
rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName
rename E StudentGroup
rename F StudentSubGroup
rename G Lev1_percent_G03_math
rename H Lev2_percent_G03_math
rename I Lev3_percent_G03_math
rename J Lev4_percent_G03_math
rename K ProficientOrAbove_pct_G03_math
rename L Lev1_percent_G04_math
rename M Lev2_percent_G04_math
rename N Lev3_percent_G04_math
rename O Lev4_percent_G04_math
rename P ProficientOrAbove_pct_G04_math
rename Q Lev1_percent_G05_math
rename R Lev2_percent_G05_math
rename S Lev3_percent_G05_math
rename T Lev4_percent_G05_math
rename U ProficientOrAbove_pct_G05_math
rename V Lev1_percent_G06_math
rename W Lev2_percent_G06_math
rename X Lev3_percent_G06_math
rename Y Lev4_percent_G06_math
rename Z ProficientOrAbove_pct_G06_math
rename AA Lev1_percent_G07_math
rename AB Lev2_percent_G07_math
rename AC Lev3_percent_G07_math
rename AD Lev4_percent_G07_math
rename AE ProficientOrAbove_pct_G07_math
rename AF Lev1_percent_G08_math
rename AG Lev2_percent_G08_math
rename AH Lev3_percent_G08_math
rename AI Lev4_percent_G08_math
rename AJ ProficientOrAbove_pct_G08_math
drop AK AL AM AN AO AP AQ AR AS AT

rename AU Lev1_percent_G03_ela
rename AV Lev2_percent_G03_ela
rename AW Lev3_percent_G03_ela
rename AX Lev4_percent_G03_ela
rename AY ProficientOrAbove_pct_G03_ela
rename AZ Lev1_percent_G04_ela
rename BA Lev2_percent_G04_ela
rename BB Lev3_percent_G04_ela
rename BC Lev4_percent_G04_ela
rename BD ProficientOrAbove_pct_G04_ela
rename BE Lev1_percent_G05_ela
rename BF Lev2_percent_G05_ela
rename BG Lev3_percent_G05_ela
rename BH Lev4_percent_G05_ela
rename BI ProficientOrAbove_pct_G05_ela
rename BJ Lev1_percent_G06_ela
rename BK Lev2_percent_G06_ela
rename BL Lev3_percent_G06_ela
rename BM Lev4_percent_G06_ela
rename BN ProficientOrAbove_pct_G06_ela
rename BO Lev1_percent_G07_ela
rename BP Lev2_percent_G07_ela
rename BQ Lev3_percent_G07_ela
rename BR Lev4_percent_G07_ela
rename BS ProficientOrAbove_pct_G07_ela
rename BT Lev1_percent_G08_ela
rename BU Lev2_percent_G08_ela
rename BV Lev3_percent_G08_ela
rename BW Lev4_percent_G08_ela
rename BX ProficientOrAbove_pct_G08_ela
drop BY BZ CA CB CC CD CE CF CG CH

rename CI Lev1_percent_G05_sci
rename CJ Lev2_percent_G05_sci
rename CK Lev3_percent_G05_sci
rename CL Lev4_percent_G05_sci
rename CM ProficientOrAbove_pct_G05_sci
rename CN Lev1_percent_G08_sci
rename CO Lev2_percent_G08_sci
rename CP Lev3_percent_G08_sci
rename CQ Lev4_percent_G08_sci
rename CR ProficientOrAbove_pct_G08_sci
drop CS CT CU CV CW CX CY CZ DA DB DC

drop if StateAssignedDistID == ""
drop if StateAssignedDistID == "Dist"
drop if StateAssignedDistID == "*** Indicates that the rate has been suppressed due to a very small student count at the subgroup level. "
drop if StateAssignedDistID == "Data suppression is applied to comply with WVDE standards for disclosure avoidance to protect student confidentiality."
drop if StateAssignedDistID == "Please Note"

//Reshape Data
reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_pct, i(StateAssignedDistID StateAssignedSchID StudentGroup StudentSubGroup) j(GradeLevel) string

gen Subject = substr(GradeLevel, 6, 4)
replace GradeLevel = subinstr(GradeLevel, "_" + Subject, "", 1)
replace GradeLevel = subinstr(GradeLevel, "_", "", 1)

rename ProficientOrAbove_pct ProficientOrAbove_percent

//Data Levels
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "999"
replace DataLevel = "State" if DistName == "Statewide"

replace DistName = "All Districts" if DataLevel == "State"
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
replace StateAssignedSchID = "" if DataLevel != "School"

//Generate New Variables
gen State = "West Virginia"
gen SchYear = "2022-23"
gen AssmtName = "West Virginia General Summative Assessment"
gen AssmtType = "Regular"
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficiencyCriteria = "Levels 3-4"
gen AvgScaleScore = "--"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"

//Student Groups
replace StudentGroup = "All Students" if StudentGroup == "Total Population"
replace StudentSubGroup = "All Students" if StudentSubGroup == "Total"

replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-Racial"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander"

replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"

replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
drop if StudentSubGroup == "Low SES"

replace StudentGroup = "Disability Status" if StudentSubGroup == "Special Education (Students with Disabilities)"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Special Education (Students with Disabilities)"

replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"

replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"

replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military-Connected"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military-Connected"

save "$data/WV_AssmtData_2023", replace

//Clean NCES Data
use "$NCES_School/NCES_2022_School.dta", clear
drop if state_location != "WV"
gen StateAssignedSchID = substr(seasch, 11, 13)
gen StateAssignedDistID = substr(state_leaid, 4, 6)
replace StateAssignedDistID = substr(StateAssignedDistID, 1,2)
replace StateAssignedDistID = "0" + StateAssignedDistID

foreach var of varlist school_type SchLevel SchVirtual district_agency_type {
	decode `var', gen(temp)
	drop `var'
	rename temp `var'
}
keep state_location state_fips ncesdistrictid district_agency_type county_name county_code state_leaid school_type ncesschoolid StateAssignedDistID StateAssignedSchID DistCharter SchVirtual SchLevel DistLocale

save "$NCES_clean/NCES_2023_School_WV", replace

use "$NCES_Dist/NCES_2022_District.dta", clear
drop if state_location != "WV"
gen StateAssignedDistID = substr(state_leaid, 4, 6)
replace StateAssignedDistID = substr(StateAssignedDistID, 1,2)
replace StateAssignedDistID = "0" + StateAssignedDistID
replace StateAssignedDistID = substr(state_leaid, strpos(state_leaid, "-") +1,3) if ncesdistrictid == "5400062" | ncesdistrictid == "5400063" | ncesdistrictid == "5400064"
drop if lea_name == "WIN Academy at BVCTC"
replace StateAssignedDistID = "101" if lea_name == "West Virginia Academy"
keep state_location state_fips ncesdistrictid district_agency_type county_name county_code state_leaid StateAssignedDistID DistCharter DistLocale
save "$NCES_clean/NCES_2023_District_WV", replace

//Merge Data
use "$data/WV_AssmtData_2023"
merge m:1 StateAssignedDistID using "$NCES_clean/NCES_2023_District_WV.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID  using "$NCES_clean/NCES_2023_School_WV.dta", gen (merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchType
rename state_leaid State_leaid

drop  _merge merge2

replace StateAbbrev = "WV"
replace StateFips = 54

//Unmerged Schools
replace NCESSchoolID = "540006201604" if SchName == "Eastern Panhandle Preparatory Academy"
replace SchType = "Regular school" if SchName == "Eastern Panhandle Preparatory Academy"
replace SchLevel = "Other" if SchName == "Eastern Panhandle Preparatory Academy"
replace SchVirtual = "Supplemental virtual" if SchName == "Eastern Panhandle Preparatory Academy"

replace NCESSchoolID = "540006301605" if SchName == "Virtual Preparatory Academy of West Virginia"
replace SchVirtual = "Supplemental virtual" if SchName == "Virtual Preparatory Academy of West Virginia"
replace SchType = "Regular school" if SchName == "Virtual Preparatory Academy of West Virginia"
replace SchLevel = "Other" if SchName == "Virtual Preparatory Academy of West Virginia"
replace DistName = "Virtual Preparatory Academy of West Virginia" if NCESDistrictID == "5400063"

replace NCESSchoolID = "540006401606" if SchName == "West Virginia Virtual Academy"
replace SchVirtual = "Supplemental virtual" if SchName == "West Virginia Virtual Academy"
replace SchType = "Regular school" if SchName == "West Virginia Virtual Academy"
replace SchLevel = "Other" if SchName == "West Virginia Virtual Academy"

replace NCESSchoolID = "540165201611" if SchName == "West Virginia Academy"
replace SchType = "Regular school" if SchName == "West Virginia Academy"
replace SchLevel = "Other" if SchName == "West Virginia Academy"
replace SchVirtual = "Supplemental virtual" if SchName == "West Virginia Academy"

replace SchType = "Regular school" if SchName == "Victory Elementary School"
replace SchVirtual = "Supplemental virtual" if SchName == "Victory Elementary School"

//Variable Types
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Student Counts
merge 1:1 NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup using "$counts/WV_2022_counts", keep(match master)
gen Count = StudentSubGroup_TotalTested
tostring StudentSubGroup_TotalTested StudentGroup_TotalTested, replace 
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."
drop _merge ParticipationRate

*Merge in State Level Counts
merge 1:1 DataLevel NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject using "$counts/WV_StateCounts_2023"
drop if _merge == 2
gen base = Students if _merge == 3
replace Students = subinstr(Students, "0-", "", 1)
replace Count = real(Students) if _merge == 3 
drop _merge

//ParticipationRate
merge 1:1 StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentSubGroup using "$data/WV_Participation_2023"
drop _merge
replace Count = round(Count * ParticipationRate) if DataLevel == 1
replace StudentSubGroup_TotalTested = string(Count) if DataLevel == 1
replace StudentSubGroup_TotalTested = "0-" + StudentSubGroup_TotalTested if strpos(base, "0-") != 0

tostring ParticipationRate, replace format("%9.4f")
replace ParticipationRate = "--" if ParticipationRate == "."

//Missing & Suppressed Data
replace Lev1_percent = "--" if Lev1_percent == ""
replace Lev2_percent = "--" if Lev2_percent == ""
replace Lev3_percent = "--" if Lev3_percent == ""
replace Lev4_percent = "--" if Lev4_percent == ""
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""

replace Lev1_percent = "*" if Lev1_percent == "***"
replace Lev2_percent = "*" if Lev2_percent == "***"
replace Lev3_percent = "*" if Lev3_percent == "***"
replace Lev4_percent = "*" if Lev4_percent == "***"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "***"

//Proficiency Levels
forvalues n = 1/4 {
	gen Lev`n'_pct = Lev`n'_percent
	destring Lev`n'_pct, replace force
	gen Lev`n'_count = Lev`n'_pct * Count
	replace Lev`n'_count = round(Lev`n'_count)
	replace Lev`n'_percent = "--" if Lev`n'_percent == ""
	replace Lev`n'_percent = "*" if Lev`n'_percent == "***"
	tostring Lev`n'_count, replace
	replace Lev`n'_count = "*" if Lev`n'_percent == "*"
	replace Lev`n'_count = "--" if Lev`n'_percent == "--"
	replace Lev`n'_count = "--" if StudentSubGroup_TotalTested == "--" & Lev`n'_count != "*"
	replace Lev`n'_percent = "--" if Lev`n'_percent == "."
	replace Lev`n'_count = "0-" + Lev`n'_count if strpos(StudentSubGroup_TotalTested, "0-") != 0 & Lev`n'_count != "*"
}

gen Prof_pct = ProficientOrAbove_percent
destring Prof_pct, replace force
gen ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count))  if !missing(real(Lev3_count)) & !missing(real(Lev4_count))
replace ProficientOrAbove_count = string(round(Prof_pct*Count)) if ProficientOrAbove_count == ""
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == ""
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "***"
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "*" if ProficientOrAbove_percent == "***"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_percent == "--"
replace ProficientOrAbove_count = "--" if StudentSubGroup_TotalTested == "--" & ProficientOrAbove_count != "*"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & ProficientOrAbove_percent == "*"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
replace ProficientOrAbove_count = "0-" + ProficientOrAbove_count if strpos(StudentSubGroup_TotalTested, "0-") != 0 & ProficientOrAbove_count != "*"
gen flag = 1 if !inlist(StudentSubGroup_TotalTested, "*", "--") & ProficientOrAbove_percent == "1" & StudentSubGroup_TotalTested != ProficientOrAbove_count //this is one specific obs. where rounding is causing ProficientOrAbove_count to be > SSGTT if derived as the sum of level counts
replace Lev3_count = "*" if flag == 1
replace Lev4_count = "*" if flag == 1
replace ProficientOrAbove_count = StudentSubGroup_TotalTested if flag == 1

drop Lev1_pct Lev2_pct Lev3_pct Lev4_pct Prof_pct Count Students base flag

//StudentGroup_TotalTested Convention
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen All_Students = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace All_Students = All_Students[_n-1] if missing(All_Students)
replace StudentGroup_TotalTested = All_Students 

//Percent Lengths
foreach var of varlist *_percent {
	replace `var' = string(real(`var'), "%9.3g") if regexm(`var', "[0-9]") !=0
}

//Remove Observations with All Information Missing
drop if Lev1_percent == "--" & Lev2_percent == "--" & Lev3_percent == "--" & Lev4_percent == "--" & ProficientOrAbove_percent == "--" //cases where grade/school combos don't exist
drop if Lev1_percent == "*" & Lev2_percent == "*" & Lev3_percent == "*" & Lev4_percent == "*" & ProficientOrAbove_percent == "*" & StudentSubGroup != "All Students"

//Formatting IDs + School & Dist Names
replace StateAssignedSchID = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == 3 //creates unique school IDs

foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var') // collapses all consecutive, internal blanks to one blank.
	replace `var' = strtrim(`var') // removes leading and trailing blanks
}

replace DistName = "McDowell" if NCESDistrictID == "5400810"
replace DistName = "Virtual Preparatory Academy of West Virginia" if DistName == "Virt Prep Academy"
replace SchName = "Mason Dixon Elementary" if NCESSchoolID == "540093000750"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$output/WV_AssmtData_2023", replace
export delimited "$output/WV_AssmtData_2023", replace
