clear all

global TUDA "/Users/miramehta/Documents/TUDA"
global Output "$TUDA/Output"

//Non-NY States
clear
tempfile temp1
save "`temp1'", empty
local States "CA CO DC FL GA IL KY MA MD MI NC NM NV OH PA TX WI"
foreach state of local States{
	forvalues year = 2022/2024{
		if "`state'" == "NM" & `year' == 2024 continue
		import delimited "$TUDA/`state'_AssmtData_`year'", delimiter(",") stringcols(9, 11, 17/47) case(preserve) clear
		drop if StateAbbrev == "CA" & !inlist(NCESDistrictID, 622710, 634320)
		drop if StateAbbrev == "CO" & NCESDistrictID != 803360
		drop if StateAbbrev == "DC" & NCESDistrictID != 1100030
		drop if StateAbbrev == "FL" & !inlist(NCESDistrictID, 1200480, 1200870, 1200390, 1201440)
		drop if StateAbbrev == "GA" & NCESDistrictID != 1300120
		drop if StateAbbrev == "IL" & NCESDistrictID != 1709930
		drop if StateAbbrev == "KY" & NCESDistrictID != 2102990
		drop if StateAbbrev == "MA" & NCESDistrictID != 2502790
		drop if StateAbbrev == "MD" & NCESDistrictID != 2400090
		drop if StateAbbrev == "MI" & NCESDistrictID != 2601103
		drop if StateAbbrev == "NC" & !inlist(NCESDistrictID, 3701920, 3702970)
		drop if StateAbbrev == "NM" & NCESDistrictID != 3500060
		drop if StateAbbrev == "NV" & NCESDistrictID != 3200060
		drop if StateAbbrev == "OH" & NCESDistrictID != 3904378
		drop if StateAbbrev == "PA" & NCESDistrictID != 4218990
		drop if StateAbbrev == "TX" & !inlist(NCESDistrictID, 4808940, 4816230, 4819700, 4823640)
		drop if StateAbbrev == "WI" & NCESDistrictID != 5509600
		append using "`temp1'"
		save "`temp1'", replace
	}
}

keep if DataLevel == "District"
keep if StudentSubGroup == "All Students"
keep if inlist(GradeLevel, "G04", "G08")
keep if inlist(Subject, "ela", "math")

drop if AssmtName == "STAAR - Spanish"

drop SchName NCESSchoolID StateAssignedSchID StudentSubGroup StudentSubGroup_TotalTested Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistCharter SchType SchLevel SchVirtual CountyName CountyCode

save "$Output/TUDA_intermediate.dta", replace

//NY
clear
tempfile temp2
save "`temp2'", empty
forvalues year = 2022/2024{
	import delimited "$TUDA/NY_AssmtData_`year'", delimiter(",") stringcols(9, 11, 17/47) case(preserve) clear
	append using "`temp2'"
	save "`temp2'", replace
}

keep if inlist(NCESDistrictID, 3600076, 3600077, 3600078, 3600079, 3600081, 3600083, 3600084, 3600085, 3600086, 3600087, 3600088, 3600090, 3600091, 3600119, 3600092, 3600094, 3600095, 3600096, 3600120, 3600151, 3600152, 3600153, 3600121, 3600098, 3600122, 3600099, 3600123, 3600100, 3600101, 3600102, 3600103, 3600097)

keep if DataLevel == "District"
keep if StudentSubGroup == "All Students"
keep if inlist(GradeLevel, "G04", "G08")
keep if inlist(Subject, "ela", "math")

drop SchName NCESSchoolID StateAssignedSchID StudentSubGroup StudentSubGroup_TotalTested Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistCharter SchType SchLevel SchVirtual CountyName CountyCode

sort SchYear Subject GradeLevel DistName

//Aggregation
egen uniquegrp = group(SchYear Subject GradeLevel)
local countvars "StudentGroup_TotalTested Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count"
foreach var of local countvars {
	destring `var', replace
	bysort uniquegrp: egen `var'Agg = total(`var')
}

gen Denom = StudentGroup_TotalTested/real(ParticipationRate)
bysort uniquegrp: egen DenomAgg = total(Denom)
drop ParticipationRate Denom

drop if uniquegrp == uniquegrp[_n-1]
drop StudentGroup_TotalTested Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent
rename *Agg *

local perfcountvars "Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count"
foreach var of local perfcountvars{
	local percent = subinstr("`var'", "count", "percent", 1)
	gen `percent' = `var'/StudentGroup_TotalTested
	tostring `var', replace
	tostring `percent', replace format("%9.3g") force
}

replace Denom = round(Denom)
gen ParticipationRate = StudentGroup_TotalTested/Denom
tostring ParticipationRate, replace format("%9.3g") force
drop Denom

tostring StudentGroup_TotalTested, replace

replace DistName = "New York City - Aggregated Values"
replace NCESDistrictID = .
replace AvgScaleScore = "--"

append using "$Output/TUDA_intermediate.dta"

tostring NCESDistrictID, replace
replace NCESDistrictID = "N/A" if NCESDistrictID == "."

order State StateAbbrev StateFips SchYear DataLevel DistName NCESDistrictID StateAssignedDistID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math  DistType DistLocale

local years "2021-22 2022-23 2023-24"
foreach year of local years {
	preserve
	keep if SchYear == "`year'"
	sort StateAbbrev DistName Subject GradeLevel
    export excel using "$Output/TUDA_StateAssmtData.xlsx", sheet("`year'") sheetreplace firstrow(variables)
	restore
}
