clear
//set more off
set trace off
global Output "/Volumes/T7/State Test Project/Connecticut/Output"
global EDFacts "/Volumes/T7/State Test Project/EDFACTS"
global Temp "/Volumes/T7/State Test Project/Connecticut/Temp"

foreach subject in ela math {
foreach dl in district school {
clear
use "${EDFacts}/edfactspart2021`subject'`dl'.dta"
keep if STNAM == "CONNECTICUT"

//Renaming
rename LEAID NCESDistrictID
cap rename NCESSCH NCESSchoolID
rename SUBJECT Subject
rename GRADE GradeLevel
rename CATEGORY StudentSubGroup
drop PCTPART
cap rename NUM* StudentSubGroup_TotalTested

//Subject
replace Subject = "ela" if Subject == "RLA"
replace Subject = "math" if Subject == "MTH"

//GradeLevel
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08", "G00")
replace GradeLevel = "G38" if GradeLevel == "G00"

//StudentSubGroup
replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "MAM"
replace StudentSubGroup = "Asian" if StudentSubGroup == "MAS"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "MHI"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "MBL"
replace StudentSubGroup = "White" if StudentSubGroup == "MWH"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "MTR"
replace StudentSubGroup = "SWD" if StudentSubGroup == "CWD"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "FCS"
replace StudentSubGroup = "Homeless" if StudentSubGroup == "HOM"
drop if StudentSubGroup == "MIG"
replace StudentSubGroup = "Military" if StudentSubGroup == "MIL"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "Female" if StudentSubGroup == "F"
replace StudentSubGroup = "Male" if StudentSubGroup == "M"
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "SWD" | StudentSubGroup == "Foster Care" | StudentSubGroup == "Homeless" | StudentSubGroup == "Military"

//Calculating StudentSubGroup_TotalTested where possible (for ECD and LEP)
destring StudentSubGroup_TotalTested, replace
tempfile temp1
save "`temp1'", replace
keep if StudentSubGroup == "All Students" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "English Learner"
expand 2 if StudentSubGroup != "All Students"
gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
if "`dl'" == "school" sort NCESDistrictID NCESSchoolID GradeLevel StudentSubGroup
if "`dl'" == "district" sort NCESDistrictID GradeLevel StudentSubGroup
replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
if "`dl'" == "school" bysort NCESDistrictID NCESSchoolID GradeLevel StudentSubGroup: replace StudentSubGroup_TotalTested = AllStudents - StudentSubGroup_TotalTested if _n==2
if "`dl'" == "district" bysort NCESDistrictID GradeLevel StudentSubGroup: replace StudentSubGroup_TotalTested = AllStudents - StudentSubGroup_TotalTested if _n==2 
replace StudentSubGroup = "English Proficient" if StudentSubGroup[_n-1] == "English Learner"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup[_n-1] == "Economically Disadvantaged"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup[_n-1] == "SWD"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup[_n-1] == "Foster Care"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup[_n-1] == "Homeless"
replace StudentSubGroup = "Non-Military" if StudentSubGroup[_n-1] == "Military"

tempfile tempcalc
save "`tempcalc'", replace
clear
use "`temp1'"
drop if StudentSubGroup == "All Students" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "English Learner"
append using "`tempcalc'"
if "`dl'" == "school" sort NCESDistrictID NCESSchoolID GradeLevel StudentSubGroup
if "`dl'" == "district" sort NCESDistrictID GradeLevel StudentSubGroup

//Aggregating To State Level
if "`dl'" == "district" egen StateStudentSubGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StudentSubGroup GradeLevel) 

//Saving
save "${Temp}/2021_`subject'_count_`dl'", replace
clear
}
}
//Combining
tempfile temp_2021_count
save "`temp_2021_count'", replace emptyok
foreach dl in district school {
	foreach subject in ela math {
	use "${Temp}/2021_`subject'_count_`dl'"
	append using "`temp_2021_count'"
	save "`temp_2021_count'", replace
	save "${Temp}/_2021_count", replace
	clear	
	}
}

 **MERGING**
use "${Output}/CT_AssmtData_2021"
drop StudentSubGroup_TotalTested StudentGroup_TotalTested
merge 1:1 NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup using "${Temp}/_2021_count", update
drop if _merge == 2
drop _merge

//Using State Level Data
tempfile temp1
save "`temp1'", replace
keep if DataLevel == 1
tempfile tempstate
save "`tempstate'", replace
clear
use "${Temp}/_2021_count"
drop if missing(StateStudentSubGroup_TotalTested)
duplicates drop StudentSubGroup GradeLevel Subject, force
merge 1:1 StudentSubGroup GradeLevel Subject using "`tempstate'"
drop if _merge == 1
replace StudentSubGroup_TotalTested = StateStudentSubGroup_TotalTested
save "`tempstate'", replace
use "`temp1'"
keep if DataLevel !=1
append using "`tempstate'"
sort DataLevel
replace NCESSchoolID = "" if DataLevel == 1
replace NCESDistrictID = "" if DataLevel == 1

// Generating Student Group Counts
tempfile overallcount
save `overallcount'
keep if StudentGroup=="All Students"
keep DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested AllStudents_TotalTested
tostring AllStudents_TotalTested, replace
duplicates drop
merge 1:m DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel using `overallcount', nogenerate

//Cleaning StudentSubGroup_TotalTested and Generating StudentGroup_TotalTested
egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)
tostring StudentGroup_TotalTested StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"
replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if (StudentGroup == "Foster Care Status" | StudentGroup == "Homeless Enrolled Status") & StudentGroup_TotalTested == "*"
replace StudentGroup_TotalTested = AllStudents_TotalTested if (StudentGroup == "EL Status" | StudentGroup == "Economic Status") & StudentGroup_TotalTested == "*"

// Dropping if StudentSubGroup_TotalTested == 0 and StudentSubGroup != "All Students"
drop if (StudentSubGroup_TotalTested == "0" | (StudentSubGroup_TotalTested == "*" & Lev1_count == "--")) & StudentSubGroup != "All Students"

// Generating Level counts
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*)
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*-)
gen nProficientOrAbove_count = nProficientOrAbove_percent * nStudentSubGroup_TotalTested
replace nProficientOrAbove_count = round(nProficientOrAbove_count,1)
replace ProficientOrAbove_count = string(nProficientOrAbove_count,"%9.0g") if nProficientOrAbove_count != .
replace ProficientOrAbove_count = "*" if (ProficientOrAbove_percent == "*" | StudentSubGroup_TotalTested == "*") & nProficientOrAbove_count == .
foreach n in 1 2 3 4 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*-)
	gen nLev`n'_count = nLev`n'_percent*nStudentSubGroup_TotalTested
	replace nLev`n'_count = round(nLev`n'_count,1)
	replace Lev`n'_count = string(nLev`n'_count, "%9.0g") if nLev`n'_count != .
	replace Lev`n'_count = "*" if Lev`n'_percent == "*" | StudentSubGroup_TotalTested == "*"
}

//Final Cleaning
recast str80 SchName
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "${Output}/CT_AssmtData_2021", replace
export delimited "${Output}/CT_AssmtData_2021", replace

