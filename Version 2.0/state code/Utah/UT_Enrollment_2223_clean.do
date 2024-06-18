clear
set more off

global raw "/Users/miramehta/Documents/UT State Testing Data/Original Data"
global output "/Users/miramehta/Documents/UT State Testing Data/Output"
global int "/Users/miramehta/Documents/UT State Testing Data/Intermediate"

global nces "/Users/miramehta/Documents/NCES District and School Demographics"
global utah "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

global edfacts "/Users/miramehta/Documents/EdFacts"

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
			rename Grade_ StudentSubGroup_TotalTested

			tostring GradeLevel, replace

			foreach x of numlist 3/8 {
				replace GradeLevel="G0`x'" if strpos(GradeLevel, "`x'")>0
			}

			gen DataLevel=3
			gen StudentSubGroup="All Students"
			
			merge m:1 SchName DistName using "${utah}/NCES_2022_School.dta"
			drop if _merge != 3
			drop _merge

			save "${raw}/UT_Enrollment_`dl'_`year'.dta", replace
			
		}
		
		if "`dl'"=="LEA" {
			
			keep SchoolYear LEAName Grade_3 Grade_4 Grade_5 Grade_6 Grade_7 Grade_8

			reshape long Grade_, i(LEAName) j(Grade)

			rename LEAName DistName
			rename Grade GradeLevel
			rename Grade_ StudentSubGroup_TotalTested

			tostring GradeLevel, replace

			foreach x of numlist 3/8 {
				replace GradeLevel="G0`x'" if strpos(GradeLevel, "`x'")>0
			}

			gen DataLevel=2
			gen StudentSubGroup="All Students"
			
			merge m:1 DistName using "${utah}/NCES_2022_District.dta"
			drop if _merge != 3
			drop _merge

			save "${raw}/UT_Enrollment_`dl'_`year'.dta", replace
			
		}
		
	}
	
	import excel "${raw}/UT_OriginalData_Enrollment_`year'.xlsx", sheet("State") firstrow allstring clear
	
	drop if LEATYPE != "State Total"
	
	keep SchoolYear Grade_3 Grade_4 Grade_5 Grade_6 Grade_7 Grade_8

	reshape long Grade_, i(SchoolYear) j(Grade)
	
	rename Grade GradeLevel
	rename Grade_ StudentSubGroup_TotalTested
	
	tostring GradeLevel, replace

			foreach x of numlist 3/8 {
				replace GradeLevel="G0`x'" if strpos(GradeLevel, "`x'")>0
			}

			gen DataLevel=1
			gen StudentSubGroup="All Students"

			save "${raw}/UT_Enrollment_State_`year'.dta", replace
	
}
