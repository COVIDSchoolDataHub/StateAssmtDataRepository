clear
set more off
cd "/Volumes/T7/State Test Project/Misc Cleaning/PA"
import delimited PA_AssmtData_2023, case(preserve)

replace CountyCode = "Missing/not reported" if CountyCode == "Missing/Not reported"
export delimited PA_AssmtData_2023, replace
