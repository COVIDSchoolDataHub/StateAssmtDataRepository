clear
set more off

** INSTALL BELOW PACKAGE IF YOU HAVEN'T**

*ssc install filelist

** Set directories

global Excel_Files "/Volumes/T7/State Test Project/Montana/Original/MT District Data"
global Combined_Stata "/Volumes/T7/State Test Project/Montana/Original"
global Output "/Volumes/T7/State Test Project/Montana/Output"
global NCES_MT "/Volumes/T7/State Test Project/Montana/NCES"



// RUN BELOW CODE ON FIRST RUN. COMBINES FILES.

/*
//Get Dataset of all filenames
filelist, dir("${Excel_Files}")
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
			cap noisily import excel "${Excel_Files}/MT_District_`ID'_`Subject'_`GradeLevel'_AllStudents.xlsx", cellrange(A3) firstrow case(preserve) allstring clear
			if _rc !=0 continue
			gen ID = "`ID'"
			gen GradeLevel = "`GradeLevel'"
			gen Subject = "`Subject'"
			append using "`temp1'"
			save "`temp1'", replace
			}
		}
	}
use "`temp1'"
save "${Combined_Stata}/AllDistricts", replace
*/

// CLEANING FILE //
use "${Combined_Stata}/AllDistricts", clear
drop if SchoolYear == "2019-2020"

//Renaming
rename SchoolYear SchYear
rename NovicePercent Lev1_percent
rename NearingProficientPercent Lev2_percent
rename ProficientPercent Lev3_percent
rename AdvancedPercent Lev4_percent
rename AdvancedStudents Lev4_count
rename ProficientStudents Lev3_count
rename NearingProficiencyStudents Lev2_count
rename NoviceStudents Lev1_count

//NCESDistrictID & DistName
split ID, parse("_")
drop ID
rename ID1 NCESDistrictID
rename ID2 DistName

//SchYear
replace SchYear = substr(SchYear, 1,5) + substr(SchYear, -2,2)

//Cleaning Percents & Counts
foreach var of varlist Lev* {
	replace `var' = "--" if missing(`var')
}

foreach percent of varlist Lev*_percent {
	replace `percent' = string(real(`percent'), "%9.3g") if !missing(real(`percent'))
}

//Generating Variables
gen ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent), "%9.3g") if !missing(real(Lev3_percent)) & !missing(real(Lev4_percent))
replace ProficientOrAbove_percent = "--" if missing(ProficientOrAbove_percent)

gen ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count), "%9.3g") if !missing(real(Lev3_count)) & !missing(real(Lev4_count))
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)

gen StudentSubGroup_TotalTested = string(real(Lev1_count) + real(Lev2_count) + real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & !missing(real(Lev3_count)) & !missing(real(Lev4_count))
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "G", "G0",.) if GradeLevel != "G38"

//Subject
replace Subject = lower(Subject)

//Separating by year
tempfile temp1
save "`temp1'", replace
clear
forvalues year = 2016/2023 {
if `year' == 2020 continue
local prevyear = `year' - 1
use "`temp1'"
keep if SchYear == "`prevyear'-" + substr("`year'", -2,2)
save "${Combined_Stata}/MT_District_`year'", replace
clear	
}

forvalues year = 2016/2023 {
	if `year' == 2020 continue
	local prevyear = `year' - 1
	use "${Combined_Stata}/MT_District_`year'", clear
	merge m:1 NCESDistrictID using "${NCES_MT}/NCES_`prevyear'_District", update replace
	drop if _merge == 2
	drop _merge
	save "${Combined_Stata}/MT_District_`year'", replace
	
//Indicator Variables
gen AssmtName = "Smarter Balanced Assessment"
gen AssmtType = "Regular"
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested
gen ProficiencyCriteria = "Levels 3-4"


replace CountyName = proper(CountyName)

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
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Not applicable"
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


//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/MT_AssmtData_`year'_District", replace	
clear	
}



