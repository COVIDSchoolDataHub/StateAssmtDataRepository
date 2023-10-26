clear
set more off

global raw "/Users/meganchen/Desktop/Research/Maryland"
import delimited "${raw}/2022ela.csv", varnames(1) delimit(",") case(preserve) clear
save "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta", replace

import delimited "${raw}/2022math.csv", varnames(1) delimit(",") case(preserve) clear

drop if Assessment == "Algebra 1" || Assessment == "Geometry"

append using "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta"


save "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta", replace
 
import delimited "${raw}/2022sci.csv", varnames(1) delimit(",") case(preserve) clear

append using "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta"



save "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta", replace

split Assessment, p(" ")
keep if Assessment1 == "English/Language" || Assessment1 == "Mathematics" || Assessment1 == "Science"
replace Assessment4 = Assessment3 if Assessment4 == ""
replace Assessment4 = "G0" + Assessment4
rename Assessment1 Subject
rename Assessment4 GradeLevel
drop Assessment Assessment2 Assessment3 CreateDate 
//rename Studentgroup StudentGroup

replace Subject = "ela" if Subject == "English/Language"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

save "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta", replace

import delimited "${raw}/2022par.csv", varnames(1) delimit(",") case(preserve) clear
rename Assessment Subject
replace Subject = "ela" if Subject == "English/Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
keep Year LEA LEAName School SchoolName TotalParticipantPct StudentGroup Subject
drop if StudentGroup != "All Students"

merge 1:m LEA School Subject using  "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta",nogenerate


save "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta", replace

//Rename Variables 

rename Year SchYear
replace SchYear = "2021-22" if SchYear == "2022"
rename LEA State_leaid
gen StateAssignedDistID = State_leaid

rename School StateAssignedSchID

rename LEAName DistrictName
rename SchoolName SchName


gen Flag_AssmtNameChange = "N"
gen AssmtName = "MCAP"
gen Flag_CutScoreChange_ELA= "Y"
gen Flag_CutScoreChange_math= "Y"
gen Flag_CutScoreChange_read= "--"
gen Flag_CutScoreChange_oth = "N"
rename TestedCount StudentGroup_TotalTested
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "A"
replace StateAssignedSchID = "" if StateAssignedSchID == "A"
replace DataLevel = "State" if SchName == "All Maryland Schools"
gen DistType = ""
gen AssmtType = "Regular"
gen seasch = StateAssignedDistID + StateAssignedSchID



gen AvgScaleScore = ""
gen ProficiencyCriteria = "Levels 3 and 4"


save "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta", replace
//School merge

use "/Users/meganchen/Desktop/Research/Maryland/NCES_2021_School.dta", clear

keep state_location state_fips district_agency_type school_type ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code

keep if state_location == "MD"
drop if ncesdistrictid == ""
drop if state_fips == 11

replace state_leaid = substr((state_leaid), 4, .)
replace seasch = substr((seasch), 4, .)
rename state_leaid State_leaid


merge 1:m seasch using "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta", keep(match using)
if _merge == 2 & DataLevel == "School" replace ncesschoolid = "Missing/not reported"
drop _merge

save "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta", replace

// District Merge

use "/Users/meganchen/Desktop/Research/Maryland/NCES_2021_District.dta", clear

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code 

keep if state_location == "MD"

drop if ncesdistrictid == ""
replace state_leaid = substr((state_leaid), 4, .)
rename state_leaid State_leaid

merge 1:m State_leaid using "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta", keep(match using) nogenerate

save "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta", replace



//Rename Variables
rename state_location StateAbbrev 
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
drop DistType
rename district_agency_type DistType
rename county_name CountyName
rename ncesschoolid NCESSchoolID
//tostring SchLevel, replace force
//keep if SchLevel == "1" || SchLevel == "2"
//replace SchLevel = "Primary" if SchLevel == "1"
//replace SchLevel = "Middle" if SchLevel == "2"
rename TotalParticipantPct ParticipationRate
drop if GradeLevel == "G010"
gen State = "Maryland"
rename DistrictName DistName
rename school_type SchType
rename ProficientCount ProficientOrAbove_count
rename ProficientPct ProficientOrAbove_percent
replace ProficientOrAbove_count = "" if ProficientOrAbove_count == "."
rename county_code CountyCode
rename Level1Pct Level1_percent
rename Level2Pct Level2_percent
rename Level3Pct Level3_percent
rename Level4Pct Level4_percent
gen Level5_percent = ""
gen Level1_count = ""
gen Level2_count = ""
gen Level3_count = ""
gen Level4_count = ""
gen Level5_count = ""

gen StudentSubGroup = StudentGroup
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested




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

//Convert level percents to decimals
local levels 1 2 3 4 5

foreach level of local levels {
	destring Level`level'_percent, generate(destrung_`level'_percent) force
	//destring Level`level'_count, generate(destrung_`level'_count) force
	gen Level`level'Percent_Low = destrung_`level'_percent
	gen Level`level'Percent_High = destrung_`level'_percent
	replace Level`level'Percent_Low = 0 if Level`level'_percent == "<= 5.0"
	replace Level`level'Percent_High = 5 if Level`level'_percent == "<= 5.0"
	
	replace Level`level'_percent = "0-.05" if Level`level'_percent == "<= 5.0"
	replace destrung_`level'_percent = destrung_`level'_percent / 100
	tostring destrung_`level'_percent, replace force
	replace Level`level'_percent = destrung_`level'_percent if Level`level'_percent != "0-.05"
}


drop destrung_1_percent destrung_2_percent destrung_3_percent destrung_4_percent destrung_5_percent Level1Percent_Low Level1Percent_High Level2Percent_Low Level2Percent_High Level3Percent_Low Level3Percent_High Level4Percent_Low Level4Percent_High Level5Percent_Low Level5Percent_High 

rename Level1_percent Lev1_percent
rename Level2_percent Lev2_percent
rename Level3_percent Lev3_percent
rename Level4_percent Lev4_percent
rename Level5_percent Lev5_percent
replace Lev4_percent = ""
replace Lev5_percent = ""

rename Level1_count Lev1_count
rename Level2_count Lev2_count
rename Level3_count Lev3_count
rename Level4_count Lev4_count
rename Level5_count Lev5_count

//Convert ProficientOrAbove_percent to decimals
destring ProficientOrAbove_percent, generate(destrung_Proficientpercent) force
gen ProficientOrAbove_percent_Low = destrung_Proficientpercent
gen ProficientOrAbove_percent_High= destrung_Proficientpercent
replace ProficientOrAbove_percent_Low = 0 if ProficientOrAbove_percent == "<= 5.0"
replace ProficientOrAbove_percent_High = .05 if ProficientOrAbove_percent == "<= 5.0"
	
replace ProficientOrAbove_percent = "0-.05" if ProficientOrAbove_percent== "<= 5.0"
replace destrung_Proficientpercent = destrung_Proficientpercent / 100
tostring destrung_Proficientpercent, replace force
replace ProficientOrAbove_percent = destrung_Proficientpercent if ProficientOrAbove_percent != "0-.05"
replace ProficientOrAbove_percent = "" if ProficientOrAbove_percent == "."
drop ProficientOrAbove_percent_High ProficientOrAbove_percent_Low destrung_Proficientpercent
replace Lev1_percent = "" if Lev1_percent == "."

replace Lev2_percent = "" if Lev2_percent == "."
replace Lev3_percent = "" if Lev3_percent == "."


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
replace State_leaid = "" if DataLevel == 1
replace StateAssignedDistID = "" if DataLevel == 1

//Put variables in order
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth


tostring SchYear, replace
replace SchYear = "2022" if SchYear == "."
replace SchYear = "2021-22" if SchYear == "2022" || SchYear == "."
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
drop if StudentGroup != "All Students"

save "/Users/meganchen/Desktop/Research/MD_2022_AssmtDataTemp.dta", replace
