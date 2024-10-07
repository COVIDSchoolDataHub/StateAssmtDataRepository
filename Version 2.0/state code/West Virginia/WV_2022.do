//2020-21
import excel "$data/WV_OriginalData_1521_all.xlsx", sheet("SY21 School & District") clear

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
drop CS CT CU CV CW CX CY CZ DA DB

drop if StateAssignedDistID == ""
drop if StateAssignedDistID == "Dist"
drop if StateAssignedDistID == "** Indicates that the rate has been suppressed due to a very small student count at the subgroup level. "
drop if StateAssignedDistID == "Data suppression is applied to comply with WVDE standards for disclosure avoidance to protect student confidentiality."
drop if StateAssignedDistID == "Please Note"

//Reshape Data
reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_pct, i(StateAssignedDistID StateAssignedSchID StudentGroup StudentSubGroup) j(GradeLevel) string

gen Subject = "math"
replace Subject = "ela" if GradeLevel == "_G03_ela"
replace Subject = "ela" if GradeLevel == "_G04_ela"
replace Subject = "ela" if GradeLevel == "_G05_ela"
replace Subject = "ela" if GradeLevel == "_G06_ela"
replace Subject = "ela" if GradeLevel == "_G07_ela"
replace Subject = "ela" if GradeLevel == "_G08_ela"
replace Subject = "sci" if GradeLevel == "_G05_sci"
replace Subject = "sci" if GradeLevel == "_G08_sci"

replace GradeLevel = "G03" if GradeLevel == "_G03_math"
replace GradeLevel = "G03" if GradeLevel == "_G03_ela"
replace GradeLevel = "G04" if GradeLevel == "_G04_math"
replace GradeLevel = "G04" if GradeLevel == "_G04_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_math"
replace GradeLevel = "G05" if GradeLevel == "_G05_ela"
replace GradeLevel = "G05" if GradeLevel == "_G05_sci"
replace GradeLevel = "G06" if GradeLevel == "_G06_math"
replace GradeLevel = "G06" if GradeLevel == "_G06_ela"
replace GradeLevel = "G07" if GradeLevel == "_G07_math"
replace GradeLevel = "G07" if GradeLevel == "_G07_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_math"
replace GradeLevel = "G08" if GradeLevel == "_G08_ela"
replace GradeLevel = "G08" if GradeLevel == "_G08_sci"

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
gen SchYear = "2021-22"
gen AssmtName = "West Virginia General Summative Assessment"
gen AssmtType = "Regular"
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficiencyCriteria = "Levels 3-4"
gen ParticipationRate = "--"
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

save "$data/WV_AssmtData_2022", replace

//Clean NCES Data
use "$data/NCES_2021_School.dta", clear
drop if state_location != "WV"
gen StateAssignedSchID = substr(seasch, 11, 13)
gen StateAssignedDistID = substr(state_leaid, 4, 6)
replace StateAssignedDistID = substr(StateAssignedDistID, 1,2)
replace StateAssignedDistID = "0" + StateAssignedDistID

foreach var of varlist SchType SchLevel SchVirtual {
	decode `var', gen(temp)
	drop `var'
	rename temp `var'
}
keep state_location state_fips ncesdistrictid district_agency_type county_name county_code state_leaid SchType ncesschoolid StateAssignedDistID StateAssignedSchID DistCharter SchVirtual SchLevel DistLocale

save "$data/NCES_2022_School_WV", replace

use "$data/NCES_2021_District.dta", clear
drop if state_location != "WV"
gen StateAssignedDistID = substr(state_leaid, 4, 6)
replace StateAssignedDistID = substr(StateAssignedDistID, 1,2)
replace StateAssignedDistID = "0" + StateAssignedDistID
drop if lea_name == "Eastern Panhandle Preparatory Academy"
drop if lea_name == "Virtual Preparatory Academy of West Virginia"
drop if lea_name == "West Virginia Virtual Academy"
save "$data/NCES_2022_District_WV", replace

use "$data/WV_AssmtData_2022", clear
//Merge Data
merge m:1 StateAssignedDistID using "$data/NCES_2022_District_WV.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$data/NCES_2022_School_WV.dta", gen(merge2) 
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
*rename school_type SchType
rename state_leaid State_leaid

drop _merge merge2

replace StateAbbrev = "WV"
replace StateFips = 54

//Variable Types
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

destring NCESDistrictID, replace

//Student Counts and ParticipationRate
merge 1:1 NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup using "$data/counts/WV_2022_counts", keep(match master)
tostring StudentSubGroup_TotalTested StudentGroup_TotalTested, replace 
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."
replace StudentGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."
replace ParticipationRate = ParticipationRate1
replace ParticipationRate = "--" if missing(ParticipationRate)

//Proficiency Levels
destring StudentSubGroup_TotalTested, gen(num) force
forvalues n = 1/4 {
	replace Lev`n'_percent = "--" if Lev`n'_percent == ""
	gen Lev`n'_pct = Lev`n'_percent
	destring Lev`n'_percent, replace force
	replace Lev`n'_percent = Lev`n'_percent/100
	gen Lev`n'_count = Lev`n'_percent * num
	replace Lev`n'_count = round(Lev`n'_count)
	tostring Lev`n'_percent, replace format("%6.0g") force
	replace Lev`n'_percent = "*" if Lev`n'_pct == "**"
	replace Lev`n'_percent = "--" if Lev`n'_pct == "--"
	tostring Lev`n'_count, replace
	replace Lev`n'_count = "*" if Lev`n'_pct == "**"
	replace Lev`n'_count = "--" if Lev`n'_pct == "--"
	replace Lev`n'_count = "--" if StudentSubGroup_TotalTested == "--" & Lev`n'_count != "*"
}

replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""
gen Prof_pct = ProficientOrAbove_percent
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
gen ProficientOrAbove_count = ProficientOrAbove_percent * num
replace ProficientOrAbove_count = round(ProficientOrAbove_count)
tostring ProficientOrAbove_percent, replace format("%6.0g") force
replace ProficientOrAbove_percent = "*" if Prof_pct == "**"
replace ProficientOrAbove_percent = "--" if Prof_pct == "--"
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "*" if Prof_pct == "**"
replace ProficientOrAbove_count = "--" if Prof_pct == "--"
replace ProficientOrAbove_count = "--" if StudentSubGroup_TotalTested == "--" & ProficientOrAbove_count != "*"

drop Lev1_pct Lev2_pct Lev3_pct Lev4_pct Prof_pct num _merge

//StudentGroup_TotalTested Convention
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen All_Students = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace All_Students = All_Students[_n-1] if missing(All_Students)
replace StudentGroup_TotalTested = All_Students 

replace DistName = "McDowell" if DistName == "Mcdowell"

//Getting rid of empty observations
drop if StudentSubGroup_TotalTested == "--" & Lev1_percent == "--" & Lev2_percent == "--" & Lev3_percent == "--" & Lev4_percent == "--" & ProficientOrAbove_percent == "--"
replace ParticipationRate = "--" if ParticipationRate == "."

//Removing extra spaces
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var') // collapses all consecutive, internal blanks to one blank.
	replace `var' = strtrim(`var') // removes leading and trailing blanks
}

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$data/WV_AssmtData_2022", replace
export delimited "$data/WV_AssmtData_2022", replace

clear
