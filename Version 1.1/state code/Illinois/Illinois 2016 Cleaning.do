clear
set more off

global output "/Volumes/T7/State Test Project/Illinois/Original Data Files"
global NCES "/Volumes/T7/State Test Project/Illinois/NCES"
global EDFacts "/Volumes/T7/State Test Project/EDFACTS"

cd "/Volumes/T7/State Test Project/Illinois"




**** State

use "${output}/IL_AssmtData_2015-2017_all_state.dta", clear

** Dropping extra variables

// drop Migrant IEP NotIEP // DO NOT DROP THESE IMMEDIATELY // 
*drop IEP NotIEP // DO NOT DROP THESE IMMEDIATELY //not dropping migrant

** Rename existing variables

rename ELA SchYear
rename B GradeLevel
rename TotalTested StudentGroup_TotalTested
rename All ProficientOrAbove_percentAll
rename Male ProficientOrAbove_percentMale
rename Female ProficientOrAbove_percentFemale
rename White ProficientOrAbove_percentWhite
rename Black ProficientOrAbove_percentBlack
rename Hispanic ProficientOrAbove_percentHisp
rename Asian ProficientOrAbove_percentAsian
rename HawaiianPacificIslander ProficientOrAbove_percentHawaii
rename NativeAmerican ProficientOrAbove_percentNative
rename TwoorMoreRaces ProficientOrAbove_percentTwo
rename LEP ProficientOrAbove_percentLearner
rename NotLEP ProficientOrAbove_percentProf
rename LowIncome ProficientOrAbove_percentDis
rename NotLowIncome ProficientOrAbove_percentNotDis
rename Migrant ProficientOrAbove_percentMigrant
rename IEP ProficientOrAbove_percentIEP
rename NotIEP ProficientOrAbove_percentNotIEP

** Dropping entries

keep if SchYear == "2016"

** Replacing variables

replace SchYear = "2015-16"

** Generating new variables

gen AssmtName = "PARCC"
gen AssmtType = "Regular"

local level 1 2 3 4 5

foreach a of local level {
	gen Lev`a'_count = "--"
	gen Lev`a'_percent = "--"
}

gen ProficientOrAbove_count = "--"

gen AvgScaleScore = "--"

gen ProficiencyCriteria = "Levels 4-5"

gen ParticipationRate = "--"

gen SchName = "All Schools"
gen DistName = "All Districts"

replace GradeLevel = "G0" + subinstr(GradeLevel,"Grade ","",.)
replace GradeLevel = "G38" if GradeLevel == "G0Grade3-8"

gen Subject = ""
replace Subject = "ela" if _n < 8
replace Subject = "math" if _n > 7

gen DataLevel = "State"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Reshaping

reshape long ProficientOrAbove_percent, i(GradeLevel Subject) j(StudentSubGroup) string

replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaii"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hisp"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Learner"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Prof"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NotDis"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant"
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "NotIEP"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Disability Status" if strpos(StudentSubGroup, "SWD") !=0


gen StudentSubGroup_TotalTested = "--"
replace StudentSubGroup_TotalTested = StudentGroup_TotalTested if StudentGroup == "All Students"

destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force format("%9.3g")

save "${output}/IL_AssmtData_2016_all_state.dta", replace




**** Sci

*** Sci AvgScaleScore

use "${output}/IL_AssmtData_2016_sci_AvgScaleScore_5.dta", clear
gen GradeLevel = "G05"

append using "${output}/IL_AssmtData_2016_sci_AvgScaleScore_8.dta"
replace GradeLevel = "G08" if GradeLevel == ""

** Dropping extra variables

drop County City

** Rename existing variables

rename RCDTS StateAssignedSchID
drop DIST
rename SchoolorDistrictName SchName
rename Mean AvgScaleScore

** Generating new variables

gen StudentSubGroup = "All Students"

replace StateAssignedSchID = "STATE" if SchName == "STATE"

tostring AvgScaleScore, replace
replace AvgScaleScore = "--" if AvgScaleScore == "."

save "${output}/IL_AssmtData_2016_sci_AvgScaleScore.dta", replace



*** Sci Participation

use "${output}/IL_AssmtData_2016_sci_Participation_5.dta", clear
gen GradeLevel = "G05"

append using "${output}/IL_AssmtData_2016_sci_Participation_8.dta"
replace GradeLevel = "G08" if GradeLevel == ""

** Dropping extra variables

// drop County City Migrant IEP NotIEP
drop County City

** Rename existing variables

rename RCDTS StateAssignedSchID
drop DIST
rename SchoolorDistrictName SchName
rename All ParticipationRateAll
rename Male ParticipationRateMale
rename Female ParticipationRateFemale
rename White ParticipationRateWhite
rename Black ParticipationRateBlack
rename Hispanic ParticipationRateHisp
rename Asian ParticipationRateAsian
rename HawaiianPacificIslander ParticipationRateHawaii
rename NativeAmerican ParticipationRateNative
rename TwoorMoreRaces ParticipationRateTwo
rename EL ParticipationRateLearner
rename NotEL ParticipationRateProf
rename LowIncome ParticipationRateDis
rename NotLowIncome ParticipationRateNotDis
rename Migrant ParticipationRateMigrant
rename IEP ProficientOrAbove_percentIEP
rename NotIEP ProficientOrAbove_percentNotIEP

** Reshaping

reshape long ParticipationRate, i(StateAssignedSchID GradeLevel) j(StudentSubGroup) string

replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaii"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hisp"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Learner"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Prof"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NotDis"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant" 
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "NotIEP"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Disability Status" if strpos(StudentSubGroup, "SWD") !=0


replace ParticipationRate = ParticipationRate/100
tostring ParticipationRate, replace force format("%9.3g")
replace ParticipationRate = "*" if ParticipationRate == "."

save "${output}/IL_AssmtData_2016_sci_Participation.dta", replace



*** Sci Performance Levels

use "${output}/IL_AssmtData_2016_sci_5.dta", clear
gen GradeLevel = "G05"

append using "${output}/IL_AssmtData_2016_sci_8.dta"
replace GradeLevel = "G08" if GradeLevel == ""

** Dropping extra variables


// drop County City Migrant IEP NotIEP
drop County City

** Rename existing variables

rename RCDTS StateAssignedSchID
drop DIST
rename SchoolorDistrictName SchName
rename All ProficientOrAbove_percentAll
rename Male ProficientOrAbove_percentMale
rename Female ProficientOrAbove_percentFemale
rename White ProficientOrAbove_percentWhite
rename Black ProficientOrAbove_percentBlack
rename Hispanic ProficientOrAbove_percentHisp
rename Asian ProficientOrAbove_percentAsian
rename HawaiianPacificIslander ProficientOrAbove_percentHawaii
rename NativeAmerican ProficientOrAbove_percentNative
rename TwoorMoreRaces ProficientOrAbove_percentTwo
rename EL ProficientOrAbove_percentLearner
rename NotEL ProficientOrAbove_percentProf
rename LowIncome ProficientOrAbove_percentDis
rename NotLowIncome ProficientOrAbove_percentNotDis
rename Migrant ProficientOrAbove_percentMigrant
rename IEP ProficientOrAbove_percentIEP
rename NotIEP ProficientOrAbove_percentNotIEP

** Dropping entries

drop if StateAssignedSchID == ""

** Generating new variables

gen SchYear = "2015-16"

gen AssmtName = "ISA"
gen AssmtType = "Regular"

gen Lev1_count = "--"
gen Lev2_count = "--"

local level 3 4 5

foreach a of local level {
	gen Lev`a'_count = ""
	gen Lev`a'_percent = ""
}

gen ProficientOrAbove_count = "--"

gen ProficiencyCriteria = "Level 2"

gen Subject = "sci"

** Reshaping

reshape long ProficientOrAbove_percent, i(StateAssignedSchID GradeLevel) j(StudentSubGroup) string

replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaii"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hisp"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Learner"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Prof"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NotDis"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant" 
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "NotIEP"


gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Disability Status" if strpos(StudentSubGroup, "SWD") !=0


gen StudentSubGroup_TotalTested = "--"
gen StudentGroup_TotalTested = "--"

replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
gen Lev1_percent = 1 - ProficientOrAbove_percent
tostring ProficientOrAbove_percent, replace force format("%9.3g")
tostring Lev1_percent, replace force format("%9.3g")
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace Lev1_percent = "*" if Lev1_percent == "."

gen Lev2_percent = ProficientOrAbove_percent

merge 1:1 StateAssignedSchID GradeLevel StudentSubGroup using "${output}/IL_AssmtData_2016_sci_AvgScaleScore.dta"
drop _merge

replace AvgScaleScore = "--" if AvgScaleScore == ""

merge 1:1 StateAssignedSchID GradeLevel StudentSubGroup using "${output}/IL_AssmtData_2016_sci_Participation.dta"
drop if _merge == 2
drop _merge

drop if ParticipationRate == "0"

gen DataLevel = "School"
replace DataLevel = "State" if StateAssignedSchID == "STATE"
replace DataLevel = "District" if strpos(StateAssignedSchID,"0000") > 0

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

gen leadingzero = 0
replace leadingzero = 1 if substr(StateAssignedSchID,15,1) == ""
replace StateAssignedSchID = "0" + StateAssignedSchID if leadingzero == 1
drop leadingzero

gen StateAssignedDistID = substr(StateAssignedSchID,1,11)

gen State_leaid = StateAssignedSchID
replace State_leaid = substr(State_leaid,1,11)
replace State_leaid = substr(State_leaid,1,2) + "-" + substr(State_leaid,3,3) + "-" + substr(State_leaid,6,4) + "-" + substr(State_leaid,10,2)
replace StateAssignedSchID = "" if DataLevel != 3

gen seasch = StateAssignedSchID
replace seasch = substr(seasch,1,9) + substr(seasch,12,4)
replace seasch = "" if DataLevel != 3

merge m:1 State_leaid using "${NCES}/NCES_2015_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2015_School.dta"
drop if _merge == 2
drop _merge

save "${output}/IL_AssmtData_2016_sci.dta", replace






**** ELA & Math District & Schools

use "${output}/IL_AssmtData_2016_all.dta", clear

** Dropping extra variables

drop County City

** Rename existing variables

rename RCDTS StateAssignedSchID
rename DistrictSchool DataLevel
drop Dist
rename DistrictNameSchoolName SchName
rename Grade3 Lev1_percentela3
rename H Lev2_percentela3
rename I Lev3_percentela3
rename J Lev4_percentela3
rename K Lev5_percentela3
rename L Lev1_percentmath3
rename M Lev2_percentmath3
rename N Lev3_percentmath3
rename O Lev4_percentmath3
rename P Lev5_percentmath3
rename Grade4 Lev1_percentela4
rename R Lev2_percentela4
rename S Lev3_percentela4
rename T Lev4_percentela4
rename U Lev5_percentela4
rename V Lev1_percentmath4
rename W Lev2_percentmath4
rename X Lev3_percentmath4
rename Y Lev4_percentmath4
rename Z Lev5_percentmath4
rename Grade5 Lev1_percentela5
rename AB Lev2_percentela5
rename AC Lev3_percentela5
rename AD Lev4_percentela5
rename AE Lev5_percentela5
rename AF Lev1_percentmath5
rename AG Lev2_percentmath5
rename AH Lev3_percentmath5
rename AI Lev4_percentmath5
rename AJ Lev5_percentmath5
rename Grade6 Lev1_percentela6
rename AL Lev2_percentela6
rename AM Lev3_percentela6
rename AN Lev4_percentela6
rename AO Lev5_percentela6
rename AP Lev1_percentmath6
rename AQ Lev2_percentmath6
rename AR Lev3_percentmath6
rename AS Lev4_percentmath6
rename AT Lev5_percentmath6
rename Grade7 Lev1_percentela7
rename AV Lev2_percentela7
rename AW Lev3_percentela7
rename AX Lev4_percentela7
rename AY Lev5_percentela7
rename AZ Lev1_percentmath7
rename BA Lev2_percentmath7
rename BB Lev3_percentmath7
rename BC Lev4_percentmath7
rename BD Lev5_percentmath7
rename Grade8 Lev1_percentela8
rename BF Lev2_percentela8
rename BG Lev3_percentela8
rename BH Lev4_percentela8
rename BI Lev5_percentela8
rename BJ Lev1_percentmath8
rename BK Lev2_percentmath8
rename BL Lev3_percentmath8
rename BM Lev4_percentmath8
rename BN Lev5_percentmath8

** Dropping entries

drop if StateAssignedSchID == ""

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Reshaping

reshape long Lev1_percentela Lev2_percentela Lev3_percentela Lev4_percentela Lev5_percentela Lev1_percentmath Lev2_percentmath Lev3_percentmath Lev4_percentmath Lev5_percentmath, i(StateAssignedSchID) j(GradeLevel) string

reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent, i(StateAssignedSchID GradeLevel) j(Subject) string

drop if Lev1_percent == " "

** Replacing variables

replace GradeLevel = "G0" + GradeLevel

** Generating new variables

gen SchYear = "2015-16"

gen AssmtName = "PARCC"
gen AssmtType = "Regular"

gen StudentGroup = "All Students"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = "--"

local level 1 2 3 4 5

foreach a of local level {
	gen Lev`a'_count = "--"
	destring Lev`a'_percent, replace
	replace Lev`a'_percent = Lev`a'_percent/100
}

gen ProficientOrAbove_count = "--"

gen ProficientOrAbove_percent = Lev4_percent + Lev5_percent
tostring ProficientOrAbove_percent, replace force format("%9.3g")

foreach a of local level {
	tostring Lev`a'_percent, replace force format("%9.3g")
}

gen AvgScaleScore = "--"

gen ProficiencyCriteria = "Levels 4-5"

gen ParticipationRate = "--"

** Merging with NCES

gen StateAssignedDistID = substr(StateAssignedSchID,1,11)

gen State_leaid = StateAssignedSchID
replace State_leaid = substr(State_leaid,1,11)
replace State_leaid = substr(State_leaid,1,2) + "-" + substr(State_leaid,3,3) + "-" + substr(State_leaid,6,4) + "-" + substr(State_leaid,10,2)
replace StateAssignedSchID = "" if DataLevel != 3

gen seasch = StateAssignedSchID
replace seasch = substr(seasch,1,9) + substr(seasch,12,4)
replace seasch = "" if DataLevel != 3

merge m:1 State_leaid using "${NCES}/NCES_2015_District.dta"

drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2015_School.dta"

drop if _merge == 2
drop _merge




**** Appending

append using "${output}/IL_AssmtData_2016_all_state.dta"
append using "${output}/IL_AssmtData_2016_sci.dta"

replace StateAbbrev = "IL" if DataLevel == 1
replace State = "Illinois" if DataLevel == 1
replace StateFips = 17 if DataLevel == 1
replace State_leaid = "" if DataLevel == 1
replace StateAssignedDistID = "" if DataLevel == 1

replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1

** Generating new variables

// gen Flag_AssmtNameChange = "N"
// gen Flag_CutScoreChange_ELA = "N"
// gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_read = ""
// gen Flag_CutScoreChange_oth = "Y"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"

drop State_leaid seasch

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode


// order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


save "${output}/IL_AssmtData_2016_1.dta", replace

export delimited using "${output}/IL_AssmtData_2016_1.csv", replace

use "${output}/IL_AssmtData_2016_1.dta", clear


////////// EDFACTS ADDENDUM


use "${output}/IL_AssmtData_2016_1.dta", clear

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2016/edfactscount2016districtillinois.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2016/edfactspart2016districtillinois.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2016/edfactscount2016schoolillinois.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2016/edfactspart2016schoolillinois.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

preserve
keep if DataLevel == 2
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
collapse (sum) StudentSubGroup_TotalTested2, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "IL_AssmtData_2016_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "IL_AssmtData_2016_State.dta"
tostring StudentSubGroup_TotalTested2, replace
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTested2 if StudentSubGroup_TotalTested2 != "0" & StudentSubGroup_TotalTested2 != "."
drop StudentSubGroup_TotalTested2
drop if _merge == 2
drop _merge


destring ProficientOrAbove_percent StudentSubGroup_TotalTested ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = round(ProficientOrAbove_percent*StudentSubGroup_TotalTested, 1)
tostring ProficientOrAbove_percent StudentSubGroup_TotalTested ProficientOrAbove_count, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."

drop StudentGroup_TotalTested
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested 

//StudentGroup_TotalTested Convention
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents = StudentGroup_TotalTested if StudentGroup == "All Students"
replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
replace StudentGroup_TotalTested = AllStudents if StudentGroup_TotalTested == "--" & DataLevel == 1
drop AllStudents

//Deriving Counts
foreach percent of varlist Lev*_percent {
	local count = subinstr("`percent'","percent","count",.)
	replace `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if regexm(StudentSubGroup_TotalTested, "[0-9]") !=0 & regexm(`percent', "[0-9]") !=0 & regexm(`count', "[0-9]") == 0 
}

//Participation
replace ParticipationRate = "--" if missing(ParticipationRate)

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/IL_AssmtData_2016.dta", replace

export delimited using "${output}/IL_AssmtData_2016.csv", replace


