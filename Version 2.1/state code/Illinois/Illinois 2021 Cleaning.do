* ILLINOIS

* File name: Illinois 2021 Cleaning
* Last update: 03/06/2025

*******************************************************
* Notes

	* This do file uses 2021 IL *.dta files
	* These files are renamed, cleaned and reshaped.
	* NCES 2020 and 2021 (schools only) are merged. 
	* A breakpoint is created before EDFacts 2021 Counts and Participation Rates files are merged.  
	* The usual and non-derivation outputs are created. 

*******************************************************
clear

**** Sci

**Sci AvgScaleScore

//Importing
use "${Original_DTA}/IL_AssmtData_2021_sci_AvgScaleScore_5", clear
gen GradeLevel = "G05"
tempfile temp1
save "`temp1'", replace
use "$Original_DTA/IL_AssmtData_2021_sci_AvgScaleScore_8", clear
gen GradeLevel = "G08"
append using "`temp1'"
drop County DIST City H

//Renaming
rename RCDTS StateAssignedSchID
rename SchoolorDistrictName SchName
rename StateDistrictSchool DataLevel
rename ALL AvgScaleScore
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"
drop if missing(StateAssignedSchID)

//DataLevel
replace DataLevel = "School" if DataLevel == "SCHL"
replace DataLevel = "District" if DataLevel == "DIST"
replace DataLevel = "State" if DataLevel == "STATE"
replace StateAssignedSchID = "" if DataLevel == "State"

replace StateAssignedSchID = "310458000800000" if StateAssignedSchID == "310458000802001" & DataLevel == "District" //correcting one mislabeled observation to avoid duplicates & allow correct merging

//Saving
tempfile avgscalescore
save "`avgscalescore'", replace
clear

**Sci Participation
use "${Original_DTA}/IL_AssmtData_2021_sci_Participation_5.dta", clear
gen GradeLevel = "G05"
tempfile temp1
save "`temp1'", replace
use "${Original_DTA}/IL_AssmtData_2021_sci_Participation_8.dta", clear
gen GradeLevel = "G08"
append using "`temp1'"

drop County DIST City Grade

//Renaming
rename RCDTS StateAssignedSchID
rename SchoolorDistrictName SchName
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
rename Migrant ParticipationRateMig
rename IEP ParticipationRateIEP
rename NotIEP ParticipationRateNonIEP

drop if DataLevel == "" & StateAssignedSchID == ""

//Reshape
reshape long ParticipationRate, i(StateAssignedSchID GradeLevel) j(StudentSubGroup, string)

//StudentSubGroup
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
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "NonIEP"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Mig"

//StudentGroup
gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"

//Cleaning ParticipationRate
replace ParticipationRate = string((real(ParticipationRate)/100), "%9.3g") if !missing(ParticipationRate)
replace ParticipationRate = "*" if ParticipationRate == "."

//DataLevel
replace DataLevel = "School" if DataLevel == "SCHL"
replace DataLevel = "District" if DataLevel == "DIST"
replace DataLevel = "State" if DataLevel == "STATE"
replace StateAssignedSchID = "" if DataLevel == "State"

//Saving
tempfile participation
save "`participation'", replace
clear

**Sci performance Part 1
//Importing
use "${Original_DTA}/IL_AssmtData_2021_sci_5.dta"
append using "${Original_DTA}/IL_AssmtData_2021_sci_8.dta"

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

save "${Original_DTA}/IL_AssmtData_2021_sci_lev_missing.dta", replace

**Sci performance Part 2
use "${Original_DTA}/IL_AssmtData_2021_sci_performance.dta", clear

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

//ProficientOrAbove_percent
gen ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent), "%9.3g") if !missing(real(Lev3_percent)) & !missing(real(Lev4_percent))
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent), "%9.3g") if missing(real(ProficientOrAbove_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent))
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == ""

append using "${Original_DTA}/IL_AssmtData_2021_sci_lev_missing.dta"

//Merging with other files
replace StateAssignedSchID = "" if DataLevel == "State"
merge 1:1 StateAssignedSchID DataLevel GradeLevel StudentSubGroup using "`participation'"
replace ParticipationRate = "--" if _merge == 1
drop _merge
merge 1:1 StateAssignedSchID DataLevel GradeLevel StudentSubGroup using "`avgscalescore'"
tostring AvgScaleScore, replace
replace AvgScaleScore = "--" if _merge !=3
drop _merge

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

gen Subject = "sci"

** Merging with NCES
gen StateAssignedDistID = substr(StateAssignedSchID, 1,11)

gen leadingzero = 0
replace leadingzero = 1 if substr(StateAssignedSchID,15,1) == ""
replace StateAssignedSchID = "0" + StateAssignedSchID if leadingzero == 1
drop leadingzero

gen State_leaid = StateAssignedSchID
replace State_leaid = substr(State_leaid,1,11)
replace State_leaid = "IL-" + substr(State_leaid,1,2) + "-" + substr(State_leaid,3,3) + "-" + substr(State_leaid,6,4) + "-" + substr(State_leaid,10,2)
replace StateAssignedSchID = "" if DataLevel != 3

gen seasch = StateAssignedSchID
replace seasch = subinstr(seasch,"IL-","",.)
replace seasch = substr(seasch,1,9) + substr(seasch,12,4)
replace seasch = "" if DataLevel != 3

merge m:1 State_leaid using "${NCES_IL}/NCES_2020_District_IL.dta", update
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES_IL}/NCES_2020_School_IL.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES_IL}/NCES_2021_School_IL.dta", update
drop if _merge == 2
drop _merge

//Indicator Variables
gen SchYear = "2020-21"
gen AssmtName = "ISA 2.0"
gen AssmtType = "Regular"

//Saving
save "${Original_DTA}/IL_AssmtData_2021_sci.dta", replace


**** ELA & Math
use "${Original_DTA}/IL_AssmtData_2021_all.dta", clear

** Dropping extra variables
drop County City DistrictType DistrictSize SchoolType GradesServed

** Rename existing variables
rename RCDTS StateAssignedSchID
rename Type DataLevel
rename SchoolName SchName
rename District DistName

//NEW RENAMING CODE BASED ON VARIABLE LABELS
//Original Data has problem with variable UJ, fixing below
label var UJ  "% Homeless students IAR Mathematics Level 1 - Grade 5"
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
		local sg = "hom"
	}
	if strpos("`label'", "Migrant") !=0 {
		local sg = "mig"
	}
	if strpos("`label'", "Military") !=0 {
		local sg = "mil"
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

//Manual Renaming
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

rename JK Lev1_percentela4hawaii
rename JL Lev2_percentela4hawaii
rename JM Lev3_percentela4hawaii
rename JN Lev4_percentela4hawaii
rename JO Lev5_percentela4hawaii
rename JP Lev1_percentmath4hawaii
rename JQ Lev2_percentmath4hawaii
rename JR Lev3_percentmath4hawaii
rename JS Lev4_percentmath4hawaii
rename JT Lev5_percentmath4hawaii

rename QS Lev1_percentela5hawaii
rename QT Lev2_percentela5hawaii
rename QU Lev3_percentela5hawaii
rename QV Lev4_percentela5hawaii
rename QW Lev5_percentela5hawaii
rename QX Lev1_percentmath5hawaii
rename QY Lev2_percentmath5hawaii
rename QZ Lev3_percentmath5hawaii
rename RA Lev4_percentmath5hawaii
rename RB Lev5_percentmath5hawaii

rename YA Lev1_percentela6hawaii
rename YB Lev2_percentela6hawaii
rename YC Lev3_percentela6hawaii
rename YD Lev4_percentela6hawaii
rename YE Lev5_percentela6hawaii
rename YF Lev1_percentmath6hawaii
rename YG Lev2_percentmath6hawaii
rename YH Lev3_percentmath6hawaii
rename YI Lev4_percentmath6hawaii
rename YJ Lev5_percentmath6hawaii

rename AFI Lev1_percentela7hawaii
rename AFJ Lev2_percentela7hawaii
rename AFK Lev3_percentela7hawaii
rename AFL Lev4_percentela7hawaii
rename AFM Lev5_percentela7hawaii
rename AFN Lev1_percentmath7hawaii
rename AFO Lev2_percentmath7hawaii
rename AFP Lev3_percentmath7hawaii
rename AFQ Lev4_percentmath7hawaii
rename AFR Lev5_percentmath7hawaii

rename AMQ Lev1_percentela8hawaii
rename AMR Lev2_percentela8hawaii
rename AMS Lev3_percentela8hawaii
rename AMT Lev4_percentela8hawaii
rename AMU Lev5_percentela8hawaii
rename AMV Lev1_percentmath8hawaii
rename AMW Lev2_percentmath8hawaii
rename AMX Lev3_percentmath8hawaii
rename AMY Lev4_percentmath8hawaii
rename AMZ Lev5_percentmath8hawaii


** Changing DataLevel
replace DataLevel = "State" if DataLevel == "Statewide"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Reshaping
reshape long Lev1_percentela3 Lev2_percentela3 Lev3_percentela3 Lev4_percentela3 Lev5_percentela3 Lev1_percentmath3 Lev2_percentmath3 Lev3_percentmath3 Lev4_percentmath3 Lev5_percentmath3 Lev1_percentela4 Lev2_percentela4 Lev3_percentela4 Lev4_percentela4 Lev5_percentela4 Lev1_percentmath4 Lev2_percentmath4 Lev3_percentmath4 Lev4_percentmath4 Lev5_percentmath4 Lev1_percentela5 Lev2_percentela5 Lev3_percentela5 Lev4_percentela5 Lev5_percentela5 Lev1_percentmath5 Lev2_percentmath5 Lev3_percentmath5 Lev4_percentmath5 Lev5_percentmath5 Lev1_percentela6 Lev2_percentela6 Lev3_percentela6 Lev4_percentela6 Lev5_percentela6 Lev1_percentmath6 Lev2_percentmath6 Lev3_percentmath6 Lev4_percentmath6 Lev5_percentmath6 Lev1_percentela7 Lev2_percentela7 Lev3_percentela7 Lev4_percentela7 Lev5_percentela7 Lev1_percentmath7 Lev2_percentmath7 Lev3_percentmath7 Lev4_percentmath7 Lev5_percentmath7 Lev1_percentela8 Lev2_percentela8 Lev3_percentela8 Lev4_percentela8 Lev5_percentela8 Lev1_percentmath8 Lev2_percentmath8 Lev3_percentmath8 Lev4_percentmath8 Lev5_percentmath8, i(StateAssignedSchID SchName) j(StudentSubGroup) string

reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent, i(StateAssignedSchID SchName StudentSubGroup) j(Subject) string

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
replace StudentSubGroup = "Homeless" if StudentSubGroup == "hom"
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
gen SchYear = "2020-21"

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

merge m:1 State_leaid using "${NCES_IL}/NCES_2020_District_IL.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES_IL}/NCES_2020_School_IL.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES_IL}/NCES_2021_School_IL.dta", update
drop if _merge == 2
drop _merge


forvalues n = 1/5{
	tostring Lev`n'_percent, replace format("%9.3g") force
}

**** Appending
append using "${Original_DTA}/IL_AssmtData_2021_sci.dta"

replace StateAbbrev = "IL" if DataLevel == 1
replace State = "Illinois" if DataLevel == 1
replace StateFips = 17 if DataLevel == 1
replace State_leaid = "" if DataLevel == 1
replace StateAssignedDistID = "" if DataLevel == 1

replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1

** Generating new variables

gen Flag_AssmtNameChange = "Y"
replace Flag_AssmtNameChange = "N" if Subject != "sci"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Y"
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
save "$Temp/IL_2021_Breakpoint",replace

////////// EDFACTS ADDENDUM
use "$Temp/IL_2021_Breakpoint", clear

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_IL}/edfactscount2021districtIL.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_IL}/edfactspart2021districtIL.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_IL}/edfactscount2021schoolIL.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_IL}/edfactspart2021schoolIL.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

preserve
keep if DataLevel == 2
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
collapse (sum) StudentSubGroup_TotalTested2, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "$Temp/IL_AssmtData_2021_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "$Temp/IL_AssmtData_2021_State.dta"
tostring StudentSubGroup_TotalTested2, replace
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTested2 if StudentSubGroup_TotalTested2 != "0" & StudentSubGroup_TotalTested2 != "."
drop StudentSubGroup_TotalTested2
drop if _merge == 2
drop _merge

replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent)* real(StudentSubGroup_TotalTested), 1)) //Derivation

replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == ""

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

//StudentSubGroup_TotalTested Values Wrong for Certain SubGroups (Equal to all students value)
replace StudentSubGroup_TotalTested = "--" if StudentGroup == "Disability Status" | StudentGroup == "EL Status" | StudentGroup == "Migrant Status" | StudentGroup == "Homeless Enrolled Status" | StudentGroup == "Economic Status" | StudentGroup == "Military Connected Status"
replace StudentGroup_TotalTested = "--" if StudentGroup == "Disability Status" | StudentGroup == "EL Status" | StudentGroup == "Migrant Status" | StudentGroup == "Homeless Enrolled Status" | StudentGroup == "Economic Status" | StudentGroup == "Military Connected Status"

******************************
//Derivations//
******************************
//Deriving Counts
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`percent'","percent","count",.)
	replace `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if regexm(StudentSubGroup_TotalTested, "[0-9]") !=0 & regexm(`percent', "[0-9]") !=0 & regexm(`count', "[0-9]") == 0 
}

//Post Launch Review Response
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentSubGroup_TotalTested = StudentGroup_TotalTested if StudentSubGroup == "All Students" & StudentSubGroup_TotalTested != StudentGroup_TotalTested

//ParticipationRate Review Response
gen LE = "0-" if strpos(ParticipationRate, "LE") !=0
replace ParticipationRate = subinstr(ParticipationRate, "LE","",.)
replace ParticipationRate = LE + string(real(ParticipationRate)/100,"%9.3g") if !missing(LE)
replace ParticipationRate = "--" if missing(ParticipationRate)

foreach var of varlist DistName SchName {
replace `var' = strtrim(`var')
replace `var' = stritrim(`var')
}

replace DistName = "N Pekin & Marquette Hght SD 102" if DistName == "N Pekin & Marquette Hght SD 10" 

replace ProficientOrAbove_count = string(real(Lev4_count) + real(Lev5_count)) if ProficiencyCriteria == "Levels 4-5" & !missing(real(Lev4_count)) &!missing(real(Lev5_count)) 

replace ProficientOrAbove_percent = string(round(real(Lev4_percent) + real(Lev5_percent), 0.001)) if ProficientOrAbove_percent != string(round(real(Lev4_percent) + real(Lev5_percent), 0.001)) & ProficiencyCriteria == "Levels 4-5" & !missing(real(Lev4_percent)) &!missing(real(Lev5_percent)) `'

replace ProficientOrAbove_percent = "0" if real(ProficientOrAbove_percent) < 0
replace ProficientOrAbove_percent = "1" if ProficientOrAbove_percent == "1.001"

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


replace SchName = "Beverly Manor Elementary School" if NCESSchoolID == "174101004878"
replace SchName = "Bismarck-Henning Jr High School" if NCESSchoolID == "170639000308"
replace SchName = "Constance Lane Elementary School" if NCESSchoolID == "173451003580"
replace SchName = "Elizabeth Blackwell Elem School" if NCESSchoolID== "173474004427"
replace SchName = "Elizabeth Eichelberger Elem Sch" if NCESSchoolID == "173174006026"
replace SchName = "Forest Park Individual Ed School" if NCESSchoolID == "172058002332"
replace SchName = "Hoover Math and Science Academy" if NCESSchoolID== "173474003645"
replace SchName = "Hubert H Humphrey Middle School" if NCESSchoolID == "174007004027"
replace SchName = "L J Stevens Intermediate School" if NCESSchoolID == "174263004281"
replace SchName = "Lowpoint-Washburn Jr Sr High Sch" if NCESSchoolID == "174092004104"
replace SchName = "Richard Ira Jones Middle School" if NCESSchoolID == "173174005748"
replace SchName = "Salt Fork North Elementary School" if NCESSchoolID == "170141806358"
replace SchName = "Salt Fork South Elementary School" if NCESSchoolID == "170141806372"
replace SchName = "Walkers Grove Elementary School" if NCESSchoolID == "173174000139"
replace SchName = "Washington Jr High & Academy Prgm" if NCESSchoolID == "172058002348"
replace SchName = "Lincoln-Douglas Elementary School" if NCESSchoolID== "173300005059"
replace SchName = "Meredosia-Chambersburg Elem Sch" if NCESSchoolID== "172568004736"

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

keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output.
save "${Output}/IL_AssmtData_2021", replace
export delimited "${Output}/IL_AssmtData_2021", replace

******************************
// Creating the non-derivation output
******************************
*Restoring the breakpoint
use "$Temp/IL_2021_Breakpoint", clear

//For the ND output, we do not merge with EDFacts files. 

preserve
keep if DataLevel == 2
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
collapse (sum) StudentSubGroup_TotalTested2, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "$Temp/IL_AssmtData_2021_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "$Temp/IL_AssmtData_2021_State.dta"
tostring StudentSubGroup_TotalTested2, replace
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTested2 if StudentSubGroup_TotalTested2 != "0" & StudentSubGroup_TotalTested2 != "."
drop StudentSubGroup_TotalTested2
drop if _merge == 2
drop _merge

replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == ""

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

//StudentSubGroup_TotalTested Values Wrong for Certain SubGroups (Equal to all students value)
replace StudentSubGroup_TotalTested = "--" if StudentGroup == "Disability Status" | StudentGroup == "EL Status" | StudentGroup == "Migrant Status" | StudentGroup == "Homeless Enrolled Status" | StudentGroup == "Economic Status" | StudentGroup == "Military Connected Status"
replace StudentGroup_TotalTested = "--" if StudentGroup == "Disability Status" | StudentGroup == "EL Status" | StudentGroup == "Migrant Status" | StudentGroup == "Homeless Enrolled Status" | StudentGroup == "Economic Status" | StudentGroup == "Military Connected Status"

//Post Launch Review Response
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentSubGroup_TotalTested = StudentGroup_TotalTested if StudentSubGroup == "All Students" & StudentSubGroup_TotalTested != StudentGroup_TotalTested

foreach var of varlist DistName SchName {
replace `var' = strtrim(`var')
replace `var' = stritrim(`var')
}

replace DistName = "N Pekin & Marquette Hght SD 102" if DistName == "N Pekin & Marquette Hght SD 10" 

replace ProficientOrAbove_count = string(real(Lev4_count) + real(Lev5_count)) if ProficiencyCriteria == "Levels 4-5" & !missing(real(Lev4_count)) &!missing(real(Lev5_count)) 

replace ProficientOrAbove_percent = string(round(real(Lev4_percent) + real(Lev5_percent), 0.001)) if ProficientOrAbove_percent != string(round(real(Lev4_percent) + real(Lev5_percent), 0.001)) & ProficiencyCriteria == "Levels 4-5" & !missing(real(Lev4_percent)) &!missing(real(Lev5_percent)) `'

replace ProficientOrAbove_percent = "0" if real(ProficientOrAbove_percent) < 0
replace ProficientOrAbove_percent = "1" if ProficientOrAbove_percent == "1.001"

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


replace SchName = "Beverly Manor Elementary School" if NCESSchoolID == "174101004878"
replace SchName = "Bismarck-Henning Jr High School" if NCESSchoolID == "170639000308"
replace SchName = "Constance Lane Elementary School" if NCESSchoolID == "173451003580"
replace SchName = "Elizabeth Blackwell Elem School" if NCESSchoolID== "173474004427"
replace SchName = "Elizabeth Eichelberger Elem Sch" if NCESSchoolID == "173174006026"
replace SchName = "Forest Park Individual Ed School" if NCESSchoolID == "172058002332"
replace SchName = "Hoover Math and Science Academy" if NCESSchoolID== "173474003645"
replace SchName = "Hubert H Humphrey Middle School" if NCESSchoolID == "174007004027"
replace SchName = "L J Stevens Intermediate School" if NCESSchoolID == "174263004281"
replace SchName = "Lowpoint-Washburn Jr Sr High Sch" if NCESSchoolID == "174092004104"
replace SchName = "Richard Ira Jones Middle School" if NCESSchoolID == "173174005748"
replace SchName = "Salt Fork North Elementary School" if NCESSchoolID == "170141806358"
replace SchName = "Salt Fork South Elementary School" if NCESSchoolID == "170141806372"
replace SchName = "Walkers Grove Elementary School" if NCESSchoolID == "173174000139"
replace SchName = "Washington Jr High & Academy Prgm" if NCESSchoolID == "172058002348"
replace SchName = "Lincoln-Douglas Elementary School" if NCESSchoolID== "173300005059"
replace SchName = "Meredosia-Chambersburg Elem Sch" if NCESSchoolID== "172568004736"

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

keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Non-Derivation Output.
save "${Output_ND}/IL_AssmtData_2021_ND", replace
export delimited "${Output_ND}/IL_AssmtData_2021_ND", replace
*End of Illinois Cleaning 2021.do
****************************************************
