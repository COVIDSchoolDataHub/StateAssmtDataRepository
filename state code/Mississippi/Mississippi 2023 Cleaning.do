clear
set more off

global output "/Users/maggie/Desktop/Mississippi/Output"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"

local grade 3 4 5 6 7 8
local gradesci 5 8
local subject ELA MATH

cd "/Users/maggie/Desktop/Mississippi"

** Appending ela & math

foreach grd of local grade {
	foreach sub of local subject {
		use "${output}/MS_AssmtData_2023_G`grd'`sub'.dta", clear

		rename *DistrictSchool SchName
		
		gen Subject = lower("`sub'")
		gen GradeLevel = "G0" + "`grd'"
		
		if (`grd' != 3) | ("`sub'" != "ELA") {
			append using "${output}/MS_AssmtData_2023_elamath.dta"
		}
		save "${output}/MS_AssmtData_2023_elamath.dta", replace
	}
}

foreach grdsci of local gradesci {
	use "${output}/MS_AssmtData_2023_G`grdsci'sci.dta", clear
	
	rename *DistrictSchool SchName
		
	gen Subject = "sci"
	gen GradeLevel = "G0" + "`grdsci'"
	
	if (`grdsci' != 5) {
		append using "${output}/MS_AssmtData_2023_sci.dta"
		}
	save "${output}/MS_AssmtData_2023_sci.dta", replace
}

use "${output}/MS_AssmtData_2023_elamath.dta", clear
append using "${output}/MS_AssmtData_2023_sci.dta"

** Rename existing variables

rename AverageScaleScore AvgScaleScore
rename TestTakers StudentGroup_TotalTested

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

replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == "‡"

** Generating new variables

gen SchYear = "2022-23"

gen AssmtName = "MAAP"
gen AssmtType = "Regular"

foreach a of local level {
	gen Lev`a'_count = "--"
}

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested

gen ProficiencyCriteria = "Levels 4-5"
gen ProficientOrAbove_count = "--"

gen ParticipationRate = "--"

gen test = ""
foreach a of local level {
	gen Lev`a'_percent2 = Lev`a'_percent
	destring Lev`a'_percent2, replace force
	replace test = "*" if Lev`a'_percent == "*"
	replace test = "--" if Lev`a'_percent == "--"
}
gen ProficientOrAbove_percent = Lev4_percent2 + Lev5_percent2
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = test if test != ""
drop test
foreach a of local level {
	drop Lev`a'_percent2
}

replace SchName = strupper(SchName)
gen DataLevel = ""
replace DataLevel = "State" if strpos(SchName, "GRAND TOTAL") > 0
replace DataLevel = "District" if (strpos(SchName, "DISTRICT") | strpos(SchName, "SCHOOLS") | strpos(SchName, "MIDTOWN PUBLIC CHARTER SCHOOL") | strpos(SchName, "SMILOW PREP") | strpos(SchName, "MS SCHOOL FOR THE BLIND AND DEAF") | strpos(SchName, "SMILOW COLLEGIATE") | strpos(SchName, "AMBITION PREPARATORY") | strpos(SchName, "CLARKSDALE COLLEGIATE PUBLIC CHARTER") | strpos(SchName, "MDHS DIVISION OF YOUTH SERVICES")) & SchName != "AMBITION PREPARATORY CHARTER SCHOOL" > 0
replace DataLevel = "School" if DataLevel == ""

gen DistName = ""
replace DistName = SchName if DataLevel == "District"
replace DistName = DistName[_n-1] if missing(DistName)
replace DistName = "All Districts" if DataLevel == "State"

replace SchName = "All Schools" if DataLevel != "School"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

merge m:1 DistName using "${NCES}/NCES_2021_District.dta"

drop if _merge == 2
drop _merge

replace DistName = subinstr(DistName,"DISTRICT","DIST",.) if CountyName == ""

merge m:1 DistName using "${NCES}/NCES_2021_District.dta", update

drop if _merge == 2
drop _merge

replace DistName = subinstr(DistName,"COUNTY","CO",.) if CountyName == ""

merge m:1 DistName using "${NCES}/NCES_2021_District.dta", update

drop if _merge == 2
drop _merge

replace DistName = "DUBARD SCHOOL FOR LANGUAGE DISORDERS" if SchName == "DUBARD SCHOOL FOR LANGUAGE DISORDERS"
replace DistName = "Leflore Legacy Academy" if SchName == "LEFLORE LEGACY ACADEMY"
replace DistName = "REIMAGINE PREP" if SchName == "REIMAGINE PREP"
replace DistName = "Ambition Preparatory Charter School" if DistName == "AMBITION PREPARATORY"
replace DistName = "BAY ST LOUIS WAVELAND SCHOOL DIST" if DistName == "BAY ST. LOUIS- WAVELAND SCHOOL DIST"
replace DistName = "CLARKSDALE COLLEGIATE DISTRICT" if DistName == "CLARKSDALE COLLEGIATE PUBLIC CHARTER"
replace DistName = "COVINGTON COUNTY SCHOOL DISTRICT" if DistName == "COVINGTON CO SCHOOLS"
replace DistName = "EAST JASPER CONSOLIDATED SCH DIST" if DistName == "EAST JASPER CONSOLIDATED SCHOOL DIST"
replace DistName = "EAST TALLAHATCHIE CONSOL SCH DIST" if DistName == "EAST TALLAHATCHIE CONSOLIDATED SCHOOL DIST"
replace DistName = "GREENWOOD-LEFLORE CONS SCH DISTRICT" if DistName == "GREENWOOD-LEFLORE CONSOLIDATED SCHOOL DIST"
replace DistName = "HOLMES COUNTY CONSOLIDATED SD" if DistName == "HOLMES CO CONSOLIDATED SCHOOL DIST"
replace DistName = "JOEL E. SMILLOW PREP" if DistName == "JOEL E. SMILOW PREP" | DistName == "SMILOW PREP"
replace DistName = "MERIDIAN PUBLIC SCHOOLS" if DistName == "MERIDIAN PUBLIC SCHOOL DIST"
replace DistName = "MS SCHLS FOR THE DEAF AND THE BLIND" if DistName == "MS SCHOOL FOR THE BLIND AND DEAF"
replace DistName = "NORTH BOLIVAR CONS SCHOOL DIST" if DistName == "NORTH BOLIVAR CONSOLIDATED SCHOOL DIST"
replace DistName = "NORTH PANOLA SCHOOL DISTRICT" if DistName == "NORTH PANOLA SCHOOLS"
replace DistName = "JOEL E SMILOW COLLEGIATE" if DistName == "SMILOW COLLEGIATE" | DistName == "SMILOW COLLEGIATE "
replace DistName = "STARKVILLE- OKTIBBEHA CONS DIST" if DistName == "STARKVILLE-OKTIBBEHA CONSOLIDATED SCHOOL DIST"
replace DistName = "SUNFLOWER CTY CONS SCHOOL DISTRICT" if DistName == "SUNFLOWER CO CONSOLIDATED SCHOOL DIST"
replace DistName = "TISHOMINGO CO SP MUN SCH DIST" if DistName == "TISHOMINGO CO SEPARATE MUNICIPAL SCHOOL DIST"
replace DistName = "WEST BOLIVAR CONS SCHOOL DIST" if DistName == "WEST BOLIVAR CONSOLIDATED SCHOOL DIST"
replace DistName = "WINONA-MONTGOMERY CONSOLIDATED" if DistName == "WINONA-MONTGOMERY CONSOLIDATED SCHOOL DIST"

merge m:1 DistName using "${NCES}/NCES_2021_District.dta", update

drop if _merge == 2
drop _merge

replace SchName = strtrim(SchName)
replace SchName = strupper(SchName)

merge m:1 DistName SchName using "${NCES}/NCES_2021_School.dta"

drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName, "JUNIOR", "JR",.) if NCESSchoolID == "" & DataLevel == 3

merge m:1 DistName SchName using "${NCES}/NCES_2021_School.dta", update

drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName," SCHOOL","",.) if NCESSchoolID == "" & DataLevel == 3 & DistName != "DUBARD SCHOOL FOR LANGUAGE DISORDERS"

merge m:1 DistName SchName using "${NCES}/NCES_2021_School.dta", update

drop if _merge == 2
drop _merge

replace SchName = subinstr(SchName," ELEMENTARY"," ELEM",.) if NCESSchoolID == "" & DataLevel == 3

replace SchName = "A. W. WATSON  ELEMENTARY" if strpos(SchName, "WATSON") > 0 & NCESSchoolID == ""
replace SchName = "Ambition Preparatory Charter School" if SchName == "AMBITION PREPARATORY CHARTER"
replace SchName = "AMITE COUNTY HIGH SCHOOL" if SchName == "AMITE COUNTY MIDDLE"
replace SchName = "ARLINGTON HEIGHTS ELEM SCHOOL" if SchName == "ARLINGTON HEIGHTS ELEM"
replace SchName = "ARMSTRONG JUNIOR HIGH SCHOOL" if SchName == "ARMSTRONG MIDDLE"
replace SchName = "ASHLAND MIDDLE-HIGH SCHOOL" if SchName == "ASHLAND HIGH"
replace SchName = "BAY SPRINGS ELEM SCH" if SchName == "BAY SPRINGS ELEM"
replace SchName = "BAY SPRINGS MIDDLE SCH" if SchName == "BAY SPRINGS MIDDLE"
replace SchName = "Bay Waveland Middle School" if SchName == "BAY WAVELAND MIDDLE"
replace SchName = "BELL ELEMENTARY SCHOOL" if SchName == "BELL ACADEMY"
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
replace SchName = "CLINTON JR HI SCHOOL" if SchName == "CLINTON JR HIGH"
replace SchName = "COAHOMA COUNTY JR/SR HIGH SCHOOL" if strpos(SchName, "COAHOMA") > 0 & NCESSchoolID == ""
replace SchName = "DEXTER ELEMENTARY SCHOOL" if SchName == "DEXTER ATTENDANCE CENTER"
replace SchName = "EDNA M SCOTT ELEMENTARY SCHOOL" if SchName == "EDNA M. SCOTT ELEM"
replace SchName = "ENTERPRISE SCHOOL" if SchName == "ENTERPRISE ATTENDANCE CENTER"
replace SchName = "ETHEL ATTENDANCE CENTER" if SchName == "ETHEL HIGH"
replace SchName = "EVA GORDON ELEMENTARY SCHOOL" if SchName == "EVA GORDON LOWER ELEM"
replace SchName = "FRENCH CAMP ELEM SCHOOL" if SchName == "FRENCH CAMP ELEM"
replace SchName = "GALENA ELEMENTARY SCHOOL (K-6)" if SchName == "GALENA ELEM, K-8"
replace SchName = "GEO H OLIVER VISUAL/PERF. ARTS" if strpos(SchName, "OLIVER") > 0 & NCESSchoolID == ""
replace SchName = "GOODMAN PICKENS ELEMENTARY SCHOOL" if SchName == "GOODMAN-PICKENS ELEM"
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
replace SchName = "JUMPERTOWN HIGH SCHOOL" if SchName == "JUMPERTOWN ATTENDANCE CENTER"
replace SchName = "KIRKPATRICK  HEALTH /WELLNESS" if SchName == "KIRKPATRICK HEALTH AND WELLNESS"
replace SchName = "LEAKE CENTRAL JUNIOR HIGH" if SchName == "LEAKE CENTRAL JR HIGH"
replace SchName = "Leflore Legacy Academy" if SchName == "LEFLORE LEGACY ACADEMY"
replace SchName = "LELAND SCHOOL PARK" if SchName == "LELAND ELEM ACCERATED"
replace SchName = "LIPSEY SCHOOL" if SchName == "LIPSEY MIDDLE"
replace SchName = "LOVETT ELEM SCHOOL" if SchName == "LOVETT ELEM"
replace SchName = "LOYD STAR SCHOOL" if SchName == "LOYD STAR ATTENDANCE CENTER"
replace SchName = "MANTACHIE ATTENDANCE CENTER" if strpos(SchName, "MANTACHIE") > 0 & NCESSchoolID == ""
replace SchName = "MARTIN BLUFF" if SchName == "MARTIN BLUFF ELEM"
replace SchName = "MARY REID SCHOOL (K-3)" if SchName == "MARY REID, K-3"
replace SchName = "MC LAIN ELEMENTARY SCHOOL" if strpos(SchName, "LAIN") > 0 & NCESSchoolID == ""
replace SchName = "MCADAMS ATTENDANCE CENTER" if SchName == "MCADAMS HIGH"
replace SchName = "MCCOMB HIGH SCHOOL" if SchName == "MCCOMB MIDDLE"
replace SchName = "MCLAURIN ATTENDANCE CENTER" if SchName == "MCLAURIN HIGH"
replace SchName = "MC NEAL ELEMENTARY SCHOOL" if SchName == "MCNEAL ELEM"
replace SchName = "MIDTOWN PUBLIC CHARTER SCHOOL" if SchName == "MIDTOWN PUBLIC"
replace SchName = "MS SCHOOL FOR THE BLIND" if SchName == "MISSISSIPPI FOR THE BLIND"
replace SchName = "MS SCHOOL FOR THE DEAF" if SchName == "MISSISSIPPI FOR THE DEAF"
replace SchName = "MOORHEAD CENTRAL SCHOOL" if strpos(SchName, "MOORHEAD CENTRAL") & NCESSchoolID == ""
replace SchName = "NANIH WAIYA ATTENDANCE CENTER" if SchName == "NANIH WAIYA"
replace SchName = "NORTH GULFPORT ELEMENTARY AND MIDDL" if SchName == "NORTH GULFPORT ELEM AND MIDDLE"
replace SchName = "NORTH PANOLA MIDDLE SCHOOL" if SchName == "NORTH PANOLA JR HIGH"
replace SchName = "NORTH PIKE UPPER ELEMENTARY SCHOOL" if SchName == "NORTH PIKE UPPER ELEM"
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
replace SchName = "POTTS CAMP HIGH SCHOOL (4-12)" if strpos(SchName, "POTTS CAMP") > 0 & NCESSchoolID == ""
replace SchName = "PUCKETT ATTENDANCE CENTER" if SchName == "PUCKETT HIGH"
replace SchName = "REUBEN B. MYERS CANTON SCHOOL OF AR" if strpos(SchName, "REUBEN") > 0 & NCESSchoolID == ""
replace SchName = "RULEVILLE MIDDLE SCHOOL" if SchName == "RULEVILLE MIDDLE"
replace SchName = "RULEVILLE CENTRAL ELEM SCHOOL" if SchName == "RULEVILLE CENTRAL ELEM"
replace SchName = "S V MARSHALL ELEMENTARY SCHOOL" if SchName == "S.V. MARSHALL ELEM"
replace SchName = "S V MARSHALL MIDDLE SCHOOL" if SchName == "S. V. MARSHALL MIDDLE"
replace SchName = "SAND HILL ELEMENTARY SCHOOL" if SchName == "SAND HILL ATTENDANCE CENTER"
replace SchName = "SCOTT CENTRAL ATTENDANCE CENTER" if SchName == "SCOTT CENTRAL ATTENDANCE CTR"
replace SchName = "SHIRLEY D. SIMMONS MIDDLE SCHOOL" if SchName == "SHIRLEY SIMMONS MIDDLE"
replace SchName = "SIMMONS HIGH SCHOOL" if SchName == "SIMMONS JR HIGH"
replace SchName = "SMITHVILLE HIGH SCHOOL" if SchName == "SMITHVILLE ATTENDANCE CENTER"
replace SchName = "South Pontotoc Elementary School" if SchName == "SOUTH PONTOTOC ELEM"
replace SchName = "South Pontotoc Middle School" if SchName == "SOUTH PONTOTOC MIDDLE"
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

merge m:1 DistName SchName using "${NCES}/NCES_2021_School.dta", update

drop if _merge == 2
drop _merge

//replace SchName = "Boyd Elementary School" if SchName == "BOYD ELEM"
//replace SchName = "Carver Middle School" if SchName == "CARVER MIDDLE"
//replace SchName = "Carver Elementary School" if SchName == "CARVER ELEM"
//replace SchName = "Central Elementary School" if SchName == "CENTRAL ELEM"
//replace SchName = "Davis Magnet School" if SchName == "DAVIS MAGNET"
//replace SchName = "Greenhill Elementary School" if SchName == "GREENHILL ELEM"
//replace SchName = "Houston Middle School" if SchName == "HOUSTON MIDDLE"
//replace SchName = "Houston Upper Elementary" if SchName == "HOUSTON UPPER ELEM"
//replace SchName = "Lake Elementary School" if SchName == "LAKE ELEM"
//replace SchName = "Lee Elementary School" if SchName == "LEE ELEM"
//replace SchName = "Magnolia Middle School" if SchName == "MAGNOLIA MIDDLE"
//replace SchName = "Marshall Elementary School" if SchName == "MARSHALL ELEM"
//replace SchName = "McLaurin Elementary School" if SchName == "MCLAURIN ELEM"
//replace SchName = "McLeod Elementary School" if SchName == "MCLEOD ELEM"
//replace SchName = "North Bay Elementary School" if SchName == "NORTH BAY ELEM"
//replace SchName = "Oak Park Elementary School" if SchName == "OAK PARK ELEM"
//replace SchName = "Pecan Park Elementary School" if SchName == "PECAN PARK ELEM"
//replace SchName = "Power Apac School" if SchName == "POWER APAC"
//replace SchName = "South Side Elementary School" if SchName == "SOUTH SIDE ELEM"
//replace SchName = "West Elementary School" if SchName == "WEST ELEM"

//merge m:1 DistName SchName using "${NCES}/NCES_Schools.dta", keepusing(NCESSchoolID seasch Virtual SchoolLevel SchoolType) update

//drop if _merge == 2
//drop _merge

replace StateAbbrev = "MS" if DataLevel == 1
replace State = 28 if DataLevel == 1
replace StateFips = 28 if DataLevel == 1

** Generating new variables

gen StateAssignedDistID = State_leaid
gen StateAssignedSchID = seasch

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/CO_AssmtData_2023.dta", replace

export delimited using "${output}/csv/CO_AssmtData_2023.csv", replace
