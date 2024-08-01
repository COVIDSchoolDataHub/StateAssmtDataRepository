### Washington Cleaning Notes

WA only uses the following do-files:
- Washington DTA Conversion.do
- Washington NCES Cleaning.do
- washington_updated.do

- washington_BIE_updated.do is **NOT** currently being used; BIE schools not currently in repository. If we want to update BIE schools, we need to change the rescaling code to match the code in washington_updated.do. In the main washington_updated.do file, this is represented by the following code:

```
//Deriving Level Counts & Percents based on ParticipationRate
//Note: Currently Level percents are based on the ExpectedCount (basically enrollment), rather than the number of students tested. Process for deriving level counts & percents is as follows:

// 1. Derive Level Counts as PercentLevel * Expected Count
// 2. Derive StudentSubGroup_TotalTested as ParticipationRate * ExpectedCount
// 3. Derive Lev*_percent as Lev*_count/StudentSubGroup_TotalTested

destring ExpectedCount, replace force

//1. Deriving Level Counts
forvalues n = 1/4 {
	gen Lev`n'_count = string(round(real(PercentLevel`n')*ExpectedCount)) if !missing(real(PercentLevel`n')) & !missing(ExpectedCount)
	replace Lev`n'_count = "*" if missing(Lev`n'_count)
}

//2. Derive StudentSubGroup_TotalTested
gen StudentSubGroup_TotalTested = string(round(real(ParticipationRate) * ExpectedCount)) if !missing(real(ParticipationRate)) & !missing(ExpectedCount)
replace StudentSubGroup_TotalTested = "*" if missing(StudentSubGroup_TotalTested)

//3. Deriving Level Percents
foreach count of varlist Lev*_count {
	local percent = subinstr("`count'", "count", "percent",.)
	gen `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.3g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested))
	replace `percent' = "*" if missing(`percent')
}
```
# Updates

8/1/24: Applied new StudentGroup_TotalTested convention to all files. Investigated "NULL" values in raw data, confirmed they were correctly coded as suppressed.
