//FILE CREATED 11.27.23
clear all
set more off


cd "/Users/benjaminm/Documents/State_Repository_Research/Nebraska"
global data "/Users/benjaminm/Documents/State_Repository_Research/Nebraska/Original Data Files" 
global counts "/Users/benjaminm/Documents/State_Repository_Research/Nebraska/Counts_2016_2017_2018" 
global NCES "/Users/benjaminm/Documents/State_Repository_Research/NCES"
global output "/Users/benjaminm/Documents/State_Repository_Research/Nebraska/Output" 



//Import and Append Subject Files
import delimited "$data/NE_OriginalData_2021_ela.csv", clear
save "$data/NE_AssmtData_2021.dta", replace

import delimited "$data/NE_OriginalData_2021_mat.csv", clear
save "$data/NE_AssmtData_2021_math.dta", replace

use "$data/NE_AssmtData_2021.dta", clear
append using "$data/NE_AssmtData_2021_math.dta"

//Rename & Generate Variables
rename schoolyear SchYear
rename type DataLevel
rename district StateAssignedDistID
rename school StateAssignedSchID
rename agencyname SchName
rename subject Subject
rename grade GradeLevel
rename category StudentGroup
rename studentsubgroup StudentSubGroup
rename averagescalescore AvgScaleScore
rename basicpct Lev1_percent
rename proficientpct Lev2_percent
rename advancedpct Lev3_percent
gen Lev4_count = ""
gen Lev4_percent = ""
gen Lev5_count = ""
gen Lev5_percent = ""
gen DistName = ""
gen AssmtName = "Nebraska Student-Centered Assessment System (NSCAS)"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "Not applicable"
gen ProficiencyCriteria = "Levels 2-3"
gen ParticipationRate = 1 - nottestedpct
drop dataasof nottestedpct

//School Year
drop if SchYear != "2020-2021"
replace SchYear = "2020-21"

//Data Levels
drop if DataLevel == "LC"
replace DataLevel = "State" if DataLevel == "ST"
replace DataLevel = "District" if StateAssignedSchID == 0 & DataLevel != "State"
replace DataLevel = "School" if DataLevel == "SC" & StateAssignedSchID != 0
replace DistName = SchName if DataLevel == "District"
replace DistName = "All Districts" if DataLevel == "State"
replace SchName = "All Schools" if DataLevel != "School"

local id "county StateAssignedDistID StateAssignedSchID"
foreach var of local id{
	tostring `var', replace
	gen `var'l = strlen(`var')
}

gen seasch = ""
replace seasch = "0" + county + "000" + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 1 & StateAssignedSchIDl == 1
replace seasch = county + "000" + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 1 & StateAssignedSchIDl == 1
replace seasch = "0" + county + "00" + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 2 & StateAssignedSchIDl == 1
replace seasch = county + "00" + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 2 & StateAssignedSchIDl == 1
replace seasch = "0" + county + "0" + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 3 & StateAssignedSchIDl == 1
replace seasch = county + "0" + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 3 & StateAssignedSchIDl == 1
replace seasch = "0" + county + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 4 & StateAssignedSchIDl == 1
replace seasch = county + StateAssignedDistID + "00" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 4 & StateAssignedSchIDl == 1
replace seasch = "0" + county + "000" + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 1 & StateAssignedSchIDl == 2
replace seasch = county + "000" + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 1 & StateAssignedSchIDl == 2
replace seasch = "0" + county + "00" + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 2 & StateAssignedSchIDl == 2
replace seasch = county + "00" + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 2 & StateAssignedSchIDl == 2
replace seasch = "0" + county + "0" + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 3 & StateAssignedSchIDl == 2
replace seasch = county + "0" + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 3 & StateAssignedSchIDl == 2
replace seasch = "0" + county + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 4 & StateAssignedSchIDl == 2
replace seasch = county + StateAssignedDistID + "0" + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 4 & StateAssignedSchIDl == 2
replace seasch = "0" + county + "000" + StateAssignedDistID + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 1 & StateAssignedSchIDl == 3
replace seasch = county + "000" + StateAssignedDistID + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 1 & StateAssignedSchIDl == 3
replace seasch = "0" + county + "00" + StateAssignedDistID + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 2 & StateAssignedSchIDl == 3
replace seasch = county + "00" + StateAssignedDistID + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 2 & StateAssignedSchIDl == 3
replace seasch = "0" + county + "0" + StateAssignedDistID + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 3 & StateAssignedSchIDl == 3
replace seasch = county + "0" + StateAssignedDistID + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 3 & StateAssignedSchIDl == 3
replace seasch = "0" + county + StateAssignedDistID + StateAssignedSchID if countyl == 1 & StateAssignedDistIDl == 4 & StateAssignedSchIDl == 3
replace seasch = county + StateAssignedDistID + StateAssignedSchID if countyl == 2 & StateAssignedDistIDl == 4 & StateAssignedSchIDl == 3
replace seasch = "" if DataLevel != "School"

gen state_leaid = ""
replace state_leaid = "0" + county + "000" + StateAssignedDistID + "000" if countyl == 1 & StateAssignedDistIDl == 1
replace state_leaid = county + "000" + StateAssignedDistID + "000" if countyl == 2 & StateAssignedDistIDl == 1
replace state_leaid = "0" + county + "00" + StateAssignedDistID + "000" if countyl == 1 & StateAssignedDistIDl == 2
replace state_leaid = county + "00" + StateAssignedDistID + "000" if countyl == 2 & StateAssignedDistIDl == 2
replace state_leaid = "0" + county + "0" + StateAssignedDistID + "000" if countyl == 1 & StateAssignedDistIDl == 3
replace state_leaid = county + "0" + StateAssignedDistID + "000" if countyl == 2 & StateAssignedDistIDl == 3
replace state_leaid = "0" + county + StateAssignedDistID + "000" if countyl == 1 & StateAssignedDistIDl == 4
replace state_leaid = county + StateAssignedDistID + "000" if countyl == 2 & StateAssignedDistIDl == 4
replace state_leaid = "" if DataLevel == "State"

replace seasch = state_leaid + "-" + seasch if DataLevel == "School"
replace state_leaid = "NE-" + state_leaid if DataLevel != "State"

drop county countyl StateAssignedDistIDl StateAssignedSchIDl

replace StateAssignedDistID = "" if DataLevel == "State"
replace StateAssignedSchID = "" if DataLevel != "School"

//Grade Levels
drop if GradeLevel == 11
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

//Student Groups & SubGroups
drop if StudentGroup == "Mobile"
replace StudentSubGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Students eligible for free and reduced lunch"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Receiving Free or Reduced Lunch"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentSubGroup = "Military" if StudentSubGroup == "Parent in Military"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Students served in migrant programs"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Special Education Students"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not in Special Education"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
drop if StudentSubGroup == "Special Education Students - Alternate Assessment"


//StudentSubGroup_TotalTested
gen StudentSubGroup_TotalTested = studentcount //Updated 06/17/24 for StudentSubGroup_TotalTested to reflect Student Count rather than StudentCount - nottested
drop studentcount nottested
replace StudentSubGroup_TotalTested =. if StudentSubGroup_TotalTested <0
tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."

//Proficiency Levels
replace Lev1_percent = 1 - (Lev2_percent + Lev3_percent) if Lev1_percent == -1 & Lev2_percent != -1 & Lev3_percent != -1
replace Lev2_percent = 1 - (Lev1_percent + Lev3_percent) if Lev2_percent == -1 & Lev1_percent != -1 & Lev3_percent != -1
replace Lev3_percent = 1 - (Lev1_percent + Lev2_percent) if Lev3_percent == -1 & Lev1_percent != -1 & Lev2_percent != -1

gen ProficientOrAbove_percent = -1
replace ProficientOrAbove_percent = Lev2_percent + Lev3_percent if Lev2_percent != -1 | Lev3_percent != -1

gen ProficientOrAbove_count = ProficientOrAbove_percent * real(StudentSubGroup_TotalTested)
gen Lev1_count = Lev1_percent * real(StudentSubGroup_TotalTested)
gen Lev2_count = Lev2_percent * real(StudentSubGroup_TotalTested)
gen Lev3_count = Lev3_percent * real(StudentSubGroup_TotalTested)

local prof_counts "Lev1_count Lev2_count Lev3_count ProficientOrAbove_count"
foreach var of local prof_counts{
	replace `var' = . if `var' < 0
	replace `var' = round(`var')
	tostring `var', replace
	replace `var' = "*" if `var' == "."
}

replace ProficientOrAbove_percent = . if ProficientOrAbove_percent < 0
tostring ProficientOrAbove_percent, replace format("%6.0g") force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

local prof_vars "Lev1_percent Lev2_percent Lev3_percent AvgScaleScore"
foreach var of local prof_vars {
	tostring `var', replace format("%6.0g") force
	replace `var' = "*" if `var' == "-1"
	replace `var' = "--" if `var' == ""
}



//Subjects
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

save "$data/NE_AssmtData_2021.dta", replace

//Merge NCES Data
merge m:1 state_leaid using "$NCES/NCES_2020_District.dta"
drop if _merge == 2
drop if _merge == 1 & DataLevel == "District"

merge m:1 seasch state_leaid using "$NCES/NCES_2020_School.dta", gen (merge2)
drop if merge2 == 2
save "$data/NE_AssmtData_2021.dta", replace

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

gen State = "Nebraska"
replace StateAbbrev = "NE"
replace StateFips = 31
replace DistName = lea_name if DataLevel == "School"


//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//StudentGroup_TotalTested (Updated 7/24/24 to reflect new convention and in response to state task.)
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

//Deriving StudentSubGroup_TotalTested where possible
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup GradeLevel Subject DistName SchName)
replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & !missing(real(StudentGroup_TotalTested)) & real(StudentGroup_TotalTested) - UnsuppressedSG >=0 & UnsuppressedSG > 0 & StudentGroup != "RaceEth" & StudentSubGroup != "EL Exited" & StudentSubGroup != "All Students"
drop Unsuppressed*

//Weird Lev*_percent Values
foreach var of varlist Lev*_percent {
local count = subinstr("`var'", "percent", "count",.)	
replace `var' = "*" if `count' == "*" & strpos(`var',"e") !=0
replace `var' = "0" if `count' == "0" & strpos(`var', "e") !=0
replace `var' = "--" if `count' == "--" & strpos(`var', "e") !=0
replace `var' = "0" if real(`var') < 0 & `var' != "*" & `var' != "--" //Rounding sometimes leads to negative numbers for level percents
}

//Response to Post-Launch Review
replace DistName = "ISANTI COMMUNITY SCHOOL" if NCESDistrictID == "3176400"

//Fixing StateAssignedDistID
replace StateAssignedDistID = subinstr(State_leaid, "NE-","",.)

//Deriving ProficientOrAbove_percent and ProficientOrAbove_count when we have Lev1_percent
replace ProficientOrAbove_percent = string(1-real(Lev1_percent), "%9.3g") if regexm(Lev1_percent, "[0-9]") !=0 & regexm(ProficientOrAbove_percent, "[0-9]") ==0 
replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent) * real(StudentSubGroup_TotalTested))) if regexm(ProficientOrAbove_count, "[0-9]") == 0 & regexm(ProficientOrAbove_percent, "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0

//Getting ParticipationRate as string for easy combining
gen sParticipationRate = string(ParticipationRate, "%9.3g")
drop ParticipationRate
rename sParticipationRate ParticipationRate
**Process: Setting the ParticipationRate to "*" for the last observation where all values are suppressed
egen allsuppressed = max(_n) if StudentSubGroup_TotalTested == "*" & Lev1_count == "*" & Lev1_percent == "*" & Lev2_count == "*" & Lev2_percent == "*" & Lev3_count == "*" & Lev3_percent == "*" & ProficientOrAbove_count == "*" & ProficientOrAbove_percent == "*" & AvgScaleScore == "*"
levelsof allsuppressed, local(max_n_suppressed)
replace ParticipationRate = "*" in `max_n_suppressed'


foreach var of varlist DistName SchName {
replace `var' = strtrim(`var')
replace `var' = stritrim(`var')
}

replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev2_percent)) if Lev3_percent == "*" & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev2_percent)) 

replace Lev3_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_percent)) if Lev3_count == "*" & !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) 


gen derive_L1_count_lev23 = .
replace derive_L1_count_lev23 = 1 if ProficiencyCriteria== "Levels 2-3" & inlist(Lev1_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--")
replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count)) if derive_L1_count_lev23 == 1

gen derive_L2_count_lev23 = .
replace derive_L2_count_lev23 = 1 if ProficiencyCriteria == "Levels 2-3" & inlist(Lev2_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--") & !inlist(Lev3_count, "*", "--") 
replace Lev2_count = string(real(ProficientOrAbove_count) - real(Lev3_count)) if derive_L2_count_lev23 == 1

gen derive_L3_count_lev23 = .
replace derive_L3_count_lev23 = 1 if ProficiencyCriteria =="Levels 2-3" & inlist(Lev3_count, "*", "--") & !inlist(Lev2_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--")
replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev2_count)) if derive_L3_count_lev23 == 1


replace Lev1_percent = string(1 - real(ProficientOrAbove_percent)) if derive_L1_count_lev23 == 1
replace Lev2_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent)) if derive_L2_count_lev23 == 1
replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev2_percent)) if derive_L3_count_lev23 == 1

replace Lev3_count = string(round(real(Lev3_percent) * real(StudentSubGroup_TotalTested),1)) if Lev3_count == "*" & Lev3_count == "0" & !inlist(StudentSubGroup_TotalTested, "*", "--")

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$output/NE_AssmtData_2021.dta", replace
export delimited "$output/NE_AssmtData_2021.csv", replace
clear


