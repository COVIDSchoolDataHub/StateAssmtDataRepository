clear
set more off

global raw "/Users/miramehta/Documents/Illinois/Original Data Files"
global output "/Users/miramehta/Documents/Illinois/Original Data Files"
global NCES "/Users/miramehta/Documents/Illinois/NCES"
global EDFacts "/Users/miramehta/Documents/EDFacts"

**** Science
use "${output}/IL_AssmtData_2024_sci", clear

//Rename Variables & Reshape Data
rename Type DataLevel
rename DistrictRCDTS StateAssignedDistID
rename SchoolRCDTS StateAssignedSchID
rename SchoolName SchName
rename District DistName

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
rename AV Lev2_Grade8GenderNonBinary
rename AW Lev3_Grade8GenderNonBinary

rename RaceAmericanIndianorAlaskaNa Lev1_Grade5RaceAIAN
rename EJ Lev2_Grade5RaceAIAN
rename EK Lev3_Grade5RaceAIAN
rename EL Lev4_Grade5RaceAIAN
rename EM Lev1_Grade8RaceAIAN
rename EN Lev2_Grade8RaceAIAN
rename EO Lev3_Grade8RaceAIAN
rename EP Lev4_Grade8RaceAIAN

rename RaceBlackorAfricanAmerican_Em Lev1_Grade5RaceBlack
rename RaceBlackorAfricanAmerican_De Lev2_Grade5RaceBlack
rename RaceBlackorAfricanAmerican_Pr Lev3_Grade5RaceBlack
rename RaceBlackorAfricanAmerican_Ex Lev4_Grade5RaceBlack
rename FK Lev1_Grade8RaceBlack
rename FL Lev2_Grade8RaceBlack
rename FM Lev3_Grade8RaceBlack
rename FN Lev4_Grade8RaceBlack

rename RaceHispanicorLatino_Emerging_ Lev1_Grade5RaceLatino
rename RaceHispanicorLatino_Developin Lev2_Grade5RaceLatino
rename RaceHispanicorLatino_Proficien Lev3_Grade5RaceLatino
rename RaceHispanicorLatino_Exemplary Lev4_Grade5RaceLatino
rename FW Lev1_Grade8RaceLatino
rename FX Lev2_Grade8RaceLatino
rename FY Lev3_Grade8RaceLatino
rename FZ Lev4_Grade8RaceLatino

rename RaceMiddleEasternorNorthAfri Lev1_Grade5RaceMENA
rename GF Lev2_Grade5RaceMENA
rename GG Lev3_Grade5RaceMENA
rename GH Lev4_Grade5RaceMENA
rename GI Lev1_Grade8RaceMENA
rename GJ Lev2_Grade8RaceMENA
rename GK Lev3_Grade8RaceMENA
rename GL Lev4_Grade8RaceMENA

rename RaceNativeHawaiianorOtherPac Lev1_Grade5RaceNHPI
rename GR Lev2_Grade5RaceNHPI
rename GS Lev3_Grade5RaceNHPI
rename GT Lev4_Grade5RaceNHPI
rename GU Lev1_Grade8RaceNHPI
rename GV Lev2_Grade8RaceNHPI
rename GW Lev3_Grade8RaceNHPI
rename GX Lev4_Grade8RaceNHPI

rename RaceTwoorMoreRaces_Emerging_G Lev1_Grade5RaceTwoorMore
rename RaceTwoorMoreRaces_Developing Lev2_Grade5RaceTwoorMore
rename RaceTwoorMoreRaces_Proficient Lev3_Grade5RaceTwoorMore
rename RaceTwoorMoreRaces_Exemplary_ Lev4_Grade5RaceTwoorMore
rename HG Lev1_Grade8RaceTwoorMore
rename HH Lev2_Grade8RaceTwoorMore
rename HI Lev3_Grade8RaceTwoorMore
rename HJ Lev4_Grade8RaceTwoorMore

rename *GenderNonBinary_ *GenderNB_
rename *GenderNonBinary *GenderNB_

drop SchoolYear AZ BA EQ ER ES ET FO FP FQ FR GA GB GC GD GM GN GO GP GY GZ HA HB HK HL HM HN *_Grade11 *_Grade1

reshape long Lev1_Grade5 Lev1_Grade8 Lev2_Grade5 Lev2_Grade8 Lev3_Grade5 Lev3_Grade8 Lev4_Grade5 Lev4_Grade8, i(DataLevel DistName SchName StateAssignedDistID StateAssignedSchID) j(StudentSubGroup) string

reshape long Lev1 Lev2 Lev3 Lev4, i(DataLevel DistName SchName StateAssignedSchID StudentSubGroup) j(GradeLevel) string

rename Lev* Lev*_percent

replace GradeLevel = subinstr(GradeLevel, "_Grade", "G0", 1)
gen Subject = "sci"

//Data Levels
replace StateAssignedDistID = substr(StateAssignedDistID, 1, 11) //updating to match formatting of IDs in ela/math file
replace StateAssignedDistID = "" if DataLevel == "State"
replace StateAssignedSchID = "" if DataLevel != "School"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

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

replace StudentSubGroup = "All Students" if StudentSubGroup == "All_"
replace StudentSubGroup = subinstr(StudentSubGroup, "_", "", 1)
replace StudentSubGroup = subinstr(StudentSubGroup, "Gender", "", 1)
replace StudentSubGroup = subinstr(StudentSubGroup, "Race", "", 1)
drop if StudentSubGroup == "CWD"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "AIAN"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "LowIncome"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "Gender X" if StudentSubGroup == "NB"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Latino"
replace StudentSubGroup = "Middle Eastern or North African" if StudentSubGroup == "MENA"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "NHPI"
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "TwoorMore"

gen StudentSubGroup_TotalTested = "--"
gen StudentGroup_TotalTested = "--"

//Assessment Information
gen SchYear = "2023-24"
gen AssmtName = "ISA 2.0"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"

//Remove Observations without Any Real Information
drop if Lev1_percent == "NULL" & Lev2_percent == "NULL" & Lev3_percent == "NULL" & Lev4_percent == "NULL" & StudentSubGroup != "All Students"
drop if Lev1_percent == "*" & Lev2_percent == "*" & Lev3_percent == "*" & Lev4_percent == "*" & StudentSubGroup != "All Students"
drop if StateAssignedDistID == "05016030800" //no real performance information or NCES information available for this district

//Performance Information
forvalues n = 1/4{
	replace Lev`n'_percent = string(real(Lev`n'_percent)/100, "%9.3f")
	replace Lev`n'_percent = "0" if Lev`n'_percent == "0.000"
	gen Lev`n'_count = "--"
}

gen ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent), "%9.3f") if Lev3_percent != "*" & Lev4_percent != "*"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "*"
gen ProficientOrAbove_count = "--"

gen Lev5_count = ""
gen Lev5_percent = ""
gen ParticipationRate = "--"
gen AvgScaleScore = "--"

save "${raw}/IL_sci_2024.dta", replace

**** ELA & Math

use "${output}/IL_AssmtData_2024_ela_mat.dta", clear

** Dropping extra variables

drop County City DistrictType SchoolType GradesServed //DistrictSize

// Children* Homeless* Youth* Migrant* Military*  DH-DP EG-ET FP-HB KY-LH LS-ML NG-OT SQ-SZ TK-UD UY-WL AAI-AAR ABC-ABV ACQ-AED AIA-AIJ AIU-AJN AKI-ALV APS-AQB AQM-ARF // DO NOT DROP SOME OF THESE FOR NEW VARIABLES

** Rename existing variables

rename RCDTS StateAssignedSchID
rename Type DataLevel
rename SchoolName SchName
rename District DistName

//NEW RENAMING CODE BASED ON VARIABLE LABELS

//Original Data has problem with variable VN, fixing below
label var UO  "% Homeless students IAR Mathematics Level 1 - Grade 5"
foreach var of varlist _all {
	local label: variable label `var'

	if strpos("`label'", "students") == 0 {
		continue
	}
// 	if strpos("`label'", "Hawaiian") !=0 {
// 		continue
// 	}
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
	
   if strpos("`label'", "NH") !=0 {
		local sg = "hawaii"
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

foreach v of varlist _all {
if strpos(`"`:var label `v''"', "Participation") |  strpos(`"`:var label `v''"', "Growth Percentile") |  strpos(`"`:var label `v''"', "Growth  Percentile") |  strpos(`"`:var label `v''"', "Proficiency Rate") {
drop `v'
}
}

drop *CWD
drop *you

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

drop if Lev1_percent == ""

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
gen SchYear = "2023-24"

gen AssmtName = "IAR"
gen AssmtType = "Regular"

gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

local level 1 2 3 4 5

foreach a of local level {
	gen Lev`a'_count = "--"
	replace Lev`a'_percent = string(round(real(Lev`a'_percent)/100, 0.001))
}

gen ProficientOrAbove_count = "--"

gen ProficientOrAbove_percent = string(real(Lev4_percent) + real(Lev5_percent))
tostring ProficientOrAbove_percent, replace force format("%9.3g")

foreach a of local level {
	tostring Lev`a'_percent, replace force format("%9.3g")
}

gen AvgScaleScore = "--"

gen ProficiencyCriteria = "Levels 4-5"

gen ParticipationRate = "--"

** Appending Science Data & Merging with NCES

gen StateAssignedDistID = substr(StateAssignedSchID,1,11)

append using "${raw}/IL_sci_2024.dta"

gen State_leaid = StateAssignedSchID
replace State_leaid = substr(State_leaid,1,11)
replace State_leaid = StateAssignedDistID if Subject == "sci"
replace State_leaid = "IL-" + substr(State_leaid,1,2) + "-" + substr(State_leaid,3,3) + "-" + substr(State_leaid,6,4) + "-" + substr(State_leaid,10,2)
replace StateAssignedSchID = "" if DataLevel != 3

gen seasch = StateAssignedSchID
replace seasch = subinstr(seasch,"IL-","",.)
replace seasch = substr(seasch,1,9) + substr(seasch,12,4)
replace seasch = "" if DataLevel != 3

merge m:1 State_leaid using "${NCES}/NCES_2022_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2022_School.dta"
drop if _merge == 2
drop _merge


/*
** Updating 2023 schools

replace SchType = 1 if SchName == "Big Timber Elementary School"
replace NCESSchoolID = "170855006869" if SchName == "Big Timber Elementary School"

replace SchType = 1 if seasch == "07016113A2005"
replace NCESSchoolID = "170729006891" if seasch == "07016113A2005"

replace SchType = 1 if SchName == "Stockton Middle School"
replace NCESSchoolID = "173798006880" if SchName == "Stockton Middle School"

replace SchLevel = -1 if SchName == "Big Timber Elementary School" | seasch == "07016113A2005" | SchName == "Stockton Middle School"
replace SchVirtual = -1 if SchName == "Big Timber Elementary School" | seasch == "07016113A2005" | SchName == "Stockton Middle School"
label def SchLevel -1 "Missing/not reported"
label def SchVirtual -1 "Missing/not reported"
*/



**** Appending


replace StateAbbrev = "IL" if DataLevel == 1
replace State = "Illinois" if DataLevel == 1
replace StateFips = 17 if DataLevel == 1
replace State_leaid = "" if DataLevel == 1
replace StateAssignedDistID = "" if DataLevel == 1

replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1

//New School 2024
replace NCESSchoolID = "172448006900" if StateAssignedSchID == "310453020262011"
replace SchType = "Regular school" if NCESSchoolID == "172448006900"
replace SchLevel = "Primary" if NCESSchoolID == "172448006900"
replace SchVirtual = "Missing/not reported" if NCESSchoolID == "172448006900"

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

drop State_leaid seasch

forvalues n = 1/5{
	replace Lev`n'_percent = "--" if  Lev`n'_percent == "."	
}

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/IL_AssmtData_2024_1.dta", replace

export delimited using "${output}/IL_AssmtData_2024_1.csv", replace

////////// EDFACTS ADDENDUM


use "${output}/IL_AssmtData_2024_1.dta", clear

merge 1:1 DataLevel Subject StudentSubGroup GradeLevel NCESDistrictID NCESSchoolID using "$EDFacts/2022/IL_cleaned_EDFacts_2022_ela_sci", keep(match master) nogen
drop StudentGroup_TotalTested StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested1 StudentSubGroup_TotalTested

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

replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."

//Deriving Counts where possible and Applying StudentGroup_TotalTested Convention
gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
destring StudentSubGroup_TotalTested, gen(UnsuppressedSSG) force
egen UnsuppressedSG = total(UnsuppressedSSG), by(DataLevel NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup)
replace StudentSubGroup_TotalTested = string(real(AllStudents) - UnsuppressedSG) if !missing(UnsuppressedSG) & UnsuppressedSG !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") ==0 & StudentSubGroup != "Middle Eastern or North African"
replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == "." | StudentGroup_TotalTested == "0"

//Deriving Counts
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`percent'","percent","count",.)
	replace `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if regexm(StudentSubGroup_TotalTested, "[0-9]") !=0 & regexm(`percent', "[0-9]") !=0 & regexm(`count', "[0-9]") == 0 
}


foreach var of varlist DistName SchName {
replace `var' = strtrim(`var')
replace `var' = stritrim(`var')
}

// CHECKING THIS: REPLACE FINAL VERSION IN FILES BACK TO 2021
replace DistName = "N Pekin & Marquette Hght SD 102" if DistName == "N Pekin & Marquette Hght SD 10" 

// Schtype 

replace SchType = "Regular school" if SchName == "Stockton Middle School" 
replace SchLevel = "Middle" if SchName == "Stockton Middle School" 
replace SchVirtual = "Missing/not reported" if SchName == "Stockton Middle School" 

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

replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "." 

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

// removing edfacts participation data
replace ParticipationRate = "--" if Subject == "math" |  Subject == "ela" 

replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested)) if real(ProficientOrAbove_count) > real(StudentSubGroup_TotalTested) & !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_count))

gen flag = .
forvalues n = 1/5{
	replace flag = 1 if Lev`n'_count == "0" & Lev`n'_percent != "0"
}

forvalues n = 1/5{
	replace Lev`n'_count = "*" if flag == 1
}

replace ProficientOrAbove_count = "*" if flag == 1
replace Lev5_count = "" if Subject == "sci"

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/IL_AssmtData_2024.dta", replace

export delimited using "${output}/IL_AssmtData_2024.csv", replace
