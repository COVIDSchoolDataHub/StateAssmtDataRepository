//2014-15
import excel "$data/WV_OriginalData_1521_all.xlsx", sheet("SY15 School & District") clear

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
drop BY BZ CA CB CC CD CE CF CG CH CI CJ

drop if StateAssignedDistID == ""
drop if StateAssignedDistID == "District"
drop if StateAssignedDistID == "** Indicates that the rate has been suppressed due to a very small student count at the subgroup level. "
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
gen SchYear = "2014-15"
gen AssmtName = "Smarter Balanced Assessment Consortium"
gen AssmtType = "Regular"
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficiencyCriteria = "Levels 3-4"
gen AvgScaleScore = "--"
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "Not applicable"

//Student Groups
replace StudentGroup = "All Students" if StudentGroup == "Total Population"
replace StudentSubGroup = "All Students" if StudentSubGroup == "Total"

replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-racial"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander"

replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"

replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged (Direct Cert.)"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
drop if StudentSubGroup == "Low SES"

replace StudentGroup = "Disability Status" if StudentSubGroup == "Special Education (Students with Disabilities)"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Special Education (Students with Disabilities)"

save "$data/WV_AssmtData_2015", replace

//Clean NCES Data
use "$NCES_School/NCES_2014_School.dta", clear
drop if state_location != "WV"
gen StateAssignedSchID = substr(seasch, 3, 5)
gen StateAssignedDistID = substr(state_leaid, 1, 2)
replace StateAssignedDistID = "0" + StateAssignedDistID
drop if state_leaid == ""
save "$NCES_clean/NCES_2015_School_WV", replace

use "$NCES_Dist/NCES_2014_District.dta", clear
drop if state_location != "WV"
gen StateAssignedDistID = substr(state_leaid, 1,2)
replace StateAssignedDistID = "0" + StateAssignedDistID
save "$NCES_clean/NCES_2015_District_WV", replace

//Merge Data
use "$data/WV_AssmtData_2015", clear
merge m:1 StateAssignedDistID using "$NCES_clean/NCES_2015_District_WV.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES_clean/NCES_2015_School_WV.dta", gen (merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename state_leaid State_leaid
drop _merge merge2

replace StateAbbrev = "WV"
replace StateFips = 54

//Unmerged School - South Preston School
replace NCESSchoolID = "540117001522" if SchName == "South Preston School"
replace SchVirtual = 0 if SchName == "South Preston School"
replace SchLevel = 1 if SchName == "South Preston School"
replace SchType = 1 if SchName == "South Preston School"
replace seasch = "70106" if SchName == "South Preston School"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Student Counts & ParticipationRate
merge 1:1 NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject using "$counts/WV_edfacts2015.dta"
drop if _merge == 2
rename Participation ParticipationRate
replace ParticipationRate = "--" if ParticipationRate == ""
drop if Count == 0 & StudentSubGroup != "All Students" //confirmed that none of these observations have real data
gen StudentSubGroup_TotalTested = string(Count)
replace StudentSubGroup_TotalTested = "--" if _merge == 1
drop _merge

//Deriving State Level Counts
gen dummy = Count
replace dummy = 0 if DataLevel != 2
bysort StudentSubGroup Subject GradeLevel: egen state = total(dummy)
replace Count = state if DataLevel == 1 & state != 0
replace dummy = state if DataLevel == 1 & state != 0
tostring dummy, replace
replace StudentSubGroup_TotalTested = dummy if DataLevel == 1 & Count != .

//StudentGroup_TotalTested
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

//Proficiency Levels
forvalues n = 1/4 {
	replace Lev`n'_percent = "--" if Lev`n'_percent == ""
	gen Lev`n'_pct = Lev`n'_percent
	destring Lev`n'_percent, replace force
	replace Lev`n'_percent = Lev`n'_percent/100
	gen Lev`n'_count = Lev`n'_percent * Count
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
gen ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count))  if !missing(real(Lev3_count)) & !missing(real(Lev4_count))
replace ProficientOrAbove_count = string(round(ProficientOrAbove_percent*Count)) if ProficientOrAbove_count == ""
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == ""
tostring ProficientOrAbove_percent, replace format("%6.0g") force
replace ProficientOrAbove_percent = "*" if Prof_pct == "**"
replace ProficientOrAbove_percent = "--" if Prof_pct == "--"
replace ProficientOrAbove_count = "*" if Prof_pct == "**"
replace ProficientOrAbove_count = "--" if Prof_pct == "--"
replace ProficientOrAbove_count = "--" if StudentSubGroup_TotalTested == "--" & ProficientOrAbove_count != "*"

drop Lev1_pct Lev2_pct Lev3_pct Lev4_pct Prof_pct Count dummy state

//Remove Observations with All Information Missing
drop if Lev1_percent == "--" & Lev2_percent == "--" & Lev3_percent == "--" & Lev4_percent == "--" & ProficientOrAbove_percent == "--" //cases where grade/school combos don't exist
drop if Lev1_percent == "*" & Lev2_percent == "*" & Lev3_percent == "*" & Lev4_percent == "*" & ProficientOrAbove_percent == "*" & StudentSubGroup != "All Students"

//Formatting IDs + School, Dist, & County Names
replace StateAssignedSchID = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == 3 //creates unique school IDs

foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var') // collapses all consecutive, internal blanks to one blank.
	replace `var' = strtrim(`var') // removes leading and trailing blanks
}

replace CountyName = proper(CountyName)
replace DistName = "McDowell" if NCESDistrictID == "5400810"
replace CountyName = "McDowell County" if CountyCode== "54047"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$output/WV_AssmtData_2015", replace
export delimited "$output/WV_AssmtData_2015", replace
