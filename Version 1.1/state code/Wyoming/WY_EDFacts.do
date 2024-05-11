clear
cd "/Users/meghancornacchia/Desktop/DataRepository/Wyoming"
local Original "/Users/meghancornacchia/Desktop/DataRepository/Wyoming/Original_Data_Files"
local Output "/Users/meghancornacchia/Desktop/DataRepository/Wyoming/Output"
local NCES "/Users/meghancornacchia/Desktop/DataRepository/Wyoming/New_NCES"
local EDFacts "/Users/meghancornacchia/Desktop/DataRepository/Wyoming/EDFacts"
local Temp "/Users/meghancornacchia/Desktop/DataRepository/Wyoming/Temporary Data Files"

forvalues year = 2014/2021 {
	if `year' == 2020 continue
foreach subject in ela math {
foreach dl in district school {
clear
use "`EDFacts'/edfactscount`year'`subject'`dl'.dta"
keep if STNAM == "WYOMING"

//Drop no student subgroups
replace NUMVALID = "0" if NUMVALID == "."
drop if NUMVALID == "0"

//Renaming
rename LEAID NCESDistrictID
cap rename NCESSCH NCESSchoolID
rename SUBJECT Subject
rename GRADE GradeLevel
rename CATEGORY StudentSubGroup
cap rename NUM* StudentSubGroup_TotalTested

//Subject
replace Subject = "ela" if Subject == "RLA"
replace Subject = "math" if Subject == "MTH"

//GradeLevel
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

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
replace StudentSubGroup = "Migrant" if StudentSubGroup == "MIG"
replace StudentSubGroup = "Military" if StudentSubGroup == "MIL"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "Female" if StudentSubGroup == "F"
replace StudentSubGroup = "Male" if StudentSubGroup == "M"

//Calculating StudentSubGroup_TotalTested where possible (for ECD and LEP)
destring StudentSubGroup_TotalTested, replace
tempfile temp1
save "`temp1'", replace
keep if StudentSubGroup == "All Students" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "English Learner" | StudentSubGroup == "SWD" | StudentSubGroup == "Foster Care" | StudentSubGroup == "Homeless" | StudentSubGroup == "Military" | StudentSubGroup == "Migrant"
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
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup[_n-1] == "Migrant"

tempfile tempcalc
save "`tempcalc'", replace
clear
use "`temp1'"
drop if StudentSubGroup == "All Students" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "English Learner" | StudentSubGroup == "SWD" | StudentSubGroup == "Foster Care" | StudentSubGroup == "Homeless" | StudentSubGroup == "Military" | StudentSubGroup == "Migrant"
append using "`tempcalc'"
if "`dl'" == "school" sort NCESDistrictID NCESSchoolID GradeLevel StudentSubGroup
if "`dl'" == "district" sort NCESDistrictID GradeLevel StudentSubGroup

//Aggregating To State Level
if "`dl'" == "district" egen StateStudentSubGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StudentSubGroup GradeLevel) 

// Renaming variables to ease merging
rename StudentSubGroup_TotalTested EDStudentSubGroup_TotalTested
drop AllStudents

//Saving
save "`Temp'/`year'_`subject'_count_`dl'", replace
clear
}
}
//Combining
tempfile temp_`year'_count
save "`temp_`year'_count'", replace emptyok
foreach dl in district school {
	foreach subject in ela math {
	use "`Temp'/`year'_`subject'_count_`dl'"
	append using "`temp_`year'_count'"
	save "`temp_`year'_count'", replace
	save "`Temp'/_`year'_count", replace
	clear
	}
}

 **MERGING**
use "`Output'/WY_AssmtData_`year'"
merge 1:1 NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup using "`Temp'/_`year'_count", update
drop if _merge == 2
drop _merge

//Using State Level Data
tempfile temp1
save "`temp1'", replace
keep if DataLevel == 1
tempfile tempstate
save "`tempstate'", replace
clear
use "`Temp'/_`year'_count"
drop if missing(StateStudentSubGroup_TotalTested)
duplicates drop StudentSubGroup GradeLevel Subject, force
merge 1:1 StudentSubGroup GradeLevel Subject using "`tempstate'"
drop if _merge == 1
replace EDStudentSubGroup_TotalTested = StateStudentSubGroup_TotalTested
save "`tempstate'", replace
use "`temp1'"
keep if DataLevel !=1
append using "`tempstate'"
sort DataLevel
replace NCESSchoolID = "" if DataLevel == 1
replace NCESDistrictID = "" if DataLevel == 1

//Cleaning StudentSubGroup_TotalTested and Generating StudentGroup_TotalTested
egen EDStudentGroup_TotalTested = total(EDStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)
tostring EDStudentGroup_TotalTested EDStudentSubGroup_TotalTested, replace

// Apply All Student tested counts if still have ranges
gen AllStudents = EDStudentGroup_TotalTested if StudentSubGroup == "All Students"
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
replace EDStudentGroup_TotalTested = AllStudents if EDStudentGroup_TotalTested == "0" & StudentGroup != "All Students"

// Generating Level counts
destring EDStudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*)
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


// Replace with EDFacts when possible
replace StudentGroup_TotalTested = EDStudentGroup_TotalTested if EDStudentGroup_TotalTested != "." & EDStudentGroup_TotalTested != "0"
replace StudentSubGroup_TotalTested = EDStudentSubGroup_TotalTested if EDStudentSubGroup_TotalTested != "."

drop nLev*_percent

// Ranges for level counts if EDFacts is not available
gen low_end_subgroup = real(substr(StudentSubGroup_TotalTested, 1, strpos(StudentSubGroup_TotalTested, "-") - 1))
destring StudentGroup_TotalTested, gen(xStudentGroup_TotalTested) force
gen high_end_subgroup = real(substr(StudentSubGroup_TotalTested, strpos(StudentSubGroup_TotalTested, "-") + 1, 4))
replace high_end_subgroup = xStudentGroup_TotalTested if (xStudentGroup_TotalTested < high_end_subgroup)
replace StudentSubGroup_TotalTested = string(low_end_subgroup)+"-"+string(high_end_subgroup) if strpos(StudentSubGroup_TotalTested, "-")>0
replace StudentSubGroup_TotalTested = string(high_end_subgroup) if high_end_subgroup == low_end_subgroup
forvalues n = 1/4 {
	destring Lev`n'_percent, gen(nLev`n'_percent) force
	gen lowLev`n'_count = round(nLev`n'_percent*low_end_subgroup)
	gen highLev`n'_count = round(nLev`n'_percent*high_end_subgroup)
	gen rangeLev`n'_count = string(lowLev`n'_count)+"-"+string(highLev`n'_count)
	replace rangeLev`n'_count = string(lowLev`n'_count) if lowLev`n'_count == highLev`n'_count
	replace Lev`n'_count = rangeLev`n'_count if Lev`n'_count == "--"
}

gen lowProfCount = string(round(lowLev3_count + lowLev4_count))
gen highProfCount = string(round(highLev3_count + highLev4_count))
replace ProficientOrAbove_count = lowProfCount+"-"+highProfCount if ProficientOrAbove_count == "--"

// Setting part rate to 0 if tested count = 0
foreach var of varlist Lev* ParticipationRate ProficientOrAbove* {
	replace `var' = "0" if StudentSubGroup_TotalTested == "0"
	replace Lev5_count = "" if StudentSubGroup_TotalTested == "0"
	replace Lev5_percent = "" if StudentSubGroup_TotalTested == "0"
}

//Final Cleaning
recast str80 SchName
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "`Output'/WY_AssmtData_`year'", replace
export delimited "`Output'/WY_AssmtData_`year'", replace

}
