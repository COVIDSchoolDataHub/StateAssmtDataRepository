clear
set more off

cd "/Users/miramehta/Documents"

global raw "/Users/miramehta/Documents/KS State Testing Data/Original Data Files"
global output "/Users/miramehta/Documents/KS State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global EDFacts "/Users/miramehta/Documents/EdFacts"

global years 2015 2016 2017 2018 2019 2021 2022 2023

** Converting to dta **

foreach a in $years {
	if `a' == 2016 {
	import excel "${raw}/KS_OriginalData_`a'_all.xlsx", sheet("AssessmentResults") firstrow clear
	save "${raw}/KS_AssmtData_`a'.dta", replace		
	}
	if `a' != 2016 {
	import excel "${raw}/KS_OriginalData_`a'_all.xlsx", sheet(`a') firstrow clear
	save "${raw}/KS_AssmtData_`a'.dta", replace
	}
}

local subject math ela
local datatype count part
local datalevel school district

foreach a in $years{
	if `a' < 2022{
		foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				import delimited "${EDFacts}/`a'/edfacts`type'`a'`sub'`lvl'.csv", clear
				save "${EDFacts}/`a'/edfacts`type'`a'`sub'`lvl'.dta", replace
				}
			}
		}
	}
}
