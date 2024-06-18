clear
set more off
set trace off

//Importing

forvalues year = 2015/2021 {
if `year' == 2020 continue
foreach subject in ela math {
foreach dl in district school {
use "${edfacts}/edfactspart`year'`subject'`dl'.dta"
keep if STNAM == "WEST VIRGINIA"

//Renaming
rename LEAID NCESDistrictID
cap rename NCESSCH NCESSchoolID
rename SUBJECT Subject
rename GRADE GradeLevel
rename CATEGORY StudentSubGroup
cap rename PCTPART ParticipationRate
cap rename NUMVALID StudentSubGroup_TotalTested

//Subject
replace Subject = "ela" if Subject == "RLA"
replace Subject = "math" if Subject == "MTH"

//GradeLevel
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//StudentSubGroup
replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "MAM"
replace StudentSubGroup = "Asian" if StudentSubGroup == "MAS"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "MHI"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "MBL"
replace StudentSubGroup = "White" if StudentSubGroup == "MWH"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "MTR"
replace StudentSubGroup = "SWD" if StudentSubGroup == "CWD"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "Female" if StudentSubGroup == "F"
replace StudentSubGroup = "Male" if StudentSubGroup == "M"
replace StudentSubGroup = "Homeless" if StudentSubGroup == "HOM"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "MIG"

//ParticipationRate
replace ParticipationRate = subinstr(ParticipationRate, "GE",">",.)
replace ParticipationRate = subinstr(ParticipationRate, "LE","<",.)
replace ParticipationRate = subinstr(ParticipationRate, "GT",">",.)
replace ParticipationRate = subinstr(ParticipationRate, "LT","<",.)
replace ParticipationRate = "*" if ParticipationRate == "PS"

foreach var of varlist ParticipationRate {
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
gen low`var' = substr(`var', 1, strpos(`var',"-")-1) if strpos(`var',"-") !=0
gen high`var' = substr(`var', strpos(`var',"-")+1, 2) if strpos(`var',"-") !=0
destring low`var', gen(nlow`var')
destring high`var', gen(nhigh`var')
replace low`var' = string((nlow`var'/100),"%9.3g")
replace high`var' = string((nhigh`var'/100),"%9.3g")
replace `var' = "R" if strpos(`var',"-") !=0
destring `var', gen(n`var') i(R*%<>-.n/a)
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--" & `var' != "R"
replace `var' = low`var' + "-" + high`var' if `var' == "R"
replace `var' = subinstr(`var', "=","",.)
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
replace `var' = "--" if `var' == "n/a" | `var' == "."
}

save "$data/WV_edfactspart`year'`subject'`dl'.dta", replace
}
}
clear
use "$data/WV_edfactspart`year'eladistrict.dta"
append using "$data/WV_edfactspart`year'elaschool.dta" "$data/WV_edfactspart`year'mathdistrict.dta" "$data/WV_edfactspart`year'mathschool.dta"
rename ParticipationRate ParticipationRate1
keep NCESDistrictID ParticipationRate1 StudentSubGroup GradeLevel Subject NCESSchoolID
save "$data/WV_edfactspart_`year'", replace
clear

use "$data/WV_AssmtData_`year'"
merge 1:1 NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject using "$data/WV_edfactspart_`year'", nogen keep(match master)
replace ParticipationRate = ParticipationRate1 if !missing(ParticipationRate1)

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$data/WV_AssmtData_`year'", replace
export delimited "$data/WV_AssmtData_`year'", replace
clear

}




