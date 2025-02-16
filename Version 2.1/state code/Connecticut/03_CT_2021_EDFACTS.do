*******************************************************
* CONNECTICUT

* File name: 03_CT_2021_EDFACTS
* Last update: 2/11/2025

*******************************************************
* Notes

	* This do file cleans EDFacts 2021 data and merges with the cleaned CT 2021 data.
	* Since the CT 2021 data does not contain counts, the EDFacts counts are utilized to generate counts.
	
	* The input files for this code are:
	* a) 2021 EDFacts *.csv files found in the Google Drive --> _Data Cleaning Materials --> _EDFacts--> Datasets
	* b) Convert the *.csv files to *.dta using the commented out code.
	
/////////////////////////////////////////
*** Conversion from EdFacts .csv to .dta format ***
/////////////////////////////////////////

	
// clear
// set more off
// global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive.
// forvalues year = 2014/2018 {
//     foreach subject in ela math {
//         foreach type in part count {
//             foreach dl in district school {
//                 import delimited "${EDFacts}/`year'/edfacts`type'`year'`subject'`dl'.csv", clear
//                 save "${EDFacts}/`year'/edfacts`type'`year'`subject'`dl'.dta", replace
//             }
//         }
//     }
// }
	
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear

foreach subject in ela math {
foreach dl in district school {
clear

import delimited "${EDFacts}/2021/edfactspart2021`subject'`dl'.csv", clear
keep if stnam == "CONNECTICUT"

//Renaming
rename leaid NCESDistrictID
cap rename ncessch NCESSchoolID
rename subject Subject
rename grade GradeLevel
rename category StudentSubGroup
drop pctpart
cap rename num* StudentSubGroup_TotalTested

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
**New code - errors with type mismatch during merges*
use "${Temp}/_2021_count", clear
destring NCESDistrictID, replace
destring NCESSchoolID, replace
format NCESDistrictID %07.0f
format NCESSchoolID %012.0f
save "${Temp}/_2021_count", replace
	
 **MERGING**
use "${Output}/CT_AssmtData_2021"
destring NCESDistrictID, replace force
destring NCESSchoolID, replace force
format NCESDistrictID %07.0f
format NCESSchoolID %012.0f

drop StudentSubGroup_TotalTested StudentGroup_TotalTested
merge 1:1 NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup using "${Temp}/_2021_count", update
drop if _merge == 2
drop _merge
 
 **MERGING**
use "${Output}/CT_AssmtData_2021", clear
destring NCESDistrictID, replace force
destring NCESSchoolID, replace force
format NCESDistrictID %07.0f
format NCESSchoolID %012.0f

drop StudentSubGroup_TotalTested StudentGroup_TotalTested
duplicates tag NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup, gen(dup)
tab dup
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

tostring NCESDistrictID, replace force
tostring NCESSchoolID, replace format(%012.0f) force
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


//StudentGroup_TotalTested
replace StudentSubGroup_TotalTested = string(real(Lev1_count) + real(Lev2_count) + real(Lev3_count) + real(Lev4_count)) if StudentSubGroup_TotalTested == "*" & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & !missing(real(Lev3_count)) & !missing(real(Lev4_count))

gen StateAssignedDistID1 = StateAssignedDistID
replace StudentGroup_TotalTested = ""
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel != 3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

destring StudentSubGroup_TotalTested, gen(total_count) ignore("*" "--")

global a 1 2 3 4
	foreach a in $a {
		destring Lev`a'_count, gen(n`a'_count) ignore("*" "--")
		destring Lev`a'_percent, gen(n`a'_percent) ignore("*" "--")
	}
	
destring ProficientOrAbove_count, gen(nprof_count) ignore("*" "--")
destring ProficientOrAbove_percent, gen(nprof_percent) ignore("*" "--")

replace n4_count = total_count - n1_count - n2_count - n3_count if Lev1_count != "*" & Lev2_count != "*" & Lev3_count != "*" & Lev4_count == "*" & StudentSubGroup_TotalTested != "*"
replace n4_percent = 1 - n1_percent - n2_percent - n3_percent if Lev1_count != "*" & Lev2_count != "*" & Lev3_count != "*" & Lev4_count == "*" & StudentSubGroup_TotalTested != "*"
replace n4_percent = 0 if n4_percent <= 0
replace n4_percent = 0 if n4_percent == 0.001


replace n3_count = total_count - n1_count - n2_count - n4_count if Lev1_count != "*" & Lev2_count != "*" & Lev4_count != "*" & Lev3_count == "*" & StudentSubGroup_TotalTested != "*"
replace n3_percent = 1 - n1_percent - n2_percent - n4_percent if Lev1_count != "*" & Lev2_count != "*" & Lev4_count != "*" & Lev3_count == "*" & StudentSubGroup_TotalTested != "*"
replace n3_percent = 0 if n3_percent <= 0
replace n3_percent = 0 if n3_percent == 0.001

replace n2_count = total_count - n1_count - n3_count - n4_count if Lev1_count != "*" & Lev3_count != "*" & Lev4_count != "*" & Lev2_count == "*" & StudentSubGroup_TotalTested != "*"
replace n2_percent = 1 - n1_percent - n3_percent - n4_percent if Lev1_count != "*" & Lev3_count != "*" & Lev4_count != "*" & Lev2_count == "*" & StudentSubGroup_TotalTested != "*"
replace n2_percent = 0 if n2_percent <= 0
replace n2_percent = 0 if n2_percent == 0.001

replace n1_count = total_count - n2_count - n3_count - n4_count if Lev2_count != "*" & Lev3_count != "*" & Lev4_count != "*" & Lev1_count == "*" & StudentSubGroup_TotalTested != "*"
replace n1_percent = 1 - n2_percent - n3_percent - n4_percent if Lev2_count != "*" & Lev3_count != "*" & Lev4_count != "*" & Lev1_count == "*" & StudentSubGroup_TotalTested != "*"
replace n1_percent = 0 if n1_percent <= 0
replace n1_percent = 0 if n1_percent == 0.001


replace nprof_count = n3_count + n4_count if Lev1_count != "*" & Lev2_count != "*" & Lev3_count != "*" & Lev4_count == "*" & StudentSubGroup_TotalTested != "*"
replace nprof_count = n3_count + n4_count if Lev1_count != "*" & Lev2_count != "*" & Lev3_count == "*" & Lev4_count != "*" & StudentSubGroup_TotalTested != "*"
replace nprof_percent = n3_percent + n4_percent if Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & Lev4_percent == "*" & StudentSubGroup_TotalTested != "*"
replace nprof_percent = n3_percent + n4_percent if Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent == "*" & Lev4_percent != "*" & StudentSubGroup_TotalTested != "*"

replace Lev4_count = string(n4_count) if Lev1_count != "*" & Lev2_count != "*" & Lev3_count != "*" & Lev4_count == "*" & StudentSubGroup_TotalTested != "*"
replace Lev4_percent = string(n4_percent) if Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & Lev4_percent == "*" & StudentSubGroup_TotalTested != "*"


replace Lev3_count = string(n3_count) if Lev1_count != "*" & Lev2_count != "*" & Lev4_count != "*" & Lev3_count == "*" & StudentSubGroup_TotalTested != "*"
replace Lev3_percent = string(n3_percent) if Lev1_percent != "*" & Lev2_percent != "*" & Lev4_percent != "*" & Lev3_percent == "*" & StudentSubGroup_TotalTested != "*"

replace Lev2_count = string(n2_count) if Lev1_count != "*" & Lev4_count != "*" & Lev3_count != "*" & Lev2_count == "*" & StudentSubGroup_TotalTested != "*"
replace Lev2_percent = string(n2_percent) if Lev1_percent != "*" & Lev4_percent != "*" & Lev3_percent != "*" & Lev2_percent == "*" & StudentSubGroup_TotalTested != "*"

replace Lev1_count = string(n1_count) if Lev4_count != "*" & Lev2_count != "*" & Lev3_count != "*" & Lev1_count == "*" & StudentSubGroup_TotalTested != "*"
replace Lev1_percent = string(n1_percent) if Lev4_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & Lev1_percent == "*" & StudentSubGroup_TotalTested != "*"

replace ProficientOrAbove_count = string(nprof_count) if ProficientOrAbove_count == "*" & nprof_count != .
replace ProficientOrAbove_percent = string(nprof_percent) if ProficientOrAbove_percent == "*" & nprof_percent != .

// fixing flags 

replace Flag_CutScoreChange_ELA = "N" 
replace Flag_CutScoreChange_math = "N" 
replace Flag_CutScoreChange_sci = "N"

replace NCESSchoolID = "" if NCESSchoolID == "."

gen flag = 1 if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & ProficientOrAbove_count == "*" & ProficientOrAbove_percent == "*"

replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count)) if flag == 1
replace ProficientOrAbove_percent = string(round(real(ProficientOrAbove_count)/real(StudentSubGroup_TotalTested),0.0001)) if flag == 1
drop flag
 
// Reordering variables and sorting data
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

*save "${Output}/CT_AssmtData_2021", replace //If .dta format needed. 
export delimited "${Output}/CT_AssmtData_2021", replace

* END of 03_CT_2021_EDFACTS.do 

