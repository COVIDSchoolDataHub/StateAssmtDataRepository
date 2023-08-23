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

drop year district_agency_type district_agency_type_num county_code county_name school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch dist_lowest_grade_offered dist_highest_grade_offered

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

** 2021-22 Participation Data by District

import excel "${path}/Original Data Files/LEAP Participation by District_Grade 3-8.xlsx", sheet("Sheet1") firstrow allstring clear
drop C D F G I J L M O P H K N Q SiteName
rename E ParticipationRate
rename SiteCode StateAssignedDistID
drop if StateAssignedDistID == "" | ParticipationRate == ""
save "${path}/Semi-Processed Data Files/ParticipationbyDistrict2022.dta", replace

** 2021-22 Proficiency Data

import excel "${path}/Original Data Files/LA_OriginalData_2022_all.xlsx", sheet("Grades 3-8") cellrange(A4:AA57142) firstrow clear

** Reshape Wide to Long

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
generate id = _n
foreach v of varlist SchoolName Grade Subgroup {
   rename `v' y`i'
   local i = `i' + 1
}
reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent, i(id) j(Subject, string)
drop id

** Rename Variables

rename SchoolSystemCode StateAssignedDistID
rename SchoolSystemName DistName
rename SchoolCode StateAssignedSchID
rename SummaryLevel DataLevel
rename y SchName
rename y1 GradeLevel
rename y2 StudentSubGroup

** Generate Flags

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

** Generate Empty Variables

gen AvgScaleScore = "--"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

** Fix Variable Types

replace Lev1_percent = subinstr(Lev1_percent, " ", "", .)
replace Lev2_percent = subinstr(Lev2_percent, " ", "", .)
replace Lev3_percent = subinstr(Lev3_percent, " ", "", .)
replace Lev4_percent = subinstr(Lev4_percent, " ", "", .)
replace Lev5_percent = subinstr(Lev5_percent, " ", "", .)

** Generate Other Variables

gen SchYear = "2021-22"
gen AssmtName = "LEAP 2025"
gen AssmtType = "Regular"
replace DataLevel = "District" if DataLevel == "School System"
gen StudentGroup = "StudentGroup"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup=="Hispanic/Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup=="Two or more races" | StudentSubGroup=="Two or More Races"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "All Students" if StudentSubGroup=="Total Population"
replace StudentGroup = "RaceEth" if StudentSubGroup=="American Indian or Alaska Native" | StudentSubGroup=="Asian" | StudentSubGroup=="Black or African American" | StudentSubGroup=="Native Hawaiian or Pacific Islander" | StudentSubGroup=="Two or More" | StudentSubGroup=="White" | StudentSubGroup=="Hispanic or Latino"
replace StudentGroup = "Gender" if StudentSubGroup=="Male" | StudentSubGroup=="Female"
replace StudentGroup = "EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup = "All Students" if StudentSubGroup=="All Students"
replace StudentGroup = "Economic Status" if StudentSubGroup=="Economically Disadvantaged" | StudentSubGroup=="Not Economically Disadvantaged"
gen ProficiencyCriteria = "Levels 4 and 5"

** Merge Participation Data by District

merge m:1 StateAssignedDistID using "${path}/Semi-Processed Data Files/ParticipationbyDistrict2022.dta"
replace ParticipationRate = "--" if DataLevel == "School"
replace ParticipationRate = "--" if ParticipationRate == ""
generate greaterthan99 = 1 if ParticipationRate == ">=99%"
generate str id = cond(substr(ParticipationRate,-1,.)=="%",subinstr(ParticipationRate,"%","",.),ParticipationRate) if ParticipationRate != "--"
destring id, replace force
replace id = id / 100 if id != .
tostring(id), replace force
replace ParticipationRate = id if id !="."
replace ParticipationRate = "≥.99" if greaterthan99 == 1
drop _merge id greaterthan99

** Convert Proficiency Data into Percentages

foreach v of varlist Lev* {
	generate lessthan`v'=0
	replace lessthan`v'=1 if `v'=="<5"
	replace `v'="*" if `v'== "<5"
	destring `v', g(n`v') i(* -) force
	replace n`v' = n`v' / 100 if n`v' != .
	tostring n`v', replace force
	replace `v' = n`v' if `v' != "*"
	replace `v' = "<.05" if lessthan==1
	drop n`v' lessthan`v'
}

** Generate Proficient or Above Percent

gen Lev4max = Lev4_percent
replace Lev4max = ".05" if Lev4_percent== "<.05"
destring Lev4max, generate(Lev4maxnumber) force
gen Lev4min = Lev4_percent
replace Lev4min = "0" if Lev4_percent== "<.05"
destring Lev4min, generate(Lev4minnumber) force
gen Lev5max = Lev5_percent
replace Lev5max = ".05" if Lev5_percent== "<.05"
destring Lev5max, generate(Lev5maxnumber) force
gen Lev5min = Lev5_percent
replace Lev5min = "0" if Lev5_percent== "<.05"
destring Lev5min, generate(Lev5minnumber) force
gen ProficientOrAbovemin = Lev4minnumber + Lev5minnumber
gen ProficientOrAbovemax = Lev4maxnumber + Lev5maxnumber
tostring ProficientOrAbovemin, replace force
tostring ProficientOrAbovemax, replace force
gen ProficientOrAbove_percent = ProficientOrAbovemin + "-" + ProficientOrAbovemax
replace ProficientOrAbove_percent = ProficientOrAbovemax if ProficientOrAbovemax == ProficientOrAbovemin
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="."
replace Lev1_percent = "*" if Lev1_percent=="."
replace Lev2_percent = "*" if Lev2_percent=="."
replace Lev3_percent = "*" if Lev3_percent=="."
replace Lev4_percent = "*" if Lev4_percent=="."
replace Lev5_percent = "*" if Lev5_percent=="."
gen ProficientOrAbove_count = "--"
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
drop Lev4max Lev4maxnumber Lev4min Lev4minnumber Lev5max Lev5maxnumber Lev5min Lev5minnumber ProficientOrAbovemin ProficientOrAbovemax

** Drop Excess Data

keep if StudentGroup != "StudentGroup"

** Merging NCES District Variables

gen state_leaidnumber =.
gen State_leaid = string(state_leaidnumber)
replace State_leaid = "LA-" + StateAssignedDistID if DataLevel != "State" 
replace State_leaid = "LA-036" if DistName == "Orleans Parish"
gen seaschnumber=.
gen seasch = string(seaschnumber)
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == "School"
merge m:1 State_leaid using "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_District.dta"
rename _merge district_merge
drop if district_merge != 3 & DataLevel != "State"

** Merging NCES School Variables

replace seasch = "017-017154" if SchName == "BASIS Baton Rouge Primary Mid City"
replace seasch = "061-061013" if SchName == "Caneview K-8 School"
replace seasch = "017-017155" if SchName == "Helix Aviation Academy"
replace seasch = "017-017156" if SchName == "Helix Legal Academy"
replace seasch = "017-017157" if SchName == "IDEA University Prep"
replace seasch = "003-003036" if SchName == "Sugar Mill Primary"
merge m:1 seasch StateFips using "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_School.dta"
drop if _merge !=3 & DataLevel == "School"
drop if SchYear == ""
drop state_leaidnumber seaschnumber district_merge _merge

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

** Relabel GradeLevel Values

tostring GradeLevel, replace
replace GradeLevel = "G" + GradeLevel

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

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

** Export 2021-22 Assessment Data

save "${path}/Semi-Processed Data Files/LA_AssmtData_2022.dta", replace
export delimited using "${path}/Output/LA_AssmtData_2022.csv", replace



