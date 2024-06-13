clear
set more off
set trace off
cd "/Volumes/T7/State Test Project/California" //Set directory to main california folder

global nces "/Volumes/T7/State Test Project/California/NCES"
global NCESOld "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024" //Updated NCES files
global output "/Volumes/T7/State Test Project/California/Output" //Output Directory



//Getting Still Unmerged for each year
forvalues year = 2010/2023 {
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
forvalues year = 2011/2023 {
	if `year' == 2020 |`year' == 2014 continue
append using "`temp`year''"
}
keep SchYear DataLevel State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID DistType DistCharter DistLocale SchLevel SchVirtual CountyName CountyCode DistName SchName StateAssignedSchID StateAssignedDistID
save "CA_Unmerged.dta", replace

//Download below file, place in main CA folder
import excel ca_unmerged_may2024, firstrow case(preserve) clear //download from drive: California -> Unmerged districts -> Unmerged as of May 2024


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
save "CA_Unmerged.dta", replace

forvalues year = 2010/2016 {
	if `year' == 2020 |`year' == 2014 continue
	
use "$output/CA_AssmtData_`year'_Stata.dta"	
merge m:1 StateAssignedDistID StateAssignedSchID SchYear using "CA_Unmerged", update replace gen(_merge1)
drop if _merge1 == 2
replace CountyName = proper(CountyName)
if `year' == 2015 drop if (DistName == "California Virtual Academy @ San Diego" & missing(NCESDistrictID)) | (DistName == "James Jordan Middle" & missing(NCESDistrictID)) //dropping these two unmerged obs
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$output/CA_AssmtData_`year'_Stata.dta", replace
export delimited "${output}/CA_AssmtData_`year'.csv", replace 
}	











