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

import excel "${raw}/UT_OriginalData_2017_all.xlsx", sheet("School Proficiency Levels") allstring clear

foreach x of numlist 3/8 {
	replace E="G0`x'" if strpos(E, "`x'")>0
}

drop if inlist(E, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename A SchYear
rename E GradeLevel
rename D Subject
rename F Lev1_percent
rename G Lev2_percent 
rename H Lev3_percent 
rename I Lev4_percent
rename B DistName
rename C SchName

save "${int}/UT_2017_school.dta", replace 

import excel "${raw}/UT_OriginalData_2017_proficiency.xlsx", sheet("School Results by Test") firstrow allstring clear 

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

merge 1:1 SchName DistName Subject GradeLevel using "${int}/UT_2017_school.dta"

drop _merge

replace SchName=strproper(SchName)
replace DistName=strproper(DistName)

replace SchName=subinstr(SchName, "Mt ", "Mt. ", 1)
replace SchName=subinstr(SchName, "Mtn ", "Mtn. ", 1)
replace SchName=subinstr(SchName, "E ", "E. ", 1)
replace SchName=subinstr(SchName, "N ", "N. ", 1)
replace SchName=subinstr(SchName, "P ", "P. ", 1)
replace SchName=subinstr(SchName, "R ", "R. ", 1)
replace SchName=subinstr(SchName, "T H ", "T.H. ", 1)
replace SchName=subinstr(SchName, "W ", "W. ", 1)
split SchName, parse("(")
replace SchName = SchName1
drop SchName1 SchName2
replace SchName = strtrim(SchName)

replace SchName="Goldminers Daughter" if strpos(SchName, "Goldminer")>0
replace SchName="Kays Creek Elementary" if strpos(SchName, "Kay'S")>0
replace SchName="Tsebiinidzisgai School" if strpos(SchName, "Tse'Bii")>0
replace SchName = "Vista at Entrada School of Performing Arts and Technology" if strpos(SchName, "Vista at Entrada")>0
replace SchName="John C. Fremont School" if SchName=="John C Fremont School"
replace SchName="Karl G. Maeser Preparatory Academy" if SchName=="Karl G Maeser Preparatory Academy"
replace SchName="C.S. Lewis Academy" if SchName=="Cs Lewis Academy"
replace SchName="M. Lynn Bennion School" if SchName=="M Lynn Bennion School"
replace SchName="Thomas O. Smith School" if SchName=="Thomas O Smith School"
replace SchName="Beehive Science & Technology Academy" if SchName=="Beehive Science & Technology Academy (Bsta)"
replace SchName="Horizonte Instruction & Training Center" if strpos(SchName, "Horizonte Instr &")>0
replace SchName=subinstr(SchName, "--", " - ", 1) if SchName == "American Preparatory Academy--The School For New Americans"

replace SchName="Minersville School (Primary)" if SchName=="Minersville School" & (GradeLevel=="G03" | GradeLevel=="G04" | GradeLevel=="G05")
	replace SchName="Minersville School (Middle)" if SchName=="Minersville School" & (GradeLevel=="G06" | GradeLevel=="G07" | GradeLevel=="G08")
replace SchName="Canyon View School (Middle)" if SchName=="Canyon View School" & inlist(GradeLevel, "GO6", "G07", "G08")
replace SchName="Canyon View School (Primary)" if SchName=="Canyon View School" & inlist(GradeLevel, "G03", "G04", "G05")

replace DistName="American Preparatory Academy - Lea" if DistName=="American Preparatory Academy"
replace DistName="Thomas Edison - Lea" if DistName == "Thomas Edison"
replace DistName="Karl G. Maeser Preparatory Academy" if DistName=="Karl G Maeser Preparatory Academy"
replace DistName="C.S. Lewis Academy" if DistName=="Cs Lewis Academy"
replace DistName="Academy for Math Engineering & Science" if DistName=="Academy For Math Engineering & Science (Ames)"
replace DistName="Beehive Science & Technology Academy" if DistName=="Beehive Science & Technology Academy (Bsta)"
replace DistName="No. Ut. Acad. For Math Engineering & Science" if DistName=="No Ut Acad For Math Engineering & Science (Nuames)"
replace DistName="Utah County Academy of Science" if DistName=="Utah County Academy Of Science (Ucas)"

merge m:1 SchName DistName using "${utah}/NCES_2017_School.dta"

gen DataLevel = 3

drop if _merge==2

save "${int}/UT_2017_school.dta", replace 

destring NCESDistrictID, replace
destring NCESSchoolID, replace

drop _merge

gen StateAssignedDistID = State_leaid
gen StateAssignedSchID = seasch

decode SchVirtual, gen(SchVirtual_s)
drop SchVirtual
rename SchVirtual_s SchVirtual

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen(SchType_s)
drop SchType
rename SchType_s SchType

merge m:1 SchName DistName SchYear using "${raw}/UT_unmerged_schools.dta", update
replace StateAssignedSchID = seasch if StateAssignedSchID == ""

drop if _merge==2
drop _merge

** Unmerged Schools
replace SchName="Minersville School" if strpos(SchName, "Minersville")>0
replace SchName="Canyon View School" if strpos(SchName, "Canyon View")>0
replace SchName="Goldminers Daughter" if strpos(SchName, "Goldminer")>0
replace SchName="Kays Creek Elementary" if strpos(SchName, "Kay'S")>0
replace SchName="TseBiiNidzisgai School" if strpos(SchName, "Tse'Bii")>0
replace SchName="LaVerkin School" if strpos(SchName, "La Verkin")>0
replace SchName="Scera Park" if strpos(SchName, "Scera")>0
replace SchName="The Center for Creativity Innovation and Discovery" if strpos(SchName, "Innovation")>0

** Prep to Merge with EdFacts
gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

format NCESSchoolID %12.0f
tostring NCESSchoolID, replace usedisplayformat
tostring NCESDistrictID, replace

gen StudentSubGroup_TotalTested = "--"
gen ParticipationRate = "--"

*** Merge EdFacts Data
merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${edfacts}/2017/edfactscount2017schoolutah.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
replace StudentSubGroup_TotalTested = "*" if Count == 0
gen Count_n = Count if DataLevel == 3 & _merge == 3
drop if _merge == 2
drop Count stnam schnam _merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${edfacts}/2017/edfactspart2017schoolutah.dta"
replace ParticipationRate = Participation if _merge == 3 & Participation != ""
drop if _merge == 2
drop stnam _merge

save "${int}/UT_2017_school.dta", replace 


*** UT Districts ***

* Proficiency levels
import excel "${raw}/UT_OriginalData_2017_proficiency.xlsx", sheet("Overall LEA Results") firstrow allstring clear

rename SchoolYear SchYear
rename LEADistrictorCharter DistName
rename SubjectArea Subject
rename PercentProficient ProficientOrAbove_percent
gen GradeLevel = "G38"

save "${int}/UT_2017_district_allstud_g38.dta", replace

import excel "${raw}/UT_OriginalData_2017_all.xlsx", sheet("LEA Proficiency Levels") firstrow allstring clear

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

save "${int}/UT_2017_district.dta", replace 

import excel "${raw}/UT_OriginalData_2017_proficiency.xlsx", sheet("LEA Results by Test") firstrow allstring clear 

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

merge 1:1 DistName Subject GradeLevel using "${int}/UT_2017_district.dta"

drop _merge

append using "${int}/UT_2017_district_allstud_g38.dta"

gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

replace DistName=strproper(DistName)

save "${int}/UT_2017_district.dta", replace

* Subgroups
import excel "${raw}/UT_OriginalData_2017_subgroup.xlsx", sheet("Overall LEA Results") cellrange (A2:M449) firstrow allstring clear

rename A DistName
rename B Subject

drop AllStudents

foreach i of varlist AfAmBlack AmericanIndian Asian HispanicLatino MultipleRaces PacificIslander White EconomicallyDisadv StudentswDisabilities EnglishLearners {
	rename `i' subgroup`i'
}

gen x = _n - 1
replace x = x/3 if Subject == "English Language Arts"
replace x = x-1 if Subject == "Mathematics"
replace x = x/3 if Subject == "Mathematics"
replace x = x-2 if Subject == "Science"
replace x = x/3 if Subject == "Science"

preserve
drop if DistName == ""
replace x = _n - 1
rename DistName District
keep District x
save "${int}/UT_2017_district_subgroup_merge.dta", replace
restore

merge m:1 x using "${int}/UT_2017_district_subgroup_merge.dta"
replace DistName = District
drop _merge

reshape long subgroup, i(District Subject) j(StudentSubGroup) string

rename subgroup ProficientOrAbove_percent

gen GradeLevel = "G38"

replace StudentSubGroup="All Students" if StudentSubGroup=="AllStudents"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="AfAmBlack"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="AmericanIndian"
replace StudentSubGroup="English Learner" if StudentSubGroup=="EnglishLearners"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="EconomicallyDisadv"
replace StudentSubGroup="Two or More" if StudentSubGroup=="MultipleRaces"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="HispanicLatino"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="PacificIslander"
replace StudentSubGroup="SWD" if StudentSubGroup=="StudentswDisabilities"

gen StudentGroup="RaceEth"
replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged"
replace StudentGroup="Disability Status" if StudentSubGroup=="SWD"

append using "${int}/UT_2017_district.dta"

replace DistName = strproper(DistName)
replace DistName = subinstr(DistName, "Of", "of", 1)
replace DistName = subinstr(DistName, "At ", "at ", 1)
replace DistName = subinstr(DistName, " The", " the", 1)
replace DistName = subinstr(DistName, "For ", "for ", 1)
replace DistName="The Center for Creativity Innovation and Discovery" if strpos(DistName, "Innovation")>0
replace DistName = "Vista at Entrada School of Performing Arts and Technology" if strpos(DistName, "Vista at Entrada")>0
replace DistName="American Preparatory Academy - LEA" if DistName=="American Preparatory Academy"
replace DistName="Thomas Edison - Lea" if DistName == "Thomas Edison"
replace DistName="Athenian eAcademy" if DistName=="Athenian Eacademy"
replace DistName="Karl G. Maeser Preparatory Academy" if DistName=="Karl G Maeser Preparatory Academy"
replace DistName="C.S. Lewis Academy" if DistName=="Cs Lewis Academy"
replace DistName="Academy for Math Engineering & Science" if DistName=="Academy for Math Engineering & Science (Ames)"
replace DistName="Beehive Science & Technology Academy" if DistName=="Beehive Science & Technology Academy (Bsta)"
replace DistName="No. UT. Acad. for Math Engineering & Science" if DistName=="No Ut Acad for Math Engineering & Science (Nuames)"
replace DistName="Utah County Academy of Science" if DistName=="Utah County Academy of Science (Ucas)"

merge m:1 DistName using "${utah}/NCES_2017_District.dta"

gen DataLevel = 2
gen StateAssignedDistID = State_leaid

drop if _merge==2

drop _merge

** Prep to Merge with EdFacts
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

gen StudentSubGroup_TotalTested = "--"
gen ParticipationRate = "--"

*** Merge EdFacts Data
merge m:1 DataLevel NCESDistrictID StudentSubGroup GradeLevel Subject using "${edfacts}/2017/edfactscount2017districtutah.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
replace StudentSubGroup_TotalTested = "*" if Count == 0
rename Count Count_n
drop if _merge == 2
drop stnam _merge

merge m:1 DataLevel NCESDistrictID StudentSubGroup GradeLevel Subject using "${edfacts}/2017/edfactspart2017districtutah.dta"
replace ParticipationRate = Participation if _merge == 3 & Participation != ""
drop if _merge == 2
drop stnam _merge Participation

save "${int}/UT_2017_district.dta", replace

*** UT state ***

* Proficiency levels

import excel "${raw}/UT_OriginalData_2017_all.xlsx", sheet("State Proficiency Levels") firstrow allstring clear

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

replace SubjectArea = "English Language Arts" if strpos(SubjectArea, "L")>0
replace SubjectArea = "Mathematics" if strpos(SubjectArea, "M")>0
replace SubjectArea ="Science" if strpos(SubjectArea, "S")>0

rename State DataLevel
rename SchoolYear SchYear
rename Subject GradeLevel
rename SubjectArea Subject
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent

save "${int}/UT_2017_state.dta", replace 

import excel "${raw}/UT_OriginalData_2017_proficiency.xlsx", sheet("State Results by Test") firstrow allstring clear 

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename SchoolYear SchYear
rename Subject GradeLevel 
rename SubjectArea Subject
rename PercentProficient ProficientOrAbove_percent
rename State DataLevel

merge 1:1 Subject GradeLevel using "${int}/UT_2017_state.dta"

replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"
gen StudentSubGroup_TotalTested = "--"
gen ParticipationRate = "--"

drop _merge

save "${int}/UT_2017_state.dta", replace

* Subgroups
import excel "${raw}/UT_OriginalData_2017_subgroup.xlsx", sheet("State Results by Test") cellrange (A2:N30) firstrow allstring clear

rename C Test
rename A LEAName
rename B Subject

drop AllStudents

foreach i of varlist AfAmBlack AmericanIndian Asian HispanicLatino MultipleRaces PacificIslander White EconomicallyDisadv StudentswDisabilities EnglishLearners {
	rename `i' subgroup`i'
}

reshape long subgroup, i(Test) j(StudentSubGroup) string

* replace StudentSubGroup="LowIncome" if StudentSubGroup=="EconomicallyDisadv"

rename subgroup ProficientOrAbove_percent

foreach x of numlist 3/8 {
	replace Test="G0`x'" if strpos(Test, "`x'")>0
}

drop if inlist(Test, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename Test GradeLevel
rename LEAName DataLevel

append using "${int}/UT_2017_state.dta"

replace DataLevel = "1"
destring DataLevel, replace

replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

replace StudentSubGroup="All Students" if StudentSubGroup=="AllStudents"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="AfAmBlack"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="AmericanIndian"
replace StudentSubGroup="English Learner" if StudentSubGroup=="EnglishLearners"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="EconomicallyDisadv"
replace StudentSubGroup="Two or More" if StudentSubGroup=="MultipleRaces"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="HispanicLatino"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="PacificIslander"
replace StudentSubGroup="SWD" if StudentSubGroup=="StudentswDisabilities"

replace StudentGroup="RaceEth" if StudentGroup==""
replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged"
replace StudentGroup="Disability Status" if StudentSubGroup=="SWD"

save "${int}/UT_2017_state.dta", replace

append using "${int}/UT_2017_district.dta"

append using "${int}/UT_2017_school.dta"

save "${int}/UT_2017.dta", replace

** State counts

use "${edfacts}/2017/edfactscount2017districtutah.dta", clear
collapse (sum) Count, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "${int}/UT_AssmtData_2017_State.dta", replace

use "${int}/UT_2017.dta", clear
merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "${int}/UT_AssmtData_2017_State.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "0" & string(Count) != "."
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

replace SchYear = "2016-17"
replace State = "Utah"
replace StateAbbrev = "UT"
replace StateFips = 49

replace CountyName = strproper(CountyName)

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
replace ProficientOrAbove_count = ProficientOrAbove_count1 + "-" + ProficientOrAbove_count2 if ProficientOrAbove_count1 != "" & ProficientOrAbove_count2 != "." & ProficientOrAbove_count1 != ProficientOrAbove_count2
tostring ProficientOrAbove_percent1, replace format("%9.2g") force
tostring ProficientOrAbove_percent2, replace format("%9.2g") force
replace ProficientOrAbove_percent = ProficientOrAbove_percent1 + "-" + ProficientOrAbove_percent2 if !inlist(ProficientOrAbove_percent1, "", ".")
replace ProficientOrAbove_count = ProficientOrAbove_count1 if ProficientOrAbove_count1 != "" & ProficientOrAbove_count == ProficientOrAbove_count2
drop ProficientOrAbove_percent1 ProficientOrAbove_percent2 ProficientOrAbove_count1 ProficientOrAbove_count2

gen flag_edfacts = 1 if !inlist(PctProf, "", ".", "--", "*") & inlist(ProficientOrAbove_percent, "--", "*")
replace ProficientOrAbove_percent = PctProf if flag_edfacts == 1
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
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
gen StudentGroup_TotalTested = AllStudents_Tested

drop if StudentGroup_TotalTested == "0" & inlist(ProficientOrAbove_percent, "*", "--")
replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == "0"
replace StudentSubGroup_TotalTested = "--" if StudentGroup_TotalTested == "--" & StudentGroup == "All Students"

** Cleaning up from unmerged
drop if SchName=="South Region Deaf"

replace CountyName="Utah County" if SchName=="Eschool@Provo School District"
replace DistLocale="City, midsize" if SchName=="Eschool@Provo School District"

replace DistLocale="Suburb, large" if inlist(DistName, "Canyons District", "Alpine District") & DistLocale==""
replace DistLocale="City, midsize" if DistName=="Salt Lake District" & DistLocale==""
replace DistLocale="City, small" if DistName=="Washington District" & DistLocale==""
replace CountyName="Salt Lake County" if inlist(DistName, "Canyons District", "Salt Lake District") & CountyName==""
replace CountyName="Utah County" if DistName=="Alpine District" & CountyName==""
replace CountyName="Washington County" if DistName=="Washington District" & CountyName==""

replace StateAssignedSchID = StateAssignedDistID + "-" + StateAssignedSchID if strpos(StateAssignedSchID, "-") == 0 & DataLevel == 3
replace StateAssignedSchID = subinstr(StateAssignedSchID, "UT-", "", .) if strpos(StateAssignedSchID, "UT-") > 0
replace StateAssignedDistID="UT-"+StateAssignedDistID if strpos(StateAssignedDistID, "UT-")<=0 & DataLevel != 1
replace DistCharter="No" if DistCharter=="NO"

gen flag = 1 if inlist(SchName, "East School", "Legacy School")
replace SchName = SchName + " (" + DistName + ")" if flag == 1
replace SchName = subinstr(SchName, " District", "", 1) if flag == 1
drop flag

*** Cleaning Inconsistent School & District Names
merge m:m SchYear NCESSchoolID NCESDistrictID using "${raw}/ut_full-dist-sch-stable-list_through2023.dta"
drop if _merge == 2
replace SchName = newschname if _merge == 3 & SchName != newschname
replace DistName = newdistname if _merge == 3 & DistName != newdistname

replace DistName = "Weilenmann School of Discovery" if NCESDistrictID == "4900145"
replace DistName = "Walden School of Liberal Arts" if NCESDistrictID == "4900061"
replace DistName = "Vista School" if NCESDistrictID == "4900141"
replace DistName = "Academy for Math Engineering & Science (Ames)" if NCESDistrictID == "4900017"
replace DistName = "American Academy of Innovation" if NCESDistrictID == "4900186"
replace DistName = "American International School of Utah" if NCESDistrictID == "4900172"
replace DistName = "American Preparatory Academy (District)" if NCESDistrictID == "4900005"
replace DistName = "Ascent Academies of Utah" if NCESDistrictID == "4900174"
replace DistName = "Athenian eAcademy" if NCESDistrictID == "4900181"
replace DistName = "Beehive Science & Technology Academy" if NCESDistrictID == "4900023"
replace DistName = "C.S. Lewis Academy" if NCESDistrictID == "4900074"
replace DistName = "Early Light Academy at Daybreak" if NCESDistrictID == "4900140"
replace DistName = "InTech Collegiate Academy" if NCESDistrictID == "4900039"
replace DistName = "Karl G. Maeser Preparatory Academy" if NCESDistrictID == "4900056"
replace DistName = "No. UT Academy for Math Engineering & Science" if NCESDistrictID == "4900063"
replace DistName = "Pioneer High School for the Performing Arts" if NCESDistrictID == "4900164"
replace DistName = "Promontory School of Expeditionary Learning" if NCESDistrictID == "4900157"
replace DistName = "Salt Lake Center for Science Education" if NCESDistrictID == "4900123"
replace DistName = "Salt Lake School for the Performing Arts" if NCESDistrictID == "4900050"
replace DistName = "The Center for Creativity Innovation and Discovery" if NCESDistrictID == "4900193"
replace DistName = "Thomas Edison (District)" if NCESDistrictID == "4900015"
replace DistName = "Tuacahn High School for the Performing Arts" if NCESDistrictID == "4900012"
replace DistName = "Utah County Academy of Science (UCAS)" if NCESDistrictID == "4900020"
replace DistName = "Utah Schools for Deaf & Blind" if NCESDistrictID == "4900069"
replace DistName = "Mountain View Montessori" if NCESDistrictID == "4900169"

*** Clean up variables & save file
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

label def DataLevel_l 1 "State" 2 "District" 3 "School"
label values DataLevel DataLevel_l

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/UT_AssmtData_2017.dta", replace

export delimited using "${output}/UT_AssmtData_2017.csv", replace