clear

// Define file paths

global original_files "/Volumes/T7/State Test Project/Louisiana Post Launch/Original"
global NCES_files "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global output_files "/Volumes/T7/State Test Project/Louisiana Post Launch/Output"
global temp_files "/Volumes/T7/State Test Project/Louisiana Post Launch/Temp"

/*
** 2015-16 Proficiency Data

import excel "${original_files}/LA_OriginalData_2016.xlsx", sheet("2016 LEAP SUPPRESSED SCI") cellrange(A2) firstrow allstring clear
rename NumberofStudents StudentSubGroup_TotalTestedsci
rename Average*ScaledScore AvgScaleScoresci
rename Advanced Lev5_countsci
rename P Lev5_percentsci
rename Mastery Lev4_countsci
rename R Lev4_percentsci
rename Basic Lev3_countsci
rename T Lev3_percentsci
rename ApproachingBasic Lev2_countsci
rename V Lev2_percentsci
rename Unsatisfactory Lev1_countsci
rename X Lev1_percentsci
drop Subject
rename Subgroup StudentSubGroup
rename Summary DataLevel
replace DistrictCode = "" if DistrictCode == "≤"
save "${temp_files}/2016_sci.dta", replace

import excel "${original_files}/LA_OriginalData_2016.xlsx", sheet("Sci Totals") cellrange(A2) firstrow allstring clear
rename NumberofStudents StudentSubGroup_TotalTestedsci
rename Average*ScaledScore AvgScaleScoresci
rename NumberADVANCED Lev5_countsci
rename PercentADVANCED Lev5_percentsci
rename NumberMASTERY Lev4_countsci
rename PercentMASTERY Lev4_percentsci
rename NumberBASIC Lev3_countsci
rename PercentBASIC Lev3_percentsci
rename NumberAPPROACHINGBASIC Lev2_countsci
rename PercentAPPROACHINGBASIC Lev2_percentsci
rename NumberUNSATISFACTORY Lev1_countsci
rename PercentUNSATISFACTORY Lev1_percentsci
drop Subject
rename Subgroup StudentSubGroup
rename Summary DataLevel
replace DistrictCode = "" if DistrictCode == "≤"
drop Percent*
drop Year
replace StudentSubGroup_TotalTestedsci
append using "${temp_files}/2016_sci.dta"
save "${temp_files}/2016_sci.dta", replace

import excel "${original_files}/LA_OriginalData_2016.xlsx", sheet("2016 LEAP SUPPRESSED ELA_MATH") cellrange(A3) firstrow allstring clear

rename AverageELAScaleScore AvgScaleScoreela
rename AverageMathScaleScore AvgScaleScoremath

rename TotalStudentTested StudentSubGroup_TotalTestedela
rename Advanced Lev5_countela
rename O Lev5_percentela
rename Mastery Lev4_countela
rename Q Lev4_percentela
rename Basic Lev3_countela
rename S Lev3_percentela
rename ApproachingBasic Lev2_countela
rename U Lev2_percentela
rename Unsatisfactory Lev1_countela
rename W Lev1_percentela

rename X StudentSubGroup_TotalTestedmath
rename Y Lev5_countmath
rename Z Lev5_percentmath
rename AA Lev4_countmath
rename AB Lev4_percentmath
rename AC Lev3_countmath
rename AD Lev3_percentmath
rename AE Lev2_countmath
rename AF Lev2_percentmath
rename AG Lev1_countmath
rename AH Lev1_percentmath
rename SubGroup StudentSubGroup

drop SummaryLevel
gen DataLevel = "District" if SchoolCode == ""
replace DataLevel = "School" if DataLevel == ""
replace DataLevel = "State" if DistrictCode == ""

append using "${temp_files}/2016_sci.dta"

** Reshape Wide to Long

generate id = _n
reshape long Lev1_percent Lev1_count Lev2_percent Lev2_count Lev3_percent Lev3_count Lev4_percent Lev4_count Lev5_percent Lev5_count StudentSubGroup_TotalTested AvgScaleScore, i(id) j(Subject, string)
drop id
drop if StudentSubGroup_TotalTested == ""
drop if DistrictCode == "" & DataLevel != "State"

save "${temp_files}/2016_all_subjects.dta", replace
*/



use "${temp_files}/2016_all_subjects.dta", clear

** Rename Variables

rename DistrictCode StateAssignedDistID
rename DistrictName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName
rename Grade GradeLevel
rename Group StudentGroup

// Fix GradeLevel values

replace GradeLevel = "0" + GradeLevel if (Subject == "ela" | Subject == "math") & DataLevel == "State" 
replace GradeLevel = "G" + GradeLevel


// Generating Student Group Counts
save "$temp_files/LA_2016_nogroup.dta", replace
keep if Order=="1"
keep DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested StudentGroup_TotalTested
save "$temp_files/LA_2016_group.dta", replace
clear
use "$temp_files/LA_2016_nogroup.dta"
merge m:1 DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel using "$temp_files/LA_2016_group.dta"
drop _merge


//// Use this code if decide to use ranges for StudentGroup_TotalTested
/*
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested_num) force
gen StudentSubGroup_TotalTested_min = StudentSubGroup_TotalTested_num
replace StudentSubGroup_TotalTested_min = 0 if StudentSubGroup_TotalTested == "<10"
bysort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel: egen StudentGroup_TotalTested_min = sum(StudentSubGroup_TotalTested_min)
tostring StudentGroup_TotalTested_min, replace

gen StudentSubGroup_TotalTested_max = StudentSubGroup_TotalTested_num
replace StudentSubGroup_TotalTested_max = 10 if StudentSubGroup_TotalTested == "<10"
bysort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel: egen StudentGroup_TotalTested_max = sum(StudentSubGroup_TotalTested_max)
tostring StudentGroup_TotalTested_max, replace

gen StudentGroup_TotalTested = StudentGroup_TotalTested_min + "-" + StudentGroup_TotalTested_max
replace StudentGroup_TotalTested = StudentGroup_TotalTested_max if StudentGroup_TotalTested_max == StudentGroup_TotalTested_min

drop *max *min
*/

** Generate Flags

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen SchYear = "2015-16"
gen AssmtName = "LEAP"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 4-5"
gen State = "Louisiana"

** Generate Empty Variables

gen ParticipationRate = "--"
replace AvgScaleScore = "*" if AvgScaleScore == ""

** Fix Variable Types

replace Lev1_percent = subinstr(Lev1_percent, " ", "", .)
replace Lev2_percent = subinstr(Lev2_percent, " ", "", .)
replace Lev3_percent = subinstr(Lev3_percent, " ", "", .)
replace Lev4_percent = subinstr(Lev4_percent, " ", "", .)
replace Lev5_percent = subinstr(Lev5_percent, " ", "", .)
replace Lev1_percent = subinstr(Lev1_percent, "%", "", .)
replace Lev2_percent = subinstr(Lev2_percent, "%", "", .)
replace Lev3_percent = subinstr(Lev3_percent, "%", "", .)
replace Lev4_percent = subinstr(Lev4_percent, "%", "", .)
replace Lev5_percent = subinstr(Lev5_percent, "%", "", .)

// Renaming student groups and subgroups

replace StudentGroup = "Economic Status" if StudentGroup == "Economically Disadvantaged"
replace StudentGroup = "Disability Status" if StudentGroup == "Education Classification"
replace StudentGroup = "RaceEth" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "LEP"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "All Students" if StudentGroup == "Total Population"
keep if StudentGroup == "Economic Status" | StudentGroup == "Disability Status" | StudentGroup == "RaceEth" | StudentGroup == "Migrant Status" | StudentGroup == "All Students" | StudentGroup == "EL Status" | StudentGroup == "Gender" 

replace StudentSubGroup = "All Students" if StudentGroup == "All Students"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Special Education"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Total Regular Education Including Section 504" | StudentSubGroup == "TotalRegEd (Section504+RegularEd)"
drop if StudentSubGroup == "Regular Education Without Section 504" | StudentSubGroup == "Regular Education without Section 504" | StudentSubGroup == "Section 504 - Yes" | StudentSubGroup == "Regular Education"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Yes" & StudentGroup == "EL Status"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "No" & StudentGroup == "EL Status"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Yes" & StudentGroup == "Economic Status"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "No" & StudentGroup == "Economic Status"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Yes" & StudentGroup == "Migrant Status"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "No" & StudentGroup == "Migrant Status"
drop if StudentSubGroup == "Invalid"

** Convert Proficiency Data into Percentages

foreach v of varlist Lev*_percent {
	destring `v', g(n`v') i(* -) force
	replace n`v' = n`v' / 100 if n`v' != .
	generate lessthan`v' = 1 if `v'=="<5"
	generate greaterthan`v' = 1 if `v'==">95"
	tostring n`v', replace force format("%9.3g")
	replace `v' = n`v' if `v' != "*"
	replace `v' = "0-.05" if lessthan`v' == 1
	replace `v' = ".95-1" if greaterthan`v' == 1
}


** Generate Proficient or Above Percent

gen Lev4max = Lev4_percent
replace Lev4max = ".05" if Lev4_percent== "0-.05"
replace Lev4max = "1" if Lev4_percent== ".95-1"
destring Lev4max, generate(Lev4maxnumber) force
gen Lev4min = Lev4_percent
replace Lev4min = "0" if Lev4_percent== "0-.05"
replace Lev4min = ".95" if Lev4_percent== ".95-1"
destring Lev4min, generate(Lev4minnumber) force
gen Lev5max = Lev5_percent
replace Lev5max = ".05" if Lev5_percent== "0-.05"
replace Lev5max = "1" if Lev5_percent== ".95-1"
destring Lev5max, generate(Lev5maxnumber) force
gen Lev5min = Lev5_percent
replace Lev5min = "0" if Lev5_percent== "0-.05"
replace Lev5min = ".95" if Lev5_percent== ".95-1"
destring Lev5min, generate(Lev5minnumber) force
gen ProficientOrAbovemin = Lev4minnumber + Lev5minnumber
gen ProficientOrAbovemax = Lev4maxnumber + Lev5maxnumber
tostring ProficientOrAbovemin, replace force format("%9.3g")
tostring ProficientOrAbovemax, replace force format("%9.3g")
gen ProficientOrAbove_percent = ProficientOrAbovemin + "-" + ProficientOrAbovemax
replace ProficientOrAbove_percent = ProficientOrAbovemax if ProficientOrAbovemax == ProficientOrAbovemin
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="."
drop Lev4max Lev4maxnumber Lev4min Lev4minnumber Lev5max Lev5maxnumber Lev5min Lev5minnumber ProficientOrAbovemin ProficientOrAbovemax


** Generate Proficient or Above Count

gen Lev4max = Lev4_count
replace Lev4max = "9" if Lev4_count== "<10"
destring Lev4max, generate(Lev4maxnumber) force
gen Lev4min = Lev4_count
replace Lev4min = "0" if Lev4_count== "<10"
destring Lev4min, generate(Lev4minnumber) force
gen Lev5max = Lev5_count
replace Lev5max = "9" if Lev5_count== "<10"
destring Lev5max, generate(Lev5maxnumber) force
gen Lev5min = Lev5_count
replace Lev5min = "0" if Lev5_count== "<10"
destring Lev5min, generate(Lev5minnumber) force
gen ProficientOrAbovemin = Lev4minnumber + Lev5minnumber
gen ProficientOrAbovemax = Lev4maxnumber + Lev5maxnumber
tostring ProficientOrAbovemin, replace force
tostring ProficientOrAbovemax, replace force
gen ProficientOrAbove_count = ProficientOrAbovemin + "-" + ProficientOrAbovemax
replace ProficientOrAbove_count = ProficientOrAbovemax if ProficientOrAbovemax == ProficientOrAbovemin
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count=="."
replace Lev1_percent = "*" if Lev1_percent=="."
replace Lev2_percent = "*" if Lev2_percent=="."
replace Lev3_percent = "*" if Lev3_percent=="."
replace Lev4_percent = "*" if Lev4_percent=="."
replace Lev5_percent = "*" if Lev5_percent=="."
replace Lev1_count = "*" if Lev1_count==" "
replace Lev2_count = "*" if Lev2_count==" "
replace Lev3_count = "*" if Lev3_count==" "
replace Lev4_count = "*" if Lev4_count==" "
replace Lev5_count = "*" if Lev5_count==" "

// Make counts ranges
foreach v of varlist Lev*_count {
	replace `v' = "0-9" if `v' == "<10"
}

** Generating NCES Variables

gen State_leaid = StateAssignedDistID if DataLevel != "State"
replace StateAssignedSchID = StateAssignedDistID + StateAssignedSchID
gen seasch = StateAssignedSchID if DataLevel == "School"

save "$temp_files/2016_preNCES.dta", replace

// Merging with list of ids for unmerged schools

import excel "$original_files/LA_unmerged.xlsx", sheet("Sheet1") firstrow clear

keep if strpos(KeepDrop, "Keep") != 0
keep if SchYear == "2015-16"
tostring NCESDistrictIDOLD, replace format(%12.0f) force
replace NCESDistrictIDNEW = NCESDistrictIDOLD if NCESDistrictIDNEW == ""
keep State_leaid DataLevel seasch StateAssignedDistID DistName StateAssignedSchID SchName SchYear NCESDistrictIDNEW NCESSchoolID

tostring NCESSchoolID, replace format(%12.0f)
replace NCESSchoolID = "" if NCESSchoolID == "."
rename NCESDistrictIDNEW NCESDistrictID
tostring NCESDistrictID, replace format(%12.0f)
replace NCESDistrictID = "" if NCESDistrictID == "."
rename DistNameCurrent DistName

merge 1:m State_leaid DataLevel seasch StateAssignedDistID DistName StateAssignedSchID SchName SchYear using "${temp_files}/2016_preNCES.dta", nogenerate

drop DistName

save "$temp_files/2016_preNCES.dta", replace

// NCES school merging for originally unmerged obs

use "$NCES_files/NCES_2020_School.dta",clear 
keep if ncesschoolid == "220032302496"

append using "$NCES_files/NCES_2014_School.dta"
keep if ncesschoolid == "220032302496" | ncesschoolid == "220015401800" | ncesschoolid == "220015502018"

append using "$NCES_files/NCES_2017_School.dta"
keep if ncesschoolid == "220028400944" | ncesschoolid == "220032302496" | ncesschoolid == "220015502018" | ncesschoolid == "220015401800"

append using "$NCES_files/NCES_2015_School.dta"

keep state_location state_fips_id district_agency_type SchType_str ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel_str SchVirtual_str DistLocale county_name county_code lea_name

keep if state_fips_id == 22

rename lea_name DistName
rename state_leaid State_leaid
rename SchType_str SchType
rename SchLevel_str SchLevel
rename SchVirtual_str SchVirtual
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID

merge 1:m NCESSchoolID using "${temp_files}/2016_preNCES.dta", keep(match using) nogenerate
save "$temp_files/2016_preNCES.dta", replace

// NCES school merging for other obs

use "$NCES_files/NCES_2015_School.dta", clear 

keep state_location state_fips_id district_agency_type SchType_str ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel_str SchVirtual_str DistLocale county_name county_code lea_name

keep if state_fips_id == 22

rename lea_name DistName
rename state_leaid State_leaid
rename SchType_str SchType
rename SchLevel_str SchLevel
rename SchVirtual_str SchVirtual
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID

merge 1:m seasch using "${temp_files}/2016_preNCES.dta"

keep if _merge == 3 | DataLevel == "District" | DataLevel == "State" | NCESSchoolID == "220028400944" | NCESSchoolID == "220032302496" | NCESSchoolID == "220015502018" | NCESSchoolID == "220015401800"

drop _merge

save "$temp_files/2016_preNCES.dta", replace

// NCES district merging for originally unmerged obs
use "$NCES_files/NCES_2020_District.dta",clear 
keep if ncesdistrictid == "2200323"

append using "$NCES_files/NCES_2017_District.dta"
keep if ncesdistrictid == "2200284" | ncesdistrictid == "2200323" 

append using "$NCES_files/NCES_2015_District.dta"

keep state_location state_fips_id district_agency_type ncesdistrictid state_leaid DistCharter DistLocale county_name county_code lea_name

keep if state_fips_id == 22
drop if ncesdistrictid == ""

rename lea_name DistName
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
drop if State_leaid == ""

merge 1:m NCESDistrictID using "$temp_files/2016_preNCES.dta", keep(match using) nogenerate
save "$temp_files/2016_preNCES.dta", replace

// NCES district merging for other obs
use "$NCES_files/NCES_2015_District.dta", clear

keep state_location state_fips_id district_agency_type ncesdistrictid state_leaid DistCharter DistLocale county_name county_code lea_name

keep if state_fips_id == 22

rename lea_name DistName
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
drop if State_leaid == ""

merge 1:m State_leaid using "$temp_files/2016_preNCES.dta"

keep if _merge == 3 | DataLevel == "State"

// Rename NCES variables
rename district_agency_type DistType
rename state_location StateAbbrev
rename state_fips_id StateFips
rename county_name CountyName
rename county_code CountyCode

// Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

// Fixing missing state data
replace StateAbbrev = "LA" if DataLevel == 1
replace StateFips = 22 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
replace seasch = "" if DataLevel != 3
replace State_leaid = "" if DataLevel == 1

//Post Launch Review Response

// Fixing StudentSubGroup_TotalTested for state level sci data
replace StudentSubGroup_TotalTested = string(real(Lev1_count)+real(Lev2_count)+real(Lev3_count)+real(Lev4_count)+real(Lev5_count)) if DataLevel == 1
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."

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

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & missing_multiple <2

drop Unsuppressed* missing_*

**Deriving ProficientOrAbove_count and percent if we have Levels 1-3
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count) - real(Lev3_count)) if strpos(StudentSubGroup_TotalTested, "-") ==0 & regexm(Lev1_count, "[*-]") == 0 & regexm(Lev2_count, "[*-]") == 0 & regexm(Lev3_count, "[*-]") == 0
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent) - real(Lev3_percent), "%9.3g") if regexm(Lev1_percent, "[*-]") == 0 & regexm(Lev2_percent, "[*-]") == 0 & regexm(Lev3_percent, "[*-]") == 0

**Deriving Exact Counts & Percents Where Possible
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`percent'","percent","count",.)
	replace `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
	replace `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.3g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`percent'))
	
}

** Fixing & Standardizing ranges (Updated 8/18/24)
foreach var of varlist StudentGroup_TotalTested StudentSubGroup_TotalTested {
	replace `var' = "0-9" if `var' == "<10"
}
foreach count of varlist ProficientOrAbove_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = subinstr(`count', substr(`count',strpos(`count',"-")+1,10), substr(StudentSubGroup_TotalTested,strpos(StudentSubGroup_TotalTested,"-")+1,10),.) if real(substr(`count',strpos(`count',"-")+1,10)) > real(substr(StudentSubGroup_TotalTested, strpos(StudentSubGroup_TotalTested,"-")+1,10))
	
	replace `percent' = subinstr(`percent', substr(`percent', strpos(`percent',"-")+1,10),"1",.) if real(substr(`percent', strpos(`percent',"-")+1,10)) > 1
}


**Misc
replace AvgScaleScore = "*" if AvgScaleScore == "NA" | AvgScaleScore == " "

replace ProficientOrAbove_percent = "0" if real(ProficientOrAbove_percent) < 0 | strpos(ProficientOrAbove_percent, "e") !=0

replace StudentSubGroup_TotalTested = "0-9" if StudentSubGroup_TotalTested == "."

replace ProficientOrAbove_count = "0" if ProficientOrAbove_count == "-1"

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

** Export 2015-16 Assessment Data

save "$output_files/LA_AssmtData_2016.dta", replace
export delimited using "$output_files/LA_AssmtData_2016.csv", replace
