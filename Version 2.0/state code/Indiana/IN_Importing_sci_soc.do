clear
set more off
set trace off

global Original "/Users/miramehta/Documents/IN State Testing Data/Original Data Files"
global temp "/Users/miramehta/Documents/IN State Testing Data/Temp"
global Output "/Users/miramehta/Documents/IN State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

//Importing and Combining
local SubGroups1 "Overall Ethnicity Gender FRL SPED ELL FOSTER HOMELESS"
local SubGroups2 "ETHNICITY GENDER FRL SPED ELL"

forvalues year = 2014/2024 {
if `year' == 2020 continue

	tempfile tempdistschool
	save "`tempdistschool'", replace emptyok
	clear
	
	foreach Subject in "Science" "Social Studies" {
		foreach DataLevel in LEA SCH {
				foreach SG of local SubGroups2 {
					if `year' < 2019 import excel using "${Original}/Science + Social Studies/IN_`year'_`DataLevel'_`Subject'_ISTEP.xlsx", sheet("`Subject' `SG'") clear
					if `year' > 2018 import excel using "${Original}/Science + Social Studies/IN_`year'_`DataLevel'_`Subject'_ILEARN.xlsx", sheet("`Subject' `SG'") clear 
					foreach var of varlist _all {
						local newvar = `var'[2] + `var'[1]
						local newvar = subinstr("`newvar'", " ", "",.)
						local newvar = lower("`newvar'")
						local newvar = subinstr("`newvar'", "%", "_per",.)
						local newvar = subinstr("`newvar'", "americanindian", "AI",.)
						local newvar = subinstr("`newvar'", "nativehawaiianorotherpacificislander","NH",.)
						local newvar = subinstr("`newvar'", "/", "",.)
						local newvar = subinstr("`newvar'", "freereducedpricemeals", "FRP",.)
						local newvar = subinstr("`newvar'", "generaleducation", "GE",.)
						local newvar = subinstr("`newvar'", "specialeducation", "SWD",.)
						local newvar = subinstr("`newvar'", "multiracial", "MR",.)
						local newvar = subinstr("`newvar'", "-","",.)
						//Level percents across years
						local newvar = subinstr("`newvar'", "belowproficiency", "Lev1_count_",.)
						local newvar = subinstr("`newvar'", "approachingproficiency", "Lev2_count_",.)
						local newvar = subinstr("`newvar'", "atproficiency", "Lev3_count_",.)
						local newvar = subinstr("`newvar'", "aboveproficiency", "Lev4_count_",.)
						
						rename `var' `newvar'
					}
					drop in 1/2
					duplicates drop
					save "${temp}/`Subject'_`DataLevel'_`SG'", replace
					clear
				}
				use "${temp}/`Subject'_`DataLevel'_GENDER"
				//Flagging here that for 2018 *AND* 2019, LEA ELA "GENDER", there are duplicate values. Arbitarily dropping below for now.
				if `year' == 2018 | `year' == 2019 duplicates drop grade idoe_corporation_id, force
				
				foreach SG in ETHNICITY FRL SPED ELL {
				if "`DataLevel'" == "LEA" merge 1:1 grade idoe_corporation_id using "${temp}/`Subject'_`DataLevel'_`SG'", nogen
				if "`DataLevel'" == "SCH" merge 1:1 grade idoe_corporation_id idoe_school_id using "${temp}/`Subject'_`DataLevel'_`SG'", nogen
				}
				gen DataLevel = "`DataLevel'"
				gen Subject = "`Subject'"
				if "`DataLevel'" == "LEA" {
					reshape long tested Lev1_count Lev2_count Lev3_count Lev4_count proficient proficient_per, i(idoe_corporation_id grade) j(StudentSubGroup) string
				}
				if "`DataLevel'" == "SCH" {
					reshape long tested Lev1_count Lev2_count Lev3_count Lev4_count proficient proficient_per, i(idoe_corporation_id idoe_school_id grade) j(StudentSubGroup) string
				}
				if `year' < 2019{
					drop Lev1_count Lev2_count Lev3_count Lev4_count //raw data do not include any actual values
				}
				rename proficient ProficientOrAbove_count
				rename proficient_per ProficientOrAbove_percent
				rename tested StudentSubGroup_TotalTested
				rename grade GradeLevel
				append using "`tempdistschool'"
				save "`tempdistschool'", replace
				clear
		}
		
	}
use "`tempdistschool'"
save "${temp}/`year'_District_School_sci_soc", replace
clear

	
	tempfile tempstate
	save "`tempstate'", emptyok replace
	foreach Subject in "Science" "Social Studies" {
			foreach SG of local SubGroups1 {
				if `year' == 2024 & "`SG'" == "FOSTER" continue
					if `year' < 2019 import excel using "${Original}/Science + Social Studies/IN_`year'_SEA_`Subject'_ISTEP.xlsx", sheet("`Subject' `SG'") clear
					if `year' > 2018 import excel using "${Original}/Science + Social Studies/IN_`year'_SEA_`Subject'_ILEARN.xlsx", sheet("`Subject' `SG'") clear
					foreach var of varlist _all {
						local newvar = `var'[1]
						local newvar = subinstr("`newvar'", " ", "",.)
						local newvar = lower("`newvar'")
						local newvar = subinstr("`newvar'", "%", "_per",.)
						local newvar = subinstr("`newvar'", "americanindian", "AI",.)
						local newvar = subinstr("`newvar'", "nativehawaiianorotherpacificislander","NH",.)
						local newvar = subinstr("`newvar'", "/", "",.)
						local newvar = subinstr("`newvar'", "freereducedpricemeals", "FRP",.)
						local newvar = subinstr("`newvar'", "generaleducation", "GE",.)
						local newvar = subinstr("`newvar'", "specialeducation", "SWD",.)
						local newvar = subinstr("`newvar'", "multiracial", "MR",.)
						local newvar = subinstr("`newvar'", "-","",.)
						//Level percents across years
						if `year' < 2019 local newvar = subinstr("`newvar'", "belowproficiency", "Lev1_count",.)
						if `year' < 2019 local newvar = subinstr("`newvar'", "atproficiency", "Lev2_count",.)
						if `year' < 2019 local newvar = subinstr("`newvar'", "aboveproficiency", "Lev3_count",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "belowproficiency", "Lev1_count",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "approachingproficiency", "Lev2_count",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "atproficiency", "Lev3_count",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "aboveproficiency", "Lev4_count",.)
					
					if "`SG'" != "Overall"{
						if "`var'" != "B" rename `var' `newvar'
						if "`var'" == "B" rename `var' StudentSubGroup
					}
					if "`SG'" == "Overall"{
						rename `var' `newvar'
					}
					}
					if "`SG'" == "Overall"{
						gen StudentSubGroup = "All Students"
					}
				drop in 1
				gen DataLevel = "State"
				gen Subject = "`Subject'"
				append using "`tempstate'"
				save "`tempstate'", replace
				clear
			}
	}

use "`tempstate'"
rename proficient ProficientOrAbove_count
rename tested StudentSubGroup_TotalTested
rename proficient_per ProficientOrAbove_percent
rename grade GradeLevel
save "${temp}/`year'_State_sci_soc", replace
clear				
}

///All Students Values

//2014-16
forvalues year = 2014/2016{
	foreach Subject in SCIENCE SS{
		foreach DataLevel in SCH CORP {
			import excel "$Original/Science + Social Studies/IN_`year'_sci_soc_allstud.xlsx", sheet("`year'_`Subject'_`DataLevel'") clear
			if "`DataLevel'" == "SCH"{
				if `year' < 2016{
					rename A idoe_school_id
					rename B school_name
					rename C idoe_corporation_id
					rename D corporation_name
				}
				if `year' == 2016{
					rename A idoe_corporation_id
					rename B corporation_name
					rename C idoe_school_id
					rename D school_name
					
				}
				if "`Subject'" == "SCIENCE"{
					rename E ProficientOrAbove_countG04
					rename F ProficientOrAbove_percentG04
					rename G ProficientOrAbove_countG06
					rename H ProficientOrAbove_percentG06
					rename I ProficientOrAbove_countG38
					rename J ProficientOrAbove_percentG38
				}
				if "`Subject'" == "SS"{
					rename E ProficientOrAbove_countG05
					rename F ProficientOrAbove_percentG05
					rename G ProficientOrAbove_countG07
					rename H ProficientOrAbove_percentG07
					rename I ProficientOrAbove_countG38
					rename J ProficientOrAbove_percentG38
				}
			}
			if "`DataLevel'" == "CORP"{
				rename A idoe_corporation_id
				rename B corporation_name
				if "`Subject'" == "SCIENCE"{
					rename C ProficientOrAbove_countG04
					rename D ProficientOrAbove_percentG04
					rename E ProficientOrAbove_countG06
					rename F ProficientOrAbove_percentG06
					rename G ProficientOrAbove_countG38
					rename H ProficientOrAbove_percentG38
				}
				if "`Subject'" == "SS"{
					rename C ProficientOrAbove_countG05
					rename D ProficientOrAbove_percentG05
					rename E ProficientOrAbove_countG07
					rename F ProficientOrAbove_percentG07
					rename G ProficientOrAbove_countG38
					rename H ProficientOrAbove_percentG38
				}
			}
			gen Subject = "`Subject'"
			gen DataLevel = "`DataLevel'"
			gen StudentSubGroup = "All Students"
			drop if _n < 3
			save "$temp/IN_`year'_`Subject'_`DataLevel'", replace
		}
	}
	use "$temp/IN_`year'_SCIENCE_SCH", clear
	append using "$temp/IN_`year'_SCIENCE_CORP" "$temp/IN_`year'_SS_SCH" "$temp/IN_`year'_SS_CORP"
	drop if corporation_name == "" & school_name == ""
	reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(idoe_corporation_id idoe_school_id Subject) j(GradeLevel) string
	drop if ProficientOrAbove_count == "" & ProficientOrAbove_percent == ""
	save "$temp/IN_`year'_sci_soc_DistSchool_allstud", replace
}

//2017
foreach Subject in Science Social_Studies {
	foreach DataLevel in School Corp {
		if "`DataLevel'" == "School" & "`Subject'" == "Science" import excel "$Original/Science + Social Studies/IN_2017_sci_soc_allstud.xlsx", sheet("2017_Science_school") clear
			else if "`DataLevel'" == "Corp" & "`Subject'" == "Social_Studies" import excel "$Original/Science + Social Studies/IN_2017_sci_soc_allstud.xlsx", sheet("2017 Social_Studies_Corp") clear
			else import excel "$Original/Science + Social Studies/IN_2017_sci_soc_allstud.xlsx", sheet("2017_`Subject'_`DataLevel'") clear
			if "`DataLevel'" == "School"{
				rename A idoe_corporation_id
				rename B corporation_name
				rename C idoe_school_id
				rename D school_name
				if "`Subject'" == "Science"{
					rename E ProficientOrAbove_countG04
					rename F ProficientOrAbove_percentG04
					rename G ProficientOrAbove_countG06
					rename H ProficientOrAbove_percentG06
					rename I ProficientOrAbove_countG38
					rename J ProficientOrAbove_percentG38
				}
				if "`Subject'" == "Social_Studies"{
					rename E ProficientOrAbove_countG05
					rename F ProficientOrAbove_percentG05
					rename G ProficientOrAbove_countG07
					rename H ProficientOrAbove_percentG07
					rename I ProficientOrAbove_countG38
					rename J ProficientOrAbove_percentG38
				}
			}
			if "`DataLevel'" == "Corp"{
				rename A idoe_corporation_id
				rename B corporation_name
				if "`Subject'" == "Science"{
					rename C ProficientOrAbove_countG04
					rename D ProficientOrAbove_percentG04
					rename E ProficientOrAbove_countG06
					rename F ProficientOrAbove_percentG06
					rename G ProficientOrAbove_countG38
					rename H ProficientOrAbove_percentG38
				}
				if "`Subject'" == "Social_Studies"{
					rename C ProficientOrAbove_countG05
					rename D ProficientOrAbove_percentG05
					rename E ProficientOrAbove_countG07
					rename F ProficientOrAbove_percentG07
					rename G ProficientOrAbove_countG38
					rename H ProficientOrAbove_percentG38
				}
			}
			gen Subject = "`Subject'"
			gen DataLevel = "`DataLevel'"
			gen StudentSubGroup = "All Students"
			drop if _n < 3
			save "$temp/IN_2017_`Subject'_`DataLevel'", replace
		}
	}
use "$temp/IN_2017_Science_School", clear
append using "$temp/IN_2017_Science_Corp" "$temp/IN_2017_Social_Studies_School" "$temp/IN_2017_Social_Studies_Corp"
drop if corporation_name == "" & school_name == ""
reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(idoe_corporation_id idoe_school_id Subject) j(GradeLevel) string
drop if ProficientOrAbove_count == "" & ProficientOrAbove_percent == ""
save "$temp/IN_2017_sci_soc_DistSchool_allstud", replace


//2018
foreach Subject in Science Social_Studies {
		foreach DataLevel in School Corp {
			if "`DataLevel'" == "Corp" & "`Subject'" == "Social_Studies" import excel "$Original/Science + Social Studies/IN_2018_sci_soc_allstud.xlsx", sheet("2018 Social_Studies_Corp") clear
			else import excel "$Original/Science + Social Studies/IN_2018_sci_soc_allstud.xlsx", sheet("2018_`Subject'_`DataLevel'") clear
			if "`DataLevel'" == "School"{
				rename A idoe_corporation_id
				rename B corporation_name
				rename C idoe_school_id
				rename D school_name
				if "`Subject'" == "Science"{
					rename E ProficientOrAbove_countG04
					rename F StudentSubGroup_TotalTestedG04
					rename G ProficientOrAbove_percentG04
					rename H ProficientOrAbove_countG06
					rename I StudentSubGroup_TotalTestedG06
					rename J ProficientOrAbove_percentG06
					rename K ProficientOrAbove_countG38
					rename L StudentSubGroup_TotalTestedG38
					rename M ProficientOrAbove_percentG38
				}
				if "`Subject'" == "Social_Studies"{
					rename E ProficientOrAbove_countG05
					rename F StudentSubGroup_TotalTestedG05
					rename G ProficientOrAbove_percentG05
					rename H ProficientOrAbove_countG07
					rename I StudentSubGroup_TotalTestedG07
					rename J ProficientOrAbove_percentG07
					rename K ProficientOrAbove_countG38
					rename L StudentSubGroup_TotalTestedG38
					rename M ProficientOrAbove_percentG38
				}
			}
			if "`DataLevel'" == "Corp"{
				rename A idoe_corporation_id
				rename B corporation_name
				if "`Subject'" == "Science"{
					rename C ProficientOrAbove_countG04
					rename D StudentSubGroup_TotalTestedG04
					rename E ProficientOrAbove_percentG04
					rename F ProficientOrAbove_countG06
					rename G StudentSubGroup_TotalTestedG06
					rename H ProficientOrAbove_percentG06
					rename I ProficientOrAbove_countG38
					rename J StudentSubGroup_TotalTestedG38
					rename K ProficientOrAbove_percentG38
				}
				if "`Subject'" == "Social_Studies"{
					rename C ProficientOrAbove_countG05
					rename D StudentSubGroup_TotalTestedG05
					rename E ProficientOrAbove_percentG05
					rename F ProficientOrAbove_countG07
					rename G StudentSubGroup_TotalTestedG07
					rename H ProficientOrAbove_percentG07
					rename I ProficientOrAbove_countG38
					rename J StudentSubGroup_TotalTestedG38
					rename K ProficientOrAbove_percentG38
				}
			}
			gen Subject = "`Subject'"
			gen DataLevel = "`DataLevel'"
			gen StudentSubGroup = "All Students"
			drop if _n < 3
			save "$temp/IN_2018_`Subject'_`DataLevel'", replace
		}
	}
use "$temp/IN_2018_Science_School", clear
append using "$temp/IN_2018_Science_Corp" "$temp/IN_2018_Social_Studies_School" "$temp/IN_2018_Social_Studies_Corp"
drop if corporation_name == "" & school_name == ""
reshape long ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(idoe_corporation_id idoe_school_id Subject) j(GradeLevel) string
drop if ProficientOrAbove_count == "" & ProficientOrAbove_percent == "" & StudentSubGroup_TotalTested == ""
save "$temp/IN_2018_sci_soc_DistSchool_allstud", replace

//2019-2023
forvalues year = 2019/2023{
	if `year' == 2020 continue
	foreach Subject in "Science" "Social Studies"{
		foreach DataLevel in LEA SCH{
			import excel "$Original/IN_`year'_`DataLevel'_allstud.xlsx", sheet("`Subject'") clear
			if "`DataLevel'" == "LEA"{
				rename A idoe_corporation_id
				rename B corporation_name
				if "`Subject'" == "Science"{
					rename C Lev1_countG04
					rename D Lev2_countG04
					rename E Lev3_countG04
					rename F Lev4_countG04
					rename G ProficientOrAbove_countG04
					rename H StudentSubGroup_TotalTestedG04
					rename I ProficientOrAbove_percentG04
					rename J Lev1_countG06
					rename K Lev2_countG06
					rename L Lev3_countG06
					rename M Lev4_countG06
					rename N ProficientOrAbove_countG06
					rename O StudentSubGroup_TotalTestedG06
					rename P ProficientOrAbove_percentG06
					rename Q Lev1_countG38
					rename R Lev2_countG38
					rename S Lev3_countG38
					rename T Lev4_countG38
					rename U ProficientOrAbove_countG38
					rename V StudentSubGroup_TotalTestedG38
					rename W ProficientOrAbove_percentG38
					drop X
					reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(idoe_corporation_id) j(GradeLevel) string
				}
				if "`Subject'" == "Social Studies"{
					rename C Lev1_count
					rename D Lev2_count
					rename E Lev3_count
					rename F Lev4_count
					rename G ProficientOrAbove_count
					rename H StudentSubGroup_TotalTested
					rename I ProficientOrAbove_percent
					drop J
					gen GradeLevel = "G05"
				}
			}
			if "`DataLevel'" == "SCH"{
				rename A idoe_corporation_id
				rename B corporation_name
				rename C idoe_school_id
				rename D school_name
				if "`Subject'" == "Science"{
					rename E Lev1_countG04
					rename F Lev2_countG04
					rename G Lev3_countG04
					rename H Lev4_countG04
					rename I ProficientOrAbove_countG04
					rename J StudentSubGroup_TotalTestedG04
					rename K ProficientOrAbove_percentG04
					rename L Lev1_countG06
					rename M Lev2_countG06
					rename N Lev3_countG06
					rename O Lev4_countG06
					rename P ProficientOrAbove_countG06
					rename Q StudentSubGroup_TotalTestedG06
					rename R ProficientOrAbove_percentG06
					rename S Lev1_countG38
					rename T Lev2_countG38
					rename U Lev3_countG38
					rename V Lev4_countG38
					rename W ProficientOrAbove_countG38
					rename X StudentSubGroup_TotalTestedG38
					rename Y ProficientOrAbove_percentG38
					drop Z
					reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(idoe_corporation_id idoe_school_id) j(GradeLevel) string
				}
				if "`Subject'" == "Social Studies"{
					rename E Lev1_count
					rename F Lev2_count
					rename G Lev3_count
					rename H Lev4_count
					rename I ProficientOrAbove_count
					rename J StudentSubGroup_TotalTested
					rename K ProficientOrAbove_percent
					drop L
					gen GradeLevel = "G05"
				}
			}
			gen Subject = "`Subject'"
			gen DataLevel = "`DataLevel'"
			gen StudentSubGroup = "All Students"
			drop if _n < 5
			save "$temp/IN_`year'_`Subject'_`DataLevel'", replace
		}
	}
	use "$temp/IN_`year'_Science_SCH", clear
	append using "$temp/IN_`year'_Science_LEA" "$temp/IN_`year'_Social Studies_SCH" "$temp/IN_`year'_Social Studies_LEA"
	drop if corporation_name == "" & school_name == ""
	drop if Lev1_count == "" & Lev2_count == "" & Lev3_count == "" & Lev4_count == "" & ProficientOrAbove_count == "" & StudentSubGroup_TotalTested == "" & ProficientOrAbove_percent == ""
	save "$temp/IN_`year'_sci_soc_DistSchool_allstud", replace
}

forvalues year = 2014/2023{
	if `year' == 2020 continue
	use "${temp}/`year'_State_sci_soc", clear
	append using "$temp/`year'_District_school_sci_soc"
	append using "$temp/IN_`year'_sci_soc_DistSchool_allstud"
	save "${temp}/IN_`year'_sci_soc", replace
}

// Finish Compiling 2024 Data
import excel using "${Original}/Science + Social Studies/IN_2024_SEA_Science_ILEARN.xlsx", sheet("Science ACTIVE DUTY") clear
foreach var of varlist _all {
	local newvar = `var'[1]
	local newvar = subinstr("`newvar'", " ", "",.)
	local newvar = lower("`newvar'")
	local newvar = subinstr("`newvar'", "%", "_per",.)
	local newvar = subinstr("`newvar'", "belowproficiency", "Lev1_count",.)
	local newvar = subinstr("`newvar'", "approachingproficiency", "Lev2_count",.)
	local newvar = subinstr("`newvar'", "atproficiency", "Lev3_count",.)
	local newvar = subinstr("`newvar'", "aboveproficiency", "Lev4_count",.)
	if "`var'" != "B" rename `var' `newvar'
	if "`var'" == "B" rename `var' StudentSubGroup
}
drop if _n == 1
rename grade GradeLevel
rename tested StudentSubGroup_TotalTested
rename proficient ProficientOrAbove_count
rename proficient_per ProficientOrAbove_percent
gen DataLevel = "State"
gen Subject = "Science"
append using "${temp}/2024_State_sci_soc" "${temp}/2024_District_school_sci_soc"
save "$temp/IN_2024_sci_soc", replace
