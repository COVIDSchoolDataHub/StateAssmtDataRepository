clear all
set maxvar 10000
// Define file paths

global original_files "/Users/miramehta/Documents/TX State Testing Data/Original"
global NCES_files "/Users/miramehta/Documents/NCES District and School Demographics"
global output_files "/Users/miramehta/Documents/TX State Testing Data/Output"
global temp_files "/Users/miramehta/Documents/TX State Testing Data/Temp"

*Unhide on first run to import .csv files
/*
foreach lev in "School" "District" "State"{
	import delimited "$original_files/TX_OriginalData_2022_`lev'", clear
	gen DataLevel = "`lev'"
	save "$temp_files/TX_OriginalData_2022_`lev'", replace
}

append using "$temp_files/TX_OriginalData_2022_District" "$temp_files/TX_OriginalData_2022_School"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

save "$temp_files/TX_OriginalData_2022", replace
*/
use "$temp_files/TX_OriginalData_2022", clear
keep if administration == "Spring 2022"
duplicates drop

//Identifying Information
rename testedgrade GradeLevel
rename studentgroup StudentSubGroup
drop administration
tostring idcdc, replace
gen StateAssignedDistID = idcdc if DataLevel == 2
replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 5
replace StateAssignedDistID = "00" + StateAssignedDistID if strlen(StateAssignedDistID) == 4
gen StateAssignedSchID = idcdc if DataLevel == 3
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 8
replace StateAssignedSchID = "00" + StateAssignedSchID if strlen(StateAssignedSchID) == 7
replace StateAssignedDistID = substr(StateAssignedSchID, 1, 6) if DataLevel == 3
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
gen DistName = organization if DataLevel == 2
gen SchName = organization if DataLevel == 3
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3
drop idcdc organization

//Renaming & Reshaping Performance Information
rename staarmathematicsteststaken StudentSubGroup_TotalTestedE1
rename staarmathematicsaveragescalescor AvgScaleScoreE1
rename staarmathematicsperformancelevel Lev1_countE1
rename v9 Lev1_percentE1
rename v10 Lev2_above_countE1
rename v11 Lev2_above_percentE1
rename v12 ProficientOrAbove_countE1
rename v13 ProficientOrAbove_percentE1
rename v14 Lev4_countE1
rename v15 Lev4_percentE1
rename staarspanishmathematicsteststake StudentSubGroup_TotalTestedS1
rename staarspanishmathematicsaveragesc AvgScaleScoreS1
rename staarspanishmathematicsperforman Lev1_countS1
rename v19 Lev1_percentS1
rename v20 Lev2_above_countS1
rename v21 Lev2_above_percentS1
rename v22 ProficientOrAbove_countS1
rename v23 ProficientOrAbove_percentS1
rename v24 Lev4_countS1
rename v25 Lev4_percentS1
rename staarreadingteststaken StudentSubGroup_TotalTestedE2
rename staarreadingaveragescalescore AvgScaleScoreE2
rename staarreadingperformancelevelsdid Lev1_countE2
rename v29 Lev1_percentE2
rename staarreadingperformancelevelsapp Lev2_above_countE2
rename v31 Lev2_above_percentE2
rename staarreadingperformancelevelsmee ProficientOrAbove_countE2
rename v33 ProficientOrAbove_percentE2
rename staarreadingperformancelevelsmas Lev4_countE2
rename v35 Lev4_percentE2
rename staarspanishreadingteststaken StudentSubGroup_TotalTestedS2
rename staarspanishreadingaveragescales AvgScaleScoreS2
rename staarspanishreadingperformancele Lev1_countS2
rename v39 Lev1_percentS2
rename v40 Lev2_above_countS2
rename v41 Lev2_above_percentS2
rename v42 ProficientOrAbove_countS2
rename v43 ProficientOrAbove_percentS2
rename v44 Lev4_countS2
rename v45 Lev4_percentS2
rename staarscienceteststaken StudentSubGroup_TotalTestedE3
rename staarscienceaveragescalescore AvgScaleScoreE3
rename staarscienceperformancelevelsdid Lev1_countE3
rename v49 Lev1_percentE3
rename staarscienceperformancelevelsapp Lev2_above_countE3
rename v51 Lev2_above_percentE3
rename staarscienceperformancelevelsmee ProficientOrAbove_countE3
rename v53 ProficientOrAbove_percentE3
rename staarscienceperformancelevelsmas Lev4_countE3
rename v55 Lev4_percentE3
rename staarspanishscienceteststaken StudentSubGroup_TotalTestedS3
rename staarspanishscienceaveragescales AvgScaleScoreS3
rename staarspanishscienceperformancele Lev1_countS3
rename v59 Lev1_percentS3
rename v60 Lev2_above_countS3
rename v61 Lev2_above_percentS3
rename v62 ProficientOrAbove_countS3
rename v63 ProficientOrAbove_percentS3
rename v64 Lev4_countS3
rename v65 Lev4_percentS3
rename staarsocialstudiesteststaken StudentSubGroup_TotalTestedE4
rename staarsocialstudiesaveragescalesc AvgScaleScoreE4
rename staarsocialstudiesperformancelev Lev1_countE4
rename v69 Lev1_percentE4
rename v70 Lev2_above_countE4
rename v71 Lev2_above_percentE4
rename v72 ProficientOrAbove_countE4
rename v73 ProficientOrAbove_percentE4
rename v74 Lev4_countE4
rename v75 Lev4_percentE4

replace AvgScaleScoreS2 = subinstr(AvgScaleScoreS2, "S-", "", .)
destring AvgScaleScoreS2, replace

reshape long StudentSubGroup_TotalTested AvgScaleScore Lev1_count Lev1_percent Lev2_above_count Lev2_above_percent ProficientOrAbove_count ProficientOrAbove_percent Lev4_count Lev4_percent, i(DataLevel DistName SchName StateAssignedDistID StateAssignedSchID GradeLevel StudentSubGroup) j(Subject) string

//Assessment Information
gen SchYear = "2021-22"
gen State = "Texas"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"
gen ParticipationRate = "--"
gen AssmtName = "STAAR - English"
replace AssmtName = "STAAR - Spanish" if strpos(Subject, "S") == 1
replace Subject = "math" if strpos(Subject, "1") == 2
replace Subject = "ela" if strpos(Subject, "2") == 2
replace Subject = "sci" if strpos(Subject, "3") == 2
replace Subject = "soc" if strpos(Subject, "4") == 2
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel
gen ProficiencyCriteria = "Levels 3-4"

//Removing Empty Observations
drop if Subject == "sci" & !inlist(GradeLevel, "G05", "G08")
drop if Subject == "soc" & GradeLevel != "G08"

//Deriving & Formatting Performance Information
gen Lev2_count = Lev2_above_count - ProficientOrAbove_count
gen Lev2_percent = Lev2_above_percent - ProficientOrAbove_percent
gen Lev3_count = ProficientOrAbove_count - Lev4_count
gen Lev3_percent = ProficientOrAbove_percent - Lev4_percent

forvalues n = 1/4{
	replace Lev`n'_percent = Lev`n'_percent/100
	tostring Lev`n'_percent, replace format("%9.2g") force
	replace Lev`n'_percent = "--" if Lev`n'_percent == "."
	tostring Lev`n'_count, replace
	replace Lev`n'_count = "--" if Lev`n'_count == "."
}

replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
replace Lev2_above_percent = Lev2_above_percent/100
tostring ProficientOrAbove_percent, replace format("%9.2g") force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
tostring Lev2_above_percent, replace format("%9.2g") force
replace Lev2_above_percent = "--" if Lev2_above_percent == "."
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
tostring Lev2_above_count, replace
replace Lev2_above_count = "--" if Lev2_above_count == "."
rename Lev2_above_count ApproachingOrAbove_count
rename Lev2_above_percent ApproachingOrAbove_percent

gen Lev5_count = ""
gen Lev5_percent = ""

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."

//AvgScaleScore
tostring AvgScaleScore, replace
replace AvgScaleScore = "--" if AvgScaleScore == "."

//StudentSubGroup & StudentGroup
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "No Ethnicity Provided"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Special Education"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not Special Education"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Current EB/EL"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Other Non-EB/EL"
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "Non-EB/EL (Monitored 1st Year)"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient", "EL Monit or Recently Ex")
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male", "No Gender Provided")
replace StudentSubGroup = "Unknown" if StudentSubGroup == "No Gender Provided"
replace StudentGroup = "Migrant Status" if inlist(StudentSubGroup, "Migrant", "Non-Migrant")
replace StudentGroup = "RaceEth" if inlist(StudentSubGroup, "American Indian or Alaska Native", "Asian", "Black or African American", "Hispanic or Latino", "Native Hawaiian or Pacific Islander", "Two or More", "Unkown", "White")
drop if StudentGroup == ""

//StudentGroup_TotalTested
replace DistName = strtrim(DistName)
replace DistName = stritrim(DistName)
replace SchName = strtrim(SchName)
replace SchName = stritrim(SchName)
sort DataLevel AssmtName StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"

//Remove Null Observations
drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"
gen flag = 1
forvalues n = 1/4 {
	replace flag = 0 if Lev`n'_count != "--"
}
drop if flag == 1 & inlist(StudentSubGroup_TotalTested, "*", "--") & StudentSubGroup != "All Students"
drop flag

//Prepare to Merge with NCES
gen state_leaid = "TX-" + StateAssignedDistID
gen seasch = state_leaid + "-" + StateAssignedSchID
replace seasch = subinstr(seasch, "TX-", "", 1)
save "$temp_files/TX_AssmtData_2022", replace

use "$NCES_files/NCES District Files, Fall 1997-Fall 2022/NCES_2021_District.dta", clear
keep if state_location == "TX"
rename district_agency_type DistType
keep state_location state_fips DistType ncesdistrictid state_leaid DistCharter county_name county_code DistLocale
save "$NCES_files/Cleaned NCES Data/NCES_2021_District_TX.dta", replace

use "$NCES_files/NCES School Files, Fall 1997-Fall 2022/NCES_2021_School.dta", clear
keep if state_location == "TX"
rename district_agency_type DistType
keep state_location state_fips lea_name ncesschoolid state_leaid seasch SchLevel SchVirtual SchType
save "$NCES_files/Cleaned NCES Data/NCES_2021_School_TX.dta", replace

//Merge with NCES Data
use "$temp_files/TX_AssmtData_2022", clear
merge m:1 state_leaid using "$NCES_files/Cleaned NCES Data/NCES_2021_District_TX.dta"
drop if _merge == 2
drop _merge

merge m:1 state_leaid seasch using "$NCES_files/Cleaned NCES Data/NCES_2021_School_TX.dta"
drop if _merge == 2
drop _merge

//Cleaning from NCES Info
rename state_location StateAbbrev
rename state_fips_id StateFips
rename ncesdistrictid NCESDistrictID
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode

replace DistName = strtrim(lea_name) if DataLevel == 3
drop lea_name

replace StateAbbrev = "TX"
replace StateFips = 48

//Final Cleaning
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode ApproachingOrAbove_count ApproachingOrAbove_percent

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode ApproachingOrAbove_count ApproachingOrAbove_percent

sort DataLevel DistName SchName AssmtName Subject GradeLevel StudentGroup StudentSubGroup

save "${output_files}/TX_AssmtData_2022 - HMH.dta", replace
export delimited "${output_files}/TX_AssmtData_2022 - HMH.csv", replace

drop ApproachingOrAbove_count ApproachingOrAbove_percent

save "${output_files}/TX_AssmtData_2022.dta", replace
export delimited "${output_files}/TX_AssmtData_2022.csv", replace
