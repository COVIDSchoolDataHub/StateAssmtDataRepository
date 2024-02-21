clear
set more off

********************************
***** File to import here: *****
* MUST INCLUDE "case(preserve)"*
********************************
** to import csv file:
import delimited "", case(preserve) clear

****** Check format of NCES IDs *******

// If NCES IDs are string:
/*
destring NCESDistrictID, replace force
destring NCESSchoolID, replace force
*/

local variables "State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode"


** Checks number of variables, if variables exist, and checks if capitalization matches

qui describe _all
di r(k)
if r(k) >46 {
	di as error "Too many variables"
}
if r(k)<46 {
	di as error "Missing variables" 
}

foreach var of varlist _all {
	if strpos("`variables'", "`var'")==0 {
		di as error "`var' is an extra variable" 
	}
}

foreach var of local variables {
capture confirm variable `var', exact
if !_rc {
                       di as txt "`var' exists"
               }
               else {
                       di as error "`var' does not exist or capitalization does not match. `var' must be added to dataset or capitalization fixed"
               }
}


** Checks order of variables
ds
local vars=r(varlist)

if "`vars'"=="`variables'" {
	di as txt "Variables are in correct order"
}

else {
	di as error "Variables are not in correct order. Use the 'order' command with full list of variables above to reorder variables in file"
}

** Check if data is sorted correctly (Messes with order of variables)
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
drop DataLevel 
rename DataLevel_n DataLevel

gen index = _n

preserve

tempfile sorted
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save `sorted'

restore

capture cf index using `sorted'

if r(Nsum) != "0" {
	di as error "Data is NOT sorted correctly"
}

drop index

** Checking Missing Values

** All data levels (remove/ignore irrelevant flags)
local nomissing "State StateAbbrev StateFips SchYear DataLevel DistName SchName AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc"

foreach var of local nomissing {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var'."
	}
}


** District and School levels
local distsch_nomiss "DistType NCESDistrictID StateAssignedDistID DistCharter CountyCode CountyName"

foreach var of local distsch_nomiss {
	count if missing(`var') & DataLevel != 1
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var' in District and School level data."
	}
	count if !missing(`var') & DataLevel == 1
	if r(N) !=0 {
		di as error "`var' has non-missing values in state level data."
	}	
}


** School level
local sch_nomiss "SchType NCESSchoolID StateAssignedSchID SchLevel SchVirtual"

foreach var of local sch_nomiss {
	count if missing(`var') & DataLevel == 3
	if r(N) !=0 {
		di as error "`var' has missing values. There should be NO MISSING VALUES for `var' in School level data."
	}
	count if !missing(`var') & DataLevel != 3
	if r(N) !=0 {
		di as error "`var' has non-missing values in state or district level data."
	}
}

** Counts and Percents (remove levels and percents which don't exist for any subjects)
local levels_nomiss "Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent"

foreach var of local levels_nomiss {
	count if missing(`var')
	if r(N) !=0 {
		di as error "`var' has missing values. Any missing values for level counts or percents should be replaced with the string -- or * if it is suppressed."
	}
}


** One correct value each
tab State 
tab StateAbbrev 
tab StateFips

******* "Check format of school years: YYYY-YY"************
levelsof SchYear, local(SchYear)
foreach year of local SchYear {
	if strpos("`year'", "-") != 5 {
		di as error "Check SchYear: `year' is in the wrong format."
	}
	if strlen("`year'") != 7 {
		di as error "Check SchYear: `year' is in the wrong format"
	}
}

** Only "State", "School", or "District"
tab DataLevel

** District and School naming for higher data levels
count if DistName != "All Districts" & DataLevel==1
	if r(N)>0 {
		di as error "The following rows need DistName='All Districts'"
		list row if DistName != "All Districts"
	}
	
count if SchName != "All Schools" & DataLevel!=3
	if r(N)>0 {
		di as error "The following rows need SchName='All Schools'"
		list row if SchName != "All Schools"
	}

** NCES ID checks
if StateFips<10 {
	**Check the following NCESSchoolIDs and NCESDistrictIDs: current values are too short**
	tab NCESSchoolID if NCESSchoolID<10000000000 & DataLevel==3
	
	tab NCESDistrictID if NCESDistrictID<100000
}

if StateFips>10 {
	**Check the following NCESSchoolIDs and NCESDistrictIDs: current values are too short**
	
	tab NCESSchoolID if NCESSchoolID<100000000000 & DataLevel==3
	
	tab NCESDistrictID if NCESDistrictID<1000000 

}

	** Check for mismatched NCES and state assigned IDs

bysort NCESDistrictID (StateAssignedDistID) : gen flag1 = StateAssignedDistID[1] != StateAssignedDistID[_N]  
bysort StateAssignedDistID (NCESDistrictID) : gen flag2 = NCESDistrictID[1] != NCESDistrictID[_N]

if flag1>0 | flag2>0 {
	di as error "Below districts have mismatched NCESDistrictID and StateAssignedDistID"
	tab NCESDistrictID if flag1==1
	tab StateAssignedDistID if flag2==1
	
}
drop flag1 flag2


bysort NCESSchoolID (StateAssignedSchID) : gen flag1 = StateAssignedSchID[1] != StateAssignedSchID[_N]  
bysort StateAssignedSchID (NCESSchoolID) : gen flag2 = NCESSchoolID[1] != NCESSchoolID[_N]

if flag1>0 | flag2>0 {
	di as error "Below schools have mismatched NCESSchoolID and StateAssignedSchID"
	tab NCESSchoolID if flag1==1
	tab StateAssignedSchID if flag2==1
}
drop flag1 flag2

	*****Check if digits of NCESSchoolID match NCESDistrictID

gen tempD= NCESDistrictID
gen tempS=floor(NCESSchoolID/100000)
di as error "First digits of NCESSchoolID for the below schools don't match NCESDistrictID"
tab NCESSchoolID if tempS != tempD & DataLevel==3
drop temp*


** Check if only values for DistCharter are Yes and No
count if DistCharter != "Yes" & DistCharter != "No" & DataLevel != 1
if r(N) > 0 {
	di as error "DistCharter has values other than Yes and No in district or school data"
	tab DistCharter
}

** Check one assessment name per subject
tab Subject AssmtName

** Check that if AssmtType is "Reg and alt" it is noted in documentation
tab AssmtType

** Check subject naming
count if !inlist(Subject, "ela" "math" "sci" "eng" "wri" "stem" "soc")
	if r(N)>0 {
		di as error "Check Subject values are abbreviated appropriately. Only AR and GA should have 'read' as a subject."
		tab Subject
	}

** Check GradeLevel values and formatting
tab GradeLevel
** Check that G38 data is included if available in original data
if GradeLevel== "G38" {
 	di as error "Please confirm that this data includes only data for Grades 3-8 and NOT any high school grades."
 }

********"Check values of StudentGroup and StudentSubGroup are correct"********

 count if !inlist(StudentGroup, "All Students", "RaceEth", "EL Status", "Gender", "Economic Status", "Disability Status", "Migrant Status", "Homeless Enrolled Status", "Foster Care Status", "Military Connected Status")
 if r(N)>0 {
 	di as error "Check StudentGroup values. StudentGroup should only contain the following values: 'All Students' 'RaceEth' 'EL Status' 'Gender' 'Economic Status' 'Disability Status' 'Migrant Status' 'Homeless Enrolled Status' 'Foster Care Status' 'Military Connected Status'"
 	tab StudentGroup
 }

 
count if StudentGroup=="All Students" & !inlist(StudentSubGroup, "All Students")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'All Students' if StudentGroup=='All Students'"
		tab StudentSubGroup if StudentGroup=="All Students"
	}


count if StudentGroup=="RaceEth" & !inlist(StudentSubGroup, "American Indian or Alaska Native", "Asian", "Black or African American", "Native Hawaiian or Pacific Islander", "Two or More", "White", "Hispanic or Latino", "Unknown", "Not Hispanic", "Filipino")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'American Indian or Alaska Native', 'Asian', 'Black or African American', 'Native Hawaiian or Pacific Islander', 'Two or More', 'White', 'Hispanic or Latino', 'Unknown' 'Not Hispanic', 'Filipino' if StudentGroup=='RaceEth'"
		tab StudentSubGroup if StudentGroup=="RaceEth"
	}

count if StudentGroup=="EL Status" & !inlist(StudentSubGroup, "English Learner", "English Proficient", "EL Exited", "EL Monit or Recently Ex", "EL and Monit or Recently Ex", "LTEL", "Ever EL")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'English Learner', 'English Proficient', 'EL Exited', 'EL Monit or Recently Ex', 'EL and Monit or Recently Ex', 'LTEL', 'Ever EL' if StudentGroup=='EL Status'"
		tab StudentSubGroup if StudentGroup=="EL Status"
	}


count if StudentGroup=="Gender" & !inlist(StudentSubGroup, "Male", "Female", "Gender X", "Unknown") 
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Male', 'Female', 'Gender X' or 'Unknown' if StudentGroup=='Gender'"
		tab StudentSubGroup if StudentGroup=="Gender"
	}


count if StudentGroup=="Economic Status" & !inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Economically Disadvantaged' or 'Not Economically Disadvantaged' if StudentGroup=='Economic Status'"
		tab StudentSubGroup if StudentGroup=="Economic Status"
	}

count if StudentGroup=="Disability Status" & !inlist(StudentSubGroup, "SWD", "Non-SWD")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'SWD' and 'Non-SWD' if StudentGroup=='Economic Status'"
		tab StudentSubGroup if StudentGroup=="Disability Status"
	}

count if StudentGroup=="Migrant Status" & !inlist(StudentSubGroup, "Migrant", "Non-Migrant")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Migrant' or 'Non-Migrant' if StudentGroup=='Migrant Status'"
		tab StudentSubGroup if StudentGroup=="Migrant Status"
	}

count if StudentGroup=="Homeless Enrolled Status" & !inlist(StudentSubGroup, "Homeless", "Non-Homeless")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Homeless' or 'Non-Homeless' if StudentGroup=='Homeless Status'"
		tab StudentSubGroup if StudentGroup=="Homeless Status"
	}
	
count if StudentGroup=="Foster Care Status" & !inlist(StudentSubGroup, "Foster Care", "Non-Foster Care")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Foster Care' or 'Non-Foster Care' if StudentGroup=='Foster Care Status'"
		tab StudentSubGroup if StudentGroup=="Foster Care Status"
	}
	
	
count if StudentGroup=="Military Connected Status" & !inlist(StudentSubGroup, "Military", "Non-Military")
	if r(N)>0 {
		di as error "Check StudentSubGroup values. StudentSubGroup should only contain 'Military' or 'Non-Military' if StudentGroup=='Military Connected Status'"
		tab StudentSubGroup if StudentGroup=="Military Connected Status"
	}
	
** Checking Level counts and percents

**** Case 1: No ranges, some suppressed and missing

****** First check that percents are presented as decimals
preserve
local percentvars = "Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent ParticipationRate"

foreach v of percentvars {
	destring `v', replace force
	drop if `v' == .
	if `v' >1  & !missing(`v') {
		di as error "`v' is not a decimal"
	}
}

****** Check that total percent for non-missing/suppressed obs are between .5 and 1
egen tot=rowtotal(Lev*percent)
gen row=_n

di as error "Below rows have percent total greater than 101%"
list row NCESSchoolID NCESDistrictID if tot>1.01

di as error "Below rows have percent total lower than 50%"
list row NCESSchoolID NCESDistrictID if tot<.50

restore

****** Check that ProficientOrAbove_percent and ProficientOrAbove_count align with level counts/percents
* Replace levels/counts in following line with proficient or above levels
tab ProficiencyCriteria

preserve 
local profpercvars = "Lev3_percent Lev4_percent Lev5_percent"
local profcountvars = "Lev3_count Lev4_count Lev5_count"

foreach v of profpercvars {
	destring `v', replace force
	drop if `v' == .
}

foreach v of profcountvars {
	destring `v', replace force
	drop if `v' == .
}

destring ProficientOrAbove_percent, replace force
drop if ProficientOrAbove_percent == .

destring ProficientOrAbove_count, replace force
drop if ProficientOrAbove_count == .

egen perctot=rowtotal(profpercvars)
egen counttot=rowtotal(profcountvars)
gen row=_n

di as error "Below rows have ProficientOrAbove_count not aligned with level counts"
list row NCESSchoolID NCESDistrictID if counttot != ProficientOrAbove_count

di as error "Below rows have ProficientOrAbove_percent not aligned with level percents"
list row NCESSchoolID NCESDistrictID if !inrange(perctot, ProficientOrAbove_percent - 0.01, ProficientOrAbove_percent + 0.01)

restore
**** Case 2: Ranges, some suppressed and missing
/* Delete this line to uncomment this section if applicable
foreach var of varlist Lev*_percent ProficientOrAbove_percent ParticipationRate {
	gen low`var' = substr(`var', 1, strpos(`var', "-")-1)
	destring low`var', replace i(*-)
	gen high`var' = substr(`var', strpos(`var', "-")+1,10)
	destring high`var', replace i(*-)	
}

foreach v of varlist low* high* {
	if `v' >1  & !missing(`v') {
		di as error "`v' is not a decimal"
	}
}

di "Checking that low percents are not greater than 101%"
count if lowLev1_percent + lowLev2_percent + lowLev3_percent + lowLev4_percent > 1.01 & !missing(lowLev1_percent) & !missing(lowLev3_percent)
di "Checking that high percents are not less than 50%"
count if highLev1_percent + highLev2_percent + highLev3_percent + highLev4_percent < 0.5 & !missing(highLev1_percent) & !missing(highLev3_percent)
di "Checking low end and high end proficiency"
gen lowcheck_perc = lowLev3_percent + lowLev4_percent
count if (lowcheck_perc - lowProficientOrAbove_percent) > abs(0.02) & !missing(lowcheck_perc)
gen highcheck_perc = highLev3_percent + highLev4_percent
count if (highcheck_perc - highProficientOrAbove_percent) > abs(0.02) & !missing(highcheck_perc)

*/

** Check ProficiencyCriteria formatting
if substr(ProficiencyCriteria,1,6) != "Levels" | substr(ProficiencyCriteria,9,1) != "-" {
	di as error "Formatting for ProficiencyCriteria is not correct"
}

** Check that there are no commas in level and proficient counts
foreach v of varlist *_count
	if strpos(`v', ",")>0 {
		di as error "`v' should not contain any commas"
	}

/*
** Checking things aggregated across years

clear
*** 1) Define csv files to include
cd "" // Save path to current folder in a local
di "`c(pwd)'" // Display path to current folder
local files : dir "`filepath'" files "*.csv" // Save name of all files in folder ending with .csv in a local
di `"`files'"' // Display list of files to import data from
*** 2) Loop over all files to import and append each file
tempfile master // Generate temporary save file to store data in
save `master', replace empty
foreach x of local files {
    di "`x'" // Display file name
	* 2A) Import each file and generate id var (filename without ".csv")
	qui: import delimited "`x'",   case(preserve) clear // <-- Change delimiter() if vars are separated by "," or tab
	qui: gen id = subinstr("`x'", ".csv", "", .)
	* 2B) Append each file to masterfile
	append using `master', force
	save `master', replace
}

tab SchYear Flag_AssmtNameChange
tab SchYear Flag_CutScoreChange_ELA
tab SchYear Flag_CutScoreChange_math
tab SchYear Flag_CutScoreChange_sci 
tab SchYear Flag_CutScoreChange_soc
tab SchYear AssmtName

