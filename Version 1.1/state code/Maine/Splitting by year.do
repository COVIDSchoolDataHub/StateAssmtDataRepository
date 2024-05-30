clear
set more off

global Original "/Volumes/T7/State Test Project/Maine/Original Data Files"

//2016-2022
import excel "$Original/Maine_OriginalData_2016-2022", firstrow case(preserve) sheet("Assessments")
save "$Original/Maine_OriginalData_2016-2022", replace
forvalues year = 2016/2022 {
	if `year' == 2020 continue
	local prevyear `=`year'-1'
	
keep if Year == "`prevyear'-`year'"
export delimited "$Original/Maine_OriginalData_`year'1", replace
clear
}

//2023
import excel "$Original/Maine_OriginalData_2023", firstrow case(preserve) sheet("Assessments")
keep if Year == "2022-2023"
export delimited "$Original/Maine_OriginalData_2023", replace
save "$Original/Maine_OriginalData_2023", replace
clear

