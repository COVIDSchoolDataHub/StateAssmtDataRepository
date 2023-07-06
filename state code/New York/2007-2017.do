clear
set more off

local original "/Users/joshuasilverman/Documents/State Test Project/New York/Original"
local output "/Users/joshuasilverman/Documents/State Test Project/New York/Output"
local nces_school "/Users/joshuasilverman/Documents/State Test Project/NCES/School"
local nces_district "/Users/joshuasilverman/Documents/State Test Project/NCES/District"


foreach year in 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 {
local prevyear =`=`year'-1'
use "`original'/Combined_`year'"

//Data contains test score data from prior year in each file
drop if `year' != v3

//Mapping v[n] onto variables in crosswalk
rename v2 ENTITY_NAME
rename v3 YEAR
rename v4 StudentSubGroup
rename v5 StudentSubGroup_TotalTested
rename v6 Lev1_count
rename v7 Lev1_percent
rename v8 Lev2_count
rename v9 Lev2_percent
rename v10 Lev3_count
rename v11 Lev3_percent
rename v12 Lev4_count
rename v13 Lev4_percent
rename v14 TOTAL_SCALE_SCORES
rename v15 AvgScaleScore

//Fixing ENTITY_CD

format v1 %18.0g
gen ENTITY_CD = string(v1, "%18.0g")
drop v1
order ENTITY_CD

//creating DataLevel, StateAssignedSchID, StateAssignedDistID, based on ENTITY_CD
drop if strlen(ENTITY_CD)<12
drop if substr(ENTITY_CD,3,10)== "0000000000"
gen DataLevel= "State" if ENTITY_CD== "111111111111"
replace DataLevel= "District" if substr(ENTITY_CD,9,4)=="0000"
replace DataLevel= "School" if substr(ENTITY_CD,9,4) !="0000"
replace DataLevel = "State" if ENTITY_CD== "111111111111"
gen StateAssignedSchID = ENTITY_CD if DataLevel== "School"
gen StateAssignedDistID = ENTITY_CD if DataLevel== "District"
replace StateAssignedDistID = substr(ENTITY_CD,1,8) + "0000" if DataLevel=="School"

//Merging and cleaning NCES Data
tempfile temp1
save "`temp1'"
clear
use "`nces_school'/NCES_`prevyear'_School.dta"
drop if state_location != "NY"
drop if seasch == ""

if `year' == 2017 {
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1, 12)
decode SchVirtual, gen(SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual
}

else {
	gen StateAssignedSchID = seasch
}
merge 1:m StateAssignedSchID using "`temp1'"
drop if _merge !=3 & DataLevel == "School"
rename _merge _merge1 
tempfile temp2
save "`temp2'"
clear
use "`nces_district'/NCES_`prevyear'_District.dta"
drop if state_location != "NY"
if `year' == 2017 {
gen StateAssignedDistID = substr(state_leaid, strpos(state_leaid, "-")+1, 12)
}
else {
gen StateAssignedDistID = state_leaid
}
merge 1:m StateAssignedDistID using "`temp2'"
drop if _merge1 !=3 & DataLevel== "School"
drop if _merge !=3 & DataLevel == "District"
drop if DataLevel==""
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
replace year = `prevyear'
tostring year YEAR, replace force
gen SchYear = year + "-" + substr(YEAR,-2,2)

//DistName
drop _merge
gen DistName =""
replace DistName = ENTITY_NAME if DataLevel== "District"
gen SchName = ""
replace SchName = ENTITY_NAME if DataLevel == "School"
replace SchName = "All Schools" if DataLevel != "School"
tempfile temp3
save "`temp3'"
drop if DataLevel != "District"
keep DistName StateAssignedDistID
duplicates drop
merge 1:m StateAssignedDistID using "`temp3'"
drop _merge
replace DistName = "All Districts" if DataLevel== "State"
replace DistName = lea_name if DistCharter == "Yes"

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

//Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "MATH"
replace Subject = "sci" if Subject == "SCIENCE"
replace Subject = "soc" if Subject == "SOC"

//StudentSubGroup
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian or Pacific Islander" | StudentSubGroup == "Asian or Native Hawaiian/Other Pacific Islander"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "Two or More" if StudentSubGroup ==  "Multiracial"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learner" | StudentSubGroup == "English Language Learners"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Language Learners"

keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
*tab StudentGroup, missing

//StudentGroup_TotalTested
sort StudentGroup
egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2013
gen Flag_CutScoreChange_math = "N"
replace Flag_CutScoreChange_math = "Y" if `year' == 2013
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"
replace Flag_CutScoreChange_oth = "Y" if `year' == 2013
//Proficiency Counts and Percents
gen ProficientOrAbove_count = ""
gen ProficientOrAbove_percent = ""
	
	//Suppressed data
	gen SUP = "N"
	replace SUP = "s" if Lev4_count== "s"
	
destring Lev*, replace force
gen tempvar1 = Lev3_count + Lev4_count
gen tempvar2 = tempvar1/StudentSubGroup_TotalTested
tostring tempvar2, replace force
tostring tempvar1, replace force
replace ProficientOrAbove_count = tempvar1
replace ProficientOrAbove_percent = tempvar2
foreach n in 1 2 3 4 {
	replace Lev`n'_percent = Lev`n'_percent/100
}
tostring Lev*, replace force
foreach num in 1 2 3 4 {
	replace Lev`num'_count = "*" if SUP == "s"
	replace Lev`num'_percent = "*" if SUP == "s"
	
}
replace ProficientOrAbove_count = "*" if SUP == "s"
replace ProficientOrAbove_percent = "*" if SUP =="s"
replace AvgScaleScore = "*" if SUP == "s"
replace Lev5_count = ""
replace Lev5_percent = ""

//Fixing Charter Schools (In NY, Charter Schools are classified as their own district)
replace DistName = SchName if DistName == "" & (DistCharter== "Yes" | strpos(SchName, "CHARTER") !=0)
replace DistType = "Charter Agency" if DistType == "" & strpos(SchName, "CHARTER") !=0


//Final Sorting and dropping extra variables

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`output'/NY_AssmtData_`year'", replace
export delimited "`output'/NY_AssmtData_`year'", replace

		
}
