clear
set more off

global output "/Users/maggie/Desktop/Nevada/Output"
global NCES "/Users/maggie/Desktop/Nevada/NCES/Cleaned"

cd "/Users/maggie/Desktop/Nevada"

use "${output}/NV_AssmtData_2023_ela.dta", clear

rename Year SchYear
rename *NumberTested StudentSubGroup_TotalTested
rename ReadingTested ParticipationRate
rename *Proficient ProficientOrAbove_percent
rename *EmergentDeveloping Lev1_percent
rename *ApproachesStandard Lev2_percent
rename *MeetsStandard Lev3_percent
rename *ExceedsStandard Lev4_percent

gen Subject = "ela"

save "${output}/NV_AssmtData_2023_elaappend.dta", replace

use "${output}/NV_AssmtData_2023_math.dta", clear

rename Year SchYear
rename *NumberTested StudentSubGroup_TotalTested
rename MathematicsTested ParticipationRate
rename *Proficient ProficientOrAbove_percent
rename *EmergentDeveloping Lev1_percent
rename *ApproachesStandard Lev2_percent
rename *MeetsStandard Lev3_percent
rename *ExceedsStandard Lev4_percent

gen Subject = "math"

save "${output}/NV_AssmtData_2023_mathappend.dta", replace

use "${output}/NV_AssmtData_2023_sci.dta", clear

rename Year SchYear
rename *NumberTested StudentSubGroup_TotalTested
rename ScienceTested ParticipationRate
rename *Proficient ProficientOrAbove_percent
rename *EmergentDeveloping Lev1_percent
rename *ApproachesStandard Lev2_percent
rename *MeetsStandard Lev3_percent
rename *ExceedsStandard Lev4_percent

gen Subject = "sci"

append using "${output}/NV_AssmtData_2023_elaappend.dta"
append using "${output}/NV_AssmtData_2023_mathappend.dta"

** Dropping extra variables

drop EligibleforCRTELAMath EligibleforCRTScience ELANotTested MathematicsNotTested ScienceNotTested

** Replacing variables

replace SchYear = "2022-23"

** Generating new variables

gen SchName = Group
replace SchName = SchName[_n-1] if OrganizationCode[_n-1] == OrganizationCode[_n]

tostring OrganizationCode, gen(StateAssignedSchID)
replace StateAssignedSchID = "0" + StateAssignedSchID if (OrganizationCode < 10000 & OrganizationCode > 100) | OrganizationCode < 10
replace StateAssignedSchID = StateAssignedSchID + "000" if OrganizationCode < 100

sort StateAssignedSchID

gen DistName = SchName
gen StateAssignedDistID = StateAssignedSchID
replace StateAssignedDistID = substr(StateAssignedSchID, 1, 2)
replace DistName = DistName[_n-1] if StateAssignedDistID[_n-1] == StateAssignedDistID[_n]

replace SchName = "All Schools" if OrganizationCode < 99
replace DistName = "All Districts" if OrganizationCode == 0

gen DataLevel = "School"
replace DataLevel = "District" if SchName == "All Schools"
replace DataLevel = "State" if DistName == "All Districts"

replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
drop OrganizationCode

gen StudentGroup = "All Students"
replace StudentGroup = "Gender" if inlist(Group, "Female", "Male", "Unknown")
replace StudentGroup = "RaceEth" if inlist(Group, "Am In/AK Native", "Black", "Hispanic", "White", "Two or More Races", "Asian", "Pacific Islander")
replace StudentGroup = "EL Status" if inlist(Group, "EL", "Not EL")
replace StudentGroup = "Economic Status" if inlist(Group, "FRL", "Not FRL")

gen StudentSubGroup = "All Students"
replace StudentSubGroup = "Female" if Group == "Female"
replace StudentSubGroup = "Male" if Group == "Male"
replace StudentSubGroup = "Unknown" if Group == "Unknown"
replace StudentSubGroup = "American Indian or Alaska Native" if Group == "Am In/AK Native"
replace StudentSubGroup = "Black or African American" if Group == "Black"
replace StudentSubGroup = "Hispanic or Latino" if Group == "Hispanic"
replace StudentSubGroup = "White" if Group == "White"
replace StudentSubGroup = "Two or More" if Group == "Two or More Races"
replace StudentSubGroup = "Asian" if Group == "Asian"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if Group == "Pacific Islander"
replace StudentSubGroup = "English Learner" if Group == "EL"
replace StudentSubGroup = "English Proficient" if Group == "Not EL"
replace StudentSubGroup = "Economically Disadvantaged" if Group == "FRL"
replace StudentSubGroup = "Not Economically Disadvantaged" if Group == "Not FRL"

gen GradeLevel = "G38"
replace GradeLevel = Group if inlist(Group, "Grade 3", "Grade 4", "Grade 5", "Grade 6", "Grade 7", "Grade 8")
replace GradeLevel = "G0" + subinstr(GradeLevel, "Grade ", "", .) if GradeLevel != "G38"
drop Group

gen AssmtName = "SBAC"
replace AssmtName = "Science" if Subject == "sci"
gen AssmtType = "Regular"

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort DistName SchName StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "-"

local level 1 2 3 4
foreach a of local level{
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"

gen ProficientOrAbove_count = "--"

gen AvgScaleScore = "--"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Converting Data to Decimals

local level 1 2 3 4

foreach a of local level {
	gen Lev`a'_percent2 = Lev`a'_percent
	replace Lev`a'_percent2 = subinstr(Lev`a'_percent2,"<","",.)	
	replace Lev`a'_percent2 = subinstr(Lev`a'_percent2,">","",.)
	destring Lev`a'_percent2, replace force
	replace Lev`a'_percent2 = Lev`a'_percent2/100
	tostring Lev`a'_percent2, replace force
	replace Lev`a'_percent = Lev`a'_percent2 if strpos(Lev`a'_percent, "<") == 0 & strpos(Lev`a'_percent, ">") == 0
	replace Lev`a'_percent = "0-0.05" if strpos(Lev`a'_percent, "<") > 0
	replace Lev`a'_percent = "0.95-1" if strpos(Lev`a'_percent, ">") > 0
	replace Lev`a'_percent = "*" if Lev`a'_percent2 == "."
	drop Lev`a'_percent2
	}
	
local var ProficientOrAbove_percent ParticipationRate

foreach a of local var {
	gen test = ""
	replace test = "less" if strpos(`a', "<") > 0
	replace test = "greater" if strpos(`a', ">") > 0
	destring `a', replace force
	replace `a' = `a'/100
	tostring `a', replace force
	replace `a' = "0-0.05" if test == "less"
	replace `a' = "0.95-1" if test == "greater"
	replace `a' = "*" if `a' == "."
	drop test
}

** Merging with NCES

gen State_leaid = "NV-" + StateAssignedDistID
replace State_leaid = "" if DataLevel == 1

replace State_leaid = "NV-18" if substr(StateAssignedSchID, 6, 1) != ""
replace StateAssignedDistID = "18" if substr(StateAssignedSchID, 6, 1) != ""
replace DistName = "State Public Charter School Authority" if substr(StateAssignedSchID, 6, 1) != ""

replace State_leaid = "NV-19" if SchName == "Davidson Academy"
replace StateAssignedDistID = "19" if SchName == "Davidson Academy"
replace DistName = "University" if SchName == "Davidson Academy"

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta"

replace State_leaid = "NV-18" if _merge == 1 & DataLevel != 1
replace StateAssignedDistID = "18" if _merge == 1 & DataLevel != 1
replace DistName = "State Public Charter School Authority" if _merge == 1 & DataLevel != 1

drop if _merge == 2
drop _merge

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta", update

drop if _merge == 2
drop _merge

gen seasch = StateAssignedDistID + "-" + StateAssignedSchID
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCES}/NCES_2021_School.dta"

drop if _merge == 2
drop _merge

**** Including 2023 schools

replace SchType = 1 if SchName == "Battle Born Academy"
replace NCESSchoolID = "320000100975" if SchName == "Battle Born Academy"

replace SchType = 1 if SchName == "Pinecrest Academy Virtual"
replace NCESSchoolID = "320000100976" if SchName == "Pinecrest Academy Virtual"

replace SchType = 1 if SchName == "Sage Collegiate Public Charter School"
replace NCESSchoolID = "320000100971" if SchName == "Sage Collegiate Public Charter School"

replace SchType = 1 if SchName == "Young Women's Leadership Academy of Las Vegas"
replace NCESSchoolID = "320000100972" if SchName == "Young Women's Leadership Academy of Las Vegas"

replace SchType = 1 if SchName == "pilotED Cactus Park"
replace NCESSchoolID = "320000100973" if SchName == "pilotED Cactus Park"

replace SchLevel = -1 if SchName == "Battle Born Academy" | SchName == "Pinecrest Academy Virtual" | SchName == "Sage Collegiate Public Charter School" | SchName == "Young Women's Leadership Academy of Las Vegas" | SchName == "pilotED Cactus Park"
replace SchVirtual = -1 if SchName == "Battle Born Academy" | SchName == "Pinecrest Academy Virtual" | SchName == "Sage Collegiate Public Charter School" | SchName == "Young Women's Leadership Academy of Las Vegas" | SchName == "pilotED Cactus Park" | SchName == "Coral Academy Cadence"
label def SchLevel -1 "Missing/not reported"
label def SchVirtual -1 "Missing/not reported"

**

replace StateAbbrev = "NV" if DataLevel == 1
replace State = 32 if DataLevel == 1
replace StateFips = 32 if DataLevel == 1

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/NV_AssmtData_2023.dta", replace

export delimited using "${output}/csv/NV_AssmtData_2023.csv", replace
