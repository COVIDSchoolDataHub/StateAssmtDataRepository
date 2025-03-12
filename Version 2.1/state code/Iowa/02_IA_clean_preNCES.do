*******************************************************
* IOWA

* File name: 02_IA_clean_preNCES
* Last update: 02/28/2024

*******************************************************
* Notes: 2004 to 2014 

	* This do files cleans 2004 to 2014 without merging in any NCES data.
	* Completed files are saved to a subfolder called DTA.
	* These files only include district-level data, except for 2014, which includes state data.
	* No subgroup data are available for these years.
	* No proficiency level data are available for these years (Level 1, Level 2, etc.)
	
* Notes: 2015 to 2023

	* This do files cleans 2015 to 2023 without merging in any NCES data.
	* Completed files are saved to a subfolder called DTA.
	* These files only include state, dist, and school data
	* All files are from a data request. 
	* Subgroup data ARE available.
	* Proficiency level data ARE available (Level 1, Level 2, etc.)
*******************************************************
clear

global years  2024 2023 2022 2021 2019 2018 2017 2016 2015 2014 2013 2012 2011 2010 2009 2008 2007 2006 2005 2004 //List all available years

*******************************************************
* 2004
*******************************************************
import excel "${Original_Pre}/IA_OriginalData_2004_district_ela,math.xls", sheet("AYP_ByDist_2004") cellrange(A6:AQ374) firstrow clear

// Dropping vars for grades above Grade 8 
drop AE AF AG AH AI AJ AK AL AM AN AO AP AQ

//drop empty vars
ds , has(varlabel "")
drop `r(varlist)'


ds , has(varlabel "Number Full Academic Year")
drop `r(varlist)'


ds , has(varlabel "Enrollment")
drop `r(varlist)'


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

gen SchYear="2003-04"
drop Enrollment 
gen DataLevel="District" //only dist data available from 2004-2013; state data begins 2014; sch data begins 2015

// Data File Note: "Blank cells indicate that the district doesn't offer that grade in the district." Therefore, dropping these grades/observations.
drop if StudentGroup_TotalTested==""

order SchYear DistName StateAssignedDistID Subject GradeLevel StudentGroup StudentGroup_TotalTested  ProficientOrAbove_count  ProficientOrAbove_percent ParticipationRate 

// StudentGroup_TotalTested & ProficientOrAbove_count 
foreach var of varlist StudentGroup_TotalTested ProficientOrAbove_count {
	replace `var'="*" if `var'=="Small Cell Size"
	replace `var'="--" if `var'==""
	tab StudentGroup_TotalTested
	tab ProficientOrAbove_count
	}

// Converting ProficientOrAbove_percent & ParticipationRate to decimals & string
foreach var of varlist ProficientOrAbove_percent ParticipationRate  {
	replace `var'="20000" if `var'=="Small Cell Size"
	replace `var'="50000" if `var'=="--"
	destring `var', replace
	replace `var'=`var'/100
	tostring `var', replace format("%9.3f") force
	replace `var'="*" if `var'=="200.000"
    replace `var' = "--" if `var' == "500.000"
	*tab ParticipationRate
	}	

//////////////////////////////////
** Important note for Iowa 2004:
** There is a "PercentageProficient" variable (renamed ProficientOrAbove_percent), but this uses a denominator of students enrolled for the "Full Academic Year", rather than the total number of students tested. Therefore, we are dropping this var and recalculating as ProficientOrAbove_count / StudentGroup_TotalTested.

	rename ProficientOrAbove_percent profabove_old 
	gen ProficientOrAbove_percent = real(ProficientOrAbove_count) / real(StudentGroup_TotalTested)
	replace ProficientOrAbove_percent=2 if ProficientOrAbove_percent==.
	drop profabove_old
	tostring ProficientOrAbove_percent, replace format("%9.3f") force
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="2.000"
//////////////////////////////////	

//note: all vars are string; participationrate and proficientorabove_percent have been convereted to decimals 

save "${Original_DTA}/IA_AssmtData_2004.dta", replace

*******************************************************
* 2005
*******************************************************
import excel "${Original_Pre}/IA_OriginalData_2005_district_ela,math.xls", sheet("AYP_2005_ByDist_Summary") cellrange(A6:AQ373) firstrow clear

// Dropping vars for grades above Grade 8 
drop AE AF AG AH AI AJ AK AL AM AN AO AP AQ

//drop empty vars
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

gen SchYear="2004-05"
drop Enrollment 
gen DataLevel="District" //only dist data available from 2004-2013; state data begins 2014; sch data begins 2015

// Data File Note: "Blank cells indicate that the district doesn't offer that grade in the district." Therefore, dropping these grades/observations.
drop if StudentGroup_TotalTested==""

order SchYear DistName StateAssignedDistID Subject GradeLevel StudentGroup StudentGroup_TotalTested  ProficientOrAbove_count  ProficientOrAbove_percent ParticipationRate 

// Converting ProficientOrAbove_percent and ParticipationRate to decimals & string
foreach var of varlist ProficientOrAbove_percent ParticipationRate  {
	replace `var'="20000" if `var'=="Small Cell Size"
	replace `var'="50000" if `var'=="--"
	destring `var', replace
	replace `var'=`var'/100
	tostring `var', replace format("%9.3f") force
	replace `var'="*" if `var'=="200.000"
    replace `var' = "--" if `var' == "500.000"
	*tab ParticipationRate
	}
	
// StudentGroup_TotalTested & ProficientOrAbove_count 
foreach var of varlist StudentGroup_TotalTested ProficientOrAbove_count {
	replace `var'="*" if `var'=="Small Cell Size"
	replace `var'="--" if `var'==""
	tab StudentGroup_TotalTested
	tab ProficientOrAbove_count
	}

//////////////////////////////////
** Important note for Iowa 2005:
** There is a "PercentageProficient" variable (renamed ProficientOrAbove_percent), but this uses a denominator of students enrolled for the "Full Academic Year", rather than the total number of students tested. Therefore, we are dropping this var and recalculating as ProficientOrAbove_count / StudentGroup_TotalTested.

	rename ProficientOrAbove_percent profabove_old 
	gen ProficientOrAbove_percent = real(ProficientOrAbove_count) / real(StudentGroup_TotalTested)
	replace ProficientOrAbove_percent=2 if ProficientOrAbove_percent==.
	drop profabove_old
	tostring ProficientOrAbove_percent, replace format("%9.3f") force
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="2.000"
//////////////////////////////////		
	
//note: all vars are string; participationrate and proficientorabove_percent have been convereted to decimals 

save "${Original_DTA}/IA_AssmtData_2005.dta", replace

*******************************************************
* 2006
*******************************************************
import excel "${Original_Pre}/IA_OriginalData_2006_district_ela,math.xls", sheet("Sheet1") cellrange(A6:CU372) firstrow clear

// Dropping vars for grades above Grade 8 
drop CP CQ CR CS CT CU AS AT AU AV AW AX

//drop empty vars
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

/*
gen PercentageProficient_n = real(PercentageProficient)
replace PercentageProficient_n = (PercentageProficient_n/100)
generate ProficientOrAbove_percent = round(PercentageProficient_n, 0.001)
drop PercentageProficient PercentageProficient_n
*/

gen SchYear="2005-06"
gen DataLevel="District" //only dist data available from 2004-2013; state data begins 2014; sch data begins 2015

// Data File Note: "Blank cells indicate that the district doesn't offer that grade in the district." Therefore, dropping these grades/observations.
drop if StudentGroup_TotalTested==""

order SchYear DistName StateAssignedDistID Subject GradeLevel StudentGroup StudentGroup_TotalTested  ProficientOrAbove_count  ProficientOrAbove_percent ParticipationRate 

// Fixing an odd value 
tab ProficientOrAbove_percent // there is a value of ']'
replace ProficientOrAbove_percent = "93.33" if ProficientOrAbove_percent =="]"


// Converting ProficientOrAbove_percent and ParticipationRate to decimals & string
foreach var of varlist ProficientOrAbove_percent ParticipationRate  {
	replace `var'="20000" if `var'=="Small cell size"
	replace `var'="50000" if `var'=="--"
	destring `var', replace
	replace `var'=`var'/100
	tostring `var', replace format("%9.3f") force
	replace `var'="*" if `var'=="200.000"
    replace `var' = "--" if `var' == "500.000"
	*tab ParticipationRate
	}
	
// StudentGroup_TotalTested & ProficientOrAbove_count 
foreach var of varlist StudentGroup_TotalTested ProficientOrAbove_count {
	replace `var'="*" if `var'=="Small cell size"
	replace `var'="--" if `var'==""
	tab StudentGroup_TotalTested
	tab ProficientOrAbove_count
	}	
	
	
//////////////////////////////////
** Important note for Iowa 2006:
** There is a "PercentageProficient" variable (renamed ProficientOrAbove_percent), but this uses a denominator of students enrolled for the "Full Academic Year", rather than the total number of students tested. Therefore, we are dropping this var and recalculating as ProficientOrAbove_count / StudentGroup_TotalTested.

	rename ProficientOrAbove_percent profabove_old 
	gen ProficientOrAbove_percent = real(ProficientOrAbove_count) / real(StudentGroup_TotalTested)
	replace ProficientOrAbove_percent=2 if ProficientOrAbove_percent==.
	drop profabove_old
	tostring ProficientOrAbove_percent, replace format("%9.3f") force
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="2.000"
//////////////////////////////////			
	
//note: all vars are string; participationrate and proficientorabove_percent have been convereted to decimals 

save "${Original_DTA}/IA_AssmtData_2006.dta", replace

*******************************************************
* 2007
*******************************************************
import excel "${Original_Pre}/IA_OriginalData_2007_district_ela,math.xls", sheet("Math & Reading") cellrange(A7:CH373) firstrow clear

// Dropping vars for grades above Grade 8 
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

/*
replace PercentageProficient_n = (PercentageProficient_n/100)
generate ProficientOrAbove_percent = round(PercentageProficient_n, 0.001)
drop PercentageProficient PercentageProficient_n
*/

gen SchYear="2006-07"
gen DataLevel="District" //only dist data available from 2004-2013; state data begins 2014; sch data begins 2015

// Data File Note: "Blank cells indicate that the district doesn't offer that grade in the district." Therefore, dropping these grades/observations.
drop if StudentGroup_TotalTested==""

order SchYear DistName StateAssignedDistID Subject GradeLevel StudentGroup StudentGroup_TotalTested  ProficientOrAbove_count  ProficientOrAbove_percent ParticipationRate 

// Converting ProficientOrAbove_percent and ParticipationRate to decimals & string
foreach var of varlist ProficientOrAbove_percent ParticipationRate  {
	replace `var'="20000" if `var'=="Small cell size"
	replace `var'="50000" if `var'=="--"
	destring `var', replace
	replace `var'=`var'/100
	tostring `var', replace format("%9.3f") force
	replace `var'="*" if `var'=="200.000"
    replace `var' = "--" if `var' == "500.000"
	*tab ParticipationRate
	}
	
// StudentGroup_TotalTested & ProficientOrAbove_count 
foreach var of varlist StudentGroup_TotalTested ProficientOrAbove_count {
	replace `var'="*" if `var'=="Small cell size"
	replace `var'="--" if `var'==""
	tab StudentGroup_TotalTested
	tab ProficientOrAbove_count
	}		
	
//////////////////////////////////
** Important note for Iowa 2007:
** There is a "PercentageProficient" variable (renamed ProficientOrAbove_percent), but this uses a denominator of students enrolled for the "Full Academic Year", rather than the total number of students tested. Therefore, we are dropping this var and recalculating as ProficientOrAbove_count / StudentGroup_TotalTested.

	rename ProficientOrAbove_percent profabove_old 
	gen ProficientOrAbove_percent = real(ProficientOrAbove_count) / real(StudentGroup_TotalTested)
	replace ProficientOrAbove_percent=2 if ProficientOrAbove_percent==.
	drop profabove_old
	tostring ProficientOrAbove_percent, replace format("%9.3f") force
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="2.000"
//////////////////////////////////		

//note: all vars are string; participationrate and proficientorabove_percent have been convereted to decimals 

save "${Original_DTA}/IA_AssmtData_2007.dta", replace

*******************************************************
* 2008 
*******************************************************
 
import excel "${Original_Pre}/IA_OriginalData_2008_district_ela,math.xls", sheet("Math results") cellrange(A10:M2462) firstrow clear
rename Gr Grade
save "${Original_DTA}/IA_AssmtData_2008.dta", replace

import excel "${Original_Pre}/IA_OriginalData_2008_district_ela,math.xls", sheet("Reading results") cellrange(A10:M2462) firstrow clear
append using "${Original_DTA}/IA_AssmtData_2008.dta"

rename District StateAssignedDistID
rename Agencyname DistName 
rename Description StudentGroup
rename NumberTested StudentGroup_TotalTested
rename ParticipationRatePercentage ParticipationRate
rename NumberProficient ProficientOrAbove_count
rename Grade GradeLevel
rename Type Subject

drop if GradeLevel=="11"
replace GradeLevel="G"+GradeLevel
replace Subject="math" if Subject=="Math"
replace Subject="ela" if Subject=="Reading"

replace StudentGroup =strtrim(StudentGroup) // to remove trailing spaces
replace StudentGroup =stritrim(StudentGroup) 

drop if DistName=="" | DistName=="Agencyname"

drop AEA Year FullAcademicYearTested Enrollment

// In 2008+, IA changed from "PercentageProficient" to "PercentProficient"

rename PercentProficient ProficientOrAbove_percent 

/*
gen PercentageProficient_n = real(PercentProficient)
replace PercentageProficient_n = (PercentageProficient_n/100)
generate ProficientOrAbove_percent = round(PercentageProficient_n, 0.001)
drop PercentProficient PercentageProficient_n
*/

gen SchYear="2007-08"
gen DataLevel="District" //only dist data available from 2004-2013; state data begins 2014; sch data begins 2015

// Data File Note: "Blank cells indicate that the district doesn't offer that grade in the district." Therefore, dropping these grades/observations.
drop if StudentGroup_TotalTested==""

order SchYear DistName StateAssignedDistID Subject GradeLevel StudentGroup StudentGroup_TotalTested  ProficientOrAbove_count  ProficientOrAbove_percent ParticipationRate 

// Converting ProficientOrAbove_percent and ParticipationRate to decimals & string
foreach var of varlist ProficientOrAbove_percent ParticipationRate  {
	replace `var'="20000" if `var'=="SCS" // In 2008+, changed to "SCS"
	replace `var'="50000" if `var'=="--"
	destring `var', replace
	replace `var'=`var'/100
	tostring `var', replace format("%9.3f") force
	replace `var'="*" if `var'=="200.000"
    replace `var' = "--" if `var' == "500.000"
	*tab ParticipationRate
	}
	
// StudentGroup_TotalTested & ProficientOrAbove_count 
foreach var of varlist StudentGroup_TotalTested ProficientOrAbove_count {
	replace `var'="*" if `var'=="SCS" // In 2008, changed to "SCS"
	replace `var'="--" if `var'==""
	tab StudentGroup_TotalTested
	tab ProficientOrAbove_count
	}		
	
//////////////////////////////////
** Important note for Iowa 2008:
** There is a "PercentageProficient" variable (renamed ProficientOrAbove_percent), but this uses a denominator of students enrolled for the "Full Academic Year", rather than the total number of students tested. Therefore, we are dropping this var and recalculating as ProficientOrAbove_count / StudentGroup_TotalTested.

	rename ProficientOrAbove_percent profabove_old 
	gen ProficientOrAbove_percent = real(ProficientOrAbove_count) / real(StudentGroup_TotalTested)
	replace ProficientOrAbove_percent=2 if ProficientOrAbove_percent==.
	drop profabove_old
	tostring ProficientOrAbove_percent, replace format("%9.3f") force
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="2.000"


//////////////////////////////////			
	
//note: all vars are string; participationrate and proficientorabove_percent have been convereted to decimals 

save "${Original_DTA}/IA_AssmtData_2008.dta", replace


*******************************************************
* 2009
*******************************************************
import excel "${Original_Pre}/IA_OriginalData_2009_district_ela,math.xls", sheet(" for posting") cellrange(A6:M4840) firstrow clear

rename District StateAssignedDistID
rename Agencyname DistName 
rename Description StudentGroup
rename NumberTested StudentGroup_TotalTested
rename ParticipationRatePercentage ParticipationRate
rename NumberProficient ProficientOrAbove_count
rename Grade GradeLevel
rename Type Subject

drop if GradeLevel=="11"
replace GradeLevel="G"+GradeLevel
replace Subject="math" if Subject=="Mathematics"
replace Subject="ela" if Subject=="Reading"

replace StudentGroup =strtrim(StudentGroup) // to remove trailing spaces
replace StudentGroup =stritrim(StudentGroup) 

drop if DistName=="" | DistName=="Agencyname"

drop AEA Year FullAcademicYearTested Enrollment

rename PercentProficient ProficientOrAbove_percent 
/*
gen PercentageProficient_n = real(PercentProficient)
replace PercentageProficient_n = (PercentageProficient_n/100)
generate ProficientOrAbove_percent = round(PercentageProficient_n, 0.001)
drop PercentProficient PercentageProficient_n
*/

gen SchYear="2008-09"
gen DataLevel="District" //only dist data available from 2004-2013; state data begins 2014; sch data begins 2015

// Data File Note: "Blank cells indicate that the district doesn't offer that grade in the district." Therefore, dropping these grades/observations.
drop if StudentGroup_TotalTested==""

order SchYear DistName StateAssignedDistID Subject GradeLevel StudentGroup StudentGroup_TotalTested  ProficientOrAbove_count  ProficientOrAbove_percent ParticipationRate 


// Converting ProficientOrAbove_percent and ParticipationRate to decimals & string
foreach var of varlist ProficientOrAbove_percent ParticipationRate  {
	replace `var'="20000" if `var'=="SCS" // In 2008 and after, changed to "SCS"
	replace `var'="50000" if `var'=="--"
	destring `var', replace
	replace `var'=`var'/100
	tostring `var', replace format("%9.3f") force
	replace `var'="*" if `var'=="200.000"
    replace `var' = "--" if `var' == "500.000"
	*tab ParticipationRate
	}
	
// StudentGroup_TotalTested & ProficientOrAbove_count 
foreach var of varlist StudentGroup_TotalTested ProficientOrAbove_count {
	replace `var'="*" if `var'=="SCS" // In 2008 and after, changed to "SCS"
	replace `var'="--" if `var'==""
	tab StudentGroup_TotalTested
	tab ProficientOrAbove_count
	}		
	
//////////////////////////////////
** Important note for Iowa 2009:
** There is a "PercentageProficient" variable (renamed ProficientOrAbove_percent), but this uses a denominator of students enrolled for the "Full Academic Year", rather than the total number of students tested. Therefore, we are dropping this var and recalculating as ProficientOrAbove_count / StudentGroup_TotalTested.

	rename ProficientOrAbove_percent profabove_old 
	gen ProficientOrAbove_percent = real(ProficientOrAbove_count) / real(StudentGroup_TotalTested)
	replace ProficientOrAbove_percent=2 if ProficientOrAbove_percent==.
	drop profabove_old
	tostring ProficientOrAbove_percent, replace format("%9.3f") force
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="2.000"
//////////////////////////////////		

//note: all vars are string; participationrate and proficientorabove_percent have been convereted to decimals 

save "${Original_DTA}/IA_AssmtData_2009.dta", replace

*******************************************************
* 2010
*******************************************************
import excel "${Original_Pre}/IA_OriginalData_2010_district_ela,math.xls", cellrange(A4:M4812) firstrow clear

rename District StateAssignedDistID
rename Agencyname DistName 
rename Description StudentGroup
rename NumberTested StudentGroup_TotalTested
rename ParticipationRatePercentage ParticipationRate
rename NumberProficient ProficientOrAbove_count
rename Grade GradeLevel
rename Type Subject

drop if GradeLevel=="11"
replace GradeLevel="G"+GradeLevel
replace Subject="math" if Subject=="Mathematics"
replace Subject="ela" if Subject=="Reading"

replace StudentGroup =strtrim(StudentGroup) // to remove trailing spaces
replace StudentGroup =stritrim(StudentGroup) 

drop AEA Year FullAcademicYearTested Enrollment

rename PercentProficient ProficientOrAbove_percent 
/*
gen PercentageProficient_n = real(PercentProficient)
replace PercentageProficient_n = (PercentageProficient_n/100)
generate ProficientOrAbove_percent = round(PercentageProficient_n, 0.001)
drop PercentProficient PercentageProficient_n
*/

gen SchYear="2009-10"
gen DataLevel="District" //only dist data available from 2004-2013; state data begins 2014; sch data begins 2015

// Data File Note: "Blank cells indicate that the district doesn't offer that grade in the district." Therefore, dropping these grades/observations.
drop if StudentGroup_TotalTested==""

order SchYear DistName StateAssignedDistID Subject GradeLevel StudentGroup StudentGroup_TotalTested  ProficientOrAbove_count  ProficientOrAbove_percent ParticipationRate 


// Converting ProficientOrAbove_percent and ParticipationRate to decimals & string
foreach var of varlist ProficientOrAbove_percent ParticipationRate  {
	replace `var'="20000" if `var'=="SCS" // In 2008 and after, changed to "SCS"
	replace `var'="50000" if `var'=="--"
	destring `var', replace
	replace `var'=`var'/100
	tostring `var', replace format("%9.3f") force
	replace `var'="*" if `var'=="200.000"
    replace `var' = "--" if `var' == "500.000"
	*tab ParticipationRate
	}
	
// StudentGroup_TotalTested & ProficientOrAbove_count 
foreach var of varlist StudentGroup_TotalTested ProficientOrAbove_count {
	replace `var'="*" if `var'=="SCS" // In 2008 and after, changed to "SCS"
	replace `var'="--" if `var'==""
	tab StudentGroup_TotalTested
	tab ProficientOrAbove_count
	}		

//////////////////////////////////
** Important note for Iowa 2010:
** There is a "PercentageProficient" variable (renamed ProficientOrAbove_percent), but this uses a denominator of students enrolled for the "Full Academic Year", rather than the total number of students tested. Therefore, we are dropping this var and recalculating as ProficientOrAbove_count / StudentGroup_TotalTested.

	rename ProficientOrAbove_percent profabove_old 
	gen ProficientOrAbove_percent = real(ProficientOrAbove_count) / real(StudentGroup_TotalTested)
	replace ProficientOrAbove_percent=2 if ProficientOrAbove_percent==.
	drop profabove_old
	tostring ProficientOrAbove_percent, replace format("%9.3f") force
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="2.000"
//////////////////////////////////		
	
//note: all vars are string; participationrate and proficientorabove_percent have been converted to decimals 

save "${Original_DTA}/IA_AssmtData_2010.dta", replace

*******************************************************
* 2011
*******************************************************
import excel "${Original_Pre}/IA_OriginalData_2011_district_ela,math.xlsx", cellrange(A4:M4808) firstrow clear

rename District StateAssignedDistID
rename Agencyname DistName 
rename Description StudentGroup
rename NumberTested StudentGroup_TotalTested
rename ParticipationRatePercentage ParticipationRate
rename NumberProficient ProficientOrAbove_count
rename Grade GradeLevel
rename Type Subject

drop if GradeLevel=="11"
replace GradeLevel="G"+GradeLevel
replace Subject="math" if Subject=="Mathematics"
replace Subject="ela" if Subject=="Reading"

replace StudentGroup =strtrim(StudentGroup) // to remove trailing spaces
replace StudentGroup =stritrim(StudentGroup) 

drop AEA Year NumberFullAcademicYearTested Enroll

rename PercentProficient ProficientOrAbove_percent 

/*
gen PercentageProficient_n = real(PercentProficient)
replace PercentageProficient_n = (PercentageProficient_n/100)
generate ProficientOrAbove_percent = round(PercentageProficient_n, 0.001)
drop PercentProficient PercentageProficient_n
*/

gen SchYear="2010-11"
gen DataLevel="District" //only dist data available from 2004-2013; state data begins 2014; sch data begins 2015

// Data File Note: "Blank cells indicate that the district doesn't offer that grade in the district." Therefore, dropping these grades/observations.
drop if StudentGroup_TotalTested==""

order SchYear DistName StateAssignedDistID Subject GradeLevel StudentGroup StudentGroup_TotalTested  ProficientOrAbove_count  ProficientOrAbove_percent ParticipationRate 

// Converting ProficientOrAbove_percent and ParticipationRate to decimals & string
foreach var of varlist ProficientOrAbove_percent ParticipationRate  {
	replace `var'="20000" if `var'=="SCS" // In 2008 and after, changed to "SCS"
	replace `var'="50000" if `var'=="--"
	destring `var', replace
	replace `var'=`var'/100
	tostring `var', replace format("%9.3f") force
	replace `var'="*" if `var'=="200.000"
    replace `var' = "--" if `var' == "500.000"
	*tab ParticipationRate
	}
	
// StudentGroup_TotalTested & ProficientOrAbove_count 
foreach var of varlist StudentGroup_TotalTested ProficientOrAbove_count {
	replace `var'="*" if `var'=="SCS" // In 2008 and after, changed to "SCS"
	replace `var'="--" if `var'==""
	tab StudentGroup_TotalTested
	tab ProficientOrAbove_count
	}		


//////////////////////////////////
** Important note for Iowa 2011:
** There is a "PercentageProficient" variable (renamed ProficientOrAbove_percent), but this uses a denominator of students enrolled for the "Full Academic Year", rather than the total number of students tested. Therefore, we are dropping this var and recalculating as ProficientOrAbove_count / StudentGroup_TotalTested.

	rename ProficientOrAbove_percent profabove_old 
	gen ProficientOrAbove_percent = real(ProficientOrAbove_count) / real(StudentGroup_TotalTested)
	replace ProficientOrAbove_percent=2 if ProficientOrAbove_percent==.
	drop profabove_old
	tostring ProficientOrAbove_percent, replace format("%9.3f") force
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="2.000"
//////////////////////////////////		
	
//note: all vars are string; participationrate and proficientorabove_percent have been converted to decimals 

save "${Original_DTA}/IA_AssmtData_2011.dta", replace

*******************************************************
* 2012
*******************************************************
import excel "${Original_Pre}/IA_OriginalData_2012_district_ela,math.xlsx", cellrange(A1:N4693) firstrow clear

rename Dist StateAssignedDistID
rename SchName DistName 
rename description StudentGroup
rename NumberTested StudentGroup_TotalTested
rename ParticipationRatePercentage ParticipationRate
rename NumberProficient ProficientOrAbove_count
rename grade GradeLevel
rename type Subject

drop if GradeLevel=="11"
replace GradeLevel="G"+GradeLevel
replace Subject="math" if Subject=="Mathematics"
replace Subject="ela" if Subject=="Reading"

replace StudentGroup =strtrim(StudentGroup) // to remove trailing spaces
replace StudentGroup =stritrim(StudentGroup) 

drop aea year subgroup NumberFullAcademicYearTested Enroll
rename PercentProficient ProficientOrAbove_percent 
/*
gen PercentageProficient_n = real(PercentProficient)
replace PercentageProficient_n = (PercentageProficient_n/100)
generate ProficientOrAbove_percent = round(PercentageProficient_n, 0.001)
drop PercentProficient PercentageProficient_n
*/
gen SchYear="2011-12"
gen DataLevel="District" //only dist data available from 2004-2013; state data begins 2014; sch data begins 2015

// Data File Note: "Blank cells indicate that the district doesn't offer that grade in the district." Therefore, dropping these grades/observations.
drop if StudentGroup_TotalTested==""

order SchYear DistName StateAssignedDistID Subject GradeLevel StudentGroup StudentGroup_TotalTested  ProficientOrAbove_count  ProficientOrAbove_percent ParticipationRate 


// Converting ProficientOrAbove_percent and ParticipationRate to decimals & string
foreach var of varlist ProficientOrAbove_percent ParticipationRate  {
	replace `var'="20000" if `var'=="small N" // In 2012, changed to "small N"
	replace `var'="50000" if `var'=="--"
	destring `var', replace
	replace `var'=`var'/100
	tostring `var', replace format("%9.3f") force
	replace `var'="*" if `var'=="200.000"
    replace `var' = "--" if `var' == "500.000"
	*tab ParticipationRate
	}
	
// StudentGroup_TotalTested & ProficientOrAbove_count 
foreach var of varlist StudentGroup_TotalTested ProficientOrAbove_count {
	replace `var'="*" if `var'=="small N" // In 2012, changed to "small N"
	replace `var'="--" if `var'==""
	tab StudentGroup_TotalTested
	tab ProficientOrAbove_count
	}		
	
	
//////////////////////////////////
** Important note for Iowa 2012:
** There is a "PercentageProficient" variable (renamed ProficientOrAbove_percent), but this uses a denominator of students enrolled for the "Full Academic Year", rather than the total number of students tested. Therefore, we are dropping this var and recalculating as ProficientOrAbove_count / StudentGroup_TotalTested.

	rename ProficientOrAbove_percent profabove_old 
	gen ProficientOrAbove_percent = real(ProficientOrAbove_count) / real(StudentGroup_TotalTested)
	replace ProficientOrAbove_percent=2 if ProficientOrAbove_percent==.
	drop profabove_old
	tostring ProficientOrAbove_percent, replace format("%9.3f") force
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="2.000"
//////////////////////////////////	
	
//note: all vars are string; participationrate and proficientorabove_percent have been convereted to decimals 

save "${Original_DTA}/IA_AssmtData_2012.dta", replace


*******************************************************
* 2013 - no participation rate data this year in Original data 
*******************************************************
clear 
import excel "${Original_Pre}/IA_OriginalData_2013_district_ela,math.xls", sheet("Districts") cellrange(A2:M4670) firstrow clear

rename district StateAssignedDistID
rename DistrictName DistName 
rename description StudentGroup
rename NumberFullAcademicYeartested StudentGroup_TotalTested
rename NumberProficient ProficientOrAbove_count
rename grade GradeLevel
rename type Subject

drop if GradeLevel=="11"
replace GradeLevel="G"+GradeLevel
replace Subject="math" if Subject=="M"
replace Subject="ela" if Subject=="R"

replace StudentGroup =strtrim(StudentGroup) // to remove trailing spaces
replace StudentGroup =stritrim(StudentGroup) 

gen ParticipationRate="--" // 

drop school aea commcollegenum year subgroup

rename PercentProficient ProficientOrAbove_percent
/*
gen PercentageProficient_n = real(PercentProficient)
replace PercentageProficient_n = (PercentageProficient_n/100)
generate ProficientOrAbove_percent = round(PercentageProficient_n, 0.001)
drop PercentProficient PercentageProficient_n
*/

gen SchYear="2012-13"
gen DataLevel="District" //only dist data available from 2004-2013; state data begins 2014; sch data begins 2015

// Data File Note: "Blank cells indicate that the district doesn't offer that grade in the district." Therefore, dropping these grades/observations.
drop if StudentGroup_TotalTested==""

order SchYear DistName StateAssignedDistID Subject GradeLevel StudentGroup StudentGroup_TotalTested  ProficientOrAbove_count  ProficientOrAbove_percent ParticipationRate 

// Converting ProficientOrAbove_percent to decimals & string [does not include ParticipationRate]
foreach var of varlist ProficientOrAbove_percent   {
	replace `var'="20000" if `var'=="small N" // In 2012+, this is "small N"
	replace `var'="50000" if `var'=="--"
	destring `var', replace
	replace `var'=`var'/100
	tostring `var', replace format("%9.3f") force
	replace `var'="*" if `var'=="200.000"
    replace `var' = "--" if `var' == "500.000"
	*tab ParticipationRate
	}
	
	
// StudentGroup_TotalTested & ProficientOrAbove_count 
foreach var of varlist StudentGroup_TotalTested ProficientOrAbove_count {
	replace `var'="*" if `var'=="small N" // In 2012, changed to "small N"
	replace `var'="--" if `var'==""
	tab StudentGroup_TotalTested
	tab ProficientOrAbove_count
	}		

//////////////////////////////////
** Important note for Iowa 2013 & 2014:
** We only have the total number of "full year" students tested, so we do NOT need to generated a new ProficientOrAbove_percent var. 
tab ProficientOrAbove_percent

//note: all are string 

save "${Original_DTA}/IA_AssmtData_2013.dta", replace



*******************************************************
* 2014 - no participation rate data in raw data
*******************************************************

// 2014 formatting changes. 
clear
import excel "${Original_Pre}/IA_OriginalData_2014_district_ela,math.xlsx",  cellrange(A3:AR349) firstrow sheet("reading") 
gen Subject="ela"
rename  District StateAssignedDistID
save "${Original_DTA}/IA_AssmtData_2014.dta", replace

clear
import excel "${Original_Pre}/IA_OriginalData_2014_district_ela,math.xlsx",  cellrange(A3:AR349) firstrow sheet("math") 
gen Subject="math"
rename Dist StateAssignedDistID
append using "${Original_DTA}/IA_AssmtData_2014.dta"
save "${Original_DTA}/IA_AssmtData_2014.dta", replace

//Re-naming vars 
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

//dropping Grade 10 and Grade 11
drop AI AJ AK AL AM AN AO AP AQ AR

//dropping blank vars & vars not needed
drop J O T Y AD 
drop Co CountyName AEA NotProficient*


//changing StateAssignedDistID to string to be consistent with prior years
tab StateAssignedDistID
gen District1=string(StateAssignedDistID,"%04.0f")
order StateAssignedDistID District1 
drop StateAssignedDistID
rename District1 StateAssignedDistID

rename DistrictName DistName

reshape long NotProficient Proficient TotalTested PercentProficient, i(StateAssignedDistID DistName Subject) j(GradeLevel)

rename TotalTested StudentGroup_TotalTested
rename Proficient ProficientOrAbove_count

tostring GradeLevel, replace
replace GradeLevel="G0"+GradeLevel

gen StudentGroup = "All Students"

replace DistName = DistName + " Comm School District" if DistName !=""
rename PercentProficient ProficientOrAbove_percent
/*
gen PercentageProficient_n = real(PercentProficient)
replace PercentageProficient_n = (PercentageProficient_n/100)
generate ProficientOrAbove_percent = round(PercentageProficient_n, 0.001)
drop PercentProficient PercentageProficient_n
*/

gen SchYear="2013-14"
gen ParticipationRate ="--"
drop NotProficient
gen DataLevel="District" if DistName !="" //only dist data available from 2004-2013; state data begins 2014; sch data begins 2015
replace DataLevel="State" if DistName ==""

// Data File Note: "Blank cells indicate that the district doesn't offer that grade in the district." Therefore, dropping these grades/observations.
drop if StudentGroup_TotalTested==""

order SchYear DistName StateAssignedDistID Subject GradeLevel StudentGroup StudentGroup_TotalTested  ProficientOrAbove_count  ProficientOrAbove_percent ParticipationRate 

// Converting ProficientOrAbove_percent to decimals & string [does not include ParticipationRate]
foreach var of varlist ProficientOrAbove_percent   {
	replace `var'="20000" if `var'=="small N" // In 2012+, this is "small N"
	replace `var'="50000" if `var'=="--"
	destring `var', replace
	replace `var'=`var'/100
	tostring `var', replace format("%9.3f") force
	replace `var'="*" if `var'=="200.000"
    replace `var' = "--" if `var' == "500.000"
	*tab ParticipationRate
	}
	
	
// StudentGroup_TotalTested & ProficientOrAbove_count 
foreach var of varlist StudentGroup_TotalTested ProficientOrAbove_count {
	replace `var'="*" if `var'=="small N" // In 2012, changed to "small N"
	replace `var'="--" if `var'==""
	tab StudentGroup_TotalTested
	tab ProficientOrAbove_count
	}		


//note: all are string except for ProficientOrAbove_percent

// Updating values where ProficientOrAbove_percent is 0 and where ProficientOrAbove_count is "--"
sort ProficientOrAbove_percent
replace ProficientOrAbove_count = "0" if ProficientOrAbove_percent=="0.000"

save "${Original_DTA}/IA_AssmtData_2014.dta", replace



/////////////////////////////////////////
// 2004-2014
/////////////////////////////////////////

foreach year in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014  {

	use "${Original_DTA}/IA_AssmtData_`year'.dta", clear
	
	// Directory Variables 
	gen State="Iowa"
	gen StateAbbrev="IA"
	gen StateFips=19

	gen SchName="All Schools"
	replace DistName = "All Districts" if DataLevel=="State"

	// Assessment Variables & Flags
	gen AssmtName = ""
		replace AssmtName = "Iowa Test of Basic Skills" if `year' < 2012 
		replace  AssmtName = "Iowa Assessments" if `year' > 2011 & `year' < 2019 // Iowa Assessments bw 2012 and 2018
		replace  AssmtName = "ISASP" if `year' > 2018 // ISASP begins 2019
		
	gen AssmtType=""
		replace AssmtType = "Regular and alt" if `year' < 2015 
		replace AssmtType = "Regular" if `year' > 2014
		
	gen Flag_AssmtNameChange = ""
		replace Flag_AssmtNameChange = "N"
		replace Flag_AssmtNameChange = "Y" if SchYear=="2011-12" & (Subject=="ela" | Subject =="math")
		replace Flag_AssmtNameChange = "Y" if SchYear=="2018-19" & (Subject=="ela" | Subject =="math" | Subject =="sci")
		
	gen Flag_CutScoreChange_ELA = ""
		replace Flag_CutScoreChange_ELA = "N"
		replace Flag_CutScoreChange_ELA = "Y" if SchYear=="2011-12" 
		replace Flag_CutScoreChange_ELA = "Y" if SchYear=="2018-19"
	

	gen Flag_CutScoreChange_math = ""
		replace Flag_CutScoreChange_math = "N"
		replace Flag_CutScoreChange_math = "Y" if SchYear=="2011-12" 
		replace Flag_CutScoreChange_math = "Y" if SchYear=="2018-19" 

	gen Flag_CutScoreChange_sci = "" 
		replace Flag_CutScoreChange_sci = "N"
		replace Flag_CutScoreChange_sci = "Not applicable" if `year' < 2015 
		replace Flag_CutScoreChange_sci = "Y" if SchYear=="2018-19" 
		
	gen Flag_CutScoreChange_soc = "" 
		replace Flag_CutScoreChange_soc = "Not applicable" 

	//
	gen AvgScaleScore="--"
	gen ProficiencyCriteria="Levels 2-3"
	
	// Cleaning up DistNames & SchNames
	replace DistName =strtrim(DistName) 
	replace DistName =stritrim(DistName) 
	replace SchName =strtrim(SchName) 
	replace SchName =stritrim(SchName) 

	// Generating StudentSubGroup & StudentSubGroup_TotalTested
	gen StudentSubGroup="All Students"
	gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
	
	/*
		*tab StudentGroup_TotalTested //non-numerical value is "small N"
		replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "small N"
		replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == ""
		gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
	*/
	
	// Blank level counts and percents
	gen Lev1_count="--"
	gen Lev2_count="--"
	gen Lev3_count="--"
	gen Lev4_count="" // IA does not use Lev4, so this is left blank.
	gen Lev5_count="" // IA does not use Lev5, so this is left blank.
	
	gen Lev1_percent="--"
	gen Lev2_percent="--"
	gen Lev3_percent="--"
	gen Lev4_percent="" // IA does not use Lev4, so this is left blank.
	gen Lev5_percent="" // IA does not use Lev5, so this is left blank.
	
	// Adding State_leaid for merging with NCES_full	
	gen State_leaid=StateAssignedDistID
	
	// Adding school-level variables that are blank 
	gen NCESSchoolID =""
	gen StateAssignedSchID = ""
	gen SchLevel =.
	gen SchType =.
	gen SchVirtual =.
	
	//ProficientOrAbove_percent
	replace ProficientOrAbove_percent = "0" if ProficientOrAbove_percent == "0.000" //for consistency across years
	
	// ParticipationRate
	replace ParticipationRate = "1" if ParticipationRate == "1.000"
	
	//Final Cleaning and Saving
	order State_leaid State StateAbbrev StateFips SchYear DataLevel DistName SchName  StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc 

	keep State_leaid State StateAbbrev StateFips SchYear DataLevel DistName SchName StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc 	SchLevel SchType SchVirtual
	
	// Saving to intermediate1 
	save "${Original_DTA}/IA_AssmtData_`year'.dta", replace
	//export delimited "${Original_DTA}/IA_AssmtData_`year'.csv", replace
	}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
* 2015-2024 - Saving raw data to .dta
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 2024 {
	
local prevyear =`=`year'-1'
local Year = substr("`prevyear'",-2,2) + substr("`year'",-2,2)

import excel "${Original_Post}/IA_ProficiencyData_`Year'.xlsx", sheet("School") firstrow allstring clear
save "${Original_DTA}/IA_ProficiencyData_`year'.dta", replace

import excel "${Original_Post}/IA_ProficiencyData_`Year'.xlsx", sheet("District") firstrow allstring clear
append using "${Original_DTA}/IA_ProficiencyData_`year'.dta"
save "${Original_DTA}/IA_ProficiencyData_`year'.dta", replace

import excel "${Original_Post}/IA_ProficiencyData_`Year'.xlsx", sheet("State") firstrow allstring clear
append using "${Original_DTA}/IA_ProficiencyData_`year'.dta"
save "${Original_DTA}/IA_ProficiencyData_`year'.dta", replace
}

/////////////////////////////////////////

foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 2024 {
	
	local prevyear =`=`year'-1'
	local Year = "`prevyear'" + "-" + substr("`year'",-2,2)
	
	use "${Original_DTA}/IA_ProficiencyData_`year'.dta", clear
	
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

	order StateAssignedDistID DistName StateAssignedSchID SchName DataLevel Subject GradeLevel StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev2_count Lev3_count ProficientOrAbove_count Lev1_percent Lev2_percent Lev3_percent ProficientOrAbove_percent ParticipationRate
	
	// GradeLevel
	foreach x of numlist 3/8 {
		
		replace GradeLevel="G0`x'" if strpos(GradeLevel, "`x'")>0
		}

	replace GradeLevel="G38" if GradeLevel==""

	// Subject
	replace Subject="ela" if Subject=="ELA"
	replace Subject="math" if Subject=="Math"
	replace Subject="sci" if Subject=="Science"
	
	// StudentGroups & StudentSubGroups
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
	replace StudentSubGroup="SWD" if StudentSubGroup=="Spec Ed"
	replace StudentSubGroup="Non-SWD" if StudentSubGroup=="Not Spec Ed"
	
	gen StudentGroup="All Students"
		replace StudentGroup="RaceEth" if inlist(StudentSubGroup, "American Indian or Alaska Native", "Asian", "Black or African American", "Hispanic or Latino", "Native Hawaiian or Pacific Islander", "Two or More", "White")
		replace StudentGroup="Gender" if inlist(StudentSubGroup, "Male", "Female", "Gender X")
		replace StudentGroup="EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient")
		replace StudentGroup="Economic Status" if inlist(StudentSubGroup, "Not Economically Disadvantaged", "Economically Disadvantaged")
		replace StudentGroup="Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
	
	//SchYear 
	gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)
	
	order SchYear DataLevel StateAssignedDistID DistName StateAssignedSchID SchName  Subject GradeLevel StudentGroup StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev2_count Lev3_count ProficientOrAbove_count Lev1_percent Lev2_percent Lev3_percent ProficientOrAbove_percent ParticipationRate
	
	// SchName updates 
	
	if "`year'"=="2015" | "`year'"=="2016" | "`year'"=="2017" | "`year'"=="2018"| "`year'"=="2019"  {
		
	replace SchName="South OBrien Elem Sch Primghar Center" if SchName=="South O'Brien Elem Sch Primghar Center"
	replace SchName="South OBrien Secondary School" if SchName=="South O'Brien Secondary School"
		
		}
		
	replace SchName="Odebolt Arthur Battle Creek Ida Grove Elementary-Ida Grove" if SchName=="Odebolt Arthur Battle Creek Ida Grove Elementary  School - Ida Grove"
	replace SchName="Odebolt Arthur Battle Creek Ida Grove Elementary-Odebolt" if SchName=="Odebolt Arthur Battle Creek Ida Grove Elementary School - Odebolt"
	
	// Note for Ruby Van Meter, 2023 - all values for all grades and subgroups are suppressed. The "All Students" value is missing for Gr8. 
	
	// Converting percents to decimals	
		foreach var of varlist ParticipationRate Lev1_percent Lev2_percent Lev3_percent ProficientOrAbove_percent {
			replace `var'="10000" if `var'=="small N"
			destring `var', replace
			replace `var'=`var'/100
			tostring `var', replace force
			replace `var'="*" if `var'=="100"
            replace `var' = "--" if `var' == "."
			}
			
	// Counts
		foreach var of varlist StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev2_count Lev3_count ProficientOrAbove_count {
			replace `var'="*" if `var'=="small N"
			}
			
	// Adding State_leaid for merging with NCES_full	
	gen State_leaid=StateAssignedDistID
	
	// Directory Variables 
	gen State="Iowa"
	gen StateAbbrev="IA"
	gen StateFips=19

	// Assessment Variables & Flags
	gen AssmtName = ""
		replace AssmtName = "Iowa Test of Basic Skills" if `year' < 2012 
		replace  AssmtName = "Iowa Assessments" if `year' >= 2012 & `year' < 2019 
		replace  AssmtName = "ISASP" if `year' > 2018 // ISASP begins 2019
		
	gen AssmtType=""
		replace AssmtType = "Regular and alt" if `year' < 2015 
		replace AssmtType = "Regular" if `year' > 2014
		
	gen Flag_AssmtNameChange = ""
		replace Flag_AssmtNameChange = "N"
		replace Flag_AssmtNameChange = "Y" if SchYear=="2011-12" & (Subject=="ela" | Subject =="math")
		replace Flag_AssmtNameChange = "Y" if SchYear=="2018-19" & (Subject=="ela" | Subject =="math" | Subject =="sci")
		
	gen Flag_CutScoreChange_ELA = ""
		replace Flag_CutScoreChange_ELA = "N"
		replace Flag_CutScoreChange_ELA = "Y" if SchYear=="2011-12" 
		replace Flag_CutScoreChange_ELA = "Y" if SchYear=="2018-19" 
	

	gen Flag_CutScoreChange_math = ""
		replace Flag_CutScoreChange_math = "N"
		replace Flag_CutScoreChange_math = "Y" if SchYear=="2011-12"
		replace Flag_CutScoreChange_math = "Y" if SchYear=="2018-19"

	gen Flag_CutScoreChange_sci = "" 
		replace Flag_CutScoreChange_sci = "N"
		replace Flag_CutScoreChange_sci = "Not applicable" if `year' < 2015 
		replace Flag_CutScoreChange_sci = "Y" if SchYear=="2018-19"
		
	gen Flag_CutScoreChange_soc = "" 
		replace Flag_CutScoreChange_soc = "Not applicable" 

	//
	gen AvgScaleScore="--"
	gen ProficiencyCriteria="Levels 2-3"


	// Blank level counts and percents
	gen Lev4_count="" // IA does not use Lev4, so this is left blank.
	gen Lev5_count="" // IA does not use Lev5, so this is left blank.
	
	gen Lev4_percent="" // IA does not use Lev4, so this is left blank.
	gen Lev5_percent="" // IA does not use Lev5, so this is left blank.
	
	// Cleaning up DistNames & SchNames
	replace SchName="All Schools" if (DataLevel == "State" | DataLevel=="District")
	replace DistName = "All Districts" if DataLevel=="State"
	replace DistName =strtrim(DistName) 
	replace DistName =stritrim(DistName) 
	replace SchName =strtrim(SchName) 
	replace SchName =stritrim(SchName) 
	
	// Combining StateAssignedDistID + StateAssignedSchID; will be used for merging with NCES. Hyphenates district and school IDs	
	gen new_sch_ID = StateAssignedDistID + "-" + StateAssignedSchID 
	drop StateAssignedSchID
	rename new_sch_ID StateAssignedSchID
	replace StateAssignedSchID="" if DataLevel !="School"
	
	// Generating student group total counts - V2.0 convention
	gen StateAssignedDistID1 = StateAssignedDistID
	replace StateAssignedDistID1 = "000000" if DataLevel == "State"
	gen StateAssignedSchID1 = StateAssignedSchID
	replace StateAssignedSchID1 = "000000" if DataLevel !="School"
	egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
	sort group_id StudentGroup StudentSubGroup
	
	by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
	by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
	drop group_id StateAssignedDistID1 StateAssignedSchID1	
	
	// Drop
	drop year All_Enrolled 
	
	//Final Cleaning and Saving
	order State_leaid State StateAbbrev StateFips SchYear DataLevel DistName SchName StateAssignedDistID  StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc 
	
	keep State_leaid State StateAbbrev StateFips SchYear DataLevel DistName SchName StateAssignedDistID  StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc 
	
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup	

	// Saving to intermediate1 to add to 2004-2014
	save "${Original_DTA}/IA_AssmtData_`year'.dta", replace
	//export delimited "${Original_DTA}/IA_AssmtData_`year'.csv", replace	
}

/////////////////////////////////////////
// County Names
/////////////////////////////////////////
clear
import excel "${Original}/ia_county-list_through2023.xlsx", firstrow
save "${Original_DTA}/ia_county-list_through2023.dta", replace

// for merging with 2024 
clear 
import excel "${Original}/ia_county-list_through2023.xlsx", firstrow
	
	keep if SchYear == "2022-23"
	drop SchYear 
	duplicates drop 
	
save "${Original_DTA}/ia_county-list_noyear.dta", replace

*End of 02_IA_clean_preNCES.do
********************************************************

