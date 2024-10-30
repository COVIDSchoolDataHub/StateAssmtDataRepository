clear
set more off

cd "/Users/miramehta/Documents"

global raw "/Users/miramehta/Documents/Nevada/Original Data Files"
global output "/Users/miramehta/Documents/Nevada/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

local years 2016 2017 2018 2019 2021 2022 2023
local sciyears 2017 2018 2019 2021 2022 2023
local grades 3 4 5 6 7 8
local scigrades 5 8

** Converting to dta **

foreach a of local years {
	foreach b of local grades {
		import delimited "${raw}/ELA & Math/NV_OriginalData_`a'_ela_math_G0`b'.csv", varnames(3) case(preserve) clear
		gen Sub1 = "elamat"
		save "${raw}/ELA & Math/Grade `b' `a'.dta", replace
	}
}

foreach a of local sciyears {
	foreach b of local scigrades {
		import delimited "${raw}/Sci/NV_OriginalData_`a'_sci_G0`b'.csv", varnames(3) case(preserve) clear
		gen Sub1 = "sci"
		save "${raw}/Sci/Grade `b' `a'.dta", replace
	}
}

local levels "state districts schools"
foreach lev of local levels{
	if "`lev'" != "school"{
	import delimited "${raw}/ELA & Math/2024/`lev'/NV_OriginalData_2024_ela_math_G38.csv", varnames(3) stringcols(_all) case(preserve) clear
	gen Sub1 = "elamat"
	save "${raw}/ELA & Math/2024/`lev'/NV_OriginalData_2024_ela_math_G38.dta", replace
	import delimited "${raw}/Sci/2024/`lev'/NV_OriginalData_2024_sci_G38.csv", varnames(3) stringcols(_all) case(preserve) clear
	gen Sub1 = "sci"
	save "${raw}/Sci/2024/`lev'/NV_OriginalData_2024_sci_G38.dta", replace
	}
	foreach a of local grades{
		import delimited "${raw}/ELA & Math/2024/`lev'/NV_OriginalData_2024_ela_math_G0`a'.csv", varnames(3) stringcols(_all) case(preserve) clear
		gen Sub1 = "elamat"
		save "${raw}/ELA & Math/2024/`lev'/NV_OriginalData_2024_ela_math_G0`a'.dta", replace
	}
	foreach b of local scigrades{
		import delimited "${raw}/Sci/2024/`lev'/NV_OriginalData_2024_sci_G0`b'.csv", varnames(3) stringcols(_all) case(preserve) clear
		gen Sub1 = "sci"
		save "${raw}/Sci/2024/`lev'/NV_OriginalData_2024_sci_G0`b'.dta", replace
	}
}

import delimited "${raw}/ELA & Math/2024/schools/NV_OriginalData_2024_ela_math_G38.csv", stringcols(_all) case(preserve) clear
gen Sub1 = "elamat"
save "${raw}/ELA & Math/2024/schools/NV_OriginalData_2024_ela_math_G38.dta", replace
import delimited "${raw}/Sci/2024/schools/NV_OriginalData_2024_sci_G38.csv", stringcols(_all) case(preserve) clear
gen Sub1 = "sci"
save "${raw}/Sci/2024/schools/NV_OriginalData_2024_sci_G38.dta", replace
