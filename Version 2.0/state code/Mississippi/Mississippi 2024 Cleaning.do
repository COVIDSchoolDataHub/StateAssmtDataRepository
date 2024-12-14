clear
set more off

global MS "/Users/miramehta/Documents/Mississippi"
global raw "/Users/miramehta/Documents/Mississippi/Original Data Files"
global output "/Users/miramehta/Documents/Mississippi/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global EDFacts "/Users/miramehta/Documents/EDFacts"
global Request "/Users/miramehta/Documents/Mississippi/Original Data Files/Data Request"

** State Level data

// Combining
use "${raw}/MS_OriginalData_2024_ela_math_state", clear
append using "$raw/MS_OriginalData_2024_sci_state"
drop if missing(TestGrade)
drop O

// Renaming & Fixing Variables
gen GradeLevel = substr(TestGrade,strpos(TestGrade, "Grade ") +6,1)
drop if missing(real(GradeLevel))
replace GradeLevel = "G0" + GradeLevel

gen Subject = "ela" if strpos(TestGrade, "ELA") !=0
replace Subject = "math" if strpos(TestGrade, "Math") !=0
replace Subject = "sci" if strpos(TestGrade, "Science") !=0
drop TestGrade
forvalues n = 1/5 {
	rename Level`n' Lev`n'_count
}
rename TotalTesters StudentSubGroup_TotalTested
rename H Lev1_percent
rename I Lev2_percent
rename J Lev3_percent
rename K Lev4_percent
rename L Lev5_percent
drop N
rename Level45 ProficientOrAbove_percent

// Converting Types

foreach var of varlist *_count {
	format `var' %9.3g
	tostring `var', replace
}
foreach var of varlist *_percent {
	format `var' %9.3g
	tostring `var', replace force usedisplayformat
}

//ProficientOrAbove_count
gen ProficientOrAbove_count = string(real(Lev4_count) + real(Lev5_count)) if !missing(real(Lev4_count)) & !missing(real(Lev5_count))

format StudentSubGroup_TotalTested %9.3g
tostring StudentSubGroup_TotalTested, replace

// DataLevel
gen DataLevel = 1

save "$raw/MS_AssmtData_2024_State", replace


** District & School Level Data

//Combining Files
clear
tempfile temp1
save "`temp1'", replace emptyok
foreach sub in ELA Math sci {
	forvalues n = 3/8 {
		if "`sub'" == "sci" & `n' !=5 & `n' !=8 continue
		use "$raw/MS_OriginalData_2024_`sub'_G`n'", clear
		gen Subject = "`sub'"
		gen GradeLevel = "G0" + "`n'"
		append using "`temp1'"
		save "`temp1'", replace
	}
}
replace Entity = strtrim(Entity)
replace Entity = stritrim(Entity)
drop if missing(Entity)

//Renaming & Dropping
rename AverageScaleScore AvgScaleScore
forvalues n = 1/5 {
	rename Level`n'PCT Lev`n'_percent
}
rename TestTakers StudentSubGroup_TotalTested
rename datalev DataLevel

keep Entity DataLevel NCESDistrictID NCESSchoolID AvgScaleScore Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent StudentSubGroup_TotalTested Subject GradeLevel

//Fixing Level counts & Percents
foreach var of varlist *percent AvgScaleScore {
	replace `var' = string(real(`var'), "%9.3g") if !missing(real(`var'))
}

foreach percent of varlist *_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	gen `count' = string(round(real(`percent')* real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested))
	replace `count' = "--" if missing(`count')
}

//Generating ProficientOrAbove_count and percent
gen ProficientOrAbove_percent = string(real(Lev4_percent) + real(Lev5_percent), "%9.3g") if !missing(real(Lev4_percent)) & !missing(real(Lev5_percent))
replace ProficientOrAbove_percent = "--" if missing(ProficientOrAbove_percent)
gen ProficientOrAbove_count = string(real(Lev4_count) + real(Lev5_count)) if !missing(real(Lev4_count)) & !missing(real(Lev5_count))
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)


//Subject
replace Subject = lower(Subject)

//Duplicates
duplicates drop

/*
//Getting ID's from stable ID list
tempfile temp2
save "`temp2'", replace
duplicates drop Entity, force
keep Entity
save "$MS/2024_Districts_Schools", replace


use "$MS/standarddistnames", clear
replace newdistname = subinstr(newdistname, "County", "Co",.)
duplicates drop newdistname, force
drop olddistname
sort newdistname
save "$MS/DistIDs_2024", replace

use "$MS/standardschnames", clear
duplicates drop newschname, force
drop oldschname olddistname newdistname
replace newschname = subinstr(newschname, "Elementary", "Elem",.)
replace newschname = subinstr(newschname, "County", "Co",.)
replace newschname = newschname + " School" if strpos(newschname, "School") == 0 & strpos(newschname, "Sch") == 0
replace newschname = subinstr(newschname, " Sch", " School",.) if strpos(newschname, "School") == 0 
replace newschname = subinstr(newschname, " Jr " ," Junior ",.)
gen newschnamecode = subinstr(newschname, " ", "",.)
replace newschnamecode = lower(newschnamecode)
replace newschnamecode = subinstr(newschnamecode, "-", "",.)
replace newschnamecode = subinstr(newschnamecode, "'","",.)
replace newschnamecode = subinstr(newschnamecode, ".","",.)
duplicates drop newschnamecode, force
sort newschname
save "$MS/SchIDs_2024", replace


use "$MS/2024_Districts_Schools", clear
gen newdistname = Entity
gen newschname = Entity
replace newdistname = subinstr(newdistname, "Desoto", "DeSoto",.)
replace newdistname = subinstr(newdistname, "County", "Co",.)

replace newschname = subinstr(newschname, "Elementary", "Elem",.)
replace newschname = subinstr(newschname, " Jr "," Junior ",.)
replace newschname = subinstr(newschname, "County", "Co",.)
replace newschname = newschname + " School" if strpos(newschname, "School") == 0 & strpos(newschname, "Sch") == 0
replace newschname = subinstr(newschname, " Sch", " School",.) if strpos(newschname, "School") == 0
gen newschnamecode = subinstr(newschname, " ", "",.)
replace newschnamecode = lower(newschnamecode)
replace newschnamecode = subinstr(newschnamecode, "-", "",.)
replace newschnamecode = subinstr(newschnamecode, "'","",.)
replace newschnamecode = subinstr(newschnamecode, ".","",.)
duplicates drop newschnamecode, force


merge 1:1 newdistname using "$MS/DistIDs_2024", gen(DistIDMerge)
drop if DistIDMerge == 2
merge 1:1 newschnamecode using "$MS/SchIDs_2024", update gen(SchIDMerge)
drop if SchIDMerge == 2
drop *Merge
gen ReadyForMerge = "True" if !missing(NCESDistrictID) | !missing(NCESSchoolID)
replace ReadyForMerge = "False" if missing(ReadyForMerge)
order ReadyForMerge
export excel "$MS/2024_District_School_IDS.xlsx", replace firstrow(variables)


//Merging in with IDs
merge m:1 Entity using "${MS}/2024_District_School_IDS", nogen
replace Keep = "False" if Entity == "Dubard School For Language Disorders" //Not in any NCES files
drop if Keep == "False"
drop Keep
*/


//NCES Merging
merge m:1 NCESDistrictID using "$NCES/NCES_2022_District", nogen keep(match master)
merge m:1 NCESSchoolID using "$NCES/NCES_2022_School", nogen keep(match master)

drop if missing(NCESDistrictID) & DataLevel != "State"
drop if missing(NCESSchoolID) & DataLevel == "School"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
drop DataLevel
rename DataLevel_n DataLevel
sort DataLevel

replace DistName = Entity if DataLevel == 2
replace SchName = Entity if DataLevel == 3
replace SchName = "All Schools" if DataLevel == 2

** DistNames for all data

merge m:1 NCESDistrictID using "${MS}/standarddistnames"
drop if _merge == 2
drop _merge
drop olddistname
replace DistName = newdistname if !missing(newdistname)
drop newdistname

//Variable Management
order State StateAbbrev StateFips DataLevel DistName SchName NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel

//StateAssignedDistID & StateAssignedSchID
gen StateAssignedDistID = subinstr(State_leaid, "MS-","",.)
gen StateAssignedSchID = substr(seasch,strpos(seasch, "-") +1,10)
drop State_leaid seasch

** Combining State and District/School Level Data
append using "$raw/MS_AssmtData_2024_State"
sort DataLevel

//Indicator & missing Variables
replace State = "Mississippi"
replace StateAbbrev = "MS"
replace StateFips = 28

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1

gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

gen SchYear = "2023-24"

gen AssmtType = "Regular"

gen AssmtName = "MAAP"

gen ProficiencyCriteria = "Levels 4-5"

gen ParticipationRate = "--"

replace AvgScaleScore = "--" if missing(AvgScaleScore)

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

drop if regexm(StudentSubGroup_TotalTested,"[0-9]") ==0 & regexm(StudentSubGroup_TotalTested, "[*-]") == 0


** Manually Fixing new 2024 schools
replace SchType = 1 if NCESSchoolID == "280087001607"
replace SchLevel = 4 if NCESSchoolID == "280087001607"
replace SchVirtual = 0 if NCESSchoolID == "280087001607"
replace StateAssignedSchID = "0700016" if NCESSchoolID == "280087001607"

replace SchType = 1 if NCESSchoolID == "280246001610"
replace SchLevel = 1 if NCESSchoolID == "280246001610"
replace SchVirtual = 0 if NCESSchoolID == "280246001610"
replace StateAssignedSchID = "3420050" if NCESSchoolID == "280246001610"


replace SchType = 1 if NCESSchoolID == "280291001612"
replace SchLevel = 1 if NCESSchoolID == "280291001612"
replace SchVirtual = 0 if NCESSchoolID == "280291001612"
replace StateAssignedSchID = "3820003" if NCESSchoolID  == "280291001612"


replace SchType = 1 if NCESSchoolID == "280309001159"
replace SchLevel = 2 if NCESSchoolID == "280309001159"
replace SchVirtual = 0 if NCESSchoolID == "280309001159"
replace StateAssignedSchID = "4111006" if NCESSchoolID == "280309001159"


replace SchType = 1 if NCESSchoolID == "280018501409"
replace SchLevel = 1 if NCESSchoolID == "280018501409"
replace SchVirtual = 0 if NCESSchoolID == "280018501409"
replace StateAssignedSchID = "0618014" if NCESSchoolID == "280018501409"

replace SchType = 1 if NCESSchoolID == "280222001609"
replace SchLevel = 2 if NCESSchoolID == "280222001609"
replace SchVirtual = 0 if NCESSchoolID == "280222001609"
replace StateAssignedSchID = "3200002" if NCESSchoolID == "280222001609"

replace SchType = 1 if NCESSchoolID == "280018501419"
replace SchLevel = 3 if NCESSchoolID == "280018501419"
replace SchVirtual = 0 if NCESSchoolID == "280018501419"
replace StateAssignedSchID = "0618018" if NCESSchoolID == "280018501419"

replace SchVirtual = 0 if NCESSchoolID == "280291000559"
replace SchLevel = 1 if NCESSchoolID == "280291000559"

** Getting rid of ranges where high and low ranges are the same
foreach var of varlist *_count *_percent {
replace `var' = substr(`var',1, strpos(`var', "-")-1) if real(substr(`var',1, strpos(`var', "-")-1)) == real(substr(`var', strpos(`var', "-")+1,10)) & strpos(`var', "-") !=0 & regexm(`var', "[0-9]") !=0
}


//Derivations

**Deriving Count if we have all other counts

replace Lev1_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev1_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) > 0

replace Lev2_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev1_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev1_count)) & missing(real(Lev2_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev1_count)) > 0

replace Lev3_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev1_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & missing(real(Lev3_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev1_count)-real(Lev2_count)) > 0

replace Lev4_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev1_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev1_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev4_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev1_count)-real(Lev3_count)-real(Lev2_count)) > 0

replace Lev5_count = string(real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev1_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev5_count)) & (real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) > 0

** Deriving Percents if we have all other percents
replace Lev1_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)

replace Lev2_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent) > 0.005)

replace Lev3_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent) > 0.005)

replace Lev4_percent = string(1-real(Lev5_percent)-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))  & (1-real(Lev5_percent)-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)

replace Lev5_percent = string(1-real(Lev1_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev5_percent))  & (1-real(Lev1_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)


//Final Cleaning
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


save "$output/MS_AssmtData_2024.dta", replace
export delimited "$output/csv/MS_AssmtData_2024.csv", replace







