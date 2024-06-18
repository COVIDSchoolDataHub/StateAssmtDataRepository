clear
set more off

cd "/Users/maggie/Desktop/EDFacts"

global raw "/Users/maggie/Desktop/EDFacts/Datasets"
local year1 2013 2014 2015 2016 2017 2018 2019 2021
local year2 2010 2011 2012
local subject ela math
local datatype count part
local datalevel district school

** Converting to dta **

foreach yr of local year2 {
	foreach sub of local subject {
		foreach lvl of local datalevel {
			if (`yr' != 2011) | ("`lvl'" != "school") {
				import delimited "${raw}/`yr'/edfactscount`yr'`sub'`lvl'.csv", case(lower) clear
				save "${raw}/`yr'/edfactscount`yr'`sub'`lvl'.dta", replace
			}
		}
	}
}

foreach sub of local subject {
	foreach lvl of local datalevel {
		import delimited "${raw}/2011/edfactscount2011`sub'school.csv", rowrange(3:) case(lower) clear
		save "${raw}/2011/edfactscount2011`sub'school.dta", replace
	}
}

foreach yr of local year1 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				import delimited "${raw}/`yr'/edfacts`type'`yr'`sub'`lvl'.csv", case(lower) clear
				save "${raw}/`yr'/edfacts`type'`yr'`sub'`lvl'.dta", replace
			}
		}
	}
}
