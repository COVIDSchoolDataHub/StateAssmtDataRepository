clear
set more off

cd "/Users/maggie/Desktop/Mississippi"

global raw "/Users/maggie/Desktop/Mississippi/Original Data Files"
global output "/Users/maggie/Desktop/Mississippi/Output"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"

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
		save "${output}/MS_AssmtData_`yr2'_G`grdsci'sciscale.dta", replace
	}
}

import excel "${raw}/MS_OriginalData_2018_all.xlsx", sheet("Grade 5 Scale Score and PL") firstrow clear
save "${output}/MS_AssmtData_2018_G5sci.dta", replace

import excel "${raw}/MS_OriginalData_2018_all.xlsx", sheet("Grade 8 Scale Score and PL") firstrow clear
save "${output}/MS_AssmtData_2018_G8sci.dta", replace

	** 2019-2023

foreach yr3 of local years3 {
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
