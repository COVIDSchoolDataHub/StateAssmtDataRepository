clear
global path "/Users/willtolmie/Documents/State Repository Research/Tennessee"
global nces "/Users/willtolmie/Documents/State Repository Research/NCES"

global ncesyears 2009 2011 2012 2013 2014 2016 2017 2018 2020 2021
foreach n in $ncesyears {
	
	** NCES School Data

	use "${nces}/School/NCES_`n'_School.dta"

	** Rename Variables

	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename ncesschoolid NCESSchoolID
	rename lea_name DistName
	rename school_type SchType

	** Isolate Tennessee Data

	drop if StateFips != 47
	drop if school_status == 2
	
	** Drop Excess Variables

	keep StateFips NCESDistrictID State_leaid DistCharter NCESSchoolID seasch SchVirtual SchLevel SchType school_name sch_lowest_grade_offered sch_highest_grade_offered
	
	** Fix Variable Types

	decode SchLevel, gen(SchLevel2)
	decode SchType, gen(SchType2)
	drop SchLevel SchType
	rename SchLevel2 SchLevel 
	rename SchType2 SchType 
	replace seasch = "00" + State_leaid + "-" + seasch if `n' < 2016
	replace State_leaid = "TN-00" + State_leaid if `n' < 2016
	
	local m = `n' - 1999
	save "${path}/Semi-Processed Data Files/`n'_`m'_NCES_Cleaned_School.dta", replace

	** NCES District Data

	clear
	use "${nces}/District/NCES_`n'_District.dta"

	** Rename Variables

	rename district_agency_type DistType
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename county_name CountyName
	rename state_fips StateFips

	** Drop Excess Variables

	keep StateFips NCESDistrictID State_leaid DistCharter CountyCode CountyName lea_name DistType lowest_grade_offered highest_grade_offered
	
	** Fix Variable Types
	
	replace State_leaid = "TN-00" + State_leaid if `n' < 2016

	* Isolate Rhode Island Data

	drop if StateFips != 47
	save "${path}/Semi-Processed Data Files/`n'_`m'_NCES_Cleaned_District.dta", replace
}

global ncesyear 2010  
foreach n in $ncesyear {
	
	** NCES School Data

	use "${nces}/School/NCES_`n'_School.dta"

	** Rename Variables

	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename ncesschoolid NCESSchoolID
	rename lea_name DistName
	rename school_type SchType

	** Isolate Tennessee Data

	drop if StateFips != 47
	drop if school_status == 2
	
	** Drop Excess Variables

	keep StateFips NCESDistrictID State_leaid DistCharter NCESSchoolID seasch SchVirtual SchLevel SchType school_name sch_lowest_grade_offered sch_highest_grade_offered
	
	** Fix Variable Types

	decode SchLevel, gen(SchLevel2)
	decode SchType, gen(SchType2)
	drop SchLevel SchType
	rename SchLevel2 SchLevel 
	rename SchType2 SchType 
	replace seasch = "00" + State_leaid + "-" + seasch
	replace State_leaid = "TN-00" + State_leaid
	
	local m = `n' - 1999
	save "${path}/Semi-Processed Data Files/`n'_`m'_NCES_Cleaned_School.dta", replace

	** NCES District Data

	clear
	use "${nces}/District/NCES_`n'_District.dta"

	** Rename Variables

	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename county_name CountyName
	rename state_fips StateFips
	rename agency_type DistType

	** Drop Excess Variables

	keep StateFips NCESDistrictID State_leaid DistCharter CountyCode CountyName lea_name DistType lowest_grade_offered highest_grade_offered
	
	** Fix Variable Types
	
	replace State_leaid = "TN-00" + State_leaid

	* Isolate Rhode Island Data

	drop if StateFips != 47
	save "${path}/Semi-Processed Data Files/`n'_`m'_NCES_Cleaned_District.dta", replace
}

** Import Data

import excel "${path}/Original Data Files/TN_OriginalData_2023_all_state.xlsx", firstrow clear // 2023 files
gen DataLevel = "State"
save "${path}/Semi-Processed Data Files/TN_OriginalData_2023_all.dta", replace
import excel "${path}/Original Data Files/TN_OriginalData_2023_all_dist.xlsx", firstrow clear
gen DataLevel = "District"
append using "${path}/Semi-Processed Data Files/TN_OriginalData_2023_all.dta"
save "${path}/Semi-Processed Data Files/TN_OriginalData_2023_all.dta", replace
import excel "${path}/Original Data Files/TN_OriginalData_2022_all_state.xlsx", firstrow clear // 2022 files
gen DataLevel = "State"
save "${path}/Semi-Processed Data Files/TN_OriginalData_2022_all.dta", replace
import excel "${path}/Original Data Files/TN_OriginalData_2022_all_dist.xlsx", firstrow clear
gen DataLevel = "District"
append using "${path}/Semi-Processed Data Files/TN_OriginalData_2022_all.dta"
save "${path}/Semi-Processed Data Files/TN_OriginalData_2022_all.dta", replace
import delimited "${path}/Original Data Files/TN_OriginalData_2022_all_sch.csv", clear
gen DataLevel = "School"
append using "${path}/Semi-Processed Data Files/TN_OriginalData_2022_all.dta"
save "${path}/Semi-Processed Data Files/TN_OriginalData_2022_all.dta", replace
global csvyears 2017 2018 2019 2021 // .csv files   
foreach v in $csvyears {
	import delimited "${path}/Original Data Files/TN_OriginalData_`v'_all_state.csv", clear
	gen DataLevel = "State"
	save "${path}/Semi-Processed Data Files/TN_OriginalData_`v'_all.dta", replace
	import delimited "${path}/Original Data Files/TN_OriginalData_`v'_all_dist.csv", clear
	gen DataLevel = "District"
	append using "${path}/Semi-Processed Data Files/TN_OriginalData_`v'_all.dta"
	save "${path}/Semi-Processed Data Files/TN_OriginalData_`v'_all.dta", replace
	import delimited "${path}/Original Data Files/TN_OriginalData_`v'_all_sch.csv", clear
	gen DataLevel = "School"
	append using "${path}/Semi-Processed Data Files/TN_OriginalData_`v'_all.dta"
	save "${path}/Semi-Processed Data Files/TN_OriginalData_`v'_all.dta", replace
}
global xlsxyears 2010 2011 2012 2013 2014 2015 // .xlsx files   
foreach x in $xlsxyears {
	import excel "${path}/Original Data Files/TN_OriginalData_`x'_all_state.xlsx", firstrow clear
	gen DataLevel = "State"
	save "${path}/Semi-Processed Data Files/TN_OriginalData_`x'_all.dta", replace
	import excel "${path}/Original Data Files/TN_OriginalData_`x'_all_dist.xlsx", firstrow clear
	gen DataLevel = "District"
	append using "${path}/Semi-Processed Data Files/TN_OriginalData_`x'_all.dta"
	save "${path}/Semi-Processed Data Files/TN_OriginalData_`x'_all.dta", replace
	import excel "${path}/Original Data Files/TN_OriginalData_`x'_all_sch.xlsx", firstrow clear
	gen DataLevel = "School"
	append using "${path}/Semi-Processed Data Files/TN_OriginalData_`x'_all.dta"
	save "${path}/Semi-Processed Data Files/TN_OriginalData_`x'_all.dta", replace
}

** Standardize Variable Names

global var1years 2010 2011 2012
foreach v in $var1years {
	clear
	use "${path}/Semi-Processed Data Files/TN_OriginalData_`v'_all.dta"
	drop NumberEnrolled PercentBelowBasicorBasic
	rename DistrictName DistName
	rename SchoolID StateAssignedSchID
	rename StudentGroup StudentSubGroup
	rename NumberBelowBasic Lev1_count  
	rename NumberAdvanced Lev4_count
	rename PercentBasic Lev2_percent
	rename PercentProficientorAdvanced ProficientOrAbove_percent
	rename SchoolName SchName     
	rename NumberBasic Lev2_count
	rename PercentBelowBasic Lev1_percent
	rename PercentProficient Lev3_percent  
	rename DistrictID StateAssignedDistID
	rename Grade GradeLevel 
	rename NumberofValidTests StudentSubGroup_TotalTested
	rename NumberProficient Lev3_count
	rename PercentAdvanced Lev4_percent
	gen AssmtName = "TCAP Achievement Assessments"
	local z = `y' - 1
	local x = `y' - 2000
	gen SchYear = "`z'-`x'"
	gen ParticipationRate = "--"
	save "${path}/Semi-Processed Data Files/TN_`v'_all.dta", replace

}

global var2years 2013 2014 2015 
foreach v in $var2years {
	clear
	use "${path}/Semi-Processed Data Files/TN_OriginalData_`v'_all.dta"
	drop pct_bsc_and_below
	rename year SchYear
	rename subject Subject
	rename system_name DistName
	rename subgroup StudentSubGroup
	rename n_below_bsc Lev1_count  
	rename n_adv Lev4_count
	rename pct_bsc Lev2_percent
	rename pct_prof_adv ProficientOrAbove_percent    
	rename n_bsc Lev2_count
	rename pct_below_bsc Lev1_percent
	rename pct_prof Lev3_percent  
	rename system StateAssignedDistID
	rename grade GradeLevel 
	rename valid_tests StudentSubGroup_TotalTested
	rename n_prof Lev3_count
	rename pct_adv Lev4_percent
	gen AssmtName = "TCAP Achievement Assessments"
	gen ParticipationRate = "--"
	save "${path}/Semi-Processed Data Files/TN_`v'_all.dta", replace

}

use "${path}/Semi-Processed Data Files/TN_2013_all.dta"
drop if StudentSubGroup_TotalTested == ""
save "${path}/Semi-Processed Data Files/TN_2013_all.dta", replace

global csvyears 2017 2018 2019 2021 
foreach v in $csvyears {
	clear
	use "${path}/Semi-Processed Data Files/TN_OriginalData_`v'_all.dta"
	rename year SchYear
	rename system_name DistName
	rename subject Subject
	rename subgroup StudentSubGroup
	rename n_below Lev1_count  
	rename n_mastered Lev4_count
	rename pct_approaching Lev2_percent
	rename pct_on_mastered ProficientOrAbove_percent    
	rename n_approaching Lev2_count
	rename pct_below Lev1_percent
	rename pct_on_track Lev3_percent  
	rename system StateAssignedDistID
	rename grade GradeLevel 
	rename valid_tests StudentSubGroup_TotalTested
	rename n_on_track Lev3_count
	rename pct_mastered Lev4_percent
	save "${path}/Semi-Processed Data Files/TN_`v'_all.dta", replace

}

global var3years 2022 2023
foreach v in $var3years {
	clear
	use "${path}/Semi-Processed Data Files/TN_OriginalData_`v'_all.dta"
	rename year SchYear
	rename system_name DistName
	rename student_group StudentSubGroup
	rename n_below Lev1_count  
	rename subject Subject
	rename n_exceeded_expectations Lev4_count
	rename pct_approaching Lev2_percent
	rename pct_met_exceeded ProficientOrAbove_percent    
	rename n_approaching Lev2_count
	rename pct_below Lev1_percent
	rename pct_met_expectations Lev3_percent  
	rename system StateAssignedDistID
	rename grade GradeLevel 
	rename valid_tests StudentSubGroup_TotalTested
	rename n_met_expectations Lev3_count
	rename pct_exceeded_expectations Lev4_percent
	save "${path}/Semi-Processed Data Files/TN_`v'_all.dta", replace

}

global var4years 2013 2014 2015 2018 2019 2021 2022
foreach v in $var4years {
	clear
	use "${path}/Semi-Processed Data Files/TN_`v'_all.dta"
	rename school_name SchName
	rename school StateAssignedSchID
	save "${path}/Semi-Processed Data Files/TN_`v'_all.dta", replace
}

use "${path}/Semi-Processed Data Files/TN_2017_all.dta"
rename school StateAssignedSchID
gen SchName = ""
gen AssmtName = "TNReady"
gen ParticipationRate = "--"
save "${path}/Semi-Processed Data Files/TN_2017_all.dta", replace

use "${path}/Semi-Processed Data Files/TN_2018_all.dta"
gen ParticipationRate = "--"
save "${path}/Semi-Processed Data Files/TN_2018_all.dta", replace

use "${path}/Semi-Processed Data Files/TN_2019_all.dta"
gen ParticipationRate = "--"
save "${path}/Semi-Processed Data Files/TN_2019_all.dta", replace

global var5years 2019 2021 2022 2023
foreach v in $var5years {
	clear
	use "${path}/Semi-Processed Data Files/TN_`v'_all.dta"
	drop enrolled tested
	save "${path}/Semi-Processed Data Files/TN_`v'_all.dta", replace
}

global var6years 2018 2019 2021 2022 2023
foreach v in $var6years {
	clear
	use "${path}/Semi-Processed Data Files/TN_`v'_all.dta"
	keep if test == "TNReady"
	rename test AssmtName
	save "${path}/Semi-Processed Data Files/TN_`v'_all.dta", replace

}

global var7years 2021 2022 2023
foreach v in $var7years {
	clear
	use "${path}/Semi-Processed Data Files/TN_`v'_all.dta"
	rename participation_rate ParticipationRate
	destring ParticipationRate, generate(nParticipationRate) force
	replace nParticipationRate = nParticipationRate / 100 if nParticipationRate != .
	tostring nParticipationRate, replace force
	replace ParticipationRate = nParticipationRate if ParticipationRate != "*"
	drop nParticipationRate
	save "${path}/Semi-Processed Data Files/TN_`v'_all.dta", replace
}

global years 2010 2011 2012 2013 2014 2015 2017 2018 2019 2021 2022 2023
foreach y in $years {
	clear
	use "${path}/Semi-Processed Data Files/TN_`y'_all.dta"
	
	** Standardize StudentSubGroup Values
	
	replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
	replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaiian or PI" | StudentSubGroup == "Hawaiian or Pacific Islander" | StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
	replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learners" | StudentSubGroup == "English Learners"
	replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Learners/Transitional 1-4" | StudentSubGroup == "Non-English Learners" | StudentSubGroup == "Non-English Language Learners"
	replace StudentSubGroup = "Other" if StudentSubGroup == "English Learner Transitional 1-4" | StudentSubGroup == "English Learners with Transitional 1-4"
	replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged (Free or Reduced Price Lunch)"
	replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Economically Disadvantaged"
	gen StudentGroup = ""
	replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
	replace StudentGroup="RaceEth" if StudentSubGroup== "Black or African American" | StudentSubGroup=="Native Hawaiian or Pacific Islander" | StudentSubGroup=="Asian" | StudentSubGroup=="Hispanic or Latino" | StudentSubGroup=="White" | StudentSubGroup=="American Indian or Alaska Native"
	replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged" | StudentSubGroup=="Not Economically Disadvantaged"
	replace StudentGroup="Gender" if StudentSubGroup=="Male" | StudentSubGroup=="Female"
	replace StudentGroup="EL Status" if StudentSubGroup=="English Learner" | StudentSubGroup=="English Proficient" | StudentSubGroup=="Other"
	keep if StudentGroup=="All Students" | StudentGroup=="RaceEth" | StudentGroup=="Economic Status" | StudentGroup=="Gender" | StudentGroup=="EL Status"
	
	** Drop Irrelevant Data
	
	keep if Subject == "Reading/Language" | Subject == "Math" | Subject == "Science" | Subject == "RLA" | Subject == "Social Studies" | Subject == "ELA"
	
	save "${path}/Semi-Processed Data Files/TN_`y'_all.dta", replace
}

global var8years 2010 2011 2012 2013 2014 2015 2017 2018 2019 2021 2022
foreach y in $var8years {
	
	** Generate StudentGroup Values
	
	clear
	use "${path}/Semi-Processed Data Files/TN_`y'_all.dta"
	keep if StudentGroup=="All Students"
	keep DataLevel StateAssignedSchID StateAssignedDistID Subject GradeLevel StudentSubGroup_TotalTested
	rename StudentSubGroup_TotalTested StudentGroup_TotalTested
	save "${path}/Semi-Processed Data Files/TN_`y'_group.dta", replace
	clear
	use "${path}/Semi-Processed Data Files/TN_`y'_all.dta"
	merge m:1 DataLevel StateAssignedSchID StateAssignedDistID Subject GradeLevel using "${path}/Semi-Processed Data Files/TN_`y'_group.dta"
	drop _merge
	save "${path}/Semi-Processed Data Files/TN_`y'_all.dta", replace
}

** Generate StudentGroup Values for 2023 Data

use "${path}/Semi-Processed Data Files/TN_2023_all.dta", replace
keep if StudentGroup=="All Students"
keep DataLevel StateAssignedDistID Subject GradeLevel StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested StudentGroup_TotalTested
save "${path}/Semi-Processed Data Files/TN_2023_group.dta", replace
clear
use "${path}/Semi-Processed Data Files/TN_2023_all.dta"
merge m:1 DataLevel StateAssignedDistID Subject GradeLevel using "${path}/Semi-Processed Data Files/TN_2023_group.dta"
drop _merge
gen SchName = "" 
gen StateAssignedSchID = .
save "${path}/Semi-Processed Data Files/TN_2023_all.dta", replace


foreach y in $years {
	clear
	use "${path}/Semi-Processed Data Files/TN_`y'_all.dta"
	gen str5 x = string(StateAssignedDistID,"%05.0f")
	gen str4 z = string(StateAssignedSchID,"%04.0f")
	gen State_leaid = "TN-" + x if DataLevel != "State"
	gen seasch = x + "-" + z if DataLevel == "School"
	replace seasch = "00900-0050" if SchName == "Grandview Heights Elementary School" & `y' == 2013
	replace State_leaid = "TN-00900"  if SchName == "Grandview Heights Elementary School" & `y' == 2013
	save "${path}/Semi-Processed Data Files/TN_`y'_merge.dta", replace
}

foreach y in $var8years {
	clear
	use "${path}/Semi-Processed Data Files/TN_`y'_merge.dta"
	local a = `y' - 1
	local b = `y' - 2000
	merge m:1 State_leaid using "${path}/Semi-Processed Data Files/`a'_`b'_NCES_Cleaned_District.dta"
	rename _merge district_merge
	merge m:1 State_leaid seasch using "${path}/Semi-Processed Data Files/`a'_`b'_NCES_Cleaned_School.dta"
	rename _merge school_merge
	drop if district_merge != 3 & DataLevel != "State" | school_merge !=3 & DataLevel == "School"
	save "${path}/Semi-Processed Data Files/TN_`y'_merged.dta", replace
}

clear
use "${path}/Semi-Processed Data Files/TN_2023_merge.dta"
merge m:1 State_leaid using "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_District.dta"
rename _merge district_merge
merge m:1 State_leaid seasch using "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_School.dta"
rename _merge school_merge
drop if district_merge != 3 & DataLevel != "State" | school_merge !=3 & DataLevel == "School"
save "${path}/Semi-Processed Data Files/TN_2023_merged.dta", replace

global var9years 2015 2017 2018 2019 2021 2022 2023
foreach y in $var9years {
	clear
	use "${path}/Semi-Processed Data Files/TN_`y'_merged.dta"
	decode SchVirtual, gen(SchVirtual2)
	drop SchVirtual
	rename SchVirtual2 SchVirtual 
	save "${path}/Semi-Processed Data Files/TN_`y'_merged.dta", replace
}

** Dist/SchName Values Missing in 2017 School-Level Data

use "${path}/Semi-Processed Data Files/TN_2017_merged.dta"
replace DistName = lea_name if DataLevel == "School"
replace SchName = school_name if DataLevel == "School"
save "${path}/Semi-Processed Data Files/TN_2017_merged.dta", replace

** SchName Value for NCESSchoolID 470449000149 Missing in Data

use "${path}/Semi-Processed Data Files/TN_2010_merged.dta"
replace SchName = "West Carroll Primary" if NCESSchoolID == "470449000149"
save "${path}/Semi-Processed Data Files/TN_2010_merged.dta", replace

foreach y in $years {
	clear
	use "${path}/Semi-Processed Data Files/TN_`y'_merged.dta"
	keep SchName Subject GradeLevel
	duplicates drop
	sort SchName Subject GradeLevel
	gen grade = .
	replace grade = 300000 if GradeLevel == "3"
	replace grade = 40000 if GradeLevel == "4"
	replace grade = 5000 if GradeLevel == "5"
	replace grade = 600 if GradeLevel == "6"
	replace grade = 70 if GradeLevel == "7"
	replace grade = 8 if GradeLevel == "8"
	collapse (sum) grade, by(SchName Subject)
	gen allgrades = ""
	replace allgrades = "G78" if grade == 78
	replace allgrades = "G06, G08" if grade == 608
	replace allgrades = "G67" if grade == 670
	replace allgrades = "G68" if grade == 678
	replace allgrades = "G05, G08" if grade == 5008
	replace allgrades = "G05, G07" if grade == 5070
	replace allgrades = "G05, G07, G08" if grade == 5078
	replace allgrades = "G56" if grade == 5600
	replace allgrades = "G05, G06, G08" if grade == 5608
	replace allgrades = "G57" if grade == 5670
	replace allgrades = "G58" if grade == 5678
	replace allgrades = "G04, G07" if grade == 40070
	replace allgrades = "G04, G07, G08" if grade == 40078
	replace allgrades = "G04, G06, G08" if grade == 40608
	replace allgrades = "G04, G06, G07, G08" if grade == 40678
	replace allgrades = "G45" if grade == 45000
	replace allgrades = "G46" if grade == 45600
	replace allgrades = "G04, G05, G06, G08" if grade == 45608
	replace allgrades = "G47" if grade == 45670
	replace allgrades = "G48" if grade == 45678
	replace allgrades = "G03, G07" if grade == 300070
	replace allgrades = "G03, G07, G08" if grade == 300078
	replace allgrades = "G03, G06, G08" if grade == 300608
	replace allgrades = "G03, G06, G07" if grade == 300670
	replace allgrades = "G03, G06, G07, G08" if grade == 300678
	replace allgrades = "G03, G05" if grade == 305000
	replace allgrades = "G03, G05, G07" if grade == 305070
	replace allgrades = "G03, G05, G06" if grade == 305600
	replace allgrades = "G03, G05, G06, G07" if grade == 305670
	replace allgrades = "G03, G05, G06, G07, G08" if grade == 305678
	replace allgrades = "G34" if grade == 340000
	replace allgrades = "G03, G04, G08" if grade == 340008
	replace allgrades = "G03, G04, G06" if grade == 340600
	replace allgrades = "G03, G04, G06, G08" if grade == 340608
	replace allgrades = "G03, G04, G06, G07, G08" if grade == 340678
	replace allgrades = "G35" if grade == 345000
	replace allgrades = "G03, G04, G05, G08" if grade == 345008
	replace allgrades = "G03, G04, G05, G07" if grade == 345070
	replace allgrades = "G03, G04, G05, G07, G08" if grade == 345078
	replace allgrades = "G36" if grade == 345600
	replace allgrades = "G03, G04, G05, G06, G08" if grade == 345608
	replace allgrades = "G37" if grade == 345670
	replace allgrades = "G38" if grade == 345678
	replace allgrades = "G03" if grade == 300000
	replace allgrades = "G04" if grade == 40000
	replace allgrades = "G05" if grade == 5000
	replace allgrades = "G06" if grade == 600
	replace allgrades = "G07" if grade == 70
	replace allgrades = "G08" if grade == 8
	save "${path}/Semi-Processed Data Files/TN_`y'_schgrade.dta", replace
	clear
	use "${path}/Semi-Processed Data Files/TN_`y'_merged.dta"
	keep DistName Subject GradeLevel
	duplicates drop
	sort DistName Subject GradeLevel
	gen grade = .
	replace grade = 300000 if GradeLevel == "3"
	replace grade = 40000 if GradeLevel == "4"
	replace grade = 5000 if GradeLevel == "5"
	replace grade = 600 if GradeLevel == "6"
	replace grade = 70 if GradeLevel == "7"
	replace grade = 8 if GradeLevel == "8"
	collapse (sum) grade, by(DistName Subject)
	gen distallgrades = ""
	replace distallgrades = "G78" if grade == 78
	replace distallgrades = "G06, G08" if grade == 608
	replace distallgrades = "G67" if grade == 670
	replace distallgrades = "G68" if grade == 678
	replace distallgrades = "G05, G08" if grade == 5008
	replace distallgrades = "G05, G07" if grade == 5070
	replace distallgrades = "G05, G07, G08" if grade == 5078
	replace distallgrades = "G56" if grade == 5600
	replace distallgrades = "G05, G06, G08" if grade == 5608
	replace distallgrades = "G57" if grade == 5670
	replace distallgrades = "G58" if grade == 5678
	replace distallgrades = "G04, G07" if grade == 40070
	replace distallgrades = "G04, G07, G08" if grade == 40078
	replace distallgrades = "G04, G06, G08" if grade == 40608
	replace distallgrades = "G04, G06, G07, G08" if grade == 40678
	replace distallgrades = "G45" if grade == 45000
	replace distallgrades = "G46" if grade == 45600
	replace distallgrades = "G04, G05, G06, G08" if grade == 45608
	replace distallgrades = "G47" if grade == 45670
	replace distallgrades = "G48" if grade == 45678
	replace distallgrades = "G03, G07" if grade == 300070
	replace distallgrades = "G03, G07, G08" if grade == 300078
	replace distallgrades = "G03, G06, G08" if grade == 300608
	replace distallgrades = "G03, G06, G07" if grade == 300670
	replace distallgrades = "G03, G06, G07, G08" if grade == 300678
	replace distallgrades = "G03, G05" if grade == 305000
	replace distallgrades = "G03, G05, G07" if grade == 305070
	replace distallgrades = "G03, G05, G06" if grade == 305600
	replace distallgrades = "G03, G05, G06, G07" if grade == 305670
	replace distallgrades = "G03, G05, G06, G07, G08" if grade == 305678
	replace distallgrades = "G34" if grade == 340000
	replace distallgrades = "G03, G04, G08" if grade == 340008
	replace distallgrades = "G03, G04, G06" if grade == 340600
	replace distallgrades = "G03, G04, G06, G08" if grade == 340608
	replace distallgrades = "G03, G04, G06, G07, G08" if grade == 340678
	replace distallgrades = "G35" if grade == 345000
	replace distallgrades = "G03, G04, G05, G08" if grade == 345008
	replace distallgrades = "G03, G04, G05, G07" if grade == 345070
	replace distallgrades = "G03, G04, G05, G07, G08" if grade == 345078
	replace distallgrades = "G36" if grade == 345600
	replace distallgrades = "G03, G04, G05, G06, G08" if grade == 345608
	replace distallgrades = "G37" if grade == 345670
	replace distallgrades = "G38" if grade == 345678
	replace distallgrades = "G03" if grade == 300000
	replace distallgrades = "G04" if grade == 40000
	replace distallgrades = "G05" if grade == 5000
	replace distallgrades = "G06" if grade == 600
	replace distallgrades = "G07" if grade == 70
	replace distallgrades = "G08" if grade == 8
	save "${path}/Semi-Processed Data Files/TN_`y'_distgrade.dta", replace
	clear
	use "${path}/Semi-Processed Data Files/TN_`y'_merged.dta"

	** Standardize Grade Level Values
	
	replace GradeLevel = "G0" + GradeLevel if GradeLevel != "All Grades"
	merge m:1 SchName Subject using "${path}/Semi-Processed Data Files/TN_`y'_schgrade.dta"
	drop _merge
	merge m:1 DistName Subject using "${path}/Semi-Processed Data Files/TN_`y'_distgrade.dta"
	replace GradeLevel = allgrades if GradeLevel == "All Grades" & DataLevel == "School"
	replace GradeLevel = distallgrades if GradeLevel == "All Grades" & DataLevel == "District"
	replace GradeLevel = "G38" if GradeLevel == "All Grades" & DataLevel == "State"
	duplicates drop
	
	** Generate Flags

	gen Flag_AssmtNameChange = "N" 
	replace Flag_AssmtNameChange = "Y" if `y' == 2017
	gen Flag_CutScoreChange_ELA = "N"
	replace Flag_CutScoreChange_ELA = "Y" if `y' == 2017
	gen Flag_CutScoreChange_math = "N"
	replace Flag_CutScoreChange_math = "Y" if `y' == 2017
	gen Flag_CutScoreChange_read = ""
	gen Flag_CutScoreChange_oth = "N"
	replace Flag_CutScoreChange_math = "Y" if `y' == 2021 | `y' == 2017
	
	** Generate Other Variables
	
	gen AssmtType = "Regular"
	gen ProficiencyCriteria = "Levels 3 and 4"

	** Fix Variable Types

	label def DataLevel 1 "State" 2 "District" 3 "School"
	decode DistType, generate(DistType2) 
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel DistType
	rename DistType2 DistType
	rename DataLevel_n DataLevel 
	recast int CountyCode
	drop StateFips district_merge
	gen State = "Tennessee"
	gen StateAbbrev = "TN"
	gen StateFips = 47
	drop SchYear 
	local z = `y' - 1
	local x = `y' - 2000
	gen SchYear = "`z'-`x'"
	tostring(StudentGroup_TotalTested), replace force
	tostring(StudentSubGroup_TotalTested), replace force
	recast int StateFips
	tostring CountyCode, replace force
	encode CountyCode, generate(CountyCode2)
	recast int CountyCode2
	drop CountyCode
	rename CountyCode2 CountyCode
	tostring(StateAssignedDistID), replace force
	tostring(StateAssignedSchID), replace force
	
	** Make StateAssignedSchoolIDs Unique
	
	replace StateAssignedSchID = StateAssignedDistID + "-" + StateAssignedSchID
	
	** Standardize Subject Values
	
	replace Subject = "ela" if Subject == "Reading/Language" | Subject == "RLA" | Subject == "ELA"
	replace Subject = "math" if Subject == "Math"
	replace Subject = "sci" if Subject == "Science"
	replace Subject = "soc" if Subject == "Social Studies"
	
	** Standardize Non-School Level Data

	replace SchName = "All Schools" if DataLevel == 1
	replace SchName = "All Schools" if DataLevel == 2
	replace DistName = "All Districts" if DataLevel == 1
	replace StateAssignedDistID = "" if DataLevel == 1
	replace StateAssignedSchID = "" if DataLevel != 3
	replace State_leaid = "" if DataLevel == 1
	replace seasch = "" if DataLevel != 3
	replace DistType = "" if DataLevel == 1
	replace SchType = "" if DataLevel != 3
	replace SchLevel = "" if DataLevel != 3
	replace SchVirtual = "" if DataLevel != 3
	
	** Convert Proficiency Data into Percentages

	foreach v of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent {
		destring `v', g(n`v') i(* -)
		replace n`v' = n`v' / 100 if n`v' != .
		tostring n`v', replace force
		replace `v' = n`v' if `v' != "*"
		drop n`v'
	}
	
	foreach v of varlist Lev1_count Lev2_count Lev3_count Lev4_count {
		destring `v', g(n`v') i(* -) force
	}
	
	gen ProficientOrAbove_count = nLev3_count + nLev4_count
	tostring ProficientOrAbove_count, replace force
	replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
	
	destring ProficientOrAbove_percent, generate(nProficientOrAbove_percent) force
	replace nProficientOrAbove_percent = nProficientOrAbove_percent / 100 if nProficientOrAbove_percent != .
	tostring nProficientOrAbove_percent, replace force
	replace ProficientOrAbove_percent = nProficientOrAbove_percent if ProficientOrAbove_percent != "*"
	drop nProficientOrAbove_percent
	
	** Standardize Suppressed Proficiency Data

	replace Lev1_percent="*" if Lev1_percent=="."
	replace Lev2_percent="*" if Lev2_percent=="."
	replace Lev3_percent="*" if Lev3_percent=="."
	replace Lev4_percent="*" if Lev4_percent=="."
	replace Lev1_count="*" if Lev1_count=="**" | Lev1_count=="***"
	replace Lev2_count="*" if Lev2_count=="**" | Lev2_count=="***"
	replace Lev3_count="*" if Lev3_count=="**" | Lev3_count=="***"
	replace Lev4_count="*" if Lev4_count=="**" | Lev4_count=="***"

	** Generate Empty Variables

	gen Lev5_count = "--"
	gen Lev5_percent = "--"
	gen AvgScaleScore = "--"
	
	** Label Variables

	label var StateAbbrev "State abbreviation"
	label var StateFips "State FIPS Id"
	label var SchYear "School year in which the data were reported. (e.g., 2021-22)"
	label var AssmtName "Name of state assessment"
	label var AssmtType "Assessment type"
	label var DataLevel "Level at which the data are reported"
	label var DistName "District name"
	label var DistCharter "Charter indicator - district"
	label var StateAssignedDistID "State-assigned district ID"
	label var SchName "School name"
	label var StateAssignedSchID "State-assigned school ID"
	label var Subject "Assessment subject area"
	label var GradeLevel "Grade tested (Individual grade levels, Gr3-8, all grades)"
	label var StudentGroup "Student demographic group"
	label var StudentSubGroup "Student demographic subgroup"
	label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested."
	label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested."
	label var Lev1_count "Count of students within subgroup performing at Level 1."
	label var Lev1_percent "Percent of students within subgroup performing at Level 1."
	label var Lev2_count "Count of students within subgroup performing at Level 2."
	label var Lev2_percent "Percent of students within subgroup performing at Level 2."
	label var Lev3_count "Count of students within subgroup performing at Level 3."
	label var Lev3_percent "Percent of students within subgroup performing at Level 3 ."
	label var Lev4_count "Count of students within subgroup performing at Level 4."
	label var Lev4_percent "Percent of students within subgroup performing at Level 4."
	label var Lev5_count "Count of students within subgroup performing at Level 5."
	label var Lev5_percent "Percent of students within subgroup performing at Level 5."
	label var AvgScaleScore "Avg scale score within subgroup."
	label var ProficiencyCriteria "Levels included in determining proficiency status."
	label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment."
	label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment."
	label var ParticipationRate "Participation rate."
	label var NCESDistrictID "NCES district ID"
	label var State_leaid "State LEA ID"
	label var CountyName "County in which the district or school is located."
	label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
	label var State "State name"
	label var StateAbbrev "State abbreviation"
	label var StateFips "State FIPS Id"
	label var DistType "District type as defined by NCES"
	label var NCESDistrictID "NCES district ID"
	label var NCESSchoolID "NCES school ID"
	label var SchType "School type as defined by NCES"
	label var SchVirtual "Virtual school indicator"
	label var SchLevel "School level"
	label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only."
	label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
	label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
	label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."

	** Fix Variable Order 

	keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

	order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

	** Export Assessment Data

	save "${path}/Semi-Processed Data Files/TN_AssmtData_`y'.dta", replace
	export delimited using "${path}/Output/TN_AssmtData_`y'.csv", replace
}
