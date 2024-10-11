clear
set more off
global Original "/Users/miramehta/Documents/AL State Testing Data/Original Data Files"
global NCES_District "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES_School "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global Output "/Users/miramehta/Documents/AL State Testing Data/Output"

//Unhide code below on first run to convert to DTA format
/*
foreach Subject in ela mat sci {
	foreach lev in State County City Charter{
		import excel "${Original}/AL_OriginalData_2024_`Subject'", firstrow cellrange(A5) sheet("`lev'") case(preserve) clear
		tempfile temp`Subject'`lev'
		save "temp`Subject'`lev'", replace
		clear
	}
	use "temp`Subject'State"
	append using "temp`Subject'County" "temp`Subject'City" "temp`Subject'Charter"
	save "${Original}/AL_OriginalData_2024_`Subject'", replace
}
append using "$Original/AL_OriginalData_2024_ela.dta" "$Original/AL_OriginalData_2024_mat.dta"

save "${Original}/AL_OriginalData_2024", replace
*/

use "${Original}/AL_OriginalData_2024", clear

//Dropping SubGroups within SubGroups (i.e Gender = Male, Ethnicity = Hispanic , SubPopulation = Economically Disadvantaged)
gen NotAll = 0
replace NotAll = NotAll + 1 if strpos(Gender, "All") !=0
replace NotAll = NotAll + 1 if strpos(Race, "All") !=0
replace NotAll = NotAll + 1 if strpos(Ethnicity, "All") !=0
replace NotAll = NotAll + 1 if strpos(SubPopulation, "All") !=0
keep if NotAll >=3
gen StudentSubGroup = ""
replace StudentSubGroup = Gender if strpos(Gender, "All") ==0
replace StudentSubGroup = Race if strpos(Race, "All") ==0
replace StudentSubGroup = Ethnicity if strpos(Ethnicity, "All") ==0
replace StudentSubGroup = SubPopulation if strpos(SubPopulation, "All") ==0
replace StudentSubGroup = "All Students" if strpos(Gender, "All") !=0 & strpos(Race, "All") !=0 & strpos(Ethnicity, "All") !=0 & strpos(SubPopulation, "All") !=0
drop Race Gender Ethnicity SubPopulation

//Fixing StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "English Learner" if strpos(StudentSubGroup, "English") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two or more") !=0
replace StudentSubGroup = "SWD" if strpos(StudentSubGroup, "Students with Disabilities") != 0
replace StudentSubGroup = "Non-SWD" if strpos(StudentSubGroup, "General Education Students") != 0
replace StudentSubGroup = "Military" if strpos(StudentSubGroup, "Military Family") != 0
replace StudentSubGroup = "Foster Care" if strpos(StudentSubGroup, "Foster") != 0
replace StudentSubGroup = "Not Hispanic or Latino" if StudentSubGroup == "Other Ethnicity"
drop if StudentSubGroup ==  "Race Not Specified"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino" | StudentSubGroup == "Unknown"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"

//Standardizing other variable names
gen SchYear = "2023-24"
rename SystemName DistName
rename SystemCode StateAssignedDistID
rename SchoolName SchName
rename SchoolCode StateAssignedSchID
rename Grade GradeLevel
rename PercentProficient ProficientOrAbove_percent
forvalues n = 1/4{
	rename PercentLevel`n' Lev`n'_percent
}

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if StateAssignedDistID == "000" & StateAssignedSchID == "0000"
replace DataLevel = "District" if StateAssignedDistID != "000" & StateAssignedSchID == "0000"
replace DataLevel = "School" if StateAssignedDistID != "000" & StateAssignedSchID != "0000"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
order DataLevel
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

//Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

//GradeLevel
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//Merge in Student Counts from 2023 -- placeholder until 2024 counts become available, likely next year
replace DistName = stritrim(DistName)
replace DistName = strtrim(DistName)
replace SchName = stritrim(SchName)
replace SchName = strtrim(SchName)
merge 1:1 DistName SchName GradeLevel Subject StudentGroup StudentSubGroup using "${Output}/AL_AssmtData_2023", keepusing(StudentSubGroup_TotalTested)
drop if _merge == 2
gen flag = 1 if Lev1_percent == "*" & Lev2_percent == "*" & Lev3_percent == "*" & Lev4_percent == "*" & ProficientOrAbove_percent == "*" & _merge == 1
replace flag = 0 if flag == .

egen uniquegrp = group(DataLevel DistName SchName Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup
by uniquegrp: egen x = max(_merge)
by uniquegrp: egen y = min(flag)
gen z = x * y
drop if z == 1 & StudentSubGroup != "All Students"
drop x y z
replace StudentSubGroup_TotalTested = "--" if _merge == 1
drop _merge flag

//StudentGroup_TotalTested
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
gen StudentGroup_TotalTested = AllStudents_Tested
drop AllStudents_Tested

//ParticipationRate
destring ParticipationRate, gen(nParticipationRate) i(*)
replace ParticipationRate = string(nParticipationRate/100, "%9.4f")
replace ParticipationRate = "*" if ParticipationRate == "."	

//ProficientOrAbove_percent and Level percents
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*)

foreach n in 1 2 3 4 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*)
	replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.4f")
	replace Lev`n'_percent = "*" if Lev`n'_percent == "." 
	gen Lev`n'_count = string(round((nLev`n'_percent/100) * real(StudentSubGroup_TotalTested)))
	replace Lev`n'_count = "*" if Lev`n'_count == "." & Lev`n'_percent == "*"
	replace Lev`n'_count = "*" if Lev`n'_count == "." & StudentSubGroup_TotalTested == "*"
	replace Lev`n'_count = "--" if Lev`n'_count == "." & StudentSubGroup_TotalTested == "--"
}

replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100, "%9.4f")
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

gen ProficientOrAbove_count = string(round((nProficientOrAbove_percent/100) * real(StudentSubGroup_TotalTested)))
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & ProficientOrAbove_percent == "*"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & StudentSubGroup_TotalTested == "*"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & StudentSubGroup_TotalTested == "--"

//Merging with NCES Data//
replace StateAssignedSchID = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel ==3

tempfile temp1
save "`temp1'", replace

//District
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'", replace
clear
use "${NCES_District}/NCES_2022_District"
keep if state_fips_id == 1
gen StateAssignedDistID = subinstr(state_leaid,"AL-","",.)
drop year
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge ==1
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel==3
tempfile tempschool
save "`tempschool'", replace
use "${NCES_School}/NCES_2022_School"
keep if state_fips_id == 1
gen StateAssignedDistID = subinstr(state_leaid,"AL-","",.)
gen StateAssignedSchID = StateAssignedDistID + "-" + seasch if strpos(seasch,"-") ==0
replace StateAssignedSchID = seasch if strpos(seasch,"-") !=0
drop if StateAssignedSchID=="-"
replace SchVirtual = 0 if seasch == "026-0063" | seasch == "800-0015"
decode district_agency_type, gen(temp)
drop district_agency_type
rename temp district_agency_type
keep state_location state_fips district_agency_type school_type ncesdistrictid StateAssignedDistID ncesschoolid StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual county_name county_code
merge 1:m StateAssignedSchID using "`tempschool'"
drop if _merge ==1
save "`tempschool'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempschool'"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename ncesdistrictid NCESDistrictID
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
rename school_type SchType
replace StateFips = 1
replace StateAbbrev = "AL"

//Generating additional variables
gen State = "Alabama"
gen AvgScaleScore = "--"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen ProficiencyCriteria = "Levels 3-4"
gen Lev5_percent = ""
gen Lev5_count = ""
gen AssmtType = "Regular"
gen AssmtName = "ACAP"

//New Schools 2024
replace NCESSchoolID = "010054002665" if SchName == "EXCEL Academy"
replace NCESDistrictID = "0100540" if SchName == "EXCEL Academy"
replace DistType = "Regular local school district" if SchName == "EXCEL Academy"
replace DistCharter = "No" if SchName == "EXCEL Academy"
replace DistLocale = "Rural, fringe" if SchName == "EXCEL Academy"
replace CountyName = "Covington County" if SchName == "EXCEL Academy"
replace CountyCode = "1039" if SchName == "EXCEL Academy"
replace SchType = 1 if SchName == "EXCEL Academy"
replace SchLevel = 4 if SchName == "EXCEL Academy"
replace SchVirtual = 1 if SchName == "EXCEL Academy"
replace NCESSchoolID = "010177002668" if SchName == "Rehobeth Primary School"
replace NCESDistrictID = "0101770" if SchName == "Rehobeth Primary School"
replace DistType = "Regular local school district" if SchName == "Rehobeth Primary School"
replace DistCharter = "No" if SchName == "Rehobeth Primary School"
replace DistLocale = "Rural, fringe" if SchName == "Rehobeth Primary School"
replace CountyName = "Houston County" if SchName == "Rehobeth Primary School"
replace CountyCode = "1069" if SchName == "Rehobeth Primary School"
replace SchType = 1 if SchName == "Rehobeth Primary School"
replace SchLevel = 1 if SchName == "Rehobeth Primary School"
replace SchVirtual = 0 if SchName == "Rehobeth Primary School"

replace SchVirtual = 0 if NCESSchoolID == "010358302559"
replace SchVirtual = 0 if NCESSchoolID == "010258002556"
replace SchVirtual = 0 if NCESSchoolID == "010000802522"

//Final Formatting (Suppression)
gen flag = 1 if !inlist(StudentSubGroup_TotalTested, "*", "--") & inlist(Lev1_percent, "*", "0.000") & inlist(Lev2_percent, "*", "0.000") & inlist(Lev3_percent, "*", "0.000") & inlist(Lev4_percent, "*" "0.000")
forvalues n = 1/4{
	replace Lev`n'_percent = "*" if flag == 1
}
replace ProficientOrAbove_percent = "*" if flag == 1
drop flag

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/AL_AssmtData_2024", replace
export delimited "${Output}/AL_AssmtData_2024", replace
