clear
set more off

global MS "/Volumes/T7/State Test Project/Mississippi"
global raw "/Volumes/T7/State Test Project/Mississippi/Original Data Files"
global output "/Volumes/T7/State Test Project/Mississippi/Output"
global NCES "/Volumes/T7/State Test Project/Mississippi/NCES"
global Request "/Volumes/T7/State Test Project/Mississippi/Original Data Files/Data Request"

** Preparing data request files

local requestyear 2015 2016 2017 2018 2019 2021 2022 2023
local subject math ela sci
local datatype performance participation
local datalevel district school state

/*
// converting to dta
foreach year of local requestyear {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				import excel "${Request}/`year'/`sub'`type'/`lvl'.xlsx", cellrange(A2) firstrow clear
				save "${Request}/`year'/`sub'`type'/`lvl'.dta", replace
			}
		}
	}
}
*/

// checking variables
foreach year of local requestyear {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				use "${Request}/`year'/`sub'`type'/`lvl'.dta", clear
				display `year' "`sub'" "`type'" "`lvl'"
				if ("`type'"  == "performance"){
					tab level
				}
			}
		}
	}
}

// cleaning variables
foreach year of local requestyear {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				use "${Request}/`year'/`sub'`type'/`lvl'.dta", clear
				
				drop table
				
				rename dist StateAssignedDistID
				tostring StateAssignedDistID, replace
				replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 3
				
				if (`year' > 2016) {
				replace StateAssignedDistID = "MS-" + StateAssignedDistID
				}
				
				rename sch StateAssignedSchID
				tostring StateAssignedSchID, replace force
				replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 6
				
				if (`year' > 2016) {
				replace StateAssignedSchID = subinstr(StateAssignedDistID, "MS-", "", .) + "-" + StateAssignedSchID
				}
				
				rename grade GradeLevel
				if (`year' < 2020) {
					drop if GradeLevel == 10
					tostring GradeLevel, replace force
				}
				if (`year' > 2020) {
					drop if GradeLevel == "HS"
				}
				replace GradeLevel = "G0" + GradeLevel
				
				gen StudentGroup = ""
				replace StudentGroup = "RaceEth" if race != ""
				replace StudentGroup = "Gender" if gender != ""
				replace StudentGroup = "EL Status" if lep != ""
				replace StudentGroup = "Economic Status" if ecodis != ""
				replace StudentGroup = "All Students" if ind == "Y"
				drop if StudentGroup == ""
				
				gen StudentSubGroup = ""
				replace StudentSubGroup = race if StudentGroup == "RaceEth"
				replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "MAN"
				replace StudentSubGroup = "Asian" if StudentSubGroup == "MA"
				replace StudentSubGroup = "Black or African American" if StudentSubGroup == "MB"
				replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "MNP"
				replace StudentSubGroup = "Two or More" if StudentSubGroup == "MM"
				replace StudentSubGroup = "White" if StudentSubGroup == "MW"
				replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "MHL"
				replace StudentSubGroup = gender if StudentGroup == "Gender"
				replace StudentSubGroup = "Male" if StudentSubGroup == "M"
				replace StudentSubGroup = "Female" if StudentSubGroup == "F"
				replace StudentSubGroup = lep if StudentGroup == "EL Status"
				replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
				replace StudentSubGroup = ecodis if StudentGroup == "Economic Status"
				replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECODIS"
				replace StudentSubGroup = "All Students" if StudentGroup == "All Students"
				drop race-ecodis ind
				
				if "`lvl'" == "state" {
					gen DataLevel = "State"
					replace StateAssignedDistID = ""
					replace StateAssignedSchID = ""
				}
				if "`lvl'" == "district" {
					gen DataLevel = "District"
					replace StateAssignedSchID = ""
				}
				if "`lvl'" == "school" {
					gen DataLevel = "School"
				}
				
				gen Subject = "`sub'"
				gen SchYear = "`year'"
				
				if ("`sub'" != "sci" & `year' < 2018) {
					keep if year == "FULLYR"
					drop year
				}
				
				rename type AssmtType
				
				if ("`type'" == "performance") {
					keep if AssmtType == "REGASSWOACC"
					replace AssmtType = "Regular"
					reshape wide cnt, i(StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup) j(level) string
					
					if (`year' < 2020) {
						rename cntL* Lev*_count
					}
						
					if (`year' > 2020) {
						rename cntPROFICIENT ProficientOrAbove_count
						rename cntNOTPROFICIENT NotProficient_count
					}

				}
				 
				if ("`type'" == "participation"){
					keep if AssmtType == "REGPARTWOACC"
					replace AssmtType = "Regular"
					rename cnt StudentSubGroup_TotalTested
				}
				
				save "${Request}/`year'/`sub'`type'/`lvl'cleaned.dta", replace
				
			}
		}
	}
}

//checking for duplicates
foreach year of local requestyear {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				use "${Request}/`year'/`sub'`type'/`lvl'cleaned.dta", clear
				display `year' "`sub'" "`type'" "`lvl'"
				sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
				quietly by DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup: gen dup = cond(_N==1,0,_n)
				tab dup if dup > 1
			}
		}
	}
}


** Preparing original data files

local year1 2016 2017 2018
local year2 2016 2017
local year3 2019 2021 2022 2023
local grade 3 4 5 6 7 8
local gradesci 5 8
local subject1 ELA Math
local subject2 ELA MATH

** Converting to dta **

	** 2014
	
import excel "${raw}/MS_OriginalData_2014_all.xls", sheet("MCT2 13-14") firstrow clear
save "${raw}/MS_AssmtData_2014_ela_mat.dta", replace

import excel "${raw}/MS_OriginalData_2014_all.xls", sheet("MST 2013-2014") firstrow clear
gen Subject = "sci"
save "${raw}/MS_AssmtData_2014_sci.dta", replace

	** 2015
	
import excel "${raw}/MS_OriginalData_2015_all.xlsx", sheet("Table 1") firstrow clear
save "${raw}/MS_AssmtData_2015_all.dta", replace

	** 2016-2018

foreach yr1 of local year1 {
	foreach grd of local grade {
		foreach sub of local subject1 {
		import excel "${raw}/MS_OriginalData_`yr1'_all.xlsx", sheet("G`grd'`sub'_Sch") firstrow clear
		save "${raw}/MS_AssmtData_`yr1'_G`grd'`sub'.dta", replace
		}
	}
}

foreach yr2 of local year2 {
	foreach grdsci of local gradesci {
		import excel "${raw}/MS_OriginalData_`yr2'_all.xlsx", sheet("Grade `grdsci' PL") firstrow clear
		save "${raw}/MS_AssmtData_`yr2'_G`grdsci'sci.dta", replace
		import excel "${raw}/MS_OriginalData_`yr2'_all.xlsx", sheet("Grade `grdsci' Scale Score") firstrow clear
		rename Grade* SchName
		rename AverageofSS AvgScaleScore
		gen row = _n
		save "${raw}/MS_AssmtData_`yr2'_G`grdsci'sciscale.dta", replace
	}
}

foreach grdsci of local gradesci {
	import excel "${raw}/MS_OriginalData_2018_all.xlsx", sheet("Grade `grdsci' Scale Score and PL") firstrow clear
	save "${raw}/MS_AssmtData_2018_G`grdsci'sci.dta", replace
}

	** 2019-2023

foreach yr3 of local year3 {
	foreach grd of local grade {
		foreach sub of local subject2 {
		import excel "${raw}/MS_OriginalData_`yr3'_all.xlsx", sheet("G`grd' `sub'") firstrow clear
		save "${raw}/MS_AssmtData_`yr3'_G`grd'`sub'.dta", replace
		}
	}
	foreach grdsci of local gradesci {
		import excel "${raw}/MS_OriginalData_`yr3'_all.xlsx", sheet("G`grdsci' SCIENCE") firstrow clear
		save "${raw}/MS_AssmtData_`yr3'_G`grdsci'sci.dta", replace
	}
}



	** 2024
	//ELA and math data
foreach sub in ELA Math {
	forvalues n = 3/8 {
		import excel "${raw}/MS_OriginalData_2024_ela_math_WITH IDs ADDED", sheet("G`n' `sub'") firstrow clear
		rename Grade`n'`sub'DistrictSchool Entity
		drop if Entity == "Grand Total" | Entity == "*N-counts less than 10 are suppressed." | Entity == "‡ Assessment results unavailable due to ongoing test security investigations."
		save "${raw}/MS_OriginalData_2024_`sub'_G`n'", replace
	}
}
import excel "${raw}/MS_OriginalData_2024_ela_math_WITH IDs ADDED", sheet("State Summary") firstrow clear
save "${raw}/MS_OriginalData_2024_ela_math_state", replace

	// Science data
foreach n in 5 8 {
		import excel "${raw}/MS_OriginalData_2024_sci_WITH IDs ADDED", sheet("G`n' Science") firstrow clear
		rename Grade`n'ScienceDistrictSchool Entity
		drop if Entity == "Grand Total" | Entity == "*N-counts less than 10 are suppressed." | Entity == "‡ Assessment results unavailable due to ongoing test security investigations."
		save "${raw}/MS_OriginalData_2024_sci_G`n'", replace
}
import excel "${raw}/MS_OriginalData_2024_sci_WITH IDs ADDED", sheet("State Summary") firstrow clear
save "${raw}/MS_OriginalData_2024_sci_state", replace

//Stable Names and Unmerged Spreadsheets
import excel "$MS/ms_full-dist-sch-stable-list_through2024", firstrow clear allstring
save "$MS/ms_full-dist-sch-stable-list_through2024", replace
import excel "$MS/MS Unmerged_2019_Sci", firstrow clear allstring
save "$MS/MS Unmerged_2019_Sci", replace


	
	
