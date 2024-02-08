clear
set more off

cd "/Users/maggie/Desktop/EDFacts"

global raw "/Users/maggie/Desktop/EDFacts/Datasets"
local year 2014 2015 2016 2017 2018 2019 2021
local subject ela math
local datatype count part
local datalevel district school

** Converting to dta **

foreach yr of local year {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				import delimited "${raw}/`yr'/edfacts`type'`yr'`sub'`lvl'.csv", case(preserve) clear
				save "${raw}/`yr'/edfacts`type'`yr'`sub'`lvl'.dta", replace
			}
		}
	}
}
