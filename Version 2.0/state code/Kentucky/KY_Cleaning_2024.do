global Original "/Users/miramehta/Documents/KY State Testing Data/Original Data Files"
global Output "/Users/miramehta/Documents/KY State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

import delimited "$Original/KY_OriginalData_2024_all", clear

//Variable Names
rename districtname DistName
rename schoolname SchName
rename grade GradeLevel
rename subject Subject
rename demographic StudentSubGroup
rename novice Lev1_percent
rename apprentice Lev2_percent
rename proficient Lev3_percent
rename distinguished Lev4_percent
rename proficientdistinguished ProficientOrAbove_percent
drop schoolclassification

//DataLevel
gen DataLevel = "School"
replace DataLevel = "District" if SchName == ""
replace DataLevel = "State" if DistName == "State"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//State & District Names & IDs
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3
replace DistName = strtrim(DistName)
replace DistName = stritrim(DistName)
replace SchName = strtrim(SchName)
replace SchName = stritrim(SchName)

rename schoolcode StateAssignedSchID
gen StateAssignedDistID = StateAssignedSchID if DataLevel == 2
sort DistName DataLevel
replace StateAssignedDistID = StateAssignedDistID[_n-1] if DistName == DistName[_n-1] & StateAssignedDistID == .
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
replace StateAssignedDistID = "00" + StateAssignedDistID if strlen(StateAssignedDistID) == 1
replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 2
replace StateAssignedSchID = "00" + StateAssignedSchID if strlen(StateAssignedSchID) == 4
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 5

//GradeLevel & Subject
tostring GradeLevel, replace
drop if inlist(GradeLevel, "10", "11")
replace GradeLevel = "G0" + GradeLevel

replace Subject = "ela" if Subject == "Reading"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"
drop if inlist(Subject, "Editing and Mechanic", "On Demand Writing")

//StudentSubGroup & StudentGroup
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "English Learner including Monitored"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Learner"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Dependent"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Non-Military Dependent"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without IEP"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Economically Disadvantaged"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities (IEP)"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"
replace StudentSubGroup = "White" if StudentSubGroup == "White (Non-Hispanic)"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient", "EL and Monit or Recently Ex")
replace StudentGroup = "Foster Care Status" if inlist(StudentSubGroup, "Foster Care", "Non-Foster Care")
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
replace StudentGroup = "Homeless Enrolled Status" if inlist(StudentSubGroup, "Homeless", "Non-Homeless")
replace StudentGroup = "Military Connected Status" if inlist(StudentSubGroup, "Military", "Non-Military")
replace StudentGroup = "Migrant Status" if inlist(StudentSubGroup, "Migrant", "Non-Migrant")
replace StudentGroup = "RaceEth" if inlist(StudentSubGroup, "American Indian or Alaska Native", "Asian", "Black or African American", "Hispanic or Latino", "Two or More", "White")
drop if StudentGroup == ""

//Performance Information
foreach var of varlist *_percent{
	local lev = subinstr("`var'", "percent", "count", 1)
	gen `lev' = "--"
	replace `var' = `var'/100
	tostring `var', replace format("%9.2f") force
	replace `var' = "*" if `var' == "." & suppressed == "Y"
	replace `var' = "--" if `var' == "."
}
drop suppressed

gen ProficiencyCriteria = "Levels 3-4"
gen Lev5_count = ""
gen Lev5_percent = ""
gen ParticipationRate = "--"
gen AvgScaleScore = "--"

//Assessment Information
gen SchYear = "2023-24"
gen AssmtName = "Kentucky Summative Assessment"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"

//Merge with NCES
tempfile temp1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist 
save "`tempdist'", replace
clear
use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District"
keep if state_location == "KY" | state_fips_id == 21
gen StateAssignedDistID = subinstr(state_leaid, "KY-","",.)
replace StateAssignedDistID = substr(StateAssignedDistID, 4,3)
*Can update this portion of the code when updated NCES info is available
replace StateAssignedDistID = "901" if lea_name == "Central Kentucky Educational Cooperative"
replace StateAssignedDistID = "902" if lea_name == "Green River Regional Educational Cooperative"
replace StateAssignedDistID = "903" if lea_name == "Kentucky Educational Development Corporation"
replace StateAssignedDistID = "904" if lea_name == "Kentucky Valley Educational Corporation"
replace StateAssignedDistID = "905" if lea_name == "Northern Kentucky Cooperative for Educational Services"
replace StateAssignedDistID = "906" if lea_name == "Ohio Valley Educational Cooperative"
replace StateAssignedDistID = "907" if lea_name == "Southeast/Southcentral Education Cooperative"
replace StateAssignedDistID = "908" if lea_name == "West Kentucky Educational Cooperative"
duplicates drop StateAssignedDistID, force
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge == 1
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear
use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_2022_School"
keep if state_location == "KY" | state_fips_id == 21
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1,10)
replace StateAssignedSchID = substr(StateAssignedSchID, 4,6)
duplicates drop StateAssignedSchID, force
decode district_agency_type, gen(district_agency_type1)
drop district_agency_type
rename district_agency_type1 district_agency_type
rename school_type SchType
keep State state_location state_fips ncesdistrictid ncesschoolid state_leaid district_agency_type county_name county_code DistLocale DistCharter school_name SchType SchVirtual SchLevel StateAssignedSchID lea_name
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge == 1
drop _merge
save "`tempsch'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"
	
//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 21
replace StateAbbrev = "KY"
gen State = "Kentucky"

//New Schools 2024
replace NCESSchoolID = "210129002566" if StateAssignedSchID == "132035"
replace SchType = 1 if NCESSchoolID == "210129002566"
replace SchLevel = 4 if NCESSchoolID == "210129002566"
replace SchVirtual = 1 if NCESSchoolID == "210129002566"
replace NCESDistrictID = "2101290" if NCESSchoolID == "210129002566"
replace DistType = "Regular local school district" if NCESSchoolID == "210129002566"
replace DistCharter = "No" if NCESSchoolID == "210129002566"
replace DistLocale = "Rural, distant" if NCESSchoolID == "210129002566"
replace CountyName = "Breckinridge County" if NCESSchoolID == "210129002566"
replace CountyCode = "21027" if NCESSchoolID == "210129002566"

replace NCESSchoolID = "210249002569" if StateAssignedSchID == "231035"
replace SchType = 1 if NCESSchoolID == "210249002569"
replace SchLevel = 4 if NCESSchoolID == "210249002569"
replace SchVirtual = 1 if NCESSchoolID == "210249002569"
replace NCESDistrictID = "2102490" if NCESSchoolID == "210249002569"
replace DistType = "Regular local school district" if NCESSchoolID == "210249002569"
replace DistCharter = "No" if NCESSchoolID == "210249002569"
replace DistLocale = "Suburb, small" if NCESSchoolID == "210249002569"
replace CountyName = "Hardin County" if NCESSchoolID == "210249002569"
replace CountyCode = "21093" if NCESSchoolID == "210249002569"

replace NCESSchoolID = "210299002570" if StateAssignedSchID == "275255"
replace SchType = 1 if NCESSchoolID == "210299002570"
replace SchLevel = 2 if NCESSchoolID == "210299002570"
replace SchVirtual = 0 if NCESSchoolID == "210299002570"
replace NCESDistrictID = "2102990" if NCESSchoolID == "210299002570"
replace DistType = "Regular local school district" if NCESSchoolID == "210299002570"
replace DistCharter = "No" if NCESSchoolID == "210299002570"
replace DistLocale = "City, large" if NCESSchoolID == "210299002570"
replace CountyName = "Jefferson County" if NCESSchoolID == "210299002570"
replace CountyCode = "21111" if NCESSchoolID == "210299002570"

replace NCESSchoolID = "210299002573" if StateAssignedSchID == "275406"
replace SchType = 1 if NCESSchoolID == "210299002573"
replace SchLevel = 2 if NCESSchoolID == "210299002573"
replace SchVirtual = 0 if NCESSchoolID == "210299002573"
replace NCESDistrictID = "2102990" if NCESSchoolID == "210299002573"
replace DistType = "Regular local school district" if NCESSchoolID == "210299002573"
replace DistCharter = "No" if NCESSchoolID == "210299002573"
replace DistLocale = "City, large" if NCESSchoolID == "210299002573"
replace CountyName = "Jefferson County" if NCESSchoolID == "210299002573"
replace CountyCode = "21111" if NCESSchoolID == "210299002573"

replace NCESSchoolID = "210429002578" if StateAssignedSchID == "441020"
replace SchType = 4 if NCESSchoolID == "210429002578"
replace SchLevel = 4 if NCESSchoolID == "210429002578"
replace SchVirtual = 0 if NCESSchoolID == "210429002578"
replace NCESDistrictID = "2104290" if NCESSchoolID == "210429002578"
replace DistType = "Regular local school district" if NCESSchoolID == "210429002578"
replace DistCharter = "No" if NCESSchoolID == "210429002578"
replace DistLocale = "Rural, remote" if NCESSchoolID == "210429002578"
replace CountyName = "Morgan County" if NCESSchoolID == "210429002578"
replace CountyCode = "21175" if NCESSchoolID == "210429002578"

replace NCESSchoolID = "210441002579" if StateAssignedSchID == "451015"
replace SchType = 4 if NCESSchoolID == "210441002579"
replace SchLevel = 4 if NCESSchoolID == "210441002579"
replace SchVirtual = 0 if NCESSchoolID == "210441002579"
replace NCESDistrictID = "2104410" if NCESSchoolID == "210441002579"
replace DistType = "Regular local school district" if NCESSchoolID == "210441002579"
replace DistCharter = "No" if NCESSchoolID == "210441002579"
replace DistLocale = "Rural, fringe" if NCESSchoolID == "210441002579"
replace CountyName = "Nelson County" if NCESSchoolID == "210441002579"
replace CountyCode = "21179" if NCESSchoolID == "210441002579"

replace NCESSchoolID = "210555002581" if StateAssignedSchID == "551025"
replace SchType = 4 if NCESSchoolID == "210555002581"
replace SchLevel = 4 if NCESSchoolID == "210555002581"
replace SchVirtual = 0 if NCESSchoolID == "210555002581"
replace NCESDistrictID = "2105550" if NCESSchoolID == "210555002581"
replace DistType = "Regular local school district" if NCESSchoolID == "210555002581"
replace DistCharter = "No" if NCESSchoolID == "210555002581"
replace DistLocale = "Rural, distant" if NCESSchoolID == "210555002581"
replace CountyName = "Todd County" if NCESSchoolID == "210555002581"
replace CountyCode = "21219" if NCESSchoolID == "210555002581"

drop if NCESSchoolID == "" & DataLevel == 3 //these are two schools (in the Model Laboratory district) that don't exist in the NCES record + the dist level observations have the same exact information
drop if NCESDistrictID == "" & DataLevel == 2 //one district that doesn't have any available NCES information yet -- may remove this once update NCES info is available
drop _merge

//Student Counts
merge 1:1 DataLevel NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup using "$Original/edfacts2022_ky_ssgtt.dta"
drop if _merge == 2
drop _merge

sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"

bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested)
gen max = StudentGroup_TotalTested
replace max = 0 if max == .

bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen RaceEth = total(StudentSubGroup_TotalTested) if StudentGroup == "RaceEth"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Econ = total(StudentSubGroup_TotalTested) if StudentGroup == "Economic Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen EL = total(StudentSubGroup_TotalTested) if StudentGroup == "EL Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Gender = total(StudentSubGroup_TotalTested) if StudentGroup == "Gender"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Migrant = total(StudentSubGroup_TotalTested) if StudentGroup == "Migrant Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Homeless = total(StudentSubGroup_TotalTested) if StudentGroup == "Homeless Enrolled Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Military = total(StudentSubGroup_TotalTested) if StudentGroup == "Military Connected Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Foster = total(StudentSubGroup_TotalTested) if StudentGroup == "Foster Care Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Disability = total(StudentSubGroup_TotalTested) if StudentGroup == "Disability Status"

replace StudentSubGroup_TotalTested = max - RaceEth if StudentGroup == "RaceEth" & max != 0 & StudentSubGroup_TotalTested == . & RaceEth != 0
replace StudentSubGroup_TotalTested = max - Econ if StudentGroup == "Economic Status" & max != 0 & StudentSubGroup_TotalTested == . & Econ != 0
replace StudentSubGroup_TotalTested = max - EL if StudentSubGroup == "English Proficient" & max != 0 & StudentSubGroup_TotalTested == . & EL != 0
replace StudentSubGroup_TotalTested = max - Gender if StudentGroup == "Gender" & max != 0 & StudentSubGroup_TotalTested == . & Gender != 0
replace StudentSubGroup_TotalTested = max - Migrant if StudentGroup == "Migrant Status" & max != 0 & StudentSubGroup_TotalTested == . & Migrant != 0
replace StudentSubGroup_TotalTested = max - Homeless if StudentGroup == "Homeless Enrolled Status" & max != 0 & StudentSubGroup_TotalTested == . & Homeless != 0
replace StudentSubGroup_TotalTested = max - Military if StudentGroup == "Military Connected Status" & max != 0 & StudentSubGroup_TotalTested == . & Military != 0
replace StudentSubGroup_TotalTested = max - Foster if StudentGroup == "Foster Care Status" & max != 0 & StudentSubGroup_TotalTested == . & Foster != 0
replace StudentSubGroup_TotalTested = max - Disability if StudentGroup == "Disability Status" & max != 0 & StudentSubGroup_TotalTested == . & Disability != 0
drop RaceEth Econ EL Gender Migrant Homeless Military Foster Disability

tostring StudentSubGroup_TotalTested, replace
tostring StudentGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."
replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == "."
drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"

//Final Cleaning
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/KY_AssmtData_2024", replace
export delimited "${Output}/KY_AssmtData_2024", replace
