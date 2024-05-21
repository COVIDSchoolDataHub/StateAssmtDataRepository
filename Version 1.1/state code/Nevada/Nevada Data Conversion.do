clear
set more off

cd "/Users/maggie/Desktop/Nevada"

global raw "/Users/maggie/Desktop/Nevada/Original Data Files"
global output "/Users/maggie/Desktop/Nevada/Output"
global NCES "/Users/maggie/Desktop/Nevada/NCES/Cleaned"

local years 2016 2017 2018 2019 2021 2022 2023
local sciyears 2017 2018 2019 2021 2022 2023
local grades 3 4 5 6 7 8
local scigrades 5 8

** Converting to dta **

foreach a of local years {
	foreach b of local grades {
		import delimited "${raw}/ELA & Math/Grade `b' `a'.csv", varnames(3) case(preserve) clear
		save "${raw}/ELA & Math/Grade `b' `a'.dta", replace
	}
}

foreach a of local sciyears {
	foreach b of local scigrades {
		import delimited "${raw}/Sci/Grade `b' `a'.csv", varnames(3) case(preserve) clear
		save "${raw}/Sci/Grade `b' `a'.dta", replace
	}
}
