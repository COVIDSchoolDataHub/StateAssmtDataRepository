clear
set more off

cd "/Users/maggie/Desktop/Colorado"

global raw "/Users/maggie/Desktop/Colorado/Original Data Files"
global output "/Users/maggie/Desktop/Colorado/Output"
global NCES "/Users/maggie/Desktop/Colorado/NCES/Cleaned"

local studentgroup `" "Gender" "Race Ethnicity" "Language Proficiency" "'
local subject ELA Math Science

** Converting to dta **
	
import excel "${raw}/2023 CMAS ELA and Math District and School Summary Achievement Results", sheet("CMAS ELA and Math") cellrange(A13) firstrow clear
save "${output}/CO_AssmtData_2023_ela_mat_allstudents.dta", replace

import excel "${raw}/2023 CMAS Science District and School Summary Achievement Results", sheet("CMAS Science") cellrange(A13) firstrow clear
save "${output}/CO_AssmtData_2023_sci_allstudents.dta", replace

foreach sub of local subject {
	foreach group of local studentgroup {
		import excel "${raw}/2023 CMAS `sub' District and School Disaggregated Achievement Results", sheet("`group'") cellrange(A13) firstrow clear
		drop NumberofTotalRecords NumberofNoScores StandardDeviation
		gen StudentGroup = "`group'"
		gen Subject = "`sub'"
		save "${output}/CO_AssmtData_2023_`sub'_`group'.dta", replace
	}
}

foreach sub of local subject {
	import excel "${raw}/2023 CMAS `sub' District and School Disaggregated Achievement Results", sheet("Free Reduced Lunch") cellrange(A14) firstrow clear
	drop NumberofTotalRecords NumberofNoScores StandardDeviation
	gen StudentGroup = "Economic Status"
	gen Subject = "`sub'"
	save "${output}/CO_AssmtData_2023_`sub'_Free Reduced Lunch.dta", replace
}
