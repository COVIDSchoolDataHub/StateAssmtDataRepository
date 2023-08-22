clear
set more off
cd "/Volumes/T7/State Test Project/South Dakota"
cap log close
set trace off
log using Observe.log, replace
local Original "/Volumes/T7/State Test Project/South Dakota/Original Data"
local Output "/Volumes/T7/State Test Project/South Dakota/Output"
local NCES_District "/Volumes/T7/State Test Project/NCES/District"
local NCES_School "/Volumes/T7/State Test Project/NCES/School"
local years 2021 2022
local Stata_versions "/Volumes/T7/State Test Project/South Dakota/Stata .dta versions"

*Prepping Files**
//For this code to work, the first time it runs must be to convert all excel files to .dta format. Simply unhide the import and save commands and hide the use command.
foreach year of local years {
	local prevyear =`=`year'-1'
	*import excel "`Original'/SD_OriginalData_`year'.xlsx", firstrow case(preserve)
	*save "`Stata_versions'/SD_OriginalData_`year'", replace
	clear
	use "`Stata_versions'/SD_OriginalData_`year'"


**Cleaning**
drop if TestTaken != "Regular Assessment"

//Renaming Variables
rename C StateAssignedDistID
drop D
rename F StateAssignedSchID
rename AllStudentsAl~e TestedStudents
rename N PartStudents
rename AllStudentsAl~l Lev1_countStudents
rename P Lev1_percentStudents
rename Q Lev2_countStudents
rename R Lev2_percentStudents
rename S Lev3_countStudents
rename T Lev3_percentStudents
rename U Lev4_countStudents
rename V Lev4_percentStudents
rename EnglishLea~T TestedLearners
rename AG PartLearners
rename EnglishLea~L Lev1_countLearners
rename AI Lev1_percentLearners
rename AJ Lev2_countLearners
rename AK Lev2_percentLearners
rename AL Lev3_countLearners
rename AM Lev3_percentLearners
rename AN Lev4_countLearners
rename AO Lev4_percentLearners
rename AY TestedD
rename AZ PartD
rename BA Lev1_countD
rename BB Lev1_percentD
rename BC Lev2_countD
rename BD Lev2_percentD
rename BE Lev3_countD
rename BF Lev3_percentD
rename BG Lev4_countD
rename BH Lev4_percentD
rename FosterCareAll~d TestedCare
rename FJ PartCare
rename FosterCareAll~l Lev1_countCare
rename FL Lev1_percentCare
rename FM Lev2_countCare
rename FN Lev2_percentCare
rename FO Lev3_countCare
rename FP Lev3_percentCare
rename FQ Lev4_countCare
rename FR Lev4_percentCare
rename GB TestedConnected
rename GC PartConnected
rename GD Lev1_countConnected
rename GE Lev1_percentConnected
rename GF Lev2_countConnected
rename GG Lev2_percentConnected
rename GH Lev3_countConnected
rename GI Lev3_percentConnected
rename GJ Lev4_countConnected
rename GK Lev4_percentConnected
rename GU TestedIN
rename GV PartIN
rename GW Lev1_countIN
rename GX Lev1_percentIN
rename GY Lev2_countIN
rename GZ Lev2_percentIN
rename HA Lev3_countIN
rename HB Lev3_percentIN
rename HC Lev4_countIN
rename HD Lev4_percentIN
rename IG TestedBlack
rename IH PartBlack
rename II Lev1_countBlack
rename IJ Lev1_percentBlack
rename IK Lev2_countBlack
rename IL Lev2_percentBlack
rename IM Lev3_countBlack
rename IN Lev3_percentBlack
rename IO Lev4_countBlack
rename IP Lev4_percentBlack
rename IZ TestedHI
rename JA PartHI
rename JB Lev1_countHI
rename JC Lev1_percentHI
rename JD Lev2_countHI
rename JE Lev2_percentHI
rename JF Lev3_countHI
rename JG Lev3_percentHI
rename JH Lev4_countHI
rename JI Lev4_percentHI
rename KL TestedoMR
rename KM PartoMR
rename KN Lev1_countoMR
rename KO Lev1_percentoMR
rename KP Lev2_countoMR
rename KQ Lev2_percentoMR
rename KR Lev3_countoMR
rename KS Lev3_percentoMR
rename KT Lev4_countoMR
rename KU Lev4_percentoMR
rename LE TestedwD
rename LF PartwD
rename LG Lev1_countwD
rename LH Lev1_percentwD
rename LI Lev2_countwD
rename LJ Lev2_percentwD
rename LK Lev3_countwD
rename LL Lev3_percentwD
rename LM Lev4_countwD
rename LN Lev4_percentwD
rename W Prof_countStudents
rename X Prof_percentStudents
rename AP Prof_countLearners
rename AQ Prof_percentLearners
rename BI Prof_countD
rename BJ Prof_percentD
rename FS Prof_countCare
rename FT Prof_percentCare
rename GL Prof_countConnected
rename GM Prof_percentConnected
rename HE Prof_countIN
rename HF Prof_percentIN
rename IQ Prof_countBlack
rename IR Prof_percentBlack
rename JJ Prof_countHI
rename JK Prof_percentHI
rename KV Prof_countoMR
rename KW Prof_percentoMR
rename LO Prof_countwD
rename LP Prof_percentwD
rename AsianAllStude~m TestedAsian
rename AsianAllStude~r PartAsian
rename AsianAllStu~1Nu Lev1_countAsian
rename AsianAllStu~1Pe Lev1_percentAsian
rename AsianAllStu~2Nu Lev2_countAsian
rename AsianAllStu~2Pe Lev2_percentAsian
rename AsianAllStu~3Nu Lev3_countAsian
rename AsianAllStu~3Pe Lev3_percentAsian
rename AsianAllStu~4Nu Lev4_countAsian
rename AsianAllStu~4Pe Lev4_percentAsian
rename AsianAllStude~L Prof_countAsian
rename HY Prof_percentAsian
rename WhiteCaucasi~Te TestedWhite
rename JT PartWhite
rename WhiteCaucasi~Le Lev1_countWhite
rename JV Lev1_percentWhite
rename JW Lev2_countWhite
rename JX Lev2_percentWhite
rename JY Lev3_countWhite
rename JZ Lev3_percentWhite
rename KA Lev4_countWhite
rename KB Lev4_percentWhite
rename KC Prof_countWhite
rename KD Prof_percentWhite
rename FemaleAllStud~u TestedFemale
rename FemaleAllStud~e PartFemale
foreach n in 1 2 3 4 {
	rename FemaleAllStu~`n'N Lev`n'_countFemale
	rename FemaleAllStu~`n'P Lev`n'_percentFemale
}
rename FemaleAllStud~r Prof_countFemale
rename CC Prof_percentFemale
rename MaleAllStuden~b TestedMale
rename MaleAllStuden~c PartMale
foreach n in 1 2 3 4 {
	rename MaleAllStu~`n'Num Lev`n'_countMale
	rename MaleAllStu~`n'Per Lev`n'_percentMale
}
rename MaleAllStude~Le Prof_countMale
rename CV Prof_percentMale

//Reshaping from wide to long
rename GradeLevels GradeLevel
keep if GradeLevel == "03" | GradeLevel == "04" | GradeLevel == "05" | GradeLevel == "06" | GradeLevel == "07" | GradeLevel == "08"
reshape long Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_percent Lev3_count Lev4_count Lev4_percent Prof_count Prof_percent Part Tested, i(District School GradeLevel Subject) j(StudentSubGroup, string)
*save "/Volumes/T7/State Test Project/South Dakota/test/`year'", replace
keep if inlist(StudentSubGroup, "Asian","Black","D","HI","IN","Learners","Students") | inlist(StudentSubGroup,"White","oMR","Male","Female","Hispanic")

//Fixing StudentSubGroup now because it's bothering me
replace StudentSubGroup = "Two or More" if StudentSubGroup == "oMR" 
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "D"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "HI"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "IN"
replace StudentSubGroup = "All Students" if StudentSubGroup == "Students"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Learners"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
*save "/Volumes/T7/State Test Project/South Dakota/test/`year'", replace

//Way too many variables
keep District School GradeLevel Subject StateAssignedDistID StateAssignedSchID StudentSubGroup AcademicYear Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Tested Part Prof_count Prof_percent
*save "/Volumes/T7/State Test Project/South Dakota/test/`year'", replace

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if District == "All Districts"
replace DataLevel = "District" if District != "All Districts" & School == "All Schools"
replace DataLevel = "School" if School != "All Schools"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Merging NCES Data

//NCES District
tempfile tempall
save "`tempall'", replace
keep if DataLevel == 2
gen UniqueDistID = StateAssignedDistID
tempfile temp1
save "`temp1'", replace
clear
use "`NCES_District'/NCES_`prevyear'_District.dta"
keep if state_fips == 46
gen UniqueDistID = substr(state_leaid, strpos(state_leaid, "-")+1, 6)
merge 1:m UniqueDistID using "`temp1'"
save "`temp1'", replace
clear
//NCES School
use "`tempall'", replace
keep if DataLevel == 3
gen UniqueSchID = StateAssignedDistID + "-" + StateAssignedSchID
tempfile temp2
save "`temp2'", replace
clear
use "`NCES_School'/NCES_`prevyear'_School.dta"
keep if state_fips == 46
gen UniqueSchID = seasch
merge 1:m UniqueSchID using "`temp2'"
save "`temp2'", replace
clear
use "`tempall'"
keep if DataLevel==1
append using "`temp1'" "`temp2'"
drop if _merge ==1
*save "/Volumes/T7/State Test Project/South Dakota/test/`year'", replace

//Fixing Subject
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

//Correcting Variables
rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
drop AcademicYear
gen SchYear = "`prevyear'"+ "-" + substr("`year'",3, 2)
rename district_agency_type DistType
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
gen AssmtName = ""
replace AssmtName = "SBAC" if Subject != "sci"
replace AssmtName = "SDSA" if Subject == "sci"
gen AssmtType = "Regular"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Two or More"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"

//StudentSubGroup_TotalTested
rename Tested StudentSubGroup_TotalTested

//StudentGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(Tested) i(*.)
egen StudentGroup_TotalTested = total(Tested), by(StudentGroup GradeLevel Subject District School DataLevel)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"
drop Tested
*save "/Volumes/T7/State Test Project/South Dakota/test/`year'", replace

//Proficiency
gen ProficiencyCriteria = "Levels 3 and 4"

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = ""
replace Flag_CutScoreChange_oth = "N"
gen Flag_CutScoreChange_read = "N"
//Fixing NCES Data at state level / all levels really
drop State
gen State = "South Dakota"
replace StateAbbrev = "SD"
replace StateFips = 46

//Renaming final Variables
rename District DistName
rename School SchName
rename Part ParticipationRate
rename Prof_count ProficientOrAbove_count
rename Prof_percent ProficientOrAbove_percent

//Empty Variables
gen Lev5_count = ""
gen Lev5_percent = ""
gen AvgScaleScore = "--"

//Misc Additional
replace StateAssignedSchID = "" if DataLevel !=3
replace StateAssignedDistID = "" if DataLevel == 1
replace GradeLevel = "G" + GradeLevel

//Final cleaning and dropping extra variables
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//Saving
save "`Output'/SD_AssmtData_`year'", replace

clear
}
log close
