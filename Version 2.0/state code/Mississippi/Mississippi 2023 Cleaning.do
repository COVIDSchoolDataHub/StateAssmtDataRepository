clear
set more off

global MS "/Users/miramehta/Documents/Mississippi"
global raw "/Users/miramehta/Documents/Mississippi/Original Data Files"
global output "/Users/miramehta/Documents/Mississippi/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global EDFacts "/Users/miramehta/Documents/EDFacts"

** Data Request files (proficient counts and student counts w/ subgroups)

local subject math ela sci
local datatype performance participation
local datalevel district school state

foreach sub of local subject {
	use "${Request}/2023/`sub'performance/statecleaned.dta", clear
	append using "${Request}/2023/`sub'performance/districtcleaned.dta"
	append using "${Request}/2023/`sub'performance/schoolcleaned.dta"
	save "${Request}/2023/`sub'performance.dta", replace
}

foreach sub of local subject {
	use "${Request}/2023/`sub'participation/statecleaned.dta", clear
	append using "${Request}/2023/`sub'participation/districtcleaned.dta"
	append using "${Request}/2023/`sub'participation/schoolcleaned.dta"
	save "${Request}/2023/`sub'participation.dta", replace
}

foreach sub of local subject {
	use "${Request}/2023/`sub'participation.dta", clear
	merge 1:1 StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup using "${Request}/2023/`sub'performance.dta"
	drop if _merge == 1
	drop _merge
	save "${Request}/2023/`sub'.dta", replace
}

use "${Request}/2023/ela.dta", clear
append using "${Request}/2023/math.dta"
append using "${Request}/2023/sci.dta"

drop if StudentSubGroup_TotalTested == "0"
replace ProficientOrAbove_count = "0" if ProficientOrAbove_count == ""
*drop if StudentGroup == "All Students" //Commenting this out so that StudentGroup_TotalTested has a value for All Students regardless of where the data came from.

foreach v of numlist 1/5 {
	gen Lev`v'_count = "--"
	gen Lev`v'_percent = "--"
}

gen State_leaid = StateAssignedDistID
merge m:1 State_leaid using "${NCES}/NCES_2022_District.dta"
drop if _merge == 2
drop _merge

gen seasch = StateAssignedSchID
merge m:1 seasch using "${NCES}/NCES_2022_School.dta"
drop if _merge == 2
drop _merge

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Creating variables

replace SchYear = "2022-23"

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

replace StateAssignedDistID = subinstr(StateAssignedDistID, "MS-", "", .)
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = substr(StateAssignedSchID, 6, 7)
replace StateAssignedSchID = "" if DataLevel != 3

gen AssmtName = "MAAP"

gen ProficiencyCriteria = "Levels 4-5"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

replace State = "Mississippi"
replace StateAbbrev = "MS"
replace StateFips = 28

** Generating student group total counts

gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
** Generating proficiencies

destring ProficientOrAbove_count, gen(ProficientOrAbove_count2) force
gen ProficientOrAbove_percent = ProficientOrAbove_count2/StudentSubGroup_TotalTested2
tostring ProficientOrAbove_percent, replace format("%9.4g") force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_count == "0"

drop StudentSubGroup_TotalTested2 *_count2

** Merging with standardized name file

merge m:1 NCESDistrictID using "${MS}/standarddistnames.dta"
replace DistName = newdistname if _merge != 1
drop if _merge == 2 
drop newdistname _merge

merge m:1 NCESSchoolID using "${MS}/standardschnames.dta"
replace SchName = newschname if _merge != 1
drop if _merge == 2
drop newdistname newschname _merge

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen Priority = 2

save "${output}/MS_AssmtData_2023.dta", replace

** Original raw data files (level percents w/o subgroups)

local grade 3 4 5 6 7 8
local gradesci 5 8
local subjectog ELA MATH

foreach grd of local grade {
	foreach sub of local subjectog {
		use "${raw}/MS_AssmtData_2023_G`grd'`sub'.dta", clear

		rename *DistrictSchool SchName
		
		gen Subject = lower("`sub'")
		gen GradeLevel = "G0" + "`grd'"
		
		if (`grd' != 3) | ("`sub'" != "ELA") {
			append using "${raw}/MS_AssmtData_2023_elamath.dta"
		}
		save "${raw}/MS_AssmtData_2023_elamath.dta", replace
	}
}

foreach grdsci of local gradesci {
	use "${raw}/MS_AssmtData_2023_G`grdsci'sci.dta", clear
	
	rename *DistrictSchool SchName
		
	gen Subject = "sci"
	gen GradeLevel = "G0" + "`grdsci'"
	
	if (`grdsci' != 5) {
		append using "${raw}/MS_AssmtData_2023_sci.dta"
		}
	save "${raw}/MS_AssmtData_2023_sci.dta", replace
}

use "${raw}/MS_AssmtData_2023_elamath.dta", clear
append using "${raw}/MS_AssmtData_2023_sci.dta"

** Rename existing variables

rename AverageScaleScore AvgScaleScore
rename TestTakers StudentSubGroup_TotalTested

local level 1 2 3 4 5
foreach a of local level {
	rename Level`a'PCT Lev`a'_percent
}

** Dropping entries

drop if AvgScaleScore == ""
drop if SchName == "School 500"

** Replacing variables

foreach a of local level {
	replace Lev`a'_percent = "--" if Lev`a'_percent == "‡" | Lev`a'_percent == ""
}
replace AvgScaleScore = "--" if AvgScaleScore == "‡"
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "‡"

** Generating new variables

gen AssmtType = "Regular"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
foreach a of local level {
	destring Lev`a'_percent, replace force
	gen Lev`a'_count = round(StudentSubGroup_TotalTested2 * Lev`a'_percent)
	tostring Lev`a'_count, replace force
	replace Lev`a'_count = "*" if Lev`a'_count == "."
}

gen ProficientOrAbove_percent = Lev4_percent + Lev5_percent
replace ProficientOrAbove_percent = StudentSubGroup_TotalTested2 - (Lev1_percent + Lev2_percent + Lev3_percent) if ProficientOrAbove_percent == .
gen ProficientOrAbove_count = round(StudentSubGroup_TotalTested2 * ProficientOrAbove_percent)
tostring ProficientOrAbove_percent, replace format("%9.4g") force
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
replace ProficientOrAbove_count = "0" if ProficientOrAbove_percent == "0"

foreach a of local level {
	tostring Lev`a'_percent, replace format("%9.4g") force
	replace Lev`a'_percent = "*" if Lev`a'_percent == "."
}

replace SchName = strupper(SchName)
gen DataLevel = ""
replace DataLevel = "State" if strpos(SchName, "GRAND TOTAL") > 0
replace DataLevel = "District" if (strpos(SchName, "DISTRICT") | strpos(SchName, "SCHOOLS") | strpos(SchName, "MIDTOWN PUBLIC CHARTER SCHOOL") | strpos(SchName, "SMILOW PREP") | strpos(SchName, "MS SCHOOL FOR THE BLIND AND DEAF") | strpos(SchName, "SMILOW COLLEGIATE") | strpos(SchName, "AMBITION PREPARATORY") | strpos(SchName, "CLARKSDALE COLLEGIATE PUBLIC CHARTER") | strpos(SchName, "MDHS DIVISION OF YOUTH SERVICES") | strpos(SchName, "DUBARD SCHOOL FOR LANGUAGE DISORDERS")) & SchName != "AMBITION PREPARATORY CHARTER SCHOOL" > 0
replace DataLevel = "School" if DataLevel == ""

gen DistName = ""
replace DistName = SchName if DataLevel == "District"
replace DistName = "Leflore Legacy Academy" if SchName == "LEFLORE LEGACY ACADEMY"
replace DistName = "REIMAGINE PREP" if SchName == "REIMAGINE PREP"
replace DistName = "JOEL E. SMILLOW PREP" if strpos(DistName, "SMILOW PREP") > 0
replace DistName = DistName[_n-1] if missing(DistName)
replace DistName = "All Districts" if DataLevel == "State"
replace DistName = strtrim(DistName)
drop if DistName == "DUBARD SCHOOL FOR LANGUAGE DISORDERS"

replace SchName = "All Schools" if DataLevel != "School"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
quietly by DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup:  gen dup = cond(_N==1,0,_n)
replace DataLevel = 3 if dup == 2 & DataLevel == 2
replace SchName = DistName if dup == 2 & DataLevel == 3
replace SchName = "CLARKSDALE COLLEGIATE" if SchName == "CLARKSDALE COLLEGIATE PUBLIC CHARTER"
replace SchName = "Joel E Smilow Collegiate" if SchName == "SMILOW COLLEGIATE"
replace DataLevel = 2 if dup == 1 & DataLevel == 3
replace SchName = "All Schools" if dup == 1 & DataLevel == 2
drop dup

** Merging with NCES

merge m:1 DistName using "${NCES}/NCES_2022_District.dta"
drop if _merge == 2
drop _merge

replace DistName = subinstr(DistName,"DISTRICT","DIST",.) if CountyName == ""
merge m:1 DistName using "${NCES}/NCES_2022_District.dta", update

drop if _merge == 2
drop _merge

replace DistName = subinstr(DistName,"COUNTY","CO",.) if CountyName == ""
merge m:1 DistName using "${NCES}/NCES_2022_District.dta", update
drop if _merge == 2
drop _merge

replace DistName = "Ambition Preparatory Charter School" if DistName == "AMBITION PREPARATORY"
replace DistName = "BAY ST LOUIS WAVELAND SCHOOL DIST" if DistName == "BAY ST. LOUIS- WAVELAND SCHOOL DIST"
replace DistName = "CLARKSDALE COLLEGIATE DISTRICT" if DistName == "CLARKSDALE COLLEGIATE PUBLIC CHARTER"
replace DistName = "COVINGTON COUNTY SCHOOL DISTRICT" if DistName == "COVINGTON CO SCHOOLS"
replace DistName = "EAST JASPER CONSOLIDATED SCH DIST" if DistName == "EAST JASPER CONSOLIDATED SCHOOL DIST"
replace DistName = "EAST TALLAHATCHIE CONSOL SCH DIST" if DistName == "EAST TALLAHATCHIE CONSOLIDATED SCHOOL DIST"
replace DistName = "GREENWOOD-LEFLORE CONS SCH DISTRICT" if DistName == "GREENWOOD-LEFLORE CONSOLIDATED SCHOOL DIST"
replace DistName = "HOLMES COUNTY CONSOLIDATED SD" if DistName == "HOLMES CO CONSOLIDATED SCHOOL DIST"
replace DistName = "MERIDIAN PUBLIC SCHOOLS" if DistName == "MERIDIAN PUBLIC SCHOOL DIST"
replace DistName = "MS SCHLS FOR THE DEAF AND THE BLIND" if DistName == "MS SCHOOL FOR THE BLIND AND DEAF"
replace DistName = "NORTH BOLIVAR CONS SCHOOL DIST" if DistName == "NORTH BOLIVAR CONSOLIDATED SCHOOL DIST"
replace DistName = "NORTH PANOLA SCHOOL DISTRICT" if DistName == "NORTH PANOLA SCHOOLS"
replace DistName = "JOEL E SMILOW COLLEGIATE" if DistName == "SMILOW COLLEGIATE"
replace DistName = "STARKVILLE- OKTIBBEHA CONS DIST" if DistName == "STARKVILLE-OKTIBBEHA CONSOLIDATED SCHOOL DIST"
replace DistName = "SUNFLOWER CTY CONS SCHOOL DISTRICT" if DistName == "SUNFLOWER CO CONSOLIDATED SCHOOL DIST"
replace DistName = "TISHOMINGO CO SP MUN SCH DIST" if DistName == "TISHOMINGO CO SEPARATE MUNICIPAL SCHOOL DIST"
replace DistName = "WEST BOLIVAR CONS SCHOOL DIST" if DistName == "WEST BOLIVAR CONSOLIDATED SCHOOL DIST"
replace DistName = "WINONA-MONTGOMERY CONSOLIDATED" if DistName == "WINONA-MONTGOMERY CONSOLIDATED SCHOOL DIST"
merge m:1 DistName using "${NCES}/NCES_2022_District.dta", update
drop if _merge == 2
drop _merge

replace SchName = strtrim(SchName)
replace SchName = strupper(SchName)

merge m:1 DistName SchName using "${NCES}/NCES_2022_School.dta"
drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName, "JUNIOR", "JR",.) if NCESSchoolID == "" & DataLevel == 3
merge m:1 DistName SchName using "${NCES}/NCES_2022_School.dta", update
drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName," SCHOOL","",.) if NCESSchoolID == "" & DataLevel == 3 & DistName != "DUBARD SCHOOL FOR LANGUAGE DISORDERS"
merge m:1 DistName SchName using "${NCES}/NCES_2022_School.dta", update
drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName," ELEMENTARY"," ELEM",.) if NCESSchoolID == "" & DataLevel == 3
replace SchName = "A. W. WATSON  ELEMENTARY" if strpos(SchName, "WATSON") > 0 & NCESSchoolID == ""
replace SchName = "Ambition Preparatory Charter School" if SchName == "AMBITION PREPARATORY CHARTER"
replace SchName = "AMITE COUNTY MIDDLE SCHOOL" if SchName == "AMITE COUNTY MIDDLE"
replace SchName = "ARLINGTON HEIGHTS ELEM SCHOOL" if SchName == "ARLINGTON HEIGHTS ELEM"
replace SchName = "ARMSTRONG JUNIOR HIGH SCHOOL" if SchName == "ARMSTRONG MIDDLE"
replace SchName = "ASHLAND MIDDLE-HIGH SCHOOL" if SchName == "ASHLAND HIGH"
replace SchName = "BAY SPRINGS ELEM SCH" if SchName == "BAY SPRINGS ELEM"
replace SchName = "BAY SPRINGS MIDDLE SCH" if SchName == "BAY SPRINGS MIDDLE"
replace SchName = "Bay Waveland Middle School" if SchName == "BAY WAVELAND MIDDLE"
replace SchName = "BELL ELEMENTARY SCHOOL" if SchName == "BELL ACADEMY"
replace SchName = "BELLEVUE ELEMENTARY SCHOOL" if SchName == "BELLEVUE ELEM"
replace SchName = "BELMONT SCHOOL" if SchName == "BELMONT HIGH"
replace SchName = "BILOXI JUNIOR HIGH" if SchName == "BILOXI JR HIGH"
replace SchName = "BLUE MOUNTAIN HIGH SCHOOL" if SchName == "BLUE MOUNTAIN"
replace SchName = "BOGUE CHITTO SCHOOL" if SchName == "BOGUE CHITTO ATTENDANCE CENTER"
replace SchName = "BOLTON-EDWARDS ELEM./MIDDLE SCHOOL" if strpos(SchName, "BOLTON") > 0 & NCESSchoolID == ""
replace SchName = "BOOKER T WASHINGTON INTERN. STUDIES" if SchName == "BOOKER T WASHINGTON INTERNATIONAL STUDIES"
replace SchName = "BROOKS ELEM SCHOOL" if SchName == "BROOKS ELEM"
replace SchName = "BURNSVILLE ELEMENTARY" if SchName == "BURNSVILLE"
replace SchName = "BYHALIA MIDDLE SCHOOL (5-8)" if strpos(SchName, "BYHALIA MIDDLE") > 0 & NCESSchoolID == ""
replace SchName = "BYHALIA ELEMENTARY SCHOOL (K-4)" if SchName == "BYHALIA ELEM, K-4"
replace SchName = "CARVER ELEMENTARY SCHOOL" if SchName == "CARVER ELEM"
replace SchName = "CLINTON JR HI SCHOOL" if SchName == "CLINTON JR HIGH"
replace SchName = "COAHOMA COUNTY JR/SR HIGH SCHOOL" if strpos(SchName, "COAHOMA") > 0 & NCESSchoolID == ""
replace SchName = "BARACK H OBAMA ELEMENTARY SCHOOL" if SchName == "DAVIS MAGNET"
replace SchName = "DEXTER ELEMENTARY SCHOOL" if SchName == "DEXTER ATTENDANCE CENTER"
replace SchName = "EDNA M SCOTT ELEMENTARY SCHOOL" if SchName == "EDNA M. SCOTT ELEM"
replace SchName = "ENTERPRISE SCHOOL" if SchName == "ENTERPRISE ATTENDANCE CENTER"
replace SchName = "ETHEL ATTENDANCE CENTER" if SchName == "ETHEL HIGH"
replace SchName = "FRENCH CAMP ELEM SCHOOL" if SchName == "FRENCH CAMP ELEM"
replace SchName = "GALENA ELEMENTARY SCHOOL (K-6)" if SchName == "GALENA ELEM, K-8"
replace SchName = "GEO H OLIVER VISUAL/PERF. ARTS" if strpos(SchName, "OLIVER") > 0 & NCESSchoolID == ""
replace SchName = "GOODMAN PICKENS ELEMENTARY SCHOOL" if SchName == "GOODMAN-PICKENS ELEM"
replace SchName = "GREEN HILL INTERMEDIATE" if SchName == "GREENHILL ELEM"
replace SchName = "H. W. BYERS HIGH SCHOOL (5-12)" if strpos(SchName, "BYERS HIGH") > 0 & NCESSchoolID == ""
replace SchName = "H. W. BYERS ELEMENTARY (K-4)" if SchName == "H. W. BYERS ELEM, K-4"
replace SchName = "HAMILTON HIGH SCHOOL" if SchName == "HAMILTON ATTENDANCE CENTER"
replace SchName = "HARPER MC CAUGHAN ELEM SCHOOL" if strpos(SchName, "HARPER") > 0 & NCESSchoolID == ""
replace SchName = "HATLEY HIGH SCHOOL" if strpos(SchName, "HATLEY") > 0 & NCESSchoolID == ""
replace SchName = "HAYES COOPER CENTER FOR MATH SC TEC" if strpos(SchName, "HAYES") > 0 & NCESSchoolID == ""
replace SchName = "HEIDELBERG SCHOOL MATH & SCIENCE" if SchName == "HEIDELBERG MATH AND SCIENCE"
replace SchName = "HENDERSON/WARD-STEWART ELEMENTARY" if SchName == "HENDERSON WARD-STEWART ELEM"
replace SchName = "JEFFERSON CO ELEM SCHOOL" if SchName == "JEFFERSON CO ELEM" | SchName == "JEFFERSON COUNTY ELEM"
replace SchName = "JEFFERSON CO JR HI" if SchName == "JEFFERSON COUNTY JR HIGH"
replace SchName = "JDC MIDDLE SCHOOL" if SchName == "JEFFERSON DAVIS COUNTY MIDDLE"
replace SchName = "Joel E Smilow Collegiate" if SchName == "JOEL E SMILOW COLLEGIATE"
replace SchName = "JOEL E. SMILOW PREP" if SchName == "JOEL E. SMILLOW PREP"
replace SchName = "JUMPERTOWN HIGH SCHOOL" if SchName == "JUMPERTOWN ATTENDANCE CENTER"
replace SchName = "KIRKPATRICK  HEALTH /WELLNESS" if SchName == "KIRKPATRICK HEALTH AND WELLNESS"
replace SchName = "LEAKE CENTRAL JUNIOR HIGH" if SchName == "LEAKE CENTRAL JR HIGH"
replace SchName = "SHIRLEY ELEMENTARY SCHOOL" if SchName == "LEE ELEM"
replace SchName = "Leflore Legacy Academy" if SchName == "LEFLORE LEGACY ACADEMY"
replace SchName = "LELAND SCHOOL PARK" if SchName == "LELAND ELEM ACCERATED"
replace SchName = "LIPSEY SCHOOL" if SchName == "LIPSEY MIDDLE"
replace SchName = "LOVETT ELEM SCHOOL" if SchName == "LOVETT ELEM"
replace SchName = "LOYD STAR SCHOOL" if SchName == "LOYD STAR ATTENDANCE CENTER"
replace SchName = "MANTACHIE ATTENDANCE CENTER" if strpos(SchName, "MANTACHIE") > 0 & NCESSchoolID == ""
replace SchName = "MARSHALL ELEMENTARY SCHOOL" if SchName == "MARSHALL ELEM"
replace SchName = "MARTIN BLUFF" if SchName == "MARTIN BLUFF ELEM"
replace SchName = "MARY REID SCHOOL (K-4)" if SchName == "MARY REID, K-3"
replace SchName = "MC LAIN ELEMENTARY SCHOOL" if strpos(SchName, "LAIN") > 0 & NCESSchoolID == ""
replace SchName = "MC LAURIN ELEMENTARY SCHOOL" if SchName == "MCLAURIN ELEM"
replace SchName = "MC LEOD ELEMENTARY SCHOOL" if SchName == "MCLEOD ELEM"
replace SchName = "MCADAMS ATTENDANCE CENTER" if SchName == "MCADAMS HIGH"
replace SchName = "MCCOMB HIGH SCHOOL" if SchName == "MCCOMB MIDDLE"
replace SchName = "MCLAURIN ATTENDANCE CENTER" if SchName == "MCLAURIN HIGH"
replace SchName = "MC NEAL ELEMENTARY SCHOOL" if SchName == "MCNEAL ELEM"
replace SchName = "MIDTOWN PUBLIC CHARTER SCHOOL" if SchName == "MIDTOWN PUBLIC"
replace SchName = "MS SCHOOL FOR THE BLIND" if SchName == "MISSISSIPPI FOR THE BLIND"
replace SchName = "MS SCHOOL FOR THE DEAF" if SchName == "MISSISSIPPI FOR THE DEAF"
replace SchName = "MORGANTOWN ELEMENTARY" if SchName == "MORGANTOWN ELEM"
replace SchName = "MOORHEAD CENTRAL SCHOOL" if strpos(SchName, "MOORHEAD CENTRAL") & NCESSchoolID == ""
replace SchName = "NANIH WAIYA ATTENDANCE CENTER" if SchName == "NANIH WAIYA"
replace SchName = "NATCHEZ MIDDLE SCHOOL" if SchName == "NATCHEZ MIDDLE"
replace SchName = "NORTH GULFPORT ELEMENTARY AND MIDDL" if SchName == "NORTH GULFPORT ELEM AND MIDDLE"
replace SchName = "NORTH PANOLA MIDDLE SCHOOL" if SchName == "NORTH PANOLA JR HIGH"
replace SchName = "NORTH PIKE UPPER ELEMENTARY SCHOOL" if SchName == "NORTH PIKE UPPER ELEM"
replace SchName = "NORTH PIKE JUNIOR HIGH SCHOOL" if SchName == "NORTH PIKE MIDDLE"
replace SchName = "North Pontotoc Elementary School" if SchName == "NORTH PONTOTOC ELEM"
replace SchName = "North Pontotoc Middle School" if SchName == "NORTH PONTOTOC MIDDLE"
replace SchName = "NORTH WOOLMARKET ELEMENTARY AND MID" if SchName == "NORTH WOOLMARKET ELEM AND MIDDLE"
replace SchName = "O M MC NAIR MIDDLE SCHOOL" if strpos(SchName, "NAIR") > 0 & NCESSchoolID == ""
replace SchName = "OAK GROVE LOWER ELEMENTARY" if SchName == "OAK GROVE ELEM" & GradeLevel == "G03"
replace SchName = "OAK GROVE UPPER  ELEMENTARY" if SchName == "OAK GROVE ELEM"
replace SchName = "BARACK H OBAMA ELEMENTARY SCHOOL" if SchName == "OBAMA MAGNET"
replace SchName = "OCEAN SPRINGS UPPER ELEMENTARY SCHO" if SchName == "OCEAN SPRINGS UPPER ELEM"
replace SchName = "OLD TOWN MIDDLE" if SchName == "OLDE TOWNE MIDDLE"
replace SchName = "OXFORD INTERMEDIATE SCHOOL" if SchName == "OXFORD ELEM"
replace SchName = "SOCSD/MSU PARTNERSHIP MIDDLE SCHOOL" if SchName == "THE PARTNERSHIP MIDDLE"
replace SchName = "PEARL RIVER CENTRAL ELEMENTAR" if SchName == "PEARL RIVER CENTRAL ELEM"
replace SchName = "PEARL RIVER CENTRAL JUNIOR HIGH" if SchName == "PEARL RIVER CENTRAL JR HIGH"
replace SchName = "PEARL UPPER SCHOOL" if SchName == "PEARL UPPER ELEM"
replace SchName = "PELAHATCHIE ATTENDANCE CENTER" if SchName == "PELAHATCHIE HIGH"
replace SchName = "PINE GROVE HIGH SCHOOL" if SchName == "PINE GROVE"
replace SchName = "POPLARVILLE UPPER ELEMENTARY SCH" if SchName == "POPLARVILLE UPPER ELEM"
replace SchName = "POTTS CAMP HIGH SCHOOL (5-12)" if strpos(SchName, "POTTS CAMP") > 0 & NCESSchoolID == ""
replace SchName = "IDA B. WELLS APAC SCHOOL" if SchName == "POWER APAC"
replace SchName = "PUCKETT ATTENDANCE CENTER" if SchName == "PUCKETT HIGH"
replace SchName = "REUBEN B. MYERS CANTON SCHOOL OF AR" if strpos(SchName, "REUBEN") > 0 & NCESSchoolID == ""
replace SchName = "RULEVILLE MIDDLE SCHOOL" if SchName == "RULEVILLE MIDDLE"
replace SchName = "RULEVILLE CENTRAL ELEM SCHOOL" if SchName == "RULEVILLE CENTRAL ELEM"
replace SchName = "S V MARSHALL ELEMENTARY SCHOOL" if SchName == "S.V. MARSHALL ELEM"
replace SchName = "S V MARSHALL MIDDLE SCHOOL" if SchName == "S. V. MARSHALL MIDDLE"
replace SchName = "SAND HILL ELEMENTARY SCHOOL" if SchName == "SAND HILL ATTENDANCE CENTER"
replace SchName = "SCOTT CENTRAL ATTENDANCE CENTER" if SchName == "SCOTT CENTRAL ATTENDANCE CTR"
replace SchName = "SHIRLEY D. SIMMONS MIDDLE SCHOOL" if SchName == "SHIRLEY SIMMONS MIDDLE"
replace SchName = "SIMMONS JR HIGH SCHOOL" if SchName == "SIMMONS JR HIGH"
replace SchName = "SMITHVILLE HIGH SCHOOL" if SchName == "SMITHVILLE ATTENDANCE CENTER"
replace SchName = "South Pontotoc Elementary School" if SchName == "SOUTH PONTOTOC ELEM"
replace SchName = "South Pontotoc Middle School" if SchName == "SOUTH PONTOTOC MIDDLE"
replace SchName = "SOUTH SIDE ELEMENTARY SCHOOL" if SchName == "SOUTH SIDE ELEM"
replace SchName = "SUMRALL ELEMENTARY SCHOOL" if SchName == "SUMRALL ELEM"
replace SchName = "TWENTY EIGHTH ST ELEM" if strpos(SchName, "TWENTY") > 0 & NCESSchoolID == ""
replace SchName = "RANKIN COUNTY LEARNING CENTER" if SchName == "THE LEARNING CENTER"
replace SchName = "TREMONT ATTENDANCE CENTER" if SchName == "TREMONT HIGH"
replace SchName = "THRASHER HIGH SCHOOL" if SchName == "THRASHER ATTENDANCE CENTER"
replace SchName = "TISHOMINGO ELEMENTARY" if SchName == "TISHOMINGO"
replace SchName = "UTICA ELEM. / MIDDLE SCHOOL" if strpos(SchName, "UTICA") > 0 & NCESSchoolID == ""
replace SchName = "VARDAMAN HIGH SCHOOL" if SchName == "VARDAMAN ATTENDANCE CENTER" & (GradeLevel == "G07" | GradeLevel == "G08")
replace SchName = "VARDAMAN ELEMENTARY SCHOOL" if SchName == "VARDAMAN ATTENDANCE CENTER"
replace SchName = "WAYNE CENTRAL ELEMENTARY SCHOOL" if SchName == "WAYNE CENTRAL"
replace SchName = "WAYNESBORO RIVERVIEW ELE SCHOOL" if strpos(SchName, "RIVERVIEW") > 0 & NCESSchoolID == ""
replace SchName = "IDA B. WELLS APAC SCHOOL" if SchName == "WELLS APAC ELEM"
replace SchName = "WEST CLAY ELEMENTARY SCHOOL" if SchName == "WEST CLAY ELEM"
replace SchName = "WEST HARRISON MIDDLE SCHOOL" if SchName == "WEST HARRISON MIDDLE"
replace SchName = "WEST JONES HIGH SCHOOL" if SchName == "WEST JONES JR SR HIGH"
replace SchName = "WEST LINCOLN SCHOOL" if SchName == "WEST LINCOLN ATTENDANCE CENTER"
replace SchName = "WEST WORTHAM ELEMENTARY AND MIDDLE" if SchName == "WEST WORTHAM ELEM AND MIDDLEDLE"
replace SchName = "WHEELER HIGH SCHOOL" if SchName == "WHEELER ATTENDANCE CENTER"
replace SchName = "WILLIAM DEAN JR. ELEMENTARY SCHOOL" if SchName == "WILLIAM DEAN JR ELEM"
replace SchName = "WILLIAMS-SULLIVAN MIDDLE SCHOOL" if SchName == "WILLIAMS-SULLIVAN ELEM"
merge m:1 DistName SchName using "${NCES}/NCES_2022_School.dta", update
drop if _merge == 2
drop _merge

replace StateAbbrev = "MS"
replace State = "Mississippi"
replace StateFips = 28

** Merging with standardized name file

merge m:1 NCESDistrictID using "${MS}/standarddistnames.dta"
replace DistName = newdistname if _merge != 1
drop if _merge == 2 
drop newdistname _merge

merge m:1 NCESSchoolID using "${MS}/standardschnames.dta"
replace SchName = newschname if _merge != 1
drop if DataLevel == 3 & _merge == 1
drop if _merge == 2
drop newdistname newschname _merge

** Creating variables

gen StateAssignedDistID = subinstr(State_leaid, "MS-", "", .)
gen StateAssignedSchID = substr(seasch, 6, 7)

gen SchYear = "2022-23"

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3

gen AssmtName = "MAAP"

gen ProficiencyCriteria = "Levels 4-5"

gen ParticipationRate = "--"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

replace State = "Mississippi"
replace StateAbbrev = "MS"
replace StateFips = 28

//Appending and Dealing with Duplicate "All Students" Values
gen Priority = 1
append using "${output}/MS_AssmtData_2023.dta"
sort Priority DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
duplicates drop DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup, force
drop Priority

replace SchName = "Jdc Middle School" if NCESSchoolID == "280225001587"

replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)

** Generating student group total counts
cap drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3 //Remove quotations id SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

** Getting rid of ranges where high and low ranges are the same
foreach var of varlist *_count *_percent {
replace `var' = substr(`var',1, strpos(`var', "-")-1) if real(substr(`var',1, strpos(`var', "-")-1)) == real(substr(`var', strpos(`var', "-")+1,10)) & strpos(`var', "-") !=0 & regexm(`var', "[0-9]") !=0
}

//Derivations

**Deriving Count if we have all other counts

replace Lev1_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev1_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) > 0

replace Lev2_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev1_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev1_count)) & missing(real(Lev2_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev1_count)) > 0

replace Lev3_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev1_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & missing(real(Lev3_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev1_count)-real(Lev2_count)) > 0

replace Lev4_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev1_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev1_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev4_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev1_count)-real(Lev3_count)-real(Lev2_count)) > 0

replace Lev5_count = string(real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev1_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev5_count)) & (real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) > 0

** Deriving Percents if we have all other percents
replace Lev1_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)

replace Lev2_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent) > 0.005)

replace Lev3_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent) > 0.005)

replace Lev4_percent = string(1-real(Lev5_percent)-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))  & (1-real(Lev5_percent)-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)

replace Lev5_percent = string(1-real(Lev1_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev5_percent))  & (1-real(Lev1_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)

//Clean up AvgScaleScore
replace AvgScaleScore = string(real(AvgScaleScore), "%9.3f") if !missing(real(AvgScaleScore))

//ProficientOrAbove_count cannot be > StudentSubGroup_TotalTested. Setting obs = "--" because data is signifcantly misaligned ( up to 10 more students marked proficient than the number tested)
replace ProficientOrAbove_percent = "--" if real(ProficientOrAbove_count) > real(StudentSubGroup_TotalTested) & !missing(real(ProficientOrAbove_count)) & !missing(real(StudentSubGroup_TotalTested))
replace ProficientOrAbove_count = "--" if real(ProficientOrAbove_count) > real(StudentSubGroup_TotalTested) & !missing(real(ProficientOrAbove_count)) & !missing(real(StudentSubGroup_TotalTested))


keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/MS_AssmtData_2023.dta", replace

export delimited using "${output}/csv/MS_AssmtData_2023.csv", replace
