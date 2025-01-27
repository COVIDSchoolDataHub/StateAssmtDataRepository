*****************************************************************************
**	Updated January 26, 2025


** 	ZELMA STATE ASSESSMENT DATA REPOSITORY 
**	REVIEW CODE TEMPLATE - VERSION 2.1

**  SETUP

**	1. In your project folder, create a state folder with the format: Florida - Version 2.0
**	2. Save all of the state's assessment data .csvs. Do not save any other .csvs in this folder.
**	3. Create a folder called "review" in the state folder in case you need to export any subsets of the data.
**	4. This do file should be saved in the state folder with the .csvs.
clear 
use "/Desktop/Zelma V2.1/North Dakota - Version 2.0/ND_allyears.dta" 
***************************************
{
clear all
global Filepath "/Desktop/Zelma V2.0/North Dakota - Version 2.0" //  Set path to csv files
global Review "${Filepath}/review" 
global State "North Dakota" //Set State Name 
global StateAbbrev "ND" //Set StateAbbrev
global date "01.26.25" //Set today's date
global years 2024 2023  2022 2021 2019  2018 2017 2016 2015 //  2014 2013 2012 2011 2010 2009 2008 2007 2006 2005 2004 2003 2002 2001 2000 1999 1998

clear
tempfile temp1
save "`temp1'", empty

foreach year of global years {
	qui import delimited "${Filepath}/${StateAbbrev}_AssmtData_`year'", delimiter(",") stringcols(9, 11, 17/47) case(preserve) clear
	qui gen id = "${StateAbbrev}_AssmtData_`year'"
	qui append using "`temp1'"
	save "`temp1'", replace
	}
	
duplicates tag, gen (dup)

gen n_all = _n 
sort id n_all
by id: gen n_yr = _n 

** Generate file name; this will be used in the review process to identify the relevant files. Do not use SchYear in the event that there are issues with that variable.
split id, p(_)
rename id3 FILE
drop id id1 id2 

order FILE

save "${Filepath}/${StateAbbrev}_allyears.dta", replace
}
***********************************************************
***********************************************************
** Duplicates check 
***********************************************************
***********************************************************
** Are all files free of duplicate observations? 

{
count if !inlist(dup, 0)
 if r(N)>0 {
 	di as error "The following files have duplicate obs across all obs"
 	tab DataLevel FILE if !inlist(dup, 0)
 }
 
 else {
		di as error "Correct."
		}
}

** Are all files free of duplicate observations for each unique group that have not already been flagged? 

{
duplicates tag FILE DataLevel AssmtName AssmtType NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup StudentSubGroup, gen (dup2)
replace dup2 = 0 if dup !=0

count if !inlist(dup2, 0)
 if r(N)>0 {
 	di as error "The following files have duplicate obs"
 	tab DataLevel FILE if !inlist(dup2, 0)
 }
 
 else {
		di as error "Correct."
		}
		
drop dup dup2
}

***********************************************************
***********************************************************
** A. VARIABLE ORGANIZATION
***********************************************************
***********************************************************

** Have all files been aggregated to complete this review? 
{
tab SchYear 
}

* Are all variables in the file & correctly formatted?
{
local variables "FILE State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr"

qui describe _all
local all_found 1
local correct_format 1

foreach var of local variables {
    capture confirm variable `var', exact
    if _rc {
        di as error "`var' is missing or incorrectly named."
        local all_found 0
	}
			
}

if `all_found' == 1 & `correct_format' == 1 {
	
    di as error "Correct"
}

else {
    di as error "Please check the issues above."
}
}


***********************************************************

** • Are all variables in the correct order? (State, StateAbbrev, StateFips, etc)
{
local variables "FILE State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr"

ds
local vars=r(varlist)

	if "`vars'"=="`variables'" {
		di as error "Correct."
		}

	else {
		di as error "Variables are not in correct order."
		}
}

***********************************************************

** • Have EXTRA variables been removed from the file? 
{
local variables "FILE State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode id n_all n_yr "

qui describe _all
di r(k)
	if r(k) >50 {
		di as error "Too many variables"
		}
	if r(k)<50 {
		di as error "Missing variables" 
		}
	if r(k)==50 {
		di as error "Correct." 
		}

foreach var of varlist _all {
	if strpos("`variables'", "`var'")==0 {
		di as error "`var' is an extra variable" 
		}
	}
}
***********************************************************

** • Are variables sorted correctly? // updated 1/9/25
{
label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)

	sort FILE DataLevel_n DistName SchName AssmtType Subject GradeLevel StudentGroup StudentSubGroup
	by FILE: generate n_testingdataorder = _n 

	gen dataordercorrect =""
	replace dataordercorrect="true" if n_yr == n_testingdataorder
	replace dataordercorrect="false" if n_yr ~= n_testingdataorder

	*tab dataordercorrect // all should be true for this to be complete
	
	{
	count if inlist(dataordercorrect, "false")
	if r(N)>0 {
 	di as error "Variables are not sorted in the correct order."
 	tab DataLevel FILE if inlist(dataordercorrect, "false")
	}
 
 else {
		di as error "Correct."
		}

		drop dataordercorrect DataLevel_n 
	}

}


***********************************************************
***********************************************************
** B. DIRECTORY VARIABLES 
***********************************************************
***********************************************************

** State, StateAbbrev, StateFips, SchYear, DataLevel, Subject, GradeLevel, StudentGroup, StudentSubGroup

** • Are all vars  free from any blanks?
{
local vars_str "State StateAbbrev SchYear DataLevel Subject GradeLevel StudentGroup StudentSubGroup ProficiencyCriteria AssmtType AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc"
local vars_num "StateFips "
local errorBlanks 0  // Track blanks value 

foreach var of local vars_str {
	
	count if inlist(`var', "")
	if r(N) > 0 {
		di as error "`var' has blank values in the following files."
		tab DataLevel FILE if inlist(`var', "")
		local errorBlanks 1
	}
	
}

foreach var of local vars_num {
	
	count if inlist(`var', .)
	if r(N) > 0 {
		di as error "`var' has blank values in the following files."
		tab DataLevel FILE if inlist(`var', .)
		local errorBlanks 1
	}
}

// Summary 
if `errorBlanks' == 0 {
	di as error "Correct."
}
}
***********************************************************
** State

** • Is the state name spelled correctly/capitalized?
{
// Define the list of valid state names
local states "Alabama Alaska Arizona Arkansas California Colorado Connecticut Delaware Florida Georgia Hawaii Idaho Illinois Indiana Iowa Kansas Kentucky Louisiana Maine Maryland Massachusetts Michigan Minnesota Mississippi Missouri Montana Nebraska Nevada 'New Hampshire' 'New Jersey' 'New Mexico' 'New York' 'North Carolina' 'North Dakota' Ohio Oklahoma Oregon Pennsylvania 'Rhode Island' 'South Carolina' 'South Dakota' Tennessee Texas Utah Vermont Virginia Washington 'West Virginia' Wisconsin Wyoming"

gen state_valid = 0

foreach state in `states' {
    replace state_valid = 1 if State == "`state'"
	}

// Summary
count if !inlist(state_valid, 1)
 if r(N)>0 {
 	di as error "State is spelled incorrectly in the following files."
 	tab FILE if !inlist(state_valid, 1)
	 }
	
	else {
		di as error "Correct"
	}

drop state_valid
}

***********************************************************
** StateAbbrev

** • Is the correct state abbrev. used? // updated 1/15/25

{
gen state_abbrev_test = StateAbbrev

	label def state_abbrev_test 1 "AL" 2 "AK" 4 "AZ" 5 "AR" 6 "CA" 8 "CO" 9 "CT" 10 "DE" 11 "DC" 12 "FL" 13 "GA" 15 "HI" 16 "ID" 17 "IL" 18 "IN" 19 "IA" 20 "KS" 21 "KY" 22 "LA" 23 "ME" 24 "MD" 25 "MA" 26 "MI" 27 "MN" 28 "MS" 29 "MO" 30 "MT" 31 "NE" 32 "NV" 33 "NH" 34 "NJ" 35 "NM" 36 "NY" 37 "NC" 38 "ND" 39 "OH" 40 "OK" 41 "OR" 42 "PA" 44 "RI" 45 "SC" 46 "SD" 47 "TN" 48 "TX" 49 "UT" 50 "VT" 51 "VA" 53 "WA" 54 "WV" 55 "WI" 56 "WY"
	
	encode state_abbrev_test, gen(state_abbrev_test_n) label(state_abbrev_test)

	** Check correctness
	gen state_abbrev_incorrect = 1 if state_abbrev_test_n != StateFips

	if (sum(state_abbrev_incorrect) > 0) {
		di as error "StateAbbrev has incorrect values."
		tab FILE if state_abbrev_incorrect == 1
	} 
	else {
		di as error "Correct."
	}

	drop state_abbrev_test state_abbrev_test_n state_abbrev_incorrect

}

***********************************************************
** StateFips 

** • Is the correct FIPS code applied? (updated 1/9/25)
{
gen fips_test = State
label def fips_test 1 "Alabama" 2 "Alaska" 4 "Arizona" 5 "Arkansas" 6 "California" 8 "Colorado" 9 "Connecticut" 10 "Delaware" 11 "District of Columbia" 12 "Florida" 13 "Georgia" 15 "Hawaii" 16 "Idaho" 17 "Illinois" 18 "Indiana" 19 "Iowa" 20 "Kansas" 21 "Kentucky" 22 "Louisiana" 23 "Maine" 24 "Maryland" 25 "Massachusetts" 26 "Michigan" 27 "Minnesota" 28 "Mississippi" 29 "Missouri" 30 "Montana" 31 "Nebraska" 32 "Nevada" 33 "New Hampshire" 34 "New Jersey" 35 "New Mexico" 36 "New York" 37 "North Carolina" 38 "North Dakota" 39 "Ohio" 40 "Oklahoma" 41 "Oregon" 42 "Pennsylvania" 44 "Rhode Island" 45 "South Carolina" 46 "South Dakota" 47 "Tennessee" 48 "Texas" 49 "Utah" 50 "Vermont" 51 "Virginia" 53 "Washington" 54 "West Virginia" 55 "Wisconsin" 56 "Wyoming"
	encode fips_test, gen(fips_test_n) label(fips_test)

** Check correctness
gen fips_incorrect = 1 if fips_test_n != StateFips

	if (sum(fips_incorrect) > 0) {
		di as error "StateFips has incorrect values."
		} 

	else {
		di as error "Correct."
		}

drop fips_test fips_test_n fips_incorrect
}

***********************************************************
** SchYear 

** • Are all years presented in the same format (e.g., 2020-21)?
{
levelsof SchYear, local(SchYear)

foreach year of local SchYear {
	if strpos("`year'", "-") != 5 {
		di as error "Check SchYear: `year' is in the wrong format."
		}
	if strlen("`year'") != 7 {
		di as error "Check SchYear: `year' is in the wrong format"
		}
	if strpos("`year'", "-") == 5 & strlen("`year'") == 7 {
		di as error "SchYear: `year' is in the correct format."
		}
	}
}
***********************************************************
** SchYear 

** • Is only one school year included per file?
{
bysort FILE (SchYear) : gen flag1 = SchYear[1] != SchYear[_N]  

local schyr_flag "flag1"

foreach var of local schyr_flag {
    count if flag1 == 1 
	if r(N) !=0 {
		di as error "There are multiple school years included per single school year file. Please review."
		tab SchYear FILE if flag1 == 1 
	}	
	else {
		di as error "Correct."
		}
	}

drop flag1 
} 

***********************************************************
** DataLevel

** • Are the only DataLevel values either State, District, or School?
{
count if !inlist(DataLevel, "State", "District", "School")

 if r(N)>0 {
 	di as error "DataLevel has unexpected values."
 	tab DataLevel FILE if !inlist(DataLevel, "State", "District", "School")
 }
 
 else {
		di as error "Correct."
		}
 }

 
***********************************************************
** DataLevel

** • Have DataLevel values across years been reviewed for changes of + or - 20%?

{
* Count observations by FILE (year) and DataLevel
bysort FILE DataLevel: gen obs_count = _N

* Keep only one observation per FILE-DataLevel group
	preserve
	bysort FILE DataLevel (obs_count): keep if _n == 1
	keep FILE State DataLevel obs_count

	* Sort by year
	sort DataLevel FILE

	* Generate previous year's count
	bysort DataLevel (FILE): gen prev_count = obs_count[_n-1]

	* Calculate percentage change from previous year
	gen change = obs_count - prev_count
	gen pct_change = (change / prev_count) * 100 if prev_count != 0

	* Identify large fluctuations (e.g., more than ±20% change)
	gen big_drop = (pct_change < -20) if !missing(pct_change)
	gen big_jump = (pct_change > 20) if !missing(pct_change)

	* Display results
	list FILE DataLevel obs_count prev_count change pct_change if big_drop | big_jump, sepby(DataLevel)
	

	{
	count if big_drop == 1 | big_jump == 1

	 if r(N)>0 {
		di as error "DataLevel has large changes in the following files. Please review."
		tab DataLevel FILE if big_drop == 1
		tab DataLevel FILE if big_jump == 1
			
	 }
	 
	 else {
			di as error "Correct."
			}
	 }
	restore 
tab FILE DataLevel 

* Clean up
drop obs_count 
}


** • Have DataLevel values across years been reviewed as a whole? Have missing years for specific DataLevels been noted in the CW?
{
tab FILE DataLevel 
di as error "Review DataLevel across all years"
}


** • Have DataLevel values across SUBGROUPS been reviewed? 

tab FILE StudentSubGroup 

// All Students 
tab FILE StudentSubGroup if StudentGroup =="All Students"

// RaceEth
tab FILE StudentSubGroup if StudentGroup =="RaceEth"

// EL Status
{
	gen ELStatus = StudentSubGroup
	replace ELStatus = "" if StudentGroup != "EL Status"
	replace ELStatus = "Prof" if ELStatus == "English Proficient"
	replace ELStatus = "EL" if ELStatus == "English Learner"
	
tab FILE ELStatus 
}

// Economic Status
tab FILE StudentSubGroup if StudentGroup =="Economic Status"

// Gender
tab FILE StudentSubGroup if StudentGroup =="Gender"

// Disability Status
tab FILE StudentSubGroup if StudentGroup =="Disability Status"

// Migrant Status
tab FILE StudentSubGroup if StudentGroup =="Migrant Status"

// Homeless Enrolled Status
tab FILE StudentSubGroup if StudentGroup =="Homeless Enrolled Status"

// Foster Care Status
tab FILE StudentSubGroup if StudentGroup =="Foster Care Status"

// Military Connected Status
tab FILE StudentSubGroup if StudentGroup =="Military Connected Status"

// Var cleanup
{
drop ELStatus
}
***********************************************************
***********************************************************
** C. DISTRICT/SCHOOL - NAMES & TYPES 
***********************************************************
***********************************************************
** DistName 

** • Are all values expected based on the DataLevel?
**   -  All levels: are all rows free from any blanks?
**   -  Where DataLeve=State: are all values ""All Districts""?"
   
{
local errorAllLevels 0
local errorStateLev 0
local nomissing "DistName"

foreach var of local nomissing {
	
	//All levels
	count if missing(`var')
	if r(N) !=0 {
		di as error "Check 1: `var' has missing values in the files below."
		tab FILE DataLevel if DistName ==""
		errorAllLevels 1
	}

	//State
	count if DistName != "All Districts" & DataLevel=="State"
	if r(N)>0 {
		di as error "Check 2: The following years need DistName='All Districts'"
		tab FILE if DistName != "All Districts" & DataLevel=="State"
		errorStateLev 1
	}
}

// Summary
if `errorAllLevels' == 0 & `errorStateLev' == 0 {
	di as error "Correct."
	}

}	


***********************************************************  
** DistName 

** • Have extraneous spaces been removed from the district names?

{
local errorLTBlanks 0  // Track leading/trailing blanks
local errorIBlanks 0  // Track internal blanks

gen dname_spaces1 = strtrim(DistName) // returns var with leading and trailing blanks removed.

count if DistName != dname_spaces1
	local n = r(N)
	if `n' > 0 {
		di as error "DistName needs leading or trailing blanks removed."
		tab FILE if DistName != dname_spaces1
		tab DistName if DistName != dname_spaces1
		local errorLTBlanks 1
	}

gen dname_spaces2 = stritrim(DistName) // returns var with all consecutive, internal blanks collapsed to one blank.

count if DistName != dname_spaces2
	local n = r(N)
	if `n' > 0 {
		di as error "DistName needs internal, consecutive blanks collapsed to one blank."
		tab SchYear if DistName != dname_spaces2
		tab DistName if DistName != dname_spaces2
		local errorIBlanks 1
	}
	
// Summary
if `errorLTBlanks' == 0 & `errorIBlanks' == 0 {
	di as error "Correct."
	}
		
drop dname_spaces1 dname_spaces2

}
***********************************************************
** DistName 

** • Has the full set of DistName values been reviewed for inconsistencies?
{	
tab DistName FILE 
di as error "Scan full list of districts / school years to note any concerns/changes/name updates that may be applicable."
}


***********************************************************
** DistType  
	
** • For all cases where DataLevel=District and DataLevel=School, are all rows free from any blanks?
** • For all cases where DataLevel= is State, are all rows blank?

{
local errorDistSch 0  // Track dist and sch levels 
local errorState 0  // Track state levels 
local distsch_nomiss "DistType"

foreach var of local distsch_nomiss {
	
	//Dist and Sch Level 
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var' in District and School level data."
		tab  DistName FILE if DistType=="" & DataLevel !="State"
		local errorDistSch 1
	}	

	//State level
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data."
		tab  SchYear FILE if DistType!="" & DataLevel =="State"
		local errorState 1
	}	
	
// Summary
if `errorDistSch' == 0 & `errorState' == 0 {
	di as error "Correct."
	}
}
}
***********************************************************
** DistType 

** • Are value labels below appropriate/as expected from the labeling conventions? If not, please indicate which need to be fixed.
** • Is the file limited to only the above groups? If not, please indicate what needs to be dropped.
{
gen distype_chk = .
replace distype_chk = 1 if inlist(DistType, ///
    "Regular local school district", "Component district", ///
    "Local school district that is a component of a supervisory union", ///
    "Supervisory union", "Regional education service agency", ///
    "State-operated agency", "Federal-operated agency", ///
    "Charter agency", "Specialized public school district")  
replace distype_chk = 1 if DistType == "Other education agency" 

count if DataLevel != "State" & distype_chk != 1
	local n = r(N)
	if `n' > 0 {
		di as error "DistType values DO NOT align with labeling conventions in the following files."
		tab FILE if DataLevel != "State" & distype_chk != 1
	}
	
	else {
		di as error "Correct."
		}

drop distype_chk
}

***********************************************************
** DistType 

** • Have DistType values across years been reviewed to ensure that irregularities have already been flagged?
{	
tab FILE DistType 
}
***********************************************************

** SchName   

** • Are all values expected based on the DataLevel?
**   -  All levels: are all rows free from any blanks?
**   -  Where DataLevel!= School: are all values "All Schools"?

{
local errorAllLev 0 
local errorStateDist 0  
local nomissing_sch "SchName"

foreach var of local nomissing_sch {
	
	//All data levels 
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
		tab FILE if SchName ==""
		local errorAllLev 1 
		}
	}
	
	//State and Dist
	count if SchName != "All Schools" & DataLevel!="School"
	if r(N)>0 {
		di as error "The following files need SchName='All Schools' for the DataLevels listed."
		tab FILE DataLevel if SchName=="" 
		local errorStateDist 1  
	}
	
// Summary
if `errorAllLev' == 0 & `errorStateDist' == 0 {
	di as error "Correct."
	}

}
	
***********************************************************  
** SchName 

** • Have extraneous spaces been removed from school names?
{
local errorLTBlanks 0  // Track leading/trailing blanks
local errorIBlanks 0  // Track internal blanks

gen sname_spaces1 = strtrim(SchName) // returns var with leading and trailing blanks removed.

count if SchName != sname_spaces1
	local n = r(N)
	if `n' > 0 {
		di as error "SchName needs leading or trailing blanks removed from the following files."
		tab SchName FILE if SchName != sname_spaces1
		local errorLTBlanks 1
	}

gen sname_spaces2 = stritrim(SchName) // returns var with all consecutive, internal blanks collapsed to one blank.

count if SchName != sname_spaces2
	local n = r(N)
	if `n' > 0 {
		di as error "SchName needs internal, consecutive blanks collapsed to one blank in the following files."
		tab SchName FILE if SchName != sname_spaces2
		local errorIBlanks 1 
	}
	
// Summary
if `errorLTBlanks' == 0 & `errorIBlanks' == 0 {
	di as error "Correct."
	}
	
drop sname_spaces1 sname_spaces2
}	

*********************************************************** 	
** SchType   

** • Are all values expected based on the DataLevel?
**   -  Where DataLevel= School: are all rows free from any blanks?
**   -  Where DataLevel!= School: are all rows blank?

{
local errorSch 0  
local errorNonSch 0  
local sch_miss "SchType "

foreach var of local sch_miss {
	
	// School level
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files."
		tab SchName FILE  if SchType =="" & DataLevel=="School"
		local errorSch 1
	}

	//State and dist level
	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state or district level data in the following files."
		tab  SchName FILE  if SchType!="" & DataLevel !="School"
		local errorNonSch 1
	}
}
	
// Summary
if `errorSch' == 0 & `errorNonSch' == 0 {
	di as error "Correct."
	}
	
}

***********************************************************
** SchType 

** • Are value labels below appropriate/as expected from the labeling conventions? If not, please indicate which need to be fixed. // updated 1/13/25
{
gen schtype_chk = inlist(SchType, ///
    "Regular school", "Special education school", "Vocational school", ///
    "Other/alternative school", "Reportable program", "High")

	count if DataLevel == "School" & schtype_chk != 1
	local n = r(N)
	if `n' > 0 {
		di as error "SchType values DO NOT align with labeling conventions in the following files."
		tab SchType FILE if DataLevel == "School" & schtype_chk != 1
	} 
	
	else {
		di as error "Correct."
	}

drop schtype_chk
}
***********************************************************
** SchType 

** • Have SchType values across years been reviewed to ensure that irregularities have already been flagged?
{	
tab FILE SchType 
}

***********************************************************
***********************************************************
** D. DISTRICT/SCHOOL IDS 
***********************************************************
***********************************************************

*NCESDistrictID 

** • Are all values expected based on the DataLevel?
**   -  Where DataLevel= District or School: are all rows free from any blanks?
**   -  Where DataLevel= State: are all rows blank?

{
local errorNonState 0  
local errorState 0  
local distsch_nomiss "NCESDistrictID"

foreach var of local distsch_nomiss {
	
	//Dist and Sch Level
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var' in District and School level data."
		tab DistName FILE  if NCESDistrictID ==. & DataLevel != "State"
		local errorNonState 1  
	}	

	//State level
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data in the following files."
		tab  NCESDistrictID FILE if NCESDistrictID!=. & DataLevel =="State"
		local errorState 1  
	}	
}	
// Summary
if `errorNonState' == 0 & `errorState' == 0 {
	di as error "Correct."
	}
}


***********************************************************
*NCESDistrictID 


** • Are all IDs in the correct format(6 digits when StateFips <10 due to leading 0, otherwise 7 digits)?
{
gen nces_distid_length=length(string(NCESDistrictID))
*tab nces_distid_length StateFips
*sort nces_distid_length

local errorTooShort 0  
local errorTooLong 0  
local nces_d_check "nces_distid_length"

foreach var of local nces_d_check {
	
	count if (`var') < 6 & StateFips < 10 & DataLevel !="State"
	if r(N) !=0 {
		di as error "NCESDistrictID has values that are too short in the following files."
		tab NCESDistrictID FILE if nces_distid_length < 6 & StateFips < 10 & DataLevel !="State"
		local errorTooShort 1  
	}	

	count if (`var') < 7 & StateFips > 10 & DataLevel !="State"
	if r(N) !=0 {
		di as error "NCESDistrictID has values that are too short in the following files."
		tab NCESDistrictID FILE if nces_distid_length < 7 & StateFips > 10 & DataLevel !="State"
		local errorTooShort 1  
	}	

	count if (`var') > 6 & StateFips < 10 & DataLevel !="State"
	if r(N) !=0 {
		di as error "NCESDistrictID has values that are too long in the following files."
		tab NCESDistrictID FILE if nces_distid_length > 6 & StateFips < 10 & DataLevel !="State"
		local errorTooLong 1  
	}	
	
	count if (`var') > 7 & StateFips > 10 & DataLevel !="State"
	if r(N) !=0 {
		di as error "NCESDistrictID has values that are too long in the following files."
		tab NCESDistrictID FILE if nces_distid_length > 7 & StateFips > 10 & DataLevel !="State"
		local errorTooLong 1  
	}	
	
// Summary
if `errorTooShort' == 0 & `errorTooLong' == 0 {
	di as error "Correct."
	}
}

drop nces_distid_length
}
***********************************************************
*NCESDistrictID 

** • Data cleaner only: Did 2024 have new districts without NCES District IDs that needed to be reviewed?
** • Data cleaner AND reviewer: If YES, were the districts exported to the state's folder on the Google drive for review and updated to the extent possible? [insert link to Google sheet in the row below for easy access for data reviewer]. If not, please explain in the comments

di as error "IDs for 2024 should be exported to a Google doc on the drive and reviewed/ completed to the greatest extent possible."

***********************************************************
*StateAssignedDistID

** • Are all values expected based on the DataLevel?
**   -  Where DataLevel= District or School: are all rows free from any blanks?
**   -  Where DataLevel= State: are all rows blank?

{
local errorNonState 0  
local errorState 0  
local distsch_nomiss "StateAssignedDistID"

foreach var of local distsch_nomiss {
	
	//Dist and Sch 
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values."
		tab FILE DataLevel if DataLevel !="State" & StateAssignedDistID=="" 
		local errorNonState 1  
		}	
		
	//State
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data for the following files."
		tab StateAssignedDistID FILE if !missing(`var') & DataLevel == "State"
		local errorState 1  
		}	
		
// Summary
if `errorNonState' == 0 & `errorState' == 0 {
	di as error "Correct."
	}
}
}

***********************************************************

*StateAssignedDistID 

** • Is there only 1 state district IDs per unique NCES District ID?
{
bysort NCESDistrictID (StateAssignedDistID) : gen d_MultipleStateIDsPer_NCESid = StateAssignedDistID[1] != StateAssignedDistID[_N]  
bysort StateAssignedDistID (NCESDistrictID) : gen d_MultipleNCESIDsPer_StateID = NCESDistrictID[1] != NCESDistrictID[_N]

local distid_flag1 "d_MultipleStateIDsPer_NCESid"

foreach var of local distid_flag1 {
	
	count if `var'==1
    
	if r(N) !=0 {
		di as error "The observations below have multiple StateAssignedDistIDs per NCESDistrictID. Upload mis-matched IDs to the Google drive and review."
		cap tab NCESDistrictID StateAssignedDistID if d_MultipleStateIDsPer_NCESid==1
			}
	{
	preserve	
	format NCESDistrictID %18.0g
	keep if d_MultipleStateIDsPer_NCESid==1 | d_MultipleNCESIDsPer_StateID==1 
	keep FILE State SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID d_MultipleStateIDsPer_NCESid  d_MultipleNCESIDsPer_StateID
	sort NCESDistrictID SchYear 
	cap duplicates drop 
	cap export excel using "${Review}/${StateAbbrev}_mismatched dist IDs_${date}.xlsx", firstrow(variables) replace
	restore
	}

	else {
		di as error "Correct."
		}
	}
}

***********************************************************
*StateAssignedDistID

** • Is there only 1 NCES District IDs per unique state district ID?
** • Have mis-matched IDs all be exported to a Google doc on the drive?
{
local distid_flag2 "d_MultipleNCESIDsPer_StateID"
foreach var of local distid_flag2 {
	
	count if `var'==1
    
	if r(N) !=0 {
		di as error "The observations below have multiple NCESDistrictIDs per StateAssignedDistID. Upload mis-matched IDs to the Google drive and review."
		cap tab NCESDistrictID StateAssignedDistID if d_MultipleNCESIDsPer_StateID==1
	}	
	
	{
	preserve	
	format NCESDistrictID %18.0g
	keep if d_MultipleStateIDsPer_NCESid==1 | d_MultipleNCESIDsPer_StateID==1 
	keep FILE State SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID d_MultipleStateIDsPer_NCESid  d_MultipleNCESIDsPer_StateID
	sort NCESDistrictID SchYear 
	cap duplicates drop 
	cap export excel using "${Review}/${StateAbbrev}_mismatched dist IDs_${date}.xlsx", firstrow(variables) replace
	restore
	}
	
	else {
		di as error "Correct."
		}
	}
}

***********************************************************
*StateAssignedDistID

** • Do IDs align with the original data for 2024? (COMPARE 5 data points in review code and original data)
{
set seed 3210
	bysort StateAssignedDistID (FILE) : gen random = runiform() if _n == 1
	by StateAssignedDistID: replace random = random[1]
	egen select = group(random StateAssignedDistID)

	tab DistName StateAssignedDistID if (select == 1 | select == 2 | select == 3 | select == 4 | select == 5) & FILE == "2024"
	drop random
}
***********************************************************
*StateAssignedDistID

** • Do IDs align with the original data for 2023? (COMPARE 5 data points in review code and original data)

tab DistName StateAssignedDistID if (select == 1 | select == 2 | select == 3 | select == 4 | select == 5) & FILE == "2023"

***********************************************************
*StateAssignedDistID

** • Do IDs align with the original data for 2022? (COMPARE 5 data points in review code and original data)

tab DistName StateAssignedDistID if (select == 1 | select == 2 | select == 3 | select == 4 | select == 5) & FILE == "2022"

***********************************************************
*StateAssignedDistID

** • Do IDs align with the original data for 2021? (COMPARE 5 data points in review code and original data)

tab DistName StateAssignedDistID if (select == 1 | select == 2 | select == 3 | select == 4 | select == 5) & FILE == "2021"

***********************************************************
*StateAssignedDistID

** • Do IDs align with the original data for 2019? (COMPARE 5 data points in review code and original data)
{
tab DistName StateAssignedDistID if (select == 1 | select == 2 | select == 3 | select == 4 | select == 5) & FILE == "2019"

drop select

}
***********************************************************
*NCESSchoolID 

** • Are all values expected based on the DataLevel?
**   -  Where DataLevel= School: are all rows free from any blanks?
**   -  Where DataLevel!= School: are all rows blank?

{
local errorSch 0  
local errorNonSch 0  
local schid_nomiss "NCESSchoolID"

foreach var of local schid_nomiss {
	
	//Sch
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing school-level values in the following files. There should be NO MISSING VALUES for `var' in school-level data."
		tab FILE DataLevel if missing(`var') & DataLevel == "School" 
		local errorSch 1
		}

	//State and Dist	
	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state-level data in the following files."
		tab NCESSchoolID FILE if !missing(`var') & DataLevel != "School"
		local errorNonSch 1  
		}
}
// Summary
if `errorSch' == 0 & `errorNonSch' == 0 {
	di as error "Correct."
	}
}


***********************************************************
*NCESSchoolID 

** • Are all IDs in the correct format?
{
	{
	format NCESSchoolID %18.0g	
	tostring NCESSchoolID, generate(nces_sch) format(%18.0f)
	order FILE State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID nces_sch

	gen nces_sch_length=length(nces_sch)

order FILE State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID nces_sch nces_sch_length
}

{
local errorTooShort 0  
local errorTooLong 0  
local nces_schlength_check "nces_sch_length"

foreach var of local nces_schlength_check {
	
	count if (nces_sch_length < 11) & (StateFips < 10) & (DataLevel=="School")
	if r(N) !=0 {
		di as error "NCESSchoolID has values that are too short in the following files."
		tab NCESSchoolID FILE if (nces_sch_length < 11) & (StateFips < 10) & (DataLevel=="School")
		local errorTooShort 1
	}	

	count if (nces_sch_length < 12) & (StateFips > 10) & (DataLevel=="School")
	if r(N) !=0 {
		di as error "NCESSchoolID has values that are too short in the following files."
		tab NCESSchoolID FILE if (nces_sch_length < 12)  & (StateFips > 10) & (DataLevel=="School")
		local errorTooShort 1
	}	

	count if (nces_sch_length > 11) & (StateFips < 10) & (DataLevel=="School")
	if r(N) !=0 {
		di as error "NCESSchoolID has values that are too long in the following files."
		tab NCESSchoolID FILE if (nces_sch_length > 11)  & (StateFips < 10) & (DataLevel=="School")
		local errorTooLong 1
	}	
	
	count if (nces_sch_length > 12) & (StateFips > 10) & (DataLevel=="School")
	if r(N) !=0 {
		di as error "NCESSchoolID has values that are too long in the following files."
		tab NCESSchoolID FILE if (nces_sch_length > 12)  & (StateFips > 10) & (DataLevel=="School")
		local errorTooLong 1
	}	
	
// Summary
if `errorTooShort' == 0 & `errorTooLong' == 0 {
	di as error "Correct."
	}


drop nces_sch_length
		}
	}
}
***********************************************************
*NCESSchoolID 

** • Does the NCESDistrictID match the first 7 digits of the NCESSchoolID? // updated 9/27/24
{
gen tempD= NCESDistrictID
gen tempS=floor(NCESSchoolID/100000)
format NCESSchoolID %18.0g	

count if tempS != tempD & DataLevel=="School"
	if r(N) !=0 {
		di as error "First digits of NCESSchoolID for the below schools don't match NCESDistrictID."
		tab NCESSchoolID FILE if tempS != tempD & DataLevel=="School"
		
	{
	preserve
	format NCESSchoolID %18.0g	
	keep if tempS != tempD & DataLevel=="School"
	keep FILE State SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID   
	sort NCESDistrictID NCESSchoolID FILE 
	cap duplicates drop 
	cap export excel using "${Review}/${StateAbbrev}_nces IDs dont align_${date}.xlsx", firstrow(variables) replace
	restore
	}
}
	else {
		di as error "Correct."
		}

drop temp*		
}		
***********************************************************
*NCESSchoolID 

** • Have new values been discussed/addressed?
{
format NCESSchoolID %18.0g	
di as error "Use project guidelines to ensure that new schools and IDs have been identified and reviewed"
}
***********************************************************
*StateAssignedSchID 

** • Are all values expected based on the DataLevel?
**   -  Where DataLevel= School: are all rows free from any blanks?
**   -  Where DataLevel!= School: are all rows blank?
{
local errorSch 0
local errorNonSch 0
local stschid_nomiss "StateAssignedSchID"

foreach var of local stschid_nomiss {
	
	//Sch
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var' in school-level data."
		tab FILE if StateAssignedSchID=="" & DataLevel=="School"
		local errorSch 1
		}

	//State and Dist
	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state or district level data."
		tab StateAssignedSchID FILE if StateAssignedSchID != "" & DataLevel != "School"
		tab FILE DataLevel if StateAssignedSchID != "" & DataLevel != "School"
		local errorNonSch 1
		}
}
// Summary
if `errorSch' == 0 & `errorNonSch' == 0 {
	di as error "Correct."
	}
}


***********************************************************
*StateAssignedSchID 

** • Is there only 1 state school ID per unique NCES school ID?

{
bysort NCESSchoolID (StateAssignedSchID) : gen s_MultipleStateSchIDsPer_NCESid = StateAssignedSchID[1] != StateAssignedSchID[_N]  

bysort StateAssignedSchID (NCESSchoolID) : gen s_MultipleNCESIDsPer_StateSchID = NCESSchoolID[1] != NCESSchoolID[_N]

local schid_flag1 "s_MultipleStateSchIDsPer_NCESid"
foreach var of local schid_flag1 {
    
	if r(N) !=0 {
		di as error "There are observations with multiple state school IDs per unique NCES school ID. See output in review folder."
		cap tab NCESSchoolID StateAssignedSchID if s_MultipleStateSchIDsPer_NCESid==1
		}	

		{
		preserve
		format NCESSchoolID %18.0g	
		keep if s_MultipleStateSchIDsPer_NCESid==1 | s_MultipleNCESIDsPer_StateSchID==1 
		keep FILE State SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID s_MultipleStateSchIDsPer_NCESid  s_MultipleNCESIDsPer_StateSchID
		sort NCESDistrictID NCESSchoolID FILE 
		cap duplicates drop 
		cap export excel using "${Review}/${StateAbbrev}_mismatched sch ids_${date}.xlsx", firstrow(variables)
		restore
		}

	else {
		di as error "Correct."
		}
	}
}
***********************************************************
*StateAssignedSchID

** • Is there only 1 NCES school ID per unique state school ID?

{
local schid_flag2 "s_MultipleNCESIDsPer_StateSchID"
foreach var of local schid_flag2 {
    
	if r(N) !=0 {
		di as error "There are multiple NCES school IDs per unique state school ID. See output in review folder."
		cap tab NCESSchoolID StateAssignedSchID if s_MultipleNCESIDsPer_StateSchID==1
		}	
	
		{
		preserve
		format NCESSchoolID %18.0g	
		keep if s_MultipleStateSchIDsPer_NCESid==1 | s_MultipleNCESIDsPer_StateSchID==1 
		keep FILE State SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID s_MultipleStateSchIDsPer_NCESid  s_MultipleNCESIDsPer_StateSchID
		sort NCESDistrictID NCESSchoolID FILE 
		cap duplicates drop 
		cap export excel using "${Review}/${StateAbbrev}_mismatched sch ids_${date}.xlsx", firstrow(variables) replace
		restore
		}
	
	else {
		di as error "Correct."
		}
	}
}

***********************************************************
*StateAssignedSchID

** • Do IDs align with the original data for 2024? (COMPARE each data point in review code and original data)
{
set seed 98765
	bysort StateAssignedSchID (FILE) : gen random = runiform() if _n == 1
	by StateAssignedSchID: replace random = random[1]
	egen sch_select = group(random StateAssignedSchID)

	tab SchName StateAssignedSchID if (sch_select == 1 | sch_select == 2 | sch_select == 3) & FILE == "2024"
	di as error "Compare StateAssignedSchID with values in original data. Flag any discrepancies. If our data combines district and school IDs to create unique school IDs, verify that this has been noted in the CW."

drop random 
}
***********************************************************
*StateAssignedSchID

** • Do IDs align with the original data for 2023? (COMPARE each data point in review code and original data)

tab SchName StateAssignedSchID if (sch_select == 1 | sch_select == 2 | sch_select == 3) & FILE == "2023"

***********************************************************
*StateAssignedSchID

** • Do IDs align with the original data for 2022? (COMPARE each data point in review code and original data)

tab SchName StateAssignedSchID if (sch_select == 1 | sch_select == 2 | sch_select == 3) & FILE == "2022"

***********************************************************
*StateAssignedSchID

** • Do IDs align with the original data for 2021? (COMPARE each data point in review code and original data)

tab SchName StateAssignedSchID if (sch_select == 1 | sch_select == 2 | sch_select == 3) & FILE == "2021"

***********************************************************
*StateAssignedSchID

** • Do IDs align with the original data for 2019? (COMPARE each data point in review code and original data)

tab SchName StateAssignedSchID if (sch_select == 1 | sch_select == 2 | sch_select == 3) & FILE == "2019"

***********************************************************
*StateAssignedSchID

** • Are IDs consistent across years (e.g., we don't want hyphens in the IDs for half the years and no hyphens for the other half)
{
set seed 98765
	bysort NCESSchoolID (FILE) : gen sch_random = runiform() if _n == 1
	by NCESSchoolID: replace sch_random = sch_random[1]
	egen sch_nces = group(sch_random NCESSchoolID)

	tab FILE StateAssignedSchID if (sch_nces == 1 )
		tab SFILE StateAssignedSchID if (sch_nces == 2 )
	di as error "Compare StateAssignedSchIDs over time."

drop sch_random sch_nces
}

***********************************************************
***********************************************************
** E. NCES CHARACTERISTICS
***********************************************************
***********************************************************

*DistCharter 

** • Are all values expected based on the DataLevel?
{
local errorNonState 0  
local errorState 0  
local dist_ch "DistCharter"

foreach var of local dist_ch {
	
	//Dist and Sch 
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files."
		tab FILE if DistCharter=="" & DataLevel!="State"
		local errorNonState 1  
	}
	//State
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state-level data in the following files."
		tab DistCharter FILE if !missing(`var') & DataLevel == "State"
		local errorState 1  
	}
}
// Summary
if `errorNonState' == 0 & `errorState' == 0 {
	di as error "Correct."
	}
}
***********************************************************
*DistCharter 

** • For all cases where DataLevel=District and DataLevel=School, are the only values either Yes or No?
{
count if !inlist(DistCharter, "Yes", "No") & DataLevel != "State"
 if r(N)>0 {
 	di as error "DistCharter has values other than Yes and No in district or school data."
 	tab DistCharter FILE if !inlist(DistCharter, "Yes", "No") & DataLevel != "State"
}

	else {
		di as error "Correct."
		}
}

***********************************************************

*DistCharter 

** • Have DistCharter values across all years been reviewed to ensure that irregularities have already been flagged?
tab FILE DistCharter 


***********************************************************
*DistLocale 

** • Are all values expected based on the DataLevel?
{
local errorNonState 0  
local errorState 0  
local distloc_nomiss "DistLocale"

foreach var of local distloc_nomiss {
	
	//Dist and Sch
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
		tab FILE if DistLocale=="" & DataLevel!="State"
		local errorNonState 1  
}

	//State
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state-level data in the following files."
		tab DistLocale FILE if DistLocale!="" & DataLevel=="State"
		local errorState 1 
	}	
}	
// Summary
if `errorNonState' == 0 & `errorState' == 0 {
	di as error "Correct."
	}
}

***********************************************************
*DistLocale 

** • For all cases where DataLevel=District and DataLevel=School, are the values appropriate? // updated 1/13/25
{
gen distlocale_flag = 1 if DataLevel != "State"

	replace distlocale_flag = . if DataLevel != "State" & ///
		(inlist(DistLocale, "City, large", "City, midsize", "City, small", "Suburb, large", "Suburb, midsize", "Suburb, small") | ///
		inlist(DistLocale, "Town, fringe", "Town, distant", "Town, remote", "Rural, fringe", "Rural, distant", "Rural, remote") | ///
		inlist(DistLocale, "Large city", "Midsize city", "Urban fringe of a large city", "Urban fringe of large city", "Urban fringe of a midsize city") | ///
		inlist(DistLocale, "Urban fringe of midsize city", "Large town", "Small town", "Rural, outside CBSA", "Rural, inside CBSA"))

	* Handle early NCES values (before 2006)
	if real(FILE) < 2006 {
		replace distlocale_flag = . if DataLevel != "State" & DistLocale == "Not applicable"
	}

	count if distlocale_flag == 1 & DataLevel != "State"
		local n = r(N)
		if `n' > 0 {
			di as error "DistLocale values DO NOT align with labeling conventions in the following files."
			tab DistLocale FILE if distlocale_flag == 1 & DataLevel != "State"
		} 
		
	else {
		di as error "Correct."
	}

drop distlocale_flag
}

***********************************************************
*DistLocale 

** • Have DistLocale values across all years been reviewed to ensure that irregularities have already been flagged?

tab DistLocale FILE 

***********************************************************
*SchLevel 

** • For all cases where DataLevel=School, are all rows free from any blanks?
{
local errorSch 0  
local errorNonSch 0  
local sch_nomiss "SchLevel"

foreach var of local sch_nomiss {
	
	//School
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files."
		tab FILE if SchLevel=="" & DataLevel=="School"
		local errorSch 1  
		
		preserve
		format NCESSchoolID %18.0g	
		keep if missing(`var') & DataLevel == "School"
		keep FILE State SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID  SchType SchLevel SchVirtual
		sort NCESDistrictID NCESSchoolID FILE 
		cap duplicates drop 
		cap export excel using "${Review}/${StateAbbrev}_schlevel blanks_${date}.xlsx", firstrow(variables)
		restore
	}	

	//State and Dist
	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state or district-level data in the following files."
		tab SchLevel FILE if SchLevel!="" & DataLevel!="School"
		local errorNonSch 1  
	}	
}	
// Summary
if `errorSch' == 0 & `errorNonSch' == 0 {
	di as error "Correct."
	}
}

***********************************************************
*SchLevel 

** • Are value labels appropriate/as expected from the labeling conventions? [e.g., there should be no numeric values, no prekindergarten values, etc.]
{
gen schlev_chk = 1 if DataLevel == "School"

	replace schlev_chk = . if DataLevel == "School" & ///
		inlist(SchLevel, "Primary", "Middle", "High", "Secondary", "Ungraded", "Other", "Not applicable", "Missing/not reported")

	count if schlev_chk == 1 & DataLevel == "School"
		local n = r(N)
		if `n' > 0 {
			di as error "SchLevel values DO NOT align with labeling conventions in the following files."
			tab SchName FILE if schlev_chk == 1 & DataLevel == "School"
	} 

	else {
		di as error "Correct."
	}

drop schlev_chk
}
	
***********************************************************
*SchLevel 

** • Are there still "Missing/not reported" values for 2024?

{
local schlev_missing "SchLevel "

foreach var of local schlev_missing {

	count if `var'=="Missing/not reported" & SchYear=="2023-24" & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has Missing/not reported values for 2024 in the following files."
		tab SchLevel FILE if `var'=="Missing/not reported" & SchYear=="2023-24" & DataLevel == "School"
	}

	{
	preserve
	keep FILE DistName SchName SchLevel SchVirtual
	duplicates drop
	list DistName SchName if SchLevel=="Missing/not reported" & FILE == "2024"
	restore
	}

	else {
		di as error "Correct."
		}
	}	
}

***********************************************************
*SchLevel 

** • Have SchLevel values across all years been reviewed to ensure that irregularities have already been flagged?

tab SchLevel FILE 

***********************************************************
*SchVirtual 

** • Are all values expected based on the DataLevel?
{
local errorSch 0  
local errorNonSch 0  
local sch_nomiss "SchVirtual"

foreach var of local sch_nomiss {
	
	//School
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
		tab FILE if SchVirtual=="" & DataLevel=="School"
		local errorSch 1  
		
		preserve
		format NCESSchoolID %18.0g	
		keep if missing(`var') & DataLevel == "School"
		keep FILE State SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID  SchType SchLevel SchVirtual
		sort NCESDistrictID NCESSchoolID FILE 
		cap duplicates drop 
		cap export excel using "${Review}/${StateAbbrev}_schvirtual blanks_${date}.xlsx", firstrow(variables)
		restore
	}

	//State and Dist 
	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state or district-level data in the following files."
		tab SchVirtual FILE if SchVirtual!="" & DataLevel!="School"
		local errorNonSch 1  
	}	
}	
// Summary
if `errorSch' == 0 & `errorNonSch' == 0 {
	di as error "Correct."
	}
}
***********************************************************

*SchVirtual 

** • For all cases where DataLevel=District and DataLevel=School, are the values appropriate?
{
gen schvir_chk = 1 if DataLevel == "School"

	replace schvir_chk = . if DataLevel == "School" & ///
		inlist(SchVirtual, "Yes", "No", "Virtual with face to face options", "Supplemental virtual", "Missing/not reported")

	count if schvir_chk == 1 & DataLevel == "School"
		local n = r(N)
		if `n' > 0 {
			di as error "SchVirtual values DO NOT align with labeling conventions in the following files."
			tab SchName FILE if schvir_chk == 1 & DataLevel == "School"
	} 

	else {
		di as error "Correct."
	}

drop schvir_chk
}
***********************************************************
*SchVirtual 

** • Are there still "Missing/not reported" values for 2024?
{
local schv_missing "SchVirtual "

foreach var of local schv_missing {

	count if `var'=="Missing/not reported" & SchYear=="2023-24" & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has Missing/not reported values for 2024 in the following files."
		tab SchVirtual FILE if `var'=="Missing/not reported" & SchYear=="2023-24" & DataLevel == "School"
	
		preserve
		keep FILE DistName SchName SchLevel SchVirtual
		duplicates drop
		list DistName SchName if SchVirtual=="Missing/not reported" & FILE == "2024"
		restore
	}

	else {
		di as error "Correct."
		}
	}	
}
***********************************************************
*SchVirtual 

** • Have SchVirtual values across all years been reviewed to ensure that irregularities have already been flagged?

tab SchVirtual FILE 

***********************************************************

* CountyName

** • Are all values expected based on the DataLevel?
{
local errorNonState 0  
local errorState 0  
local cty_nomiss "CountyName"

foreach var of local cty_nomiss {
	
	//Dist and Sch
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files."
		tab FILE if CountyName=="" & DataLevel != "State"
		local errorNonState 1  
	}

	//State
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data."
		tab CountyName FILE if CountyName!="" & DataLevel == "State"
		local errorState 1  
	}
}	
// Summary
if `errorNonState' == 0 & `errorState' == 0 {
	di as error "Correct."
	}
}


***********************************************************

* CountyName
** • Have county names through 2015 been changed to proper case?

tab CountyName FILE 

/* Code to update county names, if needed
replace CountyName = proper(CountyName) 
tab CountyName SchYear 
*/ 
***********************************************************
** • Are county names starting with Mc, or De been formatted correctly? (e.g., county name should be McDonald County, not Mcdonald County; name should be DeSoto County, not Desoto County)

{
di as error "Review county names below to check for incorrect capitalization, such as Mcdonald instead of McDonald. Other typical cases are De and Le"
tab CountyName FILE 
}

***********************************************************

* CountyName

** • Is the file free of obs that use "Missing/not reported"?

tab  DistName FILE if CountyName=="Missing/not reported"

***********************************************************

* CountyCode

** • Are all values expected based on the DataLevel?
{
local errorNonState 0  
local errorState 0  
local cty_nomiss "CountyCode"

	//Dist and Sch 
	count if missing(CountyCode) & DataLevel != "State"

		local n = r(N)
		if `n' > 0 {
			di as error "`cty_nomiss' has missing values in the following files."
			tab FILE if missing(CountyCode) & DataLevel != "State"
			local errorNonState 1  
			} 

	//State
	count if !missing(CountyCode) & DataLevel == "State"

	local n = r(N)
	if `n' > 0 {
		di as error "`cty_nomiss' has non-missing values in state level data."
		tab CountyCode FILE if !missing(CountyCode) & DataLevel == "State"
		local errorState 0  
	} 
	
// Summary
if `errorNonState' == 0 & `errorState' == 0 {
	di as error "Correct."
	}
}


***********************************************************
* CountyCode

** • Is the file free of obs that use "Missing/not reported"?
{
tab  DistName FILE if CountyCode=="Missing/not reported"
di as error "Review any CountyCode values that are missing/not reported." 
}
***********************************************************
* CountyCode

** • Is there just 1 CountyCode per CountyName? 
{ 
bysort CountyName (CountyCode) : gen cty_flag1 = CountyCode[1] != CountyCode[_N]  
bysort CountyCode (CountyName) : gen cty_flag2 = CountyName[1] != CountyName[_N] 
 
count if cty_flag1>0 | cty_flag2>0

	if r(N) !=0 {
		di as error "Counties below have mismatched CountyName and CountyCode"
		tab CountyName if cty_flag1>0 | cty_flag2>0
		tab CountyCode if cty_flag1>0 | cty_flag2>0
		
		preserve 
		keep State StateAbbrev StateFips SchYear DataLevel DistName  NCESDistrictID   CountyName CountyCode cty_flag1 cty_flag2
		keep if cty_flag1==1 | cty_flag2==1
		cap duplicates drop 
		cap export excel using "${Review}/${StateAbbrev}_county ids_${date}.xlsx", firstrow(variables) replace
		restore
	}

	else {
		di as error "Correct."
		}
		
drop cty_flag1 cty_flag2	
	}

***********************************************************
** CountyCode 

** • Have CountyCode values across all years been reviewed to ensure that irregularities have already been flagged?

tab CountyCode FILE 


***********************************************************
***********************************************************
** F. ASSESSMENT DETAILS 
***********************************************************
***********************************************************
*Subject 

** • Is "ela" the subject for all states except for AR and GA, which have both "ela" and "read"? (updated 1/9/25)

{
if "${StateAbbrev}" != "AR" & "${StateAbbrev}" != "GA" {
	count if inlist(Subject, "read", "reading")
	if r(N)>0 {
		di as error "Reading should be labelled as 'ela' in the data file. Only AR and GA should have 'read' as a subject."
		tab Subject FILE 
	}
}

if "${StateAbbrev}" == "AR" | "${StateAbbrev}" == "GA" {
	count if inlist(Subject, "reading")
	if r(N)>0 {
		di as error "Should not be 'reading'."
		tab Subject FILE 
	}
}

else {
	di as error "Correct."
	}

}

***********************************************************
*Subject 
	
** • Are subjects listed as ela, math, sci, eng, read, wri, stem, soc? (eg not "science" etc) (updated 1/26/25)
{
count if !inlist(Subject, "ela", "math", "sci", "eng", "wri", "stem", "soc", "read")
	if r(N)>0 {
		di as error "Subject values are not labelled appropriately."
		tab Subject FILE if !inlist(Subject, "ela", "math", "sci", "eng", "wri", "stem", "soc", "read")
	}
	
	else {
		di as error "Correct."
		}	
}

***********************************************************
*Subject 	
	
** • Have Subject values across all years been reviewed to ensure that irregularities have already been flagged?

tab Subject FILE 	

***********************************************************
*Subject 	
	
** • Do the available subjects align with the years that the CW indicates are available? (eg, if the CW says science starts in 2015 but the data only start in 2019, this should be flagged)

tab Subject FILE  if DataLevel=="State" 
tab Subject FILE  if DataLevel=="District" 
tab Subject FILE  if DataLevel=="School" 

***********************************************************
*GradeLevel 

** • Are grades listed as G03, G04 etc and not 3, 4?
{
count if !inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38", "GZ")

	if r(N)>0 {
		di as error "Grade level values below are not labelled appropriately."
		tab GradeLevel FILE if !inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38", "GZ")
		}
	
	else {
		di as error "Correct."
	}	
}

***********************************************************
*GradeLevel 

** • If G38 is included (aggregated data for Grades 3-8), has it been confirmed that this only includes Grades 3-8 and not high school grades?

tab FILE GradeLevel 
if GradeLevel== "G38" {
 	di as error "Please confirm that this data includes only data for Grades 3-8 and NOT any high school grades."
 }

***********************************************************
*StudentGroup 

** • Do all labels follow the standardized naming conventions? 

{
 count if !inlist(StudentGroup, "All Students", "RaceEth", "EL Status", "Gender", "Economic Status") & !inlist(StudentGroup, "Disability Status", "Migrant Status", "Homeless Enrolled Status", "Foster Care Status", "Military Connected Status")
 
 if r(N)>0 {
 	
 	di as error "StudentGroup values below are not labelled appropriately."
	tab StudentGroup FILE if !inlist(StudentGroup, "All Students", "RaceEth", "EL Status", "Gender", "Economic Status") & !inlist(StudentGroup, "Disability Status", "Migrant Status", "Homeless Enrolled Status", "Foster Care Status", "Military Connected Status")
 }
 
 else {
		di as error "Correct."
		}	
}

***********************************************************
*StudentGroup_TotalTested 

** • Is there an "All Students" value for each 'unique group' in the file? 
** • Has the "All Students" value been applied to all other student groups? 

{
//Setup
replace StateAssignedDistID = "000000" if DataLevel == "State"
replace StateAssignedSchID = "000000" if inlist(DataLevel, "State", "District")

egen uniquegrp = group(FILE DataLevel StateAssignedDistID StateAssignedSchID AssmtName AssmtType Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup 
by uniquegrp: gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by uniquegrp: replace AllStudents = AllStudents[_n-1] if missing(AllStudents)

order FILE State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested uniquegrp AllStudents

bysort uniquegrp: gen AllStudChk = cond(AllStudents == StudentGroup_TotalTested, "Correct", ///
    cond(AllStudents == "", "All Students Value Missing", "Not Aligned"))

	
//Check	
local AllStudChk "AllStudChk"
local errorMissing 0       // Track if "All Students Value Missing" occurs
local errorNotAligned 0    // Track if "Not Aligned" occurs

// Checking if All Students is missing for each unique group
count if `AllStudChk' == "All Students Value Missing"
if r(N) > 0 {
    local errorMissing 1
}

// Checking if the 2 All Students values are aligned 
count if `AllStudChk' == "Not Aligned"
if r(N) > 0 {
    local errorNotAligned 1
}

// Output for review if either error exists
if `errorMissing' | `errorNotAligned' {
    preserve
    keep if `AllStudChk' == "All Students Value Missing" | `AllStudChk' == "Not Aligned"
    keep FILE State SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested AllStudents AllStudChk uniquegrp
    cap duplicates drop 
    cap export excel using "${Review}/${StateAbbrev}_AllStudChk_${date}.xlsx", firstrow(variables) replace
    restore
}

// Summary
if `errorMissing' {
    di as error "All Students Value Missing. Review output in review folder."
    tab DataLevel FILE if `AllStudChk' == "All Students Value Missing"
}

if `errorNotAligned' {
    di as error "All Students Values Not Aligned. Review output in review folder."
    tab DataLevel FILE if `AllStudChk' == "Not Aligned"
}

if `errorMissing' == 0 & `errorNotAligned' == 0 {
    di as error "Correct."
}
		
drop uniquegrp	AllStudChk 		
}


***********************************************************

*StudentGroup_TotalTested 

** • Are all rows free from any blanks, commas, extra spaces, and inequalities?
{	
//Check	
local errorBlanks 0    // Track blanks
local errorCommas 0    // Track commas
local errorSpaces 0    // Track extra spaces
local errorInequalities 0 // Track inequalities
local sgtt "StudentGroup_TotalTested"

foreach var of local sgtt {
	
	//blanks 
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the following files."
		tab DataLevel FILE if missing(`var')
		local errorBlanks 1
	}

	//commas 
	count if strpos(`var', ",")
	if r(N) !=0 {
		di as error "`var' has values with commas in the files below."
		tab StudentGroup_TotalTested FILE if strpos(`var', ",")
		local errorCommas 1
	}

	//extra spaces 
	count if strpos(`var', " ")
	if r(N) !=0 {
		di as error "`var' has values with extra spaces in the files below."
		tab StudentGroup_TotalTested FILE if strpos(`var', " ")
		local errorSpaces 1
	}

	//inequalities
	count if strpos(`var', ">") | strpos(`var', "<") 
	if r(N) !=0 {
		di as error "`var' has values with inequalities in the files below."
		tab StudentGroup_TotalTested FILE if strpos(`var', ">") | strpos(`var', "<") 
		local errorInequalities 1
	}
	
	// Correct 
	if `errorBlanks' == 0 & `errorCommas' == 0 & `errorSpaces' == 0 & `errorInequalities' == 0 {
		di as error "Correct."
		}
	}
}
***********************************************************
*StudentGroup_TotalTested 

** • Are all rows free from negative numbers? // updated 1/13/25

{
local sgtt "StudentGroup_TotalTested"

count if real(`sgtt') < 0 & !missing(real(`sgtt'))
	if r(N) > 0 {
		di as error "`sgtt' has negative values in the files below."
		tab StudentSubGroup FILE if real(`sgtt') < 0
		} 
	
else {
    di as error "Correct."
	}
}

***********************************************************
*StudentGroup_TotalTested 

** • Are all values free of periods (.)?
{
local sgtt "StudentGroup_TotalTested" 

foreach var of local sgtt {
	
	count if strpos(`var', ".") 
	if r(N) !=0 {
		di as error "`var' has values with  periods in the files below."
		tab StudentGroup_TotalTested FILE if strpos(`var', ".") 
	}
	
 else {
		di as error "Correct."
		}	
	} 
}

***********************************************************
*StudentGroup_TotalTested

** • Have low StudentGroup_TotalTested values across all years been reviewed for irregularities? (updated 1/21/25)
{
gen sgtt_n = real(StudentGroup_TotalTested)
sort  FILE sgtt_n
by FILE: gen  sg_tt_low = _n //Number observations by year from lowest StudentGroup_TotalTested value to highest
	tab  FILE StudentGroup_TotalTested if sg_tt_low < 11  //Look at lowest 10 values for each file
	tab FILE StudentGroup_TotalTested if StudentGroup_TotalTested < "1"  // additional check
}

** • Have high StudentGroup_TotalTested values across all years been reviewed for irregularities? (updated 1/21/25)
{
gsort  FILE -sgtt_n
by FILE: gen  sg_tt_high = _n //Number observations by year from highest StudentGroup_TotalTested value to lowest
	tab  FILE StudentGroup_TotalTested if sg_tt_high <= 3 //Look at highest 3 values for each file

drop sgtt_n sg_tt_low sg_tt_high // drop vars no longer needed
}
***********************************************************
*StudentGroup_TotalTested 

** • Does the file include suppressed (*) or missing (--) data ?
{
local sgtt "StudentGroup_TotalTested"

foreach var of local sgtt {
	
	//Suppressed
	count if `var' =="*"
	if r(N) !=0 {
		di as error "Yes, `var' has suppressed values in the files below."
		tab  FILE `var' if `var' =="*"
		} 
		
		else {
		di as error "No, `var' does not have suppressed values."
		}
	
	//Missing
	count if `var' =="--" 
	if r(N) !=0 {
		di as error "`var' has missing values in the files below."
		tab  FILE `var' if `var' =="--"
		} 
		
	else {
		di as error "No, `var' does not have missing (--) values."
		}
	}
}

***********************************************************
*StudentGroup_TotalTested 

** • Does the file include ranges (-)?
{
count if strpos(StudentGroup_TotalTested, "-") & StudentGroup_TotalTested != "--" & StudentGroup_TotalTested > "0"
	if r(N) !=0 {
		di as error "StudentGroup_TotalTested has range values in the files below. Make sure to note in the CW and data review."
		tab StudentGroup_TotalTested FILE if strpos(StudentGroup_TotalTested, "-") & StudentGroup_TotalTested != "--" & StudentGroup_TotalTested > "0"
		gen sgtt_rng = 1 if strpos(StudentGroup_TotalTested, "-") & StudentGroup_TotalTested != "--" & StudentGroup_TotalTested > "0"
	}
	
		else {
		di as error "No, StudentGroup_TotalTested does not have ranges."
		}
 }

************************************************************************************************************
*StudentSubGroup

** • Are value labels below appropriate/as expected from the labeling conventions? If not, please indicate which need to be fixed.
** • If there are other values, please indicate what needs to be dropped.

	
* Checking subgroup values for StudentGroup == "All Students"
{
count if StudentGroup=="All Students" & !inlist(StudentSubGroup, "All Students")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should == 'All Students' if StudentGroup=='All Students'"
		tab StudentSubGroup FILE if StudentGroup=="All Students" & !inlist(StudentSubGroup, "All Students")
	}

		else {
		di as error "Correct."
		}
		
* Checking subgroup values for StudentGroup == "RaceEth"	
gen raceeth_chk = .
replace raceeth_chk = 1 if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander"| StudentSubGroup == "Two or More" | StudentSubGroup =="White"| StudentSubGroup == "Hispanic or Latino" | StudentSubGroup =="Unknown" | StudentSubGroup =="Not Hispanic or Latino" | StudentSubGroup =="Filipino"


count if StudentGroup=="RaceEth" & !inlist(raceeth_chk, 1)
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'American Indian or Alaska Native', 'Asian', 'Black or African American', 'Native Hawaiian or Pacific Islander', 'Two or More', 'White', 'Hispanic or Latino', 'Unknown' 'Not Hispanic', 'Filipino' if StudentGroup=='RaceEth'"
		tab StudentSubGroup FILE if StudentGroup=="RaceEth" & !inlist(raceeth_chk, 1)
	}

		else {
		di as error "Correct."
		}
drop raceeth_chk
 }
 
 
 
* Checking subgroup values for StudentGroup == "EL Status"
{
count if StudentGroup=="EL Status" & !inlist(StudentSubGroup, "English Learner", "English Proficient", "EL Exited", "EL Monit or Recently Ex", "EL and Monit or Recently Ex", "LTEL", "Ever EL")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'English Learner', 'English Proficient', 'EL Exited', 'EL Monit or Recently Ex', 'EL and Monit or Recently Ex', 'LTEL', 'Ever EL' if StudentGroup=='EL Status'"
		tab StudentSubGroup FILE if StudentGroup=="EL Status" & !inlist(StudentSubGroup, "English Learner", "English Proficient", "EL Exited", "EL Monit or Recently Ex", "EL and Monit or Recently Ex", "LTEL", "Ever EL")
	}

		else {
		di as error "Correct."
		}

* Checking subgroup values for StudentGroup == "Economic Status"
count if StudentGroup=="Economic Status" & !inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Economically Disadvantaged' or 'Not Economically Disadvantaged' if StudentGroup=='Economic Status'"
		tab StudentSubGroup FILE if StudentGroup=="Economic Status"
	}	
	
		else {
		di as error "Correct."
		}
 }
 
 
* Checking subgroup values for StudentGroup == "Gender"
{
count if StudentGroup=="Gender" & !inlist(StudentSubGroup, "Male", "Female", "Gender X", "Unknown") 
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Male', 'Female', 'Gender X' or 'Unknown' if StudentGroup=='Gender'"
		tab StudentSubGroup FILE if StudentGroup=="Gender" & !inlist(StudentSubGroup, "Male", "Female", "Gender X", "Unknown") 
	}
	
		else {
		di as error "Correct."
		}

* Checking subgroup values for StudentGroup == "Disability Status"
count if StudentGroup=="Disability Status" & !inlist(StudentSubGroup, "SWD", "Non-SWD")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'SWD' and 'Non-SWD' if StudentGroup=='Economic Status'"
		tab StudentSubGroup FILE if StudentGroup=="Disability Status" & !inlist(StudentSubGroup, "SWD", "Non-SWD")
	}
	
		else {
		di as error "Correct."
		}

* Checking subgroup values for StudentGroup == "Migrant Status"
count if StudentGroup=="Migrant Status" & !inlist(StudentSubGroup, "Migrant", "Non-Migrant")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Migrant' or 'Non-Migrant' if StudentGroup=='Migrant Status'"
		tab StudentSubGroup FILE if StudentGroup=="Migrant Status" & !inlist(StudentSubGroup, "Migrant", "Non-Migrant")
	}
	
		else {
		di as error "Correct."
		}
 }
 
 
* Checking subgroup values for StudentGroup == "Homeless Enrolled Status"
{
count if StudentGroup=="Homeless Enrolled Status" & !inlist(StudentSubGroup, "Homeless", "Non-Homeless")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Homeless' or 'Non-Homeless' if StudentGroup=='Homeless Status'"
		tab StudentSubGroup FILE if StudentGroup=="Homeless Status" & !inlist(StudentSubGroup, "Homeless", "Non-Homeless")
	}
	
		else {
		di as error "Correct."
		}

* Checking subgroup values for StudentGroup == "Foster Care Status"
count if StudentGroup=="Foster Care Status" & !inlist(StudentSubGroup, "Foster Care", "Non-Foster Care")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Foster Care' or 'Non-Foster Care' if StudentGroup=='Foster Care Status'"
		tab StudentSubGroup FILE if StudentGroup=="Foster Care Status" & !inlist(StudentSubGroup, "Foster Care", "Non-Foster Care")
	}
	
		else {
		di as error "Correct."
		}
	
* Checking subgroup values for StudentGroup == "Military Connected Status"	
count if StudentGroup=="Military Connected Status" & !inlist(StudentSubGroup, "Military", "Non-Military")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Military' or 'Non-Military' if StudentGroup=='Military Connected Status'"
		tab StudentSubGroup FILE if StudentGroup=="Military Connected Status"
	}
	
		else {
		di as error "Correct."
		}
 }

***********************************************************	
*StudentSubGroup_TotalTested

** • Does the "All Students" value for StudentSubGroup_TotalTested = the "All Students" value for StudentGroup_TotalTested? // updated 1/13/25

{
gen allstudents_flag = (StudentGroup == "All Students" & StudentSubGroup == "All Students")

count if allstudents_flag == 1 & (StudentGroup_TotalTested != StudentSubGroup_TotalTested)
	if r(N) > 0 {
		di as error "The two All Students values do not match in the following files."
		tab allstudents_flag FILE if allstudents_flag == 1 & StudentGroup_TotalTested != StudentSubGroup_TotalTested
	
		preserve
		format NCESDistrictID %18.0g
		keep if allstudents_flag==1 & (StudentGroup_TotalTested ~= StudentSubGroup_TotalTested)
		keep FILE State SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup_TotalTested allstudents_flag
		cap duplicates drop 
		cap export excel using "${Review}/${StateAbbrev}_all stud values do not match_${date}.xlsx", firstrow(variables) replace
		restore
		}
	
	else {
		di as error "Correct."
		}	
		
drop allstudents_flag
}

***********************************************************	
*StudentSubGroup_TotalTested
 
** • Has it been verified that the sum of student subgroup counts do not exceed the All Students count? (updated 1/21/25)
{
cap drop AllStudents
replace StateAssignedDistID = "000000" if DataLevel == "State"
replace StateAssignedSchID = "000000" if DataLevel == "State" | DataLevel == "District"

// Generate unique group identifiers for subgroups and all students
egen uniquegrp_sg = group(FILE DataLevel StateAssignedDistID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup)
egen uniquegrp = group(FILE DataLevel StateAssignedDistID StateAssignedSchID AssmtName AssmtType Subject GradeLevel)

// Sort and assign "All Students" total
sort uniquegrp StudentGroup StudentSubGroup
by uniquegrp: gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by uniquegrp: replace AllStudents = AllStudents[_n-1] if missing(AllStudents)

// Exclude specific subgroups from sum calculation
gen exclude = inlist(StudentSubGroup, "EL Exited", "EL Monit or Recently Ex", "EL and Monit or Recently Ex", "LTEL", "Ever EL")

// Flag when subgroup total exceeds All Students total
sort uniquegrp_sg
by uniquegrp_sg: gen sg_sum = real(StudentSubGroup_TotalTested) if exclude != 1
by uniquegrp_sg: replace sg_sum = sg_sum[_n-1] if missing(sg_sum) 

gen flag = 1 if (sg_sum > real(AllStudents) & sg_sum != .)

count if flag == 1
if r(N) > 0 {
    di as error "The sum of ssgtt has values greater than sgtt in the files below. Review file in review folder."
    tab FILE StudentGroup if flag == 1

    // Export flagged obs
    preserve
    keep if flag == 1 & StudentGroup == "RaceEth"
    cap export excel using "${Review}/${StateAbbrev}_ssgtt_sum_greater_than_sgtt_Race_${date}.xlsx", firstrow(variables) replace
    restore

    preserve
    keep if flag == 1 & StudentGroup != "RaceEth"
	keep FILE	State	DataLevel	DistName	SchName	NCESDistrictID		NCESSchoolID	AssmtName	AssmtType	Subject	GradeLevel	StudentGroup	StudentGroup_TotalTested	StudentSubGroup	StudentSubGroup_TotalTested	Lev1_count	Lev1_percent	Lev2_count	Lev2_percent	Lev3_count	Lev3_percent	Lev4_count	Lev4_percent	Lev5_count	Lev5_percent uniquegrp_sg	uniquegrp	AllStudents	exclude	sg_sum	flag
	sort FILE DistName SchName AssmtType Subject GradeLevel StudentGroup StudentSubGroup 
    cap export excel using "${Review}/${StateAbbrev}_ssgtt_sum_greater_than_sgtt_NotRace_${date}.xlsx", firstrow(variables) replace
    restore
	} 

	else {
		di as error "Correct."
		}

drop uniquegrp_sg uniquegrp flag exclude sg_sum
}

***********************************************************	
*StudentSubGroup_TotalTested
  
** • Are all rows free from any blanks, commas, extra spaces, and inequalities?
{	
//Check	
local errorBlanks 0    // Track blanks
local errorCommas 0    // Track commas
local errorSpaces 0    // Track extra spaces
local errorInequalities 0 // Track inequalities
local ssgtt "StudentSubGroup_TotalTested"

foreach var of local ssgtt {
	
	//blanks 
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the following files."
		tab DataLevel FILE if missing(`var')
		local errorBlanks 1
	}

	//commas 
	count if strpos(`var', ",")
	if r(N) !=0 {
		di as error "`var' has values with commas in the files below."
		tab StudentSubGroup_TotalTested FILE if strpos(`var', ",")
		local errorCommas 1
	}

	//extra spaces 
	count if strpos(`var', " ")
	if r(N) !=0 {
		di as error "`var' has values with extra spaces in the files below."
		tab StudentSubGroup_TotalTested FILE if strpos(`var', " ")
		local errorSpaces 1
	}

	//inequalities
	count if strpos(`var', ">") | strpos(`var', "<") 
	if r(N) !=0 {
		di as error "`var' has values with inequalities in the files below."
		tab StudentSubGroup_TotalTested FILE if strpos(`var', ">") | strpos(`var', "<") 
		local errorInequalities 1
	}
	
	// Correct 
	if `errorBlanks' == 0 & `errorCommas' == 0 & `errorSpaces' == 0 & `errorInequalities' == 0 {
		di as error "Correct."
		}
	}
}

***********************************************************
*StudentSubGroup_TotalTested 

** • Are all rows free from negative numbers?
{
local ssgtt "StudentSubGroup_TotalTested" 

foreach var of local ssgtt {
	count if real(StudentSubGroup_TotalTested) < 0 & !missing(real(StudentSubGroup_TotalTested))
	if r(N) !=0 {
		di as error "`var' has values with negative numbers in the files below."
		tab StudentSubGroup_TotalTested FILE if real(StudentSubGroup_TotalTested) < 0 & !missing(real(StudentSubGroup_TotalTested))
	}

	else {
		di as error "Correct."
		}	
	}
}

***********************************************************
*StudentSubGroup_TotalTested // updated 11/5/24 

** • Are all values free of periods (.)?
{
local ssgtt "StudentSubGroup_TotalTested" 

foreach var of local ssgtt {
	count if strpos(`var', ".") 
	if r(N) !=0 {
		di as error "`var' has values with periods in the files below."
		tab StudentSubGroup_TotalTested FILE if strpos(`var', ".") 
	 
		preserve
		format NCESSchoolID %18.0g
		keep if strpos(`var', ".") 
		keep FILE State SchYear DataLevel DistName SchName NCESDistrictID  NCESSchoolID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested 
		cap duplicates drop 
		cap export excel using "${Review}/${StateAbbrev}_check ssgtt values_${date}.xlsx", firstrow(variables) replace
		restore
		}
		
	else {
		di as error "Correct."
		}	
	}
}
***********************************************************
*StudentSubGroup_TotalTested 

** • California and Texas: Have obs been dropped if StudentSubGroup_TotalTested==0 ? (otherwise the files are too big)
{
if "${StateAbbrev}" == "CA" | "${StateAbbrev}" == "TX" {
	cap gen testedcount = real(StudentSubGroup_TotalTested)
	cap gen testedcount = StudentSubGroup_TotalTested
	count if testedcount == 0
	if r(N) !=0 di as error "Need to drop if StudentSubGroup_TotalTested == 0 in ${StateAbbrev}"
}
else {
	di as error "N/A (only applicable to TX and CA)"
}
cap drop testedcount dup
}

***********************************************************

** • Have low StudentSubGroup_TotalTested values across all years been reviewed for irregularities? (updated 1/21/25)
{
gen ssgtt_n = real(StudentSubGroup_TotalTested)
sort FILE ssgtt_n
by FILE: gen  ssg_tt_low = _n //Number observations by year from lowest StudentSubGroup_TotalTested value to highest
tab  FILE StudentSubGroup_TotalTested if ssg_tt_low < 11  //Look at lowest 10 values for each file
tab FILE StudentSubGroup_TotalTested if StudentSubGroup_TotalTested < "1"  // additional check
}


** • Have high StudentSubGroup_TotalTested values across all years been reviewed for irregularities? (updated 1/21/25)
{
gsort  FILE -ssgtt_n
by FILE: gen  ssg_tt_high = _n //Number observations by year from highest StudentSubGroup_TotalTested value to lowest
tab  FILE StudentSubGroup_TotalTested if ssg_tt_high < 11 //Look at highest 10 values for each file

drop ssgtt_n ssg_tt_low ssg_tt_high
}

***********************************************************
*StudentSubGroup_TotalTested 

** • Does the file include suppressed (*) or missing (--) data?

{
local ssgtt "StudentSubGroup_TotalTested" 

	foreach var of local ssgtt {
		
		//suppressed
		count if StudentSubGroup_TotalTested=="*" 
		if r(N) !=0 {
			di as error "Yes, `var' has suppressed values in the files below."
			tab FILE `var'  if StudentSubGroup_TotalTested=="*" 
			} 
		
		else {
			di as error "No, `var' does not have suppressed (*) values."
			}	
			
		//missing	
		count if StudentSubGroup_TotalTested=="--" 
		if r(N) !=0 {
			di as error "Yes, `var' has values represented as missing (--) in the files below."
			tab FILE `var' if StudentSubGroup_TotalTested=="--" 
			} 
		
		else {
			di as error "No, `var' does not have values represented as missing (--)."
			}	
		}
}

***********************************************************
*StudentSubGroup_TotalTested 


** • Does the file include ranges (-)?
{
count if strpos(StudentSubGroup_TotalTested, "-") & StudentSubGroup_TotalTested != "--" & StudentSubGroup_TotalTested > "0"
	if r(N) !=0 {
		gen ssg_tt_range = 1 if strpos(StudentSubGroup_TotalTested, "-") & StudentSubGroup_TotalTested != "--" & StudentSubGroup_TotalTested > "0" 
		di as error "StudentSubGroup_TotalTested has range values in the files below. Make sure to note in the CW and data review."
		tab StudentSubGroup_TotalTested FILE if strpos(StudentSubGroup_TotalTested, "-") & StudentSubGroup_TotalTested != "--" & StudentSubGroup_TotalTested > "0"
		gen ssgtt_rng = 1 if strpos(StudentSubGroup_TotalTested, "-") & StudentSubGroup_TotalTested != "--" & StudentSubGroup_TotalTested > "0"
	}
 
 	else {
		di as error "No, StudentSubGroup_TotalTested does not include ranges."
		}	
}

***********************************************************
*StudentSubGroup_TotalTested 

** • Data cleaner only: Have ANY sugroup_totaltested counts been derived?
** • Data cleaner and reviewer: If YES to question above, have notes about count derivations been added to the CW? [if not applicable, mark n/a]
di as error "Data cleaner only: Have ANY sugroup_totaltested counts been derived/notes added to CW?"
di as error "Data cleaner and reviewer: If YES to question above, verify in the CW that notes about count derivations for StudentSubGroup_TotalTested been added to the CW"

***********************************************************
*StudentSubGroup_TotalTested 

** • Has StudentSubGroup_TotalTested been derived to the extent possible? // update 12/19/24

{
gen derive_ssgtt = .
gen levcount_rng_flag=.
gen levcount_supp_or_missing = .

forvalues n = 1/3{
	
	replace levcount_supp_or_missing = 1 if inlist(Lev`n'_count, "*", "--","") & ProficiencyCriteria == "Levels 2-3"
	
	}
	
forvalues n = 1/4{
	
	replace levcount_supp_or_missing = 1 if inlist(Lev`n'_count, "*", "--","") & ProficiencyCriteria == "Levels 3-4"
	
	}
	
forvalues n = 1/5{
	
	replace levcount_supp_or_missing = 1 if inlist(Lev`n'_count, "*", "--","") & ProficiencyCriteria == "Levels 3-5"
	
	}
	
forvalues n = 1/5{
	
	replace levcount_supp_or_missing = 1 if inlist(Lev`n'_count, "*", "--","") & ProficiencyCriteria == "Levels 4-5"
	
	}
	
forvalues n = 1/5{
	
	replace levcount_rng_flag = 1 if strpos(Lev`n'_count, "-")
	
	}

// Determining if possible to derive 	
replace derive_ssgtt = 1 if inlist(StudentSubGroup_TotalTested, "*", "--") & !inlist(levcount_supp_or_missing, 1) 
replace derive_ssgtt = . if levcount_rng_flag == 1
	
	gsort -derive_ssgtt
	
	count if inlist(derive_ssgtt, 1)
		if r(N)>0 {
			di as error "SSG_TT values can be derived in the files below. Check the exported excel file."
			tab FILE DataLevel if inlist(derive_ssgtt, 1)
			
		preserve
		keep if derive_ssgtt==1
		drop StateAbbrev StateFips  StateAssignedDistID  StateAssignedSchID  AssmtName AssmtType AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr
		cap drop d_MultipleStateIDsPer_NCESid	d_MultipleNCESIDsPer_SchID	select	s_MultipleStateSchIDsPer_NCESid	s_MultipleNCESIDsPer_StateSchID	sch_select	cty_flag1	cty_flag2	AllStudChk	raceeth_chk dup

		export excel using "${Review}/${StateAbbrev}_can derive ssgtt_${date}.xlsx", firstrow(variables) replace
		restore
	}	
	
	else {
		di as error "No additional StudentSubGroup_TotalTested values can be derived."
		}

drop derive_ssgtt levcount_rng_flag
}
 
***********************************************************
***********************************************************
** G. PROFICIENCY DATA
***********************************************************
***********************************************************
*ProficiencyCriteria

** • Does this variable clearly reflect the proficiency criteria stated in the CW across years for ela/math?
{
tab ProficiencyCriteria FILE if Subject == "ela"
tab ProficiencyCriteria FILE if Subject == "math"
}

** • Does this variable clearly reflect the proficiency criteria stated in the CW across years for sci?

{
tab ProficiencyCriteria FILE if Subject == "sci"
}

** • Does this variable clearly reflect the proficiency criteria stated in the CW across years for social studies?

{
tab ProficiencyCriteria FILE if Subject == "soc"
}

***********************************************************	
*ProficiencyCriteria

** • Are all rows free from any blanks?
** • Is the appropriate naming convention used across all files/subjects? ("Levels 3-4"  vs. "Lev 3-4" or "Levels 3 and 4", for example)

{
local errorBlanks 0    // Track blanks
local errorFormat 0    // Track format

local prof_criteria "ProficiencyCriteria"

foreach var of local prof_criteria {
	
	//blanks 
	count if missing(`var')
	if r(N) {
		di as error "`var' has missing values in the following files."
		tab DataLevel FILE if missing(`var')
		local errorBlanks 1
	}
	
	//format
	count if substr(ProficiencyCriteria,1,6) != "Levels" | substr(ProficiencyCriteria,9,1) != "-"
	if r(N) !=0 {
		di as error "`var' formatting is not correct in the following files."
		tab ProficiencyCriteria FILE if substr(ProficiencyCriteria,1,6) != "Levels" | substr(ProficiencyCriteria,9,1) != "-"
		tab Subject FILE if substr(ProficiencyCriteria,1,6) != "Levels" | substr(ProficiencyCriteria,9,1) != "-"
		local errorFormat 1
	}
	
	// Correct 
	if `errorBlanks' == 0 & `errorFormat' == 0 {
		di as error "Correct."
		}
	}
}
***********************************************************
* Level counts - Run code all together down to / including the summary

** • LEV 1: Have counts been derived to the extent possible? (updated 1/16/25)
{
{			
gen der_L1_ct_lev23 = .
	replace der_L1_ct_lev23 = 1 if ProficiencyCriteria == "Levels 2-3" & ///
		(inlist(Lev1_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--") & ///
		!inlist(StudentSubGroup_TotalTested, "*", "--")) 
	replace der_L1_ct_lev23 = 1 if ProficiencyCriteria == "Levels 2-3" & ///
		(inlist(Lev1_count, "*", "--") & !inlist(Lev2_count, "*", "--") & ///
		!inlist(StudentSubGroup_TotalTested, "*", "--"))

gen der_L1_ct_lev34 = .
	replace der_L1_ct_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ///
		(inlist(Lev1_count, "*", "--") & !inlist(Lev2_count, "*", "--") & ///
		!inlist(ProficientOrAbove_count, "*", "--") & ///
		!inlist(StudentSubGroup_TotalTested, "*", "--")) 
	replace der_L1_ct_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ///
		(inlist(Lev1_count, "*", "--") & !inlist(Lev2_count, "*", "--") & ///
		!inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--") & ///
		!inlist(StudentSubGroup_TotalTested, "*", "--"))

gen der_L1_ct_lev35 = .
	replace der_L1_ct_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev1_count, "*", "--") & !inlist(Lev2_count, "*", "--") & ///
		!inlist(ProficientOrAbove_count, "*", "--") & ///
		!inlist(StudentSubGroup_TotalTested, "*", "--")) 
	replace der_L1_ct_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev1_count, "*", "--") & !inlist(Lev2_count, "*", "--") & ///
		!inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--") & ///
		!inlist(Lev5_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--"))
	
gen der_L1_ct_lev45 = .
	replace der_L1_ct_lev45 = 1 if ProficiencyCriteria == "Levels 4-5" & ///
		(inlist(Lev1_count, "*", "--") & !inlist(Lev2_count, "*", "--") & ///
		!inlist(Lev3_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--") & ///
		!inlist(StudentSubGroup_TotalTested, "*", "--")) 
	replace der_L1_ct_lev45 = 1 if ProficiencyCriteria == "Levels 4-5" & ///
		(inlist(Lev1_count, "*", "--") & !inlist(Lev2_count, "*", "--") & ///
		!inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--") & ///
		!inlist(Lev5_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--"))

	// L1 summary
	gen der_L1 = .
	cap replace der_L1 = 1 if (der_L1_ct_lev23 == 1 | der_L1_ct_lev34 == 1 | der_L1_ct_lev35 == 1 | der_L1_ct_lev45 == 1)
	replace der_L1 = . if StateAbbrev == "ME" & inlist(FILE, "2021", "2022") & Subject != "sci"
	gsort -der_L1

	drop der_L1_ct_lev23 der_L1_ct_lev34 der_L1_ct_lev35 der_L1_ct_lev45

}

** • LEV 2: Have counts been derived to the extent possible? (updated 1/16/25)
{
gen der_L2_ct_lev23 = .
	replace der_L2_ct_lev23 = ProficiencyCriteria == "Levels 2-3" & ///
        (inlist(Lev2_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--", "")) 
	replace der_L2_ct_lev23 = ProficiencyCriteria == "Levels 2-3" & ///
        (inlist(Lev2_count, "*", "--") & !inlist(Lev1_count, "*", "--") & ///
        !inlist(Lev3_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--"))

gen der_L2_ct_lev34 = .
    replace der_L2_ct_lev34 = ProficiencyCriteria == "Levels 3-4" & ///
        (inlist(Lev2_count, "*", "--") & !inlist(Lev1_count, "*", "--") & ///
        !inlist(ProficientOrAbove_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--")) 
    replace der_L2_ct_lev34 = ProficiencyCriteria == "Levels 3-4" & ///
        (inlist(Lev2_count, "*", "--") & !inlist(Lev1_count, "*", "--") & ///
        !inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--") & ///
        !inlist(StudentSubGroup_TotalTested, "*", "--"))
	if StateAbbrev == "ME" & inlist(FILE, "2021", "2022") & Subject != "sci" {
		replace der_L2_ct_lev34 = .
		replace der_L2_ct_lev34 = ProficiencyCriteria == "Levels 3-4" & ///
        (inlist(Lev2_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--") & ///
		!inlist(StudentSubGroup_TotalTested, "*", "--"))
		replace der_L2_ct_lev34 = ProficiencyCriteria == "Levels 3-4" & ///
        (inlist(Lev2_count, "*", "--") & !inlist(Lev3_count, "*", "--") & ///
        !inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--") & ///
        !inlist(StudentSubGroup_TotalTested, "*", "--"))
	}

gen der_L2_ct_lev35 = .
    replace der_L2_ct_lev35 = ProficiencyCriteria == "Levels 3-5" & ///
        (inlist(Lev2_count, "*", "--") & !inlist(Lev1_count, "*", "--") & ///
        !inlist(ProficientOrAbove_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--")) 
    replace der_L2_ct_lev35 = ProficiencyCriteria == "Levels 3-5" & ///
        (inlist(Lev2_count, "*", "--") & !inlist(Lev1_count, "*", "--") & ///
        !inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--") & ///
        !inlist(Lev5_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--"))

gen der_L2_ct_lev45 = .
    replace der_L2_ct_lev45 = ProficiencyCriteria == "Levels 4-5" & ///
        (inlist(Lev2_count, "*", "--") & !inlist(Lev1_count, "*", "--") & ///
        !inlist(Lev3_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--") & ///
        !inlist(StudentSubGroup_TotalTested, "*", "--")) 
    replace der_L2_ct_lev45 = ProficiencyCriteria == "Levels 4-5" & ///
        (inlist(Lev2_count, "*", "--") & !inlist(Lev1_count, "*", "--") & ///
        !inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--") & ///
        !inlist(Lev5_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--"))

    // L2 summary
    gen der_L2 = .
    cap replace der_L2 = 1 if (der_L2_ct_lev23 == 1 | der_L2_ct_lev34 == 1 | der_L2_ct_lev35 == 1 | der_L2_ct_lev45 == 1)
    gsort -der_L2
    drop der_L2_ct_lev23 der_L2_ct_lev34 der_L2_ct_lev35 der_L2_ct_lev45
}



** • LEV 3: Have counts been derived to the extent possible? (updated 1/16/25)
{
gen der_L3_ct_lev23 = .
    replace der_L3_ct_lev23 = ProficiencyCriteria == "Levels 2-3" & ///
        (inlist(Lev3_count, "*", "--") & ///
		!inlist(Lev2_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--")) 
    replace der_L3_ct_lev23 = ProficiencyCriteria == "Levels 2-3" & ///
        (inlist(Lev3_count, "*", "--") & !inlist(Lev1_count, "*", "--") & ///
		!inlist(Lev2_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--"))

gen der_L3_ct_lev34 = .
    replace der_L3_ct_lev34 = ProficiencyCriteria == "Levels 3-4" & ///
        (inlist(Lev3_count, "*", "--") & /// 
		!inlist(Lev4_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--")) 
    replace der_L3_ct_lev34 = ProficiencyCriteria == "Levels 3-4" & ///
        (inlist(Lev3_count, "*", "--") & ///
		!inlist(Lev1_count, "*", "--") & ///
		!inlist(Lev2_count, "*", "--") & ///
		!inlist(Lev4_count, "*", "--") & ///
		!inlist(StudentSubGroup_TotalTested, "*", "--"))

gen der_L3_ct_lev35 = .
    replace der_L3_ct_lev35 = ProficiencyCriteria == "Levels 3-5" & ///
        (inlist(Lev3_count, "*", "--") & ///
		!inlist(Lev4_count, "*", "--") & !inlist(Lev5_count, "*", "--") & ///
		!inlist(ProficientOrAbove_count, "*", "--")) 
    replace der_L3_ct_lev35 = ProficiencyCriteria == "Levels 3-5" & ///
        (inlist(Lev3_count, "*", "--") & !inlist(Lev1_count, "*", "--") & ///
		!inlist(Lev2_count, "*", "--") & !inlist(Lev4_count, "*", "--") & ///
		!inlist(Lev5_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--"))

gen der_L3_ct_lev45 = .
    replace der_L3_ct_lev45 = ProficiencyCriteria == "Levels 4-5" & ///
        (inlist(Lev3_count, "*", "--") & ///
		!inlist(Lev1_count, "*", "--") & !inlist(Lev2_count, "*", "--") & ///
		!inlist(ProficientOrAbove_count, "*", "--")) 
    replace der_L3_ct_lev45 = ProficiencyCriteria == "Levels 4-5" & ///
        (inlist(Lev3_count, "*", "--") & !inlist(Lev1_count, "*", "--") & ///
		!inlist(Lev2_count, "*", "--") & !inlist(Lev4_count, "*", "--") & ///
		!inlist(Lev5_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--"))

    // L3 summary
    gen der_L3 = .
    cap replace der_L3 = 1 if (der_L3_ct_lev23 == 1 | der_L3_ct_lev34 == 1 | der_L3_ct_lev35 == 1 | der_L3_ct_lev45 == 1)
    gsort -der_L3

drop der_L3_ct_lev23 der_L3_ct_lev34 der_L3_ct_lev35 der_L3_ct_lev45
}

** • LEV 4: Have counts been derived to the extent possible? (updated 1/16/25)

{
gen der_L4_ct_lev34 = .
    replace der_L4_ct_lev34 = ProficiencyCriteria == "Levels 3-4" & ///
        (inlist(Lev4_count, "*", "--") & ///
		!inlist(Lev3_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--")) 
    replace der_L4_ct_lev34 = ProficiencyCriteria == "Levels 3-4" & ///
        (inlist(Lev4_count, "*", "--") & !inlist(Lev1_count, "*", "--") & ///
		!inlist(Lev2_count, "*", "--") & !inlist(Lev3_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--"))

gen der_L4_ct_lev35 = .
    replace der_L4_ct_lev35 = ProficiencyCriteria == "Levels 3-5" & ///
        (inlist(Lev4_count, "*", "--") & ///
		!inlist(Lev3_count, "*", "--") & !inlist(Lev5_count, "*", "--") & ///
		!inlist(ProficientOrAbove_count, "*", "--")) 
    replace der_L4_ct_lev35 = ProficiencyCriteria == "Levels 3-5" & ///
        (inlist(Lev4_count, "*", "--") & !inlist(Lev1_count, "*", "--") & ///
		!inlist(Lev2_count, "*", "--") & !inlist(Lev3_count, "*", "--") & ///
		!inlist(Lev5_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--"))

gen der_L4_ct_lev45 = .
    replace der_L4_ct_lev45 = ProficiencyCriteria == "Levels 4-5" & ///
        (inlist(Lev4_count, "*", "--") & !inlist(Lev5_count, "*", "--") & ///
		!inlist(ProficientOrAbove_count, "*", "--")) 
    replace der_L4_ct_lev45 = ProficiencyCriteria == "Levels 4-5" & ///
        (inlist(Lev4_count, "*", "--") & !inlist(Lev1_count, "*", "--") & ///
		!inlist(Lev2_count, "*", "--") & !inlist(Lev3_count, "*", "--") & ///
		!inlist(Lev5_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--"))

    // L4 summary
    gen der_L4 = .
    cap replace der_L4 = 1 if (der_L4_ct_lev34 == 1 | der_L4_ct_lev35 == 1 | der_L4_ct_lev45 == 1)
    gsort -der_L4


drop der_L4_ct_lev34 der_L4_ct_lev35 der_L4_ct_lev45
}

** • LEV 5: Have counts been derived to the extent possible? (updated 1/16/25)
{
gen der_L5_ct_lev35 = .
	replace der_L5_ct_lev35= ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev5_count, "*", "--") & ///
		!inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--") & ///
		!inlist(ProficientOrAbove_count, "*", "--")) 
	replace der_L5_ct_lev35= ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev5_count, "*", "--") & !inlist(Lev1_count, "*", "--") & !inlist(Lev2_count, "*", "--") & ///
		!inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--"))

gen der_L5_ct_lev45 = .
	replace der_L5_ct_lev45 = ProficiencyCriteria == "Levels 4-5" & ///
		(inlist(Lev5_count, "*", "--") & ///
		!inlist(Lev4_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--"))
	replace der_L5_ct_lev45 = ProficiencyCriteria == "Levels 4-5" & ///
		(inlist(Lev5_count, "*", "--") & !inlist(Lev1_count, "*", "--") & !inlist(Lev2_count, "*", "--") & ///
		!inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--"))

	// L5 summary
	gen der_L5 = .
	cap replace der_L5 = 1 if (der_L5_ct_lev35 == 1 | der_L5_ct_lev45 == 1)
	gsort -der_L5

drop der_L5_ct_lev35 der_L5_ct_lev45
}

//Summary
{
local der_alllev_counts "der_L1 der_L2 der_L3 der_L4 der_L5"

foreach var of local der_alllev_counts {
	
	count if `var' ==1
	
	if r(N) !=0 {
		tab FILE Subject if `var' ==1
			
		preserve
		keep if `var' ==1
		cap drop StateAbbrev StateFips  StateAssignedDistID  StateAssignedSchID  AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr AssmtName AssmtType
		cap drop dup
		cap export excel using "${Review}/${StateAbbrev}_der lev counts summary_${date}.xlsx", firstrow(variables) replace
		restore		
	
		di as error "It is possible to `var'. Review output in review folder."	
		}
		
	else {
		di as error "No additional `var' values can be derived."
		}	
	}

drop der_L1 der_L2 der_L3 der_L4 der_L5
}
}

***********************************************************
* Level counts 

** • Are all applicable rows free from any blanks? // updated 1/9/25

{
local levcounts "Lev1_count Lev2_count Lev3_count"
local lev4counts "Lev4_count"
local lev5counts "Lev5_count"

foreach var of local levcounts {
    gen `var'_blank = missing(`var')
    *tab FILE `var'_blank
}

gen Lev4_count_blank = missing(Lev4_count) & ProficiencyCriteria != "Levels 2-3"
*tab FILE Lev4_count_blank

gen Lev5_count_blank = missing(Lev5_count) & inlist(ProficiencyCriteria, "Levels 3-5", "Levels 4-5")
*tab FILE Lev5_count_blank

local levcountsblank "Lev1_count_blank Lev2_count_blank Lev3_count_blank Lev4_count_blank Lev5_count_blank"

foreach var of local levcountsblank {
    count if `var' == 1
    if r(N) {
        tab FILE DataLevel if `var' == 1
        preserve
        keep if `var' == 1
        cap drop StateAbbrev StateFips  StateAssignedDistID  StateAssignedSchID  AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr dup
        cap export excel using "${Review}/${StateAbbrev}_levblanks_${date}.xlsx", firstrow(variables) replace
        restore	
    } 
	else {
        di as error "Correct."
    }
}

drop `levcountsblank'
}



***********************************************************
* Level counts 

** • Are all rows free from commas, extra spaces, negative values, inequalities, and periods?
{	
//Check	
local errorCommas 0   		// Track commas
local errorSpaces 0   		// Track extra spaces
local errorNegative 0    	// Track neg values
local errorInequalities 0 	// Track inequalities
local errorPeriods 0 		// Track periods

local levcounts "Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count"

foreach var of local levcounts {
	
	//commas 
	count if strpos(`var', ",")
	if r(N) !=0 {
		di as error "`var' has values with commas in the files below."
		tab DataLevel FILE if strpos(`var', ",")
		local errorCommas 1
		}

	//extra spaces 
	count if strpos(`var', " ")
	if r(N) !=0 {
		di as error "`var' has values with extra spaces in the files below."
		tab DataLevel FILE if strpos(`var', " ")
		local errorSpaces 1
		}

	//negative numbers
	count if real(`var') < 0 & !missing(real(`var'))
	if r(N) !=0 {
		di as error "`var' has negative values in the files below."
		tab `var' FILE if real(`var') < 0 & !missing(real(`var'))
		keep if real(`var') < 0 & !missing(real(`var'))
		local errorNegative 1
		}
	
	//inequalities
	count if strpos(`var', ">") | strpos(`var', "<") 
	if r(N) !=0 {
		di as error "`var' has values with inequalities in the files below."
		tab DataLevel FILE if strpos(`var', ">") | strpos(`var', "<") 
		local errorInequalities 1
		}
	
	//periods
	count if strpos(`var', ".") 
	if r(N) !=0 {
		di as error "`var' has values with periods in the files below."
		tab DataLevel FILE if strpos(`var', ".") 
		local errorPeriods 1
		}
}

	// Correct 
	if `errorCommas' == 0 & `errorSpaces' == 0 & `errorNegative' == 0 & `errorInequalities' == 0 & `errorPeriods' == 0 {
		di as error "Correct."
		}
	}



**********************************************************
* Level counts 

** • Have low level count values been reviewed for irregularities?
tab Lev1_count if Lev1_count <"10" 
tab Lev2_count if Lev2_count <"10" 
tab Lev3_count if Lev3_count <"10" 
tab Lev4_count if Lev4_count <"10" 
tab Lev5_count if Lev5_count <"10" 



***********************************************************
* Level counts 

** • Does the file include suppressed data (*)?
{
local levcounts "Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count"

foreach var of local levcounts {
	count if `var' =="*"
	if r(N) !=0 {
		di as error "`var' has suppressed values in the files below."
		tab FILE `var'  if `var' =="*"
	} 
	
	else {
		di as error "No, `var' does not have suppressed (*) values."
		}	
	}
}


***********************************************************
* Level counts 

** • Does the file include missing data (--)?
{
local levcounts "Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count"

foreach var of local levcounts {
	count if `var' =="--"
	if r(N) !=0 {
		di as error "`var' has values indicated as missing (--) in the files below."
		tab FILE `var'  if `var' =="--"
	} 
	
	else {
		di as error "No, `var' does not have missing (--) values."
		}	
	}
}

***********************************************************
* Level counts 

** • Are there ranges in the level counts?
** • If YES: Has this been noted in the CW?
** • If YES: Do the values make sense? (e.g., "1-1" should just be 1, lower bound should not be higher than the upper bound)
{ 
local levcounts "Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count"

foreach var of local levcounts {
	count if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	gen `var'_rngflag =1 if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	if r(N) !=0 {
		di as error "`var' has values with possible ranges in the files below."
		tab `var' FILE if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	} 
	
	else {
		di as error " `var' does not have ranges."
		}	
}

drop Lev1_count_rngflag Lev2_count_rngflag Lev3_count_rngflag Lev4_count_rngflag Lev5_count_rngflag
}
***********************************************************
* Level counts 

** • If the state does NOT USE the proficiency level (most commonly, Level 5 is not used), is the proficiency level BLANK? // updated 1/9/25
{
local levcounts "Lev4_count Lev5_count"

foreach var of local levcounts {
    gen `var'_shouldbeblank = .
    
    if "`var'" == "Lev4_count" {
        replace `var'_shouldbeblank = 1 if !missing(`var') & ProficiencyCriteria == "Levels 2-3"
    }
    else if "`var'" == "Lev5_count" {
        replace `var'_shouldbeblank = 1 if !missing(`var') & inlist(ProficiencyCriteria, "Levels 2-3", "Levels 3-4")
    }

    tab FILE Subject if `var'_shouldbeblank == 1
    tab ProficiencyCriteria FILE if `var'_shouldbeblank == 1
}

count if Lev4_count_shouldbeblank == 1 | Lev5_count_shouldbeblank == 1

	if r(N) != 0 {
		preserve
		keep if Lev4_count_shouldbeblank == 1 | Lev5_count_shouldbeblank == 1
		drop StateAbbrev StateFips StateAssignedDistID StateAssignedSchID ///
				 AvgScaleScore ParticipationRate Flag_AssmtNameChange ///
				 Flag_CutScoreChange_ELA Flag_CutScoreChange_math ///
				 Flag_CutScoreChange_sci Flag_CutScoreChange_soc ///
				 DistType DistCharter DistLocale SchType SchLevel ///
				 SchVirtual CountyName CountyCode n_all n_yr 
		cap export excel using "${Review}/${StateAbbrev}_level_counts_should_be_blank_${date}.xlsx", ///
			 firstrow(variables) replace
		restore		

		di as error "There are Level 4 or 5 counts that should be blank based on the ProficiencyCriteria. Review output in review folder. The file will not export if there are too many values, so please review in the Data Editor if needed."
	} 
	else {
		di as error "Correct."
	}
}



// drop only after no longer needed
drop Lev4_count_shouldbeblank Lev5_count_shouldbeblank


***********************************************************
* Level percents  

** RUN THIS CODE DOWN THROUGH / INCLUDING THE SUMMARY
** • LEV 1: Can additional Level1_percents be derived? // updated 1/13/25
{
{
gen der_L1_per_lev23 = .
	replace der_L1_per_lev23 = 1 if ProficiencyCriteria == "Levels 2-3" & ///
		(inlist(Lev1_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--") & ///
		!inlist(StudentSubGroup_TotalTested, "*", "--")) 
	replace der_L1_per_lev23 = 1 if ProficiencyCriteria == "Levels 2-3" & ///
		(inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & ///
		!inlist(Lev3_percent, "*", "--"))

gen der_L1_per_lev34 = .
	replace der_L1_per_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ///
		(inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & ///
		!inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L1_per_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ///
		(inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & ///
		!inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--"))

gen der_L1_per_lev35 = .
	replace der_L1_per_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & ///
		!inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L1_per_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & ///
		!inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & ///
		!inlist(Lev5_percent, "*", "--"))

gen der_L1_per_lev45 = .
	replace der_L1_per_lev45 = 1 if ProficiencyCriteria == "Levels 4-5" & ///
		(inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & ///
		!inlist(Lev3_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L1_per_lev45 = 1 if ProficiencyCriteria == "Levels 4-5" & ///
		(inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & ///
		!inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & ///
		!inlist(Lev5_percent, "*", "--"))

	// L1 summary 
	gen der_L1 = .
	cap replace der_L1 = 1 if (der_L1_per_lev23 == 1 | der_L1_per_lev34 == 1 | der_L1_per_lev35 == 1 | der_L1_per_lev45 == 1)
	replace der_L1 = . if StateAbbrev == "ME" & inlist(FILE, "2021", "2022") & Subject != "sci"
	gsort -der_L1

	drop der_L1_per_lev23 der_L1_per_lev34 der_L1_per_lev35 der_L1_per_lev45
}

** • LEV 2: Can additional Level2_percents be derived?
{
gen der_L2_per_lev23 = .
	replace der_L2_per_lev23 = 1 if ProficiencyCriteria == "Levels 2-3" & ///
		(inlist(Lev2_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L2_per_lev23 = 1 if ProficiencyCriteria == "Levels 2-3" & ///
		(inlist(Lev2_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(Lev3_percent, "*", "--"))
	

gen der_L2_per_lev34 = .
	replace der_L2_per_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ///
		(inlist(Lev2_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L2_per_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ///
		(inlist(Lev2_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--"))
	if StateAbbrev == "ME" & inlist(FILE, "2021", "2022") & Subject != "sci" {
		replace der_L2_ct_lev34 = .
		replace der_L2_ct_lev34 = ProficiencyCriteria == "Levels 3-4" & ///
        (inlist(Lev2_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--") & ///
		!inlist(StudentSubGroup_TotalTested, "*", "--"))
		replace der_L2_ct_lev34 = ProficiencyCriteria == "Levels 3-4" & ///
        (inlist(Lev2_count, "*", "--") & !inlist(Lev3_count, "*", "--") & ///
        !inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--") & ///
        !inlist(StudentSubGroup_TotalTested, "*", "--"))
	}


gen der_L2_per_lev35 = .
	replace der_L2_per_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev2_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L2_per_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev2_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & ///
		!inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & !inlist(Lev5_percent, "*", "--"))


gen der_L2_per_lev45 = .
	replace der_L2_per_lev45 = 1 if ProficiencyCriteria == "Levels 4-5" & ///
		(inlist(Lev2_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & ///
		!inlist(Lev3_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L2_per_lev45 = 1 if ProficiencyCriteria == "Levels 4-5" & ///
		(inlist(Lev2_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & ///
		!inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & !inlist(Lev5_percent, "*", "--"))

	// L2 summary 
	gen der_L2 = .
	cap replace der_L2 = 1 if (der_L2_per_lev23 == 1 | der_L2_per_lev34 == 1 | der_L2_per_lev35 == 1 | der_L2_per_lev45 == 1)
	gsort -der_L2

drop der_L2_per_lev23 der_L2_per_lev34 der_L2_per_lev35 der_L2_per_lev45
}

** • LEV 3: Can additional Level2_percents be derived?
{
gen der_L3_per_lev23 = .
	replace der_L3_per_lev23 = 1 if ProficiencyCriteria == "Levels 2-3" & ///
		(inlist(Lev3_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L3_per_lev23 = 1 if ProficiencyCriteria == "Levels 2-3" & ///
		(inlist(Lev3_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--"))

gen der_L3_per_lev34 = .
	replace der_L3_per_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ///
		(inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L3_per_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ///
		(inlist(Lev3_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & !inlist(Lev4_percent, "*", "--"))


gen der_L3_per_lev35 = .
	replace der_L3_per_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & ///
		!inlist(Lev5_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L3_per_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev3_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & ///
		!inlist(Lev2_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & !inlist(Lev5_percent, "*", "--"))

gen der_L3_per_lev45 = .
	replace der_L3_per_lev45 = 1 if ProficiencyCriteria == "Levels 4-5" & ///
		(inlist(Lev3_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & ///
		!inlist(Lev2_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L3_per_lev45 = 1 if ProficiencyCriteria == "Levels 4-5" & ///
		(inlist(Lev3_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & ///
		!inlist(Lev2_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & !inlist(Lev5_percent, "*", "--"))
		
	// L3 summary 
	gen der_L3 = .
	cap replace der_L3 = 1 if (der_L3_per_lev23 == 1 | der_L3_per_lev34 == 1 | der_L3_per_lev35 == 1 | der_L3_per_lev45 == 1)
	gsort -der_L3

drop der_L3_per_lev23 der_L3_per_lev34 der_L3_per_lev35 der_L3_per_lev45
}

** • LEV 4: Can additional Level2_percents be derived?

{
gen der_L4_per_lev34 = .
	replace der_L4_per_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ///
		(inlist(Lev4_percent, "*", "--") & !inlist(Lev3_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L4_per_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ///
		(inlist(Lev4_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & !inlist(Lev3_percent, "*", "--"))

gen der_L4_per_lev35 = .
	replace der_L4_per_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev4_percent, "*", "--") & !inlist(Lev3_percent, "*", "--") & ///
		!inlist(Lev5_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L4_per_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev4_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & ///
		!inlist(Lev2_percent, "*", "--") & !inlist(Lev3_percent, "*", "--") & !inlist(Lev5_percent, "*", "--"))

gen der_L4_per_lev45 = .
	replace der_L4_per_lev45 = 1 if ProficiencyCriteria == "Levels 4-5" & ///
		(inlist(Lev4_percent, "*", "--") & !inlist(Lev5_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L4_per_lev45 = 1 if ProficiencyCriteria == "Levels 4-5" & ///
		(inlist(Lev4_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & !inlist(Lev3_percent, "*", "--") & !inlist(Lev5_percent, "*", "--"))

	// L4 summary 
	gen der_L4 = .
	cap replace der_L4 = 1 if (der_L4_per_lev34 == 1 | der_L4_per_lev35 == 1 | der_L4_per_lev45 == 1)

drop der_L4_per_lev34 der_L4_per_lev35 der_L4_per_lev45

}
	
** • LEV 5: Can additional Level2_percents be derived?

{
gen der_L5_per_lev35 = .
	replace der_L5_per_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev5_percent, "*", "--") & !inlist(Lev3_percent, "*", "--") & ///
		!inlist(Lev4_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")) 
	replace der_L5_per_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ///
		(inlist(Lev5_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & ///
		!inlist(Lev2_percent, "*", "--") & !inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--"))

gen der_L5_per_lev45 = .
	replace der_L5_per_lev45 = 1 if ProficiencyCriteria == "Levels 4-5" & ///
		(inlist(Lev5_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & ///
		!inlist(ProficientOrAbove_percent, "*", "--")) | ///
		(inlist(Lev5_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & ///
		!inlist(Lev2_percent, "*", "--") & !inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--"))
		
	// L5 summary 
	gen der_L5 = .
	cap replace der_L5 = 1 if (der_L5_per_lev35 == 1 | der_L5_per_lev45 == 1)

drop der_L5_per_lev35 der_L5_per_lev45
}

//Summary
{
local der_alllev "der_L1 der_L2 der_L3 der_L4 der_L5"

foreach var of local der_alllev {
	
	count if `var' ==1
	
	if r(N) !=0 {
		tab FILE Subject if `var' ==1
			
		preserve
		keep if `var' ==1
		cap drop StateAbbrev StateFips  StateAssignedDistID  StateAssignedSchID  AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr dup
		cap export excel using "${Review}/${StateAbbrev}_der lev per summary_${date}.xlsx", firstrow(variables) replace
		restore		
	
		di as error "It is possible to `var'. Review output in review folder."	
		}
		
	else {
		di as error "No additional `var' percents can be derived."
		}	
	}
}
}
***********************************************************
* Level percents 

** • Are all applicable rows free from any blanks?
{
	gen levpercent_blank = .
	replace levpercent_blank = 1 if ProficiencyCriteria == "Levels 2-3" & (Lev1_percent =="" | Lev2_percent =="" | Lev3_percent =="") 
	
	replace levpercent_blank = 1 if ProficiencyCriteria == "Levels 3-4" & (Lev1_percent =="" | Lev2_percent =="" | Lev3_percent =="" | Lev4_percent =="" ) 
	
	replace levpercent_blank = 1 if ProficiencyCriteria == "Levels 3-5" & (Lev1_percent =="" | Lev2_percent =="" | Lev3_percent =="" | Lev4_percent =="" |Lev5_percent =="") 
	
	replace levpercent_blank = 1 if ProficiencyCriteria == "Levels 4-5" & (Lev1_percent =="" | Lev2_percent =="" | Lev3_percent =="" | Lev4_percent =="" |Lev5_percent =="")
	
	count if levpercent_blank == 1
	if r(N) !=0 {
		di as error "There are blank values in the following files."
		tab FILE DataLevel if levpercent_blank == 1
		preserve
		keep if levpercent_blank == 1
		cap drop StateAbbrev StateFips  StateAssignedDistID  StateAssignedSchID  AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr dup
		cap export excel using "${Review}/${StateAbbrev}_levpercentblank_${date}.xlsx", firstrow(variables) replace
		restore	
		}
		
	else {
		di as error "Correct."
	}
drop levpercent_blank
}

***********************************************************
* Level percents 

** • Are all values free of inequalities (< or >)?
{
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent "

foreach var of local levpercents {
	count if strpos(`var', ">") | strpos(`var', "<") 
	if r(N) !=0 {
		di as error "`var' has values with extra spaces in the files below."
		tab DataLevel FILE if strpos(`var', ">") | strpos(`var', "<") 
	} 
	
	else {
		di as error "Correct."
		}
	}
}
***********************************************************
*Level percents 

** • Has it been confirmed that there are no cases where the percent across levels does not sum to over 103%?

{
gen levcount_rng_flag=.	
local percents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local percents {
    
	replace levcount_rng_flag = 1 if strpos(`var', "-")
	
	cap split `var', parse("-")
	cap replace `var'2 = `var'1 if (`var'2=="")
	
	cap gen `var'2 = ""
	cap replace `var'2 = `var'1 if (`var'2=="")
}

// Generating num values
local percents2 "Lev1_percent2 Lev2_percent2 Lev3_percent2 Lev4_percent2 Lev5_percent2"

foreach var of local percents2 {
    
	destring `var', generate(`var'_n) ignore("*" & "--")

}

// Generate total
egen tot_levpcts = rowtotal(Lev1_percent2_n Lev2_percent2_n Lev3_percent2_n Lev4_percent2_n Lev5_percent2_n)

// Checking total
count if tot_levpcts>1.03 & levcount_rng_flag !=1
	if r(N) !=0 {
		di as error "Obs have level percents that sum to over 103%. Review output in review folder."
		tab DataLevel FILE if tot_levpcts>1.03
	} 

	{
	preserve
	keep if tot_levpcts>1.03 & levcount_rng_flag !=1
	keep FILE	DataLevel	DistName	SchName	NCESDistrictID	NCESSchoolID	AssmtName	AssmtType	Subject	GradeLevel	StudentGroup	StudentGroup_TotalTested	StudentSubGroup	StudentSubGroup_TotalTested	Lev1_count	Lev1_percent	Lev2_count	Lev2_percent	Lev3_count	Lev3_percent	Lev4_count	Lev4_percent	Lev5_count	Lev5_percent	ProficiencyCriteria	ProficientOrAbove_count	ProficientOrAbove_percent tot_levpcts
	cap export excel using "${Review}/${StateAbbrev}_lev pct over 103_${date}.xlsx", firstrow(variables) replace
	restore	
	}
		else {
		di as error "Correct."
		}
}	

***********************************************************
*Level percents 

** • If there are cases where the percent across levels is <50%, have these been reviewed to check possible areas of concern? (updated 1/26/25)

{
count if tot_levpcts <.50 & tot_levpcts !=0 & levcount_rng_flag !=1
	if r(N) !=0 {
		di as error "Obs have level percents that sum to less than 50%. Review output in review folder."
		tab DataLevel FILE if tot_levpcts <.50 & tot_levpcts !=0 & levcount_rng_flag !=1
		tab FILE StudentSubGroup if tot_levpcts <.50 & tot_levpcts !=0 & levcount_rng_flag !=1
	} 
	
	preserve
	keep if tot_levpcts <.50 & tot_levpcts !=0 & levcount_rng_flag !=1
	keep FILE	DataLevel	DistName	SchName	NCESDistrictID	NCESSchoolID	AssmtName	AssmtType	Subject	GradeLevel	StudentGroup	StudentGroup_TotalTested	StudentSubGroup	StudentSubGroup_TotalTested	Lev1_count	Lev1_percent	Lev2_count	Lev2_percent	Lev3_count	Lev3_percent	Lev4_count	Lev4_percent	Lev5_count	Lev5_percent	ProficiencyCriteria	ProficientOrAbove_count	ProficientOrAbove_percent tot_levpcts
	cap export excel using "${Review}/${StateAbbrev}_lev pct less than 50_${date}.xlsx", firstrow(variables) replace
	restore	
	
		else {
		di as error "Correct."
		}
drop levcount_rng_flag
}


***********************************************************
*Level percents 

** • Are all percents presented as decimals? [or decimal ranges] (updated 1/26/25)
{
local levpercents "Lev1_percent2_n Lev2_percent2_n Lev3_percent2_n Lev4_percent2_n Lev5_percent2_n"

foreach var of local levpercents {
    // Count observations where the variable is outside the range [0, 1]
    count if (`var' > 1 | `var' < 0) & !missing(`var')
    
    if r(N) != 0 {
        di as error "`var' has values greater than 1 or less than 0 in the files below."
        tab `var' FILE if (`var' > 1 | `var' < 0) & !missing(`var')
    } 
    else {
        di as error "`var' Correct."
    }		
}
}

* Drop when no longer needed 
drop Lev1_percent2_n Lev2_percent2_n Lev3_percent2_n Lev4_percent2_n Lev5_percent2_n

***********************************************************
* Level percents 

** • Does the file include suppressed data (*)?
{
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	count if `var' =="*"
	if r(N) !=0 {
		di as error "`var' has suppressed values in the files below."
		tab `var' FILE if `var' =="*"
		} 
	else {
		di as error "No, `var' does not have suppressed (*) values."
		}
	}
}

***********************************************************
* Level percents 

** • Does the file include missing data (--)?

{
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	count if `var' =="--"
	if r(N) !=0 {
		di as error "`var' has values indicated as missing (--) in the files below."
		tab `var' FILE if `var' =="--"
	} 

	else {
		di as error "No, `var' does not have missing (--) values."
		}
	}
}
***********************************************************
* Level percents 

** • Are there ranges in the level percents?
** • If YES: Has this been noted in the CW?
** • If YES: Do the values make sense? (e.g., "1-1" should just be 1, lower bound should not be higher than the upper bound)

{
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	count if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	if r(N) !=0 {
		di as error "`var' has values with possible ranges in the files below."
		tab `var' FILE if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
		} 
		
	else {
		di as error "`var' does not have ranges."
		}
	}
}
***********************************************************
* Level percents 

** • Are all values free of periods (.) where there should be -- or * instead?
{
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	count if `var'=="."
	if r(N) !=0 {
		di as error "`var' has values appearing as periods (.) in the files below."
		tab `var' FILE if `var'== "."
		} 
		
	else {
		di as error "Correct."
		}
	}
}
***********************************************************
* Level percents 

** • Do values align with the original ELA and math data for 2024? [based on State/ELA/Grade 3/All Students] // updated 1/9/25
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"
local subjects "ela math"

foreach subj of local subjects {
    di as text "Level Percent Values for `subj' - 2024, State, Grade 3, All Students" // title above output
	
    preserve
    keep if FILE == "2024" & Subject == "`subj'" & GradeLevel == "G03" & StudentSubGroup == "All Students" & DataLevel == "State"
    
    * Display all level percentages in a single table
    list `levpercents', abbrev(20) noobs sepby(FILE)
    
    di as error "Confirm `subj' values in original 2024 data for State/`subj'/Grade 3/All Students."
    restore
}
***********************************************************
* Level percents 

** • Do values align with the original ELA and math data for 2023? [based on State/ELA/Grade 3/All Students] // updated 1/9/25
{
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"
local subjects "ela math"

foreach subj of local subjects {
    di as text "Level Percent Values for `subj' - 2023, State, Grade 3, All Students" // title above output
	
    preserve
    keep if FILE == "2023" & Subject == "`subj'" & GradeLevel == "G03" & StudentSubGroup == "All Students" & DataLevel == "State"
    
    * Display all level percentages in a single table
    list `levpercents', abbrev(20) noobs sepby(FILE)
    
    di as error "Confirm `subj' values in original 2023 data for State/`subj'/Grade 3/All Students."
    restore
	}
}
***********************************************************
* Level percents 

** • Do values align with the original ELA and math data for 2022? [based on State/ELA/Grade 3/All Students]  // updated 1/9/25
{
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"
local subjects "ela math"

foreach subj of local subjects {
    di as text "Level Percent Values for `subj' - 2022, State, Grade 3, All Students" // title above output
	
    preserve
    keep if FILE == "2022" & Subject == "`subj'" & GradeLevel == "G03" & StudentSubGroup == "All Students" & DataLevel == "State"
    
    * Display all level percentages in a single table
    list `levpercents', abbrev(20) noobs sepby(FILE)
    
    di as error "Confirm `subj' values in original 2022 data for State/`subj'/Grade 3/All Students."
    restore
	}
}
***********************************************************
* Level percents 

** • Has it been confirmed that ELA and math data ARE NOT THE SAME in 2024 (ie, has it been confirmed that ELA data have not inadvertently been applied to math as well, and vice versa?) 
{
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' Subject if (FILE =="2024" & DataLevel=="State" & GradeLevel=="G04" & StudentSubGroup=="White" & (Subject=="ela" | Subject =="math"))
	di as error "Confirm that ELA and math values ARE NOT THE SAME in 2024 for State/Grade 4/White."
	} 
}

***********************************************************
* Level percents 

** • Has it been confirmed that ELA and math data ARE NOT THE SAME in 2023 (ie, has it been confirmed that ELA data have not inadvertently been applied to math as well, and vice versa?) 
{
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' Subject if (FILE =="2023" & DataLevel=="State" & GradeLevel=="G04" & StudentSubGroup=="White" & (Subject=="ela" | Subject =="math"))
	di as error "Confirm that ELA and math values ARE NOT THE SAME in 2023 for State/Grade 4/White."
	} 
}
***********************************************************
* Level percents 

** • Has it been confirmed that ELA and math data ARE NOT THE SAME in 2022 (ie, has it been confirmed that ELA data have not inadvertently been applied to math as well, and vice versa?) 
{
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' Subject if (FILE =="2022" & DataLevel=="State" & GradeLevel=="G04" & StudentSubGroup=="White" & (Subject=="ela" | Subject =="math"))
	di as error "Confirm that ELA and math values ARE NOT THE SAME in 2022 for State/Grade 4/White."
	} 
}
***********************************************************
* Level percents 

** • Has it been confirmed that ELA and math data ARE NOT THE SAME in 2021 (ie, has it been confirmed that ELA data have not inadvertently been applied to math as well, and vice versa?) 
{
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' Subject if (FILE =="2021" & DataLevel=="State" & GradeLevel=="G04" & StudentSubGroup=="White" & (Subject=="ela" | Subject =="math"))
	di as error "Confirm that ELA and math values ARE NOT THE SAME in 2021 for State/Grade 4/White."
	} 
}
************************************************************ 
* Level percents 

** • Has it been confirmed that ELA and math data ARE NOT THE SAME in 2019 (ie, has it been confirmed that ELA data have not inadvertently been applied to math as well, and vice versa?) 
{
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' Subject if (FILE =="2019" & DataLevel=="State" & GradeLevel=="G04" & StudentSubGroup=="White" & (Subject=="ela" | Subject =="math"))
	di as error "Confirm that ELA and math values ARE NOT THE SAME in 2019 for State/Grade 4/White."
	} 
}
***********************************************************
* Level percents 
	
* If the state does NOT USE the proficiency level (most commonly, Level 5 is not used), is the proficiency level BLANK?	// 1/9/25
{
local levpercents "Lev4_percent Lev5_percent"

foreach var of local levpercents {
    gen `var'_shouldbeblank = .
    
    if "`var'" == "Lev4_percent" {
        replace `var'_shouldbeblank = 1 if !missing(`var') & ProficiencyCriteria == "Levels 2-3"
    }
    else if "`var'" == "Lev5_percent" {
        replace `var'_shouldbeblank = 1 if !missing(`var') & inlist(ProficiencyCriteria, "Levels 2-3", "Levels 3-4")
    }

    tab FILE Subject if `var'_shouldbeblank == 1
    tab ProficiencyCriteria FILE if `var'_shouldbeblank == 1
}

count if Lev4_percent_shouldbeblank == 1 | Lev5_percent_shouldbeblank == 1

if r(N) != 0 {
    preserve
    keep if Lev4_percent_shouldbeblank == 1 | Lev5_percent_shouldbeblank == 1
    cap drop StateAbbrev StateFips StateAssignedDistID StateAssignedSchID ///
             AvgScaleScore ParticipationRate Flag_AssmtNameChange ///
             Flag_CutScoreChange_ELA Flag_CutScoreChange_math ///
             Flag_CutScoreChange_sci Flag_CutScoreChange_soc ///
             DistType DistCharter DistLocale SchType SchLevel ///
             SchVirtual CountyName CountyCode n_all n_yr dup 
    cap export excel using "${Review}/${StateAbbrev}_level_percents_should_be_blank_${date}.xlsx", ///
         firstrow(variables) replace
    restore		

    di as error "There are Level 4 or 5 percents that should be blank based on the ProficiencyCriteria. Review output in review folder. The file will not export if there are too many values, so please review in the Data Editor if needed."
} 
else {
    di as error "Correct."
}


// Drop only after no longer needed
drop Lev4_percent_shouldbeblank Lev5_percent_shouldbeblank
}

***********************************************************

// PROFICIENT OR ABOVE

***********************************************************
** • Does this variable appropriately match the count of the proficiency levels described? (e.g., Levels 3+4?) // updated 1/15/25

// Capturing highest value of each count (for values without ranges)
{
local counts "Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count ProficientOrAbove_count"

foreach var of local counts {
    
	cap split `var', parse("-")
	cap replace `var'2 = `var'1 if missing(`var'2)
	
	cap gen `var'2 = ""
	cap replace `var'2 = `var'1 if missing(`var'2)
}

// Generating num values
local counts2 "Lev1_count2 Lev2_count2 Lev3_count2 Lev4_count2 Lev5_count2 ProficientOrAbove_count2"

foreach var of local counts2 {
    
	destring `var', generate(`var'_n) ignore("*" & "--")

}

// Summing counts based on proficiency criteria
egen sumcounts_lev23 = rowtotal(Lev2_count2_n Lev3_count2_n) if ProficiencyCriteria=="Levels 2-3"
egen sumcounts_lev34 = rowtotal(Lev3_count2_n Lev4_count2_n) if ProficiencyCriteria=="Levels 3-4"
egen sumcounts_lev35 = rowtotal(Lev3_count2_n Lev4_count2_n Lev5_count2_n) if ProficiencyCriteria=="Levels 3-5"
egen sumcounts_lev45 = rowtotal(Lev4_count2_n Lev5_count2_n) if ProficiencyCriteria=="Levels 4-5"

gen sum_levcts = .
	replace sum_levcts = sumcounts_lev23 if missing(sum_levcts)
	replace sum_levcts = sumcounts_lev34 if missing(sum_levcts)
	replace sum_levcts = sumcounts_lev35 if missing(sum_levcts)
	replace sum_levcts = sumcounts_lev45 if missing(sum_levcts)

// Dropping temporary sum variables
drop sumcounts_lev23 sumcounts_lev34 sumcounts_lev35 sumcounts_lev45

// Generating count_diff 

gen count_diff = ProficientOrAbove_count2_n - sum_levcts
gen prof_lv_cts_supp_or_missing = .
gen levcount_rng_flag=.

forvalues n = 2/3{
	
	replace prof_lv_cts_supp_or_missing = 1 if inlist(Lev`n'_count, "*", "--","") & ProficiencyCriteria == "Levels 2-3"
	
	}
	
forvalues n = 3/4{
	
	replace prof_lv_cts_supp_or_missing = 1 if inlist(Lev`n'_count, "*", "--","") & ProficiencyCriteria == "Levels 3-4"
	
	}
	
forvalues n = 3/5{
	
	replace prof_lv_cts_supp_or_missing = 1 if inlist(Lev`n'_count, "*", "--","") & ProficiencyCriteria == "Levels 3-5"
	
	}
	
forvalues n = 4/5{
	
	replace prof_lv_cts_supp_or_missing = 1 if inlist(Lev`n'_count, "*", "--","") & ProficiencyCriteria == "Levels 4-5"
	
	}
	
forvalues n = 1/5{
	
	replace levcount_rng_flag = 1 if strpos(Lev`n'_count, "-")
	
	}

// 
replace count_diff = . if count_diff == 0
replace count_diff = . if inlist(prof_lv_cts_supp_or_missing, 1) 
*replace count_diff = . if levcount_rng_flag == 1
	
	gsort -count_diff
	
//Summary for data without ranges
count if count_diff !=. & levcount_rng_flag !=1

if r(N) != 0 {
        di as error "Review count_diff."
		
		preserve
		keep if count_diff !=. & levcount_rng_flag !=1
		tab if count_diff !=. & levcount_rng_flag !=1
		cap drop StateAbbrev StateFips StateAssignedDistID StateAssignedSchID ///
				 AvgScaleScore ParticipationRate Flag_AssmtNameChange ///
				 Flag_CutScoreChange_ELA Flag_CutScoreChange_math ///
				 Flag_CutScoreChange_sci Flag_CutScoreChange_soc ///
				 DistType DistCharter DistLocale SchType SchLevel ///
				 SchVirtual CountyName CountyCode n_all n_yr  
		cap drop AssmtName AssmtType
		cap drop Lev1_count1 Lev1_count2 Lev1_count2_n Lev2_count1 Lev2_count2 Lev2_count2_n Lev3_count1 Lev3_count2 Lev3_count2_n Lev4_count1 Lev4_count2 Lev4_count2_n Lev5_count2 Lev5_count2_n ProficientOrAbove_count1 ProficientOrAbove_count2 ProficientOrAbove_count2_n 
		cap export excel using "${Review}/${StateAbbrev}_count_diff_check_${date}.xlsx", ///
			 firstrow(variables) replace
		restore		

} 

	else {
		di as error "Correct."
		}
		
}

* Drop after check above is correct.
{
* List of variables to drop
local vars "Lev1_count1 Lev1_count2 Lev1_count2_n Lev2_count1 Lev2_count2 Lev2_count2_n Lev3_count1 Lev3_count2 Lev3_count2_n Lev4_count1 Lev4_count2 Lev4_count2_n Lev5_count2 Lev5_count1 Lev5_count2_n ProficientOrAbove_count1 ProficientOrAbove_count2 ProficientOrAbove_count2_n sum_levcts count_diff prof_lv_cts_supp_or_missing levcount_rng_flag"

* Loop over the list and drop variables if they exist
foreach var of local vars {
    * Check if the variable exists in the dataset
    capture confirm variable `var'
    * If the variable exists, drop it
    if !_rc {
        drop `var'
    }
}
}
***********************************************************
*ProficientOrAbove_count 

//• Have counts been derived to the extent possible? (updated 1/26/25)

{
{	
// Levels 2-3	
	gen derive_profabvcount_lev23 = .

	replace derive_profabvcount_lev23 = 1 if ProficiencyCriteria == "Levels 2-3" & ( ///
		(inlist(ProficientOrAbove_count, "*", "--", "") & !inlist(Lev2_count, "*", "--", "") & !inlist(Lev3_count, "*", "--", "")) ///  
		| (inlist(ProficientOrAbove_count, "*", "--", "") & !inlist(Lev1_count, "*", "--", "") & !inlist(StudentSubGroup_TotalTested, "*", "--", "")) ///  
		| (inlist(ProficientOrAbove_count, "*", "--", "") & !inlist(ProficientOrAbove_percent, "*", "--", "") & !inlist(StudentSubGroup_TotalTested, "*", "--", "")) ///
	)
	
// Levels 3-4	
	gen derive_profabvcount_lev34 = .

	replace derive_profabvcount_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ( ///
		(inlist(ProficientOrAbove_count, "*", "--", "") & !inlist(Lev3_count, "*", "--", "") & !inlist(Lev4_count, "*", "--", "")) ///  
		| (inlist(ProficientOrAbove_count, "*", "--", "") & !inlist(Lev1_count, "*", "--", "") & !inlist(Lev2_count, "*", "--", "") & !inlist(StudentSubGroup_TotalTested, "*", "--", "")) ///  
		| (inlist(ProficientOrAbove_count, "*", "--", "") & !inlist(ProficientOrAbove_percent, "*", "--", "") & !inlist(StudentSubGroup_TotalTested, "*", "--", "")) ///
	)
	if StateAbbrev == "ME" & inlist(FILE, "2021", "2022") & Subject != "sci"{
		replace derive_profabvcount_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ( ///
		(inlist(ProficientOrAbove_count, "*", "--", "") & !inlist(Lev2_count, "*", "--", "") & !inlist(StudentSubGroup_TotalTested, "*", "--", ""))
	)
	}

// Levels 3-5	
	gen derive_profabvcount_lev35 = .

	replace derive_profabvcount_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ( ///
		(inlist(ProficientOrAbove_count, "*", "--", "") & !inlist(Lev3_count, "*", "--", "") & !inlist(Lev4_count, "*", "--", "") & !inlist(Lev5_count, "*", "--", "")) ///  
		| (inlist(ProficientOrAbove_count, "*", "--", "") & !inlist(Lev1_count, "*", "--", "") & !inlist(Lev2_count, "*", "--", "") & !inlist(StudentSubGroup_TotalTested, "*", "--", "")) ///  
		| (inlist(ProficientOrAbove_count, "*", "--", "") & !inlist(ProficientOrAbove_percent, "*", "--", "") & !inlist(StudentSubGroup_TotalTested, "*", "--", "")) ///
	)		

// Levels 4-5
	gen derive_profabvcount_lev45 = .

	replace derive_profabvcount_lev45 = 1 if ProficiencyCriteria == "Levels 4-5" & ( ///
		(inlist(ProficientOrAbove_count, "*", "--", "") & !inlist(Lev4_count, "*", "--", "") & !inlist(Lev5_count, "*", "--", "")) ///  
		| (inlist(ProficientOrAbove_count, "*", "--", "") & !inlist(Lev1_count, "*", "--", "") & !inlist(Lev2_count, "*", "--", "") & !inlist(Lev3_count, "*", "--", "") & !inlist(StudentSubGroup_TotalTested, "*", "--", "")) ///
	)

//Summary
gen derive_profavb_count = .

	local derive_vars "derive_profabvcount_lev23 derive_profabvcount_lev34 derive_profabvcount_lev35 derive_profabvcount_lev45"

	foreach var of local derive_vars {
		cap replace derive_profavb_count = 1 if `var' == 1  
	}

	gsort -derive_profavb_count  
	count if derive_profavb_count == 1

	if r(N) > 0 {
		di as error "ProficientOrAbove_count values can be derived. See output in review folder."
		tab FILE DataLevel if derive_profavb_count == 1  

		preserve
		keep if derive_profavb_count == 1
		drop StateAbbrev StateFips  AssmtName AssmtType StateAssignedDistID  StateAssignedSchID  AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr 
		cap export excel using "${Review}/${StateAbbrev}_derive_profabvcount_${date}.xlsx", firstrow(variables) replace
		restore	
		}
			
		
	else {
		di as error "No additional ProficientOrAbove_count values can be derived."
		}
	}
}

***********************************************************

*ProficientOrAbove_count 

** • Are all rows free from any blanks, commas, and extra spaces
{
local errorBlanks 0    // Track blanks
local errorCommas 0    // Track commas
local errorSpaces 0    // Track extra spaces
local errorInequalities 0 // Track inequalities

local profabove_n "ProficientOrAbove_count"

foreach var of local profabove_n {
	
	//blanks
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has blank values in the files below. Review output."
		tab DataLevel FILE if missing(`var')
		local errorBlanks 1
		
		preserve
		keep if missing(`var')
		keep FILE	State	DataLevel	DistName	SchName	NCESDistrictID	NCESSchoolID Subject	GradeLevel	StudentGroup	StudentGroup_TotalTested	StudentSubGroup	StudentSubGroup_TotalTested	Lev1_count	Lev1_percent	Lev2_count	Lev2_percent	Lev3_count	Lev3_percent	Lev4_count	Lev4_percent	Lev5_count	Lev5_percent	ProficiencyCriteria	ProficientOrAbove_count	ProficientOrAbove_percent
 
		cap export excel using "${Review}/${StateAbbrev}_profabv_blanks_${date}.xlsx", firstrow(variables) replace
		restore	
		}

	//commas
	count if strpos(`var', ",") 
	if r(N) !=0 {
		di as error "`var' has values with commas in the files below. Review output"
		tab DataLevel FILE if strpos(`var', ",") |  strpos(`var', " ")
		local errorCommas 1
				
		preserve
		keep if strpos(`var', ",")
		keep FILE	State	DataLevel	DistName	SchName	NCESDistrictID	NCESSchoolID Subject	GradeLevel	StudentGroup	StudentGroup_TotalTested	StudentSubGroup	StudentSubGroup_TotalTested	Lev1_count	Lev1_percent	Lev2_count	Lev2_percent	Lev3_count	Lev3_percent	Lev4_count	Lev4_percent	Lev5_count	Lev5_percent	ProficiencyCriteria	ProficientOrAbove_count	ProficientOrAbove_percent
		cap export excel using "${Review}/${StateAbbrev}_profabv_commas_${date}.xlsx", firstrow(variables) replace
		restore	
		}
		
	//extra spaces
	count if strpos(`var', " ")
	if r(N) !=0 {
		di as error "`var' has values with extra spaces. "
		tab DataLevel FILE if strpos(`var', "  ") 
		local errorSpaces 1
		}
		 
	// Correct 
	if `errorBlanks' == 0 & `errorCommas' == 0 & `errorSpaces' == 0  {
		di as error "Correct."
		}
		
	}
}

***********************************************************
*ProficientOrAbove_count 

** • Are all rows free from negative numbers?
{
local profabove_n "ProficientOrAbove_count"

foreach var of local profabove_n {
	count if real(`var') < 0 & !missing(real(`var'))
	if r(N) !=0 {
		di as error "`var' has negative values in the files below."
		tab `var' FILE if real(`var') < 0 & !missing(real(`var'))
		}
		
	else {
		di as error "Correct."
		}
		
		{		
		preserve
		keep if real(`var') < 0 & !missing(real(`var'))
		drop StateAbbrev StateFips  StateAssignedDistID  StateAssignedSchID  AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr 
		cap export excel using "${Review}/${StateAbbrev}_profabove_negativenum_${date}.xlsx", firstrow(variables) replace
		restore	
		}
	}
}
***********************************************************
*ProficientOrAbove_count 

** • Are all values free of inequalities (< or >)?
** • Are all values free of periods (.)?
{
local profabove_n "ProficientOrAbove_count"

foreach var of local profabove_n {
	count if strpos(`var', ">") | strpos(`var', "<") | strpos(`var', ".") 
	if r(N) !=0 {
		di as error "`var' has values with inequalities or periods in the files below."
		tab DataLevel FILE if strpos(`var', ">") | strpos(`var', "<") | strpos(`var', ".") 
	} 
	else {
		di as error "Correct."
		}
		
		{		
		preserve
		keep if strpos(`var', ">") | strpos(`var', "<") | strpos(`var', ".") 
		drop StateAbbrev StateFips  StateAssignedDistID  StateAssignedSchID  AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr 
		cap export excel using "${Review}/${StateAbbrev}_profabove_checkvalues_${date}.xlsx", firstrow(variables) replace
		restore	
		}
	}
}
**********************************************************
*ProficientOrAbove_count 

** • Have low count values been reviewed for irregularities?
{
tab ProficientOrAbove_count if ProficientOrAbove_count <"10" 
}

***********************************************************
*ProficientOrAbove_count 

** • Does the file include suppressed data (*)?
** • Does the file include missing data (--)?

local profabove_n "ProficientOrAbove_count"

foreach var of local profabove_n {
	
    // Check for suppressed data (*)
    count if `var' == "*"
    if r(N) != 0 {
        di as error "`var' has suppressed (*) values in the files below."
        tab `var' FILE if `var' == "*"
    }
    else {
        di as error "No, `var' does not have suppressed (*) values."
    }
    
    // Check for missing data (--)
    count if `var' == "--"
    if r(N) != 0 {
        di as error "`var' has values indicated as missing (--) in the files below."
        tab `var' FILE if `var' == "--"
    }
    else {
        di as error "No, `var' does not have missing (--) values."
    }
}

***********************************************************
*ProficientOrAbove_count // updated 9/29/24

** • Are there ranges in the counts?
** • If YES: Has this been noted in the CW?
** • If YES: Do the values make sense? (e.g., "1-1" should just be 1, lower bound should not be higher than the upper bound)
{
local profabove_n "ProficientOrAbove_count"

foreach var of local profabove_n {
	count if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	if r(N) !=0 {
		di as error "`var' has values with possible ranges in the files below."
		tab `var' FILE if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	} 
	
	else {
		di as error "No, `var' does not have ranges in the counts."
		}	
	}	
}
***********************************************************
*ProficientOrAbove_count 
** • Are all values  of ProficientOrAbove_count less than or equal to StudentSubGroup_TotalTested? // updated 9/29/24

{
cap drop flag 
local counts_check "StudentSubGroup_TotalTested ProficientOrAbove_count"

foreach var of local counts_check {
    
	cap split `var', parse("-")
	cap replace `var'2 = `var'1 if (`var'2=="")
	
	cap gen `var'2 = ""
	cap replace `var'2 = `var'1 if (`var'2=="")
}

gen flag = .
	replace flag = 1 if ((real(ProficientOrAbove_count2)) > (real(StudentSubGroup_TotalTested2)))
	replace flag = . if (ProficientOrAbove_count =="" | ProficientOrAbove_count =="*"| ProficientOrAbove_count == "--"| ProficientOrAbove_count2 ==".")
	tab FILE if flag == 1

	{
	count if flag == 1
	if r(N)>0 {
	di as error "ProficientOrAbove_count has values greater than StudentSubGroup_TotalTested in the files below. Review file in review folder."
	tab FILE if flag == 1
	}	
			
	{
	preserve
	cap keep if flag == 1
	drop StateAbbrev StateFips StateAssignedDistID  StateAssignedSchID AssmtName AssmtType AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr StudentSubGroup_TotalTested1  ProficientOrAbove_count1 
	cap export excel using "${Review}/${StateAbbrev}_prof count greater than ssgtt_${date}.xlsx", firstrow(variables) replace
	restore	
	}
	
	else {
	di as error "Correct."
	}
}	
	
drop StudentSubGroup_TotalTested1 StudentSubGroup_TotalTested2 ProficientOrAbove_count1 ProficientOrAbove_count2 flag
}
	
***********************************************************
*ProficientOrAbove_percent 

** • Does this variable appropriately match the sum of the percent of the proficiency levels described? (e.g., Levels 3+4?) // updated 1/15/25

// note - use CA as a test case for next review update 

// Capturing highest value of each count (with and without ranges)
 
{
local percents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent"

foreach var of local percents {
    
    cap split `var', parse("-")
    cap replace `var'2 = `var'1 if missing(`var'2)
    
    cap gen `var'2 = ""
    cap replace `var'2 = `var'1 if missing(`var'2)
}

// Generating num values
local percents2 "Lev1_percent2 Lev2_percent2 Lev3_percent2 Lev4_percent2 Lev5_percent2 ProficientOrAbove_percent2"

foreach var of local percents2 {
    
    destring `var', generate(`var'_n) ignore("*" & "--")

}

// Summing percents based on proficiency criteria
egen sumpercents_lev23 = rowtotal(Lev2_percent2_n Lev3_percent2_n) if ProficiencyCriteria=="Levels 2-3"
egen sumpercents_lev34 = rowtotal(Lev3_percent2_n Lev4_percent2_n) if ProficiencyCriteria=="Levels 3-4"
egen sumpercents_lev35 = rowtotal(Lev3_percent2_n Lev4_percent2_n Lev5_percent2_n) if ProficiencyCriteria=="Levels 3-5"
egen sumpercents_lev45 = rowtotal(Lev4_percent2_n Lev5_percent2_n) if ProficiencyCriteria=="Levels 4-5"

gen sum_levpcts = .
    replace sum_levpcts = sumpercents_lev23 if missing(sum_levpcts)
    replace sum_levpcts = sumpercents_lev34 if missing(sum_levpcts)
    replace sum_levpcts = sumpercents_lev35 if missing(sum_levpcts)
    replace sum_levpcts = sumpercents_lev45 if missing(sum_levpcts)

// Dropping temporary sum variables
drop sumpercents_lev23 sumpercents_lev34 sumpercents_lev35 sumpercents_lev45

// Generating percent_diff 

gen percent_diff = ProficientOrAbove_percent2_n - sum_levpcts
gen prof_lv_pcts_supp_or_missing = .
gen levpercent_rng_flag=.

forvalues n = 2/3{
    
    replace prof_lv_pcts_supp_or_missing = 1 if inlist(Lev`n'_percent, "*", "--","") & ProficiencyCriteria == "Levels 2-3"
    
    }
    
forvalues n = 3/4{
    
    replace prof_lv_pcts_supp_or_missing = 1 if inlist(Lev`n'_percent, "*", "--","") & ProficiencyCriteria == "Levels 3-4"
    
    }
    
forvalues n = 3/5{
    
    replace prof_lv_pcts_supp_or_missing = 1 if inlist(Lev`n'_percent, "*", "--","") & ProficiencyCriteria == "Levels 3-5"
    
    }
    
forvalues n = 4/5{
    
    replace prof_lv_pcts_supp_or_missing = 1 if inlist(Lev`n'_percent, "*", "--","") & ProficiencyCriteria == "Levels 4-5"
    
    }
    
forvalues n = 1/5{
    
    replace levpercent_rng_flag = 1 if strpos(Lev`n'_percent, "-")
    
    }

// 
replace percent_diff = . if percent_diff == 0
replace percent_diff = . if inlist(prof_lv_pcts_supp_or_missing, 1) 
replace percent_diff = . if abs(percent_diff) < .001
*replace percent_diff = . if levpercent_rng_flag == 1


	// MO, 2010-2014. Confirmed the ProficientOrAbove_percent values in the raw data. (1/15/25 - ch)
	if "${StateAbbrev}" == "MO"  & real(FILE)> 2009 & real(FILE) <2015 {
		replace percent_diff = . if abs(percent_diff) < .01
	}
  
    gsort -percent_diff
    
//Summary for data without ranges
count if percent_diff !=. & levpercent_rng_flag !=1

if r(N) != 0 {
        di as error "Review percent_diff."
        
        preserve
        keep if percent_diff !=. & levpercent_rng_flag !=1
        tab FILE if percent_diff !=. & levpercent_rng_flag !=1
        drop StateAbbrev StateFips StateAssignedDistID StateAssignedSchID ///
                 AvgScaleScore ParticipationRate Flag_AssmtNameChange ///
                 Flag_CutScoreChange_ELA Flag_CutScoreChange_math ///
                 Flag_CutScoreChange_sci Flag_CutScoreChange_soc ///
                 DistType DistCharter DistLocale SchType SchLevel ///
                 SchVirtual CountyName CountyCode n_all n_yr  AssmtName AssmtType
        cap drop Lev1_percent1 Lev1_percent2 Lev1_percent2_n Lev2_percent1 Lev2_percent2 Lev2_percent2_n Lev3_percent1 Lev3_percent2 Lev3_percent2_n Lev4_percent1 Lev4_percent2 Lev4_percent2_n Lev5_percent2 Lev5_percent2_n ProficientOrAbove_percent1 ProficientOrAbove_percent2 ProficientOrAbove_percent2_n 
        cap export excel using "${Review}/${StateAbbrev}_percent_diff_check_${date}.xlsx", ///
             firstrow(variables) replace
        restore       

} 

    else {
        di as error "Correct."
        }
        
}

* Drop after check above is correct.
{
* List of variables to drop
local vars "Lev1_percent1 Lev1_percent2 Lev1_percent2_n Lev2_percent1 Lev2_percent2 Lev2_percent2_n Lev3_percent1 Lev3_percent2 Lev3_percent2_n Lev4_percent1 Lev4_percent2 Lev4_percent2_n Lev5_percent2 Lev5_percent1 Lev5_percent2_n ProficientOrAbove_percent1 ProficientOrAbove_percent2 ProficientOrAbove_percent2_n sum_levpcts percent_diff prof_lv_pcts_supp_or_missing levpercent_rng_flag"

* Loop over the list and drop variables if they exist
foreach var of local vars {
    * Check if the variable exists in the dataset
    capture confirm variable `var'
    * If the variable exists, drop it
    if !_rc {
        drop `var'
    }
}
}

***********************************************************
*ProficientOrAbove_percent 


// • Have percents been derived to the extent possible? (updated 1/8/25)

{
//Levels 2-3
gen der_profabvper_lev23 = .

	replace der_profabvper_lev23 = 1 if ProficiencyCriteria == "Levels 2-3" & ( ///
		(inlist(ProficientOrAbove_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & !inlist(Lev3_percent, "*", "--")) ///  
		| (inlist(ProficientOrAbove_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--")) ///  
		| (inlist(ProficientOrAbove_percent, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--")) ///
	)

	count if der_profabvper_lev23 == 1
	if r(N) > 0 {
		di as error "ProficientOrAbove_percent values can be derived. See output in review folder."
		tab FILE DataLevel if der_profabvper_lev23 == 1
	}

//Levels 3-4
gen der_profabvper_lev34 = .

	replace der_profabvper_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ( ///
		(inlist(ProficientOrAbove_percent, "*", "--") & !inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--")) ///  
		| (inlist(ProficientOrAbove_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--")) ///  
		| (inlist(ProficientOrAbove_percent, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--")) ///
	)
	
	if StateAbbrev == "ME" & inlist(FILE, "2021", "2022") & Subject != "sci"{
		replace der_profabvper_lev34 = 1 if ProficiencyCriteria == "Levels 3-4" & ( ///
		(inlist(ProficientOrAbove_percent, "*", "--", "") & !inlist(Lev2_percent, "*", "--", "")
	)
	}

	count if der_profabvper_lev34 == 1
	if r(N) > 0 {
		di as error "ProficientOrAbove_percent values can be derived. See output in review folder."
		tab FILE DataLevel if der_profabvper_lev34 == 1
	}

//Levels 3-5
gen der_profabvper_lev35 = .

	replace der_profabvper_lev35 = 1 if ProficiencyCriteria == "Levels 3-5" & ( ///
		(inlist(ProficientOrAbove_percent, "*", "--") & !inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & !inlist(Lev5_percent, "*", "--")) ///  
		| (inlist(ProficientOrAbove_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--")) ///  
		| (inlist(ProficientOrAbove_percent, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--")) ///
	)

	count if der_profabvper_lev35 == 1
	if r(N) > 0 {
		di as error "ProficientOrAbove_percent values can be derived. See output in review folder."
		tab FILE DataLevel if der_profabvper_lev35 == 1
	}
	
//Levels 4-5
gen der_profabvper_lev45 = .

	replace der_profabvper_lev45 = 1 if ProficiencyCriteria == "Levels 4-5" & ( ///
		(inlist(ProficientOrAbove_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & !inlist(Lev5_percent, "*", "--")) ///  
		| (inlist(ProficientOrAbove_percent, "*", "--") & !inlist(Lev1_percent, "*", "--") & !inlist(Lev2_percent, "*", "--") & !inlist(Lev3_percent, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--")) ///  
		| (inlist(ProficientOrAbove_percent, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--")) ///
	)


//Summary
gen derive_profavb_per = .

	local derive_vars "der_profabvper_lev23 der_profabvper_lev34 der_profabvper_lev35 der_profabvper_lev45"

	foreach var of local derive_vars {
		cap replace derive_profavb_per = 1 if `var' == 1  
	}

	gsort -derive_profavb_per  
	count if derive_profavb_per == 1

	if r(N) > 0 {
		di as error "ProficientOrAbove_percent values can be derived. See output in review folder."
		
		tab FILE DataLevel if derive_profavb_per == 1  
	

		{
		preserve
		keep if derive_profavb_per == 1
		drop StateAbbrev StateFips  AssmtName AssmtType StateAssignedDistID  StateAssignedSchID  AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr 
		cap export excel using "${Review}/${StateAbbrev}_derive_profabvper_${date}.xlsx", firstrow(variables) replace
		restore	
		}
		
	}	
		
	else {
		di as error "No additional ProficientOrAbove_percent values can be derived."
		}
}



***********************************************************
*ProficientOrAbove_percent 

** • Are all rows free from any blanks?
{
local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has blank values in the following files. "
		tab DataLevel FILE if missing(`var')
	}
	
		preserve
		keep if missing(`var')
		cap drop StateAbbrev StateFips  StateAssignedDistID  StateAssignedSchID  AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr dup
		cap export excel using "${Review}/${StateAbbrev}_profaboveperc missing_${date}.xlsx", firstrow(variables) replace
		restore	
		}
		
	else {
	di as error "Correct."
	}
}

***********************************************************
*ProficientOrAbove_percent 

** • Are all values free of inequalities (< or >)?
{
local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	count if strpos(`var', ">") | strpos(`var', "<") 
	if r(N) !=0 {
		di as error "`var' has values with inequalities in the files below."
		tab DataLevel FILE if strpos(`var', ">") | strpos(`var', "<") 
	} 
	
		preserve
		keep if strpos(`var', ">") | strpos(`var', "<") 
		cap drop StateAbbrev StateFips  StateAssignedDistID  StateAssignedSchID  AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr dup 
		cap export excel using "${Review}/${StateAbbrev}_profaboveperc inequalities_${date}.xlsx", firstrow(variables) replace
		restore	
		}
		
	else {
	di as error "Correct."
	}
}

***********************************************************
*ProficientOrAbove_percent 

** • Are all values free of periods (.) where there should be -- or * instead?
{
local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	count if `var'=="."
	if r(N) !=0 {
		di as error "`var' has values appearing as periods (.) in the files below."
		tab `var' FILE if `var'== "."
	} 
		preserve
		keep if `var'=="."
		cap drop StateAbbrev StateFips  StateAssignedDistID  StateAssignedSchID  AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr dup 
		cap export excel using "${Review}/${StateAbbrev}_profaboveperc periods_${date}.xlsx", firstrow(variables) replace
		restore	
		}
		
	else {
	di as error "Correct."
	}
}

***********************************************************
*ProficientOrAbove_percent 

** • Are all rows free from negative numbers? // updated 10/6/24
{
local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	count if real(`var') < 0 & !missing(real(`var'))
	if r(N) !=0 {
		di as error "`var' has negative values in the files below."
		tab `var' FILE if real(`var') < 0 & !missing(real(`var'))
		
		preserve
		keep if real(`var') < 0 & !missing(real(`var'))
		cap drop StateAbbrev StateFips  StateAssignedDistID  StateAssignedSchID  AvgScaleScore  ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr dup 
		cap export excel using "${Review}/${StateAbbrev}_profaboveperc neg numbers_${date}.xlsx", firstrow(variables) replace
		restore	
		} 
	
	else {
		di as error "Correct."
		}
	
	}
}

***********************************************************
*ProficientOrAbove_percent 

** • Does the file include suppressed or missing data?

{
local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	
	//suppressed 
	count if `var' =="*"
	if r(N) !=0 {
		di as error "`var' has suppressed values in the files below."
		tab `var' FILE if `var' =="*"
	} 
	
		else {
		di as error "No, `var' does not have suppressed values."
		}	
	
	//missing
	count if `var' =="--"
	if r(N) !=0 {
		di as error "`var' has values indicated as missing (--) in the files below."
		tab `var' FILE if `var' =="--"
		
	else {
		di as error "No, `var' does not have missing values."
		}	
	}
}
}

***********************************************************
*ProficientOrAbove_percent 

** • Are there ranges in the variable?
** • If YES: Has this been noted in the CW?
** • If YES: Do the values make sense? (e.g., lower bound should not be higher than the upper bound)
{
local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	count if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	if r(N) !=0 {
		di as error "`var' has values with possible ranges in the files below."
		tab `var' FILE if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	} 
	
		else {
		di as error "No ranges."
		}	
	}	
}
**********************************************************
*ProficientOrAbove_percent 

** • Are all percents presented as decimals? [or decimal ranges] There should be no values below 0 or greater than 1. // updated 10/22/24

{
cap drop proforabove_p	ProficientOrAbove_percent1 ProficientOrAbove_percent2

local percents "ProficientOrAbove_percent"

foreach var of local percents {
    
	cap split `var', parse("-")
	cap replace `var'2 = `var'1 if (`var'2=="")
	
	cap gen `var'2 = ""
	cap replace `var'2 = `var'1 if (`var'2=="")
}

// Generating num values
	local percents2 "ProficientOrAbove_percent2"

	foreach var of local percents2 {
    
	destring `var', generate(`var'_n) ignore("*" & "--")

}

// Re-naming for brevity
	rename ProficientOrAbove_percent2_n proforabove_p

	
local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	
	count if (proforabove_p>1 | proforabove_p <0) & (`var' !="*") & (`var' !="--")
	if r(N) !=0 {
		di as error "`var' has values below 0 or greater than 1 in the files below. Check output in review folder."
		tab `var' if (proforabove_p>1 | proforabove_p <0) & (`var' !="*") & (`var' !="--")
	 
		preserve
		keep if (proforabove_p>1 | proforabove_p <0) & (`var' !="*") & (`var' !="--")
		keep FILE	State	SchYear	DataLevel	DistName	SchName	NCESDistrictID	NCESSchoolID	Subject	GradeLevel	StudentGroup	StudentGroup_TotalTested	StudentSubGroup	StudentSubGroup_TotalTested	Lev1_count	Lev1_percent	Lev2_count	Lev2_percent	Lev3_count	Lev3_percent	Lev4_count	Lev4_percent	Lev5_count	Lev5_percent	ProficiencyCriteria	ProficientOrAbove_count	ProficientOrAbove_percent

		cap export excel using "${Review}/${StateAbbrev}_check proforabv_pct_${date}.xlsx", firstrow(variables) replace
		restore	
		}
	
		else {
		di as error "Correct."
		}	
	}
}
***********************************************************

* AvgScaleScore
 
** • Are all rows free from any blanks or commas?
{
local errorBlanks 0    // Track blanks
local errorCommas 0    // Track commas
local errorPeriods 0    // Track periods
local errorInequalities 0 // Track inequalities
local avgss "AvgScaleScore"

foreach var of local avgss {
	
	//blanks
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has blank values in the files below."
		tab FILE if missing(`var')
		local errorBlanks 1
	}
	
	//commas
	count if strpos(`var', ",")
	if r(N) !=0 {
		di as error "`var' has values with commas in the files below."
		tab StudentGroup_TotalTested FILE if strpos(`var', ",")
		local errorCommas 1
	}
	
	
	//inequalities
	count if strpos(`var', ">") | strpos(`var', "<") 
	if r(N) !=0 {
		di as error "`var' has values with inequalities in the files below."
		tab AvgScaleScore FILE if strpos(`var', ">") | strpos(`var', "<") 
		local errorInequalities 1
	} 
	
	//periods
	count if `var'=="."
	if r(N) !=0 {
		di as error "`var' has values appearing as periods (.) in the files below."
		tab `var' FILE if `var'== "."
		local errorPeriods 1
	} 
	
	// Correct 
	if `errorBlanks' == 0 & `errorCommas' == 0 & `errorPeriods' == 0 & `errorInequalities' == 0 {
		di as error "Correct."
		}
	}
}
***********************************************************

*AvgScaleScore 

** • Does the file include suppressed (*) or missing (--) data ?
{
local avgss_nomiss "AvgScaleScore"

foreach var of local avgss_nomiss {
	count if `var' =="*"
	if r(N) !=0 {
		di as error "`var' has suppressed values in the files below."
		tab  FILE `var' if `var' =="*"
		} 
		
	else {
		di as error "No, `var' does not have suppressed (*) values."
		}	
		
		
	count if `var' =="--"
	if r(N) !=0 {
		di as error "`var' has values indicated as missing (--) in the files below."
		tab  FILE `var' if `var' =="--"
	} 
	
	else {
		di as error "No, `var' does not have missing (--) values."
		}
	}
}

***********************************************************
*AvgScaleScore

** • Have low level count values been reviewed for irregularities?
tab AvgScaleScore FILE if AvgScaleScore<"10"

***********************************************************
*AvgScaleScore 

** • Do all values make sense?
tab AvgScaleScore

****************************************************************************************
****************************************************************************************
** H. PARTICIPATION RATE
****************************************************************************************
****************************************************************************************

* ParticipationRate 
 
** • Are all rows free from any blanks or inequalities (< or >)?
{
local errorBlanks 0    // Track blanks
local errorInequalities 0 // Track inequalities
local errorPeriods 0    // Track periods
local part_rate "ParticipationRate"

foreach var of local part_rate {
	
	//blanks
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. Any missing values should be replaced with the string -- or * if it is suppressed."
		tab FILE if missing(`var')
		local errorBlanks 1
	}
	
	//inequalities
	count if strpos(`var', ">") | strpos(`var', "<") 
	if r(N) !=0 {
		di as error "`var' has values with inequalities in the files below."
		tab AvgScaleScore FILE if strpos(`var', ">") | strpos(`var', "<") 
		local errorInequalities 1
	} 

	//periods 
	count if `var'=="."
	if r(N) !=0 {
		di as error "`var' has values appearing as periods (.) in the files below."
		tab `var' FILE if `var'== "."
		local errorPeriods 1
	}
	// Correct 
	if `errorBlanks' == 0  & `errorInequalities' == 0 & `errorPeriods' == 0 {
		di as error "Correct."
		}
	}
}

***********************************************************
*ParticipationRate 

** • Does the file include suppressed (*) or missing (--) data ?
{
local part_nomiss "ParticipationRate"

foreach var of local part_nomiss {
	count if `var' =="*"
	if r(N) !=0 {
		di as error "Yes, `var' has suppressed values in the files below."
		tab  FILE `var' if `var' =="*"
	} 
	
	else {
		di as error "No, `var' does not have suppressed (*) values."
		}
		
	count if `var' =="--"
	if r(N) !=0 {
		di as error "Yes, `var' has values indicated as missing (--) in the files below."
		tab  FILE `var' if `var' =="--"
	} 
	
	else {
		di as error "No, `var' does not have missing (--) values."
		}
	}
	
}

***********************************************************
*ParticipationRate 

** • Are there ranges in the variable?
** • If YES: Has this been noted in the CW?
** • If YES: Do the values make sense? (e.g., lower bound should not be higher than the upper bound)
{
local part_nomiss "ParticipationRate"

foreach var of local part_nomiss {
	count if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	if r(N) !=0 {
		di as error "`var' has values with possible ranges in the files below."
		tab `var' FILE if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
		tab `var' Subject if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
		tab `var' DataLevel if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	} 
	
	else {
		di as error "No ranges."
		}
	}	
}
**********************************************************
*ParticipationRate 

** • Are all percents presented as decimals? [or decimal ranges] There should be no values below 0 or greater than 1.
{
local part "ParticipationRate"

foreach var of local part {
	count if (real(`var') < 0 | real(`var') > 1.01) & !missing(real(`var'))
	if r(N) !=0 {
		di as error "`var' has values greater than 1 or less than 0 in the files below."
		tab `var' FILE if (real(`var') < 0 | real(`var') > 1.01) & !missing(real(`var'))
	} 
	
	else {
		di as error "Correct."
		}	
	}
}
** ParticipationRate 

** • Have ParticipationRate values across years been reviewed to ensure that irregularities have already been flagged?
	
tab ParticipationRate FILE 

sort ParticipationRate 

**********************************************************
**********************************************************
** I. ASSESSESSMENT CLASSIFICATION & FLAGS
**********************************************************
**********************************************************

*AssmtType 

** • Are all values either "Regular" or "Regular and alt"?
** • If there are other values, please indicate what needs to be dropped.
	
* Checking subgroup values for AssmtType

{
count if !inlist(AssmtType, "Regular", "Regular and alt")
	if r(N)>0 {
		di as error "Check AssmtType values. AssmtType should == 'Regular' or 'Regular and alt''"
		tab AssmtType FILE if !inlist(AssmtType, "Regular", "Regular and alt")
	}
	
	else {
		di as error "Correct."
		}
}
**********************************************************
*AssmtType 

** • Does the AssmtType in the CW align with what is provided in the data files?
{
tab  FILE AssmtType if  Subject == "ela"
tab  FILE AssmtType if Subject == "math"
tab  FILE AssmtType if Subject == "sci"
tab  FILE AssmtType if Subject == "soc"

di as error "Review CW to ensure that data aligns."
}
**********************************************************
*AssmtName 

** • If the state uses the same assmt name, is the naming convention consistent across years?
tab  AssmtName FILE

**********************************************************
*AssmtName 

** • Does the ELA/math assessment name align with the CW across years?
{
tab SchYear AssmtName if Subject =="ela"  
tab SchYear DataLevel  if Subject =="ela"  

tab SchYear AssmtName if Subject =="math"  
tab SchYear DataLevel  if Subject =="math" 
}
**********************************************************
*AssmtName 

** • Does the sci assessment name align with the CW across years?
{
tab SchYear AssmtName if Subject =="sci"  
tab SchYear DataLevel  if Subject =="sci"  
}
**********************************************************
*AssmtName 

** • Does the soc assessment name align with the CW across years?
{
tab SchYear AssmtName if Subject =="soc"  
tab DataLevel SchYear if Subject =="soc"  
}
**********************************************************
*AssmtName 

** • Has the 2024 assmt name been verified for ELA/math? 
** • Has the 2024 assmt name been verified for sci? 
** • Has the 2024 assmt name been verified for soc? 
di as error "Review data file or documentation to verify assessment name for 2024."

***********************************************************
** Flag_AssmtNameChange	

** • Does the ELA name flag align with the CW across years?
{
tab  FILE AssmtName if Subject == "ela" 
tab  FILE Flag_AssmtNameChange if Subject == "ela" 
}

{
tab  FILE AssmtName if Subject == "math"
tab  FILE Flag_AssmtNameChange if Subject == "math"
}
***********************************************************
** Flag_AssmtNameChange	

** • Does the sci assessment name flag align with the CW across years?
{
tab  FILE AssmtName if Subject == "sci"
tab  FILE Flag_AssmtNameChange if Subject == "sci"
}

***********************************************************
** Flag_AssmtNameChange	

** • Does the soc assessment name flag align with the CW across years?
{
tab  FILE AssmtName if Subject == "soc"
tab  FILE Flag_AssmtNameChange if Subject == "soc"
}
***********************************************************
** Flag_AssmtNameChange	

** • Are all values either "Y" or "N"?
{
count if !inlist(Flag_AssmtNameChange, "Y", "N")
	if r(N)>0 {
		di as error "Check Flag_AssmtNameChange values. Values should only == 'Y' or 'N.''"
		tab Flag_AssmtNameChange FILE if !inlist(Flag_AssmtNameChange, "Y", "N")
	}
	
	else {
		di as error "Correct."
		}
}
***********************************************************
** • Are all CUT SCORE change flag values either "Y", "N", or "Not applicable"?
{
local cutscorech_flags "Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc"

foreach var of local cutscorech_flags {
	
	count if !inlist(`var', "Y", "N", "Not applicable")
	if r(N) > 0 {
		di as error "`var' has blank values in the following files."
		tab DataLevel FILE if inlist(`var', "")

	}
	
	else {
		di as error "`var' Correct."
		}
	}
}

***********************************************************
** Flag_CutScoreChange_ELA	
	
** • Do flags across all years align with what is in the crosswalk?
tab  FILE Flag_CutScoreChange_ELA 

***********************************************************
** Flag_CutScoreChange_math	
	
** • Do flags across all years align with what is in the crosswalk?
tab  FILE Flag_CutScoreChange_math 

***********************************************************
** Flag_CutScoreChange_sci
	
** • Do flags across all years align with what is in the crosswalk?
tab  FILE Flag_CutScoreChange_sci 

***********************************************************
** Flag_CutScoreChange_soc
	
** • Do flags across all years align with what is in the crosswalk?
tab  FILE Flag_CutScoreChange_soc 

***********************************************************
***********************************************************
** J. DOCUMENTATION REVIEW  
***********************************************************
***********************************************************
** • Does the dd document what grade levels are tested in SCIENCE, if applicable?
** • Does the dd document what grade levels are tested in SOCIAL STUDIES, if applicable?

tab Subject GradeLevel 
tab GradeLevel SchYear if Subject =="sci" 
tab GradeLevel SchYear if Subject =="soc"


