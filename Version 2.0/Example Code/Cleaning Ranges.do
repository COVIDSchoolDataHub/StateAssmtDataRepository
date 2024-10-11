//Code to Convert to Decimals with Ranges

foreach var of varlist Lev*_percent ProficientOrAbove_percent ParticipationRate {
	split `var', parse("-")
	destring `var'1, replace i(*-)
	destring `var'2, replace i(*-)
	replace `var'1 = `var'1/100
	replace `var'2 = `var'2/100
	replace `var' = string(`var'1, "%9.3g") if !inlist(`var', "*", "--") & `var'2 == .
	replace `var' = string(`var'1, "%9.3g") + "-" + string(`var'2, "%9.3g") if !inlist(`var', "*", "--") & `var'2 != .
}

//Notes:
//1. varlist should only include variables that have ranges in them.  Specify which level percents 1-4 in the varlist if Lev5 is blank.
//2. DC V2.0 do files have a lot more code for handling ranges, particularly if you ever need to derive values.
//3. The first line of the loop is a good way to check whether you have ranges and if your ranges are in the correct format (i.e. that you do not multiple ranges or negative values like -.1-.2).
