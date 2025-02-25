*******************************************************
* COLORADO

* File name: Colorado DTA Conversion
* Last update: 2/25/2025

*******************************************************
* Notes

	* This do file imports CO 2023 data, generates StudentGroup and Subject variables, and saves it as a dta file.
*******************************************************
/////////////////////////////////////////
*** Setup ***
clear
*******************************************************
*** Importing ***
*******************************************************


local studentgroup `" "Gender" "Race Ethnicity" "Language Proficiency" "Migrant" "IEP" "'
local subject ELA Math Science

** Converting to dta **
import excel "$Original/2023/2023 CMAS ELA and Math District and School Summary Achievement Results", sheet("CMAS ELA and Math") cellrange(A13) firstrow clear
save "${Temp}/CO_AssmtData_2023_ela_mat_allstudents.dta", replace

import excel "$Original/2023/2023 CMAS Science District and School Summary Achievement Results", sheet("CMAS Science") cellrange(A13) firstrow clear
save "${Temp}/CO_AssmtData_2023_sci_allstudents.dta", replace

foreach sub of local subject {
	foreach group of local studentgroup {
		import excel "$Original/2023/2023 CMAS `sub' District and School Disaggregated Achievement Results", sheet("`group'") cellrange(A13) firstrow clear
		drop NumberofTotalRecords NumberofNoScores StandardDeviation
		gen StudentGroup = "`group'"
		gen Subject = "`sub'"
		save "${Temp}/CO_AssmtData_2023_`sub'_`group'.dta", replace
	}
}

foreach sub of local subject {
	import excel "$Original/2023/2023 CMAS `sub' District and School Disaggregated Achievement Results", sheet("Free Reduced Lunch") cellrange(A14) firstrow clear
	drop NumberofTotalRecords NumberofNoScores StandardDeviation
	gen StudentGroup = "Economic Status"
	gen Subject = "`sub'"
	save "${Temp}/CO_AssmtData_2023_`sub'_Free Reduced Lunch.dta", replace
}
* END of Colorado DTA Conversion.do
****************************************************
