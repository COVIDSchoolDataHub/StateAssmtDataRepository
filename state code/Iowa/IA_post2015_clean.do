clear
set more off

global raw "/Users/minnamgung/Desktop/SADR/Iowa/Input"
global output "/Users/minnamgung/Desktop/SADR/Iowa/Output"
global int "/Users/minnamgung/Desktop/SADR/Iowa/Intermediate"
global dr "/Users/minnamgung/Desktop/SADR/Iowa/Input/Data Request"

global nces "/Users/minnamgung/Desktop/SADR/NCES District and School Demographics-2"
global iowa "/Users/minnamgung/Desktop/SADR/Iowa/NCES"

foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 {
local prevyear =`=`year'-1'
local Year = substr("`prevyear'",-2,2) + substr("`year'",-2,2)

import excel "/Users/minnamgung/Desktop/SADR/Iowa/Input/Data Request/IA_ProficiencyData_`Year'.xlsx", sheet("School") firstrow allstring clear

save "${output}/IA_AssmtData_`year'_NEW.dta", replace

import excel "/Users/minnamgung/Desktop/SADR/Iowa/Input/Data Request/IA_ProficiencyData_`Year'.xlsx", sheet("District") firstrow allstring clear

append using "${output}/IA_AssmtData_`year'_NEW.dta"

save "${output}/IA_AssmtData_`year'_NEW.dta", replace

import excel "/Users/minnamgung/Desktop/SADR/Iowa/Input/Data Request/IA_ProficiencyData_`Year'.xlsx", sheet("State") firstrow allstring clear

append using "${output}/IA_AssmtData_`year'_NEW.dta"

save "${output}/IA_AssmtData_`year'_NEW.dta", replace

}

foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 {
	
	local prevyear =`=`year'-1'
	local Year = "`prevyear'" + "-" + substr("`year'",-2,2)
	
	use "${output}/IA_AssmtData_`year'_NEW.dta", clear
	
	////////////////////

	rename district StateAssignedDistID
	rename District_Name DistName 
	rename school StateAssignedSchID
	rename School_Name SchName
	rename Level DataLevel
	rename subject Subject
	rename grade GradeLevel
	rename subgroup StudentSubGroup
	rename All_Tested StudentSubGroup_TotalTested
	rename All_Not_Proficient Lev1_count
	rename All_Prof Lev2_count
	rename All_Advanced Lev3_count
	rename All_Prof_And_Above ProficientOrAbove_count
	rename All_Low_Percent Lev1_percent
	rename All_Prof_Percent Lev2_percent
	rename All_Advanced_Percent Lev3_percent
	rename All_Prof_Above_Percent ProficientOrAbove_percent
	rename All_Tested_Percent ParticipationRate

	keep StateAssignedDistID DistName StateAssignedSchID SchName DataLevel Subject GradeLevel StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev2_count Lev3_count ProficientOrAbove_count Lev1_percent Lev2_percent Lev3_percent ProficientOrAbove_percent ParticipationRate

	foreach x of numlist 3/8 {
		replace GradeLevel="G0`x'" if strpos(GradeLevel, "`x'")>0
	}

	replace GradeLevel="G38" if GradeLevel==""

	replace Subject="ela" if Subject=="ELA"
	replace Subject="math" if Subject=="Math"
	replace Subject="sci" if Subject=="Science"

	replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black"
	replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="Native American"
	replace StudentSubGroup="English Learner" if StudentSubGroup=="EL"
	replace StudentSubGroup="English Proficient" if StudentSubGroup=="Not EL"
	replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="Econ Disad"
	replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="Not Econ Disad"
	replace StudentSubGroup="Two or More" if StudentSubGroup=="Multi-Racial"
	replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"
	replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Pacific Islander"
	replace StudentSubGroup="Other" if StudentSubGroup=="Non-Binary"

	gen StudentGroup="All Students"
	replace StudentGroup="RaceEth" if inlist(StudentSubGroup, "American Indian or Alaska Native", "Asian", "Black or African American", "Hispanic or Latino", "Native Hawaiian or Pacific Islander", "Two or More", "White")
	replace StudentGroup="Gender" if inlist(StudentSubGroup, "Male", "Female", "Other")
	replace StudentGroup="EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient")
	replace StudentGroup="Economic Status" if inlist(StudentSubGroup, "Not Economically Disadvantaged", "Economically Disadvantaged")

	foreach var of varlist ParticipationRate Lev1_percent Lev2_percent Lev3_percent ProficientOrAbove_percent {
		replace `var'="10000" if `var'=="small N"
		destring `var', replace
		replace `var'=`var'/100
		tostring `var', replace force
		replace `var'="*" if `var'=="100"
	}

	foreach var of varlist StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev2_count Lev3_count ProficientOrAbove_count {
		replace `var'="*" if `var'=="small N"
	}
	
		replace SchName="Odebolt Arthur Battle Creek Ida Grove Elementary-Ida Grove" if SchName=="Odebolt Arthur Battle Creek Ida Grove Elementary School - Ida Grove"
	replace SchName="Odebolt Arthur Battle Creek Ida Grove Elementary-Odebolt" if SchName=="Odebolt Arthur Battle Creek Ida Grove Elementary School - Odebolt"
	// replace school_name="Van Buren County Community School District Douds Center" if SchName=="Van Buren County Community School District Middle & High School"

	replace SchName="All Schools" if DataLevel=="District" | DataLevel=="State"
	replace DistName="All Districts" if DataLevel=="State"
	
	gen State_leaid=StateAssignedDistID
	
	if  "`year'"=="2022" | "`year'"=="2023" {
		
		merge m:1 State_leaid using "${iowa}/NCES_2021_district.dta"
		
		drop if _merge==2
		drop _merge

		merge m:1 State_leaid SchName using "${iowa}/NCES_2021_school.dta", update replace
		
		drop if _merge==2
		drop _merge
		
		drop State
		
		merge m:1 DataLevel SchName DistName using "${raw}/IA_Unmerged.dta", update replace
		
	}
	
	if "`year'"=="2015" | "`year'"=="2016" | "`year'"=="2017" | "`year'"=="2018"| "`year'"=="2019"  {
		
		replace SchName="South OBrien Elem Sch Primghar Center" if SchName=="South O'Brien Elem Sch Primghar Center"
	replace SchName="South OBrien Secondary School" if SchName=="South O'Brien Secondary School"
		
	}
	
	if "`year'"=="2015" | "`year'"=="2016" | "`year'"=="2017" | "`year'"=="2018"| "`year'"=="2019" | "`year'"=="2021"  {
		
		merge m:1 State_leaid using "${iowa}/NCES_`prevyear'_district.dta"

		drop if _merge==2
		drop _merge

		merge m:1 State_leaid SchName using "${iowa}/NCES_`prevyear'_school.dta", update replace
	}


	gen SchYear="`Year'"
	gen AssmtType="Regular"
	
	if "`year'"=="2019" | "`year'"=="2021" | "`year'"=="2022" | "`year'"=="2023" {
		gen AssmtName="ISASP"
	}
	
	if "`year'"=="2015" | "`year'"=="2016" | "`year'"=="2017" | "`year'"=="2018" {
		gen AssmtName="Iowa Assessments"
	}

	destring StudentSubGroup_TotalTested, replace force
	bysort DistName SchName Subject GradeLevel StudentGroup: egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested)
	tostring StudentSubGroup_TotalTested, replace force
	tostring StudentGroup_TotalTested, replace force
	replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="."
	replace StudentGroup_TotalTested="*" if StudentGroup_TotalTested=="."

	foreach x of numlist 4/5 {
		generate Lev`x'_count = ""
		generate Lev`x'_percent = ""
	}

	if "`year'"=="2019" {
		gen Flag_AssmtNameChange="Y"
		gen Flag_CutScoreChange_ELA="Y"
		gen Flag_CutScoreChange_math="Y"
		gen Flag_CutScoreChange_read=""
		gen Flag_CutScoreChange_oth="Y"
	}
	
	if "`year'"!="2019" {
		gen Flag_AssmtNameChange="N"
		gen Flag_CutScoreChange_ELA="N"
		gen Flag_CutScoreChange_math="N"
		gen Flag_CutScoreChange_read=""
		gen Flag_CutScoreChange_oth="N"
	}
	
	gen AvgScaleScore="--"
	gen ProficiencyCriteria="Levels 2-3"

	drop if SchName=="" | DistName==""

	drop State
	gen State="Iowa"
	
	drop if _merge==2

	keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth 

	order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth 

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
	replace State="Iowa"
	replace StateAbbrev="IA"
	replace StateFips=19
	
	save "${output}/IA_AssmtData_`year'.dta", replace

	export delimited using "${output}/IA_AssmtData_`year'.csv", replace
}



