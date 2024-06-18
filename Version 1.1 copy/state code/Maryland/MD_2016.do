clear
set more off
global Original "/Volumes/T7/State Test Project/Maryland/Original"
global Output "/Volumes/T7/State Test Project/Maryland/Output"
global NCES_MD "/Volumes/T7/State Test Project/Maryland/NCES"

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
merge m:1 State_leaid using "${NCES_MD}/NCES_2015_District", keep(match master) nogen
merge m:1 seasch using "${NCES_MD}/NCES_2015_School", keep(match master) nogen
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
replace ProficientOrAbove_percent = string(real(lowLev4_percent) + real(lowLev5_percent)) + "-" + string(real(highLev4_percent) + real(highLev5_percent)) if strpos(Lev4_percent, "-") !=0 & regexm(Lev4_percent, "[0-9]") !=0 | (strpos(Lev5_percent, "-") !=0 & regexm(Lev5_percent, "[0-9]") !=0) & Subject != "sci"
replace ProficientOrAbove_percent = string(real(lowLev2_percent) + real(lowLev3_percent)) + "-" + string(real(highLev2_percent) + real(highLev3_percent)) if strpos(Lev2_percent, "-") !=0 & regexm(Lev2_percent, "[0-9]") !=0 | (strpos(Lev3_percent, "-") !=0 & regexm(Lev3_percent, "[0-9]") !=0) & Subject == "sci"
drop low* high*

//Deriving Counts with Ranges
foreach count of varlist *_count {
local percent = subinstr("`count'", "count","percent",.)	
replace `count' = string(round(real(substr(`percent', 1, strpos(`percent', "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(`percent',strpos(`percent', "-")+1,5))*real(StudentSubGroup_TotalTested))) if missing(real(`count')) & strpos(`percent', "-") !=0 & regexm(`percent', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0
}

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

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/MD_AssmtData_2016", replace
export delimited "${Output}/MD_AssmtData_2016", replace



