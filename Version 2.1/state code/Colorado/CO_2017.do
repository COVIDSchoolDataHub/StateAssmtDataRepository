*******************************************************
* COLORADO

* File name: CO_2017
* Last update: 2/25/2025

*******************************************************
* Notes

	* This do file imports CO 2017 data, renames variables, cleans and saves it as a dta file.
	* NCES 2016 is merged with CO 2017 data. 
	* Only the usual output is created.
*******************************************************
/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear
*******************************************************
//Importing & Renaming
*******************************************************
** All Students Data
import excel "$Original/2017/CO_OriginalData_2017_ela&mat.xlsx", cellrange(A5) firstrow case(lower) clear
drop if missing(districtcode)
drop y-changeinmetor
rename numberdidnotyetmeetexpect Lev1_count
rename didnotyetmeetexpectation Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename partiallymetexpectations Lev2_percent
rename numberapproachedexpectations Lev3_count
rename approachedexpectations Lev3_percent
rename numbermetexpectations Lev4_count
rename metexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename exceededexpectations Lev5_percent
save "${Temp}/CO_OriginalData_2017_ela&mat", replace

import excel "$Original/2017/CO_OriginalData_2017_sci.xlsx", cellrange(A4) case(lower) firstrow clear
drop if missing(districtcode)
drop w-changeinmetor
rename numberpartiallymetexpectati Lev1_count
rename partiallymetexpectations Lev1_percent
rename numberapproachedexpectations Lev2_count
rename approachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename metexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename exceededexpectations Lev4_percent
save "${Temp}/CO_OriginalData_2017_sci", replace

append using "${Temp}/CO_OriginalData_2017_ela&mat"

* Renaming & Dropping Variables
rename level DataLevel
rename districtcode StateAssignedDistID
rename districtname DistName
rename schoolcode StateAssignedSchID
rename schoolname SchName
rename content Subject
rename test GradeLevel
drop numberoftotalrecords numberofnoscores
rename numberofvalidscores StudentSubGroup_TotalTested
rename meanscalescore AvgScaleScore
rename participationrate ParticipationRate
rename numbermetorexceededexpecta ProficientOrAbove_count 
rename metorexceededexpectations ProficientOrAbove_percent
save "${Temp}/CO_OriginalData_2017_allstudents", replace
clear

** SubGroup Data
clear
tempfile temp1
save "`temp1'", replace emptyok
foreach s in ela mat sci {
	foreach sg in FreeReducedLunch raceEthnicity gender individualEd language migrant {
		import excel "$Original/2017/CO_2017_`s'_`sg'.xlsx", cellrange(A5) clear
		drop if missing(B)
		if "`s'" != "sci" {
		rename M Lev1_count
		rename N Lev1_percent
		rename O Lev2_count
		rename P Lev2_percent
		rename Q Lev3_count
		rename R Lev3_percent
		rename S Lev4_count
		rename T Lev4_percent
		rename U Lev5_count
		rename V Lev5_percent
		rename W ProficientOrAbove_count
		rename X ProficientOrAbove_percent
		}
		if "`s'" == "sci" {
		rename M Lev1_count
		rename N Lev1_percent
		rename O Lev2_count
		rename P Lev2_percent
		rename Q Lev3_count
		rename R Lev3_percent
		rename S Lev4_count
		rename T Lev4_percent
		rename U ProficientOrAbove_count
		rename V ProficientOrAbove_percent
		}
		rename A DataLevel
		rename B StateAssignedDistID
		rename C DistName
		rename D StateAssignedSchID
		rename E SchName
		rename F Subject
		rename G GradeLevel
		rename H StudentSubGroup
		drop I
		rename J StudentSubGroup_TotalTested
		rename K ParticipationRate
		rename L AvgScaleScore
		append using "`temp1'"
		save "`temp1'", replace	
	}
}
use "`temp1'"
save "${Temp}/CO_OriginalData_2017_subgroups", replace
append using "${Temp}/CO_OriginalData_2017_allstudents"
save "${Original_Cleaned}/CO_OriginalData_2017", replace

//Cleaning
use "${Original_Cleaned}/CO_OriginalData_2017", clear

//DataLevel
replace DataLevel = proper(DataLevel)

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel !=3

//Subject
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "sci" if Subject == "Science"
replace Subject = lower(Subject)

//GradeLevel
keep if real(substr(GradeLevel, -1,1)) >= 3 & real(substr(GradeLevel, -1,1)) <= 8
replace GradeLevel = "G" + substr(GradeLevel, -2,2)

//StudentSubGroup (Except EL Groups)
replace StudentSubGroup = "All Students" if missing(StudentSubGroup)
drop if StudentSubGroup == "Unreported"

replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaiian/Pacific Islander"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Unreported/ Not Applicable"
drop if StudentSubGroup == "Unknown"
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not IEP"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"

replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free/Reduced Lunch Eligible"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Free/Reduced Lunch Eligible"

//Counts and Percents
foreach percent of varlist *_percent ParticipationRate {
	replace `percent' = string(real(`percent')/100, "%9.3g") if !missing(real(`percent'))
}

replace StudentSubGroup_TotalTested = "0-15" if StudentSubGroup_TotalTested == "< 16"

//EL Groups Aggregation
tempfile temp1
save "`temp1'", replace
keep if StudentSubGroup == "FEP - Fluent English Proficient" | StudentSubGroup == "LEP - Limited English Proficient" | StudentSubGroup == "NEP - Non English Proficient" | StudentSubGroup == "PHLOTE/FELL/NA"

gen EL_Group = "English Learner" if StudentSubGroup == "LEP - Limited English Proficient" | StudentSubGroup == "NEP - Non English Proficient"
replace EL_Group = "English Proficient" if StudentSubGroup == "PHLOTE/FELL/NA" | StudentSubGroup == "FEP - Fluent English Proficient"

** Absolute Variables (Just need to add together)
sort DataLevel DistName SchName Subject GradeLevel EL_Group StudentSubGroup
replace StateAssignedDistID = "--" if StateAssignedDistID == ""
replace StateAssignedSchID = "--" if StateAssignedSchID == ""
egen uniquegrp = group(DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel EL_Group)
foreach var of varlist StudentSubGroup_TotalTested *_count {
	destring `var', gen(n`var') force
	egen `var'_Agg = total(n`var'), by(DistName SchName Subject GradeLevel EL_Group)
	gen `var'_Miss = 1 if n`var' == .
	sort DataLevel DistName SchName Subject GradeLevel EL_Group StudentSubGroup
	replace `var'_Miss = 1 if `var'_Miss[_n+1] == 1 & uniquegrp == uniquegrp[_n+1]
	replace `var'_Miss = 1 if `var'_Miss[_n-1] == 1 & uniquegrp == uniquegrp[_n-1]
	if `var' != StudentSubGroup_TotalTested{
		replace `var'_Agg = . if `var'_Miss == 1
	}
	drop `var'_Miss
}

** Adjusting StudentSubGroup_TotalTested
gen range = 1 if strpos(StudentSubGroup_TotalTested, "<16") !=0 
replace range = 1 if strpos(StudentSubGroup_TotalTested, "0-15") != 0
sort DataLevel DistName SchName Subject GradeLevel EL_Group StudentSubGroup
gen StudentSubGroup_TotalTested_High = StudentSubGroup_TotalTested_Agg + 15 if range == . & range[_n+1] == 1 & uniquegrp == uniquegrp[_n+1]
replace StudentSubGroup_TotalTested_High = StudentSubGroup_TotalTested_High[_n-1] if range == 1 & range[_n-1] == . & uniquegrp == uniquegrp[_n-1]
replace StudentSubGroup_TotalTested_High = StudentSubGroup_TotalTested_Agg + 15 if range == . & range[_n-1] == 1 & uniquegrp == uniquegrp[_n-1]
replace StudentSubGroup_TotalTested_High = StudentSubGroup_TotalTested_High[_n+1] if range == 1 & range[_n+1] == . & uniquegrp == uniquegrp[_n+1]
replace range = 2 if range == 1 & range[_n+1] == 1 & uniquegrp == uniquegrp[_n+1]
replace range = 2 if range == 1 & range[_n-1] !=. & uniquegrp == uniquegrp[_n-1]

** Proportional Variables (Need to account for how many were tested in each group)
gen Prop = nStudentSubGroup_TotalTested/StudentSubGroup_TotalTested_Agg
replace Prop = . if StudentSubGroup_TotalTested_High != .
replace Prop = . if range == 2

foreach var of varlist ParticipationRate AvgScaleScore *_percent {
	gen n`var' = Prop * real(`var')
	egen `var'_Agg = total(n`var'), by(DistName SchName Subject GradeLevel EL_Group)
	gen `var'_Miss = 1 if n`var' == .
	sort DataLevel DistName SchName Subject GradeLevel EL_Group StudentSubGroup
	replace `var'_Miss = 1 if `var'_Miss[_n+1] == 1 & uniquegrp == uniquegrp[_n+1]
	replace `var'_Miss = 1 if `var'_Miss[_n-1] == 1 & uniquegrp == uniquegrp[_n-1]
	replace `var'_Agg = . if `var'_Miss == 1
	drop `var'_Miss
}

** Replace Values
drop n*
foreach var of varlist *_count *_percent ParticipationRate AvgScaleScore {
	drop `var'
	rename `var'_Agg `var'
	tostring `var', replace format("%9.3g") force
	replace `var' = "*" if `var' == "0" | `var' == "."
}

replace StudentSubGroup_TotalTested = string(StudentSubGroup_TotalTested_Agg) if StudentSubGroup_TotalTested_High == . & range == .
replace StudentSubGroup_TotalTested = string(StudentSubGroup_TotalTested_Agg) + "-" + string(StudentSubGroup_TotalTested_High) if StudentSubGroup_TotalTested_High != .
replace StudentSubGroup_TotalTested = "0-30" if range == 2
drop StudentSubGroup_TotalTested_Agg StudentSubGroup_TotalTested_High range

** Check for Proper Aggregation
sort DataLevel DistName SchName Subject GradeLevel EL_Group StudentSubGroup
egen uniquegrp1 = group(DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel EL_Group StudentSubGroup_TotalTested ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate AvgScaleScore)
tab DataLevel if uniquegrp != uniquegrp1
drop uniquegrp uniquegrp1

** Cleaning Up
replace StateAssignedSchID = "" if StateAssignedSchID == "--"
replace StateAssignedDistID = "" if StateAssignedDistID == "--"

drop StudentSubGroup Prop
rename EL_Group StudentSubGroup
sort DataLevel DistName SchName Subject GradeLevel StudentSubGroup
duplicates drop DistName SchName Subject GradeLevel StudentSubGroup, force
tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "0-15" if StudentSubGroup_TotalTested == "0"
append using "`temp1'"
drop if StudentSubGroup == "LEP - Limited English Proficient" | StudentSubGroup == "NEP - Non English Proficient" | StudentSubGroup == "PHLOTE/FELL/NA"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "FEP - Fluent English Proficient" 
replace Lev5_count = "" if Subject == "sci"
replace Lev5_percent = "" if Subject == "sci"

//Derive Additional Performance Information where Possible
destring Lev1_count, gen(Lev1_c) force
destring ProficientOrAbove_count, gen(prof_c) force
destring StudentSubGroup_TotalTested, gen(studcount) force
replace Lev2_count = string(studcount - prof_c - Lev1_c) if Subject == "sci" & inlist(Lev2_count, "*", "--") & !inlist(Lev1_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--")

drop Lev1_c prof_c studcount

//StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = "0-15" if strpos(StudentSubGroup_TotalTested, "<16") !=0 | strpos(StudentSubGroup_TotalTested, "< 16") !=0
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)


//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex" | StudentSubGroup == "EL Exited"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"
// order DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
// sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Original_Cleaned}/CO_OriginalData_2017", replace
*******************************************************
//Merging NCES Variables
*******************************************************
//NCES Merging
gen State_leaid = "CO-" + StateAssignedDistID if DataLevel !=1
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == 3

merge m:1 State_leaid using "$NCES_CO/NCES_2016_District_CO", gen(DistMerge)
drop if DistMerge == 2

merge m:1 seasch using "$NCES_CO/NCES_2016_School_CO", gen(SchMerge)
drop if SchMerge == 2

drop *Merge
// order DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

//StudentGroup_TotalTested
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

//Deriving StudentSubGroup_TotalTested where suppressed
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup GradeLevel Subject DistName SchName)
replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & !missing(real(StudentGroup_TotalTested)) & real(StudentGroup_TotalTested) - UnsuppressedSG >=0 & UnsuppressedSG > 0 & StudentGroup != "RaceEth" & StudentSubGroup != "EL Exited"
drop Unsuppressed*

//Removing "Empty" Observations for Subgroups
drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"

//Indicator Variables
replace State = "Colorado"
replace StateAbbrev = "CO"
replace StateFips = 8

gen AssmtName = "Colorado Measures of Academic Success"
gen AssmtType = "Regular"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"
gen SchYear = "2016-17" 

gen ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
replace ProficiencyCriteria = "Levels 4-5" if Subject != "sci"

*******************************************************
*Derivations [0 real changes made]
*******************************************************
//Deriving Additional Information 
forvalues n = 1/5{
	replace Lev`n'_count = string(round(real(Lev`n'_percent)* real(StudentSubGroup_TotalTested))) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev`n'_percent)) & missing(real(Lev`n'_count))
}

replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent)* real(StudentSubGroup_TotalTested))) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_percent)) & missing(real(ProficientOrAbove_count))

//SchName & DistName Changes
replace DistName = proper(DistName)
replace SchName = proper(SchName)
replace SchName = stritrim(SchName)

replace SchName = "Prairie Vista Youth Service Center" if NCESSchoolID == "080258006343"
replace SchName = "Marvin W Foote Youth Services" if NCESSchoolID == "080291006344"
replace SchName = "Gilliam School" if NCESSchoolID == "080336006345"
replace SchName = "Spring Creek Youth Services Center" if NCESSchoolID == "080453006342"
replace SchName = "Mountview Youth Service Center" if NCESSchoolID == "080480006347"
replace SchName = "Pueblo Youth Service Center" if NCESSchoolID == "080612006350"

** Standardize Names
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
replace DistName = strproper(DistName)
replace DistName = "Moffat County Re: No 1" if NCESDistrictID == "0805730"
replace DistName = "St Vrain Valley Re1J" if NCESDistrictID == "0805370"
replace DistName = "Weld Re-8 Schools" if NCESDistrictID == "0804020"
replace DistName = "Meeker Re-1" if NCESDistrictID == "0805610"
replace DistName = "McClave Re-2" if NCESDistrictID == "0805580"
replace DistName = "Weld Re-4" if NCESDistrictID == "0807350"
replace DistName = "Elizabeth School District" if NCESDistrictID == "0803720"

//Final Cleaning
foreach var of varlist StudentGroup_TotalTested StudentSubGroup_TotalTested *_count *_percent {
	replace `var' = subinstr(`var', ",","",.)
	replace `var' = subinstr(`var', " ", "",.)
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

*Exporting Output*
save "${Output}/CO_AssmtData_2017", replace
export delimited "${Output}/CO_AssmtData_2017", replace
* END of CO_2017.do
****************************************************
