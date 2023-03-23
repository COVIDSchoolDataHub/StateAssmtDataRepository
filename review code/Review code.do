clear
set more off

cd "/Users/minnamgung/Desktop/Arizona"

global output "/Users/minnamgung/Desktop/Alaska/Output"

import delimited "/Users/minnamgung/Desktop/Alaska/Output/AK_AssmtData_2017.csv"


local variables "State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate"


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
if r(k) >47 {
	di as error "Too many variables"
}
if r(k)<47 {
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
********Check values are appropriate, Hispanic/Latino mapping ********
tab StudentSubGroup


**(5) NCESSchoolID and DistrictID

tab NCESSchoolID if NCESSchoolID<99999999999 //this is 11 digits, NCESID should be 12. May need to be adjusted to 10 digits for states that have a fips/NCES id that starts with 0
tab ncesdistrictid if ncesdistrictid<999999 //this is 6 digits, district id should be 7. May need to be adjusted to 5 digits as above


bysort ncesdistrictid (stateassigneddistid) : gen flag1 = stateassigneddistid[1] != stateassigneddistid[_N]  
bysort stateassigneddistid (ncesdistrictid) : gen flag2 = ncesdistrictid[1] != ncesdistrictid[_N]

di as error "Below districts have mismatched NCESDistrictID and StateAssignedDistID"
tab ncesdistrictid if flag1==1
tab stateassigneddistid if flag2==1
drop flag1 flag2

bysort NCESSchoolID (StateAssignedSchlID) : gen flag1 = StateAssignedSchlID[1] != StateAssignedSchlID[_N]  
bysort StateAssignedSchlID (NCESSchoolID) : gen flag2 = NCESSchoolID[1] != NCESSchoolID[_N]

di as error "Below schools have mismatched NCESSchoolID and StateAssignedSchlID"
tab NCESSchoolID if flag1==1
tab StateAssignedSchlID if flag2==1
drop flag1 flag2

*****Check if digits of NCESSchoolID match NCESDistrictID
gen tempS=floor(NCESSchoolID/100000)
tostring(NCESSchoolID), g(NCES_School) format(%14.0g)
di as error "Below schools don't match NCESDistrictID"
tab NCES_School if tempS != ncesdistrictid
drop tempS 

**(6)
**Check Yes/No
tab Charter

capture confirm numeric variable CountyCode
	if _rc {
		di as error "StudentGroup_TotalTested is not numeric"
	}
	
**(7) Levels 
foreach v of varlist Lev* {
	destring `v', g(n`v') i(* -)
}

egen tot=rowtotal(nLev*percent)

di as error "Below rows have percent total greater than 101"

list NCES_School NCESDistrictID if tot>101

di as error "Below rows have percent total lower than 50"

list NCES_School NCESDistrictID if tot>50

tab ProficiencyCriteria

******************************************************
*****NOTE: Needs to be edited to match ***************
*****Proficiency Criteria before running check********
******************************************************
egen check_count=rowtotal(nLev3_count nLev4_count nLev5_count)
egen check_perc==rowtotal(nLev3_percent nLev4_percent nLev5_percent)

list NCES_School NCESDistrictID if check_count != ProficientOrAbove_count
list NCES_School NCESDistrictID if check_perc != ProficientOrAbove_percent

drop tot nLev* NCES_School check*





	
	
	


