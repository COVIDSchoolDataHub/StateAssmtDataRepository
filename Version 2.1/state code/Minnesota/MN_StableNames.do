* MINNESOTA

* File name: MN_StableNames
* Last update: 2/24/2025

*******************************************************
* Notes

	* This do file imports mn_full-dist-sch-stable-list_through2024.
	* It loops through temporary output files created in MN_AssmtData_`year'.do
	* and replaces District and School Names.
	* Some additional cleaning is also done here. 
	* The resulting output is saved in 
	* a) the output folder (1998-2013)
	* b) the non-derivation output folder (2014-2022).
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear

//Importing
import excel "${Stable}/mn_full-dist-sch-stable-list_through2024", firstrow case(preserve) allstring

//Fixing DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

save "${Temp}/MN_StableNames_Sch", replace
duplicates drop NCESDistrictID SchYear, force
drop NCESSchoolID newschname olddistname oldschname
gen SchName = "All Schools"
replace DataLevel = 2

append using "${Temp}/MN_StableNames_Sch"
sort DataLevel
duplicates drop SchYear DataLevel NCESDistrictID NCESSchoolID, force
save "${Temp}/MN_StableNames", replace
clear

//Looping Through Years
forvalues year = 1998/2024 {
	if `year' == 2020 continue
use "${Temp}/MN_StableNames"
local prevyear = `=`year'-1'
keep if SchYear == "`prevyear'-" + substr("`year'",-2,2)
merge 1:m DataLevel NCESDistrictID NCESSchoolID using "${Temp}/MN_AssmtData_`year'", update
replace DistName = newdistname if DataLevel !=1
replace SchName = newschname if DataLevel == 3
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel ==1
drop if DistName == "Hiawatha Valley Education District" & DataLevel== 2
//Minnesota Department of Corrections
drop if DistName == "Minnesota Department of Corrections" & DataLevel== 2
//Hiawatha Valley Education District
drop if DistName == "Mid-State Education District" & DataLevel== 2


	if `year' == 2023 {
drop if DistName == "Minnesota Department of Corrections" & DataLevel == 2
	}

	if `year' == 2024 {
replace SchLevel = "Middle" if SchName == "Blooming Prairie Intermediate School"
replace SchVirtual = "No" if SchName == "Blooming Prairie Intermediate School"
replace SchLevel = "Middle" if SchName == "Community School Of Excellence - Ms"
replace SchVirtual = "No" if SchName == "Community School Of Excellence - Ms"
replace SchLevel = "Primary" if SchName == "New Heights Elementary School"
replace SchVirtual = "No" if SchName == "New Heights Elementary School"
replace SchLevel = "Middle" if SchName == "Washington Technology Middle School"
replace SchVirtual = "No" if SchName == "Washington Technology Middle School"
replace SchLevel = "Primary" if SchName == "Surad Academy"
replace SchVirtual = "No" if SchName == "Surad Academy"
replace SchVirtual = "No" if SchName == "Aspire Academy Middle School"
	}

	if `year' != 2020 { 
	replace StateFips = 27 if StateFips ==. 
	replace StateAbbrev = "MN" if StateAbbrev == ""
	replace ProficientOrAbove_percent = "1" if ProficientOrAbove_percent == "1.001000047"
	replace StateAssignedDistID="" if DataLevel==1
	replace StateAssignedSchID="" if DataLevel==1 | DataLevel==2
	replace AvgScaleScore = "*" if AvgScaleScore == "."
	replace Lev5_percent = "" if Lev5_percent != ""
	replace Lev5_count = "" if Lev5_count != ""
	replace Lev5_count = ""
	replace Lev5_percent = ""
	}

// Reordering variables and sorting data
local vars State StateAbbrev StateFips SchYear DataLevel DistName DistType 	///
    SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID 		///
    StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual 			///
    CountyName CountyCode AssmtName AssmtType Subject GradeLevel 			///
    StudentGroup StudentGroup_TotalTested StudentSubGroup 					///
    StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count 			///
    Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent 			///
    Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria 				///
    ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 	///
    Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math 	///
    Flag_CutScoreChange_sci Flag_CutScoreChange_soc
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


* Exporting usual output for 1998-2013, 2023-2024. There is no non-derivation output for these years. 
	if (`year' >= 1998) & (`year' <= 2013) {
save "${Output}/MN_AssmtData_`year'", replace
export delimited "${Output}/MN_AssmtData_`year'", replace
	}

	if (`year' == 2023) | (`year' <= 2024) {
save "${Output}/MN_AssmtData_`year'", replace
export delimited "${Output}/MN_AssmtData_`year'", replace
	}
****************************************************
*Exporting Non-Derivation Output*
	if (`year' > 2013) & (`year' <= 2022)  {
save "${Output_ND}/MN_AssmtData_`year'", replace
export delimited "${Output_ND}/MN_AssmtData_`year'", replace
	}
clear
}
* END of MN_StableNames.do
****************************************************
