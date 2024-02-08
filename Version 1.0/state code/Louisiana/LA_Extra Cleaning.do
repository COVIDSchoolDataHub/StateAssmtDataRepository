clear
set more off
local Cleaned "/Volumes/T7/State Test Project/LA/Cleaned"
local Output "/Volumes/T7/State Test Project/LA/Output"

forvalues year = 2015/2023 {
	if `year' == 2020 continue
if `year' != 2016 & `year' != 2019 use "`Cleaned'/LA_AssmtData_`year'"
if `year' == 2016 | `year' == 2019 use "`Output'/LA_AssmtData_`year'"


foreach var of varlist Lev*_count StudentSubGroup_TotalTested {
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
}

//Fixing decimals
foreach var of varlist Lev*_percent {
	destring `var', gen(n`var') i(*-)
	replace `var' = string(n`var', "%9.5g") if strpos(`var', "-") ==0 & strpos(`var', "*") == 0
}

//Generating ProficientOrAbove_Count and Percent
foreach var of varlist Lev* {
	gen low`var' = substr(`var', 1, strpos(`var', "-")-1)
	destring low`var', replace i(*-)
	gen high`var' = substr(`var', strpos(`var', "-")+1,10)
	destring high`var', replace i(*-)
	replace low`var' = high`var' if strpos(`var', "-") == 0
}
gen lowProficientOrAbove_percent = round(lowLev4_percent + lowLev5_percent, 0.01)
gen highProficientOrAbove_percent = round(highLev4_percent + highLev5_percent, 0.01)
replace ProficientOrAbove_percent = string(lowProficientOrAbove_percent) + "-" + string(highProficientOrAbove_percent) if lowProficientOrAbove_percent != highProficientOrAbove_percent
replace ProficientOrAbove_percent = string(highProficientOrAbove_percent) if lowProficientOrAbove_percent == highProficientOrAbove_percent & ProficientOrAbove_percent != "*" & ProficientOrAbove_percent != "--"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

gen lowProficientOrAbove_count = lowLev4_count + lowLev5_count
gen highProficientOrAbove_count = highLev4_count + highLev5_count
replace ProficientOrAbove_count = string(lowProficientOrAbove_count) + "-" + string(highProficientOrAbove_count) if lowProficientOrAbove_count != highProficientOrAbove_count
replace ProficientOrAbove_count = string(highProficientOrAbove_count) if lowProficientOrAbove_count == highProficientOrAbove_count & ProficientOrAbove_count != "*" & ProficientOrAbove_count != "--"

//ParticipationRate
replace ParticipationRate = ".99-1" if ParticipationRate == "≥.99" | (strpos(ParticipationRate, "¥") !=0 & strpos(ParticipationRate, ".99"))

//Eliminating ranges where possible
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
destring ProficientOrAbove_count, gen(nProficientOrAbove_count) i(-*)
replace ProficientOrAbove_percent = string(nProficientOrAbove_count/nStudentSubGroup_TotalTested, "%9.3g") if strpos(ProficientOrAbove_count, "-") ==0 & strpos(StudentSubGroup_TotalTested, "-") ==0

//Fixing decimal ranges
foreach var of varlist _all {
	cap replace `var' = subinstr(`var',"0.",".",.)
	if "`var'" == "ProficientOrAbove_percent" replace `var' = subinstr(`var',"1.05","1",.)
}

if `year' != 2016 & `year' != 2019 {
//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
}


//Final Cleaning and exporting
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
	
	
save "`Output'/LA_AssmtData_`year'", replace
export delimited "`Output'/LA_AssmtData_`year'", replace	
	
}
