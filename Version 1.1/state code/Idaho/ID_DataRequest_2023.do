// Idaho Cleaning 

clear

// Define file paths

global original_files "/Users/meghancornacchia/Desktop/DataRepository/Idaho/Original_Data_Files"
global NCES_files "/Users/meghancornacchia/Desktop/DataRepository/NCES_Data_Files"
global output_files "/Users/meghancornacchia/Desktop/DataRepository/Idaho/Output_Data_Files"
global temp_files "/Users/meghancornacchia/Desktop/DataRepository/Idaho/Temporary_Data_Files"

// 2022-2023
/*
import excel "$original_files/ID_OriginalData_2023.xlsx", sheet("State Of Idaho") firstrow clear
gen DataLevel = "State"
save "${temp_files}/ID_AssmtData_2023_state.dta", replace

import excel "$original_files/ID_OriginalData_2023.xlsx", sheet("Districts") firstrow clear
gen DataLevel = "District"
save "${temp_files}/ID_AssmtData_2023_district.dta", replace

import excel "$original_files/ID_OriginalData_2023.xlsx", sheet("Schools") firstrow clear
gen DataLevel = "School"
save "${temp_files}/ID_AssmtData_2023_school.dta", replace

clear

append using "${temp_files}/ID_AssmtData_2023_state.dta" "${temp_files}/ID_AssmtData_2023_district.dta" "${temp_files}/ID_AssmtData_2023_school.dta"

save "${temp_files}/ID_AssmtData_2023_all.dta", replace
*/
// Renaming Variables

use "${temp_files}/ID_AssmtData_2023_all.dta", clear

rename SubjectName Subject
rename Grade GradeLevel
rename Population StudentSubGroup
rename Advanced Lev4_count
rename AdvancedRate	Lev4_percent
rename Proficient Lev3_count
rename ProficientRate Lev3_percent
rename Basic Lev2_count
rename BasicRate Lev2_percent
rename BelowBasic Lev1_count
rename BelowBasicRate Lev1_percent
rename Tested StudentSubGroup_TotalTested
rename TestedRate ParticipationRate
rename DistrictId StateAssignedDistID
rename DistrictName DistName
rename SchoolId StateAssignedSchID
rename SchoolName SchName
drop ParticipationDenominator
drop ProficiencyDenominator

// Dropping irrelevant Observations
drop if Lev1_percent == "N/A"
drop if StudentSubGroup == "Students with Disabilities"
drop if StudentSubGroup == "Students without Disabilities"
drop if StudentSubGroup == "Migrant"
drop if StudentSubGroup == "Homeless"
drop if StudentSubGroup == "Foster"
drop if StudentSubGroup == "Military Connected"
drop if GradeLevel == "High School"
drop if GradeLevel == "All Grades"

// StudentSubGroup
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup,"Asian") !=0
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup,"Black") !=0
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Economically Disadvantaged "
replace StudentSubGroup = "Not Economically Disadvantaged" if strpos(StudentSubGroup, "Not Economically Disadvantaged") !=0
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "American Indian or Alaskan Native") !=0
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not LEP"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two Or More") !=0

// StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"

// GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ","",.)
keep if GradeLevel == "3" | GradeLevel == "4" | GradeLevel == "5" | GradeLevel == "6" | GradeLevel == "7" | GradeLevel == "8"
replace GradeLevel = "G0" + GradeLevel

// DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3


//Proficient or above percent and Dealing with ranges

gen missing = ""
foreach n in 1 2 3 4 {
	gen Range`n' = ""
}
foreach n in 1 2 3 4 {
	gen Suppressed`n' = "*" if strpos(Lev`n'_percent,"*") !=0 | strpos(Lev`n'_percent, "NSIZE") !=0
	replace Range`n' = ">" if strpos(Lev`n'_percent, ">") !=0
	replace Range`n' = "<" if strpos(Lev`n'_percent, "<") !=0
	replace missing = "Y" if Lev`n'_percent == "N/A"
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*NSIZE/A<>)
	replace nLev`n'_percent = nLev`n'_percent/100
	replace Lev`n'_percent = Range`n' + string(nLev`n'_percent, "%9.4f")
	replace Lev`n'_percent = "*" if Suppressed`n' == "*"
	replace Lev`n'_percent = "--" if missing == "Y"

}
gen ProficientOrAbove_percent = string(nLev3_percent + nLev4_percent, "%9.4f")
replace ProficientOrAbove_percent = "*" if Suppressed3 == "*" | Suppressed4 == "*"
replace ProficientOrAbove_percent = "*" if Range3 != Range4 & !missing(Range3) & !missing(Range4)
replace ProficientOrAbove_percent = Range3 + ProficientOrAbove_percent if !missing(Range3) & missing(Range4)
replace ProficientOrAbove_percent = Range4 + ProficientOrAbove_percent if !missing(Range4) & missing(Range3)
replace ProficientOrAbove_percent = Range3 + ProficientOrAbove_percent if Range3==Range4
destring ProficientOrAbove_percent, gen(ind) i(*-<>)
replace ind = 1 if ind > 1 & !missing(ind)
replace ProficientOrAbove_percent = "<=1.000" if ind == 1
drop ind
replace ProficientOrAbove_percent = "--" if missing== "Y"
replace ParticipationRate = "--" if ParticipationRate == "N/A"
replace ParticipationRate = "*" if ParticipationRate == "NSIZE" | strpos(ParticipationRate, "*") !=0
gen PartRange = "Y" if strpos(ParticipationRate,">") !=0
destring ParticipationRate, gen(Part) i(*->)
replace Part = Part/100
replace ParticipationRate = string(Part, "%9.4f") if !missing(Part)
replace ParticipationRate = ">"+ParticipationRate if PartRange == "Y"
drop PartRange
generate ProficientOrAbove_count = Lev3_count + Lev4_count
foreach n in 1 2 3 4 {
replace Lev`n'_percent = "--" if Lev`n'_percent == "*" & (Suppressed1 != Suppressed2 | Suppressed3 != Suppressed4 | Suppressed2 != Suppressed3)
tostring Lev`n'_count, replace force
replace Lev`n'_count = "*" if Lev`n'_count == "."
replace Lev`n'_count = "--" if Lev`n'_percent == "--"
}
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if Lev3_count == "*" | Lev4_count == "*"
replace ParticipationRate = "--" if Lev1_percent == "--" & Lev2_percent == "--" & Lev3_percent == "--" & Lev4_percent == "--"
replace ProficientOrAbove_count = "--" if Lev3_percent == "--" | Lev4_percent == "--"
drop Part

// Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

// Missing Variables
gen State = "Idaho"
gen SchYear = "2022-23"
gen Lev5_percent = ""
gen Lev5_count = ""
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3 and 4"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"
gen AssmtName = "ISAT"
gen AssmtType = "Regular"
gen state_leaid = "ID-"+StateAssignedDistID
gen seasch = StateAssignedDistID+"-"+StateAssignedSchID

// Generating Student Group Counts
bysort state_leaid seasch StudentGroup Grade Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

// Saving transformed data
save "${output_files}/ID_AssmtData_2023.dta", replace

// Merging with NCES School Data

use "$NCES_files/NCES_2021_School.dta", clear 

keep state_location state_fips district_agency_type school_type ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code

drop if seasch == ""

keep if substr(ncesschoolid, 1, 2) == "16"

merge 1:m seasch using "${output_files}/ID_AssmtData_2023.dta", keep(match using)

save "${output_files}/ID_AssmtData_2023.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES_2021_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code

keep if substr(ncesdistrictid, 1, 2) == "16"

merge 1:m state_leaid using "${output_files}/ID_AssmtData_2023.dta", keep(match using) nogenerate

// Removing extra variables and renaming NCES variables
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename state_location StateAbbrev
rename county_code CountyCode
rename school_type SchType
rename state_fips StateFips
rename county_name CountyName
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth _merge

//Fixing Unmerged
replace NCESSchoolID = "160219001178" if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace NCESDistrictID = "1602190" if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace State_leaid = "ID-331" if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace seasch = "331-1495" if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace DistCharter = "No" if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace SchType = 4 if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace DistType = 1 if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace CountyName = "Minidoka County" if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace CountyCode = 16067 if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace SchLevel = 2 if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace SchVirtual = 0 if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"

replace NCESSchoolID = "160093001171" if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace NCESDistrictID = "1600930" if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace State_leaid = "ID-093" if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace seasch = "093-1482" if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace DistCharter = "No" if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace SchType = 1 if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace DistType = 1 if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace CountyName = "Bonneville County" if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace CountyCode = 16019 if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace SchLevel = 2 if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace SchVirtual = 0 if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"

replace NCESSchoolID = "160309001177" if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace NCESDistrictID = "1603090" if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace State_leaid = "ID-322" if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace seasch = "322-1483" if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace DistCharter = "No" if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace SchType = 1 if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace DistType = 1 if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace CountyName = "Madison County" if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace CountyCode = 16065 if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace SchLevel = -1 if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace SchVirtual = 1 if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"

replace NCESSchoolID = "160225001174" if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace NCESDistrictID = "1602250" if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace State_leaid = "ID-193" if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace seasch = "193-1494" if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace DistCharter = "No" if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace SchType = 4 if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace DistType = 1 if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace CountyName = "Elmore County" if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace CountyCode = 16039 if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace SchLevel = 2 if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace SchVirtual = 0 if _merge == 2 & SchName == "TIGER LEARN PROGRAM"

//SchVirtual for Select Schools
label define SchVirtual -1 "Missing/not reported", add
replace SchVirtual = 1 if SchName == "COEUR D'ALENE VIRTUAL ACADMEY"
replace SchVirtual = -1 if SchName == "ELEVATE ACADEMY NAMPA"
replace SchVirtual = -1 if SchName == "ELEVATE ACADEMY NORTH"
replace SchVirtual = -1 if SchName == "GEM PREP: MERIDIAN SOUTH"
replace SchVirtual = -1 if SchName == "MOUNTAIN COMMUNITY SCHOOL"
replace SchVirtual = 1 if SchName == "IDAHO FUTURE READY ACADEMY FOR VIRTUAL LEARNING"

drop _merge

// Fixing missing state data
replace StateAbbrev = "ID" if DataLevel == 1
replace StateFips = 16 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
replace seasch = "" if DataLevel != 3
replace State_leaid = "" if DataLevel == 1

// Dropping not ID data
drop if StateAbbrev != "ID"

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/ID_AssmtData_2023.dta", replace
export delimited using "$output_files/ID_AssmtData_2023.csv", replace

