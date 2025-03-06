*******************************************************
* MONTANA

* File name: 03_MT_District_Cleaning
* Last update: 03/05/2025

*******************************************************
* Notes

	* This do file cleans MT district level data and appends it to the state level data.
	* You must have the filelist package installed for this file to run properly.
	
*******************************************************

clear all
set more off

// RUN BELOW CODE AFTER FIRST RUN -- COMBINES FILES


//Get Dataset of all filenames
filelist, dir("${ELA_Math}")
drop if dirname == "."
keep if strpos(filename, "MT_District_") !=0
drop dirname
drop fsize

//Get criteria for importing
split(filename), parse("_")
drop filename filename1 filename2
rename filename3 NCESDistrictID
rename filename4 DistName
rename filename5 Subject
rename filename6 GradeLevel
drop if filename7 == "AllStudents 2.xlsx"
drop filename7
gen NCESDistrictID_DistName = NCESDistrictID + "_" + DistName
drop NCESDistrictID DistName

//Importing & Combining
levelsof NCESDistrictID_DistName, local(IDs)
levelsof Subject, local(Subjects)
levelsof GradeLevel, local(GradeLevels)

//Importing
clear
tempfile temp1
save "`temp1'", emptyok replace
foreach ID of local IDs {
	foreach Subject of local Subjects {
		foreach GradeLevel of local GradeLevels {
			cap noisily import excel "${ELA_Math}/MT_District_`ID'_`Subject'_`GradeLevel'_AllStudents.xlsx", cellrange(A3) firstrow case(preserve) allstring clear
			if _rc !=0 continue
			gen ID = "`ID'"
			gen GradeLevel = "`GradeLevel'"
			gen Subject = "`Subject'"
			cap rename NearingProficiencyStudents NearingProficientStudents
			append using "`temp1'"
			save "`temp1'", replace
			}
		}
	}
use "`temp1'"
save "${Original}/AllDistricts_ELA_Math", replace

//Get Dataset of all filenames
filelist, dir("${Sci}")
drop if dirname == "."
keep if strpos(filename, "MT_District_") !=0
drop dirname
drop fsize

//Get criteria for importing
split(filename), parse("_")
drop filename filename1 filename2
rename filename3 NCESDistrictID
rename filename4 DistName
rename filename5 Subject
rename filename6 GradeLevel
drop if filename7 == "AllStudents 2.xlsx"
drop filename7
gen NCESDistrictID_DistName = NCESDistrictID + "_" + DistName
drop NCESDistrictID DistName

//Importing & Combining
levelsof NCESDistrictID_DistName, local(IDs)
levelsof Subject, local(Subjects)
levelsof GradeLevel, local(GradeLevels)

//Importing
clear
tempfile temp2
save "`temp2'", emptyok replace
foreach ID of local IDs {
	foreach Subject of local Subjects {
		foreach GradeLevel of local GradeLevels {
			cap noisily import excel "${Sci}/MT_District_`ID'_`Subject'_`GradeLevel'_AllStudents.xlsx", cellrange(A3) firstrow case(preserve) allstring clear
			if _rc !=0 continue
			gen ID = "`ID'"
			gen GradeLevel = "`GradeLevel'"
			gen Subject = "`Subject'"
			append using "`temp2'"
			save "`temp2'", replace
			}
		}
	}
use "`temp2'"
save "${Original}/AllDistricts_Sci", replace


// CLEANING FILE -- DO NOT HIDE
use "${Original}/AllDistricts_ELA_Math", clear
append using "${Original}/AllDistricts_Sci"
drop if SchoolYear == "2019-2020"

//Renaming
rename SchoolYear SchYear
rename NovicePercent Lev1_percent
rename NearingProficientPercent Lev2_percent
rename ProficientPercent Lev3_percent
rename AdvancedPercent Lev4_percent
rename AdvancedStudents Lev4_count
rename ProficientStudents Lev3_count
rename NearingProficientStudents Lev2_count
rename NoviceStudents Lev1_count

//NCESDistrictID & DistName
split ID, parse("_")
drop ID
rename ID1 NCESDistrictID
rename ID2 DistName

//SchYear
replace SchYear = substr(SchYear, 1,5) + substr(SchYear, 8,2)

//Cleaning Percents & Counts
foreach var of varlist Lev* {
	replace `var' = "--" if `var' == "0"
	replace `var' = "--" if missing(`var')
}

foreach percent of varlist Lev*_percent {
	replace `percent' = string(real(`percent')) if !missing(real(`percent'))
}

//StudentSubGroup_TotalTested
gen StudentSubGroup_TotalTested = string(real(Lev1_count) + real(Lev2_count) + real(Lev3_count) + real(Lev4_count)) if !inlist(Lev1_count, "*", "--") & !inlist(Lev2_count, "*", "--") & !inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--")

forvalues n = 1/4{
	replace StudentSubGroup_TotalTested = string(round(real(Lev`n'_count)/real(Lev`n'_percent))) if !missing(real(Lev`n'_count)) & !missing(real(Lev`n'_percent)) & missing(StudentSubGroup_TotalTested)
}

replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)

//Deriving Additional Information
replace Lev4_percent = string(1 - real(Lev1_percent) - real(Lev2_percent) - real(Lev3_percent)) if real(Lev4_percent) == . & real(Lev1_percent) != . & real(Lev2_percent) != . & real(Lev3_percent) != .
replace Lev4_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count) - real(Lev3_count)) if real(Lev4_count) == . & real(Lev1_count) != . & real(Lev2_count) != . & real(Lev3_count) != . & real(StudentSubGroup_TotalTested) != .

replace Lev3_percent = string(1 - real(Lev1_percent) - real(Lev2_percent) - real(Lev4_percent)) if real(Lev3_percent) == . & real(Lev1_percent) != . & real(Lev2_percent) != . & real(Lev4_percent) != .
replace Lev3_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count) - real(Lev4_count)) if real(Lev3_count) == . & real(Lev1_count) != . & real(Lev2_count) != . & real(Lev4_count) != . & real(StudentSubGroup_TotalTested) != .

replace Lev2_percent = string(1 - real(Lev1_percent) - real(Lev3_percent) - real(Lev4_percent)) if real(Lev2_percent) == . & real(Lev1_percent) != . & real(Lev3_percent) != . & real(Lev4_percent) != .
replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev3_count) - real(Lev4_count)) if real(Lev2_count) == . & real(Lev1_count) != . & real(Lev3_count) != . & real(Lev4_count) != . & real(StudentSubGroup_TotalTested) != .

replace Lev1_percent = string(1 - real(Lev2_percent) - real(Lev3_percent) - real(Lev4_percent)) if real(Lev1_percent) == . & real(Lev2_percent) != . & real(Lev3_percent) != . & real(Lev4_percent) != .
replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(Lev2_count) - real(Lev3_count) - real(Lev4_count)) if real(Lev1_count) == . & real(Lev2_count) != . & real(Lev3_count) != . & real(Lev4_count) != . & real(StudentSubGroup_TotalTested) != .

gen ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent)) if !missing(real(Lev3_percent)) & !missing(real(Lev4_percent))
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent)) if !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(ProficientOrAbove_percent))
replace ProficientOrAbove_percent = "--" if missing(ProficientOrAbove_percent)

foreach var of varlist Lev*_percent ProficientOrAbove_percent {
	replace `var' = "0" if strpos(`var', "e") != 0
}

gen ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev3_count)) & !missing(real(Lev4_count))
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count)) if !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(ProficientOrAbove_count))
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "G", "G0",.) if GradeLevel != "G38"

//Subject
replace Subject = lower(Subject)

//Separating by year
forvalues year = 2016/2024{
if `year' == 2020 continue
preserve
local prevyear = `year' - 1
keep if SchYear == "`prevyear'-" + substr("`year'", -2,2)
save "${Original}/MT_District_`year'", replace
restore	
}

forvalues year = 2016/2024 {
	if `year' == 2020 continue
	local prevyear = `year' - 1
	use "${Original}/MT_District_`year'", clear
	if `year' != 2024 merge m:1 NCESDistrictID using "${NCES_MT}/NCES_`prevyear'_District", update replace
	if `year' == 2024 merge m:1 NCESDistrictID using "${NCES_MT}/NCES_2022_District", update replace
	drop if _merge == 2
	drop _merge
	save "${Original}/MT_District_`year'", replace
	
//Indicator Variables
gen AssmtName = "Smarter Balanced Assessment"
replace AssmtName = "Montana Science Assessment" if Subject == "sci"
gen AssmtType = "Regular"
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested
gen ProficiencyCriteria = "Levels 3-4"

*replace CountyName = proper(CountyName)

gen StateAssignedDistID = subinstr(State_leaid, "MT-","",.)
drop State_leaid

gen DataLevel = "District"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel

gen SchName = "All Schools"

** Flags
gen Flag_AssmtNameChange = "N"
replace Flag_AssmtNameChange = "Y" if Subject == "sci" & SchYear == "2021-22"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Not applicable"
replace Flag_CutScoreChange_sci = "Y" if SchYear == "2021-22"
replace Flag_CutScoreChange_sci = "N" if inlist(SchYear, "2022-23", "2023-24")
gen Flag_CutScoreChange_soc = "Not applicable"

//Missing Variables
gen AvgScaleScore = "--"
gen ParticipationRate = "--"
gen NCESSchoolID = ""
gen SchType = ""
gen SchLevel = ""
gen SchVirtual = ""
gen StateAssignedSchID = ""
gen Lev5_count = ""
gen Lev5_percent = ""

//Include all Appropriate Observations
duplicates drop
append using "${Output}/MT_AssmtData_`year'_State"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/MT_AssmtData_`year'", replace
export delimited "${Output}/MT_AssmtData_`year'", replace	
clear	
}



