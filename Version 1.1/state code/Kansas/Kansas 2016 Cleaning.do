clear
set more off

global raw "/Users/miramehta/Documents/KS State Testing Data/Original Data Files"
global output "/Users/miramehta/Documents/KS State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global EDFacts "/Users/miramehta/Documents/EdFacts"

cd "/Users/miramehta/Documents"

use "${raw}/KS_AssmtData_2016.dta", clear

** Renaming variables

rename Organization SchName
rename PCLevel_One Lev1_percent
rename PCLevel_Two Lev2_percent
rename PCLevel_Three Lev3_percent
rename PCLevel_Four Lev4_percent
rename GroupName StudentSubGroup
rename GradeName GradeLevel
rename Building_Number StateAssignedSchID
rename Org_No StateAssignedDistID
rename program_year SchYear

** Dropping entries

drop if Population == "Accountability"
drop Population

drop if inlist(GradeLevel, "10", "ALL")

drop if SchYear == "2015"

drop if StateAssignedSchID == "District Aggregate" & SchName == "State of Kansas"

drop if StudentSubGroup == "ELL with Disabilities"
drop if StudentSubGroup == "Free Lunch only"
drop if StudentSubGroup == "Reduced Lunch only"
drop if StudentSubGroup == "With Disability"

** Replacing/generating variables

replace SchYear = "2015-16"

replace Subject = strlower(Subject)

replace GradeLevel = "G0" + GradeLevel

gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "District Aggregate"
replace DataLevel = "State" if StateAssignedSchID == "State Aggregate"

gen DistName = SchName
sort StateAssignedDistID DataLevel
replace DistName = DistName[_n-1] if DataLevel == "School"

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

replace StudentSubGroup = strtrim(StudentSubGroup)
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African-American Students"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ELL Students"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free and Reduced Lunch"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-Racial"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-ELL Students"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Self-Paid Lunch only"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with  Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not Disabled"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"

gen StudentSubGroup_TotalTested = "--"

destring PCNotValid, replace
replace PCNotValid = PCNotValid/100

local level 1 2 3 4
foreach a of local level {
	destring Lev`a'_percent, replace
	replace Lev`a'_percent = Lev`a'_percent/100
	replace Lev`a'_percent = Lev`a'_percent/(1 - PCNotValid)
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen AssmtName = "KAP"
gen AssmtType = "Regular"

gen AvgScaleScore = "--"

gen ParticipationRate = 1 - PCNotValid
tostring ParticipationRate, replace format("%9.2g") force
replace ParticipationRate = "--" if inlist(ParticipationRate, "", ".")
drop PCNotValid

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--"
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
tostring ProficientOrAbove_percent, replace format("%9.2g") force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

gen State_leaid = StateAssignedDistID

merge m:1 State_leaid using "${NCES}/NCES_2015_District.dta"

drop if _merge == 1 & DataLevel != 1
drop if _merge == 2
drop _merge

gen seasch = StateAssignedSchID

merge m:1 seasch using "${NCES}/NCES_2015_School.dta"

drop if _merge == 2
drop _merge

replace StateAbbrev = "KS" if DataLevel == 1
replace State = "Kansas" if DataLevel == 1
replace StateFips = 20 if DataLevel == 1

** Merging with EDFacts Datasets

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2016/edfactscount2016districtkansas.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
rename Count Count_n
replace ProficientOrAbove_percent = PctProf if _merge == 3 & inlist(ProficientOrAbove_percent, "--", "*")
drop if _merge == 2
drop stnam _merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2016/edfactscount2016schoolkansas.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
replace Count_n = Count if DataLevel == 3 & _merge == 3
replace ProficientOrAbove_percent = PctProf if _merge == 3 & inlist(ProficientOrAbove_percent, "--", "*")
drop if _merge == 2
drop Count stnam schnam _merge

** Pull in gender subgroup data
preserve
keep SchName StateAssignedSchID StateAssignedDistID DistName DataLevel SchYear State StateAbbrev StateFips NCESDistrictID NCESSchoolID DistType DistCharter DistLocale CountyCode CountyName seasch SchLevel SchVirtual SchType GradeLevel Subject AssmtName AssmtType ProficiencyCriteria 
duplicates drop
expand 2, gen(indicator)
gen StudentSubGroup = "Female"
replace StudentSubGroup = "Male" if indicator == 1
gen StudentGroup = "Gender"
gen StudentSubGroup_TotalTested = "--"
gen AvgScaleScore = "--"
forvalues n = 1/4{
	gen Lev`n'_count = "--"
	gen Lev`n'_percent = .
}
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficientOrAbove_count = "--"
gen ProficientOrAbove_percent = "--"
gen ParticipationRate = "--"

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2016/edfactscount2016districtkansas.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
rename Count Count_n
replace ProficientOrAbove_percent = PctProf if _merge == 3
drop if _merge == 2
drop stnam _merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2016/edfactscount2016schoolkansas.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "0" & string(Count) != "."
replace Count_n = Count if Count != .
replace ProficientOrAbove_percent = PctProf if _merge == 3
drop Count
drop if _merge == 2
drop stnam schnam _merge indicator

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2016/edfactspart2016districtkansas.dta"
replace ParticipationRate = Participation if _merge == 3
drop if _merge == 2
drop stnam _merge Participation

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2016/edfactspart2016schoolkansas.dta"
replace ParticipationRate = Participation if _merge == 3
drop if _merge == 2
drop stnam schnam _merge Participation

save "${raw}/KS_AssmtData_2016_Gender.dta", replace
restore

append using "${raw}/KS_AssmtData_2016_Gender.dta"

** Deriving More SubGroup Counts
bysort State_leaid seasch GradeLevel Subject: egen All = max(Count_n)
bysort State_leaid seasch GradeLevel Subject: egen Econ = sum(Count_n) if StudentGroup == "Economic Status"
bysort State_leaid seasch GradeLevel Subject: egen Disability = sum(Count_n) if StudentGroup == "Disability Status"
replace Count_n = All - Econ if StudentSubGroup == "Not Economically Disadvantaged"
replace Count_n = All - Disability if StudentSubGroup == "Non-SWD"
replace StudentSubGroup_TotalTested = string(Count_n) if inlist(StudentSubGroup, "Not Economically Disadvantaged", "Non-SWD") & Count_n != .

** State counts

preserve
keep if DataLevel == 2
rename Count_n Count
collapse (sum) Count, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "${raw}/KS_AssmtData_2016_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "${raw}/KS_AssmtData_2016_State.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "0" & string(Count) != "."
replace Count_n = Count if Count != .
drop Count
drop if _merge == 2
drop _merge

** Deriving More Proficiency Information
gen ProfPct = ProficientOrAbove_percent
split ProfPct, parse("-")
destring ProfPct1, replace force
destring ProfPct2, replace force
gen ProfCount = round(Count_n * ProfPct1)
gen ProfCount2 = .
replace ProfCount2 = Count_n * ProfPct2 if ProfPct2 != .
tostring ProfCount, replace force
replace ProfCount = ProfCount + "-" + string(round(ProfCount2)) if ProfCount2 != .
replace ProfCount = "--" if inlist(ProfCount, "", ".", ".-.")
replace ProficientOrAbove_count = ProfCount if ProfCount != "--"
replace ProficientOrAbove_count = "--" if StudentSubGroup_TotalTested == "--"

replace Lev3_percent = ProfPct1 - Lev4_percent if Lev3_percent == . & Lev4_percent != .
replace Lev4_percent = ProfPct1 - Lev3_percent if Lev4_percent == . & Lev3_percent != .

forvalues n = 1/4{
	gen Lev`n' = round(Lev`n'_percent * Count_n)
	tostring Lev`n', replace
	replace Lev`n' = "--" if inlist(Lev`n', "", ".")
	replace Lev`n' = "--" if StudentSubGroup_TotalTested == "--"
	replace Lev`n' = "--" if Lev`n'_percent == .
	replace Lev`n'_count = Lev`n'
	drop Lev`n'
	tostring Lev`n'_percent, replace format("%9.2g") force
	replace Lev`n'_percent = "--" if inlist(Lev`n'_percent, "", ".")
}

drop ProfPct ProfPct1 ProfPct2 ProfCount ProfCount2

** StudentGroup_TotalTested
replace Count_n = 0 if Count_n == .
bysort State_leaid seasch StudentGroup GradeLevel Subject: egen test = min(Count_n)
bysort State_leaid seasch StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(Count_n) if test != 0
tostring Count_n, replace force
replace StudentSubGroup_TotalTested = Count_n if Count_n != "0"
tostring Count_n, replace force
replace Count_n = "--" if Count_n == "."
drop Count_n test All Econ Disability
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "--" if inlist(StudentGroup_TotalTested, "", ".")

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = ""
gen Flag_CutScoreChange_soc = ""

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/KS_AssmtData_2016.dta", replace

export delimited using "${output}/KS_AssmtData_2016.csv", replace
