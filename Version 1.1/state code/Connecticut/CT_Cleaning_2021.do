clear
set more off
clear
set more off
set trace off
cap log close
cd "/Users/meghancornacchia/Desktop/DataRepository/Connecticut.nosync"
local Original "/Users/meghancornacchia/Desktop/DataRepository/Connecticut.nosync/Original_Data_Files"
local Output "/Users/meghancornacchia/Desktop/DataRepository/Connecticut.nosync/Output_Data_Files"
local NCES_School "/Users/meghancornacchia/Desktop/DataRepository/NCES_Data_Files"
local NCES_District "/Users/meghancornacchia/Desktop/DataRepository/NCES_Data_Files"


**** Need to install labutil for labelling to work properly. Type search labutil into Stata terminal and install first result. 

//Unhide Below code on first run
/*

tempfile temp1
save "`temp1'", emptyok
clear
import excel "`Original'/CT_OriginalData_2021_math_ela.xlsx", firstrow case(preserve) sheet(ALL)
append using "`temp1'"
save "`temp1'", replace
clear
import excel "`Original'/CT_OriginalData_2021_sci.xlsx", firstrow case(preserve) sheet(ALL)
gen SUBJECT = "sci"
append using "`temp1'"
save "`Original/CT_OriginalData_2021_all'", replace


*/

//Unhide above code on first run
clear
use "`Original/CT_OriginalData_2021_all'"

//Renaming Variables
rename DistrictCode StateAssignedDistID
rename District DistName
rename SchoolCode StateAssignedSchID
rename School SchName
drop OrganizationTypeCode
drop OrganizationTypeName
rename Grade GradeLevel
rename SubgroupCategory StudentGroup
rename Subgroup StudentSubGroup
drop NonParticipationRate
foreach n in 1 2 3 4 {
	rename PercentLevel`n' Lev`n'_percent
}
rename PercentProficient ProficientOrAbove_percent
rename AverageVSS AvgScaleScore
rename SUBJECT Subject

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if StateAssignedDistID == "0000000"
replace DataLevel = "District" if StateAssignedDistID != "0000000" & StateAssignedSchID == "0000000"
replace DataLevel = "School" if StateAssignedSchID != "0000000"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel !=3
replace DistName = "All Districts" if DataLevel ==1
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel !=3

//StudentSubGroup
replace StudentSubGroup = "Hispanic or Latino" if strpos(StudentSubGroup, "Hispanic") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two or More") !=0
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "Female" if StudentSubGroup == "F"
replace StudentSubGroup = "Male" if StudentSubGroup == "M"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Eligible for Free/Reduced Price Meals"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Eligible for Free/Reduced Price Meals"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Learners"
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "Military" if StudentGroup == "Military Family"
replace StudentSubGroup = "Non-Foster Care" if StudentGroup == "Not Foster Care"
replace StudentSubGroup = "Non-Military" if StudentGroup == "Not Military Family"
replace StudentSubGroup = "Non-Homeless" if StudentGroup == "Not Homeless"
replace StudentSubGroup = "SWD" if StudentGroup == "Students with Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentGroup == "Students without Disabilities"
replace StudentSubGroup = "Gender X" if StudentGroup == "N"
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "Foster Care" | StudentSubGroup == "Homeless" | StudentSubGroup == "Military" | StudentSubGroup == "Non-Foster Care" | StudentSubGroup == "Non-Military" | StudentSubGroup == "Non-Homeless" | StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD" | StudentSubGroup == "Gender X" 

//StudentGroup
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X" 
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//Subject
replace Subject = lower(Subject)

//Year
gen SchYear = "2020-21"

//GradeLevel
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//Making percents look reasonable
destring ParticipationRate, gen(nParticipationRate) i(*)
replace ParticipationRate = string(nParticipationRate, "%9.4g") if ParticipationRate != "*"
foreach n in 1 2 3 4 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*)
	replace Lev`n'_percent = string(nLev`n'_percent, "%9.4g") if Lev`n'_percent != "*"
}
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent, "%9.4g") if ProficientOrAbove_percent != "*"
replace AvgScaleScore = "--" if missing(AvgScaleScore)
foreach var of varlist _all {
	cap noisily replace `var' = "--" if `var' == "."
}

//Calculating suppressed values when possible
replace Lev4_percent = string((nProficientOrAbove_percent - nLev3_percent), "%9.4f") if missing(nLev4_percent) & !missing(nProficientOrAbove_percent) & !missing(nLev3_percent)
replace Lev3_percent = string((nProficientOrAbove_percent - nLev4_percent), "%9.4f") if missing(nLev3_percent) & !missing(nProficientOrAbove_percent) & !missing(nLev4_percent)

//Merging with NCES Data//
gen StateAssignedDistID2 = StateAssignedDistID
gen StateAssignedSchID2 = StateAssignedDistID + "-" + StateAssignedSchID
tempfile temp1
save "`temp1'", replace

//District
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'", replace
clear
use "`NCES_District'/NCES_2020_District"
keep if state_name == "Connecticut" | state_location == "CT"
gen StateAssignedDistID2 = subinstr(state_leaid,"CT-","",.)
merge 1:m StateAssignedDistID2 using "`tempdist'"
drop if _merge ==1
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel==3
tempfile tempschool
save "`tempschool'", replace
use "`NCES_School'/NCES_2020_School"
keep if state_name == "Connecticut" | state_location == "CT"
gen StateAssignedSchID2 = seasch 
merge 1:m StateAssignedSchID2 using "`tempschool'"
drop if _merge ==1
save "`tempschool'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempschool'"

//Fixing NCES Variables
rename district_agency_type DistTypeLabels
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type_num DistType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 9
replace StateAbbrev = "CT"

replace State_leaid = "CT-" + StateAssignedDistID if SchName == "Mill Academy" & missing(NCESSchoolID)
replace SchType = 4 if SchName == "Mill Academy" & missing(NCESSchoolID)
replace NCESDistrictID = "900070" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace NCESSchoolID = "90007001505" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if SchName == "Mill Academy" & missing(NCESSchoolID)
replace DistCharter = "No" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace DistType = 4 if SchName == "Mill Academy" & missing(NCESSchoolID)
replace SchLevel = -1 if SchName == "Mill Academy" & missing(NCESSchoolID)
replace SchVirtual = -1 if SchName == "Mill Academy" & missing(NCESSchoolID)
replace CountyName = "New Haven County" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace CountyCode = "9009" if SchName == "Mill Academy" & missing(NCESSchoolID)

replace DistTypeLabels = "Regular local school district" if SchName == "Coleytown Middle School"
replace State_leaid = "CT-" + StateAssignedDistID if SchName == "Coleytown Middle School" & missing(NCESSchoolID)
replace SchType = 1 if SchName == "Coleytown Middle School" & missing(NCESSchoolID)
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if SchName == "Coleytown Middle School" & missing(NCESSchoolID)
replace DistCharter = "No" if SchName == "Coleytown Middle School" & missing(NCESSchoolID)
replace DistType = 1 if SchName == "Coleytown Middle School" & missing(NCESSchoolID)
replace SchLevel = 2 if SchName == "Coleytown Middle School" & missing(NCESSchoolID)
replace SchVirtual = 0 if SchName == "Coleytown Middle School" & missing(NCESSchoolID)
replace CountyName = "Fairfield County" if SchName == "Coleytown Middle School" & missing(NCESSchoolID)
replace CountyCode = "9001" if SchName == "Coleytown Middle School" & missing(NCESSchoolID)
replace DistLocale = "Suburb, large" if SchName == "Coleytown Middle School" & missing(NCESSchoolID)
replace NCESDistrictID = "0905040" if SchName == "Coleytown Middle School" & missing(NCESSchoolID)
replace NCESSchoolID = "090504001052" if SchName == "Coleytown Middle School" & missing(NCESSchoolID)

replace State_leaid = "CT-2440014" if DistName == "Area Cooperative Educational Services"
replace NCESDistrictID = "0900070" if DistName == "Area Cooperative Educational Services"
replace DistCharter = "No" if DistName == "Area Cooperative Educational Services"
replace DistType = 9 if DistName == "Area Cooperative Educational Services"
replace CountyName = "New Haven County" if DistName == "Area Cooperative Educational Services"
replace CountyCode = "9009" if DistName == "Area Cooperative Educational Services"
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if _merge == 2

//Dropping Unmerged with no data available and unmerged bilingual
drop if [_merge==2] & [(Lev1_percent == "*" | Lev1_percent == "--" | Lev1_percent == "0")  & (Lev2_percent == "*" | Lev2_percent == "--" | Lev2_percent == "0") & (Lev3_percent == "*" | Lev3_percent == "--" | Lev3_percent == "0" ) & (Lev4_percent == "*" | Lev4_percent == "--" | Lev4_percent == "0") & (ProficientOrAbove_percent == "*" | ProficientOrAbove_percent == "--" | ProficientOrAbove_percent == "0")]
drop if (_merge==2) & strpos(SchName, "Bilingual") !=0

//Replacing NCES vars with Missing/not reported when applicable
label def agency_typedf -1 "Missing/not reported", add
replace DistType = -1 if missing(DistType) & DataLevel !=1
replace DistCharter = "Missing/not reported" if missing(DistCharter) & DataLevel !=1
replace SchType =-1 if missing(SchType) & DataLevel ==3
replace SchLevel = -1 if missing(SchLevel) & DataLevel ==3
replace CountyName = "Missing/not reported" if missing(CountyName) & DataLevel !=1
replace CountyCode = "Missing/not reported" if missing(CountyCode) & DataLevel !=1
replace SchVirtual = -1 if missing(SchVirtual) & DataLevel ==3
replace NCESDistrictID = "Missing/not reported" if missing(NCESDistrictID) & DataLevel !=1
replace NCESSchoolID = "Missing/not reported" if missing(NCESSchoolID) & DataLevel ==3
replace State_leaid = "Missing/not reported" if missing(State_leaid) & DataLevel !=1
replace seasch = "Missing/not reported" if missing(seasch) & DataLevel ==3

//Proficiency Criteria
gen ProficiencyCriteria = "Levels 3-4"

//AssmtName
gen AssmtName = "Smarter Balanced Assessment"
replace AssmtName = "NGSS Assessment" if Subject == "sci"

//State 
gen State = "Connecticut"

//AssmtType
gen AssmtType = "Regular"

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_sci = "Y"
gen Flag_CutScoreChange_soc = ""

//Missing/empty Variables
gen Lev5_count = ""
gen Lev5_percent= ""

foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
}

gen ProficientOrAbove_count = "--"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

//AvgScaleScore
replace AvgScaleScore = "--" if AvgScaleScore == "N/A"

//Dropping specific schools in response to R1
drop if StateAssignedSchID == "2449414" | StateAssignedSchID == "2440214"


// Apply DistType labels
labmask DistType, values(DistTypeLabels)

//Final Cleaning
recast str80 SchName
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/CT_AssmtData_2021", replace
export delimited "`Output'/CT_AssmtData_2021", replace

do CT_2021_EDFACTS


