clear
set more off
set trace off
global NCESOld "/Users/kaitlynlucas/Desktop/Wyoming State Task/NCESOld1"
global Original "/Users/kaitlynlucas/Desktop/Wyoming/Original"
global Output "/Users/kaitlynlucas/Desktop/Wyoming/Output"
global NCES "/Users/kaitlynlucas/Desktop/Wyoming/NCES"
/*
//Cleaning NCES files and putting it into a new folder
forvalues year = 2014/2022 {
local prevyear =`=`year'-1'
	foreach dl in District School {
use "`NCESOld'/NCES_`prevyear'_`dl'.dta"
keep if state_location == "WY" | state_name == "Wyoming"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType

if "`dl'" == "School" drop SchType 
if "`dl'" == "School" rename SchType_str SchType 
if "`dl'" == "School" drop SchVirtual
if "`dl'" == "School" rename SchVirtual_str SchVirtual
if "`dl'" == "School" drop SchLevel 
if "`dl'" == "School" rename SchLevel_str SchLevel

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
save "`NCES'/NCESnew_`prevyear'_`dl'.dta", replace
	}	
}
*/

//Unhide below code on first run
/*
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

*/

//Unhide Above code on first run

//Seperating By Year
forvalues year = 2014/2024 {
use "${Original}/WY_OriginalData_All"
local prevyear =`=`year'-1'
if `year' == 2020 continue
keep if SchoolYear == "`prevyear'" + "-" + substr("`year'",-2,2)
save "${Original}/WY_OriginalData_`year'", replace

//Dropping duplicates for 2019
if `year' == 2019 {
	duplicates drop Subgroup SpecificGrade Subject DistrictName SchoolName DataLevel, force
	drop if SchoolName == "Baldwin Creek"
	drop if SchoolName == "Clearmont K-12"
	drop if SchoolName == "Coffeen Elementary"
	drop if SchoolName == "Gannett Peak"
	drop if SchoolName == "Glenrock High School"
	drop if SchoolName == "Laramie Junior High School"
	drop if SchoolName == "Laramie Montessori"
	drop if SchoolName == "Monroe Elementray School"
	drop if SchoolName == "Munger Mountain Elementary"
	drop if SchoolName == "PODER Secondary School"
	drop if SchoolName == "Riverside High School"
	drop if SchoolName == "Summit Elementary"
	drop if SchoolName == "Sundance Secondary"
}

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
*save "`Original'/WY_OriginalData_`year'", replace

// Drop no student subgroups
drop if StudentSubGroup_TotalTested == "             0" & Subgroup != "All Students"

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
if inlist("`year'", "2023", "2024") {
    use "${NCES}/NCESnew_2022_District"
} 
	else {
    use "${NCES}/NCESnew_`prevyear'_District"
}

/*if "`year'" != "2023" use "${NCES}/NCESnew_`prevyear'_District"
if "`year'" != "2024" use "${NCES}/NCESnew_`prevyear'_District"
if "`year'" == "2023" use "${NCES}/NCESnew_2022_District"
if "`year'" == "2024" use "${NCES}/NCESnew_2022_District"
*/
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
replace school_name = "albany#1-laramiemontessoricharterschool" if school_name == "albany#1-laramiemontessori" & `year' == 2019
replace school_name = "albany#1-laramiemontessoricharterschool" if school_name == "albany#1-laramiemontessori" & `year' == 2022
replace school_name = "albany#1-laramiemontessoricharterschool" if school_name == "albany#1-laramiemontessori" & `year' == 2023
replace school_name = "crook#1-moorcroftsecondaryschool" if school_name == "crook#1-moorcroftsecondary" & `year' == 2014
replace school_name = "crook#1-moorcroftsecondaryschool" if school_name == "crook#1-moorcroftsecondary" & `year' == 2015
replace school_name = "crook#1-moorcroftsecondaryschool" if school_name == "crook#1-moorcroftsecondary" & `year' == 2022
replace school_name = "crook#1-moorcrofthighschool" if school_name == "crook#1-moorcroftsecondary" & `year' == 2023
replace school_name = "crook#1-moorcrofthighschool" if school_name == "crook#1-moorcroftsecondaryschool" & `year' == 2023
replace school_name = "crook#1-moorcroftk-8" if school_name == "crook#1-moorcroftelementary" & (`year' == 2022 | `year' == 2023)
replace school_name = "crook#1-sundancesecondaryschool" if school_name == "crook#1-sundancesecondary" & `year' == 2014
replace school_name = "crook#1-sundancesecondaryschool" if school_name == "crook#1-sundancesecondary" & `year' == 2015
replace school_name = "crook#1-sundancesecondaryschool" if school_name == "crook#1-sundancesecondary" & `year' == 2016
replace school_name = "crook#1-sundancesecondaryschool" if school_name == "crook#1-sundancesecondary" & `year' == 2017
replace school_name = "crook#1-sundancesecondaryschool" if school_name == "crook#1-sundancesecondary" & `year' == 2018
replace school_name = "crook#1-sundancesecondaryschool" if school_name == "crook#1-sundancesecondary" & `year' == 2019
replace school_name = "fremont#1-baldwincreekelementary" if school_name == "fremont#1-baldwincreek" & `year' == 2014
replace school_name = "fremont#1-baldwincreekelementary" if school_name == "fremont#1-baldwincreek" & `year' == 2015
replace school_name = "fremont#1-baldwincreekelementary" if school_name == "fremont#1-baldwincreek" & `year' == 2016
replace school_name = "fremont#1-baldwincreekelementary" if school_name == "fremont#1-baldwincreek" & `year' == 2017
replace school_name = "fremont#1-baldwincreekelementary" if school_name == "fremont#1-baldwincreek" & `year' == 2018
replace school_name = "fremont#1-baldwincreekelementary" if school_name == "fremont#1-baldwincreek" & `year' == 2019
replace school_name = "fremont#1-gannettpeakelementary" if school_name == "fremont#1-gannettpeak" & `year' == 2014
replace school_name = "fremont#1-gannettpeakelementary" if school_name == "fremont#1-gannettpeak" & `year' == 2015
replace school_name = "fremont#1-gannettpeakelementary" if school_name == "fremont#1-gannettpeak" & `year' == 2016
replace school_name = "fremont#1-gannettpeakelementary" if school_name == "fremont#1-gannettpeak" & `year' == 2017
replace school_name = "fremont#1-gannettpeakelementary" if school_name == "fremont#1-gannettpeak" & `year' == 2018
replace school_name = "fremont#1-gannettpeakelementary" if school_name == "fremont#1-gannettpeak" & `year' == 2019
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
replace school_name = "natrona#1-summitelementaryschool" if school_name == "natrona#1-summitelementary" & `year' == 2019
replace school_name = "sheridan#2-henrya.coffeenelementary" if school_name == "sheridan#2-coffeenelementary" & `year' == 2014
replace school_name = "sheridan#2-henrya.coffeenelementary" if school_name == "sheridan#2-coffeenelementary" & `year' == 2015
replace school_name = "sheridan#2-henrya.coffeenelementary" if school_name == "sheridan#2-coffeenelementary" & `year' == 2016
replace school_name = "sheridan#2-henrya.coffeenelementary" if school_name == "sheridan#2-coffeenelementary" & `year' == 2017
replace school_name = "sheridan#2-henrya.coffeenelementary" if school_name == "sheridan#2-coffeenelementary" & `year' == 2018
replace school_name = "sheridan#2-henrya.coffeenelementary" if school_name == "sheridan#2-coffeenelementary" & `year' == 2019
replace school_name = "sheridan#3-clearmontk-12school" if school_name == "sheridan#3-clearmontk-12" & `year' == 2017
replace school_name = "sheridan#3-clearmontk-12school" if school_name == "sheridan#3-clearmontk-12" & `year' == 2018
replace school_name = "sheridan#3-clearmontk-12school" if school_name == "sheridan#3-clearmontk-12" & `year' == 2019
replace school_name = "albany#1-laramiemiddleschool" if school_name == "albany#1-laramiejuniorhighschool" & `year' == 2018
replace school_name = "albany#1-laramiemiddleschool" if school_name == "albany#1-laramiejuniorhighschool" & `year' == 2019
replace school_name = "bighorn#4-riversidemiddle/highschool" if school_name == "bighorn#4-riversidehighschool" & `year' == 2018
replace school_name = "bighorn#4-riversidemiddle/highschool" if school_name == "bighorn#4-riversidehighschool" & `year' == 2019
replace school_name = "laramie#1-poderacademysecondaryschool" if school_name == "laramie#1-podersecondaryschool" & `year' == 2017
replace school_name = "laramie#1-poderacademysecondaryschool" if school_name == "laramie#1-podersecondaryschool" & `year' == 2018
replace school_name = "laramie#1-poderacademysecondaryschool" if school_name == "laramie#1-podersecondaryschool" & `year' == 2019
replace school_name = "sweetwater#2-monroeelementaryschool" if school_name == "sweetwater#2-monroeelementrayschool" & `year' == 2019
replace school_name = "sweetwater#2-monroeelementaryschool" if school_name == "sweetwater#2-monroeelementrayschool" & `year' == 2021
replace school_name = "sweetwater#2-monroeelementaryschool" if school_name == "sweetwater#2-monroeelementrayschool" & `year' == 2022
replace school_name = "teton#1-mungermountainelementaryschool" if school_name == "teton#1-mungermountainelementary" & `year' == 2019
replace school_name = "converse#2-glenrockjr/srhighschool" if school_name == "converse#2-glenrockhighschool" & `year' == 2019
replace school_name = "converse#2-glenrockintermediate/middleschool" if school_name == "converse#2-glenrockintermediateschool" & `year' == 2019
replace school_name = "johnson#1-cloudpeakelementaryschool" if school_name == "johnson#1-cloudpeakelementary" & `year' == 2019
replace school_name = "natrona#1-cyjuniormiddleschool" if school_name == "natrona#1-cymiddleschool" & `year' == 2019
replace school_name = "laramie#1-poderacademysecondaryschool" if school_name == "laramie#1-poder" & `year' == 2022
replace school_name = "laramie#1-poderacademysecondaryschool" if school_name == "laramie#1-poder" & `year' == 2023

//Continuing merge
save "`tempschool'", replace
clear
if inlist("`year'", "2023", "2024") {
    use "${NCES}/NCESnew_2022_School"
} 
	else {
    use "${NCES}/NCESnew_`prevyear'_School"
}
duplicates report school_name
duplicates drop school_name, force
merge 1:m school_name using "`tempschool'"
rename _merge _merge1
if `year' == 2014 {	
replace SchVirtual = "Missing/not reported"
}

if !inlist("`year'", "2022", "2023", "2024"){
	merge m:1 school_name using"${NCES}/NCESnew_`year'_School", update
	rename _merge _merge2
}
if `year' == 2021{
	drop _merge1
}
//code below may need to be reviewed after V2.0
merge m:1 school_name using "${NCES}/NCESnew_2020_School", update
rename _merge _merge3
drop _merge3
save "`tempschool'", replace
clear

*Appending 
use "`temp1'"
keep if DataLevel== "State"
append using "`tempdistrict'" "`tempschool'"
duplicates drop
*save "/Volumes/T7/State Test Project/Wyoming/Testing/`year'", replace


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
gen StateAssignedDistID = State_leaid
gen StateAssignedSchID = seasch

//StudentGroup_TotalTested
gen low_end_subgroup = real(substr(StudentSubGroup_TotalTested, 1, strpos(StudentSubGroup_TotalTested, "-")-2))
gen high_end_subgroup = real(substr(StudentSubGroup_TotalTested, strpos(StudentSubGroup_TotalTested, "-") +2,10))
sort StudentGroup
egen low_end_group = total(low_end_subgroup), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
egen high_end_group =  total(high_end_subgroup), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
gen StudentGroup_TotalTested = string(low_end_group) + "-" + string(high_end_group)
replace StudentGroup_TotalTested = "0" if missing(StudentGroup_TotalTested)
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, " ", "",.)

// Dropping observations with no students tested
drop if StudentSubGroup_TotalTested == "0" & StudentGroup != "All Students"
replace StudentGroup_TotalTested = "0" if StudentGroup_TotalTested == "0-0"

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
if `year' <2018 gen AssmtName = "PAWS"
if `year' > 2017 gen AssmtName = "WY-TOPP"
replace AssmtName = "SAWS" if `year' == 2014 & Subject == "wri"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc="Not applicable"
gen Flag_CutScoreChange_sci = "N"

replace Flag_AssmtNameChange = "Y" if `year' == 2018
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2018 | `year' == 2014
replace Flag_CutScoreChange_math = "Y" if `year' == 2018 | `year' == 2014
replace Flag_CutScoreChange_sci = "Y" if `year' == 2022

//Fix capitalization of county name
replace CountyName = proper(CountyName)

//Generating Empty/missing Variables
gen AvgScaleScore = "--"
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficientOrAbove_count = "--"

// Reset vars before generating counts
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode


// Ranges for level counts for 2022 & 2023

*if `year' == 2022 | `year' == 2023 | `year' == 2024{
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


// Standardizing state ids across years
if `year' == 2014 | `year' == 2015 | `year' == 2016 {
	replace StateAssignedSchID = StateAssignedDistID +"-"+ StateAssignedSchID
	replace StateAssignedDistID = "WY-"+StateAssignedDistID
	replace StateAssignedDistID = "" if DataLevel == 1
	replace StateAssignedSchID = "" if DataLevel != 3
}

if `year' == 2021{
	replace DistType = "Regular local school district" if DistName == "Converse #2"
	replace DistCharter = "No" if DistName == "Converse #2"
	replace DistLocale = "Rural, distant" if DistName == "Converse #2"
	replace CountyName = "Converse County" if DistName == "Converse #2"
	replace CountyCode = "56009" if DistName == "Converse #2"
	replace SchType = "Regular school" if SchName == "Glenrock Intermediate School"
	replace SchLevel = "Middle" if SchName == "Glenrock Intermediate School"
	replace SchVirtual = "No" if SchName == "Glenrock Intermediate School"
	replace DistType = "Regular local school district" if DistName == "Johnson #1"
	replace DistCharter = "No" if DistName == "Johnson #1"
	replace DistLocale = "Rural, fringe" if DistName == "Johnson #1"
	replace CountyName = "Johnson County" if DistName == "Johnson #1"
	replace CountyCode = "56019" if DistName == "Johnson #1"
	replace SchType = "Regular school" if SchName == "Cloud Peak Elementary"
	replace SchLevel = "Primary" if SchName == "Cloud Peak Elementary"
	replace SchVirtual = "No" if SchName == "Cloud Peak Elementary"
	replace DistType = "Regular local school district" if DistName == "Natrona #1"
	replace DistCharter = "No" if DistName == "Natrona #1"
	replace DistLocale = "City, small" if DistName == "Natrona #1"
	replace CountyName = "Natrona County" if DistName == "Natrona #1"
	replace CountyCode = "56025" if DistName == "Natrona #1"
	replace SchType = "Regular school" if SchName == "C Y Middle School"
	replace SchLevel = "Middle" if SchName == "C Y Middle School"
	replace SchVirtual = "No" if SchName == "C Y Middle School"
}

if `year' ==2024{
	replace DistType = "Regular local school district" if SchName == "Laramie Montessori"
	replace DistCharter = "No" if SchName == "Laramie Montessori"
	replace DistLocale = "Town, remote" if SchName == "Laramie Montessori"
	replace SchType = "Regular school" if SchName == "Laramie Montessori"
	replace SchLevel = "Primary" if SchName == "Laramie Montessori"
	replace SchVirtual = "No" if SchName == "Laramie Montessori"
	replace CountyName = "Albany County" if SchName == "Laramie Montessori"
	replace StateAssignedDistID = "WY-0101000" if SchName == "Laramie Montessori"
	replace StateAssignedSchID = "0101000-0101031" if SchName == "Laramie Montessori"
	replace NCESDistrictID = "5600730" if DistName == "Albany #1"
	replace CountyCode = "56001" if SchName == "Laramie Montessori"
	replace DistType = "Regular local school district" if SchName == "PODER"
	replace DistCharter = "No" if SchName == "PODER"
	replace DistLocale = "City, small" if SchName == "PODER"
	replace SchType = "Regular school" if SchName == "PODER"
	replace SchLevel = "Primary" if SchName == "PODER"
	replace SchVirtual = "No" if SchName == "PODER"
	replace CountyName = "Laramie County" if SchName == "PODER"
	replace StateAssignedDistID = "WY-1101000" if SchName == "PODER"
	replace StateAssignedSchID = "1101000-1101040" if SchName == "PODER"
	replace NCESDistrictID = "5601980" if DistName == "Laramie #1"
	replace CountyCode = "56021" if SchName == "PODER"
	replace NCESSchoolID = "560073000542" if SchName == "Laramie Montessori"
	replace NCESSchoolID = "560198000547" if SchName == "PODER"
	//new school/district 2024
	replace StateAssignedDistID = "WY-5003000" if DistName == "Prairie View Community School"
	replace DistType = "Charter agency" if DistName == "Prairie View Community School"
	replace DistCharter = "Yes" if DistName == "Prairie View Community School"
	replace DistLocale = "Missing/not reported" if DistName == "Prairie View Community School"
	replace NCESSchoolID = "568025900599" if SchName == "Prairie View Community School"
	replace SchType = "Regular school" if SchName == "Prairie View Community School"
	replace SchLevel = "Other" if SchName == "Prairie View Community School"
	replace SchVirtual = "No" if SchName == "Prairie View Community School"
	replace StateAssignedSchID = "5003000-5003001" if SchName == "Prairie View Community School"
	replace NCESDistrictID = "5680259" if DistName == "Prairie View Community School"
	replace CountyName = "Platte County" if DistName == "Prairie View Community School"
	replace CountyCode = "56031" if DistName == "Prairie View Community School"
	//new school /district
	replace DistType = "Charter agency" if DistName == "Wyoming Classical Academy"
	replace DistCharter = "Yes" if DistName == "Wyoming Classical Academy"
	replace DistLocale = "Missing/not reported" if DistName == "Wyoming Classical Academy"
	replace StateAssignedDistID = "WY-5002000" if DistName == "Wyoming Classical Academy"
	replace CountyName = "Natrona County" if DistName == "Wyoming Classical Academy"
	replace CountyCode = "56025" if DistName == "Wyoming Classical Academy"
	replace SchType = "Regular school" if SchName == "Wyoming Classical Academy"
	replace SchLevel = "Primary" if SchName == "Wyoming Classical Academy"
	replace SchVirtual = "No" if SchName == "Wyoming Classical Academy"
	replace StateAssignedSchID = "5002000-5002001" if SchName == "Wyoming Classical Academy"
	replace NCESDistrictID = "5680258" if DistName == "Wyoming Classical Academy"
	replace NCESSchoolID = "568025800598" if SchName == "Wyoming Classical Academy"
}

//Fixing Space Issues
replace SchName = "Albany #1 - Indian Paintbrush Elementary" if SchName == "Albany #1 - Indian Paintbrush  Elementary"
replace SchName = "Indian Paintbrush Elementary" if SchName == "Indian Paintbrush  Elementary"


//adding update StudentGroup_TotalTested code V2.0
{
replace StateAssignedDistID = "000000" if DataLevel== 1 // State
replace StateAssignedSchID = "000000" if DataLevel== 1 // State
replace StateAssignedSchID = "000000" if DataLevel== 2 // District
egen uniquegrp = group(SchYear DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup 
by uniquegrp: gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by uniquegrp: replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
drop StudentGroup_TotalTested
rename AllStudents StudentGroup_TotalTested
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel != 3
}

//Period issues in 2014, 2017, 2018 for 7 observations
forvalues n = 1/4 {
	replace Lev`n'_count = "--" if Lev`n'_count == "."
}
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == ".-."

//June 2024 State Task
replace AssmtType = "Regular and alt"



//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
drop if missing(DataLevel)
save "${Output}/WY_AssmtData_`year'", replace
export delimited using "${Output}/WY_AssmtData_`year'", replace

clear
}


