cd "/Users/miramehta/Documents/"
global Original "/Users/miramehta/Documents/KY State Testing Data/Original Data Files"
global Output "/Users/miramehta/Documents/KY State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

//Clean 2022 EDFacts File

local FILES "SEA LEA SCH SCH_RaceEth SCH_Gender SCH_All"
foreach lev of local FILES {
	import delimited "$Original/edfacts2022_KY_`lev'.csv", clear
	gen DataLevel = "`lev'"
	tostring lea, replace
	tostring school, replace
	tostring characteristics, replace
	tostring programtype, replace
	tostring datagroup, replace
	tostring subgroup, replace
	save "$Original/edfacts2022_KY_`lev'.dta", replace
}

use "$Original/edfacts2022_KY_SEA.dta", replace
append using "$Original/edfacts2022_KY_LEA.dta" "$Original/edfacts2022_KY_SCH.dta" "$Original/edfacts2022_KY_SCH_RaceEth.dta" "$Original/edfacts2022_KY_SCH_Gender.dta" "$Original/edfacts2022_KY_SCH_All.dta"

replace DataLevel = "State" if DataLevel == "SEA"
replace DataLevel = "District" if DataLevel == "LEA"
replace DataLevel = "School" if strpos(DataLevel, "SCH") > 0

//Subject
rename academicsubject Subject
replace Subject = "ela" if Subject == "Reading/Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
drop if Subject == ""
drop if strpos(datadescription, "Performance on Pre- and Post-Tests") > 0

//StudentSubGroup
drop if population != "All Students"
replace subgroup = characteristics if inlist(subgroup, "", ".") & !inlist(characteristics, "", ".")
drop population characteristics datagroup

rename subgroup StudentSubGroup
drop if StudentSubGroup == "Asian/Pacific Islander" & DataLevel == "State"
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All Students") > 0
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "American Indian") > 0
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup, "Asian") > 0
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup, "Black") > 0
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster care students"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migratory students"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military connected"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Children with disabilities"
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Multicultural") > 0
replace StudentSubGroup = "White" if strpos(StudentSubGroup, "White") > 0

//GradeLevel
rename agegrade GradeLevel
drop if inlist(GradeLevel, "All Grades", "High School")
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0", 1)

//Final Cleaning
rename denominator StudentSubGroup_TotalTested
rename ncesleaid NCESDistrictID
rename ncesschid NCESSchoolID
tostring NCESDistrictID, replace
tostring NCESSchoolID, replace format ("%18.0f")
replace NCESDistrictID = "" if DataLevel == "State"
replace NCESSchoolID = "" if DataLevel != "School"

duplicates tag NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup, gen(tag)
drop if tag == 1 & outcome == ""

drop schoolyear state value programtype outcome datadescription lea school numerator

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

save "$Original/edfacts2022_ky_ssgtt.dta", replace

//Merge with 2022 & 2023 Data
forvalues year = 2022/2023{

use "${Output}/KY_AssmtData_`year'", clear
drop StudentGroup_TotalTested StudentSubGroup_TotalTested

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

// No level counts derived due to overrounding of percents

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/KY_AssmtData_`year'", replace
export delimited "${Output}/KY_AssmtData_`year'", replace

}
