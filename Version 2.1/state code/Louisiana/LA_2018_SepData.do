*******************************************************
* LOUISIANA

* File name: LA_2018_SepData
* Last update: 2/18/2025

*******************************************************
* Notes

	* This do file 
	* a) imports LA's 2018 data (soc, sci, ela and math), reshapes it and saves as *.dta.  
	* b) cleans LA's 2018 data
	* c) merges with NCES School (2014, 2016, 2017, 2020), NCES District (2015, 2016, 2017, 2020) and LA_unmerged. 

*******************************************************

clear

//Uncomment only for first run.
** 2017-18 Proficiency Data
import excel "$Original/LA_OriginalData_2018.xlsx", sheet("2018 LEAP SUPPRESSED") cellrange(A3:AS114147) firstrow allstring clear

rename ELA AvgScaleScoreela
rename Math AvgScaleScoremath
rename SocialStudies AvgScaleScoresoc

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

rename AI StudentSubGroup_TotalTestedsoc
rename AJ Lev5_countsoc
rename AK Lev5_percentsoc
rename AL Lev4_countsoc
rename AM Lev4_percentsoc
rename AN Lev3_countsoc
rename AO Lev3_percentsoc
rename AP Lev2_countsoc
rename AQ Lev2_percentsoc
rename AR Lev1_countsoc
rename AS Lev1_percentsoc

rename SummaryLevel DataLevel
replace DataLevel = "District" if DataLevel == "School System"

** Reshape Wide to Long

generate id = _n
reshape long Lev1_percent Lev1_count Lev2_percent Lev2_count Lev3_percent Lev3_count Lev4_percent Lev4_count Lev5_percent Lev5_count StudentSubGroup_TotalTested AvgScaleScore, i(id) j(Subject, string)
drop id
drop if StudentSubGroup_TotalTested == ""
drop if SchoolSystemCode == "" & DataLevel != "State"

save "${Temp}/2018_all_subjects.dta", replace

********************************
*Cleaning
********************************

use "${Temp}/2018_all_subjects.dta", clear

** Rename Variables

rename SchoolSystemCode StateAssignedDistID
rename SchoolSystemName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName
rename Grade GradeLevel
rename Group StudentGroup

// Fix GradeLevel values

replace GradeLevel = "G0" + GradeLevel

// Generating Student Group Counts
save "$Temp/LA_2018_nogroup.dta", replace
keep if StudentGroup=="Total Population"
keep DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested StudentGroup_TotalTested
save "$Temp/LA_2018_group.dta", replace
clear
use "$Temp/LA_2018_nogroup.dta"
merge m:1 DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel using "$Temp/LA_2018_group.dta"
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
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Not applicable"
gen Flag_CutScoreChange_soc = "N"
gen SchYear = "2017-18"
gen AssmtName = "LEAP 2025"
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
rename Subgroup StudentSubGroup

replace StudentGroup = "Economic Status" if StudentGroup == "Economically Disadvantaged"
replace StudentGroup = "Disability Status" if StudentGroup == "Education Classification"
replace StudentGroup = "RaceEth" if StudentGroup == "Ethnicity "
replace StudentGroup = "EL Status" if StudentGroup == "English Learner"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "All Students" if StudentGroup == "Total Population"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Affiliation"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Care"
keep if StudentGroup == "Economic Status" | StudentGroup == "Disability Status" | StudentGroup == "RaceEth" | StudentGroup == "Migrant Status" | StudentGroup == "All Students" | StudentGroup == "EL Status" | StudentGroup == "Gender" | StudentGroup == "Military Connected Status" | StudentGroup == "Foster Care Status"

replace StudentSubGroup = "All Students" if StudentGroup == "All Students"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disability"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Regular Education"
drop if StudentSubGroup == "Regular Education and Section 504 - No" | StudentSubGroup == "Regular Education and Section 504 - Yes"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Yes" & StudentGroup == "EL Status"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "No" & StudentGroup == "EL Status"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Yes" & StudentGroup == "Economic Status"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "No" & StudentGroup == "Economic Status"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Yes" & StudentGroup == "Migrant Status"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "No" & StudentGroup == "Migrant Status"
drop if StudentSubGroup == "Invalid"

replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Yes" & StudentGroup == "Foster Care Status"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "No" & StudentGroup == "Foster Care Status"
replace StudentSubGroup = "Military" if StudentSubGroup == "Yes" & StudentGroup == "Military Connected Status"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "No" & StudentGroup == "Military Connected Status"

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

gen State_leaid = "LA-" + StateAssignedDistID if DataLevel != "State"
//replace StateAssignedSchID = StateAssignedDistID + StateAssignedSchID
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == "School"

save "$Temp/2018_preNCES.dta", replace

// Merging with list of ids for unmerged schools

import excel "$Original/LA_unmerged.xlsx", sheet("Sheet1") firstrow clear

keep if strpos(KeepDrop, "Keep") != 0
keep if SchYear == "2017-18"
tostring NCESDistrictIDOLD, replace format(%12.0f) force
replace NCESDistrictIDNEW = NCESDistrictIDOLD if NCESDistrictIDNEW == ""
keep State_leaid DataLevel seasch StateAssignedDistID DistName StateAssignedSchID SchName SchYear NCESDistrictIDNEW NCESSchoolID

tostring NCESSchoolID, replace format(%12.0f)
replace NCESSchoolID = "" if NCESSchoolID == "."
rename NCESDistrictIDNEW NCESDistrictID
tostring NCESDistrictID, replace format(%12.0f)
replace NCESDistrictID = "" if NCESDistrictID == "."
rename DistNameCurrent DistName

merge 1:m State_leaid DataLevel seasch StateAssignedDistID DistName StateAssignedSchID SchName SchYear using "${Temp}/2018_preNCES.dta", nogenerate

drop DistName

save "$Temp/2018_preNCES.dta", replace

// NCES school merging for originally unmerged obs
use "$NCES_School/NCES_2020_School.dta",clear 
keep if ncesschoolid == "220032302496"

append using "$NCES_School/NCES_2014_School.dta"
keep if ncesschoolid == "220032302496" | ncesschoolid == "220015401800"

append using "$NCES_School/NCES_2016_School.dta"
keep if ncesschoolid == "220032302496" | ncesschoolid == "220015401800" | ncesschoolid == "220117002430"

append using "$NCES_School/NCES_2017_School.dta"

keep state_location state_fips_id district_agency_type SchType_str ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel_str SchVirtual_str DistLocale county_name county_code lea_name

keep if state_fips_id == 22

rename lea_name DistName
rename state_leaid State_leaid
rename SchType_str SchType
rename SchLevel_str SchLevel
rename SchVirtual_str SchVirtual
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID

save "$NCES_LA/NCES_2017_School_LA", replace

merge 1:m NCESSchoolID using "${Temp}/2018_preNCES.dta", keep(match using) nogenerate
save "$Temp/2018_preNCES.dta", replace

// NCES school merging for other obs

use "$NCES_LA/NCES_2017_School_LA.dta", clear 
merge 1:m seasch using "${Temp}/2018_preNCES.dta"

keep if _merge == 3 | DataLevel == "District" | DataLevel == "State" | NCESSchoolID == "220032302496" | NCESSchoolID == "220015401800" | NCESSchoolID == "220117002430"

drop _merge

save "$Temp/2018_preNCES.dta", replace

// NCES district merging for originally unmerged obs

use "$NCES_District/NCES_2020_District.dta", clear
keep if ncesdistrictid == "2200323"

append using "$NCES_District/NCES_2015_District.dta"
keep if ncesdistrictid == "2200323" | ncesdistrictid == "2200154"

append using "$NCES_District/NCES_2017_District.dta"

keep state_location state_fips_id district_agency_type ncesdistrictid state_leaid DistCharter DistLocale county_name county_code lea_name

keep if state_fips_id == 22
drop if ncesdistrictid == ""

rename lea_name DistName
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
drop if State_leaid == ""

save "$NCES_LA/NCES_2017_District_LA", replace

merge 1:m NCESDistrictID using "$Temp/2018_preNCES.dta", keep(match using) nogenerate
save "$Temp/2018_preNCES.dta", replace

// NCES district merging for other obs
use "$NCES_LA/NCES_2017_District_LA", clear
merge 1:m State_leaid using "$Temp/2018_preNCES.dta"

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


destring StudentSubGroup_TotalTested, gen(UnsuppressedSSG) force
egen UnsuppressedSG = sum(UnsuppressedSSG), by(DataLevel NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup)
replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested) - UnsuppressedSG) if StudentGroup != "RaceEth" & strpos(StudentSubGroup_TotalTested, "<") !=0 & UnsuppressedSG !=0 & (real(StudentGroup_TotalTested)-UnsuppressedSG > 0)

**Deriving ProficientOrAbove_count and percent if we have Levels 1-3
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count) - real(Lev3_count)) if strpos(StudentSubGroup_TotalTested, "-") ==0 & regexm(Lev1_count, "[*-]") == 0 & regexm(Lev2_count, "[*-]") == 0 & regexm(Lev3_count, "[*-]") == 0
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent) - real(Lev3_percent), "%9.3g") if regexm(Lev1_percent, "[*-]") == 0 & regexm(Lev2_percent, "[*-]") == 0 & regexm(Lev3_percent, "[*-]") == 0

** Fixing & Standardizing ranges (Updated 8/18/24)
foreach var of varlist StudentGroup_TotalTested StudentSubGroup_TotalTested {
	replace `var' = "0-9" if `var' == "<10"
}
foreach count of varlist ProficientOrAbove_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = subinstr(`count', substr(`count',strpos(`count',"-")+1,10), substr(StudentSubGroup_TotalTested,strpos(StudentSubGroup_TotalTested,"-")+1,10),.) if real(substr(`count',strpos(`count',"-")+1,10)) > real(substr(StudentSubGroup_TotalTested, strpos(StudentSubGroup_TotalTested,"-")+1,10))
	replace `percent' = subinstr(`percent', substr(`percent', strpos(`percent',"-")+1,10),"1",.) if real(substr(`percent', strpos(`percent',"-")+1,10)) > 1
}

replace ProficientOrAbove_percent = "0" if real(ProficientOrAbove_percent) < 0 | strpos(ProficientOrAbove_percent, "e") !=0

replace ProficientOrAbove_count = "0" if ProficientOrAbove_count == "-1"

// Reordering variables and sorting data
local vars State StateAbbrev StateFips SchYear DataLevel DistName DistType 	///
    SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID 		///
    StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual 			///
    CountyName CountyCode AssmtName AssmtType Subject GradeLevel 			///
    StudentGroup StudentGroup_TotalTested StudentSubGroup 					///
    StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count 			///
    Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent 			///
    Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria 				///
    ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 	///
    Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math 	///
    Flag_CutScoreChange_sci Flag_CutScoreChange_soc
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// *Exporting into a separate folder Output for Stanford - without derivations*
save "${Output_ND}/LA_AssmtData2018_NoDev", replace //If .dta format needed.
export delimited "${Output_ND}/LA_AssmtData2018_NoDev", replace 

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

//Keeping, ordering and sorting variables
keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output with derivations*
save "$Output/LA_AssmtData_2018.dta", replace
export delimited using "$Output/LA_AssmtData_2018.csv", replace
* END of LA_2018_SepData.do
****************************************************
