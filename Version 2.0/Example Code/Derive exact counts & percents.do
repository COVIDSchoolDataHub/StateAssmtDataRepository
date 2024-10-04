//Derive Exact count/percent where we have range and corresponding exact count/percent and StudentSubGroup_TotalTested
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	replace `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.3g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`percent'))
	replace `count' = string(round(real(`percent')* real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}
