clear
set more off

// global raw "/Users/minnamgung/Desktop/SADR/Iowa/Input"
// global output "/Users/minnamgung/Desktop/SADR/Iowa/Output"
// global int "/Users/minnamgung/Desktop/SADR/Iowa/Intermediate"
//
// global nces "/Users/minnamgung/Desktop/SADR/NCES"
// global iowa "/Users/minnamgung/Desktop/SADR/Iowa/NCES"

global iowa "/Users/benjaminm/Documents/State_Repository_Research/Iowa/NCES"
global nces "/Users/benjaminm/Documents/State_Repository_Research/NCES"
global raw "/Users/benjaminm/Documents/State_Repository_Research/Iowa/Input"
global dr "/Users/benjaminm/Documents/State_Repository_Research/Iowa/Input/Data Request"
global int "/Users/benjaminm/Documents/State_Repository_Research/Iowa/Intermediate"
global output "/Users/benjaminm/Documents/State_Repository_Research/Iowa/Output"
global output2 "/Users/benjaminm/Documents/State_Repository_Research/Iowa/Output - Version 1.0"

import delimited "${output2}/IA_AssmtData_2011", clear

/////////////////////////////////////////
*** NCES Cleaning for IA ***
/////////////////////////////////////////


/////////////////////////////////////////
*** Iowa District Saving 2014-2017***
/////////////////////////////////////////

program filesave11

	* ELA
	import excel "${raw}/Iowa - District/IA_OriginalData_`1'_district_all.`4'", sheet(`8') cellrange(`5':`2') firstrow clear

	gen Subject="ela"

	save "${int}/IA_AssmtData_district_ela_`1'.dta", replace

	* Math 

	import excel "${raw}/Iowa - District/IA_OriginalData_`1'_district_all.`4'", sheet(`9') cellrange(`6':`3') firstrow clear

	gen Subject="math"

	save "${int}/IA_AssmtData_district_math_`1'.dta", replace

	append using "${int}/IA_AssmtData_district_ela_`1'.dta"

	drop `7'

	foreach i of varlist NotProficient Proficient TotalTested I {
		local a: variable label `i'
		local a: subinstr local a "%" "Percent"
		local a: subinstr local a " " ""
		local a: subinstr local a " " ""
		local a: subinstr local a " " ""
		local a = "`a'" + "3"
		label var `i' "`a'"
	}

	foreach i of varlist K L M N {
		local a: variable label `i'
		local a: subinstr local a "%" "Percent"
		local a: subinstr local a " " ""
		local a: subinstr local a " " ""
		local a: subinstr local a " " ""
		local a = "`a'" + "4"
		label var `i' "`a'"
	}

	foreach i of varlist P Q R S {
		local a: variable label `i'
		local a: subinstr local a "%" "Percent"
		local a: subinstr local a " " ""
		local a: subinstr local a " " ""
		local a: subinstr local a " " ""
		local a = "`a'" + "5"
		label var `i' "`a'"
	}

	foreach i of varlist U V W X {
		local a: variable label `i'
		local a: subinstr local a "%" "Percent"
		local a: subinstr local a " " ""
		local a: subinstr local a " " ""
		local a: subinstr local a " " ""
		local a = "`a'" + "6"
		label var `i' "`a'"
	}

	foreach i of varlist Z AA AB AC {
		local a: variable label `i'
		local a: subinstr local a "%" "Percent"
		local a: subinstr local a " " ""
		local a: subinstr local a " " ""
		local a: subinstr local a " " ""
		local a = "`a'" + "7"
		label var `i' "`a'"
	}

	foreach i of varlist AE AF AG AH {
		local a: variable label `i'
		local a: subinstr local a "%" "Percent"
		local a: subinstr local a " " ""
		local a: subinstr local a " " ""
		local a: subinstr local a " " ""
		local a = "`a'" + "8"
		label var `i' "`a'"
	}


	foreach i of varlist NotProficient Proficient TotalTested I K L M N P Q R S U V W X Z AA AB AC AE AF AG AH {
		local x : variable label `i'
		rename `i' `x'
	}

	save "${int}/IA_AssmtData_district_`1'.dta", replace

end

filesave11 "2014" "AR349" "AR349" "xlsx" "A3" "A3" "J O T Y AD AI AJ AK AL AM AN AO AP AQ AR" "reading" "math"



use "${int}/IA_AssmtData_district_2014.dta", clear
replace District=Dist if District==.
drop Dist 
gen District1=string(District,"%04.0f")
drop District
rename District1 District
save "${int}/IA_AssmtData_district_2014.dta", replace



/////////////////////////////////////////
*** 2008-2013 (Data Saving) ***
/////////////////////////////////////////

* 2013
import excel "${raw}/Iowa - District/IA_OriginalData_2013_district_all.xls", sheet("Districts") cellrange(A2:M4670) firstrow clear

rename district StateAssignedDistID
rename DistrictName DistName 
rename description StudentGroup
rename NumberFullAcademicYeartested StudentGroup_TotalTested
rename PercentProficient ProficientOrAbove_percent
rename NumberProficient ProficientOrAbove_count
rename grade GradeLevel
rename type Subject

drop if GradeLevel=="11"
replace GradeLevel="G"+GradeLevel
replace Subject="math" if Subject=="M"
replace Subject="ela" if Subject=="R"

gen ParticipationRate=""

drop school aea commcollegenum year subgroup

save "${int}/IA_AssmtData_all_2013.dta", replace

* 2012
import excel "${raw}/Iowa - District/IA_OriginalData_2012_district_all.xlsx", cellrange(A1:N4693) firstrow clear

rename Dist StateAssignedDistID
rename SchName DistName 
rename description StudentGroup
rename NumberTested StudentGroup_TotalTested
rename PercentProficient ProficientOrAbove_percent
rename ParticipationRatePercentage ParticipationRate
rename NumberProficient ProficientOrAbove_count
rename grade GradeLevel
rename type Subject

drop if GradeLevel=="11"
replace GradeLevel="G"+GradeLevel
replace Subject="math" if Subject=="Mathematics"
replace Subject="ela" if Subject=="Reading"

drop aea year subgroup NumberFullAcademicYearTested Enroll

save "${int}/IA_AssmtData_all_2012.dta", replace

* 2011
import excel "${raw}/Iowa - District/IA_OriginalData_2011_district_all.xlsx", cellrange(A4:M4808) firstrow clear

rename District StateAssignedDistID
rename Agencyname DistName 
rename Description StudentGroup
rename NumberTested StudentGroup_TotalTested
rename PercentProficient ProficientOrAbove_percent
rename ParticipationRatePercentage ParticipationRate
rename NumberProficient ProficientOrAbove_count
rename Grade GradeLevel
rename Type Subject

drop if GradeLevel=="11"
replace GradeLevel="G"+GradeLevel
replace Subject="math" if Subject=="Mathematics"
replace Subject="ela" if Subject=="Reading"

drop AEA Year NumberFullAcademicYearTested Enroll

save "${int}/IA_AssmtData_all_2011.dta", replace

* 2010
import excel "${raw}/Iowa - District/IA_OriginalData_2010_district_all.xls", cellrange(A4:M4812) firstrow clear

rename District StateAssignedDistID
rename Agencyname DistName 
rename Description StudentGroup
rename NumberTested StudentGroup_TotalTested
rename PercentProficient ProficientOrAbove_percent
rename ParticipationRatePercentage ParticipationRate
rename NumberProficient ProficientOrAbove_count
rename Grade GradeLevel
rename Type Subject

drop if GradeLevel=="11"
replace GradeLevel="G"+GradeLevel
replace Subject="math" if Subject=="Mathematics"
replace Subject="ela" if Subject=="Reading"

drop AEA Year FullAcademicYearTested Enrollment

save "${int}/IA_AssmtData_all_2010.dta", replace

* 2009
import excel "${raw}/Iowa - District/IA_OriginalData_2009_district_all.xls", sheet(" for posting") cellrange(A6:M4840) firstrow clear

rename District StateAssignedDistID
rename Agencyname DistName 
rename Description StudentGroup
rename NumberTested StudentGroup_TotalTested
rename PercentProficient ProficientOrAbove_percent
rename ParticipationRatePercentage ParticipationRate
rename NumberProficient ProficientOrAbove_count
rename Grade GradeLevel
rename Type Subject

drop if GradeLevel=="11"
replace GradeLevel="G"+GradeLevel
replace Subject="math" if Subject=="Mathematics"
replace Subject="ela" if Subject=="Reading"

drop if DistName=="" | DistName=="Agencyname"

drop AEA Year FullAcademicYearTested Enrollment

save "${int}/IA_AssmtData_all_2009.dta", replace

* 2008 

import excel "${raw}/Iowa - District/IA_OriginalData_2008_district_all.xls", sheet("Math results") cellrange(A10:M2462) firstrow clear

rename Gr Grade

save "${int}/IA_AssmtData_math_2009.dta", replace

import excel "${raw}/Iowa - District/IA_OriginalData_2008_district_all.xls", sheet("Reading results") cellrange(A10:M2462) firstrow clear

append using "${int}/IA_AssmtData_math_2009.dta"

rename District StateAssignedDistID
rename Agencyname DistName 
rename Description StudentGroup
rename NumberTested StudentGroup_TotalTested
rename PercentProficient ProficientOrAbove_percent
rename ParticipationRatePercentage ParticipationRate
rename NumberProficient ProficientOrAbove_count
rename Grade GradeLevel
rename Type Subject

drop if GradeLevel=="11"
replace GradeLevel="G"+GradeLevel
replace Subject="math" if Subject=="Math"
replace Subject="ela" if Subject=="Reading"

drop if DistName=="" | DistName=="Agencyname"

drop AEA Year FullAcademicYearTested Enrollment

save "${int}/IA_AssmtData_all_2008.dta", replace

/////////////////////////////////////////
*** Before 2007 (Data Cleaning) ***
/////////////////////////////////////////

* 2007

import excel "${raw}/Iowa - District/IA_OriginalData_2007_district_all.xls", sheet("Math & Reading") cellrange(A7:CH373) firstrow clear

drop AM AN AO AP AQ AR CC CD CE CF CG CH

ds , has(varlabel "Full Academic Year")
drop `r(varlist)'

ds , has(varlabel "Enrollment")
drop `r(varlist)'

drop if DistrictName==""

foreach i of varlist NumberTested ParticipationRate NumberProficient PercentageProficient {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "3math"
	label var `i' "`a'"
}

foreach i of varlist J K M N {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "4math"
	label var `i' "`a'"
}

foreach i of varlist P Q S T {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "5math"
	label var `i' "`a'"
}

foreach i of varlist V W Y Z {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "6math"
	label var `i' "`a'"
}

foreach i of varlist AB AC AE AF {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "7math"
	label var `i' "`a'"
}

foreach i of varlist AH AI AK AL {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "8math"
	label var `i' "`a'"
}

foreach i of varlist AT AU AW AX {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "3ela"
	label var `i' "`a'"
}

foreach i of varlist AZ BA BC BD {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "4ela"
	label var `i' "`a'"
}

foreach i of varlist BF BG BI BJ {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "5ela"
	label var `i' "`a'"
}

foreach i of varlist BL BM BO BP {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "6ela"
	label var `i' "`a'"
}

foreach i of varlist BR BS BU BV {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "7ela"
	label var `i' "`a'"
}

foreach i of varlist BX BY CA CB {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "8ela"
	label var `i' "`a'"
}

foreach i of varlist NumberTested ParticipationRate NumberProficient PercentageProficient J K M N P Q S T V W Y Z AB AC AE AF AH AI AK AL AT AU AW AX AZ BA BC BD BF BG BI BJ BL BM BO BP BR BS BU BV BX BY CA CB {
	local x : variable label `i'
	rename `i' `x'
}

rename DistrictName DistName
rename District StateAssignedDistID

reshape long NumberTested3 ParticipationRate3 NumberProficient3 PercentageProficient3 NumberTested4 ParticipationRate4 NumberProficient4 PercentageProficient4 NumberTested5 ParticipationRate5 NumberProficient5 PercentageProficient5 NumberTested6 ParticipationRate6 NumberProficient6 PercentageProficient6 NumberTested7 ParticipationRate7 NumberProficient7 PercentageProficient7 NumberTested8 ParticipationRate8 NumberProficient8 PercentageProficient8, i(StateAssignedDistID DistName) j(Subject, string)

reshape long NumberTested ParticipationRate NumberProficient PercentageProficient, i(StateAssignedDistID DistName Subject) j(GradeLevel)

tostring GradeLevel, replace
replace GradeLevel="G0"+GradeLevel

gen StudentGroup="All Students"
rename NumberTested StudentGroup_TotalTested
rename NumberProficient ProficientOrAbove_count
rename PercentageProficient ProficientOrAbove_percent 

save "${int}/IA_AssmtData_all_2007.dta", replace

* 2006
import excel "${raw}/Iowa - District/IA_OriginalData_2006_district_all.xls", sheet("Sheet1") cellrange(A6:CU372) firstrow clear

drop CP CQ CR CS CT CU AS AT AU AV AW AX

ds , has(varlabel "")
drop `r(varlist)'

ds , has(varlabel "Full Academic Year")
drop `r(varlist)'

ds , has(varlabel "Enrollment")
drop `r(varlist)'

drop if DistrictName==""

foreach i of varlist NumberTested ParticipationRate NumberProficient PercentageProficient {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "3math"
	label var `i' "`a'"
}

foreach i of varlist K L N O {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "4math"
	label var `i' "`a'"
}

foreach i of varlist R S U V {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "5math"
	label var `i' "`a'"
}

foreach i of varlist Y Z AB AC {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "6math"
	label var `i' "`a'"
}

foreach i of varlist AF AG AI AJ {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "7math"
	label var `i' "`a'"
}

foreach i of varlist AM AN AP AQ {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "8math"
	label var `i' "`a'"
}

foreach i of varlist BA BB BD BE {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "3ela"
	label var `i' "`a'"
}

foreach i of varlist BH BI BK BL {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "4ela"
	label var `i' "`a'"
}

foreach i of varlist BO BP BR BS {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "5ela"
	label var `i' "`a'"
}

foreach i of varlist BV BW BY BZ {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "6ela"
	label var `i' "`a'"
}

foreach i of varlist CC CD CF CG {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "7ela"
	label var `i' "`a'"
}

foreach i of varlist CJ CK CM CN {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "8ela"
	label var `i' "`a'"
}

foreach i of varlist NumberTested ParticipationRate NumberProficient PercentageProficient K L N O R S U V Y Z AB AC AF AG AI AJ AM AN AP AQ BA BB BD BE BH BI BK BL BO BP BR BS BV BW BY BZ CC CD CF CG CJ CK CM CN {
	local x : variable label `i'
	rename `i' `x'
}

rename DistrictName DistName
rename District StateAssignedDistID

reshape long NumberTested3 ParticipationRate3 NumberProficient3 PercentageProficient3 NumberTested4 ParticipationRate4 NumberProficient4 PercentageProficient4 NumberTested5 ParticipationRate5 NumberProficient5 PercentageProficient5 NumberTested6 ParticipationRate6 NumberProficient6 PercentageProficient6 NumberTested7 ParticipationRate7 NumberProficient7 PercentageProficient7 NumberTested8 ParticipationRate8 NumberProficient8 PercentageProficient8, i(StateAssignedDistID DistName) j(Subject, string)

reshape long NumberTested ParticipationRate NumberProficient PercentageProficient, i(StateAssignedDistID DistName Subject) j(GradeLevel)

tostring GradeLevel, replace
replace GradeLevel="G0"+GradeLevel

gen StudentGroup="All Students"
rename NumberTested StudentGroup_TotalTested
rename NumberProficient ProficientOrAbove_count
rename PercentageProficient ProficientOrAbove_percent

save "${int}/IA_AssmtData_all_2006.dta", replace


* 2005
import excel "${raw}/Iowa - District/IA_OriginalData_2005_district_all.xls", sheet("AYP_2005_ByDist_Summary") cellrange(A6:AQ373) firstrow clear

drop AE AF AG AH AI AJ AK AL AM AN AO AP AQ

ds , has(varlabel "")
drop `r(varlist)'

ds , has(varlabel "Number Full Academic Year")
drop `r(varlist)'

ds , has(varlabel "Enrollment")
drop `r(varlist)'

drop if DistrictName=="" | DistrictName=="DistrictName"

foreach i of varlist NumberTested ParticipationRate NumberProficient PercentageProficient {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "4math"
	label var `i' "`a'"
}

foreach i of varlist K L N O {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "4ela"
	label var `i' "`a'"
}

foreach i of varlist R S U V {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "8math"
	label var `i' "`a'"
}

foreach i of varlist Y Z AB AC {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "8ela"
	label var `i' "`a'"
}

foreach i of varlist Enrollment NumberTested ParticipationRate NumberProficient PercentageProficient K L N O R S U V Y Z AB AC {
	local x : variable label `i'
	rename `i' `x'
}

rename DistrictName DistName
rename District StateAssignedDistID

reshape long NumberTested4 ParticipationRate4 NumberProficient4 PercentageProficient4 NumberTested8 ParticipationRate8 NumberProficient8 PercentageProficient8, i(StateAssignedDistID DistName) j(Subject, string)

reshape long NumberTested ParticipationRate NumberProficient PercentageProficient, i(StateAssignedDistID DistName Subject) j(GradeLevel)

tostring GradeLevel, replace
replace GradeLevel="G0"+GradeLevel

gen StudentGroup="All Students"
rename NumberTested StudentGroup_TotalTested
rename NumberProficient ProficientOrAbove_count
rename PercentageProficient ProficientOrAbove_percent

save "${int}/IA_AssmtData_all_2005.dta", replace


* 2004
import excel "${raw}/Iowa - District/IA_OriginalData_2004_district_all.xls", sheet("AYP_ByDist_2004") cellrange(A6:AQ374) firstrow clear

drop AE AF AG AH AI AJ AK AL AM AN AO AP AQ

ds , has(varlabel "")
drop `r(varlist)'

ds , has(varlabel "Number Full Academic Year")
drop `r(varlist)'

ds , has(varlabel "Enrollment")
drop `r(varlist)'

drop if DistrictName=="" | DistrictName=="DistrictName"

foreach i of varlist NumberTested ParticipationRate NumberProficient PercentageProficient {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "4math"
	label var `i' "`a'"
}

foreach i of varlist K L N O {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "4ela"
	label var `i' "`a'"
}

foreach i of varlist R S U V {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "8math"
	label var `i' "`a'"
}

foreach i of varlist Y Z AB AC {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "8ela"
	label var `i' "`a'"
}

foreach i of varlist Enrollment NumberTested ParticipationRate NumberProficient PercentageProficient K L N O R S U V Y Z AB AC {
	local x : variable label `i'
	rename `i' `x'
}

rename DistrictName DistName
rename District StateAssignedDistID

reshape long NumberTested4 ParticipationRate4 NumberProficient4 PercentageProficient4 NumberTested8 ParticipationRate8 NumberProficient8 PercentageProficient8, i(StateAssignedDistID DistName) j(Subject, string)

reshape long NumberTested ParticipationRate NumberProficient PercentageProficient, i(StateAssignedDistID DistName Subject) j(GradeLevel)

tostring GradeLevel, replace
replace GradeLevel="G0"+GradeLevel

gen StudentGroup="All Students"
rename NumberTested StudentGroup_TotalTested
rename NumberProficient ProficientOrAbove_count
rename PercentageProficient ProficientOrAbove_percent

save "${int}/IA_AssmtData_all_2004.dta", replace


* 2003
import excel "${raw}/Iowa - District/IA_OriginalData_2003_district_all.xlsx", sheet("ayp_byDist_2003") cellrange(A6:AQ373) firstrow clear

drop AE AF AG AH AI AJ AK AL AM AN AO AP AQ

ds , has(varlabel "")
drop `r(varlist)'

ds , has(varlabel "Number Full Academic Year")
drop `r(varlist)'

ds , has(varlabel "Enrollment")
drop `r(varlist)'

drop if DistrictName=="" | DistrictName=="DistrictName"

foreach i of varlist NumberTested ParticipationRate NumberProficient PercentageProficient {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "4math"
	label var `i' "`a'"
}

foreach i of varlist K L N O {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "4ela"
	label var `i' "`a'"
}

foreach i of varlist R S U V {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "8math"
	label var `i' "`a'"
}

foreach i of varlist Y Z AB AC {
	local a: variable label `i'
	local a: subinstr local a "%" "Percent"
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a: subinstr local a " " ""
	local a = "`a'" + "8ela"
	label var `i' "`a'"
}

foreach i of varlist Enrollment NumberTested ParticipationRate NumberProficient PercentageProficient K L N O R S U V Y Z AB AC {
	local x : variable label `i'
	rename `i' `x'
}

rename DistrictName DistName
rename District StateAssignedDistID

reshape long NumberTested4 ParticipationRate4 NumberProficient4 PercentageProficient4 NumberTested8 ParticipationRate8 NumberProficient8 PercentageProficient8, i(StateAssignedDistID DistName) j(Subject, string)

reshape long NumberTested ParticipationRate NumberProficient PercentageProficient, i(StateAssignedDistID DistName Subject) j(GradeLevel)

tostring GradeLevel, replace
replace GradeLevel="G0"+GradeLevel

gen StudentGroup="All Students"
rename NumberTested StudentGroup_TotalTested
rename NumberProficient ProficientOrAbove_count
rename PercentageProficient ProficientOrAbove_percent

save "${int}/IA_AssmtData_all_2003.dta", replace




/////////////////////////////////////////
*** 2003-2013 (Data Cleaning) ***
/////////////////////////////////////////

// use "${int}/IA_AssmtData_all_2013.dta", clear
// use "${iowa}/NCES_2013_district.dta", clear



**# Bookmark #3
program cleaner139
use "${int}/IA_AssmtData_all_`1'.dta", clear

gen State_leaid=StateAssignedDistID
merge m:1 State_leaid using "${iowa}/NCES_`2'_district.dta"

	drop if _merge==2

	gen DataLevel="District"
	replace DataLevel="State" if DistName=="State"
	replace DistName="All Districts" if DataLevel=="State"

	drop State
	gen State="Iowa"
	replace StateAbbrev="IA"
	replace StateFips=19
	gen SchYear="`3'"

	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel 
	rename DataLevel_n DataLevel

	gen SchName=""

	replace DistName="All Districts" if DataLevel==1
	replace SchName="All Districts" if DataLevel==1

	gen AssmtName="ITBS"
	gen AssmtType="Regular and alt"
	replace StudentGroup="All Students"

	replace StudentGroup_TotalTested="--" if StudentGroup_TotalTested==""

	gen ProficiencyCriteria="Levels 2-3"
	gen AvgScaleScore="--"
	gen StudentSubGroup="All Students"
	gen StudentSubGroup_TotalTested=StudentGroup_TotalTested 

	foreach x of numlist 1/5 {
		generate Lev`x'_count = ""
		generate Lev`x'_percent = ""
		label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
		label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
	}

// gen Flag_AssmtNameChange = "N"
// gen Flag_CutScoreChange_ELA = "N"
// gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_oth = "Y"
// gen Flag_CutScoreChange_read = ""

// updated 
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N" 
gen Flag_CutScoreChange_soc = "Not applicable"
// updated 

////////////////////////////////////
*** Review 1 Edits ***
////////////////////////////////////

replace State="Iowa"

replace SchName="All Schools" if DataLevel==2 | DataLevel==1

drop if DistName=="Rolled up to state"

local schoolvar "seasch NCESSchoolID StateAssignedSchID"

foreach s of local schoolvar {
	gen `s'=""
}

local schoolvar "SchType SchLevel SchVirtual"

foreach s of local schoolvar {
	gen `s'=.
}

foreach i of varlist NCESDistrictID State_leaid CountyName DistCharter {
	tostring `i', replace 
	replace `i'="Missing/not reported" if _merge==1 & DataLevel!=1
}

foreach i of varlist DistType CountyCode{
	replace `i'= "Missing/not reported" if _merge==1 & DataLevel!=1 
	// label def `i' -1 "Missing/not reported"
}

foreach v of varlist StudentGroup_TotalTested StudentSubGroup_TotalTested ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate {
	replace `v'="*" if `v'=="`4'"
}

foreach v of varlist StudentSubGroup_TotalTested AvgScaleScore Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ParticipationRate Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	tostring `v', replace
	replace `v' = "--" if `v' == "" | `v' == "."
}

drop if _merge==1 & strpos(SchName, "Online")>0

save "${int}/IA_AssmtData_school_`1'.dta", replace

keep if _merge==1 & DataLevel!=1

//export delimited using "${output}/Unmerged/IA_unmerged_`1'.csv", replace

use "${int}/IA_AssmtData_school_`1'.dta", clear

////////////////////////////////////
*** Review 2 Edits ***
////////////////////////////////////

destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent=ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent="--" if ProficientOrAbove_percent=="."

//label define agency_typedf -1 "Missing/not reported", add
//label values DistType agency_typedf

replace Lev4_count=""
replace Lev4_percent=""

//replace CountyCode=. if CountyCode==-1

////////////////////////////////////
*** Sorting ***
////////////////////////////////////

// keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
//
// order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read 


// updated 
	drop State_leaid seasch

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// updated

//sort
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
*replace SchVirtual = "Missing/not reported" if SchVirtual == "" & DataLevel == 3
*replace SchLevel = "Missing/not reported" if SchLevel == "" & DataLevel == 3

save "${output}/IA_AssmtData_all_`1'.dta", replace

export delimited using "${output}/IA_AssmtData_`1'.csv", replace
end


cleaner139 "2004" "2003" "2003-04" "Small Cell Size"
cleaner139 "2003" "2002" "2002-03" "Small Cell Size"
cleaner139 "2013" "2012" "2012-13" "small N"
cleaner139 "2012" "2011" "2011-12" "small N"
cleaner139 "2011" "2010" "2010-11" "SCS"
cleaner139 "2010" "2009" "2009-10" "SCS"

cleaner139 "2009" "2008" "2008-09" "SCS"
cleaner139 "2008" "2007" "2007-08" "SCS"
cleaner139 "2007" "2006" "2006-07" "Small cell size"
cleaner139 "2006" "2005" "2005-06" "Small cell size"
cleaner139 "2005" "2004" "2004-05" "Small Cell Size"

//cleaner12 "2005" "2004" "2004-05" "Small Cell Size"
// cleaner13 "2004" "2003" "2003-04" "Small Cell Size"
// cleaner13 "2003" "2002" "2002-03" "Small Cell Size"



/////////////////////////////////////////
*** Label change for 2012 ***
/////////////////////////////////////////

use "${output}/IA_AssmtData_all_2012.dta", clear 

// 		gen Flag_AssmtNameChange="Y"
// 		gen Flag_CutScoreChange_ELA="Y"
// 		gen Flag_CutScoreChange_math="Y"
// 		gen Flag_CutScoreChange_read=""
// 		gen Flag_CutScoreChange_oth="Y"
		
		replace Flag_AssmtNameChange = "Y"
		replace Flag_CutScoreChange_ELA = "Y"
		replace Flag_CutScoreChange_math = "Y"
		replace Flag_CutScoreChange_sci = "Not applicable" 
		replace Flag_CutScoreChange_soc = "Not applicable"

save "${output}/IA_AssmtData_all_2012.dta", replace

export delimited using "${output}/IA_AssmtData_2012.csv", replace

/////////////////////////////////////////
*** Assessment name change for 2012-2018 ***
/////////////////////////////////////////

global years 2012 2013 2014

foreach a in $years {
	
	
	use "${output}/IA_AssmtData_all_`a'.dta", clear 
	
	replace AssmtName="Iowa Assessments"
	
	save "${output}/IA_AssmtData_all_`a'.dta", replace
	
	export delimited using "${output}/IA_AssmtData_`a'.csv", replace
	
}

* ParticipationRate issues


global yearspar1 2003 2004 2006 2007 2008 2009 2010 2011 2012 //2005

foreach a in $yearspar1 {
	
	//use "${output}/IA_AssmtData_all_2009.dta", clear 
	use "${output}/IA_AssmtData_all_`a'.dta", clear 
	
	destring ParticipationRate, replace force
replace ParticipationRate=ParticipationRate/100
tostring ParticipationRate, replace force
replace ParticipationRate="--" if ParticipationRate=="."

////////////////////////////////////
*** Review 3 Edits ***
////////////////////////////////////

// updated
//tostring StateAssignedDistID, replace
//tostring State_leaid, replace
// updated

// decode DataLevel, gen(DataLevel1)
// drop DataLevel
// rename DataLevel1 DataLevel

//if `a' == 2003 {
	
// 	encode DataLevel, gen(DataLevel_n) label(DataLevel)
// 	sort DataLevel_n 
// 	drop DataLevel 
// 	rename DataLevel_n DataLevel

//} 

// keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
//
// order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

// updated


order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// updated

//sort
	
	save "${output}/IA_AssmtData_all_`a'.dta", replace
	
	export delimited using "${output}/IA_AssmtData_`a'.csv", replace
	
}

	 

global yearspar 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012

foreach a in $yearspar {
	
use "${output}/IA_AssmtData_all_`a'.dta", clear 
		
		
	foreach i of varlist StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate {
		
		replace `i'="*" if `i'=="Small Cell Size" | `i'=="SCS" | `i'=="small N" | `i'=="Small cell size"
	}

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//sort
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
	save "${output}/IA_AssmtData_all_`a'.dta", replace
	
	export delimited using "${output}/IA_AssmtData_`a'.csv", replace
	
}




import excel "${raw}/ia_county-list_through2023", firstrow case(preserve) allstring clear

duplicates drop CountyCode SchYear, force
drop oldcountyname 

save "IA_StableCounty", replace

forvalues year = 2003/2014 {  
	if `year' == 2020 continue
use "IA_StableCounty", clear
local prevyear = `=`year'-1'
keep if SchYear == "`prevyear'-" + substr("`year'",-2,2)
merge 1:m CountyCode using "${output}/IA_AssmtData_all_`year'" 


replace CountyName = newcountyname if newcountyname != ""
drop newcountyname

//Final Cleaning and Saving
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup	

	save "${output}/IA_AssmtData_all_`a'.dta", replace
	
	export delimited using "${output}/IA_AssmtData_`a'.csv", replace

}





