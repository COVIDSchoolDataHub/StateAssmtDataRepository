*******************************************************
* NEW MEXICO

* File name: 07_New Mexico 2022 Cleaning
* Last update: 2/20/2025

*******************************************************
* Description: This file cleans all New Mexico Original Data for 2022.

*******************************************************

clear
set more off

use "${raw}/NM_AssmtData_2022_all.dta", clear

drop nonParticipation*

//Reshaping
duplicates tag SchNumb DistCode, gen(tag)
list SchNumb if tag !=0
keep if tag ==0 | (MetPartMATH !=0 & tag !=0)
drop tag Met* Attenuation* Unattenuated* *Dir*


//Renaming to standardize
foreach var of varlist _all {
local label: variable label `var'
local newlabel = subinstr("`label'",".","",.)
local newlabel = subinstr("`newlabel'","ESSA_","",.)
local newlabel = lower("`newlabel'")
label var `var' `newlabel'
rename `var' `newlabel'
}


reshape long dproficient nproficient participation nparticipation dparticipation proficiency, i(schnumb distcode) j(Subject_SubGroup, string)

//Subgroup & Subject
replace Subject_SubGroup = subinstr(Subject_SubGroup, "math","mat",.)
replace Subject_SubGroup = subinstr(Subject_SubGroup, "science","sci",.)
gen Subject = substr(Subject_SubGroup, 1,3)
replace Subject = "math" if Subject == "mat"
forvalues n = 0/9 {
	replace Subject_SubGroup = subinstr(Subject_SubGroup,"`n'","",.)
}
gen StudentSubGroup = substr(Subject_SubGroup,4,10)
drop Subject_SubGroup dparticipation nparticipation

//Renaming
rename schnumb StateAssignedSchID
rename distcode StateAssignedDistID
rename proficiency ProficientOrAbove_percent
rename participation ParticipationRate
rename nproficient ProficientOrAbove_count
rename dproficient StudentSubGroup_TotalTested

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if StateAssignedDistID == 999
replace DataLevel = "District" if StateAssignedSchID == 1000* StateAssignedDistID
replace DataLevel = "School" if missing(DataLevel)
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel

//Fixing ID's
drop StateAssignedDistID //DistCodes are wrong for several observations at the school level (referred to Names Sch Dist sheet from data request)
tostring StateAssignedSchID, replace
gen StateAssignedDistID = StateAssignedSchID if DataLevel == 2
replace StateAssignedDistID = StateAssignedSchID if DataLevel !=1
replace StateAssignedDistID = substr(StateAssignedDistID, 1, strlen(StateAssignedDistID)-3) if DataLevel !=1
replace StateAssignedSchID = substr(StateAssignedSchID,-3,3)
replace StateAssignedSchID = "" if DataLevel !=3

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

//GradeLevel
gen GradeLevel = "GZ" //Using GZ as there is no GradeLevel specified, cannot determine if it's G38 or also includes high school

//Merging NCES
replace StateAssignedDistID = "00" + StateAssignedDistID if strlen(StateAssignedDistID) == 1
replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 2
gen State_leaid = "NM-" + StateAssignedDistID if DataLevel !=1
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == 3


//District
merge m:1 State_leaid using "$NCES/NCES_2021_District_NM.dta", keep(match master) nogen

//School
merge m:1 seasch using "$NCES/NCES_2021_School_NM.dta", keep(match master) 

//Cleaning Unmerged
** All Unmerged schools have no corresponding school in the Index sheet from the data request and have no corresponding school in NCES. Therefore dropping, as it's impossible to tell what schools these represent.
drop if _merge == 1 & DataLevel == 3 //1710 Observations, 30 unmerged "schools"
drop _merge

//Dropping as many high school observations as possible
drop if sch_lowest_grade_offered >=9 & !missing(sch_lowest_grade_offered)
drop sch_lowest_grade_offered

//StudentGroup_TotalTested with New Convention & Derivations of StudentSubGroup_TotalTested
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) force
egen UnsuppressedSG_TotalTested = total(nStudentSubGroup_TotalTested), by(DistName SchName Subject Grade StudentGroup)
gen AllStudents_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_TotalTested = AllStudents_TotalTested[_n-1] if missing(AllStudents_TotalTested)
gen StudentGroup_TotalTested = AllStudents_TotalTested
replace StudentSubGroup_TotalTested = string(real(AllStudents_TotalTested)-UnsuppressedSG_TotalTested) if regexm(StudentSubGroup_TotalTested, "[0-9]") == 0 & regexm(AllStudents_TotalTested, "[0-9]") !=0 & UnsuppressedSG_TotalTested !=0 & StudentGroup != "RaceEth"

//Indicator & empty variables
local level 1 2 3 4
foreach a of local level {
	gen Lev`a'_percent = "--"
	gen Lev`a'_count = "--"
}

gen Lev5_percent = ""
gen Lev5_count = ""

gen ProficiencyCriteria = "Levels 3-4"
gen AvgScaleScore = "--"
gen AssmtName = "NM-MSSA & Dynamic Learning Maps" if Subject != "sci"
replace AssmtName = "NM-ASR & Dynamic Learning Maps" if Subject == "sci"

**Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

gen SchYear = "2021-22"
gen AssmtType = "Regular and alt"

//Fixing State & District Level Observations
replace State = "New Mexico"
replace StateAbbrev = "NM"
replace StateFips = 35
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3

//Doña Ana County
replace CountyName = "Dona Ana County" if CountyCode == "35013"

//Post launch response
replace DistName = stritrim(DistName)
replace SchName = stritrim(SchName)

replace ProficientOrAbove_percent = "0" if strpos(ProficientOrAbove_percent, "e") !=0

** Deriving Count Ranges where possible
foreach count of varlist *_count {
	local percent = subinstr("`count'","count","percent",.)
	replace `count' = string(round(real(substr(`percent',1,strpos(`percent', "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(`percent',strpos(`percent', "-")+1,5))*real(StudentSubGroup_TotalTested))) if regexm(`percent', "[0-9]") !=0 & strpos(`percent', "-") !=0 & !missing(real(StudentSubGroup_TotalTested))
}

//Deriving Counts Where Possible
foreach count of varlist *_count {
local percent = subinstr("`count'", "count","percent",.)
replace `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if regexm(`count', "[0-9]") == 0 & regexm(`percent', "-") == 0 & regexm(`percent', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0
}

//Deriving Additional Values of StudentSubGroup_TotalTested
drop nStudentSubGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
gen missing_ssgtt = 1 if nStudentSubGroup_TotalTested == .
bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen missing_multiple = total(missing_ssgtt)
gen max = real(StudentGroup_TotalTested)
replace max = 0 if max == .

bysort StateAssignedDistID StateAssignedSchID AssmtType GradeLevel Subject: egen RaceEth = total(nStudentSubGroup_TotalTested) if StudentGroup == "RaceEth" & StudentSubGroup != "Hispanic or Latino"

replace StudentSubGroup_TotalTested = string(max - RaceEth) if StudentGroup == "RaceEth" & StudentSubGroup != "Hispanic or Latino" & max != 0 & nStudentSubGroup_TotalTested == . & RaceEth != 0 & missing_multiple == 1
drop RaceEth max missing_ssgtt missing_multiple nStudentSubGroup_TotalTested

drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"

//Derive ProficientOrAbove_percent given new derived ssg_tt
replace ProficientOrAbove_percent = string(real(ProficientOrAbove_count)/real(StudentSubGroup_TotalTested), "%9.3g") if !missing(real(ProficientOrAbove_count)) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(ProficientOrAbove_percent))

** Response to R1 3.2.25
replace StateAssignedSchID = StateAssignedDistID + StateAssignedSchID if DataLevel == 3

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/NM_AssmtData_2022", replace
export delimited "${output}/NM_AssmtData_2022", replace

* End of 07_New Mexico 2022 Cleaning



