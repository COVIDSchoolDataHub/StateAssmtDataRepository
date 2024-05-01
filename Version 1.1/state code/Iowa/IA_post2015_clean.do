clear
set more off

// global raw "/Users/minnamgung/Desktop/SADR/Iowa/Input"
// global output "/Users/minnamgung/Desktop/SADR/Iowa/Output"
// global int "/Users/minnamgung/Desktop/SADR/Iowa/Intermediate"
// global dr "/Users/minnamgung/Desktop/SADR/Iowa/Input/Data Request"

// global nces "/Users/minnamgung/Desktop/SADR/NCES District and School Demographics-2"
// global iowa "/Users/minnamgung/Desktop/SADR/Iowa/NCES"

global iowa "/Users/benjaminm/Documents/State_Repository_Research/Iowa/NCES"
global nces "/Users/benjaminm/Documents/State_Repository_Research/NCES"
global raw "/Users/benjaminm/Documents/State_Repository_Research/Iowa/Input"
global dr "/Users/benjaminm/Documents/State_Repository_Research/Iowa/Input/Data Request"
global int "/Users/benjaminm/Documents/State_Repository_Research/Iowa/Intermediate"
global output "/Users/benjaminm/Documents/State_Repository_Research/Iowa/Output"

//cd "/Users/benjaminm/Documents/State_Repository_Research/NCES"

import excel "${raw}/Iowa_Unmerged.xlsx", firstrow clear
// save "${raw}/IA_Unmerged.dta", replace

// precleanign of unmerged data 
use "${raw}/IA_Unmerged.dta", clear

tostring DistType, replace
tostring SchType, replace 

replace DistType = "Regular local school district" if DistType == "1"
replace DistType = "Independent charter district" if DistType == "7"

replace SchType = "Regular school" if SchType == "1"
replace SchType = "" if SchType == "."

tostring CountyCode, replace 

save "${raw}/IA_Unmerged_1.dta", replace

// saving files 
foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 {
	
local prevyear =`=`year'-1'
local Year = substr("`prevyear'",-2,2) + substr("`year'",-2,2)

import excel "${dr}/IA_ProficiencyData_`Year'.xlsx", sheet("School") firstrow allstring clear


save "${output}/IA_AssmtData_`year'_NEW.dta", replace

import excel "${dr}/IA_ProficiencyData_`Year'.xlsx", sheet("District") firstrow allstring clear

append using "${output}/IA_AssmtData_`year'_NEW.dta"

save "${output}/IA_AssmtData_`year'_NEW.dta", replace

import excel "${dr}/IA_ProficiencyData_`Year'.xlsx", sheet("State") firstrow allstring clear

append using "${output}/IA_AssmtData_`year'_NEW.dta"

save "${output}/IA_AssmtData_`year'_NEW.dta", replace

}

use "${output}/IA_AssmtData_2023_NEW.dta", replace
//	use "${output}/IA_AssmtData_2022_NEW.dta", clear

// set trace on






foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 {
	
	local prevyear =`=`year'-1'
	local Year = "`prevyear'" + "-" + substr("`year'",-2,2)
	
	use "${output}/IA_AssmtData_`year'_NEW.dta", clear
	
	///////////////////////

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
	replace StudentSubGroup="Gender X" if StudentSubGroup=="Non-Binary"

	gen StudentGroup="All Students"
	replace StudentGroup="RaceEth" if inlist(StudentSubGroup, "American Indian or Alaska Native", "Asian", "Black or African American", "Hispanic or Latino", "Native Hawaiian or Pacific Islander", "Two or More", "White")
	replace StudentGroup="Gender" if inlist(StudentSubGroup, "Male", "Female", "Gender X")
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
	
		replace SchName="Odebolt Arthur Battle Creek Ida Grove Elementary-Ida Grove" if SchName=="Odebolt Arthur Battle Creek Ida Grove Elementary  School - Ida Grove"
	replace SchName="Odebolt Arthur Battle Creek Ida Grove Elementary-Odebolt" if SchName=="Odebolt Arthur Battle Creek Ida Grove Elementary School - Odebolt"
	// replace school_name="Van Buren County Community School District Douds Center" if SchName=="Van Buren County Community School District Middle & High School"

	
	
// 	replace SchName="All Schools" if DataLevel=="District" | DataLevel=="State"
// 	replace DistName="All Districts" if DataLevel=="State"
	
	gen State_leaid=StateAssignedDistID




	
	if  "`year'"=="2022" | "`year'"=="2023" {
		
		merge m:1 State_leaid using "${iowa}/NCES_2021_district.dta"
		
		drop if _merge==2
		drop _merge

		merge m:1 State_leaid SchName using "${iowa}/NCES_2021_school.dta" //, update replace
		
		drop if _merge==2
		drop _merge
		
		
		drop SchType
		rename SchType_str SchType

		


		
	}
	
	
	
	
	if "`year'"=="2015" | "`year'"=="2016" | "`year'"=="2017" | "`year'"=="2018"| "`year'"=="2019"  {
		
		replace SchName="South OBrien Elem Sch Primghar Center" if SchName=="South O'Brien Elem Sch Primghar Center"
	replace SchName="South OBrien Secondary School" if SchName=="South O'Brien Secondary School"
		
	}
	
	if "`year'"=="2015" | "`year'"=="2016" | "`year'"=="2017" | "`year'"=="2018"| "`year'"=="2019" | "`year'"=="2021"  {
		

		merge m:1 State_leaid using "${iowa}/NCES_`prevyear'_district.dta"

		drop if _merge==2
		drop _merge
		

	merge m:1 State_leaid SchName using "${iowa}/NCES_`prevyear'_school.dta" 

	 
	 	drop if _merge==2

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

		if "`year'"=="2015" | "`year'"=="2016" | "`year'"=="2017" | "`year'"=="2018" {
			
			
	// 		gen Flag_AssmtNameChange="N"
// 		gen Flag_CutScoreChange_ELA="N"
// 		gen Flag_CutScoreChange_math="N"
// 		gen Flag_CutScoreChange_read=""
// 		gen Flag_CutScoreChange_oth=""

		gen Flag_AssmtNameChange = "N"
		gen Flag_CutScoreChange_ELA = "N"
		gen Flag_CutScoreChange_math = "N"
		gen Flag_CutScoreChange_sci = "Not applicable" 
		gen Flag_CutScoreChange_soc = "Not applicable"
		
		}

	if "`year'"=="2019" {
// 		gen Flag_AssmtNameChange="Y"
// 		gen Flag_CutScoreChange_ELA="Y"
// 		gen Flag_CutScoreChange_math="Y"
// 		gen Flag_CutScoreChange_read=""
// 		gen Flag_CutScoreChange_oth="Y"
		
		gen Flag_AssmtNameChange = "Y"
		gen Flag_CutScoreChange_ELA = "Y"
		gen Flag_CutScoreChange_math = "Y"
		gen Flag_CutScoreChange_sci = "Y" 
		gen Flag_CutScoreChange_soc = "Not applicable"
	}
	
	if "`year'"=="2021" | "`year'"=="2022" | "`year'"=="2023" {
// 		gen Flag_AssmtNameChange="N"
// 		gen Flag_CutScoreChange_ELA="N"
// 		gen Flag_CutScoreChange_math="N"
// 		gen Flag_CutScoreChange_read=""
// 		gen Flag_CutScoreChange_oth="N"
		
		gen Flag_AssmtNameChange = "N"
		gen Flag_CutScoreChange_ELA = "N"
		gen Flag_CutScoreChange_math = "N"
		gen Flag_CutScoreChange_sci = "N" 
		gen Flag_CutScoreChange_soc = "Not applicable"
	}
	
	gen AvgScaleScore="--"
	gen ProficiencyCriteria="Levels 2-3"

	// drop if SchName=="" | DistName==""

	//drop State
	//gen State="Iowa"
	
	//drop if _merge==2

// 	keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth 
//
// 	order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth 
//
// 	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

	//DataLevel //UPDATED
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel ==1 | DataLevel ==2

	
	if  "`year'"=="2022" | "`year'"=="2023" {
	replace SchType = "Regular school" if SchName == "Big Creek Elementary" 
		replace NCESSchoolID = "192091002314" if SchName == "Big Creek Elementary" 
		replace SchLevel = 1 if SchName == "Big Creek Elementary" 
		replace SchVirtual = 0  if SchName == "Big Creek Elementary" 
		
		replace SchType = "Regular school" if SchName == "Bondurant - Farrar Intermediate School" 
		replace NCESSchoolID = "190507002125" if SchName == "Bondurant - Farrar Intermediate School" 
		replace SchLevel = 2 if SchName == "Bondurant - Farrar Intermediate School" 
		replace SchVirtual = 0  if SchName == "Bondurant - Farrar Intermediate School" 
		
		replace SchType = "Regular school" if SchName == "Bondurant-Farrar Junior High" 
		replace NCESSchoolID = "190507002313" if SchName == "Bondurant-Farrar Junior High" 
		replace SchLevel = 2 if SchName == "Bondurant-Farrar Junior High" 
		replace SchVirtual = 0  if SchName == "Bondurant-Farrar Junior High" 
		
		replace SchType = "Regular school" if SchName == "Dubuque Online School" 
		replace NCESSchoolID = "190948002309" if SchName == "Dubuque Online School" 
		replace SchLevel = 4 if SchName == "Dubuque Online School" 
		replace SchVirtual = 1  if SchName == "Dubuque Online School" 
		
		
		replace SchType = "Regular school" if SchName == "Edmunds Elementary School"
		replace NCESSchoolID = "190897000529" if SchName == "Edmunds Elementary School"
		replace SchLevel = 1 if SchName == "Edmunds Elementary School" 
		replace SchVirtual = 0  if SchName == "Edmunds Elementary School"
		
		replace SchType = "Regular school" if SchName == "Lisbon Secondary"
		replace NCESSchoolID = "191725001009" if SchName == "Lisbon Secondary"
		replace SchLevel = 2 if SchName == "Lisbon Secondary"
		replace SchVirtual = 0  if SchName == "Lisbon Secondary"
		
		
		replace SchType = "Regular school" if SchName == "Lone Tree Middle-Senior High School"
		replace NCESSchoolID = "191755001019" if SchName == "Lone Tree Middle-Senior High School"
		replace SchLevel = 2 if SchName == "Lone Tree Middle-Senior High School"
		replace SchVirtual = 0  if SchName == "Lone Tree Middle-Senior High School"
		
		replace SchType = "Regular school" if SchName == "Northwood-Kensett MIddle/High School"
		replace NCESSchoolID = "192121001271" if SchName == "Northwood-Kensett MIddle/High School"
		replace SchLevel = 4 if SchName == "Northwood-Kensett MIddle/High School"
		replace SchVirtual = 0  if SchName == "Northwood-Kensett MIddle/High School"
		
		replace SchType = "Regular school" if SchName == "Sugar Creek Elementary School"
		replace NCESSchoolID = "193051002308" if SchName == "Sugar Creek Elementary School"
		replace SchLevel = 1 if SchName == "Sugar Creek Elementary School"
		replace SchVirtual = 0  if SchName == "Sugar Creek Elementary School"
		
			replace SchType = "Regular school" if SchName == "Maple Grove Elementary"
		replace NCESSchoolID = "193051002308" if SchName == " Maple Grove Elementary"
		replace SchLevel = 1 if SchName == " Maple Grove Elementary"
		replace SchVirtual = 0  if SchName == "Maple Grove Elementary"
	}
	
	if  "`year'"=="2019" | "`year'"=="2021" {
		replace SchType = 1 if SchName == "Odebolt Arthur Battle Creek Ida Grove Elementary School - Ida Grove"
		replace NCESSchoolID = "192160002247" if SchName == "Odebolt Arthur Battle Creek Ida Grove Elementary School - Ida Grove"
		replace SchLevel = 1 if SchName == "Odebolt Arthur Battle Creek Ida Grove Elementary School - Ida Grove"
		replace SchVirtual = 0  if SchName == "Odebolt Arthur Battle Creek Ida Grove Elementary School - Ida Grove"
		
	}
	
	if  "`year'"=="2021" {
		replace SchType = 1 if SchName == "Van Buren County Community School District Middle & High School"
		replace NCESSchoolID = "192898001670" if SchName == "Van Buren County Community School District Middle & High School"
		replace SchLevel = 4 if SchName == "Van Buren County Community School District Middle & High School"
		replace SchVirtual = 0  if SchName == "Van Buren County Community School District Middle & High School"
		
	}
	

	// updated 4/30/2024
	
if "`year'" == "2023" {
	
	replace NCESSchoolID = "190654000213" if SchName == "Maple Grove Elementary" & NCESDistrictID == "1906540"
	
}
	
	
	drop State_leaid seasch

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
	replace State = "Iowa"
	replace StateAbbrev = "IA"
	replace StateFips =19
	
	save "${output}/IA_AssmtData_`year'.dta", replace

	export delimited using "${output}/IA_AssmtData_`year'.csv", replace
}



// new dist names 

import excel "${raw}/ia_full-dist-sch-stable-list_through2023", firstrow case(preserve) allstring clear

//Fixing DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

save "IA_StableNames_Sch", replace
duplicates drop NCESDistrictID SchYear, force
drop NCESSchoolID newschname olddistname oldschname
gen SchName = "All Schools"
replace DataLevel = 2

append using "IA_StableNames_Sch"
sort DataLevel
duplicates drop SchYear DataLevel NCESDistrictID NCESSchoolID, force
save "IA_StableNames", replace
clear


//Looping Through Years
forvalues year = 2015/2023 {  
	if `year' == 2020 continue
use "IA_StableNames", clear
local prevyear = `=`year'-1'
keep if SchYear == "`prevyear'-" + substr("`year'",-2,2)
merge 1:m DataLevel NCESDistrictID NCESSchoolID using "${output}/IA_AssmtData_`year'" 
drop if _merge == 1
replace DistName = newdistname if DataLevel !=1
replace SchName = newschname if DataLevel == 3
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel ==1


//Final Cleaning and Saving
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup	

save "${output}/IA_AssmtData_`year'.dta", replace

export delimited using "${output}/IA_AssmtData_`year'.csv", replace

}



// merging in updated county names 
	
import excel "${raw}/ia_county-list_through2023", firstrow case(preserve) allstring clear

duplicates drop CountyCode SchYear, force
drop oldcountyname 

save "IA_StableCounty", replace

forvalues year = 2015/2023 {  // /2023 { 
	if `year' == 2020 continue
use "IA_StableCounty", clear
local prevyear = `=`year'-1'
keep if SchYear == "`prevyear'-" + substr("`year'",-2,2)
merge 1:m CountyCode using "${output}/IA_AssmtData_`year'" 
replace CountyName = newcountyname if newcountyname != ""
drop newcountyname

//Final Cleaning and Saving
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup	

save "${output}/IA_AssmtData_`year'.dta", replace

export delimited using "${output}/IA_AssmtData_`year'.csv", replace


}
