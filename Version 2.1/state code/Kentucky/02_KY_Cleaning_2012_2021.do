***************************
*KENTUCKY

*File Name: 02_KY_Cleaning_2012_2021
*Last update: 02/17/25

***************************

*NOTES:

*This do-file cleans all raw data from 2012 to 2021 and merges it with NCES (using raw NCES files available on the drive)


***************************

clear
set more off
set trace off



//Importing (unhide after first run)


forvalues year = 2012/2017 {
	import excel "${Original}/KY_OriginalData_`year'_all", firstrow case(preserve) allstring
	save "${Original}/KY_OriginalData_`year'", replace
	clear
}
foreach year in 2018 2019 {
	import excel "${Original}/KY_OriginalData_`year'_all", firstrow case(preserve) allstring sheet(DATA)
	save "${Original}/KY_OriginalData_`year'", replace
	clear
}


foreach year in 2021 {
	import delimited "${Original}/KY_OriginalData_`year'_all", case(preserve) stringcols(_all) clear
	save "${Original}/KY_OriginalData_`year'", replace
	clear
}



//Cleaning

forvalues year = 2012/2021 {
	if `year' == 2020 continue
use "${Original}/KY_OriginalData_`year'", clear
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
if `year' == 2021 rename NAPDPOPULATION StudentSubGroup_TotalTested //updated 1/30/25 to map correct variable
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
replace DEMOGRAPHIC = "Asian" if DEMOGRAPHIC == "ETA"
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
replace DEMOGRAPHIC = "EL and Monit or Recently Ex" if DEMOGRAPHIC == "English Learners including Monitored"
replace DEMOGRAPHIC = "EL and Monit or Recently Ex" if DEMOGRAPHIC == "English Learner including Monitored"

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
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL and Monit or Recently Ex" | StudentSubGroup == "EL Exited" | StudentSubGroup == "Ever EL"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"

replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD" 
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"  | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless" 
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Non-Military" | StudentSubGroup == "Military"

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
if `year' >= 2018 & `year' <= 2021 gen AssmtName = "KPREP"
if `year' > 2021 gen AssmtName = "Kentucky Summative Assessment"
keep StateAssignedSchID DistName SchName AssmtName Subject GradeLevel Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent StateAssignedDistID DataLevel StudentGroup ParticipationRate StudentSubGroup_TotalTested StudentSubGroup

//Converting to Decimal
foreach var of varlist ProficientOrAbove_percent Lev* ParticipationRate {
	destring `var', gen(n`var') i(*-)
	replace `var' = string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
}

//StudentGroup_TotalTested
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, ",", "", .)
sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"

gen StudentSubGroup_TotalTested2 = real(StudentSubGroup_TotalTested)
bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
gen max = real(StudentGroup_TotalTested)
replace max = 0 if max == .

bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen RaceEth = total(StudentSubGroup_TotalTested2) if StudentGroup == "RaceEth"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Gender = total(StudentSubGroup_TotalTested2) if StudentGroup == "Gender"

replace StudentSubGroup_TotalTested = string(max - RaceEth) if StudentGroup == "RaceEth" & max != 0 & StudentSubGroup_TotalTested2 == . & RaceEth != 0
replace StudentSubGroup_TotalTested = string(max - Gender) if StudentGroup == "Gender" & max != 0 & StudentSubGroup_TotalTested2 == . & Gender != 0
drop RaceEth Gender StudentSubGroup_TotalTested2

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
use "${NCES_Original}/NCES_`prevyear'_District"
keep if state_location == "KY" | state_fips_id == 21
gen StateAssignedDistID = subinstr(state_leaid, "KY-","",.)
replace StateAssignedDistID = substr(StateAssignedDistID, 4,3)
duplicates drop StateAssignedDistID, force
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge == 1
save "`tempdist'", replace
clear
/*
if `year' > 2022 {
use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District"
rename state_location StateAbbrev
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
*/
//School
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear
use "${NCES_Original}/NCES_`prevyear'_School"
keep if state_location == "KY" | state_fips_id == 21
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1,10)
replace StateAssignedSchID = substr(StateAssignedSchID, 4,6)
duplicates drop StateAssignedSchID, force
if `year' > 2019 replace StateAssignedSchID = "606450" if StateAssignedSchID == "365450"
if `year' > 2019 replace StateAssignedSchID = "606460" if StateAssignedSchID == "365460"
if `year' == 2023 {
	decode district_agency_type, gen(district_agency_type1)
	drop district_agency_type
	rename district_agency_type1 district_agency_type
	rename school_type SchType
	keep State state_location state_fips ncesdistrictid ncesschoolid state_leaid district_agency_type county_name county_code DistLocale DistCharter school_name SchType SchVirtual SchLevel StateAssignedSchID lea_name
}
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge == 1
drop _merge
save "`tempsch'", replace
clear
/*
if `year' > 2022 {
use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_2022_School"
keep if StateAbbrev == "KY" | StateFips == "21"
gen seasch = substr(st_schid, "KY-", "", .)
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1,10)
replace StateAssignedSchID = substr(StateAssignedSchID, 4,6)
duplicates drop StateAssignedSchID, force
if `year' > 2019 replace StateAssignedSchID = "606450" if StateAssignedSchID == "365450"
if `year' > 2019 replace StateAssignedSchID = "606460" if StateAssignedSchID == "365460"
rename school_type SchType
merge 1:m StateAssignedSchID using "`tempsch'", update
drop if _merge == 1
destring StateFips, replace
save "`tempsch'", replace
clear
}
*/
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
replace StateFips = 21
replace StateAbbrev = "KY"

//Idk whats going on with 2018 and missing DistNames. They're not in NCES. I'm Assuming for now that these are the "COOPS" that appear in later years
if `year' == 2018 drop if missing(DistName)

replace CountyName = strproper(CountyName)
replace CountyName= "LaRue County" if CountyName == "Larue County"
replace CountyName = "McCracken County" if CountyName == "Mccracken County"
replace CountyName = "McCreary County" if CountyName == "Mccreary County"
replace CountyName = "McLean County" if CountyName == "Mclean County"

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

//Deriving Counts
forvalues n = 1/4{
	replace Lev`n'_count = string(round(real(Lev`n'_percent) * real(StudentSubGroup_TotalTested))) if missing(real(Lev`n'_count)) & !missing(real(Lev`n'_percent)) & !missing(real(StudentSubGroup_TotalTested))
}

replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent) * real(StudentSubGroup_TotalTested))) if missing(real(ProficientOrAbove_count)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(StudentSubGroup_TotalTested))

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "N"
gen Flag_CutScoreChange_sci = "N"

if `year' == 2012 {
replace Flag_AssmtNameChange = "Y"
replace Flag_CutScoreChange_ELA = "Y"
replace Flag_CutScoreChange_math = "Y"
replace Flag_CutScoreChange_soc = "Y"
replace Flag_CutScoreChange_sci = "Y"
}

if `year' == 2018 {
replace Flag_CutScoreChange_sci = "Y"
}

if `year' == 2022 {
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

if `year' == 2021 {
	drop if inlist(SchName, "Model Elementary", "Model High School") //distname is mismatched in raw data & NCES data and then the schools are dropped in subsequent years due to lack of NCES information
}

if `year' > 2021 {
	drop if NCESSchoolID == "" & DataLevel == 3 //these are two schools (in the Model Laboratory district) that don't exist in the NCES record + the dist level observations have the same exact information
}

//Response to Review
cap replace SchVirtual = -1 if missing(SchVirtual) & DataLevel == 3

//Final Cleaning
replace StudentGroup_TotalTested = "--" if `year' >= 2022

if `year' >= 2015 {
	
	foreach v of varlist SchType SchLevel SchVirtual {
	
	decode `v', generate(`v'1)
	drop `v'
	rename `v'1 `v'
	
}

}

if `year' < 2015 {
	
	foreach v of varlist SchType SchLevel {
	
	decode `v', generate(`v'1)
	drop `v'
	rename `v'1 `v'
	
}

}
//Standardize Names & IDs
replace DistName = stritrim(DistName)
replace SchName = stritrim(SchName)
replace DistName = "KY School for the Blind" if NCESDistrictID == "2100094"
replace DistName = "KY School for the Deaf" if NCESDistrictID == "2100095"
replace StateAssignedDistID = "00" + StateAssignedDistID if strlen(StateAssignedDistID) == 1
replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 2
replace StateAssignedSchID = "00" + StateAssignedSchID if strlen(StateAssignedSchID) == 4
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 5

//Final Cleaning
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/KY_AssmtData_`year'", replace
export delimited "${Output}/KY_AssmtData_`year'", replace
clear	
	
}

**********************

* END of 02_KY_Cleaning_2012_2021

**********************


