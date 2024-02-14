clear
set more off

global raw "/Users/minnamgung/Desktop/SADR/Utah/Original Data Files"
global output "/Users/minnamgung/Desktop/SADR/Utah/Output"
global int "/Users/minnamgung/Desktop/SADR/Utah/Intermediate"

global nces "/Users/minnamgung/Desktop/SADR/NCES"
global utah "/Users/minnamgung/Desktop/SADR/Utah/NCES"

global edfacts "/Users/minnamgung/Desktop/EdFacts/Output"

import excel "/Users/minnamgung/Desktop/SADR/Utah/UT_Enrollment_Unmerged_2022_2023.xlsx", firstrow allstring clear

save "${raw}/UT_Enrollment_Unmerged_2022_2023.dta", replace

foreach year in 2022 2023 {
	
	foreach dl in School LEA {
		
		import excel "${raw}/UT_OriginalData_Enrollment_`year'.xlsx", sheet("By `dl'") firstrow allstring clear
		
		if "`dl'"=="School" {
			
			keep SchoolYear LEAName SchoolName Grade_3 Grade_4 Grade_5 Grade_6 Grade_7 Grade_8

			drop if SchoolName=="Minersville School"

			reshape long Grade_, i(LEAName SchoolName) j(Grade)

			rename LEAName DistName
			rename SchoolName SchName
			rename Grade GradeLevel
			rename Grade_ StudentGroup_TotalTested

			tostring GradeLevel, replace

			foreach x of numlist 3/8 {
				replace GradeLevel="G0`x'" if strpos(GradeLevel, "`x'")>0
			}

			gen DataLevel="School"
			gen StudentGroup="All Students"

			save "${raw}/UT_Enrollment_`dl'_`year'.dta", replace
			
		}
		
		if "`dl'"=="LEA" {
			
			keep SchoolYear LEAName Grade_3 Grade_4 Grade_5 Grade_6 Grade_7 Grade_8

			reshape long Grade_, i(LEAName) j(Grade)

			rename LEAName DistName
			rename Grade GradeLevel
			rename Grade_ StudentGroup_TotalTested

			tostring GradeLevel, replace

			foreach x of numlist 3/8 {
				replace GradeLevel="G0`x'" if strpos(GradeLevel, "`x'")>0
			}

			gen DataLevel="District"
			gen StudentGroup="All Students"

			save "${raw}/UT_Enrollment_`dl'_`year'.dta", replace
			
		}
		
	}
	
	import excel "${raw}/UT_OriginalData_Enrollment_`year'.xlsx", sheet("State") firstrow allstring clear
	
	drop if LEATYPE != "State Total"
	
	keep SchoolYear Grade_3 Grade_4 Grade_5 Grade_6 Grade_7 Grade_8

	reshape long Grade_, i(SchoolYear) j(Grade)
	
	rename Grade GradeLevel
	rename Grade_ StudentGroup_TotalTested
	
	tostring GradeLevel, replace

			foreach x of numlist 3/8 {
				replace GradeLevel="G0`x'" if strpos(GradeLevel, "`x'")>0
			}

			gen DataLevel="State"
			gen StudentGroup="All Students"

			save "${raw}/UT_Enrollment_State_`year'.dta", replace
	
}
