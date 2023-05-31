clear
set more off

import delimited "/Users/sarahridley/Desktop/CSDH/Raw/Test Scores/Arizona/Output/AZ_AssmtData_2012.csv", varnames(1) delimit(",") case(preserve)

/*
rename SchoolType SchType
rename SchoolLevel SchLevel
rename Charter DistCharter
rename Virtual SchVirtual
rename DistrictType DistType
*/

local variables "State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth"


**(1) Checks if variables exist and checks if capitalization matches
foreach var of local variables {
capture confirm variable `var', exact
if !_rc {
                       di as txt "`var' exists"
               }
               else {
                       di as error "`var' does not exist"
               }
}

**(2) Checks for extra variables
qui describe _all
di r(k)
if r(k) >48 {
	di as error "Too many variables"
}
if r(k)<48 {
di as error "Missing variables" 
}

foreach var of varlist _all {
	if strpos("`variables'", "`var'")==0 {
		di as error "`var' is an extra variable" 
	}
}

**(3) Checking for missing values for all variables--

foreach var of varlist _all{
	count if missing(`var')
	if r(N)==0 {
		di as txt "`var' has no missing values"
	}
	if (r(N)>0 & r(N)<15) {
		di as error "`var' has a few missing values"
		list `var' if missing(`var')
	}
	if r(N)>=15 {
		di as error "`var' has many missing values, check by hand"
	}
}

**(4) Check variable values
******Check State names and abbreviations****
tab State
tab StateAbbrev
tab StateFips

******* "Check format of school years: YYYY-YY"************
tab SchYear
*******"Check for only one AssmtName per SchYear"***********
tab SchYear AssmtName
********"Check that all rows list Regular as type"**********
tab AssmtType
********"Check number of districts and schools"**********
tab DataLevel Subject
********"Check for all subjects and reading->ELA"**********
tab Subject
********"Check grade level values"**********
tab GradeLevel
********"Check values are appropriate"********
tab StudentGroup

capture confirm numeric variable StudentGroup_TotalTested
	if _rc {
		di as error "StudentGroup_TotalTested is not numeric"
	}

capture confirm numeric variable StudentSubGroup_TotalTested
	if _rc {
		di as error "StudentSubGroup_TotalTested is not numeric"
	}

********Check values are appropriate, Hispanic/Latino mapping ********
tab StudentSubGroup

tab ProficiencyCriteria

/*
**(5) NCESSchoolID and DistrictID

tab NCESSchoolID if NCESSchoolID<99999999999 //this is 11 digits, NCESID should be 12. May need to be adjusted to 10 digits for states that have a fips/NCES id that starts with 0
tab NCESDistrictID if NCESDistrictID<999999 //this is 6 digits, district id should be 7. May need to be adjusted to 5 digits as above
*/

bysort NCESDistrictID (StateAssignedDistID) : gen flag1 = StateAssignedDistID[1] != StateAssignedDistID[_N]  
bysort StateAssignedDistID (NCESDistrictID) : gen flag2 = NCESDistrictID[1] != NCESDistrictID[_N]

di as error "Below districts have mismatched NCESDistrictID and StateAssignedDistID"
tab NCESDistrictID if flag1==1
tab StateAssignedDistID if flag2==1
drop flag1 flag2

bysort NCESSchoolID (StateAssignedSchID) : gen flag1 = StateAssignedSchID[1] != StateAssignedSchID[_N]  
bysort StateAssignedSchID (NCESSchoolID) : gen flag2 = NCESSchoolID[1] != NCESSchoolID[_N]

di as error "Below schools have mismatched NCESSchoolID and StateAssignedSchlID"
tab NCESSchoolID if flag1==1
tab StateAssignedSchID if flag2==1
drop flag1 flag2

*****Check if digits of NCESSchoolID match NCESDistrictID
gen tempS=floor(NCESSchoolID/100000)
tostring(NCESSchoolID), g(NCES_School) format(%14.0g)
di as error "Below schools don't match NCESDistrictID"
tab NCES_School if tempS != NCESDistrictID
drop tempS 


**(6)
**Check Yes/No
tab DistCharter

capture confirm numeric variable CountyCode
	if _rc {
		di as error "CountyCode is not numeric"
	}

**(7) Levels 
foreach v of varlist Lev* {
	destring `v', g(n`v') i(* -)
}

egen tot = rowtotal(nLev*percent)

di as error "Below rows have percent total greater than 101"

list NCES_School NCESDistrictID if tot>101

/*
di as error "Below rows have percent total lower than 50"

list NCES_School NCESDistrictID if tot<50


/*
******************************************************
*****NOTE: Needs to be edited to match ***************
*****Proficiency Criteria before running check********
******************************************************
egen check_count=rowtotal(nLev3_count nLev4_count nLev5_count)
egen check_perc==rowtotal(nLev3_percent nLev4_percent nLev5_percent)

list NCES_School NCESDistrictID if check_count != ProficientOrAbove_count
list NCES_School NCESDistrictID if check_perc != ProficientOrAbove_percent

drop tot nLev* NCES_School check*





	
	
	


