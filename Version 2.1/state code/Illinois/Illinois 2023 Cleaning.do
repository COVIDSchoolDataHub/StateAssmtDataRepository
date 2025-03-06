* ILLINOIS

* File name: Illinois 2023 Cleaning
* Last update: 03/06/2025

*******************************************************
* Notes 

	* This do file uses 2023 IL *.dta files
	* These files are renamed, cleaned and reshaped.
	
	* NCES 2022 is merged. 
	* As of the last update, NCES_2022 is the latest data.
	* This file will need to be updated when NCES_2023 is available.
	
	* A breakpoint is created before ED Data Express 2022 Counts is merged.
	* This file will need to be updated when ED Data Express 2023 is available.
	
	* The usual and non-derivation outputs are created. 

*******************************************************
clear

*** Sci

*** Sci Participation

use "${Original_DTA}/IL_AssmtData_2023_sci_Participation_5.dta", clear
append using "${Original_DTA}/IL_AssmtData_2023_sci_Participation_8.dta"

** Dropping extra variables
drop County City DIST

** Rename existing variables
rename RCDTS StateAssignedSchID
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
rename NotIEP ParticipationRateNonIEP

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
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "NonIEP"

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

//DataLevel
replace DataLevel = "School" if DataLevel == "SCHL"
replace DataLevel = "District" if DataLevel == "DIST"
replace DataLevel = "State" if DataLevel == "STATE"
replace StateAssignedSchID = "" if DataLevel == "State"

save "${Original_DTA}/IL_AssmtData_2023_sci_Participation.dta", replace

**Sci performance Part 1
//Importing
use "$Original_DTA/IL_AssmtData_2023_sci_5.dta"
append using "$Original_DTA/IL_AssmtData_2023_sci_8.dta"

drop County DIST City AverageScaleScore

//Renaming
rename RCDTS StateAssignedSchID
rename SchoolorDistrictName SchName
rename StateDistrictSchool DataLevel
rename Grade GradeLevel
replace GradeLevel = "G" + GradeLevel
rename NotEL ProficientOrAbove_percentProf
rename NotIEP ProficientOrAbove_percentNonIEP

drop All Male Female White Black Hispanic Asian HawaiianPacificIslander NativeAmerican TwoorMoreRaces EL LowIncome NotLowIncome Migrant IEP

//Reshape
reshape long ProficientOrAbove_percent, i(StateAssignedSchID GradeLevel) j(StudentSubGroup, string)

//StudentSubGroup
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Prof"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "NonIEP"

//StudentGroup
gen StudentGroup = "EL Status"
replace StudentGroup = "Disability Status" if StudentSubGroup == "Non-SWD"

//ProficientOrAbove_percent
replace ProficientOrAbove_percent = string(real(ProficientOrAbove_percent)/100, "%9.3g")
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

forvalues n = 1/4{
	gen Lev`n'_percent = "--"
}

//Data Levels
replace DataLevel = "School" if DataLevel == "SCHL"
replace DataLevel = "District" if DataLevel == "DIST"
replace DataLevel = "State" if DataLevel == "STATE"
replace StateAssignedSchID = "" if DataLevel == "State"

save "${Original_DTA}/IL_AssmtData_2023_sci_lev_missing.dta", replace

*** Sci Performance Levels - Part 2

use "${Original_DTA}/IL_AssmtData_2023_sci_performance.dta", clear

//Renaming & Reshaping
rename RCDTS StateAssignedSchID
rename SchoolName SchName
rename DistrictName DistName
rename AggregationLevel DataLevel

rename *Emerging_Grade5 Lev1_Grade5*
rename *Emerging_Grade8 Lev1_Grade8*
rename *Developing_Grade5 Lev2_Grade5*
rename *Developing_Grade8 Lev2_Grade8* 
rename *Proficient_Grade5 Lev3_Grade5*
rename *Proficient_Grade8 Lev3_Grade8*
rename *Exemplary_Grade5 Lev4_Grade5*
rename *Exemplary_Grade8 Lev4_Grade8*

rename GenderNonBinary_Developing_Grade Lev2_Grade5GenderNonBinary
rename GenderNonBinary_Proficient_Grade Lev3_Grade5GenderNonBinary
rename CU Lev2_Grade8GenderNonBinary
rename CV Lev3_Grade8GenderNonBinary
rename *GenderNonBinary_ *GenderNB_
rename *GenderNonBinary *GenderNB_

drop *_Grade11 *_Grade1 FW FX Year
drop if StateAssignedSchID == ""

reshape long Lev1_Grade5 Lev1_Grade8 Lev2_Grade5 Lev2_Grade8 Lev3_Grade5 Lev3_Grade8 Lev4_Grade5 Lev4_Grade8, i(DataLevel DistName SchName StateAssignedSchID) j(StudentSubGroup) string

reshape long Lev1 Lev2 Lev3 Lev4, i(DataLevel DistName SchName StateAssignedSchID StudentSubGroup) j(GradeLevel) string

rename Lev* Lev*_percent

replace GradeLevel = subinstr(GradeLevel, "_Grade", "G0", 1)

//StudentGroup & StudentSubGroup
gen StudentGroup = "All Students"
replace StudentGroup = "Disability Status" if strpos(StudentSubGroup, "IEP") != 0
replace StudentGroup = "Economic Status" if strpos(StudentSubGroup, "LowIncome") != 0
replace StudentGroup = "EL Status" if strpos(StudentSubGroup, "LEP") != 0
replace StudentGroup = "Gender" if strpos(StudentSubGroup, "Gender") != 0
replace StudentGroup = "Homeless Enrolled Status" if strpos(StudentSubGroup, "Homeless") != 0
replace StudentGroup = "Military Connected Status" if strpos(StudentSubGroup, "Military") != 0
replace StudentGroup = "RaceEth" if strpos(StudentSubGroup, "Race") != 0
replace StudentGroup = "Migrant Status" if strpos(StudentSubGroup, "Migrant") != 0

replace StudentSubGroup = "All Students" if StudentSubGroup == "All_Students_"
replace StudentSubGroup = subinstr(StudentSubGroup, "_", "", 1)
replace StudentSubGroup = subinstr(StudentSubGroup, "Gender", "", 1)
replace StudentSubGroup = subinstr(StudentSubGroup, "Race", "", 1)
drop if inlist(StudentSubGroup, "CWD", "YIC")

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "AmerIndian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "LowIncome"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "Gender X" if StudentSubGroup == "NB"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "PacIsland"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NonLowIncome"
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "2More"

//Level Percents
forvalues n = 1/4{
	replace Lev`n'_percent = "*" if Lev`n'_percent == "NULL"
	replace Lev`n'_percent = string(real(Lev`n'_percent)/100, "%9.3g") if Lev`n'_percent != "*"
}

gen Lev5_percent = ""

replace Lev1_percent = string(1 - real(Lev2_percent) - real(Lev3_percent) - real(Lev4_percent), "%9.3g") if missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev4_percent))

replace Lev4_percent = string(1 - real(Lev1_percent) - real(Lev2_percent) - real(Lev3_percent), "%9.3g") if missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & !missing(real(Lev3_percent))

//ProficientOrAbove_percent
gen ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent), "%9.3g") if !missing(real(Lev3_percent)) & !missing(real(Lev4_percent))
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent), "%9.3g") if missing(real(ProficientOrAbove_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent))
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == ""

append using "${Original_DTA}/IL_AssmtData_2023_sci_lev_missing.dta"

//Merging with participation
replace StateAssignedSchID = "" if DataLevel == "State"
merge 1:1 DataLevel StateAssignedSchID GradeLevel StudentSubGroup using "${Original_DTA}/IL_AssmtData_2023_sci_Participation.dta"
replace ParticipationRate = "--" if _merge == 1
drop _merge

drop if ParticipationRate == "0" & StudentSubGroup != "All Students"

local variables "Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent"
foreach var of local variables {
	replace `var' = "--" if `var' == ""
}

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel !=3
replace DistName = "All Districts" if DataLevel == 1

//Other Variables
forvalues n = 1/4 {
	gen Lev`n'_count = "--"
}

gen Lev5_count = ""
gen ProficientOrAbove_count = "--"

gen ProficiencyCriteria = "Levels 3-4"
gen AvgScaleScore = "--"

gen Subject = "sci"
gen SchYear = "2022-23"

gen AssmtName = "ISA 2.0"
gen AssmtType = "Regular"

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

merge m:1 State_leaid using "${NCES_IL}/NCES_2022_District_IL.dta", update
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES_IL}/NCES_2022_School_IL.dta"
tab seasch if _merge == 1
drop if _merge == 2
drop _merge

save "${Original_DTA}/IL_AssmtData_2023_sci.dta", replace

**** ELA & Math

use "${Original_DTA}/IL_AssmtData_2023_all.dta", clear

** Dropping extra variables
drop County City DistrictType DistrictSize SchoolType GradesServed

** Rename existing variables
rename RCDTS StateAssignedSchID
rename Type DataLevel
rename SchoolName SchName
rename District DistName

//NEW RENAMING CODE BASED ON VARIABLE LABELS
//Original Data has problem with variable VN, fixing below
label var VN  "% Homeless students IAR Mathematics Level 1 - Grade 5"
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
	if strpos("`label'", "Children with Disabilities") !=0 {
		local sg = "CWD"
	}
	if strpos("`label'", "Homeless") !=0 {
		local sg = "home"
	}
	if strpos("`label'", "Migrant") !=0 {
		local sg = "mig"
	}
	if strpos("`label'", "Military") !=0 {
		local sg = "mil"
	}
	
	if strpos("`label'", "Youth") !=0 {
		local sg = "you"
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

drop *CWD
drop *you

rename NativeHawaiianorOtherPacif Lev1_percentela3hawaii
rename CD Lev2_percentela3hawaii
rename CE Lev3_percentela3hawaii
rename CF Lev4_percentela3hawaii
rename CG Lev5_percentela3hawaii
rename CH Lev1_percentmath3hawaii
rename CI Lev2_percentmath3hawaii
rename CJ Lev3_percentmath3hawaii
rename CK Lev4_percentmath3hawaii
rename CL Lev5_percentmath3hawaii

rename JU Lev1_percentela4hawaii
rename JV Lev2_percentela4hawaii
rename JW Lev3_percentela4hawaii
rename JX Lev4_percentela4hawaii
rename JY Lev5_percentela4hawaii
rename JZ Lev1_percentmath4hawaii
rename KA Lev2_percentmath4hawaii
rename KB Lev3_percentmath4hawaii
rename KC Lev4_percentmath4hawaii
rename KD Lev5_percentmath4hawaii

rename RM Lev1_percentela5hawaii
rename RN Lev2_percentela5hawaii
rename RO Lev3_percentela5hawaii
rename RP Lev4_percentela5hawaii
rename RQ Lev5_percentela5hawaii
rename RR Lev1_percentmath5hawaii
rename RS Lev2_percentmath5hawaii
rename RT Lev3_percentmath5hawaii
rename RU Lev4_percentmath5hawaii
rename RV Lev5_percentmath5hawaii

rename ZE Lev1_percentela6hawaii
rename ZF Lev2_percentela6hawaii
rename ZG Lev3_percentela6hawaii
rename ZH Lev4_percentela6hawaii
rename ZI Lev5_percentela6hawaii
rename ZJ Lev1_percentmath6hawaii
rename ZK Lev2_percentmath6hawaii
rename ZL Lev3_percentmath6hawaii
rename ZM Lev4_percentmath6hawaii
rename ZN Lev5_percentmath6hawaii

rename AGW Lev1_percentela7hawaii
rename AGX Lev2_percentela7hawaii
rename AGY Lev3_percentela7hawaii
rename AGZ Lev4_percentela7hawaii
rename AHA Lev5_percentela7hawaii
rename AHB Lev1_percentmath7hawaii
rename AHC Lev2_percentmath7hawaii
rename AHD Lev3_percentmath7hawaii
rename AHE Lev4_percentmath7hawaii
rename AHF Lev5_percentmath7hawaii

rename AOO Lev1_percentela8hawaii
rename AOP Lev2_percentela8hawaii
rename AOQ Lev3_percentela8hawaii
rename AOR Lev4_percentela8hawaii
rename AOS Lev5_percentela8hawaii
rename AOT Lev1_percentmath8hawaii
rename AOU Lev2_percentmath8hawaii
rename AOV Lev3_percentmath8hawaii
rename AOW Lev4_percentmath8hawaii
rename AOX Lev5_percentmath8hawaii

** Changing DataLevel
replace DataLevel = "State" if DataLevel == "Statewide"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Reshaping
reshape long Lev1_percentela3 Lev2_percentela3 Lev3_percentela3 Lev4_percentela3 Lev5_percentela3 Lev1_percentmath3 Lev2_percentmath3 Lev3_percentmath3 Lev4_percentmath3 Lev5_percentmath3 Lev1_percentela4 Lev2_percentela4 Lev3_percentela4 Lev4_percentela4 Lev5_percentela4 Lev1_percentmath4 Lev2_percentmath4 Lev3_percentmath4 Lev4_percentmath4 Lev5_percentmath4 Lev1_percentela5 Lev2_percentela5 Lev3_percentela5 Lev4_percentela5 Lev5_percentela5 Lev1_percentmath5 Lev2_percentmath5 Lev3_percentmath5 Lev4_percentmath5 Lev5_percentmath5 Lev1_percentela6 Lev2_percentela6 Lev3_percentela6 Lev4_percentela6 Lev5_percentela6 Lev1_percentmath6 Lev2_percentmath6 Lev3_percentmath6 Lev4_percentmath6 Lev5_percentmath6 Lev1_percentela7 Lev2_percentela7 Lev3_percentela7 Lev4_percentela7 Lev5_percentela7 Lev1_percentmath7 Lev2_percentmath7 Lev3_percentmath7 Lev4_percentmath7 Lev5_percentmath7 Lev1_percentela8 Lev2_percentela8 Lev3_percentela8 Lev4_percentela8 Lev5_percentela8 Lev1_percentmath8 Lev2_percentmath8 Lev3_percentmath8 Lev4_percentmath8 Lev5_percentmath8, i(StateAssignedSchID) j(StudentSubGroup)  string

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
replace StudentSubGroup = "Migrant" if StudentSubGroup == "mig"
replace StudentSubGroup = "Homeless" if StudentSubGroup == "home"
replace StudentSubGroup = "Military" if StudentSubGroup == "mil"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"

** Generating new variables
gen SchYear = "2022-23"

gen AssmtName = "IAR"
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

merge m:1 State_leaid using "${NCES_IL}/NCES_2022_District_IL.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES_IL}/NCES_2022_School_IL.dta"
drop if _merge == 2
drop _merge

**** Appending

append using "${Original_DTA}/IL_AssmtData_2023_sci.dta"

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
local vars State StateAbbrev StateFips SchYear DataLevel DistName DistType 	///
    SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID 		///
    StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual 			///
    CountyName CountyCode AssmtName AssmtType Subject GradeLevel 			///
    StudentGroup StudentGroup_TotalTested StudentSubGroup 					///
    StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count 			///
    Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent 			///
    Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria 				///
    ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 	///
    Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math 	///
    Flag_CutScoreChange_sci Flag_CutScoreChange_soc
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*******************************************************
// Creating a Breakpoint - to restore for non-derivation data processing
*******************************************************
save "$Temp/IL_2023_Breakpoint",replace

////////// EDFACTS ADDENDUM
use "$Temp/IL_2023_Breakpoint", clear

merge 1:1 DataLevel Subject StudentSubGroup GradeLevel NCESDistrictID NCESSchoolID using "$ED_Express/IL_cleaned_EDFacts_2022_ela_sci", keep(match master) nogen
drop StudentGroup_TotalTested StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested1 StudentSubGroup_TotalTested

egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject NCESDistrictID NCESSchoolID)
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
tostring StudentSubGroup_TotalTested StudentGroup_TotalTested, replace

replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."

//Deriving Counts where possible and Applying StudentGroup_TotalTested Convention
gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
sort DataLevel NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup StudentSubGroup
replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
destring StudentSubGroup_TotalTested, gen(UnsuppressedSSG) force
egen UnsuppressedSG = total(UnsuppressedSSG), by(DataLevel NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup)
replace StudentSubGroup_TotalTested = string(real(AllStudents) - UnsuppressedSG) if !missing(UnsuppressedSG) & UnsuppressedSG !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") ==0
replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == "." | StudentGroup_TotalTested == "0"
replace StudentGroup_TotalTested = AllStudents if Subject != "sci" & StudentGroup != "Migrant Status" & StudentGroup != "EL Status" & StudentGroup != "Military Connected Status" & StudentGroup != "Homeless Enrolled Status"
replace StudentGroup_TotalTested = AllStudents if Subject == "sci" & StudentGroup != "Migrant Status" & StudentGroup != "Military Connected Status" & StudentGroup != "Homeless Enrolled Status"

//Still some bad data (Migrant counts for example are the same as All Students Counts)
replace StudentSubGroup_TotalTested = "--" if StudentGroup_TotalTested == "--"

******************************
//Derivations//
******************************
//Deriving Counts
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`percent'","percent","count",.)
	replace `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if regexm(StudentSubGroup_TotalTested, "[0-9]") !=0 & regexm(`percent', "[0-9]") !=0 & regexm(`count', "[0-9]") == 0 
}

local Lev_percents "Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent"

foreach var of local Lev_percents {
	replace `var' = "--" if `var' == "." 
}


foreach var of varlist DistName SchName {
replace `var' = strtrim(`var')
replace `var' = stritrim(`var')
}

replace DistName = "N Pekin & Marquette Hght SD 102" if DistName == "N Pekin & Marquette Hght SD 10" 

replace ProficientOrAbove_count = string(real(Lev4_count) + real(Lev5_count)) if ProficiencyCriteria == "Levels 4-5" & !missing(real(Lev4_count)) &!missing(real(Lev5_count)) 

replace ProficientOrAbove_percent = string(round(real(Lev4_percent) + real(Lev5_percent), 0.001)) if ProficientOrAbove_percent != string(round(real(Lev4_percent) + real(Lev5_percent), 0.001)) & ProficiencyCriteria == "Levels 4-5" & !missing(real(Lev4_percent)) &!missing(real(Lev5_percent)) 

replace ProficientOrAbove_percent = "0" if real(ProficientOrAbove_percent) < 0
replace ProficientOrAbove_percent = "1" if ProficientOrAbove_percent == "1.001"

// fixing certain dist and sch names 
replace DistName ="Horizon Science Acad-McKinley Park Charter Sch" if NCESDistrictID=="1701410"
replace DistName ="Horizon Science Acad-Belmont Charter Sch" if NCESDistrictID=="1701412"
replace DistName ="Milford Area PSD 124" if NCESDistrictID=="1701416"
replace DistName ="Huntley Community School District 158" if NCESDistrictID=="1719830"
replace DistName ="Salt Fork Community Unit District 512" if NCESDistrictID=="1701418"
replace DistName ="Spring Garden Community Consolidated School District 178" if NCESDistrictID=="1701419"
replace DistName ="LEARN John and Kathy Schreiber Charter School" if NCESDistrictID=="1701423"
replace DistName ="Betty Shabazz International Charter School" if NCESDistrictID=="1701424"
replace DistName ="Community Unit School District No 196" if NCESDistrictID=="1712720"


replace SchName="Litchfield Elementary School" if NCESSchoolID== "172325002563"
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
replace DistName="Chicago Public Schools District 299" if NCESDistrictID=="1709930"

replace DistName = subinstr(DistName, "Comm ", "Community ", 1)

// fixing SG_TT
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

// removing edfacts participation data
replace ParticipationRate = "--" if Subject == "math" |  Subject == "ela" 	

replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested)) if real(ProficientOrAbove_count) > real(StudentSubGroup_TotalTested) & !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_count))

keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output.
save "${Output}/IL_AssmtData_2023", replace
export delimited "${Output}/IL_AssmtData_2023", replace

******************************
// Creating the non-derivation output
******************************
*Restoring the breakpoint
use "$Temp/IL_2023_Breakpoint", clear

//For the ND output, we do not merge with ED Data Express. 

//The code to generate group_id, derive counts, and applying StudentGroup_TotalTested Convention
//is deleted, since no counts are generated. 

local Lev_percents "Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent"

foreach var of local Lev_percents {
	replace `var' = "--" if `var' == "." 
}


foreach var of varlist DistName SchName {
replace `var' = strtrim(`var')
replace `var' = stritrim(`var')
}

replace DistName = "N Pekin & Marquette Hght SD 102" if DistName == "N Pekin & Marquette Hght SD 10" 

replace ProficientOrAbove_count = string(real(Lev4_count) + real(Lev5_count)) if ProficiencyCriteria == "Levels 4-5" & !missing(real(Lev4_count)) &!missing(real(Lev5_count)) 

replace ProficientOrAbove_percent = string(round(real(Lev4_percent) + real(Lev5_percent), 0.001)) if ProficientOrAbove_percent != string(round(real(Lev4_percent) + real(Lev5_percent), 0.001)) & ProficiencyCriteria == "Levels 4-5" & !missing(real(Lev4_percent)) &!missing(real(Lev5_percent)) 

replace ProficientOrAbove_percent = "0" if real(ProficientOrAbove_percent) < 0
replace ProficientOrAbove_percent = "1" if ProficientOrAbove_percent == "1.001"

// fixing certain dist and sch names 
replace DistName ="Horizon Science Acad-McKinley Park Charter Sch" if NCESDistrictID=="1701410"
replace DistName ="Horizon Science Acad-Belmont Charter Sch" if NCESDistrictID=="1701412"
replace DistName ="Milford Area PSD 124" if NCESDistrictID=="1701416"
replace DistName ="Huntley Community School District 158" if NCESDistrictID=="1719830"
replace DistName ="Salt Fork Community Unit District 512" if NCESDistrictID=="1701418"
replace DistName ="Spring Garden Community Consolidated School District 178" if NCESDistrictID=="1701419"
replace DistName ="LEARN John and Kathy Schreiber Charter School" if NCESDistrictID=="1701423"
replace DistName ="Betty Shabazz International Charter School" if NCESDistrictID=="1701424"
replace DistName ="Community Unit School District No 196" if NCESDistrictID=="1712720"


replace SchName="Litchfield Elementary School" if NCESSchoolID== "172325002563"
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
replace DistName="Chicago Public Schools District 299" if NCESDistrictID=="1709930"

replace DistName = subinstr(DistName, "Comm ", "Community ", 1)

// fixing SG_TT
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

// removing edfacts participation data
replace ParticipationRate = "--" if Subject == "math" |  Subject == "ela" 	

keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Non-Derivation Output.
save "${Output_ND}/IL_AssmtData_2023_ND", replace
export delimited "${Output_ND}/IL_AssmtData_2023_ND", replace
*End of Illinois Cleaning 2023.do
****************************************************
