clear
set more off
set trace off

global Original "/Volumes/T7/State Test Project/Indiana/Original Data Files - Version 1.1"
global temp "/Volumes/T7/State Test Project/Indiana/Original Data Files - Version 1.1/temp"
global Output "/Volumes/T7/State Test Project/Indiana/Output"
global NCES_New "/Volumes/T7/State Test Project/Indiana/NCES"

//Importing and Combining
local SubGroups1 "OVERALL ETHNICITY GENDER FRL SPED ELL FOSTER HOMELESS ACTIVE_DUTY"
local SubGroups2 "ETHNICITY GENDER FRL SPED ELL"

forvalues year = 2014/2023 {

if `year' == 2020 continue	
	tempfile tempdistschool
	save "`tempdistschool'", replace emptyok
	clear
	
	foreach Subject in ELA MATH {
		foreach DataLevel in LEA SCH {
				foreach SG of local SubGroups2 {
					if `year' < 2019 import excel using "${Original}/IN_`year'_`DataLevel'_`Subject'_ISTEP.xlsx", sheet("`Subject'_`SG'") clear
					if `year' > 2018 import excel using "${Original}/IN_`year'_`DataLevel'_`Subject'_ILEARN.xlsx", sheet("`Subject'_`SG'") clear
					foreach var of varlist _all {
						local newvar = `var'[2] + `var'[1]
						local newvar = subinstr("`newvar'", " ", "",.)
						local newvar = lower("`newvar'")
						local newvar = subinstr("`newvar'", "%", "_per",.)
						local newvar = subinstr("`newvar'", "americanindian", "AI",.)
						local newvar = subinstr("`newvar'", "nativehawaiianorotherpacificislander","NH",.)
						local newvar = subinstr("`newvar'", "/", "",.)
						local newvar = subinstr("`newvar'", "freereducedpricemeals", "FRP",.)
						local newvar = subinstr("`newvar'", "generaleducation", "GE",.)
						local newvar = subinstr("`newvar'", "specialeducation", "SWD",.)
						local newvar = subinstr("`newvar'", "multiracial", "MR",.)
						local newvar = subinstr("`newvar'", "-","",.)
						//Level percents across years
						if `year' < 2019 local newvar = subinstr("`newvar'", "belowproficiency", "Lev1_count_",.)
						if `year' < 2019 local newvar = subinstr("`newvar'", "atproficiency", "Lev2_count_",.)
						if `year' < 2019 local newvar = subinstr("`newvar'", "aboveproficiency", "Lev3_count_",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "belowproficiency", "Lev1_count_",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "approachingproficiency", "Lev2_count_",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "atproficiency", "Lev3_count_",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "aboveproficiency", "Lev4_count_",.)
						
						
						
						
						rename `var' `newvar'
					}
					drop in 1/2
					save "${temp}/`Subject'_`DataLevel'_`SG'", replace
					clear
				}
				use "${temp}/`Subject'_`DataLevel'_GENDER"
				//Flagging here that for 2018 *AND* 2019, LEA ELA "GENDER", there are duplicate values. Arbitarily dropping below for now.
				if `year' == 2018 | `year' == 2019 duplicates drop grade idoe_corporation_id, force
				
				foreach SG in ETHNICITY FRL SPED ELL {
				if "`DataLevel'" == "LEA" merge 1:1 grade idoe_corporation_id using "${temp}/`Subject'_`DataLevel'_`SG'", nogen
				if "`DataLevel'" == "SCH" merge 1:1 grade idoe_corporation_id idoe_school_id using "${temp}/`Subject'_`DataLevel'_`SG'", nogen
				}
				gen DataLevel = "`DataLevel'"
				gen Subject = "`Subject'"
				append using "`tempdistschool'"
				save "`tempdistschool'", replace
				clear
		}
		
	}
use "`tempdistschool'"
save "${temp}/`year'_District_School", replace
clear

	
	tempfile tempstate
	save "`tempstate'", emptyok replace
	foreach Subject in ELA MATH {
			foreach SG of local SubGroups1 {
					if `year' < 2019 import excel using "${Original}/IN_`year'_SEA_`Subject'_ISTEP.xlsx", sheet("`Subject'_`SG'") clear
					if `year' > 2018 import excel using "${Original}/IN_`year'_SEA_`Subject'_ILEARN.xlsx", sheet("`Subject'_`SG'") clear
					foreach var of varlist _all {
						local newvar = `var'[1]
						local newvar = subinstr("`newvar'", " ", "",.)
						local newvar = lower("`newvar'")
						local newvar = subinstr("`newvar'", "%", "_per",.)
						local newvar = subinstr("`newvar'", "americanindian", "AI",.)
						local newvar = subinstr("`newvar'", "nativehawaiianorotherpacificislander","NH",.)
						local newvar = subinstr("`newvar'", "/", "",.)
						local newvar = subinstr("`newvar'", "freereducedpricemeals", "FRP",.)
						local newvar = subinstr("`newvar'", "generaleducation", "GE",.)
						local newvar = subinstr("`newvar'", "specialeducation", "SWD",.)
						local newvar = subinstr("`newvar'", "multiracial", "MR",.)
						local newvar = subinstr("`newvar'", "-","",.)
						//Level percents across years
						if `year' < 2019 local newvar = subinstr("`newvar'", "belowproficiency", "Lev1_count",.)
						if `year' < 2019 local newvar = subinstr("`newvar'", "atproficiency", "Lev2_count",.)
						if `year' < 2019 local newvar = subinstr("`newvar'", "aboveproficiency", "Lev3_count",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "belowproficiency", "Lev1_count",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "approachingproficiency", "Lev2_count",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "atproficiency", "Lev3_count",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "aboveproficiency", "Lev4_count",.)
					
					if "`var'" != "B" rename `var' `newvar'
					if "`var'" == "B" rename `var' StudentSubGroup
					
					}
				drop in 1
				gen DataLevel = "State"
				gen Subject = "`Subject'"
				append using "`tempstate'"
				save "`tempstate'", replace
				clear
			}
	}

use "`tempstate'"
rename proficient_per* proficiency_per*
save "${temp}/`year'_State", replace
clear				
}
