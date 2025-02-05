clear
set more off
global Original "/Users/miramehta/Documents/AL State Testing Data/Original Data Files"
global NCES_District "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES_School "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global Output "/Users/miramehta/Documents/AL State Testing Data/Output"
set trace off

//Unhide code below on first run to convert to DTA format
/*
import delimited "$Original/AL_OriginalData_2024_ela.csv", clear
save "$Original/AL_OriginalData_2024_ela.dta", replace
import delimited "$Original/AL_OriginalData_2024_mat.csv", clear
save "$Original/AL_OriginalData_2024_mat.dta", replace
import delimited "$Original/AL_OriginalData_2024_sci.csv", clear
save "$Original/AL_OriginalData_2024_sci.dta", replace

append using "$Original/AL_OriginalData_2024_ela.dta" "$Original/AL_OriginalData_2024_mat.dta"

save "$Original/AL_OriginalData_2024.dta", replace

foreach Subject in ela math sci {
	foreach lev in State County City Charter{
		import excel "${Original}/AL_OriginalData`Subject'_2024", firstrow cellrange(A5) sheet("`lev'") case(preserve) clear
		tempfile temp`Subject'`lev'
		save "temp`Subject'`lev'", replace
		clear
	}
	use "temp`Subject'State"
	append using "temp`Subject'County" "temp`Subject'City" "temp`Subject'Charter"
	save "${Original}/AL_OriginalData`Subject'_2024_codes", replace
}

use "${Original}/AL_OriginalDataela_2024_codes", clear
append using "${Original}/AL_OriginalDatamath_2024_codes" "${Original}/AL_OriginalDatasci_2024_codes"
rename SystemCode StateAssignedDistID
rename System DistName
rename SchoolCode StateAssignedSchID
rename School SchName
keep StateAssignedDistID DistName StateAssignedSchID SchName
duplicates drop
duplicates tag SchName DistName, gen(tag)
replace SchName = "All Schools" if tag == 1 & StateAssignedSchID == "0000"
drop tag
save "${Original}/AL_OriginalData_2024_codes", replace
clear
*/

use "${Original}/AL_OriginalData_2024", clear

//Dropping SubGroups within SubGroups (i.e Gender = Male, Ethnicity = Hispanic , SubPopulation = Economically Disadvantaged)
gen NotAll = 0
replace NotAll = NotAll + 1 if strpos(gender, "All") !=0
replace NotAll = NotAll + 1 if strpos(race, "All") !=0
replace NotAll = NotAll + 1 if strpos(ethnicity, "All") !=0
replace NotAll = NotAll + 1 if strpos(subpopulation, "All") !=0
keep if NotAll >=3
gen StudentSubGroup = ""
replace StudentSubGroup = gender if strpos(gender, "All") ==0
replace StudentSubGroup = race if strpos(race, "All") ==0
replace StudentSubGroup = ethnicity if strpos(ethnicity, "All") ==0
replace StudentSubGroup = subpopulation if strpos(subpopulation, "All") ==0
replace StudentSubGroup = "All Students" if strpos(gender, "All") !=0 & strpos(race, "All") !=0 & strpos(ethnicity, "All") !=0 & strpos(subpopulation, "All") !=0
drop race gender ethnicity subpopulation

//Fixing StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "English Learner" if strpos(StudentSubGroup, "English") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two or more") !=0
replace StudentSubGroup = "SWD" if strpos(StudentSubGroup, "Students with Disabilities") != 0
replace StudentSubGroup = "Non-SWD" if strpos(StudentSubGroup, "General Education Students") != 0
replace StudentSubGroup = "Military" if strpos(StudentSubGroup, "Military Family") != 0
replace StudentSubGroup = "Foster Care" if strpos(StudentSubGroup, "Foster") != 0
replace StudentSubGroup = "Not Hispanic or Latino" if StudentSubGroup == "Other Ethnicity"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Economically Disadvantaged"
drop if StudentSubGroup ==  "Race Not Specified"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino" | StudentSubGroup == "Unknown"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"

//Standardizing other variable names
gen SchYear = "2023-24"
rename system DistName
rename school SchName
rename grade GradeLevel
rename subject Subject
rename proficient ProficientOrAbove_count
rename proficientrate ProficientOrAbove_percent
rename participationrate ParticipationRate
forvalues n = 1/4{
	rename level`n' Lev`n'_count 
}
rename v19 Lev1_percent
rename v20 Lev2_percent
rename v21 Lev3_percent
rename v22 Lev4_percent

duplicates tag DistName SchName GradeLevel Subject StudentGroup StudentSubGroup, gen(tag)
sort tag DistName SchName GradeLevel Subject StudentGroup StudentSubGroup
replace SchName = "All Schools" if tag == 1 & DistName == DistName[_n-1] & GradeLevel == GradeLevel[_n-1] & Subject == Subject[_n-1] & StudentSubGroup == StudentSubGroup[_n-1]
drop tag

merge m:1 DistName SchName using "${Original}/AL_OriginalData_2024_codes"
drop if _merge == 2
drop _merge

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if StateAssignedDistID == "000" & StateAssignedSchID == "0000"
replace DataLevel = "District" if StateAssignedDistID != "000" & StateAssignedSchID == "0000"
replace DataLevel = "School" if StateAssignedDistID != "000" & StateAssignedSchID != "0000"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
order DataLevel
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

//Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

//GradeLevel
replace GradeLevel = subinstr(GradeLevel,"Grade ","G",.)
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//Derive Missing StudentSubGroup Counts where Possible
	foreach n in 1 2 3 4 {
	destring Lev`n'_count, gen(nLev`n'_count) i(*-)
	}
	destring enrolled tested, replace i(*~)
	replace tested = nLev1_count + nLev2_count + nLev3_count + nLev4_count if tested ==.
	gen StudentSubGroup_TotalTested = tested

//Deriving StudentSubGroup_TotalTested when we have at least one Level Percent & Level Count
tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
if "`var'" == "Lev5_percent" continue
di "`var'"
local count = subinstr("`percent'", "percent", "count",.)
replace StudentSubGroup_TotalTested = string(round(real(`count')/((real(`percent'))/100))) if regexm(`percent', "[0-9]") !=0 & regexm(`count', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") == 0
}

//StudentGroup_TotalTested and StudentSubGroup_TotalTested	
replace DistName = stritrim(DistName)
replace DistName = strtrim(DistName)
replace SchName = stritrim(SchName)
replace SchName = strtrim(SchName)
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
gen StudentGroup_TotalTested = AllStudents_Tested
drop AllStudents_Tested

//Deriving StudentSubGroup_TotalTested from Counterparts
	gen max = real(StudentGroup_TotalTested)
	replace max = 0 if max == .
	
	bysort uniquegrp: egen RaceEth = total(real(StudentSubGroup_TotalTested)) if StudentGroup == "RaceEth"
	bysort uniquegrp: egen Gender = total(real(StudentSubGroup_TotalTested)) if StudentGroup == "Gender"
	bysort uniquegrp: egen Disability = total(real(StudentSubGroup_TotalTested)) if StudentGroup == "Disability Status"
	bysort uniquegrp: egen Econ = total(real(StudentSubGroup_TotalTested)) if StudentGroup == "Economic Status"
	bysort uniquegrp: egen ELStatus = total(real(StudentSubGroup_TotalTested)) if StudentGroup == "EL Status"
	bysort uniquegrp: egen Homeless = total(real(StudentSubGroup_TotalTested)) if StudentGroup == "Homeless Enrolled Status"
	bysort uniquegrp: egen Foster = total(real(StudentSubGroup_TotalTested)) if StudentGroup == "Foster Care Status"
	bysort uniquegrp: egen Military = total(real(StudentSubGroup_TotalTested)) if StudentGroup == "Military Connected Status"

	gen x = 1 if missing(real(StudentSubGroup_TotalTested))
	bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject StudentGroup: egen flag = total(x)

	replace StudentSubGroup_TotalTested = string(max - RaceEth) if StudentGroup == "RaceEth" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
	replace StudentSubGroup_TotalTested = string(max - Gender) if StudentGroup == "Gender" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		replace StudentSubGroup_TotalTested = string(max - Disability) if StudentGroup == "Disability Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		replace StudentSubGroup_TotalTested = string(max - Econ) if StudentGroup == "Economic Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		replace StudentSubGroup_TotalTested = string(max - ELStatus) if StudentGroup == "EL Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		replace StudentSubGroup_TotalTested = string(max - Homeless) if StudentGroup == "Homeless Enrolled Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		replace StudentSubGroup_TotalTested = string(max - Foster) if StudentGroup == "Foster Care Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		replace StudentSubGroup_TotalTested = string(max - Military) if StudentGroup == "Military Connected Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		drop uniquegrp x flag RaceEth Gender Disability Econ ELStatus Homeless Foster Military
	

//ParticipationRate
destring ParticipationRate, gen(nParticipationRate) i(*~)
replace ParticipationRate = string(nParticipationRate/100, "%9.4f")
replace ParticipationRate = "*" if ParticipationRate == "."	

//ProficientOrAbove_percent and Level percents

destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*~)

foreach n in 1 2 3 4 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*~)
}
foreach n in 1 2 3 4 {
	replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.4f")
	replace Lev`n'_percent = "*" if Lev`n'_percent == "." 
}

replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100, "%9.4f")
replace ProficientOrAbove_percent = string((nLev3_percent + nLev4_percent)/100, "%9.4f") if missing(nProficientOrAbove_percent)
replace ProficientOrAbove_percent = "0.000" if (nLev3_percent + nLev4_percent)==0 & !missing(nLev3_percent) & !missing(nLev4_percent)
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

//Merging with NCES Data//
replace StateAssignedSchID = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel ==3

tempfile temp1
save "`temp1'", replace

//District
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'", replace
clear
use "${NCES_District}/NCES_2022_District"
keep if state_fips_id == 1
gen StateAssignedDistID = subinstr(state_leaid,"AL-","",.)
drop year
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge ==1
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel==3
tempfile tempschool
save "`tempschool'", replace
use "${NCES_School}/NCES_2022_School"
keep if state_fips_id == 1
gen StateAssignedDistID = subinstr(state_leaid,"AL-","",.)
gen StateAssignedSchID = StateAssignedDistID + "-" + seasch if strpos(seasch,"-") ==0
replace StateAssignedSchID = seasch if strpos(seasch,"-") !=0
drop if StateAssignedSchID=="-"
replace SchVirtual = 0 if seasch == "026-0063" | seasch == "800-0015"
decode district_agency_type, gen(temp)
drop district_agency_type
rename temp district_agency_type
keep state_location state_fips district_agency_type school_type ncesdistrictid StateAssignedDistID ncesschoolid StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual county_name county_code
merge 1:m StateAssignedSchID using "`tempschool'"
drop if _merge ==1
save "`tempschool'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempschool'"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename ncesdistrictid NCESDistrictID
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
rename school_type SchType
replace StateFips = 1
replace StateAbbrev = "AL"

//Generating additional variables
gen State = "Alabama"
gen AvgScaleScore = "--"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen ProficiencyCriteria = "Levels 3-4"
gen Lev5_percent = ""
gen Lev5_count = ""
gen AssmtType = "Regular"
gen AssmtName = "ACAP"

//Level counts for 0 StudentSubGroup_TotalTested
foreach n in 1 2 3 4 {
replace Lev`n'_count = "0" if StudentSubGroup_TotalTested == "0"
}

//Levels for weird suppression that can be calculated
destring ProficientOrAbove_count, gen(nProficientOrAbove_count) i(*-)
replace Lev4_count = string(nProficientOrAbove_count - nLev3_count) if missing(nLev4_count) & !missing(nProficientOrAbove_count) & !missing(nLev3_count)
replace Lev3_count = string(nProficientOrAbove_count - nLev4_count) if missing(nLev3_count) & !missing(nProficientOrAbove_count) & !missing(nLev4_count)

replace Lev1_count = string((real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - nLev2_count)) if missing(nLev1_count) & !missing(nLev2_count) & !missing(real(ProficientOrAbove_count)) & !missing(real(StudentSubGroup_TotalTested))
replace Lev1_count = "*" if real(Lev1_count) < 0
replace Lev2_count = string((real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - nLev1_count)) if missing(nLev2_count) & !missing(nLev1_count) & !missing(real(ProficientOrAbove_count)) & !missing(real(StudentSubGroup_TotalTested))
replace Lev2_count = "*" if real(Lev2_count) < 0
replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count)) if missing(nLev3_count) & !missing(nLev4_count) & !missing(real(ProficientOrAbove_count))
replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count)) if missing(nLev4_count) & !missing(nLev3_count) & !missing(real(ProficientOrAbove_count))

forvalues n = 1/4{
	replace Lev`n'_count = string(round(real(StudentSubGroup_TotalTested) * real(Lev`n'_percent))) if missing(real(Lev`n'_count)) & !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev`n'_percent))
	replace Lev`n'_percent = string(real(Lev`n'_count)/real(StudentSubGroup_TotalTested), "%9.4f") if missing(real(Lev`n'_percent)) & !missing(real(Lev`n'_count)) & !missing(real(StudentSubGroup_TotalTested))
}

replace ProficientOrAbove_count = string(tested - nLev1_count - nLev2_count) if missing(nProficientOrAbove_count)
drop tested
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if missing(real(ProficientOrAbove_count)) & !missing(real(Lev3_count)) & !missing(real(Lev4_count))

replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if missing(real(ProficientOrAbove_count)) & !missing(real(Lev3_count)) & !missing(real(Lev4_count))

replace ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent), "%9.4f") if missing(real(ProficientOrAbove_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev4_percent))
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent), "%9.4f") if missing(real(ProficientOrAbove_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent))
replace ProficientOrAbove_percent = "1" if ProficientOrAbove_percent == "1.0001"

replace Lev1_percent = string((1 - real(ProficientOrAbove_percent) - (nLev2_percent/100)), "%9.4f") if missing(nLev1_percent) & !missing(nLev2_percent) & !missing(real(ProficientOrAbove_percent))
replace Lev2_percent = string((1 - real(ProficientOrAbove_percent) - (nLev1_percent/100)), "%9.4f") if missing(nLev2_percent) & !missing(nLev1_percent) & !missing(real(ProficientOrAbove_percent))
replace Lev1_percent = string((1 - real(ProficientOrAbove_percent) - (nLev2_percent/100)), "%9.4f") if missing(nLev1_percent) & !missing(nLev2_percent) & !missing(real(ProficientOrAbove_percent))
replace Lev1_percent = "*" if real(Lev1_percent) < 0
replace Lev2_percent = string(((1 - real(ProficientOrAbove_percent) - (nLev1_percent)/100)), "%9.4f") if missing(nLev2_percent) & !missing(nLev1_percent) & !missing(real(ProficientOrAbove_percent))
replace Lev2_percent = "*" if real(Lev2_percent) < 0
replace Lev3_percent = string((real(ProficientOrAbove_percent) - real(Lev4_percent)), "%9.4f") if missing(nLev3_percent) & !missing(nLev4_percent) & !missing(real(ProficientOrAbove_percent))
replace Lev4_percent = string((real(ProficientOrAbove_percent) - real(Lev3_percent)), "%9.4f") if missing(nLev4_percent) & !missing(nLev3_percent) & !missing(real(ProficientOrAbove_percent))


forvalues n = 1/4{
	replace Lev`n'_count = string(round(real(StudentSubGroup_TotalTested) * real(Lev`n'_percent))) if missing(real(Lev`n'_count)) & !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev`n'_percent))
}
replace ProficientOrAbove_count = string(round(real(StudentSubGroup_TotalTested) * real(ProficientOrAbove_percent))) if missing(real(ProficientOrAbove_count)) & !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_percent))

//Response to Reviews
drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"
drop if Lev1_percent == "0" & Lev2_percent == "0" & Lev3_percent == "0" & Lev4_percent == "0"

//Deriving StudentSubGroup_TotalTested where possible and inputting new StudentGroup values
replace StudentSubGroup_TotalTested = string(real(Lev1_count) + real(Lev2_count) + real(Lev3_count) + real(Lev4_count)) if regexm(StudentSubGroup_TotalTested, "[0-9]") == 0 & regexm(Lev1_count, "[0-9]") !=0 & regexm(Lev2_count, "[0-9]") !=0 & regexm(Lev3_count, "[0-9]") !=0 & regexm(Lev4_count, "[0-9]") !=0

//New Schools 2024
replace NCESSchoolID = "010054002665" if SchName == "EXCEL Academy"
replace NCESDistrictID = "0100540" if SchName == "EXCEL Academy"
replace DistType = "Regular local school district" if SchName == "EXCEL Academy"
replace DistCharter = "No" if SchName == "EXCEL Academy"
replace DistLocale = "Rural, fringe" if SchName == "EXCEL Academy"
replace CountyName = "Covington County" if SchName == "EXCEL Academy"
replace CountyCode = "1039" if SchName == "EXCEL Academy"
replace SchType = 1 if SchName == "EXCEL Academy"
replace SchLevel = 4 if SchName == "EXCEL Academy"
replace SchVirtual = 1 if SchName == "EXCEL Academy"
replace NCESSchoolID = "010177002668" if SchName == "Rehobeth Primary School"
replace NCESDistrictID = "0101770" if SchName == "Rehobeth Primary School"
replace DistType = "Regular local school district" if SchName == "Rehobeth Primary School"
replace DistCharter = "No" if SchName == "Rehobeth Primary School"
replace DistLocale = "Rural, fringe" if SchName == "Rehobeth Primary School"
replace CountyName = "Houston County" if SchName == "Rehobeth Primary School"
replace CountyCode = "1069" if SchName == "Rehobeth Primary School"
replace SchType = 1 if SchName == "Rehobeth Primary School"
replace SchLevel = 1 if SchName == "Rehobeth Primary School"
replace SchVirtual = 0 if SchName == "Rehobeth Primary School"

replace SchVirtual = 0 if NCESSchoolID == "010358302559"
replace SchVirtual = 0 if NCESSchoolID == "010258002556"
replace SchVirtual = 0 if NCESSchoolID == "010000802522"

//Final Formatting (Suppression)
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
gen flag = 1 if StudentSubGroup_TotalTested != "*" & inlist(Lev1_percent, "*", "0.000") & inlist(Lev2_percent, "*", "0.000") & inlist(Lev3_percent, "*", "0.000") & inlist(Lev4_percent, "*" "0.000")
forvalues n = 1/4{
	replace Lev`n'_percent = "*" if flag == 1
}
replace ProficientOrAbove_percent = "*" if flag == 1
drop flag

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/AL_AssmtData_2024", replace
export delimited "${Output}/AL_AssmtData_2024", replace
