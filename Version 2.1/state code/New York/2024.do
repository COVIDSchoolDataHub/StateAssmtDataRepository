*******************************************************
* NEW YORK

* File name: 2024
* Last update: 03/03/2025

*******************************************************
* Notes

	* This do file imports NY 2024 *.txt files and combines it as a dta. 
	* Variables are renamed and cleaned.
	* The file is merged with NCES_2022.
	* This file will need to be updated when NCES_2023 is available. 
	* This file creates the usual output for 2024.
	
*******************************************************

clear
set more off

//ELA
import delimited "${Original_2}/NY_OriginalData_ela_2024.txt", clear stringcols(2)
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

import delimited "${Original_2}/NY_OriginalData_mat_2024.txt", clear stringcols(2)
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
import delimited "${Original_2}/NY_OriginalData_sci_2024.txt", clear stringcols(2)
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

save "${Original_DTA}/Combined_2024.dta", replace

drop if YEAR != 2024

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
replace StateAssignedDistID = ENTITY_CD if strpos(ENTITY_CD, "86") == 7 & DataLevel == "School" // based on designation of charter schools in IDs (as noted above)

//GradeLevel
drop if strpos(ASSESSMENT, "Regents") !=0 | strpos(ASSESSMENT, "Combined") !=0
gen GradeLevel = "G0" + substr(ASSESSMENT, -1, 1)
drop if strpos(ASSESSMENT, "_") !=0 //Values dropped- include data for Lev5_count and Lev5_percent in raw data, indicating that they aggregate Regents exam information as well.

//Merging and cleaning NCES Data
tempfile temp1
save "`temp1'"
clear
use "${NCES_School}/NCES_2022_School.dta"
drop if state_location != "NY"
drop if seasch == ""
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1, 12)
//Fixing two schools

merge 1:m StateAssignedSchID using "`temp1'"
*drop if _merge !=3 & DataLevel == "School"
rename _merge _merge1 

//Fixing NCES 2022 School Data Before Appending
drop year boundary_change_indicator number_of_schools fips
decode district_agency_type, gen(temp1)
drop district_agency_type
rename temp1 district_agency_type
tempfile temp2
save "`temp2'"
clear
use "${NCES_District}/NCES_2022_District.dta"
drop if state_location != "NY"
gen StateAssignedDistID = substr(state_leaid, strpos(state_leaid, "-")+1, 12)

merge 1:m StateAssignedDistID using "`temp2'"
/*
preserve
drop if inlist(_merge1, 1, 3) & inlist(_merge, 1, 3)
drop if _merge1 == 2 & DataLevel != "School" & inlist(_merge, 1, 3)
drop if _merge == 1
drop if _merge1 == 1
drop if DataLevel == "State"
keep if (_merge1 == 2 & DataLevel == "School") | (_merge == 2 & DataLevel != "State")
keep StateAssignedDistID ENTITY_NAME StateAssignedSchID DataLevel
duplicates drop
export excel "$output/New Schools 2024.xlsx", replace
restore
*/
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
rename school_type SchType
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
gen SchYear = "2023-24"


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
sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "Y"

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
replace DistName = SchName if DistName == "" & DataLevel == 3

//2024 New Schools
replace NCESDistrictID = "3601144" if StateAssignedDistID == "310500861081"
replace DistType = "Charter agency" if NCESDistrictID == "3601144"
replace DistCharter = "Yes" if NCESDistrictID == "3601144"
replace DistLocale = "City, large" if NCESDistrictID == "3601144"
replace CountyName = "New York County" if NCESDistrictID == "3601144"
replace CountyCode = "36061" if NCESDistrictID == "3601144"
replace NCESSchoolID = "360114406597" if StateAssignedSchID == "310500861081"
replace SchType = 1 if NCESSchoolID == "360114406597"
replace SchLevel = 4 if NCESSchoolID == "360114406597"
replace SchVirtual = 0 if NCESSchoolID == "360114406597"

replace NCESDistrictID = "3601192" if StateAssignedDistID == "310400861171"
replace DistType = "Charter agency" if NCESDistrictID == "3601192"
replace DistCharter = "Yes" if NCESDistrictID == "3601192"
replace DistLocale = "City, large" if NCESDistrictID == "3601192"
replace CountyName = "New York County" if NCESDistrictID == "3601192"
replace CountyCode = "36061" if NCESDistrictID == "3601192"
replace NCESSchoolID = "360119206705" if StateAssignedSchID == "310400861171"
replace SchType = 1 if NCESSchoolID == "360119206705"
replace SchLevel = 1 if NCESSchoolID == "360119206705"
replace SchVirtual = 0 if NCESSchoolID == "360119206705"

replace NCESDistrictID = "3601221" if StateAssignedDistID == "321000861160"
replace DistType = "Charter agency" if NCESDistrictID == "3601221"
replace DistCharter = "Yes" if NCESDistrictID == "3601221"
replace DistLocale = "City, large" if NCESDistrictID == "3601221"
replace CountyName = "Bronx County" if NCESDistrictID == "3601221"
replace CountyCode = "36005" if NCESDistrictID == "3601221"
replace NCESSchoolID = "360122106719" if StateAssignedSchID == "321000861160"
replace SchType = 1 if NCESSchoolID == "360122106719"
replace SchLevel = 1 if NCESSchoolID == "360122106719"
replace SchVirtual = 0 if NCESSchoolID == "360122106719"

replace NCESDistrictID = "3601222" if StateAssignedDistID == "321000861161"
replace DistType = "Charter agency" if NCESDistrictID == "3601222"
replace DistCharter = "Yes" if NCESDistrictID == "3601222"
replace DistLocale = "City, large" if NCESDistrictID == "3601222"
replace CountyName = "Bronx County" if NCESDistrictID == "3601222"
replace CountyCode = "36005" if NCESDistrictID == "3601222"
replace NCESSchoolID = "360122206720" if StateAssignedSchID == "321000861161"
replace SchType = 1 if NCESSchoolID == "360122206720"
replace SchLevel = 1 if NCESSchoolID == "360122206720"
replace SchVirtual = 0 if NCESSchoolID == "360122206720"

replace NCESDistrictID = "3600991" if StateAssignedDistID == "331800860935"
replace DistType = "Charter agency" if NCESDistrictID == "3600991"
replace DistCharter = "Yes" if NCESDistrictID == "3600991"
replace DistLocale = "City, large" if NCESDistrictID == "3600991"
replace CountyName = "Kings County" if NCESDistrictID == "3600991"
replace CountyCode = "36047" if NCESDistrictID == "3600991"
replace NCESSchoolID = "360099106123" if StateAssignedSchID == "331800860935"
replace SchType = 1 if NCESSchoolID == "360099106123"
replace SchLevel = 1 if NCESSchoolID == "360099106123"
replace SchVirtual = 0 if NCESSchoolID == "360099106123"

replace NCESDistrictID = "3601085" if StateAssignedDistID == "310200861055"
replace DistType = "Charter agency" if NCESDistrictID == "3601085"
replace DistCharter = "Yes" if NCESDistrictID == "3601085"
replace DistLocale = "City, large" if NCESDistrictID == "3601085"
replace CountyName = "New York County" if NCESDistrictID == "3601085"
replace CountyCode = "36061" if NCESDistrictID == "3601085"
replace NCESSchoolID = "360108506376" if StateAssignedSchID == "310200861055"
replace SchType = 1 if NCESSchoolID == "360108506376"
replace SchLevel = 4 if NCESSchoolID == "360108506376"
replace SchVirtual = 0 if NCESSchoolID == "360108506376"

replace NCESDistrictID = "3601203" if StateAssignedDistID == "320900861151"
replace DistType = "Charter agency" if NCESDistrictID == "3601203"
replace DistCharter = "Yes" if NCESDistrictID == "3601203"
replace DistLocale = "City, large" if NCESDistrictID == "3601203"
replace CountyName = "Bronx County" if NCESDistrictID == "3601203"
replace CountyCode = "36005" if NCESDistrictID == "3601203"
replace NCESSchoolID = "360120306678" if StateAssignedSchID == "320900861151"
replace SchType = 1 if NCESSchoolID == "360120306678"
replace SchLevel = 4 if NCESSchoolID == "360120306678"
replace SchVirtual = 0 if NCESSchoolID == "360120306678"

replace NCESDistrictID = "3600061" if StateAssignedDistID == "310500860804"
replace DistType = "Charter agency" if NCESDistrictID == "3600061"
replace DistCharter = "Yes" if NCESDistrictID == "3600061"
replace DistLocale = "City, large" if NCESDistrictID == "3600061"
replace CountyName = "New York County" if NCESDistrictID == "3600061"
replace CountyCode = "36061" if NCESDistrictID == "3600061"
replace NCESSchoolID = "360006104438" if StateAssignedSchID == "310500860804"
replace SchType = 1 if NCESSchoolID == "360006104438"
replace SchLevel = 1 if NCESSchoolID == "360006104438"
replace SchVirtual = 0 if NCESSchoolID == "360006104438"

replace NCESSchoolID = "360007802919" if StateAssignedSchID == "310300011610"
replace SchType = 1 if NCESSchoolID == "360007802919"
replace SchLevel = 4 if NCESSchoolID == "360007802919"
replace SchVirtual = 0 if NCESSchoolID == "360007802919"

replace NCESSchoolID = "360008406771" if StateAssignedSchID == "320700010642"
replace SchType = 1 if NCESSchoolID == "360008406771"
replace SchLevel = 1 if NCESSchoolID == "360008406771"
replace SchVirtual = 0 if NCESSchoolID == "360008406771"

replace NCESSchoolID = "360009606775" if StateAssignedSchID == "331800010961"
replace SchType = 1 if NCESSchoolID == "360009606775"
replace SchLevel = 2 if NCESSchoolID == "360009606775"
replace SchVirtual = 0 if NCESSchoolID == "360009606775"

replace NCESSchoolID = "360010206776" if StateAssignedSchID == "343000010429"
replace SchType = 1 if NCESSchoolID == "360010206776"
replace SchLevel = 2 if NCESSchoolID == "360010206776"
replace SchVirtual = 0 if NCESSchoolID == "360010206776"

replace NCESSchoolID = "361598006768" if StateAssignedSchID == "170600010009"
replace SchType = 1 if NCESSchoolID == "361598006768"
replace SchLevel = 2 if NCESSchoolID == "361598006768"
replace SchVirtual = 0 if NCESSchoolID == "361598006768"

replace NCESSchoolID = "361623006767" if StateAssignedSchID == "142601030028"
replace SchType = 4 if NCESSchoolID == "361623006767"
replace SchLevel = 3 if NCESSchoolID == "361623006767"
replace SchVirtual = 0 if NCESSchoolID == "361623006767"

replace SchLevel = 1 if NCESSchoolID == "362874003902"
replace SchVirtual = 0 if NCESSchoolID == "362874003902"

/*
//Fixing 2023 Unmerged
tempfile temp1
save "`temp1'", replace
keep if missing(NCESSchoolID) & DataLevel ==3
tempfile tempunmerged
save "`tempunmerged'", replace
use "${NCES_School}/NCES_2022_School"
keep if State == "New York"
destring StateFips, replace
replace StateAssignedSchID = substr(StateAssignedSchID, -12,12)
merge 1:m StateAssignedSchID using "`tempunmerged'", update
drop if _merge ==1
save "`tempunmerged'", replace
use "`temp1'"
drop if missing(NCESSchoolID) & DataLevel ==3
append using "`tempunmerged'"
*/

//Dropping if No Students Tested
drop if StudentSubGroup_TotalTested == 0 & StudentSubGroup != "All Students"

//Standardizing Names
replace CountyName = proper(CountyName)
replace DistName = strtrim(DistName)
replace DistName = stritrim(DistName)
replace SchName = strtrim(SchName)
replace SchName = stritrim(SchName)

//Final Cleaning and dropping extra variables
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

*Exporting Output for 2024.
save "${Output}/NY_AssmtData_2024", replace
export delimited "${Output}/NY_AssmtData_2024", replace
*End of 2024.do
****************************************************
