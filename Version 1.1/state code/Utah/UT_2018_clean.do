clear
set more off

global raw "/Users/miramehta/Documents/UT State Testing Data/Original Data"
global output "/Users/miramehta/Documents/UT State Testing Data/Output"
global int "/Users/miramehta/Documents/UT State Testing Data/Intermediate"

global nces "/Users/miramehta/Documents/NCES District and School Demographics"
global utah "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

global edfacts "/Users/miramehta/Documents/EdFacts"


*** UT School ***

* Proficiency levels

import excel "${raw}/UT_OriginalData_2018_all.xlsx", sheet("School") firstrow allstring clear

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename SchoolYear SchYear
rename Subject GradeLevel
rename SubjectArea Subject
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent
rename LEADistrictorCharter DistName
rename School SchName

save "${int}/UT_2018_school.dta", replace 

import excel "${raw}/UT_OriginalData_2018_proficiency.xlsx", sheet("School Results by Test") firstrow allstring clear 

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename SchoolYear SchYear
rename LEADistrictorCharter DistName
rename SchoolName SchName 
rename Subject GradeLevel 
rename SubjectArea Subject
rename PercentProficient ProficientOrAbove_percent

merge 1:1 SchName DistName Subject GradeLevel using "${int}/UT_2018_school.dta"

drop _merge

gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

replace SchName=strproper(SchName)
replace DistName=strproper(DistName)

replace SchName="The Center for Creativity Innovation and Discovery" if strpos(SchName, "Innovation")>0
replace DistName="The Center for Creativity Innovation and Discovery" if strpos(DistName, "Innovation")>0

save "${int}/UT_2018_school.dta", replace

* Subgroups
import excel "${raw}/UT_OriginalData_2018_subgroup.xlsx", sheet("SchoolByTestAndDemographic") firstrow allstring clear

drop AllStudents

foreach i of varlist AfAmBlack AmericanIndian Asian HispanicLatino MultipleRaces PacificIslander White LowIncome StudentswDisabilities EnglishLearners {
	rename `i' subgroup`i'
}

reshape long subgroup, i(Test LEAName SchoolName) j(StudentSubGroup) string

rename subgroup ProficientOrAbove_percent

foreach x of numlist 3/8 {
	replace Test="G0`x'" if strpos(Test, "`x'")>0
}

drop if inlist(Test, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename Test GradeLevel
rename SchoolYear SchYear
rename LEAName DistName
rename SchoolName SchName

save "${int}/UT_2018_subgroup_school.dta", replace 

append using "${int}/UT_2018_school.dta"

replace SchName="Goldminers Daughter" if strpos(SchName, "Goldminer")>0
replace SchName="Kays Creek Elementary" if strpos(SchName, "Kay's")>0
replace SchName="TseBiiNidzisgai School" if strpos(SchName, "Tse'Bii")>0
replace SchName="Laverkin School" if strpos(SchName, "La Verkin")>0

replace SchName="Minersville School (Middle)" if SchName=="Minersville School" & (GradeLevel=="G03" | GradeLevel=="G04" | GradeLevel=="G05")
replace SchName="Minersville School (Primary)" if SchName=="Minersville School" & (GradeLevel=="G06" | GradeLevel=="G07" | GradeLevel=="G08")
replace SchName="Canyon View School (Middle)" if SchName=="Canyon View School" & inlist(GradeLevel, "GO6", "G07", "G08")
replace SchName="Canyon View School (Primary)" if SchName=="Canyon View School" & inlist(GradeLevel, "G03", "G04", "G05")
replace SchName = strproper(SchName)
replace DistName = strproper(DistName)
replace DistName="American Preparatory Academy - Lea" if DistName=="American Preparatory Academy"
replace DistName="Thomas Edison - Lea" if DistName == "Thomas Edison"
replace SchName="Kays Creek Elementary" if strpos(SchName, "Kay'S")>0
replace SchName=subinstr(SchName, ",", "", 1) if strpos(SchName, "The Center For Creativity, Innovation") > 0
replace DistName=subinstr(DistName, ",", "", 1) if strpos(DistName, "The Center For Creativity, Innovation") > 0

merge m:1 SchName DistName using "${utah}/NCES_2018_School.dta"

replace NCESSchoolID = "490066001431" if SchName == "North Sanpete Special Purpose School"
replace seasch = "20801" if SchName == "North Sanpete Special Purpose School"

gen DataLevel=3

drop if _merge==2

destring NCESDistrictID, replace
destring NCESSchoolID, replace

drop _merge 

decode SchVirtual, gen(SchVirtual_s)
drop SchVirtual
rename SchVirtual_s SchVirtual

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen(SchType_s)
drop SchType
rename SchType_s SchType

replace SchName = strproper(SchName)

merge m:1 SchName DistName SchYear using "${raw}/UT_unmerged_schools.dta", update

gen StateAssignedDistID = State_leaid
replace StateAssignedSchID = seasch

drop if _merge==2
drop _merge

** Prep to Merge with EdFacts
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

format NCESSchoolID %12.0f
tostring NCESSchoolID, replace usedisplayformat
tostring NCESDistrictID, replace

gen StudentSubGroup_TotalTested = "--"
gen ParticipationRate = "--"

replace StudentSubGroup="All Students" if StudentSubGroup=="AllStudents"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="AfAmBlack"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="AmericanIndian"
replace StudentSubGroup="English Learner" if StudentSubGroup=="EnglishLearners"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="LowIncome"
replace StudentSubGroup="Two or More" if StudentSubGroup=="MultipleRaces"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="HispanicLatino"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="PacificIslander"
replace StudentSubGroup="SWD" if StudentSubGroup=="StudentswDisabilities"

replace StudentGroup="RaceEth" if StudentGroup == ""
replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged"
replace StudentGroup="Disability Status" if StudentSubGroup=="SWD"

*** Merge EdFacts Data
merge m:1 DataLevel NCESSchoolID StudentSubGroup GradeLevel Subject using "${edfacts}/2018/edfactscount2018schoolutah.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
gen Count_n = Count if DataLevel == 3 & _merge == 3
drop if _merge == 2
drop Count stnam schnam _merge

merge m:1 DataLevel NCESSchoolID StudentSubGroup GradeLevel Subject using "${edfacts}/2018/edfactspart2018schoolutah.dta"
replace ParticipationRate = Participation if _merge == 3 & Participation != ""
drop if _merge == 2
drop stnam _merge

save "${int}/UT_2018_school.dta", replace

*** UT Districts ***

* Proficiency levels
import excel "${raw}/UT_OriginalData_2018_all.xlsx", sheet("LEA") firstrow allstring clear

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

drop I J

rename SchoolYear SchYear
rename Subject GradeLevel
rename SubjectArea Subject
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent
rename LEADistrictorCharter DistName


save "${int}/UT_2018_district.dta", replace 

import excel "${raw}/UT_OriginalData_2018_proficiency.xlsx", sheet("LEA Results by Test") firstrow allstring clear 

gen Subject1=""
replace Subject1="English Language Arts" if strpos(Subject, "Language Arts")>0
replace Subject1="Mathematics" if strpos(Subject, "Math")>0
replace Subject1="Science" if strpos(Subject, "Science")>0

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename SchoolYear SchYear
rename LEADistrictorCharter DistName
rename Subject GradeLevel 
rename Subject1 Subject
rename PercentProficient ProficientOrAbove_percent

merge 1:1 DistName Subject GradeLevel using "${int}/UT_2018_district.dta"

drop _merge

gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

replace DistName=strproper(DistName)
replace DistName="The Center for Creativity Innovation and Discovery" if strpos(DistName, "Innovation")>0

save "${int}/UT_2018_district.dta", replace

* Subgroups
import excel "${raw}/UT_OriginalData_2018_subgroup.xlsx", sheet("LEAByTestAndDemographic") firstrow allstring clear

drop AllStudents

foreach i of varlist AfAmBlack AmericanIndian Asian HispanicLatino MultipleRaces PacificIslander White LowIncome StudentswDisabilities EnglishLearners {
	rename `i' subgroup`i'
}

reshape long subgroup, i(Test LEAName) j(StudentSubGroup) string

rename subgroup ProficientOrAbove_percent

foreach x of numlist 3/8 {
	replace Test="G0`x'" if strpos(Test, "`x'")>0
}

drop if inlist(Test, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename Test GradeLevel
rename SchoolYear SchYear
rename LEAName DistName

append using "${int}/UT_2018_district.dta"

replace DistName = strproper(DistName)
replace DistName = subinstr(DistName, "Of", "of", 1)
replace DistName = subinstr(DistName, "At ", "at ", 1)
replace DistName = subinstr(DistName, "For", "for", 1)
replace DistName="The Center for Creativity Innovation and Discovery" if strpos(DistName, "Innovation")>0
replace DistName = "Vista at Entrada School of Performing Arts and Technology" if strpos(DistName, "Vista at Entrada")>0
replace DistName="American Preparatory Academy - LEA" if DistName=="American Preparatory Academy"
replace DistName="Thomas Edison - Lea" if DistName == "Thomas Edison"
replace DistName="Athenian eAcademy" if DistName=="Athenian Eacademy"

merge m:1 DistName using "${utah}/NCES_2018_District.dta"

gen DataLevel=2

drop if _merge==2
drop _merge

save "${int}/UT_2018_district.dta", replace 

** Prep to Merge with EdFacts
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

gen StudentSubGroup_TotalTested = "--"
gen ParticipationRate = "--"

replace StudentSubGroup="All Students" if StudentSubGroup=="AllStudents"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="AfAmBlack"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="AmericanIndian"
replace StudentSubGroup="English Learner" if StudentSubGroup=="EnglishLearners"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="LowIncome"
replace StudentSubGroup="Two or More" if StudentSubGroup=="MultipleRaces"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="HispanicLatino"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="PacificIslander"
replace StudentSubGroup="SWD" if StudentSubGroup=="StudentswDisabilities"

replace StudentGroup="RaceEth" if StudentGroup == ""
replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged"
replace StudentGroup="Disability Status" if StudentSubGroup=="SWD"

*** Merge EdFacts Data
merge m:1 DataLevel NCESDistrictID StudentSubGroup GradeLevel Subject using "${edfacts}/2018/edfactscount2018districtutah.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
rename Count Count_n
drop if _merge == 2
drop stnam _merge

merge m:1 DataLevel NCESDistrictID StudentSubGroup GradeLevel Subject using "${edfacts}/2018/edfactspart2018districtutah.dta"
replace ParticipationRate = Participation if _merge == 3 & Participation != ""
drop if _merge == 2
drop stnam _merge Participation

save "${int}/UT_2018_district.dta", replace


*** UT state ***

* Total Tested
import excel "${raw}/UT_OriginalData_2018_proficiency.xlsx", sheet("State Results by Test") firstrow allstring clear

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename State DataLevel
rename SchoolYear SchYear
rename Subject GradeLevel
rename SubjectArea Subject
rename NumberTested StudentSubGroup_TotalTested

drop PercentProficient
gen StudentSubGroup="AllStudents"

save "${int}/UT_2018_state.dta", replace 

* Proficiency levels

import excel "${raw}/UT_OriginalData_2018_all.xlsx", sheet("State") firstrow allstring clear

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename State DataLevel
rename SchoolYear SchYear
rename Subject GradeLevel
rename SubjectArea Subject
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent

gen StudentSubGroup="AllStudents"

merge m:1 Subject GradeLevel StudentSubGroup using "${int}/UT_2018_state.dta"

drop _merge

save "${int}/UT_2018_state.dta", replace

* Subgroups
import excel "${raw}/UT_OriginalData_2018_subgroup.xlsx", sheet("StateByTestAndDemographic") firstrow allstring clear

drop AllStudents

foreach i of varlist AfAmBlack AmericanIndian Asian HispanicLatino MultipleRaces PacificIslander White LowIncome StudentswDisabilities EnglishLearners {
	rename `i' subgroup`i'
}

reshape long subgroup, i(Test) j(StudentSubGroup) string
rename subgroup ProficientOrAbove_percent

foreach x of numlist 3/8 {
	replace Test="G0`x'" if strpos(Test, "`x'")>0
}

drop if inlist(Test, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename Test GradeLevel
rename LEAName DataLevel

append using "${int}/UT_2018_state.dta"

replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

replace StudentSubGroup="All Students" if StudentSubGroup=="AllStudents"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="AfAmBlack"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="AmericanIndian"
replace StudentSubGroup="English Learner" if StudentSubGroup=="EnglishLearners"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="LowIncome"
replace StudentSubGroup="Two or More" if StudentSubGroup=="MultipleRaces"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="HispanicLatino"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="PacificIslander"
replace StudentSubGroup="SWD" if StudentSubGroup=="StudentswDisabilities"

gen StudentGroup="RaceEth"
replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged"
replace StudentGroup="Disability Status" if StudentSubGroup=="SWD"

replace DataLevel = "1"
destring DataLevel, replace

save "${int}/UT_2018_state.dta", replace 

append using "${int}/UT_2018_district.dta"

append using "${int}/UT_2018_school.dta"

save "${int}/UT_2018.dta", replace

** State counts

use "${edfacts}/2018/edfactscount2018districtutah.dta", clear
collapse (sum) Count, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "${int}/UT_AssmtData_2018_State.dta", replace

use "${int}/UT_2018.dta", clear
merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "${int}/UT_AssmtData_2018_State.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "0" & string(Count) != "." & StudentSubGroup != "All Students"
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == ""
replace Count_n = Count if Count != .
drop if _merge == 2
drop Count _merge

*** Other Cleaning
gen AssmtName="SAGE"
gen AssmtType="Regular"
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3-4"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

replace SchYear = "2017-18"
replace State = "Utah"
replace StateAbbrev = "UT"
replace StateFips = 49

foreach i of varlist StateAssignedDistID StateAssignedSchID {
	
	gen `i'1=""
	
}

replace StateAssignedDistID1=State_leaid
replace StateAssignedSchID1=school_id

replace State_leaid=StateAssignedDistID if StateAssignedDistID!=""

foreach i of varlist StateAssignedDistID StateAssignedSchID {
	
	replace `i'1=`i' if `i'!=""
	drop `i'
	rename `i'1 `i'
	
}

replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
replace StateAssignedDistID = "" if DataLevel == 1

** Proficiency Values
foreach i of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	replace `i'="--" if `i'=="null" | `i'=="NULL" | `i'=="" | `i'=="-"
	replace `i'="*" if `i'=="N≤10" | `i'=="n≤10" | `i'=="n<10"| `i'=="N<10"
}

replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, " to ", "-", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "%", "", 1)
gen Below = 0
replace Below = 1 if strpos(ProficientOrAbove_percent, "<") > 0
replace Below = 1 if strpos(ProficientOrAbove_percent, "≤") > 0
gen Above = 0
replace Above = 1 if strpos(ProficientOrAbove_percent, ">") > 0
replace Above = 1 if strpos(ProficientOrAbove_percent, "≥") > 0
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "< ", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "<= ", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "≤", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "> ", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, ">= ", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "≥", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "<", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, ">", "", 1)
gen ProficientOrAbove_percent1 = ProficientOrAbove_percent
destring ProficientOrAbove_percent1, replace force
replace ProficientOrAbove_percent1 = ProficientOrAbove_percent1/100 if Below == 1 | Above == 1
gen ProficientOrAbove_count = .
replace ProficientOrAbove_count = round(ProficientOrAbove_percent1 * Count_n) if Below == 0 & Above == 0
tostring ProficientOrAbove_count, replace
tostring ProficientOrAbove_percent1, replace format("%9.2g") force
replace ProficientOrAbove_percent = "0-" + ProficientOrAbove_percent1 if Below == 1
replace ProficientOrAbove_percent = ProficientOrAbove_percent1 + "-1" if Above == 1
drop ProficientOrAbove_percent1
	
split ProficientOrAbove_percent, parse("-")
replace ProficientOrAbove_percent1 = "" if ProficientOrAbove_percent == ProficientOrAbove_percent1
destring ProficientOrAbove_percent1, replace force
destring ProficientOrAbove_percent2, replace force
replace ProficientOrAbove_percent1 = ProficientOrAbove_percent1/100 if Above == 0 & Below == 0
replace ProficientOrAbove_percent2 = ProficientOrAbove_percent2/100 if Above == 0 & Below == 0
gen ProficientOrAbove_count1 = round(ProficientOrAbove_percent1 * Count_n)
gen ProficientOrAbove_count2 = round(ProficientOrAbove_percent2 * Count_n)
tostring ProficientOrAbove_count1, replace
tostring ProficientOrAbove_count2, replace
replace ProficientOrAbove_count1 = "" if ProficientOrAbove_count1 == "."
replace ProficientOrAbove_count = ProficientOrAbove_count1 + "-" + ProficientOrAbove_count2 if ProficientOrAbove_count1 != "" & ProficientOrAbove_count2 != "."
tostring ProficientOrAbove_percent1, replace format("%9.2g") force
tostring ProficientOrAbove_percent2, replace format("%9.2g") force
replace ProficientOrAbove_percent = ProficientOrAbove_percent1 + "-" + ProficientOrAbove_percent2 if !inlist(ProficientOrAbove_percent1, "", ".")
drop ProficientOrAbove_percent1 ProficientOrAbove_percent2 ProficientOrAbove_count1 ProficientOrAbove_count2

replace ProficientOrAbove_percent = PctProf if !inlist(PctProf, "", ".", "--", "*") & inlist(ProficientOrAbove_percent, "--", "*")
replace ProficientOrAbove_count = "--" if inlist(ProficientOrAbove_count, "", ".")
replace ProficientOrAbove_count = "--" if ProficientOrAbove_percent == "--"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_percent == "*"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
replace ParticipationRate = "--" if ParticipationRate == ""

forvalues n = 1/4{
	gen Lev`n' = Lev`n'_percent
	destring Lev`n', replace force
	gen Lev`n'_count = round(Lev`n' * Count_n)
	tostring Lev`n'_count, replace
	replace Lev`n'_count = "--" if inlist(Lev`n'_count, "", ".")
	replace Lev`n'_count = "--" if Lev`n'_percent == "--"
	replace Lev`n'_count = "*" if Lev`n'_percent == "*"
	replace Lev`n'_count = "*" if StudentSubGroup_TotalTested == "*"
	replace Lev`n'_count = "--" if StudentSubGroup_TotalTested == "--" & Lev`n'_count != "*"
	drop Lev`n'
}

gen Lev5_count = ""
gen Lev5_percent = ""

** StudentGroup_TotalTested
replace Count_n = 0 if Count_n == .
bysort State_leaid seasch StudentGroup GradeLevel Subject: egen test = min(Count_n)
bysort State_leaid seasch StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(Count_n) if test != 0
tostring Count_n, replace force
replace Count_n = "--" if Count_n == "."
drop Count_n test
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = "--" if inlist(StudentGroup_TotalTested, "", ".")

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen Suppressed = 0
replace Suppressed = 1 if inlist(StudentSubGroup_TotalTested, "--", "*")
egen StudentGroup_Suppressed = max(Suppressed), by(StudentGroup GradeLevel Subject DataLevel seasch StateAssignedDistID DistName SchName)
drop Suppressed
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
replace StudentGroup_TotalTested = AllStudents_Tested if StudentGroup_Suppressed == 1
replace StudentGroup_TotalTested = AllStudents_Tested if inlist(StudentGroup, "Disability Status", "Economic Status", "EL Status")
drop AllStudents_Tested StudentGroup_Suppressed
replace StudentGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "--"
replace StudentGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "*"

** Unmerged Districts

replace CountyCode="49049" if strpos(DistName, "Alpine")>0 & CountyCode == ""
replace CountyName="Utah County" if strpos(DistName, "Alpine")>0 & CountyName == ""
replace DistType="Regular local school district" if strpos(DistName, "Alpine")>0 & DistType == ""
replace NCESDistrictID="4900030" if strpos(DistName, "Alpine")>0 & NCESDistrictID == ""
replace StateAssignedDistID="UT-01" if strpos(DistName, "Alpine")>0 & StateAssignedDistID == ""
replace DistCharter="No" if strpos(DistName, "Alpine")>0 & DistCharter == ""
replace DistLocale="Suburb, large" if strpos(DistName, "Alpine")>0 & DistLocale == ""
replace CountyName="Sanpete County" if DistName=="North Sanpete District" & CountyName == ""
replace CountyCode="49039" if DistName=="North Sanpete District" & CountyCode == ""
replace DistCharter="No" if DistName=="North Sanpete District" & DistCharter == ""
replace DistLocale="Rural, fringe" if DistName=="North Sanpete District" & DistLocale == ""
replace NCESDistrictID="4900660" if DistName=="North Sanpete District" & NCESDistrictID == ""
replace StateAssignedDistID="UT-20" if DistName=="North Sanpete District" & StateAssignedDistID == ""

replace SchName="Canyon View School" if strpos(SchName, "Canyon View")>0

replace SchLevel="Missing/not reported" if SchName=="North Sanpete Special Purpose School"
replace SchType="Missing/not reported" if SchName=="North Sanpete Special Purpose School"
replace SchVirtual="Missing/not reported" if SchName=="North Sanpete Special Purpose School"

*** Clean up variables & save file
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

label def DataLevel_l 1 "State" 2 "District" 3 "School"
label values DataLevel DataLevel_l

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/UT_AssmtData_2018.dta", replace

export delimited using "${output}/UT_AssmtData_2018.csv", replace
