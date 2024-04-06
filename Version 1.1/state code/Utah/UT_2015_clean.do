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

import excel "${raw}/UT_OriginalData_2015_all.xlsx", sheet("School Proficiency Levels") firstrow allstring clear

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
rename LEANameDistrictCharter DistName
rename School SchName

save "${int}/UT_2015_school.dta", replace 

import excel "${raw}/UT_OriginalData_2015_proficiency.xlsx", sheet("School Results by Test Subject") firstrow allstring clear 

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename SchoolYear SchYear
rename DistrictLEA DistName
rename SchoolName SchName 
rename Subject GradeLevel 
rename SubjectArea Subject
rename PercentProficient ProficientOrAbove_percent

replace SchName="WASHINGTON COUNTY ONLINE SCHOOL" if SchName=="UTAH ONLINE K8"
replace SchName="WASHINGTON COUNTY ONLINE HIGH SCHOOL" if SchName=="UTAH ONLINE 7-12"
replace SchName="SYRACUSE ARTS ACADEMY" if SchName=="SYRACUSE ARTS ACADEMY - ANTELOPE"

merge 1:1 SchName DistName Subject GradeLevel using "${int}/UT_2015_school.dta"

drop _merge

replace SchName=strproper(SchName)
replace DistName=strproper(DistName)

replace SchName="Goldminers Daughter" if strpos(SchName, "Goldminer")>0
replace SchName="Kays Creek Elementary" if strpos(SchName, "Kay'S")>0
replace SchName="Tsebiinidzisgai School" if strpos(SchName, "Tse'Bii")>0
replace SchName="The Center for Creativity Innovation and Discovery" if strpos(SchName, "Innovation")>0
replace DistName="The Center for Creativity Innovation and Discovery" if strpos(SchName, "Innovation")>0

replace SchName="Minersville School (Middle)" if SchName=="Minersville School" & (GradeLevel=="G03" | GradeLevel=="G04" | GradeLevel=="G05")
	replace SchName="Minersville School (Primary)" if SchName=="Minersville School" & (GradeLevel=="G06" | GradeLevel=="G07" | GradeLevel=="G08")
replace SchName="Canyon View School (Middle)" if SchName=="Canyon View School" & inlist(GradeLevel, "GO6", "G07", "G08")
replace SchName="Canyon View School (Primary)" if SchName=="Canyon View School" & inlist(GradeLevel, "G03", "G04", "G05")
replace DistName = "American Preparatory Academy--Lea" if DistName == "American Preparatory Academy"
replace DistName = "Thomas Edison - Lea" if DistName == "Thomas Edison"

merge m:1 SchName DistName using "${utah}/NCES_2015_School.dta"

gen DataLevel = 3

drop if _merge==2

save "${int}/UT_2015_school.dta", replace 

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

replace SchName=strupper(SchName)
replace DistName=strupper(DistName)

merge m:1 SchName DistName SchYear using "${raw}/UT_unmerged_schools.dta", update

drop if _merge==2
drop _merge

** Unmerged Schools

replace SchName=strproper(SchName)
replace DistName=strproper(DistName)

replace SchName="Minersville School" if strpos(SchName, "Minersville")>0
replace SchName="Canyon View School" if strpos(SchName, "Canyon View")>0
replace SchName="Goldminers Daughter" if strpos(SchName, "Goldminer")>0
replace SchName="Kays Creek Elementary" if strpos(SchName, "Kay'S")>0
replace SchName="TseBiiNidzisgai School" if strpos(SchName, "Tse'Bii")>0
replace SchName="LaVerkin School" if strpos(SchName, "La Verkin")>0
replace SchName="Scera Park" if strpos(SchName, "Scera")>0
replace SchName="The Center for Creativity Innovation and Discovery" if strpos(SchName, "Innovation")>0
replace DistName="The Center for Creativity Innovation and Discovery" if strpos(SchName, "Innovation")>0

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
merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${edfacts}/2015/edfactscount2015schoolutah.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
gen Count_n = Count if DataLevel == 3 & _merge == 3
drop if _merge == 2
drop Count stnam schnam _merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${edfacts}/2015/edfactspart2015schoolutah.dta"
replace ParticipationRate = Participation if _merge == 3 & Participation != ""
drop if _merge == 2
drop stnam _merge

save "${int}/UT_2015_school.dta", replace 


*** UT Districts ***

* Proficiency levels
import excel "${raw}/UT_OriginalData_2015_all.xlsx", sheet("LEA Proficiency Levels") firstrow allstring clear

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
rename LEANameDistrictCharter DistName

save "${int}/UT_2015_district.dta", replace 

import excel "${raw}/UT_OriginalData_2015_proficiency.xlsx", sheet("District Results by Test Subjec") firstrow allstring clear 

gen Subject1=""
replace Subject1="English Language Arts" if strpos(Subject, "Language Arts")>0
replace Subject1="Mathematics" if strpos(Subject, "Math")>0
replace Subject1="Science" if strpos(Subject, "Science")>0

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename SchoolYear SchYear
rename DistrictLEA DistName
rename Subject GradeLevel 
rename Subject1 Subject
rename PercentProficient ProficientOrAbove_percent

merge 1:1 DistName Subject GradeLevel using "${int}/UT_2015_district.dta"

drop _merge

replace DistName = strupper(DistName)
replace DistName = "AMERICAN PREPARATORY ACADEMY--LEA" if DistName == "AMERICAN PREPARATORY ACADEMY"
replace DistName = "THOMAS EDISON - LEA" if DistName == "THOMAS EDISON"

merge m:1 DistName using "${utah}/NCES_2015_District.dta"

gen DataLevel = 2
gen StateAssignedDistID = State_leaid

drop if _merge==2

drop _merge

** Prep to Merge with EdFacts
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"
gen StudentSubGroup_TotalTested = "--"
gen ParticipationRate = "--"

*** Merge EdFacts Data
merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${edfacts}/2015/edfactscount2015districtutah.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
rename Count Count_n
drop if _merge == 2
drop stnam _merge

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${edfacts}/2015/edfactspart2015districtutah.dta"
replace ParticipationRate = Participation if _merge == 3 & Participation != ""
drop if _merge == 2
drop stnam _merge Participation

save "${int}/UT_2015_district.dta", replace  

*** UT state ***

* Proficiency levels

import excel "${raw}/UT_OriginalData_2015_all.xlsx", sheet("State Proficiency Levels") firstrow allstring clear

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

save "${int}/UT_2015_state.dta", replace 

import excel "${raw}/UT_OriginalData_2015_proficiency.xlsx", sheet("State Results by Test Subject") firstrow allstring clear 

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

replace SubjectArea="English Language Arts" if strpos(SubjectArea, "L")>0
replace SubjectArea="Mathematics" if strpos(SubjectArea, "M")>0
replace SubjectArea="Science" if strpos(SubjectArea, "S")>0

rename SchoolYear SchYear
rename Subject GradeLevel 
rename SubjectArea Subject
rename PercentProficient ProficientOrAbove_percent
rename State DataLevel

merge 1:1 Subject GradeLevel using "${int}/UT_2015_state.dta"

replace DataLevel = "1"
destring DataLevel, replace

replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"
gen StudentSubGroup_TotalTested = "--"
gen ParticipationRate = "--"

drop _merge

save "${int}/UT_2015_state.dta", replace

append using "${int}/UT_2015_district.dta"

append using "${int}/UT_2015_school.dta"

save "${int}/UT_2015.dta", replace

** State counts
preserve
keep if DataLevel == 2
rename Count_n Count
collapse (sum) Count, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "${int}/UT_AssmtData_2015_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "${int}/UT_AssmtData_2015_State.dta"
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

replace SchYear = "2014-15"
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
replace ProficientOrAbove_count = ProficientOrAbove_count1 + "-" + ProficientOrAbove_count2 if ProficientOrAbove_count1 != "" & ProficientOrAbove_count2 != "."
tostring ProficientOrAbove_percent1, replace format("%9.2g") force
tostring ProficientOrAbove_percent2, replace format("%9.2g") force
replace ProficientOrAbove_percent = ProficientOrAbove_percent1 + "-" + ProficientOrAbove_percent2 if !inlist(ProficientOrAbove_percent1, "", ".")
drop ProficientOrAbove_percent1 ProficientOrAbove_percent2 ProficientOrAbove_count1 ProficientOrAbove_count2

replace ProficientOrAbove_percent = PctProf if !inlist(PctProf, "", ".", "--", "*") & inlist(ProficientOrAbove_percent, "--", "*")
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == ""
replace ProficientOrAbove_count = "--" if ProficientOrAbove_percent == "--"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_percent == "*"

forvalues n = 1/4{
	gen Lev`n' = Lev`n'_percent
	destring Lev`n', replace force
	gen Lev`n'_count = round(Lev`n' * Count_n)
	tostring Lev`n'_count, replace
	replace Lev`n'_count = "--" if Lev`n'_count == ""
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
replace StudentGroup_TotalTested = "--" if inlist(StudentGroup_TotalTested, "", ".")

** Cleaning up from unmerged
replace DistLocale="City, small" if DistName=="Washington District" & DistLocale==""
replace CountyName="Washington County" if DistName=="Washington District" & CountyName==""
replace StateAssignedSchID = subinstr(StateAssignedSchID, "UT-", "", 1)
replace StateAssignedDistID = subinstr(StateAssignedDistID, "UT-", "", 1)

*** Clean up variables & save file
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

label def DataLevel_l 1 "State" 2 "District" 3 "School"
label values DataLevel DataLevel_l

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/UT_AssmtData_2015.dta", replace

export delimited using "${output}/UT_AssmtData_2015.csv", replace
