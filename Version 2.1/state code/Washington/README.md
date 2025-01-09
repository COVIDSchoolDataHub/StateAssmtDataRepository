# Washington Cleaning

This is a ReadMe for Washington's cleaning process, from 2015-2024

## Setup
There are four folders you need to create:
Original Data, NCES, Output (and a folder titled "csv" within the output folder)

Download the Original csv files from the drive and place them in the original folder. Download the WA_Unmerged_2024.xlsx file and place it in your main Washington folder.

Make sure to have NCES data.

There are four do-files to download:
- Washington DTA Conversion
- Washington NCES Cleaning
- washington_updated
- washington_BIE_updated (resulting files not currently in repository)


## File path

The following file paths should be updated in all do-files:
```
cd "/Volumes/T7/State Test Project/Washington" // Set directory to main Washington folder
global raw "/Volumes/T7/State Test Project/Washington/Original Data Files" //Directory for original data files
global output "/Volumes/T7/State Test Project/Washington/Output" //Directory for Output
global NCESOLD "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024" //Directory for full unclearned NCES data
global NCES "/Volumes/T7/State Test Project/Washington/NCES" //Directory for NCES folder inside Washington folder.
```

## Re-create cleaning
Run the files in the following order

1. Washington DTA Conversion.do
2. Washington NCES Cleaning.do
3. washington_updated.do
4. washington_BIE_updated.do

## Cleaning Note
- In the main washington_updated.do file, we have rescaled level percents to align with our standards in the following way:

```
//Deriving Level Counts & Percents based on ParticipationRate
//Note: Currently Level percents are based on the ExpectedCount (basically enrollment), rather than the number of students tested. Process for deriving level counts & percents is as follows:

// 1. Derive Level Counts as PercentLevel * Expected Count
// OLD 2. Derive StudentSubGroup_TotalTested as ParticipationRate * ExpectedCount
// NEW 2. Derive StudentSubGroup_TotalTested as Sum of Derived Level Counts
// 3. Derive Lev*_percent as Lev*_count/StudentSubGroup_TotalTested

destring ExpectedCount, replace force

//1. Deriving Level Counts
forvalues n = 1/4 {
	gen Lev`n'_count = string(round(real(PercentLevel`n')*ExpectedCount)) if !missing(real(PercentLevel`n')) & !missing(ExpectedCount)
	replace Lev`n'_count = "*" if missing(Lev`n'_count)
}

//2. Derive StudentSubGroup_TotalTested
gen StudentSubGroup_TotalTested = string(real(Lev1_count) + real(Lev2_count) + real(Lev3_count) + real(Lev4_count)) //Confirmed that rows are always entirely suppressed (i.e, it's not the case that only Lev1 will be suppressed)
replace StudentSubGroup_TotalTested = "*" if missing(real(StudentSubGroup_TotalTested))

//3. Deriving Level Percents
foreach count of varlist Lev*_count {
	local percent = subinstr("`count'", "count", "percent",.)
	gen `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.3g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested))
	replace `percent' = "*" if missing(`percent')
}
```
## Updates

8/1/24: Applied new StudentGroup_TotalTested convention to all files. Investigated "NULL" values in raw data, confirmed they were correctly coded as suppressed.

9/21/24: Incorporated 2024 data, implemented changes from V2.0 Review. Updated BIE code.

12/9/24: Fixed count issues, set StudentSubGroup_TotalTested to sum of level counts rather than ParticipationRate * Enrollment

