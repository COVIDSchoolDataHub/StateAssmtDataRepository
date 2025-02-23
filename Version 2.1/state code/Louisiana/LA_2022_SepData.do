*******************************************************
* LOUISIANA

* File name: LA_2022_SepData
* Last update: 2/18/2025

*******************************************************
* Notes

	* This do file 
	* a) imports LA's 2022 data (soc, sci, ela and math), reshapes it and saves as *.dta.  
	* b) cleans LA's 2022 data
	* c) merges with NCES School (2014, 2016, 2021), NCES District (2021) and LA_unmerged. 

*******************************************************

clear

////Uncomment only for first run.
** 2021-22 Proficiency Data
import excel "$Original/LA_OriginalData_2022.xlsx", sheet("2022 LEAP SUPPRESSED") cellrange(A3:BE140673) firstrow allstring clear

rename ELA AvgScaleScoreela
rename Math AvgScaleScoremath
rename Science AvgScaleScoresci
rename SocialStudies AvgScaleScoresoc

rename TotalStudentTested StudentSubGroup_TotalTestedela
rename Advanced Lev5_countela
rename P Lev5_percentela
rename Mastery Lev4_countela
rename R Lev4_percentela
rename Basic Lev3_countela
rename T Lev3_percentela
rename ApproachingBasic Lev2_countela
rename V Lev2_percentela
rename Unsatisfactory Lev1_countela
rename X Lev1_percentela

rename Y StudentSubGroup_TotalTestedmath
rename Z Lev5_countmath
rename AA Lev5_percentmath
rename AB Lev4_countmath
rename AC Lev4_percentmath
rename AD Lev3_countmath
rename AE Lev3_percentmath
rename AF Lev2_countmath
rename AG Lev2_percentmath
rename AH Lev1_countmath
rename AI Lev1_percentmath

rename AJ StudentSubGroup_TotalTestedsci
rename AK Lev5_countsci
rename AL Lev5_percentsci
rename AM Lev4_countsci
rename AN Lev4_percentsci
rename AO Lev3_countsci
rename AP Lev3_percentsci
rename AQ Lev2_countsci
rename AR Lev2_percentsci
rename AS Lev1_countsci
rename AT Lev1_percentsci

rename AU StudentSubGroup_TotalTestedsoc
rename AV Lev5_countsoc
rename AW Lev5_percentsoc
rename AX Lev4_countsoc
rename AY Lev4_percentsoc
rename AZ Lev3_countsoc
rename BA Lev3_percentsoc
rename BB Lev2_countsoc
rename BC Lev2_percentsoc
rename BD Lev1_countsoc
rename BE Lev1_percentsoc

gen DataLevel = "School"
replace DataLevel = "District" if SchoolName == ""
replace DataLevel = "State" if SchoolSystemName == "Louisiana Statewide"

** Reshape Wide to Long

generate id = _n
reshape long Lev1_percent Lev1_count Lev2_percent Lev2_count Lev3_percent Lev3_count Lev4_percent Lev4_count Lev5_percent Lev5_count StudentSubGroup_TotalTested AvgScaleScore, i(id) j(Subject, string)
drop id
drop if StudentSubGroup_TotalTested == ""
drop if SchoolSystemCode == "" & DataLevel != "State"

save "${Temp}/2022_all_subjects.dta", replace

********************************
*Cleaning
********************************
use "${Temp}/2022_all_subjects.dta", clear

** Keep only regular assessment
drop if InnovativeAssessmentProgram == "Y"

** Rename Variables
rename SchoolSystemCode StateAssignedDistID
rename SchoolSystemName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName
rename Grade GradeLevel

// Fix GradeLevel values
replace GradeLevel = "G" + GradeLevel

// Generating Student Group Counts
save "$Temp/LA_2022_nogroup.dta", replace
keep if Subgroup=="Total Population"
keep DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested StudentGroup_TotalTested
save "$Temp/LA_2022_group.dta", replace
clear
use "$Temp/LA_2022_nogroup.dta"
merge m:1 DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel using "$Temp/LA_2022_group.dta"
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
gen Flag_CutScoreChange_soc = "N"
gen SchYear = "2021-22"
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

gen StudentGroup = ""

replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged"

replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Economically Disadvantaged"

replace StudentGroup = "Disability Status" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"

replace StudentGroup = "Disability Status" if StudentSubGroup == "Regular Education"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Regular Education"

replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or more races"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

replace StudentGroup = "RaceEth" if StudentSubGroup == "White"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"

replace StudentGroup = "EL Status" if StudentSubGroup == "Not English Learner"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not English Learner"

replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"

replace StudentGroup = "Migrant Status" if StudentSubGroup == "Not Migrant"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"

replace StudentGroup = "All Students" if StudentSubGroup == "Total Population"
replace StudentSubGroup = "All Students" if StudentSubGroup == "Total Population"

replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military Affiliated"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Affiliated"

replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Not Military Affiliated"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not Military Affiliated"

replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"

replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Not Foster Care"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not Foster Care"

replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"

replace StudentGroup = "Homeless Enrollled Status" if StudentSubGroup == "Not Homeless"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Homeless"

replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"

keep if StudentGroup == "Economic Status" | StudentGroup == "Disability Status" | StudentGroup == "RaceEth" | StudentGroup == "Migrant Status" | StudentGroup == "All Students" | StudentGroup == "EL Status" | StudentGroup == "Gender" | StudentGroup == "Military Connected Status" | StudentGroup == "Foster Care Status" | StudentGroup == "Homeless Enrolled Status"

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

save "$Temp/2022_preNCES.dta", replace

// Merging with list of ids for unmerged schools
import excel "$Original/LA_unmerged.xlsx", sheet("Sheet1") firstrow clear

keep if strpos(KeepDrop, "Keep") != 0
keep if SchYear == "2021-22"
tostring NCESDistrictIDOLD, replace format(%12.0f) force
replace NCESDistrictIDNEW = NCESDistrictIDOLD if NCESDistrictIDNEW == ""
keep State_leaid DataLevel seasch StateAssignedDistID DistName StateAssignedSchID SchName SchYear NCESDistrictIDNEW NCESSchoolID

tostring NCESSchoolID, replace format(%12.0f)
replace NCESSchoolID = "" if NCESSchoolID == "."
rename NCESDistrictIDNEW NCESDistrictID
tostring NCESDistrictID, replace format(%12.0f)
replace NCESDistrictID = "" if NCESDistrictID == "."
rename DistNameCurrent DistName

merge 1:m State_leaid DataLevel seasch StateAssignedDistID DistName StateAssignedSchID SchName SchYear using "${Temp}/2022_preNCES.dta", nogenerate

//Fixing Empty DistNames 
rename DistName DistName1

save "$Temp/2022_preNCES.dta", replace

// NCES school merging for originally unmerged obs
append using "$NCES_School/NCES_2014_School.dta"
keep if ncesschoolid == "220015401800"

append using "$NCES_School/NCES_2016_School.dta"
keep if ncesschoolid == "220015401800" | ncesschoolid == "220117002430"

append using "$NCES_School/NCES_2021_School.dta"

keep state_location state_fips_id district_agency_type SchType_str ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel_str SchVirtual_str DistLocale county_name lea_name DistName1

keep if state_fips_id == 22

rename lea_name DistName
rename state_leaid State_leaid
rename SchType_str SchType
rename SchLevel_str SchLevel
rename SchVirtual_str SchVirtual
rename ncesschoolid NCESSchoolID

save "$NCES_LA/NCES_2021_School_LA.dta", replace

merge 1:m NCESSchoolID using "${Temp}/2022_preNCES.dta", keep(match using) nogenerate
save "$Temp/2022_preNCES.dta", replace

// NCES school merging for other obs

use "$NCES_LA/NCES_2021_School_LA.dta", clear
merge 1:m seasch using "${Temp}/2022_preNCES.dta"
keep if _merge == 3 | DataLevel == "District" | DataLevel == "State" | NCESSchoolID == "220015401800" | NCESSchoolID == "220117002430"
drop _merge
save "$Temp/2022_preNCES.dta", replace

// NCES district merging for originally unmerged obs
use "$NCES_District/NCES_2021_District.dta", clear

keep if state_fips_id == 22

keep state_location state_fips_id district_agency_type ncesdistrictid state_leaid DistCharter DistLocale county_name county_code lea_name

rename lea_name DistName
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
drop if State_leaid == ""

save "$NCES_LA/NCES_2021_District_LA.dta", replace

merge 1:m NCESDistrictID using "$Temp/2022_preNCES.dta", keep(match using) nogenerate
save "$Temp/2022_preNCES.dta", replace

// NCES district merging for other obs
use "$NCES_LA/NCES_2021_District_LA.dta", clear
merge 1:m State_leaid using "$Temp/2022_preNCES.dta"
keep if _merge == 3 | DataLevel == "State"

//Fixing Empty DistNames
replace DistName = DistName1 if missing(DistName)
drop DistName1

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

//Response to Post-Launch Review
replace SchLevel = "Primary" if NCESSchoolID == "220009002530"
replace SchVirtual = "No" if NCESSchoolID == "220009002530"
foreach var of varlist StudentGroup_TotalTested StudentSubGroup_TotalTested {
	replace `var' = "0-9" if `var' == "<10"
}

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

replace ProficientOrAbove_count = "0" if ProficientOrAbove_count == "-1"

replace ProficientOrAbove_percent = "0" if real(ProficientOrAbove_percent) < 0 | strpos(ProficientOrAbove_percent, "e") !=0

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
save "${Output_ND}/LA_AssmtData2022_NoDev", replace //If .dta format needed.
export delimited "${Output_ND}/LA_AssmtData2022_NoDev", replace 

*Derivations*
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

replace ProficientOrAbove_count = "0" if ProficientOrAbove_count == "-1"
replace ProficientOrAbove_percent = "0" if real(ProficientOrAbove_percent) < 0 | strpos(ProficientOrAbove_percent, "e") !=0

//Keeping, ordering and sorting variables
keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output with derivations*
save "$Output/LA_AssmtData_2022.dta", replace
export delimited using "$Output/LA_AssmtData_2022.csv", replace
* END of LA_2022_SepData.do
****************************************************
