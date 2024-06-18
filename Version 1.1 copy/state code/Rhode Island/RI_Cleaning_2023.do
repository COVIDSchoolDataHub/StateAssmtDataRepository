clear
set more off

// fix paths 
// run 

local Original "/Users/benjaminm/Documents/State_Repository_Research/Rhode Island/Original Data Files"
local Output "/Users/benjaminm/Documents/State_Repository_Research/Rhode Island/Output"
local NCES "/Users/benjaminm/Documents/State_Repository_Research/NCES District and School Demographics"


// local Original "/Users/miramehta/Documents/RI State Testing Data/Original Data Files"
// local Output "/Users/miramehta/Documents/RI State Testing Data/Output"
// local NCES "/Users/miramehta/Documents/NCES District and School Demographics"

tempfile temp1
save "`temp1'", emptyok
clear

//Importing

*Unhide below code on first run


/*
foreach Subject in ela math sci {
	import excel "`Original'/RI_OriginalData_2023_`Subject'", firstrow case(preserve) allstring
	keep if strpos(SchYear, "23") !=0
	*For some reason, the original science file says "math" in it, but this is incorrect
	replace Subject = "sci" if "`Subject'" == "sci"
	append using "`temp1'"
	save "`temp1'", replace
	clear
}
use "`temp1'"
save "`Original'/RI_OriginalData_2023", replace
*/

use "`Original'/RI_OriginalData_2023", clear

// new 5/31/24
rename G ParticipationRate

//DataLevel
gen DataLevel = ""
replace DataLevel = "District" if SchName == "All Schools"
replace DataLevel = "School" if SchName != "All Schools"
replace DataLevel = "State" if DistName == "Statewide"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3

//GradeLevel
replace GradeLevel = "G" + GradeLevel

//StudentSubGroup
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Other"
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All Groups") !=0
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Current English Learners"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not English Learners"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "EL Monit or Recently Ex" if strpos(,StudentSubGroup, "Recently (3 yrs)") !=0

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Unknown"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "EL Monit or Recently Ex" if StudentSubGroup == "EL Monit or Recently Ex"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino"

//Suppression and Missing
foreach var of varlist _all {
	cap replace `var' = "*" if `var' == "N/A"
}

//StudentSubGroup_TotalTested and StudentGroup_TotalTested
rename TotalTested StudentSubGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*)
sort StudentGroup
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if inlist(StudentGroup_TotalTested, "", ".")

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen Suppressed = 0
replace Suppressed = 1 if inlist(StudentSubGroup_TotalTested, "--", "*")
egen StudentGroup_Suppressed = max(Suppressed), by(StudentGroup GradeLevel Subject DataLevel DistName SchName)
drop Suppressed
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
destring AllStudents_Tested, replace
replace StudentGroup_TotalTested = string(AllStudents_Tested) if StudentGroup_Suppressed == 1
replace StudentGroup_TotalTested = string(AllStudents_Tested) if StudentSubGroup == "All Students"
destring StudentGroup_TotalTested, gen(Count) force
replace StudentGroup_TotalTested = string(AllStudents_Tested) if Count > AllStudents_Tested
drop AllStudents_Tested StudentGroup_Suppressed

replace StudentGroup = "EL Status" if StudentSubGroup=="EL Monit or Recently Ex"



//Proficiency Levels
rename NME Lev1_percent
rename PME Lev2_percent
rename ME Lev3_percent
rename EE Lev4_percent
rename MOEE ProficientOrAbove_percent
foreach var of varlist Lev* {
	replace `var' = subinstr(`var', "1-Not Meeting Expectations: ","",.)
	replace `var' = subinstr(`var', "2-Partially Meeting Expectations: ", "",.)
	replace `var' = subinstr(`var', "3-Meeting Expectations: ", "",.)
	replace `var' = subinstr(`var', "4-Exceeding Expectations: ", "",.)
	replace `var' = subinstr(`var', "1-Beginning to Meet Expectations: ","",.)
	replace `var' = subinstr(`var', "2-Approaching Expectations: ","",.)
	replace `var' = subinstr(`var', "4-Exceeds Expectations: ","",.)
}

replace Lev1_percent = subinstr(Lev1_percent, "1-Not Meeting Expectations: ", "",.)
replace Lev1_percent = subinstr(Lev1_percent, "1-Beginning to Meet Expectations: ", "",.)
replace Lev2_percent = subinstr(Lev2_percent, "2-Partially Meeting Expectations: ", "",.)
replace Lev2_percent = subinstr(Lev2_percent, "2-Approaching Expectations: ", "",.)
replace Lev3_percent = subinstr(Lev3_percent, "3-Meeting Expectations: ", "",.)
replace Lev4_percent = subinstr(Lev4_percent, "4-Exceeding Expectations: ", "",.)
replace Lev4_percent = subinstr(Lev4_percent, "4-Exceeds Expectations: ", "",.)

forvalues i = 1/4 {
		replace Lev`i'_percent = "*" if Lev`i'_percent == "N/A"
		replace Lev`i'_percent = subinstr(Lev`i'_percent, "%", "",.)
		if `i' != 1 {
			replace Lev`i'_percent = "*" if strpos(Lev`i'_percent, "1-Not Meeting Expectations: ") > 0
		}
		if `i' != 2 {
			replace Lev`i'_percent = "*" if strpos(Lev`i'_percent, "2-Partially Meeting Expectations: ") > 0
		}
		if `i' != 3 {
			replace Lev`i'_percent = "*" if strpos(Lev`i'_percent, "3-Meeting Expectations: ") > 0
		}
		if `i' != 4{
			replace Lev`i'_percent = "*" if strpos(Lev`i'_percent, "4-Exceeding Expectations: ") > 0
		}
}

foreach var of varlist Lev* Proficient* {
	destring `var', gen(n`var') i(*%)
	replace n`var' = n`var'/100
	replace `var' = string(n`var', "%9.3g") if `var' != "*"
}

//Subject
replace Subject = "ela" if strpos(Subject, "English") !=0
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "sci" if strpos(Subject, "Sci") !=0

//AvgScaleScore
rename Avg_Scale_Score AvgScaleScore

//Replacing SchNames (THANK YOU WILL!!!)
replace SchName = "AF Iluminar Mayoral Academy Middle School" if SchName == "AF Iluminar Mayoral Middle Sch"
replace SchName = "AF Providence Mayoral Academy Middle" if SchName == "AF Providence Mayoral Middle"
replace SchName = "Achievement First Iluminar Mayoral Academy" if SchName == "Achievement First Iluminar"
replace SchName = "Achievement First Providence Mayoral Academy" if SchName == "Achievement First Providence"
replace SchName = "Alan Shawn Feinstein Elementary at Broad Street" if SchName == "Alan Shawn Feinstein Elem."
replace SchName = "Alan Shawn Feinstein Middle School Of Coventry" if SchName == "Alan Shawn Feinstein MS of Cov"
replace SchName = "Alfred Lima Sr. Elementary School" if SchName == "Alfred Lima Sr. El School"
replace SchName = "Anthony Carnevale Elementary School" if SchName == "Anthony Carnevale Elementary"
replace SchName = "Archie R. Cole Middle School" if SchName == "Archie R. Cole MS"
replace SchName = "Asa Messer Elementary School" if SchName == "Asa Messer El. School"
replace SchName = "Blackstone Valley Prep Elementary 2 School" if SchName == "Blackstone Valley Prep E. 2"
replace SchName = "Blackstone Valley Prep Elementary School" if SchName == "Blackstone Valley Prep Element" | SchName == "Blackstone Valley Prep" & GradeLevel == "03" | SchName == "Blackstone Valley Prep" & GradeLevel == "04"
replace SchName = "Blackstone Valley Prep Junior High School" if SchName == "Blackstone Valley Prep Jr High"
replace SchName = "Blackstone Valley Prep Upper Elementary School" if SchName == "Blackstone Valley Prep Upper E"
replace SchName = "Dr. Earl F. Calcutt Middle School" if SchName == "Calcutt Middle School"
replace SchName = "Captain Isaac Paine Elementary School" if SchName == "Capt. Isaac Paine El. School"
replace SchName = "Carl G. Lauro Elementary School" if SchName == "Carl G. Lauro El. School"
replace SchName = "Chariho Alternative Learning Academy" if SchName == "Chariho Alternative Learning A"
replace SchName = "Claiborne Pell Elementary School" if SchName == "Claiborne Pell Elementary"
replace SchName = "Clayville Elementary School" if SchName == "Clayville School"
replace SchName = "The Sgt. Cornel Young Jr & Charlotte Woods Elementary School @ The B. Jae Clanton Complex" if SchName == "Cornel Young & Charlotte Woods"
replace SchName = "M. Virginia Cunningham School" if SchName == "Cunningham School"
replace SchName = "Curvin-McCabe School" if SchName == "Curvin-McCabe School          "      
replace SchName = "DCYF Alternative Education Program" if SchName == "DCYF Alternative Ed. Program"
replace SchName = "Dr. Edward A. Ricci Middle School" if SchName == "Dr. Edward Ricci School"
replace SchName = "Dr. Harry L. Halliwell Memorial School" if SchName == "Dr. Halliwell School"
replace SchName = "Dunn s Corners School" if SchName == "Dunn's Corners School"
replace SchName = "Edgewood Highland School" if SchName == "Edgewood Highland"
replace SchName = "Edward R. Martin Middle School" if SchName == "Edward Martin Middle"
replace SchName = "Edward S. Rhodes School" if SchName == "Edward S. Rhodes School       "
replace SchName = "Esek Hopkins Middle School" if SchName == "Esek Hopkins Middle"
replace SchName = "Exeter-West Greenwich Regional  Junior High" if SchName == "Exeter-West Greenwich Reg. Jr."
replace SchName = "Fishing Cove Elementary School" if SchName == "Fishing Cove El. School"
replace SchName = "Flora S. Curtis Memorial School" if SchName == "Flora S. Curtis School"
replace SchName = "Fogarty Memorial School" if SchName == "Fogarty Memorial"
replace SchName = "Forest Park Elementary School" if SchName == "Forest Park El. School"
replace SchName = "Frank D. Spaziano Elementary School" if SchName == "Frank D. Spaziano Elem School"
replace SchName = "Frank E. Thompson Middle School" if SchName == "Frank E. Thompson Middle"
replace SchName = "Garden City School" if SchName == "Garden City School            "
replace SchName = "Garvin Memorial School" if SchName == "Garvin Memorial"
replace SchName = "George J. West Elementary School" if SchName == "George J. West El. School"
replace SchName = "Globe Park School" if SchName == "Globe Park School             "
replace SchName = "Governor Christopher DelSesto Middle School" if SchName == "Governor Christopher DelSesto "
replace SchName = "Hamilton Elementary School" if SchName == "Hamilton School"
replace SchName = "Harry Kizirian Elementary School" if SchName == "Harry Kizirian Elementary"
replace SchName = "Highlander Elementary Charter School" if SchName == "Highlander Elementary Charter "
replace SchName = "Highlander Secondary Charter School" if SchName == "Highlander Secondary Charter S"
replace SchName = "Highlander Charter School" if SchName == "Highlander Charter"
replace SchName = "Randall Holden School" if SchName == "Holden School"
replace SchName = "Hope Elementary School" if SchName == "Hope School                   "
replace SchName = "Cottrell F. Hoxsie School" if SchName == "Hoxsie School"
replace SchName = "James H. Eldredge El. School" if SchName == "James H. Eldredge School"
replace SchName = "John F. Deering Middle School" if SchName == "John F. Deering Middle"
replace SchName = "John F. Horgan Elementary School" if SchName == "John F. Horgan School"
replace SchName = "John J. McLaughlin Cumberland Hill School" if SchName == "John J. McLaughlin Cumberland"
replace SchName = "Dr. Joseph A Whelan Elementary School" if SchName == "Joseph A. Whelan School"
replace SchName = "Joseph H. Gaudet Learning Academy" if SchName == "Joseph Gaudet Academy"
replace SchName = "Joseph L. McCourt Middle School" if SchName == "Joseph L. McCourt MS"
replace SchName = "Kevin K. Coleman Elementary School" if SchName == "Kevin K. Coleman School"
replace SchName = "Lillian Feinstein Elementary Sackett Street" if SchName == "Lillian Feinstein El. School"
replace SchName = "Lincoln Central Elementary School" if SchName == "Lincoln Central Elem."
replace SchName = "Lonsdale Elementary School" if SchName == "Lonsdale Elementary"
replace SchName = "Marieville Elementary School" if SchName == "Marieville School"
replace SchName = "Dr. Martin Luther King, Jr. Elementary School" if SchName == "Martin Luther King El. School"
replace SchName = "Mary E. Fogarty Elementary School" if SchName == "Mary E. Fogarty El. School"
replace SchName = "Melville Elementary School" if SchName == "Melville School"
replace SchName = "Myron J. Francis Elementary School" if SchName == "Myron J. Francis Elementary"
replace SchName = "Narragansett Elementary School" if SchName == "Narragansett Elementary"
replace SchName = "Nathan Bishop Middle School" if SchName == "Nathan Bishop Middle"
replace SchName = "Nathanael Greene Middle School" if SchName == "Nathanael Greene Middle"
replace SchName = "Nicholas A. Ferri Middle School" if SchName == "Nicholas A. Ferri Middle"
replace SchName = "North Cumberland Middle School" if SchName == "North Cumberland Middle"
replace SchName = "North Scituate Elementary School" if SchName == "North Scituate School"
replace SchName = "North Smithfield Elementary School" if SchName == "North Smithfield Elementary"
replace SchName = "North Smithfield Middle School" if SchName == "North Smithfield MS"
replace SchName = "Northern Lincoln Elementary School" if SchName == "Northern Lincoln Elem."
replace SchName = "Nuestro Mundo Public Charter School" if SchName == "Nuestro Mundo Public Charter S"
replace SchName = "Oakland Beach Elementary School" if SchName == "Oakland Beach School"
replace SchName = "Orchard Farms Elementary School" if SchName == "Orchard Farms El. School"
replace SchName = "Peace Dale Elementary School" if SchName == "Peace Dale School"
replace SchName = "Pleasant View School" if SchName == "Pleasant View Elementary Schoo"
replace SchName = "Pothier-Citizens Elementary Campus" if SchName == "Pothier-Citizens Elem Campus"
replace SchName = "Providence Preparatory Charter School" if SchName == "Providence Preparatory Charter" 
replace SchName = "Rhode Island School for the Deaf" if SchName == "R.I. School for the Deaf" 
replace SchName = "RISE Prep Mayoral Academy Middle School" if SchName == "RISE Prep Mayoral Acad Middle"
replace SchName = "RISE Prep Mayoral Academy Elementary School" if SchName == "RISE Prep Mayoral Academy Ele"
replace SchName = "Raices Dual Language Academy at Margaret I. Robertson School" if SchName == "Raices Dual Language Academy"
replace SchName = "Walter E. Ranger School" if SchName == "Ranger School"
replace SchName = "Raymond C. LaPerche School" if SchName == "Raymond LaPerche School"
replace SchName = "Robert F. Kennedy Elementary School" if SchName == "Robert F. Kennedy El. School"
replace SchName = "Robert L Bailey IV Elementary School" if SchName == "Robert L. Bailey IV"
replace SchName = "E. G. Robertson School" if SchName == "Robertson School"
replace SchName = "Roger Williams Middle School" if SchName == "Roger Williams Middle"
replace SchName = "Saylesville Elementary School" if SchName == "Saylesville Elementary"
replace SchName = "Harold F. Scott School" if SchName == "Scott School"
replace SchName = "Segue Institute for Learning" if SchName == "Segue Inst for Learning"
replace SchName = "SouthSide Elementary Charter School" if SchName == "SouthSide Elementary Charter"
replace SchName = "Stone Hill School" if SchName == "Stone Hill School             "
replace SchName = "Stony Lane Elementary School" if SchName == "Stony Lane El. School"
replace SchName = "Suzanne M. Henseler Quidnessett Elementary School" if SchName == "Suzanne M. Henseler Quidnesset"
replace SchName = "The Learning Community Charter School" if SchName == "The Learning Community"
replace SchName = "The R.Y.S.E. School" if SchName == "The R.Y.S.E School"
replace SchName = "Trinity Academy for the Performing Arts" if SchName == "Trinity Academy Performing Art"
replace SchName = "Urban Collaborative Accelerated Program" if SchName == "Urban Collaborative Program"
replace SchName = "Vartan Gregorian Elementary School" if SchName == "Vartan Gregorian El. School"
replace SchName = "Vincent J. Gallagher Middle School" if SchName == "Vincent J. Gallagher Middle"
replace SchName = "William R. Dutemple School" if SchName == "W. R. Dutemple School"
replace SchName = "Alice M. Waddington School" if SchName == "Waddington School"
replace SchName = "Wakefield Hills Elementary School" if SchName == "Wakefield Hills El. School"
replace SchName = "Wakefield Elementary School" if SchName == "Wakefield School"
replace SchName = "Warwick Veterans Jr. High School" if SchName == "Warwick Veterans Jr. High Sch"
replace SchName = "West Kingston Elementary School" if SchName == "West Kingston School"
replace SchName = "Western Hills Middle School" if SchName == "Western Hills Middle School   "
replace SchName = "John Wickes School" if SchName == "Wickes School"
replace SchName = "William L. Callahan School" if SchName == "William Callahan School       "
replace SchName = "William D Abate Elementary School" if SchName == "William D'Abate Elem. School"
replace SchName = "Woonsocket Middle School at Villa Nova" if SchName == "Woonsocket Middle @ Villa Nova"
replace SchName = "Woonsocket Middle School at Hamlet" if SchName == "Woonsocket Middle at Hamlet"
replace SchName = "Exeter-West Greenwich Regional Junior High" if SchName == "Exeter-West Greenwich Regional  Junior High"
//StateAssignedDistID and StateAssignedSchID


//Merging
tempfile temp1
save "`temp1'", replace
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
clear
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear
import excel "`Original'/Downloading RICAS subgroup data by grade.xlsx", firstrow case(preserve) allstring
rename A StateAssignedDistID
rename C StateAssignedSchID
rename B DistName
rename D SchName
drop if StateAssignedDistID == "District Code"
drop E F

//Replacing DistNames (THANK YOU WILL!!!)
replace DistName = "Beacon Charter" if DistName == "Beacon Charter School"
replace DistName = "Blackstone Valley Prep" if DistName == "Blackstone Valley Prep, A RI Mayoral Academy"
replace DistName = "Compass" if DistName == "The Compass School"
replace DistName = "Exeter-W. Greenw" if DistName == "Exeter-West Greenwich"
replace DistName = "International" if DistName == "International Charter"
replace DistName = "Kingston Hill" if DistName == "Kingston Hill Academy"
replace DistName = "Learning" if DistName == "Learning Community"
replace DistName = "Paul Cuffee" if DistName == "Paul Cuffee Charter Sch"
replace DistName = "RI Deaf" if DistName == "R.I. Sch for the Deaf"
replace DistName = "Segue Inst for Learning" if DistName == "Segue Institute for Learning"
replace DistName = "Trinity Academy Performing Art" if DistName == "Trinity Academy for the Performing Arts"
replace DistName = "UCAP" if DistName == "Urban Collaborative"

tempfile temp2
save "`temp2'", replace

//StateAssignedDistID
duplicates drop DistName, force
merge 1:m DistName using "`tempdist'"
replace SchName = "All Schools"
save "`tempdist'", replace
clear

//StateAssignedSchID
use "`temp2'"
duplicates drop SchName, force
merge 1:m SchName using "`tempsch'"
save "`tempsch'", replace
clear

//Adding Together
use "`temp1'"
keep if DataLevel == 1
append using "`tempdist'" "`tempsch'"

//Fixing Unmerged
replace StateAssignedDistID = "84" if DistName == "Excel Academy Rhode Island" // NCES: 440120100543
replace StateAssignedSchID = "41605" if SchName == "Achievement First Promesa" // NCES: 440002100533
replace StateAssignedSchID = "08601" if SchName == "Blackstone Valley Prep" //NCES: 440001500473
replace StateAssignedSchID = "84601" if SchName == "Excel Academy Rhode Island" // NCES: 440120100543
replace StateAssignedSchID = "28182" if SchName == "Governor Christopher DelSesto" //NCES: 440090000175
replace StateAssignedSchID = "48601" if SchName == "Highlander Elementary Charter" //440003100524
replace StateAssignedSchID = "30102" if SchName == "Hope School" // 440096000253
replace StateAssignedSchID = "39602" if SchName == "RISE Prep Mayoral Academy" //440002900494
replace StateAssignedSchID = "04118" if SchName == "Raices Upper Dual Language Acd" //440012000542
replace StateAssignedSchID = "03107" if SchName == "William Callahan School" //440009000022
drop if missing(GradeLevel)
drop _merge
//Merging NCES data
tempfile temp1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel == 2
replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 1
tempfile tempdist
save "`tempdist'", replace
clear
use "`NCES'/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District"
keep if state_location == "RI" | state_fips_id == 44
gen StateAssignedDistID = subinstr(state_leaid, "RI-","",.)
duplicates drop StateAssignedDistID, force
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge == 1
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel == 3
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 4
tempfile tempsch
save "`tempsch'", replace
clear
use "`NCES'/NCES School Files, Fall 1997-Fall 2022/NCES_2022_School"
keep if state_location == "RI" | state_fips_id == 44
gen StateAssignedSchID = substr(seasch, -5,5)
decode district_agency_type, gen(DistType)
drop district_agency_type
rename DistType district_agency_type
duplicates drop StateAssignedSchID, force
keep ncesdistrictid ncesschoolid seasch state_leaid district_agency_type DistLocale county_code county_name DistCharter school_type SchLevel SchVirtual StateAssignedSchID
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge == 1
save "`tempsch'", replace
clear

//Adding Together
use "`temp1'"
keep if DataLevel == 1
append using "`tempdist'" "`tempsch'"
drop if _merge == 1
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
replace StateFips = 44
replace StateAbbrev = "RI"

//Generating additional variables
gen State = "Rhode Island"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen ProficiencyCriteria = "Levels 3-4"
gen Lev5_percent = ""
gen Lev5_count = ""
gen AssmtType = "Regular"
gen AssmtName = "RICAS"
replace AssmtName = "NGSA" if Subject == "sci"
forvalues n = 1/4 {
	gen Lev`n'_count = round(nLev`n'_percent * nStudentSubGroup_TotalTested)
	tostring Lev`n'_count, replace
	replace Lev`n'_count = "*" if Lev`n'_count == "."
}
gen ProficientOrAbove_count = round(nProficientOrAbove_percent * nStudentSubGroup_TotalTested)
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
//gen ParticipationRate = "--"

//StateAssignedDistID for previously unmerged
replace StateAssignedDistID = subinstr(State_leaid, "RI-","",.) if missing(StateAssignedDistID) & DataLevel !=1

//Final Cleaning
drop if StudentSubGroup_TotalTested == "0"
replace StateAssignedSchID = "" if DataLevel != 3
replace SchName = "All Schools" if DataLevel !=3
replace Lev4_percent = "0" if SchName == "West Broadway Middle School" & Subject == "ela" & GradeLevel == "G06" & StudentSubGroup == "Black or African American"
replace Lev4_count = "0" if SchName == "West Broadway Middle School" & Subject == "ela" & GradeLevel == "G06" & StudentSubGroup == "Black or African American"
replace StateAssignedDistID = "0" + StateAssignedDistID if DataLevel != 1 & strlen(StateAssignedDistID) == 1

// ParticipationRate Cleaning
	replace ParticipationRate = subinstr(ParticipationRate, "%", "",.)
	destring ParticipationRate, generate(nParticipationRate) ignore("*")
	replace nParticipationRate = nParticipationRate / 100 if nParticipationRate != .
	tostring nParticipationRate, replace force
	replace ParticipationRate = nParticipationRate if ParticipationRate != "*"
	drop nParticipationRate

	
// generating counts 5/31/24
destring StudentSubGroup_TotalTested, replace 

local a  "1 2 3 4 5" 
foreach b in `a' {


destring Lev`b'_percent, replace ignore("*")
destring Lev`b'_count, replace ignore("*")

replace Lev`b'_count = Lev`b'_percent * StudentSubGroup_TotalTested if Lev`b'_count == . & Lev`b'_percent != .
replace Lev`b'_count = round(Lev`b'_count, 1)

tostring Lev`b'_percent, replace force 
tostring Lev`b'_count, replace force

replace Lev`b'_percent = "*" if  Lev`b'_percent == "." 
replace Lev`b'_count = "*" if  Lev`b'_count == "." 

}

replace Lev5_percent = "" if  Lev5_percent == "*" 
replace Lev5_count = "" if  Lev5_count == "*" 

destring ProficientOrAbove_percent, replace ignore("*")
destring ProficientOrAbove_count, replace ignore("*")

replace ProficientOrAbove_count = ProficientOrAbove_percent * StudentSubGroup_TotalTested if ProficientOrAbove_count == . &  ProficientOrAbove_percent != .
replace ProficientOrAbove_count = round(ProficientOrAbove_count, 1)

tostring ProficientOrAbove_percent, replace force
tostring ProficientOrAbove_count, replace force
tostring StudentSubGroup_TotalTested, replace force

replace ProficientOrAbove_percent = "*" if  ProficientOrAbove_percent == "." 
replace ProficientOrAbove_count = "*" if  ProficientOrAbove_count == "." 
replace StudentSubGroup_TotalTested = "*" if  StudentSubGroup_TotalTested == "." 
	
		

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


save "`Output'/RI_AssmtData_2023", replace
export delimited "`Output'/RI_AssmtData_2023", replace
