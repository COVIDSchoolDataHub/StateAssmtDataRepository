clear
set more off

local original "/Users/joshuasilverman/Documents/State Test Project/New York/Original"
local output "/Users/joshuasilverman/Documents/State Test Project/New York/Output"
local nces_school "/Users/joshuasilverman/Documents/State Test Project/NCES/School"
local nces_district "/Users/joshuasilverman/Documents/State Test Project/NCES/District"

use "`original'/Combined_2006.dta"

//Fixing BEDS_CD

format v1 %18.0g
gen BEDS_CD = string(v1, "%18.0g")
drop v1
order BEDS_CD

//Correcting v1-v12 so that the same variable is represented across subjects and renaming v1-v12 when necessary

rename v2 SchName
rename v3 StudentSubGroup
rename v4 StudentSubGroup_TotalTested
rename v11 TOTALSCALESCORE
rename v12 AvgScaleScore
replace TOTALSCALESCORE = v9 if subject=="SOC"
replace AvgScaleScore = v10 if subject=="SOC"
gen Lev1_count =""
gen Lev1_percent=""
gen Lev2_count=""
gen Lev2_percent=""
gen Lev3_count=""
gen Lev3_percent=""
gen Lev4_count=""
gen Lev4_percent=""
replace Lev1_count= v5 if subject== "SOC"
replace Lev2_count= v6 if subject== "SOC"
replace Lev3_count= v7 if subject== "SOC"
replace Lev4_count= v8 if subject== "SOC"
replace Lev4_count= v9 if subject != "SOC"
replace Lev4_percent= v10 if subject != "SOC"

//Proficiency Counts
gen ProficientOrAbove_count= ""
replace ProficientOrAbove_count = v7 if subject != "SOC"

	//Suppressed data
	gen SUP = "N"
	replace SUP = "s" if Lev4_count== "s"

destring Lev*, replace force
gen tempvar1 = Lev3_count + Lev4_count if subject == "SOC"
gen ProficientOrAbove_percentSOC = tempvar1/StudentSubGroup_TotalTested
tostring ProficientOrAbove_percentSOC, replace force
tostring tempvar1, replace force
replace ProficientOrAbove_count = tempvar1 if subject == "SOC"

tostring Lev*, replace force
foreach num in 1 2 3 4 {
	replace Lev`num'_count = "*" if SUP == "s"
	replace Lev`num'_percent = "*" if SUP == "s"
	
}
gen ProficientOrAbove_percent = ""
replace ProficientOrAbove_percent = ProficientOrAbove_percentSOC if subject== "SOC"
replace ProficientOrAbove_percent = v8 if subject != "SOC"
replace ProficientOrAbove_count = "*" if SUP == "s"
replace ProficientOrAbove_percent = "*" if SUP =="s"
replace AvgScaleScore = "*" if SUP == "s"
//More levels cleaning
drop v5
drop v6
drop v7
drop v8
drop v9
drop v10
replace Lev1_count ="--" if subject !="SOC"
replace Lev1_percent ="--"
replace Lev2_count = "--" if subject !="SOC"
replace Lev2_percent = "--"
replace Lev3_count="--" if subject !="SOC"
replace Lev3_percent= "--"
replace Lev4_percent = "--" if subject=="SOC"

drop SUP

//creating DataLevel, StateAssignedSchID, StateAssignedDistID, based on BEDS_CD
drop if strlen(BEDS_CD)<12
drop if substr(BEDS_CD,3,10)== "0000000000"
gen DataLevel= "State" if BEDS_CD== "111111111111"
replace DataLevel= "District" if substr(BEDS_CD,9,4)=="0000"
replace DataLevel= "School" if substr(BEDS_CD,9,4) !="0000"
replace DataLevel = "State" if BEDS_CD== "111111111111"
gen StateAssignedSchID = BEDS_CD if DataLevel== "School"
gen StateAssignedDistID = BEDS_CD if DataLevel== "District"
replace StateAssignedDistID = substr(BEDS_CD,1,8) + "0000" if DataLevel=="School"

//Merging and cleaning NCES Data
tempfile temp1
save "`temp1'"
clear
use "`nces_school'/NCES_2005_School.dta"
drop if state_location != "NY"
gen StateAssignedSchID = seasch
merge 1:m StateAssignedSchID using "`temp1'"
drop if _merge !=3 & DataLevel == "School"
rename _merge _merge1 
tempfile temp2
save "`temp2'"
clear
use "`nces_district'/NCES_2005_District.dta"
drop if state_location != "NY"
gen StateAssignedDistID = state_leaid
merge 1:m StateAssignedDistID using "`temp2'"
drop if _merge1 !=3 & DataLevel== "School"
drop if _merge !=3 & DataLevel == "District"
drop if DataLevel==""
tostring year, replace force
replace year = "2005-06"
rename year SchYear
rename state_location StateAbbrev
rename state_name State
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
tostring State, replace force
replace State = "New York"
replace StateAbbrev = "NY"
replace StateFips = 36
decode district_agency_type, gen(DistType)
drop district_agency_type
decode school_type, gen(SchType)
drop school_type
decode SchLevel, gen(SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel
rename county_name CountyName
rename county_code CountyCode

//DistName
drop _merge
gen DistName =""
replace DistName = SchName if DataLevel== "District"
replace SchName = "All Schools" if DataLevel != "School"
tempfile temp3
save "`temp3'"
drop if DataLevel != "District"
keep DistName StateAssignedDistID
duplicates drop
merge 1:m StateAssignedDistID using "`temp3'"
drop _merge
replace DistName = "All Districts" if DataLevel== "State"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Misc cleaning and generating variables
gen AssmtName = "NYSTP"
gen AssmtType = "Regular"
rename subject Subject
rename grade GradeLevel
gen ParticipationRate=""
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficiencyCriteria = "Level 3 or 4"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian or Pacific Islander" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "Limited English Proficient"
drop if StudentSubGroup == "General Education" | StudentSubGroup == "Migrant" | StudentSubGroup == "Not Migrant" | StudentSubGroup == "Small Group Total" | StudentSubGroup == "Students with Disabilities"
*tab StudentGroup, missing

//StudentGroup_TotalTested
sort StudentGroup
egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)

//Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "MATH"
replace Subject = "sci" if Subject == "SCIENCE"
replace Subject = "soc" if Subject == "SOC"

//StudentSubGroup
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian or Pacific Islander"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

//Fixing Charter Schools (In NY, Charter Schools are classified as their own district)
replace DistName = SchName if DistName == "" & (DistCharter== "Yes" | strpos(SchName, "CHARTER") !=0)
replace DistType = "Charter Agency" if DistType == "" & strpos(SchName, "CHARTER") !=0



//Final Sorting and dropping extra variables

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "`output'/NY_AssmtData_2006", replace
export delimited "`output'/NY_AssmtData_2006", replace



















