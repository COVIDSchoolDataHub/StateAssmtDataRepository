// Set up and import data for 2015 ela and math scores
clear
set more off

global raw "/Users/meganchen/Desktop/Research/Maryland"
import delimited "${raw}/MD_OriginalData_2015_ela_mat.csv", varnames(1) delimit(",") case(preserve) clear

save "/Users/meganchen/Desktop/Research/MD_2015_AssmtDataTemp.dta", replace

//import data for 2015 participation

import delimited "${raw}/PARCC_Participation_2015.csv", varnames(1) delimit(",") case(preserve) clear

merge 1:1 LEANumber SchoolNumber Assessment using "/Users/meganchen/Desktop/Research/MD_2015_AssmtDataTemp.dta", nogenerate

//reformat Subject and GradeLevel
split Assessment, p(" ")
keep if Assessment1 == "English/Language" || Assessment1 == "Mathematics"
replace Assessment4 = Assessment3 if Assessment4 == ""
replace Assessment4 = "G0" + Assessment4
rename Assessment1 Subject
rename Assessment4 GradeLevel
drop Assessment Assessment2 Assessment3 CreateDate 

//Rename proficiency levels
rename Level1DidnotyetmeetexpectationsP Level1_percent
rename Level2PartiallymetexpectationsPe Level2_percent
rename Level3ApproachedexpectationsPerc Level3_percent
rename Level4MetexpectationsPercent Level4_percent
rename Level5ExceededexpectationsPercen Level5_percent

rename Level1DidnotyetmeetexpectationsC Level1_count
rename Level2PartiallymetexpectationsCo Level2_count
rename Level3ApproachedexpectationsCoun Level3_count
rename Level4MetexpectationsCount Level4_count
rename Level5ExceededexpectationsCount Level5_count

save "/Users/meganchen/Desktop/Research/MD_2015_AssmtDataTemp.dta", replace

//Import data for 2015 science 
import delimited "${raw}/MSA_2015.csv", varnames(1) delimit(",") case(preserve) clear
rename AdvancedCount Level3_count
rename AdvancedPercent Level3_percent
rename ProficientCount Level2_count
rename ProficientPercent Level2_percent
rename BasicCount Level1_count
rename BasicPercent Level1_percent
drop TestType
rename Grade GradeLevel
split GradeLevel, p("")
replace GradeLevel = "G0" + GradeLevel2
drop GradeLevel1 GradeLevel2
append using "/Users/meganchen/Desktop/Research/MD_2015_AssmtDataTemp.dta"

//Rename and add missing variables
rename AcademicYear SchYear
rename LEANumber State_leaid
gen StateAssignedDistID = State_leaid
rename SchoolNumber StateAssignedSchID
rename LEAName DistrictName
rename SchoolName SchName
rename TestedCount StudentGroup_TotalTested
replace Subject = "ela" if Subject == "English/Language"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
gen CountyCode = ""

//Convert Level percents to decimals
local levels 1 2 3 4 5

foreach level of local levels {
	destring Level`level'_percent, generate(destrung_`level'_percent) force
	destring Level`level'_count, generate(destrung_`level'_count) force
	gen Level`level'Percent_Low = destrung_`level'_percent
	gen Level`level'Percent_High = destrung_`level'_percent
	replace Level`level'Percent_Low = 0 if Level`level'_percent == "<= 5.0"
	replace Level`level'Percent_High = 5 if Level`level'_percent == "<= 5.0"
	
	replace Level`level'_percent = "0-.05" if Level`level'_percent == "<= 5.0"
	replace destrung_`level'_percent = destrung_`level'_percent / 100
	tostring destrung_`level'_percent, replace force
	replace Level`level'_percent = destrung_`level'_percent if Level`level'_percent != "0-.05"
}
 
gen ProficientOrAbove_percent_low = (Level4Percent_Low + Level5Percent_Low) / 100 
gen ProficientOrAbove_percent_high = (Level4Percent_High + Level5Percent_High) / 100 if Subject == "ela" || Subject == "math"
replace ProficientOrAbove_percent_low = (Level2Percent_Low + Level3Percent_Low) / 100 if Subject == "sci"
replace ProficientOrAbove_percent_high = (Level2Percent_High + Level3Percent_High) / 100 if Subject == "sci"

egen ProficientOrAbove_percent = concat(ProficientOrAbove_percent_low ProficientOrAbove_percent_high), punct(-)
tostring ProficientOrAbove_percent_low, generate(ProficientOrAbove_percent_lows) format(%7.0g) force
replace ProficientOrAbove_percent = ProficientOrAbove_percent_lows if ProficientOrAbove_percent_low == ProficientOrAbove_percent_high

gen ProficientOrAbove_count = destrung_4_count + destrung_5_count if Subject == "ela" || Subject == "math"
replace ProficientOrAbove_count = destrung_2_count + destrung_3_count if Subject == "sci"
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if Level4_count == "*" || Level5_count == "*" 

drop destrung_1_percent destrung_1_count destrung_2_percent destrung_2_count destrung_3_percent destrung_3_count destrung_4_percent destrung_4_count destrung_5_percent destrung_5_count Level1Percent_Low Level1Percent_High Level2Percent_Low Level2Percent_High Level3Percent_Low Level3Percent_High Level4Percent_Low Level4Percent_High Level5Percent_Low Level5Percent_High ProficientOrAbove_percent_low ProficientOrAbove_percent_lows ProficientOrAbove_percent_high CreateDate

//Rename proficiency levels

rename Level1_count Lev1_count
rename Level2_count Lev2_count
rename Level3_count Lev3_count
rename Level4_count Lev4_count
rename Level5_count Lev5_count

rename Level1_percent Lev1_percent
rename Level2_percent Lev2_percent
rename Level3_percent Lev3_percent
rename Level4_percent Lev4_percent
rename Level5_percent Lev5_percent

//Generate remaining variables
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA= "N"
gen Flag_CutScoreChange_math= "N"
gen Flag_CutScoreChange_read= "--"
gen Flag_CutScoreChange_oth = "N"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "A"
replace StateAssignedSchID = "" if StateAssignedSchID == "A"
replace DataLevel = "State" if SchName == "All Maryland Schools"
gen DistType = "--"
gen AssmtName = "PARCC"
gen AssmtType = "Regular"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen seasch = StateAssignedDistID + StateAssignedSchID
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 4 and 5"


save "/Users/meganchen/Desktop/Research/MD_2015_AssmtData.dta", replace

//School merge

use "/Users/meganchen/Desktop/Research/Maryland/NCES_2014_School.dta", clear

keep state_location state_fips district_agency_type school_type ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code

keep if state_location == "MD"

drop if ncesdistrictid == ""

merge 1:m seasch using "/Users/meganchen/Desktop/Research/MD_2015_AssmtData.dta", keep(match using)
if _merge == 2 & DataLevel == "School" replace ncesschoolid = "Missing/not reported"
drop _merge

save "/Users/meganchen/Desktop/Research/MD_2015_AssmtData.dta", replace

// District Merge

use "/Users/meganchen/Desktop/Research/Maryland/NCES_2014_District.dta", clear

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code

keep if state_location == "MD"

drop if ncesdistrictid == ""
rename state_leaid State_leaid

merge 1:m State_leaid using "/Users/meganchen/Desktop/Research/MD_2015_AssmtData.dta", keep(match using) nogenerate

save "/Users/meganchen/Desktop/Research/MD_2015_AssmtData.dta", replace

//rename all NCES variables
drop state_leaid StudentCount ParticipationCount CountyCode DistType
rename state_location StateAbbrev 
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_code CountyCode
rename county_name CountyName
rename ncesschoolid NCESSchoolID
drop if GradeLevel == "G010"
//tostring SchLevel, replace force
//keep if SchLevel == "1" || SchLevel == "2"
//replace SchLevel = "Primary" if SchLevel == "1"
//replace SchLevel = "Middle" if SchLevel == "2"
rename ParticipationPercent ParticipationRate
gen State = "Maryland"
rename DistrictName DistName
rename school_type SchType
replace Lev4_percent = "" if Lev4_percent == "."
replace Lev5_percent = "" if Lev5_percent == "."
replace ProficientOrAbove_count = "" if ProficientOrAbove_count == "."

//Convert participation rate to decimals
destring ParticipationRate, generate(destrung_Participationpercent) force
gen ParticipationRate_Low = destrung_Participationpercent
gen ParticipationRate_High= destrung_Participationpercent
replace ParticipationRate_Low = .95 if ParticipationRate == ">= 95.0"
replace ParticipationRate_High = 1 if ParticipationRate == ">= 95.0"
	
replace ParticipationRate = ".95-1" if ParticipationRate == ">= 95.0"
replace destrung_Participationpercent = destrung_Participationpercent / 100
tostring destrung_Participationpercent, replace force
replace ParticipationRate = destrung_Participationpercent if ParticipationRate != ".95-1"
replace ParticipationRate = "" if ParticipationRate == "."
drop ParticipationRate_High ParticipationRate_Low destrung_Participationpercent
replace ProficiencyCriteria = "Levels 2 and 3" if Subject == "sci"
replace AssmtName = "MSA" if Subject == "sci"

// Relabelling Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n
drop DataLevel
rename DataLevel_n DataLevel

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1

replace SchName = "All Schools" if DataLevel == 2
replace seasch = "--" if DataLevel == 1 | DataLevel == 2
replace State_leaid = "--" if DataLevel == 1
replace StateAssignedDistID = "" if DataLevel == 1
tostring SchYear, replace
replace SchYear = "2014-15" if SchYear == "2015"
replace ParticipationRate = "--" if ParticipationRate == ""
replace ProficientOrAbove_count= "--" if ProficientOrAbove_count == ""
replace Lev5_percent= "--" if Lev5_percent == ""
replace Lev5_count= "--" if Lev5_count == ""
replace Lev4_percent= "--" if Lev4_percent == ""
replace Lev4_count= "--" if Lev4_count == ""
replace Lev3_percent= "--" if Lev3_percent == ""
replace Lev3_count= "--" if Lev3_count == ""
replace Lev2_percent= "--" if Lev2_percent == ""
replace Lev2_count= "--" if Lev2_count == ""
replace Lev1_percent= "--" if Lev1_percent == ""
replace Lev1_count= "--" if Lev1_count == ""
replace StateAbbrev = "MD" if StateAbbrev == ""
replace StateFips = 24 if StateFips == .






//label def hi "." "--"
//replace DistType = hi if DataLevel == "Sate"
//label define DistType 1 "Regular local school district" 5 "State-operated agency" 3 "--"
//encode DistType, gen(DistType_n) label(DistType)
//sort DistType_n
//drop DistType
//rename DistType_n DistType


//Replace missing variables with -- 
tostring DistType, force replace
replace DistType = "--" if DistType == "."
replace DistType = "Regular local school district" if DistType == "1"
replace DistType = "State-operated agency" if DistType == "5"

tostring SchType, force replace
replace SchType = "--" if SchType == "."
replace SchType= "Regular school" if SchType == "1"
replace SchType = "Special education school" if SchType == "2"
replace SchType = "Other/alternative school" if SchType =="4"

replace NCESDistrictID = "--" if NCESDistrictID == ""
replace StateAssignedDistID = "--" if StateAssignedDistID == ""
replace NCESSchoolID = "--" if NCESSchoolID == ""
replace StateAssignedSchID = "--" if StateAssignedSchID == ""

tostring CountyCode, force replace
replace CountyCode = "--" if CountyCode == "."

replace CountyName = "--" if CountyName == ""

replace DistCharter = "--" if DistCharter == ""

tostring SchVirtual, force replace
replace SchVirtual = "--" if SchVirtual == "."
replace SchVirtual = "No" if SchVirtual == "0"

tostring SchLevel, force replace
replace SchLevel = "--" if SchLevel == "."
replace SchLevel = "Primary" if SchLevel == "1"
replace SchLevel = "Middle" if SchLevel == "2"
replace SchLevel = "High" if SchLevel == "3"
replace SchLevel = "Other" if SchLevel == "3"







//tostring SchLevel, replace force
//keep if SchLevel == "1" || SchLevel == "2"
//replace SchLevel = "Primary" if SchLevel == "1"
//replace SchLevel = "Middle" if SchLevel == "2"
//replace SchLevel

//Put variables in correct order
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

save "/Users/meganchen/Desktop/Research/MD_2015_AssmtData.dta", replace




