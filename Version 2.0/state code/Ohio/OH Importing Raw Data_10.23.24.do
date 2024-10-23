clear
set more off

cd "/Users/miramehta/Documents"

global raw "/Users/miramehta/Documents/OH State Testing Data/Original Data"
global output "/Users/miramehta/Documents/OH State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/"
global NCES_clean "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

forvalues n = 2016/2024{
	if `n' == 2020{
		continue
	}
	local levels "School District State"
	foreach lev of local levels{
		import delimited "$raw/OH_OriginalData_`lev'_16_24.txt", clear
		keep if school_year == `n'
		gen DataLevel = "`lev'"
		tostring *_ct, replace
		save "$raw/OH_OriginalData_`n'_`lev'.dta", replace
	}
	append using "$raw/OH_OriginalData_`n'_School.dta" "$raw/OH_OriginalData_`n'_District.dta"
	save "$raw/OH_OriginalData_`n'.dta", replace
}
