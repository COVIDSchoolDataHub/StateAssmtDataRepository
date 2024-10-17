clear
set more off
set trace off

cd "/Volumes/T7/State Test Project/Massachusetts"

global Original "/Volumes/T7/State Test Project/Massachusetts/Original"
global Output "/Volumes/T7/State Test Project/Massachusetts/Output"
global NCES "/Volumes/T7/State Test Project/Massachusetts/NCES"

//2010-2014 Data
local spreadsheets "MA_OriginalData_Dist_all_2010_2014_Legacy_MCAS MA_OriginalData_Sch_all_2010_2011_Legacy_MCAS MA_OriginalData_Sch_all_2010_Legacy_MCAS MA_OriginalData_Sch_all_2012_2014_Legacy_MCAS"

foreach sheet of local spreadsheets {
	import excel "$Original/`sheet'.xlsx", allstring clear
	save "$Original/`sheet'", replace
}

//2015-2016 Data
local spreadsheets "MA_OriginalData_Dist_all_2015_2018_Legacy_MCAS MA_OriginalData_Dist_ela_math_2015_2016_PARCC MA_OriginalData_Sch_all_2015_2018_Legacy_MCAS MA_OriginalData_Sch_ela_math_2015_2016_PARCC"

foreach sheet of local spreadsheets {
	import excel "$Original/`sheet'.xlsx", allstring clear
	save "$Original/`sheet'", replace
}

//2017-2024 Data
forvalues year = 2017/2024 {
	import delimited "$Original/MA_OriginalData_2017_2024", case(preserve) clear
	if `year' == 2020 continue
	keep if SY == `year'
	save "$Original/MA_OriginalData_`year'", replace
	
}

//Participation Data
import excel "$Original/MA_ParticipationRate_Dist", clear
save "$Original/MA_ParticipationRate_Dist", replace
import excel "$Original/MA_ParticipationRate_Sch", clear
save "$Original/MA_ParticipationRate_Sch", replace

//Unmerged Data
import excel MA_Unmerged_2024.xlsx, firstrow case(preserve) allstring clear
save MA_Unmerged_2024, replace

//Stable Names
import excel ma_full-dist-sch-stable-list_through2024, firstrow case(preserve) allstring clear
drop DataLevel
gen DataLevel = 3
save MA_SchNames, replace
duplicates drop SchYear NCESDistrictID, force
replace DataLevel = 2
drop *schname NCESSchoolID
save MA_DistNames, replace
append using MA_SchNames
duplicates drop SchYear NCESDistrictID NCESSchoolID, force
save MA_StableNames, replace
