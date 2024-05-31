clear


global path "/Users/benjaminm/Documents/State_Repository_Research/Rhode Island"
global nces "/Users/benjaminm/Documents/State_Repository_Research/NCES District and School Demographics"
global nces_clean "/Users/benjaminm/Documents/State_Repository_Research/NCES District and School Demographics/Cleaned NCES Data"


//
// global path "/Users/miramehta/Documents/RI State Testing Data"
// global nces "/Users/miramehta/Documents/NCES District and School Demographics"
// global nces_clean "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

	import excel "${path}/Original Data Files/RI_OriginalData_2022_ela.xlsx", firstrow clear

global ncesyears 2017 2018 2020 2021
foreach n in $ncesyears {
	
	** NCES School Data

	use "${nces}/NCES School Files, Fall 1997-Fall 2022/NCES_`n'_School.dta", clear

	** Rename Variables

	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename ncesschoolid NCESSchoolID
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode

	**Fix School Misspellings
	replace school_name = "Pleasant View Elementary School" if school_name=="Pleasant View Elementary Schoo"
	replace school_name = "Providence Preparatory Charter School" if school_name=="Providence Preparatory Charter"

	** Drop Excess Variables
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID lea_name school_name seasch State_leaid DistType DistLocale CountyCode CountyName DistCharter SchType SchLevel SchVirtual
	
	** Isolate Rhode Island Data
	
	drop if StateFips != 44
	local m = `n' - 1999
	save "${nces_clean}/NCES_`n'_School_RI.dta", replace

	** NCES District Data

	clear
	use "${nces}/NCES District Files, Fall 1997-Fall 2022/NCES_`n'_District.dta"

	** Rename Variables

	rename ncesdistrictid NCESDistrictID
	rename state_name State
	rename state_leaid State_leaid
	rename state_location StateAbbrev
	rename county_code CountyCode
	rename county_name CountyName
	rename district_agency_type DistType
	rename state_fips StateFips

	** Drop Excess Variables
	keep State StateAbbrev StateFips NCESDistrictID lea_name State_leaid DistType DistLocale CountyCode CountyName DistCharter
	** Isolate Rhode Island Data

	drop if StateFips != 44
	save "${nces_clean}/NCES_`n'_District_RI.dta", replace
}


global years 2018 2019 2021 2022
foreach y in $years {
	local z = `y' - 1
	local x = `y' - 2000
	
	** State-Assigned IDs
	
	import excel "${path}/Original Data Files/RI_OriginalData_`y'_ela.xlsx", firstrow clear
	rename DistrictCode StateAssignedDistID
	rename DistrictName DistName
	keep StateAssignedDistID DistName
	sort StateAssignedDistID DistName
    quietly by StateAssignedDistID DistName:  gen dup = cond(_N==1,0,_n)
	drop if dup>1
	drop dup
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
	save "${path}/Semi-Processed Data Files/`y'_distid.dta", replace
	
	import excel "${path}/Original Data Files/RI_OriginalData_`y'_ela.xlsx", firstrow clear
	rename SchoolCode StateAssignedSchID
	rename SchoolName SchName
	keep StateAssignedSchID SchName
	sort StateAssignedSchID SchName
    quietly by StateAssignedSchID SchName:  gen dup = cond(_N==1,0,_n)
	drop if dup>1
	drop dup
	save "${path}/Semi-Processed Data Files/`y'_schid.dta", replace
	
	** Math Data
	
	import excel "${path}/Original Data Files/ri_ricas_math.xlsx", firstrow clear
	replace SchName = "AF Iluminar Mayoral Academy Middle" if SchName == "AF Iluminar Mayoral Middle Sch"
	replace SchName = "AF Providence Mayoral Academy Middle" if SchName == "AF Providence Mayoral Middle"
	replace SchName = "Achievement First Iluminar Mayoral Academy" if SchName == "Achievement First Iluminar"
	replace SchName = "Achievement First Providence Mayoral Academy" if SchName == "Achievement First Providence"
	replace SchName = "Alan Shawn Feinstein Elementary at Broad Street" if SchName == "Alan Shawn Feinstein Elem."
	replace SchName = "Alan Shawn Feinstein Middle School Of Coventry" if SchName == "Alan Shawn Feinstein MS of Cov"
	replace SchName = "Alfred Lima, Sr. Elementary School" if SchName == "Alfred Lima Sr. El School"  & `y' < 2021 | SchName == "Alfred Lima, Sr. El School" & `y' < 2021
	replace SchName = "Alfred Lima Sr. Elementary School" if SchName == "Alfred Lima Sr. El School" & `y' >= 2021 | SchName == "Alfred Lima, Sr. El School" & `y' >= 2021 
	replace SchName = "Anthony Carnevale Elementary School" if SchName == "Anthony Carnevale Elementary"
	replace SchName = "Archie R. Cole Middle School" if SchName == "Archie R. Cole MS"
	replace SchName = "Asa Messer Elementary School" if SchName == "Asa Messer El. School"
	replace SchName = "Blackstone Valley Prep Elementary 2 School" if SchName == "Blackstone Valley Prep E. 2"
	replace SchName = "Blackstone Valley Prep Elementary School" if SchName == "Blackstone Valley Prep Element" | SchName == "Blackstone Valley Prep" & GradeLevel == "03" | SchName == "Blackstone Valley Prep" & GradeLevel == "04" 
	replace SchName = "Blackstone Valley Prep Middle School" if SchName == "Blackstone Valley Prep Jr High" & `y' < 2021 | SchName == "Blackstone Valley Prep" & GradeLevel == "05" | SchName == "Blackstone Valley Prep" & GradeLevel == "06" | SchName == "Blackstone Valley Prep" & GradeLevel == "07" | SchName == "Blackstone Valley Prep" & GradeLevel == "08" // ?
	replace SchName = "Blackstone Valley Prep Junior High School" if SchName == "Blackstone Valley Prep Jr High" & `y' >= 2021
	replace SchName = "Blackstone Valley Prep Middle School 2" if SchName == "Blackstone Valley Prep Upper E" & `y' < 2021  | SchName == "Blackstone Valley Prep Mid2 " & `y' < 2021  // ?
	replace SchName = "Blackstone Valley Prep Upper Elementary School" if SchName == "Blackstone Valley Prep Upper E" & `y' >= 2021 
	replace SchName = "Dr. Earl F. Calcutt Middle School" if SchName == "Calcutt Middle School"
	replace SchName = "Captain Isaac Paine Elementary School" if SchName == "Capt. Isaac Paine El. School"
	replace SchName = "Carl G. Lauro Elementary School" if SchName == "Carl G. Lauro El. School"
	replace SchName = "Chariho Alternative Learning Academy" if SchName == "Chariho Alternative Learning A"
	replace SchName = "Claiborne Pell Elementary School" if SchName == "Claiborne Pell Elementary"
	replace SchName = "Clayville Elementary School" if SchName == "Clayville School"
	replace SchName = "The Sgt. Cornel Young, Jr & Charlotte Woods Elementary School @ The B. Joe Clanton Complex" if SchName == "Cornel Young & Charlotte Woods" & `y' < 2019 | SchName == "The Sgt. Cornel Young, Jr & Charlotte Woods Elementary School @ The B. Jae Clanton Complex" & `y' < 2021
	replace SchName = "The Sgt. Cornel Young, Jr & Charlotte Woods Elementary School @ The B. Jae Clanton Complex" if SchName == "Cornel Young & Charlotte Woods" & `y' == 2019 
	replace SchName = "The Sgt. Cornel Young Jr & Charlotte Woods Elementary School @ The B. Jae Clanton Complex" if SchName == "Cornel Young & Charlotte Woods" & `y' > 2019 
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
	replace SchName = "Joseph H. Gaudet Learning Academy" if inlist(SchName, "Joseph Gaudet Academy", "Gaudet Learning Academy")
	replace SchName = "Joseph H. Gaudet School" if SchName == "Gaudet Middle School"
	replace SchName = "Joseph L. McCourt Middle School" if SchName == "Joseph L. McCourt MS"
	replace SchName = "Kevin K. Coleman Elementary School" if SchName == "Kevin K. Coleman School"
	replace SchName = "Lillian Feinstein Elementary, Sackett Street" if SchName == "Lillian Feinstein El. School" & `y' < 2021
	replace SchName = "Lillian Feinstein Elementary Sackett Street" if SchName == "Lillian Feinstein El. School" & `y' >= 2021 
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
	replace SchName = "Robert L Bailey IV, Elementary School" if SchName == "Robert L. Bailey IV" & `y' < 2021 | SchName == "Robert L. Bailey, IV" & `y' < 2021
	replace SchName = "Robert L Bailey IV Elementary School" if SchName == "Robert L. Bailey IV" & `y' >= 2021 | SchName == "Robert L. Bailey, IV" & `y' >= 2021 
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
	merge m:1 DistName using "${path}/Semi-Processed Data Files/`y'_distid.dta"
	drop _merge
	merge m:1 SchName using "${path}/Semi-Processed Data Files/`y'_schid.dta"
	drop _merge
	keep if SchYear == "`z'-`x'"
	gen Subject = "ela"
	gen AssmtName = "RICAS"
	gen DataLevel = "School"
	replace DataLevel = "District" if SchName == "All Schools" | SchName == "N/A"
	replace DataLevel = "State" if DistName == "Statewide"
	drop Low_Growth	Typ_Growth High_Growth Avg_Growth_
	
	** Rename Variables
	
	rename NME Lev1_percent
	rename PME Lev2_percent
	rename ME Lev3_percent
	rename EE Lev4_percent
	rename MOEE	ProficientOrAbove_percent
	rename Avg_Scale_Score AvgScaleScore
	rename TotalTested StudentSubGroup_TotalTested
	rename G ParticipationRate
	sort DistName SchName GradeLevel StudentSubGroup 
	quietly by DistName SchName GradeLevel StudentSubGroup :  gen dup = cond(_N==1,0,_n)
	drop if dup>1
	drop dup
	
	** Standardize Subgroup Data
	replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
	replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian or Other Pacific Islander"
	gen StudentGroup="RaceEth"
	replace StudentGroup="Economic Status" if StudentGroup=="Economically Disadvantaged" | StudentSubGroup=="Economically Disadvantaged" | StudentSubGroup=="Not Economically Disadvantaged"
	replace StudentSubGroup="Unknown" if StudentSubGroup=="Other"
	replace StudentGroup="Gender" if StudentSubGroup == "Male" | StudentSubGroup=="Female" | StudentSubGroup == "Unknown"
	replace StudentSubGroup="English Learner" if StudentSubGroup=="Current English Learners"
	replace StudentSubGroup="English Proficient" if StudentSubGroup=="Not English Learners"
	replace StudentSubGroup="EL Monit or Recently Ex" if StudentSubGroup=="Recently (3 yrs) Exited English Learners"
	replace StudentGroup="EL Status" if StudentSubGroup=="English Learner" | StudentSubGroup=="English Proficient"
	replace StudentGroup="EL Monit or Recently Ex" if StudentSubGroup=="EL Monit or Recently Ex"
	replace StudentSubGroup = "All Students" if StudentSubGroup == "" | StudentSubGroup == "All Groups"
	replace StudentGroup="All Students" if StudentSubGroup=="All Students"
	replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"
	replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Homeless"
	replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Students in Foster Care"
	replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Students not in Foster Care"
	replace StudentSubGroup = "Military" if StudentSubGroup == "Students with Active Military Parent"
	replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Students without Active Military Parent"
	replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
	replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without Disabilities"
	replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
	replace StudentGroup = "Foster Care Status" if inlist(StudentSubGroup, "Foster Care", "Non-Foster Care")
	replace StudentGroup = "Migrant Status" if inlist(StudentSubGroup, "Homeless", "Non-Homeless")
	replace StudentGroup = "Homeless Enrolled Status" if inlist(StudentSubGroup, "Migrant", "Non-Migrant")
	replace StudentGroup = "Military Connected Status" if inlist(StudentSubGroup, "Military", "Non-Military")
	
	save "${path}/Semi-Processed Data Files/`y'_ela_group_missing.dta", replace

	** Generate Student Group Counts

	keep if StudentSubGroup == "All Students"
	drop Lev1_percent Lev2_percent Lev3_percent Lev4_percent ParticipationRate ProficientOrAbove_percent AvgScaleScore SchYear StudentSubGroup Subject AssmtName StudentGroup
	rename StudentSubGroup_TotalTested AllStudents_Tested
	destring AllStudents_Tested, replace
	merge 1:m DistName SchName GradeLevel using "${path}/Semi-Processed Data Files/`y'_ela_group_missing.dta"
	
	destring StudentSubGroup_TotalTested, gen(Tested)
	drop _merge	
	bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen test = min(Tested)
	bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(Tested) if test != 0
	drop test
	tostring StudentGroup_TotalTested, replace
	replace StudentGroup_TotalTested = "*" if inlist(StudentGroup_TotalTested, "", ".")
	
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	gen Suppressed = 0
	replace Suppressed = 1 if inlist(StudentSubGroup_TotalTested, "--", "*")
	egen StudentGroup_Suppressed = max(Suppressed), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID DistName SchName)
	drop Suppressed
	replace StudentGroup_TotalTested = string(AllStudents_Tested) if StudentGroup_Suppressed == 1
	replace StudentGroup_TotalTested = string(AllStudents_Tested) if StudentSubGroup == "All Students"
	destring StudentGroup_TotalTested, gen(Count) force
	replace StudentGroup_TotalTested = string(AllStudents_Tested) if Count > AllStudents_Tested
	drop AllStudents_Tested StudentGroup_Suppressed
	
	replace StudentGroup = "EL Status" if StudentSubGroup=="EL Monit or Recently Ex"

	save "${path}/Semi-Processed Data Files/`y'_ela_unmerged.dta", replace
	
	** Math Data
	
	import excel "${path}/Original Data Files/ri_ricas_math.xlsx", firstrow clear
	replace SchName = "AF Iluminar Mayoral Academy Middle School" if SchName == "AF Iluminar Mayoral Middle Sch"
	replace SchName = "AF Providence Mayoral Academy Middle" if SchName == "AF Providence Mayoral Middle"
	replace SchName = "Achievement First Iluminar Mayoral Academy" if SchName == "Achievement First Iluminar"
	replace SchName = "Achievement First Providence Mayoral Academy" if SchName == "Achievement First Providence"
	replace SchName = "Alan Shawn Feinstein Elementary at Broad Street" if SchName == "Alan Shawn Feinstein Elem."
	replace SchName = "Alan Shawn Feinstein Middle School Of Coventry" if SchName == "Alan Shawn Feinstein MS of Cov"
	replace SchName = "Alfred Lima, Sr. Elementary School" if SchName == "Alfred Lima Sr. El School"  & `y' < 2021 | SchName == "Alfred Lima, Sr. El School" & `y' < 2021
	replace SchName = "Alfred Lima Sr. Elementary School" if SchName == "Alfred Lima Sr. El School" & `y' >= 2021 | SchName == "Alfred Lima, Sr. El School" & `y' >= 2021 
	replace SchName = "Anthony Carnevale Elementary School" if SchName == "Anthony Carnevale Elementary"
	replace SchName = "Archie R. Cole Middle School" if SchName == "Archie R. Cole MS"
	replace SchName = "Asa Messer Elementary School" if SchName == "Asa Messer El. School"
	replace SchName = "Blackstone Valley Prep Elementary 2 School" if SchName == "Blackstone Valley Prep E. 2"
	replace SchName = "Blackstone Valley Prep Elementary School" if SchName == "Blackstone Valley Prep Element" | SchName == "Blackstone Valley Prep" & GradeLevel == "03" | SchName == "Blackstone Valley Prep" & GradeLevel == "04" 
	replace SchName = "Blackstone Valley Prep Middle School" if SchName == "Blackstone Valley Prep Jr High" & `y' < 2021 | SchName == "Blackstone Valley Prep" & GradeLevel == "05" | SchName == "Blackstone Valley Prep" & GradeLevel == "06" | SchName == "Blackstone Valley Prep" & GradeLevel == "07" | SchName == "Blackstone Valley Prep" & GradeLevel == "08" // ?
	replace SchName = "Blackstone Valley Prep Junior High School" if SchName == "Blackstone Valley Prep Jr High" & `y' >= 2021
	replace SchName = "Blackstone Valley Prep Middle School 2" if SchName == "Blackstone Valley Prep Upper E" & `y' < 2021  | SchName == "Blackstone Valley Prep Mid2 " & `y' < 2021  // ?
	replace SchName = "Blackstone Valley Prep Upper Elementary School" if SchName == "Blackstone Valley Prep Upper E" & `y' >= 2021 
	replace SchName = "Dr. Earl F. Calcutt Middle School" if SchName == "Calcutt Middle School"
	replace SchName = "Captain Isaac Paine Elementary School" if SchName == "Capt. Isaac Paine El. School"
	replace SchName = "Carl G. Lauro Elementary School" if SchName == "Carl G. Lauro El. School"
	replace SchName = "Chariho Alternative Learning Academy" if SchName == "Chariho Alternative Learning A"
	replace SchName = "Claiborne Pell Elementary School" if SchName == "Claiborne Pell Elementary"
	replace SchName = "Clayville Elementary School" if SchName == "Clayville School"
	replace SchName = "The Sgt. Cornel Young, Jr & Charlotte Woods Elementary School @ The B. Joe Clanton Complex" if SchName == "Cornel Young & Charlotte Woods" & `y' < 2019 | SchName == "The Sgt. Cornel Young, Jr & Charlotte Woods Elementary School @ The B. Jae Clanton Complex" & `y' < 2021
	replace SchName = "The Sgt. Cornel Young, Jr & Charlotte Woods Elementary School @ The B. Jae Clanton Complex" if SchName == "Cornel Young & Charlotte Woods" & `y' == 2019 
	replace SchName = "The Sgt. Cornel Young Jr & Charlotte Woods Elementary School @ The B. Jae Clanton Complex" if SchName == "Cornel Young & Charlotte Woods" & `y' > 2019 
	replace SchName = "M. Virginia Cunningham School" if SchName == "Cunningham School"
	replace SchName = "M. Virginia Cunningham School" if SchName == "Curvin-McCabe School          "      
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
	replace SchName = "Lillian Feinstein Elementary, Sackett Street" if SchName == "Lillian Feinstein El. School" & `y' < 2021
	replace SchName = "Lillian Feinstein Elementary Sackett Street" if SchName == "Lillian Feinstein El. School" & `y' >= 2021 
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
	replace SchName = "Providence Preparatory Charter School" if SchName == "Providence Preparatory Charter" // not found
	replace SchName = "Rhode Island School for the Deaf" if SchName == "R.I. School for the Deaf" 
	replace SchName = "RISE Prep Mayoral Academy Middle School" if SchName == "RISE Prep Mayoral Acad Middle"
	replace SchName = "RISE Prep Mayoral Academy Elementary School" if SchName == "RISE Prep Mayoral Academy Ele"
	replace SchName = "Raices Dual Language Academy at Margaret I. Robertson School" if SchName == "Raices Dual Language Academy"
	replace SchName = "Walter E. Ranger School" if SchName == "Ranger School"
	replace SchName = "Raymond C. LaPerche School" if SchName == "Raymond LaPerche School"
	replace SchName = "Robert F. Kennedy Elementary School" if SchName == "Robert F. Kennedy El. School"
	replace SchName = "Robert L Bailey IV, Elementary School" if SchName == "Robert L. Bailey IV" & `y' < 2021 | SchName == "Robert L. Bailey, IV" & `y' < 2021
	replace SchName = "Robert L Bailey IV Elementary School" if SchName == "Robert L. Bailey IV" & `y' >= 2021 | SchName == "Robert L. Bailey, IV" & `y' >= 2021 
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
	merge m:1 DistName using "${path}/Semi-Processed Data Files/`y'_distid.dta"
	tab DistName if _merge == 1
	drop _merge
	merge m:1 SchName using "${path}/Semi-Processed Data Files/`y'_schid.dta"
	tab SchName if _merge == 1
	
	drop _merge
	keep if SchYear == "`z'-`x'"
	gen Subject = "math"
	gen AssmtName = "RICAS"
	gen DataLevel = "School"
	replace DataLevel = "District" if SchName == "All Schools"
	replace DataLevel = "State" if DistName == "Statewide"
	drop Low_Growth	Typ_Growth High_Growth Avg_Growth_
	
	** Rename Variables
	
	rename NME Lev1_percent
	rename PME Lev2_percent
	rename ME Lev3_percent
	rename EE Lev4_percent
	rename MOEE	ProficientOrAbove_percent
	rename Avg_Scale_Score AvgScaleScore
	rename TotalTested StudentSubGroup_TotalTested
	rename G ParticipationRate
	sort DistName SchName GradeLevel StudentSubGroup 
	quietly by DistName SchName GradeLevel StudentSubGroup :  gen dup = cond(_N==1,0,_n)
	drop if dup>1
	drop dup
	
	** Standardize Subgroup Data
	replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
	replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian or Other Pacific Islander"
	gen StudentGroup="RaceEth"
	replace StudentGroup="Economic Status" if StudentGroup=="Economically Disadvantaged" | StudentSubGroup=="Economically Disadvantaged" | StudentSubGroup=="Not Economically Disadvantaged"
	replace StudentSubGroup="Unknown" if StudentSubGroup=="Other"
	replace StudentGroup="Gender" if StudentSubGroup=="Male" | StudentSubGroup=="Female" | StudentSubGroup == "Unknown"
	replace StudentSubGroup="English Learner" if StudentSubGroup=="Current English Learners"
	replace StudentSubGroup="English Proficient" if StudentSubGroup=="Not English Learners"
	replace StudentSubGroup="EL Monit or Recently Ex" if StudentSubGroup=="Recently (3 yrs) Exited English Learners"
	replace StudentGroup="EL Status" if StudentSubGroup=="English Learner" | StudentSubGroup=="English Proficient"
	replace StudentGroup="EL Monit or Recently Ex" if StudentSubGroup=="EL Monit or Recently Ex"
	replace StudentSubGroup = "All Students" if StudentSubGroup == "" | StudentSubGroup == "All Groups"
	replace StudentGroup="All Students" if StudentSubGroup=="All Students"
	replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"
	replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Homeless"
	replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Students in Foster Care"
	replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Students not in Foster Care"
	replace StudentSubGroup = "Military" if StudentSubGroup == "Students with Active Military Parent"
	replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Students without Active Military Parent"
	replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
	replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without Disabilities"
	replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
	replace StudentGroup = "Foster Care Status" if inlist(StudentSubGroup, "Foster Care", "Non-Foster Care")
	replace StudentGroup = "Migrant Status" if inlist(StudentSubGroup, "Homeless", "Non-Homeless")
	replace StudentGroup = "Homeless Enrolled Status" if inlist(StudentSubGroup, "Migrant", "Non-Migrant")
	replace StudentGroup = "Military Connected Status" if inlist(StudentSubGroup, "Military", "Non-Military")
	
	save "${path}/Semi-Processed Data Files/`y'_mat_group_missing.dta", replace

	** Generate Student Group Data

	keep if StudentSubGroup == "All Students"
	drop Lev1_percent Lev2_percent Lev3_percent Lev4_percent ParticipationRate ProficientOrAbove_percent AvgScaleScore SchYear StudentSubGroup Subject AssmtName StudentGroup
	rename StudentSubGroup_TotalTested AllStudents_Tested
	destring AllStudents_Tested, replace
	merge 1:m DistName SchName GradeLevel using "${path}/Semi-Processed Data Files/`y'_mat_group_missing.dta"
	drop _merge
	
	destring StudentSubGroup_TotalTested, gen(x)
	bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen test = min(x)
	bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(x) if test != 0
	drop test
	tostring StudentGroup_TotalTested, replace
	replace StudentGroup_TotalTested = "*" if inlist(StudentGroup_TotalTested, "", ".")
	
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	gen Suppressed = 0
	replace Suppressed = 1 if inlist(StudentSubGroup_TotalTested, "--", "*")
	egen StudentGroup_Suppressed = max(Suppressed), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID DistName SchName)
	drop Suppressed
	replace StudentGroup_TotalTested = string(AllStudents_Tested) if StudentGroup_Suppressed == 1
	replace StudentGroup_TotalTested = string(AllStudents_Tested) if StudentSubGroup == "All Students"
	destring StudentGroup_TotalTested, gen(Count) force
	replace StudentGroup_TotalTested = string(AllStudents_Tested) if Count > AllStudents_Tested
	drop AllStudents_Tested StudentGroup_Suppressed
	
	replace StudentGroup = "EL Status" if StudentSubGroup=="EL Monit or Recently Ex"
	
	save "${path}/Semi-Processed Data Files/`y'_mat_unmerged.dta", replace
}


global ngsayears 2019 2021 2022
foreach y in $ngsayears {
	local z = `y' - 1
	local x = `y' - 2000
	
	** Science Data

	import delimited "${path}/Original Data Files/RI_OriginalData_2019,2021,2022_sci.csv", case(preserve) stringcols(7) clear 
	keep if School_Year == "`z'-`x'"
	rename Percent_of_Students_Tested ParticipationRate
	rename District DistName
	rename School SchName
	rename Percent_Beginning_to_Meet_Expect Lev1_percent
	rename Percent_Approaching_Expectations Lev2_percent
	rename Percent_Meeting_Expectations Lev3_percent
	rename Percent_Exceeds_Expectations Lev4_percent
	rename Percent_Meeting_or_Exceeding_Exp ProficientOrAbove_percent
	rename Scale_Score AvgScaleScore
	rename Group StudentSubGroup
	rename Grade GradeLevel
	rename Number_of_Students_Tested StudentSubGroup_TotalTested
	rename ncesschoolid NCESSchoolID
	rename School_Year SchYear
	gen StateAssignedDistID = subinstr(state_leaid, "RI-", "", .)
	replace Subject = "sci"
	gen AssmtName = "NGSA"
	tostring StudentSubGroup_TotalTested, replace
	drop ncesdistrictid state_leaid school_id
	
	** Standardize Subgroup Data

	replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
	replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian or Other Pacific Islander"
	gen StudentGroup="RaceEth"
	replace StudentGroup="Economic Status" if StudentGroup=="Economically Disadvantaged" | StudentSubGroup=="Economically Disadvantaged" | StudentSubGroup=="Not Economically Disadvantaged"
	replace StudentSubGroup="Unknown" if StudentSubGroup=="Other"
	replace StudentGroup="Gender" if StudentSubGroup=="Male" | StudentSubGroup=="Female" | StudentSubGroup == "Unknown"
	replace StudentSubGroup="English Learner" if StudentSubGroup=="Current English Learners"
	replace StudentSubGroup="English Proficient" if StudentSubGroup=="Not English Learners"
	replace StudentSubGroup="EL Monit or Recently Ex" if StudentSubGroup=="Recently (3 yrs) Exited English Learners"
	replace StudentGroup="EL Status" if StudentSubGroup=="English Learner" | StudentSubGroup=="English Proficient"
	replace StudentGroup="EL Monit or Recently Ex" if StudentSubGroup=="EL Monit or Recently Ex"
	replace StudentSubGroup = "All Students" if StudentSubGroup == "" | StudentSubGroup == "All Groups"
	replace StudentGroup="All Students" if StudentSubGroup=="All Students"
	replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"
	replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Homeless"
	replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Students in Foster Care"
	replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Students not in Foster Care"
	replace StudentSubGroup = "Military" if StudentSubGroup == "Students with Active Military Parent"
	replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Students without Active Military Parent"
	replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
	replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without Disabilities"
	replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
	replace StudentGroup = "Foster Care Status" if inlist(StudentSubGroup, "Foster Care", "Non-Foster Care")
	replace StudentGroup = "Migrant Status" if inlist(StudentSubGroup, "Homeless", "Non-Homeless")
	replace StudentGroup = "Homeless Enrolled Status" if inlist(StudentSubGroup, "Migrant", "Non-Migrant")
	replace StudentGroup = "Military Connected Status" if inlist(StudentSubGroup, "Military", "Non-Military")
	
	save "${path}/Semi-Processed Data Files/`y'_sci_group_missing.dta", replace

	** Generate Student Group Data

	keep if StudentGroup == "All Students"
	drop AssmtName StateAssignedDistID Lev1_percent Lev2_percent Lev3_percent Lev4_percent ParticipationRate ProficientOrAbove_percent Subject AvgScaleScore StudentGroup NCESSchoolID SchYear StudentSubGroup
	rename StudentSubGroup_TotalTested AllStudents_Tested
	destring AllStudents_Tested, replace
	merge 1:m DistName SchName GradeLevel using "${path}/Semi-Processed Data Files/`y'_sci_group_missing.dta"
	drop _merge
	
	destring StudentSubGroup_TotalTested, gen(x)
	bysort StateAssignedDistID NCESSchoolID StudentGroup GradeLevel Subject: egen test = min(x)
	bysort StateAssignedDistID NCESSchoolID StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(x) if test != 0
	drop test
	tostring StudentGroup_TotalTested, replace
	replace StudentGroup_TotalTested = "*" if inlist(StudentGroup_TotalTested, "", ".")
	
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	gen Suppressed = 0
	replace Suppressed = 1 if inlist(StudentSubGroup_TotalTested, "--", "*")
	egen StudentGroup_Suppressed = max(Suppressed), by(StudentGroup GradeLevel Subject DataLevel NCESSchoolID StateAssignedDistID DistName SchName)
	drop Suppressed
	replace StudentGroup_TotalTested = string(AllStudents_Tested) if StudentGroup_Suppressed == 1
	replace StudentGroup_TotalTested = string(AllStudents_Tested) if StudentSubGroup == "All Students"
	destring StudentGroup_TotalTested, gen(Count) force
	replace StudentGroup_TotalTested = string(AllStudents_Tested) if Count > AllStudents_Tested
	drop AllStudents_Tested StudentGroup_Suppressed
	
	replace StudentGroup = "EL Status" if StudentGroup=="EL Monit or Recently Ex"
	
	** Merge Assessments
	
	append using "${path}/Semi-Processed Data Files/`y'_ela_unmerged.dta" "${path}/Semi-Processed Data Files/`y'_mat_unmerged.dta"
	
	replace StateAssignedDistID = "69" if DistName == "Nustro Mundo Public Charter"
	replace StateAssignedDistID = "83" if DistName == "Providence Preparatory Charter"
	replace StateAssignedDistID = "79" if DistName == "RISE Prep Mayoral Academy"
	replace StateAssignedSchID = "98108" if SchName == "Chariho Alternative Learning Academy"
	replace StateAssignedSchID = "48601" if SchName == "Highlander Elementary Charter School"
	replace StateAssignedSchID = "48602" if SchName == "Highlander Seecondary Charter School"
	replace StateAssignedSchID = "69601" if SchName == "Nuestro Mundo Public Charter School"
	replace StateAssignedSchID = "51601" if SchName == "Paul Cuffee Lower School"
	replace StateAssignedSchID = "51602" if SchName == "Paul Cuffee Middle School"
	replace StateAssignedSchID = "39133" if SchName == "Pothier-Citizens Elementary Campus"
	replace StateAssignedSchID = "83601" if SchName == "Providence Preparatory Charter School"
	replace StateAssignedSchID = "39602" if SchName == "RISE Prep Mayoral Academy"
	replace StateAssignedSchID = "04112" if SchName == "Raices Dual Language Academy at Margaret I. Robertson School"
	replace StateAssignedSchID = "28197" if SchName == "Times2 Elementary School"
	replace StateAssignedSchID = "28198" if SchName == "Times2 Middle/High School"
	replace StateAssignedSchID = "35142" if SchName == "Warwick Veterans Middle School"
	replace StateAssignedSchID = "35139" if SchName == "Winman Middle School"
	
	save "${path}/Semi-Processed Data Files/`y'_merged.dta", replace
}


clear
use "${path}/Semi-Processed Data Files/2018_mat_unmerged.dta"
append using "${path}/Semi-Processed Data Files/2018_ela_unmerged.dta"
save "${path}/Semi-Processed Data Files/2018_merged.dta", replace

replace StateAssignedDistID = "69" if DistName == "Nustro Mundo Public Charter"
replace StateAssignedDistID = "83" if DistName == "Providence Preparatory Charter"
replace StateAssignedDistID = "79" if DistName == "RISE Prep Mayoral Academy"
replace StateAssignedSchID = "98108" if SchName == "Chariho Alternative Learning Academy"
replace StateAssignedSchID = "48601" if SchName == "Highlander Elementary Charter School"
replace StateAssignedSchID = "48602" if SchName == "Highlander Seecondary Charter School"
replace StateAssignedSchID = "69601" if SchName == "Nuestro Mundo Public Charter School"
replace StateAssignedSchID = "51601" if SchName == "Paul Cuffee Lower School"
replace StateAssignedSchID = "51602" if SchName == "Paul Cuffee Middle School"
replace StateAssignedSchID = "39133" if SchName == "Pothier-Citizens Elementary Campus"
replace StateAssignedSchID = "83601" if SchName == "Providence Preparatory Charter School"
replace StateAssignedSchID = "39602" if SchName == "RISE Prep Mayoral Academy"
replace StateAssignedSchID = "04112" if SchName == "Raices Dual Language Academy at Margaret I. Robertson School"
replace StateAssignedSchID = "28197" if SchName == "Times2 Elementary School"
replace StateAssignedSchID = "28198" if SchName == "Times2 Middle/High School"
replace StateAssignedSchID = "35142" if SchName == "Warwick Veterans Middle School"
replace StateAssignedSchID = "35139" if SchName == "Winman Middle School"

foreach y in $years {
	clear
	local z = `y' - 1
	local x = `y' - 2000
	
	use "${path}/Semi-Processed Data Files/`y'_merged.dta"
	
	** Generate Flags

	gen Flag_AssmtNameChange = "N"
	replace Flag_AssmtNameChange = "Y" if `y' == 2018
	replace Flag_AssmtNameChange = "Y" if AssmtName == "NGSA" & `y' == 2019
	gen Flag_CutScoreChange_ELA = "N"
	replace Flag_CutScoreChange_ELA = "Y" if `y' == 2018
	gen Flag_CutScoreChange_math = "N"
	replace Flag_CutScoreChange_math = "Y" if `y' == 2018
	gen Flag_CutScoreChange_sci = "N"
	replace Flag_CutScoreChange_sci = "Not applicable" if `y' == 2018
	replace Flag_CutScoreChange_sci = "Y" if `y' == 2019
	gen Flag_CutScoreChange_soc = "Not applicable"
	
	** Generate Other Variables

	gen AssmtType = "Regular"
	gen ProficiencyCriteria = "Levels 3-4"

	** Merging NCES Variables

	gen State_leaid = "RI-" + StateAssignedDistID if DataLevel != "State"
	gen seaschnumber = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == "School"
	merge m:1 State_leaid using "${nces_clean}/NCES_`z'_District_RI.dta"
	rename _merge district_merge
	save "${path}/Semi-Processed Data Files/`y'_distmerge.dta", replace
}

foreach y in $ngsayears {
	clear
	local z = `y' - 1
	local x = `y' - 2000
	use "${path}/Semi-Processed Data Files/`y'_distmerge.dta"
	drop State
	replace NCESSchoolID = "440090000157" if SchName == "Times2 Academy"
	replace NCESSchoolID = "440033000094" if SchName == "James R. D. Oldham School"
	merge m:1 NCESSchoolID using "${nces_clean}/NCES_`z'_School_RI.dta"
	drop if _merge == 2
	rename _merge sci_merge
	rename NCESSchoolID Sci_NCESSchoolID
	drop SchVirtual SchType SchLevel
	replace seasch = seaschnumber if Subject != "sci"
	drop seaschnumber
	merge m:1 seasch using "${nces_clean}/NCES_`z'_School_RI.dta"
	rename _merge school_merge
	replace NCESSchoolID = Sci_NCESSchoolID if NCESSchoolID == ""
	drop Sci_NCESSchoolID
	drop if district_merge != 3 & DataLevel != "State" | school_merge !=3 & DataLevel == "School" & Subject != "sci" | sci_merge !=3 & DataLevel == "School" & Subject == "sci"
	save "${path}/Semi-Processed Data Files/`y'_scimerge.dta", replace
	
	** Generate State-assigned School IDs for Science Data
	
	use "${nces_clean}/NCES_`z'_School_RI.dta"
	keep seasch NCESSchoolID
	sort seasch NCESSchoolID
    quietly by seasch NCESSchoolID:  gen dup = cond(_N==1,0,_n)
	drop if dup>1
	gen Sci_StateAssignedSchID = substr(seasch, 4, .)
	drop dup seasch
	save "${path}/Semi-Processed Data Files/`y'_sci_ids.dta", replace
	use "${path}/Semi-Processed Data Files/`y'_scimerge.dta"
	merge m:1 NCESSchoolID using "${path}/Semi-Processed Data Files/`y'_sci_ids.dta"
	replace StateAssignedSchID = Sci_StateAssignedSchID if StateAssignedSchID == ""
	save "${path}/Semi-Processed Data Files/`y'_ncesmerge.dta", replace
}	



use "${path}/Semi-Processed Data Files/2018_distmerge.dta"
rename seaschnumber seasch
merge m:1 seasch using "${nces_clean}/NCES_2018_School_RI.dta"
rename _merge school_merge
drop if district_merge != 3 & DataLevel != "State" | school_merge !=3 & DataLevel == "School"
save "${path}/Semi-Processed Data Files/2018_ncesmerge.dta", replace

foreach y in $years {
	use "${path}/Semi-Processed Data Files/`y'_ncesmerge.dta"
	drop if DataLevel == ""
	
	** Standardize School and District Names

	** Standardize Non-School Level Data and Fix Variable Types

	replace SchName = "All Schools" if DataLevel == "State"
	replace SchName = "All Schools" if DataLevel == "District"
	replace DistName = "All Districts" if DataLevel == "State"
	replace StateAssignedDistID = "" if DataLevel == "State"
	replace StateAssignedSchID = "" if DataLevel != "School"
	replace State_leaid = "" if DataLevel == "State"
	replace DistType = "" if DataLevel == "State"
	replace SchType = . if DataLevel != "School"
	replace SchLevel = . if DataLevel != "School"
	replace SchVirtual = . if DataLevel != "School"
	replace seasch = "" if DataLevel == "State" | DataLevel == "District"
	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel 
	rename DataLevel_n DataLevel 
	drop State StateAbbrev StateFips
	gen State = "Rhode Island"
	gen StateAbbrev = "RI"
	gen StateFips = 44
	recast int StateFips
	
	** Relabel GradeLevel Values 

	replace GradeLevel="G03" if GradeLevel=="03"
	replace GradeLevel="G04" if GradeLevel=="04"
	replace GradeLevel="G05" if GradeLevel=="05" | GradeLevel=="Grade: 05"
	replace GradeLevel="G06" if GradeLevel=="06"
	replace GradeLevel="G07" if GradeLevel=="07"
	replace GradeLevel="G08" if GradeLevel=="08" | GradeLevel=="Grade: 08"
	replace GradeLevel="G38" if DistName=="All Districts" & GradeLevel==""
	replace GradeLevel="G38" if GradeLevel=="STATE"
	
	** Standardize Suppressed Proficiency Data

	replace Lev1_percent="*" if Lev1_percent=="**" | Lev1_percent=="N/A"
	replace Lev2_percent="*" if Lev2_percent=="**" | Lev2_percent=="N/A"
	replace Lev3_percent="*" if Lev3_percent=="**" | Lev3_percent=="N/A"
	replace Lev4_percent="*" if Lev4_percent=="**" | Lev4_percent=="N/A"
	
	replace Lev1_percent = subinstr(Lev1_percent, "1-Not Meeting Expectations: ", "",.)
	replace Lev2_percent = subinstr(Lev2_percent, "2-Partially Meeting Expectations: ", "",.)
	replace Lev3_percent = subinstr(Lev3_percent, "3-Meeting Expectations: ", "",.)
	replace Lev4_percent = subinstr(Lev4_percent, "4-Exceeding Expectations: ", "",.)
	
	** Convert Proficiency Data into Percentages	
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
		destring Lev`i'_percent, g(Lev`i') i(* -)
		replace Lev`i' = Lev`i' / 100 if Lev`i' != .
		gen Lev`i'_count = round(Lev`i' * Tested)
		tostring Lev`i'_count, replace
		replace Lev`i'_count = "*" if Lev`i'_count == "."
		tostring Lev`i', replace format("%7.3g") force
		replace Lev`i'_percent = Lev`i' if Lev`i'_percent != "*"
		drop Lev`i'
	}

	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "N/A"
	replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "%", "",.)
	destring ProficientOrAbove_percent, generate(nProficientOrAbove_percent) force
	replace nProficientOrAbove_percent = nProficientOrAbove_percent / 100 if nProficientOrAbove_percent != .
	gen ProficientOrAbove_count = round(nProficientOrAbove_percent * x)
	tostring ProficientOrAbove_count, replace
	replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
	tostring nProficientOrAbove_percent, replace force
	replace ProficientOrAbove_percent = nProficientOrAbove_percent if ProficientOrAbove_percent != "*"
	drop nProficientOrAbove_percent x
	replace ParticipationRate = subinstr(ParticipationRate, "%", "",.)
	destring ParticipationRate, generate(nParticipationRate) ignore("*")
	replace nParticipationRate = nParticipationRate / 100 if nParticipationRate != .
	tostring nParticipationRate, replace force
	replace ParticipationRate = nParticipationRate if ParticipationRate != "*"
	drop nParticipationRate
	
	replace AvgScaleScore = "*" if AvgScaleScore == "N/A"
	
	** Other
	replace StudentGroup = "EL Status" if StudentSubGroup=="EL Monit or Recently Ex"
	
	** Generate Empty Variables
	gen Lev5_count = ""
	gen Lev5_percent = ""

	** Label Variables

// 	label var StateAbbrev "State abbreviation"
// 	label var StateFips "State FIPS Id"
// 	label var SchYear "School year in which the data were reported. (e.g., 2021-22)"
// 	label var AssmtName "Name of state assessment"
// 	label var AssmtType "Assessment type"
// 	label var DataLevel "Level at which the data are reported"
// 	label var DistName "District name"
// 	label var DistCharter "Charter indicator - district"
// 	label var StateAssignedDistID "State-assigned district ID"
// 	label var SchName "School name"
// 	label var StateAssignedSchID "State-assigned school ID"
// 	label var Subject "Assessment subject area"
// 	label var GradeLevel "Grade tested (Individual grade levels, Gr3-8, all grades)"
// 	label var StudentGroup "Student demographic group"
// 	label var StudentSubGroup "Student demographic subgroup"
// 	label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested."
// 	label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested."
// 	label var Lev1_count "Count of students within subgroup performing at Level 1."
// 	label var Lev1_percent "Percent of students within subgroup performing at Level 1."
// 	label var Lev2_count "Count of students within subgroup performing at Level 2."
// 	label var Lev2_percent "Percent of students within subgroup performing at Level 2."
// 	label var Lev3_count "Count of students within subgroup performing at Level 3."
// 	label var Lev3_percent "Percent of students within subgroup performing at Level 3 ."
// 	label var Lev4_count "Count of students within subgroup performing at Level 4."
// 	label var Lev4_percent "Percent of students within subgroup performing at Level 4."
// 	label var Lev5_count "Count of students within subgroup performing at Level 5."
// 	label var Lev5_percent "Percent of students within subgroup performing at Level 5."
// 	label var AvgScaleScore "Avg scale score within subgroup."
// 	label var ProficiencyCriteria "Levels included in determining proficiency status."
// 	label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment."
// 	label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment."
// 	label var ParticipationRate "Participation rate."
// 	label var NCESDistrictID "NCES district ID"
// 	label var State_leaid "State LEA ID"
// 	label var CountyName "County in which the district or school is located."
// 	label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
// 	label var State "State name"
// 	label var StateAbbrev "State abbreviation"
// 	label var StateFips "State FIPS Id"
// 	label var DistType "District type as defined by NCES"
// 	label var NCESDistrictID "NCES district ID"
// 	label var NCESSchoolID "NCES school ID"
// 	label var SchType "School type as defined by NCES"
// 	label var SchVirtual "Virtual school indicator"
// 	label var SchLevel "School level"
// 	label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only."
// 	label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
// 	label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."

	** Fix Variable Order 
	replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 4
	
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

	** Export Assessment Data

	save "${path}/Output/RI_AssmtData_`y'.dta", replace
	export delimited using "${path}/Output/RI_AssmtData_`y'.csv", replace
}



foreach y in $years {
	
use  "${path}/Output/RI_AssmtData_`y'.dta", clear

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

save "${path}/Output/RI_AssmtData_`y'.dta", replace
export delimited using "${path}/Output/RI_AssmtData_`y'.csv", replace

}


