clear
set trace off

local original "/Volumes/T7/State Test Project/Delaware/Original/Excel DCAS Datasets"
local output "/Volumes/T7/State Test Project/Delaware/Original/Combined .dta by DataLevel & Year"

local n = 0

foreach DataLevel in "State" "District" "School" "Charter" {
	foreach year in 2015 2016 2017 {
		if `year' == 2015 & "`DataLevel'" == "Charter" {
			continue
		}
		forvalues s = 1/100 {
			capture noisily import excel using "`original'/`DataLevel'_`year'_DCAS.xlsx", sheet("Sheet`s'") firstrow case(preserve)
			if _rc !=0 {
				continue
			}
			local n = `n' + 1
			tempfile temp`n'
			save "`temp`n''", replace
			clear
		}
		forvalues i = 1/`n' {
			capture noisily append using "`temp`i''", force
			if _rc !=0 {
				continue
			}
		}
		save "`output'/`DataLevel'_`year'_DCAS", replace
		clear
		local n = 0
	}
}
