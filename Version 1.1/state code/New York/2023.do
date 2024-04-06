clear
set more off

			** NOTE: SET GLOBAL DIRECTORIES IN NY_Master do-file **

			
			

//ELA
import delimited "${original}/NY_OriginalData_ela_2023.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 NUM_PROF
rename v21 PER_PROF
rename v22 TOTAL_SCALE_SCORES
rename v23 AvgScaleScore
gen subject = "ELA"

tempfile temp1
save "`temp1'"

//MATH

import delimited "${original}/NY_OriginalData_mat_2023.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 Lev5_count
rename v21 Lev5_percent
rename v22 NUM_PROF
rename v23 PER_PROF
rename v24 TOTAL_SCALE_SCORES
rename v25 AvgScaleScore
gen subject = "MATH"

tempfile temp2
save "`temp2'"

//SCIENCE
import delimited "${original}/NY_OriginalData_sci_2023.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 NUM_PROF
rename v21 PER_PROF
rename v22 TOTAL_SCALE_SCORES
rename v23 AvgScaleScore
gen subject = "SCIENCE"

tempfile temp3
save "`temp3'"
clear

//Appending

foreach n in 1 2 3 {
	append using "`temp`n''", force
}

drop if YEAR != 2023

//Fixing ENTITY_CD
gen ENTITY_CD = v1
drop v1
order ENTITY_CD

//creating DataLevel, StateAssignedSchID, StateAssignedDistID, based on ENTITY_CD
drop if strlen(ENTITY_CD)<12
drop if substr(ENTITY_CD,1,2)== "00"
gen DataLevel= "State" if ENTITY_CD== "111111111111"
replace DataLevel= "District" if substr(ENTITY_CD,9,4)=="0000" & substr(ENTITY_CD,7,2) !="86"
replace DataLevel= "School" if substr(ENTITY_CD,9,4) !="0000" & substr(ENTITY_CD,7,2) !="86"
replace DataLevel= "School" if substr(ENTITY_CD,7,2) =="86" //All Charter schools are their own district
replace DataLevel = "State" if ENTITY_CD== "111111111111"
gen StateAssignedSchID = ENTITY_CD if DataLevel== "School"
gen StateAssignedDistID = ENTITY_CD if DataLevel== "District"
replace StateAssignedDistID = substr(ENTITY_CD,1,8) + "0000" if DataLevel=="School" & strpos(ENTITY_NAME, "CHARTER") ==0
replace StateAssignedDistID = ENTITY_CD if strpos(ENTITY_NAME, "CHARTER") !=0 & DataLevel == "School"

//GradeLevel
drop if strpos(ASSESSMENT, "Regents") !=0 | strpos(ASSESSMENT, "Combined") !=0
gen GradeLevel = "G0" + substr(ASSESSMENT, -1, 1)
replace GradeLevel = "G38" if strpos(ASSESSMENT, "_") !=0

//Merging and cleaning NCES Data
tempfile temp1
save "`temp1'"
clear
use "${nces_school}/NCES_2021_School.dta"
drop if state_location != "NY"
drop if seasch == ""
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1, 12)
//Fixing two schools
replace StateAssignedSchID = "320900861122" if ncesschoolid == "360115606620"

merge 1:m StateAssignedSchID using "`temp1'"
*drop if _merge !=3 & DataLevel == "School"
rename _merge _merge1 
tempfile temp2
save "`temp2'"
clear
use "${nces_district}/NCES_2021_District.dta"
drop if state_location != "NY"
gen StateAssignedDistID = substr(state_leaid, strpos(state_leaid, "-")+1, 12)

merge 1:m StateAssignedDistID using "`temp2'"
*drop if _merge1 !=3 & DataLevel== "School"
*drop if _merge !=3 & DataLevel == "District"
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
rename district_agency_type DistType
decode SchLevel, gen(SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel
decode SchVirtual, gen(SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual
rename county_name CountyName
rename county_code CountyCode

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
replace Lev5_count = ""
replace Lev5_percent = ""
gen ProficiencyCriteria = "Levels 3-4"
gen SchYear = "2022-23"


//Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "MATH"
replace Subject = "sci" if Subject == "SCIENCE"
replace Subject = "soc" if Subject == "SOC"

//StudentSubGroup
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup, "Asian") !=0
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "Two or More" if StudentSubGroup ==  "Multiracial"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learner" | StudentSubGroup == "English Language Learners"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Language Learners" | StudentSubGroup == "Non-English Language Learner"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiracial"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "General Education Students"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "In Foster Care"
replace StudentSubGroup = "Gender X" if StudentSubGroup == "Non-Binary"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Homeless"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not in Foster Care"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Parent Not in Armed Forces"
replace StudentSubGroup = "Military" if StudentSubGroup == "Parent in Armed Forces"
drop if strpos(StudentSubGroup, "Small Group Total") !=0
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"


//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"
*tab StudentGroup, missing

//StudentGroup_TotalTested
*duplicates drop
destring StudentSubGroup_TotalTested, replace
egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"

//Proficiency
rename NUM_PROF ProficientOrAbove_count //already in correct format

	//Suppressed data
	gen SUP = "N"
	replace SUP = "s" if Lev4_count== "s"
	
destring Lev*_percent, replace force

foreach n in 1 2 3 4 {
replace Lev`n'_percent = Lev`n'_percent/100
}
tostring Lev*_percent, replace format("%9.3g") force
foreach n in 1 2 3 4 {
replace Lev`n'_percent = "*" if SUP=="s"
replace Lev`n'_count = "*" if SUP=="s"
replace Lev`n'_percent = "0" if Lev`n'_percent=="" | Lev`n'_percent== "."
replace Lev`n'_count = "0" if Lev`n'_count == "" | Lev`n'_count== "."
}
replace ProficientOrAbove_count = "*" if SUP== "s"
rename PER_PROF ProficientOrAbove_percent
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) force
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100, "%9.3g")
replace ProficientOrAbove_percent = "*" if SUP== "s"
replace Lev5_percent = ""
replace AvgScaleScore = "*" if SUP== "s"
replace ParticipationRate = ParticipationRate/100
tostring ParticipationRate, replace force format("%9.3g")
replace ParticipationRate= "0" if ParticipationRate=="."
replace AvgScaleScore = "0" if AvgScaleScore == ""
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_percent =="."

//Fixing Charter Schools (In NY, Charter Schools are classified as their own district)
replace DistName = SchName if DistName == "" & (DistCharter== "Yes" | strpos(SchName, "CHARTER") !=0)
replace DistType = "Charter Agency" if DistType == "" & strpos(SchName, "CHARTER") !=0
replace StateAssignedDistID = StateAssignedSchID if DistCharter == "Yes" | strpos(SchName, "CHARTER") !=0

//Fixing SchVirtual for Missing schools
replace SchVirtual = "Missing/not reported" if SchVirtual == "" & DataLevel ==3

//Fixing 2023 Unmerged
tempfile temp1
save "`temp1'", replace
keep if missing(NCESSchoolID) & DataLevel ==3
tempfile tempunmerged
save "`tempunmerged'", replace
use "${nces_school}/NCES_2022_School"
keep if State == "New York"
destring StateFips, replace
replace StateAssignedSchID = substr(StateAssignedSchID, -12,12)
merge 1:m StateAssignedSchID using "`tempunmerged'", update
drop if _merge ==1
save "`tempunmerged'", replace
use "`temp1'"
drop if missing(NCESSchoolID) & DataLevel ==3
append using "`tempunmerged'"

//Dropping if No Students Tested
drop if StudentSubGroup_TotalTested == 0



//Final Cleaning

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/NY_AssmtData_2023", replace
export delimited "${output}/NY_AssmtData_2023", replace


