clear
set more off
set trace off //TURN THIS ON FOR DEBUGGING LOOPS

global Original "/Users/miramehta/Documents/AR State Testing Data/Original Data"
global Output "/Users/miramehta/Documents/AR State Testing Data/Output"
global NCES "//Users/miramehta/Documents/NCES District and School Demographics"
global Temp "/Users/miramehta/Documents/AR State Testing Data/Temp"
global EDFacts "/Users/miramehta/Documents/AR State Testing Data/EDFacts"

forvalues year = 2016/2023 {
local prevyear =`=`year'-1'
if `year' == 2020 continue
tempfile temp1
save "`temp1'", emptyok replace
clear

				 ** DISTRICT & SCHOOL LEVEL CLEANING ** 
				 
				 
	*UNHIDE THIS CODE ON FIRST RUN			 

//Importing & Combining & Renaming for each Year at District and School Level Data
foreach dl in District School {
import excel using "${Original}/State, Dist, Sch Subgroup Data - Added 3-5-24/AR_`dl'_Subgroups_`year'_no counts.xlsx"
drop in 1

//Setting up variable names

**Renaming variable values in first row to then rename the generic excel letter variables to descriptive variables
foreach v of varlist _all {
replace `v' = subinstr(`v',"ACT Aspire - Grade ","",.)
replace `v' = subinstr(`v',": Percent Meets/Exceeds Standards - ","",.)
local vars = `v'[2] + `v'[1]
replace `v' = "`vars'" in 1
replace `v' = subinstr(`v', " ", "",50) in 1
replace `v' = subinstr(`v', "EconomicallyDisadvantaged", "_ECD_",.) in 1
replace `v' = subinstr(`v', "StudentswithDisabilities", "_SWD_",.) in 1
replace `v' = subinstr(`v', "AfricanAmerican", "_BLK_",.) in 1
replace `v' = subinstr(`v', "Caucasian", "_WHT_",.) in 1
replace `v' = subinstr(`v', "Hispanic", "_HIS_",.) in 1
replace `v' = subinstr(`v', "EnglishLearners", "_LER_",.) in 1
replace `v' = subinstr(`v', "Migrant", "_MIG_",.) in 1
replace `v' = subinstr(`v', "Female", "_FML_",.) in 1
replace `v' = subinstr(`v', "Male", "_MAL_",.) in 1
replace `v' = subinstr(`v', "CombinedPopulation", "_ALL_",.) in 1
forvalues n = 3/8 {
	replace `v' = subinstr(`v',"`n'","`n'",.) in 1
}
replace `v' = subinstr(`v', "Science", "_sci",.) in 1
replace `v' = subinstr(`v', "Reading", "_read",.) in 1
replace `v' = subinstr(`v', "Literacy", "_ela",.) in 1
replace `v' = subinstr(`v', "English", "_eng",.) in 1
replace `v' = subinstr(`v', "Math", "_math",.) in 1
}
drop in 2 // Second part of varnames included in new variables, dropping

foreach v of varlist _all { //renaming vars to first row
local var = `v'[1]
rename `v' Prof`var'
}
drop in 1 //Renamed variables to variable values in first row, deleting first row
if "`dl'" == "District" rename ProfLEA StateAssignedDistID
if "`dl'" == "School" rename ProfLEA StateAssignedSchID
cap rename ProfDistrictLEAInformation DistName
cap rename ProfDistrictName DistName
cap rename ProfSchoolName SchName

gen DataLevel = "`dl'"
append using "`temp1'"
save "`temp1'", replace
clear

}
use "`temp1'"
save "${Temp}/`year'_sg", replace
clear


use "${Temp}/`year'_sg"

//Reshaping ** Reshape occurs three times. Original data is fully wide with each SchID/DistID having its own row. The Code below reshapes it so that Every combination of StudentSubGroup, GradeLevel, Subject, and SchID/DistID has its own row
reshape long Prof_BLK_3_ Prof_WHT_3_ Prof_HIS_3_ Prof_ECD_3_ Prof_LER_3_ Prof_SWD_3_ Prof_MIG_3_ Prof_MAL_3_ Prof_FML_3_ Prof_ALL_3_ Prof_BLK_4_ Prof_WHT_4_ Prof_HIS_4_ Prof_ECD_4_ Prof_LER_4_ Prof_SWD_4_ Prof_MIG_4_ Prof_MAL_4_ Prof_FML_4_ Prof_ALL_4_ Prof_BLK_5_ Prof_WHT_5_ Prof_HIS_5_ Prof_ECD_5_ Prof_LER_5_ Prof_SWD_5_ Prof_MIG_5_ Prof_MAL_5_ Prof_FML_5_ Prof_ALL_5_ Prof_BLK_6_ Prof_WHT_6_ Prof_HIS_6_ Prof_ECD_6_ Prof_LER_6_ Prof_SWD_6_ Prof_MIG_6_ Prof_MAL_6_ Prof_FML_6_ Prof_ALL_6_ Prof_BLK_7_ Prof_WHT_7_ Prof_HIS_7_ Prof_ECD_7_ Prof_LER_7_ Prof_SWD_7_ Prof_MIG_7_ Prof_MAL_7_ Prof_FML_7_ Prof_ALL_7_ Prof_BLK_8_ Prof_WHT_8_ Prof_HIS_8_ Prof_ECD_8_ Prof_LER_8_ Prof_SWD_8_ Prof_MIG_8_ Prof_MAL_8_ Prof_FML_8_ Prof_ALL_8_, i(StateAssignedSchID StateAssignedDistID) j(Subject, string)
reshape long Prof_BLK Prof_WHT Prof_HIS Prof_ECD Prof_LER Prof_SWD Prof_MIG Prof_MAL Prof_FML Prof_ALL, i(StateAssignedSchID StateAssignedDistID Subject) j(GradeLevel, string)
reshape long Prof_, i(StateAssignedSchID StateAssignedDistID Subject GradeLevel) j(StudentSubGroup, string)

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "_","",.)
replace GradeLevel = subinstr(GradeLevel, "Grade ", "",.)
replace GradeLevel = subinstr(GradeLevel, ": Percent Meets/Exceeds Standards","",.)
replace GradeLevel = "G0" + GradeLevel

//StudentSubGroup
drop if StudentSubGroup == "ALL"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "BLK"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
replace StudentSubGroup = "Female" if StudentSubGroup == "FML"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "HIS"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LER"
replace StudentSubGroup = "Male" if StudentSubGroup == "MAL"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "MIG"
replace StudentSubGroup = "White" if StudentSubGroup == "WHT"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Native Hawaiian" | StudentSubGroup == "Pacific Islander" | StudentSub == "Filipino"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel != 3

//ProficientOrAbove_percent
rename Prof_ ProficientOrAbove_percent
drop if ProficientOrAbove_percent == "N/A" //these are mostly grades that are no applicable for a given school (but sometimes subgroups without any real data available)
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "RV"
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*-)

replace ProficientOrAbove_percent = string(nProficientOrAbove_percent, "%9.3g") if ProficientOrAbove_percent != "--" & ProficientOrAbove_percent != "*"
if `year' >2021 replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "." //ela G03 is missing in 2022 and 2023. Setting these observations to "--".
drop nProficientOrAbove_percent

//Merging with NCES
tempfile tempm
save "`tempm'", replace

//District Merging
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
clear
use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_`prevyear'_District.dta"
keep if state_name == "Arkansas"
if `year' == 2016 gen StateAssignedDistID = state_leaid
if `year' > 2016 gen StateAssignedDistID = subinstr(state_leaid, "AR-","",.)
if `year' == 2023 tostring _all, replace force
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge == 1
drop _merge
save "`tempdist'", replace
clear

//School Merging
use "`tempm'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear
use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_`prevyear'_School.dta"
label def SchType -1 "Missing/not reported", add
keep if state_name == "Arkansas"
if `year' == 2016 gen StateAssignedSchID = seasch
if `year' > 2016 gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1, 10)
duplicates drop StateAssignedSchID, force
if `year' == 2023 {
foreach var of varlist year district_agency_type SchLevel SchVirtual school_type {
	decode `var', gen(`var'_x)
	drop `var'
	rename `var'_x `var'
}
tostring _all, replace force
}
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge ==1
drop _merge

//Appending District and School Level Data
append using "`tempdist'"
tempfile temp2
save "`temp2'", replace

/*
//Fixing 2023 Unmerged
if `year' == 2023 {	
keep if missing(ncesschoolid) & DataLevel == 3
save "${Temp}/Unmerged_2023", replace
use "${NCES}/NCES_2022_School.dta"
keep if StateName == "Arkansas"
gen StateAssignedSchID = substr(st_schid, -7,7)
gen StateAssignedDistID = State_leaid

*Cleaning 2023 NCES
rename SchoolType SchType
rename NCESDistrictID ncesdistrictid
rename NCESSchoolID ncesschoolid
drop SchYear 
foreach var of varlist SchLevel SchVirtual SchType {
replace `var' = "Missing/not reported"
label def `var' -1 "Missing/not reported"
encode `var', gen(n`var') label(`var')
drop `var'
rename n`var' `var'
}
gen DistLocale = "Missing/not reported"
*Merging
merge 1:m StateAssignedSchID using "${Temp}/Unmerged_2023", keep(match using) nogen
save "${Temp}/Unmerged_2023", replace
clear
use "`temp2'"
drop if missing(ncesschoolid) & DataLevel == 3
append using "${Temp}/Unmerged_2023"
}

*/


//Fixing NCES Variables for all years
rename district_agency_type DistType
*rename school_type SchType
rename ncesdistrictid NCESDistrictID
*rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
if `year' == 2023 rename school_type SchType

replace StateAssignedDistID = state_leaid if DataLevel == 3 & StateAssignedDistID == ""
replace StateAssignedDistID = subinstr(StateAssignedDistID, "AR-", "", 1)

//Saving Before Moving on to State Level Cleaning
save "${Temp}/DistSch_`year'_temp", replace
clear



			 ** STATE LEVEL CLEANING **

//Importing and Adding State Level Data
import excel using "${Original}/State, Dist, Sch Subgroup Data - Added 3-5-24/AR_State_Subgroups_`year'_no counts.xlsx", firstrow
keep Group Element StateofArkansas
drop in 1
split(Group), parse("-")
drop Group
rename Group1 AssmtName
rename Group2 GradeLevel
rename Group3 Subject
foreach var of varlist _all {
	replace `var' = trim(`var')
}
rename Element StudentSubGroup
rename StateofArkansas ProficientOrAbove_percent

//ProficientOrAbove_percent
replace ProficientOrAbove_percent = "--" if missing(ProficientOrAbove_percent)
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(%-)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100, "%9.3g") if ProficientOrAbove_percent != "--"
drop nProficientOrAbove_percent

//Subject
replace Subject = "ela" if Subject == "Literacy"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"
replace Subject = "eng" if Subject == "English"
replace Subject = "read" if Subject == "Reading"

//StudentSubGroups
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "White" if StudentSubGroup == "Caucasian"
drop if StudentSubGroup == "Combined Population"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"

//StudentGroupx
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Exited" | StudentSubGroup == "EL Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//GradeLevel
replace GradeLevel = "G0" + substr(GradeLevel, strpos(GradeLevel, ":")-1,1)

//DataLevel
gen DataLevel = "State"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
gen SchName = "All Schools"
gen DistName = "All Districts"

		** STATE, DISTRICT, SCHOOL COMBINING AND CLEANING **

//Adding District and School Data
append using "${Temp}/DistSch_`year'_temp"		
if `year' >= 2019 drop if DataLevel == 1 //Using data cleaned in StateSG_2019_2023 for State level data from 2019-2023 because it's better

//Generating Additional Variables
cap drop StateFips
gen StateFips = 5
cap drop StateAbbrev
gen StateAbbrev = "AR"
cap drop State
gen State = "Arkansas"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_soc = ""
gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular and alt"
replace AssmtName = "ACT Aspire"
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2018
replace Flag_CutScoreChange_sci = "Y" if `year' == 2018
foreach var of varlist Flag* {
	replace `var' = "Y" if `year' == 2016 & "`var'" != "Flag_CutScoreChange_sci"
}

//Missing Variables
forvalues n = 1/4 {
	gen Lev`n'_percent = "--"
	gen Lev`n'_count = "--"
}
gen Lev5_percent = "--"
gen Lev5_count = "--"
gen ProficientOrAbove_count = "--"
gen AvgScaleScore = "--"
gen ParticipationRate = "--"
gen StudentSubGroup_TotalTested = "--"
gen StudentGroup_TotalTested = "--"

//Order, Keep, Sort, Save
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Temp}/AR_AssmtData_`year'_nocountsSG", replace
clear
}
