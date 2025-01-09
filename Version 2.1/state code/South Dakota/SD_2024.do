clear
set more off


global Original "/Volumes/T7/State Test Project/South Dakota/Original Data"
global Output "/Volumes/T7/State Test Project/South Dakota/Output"
global NCES_District "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_School "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global Stata_versions "/Volumes/T7/State Test Project/South Dakota/Stata .dta versions"

//Importing (hide after first run)

// import excel "$Original/SD_OriginalData_2024.xlsx", firstrow case(preserve) clear allstring
// save "$Original/SD_OriginalData_2024", replace

//Hide above code after first run
use "$Original/SD_OriginalData_2024", clear

// Renaming
rename Entity_Level DataLevel
cap drop School_Level
drop Academic_Year
rename Grades GradeLevel
rename Subgroup StudentSubGroup
drop Subgroup_Code
rename Asmt_Type AssmtType
drop Accommodations
rename Nbr_Students_Tested StudentSubGroup_TotalTested
rename Pct_Students_Tested ParticipationRate
rename Nbr_Proficient_or_Advanced ProficientOrAbove_count
*rename Pct_Proficient_or_Advanced ProficientOrAbove_percent
rename Nbr_Students_Below_Basic Lev1_count
*rename Pct_Students_Below_Basic Lev1_percent
rename Nbr_Students_Basic Lev2_count
*rename Pct_Students_Basic Lev2_percent
rename Nbr_Students_Proficient Lev3_count
*rename Pct_Students_Proficient Lev3_percent
rename Nbr_Students_Advanced Lev4_count
*rename Pct_Students_Advanced Lev4_percent

** Percent variables have a denominator of enrollment, rather than tested, so the percents add to ParticipationRate rather than 100%. Deriving percents based on counts instead.

drop *FAY*
drop Nbr_Students_Not_Tested
drop Nbr* Pct* Total_Students

//AssmtType
drop if AssmtType == "Alt"
replace AssmtType = "Regular"

// DataLevel
gen DistName = Entity_Name if DataLevel == "District"
gen SchName = Entity_Name if DataLevel == "School"
gen StateAssignedDistID = Entity_ID if DataLevel == "District"
gen StateAssignedSchID = Entity_ID if DataLevel == "School"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3
drop Entity_Name Entity_ID
order DistName SchName StateAssignedDistID StateAssignedSchID

//GradeLevel
replace GradeLevel = "G38" if GradeLevel == "All Grades"
replace GradeLevel = "G0" + GradeLevel if GradeLevel != "G38"

//Subject
replace Subject = "math" if Subject == "Math"
replace Subject = "ela" if Subject == "Reading"
replace Subject = "sci" if Subject == "Science"

//StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners (EL)"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more Races"
replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "NON-EL"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NON-Economically Disadvantaged"
replace StudentSubGroup = "LTEL" if StudentSubGroup == "Long Term EL"
drop if StudentSubGroup == "SPED EL"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "NON Students with Disabilities"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex" | StudentSubGroup == "EL Exited" | StudentSubGroup == "EL and Monit or Recently Ex" | StudentSubGroup == "Ever EL" | StudentSubGroup == "LTEL"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

// Proficiency Percent Levels
foreach count of varlist *count {
	local percent = subinstr("`count'", "count", "percent",.)
	gen `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.4g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested))
	replace `percent' = "*" if `count' == "*"
	replace `percent' = "--" if missing(`percent')
}

//ParticipationRate
replace ParticipationRate = string(real(ParticipationRate)/100, "%9.4g") if !missing(real(ParticipationRate))
replace ParticipationRate = "*" if missing(real(ParticipationRate))

//NCES Merging
replace StateAssignedDistID = string(real(StateAssignedDistID),"%05.0f") if DataLevel == 2
replace StateAssignedSchID = string(real(StateAssignedSchID), "%07.0f") if DataLevel == 3
tempfile temp1
save "`temp1'", replace
clear



// District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace

use "$NCES_District/NCES_2022_District"
keep if state_fips_id == 46 | state_name == "South Dakota"
gen StateAssignedDistID = subinstr(state_leaid, "SD-","",.)
merge 1:m StateAssignedDistID using "`tempdist'"

drop if _merge == 1
drop year
save "`tempdist'", replace

clear

// School
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear

use "$NCES_School/NCES_2022_School"
keep if state_fips_id == 46 | state_name == "South Dakota"
gen StateAssignedSchID = subinstr(seasch, "-","",.)
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge == 1
drop year 
decode district_agency_type, generate(district_agency_type1) 
drop district_agency_type
rename district_agency_type1 district_agency_type
drop boundary_change_indicator
drop number_of_schools 
drop fips

save "`tempsch'", replace




//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 46
replace StateAbbrev = "SD"
replace SchVirtual = -1 if missing(SchVirtual) & DataLevel ==3

//Fixing StateAssignedDistID & StateAssignedSchID for Schools
replace StateAssignedDistID = subinstr(State_leaid, "SD-","",.) if DataLevel == 3
replace DistName = lea_name if DataLevel == 3
replace DistName = lea_name if DistName == "NULL"

//Indicator Variables
gen State = "South Dakota"
replace StateFips = 46
replace StateAbbrev = "SD"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N" 
gen Flag_CutScoreChange_soc = "Not applicable"

gen AssmtName = ""
replace AssmtName = "SBAC" if Subject != "sci"
replace AssmtName = "SDSA 2.0" if Subject == "sci"

gen ProficiencyCriteria = "Levels 3-4"

gen SchYear = "2023-24"

//Missing variables
gen Lev5_count = ""
gen Lev5_percent = ""
gen AvgScaleScore = "--"

//StudentGroup_TotalTested
cap drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Deriving StudentSubGroup_TotalTested where possible
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName GradeLevel Subject)
gen missing_SSG = 1 if missing(real(StudentSubGroup_TotalTested))
egen missing_multiple = total(missing_SSG), by(StudentGroup DistName SchName GradeLevel Subject)

order StudentGroup_TotalTested UnsuppressedSG StudentSubGroup_TotalTested UnsuppressedSSG missing_multiple

gen Derivable = 1 if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0 & !missing(real(StudentGroup_TotalTested)-UnsuppressedSG) & StudentSubGroup != "All Students"

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if Derivable == 1

drop Unsuppressed* missing_* Derivable

//Level percent (and corresponding count) derivations if we have all other percents
replace Lev1_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent))

replace Lev2_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent))

replace Lev3_percent = string(1-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))

replace Lev4_percent = string(1-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))

foreach percent of varlist Lev*_percent {
	replace `percent' = "0" if real(`percent') <  0.005 & !missing(real(`percent'))
}

replace ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent)) if !missing(real(Lev3_percent)) & !missing(real(Lev4_percent)) & missing(real(ProficientOrAbove_percent))

foreach count of varlist Lev*_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}

//Misc Fixes
drop if missing(DistName)
replace StateAssignedSchID = substr(StateAssignedSchID,1,5) + "-" + substr(StateAssignedSchID,-2,2) if DataLevel == 3
replace DistName = subinstr(DistName, "School District ", "",.)
replace ProficientOrAbove_percent = "1" if real(ProficientOrAbove_percent) > 1 & !missing(real(ProficientOrAbove_percent))
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev3_count)) & !missing(real(Lev4_count))

//Missing/not reported values for SchLevel & SchVirtual in 2024 (Reference table in drive, SD_2024_Updates)
replace SchLevel = 2 if NCESSchoolID == "461695000320"
replace SchLevel = 2 if NCESSchoolID == "463135010809"
replace SchLevel = 2 if NCESSchoolID == "465175010812"
replace SchLevel = 1 if NCESSchoolID == "468044710806"
replace SchLevel = 1 if NCESSchoolID == "468044710804"
replace SchLevel = 2 if NCESSchoolID == "468044710805"
replace SchLevel = 1 if NCESSchoolID == "468044710807"
replace SchLevel = 1 if NCESSchoolID == "464494010811"
replace SchVirtual = 0 if NCESSchoolID == "461695000320"
replace SchVirtual = 0 if NCESSchoolID == "463135010809"
replace SchVirtual = 0 if NCESSchoolID == "465175010812"
replace SchVirtual = 0 if NCESSchoolID == "468044710806"
replace SchVirtual = 0 if NCESSchoolID == "468044710804"
replace SchVirtual = 0 if NCESSchoolID == "468044710805"
replace SchVirtual = 0 if NCESSchoolID == "468044710807"
replace SchVirtual = 0 if NCESSchoolID == "464494010811"

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Output/SD_AssmtData_2024", replace
export delimited "$Output/SD_AssmtData_2024", replace






