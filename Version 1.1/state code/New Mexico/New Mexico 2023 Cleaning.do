clear
set more off

global raw "/Volumes/T7/State Test Project/New Mexico/Original Data Files"
global output "/Volumes/T7/State Test Project/New Mexico/Output"
global NCES "/Volumes/T7/State Test Project/New Mexico/NCES"

cd "/Volumes/T7/State Test Project/New Mexico"

//Importing, appending, reshaping
tempfile temp1
save "`temp1'", emptyok
foreach SUBJECT in ELA MATH SCIENCE {
	use "${raw}/NM_AssmtData_2023_`SUBJECT'"
	drop *Dir* *Any_*
	reshape long Participation Proficiency NProficient d, i(DistCode SchNumb approvedTestGrade) j(StudentSubGroup, string)
	gen Subject = "`SUBJECT'"
	replace StudentSubGroup = subinstr(StudentSubGroup, "`SUBJECT'","",.)
	forvalues n = 0/9 {
		replace StudentSubGroup = subinstr(StudentSubGroup, "`n'","",.)
	}
	append using "`temp1'"
	save "`temp1'", replace
}
use "`temp1'"

//Renaming
rename DistCode StateAssignedDistID
rename SchNumb StateAssignedSchID
rename approvedTestGrade GradeLevel
rename District DistName
rename School SchName
rename Proficiency ProficientOrAbove_percent
rename NProficient ProficientOrAbove_count
rename d StudentSubGroup_TotalTested
rename Participation ParticipationRate

//Fixing ID's 
tostring *Assigned*, replace
replace StateAssignedSchID = subinstr(StateAssignedSchID, StateAssignedDistID, "",1)
foreach var of varlist StateAssigned* {
	replace `var' = "00" + `var' if strlen(`var') == 1
	replace `var' = "0" + `var' if strlen(`var') == 2
}

//GradeLevel
drop if GradeLevel >8 | GradeLevel <3
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

//StudentSubGroup
replace StudentSubGroup = proper(StudentSubGroup)
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "El"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Frl"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multirace"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Notel"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Notfrl"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Swd"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Notswd"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//Fixing Counts/Percents
foreach var of varlist ProficientOrAbove_percent ParticipationRate {
replace `var' = subinstr(`var', "≥ ",">",.)
replace `var' = subinstr(`var', "≤ ", "<",.)
gen range`var' = substr(`var',1,1) if regexm(`var', "[<>]") !=0
replace range`var' = "0-" if range`var' == "<"
replace range`var' = "-1" if range`var' == ">"
replace `var' = subinstr(`var', ">","",.)
replace `var' = subinstr(`var', "<","",.)
replace `var' = string(real(`var')/100, "%9.3g") if !missing(range`var')
replace `var' = range`var' + `var' if range`var' == "0-"
replace `var' = `var' + range`var' if range`var' == "-1"
drop range`var'
}
foreach var of varlist ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate StudentSubGroup_TotalTested {
	replace `var' = "*" if strpos(`var', "*") !=0
	replace `var' = "--" if missing(`var') | `var' == " "
	replace `var' = string(real(`var'), "%9.3g") if regexm(`var', "[*-]") ==0
}

//Subject
replace Subject = lower(Subject)
replace Subject = "sci" if Subject == "science"

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if SchName == "Statewide"
replace DataLevel = "District" if missing(StateAssignedSchID)
replace DataLevel = "School" if !missing(StateAssignedSchID) & StateAssignedSchID != "999"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3

//Merging NCES
gen State_leaid = "NM-" + StateAssignedDistID if DataLevel !=1
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel ==3

merge m:1 State_leaid using "$NCES/NCES_2022_District.dta", keep(match master) nogen

merge m:1 seasch using "$NCES/NCES_2022_School.dta", keep(match master)

//StudentGroup_TotalTested with New Convention & Derivations of StudentSubGroup_TotalTested
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) force
egen UnsuppressedSG_TotalTested = total(nStudentSubGroup_TotalTested), by(DistName SchName Subject Grade StudentGroup)
gen AllStudents_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_TotalTested = AllStudents_TotalTested[_n-1] if missing(AllStudents_TotalTested)
gen StudentGroup_TotalTested = AllStudents_TotalTested
replace StudentSubGroup_TotalTested = string(real(AllStudents_TotalTested)-UnsuppressedSG_TotalTested) if regexm(StudentSubGroup_TotalTested, "[0-9]") == 0 & regexm(AllStudents_TotalTested, "[0-9]") !=0 & UnsuppressedSG_TotalTested !=0 & StudentGroup != "RaceEth"

//Indicator & empty variables
forvalues n = 1/5 {
	gen Lev`n'_count = "--"
	gen Lev`n'_percent = "--"
}

gen ProficiencyCriteria = "Levels 3-4"
gen AvgScaleScore = "--"
gen AssmtName = "NM-MSSA" if Subject != "sci"
replace AssmtName = "NM-ASR" if Subject == "sci"

**Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

gen SchYear = "2022-23"
gen AssmtType = "Regular and alt"

//Fixing State & District Level Observations
replace State = "New Mexico"
replace StateAbbrev = "NM"
replace StateFips = 35
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3

//Doña Ana County
replace CountyName = "Dona Ana County" if CountyCode == "35013"



//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/NM_AssmtData_2023", replace
export delimited "${output}/NM_AssmtData_2023", replace



