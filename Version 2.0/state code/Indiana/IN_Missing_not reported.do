clear
cd "/Volumes/T7/State Test Project/Misc Cleaning/IN"

use "IN_AssmtData_2023"
replace CountyCode = "Missing/not reported" if CountyCode == "Missing/Not reported"

export delimited IN_AssmtData_2023, replace
