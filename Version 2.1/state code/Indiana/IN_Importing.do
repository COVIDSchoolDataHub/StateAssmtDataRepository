clear
set more off
set trace off

global Original "/Users/miramehta/Documents/IN State Testing Data/Original Data Files"
global temp "/Users/miramehta/Documents/IN State Testing Data/Temp"
global Output "/Users/miramehta/Documents/IN State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

//Importing and Combining
local SubGroups1 "OVERALL ETHNICITY GENDER FRL SPED ELL FOSTER HOMELESS ACTIVE_DUTY"
local SubGroups2 "ETHNICITY GENDER FRL SPED ELL"

forvalues year = 2014/2024 {

if `year' == 2020 continue

	tempfile tempdistschool
	save "`tempdistschool'", replace emptyok
	clear
	
	foreach Subject in ELA MATH {
		foreach DataLevel in LEA SCH {
				foreach SG of local SubGroups2 {
					if `year' < 2019 import excel using "${Original}/ELA + Math/IN_`year'_`DataLevel'_`Subject'_ISTEP.xlsx", sheet("`Subject'_`SG'") clear
					else if `year' > 2018 & `year' != 2024 import excel using "${Original}/ELA + Math/IN_`year'_`DataLevel'_`Subject'_ILEARN.xlsx", sheet("`Subject'_`SG'") clear
					else if `year' == 2024 & "`DataLevel'" == "LEA" & "`SG'" != "ELL" import excel using "${Original}/ELA + Math/IN_`year'_`DataLevel'_`Subject'_ILEARN.xlsx", sheet("`Subject' `SG'") clear
					else import excel using "${Original}/ELA + Math/IN_`year'_`DataLevel'_`Subject'_ILEARN.xlsx", sheet("`Subject'_`SG'") clear
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
						if `year' < 2019 local newvar = subinstr("`newvar'", "belowproficiency", "Lev1_count_",.)
						if `year' < 2019 local newvar = subinstr("`newvar'", "atproficiency", "Lev2_count_",.)
						if `year' < 2019 local newvar = subinstr("`newvar'", "aboveproficiency", "Lev3_count_",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "belowproficiency", "Lev1_count_",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "approachingproficiency", "Lev2_count_",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "atproficiency", "Lev3_count_",.)
						if `year' > 2018 local newvar = subinstr("`newvar'", "aboveproficiency", "Lev4_count_",.)
						
						
						
						
						rename `var' `newvar'
					}
					drop in 1/2
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
				if "`DataLevel'" == "LEA" & `year' < 2019 {
					reshape long tested Lev1_count Lev2_count Lev3_count proficient proficient_per, i(idoe_corporation_id grade) j(StudentSubGroup) string
				}
				if "`DataLevel'" == "SCH" & `year' < 2019 {
					reshape long tested Lev1_count Lev2_count Lev3_count proficient proficient_per, i(idoe_corporation_id idoe_school_id grade) j(StudentSubGroup) string
				}
				if "`DataLevel'" == "LEA" & `year' > 2018 {
					reshape long tested Lev1_count Lev2_count Lev3_count Lev4_count proficient proficient_per, i(idoe_corporation_id grade) j(StudentSubGroup) string
				}
				if "`DataLevel'" == "SCH" & `year' > 2018 {
					reshape long tested Lev1_count Lev2_count Lev3_count Lev4_count proficient proficient_per, i(idoe_corporation_id idoe_school_id grade) j(StudentSubGroup) string
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
save "${temp}/`year'_District_School_ela_mat", replace
clear

	
	tempfile tempstate
	save "`tempstate'", emptyok replace
	foreach Subject in ELA MATH {
			foreach SG of local SubGroups1 {
				if `year' == 2024 & "`SG'" == "FOSTER" continue
				local sg = strproper("`SG'")
					if `year' < 2019 import excel using "${Original}/ELA + Math/IN_`year'_SEA_`Subject'_ISTEP.xlsx", sheet("`Subject'_`SG'") clear
					else if `year' > 2018 & `year' != 2024 import excel using "${Original}/ELA + Math/IN_`year'_SEA_`Subject'_ILEARN.xlsx", sheet("`Subject'_`SG'") clear
					else if `year' == 2024 & inlist("`SG'", "OVERALL", "ETHNICITY", "GENDER") import excel using "${Original}/ELA + Math/IN_`year'_SEA_`Subject'_ILEARN.xlsx", sheet("`Subject' `sg'") clear
					else if `year' == 2024 & "`Subject'" == "ELA" & inlist("`SG'", "ELL", "HOMELESS") import excel using "${Original}/ELA + Math/IN_`year'_SEA_`Subject'_ILEARN.xlsx", sheet("`Subject'_`SG'") clear
					else if `year' == 2024 & "`Subject'" == "ELA" & "`SG'" == "ACTIVE_DUTY" import excel using "${Original}/ELA + Math/IN_`year'_SEA_`Subject'_ILEARN.xlsx", sheet("ELA_ACTIVE DUTY") clear
					else if `year' == 2024 & "`Subject'" == "MATH" & "`SG'" == "ACTIVE_DUTY" import excel using "${Original}/ELA + Math/IN_`year'_SEA_`Subject'_ILEARN.xlsx", sheet("MATH ACTIVE DUTY") clear
					else import excel using "${Original}/ELA + Math/IN_`year'_SEA_`Subject'_ILEARN.xlsx", sheet("`Subject' `SG'") clear
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
					
					if "`SG'" != "OVERALL"{
						if "`var'" != "B" rename `var' `newvar'
						if "`var'" == "B" rename `var' StudentSubGroup
					}
					if "`SG'" == "OVERALL"{
						rename `var' `newvar'
					}
					}
					if "`SG'" == "OVERALL"{
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
rename proficient_per* proficient_per*
rename proficient ProficientOrAbove_count
rename tested StudentSubGroup_TotalTested
rename proficient_per ProficientOrAbove_percent
rename grade GradeLevel
save "${temp}/`year'_State_ela_mat", replace
clear				
}


/// All Students Data
//2014-2016
forvalues year = 2014/2016{
	foreach DataLevel in LEA SCH {
		import excel "$Original/ELA + Math/IN_`year'_`DataLevel'_allstud_ela_mat.xlsx", sheet("Spring `year'") clear
		if "`DataLevel'" == "LEA"{
			rename A idoe_corporation_id
			rename B corporation_name
			rename C ProficientOrAbove_countELAG03
			rename D ProficientOrAbove_percentELAG03
			rename E ProficientOrAbove_countmathG03
			rename F ProficientOrAbove_percentmathG03
			rename H ProficientOrAbove_countELAG04
			rename I ProficientOrAbove_percentELAG04
			rename J ProficientOrAbove_countmathG04
			rename K ProficientOrAbove_percentmathG04
			rename M ProficientOrAbove_countELAG05
			rename N ProficientOrAbove_percentELAG05
			rename O ProficientOrAbove_countmathG05
			rename P ProficientOrAbove_percentmathG05
			rename R ProficientOrAbove_countELAG06
			rename S ProficientOrAbove_percentELAG06
			rename T ProficientOrAbove_countmathG06
			rename U ProficientOrAbove_percentmathG06
			rename W ProficientOrAbove_countELAG07
			rename X ProficientOrAbove_percentELAG07
			rename Y ProficientOrAbove_countmathG07
			rename Z ProficientOrAbove_percentmathG07
			rename AB ProficientOrAbove_countELAG08
			rename AC ProficientOrAbove_percentELAG08
			rename AD ProficientOrAbove_countmathG08
			rename AE ProficientOrAbove_percentmathG08
			rename AG ProficientOrAbove_countELAG38
			rename AH ProficientOrAbove_percentELAG38
			rename AI ProficientOrAbove_countmathG38
			rename AJ ProficientOrAbove_percentmathG38
			drop G L Q V AA AF AK
			drop if inlist(corporation_name, "", "Corp Name")
			reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(idoe_corporation_id) j(GradeLevel) string
			gen Subject = "ELA" if strpos(GradeLevel, "ELA") != 0
			replace Subject = "math" if strpos(GradeLevel, "math") != 0
			replace GradeLevel = subinstr(GradeLevel, Subject, "", 1)
		}
		if "`DataLevel'" == "SCH"{
			rename A idoe_corporation_id
			rename B corporation_name
			rename C idoe_school_id
			rename D school_name
			rename E ProficientOrAbove_countELAG03
			rename F ProficientOrAbove_percentELAG03
			rename G ProficientOrAbove_countmathG03
			rename H ProficientOrAbove_percentmathG03
			rename J ProficientOrAbove_countELAG04
			rename K ProficientOrAbove_percentELAG04
			rename L ProficientOrAbove_countmathG04
			rename M ProficientOrAbove_percentmathG04
			rename O ProficientOrAbove_countELAG05
			rename P ProficientOrAbove_percentELAG05
			rename Q ProficientOrAbove_countmathG05
			rename R ProficientOrAbove_percentmathG05
			rename T ProficientOrAbove_countELAG06
			rename U ProficientOrAbove_percentELAG06
			rename V ProficientOrAbove_countmathG06
			rename W ProficientOrAbove_percentmathG06
			rename Y ProficientOrAbove_countELAG07
			rename Z ProficientOrAbove_percentELAG07
			rename AA ProficientOrAbove_countmathG07
			rename AB ProficientOrAbove_percentmathG07
			rename AD ProficientOrAbove_countELAG08
			rename AE ProficientOrAbove_percentELAG08
			rename AF ProficientOrAbove_countmathG08
			rename AG ProficientOrAbove_percentmathG08
			rename AI ProficientOrAbove_countELAG38
			rename AJ ProficientOrAbove_percentELAG38
			rename AK ProficientOrAbove_countmathG38
			rename AL ProficientOrAbove_percentmathG38
			drop I N S X AC AH AM
			drop if inlist(corporation_name, "", "Corp Name")
			reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(idoe_corporation_id idoe_school_id) j(GradeLevel) string
			gen Subject = "ELA" if strpos(GradeLevel, "ELA") != 0
			replace Subject = "math" if strpos(GradeLevel, "math") != 0
			replace GradeLevel = subinstr(GradeLevel, Subject, "", 1)
		}
		gen DataLevel = "`DataLevel'"
		gen StudentSubGroup = "All Students"
		save "$temp/IN_`year'_ela_mat_`DataLevel'", replace
		}
	use "$temp/IN_`year'_ela_mat_LEA", clear
	append using "$temp/IN_`year'_ela_mat_SCH"
	save "$temp/IN_`year'_ela_mat_allstud", replace
}

//2017-2018
forvalues year = 2017/2018{
	foreach DataLevel in LEA SCH {
		import excel "$Original/ELA + Math/IN_`year'_`DataLevel'_allstud_ela_mat.xlsx", sheet("Spring `year'") clear
		if "`DataLevel'" == "LEA"{
			rename A idoe_corporation_id
			rename B corporation_name
			rename C ProficientOrAbove_countELAG03
			rename D testedELAG03
			rename E ProficientOrAbove_percentELAG03
			rename F ProficientOrAbove_countmathG03
			rename G testedmathG03
			rename H ProficientOrAbove_percentmathG03
			rename L ProficientOrAbove_countELAG04
			rename M testedELAG04
			rename N ProficientOrAbove_percentELAG04
			rename O ProficientOrAbove_countmathG04
			rename P testedmathG04
			rename Q ProficientOrAbove_percentmathG04
			rename U ProficientOrAbove_countELAG05
			rename V testedELAG05
			rename W ProficientOrAbove_percentELAG05
			rename X ProficientOrAbove_countmathG05
			rename Y testedmathG05
			rename Z ProficientOrAbove_percentmathG05
			rename AD ProficientOrAbove_countELAG06
			rename AE testedELAG06
			rename AF ProficientOrAbove_percentELAG06
			rename AG ProficientOrAbove_countmathG06
			rename AH testedmathG06
			rename AI ProficientOrAbove_percentmathG06
			rename AM ProficientOrAbove_countELAG07
			rename AN testedELAG07
			rename AO ProficientOrAbove_percentELAG07
			rename AP ProficientOrAbove_countmathG07
			rename AQ testedmathG07
			rename AR ProficientOrAbove_percentmathG07
			rename AV ProficientOrAbove_countELAG08
			rename AW testedELAG08
			rename AX ProficientOrAbove_percentELAG08
			rename AY ProficientOrAbove_countmathG08
			rename AZ testedmathG08
			rename BA ProficientOrAbove_percentmathG08
			rename BE ProficientOrAbove_countELAG38
			rename BF testedELAG38
			rename BG ProficientOrAbove_percentELAG38
			rename BH ProficientOrAbove_countmathG38
			rename BI testedmathG38
			rename BJ ProficientOrAbove_percentmathG38
			drop I J K R S T AA AB AC AJ AK AL AS AT AU BB BC BD BK BL BM
			drop if inlist(corporation_name, "", "Corp Name")
			reshape long tested ProficientOrAbove_count ProficientOrAbove_percent, i(idoe_corporation_id) j(GradeLevel) string
			gen Subject = "ELA" if strpos(GradeLevel, "ELA") != 0
			replace Subject = "math" if strpos(GradeLevel, "math") != 0
			replace GradeLevel = subinstr(GradeLevel, Subject, "", 1)
			rename tested StudentSubGroup_TotalTested
		}
		if "`DataLevel'" == "SCH"{
			rename A idoe_corporation_id
			rename B corporation_name
			rename C idoe_school_id
			rename D school_name
			rename E ProficientOrAbove_countELAG03
			rename F testedELAG03
			rename G ProficientOrAbove_percentELAG03
			rename H ProficientOrAbove_countmathG03
			rename I testedmathG03
			rename J ProficientOrAbove_percentmathG03
			rename N ProficientOrAbove_countELAG04
			rename O testedELAG04
			rename P ProficientOrAbove_percentELAG04
			rename Q ProficientOrAbove_countmathG04
			rename R testedmathG04
			rename S ProficientOrAbove_percentmathG04
			rename W ProficientOrAbove_countELAG05
			rename X testedELAG05
			rename Y ProficientOrAbove_percentELAG05
			rename Z ProficientOrAbove_countmathG05
			rename AA testedmathG05
			rename AB ProficientOrAbove_percentmathG05
			rename AF ProficientOrAbove_countELAG06
			rename AG testedELAG06
			rename AH ProficientOrAbove_percentELAG06
			rename AI ProficientOrAbove_countmathG06
			rename AJ testedmathG06
			rename AK ProficientOrAbove_percentmathG06
			rename AO ProficientOrAbove_countELAG07
			rename AP testedELAG07
			rename AQ ProficientOrAbove_percentELAG07
			rename AR ProficientOrAbove_countmathG07
			rename AS testedmathG07
			rename AT ProficientOrAbove_percentmathG07
			rename AX ProficientOrAbove_countELAG08
			rename AY testedELAG08
			rename AZ ProficientOrAbove_percentELAG08
			rename BA ProficientOrAbove_countmathG08
			rename BB testedmathG08
			rename BC ProficientOrAbove_percentmathG08
			rename BG ProficientOrAbove_countELAG38
			rename BH testedELAG38
			rename BI ProficientOrAbove_percentELAG38
			rename BJ ProficientOrAbove_countmathG38
			rename BK testedmathG38
			rename BL ProficientOrAbove_percentmathG38
			drop K L M T U V AC AD AE AL AM AN AU AV AW BD BE BF BM BN BO
			drop if inlist(corporation_name, "", "Corp Name")
			reshape long tested ProficientOrAbove_count ProficientOrAbove_percent, i(idoe_corporation_id idoe_school_id) j(GradeLevel) string
			gen Subject = "ELA" if strpos(GradeLevel, "ELA") != 0
			replace Subject = "math" if strpos(GradeLevel, "math") != 0
			replace GradeLevel = subinstr(GradeLevel, Subject, "", 1)
			rename tested StudentSubGroup_TotalTested
		}
		gen DataLevel = "`DataLevel'"
		gen StudentSubGroup = "All Students"
		save "$temp/IN_`year'_ela_mat_`DataLevel'", replace
		}
	use "$temp/IN_`year'_ela_mat_LEA", clear
	append using "$temp/IN_`year'_ela_mat_SCH"
	replace idoe_corporation_id = "0" + idoe_corporation_id if strlen(idoe_corporation_id) == 3
	replace idoe_corporation_id = "00" + idoe_corporation_id if strlen(idoe_corporation_id) == 2
	replace idoe_school_id = "0" + idoe_school_id if strlen(idoe_school_id) == 3
	replace idoe_school_id = "00" + idoe_school_id if strlen(idoe_school_id) == 2
	save "$temp/IN_`year'_ela_mat_allstud", replace
}

//2019-2024
forvalues year = 2019/2024{
	if `year' == 2020 continue
	foreach Subject in "ELA" "Math"{
		foreach DataLevel in LEA SCH {
			import excel "$Original/IN_`year'_`DataLevel'_allstud.xlsx", sheet("`Subject'") clear
			if "`DataLevel'" == "LEA"{
				rename A idoe_corporation_id
				rename B corporation_name
				rename C Lev1_countG03
				rename D Lev2_countG03
				rename E Lev3_countG03
				rename F Lev4_countG03
				rename G ProficientOrAbove_countG03
				rename H StudentSubGroup_TotalTestedG03
				rename I ProficientOrAbove_percentG03
				rename J Lev1_countG04
				rename K Lev2_countG04
				rename L Lev3_countG04
				rename M Lev4_countG04
				rename N ProficientOrAbove_countG04
				rename O StudentSubGroup_TotalTestedG04
				rename P ProficientOrAbove_percentG04
				rename Q Lev1_countG05
				rename R Lev2_countG05
				rename S Lev3_countG05
				rename T Lev4_countG05
				rename U ProficientOrAbove_countG05
				rename V StudentSubGroup_TotalTestedG05
				rename W ProficientOrAbove_percentG05
				rename X Lev1_countG06
				rename Y Lev2_countG06
				rename Z Lev3_countG06
				rename AA Lev4_countG06
				rename AB ProficientOrAbove_countG06
				rename AC StudentSubGroup_TotalTestedG06
				rename AD ProficientOrAbove_percentG06
				rename AE Lev1_countG07
				rename AF Lev2_countG07
				rename AG Lev3_countG07
				rename AH Lev4_countG07
				rename AI ProficientOrAbove_countG07
				rename AJ StudentSubGroup_TotalTestedG07
				rename AK ProficientOrAbove_percentG07
				rename AL Lev1_countG08
				rename AM Lev2_countG08
				rename AN Lev3_countG08
				rename AO Lev4_countG08
				rename AP ProficientOrAbove_countG08
				rename AQ StudentSubGroup_TotalTestedG08
				rename AR ProficientOrAbove_percentG08
				rename AS Lev1_countG38
				rename AT Lev2_countG38
				rename AU Lev3_countG38
				rename AV Lev4_countG38
				rename AW ProficientOrAbove_countG38
				rename AX StudentSubGroup_TotalTestedG38
				rename AY ProficientOrAbove_percentG38
				drop AZ
				
				drop if corporation_name == ""
				
				reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(idoe_corporation_id) j(GradeLevel) string
				}
				
			if "`DataLevel'" == "SCH"{
				rename A idoe_corporation_id
				rename B corporation_name
				rename C idoe_school_id
				rename D school_name
				rename E Lev1_countG03
				rename F Lev2_countG03
				rename G Lev3_countG03
				rename H Lev4_countG03
				rename I ProficientOrAbove_countG03
				rename J StudentSubGroup_TotalTestedG03
				rename K ProficientOrAbove_percentG03
				rename L Lev1_countG04
				rename M Lev2_countG04
				rename N Lev3_countG04
				rename O Lev4_countG04
				rename P ProficientOrAbove_countG04
				rename Q StudentSubGroup_TotalTestedG04
				rename R ProficientOrAbove_percentG04
				rename S Lev1_countG05
				rename T Lev2_countG05
				rename U Lev3_countG05
				rename V Lev4_countG05
				rename W ProficientOrAbove_countG05
				rename X StudentSubGroup_TotalTestedG05
				rename Y ProficientOrAbove_percentG05
				rename Z Lev1_countG06
				rename AA Lev2_countG06
				rename AB Lev3_countG06
				rename AC Lev4_countG06
				rename AD ProficientOrAbove_countG06
				rename AE StudentSubGroup_TotalTestedG06
				rename AF ProficientOrAbove_percentG06
				rename AG Lev1_countG07
				rename AH Lev2_countG07
				rename AI Lev3_countG07
				rename AJ Lev4_countG07
				rename AK ProficientOrAbove_countG07
				rename AL StudentSubGroup_TotalTestedG07
				rename AM ProficientOrAbove_percentG07
				rename AN Lev1_countG08
				rename AO Lev2_countG08
				rename AP Lev3_countG08
				rename AQ Lev4_countG08
				rename AR ProficientOrAbove_countG08
				rename AS StudentSubGroup_TotalTestedG08
				rename AT ProficientOrAbove_percentG08
				rename AU Lev1_countG38
				rename AV Lev2_countG38
				rename AW Lev3_countG38
				rename AX Lev4_countG38
				rename AY ProficientOrAbove_countG38
				rename AZ StudentSubGroup_TotalTestedG38
				rename BA ProficientOrAbove_percentG38
				drop BB
				
				drop if corporation_name == ""
				
				reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(idoe_corporation_id idoe_school_id) j(GradeLevel) string
				}
				gen Subject = "`Subject'"
				gen DataLevel = "`DataLevel'"
				gen StudentSubGroup = "All Students"
				save "$temp/IN_`year'_`Subject'_`DataLevel'", replace
			}
	}
	use "$temp/IN_`year'_ELA_SCH", clear
	append using "$temp/IN_`year'_ELA_LEA" "$temp/IN_`year'_Math_SCH" "$temp/IN_`year'_Math_LEA"
	drop if corporation_name == "" & school_name == ""
	drop if Lev1_count == "" & Lev2_count == "" & Lev3_count == "" & Lev4_count == "" & ProficientOrAbove_count == "" & StudentSubGroup_TotalTested == "" & ProficientOrAbove_percent == ""
	save "$temp/IN_`year'_ela_mat_allstud", replace
}

//Append Data
forvalues year = 2014/2024{
	if `year' == 2020 continue
	use "$temp/`year'_State_ela_mat", clear
	append using "$temp/`year'_District_school_ela_mat" "$temp/IN_`year'_ela_mat_allstud" "$temp/IN_`year'_sci_soc"
	save "$temp/IN_`year'", replace
}
