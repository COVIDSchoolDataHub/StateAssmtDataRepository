clear
set more off
set trace off

cd "/Volumes/T7/State Test Project/South Dakota"
global Original "/Volumes/T7/State Test Project/South Dakota/Original Data"
global Output "/Volumes/T7/State Test Project/South Dakota/Output"
global NCES_District "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_School "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global Stata_versions "/Volumes/T7/State Test Project/South Dakota/Stata .dta versions"
global EDFacts "/Volumes/T7/State Test Project/EDFACTS"

//Hide below after first run

// foreach year in 2015 2016 2017 {
// 	foreach Subject in ELA Math Science {
// 		foreach dl in State District School {
// 		local sheetyear = string(real(substr("`year'",-2,2))-1) + string(real(substr("`year'",-2,2)))
// 		import excel "$Original/SD_OriginalData_`year'_`Subject'", cellrange(A7) sheet("`Subject'`dl'`sheetyear'") allstring clear
// 		save "/SD_OriginalData_`year'_`Subject'_`dl'", replace
// 		}
// 	}
// }
//Hide above after first run


foreach year in 2015 2016 2017 {
	clear
	tempfile temp`year'
	save "`temp`year''", empty
	foreach Subject in ELA Math Science {
		foreach dl in State District School {
			
use "$Original/SD_OriginalData_`year'_`Subject'_`dl'", clear

//Fill in StudentSubGroup values above level percents			
ds
local vars `r(varlist)'
local nvars: word count `vars'
forval i = 2/`nvars' {
    local thisvar : word `i' of `vars'
    local prevvar : word `=`i'-1' of `vars'

    replace `thisvar' = `prevvar' if missing(`thisvar') in 1
}

//Replace variables with valid stata names for variable values in the first row
foreach var of varlist _all {
	replace `var' = `var'[_n+1] + `var' in 1
	replace `var' = subinstr(`var', " ", "",.) in 1
	replace `var' = subinstr(`var', "-","",.) in 1
}

drop in 2 //extra row

//Science has Adv, Prof, etc rather than Lev4, Lev3, etc

if "`Subject'" == "Science" {
foreach var of varlist _all {
	replace `var' = subinstr(`var', "BelowBasic", "Lvl1",.) in 1
	replace `var' = subinstr(`var', "Adv", "Lvl4",.) in 1
	replace `var' = subinstr(`var', "Prof", "Lvl3",.) in 1
	replace `var' = subinstr(`var', "Basic", "Lvl2",.) in 1
}
}

//Rename
foreach oldvar of varlist _all {
	local newvar = `oldvar' in 1
	rename `oldvar' `newvar'
}

drop in 1 //extra row
drop if missing(Grade) // getting rid of all empty rows

if `year' == 2017 cap rename CountyDistrictID CountyDistrictNumber //different varname in 2017

//Reshaping (Identifier different based on datalevel)
if "`dl'" == "State" reshape long Lvl1 Lvl2 Lvl3 Lvl4, i(Grade) j(StudentSubGroup, string)
if "`dl'" == "District" reshape long Lvl1 Lvl2 Lvl3 Lvl4, i(CountyDistrictNumber Grade) j(StudentSubGroup, string)
if "`dl'" == "School" reshape long Lvl1 Lvl2 Lvl3 Lvl4, i(CountyDistrictNumber SchoolNumber Grade) j(StudentSubGroup, string)

gen DataLevel = "`dl'"
gen Subject = "`Subject'"
append using "`temp`year''"
save "`temp`year''", replace
		}
	}
use "`temp`year''", clear
keep CountyDistrictNumber SchoolNumber Grade StudentSubGroup DistrictName SchoolName NumberTested Lvl4 Lvl3 Lvl2 Lvl1 DataLevel Subject

save "$Original/SD_OriginalData_`year'", replace	

//Rename Vars
rename CountyDistrictNumber StateAssignedDistID
rename SchoolNumber StateAssignedSchID
rename Grade GradeLevel
rename DistrictName DistName
rename SchoolName SchName
rename NumberTested StudentSubGroup_TotalTested
rename Lvl4 Lev4_percent
rename Lvl3 Lev3_percent
rename Lvl2 Lev2_percent
rename Lvl1 Lev1_percent

//StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup != "AllStudents"

//GradeLevel
drop if real(GradeLevel) > 8 | real(GradeLevel) < 3
replace GradeLevel = "G0" + GradeLevel

//StudentSubGroup
replace StudentSubGroup = "All Students" if StudentSubGroup == "AllStudents"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "EconomicallyDisadvantaged"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EnglishLanguageLearners" | strpos(StudentSubGroup, "LimitedEnglish") !=0
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "NativeAmerican"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "PacificIslander"
replace StudentSubGroup = "SWD" if strpos(StudentSubGroup, "Disabilities") !=0
replace StudentSubGroup = "Two or More" if StudentSubGroup == "TwoorMoreRaces"
drop if strpos(StudentSubGroup, "Gap") !=0

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex" | StudentSubGroup == "EL Exited" | StudentSubGroup == "EL and Monit or Recently Ex" | StudentSubGroup == "Ever EL" | StudentSubGroup == "LTEL"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//Level counts & percents
foreach percent of varlist *_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	replace `percent' = string(real(`percent')/100) if !missing(real(`percent'))
	replace `percent' = "*" if missing(real(`percent'))
	gen `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested))
	replace `count' = "*" if `percent' == "*"
	replace `count' = "--" if missing(`count')
}
gen ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent), "%9.4g") if !missing(real(Lev3_percent)) & !missing(real(Lev4_percent))
gen ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev3_count)) & !missing(real(Lev4_count))

//DataLevel 
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3

//Subject
replace Subject = lower(Subject)
replace Subject = "sci" if Subject == "science"

//NCES Merging
local prevyear = `year' -1
replace StateAssignedDistID = string(real(StateAssignedDistID),"%05.0f") if DataLevel !=1
replace StateAssignedSchID = StateAssignedDistID + string(real(StateAssignedSchID), "%02.0f") if DataLevel == 3
tempfile temp1
save "`temp1'", replace
clear

// District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace

use "$NCES_District/NCES_`prevyear'_District"
keep if state_fips_id == 46 | state_name == "South Dakota"
gen StateAssignedDistID = subinstr(state_leaid, "SD-","",.)
merge 1:m StateAssignedDistID using "`tempdist'"

drop if _merge == 1
drop year
save "`tempdist'", replace
clear

// School
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear

use "$NCES_School/NCES_`prevyear'_School"
keep if state_fips_id == 46 | state_name == "South Dakota"
if `year' != 2017 gen StateAssignedSchID = state_leaid + seasch
if `year' == 2017 gen StateAssignedSchID = subinstr(seasch, "-","",.)
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge == 1
drop year
save "`tempsch'", replace
clear

//Appending
use "`temp1'", clear
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
if `year' == 2023 {
 rename school_type SchType
 }
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
gen State = "South Dakota"
replace StateFips = 46
replace StateAbbrev = "SD"
replace SchVirtual = -1 if missing(SchVirtual) & DataLevel ==3

//Indicator Variables
gen ProficiencyCriteria = "Levels 3-4"

gen ParticipationRate = "--"

gen AvgScaleScore = "--"

gen Lev5_count = ""
gen Lev5_percent = ""

gen AssmtName = ""
replace AssmtName = "SBAC" if Subject != "sci"
replace AssmtName = "DSTEP" if Subject == "sci"
replace AssmtName = "SDSA 1.0" if Subject == "sci" & `year' == 2017
gen AssmtType = "Regular and alt"

gen SchYear = "`prevyear'-" + substr("`year'", -2,2)

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N" 
gen Flag_CutScoreChange_soc = "Not applicable"

if `year' == 2015 replace Flag_AssmtNameChange = "Y" if Subject == "ela" | Subject == "math"
if `year' == 2017 replace Flag_AssmtNameChange = "Y" if Subject == "sci"
if `year' == 2015 replace Flag_CutScoreChange_ELA = "Y" 
if `year' == 2015 replace Flag_CutScoreChange_math = "Y"
if `year' == 2017 replace Flag_CutScoreChange_sci = "Y"

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

gen Derivable = 1 if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0 & !missing(real(StudentGroup_TotalTested)-UnsuppressedSG) & StudentSubGroup != "All Students"

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if Derivable == 1

drop Unsuppressed* missing_* Derivable

//Level percent (and corresponding count) derivations if we have all other percents
replace Lev1_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent))

replace Lev2_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent))

replace Lev3_percent = string(1-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))

replace Lev4_percent = string(1-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))

foreach percent of varlist Lev*_percent {
	replace `percent' = "0" if real(`percent') <  0.005 & !missing(real(`percent'))
}

replace ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent)) if !missing(real(Lev3_percent)) & !missing(real(Lev4_percent)) & missing(real(ProficientOrAbove_percent))

foreach count of varlist Lev*_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
	replace `percent' = string(real(`percent'), "%9.4g") if !missing(real(`percent'))
}


//Misc Fixes
drop if missing(DistName)
replace StateAssignedSchID = substr(StateAssignedSchID,1,5) + "-" + substr(StateAssignedSchID,-2,2) if DataLevel == 3
replace DistName = subinstr(DistName, "School District ", "",.)
replace ProficientOrAbove_percent = "1" if real(ProficientOrAbove_percent) > 1 & !missing(real(ProficientOrAbove_percent))
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev3_count)) & !missing(real(Lev4_count))
replace ProficientOrAbove_count = "--" if missing(real(ProficientOrAbove_count))
replace ProficientOrAbove_percent = "--" if missing(real(ProficientOrAbove_percent))
drop if SchName == "Out of District Placement"
if `year' == 2017 drop if SchName == "Northeast Educational Services Cooperative - 01" & missing(NCESDistrictID) //No data, also not a standard school
replace Lev5_count = ""

if `year' == 2015 {
replace CountyName = proper(CountyName)
replace CountyName = "McPherson County" if CountyName == "Mcpherson County"
replace CountyName = "McCook County" if CountyName == "Mccook County"
} 



//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Output/SD_AssmtData_`year'", replace
export delimited "$Output/SD_AssmtData_`year'", replace

}
