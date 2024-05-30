clear
set more off
forvalues year = 2015/2022 {
	if `year' == 2020 {
		continue
	}
local prevyear =`=`year'-1'
import excel "/Volumes/T7/State Test Project/Maine/Original Data Files/Maine_OriginalData_All.xlsx", sheet(Assessments) firstrow case(preserve)
keep if Year == "`prevyear'-`year'"
export delimited "/Volumes/T7/State Test Project/Maine/Original Data Files/Maine_OriginalData_`year'.csv"
save "/Volumes/T7/State Test Project/Maine/Original Data Files/Maine_OriginalData_`year'.dta", replace
clear
}
