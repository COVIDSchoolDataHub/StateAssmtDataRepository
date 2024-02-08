clear
set more off
local Original "/Volumes/T7/State Test Project/LA/Original"
local Cleaned "/Volumes/T7/State Test Project/LA/Cleaned"
local Output "/Volumes/T7/State Test Project/LA/Output"

//2016 DATA

/*
tempfile temp1
save "`temp1'", replace emptyok
import excel "`Original'/2016 LEAP_Suppressed.xlsx", sheet("2016 LEAP SUPPRESSED ELA_MATH") firstrow allstring
append using "`temp1'"
save "`temp1'", replace

/*
clear
import excel "`Original'/2016 LEAP_Suppressed.xlsx", sheet("2016 LEAP SUPPRESSED SCI") firstrow allstring
append using "`temp1'"
*/

save "`Original'/2016", replace
*/

use "`Original'/2016"
keep if SummaryLevel == "State"

//Renaming
foreach var of varlist _all {
local oldname  = "`var'"
if strpos("`var'", "ELA") != 0 {
local newname = subinstr("`var'", "ELA","",.) + "ela"
rename `oldname' `newname'
}
if strpos("`var'", "Math") !=0 {

local newname = subinstr("`var'", "Math","",2) + "math"
rename `oldname' `newname'
}
}

rename AverageScaleScoreAverageela AverageScaleScoreela
rename SummaryLevel DataLevel

//Reshaping
reshape long COUNTAdvanced PERCENTAdvanced COUNTMastery PERCENTMastery COUNTBasic PERCENTBasic COUNTApproachingBasic PERCENTApproachingBasic COUNTUnsatisfactory PERCENTUnsatisfactory TotalStudentTested AverageScaleScore, i(Grade Group SubGroup) j(Subject, string)

//StudentSubGroup
replace Group = SubGroup if Group == "Ethnicity" | Group == "Gender"
replace Group = Group + SubGroup if Group == "LEP" | Group == "Economically Disadvantaged"
keep if Group == SubGroup | SubGroup == "No" | strpos(Group, "LEP") !=0 | strpos(Group, "Economically") !=0 | Group == "Total Population"
drop SubGroup
rename Group StudentSubGroup
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically DisadvantagedYes"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Economically DisadvantagedNo"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEPYes"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "LEPNo"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Native H") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two") !=0
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "Total Pop") !=0
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "Unknown"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Unknown"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"

//GradeLevel
rename Grade GradeLevel
replace GradeLevel = "G0" + GradeLevel 

//Renaming after Reshaping
rename AverageScaleScore AvgScaleScore
rename COUNTAdvanced Lev5_count
rename PERCENTAdvanced Lev5_percent
rename COUNTMastery Lev4_count
rename PERCENTMastery Lev4_percent
rename COUNTBasic Lev3_count
rename PERCENTBasic Lev3_percent
rename COUNTApproachingBasic Lev2_count
rename PERCENTApproachingBasic Lev2_percent
rename COUNTUnsatisfactory Lev1_count
rename PERCENTUnsatisfactory Lev1_percent
rename TotalStudentTested StudentSubGroup_TotalTested

//Cleaning Percents and Counts

foreach var of varlist Lev*_percent {
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
destring `var', gen(n`var') i(*%<>-)
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
replace `var' = subinstr(`var', "=","",.)
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
}

foreach var of varlist Lev*_count {
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
destring `var', gen(n`var') i(*%<>-)
replace `var' = range`var' + string(n`var', "%9.3g") if `var' != "*" & `var' != "--"
replace `var' = subinstr(`var', "=","",.)
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
}

//Generating ProficientOrAbove_Count and Percent
foreach var of varlist Lev* {
	gen low`var' = substr(`var', 1, strpos(`var', "-")-1)
	destring low`var', replace i(*)
	gen high`var' = substr(`var', strpos(`var', "-")+1,10)
	destring high`var', replace i(*)
	replace low`var' = high`var' if strpos(`var', "-") == 0
}
gen lowProficientOrAbove_percent = round(lowLev4_percent + lowLev5_percent, 0.01)
gen highProficientOrAbove_percent = highLev4_percent + highLev5_percent
gen ProficientOrAbove_percent = string(lowProficientOrAbove_percent) + "-" + string(highProficientOrAbove_percent) if lowProficientOrAbove_percent != highProficientOrAbove_percent
replace ProficientOrAbove_percent = string(highProficientOrAbove_percent) if lowProficientOrAbove_percent == highProficientOrAbove_percent

gen lowProficientOrAbove_count = lowLev4_count + lowLev5_count
gen highProficientOrAbove_count = highLev4_count + highLev5_count
gen ProficientOrAbove_count = string(lowProficientOrAbove_count) + "-" + string(highProficientOrAbove_count) if lowProficientOrAbove_count != highProficientOrAbove_count
replace ProficientOrAbove_count = string(highProficientOrAbove_count) if lowProficientOrAbove_count == highProficientOrAbove_count

//Dropping Extra variables
keep GradeLevel StudentSubGroup Subject AvgScaleScore StudentSubGroup_TotalTested Lev5_count Lev5_percent Lev4_count Lev4_percent Lev3_count Lev3_percent Lev2_count Lev2_percent Lev1_count Lev1_percent StudentGroup DataLevel ProficientOrAbove_percent ProficientOrAbove_count

//StudentSubGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested)
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject)
tostring StudentGroup_TotalTested, replace

//Indicator Variables
gen State = "Louisiana"
gen StateAbbrev = "LA"
gen StateFips = 22
gen SchYear = "2015-16"
gen DistName = "All Districts"
gen SchName = "All Schools"
gen AssmtName = "LEAP"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 4 and 5"
gen ParticipationRate = "--"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read =.
gen Flag_CutScoreChange_oth = "N"

//Adding to Original Cleaned Data
append using "`Cleaned'/LA_AssmtData_2016"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Eliminating ranges where possible
destring ProficientOrAbove_count, gen(nProficientOrAbove_count) i(-*)
replace ProficientOrAbove_percent = string(nProficientOrAbove_count/nStudentSubGroup_TotalTested, "%9.3g") if strpos(ProficientOrAbove_count, "-") ==0

//AvgScaleScore
replace AvgScaleScore = "*" if missing(AvgScaleScore) | AvgScaleScore == " "

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/LA_AssmtData_2016", replace
export delimited "`Output'/LA_AssmtData_2016", replace

