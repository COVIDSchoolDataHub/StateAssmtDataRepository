* NORTH DAKOTA

* File name: ND Cleaning 2018
* Last update: 03/05/2025

*******************************************************
* Notes

	* This do file imports 2018 Participation Data and the Original Data.
	* It saves it as *.dta file, renames and cleans it. 
	* NCES 2017 is merged.
	* A breakpoint is created before EDFacts 2018 Counts file is merged.  
	* The usual and non-derivation outputs are created. 

*******************************************************
clear all

//Import Data & Merge in Participation Data
import excel "$Original/ND_ParticipationData_2018.xlsx", clear firstrow
duplicates drop
save "$Original_DTA/ND_ParticipationData_2018.dta", replace

import excel "$Original/ND_OriginalData_2018_all.xlsx", clear firstrow
duplicates drop
merge 1:1 InstitutionName InstitutionID Grade Subject AssessmentType Accomodations Subgroup using "$Original_DTA/ND_ParticipationData_2018.dta"
drop if _merge == 2

tostring PercentTestedRangeLow, replace force
tostring PercentTestedRangeHigh, replace force

gen ParticipationRate = PercentTestedRangeLow + "-" + PercentTestedRangeHigh
replace ParticipationRate = PercentTestedRangeLow if PercentTestedRangeLow == PercentTestedRangeHigh
replace ParticipationRate = "--" if _merge == 1

drop _merge PercentTestedRangeLow PercentTestedRangeHigh

//Rename Variables
rename AcademicYear SchYear
rename InstitutionName SchName
rename InstitutionID StateAssignedSchID
rename Grade GradeLevel
rename AssessmentType AssmtType
rename Subgroup StudentSubGroup

//Filter for Only Desired Data
drop if AssmtType != "Reg"
replace AssmtType = "Regular"
drop Accomodations
drop if GradeLevel == "10" | GradeLevel == "11" | GradeLevel == "High School" | GradeLevel == "All Grades"
replace GradeLevel = "G0" + GradeLevel
replace GradeLevel = "G38" if GradeLevel == "G0Elementary/Middle School"

//Data Levels
gen DataLevel = "School"
replace DataLevel = "District" if strlen(StateAssignedSchID) == 5
gen DistName = ""
replace DistName = SchName if DataLevel == "District"
replace SchName = "All Schools" if DataLevel == "District"
gen StateAssignedDistID = ""
replace StateAssignedDistID = StateAssignedSchID if DataLevel == "District"
replace StateAssignedDistID = substr(StateAssignedSchID, 1, 5) if DataLevel == "School"
replace StateAssignedSchID = "" if DataLevel == "District"
replace DataLevel = "State" if DistName == "State of North Dakota"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

//Subject
replace Subject = "ela" if Subject == "Reading"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

//Student Groups & SubGroups
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian American"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Learner"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Low Income"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Low Income"
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP (student with disabilities)"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Non-IEP"
drop if StudentSubGroup == "All Others"
drop if StudentSubGroup == "IEP - Emotional Disturbance" | StudentSubGroup == "Non-IEP - Emotional Disturbance"
drop if StudentSubGroup == "Mobile Student" | StudentSubGroup == "Non-Mobile Student"
drop if StudentSubGroup == "Non-Former English Learner"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Gender" if StudentSubGroup == "Female" | StudentSubGroup == "Male"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "Migrant Status" if inlist(StudentSubGroup, "Migrant", "Non-Migrant")
replace StudentGroup = "Homeless Enrolled Status" if inlist(StudentSubGroup, "Homeless", "Non-Homeless")
replace StudentGroup = "Foster Care Status" if inlist(StudentSubGroup, "Foster Care", "Non-Foster Care")
replace StudentGroup = "Military Connected Status" if inlist(StudentSubGroup, "Military", "Non-Military")

//Fix Formatting & Generate Additional Variables
replace SchYear = "2017-18"
gen AssmtName = "North Dakota State Assessment (NDSA)"
gen Lev5_count = ""
gen Lev5_percent = ""
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3-4"
gen Flag_AssmtNameChange = "Y"
replace Flag_AssmtNameChange = "N" if Subject == "sci"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

gen State_leaid = "ND-" + StateAssignedDistID
gen seasch = substr(StateAssignedSchID, 1, 5) + "-" + substr(StateAssignedSchID, 6, 5)
merge m:1 State_leaid using "$NCES_ND/NCES_2017_District_ND.dta"
drop if _merge == 2
drop _merge

merge m:1 State_leaid seasch using "$NCES_ND/NCES_2017_School_ND.dta", update
drop if _merge == 2
drop _merge

//Clean Merged Data
replace State = "North Dakota"
replace StateAbbrev = "ND"
replace StateFips = 38
replace DistName = proper(DistName) if DataLevel == "School"

//Unmerged Schools
replace NCESDistrictID = "3820340" if StateAssignedDistID == "27014"
replace State_leaid = "NE-27014" if StateAssignedDistID == "27014"
replace DistType = "Regular local school district" if StateAssignedDistID == "27014"
replace DistCharter = "No" if StateAssignedDistID == "27014"
replace CountyName = "McKenzie County" if StateAssignedDistID == "27014"
replace CountyCode = "38053" if StateAssignedDistID == "27014"
replace NCESSchoolID = "382034000714" if SchName == "East Fairview Elementary School"
replace seasch = "27014-27411" if SchName == "East Fairview Elementary School"
replace SchType = 1 if SchName == "East Fairview Elementary School"
replace SchLevel = 1 if SchName == "East Fairview Elementary School"
replace SchVirtual = 0 if SchName == "East Fairview Elementary School"
replace DistName = "Yellowstone 14" if SchName == "East Fairview Elementary School"
replace DistLocale = "Rural, remote" if DistName == "Yellowstone 14"

//Renaming district/schools
replace DistName = "Hope-Page 85" if DistName == "Hope Page 85"
replace DistName = "May-Port CG 14" if DistName == "May-Port Cg 14"
replace DistName = "McClusky 19" if DistName == "Mcclusky 19"
replace DistName = "McKenzie Co 1" if DistName == "Mckenzie Co 1"
replace DistName = "TGU 60" if DistName == "Tgu 60"

*******************************************************
// Creating a Breakpoint - to restore for non-derivation data processing
*******************************************************
save "$Temp/ND_2018_Breakpoint",replace

//Merging with EDFacts Datasets
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

gen StudentSubGroup_TotalTested = "--"

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_ND}/edfactscount2018districtND.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
drop if _merge == 2
drop Count stnam _merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_ND}/edfactscount2018schoolND.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "0" & string(Count) != "."
drop if _merge == 2
drop Count stnam schnam _merge

destring StudentSubGroup_TotalTested, gen(num) force
gen dummy = num
replace dummy = 0 if DataLevel != 2
bys StudentSubGroup Subject GradeLevel: egen state = total(dummy)
replace num = state if DataLevel == 1 & state != 0 & state != .
tostring state, replace force
replace StudentSubGroup_TotalTested = state if DataLevel == 1 & state != "." & state != "0"
drop dummy

** Deriving More SubGroup Counts
bysort SchName DistName Subject GradeLevel: egen All = max(num)
bysort SchName DistName Subject GradeLevel: egen Econ = sum(num) if StudentGroup == "Economic Status"
bysort SchName DistName Subject GradeLevel: egen Disability = sum(num) if StudentGroup == "Disability Status"
bysort SchName DistName Subject GradeLevel: egen EL = sum(num) if StudentGroup == "EL Status"
bysort SchName DistName Subject GradeLevel: egen Foster = sum(num) if StudentGroup == "Foster Care Status"
bysort SchName DistName Subject GradeLevel: egen Homeless = sum(num) if StudentGroup == "Homeless Enrolled Status"
bysort SchName DistName Subject GradeLevel: egen Military = sum(num) if StudentGroup == "Military Connected Status"
replace num = All - Econ if StudentSubGroup == "Not Economically Disadvantaged" & Econ != 0
replace num = All - Disability if StudentSubGroup == "Non-SWD" & Disability != 0
replace num = All - EL if StudentSubGroup == "English Proficient" & EL != 0
replace num = All - Foster if StudentSubGroup == "Non-Foster Care" & Foster != 0
replace num = All - Homeless if StudentSubGroup == "Non-Homeless" & Homeless != 0
replace num = All - Military if StudentSubGroup == "Non-Military" & Military != 0
replace StudentSubGroup_TotalTested = string(num) if inlist(StudentSubGroup, "Not Economically Disadvantaged", "Non-SWD", "English Proficient", "Non-Foster Care", "Non-Homeless", "Non-Military") & num != .

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested = "--" if inlist(StudentSubGroup_TotalTested, "0", ".")
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "--" if inlist(StudentGroup_TotalTested, "0", ".")

//Proficiency Levels
gen ProfLow = ProficientRangeLow + AdvancedRangeLow
gen ProfHigh = ProficientRangeHigh + AdvancedRangeHigh
replace ProfHigh = 1 if ProfHigh > 1

rename NoviceRangeLow Lev1_pctLow
rename NoviceRangeHigh Lev1_pctHigh
rename PartiallyRangeLow Lev2_pctLow
rename PartiallyRangeHigh Lev2_pctHigh
rename ProficientRangeLow Lev3_pctLow
rename ProficientRangeHigh Lev3_pctHigh
rename AdvancedRangeLow Lev4_pctLow
rename AdvancedRangeHigh Lev4_pctHigh

******************************
//Derivations//
******************************
forvalues n = 1/4 {
	gen Lev`n'_countLow = num * Lev`n'_pctLow
	replace Lev`n'_countLow = round(Lev`n'_countLow)
	gen Lev`n'_countHigh = num * Lev`n'_pctHigh
	replace Lev`n'_countHigh = round(Lev`n'_countHigh)
	replace Lev`n'_countLow = . if num < 0
	replace Lev`n'_countHigh = . if num < 0
}

gen Prof_countLow = Lev3_countLow + Lev4_countLow
gen Prof_countHigh = Lev3_countHigh + Lev4_countHigh
replace Prof_countHigh = real(StudentSubGroup_TotalTested) if Prof_countHigh > real(StudentSubGroup_TotalTested) & StudentSubGroup_TotalTested != "--"

forvalues n = 1/4 {
	tostring Lev`n'_countLow, replace
	tostring Lev`n'_countHigh, replace
	tostring Lev`n'_pctLow, replace
	tostring Lev`n'_pctHigh, replace
	gen Lev`n'_count = Lev`n'_countLow + "-" + Lev`n'_countHigh
	replace Lev`n'_count = Lev`n'_countLow if Lev`n'_countLow == Lev`n'_countHigh
	replace Lev`n'_count = "--" if num < 0 
	replace Lev`n'_count = "--" if Lev`n'_count == "."
	gen Lev`n'_percent = Lev`n'_pctLow + "-" + Lev`n'_pctHigh
	replace Lev`n'_percent = Lev`n'_pctLow if Lev`n'_pctLow == Lev`n'_pctHigh
	drop Lev`n'_countLow Lev`n'_countHigh Lev`n'_pctLow Lev`n'_pctHigh
}

tostring ProfLow, replace format("%6.0g") force
tostring ProfHigh, replace format("%6.0g") force
gen ProficientOrAbove_percent = ProfLow + "-" + ProfHigh
replace ProficientOrAbove_percent = ProfLow if ProfLow == ProfHigh
tostring Prof_countLow, replace
tostring Prof_countHigh, replace
gen ProficientOrAbove_count = Prof_countLow + "-" + Prof_countHigh
replace ProficientOrAbove_count = Prof_countLow if Prof_countLow == Prof_countHigh
replace ProficientOrAbove_count = "--" if num < 0
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistType "District type as defined by NCES"
label var DistCharter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var SchYear "School year in which the data were reported"
label var AssmtName "Name of state assessment"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only"
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only"
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only"
label var Flag_CutScoreChange_sci "Flag denoting a change in scoring determinations in science from the prior year only"
label var Flag_CutScoreChange_soc "Flag denoting a change in scoring determinations in social studies from the prior year only"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested"
label var StudentGroup "Student demographic group"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested"
label var StudentSubGroup "Student demographic subgroup"
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested"
label var Lev1_count "Count of students within subgroup performing at Level 1"
label var Lev1_percent "Percent of students within subgroup performing at Level 1"
label var Lev2_count "Count of students within subgroup performing at Level 2"
label var Lev2_percent "Percent of students within subgroup performing at Level 2"
label var Lev3_count "Count of students within subgroup performing at Level 3"
label var Lev3_percent "Percent of students within subgroup performing at Level 3"
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"
label var Lev5_count "Count of students within subgroup performing at Level 5"
label var Lev5_percent "Percent of students within subgroup performing at Level 5"
label var AvgScaleScore "Avg scale score within subgroup"
label var ProficiencyCriteria "Levels included in determining proficiency status"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment"
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment"
label var ParticipationRate "Participation rate"

//Final Cleaning and dropping extra variables
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

*Exporting Output.
save "${Output}/ND_AssmtData_2018", replace
export delimited "${Output}/ND_AssmtData_2018", replace

******************************
// Creating the non-derivation output
******************************
*Restoring the breakpoint
use "$Temp/ND_2018_Breakpoint", clear

//Merging with EDFacts Datasets
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

gen StudentSubGroup_TotalTested = "--"

//For the ND output, we do not merge with EDFacts counts files. 

destring StudentSubGroup_TotalTested, gen(num) force
gen dummy = num
replace dummy = 0 if DataLevel != 2
bys StudentSubGroup Subject GradeLevel: egen state = total(dummy)
replace num = state if DataLevel == 1 & state != 0 & state != .
tostring state, replace force
replace StudentSubGroup_TotalTested = state if DataLevel == 1 & state != "." & state != "0"
drop dummy

** Deriving More SubGroup Counts
bysort SchName DistName Subject GradeLevel: egen All = max(num)
bysort SchName DistName Subject GradeLevel: egen Econ = sum(num) if StudentGroup == "Economic Status"
bysort SchName DistName Subject GradeLevel: egen Disability = sum(num) if StudentGroup == "Disability Status"
bysort SchName DistName Subject GradeLevel: egen EL = sum(num) if StudentGroup == "EL Status"
bysort SchName DistName Subject GradeLevel: egen Foster = sum(num) if StudentGroup == "Foster Care Status"
bysort SchName DistName Subject GradeLevel: egen Homeless = sum(num) if StudentGroup == "Homeless Enrolled Status"
bysort SchName DistName Subject GradeLevel: egen Military = sum(num) if StudentGroup == "Military Connected Status"
replace num = All - Econ if StudentSubGroup == "Not Economically Disadvantaged" & Econ != 0
replace num = All - Disability if StudentSubGroup == "Non-SWD" & Disability != 0
replace num = All - EL if StudentSubGroup == "English Proficient" & EL != 0
replace num = All - Foster if StudentSubGroup == "Non-Foster Care" & Foster != 0
replace num = All - Homeless if StudentSubGroup == "Non-Homeless" & Homeless != 0
replace num = All - Military if StudentSubGroup == "Non-Military" & Military != 0
replace StudentSubGroup_TotalTested = string(num) if inlist(StudentSubGroup, "Not Economically Disadvantaged", "Non-SWD", "English Proficient", "Non-Foster Care", "Non-Homeless", "Non-Military") & num != .

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested = "--" if inlist(StudentSubGroup_TotalTested, "0", ".")
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "--" if inlist(StudentGroup_TotalTested, "0", ".")

//Proficiency Levels
gen ProfLow = ProficientRangeLow + AdvancedRangeLow
gen ProfHigh = ProficientRangeHigh + AdvancedRangeHigh
replace ProfHigh = 1 if ProfHigh > 1

rename NoviceRangeLow Lev1_pctLow
rename NoviceRangeHigh Lev1_pctHigh
rename PartiallyRangeLow Lev2_pctLow
rename PartiallyRangeHigh Lev2_pctHigh
rename ProficientRangeLow Lev3_pctLow
rename ProficientRangeHigh Lev3_pctHigh
rename AdvancedRangeLow Lev4_pctLow
rename AdvancedRangeHigh Lev4_pctHigh


forvalues n = 1/4 {
	tostring Lev`n'_pctLow, replace
	tostring Lev`n'_pctHigh, replace
	gen Lev`n'_percent = Lev`n'_pctLow + "-" + Lev`n'_pctHigh
	replace Lev`n'_percent = Lev`n'_pctLow if Lev`n'_pctLow == Lev`n'_pctHigh
	drop Lev`n'_pctLow Lev`n'_pctHigh
}

tostring ProfLow, replace format("%6.0g") force
tostring ProfHigh, replace format("%6.0g") force
gen ProficientOrAbove_percent = ProfLow + "-" + ProfHigh
replace ProficientOrAbove_percent = ProfLow if ProfLow == ProfHigh

//Generating the count variables
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen ProficientOrAbove_count = "--"

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistType "District type as defined by NCES"
label var DistCharter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var SchYear "School year in which the data were reported"
label var AssmtName "Name of state assessment"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only"
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only"
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only"
label var Flag_CutScoreChange_sci "Flag denoting a change in scoring determinations in science from the prior year only"
label var Flag_CutScoreChange_soc "Flag denoting a change in scoring determinations in social studies from the prior year only"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested"
label var StudentGroup "Student demographic group"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested"
label var StudentSubGroup "Student demographic subgroup"
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested"
label var Lev1_count "Count of students within subgroup performing at Level 1"
label var Lev1_percent "Percent of students within subgroup performing at Level 1"
label var Lev2_count "Count of students within subgroup performing at Level 2"
label var Lev2_percent "Percent of students within subgroup performing at Level 2"
label var Lev3_count "Count of students within subgroup performing at Level 3"
label var Lev3_percent "Percent of students within subgroup performing at Level 3"
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"
label var Lev5_count "Count of students within subgroup performing at Level 5"
label var Lev5_percent "Percent of students within subgroup performing at Level 5"
label var AvgScaleScore "Avg scale score within subgroup"
label var ProficiencyCriteria "Levels included in determining proficiency status"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment"
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment"
label var ParticipationRate "Participation rate"

//Final Cleaning and dropping extra variables
keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Non-Derivation Output.
save "${Output_ND}/ND_AssmtData_2018_ND", replace
export delimited "${Output_ND}/ND_AssmtData_2018_ND", replace
*End of ND Cleaning 2018.do
****************************************************
