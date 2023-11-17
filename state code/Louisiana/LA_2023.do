clear
global path "/Users/willtolmie/Documents/State Repository Research/Louisiana"
global nces "/Users/willtolmie/Documents/State Repository Research/NCES"

** 2021-22 NCES School Data

use "${nces}/School/NCES_2021_School.dta"

** Rename Variables

rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename lea_name DistName
rename school_type SchType

** Drop Excess Variables

drop year district_agency_type district_agency_type_num county_code county_name school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch dist_lowest_grade_offered dist_highest_grade_offered sch_lowest_grade_offered sch_highest_grade_offered

** Fix Variable Types

decode State, gen(State2)
decode SchLevel, gen(SchLevel2)
decode SchType, gen(SchType2)
decode SchVirtual, gen(SchVirtual2)
drop State SchLevel SchType SchVirtual
rename State2 State
rename SchLevel2 SchLevel 
rename SchType2 SchType 
rename SchVirtual2 SchVirtual
tostring seasch, replace force

** Isolate Louisiana Data

drop if StateFips != 22
save "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_School.dta", replace

** 2021-22 NCES District Data

use "${nces}/District/NCES_2021_District.dta"

** Rename Variables

rename ncesdistrictid NCESDistrictID
rename state_name State
rename state_leaid State_leaid
rename state_location StateAbbrev
rename county_code CountyCode
rename county_name CountyName
rename district_agency_type DistType
rename state_fips StateFips

** Drop Excess Variables

drop year lea_name urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type_num lowest_grade_offered highest_grade_offered

** Fix Variable Types

decode State, gen(State2)
decode DistType, gen(DistType2)
drop State DistType
rename DistType2 DistType
rename State2 State

* Isolate Louisiana Data

drop if StateFips != 22
save "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_District.dta", replace

** 2022-23 Proficiency Data

import excel "${path}/Original Data Files/LA_OriginalData_2023_state.xlsx", sheet("Grades 3-8") cellrange(A4:AF74738) firstrow clear

rename EnglishLanguageArts Lev5_percentela
rename I Lev4_percentela
rename J Lev3_percentela
rename K Lev2_percentela
rename L Lev1_percentela

rename Mathematics Lev5_percentmath
rename N Lev4_percentmath
rename O Lev3_percentmath
rename P Lev2_percentmath
rename Q Lev1_percentmath

rename Science Lev5_percentsci
rename S Lev4_percentsci
rename T Lev3_percentsci
rename U Lev2_percentsci
rename V Lev1_percentsci

rename SocialStudies Lev5_percentsoc
rename X Lev4_percentsoc
rename Y Lev3_percentsoc
rename Z Lev2_percentsoc
rename AA Lev1_percentsoc

keep if SchoolSystemName == "Louisiana Statewide"

save "${path}/Semi-Processed Data Files/LA_OriginalData_2023_state.dta", replace

import excel "${path}/Original Data Files/LA_OriginalData_2023_all.xls", sheet("2023 LEAP SUPPRESSED") cellrange(A3:BH65536) firstrow allstring clear

rename ELA AvgScaleScoreela
rename Math AvgScaleScoremath
rename Science AvgScaleScoresci
rename SocialStudies AvgScaleScoresoc

rename TotalStudentTested StudentSubGroup_TotalTestedela
rename Advanced Lev5_countela
rename P Lev5_percentela
rename Mastery Lev4_countela
rename R Lev4_percentela
rename Basic Lev3_countela
rename T Lev3_percentela
rename ApproachingBasic Lev2_countela
rename V Lev2_percentela
rename Unsatisfactory Lev1_countela
rename X Lev1_percentela

rename Y StudentSubGroup_TotalTestedmath
rename Z Lev5_countmath
rename AA Lev5_percentmath
rename AB Lev4_countmath
rename AC Lev4_percentmath
rename AD Lev3_countmath
rename AE Lev3_percentmath
rename AF Lev2_countmath
rename AG Lev2_percentmath
rename AH Lev1_countmath
rename AI Lev1_percentmath

rename AJ StudentSubGroup_TotalTestedsci
rename AK Lev5_countsci
rename AL Lev5_percentsci
rename AM Lev4_countsci
rename AN Lev4_percentsci
rename AO Lev3_countsci
rename AP Lev3_percentsci
rename AQ Lev2_countsci
rename AR Lev2_percentsci
rename AS Lev1_countsci
rename AT Lev1_percentsci

rename AU StudentSubGroup_TotalTestedsoc
rename AV Lev5_countsoc
rename AW Lev5_percentsoc
rename AX Lev4_countsoc
rename AY Lev4_percentsoc
rename AZ Lev3_countsoc
rename BA Lev3_percentsoc
rename BB Lev2_countsoc
rename BC Lev2_percentsoc
rename BD Lev1_countsoc
rename BE Lev1_percentsoc

append using "${path}/Semi-Processed Data Files/LA_OriginalData_2023_state.dta"

** Reshape Wide to Long

generate id = _n
reshape long Lev1_percent Lev1_count Lev2_percent Lev2_count Lev3_percent Lev3_count Lev4_percent Lev4_count Lev5_percent Lev5_count StudentSubGroup_TotalTested AvgScaleScore, i(id) j(Subject, string)
drop id
gen DataLevel = "School"
replace DataLevel = "District" if SchoolName == ""
replace DataLevel = "State" if SchoolSystemName == "Louisiana Statewide"

** Rename Variables

rename SchoolSystemCode StateAssignedDistID
rename SchoolSystemName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName
rename Grade GradeLevel
rename Subgroup StudentSubGroup

* Generate StudentGroup Values

save "${path}/Semi-Processed Data Files/TN_2023_nogroup.dta", replace
keep if StudentSubGroup=="Total Population"
keep DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested StudentGroup_TotalTested
save "${path}/Semi-Processed Data Files/TN_2023_group.dta", replace
clear
use "${path}/Semi-Processed Data Files/TN_2023_nogroup.dta"
merge m:1 DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel using "${path}/Semi-Processed Data Files/TN_2023_group.dta"
drop _merge
replace StudentGroup_TotalTested="--" if StudentGroup_TotalTested == ""
save "${path}/Semi-Processed Data Files/TN_2023_all.dta", replace

** Generate Flags

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

** Fix Variable Types

replace Lev1_percent = subinstr(Lev1_percent, " ", "", .)
replace Lev2_percent = subinstr(Lev2_percent, " ", "", .)
replace Lev3_percent = subinstr(Lev3_percent, " ", "", .)
replace Lev4_percent = subinstr(Lev4_percent, " ", "", .)
replace Lev5_percent = subinstr(Lev5_percent, " ", "", .)
replace Lev1_percent = subinstr(Lev1_percent, "%", "", .)
replace Lev2_percent = subinstr(Lev2_percent, "%", "", .)
replace Lev3_percent = subinstr(Lev3_percent, "%", "", .)
replace Lev4_percent = subinstr(Lev4_percent, "%", "", .)
replace Lev5_percent = subinstr(Lev5_percent, "%", "", .)

** Generate Other Variables

gen SchYear = "2022-23"
gen AssmtName = "LEAP 2025"
gen AssmtType = "Regular"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup=="Hispanic/Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup=="Two or more races" | StudentSubGroup=="Two or More Races"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian/Other Pacific Islander"
replace StudentSubGroup = "All Students" if StudentSubGroup=="Total Population"
replace StudentSubGroup = "English Proficient" if StudentSubGroup=="Not English Learner"
gen StudentGroup = "RaceEth" if StudentSubGroup=="American Indian or Alaska Native" | StudentSubGroup=="Asian" | StudentSubGroup=="Black or African American" | StudentSubGroup=="Native Hawaiian or Pacific Islander" | StudentSubGroup=="Two or More" | StudentSubGroup=="White" | StudentSubGroup=="Hispanic or Latino"
replace StudentGroup = "EL Status" if StudentSubGroup=="English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Gender" if StudentSubGroup=="Female" | StudentSubGroup=="Male"
replace StudentGroup = "All Students" if StudentSubGroup=="All Students"
replace StudentGroup = "Economic Status" if StudentSubGroup=="Economically Disadvantaged" | StudentSubGroup=="Not Economically Disadvantaged"
keep if StudentGroup == "All Students" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender" | StudentGroup == "RaceEth"
gen ProficiencyCriteria = "Levels 4 and 5"
replace AvgScaleScore = "--" if AvgScaleScore == ""
replace StudentSubGroup_TotalTested="--" if StudentSubGroup_TotalTested == ""

** Convert Proficiency Data into Percentages

foreach v of varlist Lev*_percent {
	destring `v', g(n`v') i(* -) force
	replace n`v' = n`v' / 100 if n`v' != .
	generate lessthan`v' = 1 if `v'=="<5"
	generate greaterthan`v' = 1 if `v'==">95"
	tostring n`v', replace force
	replace `v' = n`v' if `v' != "*"
	replace `v' = "0-0.05" if lessthan`v' == 1
	replace `v' = "0.95-1" if greaterthan`v' == 1
}
** Generate Proficient or Above Percent

gen Lev4max = Lev4_percent
replace Lev4max = ".05" if Lev4_percent== "0-0.05"
replace Lev4max = "1" if Lev4_percent== "0.95-1"
destring Lev4max, generate(Lev4maxnumber) force
gen Lev4min = Lev4_percent
replace Lev4min = "0" if Lev4_percent== "0-0.05"
replace Lev4min = "0.95" if Lev4_percent== "0.95-1"
destring Lev4min, generate(Lev4minnumber) force
gen Lev5max = Lev5_percent
replace Lev5max = ".05" if Lev5_percent== "0-0.05"
replace Lev5max = "1" if Lev5_percent== "0.95-1"
destring Lev5max, generate(Lev5maxnumber) force
gen Lev5min = Lev5_percent
replace Lev5min = "0" if Lev5_percent== "0-0.05"
replace Lev5min = "0.95" if Lev5_percent== "0.95-1"
destring Lev5min, generate(Lev5minnumber) force
gen ProficientOrAbovemin = Lev4minnumber + Lev5minnumber
gen ProficientOrAbovemax = Lev4maxnumber + Lev5maxnumber
tostring ProficientOrAbovemin, replace force
tostring ProficientOrAbovemax, replace force
gen ProficientOrAbove_percent = ProficientOrAbovemin + "-" + ProficientOrAbovemax
replace ProficientOrAbove_percent = ProficientOrAbovemax if ProficientOrAbovemax == ProficientOrAbovemin
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="."
drop Lev4max Lev4maxnumber Lev4min Lev4minnumber Lev5max Lev5maxnumber Lev5min Lev5minnumber ProficientOrAbovemin ProficientOrAbovemax

** Generate Proficient or Above Count

gen Lev4max = Lev4_count
replace Lev4max = "10" if Lev4_count== "<10"
destring Lev4max, generate(Lev4maxnumber) force
gen Lev4min = Lev4_count
replace Lev4min = "0" if Lev4_count== "<10"
destring Lev4min, generate(Lev4minnumber) force
gen Lev5max = Lev5_count
replace Lev5max = "10" if Lev5_count== "<10"
destring Lev5max, generate(Lev5maxnumber) force
gen Lev5min = Lev5_count
replace Lev5min = "0" if Lev5_count== "<10"
destring Lev5min, generate(Lev5minnumber) force
gen ProficientOrAbovemin = Lev4minnumber + Lev5minnumber
gen ProficientOrAbovemax = Lev4maxnumber + Lev5maxnumber
tostring ProficientOrAbovemin, replace force
tostring ProficientOrAbovemax, replace force
gen ProficientOrAbove_count = ProficientOrAbovemin + "-" + ProficientOrAbovemax
replace ProficientOrAbove_count = ProficientOrAbovemax if ProficientOrAbovemax == ProficientOrAbovemin
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count=="."
replace Lev1_percent = "*" if Lev1_percent=="."
replace Lev2_percent = "*" if Lev2_percent=="."
replace Lev3_percent = "*" if Lev3_percent=="."
replace Lev4_percent = "*" if Lev4_percent=="."
replace Lev5_percent = "*" if Lev5_percent=="."
replace Lev1_count = "*" if Lev1_count==" "
replace Lev2_count = "*" if Lev2_count==" "
replace Lev3_count = "*" if Lev3_count==" "
replace Lev4_count = "*" if Lev4_count==" "
replace Lev5_count = "*" if Lev5_count==" "
replace Lev1_count = "--" if Lev1_count==""
replace Lev2_count = "--" if Lev2_count==""
replace Lev3_count = "--" if Lev3_count==""
replace Lev4_count = "--" if Lev4_count==""
replace Lev5_count = "--" if Lev5_count==""

** Merging NCES Variables

gen State_leaid = "LA-" + StateAssignedDistID if DataLevel != "State" 
replace State_leaid = "LA-036" if DistName == "Orleans Parish"
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == "School"
replace seasch = "322-322001" if SchName == "A. E. Phillips Laboratory School"
replace seasch = "322-322001" if SchName == "A. E. Phillips Laboratory School"
replace seasch = "WI1-WI1001" if SchName == "Akili Academy of New Orleans"
replace seasch = "WBC-WBC001" if SchName == "Alice M Harte Elementary Charter School"
replace seasch = "W92-W92001" if SchName == "Arthur Ashe Charter School"
replace seasch = "WBT-WBT001" if SchName == "Audubon Charter Gentilly"
replace seasch = "WAZ-WAZ001" if SchName == "Audubon Charter School"
replace seasch = "036-036161" if SchName == "Benjamin Franklin Elem. Math and Science"
replace seasch = "WBK-WBK001" if SchName == "Bricolage Academy"
replace seasch = "WAM-WAM001" if SchName == "Dorothy Height Charter School" // renamed from Paul Habans
replace seasch = "W31-W31001" if SchName == "Dr. Martin Luther King Charter School for Sci Tech"
replace seasch = "WBV-WBV001" if SchName == "Dwight D. Eisenhower Charter School"
replace seasch = "WBJ-WBJ001" if SchName == "ENCORE Academy"
replace seasch = "WZC-WZC001" if SchName == "Edward Hynes Charter School - Lakeview"
replace seasch = "WZD-WZD001" if SchName == "Edward Hynes Charter School - UNO"
replace seasch = "WBN-WBN001" if SchName == "Einstein Charter Middle Sch at Sarah Towles Reed"
replace seasch = "WBA-WBA001" if SchName == "Einstein Charter School at Village De L'Est"
replace seasch = "WBO-WBO001" if SchName == "Einstein Charter at Sherwood Forest"
replace seasch = "036-036197" if SchName == "Elan Academy Charter School"
replace seasch = "WZI-WZI001" if SchName == "Esperanza Charter School"
replace seasch = "Missing/not reported" if SchName == "Eva Legard Learning Center"
replace seasch = "WAE-WAE001" if SchName == "Fannie C. Williams Charter School"
replace seasch = "WZG-WZG001" if SchName == "Foundation Preparatory Academy"
replace seasch = "WAF-WAF001" if SchName == "Harriet Tubman Charter School"
replace seasch = "WZK-WZK001" if SchName == "Homer Plessy Community School"
replace seasch = "WZJ-WZJ001" if SchName == "Hynes Parkview"
replace seasch = "W82-W82001" if SchName == "KIPP Believe"
replace seasch = "WL1-WL1001" if SchName == "KIPP Central City"
replace seasch = "W86-W86001" if SchName == "KIPP East"
replace seasch = "W85-W85001" if SchName == "KIPP Leadership"
replace seasch = "W81-W81001" if SchName == "KIPP Morial"
replace seasch = "WZH-WZH001" if SchName == "Lafayette Academy Charter School"
replace seasch = "WBH-WBH001" if SchName == "Lake Forest Elementary Charter School"
replace seasch = "W95-W95001" if SchName == "Langston Hughes Charter Academy"
replace seasch = "W66-W66001" if SchName == "Martin Behrman Charter Acad of Creative Arts & Sci"
replace seasch = "036-036011" if SchName == "Mary Bethune Elementary Literature/Technology"
replace seasch = "WBP-WBP001" if SchName == "McDonogh 42 Charter School"
replace seasch = "WV2-WV2001" if SchName == "Mildred Osborne Charter School"
replace seasch = "WAA-WAA001" if SchName == "Morris Jeff Community School"
replace seasch = "WZA-WZA001" if SchName == "New Orleans Accelerated High School"
replace seasch = "Missing/not reported" if SchName == "North Iberville High School"
replace seasch = "W94-W94001" if SchName == "Phillis Wheatley Community School"
replace seasch = "WZF-WZF001" if SchName == "Pierre A. Capdau Charter School"
replace seasch = "WZ3-WZ3001" if SchName == "ReNEW Dolores T. Aaron Elementary"
replace seasch = "WZ2-WZ2001" if SchName == "ReNEW Laurel Elementary"
replace seasch = "WZ6-WZ6001" if SchName == "ReNEW Schaumburg Elementary"
replace seasch = "WBG-WBG001" if SchName == "Robert Russa Moton Charter School"
replace seasch = "W91-W91001" if SchName == "Samuel J. Green Charter School"
replace seasch = "WU1-WU1001" if SchName == "Success @ Thurgood Marshall" // Success Preparatory Academy
replace seasch = "036-036200" if SchName == "The Delores Taylor Arthur School for Young Men"
replace seasch = "WZ9-WZ9001" if SchName == "The NET 2 Charter High School"
replace seasch = "WAH-WAH001" if SchName == "The NET Charter High School"
replace seasch = "WBE-WBE001" if SchName == "The Willow School"
// replace seasch = "" if SchName == "Travis Hill School"
replace seasch = "WBL-WBL001" if SchName == "Wilson Charter School"
replace seasch = "WZL-WZL001" if SchName == "YACS at Lawrence D. Crocker"
merge m:1 State_leaid using "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_District.dta"
rename _merge district_merge
merge m:1 seasch using "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_School.dta"
rename _merge school_merge
drop if district_merge != 3 & DataLevel != "State" & seasch != "Missing/not reported"| school_merge !=3 & DataLevel == "School" & seasch != "Missing/not reported"
drop if SchYear == ""
replace SchVirtual = "Missing/not reported" if seasch == "Missing/not reported" 
replace SchLevel = "Missing/not reported" if seasch == "Missing/not reported" 
replace SchType = "Missing/not reported" if seasch == "Missing/not reported" 
replace NCESSchoolID = "Missing/not reported" if seasch == "Missing/not reported" 
save "${path}/Semi-Processed Data Files/LA_2023_merged.dta", replace

keep SchName Subject GradeLevel
duplicates drop
sort SchName Subject GradeLevel
gen grade = .
replace grade = 300000 if GradeLevel == "03"
replace grade = 40000 if GradeLevel == "04"
replace grade = 5000 if GradeLevel == "05"
replace grade = 600 if GradeLevel == "06"
replace grade = 70 if GradeLevel == "07"
replace grade = 8 if GradeLevel == "08"
collapse (sum) grade, by(SchName Subject)
gen allgrades = ""
replace allgrades = "G78" if grade == 78
replace allgrades = "G06, G08" if grade == 608
replace allgrades = "G67" if grade == 670
replace allgrades = "G68" if grade == 678
replace allgrades = "G05, G08" if grade == 5008
replace allgrades = "G05, G07" if grade == 5070
replace allgrades = "G05, G07, G08" if grade == 5078
replace allgrades = "G56" if grade == 5600
replace allgrades = "G05, G06, G08" if grade == 5608
replace allgrades = "G57" if grade == 5670
replace allgrades = "G58" if grade == 5678
replace allgrades = "G04, G07" if grade == 40070
replace allgrades = "G04, G07, G08" if grade == 40078
replace allgrades = "G04, G06, G08" if grade == 40608
replace allgrades = "G04, G06, G07, G08" if grade == 40678
replace allgrades = "G45" if grade == 45000
replace allgrades = "G46" if grade == 45600
replace allgrades = "G04, G05, G06, G08" if grade == 45608
replace allgrades = "G47" if grade == 45670
replace allgrades = "G48" if grade == 45678
replace allgrades = "G03, G07" if grade == 300070
replace allgrades = "G03, G07, G08" if grade == 300078	
replace allgrades = "G03, G06, G08" if grade == 300608
replace allgrades = "G03, G06, G07" if grade == 300670
replace allgrades = "G03, G06, G07, G08" if grade == 300678
replace allgrades = "G03, G05" if grade == 305000
replace allgrades = "G03, G05, G07" if grade == 305070
replace allgrades = "G03, G05, G06" if grade == 305600
replace allgrades = "G03, G05, G06, G07" if grade == 305670
replace allgrades = "G03, G05, G06, G07, G08" if grade == 305678
replace allgrades = "G34" if grade == 340000
replace allgrades = "G03, G04, G08" if grade == 340008
replace allgrades = "G03, G04, G06" if grade == 340600
replace allgrades = "G03, G04, G06, G08" if grade == 340608
replace allgrades = "G03, G04, G06, G07, G08" if grade == 340678
replace allgrades = "G35" if grade == 345000
replace allgrades = "G03, G04, G05, G08" if grade == 345008
replace allgrades = "G03, G04, G05, G07" if grade == 345070
replace allgrades = "G03, G04, G05, G07, G08" if grade == 345078
replace allgrades = "G36" if grade == 345600
replace allgrades = "G03, G04, G05, G06, G08" if grade == 345608
replace allgrades = "G37" if grade == 345670
replace allgrades = "G38" if grade == 345678
save "${path}/Semi-Processed Data Files/LA_2023_schgrade.dta", replace

** Standardize Non-School Level Data

clear
use "${path}/Semi-Processed Data Files/LA_2023_merged.dta"
replace SchName = "All Schools" if DataLevel == "State"
replace SchName = "All Schools" if DataLevel == "District"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace StateAssignedSchID = "" if DataLevel == "State" | DataLevel == "District"
replace State_leaid = "" if DataLevel == "State"
replace SchLevel = ""  if DataLevel == "State" | DataLevel == "District"
replace SchVirtual = ""  if DataLevel == "State" | DataLevel == "District"
replace DistType = "" if DataLevel == "State"
replace DistCharter = "" if DataLevel == "State"
replace seasch = "" if DataLevel == "State" | DataLevel == "District"

** Relabel GradeLevel Values

tostring GradeLevel, replace
replace GradeLevel = "G" + GradeLevel
replace GradeLevel = "G38" if GradeLevel == "GAll" & DataLevel != "School"
replace GradeLevel = "G38" if GradeLevel == "GAll" & DataLevel == "District"
merge m:1 SchName Subject using "${path}/Semi-Processed Data Files/LA_2023_schgrade.dta"
replace GradeLevel = allgrades if GradeLevel == "GAll" & DataLevel == "School"
replace GradeLevel = "G38" if GradeLevel == "" & DataLevel == "School" & grade == 345678
replace GradeLevel = "G03" if GradeLevel == "" & DataLevel == "School" & grade == 300000
replace GradeLevel = "G06" if GradeLevel == "" & DataLevel == "School" & grade == 600
replace GradeLevel = "G08" if GradeLevel == "" & DataLevel == "School" & grade == 8
drop if SchYear == ""
drop _merge allgrades grade
duplicates drop
replace GradeLevel = "G38" if GradeLevel != "G03" & GradeLevel != "G04" & GradeLevel != "G05" & GradeLevel != "G06" & GradeLevel != "G07" & GradeLevel != "G08"

** Relabel ParticipationRate Values

replace TotalParticipationRate = subinstr(TotalParticipationRate, "%", "", .)
replace TotalParticipationRate = subinstr(TotalParticipationRate, ">=99", "≥0.99", .)
replace TotalParticipationRate = subinstr(TotalParticipationRate, "<=1", "≤0.01", .)
destring TotalParticipationRate, g(nTotalParticipationRate) force
rename TotalParticipationRate ParticipationRate
replace nTotalParticipationRate = nTotalParticipationRate / 100
tostring nTotalParticipationRate, replace force
replace ParticipationRate = nTotalParticipationRate if nTotalParticipationRate != "."
replace ParticipationRate = "--" if ParticipationRate == ""

** Fix Variable Types

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 
recast int CountyCode
drop State StateAbbrev StateFips
gen State = "Louisiana"
gen StateAbbrev = "LA"
gen StateFips = 22
recast int StateFips

** Label Variables

label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var SchYear "School year in which the data were reported. (e.g., 2021-22)"
label var AssmtName "Name of state assessment"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var DistCharter "Charter indicator - district"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested (Individual grade levels, Gr3-8, all grades)"
label var StudentGroup "Student demographic group"
label var StudentSubGroup "Student demographic subgroup"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested."
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested."
label var Lev1_count "Count of students within subgroup performing at Level 1."
label var Lev1_percent "Percent of students within subgroup performing at Level 1."
label var Lev2_count "Count of students within subgroup performing at Level 2."
label var Lev2_percent "Percent of students within subgroup performing at Level 2."
label var Lev3_count "Count of students within subgroup performing at Level 3."
label var Lev3_percent "Percent of students within subgroup performing at Level 3 ."
label var Lev4_count "Count of students within subgroup performing at Level 4."
label var Lev4_percent "Percent of students within subgroup performing at Level 4."
label var Lev5_count "Count of students within subgroup performing at Level 5."
label var Lev5_percent "Percent of students within subgroup performing at Level 5."
label var AvgScaleScore "Avg scale score within subgroup."
label var ProficiencyCriteria "Levels included in determining proficiency status."
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment."
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment."
label var ParticipationRate "Participation rate."
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var CountyName "County in which the district or school is located."
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var DistType "District type as defined by NCES"
label var NCESDistrictID "NCES district ID"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only."
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."

** Fix Variable Order 

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

** Export 2022-23 Assessment Data

save "${path}/Semi-Processed Data Files/LA_AssmtData_2023.dta", replace
export delimited using "${path}/Output/LA_AssmtData_2023.csv", replace



