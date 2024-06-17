clear
cd "/Volumes/T7/State Test Project/Wyoming/Output"

//Importing


forvalues year = 2014/2023 {
	if `year' == 2020 continue
	
	import delimited "WY_AssmtData_`year'", case(preserve) clear
	replace AssmtType = "Regular and alt"
	export delimited "WY_AssmtData_`year'", replace
	


}
