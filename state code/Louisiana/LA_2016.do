clear
global path "/Users/willtolmie/Documents/State Repository Research/Louisiana"

** 2015-16 NCES School Data

use "${path}/NCES/School/NCES_2015_School.dta"

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

** Isolate Louisiana Data

keep if StateAbbrev == "LA" | DistName == "Chitimacha Day School"
drop if DistName == ""
replace seasch = State_leaid + "-" + seasch
replace State_leaid = "LA-" + State_leaid
save "${path}/Semi-Processed Data Files/2015_16_NCES_Cleaned_School.dta", replace

** 2015-16 NCES District Data

use "${path}/NCES/District/NCES_2015_District.dta"

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

drop year lea_name urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type_num agency_charter_indicator lowest_grade_offered highest_grade_offered

** Isolate Louisiana Data

keep if StateAbbrev == "LA" | NCESDistrictID == "5900146"
drop if State_leaid == ""

** Fix Variable Types

decode State, gen(State2)
decode DistType, gen(DistType2)
drop State DistType
rename DistType2 DistType
rename State2 State
replace State_leaid = "LA-" + State_leaid
replace State_leaid = "D50S09" if NCESDistrictID == "5900146"
save "${path}/Semi-Processed Data Files/2015_16_NCES_Cleaned_District.dta", replace

** 2015-16 Proficiency Data

import excel "${path}/Original Data Files/LA_OriginalData_2016_all.xlsx", sheet("Sheet1") cellrange(A4:V52024) firstrow clear

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
gen ParticipationRate = "--"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

** Fix Variable Types

replace Lev1_percent = subinstr(Lev1_percent, " ", "", .)
replace Lev2_percent = subinstr(Lev2_percent, " ", "", .)
replace Lev3_percent = subinstr(Lev3_percent, " ", "", .)
replace Lev4_percent = subinstr(Lev4_percent, " ", "", .)
replace Lev5_percent = subinstr(Lev5_percent, " ", "", .)

** Generate Other Variables

gen SchYear = "2015-16"
gen AssmtName = "LEAP"
gen AssmtType = "Regular"
replace DataLevel = "District" if DataLevel == "School System"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup=="Hispanic/Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup=="Two or more races"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "All Students" if StudentSubGroup=="Total Population"
gen StudentGroup = "RaceEth" if StudentSubGroup=="American Indian or Alaska Native" | StudentSubGroup=="Asian" | StudentSubGroup=="Black or African American" | StudentSubGroup=="Native Hawaiian or Pacific Islander" | StudentSubGroup=="Two or More" | StudentSubGroup=="White" | StudentSubGroup=="Hispanic or Latino"
replace StudentGroup = "EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup = "All Students" if StudentSubGroup=="All Students"
replace StudentGroup = "Economic Status" if StudentSubGroup=="Economically Disadvantaged"
gen ProficiencyCriteria = "Levels 4 and 5"

** Convert Proficiency Data into Percentages

foreach v of varlist Lev* {
	generate lessthan`v'=0
	replace lessthan`v'=1 if `v'=="≤5"
	replace `v'="*" if `v'== "≤5"
	destring `v', g(n`v') i(* -) force
	replace n`v' = n`v' / 100 if n`v' != .
	tostring n`v', replace force
	replace `v' = n`v' if `v' != "*"
	replace `v' = "≤.05" if lessthan==1
	drop n`v' lessthan`v'
}

** Generate Proficient or Above Percent

gen Lev4max = Lev4_percent
replace Lev4max = ".05" if Lev4_percent== "≤.05"
destring Lev4max, generate(Lev4maxnumber) force
gen Lev4min = Lev4_percent
replace Lev4min = "0" if Lev4_percent== "≤.05"
destring Lev4min, generate(Lev4minnumber) force
gen Lev5max = Lev5_percent
replace Lev5max = ".05" if Lev5_percent== "≤.05"
destring Lev5max, generate(Lev5maxnumber) force
gen Lev5min = Lev5_percent
replace Lev5min = "0" if Lev5_percent== "≤.05"
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

drop if StudentSubGroup == "Students with Disability"

** Merging NCES District Variables

gen state_leaidnumber =.
gen State_leaid = string(state_leaidnumber)
replace State_leaid = "LA-" + StateAssignedDistID if DataLevel != "State"
gen seaschnumber=.
gen seasch = string(seaschnumber)
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == "School"
replace seasch = "D50S09-D50S09" if SchName == "Chitimacha Tribal School"
replace State_leaid = "D50S09" if SchName == "Chitimacha Tribal School"
merge m:1 State_leaid using "${path}/Semi-Processed Data Files/2015_16_NCES_Cleaned_District.dta"
rename _merge district_merge
drop if district_merge != 3 & DataLevel != "State"

** Correct Inaccurate State_lead and seasch Values 

replace seasch = "WI1-WI1001" if StateAssignedSchID == "381001"
replace State_leaid = "LA-WI1" if StateAssignedSchID == "381001"

replace seasch = "WV1-WV1001" if StateAssignedSchID == "373001"
replace State_leaid = "LA-WV1" if StateAssignedSchID == "373001"

replace seasch = "W92-W92001" if StateAssignedSchID == "399002"
replace State_leaid = "LA-W92" if StateAssignedSchID == "399002"

replace seasch = "W8B-W8B001" if StateAssignedSchID == "3AP002"
replace State_leaid = "LA-W8B" if StateAssignedSchID == "3AP002"

replace seasch = "WAO-WAO001" if StateAssignedSchID == "3AP003"
replace State_leaid = "LA-WAO" if StateAssignedSchID == "3AP003"

replace seasch = "WAP-WAP001" if StateAssignedSchID == "3AP001"
replace State_leaid = "LA-WAP" if StateAssignedSchID == "3AP001"

replace seasch = "WE2-WE2001" if StateAssignedSchID == "385002"
replace State_leaid = "LA-WE2" if StateAssignedSchID == "385002"

replace seasch = "WAI-WAI001" if StateAssignedSchID == "361001"
replace State_leaid = "LA-WAI" if StateAssignedSchID == "361001"

replace seasch = "W65-W65001" if StateAssignedSchID == "395002"
replace State_leaid = "LA-W65" if StateAssignedSchID == "395002"

replace seasch = "WAB-WAB001" if StateAssignedSchID == "367001"
replace State_leaid = "LA-WAB" if StateAssignedSchID == "367001"

replace seasch = "W52-W52001" if StateAssignedSchID == "393002"
replace State_leaid = "LA-W52" if StateAssignedSchID == "393002"

replace seasch = "WAE-WAE001" if StateAssignedSchID == "364001"
replace State_leaid = "LA-WAE" if StateAssignedSchID == "364001"

replace seasch = "W14-W14001" if StateAssignedSchID == "300004"
replace State_leaid = "LA-W14" if StateAssignedSchID == "300004"

replace seasch = "WAF-WAF001" if StateAssignedSchID == "363001"
replace State_leaid = "LA-WAF" if StateAssignedSchID == "363001"

replace seasch = "W21-W21001" if StateAssignedSchID == "390001"
replace State_leaid = "LA-W21" if StateAssignedSchID == "390001"

replace seasch = "W82-W82001" if StateAssignedSchID == "398001"
replace State_leaid = "LA-W82" if StateAssignedSchID == "398001"

replace seasch = "W83-W83001" if StateAssignedSchID == "398003"
replace State_leaid = "LA-W83" if StateAssignedSchID == "398003"

replace seasch = "WL1-WL1001" if StateAssignedSchID == "398004"
replace State_leaid = "LA-WL1" if StateAssignedSchID == "398004"

replace seasch = "W81-W81001" if StateAssignedSchID == "398002"
replace State_leaid = "LA-W81" if StateAssignedSchID == "398002"

replace seasch = "W85-W85001" if StateAssignedSchID == "398006"
replace State_leaid = "LA-W85" if StateAssignedSchID == "398006"

replace seasch = "WB2-WB2001" if StateAssignedSchID == "389002"
replace State_leaid = "LA-WB2" if StateAssignedSchID == "389002"

replace seasch = "W51-W51001" if StateAssignedSchID == "393001"
replace State_leaid = "LA-W51" if StateAssignedSchID == "393001"

replace seasch = "W95-W95001" if StateAssignedSchID == "399005"
replace State_leaid = "LA-W95" if StateAssignedSchID == "399005"

replace seasch = "WE3-WE3001" if StateAssignedSchID == "385003"
replace State_leaid = "LA-WE3" if StateAssignedSchID == "385003"

replace seasch = "WX1-WX1001" if StateAssignedSchID == "371001"
replace State_leaid = "LA-WX1" if StateAssignedSchID == "371001"

replace seasch = "W66-W66001" if StateAssignedSchID == "395001"
replace State_leaid = "LA-W66" if StateAssignedSchID == "395001"

replace seasch = "W5A-W5A001" if StateAssignedSchID == "3A5001"
replace State_leaid = "LA-W5A" if StateAssignedSchID == "3A5001"

replace seasch = "W63-W63001" if StateAssignedSchID == "395004"
replace State_leaid = "LA-W63" if StateAssignedSchID == "395004"

replace seasch = "W53-W53001" if StateAssignedSchID == "393003"
replace State_leaid = "LA-W53" if StateAssignedSchID == "393003"

replace seasch = "WV2-WV2001" if StateAssignedSchID == "373002"
replace State_leaid = "LA-WV2" if StateAssignedSchID == "373002"

replace seasch = "WAA-WAA001" if StateAssignedSchID == "368001"
replace State_leaid = "LA-WAA" if StateAssignedSchID == "368001"

replace seasch = "W11-W11001" if StateAssignedSchID == "300002"
replace State_leaid = "LA-W11" if StateAssignedSchID == "300002"

replace seasch = "WAM-WAM001" if StateAssignedSchID == "363002"
replace State_leaid = "LA-WAM" if StateAssignedSchID == "363002"

replace seasch = "W94-W94001" if StateAssignedSchID == "399004"
replace State_leaid = "LA-W94" if StateAssignedSchID == "399004"

replace seasch = "W12-W12001" if StateAssignedSchID == "300001"
replace State_leaid = "LA-W12" if StateAssignedSchID == "300001"

replace seasch = "WZ1-WZ1001" if StateAssignedSchID == "369001"
replace State_leaid = "LA-WZ1" if StateAssignedSchID == "369001"

replace seasch = "WZ3-WZ3001" if StateAssignedSchID == "369003"
replace State_leaid = "LA-WZ3" if StateAssignedSchID == "369003"

replace seasch = "WZ6-WZ6001" if StateAssignedSchID == "369006"
replace State_leaid = "LA-WZ6" if StateAssignedSchID == "369006"

replace seasch = "WZ2-WZ2001" if StateAssignedSchID == "369002"
replace State_leaid = "LA-WZ2" if StateAssignedSchID == "369002"

replace seasch = "WZ7-WZ7001" if StateAssignedSchID == "369007"
replace State_leaid = "LA-WZ7" if StateAssignedSchID == "369007"

replace seasch = "W91-W91001" if StateAssignedSchID == "399001"
replace State_leaid = "LA-W91" if StateAssignedSchID == "399001"

replace seasch = "W71-W71001" if StateAssignedSchID == "397001"
replace State_leaid = "LA-W71" if StateAssignedSchID == "397001"

replace seasch = "WU1-WU1001" if StateAssignedSchID == "374001"
replace State_leaid = "LA-WU1" if StateAssignedSchID == "374001"

replace seasch = "WE1-WE1001" if StateAssignedSchID == "385001"
replace State_leaid = "LA-WE1" if StateAssignedSchID == "385001"

replace seasch = "W64-W64001" if StateAssignedSchID == "395003"
replace State_leaid = "LA-W64" if StateAssignedSchID == "395003"

** Merging NCES School Variables

merge m:1 seasch using "${path}/Semi-Processed Data Files/2015_16_NCES_Cleaned_School.dta"
drop if  _merge !=3 & DataLevel == "School"
drop state_leaidnumber seaschnumber _merge district_merge

** Standardize Non-School Level Data

replace SchName = "All Schools" if DataLevel == "State"
replace SchName = "All Schools" if DataLevel == "District"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace State_leaid = "" if DataLevel == "State"
replace seasch = "" if DataLevel == "State" | DataLevel == "District"

** Standardize Charter Data

replace DistCharter="No" if DistCharter=="Not applicable"

** Relabel GradeLevel Values

tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

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

** Export 2015-16 Assessment Data

save "${path}/Semi-Processed Data Files/LA_AssmtData_2016.dta", replace
export delimited using "${path}/Output/LA_AssmtData_2016.csv", replace
