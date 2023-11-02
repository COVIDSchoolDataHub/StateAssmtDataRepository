clear
set more off
set trace off
cd "/Volumes/T7/State Test Project/Wyoming"
local Original "/Volumes/T7/State Test Project/Wyoming/Original Data Files"
local Output "/Volumes/T7/State Test Project/Wyoming/Output"
local NCES "/Volumes/T7/State Test Project/Wyoming/NCES"

//Unhide below code on first run

/*

import delimited using "`Original'/WY_OriginalData_All_District.csv", case(preserve)
gen DataLevel = "District"
save "`Original'/WY_OriginalData_All_District.dta", replace
clear
import delimited using "`Original'/WY_OriginalData_All_School.csv", case(preserve)
gen DataLevel = "School"
save "`Original'/WY_OriginalData_All_School.dta", replace
clear
import delimited using "`Original'/WY_OriginalData_All_State.csv", case(preserve)
gen DataLevel = "State"
save "`Original'/WY_OriginalData_All_State.dta", replace

append using "`Original'/WY_OriginalData_All_District.dta" "`Original'/WY_OriginalData_All_School.dta"
save "`Original'/WY_OriginalData_All"
clear

*/

//Unhide Above code on first run

//Seperating By Year
forvalues year = 2014/2023 {
use "`Original'/WY_OriginalData_All"
local prevyear =`=`year'-1'
if `year' == 2020 continue
keep if SchoolYear == "`prevyear'" + "-" + substr("`year'",-2,2)
save "`Original'/WY_OriginalData_`year'", replace


//Renaming Varnames
rename SchoolYear SchYear
rename DistrictName DistName
rename SchoolName SchName
rename Subgroup StudentSubGroup
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

//StudentSubGroup 
replace StudentSubGroup = "English Learner" if strpos(StudentSubGroup, "English Learner Status: English Learner") !=0
replace StudentSubGroup = "English Proficient" if strpos(StudentSubGroup, "English Learner Status: Non-English") !=0
replace StudentSubGroup = "Male" if strpos(StudentSubGroup, "Gender: Male") !=0
replace StudentSubGroup = "Female" if strpos(StudentSubGroup, "Gender: Female") !=0
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Income Status: Low Income"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Income Status: Non-Low Income"
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "Race / Ethnicity: American Indian") !=0
replace StudentSubGroup = "Asian" if StudentSubGroup == "Race / Ethnicity: Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Race / Ethnicity: Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Race / Ethnicity: Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Race / Ethnicity: Native Hawaiian") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Race / Ethnicity: Two or More Races") !=0
replace StudentSubGroup = "White" if StudentSubGroup == "Race / Ethnicity: White"

keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"

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
if "`year'" != "2023" use "`NCES'/NCESnew_`prevyear'_District"
if "`year'" == "2023" use "`NCES'/NCESnew_2021_District"
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
replace school_name = "laramie#1-poderacademysecondaryschool" if school_name == "laramie#1-poder" & `year' == 2022
replace school_name = "laramie#1-poderacademysecondaryschool" if school_name == "laramie#1-poder" & `year' == 2023

//Continuing merge
save "`tempschool'", replace
clear
if "`year'" != "2023" use "`NCES'/NCESnew_`prevyear'_School"
if "`year'" == "2023" use "`NCES'/NCESnew_2021_School"
duplicates report school_name
duplicates drop school_name, force
merge 1:m school_name using "`tempschool'"
rename _merge _merge1
if `year' == 2014 {	
label def SchVirtual -1 "Missing/not reported"
encode SchVirtual, gen(nSchVirtual) label(SchVirtual)
drop SchVirtual
rename nSchVirtual SchVirtual
}

if `year' != 2023 & `year' != 2022 merge m:1 school_name using "`NCES'/NCESnew_`year'_School", update

rename _merge _merge2
merge m:1 school_name using "`NCES'/NCESnew_2020_School", update

rename _merge _merge3
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


//Level counts and percents
foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
	destring Lev`n'_percent, gen(nLev`n'_percent) i(%)
	replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.4g")
	replace Lev`n'_percent = "*" if missing(nLev`n'_percent)
	replace Lev`n'_percent = "--" if StudentSubGroup_TotalTested == "0"
}

//ProficientOrAbove_percent
gen range = substr(ProficientOrAbove_percent, 1,2) if regexm(ProficientOrAbove_percent, "[<>=]") !=0
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(%<>=)
replace ProficientOrAbove_percent = range + " " + string(nProficientOrAbove_percent/100, "%9.4g")
replace ProficientOrAbove_percent = "*" if missing(nProficientOrAbove_percent)
replace ProficientOrAbove_percent = "--" if StudentSubGroup_TotalTested == "0"

//ParticipationRate
destring ParticipationRate, gen(nParticipationRate) i(%)
replace ParticipationRate = string(nParticipationRate/100, "%9.4g")
replace ParticipationRate = "*" if missing(nParticipationRate)
replace ParticipationRate = "--" if StudentSubGroup_TotalTested == "0" 

//Generating Informational Variables 
gen ProficiencyCriteria = "Levels 3 and 4"
if `year' <2018 gen AssmtName = "PAWS"
if `year' > 2017 gen AssmtName = "WY-TOPP"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth = "N"

replace Flag_AssmtNameChange = "Y" if `year' == 2018
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2018 | `year' == 2015
replace Flag_CutScoreChange_math = "Y" if `year' == 2018 | `year' == 2015
replace Flag_CutScoreChange_oth = "Y" if `year' == 2022 | `year' == 2018 | `year' == 2015


//Generating Empty/missing Variables
gen AvgScaleScore = "--"
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficientOrAbove_count = "--"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
drop if missing(DataLevel)
save "`Output'/WY_AssmtData_`year'", replace
export delimited using "`Output'/WY_AssmtData_`year'", replace

clear
}
