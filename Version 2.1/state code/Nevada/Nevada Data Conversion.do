*******************************************************
* NEVADA

* File name: Nevada Data Conversion
* Last update: 2/27/2025

*******************************************************
* Notes

	* This do file imports and saves NV data in a dta format. 

*******************************************************
///////////////////////////////
// Setup
///////////////////////////////
clear

local years 2016 2017 2018 2019 2021 2022 2023
local sciyears 2017 2018 2019 2021 2022 2023
local grades 3 4 5 6 7 8
local scigrades 5 8

** Converting to dta **

foreach a of local years {
	foreach b of local grades {
		import delimited "${Original}/ELA & Math/NV_OriginalData_`a'_ela_math_G0`b'.csv", varnames(3) case(preserve) clear
		gen Sub1 = "elamat"
		save "${Original}/ELA & Math/Grade `b' `a'.dta", replace
	}
}

foreach a of local sciyears {
	foreach b of local scigrades {
		import delimited "${Original}/Sci/NV_OriginalData_`a'_sci_G0`b'.csv", varnames(3) case(preserve) clear
		gen Sub1 = "sci"
		save "${Original}/Sci/Grade `b' `a'.dta", replace
	}
}

local levels "state districts schools"
foreach lev of local levels{
	if "`lev'" != "school"{
	import delimited "${Original}/ELA & Math/2024/`lev'/NV_OriginalData_2024_ela_math_G38.csv", varnames(3) stringcols(_all) case(preserve) clear
	gen Sub1 = "elamat"
	save "${Original}/ELA & Math/2024/`lev'/NV_OriginalData_2024_ela_math_G38.dta", replace
	
	import delimited "${Original}/Sci/2024/`lev'/NV_OriginalData_2024_sci_G38.csv", varnames(3) stringcols(_all) case(preserve) clear
	gen Sub1 = "sci"
	save "${Original}/Sci/2024/`lev'/NV_OriginalData_2024_sci_G38.dta", replace
	}
	foreach a of local grades{
		import delimited "${Original}/ELA & Math/2024/`lev'/NV_OriginalData_2024_ela_math_G0`a'.csv", varnames(3) stringcols(_all) case(preserve) clear
		gen Sub1 = "elamat"
		save "${Original}/ELA & Math/2024/`lev'/NV_OriginalData_2024_ela_math_G0`a'.dta", replace
	}
	foreach b of local scigrades{
		import delimited "${Original}/Sci/2024/`lev'/NV_OriginalData_2024_sci_G0`b'.csv", varnames(3) stringcols(_all) case(preserve) clear
		gen Sub1 = "sci"
		save "${Original}/Sci/2024/`lev'/NV_OriginalData_2024_sci_G0`b'.dta", replace
	}
}

import delimited "${Original}/ELA & Math/2024/schools/NV_OriginalData_2024_ela_math_G38.csv", stringcols(_all) case(preserve) clear
gen Sub1 = "elamat"
save "${Original}/ELA & Math/2024/schools/NV_OriginalData_2024_ela_math_G38.dta", replace

import delimited "${Original}/Sci/2024/schools/NV_OriginalData_2024_sci_G38.csv", stringcols(_all) case(preserve) clear
gen Sub1 = "sci"
save "${Original}/Sci/2024/schools/NV_OriginalData_2024_sci_G38.dta", replace
* END of Nevada Data Conversion.do
****************************************************
