clear
set more off
set trace off

global Original "/Users/miramehta/Documents/AR State Testing Data/Original Data"
global Output "/Users/miramehta/Documents/AR State Testing Data/Output"
global NCES "//Users/miramehta/Documents/NCES District and School Demographics"
global Temp "/Users/miramehta/Documents/AR State Testing Data/Temp"
global EDFacts "/Users/miramehta/Documents/AR State Testing Data/EDFacts"

//Importing

forvalues year = 2016/2023 {
local prevyear =`=`year'-1'
if `year' == 2020 continue
tempfile temp1
save "`temp1'", replace emptyok 
clear

import excel "${Original}/AR_OriginalData_`year'", sheet(Schools) firstrow allstring
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/AR_OriginalData_`year'", sheet(Districts) firstrow allstring
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/AR_OriginalData_`year'", sheet(State) firstrow allstring
append using "`temp1'"
save "${Original}/`year'", replace


//Renaming in prep for reshape
rename EnglishN StudentSubGroup_TotalTestedeng
rename EnglishInNeedofSupport Lev1_percenteng
rename EnglishClose Lev2_percenteng
rename EnglishReady Lev3_percenteng
rename EnglishExceeding Lev4_percenteng
rename EnglishMetReadinessBenchmar ProficientOrAbove_percenteng
rename MathN StudentSubGroup_TotalTestedmath
rename MathInNeedofSupport Lev1_percentmath
rename MathClose Lev2_percentmath
rename MathReady Lev3_percentmath
rename MathExceeding Lev4_percentmath
rename MathMetReadinessBenchmark ProficientOrAbove_percentmath
rename ScienceN StudentSubGroup_TotalTestedsci
rename ScienceInNeedofSupport Lev1_percentsci
rename ScienceClose Lev2_percentsci
rename ScienceReady Lev3_percentsci
rename ScienceExceeding Lev4_percentsci
rename ScienceMetReadinessBenchmar ProficientOrAbove_percentsci
rename ReadingN StudentSubGroup_TotalTestedread
rename ReadingInNeedofSupport Lev1_percentread
rename ReadingClose Lev2_percentread
rename ReadingReady Lev3_percentread
rename ReadingExceeding Lev4_percentread
rename ReadingMetReadinessBenchmar ProficientOrAbove_percentread
if `year' < 2018 {
rename WritingN StudentSubGroup_TotalTestedwrit
rename WritingInNeedofSupport Lev1_percentwrit
rename WritingClose Lev2_percentwrit
rename WritingReady Lev3_percentwrit
rename WritingExceeding Lev4_percentwrit
rename WritingMetReadinessBenchmar ProficientOrAbove_percentwrit
}
rename ELAN StudentSubGroup_TotalTestedela
rename ELAInNeedofSupport Lev1_percentela
rename ELAClose Lev2_percentela
rename ELAReady Lev3_percentela
rename ELAExceeding Lev4_percentela
rename ELAMetReadinessBenchmark ProficientOrAbove_percentela
rename STEMN StudentSubGroup_TotalTestedstem
rename STEMMetReadinessBenchmark ProficientOrAbove_percentstem
if `year' < 2021 rename Grade GradeLevel
if `year' == 2016 rename DISTRICTLEA DistrictLEA
rename DistrictLEA StateAssignedDistID
rename SchoolLEA StateAssignedSchID
cap rename DISTRICTNAME DistName
cap rename SCHOOLNAME SchName
cap rename DistrictName DistName
cap rename SchoolName SchName 
if `year' == 2022 replace StateAssignedDistID = DISTRICTLEA if missing(StateAssignedDistID)
if `year' == 2022 drop DISTRICTLEA
if `year' == 2022 {
	drop if GradeLevel == "" & DistName == "" & SchName == ""
}
//Reshaping from wide to long
reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent StudentSubGroup_TotalTested ProficientOrAbove_percent, i(GradeLevel StateAssignedSchID StateAssignedDistID) j(Subject, string)
*save "/Volumes/T7/State Test Project/Arkansas/Testing/`year'", replace


//GradeLevel
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//StudentSubGroup and StudentGroup
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

//Supression / missing
foreach var of varlist Lev* ProficientOrAbove_percent StudentSubGroup_TotalTested StudentGroup_TotalTested {
	replace `var' = lower(`var')
	replace `var' = "*" if `var' == "n<10"
	replace `var' = "*" if `year' == 2019 & Subject == "ela" & `var' == "."
	replace `var' = "--" if missing(`var')
	replace `var' = "--" if `var' == "na"
	replace `var' = "--" if `var' == "."
}

//Proficiency Levels
foreach n in 1 2 3 4 {
	drop if Lev`n'_percent == "rv"
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*-%)
	replace Lev`n'_percent = string(nLev`n'_percent/100) if Lev`n'_percent != "*" & Lev`n'_percent != "--"
	
}

destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*-%)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100) if ProficientOrAbove_percent != "*" & ProficientOrAbove_percent != "--"

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if missing(StateAssignedDistID) & missing(StateAssignedSchID)
replace DataLevel = "District" if !missing(StateAssignedDistID) & missing(StateAssignedSchID)
replace DataLevel = "School" if !missing(StateAssignedDistID) & !missing(StateAssignedSchID)
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1
*save "/Volumes/T7/State Test Project/Arkansas/Testing/`year'", replace

**Merging**
gen StateAssignedSchID1 = ""
if `year' == 2016 replace StateAssignedSchID1 = StateAssignedSchID
if `year' > 2016 replace StateAssignedSchID1 = StateAssignedDistID + "-" + StateAssignedSchID
tempfile temp1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
clear
use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_`prevyear'_District"
keep if state_name == "Arkansas" | state_location == "AR"
gen StateAssignedDistID = subinstr(state_leaid, "AR-","",.)
duplicates drop StateAssignedDistID, force
if `year' == 2023 tostring _all, replace force
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge ==1
save "`tempdist'", replace
clear

//School 
use "`temp1'"
keep if DataLevel ==3
tempfile tempsch
save "`tempsch'", replace
clear
use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_`prevyear'_School"
keep if state_name == "Arkansas" | state_location == "AR"
gen StateAssignedSchID1 = seasch
 if `year' ==2019 replace StateAssignedSchID1 = "6061700-6061702" if ncesschoolid == "050042301657"
if `year' == 2023 {
 	
replace StateAssignedSchID1 = "3201000-3201702" if ncesschoolid == "050001900042"
replace StateAssignedSchID1 = "0442700-0442703" if ncesschoolid == "050040901606"
 }

if `year' == 2023 {
foreach var of varlist year district_agency_type SchLevel SchVirtual school_type {
	decode `var', gen(`var'_x)
	drop `var'
	rename `var'_x `var'
}
tostring _all, replace force
}
duplicates drop StateAssignedSchID, force
merge 1:m StateAssignedSchID1 using "`tempsch'"
drop if _merge ==1


save "`tempsch'", replace

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"

//Fixing NCES Variables
rename state_location StateAbbrev
drop state_fips
rename district_agency_type DistType
*rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
gen StateFips = 5
replace StateAbbrev = "AR"
if `year' == 2023 rename school_type SchType

/*

//2023 Unmerged Using 2022 NCES preliminary
tempfile temp2
save "`temp2'", replace
if `year' == 2023 {	
keep if missing(NCESSchoolID) & DataLevel == 3
save "${Temp}/Unmerged_2023", replace
use "${NCES}/NCES_2022_School.dta"
keep if StateName == "Arkansas"
gen StateAssignedSchID = substr(st_schid, -7,7)
gen StateAssignedDistID = State_leaid

*Cleaning 2023 NCES
rename SchoolType SchType
drop SchYear 
foreach var of varlist SchLevel SchVirtual SchType {
replace `var' = "Missing/not reported"
label def `var' -1 "Missing/not reported"
encode `var', gen(n`var') label(`var')
drop `var'
rename n`var' `var'
}
gen DistLocale = "Missing/not reported"
destring StateFips, replace

*Merging
merge 1:m StateAssignedSchID using "${Temp}/Unmerged_2023", keep(match using) nogen
save "${Temp}/Unmerged_2023", replace
clear
use "`temp2'"
drop if missing(NCESSchoolID) & DataLevel == 3
append using "${Temp}/Unmerged_2023"
}

*/


//Generating additional variables
gen State = "Arkansas"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = ""
gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular and alt"
gen AssmtName = "ACT Aspire"
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2018
replace Flag_CutScoreChange_sci = "Y" if `year' == 2018

foreach var of varlist Flag* {
	replace `var' = "Y" if `year' == 2016
}

//Missing Variables

foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
}
gen ProficientOrAbove_count = "--"
gen Lev5_percent = "--"
gen Lev5_count = "--"
gen AvgScaleScore = "--"
gen ParticipationRate = "--"

//Dropping if StudentSubGroup_TotalTested == 0
drop if StudentSubGroup_TotalTested == "0"

//Missing DistName for some obs (??)
replace DistName = "ARKANSAS CONNECTIONS ACADEMY" if NCESDistrictID == "0500417"
replace DistName = "JACKSONVILLE NORTH PULASKI SCHOOL DISTRICT" if NCESDistrictID == "0500419"

drop if missing(DistName) & missing(NCESDistrictID) & DataLevel ==2
replace DistName = lea_name if missing(DistName) & DataLevel ==2

//Writing
replace Subject = "wri" if Subject == "writ"


/*
//2023 Unmerged (Manual code)
if `year' == 2023 {
replace NCESSchoolID = "050438005135" if SchName == "CLARKSVILLE INTERMEDIATE SCHOOL"
replace NCESDistrictID = "0504380" if SchName == "CLARKSVILLE INTERMEDIATE SCHOOL"
replace State_leaid = "AR-3601000" if SchName == "CLARKSVILLE INTERMEDIATE SCHOOL"
replace seasch = "3601000-3601006" if SchName == "CLARKSVILLE INTERMEDIATE SCHOOL"
replace SchType = 1 if SchName == "CLARKSVILLE INTERMEDIATE SCHOOL"
replace DistType = 1 if SchName == "CLARKSVILLE INTERMEDIATE SCHOOL"
replace DistCharter = "No" if SchName == "CLARKSVILLE INTERMEDIATE SCHOOL"
replace SchVirtual = 0 if SchName == "CLARKSVILLE INTERMEDIATE SCHOOL"
replace CountyName = "Johnson County" if SchName == "CLARKSVILLE INTERMEDIATE SCHOOL"
replace CountyCode = 5071 if SchName == "CLARKSVILLE INTERMEDIATE SCHOOL"
replace SchLevel = 7 if SchName == "CLARKSVILLE INTERMEDIATE SCHOOL"

replace NCESSchoolID = "050633005147" if SchName == "FORT SMITH VIRTUAL ACADEMY"
replace NCESDistrictID = "0506330" if SchName == "FORT SMITH VIRTUAL ACADEMY"
replace State_leaid = "AR-6601000" if SchName == "FORT SMITH VIRTUAL ACADEMY"
replace seasch = "6601000-6601702" if SchName == "FORT SMITH VIRTUAL ACADEMY"
replace SchType = 1 if SchName == "FORT SMITH VIRTUAL ACADEMY"
replace DistType = 7 if SchName == "FORT SMITH VIRTUAL ACADEMY"
replace DistCharter = "Yes" if SchName == "FORT SMITH VIRTUAL ACADEMY"
replace SchVirtual = 1 if SchName == "FORT SMITH VIRTUAL ACADEMY"
replace CountyName = "Sebastian County" if SchName == "FORT SMITH VIRTUAL ACADEMY"
replace CountyCode = 5131 if SchName == "FORT SMITH VIRTUAL ACADEMY"
replace SchLevel = 7 if SchName == "FORT SMITH VIRTUAL ACADEMY"

replace NCESSchoolID = "050040905131" if SchName == "FOUNDERS CLASSICAL ACADEMIES OF ARKANSAS ROGERS"
replace NCESDistrictID = "0500409" if SchName == "FOUNDERS CLASSICAL ACADEMIES OF ARKANSAS ROGERS"
replace State_leaid = "AR-0442700" if SchName == "FOUNDERS CLASSICAL ACADEMIES OF ARKANSAS ROGERS"
replace seasch = "0442700-0442701" if SchName == "FOUNDERS CLASSICAL ACADEMIES OF ARKANSAS ROGERS"
replace SchType = 1 if SchName == "FOUNDERS CLASSICAL ACADEMIES OF ARKANSAS ROGERS"
replace DistType = 7 if SchName == "FOUNDERS CLASSICAL ACADEMIES OF ARKANSAS ROGERS"
replace DistCharter = "Yes" if SchName == "FOUNDERS CLASSICAL ACADEMIES OF ARKANSAS ROGERS"
replace SchVirtual = 0 if SchName == "FOUNDERS CLASSICAL ACADEMIES OF ARKANSAS ROGERS"
replace CountyName = "Benton County" if SchName == "FOUNDERS CLASSICAL ACADEMIES OF ARKANSAS ROGERS"
replace CountyCode = 5007 if SchName == "FOUNDERS CLASSICAL ACADEMIES OF ARKANSAS ROGERS"
replace SchLevel = 1 if SchName == "FOUNDERS CLASSICAL ACADEMIES OF ARKANSAS ROGERS"

replace NCESSchoolID = "050042301681" if SchName == "FRIENDSHIP ACADEMY LITTLE ROCK ELEMENTARY"
replace NCESDistrictID = "0500423" if SchName == "FRIENDSHIP ACADEMY LITTLE ROCK ELEMENTARY"
replace State_leaid = "AR-3544700" if SchName == "FRIENDSHIP ACADEMY LITTLE ROCK ELEMENTARY"
replace seasch = "3544700-3544704" if SchName == "FRIENDSHIP ACADEMY LITTLE ROCK ELEMENTARY"
replace SchType = 1 if SchName == "FRIENDSHIP ACADEMY LITTLE ROCK ELEMENTARY"
replace DistType = 7 if SchName == "FRIENDSHIP ACADEMY LITTLE ROCK ELEMENTARY"
replace DistCharter = "Yes" if SchName == "FRIENDSHIP ACADEMY LITTLE ROCK ELEMENTARY"
replace SchVirtual = 0 if SchName == "FRIENDSHIP ACADEMY LITTLE ROCK ELEMENTARY"
replace CountyName  = "Jefferson County" if SchName == "FRIENDSHIP ACADEMY LITTLE ROCK ELEMENTARY"
replace CountyCode = 5069 if SchName == "FRIENDSHIP ACADEMY LITTLE ROCK ELEMENTARY"
replace SchLevel = 1 if SchName == "FRIENDSHIP ACADEMY LITTLE ROCK ELEMENTARY"

replace NCESSchoolID = "050042301683" if SchName == "FRIENDSHIP ASPIRE ACADEMY LITTLE ROCK MIDDLE SCHOOL"
replace NCESDistrictID = "0500423" if SchName == "FRIENDSHIP ASPIRE ACADEMY LITTLE ROCK MIDDLE SCHOOL"
replace State_leaid = "AR-3544700" if SchName == "FRIENDSHIP ASPIRE ACADEMY LITTLE ROCK MIDDLE SCHOOL"
replace seasch = "3544700-3544702" if SchName == "FRIENDSHIP ASPIRE ACADEMY LITTLE ROCK MIDDLE SCHOOL"
replace SchType = 1 if SchName == "FRIENDSHIP ASPIRE ACADEMY LITTLE ROCK MIDDLE SCHOOL"
replace DistType = 7 if SchName == "FRIENDSHIP ASPIRE ACADEMY LITTLE ROCK MIDDLE SCHOOL"
replace DistCharter = "Yes" if SchName == "FRIENDSHIP ASPIRE ACADEMY LITTLE ROCK MIDDLE SCHOOL"
replace SchVirtual = 0 if SchName == "FRIENDSHIP ASPIRE ACADEMY LITTLE ROCK MIDDLE SCHOOL"
replace CountyName = "Jefferson County" if SchName == "FRIENDSHIP ASPIRE ACADEMY LITTLE ROCK MIDDLE SCHOOL"
replace CountyCode = 5069 if SchName == "FRIENDSHIP ASPIRE ACADEMY LITTLE ROCK MIDDLE SCHOOL"
replace SchLevel = 2 if SchName == "FRIENDSHIP ASPIRE ACADEMY LITTLE ROCK MIDDLE SCHOOL"

replace NCESSchoolID = "050042301707" if SchName == "FRIENDSHIP ASPIRE ACADEMY SOUTHEAST PINE BLUFF"
replace NCESDistrictID = "0500423" if SchName == "FRIENDSHIP ASPIRE ACADEMY SOUTHEAST PINE BLUFF"
replace State_leaid = "AR-3544700" if SchName == "FRIENDSHIP ASPIRE ACADEMY SOUTHEAST PINE BLUFF"
replace seasch = "3544700-3544703" if SchName == "FRIENDSHIP ASPIRE ACADEMY SOUTHEAST PINE BLUFF"
replace SchType = 1 if SchName == "FRIENDSHIP ASPIRE ACADEMY SOUTHEAST PINE BLUFF"
replace DistType = 7 if SchName == "FRIENDSHIP ASPIRE ACADEMY SOUTHEAST PINE BLUFF"
replace DistCharter = "Yes" if SchName == "FRIENDSHIP ASPIRE ACADEMY SOUTHEAST PINE BLUFF"
replace SchVirtual = 0 if SchName == "FRIENDSHIP ASPIRE ACADEMY SOUTHEAST PINE BLUFF"
replace CountyName = "Jefferson County" if SchName == "FRIENDSHIP ASPIRE ACADEMY SOUTHEAST PINE BLUFF"
replace CountyCode = 5069 if SchName == "FRIENDSHIP ASPIRE ACADEMY SOUTHEAST PINE BLUFF"
replace SchLevel = 7 if SchName == "FRIENDSHIP ASPIRE ACADEMY SOUTHEAST PINE BLUFF"

replace NCESSchoolID = "050411005137" if SchName == "GENOA CENTRAL JUNIOR HIGH"
replace NCESDistrictID = "0504110" if SchName == "GENOA CENTRAL JUNIOR HIGH"
replace State_leaid = "AR-4602000" if SchName == "GENOA CENTRAL JUNIOR HIGH"
replace seasch = "4602000-4602008" if SchName == "GENOA CENTRAL JUNIOR HIGH"
replace SchType = 1 if SchName == "GENOA CENTRAL JUNIOR HIGH"
replace DistType = 1 if SchName == "GENOA CENTRAL JUNIOR HIGH"
replace DistCharter = "No" if SchName == "GENOA CENTRAL JUNIOR HIGH"
replace SchVirtual = 0 if SchName == "GENOA CENTRAL JUNIOR HIGH"
replace CountyName = "Miller County" if SchName == "GENOA CENTRAL JUNIOR HIGH"
replace CountyCode = 5091 if SchName == "GENOA CENTRAL JUNIOR HIGH"
replace SchLevel = 2 if SchName == "GENOA CENTRAL JUNIOR HIGH"

replace NCESSchoolID = "050004305129" if SchName == "GUY BERRY COLLEGE AND CAREER ACADEMY"
replace NCESDistrictID = "0500043" if SchName == "GUY BERRY COLLEGE AND CAREER ACADEMY"
replace State_leaid = "AR-0303000" if SchName == "GUY BERRY COLLEGE AND CAREER ACADEMY"
replace seasch = "0303000-0303706" if SchName == "GUY BERRY COLLEGE AND CAREER ACADEMY"
replace SchType = 1 if SchName == "GUY BERRY COLLEGE AND CAREER ACADEMY"
replace DistType = 1 if SchName == "GUY BERRY COLLEGE AND CAREER ACADEMY"
replace DistCharter = "Yes" if SchName == "GUY BERRY COLLEGE AND CAREER ACADEMY"
replace SchVirtual = 0 if SchName == "GUY BERRY COLLEGE AND CAREER ACADEMY"
replace CountyName = "Baxter County" if SchName == "GUY BERRY COLLEGE AND CAREER ACADEMY"
replace CountyCode = 5065 if SchName == "GUY BERRY COLLEGE AND CAREER ACADEMY"
replace SchLevel = 7 if SchName == "GUY BERRY COLLEGE AND CAREER ACADEMY"

replace NCESSchoolID = "050007405142" if SchName == "LISA ACADEMY ROGERS-BENTONVILLE ELEMENTARY SCHOOL"
replace NCESDistrictID = "0500074" if SchName == "LISA ACADEMY ROGERS-BENTONVILLE ELEMENTARY SCHOOL"
replace State_leaid = "AR-6041700" if SchName == "LISA ACADEMY ROGERS-BENTONVILLE ELEMENTARY SCHOOL"
replace seasch = "6041700-6041710" if SchName == "LISA ACADEMY ROGERS-BENTONVILLE ELEMENTARY SCHOOL"
replace SchType = 1 if SchName == "LISA ACADEMY ROGERS-BENTONVILLE ELEMENTARY SCHOOL"
replace DistType = 7 if SchName == "LISA ACADEMY ROGERS-BENTONVILLE ELEMENTARY SCHOOL"
replace DistCharter = "Yes" if SchName == "LISA ACADEMY ROGERS-BENTONVILLE ELEMENTARY SCHOOL"
replace SchVirtual = 0 if SchName == "LISA ACADEMY ROGERS-BENTONVILLE ELEMENTARY SCHOOL"
replace CountyName = "Pulaski County" if SchName == "LISA ACADEMY ROGERS-BENTONVILLE ELEMENTARY SCHOOL"
replace CountyCode = 5119 if SchName == "LISA ACADEMY ROGERS-BENTONVILLE ELEMENTARY SCHOOL"
replace SchLevel = 1 if SchName == "LISA ACADEMY ROGERS-BENTONVILLE ELEMENTARY SCHOOL"

replace NCESSchoolID = "050007405143" if SchName == "LISA ACADEMY ROGERS-BENTONVILLE MIDDLE SCHOOL"
replace NCESDistrictID = "0500074" if SchName == "LISA ACADEMY ROGERS-BENTONVILLE MIDDLE SCHOOL"
replace State_leaid = "AR-6041700" if SchName == "LISA ACADEMY ROGERS-BENTONVILLE MIDDLE SCHOOL"
replace seasch = "6041700-6041711" if SchName == "LISA ACADEMY ROGERS-BENTONVILLE MIDDLE SCHOOL"
replace SchType = 1 if SchName == "LISA ACADEMY ROGERS-BENTONVILLE MIDDLE SCHOOL"
replace DistType = 7 if SchName == "LISA ACADEMY ROGERS-BENTONVILLE MIDDLE SCHOOL"
replace DistCharter = "Yes" if SchName == "LISA ACADEMY ROGERS-BENTONVILLE MIDDLE SCHOOL"
replace SchVirtual = 0 if SchName == "LISA ACADEMY ROGERS-BENTONVILLE MIDDLE SCHOOL"
replace CountyName = "Pulaski County" if SchName == "LISA ACADEMY ROGERS-BENTONVILLE MIDDLE SCHOOL"
replace CountyCode = 5119 if SchName == "LISA ACADEMY ROGERS-BENTONVILLE MIDDLE SCHOOL"
replace SchLevel = 2 if SchName == "LISA ACADEMY ROGERS-BENTONVILLE MIDDLE SCHOOL"

replace NCESSchoolID = "050005905141" if SchName == "MAUMELLE CHARTER MIDDLE SCHOOL"
replace NCESDistrictID = "0500059" if SchName == "MAUMELLE CHARTER MIDDLE SCHOOL"
replace State_leaid = "AR-6040700" if SchName == "MAUMELLE CHARTER MIDDLE SCHOOL"
replace seasch = "6040700-6040705" if SchName == "MAUMELLE CHARTER MIDDLE SCHOOL"
replace SchType = 1 if SchName == "MAUMELLE CHARTER MIDDLE SCHOOL"
replace DistType = 7 if SchName == "MAUMELLE CHARTER MIDDLE SCHOOL"
replace DistCharter = "Yes" if SchName == "MAUMELLE CHARTER MIDDLE SCHOOL"
replace SchVirtual = 0 if SchName == "MAUMELLE CHARTER MIDDLE SCHOOL"
replace CountyName = "Pulaski County" if SchName == "MAUMELLE CHARTER MIDDLE SCHOOL"
replace CountyCode = 5119 if SchName == "MAUMELLE CHARTER MIDDLE SCHOOL"
replace SchLevel = 2 if SchName == "MAUMELLE CHARTER MIDDLE SCHOOL"

replace NCESSchoolID = "050729005139" if SchName == "SPARKMAN ELEMENTARY SCHOOL"
replace NCESDistrictID = "0507290" if SchName == "SPARKMAN ELEMENTARY SCHOOL"
replace State_leaid = "AR-5205000" if SchName == "SPARKMAN ELEMENTARY SCHOOL"
replace seasch = "5205000-5205014" if SchName == "SPARKMAN ELEMENTARY SCHOOL"
replace SchType = 1 if SchName == "SPARKMAN ELEMENTARY SCHOOL"
replace DistCharter = "No" if SchName == "SPARKMAN ELEMENTARY SCHOOL"
replace SchVirtual = 0 if SchName == "SPARKMAN ELEMENTARY SCHOOL"
replace CountyName = "Ouachita County" if SchName == "SPARKMAN ELEMENTARY SCHOOL"
replace CountyCode = 5103 if SchName == "SPARKMAN ELEMENTARY SCHOOL"
replace SchLevel = 1 if SchName == "SPARKMAN ELEMENTARY SCHOOL"

replace NCESSchoolID = "050306005130" if SchName == "VAUGHN ELEMENTARY"
replace NCESDistrictID = "0503060" if SchName == "VAUGHN ELEMENTARY"
replace State_leaid = "AR-0401000" if SchName == "VAUGHN ELEMENTARY"
replace seasch = "0401000-0401024" if SchName == "VAUGHN ELEMENTARY"
replace SchType = 1 if SchName == "VAUGHN ELEMENTARY"
replace DistCharter = "No" if SchName == "VAUGHN ELEMENTARY"
replace SchVirtual = 0 if SchName == "VAUGHN ELEMENTARY"
replace CountyName = "Benton County" if SchName == "VAUGHN ELEMENTARY"
replace CountyCode = 5007 if SchName == "VAUGHN ELEMENTARY"
replace SchLevel = 1 if SchName == "VAUGHN ELEMENTARY"

replace NCESSchoolID = "051449005136" if SchName == "YELLVILLE-SUMMIT MIDDLE SCHOOL"
replace NCESDistrictID = "0514490" if SchName == "YELLVILLE-SUMMIT MIDDLE SCHOOL"
replace State_leaid = "AR-4502000" if SchName == "YELLVILLE-SUMMIT MIDDLE SCHOOL"
replace seasch = "4502000-4502008" if SchName == "YELLVILLE-SUMMIT MIDDLE SCHOOL"
replace SchType = 1 if SchName == "YELLVILLE-SUMMIT MIDDLE SCHOOL"
replace DistCharter = "No" if SchName == "YELLVILLE-SUMMIT MIDDLE SCHOOL"
replace SchVirtual = 0 if SchName == "YELLVILLE-SUMMIT MIDDLE SCHOOL"
replace CountyName = "Marion County" if SchName == "YELLVILLE-SUMMIT MIDDLE SCHOOL"
replace CountyCode = 5089 if SchName == "YELLVILLE-SUMMIT MIDDLE SCHOOL"
replace SchLevel = 2 if SchName == "YELLVILLE-SUMMIT MIDDLE SCHOOL"

replace NCESSchoolID = "050040905132" if SchName == "FOUNDERS CLASSICAL ACADEMY ELEMENTARY ONLINE"
replace NCESDistrictID = "0500409" if SchName == "FOUNDERS CLASSICAL ACADEMY ELEMENTARY ONLINE"
replace State_leaid = "AR-0442700" if SchName == "FOUNDERS CLASSICAL ACADEMY ELEMENTARY ONLINE"
replace seasch = "0442700-0442707" if SchName == "FOUNDERS CLASSICAL ACADEMY ELEMENTARY ONLINE"
replace SchType = 1 if SchName == "FOUNDERS CLASSICAL ACADEMY ELEMENTARY ONLINE"
replace DistCharter = "Yes" if SchName == "FOUNDERS CLASSICAL ACADEMY ELEMENTARY ONLINE"
replace SchVirtual = 1 if SchName == "FOUNDERS CLASSICAL ACADEMY ELEMENTARY ONLINE"
replace CountyName = "Benton County" if SchName == "FOUNDERS CLASSICAL ACADEMY ELEMENTARY ONLINE"
replace CountyCode = 5007 if SchName == "FOUNDERS CLASSICAL ACADEMY ELEMENTARY ONLINE"
replace SchLevel = 1 if SchName == "FOUNDERS CLASSICAL ACADEMY ELEMENTARY ONLINE"

replace NCESSchoolID = "050040905133" if SchName == "FOUNDERS CLASSICAL ACADEMY HIGH SCHOOL ONLINE"
replace NCESDistrictID = "0500409" if SchName == "FOUNDERS CLASSICAL ACADEMY HIGH SCHOOL ONLINE"
replace State_leaid = "AR-0442700" if SchName == "FOUNDERS CLASSICAL ACADEMY HIGH SCHOOL ONLINE"
replace seasch = "0442700-0442709" if SchName == "FOUNDERS CLASSICAL ACADEMY HIGH SCHOOL ONLINE"
replace SchType = 1 if SchName == "FOUNDERS CLASSICAL ACADEMY HIGH SCHOOL ONLINE"
replace DistCharter = "Yes" if SchName == "FOUNDERS CLASSICAL ACADEMY HIGH SCHOOL ONLINE"
replace SchVirtual = 1 if SchName == "FOUNDERS CLASSICAL ACADEMY HIGH SCHOOL ONLINE"
replace CountyName = "Benton County" if SchName == "FOUNDERS CLASSICAL ACADEMY HIGH SCHOOL ONLINE"
replace CountyCode = 5007 if SchName == "FOUNDERS CLASSICAL ACADEMY HIGH SCHOOL ONLINE"
replace SchLevel = 2 if SchName == "FOUNDERS CLASSICAL ACADEMY HIGH SCHOOL ONLINE"
}
*/

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Temp}/AR_AssmtData_`year'_AllStudents", replace

clear
}
