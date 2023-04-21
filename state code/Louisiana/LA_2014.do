clear
global path "/Users/willtolmie/Documents/State Repository Research/Louisiana"

** 2013-14 NCES School Data

use "${path}/NCES/School/NCES_2013_School.dta"

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
drop if State_leaid == ""
save "${path}/Semi-Processed Data Files/2013_14_NCES_Cleaned_School.dta", replace

** 2013-14 NCES District Data

use "${path}/NCES/District/NCES_2013_District.dta"

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
save "${path}/Semi-Processed Data Files/2013_14_NCES_Cleaned_District.dta", replace

** 2013-14 Proficiency Data

local grades 3 4 5 6 7 8
foreach gr of local grades {
	clear
	import excel "${path}/Original Data Files/LA_OriginalData_2014_`gr'_all"
	
	** Label Grade Values
	
	replace C = "0`gr'"
	
	** Reshape Wide to Long
	
	rename D Lev5_percentela
	rename E Lev4_percentela
	rename F Lev3_percentela
	rename G Lev2_percentela
	rename H Lev1_percentela
	rename I Lev5_percentmath
	rename J Lev4_percentmath
	rename K Lev3_percentmath
	rename L Lev2_percentmath
	rename M Lev1_percentmath
	rename N Lev5_percentsci
	rename O Lev4_percentsci
	rename P Lev3_percentsci
	rename Q Lev2_percentsci
	rename R Lev1_percentsci
	rename S Lev5_percentsoc
	rename T Lev4_percentsoc
	rename U Lev3_percentsoc
	rename V Lev2_percentsoc
	rename W Lev1_percentsoc
	generate id = _n
	
	reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent, i(id) j(Subject, string)
	
	** Rename Variables
	
	rename A StateAssignedSchID
	rename B SchName
	rename C GradeLevel
	
	** Drop Excess Data and Variables
	
	drop id
	drop if SchName==""
	
	** Export Cleaned Data by Grade
	
	save "${path}/Semi-Processed Data Files/LA_CleanedData_2014_`gr'", replace
	
}

** Merge Cleaned Data by Grade

use "${path}/Semi-Processed Data Files/LA_CleanedData_2014_3"
append using "${path}/Semi-Processed Data Files/LA_CleanedData_2014_4.dta""/${path}/Semi-Processed Data Files/LA_CleanedData_2014_4.dta" "/${path}/Semi-Processed Data Files/LA_CleanedData_2014_5.dta" "${path}/Semi-Processed Data Files/LA_CleanedData_2014_6.dta""/${path}/Semi-Processed Data Files/LA_CleanedData_2014_7.dta" "/${path}/Semi-Processed Data Files/LA_CleanedData_2014_8.dta"

** Generate StateAssignedDistID and DistName Variables

gen StateAssignedDistID = substr(StateAssignedSchID,1,3)
keep if StateAssignedDistID == StateAssignedSchID
keep if Subject == "ela"
rename SchName DistName
drop Subject Lev5_percent Lev4_percent Lev3_percent Lev2_percent Lev1_percent StateAssignedSchID GradeLevel
generate long obs = _n 
by StateAssignedDistID (obs), sort: replace obs = obs[1] 
by obs, sort: gen byte group = _n == 1
replace group = sum(group) 
bysort obs (StateAssignedDistID) : gen firstStateAssignedDistID = sum(group >= 1 & group < .) == 1
keep if firstStateAssignedDistID==1
drop obs group firstStateAssignedDistID 
save "${path}/Semi-Processed Data Files/StateAssignedDistID_2014.dta", replace

** Merge StateAssignedDistID and DistName Variables with Cleaned DataLevel

clear
use "${path}/Semi-Processed Data Files/LA_CleanedData_2014_3"
append using "${path}/Semi-Processed Data Files/LA_CleanedData_2014_4.dta""/${path}/Semi-Processed Data Files/LA_CleanedData_2014_4.dta" "/${path}/Semi-Processed Data Files/LA_CleanedData_2014_5.dta" "${path}/Semi-Processed Data Files/LA_CleanedData_2014_6.dta""/${path}/Semi-Processed Data Files/LA_CleanedData_2014_7.dta" "/${path}/Semi-Processed Data Files/LA_CleanedData_2014_8.dta"
gen StateAssignedDistID = substr(StateAssignedSchID,1,3)
merge m:1 StateAssignedDistID using "${path}/Semi-Processed Data Files/StateAssignedDistID_2014.dta"
drop _merge

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
replace Lev2_percent = subinstr(Lev2_percent, " ", "", .)
replace Lev3_percent = subinstr(Lev3_percent, " ", "", .)
replace Lev4_percent = subinstr(Lev4_percent, " ", "", .)
replace Lev5_percent = subinstr(Lev5_percent, " ", "", .)
destring GradeLevel, replace

** Generate Other Variables

gen SchYear = "2013-14"
gen AssmtName = "LEAP"
gen AssmtType = "Regular"
gen DataLevel = "School"
gen StudentSubGroup = "All students"
gen StudentGroup = "All students"
gen ProficiencyCriteria = "Levels 4 and 5"
drop if StateAssignedDistID == StateAssignedSchID | StateAssignedDistID == "Sit" | StateAssignedDistID == "STA"
replace Lev1_percent = "*" if Lev1_percent=="NR"
replace Lev2_percent = "*" if Lev2_percent=="NR"
replace Lev3_percent = "*" if Lev3_percent=="NR"
replace Lev4_percent = "*" if Lev4_percent=="NR"
replace Lev5_percent = "*" if Lev5_percent=="NR"

** Generate Proficienct or Above Percent

gen Lev4max = Lev4_percent
replace Lev4max = "1" if Lev4_percent== "≤1"
destring Lev4max, generate(Lev4maxnumber) force
gen Lev4min = Lev4_percent
replace Lev4min = "0" if Lev4_percent== "≤1"
destring Lev4min, generate(Lev4minnumber) force
gen Lev5max = Lev5_percent
replace Lev5max = "1" if Lev5_percent== "≤1"
destring Lev5max, generate(Lev5maxnumber) force
gen Lev5min = Lev5_percent
replace Lev5min = "0" if Lev5_percent== "≤1"
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

** Merging NCES Variables

gen state_leaidnumber =.
gen State_leaid = string(state_leaidnumber)
replace State_leaid = "LA-" + StateAssignedDistID 
label var State_leaid "State LEA ID"
gen seaschnumber=.
gen seasch = string(seaschnumber)
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID
merge m:1 State_leaid using "${path}/Semi-Processed Data Files/2013_14_NCES_Cleaned_District.dta"
rename _merge district_merge
merge m:1 seasch StateFips using "${path}/Semi-Processed Data Files/2013_14_NCES_Cleaned_School.dta"
keep if district_merge == 3 & _merge == 3
drop state_leaidnumber seaschnumber _merge district_merge

** Fix Variable Order 

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

** Export 2013-14 Assessment Data

save "${path}/Semi-Processed Data Files/LA_AssmtData_2014.dta", replace
export delimited using "${path}/Output/LA_AssmtData_2014.csv", replace
