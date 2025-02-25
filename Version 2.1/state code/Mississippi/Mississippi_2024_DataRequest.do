clear
set more off

global raw "/Volumes/T7/State Test Project/Mississippi/Original Data Files"
global output "/Volumes/T7/State Test Project/Mississippi/Output"
global NCES "/Volumes/T7/State Test Project/Mississippi/NCES"

//Getting Files Together

** Appending Everything
tempfile tempall
save "`tempall'", emptyok replace
foreach subject in ela math sci {
	foreach dl in state dist sch {
		foreach datatype in part perf {
		use "$raw/MS_OriginalData_2024_`subject'_`dl'_`datatype'", clear
		append using "`tempall'"
		save "`tempall'", replace
		}
	}
}

** Reshaping Wide
rename PROFICIENCY ProfPart 
replace ProfPart = ASSESSMENT if missing(ProfPart)
keep if strpos(ASSESSMENT, "WOACC") | strpos(ASSESSMENT, "NPART")
keep if real(GRADE) >
