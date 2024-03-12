clear
set more off

cd "/Users/maggie/Desktop/Mississippi"

global raw "/Users/maggie/Desktop/Mississippi/Original Data Files"
global output "/Users/maggie/Desktop/Mississippi/Output"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"
global Request "/Users/maggie/Desktop/Mississippi/Data Request"

** Preparing data request files

local requestyear 2015 2016 2017 2018 2019 2021 2022 2023
local subject math ela sci
local datalevel district school state
local datatype performance participation

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

foreach year of local requestyear {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				use "${Request}/`year'/`sub'`type'/`lvl'.dta", clear
				rename lea StateAssignedDistID
				tostring(StateAssignedDistID), replace force
				replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 3
				replace StateAssignedDistID = "MS-" + StateAssignedDistID
				rename SCH StateAssignedSchID
				tostring(StateAssignedSchID), replace force
				replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 6
				replace StateAssignedSchID = subinstr(StateAssignedDistID, "MS-", "", .) + "-" + StateAssignedSchID
				drop C
				rename grade GradeLevel
				tostring(GradeLevel), replace
				if (("`type'" == "performance") & ("`year'" == "2017") & ("`sub'" == "math") & (("`lvl'" == "district") |("`lvl'" == "school"))){
						replace GradeLevel = "G" + GradeLevel
						keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")
					}
					else {
						replace GradeLevel = "G0" + GradeLevel
						keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")
				}
				gen StudentGroup = ""
				replace StudentGroup = "RaceEth" if race != ""
				replace StudentGroup = "Gender" if gender != ""
				replace StudentGroup = "EL Status" if lep != ""
				replace StudentGroup = "Economic Status" if ecodis != ""
				drop if StudentGroup == ""
				rename ASSESSMENT AssmtType
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
				drop race-ecodis
				if "`lvl'" == "state" {
					gen DataLevel = 1
					replace StateAssignedDistID = ""
					replace StateAssignedSchID = ""
				}
				if "`lvl'" == "district" {
					gen DataLevel = 2
					replace StateAssignedSchID = ""
				}
				if "`lvl'" == "school" {
					gen DataLevel = 3
				}
				gen Subject = "`sub'"
				gen SchYear = "`year'"
				if ("`sub'" != "sci" & ("`year'" == "2017" | "`year'" == "2016" | "`year'" == "2015")) {
					keep if yr == "FULLYR"
				}
				drop yr
				if ("`type'" == "performance") {
					if (("`year'" == "2017") & ("`sub'" == "sci") & ("`lvl'" == "state")){
						drop level
						rename cnt ProficientOrAbove_count
						keep if AssmtType == "REGASSWOACC"
						replace AssmtType = "Regular"
					}
					else {
						keep if level == "PROFICIENT"
						drop level
						rename cnt ProficientOrAbove_count
						if (("`year'" == "2018") & (("`sub'" == "ela") | ("`sub'" == "sci")) & ("`lvl'" == "district")){
							replace AssmtType = "Regular"
						}
						else {
							keep if AssmtType == "REGASSWOACC"
							replace AssmtType = "Regular"
						}
					}
				 }
				if ("`type'" == "participation"){
					drop level
					rename cnt StudentSubGroup_TotalTested
					keep if AssmtType == "REGPARTWOACC"
					replace AssmtType = "Regular"
				}
				save "${Request}/`year'/`sub'`type'/`lvl'cleaned.dta", replace
			}
		}
	}
}

foreach year of local requestyear {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				use "${Request}/`year'/`sub'`type'/`lvl'cleaned.dta", clear
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
save "${output}/MS_AssmtData_2014_ela_mat.dta", replace

import excel "${raw}/MS_OriginalData_2014_all.xls", sheet("MST 2013-2014") firstrow clear
gen Subject = "sci"
save "${output}/MS_AssmtData_2014_sci.dta", replace

	** 2015
	
import excel "${raw}/MS_OriginalData_2015_all.xlsx", sheet("Table 1") firstrow clear
save "${output}/MS_AssmtData_2015_all.dta", replace

	** 2016-2018

foreach yr1 of local year1 {
	foreach grd of local grade {
		foreach sub of local subject1 {
		import excel "${raw}/MS_OriginalData_`yr1'_all.xlsx", sheet("G`grd'`sub'_Sch") firstrow clear
		save "${output}/MS_AssmtData_`yr1'_G`grd'`sub'.dta", replace
		}
	}
}

foreach yr2 of local year2 {
	foreach grdsci of local gradesci {
		import excel "${raw}/MS_OriginalData_`yr2'_all.xlsx", sheet("Grade `grdsci' PL") firstrow clear
		save "${output}/MS_AssmtData_`yr2'_G`grdsci'sci.dta", replace
		import excel "${raw}/MS_OriginalData_`yr2'_all.xlsx", sheet("Grade `grdsci' Scale Score") firstrow clear
		rename Grade* SchName
		rename AverageofSS AvgScaleScore
		gen row = _n
		save "${output}/MS_AssmtData_`yr2'_G`grdsci'sciscale.dta", replace
	}
}

foreach grdsci of local gradesci {
	import excel "${raw}/MS_OriginalData_2018_all.xlsx", sheet("Grade `grdsci' Scale Score and PL") firstrow clear
	save "${output}/MS_AssmtData_2018_G`grdsci'sci.dta", replace
}

	** 2019-2023

foreach yr3 of local year3 {
	foreach grd of local grade {
		foreach sub of local subject2 {
		import excel "${raw}/MS_OriginalData_`yr3'_all.xlsx", sheet("G`grd' `sub'") firstrow clear
		save "${output}/MS_AssmtData_`yr3'_G`grd'`sub'.dta", replace
		}
	}
	foreach grdsci of local gradesci {
		import excel "${raw}/MS_OriginalData_`yr3'_all.xlsx", sheet("G`grdsci' SCIENCE") firstrow clear
		save "${output}/MS_AssmtData_`yr3'_G`grdsci'sci.dta", replace
	}
}
