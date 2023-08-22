clear
set more off
//Make sure to download and edit all dofiles first and save to a directory, specified below. Directories for data must be specified in each do-file.
cd "/Volumes/T7/State Test Project/South Dakota"
local NCES_District "/Volumes/T7/State Test Project/NCES/District"
local NCES_School "/Volumes/T7/State Test Project/NCES/School"
local dofiles SD_2003_2013.do SD_2014_2017.do SD_2018.do SD_2019.do SD_2021_2022.do
local years 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2021 2022
local Output "/Volumes/T7/State Test Project/South Dakota/Output"
foreach file of local dofiles { //Doing all do-files
	do `file'
}

foreach year of local years { //Additional Cleaning for each year (mostly unmerged schools)
local prevyear2 =`=`year'-2'
	use "`Output'/SD_AssmtData_`year'.dta", clear
if `year' == 2003 {
	replace NCESSchoolID = "462010001233" if  StateAssignedDistID == "20001" & StateAssignedSchID == "7"
	replace SchType=4 if StateAssignedDistID == "20001" & StateAssignedSchID == "7"
	replace NCESDistrictID = "4620100" if StateAssignedDistID == "20001" & StateAssignedSchID == "7"
	replace DistType=1 if StateAssignedDistID == "20001" & StateAssignedSchID == "7"
	replace seasch = StateAssignedSchID if StateAssignedDistID == "20001" & StateAssignedSchID == "7"
	replace DistCharter = "No" if StateAssignedDistID == "20001" & StateAssignedSchID == "7"
	replace SchLevel = 3 if StateAssignedDistID == "20001" & StateAssignedSchID == "7"
	replace SchVirtual = "Missing/not reported" if StateAssignedDistID == "20001" & StateAssignedSchID == "7"
	replace CountyName = "DEWEY" if StateAssignedDistID == "20001" & StateAssignedSchID == "7"
	replace CountyCode = 46041 if StateAssignedDistID == "20001" & StateAssignedSchID == "7"
}
if `year' == 2004 {
di "Unmerged schools fixed in do file SD_2003_2013"
}
if `year' == 2005 {
label def school_typedf 16 "MISSING", add
label def agency_typedf 16 "MISSING", add
label def school_leveldf 16 "MISSING", add
replace NCESSchoolID = "MISSING" if strpos(SchName, "DSS") !=0
replace SchType = 16 if strpos(SchName, "DSS") !=0
replace NCESDistrictID = "MISSING" if strpos(SchName, "DSS") !=0 | strpos(DistName, "DSS Auxiliary Placements") !=0
replace DistType = 16 if strpos(SchName, "DSS") !=0 | strpos(DistName, "DSS Auxiliary Placements") !=0
replace seasch = "MISSING" if strpos(SchName, "DSS") !=0
replace DistCharter = "MISSING" if strpos(SchName, "DSS") !=0 | strpos(DistName, "DSS Auxiliary Placements") !=0
replace SchLevel = 16 if strpos(SchName, "DSS") !=0
replace SchVirtual = "Missing/not reported" if strpos(SchName, "DSS") !=0
replace CountyName = "MISSING" if strpos(SchName, "DSS") !=0 | strpos(DistName, "DSS Auxiliary Placements") !=0
replace CountyCode = 0 if strpos(SchName, "DSS") !=0 | strpos(DistName, "DSS Auxiliary Placements") !=0
}
if `year' == 2008 {
label def school_typedf 16 "MISSING", add
label def agency_typedf 16 "MISSING", add
label def school_leveldf 16 "MISSING", add
replace NCESSchoolID = "MISSING" if strpos(SchName, "St. Lawrence Elem") !=0
replace SchType = 16 if strpos(SchName, "St. Lawrence Elem") !=0
replace NCESDistrictID = "MISSING" if strpos(SchName, "St. Lawrence Elem") !=0 | strpos(DistName, "St Lawrence School") !=0
replace DistType = 16 if strpos(SchName, "St. Lawrence Elem") !=0 | strpos(DistName, "St Lawrence School") !=0
replace seasch = "MISSING" if strpos(SchName, "St. Lawrence Elem") !=0
replace DistCharter = "MISSING" if strpos(SchName, "St. Lawrence Elem") !=0 | strpos(DistName, "St Lawrence School") !=0
replace SchLevel = 16 if strpos(SchName, "St. Lawrence Elem") !=0
replace SchVirtual = "Missing/not reported" if strpos(SchName, "St. Lawrence Elem") !=0
replace CountyName = "MISSING" if strpos(SchName, "St. Lawrence Elem") !=0 | strpos(DistName, "St Lawrence School") !=0
replace CountyCode = 0 if strpos(SchName, "St. Lawrence Elem") !=0 | strpos(DistName, "St Lawrence School") !=0
}
if `year' == 2009 {
//Using 2007 file for unmerged districts/schools
gen UniqueDistID = ""
replace UniqueDistID = StateAssignedDistID if strlen(StateAssignedDistID) == 5
replace UniqueDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 4
tempfile temp1
replace UniqueDistID = "32001" if strpos(DistName, "Harrold") !=0
save "`temp1'", replace

//District
keep if missing(NCESDistrictID) & DataLevel == 2
tempfile temp2
save "`temp2'", replace
clear
use "`temp1'"
drop if missing(NCESDistrictID) & DataLevel == 2
tempfile temp3
save "`temp3'", replace
clear
use "`temp2'"
save "`temp2'", replace
clear
use "`NCES_District'/NCES_`prevyear2'_District.dta"
keep if state_fips == 46
gen UniqueDistID = state_leaid
replace UniqueDistID = "32001" if strpos(lea_name, upper("Harrold")) !=0
merge 1:m UniqueDistID using "`temp2'"
drop if _merge==1
append using "`temp3'"
save "`temp1'", replace
tab DistName if _merge==3
drop _merge 
//School
keep if missing(NCESSchoolID) & DataLevel ==3
save "`temp2'", replace
clear
use "`temp1'"
drop if missing(NCESSchoolID) & DataLevel ==3
save "`temp3'", replace
clear
use "`temp2'"
gen StateAssignedSchID1 = ""
replace StateAssignedSchID1 = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 1
replace StateAssignedSchID1 = StateAssignedSchID if strlen(StateAssignedSchID) ==2
gen UniqueSchID = UniqueDistID + "-" + StateAssignedSchID1
drop UniqueDistID StateAssignedSchID1


save "`temp2'", replace
clear
use "`NCES_School'/NCES_`prevyear2'_School.dta"
rename SchLevel SchLevel1
rename SchVirtual SchVirtual1
rename seasch seasch1
rename DistCharter DistCharter1
keep if state_fips == 46
gen UniqueDistID = state_leaid
gen StateAssignedSchID1 = ""
replace StateAssignedSchID1 = "0" + seasch if strlen(seasch) == 1
replace StateAssignedSchID1 = seasch if strlen(seasch) ==2
gen UniqueSchID = UniqueDistID + "-" + StateAssignedSchID1
drop UniqueDistID StateAssignedSchID1
merge 1:m UniqueSchID using "`temp2'"
tab SchName if _merge ==3
drop if _merge==1
append using "`temp3'"
save "`temp1'", replace
clear
use "`temp1'"
replace NCESSchoolID = ncesschoolid if missing(NCESSchoolID)
replace SchType = school_type if missing(SchType)
replace NCESDistrictID = ncesdistrictid if missing(NCESDistrictID)
replace DistType = district_agency_type if missing(DistType)
replace seasch = seasch1 if missing(seasch)
replace DistCharter = DistCharter1 if missing(DistCharter)
replace SchLevel = SchLevel1 if missing(SchLevel)
replace SchVirtual = SchVirtual1 if missing(SchVirtual)
replace CountyName = county_name if missing(CountyName)
replace CountyCode = county_code if missing(CountyCode)
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

foreach n in 1 2 3 {
	erase "`temp`n''"
}

//Missing from NCES 2007 & 2008

//Harrold Elem
label def school_typedf 16 "MISSING", add
label def agency_typedf 16 "MISSING", add
label def school_leveldf 16 "MISSING", add
replace NCESSchoolID = "MISSING" if strpos(SchName, "Harrold Elem ") !=0
replace SchType = 16 if strpos(SchName, "Harrold Elem ") !=0
replace NCESDistrictID = "MISSING" if strpos(SchName, "Harrold Elem ") !=0 
replace DistType = 16 if strpos(SchName, "Harrold Elem ") !=0
replace seasch = "MISSING" if strpos(SchName, "Harrold Elem ") !=0
replace DistCharter = "MISSING" if strpos(SchName, "Harrold Elem ") !=0
replace SchLevel = 16 if strpos(SchName, "Harrold Elem ") !=0
replace SchVirtual = "Missing/not reported" if strpos(SchName, "Harrold Elem") !=0
replace CountyName = "MISSING" if strpos(SchName, "Harrold Elem") !=0
replace CountyCode = 0 if strpos(SchName, "Harrold Elem") !=0

//St Lawrence Elem
replace NCESSchoolID = "MISSING" if strpos(SchName, "St. Lawrence Elem") !=0
replace SchType = 16 if strpos(SchName, "St. Lawrence Elem") !=0
replace NCESDistrictID = "MISSING" if strpos(SchName, "St. Lawrence Elem") !=0 | strpos(DistName, "St Lawrence School") !=0
replace DistType = 16 if strpos(SchName, "St. Lawrence Elem") !=0 | strpos(DistName, "St Lawrence School") !=0
replace seasch = "MISSING" if strpos(SchName, "St. Lawrence Elem") !=0
replace DistCharter = "MISSING" if strpos(SchName, "St. Lawrence Elem") !=0 | strpos(DistName, "St Lawrence School") !=0
replace SchLevel = 16 if strpos(SchName, "St. Lawrence Elem") !=0
replace SchVirtual = "Missing/not reported" if strpos(SchName, "St. Lawrence Elem") !=0
replace CountyName = "MISSING" if strpos(SchName, "St. Lawrence Elem") !=0 | strpos(DistName, "St Lawrence School") !=0
replace CountyCode = 0 if strpos(SchName, "St. Lawrence Elem") !=0 | strpos(DistName, "St Lawrence School") !=0

//Rest are missing
replace NCESSchoolID = "MISSING" if (missing(NCESSchoolID) & DataLevel ==3)
replace SchType = 16 if NCESSchoolID == "MISSING"
replace NCESDistrictID = "MISSING" if NCESSchoolID == "MISSING" | (missing(NCESDistrictID) & DataLevel !=1)
replace DistType = 16 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace seasch = "MISSING" if NCESSchoolID == "MISSING"
replace DistCharter = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace SchLevel = 16 if NCESSchoolID == "MISSING"
replace SchVirtual = "Missing/not reported" if NCESSchoolID == "MISSING"
replace CountyName = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace CountyCode = 0 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
}

if `year' == 2010 {
//Trying 2008 file for unmerged districts/schools
gen UniqueDistID = ""
replace UniqueDistID = StateAssignedDistID if strlen(StateAssignedDistID) == 5
replace UniqueDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 4
tempfile temp1
save "`temp1'", replace

//District
keep if missing(NCESDistrictID) & DataLevel == 2
tempfile temp2
save "`temp2'", replace
clear
use "`temp1'"
drop if missing(NCESDistrictID) & DataLevel == 2
tempfile temp3
save "`temp3'", replace
clear
use "`temp2'"
save "`temp2'", replace
clear
use "`NCES_District'/NCES_`prevyear2'_District.dta"
keep if state_fips == 46
gen UniqueDistID = state_leaid
merge 1:m UniqueDistID using "`temp2'"
drop if _merge==1
append using "`temp3'"
save "`temp1'", replace
tab DistName if _merge==3
drop _merge 
//School
keep if missing(NCESSchoolID) & DataLevel ==3
save "`temp2'", replace
clear
use "`temp1'"
drop if missing(NCESSchoolID) & DataLevel ==3
save "`temp3'", replace
clear
use "`temp2'"
gen StateAssignedSchID1 = ""
replace StateAssignedSchID1 = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 1
replace StateAssignedSchID1 = StateAssignedSchID if strlen(StateAssignedSchID) ==2
gen UniqueSchID = UniqueDistID + "-" + StateAssignedSchID1
drop UniqueDistID StateAssignedSchID1


save "`temp2'", replace
clear
use "`NCES_School'/NCES_`prevyear2'_School.dta"
rename SchLevel SchLevel1
rename SchVirtual SchVirtual1
rename seasch seasch1
rename DistCharter DistCharter1
keep if state_fips == 46
gen UniqueDistID = state_leaid
gen StateAssignedSchID1 = ""
replace StateAssignedSchID1 = "0" + seasch if strlen(seasch) == 1
replace StateAssignedSchID1 = seasch if strlen(seasch) ==2
gen UniqueSchID = UniqueDistID + "-" + StateAssignedSchID1
drop UniqueDistID StateAssignedSchID1
merge 1:m UniqueSchID using "`temp2'"
tab SchName if _merge ==3
drop if _merge==1
append using "`temp3'"
save "`temp1'", replace
clear
use "`temp1'"
replace NCESSchoolID = ncesschoolid if missing(NCESSchoolID)
replace SchType = school_type if missing(SchType)
replace NCESDistrictID = ncesdistrictid if missing(NCESDistrictID)
replace DistType = district_agency_type if missing(DistType)
replace seasch = seasch1 if missing(seasch)
replace DistCharter = DistCharter1 if missing(DistCharter)
replace SchLevel = SchLevel1 if missing(SchLevel)
replace SchVirtual = SchVirtual1 if missing(SchVirtual)
replace CountyName = county_name if missing(CountyName)
replace CountyCode = county_code if missing(CountyCode)
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
foreach n in 1 2 3 {
	erase "`temp`n''"
}

//Rest are missing
label def school_typedf 16 "MISSING", add
label def agency_typedf 16 "MISSING", add
label def school_leveldf 16 "MISSING", add
replace NCESSchoolID = "MISSING" if (missing(NCESSchoolID) & DataLevel ==3)
replace SchType = 16 if NCESSchoolID == "MISSING"
replace NCESDistrictID = "MISSING" if NCESSchoolID == "MISSING" | (missing(NCESDistrictID) & DataLevel !=1)
replace DistType = 16 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace seasch = "MISSING" if NCESSchoolID == "MISSING"
replace DistCharter = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace SchLevel = 16 if NCESSchoolID == "MISSING"
replace SchVirtual = "Missing/not reported" if NCESSchoolID == "MISSING"
replace CountyName = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace CountyCode = 0 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"

}
if `year' == 2012 {
	drop if strpos(SchName, "Eureka Kindergarten") !=0 //Data seems to be duplicated from Eureka Elem, also not in NCES data. Also doesn't make sense for a kindergarden to have Grades 3-5
	label def school_typedf 16 "MISSING", add
label def agency_typedf 16 "MISSING", add
label def school_leveldf 16 "MISSING", add
replace NCESSchoolID = "467560001326" if strpos(SchName, "Wakpala Jr. High") !=0
replace SchType = 1 if strpos(SchName, "Wakpala Jr. High") !=0
replace NCESDistrictID = "4675600" if strpos(SchName, "Wakpala Jr. High") !=0
replace DistType = 1 if strpos(SchName, "Wakpala Jr. High") !=0
replace seasch = "04" if strpos(SchName, "Wakpala Jr. High") !=0
replace DistCharter = "No" if strpos(SchName, "Wakpala Jr. High") !=0
replace SchLevel = 2 if strpos(SchName, "Wakpala Jr. High") !=0
replace SchVirtual = "Missing/not reported" if strpos(SchName, "Wakpala Jr. High") !=0
replace CountyName = upper("Corson County") if strpos(SchName, "Wakpala Jr. High") !=0
replace CountyCode = 46031 if strpos(SchName, "Wakpala Jr. High") !=0

//Other is missing from NCES
replace NCESSchoolID = "MISSING" if (missing(NCESSchoolID) & DataLevel ==3)
replace SchType = 16 if NCESSchoolID == "MISSING"
replace NCESDistrictID = "MISSING" if NCESSchoolID == "MISSING" | (missing(NCESDistrictID) & DataLevel !=1)
replace DistType = 16 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace seasch = "MISSING" if NCESSchoolID == "MISSING"
replace DistCharter = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace SchLevel = 16 if NCESSchoolID == "MISSING"
replace SchVirtual = "Missing/not reported" if NCESSchoolID == "MISSING"
replace CountyName = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace CountyCode = 0 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
}

if `year' == 2013 {
label def school_typedf 16 "MISSING", add
label def agency_typedf 16 "MISSING", add
label def school_leveldf 16 "MISSING", add
replace NCESSchoolID = "467560001326" if strpos(SchName, "Wakpala Jr. High") !=0
replace SchType = 1 if strpos(SchName, "Wakpala Jr. High") !=0
replace NCESDistrictID = "4675600" if strpos(SchName, "Wakpala Jr. High") !=0
replace DistType = 1 if strpos(SchName, "Wakpala Jr. High") !=0
replace seasch = "04" if strpos(SchName, "Wakpala Jr. High") !=0
replace DistCharter = "No" if strpos(SchName, "Wakpala Jr. High") !=0
replace SchLevel = 2 if strpos(SchName, "Wakpala Jr. High") !=0
replace SchVirtual = "Missing/not reported" if strpos(SchName, "Wakpala Jr. High") !=0
replace CountyName = upper("Corson County") if strpos(SchName, "Wakpala Jr. High") !=0
replace CountyCode = 46031 if strpos(SchName, "Wakpala Jr. High") !=0

//Other two are missing from NCES
replace NCESSchoolID = "MISSING" if (missing(NCESSchoolID) & DataLevel ==3)
replace SchType = 16 if NCESSchoolID == "MISSING"
replace NCESDistrictID = "MISSING" if NCESSchoolID == "MISSING" | (missing(NCESDistrictID) & DataLevel !=1)
replace DistType = 16 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace seasch = "MISSING" if NCESSchoolID == "MISSING"
replace DistCharter = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace SchLevel = 16 if NCESSchoolID == "MISSING"
replace SchVirtual = "Missing/not reported" if NCESSchoolID == "MISSING"
replace CountyName = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace CountyCode = 0 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
}
if `year' == 2014 {
label def school_typedf 16 "MISSING", add
label def agency_typedf 16 "MISSING", add
label def school_leveldf 16 "MISSING", add
//Theres weird district level data where the name has several spaces and only 1 student... I'm keeping it because it's in the raw data but it doesn't give information.
replace DistName = "MISSING" if (missing(NCESSchoolID) & DataLevel ==2) | (missing(NCESDistrictID) & DataLevel !=1)
replace NCESSchoolID = "MISSING" if (missing(NCESSchoolID) & DataLevel ==3)
replace SchType = 16 if NCESSchoolID == "MISSING"
replace NCESDistrictID = "MISSING" if NCESSchoolID == "MISSING" | (missing(NCESDistrictID) & DataLevel !=1)
replace DistType = 16 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace seasch = "MISSING" if NCESSchoolID == "MISSING"
replace DistCharter = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace SchLevel = 16 if NCESSchoolID == "MISSING"
replace SchVirtual = "Missing/not reported" if NCESSchoolID == "MISSING"
replace CountyName = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace CountyCode = 0 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
}

if `year' == 2017 {
label def school_typedf 16 "MISSING", add
label def agency_typedf 16 "MISSING", add
label def school_leveldf 16 "MISSING", add
drop if strpos(SchName, "Out of District") !=0
label def virtualdf 16 "Missing/not reported", add
replace NCESSchoolID = "MISSING" if (missing(NCESSchoolID) & DataLevel ==3)
replace SchType = 16 if NCESSchoolID == "MISSING"
replace NCESDistrictID = "MISSING" if NCESSchoolID == "MISSING" | (missing(NCESDistrictID) & DataLevel !=1)
replace DistType = 16 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace seasch = "MISSING" if NCESSchoolID == "MISSING"
replace DistCharter = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace SchLevel = 16 if NCESSchoolID == "MISSING"
replace SchVirtual = 16 if NCESSchoolID == "MISSING"
replace CountyName = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace CountyCode = 0 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
}

if `year' == 2021 {
label def school_typedf 16 "MISSING", add
label def agency_typedf 16 "MISSING", add
label def school_leveldf 16 "MISSING", add
label def virtualdf 16 "Missing/not reported", add
replace NCESSchoolID = "MISSING" if (missing(NCESSchoolID) & DataLevel ==3)
replace SchType = 16 if NCESSchoolID == "MISSING"
replace NCESDistrictID = "MISSING" if NCESSchoolID == "MISSING" | (missing(NCESDistrictID) & DataLevel !=1)
replace DistType = 16 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace seasch = "MISSING" if NCESSchoolID == "MISSING"
replace DistCharter = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace SchLevel = 16 if NCESSchoolID == "MISSING"
replace SchVirtual = 16 if NCESSchoolID == "MISSING"
replace CountyName = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace CountyCode = 0 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"

}

if `year' == 2022 {
label def school_typedf 16 "MISSING", add
label def agency_typedf 16 "MISSING", add
label def school_leveldf 16 "MISSING", add
label def virtualdf 16 "Missing/not reported", add
replace NCESSchoolID = "MISSING" if (missing(NCESSchoolID) & DataLevel ==3)
replace SchType = 16 if NCESSchoolID == "MISSING"
replace NCESDistrictID = "MISSING" if NCESSchoolID == "MISSING" | (missing(NCESDistrictID) & DataLevel !=1)
replace DistType = 16 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace seasch = "MISSING" if NCESSchoolID == "MISSING"
replace DistCharter = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace SchLevel = 16 if NCESSchoolID == "MISSING"
replace SchVirtual = 16 if NCESSchoolID == "MISSING"
replace CountyName = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
replace CountyCode = 0 if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"
}
replace State_leaid = StateAssignedDistID if missing(State_leaid)
replace State_leaid = "MISSING" if NCESSchoolID == "MISSING" | NCESDistrictID == "MISSING"	
	
	
	
	
	
	save "`Output'/SD_AssmtData_`year'.dta" , replace
	export delimited "`Output'/SD_AssmtData_`year'", replace	
}
*do "/Volumes/T7/State Test Project/South Dakota/Unmerged Schools & Districts.do"
