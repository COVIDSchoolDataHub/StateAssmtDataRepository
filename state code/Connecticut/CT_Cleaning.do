clear
set more off
set trace off
cap log close
cd "/Volumes/T7/State Test Project/Connecticut"
local Original "/Volumes/T7/State Test Project/Connecticut/Original Data Files"
local Output "/Volumes/T7/State Test Project/Connecticut/Output"
local NCES_School "/Volumes/T7/State Test Project/NCES/School"
local NCES_District "/Volumes/T7/State Test Project/NCES/District"
log using variablescheck.log, replace
//Standardizing Varnames (and variables if necessary) before appending
forvalues year = 2015/2023 {
	local prevyear =`=`year'-1'
	if `year' == 2020 | `year' == 2021 continue
	tempfile temp_`year'
	save "`temp_`year''", emptyok
	foreach dl in State Dist Sch {
		foreach sg in All EL FRM2 Gen RE {
			foreach subject in ela_mat sci {
				if (`year' == 2015 | `year' == 2016 | `year' == 2017 | `year' == 2018) & "`subject'" == "sci" continue
				di "~~~~~~~~"
				di "`year'"
				di "`dl'"
				di "`sg'"
				di "`subject'"
				import delimited "`Original'/`dl'_`sg'_CT_OriginalData_`year'_`subject'.csv", clear
				if "`dl'" == "State" gen DataLevel = "State" 
				if "`dl'" == "Dist" gen DataLevel = "District" 
				if "`dl'" == "Sch" gen DataLevel = "School" 
				
				if "`subject'" == "sci" & "`dl'" != "Sch" {
					forvalues n = 22(-1)3 {
					local new = `n'+1
					capture rename v`n' v`new'
					}
					gen v3 = "sci"
				}
				if "`subject'" == "sci" & "`dl'" == "Sch" {
					forvalues n = 22(-1)5 {
					local new = `n'+1
					capture rename v`n' v`new'
					}
					gen v5 = "sci"
					
				}
				
				if "`dl'" == "State" & "`sg'" == "All" {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					drop v4
					gen StudentSubGroup = "All Students"
					rename v5 StudentSubGroup_TotalTested
					rename v6 ParticipationRate
					drop v7
					rename v8 Lev1_count
					rename v9 Lev1_percent
					rename v10 Lev2_count
					rename v11 Lev2_percent
					rename v12 Lev3_count
					rename v13 Lev3_percent
					rename v14 Lev4_count
					rename v15 Lev4_percent
					rename v16 ProficientOrAbove_count
					rename v17 ProficientOrAbove_percent
					rename v18 AvgScaleScore
					
				}
				if "`dl'" == "State" & "`sg'" == "EL" {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					replace v4 = "English Learner" if v4 == "Y"
					replace v4 = "English Proficient" if v4 == "N"
					rename v4 StudentSubGroup
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
					
				}
				if "`dl'" == "State" & "`sg'" == "FRM2"  {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					replace v4 = "Economically Disadvantaged" if v4 == "Y"
					replace v4 = "Not Economically Disadvantaged" if v4 == "N"
					rename v4 StudentSubGroup
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
				}
				if "`dl'" == "State" & "`sg'" == "Gen" {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					rename v4 StudentSubGroup
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
				}
				if "`dl'" == "State" & "`sg'" == "RE" {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					rename v4 StudentSubGroup
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
				}
				if "`dl'" == "State" {
					gen SchName = "All Schools"
					gen StateAssignedSchID = ""
					gen StateAssignedDistID = ""
				}
				if "`dl'" == "Dist" & "`sg'" == "All" & {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					gen StudentSubGroup = "All Students"
					rename v4 Subject
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
				}
				if "`dl'" == "Dist" & "`sg'" == "EL" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					rename v4 Subject
					replace v5 = "English Learner" if v5 == "Y"
					replace v5 = "English Proficient" if v5 == "N"
					rename v5 StudentSubGroup
					drop v6
					rename v7 StudentSubGroup_TotalTested
					rename v8 ParticipationRate
					drop v9
					rename v10 Lev1_count
					rename v11 Lev1_percent
					rename v12 Lev2_count
					rename v13 Lev2_percent
					rename v14 Lev3_count
					rename v15 Lev3_percent
					rename v16 Lev4_count
					rename v17 Lev4_percent
					rename v18 ProficientOrAbove_count
					rename v19 ProficientOrAbove_percent
					rename v20 AvgScaleScore
					
					
				}
				
				if "`dl'" == "Dist" & "`sg'" == "FRM2" & {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					rename v4 Subject
					replace v5 = "Economically Disadvantaged" if v5 == "Y"
					replace v5 = "Not Economically Disadvantaged" if v5 == "N"
					rename v5 StudentSubGroup
					drop v6
					rename v7 StudentSubGroup_TotalTested
					rename v8 ParticipationRate
					drop v9
					rename v10 Lev1_count
					rename v11 Lev1_percent
					rename v12 Lev2_count
					rename v13 Lev2_percent
					rename v14 Lev3_count
					rename v15 Lev3_percent
					rename v16 Lev4_count
					rename v17 Lev4_percent
					rename v18 ProficientOrAbove_count
					rename v19 ProficientOrAbove_percent
					rename v20 AvgScaleScore
				}
				if "`dl'" == "Dist" & "`sg'" == "Gen" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					rename v4 Subject
					rename v5 StudentSubGroup
					drop v6
					rename v7 StudentSubGroup_TotalTested
					rename v8 ParticipationRate
					drop v9
					rename v10 Lev1_count
					rename v11 Lev1_percent
					rename v12 Lev2_count
					rename v13 Lev2_percent
					rename v14 Lev3_count
					rename v15 Lev3_percent
					rename v16 Lev4_count
					rename v17 Lev4_percent
					rename v18 ProficientOrAbove_count
					rename v19 ProficientOrAbove_percent
					rename v20 AvgScaleScore
				}
				if "`dl'" == "Dist" & "`sg'" == "RE" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					rename v4 Subject
					rename v5 StudentSubGroup
					drop v6
					rename v7 StudentSubGroup_TotalTested
					rename v8 ParticipationRate
					drop v9
					rename v10 Lev1_count
					rename v11 Lev1_percent
					rename v12 Lev2_count
					rename v13 Lev2_percent
					rename v14 Lev3_count
					rename v15 Lev3_percent
					rename v16 Lev4_count
					rename v17 Lev4_percent
					rename v18 ProficientOrAbove_count
					rename v19 ProficientOrAbove_percent
					rename v20 AvgScaleScore
				}
				if "`dl'" == "Dist" {
					gen SchName = "All Schools"
					gen StateAssignedSchID = ""
				}
				if "`dl'" == "Sch" & "`sg'" == "All" {
					gen StudentSubGroup = "All Students"
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					drop v7 
					rename v8 StudentSubGroup_TotalTested
					rename v9 ParticipationRate
					drop v10
					rename v11 Lev1_count
					rename v12 Lev1_percent
					rename v13 Lev2_count
					rename v14 Lev2_percent
					rename v15 Lev3_count
					rename v16 Lev3_percent
					rename v17 Lev4_count
					rename v18 Lev4_percent
					rename v19 ProficientOrAbove_count
					rename v20 ProficientOrAbove_percent
					rename v21 AvgScaleScore
				}
				if "`dl'" == "Sch" & "`sg'" == "EL" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					replace v7 = "English Learner" if v7 == "Y"
					replace v7 = "English Proficient" if v7 == "N"
					rename v7 StudentSubGroup
					drop v8
					rename v9 StudentSubGroup_TotalTested
					rename v10 ParticipationRate
					drop v11
					rename v12 Lev1_count
					rename v13 Lev1_percent
					rename v14 Lev2_count
					rename v15 Lev2_percent
					rename v16 Lev3_count
					rename v17 Lev3_percent
					rename v18 Lev4_count
					rename v19 Lev4_percent
					rename v20 ProficientOrAbove_count
					rename v21 ProficientOrAbove_percent
					rename v22 AvgScaleScore
				}
				if "`dl'" == "Sch" & "`sg'" == "FRM2" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					replace v7 = "Economically Disadvantaged" if v7 == "Y"
					replace v7 = "Not Economically Disadvantaged" if v7 == "N"
					rename v7 StudentSubGroup
					drop v8
					rename v9 StudentSubGroup_TotalTested
					rename v10 ParticipationRate
					drop v11
					rename v12 Lev1_count
					rename v13 Lev1_percent
					rename v14 Lev2_count
					rename v15 Lev2_percent
					rename v16 Lev3_count
					rename v17 Lev3_percent
					rename v18 Lev4_count
					rename v19 Lev4_percent
					rename v20 ProficientOrAbove_count
					rename v21 ProficientOrAbove_percent
					rename v22 AvgScaleScore
				}
				if "`dl'" == "Sch" & "`sg'" == "Gen" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					rename v7 StudentSubGroup
					drop v8
					rename v9 StudentSubGroup_TotalTested
					rename v10 ParticipationRate
					drop v11
					rename v12 Lev1_count
					rename v13 Lev1_percent
					rename v14 Lev2_count
					rename v15 Lev2_percent
					rename v16 Lev3_count
					rename v17 Lev3_percent
					rename v18 Lev4_count
					rename v19 Lev4_percent
					rename v20 ProficientOrAbove_count
					rename v21 ProficientOrAbove_percent
					rename v22 AvgScaleScore
				}
				if "`dl'" == "Sch" & "`sg'" == "RE" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					rename v7 StudentSubGroup
					drop v8
					rename v9 StudentSubGroup_TotalTested
					rename v10 ParticipationRate
					drop v11
					rename v12 Lev1_count
					rename v13 Lev1_percent
					rename v14 Lev2_count
					rename v15 Lev2_percent
					rename v16 Lev3_count
					rename v17 Lev3_percent
					rename v18 Lev4_count
					rename v19 Lev4_percent
					rename v20 ProficientOrAbove_count
					rename v21 ProficientOrAbove_percent
					rename v22 AvgScaleScore
				}
				if "`subject'" == "sci" & "`dl'" != "State" {
					replace GradeLevel = Subject
					drop Subject
					gen Subject = "sci"
					
				}
				drop in 1/4
				save "`Original'/`dl'_`sg'_CT_OriginalData_`year'_`subject'.dta", replace
				append using "`temp_`year''"
				save "`temp_`year''", replace
				*save "/Volumes/T7/State Test Project/Connecticut/Testing/`year'", replace
				clear
			}
		}
	}
use "`temp_`year''"


//StateAssignedDistID and StateAssignedSchID
replace StateAssignedDistID = subinstr(StateAssignedDistID, "=","",.)
replace StateAssignedSchID = subinstr(StateAssignedSchID,"=","",.)
replace StateAssignedDistID = subinstr(StateAssignedDistID,`"""',"",.)
replace StateAssignedSchID = subinstr(StateAssignedSchID,`"""',"",.)


//StudentSubGroup
replace StudentSubGroup = "Hispanic or Latino" if strpos(StudentSubGroup, "Hispanic") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two or More") !=0
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0


//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "Ethnicity" if StudentSubGroup == "Hispanic or Latino"

//StudentGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*N/A)
sort StudentGroup
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel !=3
replace DistName = "All Districts" if DataLevel ==1

//Subject
replace Subject = lower(Subject)

//GradeLevel
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//Converting ParticipationRate, ProficientOrAbove_percent, and Level percents to decimal and general cleaning
destring ParticipationRate, gen(nParticipationRate) i(*N/A)
replace ParticipationRate = string(nParticipationRate/100, "%9.3g") if ParticipationRate != "*"
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*N/A)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100, "%9.3g") if ProficientOrAbove_percent != "*" & ProficientOrAbove_percent != "N/A"
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "N/A"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "N/A"
foreach n in 1 2 3 4 {
	replace Lev`n'_percent = "--" if Lev`n'_percent == "N/A"
	replace Lev`n'_count = "--" if Lev`n'_count == "N/A"
	destring Lev`n'_count, gen(nLev`n'_count) i(*-)
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*-)
	replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.3g") if Lev`n'_percent != "*" & Lev`n'_percent != "--"
}

//Sometimes, ProficientOrAbove_count and ProficientOrAbove_percent can be calculated even if they're listed as suppressed for some reason. Correcting below. 
replace ProficientOrAbove_count = string(nLev3_count + nLev4_count, "%9.3g") if ProficientOrAbove_count == "*" & Lev3_count != "*" & Lev4_count != "*" & Lev3_count != "--" & Lev4_count != "--"
replace ProficientOrAbove_percent = string((nLev3_percent/100) + (nLev4_percent/100), "%9.3g") if ProficientOrAbove_percent == "*" & Lev3_percent != "*" & Lev4_percent != "*" & Lev3_percent != "--" & Lev4_percent != "--"

//Year
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)

//Merging with NCES Data//
gen StateAssignedDistID1 = substr(StateAssignedDistID,1,3)
gen StateAssignedDistID2 = StateAssignedDistID
gen StateAssignedSchID1 = StateAssignedDistID1 + "-" + substr(StateAssignedSchID,4,2)
gen StateAssignedSchID2 = StateAssignedDistID + "-" + StateAssignedSchID
tempfile temp1
save "`temp1'", replace

//District
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'", replace
clear
if `year' < 2023 {
use "`NCES_District'/NCES_`prevyear'_District"
}
else if `year'==2023{
use "`NCES_District'/NCES_2021_District"
}
keep if state_name == 9 | state_location == "CT"
if `year' <2019 {
gen StateAssignedDistID1 = subinstr(state_leaid,"CT-","",.)
merge 1:m StateAssignedDistID1 using "`tempdist'"
}
if `year' >= 2019 {
	gen StateAssignedDistID2 = subinstr(state_leaid,"CT-","",.)
	merge 1:m StateAssignedDistID2 using "`tempdist'"
}
drop if _merge ==1
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel==3
tempfile tempschool
save "`tempschool'", replace
if `year' <2023 {
use "`NCES_School'/NCES_`prevyear'_School"
}
else if `year' == 2023 {
use "`NCES_School'/NCES_2021_School"
}
keep if state_name == 9 | state_location == "CT"
gen StateAssignedDistID1 = subinstr(state_leaid,"CT-","",.)
if `year' <2019 {
gen StateAssignedSchID1 = StateAssignedDistID1 + "-" + seasch if strpos(seasch,"-") ==0
replace StateAssignedSchID1 = seasch if strpos(seasch,"-") !=0
drop if StateAssignedSchID1=="-"
merge 1:m StateAssignedSchID1 using "`tempschool'"
drop if _merge ==1
}
if `year' >= 2019 {
	gen StateAssignedSchID2 = seasch 
	merge 1:m StateAssignedSchID2 using "`tempschool'"
	drop if _merge ==1
}
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
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 9
replace StateAbbrev = "CT"

//Fixing Unmerged with Data where possible
replace State_leaid = "0150011" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace SchType = 1 if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace NCESDistrictID = "900450" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace NCESSchoolID = "90045001918" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace seasch = "31" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace DistCharter = "No" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace DistType = 1 if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace SchLevel = 2 if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace SchVirtual = 0 if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace CountyName = "Fairfield County" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace CountyCode = 9001 if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017

replace State_leaid = "CT-244" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace SchType = 4 if SchName == "Mill Academy" & missing(NCESSchoolID)
replace NCESDistrictID = "900070" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace NCESSchoolID = "90007001505" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace seasch = "244-94" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace DistCharter = "No" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace DistType = 4 if SchName == "Mill Academy" & missing(NCESSchoolID)
replace SchLevel = -1 if SchName == "Mill Academy" & missing(NCESSchoolID)
replace SchVirtual = -1 if SchName == "Mill Academy" & missing(NCESSchoolID)
replace CountyName = "New Haven County" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace CountyCode = 9009 if SchName == "Mill Academy" & missing(NCESSchoolID)

replace State_leaid = "CT-1510011" if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace SchType = 1 if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace NCESDistrictID = "904830" if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace NCESSchoolID = "90483001418" if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace seasch = "1510011-1519111" if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace DistCharter = "No" if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace DistType = 1 if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace SchLevel = 4 if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace SchVirtual = 0 if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace CountyName = "New Haven County" if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace CountyCode = 9009 if SchName == "Enlightenment School" & missing(NCESSchoolID)

replace State_leaid = "CT-0430011" if SchName == "Woodland School" & missing(NCESSchoolID)
replace SchType = 2 if SchName == "Woodland School" & missing(NCESSchoolID)
replace NCESDistrictID = "901260" if SchName == "Woodland School" & missing(NCESSchoolID)
replace NCESSchoolID = "90126000205" if SchName == "Woodland School" & missing(NCESSchoolID)
replace seasch = "0430011-0439011" if SchName == "Woodland School" & missing(NCESSchoolID)
replace DistCharter = "No" if SchName == "Woodland School" & missing(NCESSchoolID)
replace DistType = 2 if SchName == "Woodland School" & missing(NCESSchoolID)
replace SchLevel = 4 if SchName == "Woodland School" & missing(NCESSchoolID)
replace SchVirtual = -1 if SchName == "Woodland School" & missing(NCESSchoolID)
replace CountyName = "Hartford County" if SchName == "Woodland School" & missing(NCESSchoolID)
replace CountyCode = 9003 if SchName == "Woodland School" & missing(NCESSchoolID)

replace State_leaid = "CT-2440014" if DistName == "Area Cooperative Educational Services"
replace NCESDistrictID = "0900070" if DistName == "Area Cooperative Educational Services"
replace DistCharter = "No" if DistName == "Area Cooperative Educational Services"
replace DistType = 9 if DistName == "Area Cooperative Educational Services"
replace CountyName = "New Haven County" if DistName == "Area Cooperative Educational Services"
replace CountyCode = 9009 if DistName == "Area Cooperative Educational Services"
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if _merge == 2

//Dropping Unmerged with no data available and unmerged bilingual schools

drop if [_merge==2] & [(Lev1_percent == "*" | Lev1_percent == "--" | Lev1_percent == "0")  & (Lev2_percent == "*" | Lev2_percent == "--" | Lev2_percent == "0") & (Lev3_percent == "*" | Lev3_percent == "--" | Lev3_percent == "0" ) & (Lev4_percent == "*" | Lev4_percent == "--" | Lev4_percent == "0") & (ProficientOrAbove_percent == "*" | ProficientOrAbove_percent == "--" | ProficientOrAbove_percent == "0") & (ProficientOrAbove_count == "*" | ProficientOrAbove_count == "--" | ProficientOrAbove_count == "0")]

drop if (_merge==2) & strpos(SchName, "Bilingual") !=0

//Replacing NCES vars with Missing/not reported when applicable
label def agency_typedf -1 "Missing/not reported", add
replace DistType = -1 if missing(DistType) & DataLevel !=1
replace DistCharter = "Missing/not reported" if missing(DistCharter) & DataLevel !=1
replace SchType =-1 if missing(SchType) & DataLevel ==3
replace SchLevel = -1 if missing(SchLevel) & DataLevel ==3
replace CountyName = "Missing/not reported" if missing(CountyName) & DataLevel !=1
replace CountyCode = 0 if missing(CountyCode) & DataLevel !=1
replace SchVirtual = -1 if missing(SchVirtual) & DataLevel ==3
replace NCESDistrictID = "Missing/not reported" if missing(NCESDistrictID) & DataLevel !=1
replace NCESSchoolID = "Missing/not reported" if missing(NCESSchoolID) & DataLevel ==3
replace State_leaid = "Missing/not reported" if missing(State_leaid) & DataLevel !=1
replace seasch = "Missing/not reported" if missing(seasch) & DataLevel ==3


//Proficiency Criteria
gen ProficiencyCriteria = "Levels 3 and 4"

//AssmtName
gen AssmtName = "Smarter Balanced Assessment"
replace AssmtName = "NGSS Assessment" if Subject == "sci"

//State 
gen State = "Connecticut"

//AssmtType
gen AssmtType = "Regular"

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth = ""

foreach var of varlist Flag* {
	replace `var' = "Y" if `year' == 2015 & "`var'" != "Flag_CutScoreChange_oth" & `var' != "Flag_CutScoreChange_read"
	replace `var' = "N" if "`var'" == "Flag_CutScoreChange_oth" & `year' >= 2019
	replace `var' = "Y" if `year' == 2022 & "`var'" != "Flag_AssmtNameChange" & "`var'" != "Flag_CutScoreChange_read"
}

//Missing/empty Variables
gen Lev5_count = ""
gen Lev5_percent= ""

//Final Cleaning
recast str80 SchName
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/CT_AssmtData_`year'", replace
export delimited "`Output'/CT_AssmtData_`year'", replace
clear



clear	
}
log close
do CT_Cleaning_2021

