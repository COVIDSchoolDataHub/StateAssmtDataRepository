clear

// Define file paths

global original_files "/Users/meghancornacchia/Desktop/DataRepository/Minnesota/Original_Data_Files"
global NCES_files "/Users/meghancornacchia/Desktop/DataRepository/NCES_Data_Files"
global output_files "/Users/meghancornacchia/Desktop/DataRepository/Minnesota/Output_Data_Files"
global temp_files "/Users/meghancornacchia/Desktop/DataRepository/Minnesota/Temporary_Data_Files"

// 2008-2009

// Converting subject tab files to dta and appending

import delimited "$original_files/MN_OriginalData_2009_mat_rea.tab", clear

tostring grade, replace
replace grade = "0" + grade
drop schoolcountynumber
drop districtcountynumber
drop ecsunumber
drop ecodevrgn
drop testdate
drop reportorder

save "${temp_files}/MN_AssmtData_2009_mat_rea.dta", replace

import delimited "$original_files/MN_OriginalData_2009_sci.txt", clear

drop schoolcountynumber
drop districtcountynumber
drop ecsunumber
drop ecodevrgn
drop testdate
drop reportorder

save "${temp_files}/MN_AssmtData_2009_sci.dta", replace

import excel "$original_files/MN_OriginalData_2009_sci_state.xlsx", sheet("Public School Districts") firstrow cellrange(A1:AB3) case(lower) clear

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

save "${temp_files}/MN_AssmtData_2009_sci_state.dta", replace

clear

append using "${temp_files}/MN_AssmtData_2009_sci_state.dta" "${temp_files}/MN_AssmtData_2009_sci.dta" "${temp_files}/MN_AssmtData_2009_mat_rea.dta"

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
drop if StudentGroup == "Special Education" 
drop if StudentGroup == "MigrantStatus"

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

gen ProficientOrAbove_count = Lev3_count+Lev4_count

foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent {
	replace `var' = `var'/100
}

gen ProficientOrAbove_percent = Lev3_percent+Lev4_percent

foreach var of varlist Lev1_count Lev2_count Lev3_count Lev4_count Lev1_percent Lev2_percent Lev3_percent Lev4_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent {
	tostring `var', replace force
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
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3 and 4"
gen ParticipationRate = ""

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

// Generating Student Group Counts
bysort seasch StudentGroup Grade Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

// Saving transformed data
save "${output_files}/MN_AssmtData_2009.dta", replace

// Merging with NCES School Data

use "$NCES_files/NCES_2009_School.dta", clear 

keep if ncesschoolid == "273384004275" | ncesschoolid == "270318004269" | ncesschoolid == "273175004277" | ncesschoolid == "273333004284" | ncesschoolid == "270444004315"

append using "$NCES_files/NCES_2008_School.dta"

keep state_location state_fips district_agency_type school_type ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code

keep if substr(ncesschoolid, 1, 2) == "27"

merge 1:m seasch using "${output_files}/MN_AssmtData_2009.dta", keep(match using) nogenerate

save "${output_files}/MN_AssmtData_2009.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES_2008_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code

keep if substr(ncesdistrictid, 1, 2) == "27"

merge 1:m state_leaid using "${output_files}/MN_AssmtData_2009.dta", keep(match using) nogenerate

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
rename school_type SchType
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

// Fixing Missing DistType
save "${output_files}/MN_AssmtData_2009.dta", replace
keep if StateFips == .
keep NCESDistrictID
rename NCESDistrictID ncesdistrictid
duplicates drop
merge 1:1 ncesdistrictid using "$NCES_files/NCES_2009_District.dta", keep(match) nogenerate
rename ncesdistrictid NCESDistrictID
rename state_fips StateFips
rename district_agency_type DistType
keep NCESDistrictID StateFips DistType

merge 1:m NCESDistrictID using "${output_files}/MN_AssmtData_2009.dta", nogenerate

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/MN_AssmtData_2009.dta", replace
export delimited using "$output_files/MN_AssmtData_2009.csv", replace
