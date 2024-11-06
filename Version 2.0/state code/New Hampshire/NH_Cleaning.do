clear
set more off
set trace off
cap log close
global Original "/Users/miramehta/Documents/NH State Testing Data/Original Data Files"
global Output "/Users/miramehta/Documents/NH State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

//Converting to dta format
forvalues year = 2009/2024 {
	if `year' == 2020 continue
	local prevyear =`=`year'-1'
	import delimited "${Original}/NH_OriginalData_`year'_all", case(preserve) clear
	save "${Original}/NH_OriginalData_`year'_all", replace


//2019 Varnames
if `year' == 2019 {
foreach var of varlist _all {
	 replace `var' = subinstr(`var', " ", "",.) if _n ==1
	 replace `var' = subinstr(`var', "%","",.) if _n ==1
	 replace `var' = subinstr(`var', "&","",.) if _n ==1
	 replace `var' = subinstr(`var', "(","",.) if _n ==1
	 replace `var' = subinstr(`var', ")","",.) if _n ==1
	 replace `var' = subinstr(`var', "-","",.) if _n ==1
	 local newvar = `var'[1]
	 rename `var' `newvar'
}
drop in 1


save "${Original}/NH_OriginalData_`year'_all", replace
}

//All Varnames
if `year' < 2019 {
	drop yearid
	rename replevel DataLevel
	rename subject Subject
	drop DenominatorType
	rename disname DistName
	rename discode StateAssignedDistID
	rename schname SchName
	rename schcode StateAssignedSchID
	rename grade GradeLevel
	rename NumberStudents StudentSubGroup_TotalTested
	foreach n in 1 2 3 4 {
		rename plevel`n' Lev`n'_percent
	}
	rename pAboveprof ProficientOrAbove_percent
	drop pBelowProf
	rename AvgScore AvgScaleScore
	gen ParticipationRate = "--"
}
if `year' == 2019 {
	drop yearid
	rename LevelofData DataLevel
	rename District DistName
	rename School SchName
	rename Grade GradeLevel
	rename Subgroup StudentSubGroup
	foreach n in 1 2 3 4 {
		rename level`n' Lev`n'_percent
	}
	rename Aboveproflvl34 ProficientOrAbove_percent
	rename AvgScore AvgScaleScore
	rename Participate ParticipationRate
	rename TotalFAYStudents StudentSubGroup_TotalTested
	drop MeanSGP oftotaltestedDLMstate oftotaltestedELFirstYr ReportDate
	
	
}
if `year' > 2019 {
	drop DenominatorType yearid ReportDate
	rename LevelofData DataLevel
	rename District DistName
	rename School SchName
	rename Grade GradeLevel
	rename Subgroup StudentSubGroup
	rename TotalFAYStudents StudentSubGroup_TotalTested
	foreach n in 1 2 3 4 {
		rename level`n' Lev`n'_percent
	}
	rename Aboveproflvl34 ProficientOrAbove_percent
	rename AvgScore AvgScaleScore
	rename Participate ParticipationRate
	
}
	**Getting StateAssignedDistIDs for 2019+**
if `year' >= 2019 {
	

//Seperating by DataLevel
tempfile temp1
save "`temp1'", replace
use "`temp1'"
keep if strpos(DataLevel, "District")
tempfile tempdist
save "`tempdist'", replace
clear

use "`temp1'"
keep if strpos(DataLevel, "School")
tempfile tempsch
save "`tempsch'", replace
clear

//Merging
import delimited "${Original}/NH_OriginalData_`year'_IDs", clear
cap rename replevel DataLevel
cap rename levelofdata DataLevel
rename subject Subject
cap rename disname DistName
cap rename district DistName
rename discode StateAssignedDistID
cap rename schname SchName
cap rename school SchName
foreach n in 1 2 3 4 {
		rename plevel`n' Lev`n'_percent
	}
rename paboveprof ProficientOrAbove_percent
rename avgscore AvgScaleScore
rename numberstudents StudentSubGroup_TotalTested
rename grade GradeLevel
tostring GradeLevel, replace
rename schcode StateAssignedSchID
keep DistName SchName StateAssignedDistID StateAssignedSchID DataLevel Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent AvgScaleScore StudentSubGroup_TotalTested GradeLevel Subject
tempfile temp2
save "`temp2'", replace
clear
use "`temp2'"
keep DistName StateAssignedDistID
duplicates drop
merge 1:m DistName using "`tempdist'"
save "`tempdist'", replace
clear
use "`temp2'"
keep DistName StateAssignedDistID SchName StateAssignedSchID
duplicates drop
merge 1:m DistName SchName using "`tempsch'", replace update
save "`tempsch'", replace
clear

use "`temp1'"
keep if strpos(DataLevel, "District") ==0 & strpos(DataLevel, "School") ==0
di "~~~~~~~~"
di "`year'"
di "~~~~~~~~"
append using "`tempdist'" "`tempsch'"
drop _merge
}

//Subject
replace Subject = "math" if strpos(Subject, "ma") !=0
replace Subject = "ela" if strpos(Subject, "rea") !=0

//GradeLevel
tostring GradeLevel, replace
replace GradeLevel = subinstr(GradeLevel, "0", "",.)
replace GradeLevel = "G0" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//DataLevel
if `year' < 2019 replace DataLevel = "School"
if `year' > 2018 replace DataLevel = subinstr(DataLevel, " Level","",.)
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1

//Suppression and Missing
foreach var of varlist StudentSubGroup_TotalTested Lev* ProficientOrAbove_percent AvgScaleScore ParticipationRate {
	cap replace `var' = "*" if strpos(`var', "*") !=0
	cap replace `var' = "--" if `var' == "NULL"
	cap replace `var' = "10 - 15" if `var' == "15-Oct" // range being formatted as date in original data by accident
	cap replace `var' = "--" if `var' == "Not Available"
	replace `var' = "--" if `var' == ""
	if "`var'" == "StudentSubGroup_TotalTested" cap replace `var' = "--" if StudentSubGroup_TotalTested == "43573" & DataLevel ==3 //This value makes no sense at DataLevel == 3 but it seems common
}

//StudentSubGroup
if `year' < 2019 gen StudentSubGroup = "All Students"
if `year' == 2019 replace StudentSubGroup = trim(StudentSubGroup)
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All") !=0
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "Indian") !=0
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup, "Asian") !=0 //**StudentSubGroup ALSO INCLUDES Native Hawaiian or Pacific Islander	**
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup, "Black") !=0
replace StudentSubGroup = "English Learner" if strpos(StudentSubGroup, "EL - Current") !=0
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "EL - Curr + Monitor Yr1-4"
replace StudentSubGroup = "Hispanic or Latino" if strpos(StudentSubGroup, "Hispanic") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two or More") !=0
replace StudentSubGroup = "White" if strpos(StudentSubGroup, "White") !=0
replace StudentSubGroup = "Female" if strpos(StudentSubGroup, "Female") !=0
replace StudentSubGroup = "Male" if strpos(StudentSubGroup, "Male") !=0
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP/SWD"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not IEP/SWD"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "SES"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not SES"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL and Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"


//StudentGroup_TotalTested
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, ",","",.)
gen low_end_subgroup = real(substr(StudentSubGroup_TotalTested, 1, strpos(StudentSubGroup_TotalTested, "-")-2))
gen high_end_subgroup = real(substr(StudentSubGroup_TotalTested, strpos(StudentSubGroup_TotalTested, "-") +2,10))
sort StudentGroup
egen low_end_group = total(low_end_subgroup), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
egen high_end_group =  total(high_end_subgroup), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
replace StudentSubGroup_TotalTested = string(low_end_subgroup) + "-" + string(high_end_subgroup)
replace StudentSubGroup_TotalTested = "0" if high_end_subgroup ==0 | missing(high_end_subgroup)
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, ".-", "0-", 1) if strpos(StudentSubGroup_TotalTested, ".-") == 1
sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"

//Proficiency Levels
foreach var of varlist Lev* Proficient* ParticipationRate {
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
destring `var', gen(n`var') i(*%<>-)
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
replace `var' = subinstr(`var', "=","",.)
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
}

** Merging NCES **
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace
replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 2
replace StateAssignedDistID = "00" + StateAssignedDistID if strlen(StateAssignedDistID) == 1
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel !=3
tempfile temp1
save "`temp1'", replace
clear


//Fixing Missing IDs before Merge
if `year' >= 2021 {
	
}


//District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
clear
if `year' < 2024{
	use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_`prevyear'_District", clear
}
if `year' == 2024{
	use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District", clear
}
keep if state_name == "New Hampshire" | state_location == "NH"
rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename lea_name DistName
keep State StateAbbrev StateFips NCESDistrictID State_leaid DistType CountyName CountyCode DistLocale DistCharter

replace CountyName = strproper(CountyName)	

gen StateAssignedDistID = subinstr(State_leaid, "NH-","",.)
replace StateAssignedDistID = "00" + StateAssignedDistID if strlen(StateAssignedDistID) == 1

//Fixing not merging Districts
duplicates drop StateAssignedDistID, force
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge !=3 & DistName != "Lionheart Classical Academy Chartered Public School" & DistName != "Heartwood Public Charter School" & DistName != "Benjamin Franklin Academy Chartered Public School"
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear
if `year' < 2024{
	use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_`prevyear'_School"
}
if `year' == 2024{
	use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_2022_School"	
}
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
if `year' >= 2023 rename school_type SchType
if `year' >= 2023 {
	foreach var of varlist SchType SchLevel SchVirtual DistType {
		decode `var', gen(temp)
		drop `var'
		rename temp `var'
		}
	}
	
replace CountyName = strproper(CountyName)

keep if State == "New Hampshire" | StateAbbrev == "NH"
keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID State_leaid DistType CountyName CountyCode DistLocale DistCharter SchType SchVirtual SchLevel seasch sch_lowest_grade_offered
gen StateAssignedSchID = substr(seasch,-5,5)
duplicates drop StateAssignedSchID, force
if `year' >= 2012 {
replace StateAssignedSchID = "28985" if strpos(seasch, "85649128985491") !=0
replace StateAssignedSchID = "28990" if strpos(seasch, "58734228990393") !=0
} 
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge !=3 & SchName != "Lionheart Classical Academy Chartered Public School" & SchName != "Heartwood Public Charter School" & SchName != "Benjamin Franklin Academy Chartered Public School (M)"
save "`tempsch'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"


//Proficiency Criteria
gen ProficiencyCriteria = "Levels 3-4"

//AssmtName
gen AssmtName = "NECAP"
if `year' >= 2018 replace AssmtName = "NH SAS"
replace AssmtName = "Smarter Balanced Assessment" if Subject != "sci" & `year' < 2018 & `year' > = 2015 

//State 
replace State = "New Hampshire"
replace StateFips = 33
replace StateAbbrev = "NH"

//AssmtType
gen AssmtType = "Regular"

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"

replace Flag_AssmtNameChange = "Y" if `year' == 2018
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2018
replace Flag_CutScoreChange_math = "Y" if `year' == 2018
replace Flag_CutScoreChange_sci = "Y" if `year' == 2018
replace Flag_CutScoreChange_sci = "Not applicable" if `year' == 2014

//Indicator variables
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)

//Missing/empty Variables
gen Lev5_count = ""
gen Lev5_percent= ""
foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
}
gen ProficientOrAbove_count = "--"


//Fixing Unmerged
if `year' == 2023 {
replace StateAssignedDistID = "722" if DistName == "Lionheart Classical Academy Chartered Public School"
replace SchType = "Regular school" if SchName == "Lionheart Classical Academy Chartered Public School"
replace NCESDistrictID = "3399974" if DistName == "Lionheart Classical Academy Chartered Public School"
replace NCESSchoolID = "339997410033" if SchName == "Lionheart Classical Academy Chartered Public School"
replace StateAssignedSchID = "29246" if SchName == "Lionheart Classical Academy Chartered Public School"
replace DistCharter = "No" if DistName == "Lionheart Classical Academy Chartered Public School"
replace DistType = "Charter agency"  if DistName == "Lionheart Classical Academy Chartered Public School"
replace DistLocale = "Town, fringe" if DistName == "Lionheart Classical Academy Chartered Public School"
replace SchLevel = "Primary" if SchName == "Lionheart Classical Academy Chartered Public School"
replace SchVirtual = "No" if SchName == "Lionheart Classical Academy Chartered Public School"
replace CountyName  = "Hillsborough County" if DistName == "Lionheart Classical Academy Chartered Public School"
replace CountyCode = "33011" if DistName == "Lionheart Classical Academy Chartered Public School"

replace StateAssignedDistID = "718" if DistName == "Heartwood Public Charter School"
replace SchType = "Regular school" if SchName == "Heartwood Public Charter School"
replace NCESDistrictID = "3399972" if DistName == "Heartwood Public Charter School"
replace NCESSchoolID = "339997210031" if SchName == "Heartwood Public Charter School"
replace StateAssignedSchID = "29244" if SchName == "Heartwood Public Charter School"
replace DistCharter = "No" if DistName == "Heartwood Public Charter School"
replace DistType = "Charter agency"  if DistName == "Heartwood Public Charter School"
replace DistLocale = "Rural, remote" if DistName == "Heartwood Public Charter School"
replace SchLevel = "Primary" if SchName == "Heartwood Public Charter School"
replace SchVirtual = "No" if SchName == "Heartwood Public Charter School"
replace CountyName  = "Coos County" if DistName == "Heartwood Public Charter School"
replace CountyCode = "33007" if DistName == "Heartwood Public Charter School"

}

if `year' == 2024{
	replace NCESDistrictID = "3399976" if DistName == "Benjamin Franklin Academy Chartered Public School"
	replace DistType = "Charter agency" if NCESDistrictID == "3399976"
	replace DistCharter = "Yes" if NCESDistrictID == "3399976"
	replace DistLocale = "Town, fringe" if NCESDistrictID == "3399976"
	replace CountyName = "Merrimack County" if NCESDistrictID == "3399976"
	replace CountyCode = "33013" if NCESDistrictID == "3399976"
	
	replace NCESSchoolID = "339997610041" if SchName == "Benjamin Franklin Academy Chartered Public School (M)"
	replace SchType = "Regular school" if NCESSchoolID == "339997610041"
	replace SchLevel = "Middle" if NCESSchoolID == "339997610041"
	replace SchVirtual = "No" if NCESSchoolID == "339997610041"
}

//Deriving Count Ranges Where Possible
split StudentSubGroup_TotalTested, parse("-")
destring StudentSubGroup_TotalTested1, replace
destring StudentSubGroup_TotalTested2, replace
foreach count of varlist *_count {
local percent = subinstr("`count'","count","percent",.)
if "`count'" != "Lev5_count"{
	split `percent', parse("-")
	destring `percent'1, replace force
	destring `percent'2, replace force
	replace `count' = string(round(`percent'1 * StudentSubGroup_TotalTested1)) if `percent'1 != . & `percent'2 == . & round(`percent'1 * StudentSubGroup_TotalTested1) == round(`percent'1 * StudentSubGroup_TotalTested2)
	replace `count' = string(round(`percent'1 * StudentSubGroup_TotalTested1)) + "-" + string(round(`percent'1*StudentSubGroup_TotalTested2)) if `percent'1 != . & `percent'2 == . & round(`percent'1 * StudentSubGroup_TotalTested1) != round(`percent'1 * StudentSubGroup_TotalTested2)
	replace `count' = string(round(`percent'1 * StudentSubGroup_TotalTested1)) if `percent'1 != . & `percent'2 != . & round(`percent'1 * StudentSubGroup_TotalTested1) == round(`percent'2 * StudentSubGroup_TotalTested2)
	replace `count' = string(round(`percent'1 * StudentSubGroup_TotalTested1)) + "-" + string(round(`percent'2*StudentSubGroup_TotalTested2)) if `percent'1 != . & `percent'2 != . & round(`percent'1 * StudentSubGroup_TotalTested1) != round(`percent'2 * StudentSubGroup_TotalTested2)
	drop `percent'1 `percent'2
	}
}

//Flags
if `year' == 2015 {
	replace Flag_AssmtNameChange = "Y" if Subject != "sci"
	replace Flag_CutScoreChange_ELA = "Y"
	replace Flag_CutScoreChange_math = "Y"
	
}
if `year' == 2018 {
	replace Flag_AssmtNameChange = "Y"
	replace Flag_CutScoreChange_math = "Y"
	replace Flag_CutScoreChange_ELA = "Y"
	replace Flag_CutScoreChange_sci = "Y"
}


//Final Cleaning
replace DistName = strtrim(DistName)
replace SchName = strtrim(SchName)

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

duplicates drop
save "${Output}/NH_AssmtData_`year'", replace
export delimited "${Output}/NH_AssmtData_`year'", replace

*clear	
}

//Adding Aggregated District-Level Data
foreach year in 2017 2018 2019 2021 2022 {
local prevyear =`=`year'-1'
import excel "${Original}/NH_OriginalData_G38_Dist", firstrow case(preserve) allstring clear
keep if Yearid == "`year'"

//Variables
drop Yearid
drop FullAcademicYearFlag
drop DenominatorType
rename Grade GradeLevel
rename DisName DistName
foreach n in 1 2 3 4 {
	rename plevel`n'text Lev`n'_percent
}
gen SchName = "All Schools"


//SchYear
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)

//DataLevel
gen DataLevel = "District"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//GradeLevel
replace GradeLevel = "G38"

//Subject
replace Subject = "math" if Subject == "mat"
replace Subject = "ela" if Subject == "rea"

//Missing Variables
gen ParticipationRate = "--"
gen AvgScaleScore = "--"

//StudentSubGroup and StudentGroup
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

//StudentSubGroup_TotalTested and StudentGroup_TotalTested
gen StudentSubGroup_TotalTested = "--"
gen StudentGroup_TotalTested = "--"


//Suppression
foreach var of varlist StudentSubGroup_TotalTested Lev* ParticipationRate {
	cap replace `var' = "*" if strpos(`var', "*") !=0
	cap replace `var' = "--" if `var' == "NULL"
	cap replace `var' = "10 - 15" if `var' == "15-Oct" // Edited in response to R1
	cap replace `var' = "--" if `var' == "Not Available"
}


//Proficiency Levels
foreach var of varlist Lev* {
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
destring `var', gen(n`var') i(*%<>-)
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
replace `var' = subinstr(`var', "=","",.)
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
}
gen ProficientOrAbove_percent = string((nLev3_percent + nLev4_percent)/100, "%9.3g")
replace ProficientOrAbove_percent = rangeLev3_percent + ProficientOrAbove_percent if !missing(rangeLev3_percent)
replace ProficientOrAbove_percent = rangeLev4_percent + ProficientOrAbove_percent if !missing(rangeLev4_percent) & missing(rangeLev3_percent)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent,">","",.) + "-1" if strpos(ProficientOrAbove_percent, ">") !=0
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "<","0-",.) if strpos(ProficientOrAbove_percent, "<") !=0
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

//Getting NCES Information from Already Cleaned Data
tempfile temp1
save "`temp1'", replace
clear
use "${Output}/NH_AssmtData_`year'"
keep State StateAbbrev StateFips SchYear DistName StateAssignedDistID NCESDistrictID DistType DistCharter DistLocale CountyName CountyCode ProficiencyCriteria AssmtType
duplicates drop
merge 1:m DistName using "`temp1'"

drop if _merge == 2

//Appending Data
append using "${Output}/NH_AssmtData_`year'"

//Response to R1
replace NCESDistrictID = "3301710" if NCESDistrictID == "3399939"
drop if SchName == "MicroSociety Academy Charter School of Southern NH" & `year' == 2017 & missing(StateAssignedSchID) //Not sure whats happening here, but it's not merging and its a duplicate observation, so dropping
drop if SchName == ""


//Deriving Count Ranges Where Possible
split StudentSubGroup_TotalTested, parse("-")
destring StudentSubGroup_TotalTested1, replace
destring StudentSubGroup_TotalTested2, replace
foreach count of varlist *_count {
local percent = subinstr("`count'","count","percent",.)
if "`count'" != "Lev5_count"{
	split `percent', parse("-")
	destring `percent'1, replace force
	destring `percent'2, replace force
	replace `count' = string(round(`percent'1 * StudentSubGroup_TotalTested1)) if `percent'1 != . & `percent'2 == . & round(`percent'1 * StudentSubGroup_TotalTested1) == round(`percent'1 * StudentSubGroup_TotalTested2)
	replace `count' = string(round(`percent'1 * StudentSubGroup_TotalTested1)) + "-" + string(round(`percent'1*StudentSubGroup_TotalTested2)) if `percent'1 != . & `percent'2 == . & round(`percent'1 * StudentSubGroup_TotalTested1) != round(`percent'1 * StudentSubGroup_TotalTested2)
	replace `count' = string(round(`percent'1 * StudentSubGroup_TotalTested1)) if `percent'1 != . & `percent'2 != . & round(`percent'1 * StudentSubGroup_TotalTested1) == round(`percent'2 * StudentSubGroup_TotalTested2)
	replace `count' = string(round(`percent'1 * StudentSubGroup_TotalTested1)) + "-" + string(round(`percent'2*StudentSubGroup_TotalTested2)) if `percent'1 != . & `percent'2 != . & round(`percent'1 * StudentSubGroup_TotalTested1) != round(`percent'2 * StudentSubGroup_TotalTested2)
	drop `percent'1 `percent'2
	replace `count' = "--" if inlist(`count', ".", "")
	}
}

//Assessment Info
if `year' <= 2017 & `year' >= 2015 replace AssmtName = "NECAP" if Subject == "sci"
if `year' >= 2018 replace AssmtName = "NH SAS"
replace AssmtName = "Smarter Balanced Assessment" if Subject != "sci" & `year' < 2018 & `year' >= 2015

//Flags
if `year' == 2015 {
	replace Flag_AssmtNameChange = "Y" if Subject != "sci"
	replace Flag_CutScoreChange_ELA = "Y"
	replace Flag_CutScoreChange_math = "Y"
	replace Flag_CutScoreChange_soc = "Not applicable"
	
}
if `year' == 2018 {
	replace Flag_AssmtNameChange = "Y"
	replace Flag_CutScoreChange_math = "Y"
	replace Flag_CutScoreChange_ELA = "Y"
	replace Flag_CutScoreChange_sci = "Y"
	replace Flag_CutScoreChange_soc = "Not applicable"
}

if !inlist(`year', 2015, 2018) {
	replace Flag_AssmtNameChange = "N"
	replace Flag_CutScoreChange_math = "N"
	replace Flag_CutScoreChange_ELA = "N"
	replace Flag_CutScoreChange_sci = "N"
	replace Flag_CutScoreChange_soc = "Not applicable"
}

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

duplicates drop 
save "${Output}/NH_AssmtData_`year'", replace
export delimited "${Output}/NH_AssmtData_`year'", replace

clear
}





