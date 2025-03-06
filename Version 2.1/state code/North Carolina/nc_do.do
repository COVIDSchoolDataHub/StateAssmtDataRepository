*******************************************************
* NORTH CAROLINA 

* File name: nc_do
* Last update: 03/06/2025

*******************************************************
* Notes

	* This do file imports NC's 2014 - 2023 *.csv files and converts it to *.dta files. 
	* The *.dta files are saved to the DTA folder.
	* The files from the DTA folder are then cleaned and processed.
	* The NCES files for the previous year are merged.
	* The do file also replaces the names with Stable Names. 
	
*******************************************************
cap log close
log using north_carolina_cleaning.log, replace 

// COUNTY NAME CHECK IN EARLIER YEARS

// imports all years and converts to dta files 
// local years  "13-14 14-15 15-16 16-17 17-18 18-19 20-21 21-22 22-23"
//
// foreach a in `years' {
// import delimited "$Original/Disag_20`a'_Data.txt", clear
// save "$Original_DTA/NC_OriginalData_`a'", replace	
// }
//


local years1  "13-14 14-15 15-16 16-17 17-18 18-19 20-21 21-22 22-23"
foreach a in `years1' {
	
local prevyear = "20" + substr("`a'", 1, 2)
local current = "20" + substr("`a'", 4, 5)

display "`a'"

use "$Original_DTA/NC_OriginalData_`a'", clear 

rename school_code Code // will need to seprate in district/school
// will need to make datalevel var based off of code
rename name SchName
rename subject Subject
rename grade GradeLevel
rename type AssmtType
rename subgroup StudentSubGroup
rename num_tested StudentSubGroup_TotalTested	

if "`a'" == "22-23" | "`a'" == "21-22" {
rename pct_notprof Lev2_percent
}

if "`a'" == "20-21" | "`a'" == "18-19" |  "`a'" == "17-18" | "`a'" == "16-17" | "`a'" == "15-16" | "`a'" == "14-15" | "`a'" == "13-14"  {
rename pct_l1 Lev1_percent
rename pct_l2 Lev2_percent
}

if "`a'" == "20-21" | "`a'" == "18-19" {
rename pct_notprof Lev2_percent1
replace Lev2_percent = Lev2_percent1 if Lev2_percent == ""
drop Lev2_percent1 
}

if "`a'" == "16-17" | "`a'" == "15-16" | "`a'" == "14-15" | "`a'" == "13-14"  {
rename num_l1 Lev1_count
rename num_l2 Lev2_count
rename num_l3 Lev3_count
rename num_l5 Lev5_count
rename num_l4 Lev4_count
rename num_glp ProficientOrAbove_count
} 

rename pct_l3 Lev3_percent
rename pct_l4 Lev4_percent
rename pct_l5 Lev5_percent
rename pct_glp ProficientOrAbove_percent
rename avg_score AvgScaleScore
drop pct_ccr grade_span

// keeping necessary grades 
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == "03"
replace GradeLevel2 = "G04" if GradeLevel == "04"
replace GradeLevel2 = "G05" if GradeLevel == "05"
replace GradeLevel2 = "G06" if GradeLevel == "06"
replace GradeLevel2 = "G07" if GradeLevel == "07"
replace GradeLevel2 = "G08" if GradeLevel == "08"
replace GradeLevel2 = "G38" if GradeLevel == "GS"

drop if GradeLevel2 == ""
drop GradeLevel
rename GradeLevel2 GradeLevel

// keeping necessary test types
keep if AssmtType == "RG"
replace AssmtType = "Regular" if AssmtType == "RG"

// keeping necessary subjects 
gen Subject2 = ""
replace Subject2 = "math" if Subject == "MA"
replace Subject2 = "ela" if Subject == "RD"
replace Subject2 = "sci" if Subject == "SC"
drop if Subject2 == ""
drop Subject
rename Subject2 Subject

// keeping necessary subroups 

gen StudentSubGroup2 = ""
replace StudentSubGroup2 = "All Students" if StudentSubGroup == "ALL"
replace StudentSubGroup2 = "American Indian or Alaska Native" if StudentSubGroup == "AMIN"
replace StudentSubGroup2 = "Asian" if StudentSubGroup == "ASIA"
replace StudentSubGroup2 = "Black or African American" if StudentSubGroup == "BLCK"
replace StudentSubGroup2 = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "PACI"
replace StudentSubGroup2 = "Two or More" if StudentSubGroup == "MULT"
replace StudentSubGroup2 = "Hispanic or Latino" if StudentSubGroup == "HISP"
replace StudentSubGroup2 = "White" if StudentSubGroup == "WHTE"

display "El Early"
if "`a'" == "13-14" | "`a'" == "14-15" | "`a'" == "15-16" | "`a'" == "16-17" {
replace StudentSubGroup2 = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup2 = "English Proficient" if StudentSubGroup== "NOT_LEP"
}

display "El Late"
replace StudentSubGroup2 = "English Learner" if StudentSubGroup == "ELS"
replace StudentSubGroup2 = "English Proficient" if StudentSubGroup == "NOT_ELS"

replace StudentSubGroup2 = "Economically Disadvantaged" if StudentSubGroup == "EDS"
replace StudentSubGroup2 = "Not Economically Disadvantaged" if StudentSubGroup== "NOT_EDS"

replace StudentSubGroup2 = "Male" if StudentSubGroup == "MALE"
replace StudentSubGroup2 = "Female" if StudentSubGroup == "FEM"

display "Homeless"
replace StudentSubGroup2 = "Homeless" if StudentSubGroup == "HMS"
replace StudentSubGroup2 = "Non-Homeless" if StudentSubGroup == "NOT_HMS"
display "Military"
replace StudentSubGroup2 = "Military" if StudentSubGroup == "MIL"
replace StudentSubGroup2 = "Non-Military" if StudentSubGroup == "NOT_MIL"
display "Migrant"
replace StudentSubGroup2 = "Migrant" if StudentSubGroup == "MIG"
replace StudentSubGroup2 = "Non-Migrant" if StudentSubGroup == "NOT_MIG"
display "SWD"
replace StudentSubGroup2 = "SWD" if StudentSubGroup == "SWD"
replace StudentSubGroup2 = "Non-SWD" if StudentSubGroup == "NOT_SWD"
display "Foster Care"
replace StudentSubGroup2 = "Foster Care" if StudentSubGroup == "FCS"
replace StudentSubGroup2 = "Non-Foster Care" if StudentSubGroup == "NOT_FCS"

drop if StudentSubGroup2 == ""
drop StudentSubGroup
rename StudentSubGroup2 StudentSubGroup

// creating student groups 
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"

replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"


replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"

replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless" 
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military" 
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"

// proficiency level 
gen ProficiencyCriteria = "Levels 3-5" // THIS WILL DIFF FOR PRIOR TO 2021/19 DEPENDING ON SUBJECT

// split CODE into district piece, and school piece 

gen StateAssignedDistID = ""
replace StateAssignedDistID = Code if strpos(Code, "LEA") > 0

// remove LEA piece from stateassigneddistrictID 

replace StateAssignedDistID = subinstr(StateAssignedDistID, "LEA", "", .)

// drop entries which are "regions" by datalevel 
drop if regexm(Code, "^NC-SB")

// create datalevel funciton based on codes 
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedDistID != ""
replace DataLevel = "State" if Code == "NC-SEA"

replace Code = "" if DataLevel == "District" | DataLevel == "State"

replace StateAssignedDistID = substr(Code, 1, 3) if DataLevel == "School"

rename Code StateAssignedSchID

// create separate district and school names, based on length of code (or daalevel function)
gen DistName = SchName if DataLevel == "District"

// hardcoding DataLevel 
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

// "All Districts" and "All School" creation
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2
save "$Temp/nc_progress_1", replace // use loop variable here (or not)

gen StateAssignedSchID_full = StateAssignedSchID // keeping to replace back later 
//making state assigned school ID just 3 for match 
replace StateAssignedSchID = substr(StateAssignedSchID, 4, .)
rename StateAssignedDistID State_leaid
if "`a'" == "22-23" {
merge m:1 State_leaid using "$NCES_NC/nc_district_IDs_2022"
} 

if "`a'" != "22-23" {
merge m:1 State_leaid using "$NCES_NC/nc_district_IDs_`prevyear'"
} 

drop DistName 
rename DistName1 DistName 
replace DistName = "All Districts" if DataLevel == 1
drop if _merge == 2
drop _merge

if "`a'" == "22-23" {
merge m:1 State_leaid using "$NCES_NC/NCES_2022_District_NC" // CHANGED
rename _merge DistMerge
drop if DistMerge == 2
drop DistMerge
	
}

if "`a'" != "22-23" {
merge m:1 State_leaid using "$NCES_NC/NCES_`prevyear'_District_NC" // CHANGED
rename _merge DistMerge
drop if DistMerge == 2
drop DistMerge
}

if "`a'" == "22-23" {	
rename StateAssignedSchID seasch
merge m:1 State_leaid seasch using "$NCES_NC/NCES_2022_School_NC" // CHANGED 
rename _merge SchoolMerge
drop if SchoolMerge == 2
} 

if "`a'" != "22-23" {	
rename StateAssignedSchID seasch
merge m:1 State_leaid seasch using "$NCES_NC/NCES_`prevyear'_School_NC" // CHANGED 
rename _merge SchoolMerge
drop if SchoolMerge == 2
} 

display "merge"
rename State_leaid StateAssignedDistID
rename seasch StateAssignedSchID

// general 
drop State
drop StateAbbrev
drop StateFips
gen State = "North Carolina"
gen StateAbbrev = "NC"
gen StateFips = 37 // CHANGED

// flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N" 
gen Flag_CutScoreChange_soc = "Not applicable"

// UPDATED 4/30/24
if "`a'" == "13-14" {
replace Flag_AssmtNameChange = "Y" // if Subject == "ela" & GradeLevel == "G04" | GradeLevel == "G05" | GradeLevel == "G06" | GradeLevel == "G07" | GradeLevel == "G08" 
replace Flag_CutScoreChange_ELA = "Y" 
replace Flag_CutScoreChange_math = "Y" 
replace Flag_CutScoreChange_sci = "Y" 
}

if "`a'" == "18-19" {
replace Flag_AssmtNameChange = "Y" if Subject == "math"
replace Flag_CutScoreChange_math = "Y" 
}

if "`a'" == "20-21" {
replace Flag_AssmtNameChange = "Y" if Subject == "ela" & (GradeLevel == "G04" | GradeLevel == "G05" | GradeLevel == "G06" | GradeLevel == "G07" | GradeLevel == "G08" | GradeLevel == "G38")
replace Flag_CutScoreChange_ELA = "Y" if (Subject == "ela" & GradeLevel == "G04" | GradeLevel == "G05" | GradeLevel == "G06" | GradeLevel == "G07" | GradeLevel == "G08" | GradeLevel == "G38")
}

if "`a'" == "21-22" {
replace Flag_AssmtNameChange = "Y" if Subject == "ela" & GradeLevel == "G03" | GradeLevel == "G38"
replace Flag_CutScoreChange_ELA = "Y" if Subject == "ela" & GradeLevel == "G03" | GradeLevel == "G38"
}

// UPDATED 4/30/24

if "`a'" == "13-14" {
gen SchYear = "2013-14"
} 

if "`a'" == "14-15" {
gen SchYear = "2014-15"
} 

if "`a'" == "15-16" {
gen SchYear = "2015-16"
} 

if "`a'" == "16-17" {
gen SchYear = "2016-17"
} 

if "`a'" == "17-18" {
gen SchYear = "2017-18"
} 

if "`a'" == "18-19" {
gen SchYear = "2018-19"
} 

if "`a'" == "20-21" {
gen SchYear = "2020-21"
}

if "`a'" == "21-22" {
gen SchYear = "2021-22"
}

if "`a'" == "22-23" {
gen SchYear = "2022-23"
} 

// decoding to create strings here

if "`a'" != "13-14" {
//decode DistType, gen (DistType1)
//drop DistType
//rename DistType1 DistType

decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType

decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel

decode SchVirtual, gen (SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual
} 

// EDIT 
// UPDATED 4/30/24
if "`a'" == "17-18" | "`a'" == "16-17" | "`a'" == "15-16" | "`a'" == "14-15" | "`a'" == "13-14"  {
gen AssmtName = "End-of-Grade Tests - Edition 4" // r3 changed
replace AssmtName = "End-of-Grade Tests - Edition 2" if Subject == "sci"
} 

if "`a'" == "18-19" { 
gen AssmtName = "End-of-Grade Tests - Edition 4" // r3 changed
replace AssmtName = "End-of-Grade Tests - Edition 5" if Subject == "math" // r3 changed
replace AssmtName = "End-of-Grade Tests - Edition 2" if Subject == "sci"
}

if "`a'" == "20-21" { 
gen AssmtName = "End-of-Grade Tests - Edition 4" // r3 changed
replace AssmtName = "End-of-Grade Tests - Edition 5" if Subject == "math" // r3 changed
replace AssmtName = "End-of-Grade Tests - Edition 5" if Subject == "ela" & GradeLevel == "G04" | GradeLevel == "G05" | GradeLevel == "G06" | GradeLevel == "G07" | GradeLevel == "G08" | GradeLevel == "G38" 
replace AssmtName = "End-of-Grade Tests - Edition 2" if Subject == "sci"
}

if "`a'" == "21-22" | "`a'" == "22-23" { 
gen AssmtName = "End-of-Grade Tests - Edition 5" 
replace AssmtName = "End-of-Grade Tests - Edition 2" if Subject == "sci"
}
// EDIT 
gen seasch = StateAssignedSchID // CHANGED //r3 changed
gen State_leaid = StateAssignedDistID // CHANGED

if "`a'" == "22-23" | "`a'" == "21-22" {
gen Lev1_count = "-" //r3 changed
gen Lev1_percent = "-" //r3 changed
gen Lev2_count = "-" //r3 changed
gen Lev3_count = "-" //r3 changed
gen Lev4_count = "-" //r3 changed
gen Lev5_count = "-" //r3 changed
} 

if "`a'" == "20-21" | "`a'" == "18-19" | "`a'" == "17-18" {
gen Lev1_count = "-" //r3 changed
gen Lev2_count = "-" //r3 changed
gen Lev3_count = "-" //r3 changed
gen Lev4_count = "-" //r3 changed
gen Lev5_count = "-" //r3 changed
}

if "`a'" == "22-23" | "`a'" == "21-22" | "`a'" == "20-21" | "`a'" == "18-19" |  "`a'" == "17-18" {
gen ProficientOrAbove_count = "-" //r3 changed
}

gen StudentGroup_TotalTested = StudentSubGroup_TotalTested 
destring StudentGroup_TotalTested, replace force ignore(",")
// replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == .
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested

gen ParticipationRate = "--" //pre-review

display "CCCCCCCCC"
replace Lev2_percent = "-100000" if Lev2_percent =="-"
replace Lev3_percent = "-100000" if Lev3_percent == "-"
replace Lev4_percent = "-100000" if Lev4_percent == "-"
replace Lev5_percent = "-100000" if Lev5_percent == "-"

replace Lev2_percent = "5000000" if Lev2_percent == "<5"
replace Lev3_percent = "5000000" if Lev3_percent == "<5"
replace Lev4_percent = "5000000" if Lev4_percent == "<5"
replace Lev5_percent = "5000000" if Lev5_percent == "<5"

replace Lev2_percent = "95000000" if Lev2_percent == ">95"
replace Lev3_percent = "95000000" if Lev3_percent == ">95"
replace Lev4_percent = "95000000" if Lev4_percent == ">95"
replace Lev5_percent = "95000000" if Lev5_percent == ">95"

replace ProficientOrAbove_percent = "-" if ProficientOrAbove_percent == "-100000"
replace ProficientOrAbove_percent = "5000000" if ProficientOrAbove_percent == "<5"
replace ProficientOrAbove_percent = "95000000" if ProficientOrAbove_percent == ">95"

if "`a'" == "16-17" | "`a'" == "15-16" | "`a'" == "14-15" | "`a'" == "13-14"  {
replace Lev1_count = "-100000" if Lev1_count == "-"
replace Lev2_count = "-100000" if Lev2_count == "-"
replace Lev3_count = "-100000" if Lev3_count == "-"
replace Lev4_count = "-100000" if Lev4_count == "-"
replace Lev5_count = "-100000" if Lev5_count == "-"
replace ProficientOrAbove_count = "-100000" if ProficientOrAbove_count == "-"
} 

if "`a'" == "21-22" | "`a'" == "20-21" | "`a'" == "18-19" |  "`a'" == "17-18" | "`a'" == "16-17" | "`a'" == "15-16" | "`a'" == "14-15" | "`a'" == "13-14"  {
replace Lev1_percent = "-100000" if Lev1_percent == "-"
replace Lev1_percent = "5000000" if Lev1_percent == "<5"
replace Lev1_percent = "95000000" if Lev1_percent == ">95"
} 

if "`a'" == "22-23" | "`a'" == "21-22" {
destring Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent AvgScaleScore, replace force ignore(", < >")  //r1 added avgscale 

// converting to decimal form from percentage form 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace Lev5_percent = Lev5_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100
tostring Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent AvgScaleScore, replace force //r1 added avgscale 
} 

if "`a'" == "20-21" | "`a'" == "18-19" | "`a'" == "17-18" | "`a'" == "16-17" | "`a'" == "15-16" | "`a'" == "14-15" | "`a'" == "13-14"  {
destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent AvgScaleScore, replace force ignore(", < >")  //r1 added avgscale score

// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace Lev5_percent = Lev5_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent AvgScaleScore, replace force //r1 added avgscale score
}

display "BBBBBBBBBB"
replace AvgScaleScore = "--" if AvgScaleScore == "."
if "`a'" == "16-17" | "`a'" == "15-16" | "`a'" == "14-15" | "`a'" == "13-14"  {
replace Lev1_count = "*" if Lev1_count == "-100000" 
replace Lev2_count = "*" if Lev2_count == "-100000" 
replace Lev3_count = "*" if Lev3_count == "-100000" 
replace Lev4_count = "*" if Lev4_count == "-100000" 
replace Lev5_count = "*" if Lev5_count == "-100000" 

replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "-100000"
replace ProficientOrAbove_count = "<.05" if ProficientOrAbove_count  == "50000"
replace ProficientOrAbove_count = ">.95" if ProficientOrAbove_count  == "950000"
} 


// NEWWWWW
if "`a'" == "21-22" {
replace Lev1_percent = "-" if Lev1_percent == "-100000"
}

if "`a'" == "20-21" | "`a'" == "18-19" |  "`a'" == "17-18" | "`a'" == "16-17" | "`a'" == "15-16" | "`a'" == "14-15" | "`a'" == "13-14"  {
replace Lev1_percent = "*" if Lev1_percent == "-1000"
replace Lev1_percent = "<.05" if Lev1_percent == "50000"
replace Lev1_percent = ">.95" if Lev1_percent == "950000"
} 

replace Lev2_percent = "<.05" if Lev2_percent == "50000"
replace Lev2_percent = ">.95" if Lev2_percent == "950000"

replace Lev3_percent = "<.05" if Lev3_percent == "50000"
replace Lev3_percent = ">.95" if Lev3_percent == "950000"

replace Lev4_percent = "<.05" if Lev4_percent == "50000"
replace Lev4_percent = ">.95" if Lev4_percent == "950000"

replace Lev5_percent = "<.05" if Lev5_percent == "50000"
replace Lev5_percent = ">.95" if Lev5_percent == "950000"

display "AAAAAAAA"
replace Lev2_percent = "*" if Lev2_percent == "-1000"
replace Lev3_percent = "*" if Lev3_percent == "-1000"
replace Lev4_percent = "*" if Lev4_percent == "-1000"
replace Lev5_percent = "*" if Lev5_percent == "-1000"

replace ProficientOrAbove_percent = "<.05" if ProficientOrAbove_percent == "50000"
replace ProficientOrAbove_percent = ">.95" if ProficientOrAbove_percent == "950000"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-1000"

if "`a'" == "14-15" { // r1
replace NCESSchoolID = "" if DataLevel == 1 // r1 (for 2015)	
} //r1 

// convert > < to ranges // r1 
foreach var of varlist Lev*_percent ProficientOrAbove_percent {
        // replace `var' = subinstr(`var', "=","",.)
        replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
        replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
} // r1


if "`a'" == "22-23" { // r1
save "$Temp/nc_in_progress_2023", replace
import delimited "$Original/missing_nc.csv", case(preserve) stringcols(2 6 12) clear 
save "$Temp/missing_nc", replace 
use "$Temp/nc_in_progress_2023", clear
merge m:1 StateAssignedDistID StateAssignedSchID using "$Temp/missing_nc"
replace DistName = DistName2 if DistName == "" & DataLevel == 3
replace NCESDistrictID = NCESDistrictID1 if NCESDistrictID == "" & DataLevel == 3
replace DistCharter = DistCharter1 if DistCharter == "" & DataLevel == 3
replace DistType = DistType1 if DistType == "" & DataLevel == 3
drop DistName1 DistCharter1 DistType1 
tostring CountyCode1, replace
replace NCESSchoolID = NCESSchoolID1 if NCESSchoolID == "" & DataLevel == 3
replace SchType = SchType1 if SchType == "" & DataLevel == 3
replace SchLevel = SchLevel1 if SchLevel == "" & DataLevel == 3
replace CountyName = CountyName1 if CountyName == "" & DataLevel == 3
replace CountyCode = CountyCode1 if CountyCode == "" & DataLevel == 3
replace SchVirtual = SchVirtual1 if SchVirtual == "" & DataLevel == 3
drop NCESSchoolID1 SchType1 SchLevel1 CountyName1 CountyCode1 SchVirtual1
}


// NEWWWWW

if "`a'" == "20-21" | "`a'" == "18-19" { 
	replace Lev1_count = "" if Lev1_percent == "."
    replace Lev1_percent = "" if Lev1_count == ""
}


if "`a'" == "22-23" | "`a'" == "21-22" {
	replace Lev1_count = "" if Lev1_percent == "-"
    replace Lev1_percent = "" if Lev1_count == ""
}
	
drop State_leaid seasch

// updated 4/30/24 

drop StateAssignedSchID
rename StateAssignedSchID_full StateAssignedSchID

// updated 4/30/24 
order State StateAbbrev StateFips SchYear DataLevel DistName SchName ///
	NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID ///
	AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested ///
	StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count ///
	Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent ///
	AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ///
	ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math ///
	Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType ///
	SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName ///
	NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID ///
	AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested ///
	StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count ///
	Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent ///
	AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ///
	ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math ///
	Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType ///
	SchLevel SchVirtual CountyName CountyCode
// 2024 update
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "$Temp/NC_AssmtData_`current'_Stata", replace
}



*************************************************************************
// Destringing/ Generating counts/ Manual Fixes to NCES IDs 
// Different codes for each set of years
*************************************************************************
// pre-review cleaning 2024 

local years2   "2014 2015 2016 2017 2018 2019 2021 2022 2023"
foreach g in `years2' {
use "$Temp/NC_AssmtData_`g'_Stata", clear
******************************
//Conditions when year == 2014 or 2015
******************************
if "`g'" == "2015" | "`g'" == "2014"  {
local a  "1 2 3 4 5" 
foreach b in `a' {
split Lev`b'_percent, parse("-")
}

split ProficientOrAbove_percent, parse("-")

destring Lev*_percent1 Lev*_percent2 ProficientOrAbove_percent1 ProficientOrAbove_percent2, replace ignore("*") // Modified 3/3/25

******************************
//Derivations//
******************************
//Counts derived from using percentages * SSGT
gen Lev1_count1 = Lev1_percent1* StudentSubGroup_TotalTested
gen Lev2_count1 = Lev2_percent1* StudentSubGroup_TotalTested
gen Lev3_count1 = Lev3_percent1* StudentSubGroup_TotalTested
gen Lev4_count1 = Lev4_percent1* StudentSubGroup_TotalTested
gen Lev5_count1 = Lev5_percent1* StudentSubGroup_TotalTested
gen ProficientOrAbove_count1 = ProficientOrAbove_percent1* StudentSubGroup_TotalTested

gen Lev1_count2 = Lev1_percent2* StudentSubGroup_TotalTested
gen Lev2_count2 = Lev2_percent2* StudentSubGroup_TotalTested
gen Lev3_count2 = Lev3_percent2* StudentSubGroup_TotalTested
gen Lev4_count2 = Lev4_percent2* StudentSubGroup_TotalTested
gen Lev5_count2 = Lev5_percent2* StudentSubGroup_TotalTested
gen ProficientOrAbove_count2 = ProficientOrAbove_percent2* StudentSubGroup_TotalTested

local a  "1 2 3 4 5" 
foreach b in `a' {
replace Lev`b'_count1 = round(Lev`b'_count1, 1)
}

local a  "1 2 3 4 5" 
foreach b in `a' {
replace Lev`b'_count2 = round(Lev`b'_count2, 1)
tostring Lev`b'_count1 Lev`b'_count2, replace force 
egen Lev`b'_countX = concat(Lev`b'_count1 Lev`b'_count2) if Lev`b'_count2 != ".", punct("-") 
replace Lev`b'_countX = Lev`b'_count1 if Lev`b'_count2 == "."
drop Lev`b'_count1 Lev`b'_count2 Lev`b'_percent1 Lev`b'_percent2
replace Lev`b'_count = Lev`b'_countX
drop Lev`b'_count
rename Lev`b'_countX Lev`b'_count

replace Lev`b'_count = "*" if Lev`b'_percent == "*"

// updated 4/30/24
split Lev`b'_count, parse("-")
replace Lev`b'_count = Lev`b'_count1 if Lev`b'_count1 == Lev`b'_count2
drop Lev`b'_count1 Lev`b'_count2
// updated 4/30/24
}

replace ProficientOrAbove_count1 = round(ProficientOrAbove_count1, 1)
replace ProficientOrAbove_count2 = round(ProficientOrAbove_count2, 1)
tostring ProficientOrAbove_count1 ProficientOrAbove_count2, replace force 
egen ProficientOrAbove_countX = concat(ProficientOrAbove_count1 ProficientOrAbove_count2) if ProficientOrAbove_count2 != ".", punct("-") 
replace ProficientOrAbove_countX  = ProficientOrAbove_count1 if ProficientOrAbove_count2 == "."
drop ProficientOrAbove_count1 ProficientOrAbove_count2 ProficientOrAbove_percent1 ProficientOrAbove_percent2
replace ProficientOrAbove_count = ProficientOrAbove_countX
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "*"
drop ProficientOrAbove_count
display "error"
rename ProficientOrAbove_countX ProficientOrAbove_count

// updated 4/30/24
split ProficientOrAbove_count, parse("-")
replace ProficientOrAbove_count = ProficientOrAbove_count1 if ProficientOrAbove_count1 == ProficientOrAbove_count2
drop ProficientOrAbove_count1 ProficientOrAbove_count2
// updated 4/30/24
}

******************************
//Conditions when year == 2016 through 2021
******************************
if "`g'" == "2021" | "`g'" == "2019" |  "`g'" == "2018" | "`g'" == "2017" | "`g'" == "2016"  {
local a  "1 2 3 4 5" 
foreach b in `a' {
split Lev`b'_percent, parse("-")
}

split ProficientOrAbove_percent, parse("-")
destring Lev*_percent1 Lev*_percent2 ProficientOrAbove_percent1 ProficientOrAbove_percent2, replace // Modified 3/3/25

******************************
//Derivations//
******************************
//Counts derived from using percentages * SSGT
gen Lev1_count1 = Lev1_percent1* StudentSubGroup_TotalTested
gen Lev2_count1 = Lev2_percent1* StudentSubGroup_TotalTested
gen Lev3_count1 = Lev3_percent1* StudentSubGroup_TotalTested
gen Lev4_count1 = Lev4_percent1* StudentSubGroup_TotalTested
gen Lev5_count1 = Lev5_percent1* StudentSubGroup_TotalTested
gen ProficientOrAbove_count1 = ProficientOrAbove_percent1* StudentSubGroup_TotalTested

gen Lev1_count2 = Lev1_percent2* StudentSubGroup_TotalTested
gen Lev2_count2 = Lev2_percent2* StudentSubGroup_TotalTested
gen Lev3_count2 = Lev3_percent2* StudentSubGroup_TotalTested
gen Lev4_count2 = Lev4_percent2* StudentSubGroup_TotalTested
gen Lev5_count2 = Lev5_percent2* StudentSubGroup_TotalTested
gen ProficientOrAbove_count2 = ProficientOrAbove_percent2* StudentSubGroup_TotalTested

local a  "1 2 3 4 5" 
foreach b in `a' {
replace Lev`b'_count1 = round(Lev`b'_count1, 1)
}

local a  "1 2 3 4 5" 
foreach b in `a' {
replace Lev`b'_count2 = round(Lev`b'_count2, 1)
tostring Lev`b'_count1 Lev`b'_count2, replace force 
egen Lev`b'_countX = concat(Lev`b'_count1 Lev`b'_count2) if Lev`b'_count2 != ".", punct("-") 
replace Lev`b'_countX = Lev`b'_count1 if Lev`b'_count2 == "."
drop Lev`b'_count1 Lev`b'_count2 Lev`b'_percent1 Lev`b'_percent2
replace Lev`b'_count = Lev`b'_countX
drop Lev`b'_count
rename Lev`b'_countX Lev`b'_count

// updated 4/30/24
split Lev`b'_count, parse("-")
replace Lev`b'_count = Lev`b'_count1 if Lev`b'_count1 == Lev`b'_count2
drop Lev`b'_count1 Lev`b'_count2
// updated 4/30/24
}

replace ProficientOrAbove_count1 = round(ProficientOrAbove_count1, 1)
replace ProficientOrAbove_count2 = round(ProficientOrAbove_count2, 1)
tostring ProficientOrAbove_count1 ProficientOrAbove_count2, replace force 
egen ProficientOrAbove_countX = concat(ProficientOrAbove_count1 ProficientOrAbove_count2) if ProficientOrAbove_count2 != ".", punct("-") 
replace ProficientOrAbove_countX  = ProficientOrAbove_count1 if ProficientOrAbove_count2 == "."
drop ProficientOrAbove_count1 ProficientOrAbove_count2 ProficientOrAbove_percent1 ProficientOrAbove_percent2
replace ProficientOrAbove_count = ProficientOrAbove_countX
drop ProficientOrAbove_count
rename ProficientOrAbove_countX ProficientOrAbove_count

// updated 4/30/24
split ProficientOrAbove_count, parse("-")
replace ProficientOrAbove_count = ProficientOrAbove_count1 if ProficientOrAbove_count1 == ProficientOrAbove_count2
drop ProficientOrAbove_count1 ProficientOrAbove_count2
// updated 4/30/24
}

******************************
//Conditions when year == 2022 or 2023
******************************
if "`g'" == "2023" | "`g'" == "2022"  {
	
local a  "2 3 4 5" 
foreach b in `a' {
split Lev`b'_percent, parse("-")
}

split ProficientOrAbove_percent, parse("-")

// destring  Lev2_percent1 Lev3_percent1 Lev4_percent1 Lev5_percent1 ProficientOrAbove_percent1  Lev2_percent2 Lev3_percent2 Lev4_percent2 Lev5_percent2 ProficientOrAbove_percent2, replace 
destring Lev*_percent1 Lev*_percent2 ProficientOrAbove_percent1 ProficientOrAbove_percent2, replace // Modified 3/3/25
******************************
//Derivations//
******************************
//Counts derived from using percentages * SSGT
gen Lev2_count1 = Lev2_percent1* StudentSubGroup_TotalTested
gen Lev3_count1 = Lev3_percent1* StudentSubGroup_TotalTested
gen Lev4_count1 = Lev4_percent1* StudentSubGroup_TotalTested
gen Lev5_count1 = Lev5_percent1* StudentSubGroup_TotalTested
gen ProficientOrAbove_count1 = ProficientOrAbove_percent1* StudentSubGroup_TotalTested

gen Lev2_count2 = Lev2_percent2* StudentSubGroup_TotalTested
gen Lev3_count2 = Lev3_percent2* StudentSubGroup_TotalTested
gen Lev4_count2 = Lev4_percent2* StudentSubGroup_TotalTested
gen Lev5_count2 = Lev5_percent2* StudentSubGroup_TotalTested
gen ProficientOrAbove_count2 = ProficientOrAbove_percent2* StudentSubGroup_TotalTested

local a  "2 3 4 5" 
foreach b in `a' {
replace Lev`b'_count1 = round(Lev`b'_count1, 1)
}

local a  "2 3 4 5" 
foreach b in `a' {
replace Lev`b'_count2 = round(Lev`b'_count2, 1)
tostring Lev`b'_count1 Lev`b'_count2, replace force 
egen Lev`b'_countX = concat(Lev`b'_count1 Lev`b'_count2) if Lev`b'_count2 != ".", punct("-") 
replace Lev`b'_countX = Lev`b'_count1 if Lev`b'_count2 == "."
drop Lev`b'_count1 Lev`b'_count2 Lev`b'_percent1 Lev`b'_percent2
replace Lev`b'_count = Lev`b'_countX
drop Lev`b'_count
rename Lev`b'_countX Lev`b'_count

// updated 4/30/24
split Lev`b'_count, parse("-")
replace Lev`b'_count = Lev`b'_count1 if Lev`b'_count1 == Lev`b'_count2
drop Lev`b'_count1 Lev`b'_count2
// updated 4/30/24
}

replace ProficientOrAbove_count1 = round(ProficientOrAbove_count1, 1)
replace ProficientOrAbove_count2 = round(ProficientOrAbove_count2, 1)
tostring ProficientOrAbove_count1 ProficientOrAbove_count2, replace force 
egen ProficientOrAbove_countX = concat(ProficientOrAbove_count1 ProficientOrAbove_count2) if ProficientOrAbove_count2 != ".", punct("-") 
replace ProficientOrAbove_countX  = ProficientOrAbove_count1 if ProficientOrAbove_count2 == "."
drop ProficientOrAbove_count1 ProficientOrAbove_count2 ProficientOrAbove_percent1 ProficientOrAbove_percent2
replace ProficientOrAbove_count = ProficientOrAbove_countX
drop ProficientOrAbove_count
rename ProficientOrAbove_countX ProficientOrAbove_count


// updated 4/30/24
split ProficientOrAbove_count, parse("-")
replace ProficientOrAbove_count = ProficientOrAbove_count1 if ProficientOrAbove_count1 == ProficientOrAbove_count2
drop ProficientOrAbove_count1 ProficientOrAbove_count2
// updated 4/30/24
}

// updated 4/30/24
// for 2016

******************************
//Conditions when year == 2016 or 2021
******************************
if "`g'" == "2016" | "`g'" == "2021" {
replace SchName = "Hallyburton Academy" if NCESSchoolID== "370048001005"
replace DistName = "Burke County Schools" if NCESSchoolID== "370048001005"
}

if "`g'" == "2016" | "`g'" == "2021"  {
// for 2021 
replace SchName = "Doris Henderson Newcomers Sch" if NCESSchoolID == "370192002988"
replace DistName = "Guilford County Schools" if NCESSchoolID == "370192002988"
}
replace CountyName = proper(CountyName)
replace CountyName = "McDowell County" if CountyCode == "37111"

******************************
// Keeping and Reordering Variables
******************************
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
save "${Temp}/NC_AssmtData_`g'_Stata", replace
}

******************************
// Creating the Stable Names File
******************************
use "$Original/nc_full-dist-sch-stable-list_through2023.dta", clear
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 
save "$Original_DTA/NC_StableNames_Sch", replace
duplicates drop NCESDistrictID SchYear, force
drop NCESSchoolID newschname olddistname oldschname
gen SchName = "All Schools"
replace DataLevel = 2

append using "$Original_DTA/NC_StableNames_Sch"
sort DataLevel
duplicates drop SchYear DataLevel NCESDistrictID NCESSchoolID, force
save "$Original_DTA/NC_StableNames", replace
clear

******************************
// NCES Merging
******************************
//Looping Through Years
forvalues year = 2014/2023 { 
	if `year' == 2020 continue
use "$Original_DTA/NC_StableNames", clear
local prevyear = `=`year'-1'
keep if SchYear == "`prevyear'-" + substr("`year'",-2,2)
tostring NCESDistrictID, replace
replace NCESDistrictID = "" if NCESDistrictID == "."
tostring NCESSchoolID, format("%18.0f") replace
replace NCESSchoolID = "" if NCESSchoolID == "."
merge 1:m DataLevel NCESDistrictID NCESSchoolID using "${Temp}/NC_AssmtData_`year'_Stata" 
drop if _merge == 1
replace DistName = newdistname if DataLevel !=1
replace SchName = newschname if DataLevel == 3
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel ==1

******************************
// Replacing values for 2016 and 2021
******************************
if `year' == 2016 | `year' == 2021 {
replace SchName = "Hallyburton Academy" if NCESSchoolID== "370048001005"
replace DistName = "Burke County Schools" if NCESSchoolID== "370048001005"
}

******************************
// Replacing values for 2016 and 2021
******************************
if `year' == 2016 | `year' == 2021  {
// for 2021 
replace SchName = "Doris Henderson Newcomers Sch" if NCESSchoolID == "370192002988"
replace DistName = "Guilford County Schools" if NCESSchoolID == "370192002988"
}


//Final Cleaning and Saving
keep `vars'
order `vars'
save "${Temp}/NC_AssmtData_`year'_Stata", replace
}

******************************
// Changing Levels for 2022 and 2023
******************************
// changes 5/7/2024
// updating from Lev 3-5 to Lev 2-4 in 2022 and 2023
forvalues year = 2022/2023 { 
// 	if `year' == 2020 continue [delete]
	
use "${Temp}/NC_AssmtData_`year'_Stata", clear
forvalues b = 2/5 { 
local prevyear = `b' - 1
replace Lev`prevyear'_count = Lev`b'_count 
replace Lev`prevyear'_percent = Lev`b'_percent
}

replace Lev5_count = ""
replace Lev5_percent  = ""
replace ProficiencyCriteria = "Levels 2-4"
save "${Temp}/NC_AssmtData_`year'_Stata", replace
}

******************************
// Changing Levels for 2019 and 2021
******************************
// updating from Lev 3-5 to Lev 2-4 for certain values in 2019 and 2021
forvalues year = 2019/2021 { 
	if `year' == 2020 continue
use "${Temp}/NC_AssmtData_`year'_Stata", replace	
forvalues b = 2/5 { 
local prevyear = `b' - 1
replace ProficiencyCriteria = "Levels 2-4" if AssmtName == "End-of-Grade Tests - Edition 5"
replace Lev`prevyear'_count = Lev`b'_count if  AssmtName == "End-of-Grade Tests - Edition 5"
replace Lev`prevyear'_percent = Lev`b'_percent if  AssmtName == "End-of-Grade Tests - Edition 5"
}
replace Lev5_count = ""  if AssmtName == "End-of-Grade Tests - Edition 5"
replace Lev5_percent  = "" if  AssmtName == "End-of-Grade Tests - Edition 5"
save "${Temp}/NC_AssmtData_`year'_Stata", replace
}

// above changes just for sci 
forvalues year = 2021/2021 { 
use "${Temp}/NC_AssmtData_`year'_Stata", replace	
forvalues b = 2/5 { 
local prevyear = `b' - 1
replace ProficiencyCriteria = "Levels 2-4" if AssmtName == "End-of-Grade Tests - Edition 2"
replace Lev`prevyear'_count = Lev`b'_count if  AssmtName == "End-of-Grade Tests - Edition 2"
replace Lev`prevyear'_percent = Lev`b'_percent if  AssmtName == "End-of-Grade Tests - Edition 2"
}
replace Lev5_count = ""  if AssmtName == "End-of-Grade Tests - Edition 2"
replace Lev5_percent  = "" if  AssmtName == "End-of-Grade Tests - Edition 2"
save "${Temp}/NC_AssmtData_`year'_Stata", replace
}

******************************
// Additional Calculations for 2014 through 2023
******************************
//Deriving Additional Information
foreach year in 2014 2015 2016 2017 2018 2019 2021 2022 2023 {

use "${Temp}/NC_AssmtData_`year'_Stata", clear

tostring StudentSubGroup_TotalTested, replace
	
//ProficiencyCriteria == Levels 2-4
replace ProficientOrAbove_percent = string(real(Lev2_percent) + real(Lev3_percent) + real(Lev4_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 &strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & Lev2_percent != "*" & Lev3_percent != "*" & Lev4_percent != "*" & ProficiencyCriteria == "Levels 2-4" & real(Lev2_percent) + real(Lev3_percent) + real(Lev4_percent) < 1

replace ProficientOrAbove_count = string(real(Lev2_count) + real(Lev3_count) + real(Lev4_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev4_count, "-") == 0 & Lev2_count != "*" & Lev3_percent != "*" & Lev4_count != "*" & ProficiencyCriteria == "Levels 2-4" & real(Lev2_count) + real(Lev3_count) + real(Lev4_count) < real(StudentSubGroup_TotalTested)

replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev2_percent)) if strpos(Lev4_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count)) if strpos(Lev4_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & Lev3_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev2_percent)) if strpos(Lev3_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count) - real(Lev2_count)) if strpos(Lev3_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & Lev4_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev2_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev3_percent)) if strpos(Lev2_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev2_count = string(real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev4_count)) if strpos(Lev2_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & Lev4_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev1_percent = string(1 - real(ProficientOrAbove_percent)) if strpos(Lev1_percent, "-") > 0 & strpos(ProficientOrAbove_percent, "-") == 0 & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count)) if strpos(Lev1_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 2-4"
replace Lev1_percent = "0" if Lev1_count == "0"

//ProficiencyCriteria == Levels 3-5
replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev5_percent)) if strpos(Lev4_percent, "-") > 0 & strpos(Lev5_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev5_percent != "*" & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"

replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev5_count)) if strpos(Lev4_count, "-") > 0 & strpos(Lev5_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev5_count != "*" & Lev3_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 3-5"

replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev5_percent)) if strpos(Lev3_percent, "-") > 0 & strpos(Lev5_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev5_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"

replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count) - real(Lev5_count)) if strpos(Lev3_count, "-") > 0 & strpos(Lev5_count, "-") == 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev5_count != "*" & Lev4_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 3-5"

replace Lev5_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev3_percent)) if strpos(Lev5_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"

replace Lev5_count = string(real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev4_count)) if strpos(Lev5_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & Lev4_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 3-5"

replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent)) if strpos(Lev2_percent, "-") > 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"

replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count)) if strpos(Lev2_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev1_count != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"

replace Lev1_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev2_percent)) if strpos(Lev1_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count)) if strpos(Lev1_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev2_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev2_count != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"

******************************
// Additional Calculations for 2014 and 2015 only 
******************************
if `year' == 2014 | `year' == 2015 {
forvalues n = 1/5{
	replace Lev`n'_percent = "0" if Lev`n'_count == "0"
}
replace Lev5_count = string(real(ProficientOrAbove_count) - real(Lev4_count) - real(Lev3_count)) if Lev5_count == "*" & strpos(Lev3_count, "-") == 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & Lev4_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 3-5"
replace Lev5_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev3_percent)) if Lev5_percent == "*" & strpos(Lev3_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"

replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev5_count) - real(Lev3_count)) if Lev4_count == "*" & strpos(Lev3_count, "-") == 0 & strpos(Lev5_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & Lev5_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 3-5"
replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev5_percent) - real(Lev3_percent)) if Lev4_percent == "*" & strpos(Lev3_percent, "-") == 0 & strpos(Lev5_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev5_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"

replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count) - real(Lev5_count)) if Lev3_count == "*" & strpos(Lev5_count, "-") == 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev5_count != "*" & Lev4_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 3-5"
replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev5_percent)) if Lev3_percent == "*" & strpos(Lev5_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev5_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"

replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count)) if Lev2_count == "*" & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev1_count != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"
replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent)) if Lev2_percent == "*" & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count)) if Lev1_count == "*" & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev2_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev2_count != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"
replace Lev1_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev2_percent)) if Lev1_percent == "*" & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 3-5"

forvalues n = 1/5{
	split Lev`n'_percent, parse("-")
	split Lev`n'_count, parse("-")
}

replace Lev1_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev2_percent2)) + string(1 - real(ProficientOrAbove_percent)) if Lev1_percent == "*" & strpos(Lev2_percent, "0-") == 1 & real(Lev2_percent2) != . & real(ProficientOrAbove_percent) != . & (1 - real(ProficientOrAbove_percent) - real(Lev2_percent2)) >= 0

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count2)) + string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count)) if Lev1_count == "*" & strpos(Lev2_count, "0-") == 1 & real(Lev2_count2) != . & real(ProficientOrAbove_count) != . & real(StudentSubGroup_TotalTested) != . & (real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count2)) >= 0

replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent2)) + string(1 - real(ProficientOrAbove_percent)) if Lev2_percent == "*" & strpos(Lev1_percent, "0-") == 1 & real(Lev1_percent2) != . & real(ProficientOrAbove_percent) != . & (1 - real(ProficientOrAbove_percent) - real(Lev1_percent2)) >= 0

replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count2)) + string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count)) if Lev2_count == "*" & strpos(Lev1_count, "0-") == 1 & real(Lev1_count2) != . & real(ProficientOrAbove_count) != . & real(StudentSubGroup_TotalTested) != . & (real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count2)) >= 0

gen flag = 1 if Lev3_percent == "*" & strpos(Lev4_percent, "0-") == 1 & strpos(Lev5_percent, "0-") == 1 & ProficientOrAbove_percent != "*"
replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent2) - real(Lev5_percent2)) + "-" + ProficientOrAbove_percent if Lev3_percent == "*" & flag == 1 & real(Lev4_percent2) != . & real(Lev5_percent2) != . & real(ProficientOrAbove_percent) != . & (real(ProficientOrAbove_percent) - real(Lev4_percent2) - real(Lev5_percent2)) >= 0

replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count2) - real(Lev5_count2)) + "-" + ProficientOrAbove_count if Lev3_count == "*" & flag == 1 & real(Lev4_count2) != . & real(Lev5_count2) != . & real(ProficientOrAbove_count) != . & (real(ProficientOrAbove_count) - real(Lev4_count2) - real(Lev5_count2)) >= 0
drop flag

gen flag = 1 if Lev4_percent == "*" & strpos(Lev3_percent, "0-") == 1 & strpos(Lev5_percent, "0-") == 1 & ProficientOrAbove_percent != "*"
replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent2) - real(Lev5_percent2)) + "-" + ProficientOrAbove_percent if Lev4_percent == "*" & flag == 1 & real(Lev3_percent2) != . & real(Lev5_percent2) != . & real(ProficientOrAbove_percent) != . & (real(ProficientOrAbove_percent) - real(Lev3_percent2) - real(Lev5_percent2)) >= 0

replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count2) - real(Lev5_count2)) + "-" + ProficientOrAbove_count if Lev4_count == "*" & flag == 1 & real(Lev3_count2) != . & real(Lev5_count2) != . & real(ProficientOrAbove_count) != . & (real(ProficientOrAbove_count) - real(Lev3_count2) - real(Lev5_count2)) >= 0
drop flag

gen flag = 1 if Lev5_percent == "*" & strpos(Lev3_percent, "0-") == 1 & strpos(Lev4_percent, "0-") == 1 & ProficientOrAbove_percent != "*"
replace Lev5_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent2) - real(Lev3_percent2)) + "-" + ProficientOrAbove_percent if Lev5_percent == "*" & flag == 1 & real(Lev4_percent2) != . & real(Lev3_percent2) != . & real(ProficientOrAbove_percent) != . & (real(ProficientOrAbove_percent) - real(Lev4_percent2) - real(Lev3_percent2)) >= 0

replace Lev5_count = string(real(ProficientOrAbove_count) - real(Lev4_count2) - real(Lev3_count2)) + "-" + ProficientOrAbove_count if Lev5_count == "*" & flag == 1 & real(Lev4_count2) != . & real(Lev3_count2) != . & real(ProficientOrAbove_count) != . & (real(ProficientOrAbove_count) - real(Lev4_count2) - real(Lev3_count2)) >= 0
drop flag

replace Lev5_count = "0-" + string(round(real(StudentSubGroup_TotalTested) * 0.1)) if Lev5_percent == "0-.1" & Lev5_count == "*" & round(real(StudentSubGroup_TotalTested) * 0.1) != 0
}
save "${Temp}/NC_AssmtData_`year'_Stata", replace
}

******************************
// New StudentGroup_TotalTested for 2014 and 2023 only 
******************************
////New StudentGroup_TotalTested convention//// 10/30/24 update - MO
foreach year in 2014 2015 2016 2017 2018 2019 2021 2022 2023 {
	
use "${Temp}/NC_AssmtData_`year'_Stata", clear
drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1
replace StateAssignedSchID = "" if (DataLevel == 1 | DataLevel == 2) & StateAssignedSchID != ""

save "$Temp/NC_AssmtData_`year'", replace 

******************************
// Other fixes for 2014 and 2021
******************************
////Participation Rate fix//// 10/30/24 update - MO
if `year' == 2014 {
	use "$Temp/NC_AssmtData_`year'", clear
	replace ParticipationRate = "--" if ParticipationRate == ""
	save "$Temp/NC_AssmtData_`year'", replace
}

if `year' == 2021 {
use "$Temp/NC_AssmtData_`year'"
replace Flag_AssmtNameChange = "N" if Subject == "math"	
replace Flag_AssmtNameChange = "N" if Subject == "sci"	
save "$Temp/NC_AssmtData_`year'", replace
}
}

******************************
// Exporting Temp Output for 2014 through 2023.
******************************
foreach year in 2014 2015 2016 2017 2018 2019 2021 2022 2023 {

use "${Temp}/NC_AssmtData_`year'.dta", clear
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
keep `vars'
order `vars'
save "${Temp}/NC_AssmtData_`year'.dta", replace
}

******************************
// Exporting Final Output for 2023. (Not using any EDFacts data. Remove this code if you use EDFacts data in the future.)
****************************** 
use "${Temp}/NC_AssmtData_2023.dta", clear
save "${Output}/NC_AssmtData_2023.dta", replace
export delimited "$Output/NC_AssmtData_2023", replace
* END of nc_do.do
****************************************************
