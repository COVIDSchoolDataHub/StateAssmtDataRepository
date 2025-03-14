*******************************************************
* MARYLAND

* File name: MD_2016
* Last update: 3/14/2025

*******************************************************
* Notes

	* This do file imports 2016 *.csv MD data and saves it as a *.dta.
	* The files are cleaned and variables are renamed.
	* NCES 2015 is merged. 
	* A breakpoint is created before derivations. 
	* This breakpoint is restored for the non-derivation output. 
	* Tempory (with derivations) and non-derivation outputs are created for 2015.
	
*******************************************************

clear

//Importing & Combining Files
tempfile temp1
save "`temp1'", emptyok
import delimited "${Original}/MD_OriginalData_2016_ela_mat.csv", case(preserve) clear
rename Level1DidnotyetmeetexpectationsC Lev1_count
rename Level1DidnotyetmeetexpectationsP Lev1_percent
rename Level2PartiallymetexpectationsCo Lev2_count
rename Level2PartiallymetexpectationsPe Lev2_percent
rename Level3ApproachedexpectationsCoun Lev3_count
rename Level3ApproachedexpectationsPerc Lev3_percent
rename Level4MetexpectationsCount Lev4_count
rename Level4MetexpectationsPercent Lev4_percent
rename Level5ExceededexpectationsCount Lev5_count
rename Level5ExceededexpectationsPercen Lev5_percent
append using "`temp1'"
save "`temp1'", replace

import delimited "${Original}/MD_OriginalData_2016_ela_mat_par.csv", case(preserve) clear
merge 1:1 LEANumber SchoolNumber Assessment using "`temp1'", nogen
save "`temp1'", replace

import delimited "${Original}/MD_OriginalData_2016_sci", case(preserve) clear
rename AdvancedCount Lev3_count
rename AdvancedPercent Lev3_percent
rename ProficientCount Lev2_count
rename ProficientPercent Lev2_percent
rename BasicCount Lev1_count
rename BasicPercent Lev1_percent
append using "`temp1'"

save "${Original_DTA}/MD_OriginalData_2016", replace

//Renaming
rename AcademicYear SchYear
rename LEANumber StateAssignedDistID
rename LEAName DistName
rename SchoolNumber StateAssignedSchID
rename SchoolName SchName
drop TestType
gen GradeLevel = "G0"+ substr(Assessment, -1,1)
replace GradeLevel = "G0"+ substr(Grade, -1,1) if !missing(Subject)
drop if real(substr(GradeLevel, -1,1)) > 8 | real(substr(GradeLevel, -1,1)) < 3 | missing(real(substr(GradeLevel, -1,1)))
drop Grade
replace Subject = substr(Assessment, 1, strpos(Assessment, "Grade")-2) if missing(Subject)
drop Assessment
rename TestedCount StudentSubGroup_TotalTested
drop CreateDate
drop ParticipationCount
drop ParticipationPercent

//SchYear
tostring SchYear, replace
replace SchYear = string(real(SchYear)-1) + "-" + substr(SchYear,-2,2)

//Subject
replace Subject = "sci" if Subject == "Science"
replace Subject = "ela" if Subject == "English/Language Arts"
replace Subject = "math" if Subject == "Mathematics"

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if StateAssignedDistID == "A" & StateAssignedSchID == "A"
replace DataLevel = "District" if StateAssignedDistID != "A" & StateAssignedSchID == "A"
replace DataLevel = "School" if StateAssignedDistID != "A" & StateAssignedSchID != "A"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1 | DataLevel == 2
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3

//Cleaning Level Percents
foreach var of varlist Lev*_percent {
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
destring `var', gen(n`var') i("*%<=>-")
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
replace `var' = subinstr(`var', "=","",.)
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
drop n`var' range`var'
replace `var' = "*" if `var' == "."
}

//Cleaning Level Counts
foreach var of varlist Lev*_count {
	replace `var' = "*" if missing(`var')
}

//Cleaning Sci Levels
forvalues n = 4/5 {
	replace Lev`n'_count = "" if Subject == "sci"
	replace Lev`n'_percent = "" if Subject == "sci"
}

//ParticipationRate
gen ParticipationRate = string(real(StudentSubGroup_TotalTested)/StudentCount, "%9.3g") if !missing(real(StudentSubGroup_TotalTested)) & !missing(StudentCount)
replace ParticipationRate = "--" if missing(ParticipationRate)
drop StudentCount

//NCES Merging
gen State_leaid = StateAssignedDistID
gen seasch = StateAssignedDistID + StateAssignedSchID
merge m:1 State_leaid using "${NCES_MD}/NCES_2015_District_MD", keep(match master) nogen
merge m:1 seasch using "${NCES_MD}/NCES_2015_School_MD", keep(match master) nogen
replace CountyName = proper(CountyName)

//Unmerged with no data
drop if SchName == "Incarcerated Youth Center (JACS)" & missing(NCESSchoolID)

//State level data
replace State = "Maryland"
replace StateFips = 24
replace StateAbbrev = "MD"

//ProficientOrAbove_count and ProficientOrAbove_percent
gen ProficientOrAbove_percent = string(real(Lev4_percent)+real(Lev5_percent)) if !missing(real(Lev4_percent)) & !missing(real(Lev5_percent)) & Subject != "sci"
replace ProficientOrAbove_percent = string(real(Lev2_percent)+real(Lev3_percent)) if !missing(real(Lev2_percent)) & !missing(real(Lev3_percent)) & Subject == "sci"
gen ProficientOrAbove_count = string(real(Lev4_count)+real(Lev5_count)) if !missing(real(Lev4_count)) & !missing(real(Lev5_count)) & Subject != "sci"
replace ProficientOrAbove_count = string(real(Lev2_count)+real(Lev3_count)) if !missing(real(Lev2_count)) & !missing(real(Lev3_count)) & Subject == "sci"

** Dealing with Ranges
foreach var of varlist Lev*_percent {
	gen low`var' = substr(`var', 1, strpos(`var', "-")-1)
	gen high`var' = substr(`var',strpos(`var', "-")+1,5)
	replace low`var' = high`var' if missing(low`var') & !missing(high`var')
	replace high`var' = low`var' if missing(high`var') & !missing(low`var')
}

*******************************************************
// Creating a Breakpoint - to restore for non-derivation data processing
*******************************************************
save "$Temp/MD_2016_Breakpoint",replace

*********************************************************
//Derivations
*********************************************************
//Deriving Counts with Ranges
foreach count of varlist *_count {
local percent = subinstr("`count'", "count","percent",.)	
replace `count' = string(round(real(substr(`percent', 1, strpos(`percent', "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(`percent',strpos(`percent', "-")+1,5))*real(StudentSubGroup_TotalTested))) if missing(real(`count')) & strpos(`percent', "-") !=0 & regexm(`percent', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0
}

replace ProficientOrAbove_percent = string(real(lowLev4_percent) + real(lowLev5_percent)) + "-" + string(real(highLev4_percent) + real(highLev5_percent)) if strpos(Lev4_percent, "-") !=0 & regexm(Lev4_percent, "[0-9]") !=0 & Subject != "sci" | (strpos(Lev5_percent, "-") !=0 & regexm(Lev5_percent, "[0-9]") !=0) & Subject != "sci"
replace ProficientOrAbove_percent = string(real(lowLev2_percent) + real(lowLev3_percent)) + "-" + string(real(highLev2_percent) + real(highLev3_percent)) if strpos(Lev2_percent, "-") !=0 & regexm(Lev2_percent, "[0-9]") !=0 & Subject == "sci" | (strpos(Lev3_percent, "-") !=0 & regexm(Lev3_percent, "[0-9]") !=0) & Subject == "sci"
drop low* high*

** Dealing with Ranges
foreach var of varlist Lev*_count {
	gen low`var' = substr(`var', 1, strpos(`var', "-")-1)
	gen high`var' = substr(`var',strpos(`var', "-")+1,5)
	replace low`var' = high`var' if missing(low`var') & !missing(high`var')
	replace high`var' = low`var' if missing(high`var') & !missing(low`var')
}

replace ProficientOrAbove_count = string(real(lowLev4_count) + real(lowLev5_count)) + "-" + string(real(highLev4_count) + real(highLev5_count)) if strpos(Lev4_count, "-") !=0 & regexm(Lev4_count, "[0-9]") !=0 & Subject != "sci" | (strpos(Lev5_count, "-") !=0 & regexm(Lev5_count, "[0-9]") !=0) & Subject != "sci"
replace ProficientOrAbove_count = string(real(lowLev2_count) + real(lowLev3_count)) + "-" + string(real(highLev2_count) + real(highLev3_count)) if strpos(Lev2_count, "-") !=0 & regexm(Lev2_count, "[0-9]") !=0 & Subject == "sci" | (strpos(Lev3_count, "-") !=0 & regexm(Lev3_count, "[0-9]") !=0) & Subject == "sci"
drop low* high*

//Indicator and Missing Variables
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

gen AssmtName = "PARCC" if Subject != "sci"
replace AssmtName = "MSA" if Subject == "sci"

gen AssmtType = "Regular"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

gen AvgScaleScore = "--"

gen ProficiencyCriteria = "Levels 4-5" if Subject != "sci"
replace ProficiencyCriteria = "Levels 2-3" if Subject == "sci"

//Fixing CountyNames
replace CountyName = subinstr(CountyName, "'S", "'s",.)

//Post Launch Review
replace SchName=stritrim(SchName)

replace DistName = "SEED School Of Maryland" if NCESDistrictID == "2400027"

replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "" 

*********************************************************
//Derivations [0 real changes!]
*********************************************************
//Derive Exact count/percent where we have range and corresponding exact count/percent and StudentSubGroup_TotalTested
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	replace `count' = string(round(real(`percent')* real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}

replace ProficientOrAbove_percent = "--" if ProficientOrAbove_count == "*" & ProficientOrAbove_percent == ""

*********************************************************
// Calculations
*********************************************************
** Deriving Additional Information
replace ProficientOrAbove_percent = string(real(Lev2_percent) + real(Lev3_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & Lev2_percent != "*" & Lev3_percent != "*" & ProficiencyCriteria == "Levels 2-3"
replace ProficientOrAbove_count = string(real(Lev2_count) + real(Lev3_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & Lev2_count != "*" & Lev3_count != "*" & ProficiencyCriteria == "Levels 2-3"
replace ProficientOrAbove_percent = string(real(Lev4_percent) + real(Lev5_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev5_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & Lev4_percent != "*" & Lev5_percent == "*" & ProficiencyCriteria == "Levels 4-5"
replace ProficientOrAbove_count = string(real(Lev4_count) + real(Lev5_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(Lev5_count, "-") == 0 & Lev4_count != "*" & Lev5_count == "*" & ProficiencyCriteria == "Levels 4-5"

replace ProficientOrAbove_percent = string(1 - real(Lev1_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev1_percent, "-") == 0 & Lev1_percent != "*" & 1 - real(Lev1_percent) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev1_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev1_count != "*" & real(StudentSubGroup_TotalTested) - real(Lev1_count) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent) - real(Lev3_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev1_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") ==0 & Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & ProficiencyCriteria == "Levels 4-5"
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count) - real(Lev3_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev1_count != "*" & Lev2_count != "*" & Lev3_count != "*" & ProficiencyCriteria == "Levels 4-5"
replace ProficientOrAbove_percent = "0" if strpos(ProficientOrAbove_percent, "e") > 0
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_count == "0"
replace ProficientOrAbove_count = "0" if ProficientOrAbove_percent == "0"

replace Lev5_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent)) if strpos(Lev5_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev5_percent = "0" if strpos(Lev5_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev5_percent = "0" if strpos(Lev5_percent, "e") > 0
replace Lev5_percent = "0" if Lev5_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev5_count = string(real(ProficientOrAbove_count) - real(Lev4_count)) if strpos(Lev5_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev5_count = "0" if strpos(Lev5_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev5_percent = "0" if Lev5_count == "0"
replace Lev5_count = "0" if Lev5_percent == "0"
replace Lev5_count = "0" if Lev5_count == "--" & ProficientOrAbove_count == "0"

replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev5_percent)) if strpos(Lev4_percent, "-") > 0 & strpos(Lev5_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev5_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev5_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev4_percent = "0" if strpos(Lev4_percent, "-") > 0 & strpos(Lev5_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev5_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev5_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev4_percent = "0" if strpos(Lev4_percent, "e") > 0
replace Lev4_percent = "0" if Lev4_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev5_count)) if strpos(Lev4_count, "-") > 0 & strpos(Lev5_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev5_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev5_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev4_count = "0" if strpos(Lev4_count, "-") > 0 & strpos(Lev5_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev5_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev5_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev4_percent = "0" if Lev4_count == "0"
replace Lev4_count = "0" if Lev4_percent == "0"
replace Lev4_count = "0" if Lev4_count == "--" & ProficientOrAbove_count == "0"

replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev2_percent)) if (strpos(Lev3_percent, "-") > 0 | Lev3_percent == "*") & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev2_percent) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev3_percent = "0" if (strpos(Lev3_percent, "-") > 0 | Lev3_percent == "*") & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev2_percent) < 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev3_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent) - real(Lev2_percent)) if strpos(Lev3_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) - real(Lev1_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev3_percent = "0" if strpos(Lev3_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) - real(Lev1_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev3_percent = "0" if strpos(Lev3_percent, "e") > 0
replace Lev3_percent = "0" if Lev3_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev2_count)) if (strpos(Lev3_count, "-") > 0 | Lev3_count == "*") & strpos(Lev2_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev2_count) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev3_count = "0" if (strpos(Lev3_count, "-") > 0 | Lev3_count == "*") & strpos(Lev2_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev2_count) < 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev3_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) - real(Lev1_count)) if strpos(Lev3_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev2_count != "*" & Lev1_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev2_count) - real(Lev1_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev3_count = "0" if strpos(Lev3_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev2_count != "*" & Lev1_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev2_count) - real(Lev1_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev3_percent = "0" if Lev3_count == "0"
replace Lev3_count = "0" if Lev3_percent == "0"
replace Lev3_count = "0" if Lev3_count == "--" & ProficientOrAbove_percent == "0"

replace Lev2_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent)) if (strpos(Lev2_percent, "-") > 0 | Lev2_percent == "*") & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev3_percent) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev2_percent = "0" if (strpos(Lev2_percent, "-") > 0 | Lev2_percent == "*") & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev3_percent) < 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent) - real(Lev3_percent)) if strpos(Lev2_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) - real(Lev3_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev2_percent = "0" if strpos(Lev2_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev1_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev2_percent = "0" if strpos(Lev2_percent, "e") > 0

replace Lev2_count = string(real(ProficientOrAbove_count) - real(Lev3_count)) if (strpos(Lev2_count, "-") > 0 | Lev2_count == "*") & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev2_count = "0" if (strpos(Lev2_count, "-") > 0 | Lev2_count == "*") & strpos(Lev3_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) < 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev1_count)) if strpos(Lev2_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev3_count != "*" & Lev1_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev1_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev2_count = "0" if strpos(Lev2_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev3_count != "*" & Lev1_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev1_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev2_percent = "0" if Lev2_count == "0"
replace Lev2_count = "0" if Lev2_percent == "0"

replace Lev1_percent = string(1 - real(ProficientOrAbove_percent)) if (strpos(Lev1_percent, "-") > 0 | Lev1_percent == "*") & strpos(ProficientOrAbove_percent, "-") == 0 & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev1_percent = "0" if (strpos(Lev1_percent, "-") > 0 | Lev1_percent == "*") & strpos(ProficientOrAbove_percent, "-") == 0 & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) < 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev1_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev2_percent) - real(Lev3_percent)) if strpos(Lev1_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) - real(Lev3_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev1_percent = "0" if strpos(Lev1_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev2_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev1_percent = "0" if strpos(Lev1_percent, "e") > 0

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count)) if (strpos(Lev1_count, "-") > 0 | Lev1_count == "*") & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev1_count = "0" if (strpos(Lev1_count, "-") > 0 | Lev1_count == "*") & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) < 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count)) if strpos(Lev1_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev3_count != "*" & Lev2_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev1_count = "0" if strpos(Lev1_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev3_count != "*" & Lev2_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev1_percent = "0" if Lev1_count == "0"
replace Lev1_count = "0" if Lev1_percent == "0"

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

*Exporting Temp Output.
save "$Temp/MD_AssmtData_2016.dta" , replace

*********************************************************
// Creating the non-derivation output
*********************************************************
*******************************************************
// Restoring breakpoint for non-derivation data processing
*******************************************************
use "$Temp/MD_2016_Breakpoint",clear

replace ProficientOrAbove_percent = string(real(lowLev4_percent) + real(lowLev5_percent)) + "-" + string(real(highLev4_percent) + real(highLev5_percent)) if strpos(Lev4_percent, "-") !=0 & regexm(Lev4_percent, "[0-9]") !=0 & Subject != "sci" | (strpos(Lev5_percent, "-") !=0 & regexm(Lev5_percent, "[0-9]") !=0) & Subject != "sci"
replace ProficientOrAbove_percent = string(real(lowLev2_percent) + real(lowLev3_percent)) + "-" + string(real(highLev2_percent) + real(highLev3_percent)) if strpos(Lev2_percent, "-") !=0 & regexm(Lev2_percent, "[0-9]") !=0 & Subject == "sci" | (strpos(Lev3_percent, "-") !=0 & regexm(Lev3_percent, "[0-9]") !=0) & Subject == "sci"
drop low* high*

** Dealing with Ranges
foreach var of varlist Lev*_count {
	gen low`var' = substr(`var', 1, strpos(`var', "-")-1)
	gen high`var' = substr(`var',strpos(`var', "-")+1,5)
	replace low`var' = high`var' if missing(low`var') & !missing(high`var')
	replace high`var' = low`var' if missing(high`var') & !missing(low`var')
}

replace ProficientOrAbove_count = string(real(lowLev4_count) + real(lowLev5_count)) + "-" + string(real(highLev4_count) + real(highLev5_count)) if strpos(Lev4_count, "-") !=0 & regexm(Lev4_count, "[0-9]") !=0 & Subject != "sci" | (strpos(Lev5_count, "-") !=0 & regexm(Lev5_count, "[0-9]") !=0) & Subject != "sci"
replace ProficientOrAbove_count = string(real(lowLev2_count) + real(lowLev3_count)) + "-" + string(real(highLev2_count) + real(highLev3_count)) if strpos(Lev2_count, "-") !=0 & regexm(Lev2_count, "[0-9]") !=0 & Subject == "sci" | (strpos(Lev3_count, "-") !=0 & regexm(Lev3_count, "[0-9]") !=0) & Subject == "sci"
drop low* high*

//Indicator and Missing Variables
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

gen AssmtName = "PARCC" if Subject != "sci"
replace AssmtName = "MSA" if Subject == "sci"

gen AssmtType = "Regular"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

gen AvgScaleScore = "--"

gen ProficiencyCriteria = "Levels 4-5" if Subject != "sci"
replace ProficiencyCriteria = "Levels 2-3" if Subject == "sci"

//Fixing CountyNames
replace CountyName = subinstr(CountyName, "'S", "'s",.)

//Post Launch Review
replace SchName=stritrim(SchName)

replace DistName = "SEED School Of Maryland" if NCESDistrictID == "2400027"

replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "" 

replace ProficientOrAbove_percent = "--" if ProficientOrAbove_count == "*" & ProficientOrAbove_percent == ""

*********************************************************
// Calculations
*********************************************************
** Deriving Additional Information
replace ProficientOrAbove_percent = string(real(Lev2_percent) + real(Lev3_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & Lev2_percent != "*" & Lev3_percent != "*" & ProficiencyCriteria == "Levels 2-3"
replace ProficientOrAbove_count = string(real(Lev2_count) + real(Lev3_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & Lev2_count != "*" & Lev3_count != "*" & ProficiencyCriteria == "Levels 2-3"
replace ProficientOrAbove_percent = string(real(Lev4_percent) + real(Lev5_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev5_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & Lev4_percent != "*" & Lev5_percent == "*" & ProficiencyCriteria == "Levels 4-5"
replace ProficientOrAbove_count = string(real(Lev4_count) + real(Lev5_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(Lev5_count, "-") == 0 & Lev4_count != "*" & Lev5_count == "*" & ProficiencyCriteria == "Levels 4-5"

replace ProficientOrAbove_percent = string(1 - real(Lev1_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev1_percent, "-") == 0 & Lev1_percent != "*" & 1 - real(Lev1_percent) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev1_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev1_count != "*" & real(StudentSubGroup_TotalTested) - real(Lev1_count) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent) - real(Lev3_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev1_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") ==0 & Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & ProficiencyCriteria == "Levels 4-5"
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count) - real(Lev3_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev1_count != "*" & Lev2_count != "*" & Lev3_count != "*" & ProficiencyCriteria == "Levels 4-5"
replace ProficientOrAbove_percent = "0" if strpos(ProficientOrAbove_percent, "e") > 0
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_count == "0"
replace ProficientOrAbove_count = "0" if ProficientOrAbove_percent == "0"

replace Lev5_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent)) if strpos(Lev5_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev5_percent = "0" if strpos(Lev5_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev5_percent = "0" if strpos(Lev5_percent, "e") > 0
replace Lev5_percent = "0" if Lev5_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev5_count = string(real(ProficientOrAbove_count) - real(Lev4_count)) if strpos(Lev5_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev5_count = "0" if strpos(Lev5_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev5_percent = "0" if Lev5_count == "0"
replace Lev5_count = "0" if Lev5_percent == "0"
replace Lev5_count = "0" if Lev5_count == "--" & ProficientOrAbove_count == "0"

replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev5_percent)) if strpos(Lev4_percent, "-") > 0 & strpos(Lev5_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev5_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev5_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev4_percent = "0" if strpos(Lev4_percent, "-") > 0 & strpos(Lev5_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev5_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev5_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev4_percent = "0" if strpos(Lev4_percent, "e") > 0
replace Lev4_percent = "0" if Lev4_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev5_count)) if strpos(Lev4_count, "-") > 0 & strpos(Lev5_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev5_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev5_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev4_count = "0" if strpos(Lev4_count, "-") > 0 & strpos(Lev5_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev5_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev5_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev4_percent = "0" if Lev4_count == "0"
replace Lev4_count = "0" if Lev4_percent == "0"
replace Lev4_count = "0" if Lev4_count == "--" & ProficientOrAbove_count == "0"

replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev2_percent)) if (strpos(Lev3_percent, "-") > 0 | Lev3_percent == "*") & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev2_percent) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev3_percent = "0" if (strpos(Lev3_percent, "-") > 0 | Lev3_percent == "*") & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev2_percent) < 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev3_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent) - real(Lev2_percent)) if strpos(Lev3_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) - real(Lev1_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev3_percent = "0" if strpos(Lev3_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) - real(Lev1_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev3_percent = "0" if strpos(Lev3_percent, "e") > 0
replace Lev3_percent = "0" if Lev3_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev2_count)) if (strpos(Lev3_count, "-") > 0 | Lev3_count == "*") & strpos(Lev2_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev2_count) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev3_count = "0" if (strpos(Lev3_count, "-") > 0 | Lev3_count == "*") & strpos(Lev2_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev2_count) < 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev3_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) - real(Lev1_count)) if strpos(Lev3_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev2_count != "*" & Lev1_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev2_count) - real(Lev1_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev3_count = "0" if strpos(Lev3_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev2_count != "*" & Lev1_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev2_count) - real(Lev1_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev3_percent = "0" if Lev3_count == "0"
replace Lev3_count = "0" if Lev3_percent == "0"
replace Lev3_count = "0" if Lev3_count == "--" & ProficientOrAbove_percent == "0"

replace Lev2_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent)) if (strpos(Lev2_percent, "-") > 0 | Lev2_percent == "*") & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev3_percent) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev2_percent = "0" if (strpos(Lev2_percent, "-") > 0 | Lev2_percent == "*") & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev3_percent) < 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent) - real(Lev3_percent)) if strpos(Lev2_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) - real(Lev3_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev2_percent = "0" if strpos(Lev2_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev1_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev2_percent = "0" if strpos(Lev2_percent, "e") > 0

replace Lev2_count = string(real(ProficientOrAbove_count) - real(Lev3_count)) if (strpos(Lev2_count, "-") > 0 | Lev2_count == "*") & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev2_count = "0" if (strpos(Lev2_count, "-") > 0 | Lev2_count == "*") & strpos(Lev3_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) < 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev1_count)) if strpos(Lev2_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev3_count != "*" & Lev1_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev1_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev2_count = "0" if strpos(Lev2_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev3_count != "*" & Lev1_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev1_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev2_percent = "0" if Lev2_count == "0"
replace Lev2_count = "0" if Lev2_percent == "0"

replace Lev1_percent = string(1 - real(ProficientOrAbove_percent)) if (strpos(Lev1_percent, "-") > 0 | Lev1_percent == "*") & strpos(ProficientOrAbove_percent, "-") == 0 & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev1_percent = "0" if (strpos(Lev1_percent, "-") > 0 | Lev1_percent == "*") & strpos(ProficientOrAbove_percent, "-") == 0 & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) < 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev1_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev2_percent) - real(Lev3_percent)) if strpos(Lev1_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) - real(Lev3_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev1_percent = "0" if strpos(Lev1_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev2_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev1_percent = "0" if strpos(Lev1_percent, "e") > 0

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count)) if (strpos(Lev1_count, "-") > 0 | Lev1_count == "*") & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) >= 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev1_count = "0" if (strpos(Lev1_count, "-") > 0 | Lev1_count == "*") & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) < 0 & ProficiencyCriteria == "Levels 2-3"
replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count)) if strpos(Lev1_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev3_count != "*" & Lev2_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev1_count = "0" if strpos(Lev1_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev3_count != "*" & Lev2_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev1_percent = "0" if Lev1_count == "0"
replace Lev1_count = "0" if Lev1_percent == "0"

//Final Cleaning and dropping extra variables
keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Non-Derivation Output.
save "$Output_ND/MD_AssmtData_2016_ND.dta" , replace
export delimited "$Output_ND/MD_AssmtData_2016_ND", replace	
* END of MD_2016.do
****************************************************
