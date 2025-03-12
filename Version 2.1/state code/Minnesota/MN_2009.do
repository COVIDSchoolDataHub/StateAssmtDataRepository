* MINNESOTA

* File name: MN_2009
* Last update: 2/21/2025

*******************************************************
* Notes

	* This do file cleans MN's 2009 data and merges with NCES 2008. 
	* Only one temp output created.
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear
// 2008-2009
// Converting subject tab files to dta and appending
import excel "$Original/MN_OriginalData_2009_mat_rea.xlsx", sheet("Sheet2") firstrow case(lower) clear

//Correcting the datayear variable because of issues importing - STATA reads it as a date.
gen datayear2 = "08-09" if datayear ==  23597 // Stata reads this as 8/9/24. No other values in datayear.
drop datayear
rename datayear2 datayear

tostring grade, replace
replace grade = "0" + grade
drop schoolcountynumber
drop districtcountynumber
drop ecsunumber
drop ecodevrgn
drop testdate
drop reportorder

save "${Temp}/MN_AssmtData_2009_mat_rea.dta", replace

import delimited "$Original/MN_OriginalData_2009_sci.txt", clear

drop schoolcountynumber
drop districtcountynumber
drop ecsunumber
drop ecodevrgn
drop testdate
drop reportorder

save "${Temp}/MN_AssmtData_2009_sci.dta", replace

import excel "$Original/MN_OriginalData_2009_sci_state.xlsx", sheet("Public School Districts") firstrow cellrange(A1:AB3) case(lower) clear

drop districtcountynumber
destring districtnumber, replace
destring districttype, replace
destring schoolnumber, replace
drop ecsunumber
drop ecodevrgn
drop testdate
drop reportorder
destring counttested, replace
destring countleveld, replace
destring countlevelp, replace
destring countlevelm, replace
destring countlevele, replace
destring percentleveld, replace
destring percentlevelp, replace
destring percentlevelm, replace
destring percentlevele, replace
destring averagescore, replace

rename countleveld countlevel1
rename countlevelp countlevel2
rename countlevelm countlevel3
rename countlevele countlevel4
rename percentleveld percentlevel1
rename percentlevelp percentlevel2
rename percentlevelm percentlevel3
rename percentlevele percentlevel4

save "${Temp}/MN_AssmtData_2009_sci_state.dta", replace

clear

append using "${Temp}/MN_AssmtData_2009_sci_state.dta" "${Temp}/MN_AssmtData_2009_sci.dta" "${Temp}/MN_AssmtData_2009_mat_rea.dta"

// Dropping extra variables

drop districtcountyname
drop testname
drop nssaveragescore
drop pfasaveragescore
drop dspsaveragescore
drop sgmsaveragescore
drop vessaveragescore
drop cpssaveragescore
drop lssaveragescore
drop hnsaveragescore
drop pscsaveragescore
drop essaveragescore
drop lifsaveragescore
drop stddev
drop stderrorofmean
drop confidenceinterval
drop countabsent
drop countinvalid
drop countmedexempt
drop countnotcomplete
drop countpso
drop countrefused
drop countwronggrade
drop schoolclassification
drop gradeenrollment
drop k12enrollment
drop filterthreshold
drop publicschool
drop schoolcountyname

// Reformatting IDs to standard length strings
// District Code
gen districtcodebig = .
replace districtcodebig=0 if districtnumber<10
replace districtcodebig=1 if districtnumber>=10
replace districtcodebig=2 if districtnumber>=100
replace districtcodebig=3 if districtnumber>=1000

gen newdistrictnumber = string(districtnumber)

replace newdistrictnumber = "000" + newdistrictnumber if districtcodebig==0
replace newdistrictnumber = "00" + newdistrictnumber if districtcodebig==1
replace newdistrictnumber = "0" + newdistrictnumber if districtcodebig==2
replace newdistrictnumber = newdistrictnumber if districtcodebig==3

drop districtcodebig
drop districtnumber

// District Type
gen districttypebig = .
replace districttypebig=0 if districttype<10
replace districttypebig=1 if districttype>=10

gen newdistricttype = string(districttype)

replace newdistricttype = "0" + newdistricttype if districttypebig==0
replace newdistricttype = newdistricttype if districttypebig==1

drop districttypebig
drop districttype

// School ID
gen schoolcodebig = .
replace schoolcodebig=0 if schoolnumber<10
replace schoolcodebig=1 if schoolnumber>=10
replace schoolcodebig=2 if schoolnumber>=100

gen newschoolnumber = string(schoolnumber)

replace newschoolnumber = "00" + newschoolnumber if schoolcodebig==0
replace newschoolnumber = "0" + newschoolnumber if schoolcodebig==1
replace newschoolnumber = newschoolnumber if schoolcodebig==2

drop schoolcodebig
drop schoolnumber

// Relabeling variables

rename newdistricttype DistrictTypeCode
rename datayear SchYear
rename districtname DistName
rename newdistrictnumber StateAssignedDistID
rename schoolname SchName
rename newschoolnumber StateAssignedSchID
rename subject Subject
rename grade GradeLevel
rename counttested StudentSubGroup_TotalTested
rename countlevel1 Lev1_count
rename percentlevel1 Lev1_percent
rename countlevel2 Lev2_count
rename percentlevel2 Lev2_percent
rename countlevel3 Lev3_count
rename percentlevel3 Lev3_percent
rename countlevel4 Lev4_count
rename percentlevel4 Lev4_percent
rename averagescore AvgScaleScore
rename reportcategory StudentGroup
rename reportdescription StudentSubGroup

// Dropping extra categories of analysis
drop if StudentGroup == "Mobility"
*drop if StudentGroup == "Special Education" 
*drop if StudentGroup == "MigrantStatus"

// Transforming Variable Values
replace SchYear = "2008-09" if SchYear == "08-09"
replace Subject = "math" if Subject == "M"
replace Subject = "ela" if Subject == "R"
replace Subject = "sci" if Subject == "S"
replace GradeLevel = "G03" if GradeLevel == "03"
replace GradeLevel = "G04" if GradeLevel == "04"
replace GradeLevel = "G05" if GradeLevel == "05"
replace GradeLevel = "G06" if GradeLevel == "06"
replace GradeLevel = "G07" if GradeLevel == "07"
replace GradeLevel = "G08" if GradeLevel == "08"
drop if GradeLevel == "010"
drop if GradeLevel == "011"
drop if GradeLevel == "HS"
replace StudentGroup = "Migrant Status" if StudentGroup == "MigrantStatus"
replace StudentGroup = "Disability Status" if StudentGroup == "Special Education"
replace StudentGroup = "All Students" if StudentGroup == "All Categories"
replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English Proficiency"
replace StudentGroup = "Economic Status" if StudentGroup == "EconomicStatus"
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "1-American Indian"
replace StudentSubGroup = "Asian" if StudentSubGroup == "2-Asian / Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "4-Black"
replace StudentSubGroup = "White" if StudentSubGroup == "5-White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "3-Hispanic"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Eligible for LEP Services"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not eligible for LEP Services"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Eligible for Free/Reduced Priced Meals"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not eligible for Free/Reduced Priced Meals"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Receiving Special Education Services"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not receiving Special Education Services"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Eligible for Migrant Services"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not eligible for Migrant Services"

gen ProficientOrAbove_count = Lev3_count+Lev4_count

foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent {
	replace `var' = `var'/100
}

gen ProficientOrAbove_percent = Lev3_percent+Lev4_percent
replace ProficientOrAbove_percent = round(ProficientOrAbove_percent, 0.001)
replace ProficientOrAbove_count = round(ProficientOrAbove_count)

foreach var of varlist Lev1_count Lev2_count Lev3_count Lev4_count Lev1_percent Lev2_percent Lev3_percent Lev4_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent {
	tostring `var', replace force format("%9.3g")
	replace `var' = "*" if filtered == "Y"
}

drop filtered

// Fixing Justification issues
replace DistName = trim(DistName)
replace SchName = trim(SchName)

// Generating missing variables
gen Lev5_count = ""
gen Lev5_percent = ""
gen AssmtName = "Minnesota Comprehensive Assessment II"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"
gen ParticipationRate = "--"

// Data Levels
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "000"
replace DataLevel = "State" if StateAssignedDistID == "9999"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

// Combined State School IDs
// (School ID in format to match with NCES is combination of different IDs)
gen seasch = DistrictTypeCode + StateAssignedDistID + StateAssignedSchID
gen state_leaid = DistrictTypeCode + StateAssignedDistID 

// Saving transformed data
save "${Original_Cleaned}/MN_AssmtData_2009.dta", replace

************************************************************************************
*Merging with NCES data
************************************************************************************
// Merging with NCES School Data
use "$NCES_School/NCES_2009_School.dta", clear 

keep if ncesschoolid == "273384004275" | ncesschoolid == "270318004269" | ncesschoolid == "273175004277" | ncesschoolid == "273333004284" | ncesschoolid == "270444004315"

append using "$NCES_School/NCES_2008_School.dta"

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if substr(ncesschoolid, 1, 2) == "27"

merge 1:m seasch using "${Original_Cleaned}/MN_AssmtData_2009.dta", keep(match using) nogenerate

save "${Temp}/MN_AssmtData_2009.dta", replace

// Merging with NCES District Data

use "$NCES_District/NCES_2008_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if substr(ncesdistrictid, 1, 2) == "27"

merge 1:m state_leaid using "${Temp}/MN_AssmtData_2009.dta", keep(match using) nogenerate

save "${Temp}/MN_AssmtData_2009.dta", replace

// Reformatting IDs
replace StateAssignedDistID = StateAssignedDistID+"-"+DistrictTypeCode
replace StateAssignedSchID = StateAssignedDistID+"-"+StateAssignedSchID

// Removing extra variables and renaming NCES variables
drop DistrictTypeCode
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename state_location StateAbbrev
generate State = "Minnesota"
rename county_code CountyCode
*rename school_type SchType
rename state_fips StateFips
rename county_name CountyName

// Fixing missing state data
replace StateAbbrev = "MN" if DataLevel == 1
replace StateFips = 27 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
replace seasch = "" if DataLevel != 3
replace State_leaid = "" if DataLevel == 1
replace StateAbbrev = "MN" if StateAbbrev == ""

/*
// Fixing Missing DistType
save "${output_files}/MN_AssmtData_2009.dta", replace
keep if DistType == "."
keep NCESDistrictID
rename NCESDistrictID ncesdistrictid
duplicates drop
merge 1:1 ncesdistrictid using "$NCES_files/NCES_2009_District.dta", keep(match) nogenerate
rename ncesdistrictid NCESDistrictID
rename state_fips StateFips
rename district_agency_type DistType
keep NCESDistrictID StateFips DistType

merge 1:m NCESDistrictID using "${output_files}/MN_AssmtData_2009.dta", nogenerate
*/

replace StateFips = 27 if StateFips ==. 

// The following districts have no district-level raw data (the districts are not included in the raw data) and so we're dropping from the output.
//Mid-State Education District
cap drop if StateAssignedDistID=="6979-61" & DataLevel==2
//Minnesota Department of Corrections
cap drop if StateAssignedDistID=="1100-60" & DataLevel==2
//Hiawatha Valley Education District
cap drop if StateAssignedDistID=="6013-61" & DataLevel==2

// Generating Student Group Counts - ADDED 10/3/24
{
replace StateAssignedDistID = "000000" if DataLevel== 1 // State
replace StateAssignedSchID = "000000" if DataLevel== 1 // State
replace StateAssignedSchID = "000000" if DataLevel== 2 // District
egen uniquegrp = group(SchYear DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup 
by uniquegrp: gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by uniquegrp: replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
rename AllStudents StudentGroup_TotalTested
}


// Reordering variables and sorting data
local vars State StateAbbrev StateFips SchYear DataLevel DistName SchName ///
	NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID ///
	AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested ///
	StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent ///
	Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent ///
	Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ///
	ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA ///
	Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType ///
	DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Temp Output*
save "${Temp}/MN_AssmtData_2009.dta", replace
* END of MN_2009.do
****************************************************

