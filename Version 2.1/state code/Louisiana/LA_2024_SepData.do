*******************************************************
* LOUISIANA

* File name: LA_2024_SepData
* Last update: 2/19/2025

*******************************************************
* Notes

	* This do file 
	* a) imports LA's 2024 data (soc, sci, ela and math), reshapes it and saves as *.dta.  
	* b) cleans LA's 2024 data
	* c) merges with NCES School (2022), NCES District (2022) and Unmerged_2024.xlsx. 
	* This file will need to be updated when newer NCES data become available. 
*******************************************************

clear

//Run this code to extract renamed NCES 2022 District and School files for Louisiana. 
// This code is different from LA_2023_SepData.do where the NCES files are extracted and variables are renamed after merges. 
******************************************************************
//NCES Cleaning
******************************************************************
global years 2022

foreach a in $years {
	
	use "${NCES_District}/NCES_`a'_District.dta", clear 
	keep if state_location == "LA"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	keep State StateAbbrev StateFips NCESDistrictID State_leaid DistType CountyName CountyCode DistLocale DistCharter DistName
	replace State_leaid = subinstr(State_leaid, "LA-", "",.)
	
	save "${NCES_LA}/NCES_`a'_District_LA_24.dta", replace
	
	use "${NCES_School}/NCES_`a'_School.dta", clear
	keep if state_location == "LA"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType	
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName	
	rename ncesschoolid NCESSchoolID
	rename school_name SchName
	replace State_leaid = subinstr(State_leaid, "LA-", "",.)
	if `a' == 2022 rename school_type SchType
		foreach var of varlist SchType SchLevel SchVirtual {
			decode `var', gen(temp)
			drop `var'
			rename temp `var'
		}
	if `a' == 2022 {
		decode DistType, gen(temp)
		drop DistType
		rename temp DistType
	}	
	
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID State_leaid DistType CountyName CountyCode DistLocale DistCharter SchName SchType SchVirtual SchLevel seasch DistName
	drop if seasch == ""

	save "${NCES_LA}/NCES_`a'_School_LA_24.dta", replace
}

////Uncomment only for first run.
//Importing and Saving
import excel "$Original/LA_OriginalData_2024_1", cellrange(A2) allstring clear
save "$Original/LA_OriginalData_2024_1", replace
import excel "$Original/LA_OriginalData_2024_2", cellrange(A2) allstring clear
save "$Original/LA_OriginalData_2024_2", replace
use "$Original/LA_OriginalData_2024_1", clear
append using "$Original/LA_OriginalData_2024_2"
save "$Temp/LA_OriginalData_2024", replace

use "$Temp/LA_OriginalData_2024", clear

//Renaming, dropping and reshaping
foreach var of varlist J-L {
replace `var' = "AverageScaleScore" + lower(`var') in 2
}

foreach var of varlist M-W {
	replace `var' = `var' + "ela" in 2
}
drop X-BM

foreach var of varlist BN-BX {
	replace `var' = `var' + "math" in 2
}
drop BY-DT

foreach var of varlist DU-EE {
	replace `var' = `var' + "sci" in 2
}

drop EF-EZ

foreach var of varlist _all {
	replace `var' = subinstr(`var', "Total Student Tested (rounded to nearest 10th)", "StudentSubGroup_TotalTested",.) in 2
	replace `var' = subinstr(`var', "%", "percent",.) in 2
	replace `var' = subinstr(`var', "#", "count",.) in 2
	replace `var' = subinstr(`var', "Approaching Basic", "Lev2",.) in 2
	replace `var' = subinstr(`var', "Advanced", "Lev5",.) in 2
	replace `var' = subinstr(`var', "Mastery", "Lev4",.) in 2
	replace `var' = subinstr(`var', "Basic", "Lev3",.) in 2
	replace `var' = subinstr(`var', "Unsatisfactory", "Lev1",.) in 2
	replace `var' = subinstr(`var', " ", "_",.) in 2
}
drop in 1

foreach var of varlist _all {
	local newname = `var'[1]
	rename `var' `newname'
}

drop in 1

rename _count_Lev* Lev*_count
rename _percent_Lev* Lev*_percent

forvalues n = 1/5 {
	rename Lev`n'*_count Lev`n'_count*
	rename Lev`n'*_percent Lev`n'_percent*
	
}

drop Code
rename School_System_Code StateAssignedDistID
rename School_System_Name DistName
rename School_Code StateAssignedSchID
rename School_Name SchName
drop Innovative*
drop Charter*
rename Grade GradeLevel
rename Subgroup StudentSubGroup
drop if missing(StateAssignedDistID)
rename AverageScaleScorescience AverageScaleScoresci
rename Average* Avg*

reshape long AvgScaleScore StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent, i(StateAssignedDistID StateAssignedSchID GradeLevel StudentSubGroup) j(Subject, string)

//DataLevel
gen DataLevel = 1 if StateAssignedDistID == "LA"
replace DataLevel = 2 if missing(StateAssignedSchID) & StateAssignedDistID != "LA"
replace DataLevel = 3 if !missing(StateAssignedSchID)
label def DataLevel 1 "State" 2 "District" 3 "School"
label values DataLevel DataLevel
order DataLevel
sort DataLevel
replace StateAssignedDistID = "" if DataLevel == 1
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3

//GradeLevel
drop if GradeLevel == "Grade"
replace GradeLevel = "G" + GradeLevel

//StudentGroup and StudentSubGroup

gen StudentGroup = ""

replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged"

replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Economically Disadvantaged"

replace StudentGroup = "Disability Status" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"

replace StudentGroup = "Disability Status" if StudentSubGroup == "Regular Education"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Regular Education"

replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"


replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian/Other Pacific Islander"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian/Other Pacific Islander"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or more races"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

replace StudentGroup = "RaceEth" if StudentSubGroup == "White"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"

replace StudentGroup = "EL Status" if StudentSubGroup == "Not English Learner"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not English Learner"

replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"

replace StudentGroup = "Migrant Status" if StudentSubGroup == "Not Migrant"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"

replace StudentGroup = "All Students" if StudentSubGroup == "Total Population"
replace StudentSubGroup = "All Students" if StudentSubGroup == "Total Population"

replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military Affiliated"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Affiliated"

replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Not Military Affiliated"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not Military Affiliated"

replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"

replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Not Foster Care"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not Foster Care"

replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"

replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Not Homeless"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Homeless"

replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"

drop if missing(StudentGroup)

//Dealing with Counts and Percents
foreach percent of varlist *_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	replace `percent' = subinstr(`percent', "%", "",.)
	gen range`percent' = substr(`percent',1,1) if regexm(`percent', "[<>]") !=0
	gen range`count' = substr(`count',1,1) if regexm(`count', "[<>]") !=0
	replace `percent' = subinstr(`percent', range`percent', "",.)
	replace `count' = subinstr(`count', range`count', "",.)
	replace `percent' = string(real(`percent')/100, "%9.3g")
	replace `percent' = "0-" + `percent' if range`percent' == "<"
	replace `percent' =  `percent' + "-1" if range`percent' == ">"
	replace `count' = "0-" + `count' if range`count' == "<"
}
drop range*
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, "<", "0-",.)


//Deriving Exact StudentSubGroup_TotalTested at State Level
replace StudentSubGroup_TotalTested = string(real(Lev1_count)+real(Lev2_count)+real(Lev3_count)+real(Lev4_count)+real(Lev5_count)) if DataLevel == 1
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."


//StudentGroup_TotalTested
cap drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Deriving StudentSubGroup_TotalTested where possible
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName GradeLevel Subject)
gen missing_SSG = 1 if missing(real(StudentSubGroup_TotalTested))
egen missing_multiple = total(missing_SSG), by(StudentGroup DistName SchName GradeLevel Subject)

order StudentGroup_TotalTested UnsuppressedSG StudentSubGroup_TotalTested UnsuppressedSSG missing_multiple

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & DataLevel == 1 & missing_multiple <2

drop Unsuppressed* missing_*

//ProficientOrAbove_count & ProficientOrAbove_percent
foreach var of varlist *_count *_percent {
	gen low`var' = substr(`var', 1, strpos(`var', "-")-1)
	gen high`var' = substr(`var', strpos(`var', "-") + 1,10)
	replace low`var' = high`var' if missing(low`var')
}

foreach type in count percent {
gen highProficientOrAbove_`type' = string(real(highLev4_`type')+real(highLev5_`type'))
 if "`type'" == "count" replace highProficientOrAbove_`type' = StudentSubGroup_TotalTested if real(highProficientOrAbove_`type') > real(StudentSubGroup_TotalTested)
 if "`type'" == "percent" replace highProficientOrAbove_`type' = "1" if real(highProficientOrAbove_`type') > 1 
gen lowProficientOrAbove_`type' = string(real(lowLev4_`type')+real(lowLev5_`type')) 
gen ProficientOrAbove_`type' = lowProficientOrAbove_`type' + "-" + highProficientOrAbove_`type' if !missing(real(lowProficientOrAbove_`type'))
replace ProficientOrAbove_`type' = highProficientOrAbove_`type' if highProficientOrAbove_`type' == lowProficientOrAbove_`type'
}
drop low* high*

//Fixing StateAssignedDistID == "R36" obs. Numerous problems.
replace StateAssignedDistID = "036" if StateAssignedDistID == "R36" & (substr(StateAssignedSchID, 1,3) == "036" | missing(StateAssignedSchID))
replace StateAssignedDistID = substr(StateAssignedSchID,1,3) if StateAssignedDistID == "R36"

//NCES Merging
gen State_leaid = StateAssignedDistID
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID

merge m:1 State_leaid using "$NCES_LA/NCES_2022_District_LA_24", gen(DistMerge)
drop if DistMerge == 2
merge m:1 seasch using "$NCES_LA/NCES_2022_School_LA_24", gen(SchMerge)
drop if SchMerge == 2

drop State_leaid seasch DistMerge

//Exporting Unmerged for 2024
tempfile temp1
save "`temp1'", replace

keep DataLevel StateAssignedDistID StateAssignedSchID DistName SchName NCESDistrictID DistType DistCharter DistLocale CountyCode CountyName NCESSchoolID SchType SchLevel SchVirtual SchMerge
order DataLevel StateAssignedDistID StateAssignedSchID DistName SchName NCESDistrictID NCESSchoolID DistType DistCharter DistLocale CountyCode CountyName SchMerge
keep if SchMerge == 1 & DataLevel == 3
duplicates drop
gen KeepDrop = ""
order KeepDrop
save "$Temp/Unmerged_2024_unfilled", replace
export excel "$Temp/Unmerged_2024_unfilled.xlsx", firstrow(variables) replace

//Merging Unmerged Schools for 2024
import excel "$Original/Unmerged_2024.xlsx", firstrow case(preserve) allstring clear
drop if missing(KeepDrop)
drop DataLevel SchMerge
gen DataLevel = 3
save "${Temp}/Unmerged_2024", replace
use "`temp1'"
merge m:1 DistName StateAssignedDistID SchName StateAssignedSchID using "${Temp}/Unmerged_2024", gen(UnmergedMerge) update
keep if KeepDrop == "Keep" | missing(KeepDrop)
drop if UnmergedMerge == 2
drop KeepDrop
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
replace StateAssignedDistID = NewStateAssignedDistID if !missing(NewStateAssignedDistID)
replace StateAssignedSchID = subinstr(StateAssignedSchID, substr(StateAssignedSchID,1,3),StateAssignedDistID,.) if !missing(NewStateAssignedDistID)
drop *Merge
drop if DistName == "New Orleans Archdiocese"

//Indicator and Missing Variables
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen SchYear = "2023-24"
gen AssmtName = "LEAP 2025"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 4-5"

replace State = "Louisiana"
replace StateFips = 22
replace StateAbbrev = "LA"

gen ParticipationRate = "--"

replace AvgScaleScore = "--" if missing(AvgScaleScore)

//Numerous Count and Percent Derivations
** Deriving level counts at the state level when we have all other counts
//NOTE: do not attempt to derive counts OR count ranges at District or School level based on percents and StudentSubGroup_TotalTested; StudentSubGroup_TotalTested is *not* exact and is rounded to the nearest 10.
replace Lev1_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev1_count)) & DataLevel == 1

replace Lev2_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev1_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev1_count)) & missing(real(Lev2_count)) & DataLevel == 1

replace Lev3_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev1_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & missing(real(Lev3_count)) & DataLevel == 1

replace Lev4_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev1_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev1_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev4_count)) & DataLevel == 1

replace Lev5_count = string(real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev1_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev5_count)) & DataLevel == 1

** Deriving Level Percents where we have all other percents at all levels
replace Lev1_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)

replace Lev2_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent) > 0.005)

replace Lev3_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent) > 0.005)

replace Lev4_percent = string(1-real(Lev5_percent)-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))  & (1-real(Lev5_percent)-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)

replace Lev5_percent = string(1-real(Lev1_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev5_percent))  & (1-real(Lev1_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)


** Deriving exact ProficientOrAbove_percent if we have Levels 1-3 at all DataLevels
replace ProficientOrAbove_percent = string(1-real(Lev3_percent)-real(Lev2_percent)-real(Lev1_percent), "%9.5g") if !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & !missing(real(Lev1_percent)) & (1-real(Lev3_percent)-real(Lev2_percent)-real(Lev1_percent)) > 0.005 & missing(real(ProficientOrAbove_percent))

//Making file consistent with prior years
foreach var of varlist StudentGroup_TotalTested *_count StudentSubGroup_TotalTested {
	replace `var' = "0-9" if `var' == "0-10"
}

replace ProficientOrAbove_count = "0" if ProficientOrAbove_count == "-1"
replace ProficientOrAbove_percent = "1" if ProficientOrAbove_percent == "1.01-1"

//Final Cleaning

foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

// Reordering variables and sorting data
local vars State StateAbbrev StateFips SchYear DataLevel DistName SchName ///
	NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID ///
	AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested ///
	StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent ///
	Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent ///
	Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ///
	ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA ///
	Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType ///
	DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// *Exporting into a separate folder Output for Stanford - without derivations*
save "${Output_ND}/LA_AssmtData2024_NoDev", replace //If .dta format needed.
export delimited "${Output_ND}/LA_AssmtData2024_NoDev", replace 

*Derivations*
** Deriving exact percent based on exact counts where we have ranges at the STATE level only
foreach percent of varlist *_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	replace `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.5g") if missing(real(`percent')) & !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested)) & DataLevel == 1
}

*Derivations*
** Deriving count based on exact percent where we have ranges at the STATE level only
foreach percent of varlist *_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	replace `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested)) & DataLevel == 1
}

//Making file consistent with prior years
foreach var of varlist StudentGroup_TotalTested *_count StudentSubGroup_TotalTested {
	replace `var' = "0-9" if `var' == "0-10"
}

replace ProficientOrAbove_count = "0" if ProficientOrAbove_count == "-1"
replace ProficientOrAbove_percent = "1" if ProficientOrAbove_percent == "1.01-1"

//Final Cleaning

foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

//Keeping, ordering and sorting variables
keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output with derivations*
save "$Output/LA_AssmtData_2024", replace
export delim "$Output/LA_AssmtData_2024", replace
* END of LA_2024_SepData.do
****************************************************
