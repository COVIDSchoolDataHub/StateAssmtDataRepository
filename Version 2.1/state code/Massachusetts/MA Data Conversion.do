*******************************************************
* MASSACHUSETTS

* File name: MA Data Conversion
* Last update: 2/27/2025

*******************************************************
* Notes

	* This do file imports and saves MA data in a dta format. 

*******************************************************
///////////////////////////////
// Setup
///////////////////////////////
clear

//2010-2014 Data
local spreadsheets "MA_OriginalData_Dist_all_2010_2014_Legacy_MCAS MA_OriginalData_Sch_all_2010_2011_Legacy_MCAS MA_OriginalData_Sch_all_2010_Legacy_MCAS MA_OriginalData_Sch_all_2012_2014_Legacy_MCAS"

foreach sheet of local spreadsheets {
	import excel "$Original/`sheet'.xlsx", allstring clear
	save "$Original_DTA/`sheet'", replace
}

//2015-2016 Data
local spreadsheets "MA_OriginalData_Dist_all_2015_2018_Legacy_MCAS MA_OriginalData_Dist_ela_math_2015_2016_PARCC MA_OriginalData_Sch_all_2015_2018_Legacy_MCAS MA_OriginalData_Sch_ela_math_2015_2016_PARCC"

foreach sheet of local spreadsheets {
	import excel "$Original/`sheet'.xlsx", allstring clear
	save "$Original_DTA/`sheet'", replace
}

//2017-2024 Data
forvalues year = 2017/2024 {
	import delimited "$Original/MA_OriginalData_2017_2024", case(preserve) clear
	if `year' == 2020 continue
	keep if SY == `year'
	save "$Original_DTA/MA_OriginalData_`year'", replace
	
}

//Participation Data
import excel "$Original/MA_ParticipationRate_Dist", clear
save "$Original_DTA/MA_ParticipationRate_Dist", replace
import excel "$Original/MA_ParticipationRate_Sch", clear
save "$Original_DTA/MA_ParticipationRate_Sch", replace

//Unmerged Data
import excel "$Original/MA_Unmerged_2024.xlsx", firstrow case(preserve) allstring clear
save "$Original_DTA/MA_Unmerged_2024", replace

//Stable Names
import excel "$Original/ma_full-dist-sch-stable-list_through2024", firstrow case(preserve) allstring clear
drop DataLevel
gen DataLevel = 3
save MA_SchNames, replace
duplicates drop SchYear NCESDistrictID, force
replace DataLevel = 2
drop *schname NCESSchoolID
save MA_DistNames, replace
append using MA_SchNames
duplicates drop SchYear NCESDistrictID NCESSchoolID, force
save "$Original_DTA/MA_StableNames", replace
* END of MA Data Conversion.do
****************************************************
