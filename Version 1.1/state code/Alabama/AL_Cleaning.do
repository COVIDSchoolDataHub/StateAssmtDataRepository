clear
set more off
local Original "/Users/miramehta/Documents/AL State Testing Data"
local NCES_District "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
local NCES_School "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
local Output "/Users/miramehta/Documents/AL State Testing Data/Output"
local AlabamaMain "/Users/miramehta/Documents/Github/StateAssmtDataRepository/Version 1.1/State Code/Alabama"
set trace off

//Unhide code below on first run to convert to DTA format

/*

//CSV Code: 2015-2022
foreach year in 2015 2016 2017 2018 2019 2021 2022 {
	import delimited "`Original'/AL_OriginalData_counts_`year'", case(preserve)
	if `year' == 2022 {
		gen Year = 2022
	}
	save "`Original'/AL_OriginalData_counts_`year'", replace
	clear

	import delimited "`Original'/AL_OriginalData_percents_`year'", case(preserve)
	foreach n in 1 2 3 4 {
		rename Level`n' Lev`n'_percent
	}
	save "`Original'/AL_OriginalData_percents_`year'", replace
	clear
	use "`Original'/AL_OriginalData_counts_`year'"
	merge 1:1 SystemCode SchoolCode Subject Grade Gender Race Ethnicity SubPopulation using "`Original'/AL_OriginalData_percents_`year'", nogen
	save "`Original'/AL_OriginalData_`year'",replace
	clear
}
//Excel Code: 2023
foreach Subject in ela math sci {
	import excel "`Original'/AL_OriginalData`Subject'_2023", firstrow case(preserve)
	save "`Original'/AL_OriginalData`Subject'_2023", replace
	clear
}
use "`Original'/AL_OriginalDataela_2023"
append using "`Original'/AL_OriginalDatamath_2023" "`Original'/AL_OriginalDatasci_2023"
save "`Original'/AL_OriginalData_2023", replace
clear

foreach year in 2019 2021 2022 {
	if `year' == 2019 {
	import excel "`Original'/AL_ParticipationRead_`year'", firstrow case(preserve)
	save "`Original'/AL_ParticipationRead_`year'", replace
	clear
	import excel "`Original'/AL_ParticipationMath_`year'", firstrow case(preserve)
	save "`Original'/AL_ParticipationMath_`year'", replace
	clear
	import excel "`Original'/AL_ParticipationSci_`year'", firstrow case(preserve)
	save "`Original'/AL_ParticipationSci_`year'", replace
	append using "`Original'/AL_ParticipationRead_`year'" "`Original'/AL_ParticipationMath_`year'"
	save "`Original'/AL_Participation_`year'", replace
}
	else {
	import excel "`Original'/AL_ParticipationELA_`year'", firstrow case(preserve)
	save "`Original'/AL_ParticipationELA_`year'", replace
	clear
	import excel "`Original'/AL_ParticipationMath_`year'", firstrow case(preserve)
	save "`Original'/AL_ParticipationMath_`year'", replace
	clear
	import excel "`Original'/AL_ParticipationSci_`year'", firstrow case(preserve)
	save "`Original'/AL_ParticipationSci_`year'", replace
	append using "`Original'/AL_ParticipationELA_`year'" "`Original'/AL_ParticipationMath_`year'"
	save "`Original'/AL_Participation_`year'", replace
	}
destring SystemCode SchoolCode, replace
keep SystemCode SchoolCode Subject Grade Gender Race Ethnicity SubPopulation ParticipationRate
replace Grade = "Grade " + Grade if `year' !=2021
replace Grade = "Grade 0" + Grade if `year' ==2021
replace Grade = "All Grades" if strpos(Grade, "ALL") !=0
replace Grade = "Grade 10" if Grade == "Grade High School" & `year' == 2019
replace Grade = "Grade 11" if Grade == "Grade 0High School" & `year' ==2021
replace Grade = "Grade 11" if Grade == "Grade High School" & `year' ==2022
merge 1:1 SystemCode SchoolCode Subject Grade Gender Race Ethnicity SubPopulation using "`Original'/AL_OriginalData_`year'", nogen
save "`Original'/AL_OriginalData_`year'", replace
clear
}


*/

forvalues year = 2015/2023 {
	if `year' == 2020 {
		continue
	}
use "`Original'/AL_OriginalData_`year'"
local prevyear =`=`year'-1'
//Dropping SubGroups within SubGroups (i.e Gender = Male, Ethnicity = Hispanic , SubPopulation = Economically Disadvantaged)
gen NotAll = 0
replace NotAll = NotAll + 1 if strpos(Gender, "All") !=0
replace NotAll = NotAll + 1 if strpos(Race, "All") !=0
replace NotAll = NotAll + 1 if strpos(Ethnicity, "All") !=0
replace NotAll = NotAll + 1 if strpos(SubPopulation, "All") !=0
keep if NotAll >=3
gen StudentSubGroup = ""
replace StudentSubGroup = Gender if strpos(Gender, "All") ==0
replace StudentSubGroup = Race if strpos(Race, "All") ==0
replace StudentSubGroup = Ethnicity if strpos(Ethnicity, "All") ==0
replace StudentSubGroup = SubPopulation if strpos(SubPopulation, "All") ==0
replace StudentSubGroup = "All Students" if strpos(Gender, "All") !=0 & strpos(Race, "All") !=0 & strpos(Ethnicity, "All") !=0 & strpos(SubPopulation, "All") !=0
*drop Race Gender Ethnicity SubPopulation

//Fixing StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "English Learner" if strpos(StudentSubGroup, "English") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two or more") !=0
replace StudentSubGroup = "SWD" if strpos(StudentSubGroup, "Students with Disabilities") != 0
replace StudentSubGroup = "Non-SWD" if strpos(StudentSubGroup, "General Education Students") != 0
replace StudentSubGroup = "Military" if strpos(StudentSubGroup, "Military Family") != 0
replace StudentSubGroup = "Foster Care" if strpos(StudentSubGroup, "Foster") != 0
replace StudentSubGroup = "Not Hispanic or Latino" if StudentSubGroup == "Other Ethnicity"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster"

//Derive Missing StudentSubGroup Counts where Possible
if `year' !=2023 {
	foreach n in 1 2 3 4 {
	rename Level`n' Lev`n'_count
	destring Lev`n'_count, gen(nLev`n'_count) i(*-)
	}
	destring Enrolled Tested, replace i(*~)
	replace Tested = nLev1_count + nLev2_count + nLev3_count + nLev4_count if Tested ==.
}


//Standardizing other variable names

if `year' !=2023 {
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)
rename SystemCode StateAssignedDistID
rename System DistName
rename SchoolCode StateAssignedSchID
rename School SchName
rename Grade GradeLevel
rename Proficient ProficientOrAbove_count
rename ProficientRate ProficientOrAbove_percent
}

if `year' == 2023 {
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)
rename SystemCode StateAssignedDistID
rename System DistName
rename SchoolCode StateAssignedSchID
rename School SchName
rename Grade GradeLevel
foreach n in 1 2 3 4 {
	rename PercentLevel`n' Lev`n'_percent
}
rename PercentProficient ProficientOrAbove_percent
}

//2023 StateAssignedDistID and StateAssignedSchID
destring StateAssignedDistID StateAssignedSchID, replace


//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if StateAssignedDistID == 0 & StateAssignedSchID == 0
replace DataLevel = "District" if StateAssignedDistID !=0 & StateAssignedSchID ==0
replace DataLevel = "School" if StateAssignedDistID !=0 & StateAssignedSchID !=0
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace StateAssignedDistID =. if DataLevel ==1
replace StateAssignedSchID=. if DataLevel ==1
replace StateAssignedSchID=. if DataLevel ==2
order DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3

//Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "read" if Subject == "Reading"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

//GradeLevel

if `year' !=2023 {
replace GradeLevel = subinstr(GradeLevel,"Grade ","G",.)
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")
}

if `year' == 2023 {
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")
}
//ParticipationRate

if `year' <2019 {
gen ParticipationRate = string(Tested/Enrolled,"%9.3f")
replace ParticipationRate = "*" if missing(Tested) | missing(Enrolled)
}

if `year' >= 2019 & `year' <2023 {
*destring Enrolled Tested, replace i(*)
destring ParticipationRate, gen(nParticipationRate) i(*~)
replace ParticipationRate = string(nParticipationRate/100, "%9.3f")
replace ParticipationRate = "*" if ParticipationRate == "."	
}
if `year' == 2023 {
destring ParticipationRate, gen(nParticipationRate) i(*~)
replace ParticipationRate = string(nParticipationRate/100, "%9.3f")
replace ParticipationRate = "*" if ParticipationRate == "."
}

//ProficientOrAbove_percent and Level percents

destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*~)

foreach n in 1 2 3 4 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*~)
}
foreach n in 1 2 3 4 {
	replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.3f")
	replace Lev`n'_percent = "*" if Lev`n'_percent == "." 
}

replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100, "%9.3f")
replace ProficientOrAbove_percent = string((nLev3_percent + nLev4_percent)/100, "%9.3f") if missing(nProficientOrAbove_percent)
replace ProficientOrAbove_percent = "0.000" if (nLev3_percent + nLev4_percent)==0 & !missing(nLev3_percent) & !missing(nLev4_percent)
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."



//StudentGroup_TotalTested and StudentSubGroup_TotalTested
if `year' == 2023 {
	gen StudentSubGroup_TotalTested = "--"
	gen StudentGroup_TotalTested = "--"
}
if `year' !=2023 {
gen StudentSubGroup_TotalTested = Tested
sort StudentGroup
egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)
tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"

}

//StateAssignedDistID and StateAssignedSchID
tostring StateAssignedDistID StateAssignedSchID, replace
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel !=3
replace StateAssignedSchID = "000" + StateAssignedSchID if strlen(StateAssignedSchID)==1 & DataLevel ==3
replace StateAssignedSchID = "00" + StateAssignedSchID if strlen(StateAssignedSchID)==2 & DataLevel ==3
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID)==3 & DataLevel ==3
replace StateAssignedDistID = "00" + StateAssignedDistID if strlen(StateAssignedDistID)==1 & DataLevel !=1
replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID)==2 & DataLevel !=1

//Merging with NCES Data//
replace StateAssignedSchID = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel ==3


tempfile temp1
save "`temp1'", replace

//District
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'", replace
clear
if `year' < 2023 {
use "`NCES_District'/NCES_`prevyear'_District"
}
else if `year'==2023{
use "`NCES_District'/NCES_2021_District"
}
keep if state_fips_id == 1
gen StateAssignedDistID = subinstr(state_leaid,"AL-","",.)
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge ==1
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel==3
tempfile tempschool
save "`tempschool'", replace
if `year' <2023 {
use "`NCES_School'/NCES_`prevyear'_School"
}
else if `year' == 2023 {
use "`NCES_School'/NCES_2021_School"
}
keep if state_fips_id == 1
gen StateAssignedDistID = subinstr(state_leaid,"AL-","",.)
gen StateAssignedSchID = StateAssignedDistID + "-" + seasch if strpos(seasch,"-") ==0
replace StateAssignedSchID = seasch if strpos(seasch,"-") !=0
drop if StateAssignedSchID=="-"
merge 1:m StateAssignedSchID using "`tempschool'"
drop if _merge ==1
if `year' == 2023 {
	
	replace SchVirtual = 0 if seasch == "026-0063" | seasch == "800-0015"
}
save "`tempschool'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempschool'"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename ncesdistrictid NCESDistrictID
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 1
replace StateAbbrev = "AL"

//Generating additional variables
gen State = "Alabama"
gen AvgScaleScore = "--"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = ""
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = ""
gen ProficiencyCriteria = "Levels 3-4"
gen Lev5_percent =.
gen Lev5_count =.
gen AssmtType = "Regular"
gen AssmtName = ""

if `year' == 2023 {
	foreach n in 1 2 3 4 {
		gen Lev`n'_count = "--"
		destring Lev`n'_count, gen(nLev`n'_count) force
	}
	gen ProficientOrAbove_count = "--"
}

//Level counts for 0 StudentSubGroup_TotalTested
if `year' != 2023 {
	foreach n in 1 2 3 4 {
	replace Lev`n'_count = "0" if StudentSubGroup_TotalTested == "0"
	}
}

//Levels for weird suppression that can be calculated
destring ProficientOrAbove_count, gen(nProficientOrAbove_count) i(*-)
replace Lev4_count = string(nProficientOrAbove_count - nLev3_count) if missing(nLev4_count) & !missing(nProficientOrAbove_count) & !missing(nLev3_count)
replace Lev3_count = string(nProficientOrAbove_count - nLev4_count) if missing(nLev3_count) & !missing(nProficientOrAbove_count) & !missing(nLev4_count)
if `year' != 2023{
	replace ProficientOrAbove_count = string(Tested - nLev1_count - nLev2_count) if missing(nProficientOrAbove_count)
	drop Tested
}
replace Lev4_percent = string((nProficientOrAbove_percent - nLev3_percent)/100, "%9.3f") if missing(nLev4_percent) & !missing(nProficientOrAbove_percent) & !missing(nLev3_percent)
replace Lev3_percent = string((nProficientOrAbove_percent - nLev4_percent)/100, "%9.3f") if missing(nLev3_percent) & !missing(nProficientOrAbove_percent) & !missing(nLev4_percent)
replace ProficientOrAbove_percent = string((100 - nLev1_percent - nLev2_percent)/100, "%9.3f") if missing(nProficientOrAbove_percent)

//AssmtName
if `year' >= 2014 & `year' <=2017 {
	replace AssmtName = "ACT Aspire"
}
if `year' >= 2018 & `year' <= 2019 {
	replace AssmtName = "Scranton Series"
}
if `year' >=2021 {
	replace AssmtName = "ACAP"
}

//Flags
replace Flag_AssmtNameChange = "Y" if `year' == 2018 | `year' == 2021
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2021
replace Flag_CutScoreChange_ELA = "N" if `year' > 2021
replace Flag_CutScoreChange_sci = "Y" if `year' == 2018 | `year' == 2021
replace Flag_CutScoreChange_math = "Y" if `year' == 2018 | `year' == 2021

//Changes fall 2023:
replace Subject = "ela" if Subject == "read"

//Response to R2
drop if StudentSubGroup_TotalTested == "0"
drop if Lev1_percent == "0" & Lev2_percent == "0" & Lev3_percent == "0" & Lev4_percent == "0"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/AL_AssmtData_`year'", replace
export delimited "`Output'/AL_AssmtData_`year'", replace
clear
}
do "`AlabamaMain'/Fixing Unmerged.do"
