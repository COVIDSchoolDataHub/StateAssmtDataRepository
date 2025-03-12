* ILLINOIS

* File name: Illinois 2018 Cleaning
* Last update: 03/06/2025

*******************************************************
* Notes

	* This do file uses 2018 IL *.dta files
	* These files are renamed, cleaned and reshaped.
	* NCES 2017 is merged. 
	* A breakpoint is created before EDFacts 2018 Counts and Participation Rates files are merged.  
	* The usual and non-derivation outputs are created. 

*******************************************************
clear

**** Sci

*** Sci AvgScaleScore
use "${Original_DTA}/IL_AssmtData_2018_sci_AvgScaleScore_5.dta", clear
append using "${Original_DTA}/IL_AssmtData_2018_sci_AvgScaleScore_8.dta"

** Dropping extra variables
drop County City

** Rename existing variables
rename RCDTS StateAssignedSchID
drop DIST
rename SchoolorDistrictName SchName
rename Grade GradeLevel
rename StateDistrictSchool DataLevel
rename AverageScaleScore AvgScaleScore

** Generating new variables
replace GradeLevel = "G" + GradeLevel

gen StudentSubGroup = "All Students"

tostring AvgScaleScore, replace
replace AvgScaleScore = "--" if AvgScaleScore == " "

save "${Original_DTA}/IL_AssmtData_2018_sci_AvgScaleScore.dta", replace

*** Sci Participation
use "${Original_DTA}/IL_AssmtData_2018_sci_Participation_5.dta", clear
append using "${Original_DTA}/IL_AssmtData_2018_sci_Participation_8.dta"

** Dropping extra variables
drop County City 

** Rename existing variables
rename RCDTS StateAssignedSchID
drop DIST
rename SchoolorDistrictName SchName
rename Grade GradeLevel
rename StateDistrictSchool DataLevel
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
rename IEP ParticipationRateIEP
rename NotIEP ParticipationRateNotIEP

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

replace GradeLevel = "G" + GradeLevel

destring ParticipationRate, replace
replace ParticipationRate = ParticipationRate/100
tostring ParticipationRate, replace force format("%9.3g")
replace ParticipationRate = "*" if ParticipationRate == "."

save "${Original_DTA}/IL_AssmtData_2018_sci_Participation.dta", replace

*** Sci Performance Levels
use "${Original_DTA}/IL_AssmtData_2018_sci_5.dta", clear
append using "${Original_DTA}/IL_AssmtData_2018_sci_8.dta"

** Dropping extra variables
drop County City

** Rename existing variables
rename RCDTS StateAssignedSchID
drop DIST
rename SchoolorDistrictName SchName
rename Grade GradeLevel
rename StateDistrictSchool DataLevel
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

** Generating new variables
gen SchYear = "2017-18"

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

replace GradeLevel = "G" + GradeLevel

destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
gen Lev1_percent = 1 - ProficientOrAbove_percent
tostring ProficientOrAbove_percent, replace force format("%9.3g")
tostring Lev1_percent, replace force format("%9.3g")
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace Lev1_percent = "*" if Lev1_percent == "."

gen Lev2_percent = ProficientOrAbove_percent

merge 1:1 DataLevel StateAssignedSchID GradeLevel StudentSubGroup using "${Original_DTA}/IL_AssmtData_2018_sci_AvgScaleScore.dta"
drop _merge

replace AvgScaleScore = "--" if AvgScaleScore == ""

merge 1:1 DataLevel StateAssignedSchID GradeLevel StudentSubGroup using "${Original_DTA}/IL_AssmtData_2018_sci_Participation.dta"
drop if _merge == 2
drop _merge

drop if ParticipationRate == "0"

replace DataLevel = "School" if DataLevel == "SCHL"
replace DataLevel = "District" if DataLevel == "DIST"
replace DataLevel = "State" if DataLevel == "STATE"

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
replace State_leaid = "IL-" + substr(State_leaid,1,2) + "-" + substr(State_leaid,3,3) + "-" + substr(State_leaid,6,4) + "-" + substr(State_leaid,10,2)
replace StateAssignedSchID = "" if DataLevel != 3

gen seasch = StateAssignedSchID
replace seasch = subinstr(seasch,"IL-","",.)
replace seasch = substr(seasch,1,9) + substr(seasch,12,4)
replace seasch = "" if DataLevel != 3

merge m:1 State_leaid using "${NCES_IL}/NCES_2017_District_IL.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES_IL}/NCES_2017_School_IL.dta"
drop if _merge == 2
drop _merge

save "${Original_DTA}/IL_AssmtData_2018_sci.dta", replace

**** ELA & Math
use "${Original_DTA}/IL_AssmtData_2018_all.dta", clear

** Dropping extra variables
drop County City DistrictType DistrictSize SchoolType GradesServed 

** Rename existing variables
rename RCDTS StateAssignedSchID
rename Type DataLevel
rename SchoolName SchName
rename District DistName

//NEW RENAMING CODE BASED ON VARIABLE LABELS
foreach var of varlist _all {
	local label: variable label `var'
	if strpos("`label'", "students") == 0 {
		continue
	}
	if strpos("`label'", "Hawaiian") !=0 {
		continue
	}
	local subject = ""
	local sg = ""
	local proflevel = ""
	local gradelevel = ""
	
	**Subjects
	if strpos("`label'", "ELA") !=0 {
		local subject = "ela"
	}
	else {
		local subject = "math"
	}
	**SubGroups
	if strpos("`label'", "IEP") !=0 {
		local sg = "IEP"
	}
	if strpos("`label'", "Non-IEP") !=0 {
		local sg = "NonIEP"
	}
	if strpos("`label'", "All students") !=0 {
		local sg = "All"
	}
	if strpos("`label'", "Male") !=0 {
		local sg = "male"
	}
	if strpos("`label'", "Female") !=0 {
		local sg = "female"
	}
	if strpos("`label'", "White") !=0 {
		local sg = "white"
	}
	if strpos("`label'", "Black") !=0 {
		local sg = "black"
	}
	if strpos("`label'", "Hispanic") !=0 {
		local sg = "hisp"
	}
	if strpos("`label'", "Asian") !=0 {
		local sg = "asian"
	}
	if strpos("`label'", "Indian") !=0 {
		local sg = "native"
	}
	if strpos("`label'", "Two") !=0 {
		local sg = "two"
	}
	if strpos("`label'", "EL students") !=0 {
		local sg = "learner"
	}
	if strpos("`label'", "Non-Low Income") !=0 {
		local sg = "notdis"
	
	}
	if strpos("`label'", "Low Income") !=0 & strpos("`label'", "Non-Low Income") == 0 {
		local sg = "dis"
	}
	
	**Prof Levels
	forvalues n = 1/5 {
		if strpos("`label'", "Level `n'") !=0 {
			local proflevel = "`n'"
			break
		}
	}
	
	**
	forvalues n = 1/8 {
		if strpos("`label'", "Grade `n'") !=0 {
			local gradelevel = "`n'"
			break
			}
		}
rename `var' Lev`proflevel'_percent`subject'`gradelevel'`sg'
}

//Manual renaming for Hawaiian
rename NativeHawaiianorOtherPacific Lev1_percentela3hawaii
rename CD Lev2_percentela3hawaii
rename CE Lev3_percentela3hawaii
rename CF Lev4_percentela3hawaii
rename CG Lev5_percentela3hawaii
rename CH Lev1_percentmath3hawaii
rename CI Lev2_percentmath3hawaii
rename CJ Lev3_percentmath3hawaii
rename CK Lev4_percentmath3hawaii
rename CL Lev5_percentmath3hawaii

rename HW Lev1_percentela4hawaii
rename HX Lev2_percentela4hawaii
rename HY Lev3_percentela4hawaii
rename HZ Lev4_percentela4hawaii
rename IA Lev5_percentela4hawaii
rename IB Lev1_percentmath4hawaii
rename IC Lev2_percentmath4hawaii
rename ID Lev3_percentmath4hawaii
rename IE Lev4_percentmath4hawaii
rename IF Lev5_percentmath4hawaii

rename NQ Lev1_percentela5hawaii
rename NR Lev2_percentela5hawaii
rename NS Lev3_percentela5hawaii
rename NT Lev4_percentela5hawaii
rename NU Lev5_percentela5hawaii
rename NV Lev1_percentmath5hawaii
rename NW Lev2_percentmath5hawaii
rename NX Lev3_percentmath5hawaii
rename NY Lev4_percentmath5hawaii
rename NZ Lev5_percentmath5hawaii

rename TK Lev1_percentela6hawaii
rename TL Lev2_percentela6hawaii
rename TM Lev3_percentela6hawaii
rename TN Lev4_percentela6hawaii
rename TO Lev5_percentela6hawaii
rename TP Lev1_percentmath6hawaii
rename TQ Lev2_percentmath6hawaii
rename TR Lev3_percentmath6hawaii
rename TS Lev4_percentmath6hawaii
rename TT Lev5_percentmath6hawaii

rename ZE Lev1_percentela7hawaii
rename ZF Lev2_percentela7hawaii
rename ZG Lev3_percentela7hawaii
rename ZH Lev4_percentela7hawaii
rename ZI Lev5_percentela7hawaii
rename ZJ Lev1_percentmath7hawaii
rename ZK Lev2_percentmath7hawaii
rename ZL Lev3_percentmath7hawaii
rename ZM Lev4_percentmath7hawaii
rename ZN Lev5_percentmath7hawaii

rename AEY Lev1_percentela8hawaii
rename AEZ Lev2_percentela8hawaii
rename AFA Lev3_percentela8hawaii
rename AFB Lev4_percentela8hawaii
rename AFC Lev5_percentela8hawaii
rename AFD Lev1_percentmath8hawaii
rename AFE Lev2_percentmath8hawaii
rename AFF Lev3_percentmath8hawaii
rename AFG Lev4_percentmath8hawaii
rename AFH Lev5_percentmath8hawaii

** Changing DataLevel
replace DataLevel = "State" if DataLevel == "Statewide"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Reshaping
reshape long Lev1_percentela3 Lev2_percentela3 Lev3_percentela3 Lev4_percentela3 Lev5_percentela3 Lev1_percentmath3 Lev2_percentmath3 Lev3_percentmath3 Lev4_percentmath3 Lev5_percentmath3 Lev1_percentela4 Lev2_percentela4 Lev3_percentela4 Lev4_percentela4 Lev5_percentela4 Lev1_percentmath4 Lev2_percentmath4 Lev3_percentmath4 Lev4_percentmath4 Lev5_percentmath4 Lev1_percentela5 Lev2_percentela5 Lev3_percentela5 Lev4_percentela5 Lev5_percentela5 Lev1_percentmath5 Lev2_percentmath5 Lev3_percentmath5 Lev4_percentmath5 Lev5_percentmath5 Lev1_percentela6 Lev2_percentela6 Lev3_percentela6 Lev4_percentela6 Lev5_percentela6 Lev1_percentmath6 Lev2_percentmath6 Lev3_percentmath6 Lev4_percentmath6 Lev5_percentmath6 Lev1_percentela7 Lev2_percentela7 Lev3_percentela7 Lev4_percentela7 Lev5_percentela7 Lev1_percentmath7 Lev2_percentmath7 Lev3_percentmath7 Lev4_percentmath7 Lev5_percentmath7 Lev1_percentela8 Lev2_percentela8 Lev3_percentela8 Lev4_percentela8 Lev5_percentela8 Lev1_percentmath8 Lev2_percentmath8 Lev3_percentmath8 Lev4_percentmath8 Lev5_percentmath8, i(StateAssignedSchID) j(StudentSubGroup) string

reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent, i(StateAssignedSchID StudentSubGroup) j(Subject) string

drop if Lev1_percent == .

gen GradeLevel = Subject
replace GradeLevel = subinstr(GradeLevel,"ela","",.)
replace GradeLevel = subinstr(GradeLevel,"math","",.)
replace GradeLevel = "G0" + GradeLevel

replace Subject = "ela" if strpos(Subject,"ela") > 0
replace Subject = "math" if strpos(Subject,"math") > 0

** Replacing variables
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "hawaii"
replace StudentSubGroup = "White" if StudentSubGroup == "white"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "two"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "hisp"
replace StudentSubGroup = "Female" if StudentSubGroup == "female"
replace StudentSubGroup = "Male" if StudentSubGroup == "male"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "learner"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "notdis"
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "NonIEP"
gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Disability Status" if strpos(StudentSubGroup, "SWD") !=0

** Generating new variables
gen SchYear = "2017-18"

gen AssmtName = "PARCC"
gen AssmtType = "Regular"

gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

local level 1 2 3 4 5

foreach a of local level {
	gen Lev`a'_count = "--"
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
replace State_leaid = "IL-" + substr(State_leaid,1,2) + "-" + substr(State_leaid,3,3) + "-" + substr(State_leaid,6,4) + "-" + substr(State_leaid,10,2)
replace StateAssignedSchID = "" if DataLevel != 3

gen seasch = StateAssignedSchID
replace seasch = subinstr(seasch,"IL-","",.)
replace seasch = substr(seasch,1,9) + substr(seasch,12,4)
replace seasch = "" if DataLevel != 3

merge m:1 State_leaid using "${NCES_IL}/NCES_2017_District_IL.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES_IL}/NCES_2017_School_IL.dta"
drop if _merge == 2
drop _merge

**** Appending
append using "${Original_DTA}/IL_AssmtData_2018_sci.dta"

replace StateAbbrev = "IL" if DataLevel == 1
replace State = "Illinois" if DataLevel == 1
replace StateFips = 17 if DataLevel == 1
replace State_leaid = "" if DataLevel == 1
replace StateAssignedDistID = "" if DataLevel == 1

replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1

** Generating new variables
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

//Cleaning and dropping extra variables
local vars State StateAbbrev StateFips SchYear DataLevel DistName SchName ///
	NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID ///
	AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested ///
	StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent ///
	Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent ///
	Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ///
	ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA ///
	Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType ///
	DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*******************************************************
// Creating a Breakpoint - to restore for non-derivation data processing
*******************************************************
save "$Temp/IL_2018_Breakpoint",replace

////////// EDFACTS ADDENDUM
use "$Temp/IL_2018_Breakpoint", clear

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_IL}/edfactscount2018districtIL.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_IL}/edfactspart2018districtIL.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_IL}/edfactscount2018schoolIL.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_IL}/edfactspart2018schoolIL.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

preserve
keep if DataLevel == 2
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
collapse (sum) StudentSubGroup_TotalTested2, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "$Temp/IL_AssmtData_2018_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "$Temp/IL_AssmtData_2018_State.dta"
tostring StudentSubGroup_TotalTested2, replace
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTested2 if StudentSubGroup_TotalTested2 != "0" & StudentSubGroup_TotalTested2 != "."
drop StudentSubGroup_TotalTested2
drop if _merge == 2
drop _merge


destring ProficientOrAbove_percent StudentSubGroup_TotalTested ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = round(ProficientOrAbove_percent*StudentSubGroup_TotalTested, 1) // Derivation
tostring ProficientOrAbove_percent StudentSubGroup_TotalTested ProficientOrAbove_count, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."

drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel != 3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

tostring StudentSubGroup_TotalTested, replace
tostring StudentGroup_TotalTested, replace

//StudentGroup_TotalTested Convention & Derivations
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents = StudentGroup_TotalTested if StudentGroup == "All Students"
replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
replace StudentGroup_TotalTested = AllStudents if StudentGroup != "EL Status" & StudentGroup != "Military Connected Status" & StudentGroup != "Homeless Enrolled Status" & StudentGroup != "Migrant Status"
destring StudentSubGroup_TotalTested, gen(UnsuppressedSSG) force
egen UnsuppressedSG = total(UnsuppressedSSG), by(DataLevel NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup)
replace StudentSubGroup_TotalTested = string(real(AllStudents) - UnsuppressedSG) if !missing(UnsuppressedSG) & UnsuppressedSG !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") ==0

******************************
//Derivations//
******************************
//Deriving Counts
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`percent'","percent","count",.)
	replace `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if regexm(StudentSubGroup_TotalTested, "[0-9]") !=0 & regexm(`percent', "[0-9]") !=0 & regexm(`count', "[0-9]") == 0 
}

//ParticipationRate Review Response
gen LE = "0-" if strpos(ParticipationRate, "LE") !=0
replace ParticipationRate = subinstr(ParticipationRate, "LE","",.)
replace ParticipationRate = LE + string(real(ParticipationRate)/100,"%9.3g") if !missing(LE)
replace ParticipationRate = "--" if missing(ParticipationRate)


foreach var of varlist DistName SchName {
replace `var' = strtrim(`var')
replace `var' = stritrim(`var')
}

drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel != 3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

replace ProficientOrAbove_count = string(real(Lev4_count) + real(Lev5_count)) if ProficiencyCriteria == "Levels 4-5" & !missing(real(Lev4_count)) &!missing(real(Lev5_count)) 
replace ProficientOrAbove_percent = string(round(real(Lev4_percent) + real(Lev5_percent), 0.001)) if ProficientOrAbove_percent != string(round(real(Lev4_percent) + real(Lev5_percent), 0.001)) & ProficiencyCriteria == "Levels 4-5" & !missing(real(Lev4_percent)) &!missing(real(Lev5_percent)) 

replace DistName ="Horizon Science Acad-McKinley Park Charter Sch" if NCESDistrictID=="1701410"
replace DistName ="Horizon Science Acad-Belmont Charter Sch" if NCESDistrictID=="1701412"
replace DistName ="Milford Area PSD 124" if NCESDistrictID=="1701416"
replace DistName ="Huntley Community School District 158" if NCESDistrictID=="1719830"
replace DistName ="Salt Fork Community Unit District 512" if NCESDistrictID=="1701418"
replace DistName ="Spring Garden Community Consolidated School District 178" if NCESDistrictID=="1701419"
replace DistName ="LEARN John and Kathy Schreiber Charter School" if NCESDistrictID=="1701423"
replace DistName ="Betty Shabazz International Charter School" if NCESDistrictID=="1701424"
replace DistName ="Community Unit School District No 196" if NCESDistrictID=="1712720"
replace DistName="Chicago Public Schools District 299" if NCESDistrictID=="1709930"

replace SchName = "Laraway School" if NCESSchoolID == "172205002473"

replace	SchName = "Acero Chtr Sch Network - Bartolome de las Casas Elem Sch" if NCESSchoolID== "170993006448"			
replace	SchName = "Acero Chtr Sch Network - Brighton Park Elem School" if NCESSchoolID== "170993006474"			
replace	SchName = "Acero Chtr Sch Network - Carlos Fuentes Elem School" if NCESSchoolID== "170993006481"		
replace	SchName = "Acero Chtr Sch Network - Esmeralda Santiago Elem Sch" if NCESSchoolID== "170993006521"				
replace	SchName = "Acero Chtr Sch Network - Jovita Idar Elem School" if NCESSchoolID== "170993006505"			
replace	SchName = "Acero Chtr Sch Network - Octavio Paz Elem School" if NCESSchoolID== "170993006482"			
replace	SchName = "Acero Chtr Sch Network - Officer Donald J Marquez Elem" if NCESSchoolID== "170993006497"			
replace	SchName = "Acero Chtr Sch Network - PFC Omar E Torres Elem Sch" if NCESSchoolID== "170993006522"		
replace	SchName = "Acero Chtr Sch Network - Rufino Tamayo Elem Sch" if NCESSchoolID== "170993006455"			
replace	SchName = "Acero Chtr Sch Network - SPC Daniel Zizumbo Elem Sch" if NCESSchoolID== "170993006444"				
replace	SchName = "Acero Chtr Sch Network- Sandra Cisneros Elem School" if NCESSchoolID== "170993006436"		
replace	SchName = "Acero Chtr Sch Newtwork - Roberto Clemente Elem School" if NCESSchoolID== "170993006524"		
replace	SchName = "EPG Middle School" if NCESSchoolID == "170032605635"			
replace	SchName = "KIPP Chicago Charters - Ascend Academy" if NCESSchoolID== "170993006509"		
replace	SchName = "Legacy Acad of Excellence Charter Sch" if NCESSchoolID == "173451006077"		
replace	SchName = "MacArthur International Spanish Academy" if NCESSchoolID== "173474003649"		
replace	SchName ="KIPP Chicago Charter School - KIPP One Academy" if NCESSchoolID== "170993006520"			
replace	SchName = "Horizon Sci Academy - Southwest Charter" if NCESSchoolID== "170993006331"			
replace	SchName = "Nicholson Technology Acad Elem Sch" if NCESSchoolID== "170993000597"		
replace	SchName= "A C Thompson Elem School" if NCESSchoolID== "173451003593"		
replace	SchName= "Acero Chtr Sch Network- Sor Juana Ines de la Cruz K-12" if NCESSchoolID == "170993006508"		
replace	SchName= "Asian Human Services -Passage Chrtr" if NCESSchoolID== "170993005682"			
replace	SchName= "Colonel George Iles Elementary School" if NCESSchoolID== "173300005056"				
replace	SchName= "Sarah Atwater Denman Elementary School" if NCESSchoolID== "173300005055"			
replace	SchName= "Thomas S Baldwin Elementary School" if NCESSchoolID== "173300003359"			
replace	SchName= "Waverly Junior/Senior High School" if NCESSchoolID== "174128004145"	

keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output.
save "${Output}/IL_AssmtData_2018", replace
export delimited "${Output}/IL_AssmtData_2018", replace

******************************
// Creating the non-derivation output
******************************
*Restoring the breakpoint
use "$Temp/IL_2018_Breakpoint", clear

//For the ND output, we do not merge with EDFacts files. 

preserve
keep if DataLevel == 2
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
collapse (sum) StudentSubGroup_TotalTested2, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "$Temp/IL_AssmtData_2018_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "$Temp/IL_AssmtData_2018_State.dta"
tostring StudentSubGroup_TotalTested2, replace
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTested2 if StudentSubGroup_TotalTested2 != "0" & StudentSubGroup_TotalTested2 != "."
drop StudentSubGroup_TotalTested2
drop if _merge == 2
drop _merge

tostring ProficientOrAbove_percent StudentSubGroup_TotalTested ProficientOrAbove_count, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."

drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel != 3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

tostring StudentSubGroup_TotalTested, replace
tostring StudentGroup_TotalTested, replace

//StudentGroup_TotalTested Convention & Derivations
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents = StudentGroup_TotalTested if StudentGroup == "All Students"
replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
replace StudentGroup_TotalTested = AllStudents if StudentGroup != "EL Status" & StudentGroup != "Military Connected Status" & StudentGroup != "Homeless Enrolled Status" & StudentGroup != "Migrant Status"
destring StudentSubGroup_TotalTested, gen(UnsuppressedSSG) force
egen UnsuppressedSG = total(UnsuppressedSSG), by(DataLevel NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup)
replace StudentSubGroup_TotalTested = string(real(AllStudents) - UnsuppressedSG) if !missing(UnsuppressedSG) & UnsuppressedSG !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") ==0

foreach var of varlist DistName SchName {
replace `var' = strtrim(`var')
replace `var' = stritrim(`var')
}

drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel != 3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

replace ProficientOrAbove_count = string(real(Lev4_count) + real(Lev5_count)) if ProficiencyCriteria == "Levels 4-5" & !missing(real(Lev4_count)) &!missing(real(Lev5_count)) 
replace ProficientOrAbove_percent = string(round(real(Lev4_percent) + real(Lev5_percent), 0.001)) if ProficientOrAbove_percent != string(round(real(Lev4_percent) + real(Lev5_percent), 0.001)) & ProficiencyCriteria == "Levels 4-5" & !missing(real(Lev4_percent)) &!missing(real(Lev5_percent)) 

replace DistName ="Horizon Science Acad-McKinley Park Charter Sch" if NCESDistrictID=="1701410"
replace DistName ="Horizon Science Acad-Belmont Charter Sch" if NCESDistrictID=="1701412"
replace DistName ="Milford Area PSD 124" if NCESDistrictID=="1701416"
replace DistName ="Huntley Community School District 158" if NCESDistrictID=="1719830"
replace DistName ="Salt Fork Community Unit District 512" if NCESDistrictID=="1701418"
replace DistName ="Spring Garden Community Consolidated School District 178" if NCESDistrictID=="1701419"
replace DistName ="LEARN John and Kathy Schreiber Charter School" if NCESDistrictID=="1701423"
replace DistName ="Betty Shabazz International Charter School" if NCESDistrictID=="1701424"
replace DistName ="Community Unit School District No 196" if NCESDistrictID=="1712720"
replace DistName="Chicago Public Schools District 299" if NCESDistrictID=="1709930"

replace SchName = "Laraway School" if NCESSchoolID == "172205002473"

replace	SchName = "Acero Chtr Sch Network - Bartolome de las Casas Elem Sch" if NCESSchoolID== "170993006448"			
replace	SchName = "Acero Chtr Sch Network - Brighton Park Elem School" if NCESSchoolID== "170993006474"			
replace	SchName = "Acero Chtr Sch Network - Carlos Fuentes Elem School" if NCESSchoolID== "170993006481"		
replace	SchName = "Acero Chtr Sch Network - Esmeralda Santiago Elem Sch" if NCESSchoolID== "170993006521"				
replace	SchName = "Acero Chtr Sch Network - Jovita Idar Elem School" if NCESSchoolID== "170993006505"			
replace	SchName = "Acero Chtr Sch Network - Octavio Paz Elem School" if NCESSchoolID== "170993006482"			
replace	SchName = "Acero Chtr Sch Network - Officer Donald J Marquez Elem" if NCESSchoolID== "170993006497"			
replace	SchName = "Acero Chtr Sch Network - PFC Omar E Torres Elem Sch" if NCESSchoolID== "170993006522"		
replace	SchName = "Acero Chtr Sch Network - Rufino Tamayo Elem Sch" if NCESSchoolID== "170993006455"			
replace	SchName = "Acero Chtr Sch Network - SPC Daniel Zizumbo Elem Sch" if NCESSchoolID== "170993006444"				
replace	SchName = "Acero Chtr Sch Network- Sandra Cisneros Elem School" if NCESSchoolID== "170993006436"		
replace	SchName = "Acero Chtr Sch Newtwork - Roberto Clemente Elem School" if NCESSchoolID== "170993006524"		
replace	SchName = "EPG Middle School" if NCESSchoolID == "170032605635"			
replace	SchName = "KIPP Chicago Charters - Ascend Academy" if NCESSchoolID== "170993006509"		
replace	SchName = "Legacy Acad of Excellence Charter Sch" if NCESSchoolID == "173451006077"		
replace	SchName = "MacArthur International Spanish Academy" if NCESSchoolID== "173474003649"		
replace	SchName ="KIPP Chicago Charter School - KIPP One Academy" if NCESSchoolID== "170993006520"			
replace	SchName = "Horizon Sci Academy - Southwest Charter" if NCESSchoolID== "170993006331"			
replace	SchName = "Nicholson Technology Acad Elem Sch" if NCESSchoolID== "170993000597"		
replace	SchName= "A C Thompson Elem School" if NCESSchoolID== "173451003593"		
replace	SchName= "Acero Chtr Sch Network- Sor Juana Ines de la Cruz K-12" if NCESSchoolID == "170993006508"		
replace	SchName= "Asian Human Services -Passage Chrtr" if NCESSchoolID== "170993005682"			
replace	SchName= "Colonel George Iles Elementary School" if NCESSchoolID== "173300005056"				
replace	SchName= "Sarah Atwater Denman Elementary School" if NCESSchoolID== "173300005055"			
replace	SchName= "Thomas S Baldwin Elementary School" if NCESSchoolID== "173300003359"			
replace	SchName= "Waverly Junior/Senior High School" if NCESSchoolID== "174128004145"	

keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Non-Derivation Output.
save "${Output_ND}/IL_AssmtData_2018_ND", replace
export delimited "${Output_ND}/IL_AssmtData_2018_ND", replace
*End of Illinois Cleaning 2018.do
****************************************************
