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
rename charter Charter
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename virtual Virtual 
rename school_level SchoolLevel
rename lea_name DistName
rename school_type SchoolType
rename county_name CountyName

** Fix Variable Types

decode State, gen(State2)
decode Charter, gen(Charter2)
decode SchoolLevel, gen(SchoolLevel2)
decode SchoolType, gen(SchoolType2)
decode Virtual, gen(Virtual2)
drop State Charter SchoolLevel SchoolType Virtual
rename State2 State
rename Charter2 Charter
rename SchoolLevel2 SchoolLevel 
rename SchoolType2 SchoolType 
rename Virtual2 Virtual
tostring seasch, replace
replace seasch = State_leaid + "-" + seasch

** Drop Excess Variables

drop year school_id school_name urban_centric_locale school_status lowest_grade_offered highest_grade_offered bureau_indian_education lunch_program free_lunch reduced_price_lunch free_or_reduced_price_lunch enrollment 

** Label Variables

label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var Charter "Charter indicator"
label var CountyName "County in which the district or school is located."
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"

** Isolate Louisiana Data

drop if StateFips != 22
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
rename district_agency_type DistrictType
rename state_fips StateFips

** Fix Variable Types

decode State, gen(State2)
decode DistrictType, gen(DistrictType2)
drop State DistrictType
rename DistrictType2 DistrictType
rename State2 State
replace State_leaid = "LA-" + State_leaid

** Drop Excess Variables

drop year lea_name

** Label Variables

label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var CountyName "County in which the district or school is located."
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var DistrictType "District type as defined by NCES"

** Isolate Louisiana Data

drop if StateFips != 22
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
drop id SummaryLevel
drop if y==""

** Rename Variables

rename SchoolSystemCode StateAssignedDistID
rename SchoolSystemName DistName
rename SchoolCode StateAssignedSchID
rename y SchName
rename y1 GradeLevel
rename y2 StudentSubGroup

** Generate Flags

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"

** Label Flags

label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only."
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."
label var Flag_CutScoreChange_oth "Flag denoting a change in scoring determinations in subjects other than ELA, math, or reading from the prior year only (e.g., writing, STEM)."

** Generate Empty Variables

gen ProficientOrAbove_count = .
gen Lev1_count = .
gen Lev2_count = .
gen Lev3_count = .
gen Lev4_count = .
gen Lev5_count = .
gen AvgScaleScore = .
gen ParticipationRate = .
gen StudentGroup_TotalTested = .
gen StudentSubGroup_TotalTested = .

** Fix Variable Types

replace Lev1_percent = subinstr(Lev1_percent, " ", "", .)
replace Lev2_percent = subinstr(Lev1_percent, " ", "", .)
replace Lev3_percent = subinstr(Lev1_percent, " ", "", .)
replace Lev4_percent = subinstr(Lev1_percent, " ", "", .)
replace Lev5_percent = subinstr(Lev1_percent, " ", "", .)
destring GradeLevel, replace

** Generate Other Variables

gen SchYear = "2015-16"
gen AssmtName = "LEAP"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup=="Hispanic/Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup=="Two or more races"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "English learner" if StudentSubGroup=="English Learner"
replace StudentSubGroup = "All students" if StudentSubGroup=="Total Population"
gen StudentGroup = "Race" if StudentSubGroup=="American Indian or Alaska Native" | StudentSubGroup=="Asian" | StudentSubGroup=="Black or African American" | StudentSubGroup=="Native Hawaiian or Pacific Islander" | StudentSubGroup=="Two or More" | StudentSubGroup=="White" | StudentSubGroup=="Hispanic or Latino"
replace StudentGroup = "EL status" if StudentSubGroup=="English learner"
replace StudentGroup = "All students" if StudentSubGroup=="All students"
gen ProficiencyCriteria = "Levels 4 and 5"
replace Lev1_percent = "*" if Lev1_percent=="NR"
replace Lev2_percent = "*" if Lev2_percent=="NR"
replace Lev3_percent = "*" if Lev3_percent=="NR"
replace Lev4_percent = "*" if Lev4_percent=="NR"
replace Lev5_percent = "*" if Lev5_percent=="NR"

** Generate Proficienct or Above Percent

gen Lev4max = Lev4_percent
replace Lev4max = "5" if Lev4_percent== "<5"
destring Lev4max, generate(Lev4maxnumber) force
gen Lev4min = Lev4_percent
replace Lev4min = "0" if Lev4_percent== "<5"
destring Lev4min, generate(Lev4minnumber) force
gen Lev5max = Lev5_percent
replace Lev5max = "5" if Lev5_percent== "<5"
destring Lev5max, generate(Lev5maxnumber) force
gen Lev5min = Lev5_percent
replace Lev5min = "0" if Lev5_percent== "<5"
destring Lev5min, generate(Lev5minnumber) force
gen ProficientOrAbovemin = Lev4minnumber + Lev5minnumber
gen ProficientOrAbovemax = Lev4maxnumber + Lev5maxnumber
tostring ProficientOrAbovemin, replace
tostring  ProficientOrAbovemax, replace
gen ProficientOrAbove_percent = ProficientOrAbovemin + "-" + ProficientOrAbovemax
replace ProficientOrAbove_percent = ProficientOrAbovemax if ProficientOrAbovemax == ProficientOrAbovemin
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="."
drop Lev4max Lev4maxnumber Lev4min Lev4minnumber Lev5max Lev5maxnumber Lev5min Lev5minnumber ProficientOrAbovemin ProficientOrAbovemax

** Label Variables

label var SchYear "School year in which the data were reported. (e.g., 2021-22)"
label var AssmtName "Name of state assessment"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
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

** Drop Excess Data

drop if StudentSubGroup == "Students with Disability" | StudentSubGroup == "Economically Disadvantaged"
keep if SchName !=""

** Merging NCES Variables

gen state_leaidnumber =.
gen State_leaid = string(state_leaidnumber)
replace State_leaid = "LA-" + StateAssignedDistID 
label var State_leaid "State LEA ID"
gen seaschnumber=.
gen seasch = string(seaschnumber)
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID
merge m:1 State_leaid using "${path}/Semi-Processed Data Files/2015_16_NCES_Cleaned_District.dta"
rename _merge district_merge
merge m:1 seasch StateFips using "${path}/Semi-Processed Data Files/2015_16_NCES_Cleaned_School.dta"
keep if district_merge == 3 & _merge == 3
drop state_leaidnumber seaschnumber _merge district_merge

** Relabel GradeLevel Values

tostring GradeLevel, replace
replace GradeLevel="G03" if GradeLevel=="3"
replace GradeLevel="G04" if GradeLevel=="4"
replace GradeLevel="G05" if GradeLevel=="5"
replace GradeLevel="G06" if GradeLevel=="6"
replace GradeLevel="G07" if GradeLevel=="7"
replace GradeLevel="G08" if GradeLevel=="8"

** Fix Variable Order 

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

** Export 2015-16 Assessment Data

save "${path}/Semi-Processed Data Files/LA_AssmtData_2016.dta", replace
export delimited using "${path}/Output/LA_AssmtData_2016.csv", replace
