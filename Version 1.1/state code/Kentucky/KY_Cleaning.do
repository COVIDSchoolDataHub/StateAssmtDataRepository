clear
set more off
set trace off
cd "/Users/minnamgung/Desktop/SADR/Kentucky"
local Original "/Users/minnamgung/Desktop/SADR/Kentucky/Original Data Files"
local Output "/Users/minnamgung/Desktop/SADR/Kentucky/Output"
local NCES "/Users/minnamgung/Desktop/SADR/NCESOld"

//Importing (unhide on first run)

/*
forvalues year = 2012/2017 {
	import excel "`Original'/KY_OriginalData_`year'_all", firstrow case(preserve) allstring
	save "`Original'/KY_OriginalData_`year'", replace
	clear
}
foreach year in 2018 2019 {
	import excel "`Original'/KY_OriginalData_`year'_all", firstrow case(preserve) allstring sheet(DATA)
	save "`Original'/KY_OriginalData_`year'", replace
	clear
}
foreach year in 2021 2022 2023 {
	import delimited "`Original'/KY_OriginalData_`year'_all", case(preserve) stringcols(_all)
	save "`Original'/KY_OriginalData_`year'", replace
	clear
}

*/

//Unhide Above Code

// HANDLE 2012 to 2022 FIRST 
// This is due to 2023 NCES issues

forvalues year = 2012/2022 {
	if `year' == 2020 continue
use "`Original'/KY_OriginalData_`year'", clear
local prevyear =`=`year'-1'

//Renaming and dropping
if `year' == 2012 | `year' == 2013 {
drop SCH_YEAR
rename SCH_CD StateAssignedSchID
gen StateAssignedDistID = substr(StateAssignedSchID,1,3)
rename DIST_NAME DistName
rename SCH_NAME SchName
rename TEST_TYPE AssmtName
rename CONTENT_TYPE Subject
rename GRADE_LEVEL GradeLevel
rename DISAGG_LABEL StudentSubGroup
rename NBR_TESTED StudentSubGroup_TotalTested
rename PCT_NOVICE Lev1_percent
rename PCT_APPRENTICE Lev2_percent
rename PCT_PROFICIENT Lev3_percent
rename PCT_DISTINGUISHED Lev4_percent
rename PCT_PROFICIENT_DISTINGUISHED ProficientOrAbove_percent
}

if `year' >= 2014 & `year' < 2018 {
drop SCH_YEAR
rename SCH_CD StateAssignedSchID
rename DIST_NAME DistName
rename SCH_NAME SchName
rename TEST_TYPE AssmtName
rename CONTENT_TYPE Subject
rename GRADE_LEVEL GradeLevel
rename DISAGG_LABEL StudentSubGroup
rename NBR_TESTED StudentSubGroup_TotalTested
rename PCT_NOVICE Lev1_percent
rename PCT_APPRENTICE Lev2_percent
rename PCT_PROFICIENT Lev3_percent
rename PCT_DISTINGUISHED Lev4_percent
rename PCT_PROFICIENT_DISTINGUISHED ProficientOrAbove_percent
rename DIST_NUMBER StateAssignedDistID
rename PARTICIP_RATE ParticipationRate
}
if `year' == 2018 | `year' == 2019 {
drop SCH_YEAR
rename SCH_CD StateAssignedSchID
rename DIST_NAME DistName
rename SCH_NAME SchName
rename SUBJECT Subject
rename GRADE GradeLevel
rename DEMOGRAPHIC StudentSubGroup
rename TESTED StudentSubGroup_TotalTested
rename NOVICE Lev1_percent
rename APPRENTICE Lev2_percent
rename PROFICIENT Lev3_percent
rename distinguished Lev4_percent
rename PROFICIENT_DISTINGUISHED ProficientOrAbove_percent
rename DIST_NUMBER StateAssignedDistID
rename PART_RATE ParticipationRate
}
if `year' == 2021 | `year' == 2022 | `year' == 2023 {
drop SCHOOLYEAR
rename DISTRICTNUMBER StateAssignedDistID
rename DISTRICTNAME DistName
rename SCHOOLCODE StateAssignedSchID
rename SCHOOLNAME SchName
rename GRADE GradeLevel
rename SUBJECT Subject
rename DEMOGRAPHIC StudentSubGroup
if `year' == 2021 rename PARTICIPATIONPOPULATION StudentSubGroup_TotalTested
if `year' == 2021 rename PARTICIPATIONRATE ParticipationRate
rename NOVICE Lev1_percent
rename APPRENTICE Lev2_percent
rename PROFICIENT Lev3_percent
rename DISTINGUISHED Lev4_percent
rename PROFICIENTDISTINGUISHED ProficientOrAbove_percent
}




//Subject
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "ela" if Subject == "Reading"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"
replace Subject = "wri" if Subject == "Writing"
replace Subject = "math" if Subject == "MA"
replace Subject = "ela" if Subject == "RD"
replace Subject = "sci" if Subject == "SC"
replace Subject = "soc" if Subject == "SS"
replace Subject = "wri" if Subject == "WR"
keep if inlist(Subject, "math", "ela", "sci", "soc", "wri")

//GradeLevel
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if strpos(SchName, "State Total") !=0
replace DataLevel = "District" if strpos(SchName, "District Total") !=0
replace DataLevel = "School" if strpos(SchName, "State Total") ==0 & strpos(SchName, "District Total") ==0
drop if strpos(SchName, "COOP Total") !=0
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel !=3

//StudentSubGroup
rename StudentSubGroup DISAGG_LABEL
replace DISAGG_LABEL = "Black or African American" if DISAGG_LABEL == "African American"
replace DISAGG_LABEL = "Native Hawaiian or Pacific Islander" if DISAGG_LABEL == "Native Hawaiian or Other Pacific Islander"
replace DISAGG_LABEL = "Two or More" if DISAGG_LABEL == "Two or more races"
replace DISAGG_LABEL = "White" if DISAGG_LABEL == "White (Non-Hispanic)"
replace DISAGG_LABEL = "Hispanic or Latino" if DISAGG_LABEL == "Hispanic"
replace DISAGG_LABEL = "English Learner" if DISAGG_LABEL == "Limited English Proficiency"
replace DISAGG_LABEL = "English Learner" if DISAGG_LABEL == "English Learners"
replace DISAGG_LABEL = "Economically Disadvantaged" if DISAGG_LABEL == "Free/Reduced-Price Meals"
replace DISAGG_LABEL = "SWD" if DISAGG_LABEL == "Disability-With IEP (Total)" 

rename DISAGG_LABEL StudentSubGroup
rename StudentSubGroup DEMOGRAPHIC
replace DEMOGRAPHIC = "All Students" if DEMOGRAPHIC == "TST"
replace DEMOGRAPHIC = "American Indian or Alaska Native" if DEMOGRAPHIC == "ETI"
replace DEMOGRAPHIC = "Black or African American" if DEMOGRAPHIC == "ETB"
replace DEMOGRAPHIC = "Native Hawaiian or Pacific Islander" if DEMOGRAPHIC == "ETP"
replace DEMOGRAPHIC = "Two or More" if DEMOGRAPHIC == "ETO"
replace DEMOGRAPHIC = "White" if DEMOGRAPHIC == "ETW"
replace DEMOGRAPHIC = "Hispanic or Latino" if DEMOGRAPHIC == "ETH"
replace DEMOGRAPHIC = "Unknown" if DEMOGRAPHIC == "ETX"
replace DEMOGRAPHIC = "English Learner" if DEMOGRAPHIC == "LEP"
replace DEMOGRAPHIC = "English Proficient" if DEMOGRAPHIC == "LEN"
replace DEMOGRAPHIC = "Economically Disadvantaged" if DEMOGRAPHIC == "LUP"
replace DEMOGRAPHIC = "Not Economically Disadvantaged" if DEMOGRAPHIC == "LUN"
replace DEMOGRAPHIC = "Male" if DEMOGRAPHIC == "SXM"
replace DEMOGRAPHIC = "Female" if DEMOGRAPHIC == "SXF"
replace DEMOGRAPHIC = "Unknown" if DEMOGRAPHIC == "SXX"
replace DEMOGRAPHIC = "Black or African American" if DEMOGRAPHIC == "African American"
replace DEMOGRAPHIC = "Native Hawaiian or Pacific Islander" if DEMOGRAPHIC == "Native Hawaiian or Other Pacific Islander"
replace DEMOGRAPHIC = "Two or More" if DEMOGRAPHIC == "Two or More Races"
replace DEMOGRAPHIC = "White" if DEMOGRAPHIC == "White (non-Hispanic)"
replace DEMOGRAPHIC = "English Proficient" if DEMOGRAPHIC == "Non-English Learner"
replace DEMOGRAPHIC = "Not Economically Disadvantaged" if DEMOGRAPHIC == "Non-Economically Disadvantaged"
replace DEMOGRAPHIC = "Military" if DEMOGRAPHIC == "Military Dependent"
replace DEMOGRAPHIC = "SWD" if DEMOGRAPHIC == "Students with Disabilities (IEP)" 
replace DEMOGRAPHIC = "Non-SWD" if DEMOGRAPHIC == "Students without IEP"
replace DEMOGRAPHIC = "EL + Monitored" if DEMOGRAPHIC == "English Learners including Monitored"

replace DEMOGRAPHIC = "Non-Military" if DEMOGRAPHIC == "MLN"
	replace DEMOGRAPHIC = "Military" if DEMOGRAPHIC == "MIL"
	replace DEMOGRAPHIC = "SWD" if DEMOGRAPHIC == "ACD" 
	replace DEMOGRAPHIC = "Non-SWD" if DEMOGRAPHIC == "ACO"
	replace DEMOGRAPHIC = "Homeless" if DEMOGRAPHIC == "HOM"
	replace DEMOGRAPHIC = "Non-Homeless" if DEMOGRAPHIC == "HON"
	replace DEMOGRAPHIC = "Homeless" if DEMOGRAPHIC == "HOM"
	replace DEMOGRAPHIC = "Migrant" if DEMOGRAPHIC == "MIG"
	replace DEMOGRAPHIC = "Non-Migrant" if DEMOGRAPHIC == "MIN"
	replace DEMOGRAPHIC = "Foster Care" if DEMOGRAPHIC == "FOS"
	replace DEMOGRAPHIC = "Non-Foster Care" if DEMOGRAPHIC == "FON"
	replace DEMOGRAPHIC = "EL Exited" if DEMOGRAPHIC == "LEX"
	replace DEMOGRAPHIC = "EL and Monit or Recently Ex" if DEMOGRAPHIC =="ELM"
	replace DEMOGRAPHIC = "Ever EL" if DEMOGRAPHIC == "LC"



rename DEMOGRAPHIC StudentSubGroup

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Unknown"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL and Monit or Recently Ex" | StudentSubGroup == "EL Exited" | StudentSubGroup == "Ever EL" | StudentSubGroup == "EL + Monitored"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"

replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD" 
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"  | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless" 
replace StudentGroup = "Military Status" if StudentSubGroup == "Non-Military" | StudentSubGroup == "Military"

drop if StudentGroup == ""

//Suppression and Missing
cap noisily drop if missing(StudentSubGroup_TotalTested)
foreach n in 1 2 3 4 {
	replace Lev`n'_percent = "*" if strpos(StudentSubGroup, "*") !=0
}
cap noisily drop if StudentSubGroup_TotalTested == "0"
if `year' >= 2018 {
	foreach var of varlist Lev* ProficientOrAbove_percent {
		replace `var' = "*" if SUPPRESSED == "Y"
	}
}
if `year' <=2013 {
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "***" | StudentSubGroup_TotalTested == "---"
foreach var of varlist Lev* ProficientOrAbove_percent {
	replace `var' = "*" if missing(`var')
}
}
if `year' >= 2014 & `year' <= 2017 {
foreach var of varlist Lev* ProficientOrAbove_percent {
	replace `var' = "*" if strpos(StudentSubGroup_TotalTested, "*") !=0
}
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, "*","",.)
}

//Standardizing All Variables
if `year' < 2014 | `year' >= 2022 gen ParticipationRate = "--"
if `year' >= 2022 gen StudentSubGroup_TotalTested = "--"
if `year' == 2018 | `year' == 2019 gen AssmtName = "KREP"
if `year' >= 2021 gen AssmtName = "Kentucky State Assessment"
keep StateAssignedSchID DistName SchName AssmtName Subject GradeLevel Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent StateAssignedDistID DataLevel StudentGroup ParticipationRate StudentSubGroup_TotalTested StudentSubGroup

//Converting to Decimal
foreach var of varlist ProficientOrAbove_percent Lev* ParticipationRate {
	destring `var', gen(n`var') i(*-)
	replace `var' = string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
}

//StudentGroup_TotalTested
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, ",","",.)
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
sort StudentGroup
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"

//Merging NCES
tempfile temp1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist 
save "`tempdist'", replace
clear
use "`NCES'/NCES_`prevyear'_District"
keep if state_location == "KY" | state_name == 21
gen StateAssignedDistID = subinstr(state_leaid, "KY-","",.)
replace StateAssignedDistID = substr(StateAssignedDistID, 4,3)
duplicates drop StateAssignedDistID, force
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge == 1
save "`tempdist'", replace
clear
if `year' > 2022 {
use "`NCES'/NCES_2022_District"
keep if StateAbbrev == "KY" | StateFips == "21"
gen StateAssignedDistID = subinstr(State_leaid, "KY-","",.)
replace StateAssignedDistID = substr(StateAssignedDistID, 4,3)
duplicates drop StateAssignedDistID, force
merge 1:m StateAssignedSchID using "`tempdist'", update
drop if _merge == 1
destring StateFips, replace
save "`tempdist'", replace
clear
}

//School
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear
use "`NCES'/NCES_`prevyear'_School"
keep if state_location == "KY" | state_name == 21
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1,10)
replace StateAssignedSchID = substr(StateAssignedSchID, 4,6)
duplicates drop StateAssignedSchID, force
if `year' > 2019 replace StateAssignedSchID = "606450" if StateAssignedSchID == "365450"
if `year' > 2019 replace StateAssignedSchID = "606460" if StateAssignedSchID == "365460"
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge == 1
drop _merge
save "`tempsch'", replace
clear
if `year' > 2022 {
use "`NCES'/NCES_2022_School"
keep if StateAbbrev == "KY" | StateFips == "21"
gen seasch = substr(st_schid, "KY-", "", .)
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1,10)
replace StateAssignedSchID = substr(StateAssignedSchID, 4,6)
duplicates drop StateAssignedSchID, force
if `year' > 2019 replace StateAssignedSchID = "606450" if StateAssignedSchID == "365450"
if `year' > 2019 replace StateAssignedSchID = "606460" if StateAssignedSchID == "365460"
merge 1:m StateAssignedSchID using "`tempsch'", update
drop if _merge == 1
destring StateFips, replace
save "`tempsch'", replace
clear
}

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"

if `year' != 2023 {
	
//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
rename dist_urban_centric_locale DistLocale
replace StateFips = 21
replace StateAbbrev = "KY"
	
}

if `year' == 2023 {
	
//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 21
replace StateAbbrev = "KY"
	
}

//Idk whats going on with 2018 and missing DistNames. They're not in NCES. I'm Assuming for now that these are the "COOPS" that appear in later years
if `year' == 2018 drop if missing(DistName)



//Missing and Indicator Variables
gen AvgScaleScore = "--"
foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
}
gen Lev5_percent = ""
gen Lev5_count = ""
gen ProficientOrAbove_count = "--"
gen ProficiencyCriteria = "Levels 3-4"
gen State = "Kentucky"
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)
gen AssmtType = "Regular"

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "N"
gen Flag_CutScoreChange_sci = "N"

if `year' == 2021 {
replace Flag_AssmtNameChange = "Y"
replace Flag_CutScoreChange_ELA = "Y"
replace Flag_CutScoreChange_math = "Y"
replace Flag_CutScoreChange_soc = "Y"
replace Flag_CutScoreChange_sci = "Y"
}

//Fixing Unmerged
if `year' == 2019 {
	drop if SchName == "Bellevue Transitional School"
}
if `year' == 2023 {


replace DistType = 1 if SchName == "Barbourville Learning Center"
replace SchType = 4 if SchName == "Barbourville Learning Center"
replace NCESDistrictID = "2100240" if SchName == "Barbourville Learning Center"
replace State_leaid = "KY-061016000" if SchName == "Barbourville Learning Center"
replace NCESSchoolID = "210024002542" if SchName == "Barbourville Learning Center"
replace seasch = "061016000-061016015" if SchName == "Barbourville Learning Center"
replace DistCharter = "No" if SchName == "Barbourville Learning Center"
replace SchLevel = 2 if SchName == "Barbourville Learning Center"
replace SchVirtual = 0 if SchName == "Barbourville Learning Center"
replace CountyName = "Knox County" if SchName == "Barbourville Learning Center"
replace CountyCode = 21121 if SchName == "Barbourville Learning Center"

replace DistType = 1 if SchName == "Glen Dale Center"
replace SchType = 4 if SchName == "Glen Dale Center"
replace NCESDistrictID = "2101650" if SchName == "Glen Dale Center"
replace State_leaid = "KY-047152000" if SchName == "Glen Dale Center"
replace NCESSchoolID = "210165002246" if SchName == "Glen Dale Center"
replace seasch = "047152000-047152045" if SchName == "Glen Dale Center"
replace DistCharter = "No" if SchName == "Glen Dale Center"
replace SchLevel = 2 if SchName == "Glen Dale Center"
replace SchVirtual = 0 if SchName == "Glen Dale Center"
replace CountyName = "Hardin County" if SchName == "Glen Dale Center"
replace CountyCode = 21093 if SchName == "Glen Dale Center"

replace DistType = 1 if SchName == "Hancock County Alternative Program"
replace SchType = 4 if SchName == "Hancock County Alternative Program"
replace NCESDistrictID = "2102460" if SchName == "Hancock County Alternative Program"
replace State_leaid = "KY-046225000" if SchName == "Hancock County Alternative Program"
replace NCESSchoolID = "210246002540" if SchName == "Hancock County Alternative Program"
replace seasch = "046225000-046225015" if SchName == "Hancock County Alternative Program"
replace DistCharter = "No" if SchName == "Hancock County Alternative Program"
replace SchLevel = 2 if SchName == "Hancock County Alternative Program"
replace SchVirtual = 0 if SchName == "Hancock County Alternative Program"
replace CountyName = "Hancock County" if SchName == "Hancock County Alternative Program"
replace CountyCode = 21091 if SchName == "Hancock County Alternative Program"

replace DistType = 1 if SchName == "Lynn Camp Elementary School"
replace SchType = 1 if SchName == "Lynn Camp Elementary School"
replace NCESDistrictID = "2103150" if SchName == "Lynn Camp Elementary School"
replace State_leaid = "KY-061301000" if SchName == "Lynn Camp Elementary School"
replace NCESSchoolID = "210315002543" if SchName == "Lynn Camp Elementary School"
replace seasch = "061301000-061301015" if SchName == "Lynn Camp Elementary School"
replace DistCharter = "No" if SchName == "Lynn Camp Elementary School"
replace SchLevel = 1 if SchName == "Lynn Camp Elementary School"
replace SchVirtual = 0 if SchName == "Lynn Camp Elementary School"
replace CountyName = "Knox County" if SchName == "Lynn Camp Elementary School"
replace CountyCode = 21121 if SchName == "Lynn Camp Elementary School"

replace DistType = 1 if SchName == "Lynn Camp Middle High School"
replace SchType = 1 if SchName == "Lynn Camp Middle High School"
replace NCESDistrictID = "2103150" if SchName == "Lynn Camp Middle High School"
replace State_leaid = "KY-061301000" if SchName == "Lynn Camp Middle High School"
replace NCESSchoolID = "210315002544" if SchName == "Lynn Camp Middle High School"
replace seasch = "061301000-061301025" if SchName == "Lynn Camp Middle High School"
replace DistCharter = "No" if SchName == "Lynn Camp Middle High School"
replace SchLevel = 2 if SchName == "Lynn Camp Middle High School"
replace CountyName = "Knox County" if SchName == "Lynn Camp Middle High School"
replace CountyCode = 21121 if SchName == "Lynn Camp Middle High School"
replace SchVirtual = 0 if SchName == "Lynn Camp Middle High School"

replace DistType = 1 if SchName == "Patriot Academy"
replace SchType = 4 if SchName == "Patriot Academy"
replace NCESDistrictID = "2100070" if SchName == "Patriot Academy"
replace State_leaid = "KY-002005000" if SchName == "Patriot Academy"
replace NCESSchoolID = "210007002535" if SchName == "Patriot Academy"
replace seasch = "002005000-002005025" if SchName == "Patriot Academy"
replace DistCharter = "No" if SchName == "Patriot Academy"
replace SchLevel = 4 if SchName == "Patriot Academy"
replace CountyName = "Allen County" if SchName == "Patriot Academy"
replace CountyCode = 21003 if SchName == "Patriot Academy"
replace SchVirtual = 0 if SchName == "Patriot Academy"

replace DistType = 1 if SchName == "Virtual Academy"
replace SchType = 4 if SchName == "Virtual Academy"
replace NCESDistrictID = "2101470" if SchName == "Virtual Academy"
replace State_leaid = "KY-030145000" if SchName == "Virtual Academy"
replace NCESSchoolID = "210147002538" if SchName == "Virtual Academy"
replace seasch = "030145000-030145035" if SchName == "Virtual Academy"
replace DistCharter = "No" if SchName == "Virtual Academy"
replace SchLevel = 4 if SchName == "Virtual Academy"
replace CountyName = "Daviess County" if SchName == "Virtual Academy"
replace CountyCode = 21059 if SchName == "Virtual Academy"
replace SchVirtual = 0 if SchName == "Patriot Academy"

}

//Response to Review
cap replace SchVirtual = -1 if missing(SchVirtual) & DataLevel == 3

//Final Cleaning
replace StudentGroup_TotalTested = "--" if `year' >= 2022

if `year' >= 2015 {
	
	foreach v of varlist DistType DistLocale SchType SchLevel SchVirtual {
	
	decode `v', generate(`v'1)
	drop `v'
	rename `v'1 `v'
	
}

}

if `year' < 2015 {
	
	foreach v of varlist DistType DistLocale SchType SchLevel {
	
	decode `v', generate(`v'1)
	drop `v'
	rename `v'1 `v'
	
}

}

	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/KY_AssmtData_`year'", replace
export delimited "`Output'/KY_AssmtData_`year'", replace
clear	
	
}

local Original "/Users/minnamgung/Desktop/SADR/Kentucky/Original Data Files"
local Output "/Users/minnamgung/Desktop/SADR/Kentucky/Output"
local NCES "/Users/minnamgung/Desktop/SADR/NCESOld"

// This is for 2023 
// When new NCES file release, adapt section and insert into the loop above

use "`Original'/KY_OriginalData_2023", clear

//Renaming and dropping
drop SCHOOLYEAR
rename DISTRICTNUMBER StateAssignedDistID
rename DISTRICTNAME DistName
rename SCHOOLCODE StateAssignedSchID
rename SCHOOLNAME SchName
rename GRADE GradeLevel
rename SUBJECT Subject
rename DEMOGRAPHIC StudentSubGroup
rename NOVICE Lev1_percent
rename APPRENTICE Lev2_percent
rename PROFICIENT Lev3_percent
rename DISTINGUISHED Lev4_percent
rename PROFICIENTDISTINGUISHED ProficientOrAbove_percent

//Subject
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "ela" if Subject == "Reading"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"
replace Subject = "wri" if Subject == "Writing"
replace Subject = "math" if Subject == "MA"
replace Subject = "ela" if Subject == "RD"
replace Subject = "sci" if Subject == "SC"
replace Subject = "soc" if Subject == "SS"
replace Subject = "wri" if Subject == "WR"
keep if inlist(Subject, "math", "ela", "sci", "soc", "wri")

//GradeLevel
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if strpos(SchName, "State Total") !=0
replace DataLevel = "District" if strpos(SchName, "District Total") !=0
replace DataLevel = "School" if strpos(SchName, "State Total") ==0 & strpos(SchName, "District Total") ==0
drop if strpos(SchName, "COOP Total") !=0
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel !=3

//StudentSubGroup
rename StudentSubGroup DISAGG_LABEL
replace DISAGG_LABEL = "Black or African American" if DISAGG_LABEL == "African American"
replace DISAGG_LABEL = "Native Hawaiian or Pacific Islander" if DISAGG_LABEL == "Native Hawaiian or Other Pacific Islander"
replace DISAGG_LABEL = "Two or More" if DISAGG_LABEL == "Two or more races"
replace DISAGG_LABEL = "White" if DISAGG_LABEL == "White (Non-Hispanic)"
replace DISAGG_LABEL = "Hispanic or Latino" if DISAGG_LABEL == "Hispanic"
replace DISAGG_LABEL = "English Learner" if DISAGG_LABEL == "Limited English Proficiency"
replace DISAGG_LABEL = "English Learner" if DISAGG_LABEL == "English Learners"
replace DISAGG_LABEL = "Economically Disadvantaged" if DISAGG_LABEL == "Free/Reduced-Price Meals"
replace DISAGG_LABEL = "SWD" if DISAGG_LABEL == "Disability-With IEP (Total)" 

rename DISAGG_LABEL StudentSubGroup
rename StudentSubGroup DEMOGRAPHIC
replace DEMOGRAPHIC = "All Students" if DEMOGRAPHIC == "TST"
replace DEMOGRAPHIC = "American Indian or Alaska Native" if DEMOGRAPHIC == "ETI"
replace DEMOGRAPHIC = "Black or African American" if DEMOGRAPHIC == "ETB"
replace DEMOGRAPHIC = "Native Hawaiian or Pacific Islander" if DEMOGRAPHIC == "ETP"
replace DEMOGRAPHIC = "Two or More" if DEMOGRAPHIC == "ETO"
replace DEMOGRAPHIC = "White" if DEMOGRAPHIC == "ETW"
replace DEMOGRAPHIC = "Hispanic or Latino" if DEMOGRAPHIC == "ETH"
replace DEMOGRAPHIC = "Unknown" if DEMOGRAPHIC == "ETX"
replace DEMOGRAPHIC = "English Learner" if DEMOGRAPHIC == "LEP"
replace DEMOGRAPHIC = "English Proficient" if DEMOGRAPHIC == "LEN"
replace DEMOGRAPHIC = "Economically Disadvantaged" if DEMOGRAPHIC == "LUP"
replace DEMOGRAPHIC = "Not Economically Disadvantaged" if DEMOGRAPHIC == "LUN"
replace DEMOGRAPHIC = "Male" if DEMOGRAPHIC == "SXM"
replace DEMOGRAPHIC = "Female" if DEMOGRAPHIC == "SXF"
replace DEMOGRAPHIC = "Unknown" if DEMOGRAPHIC == "SXX"
replace DEMOGRAPHIC = "Black or African American" if DEMOGRAPHIC == "African American"
replace DEMOGRAPHIC = "Native Hawaiian or Pacific Islander" if DEMOGRAPHIC == "Native Hawaiian or Other Pacific Islander"
replace DEMOGRAPHIC = "Two or More" if DEMOGRAPHIC == "Two or More Races"
replace DEMOGRAPHIC = "White" if DEMOGRAPHIC == "White (non-Hispanic)"
replace DEMOGRAPHIC = "English Proficient" if DEMOGRAPHIC == "Non-English Learner"
replace DEMOGRAPHIC = "Not Economically Disadvantaged" if DEMOGRAPHIC == "Non-Economically Disadvantaged"
replace DEMOGRAPHIC = "Military" if DEMOGRAPHIC == "Military Dependent"
replace DEMOGRAPHIC = "SWD" if DEMOGRAPHIC == "Students with Disabilities (IEP)" 
replace DEMOGRAPHIC = "Non-SWD" if DEMOGRAPHIC == "Students without IEP"


rename DEMOGRAPHIC StudentSubGroup


//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Unknown"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL and Monit or Recently Ex" | StudentSubGroup == "EL Exited" | StudentSubGroup == "Ever EL" | StudentSubGroup == "EL + Monitored"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"

replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD" 
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"  | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless" 
replace StudentGroup = "Military Status" if StudentSubGroup == "Non-Military" | StudentSubGroup == "Military"

drop if StudentGroup == ""

//Suppression and Missing
gen StudentSubGroup_TotalTested = "--"
gen StudentGroup_TotalTested = "--"
gen ParticipationRate = "--"
gen AssmtName = "Kentucky State Assessment"

keep StateAssignedSchID DistName SchName AssmtName Subject GradeLevel Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent StateAssignedDistID DataLevel StudentGroup ParticipationRate StudentSubGroup_TotalTested StudentSubGroup

//Converting to Decimal
foreach var of varlist ProficientOrAbove_percent Lev* ParticipationRate {
	destring `var', gen(n`var') i(*-)
	replace `var' = string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
}

//Merging NCES
tempfile temp1
save "`temp1'", replace
clear

use "`temp1'"
keep if DataLevel == 2
tempfile tempdist 
save "`tempdist'", replace
clear

// District
use "`NCES'/NCES_2022_District"
keep if StateAbbrev == "KY" | StateFips == "21"
gen StateAssignedDistID = subinstr(State_leaid, "KY-","",.)
replace StateAssignedDistID = substr(StateAssignedDistID, 4,3)
duplicates drop StateAssignedDistID, force
merge 1:m StateAssignedDistID using "`tempdist'", update
drop if _merge == 1
destring StateFips, replace
save "`tempdist'", replace
clear

// School
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear

use "`NCES'/NCES_2022_School"
keep if StateAbbrev == "KY" | StateFips == "21"
gen seasch = subinstr(st_schid, "KY-", "", .)
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1,10)
replace StateAssignedSchID = substr(StateAssignedSchID, 4,6)
duplicates drop StateAssignedSchID, force
replace StateAssignedSchID = "606450" if StateAssignedSchID == "365450"
replace StateAssignedSchID = "606460" if StateAssignedSchID == "365460"
merge 1:m StateAssignedSchID using "`tempsch'", update
drop if _merge == 1
destring StateFips, replace
save "`tempsch'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"

replace ncesdistrictid=NCESDistrictID if DataLevel==3 & missing(ncesdistrictid)
drop NCESDistrictID

drop _merge

local NCES "/Users/minnamgung/Desktop/SADR/NCESOld"
merge m:1 ncesdistrictid using "`NCES'/NCES_2022_District", keepusing(DistType) update

drop if _merge==2
drop _merge

tempfile temp2
save "`temp2'", replace
clear

use "`NCES'/NCES_2021_District"
keep if state_location == "KY" 
decode urban_centric_locale, generate(DistLocale)
tempfile templocale
save "`templocale'", replace
clear 

use "`temp2'"
merge m:1 ncesdistrictid using "`templocale'", keepusing(DistLocale county_code county_name DistCharter)

drop if _merge==2

rename ncesdistrictid NCESDistrictID
rename county_code CountyCode
rename county_name CountyName

replace StateFips = 21
replace StateAbbrev = "KY"

//Missing and Indicator Variables
gen AvgScaleScore = "--"
foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
}
gen Lev5_percent = ""
gen Lev5_count = ""
gen ProficientOrAbove_count = "--"
gen ProficiencyCriteria = "Levels 3-4"
gen State = "Kentucky"
replace SchYear = "2022-23"
gen AssmtType = "Regular"

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "N"
gen Flag_CutScoreChange_sci = "N"

rename SchoolType SchType

replace DistType = "Regular local school district" if SchName == "Barbourville Learning Center"
replace SchType = "Other/alternative school" if SchName == "Barbourville Learning Center"
replace NCESDistrictID = "2100240" if SchName == "Barbourville Learning Center"
replace State_leaid = "KY-061016000" if SchName == "Barbourville Learning Center"
replace NCESSchoolID = "210024002542" if SchName == "Barbourville Learning Center"
replace seasch = "061016000-061016015" if SchName == "Barbourville Learning Center"
replace DistCharter = "No" if SchName == "Barbourville Learning Center"
replace SchLevel = "Middle" if SchName == "Barbourville Learning Center"
replace SchVirtual = "No" if SchName == "Barbourville Learning Center"
replace CountyName = "Knox County" if SchName == "Barbourville Learning Center"
replace CountyCode = 21121 if SchName == "Barbourville Learning Center"

replace DistType = "Regular local school district" if SchName == "Glen Dale Center"
replace SchType = "Other/alternative school" if SchName == "Glen Dale Center"
replace NCESDistrictID = "2101650" if SchName == "Glen Dale Center"
replace State_leaid = "KY-047152000" if SchName == "Glen Dale Center"
replace NCESSchoolID = "210165002246" if SchName == "Glen Dale Center"
replace seasch = "047152000-047152045" if SchName == "Glen Dale Center"
replace DistCharter = "No" if SchName == "Glen Dale Center"
replace SchLevel = "Middle" if SchName == "Glen Dale Center"
replace SchVirtual = "No" if SchName == "Glen Dale Center"
replace CountyName = "Hardin County" if SchName == "Glen Dale Center"
replace CountyCode = 21093 if SchName == "Glen Dale Center"

replace DistType = "Regular local school district" if SchName == "Hancock County Alternative Program"
replace SchType = "Other/alternative school" if SchName == "Hancock County Alternative Program"
replace NCESDistrictID = "2102460" if SchName == "Hancock County Alternative Program"
replace State_leaid = "KY-046225000" if SchName == "Hancock County Alternative Program"
replace NCESSchoolID = "210246002540" if SchName == "Hancock County Alternative Program"
replace seasch = "046225000-046225015" if SchName == "Hancock County Alternative Program"
replace DistCharter = "No" if SchName == "Hancock County Alternative Program"
replace SchLevel = "Middle" if SchName == "Hancock County Alternative Program"
replace SchVirtual = "No" if SchName == "Hancock County Alternative Program"
replace CountyName = "Hancock County" if SchName == "Hancock County Alternative Program"
replace CountyCode = 21091 if SchName == "Hancock County Alternative Program"

replace DistType = "Regular local school district" if SchName == "Lynn Camp Elementary School"
replace SchType = "Regular school" if SchName == "Lynn Camp Elementary School"
replace NCESDistrictID = "2103150" if SchName == "Lynn Camp Elementary School"
replace State_leaid = "KY-061301000" if SchName == "Lynn Camp Elementary School"
replace NCESSchoolID = "210315002543" if SchName == "Lynn Camp Elementary School"
replace seasch = "061301000-061301015" if SchName == "Lynn Camp Elementary School"
replace DistCharter = "No" if SchName == "Lynn Camp Elementary School"
replace SchLevel = "Primary" if SchName == "Lynn Camp Elementary School"
replace SchVirtual = "No" if SchName == "Lynn Camp Elementary School"
replace CountyName = "Knox County" if SchName == "Lynn Camp Elementary School"
replace CountyCode = 21121 if SchName == "Lynn Camp Elementary School"

replace DistType = "Regular local school district" if SchName == "Lynn Camp Middle High School"
replace SchType = "Regular school" if SchName == "Lynn Camp Middle High School"
replace NCESDistrictID = "2103150" if SchName == "Lynn Camp Middle High School"
replace State_leaid = "KY-061301000" if SchName == "Lynn Camp Middle High School"
replace NCESSchoolID = "210315002544" if SchName == "Lynn Camp Middle High School"
replace seasch = "061301000-061301025" if SchName == "Lynn Camp Middle High School"
replace DistCharter = "No" if SchName == "Lynn Camp Middle High School"
replace SchLevel = "Middle" if SchName == "Lynn Camp Middle High School"
replace CountyName = "Knox County" if SchName == "Lynn Camp Middle High School"
replace CountyCode = 21121 if SchName == "Lynn Camp Middle High School"
replace SchVirtual = "No" if SchName == "Lynn Camp Middle High School"

replace DistType = "Regular local school district" if SchName == "Patriot Academy"
replace SchType = "Other/alternative school" if SchName == "Patriot Academy"
replace NCESDistrictID = "2100070" if SchName == "Patriot Academy"
replace State_leaid = "KY-002005000" if SchName == "Patriot Academy"
replace NCESSchoolID = "210007002535" if SchName == "Patriot Academy"
replace seasch = "002005000-002005025" if SchName == "Patriot Academy"
replace DistCharter = "No" if SchName == "Patriot Academy"
replace SchLevel = "Other" if SchName == "Patriot Academy"
replace CountyName = "Allen County" if SchName == "Patriot Academy"
replace CountyCode = 21003 if SchName == "Patriot Academy"
replace SchVirtual = "No" if SchName == "Patriot Academy"

replace DistType = "Regular local school district" if SchName == "Virtual Academy"
replace SchType = "Other/alternative school" if SchName == "Virtual Academy"
replace NCESDistrictID = "2101470" if SchName == "Virtual Academy"
replace State_leaid = "KY-030145000" if SchName == "Virtual Academy"
replace NCESSchoolID = "210147002538" if SchName == "Virtual Academy"
replace seasch = "030145000-030145035" if SchName == "Virtual Academy"
replace DistCharter = "No" if SchName == "Virtual Academy"
replace SchLevel = "Other" if SchName == "Virtual Academy"
replace CountyName = "Daviess County" if SchName == "Virtual Academy"
replace CountyCode = 21059 if SchName == "Virtual Academy"
replace SchVirtual = "No" if SchName == "Patriot Academy"

cap replace SchVirtual = "Missing/not reported" if missing(SchVirtual) & DataLevel == 3

gen StudentGroup_TotalTested = "--"

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
save "`Output'/KY_AssmtData_2023", replace
export delimited "`Output'/KY_AssmtData_2023", replace


// Merging in Edfacts data for 2022 and 2023
forvalues year = 2022/2023 {
	
	use "`Output'/KY_AssmtData_`year'", clear
	
	destring NCESDistrictID, replace force
	destring NCESSchoolID, replace force
	merge m:1 DataLevel NCESDistrictID NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "`edfacts'/edfacts2022_KY.dta"
	
	replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
rename Count Count_n
replace ParticipationRate = Participation if _merge == 3 & Participation != ""
drop if _merge == 2
drop state _merge PctProf2 Participation2

** Deriving More SubGroup Counts
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen All = max(Count_n)
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Econ = sum(Count_n) if StudentGroup == "Economic Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Disability = sum(Count_n) if StudentGroup == "Disability Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Migrant = sum(Count_n) if StudentGroup == "Migrant Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Home = sum(Count_n) if StudentGroup == "Homeless Enrolled Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Eng = sum(Count_n) if StudentGroup == "EL Status"
replace Count_n = All - Econ if StudentSubGroup == "Not Economically Disadvantaged"
replace Count_n = All - Disability if StudentSubGroup == "Non-SWD"
replace Count_n = All - Home if StudentSubGroup == "Non-Homeless"
replace Count_n = All - Migrant if StudentSubGroup == "Non-Migrant"
replace Count_n = All - Eng if StudentSubGroup == "English Proficient"
replace StudentSubGroup_TotalTested = string(Count_n) if inlist(StudentSubGroup, "Not Economically Disadvantaged", "Non-SWD", "Non-Migrant", "English Proficient", "Non-Homeless") & Count_n != .

** StudentGroup_TotalTested
drop StudentGroup_TotalTested
replace Count_n = 0 if Count_n == .
bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen test = min(Count_n)
bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(Count_n) if test != 0
tostring Count_n, replace force
replace Count_n = "--" if Count_n == "."
replace StudentSubGroup_TotalTested = Count_n if Count_n != "0" & Count_n != "--"
drop Count_n test All Econ Disability Migrant Home Eng
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "--" if inlist(StudentGroup_TotalTested, "", ".")

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
	save "`Output'/KY_AssmtData_`year'", replace
export delimited "`Output'/KY_AssmtData_`year'", replace
}
