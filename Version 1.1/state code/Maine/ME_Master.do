clear
set more off
set trace off
cd "/Volumes/T7/State Test Project/Maine"
global Output "/Volumes/T7/State Test Project/Maine/Output"
global NCES_School "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_District "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"

local dofiles ME_Cleaning_2015.do ME_Cleaning_2016-2019.do ME_Cleaning_2021-2022.do ME_Cleaning_2023.do

foreach file of local dofiles {
	do `file'
}
forvalues year = 2015/2022 {
	if `year' == 2020 continue
//Getting rid of private schools
use "${Output}/ME_AssmtData_`year'"
drop if (missing(NCESDistrictID) & DataLevel== 2 | (missing(NCESSchoolID) & DataLevel == 3 | missing(NCESDistrictID) & DataLevel == 3)) & (!inlist(SchName, "Beatrice Rafferty School", "Indian Island School", "Indian Township School", "MDOE School", "Ashley Bryan School", "Governor Baxter School for the Deaf") & !inlist(SchName, "Hudson Elementary School", "Jay Elementary School", "Livermore Elementary School", "Lura Libby School", "Morison Memorial School", "Oceanside High School East", "Oceanside High School West") & !inlist(SchName, "Rockland District Middle School", "SAD 70 Hodgdon High School") & !inlist(DistName, "ME Educational Ctr for the Deaf & Hard of Hearing"))

//Replacing missing NCES with Missing/not reported
label def virtualdf 16 "Missing/not reported", add
if `year' == 2015 {
	drop if SchName == "MDOE School" //All values suppressed/missing, not in NCES
}

if `year' == 2016 {
	replace DistType = "State-operated agency" if SchName == "Governor Baxter School for the Deaf"
	replace SchType = 2 if SchName == "Governor Baxter School for the Deaf"
	replace SchLevel = -2  if SchName == "Governor Baxter School for the Deaf"
	replace NCESDistrictID = "2300051" if SchName == "Governor Baxter School for the Deaf"
	replace NCESSchoolID = "230005100381" if SchName == "Governor Baxter School for the Deaf"
	replace DistCharter = "No" if SchName == "Governor Baxter School for the Deaf"
	replace CountyName = "Cumberland County" if SchName == "Governor Baxter School for the Deaf"
	replace CountyCode = "23005" if SchName == "Governor Baxter School for the Deaf"
	replace SchVirtual = 0 if SchName == "Governor Baxter School for the Deaf"
	replace DistLocale = "Rural, fringe" if SchName == "Governor Baxter School for the Deaf"
	
}




//Merging Unmerged for 2016
if `year' == 2016 {
gen StateAssignedSchID1 = StateAssignedDistID + "-" + StateAssignedSchID
tempfile temp1
save "`temp1'"

tempfile temp2
drop if (missing(NCESSchoolID) & DataLevel ==3) | (missing(NCESDistrictID) & DataLevel==2)
save "`temp2'"
clear


//Districts
use "`temp1'"
keep if DataLevel ==2
keep if (missing(NCESSchoolID) & DataLevel ==3) | (missing(NCESDistrictID) & DataLevel==2)
tempfile tempdist
save "`tempdist'", replace
clear
use "${NCES_District}/NCES_2016_District"
keep if state_name == "Maine" | state_location == "ME"
gen StateAssignedDistID = subinstr(state_leaid,"ME-","",.)
replace StateAssignedDistID = "1071" if ncesdistrictid == "2300051"
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge !=3
replace DistType = district_agency_type
replace NCESDistrictID = ncesdistrictid
replace CountyName = county_name 
replace CountyCode = county_code 
replace StateFips = 23
replace StateAbbrev = "ME"
save "`tempdist'", replace
clear

//Schools
use "`temp1'"
keep if DataLevel ==3
keep if (missing(NCESSchoolID) & DataLevel ==3) | (missing(NCESDistrictID) & DataLevel==2)
tempfile tempschool
save "`tempschool'"
clear
use "${NCES_School}/NCES_2016_School"
rename SchType school_type
keep if state_name == "Maine" | state_location == "ME"
gen StateAssignedSchID1 = seasch
replace StateAssignedSchID1 = "139-141" if strpos(school_name , "Ashley") !=0
replace StateAssignedSchID1 = "1071-1072" if ncesschoolid == "231484323197"
replace StateAssignedSchID1 = "936-941" if ncesschoolid == "231444000944"
replace StateAssignedSchID1 = "1498-233" if ncesschoolid == "231480500172"
replace StateAssignedSchID1 = "1498-750" if ncesschoolid == "231480500456"
replace StateAssignedSchID1 = "1452-836" if ncesschoolid == "231478700709"
replace StateAssignedSchID1 = "936-938" if ncesschoolid == "231444000718"
replace StateAssignedSchID1 = "1452-1454" if ncesschoolid == "231478723128"
replace StateAssignedSchID1 = "1452-1453" if ncesschoolid == "231478723127"
replace StateAssignedSchID1 = "1452-585" if ncesschoolid == "231478700414"
replace StateAssignedSchID1 = "957-959" if ncesschoolid == "231476200795"
merge 1:m StateAssignedSchID1 using "`tempschool'"
drop if _merge !=3
replace DistType = district_agency_type
replace SchType = school_type 
replace NCESDistrictID = ncesdistrictid
replace NCESSchoolID = ncesschoolid 
replace CountyName = county_name 
replace CountyCode = county_code 
replace StateFips = 23
replace StateAbbrev = "ME"
save "`tempschool'", replace
clear

//Appending to Merged data
use "`temp2'"
append using "`tempdist'" "`tempschool'"	
}


replace ProficientOrAbove_percent = ">0.95" if ProficientOrAbove_percent == ">95%"

//Fixing missing values for all years
foreach var of varlist Lev* Proficient* ParticipationRate StudentSubGroup_TotalTested {
	cap replace `var' = "*" if `var' == ""
}
replace SchVirtual = 16 if missing(SchVirtual) & DataLevel ==3

//Fixing Ranges
foreach var of varlist Lev*_percent ParticipationRate ProficientOrAbove_percent {
	cap replace `var' = subinstr(`var', "=","",.)
	cap replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
	cap replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
}

//Fixing Proficiency Levels and Criteria for Science 2022
if `year' == 2022 {
replace ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
replace AssmtName = "Maine Science Assessment" if Subject == "sci"
foreach n in 1 2 3 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*-)
	destring Lev`n'_count, gen(nLev`n'_count) i(*-)
}
gen nLev4_count =.
gen nLev4_percent=.
forvalues n = 3(-1)1 {
local next_n =`=`n'+1'
replace nLev`next_n'_percent = nLev`n'_percent if Subject == "sci"
replace nLev`next_n'_count = nLev`n'_count if Subject == "sci"	
}
//Calculating Lev1_percent for sci
replace nLev1_percent = 1-nLev4_percent-nLev3_percent-nLev2_percent if Subject == "sci"

//Reformatting and Correcting Data
tostring Lev4*, replace
replace Lev4_count = ""
replace Lev4_percent = ""

foreach n in 1 2 3 4 {
	replace Lev`n'_percent = string(nLev`n'_percent, "%9.3g") if Subject == "sci" & Lev`n'_percent != "*"
	replace Lev`n'_count = string(nLev`n'_count) if Subject == "sci" & Lev`n'_count != "*"
}
replace Lev4_count = "*" if Lev4_count == "."
replace Lev4_percent = "*" if Lev4_percent == "."
replace Lev1_count = "--" if Subject == "sci"


}

//Sci 2021
if `year' == 2021 {
	tostring Lev4*, replace
	replace Lev4_count = ""
	replace Lev4_percent = ""
	replace Lev4_count = "--" if Subject == "sci"
	replace Lev4_percent = "--" if Subject == "sci"
	replace ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
	
}

//DATA DECISION: GradeLevel == "GZ" because high school data is currently included
replace GradeLevel = "GZ"

//DATA DECISIONS SCI 2021/ 2022
if `year' == 2021 {
	drop if Subject == "sci"
	replace Flag_CutScoreChange_sci = "Not applicable"
}
if `year' == 2022 {
	replace Lev1_percent = "--" if Subject == "sci"
}


//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/ME_AssmtData_`year'", replace	
export delimited "${Output}/ME_AssmtData_`year'", replace 
	
clear	
}
