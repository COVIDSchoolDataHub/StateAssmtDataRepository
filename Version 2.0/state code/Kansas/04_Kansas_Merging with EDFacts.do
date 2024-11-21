****************************************************************
** Merging with EDFacts / Producing Final Output
****************************************************************

clear
set more off

global raw "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\Raw"
global temp "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\temp"
global NCESDistrict "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\NCES District Files, Fall 1997-Fall 2022"
global NCESSchool "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\NCES School Files, Fall 1997-Fall 2022"
global EDFacts "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\EdFacts"
global output "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\Output"

****************************************************************
** Merging with EDFacts 
****************************************************************
local years1 2015 2016 2017 2019 2021  
local years2 2018
local years3 2022 2023
local datatype count part
local datalevel school district


foreach year of local years1 {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				
				use "${temp}/kansas_`year'_temp2.dta"
				
				merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/_edfactscount`year'districtkansas.dta"
				
				replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
				rename Count Count_n
				replace ProficientOrAbove_percent = PctProf if _merge == 3 & inlist(ProficientOrAbove_percent, "--", "*")
				drop if _merge == 2
				drop stnam _merge

				merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/_edfactscount`year'schoolkansas.dta"
				replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
				replace Count_n = Count if DataLevel == 3 & _merge == 3
				replace ProficientOrAbove_percent = PctProf if _merge == 3 & inlist(ProficientOrAbove_percent, "--", "*")
				drop if _merge == 2
				drop Count stnam schnam _merge


** Pull in gender subgroup data (2018 is the only yr with gender data)
	{
		
	if `year' ! = 2018 {
		
	preserve
	keep SchName StateAssignedSchID StateAssignedDistID DistName DataLevel SchYear State StateAbbrev StateFips NCESDistrictID NCESSchoolID DistType DistCharter DistLocale CountyCode CountyName seasch SchLevel SchVirtual SchType GradeLevel Subject AssmtName AssmtType ProficiencyCriteria 
	duplicates drop
	expand 2, gen(indicator)
	gen StudentSubGroup = "Female"
	replace StudentSubGroup = "Male" if indicator == 1
	gen StudentGroup = "Gender"
	gen StudentSubGroup_TotalTested = "--"
	gen AvgScaleScore = "--"
	
	forvalues n = 1/4{
		gen Lev`n'_count = "--"
		gen Lev`n'_percent = .
	}
	
	gen Lev5_count = ""
	gen Lev5_percent = ""
	gen ProficientOrAbove_count = "--"
	gen ProficientOrAbove_percent = "--"
	gen ParticipationRate = "--"

	// district merge - counts
	merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/_edfactscount`year'districtkansas.dta"
	replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
	rename Count Count_n
	replace ProficientOrAbove_percent = PctProf if _merge == 3
	drop if _merge == 2
	drop stnam _merge

	// school merge - counts
	merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/_edfactscount`year'schoolkansas.dta"
	replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "0" & string(Count) != "."
	replace Count_n = Count if Count != .
	replace ProficientOrAbove_percent = PctProf if _merge == 3
	drop Count
	drop if _merge == 2
	drop stnam schnam _merge indicator

	// district merge - participation
	merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/_edfactspart`year'districtkansas.dta"
	replace ParticipationRate = Participation if _merge == 3
	drop if _merge == 2
	drop stnam _merge Participation

	// school merge - participation
	merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/_edfactspart`year'schoolkansas.dta"
	replace ParticipationRate = Participation if _merge == 3
	drop if _merge == 2
	drop stnam schnam _merge Participation

	save "${temp}/KS_`year'_Gender.dta", replace
	export delimited "${temp}/KS_`year'_Gender.csv", replace
	
	restore
	}
	
	}
	
append using "${temp}/KS_`year'_Gender.dta" 

** Deriving More SubGroup Counts

	bysort State_leaid seasch GradeLevel Subject: egen All = max(Count_n)
	bysort State_leaid seasch GradeLevel Subject: egen Econ = sum(Count_n) if StudentGroup == "Economic Status"
	replace Count_n = All - Econ if StudentSubGroup == "Not Economically Disadvantaged"
	replace StudentSubGroup_TotalTested = string(Count_n) if StudentSubGroup == "Not Economically Disadvantaged" & Count_n != .
	replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "0"

** State counts
	{
	preserve
	keep if DataLevel == 2
	rename Count_n Count
	collapse (sum) Count, by(StudentSubGroup GradeLevel Subject)
	gen DataLevel = 1
	save "${temp}/KS_AssmtData_`year'_State.dta", replace
	restore
	}
	
	merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "${temp}/KS_AssmtData_`year'_State.dta"
	replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "0" & string(Count) != "."
	replace Count_n = Count if Count != .
	drop Count
	drop if _merge == 2
	drop _merge

** Deriving More Proficiency Information
gen ProfPct = ProficientOrAbove_percent
split ProfPct, parse("-")
destring ProfPct1, replace force
destring ProfPct2, replace force

gen flag = 0
replace flag = 1 if ProfPct1 == . & Lev3_percent != . & Lev4_percent != .
replace ProfPct1 = Lev3_percent + Lev4_percent if flag == 1

gen ProfCount = round(Count_n * ProfPct1)
gen ProfCount2 = .
replace ProfCount2 = Count_n * ProfPct2 if ProfPct2 != .
tostring ProfCount, replace force
replace ProfCount = ProfCount + "-" + string(round(ProfCount2)) if ProfCount2 != .
replace ProfCount = "--" if inlist(ProfCount, "", ".", ".-.")
replace ProficientOrAbove_count = ProfCount if ProfCount != "--"
replace ProficientOrAbove_count = "--" if StudentSubGroup_TotalTested == "--"

replace Lev3_percent = ProfPct1 - Lev4_percent if (Lev3_percent == . & Lev4_percent != . & ProfPct1 != .)
replace Lev4_percent = ProfPct1 - Lev3_percent if (Lev4_percent == . & Lev3_percent != . & ProfPct1 != .)

forvalues n = 1/4{
	gen Lev`n' = round(Lev`n'_percent * Count_n)
	tostring Lev`n', replace
	replace Lev`n' = "--" if inlist(Lev`n', "", ".")
	replace Lev`n' = "--" if StudentSubGroup_TotalTested == "--"
	replace Lev`n' = "--" if Lev`n'_percent == .
	replace Lev`n'_count = Lev`n'
	drop Lev`n'
	tostring Lev`n'_percent, replace format("%9.4g") force
	replace Lev`n'_percent = "--" if inlist(Lev`n'_percent, "", ".")
}

tostring ProfPct1, replace format("%9.4g") force
replace ProficientOrAbove_percent = ProfPct1 if flag == 1

drop ProfPct ProfPct1 ProfPct2 ProfCount ProfCount2 flag

replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""

** StudentGroup_TotalTested // new convention for V2.0+

{
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

// where we have suppressed subgroup_totaltested counts, we will make sure the level counts are suppressed
forvalues n = 1/4{
		
		replace Lev`n'_count = "*" if StudentSubGroup_TotalTested == "*"

	}
	
* replace StudentGroup_TotalTested= "*" if StudentGroup_TotalTested=="1" // removed 11/21/24



** Generating new variables

gen Flag_AssmtNameChange = "N"
	replace Flag_AssmtNameChange = "Y" if `year' == 2015
	
gen Flag_CutScoreChange_ELA = "N"
	replace Flag_CutScoreChange_ELA = "Y" if `year' == 2015
	
gen Flag_CutScoreChange_math = "N"
	replace Flag_CutScoreChange_math = "Y" if `year' == 2015
	
gen Flag_CutScoreChange_soc = "Not applicable"

gen Flag_CutScoreChange_sci = "Not applicable"
	replace Flag_CutScoreChange_sci = "N" if `year' > 2018




//Cleanup and Ordering
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
}

save "${output}/KS_AssmtData_`year'.dta", replace
export delimited using "${output}/KS_AssmtData_`year'.csv", replace

}
}
}


****************************************************************
** 2018
****************************************************************

foreach year of local years2 {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				
				use "${temp}/kansas_`year'_temp2.dta"
				
				merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/_edfactscount2018districtkansas.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
rename Count Count_n
replace ProficientOrAbove_percent = PctProf if _merge == 3 & inlist(ProficientOrAbove_percent, "--", "*")
drop if _merge == 2
drop stnam _merge

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/_edfactspart2018districtkansas.dta"
replace ParticipationRate = Participation if _merge == 3 & Participation != ""
drop if _merge == 2
drop stnam _merge Participation

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/_edfactscount2018schoolkansas.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
replace Count_n = Count if DataLevel == 3 & _merge == 3
replace ProficientOrAbove_percent = PctProf if _merge == 3 & inlist(ProficientOrAbove_percent, "--", "*")
drop if _merge == 2
drop Count stnam schnam _merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/_edfactspart2018schoolkansas.dta"
replace ParticipationRate = Participation if _merge == 3 & Participation != ""
drop if _merge == 2
drop stnam _merge

** Deriving More SubGroup Counts
bysort State_leaid seasch GradeLevel Subject: egen All = max(Count_n)
bysort State_leaid seasch GradeLevel Subject: egen Econ = sum(Count_n) if StudentGroup == "Economic Status"
bysort State_leaid seasch GradeLevel Subject: egen Disability = sum(Count_n) if StudentGroup == "Disability Status"
replace Count_n = All - Econ if StudentSubGroup == "Not Economically Disadvantaged"
replace Count_n = All - Disability if StudentSubGroup == "Non-SWD"
replace StudentSubGroup_TotalTested = string(Count_n) if inlist(StudentSubGroup, "Not Economically Disadvantaged", "Non-SWD") & Count_n != .
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "0"

** State counts

preserve
keep if DataLevel == 2
rename Count_n Count
collapse (sum) Count, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "${temp}/KS_AssmtData_2018_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "${temp}/KS_AssmtData_2018_State.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "0" & string(Count) != "."
replace Count_n = Count if Count != .
drop Count
drop if _merge == 2
drop _merge

** Deriving More Proficiency Information
gen ProfPct = ProficientOrAbove_percent
destring ProfPct, replace

gen flag = 0
replace flag = 1 if ProfPct == . & Lev3_percent != . & Lev4_percent != .
replace ProfPct = Lev3_percent + Lev4_percent if flag == 1

gen ProfCount = round(Count_n * ProfPct)
tostring ProfCount, replace force
replace ProfCount = "--" if inlist(ProfCount, "", ".", ".-.")
replace ProficientOrAbove_count = ProfCount if ProfCount != "--"
replace ProficientOrAbove_count = "--" if StudentSubGroup_TotalTested == "--"

replace Lev3_percent = ProfPct - Lev4_percent if Lev3_percent == . & Lev4_percent != .
replace Lev4_percent = ProfPct - Lev3_percent if Lev4_percent == . & Lev3_percent != .

forvalues n = 1/4{
	gen Lev`n' = round(Lev`n'_percent * Count_n)
	tostring Lev`n', replace
	replace Lev`n' = "--" if inlist(Lev`n', "", ".")
	replace Lev`n' = "--" if StudentSubGroup_TotalTested == "--"
	replace Lev`n' = "--" if Lev`n'_percent == .
	replace Lev`n'_count = Lev`n'
	drop Lev`n'
	tostring Lev`n'_percent, replace format("%9.4g") force
	replace Lev`n'_percent = "--" if inlist(Lev`n'_percent, "", ".")
}

tostring ProfPct, replace format("%9.4g") force
replace ProficientOrAbove_percent = ProfPct if flag == 1

drop ProfPct ProfCount flag

replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""


** StudentGroup_TotalTested // new convention for V2.0+

{
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

// where we have suppressed subgroup_totaltested counts, we will make sure the level counts are suppressed
forvalues n = 1/4{
		
		replace Lev`n'_count = "*" if StudentSubGroup_TotalTested == "*"

	}
	
* replace StudentGroup_TotalTested= "*" if StudentGroup_TotalTested=="1" // removed 11/21/24


** Generating new variables

gen Flag_AssmtNameChange = "N"
	replace Flag_AssmtNameChange = "Y" if `year' == 2015
	
gen Flag_CutScoreChange_ELA = "N"
	replace Flag_CutScoreChange_ELA = "Y" if `year' == 2015
	
gen Flag_CutScoreChange_math = "N"
	replace Flag_CutScoreChange_math = "Y" if `year' == 2015
	
gen Flag_CutScoreChange_soc = "Not applicable"

gen Flag_CutScoreChange_sci = "Not applicable"
	replace Flag_CutScoreChange_sci = "N" if `year' > 2018
	
	
//Cleanup and Ordering
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
}

save "${output}/KS_AssmtData_`year'.dta", replace
export delimited using "${output}/KS_AssmtData_`year'.csv", replace

}
}
}


****************************************************************
** 2022, 2023
****************************************************************

foreach year of local years3 {

				use "${temp}/kansas_`year'_temp2.dta"
				
destring NCESDistrictID, replace force
destring NCESSchoolID, replace force

** Merging with NCES 2022 only (for 2022 onward bc this is the most recent available)
merge m:1 DataLevel NCESDistrictID NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/_edfacts2022kansas.dta"


replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
rename Count Count_n
replace ProficientOrAbove_percent = PctProf if _merge == 3
replace ParticipationRate = Participation if _merge == 3 & Participation != ""
drop if _merge == 2
drop state _merge PctProf2 Participation2

** Pull in gender subgroup data
{
preserve

	keep SchName StateAssignedSchID StateAssignedDistID DistName DataLevel SchYear State StateAbbrev StateFips NCESDistrictID NCESSchoolID DistType DistCharter DistLocale CountyCode CountyName seasch SchLevel SchVirtual SchType GradeLevel Subject AssmtName AssmtType ProficiencyCriteria 
	duplicates drop
	expand 2, gen(indicator)
	gen StudentSubGroup = "Female"
	replace StudentSubGroup = "Male" if indicator == 1
	gen StudentGroup = "Gender"
	gen StudentSubGroup_TotalTested = "--"
	gen AvgScaleScore = "--"
	forvalues n = 1/4{
		gen Lev`n'_count = "--"
		gen Lev`n'_percent = .
	}
	gen Lev5_count = ""
	gen Lev5_percent = ""
	gen ProficientOrAbove_count = "--"
	gen ProficientOrAbove_percent = "--"
	gen ParticipationRate = "--"

	merge m:1 DataLevel NCESDistrictID NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/_edfacts2022kansas.dta"
	replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
	rename Count Count_n
	replace ProficientOrAbove_percent = PctProf if _merge == 3
	replace ParticipationRate = Participation if _merge == 3 & Participation != ""
	drop if _merge == 2
	drop state _merge PctProf2 Participation2

	save "${temp}/KS_`year'_Gender.dta", replace
	export delimited "${temp}/KS_`year'_Gender.csv", replace
	
restore
}

append using "${temp}/KS_`year'_Gender.dta"

** Deriving More SubGroup Counts
	bysort State_leaid seasch GradeLevel Subject: egen All = max(Count_n)
	bysort State_leaid seasch GradeLevel Subject: egen Econ = sum(Count_n) if StudentGroup == "Economic Status"
	bysort State_leaid seasch GradeLevel Subject: egen Disability = sum(Count_n) if StudentGroup == "Disability Status"
	replace Count_n = All - Econ if StudentSubGroup == "Not Economically Disadvantaged"
	replace Count_n = All - Disability if StudentSubGroup == "Non-SWD"
	replace StudentSubGroup_TotalTested = string(Count_n) if inlist(StudentSubGroup, "Not Economically Disadvantaged", "Non-SWD") & Count_n != .
	replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "0"

** Deriving More Proficiency Information
	gen ProfPct = ProficientOrAbove_percent
	split ProfPct, parse("-")
	destring ProfPct1, replace force
	destring ProfPct2, replace force

	gen flag = 0
	replace flag = 1 if ProfPct1 == . & Lev3_percent != . & Lev4_percent != .
	replace ProfPct1 = Lev3_percent + Lev4_percent if flag == 1

	gen ProfCount = round(Count_n * ProfPct1)
	gen ProfCount2 = .
	replace ProfCount2 = Count_n * ProfPct2 if ProfPct2 != .
	tostring ProfCount, replace force
	replace ProfCount = ProfCount + "-" + string(round(ProfCount2)) if ProfCount2 != .
	replace ProfCount = "--" if inlist(ProfCount, "", ".", ".-.")
	replace ProficientOrAbove_count = ProfCount if ProfCount != "--"
	replace ProficientOrAbove_count = "--" if StudentSubGroup_TotalTested == "--"

	replace Lev3_percent = ProfPct1 - Lev4_percent if Lev3_percent == . & Lev4_percent != .
	replace Lev4_percent = ProfPct1 - Lev3_percent if Lev4_percent == . & Lev3_percent != .

	forvalues n = 1/4{
		gen Lev`n' = round(Lev`n'_percent * Count_n)
		tostring Lev`n', replace
		replace Lev`n' = "--" if inlist(Lev`n', "", ".")
		replace Lev`n' = "--" if StudentSubGroup_TotalTested == "--"
		replace Lev`n' = "--" if Lev`n'_percent == .
		replace Lev`n'_count = Lev`n'
		
		*replace Lev`n'_count = "--" if Lev`n'_percent !=0 & Lev`n'_count=="0" // 11/14/24
		replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested=="1"	
		replace Lev`n'_count = "*" if StudentSubGroup_TotalTested=="*" // 11/14/24
				
				
		drop Lev`n'
		tostring Lev`n'_percent, replace format("%9.4g") force
		replace Lev`n'_percent = "--" if inlist(Lev`n'_percent, "", ".")
	}

	tostring ProfPct1, replace format("%9.4g") force
	replace ProficientOrAbove_percent = ProfPct1 if flag == 1

	drop ProfPct ProfPct1 ProfPct2 ProfCount ProfCount2 flag

	replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""

** StudentGroup_TotalTested // new convention for V2.0+

{
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1
}


// where we have suppressed subgroup_totaltested counts, we will make sure the level counts are suppressed
forvalues n = 1/4{
		
		replace Lev`n'_count = "*" if StudentSubGroup_TotalTested == "*"

	}
	
* replace StudentGroup_TotalTested= "*" if StudentGroup_TotalTested=="1" // removed 11/21/24


** Generating new variables

gen Flag_AssmtNameChange = "N"
	replace Flag_AssmtNameChange = "Y" if `year' == 2015
	
gen Flag_CutScoreChange_ELA = "N"
	replace Flag_CutScoreChange_ELA = "Y" if `year' == 2015
	
gen Flag_CutScoreChange_math = "N"
	replace Flag_CutScoreChange_math = "Y" if `year' == 2015
	
gen Flag_CutScoreChange_soc = "Not applicable"

gen Flag_CutScoreChange_sci = "Not applicable"
	replace Flag_CutScoreChange_sci = "N" if `year' > 2018
	
//Cleanup and Ordering
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/KS_AssmtData_`year'.dta", replace
export delimited using "${output}/KS_AssmtData_`year'.csv", replace
}


