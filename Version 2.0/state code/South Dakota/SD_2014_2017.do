clear
set more off
cd "/Users/benjaminm/Documents/State_Repository_Research"
cap log close
set trace off
// log using Observe.log, replace



local Original "/Users/benjaminm/Documents/State_Repository_Research/South Dakota/Original Data"
local Output "/Users/benjaminm/Documents/State_Repository_Research/South Dakota/Output"
local NCES_District "/Users/benjaminm/Documents/State_Repository_Research/NCES/District"
local NCES_School "/Users/benjaminm/Documents/State_Repository_Research/NCES/School"
local Stata_versions "/Users/benjaminm/Documents/State_Repository_Research/South Dakota/Stata .dta versions"

local years 2014 2015 2016 2017
local subjects ela math sci
local DataLevels State District School




**Prepping Files**
//For this code to work, the first time it runs must be to convert all excel files to .dta format. Simply unhide the import and save commands and hide the use command.
foreach year of local years {
	
di "~~~~~~~~~~~~"
di "`year'"
di "~~~~~~~~~~~~"	

	local prevyear =`=`year'-1'
	tempfile temp_`year'
	clear
	save "`temp_`year''", emptyok
	foreach subject of local subjects {
		 if ("`subject'" == "ela"| "`subject'" == "math") & (`year' == 2014) {
		 	continue
		 }
		foreach DataLevel of local DataLevels {
			// import excel "`Original'/`subject'_`prevyear'-`year'.xlsx", case(preserve) sheet("`DataLevel'")
			// save "`Stata_versions'/`year'_`subject'_`DataLevel'", replace
			use "`Stata_versions'/`year'_`subject'_`DataLevel'"
** Cleaning **

//Varnames in prep for reshape
drop in 1/6
if "`DataLevel'" == "State" {
drop A
rename B GradeLevel
rename C Total_Tested
rename D Lev4_percentAll_Students
rename E Lev3_percentAll_Students
rename F Lev2_percentAll_Students
rename G Lev1_percentAll_Students
rename H Lev4_percentWhite
rename I Lev3_percentWhite
rename J Lev2_percentWhite
rename K Lev1_percentWhite
rename L Lev4_percentBlack
rename M Lev3_percentBlack
rename N Lev2_percentBlack
rename O Lev1_percentBlack
rename P Lev4_percentAsian
rename Q Lev3_percentAsian
rename R Lev2_percentAsian
rename S Lev1_percentAsian
rename T Lev4_percentNative_American
rename U Lev3_percentNative_American
rename V Lev2_percentNative_American
rename W Lev1_percentNative_American
rename X Lev4_percentHispanic
rename Y Lev3_percentHispanic
rename Z Lev2_percentHispanic
rename AA Lev1_percentHispanic
rename AB Lev4_percentPacific_Islander
rename AC Lev3_percentPacific_Islander
rename AD Lev2_percentPacific_Islander
rename AE Lev1_percentPacific_Islander
rename AF Lev4_percentTwo_Or_More
rename AG Lev3_percentTwo_Or_More
rename AH Lev2_percentTwo_Or_More
rename AI Lev1_percentTwo_Or_More
rename AJ Lev4_percentDisadv
rename AK Lev3_percentDisadv
rename AL Lev2_percentDisadv
rename AM Lev1_percentDisadv
rename AN Lev4_percentEnglish_Learner
rename AO Lev3_percentEnglish_Learner
rename AP Lev2_percentEnglish_Learner
rename AQ Lev1_percentEnglish_Learner
rename AR Lev4_percentMale
rename AS Lev3_percentMale
rename AT Lev2_percentMale
rename AU Lev1_percentMale
rename AV Lev4_percentFemale
rename AW Lev3_percentFemale
rename AX Lev2_percentFemale
rename AY Lev1_percentFemale

	rename AZ Lev4_percentSWD
	rename BA Lev3_percentSWD
	rename BB Lev2_percentSWD
	rename BC Lev1_percentSWD
	rename BD Lev4_percentMigrant
	rename BE Lev3_percentMigrant
	rename BF Lev2_percentMigrant
	rename BG Lev1_percentMigrant
	
drop BH BI BJ BK BL BM BN BO // AZ BA BB BC BD BE BF BG 
drop in 1/2
}
if "`DataLevel'" == "District" {
rename A StateAssignedDistID
rename B DistName 
rename C GradeLevel
rename D Total_Tested
rename E Lev4_percentAll_Students
rename F Lev3_percentAll_Students
rename G Lev2_percentAll_Students
rename H Lev1_percentAll_Students
rename I Lev4_percentWhite
rename J Lev3_percentWhite
rename K Lev2_percentWhite
rename L Lev1_percentWhite
rename M Lev4_percentBlack
rename N Lev3_percentBlack
rename O Lev2_percentBlack
rename P Lev1_percentBlack
rename Q Lev4_percentAsian
rename R Lev3_percentAsian
rename S Lev2_percentAsian
rename T Lev1_percentAsian
rename U Lev4_percentNative_American
rename V Lev3_percentNative_American
rename W Lev2_percentNative_American
rename X Lev1_percentNative_American
rename Y Lev4_percentHispanic
rename Z Lev3_percentHispanic
rename AA Lev2_percentHispanic
rename AB Lev1_percentHispanic
rename AC Lev4_percentPacific_Islander
rename AD Lev3_percentPacific_Islander
rename AE Lev2_percentPacific_Islander
rename AF Lev1_percentPacific_Islander
rename AG Lev4_percentTwo_Or_More
rename AH Lev3_percentTwo_Or_More
rename AI Lev2_percentTwo_Or_More
rename AJ Lev1_percentTwo_Or_More
rename AK Lev4_percentDisadv
rename AL Lev3_percentDisadv
rename AM Lev2_percentDisadv
rename AN Lev1_percentDisadv
rename AO Lev4_percentEnglish_Learner
rename AP Lev3_percentEnglish_Learner
rename AQ Lev2_percentEnglish_Learner
rename AR Lev1_percentEnglish_Learner
rename AS Lev4_percentMale
rename AT Lev3_percentMale
rename AU Lev2_percentMale
rename AV Lev1_percentMale
rename AW Lev4_percentFemale
rename AX Lev3_percentFemale
rename AY Lev2_percentFemale
rename AZ Lev1_percentFemale
	rename BA Lev4_percentSWD
	rename BB Lev3_percentSWD
	rename BC Lev2_percentSWD
	rename BD Lev1_percentSWD
 rename BE Lev4_percentMigrant
	rename BF Lev3_percentMigrant
	rename BG Lev2_percentMigrant
	rename BH Lev1_percentMigrant
drop in 1/2
}
if "`DataLevel'" == "School" {
rename A StateAssignedDistID
rename B DistName
rename C SchName
rename D StateAssignedSchID
rename E GradeLevel
rename F Total_Tested
rename G Lev4_percentAll_Students
rename H Lev3_percentAll_Students
rename I Lev2_percentAll_Students
rename J Lev1_percentAll_Students
rename K Lev4_percentWhite
rename L Lev3_percentWhite
rename M Lev2_percentWhite
rename N Lev1_percentWhite
rename O Lev4_percentBlack
rename P Lev3_percentBlack
rename Q Lev2_percentBlack
rename R Lev1_percentBlack
rename S Lev4_percentAsian
rename T Lev3_percentAsian
rename U Lev2_percentAsian
rename V Lev1_percentAsian
rename W Lev4_percentNative_American
rename X Lev3_percentNative_American
rename Y Lev2_percentNative_American
rename Z Lev1_percentNative_American
rename AA Lev4_percentHispanic
rename AB Lev3_percentHispanic
rename AC Lev2_percentHispanic
rename AD Lev1_percentHispanic
rename AE Lev4_percentPacific_Islander
rename AF Lev3_percentPacific_Islander
rename AG Lev2_percentPacific_Islander
rename AH Lev1_percentPacific_Islander
rename AI Lev4_percentTwo_Or_More
rename AJ Lev3_percentTwo_Or_More
rename AK Lev2_percentTwo_Or_More
rename AL Lev1_percentTwo_Or_More
rename AM Lev4_percentDisadv
rename AN Lev3_percentDisadv
rename AO Lev2_percentDisadv
rename AP Lev1_percentDisadv
rename AQ Lev4_percentEnglish_Learner
rename AR Lev3_percentEnglish_Learner
rename AS Lev2_percentEnglish_Learner
rename AT Lev1_percentEnglish_Learner
rename AU Lev4_percentMale
rename AV Lev3_percentMale
rename AW Lev2_percentMale
rename AX Lev1_percentMale
rename AY Lev4_percentFemale
rename AZ Lev3_percentFemale
rename BA Lev2_percentFemale
rename BB Lev1_percentFemale
	rename BC Lev4_percentSWD
	rename BD Lev3_percentSWD
	rename BE Lev2_percentSWD
	rename BF Lev1_percentSWD
	 rename BG Lev4_percentMigrant
	rename BH Lev3_percentMigrant
	rename BI Lev2_percentMigrant
	rename BJ Lev1_percentMigrant
	
	
cap drop  BK BL BM BN BO BP BQ BR // BC BD BE BF  BG BH BI BJ
drop in 1/2
}
//Reshaping from Wide to Long
keep if GradeLevel == "3" | GradeLevel == "4" | GradeLevel == "5" | GradeLevel == "6" | GradeLevel == "7" | GradeLevel == "8"		

if "`DataLevel'" == "State" {
reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent, i(GradeLevel) j(StudentSubGroup, string)
gen StateAssignedDistID = ""
gen StateAssignedSchID = ""			
}

if "`DataLevel'" == "District" {
reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent, i(DistName GradeLevel) j(StudentSubGroup, string)
gen StateAssignedSchID = ""
}

if "`DataLevel'" == "School" {
reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent, i(DistName SchName GradeLevel) j(StudentSubGroup, string)
}		
*save "/Volumes/T7/State Test Project/South Dakota/test/`year'_`DataLevel'_`subject'", replace

//Merging NCES Data
gen UniqueDistID = ""
replace UniqueDistID = StateAssignedDistID if strlen(StateAssignedDistID) == 5
replace UniqueDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 4
if "`DataLevel'" == "District" {
tempfile temp1
save "`temp1'"
clear
use "`NCES_District'/NCES_`prevyear'_District.dta"
keep if state_fips == 46
if `year' != 2017 {
gen UniqueDistID = state_leaid
}
if `year' == 2017 {
gen UniqueDistID = substr(state_leaid, strpos(state_leaid, "-")+1, 6)
}
merge 1:m UniqueDistID using "`temp1'"
drop if _merge==1
drop if _merge == 2 // changed 6/3/24
if _rc !=0 {
di as error "Problem with DistID, check `year'_`subject'_`DataLevel'"
}

}
if "`DataLevel'" == "School" {
gen StateAssignedSchID1 = ""
replace StateAssignedSchID1 = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 1
replace StateAssignedSchID1 = StateAssignedSchID if strlen(StateAssignedSchID) ==2
gen UniqueSchID = UniqueDistID + "-" + StateAssignedSchID1
drop UniqueDistID StateAssignedSchID1
tempfile temp1
save "`temp1'"
clear
use "`NCES_School'/NCES_`prevyear'_School.dta"
keep if state_fips == 46
if `year' != 2017 {
gen UniqueDistID = state_leaid
}
if `year' == 2017 {
gen UniqueDistID = substr(state_leaid, strpos(state_leaid, "-")+1, 5)
}
gen StateAssignedSchID1 = ""
replace StateAssignedSchID1 = "0" + seasch if strlen(seasch) == 1
replace StateAssignedSchID1 = seasch if strlen(seasch) ==2
if `year' != 2017 {
gen UniqueSchID = UniqueDistID + "-" + StateAssignedSchID1
}
if `year' == 2017 { 
gen UniqueSchID = seasch
}
drop UniqueDistID StateAssignedSchID1

merge 1:m UniqueSchID using "`temp1'"
drop if _merge==1
drop if _merge == 2 // changed 6/3/24
if _rc !=0 {
di as error "Problem with SchID, check `year'_`subject'_`DataLevel'"
}
}
*save "/Volumes/T7/State Test Project/South Dakota/test/`year'_`DataLevel'_`subject'", replace

//Combining DataLevel and subject
gen Subject = "`subject'"
gen DataLevel = "`DataLevel'"
tempfile `subject'_`DataLevel'
save "``subject'_`DataLevel''"
clear
use "``subject'_`DataLevel''"
append using "`temp_`year''"
save "`temp_`year''", replace
*save "/Volumes/T7/State Test Project/South Dakota/test/`year'", replace
clear

			
			
		}
	}
use "`temp_`year''"
//Correcting Variables
rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
gen SchYear = "`prevyear'"+ "-" + substr("`year'",3, 2)
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
rename district_agency_type DistType
// rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
gen AssmtName = ""
replace AssmtName = "SBAC" if Subject != "sci"
replace AssmtName = "DSTEP" if Subject == "sci"
gen AssmtType = "Regular"
replace AssmtType = "Regular and alt" if `year' == 2015 | `year' == 2016 | `year' == 2017 

//StudentSubGroup
replace StudentSubGroup = "All Students" if StudentSubGroup == "All_Students"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific_Islander"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Disadv"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English_Learner"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native_American"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two_Or_More"


//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Two or More"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"

	replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" 
	replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" 

//StudentSubGroup_TotalTested
gen StudentSubGroup_TotalTested = "" 
replace StudentSubGroup_TotalTested = Total_Tested if StudentSubGroup == "All Students"
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)
//StudentGroup_TotalTested
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

//Level Counts and Percents
foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
	destring Lev`n'_percent, replace i("*-")
	replace Lev`n'_percent = round(Lev`n'_percent/100, .01)
	//format Lev`n'_percent %9.2f
}
//Proficiency
gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--"
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
//Final Variables
gen ParticipationRate = "--"

gen Flag_AssmtNameChange = "N"

if `year' == 2015 {
replace Flag_AssmtNameChange = "Y" if Subject == "ela" | Subject == "math"
}


if `year' == 2017 {
replace Flag_AssmtNameChange = "Y" if Subject == "sci"
}


gen Flag_CutScoreChange_ELA = "N"
if `year' == 2015 {
replace Flag_CutScoreChange_ELA = "Y" 
}
gen Flag_CutScoreChange_math = "N"

if `year' == 2015 {
replace Flag_CutScoreChange_ELA = "Y"
}
gen Flag_CutScoreChange_sci = "N" 

if `year' == 2015 {
replace Flag_CutScoreChange_sci = "Y" 
}

gen Flag_CutScoreChange_soc = "Not applicable"


//Converting to Correct Types and Misc Cleaning
foreach n in 1 2 3 4 {
gen Lev`n'_string = string(Lev`n'_percent, "%9.2f")
drop Lev`n'_percent
rename Lev`n'_string Lev`n'_percent
replace Lev`n'_percent = "--" if missing(Lev`n'_percent) | Lev`n'_percent == "."	
}
gen ProficientOrAbove_string = string(ProficientOrAbove_percent, "%9.2f")
drop ProficientOrAbove_percent
rename ProficientOrAbove_string ProficientOrAbove_percent
replace ProficientOrAbove_percent = "--" if missing(ProficientOrAbove_percent) | ProficientOrAbove_percent == "."
*save "/Volumes/T7/State Test Project/South Dakota/test/`year'", replace
//Empty Variables
gen Lev5_count = ""
gen Lev5_percent = ""
gen AvgScaleScore = "--"

//GradeLevel
replace GradeLevel = "G0" + GradeLevel
//Fixing State Level Data
drop State
gen State = "South Dakota"
replace StateAbbrev = "SD"
replace StateFips = 46

//DistName and SchName
replace DistName = "All Districts" if DataLevel==1
replace SchName = "All Schools" if DataLevel ==1
replace SchName = "All Schools" if DataLevel ==2

	
// generating counts 5/31/24
destring StudentSubGroup_TotalTested, replace ignore("--")

local a  "1 2 3 4 5" 
foreach b in `a' {


destring Lev`b'_percent, replace ignore("--")
destring Lev`b'_count, replace ignore("--")



replace Lev`b'_count = Lev`b'_percent * StudentSubGroup_TotalTested if Lev`b'_count == . & Lev`b'_percent != . & StudentSubGroup_TotalTested != .
replace Lev`b'_count = round(Lev`b'_count, 1)


tostring Lev`b'_percent, replace force 
tostring Lev`b'_count, replace force

replace Lev`b'_percent = "--" if  Lev`b'_percent == "." 
replace Lev`b'_count = "--" if  Lev`b'_count == "." 


}


replace Lev5_percent = "" if  Lev5_percent == "--" 
replace Lev5_count = "" if  Lev5_count == "--" 

destring ProficientOrAbove_percent, replace ignore("--")
destring ProficientOrAbove_count, replace ignore("--")

replace ProficientOrAbove_count = ProficientOrAbove_percent * StudentSubGroup_TotalTested if ProficientOrAbove_count == . &  ProficientOrAbove_percent != . & StudentSubGroup_TotalTested != .
replace ProficientOrAbove_count = round(ProficientOrAbove_count, 1)

tostring ProficientOrAbove_percent, replace force
tostring ProficientOrAbove_count, replace force

replace ProficientOrAbove_percent = "--" if  ProficientOrAbove_percent == "." 
replace ProficientOrAbove_count = "--" if  ProficientOrAbove_count == "." 

tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested = "--" if  StudentSubGroup_TotalTested == "." 

replace CountyName = proper(CountyName) // added 6/3/24

replace Subject = "ela" if Subject == "read" 

drop if NCESDistrictID == "MISSING"
drop if NCESSchoolID == "MISSING"



replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 4
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 1

replace StateAssignedSchID = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel ==3


replace DistName=strtrim(DistName) // adjusted district spacing
replace SchName =strtrim(SchName) // adjusted school spacing

replace CountyName = "McCook County" if CountyName == "Mccook County"
replace CountyName = "McPherson County" if CountyName == "Mcpherson County"

 //SD reivew added 6/6/24
 sort GradeLevel Subject DataLevel SchName DistName StudentGroup
by GradeLevel Subject DataLevel SchName DistName (StudentGroup): gen all_students_tested = StudentGroup_TotalTested if StudentGroup == "All Students"
by GradeLevel Subject DataLevel SchName DistName: replace all_students_tested = all_students_tested[_n-1] if missing(all_students_tested)
replace StudentGroup_TotalTested = all_students_tested


drop State_leaid seasch

//Final cleaning and dropping extra variables
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup



//Saving
save "`Output'/SD_AssmtData_`year'.dta" , replace
export delimited "`Output'/SD_AssmtData_`year'", replace	
clear
erase "`temp_`year''"
}




