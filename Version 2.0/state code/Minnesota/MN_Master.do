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
*/

	
	
save "${output_files}/MN_AssmtData_`year'", replace
export delimited "${output_files}/MN_AssmtData_`year'", replace
clear	

