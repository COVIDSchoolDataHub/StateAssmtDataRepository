clear
set more off
set trace off

cd "/Users/benjaminm/Documents/State_Repository_Research"
local Original "/Users/benjaminm/Documents/State_Repository_Research/Oregon/Original"
local Output "/Users/benjaminm/Documents/State_Repository_Research/Oregon/Output"
local NCESDistrict "/Users/benjaminm/Documents/State_Repository_Research/NCES/District"
local NCESSchool "/Users/benjaminm/Documents/State_Repository_Research/NCES/School"

// use "`Original'/2021"
use "`Output'/OR_AssmtData_2023", replace
// tab StudentSubGroup DataLevel

// use "`Output'/OR_AssmtData_2024", replace
// keep if NCESSchoolID == "Missing/Not Reported" | NCESSchoolID == "411224011374"
// replace NCESSchoolID = "Missing/not reported" if NCESSchoolID == "Missing/Not Reported"
// export delimited "`Output'/OR_MissingNCES_Schools", replace
// //Unhide Below Importing Code on First Run

/*
forvalues year = 2015/2024 {
	if `year' == 2020 | `year' == 2021 continue
	tempfile temp1
	save "`temp1'", emptyok
	clear
	foreach dl in State District School {
		foreach Subject in ela mat sci {
		local prior_2019_sg "RE ES_EL_Gen"
		local post_2019_sg "RE ES EL Gen SWD"
				if "`dl'" != "School" {
					import excel "`Original'/OR_OriginalData_`year'_`Subject'_`dl'", firstrow case(preserve) allstring
					gen DataLevel = "`dl'"
					append using "`temp1'"
					save "`temp1'", replace
					clear
					
				}
				if "`dl'" == "School" & (`year' < 2019 | "`Subject'" == "sci") {
					foreach sg of local prior_2019_sg {
					import excel "`Original'/OR_OriginalData_`year'_`Subject'_`dl'_`sg'", firstrow case(preserve) allstring
					gen DataLevel = "`dl'"
					append using "`temp1'"
					save "`temp1'", replace
					clear
				}
			}
				if "`dl'" == "School" & `year' >= 2019 & "`Subject'" != "sci"  {
					foreach sg of local post_2019_sg {
					import excel "`Original'/OR_OriginalData_`year'_`Subject'_`dl'_`sg'", firstrow case(preserve) allstring
					gen DataLevel = "`dl'"
					append using "`temp1'"
					save "`temp1'", replace
					clear
					}
				}
			
		}
	}
	use "`temp1'"
	save "`Original'/`year'", replace
	clear
}


*/

/*
clear
tempfile temp1
save "`temp1'", emptyok
foreach dl in State District School {
	foreach sg in EL ES Gen RE {
		if "`dl'" != "School" {
			import excel "`Original'/OR_OriginalData_2021_`dl'", firstrow case(preserve) allstring
			gen DataLevel = "`dl'"
					append using "`temp1'"
					save "`temp1'", replace
					clear
		}
		if "`dl'" == "School" {
			import excel "`Original'/OR_OriginalData_2021_`dl'_`sg'", firstrow case(preserve) allstring
			gen DataLevel = "`dl'"
					append using "`temp1'"
					save "`temp1'", replace
					clear
		}
	}
}
use "`temp1'"
save "`Original'/2021", replace
clear

*/

//Unhide Above importing code on first run


**# Bookmark #1

forvalues year == 2015/2024 {
if `year' == 2020 | `year' == 2021 continue

use "`Original'/`year'"


local prevyear =`=`year'-1'

//Renaming and Dropping
drop AcademicYear
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)
rename DistrictID StateAssignedDistID
rename District DistName
rename SchoolID StateAssignedSchID
rename School SchName
rename StudentGroup StudentSubGroup
foreach n in 1 2 3 4 5 {
	cap rename NumberLevel`n' Lev`n'_count
	cap rename PercentLevel`n' Lev`n'_percent
}
rename NumberofParticipants StudentSubGroup_TotalTested
gen ProficientOrAbove_percent = ""
gen ProficientOrAbove_count = ""
if `year' <= 2017 {
replace ProficientOrAbove_count = NumberProficientLevel3or4 if !missing(NumberProficientLevel3or4)
replace ProficientOrAbove_count = NumberProficientLevel4or5 if !missing(NumberProficientLevel4or5)
replace ProficientOrAbove_percent = PercentProficientLevel4or5 if !missing(PercentProficientLevel4or5)
replace ProficientOrAbove_percent = PercentProficientLevel3or4 if !missing(PercentProficientLevel3or4)
}
if `year' ==2018 {
	replace ProficientOrAbove_count = NumberProficient
	replace ProficientOrAbove_percent = PercentProficientLevel4or5 if !missing(PercentProficientLevel4or5)
	replace ProficientOrAbove_percent = PercentProficientLevel3or4 if !missing(PercentProficientLevel3or4)
}
if `year' ==2019 {
replace ProficientOrAbove_count = NumberProficient if !missing(NumberProficient)
replace ProficientOrAbove_percent = PercentProficientLevel3or4 if !missing(PercentProficientLevel3or4)
}
if `year' == 2022 {
replace ProficientOrAbove_count = NumberProficient if !missing(NumberProficient)
replace ProficientOrAbove_percent = PercentProficientLevel3or4 if !missing(PercentProficientLevel3or4)
replace ProficientOrAbove_percent = PercentProficient if !missing(PercentProficient)

}
if `year' == 2023 {
	replace ProficientOrAbove_count = NumberProficient
	replace ProficientOrAbove_percent = PercentProficient
}

if `year' == 2024 {
	replace ProficientOrAbove_count = NumberProficient
	replace ProficientOrAbove_percent = PercentProficient
}

destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
destring ProficientOrAbove_percent, gen(Prof) force
replace Prof = Prof/100
gen ProfCount = round(Prof * nStudentSubGroup_TotalTested)
replace ProficientOrAbove_count = string(ProfCount) if inlist(ProficientOrAbove_count, "*", "--", "") & ProfCount != .

cap gen Lev5_count = ""
cap gen Lev5_percent = ""

keep StateAssignedDistID DistName StateAssignedSchID SchName Subject StudentSubGroup GradeLevel Lev5_count Lev5_percent Lev4_count Lev4_percent Lev3_count Lev3_percent Lev2_count Lev2_percent Lev1_count Lev1_percent StudentSubGroup_TotalTested ParticipationRate DataLevel SchYear ProficientOrAbove_count ProficientOrAbove_percent nStudentSubGroup_TotalTested

//Subject 
replace Subject = "sci" if Subject == "Science"
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "ela" if strpos(Subject, "English") !=0

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.)
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = subinstr(StudentSubGroup, "Alaskan", "Alaska", .)
replace StudentSubGroup = "Economically Disadvantaged" if strpos(StudentSubGroup, "Disadvantaged") !=0
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Students Experiencing Poverty"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Students Not Experiencing Poverty"
replace StudentSubGroup = subinstr(StudentSubGroup, "Learners", "Learner",.)
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Current English Learner"
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Multi") !=0
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All Students") !=0
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All students") !=0
replace StudentSubGroup = "Migrant" if strpos(StudentSubGroup, "Migrant Education") != 0
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities (SWD)"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Pacific Islander") != 0
replace StudentSubGroup = "Military" if strpos(StudentSubGroup, "Military") != 0
replace StudentSubGroup = "Foster Care" if strpos(StudentSubGroup, "Foster Care") != 0
replace StudentSubGroup = "Gender X" if strpos(StudentSubGroup, "Non-Binary") != 0
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without Disabilities"



keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "Unknown" | StudentSubGroup == "SWD" | StudentSubGroup == "Migrant" | StudentSubGroup == "Military" | StudentSubGroup == "Homeless" | StudentSubGroup == "Foster Care" | StudentSubGroup == "Gender X" | StudentSubGroup == "Non-SWD"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Unknown"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD" 
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel != 3

//ProficientOrAbove_count
replace ProficientOrAbove_count = "*" if regexm(ProficientOrAbove_count, "[<>]") !=0

//Dealing with ProficientOrAbove_percent ranges
replace ProficientOrAbove_percent = "0-0.05" if strpos(ProficientOrAbove_percent, "<") !=0
replace ProficientOrAbove_percent = "0.95-1" if strpos(ProficientOrAbove_percent, ">") !=0

//Proficiency Levels
foreach n in 1 2 3 4 5 {
destring Lev`n'_percent, gen(nLev`n'_percent) i(*-%)
replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.3g") if regexm(Lev`n'_percent, "[*-]") ==0
}
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*-)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100,"%9.3g") if regexm(ProficientOrAbove_percent, "[*-]") == 0

//Derive Additional Information
gen flag1 = 1 if ProficientOrAbove_count == "*" & ProficientOrAbove_percent != "0-0.05"
gen flag2 = 1 if ProficientOrAbove_count == "*" & ProficientOrAbove_percent != "0.95-1"
gen xlow = round(0.05 * nStudentSubGroup_TotalTested)
gen xhigh = round(0.95 * nStudentSubGroup_TotalTested)
replace ProficientOrAbove_count = "0-" + string(xlow) if flag1 == 1 & xlow != .
replace ProficientOrAbove_percent = string(xhigh) + "-1" if flag2 == 1 & xhigh != .

replace ProficientOrAbove_count = "*" if ProficientOrAbove_percent == "*" & ProficientOrAbove_count == "--"
replace ProficientOrAbove_count = "*" if StudentSubGroup_TotalTested == "*" & ProficientOrAbove_count == "--"

//ParticipationRate
destring ParticipationRate, gen(nParticipationRate) i(*-)
replace ParticipationRate = string(nParticipationRate/100, "%9.3g") if regexm(ParticipationRate, "[*-]") ==0

//Missing Data
foreach var of varlist Lev* ParticipationRate ProficientOrAbove_percent StudentSubGroup_TotalTested ProficientOrAbove_count {
	replace `var' = "--" if `var' == "-"
	replace `var' = "--" if `var' == "."
}

**Merging with NCES Data**
tempfile temp1
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) ==3
replace StateAssignedSchID = "00" + StateAssignedSchID if strlen(StateAssignedSchID) ==2
replace StateAssignedSchID = "000" + StateAssignedSchID if strlen(StateAssignedSchID) ==1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'", replace
clear



if `year' < 2023 {
use "`NCESDistrict'/NCES_`prevyear'_District"
}
if `year' == 2023{
use "`NCESDistrict'/NCES_`prevyear'_District"
drop year
merge 1:1 ncesdistrictid using "`NCESDistrict'/NCES_2022_District", keepusing (DistLocale county_code county_name DistCharter)
drop if _merge == 2
drop _merge
}

if `year' == 2024 {
use "`NCESDistrict'/NCES_2022_District"
}


keep if state_name == "Oregon" | state_location == "OR"
gen StateAssignedDistID = substr(state_leaid,-4,4)
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge ==1
save "`tempdist'", replace
clear



//School
use "`temp1'"
keep if DataLevel ==3
tempfile tempsch
save "`tempsch'", replace
clear
if `year' < 2023 {
use "`NCESSchool'/NCES_`prevyear'_School"
}

if `year'==2023{
use "`NCESSchool'/NCES_`prevyear'_School"
drop district_agency_type
merge 1:1 ncesdistrictid ncesschoolid using "`NCESSchool'/NCES_2022_School", keepusing (DistLocale county_code county_name district_agency_type SchVirtual)
drop if _merge == 2
drop _merge
}


if `year' == 2024 {
use "`NCESSchool'/NCES_2022_School"
}


keep if state_name == "Oregon" | state_location == "OR"
if `year' >= 2023{
	drop if state_name == "Idaho"
	rename school_type SchType
	keep state_location state_fips ncesdistrictid ncesschoolid seasch state_leaid district_agency_type DistLocale county_code county_name DistCharter SchType SchLevel SchVirtual
}
gen StateAssignedSchID = substr(seasch, -4,4)
merge 1:m StateAssignedSchID using "`tempsch'"


drop if _merge ==1

if `year' >= 2023 {
decode district_agency_type, gen(district_agency_type1)
drop district_agency_type
rename district_agency_type1 district_agency_type
}

save "`tempsch'", replace
clear



//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"



//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 41
replace StateAbbrev = "OR"

if `year' == 2015{
	replace CountyName = strproper(CountyName)
}

//Generating additional variables
gen State = "Oregon"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular"
gen AssmtName = "Smarter Balanced Assessment"
replace AssmtName = "OAKS Science" if Subject == "sci" & `year' < 2019
replace AssmtName = "OSAS" if Subject == "sci" & `year' >= 2019
replace ProficiencyCriteria = "Levels 4-5" if Subject == "sci" & `year' < 2019



//Flags
foreach var of varlist Flag* {
	replace `var' = "Y" if ("`var'" == "Flag_AssmtNameChange" | "`var'" == "Flag_CutScoreChange_ELA" | "`var'" == "Flag_CutScoreChange_math") & `year' == 2015
	replace `var' = "Y" if "`var'" == "Flag_CutScoreChange_sci" & `year' == 2019
}

replace Flag_AssmtNameChange = "N" if Subject == "sci" & `year' == 2015
replace Flag_AssmtNameChange = "Y" if Subject == "sci" & `year' == 2019
replace Flag_CutScoreChange_sci = "Y" if `year' == 2023

//Empty Variables
gen AvgScaleScore = "--"

//Fixing Lev5_count and Lev5_percent
replace Lev5_count = "" if Subject != "sci"
replace Lev5_percent = "" if Subject != "sci"
replace Lev5_count = "" if Subject == "sci" & `year' > 2018
replace Lev5_percent = "" if Subject == "sci" & `year' > 2018

//StudentGroup_TotalTested
duplicates drop DataLevel AssmtName AssmtType NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup StudentSubGroup, force 
duplicates drop
sort StudentGroup
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel != 3 //Remove quotations if SchIDs are numeric
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

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0

drop Unsuppressed* missing_*


// egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
// tostring StudentGroup_TotalTested, replace
// replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"
//
//
//
// sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
// gen Suppressed = 0
// replace Suppressed = 1 if inlist(StudentSubGroup_TotalTested, "--", "*")
// egen StudentGroup_Suppressed = max(Suppressed), by(StudentGroup GradeLevel Subject DataLevel seasch StateAssignedDistID DistName SchName)
// drop Suppressed
// gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
// replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
// replace StudentGroup_TotalTested = AllStudents_Tested if StudentGroup_Suppressed == 1
// replace StudentGroup_TotalTested = AllStudents_Tested if inlist(StudentGroup, "Homeless Enrolled Status", "Migrant Status", "Foster Care Status", "Military Connected Status", "Disability Status", "Economic Status", "EL Status")
// drop AllStudents_Tested StudentGroup_Suppressed

//Supression
foreach var of varlist StudentSubGroup_TotalTested Lev* ParticipationRate {
	replace `var' = "*" if `var' == "--" & ProficientOrAbove_percent != "--"
}

//Dropping Empty Obs
// drop if ProficientOrAbove_percent == "--" commented out due to dropping all variables 
replace StudentGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "*" & StudentSubGroup == "All Students"

**Unmerged 2023**
if `year' == 2023 {
replace DistType = "Regular local school district" if DistType == "" & DataLevel == 3
}

if `year' == 2024 {
** fixing district info for unmerged schools for 2024 ** 
* For NCESDistrictID
bysort DistName (NCESDistrictID): gen missing_flag = missing(NCESDistrictID)
bysort DistName (missing_flag): replace NCESDistrictID = NCESDistrictID[_n-1] if missing(NCESDistrictID)
drop missing_flag

* For DistType
bysort DistName (DistType): gen missing_flag_disttype = missing(DistType)
bysort DistName (missing_flag_disttype): replace DistType = DistType[_n-1] if missing(DistType)
drop missing_flag_disttype

* For DistCharter
bysort DistName (DistCharter): gen missing_flag_distcharter = missing(DistCharter)
bysort DistName (missing_flag_distcharter): replace DistCharter = DistCharter[_n-1] if missing(DistCharter)
drop missing_flag_distcharter

* For DistLocale
bysort DistName (DistLocale): gen missing_flag_distlocale = missing(DistLocale)
bysort DistName (missing_flag_distlocale): replace DistLocale = DistLocale[_n-1] if missing(DistLocale)
drop missing_flag_distlocale

* For CountyName
bysort DistName (CountyName): gen missing_flag_nces = missing(CountyName)
bysort DistName (missing_flag_nces): replace CountyName = CountyName[_n-1] if missing(CountyName)
drop missing_flag_nces

* For CountyCode
bysort DistName (CountyCode): gen missing_flag_nces = missing(CountyCode)
bysort DistName (missing_flag_nces): replace CountyCode = CountyCode[_n-1] if missing(CountyCode)
drop missing_flag_nces

// fixing unmerged schools 
replace SchType = 1 if SchName == "Art Rutkin Elementary School"
replace SchLevel = 1 if SchName == "Art Rutkin Elementary School"
replace SchVirtual = 0 if SchName == "Art Rutkin Elementary School"
replace NCESSchoolID = "411224011374" if SchName == "Art Rutkin Elementary School"

replace SchType = 1 if SchName == "Clark Elementary School"
replace SchLevel = 1 if SchName == "Clark Elementary School"
replace SchVirtual = 0 if SchName == "Clark Elementary School"
replace NCESSchoolID = "411004011371" if SchName == "Clark Elementary School"

replace SchType = 1 if SchName == "Oakdale Middle School"
replace SchLevel = 2 if SchName == "Oakdale Middle School"
replace SchVirtual = 0 if SchName == "Oakdale Middle School"
replace NCESSchoolID = "410804011365" if SchName == "Oakdale Middle School"

replace SchType = 1 if SchName == "Tamarack Elementary School"
replace SchLevel = 1 if SchName == "Tamarack Elementary School"
replace SchVirtual = 0 if SchName == "Tamarack Elementary School"
replace NCESSchoolID = "410002311372" if SchName == "Tamarack Elementary School"
}

// R1 Updates

foreach var of varlist DistName SchName {
replace `var' = strtrim(`var')
replace `var' = stritrim(`var')
}


// derviations 
gen flag_gen = 1 if ProficientOrAbove_count == "--" & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & !missing(real(StudentSubGroup_TotalTested)) 
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count))  if flag_gen == 1
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent)) if flag_gen == 1
drop flag_gen

// FINISH THE DERIVATIONS, COPY AND PAST OR LOOP TO GEN ALL POSSIBLE MISSING COUNT VARS HERE
// LAST DERVIATION IS ADDITIONAL SUBGROUPS, THEN DERS COMPLETE


// gen flag_gen = 1 if !missing(real(Lev1_count)) & !missing(real(Lev2_count))  & !missing(real(ProficientOrAbove_count)) & !missing(real(StudentSubGroup_TotalTested)) & (Lev4_count == "--" | Lev4_count == "*" )

// deriving Lev4
gen derive_L4_count_lev34 = 1 if ProficiencyCriteria=="Levels 3-4" & inlist(Lev4_count, "*", "--")  & !inlist(Lev3_count, "*", "--") & !inlist(ProficientOrAbove_count,  "*", "--")
replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count)) if derive_L4_count_lev34 == 1
replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent)) if derive_L4_count_lev34 == 1
drop derive_L4_count_lev34 

gen derive_L4_per_lev34 = 1 if ProficiencyCriteria== "Levels 3-4" & !inlist(Lev3_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "-- ")  & inlist(Lev4_percent, "*", "--") 
replace Lev4_percent = string(1 - real(Lev1_percent) - real(Lev2_percent) - real(Lev3_percent)) if derive_L4_per_lev34 == 1
drop derive_L4_per_lev34



// deriving Lev3_count
 gen derive_L3_count_lev34 = .
         replace derive_L3_count_lev34 = 1 if ProficiencyCriteria =="Levels 3-4" & inlist(Lev3_count, "*", "--")  & !inlist(Lev4_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--")
replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count)) if derive_L3_count_lev34 == 1
replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent)) if derive_L3_count_lev34 == 1
drop derive_L3_count_lev34

gen derive_L3_per_lev34 = 1 if ProficiencyCriteria== "Levels 3-4" & !inlist(Lev4_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "-- ")  & inlist(Lev3_percent, "*", "--") 
replace Lev3_percent = string(1 - real(Lev1_percent) - real(Lev2_percent) - real(Lev4_percent)) if derive_L3_per_lev34 == 1
drop derive_L3_per_lev34


// replace Lev4_percent = string(1 - real(Lev3_percent)) if derive_L4_count_lev34 == 1
// gen flag_gen = 1 if !missing(real(Lev1_count)) & !missing(real(Lev2_count))  & !missing(real(Lev4_count)) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(Lev3_count)) // Lev4_count == "--" | Lev4_count == "*"
// replace Lev3_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count) - real(Lev4_count))  if flag_gen == 1
// replace Lev4_percent = string(1 - real(Lev1_percent) - real(Lev2_percent) - real(Lev4_percent)) if flag_gen == 1
// drop flag_gen 

gen flag_gen = 1 if !missing(real(Lev1_count)) & !missing(real(Lev4_count))  & !missing(real(Lev3_count)) & !missing(real(StudentSubGroup_TotalTested))  & missing(real(Lev2_count)) & ProficiencyCriteria =="Levels 3-4"  
replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev4_count) - real(Lev3_count))  if flag_gen == 1
replace Lev2_percent = string(1 - real(Lev1_percent) - real(Lev4_percent) - real(Lev3_percent)) if flag_gen == 1
drop flag_gen 

gen flag_gen = 1 if !missing(real(Lev4_count)) & !missing(real(Lev2_count))  & !missing(real(Lev3_count)) & !missing(real(StudentSubGroup_TotalTested))  & missing(real(Lev1_count)) & ProficiencyCriteria =="Levels 3-4" 
replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(Lev4_count) - real(Lev2_count) - real(Lev3_count))  if flag_gen == 1
replace Lev1_percent = string(1 - real(Lev4_percent) - real(Lev2_percent) - real(Lev3_percent)) if flag_gen == 1
drop flag_gen 


replace StateAssignedDistID = "000000" if DataLevel==1

replace StateAssignedSchID = "000000" if DataLevel==1

replace StateAssignedSchID = "000000" if DataLevel==2

 
egen uniquegrp = group(DataLevel StateAssignedDistID StateAssignedSchID AssmtName Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup 
by uniquegrp: gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by uniquegrp: replace AllStudents = AllStudents[_n-1] if missing(AllStudents)


replace StudentGroup_TotalTested = "*" if AllStudents == "*" 

replace StateAssignedDistID = "" if DataLevel==1

replace StateAssignedSchID = "" if DataLevel==1

replace StateAssignedSchID = "" if DataLevel==2


duplicates drop DataLevel AssmtName AssmtType NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup StudentSubGroup, force 

duplicates drop
sort StudentGroup
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel != 3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName GradeLevel Subject)
gen missing_SSG = 1 if missing(real(StudentSubGroup_TotalTested))
egen missing_multiple = total(missing_SSG), by(StudentGroup DistName SchName GradeLevel Subject)

order StudentGroup_TotalTested UnsuppressedSG StudentSubGroup_TotalTested UnsuppressedSSG missing_multiple

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0 & !missing(real(StudentGroup_TotalTested)-UnsuppressedSG) & StudentSubGroup != "All Students"

drop Unsuppressed* missing_*


//Final Cleaning
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/OR_AssmtData_`year'", replace
export delimited "`Output'/OR_AssmtData_`year'", replace
clear

}

