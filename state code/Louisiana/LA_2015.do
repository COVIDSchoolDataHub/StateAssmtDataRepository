clear
global path "/Users/willtolmie/Documents/State Repository Research/Louisiana"
global nces "/Users/willtolmie/Documents/State Repository Research/NCES"

** 2014-15 NCES School Data

use "${nces}/School/NCES_2014_School.dta"

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

drop year district_agency_type district_agency_type_num county_code county_name school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch dist_lowest_grade_offered dist_highest_grade_offered dist_agency_charter_indicator

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
tostring seasch, replace
replace seasch = State_leaid + "-" + seasch
replace State_leaid = "LA-" + State_leaid 

** Isolate Louisiana Data

drop if StateAbbrev != "LA"
drop if DistName == ""
save "${path}/Semi-Processed Data Files/2014_15_NCES_Cleaned_School.dta", replace

** 2014-15 NCES District Data

use "${nces}/District/NCES_2014_District.dta"

** Rename Variables

rename ncesdistrictid NCESDistrictID
rename state_name State
rename state_leaid State_leaid
rename state_location StateAbbrev
rename county_code CountyCode
rename county_name CountyName
rename district_agency_type DistType
rename state_fips StateFips

** Isolate Louisiana Data

drop if StateAbbrev != "LA"
drop if State_leaid == ""

** Fix Variable Types

decode State, gen(State2)
decode DistType, gen(DistType2)
drop State DistType
rename DistType2 DistType
rename State2 State
replace State_leaid = "LA-" + State_leaid

** Drop Excess Variables

drop year lea_name urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type_num agency_charter_indicator lowest_grade_offered highest_grade_offered
save "${path}/Semi-Processed Data Files/2014_15_NCES_Cleaned_District.dta", replace

** 2014-15 Proficiency Data

import excel "${path}/Original Data Files/LA_OriginalData_2015.xlsx", sheet("2015 LEAP SUPPRESSED SOC") cellrange(A2:Z54402) firstrow allstring clear
rename NumberofStudents StudentSubGroup_TotalTestedsoc
rename AverageSocialStudiesScaledSc AvgScaleScoresoc
rename NumberADVANCEDAchievementLeve Lev5_countsoc
rename PercentADVANCEDAchievementLev Lev5_percentsoc
rename NumberMASTERYAchievementLevel Lev4_countsoc
rename PercentMASTERYAchievementLeve Lev4_percentsoc
rename NumberBASICAchievementLevel Lev3_countsoc
rename PercentBASICAchievementLevel Lev3_percentsoc
rename NumberAPPROACHINGBASICAchieve Lev2_countsoc
rename PercentAPPROACHINGBASICAchiev Lev2_percentsoc
rename NumberUNSATISFACTORYAchievemen Lev1_countsoc
rename PercentUNSATISFACTORYAchieveme Lev1_percentsoc
drop Subject
rename Subgroup StudentSubGroup
rename Summary DataLevel
save "${path}/Semi-Processed Data Files/2014_15_soc.dta", replace

import excel "${path}/Original Data Files/LA_OriginalData_2015.xlsx", sheet("2015 LEAP SUPPRESSED SCI") cellrange(A2:Z54402) firstrow allstring clear
rename NumberofStudents StudentSubGroup_TotalTestedsci
rename AverageScienceScaledScore AvgScaleScoresci
rename NumberADVANCEDAchievementLeve Lev5_countsci
rename PercentADVANCEDAchievementLev Lev5_percentsci
rename NumberMASTERYAchievementLevel Lev4_countsci
rename PercentMASTERYAchievementLeve Lev4_percentsci
rename NumberBASICAchievementLevel Lev3_countsci
rename PercentBASICAchievementLevel Lev3_percentsci
rename NumberAPPROACHINGBASICAchieve Lev2_countsci
rename PercentAPPROACHINGBASICAchiev Lev2_percentsci
rename NumberUNSATISFACTORYAchievemen Lev1_countsci
rename PercentUNSATISFACTORYAchieveme Lev1_percentsci
drop Subject
rename Subgroup StudentSubGroup
rename Summary DataLevel
replace DistrictCode = "" if DistrictCode == "≤"
save "${path}/Semi-Processed Data Files/2014_15_sci.dta", replace

import excel "${path}/Original Data Files/LA_OriginalData_2015.xlsx", sheet("2015 LEAP SUPPRESSED ELA_Math") cellrange(A3:AH107348) firstrow allstring clear

rename AverageELAScaleScore AvgScaleScoreela
rename AverageMathScaleScore AvgScaleScoremath

rename TotalStudentTested StudentSubGroup_TotalTestedela
rename Advanced Lev5_countela
rename O Lev5_percentela
rename Mastery Lev4_countela
rename Q Lev4_percentela
rename Basic Lev3_countela
rename S Lev3_percentela
rename ApproachingBasic Lev2_countela
rename U Lev2_percentela
rename Unsatisfactory Lev1_countela
rename W Lev1_percentela

rename X StudentSubGroup_TotalTestedmath
rename Y Lev5_countmath
rename Z Lev5_percentmath
rename AA Lev4_countmath
rename AB Lev4_percentmath
rename AC Lev3_countmath
rename AD Lev3_percentmath
rename AE Lev2_countmath
rename AF Lev2_percentmath
rename AG Lev1_countmath
rename AH Lev1_percentmath
rename SubGroup StudentSubGroup

drop SummaryLevel
gen DataLevel = "District" if SchoolCode == ""
replace DataLevel = "School" if DataLevel == ""
replace DataLevel = "State" if DistrictCode == ""

append using "${path}/Semi-Processed Data Files/2014_15_sci.dta" "${path}/Semi-Processed Data Files/2014_15_soc.dta"

** Reshape Wide to Long

generate id = _n
reshape long Lev1_percent Lev1_count Lev2_percent Lev2_count Lev3_percent Lev3_count Lev4_percent Lev4_count Lev5_percent Lev5_count StudentSubGroup_TotalTested AvgScaleScore, i(id) j(Subject, string)
drop id
drop if StudentSubGroup_TotalTested == ""
drop if DistrictCode == "" & DataLevel != "State"

** Rename Variables

rename DistrictCode StateAssignedDistID
rename DistrictName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName
rename Grade GradeLevel
rename Group StudentGroup

* Generate StudentGroup Values

save "${path}/Semi-Processed Data Files/TN_2015_nogroup.dta", replace
keep if Order=="1"
keep DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested StudentGroup_TotalTested
save "${path}/Semi-Processed Data Files/TN_2015_group.dta", replace
clear
use "${path}/Semi-Processed Data Files/TN_2015_nogroup.dta"
merge m:1 DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel using "${path}/Semi-Processed Data Files/TN_2015_group.dta"
drop _merge
save "${path}/Semi-Processed Data Files/TN_2015_all.dta", replace

** Generate Flags

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

** Generate Empty Variables

gen ParticipationRate = "--"

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

gen SchYear = "2014-15"
gen AssmtName = "LEAP"
gen AssmtType = "Regular"
replace StudentSubGroup = "Unknown" if StudentSubGroup=="Invalid"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup=="Hispanic/Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup=="Two or more races"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "All Students" if StudentGroup=="Total Population"
replace StudentGroup = "All Students" if StudentGroup=="Total Population"
replace StudentGroup = "RaceEth" if StudentGroup=="Ethnicity"
replace StudentSubGroup = "English Learner" if StudentSubGroup=="Yes" & StudentGroup=="LEP"
replace StudentSubGroup = "English Proficient" if StudentSubGroup=="No" & StudentGroup=="LEP"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup=="Yes" & StudentGroup=="Economically Disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup=="No" & StudentGroup=="Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentGroup=="Economically Disadvantaged"
replace StudentGroup = "EL Status" if StudentGroup=="LEP"
keep if StudentGroup == "All Students" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender" | StudentGroup == "RaceEth"
gen ProficiencyCriteria = "Levels 4 and 5"
replace AvgScaleScore = "*" if AvgScaleScore == ""

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
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count=="."
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

** Merging NCES Variables

gen State_leaid = "LA-" + StateAssignedDistID if DataLevel != "State"
replace StateAssignedSchID = StateAssignedDistID + StateAssignedSchID
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == "School"
replace seasch = "D50S09-D50S09" if SchName == "Chitimacha Tribal School"
replace State_leaid = "LA-D50S09" if State_leaid == "LA-660"
merge m:1 State_leaid using "${path}/Semi-Processed Data Files/2014_15_NCES_Cleaned_District.dta"
rename _merge district_merge
merge m:1 seasch StateAbbrev using "${path}/Semi-Processed Data Files/2014_15_NCES_Cleaned_School.dta"
drop if district_merge != 3 & DataLevel != "State"| _merge !=3 & DataLevel == "School"

** Relabel GradeLevel Values

replace GradeLevel = "G" + GradeLevel

** Fix Variable Types

recast int CountyCode
drop State StateAbbrev StateFips
gen State = "Louisiana"
gen StateAbbrev = "LA"
gen StateFips = 22
recast int StateFips
replace SchVirtual = "Missing/not reported"

** Standardize Non-School Level Data

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

** Fix DataLevel Format

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

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

** Export 2014-15 Assessment Data

save "${path}/Semi-Processed Data Files/LA_AssmtData_2015.dta", replace
export delimited using "${path}/Output/LA_AssmtData_2015.csv", replace
