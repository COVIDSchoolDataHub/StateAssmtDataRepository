clear
set more off
set trace off
cd "/Volumes/T7/State Test Project/California"
global cd "/Volumes/T7/State Test Project/California" //treat this like the cd command and set directory as you would.

global nces "/Volumes/T7/State Test Project/California/NCES"
global NCESOld "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024" //Updated NCES files
global output "/Volumes/T7/State Test Project/California/Output" //Output Directory



//Fixing Unmerged for 2010-2016
forvalues year = 2010/2016 {
	if `year' == 2020 |`year' == 2014 continue
	
use "$output/CA_AssmtData_`year'_Stata.dta"

duplicates drop NCESDistrictID DistName NCESSchoolID SchName, force
gen missing = 1 if (substr(NCESSchoolID,1,2) != "06" & DataLevel ==3) | (missing(NCESDistrictID) & DataLevel !=1)
keep if missing == 1

tempfile temp`year'
save "`temp`year''", replace

clear
}

use "`temp2010'"
forvalues year = 2011/2016 {
	if `year' == 2020 |`year' == 2014 continue
append using "`temp`year''"
}
keep SchYear DataLevel State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID DistType DistCharter DistLocale SchLevel SchVirtual CountyName CountyCode DistName SchName StateAssignedSchID StateAssignedDistID
save "CA_Unmerged.dta", replace

//Download below file, place in main CA folder
import excel ca_unmerged_may2024, firstrow case(preserve) clear


//Cleaning File
format correctNCESSchoolID %18.3g
tostring correctNCESSchoolID, replace usedisplayformat
replace correctNCESSchoolID = "" if correctNCESSchoolID == "."
replace NCESSchoolID = correctNCESSchoolID
drop correctNCESSchoolID
replace NCESDistrictID = correctNCESDistrictID
drop correctNCESDistrictID
drop Reviewed Decision



label def DataLevel 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
order DataLevel
sort DataLevel SchYear

replace StateAssignedSchID = "0" + StateAssignedSchID if SchName == "Wieden (James A.) High"
merge 1:1 SchYear StateAssignedDistID StateAssignedSchID using "CA_Unmerged.dta"
drop if _merge ==1

//Leftover Unmerged
tempfile temp1
save "`temp1'", replace
tempfile tempmerged
keep if _merge == 3
save "`tempmerged'", replace
clear
use "`temp1'"
tempfile tempunmerged
keep if _merge == 2
save "`tempunmerged'", replace
clear

//Trying to merge by getting all NCES files together
clear
tempfile tempnces
save "`tempnces'", emptyok replace
clear
forvalues year = 2009/2022 {
use "$nces/1_NCES_`year'_District"
append using "`tempnces'"
save "`tempnces'", replace	
}

use "`tempnces'"
duplicates drop NCESDistrictID, force
replace State_leaid = substr(State_leaid,3,6)
gen StateAssignedDistID = State_leaid
duplicates drop StateAssignedDistID, force
merge 1:1 StateAssignedDistID using "`tempunmerged'", update gen(_merge2)
drop if _merge2 == 1
drop _merge _merge2

//After all that, still two unmerged observations, both in 2014-15: "California Virtual Academy @ San Diego", "James Jordan Middle."

//Appending Unmerged Back in
append using "`tempmerged'"
drop _merge
save "CA_Unmerged_2010_2016.dta", replace

forvalues year = 2010/2018 {
	if `year' == 2020 |`year' == 2014 continue
	
use "$output/CA_AssmtData_`year'_Stata.dta"	
merge m:1 StateAssignedDistID StateAssignedSchID SchYear using "CA_Unmerged_2010_2016", update replace gen(_merge1)
drop if _merge1 == 2
replace CountyName = proper(CountyName) if CountyName != "Missing/not reported"
if `year' == 2015 drop if (DistName == "California Virtual Academy @ San Diego" & missing(NCESDistrictID)) | (DistName == "James Jordan Middle" & missing(NCESDistrictID)) //dropping these two unmerged obs
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$output/CA_AssmtData_`year'.dta", replace
}

//Fixing Unmerged for 2019-2023
import excel "${cd}/ca_unmatched_unmerged_v3.xlsx", firstrow case(preserve) clear
rename state_leaid State_leaid
replace State_leaid = subinstr(State_leaid, "CA-","",.)
replace State_leaid = substr(State_leaid, 3,5)

//Variable Types
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

tostring NCESDistrictID, replace
format NCESSchoolID %18.3g
tostring NCESSchoolID, replace usedisplayformat
replace NCESSchoolID = "" if NCESSchoolID == "."

tostring StateAssignedDistID StateAssignedSchID, replace
replace StateAssignedSchID = "" if StateAssignedSchID == "."

duplicates drop

save "${cd}/Ca_Unmerged_2019_2023", replace
clear
foreach year in 2019 2021 2022 2023 {
use  "${output}/CA_AssmtData_`year'_Stata"

merge m:1 SchYear DistName SchName using "${cd}/Ca_Unmerged_2019_2023", update replace gen(merge4)
drop if merge4 == 2

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
save "${output}/CA_AssmtData_`year'", replace
clear
}

//Fixing ID's for 2023
import excel "${cd}/CA_Flagged.xlsx", firstrow cellrange(A16) clear
gen NCESSchoolID = string(new_NCESSchoolID, "%18.3g")
replace NCESSchoolID = "0" + NCESSchoolID
tostring StateAssignedSchID, replace
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 6
merge 1:1 NCESSchoolID using "${nces}/1_NCES_2022_School"
drop if _merge==2
keep StateAssignedSchID DistName SchName new_NCESSchoolID new_NCESDistrictID new_StateAssignedDistID DistType DistCharter DistLocale SchLevel SchVirtual CountyName CountyCode
merge 1:m DistName SchName using "${output}/CA_AssmtData_2023", update replace

format new_NCESSchoolID %18.3g
tostring new_NCESSchoolID new_StateAssignedDistID, usedisplayformat replace
replace new_NCESSchoolID = "" if new_NCESSchoolID == "."
replace new_StateAssignedDistID = "" if new_StateAssignedDistID == "."
replace new_StateAssignedDistID = "0" + new_StateAssignedDistID if strlen(new_StateAssignedDistID) == 6
replace NCESSchoolID = new_NCESSchoolID if !missing(new_NCESSchoolID)
replace NCESDistrictID = new_NCESDistrictID if !missing(new_NCESDistrictID)
replace StateAssignedDistID = new_StateAssignedDistID if !missing(new_StateAssignedDistID)

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
save "${output}/CA_AssmtData_2023", replace

//County Name and Code Updates Across all years
import excel "${cd}/county name and code updates.xlsx", firstrow case(preserve) clear
rename CountyName CountyName_new
rename CountyCode CountyCode_new
keep SchYear County*_new DistName SchName

duplicates drop
save "${cd}/county_updates.dta", replace

forvalues year = 2010/2023 {
if `year' == 2014 | `year' == 2020 continue
use "${output}/CA_AssmtData_`year'", clear
merge m:1 SchYear DistName SchName using "${cd}/county_updates.dta"
drop if _merge == 2
drop _merge
replace CountyCode = CountyCode_new if !missing(CountyCode_new)
replace CountyName = CountyName_new if !missing(CountyName_new)
drop County*_new

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "${output}/CA_AssmtData_`year'", replace
export delimited "${output}/CA_AssmtData_`year'", replace
}


















