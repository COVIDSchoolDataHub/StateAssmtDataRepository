***************************************
**	Updated August 14, 2024


** 	ZELMA STATE ASSESSMENT DATA REPOSITORY 
**	REVIEW CODE TEMPLATE - VERSION 2.0

**  SETUP

**	1. In your project folder, create a state folder with the format: Florida - Version 2.0
**	2. Save all of the state's assessment data .csvs. Do not save any other .csvs in this folder.
**	3. Create a folder called "review" in the state folder in case you need to export any subsets of the data.
**	4. This do file should be saved in the state folder with the .csvs.

***************************************
clear all
cap log close
global Filepath "\Desktop\Zelma V2.0\Louisiana - Version 2.0" //Set path to csv files
global StateAbbrev "FL" //Set StateAbbrev
global years  2024 2023 2022 2021 2019 2018 2017 2016 2015 2014 2013 2012 2011 2010  //List Applicable years
log using "$Filepath/${StateAbbrev}_Review.smcl", replace

clear
tempfile temp1
save "`temp1'", empty
foreach year of global years {
	qui import delimited "${Filepath}/${StateAbbrev}_AssmtData_`year'", delimiter(",") stringcols(9, 11, 17/47) case(preserve) clear
	qui gen id = "${StateAbbrev}_AssmtData_`year'"
	qui append using "`temp1'"
	save "`temp1'", replace
}

gen n_all = _n 

sort id n_all
by id: gen n_yr = _n 

** Generate file name; this will be used in the review process to identify the relevant files. Do not use SchYear in the event that there are issues with that variable.
split id, p(_)
rename id3 FILE
drop id id1 id2 

order FILE State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

save "${Filepath}/${StateAbbrev}_allyears.dta", replace

***********************************************************
***********************************************************
clear
use "${Filepath}/${StateAbbrev}_allyears.dta"
***********************************************************
***********************************************************
** A. VARIABLE ORGANIZATION
***********************************************************
***********************************************************

** Have all files been aggregated to complete this review? 
tab SchYear 

** • Are all variables included in the file?
** • Are all variables in the proper format (capitalization etc)?
local variables "FILE State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode"


foreach var of local variables {
capture confirm variable `var', exact
if !_rc {
                       di as txt "`var' exists"
               }
               else {
                       di as error "`var' does not exist or capitalization does not match. `var' must be added to dataset or capitalization fixed"
               }
}

***********************************************************

** • Are all variables in the correct order? (State, StateAbbrev, StateFips, etc)
local variables "FILE State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode n_all n_yr"

ds
local vars=r(varlist)

if "`vars'"=="`variables'" {
	di as txt "Variables are in correct order"
}

else {
	di as error "Variables are not in correct order."
}


***********************************************************

** • Have EXTRA variables been removed from the file? 

local variables "FILE State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode id n_all n_yr "

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

***********************************************************

** • Are variables sorted correctly?

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)

sort FILE DataLevel_n DistName SchName Subject GradeLevel StudentGroup StudentSubGroup 
by FILE: generate n_testingdataorder = _n 

gen dataordercorrect =""
replace dataordercorrect="true" if n_yr == n_testingdataorder
replace dataordercorrect="false" if n_yr ~= n_testingdataorder

tab dataordercorrect // all should be true for this to be complete
if dataordercorrect=="false" di as error "Variables are not sorted in the correct order."

drop dataordercorrect DataLevel_n 
*keep n_testingdataorder


***********************************************************
***********************************************************
** B. DIRECTORY VARIABLES 
***********************************************************
***********************************************************

** State

** • Are all State rows free from any blanks?

tab  SchYear FILE if State=="" // should be no observerations 

***********************************************************
** State

** • Is the state name spelled correctly/capitalized?

tab  State SchYear  // should be only one value.
di as error "State name spelling and spacing should be VERIFIED by cleaner and reviewer"

***********************************************************
** StateAbbrev

** • Are all StateAbbrev rows free from any blanks?

tab FILE if StateAbbrev== "" // should be no observerations 

***********************************************************
** StateAbbrev

** • Is the correct state abbrev. used?

tab FILE StateAbbrev // should be only one value.
di as error "State abbreviation should be VERIFIED by cleaner and reviewer"


***********************************************************
** StateFips 

** • Is StateFips free from any blanks?

tab FILE SchYear if StateFips==. // should be no observerations 

***********************************************************
** StateFips 

tab StateFips 

** • Is the correct FIPS code applied?

gen fips_test = .

replace fips_test =1 if State =="Alabama"
replace fips_test =2 if State =="Alaska"
replace fips_test =4 if State =="Arizona"
replace fips_test =5 if State =="Arkansas"
replace fips_test =6 if State =="California"
replace fips_test =8 if State =="Colorado"
replace fips_test =9 if State =="Connecticut"
replace fips_test =10 if State =="Delaware"
replace fips_test =11 if State =="District of Columbia"
replace fips_test =12 if State =="Florida"
replace fips_test =13 if State =="Georgia"
replace fips_test =15 if State =="Hawaii"
replace fips_test =16 if State =="Idaho"
replace fips_test =17 if State =="Illinois"
replace fips_test =18 if State =="Indiana"
replace fips_test =19 if State =="Iowa"
replace fips_test =20 if State =="Kansas"
replace fips_test =21 if State =="Kentucky"
replace fips_test =22 if State =="Louisiana"
replace fips_test =23 if State =="Maine"
replace fips_test =24 if State =="Maryland"
replace fips_test =25 if State =="Massachusetts"
replace fips_test =26 if State =="Michigan"
replace fips_test =27 if State =="Minnesota"
replace fips_test =28 if State =="Mississippi"
replace fips_test =29 if State =="Missouri"
replace fips_test =30 if State =="Montana"
replace fips_test =31 if State =="Nebraska"
replace fips_test =32 if State =="Nevada"
replace fips_test =33 if State =="New Hampshire"
replace fips_test =34 if State =="New Jersey"
replace fips_test =35 if State =="New Mexico"
replace fips_test =36 if State =="New York"
replace fips_test =37 if State =="North Carolina"
replace fips_test =38 if State =="North Dakota"
replace fips_test =39 if State =="Ohio"
replace fips_test =40 if State =="Oklahoma"
replace fips_test =41 if State =="Oregon"
replace fips_test =42 if State =="Pennsylvania"
replace fips_test =44 if State =="Rhode Island"
replace fips_test =45 if State =="South Carolina"
replace fips_test =46 if State =="South Dakota"
replace fips_test =47 if State =="Tennessee"
replace fips_test =48 if State =="Texas"
replace fips_test =49 if State =="Utah"
replace fips_test =50 if State =="Vermont"
replace fips_test =51 if State =="Virginia"
replace fips_test =53 if State =="Washington"
replace fips_test =54 if State =="West Virginia"
replace fips_test =55 if State =="Wisconsin"
replace fips_test =56 if State =="Wyoming"


local fipscheck "fips_test StateFips"

foreach var of local fipscheck   {
	count if `var' != StateFips
	if r(N) !=0 {
		di as error "StateFips has incorrect values."
		tab StateFips FILE
		tab StateFips fips_test 
	}
}

drop fips_test

***********************************************************
** StateFips 

** • Is the same FIPS code used for all obs?

tab SchYear StateFips

***********************************************************
** SchYear 

** • Are all SchYear rows free from any blanks?

tab  SchYear FILE if SchYear==""

***********************************************************
** SchYear 

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
***********************************************************
** SchYear 

** • Is only one school year included per file?

bysort FILE (SchYear) : gen flag1 = SchYear[1] != SchYear[_N]  

local schyr_flag "flag1"

foreach var of local schyr_flag {
    count if flag1 == 1 
	if r(N) !=0 {
		di as error "There are multiple school years included per single school year file. Non-applicable school year data should be removed if the year is wrong, or the formatting should be updated."
		tab SchYear FILE if flag1 == 1 
	}	
}

drop flag1  
***********************************************************
** DataLevel

** • Are all DataLevel rows free from any blanks?

tab  SchYear FILE if DataLevel==""

***********************************************************
** DataLevel

** • Are the only DataLevel values either State, District, or School?

count if !inlist(DataLevel, "State", "District", "School")
 if r(N)>0 {
 	di as error "DataLevel has unexpected values."
 	tab DataLevel FILE if !inlist(DataLevel, "State", "District", "School")
 }

 
***********************************************************
** DataLevel

** • Have DataLevel values across years been reviewed? Have missing years for specific DataLevels been noted in the CW?

tab FILE DataLevel 
di as error "Scan for any years / data levels that may need a closer look (ie if numbers are greatly different from one year to the next)."


***********************************************************
***********************************************************
** C. DISTRICT/SCHOOL - NAMES & TYPES 
***********************************************************
***********************************************************
** DistName 

** • Are all DistName rows free from any blanks?

local nomissing "DistName"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
	tab FILE DataLevel if DistName =="" & DataLevel !="State"
	}
}

***********************************************************
** DistName 

** • For all cases where DataLevel=State, does DistName = "All Districts"?

count if DistName != "All Districts" & DataLevel=="State"
	if r(N)>0 {
		di as error "The following years need DistName='All Districts'"
		tab FILE if DistName != "All Districts" & DataLevel=="State"
	}
	

***********************************************************  
** DistName 

** • Have leading and trailing spaces been removed from the district names?
gen dname_spaces1 = DistName 
replace dname_spaces1 =strtrim(dname_spaces1) // returns var with leading and trailing blanks removed.

count if DistName != dname_spaces1
	if r(N)>0 {
		di as error "DistName needs leading or trailing blanks removed."
		tab FILE if DistName != dname_spaces1
		tab DistName if DistName != dname_spaces1
	}

drop dname_spaces1 
***********************************************************  
** DistName 

** • Have internal consecutive spaces been removed from the district names?

gen dname_spaces2 = DistName 
replace dname_spaces2 =stritrim(dname_spaces2) // returns var with all consecutive, internal blanks collapsed to one blank.

count if DistName != dname_spaces2
	if r(N)>0 {
		di as error "DistName needs internal, consecutive blanks collapsed to one blank."
		tab SchYear if DistName != dname_spaces2
		tab DistName if DistName != dname_spaces2
	}

drop dname_spaces2

***********************************************************
** DistName 

** • Has the full set of DistName values been reviewed for inconsistencies?
	
tab DistName FILE 
di as error "Scan full list of districts / school years to note any concerns/changes/name updates that may be applicable."

// if needed to look into districts / IDs over time:
* tab DistName NCESDistrictID if DistName =="" | DistName ==""
* replace DistName = "xxx" if NCESDistrictID ==.

** • Not applicable for all states- district name updates placeholder
** • Not applicable for all states- district dropping placeholder
** • Not applicable for all states- district name standardization placeholder


***********************************************************
** DistType  
	
** • For all cases where DataLevel=District and DataLevel=School, are all rows free from any blanks?

local distsch_nomiss "DistType"

foreach var of local distsch_nomiss {
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var' in District and School level data."
		tab  DistName FILE if DistType=="" & DataLevel !="State"
	}	
	
}

***********************************************************
** DistType 

** • For all cases where DataLevel= is State, are all rows blank?

local distsch_nomiss "DistType"

foreach var of local distsch_nomiss {
	
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data."
		tab  SchYear FILE if DistType!="" & DataLevel =="State"
	}	
}


***********************************************************
** DistType 

** • Are value labels below appropriate/as expected from the labeling conventions? If not, please indicate which need to be fixed.
** • Is the file limited to only the above groups? If not, please indicate what needs to be dropped.

gen distype_chk = .
replace distype_chk = 1 if DistType=="Regular local school district" | DistType== "Component district" | DistType== "Local school district that is a component of a supervisory union" | DistType== "Supervisory union" | DistType== "Regional education service agency" | DistType=="State-operated agency" | DistType== "Federal-operated agency" | DistType==  "Charter agency" | DistType==  "Specialized public school district"  | DistType== "Other education agency"


count if DataLevel !="State" & !inlist(distype_chk, 1)
	if r(N)>0 {
		di as error "Check DistType values in the files below."
		tab DistType FILE if DataLevel !="State" & !inlist(distype_chk, 1)
	}	
	

drop distype_chk 

***********************************************************
** DistType 

** • Have DistType values across years been reviewed to ensure that irregularities have already been flagged?
	
tab FILE DistType 

***********************************************************

** SchName   

** • Are all SchName rows free from any blanks?

local nomissing_sch "SchName"

foreach var of local nomissing_sch {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
	tab FILE if SchName ==""
	}
}

***********************************************************
** SchName   

** • For all cases where DataLevel=State or District, does SchName = "All Schools"?

count if SchName != "All Schools" & DataLevel!="School"
	if r(N)>0 {
		di as error "The following files need SchName='All Schools' for the DataLevels listed."
		tab FILE DataLevel if SchName=="" 
	}
	
***********************************************************  
** SchName 

** • Have leading and trailing spaces been removed from school names?
gen sname_spaces1 = SchName 
replace sname_spaces1 =strtrim(sname_spaces1) // returns var with leading and trailing blanks removed.

count if SchName != sname_spaces1
	if r(N)>0 {
		di as error "SchName needs leading or trailing blanks removed from the following files."
		tab SchName FILE if SchName != sname_spaces1
	}

drop sname_spaces1 
*********************************************************** 
** SchName 

** • Have internal consecutive spaces been removed from the district names?

gen sname_spaces2 = SchName 
replace sname_spaces2 =stritrim(sname_spaces2) // returns var with all consecutive, internal blanks collapsed to one blank.

count if SchName != sname_spaces2
	if r(N)>0 {
		di as error "SchName needs internal, consecutive blanks collapsed to one blank in the following files."
		tab SchName FILE if SchName != sname_spaces2
	}
	
drop sname_spaces2


*********************************************************** 	
** SchType   

** • For all cases where DataLevel= School, are all rows free from any blanks?

local sch_miss "SchType "

foreach var of local sch_miss {
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var' in School level data."
		tab SchName FILE  if SchType =="" & DataLevel=="School"
	}

}

***********************************************************	
** SchType   

** • For all cases where DataLevel is not School, are all rows blank?

local sch_nomiss "SchType"

foreach var of local sch_nomiss {

	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state or district level data in the following files."
		tab  SchName FILE  if SchType!="" & DataLevel !="School"
	}
}	


***********************************************************
** SchType 

** • Are value labels below appropriate/as expected from the labeling conventions? If not, please indicate which need to be fixed.

gen schtype_chk = .
replace schtype_chk = 1 if SchType == "Regular school" | SchType == "Special education school"  | SchType == "Vocational school"  | SchType == "Other/alternative school"  | SchType == "Reportable program"
local sch_nomiss "SchType"

count if DataLevel =="School" & !inlist(schtype_chk, 1)
	if r(N)>0 {
		di as error "SchType values DO NOT align with labeling conventions in the following files."
		tab  SchType FILE if schtype_chk != 1 & DataLevel=="School" // changed from schtype_chk == 1 

	}

drop schtype_chk

***********************************************************
** SchType 

** • Have SchType values across years been reviewed to ensure that irregularities have already been flagged?
	
tab FILE SchType 


***********************************************************
***********************************************************
** D. DISTRICT/SCHOOL IDS 
***********************************************************
***********************************************************

*NCESDistrictID 

** • For all cases where DataLevel is District or School, are all rows free from any blanks?
local distsch_nomiss "NCESDistrictID"

foreach var of local distsch_nomiss {
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var' in District and School level data."
		tab DistName FILE  if NCESDistrictID ==. & DataLevel != "State"
	}	
}

***********************************************************
** NCESDistrictID 

** • For all cases where DataLevel= is State, are all rows of NCESDistrictID blank?

local distsch_nomiss "NCESDistrictID"

foreach var of local distsch_nomiss {
	
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data in the following files."
		tab  NCESDistrictID FILE if NCESDistrictID!=. & DataLevel =="State"
	}	
}

***********************************************************
*NCESDistrictID 
tab StateFips 

** • Are all IDs in the correct format(6 digits when StateFips <10 due to leading 0, otherwise 7 digits)?
gen nces_distid_length=length(string(NCESDistrictID))
tab nces_distid_length StateFips
sort nces_distid_length

local nces_d_check "nces_distid_length"

foreach var of local nces_d_check {
	
	count if (`var') < 6 & StateFips < 10 & DataLevel !="State"
	if r(N) !=0 {
		di as error "NCESDistrictID has values that are too short in the following files and should be reviewed for accuracy."
		tab NCESDistrictID FILE if nces_distid_length < 6 & StateFips < 10 & DataLevel !="State"
	}	

	count if (`var') < 7 & StateFips > 10 & DataLevel !="State"
	if r(N) !=0 {
		di as error "NCESDistrictID has values that are too short in the following files and should be reviewed for accuracy."
		tab NCESDistrictID FILE if nces_distid_length < 7 & StateFips > 10 & DataLevel !="State"
	}	

	count if (`var') > 6 & StateFips < 10 & DataLevel !="State"
	if r(N) !=0 {
		di as error "NCESDistrictID has values that are too long in the following files and should be reviewed for accuracy."
		tab NCESDistrictID FILE if nces_distid_length > 6 & StateFips < 10 & DataLevel !="State"
	}	
	
	count if (`var') > 7 & StateFips > 10 & DataLevel !="State"
	if r(N) !=0 {
		di as error "NCESDistrictID has values that are too long in the following files and should be reviewed for accuracy."
		tab NCESDistrictID FILE if nces_distid_length > 7 & StateFips > 10 & DataLevel !="State"
	}	
}

drop nces_distid_length
***********************************************************
*NCESDistrictID 

** • Data cleaner only: Did 2024 have new districts without NCES District IDs that needed to be reviewed?
** • Data cleaner AND reviewer: If YES, were the districts exported to the state's folder on the Google drive for review and updated to the extent possible? [insert link to Google sheet in the row below for easy access for data reviewer]. If not, please explain in the comments

di as error "IDs for 2024 should be reviewed and completed to the greatest extent possible."

***********************************************************
*StateAssignedDistID

** • For all cases where DataLevel=State, are all StateAssignedDistID values blank?

local distsch_nomiss "StateAssignedDistID"

foreach var of local distsch_nomiss {
	
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data for the following files."
		tab StateAssignedDistID FILE if !missing(`var') & DataLevel == "State"
	}	
}

***********************************************************
*StateAssignedDistID

** • For all cases where DataLevel=District and DataLevel=School, are all rows free from any blanks?

local distsch_nomiss "StateAssignedDistID"

foreach var of local distsch_nomiss {
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var' in District and School level data in the following files."
		tab FILE DataLevel if DataLevel !="State" & StateAssignedDistID=="" 
	}	
}
***********************************************************
break

*StateAssignedDistID

** • Is there only 1 state district IDs per unique NCES District ID?

bysort NCESDistrictID (StateAssignedDistID) : gen d_MultipleStateIDsPer_NCESid = StateAssignedDistID[1] != StateAssignedDistID[_N]  
bysort StateAssignedDistID (NCESDistrictID) : gen d_MultipleNCESIDsPer_SchID = NCESDistrictID[1] != NCESDistrictID[_N]

local distid_flag1 "d_MultipleStateIDsPer_NCESid"
foreach var of local distid_flag1 {
    
	if r(N) !=0 {
		di as error "The observations below have  multiple state district IDs per NCES District ID."
		tab NCESDistrictID StateAssignedDistID if d_MultipleStateIDsPer_NCESid==1
	}	
}

***********************************************************
*StateAssignedDistID

** • Is there only 1 NCES District IDs per unique state district ID?

local distid_flag2 "d_MultipleStateIDsPer_NCESid"
foreach var of local distid_flag2 {
    
	if r(N) !=0 {
		di as error "The observations below have multiple NCES District IDs per state district ID."
		tab NCESDistrictID StateAssignedDistID if d_MultipleNCESIDsPer_SchID==1
	}	
}

***********************************************************
*StateAssignedDistID

** • Have mis-matched IDs all be exported to a Google doc on the drive?

format NCESDistrictID %18.0g
preserve	
keep if d_MultipleStateIDsPer_NCESid==1 | d_MultipleNCESIDsPer_SchID==1 
keep FILE State SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID d_MultipleStateIDsPer_NCESid  d_MultipleNCESIDsPer_SchID
sort NCESDistrictID SchYear 
cap duplicates drop 
cap export excel using "${Filepath}/review/mismatched dist ids.xlsx", firstrow(variables) replace
restore

***********************************************************
*StateAssignedDistID

** • Do IDs align with the original data for 2024? (COMPARE 5 data points in review code and original data)

set seed 3210
bysort StateAssignedDistID (FILE) : gen random = runiform() if _n == 1
by StateAssignedDistID: replace random = random[1]
egen select = group(random StateAssignedDistID)

tab DistName StateAssignedDistID if (select == 1 | select == 2 | select == 3 | select == 4 | select == 5) & FILE == "2024"

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

tab DistName StateAssignedDistID if (select == 1 | select == 2 | select == 3 | select == 4 | select == 5) & FILE == "2019"

drop random 
*keep select  

***********************************************************
*NCESSchoolID 

** • For all cases where DataLevel= School, are all rows free from any blanks?
local schid_nomiss "NCESSchoolID"

foreach var of local schid_nomiss {
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing school-level values in the following files. There should be NO MISSING VALUES for `var' in school-level data."
		tab FILE DataLevel if missing(`var') & DataLevel == "School" 
	}

}

***********************************************************
*NCESSchoolID 

** • For all cases where DataLevel is not School, are all rows blank?

local sch_nomiss "NCESSchoolID"

foreach var of local sch_nomiss {
	
	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state-level data in the following files."
		tab NCESSchoolID FILE if !missing(`var') & DataLevel != "School"
	}	
}
***********************************************************
*NCESSchoolID 

** • Are all IDs in the correct format?
format NCESSchoolID %18.0g	
tostring NCESSchoolID, generate(nces_sch) format(%18.0f)
order FILE State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID nces_sch

gen nces_sch_length=length(nces_sch)
tab nces_sch_length

order FILE State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID nces_sch nces_sch_length

local nces_schlength_check "nces_sch_length"

foreach var of local nces_schlength_check {
	
	count if (nces_sch_length < 11) & (StateFips < 10) & (DataLevel=="School")
	if r(N) !=0 {
		di as error "NCESSchoolID has values that are too short in the following files and should be reviewed for accuracy."
		tab NCESSchoolID FILE if (nces_sch_length < 11) & (StateFips < 10) & (DataLevel=="School")
	}	

	count if (nces_sch_length < 12) & (StateFips > 10) & (DataLevel=="School")
	if r(N) !=0 {
		di as error "NCESSchoolID has values that are too short in the following files and should be reviewed for accuracy."
		tab NCESSchoolID FILE if (nces_sch_length < 12)  & (StateFips > 10) & (DataLevel=="School")
	}	

	count if (nces_sch_length > 11) & (StateFips < 10) & (DataLevel=="School")
	if r(N) !=0 {
		di as error "NCESSchoolID has values that are too long in the following files and should be reviewed for accuracy."
		tab NCESSchoolID FILE if (nces_sch_length > 11)  & (StateFips < 10) & (DataLevel=="School")
	}	
	
	count if (nces_sch_length > 12) & (StateFips > 10) & (DataLevel=="School")
	if r(N) !=0 {
		di as error "NCESSchoolID has values that are too long in the following files and should be reviewed for accuracy."
		tab NCESSchoolID FILE if (nces_sch_length > 12)  & (StateFips > 10) & (DataLevel=="School")
	}	
}

drop nces_sch_length

***********************************************************
*NCESSchoolID 

** • Does the NCESDistrictID match the first 7 digits of the NCESSchoolID?

format NCESSchoolID %18.0g	
gen tempD= NCESDistrictID
gen tempS=floor(NCESSchoolID/100000)
di as error "First digits of NCESSchoolID for the below schools don't match NCESDistrictID"
tab NCESSchoolID FILE if tempS != tempD & DataLevel=="School"
drop temp*

***********************************************************
*NCESSchoolID 

** • Have values for 2024 been discussed/addressed to the extent possible?
format NCESSchoolID %18.0g	
di as error "Use this space to review any flagged values specific to 2024, such as new schools with missing NCES IDs. These should be verified as much as possible."

***********************************************************
*StateAssignedSchID 

** • For all cases where DataLevel= School, are all rows free from any blanks?
local stschid_nomiss "StateAssignedSchID"

foreach var of local stschid_nomiss {
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var' in school-level data."
		tab FILE if StateAssignedSchID=="" & DataLevel=="School"
	}

}

***********************************************************
*StateAssignedSchID 

** • For all cases where DataLevel is State or District, are all rows blank?

local stschid_nomiss "StateAssignedSchID"

foreach var of local stschid_nomiss {

	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state or district level data."
		tab StateAssignedSchID FILE if StateAssignedSchID != "" & DataLevel != "School"
	}
}	

***********************************************************
*StateAssignedSchID 

** • Is there only 1 state school ID per unique NCES school ID?

bysort NCESSchoolID (StateAssignedSchID) : gen s_MultipleStateSchIDsPer_NCESid = StateAssignedSchID[1] != StateAssignedSchID[_N]  
bysort StateAssignedSchID (NCESSchoolID) : gen s_MultipleNCESIDsPer_StateSchID = NCESSchoolID[1] != NCESSchoolID[_N]

local schid_flag1 "s_MultipleStateSchIDsPer_NCESid"
foreach var of local schid_flag1 {
    
	if r(N) !=0 {
		di as error "The observations below have  multiple state school IDs per unique NCES school ID."
		tab NCESSchoolID StateAssignedSchID if s_MultipleStateSchIDsPer_NCESid==1
	}	
}

***********************************************************
*StateAssignedSchID

** • Is there only 1 NCES school ID per unique state school ID?

local schid_flag2 "s_MultipleNCESIDsPer_StateSchID"
foreach var of local schid_flag2 {
    
	if r(N) !=0 {
		di as error "The observations below have multiple NCES school IDs per unique state school ID."
		tab NCESSchoolID StateAssignedSchID if s_MultipleNCESIDsPer_StateSchID==1
	}	
}

***********************************************************
*StateAssignedDistID

** • Have mis-matched IDs all be exported to a Google doc on the drive?

format NCESSchoolID %18.0g
preserve	
keep if s_MultipleStateSchIDsPer_NCESid==1 | s_MultipleNCESIDsPer_StateSchID==1 
keep FILE State SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID s_MultipleStateSchIDsPer_NCESid  s_MultipleNCESIDsPer_StateSchID
sort NCESDistrictID NCESSchoolID FILE 
cap duplicates drop 
cap export excel using "${Filepath}/review/mismatched sch ids.xlsx", firstrow(variables)
restore
***********************************************************
*StateAssignedSchID

** • Do IDs align with the original data for 2024? (COMPARE each data point in review code and original data)

set seed 98765
bysort StateAssignedSchID (FILE) : gen random = runiform() if _n == 1
by StateAssignedSchID: replace random = random[1]
egen sch_select = group(random StateAssignedSchID)

tab SchName StateAssignedSchID if (sch_select == 1 | sch_select == 2 | sch_select == 3) & FILE == "2024"
di as error "Compare StateAssignedSchID with values in original data. Flag any discrepancies. If our data combines district and school IDs to create unique school IDs, verify that this has been noted in the CW."

drop random 

***********************************************************
*StateAssignedSchID

** • Do IDs align with the original data for 2023? (COMPARE each data point in review code and original data)

tab SchName StateAssignedSchID if (sch_select == 1 | sch_select == 2 | sch_select == 3) & FILE == "2023"

***********************************************************
*StateAssignedSchID

** • Do IDs align with the original data for 2022? (COMPARE each data point in review code and original data)

tab SchName StateAssignedSchID if (sch_select == 4 | sch_select == 5 | sch_select == 6) & FILE == "2022"

***********************************************************
*StateAssignedSchID

** • Do IDs align with the original data for 2021? (COMPARE each data point in review code and original data)

tab SchName StateAssignedSchID if (sch_select == 7 | sch_select == 8 | sch_select == 9) & FILE == "2021"

***********************************************************
*StateAssignedSchID

** • Do IDs align with the original data for 2019? (COMPARE each data point in review code and original data)

tab SchName StateAssignedSchID if (sch_select == 10 | sch_select == 11 | sch_select == 12) & FILE == "2019"

***********************************************************
*StateAssignedSchID

** • Are IDs consistent across years (e.g., we don't want hyphens in the IDs for half the years and no hyphens for the other half)
tab StateAssignedSchID FILE if sch_select == 1 | sch_select == 2 | sch_select == 3 | sch_select == 4 | sch_select == 5

//string NCESSchoolID to help with display format
tostring NCESSchoolID, gen(ncesschid_str) usedisplayformat
tab FILE StateAssignedSchID if (sch_select == 1 | sch_select == 2 | sch_select == 3) 
tab  ncesschid_str StateAssignedSchID if (sch_select == 1 | sch_select == 2 | sch_select == 3) 


***********************************************************
***********************************************************
** E. NCES CHARACTERISTICS
***********************************************************
***********************************************************

*DistCharter 

** • For all cases where DataLevel=District and DataLevel=School, are all rows free from any blanks?

local ch_nomiss "DistCharter"

foreach var of local ch_nomiss {
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
		tab FILE if DistCharter=="" & DataLevel!="State"
	}

}
***********************************************************
*DistCharter 

** • For all cases where DataLevel=District and DataLevel=School, are the only values either Yes or No?

count if !inlist(DistCharter, "Yes", "No") & DataLevel != "State"
 if r(N)>0 {
 	di as error "DistCharter has values other than Yes and No in district or school data."
 	tab DistCharter FILE if !inlist(DistCharter, "Yes", "No") & DataLevel != "State"
 }


***********************************************************
*DistCharter 

** • For all cases where DataLevel= is State, are all rows blank?
local distsch_nomiss "DistCharter"

foreach var of local distsch_nomiss {
	
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state-level data in the following files."
		tab DistCharter FILE if !missing(`var') & DataLevel == "State"
	}	
}
***********************************************************
*DistCharter 

** • Have DistCharter values across all years been reviewed to ensure that irregularities have already been flagged?
tab FILE DistCharter 


***********************************************************
*DistLocale 

** • For all cases where DataLevel=District and DataLevel=School, are all rows free from any blanks?
local distloc_nomiss "DistLocale"

foreach var of local distloc_nomiss {
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
		tab FILE if DistLocale=="" & DataLevel!="State"
	}

}

***********************************************************
*DistLocale 

** • For all cases where DataLevel=District and DataLevel=School, are the values appropriate?

gen distlocale_flag = 1 if DataLevel !="State"

replace distlocale_flag = . if DataLevel !="State" & (DistLocale == "City, large" | DistLocale == "City, midsize"  | DistLocale == "City, small"  | DistLocale == "Suburb, large"  | DistLocale == "Suburb, midsize" | DistLocale == "Suburb, small"| DistLocale == "Town, fringe"| DistLocale == "Town, distant"| DistLocale == "Town, remote"| DistLocale == "Rural, fringe"| DistLocale == "Rural, distant"| DistLocale == "Rural, remote" | DistLocale == "Large city" | DistLocale == "Midsize city"  | DistLocale == "Urban fringe of a large city"  | DistLocale == "Urban fringe of a midsize city"  | DistLocale == "Large town" | DistLocale == "Small town"| DistLocale == "Rural, outside CBSA"| DistLocale == "Rural, inside CBSA")

local distloc_flag "distlocale_flag"

foreach var of local distloc_flag {
	count if (`var')==1 & DataLevel != "State"
	if r(N)>0 {
		di as error "DistLocale values DO NOT align with labeling conventions in the following files." 
		tab  DistLocale FILE if (`var')==1 & DataLevel != "State"

	}
}	
drop distlocale_flag 

***********************************************************
*DistLocale 

** • For all cases where DataLevel= is State, are all rows blank?
local distloc_miss "DistLocale"

foreach var of local distloc_miss {
	
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state-level data in the following files."
		tab DistLocale FILE if DistLocale!="" & DataLevel=="State"
	}	
}
***********************************************************
*DistLocale 

** • Have DistLocale values across all years been reviewed to ensure that irregularities have already been flagged?

tab DistLocale FILE 

***********************************************************
*SchLevel 

** • For all cases where DataLevel=School, are all rows free from any blanks?

local sch_nomiss "SchLevel"

foreach var of local sch_nomiss {
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
		tab FILE if SchLevel=="" & DataLevel=="School"
	}

}
***********************************************************
*SchLevel 

** • For all cases where DataLevel is not School, are all rows blank?

local sch_nomiss "SchLevel "

foreach var of local sch_nomiss {

	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state or district-level data in the following files."
		tab SchLevel FILE if SchLevel!="" & DataLevel!="School"
	}
}	

*format NCESSchoolID %18.0g

***********************************************************
*SchLevel 

** • Are value labels appropriate/as expected from the labeling conventions? [e.g., there should be no numeric values, no prekindergarten values, etc.]
gen schlev_chk = 1 if DataLevel =="School"

replace schlev_chk = . if DataLevel =="School" & (SchLevel == "Primary" | SchLevel == "Middle"  | SchLevel == "High"  | SchLevel == "Secondary"  | SchLevel == "Ungraded" | SchLevel == "Other"| SchLevel == "Not applicable"| SchLevel == "Missing/not reported")

local schlev_flag "schlev_chk"

foreach var of local schlev_flag {
	count if (`var')==1 & DataLevel == "School"
	if r(N)>0 {
		di as error "SchLevel values DO NOT align with labeling conventions in the following files." 
		tab  SchName FILE if (`var')==1 & DataLevel == "School"

	}
}	
drop schlev_chk
 
***********************************************************
*SchLevel 

** • Are there still "Missing/not reported" values for 2024?

tab DistName SchName if SchLevel=="Missing/not reported" & FILE == "2024"

***********************************************************
*SchLevel 

** • Have SchLevel values across all years been reviewed to ensure that irregularities have already been flagged?

tab SchLevel FILE 

***********************************************************
*SchVirtual 

** • For all cases where DataLevel=School, are all rows free from any blanks?

local sch_nomiss "SchVirtual"

foreach var of local sch_nomiss {
	count if missing(`var') & DataLevel == "School"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
		tab FILE if SchVirtual=="" & DataLevel=="School"
	}

}

***********************************************************
*SchVirtual 

** • For all cases where DataLevel is not School, are all rows blank?

local schv_nomiss "SchVirtual "

foreach var of local schv_nomiss {

	count if !missing(`var') & DataLevel != "School"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state or district-level data in the following files."
		tab SchVirtual FILE if SchVirtual!="" & DataLevel!="School"
	}
}	
***********************************************************

*SchVirtual 

** • For all cases where DataLevel=District and DataLevel=School, are the values appropriate?

gen schvir_chk = 1 if DataLevel =="School"

replace schvir_chk = . if DataLevel =="School" & (SchVirtual == "Yes" | SchVirtual == "No"  | SchVirtual == "Virtual with face to face options"  | SchVirtual == "Supplemental virtual" | SchVirtual == "Missing/not reported")

local schvir_chk_flag "schvir_chk"

foreach var of local schvir_chk_flag {
	count if (`var')==1 & DataLevel == "School"
	if r(N)>0 {
		di as error "SchVirtual values DO NOT align with labeling conventions in the following files." 
		tab  SchName FILE if (`var')==1 & DataLevel == "School"

	}
}	
drop schvir_chk

***********************************************************
*SchVirtual 
** • Are there still "Missing/not reported" values for 2024?

preserve
keep FILE DistName SchName SchVirtual
duplicates drop
list DistName SchName if SchVirtual=="Missing/not reported" & FILE == "2024"
restore

***********************************************************
*SchVirtual 

** • Have SchVirtual values across all years been reviewed to ensure that irregularities have already been flagged?

tab SchVirtual FILE 

***********************************************************

/*
Additional code if needed to look at 2024 only for SchLevel and SchVirtual. 

keep if SchYear=="2023-24"
keep if SchLevel=="Missing/not reported" | SchVirtual =="Missing/not reported" 

keep SchYear NCESSchoolID NCESDistrictID DistName SchName SchLevel SchVirtual
duplicates drop 
*/

***********************************************************
* CountyName

** • For all cases where DataLevel=District and DataLevel=School, are all rows free from any blanks?

local cty_nomiss "CountyName"

foreach var of local cty_nomiss {
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var' in district and school-level data."
		tab FILE if CountyName=="" & DataLevel != "State"
	}

}
***********************************************************
* CountyName

** • For all cases where DataLevel=State, are all rows blank?

local cty_nomiss "CountyName"

foreach var of local cty_nomiss {
	
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data."
		tab CountyName FILE if CountyName!="" & DataLevel == "State"
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


di as error "Review county names below to check for incorrect capitalization, such as Mcdonald instead of McDonald. Other typical cases are De and Le"
tab CountyName FILE 


***********************************************************

* CountyName

** • Is the file free of obs that use "Missing/not reported"?

tab  DistName FILE if CountyName=="Missing/not reported"

***********************************************************

* CountyCode

** • For all cases where DataLevel=District and DataLevel=School, are all rows free from any blanks?

local cty_nomiss "CountyCode"

foreach var of local cty_nomiss {
	count if missing(`var') & DataLevel != "State"
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var' in district and school-level data."
		tab FILE if CountyCode=="" & DataLevel != "State"
	}

}
***********************************************************
* CountyCode

** • For all cases where DataLevel=State, are all rows blank?

local cty_nomiss "CountyCode"

foreach var of local cty_nomiss {
	
	count if !missing(`var') & DataLevel == "State"
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data."
		tab CountyCode FILE if CountyCode!="" & DataLevel == "State"
	}	
}
***********************************************************
* CountyCode

** • Is the file free of obs that use "Missing/not reported"?

tab  DistName FILE if CountyCode=="Missing/not reported"
di as error "Review any CountyCode values that are missing/not reported." 

***********************************************************
* CountyCode

** • Is there just 1 CountyCode per CountyName? 
 
bysort CountyName (CountyCode) : gen cty_flag1 = CountyCode[1] != CountyCode[_N]  
bysort CountyCode (CountyName) : gen cty_flag2 = CountyName[1] != CountyName[_N] 
 

if cty_flag1>0 | cty_flag2>0 {
	di as error "Counties below have mismatched CountyName and CountyCode"
	tab CountyName if cty_flag1==1
	tab CountyCode if cty_flag2==1
}

** • IF no: Have mis-matched county names/codes all be exported to a Google doc on the drive?

preserve 
keep State StateAbbrev StateFips SchYear DataLevel DistName  NCESDistrictID   CountyName CountyCode cty_flag1 cty_flag2
keep if cty_flag1==1 | cty_flag2==1
cap duplicates drop 
cap export excel using "${Filepath}/review/county ids.xlsx", firstrow(variables) replace
restore

drop cty_flag1 cty_flag2

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

** • Is "ela" the subject for all states except for AR and GA, which have both "ela" and "read"?

count if !inlist(State, "Arkansas" "Georgia") & inlist(Subject, "read", "reading")
	if r(N)>0 {
		di as error "Reading should be labelled as 'ela' in the data file. Only AR and GA should have 'read' as a subject."
		tab Subject FILE if !inlist(State, "Arkansas" "Georgia") & inlist(Subject, "read", "reading")
	}

***********************************************************
*Subject 
	
** • Are subjects listed as ela, math, sci, eng, read, wri, stem, soc? (eg not "reading" "science" etc) 

count if !inlist(Subject, "ela", "math", "sci", "eng", "wri", "stem", "soc")
	if r(N)>0 {
		di as error "Subject values are not labelled appropriately."
		tab Subject FILE if !inlist(Subject, "ela", "math", "sci", "eng", "wri", "stem", "soc", "read")
	}

***********************************************************
*Subject 

** • Are all rows free from any blanks?

local subj_nomiss "Subject"

foreach var of local subj_nomiss {
	
	count if missing(`var') 
	if r(N) !=0 {
		di as error "`var' has missing values in the following files."
		tab DataLevel FILE if Subject=="" 
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

** • Are all rows free from any blanks?

local nomissing "GradeLevel"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
		tab DataLevel FILE if GradeLevel=="" 
	}
}
***********************************************************
*GradeLevel 

** • Are grades listed as G03, G04 etc and not 3, 4?

count if !inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38", "GZ")
	if r(N)>0 {
		di as error "Grade level values below are not labelled appropriately."
		tab GradeLevel FILE if !inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38", "GZ")
	}

***********************************************************
*GradeLevel 

** • If G38 is included (aggregated data for Grades 3-8), has it been confirmed that this only includes Grades 3-8 and not high school grades?
tab FILE GradeLevel 
if GradeLevel== "G38" {
 	di as error "Please confirm that this data includes only data for Grades 3-8 and NOT any high school grades."
 }

***********************************************************
*GradeLevel 


di as error "Data cleaner only: Do the data files include data AGGREGATED across grade levels? IF YES, please note what grade levels are aggregated in the ORIGINAL state data."

di as error "Data cleaner only: If there is aggregated grade 3-8 data in the original data, has it been incorporated into the data file? [ONLY Grades 3-8 should be included, and not aggregated data that includes HS grades]"

***********************************************************
*StudentGroup 

** • Do all labels follow the standardized naming conventions? 
** • If there are other values, please indicate what needs to be dropped.

 count if !inlist(StudentGroup, "All Students", "RaceEth", "EL Status", "Gender", "Economic Status") & !inlist(StudentGroup, "Disability Status", "Migrant Status", "Homeless Enrolled Status", "Foster Care Status", "Military Connected Status")
 if r(N)>0 {
 	di as error "StudentGroup values below are not labelled appropriately."
	tab StudentGroup FILE if !inlist(StudentGroup, "All Students", "RaceEth", "EL Status", "Gender", "Economic Status") & !inlist(StudentGroup, "Disability Status", "Migrant Status", "Homeless Enrolled Status", "Foster Care Status", "Military Connected Status")
 }

***********************************************************
*StudentGroup 
 
** • Are all rows free from any blanks?

local nomissing_sg "StudentGroup"

foreach var of local nomissing_sg {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the files below. There should be NO MISSING VALUES for `var'."
		tab StudentSubGroup FILE if StudentGroup==""
	}
}

***********************************************************
*StudentGroup_TotalTested 

** • Is there an "All Students" value for each 'unique group' in the file? (A unique group is defined as the same SchYear-DataLevel-DistID-SchID-Subject-GradeLevel)

// generating num DataLevel for ordering & adding state-level values for dist and sch IDs
replace StateAssignedDistID = "000000" if DataLevel=="State"
replace StateAssignedSchID = "000000" if DataLevel=="State"
replace StateAssignedSchID = "000000" if DataLevel=="District"

egen uniquegrp = group(FILE DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup 
by uniquegrp: gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by uniquegrp: replace AllStudents = AllStudents[_n-1] if missing(AllStudents)

order FILE State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested uniquegrp AllStudents

bysort uniquegrp: gen AllStudChk = "Correct" if AllStudents == StudentGroup_TotalTested
bysort uniquegrp: replace AllStudChk = "Not Aligned"  if AllStudents != StudentGroup_TotalTested
bysort uniquegrp: replace AllStudChk = "All Students Value Missing" if AllStudents == ""

local allstudchk_nomiss "AllStudents"

foreach var of local allstudchk_nomiss {
	count if missing(`var')
	if r(N) !=0 {
		di as error "The uniquegroups below are missing values for 'All Students'."
		tab uniquegrp FILE if missing(`var')
		tab DataLevel FILE if missing(`var')
	}
}

//another look at the same thing:
tab FILE AllStudChk if AllStudChk=="All Students Value Missing"

***********************************************************
*StudentGroup_TotalTested 

** •Has the "All Students" value been applied to all other student groups?
tab FILE AllStudChk if AllStudChk=="All Students Value Missing" | AllStudChk=="Not Aligned"

***********************************************************
//if needed to export, this code can be used:
format NCESDistrictID %18.0g
preserve	
keep if AllStudChk=="All Students Value Missing" | AllStudChk=="Not Aligned"
keep FILE State SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested AllStudents AllStudChk uniquegrp
cap duplicates drop 
cap export excel using "${Filepath}/review/stud group all stud check.xlsx", firstrow(variables) replace
restore
***********************************************************

*StudentGroup_TotalTested 

** • Are all rows free from any blanks?

local nomissing "StudentGroup_TotalTested"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the files below. There should be NO MISSING VALUES for `var'."
		tab StudentSubGroup FILE if StudentGroup_TotalTested==""
	}
}

***********************************************************
*StudentGroup_TotalTested 

** • Are all rows free from negative numbers?

tab StudentGroup_TotalTested FILE if real(StudentGroup_TotalTested) < 0 & !missing(real(StudentGroup_TotalTested))

***********************************************************
*StudentGroup_TotalTested 

** • Are commas removed from all tested counts?

local sgtt "StudentGroup_TotalTested" 

foreach var of local sgtt {
	count if strpos(`var', ",")
	if r(N) !=0 {
		di as error "`var' has values with commas in the files below."
		tab StudentGroup_TotalTested FILE if strpos(`var', ",")
	}
}

***********************************************************
*StudentGroup_TotalTested 

** • Have extra spaces been removed from all tested counts?

local sgtt "StudentGroup_TotalTested" 

foreach var of local sgtt {
	count if strpos(`var', " ")
	if r(N) !=0 {
		di as error "`var' has values with extra spaces in the files below."
		tab StudentGroup_TotalTested FILE if strpos(`var', " ")
	}
}

***********************************************************
*StudentGroup_TotalTested 

** • Are all values free of inequalities (< or >)?
** • Are all values free of periods (.)?

local sgtt "StudentGroup_TotalTested" 

foreach var of local sgtt {
	count if strpos(`var', ">") | strpos(`var', "<") | strpos(`var', ".") 
	if r(N) !=0 {
		di as error "`var' has values with inequalities or periods in the files below."
		tab StudentGroup_TotalTested FILE if strpos(`var', ">") | strpos(`var', "<") | strpos(`var', ".") 
	} 
}

***********************************************************
*StudentGroup_TotalTested 

** • Have low StudentGroup_TotalTested values across all years been reviewed for irregularities?

sort  FILE StudentGroup_TotalTested
by FILE: gen  sg_tt_low = _n //Number observations by year from lowest StudentGroup_TotalTested value to highest
tab  FILE StudentGroup_TotalTested if sg_tt_low < 11  //Look at lowest 10 values for each file
tab FILE StudentGroup_TotalTested if StudentGroup_TotalTested < "1"  // additional check

** • Have high StudentGroup_TotalTested values across all years been reviewed for irregularities?

gsort  FILE -StudentGroup_TotalTested
by FILE: gen  sg_tt_high = _n //Number observations by year from highest StudentGroup_TotalTested value to lowest
tab  FILE StudentGroup_TotalTested if sg_tt_high < 11 //Look at highest 10 values for each file

drop sg_tt_low sg_tt_high // drop vars no longer needed

***********************************************************
*StudentGroup_TotalTested 

** • Does the file include suppressed data (*)?
tab  StudentGroup_TotalTested FILE if StudentGroup_TotalTested=="*"

***********************************************************
*StudentGroup_TotalTested 

** • Does the file include missing data (--)?
tab  StudentGroup_TotalTested FILE if StudentGroup_TotalTested=="--"

***********************************************************
*StudentGroup_TotalTested 

** • Does the file include ranges (-)?

count if strpos(StudentGroup_TotalTested, "-") & StudentGroup_TotalTested != "--" & StudentGroup_TotalTested > "0"
	if r(N) !=0 {
		di as error "StudentGroup_TotalTested has range values in the files below. Make sure to note in the CW and data review."
		tab StudentGroup_TotalTested FILE if strpos(StudentGroup_TotalTested, "-") & StudentGroup_TotalTested != "--" & StudentGroup_TotalTested > "0"
 }

************************************************************************************************************
*StudentSubGroup

** • Are value labels below appropriate/as expected from the labeling conventions? If not, please indicate which need to be fixed.
** • If there are other values, please indicate what needs to be dropped.
	
* Checking subgroup values for StudentGroup == "All Students"
count if StudentGroup=="All Students" & !inlist(StudentSubGroup, "All Students")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should == 'All Students' if StudentGroup=='All Students'"
		tab StudentSubGroup FILE if StudentGroup=="All Students" & !inlist(StudentSubGroup, "All Students")
	}

* Checking subgroup values for StudentGroup == "RaceEth"	
gen raceeth_chk = .
replace raceeth_chk = 1 if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander"| StudentSubGroup == "Two or More" | StudentSubGroup =="White"| StudentSubGroup == "Hispanic or Latino" | StudentSubGroup =="Unknown" | StudentSubGroup =="Not Hispanic or Latino" | StudentSubGroup =="Filipino"


count if StudentGroup=="RaceEth" & !inlist(raceeth_chk, 1)
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'American Indian or Alaska Native', 'Asian', 'Black or African American', 'Native Hawaiian or Pacific Islander', 'Two or More', 'White', 'Hispanic or Latino', 'Unknown' 'Not Hispanic', 'Filipino' if StudentGroup=='RaceEth'"
		tab StudentSubGroup FILE if StudentGroup=="RaceEth" & !inlist(raceeth_chk, 1)
	}	
	
* Checking subgroup values for StudentGroup == "EL Status"
count if StudentGroup=="EL Status" & !inlist(StudentSubGroup, "English Learner", "English Proficient", "EL Exited", "EL Monit or Recently Ex", "EL and Monit or Recently Ex", "LTEL", "Ever EL")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'English Learner', 'English Proficient', 'EL Exited', 'EL Monit or Recently Ex', 'EL and Monit or Recently Ex', 'LTEL', 'Ever EL' if StudentGroup=='EL Status'"
		tab StudentSubGroup FILE if StudentGroup=="EL Status" & !inlist(StudentSubGroup, "English Learner", "English Proficient", "EL Exited", "EL Monit or Recently Ex", "EL and Monit or Recently Ex", "LTEL", "Ever EL")
	}

* Checking subgroup values for StudentGroup == "Economic Status"
count if StudentGroup=="Economic Status" & !inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Economically Disadvantaged' or 'Not Economically Disadvantaged' if StudentGroup=='Economic Status'"
		tab StudentSubGroup FILE if StudentGroup=="Economic Status"
	}	
	
* Checking subgroup values for StudentGroup == "Gender"
count if StudentGroup=="Gender" & !inlist(StudentSubGroup, "Male", "Female", "Gender X", "Unknown") 
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Male', 'Female', 'Gender X' or 'Unknown' if StudentGroup=='Gender'"
		tab StudentSubGroup FILE if StudentGroup=="Gender" & !inlist(StudentSubGroup, "Male", "Female", "Gender X", "Unknown") 
	}

* Checking subgroup values for StudentGroup == "Disability Status"
count if StudentGroup=="Disability Status" & !inlist(StudentSubGroup, "SWD", "Non-SWD")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'SWD' and 'Non-SWD' if StudentGroup=='Economic Status'"
		tab StudentSubGroup FILE if StudentGroup=="Disability Status" & !inlist(StudentSubGroup, "SWD", "Non-SWD")
	}

* Checking subgroup values for StudentGroup == "Migrant Status"
count if StudentGroup=="Migrant Status" & !inlist(StudentSubGroup, "Migrant", "Non-Migrant")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Migrant' or 'Non-Migrant' if StudentGroup=='Migrant Status'"
		tab StudentSubGroup FILE if StudentGroup=="Migrant Status" & !inlist(StudentSubGroup, "Migrant", "Non-Migrant")
	}

* Checking subgroup values for StudentGroup == "Homeless Enrolled Status"
count if StudentGroup=="Homeless Enrolled Status" & !inlist(StudentSubGroup, "Homeless", "Non-Homeless")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Homeless' or 'Non-Homeless' if StudentGroup=='Homeless Status'"
		tab StudentSubGroup FILE if StudentGroup=="Homeless Status" & !inlist(StudentSubGroup, "Homeless", "Non-Homeless")
	}

* Checking subgroup values for StudentGroup == "Foster Care Status"
count if StudentGroup=="Foster Care Status" & !inlist(StudentSubGroup, "Foster Care", "Non-Foster Care")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Foster Care' or 'Non-Foster Care' if StudentGroup=='Foster Care Status'"
		tab StudentSubGroup FILE if StudentGroup=="Foster Care Status" & !inlist(StudentSubGroup, "Foster Care", "Non-Foster Care")
	}
	
* Checking subgroup values for StudentGroup == "Military Connected Status"	
count if StudentGroup=="Military Connected Status" & !inlist(StudentSubGroup, "Military", "Non-Military")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Military' or 'Non-Military' if StudentGroup=='Military Connected Status'"
		tab StudentSubGroup FILE if StudentGroup=="Military Connected Status"
	}

***********************************************************
*StudentSubGroup 
 
** • Are all rows free from any blanks?

local nomissing_ssg "StudentSubGroup"

foreach var of local nomissing_ssg {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the files below. There should be NO MISSING VALUES for `var'."
		tab StudentGroup FILE if StudentSubGroup==""
	}
}

***********************************************************	
*StudentSubGroup_TotalTested

** • Does the "All Students" value for StudentSubGroup_TotalTested = the "All Students" value for StudentGroup_TotalTested?
gen allstudents_flag = .
replace allstudents_flag = 1 if (StudentGroup=="All Students") & (StudentSubGroup=="All Students")

count if allstudents_flag==1 & (StudentGroup_TotalTested ~= StudentSubGroup_TotalTested)
	if r(N)>0 {
		di as error "The two All Students values do not match in the following files."
		tab allstudents_flag FILE if allstudents_flag==1 & (StudentGroup_TotalTested ~= StudentSubGroup_TotalTested)
	}

// To look at specific cases, if necessary:

gen allstudentsvalue_check = ""
replace allstudentsvalue_check = "true" if (allstudents_flag==1) & (StudentGroup_TotalTested == StudentSubGroup_TotalTested)
replace allstudentsvalue_check = "false" if (allstudents_flag==1) & (StudentGroup_TotalTested ~= StudentSubGroup_TotalTested)

gsort -allstudentsvalue_check

tab DataLevel FILE if allstudentsvalue_check=="false"
tab SchName FILE if allstudentsvalue_check=="false"
tab DistName FILE if allstudentsvalue_check=="false"

***********************************************************	
*StudentSubGroup_TotalTested

** • Are all rows free from any blanks?

local nomissing "StudentSubGroup_TotalTested"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
		tab DataLevel FILE if missing(`var')
	}
}

***********************************************************
*StudentSubGroup_TotalTested 

** • Are commas removed from all tested counts?

local ssgtt "StudentSubGroup_TotalTested" 

foreach var of local ssgtt {
	count if strpos(`var', ",")
	if r(N) !=0 {
		di as error "`var' has values with commas in the files below."
		tab StudentSubGroup_TotalTested FILE if strpos(`var', ",")
	}
}

***********************************************************
*StudentSubGroup_TotalTested 

** • Have extra spaces been removed from all tested counts?

local ssgtt "StudentSubGroup_TotalTested" 

foreach var of local ssgtt {
	count if strpos(`var', " ")
	if r(N) !=0 {
		di as error "`var' has values with extra spaces in the files below."
		tab StudentSubGroup_TotalTested FILE if strpos(`var', " ")
	}
}

***********************************************************
*StudentSubGroup_TotalTested 

** • Are all rows free from negative numbers?

tab StudentSubGroup_TotalTested FILE if real(StudentSubGroup_TotalTested) < 0 & !missing(real(StudentSubGroup_TotalTested))

***********************************************************
*StudentSubGroup_TotalTested 

** • Are all values free of inequalities (< or >)?
** • Are all values free of periods (.)?

local ssgtt "StudentSubGroup_TotalTested" 

foreach var of local ssgtt {
	count if strpos(`var', ">") | strpos(`var', "<") | strpos(`var', ".") 
	if r(N) !=0 {
		di as error "`var' has values with inqualities or periods in the files below."
		tab StudentSubGroup_TotalTested FILE if strpos(`var', ">") | strpos(`var', "<") | strpos(`var', ".") 
	} 
}

***********************************************************
*StudentSubGroup_TotalTested 

** • California and Texas: Have obs been dropped if StudentSubGroup_TotalTested==0 ? (otherwise the files are too big)

if "${StateAbbrev}" == "CA" | "${StateAbbrev}" == "TX" {
	cap gen testedcount = real(StudentSubGroup_TotalTested)
	cap gen testedcount = StudentSubGroup_TotalTested
	count if testedcount == 0
	if r(N) !=0 di as error "Need to drop if StudentSubGroup_TotalTested == 0 in ${StateAbbrev}"
}
else {
	di "N/A"
}
cap drop testedcount
***********************************************************

** • Have low StudentSubGroup_TotalTested values across all years been reviewed for irregularities?
sort  FILE StudentSubGroup_TotalTested
by FILE: gen  ssg_tt_low = _n //Number observations by year from lowest StudentSubGroup_TotalTested value to highest
tab  FILE StudentSubGroup_TotalTested if ssg_tt_low < 11  //Look at lowest 10 values for each file
tab FILE StudentSubGroup_TotalTested if StudentSubGroup_TotalTested < "1"  // additional check

** • Have high StudentSubGroup_TotalTested values across all years been reviewed for irregularities?
gsort  FILE -StudentSubGroup_TotalTested
by FILE: gen  ssg_tt_high = _n //Number observations by year from highest StudentSubGroup_TotalTested value to lowest
tab  FILE StudentSubGroup_TotalTested if ssg_tt_high < 11 //Look at highest 10 values for each file

drop ssg_tt_low ssg_tt_high
***********************************************************
*StudentSubGroup_TotalTested 

** • Does the file include suppressed data (*)?
tab  StudentSubGroup_TotalTested FILE if StudentSubGroup_TotalTested=="*"

***********************************************************
*StudentSubGroup_TotalTested 

** • Does the file include missing data (--)?
tab  StudentSubGroup_TotalTested FILE if StudentSubGroup_TotalTested=="--"

***********************************************************
*StudentSubGroup_TotalTested 

** • Does the file include ranges (-)?

count if strpos(StudentSubGroup_TotalTested, "-") & StudentSubGroup_TotalTested != "--" & StudentSubGroup_TotalTested > "0"
	if r(N) !=0 {
		di as error "StudentSubGroup_TotalTested has range values in the files below. Make sure to note in the CW and data review."
		tab StudentSubGroup_TotalTested FILE if strpos(StudentSubGroup_TotalTested, "-") & StudentSubGroup_TotalTested != "--" & StudentSubGroup_TotalTested > "0"
 }

***********************************************************
*StudentSubGroup_TotalTested 

** • Data cleaner only: Have ANY sugroup_totaltested counts been derived?
di as error "Data cleaner only: Have ANY sugroup_totaltested counts been derived/notes added to CW?"

***********************************************************
*StudentSubGroup_TotalTested 

** • Data cleaner and reviewer: If YES to question above, have notes about count derivations been added to the CW? [if not applicable, mark n/a]
di as error "Data cleaner and reviewer: If YES to question above, verify in the CW that notes about count derivations for StudentSubGroup_TotalTested been added to the CW"

***********************************************************
*StudentSubGroup_TotalTested 

** • Is StudentSubGroup_TotalTested completed to the extent possible? If no, please indicate which of the areas below can be used to further complete this variable.
di as error "Review data in Data Editor to identify if there are remaining gaps. Please do so carefully so that gaps do not remain for the reviewer."

***********************************************************
*StudentSubGroup_TotalTested 

** • If ALL proficiency level counts are available and not suppressed, have these been used to determine the StudentSubGroup_TotalTested to the extent possible?
di as error "If ALL proficiency level counts are available and not suppressed, have these been used to determine the StudentSubGroup_TotalTested to the extent possible?"

sort Lev1_count Lev2_count Lev3_count Lev4_count
sort StudentSubGroup_TotalTested
***********************************************************
*StudentSubGroup_TotalTested 

** • If we have StudentGroup_TotalTested and the subgroup counterpart's value, have missing subgroup counts been derived and applied to the extent possible here? (e.g. If we have total tested and non-migrant tested counts, we can derive the migrant tested counts)
di as error "If we have StudentGroup_TotalTested and the subgroup counterpart's value, have missing subgroup counts been derived and applied to the extent possible here?"
		  
sort n_all	  
		  
		  
***********************************************************
***********************************************************
** G. PROFICIENCY DATA
***********************************************************
***********************************************************
*ProficiencyCriteria

** • Does this variable clearly reflect the proficiency criteria stated in the CW across years for ela/math?

tab ProficiencyCriteria FILE if Subject == "ela"
tab ProficiencyCriteria FILE if Subject == "math"

***********************************************************
*ProficiencyCriteria

** • Does this variable clearly reflect the proficiency criteria stated in the CW across years for sci?

tab ProficiencyCriteria FILE if Subject == "sci"

***********************************************************
*ProficiencyCriteria

** • Does this variable clearly reflect the proficiency criteria stated in the CW across years for social studies?
tab ProficiencyCriteria FILE if Subject == "soc"

***********************************************************	
*ProficiencyCriteria

** • Are all rows free from any blanks?

local nomissing "ProficiencyCriteria"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
		tab DataLevel FILE if missing(`var')
	}
}

***********************************************************
*ProficiencyCriteria

** • Is the appropriate naming convention used across all files/subjects? ("Levels 3-4"  vs. "Lev 3-4" or "Levels 3 and 4", for example)

local nomissing "ProficiencyCriteria"

foreach var of local nomissing {
	count if substr(ProficiencyCriteria,1,6) != "Levels" | substr(ProficiencyCriteria,9,1) != "-"
	if r(N) !=0 {
		di as error "`var' formatting is not correct in the following files."
		tab ProficiencyCriteria FILE if substr(ProficiencyCriteria,1,6) != "Levels" | substr(ProficiencyCriteria,9,1) != "-"
		tab Subject FILE if substr(ProficiencyCriteria,1,6) != "Levels" | substr(ProficiencyCriteria,9,1) != "-"
	}
}

***********************************************************
* Level counts 

** • Do the data files include StudentSubGroup_TotalTested?
di as error "Confirm if data files include StudentSubGroup_TotalTested values."
** • Do the data files include Level*_percent values?
di as error "Confirm if data files include Level*_percent values."


** • If YES to both questions above: Have the Level*_count values been derived / applied to the extent possible here and noted in the CW?
di as error "Confirm if Level counts have been derived using SSG_TT values and level percents by carefully reviewing data in data editor."
sort Lev1_count Lev1_percent 
sort Lev2_count Lev2_percent 
sort Lev3_count Lev3_percent 
sort Lev4_count Lev4_percent 
sort Lev5_count Lev5_percent 

***********************************************************
* Level counts 

** • Have StudentSubGroup_TotalTested values and level counts been applied to the extent possible? (eg if all level counts are available except one and we have studentsubgroup_totaltested, we can determine the missing count)
** • Have ProficientOrAbove_count values and the level counts been applied to the extent possible? (eg the proficientorabove_count should be used along with of the the proficiency level counts to determine any gaps)
di as error "Confirm by carefully reviewing data in data editor."

sort ProficientOrAbove_count

***********************************************************
* Level counts 

** • Are all rows free from any blanks? [note: Ohio is the only state with 6 levels]

local levcounts "Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count "

foreach var of local levcounts {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
		tab DataLevel FILE if missing(`var')
	}
}

***********************************************************
* Level counts 

** • Are commas removed from all counts?

local levcounts "Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count "

foreach var of local levcounts {
	count if strpos(`var', ",")
	if r(N) !=0 {
		di as error "`var' has values with commas in the files below."
		tab DataLevel FILE if strpos(`var', ",")
	}
}


***********************************************************
* Level counts 

** • Have extra spaces been removed from all counts?

local levcounts "Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count "

foreach var of local levcounts {
	count if strpos(`var', " ")
	if r(N) !=0 {
		di as error "`var' has values with extra spaces in the files below."
		tab DataLevel FILE if strpos(`var', " ")
	}
}

***********************************************************
*Level counts 

** • Are all rows free from negative numbers?

local levcounts "Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count "

foreach var of local levcounts {
	count if real(`var') < 0 & !missing(real(`var'))
	if r(N) !=0 {
		di as error "`var' has negative values in the files below."
		tab `var' FILE if real(`var') < 0 & !missing(real(`var'))
	}
}


***********************************************************
* Level counts 

** • Are all values free of inequalities (< or >)?
** • Are all values free of periods (.)?

local levcounts "Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count"

foreach var of local levcounts {
	count if strpos(`var', ">") | strpos(`var', "<") | strpos(`var', ".") 
	if r(N) !=0 {
		di as error "`var' has values with extra spaces in the files below."
		tab DataLevel FILE if strpos(`var', ">") | strpos(`var', "<") | strpos(`var', ".") 
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
*tab Lev6_count if Lev5_count <"10" 
di as error "The Ohio review should include the Level 6 check."


***********************************************************
* Level counts 

** • Does the file include suppressed data (*)?
local levcounts "Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count"

foreach var of local levcounts {
	count if `var' =="*"
	if r(N) !=0 {
		di as error "`var' has suppressed values in the files below."
		tab `var' FILE if `var' =="*"
	} 
}



***********************************************************
* Level counts 

** • Does the file include missing data (--)?
local levcounts "Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count"

foreach var of local levcounts {
	count if `var' =="--"
	if r(N) !=0 {
		di as error "`var' has values indicated as missing (--) in the files below."
		tab `var' FILE if `var' =="--"
	} 
}

***********************************************************
* Level counts 

** • Are there ranges in the level counts?
** • If YES: Has this been noted in the CW?
** • If YES: Do the values make sense? (e.g., "1-1" should just be 1, lower bound should not be higher than the upper bound)

local levcounts "Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count"

foreach var of local levcounts {
	count if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	if r(N) !=0 {
		di as error "`var' has values with possible ranges in the files below."
		tab `var' FILE if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	} 
}

***********************************************************
* Level counts 

** • If the state does NOT USE the proficiency level (most commonly, Level 5 is not used), is the proficiency level BLANK?
di as error "Review values for any level counts not used by state."


***********************************************************
* Level percents  

** • Do the data files include StudentSubGroup_TotalTested?
di as error "Confirm if data files include StudentSubGroup_TotalTested values."
** • Do the data files include Level*_count values?
di as error "Confirm if data files include Level*_count values."


** • Have the Level*_percent values been derived / applied to the extent possible here using the SSG_TT and level counts values and noted in the CW?
di as error "Confirm if Level percents have been derived using SSG_TT values and level counts by carefully reviewing data in data editor."
sort Lev1_count Lev1_percent 
sort Lev2_count Lev2_percent 
sort Lev3_count Lev3_percent 
sort Lev4_count Lev4_percent 
sort Lev5_count Lev5_percent 

***********************************************************
* Level percents 

** • Have StudentSubGroup_TotalTested values and level percents been applied to the extent possible to fill in any gaps within the level percents? (eg if all level percents are available except one and we have studentsubgroup_totaltested, we can determine the missing percent)


***********************************************************
* Level percents 

** • Have ProficientOrAbove_percent values and the level percents been applied to the extent possible to fill in any gaps? (eg the proficientorabove_count should be used along with of the the proficiency level percents to determine any gaps)
di as error "Confirm by carefully reviewing data in data editor."

***********************************************************
* Level percents 

** • Are all rows free from any blanks? [note: Ohio is the only state with 6 levels]

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent "

foreach var of local levpercents {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
		tab DataLevel FILE if missing(`var')
	}
}

***********************************************************
* Level percents 

** • Are all values free of inequalities (< or >)?

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent "

foreach var of local levpercents {
	count if strpos(`var', ">") | strpos(`var', "<") 
	if r(N) !=0 {
		di as error "`var' has values with extra spaces in the files below."
		tab DataLevel FILE if strpos(`var', ">") | strpos(`var', "<") 
	} 
}

***********************************************************
*Level percents 

** • Has it been confirmed that there are no cases where the percent across levels does not sum to over 101%?

// first converting level counts from string to num 
destring Lev1_percent, generate(Lev1_p) ignore("*" & "--") 
destring Lev2_percent, generate(Lev2_p) ignore("*" & "--")
destring Lev3_percent, generate(Lev3_p) ignore("*" & "--")
destring Lev4_percent, generate(Lev4_p) ignore("*" & "--") 
destring Lev5_percent, generate(Lev5_p) ignore("*" & "--")

egen tot_percent=rowtotal(Lev*_p)
gen row=_n

di as error "Below rows have percent total greater than 103%"
list n_all NCESSchoolID NCESDistrictID if tot_percent>1.03
***********************************************************
*Level percents 

** • If there are cases where the percent across levels is <50%, have these been reviewed to check possible areas of concern? Please note in the comments any areas to double check.
di as error "Below rows have percent total lower than 50%. NOTE: To dig into this, you may need to focus on specific years or subject errors."
list n_all NCESSchoolID NCESDistrictID if tot_percent<.50 & tot_percent !=0

***********************************************************
*Level percents 

** • Are all percents presented as decimals? [or decimal ranges]

tab Lev1_p if Lev1_p>1 | Lev1_p <0
tab Lev2_p if Lev2_p>1 | Lev2_p <0
tab Lev3_p if Lev3_p>1 | Lev3_p <0
tab Lev4_p if Lev4_p>1 | Lev4_p <0
tab Lev5_p if Lev5_p>1 | Lev5_p <0

***********************************************************
* Level percents 

** • Does the file include suppressed data (*)?
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	count if `var' =="*"
	if r(N) !=0 {
		di as error "`var' has suppressed values in the files below."
		tab `var' FILE if `var' =="*"
	} 
}

***********************************************************
* Level percents 

** • Does the file include missing data (--)?
local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	count if `var' =="--"
	if r(N) !=0 {
		di as error "`var' has values indicated as missing (--) in the files below."
		tab `var' FILE if `var' =="--"
	} 
}

***********************************************************
* Level percents 

** • Are there ranges in the level percents?
** • If YES: Has this been noted in the CW?
** • If YES: Do the values make sense? (e.g., "1-1" should just be 1, lower bound should not be higher than the upper bound)

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	count if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	if r(N) !=0 {
		di as error "`var' has values with possible ranges in the files below."
		tab `var' FILE if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	} 
}

***********************************************************
* Level percents 

** • Are all values free of periods (.) where there should be -- or * instead?

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	count if `var'=="."
	if r(N) !=0 {
		di as error "`var' has values appearing as periods (.) in the files below."
		tab `var' FILE if `var'== "."
	} 
}

***********************************************************
* Level percents 

** • Do values align with the original ELA data for 2024? [based on State/ELA/Grade 3/All Students]

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' if FILE == "2024" & Subject == "ela" & GradeLevel=="G03" & StudentSubGroup=="All Students" & DataLevel=="State"
	di as error "Confirm `var' values in original 2024 data for State/ELA/Grade 3/All Students."
	} 

***********************************************************
* Level percents 

** • Do values align with the original math data for 2024? [based on State/ELA/Grade 3/All Students]

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' if FILE == "2024" & Subject == "math" & GradeLevel=="G03" & StudentSubGroup=="All Students" & DataLevel=="State"
	di as error "Confirm `var' values in original 2024 data for State/ELA/Grade 3/All Students."
	} 
***********************************************************
* Level percents 

** • Do values align with the original ELA data for 2023? [based on State/ELA/Grade 3/All Students]

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' if FILE == "2023" & Subject == "ela" & GradeLevel=="G03" & StudentSubGroup=="All Students" & DataLevel=="State"
	di as error "Confirm `var' values in original 2023 data for State/ELA/Grade 3/All Students."
	} 

***********************************************************
* Level percents 

** • Do values align with the original math data for 2023? [based on State/ELA/Grade 3/All Students]

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' if FILE == "2023" & Subject == "math" & GradeLevel=="G03" & StudentSubGroup=="All Students" & DataLevel=="State"
	di as error "Confirm `var' values in original 2023 data for State/ELA/Grade 3/All Students."
	} 

***********************************************************
* Level percents 

** • Do values align with the original ELA data for 2022? [based on State/ELA/Grade 3/All Students]

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' if FILE == "2022" & Subject == "ela" & GradeLevel=="G03" & StudentSubGroup=="All Students" & DataLevel=="State"
	di as error "Confirm `var' values in original 2022 data for State/ELA/Grade 3/All Students."
	} 

***********************************************************
* Level percents 

** • Do values align with the original math data for 2022? [based on State/ELA/Grade 3/All Students]

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' if FILE == "2022" & Subject == "math" & GradeLevel=="G03" & StudentSubGroup=="All Students" & DataLevel=="State"
	di as error "Confirm `var' values in original 2022 data for State/ELA/Grade 3/All Students."
	} 

***********************************************************
* Level percents 

** • Has it been confirmed that ELA and math data ARE NOT THE SAME in 2024 (ie, has it been confirmed that ELA data have not inadvertently been applied to math as well, and vice versa?) 

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' Subject if (FILE =="2024" & DataLevel=="State" & GradeLevel=="G04" & StudentSubGroup=="White" & (Subject=="ela" | Subject =="math"))
	di as error "Confirm that ELA and math values ARE NOT THE SAME in 2024 for State/Grade 4/White."
	} 


***********************************************************
* Level percents 

** • Has it been confirmed that ELA and math data ARE NOT THE SAME in 2023 (ie, has it been confirmed that ELA data have not inadvertently been applied to math as well, and vice versa?) 

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' Subject if (FILE =="2023" & DataLevel=="State" & GradeLevel=="G04" & StudentSubGroup=="White" & (Subject=="ela" | Subject =="math"))
	di as error "Confirm that ELA and math values ARE NOT THE SAME in 2023 for State/Grade 4/White."
	} 

***********************************************************
* Level percents 

** • Has it been confirmed that ELA and math data ARE NOT THE SAME in 2022 (ie, has it been confirmed that ELA data have not inadvertently been applied to math as well, and vice versa?) 

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' Subject if (FILE =="2022" & DataLevel=="State" & GradeLevel=="G04" & StudentSubGroup=="White" & (Subject=="ela" | Subject =="math"))
	di as error "Confirm that ELA and math values ARE NOT THE SAME in 2022 for State/Grade 4/White."
	} 

***********************************************************
* Level percents 

** • Has it been confirmed that ELA and math data ARE NOT THE SAME in 2021 (ie, has it been confirmed that ELA data have not inadvertently been applied to math as well, and vice versa?) 

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' Subject if (FILE =="2021" & DataLevel=="State" & GradeLevel=="G04" & StudentSubGroup=="White" & (Subject=="ela" | Subject =="math"))
	di as error "Confirm that ELA and math values ARE NOT THE SAME in 2021 for State/Grade 4/White."
	} 

************************************************************ 
* Level percents 

** • Has it been confirmed that ELA and math data ARE NOT THE SAME in 2019 (ie, has it been confirmed that ELA data have not inadvertently been applied to math as well, and vice versa?) 

local levpercents "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent"

foreach var of local levpercents {
	tab `var' Subject if (FILE =="2019" & DataLevel=="State" & GradeLevel=="G04" & StudentSubGroup=="White" & (Subject=="ela" | Subject =="math"))
	di as error "Confirm that ELA and math values ARE NOT THE SAME in 2019 for State/Grade 4/White."
	} 

***********************************************************
* Level percents 
	
* If the state does NOT USE the proficiency level (most commonly, Level 5 is not used), is the proficiency level BLANK?	

di as error "Confirm which proficiency levels are not used for the state for a given year/subject and review accordingly."

***********************************************************




// PROFICIENT OR ABOVE





***********************************************************
** • Does this variable appropriate match the count of the proficiency levels described? (e.g., Levels 3+4?)

// NOTE: UPDATE CODE AS NEEDED FOR EACH STATE'S SUBJECT-AREA CRITERIA FOR A GIVEN YEAR. This will not solve every issue but will provide starting places for you as the data cleaner and data reviewer to know where to look. 

break 

** converting level counts from string to num 
destring Lev1_count, generate(Lev1_n) ignore("*" & "--")
destring Lev2_count, generate(Lev2_n) ignore("*" & "--")
destring Lev3_count, generate(Lev3_n) ignore("*" & "--")
destring Lev4_count, generate(Lev4_n) ignore("*" & "--")
destring ProficientOrAbove_count, generate(profcount_n) ignore("*" & "--")

tab  ProficiencyCriteria Subject // review proficiency criteria by suject
tab  ProficiencyCriteria SchYear // review proficiency criteria by year

egen sumoflevcounts = rowtotal(Lev3_n Lev4_n) // add applicable levels  
gen count_diff = (profcount_n - sumoflevcounts) // checking how the 2 vars compare 

// generate list of cases where there are differences 
sort count_diff
tab count_diff 

tab FILE DataLevel if count_diff > 20 


* If needed to dig in more:
sort n_all 
drop if sumoflevcounts==0
tab FILE DataLevel if count_diff > 20 

***********************************************************
*ProficientOrAbove_count 
	
** • If it is possible to determine this count based on the available data for ProficientOrAbove_percent*StudentSubGroup_TotalTested, has this value been derived and applied to the extent possible? [This approach should be noted in the CW if used]

sort ProficientOrAbove_percent StudentSubGroup_TotalTested ProficientOrAbove_count

***********************************************************
*ProficientOrAbove_count 
	
** • If it is possible to determine this count based on the available data for the PROFICIENT level counts (e.g., Levels 3 + 4), has this value been derived and applied to the extent possible?  [This approach should be noted in the CW if used]
di as error "Review data in Data Editor. Edit/add to code below based on state-specific data."

sort ProficientOrAbove_count Lev4_count Lev3_count

***********************************************************
*ProficientOrAbove_count 
	
** • If it is possible to determine this count based on the available data for the NON-PROFICIENT level counts (e.g., [1 - (Levels 1 + 2)], has this value been derived and applied to the extent possible?  [This approach should be noted in the CW if used]
di as error "Review data in Data Editor. Edit/add to code below based on state-specific data."

sort ProficientOrAbove_count Lev1_count Lev2_count

***********************************************************

*ProficientOrAbove_count 

** • Are all rows free from any blanks?

local profabove_n "ProficientOrAbove_count"

foreach var of local profabove_n {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
		tab DataLevel FILE if missing(`var')
	}
}

***********************************************************
*ProficientOrAbove_count 

** • Are commas removed from all counts?

local profabove_n "ProficientOrAbove_count"

foreach var of local profabove_n {
	count if strpos(`var', ",")
	if r(N) !=0 {
		di as error "`var' has values with commas in the files below."
		tab DataLevel FILE if strpos(`var', ",")
	}
}

***********************************************************
*ProficientOrAbove_count 

** • Have extra spaces been removed from all counts?

local profabove_n "ProficientOrAbove_count"

foreach var of local profabove_n {
	count if strpos(`var', " ")
	if r(N) !=0 {
		di as error "`var' has values with extra spaces in the files below."
		tab DataLevel FILE if strpos(`var', " ")
	}
}

***********************************************************
*ProficientOrAbove_count 

** • Are all rows free from negative numbers?

local profabove_n "ProficientOrAbove_count"

foreach var of local profabove_n {
	count if real(`var') < 0 & !missing(real(`var'))
	if r(N) !=0 {
		di as error "`var' has negative values in the files below."
		tab `var' FILE if real(`var') < 0 & !missing(real(`var'))
	}
}

***********************************************************
*ProficientOrAbove_count 

** • Are all values free of inequalities (< or >)?
** • Are all values free of periods (.)?

local profabove_n "ProficientOrAbove_count"

foreach var of local profabove_n {
	count if strpos(`var', ">") | strpos(`var', "<") | strpos(`var', ".") 
	if r(N) !=0 {
		di as error "`var' has values with inequalities or periods in the files below."
		tab DataLevel FILE if strpos(`var', ">") | strpos(`var', "<") | strpos(`var', ".") 
	} 
}

**********************************************************
*ProficientOrAbove_count 

** • Have low count values been reviewed for irregularities?
tab ProficientOrAbove_count if ProficientOrAbove_count <"10" 
di as error "The Ohio review should include the Level 6 check."


***********************************************************
*ProficientOrAbove_count 

** • Does the file include suppressed data (*)?
local profabove_n "ProficientOrAbove_count"

foreach var of local levcounts {
	count if `var' =="*"
	if r(N) !=0 {
		di as error "`var' has suppressed values in the files below."
		tab `var' FILE if `var' =="*"
	} 
}

***********************************************************
*ProficientOrAbove_count 

** • Does the file include missing data (--)?
local profabove_n "ProficientOrAbove_count"

foreach var of local profabove_n {
	count if `var' =="--"
	if r(N) !=0 {
		di as error "`var' has values indicated as missing (--) in the files below."
		tab `var' FILE if `var' =="--"
	} 
}

***********************************************************
*ProficientOrAbove_count 

** • Are there ranges in the counts?
** • If YES: Has this been noted in the CW?
** • If YES: Do the values make sense? (e.g., "1-1" should just be 1, lower bound should not be higher than the upper bound)

local profabove_n "ProficientOrAbove_count"

foreach var of local levcounts {
	count if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	if r(N) !=0 {
		di as error "`var' has values with possible ranges in the files below."
		tab `var' FILE if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	} 
}	
***********************************************************
*ProficientOrAbove_count 
** • Are all values of ProficientOrAbove_count less than or equal to StudentSubGroup_TotalTested?

gen ssg_rangeflag = .
replace ssg_rangeflag = 1 if strpos(StudentSubGroup_TotalTested,"-") & StudentSubGroup_TotalTested !="--"

// to get a sense of the data 
local ssg_rangeflag "ssg_rangeflag"

foreach var of local ssg_rangeflag {
	count if `var'==1
	if r(N) !=0 {
		di as error "`var' has range values."
	} 
}	


if ssg_rangeflag == 1 {
	    
		// isolating the upper bound if there are ranges in SSG_TT 
		split StudentSubGroup_TotalTested, p(-)
		cap rename StudentSubGroup_TotalTested1 SSG_TT_low
		cap rename StudentSubGroup_TotalTested2 SSG_TT_high
		cap destring SSG_TT_low, generate(ssgtt_low_num) ignore("*" & "--")
		cap destring SSG_TT_high, generate(ssgtt_high_num) ignore("*" & "--")

		// combining upper limit values and whole values into one variable to be used for comparison against ProficientOrAbove_count
		cap replace ssgtt_high_num = ssgtt_low_num if ssgtt_high_num == . 

		// drop vars 
		cap drop SSG_TT_low SSG_TT_high ssgtt_low_num
		
		// var to use is "ssgtt_high_num"
	} 


if ssg_rangeflag == . {	
		cap destring StudentSubGroup_TotalTested, generate(ssgtt_high_num) ignore("*" & "--")
			}

// ProficientOrAbove_count			
gen poac_rangeflag = .
replace poac_rangeflag = 1 if strpos(ProficientOrAbove_count,"-") & ProficientOrAbove_count !="--"

// to get a sense of the data 
local poac_rangeflag "poac_rangeflag"

foreach var of local poac_rangeflag {
	count if `var'==1
	if r(N) !=0 {
		di as error "`var' has range values."
	} 
}	

sort ProficientOrAbove_count

if poac_rangeflag == 1 {
	    
		// isolating the upper bound if there are ranges in ProficientOrAbove_count
		split ProficientOrAbove_count, p(-)
		cap rename ProficientOrAbove_count1 poac_low
		cap rename ProficientOrAbove_count2 poac_high
		cap destring poac_low, generate(poac_low_num) ignore("*" & "--")
		cap destring poac_high, generate(poac_high_num) ignore("*" & "--")

		// combining upper limit values and whole values into one variable to be used for comparison against StudentSubGroup_TotalTested
		cap replace poac_high_num = poac_low_num if poac_high_num == . 

		// drop vars 
		cap drop poac_low poac_high poac_low_num
	} 
	
if poac_rangeflag == . {	
		cap destring ProficientOrAbove_count, generate(poac_high_num) ignore("*" & "--")
			}

drop ssg_rangeflag poac_rangeflag 

// Setup complete. Compare values.

count if (ssgtt_high_num < poac_high_num) & (poac_high_num !=.) & (ssgtt_high_num !=.) 
			if r(N)>0 {
			di as error "ProficientOrAbove_count has values greater than StudentSubGroup_TotalTested in the files below. Review cases where flag == 1. The maximum number for ProficientOrAbove_count should not be more than StudentSubGroup_TotalTested."
			tab FILE if (ssgtt_high_num < poac_high_num) & (poac_high_num !=.) & (ssgtt_high_num !=.) 
			gen flag = 1 if (ssgtt_high_num < poac_high_num) & (poac_high_num !=.) & (ssgtt_high_num !=.) 
			tab ssgtt_high_num poac_high_num if flag == 1
			}		


***********************************************************
*ProficientOrAbove_percent 

** • Does this variable appropriate match the percent of the proficiency levels described? (e.g., Levels 3+4?)

di as error "UPDATE CODE AS NEEDED FOR EACH STATE'S SUBJECT-AREA CRITERIA FOR A GIVEN YEAR."

break 

** converting level percents from string to num 

destring ProficientOrAbove_percent, generate(prof_p) ignore("*" & "--")


// review proficiency criteria by suject and year
tab  ProficiencyCriteria Subject
tab  ProficiencyCriteria SchYear

// add applicable levels below 
egen sumoflevpercents = rowtotal(Lev3_p Lev4_p)

// checking how the 2 vars compare 
gen percent_diff = (prof_p - sumoflevpercents)
replace percent_diff=round(percent_diff, .01)

// review differences 
sort percent_diff
tab FILE DataLevel if percent_diff > .20 

***********************************************************
*ProficientOrAbove_percent 
	
** • If it is possible to determine this count based on the available data for the PROFICIENT level percents (e.g., Levels 3 + 4), has this value been derived and applied to the extent possible?  [This approach should be noted in the CW if used]
di as error "Review data in Data Editor. Edit/add to code below based on state-specific data."

sort ProficientOrAbove_percent Lev4_percent Lev3_percent

***********************************************************
*ProficientOrAbove_percent 
	
** • If it is possible to determine this count based on the available data for the NON-PROFICIENT level percents (e.g., [1 - (Levels 1 + 2)], has this value been derived and applied to the extent possible?  [This approach should be noted in the CW if used]
di as error "Review data in Data Editor. Edit/add to code below based on state-specific data."

sort ProficientOrAbove_percent Lev1_percent Lev2_percent

***********************************************************
*ProficientOrAbove_percent 
	
** • If it is possible to determine this count based on the available data for ProficientOrAbove_count / StudentSubGroup_TotalTested, has this value been derived and applied to the extent possible? [This approach should be noted in the CW if used]

sort ProficientOrAbove_percent StudentSubGroup_TotalTested ProficientOrAbove_count

***********************************************************
*ProficientOrAbove_percent 

** • Are all rows free from any blanks?

local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the following files. There should be NO MISSING VALUES for `var'."
		tab DataLevel FILE if missing(`var')
	}
}

***********************************************************
*ProficientOrAbove_percent 

** • Are all values free of inequalities (< or >)?

local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	count if strpos(`var', ">") | strpos(`var', "<") 
	if r(N) !=0 {
		di as error "`var' has values with inequalities in the files below."
		tab DataLevel FILE if strpos(`var', ">") | strpos(`var', "<") 
	} 
}

***********************************************************
*ProficientOrAbove_percent 

** • Are all values free of periods (.) where there should be -- or * instead?

local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	count if `var'=="."
	if r(N) !=0 {
		di as error "`var' has values appearing as periods (.) in the files below."
		tab `var' FILE if `var'== "."
	} 
}
***********************************************************
*ProficientOrAbove_percent 

** • Are all rows free from negative numbers? 
local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	count if real(`var') < 0 & !missing(real(`var'))
	if r(N) !=0 {
		di as error "`var' has negative values in the files below."
		tab `var' FILE if real(`var') < 0 & !missing(real(`var'))
	} 
}


***********************************************************
*ProficientOrAbove_percent 

** • Does the file include suppressed data (*)?
local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	count if `var' =="*"
	if r(N) !=0 {
		di as error "`var' has suppressed values in the files below."
		tab `var' FILE if `var' =="*"
	} 
}

***********************************************************
*ProficientOrAbove_percent 

** • Does the file include missing data (--)?
local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	count if `var' =="--"
	if r(N) !=0 {
		di as error "`var' has values indicated as missing (--) in the files below."
		tab `var' FILE if `var' =="--"
	} 
}
***********************************************************
*ProficientOrAbove_percent 

** • Are there ranges in the variable?
** • If YES: Has this been noted in the CW?
** • If YES: Do the values make sense? (e.g., lower bound should not be higher than the upper bound)

local profabove_p "ProficientOrAbove_percent"

foreach var of local profabove_p {
	count if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	if r(N) !=0 {
		di as error "`var' has values with possible ranges in the files below."
		tab `var' FILE if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	} 
}	

**********************************************************
*ProficientOrAbove_percent 

** • Are all percents presented as decimals? [or decimal ranges] There should be no values below 0 or greater than 1.
destring ProficientOrAbove_percent, generate(prof_p) ignore("*" & "--") // if var is no longer in file 
tab ProficientOrAbove_percent if (prof_p>1 | prof_p <0) & (ProficientOrAbove_percent !="*") & (ProficientOrAbove_percent !="--")


***********************************************************
* AvgScaleScore

** • Are all rows free from any blanks? 
local avgss_nomiss "AvgScaleScore"

foreach var of local avgss_nomiss {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. Any missing values for AvgScaleScore should be replaced with the string -- if it is missing or * if it is suppressed."
		tab FILE if AvgScaleScore==""
	}
}

***********************************************************
* AvgScaleScore

** • Are commas removed from AvgScaleScore?

local avgss_nomiss "AvgScaleScore" 

foreach var of local avgss_nomiss {
	count if strpos(`var', ",")
	if r(N) !=0 {
		di as error "`var' has values with commas in the files below."
		tab StudentGroup_TotalTested FILE if strpos(`var', ",")
	}
}

***********************************************************
* AvgScaleScore

** • Are all values free of inequalities (< or >)?

local avgss_nomiss "AvgScaleScore" 

foreach var of local avgss_nomiss {
	count if strpos(`var', ">") | strpos(`var', "<") 
	if r(N) !=0 {
		di as error "`var' has values with inequalities in the files below."
		tab AvgScaleScore FILE if strpos(`var', ">") | strpos(`var', "<") 
	} 
}

***********************************************************
* AvgScaleScore

** • Are all values free of periods (.) where there should be -- or * instead?

local avgss_nomiss "AvgScaleScore" 

foreach var of local avgss_nomiss {
	count if `var'=="."
	if r(N) !=0 {
		di as error "`var' has values appearing as periods (.) in the files below."
		tab `var' FILE if `var'== "."
	} 
}

***********************************************************
*AvgScaleScore 

** • Does the file include suppressed data (*)?
local avgss_nomiss "AvgScaleScore"

foreach var of local avgss_nomiss {
	count if `var' =="*"
	if r(N) !=0 {
		di as error "`var' has suppressed values in the files below."
		tab `var' FILE if `var' =="*"
	} 
}

***********************************************************
*AvgScaleScore 

** • Does the file include missing data (--)?
local avgss_nomiss "AvgScaleScore"

foreach var of local avgss_nomiss {
	count if `var' =="--"
	if r(N) !=0 {
		di as error "`var' has values indicated as missing (--) in the files below."
		tab `var' FILE if `var' =="--"
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

** • Are all rows free from any blanks?
local part_nomiss "ParticipationRate"

foreach var of local part_nomiss {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. Any missing values should be replaced with the string -- or * if it is suppressed."
		tab FILE if missing(`var')
	}
}
***********************************************************
* ParticipationRate

** • Are all values free of inequalities (< or >)?

local part_nomiss "ParticipationRate"

foreach var of local part_nomiss {
	count if strpos(`var', ">") | strpos(`var', "<") 
	if r(N) !=0 {
		di as error "`var' has values with inequalities in the files below."
		tab AvgScaleScore FILE if strpos(`var', ">") | strpos(`var', "<") 
	} 
}

***********************************************************
* ParticipationRate

** • Are all values free of periods (.) where there should be -- or * instead?

local part_nomiss "ParticipationRate"

foreach var of local part_nomiss {
	count if `var'=="."
	if r(N) !=0 {
		di as error "`var' has values appearing as periods (.) in the files below."
		tab `var' FILE if `var'== "."
	} 
}

***********************************************************
*ParticipationRate 

** • Does the file include suppressed data (*)?
local part_nomiss "ParticipationRate"

foreach var of local part_nomiss {
	count if `var' =="*"
	if r(N) !=0 {
		di as error "`var' has suppressed values in the files below."
		tab `var' FILE if `var' =="*"
	} 
}

***********************************************************
*ParticipationRate 

** • Does the file include missing data (--)?
local part_nomiss "ParticipationRate"

foreach var of local part_nomiss {
	count if `var' =="--"
	if r(N) !=0 {
		di as error "`var' has values indicated as missing (--) in the files below."
		tab `var' FILE if `var' =="--"
	} 
}

***********************************************************
*ParticipationRate 

** • Are there ranges in the variable?
** • If YES: Has this been noted in the CW?
** • If YES: Do the values make sense? (e.g., lower bound should not be higher than the upper bound)

local part_nomiss "ParticipationRate"

foreach var of local part_nomiss {
	count if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	if r(N) !=0 {
		di as error "`var' has values with possible ranges in the files below."
		tab `var' FILE if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
		tab `var' Subject if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
		tab `var' DataLevel if strpos(`var', "-") & (`var' != "--") & (`var' > "0")
	} 
}	

**********************************************************
*ParticipationRate 

** • Are all percents presented as decimals? [or decimal ranges] There should be no values below 0 or greater than 1.
local part "ParticipationRate"

foreach var of local part {
	count if (real(`var') < 0 | real(`var') > 1.01) & !missing(real(`var'))
	if r(N) !=0 {
		di as error "`var' has values greater than 1 or less than 0 in the files below."
		tab `var' FILE if (real(`var') < 0 | real(`var') > 1.01) & !missing(real(`var'))
	} 
}
** ParticipationRate 

** • Have ParticipationRate values across years been reviewed to ensure that irregularities have already been flagged?
	
tab ParticipationRate FILE 


**********************************************************
**********************************************************
** I. ASSESSESSMENT CLASSIFICATION & FLAGS
**********************************************************
**********************************************************
*AssmtType 

** • Are all values either "Regular" or "Regular and alt"?
** • If there are other values, please indicate what needs to be dropped.
	
* Checking subgroup values for AssmtType
count if !inlist(AssmtType, "Regular", "Regular and alt")
	if r(N)>0 {
		di as error "Check AssmtType values. AssmtType should == 'Regular' or 'Regular and alt''"
		tab AssmtType FILE if !inlist(AssmtType, "Regular", "Regular and alt")
	}

**********************************************************
*AssmtType 

** • Does the AssmtType in the CW align with what is provided in the data files?
tab AssmtType FILE if Subject == "ela"
tab AssmtType FILE if Subject == "math"
tab AssmtType FILE if Subject == "sci"
tab AssmtType FILE if Subject == "soc"

di as error "Review CW to ensure that data aligns."

**********************************************************
*AssmtType 

** • Are all rows free from any blanks?

local nomissing "AssmtType"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
		tab FILE if missing(`var')
	}
}

**********************************************************
*AssmtName 

** • If the state uses the same assmt name, is the naming convention consistent across years?
tab  AssmtName FILE

**********************************************************
*AssmtName 

** • Does the ELA/math assessment name align with the CW across years?
tab SchYear AssmtName if Subject =="ela"  
tab SchYear AssmtName if Subject =="math"  

tab DataLevel SchYear if Subject =="ela"  
tab DataLevel SchYear if Subject =="math"  

**********************************************************
*AssmtName 

** • Does the sci assessment name align with the CW across years?
tab SchYear AssmtName if Subject =="sci"  
tab DataLevel SchYear if Subject =="sci"  

**********************************************************
*AssmtName 

** • Does the soc assessment name align with the CW across years?
tab SchYear AssmtName if Subject =="soc"  
tab DataLevel SchYear if Subject =="soc"  

**********************************************************
*AssmtName 

** • Has the 2024 assmt name been verified for ELA/math? 
** • Has the 2024 assmt name been verified for sci? 
** • Has the 2024 assmt name been verified for soc? 
di as error "Review data file or documentation to verify assessment name for 2024."

**********************************************************
*AssmtName 

** • Are all rows free from any blanks?

local nomissing "AssmtName"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
		tab FILE if missing(`var')
	}
}

***********************************************************
** Flag_AssmtNameChange	

** • Does the ELA/math name flag align with the CW across years?
tab  FILE AssmtName if Subject == "ela" |  Subject == "math"
tab  FILE Flag_AssmtNameChange if Subject == "ela" |  Subject == "math"

***********************************************************
** Flag_AssmtNameChange	

** • Does the sci assessment name flag align with the CW across years?
tab  FILE AssmtName if Subject == "sci"
tab  FILE Flag_AssmtNameChange if Subject == "sci"

***********************************************************
** Flag_AssmtNameChange	

** • Does the soc assessment name flag align with the CW across years?
tab  FILE AssmtName if Subject == "soc"
tab  FILE Flag_AssmtNameChange if Subject == "soc"

***********************************************************
** Flag_AssmtNameChange	

** • Are all values either "Y" or "N"?
count if !inlist(Flag_AssmtNameChange, "Y", "N")
	if r(N)>0 {
		di as error "Check Flag_AssmtNameChange values. Values should only == 'Y' or 'N.''"
		tab Flag_AssmtNameChange FILE if !inlist(Flag_AssmtNameChange, "Y", "N")
	}

***********************************************************
** Flag_AssmtNameChange	

** • Are all rows free from any blanks?
local flag_name_nomiss "Flag_AssmtNameChange"

foreach var of local flag_name_nomiss {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the files below."
		tab FILE if missing(`var')
	}
}

***********************************************************
** Flag_CutScoreChange_ELA	
	
** • Do flags across all years align with what is in the crosswalk?
tab  FILE Flag_CutScoreChange_ELA 

***********************************************************
** Flag_CutScoreChange_ELA	

** • Are all values either "Y" or "N"?
count if !inlist(Flag_CutScoreChange_ELA, "Y", "N", "Not applicable")
	if r(N)>0 {
		di as error "Check values. Values should only == 'Y', 'N', or 'Not applicable.''"
		tab Flag_CutScoreChange_ELA FILE if !inlist(Flag_CutScoreChange_ELA, "Y", "N", "Not applicable")
	}

***********************************************************
** Flag_CutScoreChange_ELA	

** • Are all rows free from any blanks?
local flag_sub_nomiss "Flag_CutScoreChange_ELA"

foreach var of local flag_sub_nomiss {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the files below."
		tab FILE if missing(`var')
	}
}

***********************************************************
** Flag_CutScoreChange_math	
	
** • Do flags across all years align with what is in the crosswalk?
tab  FILE Flag_CutScoreChange_math 

***********************************************************
** Flag_CutScoreChange_math	

** • Are all values either "Y" or "N"?
count if !inlist(Flag_CutScoreChange_math, "Y", "N", "Not applicable")
	if r(N)>0 {
		di as error "Check values. Values should only == 'Y', 'N', or 'Not applicable.''"
		tab Flag_CutScoreChange_math FILE if !inlist(Flag_CutScoreChange_math, "Y", "N", "Not applicable")
	}

***********************************************************
** Flag_CutScoreChange_math	

** • Are all rows free from any blanks?
local flag_sub_nomiss "Flag_CutScoreChange_math"

foreach var of local flag_sub_nomiss {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the files below."
		tab FILE if missing(`var')
	}
}

***********************************************************
** Flag_CutScoreChange_sci
	
** • Do flags across all years align with what is in the crosswalk?
tab  FILE Flag_CutScoreChange_sci 

***********************************************************
** Flag_CutScoreChange_sci	

** • Are all values either "Y" or "N"?
count if !inlist(Flag_CutScoreChange_sci, "Y", "N", "Not applicable")
	if r(N)>0 {
		di as error "Check values. Values should only == 'Y', 'N', or 'Not applicable.''"
		tab Flag_CutScoreChange_sci FILE if !inlist(Flag_CutScoreChange_sci, "Y", "N", "Not applicable")
	}

***********************************************************
** Flag_CutScoreChange_sci	

** • Are all rows free from any blanks?
local flag_sub_nomiss "Flag_CutScoreChange_sci"

foreach var of local flag_sub_nomiss {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the files below."
		tab FILE if missing(`var')
	}
}

***********************************************************
** Flag_CutScoreChange_soc
	
** • Do flags across all years align with what is in the crosswalk?
tab  FILE Flag_CutScoreChange_soc 

***********************************************************
** Flag_CutScoreChange_soc	

** • Are all values either "Y" or "N"?
count if !inlist(Flag_CutScoreChange_soc, "Y", "N", "Not applicable")
	if r(N)>0 {
		di as error "Check values. Values should only == 'Y', 'N', or 'Not applicable.''"
		tab Flag_CutScoreChange_soc FILE if !inlist(Flag_CutScoreChange_soc, "Y", "N", "Not applicable")
	}

***********************************************************
** Flag_CutScoreChange_soc	

** • Are all rows free from any blanks?
local flag_sub_nomiss "Flag_CutScoreChange_soc"

foreach var of local flag_sub_nomiss {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values in the files below."
		tab FILE if missing(`var')
	}
}

***********************************************************
***********************************************************
** J. DOCUMENTATION REVIEW  
***********************************************************
***********************************************************
di as error "Review questions should be verified by crosschecking with the state's CW and data documentation.'"


** • Does the dd document what grade levels are tested in SCIENCE, if applicable?
** • Does the dd document what grade levels are tested in SOCIAL STUDIES, if applicable?

tab Subject GradeLevel 
tab GradeLevel SchYear if Subject =="sci" 
tab GradeLevel SchYear if Subject =="soc"

log close

