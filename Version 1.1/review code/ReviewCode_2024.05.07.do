***************************************
**	Updated May 7, 2024


** 	ZELMA STATE ASSESSMENT DATA REPOSITORY 
**	REVIEW CODE TEMPLATE


** Three things to select all and replace:

**	1. Wisconsin - Version 1.1 	// should be changed to the new state name. Be careful with spacing around the hyphen.
**	1. wi_assmtdata  			// should be changed to the new state abbrev  
**	3. wi_allyears 				// should be changed to the new state abbrev  

***************************************
clear
*** 1) Define csv files to include
cd "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1" // Save path to current folder in a local
di "`c(pwd)'" // Display path to current folder

local files : dir "`filepath'" files "*.csv" // Save name of all files in folder ending with .csv in a local
di `"`files'"' // Display list of files to import data from


*** 2) Loop over all files to import and append each file
tempfile master // Generate temporary save file to store data in
save `master', replace empty

foreach x of local files {
    di "`x'" // Display file name

	* 2A) Import each file and generate id var (filename without ".csv")
	qui: import delimited "`x'", delimiter("")  stringcols(9, 11, 17/34) case(preserve) clear // <-- Change delimiter() if vars are separated by "," or tab
	qui: gen id = subinstr("`x'", ".csv", "", .)
	
	* 2B) Append each file to masterfile
	*append using `master', force 
	*save `master', replace

	* 3) Save .csv files as new .dta files 
	save "`x'.dta", replace
}
***************************************
/*
* additional files that can be inserted as needed
"C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_assmtdata_2010.csv.dta"  "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_assmtdata_2011.csv.dta"  "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_assmtdata_2012.csv.dta"  "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_assmtdata_2013.csv.dta"  "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_assmtdata_2014.csv.dta"  
"C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_assmtdata_2015.csv.dta" 
*/


** Append files. Update based on appropriate years for each state. 
clear 
append using "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_assmtdata_2016.csv.dta" "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_assmtdata_2017.csv.dta" "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_assmtdata_2018.csv.dta" "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_assmtdata_2019.csv.dta" "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_assmtdata_2021.csv.dta" "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_assmtdata_2022.csv.dta" "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_assmtdata_2023.csv.dta", generate(id) force

generate n_all = _n 

sort id n_all
by id: generate n_yr = _n 


save "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta", replace empty

***********************************************************************************************************
***********************************************************************************************************
** A. VARIABLE ORGANIZATION
***********************************************************************************************************
***********************************************************************************************************

** Get a sense of the school years in the file and how that aligns with our data documentation (DD) and crosswalk (CW).
tab SchYear 

** • Are all variables included in the file?
** • Are all variables in the proper format (capitalization etc)?
local variables "id State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode"


foreach var of local variables {
capture confirm variable `var', exact
if !_rc {
                       di as txt "`var' exists"
               }
               else {
                       di as error "`var' does not exist or capitalization does not match. `var' must be added to dataset or capitalization fixed"
               }
}


***********************************************************************************************************

** • Are all variables in the correct order? (State, StateAbbrev, StateFips, etc)
local variables "id State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr"

ds
local vars=r(varlist)

if "`vars'"=="`variables'" {
	di as txt "Variables are in correct order"
}

else {
	di as error "Variables are not in correct order. Use the 'order' command with full list of variables above to reorder variables in file"
}
***********************************************************************************************************

** • Have EXTRA variables been removed from the file? (eg agency_ID and other vars not included in our file format)
** • Have the following vars been removed from the file?

     *- State_leaid  
     *- seasch   
     *- Flag_CutScoreChange_oth
     *- Flag_CutScoreChange_read"

local variables " State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode id n_all n_yr "

qui describe _all
di r(k)
if r(k) >50 {
	di as error "Too many variables"
}
if r(k)<50 {
	di as error "Missing variables" 
}

foreach var of varlist _all {
	if strpos("`variables'", "`var'")==0 {
		di as error "`var' is an extra variable" 
	}
}

***********************************************************************************************************

** • Is DataLevel sorted in the correct order?

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)

sort id DataLevel_n 
by id: generate n_testingdataorder = _n 

gen dataordercorrect =""
replace dataordercorrect="true" if n_yr == n_testingdataorder
replace dataordercorrect="false" if n_yr ~= n_testingdataorder

tab dataordercorrect // all should be true for this to be complete

***********************************************************************************************************
***********************************************************************************************************
** B. DIRECTORY VARIABLES 
***********************************************************************************************************
***********************************************************************************************************
** • Are all State rows free from any blanks?
** • Are all StateAbbrev rows free from any blanks?
** • Is StateFips free from any blanks?
** • Are all SchYear rows free from any blanks?
** • Are all DataLevel rows free from any blanks?

** All data levels (remove/ignore irrelevant flags)
local nomissing "State StateAbbrev StateFips SchYear DataLevel"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
	}
}
***********************************************************************************************************
** • Is the state name spelled correctly/capitalized?

tab  SchYear State // should be only one value.

***********************************************************************************************************

** • Is the correct state abbrev. used?

tab SchYear StateAbbrev // should be only one value.

***********************************************************************************************************

** • Is the same FIPS code used for all obs?
** • Is the correct FIPS code applied?

tab SchYear StateFips

***********************************************************************************************************

** • Are all years presented in the same format (e.g., 2020-21)?

levelsof SchYear, local(SchYear)
foreach year of local SchYear {
	if strpos("`year'", "-") != 5 {
		di as error "Check SchYear: `year' is in the wrong format."
	}
	if strlen("`year'") != 7 {
		di as error "Check SchYear: `year' is in the wrong format"
	}
}


***********************************************************************************************************

** • Are the only DataLevel values either State, District, or School?

tab SchYear DataLevel 

// scan for any years / data levels that may need a closer look (ie if numbers are greatly different from one year to the next)


***********************************************************************************************************
***********************************************************************************************************
** C. DISTRICT/SCHOOL - NAMES & TYPES 
***********************************************************************************************************
***********************************************************************************************************
** DistName 

clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"



// scan for district names over time 	
tab DistName SchYear 



** • Are all DistName rows free from any blanks?

local nomissing "DistName"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
	}
}

** • For all cases where DataLevel=State, does DistName = "All Districts"?

count if DistName != "All Districts" & DataLevel=="State"
	if r(N)>0 {
		di as error "The following rows need DistName='All Districts'"
		list row if DistName != "All Districts"
	}
	



** • Have extraneous spaces been removed from the district names?

// note: If the code below ends up changing any of the district names, this will need to be flagged for the data cleaner. Make sure to specify the years and command that will need to be used .

gen dname_test = DistName 
replace dname_test =stritrim(dname_test) // returns var with all consecutive, internal blanks collapsed to one blank.
*replace dname_test =strltrim(dname_test) // returns var with leading blanks removed.
*replace dname_test =strrtrim(dname_test) // returns s with trailing blanks removed.
replace dname_test =strtrim(dname_test) // returns s with leading and trailing blanks removed.


// if there are changes made:
gen dname_flag = .
replace dname_flag = 1 if DistName != dname_test 
order id State StateAbbrev StateFips SchYear DataLevel DistName dname_test dname_flag 

tab SchYear if dname_flag == 1 // to figure out school years 
tab DistName if dname_flag == 1 // to see list of district names 



***********************************************************************************************************
** DistType  


clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"
	
	
** • For all cases where DataLevel=District and DataLevel=School, are all rows free from any blanks?
local distsch_nomiss "DistType"

foreach var of local distsch_nomiss {
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var' in District and School level data."
	}	
}


// to scan for school years that have missing values 
tab SchYear if DistType=="" & DataLevel=="District"
tab SchYear if DistType=="" & DataLevel=="School"


** • For all cases where DataLevel= is State, are all rows blank?
local distsch_nomiss "DistType"

foreach var of local distsch_nomiss {
	
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data."
	}	
}


// scan DistType 
tab SchYear DistType 
***********************************************************************************************************
clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

** SchName   

** • Are all SchName rows free from any blanks?

local nomissing "SchName"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
	}
}


** • For all cases where DataLevel=State, does SchName = "All Schools"?
** • For all cases where DataLevel=District, does SchName = "All Schools"?	
count if SchName != "All Schools" & DataLevel!="School"
	if r(N)>0 {
		di as error "The following rows need SchName='All Schools'"
		list row if SchName != "All Schools"
	}
	
***********************************************************************************************************
clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

** SchType   

** • For all cases where DataLevel= School, are all rows free from any blanks?

local sch_nomiss "SchType "

foreach var of local sch_nomiss {
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var' in School level data."
	}

}


** • NEW. For all cases where DataLevel= is not School, are all rows blank?

local sch_nomiss "SchType"

foreach var of local sch_nomiss {

	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state or district level data."
	}
}	

***********************************************************************************************************
***********************************************************************************************************
** D. DISTRICT/SCHOOL IDS 
***********************************************************************************************************
***********************************************************************************************************

clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

*NCESDistrictID 


** • For all cases where DataLevel=District and DataLevel=School, are all rows free from any blanks?
local distsch_nomiss "NCESDistrictID"

foreach var of local distsch_nomiss {
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var' in District and School level data."
	}	
}

** • Are all IDs in the correct format / 7 digits?

if StateFips<10 {
	**Check the following NCESDistrictIDs: current values are too short**

	tab NCESDistrictID if NCESDistrictID<100000
}

if StateFips>10 {
	**Check the following NCESDistrictIDs: current values are too short**
	
	tab NCESDistrictID if NCESDistrictID<1000000 

}


** • Is there only 1 NCES district ID per state-assigned district ID?

bysort NCESDistrictID (StateAssignedDistID) : gen flag1 = StateAssignedDistID[1] != StateAssignedDistID[_N]  
bysort StateAssignedDistID (NCESDistrictID) : gen flag2 = NCESDistrictID[1] != NCESDistrictID[_N]

if flag1>0 | flag2>0 {
	di as error "Below districts have mismatched NCESDistrictID and StateAssignedDistID"
	tab NCESDistrictID if flag1==1
	tab StateAssignedDistID if flag2==1
	
}

// extra checks 
tab SchYear if flag1==1 
tab SchYear if flag2==1 

// if there are observations flagged, identify the issue and flag for data cleaner (specific districts? specific years?)


***********************************************************************************************************	
clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

*StateAssignedDistID

** • For all cases where DataLevel=State, are all StateAssignedDistID values blank?

local distsch_nomiss "StateAssignedDistID"

foreach var of local distsch_nomiss {
	
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data."
	}	
}


** • For all cases where DataLevel=District and DataLevel=School, are all rows free from any blanks?

local distsch_nomiss "StateAssignedDistID"

foreach var of local distsch_nomiss {
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var' in District and School level data."
	}	
}

tab SchYear DataLevel if DataLevel !="State" & StateAssignedDistID==.

** • Do IDs align with the original data? (Spot-check 5 to 10 data points)

tab SchYear StateAssignedDistID 

***********************************************************************************************************	
clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

*NCESSchoolID 

** • For all cases where DataLevel= School, are all rows free from any blanks?
local schid_nomiss "NCESSchoolID"

foreach var of local schid_nomiss {
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var' in School level data."
	}

}

// extra check 
tab SchYear if NCESSchoolID==. & DataLevel=="School"


** • NEW. For all cases where DataLevel= is not School, are all rows blank?

local schid_nomiss "NCESSchoolID"

foreach var of local sch_nomiss {

	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state or district level data."
	}
}	



** • Are all IDs in the correct format / 12 digits?

if StateFips<10 {
	**Check the following NCESSchoolIDs and NCESDistrictIDs: current values are too short**
	tab NCESSchoolID if NCESSchoolID<10000000000 & DataLevel=="School"
	
}

if StateFips>10 {
	**Check the following NCESSchoolIDs and NCESDistrictIDs: current values are too short**
	
	tab NCESSchoolID if NCESSchoolID<100000000000 & DataLevel=="School"

}


** • Does the NCESDistrictID match the first 7 digits of the NCESSchoolID?

gen tempD= NCESDistrictID
gen tempS=floor(NCESSchoolID/100000)
di as error "First digits of NCESSchoolID for the below schools don't match NCESDistrictID"
tab NCESSchoolID if tempS != tempD & DataLevel=="School"
drop temp*


** • Is there only 1 NCES schoolID per state-assigned school ID?
drop flag1 flag2

bysort NCESSchoolID (StateAssignedSchID) : gen flag1 = StateAssignedSchID[1] != StateAssignedSchID[_N]  
bysort StateAssignedSchID (NCESSchoolID) : gen flag2 = NCESSchoolID[1] != NCESSchoolID[_N]

if flag1>0 | flag2>0 {
	di as error "Below schools have mismatched NCESSchoolID and StateAssignedSchID"
	tab NCESSchoolID if flag1==1
	tab StateAssignedSchID if flag2==1
}


// extra checks 
tab SchYear if flag1==1 
tab SchYear if flag2==1 

tab NCESSchoolID if flag1==1 
keep if flag1==1 

// If there are observations flagged, identify the issue and flag for data cleaner (specific districts? specific years?)
// For example, it may help to focus on the specific cases flagged:

format NCESSchoolID %18.0g	
keep if flag1==1
keep State SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID flag1 
sort NCESSchoolID SchYear 
duplicates drop 

// State notes here.
// Illinois - 2022 and onward - NCESSchoolID 53090102002 uses StateAssignedSchID 530901020022003 instead of 530901020021003 as in years back to 2015. Should verify that this is correct. 

***********************************************************************************************************	
clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

*StateAssignedSchID 

** • For all cases where DataLevel= School, are all rows free from any blanks?
local stschid_nomiss "StateAssignedSchID"

foreach var of local stschid_nomiss {
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var' in School level data."
	}

}

// extra checks 
tab SchYear if StateAssignedSchID=="" & DataLevel=="School"



** • NEW. For all cases where DataLevel= is not School, are all rows blank?

local stschid_nomiss "StateAssignedSchID"

foreach var of local stschid_nomiss {

	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state or district level data."
	}
}	


***********************************************************************************************************
***********************************************************************************************************
** E. NCES CHARACTERISTICS
***********************************************************************************************************
***********************************************************************************************************
clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"


*DistCharter 


// get a sense of the values used for this variable over time / make sure values look appropriate 
tab SchYear DistCharter 


** • For all cases where DataLevel=District and DataLevel=School, are all rows free from any blanks?
** • For all cases where DataLevel=District and DataLevel=School, are the only values either Yes or No?

count if DistCharter != "Yes" & DistCharter != "No" & DataLevel != "State"
if r(N) > 0 {
	di as error "DistCharter has values other than Yes and No in district or school data"
	tab DistCharter
}

// if there is an error, scan values 
tab SchYear DistCharter 

// if the values are only yes or no, scan years for missing values 

tab SchYear DistName if DistCharter=="" & DataLevel !="State"


** • For all cases where DataLevel= is State, are all rows blank?
local distsch_nomiss "DistCharter"

foreach var of local distsch_nomiss {
	
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data."
	}	
}


***********************************************************
*DistLocale 

** • For all cases where DataLevel=District and DataLevel=School, are all rows free from any blanks?
local distloc_nomiss "DistLocale"

foreach var of local distloc_nomiss {
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var' in School level data."
	}

}

** • NEW. For all cases where DataLevel= is State, are all rows blank?
local distloc_miss "DistLocale"

foreach var of local distloc_miss {
	
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data."
	}	
}

** • For all cases where DataLevel=District and DataLevel=School, are the values appropriate?
tab DistLocale

// review all values to make sure there are no unexpected values 

***********************************************************

clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

// scan values 
tab SchYear SchLevel 
tab SchYear SchVirtual 

*SchLevel and SchVitual 

** • For all cases where DataLevel= School, are all rows free from any blanks?

local sch_nomiss "SchLevel SchVirtual"

foreach var of local sch_nomiss {
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var' in School level data."
	}

}

// if there are values of Missing/not reported:

tab DataLevel SchYear if SchLevel == "Missing/not reported"
tab DataLevel SchYear if SchVirtual == "Missing/not reported"

// verify where the issues are and flag for data cleaner. try to be as specific as possible. Particularly want to see if we can update cases for 2023. Add additional code as needed to investigate these cases / add notes.


** • NEW. For all cases where DataLevel= is not School, are all rows blank?

local sch_nomiss "SchLevel SchVirtual"

foreach var of local sch_nomiss {

	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state or district level data."
	}
}	

tab SchYear SchLevel 
tab SchYear SchVirtual  
format NCESSchoolID %18.0g

/*
Additional code if needed to look at 2023. 

keep if SchYear=="2022-23"
keep if SchLevel=="Missing/not reported" | SchVirtual =="Missing/not reported" 

keep SchYear NCESSchoolID NCESDistrictID DistName SchName SchLevel SchVirtual
duplicates drop 
*/

***********************************************************
* CountyName and CountyCode 

clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"


** • For all cases where DataLevel=District and DataLevel=School, are all rows free from any blanks?

local cty_nomiss "CountyName CountyCode"

foreach var of local cty_nomiss {
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var' in District and School level data."
	}

}

** • For all cases where DataLevel=State, are all rows blank?

local cty_nomiss "CountyName CountyCode"

foreach var of local cty_nomiss {
	
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data."
	}	
}


** • Is there just one county code per county name? 
 
bysort CountyName (CountyCode) : gen flag1 = CountyCode[1] != CountyCode[_N]  
bysort CountyCode (CountyName) : gen flag2 = CountyName[1] != CountyName[_N] 
 

if flag1>0 | flag2>0 {
	di as error "Below schools have mismatched CountyName and CountyCode"
	tab CountyName if flag1==1
	tab CountyCode if flag2==1
}

// extra checks 
tab CountyName if flag1==1 
tab CountyName if flag2==1 


** • Have county names through 2015 been changed to proper case?

tab CountyName SchYear 


/* Code to update county names, if needed
replace CountyName = proper(CountyName) 
tab CountyName SchYear 
*/ 

// It may be that just a few county names could be updated. See below for example code 
/*
replace CountyName = "Sumter County" if NCESDistrictID==100199
tab CountyName SchYear 
*/

// checking missing/not reported for 2023
keep State StateAbbrev StateFips SchYear DataLevel DistName  NCESDistrictID   CountyName CountyCode
duplicates drop 

//If there are missing values for CountyName:

drop if DataLevel=="State"
keep if CountyName==""
keep id State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID  NCESSchoolID  CountyName CountyCode 
duplicates drop 

***********************************************************************************************************
***********************************************************************************************************
** F. ASSESSMENT DETAILS 
***********************************************************************************************************
***********************************************************************************************************
clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"


*AssmtName 

** • Is only one Assessment Name listed per school year per assessment (it may be the case that ELA and science have different names)?
** • Aggregating files across years: If the state uses the same assmt name, is the naming convention consistent across years?


// look within each subject 
tab SchYear AssmtName if Subject =="ela"  
tab SchYear AssmtName if Subject =="math"  
tab SchYear AssmtName if Subject =="sci"  
tab SchYear AssmtName if Subject =="soc"  

// look at subject x assmtname 
tab  Subject AssmtName 

// look at assmtname x subject
tab SchYear AssmtName  


** • Are all rows free from any blanks?

local nomissing "AssmtName"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
	}
}

***********************************************************
*AssmtType 

** • Does the AssmtType in the CW align with what is provided in the data files?

tab AssmtType SchYear // check CW and DD 



** • Are all rows free from any blanks?

local nomissing "AssmtType"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
	}
}

***********************************************************
*Subject 

** • Is "ela" the subject for all states except for AR and GA, which have both "ela" and "read"?
** • Are subjects listed as ela, math, sci, eng, read, wri, stem, soc? (eg not "reading" "science" etc) 


count if !inlist(Subject, "ela" "math" "sci" "eng" "wri" "stem" "soc")
	if r(N)>0 {
		di as error "Check Subject values are abbreviated appropriately. Only AR and GA should have 'read' as a subject."
		tab Subject
	}

// check subjects across years 
tab Subject SchYear 
tab Subject SchYear  if DataLevel=="State" 
tab Subject SchYear  if DataLevel=="District" 
tab Subject SchYear  if DataLevel=="School" 

// complete additional checks as warranted.

***********************************************************
clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

*GradeLevel 

** • Are all rows free from any blanks?

local nomissing "GradeLevel"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
	}
}

** • Are grades listed as G03, G04 etc and not 3, 4?

tab GradeLevel Subject // verify all values are correct 


** • If G38 is included (aggregated data for Grades 3-8), has it been confirmed that this only includes Grades 3-8 and not high school grades?
if GradeLevel== "G38" {
 	di as error "Please confirm that this data includes only data for Grades 3-8 and NOT any high school grades."
 }


** • If there is aggregated grade 3-8 data in the original data, has it been incorporated into the data file?

// verify 

***********************************************************
clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

*StudentGroup 

** • Have new subgroups been added to the files, if available?
** • For Alabama, Connecticut, Michigan: Have data for the StudentGroup "Ethnicity" been moved to "Race" instead?
** • Has the Ethnicity student group been removed?
** • Do all labels follow the standardized naming convention? 

 count if !inlist(StudentGroup, "All Students", "RaceEth", "EL Status", "Gender", "Economic Status") & !inlist(StudentGroup, "Disability Status", "Migrant Status", "Homeless Enrolled Status", "Foster Care Status", "Military Connected Status")
 if r(N)>0 {
 	di as error "Check StudentGroup values. StudentGroup should only contain the following values: 'All Students' 'RaceEth' 'EL Status' 'Gender' 'Economic Status' 'Disability Status' 'Migrant Status' 'Homeless Enrolled Status' 'Foster Care Status' 'Military Connected Status'"
 	tab StudentGroup
 }


** • Are all rows free from any blanks?

local nomissing_sg "StudentGroup"

foreach var of local nomissing_sg {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
	}
}

// if StudentGroup has missing values 

tab SchYear if StudentGroup==""
tab StudentSubGroup if StudentGroup==""

// verify missingness and provide specific feedback to data cleaner 

***********************************************************
clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

*StudentGroup_TotalTested 

** • Are all rows free from any blanks?

local nomissing "StudentGroup_TotalTested"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
	}
}

** • Do all values make sense?
tab StudentGroup_TotalTested // review values 
tab SchYear StudentGroup_TotalTested if StudentGroup_TotalTested < "1" // review low values. May need to check against original data.

// if there are values of "--" or "*" to review 
tab SchYear StudentGroup_TotalTested if  StudentGroup_TotalTested == "--" | StudentGroup_TotalTested == "*"
tab SchYear StudentGroup_TotalTested if  StudentGroup_TotalTested == "--" & Subject =="ela"
tab SchYear StudentGroup_TotalTested if  StudentGroup_TotalTested == "--" & Subject =="math"
tab SchYear StudentGroup_TotalTested if  StudentGroup_TotalTested == "--" & Subject =="sci" 

tab SchYear StudentGroup_TotalTested if  StudentGroup_TotalTested == "*" 
tab SchYear StudentGroup_TotalTested if  StudentGroup_TotalTested == "*" & Subject =="ela"
tab SchYear StudentGroup_TotalTested if  StudentGroup_TotalTested == "*" & Subject =="math"
tab SchYear StudentGroup_TotalTested if  StudentGroup_TotalTested == "*" & Subject =="sci" 


** • Has the "All Students" value been applied to other student groups, where missing?

// review Data Editor

************************************************************************************************************

clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

*StudentSubGroup

// Getting an overview 
tab StudentGroup StudentSubGroup if StudentGroup =="All Students" 
tab StudentSubGroup StudentGroup if StudentGroup =="RaceEth" 
tab StudentSubGroup StudentGroup  if StudentGroup =="Gender" 
tab StudentSubGroup StudentGroup  if StudentGroup =="EL Status" 
tab StudentSubGroup StudentGroup  if StudentGroup =="Economic Status" 
tab StudentSubGroup StudentGroup  if StudentGroup =="Disability Status" 
tab StudentSubGroup StudentGroup  if StudentGroup =="Homeless Enrolled Status" 
tab StudentSubGroup StudentGroup  if StudentGroup =="Foster Care Status"  
tab StudentSubGroup StudentGroup  if StudentGroup =="Military Connected Status" 
tab StudentSubGroup StudentGroup  if StudentGroup =="Migrant Status" 


* Checking subgroup values for StudentGroup == "All Students"
count if StudentGroup=="All Students" & !inlist(StudentSubGroup, "All Students")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'All Students' if StudentGroup=='All Students'"
		tab StudentSubGroup if StudentGroup=="All Students"
	}

* Checking subgroup values for StudentGroup == "EL Status"
count if StudentGroup=="EL Status" & !inlist(StudentSubGroup, "English Learner", "English Proficient", "EL Exited", "EL Monit or Recently Ex", "EL and Monit or Recently Ex", "LTEL", "Ever EL")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'English Learner', 'English Proficient', 'EL Exited', 'EL Monit or Recently Ex', 'EL and Monit or Recently Ex', 'LTEL', 'Ever EL' if StudentGroup=='EL Status'"
		tab StudentSubGroup if StudentGroup=="EL Status"
	}

* Checking subgroup values for StudentGroup == "Gender"
count if StudentGroup=="Gender" & !inlist(StudentSubGroup, "Male", "Female", "Gender X", "Unknown") 
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Male', 'Female', 'Gender X' or 'Unknown' if StudentGroup=='Gender'"
		tab StudentSubGroup if StudentGroup=="Gender"
	}

* Checking subgroup values for StudentGroup == "Economic Status"
count if StudentGroup=="Economic Status" & !inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Economically Disadvantaged' or 'Not Economically Disadvantaged' if StudentGroup=='Economic Status'"
		tab StudentSubGroup if StudentGroup=="Economic Status"
	}

* Checking subgroup values for StudentGroup == "Disability Status"
count if StudentGroup=="Disability Status" & !inlist(StudentSubGroup, "SWD", "Non-SWD")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'SWD' and 'Non-SWD' if StudentGroup=='Economic Status'"
		tab StudentSubGroup if StudentGroup=="Disability Status"
	}

* Checking subgroup values for StudentGroup == "Migrant Status"
count if StudentGroup=="Migrant Status" & !inlist(StudentSubGroup, "Migrant", "Non-Migrant")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Migrant' or 'Non-Migrant' if StudentGroup=='Migrant Status'"
		tab StudentSubGroup if StudentGroup=="Migrant Status"
	}

* Checking subgroup values for StudentGroup == "Homeless Enrolled Status"
count if StudentGroup=="Homeless Enrolled Status" & !inlist(StudentSubGroup, "Homeless", "Non-Homeless")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Homeless' or 'Non-Homeless' if StudentGroup=='Homeless Status'"
		tab StudentSubGroup if StudentGroup=="Homeless Status"
	}

* Checking subgroup values for StudentGroup == "Foster Care Status"
count if StudentGroup=="Foster Care Status" & !inlist(StudentSubGroup, "Foster Care", "Non-Foster Care")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Foster Care' or 'Non-Foster Care' if StudentGroup=='Foster Care Status'"
		tab StudentSubGroup if StudentGroup=="Foster Care Status"
	}
	
* Checking subgroup values for StudentGroup == "Military Connected Status"	
count if StudentGroup=="Military Connected Status" & !inlist(StudentSubGroup, "Military", "Non-Military")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Military' or 'Non-Military' if StudentGroup=='Military Connected Status'"
		tab StudentSubGroup if StudentGroup=="Military Connected Status"
	}

	
* Checking subgroup values for StudentGroup == "RaceEth"	
gen raceeth_chk = .
replace raceeth_chk = 1 if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander"| StudentSubGroup == "Two or More" | StudentSubGroup =="White"| StudentSubGroup == "Hispanic or Latino" | StudentSubGroup =="Unknown" | StudentSubGroup =="Not Hispanic or Latino" | StudentSubGroup =="Filipino"


count if StudentGroup=="RaceEth" & !inlist(raceeth_chk, 1)
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'American Indian or Alaska Native', 'Asian', 'Black or African American', 'Native Hawaiian or Pacific Islander', 'Two or More', 'White', 'Hispanic or Latino', 'Unknown' 'Not Hispanic', 'Filipino' if StudentGroup=='RaceEth'"
		tab StudentSubGroup if StudentGroup=="RaceEth"
	}
	

// if incorrect values, check SchYear and any other information to provide to data cleaner. 
tab SchYear if StudentSubGroup == 
	
	
***********************************************************
*StudentSubGroup_TotalTested

** • Are all rows free from any blanks?

local nomissing "StudentSubGroup_TotalTested"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
	}
}

** • Do all values make sense?
tab StudentSubGroup_TotalTested // review values 
tab SchYear StudentSubGroup_TotalTested if StudentSubGroup_TotalTested < "1" // review low values. May need to check against original data.

// if there are values of "--" or "*" to review 
tab SchYear StudentSubGroup_TotalTested if  StudentSubGroup_TotalTested == "--" | StudentGroup_TotalTested == "*"
tab SchYear StudentSubGroup_TotalTested if  StudentSubGroup_TotalTested == "--" & Subject =="ela"
tab SchYear StudentSubGroup_TotalTested if  StudentSubGroup_TotalTested == "--" & Subject =="math"
tab SchYear StudentSubGroup_TotalTested if  StudentSubGroup_TotalTested == "--" & Subject =="sci" 

tab SchYear StudentSubGroup_TotalTested if  StudentSubGroup_TotalTested == "*" 
tab SchYear StudentSubGroup_TotalTested if  StudentSubGroup_TotalTested == "*" & Subject =="ela"
tab SchYear StudentSubGroup_TotalTested if  StudentSubGroup_TotalTested == "*" & Subject =="math"
tab SchYear StudentSubGroup_TotalTested if  StudentSubGroup_TotalTested == "*" & Subject =="sci" 

// additional checks

tab StudentSubGroup_TotalTested if StudentSubGroup_TotalTested<"10" 

tab SchYear if StudentSubGroup_TotalTested=="--"
tab SchYear if StudentSubGroup_TotalTested=="*"




** • Does the "All Students" value for StudentSubGroup_TotalTested = the "All Students" value for StudentGroup_TotalTested?
gen allstudents_flag = .
replace allstudents_flag = 1 if (StudentGroup=="All Students") & (StudentSubGroup=="All Students")

gen allstudentsvalue_check = ""
replace allstudentsvalue_check = "true" if (allstudents_flag==1) & (StudentGroup_TotalTested == StudentSubGroup_TotalTested)
replace allstudentsvalue_check = "false" if (allstudents_flag==1) & (StudentGroup_TotalTested ~= StudentSubGroup_TotalTested)

gsort -allstudentsvalue_check

tab DataLevel if allstudentsvalue_check=="false"
tab SchName if allstudentsvalue_check=="false"
tab DistName if allstudentsvalue_check=="false"

// if there are errors, investigate the years / observations to provide specific feedback to the data cleaner.


****************************************************************************************
****************************************************************************************
** G. PROFICIENCY DATA
****************************************************************************************
****************************************************************************************
clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

*ProficiencyCriteria

** • Does this variable clearly state which levels are included in the proficiency definition

tab SchYear ProficiencyCriteria
tab  ProficiencyCriteria Subject


** • NEW. Is the new naming convention used across all files/subjects? ("Levels 3-4"  vs. "Lev 3-4" or "Levels 3 and 4", for example)

if substr(ProficiencyCriteria,1,6) != "Levels" | substr(ProficiencyCriteria,9,1) != "-" {
	di as error "Formatting for ProficiencyCriteria is not correct"
}


***********************************************************

* Level counts 

clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

// Look at proficiency criteria to see which levels are used for the state 
// Check CW to see what levels to expect 

tab ProficiencyCriteria 

** • Are commas removed from all level counts?
count if strpos(Lev1_count, ",")
count if strpos(Lev2_count, ",")
count if strpos(Lev3_count, ",")
count if strpos(Lev4_count, ",")
count if strpos(Lev5_count, ",") // may not be applicable to the state 

** • Have extra spaces been removed from all level counts?
count if strpos(Lev1_count, " ")
count if strpos(Lev2_count, " ")
count if strpos(Lev3_count, " ")
count if strpos(Lev4_count, " ")
count if strpos(Lev5_count, " ") // may not be applicable to the state 

** • Do all values make sense? 
tab Lev1_count
tab Lev2_count
tab Lev3_count
tab Lev4_count
tab Lev5_count // may not be applicable to the state 

// additional checks for looking at level data 
sort Lev1_count
sort Lev2_count
sort Lev3_count
sort Lev4_count
sort Lev5_count

** • Are all rows free from any blanks? (as applicable)
local levels_nomiss "Lev1_count  Lev2_count Lev3_count  Lev4_count Lev5_count"

foreach var of local levels_nomiss {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. Any missing values for level counts or percents should be replaced with the string -- or * if it is suppressed."
	}
}


** • If the data are SUPPRESSED in the original data, is it reflected with * ? 
** • If the data are MISSING in the original data, is it reflected with --? 

tab Lev1_count if Lev1_count <"10" // mix of -- and ranges 
tab Lev2_count if Lev2_count <"10" // mix of -- and ranges 
tab Lev3_count if Lev3_count <"10" // mix of -- and ranges 
tab Lev4_count if Lev4_count <"10" // mix of -- and ranges 
*tab Lev5_count if Lev5_count <"10" // mix of *, --, and 0 // may not be applicable to the state


// additional checks 
tab Lev1_count SchYear if Lev1_count=="--" // used across all years 
tab Lev1_count SchYear if Lev1_count=="*" // used across all years 

// to sort by level counts 
sort Lev1_count Lev2_count Lev3_count Lev4_count 

gsort -Lev1_count 

// to look at low values 
tab StudentSubGroup_TotalTested if StudentSubGroup_TotalTested=="<=15"
tab StudentSubGroup_TotalTested if StudentSubGroup_TotalTested=="<=15" 

tab SchYear Subject if StudentSubGroup_TotalTested=="<= 15"



***********************************************************
clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

* Level percents  

** • Are all rows free from any blanks? (as applicable)
local levels_nomiss "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levels_nomiss {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. Any missing values for level counts or percents should be replaced with the string -- or * if it is suppressed."
	}
}


** • Are percents completed to the extent possible?

// sorting to look at data in Data Editor 

*sort Lev1_percent 
sort Lev1_percent 
sort Lev2_percent 
sort Lev3_percent 
sort Lev4_percent 
sort Lev5_percent 

** • Are all percents presented as decimals? 
tab Lev1_percent 
tab Lev2_percent 
tab Lev3_percent 
tab Lev4_percent 
tab Lev5_percent 


** • Has it been confirmed that there are no cases where the percent across levels does not sum to over 101%?

// first converting level counts from string to num 
destring Lev1_percent, generate(Lev1_p) ignore("*" & "--" & "<") //added < for DE
destring Lev2_percent, generate(Lev2_p) ignore("*" & "--")
destring Lev3_percent, generate(Lev3_p) ignore("*" & "--")
destring Lev4_percent, generate(Lev4_p) ignore("*" & "--" & "<") //added < for DE
*destring Lev5_percent, generate(Lev5_p) ignore("*" & "--")

egen tot_percent=rowtotal(Lev*_percent)
gen row=_n

di as error "Below rows have percent total greater than 101%"
list row NCESSchoolID NCESDistrictID if tot_percent>1.01

// if there are many values, make the criteria slightly broader and then examine inconsistencies: 
di as error "Below rows have percent total greater than 101%"
list row NCESSchoolID NCESDistrictID if tot_percent>1.03

** • Cross-check low values - if there are cases where the percent across levels is <50%, please note observations for the original cleaner to check. 
di as error "Below rows have percent total lower than 50%"
list row NCESSchoolID NCESDistrictID if tot_percent<.50 & tot_percent !=0


/*
// to dig into this, it may be necessary to focus on certain cases, for example:

drop if tot == 0
drop if tot > .95
drop if ProficiencyCriteria=="Levels 3-5" 
drop if Subject == "sci"
*/


** • Do all values make sense? 
tab Lev1_p if Lev1_p>1 | Lev1_p <0
tab Lev2_p if Lev2_p>1 | Lev2_p <0
tab Lev3_p if Lev3_p>1 | Lev3_p <0
tab Lev4_p if Lev4_p>1 | Lev4_p <0
tab Lev5_p if Lev5_p>1 | Lev5_p <0



***********************************************************

*ProficientOrAbove_count 

clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"


** • Does this variable appropriate match the count of the proficiency levels described? (e.g., Levels 3+4?)

// NOTE: UPDATE CODE AS NEEDED FOR EACH STATE'S SUBJECT-AREA CRITERIA FOR A GIVEN YEAR.

** converting level counts from string to num 
destring Lev1_count, generate(Lev1_n) ignore("*" & "--")
destring Lev2_count, generate(Lev2_n) ignore("*" & "--")
destring Lev3_count, generate(Lev3_n) ignore("*" & "--")
destring Lev4_count, generate(Lev4_n) ignore("*" & "--")
destring Lev5_count, generate(Lev5_n) ignore("*" & "--")
destring ProficientOrAbove_count, generate(profcount_n) ignore("*" & "--")


// add applicable levels below 
tab  ProficiencyCriteria Subject
tab  ProficiencyCriteria SchYear

egen tot_count = rowtotal(Lev3_n Lev4_n Lev5_n)


// visually check new tot_count variable against ProficientOrAbove_count variable in Data Editor 
order id State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_n Lev1_percent Lev2_count Lev2_n Lev2_percent Lev3_count Lev3_n Lev3_percent Lev4_count Lev4_n Lev4_percent Lev5_count Lev5_n Lev5_percent AvgScaleScore ProficiencyCriteria tot_count ProficientOrAbove_count profcount_n

// checking how the 2 vars compare 
gen count_diff = (profcount_n - tot_count)

order id State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_n Lev1_percent Lev2_count Lev2_n Lev2_percent Lev3_count Lev3_n Lev3_percent Lev4_count Lev4_n Lev4_percent Lev5_count Lev5_n Lev5_percent AvgScaleScore ProficiencyCriteria tot_count ProficientOrAbove_count profcount_n count_diff

sort count_diff

// generate list of cases where there are differences 
tab count_diff 

list n_all NCESSchoolID NCESDistrictID if count_diff > 1 & count_diff !=. // investigate any obs. Each state may require a unique approach depending on available data. 

local profcountvars = "Lev3_n Lev4_n Lev5_n"


** • Are commas removed from all numbers if it is a string variable?

gen comma_flag =.
replace comma_flag = 1 if strpos(ProficientOrAbove_count , ",")!=0 
tab  SchYear if comma_flag == 1 

sort ProficientOrAbove_count

** • Do all values make sense? 

tab ProficientOrAbove_count
tab ProficientOrAbove_count if ProficientOrAbove_count<"10"


** • If it is possible to determine this count based on the available data, have those values been applied? (eg if the level counts are available in the raw data, have they been used to the extent possible to generate the counts here?)

// REVIEW DATA IN DATA EDITOR 

sort Lev1_count 
sort Lev2_count 
sort Lev3_count 
sort Lev4_count 
sort Lev5_count 
sort ProficientOrAbove_count




*ProficientOrAbove_percent 

clear 
use "C:\Users\Clare\Desktop\StateAssmtDataRepository-main\Version 1.1\Wisconsin - Version 1.1\wi_allyears.dta"

** • Does this variable appropriate match the percent of the proficiency levels described? (e.g., Levels 3+4?)

// NOTE: UPDATE CODE AS NEEDED FOR EACH STATE'S SUBJECT-AREA CRITERIA FOR A GIVEN YEAR.

** converting level percents from string to num 
destring Lev1_percent, generate(Lev1_p) ignore("*" & "--")
destring Lev2_percent, generate(Lev2_p) ignore("*" & "--")
destring Lev3_percent, generate(Lev3_p) ignore("*" & "--")
destring Lev4_percent, generate(Lev4_p) ignore("*" & "--")
destring Lev5_percent, generate(Lev5_p) ignore("*" & "--")
destring ProficientOrAbove_percent, generate(prof_p) ignore("*" & "--")


// add applicable levels below 
tab  ProficiencyCriteria Subject // if needed to check criteria 
tab  ProficiencyCriteria SchYear // if needed to check criteria 

egen tot_percent = rowtotal(Lev3_p Lev4_p Lev5_p)


// visually check new tot_count variable against ProficientOrAbove_count variable in Data Editor 
order id State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_n Lev1_percent Lev2_count Lev2_n Lev2_percent Lev3_count Lev3_n Lev3_percent Lev4_count Lev4_n Lev4_percent Lev5_count Lev5_n Lev5_percent AvgScaleScore ProficiencyCriteria tot_count ProficientOrAbove_count profcount_n tot_percent ProficientOrAbove_percent prof_p

// checking how the 2 vars compare 
gen per_diff = (prof_p - tot_percent)

order id State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_n Lev1_percent Lev2_count Lev2_n Lev2_percent Lev3_count Lev3_n Lev3_percent Lev4_count Lev4_n Lev4_percent Lev5_count Lev5_n Lev5_percent AvgScaleScore ProficiencyCriteria tot_count ProficientOrAbove_count profcount_n tot_percent ProficientOrAbove_percent prof_p per_diff 

sort per_diff

replace per_diff=round(per_diff, .01)

// generate list of cases where there are differences 
tab per_diff 

list n_all NCESSchoolID NCESDistrictID if per_diff > 1 & per_diff !=. // investigate any obs. Each state may require a unique approach depending on available data. 


***********************************************************
*Check AvgScaleScore


** • Are all rows free from any blanks? (as applicable)
local avgss_nomiss "AvgScaleScore"

foreach var of local avgss_nomiss {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. Any missing values for AvgScaleScore should be replaced with the string -- if it is missing or * if it is suppressed."
	}
}

// if missing values 

tab SchYear if AvgScaleScore==""
tab n_all if AvgScaleScore==""

** • Do all values make sense? 

// checking for commas 
tab AvgScaleScore SchYear if strpos(AvgScaleScore, ",")!=0 

// checking low values 
tab AvgScaleScore SchYear if AvgScaleScore<"10"


tab AvgScaleScore


****************************************************************************************
****************************************************************************************
** H. PARTICIPATION RATE
****************************************************************************************
****************************************************************************************

* ParticipationRate 

** • Are all rows free from any blanks?
local part_nomiss "ParticipationRate"

foreach var of local part_nomiss {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. Any missing values should be replaced with the string -- or * if it is suppressed."
	}
}

** • Are all percents presented as decimals? 
tab ParticipationRate

// Further investigate any years/cases if there are non-decimal observations. Flag for data cleaner. Example checks below.

/*
tab ParticipationRate SchYear if ParticipationRate=="."
tab ParticipationRate Subject if ParticipationRate=="."
tab ParticipationRate SchYear if strpos(ParticipationRate , ">")!=0 
*/

****************************************************************************************
****************************************************************************************
** I. FLAGS 
****************************************************************************************
****************************************************************************************

** • AssessmentNameChange - Do flags across all years align with what is in the crosswalk? 

// Looks across all years and subjects. Review DD to make sure flags are appropriate. 

tab SchYear AssmtName 
tab SchYear Flag_AssmtNameChange 

// if multiple assessment names, explore by subject area:
tab SchYear Flag_AssmtNameChange if Subject == "ela"
tab SchYear Flag_AssmtNameChange if Subject == "math"
tab SchYear Flag_AssmtNameChange if Subject == "sci"
tab SchYear Flag_AssmtNameChange if Subject == "soc"


** • Flag_CutScoreChange_ELA - Do flags across all years align with what is in the crosswalk? 
** • Flag_CutScoreChange_math - Do flags across all years align with what is in the crosswalk? 
** • Flag_CutScoreChange_sci - Do flags across all years align with what is in the crosswalk? 
** • Flag_CutScoreChange_soc - Do flags across all years align with what is in the crosswalk? 

tab SchYear Flag_CutScoreChange_ELA 
tab SchYear Flag_CutScoreChange_math 
tab SchYear Flag_CutScoreChange_sci 
tab SchYear Flag_CutScoreChange_soc 

****************************************************************************************
****************************************************************************************
** J. DOCUMENTATION REVIEW  
****************************************************************************************
****************************************************************************************

** • File cleanliness can be reviewed in the team drive 

** • Does the dd document what grade levels are tested in SCIENCE, if applicable?
** • Does the dd document what grade levels are tested in SOCIAL STUDIES, if applicable?

tab Subject GradeLevel 
tab GradeLevel SchYear if Subject =="sci" 
tab GradeLevel SchYear if Subject =="soc" 

** • Respond to CW review checks 
