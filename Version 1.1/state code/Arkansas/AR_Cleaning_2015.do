clear
set more off
set trace off
local Original "/Volumes/T7/State Test Project/Arkansas/Original Data"
local Output "/Volumes/T7/State Test Project/Arkansas/Output"
local NCES "/Volumes/T7/State Test Project/NCES"

//Importing
tempfile temp1
save "`temp1'", emptyok
clear
import excel "`Original'/AR_OriginalData_2015_School_ela_math.xlsx", firstrow case(lower)
append using "`temp1'"
save "`temp1'", replace
clear
import excel "`Original'/AR_OriginalData_2015_District_ela_math.xlsx", firstrow case(lower)
append using "`temp1'"
save "`temp1'", replace
clear
import excel "`Original'/AR_OriginalData_2015_State_ela_math.xlsx", firstrow case(lower)
append using "`temp1'"
save "`temp1'", replace
clear
import excel "`Original'/AR_OriginalData_2015_All_sci", sheet("Grade 5")
drop in 1/5
gen xtest = "Science Grade 05"
gen subject = "sci"
append using "`temp1'"
save "`temp1'", replace
clear
import excel "`Original'/AR_OriginalData_2015_All_sci", sheet("Grade 7")
drop in 1/5
gen xtest = "Science Grade 07"
gen subject = "sci"
append using "`temp1'"

save "`Original'/2015", replace



//Correcting sci variables
replace D = "All Districts" if A == "STATE TOTALS"
replace district_lea = subinstr(A, "-","",.) if subject == "sci"
replace school_lea = subinstr(B, "-","",.) if subject == "sci"
replace district_name = D if subject == "sci"
replace school_name = E if subject == "sci"
replace n_score = real(F) if subject == "sci"
rename G AvgScaleScore
replace p_level1 = H if subject == "sci"
replace p_level2 = I if subject == "sci"
replace p_level3 = J if subject == "sci"
replace p_level4 = K if subject == "sci"
drop A B C D E F H I J K
drop if subject == "sci" & n_score==.
replace AvgScaleScore = "--" if missing(AvgScaleScore)
replace subgroup = "All Students" if subject == "sci"

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if state_lea == "AR" | district_lea == "STATE TOTALS"
replace district_lea = "" if DataLevel == "State"
replace DataLevel = "District" if regexm(district_lea, "[0-9]") !=0 & regexm(school_lea, "[0-9]") ==0
replace DataLevel = "School" if regexm(district_lea, "[0-9]") !=0 & regexm(school_lea, "[0-9]") !=0
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Renaming / dropping vars
rename subject Subject
rename district_lea StateAssignedDistID
rename school_lea StateAssignedSchID
rename district_name DistName
rename school_name SchName
rename n_score StudentSubGroup_TotalTested
rename p_tested ParticipationRate
foreach n in 1 2 3 4 5 {
	rename p_level`n' Lev`n'_percent
}
rename subgroup StudentSubGroup 
drop state_lea state_name test n_all 
rename p_level45 ProficientOrAbove_percent

//GradeLevel
gen GradeLevel = "G" + substr(xtest, -2,2)
drop xtest
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//All Districts and All Schools
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3

//StudentSubGroup 
replace StudentSubGroup = "All Students" if StudentSubGroup == "Overall"
replace StudentSubGroup = "Economically Disadvantaged" if strpos(StudentSubGroup, "FRL:1Free/Reduced Lunch Price") !=0
replace StudentSubGroup = "Not Economically Disadvantaged" if strpos(StudentSubGroup, "FRL:0Not Free/Reduced Lunch Price") !=0
replace StudentSubGroup = "Male" if strpos(StudentSubGroup, "Male") !=0
replace StudentSubGroup = "Female" if strpos(StudentSubGroup, "Female") !=0
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP:1Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "LEP:0Not Limited English Proficient"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Race:"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Race:1Hispanic"
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "Alaska") !=0
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup, "Asian") !=0
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup, "African") !=0
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "White" if strpos(StudentSubGroup, "White") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two") !=0
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "Unknown"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Unknown"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino"

//Missing or suppressed data
foreach var of varlist _all {
	cap replace `var' = "*" if `var' == "n<10" | `var' == "xx"
}

//Proficiency Percents
foreach n in 1 2 3 4 5 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*%)
	replace Lev`n'_percent = string(nLev`n'_percent/100) if Lev`n'_percent != "*"
}
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*%)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100) if ProficientOrAbove_percent != "*"
replace ProficientOrAbove_percent = string((nLev3_percent + nLev4_percent)/100) if Subject == "sci"
replace ProficientOrAbove_percent = "*" if missing(ProficientOrAbove_percent)
replace Lev5_percent = "" if Subject == "sci"

//Subject
replace Subject = lower(Subject)

//ParticipationRate
replace ParticipationRate = "--" if Subject == "sci"
destring ParticipationRate, gen(nParticipationRate) i(-*%)
replace ParticipationRate = string(nParticipationRate/100) if ParticipationRate != "*" & ParticipationRate != "--"

//StudentGroup_TotalTested
sort StudentGroup
egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"

**Merging**
replace StateAssignedDistID = StateAssignedDistID + "000" if Subject == "sci" & DataLevel !=1
tempfile temp1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel == 2
replace StateAssignedDistID = "1702000" if DistName == "CEDARVILLE SCHOOL DISTRICT"
tempfile tempdist
save "`tempdist'", replace
clear
use "`NCES'/NCES_2014_District"
keep if state_name == 5 | state_location == "AR"
gen StateAssignedDistID = state_leaid
duplicates drop StateAssignedDistID, force
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge ==1
save "`tempdist'", replace
clear

//School 
use "`temp1'"
keep if DataLevel ==3
tempfile tempsch
save "`tempsch'", replace
clear
use "`NCES'/NCES_2014_School"
keep if state_name == 5 | state_location == "AR"
gen StateAssignedSchID = seasch
duplicates drop StateAssignedSchID, force
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge ==1
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
replace StateFips = 5
replace StateAbbrev = "AR"

//Generating additional variables
gen State = "Arkansas"
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_oth = "N"
gen Flag_CutScoreChange_read = ""
gen ProficiencyCriteria = "Levels 4 and 5"
replace ProficiencyCriteria = "Levels 3 and 4" if Subject == "sci"
gen AssmtType = "Regular"
gen AssmtName = "PARCC"
replace AssmtName = "Augmented Benchmark" if Subject == "sci"
gen SchYear = "2014-15"

//Missing variables

foreach n in 1 2 3 4 5 {
	gen Lev`n'_count = "--"
}
gen ProficientOrAbove_count = "--"
replace ProficientOrAbove_percent = "*" if Lev3_percent == "*" | Lev4_percent == "*"

//Fixing sci obs
replace Lev5_count = "" if Subject == "sci"
replace Lev5_percent = "" if Subject == "sci"

//Dropping if StudentSubGroup_TotalTested == 0
drop if StudentSubGroup_TotalTested == 0 

//Duplicate School and District observations for charter schools. Retaining school Level observations since District level is not classified in NCES 
drop if DataLevel ==2 & missing(NCESDistrictID)

//Cloverdale Aerospace Tech Charter / Cloverdale Middle School
replace SchName = "CLOVERDALE AEROSPACE TECH CHARTER" if NCESSchoolID == "050900001387"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/AR_AssmtData_2015", replace
export delimited "`Output'/AR_AssmtData_2015", replace
clear
