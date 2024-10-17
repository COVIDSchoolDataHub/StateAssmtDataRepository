clear
set more off

cd "/Users/kaitlynlucas/Desktop/do files"

//Set Filepaths inside Directory Here
global original_files "/Users/kaitlynlucas/Desktop/Minnesota State Task"
global NCES_files "/Users/kaitlynlucas/Desktop/Minnesota State Task/NCES_MN"
global output_files "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN Output"
global temp_files "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN_Temp"

//Do all files
forval year = 1998/2024 {
	if `year' == 2020 continue
	do MN_`year'.do	
}
do MN_StableNames.do

use "${output_files}/MN_AssmtData_2023"
drop if DistName == "Minnesota Department of Corrections" & DataLevel == 2
save "${output_files}/MN_AssmtData_2023", replace
export delimited "${output_files}/MN_AssmtData_2023", replace

use "${output_files}/MN_AssmtData_2024"
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
save "${output_files}/MN_AssmtData_2024", replace
export delimited "${output_files}/MN_AssmtData_2024", replace

forval year = 1998/2024 {
	if `year' == 2020 continue
	use "${output_files}/MN_AssmtData_`year'"
	replace StateFips = 27 if StateFips ==. 
	replace StateAbbrev = "MN" if StateAbbrev == ""
	replace ProficientOrAbove_percent = "1" if ProficientOrAbove_percent == "1.001000047"
	replace StateAssignedDistID="" if DataLevel==1
	replace StateAssignedSchID="" if DataLevel==1 | DataLevel==2
	save "${output_files}/MN_AssmtData_`year'", replace
	export delimited "${output_files}/MN_AssmtData_`year'", replace
}

forval year = 2019/2024 {
	if `year' == 2020 continue
	use "${output_files}/MN_AssmtData_`year'"
	replace Lev5_percent = "" if Lev5_percent != ""
	replace Lev5_count = "" if Lev5_count != ""
	replace Lev5_count = ""
	replace Lev5_percent = ""
	save "${output_files}/MN_AssmtData_`year'", replace
	export delimited "${output_files}/MN_AssmtData_`year'", replace
}



/*
	//Update April 1st 2024: Response to post-launch review//
	
clear
forvalues year = 1998/2023 {
	if `year' == 2020 continue
	use "${output_files}/MN_AssmtData_`year'"

//Correcting Level 5 Count and Percent for 2006+
if `year' >= 2006 {
	foreach var of varlist Lev5* {
		replace `var' = "--"
	}
}

//Converting "--" to "*" for counts in 1998-2000
if `year' >= 1998 & `year' <= 2000 {
	foreach var of varlist Lev*_count ProficientOrAbove_count {
		replace `var' = "*" if `var' == "--"
	}
}

//Fixing Flag_AssmtNameChange
if `year' == 2011 replace Flag_AssmtNameChange = "Y" if Subject == "math"
if `year' == 2012 replace Flag_AssmtNameChange = "Y" if Subject == "sci"
if `year' == 2013 replace Flag_AssmtNameChange = "Y" if Subject == "ela"

//Changing Flags to "Not Applicable" where applicable
if `year' >= 1998 & `year' <= 2007 {
	replace Flag_CutScoreChange_sci = "Not Applicable"
}
replace Flag_CutScoreChange_soc = "Not Applicable"


	
	
save "${output_files}/MN_AssmtData_`year'", replace
export delimited "${output_files}/MN_AssmtData_`year'", replace
clear	
*/
