*******************************************************
* WYOMING

* File name: 01_WY_Cleaning_14_18
* Last update: 03/01/2025

*******************************************************
* Notes

	* This do file cleans WY's yearly data from 2014 through 2018 and merges with NCES.

*******************************************************

clear all
set more off
set trace off

//Cleaning NCES Files - Hide After First Run
forvalues year = 2014/2018 {
local prevyear =`=`year'-1'
foreach dl in District School {

use "${NCES`dl'}/NCES_`prevyear'_`dl'.dta", clear
keep if state_location == "WY" | state_name == "Wyoming"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType

if "`dl'" == "School" {
	drop SchType
	drop SchVirtual SchLevel
	rename SchType_str SchType
	rename SchVirtual_str SchVirtual
	rename SchLevel_str SchLevel
}

rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
if "`dl'" == "School" rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 56
replace StateAbbrev = "WY"
replace lea_name = subinstr(lea_name, " ", "",.)
replace lea_name = lower(lea_name)
replace lea_name = subinstr(lea_name, "countyschooldistrict", "",.)

if "`dl'" == "School" replace school_name = lower(school_name)
if "`dl'" == "School" replace school_name = subinstr(school_name, " ", "",.)
if "`dl'" == "School" replace school_name = lea_name + "-" + school_name
cap duplicates drop school_name, force 
save "${NCES}/NCES_`prevyear'_`dl'_WY.dta", replace
	}	
}

//Import Raw Data - Hide After First Run
clear
import delimited using "${Original}/WY_OriginalData_All_District.csv", case(preserve)
gen DataLevel = "District"
save "${Original}/WY_OriginalData_All_District.dta", replace
clear
import delimited using "${Original}/WY_OriginalData_All_School.csv", case(preserve)
gen DataLevel = "School"
save "${Original}/WY_OriginalData_All_School.dta", replace
clear
import delimited using "${Original}/WY_OriginalData_All_State.csv", case(preserve)
gen DataLevel = "State"
save "${Original}/WY_OriginalData_All_State.dta", replace

append using "${Original}/WY_OriginalData_All_District.dta" "${Original}/WY_OriginalData_All_School.dta"
save "${Original}/WY_OriginalData_All", replace
clear

//Separating By Year
forvalues year = 2014/2018 {
use "${Original}/WY_OriginalData_All", clear
local prevyear =`=`year'-1'
keep if SchoolYear == "`prevyear'" + "-" + substr("`year'",-2,2)
save "${Original}/WY_OriginalData_`year'", replace

//Renaming Varnames
rename SchoolYear SchYear
rename DistrictName DistName
rename SchoolName SchName
rename SpecificGrade GradeLevel
rename NoofStudentsTested StudentSubGroup_TotalTested
rename PercentBelowBasic Lev1_percent
rename PercentBasic Lev2_percent
rename PercentProficient Lev3_percent
rename PercentAdvanced Lev4_percent
drop PercentBasicBelow
rename PercentProficientAdvanced ProficientOrAbove_percent


//GradeLevels
keep if GradeLevel >= 3 & GradeLevel <= 8
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

//StudentSubGroup 
replace Subgroup = "All Students: All Students" if Subgroup == "All Students"
gen StudentGroup = substr(Subgroup, 1, strpos(Subgroup, ":") - 1)
gen StudentSubGroup = substr(Subgroup, strpos(Subgroup, ":") + 2, .)

replace StudentSubGroup = "English Proficient" if strpos(StudentSubGroup, "Non-English Learner") !=0
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Low Income"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Low Income"
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "American Indian") !=0
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Native Hawaiian") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two or More Races") !=0
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Non-Military Connected"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without Disabilities"


replace StudentGroup = "EL Status" if StudentGroup == "English Learner Status"
replace StudentGroup = "Economic Status" if StudentGroup == "Income Status"
replace StudentGroup = "RaceEth" if StudentGroup == "Race / Ethnicity"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"


keep if StudentGroup == "All Students" | StudentGroup == "Disability Status" | StudentGroup == "EL Status" | StudentGroup == "Foster Care Status" | StudentGroup == "Gender" | StudentGroup == "Homeless Enrolled Status" | StudentGroup == "Economic Status" | StudentGroup == "Migrant Status" | StudentGroup == "Military Connected Status" | StudentGroup == "RaceEth"


//Merging with NCES
tempfile temp1
save "`temp1'"

*District
keep if DataLevel == "District"
gen lea_name = DistName
replace lea_name = subinstr(lea_name, " ", "",.)
replace lea_name = lower(lea_name)
tempfile tempdistrict
save "`tempdistrict'"
clear
use "${NCES}/NCES_`prevyear'_District_WY"

merge 1:m lea_name using "`tempdistrict'"
drop if _merge==1
save "`tempdistrict'", replace


*School
use "`temp1'"
keep if DataLevel == "School"
gen lea_name = DistName
replace lea_name = subinstr(lea_name, " ", "",.)
replace lea_name = lower(lea_name)
gen school_name = SchName
replace school_name = subinstr(school_name, " ", "",.)
replace school_name = lower(school_name)
replace school_name = subinstr(school_name, lea_name + "-","",.)
replace school_name = lea_name + "-" + school_name
tempfile tempschool

//Replacing a number of school names with the names listed in NCES 
replace school_name = "albany#1-laramiemontessoricharterschool" if school_name == "albany#1-laramiemontessori" & `year' == 2014
replace school_name = "albany#1-laramiemontessoricharterschool" if school_name == "albany#1-laramiemontessori" & `year' == 2015
replace school_name = "albany#1-laramiemontessoricharterschool" if school_name == "albany#1-laramiemontessori" & `year' == 2016
replace school_name = "albany#1-laramiemontessoricharterschool" if school_name == "albany#1-laramiemontessori" & `year' == 2017
replace school_name = "albany#1-laramiemontessoricharterschool" if school_name == "albany#1-laramiemontessori" & `year' == 2018
replace school_name = "crook#1-moorcroftsecondaryschool" if school_name == "crook#1-moorcroftsecondary" & `year' == 2014
replace school_name = "crook#1-moorcroftsecondaryschool" if school_name == "crook#1-moorcroftsecondary" & `year' == 2015
replace school_name = "crook#1-sundancesecondaryschool" if school_name == "crook#1-sundancesecondary" & `year' == 2014
replace school_name = "crook#1-sundancesecondaryschool" if school_name == "crook#1-sundancesecondary" & `year' == 2015
replace school_name = "crook#1-sundancesecondaryschool" if school_name == "crook#1-sundancesecondary" & `year' == 2016
replace school_name = "crook#1-sundancesecondaryschool" if school_name == "crook#1-sundancesecondary" & `year' == 2017
replace school_name = "crook#1-sundancesecondaryschool" if school_name == "crook#1-sundancesecondary" & `year' == 2018
replace school_name = "fremont#1-baldwincreekelementary" if school_name == "fremont#1-baldwincreek" & `year' == 2014
replace school_name = "fremont#1-baldwincreekelementary" if school_name == "fremont#1-baldwincreek" & `year' == 2015
replace school_name = "fremont#1-baldwincreekelementary" if school_name == "fremont#1-baldwincreek" & `year' == 2016
replace school_name = "fremont#1-baldwincreekelementary" if school_name == "fremont#1-baldwincreek" & `year' == 2017
replace school_name = "fremont#1-baldwincreekelementary" if school_name == "fremont#1-baldwincreek" & `year' == 2018
replace school_name = "fremont#1-gannettpeakelementary" if school_name == "fremont#1-gannettpeak" & `year' == 2014
replace school_name = "fremont#1-gannettpeakelementary" if school_name == "fremont#1-gannettpeak" & `year' == 2015
replace school_name = "fremont#1-gannettpeakelementary" if school_name == "fremont#1-gannettpeak" & `year' == 2016
replace school_name = "fremont#1-gannettpeakelementary" if school_name == "fremont#1-gannettpeak" & `year' == 2017
replace school_name = "fremont#1-gannettpeakelementary" if school_name == "fremont#1-gannettpeak" & `year' == 2018
replace school_name = "johnson#1-cloudpeakelementaryschool" if school_name == "johnson#1-cloudpeakelementary" & `year' == 2014
replace school_name = "johnson#1-cloudpeakelementaryschool" if school_name == "johnson#1-cloudpeakelementary" & `year' == 2015
replace school_name = "johnson#1-cloudpeakelementaryschool" if school_name == "johnson#1-cloudpeakelementary" & `year' == 2016
replace school_name = "johnson#1-cloudpeakelementaryschool" if school_name == "johnson#1-cloudpeakelementary" & `year' == 2017
replace school_name = "johnson#1-cloudpeakelementaryschool" if school_name == "johnson#1-cloudpeakelementary" & `year' == 2018
replace school_name = "Missing/not reported" if school_name == "lincoln#1-kemmereralternativeschool" & `year' == 2014
replace school_name = "natrona#1-summitelementaryschool" if school_name == "natrona#1-summitelementary" & `year' == 2014
replace school_name = "natrona#1-summitelementaryschool" if school_name == "natrona#1-summitelementary" & `year' == 2015
replace school_name = "natrona#1-summitelementaryschool" if school_name == "natrona#1-summitelementary" & `year' == 2016
replace school_name = "natrona#1-summitelementaryschool" if school_name == "natrona#1-summitelementary" & `year' == 2017
replace school_name = "natrona#1-summitelementaryschool" if school_name == "natrona#1-summitelementary" & `year' == 2018
replace school_name = "sheridan#2-henrya.coffeenelementary" if school_name == "sheridan#2-coffeenelementary" & `year' == 2014
replace school_name = "sheridan#2-henrya.coffeenelementary" if school_name == "sheridan#2-coffeenelementary" & `year' == 2015
replace school_name = "sheridan#2-henrya.coffeenelementary" if school_name == "sheridan#2-coffeenelementary" & `year' == 2016
replace school_name = "sheridan#2-henrya.coffeenelementary" if school_name == "sheridan#2-coffeenelementary" & `year' == 2017
replace school_name = "sheridan#2-henrya.coffeenelementary" if school_name == "sheridan#2-coffeenelementary" & `year' == 2018
replace school_name = "sheridan#3-clearmontk-12school" if school_name == "sheridan#3-clearmontk-12" & `year' == 2017
replace school_name = "sheridan#3-clearmontk-12school" if school_name == "sheridan#3-clearmontk-12" & `year' == 2018
replace school_name = "albany#1-laramiemiddleschool" if school_name == "albany#1-laramiejuniorhighschool" & `year' == 2018
replace school_name = "bighorn#4-riversidemiddle/highschool" if school_name == "bighorn#4-riversidehighschool" & `year' == 2018
replace school_name = "laramie#1-poderacademysecondaryschool" if school_name == "laramie#1-podersecondaryschool" & `year' == 2017
replace school_name = "laramie#1-poderacademysecondaryschool" if school_name == "laramie#1-podersecondaryschool" & `year' == 2018

//Continuing merge
save "`tempschool'", replace
clear

use "${NCES}/NCES_`prevyear'_School_WY"
duplicates report school_name
duplicates drop school_name, force
merge 1:m school_name using "`tempschool'"
rename _merge _merge1
if `year' == 2014 {	
replace SchVirtual = "Missing/not reported"
}

merge m:1 school_name using"${NCES}/NCES_`year'_School_WY", update
rename _merge _merge2

//code below may need to be reviewed after V2.0
merge m:1 school_name using "${NCES}/NCES_2020_School_WY", update
rename _merge _merge3
drop _merge3
save "`tempschool'", replace
clear

*Appending 
use "`temp1'"
keep if DataLevel== "State"
append using "`tempdistrict'" "`tempschool'"
duplicates drop

//2014: No Data for unmerged Kemmerer Alternative School
if `year' == 2014 drop if SchName == "Lincoln #1 - Kemmerer Alternative School"

//State level values
replace StateFips = 56
replace StateAbbrev = "WY"
gen State = "Wyoming"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
order DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3

//Subject
replace Subject = "math" if Subject == "Math"
replace Subject = "ela" if strpos(Subject, "ELA") !=0 | Subject == "Reading"
replace Subject = "sci" if Subject == "Science"
replace Subject = "wri" if Subject == "Writing"


//StateAssignedSchID and StateAssignedDistID
gen StateAssignedDistID = subinstr(State_leaid, "WY-", "", 1)
gen StateAssignedSchID = subinstr(seasch, StateAssignedDistID, "", 1)
replace StateAssignedSchID = subinstr(StateAssignedSchID, "-", "", 1)

//StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = strtrim(StudentSubGroup_TotalTested)
drop if StudentSubGroup_TotalTested == "0"
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, " ", "", 2)

gen low_end_subgroup = real(substr(StudentSubGroup_TotalTested, 1, strpos(StudentSubGroup_TotalTested, "-")-2))
gen high_end_subgroup = real(substr(StudentSubGroup_TotalTested, strpos(StudentSubGroup_TotalTested, "-") +2,10))
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, " ", "",.)

// Dropping observations with no students tested
drop if StudentSubGroup_TotalTested == "0" & StudentGroup != "All Students"

//Level counts and percents
foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
	destring Lev`n'_percent, gen(nLev`n'_percent) i(%)
	replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.4g")
	replace Lev`n'_percent = "*" if missing(nLev`n'_percent)
	replace Lev`n'_percent = "--" if StudentSubGroup_TotalTested == "0"
}

//ProficientOrAbove_percent
gen ranges = substr(ProficientOrAbove_percent, 1,2) if regexm(ProficientOrAbove_percent, "[<>=]") !=0
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(%<>=)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100, "%9.4g") if strpos(ProficientOrAbove_percent, "%")!=0
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100, "%9.4g") + "-1" if strpos(ranges, ">")!=0
replace ProficientOrAbove_percent = "0-" + string(nProficientOrAbove_percent/100, "%9.4g") if strpos(ranges, "<")!=0
replace ProficientOrAbove_percent = "*" if missing(nProficientOrAbove_percent)
replace ProficientOrAbove_percent = "--" if StudentSubGroup_TotalTested == "0"

//ParticipationRate
destring ParticipationRate, gen(nParticipationRate) i(%)
replace ParticipationRate = string(nParticipationRate/100, "%9.4g")
replace ParticipationRate = "*" if missing(nParticipationRate)
replace ParticipationRate = "--" if StudentSubGroup_TotalTested == "0" 

//Generating Informational Variables 
gen ProficiencyCriteria = "Levels 3-4"
if `year' < 2018 gen AssmtName = "PAWS"
if `year' > 2017 gen AssmtName = "WY-TOPP"
replace AssmtName = "SAWS" if `year' == 2014 & Subject == "wri"
gen AssmtType = "Regular and alt"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc="Not applicable"
gen Flag_CutScoreChange_sci = "N"

replace Flag_AssmtNameChange = "Y" if `year' == 2018
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2018 | `year' == 2014
replace Flag_CutScoreChange_math = "Y" if `year' == 2018 | `year' == 2014

//Fix capitalization of county name
replace CountyName = proper(CountyName)

//Generating Empty/missing Variables
gen AvgScaleScore = "--"
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficientOrAbove_count = "--"

// Reset vars before generating counts
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

//Fixing Space Issues
replace SchName = "Albany #1 - Indian Paintbrush Elementary" if SchName == "Albany #1 - Indian Paintbrush  Elementary"
replace SchName = "Indian Paintbrush Elementary" if SchName == "Indian Paintbrush  Elementary"

//StudentGroup_TotalTested
replace StateAssignedDistID = "000000" if DataLevel== 1
replace StateAssignedSchID = "000000" if DataLevel != 3
egen uniquegrp = group(SchYear DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup 
by uniquegrp: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by uniquegrp: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel != 3

// Ranges for level counts

gen low_end_subgroup = real(substr(StudentSubGroup_TotalTested, 1, strpos(StudentSubGroup_TotalTested, "-") - 1))
destring StudentGroup_TotalTested, gen(xStudentGroup_TotalTested) force
gen high_end_subgroup = real(substr(StudentSubGroup_TotalTested, strpos(StudentSubGroup_TotalTested, "-") + 1, 4))
replace high_end_subgroup = xStudentGroup_TotalTested if (xStudentGroup_TotalTested < high_end_subgroup)
replace StudentSubGroup_TotalTested = string(low_end_subgroup)+"-"+string(high_end_subgroup) if strpos(StudentSubGroup_TotalTested, "-")>0
replace StudentSubGroup_TotalTested = string(high_end_subgroup) if high_end_subgroup == low_end_subgroup
forvalues n = 1/4 {
	destring Lev`n'_percent, gen(nLev`n'_percent) force
	gen lowLev`n'_count = round(nLev`n'_percent*low_end_subgroup)
	gen highLev`n'_count = round(nLev`n'_percent*high_end_subgroup)
	gen rangeLev`n'_count = string(lowLev`n'_count)+"-"+string(highLev`n'_count)
	replace rangeLev`n'_count = string(lowLev`n'_count) if lowLev`n'_count == highLev`n'_count
	replace Lev`n'_count = rangeLev`n'_count if Lev`n'_count == "--"
	replace Lev`n'_count = "*" if Lev`n'_percent == "*"
}

gen lowProfCount = string(round(lowLev3_count + lowLev4_count))
gen highProfCount = string(round(highLev3_count + highLev4_count))
replace ProficientOrAbove_count = lowProfCount+"-"+highProfCount if ProficientOrAbove_count == "--"

split ProficientOrAbove_percent, parse("-")
destring ProficientOrAbove_percent1 ProficientOrAbove_percent2, replace force
gen lowProficientOrAbove_count = round(ProficientOrAbove_percent1*low_end_subgroup)
gen highProficientOrAbove_count = round(ProficientOrAbove_percent2*high_end_subgroup)
replace highProficientOrAbove_count = round(ProficientOrAbove_percent1*high_end_subgroup) if ProficientOrAbove_percent2 == .
gen rangeProficientOrAbove_count = string(lowProficientOrAbove_count)+"-"+string(highProficientOrAbove_count)
replace rangeProficientOrAbove_count = string(lowProficientOrAbove_count) if lowProficientOrAbove_count == highProficientOrAbove_count
replace ProficientOrAbove_count = rangeProficientOrAbove_count if inlist(ProficientOrAbove_count, "--", ".-.")
replace ProficientOrAbove_count = "*" if ProficientOrAbove_percent == "*"

//Period issues in 2014, 2017, 2018 for 7 observations
forvalues n = 1/4 {
	replace Lev`n'_count = "--" if Lev`n'_count == "."
}
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == ".-."


//Replacing Assessment name after 2018
if `year'>2017 {
	replace AssmtName = "WY-TOPP and WY-ALT" if AssmtName == "WY-TOPP"
}

//Fixing one school
replace NCESSchoolID = "560198000574" if SchName == "PODER Academy Secondary School"
replace StateAssignedSchID = "1101045" if SchName == "PODER Academy Secondary School"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
drop if missing(DataLevel)
save "${Output}/WY_AssmtData_`year'", replace
export delimited using "${Output}/WY_AssmtData_`year'", replace

clear
}


