clear
set more off

cd "/Volumes/T7/State Test Project/Maine"
global Original "/Volumes/T7/State Test Project/Maine/Original Data Files/For V2.0+ Data Received from Maine - August 2024"
global Output "/Volumes/T7/State Test Project/Maine/Output"
global NCES_School "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_District "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"

//2015-2022 State Level Data
import excel "${Original}/ME_2008 to 2023_state_ela,math_by grade and prof level_no counts", clear firstrow sheet("ALL DATA (2007-2023)")

//Renaming & Dropping
drop if missing(Year)
drop if Year == 2015 | Year == 2023
drop if ContentArea == "Combined"
rename AssessmentName AssmtName
rename Grade GradeLevel
rename ContentArea Subject
rename E Lev1_percent
rename F Lev2_percent
rename G Lev3_percent
rename H Lev4_percent
drop NotProficient
rename Proficient ProficientOrAbove_percent
drop Note

//Fixing Values

gen SchYear = string(Year-1) + "-" + substr(string(Year),-2,2)

replace GradeLevel = "G0" + GradeLevel

gen DataLevel = 1
label def DataLevel 1 "State"
label values DataLevel DataLevel

replace Subject = lower(Subject)
replace Subject = "ela" if Subject == "reading"

foreach percent of varlist *_percent {
	tostring `percent', replace force format("%9.3g")
	replace `percent' = string(real(`percent')/100, "%9.3g") if Year > 2015
	replace `percent' = "--" if `percent' == "."
	local count = subinstr("`percent'", "percent", "count",.)
	gen `count' = "--"
}

//Indicator & missing Variables
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular"


gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

gen State = "Maine"
gen StateAbbrev = "ME"
gen StateFips = 23

gen DistName = "All Districts"
gen SchName = "All Schools"

gen AvgScaleScore = "--"
gen ParticipationRate = "--"




replace AssmtName = "Maine Through Year Assessment" if AssmtName == "Maine Through Year"

//Splitting By Year
tempfile temp1
save "`temp1'", replace
forvalues year = 2016/2022 {
use "`temp1'", clear	
if `year' == 2020 continue

keep if Year == `year'

//Flags

if `year' >= 2016 & `year' <= 2019 {
gen Flag_AssmtNameChange = "Y" if Subject != "sci" 
replace Flag_AssmtNameChange = "N" if Subject == "sci"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"


foreach var of varlist Flag* {
	cap replace `var' = "N" if `year' !=20161
}
}

if `year' == 2021 {
gen Flag_AssmtNameChange = "Y" if Subject != "sci"
replace Flag_AssmtNameChange = "N" if Subject == "sci"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"
}

if `year' == 2022 {
gen Flag_AssmtNameChange = "N" if Subject != "sci"
replace Flag_AssmtNameChange = "Y" if Subject == "sci"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"
}


order State StateAbbrev StateFips SchYear DataLevel DistName SchName AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Output/ME_DataRequest_`year'", replace

}


//2023 Data
clear
tempfile temp2
save "`temp2'", replace empty
import excel "${Original}/ME_2023_state by grade_dist aggregated_ela,math,sci", firstrow clear sheet("Data, Grades 3-8 Combined") allstring
append using "`temp2'"
save "`temp2'", replace
import excel "${Original}/ME_2023_state by grade_dist aggregated_ela,math,sci", firstrow clear sheet("Statewide Data, By Grade") allstring
append using "`temp2'"
save "`temp2'", replace

//Reshaping
rename Total Total_count
rename Female Female_count
rename Male Male_count
rename MultilingualLearner EL_count
rename Asian Asian_count
rename AmericanIndianAlaska AIAN_count
rename BlackAfrican Black_count
rename NativeHawaiianPacific Hawaiian_count
rename White White_count
rename Hispanic Hispanic_count
rename TwoOrMore Two_count
rename EconomicallyDisadvantaged ECD_count
rename NonEconomicallyDisadvantaged nECD_count
rename SWD SWD_count
rename NonSWD nSWD_count
rename Migrant Migrant_count
rename NonMigrant nMigrant_count
rename Homeless Homeless_count
rename NonHomeless nHomeless_count
rename FosterCare Foster_count
rename NonFosterCare nFoster_count
rename Military Military_count
rename NonMilitary nMilitary_count

rename *_count Count_*

reshape long Count_, i(Grade SAUID Subject PerformanceLevel) j(StudentSubGroup, string)
reshape wide Count_, i(Grade SAUID Subject StudentSubGroup) j(PerformanceLevel, string)

rename Count_* Lev*_count

//Renaming
rename Grade GradeLevel
rename SAUID StateAssignedDistID
rename AssessmentTitle AssmtName
rename Name DistName
rename SchoolYear SchYear

//GradeLevel
replace GradeLevel = "G0" + GradeLevel if !missing(GradeLevel)
replace GradeLevel = "G38" if missing(GradeLevel)

//StateAssignedDistID
replace StateAssignedDistID = "" if DataLevel == "State"

//Subject
replace Subject = lower(Subject)
replace Subject = "ela" if Subject == "reading"
replace Subject = "sci" if Subject == "science"

//StudentSubGroup
replace StudentSubGroup = "All Students" if StudentSubGroup == "Total"
*Female
*Male
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL"
*Asian
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "AIAN"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaiian"
*White
*SWD
*Migrant
*Military
*Homeless
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "nECD"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "nFoster"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "nHomeless"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "nMigrant"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "nMilitary"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "nSWD"


//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex" | StudentSubGroup == "EL Exited" | StudentSubGroup == "EL and Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//DataLevel
replace DataLevel = "District" if DataLevel == "SAU"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel

replace DistName = "All Districts" if DataLevel ==1

//SchYear
replace SchYear = "2022-23"

//Level Counts & Percents
foreach count of varlist *_count {
	replace `count' = "--" if missing(`count')
}


//Merging Files
tempfile tempall
save "`tempall'", replace
clear

//NCES Merging
use "`tempall'"
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
use "$NCES_District/NCES_2022_District", clear
keep if state_name == "Maine"
gen StateAssignedDistID = subinstr(state_leaid, "ME-", "",.)
merge 1:m StateAssignedDistID using "`tempdist'", gen(DistMerge)
drop if DistMerge == 1
save "`tempdist'", replace

use "`tempall'"
keep if DataLevel ==1
append using "`tempdist'"

rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
// rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 23
replace StateAbbrev = "ME"
gen State = "Maine"

keep GradeLevel StateAssignedDistID Subject StudentSubGroup Lev1_count Lev2_count Lev3_count Lev4_count AssmtName DistName SchYear StudentGroup DataLevel StateFips NCESDistrictID DistType DistCharter DistLocale CountyCode CountyName StateAbbrev State

//Indicator and Missing Variables
gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "Y"
replace Flag_AssmtNameChange = "N" if Subject == "sci"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Lev5_count = ""
gen AvgScaleScore = "--"
gen ParticipationRate = "--"

gen StateAssignedSchID = ""
gen SchType = ""
gen SchLevel = ""
gen SchVirtual = ""
gen NCESSchoolID = ""
gen SchName = "All Schools"

//Deriving Variables
gen StudentSubGroup_TotalTested = string(real(Lev1_count)+ real(Lev2_count) + real(Lev3_count)+ real(Lev4_count)) if !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & !missing(real(Lev3_count)) & !missing(real(Lev4_count))
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)


gen ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev3_count)) & !missing(real(Lev4_count))
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)

foreach count of varlist *_count {
	local percent = subinstr("`count'", "count", "percent",.)
	gen `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.3g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested))
	replace `percent' = "--" if missing(`percent') | `percent' == "."
}

//StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1


//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Output/ME_DataRequest_2023", replace












